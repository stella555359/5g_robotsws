# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Mateusz Rzeczyca
:contact: mateusz.rzeczyca@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""


from taf.ue.prisma import prisma
from taf.ue.prisma.exceptions import AirmosaicRequestFailed
from taf.ue.prisma.exceptions import AirmosaicOpenRestSessionFailed
from taf.ue.prisma.exceptions import UnexpectedAirmosaicStatus
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from robot.libraries.OperatingSystem import OperatingSystem
import subprocess
import shlex
import time
import sys
import os
import re
from common_gnb import execute_command_on_the_remote
from common_gnb import get_scf_phys_cell_id
from file_management import upload_file_to
from utilities import logger_console


class WrongCellIdOnPrismaException(Exception):
    """Custom exception raised, when Cell ID found on LSU is not matching Physical Cell ID at SCF.
    """
    pass


class NotKnownBeamsCountException(Exception):
    """Custom exception raised, when at Cell Configuration file on LSU beam count cannot be retrieved.
    """
    pass


class BeamsCountTooLargeException(Exception):
    """Custom exception raised, when beam count was retrieved, but was to large.
    """
    pass


class NoSyncCellStatusOnPrismaException(Exception):
    """Custom exception raised, when Prisma could not achieve sync status.
    """
    pass


class NoTSTMConnectionInAirmosaicException(Exception):
    """Custom exception raised, when Airmosaic cannot achieve TSTM connection during configuration loading.
    """
    pass


class NoPingToPrismaException(Exception):
    """Custom exception raised, when prisma is not pingable.
    """
    pass


class NoTstmStartupException(Exception):
    """Custom exception raised, when TSTM could not start.
    """
    pass


class NoScenarioCompletionException(Exception):
    """Custom exception raised, when scenario cannot finish.
    """
    pass


class NoIpAddressInScenarioLogsException(Exception):
    """Custom exception raised, when in scenario logger there is no UE ip address used in DL traffic.
    """
    pass


class LsuStartFailureException(Exception):
    """Custom exception raised, when LSU could not start.
    """
    pass


class PrismaHolder(object):
    """Holder for all needed prisma objects instances.
    ${tl} variable should be UTE CLOUD VM variable file from testline_configuration repo.
    Ex: robot -V /home/ute/testline_configuration/7_7_UTE5GCLOUDT411/ 5GC002001-A-i.robot
    """
    instance = prisma()
    ul_tput = None
    dl_tput = None


def load_prisma_configuration():
    """Loads ${PRISMA_CONFIG_YAML} and starts connection with all instances, like LSU, TSTM and Airmosaic.

    Important:
    This keyword must be called everytime when you need to establish LSU, TSTM and Airmosaic connection
    and most of below keywords needs this to be called.

    Required:
    ${PRISMA_CONFIG_YAML} - path to Prisma Configuration .yaml file
    """
    PrismaHolder.instance = prisma()
    yaml_file = BuiltIn().get_variable_value('${PRISMA_CONFIG_YAML}')

    logger_console("Loading config for Prisma: {} ...".format(yaml_file))
    PrismaHolder.instance.load_config(yaml_file=yaml_file,
                                      testline_configuration=BuiltIn().get_variable_value('${tl}').ues[0])

    logger_console("Prisma setup call...")
    PrismaHolder.instance.setup()


def reboot_prisma():
    """Reboots Prisma with ${CMD_REBOOT_PRISMA} command.

    Required:
    ${CMD_REBOOT_PRISMA} - command used to prisma reboot (Ex. lsusuid shutdown)
    """
    logger_console("Rebooting Prisma...")
    PrismaHolder.instance.execute_script(node_name="lsu_uu",
                                         script_cmd=BuiltIn().get_variable_value('${CMD_REBOOT_PRISMA}'),
                                         expect_regex='',
                                         timeout=30)


def __get_ping_status():
    """Tries to ping LSU and returns output of command.

    :return: output of ping -c 1 <addr> command,
             where <addr> is retrieved from tl.ues[0].lsu_uu_ssh_connection_details.addr
    """
    lsu_addr = BuiltIn().get_variable_value('${tl}').ues[0].lsu_uu_ssh_connection_details.addr
    ping_cmd = "ping -c 1 {}".format(lsu_addr)
    ping_regexp = "% packet loss"

    output = PrismaHolder.instance.execute_script(node_name="airmosaic",
                                                  script_cmd=ping_cmd,
                                                  expect_regex=ping_regexp,
                                                  timeout=30)
    return output


def is_ping_to_prisma_working():
    """Checks, if ping to LSU is working and returns result in boolean format.

    :return: True, if ping is working, False otherwise
    """
    working_ping_print = "1 packets transmitted, 1 received, 0% packet loss"
    status = __get_ping_status()
    if working_ping_print in status[1]:
        return True

    return False


def wait_for_prisma_ping(retry=15, retry_interval=30):
    """Waits for prisma to become pingable and if calls load_prisma_configuration().

    :param retry: num of retries (defaults to 15)
    :param retry_interval: interval in seconds to next try (defaults to 30)
    :raises NoPingToPrismaException: if prisma is not pingable after given number of retries.
    """
    logger_console("Waiting for ping to LSU...")
    status_print = "Prisma Ping Status: {}"
    status = ""
    while retry > 0:
        retry -= 1

        if is_ping_to_prisma_working():
            break

        logger.info(msg=status_print.format("No ping"), also_console=True)
        time.sleep(retry_interval)

    if retry == 0:
        raise NoPingToPrismaException('Could not ping Prisma!')

    logger.info(msg=status_print.format("OK!"), also_console=True)
    load_prisma_configuration()


def __create_directory_at_prisma(directory):
    """Creates given directory at LSU.

    :param directory: directory name
    """
    logger_console("Creating directory {} at LSU...".format(directory))
    PrismaHolder.instance.execute_script(node_name="lsu_uu",
                                         script_cmd="mkdir {}".format(directory),
                                         expect_regex='',
                                         timeout=4)


def __give_executable_permissions_at_dir_on_prisma(remote_path):
    """Gives +x permissions on all files at directory.

    :param remote_path: path, where only executable files should be found.
    """
    logger_console("Giving +x permission at {} (LSU)...".format(remote_path))
    PrismaHolder.instance.execute_script(node_name="lsu_uu",
                                         script_cmd="cd {}; chmod +x *".format(remote_path),
                                         expect_regex='',
                                         timeout=4)


def __upload_file_to_prisma(files, remote_path):
    """Uploads given files to LSU at remote_path.

    :param files: str (file) or list (files) that should be on LSU
    :param remote_path: remote path at LSU
    """
    logger_console("Uploading {} to {} at LSU...".format(files, remote_path))
    tl = BuiltIn().get_variable_value('${tl}')
    upload_file_to(files=files if isinstance(files, list) else [files],
                   remote_path=remote_path,
                   ip_addr=tl.ues[0].lsu_uu_ssh_connection_details.addr,
                   username=tl.ues[0].lsu_uu_ssh_connection_details.username,
                   password=tl.ues[0].lsu_uu_ssh_connection_details.password)


def upload_scripts_to_prisma():
    """Uploads all needed scripts to LSU and gives them executable permissions.

    Required:
    ${PRISMA_SCRIPTS_REMOTE_DIR} - remote path at LSU, where files will be uploaded, Ex: /home/user/PrismaAutomation
    ${PRISMA_START_LSU_SCRIPT} - local path pointing to start lsu script, Ex: {}/start_LSU_with_5G_cell.sh
    ${PRISMA_START_CELL_SCRIPT} - local path pointing to start cell script, Ex: {}/start_5G_cell_2beams.sh
    ${PRISMA_START_TSTM_SCRIPT} - local path pointing to start tstm script, Ex: {}/start_tstm.cfg
    """
    remote_dir = BuiltIn().get_variable_value('${PRISMA_SCRIPTS_REMOTE_DIR}')
    __create_directory_at_prisma(directory=remote_dir)
    __upload_file_to_prisma(files=BuiltIn().get_variable_value('${PRISMA_START_LSU_SCRIPT}'), remote_path=remote_dir)
    __upload_file_to_prisma(files=BuiltIn().get_variable_value('${PRISMA_START_CELL_SCRIPT}'), remote_path=remote_dir)
    __upload_file_to_prisma(files=BuiltIn().get_variable_value('${PRISMA_START_TSTM_SCRIPT}'), remote_path=remote_dir)
    __give_executable_permissions_at_dir_on_prisma(remote_path=remote_dir)


def __get_cell_id_print(regexp):
    """Returns Cell ID print line from LSU.

    Required:
    ${CMD_CELL_ID} - command used to get Cell ID print line, Ex: trcinfo -p 0-2 | grep SSS

    :param regexp: regex expression used to find expected print
    :return: found output print line
    """
    output = PrismaHolder.instance.execute_script(node_name="lsu_uu",
                                                  script_cmd=BuiltIn().get_variable_value('${CMD_CELL_ID}'),
                                                  expect_regex=regexp,
                                                  timeout=30)
    return output


def is_cell_id_correct_on_prisma(phy_cell_id_scf):
    """Checks, if Cell ID found on LSU is matching the one at SCF file.

    Required:
    ${CMD_CELL_ID} - command used to get Cell ID print line, Ex: trcinfo -p 0-2 | grep SSS
    ${CELL_ID_REGEXP} - regexp with one format {} place, where SCF phy cell id must be placed, Ex: SYNC->SSS CELL_ID={}

    :param phy_cell_id_scf: retrieved Physical Cell ID from SCF file.
    :return: Tuple (boolean, current_cell_id), boolean is True when current_cell_id is correct, False otherwise
    """
    cell_id_regexp = BuiltIn().get_variable_value('${CELL_ID_REGEXP}')
    regexp = cell_id_regexp.format(phy_cell_id_scf)

    status = __get_cell_id_print(regexp)

    current_cell_id = -1
    try:
        current_cell_id = status[1].split("CELL_ID=")[1]
        if str(phy_cell_id_scf) == current_cell_id:
            return True, current_cell_id
    except IndexError:
        return False, current_cell_id

    return False, current_cell_id


def wait_for_prisma_to_detect_cell(phys_cell_id=50, retry=15, retry_interval=30):
    """Waits from Prisma to detect 5G gNB cell.

    Required:
    ${CMD_CELL_ID} - command used to get Cell ID print line, Ex: trcinfo -p 0-2 | grep SSS
    ${CELL_ID_REGEXP} - regexp with one format {} place, where SCF phy cell id must be placed, Ex: SYNC->SSS CELL_ID={}

    :param phys_cell_id: Physical Cell ID, which should be retrieved from SCF (defaults to 50)
    :param retry: num of retries (defaults to 15)
    :param retry_interval: interval in seconds to next try (defaults to 30)
    :raises WrongCellIdOnPrismaException: if prisma has wrong cell id after number of retries
    """
    logger_console("Waiting for correct Cell ID on Prisma...")

    status_print = "Prisma Cell ID Status: {}"
    status = ""

    while retry > 0:
        retry -= 1

        is_correct, cell_id = is_cell_id_correct_on_prisma(phys_cell_id)
        if is_correct:
            break

        logger.info(msg=status_print.format("Wrong Cell ID: {}".format(cell_id)), also_console=True)
        time.sleep(retry_interval)

    if retry == 0:
        raise WrongCellIdOnPrismaException('Prisma could not get expected Cell ID: {}'.format(phys_cell_id))

    logger.info(msg=status_print.format("OK!"), also_console=True)


def __get_cell_status_print():
    """Returns Cell Status print retrieved from output of ${CMD_CELL_SYNC} command.

    Required:
    ${CMD_CELL_SYNC} - command to check current state of cell, Ex. cat /res/sdr/state/r5gnr.ue/01 | grep STATE

    :return: cell status print line
    """
    output = PrismaHolder.instance.execute_script(node_name="lsu_uu",
                                                  script_cmd=BuiltIn().get_variable_value('${CMD_CELL_SYNC}'),
                                                  expect_regex='',
                                                  timeout=30)
    return output


def __get_beams_count():
    """Returns beams count retrieved from ${CMD_BEAMS_COUNT_CHECK} command.

    Required:
    ${CMD_BEAMS_COUNT_CHECK} - command that should count DBEAM_ lines in cell configuration script,
                               Ex. "cat {} | grep DBEAM_ | wc -l".format(PRISMA_START_CELL_SCRIPT_REMOTE)

    :return: beams_count in int type, or None if retrieval was failure
    """
    output = PrismaHolder.instance.execute_script(node_name="lsu_uu",
                                                  script_cmd=BuiltIn().get_variable_value('${CMD_BEAMS_COUNT_CHECK}'),
                                                  expect_regex='',
                                                  timeout=30)
    beams_count = None

    try:
        beams_count = int(output[1])
    except IndexError:
        raise NotKnownBeamsCountException("beams_count is None and couldnt be retrieved from LSU")

    if beams_count > 3:
        raise BeamsCountTooLargeException("beams_count {} is high, it is not expected".format(beams_count))

    return beams_count


def is_cell_in_sync():
    """Checks if cell is in SYNC state and returns result in boolean format.

    Required:
    ${CMD_CELL_SYNC} - command to check current state of cell, Ex. cat /res/sdr/state/r5gnr.ue/01 | grep STATE
    ${CMD_BEAMS_COUNT_CHECK} - command that should count DBEAM_ lines in cell configuration script,
                               Ex. "cat {} | grep DBEAM_ | wc -l".format(PRISMA_START_CELL_SCRIPT_REMOTE)
    ${CELL_SYNC_REGEXP} - regex expression to check STATE_ of cell and beams,
                          Ex. "STATE_{} = SYNC", where {} should be ready to get some string in formatting

    :return: result in boolean format, True if cell in sync, False otherwise
    """
    cell_id_list = ["00", "01", "02", "03"]  # 03 is max as keysight docs does not show more
    cell_sync_regexp = BuiltIn().get_variable_value('${CELL_SYNC_REGEXP}')
    beams_count = __get_beams_count()
    cell_status = __get_cell_status_print()

    found_sync_count = 0
    for i in range(beams_count):
        beam_sync_regexp = cell_sync_regexp.format(cell_id_list[i])
        if beam_sync_regexp in cell_status[1]:  # Searching for STATE_00 = SYNC and iterating
            found_sync_count += 1

    if beams_count == found_sync_count:
        return True

    return False


def wait_for_prisma_sync_status(retry=15, retry_interval=30):
    """During every retry keyword validates beams count and cell status print. If everything is fine
    keyword ends.

    Required:
    ${CMD_CELL_SYNC} - command to check current state of cell, Ex. cat /res/sdr/state/r5gnr.ue/01 | grep STATE
    ${CMD_BEAMS_COUNT_CHECK} - command that should count DBEAM_ lines in cell configuration script,
                               Ex. "cat {} | grep DBEAM_ | wc -l".format(PRISMA_START_CELL_SCRIPT_REMOTE)
    ${CELL_SYNC_REGEXP} - regex expression to check STATE_ of cell and beams,
                          Ex. "STATE_{} = SYNC", where {} should be ready to get some string in formatting

    :param retry: num of retries (defaults to 15)
    :param retry_interval: interval in seconds to next try (defaults to 30)
    :raises NoSyncCellStatusOnPrismaException: if prisma is not in sync status
    """
    logger_console("Waiting for sync...")

    status_print = "Prisma Cell Status: {}"
    status = ""

    while retry > 0:
        retry -= 1

        if is_cell_in_sync():
            break

        logger.info(msg=status_print.format("No Sync"), also_console=True)
        time.sleep(retry_interval)

    if retry == 0:
        raise NoSyncCellStatusOnPrismaException('Prisma could not get expected Cell Status: SYNC')

    logger.info(msg=status_print.format("SYNC!"), also_console=True)


def create_cell(timeout=180):
    """Calls on LSU script in order to create 5G cell and then waits for cell sync state.

    Required:
    ${CELL_DISTNAME} - dist_name pointing to cell, Ex. MRBTS-75411/NRBTS-75411/NRCELL-1
    ${CELL_PHY_ID_PARAM_NAME} - physCellId parameter name in CELL_DISTNAME, Ex. [{"parameter": "physCellId"}]
    ${CMD_CELL_ID} - command used to get Cell ID print line, Ex: trcinfo -p 0-2 | grep SSS
    ${CELL_ID_REGEXP} - regexp with one format {} place, where SCF phy cell id must be placed, Ex: SYNC->SSS CELL_ID={}
    ${CMD_CELL_SYNC} - command to check current state of cell, Ex. cat /res/sdr/state/r5gnr.ue/01 | grep STATE
    ${CMD_BEAMS_COUNT_CHECK} - command that should count DBEAM_ lines in cell configuration script,
                               Ex. "cat {} | grep DBEAM_ | wc -l".format(PRISMA_START_CELL_SCRIPT_REMOTE)
    ${CELL_SYNC_REGEXP} - regex expression to check STATE_ of cell and beams,
                          Ex. "STATE_{} = SYNC", where {} should be ready to get some string in formatting

    :param timeout: defaults to 180
    """
    logger_console("Creating 5G cell...")
    PrismaHolder.instance.create_5g_cell(node_name='lsu_uu', timeout=timeout)

    phys_cell_id = get_scf_phys_cell_id(cell_distname=BuiltIn().get_variable_value('${CELL_DISTNAME}'),
                                        cell_phy_id_param=BuiltIn().get_variable_value('${CELL_PHY_ID_PARAM_NAME}'))
    wait_for_prisma_to_detect_cell(phys_cell_id=phys_cell_id)
    wait_for_prisma_sync_status()


def start_lsu(timeout=250):
    """Calls lsustart after preparation with lsustop and lsuclean.

    Required:
    ${LSU_START_REGEXP} - regex expression used to check if lsu started correctly, Ex. lsustart completed correctly
    ${CMD_LSUCLEAN_PRISMA} - command to clean current LSU logs, Ex. lsuclean
    ${CMD_LSUSTOP_PRISMA} - command to stop LSU, Ex. lsustop

    :param timeout: defaults to 250
    :raises LsuStartFailureException: if LSU could not start
    """
    stop_lsu()
    clean_lsu()

    logger_console("Starting LSU...")
    lsu_response = PrismaHolder.instance.start_lsu(node_name='lsu_uu', timeout=timeout)
    if BuiltIn().get_variable_value('${LSU_START_REGEXP}') in lsu_response[1]:
        logger_console("LSU started correctly")
    else:
        logger_console("LSU failed to start")
        raise LsuStartFailureException("Could not start LSU.")


def clean_lsu(timeout=30):
    """Calls ${CMD_LSUCLEAN_PRISMA} command.

    Required:
    ${CMD_LSUCLEAN_PRISMA} - command to clean current LSU logs, Ex. lsuclean

    :param timeout: defaults to 30
    """
    logger_console("Cleaning LSU...")
    lsu_details = BuiltIn().get_variable_value('${tl}').ues[0].lsu_uu_ssh_connection_details
    execute_command_on_the_remote(hostname=lsu_details.addr,
                                  username=lsu_details.username,
                                  password=lsu_details.password,
                                  cmd=BuiltIn().get_variable_value('${CMD_LSUCLEAN_PRISMA}'))
    logger_console("Waiting for LSU to clean")
    time.sleep(timeout)


def stop_lsu(timeout=60):
    """Calls ${CMD_LSUSTOP_PRISMA} command.

    Required:
    ${CMD_LSUSTOP_PRISMA} - command to stop LSU, Ex. lsustop

    :param timeout: defaults to 60
    """
    logger_console("Stopping LSU...")
    lsu_details = BuiltIn().get_variable_value('${tl}').ues[0].lsu_uu_ssh_connection_details
    execute_command_on_the_remote(hostname=lsu_details.addr,
                                  username=lsu_details.username,
                                  password=lsu_details.password,
                                  cmd=BuiltIn().get_variable_value('${CMD_LSUSTOP_PRISMA}'))
    logger_console("Waiting for LSU to stop")
    time.sleep(timeout)


def start_airmosaic(timeout=60):
    """Starts Airmosaic on harness mode

    :param timeout: defaults to 60
    """
    logger_console("Starting Airmosaic...")
    PrismaHolder.instance.start_mosaic()
    logger_console("Waiting for airmosaic to launch...")
    time.sleep(15)


def stop_airmosaic():
    """Stops Airmosaic on harness mode.
    """
    logger_console("Stopping Airmosaic...")
    PrismaHolder.instance.close_mosaic()


def restart_cell_without_prisma_reboot():
    """Calls start_lsu() and create_cell() keywords without rebooting.

    Required:
    ${LSU_START_REGEXP} - regex expression used to check if lsu started correctly, Ex. lsustart completed correctly
    ${CMD_LSUCLEAN_PRISMA} - command to clean current LSU logs, Ex. lsuclean
    ${CMD_LSUSTOP_PRISMA} - command to stop LSU, Ex. lsustop
    ${CELL_DISTNAME} - dist_name pointing to cell, Ex. MRBTS-75411/NRBTS-75411/NRCELL-1
    ${CELL_PHY_ID_PARAM_NAME} - physCellId parameter name in CELL_DISTNAME, Ex. [{"parameter": "physCellId"}]
    ${CMD_CELL_ID} - command used to get Cell ID print line, Ex: trcinfo -p 0-2 | grep SSS
    ${CELL_ID_REGEXP} - regexp with one format {} place, where SCF phy cell id must be placed, Ex: SYNC->SSS CELL_ID={}
    ${CMD_CELL_SYNC} - command to check current state of cell, Ex. cat /res/sdr/state/r5gnr.ue/01 | grep STATE
    ${CMD_BEAMS_COUNT_CHECK} - command that should count DBEAM_ lines in cell configuration script,
                               Ex. "cat {} | grep DBEAM_ | wc -l".format(PRISMA_START_CELL_SCRIPT_REMOTE)
    ${CELL_SYNC_REGEXP} - regex expression to check STATE_ of cell and beams,
                          Ex. "STATE_{} = SYNC", where {} should be ready to get some string in formatting
    """
    start_lsu()
    create_cell()


def __check_if_tstm_started_correctly(timeout=30):
    """Checks if TSTM has started correctly or is already running. Then returns result in boolean format.

    Required:
    ${TSTM_START_REGEXP} - expected regex expression, when TSTM started correctly, Ex. SOKLISTEN
    ${TSTM_ALREADY_STARTED_REGEXP} - expected regex expression, when TSTM is running, Ex. Address already in use

    :param timeout: defaults to 30
    :return: True if TSTM started correctly or is running, False otherwise
    """
    tstm_start_regexp = BuiltIn().get_variable_value('${TSTM_START_REGEXP}')
    tstm_already_started_regexp = BuiltIn().get_variable_value('${TSTM_ALREADY_STARTED_REGEXP}')

    response = PrismaHolder.instance.get_tstm_log(node_name="tstm_uu",
                                                  expected_regex=tstm_start_regexp,
                                                  timeout=timeout)
    if tstm_start_regexp in response[1]:
        return True
    elif tstm_already_started_regexp in response[1]:
        logger_console("Address already in use -> assuming that TSTM has already started")
        return True

    return False


def start_tstm(timeout=30):
    """Starts TSTM and validates if started correctly.

    Required:
    ${TSTM_START_REGEXP} - expected regex expression, when TSTM started correctly, Ex. SOKLISTEN
    ${TSTM_ALREADY_STARTED_REGEXP} - expected regex expression, when TSTM is running, Ex. Address already in use

    :raises NoTstmStartupException: if TSTM has not started correctly
    """
    logger_console("Starting TSTM...")
    PrismaHolder.instance.clean_tstm_log(node_name="tstm_uu")
    PrismaHolder.instance.start_tstm(node_name="tstm_uu", timeout=timeout)

    if not __check_if_tstm_started_correctly(timeout=timeout):
        raise NoTstmStartupException("Could not start TSTM...")


def stop_tstm(timeout=30):
    """Stops TSTM.

    :param timeout: defaults to 30
    """
    logger_console("Stopping TSTM")
    PrismaHolder.instance.stop_tstm(node_name="tstm_uu", timeout=timeout)
    logger_console("Waiting for TSTM to stop")
    time.sleep(timeout)


def get_scenario_status():
    """Returns scenario status from Airmosaic.

    :return: scenario status in str
    """
    return PrismaHolder.instance.get_scenario_status(node_name="airmosaic")


def print_scenario_status():
    """Prints scenario status.
    """
    sce_status = get_scenario_status()
    logger.info(msg="SCE status: {}".format(sce_status), also_console=True)


def get_scenario_logging():
    """Returns scenario logger prints from Airmosaic

    :return: airmosaic scenario logger prints
    """
    return PrismaHolder.instance.get_scenario_logger(node_name="airmosaic")


def print_scenario_logging():
    """Prints scenario logger prints from Airmosaic.
    """
    sce_logging = get_scenario_logging()
    logger.info(msg="SCE logging: {}".format(sce_logging), also_console=True)


def load_airmosaic_configs_and_connect_to_tstm(airmosaic_configs_dir):
    """Loads Airmosaic configs like .sid, .usr, .mdl, .rclib files in given airmosaic_configs_dir
    and ${AIRMOSAIC_CONFIG_SID}. If loading configs procedure was a failure, then it tries proper
    action, which can repair issue. Returns result in boolean format.

    Required:
    ${AIRMOSAIC_CONFIG_SID} - just filename of .sid file, Ex. TDD_2beams_Artur.sid
    ${LSU_START_REGEXP} - regex expression used to check if lsu started correctly, Ex. lsustart completed correctly
    ${CMD_LSUCLEAN_PRISMA} - command to clean current LSU logs, Ex. lsuclean
    ${CMD_LSUSTOP_PRISMA} - command to stop LSU, Ex. lsustop
    ${CELL_DISTNAME} - dist_name pointing to cell, Ex. MRBTS-75411/NRBTS-75411/NRCELL-1
    ${CELL_PHY_ID_PARAM_NAME} - physCellId parameter name in CELL_DISTNAME, Ex. [{"parameter": "physCellId"}]
    ${CMD_CELL_ID} - command used to get Cell ID print line, Ex: trcinfo -p 0-2 | grep SSS
    ${CELL_ID_REGEXP} - regexp with one format {} place, where SCF phy cell id must be placed, Ex: SYNC->SSS CELL_ID={}
    ${CMD_CELL_SYNC} - command to check current state of cell, Ex. cat /res/sdr/state/r5gnr.ue/01 | grep STATE
    ${CMD_BEAMS_COUNT_CHECK} - command that should count DBEAM_ lines in cell configuration script,
                               Ex. "cat {} | grep DBEAM_ | wc -l".format(PRISMA_START_CELL_SCRIPT_REMOTE)
    ${CELL_SYNC_REGEXP} - regex expression to check STATE_ of cell and beams,
                          Ex. "STATE_{} = SYNC", where {} should be ready to get some string in formatting

    :param airmosaic_configs_dir: path to all prisma configs
    :return: True, if configs loaded correctly, False otherwise
    """
    try:
        logger.info(msg="Loading airmosaic configs: {}".format(airmosaic_configs_dir), also_console=True)
        PrismaHolder.instance.prepare_test(sid=BuiltIn().get_variable_value('${AIRMOSAIC_CONFIG_SID}'),
                                           config_dir=airmosaic_configs_dir)
    except AirmosaicRequestFailed as e:
        logger.info(msg="Issue: {}\n".format(e), also_console=True)
        restart_cell_without_prisma_reboot()
        return False
    except AirmosaicOpenRestSessionFailed as e:
        logger.info(msg="Issue: {}\nProbably reason is turned off airmosaic...".format(e), also_console=True)
        stop_airmosaic()
        start_airmosaic()
        return False
    except UnexpectedAirmosaicStatus as e:
        logger.info(msg="Issue: {}\nUnknown reason of this issue...".format(e), also_console=True)
        stop_airmosaic()
        start_airmosaic()
        return False

    print_scenario_status()
    return True


def wait_for_airmosaic_tstm_connection(airmosaic_configs_dir, retry=5):
    """Waits for airmosaic to load configs and connect to TSTM.

    Required:
    ${AIRMOSAIC_CONFIG_SID} - just filename of .sid file, Ex. TDD_2beams_Artur.sid
    ${LSU_START_REGEXP} - regex expression used to check if lsu started correctly, Ex. lsustart completed correctly
    ${CMD_LSUCLEAN_PRISMA} - command to clean current LSU logs, Ex. lsuclean
    ${CMD_LSUSTOP_PRISMA} - command to stop LSU, Ex. lsustop
    ${CELL_DISTNAME} - dist_name pointing to cell, Ex. MRBTS-75411/NRBTS-75411/NRCELL-1
    ${CELL_PHY_ID_PARAM_NAME} - physCellId parameter name in CELL_DISTNAME, Ex. [{"parameter": "physCellId"}]
    ${CMD_CELL_ID} - command used to get Cell ID print line, Ex: trcinfo -p 0-2 | grep SSS
    ${CELL_ID_REGEXP} - regexp with one format {} place, where SCF phy cell id must be placed, Ex: SYNC->SSS CELL_ID={}
    ${CMD_CELL_SYNC} - command to check current state of cell, Ex. cat /res/sdr/state/r5gnr.ue/01 | grep STATE
    ${CMD_BEAMS_COUNT_CHECK} - command that should count DBEAM_ lines in cell configuration script,
                               Ex. "cat {} | grep DBEAM_ | wc -l".format(PRISMA_START_CELL_SCRIPT_REMOTE)
    ${CELL_SYNC_REGEXP} - regex expression to check STATE_ of cell and beams,
                          Ex. "STATE_{} = SYNC", where {} should be ready to get some string in formatting

    :param retry: num of retries (defaults to 5)
    :param airmosaic_configs_dir: path to all prisma configs
    :raises NoTSTMConnectionInAirmosaicException: if Airmosaic could not connect to TSTM
    """
    logger_console("Trying to load airmosaic configs and connect to TSTM...")

    status_print = "Airmosaic Configs and TSTM connection status: {}"
    status = ""

    while retry > 0:
        retry -= 1

        if load_airmosaic_configs_and_connect_to_tstm(airmosaic_configs_dir):
            break

        logger.info(msg=status_print.format("No"), also_console=True)

    if retry == 0:
        raise NoTSTMConnectionInAirmosaicException('Airmosaic could not load its configs and connect to TSTM...')

    logger.info(msg=status_print.format("TSTM ONLINE!"), also_console=True)


def stop_airmosaic_test():
    """Stops currently running airmosaic test.
    """
    logger_console("Stopping Airmosaic test running...")
    PrismaHolder.instance.stop_test_running(node_name="airmosaic")


def run_attach_scenario(timeout=60):
    """Starts attach scenario defined in config.yaml.

    :param timeout: defaults to 60
    """
    logger_console("Starting Attach Scenario...")
    PrismaHolder.instance.ue_attach(node_name="airmosaic", timeout=timeout)


def get_matching_regexp_pattern(msg, regexp):
    """Returns matching regex expression pattern.

    :param msg: message, where regexp should be found
    :param regexp: regex expression
    :return: regexp in msg if found, None otherwise
    """
    match = re.search(regexp, msg)
    if match:
        return match.group(0)

    return None


def get_matching_scenario_log_print(logs, regexp):
    """Returns matching scenario log print.

    :param logs: list of scenario logger prints
    :param regexp: regex expression, which should be found
    :return: matching scenario log print if found, None otherwise
    """
    for log_msg in logs:
        if get_matching_regexp_pattern(msg=log_msg['message'], regexp=regexp):
            return log_msg['message']

    return None


def is_simulation_started(scenario_logs):
    """Validates if simulation started correctly and returns result.

    Required:
    ${AIRMOSAIC_SIMULATION_STARTED_REGEXP} - print saying simulation has started, Ex. Simulation started

    :param scenario_logs: list of scenario logger prints
    :return: boolean True if simulation started, False otherwise
    """
    found_print = get_matching_scenario_log_print(
        logs=scenario_logs,
        regexp=BuiltIn().get_variable_value('${AIRMOSAIC_SIMULATION_STARTED_REGEXP}')
    )
    if found_print:
        return True

    return False


def is_rnti_assigned(scenario_logs):
    """Validates if RNTI is assigned to UE and returns it.

    Required:
    ${AIRMOSAIC_RNTI_ASSIGNED_REGEXP} - print saying RNTI is assigned, Ex. RNTI assigned:

    :param scenario logs: list of scenario logger prints.
    :return: assigned RNTI if it is assigned, None otherwise
    """
    found_print = get_matching_scenario_log_print(
        logs=scenario_logs,
        regexp=BuiltIn().get_variable_value('${AIRMOSAIC_RNTI_ASSIGNED_REGEXP}')
    )
    if found_print:
        rnti = get_matching_regexp_pattern(msg=found_print, regexp=r'\d+')  # retrieve number from string
        logger.info(msg="Found RNTI assigned: {}".format(rnti), also_console=True)
        return rnti

    return None


def is_ip_addr_assigned(scenario_logs):
    """Validates if IP Address was assigned to UE (used in DL traffic) and returns it.

    Required:
    ${AIRMOSAIC_IP_ADDR_ASSIGNED_REGEXP} - print saying IP Addr was assigned, Ex. UEMNG-pdn_connected bearer

    :param scenario_logs: list of scenario logger prints
    :return: assigned IP Addr if it assigned, None otherwise
    """
    found_print = get_matching_scenario_log_print(
        logs=scenario_logs,
        regexp=BuiltIn().get_variable_value('${AIRMOSAIC_IP_ADDR_ASSIGNED_REGEXP}')
    )
    if found_print:
        ue_ip = get_matching_regexp_pattern(
            msg=found_print,
            regexp=r'((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
        )  # retrieve UE IP address from string
        logger.info(msg="Found UE IP assigned: {}".format(ue_ip), also_console=True)
        return ue_ip

    return None


def __is_ue_attach_rejected(sce_logs):
    """Validates if UE attach procedure is rejected and returns result in boolean format.

    Required:
    ${AIRMOSAIC_ATTACH_REJECTED_REGEXP} - print saying UE attach is rejected, Ex. Attach Rejected

    :param sce_logs: list of scenario logger prints
    :return: True if ue attach rejected, False otherwise
    """
    logger.info(msg="Trying to check, if UE attach procedure was rejected...")
    ue_was_rejected = get_matching_scenario_log_print(
        logs=sce_logs,
        regexp=BuiltIn().get_variable_value('${AIRMOSAIC_ATTACH_REJECTED_REGEXP}')
    )
    if ue_was_rejected:
        logger.info(msg="Issue: UE Attach Rejected...", also_console=True)
        return True

    return False


def __is_pdn_connection_rejected(sce_logs):
    """Validates if PDN connection is rejected and returns result in boolean format.

    Required:
    ${AIRMOSAIC_PDN_CONN_REJECTED_REGEXP} - print saying UE attach is rejected, Ex. PDN connenction rejected

    :param sce_logs: list of scenario logger prints
    :return: True if PDN connection rejected, False otherwise
    """
    logger.info(msg="Trying to check, if PDN Connection procedure was rejected...")
    pdn_conn_rejected = get_matching_scenario_log_print(
        logs=sce_logs,
        regexp=BuiltIn().get_variable_value('${AIRMOSAIC_PDN_CONN_REJECTED_REGEXP}')
    )
    if pdn_conn_rejected:
        logger.info(msg="Issue:PDN Connection Rejected...", also_console=True)
        return True

    return False


def is_test_scenario_invalid():
    """Validates if test scenario went invalid or it is going well. Returns result in boolean format.

    Required:
    ${AIRMOSAIC_PDN_CONN_REJECTED_REGEXP} - print saying UE attach is rejected, Ex. PDN connenction rejected
    ${AIRMOSAIC_ATTACH_REJECTED_REGEXP} - print saying UE attach is rejected, Ex. Attach Rejected

    :return: True if test scenario went invalid, False otherwise
    """
    sce_logs = get_scenario_logging()
    if __is_ue_attach_rejected(sce_logs):
        return True

    if __is_pdn_connection_rejected(sce_logs):
        return True

    return False


def retrieve_ue_ip_from_airmosaic_logs():
    """Retrieves UE IP address for DL traffic.

    Required:
    ${AIRMOSAIC_IP_ADDR_ASSIGNED_REGEXP} - print saying IP Addr was assigned, Ex. UEMNG-pdn_connected bearer

    :return: assigned UE IP address
    :raises NoIpAddressInScenarioLogsException: when cannot retrieve UE Ip addr from scenario logs
    """
    sce_logs = get_scenario_logging()
    logger_console("Trying to retrieve UE IP addr...")
    ue_ip = is_ip_addr_assigned(scenario_logs=sce_logs)
    if ue_ip:
        return ue_ip

    raise NoIpAddressInScenarioLogsException("Cannot retrieve UE IP...")


def wait_for_scenario_to_finish(retry=60, retry_interval=10):
    """Waits for scenario to finish. If test scenario went invalid tries some WA.

    Required:
    ${AIRMOSAIC_CONFIG_SID} - just filename of .sid file, Ex. TDD_2beams_Artur.sid
    ${LSU_START_REGEXP} - regex expression used to check if lsu started correctly, Ex. lsustart completed correctly
    ${CMD_LSUCLEAN_PRISMA} - command to clean current LSU logs, Ex. lsuclean
    ${CMD_LSUSTOP_PRISMA} - command to stop LSU, Ex. lsustop
    ${CELL_DISTNAME} - dist_name pointing to cell, Ex. MRBTS-75411/NRBTS-75411/NRCELL-1
    ${CELL_PHY_ID_PARAM_NAME} - physCellId parameter name in CELL_DISTNAME, Ex. [{"parameter": "physCellId"}]
    ${CMD_CELL_ID} - command used to get Cell ID print line, Ex: trcinfo -p 0-2 | grep SSS
    ${CELL_ID_REGEXP} - regexp with one format {} place, where SCF phy cell id must be placed, Ex: SYNC->SSS CELL_ID={}
    ${CMD_CELL_SYNC} - command to check current state of cell, Ex. cat /res/sdr/state/r5gnr.ue/01 | grep STATE
    ${CMD_BEAMS_COUNT_CHECK} - command that should count DBEAM_ lines in cell configuration script,
                               Ex. "cat {} | grep DBEAM_ | wc -l".format(PRISMA_START_CELL_SCRIPT_REMOTE)
    ${CELL_SYNC_REGEXP} - regex expression to check STATE_ of cell and beams,
                          Ex. "STATE_{} = SYNC", where {} should be ready to get some string in formatting

    :param retry: num of retries (defaults to 60)
    :param retry_interval: interval in seconds to next try (defaults to 10)
    :raises NoScenarioCompletionException: if scenario could not be completed after number of retries
    """
    logger_console("Waiting for scenario to finish...")

    status_print = "Scenario Completion: {}"
    status = ""

    while retry > 0:
        retry -= 1

        sce_status = get_scenario_status()
        if sce_status == "SCENARIO_COMPLETED":
            break

        if is_test_scenario_invalid():
            stop_airmosaic_test()
            wait_for_airmosaic_tstm_connection()

        logger.info(msg=status_print.format(sce_status), also_console=True)
        time.sleep(retry_interval)

    if retry == 0:
        raise NoScenarioCompletionException('Scenario could not be finished, sth is wrong...')

    logger.info(msg=status_print.format("FINISHED!"), also_console=True)


def __compose_ssh_cmd(addr, username, password, cmd):
    """Creates SSH command with sshpass and returns it.

    :param addr: hostname IP address
    :param username: username
    :param password: password
    :param cmd: command, which shall be executed
    :return: created SSH command
    """
    return "sshpass -p {} ssh {}@{} {}".format(password, username, addr, cmd)


def __compose_ul_traffic_start_cmd(addr, port, packet_size, tput, time):
    """Creates UL traffic iperf command.

    :param addr: hostname IP address, where traffic should go
    :param port: port, where traffic will run, Ex. 7070
    :param packet_size: packet size, Ex. 1400
    :param tput: throughput size, Ex. 100M
    :param time: in seconds
    :return: iperf command
    """
    return "iperf -u -i 1 -c {} -p {} -l {} -b {} -t {}".format(addr, port, packet_size, tput, time)


def start_uplink_traffic(tput, tput_time):
    """Starts UL traffic generated to prisma from UL VM.

    Required:
    ${UL_ADDR} - IP address of Uplink UTE VM
    ${PORT_TPUT} - port, where traffic will run, Ex. 7070
    ${PACKET_SIZE} - packet size, Ex. 1400

    :param tput: throughput size, Ex. 100M
    :param tput_time: in seconds
    """
    logger_console("Starting UL tput...")
    ul_start_cmd = __compose_ul_traffic_start_cmd(addr=BuiltIn().get_variable_value('${UL_ADDR}'),
                                                  port=BuiltIn().get_variable_value('${PORT_TPUT}'),
                                                  packet_size=BuiltIn().get_variable_value('${PACKET_SIZE}'),
                                                  tput=tput,
                                                  time=tput_time)
    ul_host_details = BuiltIn().get_variable_value('${tl}').ues[0].iperf_details.ssh_connection_details
    ssh_ul_start_cmd = __compose_ssh_cmd(addr=ul_host_details.addr,
                                         username=ul_host_details.username,
                                         password=ul_host_details.password,
                                         cmd=ul_start_cmd)

    logger.info(msg="Running cmd: {}".format(ssh_ul_start_cmd), also_console=True)
    PrismaHolder.ul_tput = subprocess.Popen(shlex.split(ssh_ul_start_cmd), stdout=subprocess.PIPE)


def stop_uplink_traffic():
    """Stops uplink traffic and resets object instance.
    """
    logger_console("Killing UL tput...")
    PrismaHolder.ul_tput.kill()
    PrismaHolder.ul_tput = None


def __compose_dl_traffic_start_cmd(addr, port, packet_size, tput, time, window_size):
    """Creates DL traffic iperf command.

    :param addr: hostname IP address, where traffic should go
    :param port: port, where traffic will run, Ex. 7070
    :param packet_size: packet size, Ex. 1400
    :param tput: throughput size, Ex. 100M
    :param time: in seconds
    :param window_size: window size, Ex. 4M
    :return: iperf command
    """
    return "iperf -u -i 1 -c {} -p {} -l {} -b {} -t {} -w {}".format(addr, port, packet_size, tput, time, window_size)


def start_downlink_traffic(tput, tput_time):
    """Starts DL traffic generated to prisma from Real Core. Need to retrieve UE IP address
    from scenario logs.

    Required:
    ${AIRMOSAIC_IP_ADDR_ASSIGNED_REGEXP} - print saying IP Addr was assigned, Ex. UEMNG-pdn_connected bearer
    ${PORT_TPUT} - port, where traffic will run, Ex. 7070
    ${PACKET_SIZE} - packet size, Ex. 1400
    ${WINDOW_SIZE} - window size, Ex. 4M
    ${APP_SERVER_ADDR} - Real Core App Server IP address
    ${APP_SERVER_USERNAME} - Real Core App Server username
    ${APP_SERVER_PASSWORD} - Real Core App Server password

    :param tput: throughput size, Ex. 100M
    :param tput_time: in seconds
    """
    ue_ip = retrieve_ue_ip_from_airmosaic_logs()

    logger_console("Starting DL tput...")
    dl_start_cmd = __compose_dl_traffic_start_cmd(addr=ue_ip,
                                                  port=BuiltIn().get_variable_value('${PORT_TPUT}'),
                                                  packet_size=BuiltIn().get_variable_value('${PACKET_SIZE}'),
                                                  tput=tput,
                                                  time=tput_time,
                                                  window_size=BuiltIn().get_variable_value('${WINDOW_SIZE}'))
    ssh_dl_start_cmd = __compose_ssh_cmd(addr=BuiltIn().get_variable_value('${APP_SERVER_ADDR}'),
                                         username=BuiltIn().get_variable_value('${APP_SERVER_USERNAME}'),
                                         password=BuiltIn().get_variable_value('${APP_SERVER_PASSWORD}'),
                                         cmd=dl_start_cmd)

    logger.info(msg="Running cmd: {}".format(ssh_dl_start_cmd), also_console=True)
    PrismaHolder.dl_tput = subprocess.Popen(shlex.split(ssh_dl_start_cmd), stdout=subprocess.PIPE)


def stop_downlink_traffic():
    """Stops downlink traffic and resets object instance.
    """
    logger_console("Killing DL tput...")
    PrismaHolder.dl_tput.kill()
    PrismaHolder.dl_tput = None


def get_airmosaic_counters():
    """Returns airmosaic counters.
    """
    return PrismaHolder.instance.get_counters()


def print_airmosaic_counters():
    """Prints airmosaic counters.
    """
    counters = get_airmosaic_counters()
    logger.info(msg="Counters: {}".format(counters), also_console=True)
