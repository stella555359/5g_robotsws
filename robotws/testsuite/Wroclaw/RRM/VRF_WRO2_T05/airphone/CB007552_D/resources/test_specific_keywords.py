from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import SyslogMessageMatcher as SM
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.resources.log.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pm
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as ue_utils
import testsuite.Wroclaw.RRM.resources.common.file_helper as fh
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog as btslog
import time

mrbts_id = tl.tl.gnbs[0].instance_id
nrbts_id = tl.tl.gnbs[0].global_bts_id
bts_prefix = "MRBTS-" + str(mrbts_id) + "/NRBTS-" + str(nrbts_id)
new_params_trunk = {'actPdcchCceFragmentControl': False,
                    'actUpperThrAckNackFiltering': False,
                    'actUpperThrAckNackHrFiltering': False,
                    'pdcchResourcePreference': 'peakRate'}
new_params = {'actPdcchCceFragmentControl': False,
              'pdcchResourcePreference': 'peakRate'}
scf_objects_params = [
    {'parameterName': 'cellBwpList', 'operation': 'update', 'value':
        [
            {'bwpDN': bts_prefix + '/BWP_PROFILE-35',
             'cellBwpId': 0},
            {'bwpDN': bts_prefix + '/BWP_PROFILE-37',
             'cellBwpId': 1},
            {'bwpDN': bts_prefix + '/BWP_PROFILE-33',
             'cellBwpId': 2},
        ]},
]


def verify_bwp_profiles(cell_ids, scf_params=None):
    if scf_params is None:
        scf_params = scf_objects_params
    blog("starting_bwp_verification")
    with AdminApi() as web_api:
        _connection = web_api.connect_to()
        release = web_api.get_sw_release_name()
        if release > 'SBTS23R4':
            for val in scf_params[0]['value']:
                (val.update(new_params_trunk))
        elif release == 'SBTS23R4':
            for val in scf_params[0]['value']:
                (val.update(new_params))
        _dist_name = bts_prefix + '/NRCELL-'
        _num_of_cells = len(web_api.get_cells_info())
        for cell_id in cell_ids:
            web_api.perform_object_recommissioning(dist_name=_dist_name + str(cell_id),
                                                   parameter=scf_params,
                                                   operation='update',
                                                   skip_parameter_relation_errors=True,
                                                   should_activate=True)


def attach_UEs(num_of_ues):
    ue_utils.require_ues(num_of_ues)
    ue_utils.detach_ues(num_of_ues)
    ue_utils.attach_ues(num_of_ues)


def attach_UE(num_of_ues, capabilities='REAL_UE'):
    ue_utils.require_ues(num_of_ues, capabilities)
    ue_utils.detach_ues(num_of_ues)
    ue_utils.attach_ues(num_of_ues)


def detach_UEs(num_of_ues):
    ue_utils.detach_ues(num_of_ues)


def detach_UE(num_of_ues):
    ue_utils.detach_ues(num_of_ues)


def start_and_verify_throughput(num_of_ues, duration='240s', parallel_streams='1'):
    ue_utils.start_ul_data_transfer_on_ues(num_of_ues, duration, parallel_streams=parallel_streams)
    time.sleep(30)
    ue_utils.check_ul_transfer_is_alive(num_of_ues)
    ue_utils.verify_average_ul_throughput(num_of_ues, tput_min='10Mbits/sec')


def verify_tput(num_of_ues):
    ue_utils.check_ul_transfer_is_alive(num_of_ues)
    ue_utils.verify_average_ul_throughput(num_of_ues, tput_min='10Mbits/sec')


def check_attach_in_bts_log(bts_log_dir):
    syslog = fh.get_files_filepaths(bts_log_dir, pattern='*.LOG')
    check_attach_related_msg_in_bts_log(syslog)


def check_attach_to_smallBwp_in_bts_log(bts_log_dir):
    print("step check")
    syslog = fh.get_files_filepaths(bts_log_dir, pattern='*.LOG')
    check_attach_related_msg_in_bts_log_for_smallBwp(syslog)


def check_handover_in_bts_log(bts_log_dir):
    syslog = fh.get_files_filepaths(bts_log_dir, pattern='*.LOG')
    check_handover_related_msg_in_bts_log(syslog)


def check_reestab_largebwp_in_bts_log(bts_log_dir):
    syslog = fh.get_files_filepaths(bts_log_dir, pattern='*.LOG')
    check_attach_related_msg_in_bts_log_CNI78446_large_profile(syslog)


def check_reestab_performance_in_bts_log(bts_log_dir):
    syslog = fh.get_files_filepaths(bts_log_dir, pattern='*.LOG')
    check_Reestablishment_viaRRCSetup_in_bts_log(syslog)


def check_attach_related_msg_in_bts_log(bts_log_file):
    with LogHelper() as lh:
        finder = lh.add_syslog(bts_log_file)

        msg1 = finder.find_next_anew(
            SM('*selectedBwpprofile ID:33*')
        )
        msg2 = finder.find_next_anew(
            SM('*selectedBwpprofile ID:37*')
        )
        assert msg1, 'Proper CellBwpId (2) not found'   # selectedBwpprofile ID:33
        assert msg2, 'Proper CellBwpId (1) not found'


def check_attach_related_msg_in_bts_log_for_smallBwp(bts_log_file):
    with LogHelper() as lh:
        finder = lh.add_syslog(bts_log_file)

        msg1 = finder.find_next_anew(
            SM('*selectedBwpprofile ID:33*')
        )
        print("Attached to small BWP")

        assert msg1, 'Proper CellBwpId (2) not found'


def check_attach_related_msg_in_bts_log_CNI78446_large_profile(bts_log_file):
    with LogHelper() as lh:
        finder = lh.add_syslog(bts_log_file)

        msg1 = finder.find_next_anew(
            SM('*selectedBwpprofile ID:35*')

        )
        msg2 = finder.find_next_anew(
            SM('*selectedBwpprofile ID:37*')
        )

        assert msg1, 'Proper CellBwpId (0) not found'  # selectedBwpprofile ID:33
        assert msg2, 'Proper CellBwpId (1) not found'


def check_Reestablishment_viaRRCSetup_in_bts_log(bts_log_file):
    with LogHelper() as lh:
        finder = lh.add_syslog(bts_log_file)

        msg1 = finder.find_next_anew(
            SM('*RrcReestablishmentRequest*')
        )
        msg2 = finder.find_next_anew(
            SM('*Fallback-type Reestablish selected for PhyCellId*')
        )
        # msg3 = finder.find_next_anew(
        #     SM('*ueAddCause:RRCREESTABLISHMENT*')
        # )
        # msg4 = finder.find_next_anew(
        #     SM('*ueAddCause:RRCREESTABLISHMENT*')
        # )
        print("Reestablishment confirmed")
        assert msg1, 'RrcReestablishmentRequest not found'
        assert msg2, 'Fallback-type Reestablish selected not found'
        # assert msg3, 'DL: UE setup*ueAddCause:RRCREESTABLISHMENT not found'
        # assert msg4, 'UL: UE setup(.*)ueAddCause:RRCREESTABLISHMENT not found'


def check_handover_related_msg_in_bts_log(bts_log_file):
    with LogHelper() as lh:
        finder = lh.add_syslog(bts_log_file)

        msg1 = finder.find_next_anew(
            SM('*Successfull HO*')
        )

        assert msg1, "Handover not triggered"


def verify_pm_counters(pm_counters_list):
    time.sleep(320)
    pm_counters_path = pm.collect_counters()
    pm_counters = pm.get_relevant_pm_counters(pi_dir=pm_counters_path, counter_ids=pm_counters_list)
    blog(str(pm_counters))
    for counter in pm_counters.values():
        incremented = False
        for cell, counter_value in iter(counter.items()):
            incr = [i for i in counter_value if i > 0]
            if incr:
                incremented = True
        assert incremented, 'PM Counters not incremented'


def perform_handover():
    attenuator = Attenuator()
    attenuator.gradually_increase_attenuation(init_value=0, max_value=14, step=2, interval=0.2, ports=[13, 14, 15, 16])
    attenuator.gradually_decrease_attenuation(init_value=90, min_value=0, step=10, interval=0.2, ports=[9, 10, 11, 12])
    time.sleep(15)      # handover should be performed here
    attenuator.gradually_increase_attenuation(init_value=10, max_value=90, step=2, interval=0.2,
                                              ports=[13, 14, 15, 16])
