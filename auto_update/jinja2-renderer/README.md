# Jinja2 模板渲染工具

一个简单的命令行工具，用于渲染 Jinja2 模板。

## 安装

### 在线安装

```bash
pip install jinja2-renderer

离线安装
下载离线安装包 jinja2-renderer-offline.tar.gz
解压安装包：tar -xzf jinja2-renderer-offline.tar.gz
运行安装脚本：cd jinja2-renderer-offline && ./install.sh


# 使用JSON文件作为上下文
jinja2-render template.j2 -c context.json -o output.txt

# 使用YAML文件作为上下文
jinja2-render template.j2 -c context.yaml -o output.txt

# 直接提供JSON字符串作为上下文
jinja2-render template.j2 -j '{"name": "World"}' -o output.txt

# 指定模板目录
jinja2-render template.j2 -c context.json -o output.txt -d /path/to/templates
