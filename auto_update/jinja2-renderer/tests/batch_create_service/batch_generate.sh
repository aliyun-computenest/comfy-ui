#!/bin/bash
# batch_generate.sh - 生成独立模型目录结构并自动导入 (修复版)

set -e

# 默认配置
CONFIG_DIR="../../configs"  # 修改为配置目录
OUTPUT_DIR="generated"
TEMP_DIR="temp_params"
SERVICE_LOGO="service_logo.png"
SERVICE_NAME_PREFIX="test"
ENABLE_IMPORT=false
MAX_CONCURRENT_IMPORTS=3  # 最大并发导入数量

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 字符串转大写函数 (兼容 macOS)
to_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# 卸载并重新安装 jinja2-renderer
reinstall_jinja2_renderer() {
    print_info "检查 jinja2-renderer..."

    if command -v jinja2-render &> /dev/null; then
        print_warning "发现已安装的 jinja2-renderer，正在卸载..."

        # 尝试找到安装位置并删除
        local jinja2_path=$(which jinja2-render)
        if [[ -n "$jinja2_path" ]]; then
            print_info "删除 jinja2-render: $jinja2_path"
            rm -f "$jinja2_path" 2>/dev/null || rm -f "$jinja2_path" 2>/dev/null || true
        fi

        # 删除可能的符号链接
        for path in /usr/local/bin/jinja2-render /usr/bin/jinja2-render ~/.local/bin/jinja2-render; do
            if [[ -f "$path" || -L "$path" ]]; then
                print_info "删除 jinja2-render: $path"
                rm -f "$path" 2>/dev/null || rm -f "$path" 2>/dev/null || true
            fi
        done

        print_success "jinja2-renderer 卸载完成"
    fi

    print_info "重新安装 jinja2-renderer..."

    # 删除可能存在的旧目录
    if [[ -d "jinja2-renderer" ]]; then
        rm -rf jinja2-renderer
    fi

    # 克隆并安装
    if git clone http://gitlab.alibaba-inc.com/xuhaoran.xhr/jinja2-renderer.git; then
        cd jinja2-renderer
        if make install; then
            cd ..
            rm -rf jinja2-renderer
            print_success "jinja2-renderer 重新安装成功"

            # 验证安装
            if command -v jinja2-render &> /dev/null; then
                print_success "jinja2-renderer 安装验证通过"
                return 0
            else
                print_error "jinja2-renderer 安装后仍无法找到命令"
                return 1
            fi
        else
            cd ..
            rm -rf jinja2-renderer
            print_error "jinja2-renderer 安装失败"
            return 1
        fi
    else
        print_error "克隆 jinja2-renderer 仓库失败"
        return 1
    fi
}

# 卸载并重新安装 computenest-cli
reinstall_computenest_cli() {
    print_info "检查 computenest-cli..."

    if command -v computenest-cli &> /dev/null; then
        print_warning "发现已安装的 computenest-cli，正在卸载..."

        # 尝试找到安装位置并删除
        local cli_path=$(which computenest-cli)
        if [[ -n "$cli_path" ]]; then
            print_info "删除 computenest-cli: $cli_path"
            rm -f "$cli_path" 2>/dev/null || rm -f "$cli_path" 2>/dev/null || true
        fi

        # 删除可能的符号链接
        for path in /usr/local/bin/computenest-cli /usr/bin/computenest-cli ~/.local/bin/computenest-cli; do
            if [[ -f "$path" || -L "$path" ]]; then
                print_info "删除 computenest-cli: $path"
                rm -f "$path" 2>/dev/null || rm -f "$path" 2>/dev/null || true
            fi
        done

        print_success "computenest-cli 卸载完成"
    fi

    print_info "重新安装 computenest-cli..."

    # 删除可能存在的旧目录
    if [[ -d "computenest-cli" ]]; then
        rm -rf computenest-cli
    fi

    # 克隆并安装
    if git clone https://code.alibaba-inc.com/acs-automation/computenest-cli.git; then
        cd computenest-cli
        print_info "切换到 auto_model 分支..."
        if git checkout auto_model; then
            print_success "成功切换到 auto_model 分支"
            if make install; then
                cd ..
                rm -rf computenest-cli
                print_success "computenest-cli 重新安装成功"

                # 验证安装
                if command -v computenest-cli &> /dev/null; then
                    print_success "computenest-cli 安装验证通过"
                    return 0
                else
                    print_error "computenest-cli 安装后仍无法找到命令"
                    return 1
                fi
            else
                cd ..
                rm -rf computenest-cli
                print_error "computenest-cli 安装失败"
                return 1
            fi
        else
            print_error "切换到 auto_model 分支失败"
            cd ..
            rm -rf computenest-cli
            return 1
        fi
    else
        print_error "克隆 computenest-cli 仓库失败"
        return 1
    fi
}

# 检查并安装 computenest-cli
# 检查并安装 computenest-cli
check_and_install_computenest_cli() {
    # 如果已经安装且可用，询问是否重新安装
    if command -v computenest-cli &> /dev/null; then
        local current_version=$(computenest-cli --version 2>/dev/null || echo "未知版本")
        print_info "发现已安装的 computenest-cli: $current_version"

        # 检查是否是从 whl 安装的期望版本
        if [[ "$current_version" == *"1.9.11"* ]]; then
            print_success "computenest-cli 版本符合要求，跳过安装"
            return 0
        else
            print_warning "computenest-cli 版本可能不匹配，重新安装..."
        fi
    else
        print_info "未找到 computenest-cli，开始安装..."
    fi

    # 从本地 whl 文件安装
    if install_computenest_cli_from_whl; then
        return 0
    else
        print_error "computenest-cli 安装失败"
        return 1
    fi
}

# 克隆并安装 CLI
clone_and_install_cli() {
    print_info "克隆 computenest-cli 仓库..."
    if git clone https://code.alibaba-inc.com/acs-automation/computenest-cli.git; then
        cd computenest-cli
        print_info "切换到 auto_model 分支..."
        if git checkout auto_model; then
            print_success "成功切换到 auto_model 分支"
            make install && cd .. && print_success "computenest-cli 安装成功"
            # 删除 computenest-cli 目录
            rm -rf computenest-cli
            return 0
        else
            print_error "切换到 auto_model 分支失败"
            cd ..
            return 1
        fi
    else
        print_error "克隆 computenest-cli 仓库失败"
        return 1
    fi
}

# 检查依赖
# 修改后的检查依赖函数
check_dependencies() {
    print_info "检查依赖工具..."

    # 强制重新安装 jinja2-renderer
    if ! reinstall_jinja2_renderer; then
        print_error "jinja2-renderer 安装失败"
        exit 1
    fi

    if ! command -v yq &> /dev/null; then
        print_error "yq 未安装，请先安装 yq 工具"
        echo "macOS: brew install yq"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        print_error "jq 未安装，请先安装 jq 工具"
        echo "macOS: brew install jq"
        exit 1
    fi

    # 检查 git 命令
    if ! command -v git &> /dev/null; then
        print_error "git 未安装，请先安装 git"
        exit 1
    fi

    # 如果启用导入功能，强制重新安装 computenest-cli
    if [[ "$ENABLE_IMPORT" == "true" ]]; then
        if ! reinstall_computenest_cli; then
            print_error "computenest-cli 安装失败，无法使用导入功能"
            exit 1
        fi
    fi

    print_success "依赖检查通过"
}

# 检查模板文件和资源文件
check_templates() {
    local templates=("config.yaml.j2" "template.yaml.j2" "k8s-resource.yaml.j2")
    local missing=()

    for template in "${templates[@]}"; do
        if [[ ! -f "$template" ]]; then
            missing+=("$template")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        print_error "缺少模板文件: ${missing[*]}"
        exit 1
    fi

    # 检查 service_logo.png 文件
    if [[ ! -f "$SERVICE_LOGO" ]]; then
        print_warning "未找到 service_logo.png 文件，将跳过复制"
        SERVICE_LOGO=""
    else
        print_success "找到 service_logo.png 文件"
    fi

    print_success "模板文件检查通过"
}

# 创建输出目录结构
setup_directories() {
    print_info "创建输出目录结构..."
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$TEMP_DIR"
    print_success "目录结构创建完成"
}

# 将模型名转换为安全的文件名
sanitize_filename() {
    local name="$1"
    # 提取模型名后缀
    local suffix=$(echo "$name" | sed 's|.*/||')
    # 转换为小写并替换特殊字符
    echo "$suffix" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9\-_]/-/g'
}

# 为单个模型创建目录结构
create_model_directories() {
    local model_dir="$1"

    mkdir -p "$model_dir"
    mkdir -p "$model_dir/resources/file"
    mkdir -p "$model_dir/ros_templates"
    mkdir -p "$model_dir/logs"  # 创建日志目录
}

# 复制资源文件到模型目录
copy_resources() {
    local model_dir="$1"
    local model_name="$2"

    # 复制 service_logo.png
    if [[ -n "$SERVICE_LOGO" && -f "$SERVICE_LOGO" ]]; then
        local target_path="$model_dir/resources/service_logo.png"
        if cp "$SERVICE_LOGO" "$target_path" 2>/dev/null; then
            print_success "  ✓ 复制资源文件: $target_path"
        else
            print_warning "  ⚠ 复制资源文件失败: $SERVICE_LOGO -> $target_path"
        fi
    fi
}

# 推导参数
derive_parameters() {
    local model_name="$1"
    local gpu_type="$2"
    local is_vision="$3"
    local is_fp8="$4"
    local is_deepseek_fp8_ppu="$5"
    local support_public="$6"

    local safe_name=$(sanitize_filename "$model_name")
    local model_suffix=$(echo "$model_name" | sed 's|.*/||')
    local deployment_name=$(echo "$safe_name" | cut -d'-' -f1)

    # 推导GPU支持情况 (使用兼容的大写转换)
    local gpu_type_upper=$(to_upper "$gpu_type")
    local support_h20="false"
    local support_ppu="false"
    local support_h20_3e="false"
    local gpu_model_series=""
    local gpu_type_is_ppu="false"

    case "$gpu_type_upper" in
        "H20")
            support_h20="true"
            gpu_model_series="H20"
            ;;
        "PPU")
            support_ppu="true"
            gpu_model_series="PPU810E"
            gpu_type_is_ppu="true"
            ;;
        "H20-3E")
            support_h20_3e="true"
            gpu_model_series="H20-3e"
            ;;
        *)
            gpu_model_series="$gpu_type"
            ;;
    esac

    # 创建临时 JSON 文件
    local temp_json="$TEMP_DIR/derived_$$.json"
    cat > "$temp_json" << EOF
{
  "ModelNameSuffix": "$model_suffix",
  "EcsImageName": "m-$safe_name-test",
  "DeploymentName": "$deployment_name",
  "SafeFileName": "$safe_name",
  "TemplateFilePath": "ros_templates/template.yaml",
  "K8sResourceFilePath": "resources/file/k8s-resource.yaml",
  "SupportH20": $support_h20,
  "SupportPPU": $support_ppu,
  "SupportH20_3e": $support_h20_3e,
  "gpu_model_series": "$gpu_model_series",
  "gpu_type_is_ppu": $gpu_type_is_ppu,
  "is_vl_model": $is_vision,
  "is_fp8_model": $is_fp8,
  "is_deepseek_fp8_ppu_model": $is_deepseek_fp8_ppu,
  "support_public_access": $support_public
}
EOF

    # 输出文件内容并清理
    cat "$temp_json"
    rm -f "$temp_json"
}

# 合并参数
merge_parameters() {
    local base_params="$1"
    local derived_params="$2"
    local defaults="$3"

    # 创建临时文件来处理 JSON 合并
    local temp_base="$TEMP_DIR/base_$$.json"
    local temp_derived="$TEMP_DIR/derived_$$.json"
    local temp_defaults="$TEMP_DIR/defaults_$$.json"

    echo "$base_params" > "$temp_base"
    echo "$derived_params" > "$temp_derived"
    echo "$defaults" > "$temp_defaults"

    # 使用 jq 逐步合并
    local result
    result=$(jq -s '.[0] + .[1]' "$temp_defaults" "$temp_base")
    result=$(echo "$result" | jq ". + $(cat "$temp_derived")")

    # 清理临时文件
    rm -f "$temp_base" "$temp_derived" "$temp_defaults"

    echo "$result"
}

# 渲染单个模板
render_template() {
    local template_file="$1"
    local params_file="$2"
    local output_file="$3"

    # 创建输出目录
    mkdir -p "$(dirname "$output_file")"

    if jinja2-render "$template_file" -c "$params_file" -o "$output_file" 2>/dev/null; then
        return 0
    else
        # 如果失败，显示错误信息用于调试
        print_error "渲染失败: $template_file -> $output_file"
        jinja2-render "$template_file" -c "$params_file" -o "$output_file" 2>&1 | head -5
        return 1
    fi
}

# 修复后的异步执行 computenest-cli import
async_import_model() {
    local model_dir="$1"
    local safe_name="$2"
    local service_name="$3"

    local log_file="$model_dir/logs/import.log"
    local pid_file="$model_dir/logs/import.pid"
    local status_file="$model_dir/logs/import.status"

    # 获取绝对路径
    local abs_model_dir=$(cd "$model_dir" && pwd)

    # 创建导入脚本 - 修复路径问题
    cat > "$model_dir/logs/import.sh" << EOF
#!/bin/bash
# 切换到模型目录
cd "$abs_model_dir"

LOG_FILE="logs/import.log"
STATUS_FILE="logs/import.status"

echo "\$(date '+%Y-%m-%d %H:%M:%S') - 开始导入模型: $safe_name" > "\$LOG_FILE"
echo "服务名称: $service_name" >> "\$LOG_FILE"
echo "配置文件: config.yaml" >> "\$LOG_FILE"
echo "工作目录: \$(pwd)" >> "\$LOG_FILE"
echo "----------------------------------------" >> "\$LOG_FILE"

# 执行导入命令
echo "\$(date '+%Y-%m-%d %H:%M:%S') - 执行导入命令..." >> "\$LOG_FILE"
if computenest-cli import \\
    --service_name "$service_name" \\
    --file_path config.yaml \\
    --update_artifact False >> "\$LOG_FILE" 2>&1; then
    echo "\$(date '+%Y-%m-%d %H:%M:%S') - 导入成功: $safe_name" >> "\$LOG_FILE"
    echo "SUCCESS" > "\$STATUS_FILE"
else
    echo "\$(date '+%Y-%m-%d %H:%M:%S') - 导入失败: $safe_name" >> "\$LOG_FILE"
    echo "FAILED" > "\$STATUS_FILE"
    exit 1
fi
EOF

    chmod +x "$model_dir/logs/import.sh"

    # 异步执行导入脚本
    nohup bash "$model_dir/logs/import.sh" > /dev/null 2>&1 &
    local import_pid=$!

    # 保存 PID
    echo "$import_pid" > "$pid_file"

    print_info "  ✓ 启动异步导入任务: $service_name (PID: $import_pid)"
}

# 修复后的管理并发导入
manage_concurrent_imports() {
    local import_dirs=("$@")
    local total=${#import_dirs[@]}
    local running_pids=()
    local completed=0
    local index=0

    if [[ $total -eq 0 ]]; then
        return
    fi

    print_info "开始管理 $total 个导入任务，最大并发: $MAX_CONCURRENT_IMPORTS"

    while [[ $completed -lt $total ]]; do
        # 清理已完成的任务
        local new_running_pids=()
        for pid in "${running_pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                new_running_pids+=("$pid")
            else
                ((completed++))
                print_info "导入任务完成 (PID: $pid), 进度: $completed/$total"
            fi
        done
        running_pids=("${new_running_pids[@]}")

        # 启动新任务（如果有空闲槽位且还有待处理任务）
        while [[ ${#running_pids[@]} -lt $MAX_CONCURRENT_IMPORTS && $index -lt $total ]]; do
            local model_dir="${import_dirs[$index]}"
            local safe_name=$(basename "$model_dir")
            local service_name="${SERVICE_NAME_PREFIX}-${safe_name}"

            # 启动导入任务
            async_import_model "$model_dir" "$safe_name" "$service_name"

            # 从 PID 文件读取 PID
            local pid_file="$model_dir/logs/import.pid"
            if [[ -f "$pid_file" ]]; then
                local import_pid=$(cat "$pid_file")
                running_pids+=("$import_pid")
                print_info "启动导入任务 $((index + 1))/$total: $service_name (PID: $import_pid)"
            else
                print_error "无法获取导入任务 PID: $service_name"
            fi

            ((index++))
        done

        # 如果还有任务在运行，等待一段时间再检查
        if [[ ${#running_pids[@]} -gt 0 ]]; then
            sleep 2
        fi
    done

    print_success "所有导入任务已完成"
}

# 等待导入任务完成
wait_for_imports() {
    local model_dirs=("$@")
    local total_imports=${#model_dirs[@]}
    local completed=0
    local failed=0

    if [[ $total_imports -eq 0 ]]; then
        return
    fi

    print_info "等待 $total_imports 个导入任务完成..."

    while [[ $completed -lt $total_imports ]]; do
        local current_completed=0
        local current_failed=0

        for model_dir in "${model_dirs[@]}"; do
            local status_file="$model_dir/logs/import.status"
            local pid_file="$model_dir/logs/import.pid"

            if [[ -f "$status_file" ]]; then
                local status=$(cat "$status_file")
                if [[ "$status" == "SUCCESS" ]]; then
                    ((current_completed++))
                elif [[ "$status" == "FAILED" ]]; then
                    ((current_completed++))
                    ((current_failed++))
                fi
            elif [[ -f "$pid_file" ]]; then
                local pid=$(cat "$pid_file")
                # 检查进程是否还在运行
                if ! kill -0 "$pid" 2>/dev/null; then
                    # 进程已结束，但没有状态文件，可能异常退出
                    echo "FAILED" > "$status_file"
                    ((current_completed++))
                    ((current_failed++))
                fi
            fi
        done

        if [[ $current_completed -ne $completed ]]; then
            completed=$current_completed
            failed=$current_failed
            print_info "导入进度: $completed/$total_imports (失败: $failed)"
        fi

        if [[ $completed -lt $total_imports ]]; then
            sleep 5  # 等待5秒后再次检查
        fi
    done

    print_info "所有导入任务完成: 成功 $((completed - failed))/$total_imports, 失败 $failed/$total_imports"
}

# 显示导入结果摘要
show_import_summary() {
    if [[ "$ENABLE_IMPORT" != "true" ]]; then
        return
    fi

    print_info "导入结果摘要:"

    local total=0
    local success=0
    local failed=0

    for model_dir in "$OUTPUT_DIR"/*; do
        if [[ -d "$model_dir" ]]; then
            local model_name=$(basename "$model_dir")
            local status_file="$model_dir/logs/import.status"
            local log_file="$model_dir/logs/import.log"

            ((total++))

            if [[ -f "$status_file" ]]; then
                local status=$(cat "$status_file")
                if [[ "$status" == "SUCCESS" ]]; then
                    echo -e "  ${GREEN}✓${NC} $model_name"
                    ((success++))
                else
                    echo -e "  ${RED}✗${NC} $model_name"
                    ((failed++))
                    if [[ -f "$log_file" ]]; then
                        echo "    错误详情: tail -10 $log_file"
                    fi
                fi
            else
                echo -e "  ${YELLOW}?${NC} $model_name (状态未知)"
                ((failed++))
            fi
        fi
    done

    echo
    print_info "导入统计: 总计 $total, 成功 $success, 失败 $failed"

    if [[ $failed -gt 0 ]]; then
        print_warning "查看失败详情请检查各模型目录下的 logs/import.log 文件"
    fi
}

# 处理单个模型
process_model() {
    local model_config="$1"
    local defaults="$2"
    local index="$3"
    local total="$4"

    # 提取模型参数
    local model_name=$(echo "$model_config" | yq -r '.ModelName')
    local gpu_type=$(echo "$model_config" | yq -r '.GPUType // "H20"')
    local is_vision=$(echo "$model_config" | yq -r '.IsVisionModel // false')
    local is_fp8=$(echo "$model_config" | yq -r '.IsFP8Model // false')
    local is_deepseek_fp8_ppu=$(echo "$model_config" | yq -r '.IsDeepSeekFP8PPUModel // false')
    local support_public=$(echo "$model_config" | yq -r '.SupportPublicAccess // true')

    print_info "[$index/$total] 处理模型: $model_name"

    local safe_name=$(sanitize_filename "$model_name")
    local model_dir="$OUTPUT_DIR/$safe_name"

    # 创建模型目录结构
    create_model_directories "$model_dir"

    # 复制资源文件
    copy_resources "$model_dir" "$model_name"

    # 推导参数
    local derived_params
    derived_params=$(derive_parameters "$model_name" "$gpu_type" "$is_vision" "$is_fp8" "$is_deepseek_fp8_ppu" "$support_public")

    if [[ $? -ne 0 ]]; then
        print_error "  ✗ 参数推导失败"
        return 1
    fi

    # 合并所有参数
    local final_params
    final_params=$(merge_parameters "$model_config" "$derived_params" "$defaults")

    if [[ $? -ne 0 ]]; then
        print_error "  ✗ 参数合并失败"
        return 1
    fi

    # 创建临时参数文件
    local temp_params="$TEMP_DIR/params_${index}.json"
    echo "$final_params" > "$temp_params"

    # 验证 JSON 格式
    if ! jq empty "$temp_params" 2>/dev/null; then
        print_error "  ✗ 生成的参数文件格式错误"
        print_error "参数内容预览:"
        head -10 "$temp_params" | sed 's/^/    /'
        rm -f "$temp_params"
        return 1
    fi

    # 定义文件映射：模板文件:输出路径
    local file_mappings=(
        "config.yaml.j2:$model_dir/config.yaml"
        "template.yaml.j2:$model_dir/ros_templates/template.yaml"
        "k8s-resource.yaml.j2:$model_dir/resources/file/k8s-resource.yaml"
    )

    local success=true

    # 渲染所有文件
    for mapping in "${file_mappings[@]}"; do
        IFS=':' read -r template_file output_path <<< "$mapping"

        if render_template "$template_file" "$temp_params" "$output_path"; then
            print_success "  ✓ 生成: $output_path"
        else
            success=false
        fi
    done

    # 清理临时文件
    rm -f "$temp_params"

    if [[ "$success" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# 加载配置文件
load_configs() {
    local config_dir="$1"

    print_info "从配置目录加载配置: $config_dir"

    # 检查配置目录是否存在
    if [[ ! -d "$config_dir" ]]; then
        print_error "配置目录不存在: $config_dir"
        exit 1
    fi

    # 检查必要的配置文件
    local global_config="$config_dir/global_config.yaml"
    local defaults_config="$config_dir/defaults.yaml"
    local models_index="$config_dir/models.yaml"
    local models_dir="$config_dir/models"

    if [[ ! -f "$global_config" ]]; then
        print_error "全局配置文件不存在: $global_config"
        exit 1
    fi

    if [[ ! -f "$defaults_config" ]]; then
        print_error "默认配置文件不存在: $defaults_config"
        exit 1
    fi

    if [[ ! -f "$models_index" ]]; then
        print_error "模型索引文件不存在: $models_index"
        exit 1
    fi

    if [[ ! -d "$models_dir" ]]; then
        print_error "模型配置目录不存在: $models_dir"
        exit 1
    fi

    print_success "配置文件检查通过"

    # 加载全局配置
    GLOBAL_CONFIG=$(yq -o json "$global_config")

    # 加载默认配置
    DEFAULTS_CONFIG=$(yq -o json "$defaults_config")

    # 加载模型索引
    MODELS_INDEX=$(yq -o json "$models_index")

    print_success "配置文件加载完成"
}

# 加载单个模型配置
load_model_config() {
    local config_dir="$1"
    local model_config_file="$2"
    local model_full_path="$config_dir/$model_config_file"

    if [[ ! -f "$model_full_path" ]]; then
        print_error "模型配置文件不存在: $model_full_path"
        return 1
    fi

    yq -o json "$model_full_path"
}

# 批量处理模型 - 修改为使用新的配置结构
batch_process() {
    local config_dir="$1"

    print_info "解析配置目录: $config_dir"

    # 加载配置文件
    load_configs "$config_dir"

    # 提取默认配置
    local defaults
    defaults=$(echo "$DEFAULTS_CONFIG" | jq '.defaults // {}')

    if [[ $? -ne 0 ]]; then
        print_error "解析默认配置失败"
        exit 1
    fi

    # 获取模型数量
    local models_count
    models_count=$(echo "$MODELS_INDEX" | jq '.models | length')

    if [[ $? -ne 0 ]] || [[ "$models_count" -eq 0 ]]; then
        print_error "模型索引中没有找到模型配置"
        exit 1
    fi

    print_info "找到 $models_count 个模型配置"

    local success_count=0
    local import_dirs=()

    # 处理每个模型
    for ((i=0; i<models_count; i++)); do
        local model_index_entry
        model_index_entry=$(echo "$MODELS_INDEX" | jq -r ".models[$i]")

        if [[ $? -ne 0 ]]; then
            print_error "解析模型索引失败: 索引 $i"
            continue
        fi

        local model_name=$(echo "$model_index_entry" | jq -r '.name')
        local config_file=$(echo "$model_index_entry" | jq -r '.config_file')
        local enabled=$(echo "$model_index_entry" | jq -r '.enabled // true')

        if [[ "$enabled" != "true" ]]; then
            print_info "[$((i+1))/$models_count] 跳过禁用的模型: $model_name"
            continue
        fi

        print_info "[$((i+1))/$models_count] 加载模型配置: $model_name ($config_file)"

        # 加载具体的模型配置
        local model_config
        model_config=$(load_model_config "$config_dir" "$config_file")

        if [[ $? -ne 0 ]]; then
            print_error "加载模型配置失败: $config_file"
            continue
        fi

        # 将模型配置转换为批处理需要的格式 - 修复 jq 语法
        local formatted_model_config
        formatted_model_config=$(echo "$model_config" | jq '{
            ModelName: .model_name,
            GPUType: (if .gpu_type then .gpu_type else "H20" end),
            IsVisionModel: (if .is_vision_model != null then .is_vision_model else false end),
            IsFP8Model: (if .is_fp8_model != null then .is_fp8_model else false end),
            IsDeepSeekFP8PPUModel: (if .is_deepseek_fp8_ppu_model != null then .is_deepseek_fp8_ppu_model else false end),
            SupportPublicAccess: (if .support_public_access != null then .support_public_access else true end),
            SystemDiskSize: (if .system_disk_size then .system_disk_size elif .disk_size then .disk_size else 450 end)
        }')

        if process_model "$formatted_model_config" "$defaults" "$((i+1))" "$models_count"; then
            ((success_count++))

            # 如果启用导入功能，记录成功的模型目录
            if [[ "$ENABLE_IMPORT" == "true" ]]; then
                local safe_name=$(sanitize_filename "$(echo "$formatted_model_config" | jq -r '.ModelName')")
                import_dirs+=("$OUTPUT_DIR/$safe_name")
            fi
        fi
    done

    print_info "批量处理完成: $success_count/$models_count 成功"

    if [[ $success_count -eq $models_count ]]; then
        print_success "所有模型处理成功！"
    else
        print_warning "部分模型处理失败"
    fi

    # 如果启用导入功能，管理并发导入任务
    if [[ "$ENABLE_IMPORT" == "true" && ${#import_dirs[@]} -gt 0 ]]; then
        manage_concurrent_imports "${import_dirs[@]}"
        wait_for_imports "${import_dirs[@]}"
    fi
}

# 显示生成结果
show_results() {
    print_info "生成的文件结构:"
    if [[ -d "$OUTPUT_DIR" ]]; then
        # 使用 tree 命令显示目录结构（如果可用）
        if command -v tree &> /dev/null; then
            tree "$OUTPUT_DIR" -I "__pycache__|*.pyc|*.pid"
        else
            # 手动显示目录结构
            echo "  $OUTPUT_DIR/"
            for model_dir in "$OUTPUT_DIR"/*; do
                if [[ -d "$model_dir" ]]; then
                    local model_name=$(basename "$model_dir")
                    echo "  ├── $model_name/"
                    echo "  │   ├── config.yaml"
                    if [[ "$ENABLE_IMPORT" == "true" ]]; then
                        echo "  │   ├── logs/"
                        echo "  │   │   ├── import.log"
                        echo "  │   │   └── import.sh"
                    fi
                    echo "  │   ├── resources/"
                    if [[ -f "$model_dir/resources/service_logo.png" ]]; then
                        echo "  │   │   ├── service_logo.png"
                    fi
                    echo "  │   │   └── file/"
                    echo "  │   │       └── k8s-resource.yaml"
                    echo "  │   └── ros_templates/"
                    echo "  │       └── template.yaml"
                fi
            done
        fi

        # 统计文件数量
        local model_count=$(find "$OUTPUT_DIR" -maxdepth 1 -type d | grep -v "^$OUTPUT_DIR$" | wc -l | tr -d ' ')
        local config_count=$(find "$OUTPUT_DIR" -name "config.yaml" | wc -l | tr -d ' ')
        local template_count=$(find "$OUTPUT_DIR" -name "template.yaml" | wc -l | tr -d ' ')
        local k8s_count=$(find "$OUTPUT_DIR" -name "k8s-resource.yaml" | wc -l | tr -d ' ')
        local logo_count=$(find "$OUTPUT_DIR" -name "service_logo.png" | wc -l | tr -d ' ')

        echo
        print_info "文件统计:"
        echo "  - 模型目录: $model_count"
        echo "  - 配置文件: $config_count"
        echo "  - 模板文件: $template_count"
        echo "  - K8s资源文件: $k8s_count"
        echo "  - Logo文件: $logo_count"

        if [[ "$ENABLE_IMPORT" == "true" ]]; then
            local log_count=$(find "$OUTPUT_DIR" -name "import.log" | wc -l | tr -d ' ')
            echo "  - 导入日志: $log_count"
        fi
    else
        print_warning "输出目录不存在"
    fi
}

# 验证文件引用关系
validate_references() {
    print_info "验证文件引用关系..."

    local validation_errors=0

    # 检查每个模型目录的文件完整性
    for model_dir in "$OUTPUT_DIR"/*; do
        if [[ -d "$model_dir" ]]; then
            local model_name=$(basename "$model_dir")
            local config_file="$model_dir/config.yaml"
            local template_file="$model_dir/ros_templates/template.yaml"
            local k8s_file="$model_dir/resources/file/k8s-resource.yaml"
            local logo_file="$model_dir/resources/service_logo.png"

            # 检查必要文件是否存在
            if [[ ! -f "$config_file" ]]; then
                print_error "  ✗ 缺少配置文件: $config_file"
                ((validation_errors++))
            fi

            if [[ ! -f "$template_file" ]]; then
                print_error "  ✗ 缺少模板文件: $template_file"
                ((validation_errors++))
            fi

            if [[ ! -f "$k8s_file" ]]; then
                print_error "  ✗ 缺少K8s资源文件: $k8s_file"
                ((validation_errors++))
            fi

            # 检查 logo 文件（可选）
            if [[ -n "$SERVICE_LOGO" && ! -f "$logo_file" ]]; then
                print_warning "  ⚠ 缺少Logo文件: $logo_file"
            fi

            # 检查 config.yaml 中的路径引用
            if [[ -f "$config_file" ]]; then
                if ! grep -q "ros_templates/template.yaml" "$config_file"; then
                    print_warning "  ⚠ $config_file 中可能缺少模板路径引用"
                fi

                if ! grep -q "resources/file/k8s-resource.yaml" "$config_file"; then
                    print_warning "  ⚠ $config_file 中可能缺少K8s资源路径引用"
                fi

                if ! grep -q "resources/service_logo.png" "$config_file"; then
                    print_warning "  ⚠ $config_file 中可能缺少Logo路径引用"
                fi
            fi
        fi
    done

    if [[ $validation_errors -eq 0 ]]; then
        print_success "文件引用关系验证通过"
    else
        print_warning "发现 $validation_errors 个引用问题"
    fi
}

# 显示帮助
show_help() {
    cat << EOF
批量配置文件生成脚本 (独立模型目录结构 + 自动导入)

使用方法:
    $0 [选项]

选项:
    -c, --config DIR        指定配置目录 (默认: ../../configs)
    -o, --output DIR        指定输出目录 (默认: generated)
    -s, --service-prefix    服务名前缀 (默认: test)
    --import                启用自动导入功能
    --max-concurrent N      最大并发导入数量 (默认: 3)
    -h, --help              显示帮助信息
    --clean                 清理输出目录
    --validate              仅验证文件引用关系
    --debug                 启用调试模式

配置目录结构:
    configs/
    ├── global_config.yaml          # 全局配置
    ├── defaults.yaml               # 默认配置
    ├── models.yaml                 # 模型索引文件
    └── models/                     # 模型配置目录
        ├── wanx-2.1.yaml          # 各个模型的独立配置
        ├── wanx-2.2.yaml
        └── ...

输出目录结构:
    generated/
    ├── model-name-1/
    │   ├── config.yaml
    │   ├── logs/                   # 导入日志目录
    │   │   ├── import.log          # 导入日志
    │   │   ├── import.sh           # 导入脚本
    │   │   └── import.status       # 导入状态
    │   ├── resources/
    │   │   ├── service_logo.png    # 自动复制
    │   │   └── file/
    │   │       └── k8s-resource.yaml
    │   └── ros_templates/
    │       └── template.yaml

导入功能:
    - 自动执行 computenest-cli import 命令
    - 异步并发执行，支持设置最大并发数
    - 完整的日志记录和状态跟踪
    - 服务名格式: {prefix}-{model-safe-name}
    - 自动安装 computenest-cli (如果未安装)

依赖安装:
    # jinja2-render
    git clone http://gitlab.alibaba-inc.com/xuhaoran.xhr/jinja2-renderer.git
    cd jinja2-renderer && make install

    # macOS 依赖
    brew install yq jq

    # computenest-cli 会自动安装

示例:
    $0 -c ../../configs                         # 仅生成文件
    $0 -c ../../configs --import                # 生成文件并自动导入
    $0 --import -s "my-service"                 # 使用自定义服务名前缀
    $0 --import --max-concurrent 5              # 设置最大并发数为5
    $0 --debug --import                         # 启用调试模式
EOF
}

# 清理输出目录
clean_output() {
    if [[ -d "$OUTPUT_DIR" ]]; then
        print_info "清理输出目录: $OUTPUT_DIR"

        # 如果有正在运行的导入任务，先终止它们
        for model_dir in "$OUTPUT_DIR"/*; do
            if [[ -d "$model_dir" && -f "$model_dir/logs/import.pid" ]]; then
                local pid=$(cat "$model_dir/logs/import.pid")
                if kill -0 "$pid" 2>/dev/null; then
                    print_warning "终止导入任务 PID: $pid"
                    kill "$pid" 2>/dev/null || true
                fi
            fi
        done

        rm -rf "$OUTPUT_DIR"
        print_success "清理完成"
    else
        print_info "输出目录不存在，无需清理"
    fi
}

# 调试模式
DEBUG_MODE=false

# 主函数
main() {
    print_info "开始批量生成配置文件..."

    if [[ "$DEBUG_MODE" == "true" ]]; then
        set -x  # 启用调试输出
    fi

    # 检查依赖
    check_dependencies

    # 检查模板文件和资源文件
    check_templates

    # 检查配置目录
    if [[ ! -d "$CONFIG_DIR" ]]; then
        print_error "配置目录不存在: $CONFIG_DIR"
        exit 1
    fi

    # 创建输出目录结构
    setup_directories

    # 批量处理
    batch_process "$CONFIG_DIR"

    # 验证文件引用关系
    validate_references

    # 显示结果
    show_results

    # 显示导入结果摘要
    show_import_summary

    print_success "批量生成完成！输出目录: $OUTPUT_DIR"

    if [[ "$ENABLE_IMPORT" == "true" ]]; then
        print_info "导入日志位置: $OUTPUT_DIR/*/logs/import.log"
    fi
}

# 参数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            CONFIG_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -s|--service-prefix)
            SERVICE_NAME_PREFIX="$2"
            shift 2
            ;;
        --import)
            ENABLE_IMPORT=true
            shift
            ;;
        --max-concurrent)
            MAX_CONCURRENT_IMPORTS="$2"
            shift 2
            ;;
        --clean)
            clean_output
            exit 0
            ;;
        --validate)
            if [[ -d "$OUTPUT_DIR" ]]; then
                validate_references
            else
                print_error "输出目录不存在: $OUTPUT_DIR"
                exit 1
            fi
            exit 0
            ;;
        --debug)
            DEBUG_MODE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 清理函数
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi

    # 如果脚本被中断，尝试清理正在运行的导入任务
    if [[ "$ENABLE_IMPORT" == "true" ]]; then
        for model_dir in "$OUTPUT_DIR"/*; do
            if [[ -d "$model_dir" && -f "$model_dir/logs/import.pid" ]]; then
                local pid=$(cat "$model_dir/logs/import.pid")
                if kill -0 "$pid" 2>/dev/null; then
                    print_warning "清理时终止导入任务 PID: $pid"
                    kill "$pid" 2>/dev/null || true
                fi
            fi
        done
    fi
}

# 设置退出时清理
trap cleanup EXIT

# 执行主函数
main