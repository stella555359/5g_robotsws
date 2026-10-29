# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_MN_RAN_L2_SW_3_CN_SG9_TA_GMS
:contact: i_mn_ran_l2_sw_3_cn_sg9_ta@internal.nsn.com
"""
import os
from setuptools import setup, find_packages

req_path = os.path.join(os.getcwd(), 'requirements', 'base.txt')
requirements = [line.strip() for line in open(req_path).readlines()]

setup(
    name='ta_kiss_bts',
    version='1.5.1',
    description='ta_kiss_bts library',
    author='Lily Xu',
    author_email='lily.l.xu@nokia-sbell.com',
    maintainer='I_MN_RAN_L2_SW_3_CN_SG9_TA_GMS',
    maintainer_email='i_mn_ran_l2_sw_3_cn_sg9_ta@internal.nsn.com',
    scripts=[],
    packages=find_packages(exclude=['test']),
    package_data={'': ['ta_kiss_bts/resources']},
    include_package_data=True,
    install_requires=requirements,
    python_requires='>=2.7.15,!=3.0.*,!=3.1.*,!=3.2.*,!=3.3.*,!=3.4.*,!=3.5.*,<4.0.0'
)
