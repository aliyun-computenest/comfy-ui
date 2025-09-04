#!/bin/bash
sudo yum install zstd --disablerepo=nvidia-container-toolkit --disablerepo=nvidia-container-toolkit-experimental -y
curl -o ossutil-2.1.2-linux-amd64.zip https://gosspublic.alicdn.com/ossutil/v2/2.1.2/ossutil-2.1.2-linux-amd64.zip
unzip ossutil-2.1.2-linux-amd64.zip
cd ossutil-2.1.2-linux-amd64
chmod 755 ossutil
sudo mv ossutil /usr/local/bin/ && sudo ln -s /usr/local/bin/ossutil /usr/bin/ossutil
ossutil
cd /root

# 从参数获取配置
MODEL_NAME="$1"
ACCESS_KEY_ID="${2:-$OSS_ACCESS_KEY_ID}"
ACCESS_KEY_SECRET="${3:-$OSS_ACCESS_KEY_SECRET}"
CHECK_ONLY="false"



# 配置信息
SOURCE_BUCKET="oss://computenest-artifacts-cn-hangzhou"
ENDPOINT="oss-cn-hangzhou-internal.aliyuncs.com"
LOCAL_FILE="./model.tar.zst"
OSS_OBJECT="model-data/$MODEL_NAME/model.tar.zst"

# 重试参数
MAX_RETRIES=300
RETRY_INTERVAL=10

# 目标地域列表（直接列出地域名）
TARGET_REGIONS=(
    "cn-qingdao"
    "cn-beijing"
    "cn-zhangjiakou"
    "cn-huhehaote"
    "cn-wulanchabu"
    "cn-hangzhou"
    "cn-shanghai"
    "cn-shenzhen"
    "cn-heyuan"
    "cn-guangzhou"
    "cn-chengdu"
    "cn-hongkong"
    "ap-northeast-1"
    "ap-southeast-1"
    "ap-southeast-3"
    "ap-southeast-5"
    "ap-southeast-6"
    "us-east-1"
    "us-west-1"
    "eu-west-1"
    "eu-central-1"
    "me-east-1"
    "ap-southeast-7"
    "ap-northeast-2"
    "na-south-1"
    "cn-wuhan-lr"
)

# 生成ossutil配置文件
echo "生成ossutil配置文件..."
cat >> ~/.ossutilconfig <<EOF
[Credentials]

endpoint = oss-cn-hangzhou-internal.aliyuncs.com

accessKeyID = $ACCESS_KEY_ID

accessKeySecret = $ACCESS_KEY_SECRET

region = cn-hangzhou

EOF

if [ "$CHECK_ONLY" = "false" ]; then
    # 开始校验目录
    echo "开始校验目录..."
    if [ ! -d "./storage" ]; then
        echo "错误: 模型目录 './storage' 不存在!"
        exit 1
    fi

    if [ -z "$(ls -A "./storage" 2>/dev/null)" ]; then
        echo "错误: 模型目录 './storage' 为空!"
        exit 1
    fi
    # 打包模型文件
    echo "开始打包文件..."
    tar -cvf - ./storage | zstd -T0 -o "$LOCAL_FILE"

    # 上传文件到源Bucket
    echo "正在上传文件到源Bucket..."
    ossutil cp "$LOCAL_FILE" "$SOURCE_BUCKET/$OSS_OBJECT" --force --acl public-read
    if [ $? -ne 0 ]; then
        echo "文件上传失败!"
        exit 1
    fi
else
    echo "跳过打包和上传步骤"
fi

# 获取源文件ETag
echo "获取源文件ETag..."
source_etag=$(ossutil stat "$SOURCE_BUCKET/$OSS_OBJECT" | grep "Etag" | cut -d'"' -f2)
if [ -z "$source_etag" ]; then
    echo "无法获取源文件ETag!"
    exit 1
fi
echo "源文件ETag: $source_etag"

# 遍历所有目标检查同步状态
all_synced=true
total_regions=${#TARGET_REGIONS[@]}
current_region=0

echo "开始检查 $total_regions 个目标地域的同步状态..."

for target_region in "${TARGET_REGIONS[@]}"; do
    current_region=$((current_region + 1))

    # 自动生成bucket名称和endpoint
    target_bucket="computenest-artifacts-$target_region"
    target_endpoint="oss-$target_region.aliyuncs.com"

    echo "[$current_region/$total_regions] 检查目标地域: $target_region, Bucket: $target_bucket"

    success=false
    for ((retry=1; retry<=MAX_RETRIES; retry++)); do
        # 获取目标文件ETag
        target_etag=$(ossutil -e "$target_endpoint" --region "$target_region" stat "oss://$target_bucket/$OSS_OBJECT" 2>/dev/null | grep "Etag" | cut -d'"' -f2)

        if [ -n "$target_etag" ] && [ "$target_etag" = "$source_etag" ]; then
            success=true
            break
        elif [ $retry -eq $MAX_RETRIES ]; then
            break
        else
            if [ $((retry % 6)) -eq 0 ]; then  # 每6次重试输出一次进度
                echo "  等待同步中...($retry/$MAX_RETRIES)"
            fi
            sleep $RETRY_INTERVAL
        fi
    done

    if $success; then
        echo "  ✅ 同步成功: $target_region"
    else
        echo "  ❌ 同步失败: $target_region"
        all_synced=false
    fi
done

# 清理本地文件
# echo "清理本地文件..."
# rm -f "$LOCAL_FILE"

# 最终状态
if $all_synced; then
    echo "🎉 所有地域同步完成!"
    exit 0
else
    echo "💥 部分地域同步失败!"
    exit 1
fi