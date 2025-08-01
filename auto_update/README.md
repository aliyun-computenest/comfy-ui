# 自动更新系统

本目录包含了 ComfyUI 配置的自动更新和批量生成系统。

## 目录结构

```
auto_update/
├── README.md                           # 说明文档
├── configs/                            # 统一配置目录
│   ├── global_config.yaml             # 全局配置
│   └── wanx_models.yaml                # WanX系列模型配置
├── scripts/                            # 管理脚本
│   ├── update_model_configs.py         # 更新ComputeNest配置
│   ├── validate_configs.py             # 验证配置
│   └── example_usage.py                # 使用示例
├── batch_generator/                    # 批量生成系统
│   ├── batch_generate.sh               # 批量生成脚本
│   ├── templates/                      # Jinja2模板
│   │   ├── config.yaml.j2              # 配置模板
│   │   ├── template.yaml.j2            # ROS模板
│   │   └── k8s-resource.yaml.j2        # K8s资源模板
│   └── resources/                      # 资源文件
│       └── service_logo.png            # 服务Logo
└── jinja2-renderer/                    # Jinja2渲染工具
    └── ...                             # 原有工具代码
```

## 功能特性

### 1. 统一配置管理
- 支持多文件配置结构
- 使用 ruamel.yaml 保持格式和注释
- 自动验证配置完整性

### 2. 自动更新系统
- 自动更新 ComputeNest 主配置
- 自动更新所有 ROS 模板
- 支持模型启用/禁用控制

### 3. 批量生成系统
- 批量生成独立模型服务目录
- 支持异步并发导入
- 完整的日志记录和状态跟踪

## 使用方法

### 配置管理
```bash
cd auto_update

# 更新配置
python3 scripts/update_model_configs.py --config-dir configs

# 验证配置
python3 scripts/validate_configs.py --config-dir configs

# 查看使用示例
python3 scripts/example_usage.py help
```

### 批量生成
```bash
cd auto_update/batch_generator

# 生成配置文件（使用统一配置）
./batch_generate.sh --config ../configs/unified_model_config.yaml

# 生成并自动导入
./batch_generate.sh --config ../configs/unified_model_config.yaml --import

# 查看帮助
./batch_generate.sh --help
```

## 配置文件格式

统一配置文件支持两套系统的所有功能，包含：
- 基础模型信息（名称、镜像、磁盘大小等）
- GPU配置（支持的GPU类型、可用区等）
- ComputeNest配置（构建命令、超时等）
- 批量生成配置（模板路径、服务前缀等）