import os
import json
import yaml
from jinja2 import Environment, FileSystemLoader, select_autoescape


class TemplateRenderer:
    def __init__(self, template_dir=None):
        """初始化模板渲染器"""
        if template_dir is None:
            template_dir = os.getcwd()
        self.env = Environment(
            loader=FileSystemLoader(template_dir),
            autoescape=select_autoescape(['html', 'xml']),
            # 对于 YAML 模板，建议关闭这些选项或者更谨慎地使用
            trim_blocks=False,  # 改为 False
            lstrip_blocks=False  # 改为 False
        )

    def load_context_from_file(self, context_file):
        """从文件加载上下文数据"""
        if not os.path.exists(context_file):
            raise FileNotFoundError(f"上下文文件不存在: {context_file}")

        file_ext = os.path.splitext(context_file)[1].lower()

        with open(context_file, 'r', encoding='utf-8') as f:
            if file_ext == '.json':
                return json.load(f)
            elif file_ext in ('.yaml', '.yml'):
                return yaml.safe_load(f)
            else:
                raise ValueError(f"不支持的上下文文件格式: {file_ext}")

    def render_template(self, template_name, context):
        """渲染模板"""
        template = self.env.get_template(template_name)
        return template.render(**context)

    def render_to_file(self, template_name, context, output_file):
        """渲染模板并写入文件"""
        content = self.render_template(template_name, context)

        # 确保输出目录存在
        output_dir = os.path.dirname(output_file)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(content)

        return output_file
