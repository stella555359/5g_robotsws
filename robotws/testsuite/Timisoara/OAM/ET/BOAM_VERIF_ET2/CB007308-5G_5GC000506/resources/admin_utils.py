from sw_info import SWBuildParsing
from robot.api import logger


def get_package_name_from_soft_name(sw_name):
    parser = SWBuildParsing(sw_name)
    return parser.get_sw_package_name()


def get_sw_file_name(sw_version, smod_type, bbmod_type, is_package_with_suffix):
    name = "AirScale-{}.zip".format(sw_version)
    if is_package_with_suffix or ("800." in sw_version):
        name = "AirScale-{}_{}_{}.zip".format(sw_version, smod_type, bbmod_type)
    return name


def new_get_sw_file_name(sw_version, is_package_with_suffix):
    name = "AirScale-{}.zip".format(sw_version)
    if is_package_with_suffix or ("800." in sw_version):
        name = "AirScale-{}.zip".format(sw_version)
    return name


def get_sw_file_name_corrupted(sw_version, smod_type, bbmod_type, is_package_with_suffix):
    name = "AirScale-{}.corrupted.zip".format(sw_version)
    if is_package_with_suffix or ("800." in sw_version):
        name = "AirScale-{}_{}_{}.corrupted.zip".format(sw_version, smod_type, bbmod_type)
    return name


def new_get_sw_file_name_corrupted(sw_version, is_package_with_suffix):
    name = "AirScale-{}.corrupted.zip".format(sw_version)
    if is_package_with_suffix or ("800." in sw_version):
        name = "AirScale-{}.corrupted.zip".format(sw_version)
    return name


def get_variant(bts_data, module):
    modules = {'SMOD': 'systemModules', 'BBMOD': 'basebandModules'}
    product_name = bts_data[str(modules[module])][0]['productName']
    return product_name.split()[0]
