'''
    author: Wang Cuicui
    contact: cuicui.wang@nokia-sbell.com
    Purpose: This file is a WA to replace local resource
'''

import os
import shutil
from robot.libraries.BuiltIn import BuiltIn

resource_git_url = 'https://gitlabe2.ext.net.nokia.com/ca_MF_ST/robotws5g_nj.git'

buildin_obj = BuiltIn()
# buildin_obj.log("flag = %s"%buildin_obj.get_variable_value('${FLAG}'), console=True)

dst_dir = os.path.join('/home/ute', 'robotws5g_nj')
if os.path.exists(dst_dir):
    shutil.rmtree(dst_dir, ignore_errors=True)

if buildin_obj.get_variable_value('${FLAG}') is None or buildin_obj.get_variable_value('${FLAG}') == 'True':
    try:
        os.system('cd /home/ute; /opt/ute/python/bin/pip install ta_xml')
        os.system('cd /home/ute; /home/ute/test_repo/bin/pip install ta_xml')
        os.system('cd /home/ute; git clone {}'.format(resource_git_url))
        os.system('cp -rf /home/ute/robotws5g_nj/Resources2 /home/ute/robotws5g/testsuite/OAM/Nanjing/')
        os.system('cp -rf /home/ute/robotws5g_nj/Resources/robot/DevNJ_resource.robot \
        /home/ute/robotws5g/testsuite/OAM/Nanjing/Resources/robot/')
        os.system('cp -rf /home/ute/robotws5g_nj/Resources2 /home/ute/Auto5G/testsuite/OAM/Nanjing/')
        os.system('cp -rf /home/ute/robotws5g_nj/Resources/robot/DevNJ_resource.robot \
        /home/ute/Auto5G/testsuite/OAM/Nanjing/Resources/robot/')
    except IOError:
        raise Exception('Resource replace failed.')
