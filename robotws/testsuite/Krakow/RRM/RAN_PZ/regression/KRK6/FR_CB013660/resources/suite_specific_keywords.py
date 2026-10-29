"""
This file contains functions used in verification of CB013660.

:copyright: Nokia Networks
:author:   Mikolaj Borkowski <mikolaj.borkowski@nokia.com>
:maintainer:   Mikolaj Borkowski <mikolaj.borkowski@nokia.com>
"""

import requests
import json
import os
import time
from on_air_tl_preparation import testline_preparation
from on_air_tl_preparation.bts.bts_operations import (
    EnbBtsPreparator,
    log_as_robot_keyword,
    log_info_to_console,
    log_warn_to_console,
    log_banner_to_console,
    SwVersionFactory,
    SwUpgradeException,
    get_selected_build,
)
from robot.api import logger
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.sbts.oam.coam.admin.interface import admin
from taf.rfrl.utilities.settings import WFT_ACCESS_KEY
from taf.internal.sbts.admin import exceptions as admin_exceptions
from taf.rfrl.utilities import test_config
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from moler.cmd.unix.exit import Exit


def get_function_file_path():
    # Get the absolute path of the current script
    script_path = os.path.abspath(__file__)
    # Get the directory containing the script
    script_dir = os.path.dirname(script_path)
    return script_dir


def get_sw_from_bts():
    """
    Retrieves the software versions for gNB from BTS.

    The function detects the software versions for gNB and eNB using the REST API.
    If the software release is TRUNK, it replaces part of the version with 'SBTS00'.

    Returns:
        str: SW version from gNB.
    """

    sw_gnb = detect_bts_sw_version_via_rest_api()
    if get_release_from_sw(sw_gnb) == "SBTS00":
        trunk_release = sw_gnb[0:8]
        sw_gnb = sw_gnb.replace(trunk_release, "SBTS00")

    return sw_gnb


def get_release_from_sw(bts_sw: str) -> str:
    """
    Retrieves the BTS software release version.

    Args:
        bts_sw Software of BTS.

    Returns:
        str: The BTS software release version.

    Raises:
        SWNotDetectedException: If the BTS software version cannot be detected.
    """

    logger.debug("Getting release from BTS SW.")
    bts_sw_release = SbtsSwVersion(bts_sw).release
    logger.info(f"BTS SW Release is: {bts_sw_release}.")
    return bts_sw_release


def detect_bts_sw_version_via_rest_api(
    bts_host: str = "192.168.255.129",
    bts_port: int = 443,
    username: str = "Nemuadmin",
    password: str = "nemuuser",
    timeout: int = 30,
) -> str:
    """
    Detects the BTS software version via REST API.

    Args:
        bts_host (str): The IP address of the BTS host. Default is '192.168.255.129'.
        bts_port (int): The port to connect to the BTS. Default is 443.
        username (str): The username for login. Default is 'Nemuadmin'.
        password (str): The password for login. Default is 'nemuuser'.
        timeout (int): The connection timeout in seconds. Default is 30.

    Returns:
        str: The BTS software version.

    Raises:
        SWNotDetectedException: If the connection to the BTS is not possible via REST API.
    """

    admin_rest_api = admin()
    connection = None

    try:
        logger.debug("Try to connect to BTS via Rest API.")
        connection = admin_rest_api.connect_to(
            bts_host, bts_port, username, password, timeout
        )
        logger.debug("Connection successful. Try to get SW from BTS.")
        bts_sw = connection.get_sw_version()
        logger.debug("BTS SW check successful.")
    except (
        admin_exceptions.AdminApiConnectionClosedException,
        admin_exceptions.AdminApiProcedureFailureException,
        admin_exceptions.AdminApiNoResponseException,
        admin_exceptions.AdminApiTerminatedException,
    ) as error:
        logger.error(f"Error: Connection to BTS is not possible via REST API: {error}")
        raise Exception("SWNotDetectedException")
    finally:
        if connection is not None:
            logger.debug("Close admin connection to BTS.")
            admin_rest_api.teardown()
            logger.debug("Admin connection closed.")

    logger.info(f"Detected BTS SW: {bts_sw}.")
    return bts_sw


def find_source_build_with_different_asihub_and_older_version():
    """
    Find a source build with a different ASIHUB value and ensure it is older than the target software.
    Returns:
        list: Target current software on BTS and source software versions if found, otherwise None.
    """
    current_sw_version_on_bts = get_sw_from_bts()
    file_to_use = construct_json_file_path()
    asihub_values = fetch_asihub_values(file_to_use, current_sw_version_on_bts)

    if len(asihub_values) >= 2:
        return assign_target_and_source(asihub_values, current_sw_version_on_bts)
    else:
        print("Less than two software entries with different ASIHUB values found.")
        return None


def construct_json_file_path():
    """Construct the full path to the JSON file."""
    default_file_location_instance = test_config.DefaultFileLocation()
    release = default_file_location_instance.get_commissioning_branch()
    json_file_name = f"params_{release}.json"
    script_dir = get_function_file_path()
    file_to_use = os.path.join(script_dir, json_file_name)
    return file_to_use


def fetch_asihub_values(file_to_use, current_sw_version_on_bts):
    """Fetch ASIHUB values by iterating through API pages."""
    url = "https://wft.int.net.nokia.com:8091/ALL/api/v1/build_branch.json"
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    asihub_values = {}

    for page in range(1, 6):  # Limit the loop to pages 1 through 5
        try:
            with open(file_to_use, "r") as params_file:
                params = json.load(params_file)
                params["access_key"] = WFT_ACCESS_KEY
                params["page"] = str(page)
                if (
                    "view_filters_attributes" in params
                    and "0" in params["view_filters_attributes"]
                ):
                    params["view_filters_attributes"]["0"][
                        "value"
                    ] = current_sw_version_on_bts
                print(f"Requesting page {page} with params: {params}")

            response = requests.post(url, headers=headers, json=params)
            response.raise_for_status()
            data = response.json()
            print("HTTP request executed successfully.")
            parse_api_response(data, asihub_values)
        except requests.exceptions.RequestException as e:
            print(f"Error executing HTTP request: {e}")
            return {}
        except FileNotFoundError:
            print(f"Error: '{file_to_use}' file not found.")
            return {}
        except json.JSONDecodeError:
            print("Error: Failed to decode JSON from response.")
            return {}

    return asihub_values


def parse_api_response(data, asihub_values):
    """Parse the API response and populate ASIHUB values."""
    items = data.get("items", [])
    for entry in items:
        version = entry.get("version")
        subbuilds = entry.get("sub_builds", [])
        for item in subbuilds:
            name = item.get("name")
            if name == "ASIHUB":
                asihub_value = item.get("baseline")
                if asihub_value not in asihub_values:
                    asihub_values[asihub_value] = version


def assign_target_and_source(asihub_values, current_sw_version_on_bts):
    """Assign target and source software versions."""
    print("Two software entries with different ASIHUB values:")
    for asihub_value, name in asihub_values.items():
        print(f"Name: {name}, ASIHUB Value: {asihub_value}")

    softwares = list(asihub_values.values())
    print(f"Current software on BTS: {current_sw_version_on_bts}")
    target = current_sw_version_on_bts
    source = None

    for sw_version in softwares:
        if sw_version != current_sw_version_on_bts:
            source = sw_version
            break

    if source:
        return target, source
    else:
        print("Error: No older source software found.")
        return None


def get_rfsw_asir_version(bts_id=0, du_id=0, hub_id=0):
    asir_hub_operator = GnbAsirHubOperations()
    device = asir_hub_operator.get_hub_device(bts_id=bts_id, du_id=du_id, ru_id=hub_id)
    device.goto_state("RFSW_CLI")
    hub_ver_cmd = device.get_cmd(cmd_name="hub_version")
    result = hub_ver_cmd()
    return result["BUILD"]


def prepare_main_and_lte_neighbour(
    scfs_path=False,
    swconfig_from_path=False,
    upload_swconfig_to_neighbour=False,
    incompatible_error_timer=False,
    increase_timeout_for_update_sw=False,
    increase_time_for_checking_bbmod=False,
    increase_time_for_checking_radios=False,
    increase_time_for_checking_cells=False,
    increase_time_for_checking_X2link=False,
    neighbour_increase_timeout_for_update_sw=False,
    increase_time_for_checking_neighbour_radios=False,
    increase_time_for_checking_neighbour_cells=False,
    scf_prefix_tag=None,
    wait_for_on_air=False,
    log_dir=None,
    wtd_sfp_wa_support=False,
    bsr_config_file=None,
    certificates=None,
    rusw=None,
    swconfig_flags=None,
    check_x2_link=False,
):
    if log_dir is None:
        log_dir = os.path.join(
            testline_preparation.get_builtin_value("OUTPUT DIR"), "preparation"
        )
    increase_timeout_for_update_sw = (
        int(increase_timeout_for_update_sw) if increase_timeout_for_update_sw else 1800
    )
    neighbour_increase_timeout_for_update_sw = (
        int(neighbour_increase_timeout_for_update_sw)
        if neighbour_increase_timeout_for_update_sw
        else 1800
    )
    should_not_print_log_about_success = []

    main_bts, neighbour_enbs, _ = (
        testline_preparation.get_neighbour_gnbs_and_enbs_info_defaults()
    )
    if certificates:
        certificates_gnb, _ = testline_preparation.group_certificates(certificates)
        certificates_gnb_main = certificates_gnb.pop(0)
    else:
        certificates_gnb, _, certificates_gnb_main = None, None, None

    testline_preparation.power_on_all_pdu_ports()
    swconfig_from_path = testline_preparation.append_swconfig_flags_if_provided(
        source_swconfig_path=swconfig_from_path,
        target_swconfig_path=os.path.join(log_dir, "auto_generated_swconfig.txt"),
        flags=swconfig_flags,
    )

    testline_preparation.prepare_main_bts(
        bsr_config_file,
        incompatible_error_timer,
        increase_time_for_checking_X2link,
        increase_time_for_checking_bbmod,
        increase_time_for_checking_cells,
        increase_time_for_checking_radios,
        increase_timeout_for_update_sw,
        log_dir,
        main_bts,
        neighbour_enbs,
        scf_prefix_tag,
        scfs_path,
        should_not_print_log_about_success,
        swconfig_from_path,
        wait_for_on_air,
        wtd_sfp_wa_support,
        certificates_gnb_main,
        rusw,
        check_x2_link,
    )

    prepare_lte_bts_neighbours(
        increase_time_for_checking_neighbour_cells,
        increase_time_for_checking_neighbour_radios,
        log_dir,
        neighbour_enbs,
        neighbour_increase_timeout_for_update_sw,
        scf_prefix_tag,
        scfs_path,
        should_not_print_log_about_success,
        swconfig_from_path,
        upload_swconfig_to_neighbour,
    )


class PatchedGenericBtsPreparator(EnbBtsPreparator):

    @log_as_robot_keyword
    def prepare_bts_neighbour(
        self,
        neighbour_name,
        neighbour_info,
        scf_path,
        sw_conf_path,
        upload_sw_config,
        neighbour_increase_timeout_for_update_sw,
        increase_time_for_checking_neighbour_radios,
        increase_time_for_checking_neighbour_cells,
        scf_prefix_tag=None,
        certificates=None,
        reset_admin_required=True,
    ):
        """Shortened neighbour preparation."""
        self.connect(increase_time_for_check=False, interface="lmp")

        if sw_conf_path and upload_sw_config:
            self.upload_sw_conf(
                node_name=neighbour_name,
                sw_conf_path=sw_conf_path,
                bts_conf=neighbour_info,
            )

        if certificates:
            self.download_and_install_certificates(certificates)

        actual_build = self.bts_comm.admin.get_sw_version(
            connection=self.bts_connection_name
        )
        selected_build = get_selected_build(actual_build)

        if self._check_if_fsmr3():
            fsm_build = self._get_proper_build_name_for_fsm(build=selected_build)
            if fsm_build:
                selected_build = fsm_build

        ab = SwVersionFactory.create_sw_version(actual_build)
        sb = SwVersionFactory.create_sw_version(selected_build)

        if ab != sb:
            log_info_to_console(
                "Different build on neighbour detected", log_hierarchy=2
            )
            log_info_to_console(
                f"Build on neighbour will be changed to {selected_build}",
                log_hierarchy=2,
            )
            try:
                path_to_sw = self.download_bts_sw_package(sw=selected_build)
            except SwUpgradeException:
                log_warn_to_console("SW download failed - check why", log_hierarchy=3)

            log_info_to_console("Configuration Reset on neighbour", log_hierarchy=2)
            self.bts_comm.reset_configuration(bts_id=self.bts_id, du_id=self.du_id)

            self.update_software(
                sw_package=path_to_sw,
                connection=self.bts_connection_name,
                timeout=neighbour_increase_timeout_for_update_sw,
            )

            self.disconnect(bts_id=self.bts_id, du_id=self.du_id)
            time.sleep(120)
            self.connect(increase_time_for_check=False, interface="lmp")
        else:
            log_info_to_console(
                "Selected build already installed on neighbour - perform commissioning",
                log_hierarchy=1,
            )

        self.commission_scf(
            node_name=neighbour_name,
            scf_path=scf_path,
            reset_admin_required=reset_admin_required,
            scf_prefix_tag=scf_prefix_tag,
        )
        self.wait_for_bts_on_air_state(
            increase_time_for_checking_radios=increase_time_for_checking_neighbour_radios,
            increase_time_for_checking_cells=increase_time_for_checking_neighbour_cells,
        )

        log_banner_to_console(
            f'{neighbour_info["bts_type"]} Neighbour {neighbour_name} prepared.'
        )


@log_as_robot_keyword
def prepare_lte_bts_neighbour(
    _log_dir,
    enb_info,
    enb_log,
    enb_name,
    increase_time_for_checking_neighbour_cells,
    increase_time_for_checking_neighbour_radios,
    neighbour_increase_timeout_for_update_sw,
    scf_prefix_tag,
    scfs_path,
    swconfig_from_path,
    upload_swconfig_to_neighbour,
):
    log_banner_to_console(
        f'Prepare {enb_info["bts_type"]} Neighbour Station: {enb_name}'
    )
    testline_preparation.check_vm_and_restart_if_uptime_is_to_long(
        du_id=enb_info["du_id"],
        bts_id=enb_info["bts_id"],
        bts_type=enb_info["bts_type"],
    )
    enb_log.start_collecting_bts_log()
    enb_bts = PatchedGenericBtsPreparator(
        du_id=enb_info["du_id"], bts_id=enb_info["bts_id"], log_dir=_log_dir
    )
    enb_bts.prepare_bts_neighbour(
        neighbour_name=enb_name,
        neighbour_info=enb_info,
        scf_path=scfs_path,
        sw_conf_path=swconfig_from_path,
        upload_sw_config=upload_swconfig_to_neighbour,
        neighbour_increase_timeout_for_update_sw=neighbour_increase_timeout_for_update_sw,
        increase_time_for_checking_neighbour_radios=increase_time_for_checking_neighbour_radios,
        increase_time_for_checking_neighbour_cells=increase_time_for_checking_neighbour_cells,
        scf_prefix_tag=scf_prefix_tag,
    )


@log_as_robot_keyword
def prepare_lte_bts_neighbours(
    increase_time_for_checking_neighbour_cells,
    increase_time_for_checking_neighbour_radios,
    log_dir,
    neighbour_enbs,
    neighbour_increase_timeout_for_update_sw,
    scf_prefix_tag,
    scfs_path,
    should_not_print_log_about_success,
    swconfig_from_path,
    upload_swconfig_to_neighbour,
):
    try:
        for enb_name, enb_info in neighbour_enbs.items():
            _log_dir = os.path.join(log_dir, enb_name)
            enb_log = testline_preparation.EnbLogger(
                du_id=enb_info["du_id"], bts_id=enb_info["bts_id"], log_dir=_log_dir
            )
            prepare_lte_bts_neighbour(
                _log_dir,
                enb_info,
                enb_log,
                enb_name,
                increase_time_for_checking_neighbour_cells,
                increase_time_for_checking_neighbour_radios,
                neighbour_increase_timeout_for_update_sw,
                scf_prefix_tag,
                scfs_path,
                swconfig_from_path,
                upload_swconfig_to_neighbour,
            )
    except Exception as err:
        exc_info = testline_preparation.sys.exc_info()
        testline_preparation.traceback.print_exception(*exc_info)
        log_banner_to_console("Preparing neighbour ENB(s) failed !")
        enb_log.collect_snapshots()
        should_not_print_log_about_success.append(True)
        del exc_info
        raise testline_preparation.PreparingENBNeighbourError(err)
    finally:
        enb_log.stop_collecting_bts_log_and_get_it()
