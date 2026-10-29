# -*- coding: utf-8 -*-
"""
ta_kiss_config library

:copyright: Nokia
:author: leo wang
:contact: leo.y.wang@nokia.com
"""
import os
from setuptools import setup, find_packages

req_path = os.path.join(os.getcwd(), 'requirements', 'base.txt')
requirements = [line.strip() for line in open(req_path).readlines()]

setup(
    name='ta_kiss_config',
    version='1.3.2',
    description='ta_kiss_config',
    author='leo wang',
    author_email='leo.y.wang@nokia.com',
    maintainer='I_MN_RAN_L2_SW_3_CN_SG9_TA_GMS',
    maintainer_email='i_mn_ran_l2_sw_3_cn_sg9_ta@internal.nsn.com',
    packages=find_packages(exclude=['test']),
    install_requires=requirements,
    python_requires='>=2.7.15,!=3.0.*,!=3.1.*,!=3.2.*,!=3.3.*,!=3.4.*,!=3.5.*,<4.0.0'
)
