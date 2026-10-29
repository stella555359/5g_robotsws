from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.CB007552_D.resources.test_specific_keywords import (
    verify_bwp_profiles,
    check_attach_in_bts_log, check_attach_related_msg_in_bts_log_for_smallBwp, attach_UEs, attach_UE, detach_UEs,
    detach_UE, start_and_verify_throughput, verify_tput, verify_pm_counters,
    check_handover_in_bts_log, check_attach_to_smallBwp_in_bts_log,
    check_attach_related_msg_in_bts_log_CNI78446_large_profile, check_Reestablishment_viaRRCSetup_in_bts_log,
    check_reestab_largebwp_in_bts_log, check_reestab_performance_in_bts_log
    )
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog as btslog
from testsuite.Wroclaw.RRM.resources.log.log import blog
import time


BTS_LOGS_DIR = "/tmp/btslog2/"

num_of_ues = 2

pm_counters_list = ["M55166C00001", "M55166C00003", "M55139C02501", "M55166C00002", "M55166C00004", "M55139C02502"]
pm_counters_list_for_smallBwp = ["M55166C00001", "M55166C00003", "M55139C02501"]
pm_counters_list_reestab = ["M55166C00002", "M55166C00004", "M55139C02502", "M55124C00502", "M55124C00505"]
pm_counters_list_for_largeBwp = ["M55166C00002", "M55166C00004", "M55139C02502"]
cell_ids = [5161, 5162]


@logged_keyword
def test_setup_CB007552():
    attenuator = Attenuator()
    attenuator.nullify_attenuation_on_all_ports()
    attenuator.release_attenuator()
    btslog.start_btslog_on_local_machine()
    verify_bwp_profiles(cell_ids)


@logged_keyword
def test_teardown_CB007552():
    attenuator = Attenuator()
    attenuator.nullify_attenuation_on_all_ports()
    attenuator.release_attenuator()


@logged_keyword
def teardown_CB007552_D():
    btslog.stop_and_collect_btslog()
    check_attach_in_bts_log(BTS_LOGS_DIR)
    verify_pm_counters(pm_counters_list)
    detach_UEs(num_of_ues)


@logged_keyword
def CB007552_D():
    attach_UEs(num_of_ues)
    start_and_verify_throughput(num_of_ues)


@logged_keyword
def CB007552_D_2():
    attenuator = Attenuator()
    attenuator.set_attenuation(value_string="90", ports=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 17, 18, 19, 20, 21,
                                                         22, 23, 24])
    attenuator.set_attenuation(value_string="0", ports=[13, 14, 15, 16])
    attach_UE(1, 'MTK_UE')
    start_and_verify_throughput(1, duration='150s')
    attenuator.gradually_increase_attenuation(init_value=0, max_value=14, step=2, interval=0.2, ports=[13, 14, 15, 16])
    attenuator.gradually_decrease_attenuation(init_value=90, min_value=0, step=10, interval=0.2, ports=[9, 10, 11, 12])
    time.sleep(15)      # handover should be performed here
    attenuator.gradually_increase_attenuation(init_value=10, max_value=90, step=2, interval=0.2,
                                              ports=[13, 14, 15, 16])
    verify_tput(1)


@logged_keyword
def teardown_CB007552_D_2():
    btslog.stop_and_collect_btslog()
    time.sleep(5)
    check_attach_to_smallBwp_in_bts_log(BTS_LOGS_DIR)
    time.sleep(8)
    check_handover_in_bts_log(BTS_LOGS_DIR)
    verify_pm_counters(pm_counters_list_for_smallBwp)
    detach_UE(1)


@logged_keyword
def CB007552_D_3():
    attenuator = Attenuator()
    attenuator.set_attenuation(value_string="90", ports=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 17, 18, 19, 20, 21,
                                                         22, 23, 24])
    attenuator.set_attenuation(value_string="0", ports=[13, 14, 15, 16])
    attach_UE(1, 'SA_QUALCOMM_SDX60')
    start_and_verify_throughput(1, duration='200s')
    blog("Performing reestablishment")
    time.sleep(15)
    attenuator.set_attenuation(value_string="90", ports=[13, 14, 15, 16])
    time.sleep(2)
    attenuator.set_attenuation(value_string="0", ports=[13, 14, 15, 16])
    time.sleep(10)
    attenuator.set_attenuation(value_string="90", ports=[13, 14, 15, 16])
    time.sleep(2)
    attenuator.set_attenuation(value_string="0", ports=[13, 14, 15, 16])
    time.sleep(10)
    attenuator.set_attenuation(value_string="90", ports=[13, 14, 15, 16])
    time.sleep(2)
    attenuator.set_attenuation(value_string="0", ports=[13, 14, 15, 16])
    time.sleep(10)
    verify_tput(1)
    blog("Verifying data traffic after reestablishment")


@logged_keyword
def teardown_CB007552_D_3():
    btslog.stop_and_collect_btslog()
    time.sleep(5)
    check_reestab_largebwp_in_bts_log(BTS_LOGS_DIR)
    time.sleep(8)
    check_reestab_performance_in_bts_log(BTS_LOGS_DIR)
    verify_pm_counters(pm_counters_list_reestab)
    detach_UE(1)


@logged_keyword
def CB007552_D_4():
    attenuator = Attenuator()
    attenuator.set_attenuation(value_string="90", ports=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 17, 18, 19, 20, 21,
                                                         22, 23, 24])
    time.sleep(5)
    attenuator.set_attenuation(value_string="0", ports=[13, 14, 15, 16])
    time.sleep(5)
    attach_UE(1, 'SA_QUALCOMM_SDX60')
    start_and_verify_throughput(1, duration='150s')
    time.sleep(12)
    attenuator.set_attenuation(value_string="14", ports=[13, 14, 15, 16])
    time.sleep(10)
    attenuator.set_attenuation(value_string="0", ports=[9, 10, 11, 12])
    time.sleep(5)
    verify_tput(1)
    attenuator.set_attenuation(value_string="90", ports=[13, 14, 15, 16])


@logged_keyword
def teardown_CB007552_D_4():
    btslog.stop_and_collect_btslog()
    time.sleep(5)
    check_reestab_largebwp_in_bts_log(BTS_LOGS_DIR)
    time.sleep(8)
    check_handover_in_bts_log(BTS_LOGS_DIR)
    verify_pm_counters(pm_counters_list_for_largeBwp)
    detach_UE(1)
