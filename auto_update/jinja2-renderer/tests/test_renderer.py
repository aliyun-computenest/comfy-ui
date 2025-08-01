import os
import tempfile
import json
import yaml
import pytest
from src.jinja2_renderer import TemplateRenderer


class TestTemplateRenderer:
    def setup_method(self):
        # 创建临时目录用于测试
        self.temp_dir = tempfile.TemporaryDirectory()

        # 创建一个简单的模板文件
        self.template_path = os.path.join(self.temp_dir.name, "template.j2")
        with open(self.template_path, "w") as f:
            f.write(
                "Hello, {{ name }}!\n{% if items %}Items: {% for item in items %}{{ item }}{% if not loop.last %}, {% endif %}{% endfor %}{% endif %}")

        # 创建渲染器
        self.renderer = TemplateRenderer(self.temp_dir.name)

        # 测试上下文
        self.context = {
            "name": "World",
            "items": ["apple", "banana", "orange"]
        }

    def teardown_method(self):
        # 清理临时目录
        self.temp_dir.cleanup()

    def test_render_template(self):
        # 测试模板渲染
        result = self.renderer.render_template("template.j2", self.context)
        assert result == "Hello, World!\nItems: apple, banana, orange"

    def test_render_to_file(self):
        # 测试渲染到文件
        output_path = os.path.join(self.temp_dir.name, "output.yaml")
        self.renderer.render_to_file("template.j2", self.context, output_path)

        # 验证文件内容
        with open(output_path, "r") as f:
            content = f.read()

        assert content == "Hello, World!\nItems: apple, banana, orange"

    def test_load_context_from_json_file(self):
        # 创建JSON上下文文件
        json_path = os.path.join(self.temp_dir.name, "context.yaml")
        with open(json_path, "w") as f:
            json.dump(self.context, f)

        # 测试加载JSON上下文
        loaded_context = self.renderer.load_context_from_file(json_path)
        assert loaded_context == self.context

    def test_load_context_from_yaml_file(self):
        # 创建YAML上下文文件
        yaml_path = os.path.join(self.temp_dir.name, "context.yaml")
        with open(yaml_path, "w") as f:
            yaml.dump(self.context, f)

        # 测试加载YAML上下文
        loaded_context = self.renderer.load_context_from_file(yaml_path)
        assert loaded_context == self.context

    def test_file_not_found(self):
        # 测试文件不存在的情况
        with pytest.raises(FileNotFoundError):
            self.renderer.load_context_from_file("nonexistent.json")

    def test_unsupported_format(self):
        # 测试不支持的文件格式
        unsupported_path = os.path.join(self.temp_dir.name, "context.txt")
        with open(unsupported_path, "w") as f:
            f.write("name: World")

        with pytest.raises(ValueError):
            self.renderer.load_context_from_file(unsupported_path)
