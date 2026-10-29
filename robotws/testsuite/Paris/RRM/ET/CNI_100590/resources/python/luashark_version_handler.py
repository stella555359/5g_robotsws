import string
import requests
import os
import sys

import linux_cmds as linux

from robot.libraries.BuiltIn import BuiltIn


def create_luashark_package_url(sw_version):
    artifactory_address = \
        'https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release'
    luashark_url = '{}/{}/luashark-{}.zip'.format(artifactory_address, sw_version, sw_version)
    return luashark_url

# https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/


def create_luashark_package_url_sbts(sw_version):
    artifactory_address = \
        'https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/'
    luashark_url = '{}/{}_luashark.zip'.format(artifactory_address, sw_version)
    return luashark_url

# https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210331_000004_luashark.zip


def decrease_sw_version_by(sw_version, i):
    split_sw_version = sw_version.split(".")
    last_index_split_sw_version = len(split_sw_version) - 1
    if int(split_sw_version[last_index_split_sw_version]) > 0:
        split_sw_version[last_index_split_sw_version] = str(int(split_sw_version[last_index_split_sw_version]) - 1)
    decreased_sw_version = '.'.join(split_sw_version)
    return decreased_sw_version


def check_package_availability_on_server(package_url):
    url = package_url
    r = requests.head(url)
    return r.status_code == 200


def set_robot_suite_variable(param_name, param_value):
    """
    Set Robot Builtin variable.
    :param param_name: variable name
    :param param_value: value
    """
    BuiltIn().set_suite_variable('${{{}}}'.format(param_name), param_value)


def try_to_find_available_package_on_server(sw_version, version_amount_to_check):
    luashark_found = False
    sw_version_to_check = sw_version
    package_url = ""
    version_amount = int(version_amount_to_check) + 1
    for i in range(1, version_amount):
        sw_version_to_check = decrease_sw_version_by(sw_version_to_check, i)
        package_url = create_luashark_package_url(sw_version_to_check)
        luashark_found = check_package_availability_on_server(package_url)
        if luashark_found is True:
            set_robot_suite_variable(param_name='current_sw_version_for_lua_gNB', param_value=sw_version_to_check)
            break
        package_url = ""
    return package_url


def get_root_path():
    """
    computing root path where to deploy Luashark
    Strategy is :
        if /home/<user> exists, it will be root path
        otherwise, retrieve TEMP_PATH robot variable as root path
    """
    root = "/home/{}".format(linux.get_user())
    if os.path.isdir(root):
        return root
    output_dir = BuiltIn().get_variable_value("${TEMP_PATH}")
    assert output_dir is not None, \
        "${TEMP_PATH} robot variable was not set in robot context"
    return output_dir


def is_luashark_installed(luashark_path, luashark_script, version):
    """
    Check if luashark is installed for this version
    Also check if luashark.lua script is present inside
    """
    # First check if path to luashark exists
    prefix = "{} for {}".format("luashark", version)
    if not os.path.isdir(luashark_path):
        linux.info("{} not installed".format(prefix))
        return False
    # Also verify if luashark/lua script exists inside it
    assert os.path.exists(luashark_script), \
        "Path for luashark {} exists, but not {} script."\
        .format(luashark_path, "luashark.lua")
    # Luashark now properly installed
    linux.info("{} already installed in {}".format(prefix, luashark_script))
    return True


def install_luashark(luashark_root, luashark_ref, luashark_script, luashark_path):
    """
    Install luashark in :
    /home/<user>/tools/luashark/generated_luashark-<version>
    """

    user = linux.get_user()
    tmp_file = "/tmp/analyzer_{}.tmp".format(user)

    try:
        # Create root path to Luashark in case it does not exist
        linux.execute("mkdir -p {}".format(luashark_root))

        # Remove temporary zip file if exists
        targetZipFile = "{}/{}"\
            .format(luashark_root, "TMP_LUASHARK.zip")

        linux.rm_if_exist(targetZipFile)

        # Launch cp command to cp luashark-<version>.zip
        # into targetZipFile
        linux.execute("cp {} {} ".format(luashark_ref, targetZipFile))

        # Unzip downloaded zip file and rename it with version as suffix
        linux.unzip_file(targetZipFile, luashark_root)

        linux.info("targetZipFile={}".format(targetZipFile))
        linux.info("luashark_root={}".format(luashark_root))
        linux.info("luashark_script={}".format(luashark_script))
        linux.info("luashark_path={}".format(luashark_path))

        luashark_msg_ids_raw = "{}/{}".format(luashark_path, "msg_ids_raw.csv")

        assert os.path.exists(luashark_script), "Unable to find {} in {}".format("luashark.lua", luashark_path)
        assert os.path.exists(luashark_msg_ids_raw), "Unable to find {} in {}".format("msg_ids_raw.csv", luashark_path)
        installed = True

    finally:
        os.remove(targetZipFile)
        linux.info("remove targetZipFile={}".format(targetZipFile))


def do_install_Xp_Analyzer(af_path):
    """
    Compute all analyzer attributes (paths, version,...)
    and install dedicated luashark  if required
    """

    luashark_ref = af_path
    # "generated_luashark-9.1800.330.zip"
    linux.info("luashark_ref={}".format(luashark_ref))

    # From AF_PATH, we extract last two directories
    twords = af_path.split('/')

    linux.info("twords={}".format(twords))
    # Version is second previous field
    version = twords[-2]
    linux.info("version={}".format(version))

    # Building path to Luashark, path to Luashark.lua script
    root = get_root_path()
    luashark_root = "{}/tools/{}"\
        .format(root, "luashark")
    luashark_path = "{}/{}-{}"\
        .format(luashark_root, "generated_luashark", version)
    luashark_script = "{}/{}"\
        .format(luashark_path, "luashark.lua")
    linux.info("version={} luashark_path={}"
               .format(version, luashark_path))
    # Install Luashark if required
    if not is_luashark_installed(luashark_path, luashark_script, version):
        install_luashark(luashark_root, luashark_ref, luashark_script, luashark_path)


def return_path_to_lua_Analyzer(af_path):
    """
    Compute all analyzer attributes (paths, version,...)
    and install dedicated luashark  if required
    """

    luashark_ref = af_path
    # "generated_luashark-9.1800.330.zip"
    linux.info("luashark_ref={}".format(luashark_ref))

    # From AF_PATH, we extract last two directories
    twords = af_path.split('/')

    linux.info("twords={}".format(twords))
    # Version is second previous field
    version = twords[0]
    linux.info("version={}".format(version))

    # Building path to Luashark, path to Luashark.lua script
    root = get_root_path()
    luashark_root = "{}/tools/{}"\
        .format(root, "luashark")
    luashark_path = "{}/{}-{}"\
        .format(luashark_root, "generated_luashark", version)
    luashark_script = "{}/{}"\
        .format(luashark_path, "luashark.lua")
    linux.info("version={} luashark_path={}"
               .format(version, luashark_path))
    return luashark_path


def isUTE():
    build = BuiltIn().get_variable_value("${ENB_BUILD}")
    return build is not None and len(build) > 0


def return_full_path_to_lua_Analyzer_script(af_path):
    isTLUTE = isUTE()
    linux.info("isTLUTE={}".format(isTLUTE))
    if not isTLUTE:
        return return_full_path_to_lua_Analyzer_script_NoneUte(af_path)
    else:
        return return_full_path_to_lua_Analyzer_script_Ute(af_path)


def return_full_path_to_lua_Analyzer_script_Ute(af_path):
    luashark_path = "/opt/luashark/generated_luashark"
    luashark_script = "{}/{}" \
        .format(luashark_path, "luashark.lua")
    linux.info("luashark_script={}".format(luashark_script))
    return luashark_script


def return_full_path_to_lua_Analyzer_script_NoneUte(af_path):
    """
    Compute all analyzer attributes (paths, version,...)
    and install dedicated luashark  if required
    """

    luashark_ref = af_path
    # "generated_luashark-9.1800.330.zip"
    linux.info("luashark_ref={}".format(luashark_ref))

    # From AF_PATH, we extract last two directories
    twords = af_path.split('/')

    linux.info("twords={}".format(twords))
    # Version is second previous field
    version = twords[6]
    linux.info("version={}".format(version))

    # Building path to Luashark, path to Luashark.lua script
    root = get_root_path()
    luashark_root = "{}/tools/{}"\
        .format(root, "luashark")
    luashark_path = "{}/{}-{}"\
        .format(luashark_root, "generated_luashark", version)
    luashark_script = "{}/{}"\
        .format(luashark_path, "luashark.lua")
    linux.info("version={} luashark_path={}"
               .format(version, luashark_path))
    return luashark_script
    # return luashark_path


def is_lua_Analyzer_installed(af_path):
    """
    Compute all analyzer attributes (paths, version,...)
    and install dedicated luashark  if required
    """

    luashark_ref = af_path
    # "generated_luashark-9.1800.330.zip"
    linux.info("luashark_ref={}".format(luashark_ref))

    # From AF_PATH, we extract last two directories
    twords = af_path.split('/')

    linux.info("twords={}".format(twords))
    # Version is second previous field
    version = twords[0]
    linux.info("version={}".format(version))

    # Building path to Luashark, path to Luashark.lua script
    root = get_root_path()
    luashark_root = "{}/tools/{}"\
        .format(root, "luashark")
    luashark_path = "{}/{}-{}"\
        .format(luashark_root, "generated_luashark", version)
    luashark_script = "{}/{}"\
        .format(luashark_path, "luashark.lua")
    linux.info("version={} luashark_path={}"
               .format(version, luashark_path))
    # Install Luashark if required
    return is_luashark_installed(luashark_path, luashark_script, version)
