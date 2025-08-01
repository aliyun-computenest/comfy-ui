#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ComputeNest 模型配置验证工具 (Auto Update版本)
用于验证模型配置文件的完整性和一致性
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
            if 'global_config' in config:
                global_config = config['global_config']

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

        if 'global_config' in config:
            global_config.update(config['global_config'])

        if 'models' in config:
            all_models.extend(config['models'])

    return all_models, global_config

def validate_model_config(model, model_index):
    """验证单个模型配置"""
    print(f"🔍 验证模型 {model_index + 1}: {model.get('model_name', 'Unknown')}")

    errors = []
    warnings = []

    # 必需字段验证
    required_fields = [
        'model_name', 'model_type', 'display_name', 'disk_size',
        'deployment_name', 'model_image', 'artifact_name', 'source_image_id'
    ]

    for field in required_fields:
        if field not in model or not model[field]:
            errors.append(f"缺少必需字段: {field}")

    # 可选但推荐的字段
    recommended_fields = ['timeout', 'type', 'enabled']
    for field in recommended_fields:
        if field not in model:
            warnings.append(f"建议添加字段: {field}")

    # GPU配置验证
    if 'gpu_configs' in model:
        if not isinstance(model['gpu_configs'], list):
            errors.append("gpu_configs 必须是列表")
        else:
            for i, gpu_config in enumerate(model['gpu_configs']):
                if not isinstance(gpu_config, dict):
                    errors.append(f"gpu_configs[{i}] 必须是对象")
                    continue

                gpu_required_fields = ['gpu_type', 'hardware', 'label', 'zones']
                for field in gpu_required_fields:
                    if field not in gpu_config:
                        errors.append(f"gpu_configs[{i}] 缺少必需字段: {field}")

    # 批量生成系统兼容性验证
    batch_recommended_fields = ['gpu_type', 'system_disk_size', 'support_min_gpu_amount', 'support_max_gpu_amount']
    for field in batch_recommended_fields:
        if field not in model:
            warnings.append(f"批量生成系统建议添加字段: {field}")

    # 输出验证结果
    if errors:
        print(f"  ❌ 发现 {len(errors)} 个错误:")
        for error in errors:
            print(f"    - {error}")

    if warnings:
        print(f"  ⚠️  发现 {len(warnings)} 个警告:")
        for warning in warnings:
            print(f"    - {warning}")

    if not errors and not warnings:
        print(f"  ✅ 配置验证通过")

    return len(errors) == 0

def validate_global_config(global_config):
    """验证全局配置"""
    print("🔍 验证全局配置...")

    errors = []
    warnings = []

    # ComputeNest配置验证
    if 'default_regions' not in global_config:
        errors.append("缺少 default_regions 配置")
    elif not isinstance(global_config['default_regions'], list):
        errors.append("default_regions 必须是列表")

    if 'default_build_command' not in global_config:
        warnings.append("建议添加 default_build_command 配置")

    # 批量生成配置验证
    if 'batch_generator' in global_config:
        batch_config = global_config['batch_generator']
        batch_required_fields = ['service_name_prefix', 'template_dir', 'output_dir']
        for field in batch_required_fields:
            if field not in batch_config:
                warnings.append(f"batch_generator 建议添加字段: {field}")

    # 输出验证结果
    if errors:
        print(f"  ❌ 发现 {len(errors)} 个错误:")
        for error in errors:
            print(f"    - {error}")

    if warnings:
        print(f"  ⚠️  发现 {len(warnings)} 个警告:")
        for warning in warnings:
            print(f"    - {warning}")

    if not errors and not warnings:
        print(f"  ✅ 全局配置验证通过")

    return len(errors) == 0

def validate_file_references(config_dir, main_config_path, templates_dir):
    """验证文件引用的有效性"""
    print("🔍 验证文件引用...")

    errors = []

    # 检查主配置文件
    if not Path(main_config_path).exists():
        errors.append(f"ComputeNest 主配置文件不存在: {main_config_path}")

    # 检查模板目录
    templates_path = Path(templates_dir)
    if not templates_path.exists():
        errors.append(f"ROS 模板目录不存在: {templates_dir}")
    else:
        # 检查关键模板文件
        key_templates = ['template.yaml', 'final_template.yaml', 'exist_template.yaml']
        for template in key_templates:
            template_path = templates_path / template
            if not template_path.exists():
                errors.append(f"关键模板文件不存在: {template_path}")

    # 检查批量生成相关文件
    batch_generator_dir = Path(config_dir).parent / "batch_generator"
    if batch_generator_dir.exists():
        batch_script = batch_generator_dir / "batch_generate.sh"
        if not batch_script.exists():
            errors.append(f"批量生成脚本不存在: {batch_script}")

        templates_dir_batch = batch_generator_dir / "templates"
        if not templates_dir_batch.exists():
            errors.append(f"批量生成模板目录不存在: {templates_dir_batch}")

    if errors:
        print(f"  ❌ 发现 {len(errors)} 个文件引用错误:")
        for error in errors:
            print(f"    - {error}")
        return False
    else:
        print("  ✅ 文件引用验证通过")
        return True

def check_consistency(models, global_config):
    """检查配置一致性"""
    print("🔍 检查配置一致性...")

    warnings = []

    # 检查模型名称唯一性
    model_names = [model.get('model_name') for model in models]
    duplicates = set([name for name in model_names if model_names.count(name) > 1])
    if duplicates:
        warnings.append(f"发现重复的模型名称: {duplicates}")

    # 检查artifact_name唯一性
    artifact_names = [model.get('artifact_name') for model in models if model.get('artifact_name')]
    duplicates = set([name for name in artifact_names if artifact_names.count(name) > 1])
    if duplicates:
        warnings.append(f"发现重复的artifact_name: {duplicates}")

    # 检查model_image唯一性
    model_images = [model.get('model_image') for model in models if model.get('model_image')]
    duplicates = set([image for image in model_images if model_images.count(image) > 1])
    if duplicates:
        warnings.append(f"发现重复的model_image: {duplicates}")

    if warnings:
        print(f"  ⚠️  发现 {len(warnings)} 个一致性警告:")
        for warning in warnings:
            print(f"    - {warning}")
    else:
        print("  ✅ 配置一致性检查通过")

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='验证 ComputeNest 模型配置')
    parser.add_argument('--config-dir',
                       default='auto_update/configs',
                       help='配置文件目录 (默认: auto_update/configs)')
    parser.add_argument('--main-config',
                       default='.computenest/config.yaml',
                       help='ComputeNest 主配置文件路径')
    parser.add_argument('--ros-templates-dir',
                       default='.computenest/ros_templates',
                       help='ROS 模板目录路径')
    parser.add_argument('--check-files',
                       action='store_true',
                       help='检查文件引用的有效性')

    args = parser.parse_args()

    try:
        print("🚀 开始验证模型配置...")

        # 加载配置
        models, global_config = load_config_files(args.config_dir)

        if not models:
            print("⚠️  没有找到模型配置")
            return

        print(f"📊 找到 {len(models)} 个模型配置")

        # 验证全局配置
        global_valid = validate_global_config(global_config)

        # 验证每个模型配置
        model_errors = 0
        for i, model in enumerate(models):
            if not validate_model_config(model, i):
                model_errors += 1

        # 检查配置一致性
        check_consistency(models, global_config)

        # 检查文件引用
        files_valid = True
        if args.check_files:
            files_valid = validate_file_references(
                args.config_dir,
                args.main_config,
                args.ros_templates_dir
            )

        # 输出总结
        print("\n" + "="*50)
        print("📋 验证结果摘要:")
        print(f"  - 配置文件: {args.config_dir}")
        print(f"  - 模型数量: {len(models)}")
        print(f"  - 启用模型: {len([m for m in models if m.get('enabled', True)])}")
        print(f"  - 全局配置: {'✅ 通过' if global_valid else '❌ 有错误'}")
        print(f"  - 模型配置: {'✅ 通过' if model_errors == 0 else f'❌ {model_errors} 个模型有错误'}")

        if args.check_files:
            print(f"  - 文件引用: {'✅ 通过' if files_valid else '❌ 有错误'}")

        if global_valid and model_errors == 0 and (not args.check_files or files_valid):
            print("\n🎉 所有配置验证通过！")
            return 0
        else:
            print("\n❌ 配置验证失败，请修复上述问题")
            return 1

    except Exception as e:
        print(f"❌ 验证过程中出错: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())