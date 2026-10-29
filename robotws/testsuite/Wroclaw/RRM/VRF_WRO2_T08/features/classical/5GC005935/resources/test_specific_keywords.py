import os
import re
import time
from datetime import datetime

from taf.sbts.oam.coam.admin import admin
from ute_tshark.interface import ute_tshark
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import _request_counters_from_bts
from testsuite.Wroclaw.RRM.resources.log.log import blog

api = admin()

ute_tshark = ute_tshark()
pattern_dl_cc0_tput = r'[|] DL [|] {cc: 0} [|] avgPHY'
pattern_dl_cc1_tput = r'[|] DL [|] {cc: 1} [|] avgPHY'
pattern_dl_cc1_no_tput = r'[|] DL [|] {cc: 1} [|] noGrant'
pattern_ul_cc0_tput = r'[|] UL [|] {cc: 0} [|] avgPHY'
pattern_ul_cc1_tput = r'[|] UL [|] {cc: 1} [|] avgPHY'
pattern_ul_cc1_no_tput = r'[|] UL [|] {cc: 1} [|] noGrant'

time_format = '%H:%M:%S.%f'


def wait_certain_time_after_attach(attach_time, time_passed_wanted):
    while (datetime.now() - datetime.strptime(attach_time, '%Y-%m-%d %H:%M:%S.%f')).total_seconds() < \
            int(time_passed_wanted):
        time.sleep(1)
    return


def set_rd_flags(phase):
    admin_alias = api.setup_admin(alias='admin_alias')
    if phase == 'setup':
        params = [{'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
                  {'name': 'rdFeatureFlagBitmap3', 'value': '512'},
                  {'name': 'rdFeatureFlagBitmap4', 'value': '1024'}]
    else:
        params = [{'name': 'rdFeatureFlagBitmapLevel', 'value': '0'},
                  {'name': 'rdFeatureFlagBitmap3', 'value': '0'},
                  {'name': 'rdFeatureFlagBitmap4', 'value': '0'}]
    try:
        for param in params:
            api.set_rad_debug_parameters(domain='L2PS',
                                         persistency='OneReset',
                                         name=param['name'],
                                         value=param['value'],
                                         connection=admin_alias)
    finally:
        api.teardown_admin(alias=admin_alias)


def verify_bd_b1_counter_values():
    counter_ids = ['M55139C00018', 'M55139C00019', 'M55139C00020', 'M55139C00021',
                   'M55308C00021', 'M55308C00023', 'M55308C00026', 'M55308C00035']
    admin_alias = api.setup_admin(alias='admin_alias')
    counters = _request_counters_from_bts(counter_ids=counter_ids, admin_connection=admin_alias)
    api.teardown_admin(alias=admin_alias)
    for counter in counters['BTS']['MRBTS-50819']['NRBTS-50819']['NRCELL-190']['RSADU']:
        print(f"counter {counter} last 2 values: "
              f"{list(counters['BTS']['MRBTS-50819']['NRBTS-50819']['NRCELL-190']['RSADU'][counter].values())[-2:]}")
        assert list(counters['BTS']['MRBTS-50819']['NRBTS-50819']['NRCELL-190']['RSADU'][counter].values())[-1] == 0, \
            f"counter {counter} last value not equal to 0."

    for counter in counters['BTS']['MRBTS-50819']['NRBTS-50819']['NRCELL-190']['NCELA']:
        print(f"counter {counter} last 2 values: "
              f"{list(counters['BTS']['MRBTS-50819']['NRBTS-50819']['NRCELL-190']['NCELA'][counter].values())[-2:]}")
        if counter == 'M55308C00035':
            assert \
                int(list(counters['BTS']['MRBTS-50819']['NRBTS-50819']['NRCELL-190']['NCELA'][counter].values())[-1]) \
                == 1, f"counter {counter} last value not equal to 1."
        else:
            assert \
                int(list(counters['BTS']['MRBTS-50819']['NRBTS-50819']['NRCELL-190']['NCELA'][counter].values())[-1]) \
                > 0, f"counter {counter} last value not incremented."


def wait_until_counter_collection_time(start_minutes_before=15):
    blog('waiting until time is right')
    rest = 15 - int(start_minutes_before)
    while True:
        time_now = datetime.now()
        if time_now.minute % 15 == rest and int(time_now.second) < 12:
            blog('The time is right!!!')
            return
        else:
            time.sleep(5)


def check_if_24r3(sw):
    return True if sw.split("_")[0] == 'SBTS24R3' else False


def prepare_pcap_filter(expected_bands_dl, expected_bands_ul):
    expected_bands = []
    for band in expected_bands_dl:
        if band not in expected_bands:
            expected_bands.append(band)
    for band in expected_bands_ul:
        if band not in expected_bands:
            expected_bands.append(band)
    pcap_filter = ''
    for band in expected_bands:
        if pcap_filter == '':
            pcap_filter = f"nr-rrc.FreqBandIndicatorNR == {band}"
        else:
            pcap_filter = pcap_filter + f" && nr-rrc.FreqBandIndicatorNR == {band}"
    pcap_filter = pcap_filter + " && nr-rrc.c1 == 0"
    return pcap_filter


def check_if_cell_197_subbandwidth_is_used(pcap_path, expected_bands_dl, expected_bands_ul):
    pcap_filter = prepare_pcap_filter(expected_bands_dl, expected_bands_ul)
    pcap_filter = pcap_filter + " && nr-rrc.physCellId == 197 && nr-rrc.physCellId == 198"
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    bands_message = ute_tshark.read_pcap(packet_filter=pcap_filter,
                                         pcap_file_path=pcap_path,
                                         alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)

    bandwidth_found = list(re.compile(
        r'physCellId: 197(?s:.{500,1000})FreqBandIndicatorNR: 66(?s:.{500,2000})locationAndBandwidth: 28875'
    ).findall(bands_message))
    assert len(bandwidth_found) > 0, 'Haven\'t found expected locationAndBadwidth report for cell 197'


def verify_correct_bands(pcap_path, expected_bands_dl, expected_bands_ul, target_cell=None):
    pcap_filter = prepare_pcap_filter(expected_bands_dl, expected_bands_ul)
    if target_cell == '193':
        pcap_filter = pcap_filter + ' && nr-rrc.physCellId != 197 && nr-rrc.physCellId != 198'
    elif target_cell == '190':
        pcap_filter = pcap_filter + ' && nr-rrc.physCellId != 190 && nr-rrc.physCellId != 196'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    bands_message = ute_tshark.read_pcap(packet_filter=pcap_filter,
                                         pcap_file_path=pcap_path,
                                         alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    bands_found = list(re.compile(r'FreqBandIndicatorNR: \d{1,2}').findall(bands_message))
    bands = []
    for band in bands_found:
        band = band.split(" ")[1]
        bands.append(band)
    for band in expected_bands_dl:
        assert band in bands, f"couldn\'t find band {band} in reported downlink bands"
        bands.remove(band)
    for band in expected_bands_ul:
        assert band in bands, f"couldn\'t find band {band} in reported uplink bands"
        bands.remove(band)
    assert bands == [], f"some unexpected FreqBandIndicatorNR bands were reported: {bands}"
    frequency_info_dl_found = list(re.compile(r'frequencyInfoDL').findall(bands_message))
    frequency_info_ul_found = list(re.compile(r'frequencyInfoUL').findall(bands_message))
    assert len(frequency_info_dl_found) == len(expected_bands_dl) and \
           len(frequency_info_ul_found) == len(expected_bands_ul), \
           f"wrong number of carriers reported: \n{str(len(frequency_info_dl_found))} " \
           f"downlink carrier(s) and {str(len(frequency_info_ul_found))} uplink carrier(s) reported"


def verify_scells_addition(pcap_path, expected_dl_scells=2, expected_ul_scell=1):
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    rrcreconfig_msg = ute_tshark.read_pcap(packet_filter='nr-rrc.c1 == 0 && nr-rrc.sCellIndex == 1',
                                           pcap_file_path=pcap_path,
                                           alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    freqs_found = \
        list(re.compile(r'frequencyInfo[DU]L(?s:.{50,700})absoluteFrequency.{1,6}: \d{4,7}').findall(rrcreconfig_msg))
    freqs_found = [freq[0:15] for freq in freqs_found]
    assert freqs_found.count('frequencyInfoDL') == int(expected_dl_scells), \
        'Different amount of downlink carriers in added scells was expected '
    assert freqs_found.count('frequencyInfoUL') == int(expected_ul_scell), \
        'Different amount of uplink carriers in added scells was expected'


def verify_uplink_carrier_aggregation(ue_log_path):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    second_uplink_carriers = list((re.compile(r'[|] UL [|] {cc: 2} [|]')).findall(text))
    assert len(second_uplink_carriers) > 0, "there was no uplink carrier aggregation ongoing"


def verify_gbr_only_uplink_tput(ue_log_path):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    pcell_uplink_carriers = list((re.compile(r'[|] UL [|] {cc: 0} [|] avgPHY')).findall(text))
    ca_uplink_carriers = list((re.compile(r'[|] UL [|] {cc: 1} [|] avgPHY')).findall(text))
    assert len(pcell_uplink_carriers) > 0, "there was no uplink throughput ongoing"
    assert len(ca_uplink_carriers) == 0, "there was an unexpected uplink carrier aggregation ongoing"


def verify_uplink_carrier_aggregation_on_cc_1(ue_log_path):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    second_uplink_carriers = list((re.compile(r'[|] UL [|] {cc: 1} [|] avgPHY')).findall(text))
    assert len(second_uplink_carriers) > 0, "there was no uplink carrier aggregation ongoing"


def verify_downlink_2cc_carrier_aggregation(ue_log_path):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    downlink_carriers = list((re.compile(r'[|] DL [|] {cc: \d{1}} [|] avgPHY')).findall(text))
    assert '| DL | {cc: 0} | avgPHY' in downlink_carriers, 'downlink throughput hasn\'t been verified'
    assert '| DL | {cc: 1} | avgPHY' in downlink_carriers, 'downlink throughput CA hasn\'t been verified'


def verify_uplink_tput_pcell_only(ue_log_path):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    pcell_uplink_carriers = list((re.compile(r'[|] UL [|] {cc: 0} [|]')).findall(text))
    second_uplink_carriers = list((re.compile(r'[|] UL [|] {cc: 2} [|]')).findall(text))
    assert len(pcell_uplink_carriers) > 0, "there was no uplink throughput ongoing"
    assert len(second_uplink_carriers) == 0, "there was an unexpected uplink carrier aggregation ongoing"


def check_bler(bler_reported):
    for bler in bler_reported:
        bler_value = int(bler.split(" ")[-1])
        if bler_value > 9:
            blog(f"BLER was higher than expected: {str(bler_value)}%.")


def verify_carrier_aggregation_ongoing_both_ways(ue_log_path, expected_ccs_dl, expected_ccs_ul, fail_if_nogrants=False):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    for cc in expected_ccs_dl:
        pattern = rf'[|] DL [|] {{cc: {cc}}} [|] avgPHY'
        prints = list((re.compile(pattern)).findall(text))
        assert len(prints) > 0, f"downlink carrier {str(cc)} throughput hasn\'t been verified"
    for cc in expected_ccs_ul:
        pattern = rf'[|] UL [|] {{cc: {cc}}} [|] avgPHY'
        prints = list((re.compile(pattern)).findall(text))
        assert len(prints) > 0, f"uplink carrier {str(cc)} throughput hasn\'t been verified"
    nogrants_found = list((re.compile(r'noGrant: true')).findall(text))
    bler_reported = list((re.compile(r'BLER.%:\s{1,2}\d{1,2}')).findall(text))
    if fail_if_nogrants:
        assert len(nogrants_found) == 0, 'found noGrant prints during full buffer throughput'
    else:
        if len(nogrants_found) > 0:
            blog(f"found {len(nogrants_found)} noGrant prints during full buffer throughput!")
    check_bler(bler_reported)


def verify_carrier_aggregation_during_vonr_call(ue_log_path, cell_aggr_level_eligible=True):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    prints = list((re.compile(pattern_dl_cc0_tput)).findall(text))
    assert len(prints) > 0, "downlink carrier 0 throughput hasn\'t been verified"
    prints = list((re.compile(pattern_dl_cc1_tput)).findall(text)) if cell_aggr_level_eligible \
        else list((re.compile(pattern_dl_cc1_no_tput)).findall(text))
    assert len(prints) > 0, "downlink carrier 1 throughput hasn\'t been verified"
    prints = list((re.compile(pattern_ul_cc0_tput)).findall(text))
    assert len(prints) > 0, "uplink carrier 0 throughput hasn\'t been verified"
    prints = list((re.compile(pattern_ul_cc1_no_tput)).findall(text))
    assert len(prints) > 0, "uplink carrier 1 throughput hasn\'t been verified"


def verify_carrier_aggregation_with_cellaggrlevel_not_eligible(ue_log_path):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    prints = list((re.compile(pattern_dl_cc0_tput)).findall(text))
    assert len(prints) > 0, "downlink carrier 0 throughput hasn\'t been verified"
    prints = list((re.compile(pattern_dl_cc1_no_tput)).findall(text))
    assert len(prints) > 0, "downlink carrier 1 throughput hasn\'t been verified"
    prints = list((re.compile(pattern_ul_cc0_tput)).findall(text))
    assert len(prints) > 0, "uplink carrier 0 throughput hasn\'t been verified"
    prints = list((re.compile(pattern_ul_cc1_tput)).findall(text))
    assert len(prints) > 0, "uplink carrier 1 throughput hasn\'t been verified"
    bler_reported = list((re.compile(r'BLER.%:\s{1,2}\d{1,2}')).findall(text))
    check_bler(bler_reported)


def verify_uplink_carrier_aggregation_with_low_tput_downlink(ue_log_path):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    uplink_carriers = list((re.compile(r'[|] UL [|] {cc: \d{1}} [|] avgPHY')).findall(text))
    downlink_carriers = list((re.compile(r'[|] DL [|] {cc: \d{1}} [|] \w{6,7}')).findall(text))
    assert '| UL | {cc: 0} | avgPHY' in uplink_carriers and '| UL | {cc: 2} | avgPHY' in uplink_carriers, \
        'some uplink carriers haven\'t been verified'
    assert '| DL | {cc: 0} | avgPHY' in downlink_carriers and \
           (('| DL | {cc: 2} | noGrant' in downlink_carriers) or ('| DL | {cc: 2} | avgPHY' in downlink_carriers)), \
        'some downlink carriers haven\'t been verified'


def verify_low_uplink_and_downlink_throughput(ue_log_path):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    uplink_carriers = list((re.compile(r'[|] UL [|] {cc: \d{1}} [|] avgPHY')).findall(text))
    downlink_carriers = list((re.compile(r'[|] DL [|] {cc: \d{1}} [|] avgPHY')).findall(text))
    assert '| UL | {cc: 0} | avgPHY' in uplink_carriers, 'uplink throughput hasn\'t been verified'
    assert '| UL | {cc: 2} | avgPHY' not in uplink_carriers, 'some unexpected uplink carriers have been found'
    assert '| DL | {cc: 0} | avgPHY' in downlink_carriers, 'downlink throughput hasn\'t been verified'
    assert '| DL | {cc: 1} | avgPHY' not in downlink_carriers and '| DL | {cc: 2} | avgPHY' not in downlink_carriers, \
           'some unexpected downlink carriers have been found'


def verify_downlink_carrier_aggregation_with_low_uplink_throughput(ue_log_path):
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    uplink_carriers = list((re.compile(r'[|] UL [|] {cc: \d{1}} [|] avgPHY')).findall(text))
    uplink_nogrants = list((re.compile(r'[|] UL [|] {cc: 2} [|] noGrant')).findall(text))
    downlink_carriers = list((re.compile(r'[|] DL [|] {cc: \d{1}} [|] avgPHY')).findall(text))
    assert '| UL | {cc: 0} | avgPHY' in uplink_carriers and '| UL | {cc: 2} | avgPHY' not in uplink_carriers\
           and len(uplink_nogrants) > 0, 'uplink throughput hasn\'t been verified'
    assert '| DL | {cc: 0} | avgPHY' in downlink_carriers and '| DL | {cc: 1} | avgPHY' in downlink_carriers and \
           '| DL | {cc: 2} | avgPHY' in downlink_carriers, 'some downlink carriers haven\'t been verified'


def verify_expected_scell_state_change(ue_log_path, expected_state, scell_index):
    assert expected_state == 'ACTIVATED' or expected_state == 'CONFIGURED', \
        'expected state can be only ACTIVATED or CONFIGURED'
    assert scell_index == '1' or scell_index == '2', 'Scell index can only be 1 or 2'
    with open(ue_log_path, 'r', errors='ignore') as f:
        text = f.read()
    state_changed_prints = list(re.compile(r', To State = {}, Cause = MAC-CE, Scell Index = {}'.
                                           format(expected_state, scell_index)).findall(text))
    assert len(state_changed_prints) > 0, 'Haven\'t found the wanted State Change print'
    assert 2 > len(state_changed_prints), 'Found more State Change prints than expected'


def verify_scelltoaddmodlist_for_cell_196(pcap_message):
    scelltoaddmodlist_regex = re.compile(r'sCellToAddModList(?s:.{200,500})sCellIndex: 1(?s:.{200,500})physCellId: '
                                         r'196(?s:.{100,400})frequencyInfoDL(?s:.{6000,9000})frequencyInfoUL')
    scelltoaddmodlist_found = list(scelltoaddmodlist_regex.findall(pcap_message))
    assert len(scelltoaddmodlist_found) == 1, 'Unable to verify proper sCellToAddModList info'


def verify_scelltoaddmodlist_for_cells_197_198(pcap_message):
    scelltoaddmodlist_197_regex = re.compile(r'sCellToAddModList(?s:.{200,500})sCellIndex: 1(?s:.{200,500})physCellId: '
                                             r'197(?s:.{100,400})frequencyInfoDL(?s:.{6000,9000})frequencyInfoUL')
    scelltoaddmodlist_198_regex = re.compile(r'sCellIndex: 2(?s:.{200,500})physCellId: '
                                             r'198(?s:.{100,400})frequencyInfoDL')
    cell_197_found = list(scelltoaddmodlist_197_regex.findall(pcap_message))
    cell_198_found = list(scelltoaddmodlist_198_regex.findall(pcap_message))
    assert len(cell_197_found) > 0 and len(cell_198_found) > 0, 'CA configuration not as expected'


def verify_scelltoaddmodlist_for_cells_190_196(pcap_message):
    scelltoaddmodlist_190_regex = re.compile(r'sCellToAddModList(?s:.{200,500})sCellIndex: 1(?s:.{200,500})physCellId: '
                                             r'190(?s:.{100,400})frequencyInfoDL(?s:.{6000,9000})frequencyInfoUL')
    scelltoaddmodlist_196_regex = re.compile('sCellIndex: 2(?s:.{200,500})physCellId: '
                                             '196(?s:.{100,400})frequencyInfoDL')
    cell_190_found = list(scelltoaddmodlist_190_regex.findall(pcap_message))
    cell_196_found = list(scelltoaddmodlist_196_regex.findall(pcap_message))
    assert len(cell_190_found) > 0 and len(cell_196_found) > 0, 'CA configuration not as expected'


def verify_scelltoaddmodlist_for_cell(pcap_message, cell, scellindex):
    scelltoaddmodlist_regex = re.compile(fr'sCellToAddModList(?s:.{{200,500}})sCellIndex: '
                                         fr'{str(scellindex)}(?s:.{{200,500}})physCellId: '
                                         fr'{str(cell)}(?s:.{{100,400}})frequencyInfoDL'
                                         fr'(?s:.{{6000,9000}})frequencyInfoUL')
    scelltoaddmodlist_found = list(scelltoaddmodlist_regex.findall(pcap_message))
    assert len(scelltoaddmodlist_found) == 1, 'Unable to verify proper sCellToAddModList info'


def verify_scell_swap(pcap_path, target_cell):
    scellindex = '3' if target_cell == '195' else '1'
    scellindex_release = '1' if target_cell == '195' else '3'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    rrcreconfig_msg = ute_tshark.read_pcap(packet_filter='nr-rrc.c1 == 0',
                                           pcap_file_path=pcap_path,
                                           alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    verify_scelltoaddmodlist_for_cell(rrcreconfig_msg, target_cell, scellindex)
    scelltorelease_regex = re.compile(fr'sCellToReleaseList: 1 item(?s:.{{100,300}})SCellIndex: {scellindex_release}')
    scelltorelease_found = list(scelltorelease_regex.findall(rrcreconfig_msg))
    assert len(scelltorelease_found) == 1, 'Unable to verify sCellToReleaseList'


def verify_correct_scell_in_attach_pcap(pcap_path):
    pcap_filter = 'nr-rrc.sCellIndex == 1 && nr-rrc.c1 == 0'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    rrcreconfig_msg = ute_tshark.read_pcap(packet_filter=pcap_filter,
                                           pcap_file_path=pcap_path,
                                           alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    verify_scelltoaddmodlist_for_cell_196(rrcreconfig_msg)


def verify_handover(pcap_path, target_cell):
    scells_filter = 'nr-rrc.c1 == 0  && nr-rrc.physCellId == 198 ' \
                    '&& nr-rrc.physCellId == 197 && nr-rrc.physCellId != 190' if target_cell == '190' \
        else 'nr-rrc.c1 == 0  && nr-rrc.physCellId == 190 && nr-rrc.physCellId == 196 && nr-rrc.physCellId != 193'
    handover_rrcreconfig_filter = 'nr-rrc.physCellId == 193 && nr-rrc.physCellId != 190 && nr-rrc.physCellId != 196 ' \
                                  '&& nr-rrc.c1 == 0 && nr-rrc.freqBandIndicatorNR == 66' if target_cell == '193' \
        else 'nr-rrc.physCellId != 193 && nr-rrc.physCellId == 190 && nr-rrc.physCellId != 196 && nr-rrc.c1 == 0 && ' \
             'nr-rrc.freqBandIndicatorNR == 71'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    scells_msg = ute_tshark.read_pcap(packet_filter=scells_filter,
                                      pcap_file_path=pcap_path,
                                      alias=pcap_alias)
    handover_rrcreconfig_msg = ute_tshark.get_packets_count(packet_filter=handover_rrcreconfig_filter,
                                                            pcap_file_path=pcap_path,
                                                            alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    if target_cell == '193':
        verify_scelltoaddmodlist_for_cells_190_196(scells_msg)
    else:
        verify_scelltoaddmodlist_for_cells_197_198(scells_msg)
    assert handover_rrcreconfig_msg == 1, \
        f"found more than one rrcReconfiguration message for cell {target_cell} handover"


def verify_syslog_prints(syslogs_folder_path, mandatory_prints, possible_prints, verify_cgcactivated_last=True):
    lines = []
    for filename in sorted(os.listdir(syslogs_folder_path)):
        filepath = os.path.join(syslogs_folder_path, filename)
        for line in file_reader(filepath):
            if any(log in line for log in mandatory_prints + possible_prints):
                lines.append(line)
    for line in lines:
        blog(line)
    for mandatory_print in mandatory_prints:
        assert mandatory_print in str(lines), f'no \'{mandatory_print}\' print found'
    if verify_cgcactivated_last:
        if len(lines) > 0:
            if 'CGWAITFORDEACTIVATIONCONFIRM' in lines[-1]:
                blog('CGWAITFORDEACTIVATIONCONFIRM print has been found as the last one.')
                assert 'entering state:CGACTIVATED' in lines[-2], "CGACTIVATED print wasn't even second to last"
                blog("found CGACTIVATED print as second to last print")
                time_of_wait_for_activation_confirm_print = lines[-1].split(" ")[2]
                time_of_cgactivated_print = lines[-2].split(" ")[2]
                time_diff = int((datetime.strptime(time_of_wait_for_activation_confirm_print, time_format) -
                                 datetime.strptime(time_of_cgactivated_print, time_format)).total_seconds()*1000)
                assert time_diff < 1500, \
                    f'the messages were too far apart from each other though ({time_diff} seconds)'
                blog("But the messages were printed about the same time")
            else:
                assert 'CGWAITFORDEACTIVATIONCONFIRM' not in lines[-1], \
                    'CGWAITFORDEACTIVATIONCONFIRM print found after last CGACTIVATED print.'


def verify_transform_precoder_enabling(qxdm_log_path):
    with open(qxdm_log_path, 'r', errors='ignore') as f:
        text = f.read()
    assert 'transformPrecoder enabled' in text, 'transform precoder hasn\'t been enabled'


def analyze_bd_b1_step3(step_3_ue_log, step_3_syslogs):
    mand_prints_s3 = ['entering state:CGACTIVATED', 'ActionMacCeForActivationReceived']
    poss_prints_s3 = ['entering state:CGCONFIGURED', 'leaving state:CGCONFIGURED',
                      'leaving state:CGWAITFORDEACTIVATIONCONFIRM']
    verify_gbr_only_uplink_tput(step_3_ue_log)
    blog("========== STEP 3 SYSLOG PRINTS: ==========")
    verify_syslog_prints(step_3_syslogs, mandatory_prints=mand_prints_s3, possible_prints=poss_prints_s3)


def analyze_bd_b1_step4(step_4_ue_log, step_4_syslogs):
    mand_prints_s4 = ['leaving state:CGWAITFORDEACTIVATIONCONFIRM', 'entering state:CGCONFIGURED']
    poss_prints_s4 = []
    verify_uplink_carrier_aggregation_on_cc_1(step_4_ue_log)
    blog("========== STEP 4 SYSLOG PRINTS: ==========")
    verify_syslog_prints(step_4_syslogs, mandatory_prints=mand_prints_s4, possible_prints=poss_prints_s4,
                         verify_cgcactivated_last=False)


def analyze_bd_b1_step5(step_5_ue_log, step_5_syslogs):
    mand_prints_s5 = ['entering state:CGACTIVATED']
    poss_prints_s5 = ['entering state:CGCONFIGURED', 'leaving state:CGWAITFORDEACTIVATIONCONFIRM']
    verify_gbr_only_uplink_tput(step_5_ue_log)
    blog("========== STEP 5 SYSLOG PRINTS: ==========")
    verify_syslog_prints(step_5_syslogs, mandatory_prints=mand_prints_s5, possible_prints=poss_prints_s5)


def analyze_bd_b1_step6(step_6_ue_log, step_6_syslogs):
    mand_prints_s6 = []
    poss_prints_s6 = ['entering state:CGACTIVATED', 'leaving state:CGWAITFORDEACTIVATIONCONFIRM']
    verify_gbr_only_uplink_tput(step_6_ue_log)
    blog("========== STEP 6 SYSLOG PRINTS: ==========")
    verify_syslog_prints(step_6_syslogs, mandatory_prints=mand_prints_s6, possible_prints=poss_prints_s6)


def analyze_bd_b1_step8(step_8_ue_log, step_8_syslogs):
    mand_prints_s8 = ['entering state:CGACTIVATED']
    poss_prints_s8 = ['entering state:CGACTIVATED', 'leaving state:CGCONFIGURED',
                      'leaving state:CGWAITFORDEACTIVATIONCONFIRM', 'ActionMacCeForActivationReceived']
    verify_uplink_carrier_aggregation_on_cc_1(step_8_ue_log)
    blog("========== STEP 8 SYSLOG PRINTS: ==========")
    verify_syslog_prints(step_8_syslogs, mandatory_prints=mand_prints_s8, possible_prints=poss_prints_s8)


def analyze_bd_b1_step9(step_9_ue_log):
    verify_transform_precoder_enabling(step_9_ue_log)


def tshark_teardown():
    ute_tshark.teardown_tshark(alias='f1ap_pcap')
