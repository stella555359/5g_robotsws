# -*- coding: utf-8 -*
import sys
import os
import shutil
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem


def import_testline_variable(tl_name, exec_path):
    sys.path.append(exec_path)

    init_file_path = os.path.join(exec_path, "testline_configuration", tl_name, "__init__.py")
    tmp_testline_dir = os.path.join(exec_path, "testline_configuration", "tmp_testline")
    ret = OperatingSystem().run("git -C ~/Projects/mmw1_config/ pull")
    BuiltIn().log_to_console("git pull results:%s" % ret)

    if os.path.isdir(tmp_testline_dir):
        shutil.rmtree(tmp_testline_dir, True)

    if not os.path.exists(tmp_testline_dir):
        os.makedirs(tmp_testline_dir)

    shutil.copy(init_file_path, tmp_testline_dir)

    if sys.modules.get("testline_configuration.tmp_testline.__init__") is not None:
        del sys.modules["testline_configuration.tmp_testline.__init__"]
    from testline_configuration.tmp_testline.__init__ import tl

    return tl

# if __name__ == '__main__':
#     tl1= import_testline_variable("7_5_UTE402T256", "/home/ute/Projects")
#     print(tl1.test_pc.default_ssh_connection_details.addr)
#
#     tl2 = import_testline_variable("7_5_UTE402T246", "/home/ute/Projects")
#     print(tl2.test_pc.default_ssh_connection_details.addr)
