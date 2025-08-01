#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
模型配置管理系统使用示例 (Auto Update版本)
演示如何在auto_update目录结构下使用配置管理和批量生成功能
"""

import subprocess
import sys
import os
from pathlib import Path

# 添加项目根目录到Python路径
current_dir = Path(__file__).parent
project_root = current_dir.parent.parent
sys.path.insert(0, str(project_root))

def run_command(cmd, description, cwd=None):
    """运行命令并显示结果"""
    print(f"\n🔄 {description}")
    print(f"执行命令: {cmd}")
    if cwd:
        print(f"工作目录: {cwd}")

    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            cwd=cwd
        )
        if result.returncode == 0:
            print(f"✅ 成功")
            if result.stdout:
                print(f"输出:\n{result.stdout}")
        else:
            print(f"❌ 失败")
            if result.stderr:
                print(f"错误:\n{result.stderr}")
        return result.returncode == 0
    except Exception as e:
        print(f"❌ 执行失败: {e}")
        return False

def check_prerequisites():
    """检查前置条件"""
    print("🔍 检查前置条件...")

    # 检查Python版本
    if sys.version_info < (3, 6):
        print("❌ 需要Python 3.6或更高版本")
        return False

    # 检查ruamel.yaml是否安装
    try:
        from ruamel.yaml import YAML
        print("✅ ruamel.yaml已安装")
    except ImportError:
        print("❌ 需要安装ruamel.yaml: pip install ruamel.yaml")
        return False

    # 检查必要文件和目录
    auto_update_dir = Path("auto_update")
    if not auto_update_dir.exists():
        print("❌ auto_update目录不存在")
        return False

    required_paths = [
        "auto_update/configs",
        "auto_update/scripts",
        ".computenest/config.yaml"
    ]

    missing_paths = []
    for path_str in required_paths:
        path = Path(path_str)
        if not path.exists():
            missing_paths.append(path_str)

    if missing_paths:
        print(f"❌ 缺少必要文件/目录: {missing_paths}")
        return False

    print("✅ 所有前置条件满足")
    return True

def show_current_models():
    """显示当前配置的模型"""
    print("\n📋 当前配置的模型:")

    try:
        from ruamel.yaml import YAML
        yaml = YAML()

        all_models = []

        # 检查统一配置文件
        unified_config = Path("auto_update/configs/unified_model_config.yaml")
        if unified_config.exists():
            with open(unified_config, 'r', encoding='utf-8') as f:
                config = yaml.load(f)

            if config and 'models' in config:
                all_models = config['models']
        else:
            # 检查分离的配置文件
            config_dir = Path("auto_update/configs")
            if config_dir.exists():
                config_files = list(config_dir.glob("*.yaml")) + list(config_dir.glob("*.yml"))

                for config_file in sorted(config_files):
                    with open(config_file, 'r', encoding='utf-8') as f:
                        config = yaml.load(f)

                    if config and 'models' in config:
                        all_models.extend(config['models'])

        enabled_models = [m for m in all_models if m.get('enabled', True)]

        for i, model in enumerate(enabled_models, 1):
            print(f"  {i}. {model.get('model_name', 'Unknown')}")
            print(f"     镜像: {model.get('model_image', 'Unknown')}")
            print(f"     磁盘大小: {model.get('disk_size', 'Unknown')}GB")
            print(f"     GPU类型: {model.get('gpu_type', 'Unknown')}")
            print()

        return len(enabled_models)
    except Exception as e:
        print(f"❌ 读取配置失败: {e}")
        return 0

def demonstrate_config_management():
    """演示配置管理功能"""
    print("\n🔧 演示配置管理功能")
    print("="*60)

    scripts_dir = "auto_update/scripts"

    # 1. 验证当前配置
    print("\n🔍 验证当前配置状态...")
    run_command(
        f"python3 {scripts_dir}/validate_configs.py --config-dir auto_update/configs --check-files",
        "验证配置文件和文件引用"
    )

    # 2. 预览配置更新
    print("\n🔍 预览配置更新...")
    run_command(
        f"python3 {scripts_dir}/update_model_configs.py --config-dir auto_update/configs --dry-run",
        "预览配置更新（不实际修改）"
    )

    # 3. 执行配置更新
    print("\n🔄 执行配置更新...")
    run_command(
        f"python3 {scripts_dir}/update_model_configs.py --config-dir auto_update/configs",
        "更新ComputeNest配置文件"
    )

    # 4. 再次验证配置
    print("\n✅ 验证更新后的配置...")
    run_command(
        f"python3 {scripts_dir}/validate_configs.py --config-dir auto_update/configs",
        "验证更新后的配置"
    )

def demonstrate_batch_generation():
    """演示批量生成功能"""
    print("\n🏭 演示批量生成功能")
    print("="*60)

    batch_dir = "auto_update/batch_generator"

    if not Path(batch_dir).exists():
        print(f"❌ 批量生成目录不存在: {batch_dir}")
        return False

    # 检查批量生成脚本和配置
    batch_script = Path(f"{batch_dir}/batch_generate.sh")
    if not batch_script.exists():
        print(f"❌ 批量生成脚本不存在: {batch_script}")
        return False

    # 运行批量生成（预览模式）
    print("\n🔍 预览批量生成...")
    run_command(
        f"cd {batch_dir} && ./batch_generate.sh --config ../configs/unified_model_config.yaml --help",
        "查看批量生成帮助信息",
        cwd=batch_dir
    )

    return True

def show_help():
    """显示帮助信息"""
    print("""
模型配置管理系统 - 使用指南 (Auto Update版本)

📁 新的目录结构:
  auto_update/                        - 自动更新主目录
  ├── configs/                        - 统一配置目录
  │   ├── unified_model_config.yaml   - 统一配置文件
  │   ├── global_config.yaml          - 全局配置（分离模式）
  │   └── wanx_models.yaml            - 模型配置（分离模式）
  ├── scripts/                        - 配置管理脚本
  │   ├── update_model_configs.py     - 自动更新脚本
  │   ├── validate_configs.py         - 配置验证脚本
  │   └── example_usage.py            - 使用示例
  └── batch_generator/                - 批量生成系统
      ├── batch_generate.sh           - 批量生成脚本
      ├── templates/                  - Jinja2模板
      └── resources/                  - 资源文件

🔧 配置管理功能:
  # 验证配置
  python3 auto_update/scripts/validate_configs.py
  
  # 更新配置
  python3 auto_update/scripts/update_model_configs.py
  
  # 指定配置目录
  python3 auto_update/scripts/update_model_configs.py --config-dir auto_update/configs
  
  # 预览模式
  python3 auto_update/scripts/update_model_configs.py --dry-run

🏭 批量生成功能:
  # 进入批量生成目录
  cd auto_update/batch_generator
  
  # 生成配置文件
  ./batch_generate.sh --config ../configs/unified_model_config.yaml
  
  # 生成并自动导入
  ./batch_generate.sh --config ../configs/unified_model_config.yaml --import
  
  # 查看帮助
  ./batch_generate.sh --help

📋 配置文件特性:
  ✅ 支持统一配置文件和分离配置文件两种模式
  ✅ 兼容配置管理和批量生成两套系统
  ✅ 使用ruamel.yaml保持原始格式和注释
  ✅ 自动验证配置完整性和一致性
  ✅ 支持模型启用/禁用控制

🔄 工作流程:
  1. 编辑 auto_update/configs/ 下的配置文件
  2. 运行验证脚本检查配置
  3. 运行更新脚本同步到ComputeNest
  4. （可选）运行批量生成创建独立服务
  5. 提交更改到版本控制

📖 更多详细信息请查看 auto_update/README.md
""")

def main():
    """主函数"""
    if len(sys.argv) < 2:
        show_help()
        return

    command = sys.argv[1].lower()

    if command == "demo":
        if check_prerequisites():
            demonstrate_config_management()
            demonstrate_batch_generation()
    elif command == "config":
        if check_prerequisites():
            demonstrate_config_management()
    elif command == "batch":
        if check_prerequisites():
            demonstrate_batch_generation()
    elif command == "check":
        check_prerequisites()
    elif command == "models":
        show_current_models()
    elif command == "help" or command == "-h" or command == "--help":
        show_help()
    else:
        print(f"未知命令: {command}")
        print("使用 'python3 auto_update/scripts/example_usage.py help' 查看帮助")

if __name__ == "__main__":
    main()