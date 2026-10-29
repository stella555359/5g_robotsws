import os
import sys
import string
import linux_cmds as linux

# sys.path modification not allowed by pipeline !!!!
# # from luashark_tools import analyzer
# from resources.python_libs.luashark_tools import analyzer
# sys.path.append("{}/../../../../../../resources/python_libs/".format(os.path.dirname(os.path.realpath(__file__))))

# relative import depends on the current location as well as the location of the module, package,
# or object to be imported
# A single dot means that the module or package referenced is in the same directory as the current location.
# Two dots mean that it is in the parent directory of the current location. that is, the directory above.
# Three dots mean that it is in the grandparent directory, and so on.
# does not work when executing robot !!!
# from ........resources.python_libs.luashark_tools import analyzer

import luashark_tools as analyzer

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


rbi = BuiltIn()


def initiate_luashark_analyzer(af_path, name):
    # return analyzer(af_path=af_path)
    lua_analyzer = analyzer.analyzer(af_path=af_path)
    lua_analyzer.setLuasharkScriptName(name=name)
    isUTE = rbi.get_variable_value("${TLConfig.isUTE}")
    if not isUTE:
        lua_analyzer.do_install_analyzer()
    return lua_analyzer
#     return analyzer.analyzer(af_path=af_path)


def get_sw_package(sw_version):
    """
    Get software version
    E.g. input: '5G19A_FSMK_0006_038451_000299', '5G20A_GNB_0009_001800_000330'
    :param sw_version: 5G19A_FSMK_0006_038451_000299 , 5G20A_GNB_0009_001800_000330
    :type sw_version: str
    :return: Software version
        E.g. output:'6.28351.123', '9.1800.330'
    :rtype: str
    """
    sw_package = [i.lstrip('0') for i in sw_version.split('_')]

    if sw_package is not None:
        if sw_package[-3] == '':
            sw_package[-3] = '0'
        return '.'.join(sw_package[-3:])
    return sw_package


# to manage sw knife like 5G20A_GNB_0009_001800_000744_182cc_  ;  5G20A_GNB_0009_001800_000668_0ilsj_
def get_sw_package_version(sw_version):
    """
    Get software version
    E.g. input: '5G19A_FSMK_0006_038451_000299', '5G20A_GNB_0009_001800_000330' , '5G20A_GNB_0009_001800_000744_182cc_'
    :param sw_version: 5G19A_FSMK_0006_038451_000299 , 5G20A_GNB_0009_001800_000330 ,
    5G20A_GNB_0009_001800_000744_182cc_
    :type sw_version: str
    :return: Software version
        E.g. output:'6.28351.123',  , '9.1800.744'
    :rtype: str
    """
    sw_package = [i.lstrip('0') for i in sw_version.split('_')]
    # linux.info("sw_package:sw_package={}".format(sw_package))
    # linux.info("sw_package:sw_package={}".format(sw_package[:5]))
    sw_package_2 = sw_package[:5]
    if sw_package_2 is not None:
        if sw_package_2[-3] == '':
            sw_package_2[-3] = '0'
        return '.'.join(sw_package_2[-3:])
    return sw_package_2
