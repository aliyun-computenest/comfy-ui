import os
import json
import tempfile
import pytest
from unittest.mock import patch, MagicMock
from src.jinja2_renderer import main, parse_args


class TestCLI:
    def setup_method(self):
        # 创建临时目录用于测试
        self.temp_dir = tempfile.TemporaryDirectory()

        # 创建一个简单的模板文件
        self.template_path = os.path.join(self.temp_dir.name, "template.j2")
        with open(self.template_path, "w") as f:
            f.write("Hello, {{ name }}!")

        # 创建一个上下文文件
        self.context = {"name": "World"}
        self.context_path = os.path.join(self.temp_dir.name, "context.yaml")
        with open(self.context_path, "w") as f:
            json.dump(self.context, f)

        # 输出路径
        self.output_path = os.path.join(self.temp_dir.name, "output.yaml")

    def teardown_method(self):
        # 清理临时目录
        self.temp_dir.cleanup()

    def test_parse_args_with_context_file(self):
        # 测试解析带有上下文文件的参数
        with patch('sys.argv', ['jinja2-render', self.template_path, '-c', self.context_path, '-o', self.output_path]):
            args = parse_args()
            assert args.template == self.template_path
            assert args.context_file == self.context_path
            assert args.output == self.output_path
            assert args.json_string is None

    def test_parse_args_with_json_string(self):
        # 测试解析带有JSON字符串的参数
        json_str = '{"name": "World"}'
        with patch('sys.argv', ['jinja2-render', self.template_path, '-j', json_str, '-o', self.output_path]):
            args = parse_args()
            assert args.template == self.template_path
            assert args.json_string == json_str
            assert args.output == self.output_path
            assert args.context_file is None

    @patch('jinja2_renderer.cli.TemplateRenderer')
    def test_main_with_context_file(self, mock_renderer_class):
        # 模拟渲染器
        mock_renderer = MagicMock()
        mock_renderer_class.return_value = mock_renderer
        mock_renderer.load_context_from_file.return_value = self.context

        # 测试使用上下文文件的主函数
        with patch('sys.argv', ['jinja2-render', self.template_path, '-c', self.context_path, '-o', self.output_path]):
            main()

            # 验证调用
            mock_renderer_class.assert_called_once()
            mock_renderer.load_context_from_file.assert_called_once_with(self.context_path)
            mock_renderer.render_to_file.assert_called_once()

    @patch('jinja2_renderer.cli.TemplateRenderer')
    def test_main_with_json_string(self, mock_renderer_class):
        # 模拟渲染器
        mock_renderer = MagicMock()
        mock_renderer_class.return_value = mock_renderer

        # 测试使用JSON字符串的主函数
        json_str = '{"name": "World"}'
        with patch('sys.argv', ['jinja2-render', self.template_path, '-j', json_str, '-o', self.output_path]):
            main()

            # 验证调用
            mock_renderer_class.assert_called_once()
            mock_renderer.render_to_file.assert_called_once()
