import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import get_filepaths
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher as PM
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import SyslogMessageMatcher as SM
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pmc
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi, assign_release_version
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog as btslog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.update_helpers import get_sw_version
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation as tp
from taf.sbts.oam.coam.admin.utils.delta import DeltaInterface


scf_counter_period_parameters_to_set = {'miNrCellAvailability': '5min',
                                        'miNrCellUtilization': '5min',
                                        'miNrNGCC': '5min',
                                        'miNrNgInterface': '5min',
                                        'miNrNgUReport': '5min'}

MRBTS_ID = tl.tl.gnbs[0].instance_id
NRBTS_ID = tl.tl.gnbs[0].global_bts_id


cells_dist_names_to_lock = [u'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-' + str(NRBTS_ID) + '/NRCELL_R-2',
                            u'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-' + str(NRBTS_ID) + '/NRCELL_R-3']


ds = DeltaStore()
taf_ue = rue_utils.get_library_instance('taf.ue')
admin_utils = AdminUtils()


@logged_keyword
def starting_btslog(which_time):
    log_name = 'the_{}_call_btslog'.format(which_time)
    btslog.start_btslog_on_local_machine(log_name)


@logged_keyword
def collecting_btslog(which_time, log_path):
    log_name = 'the_{}_call_btslog'.format(which_time)
    btslog.stop_and_collect_btslog(log_name, target_dir='{}/source_logs_dir'.format(log_path))


@logged_keyword
def get_my_current_scf():
    bts_host = '192.168.255.1'
    admin_utils = AdminUtils(bts_host=bts_host)
    scf_file = admin_utils.download_current_scf(file_name='new_scf.xml')
    return scf_file


@logged_keyword
def disable_vonr_on_gnb_for_fallback():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'actVoNR', false)
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'actVoNR', false)
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'actVoNR', false)
    disable_vonr_ds_file = ds.collect_delta_store()
    blog('Delta store file (disable_vonr_ds_file): {}'.format(disable_vonr_ds_file))
    ds.perform_delta_recommissioning(delta_file=disable_vonr_ds_file)


@logged_keyword
def enable_vonr_on_gnb_for_fallback():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'actVoNR', true)
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'actVoNR', true)
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'actVoNR', true)
    enable_vonr_ds_file = ds.collect_delta_store()
    blog('Delta store file (enable_vonr_ds_file): {}'.format(enable_vonr_ds_file))
    ds.perform_delta_recommissioning(delta_file=enable_vonr_ds_file)


@logged_keyword
def set_counter_period_parameters_for_all(params_to_check=scf_counter_period_parameters_to_set):
    ds.initialise_delta_store()
    for param, value in params_to_check.items():
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRPMRNL-1'.format(MRBTS_ID, NRBTS_ID), param, value)
    counter_periods_file = ds.collect_delta_store()
    blog('Delta store file (counter_periods_file): {}'.format(counter_periods_file))
    ds.perform_delta_recommissioning(delta_file=counter_periods_file)


@logged_keyword
def set_parameters_for_part_1():
    ds.initialise_delta_store()
    if assign_release_version() not in ['SBTS22R2', 'SBTS22R3']:
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actNrpmqapProfiles', 'true')
        ds.add_managed_object_and_parameter_to_delta(
            'MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-1'.format(MRBTS_ID, NRBTS_ID), cfg5qiRange='1', cfgProfType='SA')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-2'.format(MRBTS_ID, NRBTS_ID), cfg5qiRange='5', cfgProfType='SA')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-3'.format(MRBTS_ID, NRBTS_ID), cfg5qiRange='9', cfgProfType='SA')
    part_1_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_1_ds_file): {}'.format(part_1_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_1_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def clear_parameters_after_part_1():
    ds.initialise_delta_store()
    ds.delete_managed_object_from_delta(
        'MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-1'.format(MRBTS_ID, NRBTS_ID))
    ds.delete_managed_object_from_delta(
        'MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-2'.format(MRBTS_ID, NRBTS_ID))
    ds.delete_managed_object_from_delta(
        'MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-3'.format(MRBTS_ID, NRBTS_ID))
    part_1_after_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_1_after_ds_file): {}'.format(part_1_after_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_1_after_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def set_parameters_for_part_2_rlf():
    ds.initialise_delta_store()
    if assign_release_version() not in ['SBTS22R2', 'SBTS22R3']:
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actNrpmqapProfiles', 'true')
        ds.add_managed_object_and_parameter_to_delta(
            'MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-1'.format(MRBTS_ID, NRBTS_ID), cfg5qiRange='1', cfgProfType='SA')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'srbInactivityTimerSA', 600)
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'drbInactivityTimerSA', 1200)
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actGnbInitRlf', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'false')
    if assign_release_version() in ['SBTS22R4']:
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'false')
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'tRLFindForDUVoNR', '2000ms')
    part_2_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_2_ds_file): {}'.format(part_2_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_2_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def clear_parameters_after_part_2_rlf():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'srbInactivityTimerSA', 60)
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'drbInactivityTimerSA', 120)
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actGnbInitRlf', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'true')
    if assign_release_version() in ['SBTS22R4']:
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'true')
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'tRLFindForDUVoNR', '2000ms')
    part_2_after_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_2_after_ds_file): {}'.format(part_2_after_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_2_after_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def set_parameters_for_part_3_reestablishment():
    ds.initialise_delta_store()
    if assign_release_version() not in ['SBTS22R2', 'SBTS22R3']:
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actNrpmqapProfiles', 'true')
        ds.add_managed_object_and_parameter_to_delta(
            'MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-1'.format(MRBTS_ID, NRBTS_ID), cfg5qiRange='1', cfgProfType='SA')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 't301', '400ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 't301', '400ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 't301', '400ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 't311', '30000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 't304', 'ms2000')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 't310', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 't310', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 't310', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 't310', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 't310VoNR', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 't310VoNR', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 't310VoNR', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'tWaitingRlRecover', '10000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'timerRRCGuard', '6000')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actGnbInitRlf', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actUeInitRlf', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'rrcReestabTypeSA', 'sameGNB')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'false')
    part_3_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_3_ds_file): {}'.format(part_3_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_3_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def clear_parameters_after_part_3_reestablishment():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 't301', '400ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 't301', '400ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 't301', '400ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 't311', '30000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 't304', 'ms2000')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 't310', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 't310', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 't310', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 't310', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 't310VoNR', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 't310VoNR', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 't310VoNR', '2000ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'tWaitingRlRecover', '500ms')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'timerRRCGuard', '2500')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actGnbInitRlf', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actUeInitRlf', 'true')
    ds.add_param_to_delta_to_delete_it('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'rrcReestabTypeSA')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'actUlDftSOfdm', 'true')
    part_3_after_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_3_after_ds_file): {}'.format(part_3_after_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_3_after_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def set_parameters_for_part_4_fallback():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actRedirect', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actNormVCfallback', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirFreqeutra ', '900')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirFreqeutra ', '900')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirFreqeutra ', '900')
    part_4_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_4_ds_file): {}'.format(part_4_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_4_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def clear_parameters_after_part_4_fallback():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actRedirect', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actNormVCfallback', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta_to_delete_it('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirFreqeutra ', '900')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirFreqeutra ', '900')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirFreqeutra ', '900')
    part_4_after_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_4_after_ds_file): {}'.format(part_4_after_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_4_after_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def set_parameters_for_part_5_redirection():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actRedirect', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2HysteresisRedirectSsbRsrp=0)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2ThresholdRedirectSsbRsrp=60)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2TimeToTriggerRedirectSsbRsrp='ms480')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2HysteresisRedirectSsbRsrp=0)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2ThresholdRedirectSsbRsrp=60)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2TimeToTriggerRedirectSsbRsrp='ms480')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2HysteresisRedirectSsbRsrp=0)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2ThresholdRedirectSsbRsrp=60)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2TimeToTriggerRedirectSsbRsrp='ms480')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID),
                          'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID),
                          'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID),
                          'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID),
                          'redirFreqeutra ', '900')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID),
                          'redirFreqeutra ', '900')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID),
                          'redirFreqeutra ', '900')
    part_5_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_5_ds_file): {}'.format(part_5_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_5_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def clear_parameters_after_part_5_redirection():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actRedirect', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode', 'redirection')
    ds.add_param_to_delta_to_delete_it('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'voiceFBmode')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2HysteresisRedirectSsbRsrp=0)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2ThresholdRedirectSsbRsrp=34)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2TimeToTriggerRedirectSsbRsrp='ms480')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2HysteresisRedirectSsbRsrp=0)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2ThresholdRedirectSsbRsrp=34)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2TimeToTriggerRedirectSsbRsrp='ms480')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2HysteresisRedirectSsbRsrp=0)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2ThresholdRedirectSsbRsrp=34)
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                                 'a2MeasRedirectSsbRsrp', a2TimeToTriggerRedirectSsbRsrp='ms480')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirRAT', 'eutra')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirFreqeutra ', '900')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirFreqeutra ', '900')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3/NRREDRT-0'.format(MRBTS_ID, NRBTS_ID), 'redirFreqeutra ', '900')
    part_5_after_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_5_after_ds_file): {}'.format(part_5_after_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_5_after_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def set_parameters_for_part_6_intra_gnb_ho():
    ds.initialise_delta_store()
    if assign_release_version() not in ['SBTS22R2', 'SBTS22R3']:
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actNrpmqapProfiles', 'true')
        ds.add_managed_object_and_parameter_to_delta(
            'MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-1'.format(MRBTS_ID, NRBTS_ID), cfg5qiRange='1', cfgProfType='SA')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actIntraFreqHoSA', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'a3MeasEnabled', 'rsrp')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'a3MeasEnabled', 'rsrp')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'a3MeasEnabled', 'rsrp')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'a3MeasSsbRsrp',
                                 a3HysteresisSsbRsrp=4, a3OffsetSsbRsrp=5, a3TimeToTriggerSsbRsrp='ms512')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'a3MeasSsbRsrp',
                                 a3HysteresisSsbRsrp=4, a3OffsetSsbRsrp=5,
                                 a3TimeToTriggerSsbRsrp='ms512')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'a3MeasSsbRsrp',
                                 a3HysteresisSsbRsrp=4, a3OffsetSsbRsrp=5,
                                 a3TimeToTriggerSsbRsrp='ms512')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'rrcReestabTypeSA', 'viaRRCSetup')
    part_6_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_6_ds_file): {}'.format(part_6_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_6_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def clear_parameters_after_part_6_intra_gnb_ho():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'actIntraFreqHoSA', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'a3MeasEnabled', 'rsrp')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'a3MeasEnabled', 'rsrp')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'a3MeasEnabled', 'rsrp')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'a3MeasSsbRsrp',
                                 a3HysteresisSsbRsrp=4, a3OffsetSsbRsrp=10, a3TimeToTriggerSsbRsrp='ms512')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'a3MeasSsbRsrp',
                                 a3HysteresisSsbRsrp=4, a3OffsetSsbRsrp=10,
                                 a3TimeToTriggerSsbRsrp='ms512')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'a3MeasSsbRsrp',
                                 a3HysteresisSsbRsrp=4, a3OffsetSsbRsrp=10,
                                 a3TimeToTriggerSsbRsrp='ms512')
    ds.add_param_to_delta_to_delete_it('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID), 'rrcReestabTypeSA')
    part_6_after_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_6_after_ds_file): {}'.format(part_6_after_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_6_after_ds_file)
    with AdminApi() as web_api:
        web_api.reset_site()
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def set_parameters_for_part_7_inter_rat_ho():
    ds.initialise_delta_store()  # TODO: delta
    part_7_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_7_ds_file): {}'.format(part_7_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_7_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def clear_parameters_after_part_7_inter_rat_ho():
    ds.initialise_delta_store()  # TODO: delta
    part_7_after_ds_file = ds.collect_delta_store()
    blog('Delta store file (part_7_after_ds_file): {}'.format(part_7_after_ds_file))
    ds.perform_delta_recommissioning(delta_file=part_7_after_ds_file)
    admin_utils.wait_for_all_cells_on_air_state()


@logged_keyword
def check_5qi_setup_in_pcap_log(in_pcap):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=in_pcap, lua=None, tshark_filter='ngap', clean_up_tmp_file=False
        )
        command_msgs = finder.find_next(
            PM('PDUSessionResourceModifyRequest', message_type_pattern='empty').containing('fiveQI', '1')
        )
        assert command_msgs, " 5QI1 setup request not found in pcap"

        complete_msg = finder.find_next(
            PM('PDUSessionResourceModifyResponse', message_type_pattern='empty')
        )
        assert complete_msg, " 5QI1 setup response not found in pcap"


@logged_keyword
def check_5qi_release_in_pcap_log(in_pcap):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=in_pcap, lua=None, tshark_filter='ngap', clean_up_tmp_file=False
        )
        release_msg = finder.find_next(
            PM('PDUSessionResourceModifyRequest', message_type_pattern='empty').containing(
                'nas', 'normal-release (0)')
        )
        assert release_msg, " 5QI1 release not found in pcap"


@logged_keyword
def check_RLF_in_pcap_log(in_pcap):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=in_pcap, lua=None, tshark_filter='f1ap', clean_up_tmp_file=False
        )
        f1ap_msgs = finder.find_next(
            PM('UEContextModificationRequired', message_type_pattern='empty').containing(
                'radioNetwork', 'rl-failure-others (12)')
        )
        assert f1ap_msgs, " f1ap msg of RLF not found in pcap"

        finder2 = lh.add_pcap(
            pcap_file_path=in_pcap, lua=None, tshark_filter='ngap', clean_up_tmp_file=False
        )
        request_msgs = finder2.find_next(
            PM('UEContextReleaseRequest', message_type_pattern='empty').containing(
                'radioNetwork', 'radio-connection-with-ue-lost (21)')
        )
        assert request_msgs, " ngap request msg of RLF not found in pcap"

        command_msgs = finder2.find_next(
            PM('UEContextReleaseCommand', message_type_pattern='empty').containing(
                'radioNetwork', 'radio-connection-with-ue-lost (21)')
        )
        assert command_msgs, " ngap command msg of RLF not found in pcap"

        complete_msgs = finder2.find_next(
            PM('UEContextReleaseComplete', message_type_pattern='empty')
        )
        assert complete_msgs, " ngap complete msg of RLF not found in pcap"


@logged_keyword
def check_reestablishment_in_pcap_and_syslog(in_pcap, btslog_dir):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=in_pcap, tshark_filter='f1ap')

        msg = finder.find_next(PM('UEContextSetupResponse', message_type_pattern='empty'))
        assert msg is not None, 'UEContextSetupResponse could not be found.'
        gnb_cu_ue_id_1 = str(msg.find('GNB-CU-UE-F1AP-ID').first()['val'])
        blog('found gNB_CU_UE_ID: ' + gnb_cu_ue_id_1)

        msg = finder.find_next(PM('UEContextSetupResponse', message_type_pattern='empty'))
        assert msg is not None, 'UEContextSetupResponse could not be found.'
        gnb_cu_ue_id_2 = str(msg.find('GNB-CU-UE-F1AP-ID').first()['val'])
        blog('found gNB_CU_UE_ID: ' + gnb_cu_ue_id_2)

        check_reestablishment_in_syslog(btslog_dir, gnb_cu_ue_id_1, gnb_cu_ue_id_2)


@logged_keyword
def check_reestablishment_in_syslog(btslog_dir, gnb_cu_ue_id_1, gnb_cu_ue_id_2):
    sw_version = get_sw_version()
    if "SBTS00" in sw_version:
        from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common_regular_expressions \
            import RegularExpressionsTrunk as RegularExpressions
    elif "22R4" in sw_version:
        from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common_regular_expressions \
            import RegularExpressions22R4 as RegularExpressions
    elif "22R3" in sw_version:
        from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common_regular_expressions \
            import RegularExpressions22R3 as RegularExpressions
    elif "22R2" in sw_version:
        from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common_regular_expressions \
            import RegularExpressions22R2 as RegularExpressions
    else:
        assert False, "Regular expressions not found for this SW version: {}".format(sw_version)

    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))

        msg_1 = syslog.find_next(SM(RegularExpressions.REE_REQUEST_REGEX, regex_engine='re'))
        assert msg_1 is not None, 'No sign of RrcReestablishmentRequest in syslog.'
        blog('FOUND: ' + str(msg_1))

        msg_2 = syslog.find_next(SM(RegularExpressions.REE_COMPLETE_REGEX))
        assert msg_2 is not None, 'No sign of RRCReestablishmentComplete in syslog.'
        blog('FOUND: ' + str(msg_2))

        msg_3 = syslog.find_next(SM(RegularExpressions.RRC_RECONFIG_COMPLETE))
        assert msg_3 is not None, 'No sign of 1st RRCReconfigurationComplete in syslog.'
        blog('FOUND: ' + msg_3)

        msg_4 = syslog.find_next(SM(RegularExpressions.RRC_RECONFIG_COMPLETE))
        assert msg_4 is not None, 'No sign of 2nd RRCReconfigurationComplete in syslog.'
        blog('FOUND: ' + msg_4)

        msg_5 = syslog.find_next(SM(RegularExpressions.UE_CONTEXT_MOD_RESPONSE
                                    .format(gnb_cu_ue_id_1), regex_engine='re'))
        assert msg_5 is not None, 'No sign of correct UeContextModificationResponse in syslog.'
        blog('FOUND: ' + msg_5)

        msg_6 = syslog.find_next(SM(RegularExpressions.UE_CONTEXT_MOD_RESPONSE
                                    .format(gnb_cu_ue_id_2), regex_engine='re'))
        assert msg_6 is not None, 'No sign of correct UeContextModificationResponse in syslog.'
        blog('FOUND: ' + msg_6)

        blog('Syslog analysed successfully.')


@logged_keyword
def check_inter_rat_ho_in_pcap_log(in_pcap, target_phys_cell_id):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=in_pcap, lua=None, tshark_filter='ngap', clean_up_tmp_file=False
        )
        ho_required_msg = finder.find_next(
            PM('HandoverRequired', message_type_pattern='empty').containing(
                'radioNetwork', 'ng-inter-system-handover-triggered (32)')
        )
        assert ho_required_msg, " ho required msg of inter rat ho not found in pcap"

        ho_command_msg = finder.find_next(
            PM('HandoverCommand', message_type_pattern='empty').containing(
                'targetPhysCellId', str(target_phys_cell_id))
        )
        assert ho_command_msg, " ho command msg of inter rat ho not found in pcap"

        ue_context_release_msg = finder.find_next(
            PM('UEContextReleaseCommand', message_type_pattern='empty').containing(
                'radioNetwork', 'successful-handover (2)')
        )
        assert ue_context_release_msg, " ue context release msg of inter rat ho not found in pcap"


@logged_keyword
def show_cell_id_before_change():
    blog("Cell ID for UE_1 before change: {}".format(str(taf_ue.get_ue_info('UE_1', 'CELL_ID'))))
    blog("Cell ID for UE_2 before change: {}".format(str(taf_ue.get_ue_info('UE_2', 'CELL_ID'))))


@logged_keyword
def show_cell_id_after_change():
    blog("Cell ID for UE_1 after change: {}".format(str(taf_ue.get_ue_info('UE_1', 'CELL_ID'))))
    blog("Cell ID for UE_2 after change: {}".format(str(taf_ue.get_ue_info('UE_2', 'CELL_ID'))))


@logged_keyword
def check_redirection_in_pcap_log(in_pcap):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=in_pcap, tshark_filter='ngap')

        redirection_msg = finder.find_next(PM(
            'UEContextReleaseCommand', message_type_pattern='empty')).containing('radioNetwork', 'redirection (41)')
        assert redirection_msg is not None, 'UEContextReleaseCommand for redirection could not be found.'


@logged_keyword
def check_fallback_in_pcap_log(in_pcap):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=in_pcap, tshark_filter='ngap')

        fallback_msg = finder.find_next(PM(
            'PDUSessionResourceModifyResponse', message_type_pattern='empty')).containing(
            'radioNetwork', 'ims-voice-eps-fallback-or-rat-fallback-triggered (36)')
        assert fallback_msg is not None, 'PDUSessionResourceModifyResponse for fallback could not be found.'

        redirection_fallback_msg = finder.find_next(PM(
            'UEContextReleaseCommand', message_type_pattern='empty')).containing('radioNetwork', 'redirection (41)')
        assert redirection_fallback_msg is not None, 'UEContextReleaseCommand for fallback could not be found.'

        complete_fallback_msg = finder.find_next(PM('UEContextReleaseComplete', message_type_pattern='empty'))
        assert complete_fallback_msg is not None, 'UEContextReleaseComplete for fallback could not be found.'


@logged_keyword
def check_if_5QI1_counters_incremented(counter_dir, counter_ids, target_counter_value=1):
    value_dict = pmc.get_relevant_pm_counters(pi_dir=counter_dir, counter_ids=counter_ids)
    if not value_dict:
        raise KeyError('dict is empty, there is no such counters collected on bts')
    blog(str(value_dict))
    for counter in value_dict.values():
        incremented = False
        for cell, counter_value_list in iter(counter.items()):
            for counter_value in counter_value_list:
                if counter_value >= target_counter_value:
                    incremented = True
                    break
            if incremented:
                break
        assert incremented, '5QI1 Counters not incremented'
    return value_dict


@logged_keyword
def check_if_5QI1_counters_work_same(counter_dir, counter_ids):
    value_dict = pmc.get_relevant_pm_counters(counter_dir, counter_ids)
    blog(value_dict)
    same = compare_counters_values(value_dict)
    if not same:
        raise KeyError('counters have different values')
    return value_dict


@logged_keyword
def compare_counters_values(value_dict):
    counter_dict = list(value_dict.values())
    first_counter_dict = counter_dict[0]
    second_counter_dict = counter_dict[1]
    a = set(flatten_list(first_counter_dict.values()))
    b = set(flatten_list(second_counter_dict.values()))
    a.remove(0)
    b.remove(0)
    blog('first counter value of last period=  {}\nsecond counter value of last period= {}'.format(a, b))
    if a == b:
        return True


@logged_keyword
def check_if_5QI1_counters_work_same_E3_E4(counter_dir, counter_ids):
    value_dict = pmc.get_relevant_pm_counters(counter_dir, counter_ids)
    blog(value_dict)
    same = compare_counters_values_E3_E4(value_dict)
    if not same:
        raise KeyError('counters have different values')
    return value_dict


@logged_keyword
def compare_counters_values_E3_E4(value_dict):
    counter_dict = list(value_dict.values())
    first_counter_dict = counter_dict[0]
    second_counter_dict = counter_dict[1]
    a = first_counter_dict["1"][len(first_counter_dict["1"])-1]
    b = second_counter_dict["1"][len(second_counter_dict["1"])-1]
    if flatten_list(second_counter_dict.values()) != second_counter_dict["1"]:
        b += second_counter_dict["2"][len(second_counter_dict["2"])-1] \
           + second_counter_dict["3"][len(second_counter_dict["3"])-1]
    blog('first counter value of last period=  {}\nsecond counter value of last period= {}'.format(a, b))
    if a == b:
        return True


@logged_keyword
def check_if_5QI1_counters_show_proper_call_duration(counter_dir, counter_ids, duration):
    value_dict = pmc.get_relevant_pm_counters(pi_dir=counter_dir, counter_ids=counter_ids)
    if not value_dict:
        raise KeyError('dict is empty, there is no such counters collected on bts')
    blog(str(value_dict))
    for counter in value_dict.values():
        is_proper_duration = False
        for cell, counter_value_list in iter(counter.items()):
            for counter_value in counter_value_list:
                expected = int(duration * 2 * 1000)
                blog("Expected call duration: {}".format(expected))
                received = int(counter_value)
                blog("Received call duration (from counters): {}".format(received))
                margine = 0.01 * expected
                blog("Margine: {}".format(margine))
                if abs(received - expected) <= margine:
                    is_proper_duration = True
        assert is_proper_duration, '5QI1 counter value is wrong'
    return value_dict


def flatten_list(input_list):
    return [element for inner_list in input_list for element in inner_list]
