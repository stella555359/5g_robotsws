import random
import time
import os
from taf.hw.pdu import pdu
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.alarms import wait_for_fault, wait_for_fault_clear
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import \
    wait_for_ru, wait_for_onair, wait_for_bbmod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from multiprocessing import Process
from variables_hr import RMODS, HR_SYSLOG_REGEX, UES_LIST, MAX_RESET_TIME, CELLS, CPLANE_CONTAINERS
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import SyslogMessageMatcher, PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.common.file_helper import get_files_filepaths
from testsuite.Wroclaw.RRM.resources.log.log import blog
from aashell_commands import get_cpnb_resources_info, get_cpnrt_resources_info, get_cprt_resources_info
from NgLinkManager import NgLinkManager
import taf.sbts.oam.coam.admin as sbts
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.HR.resources.asik_commands import AsikConnection
from taf.sw.syslog import syslog as taf_syslog
ue_lib = BuiltIn().get_library_instance('ute_ue')


taf_syslog = taf_syslog()
SYSLOG_OUTPUT = os.path.join(get_robot_output_dir(), 'hr_syslog')


def reset_rmod(rmod):
    model = RMODS[rmod]['pdu'].vendor
    port = RMODS[rmod]['port']
    version = RMODS[rmod]['pdu'].version
    address = RMODS[rmod]['pdu'].addr

    pd = pdu().setup_pdu(model=model, host=address, version=version)
    logger.console("\n[{}] Resetting port: {} on PDU: {} ({})".format(rmod, port, address, model))
    pd.reset([port], time_interval=2)


def attach_next_ue_and_reset_rmod_in_parallel(rmod):
    def random_float():
        return round(random.uniform(1, 1.8), 1)
    p1 = Process(target=ue_lib.attach_ue, kwargs={'ue_alias': "UE_2", 'timeout': 20})
    p2 = Process(target=reset_rmod, kwargs={'rmod': rmod})
    p1.start()
    time.sleep(random_float())
    p2.start()
    logger.debug('Next ue attach process started!')
    logger.debug('Reset rmod {} process started'.format(rmod))
    t0 = time.time()
    p1.join()
    p2.join()
    return t0


def attach_next_ue_and_block_ng_link(nglink_manager):
    def random_float():
        return round(random.uniform(1, 1.5), 1)

    p1 = Process(target=ue_lib.attach_ue, kwargs={'ue_alias': "UE_2", 'timeout': 20})
    p2 = Process(target=nglink_manager.block_ng_link)
    p1.start()
    time.sleep(random_float())
    p2.start()
    logger.debug('Next ue attach process started!')

    logger.debug('Ng link blocked!')
    t0 = time.time()
    p1.join()
    p2.join()
    return t0


def admin_setup_and_teardown(func):
    def inner_func(*args, **kwargs):
        adm_api = sbts.admin()
        adm_conn = adm_api.connect_to()
        try:
            func(adm_conn, *args, **kwargs)
        finally:
            adm_api.teardown_admin()

    return inner_func


@admin_setup_and_teardown
def attach_next_ue_and_lock_cell_in_parallel(adm_conn, cell):
    def random_float():
        return round(random.uniform(1, 1.8), 1)

    p1 = Process(target=ue_lib.attach_ue, kwargs={'ue_alias': "UE_2", 'timeout': 20})
    p2 = Process(target=adm_conn.lock, args=[cell], kwargs={'timeout': 60})
    p1.start()
    time.sleep(random_float())
    p2.start()
    logger.debug('Next ue attach process started!')
    logger.debug('lock unlock cell {} process started'.format(cell))
    p1.join()
    p2.join()
    detach_all_ues()
    adm_conn.unlock(cell, timeout=60)


def test_on_rmod(rmod):
    log = L1L2()
    syslog_alias = 'reset_rmod'
    logger.info("Performing test with rmod: {}".format(rmod))
    taf_syslog.start_syslog(log_dir=SYSLOG_OUTPUT, log_name='SYSLOG_reset_rmod.LOG', alias=syslog_alias)
    set_attenuation_for_test_with_rmod(rmod)
    ue_lib.attach_ue("UE_1")
    t0 = attach_next_ue_and_reset_rmod_in_parallel(rmod)
    detach_all_ues()
    wait_for_ru()
    reset_time = int(time.time() - t0)
    time.sleep(30)
    taf_syslog.collect_syslog_results(alias=syslog_alias)
    log.start_gnbmirroring(filename='l1l2', filtering='off', capturing_time_seconds='2')
    time.sleep(2)
    l1l2_log = log.stop_gnbmirroring_and_download_logs()
    check_l1l2_against_hanging_resources(l1l2_log)
    check_syslog_against_hanging_resources(SYSLOG_OUTPUT, alias=syslog_alias)
    check_cplane_against_hanging_resources()
    ue_lib.attach_ue("UE_1")
    ue_lib.attach_ue("UE_2")
    ue_lib.detach_ue("UE_1")
    ue_lib.detach_ue("UE_2")
    logger.info("Reset time: {}".format(reset_time), also_console=True)
    assert reset_time < MAX_RESET_TIME, 'Maximum reset time exceeded!'


def test_on_all_cells_with_locking(cell):
    log = L1L2()
    syslog_alias = 'cell_lock'
    logger.info("Performing test with cell: {}".format(cell))
    taf_syslog.start_syslog(log_dir=SYSLOG_OUTPUT, log_name='SYSLOG_cell_lock.LOG', alias=syslog_alias)
    set_attenuation_for_test_with_rmod(CELLS[cell]['rmod'])
    ue_lib.attach_ue("UE_1")
    attach_next_ue_and_lock_cell_in_parallel(CELLS[cell]['dist_name'])
    taf_syslog.collect_syslog_results(alias=syslog_alias)
    log.start_gnbmirroring(filename='l1l2', filtering='off', capturing_time_seconds='2')
    time.sleep(2)
    l1l2_log = log.stop_gnbmirroring_and_download_logs()
    check_l1l2_against_hanging_resources(l1l2_log)
    check_syslog_against_hanging_resources(SYSLOG_OUTPUT, alias=syslog_alias)
    check_cplane_against_hanging_resources()
    ue_lib.attach_ue("UE_1")
    ue_lib.attach_ue("UE_2")
    ue_lib.detach_ue("UE_1")
    ue_lib.detach_ue("UE_2")


def check_l1l2_against_hanging_resources(log_filepath):
    finder = bip_finder(log_filepath, shark_filter='3gpp.subcellid && !(3gpp.rnti == 65535)')
    msgs = [
        pm('PdschSendReq*', name_line_pattern='empty'),
        pm('PuschReceiveReq*', name_line_pattern='empty')
    ]
    found_msgs = finder.find_all(msgs, forget_matcher_on_hit=True)
    blog(found_msgs)
    assert not found_msgs, "At least one message was found, but should not exist: {}" \
        .format(','.join(found_msgs.keys()))


def _check_cprt_resources():
    logger.info("Checking CPRT resources", also_console=True)
    cprt_resources = get_cprt_resources_info()

    cprt_allocated_num_sr = [int(x["sr"]["allocatedNumSR"]) for x in cprt_resources["cellList"]["cellInfo"]]
    validate_resource_value(cprt_allocated_num_sr)

    cprt_ue_ids_per_cell = [x["ueIds"] for x in cprt_resources["cellList"]["cellInfo"]]
    validate_resource_value(cprt_ue_ids_per_cell)

    cprt_active_ues_per_cell = [int(x["activeUEsPerCell"]) for x in cprt_resources["cellList"]["cellInfo"]]
    validate_resource_value(cprt_active_ues_per_cell)

    cprt_current_ue_number = int(cprt_resources["currentUeNumber"])
    validate_resource_value(cprt_current_ue_number)


def _check_cpnrt_resources():
    logger.info("Checking CPNRT resources", also_console=True)
    cpnrt_resources = get_cpnrt_resources_info()
    cpnrt_active_ues = int(cpnrt_resources["activeUes"])
    cpnrt_ue_identifiers = cpnrt_resources["ueIdList"]["ueIdentifiers"]
    cpnrt_allocated_bearers = [int(x["allocatedNumOfBearers"]) for x in cpnrt_resources["l2NrtPoolList"]]
    cpnrt_allocated_pdu_sessions = [int(x["allocatedNumOfPduSessions"]) for x in cpnrt_resources["l2NrtPoolList"]]

    validate_resource_value(cpnrt_active_ues)
    validate_resource_value(cpnrt_ue_identifiers)
    validate_resource_value(cpnrt_allocated_bearers)
    validate_resource_value(cpnrt_allocated_pdu_sessions)


def _check_cpnb_resources():
    logger.info("Checking CPNB resources", also_console=True)
    cpnb_resources = get_cpnb_resources_info()

    cpnb_admitted_nsa_users = int(cpnb_resources["cpCellGetResourceUsageResp"][0]["admittedNsaUsers"])
    validate_resource_value(cpnb_admitted_nsa_users)

    cpnb_admitted_sa_users = int(cpnb_resources["cpCellGetResourceUsageResp"][0]["admittedSaUsers"])
    validate_resource_value(cpnb_admitted_sa_users)

    for cell in cpnb_resources["cpCellGetResourceUsageResp"][0]["resources"]["cells"]:
        for counter, value in cell["admittedSaUsersPerCell"].items():
            validate_resource_value(value)
        for counter, value in cell["admittedNsaUsersPerCell"].items():
            validate_resource_value(value)

    cpue_number_of_active_ue_sa = [int(x["numberOfActiveUeSa"]) for x in cpnb_resources["cpUeGetResourceUsageResp"]]
    validate_resource_value(cpue_number_of_active_ue_sa)

    cpue_number_of_active_use_nsa = [int(x["numberOfActiveUeNsa"]) for x in cpnb_resources["cpUeGetResourceUsageResp"]]
    validate_resource_value(cpue_number_of_active_use_nsa)


def check_cplane_against_hanging_resources():
    failed = 0
    try:
        _check_cpnb_resources()
    except AssertionError:
        failed += 1
        logger.error("CPNB resources contains active ues!")
    try:
        _check_cprt_resources()
    except AssertionError:
        failed += 1
        logger.error("CPRT resources contains active ues!")
    try:
        _check_cpnrt_resources()
    except AssertionError:
        failed += 1
        logger.error("CPNRT resources contains active ues!")
    if failed:
        raise RuntimeError("Some CPLANE resources contains active ues!")


def check_syslog_against_hanging_resources(syslog_dir, alias):
    syslog = syslog_helper(os.path.join(syslog_dir, ''), alias)
    msgs = [SyslogMessageMatcher(f'*{msg}*') for msg in HR_SYSLOG_REGEX]
    found_msgs = syslog.find_all(msgs)

    assert not found_msgs, "At least one message was found, but should not exist: {}" \
        .format(','.join(found_msgs.keys()))


def set_attenuation_for_test_with_rmod(rmod):
    """
    :param att: Attenuator object
    :param rmod:
    :return:
    """
    att = BuiltIn().get_library_instance('attenuator_keywords').Attenuator()
    if not att.is_initialised():
        att.initialise_attenuator()
    try:
        for r in RMODS.keys():
            att.set_attenuation('90db', RMODS[r]['att_ports'])
        att.set_attenuation('0db', RMODS[rmod]['att_ports'])
    finally:
        att.release_attenuator()


def bip_finder(pcap_file, shark_filter=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=shark_filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    return finder


def syslog_helper(syslog_dir, alias):
    with LogHelper() as lh:
        return lh.add_syslog(get_files_filepaths(syslog_dir, pattern=f'SYSLOG_{alias}*.LOG'))


def detach_all_ues():
    for ue in UES_LIST:
        ue_lib.detach_ue(ue)


def validate_resource_value(value):
    if value and isinstance(value, list):
        if isinstance(value[0], list):
            assert value == [list() for _ in range(len(value))]
        else:
            assert value == [0] * len(value)
    else:
        assert not value


def perform_test_with_block_ng_link():
    nglink_manager = NgLinkManager()
    log = L1L2()
    syslog_alias = 'ng_link'
    taf_syslog.start_syslog(log_dir=SYSLOG_OUTPUT, log_name='SYSLOG_ng_link.LOG', alias=syslog_alias)
    ue_lib.attach_ue("UE_1")
    attach_next_ue_and_block_ng_link(nglink_manager)
    detach_all_ues()
    wait_for_fault('7304')
    nglink_manager.unblock_ng_link()
    wait_for_fault_clear('7304')
    taf_syslog.collect_syslog_results(alias=syslog_alias)
    log.start_gnbmirroring(filename='l1l2', filtering='off', capturing_time_seconds='2')
    time.sleep(2)
    l1l2_log = log.stop_gnbmirroring_and_download_logs()
    check_l1l2_against_hanging_resources(l1l2_log)
    check_syslog_against_hanging_resources(SYSLOG_OUTPUT, alias=syslog_alias)
    check_cplane_against_hanging_resources()
    ue_lib.attach_ue("UE_1")
    ue_lib.attach_ue("UE_2")
    ue_lib.detach_ue("UE_1")
    ue_lib.detach_ue("UE_2")


def trigger_cplane_crash(container):
    command = "pkill -11 -f '/opt/CCS/CCSDaemonExe --startup=nid={}'"
    with AsikConnection() as asik:
        if CPLANE_CONTAINERS.get(container)[0] == 'slave':
            return asik.execute_command_on_slave(command.format(CPLANE_CONTAINERS.get(container)[1]))
        return asik.execute_command_on_abil(command.format(CPLANE_CONTAINERS.get(container)[1]))


def attach_next_ue_and_trigger_cplane_crash(container):
    def random_float():
        return round(random.uniform(1, 1.5), 1)

    p1 = Process(target=ue_lib.attach_ue, kwargs={'ue_alias': "UE_2", 'timeout': 20})
    p2 = Process(target=trigger_cplane_crash, kwargs={'container': container})
    p1.start()
    time.sleep(random_float())
    p2.start()
    logger.debug('Next ue attach process started!')

    logger.debug('Cplane process {} killed!'.format(container))
    t0 = time.time()
    p1.join()
    p2.join()
    return t0


def perform_test_with_cplane_crash(container):
    log = L1L2()
    syslog_alias = 'cplane_crash'
    taf_syslog.start_syslog(log_dir=SYSLOG_OUTPUT, log_name='SYSLOG_cplane_crash.LOG', alias=syslog_alias)
    ue_lib.attach_ue("UE_1")
    attach_next_ue_and_trigger_cplane_crash(container)
    detach_all_ues()
    wait_for_bbmod()
    wait_for_onair()
    taf_syslog.collect_syslog_results(alias=syslog_alias)
    log.start_gnbmirroring(filename='l1l2', filtering='off', capturing_time_seconds='2')
    time.sleep(2)
    l1l2_log = log.stop_gnbmirroring_and_download_logs()
    check_l1l2_against_hanging_resources(l1l2_log)
    check_syslog_against_hanging_resources(SYSLOG_OUTPUT, alias=syslog_alias)
    check_cplane_against_hanging_resources()
    ue_lib.attach_ue("UE_1")
    ue_lib.attach_ue("UE_2")
    ue_lib.detach_ue("UE_1")
    ue_lib.detach_ue("UE_2")
