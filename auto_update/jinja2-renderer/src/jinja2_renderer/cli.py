import os
import sys
import argparse
import json
from .renderer import TemplateRenderer


def parse_args():
    parser = argparse.ArgumentParser(description='Jinja2 模板渲染工具')

    parser.add_argument('template', help='模板文件路径')

    parser.add_argument('-o', '--output', required=True,
                        help='输出文件路径')

    context_group = parser.add_mutually_exclusive_group(required=True)
    context_group.add_argument('-c', '--context-file',
                               help='包含渲染上下文的JSON或YAML文件')
    context_group.add_argument('-j', '--json-string',
                               help='JSON格式的渲染上下文字符串')

    parser.add_argument('-d', '--template-dir',
                        help='模板目录，默认为当前目录')

    return parser.parse_args()


def main():
    args = parse_args()

    try:
        # 设置模板目录
        template_dir = args.template_dir
        if not template_dir:
            template_dir = os.path.dirname(os.path.abspath(args.template))

        # 初始化渲染器
        renderer = TemplateRenderer(template_dir)

        # 获取上下文数据
        if args.context_file:
            context = renderer.load_context_from_file(args.context_file)
        else:
            try:
                context = json.loads(args.json_string)
            except json.JSONDecodeError as e:
                print(f"错误: JSON解析失败 - {e}", file=sys.stderr)
                sys.exit(1)

        # 获取模板名称（相对于模板目录）
        if args.template_dir:
            template_path = os.path.abspath(args.template)
            template_dir_path = os.path.abspath(args.template_dir)
            if template_path.startswith(template_dir_path):
                template_name = os.path.relpath(template_path, template_dir_path)
            else:
                template_name = os.path.basename(args.template)
        else:
            template_name = os.path.basename(args.template)

        # 渲染模板并输出
        output_file = renderer.render_to_file(template_name, context, args.output)
        print(f"模板已成功渲染到: {output_file}")

    except Exception as e:
        print(f"错误: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
