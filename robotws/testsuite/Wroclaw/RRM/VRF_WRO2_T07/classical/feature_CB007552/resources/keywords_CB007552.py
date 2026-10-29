from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB007552.resources.test_specific_keywords import \
    verify_bwp_for_specific_release, verify_feature_parameter, attach_UEs, detach_UEs, verify_attach_with_correct_bwp, \
    start_and_verify_throughput, perform_double_handover
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog as btslog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator


num_of_ues = 2
carrier_bandwidths = [106, 160]


@logged_keyword
def test_setup_CB007552():
    attenuator = Attenuator()
    attenuator.nullify_attenuation_on_all_ports()
    attenuator.set_attenuation(value_string='80', ports=[1, 3])
    attenuator.release_attenuator()
    btslog.start_btslog_on_local_machine()
    verify_feature_parameter()
    verify_bwp_for_specific_release()


@logged_keyword
def test_teardown_CB007552():
    btslog.stop_and_collect_btslog()
    detach_UEs(num_of_ues)
    attenuator = Attenuator()
    attenuator.nullify_attenuation_on_all_ports()
    attenuator.release_attenuator()


@logged_keyword
def CB007552_5G_C_8_Management_of_UE_Bandwidth_Capabilities_FDD_30MHz_Regression_bundle_TC():
    attach_logs = attach_UEs(num_of_ues)
    verify_attach_with_correct_bwp(attach_logs, carrier_bandwidths)
    start_and_verify_throughput(num_of_ues)
    perform_double_handover(num_of_ues)
