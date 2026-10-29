import os
import re
import sys
import time
import importlib
import subprocess

from robot.api.deco import keyword
from moler.util.moler_test import MolerTest
from taf.gnb.oam.coam.admin import admin

from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_asicli import (
    prepare_asi_cli_env_for_enb,
)
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_download_build_from_LS import (
    download_package_from_load_server,
    LOACAL_YAFT_DIR,
    checkout_yaft_from_svn,
)
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_get_tl_configuration import (
    get_full_commission_dir,
)
from testsuite.Krakow.resources.NJ_Resources.Resources.python.wft import (
    get_asicli_version,
)


@MolerTest.raise_background_exceptions()
def waiting_for_site_response(rerun=120, ip_addr="192.168.255.129"):
    """
    Wait for ssh open
    """
    return wait_device_portopen(ip_addr, 22, rerun, 5)


@MolerTest.raise_background_exceptions()
def check_if_enb_is_onair(dist_name=None, ip_addr="192.168.255.129"):
    """
    Check if gNB operationalStatus is onAir.

    :param ip_addr: IP address of gNB
    :param dist_name: parameter group name where operationalState can be found
    :return: True if gNB is onAir, False otherwise
    """
    api = admin()
    connection = None
    result = False
    try:
        connection = api.connect_to(bts_host=ip_addr)
        status_dict = connection.get_bts_statuses(timeout=120)
        operational_state = status_dict["proceduralState"]

        result = re.match(r"onAir", operational_state, re.I) is not None
    except Exception as e:
        MolerTest.error(
            "There is an requests exception in check_if_enb_is_onair: {}".format(
                repr(e)
            )
        )
    finally:
        if connection:
            api.teardown(connection=connection)

    return result


@MolerTest.raise_background_exceptions()
def wait_for_onair(
    dist_name=None,
    timeout=930,
    interval=30,
    raise_error=True,
    ip_addr="192.168.255.129",
):
    """
    Wait until gNB gets on air or timeout expire.

    :param dist_name: parameter group name where operationalState can be found
    :param timeout: time in seconds, after timeout expires an exception is raised
    :param interval: time between checks of operationalState
    :param raise_error: True if moler error should be raised when gNB is not onAir, False otherwise
    :param ip_addr: IP address of gNB
    :return: None
    """
    start_time = time.time()

    while time.time() - start_time <= timeout:
        if check_if_enb_is_onair(dist_name, ip_addr):
            MolerTest.info("eNB is on air")
            return True
        else:
            MolerTest.sleep(interval)

    if raise_error:
        MolerTest.error("eNB is not on air")
    return False


@MolerTest.raise_background_exceptions()
def run_cmd(cmd):
    p = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        universal_newlines=True,
    )
    stdout = []
    while True:
        line = p.stdout.readline()
        stdout.append(line)
        MolerTest.info(line)

        # poll has a bug: http://bbs.chinaunix.net/thread-3775926-1-1.html
        if line == "" and p.poll() is not None:
            break

    return "".join(stdout)


@MolerTest.raise_background_exceptions()
def get_tl_enb_latest_load(git_full_scf, testline, current_build):
    """
    Based on the specified build version, list all builds with the same version as it.
    @param git_full_scf  returned by function get_full_commission_dir
    @param testline      testline, e.g. 7_21_CLOUD006TL006
    @param current_build current build, e.g. SBTS21A_ENB_0000_000185_000000
    """
    dir_list = []
    loads = {}

    if not testline.startswith("7_21_"):
        # ignore TL type directories
        return None

    actual_dir = os.path.join(git_full_scf, testline)
    branch = current_build.split("_")[0]
    for item in os.listdir(actual_dir):
        if not item.startswith(branch):
            continue

        for file_name in os.listdir(os.path.join(actual_dir, item)):
            if file_name.endswith("_enb.xml"):
                dir_list.append(item)

    if len(dir_list) != 0:
        MolerTest.info(dir_list)
        for item in dir_list:
            if enb_newer_version(item, current_build) or enb_same_version(
                item, current_build
            ):
                MolerTest.info("coming version:", item)
                parts = item.split("_")
                version = int("{}{}".format(int(parts[-2]), int(parts[-1])))
                loads[version] = item

        if len(loads) != 0:
            latest_version = max(loads.keys())
            MolerTest.info("latest version:", loads[latest_version])
            return loads[latest_version]

    return None


@MolerTest.raise_background_exceptions()
def enb_newer_version(load1, load2):
    load1_parts = load1.split("_")
    load2_parts = load2.split("_")

    return load1_parts[0] == load2_parts[0] and (
        int(load1_parts[-2]) > int(load2_parts[-2])
        or (
            int(load1_parts[-2]) == int(load2_parts[-2])
            and int(load1_parts[-1]) > int(load2_parts[-1])
        )
    )


@MolerTest.raise_background_exceptions()
def enb_same_version(load1, load2):
    return load1 == load2


@MolerTest.raise_background_exceptions()
def load_tl_cfg(testline):
    tl_cfg_5g = "/home/ute/testline_configuration"
    tl_file = os.path.join(tl_cfg_5g, testline, "__init__.py")
    if not os.path.exists(tl_file):
        MolerTest.info("{} not found".format(tl_file))
        raise FileNotFoundError

    sys.path.append(tl_cfg_5g)
    try:
        tl_module = importlib.import_module(testline)
    finally:
        sys.path.pop()

    return tl_module.tl


@MolerTest.raise_background_exceptions()
def get_enb_current_build_version_from_bbu(bts_host="192.168.255.129"):
    api = admin()
    connection = api.connect_to(bts_host=bts_host)
    version = api.get_sw_version(timeout=30, connection=connection)
    api.teardown(connection=connection)
    return version


@MolerTest.raise_background_exceptions()
def download_enb_package_from_load_server(
    build_version, local_package_dir, remote_package_dir
):
    build_package = "{}_release_BTSSM_downloadable_A50.zip".format(build_version)
    build_package_dir = "{}/{}".format(local_package_dir, build_version)
    if not os.path.exists(build_package_dir):
        os.mkdir(build_package_dir)

    local_package = "{}/{}".format(build_package_dir, build_package)
    remote_package = "{}/{}/{}".format(remote_package_dir, build_version, build_package)

    download_package_from_load_server(build_package, local_package, remote_package)
    if not os.path.exists(local_package):
        return None

    return local_package


@MolerTest.raise_background_exceptions()
def download_enb_asicli_package_from_load_server(
    build_version, local_package_dir, remote_package_dir
):
    asicli_version = get_asicli_version(build_version)
    if asicli_version is None:
        return None

    if not os.path.exists(local_package_dir):
        os.mkdir(local_package_dir)

    local_package = "{}/asi-cli.tgz".format(local_package_dir, "asi-cli.tgz")
    remote_package = "{}/{}/asi-cli.tgz".format(remote_package_dir, asicli_version)

    download_package_from_load_server(asicli_version, local_package, remote_package)
    if not os.path.exists(local_package):
        return None

    return local_package


@MolerTest.raise_background_exceptions()
def prepare_yaft_package():
    yaft = "{}/yaft.py".format(LOACAL_YAFT_DIR)
    if os.path.exists(yaft):
        return yaft

    return checkout_yaft_from_svn()


@MolerTest.raise_background_exceptions()
def install_enb_via_yaft(yaft_path, build_package):
    params = "--NO_lockfile --ignore_FSPs --ask_for_password --clean_to_default"
    cmd = "echo oZPS0POrRieRtu | python {} --ip {} {} -z {}".format(
        yaft_path, "192.168.255.129", params, build_package
    )
    return run_cmd(cmd)


@MolerTest.raise_background_exceptions()
def get_bts_info(bts_host="192.168.255.129"):
    api = admin()
    connection = api.connect_to(bts_host=bts_host)
    bts_info = api.get_bts_info(connection=connection)
    api.teardown(connection=connection)
    MolerTest.info(bts_info)
    return bts_info


@MolerTest.raise_background_exceptions()
def get_component_info(bts_info, component):
    if component == "radioModules":
        return bts_info["radioModules"]["asirmod"]

    return bts_info[component]


@MolerTest.raise_background_exceptions()
def get_enb_commission_from_git(build_version, testline_name):
    commission_dir = get_full_commission_dir()
    commission = "{0}/{1}/{2}/{1}_enb.xml".format(
        commission_dir,
        testline_name,
        build_version,
    )
    return commission


@MolerTest.raise_background_exceptions()
def get_enb_asir_commission_from_git(build_version, testline_name):
    commission_dir = get_full_commission_dir()
    commission = "{0}/{1}/{2}/{1}_enb_asirmgr.xml".format(
        commission_dir,
        testline_name,
        build_version,
    )
    return commission


@MolerTest.raise_background_exceptions()
def perform_enb_commissioning(scf_file, bts_host="192.168.255.129"):
    api = admin()
    connection = api.connect_to(bts_host=bts_host)
    # status: Commissioning status (completed, ongoing or failed)
    status = api.perform_commissioning(scf_file, connection=connection)
    api.teardown(connection=connection)
    return status


@MolerTest.raise_background_exceptions()
def perform_asir_commission_fullfile(scf_file, asicli_dir, bts_host="192.168.255.129"):
    cmd = (
        '{}/scripts/commission.sh -ne {} -pw Nemuadmin:nemuuser -fullfile "{}"'.format(
            asicli_dir, bts_host, scf_file
        )
    )
    return run_cmd(cmd)


@MolerTest.raise_background_exceptions()
def coam_admin_check_units_status_normal(component, ip_address="192.168.255.129"):
    try:
        bts_info = get_bts_info(ip_address)
        info = get_component_info(bts_info, component)
        for element in info:
            status = element["status"]["availabilityStatus"]
            if status == "Online":
                return True
    except Exception as e:
        MolerTest.error("exception raised in check_units_status", e)

    return False


def wait_device_portopen(host, port, times, peroid):
    i = 0
    while i < times:
        i += 1
        output = run_cmd("nmap -Pn -open {} -p {}".format(host, str(port)))
        if "open" in output:
            MolerTest.info("{} port {} is opened.".format(host, port))
            return True
        time.sleep(peroid)

    MolerTest.info("{} port {} is closed.".format(host, port))
    return False


@MolerTest.raise_background_exceptions()
def sw_upgrade(pkg_file, bts_host="192.168.255.129"):
    api = admin()
    connection = api.connect_to(bts_host=bts_host)
    result = api.update_software(
        sw_package=pkg_file, timeout=3600, connection=connection
    )
    api.teardown(connection=connection)

    # result: Status of the operation. Possible statuses: 'Accepted' or 'Failed'
    MolerTest.info("sw_upgrade result: {}".format(result))
    return result


class EnbRpcLibrary(object):
    """EnbRpcLibrary library to be used with Robot Framework's remote server."""

    def get_keyword_names(self):
        # Get all attributes and their values from the library.
        attributes = [(name, getattr(self, name)) for name in dir(self)]
        # Filter out attributes that do not have 'robot_name' set.
        keywords = [
            (name, value) for name, value in attributes if hasattr(value, "robot_name")
        ]
        # Return value of 'robot_name', if given, or the original 'name'.
        return [value.robot_name or name for name, value in keywords]

    @keyword
    def get_tl_enb_latest_load(self, git_full_scf, testline, current_build):
        """
        Based on the specified build version, list all builds with the same version as it.
        @param git_full_scf  returned by function get_full_commission_dir
        @param testline      testline, e.g. 7_21_CLOUD006TL006
        @param current_build current build, e.g. SBTS21A_ENB_0000_000185_000000
        """
        return get_tl_enb_latest_load(git_full_scf, testline, current_build)

    @keyword
    def get_enb_current_build_version_from_bbu(self, bts_host="192.168.255.129"):
        return get_enb_current_build_version_from_bbu(bts_host=bts_host)

    @keyword
    def get_enb_latest_build_version_from_git(self, testline_name, build_version):
        commission_dir = get_full_commission_dir()
        return get_tl_enb_latest_load(commission_dir, testline_name, build_version)

    @keyword
    def download_enb_package_from_load_server(
        self, build_version, local_package_dir, remote_package_dir
    ):
        return download_enb_package_from_load_server(
            build_version, local_package_dir, remote_package_dir
        )

    @keyword
    def download_enb_asicli_package_from_load_server(
        self, build_version, local_package_dir, remote_package_dir
    ):
        return download_enb_asicli_package_from_load_server(
            build_version, local_package_dir, remote_package_dir
        )

    @keyword
    def prepare_asi_cli_env_for_enb(self, local_asicli_file, dest_asicli_dir):
        prepare_asi_cli_env_for_enb(local_asicli_file, dest_asicli_dir)
        return "success"

    @keyword
    def prepare_yaft_package(self):
        return prepare_yaft_package()

    @keyword
    def install_enb_via_yaft(self, yaft_path, build_package):
        return install_enb_via_yaft(yaft_path, build_package)

    @keyword
    def waiting_for_site_response(self, ip_address="192.168.255.129"):
        success = waiting_for_site_response(ip_address)
        if success:
            return "connected"

        MolerTest.error("failed to wait site response")

    @keyword
    def coam_admin_check_units_status_normal(
        self, component, ip_address="192.168.255.129"
    ):
        success = coam_admin_check_units_status_normal(component, ip_address=ip_address)
        if success:
            return "online"

        MolerTest.error("check units status: abnormal")

    @keyword
    def sw_upgrade(self, pkg_file, bts_host="192.168.255.129"):
        # result: Status of the operation. Possible statuses: 'Accepted' or 'Failed'
        result = sw_upgrade(pkg_file, bts_host)
        if "failed" in result.lower():
            MolerTest.error("sw_upgrade failed", raise_exception=True)

        return result

    @keyword
    def get_enb_commission_from_git(self, build_version, testline_name):
        return get_enb_commission_from_git(build_version, testline_name)

    @keyword
    def get_enb_asir_commission_from_git(self, build_version, testline_name):
        return get_enb_asir_commission_from_git(build_version, testline_name)

    @keyword
    def perform_enb_commissioning(self, scf_file, bts_host="192.168.255.129"):
        status = perform_enb_commissioning(scf_file, bts_host=bts_host)
        if status == "failed":
            MolerTest.error("failed to perform enb commission", raise_exception=True)

        MolerTest.info("perform enb commission: {}".format(status))
        return "success"

    @keyword
    def perform_asir_commission_fullfile(
        self, scf_file, asicli_dir, bts_host="192.168.255.129"
    ):
        output = perform_asir_commission_fullfile(
            scf_file, asicli_dir, bts_host=bts_host
        )

        return output

    @keyword
    def wait_for_onair(self, ip_addr="192.168.255.129"):
        success = wait_for_onair(ip_addr=ip_addr)
        if success:
            return "on air"

        MolerTest.error("eNB is not on air")
