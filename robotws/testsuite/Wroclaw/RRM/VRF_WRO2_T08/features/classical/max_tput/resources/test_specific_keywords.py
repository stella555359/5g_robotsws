import re
from pprint import pformat
from time import sleep

from taf.rfrl.common_resources.common_step.sleep_cell_check.ru_transmit_power import \
    check_ecpri_ru_transmit_power_in_normal_range

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap import dcap, extract_logs
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.kpi import parse_tti
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import continue_on_failure
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.AdminWrapper import AdminWrapper
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.Attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.TafUe import TafUe
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.teardown import Teardown
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.reporting_portal import report_kpi
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger
from testsuite.Wroclaw.RRM.resources.max_tput_counters import MaxTputCounters

taf_ue = TafUe()
teardown = Teardown()
admin = AdminWrapper()
attenuator = Attenuator()
counters = MaxTputCounters()
dcap_alias = 'max_tput_dcap'
gnb_log_profile = ['condor5gSyslog', 'L2Ps_Component', 'bip_interface_mirroring']
bts_log_profile = ['scf', 'pmFiles', 'ipCapture', 'immediateSnapshot']
lte_log_profile = []
log_kwargs = {'gnb_custom_profile': gnb_log_profile, 'enb_custom_profile': lte_log_profile,
              'bts_custom_profile': bts_log_profile, 'bip_mirroring_time': 0}
ue_alias = 'UE_1'
_split_pattern = re.compile(r'^(\d+)\s*(\D+)$')


def test_setup_py():
    attenuator.load_attenuation_config()
    teardown.schedule_test_teardown_function("Teardown attenuator", attenuator.teardown_attenuator, [])
    teardown.schedule_test_teardown_function("RU power check", check_ecpri_ru_transmit_power_in_normal_range, [])
    with admin.nr_context() as admin_nr:
        logger.info("\nWaiting for fresh PM counter cycle before test. This may take a while...", also_to_console=True)
        counters.wait_for_next_pm_interval_before_test(admin_connection=admin_nr)
    dcap.connect_to(alias=dcap_alias)


def test_teardown_py():
    teardown('test')


def force_good_radio_condition_on_cell(cell_alias):
    attenuator.force_cell(cell_name=cell_alias, attenuation='0dB')


def attach():
    taf_ue.attach_ue(ue_alias=ue_alias, capabilities='REAL_UE')
    teardown.schedule_test_teardown_function(f"Detach {ue_alias}", taf_ue.detach_ue, (ue_alias,))


@continue_on_failure()
def detach():
    taf_ue.detach_ue(ue_alias=ue_alias)
    teardown.recall_test_teardown_function(f"Detach {ue_alias}")


def start_tput(direction='ULDL', protocol='tcp'):
    taf_ue.start_tput_on_ue(ue_alias=ue_alias, direction=direction, duration=300, protocol=protocol)
    teardown.schedule_test_teardown_function(f"Stop tput on {ue_alias}", taf_ue.stop_tput_on_ue, (ue_alias, direction))


def wait_tput():
    taf_ue.await_tput_end(ue_alias=ue_alias)
    teardown.recall_test_teardown_function(f"Stop tput on {ue_alias}")


def start_logging():
    trace_id = dcap.start_new_trace(mplane='10.44.224.6', connection=dcap_alias, nr_cells=[193], log_kwargs=log_kwargs)
    teardown.schedule_test_teardown_function(f"Stop DCAP trace (id = {trace_id})", stop_and_collect_logs, (trace_id, ))
    return trace_id


def stop_and_collect_logs(trace_id, target_dir):
    log_zip = dcap.stop_trace_and_get_results(trace=trace_id, target_dir=target_dir, connection=dcap_alias,
                                              timeout=1500)
    teardown.recall_test_teardown_function(f"Stop DCAP trace (id = {trace_id})")
    return log_zip


def perform_max_tput(direction='ULDL', protocol='tcp', test_dir='/home/ute/logs'):
    trace_id = start_logging()
    attach()
    sleep(5)
    start_tput(direction, protocol)
    logger.info("\nUE attached, tput ongoing...", also_to_console=True)
    wait_tput()
    logger.info("\nTput ended. Collecting DCAP logs...", also_to_console=True)
    log_zip = stop_and_collect_logs(trace_id, test_dir)
    detach()
    return log_zip


def verify_max_tput(direction, expected_tput, deviation='10%', omit=30):
    taf_ue.verify_tput(ue_alias=ue_alias, direction=direction, expected=expected_tput, deviation=deviation, omit=omit)
    avg_tput, min_tput, max_tput = _get_tput_stats(direction, omit)
    expected_tput, unit = _split_pattern.findall(expected_tput)[0]
    return {'avg': avg_tput, 'min': min_tput, 'max': max_tput, 'target': expected_tput, 'unit': unit,
            'deviation': deviation}


def _get_tput_stats(direction, omit):
    samples = list(map(_rescale_to_mbits_float,
                       taf_ue.get_tput_stats(ue_alias=ue_alias, direction=direction).split(';')[-1].split(',')))
    if len(samples) <= omit:
        return 0, 0, 0
    samples = samples[omit:]
    return round(sum(samples) / len(samples), 1), min(samples), max(samples)


def _rescale_to_mbits_float(value):
    return float(value) / 1_000_000


def verify_max_tput_counters():
    with admin.nr_context() as admin_nr:
        logger.info("\nWaiting for fresh PM counter cycle after test. This may take a while...", also_to_console=True)
        counters.collect_counters_after_test(admin_connection=admin_nr)
    # counters.verify_pdcp_tput_counter()
    counters.verify_M51301C1_counter()
    counters.verify_M51301C5_counter()
    counters.verify_M51352C1_counter()
    counters.verify_M51352C9_counter()
    counters.verify_M51363C7_counter()


def report_tput_kpis(log_zip, tput_dl, tput_ul, protocol='tcp'):
    _log_tput(tput_dl, tput_ul)
    logs = extract_logs(log_zip)
    tti_kpis = parse_tti(log_path=logs['udptracer'], kpi_names=('dl_mcs', 'dl_bler', 'dl_pdcch_beam_id',
                                                                'ul_mcs', 'ul_bler', 'ul_pdcch_beam_id'))
    logger.info(f"{pformat(tti_kpis, indent=4)}", also_to_console=True)
    common_kwargs = {'visible_to_db': 'true', 'kpi_type': 'Throughput', 'category': 'Performance'}
    for direction, tput in zip(('dl', 'ul'), (tput_dl, tput_ul)):
        report_kpi(name=f'avg_{direction}_{protocol}_tput', value=tput['avg'], target=tput['target'],
                   description=f'Average {direction.upper()} {protocol.upper()} throughput', unit=tput['unit'],
                   **common_kwargs)
        report_kpi(name=f'min_{direction}_{protocol}_tput', value=tput['min'], target=tput['target'],
                   description=f'Minimum {direction.upper()} {protocol.upper()} throughput', unit=tput['unit'],
                   **common_kwargs)
        report_kpi(name=f'max_{direction}_{protocol}_tput', value=tput['max'], target=tput['target'],
                   description=f'Maximum {direction.upper()} {protocol.upper()} throughput', unit=tput['unit'],
                   **common_kwargs)
        report_kpi(name=f'{direction}_{protocol}_mcs', value=tti_kpis[f'{direction}_mcs'], target='',
                   description=f'{direction.upper()} {protocol.upper()} MCS', unit='#', **common_kwargs)
        report_kpi(name=f'{direction}_{protocol}_bler', value=tti_kpis[f'{direction}_bler'], target='',
                   description=f'{direction.upper()} {protocol.upper()} BLER', unit='#', **common_kwargs)
        report_kpi(name=f'{direction}_{protocol}_beam_id', value=tti_kpis[f'{direction}_pdcch_beam_id'], target='',
                   description=f'{direction.upper()} {protocol.upper()} BEAM ID', unit='#', **common_kwargs)


def _log_tput(tput_dl, tput_ul):
    logger.info("Tput DL:", also_to_console=True)
    logger.info(f"{pformat(tput_dl, indent=4)}", also_to_console=True)
    logger.info("Tput UL:", also_to_console=True)
    logger.info(f"{pformat(tput_ul, indent=4)}", also_to_console=True)
