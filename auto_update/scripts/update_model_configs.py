#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ComputeNest 模型配置自动更新工具 (Auto Update版本)
用于自动同步模型配置到 ComputeNest 主配置文件和所有 ROS 模板文件
"""

import os
import sys
import argparse
from pathlib import Path
from ruamel.yaml import YAML

# 添加项目根目录到Python路径，支持从auto_update目录运行
current_dir = Path(__file__).parent
project_root = current_dir.parent.parent
sys.path.insert(0, str(project_root))

def setup_yaml():
    """配置 ruamel.yaml 以保持原始格式"""
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.width = 4096
    yaml.indent(mapping=2, sequence=4, offset=2)
    return yaml

def load_config_files(config_dir):
    """加载配置目录下的所有YAML文件"""
    config_path = Path(config_dir)

    if not config_path.exists():
        raise FileNotFoundError(f"配置目录不存在: {config_dir}")

    yaml = setup_yaml()
    all_models = []
    global_config = {}

    # 支持统一配置文件
    unified_config_file = config_path / "unified_model_config.yaml"
    if unified_config_file.exists():
        print(f"📖 读取统一配置文件: {unified_config_file}")
        with open(unified_config_file, 'r', encoding='utf-8') as f:
            config = yaml.load(f)

        if config:
            # 提取全局配置
            if 'global_config' in config:
                global_config = config['global_config']

            # 提取模型配置
            if 'models' in config:
                all_models.extend(config['models'])

        return all_models, global_config

    # 否则读取分离的配置文件
    config_files = list(config_path.glob("*.yaml")) + list(config_path.glob("*.yml"))

    if not config_files:
        raise FileNotFoundError(f"配置目录中没有找到YAML配置文件: {config_dir}")

    for config_file in sorted(config_files):
        print(f"📖 读取配置文件: {config_file}")

        with open(config_file, 'r', encoding='utf-8') as f:
            config = yaml.load(f)

        if not config:
            continue

        # 如果有全局配置，合并到global_config
        if 'global_config' in config:
            global_config.update(config['global_config'])

        # 提取模型配置
        if 'models' in config:
            all_models.extend(config['models'])

    return all_models, global_config

def validate_model_config(model):
    """验证单个模型配置的有效性"""
    required_fields = [
        'model_name', 'model_type', 'display_name', 'disk_size',
        'deployment_name', 'model_image', 'artifact_name', 'source_image_id'
    ]

    for field in required_fields:
        if field not in model or not model[field]:
            print(f"错误: 模型 {model['model_name']} 缺少必需字段: {field}")
            return False

    return True

def update_computenest_config(models, config_path, global_config):
    """更新ComputeNest主配置文件"""
    print(f"🔄 更新 ComputeNest 配置文件: {config_path}")

    yaml = setup_yaml()
    config_data = yaml.load(open(config_path, 'r', encoding='utf-8'))

    if not config_data:
        return

    # 确保Artifact节点存在
    if 'Artifact' not in config_data:
        config_data['Artifact'] = {}

    default_regions = global_config.get('default_regions', [])
    default_build_command = global_config.get('default_build_command', '')

    # 更新模型的Artifact配置
    for model in models:
        if not model.get('enabled', True):
            continue

        artifact_name = model.get('artifact_name')
        if not artifact_name:
            continue

        artifact_config = {
            'ArtifactType': 'EcsImage',
            'ArtifactName': model.get('model_image'),
            'Description': f"ComfyUI {model.get('display_name')} 镜像，预装 ComfyUI 环境",
            'SupportRegionIds': default_regions,
            'ArtifactProperty': {
                'RegionId': 'ap-southeast-1'
            },
            'ArtifactBuildProperty': {
                'EnableGpu': True,
                'RegionId': 'ap-southeast-1',
                'SourceImageId': model.get('source_image_id'),
                'SystemDiskSize': model.get('disk_size'),
                'CommandType': 'RunShellScript',
                'Timeout': model.get('timeout'),
                'CommandContent': default_build_command
            }
        }

        config_data['Artifact'][artifact_name] = artifact_config

    # 更新ArtifactRelation配置
    if 'Service' in config_data and 'DeployMetadata' in config_data['Service']:
        deploy_metadata = config_data['Service']['DeployMetadata']

        if 'SupplierDeployMetadata' in deploy_metadata:
            supplier_metadata = deploy_metadata['SupplierDeployMetadata']
            if 'ArtifactRelation' not in supplier_metadata:
                supplier_metadata['ArtifactRelation'] = {}

            for model in models:
                if not model.get('enabled', True):
                    continue

                model_image = model.get('model_image')
                artifact_name = model.get('artifact_name')
                if model_image and artifact_name:
                    supplier_metadata['ArtifactRelation'][model_image] = {
                        'ArtifactId': f"${{Artifact.{artifact_name}.ArtifactId}}",
                        'ArtifactVersion': 'draft'
                    }

    with open(config_path, 'w', encoding='utf-8') as f:
        yaml.dump(config_data, f)
        print(f"✅ 已更新文件: {config_path}")

def update_ros_template(template_path, models):
    """更新ROS模板文件"""
    print(f"🔄 更新 ROS 模板: {template_path.name}")

    yaml = setup_yaml()
    template_data = yaml.load(open(template_path, 'r', encoding='utf-8'))

    if not template_data:
        return

    # 更新ModelSeries参数的AllowedValues
    if 'Parameters' in template_data and 'ModelSeries' in template_data['Parameters']:
        model_series_param = template_data['Parameters']['ModelSeries']

        allowed_values = [model.get('model_name') for model in models if model.get('enabled', True)]

        model_series_param['AllowedValues'] = allowed_values

        if allowed_values:
            model_series_param['Default'] = allowed_values[0]

    # 更新Mappings
    if 'Mappings' not in template_data:
        template_data['Mappings'] = {}

    if 'ModelMapping' not in template_data['Mappings']:
        template_data['Mappings']['ModelMapping'] = {}

    model_mapping = template_data['Mappings']['ModelMapping']

    if 'ModelImageMap' not in model_mapping:
        model_mapping['ModelImageMap'] = {}
    if 'ModelDiskSizeMap' not in model_mapping:
        model_mapping['ModelDiskSizeMap'] = {}

    for model in models:
        if not model.get('enabled', True):
            continue

        model_name = model.get('model_name')
        model_image = model.get('model_image')
        disk_size = model.get('disk_size')

        if model_name and model_image:
            model_mapping['ModelImageMap'][model_name] = model_image

        if model_name and disk_size:
            model_mapping['ModelDiskSizeMap'][model_name] = disk_size

    with open(template_path, 'w', encoding='utf-8') as f:
        yaml.dump(template_data, f)
        print(f"✅ 已更新文件: {template_path}")

def update_all_ros_templates(models, templates_dir):
    """更新所有ROS模板文件"""
    print(f"🔄 更新所有 ROS 模板: {templates_dir}")

    templates_path = Path(templates_dir)

    if not templates_path.exists():
        print(f"警告: 模板目录不存在: {templates_dir}")
        return

    for template_file in templates_path.glob("*.yaml") + templates_path.glob("*.yml"):
        update_ros_template(template_file, models)

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='自动更新 ComputeNest 模型配置')
    parser.add_argument('--config-dir',
                       default='auto_update/configs',  # 更新默认路径
                       help='配置文件目录 (默认: auto_update/configs)')
    parser.add_argument('--main-config',
                       default='.computenest/config.yaml',
                       help='ComputeNest 主配置文件路径')
    parser.add_argument('--ros-templates-dir',
                       default='.computenest/ros_templates',
                       help='ROS 模板目录路径')
    parser.add_argument('--dry-run',
                       action='store_true',
                       help='预览模式，不实际修改文件')

    args = parser.parse_args()

    try:
        print("🚀 开始更新模型配置...")

        # 加载模型配置
        models, global_config = load_config_files(args.config_dir)

        if not models:
            print("⚠️  没有找到模型配置")
            return

        # 验证模型配置
        print("🔍 验证模型配置...")
        for model in models:
            validate_model_config(model)
        print("✅ 模型配置验证通过")

        # 更新 ComputeNest 主配置文件
        if not args.dry_run:
            print("🔄 更新 ComputeNest 配置文件...")
            update_computenest_config(models, args.main_config, global_config)
            print(f"✅ 已更新文件: {args.main_config}")
        else:
            print(f"🔍 预览模式: 将更新 {args.main_config}")

        # 更新所有 ROS 模板
        if not args.dry_run:
            print("🔄 更新所有 ROS 模板...")
            update_all_ros_templates(models, args.ros_templates_dir)
        else:
            print(f"🔍 预览模式: 将更新 {args.ros_templates_dir} 目录下的模板")

        print("🎉 所有配置文件更新完成！")

    except Exception as e:
        print(f"❌ 错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()