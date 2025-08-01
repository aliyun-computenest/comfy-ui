#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup, find_packages
import sys

# 根据 Python 版本选择合适的依赖
install_requires = []

# Python 版本特定的依赖
if sys.version_info >= (3, 8):
    # Python 3.8+ 使用较新但兼容的版本
    install_requires.extend([
        "jinja2>=3.0.0,<4.0",  # 使用 3.x 版本以兼容新的 MarkupSafe
        "pyyaml>=6.0",
        "markupsafe>=2.0.0,<3.0",  # 限制在 2.x 版本
    ])
elif sys.version_info >= (3, 7):
    # Python 3.7 使用中等版本
    install_requires.extend([
        "jinja2>=2.11.0,<3.0",
        "pyyaml>=5.4.1,<7.0",
        "markupsafe>=1.1.0,<2.1.0",  # 使用兼容的版本
    ])
else:
    # Python 3.6 使用较老但稳定的版本
    install_requires.extend([
        "jinja2>=2.10,<3.0",
        "pyyaml>=5.1,<6.0",
        "markupsafe>=1.1.0,<2.0.0",
    ])

setup(
    name="jinja2-renderer",
    version="0.2.0",
    description="一个简单的Jinja2模板渲染命令行工具",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="Your Name",
    author_email="your.email@example.com",
    url="https://github.com/yourusername/jinja2-renderer",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=install_requires,
    entry_points={
        'console_scripts': [
            'jinja2-render=jinja2_renderer.cli:main',
        ],
    },
    python_requires='>=3.6',
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
    keywords="jinja2, template, renderer",
    license="MIT",
)
