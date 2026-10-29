# -*- coding: utf-8 -*-
"""
ta_kiss_iphy library

:copyright: Nokia
:author: leo wang
:contact: leo.y.wang@nokia.com
"""
import os
from setuptools import setup, find_packages

req_path = os.path.join(os.getcwd(), 'requirements', 'base.txt')
requirements = [line.strip() for line in open(req_path).readlines()]

setup(
    name='ta_kiss_iphy',
    version='1.3.11',
    description='ta_kiss_iphy',
    author='Leo Wang',
    author_email='leo.y.wang@nokia.com',
    maintainer='Yonna Yao',
    maintainer_email='yonna.yao@nokia-sbell.com',
    packages=find_packages(exclude=['test']),
    package_data={'': ['ta_kiss_iphy/luafiles']},
    include_package_data=True,
    install_requires=requirements,
    python_requires='>=2.7.15,!=3.0.*,!=3.1.*,!=3.2.*,!=3.3.*,!=3.4.*,!=3.5.*,<4.0.0'
)
