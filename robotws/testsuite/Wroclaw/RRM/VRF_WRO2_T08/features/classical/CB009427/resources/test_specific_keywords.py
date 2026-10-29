import math
import os
from time import sleep

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.bip_log_collector import BipLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.qxdm_log_collector import QxdmLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.throughput_curves.resources.bip_verification import BipParser
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.throughput_curves.resources.elt_verification import \
    EltLogParser
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.AdminWrapper import AdminWrapper
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.Attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.scf import SCFContent, Delta

admin = AdminWrapper()
attenuator = Attenuator()

pre_set_params = {
    'actAdaptiveReTxResMcs': 'true',
    'minPctResourceReservedMcsUl': 50,
    'minPctResourceReservedMcsDl': 50,
    'targetPctResourceReservedMcsDl': 100,
    'targetPctResourceReservedMcsUl': 100,
    'dlPtrs': [
        {
            'actDlPtrs': 'false',
            'dlPtrsFreqDensityThresNrb0': 277,
            'dlPtrsFreqDensityThresNrb1': 24
        }
    ],
    'ullaBlerTarget': 10
}
feature_enabled_params = {
    'actAdaptiveUlBlerTarget': 'true',
    'adaptiveUlBlerTarget': [
        {
            'ullaBlerTargetLowSinr': 20,
            'ullaBlerTargetMcs0': 50,
            'ullaBlerTargetSinrThreshold': 50
        }
    ]
}
feature_disabled_params = {
    'actAdaptiveUlBlerTarget': 'false',
    'adaptiveUlBlerTarget': None
}

delta_id = 'cb009427_delta'


def backup_current_scf(output_dir, scf_filename):
    with admin.nr_context() as connection:
        admin.get_current_scf_file(output_dir, scf_filename, timeout=20, connection=connection)
    scf_path = os.path.join(output_dir, scf_filename)
    blog(f"SCF backed up at {scf_path}")
    return scf_path


def get_current_nrcell_parameter_dict(phys_cell_id, scf_filepath):
    scf = SCFContent(scf_filepath=scf_filepath)
    nrcell_dn, nrcell_params = scf.get_nrcell(physcellid=phys_cell_id)
    param_dict = {k: nrcell_params.get(k, None) for k in set(pre_set_params) | set(feature_enabled_params)}
    return {nrcell_dn: param_dict}


def ensure_pre_set_scf_parameters(nrcell_params):
    _delta_commission_target(nrcell_params, pre_set_params)


def disable_adaptive_ul_bler_target(nrcell_params):
    _delta_commission_target(nrcell_params, feature_disabled_params)


def enable_adaptive_ul_bler_target(nrcell_params):
    _delta_commission_target(nrcell_params, feature_enabled_params)


def _delta_commission_target(nrcell_params, target_params):
    delta = Delta()
    param_dict = {nrcell_dn: target_params for nrcell_dn in nrcell_params}
    delta.append_parameter_dict(param_dict)
    with admin.nr_context() as connection:
        delta.commission_delta(admin_api=admin, admin_connection=connection)


def restore_original_scf(nrcell_params):
    delta = Delta()
    delta.append_parameter_dict(nrcell_params)
    with admin.nr_context() as connection:
        delta.commission_delta(admin_api=admin, admin_connection=connection)


def setup_attenuator():
    attenuator.load_attenuation_config()


def setup_ue_log_collector(ue_app='elt'):
    ue_log_collector = (QxdmLogCollector if ue_app.lower() == 'qxdm' else EltLogCollector)()
    ue_log_collector.setup()
    ue_log_collector.set_logging_filter()
    return ue_log_collector


def setup_bip_collector(nrcell_dn):
    bip_collector = BipLogCollector(nrcell_dns=[nrcell_dn])
    bip_collector.setup()
    return bip_collector


def force_good_condition_only_on_cell(cell_id, init_atten='0dB'):
    attenuator.force_cell(cell_id, attenuation=init_atten)


def tput_curve_cb009427(cell_id, init_atten, ue_app, nrcell_params):
    cell_id = f'GNB_1_CELL_{cell_id}'
    ue_log_collector = setup_ue_log_collector(ue_app)
    bip_log_collector = setup_bip_collector(list(nrcell_params.keys())[0])
    attenuation = init_atten
    values = {}
    try:
        while True:
            atten_str = f'{attenuation}dB'
            attenuator.set_attenuation(cell_alias=cell_id, attenuation_value=atten_str)
            sleep(20)
            ue_log_collector.reset_log_collector()
            ue_log_collector.start_log_collecting()
            bip_log_collector.start_log_collecting()
            sleep(5)
            bip_log_collector.stop_log_collecting()
            ue_log_collector.stop_log_collecting()
            bip = bip_log_collector.download_log(filepath=f'step_{atten_str}')
            ue_log = ue_log_collector.download_log(filepath=f'step_{atten_str}')
            pusch_sinr, pucch_sinr, bip_mcs = analyze_bip(bip)
            bler, ibler, ue_mcs, ue_sinr, rsrp = analyze_ue_log(ue_log)
            values[atten_str] = {'pusch_sinr': pusch_sinr, 'pucch_sinr': pucch_sinr, 'ue_sinr': ue_sinr,
                                 'bip_mcs': bip_mcs, 'ue_mcs': ue_mcs, 'bler': bler, 'ibler': ibler, 'rsrp': rsrp}
            blog(f'{atten_str}: {values[atten_str]}')
            if any([math.isnan(value) for value in values[atten_str].values()]):
                break
            attenuation += 5 if pusch_sinr >= 10 else 2 if ue_mcs >= 3 else 1
    finally:
        ue_log_collector.shutdown()
        bip_log_collector.shutdown()
    return values


def analyze_bip(bip):
    bip_parser = BipParser()
    stats = bip_parser.analyze_log(logfile=bip, stat_names=('ul_mcs', 'pusch_sinr', 'pucch_sinr'))
    return stats['pusch_sinr'], stats['pucch_sinr'], stats['ul_mcs']


def analyze_ue_log(ue_log):
    if isinstance(ue_log, list):
        return analyze_elt_log(ue_log[0])
    return analyze_qxdm_log(ue_log[0][0])


def analyze_elt_log(ue_log):
    elt_parser = EltLogParser()
    stats = elt_parser.analyze_log(logfile=ue_log)
    return stats['ul_bler'], stats['ul_ibler'], stats['ul_mcs'], stats['sinr'], stats['rsrp']


def analyze_qxdm_log(ue_log):
    pass


def verify_feature_disabled(atten_stats):
    high_checks, low_checks, mcs0_checks = (0, 0, 0)
    for atten, stats in atten_stats.items():
        if stats['pusch_sinr'] > 10:
            assert 8 < stats['bler'] < 12, f"Invalid BLER ({stats['bler']}) for High Sinr ({stats['pusch_sinr']}) " \
                                           f" (feature disabled)"
            high_checks += 1
        if stats['pusch_sinr'] < 8 and stats['bip_mcs'] > 2.5:
            assert 8 < stats['bler'] < 12, f"Invalid BLER ({stats['bler']}) for Low Sinr ({stats['pusch_sinr']}) " \
                                           f" (feature disabled)"
            low_checks += 1
        if stats['bip_mcs'] < 1.2:
            assert 8 < stats['bler'] < 30, f"Invalid BLER ({stats['bler']}) for MCS0 (avg mcs={stats['bip_mcs']}) " \
                                           f" (feature disabled)"
            mcs0_checks += 1
    assert high_checks >= 2, f"Too low amount of high sinr region check points - {high_checks}. At least 2 required"
    assert low_checks >= 2, f"Too low amount of low sinr region check points - {low_checks}. At least 2 required"
    assert mcs0_checks >= 2, f"Too low amount of mcs0 region check points - {mcs0_checks}. At least 2 required"


def verify_feature_enabled(atten_stats):
    high_checks, low_checks, mcs0_checks = (0, 0, 0)
    for atten, stats in atten_stats.items():
        if stats['pusch_sinr'] > 10:
            assert 8 < stats['bler'] < 12, f"Invalid BLER ({stats['bler']}) for High Sinr ({stats['pusch_sinr']}) " \
                                           f" (feature enabled)"
            high_checks += 1
        if stats['pusch_sinr'] < 8 and stats['bip_mcs'] > 2.5:
            assert 14 < stats['bler'] < 26, f"Invalid BLER ({stats['bler']}) for Low Sinr ({stats['pusch_sinr']}) " \
                                            f" (feature enabled)"
            low_checks += 1
        if stats['bip_mcs'] < 1.2:
            assert 35 < stats['bler'] < 55, f"Invalid BLER ({stats['bler']}) for MCS0 (avg mcs={stats['bip_mcs']}) " \
                                            f" (feature enabled)"
            mcs0_checks += 1
    assert high_checks >= 2, f"Too low amount of high sinr region check points - {high_checks}. At least 2 required"
    assert low_checks >= 2, f"Too low amount of low sinr region check points - {low_checks}. At least 2 required"
    assert mcs0_checks >= 2, f"Too low amount of mcs0 region check points - {mcs0_checks}. At least 2 required"


def release_attenuator():
    attenuator.set_maximum_attenuation_for_all_cells_of_testline()
    attenuator.teardown_attenuator()
