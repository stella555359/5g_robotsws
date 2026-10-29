from taf.rfrl.bts.devices.dist_name_patterns import EnbDistNamePatterns, GnbDistNamePatterns

_gnb_cell1_dist_name = GnbDistNamePatterns.cell_dist_name.format('{}', '{}', 1)
_gnb_cell9_dist_name = GnbDistNamePatterns.cell_dist_name.format('{}', '{}', 9)
_gnb_nrpmrnl1_dist_name = f'{GnbDistNamePatterns.bts_dist_name}/NRPMRNL-1'


def _generate_base_delta(dist_name: str, parameter_name: str, value: str or list, operation: str = 'update'):
    return {
        "distName": dist_name,
        "operation": operation,
        "parameters": [
            {
                "parameterName": parameter_name,
                "value": value,
                "operation": operation
            }
        ]
    }


def generate_cbra_preambles_per_ssb_for_each_cell(nrbts_dist_name: str, cell_start: int, cell_end: int, value: str):
    deltas = []
    for cell_id in range(cell_start, cell_end + 1):
        _cell_dist_name = f'{nrbts_dist_name}/NRCELL-{cell_id}'
        deltas.append(_generate_base_delta(_cell_dist_name, 'cbraPreamblesPerSsb', value))
    return deltas


def _generate_a2_meas_settings(cell_dist_name: str, hysteresis: str = '0', threshold: str = '96',
                               trigger_time: str = 'ms480'):
    a2_settings = [{"a2HysteresishoSsbRsrp": hysteresis,
                    "a2ThresholdhoSsbRsrp": threshold,
                    "a2TimeToTriggerhoSsbRsrp": trigger_time}]
    return _generate_base_delta(dist_name=cell_dist_name, parameter_name="a2MeashoSsbRsrp", value=a2_settings)


def _generate_a2_meas_redirect_settings(cell_dist_name: str, hysteresis: str = '0', threshold: str = '86',
                                        trigger_time: str = 'ms480'):
    a2_settings = [{"a2HysteresisRedirectSsbRsrp": hysteresis,
                    "a2ThresholdRedirectSsbRsrp": threshold,
                    "a2TimeToTriggerRedirectSsbRsrp": trigger_time}]
    return _generate_base_delta(dist_name=cell_dist_name, parameter_name="a2MeasRedirectSsbRsrp", value=a2_settings)


CBRA_DELTAS = {
    'ENB0': [_generate_base_delta(EnbDistNamePatterns.bts_dist_name, 'actB1ExtMeasNR', 'false')],
    'GNB0': [
        _generate_base_delta(_gnb_nrpmrnl1_dist_name, 'miNrRachUsage', '5min'),
        _generate_base_delta(_gnb_nrpmrnl1_dist_name, 'miNrNGCC', '5min'),
        *generate_cbra_preambles_per_ssb_for_each_cell(GnbDistNamePatterns.bts_dist_name, 1, 8, 'n64')
    ],
}

CFRA_DELTAS = {
    'ENB0': [
        _generate_base_delta(EnbDistNamePatterns.bts_dist_name, 'actB1ExtMeasNR', 'true'),
        _generate_base_delta(EnbDistNamePatterns.bts_dist_name, 'actSnChangeSnInit', 'true'),
    ],
    'GNB0': [
        _generate_base_delta(GnbDistNamePatterns.bts_dist_name, 'actIntraFreqInterGnbMobilityNSA3x', 'true'),
        _generate_base_delta(_gnb_nrpmrnl1_dist_name, 'miNrRachUsage', '5min'),
        _generate_base_delta(_gnb_nrpmrnl1_dist_name, 'miNrNGCC', '5min'),
        *generate_cbra_preambles_per_ssb_for_each_cell(GnbDistNamePatterns.bts_dist_name, 1, 8, 'n48')
    ],
    'GNB1': [
        _generate_base_delta(GnbDistNamePatterns.bts_dist_name, 'actIntraFreqInterGnbMobilityNSA3x', 'true'),
        _generate_base_delta(_gnb_nrpmrnl1_dist_name, 'miNrRachUsage', '5min'),
        _generate_base_delta(_gnb_nrpmrnl1_dist_name, 'miNrNGCC', '5min'),
        *generate_cbra_preambles_per_ssb_for_each_cell(GnbDistNamePatterns.bts_dist_name, 9, 16, 'n48')
    ],
}

DEFAULT_PARAM_DELTAS = {
    'ENB0': [
        _generate_base_delta(EnbDistNamePatterns.bts_dist_name, 'actB1ExtMeasNR', 'false'),
        _generate_base_delta(EnbDistNamePatterns.bts_dist_name, 'actSnChangeSnInit', 'true'),
    ]
}
