"""
:copyright: Nokia Networks
:authors:
    Patryk Wojcik, patryk.wojcik@nokia.com
:maintainers:
    Patryk Wojcik, patryk.wojcik@nokia.com
"""
import logging
import math


def verify_values_from_antenna_online_monitoring(results, cell_id=0, exp_value='-', margin=5):
    """
    Verify values of ETP or RTWP obtained from Antenna Line Online Monitoring.
    The results are presented alternately for each cell, so cell 0 has indexes [0, 2], and cell 2 has indexes [1, 3].
    :param list results:    list of dicts with values measured on given antenna
    :param int cell_id:     id of LNCEL
    :param list exp_value:  expected value of ETP/RTWP measured on given antenna
    :param list margin:     acceptable error in the results
    """
    indexes = [0, 2] if cell_id == 0 else [1, 3]
    for index in indexes:
        obtained_value = results[index][list(results[index].keys())[-1]]
        if exp_value == '-':
            assert obtained_value == '-', "Value of data should be equal to - "
        else:
            obtained_value = float(obtained_value)
            if float(exp_value) > 0:
                assert (100+margin)/100 * float(exp_value) >= obtained_value >= (100-margin)/100 * float(exp_value), \
                    f"{(100+margin)/100 * float(exp_value)}>={obtained_value}>={(100-margin)/100 * float(exp_value)}"

            else:
                assert (100-margin)/100 * float(exp_value) >= obtained_value >= (100+margin)/100 * float(exp_value), \
                    f"{(100-margin)/100 * float(exp_value)}>={obtained_value}>={(100+margin)/100 * float(exp_value)}"


def compare_rtwps_from_antenna_line_online_monitoring(results_without_traffic, results_with_traffic, diff=4):
    """
    Compare values of RTWPS obtained from Antenna Line Online Monitoring
    :param list results_without_traffic: list of dicts with values of RTWP on given antenna on given radio module
                                         without traffic
    :param list results_with_traffic:    list of dicts with values of RTWP on given antenna on given radio module
                                         with traffic
    :param int diff:                     acceptable error in the results
    """
    results = []
    for index in range(0, len(results_without_traffic)):
        rtwp_wo_traffic = float(results_without_traffic[index][list(results_without_traffic[index].keys())[-1]])
        rtwp_with_traffic = float(results_with_traffic[index][list(results_with_traffic[index].keys())[-1]])
        results.append(round((rtwp_with_traffic - rtwp_wo_traffic), 2))
    logging.info(f'Differences={results}')
    assert max(results) >= diff, f'differences={results}'


def verify_general_values_from_rf_diagnostic_test(results, etp_exp, sinr_exp=-20, margin=5):
    """
    Verify general values obtained from RF Diagnostic Tests
    :param list results:    list of dicts with values measured on given antenna
    :param list etp_exp:    expected value of ETP measured on given antenna
    :param list sinr_exp:   expected value of SINR measured on given antenna
    :param list margin:     acceptable error in the results
    """
    got_etp = results[0]["Forward expected transmit RF power"]
    logging.info(f'Forward expected transmit RF power={results[0]["Forward expected transmit RF power"]}')
    logging.info(f'Forward test disposition={results[0]["Forward test disposition"]}')
    logging.info(f'Outcome={results[0]["Outcome"]}')
    logging.info(f'SINR (dB)={results[0]["SINR (dB)"]}')
    logging.info(f'Result={results[0]["Result"]}')
    logging.info(f'Reverse test disposition={results[0]["Reverse test disposition"]}')
    logging.info(f'expected_etp={etp_exp} got_ETP={got_etp}')

    assert (100 + margin) / 100 * float(etp_exp) > float(got_etp) > \
           (100 - margin) / 100 * float(etp_exp), f'expected_etp={etp_exp} got_ETP={got_etp}'

    assert (100 - margin) / 100 * float(sinr_exp) > float(results[0]["SINR (dB)"]) > \
           (100 + margin) / 100 * float(sinr_exp), f'expected_SINR={sinr_exp} got_SINR={results[0]["SINR (dB)"]}'
    assert results[0]["Forward test disposition"] == 'Pass', \
        f"Forward test disposition: {results[0]['Forward test disposition']}"
    assert results[0]["Result"] == 'success', \
        f"Result: {results[0]['Result']}"
    assert results[0]["Reverse test disposition"] == 'Pass', \
        f"Reverse test disposition: {results[0]['Reverse test disposition']}"


def verify_detailed_values_from_rf_diagnostic_test(results, etp_exp_dbm,  margin=5):
    """
    Verify values of RTWPS and ETP obtained from RF Diagnostic Tests. ETP should be equal to 14 dBm (0 W),
    RTWP should be in range (-80,-115)
    :param list results:       list of dicts with values measured on given antenna
    :param list etp_exp_dbm:   expected value of ETP measured on given antenna
    :param list margin:        acceptable error in the results
    """
    etp_exp_w = round(float(math.pow(10, float(etp_exp_dbm)/10)/1000), 1)
    for index in range(0, len(results)):
        got_etp_dbm = float(results[index]['Forward expected transmit RF power']['dBm'])
        got_etp_w = float(results[index]['Forward expected transmit RF power']['W'])
        got_rtwp = float(results[index]['RTWP (dBm)'])

        assert (100 + margin) / 100 * float(etp_exp_dbm) > got_etp_dbm > (100 - margin) / 100 * float(etp_exp_dbm), \
            f'expected_ETP={etp_exp_dbm} got_ETP={got_etp_dbm}'
        assert (100 + margin) / 100 * float(etp_exp_w) >= got_etp_w >= (100 - margin) / 100 * float(etp_exp_w), \
            f'expected_ETP={etp_exp_w} got_ETP={got_etp_w}'
        assert -80 >= got_rtwp >= -115, f'expected_RTWP should be in range (-80,-115)'


def compare_rtwps_from_rf_diagnostic_tests(results_without_traffic, results_with_traffic, diff=4):
    """
    Compare values of RTWPS obtained from RF Diagnostic Tests
    :param list results_without_traffic: list of dicts with values of RTWP on given antenna on given radio module
                                         without traffic
    :param list results_with_traffic:    list of dicts with values of RTWP on given antenna on given radio module
                                         with traffic
    :param int diff:                     acceptable error in the results
    """
    results = []
    for index in range(0, len(results_without_traffic)):
        rtwp_wo_traffic = float(results_without_traffic[index]['RTWP (dBm)'])
        rtwp_with_traffic = float(results_with_traffic[index]['RTWP (dBm)'])
        results.append(round((rtwp_with_traffic - rtwp_wo_traffic), 2))
    logging.info(f'Differences={results}')
    assert max(results) >= diff, f'differences={results}'
