from taf.transport.ssh import ssh
import os
import logging
import re

SERVER_IP = "10.66.11.28"
SERVER_USERNAME = "scpadm"
SERVER_PASSWORD = "M%ACTfVV&U!k3qqL#1r4"
LOCAL_SW_BUILD_ROOT_PATH = "/home/ute/pkgload"
LOAD_SERVER_BUILD_PATH = "/home/scpadm/SPACE/COMMON/Loads/ASIR5G/"
LOAD_SERVER_BUILD_PATH_COMMON_LOAD = "/home/scpadm/SPACE/COMMON/Loads/ASIR/"
LOAD_SERVER_YAFT_PATH = "/home/scpadm/SPACE/COMMON/tools/"
LOAD_SERVER_FACTORY_PATH = "/home/scpadm/SPACE/COMMON/Loads/ASIR5G/Factory_Load"
LOACAL_YAFT_DIR = "/home/ute/yaft"

csn = ssh()


def download_sw_build_from_loadserver(build_version):

    loaddir_local = os.path.join(LOCAL_SW_BUILD_ROOT_PATH, build_version)

    if '5G' in build_version:
        rel_version_list = build_version.split("_")
        version_id = rel_version_list[1]
        loaddir_remote = os.path.join(LOAD_SERVER_BUILD_PATH, "{}".format(build_version))
        loadpkg_remote = os.path.join(loaddir_remote, "AirScale-{}.zip".format(version_id))
        loadpkg_local = os.path.join(loaddir_local, "AirScale-{}.zip".format(version_id))
    else:
        loaddir_remote = os.path.join(LOAD_SERVER_BUILD_PATH_COMMON_LOAD, "{}".format(build_version))
        loadpkg_remote = os.path.join(loaddir_remote, "{}_release_BTSSM_downloadable_A54.zip".format(build_version))
        loadpkg_local = os.path.join(loaddir_local, "{}_release_BTSSM_downloadable_A54.zip".format(build_version))

    if os.path.exists(loadpkg_local):
        return loadpkg_local
    elif not os.path.exists(LOCAL_SW_BUILD_ROOT_PATH):
        os.system(
            "cd /home/ute; mkdir pkgload; cd pkgload; mkdir {}".format(build_version)
        )
    elif not os.path.exists(loaddir_local):
        os.system("cd {}; mkdir {}".format(LOCAL_SW_BUILD_ROOT_PATH, build_version))

    csn.connect_to(SERVER_IP, SERVER_USERNAME, SERVER_PASSWORD, alias="download")
    logging.info("Start Download SW Build From Load Server {}".format(SERVER_IP))
    if csn.file_exists(loadpkg_remote, connection="download"):
        csn.download_file(loadpkg_remote, loadpkg_local, connection="download")
    csn.disconnect(connection="download")
    logging.info("Download SW Build Finished")
    if not os.path.exists(loadpkg_local):
        raise Exception(
            "Download failed or there is no {} in load server".format(loadpkg_remote)
        )
    else:
        return loadpkg_local


def download_package_from_load_server(filename, localpath, remotepath):
    """
    Download package from load server
    :param filename: target filename
    :param localpath: local file path for example /home/ute/file.txt
    :param remotepath: remote file path for example /tmp/file.txt
    :return NO return
    """
    logging.info("Download {} Package From Load Server {}".format(filename, SERVER_IP))

    csn.connect_to(SERVER_IP, SERVER_USERNAME, SERVER_PASSWORD, alias="download")
    if csn.file_exists(remotepath, connection="download"):
        csn.download_file(remotepath, localpath, connection="download")
    else:
        raise Exception("There is no {} in Load Server {}".format(filename, SERVER_IP))
    csn.disconnect(connection="download")


def run_cmd_on_ute(cmd):
    if os.system(cmd) == 0:
        logging.info("Cmd: {} success".format(cmd))
        return True
    else:
        raise Exception("Run cmd: {} failed".format(cmd))


def download_factory_file_from_load_server(filename):
    """
    Download factory from load server
    :param filename: target filename
    :return factory_dir_local: local file path for example /home/ute/file.txt
    """
    factory_dir_remote = os.path.join(LOAD_SERVER_FACTORY_PATH, filename)
    factory_dir_local = os.path.join(LOCAL_SW_BUILD_ROOT_PATH, filename)

    if os.path.exists(factory_dir_local):
        return factory_dir_local
    elif not os.path.exists(LOCAL_SW_BUILD_ROOT_PATH):
        run_cmd_on_ute("cd /home/ute; mkdir pkgload")
    download_package_from_load_server(filename, factory_dir_local, factory_dir_remote)
    return factory_dir_local


def checkout_yaft_from_svn():
    """
    Download yaft from svn
    :return os.path.join(yaft_dir_local, 'yaft.py'): path of yaft.py
    """
    yaft_svn_path = "https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk"

    logging.info("Checkout Yaft From SVN {}".format(yaft_svn_path))

    run_cmd_on_ute("rm -rf {0} && mkdir -p {0}".format(LOACAL_YAFT_DIR))
    cmd = (
        "svn checkout --username ca_ute_test --password utetest --ignore-externals "
        "{} {}".format(yaft_svn_path, LOACAL_YAFT_DIR)
    )

    if run_cmd_on_ute(cmd) is True:
        return os.path.join(LOACAL_YAFT_DIR, "yaft.py")


if __name__ == "__main__":
    download_sw_build_from_loadserver("5G21A_11.800.313")
    # download_unzip_yaft_from_load_server('newest_yaft.tar.gz')
    # download_factory_file_from_load_server('LN_WN_FDSW19A_0000_000143_000000_release_BTSSM_downloadable.zip')
    # download_factory_file_from_load_server('FDSW_clear')
    # checkout_yaft_from_svn()
