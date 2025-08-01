.PHONY: clean build install test lint wheels offline-package help check-python

PYTHON := python3
PIP := pip3
PACKAGE_NAME := jinja2-renderer
WHEEL_DIR := ./wheels

help:
	@echo "使用说明:"
	@echo "  make clean         - 清理构建文件和缓存"
	@echo "  make build         - 构建项目"
	@echo "  make install       - 安装项目到当前环境"
	@echo "  make dev-install   - 以开发模式安装项目"
	@echo "  make test          - 运行测试"
	@echo "  make lint          - 运行代码检查"
	@echo "  make wheels        - 创建wheel包用于离线安装"
	@echo "  make offline-package - 创建完整的离线安装包"
	@echo "  make check-python  - 检查Python版本"

check-python:
	@echo "检查 Python 版本..."
	@$(PYTHON) -c "import sys; print(f'Python {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')"
	@$(PYTHON) -c "import sys; sys.exit(0 if sys.version_info >= (3, 6) else 1)" || (echo "错误: 需要 Python 3.6 或更高版本" && exit 1)

clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info
	rm -rf src/*.egg-info
	rm -rf $(WHEEL_DIR)
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

build: check-python clean
	@echo "使用传统方式构建以确保兼容性..."
	$(PYTHON) setup.py sdist bdist_wheel

install: build
	$(PIP) install dist/*.whl --force-reinstall

dev-install: check-python
	$(PIP) install -e .

test: check-python
	$(PYTHON) -m pytest

lint:
	$(PIP) install black isort flake8
	$(PYTHON) -m black src tests
	$(PYTHON) -m isort src tests
	$(PYTHON) -m flake8 src tests

# 为不同 Python 版本创建 wheels
wheels: check-python clean
	mkdir -p $(WHEEL_DIR)
	@echo "检测 Python 版本并下载对应依赖..."
	@$(PYTHON) -c "import sys; \
	py_ver = f'{sys.version_info.major}.{sys.version_info.minor}'; \
	print(f'Python 版本: {py_ver}'); \
	deps = []; \
	if sys.version_info >= (3, 8): \
		deps = ['jinja2>=2.10,<3.0', 'pyyaml>=6.0', 'markupsafe>=2.0.0']; \
	elif sys.version_info >= (3, 7): \
		deps = ['jinja2>=2.10,<3.0', 'pyyaml>=5.4.1,<7.0', 'markupsafe>=1.1.0,<2.1.0']; \
	else: \
		deps = ['jinja2>=2.10,<3.0', 'pyyaml>=5.1,<6.0', 'markupsafe>=1.1.0,<2.0.0']; \
	print('依赖包:', deps); \
	import subprocess; \
	for dep in deps: \
		try: \
			subprocess.run(['$(PIP)', 'download', '--only-binary=:all:', '--dest', '$(WHEEL_DIR)', dep], check=True); \
		except: \
			print(f'下载 {dep} 的二进制包失败，尝试下载源码包...'); \
			subprocess.run(['$(PIP)', 'download', '--dest', '$(WHEEL_DIR)', dep], check=True)"
	# 构建我们自己的包
	$(PYTHON) setup.py bdist_wheel
	cp dist/*.whl $(WHEEL_DIR)/

# 为当前 Python 版本快速修复
fix-install: check-python
	@echo "为当前 Python 版本修复安装..."
	$(PIP) install --upgrade pip setuptools wheel
	@echo "检测 Python 版本并安装对应依赖..."
	@$(PYTHON) -c "import sys; print(f'Python 版本: {sys.version_info.major}.{sys.version_info.minor}')"
	@if $(PYTHON) -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)"; then \
		echo "Python 3.8+ 检测到，安装兼容版本依赖..."; \
		$(PIP) install "jinja2>=3.0.0,<4.0" "pyyaml>=6.0" "markupsafe>=2.0.0,<3.0"; \
	elif $(PYTHON) -c "import sys; sys.exit(0 if sys.version_info >= (3, 7) else 1)"; then \
		echo "Python 3.7 检测到，安装中等版本依赖..."; \
		$(PIP) install "jinja2>=2.11.0,<3.0" "pyyaml>=5.4.1,<7.0" "markupsafe>=1.1.0,<2.1.0"; \
	else \
		echo "Python 3.6 检测到，安装兼容版本依赖..."; \
		$(PIP) install "jinja2>=2.10,<3.0" "pyyaml>=5.1,<6.0" "markupsafe>=1.1.0,<2.0.0"; \
	fi
	@echo "构建和安装 jinja2-renderer..."
	$(PYTHON) setup.py bdist_wheel
	$(PIP) install dist/*.whl --force-reinstall
	@echo "安装完成！验证安装..."
	jinja2-render --help || echo "验证失败，但安装可能已完成"