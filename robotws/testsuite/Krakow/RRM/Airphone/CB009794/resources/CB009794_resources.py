"""
:copyright: Nokia Networks
:authors:
    Jakub Grela <jakub.grela@nokia.com>
    Maciej Majewski <maciej.majewski@nokia.com>
    Michal Obszarny <michal.obszarny@nokia.com>
    Tomasz Siuta <tomasz.siuta@nokia.com>
    Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
    Patryk Wojcik <patryk.wojcik@nokia.com>
:maintainers:
    Jakub Grela <jakub.grela@nokia.com>
    Maciej Majewski <maciej.majewski@nokia.com>
    Michal Obszarny <michal.obszarny@nokia.com>
    Tomasz Siuta <tomasz.siuta@nokia.com>
    Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
    Patryk Wojcik <patryk.wojcik@nokia.com>
"""
import math
from ta5g_pm_counters import ta5g_pm_counters
from taf.transport.ssh import ssh
from robot.api import logger
from robot.errors import ExecutionFailed
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers
from ta_emss import ta_emss

csv_bip = csv_verifiers()

NR_RTWP_COUNTERS_MOID = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'


def get_rtwp_counters(cell_id="NRCELL-1"):
    """
    Function that gets RTWP counters
    +------------------+-------+------------+------------+------------+
    |     Example                                                     |
    +==================+=======+============+============+============+
    | counter_list = get_rtwp_counters(cell_id)                       |
    +------------------+-------+------------+------------+------------+
    :param cell_id: ID of Cell
    """
    emss = ta_emss(host='10.0.1.1', port=16463)
    parse_pm_file_command = emss.emssim.cmd_parse_pm_file()
    parse_pm_file_command.run()
    counter_dict = parse_pm_file_command.returned_data()
    counter_list = counter_dict.get("measurement_table")
    counters = [d for d in counter_list if d['measurement'] in 'NRRTP(M55369)']
    rtwp_counters_list = [d for d in counters if d['object'] in 'DN:NE-NRBTS-1/'+cell_id]
    return rtwp_counters_list[0].get('table')


def get_rtwp_counters_as_dict_for_vran(cell_id="NRCELL-1"):
    """
    Function that gets RTWP counters as dict
    +------------------+-------+------------+------------+------------+
    |     Example                                                     |
    +==================+=======+============+============+============+
    | ${pm_counters}=  Get RTWP counters as dict for vran             |
    +------------------+-------+------------+------------+------------+
    :param cell_id: ID of Cell
    """
    rtwp_counters_list = get_rtwp_counters(cell_id)
    dict_of_counters = dict()
    for rtwp_counter in rtwp_counters_list:
        dict_of_counters[rtwp_counter['COUNTER']] = float(rtwp_counter['T1'])
    return dict_of_counters


def fix_csv_headers(csv_file, num_of_ues=1):
    """
    fix_csv_headers - fixes headers for varied amount of UEs
    +------------------+-------+------------+------------+------------+------------+
    |     Example                                                                  |
    +==================+=======+============+============+============+============+
    | fix csv headers  ${OUTPUT_DIR}/BIP_LOGS/${alias}/BIP.csv  ${num_of_ues}      |
    +------------------+-------+------------+------------+------------+------------+
    :param csv_file:        path to file
    :param num_of_ues:      describes amount of UEs
    :return:                file with fixed headers
    """
    with open(csv_file) as input_file:
        lines = input_file.read().splitlines()
    logger.info(f'Length of file={len(lines)}')
    new_headers = []
    for header in lines[0].split(','):
        first_word = header.split('.')[0]
        last_word = header.split('.')[-1]
        if last_word in ('subcellid', 'slot', 'sfn'):
            new_headers.append(f'{first_word}.{last_word}')
        elif last_word in ('rnti', 'startPrb', 'numOfPrb', 'fakeUe', 'pairedUe'):
            for i in range(0, num_of_ues):
                new_headers.append(f'{first_word}.UE{i + 1}_{last_word}')
        elif last_word in ('linRssiOfAnt', 'linNoiseOfAnt'):
            for i in range(0, num_of_ues):
                for j in range(0, 4):
                    new_headers.append(f'{first_word}.UE{i + 1}_{last_word}_{j}')
    lines[0] = ','.join(new_headers)
    with open(csv_file, 'w') as output_file:
        output_file.write('\n'.join(lines) + '\n')


def correct_line_if_two_antennas_were_used(line, num_of_ues, missing_ues, num_of_ants):
    """
    correct_line_if_two_antennas_were_used - corrects line if configuration with two antennas was used.
    verify_if_two_antennas_were_used - verifies if configuration with two antennas was used.
    For configuration with two antennas only 2xRSSI and 2xNOISE appears in csv file.
    Function will append two additional zeros for 3rd and 4th antennas for both RSSI and NOISE.
    +------------------+-------+------------+------------+------------+------------+
    |     Example                                                                  |
    +==================+=======+============+============+============+============+
    |  line=correct_line_if_two_antennas_were_used(line, missing_ues, num_of_ues)  |
    +------------------+-------+------------+------------+------------+------------+
    :param line:         single line with response from bip.csv file
    :param num_of_ues:   number of attached UEs
    :param missing_ues:  number of UEs which were attached but not scheduled
    :param num_of_ants:  number of ants which were used
    :return:             corrected line if configuration with two antennas was used, else line without any change
    """
    if num_of_ants == 2:
        for index in range(len(line), len(line) - (num_of_ues - missing_ues) * 4, -2):
            line[index:index] = ['0', '0']
    return line


def fix_request_csv_values(line, num_of_ues):
    """
    fix_request_csv_values - fixes values for varied amount of UEs for request.
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | line = fix_request_csv_values(line, num_of_ues)    |
    +------------------+-------+------------+------------+
    :param line:            single line with request
    :param num_of_ues:      describes amount of UEs
    :return:                request line with fixed values
    """
    missing_ues = num_of_ues - int((len(line) - 5) / 5)
    # add missing rnti, numOfPrb, startPrb, fakeUe, pairedUe for missing UEs
    for x in range(3 + num_of_ues - missing_ues, 4 + 5 * num_of_ues - missing_ues, num_of_ues):
        for _ in range(missing_ues):
            line.insert(x, '0')
    return line


def fix_response_csv_values(line, num_of_ues, num_of_ants):
    """
    fix_response_csv_values - fixes values for varied amount of UEs for response.
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | line = fix_response_csv_values(line, num_of_ues)   |
    +------------------+-------+------------+------------+
    :param line:            single line with response
    :param num_of_ues:      describes amount of UEs
    :param num_of_ants:  number of ants which were used
    :return:                response line with fixed values
    """
    missing_ues = max(3 + num_of_ues - line.index(''), 0)
    # add rssi and noise to fulfill to 4 antennas ir configuration with two antennas was used
    line = correct_line_if_two_antennas_were_used(line, num_of_ues, missing_ues, num_of_ants)
    # add rnti for missing UEs
    line[3 + num_of_ues - missing_ues:3 + num_of_ues - missing_ues] = ['0' for _ in range(missing_ues)]
    # add num_of_prbs,first_prb,fakeUe, paired for all UEs apart from first
    line[3 + num_of_ues:3 + num_of_ues] = ['' for _ in range(4 * (num_of_ues - 1))]
    # rssi and noise for missing UEs
    index_of_missing_rssi = 3 + num_of_ues * 5 + 4 * (num_of_ues - missing_ues)
    line[index_of_missing_rssi:index_of_missing_rssi] = ['0' for _ in range(4) for _ in range(missing_ues)]
    line[len(line):len(line)] = ['0' for _ in range(4) for _ in range(missing_ues)]
    return line


def fix_csv_values_for_uldata(csv_file, num_of_ues=1, num_of_ants=2):
    """
    fix_csv_values_for_uldata - fixes values for varied amount of UEs. Function fulfils rows with missing values
    (eg. because scheduler used only one UE for grant when two were predicted) to generate more useful csv file.
    +------------------+-------+------------+------------+------------+------------+------------+
    |     Example                                                                               |
    +==================+=======+============+============+============+============+============+
    | fix csv values for uldata  ${OUTPUT_DIR}/BIP_LOGS/${alias}/BIP_PUSCH.csv  ${num_of_ues}   |
    +------------------+-------+------------+------------+------------+------------+------------+
    :param csv_file:        path to file
    :param num_of_ues:      describes amount of UEs
    :param num_of_ants:     number of ants which were used
    :return:                csv file with fixed values
    """
    with open(csv_file) as input_file:
        lines = input_file.read().splitlines()
    for index in range(1, len(lines)):
        line = lines[index].split(',')
        if verify_if_line_is_request(line):
            line = fix_request_csv_values(line, num_of_ues)
        else:
            line = fix_response_csv_values(line, num_of_ues, num_of_ants)
        lines[index] = ','.join(line)
    with open(csv_file, 'w') as output_file:
        output_file.write('\n'.join(lines) + '\n')


def verify_if_line_is_request(line):
    """
    verify_if_line_is_request - verifies if line is a request. If last element of list is empty, it will be request,
    otherwise line will be resonse.
    Example of request with one UE and two antennas:
    ['0', '591', '14', '65521', '247', '13', '1', '0', '', '']
    Example of response with one UE and two antennas:
    ['0', '592', '4', '65521', '', '', '', '', '1587', '1536', '1587', '1536']
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | if verify_if_line_is_request(line):                |
    +------------------+-------+------------+------------+
    :param line:            single line with request or response
    :return:                request line with fixed values
    """
    if line[-1] == '':
        return True
    else:
        return False


def find_first_and_last_sfn(csv_path):
    """
    find_first_and_last_sfn - finds the first and the last sfn which algorithm will use to calculate data
    +------------------+-------+------------+
    |     Example                           |
    +==================+=======+============+
    | find_first_and_last_line(csv_path)    |
    +------------------+-------+------------+
    :param csv_path:   path to file
    :return:           first and last index of sfn which will be calculated
    """
    csv_list = csv_bip.create_list_of_lists_from_csv(csv_path)
    first_sfn, last_sfn = int(csv_list[1][1]) + 1, int(csv_list[-1][1]) + 1
    last_sfn = last_sfn if last_sfn > first_sfn else last_sfn + 1023
    used_sfn_ranges = []
    first_range_sfn = first_sfn - 99
    last_absolute_sfn = first_sfn + 1
    while True:
        last_absolute_sfn += 100
        first_range_sfn = (first_range_sfn + 100) % 1024
        last_range_sfn = (first_range_sfn + 99) % 1024
        if last_absolute_sfn <= last_sfn:
            used_sfn_ranges.append((first_range_sfn, last_range_sfn))
        else:
            break
    return used_sfn_ranges[0][0], used_sfn_ranges[-1][-1]


def find_first_and_last_line(csv_list):
    """
    find_first_and_last_line - finds the first and the last line which algorithm will use to calculate data
    +------------------+-------+------------+
    |     Example                           |
    +==================+=======+============+
    | find_first_and_last_line(csv_list)    |
    +------------------+-------+------------+
    :param csv_list:  list with corrected values
    :return:          first and last index of values which will be calculated
    """
    first_sfn, last_sfn = (int(csv_list[1][1]) + 2) % 1024, (int(csv_list[-1][1]) + 1) % 1024
    num_of_slots = len(list(set([line[2] for line in csv_list[1:]])))
    start_index = 0
    for index in range(1, len(csv_list)):
        if int(csv_list[index][1]) == first_sfn:
            start_index = index
            break
    end_index = start_index + 1
    while end_index + num_of_slots * 2 * 100 <= len(csv_list):
        end_index += num_of_slots * 2 * 100
    return start_index, end_index


def generate_keys_for_req_and_resps(csv_list):
    """
    generate_keys_for_req_and_resps - generate headers for both requests and responses
    +------------------+------------+------------+------------+------------+
    |     Example                                                           |
    +------------------+------------+------------+------------+------------+
    | reqs_keys, resps_keys = generate_keys_for_req_and_resps(csv_list)    |
    +------------------+------------+------------+------------+------------+
    :param csv_list:   list with fixed values
    :return:           generated headers for requests and responses
    """
    headers_for_resps = []
    headers_for_reqs = []
    for header in csv_list[0]:
        first_word = header.split('.')[0]
        last_word = header.split('.')[-1]
        if first_word == '3gpp':
            headers_for_reqs.append(last_word)
            headers_for_resps.append(last_word)
        elif first_word in ('UlData_UePuschReceiveRespPs_t', 'UlData_puschAntMeas_t'):
            headers_for_resps.append(last_word)
        elif first_word == 'UlData_puschReceiveReqGrant_t':
            headers_for_reqs.append(last_word)
    logger.info(f'Headers for requests:\n{headers_for_reqs}')
    logger.info(f'Headers for responses:\n{headers_for_resps}')
    return headers_for_reqs, headers_for_resps


def generate_requests_and_responses(csv_list, reqs_keys, resps_keys):
    """
    generate_requests_and_responses - generate list of dictionaries for both requests and responses
    +------------------+------------+------------+------------+------------+------------+
    |     Example                                                                       |
    +------------------+------------+------------+------------+------------+------------+
    | reqs, resps = generate_requests_and_responses(csv_list, reqs_keys, resps_keys)    |
    +------------------+------------+------------+------------+------------+------------+
    :param csv_list:     list with fixed values
    :param reqs_keys:    list of keys for requests
    :param resps_keys:   list of keys for responses
    :return:             generated list of dictionaries for requests and responses
    """
    first_line, last_line = find_first_and_last_line(csv_list)
    list_reqs, list_resps = [], []
    for line in csv_list[first_line:last_line + 1]:
        line = [int(x) for x in line if x != '']
        if len(line) == len(resps_keys):
            resp = {}
            for x in range(0, len(line)):
                resp[f'{resps_keys[x]}'] = line[x]
            list_resps.append(resp)
        elif len(line) == len(reqs_keys):
            req = {}
            for x in range(0, len(line)):
                req[f'{reqs_keys[x]}'] = line[x]
            list_reqs.append(req)
    logger.info(f'len(list_reqs)={len(list_reqs[:-1])}, len(list_resps)={len(list_resps[1:])}')
    assert len(list_resps) == len(list_reqs), \
        f'len(list_reqs)={len(list_reqs[:-1])} should be equal to len(list_resps)={len(list_resps[1:])}. '
    return list_reqs[:-1], list_resps[1:]


def get_rssi_and_noise_per_stream_sfn_and_slot(req, resp,  mimo, ant, num_of_ues):
    """
    get_rssi_and_noise_per_stream_sfn_and_slot - cumulated rssi and noise per stream, sfn and slot
    +------------------+------------+------------+------------+------------+------------+
    |     Example                                                                       |
    +------------------+------------+------------+------------+------------+------------+
    | rssi_per_ant_per_sfn, noise_per_ant_per_sfn =                                     |
    |                get_rssi_and_noise_per_stream_sfn_and_slot(                        |
    |                req, resp, mimo, ant, num_of_ues)                                  |
    +------------------+------------+------------+------------+------------+------------+
    :param req:         request per one slot
    :param resp:        response per one slot
    :param mimo:        parameter check if MU MIMO configuration was used
    :param ant:         used antenna
    :param num_of_ues:  describes amount of UEs
    :return:            cumulated rssi and noise per antenna per sfn and slot
    """
    if mimo and req['UE2_pairedUe'] == req['UE1_rnti'] and req['UE1_pairedUe'] == req['UE2_rnti']:
        return get_rssi_and_noise_stream_sfn_and_slot_when_mimo_is_enabled_and_ues_are_paired(req, resp, ant)
    return get_rssi_and_noise_stream_sfn_and_slot_when_mimo_is_disabled(req, resp, ant, num_of_ues)


def get_rssi_and_noise_stream_sfn_and_slot_when_mimo_is_disabled(req, resp, ant, num_of_ues):
    """
    get_rssi_and_noise_stream_sfn_and_slot_when_mimo_is_disabled - cumulated rssi and noise per stream, sfn and slot
    when mimo is disabled.
    +------------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    | return get_rssi_and_noise_stream_sfn_and_slot_when_mimo_is_disabled(req, resp, ant, num_of_ues)|
    +------------------+------------+------------+------------+------------+------------+------------+
    :param req:         request per one slot
    :param resp:        response per one slot
    :param ant:         used antenna
    :param num_of_ues:  describes amount of UEs
    :return:            cumulated rssi and noise per antenna per sfn and slot
    """
    rssi_per_ant_per_sfn, noise_per_ant_per_sfn = 0, 0
    for ue in range(1, num_of_ues + 1):
        num_of_prb = f'UE{str(ue)}_numOfPrb'
        rssi = f'UE{ue}_linRssiOfAnt_{ant}'
        noise = f'UE{ue}_linNoiseOfAnt_{ant}'
        if resp[rssi] > 10:
            rssi_per_ant_per_sfn += resp[rssi] * req[num_of_prb]
            noise_per_ant_per_sfn += resp[noise] * req[num_of_prb]
    return rssi_per_ant_per_sfn, noise_per_ant_per_sfn


def get_rssi_and_noise_stream_sfn_and_slot_when_mimo_is_enabled_and_ues_are_paired(req, resp, ant):
    """
    get_rssi_and_noise_stream_sfn_and_slot_when_mimo_is_enabled_and_ues_are_paired - cumulated rssi and noise per
    stream, sfn and slot when mimo is enabled and UEs are paired.
    +------------------+------------+------------+------------+------------+------------+------------+----------------+
    |     Example                                                                                                     |
    +------------------+------------+------------+------------+------------+------------+------------+----------------+
    |return get_rssi_and_noise_stream_sfn_and_slot_when_mimo_is_enabled_and_ues_are_paired(req, resp, ant, num_of_ues)|
    +------------------+------------+------------+------------+------------+------------+------------+----------------+
    :param req:         request per one slot
    :param resp:        response per one slot
    :param ant:         used antenna
    :return:            cumulated rssi and noise per antenna per sfn and slot when ues are paired and mimo is enabled
    """
    num_of_prb = max(req['UE1_numOfPrb'], req['UE2_numOfPrb'])
    rssi1 = f'UE1_linRssiOfAnt_{ant}'
    rssi2 = f'UE2_linRssiOfAnt_{ant}'
    noise1 = f'UE1_linNoiseOfAnt_{ant}'
    noise2 = f'UE2_linNoiseOfAnt_{ant}'
    rssi, noise = max(resp[rssi1], resp[rssi2]), max(resp[noise1], resp[noise2])
    rssi_per_ant_per_sfn = rssi * num_of_prb
    noise_per_ant_per_sfn = noise * num_of_prb
    return rssi_per_ant_per_sfn, noise_per_ant_per_sfn


def get_rssi_and_noise_per_spatial_stream(reqs, resps, num_of_ues, num_of_slots, mimo):
    """
    get_rssi_and_noise_per_spatial_stream - cumulated rssi and noise per stream per second
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                                 |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    | rssis, noises = get_rssi_and_noise_per_spatial_stream(reqs, resps, num_of_ues, num_of_slots, mimo)          |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    :param reqs:         list of requests
    :param resps:        list of responses
    :param num_of_ues:   describes amount of UEs
    :param num_of_slots: number of used slots
    :param mimo:         parameter check if MU MIMO configuration was used
    :return:             cumulated rssi and noise per stream per second
    """
    noises, rssis = [], []
    for interval in range(0, len(reqs), (num_of_slots*100)):
        rssis_per_second, noises_per_second = [], []
        for ant in range(0, 4):
            rssi_per_ant_per_sec, noise_per_ant_per_sec = 0, 0
            for index in range(interval, interval + (num_of_slots*100)):
                req, resp = reqs[index], resps[index]
                rssi_per_ant_per_sfn, noise_per_ant_per_sfn = get_rssi_and_noise_per_stream_sfn_and_slot(
                    req, resp, mimo, ant, num_of_ues)
                rssi_per_ant_per_sec += rssi_per_ant_per_sfn
                noise_per_ant_per_sec += noise_per_ant_per_sfn
            rssis_per_second.append(rssi_per_ant_per_sec)
            noises_per_second.append(noise_per_ant_per_sec)
        rssis.append(rssis_per_second)
        noises.append(noises_per_second)
    logger.info(f'linRssiOfAnt_items={rssis}')
    logger.info(f'linNoiseOfAnt_items={noises}')
    return rssis, noises


def get_prb_with_measurement(req, num_of_ues, long_pucch_start, long_pucch_num, mimo):
    """
    get_prb_with_measurement - get num of PRB with measurement per sfn and slot
    +------------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    | with_meas += get_prb_with_measurement(req, num_of_ues, long_pucch_start, long_pucch_num, mimo) |
    +------------------+------------+------------+------------+------------+------------+------------+
    :param req:              single request
    :param num_of_ues:       describes amount of UEs
    :param long_pucch_start: longPucchStartPuschPrb for the largest UL Bandwidth Part taken from tcpdump
    :param long_pucch_num:   longPucchNumPuschPrb for the largest UL Bandwidth Part taken from tcpdump
    :return:                 cumulated num of PRB with measurement per sfn and slot
    """
    if mimo and req['UE2_pairedUe'] == req['UE1_rnti'] and req['UE1_pairedUe'] == req['UE2_rnti']:
        return max(req['UE1_numOfPrb'], req['UE2_numOfPrb'])
    meas = 0
    for ue in range(1, num_of_ues + 1):
        num_of_prb_per_ue = f'UE{ue}_numOfPrb'
        start_prb_per_ue = f'UE{ue}_startPrb'
        meas -= max(req[start_prb_per_ue], long_pucch_start)
        meas += min(req[start_prb_per_ue] + req[num_of_prb_per_ue], long_pucch_start + long_pucch_num)
    return meas


def number_prb_with_and_without_measurement(reqs, num_of_ues, long_pucch_start, long_pucch_num, slots, mimo):
    """
    number_prb_with_and_without_measurement - get num of PRB with and without measurement
    +------------------+------------+------------+------------+------------+------------+------------+-------------+
    |     Example                                                                                                  |
    +------------------+------------+------------+------------+------------+------------+------------+-------------+
    | with_meas += number_prb_with_and_without_measurement(req, num_of_ues, long_pucch_start, long_pucch_num, mimo)|
    +------------------+------------+------------+------------+------------+------------+------------+-------------+
    :param reqs:             list of requests
    :param num_of_ues:       describes amount of UEs
    :param long_pucch_start: longPucchStartPuschPrb for the largest UL Bandwidth Part taken from tcpdump
    :param long_pucch_num:   longPucchNumPuschPrb for the largest UL Bandwidth Part taken from tcpdump
    :param slots:            number of slots used in configuration
    :param mimo:             describes if MU MIMO was used
    :return:                 cumulated num of PRB with and without measurement per second
    """
    prbs_with_meas, prbs_without_meas = [], []
    for interval in range(0, len(reqs), slots * 100):
        with_meas = 0
        for index in range(interval, interval + slots * 100):
            req = reqs[index]
            with_meas += get_prb_with_measurement(req, num_of_ues, long_pucch_start, long_pucch_num, mimo)
        prbs_with_meas.append(with_meas)
        prbs_without_meas.append(long_pucch_num*(slots * 100)-with_meas)
    logger.info(f'prbs_with_meas={prbs_with_meas}')
    logger.info(f'prbs_without_meas={prbs_without_meas}')
    return prbs_with_meas, prbs_without_meas


def number_prb_with_and_without_measurement_for_short_pucch_tdd_fr2(reqs, num_of_ues, num_of_slots, prbs_for_short):
    """
    number_prb_with_and_without_measurement_for_short_pucch_tdd_fr2 - get num of PRB with and without measurement
    for short pucch FR2
    +------------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    | with_meas, without_meas = number_prb_with_and_without_measurement_for_short_pucch_tdd_fr2(     |
            reqs, num_of_ues, num_of_slots, prbs_for_short)                                          |
    +------------------+------------+------------+------------+------------+------------+------------+
    :param reqs:             list of requests
    :param num_of_ues:       describes amount of UEs
    :param num_of_slots:     number of slots used in configuration
    :param prbs_for_short:   number of prbs for given configuration
    :return:                 cumulated num of PRB with and without measurement per second
    """
    prbs_with_meas, prbs_without_meas = [], []
    for interval in range(0, len(reqs), num_of_slots * 100):
        with_meas, without_meas = 0, 0
        for index in range(interval, interval + num_of_slots * 100):
            req = reqs[index]
            for ue in range(1, num_of_ues + 1):
                num_of_prb_per_ue = f'UE{ue}_numOfPrb'
                with_meas += req[num_of_prb_per_ue]
                without_meas += prbs_for_short - req[num_of_prb_per_ue]
        prbs_with_meas.append(with_meas)
        prbs_without_meas.append(without_meas)
    logger.info(f'prbs_with_meas={prbs_with_meas}')
    logger.info(f'prbs_without_meas={prbs_without_meas}')
    return prbs_with_meas, prbs_without_meas


def get_rrm_avg_in_per_prb(noises, with_meas):
    """
    get_rrm_avg_in_per_prb - get average I+N measurements per PRB
    +------------------+------------+------------+------------+------------+
    |     Example                                                          |
    +------------------+------------+------------+------------+------------+
    | rrm_avg_in_per_prb = get_rrm_avg_in_per_prb(noises, with_meas)       |
    +------------------+------------+------------+------------+------------+
    :param noises:          list of noises per second
    :param with_meas:       list of PRBs with measurements
    :return:                list for dividing noise per second by measurement per second per antenna
    """
    logger.info(f'rrmAvgINPerPRB='
                f'{[[noises[index][ant]/with_meas[index] for ant in range(0, 4)] for index in range(0, len(noises))]}')
    return [[noises[index][ant]/with_meas[index] for ant in range(0, 4)] for index in range(0, len(noises))]


def get_rrm_total_received_rssi_per_spatial_stream(rrmAvgINPerPRB, rssi, without_meas):
    """
    get_rrm_total_received_rssi_per_spatial_stream - get total rssi per spatial stream
    +------------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    | rrm_total_received_rssi_per_spatial_stream =                                                   |
    |         get_rrm_total_received_rssi_per_spatial_stream(rrm_avg_in_per_prb,rssis, without_meas) |
    +------------------+------------+------------+------------+------------+------------+------------+
    :param rrmAvgINPerPRB:  list of average noise per second per antenna
    :param rssi             list of rssi per second per antenna
    :param without_meas:    list of PRBs without measurements per second
    :return:                list for dividing noise per second by measurement per second
    """
    return [[rssi[index][ant]+rrmAvgINPerPRB[index][ant]*without_meas[index] for ant in range(0, 4)]
            for index in range(0, len(rssi))]


def convert_aw_to_dbm(aw):
    """
    convert_aw_to_dbm - converting aW values to dbm
    +------------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    |  rrm_rtwp_in_dbm = [[convert_aw_to_dbm(aW[ant]) if aW[ant] > 0 else 0 for ant in range(0, 4)]  |
    |                   for aW in rrm_rtwp_in_aw]                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    :param aw:        value given in aW
    :return:          value given in dbm
    """
    return 10 * math.log10(1000 * int(aw) * pow(10, -18))


def get_number_of_slots(reqs):
    """
    get_number_of_slots - get number of slots for given configuration
    +------------------+------------+------------+
    |     Example                                |
    +------------------+------------+------------+
    | num_of_slots = get_number_of_slots(reqs)   |
    +------------------+------------+------------+
    :param reqs:        list of requests
    :return:            number of used slots
    """
    slots = [req['slot'] for req in reqs]
    logger.info(f'number of slots={len(list(set(slots)))}')
    return len(list(set(slots)))


def convert_csv_values_to_int(csv_list):
    """
    convert_csv_values_to_int - converting csv values to int type
    +------------------+------------+------------+------------+
    |     Example                                             |
    +------------------+------------+------------+------------+
    | csv_list = convert_csv_values_to_int(csv_list)          |
    +------------------+------------+------------+------------+
    :param csv_list:   csv list
    :return:           return list with values converted to int
    """
    for line in csv_list[1:]:
        for idx in range(0, len(line)):
            line[idx] = line[idx].replace('\\', '')
            if line[idx].lower() == 'true':
                line[idx] = 1
            elif line[idx].lower() == 'false':
                line[idx] = 0
        [int(elem) for elem in line if elem != '']
    return csv_list


def filter_csv_by_subcell(csv_path, subcellid=0):
    """
    filter_csv_by_subcell - get list of datas filtered by subcell id
    +------------------+------------+------------+------------+
    |     Example                                             |
    +------------------+------------+------------+------------+
    | csv_list = filter_csv_by_subcell(csv_path, subcellid)   |
    +------------------+------------+------------+------------+
    :param csv_path:    path to csv file
    :param subcellid:   id of subcell
    :return:            csv list filtered by subcell id
    """
    csv_list = csv_bip.create_list_of_lists_from_csv(csv_path)
    column = "3gpp.subcellid"
    csv_list = csv_bip.filter_csv_by_column_value(csv_list, column_name=column, condition='==', value=subcellid)
    return csv_list


def calculate_rtwp(csv_path, num_of_ues=1, long_pucch_start=13, long_pucch_num=247, mimo=False, subcellid=0,
                   pucch='long', prbs_for_short=66):
    """
    calculate_rtwp - calculate rtwp counters
    +------------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    | ${bip_counters}=  calculate rtwp  csv_path=${OUTPUT_DIR}/BIP_LOGS/two_subcells/BIP_PUSCH.csv   |
    ...                             num_of_ues=2  mimo=True  long_pucch_start=18  long_pucch_num=237 |
    |                                                                                                |
    | ${bip_counters}=  calculate rtwp  csv_path=${OUTPUT_DIR}/BIP_LOGS/two_subcells/BIP_PUSCH.csv   |
    ...                             num_of_ues=2  pucch=short  prbs_for_short=66                     |
    +------------------+------------+------------+------------+------------+------------+------------+
    :param csv_path:         path to csv file
    :param num_of_ues:       describes amount of UEs
    :param long_pucch_start: longPucchStartPuschPrb for the largest UL Bandwidth Part taken from tcpdump
    :param long_pucch_num:   longPucchNumPuschPrb for the largest UL Bandwidth Part taken from tcpdump
    :param mimo:             parameter check if MU MIMO configuration was used
    :param subcellid:        id of subcell
    :param pucch:            pucch format. Should be long or short
    :param prbs_for_short:   number of prbs for given configuration
    :return:                 rtwp counters as dict
    """
    csv_list = filter_csv_by_subcell(csv_path, subcellid)
    csv_list = convert_csv_values_to_int(csv_list)
    reqs_keys, resps_keys = generate_keys_for_req_and_resps(csv_list)
    reqs, resps = generate_requests_and_responses(csv_list, reqs_keys, resps_keys)
    num_of_slots = get_number_of_slots(reqs)
    rssis, noises = get_rssi_and_noise_per_spatial_stream(reqs, resps, num_of_ues, num_of_slots, mimo)
    with_meas, without_meas = [], []
    if pucch.lower() == 'long':
        with_meas, without_meas = number_prb_with_and_without_measurement(
            reqs, num_of_ues, long_pucch_start, long_pucch_num, num_of_slots, mimo)
    elif pucch.lower() == 'short':
        with_meas, without_meas = number_prb_with_and_without_measurement_for_short_pucch_tdd_fr2(
            reqs, num_of_ues, num_of_slots, prbs_for_short)
    rrm_avg_in_per_prb = get_rrm_avg_in_per_prb(noises, with_meas)
    rrm_total_received_rssi_per_spatial_stream = get_rrm_total_received_rssi_per_spatial_stream(rrm_avg_in_per_prb,
                                                                                                rssis, without_meas)
    rrm_rtwp_in_aw = [[int(x[ant] / (num_of_slots * 100))
                      for ant in range(0, 4)] for x in rrm_total_received_rssi_per_spatial_stream]
    logger.info(f'rrmRTWP_in_aW={rrm_rtwp_in_aw}')
    rrm_rtwp_in_dbm = [[convert_aw_to_dbm(aW[ant]) if aW[ant] > 0 else 0 for ant in range(0, 4)]
                       for aW in rrm_rtwp_in_aw]
    logger.info(f'rrm_rtwp_in_dbm={rrm_rtwp_in_dbm}')
    return get_rtwp_counters_as_dict(rrm_rtwp_in_dbm, subcellid)


def get_rtwp_counter(counter, bip_counters):
    """
    Get rtwp counter - get value of single counter from bip counters
    +------------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    | ${M55369C00000}=  get rtwp counter  M55369C00000  ${bip_counters}                 |
    +------------------+------------+------------+------------+------------+------------+------------+
    :param counter_id:       id of counter
    :local_moid:             local moid
    :param pm_counter_file:  path to pm counters
    :return:                 value of counter
    """
    return bip_counters[counter]


def get_rtwp_counters_as_dict(rtwp_counters_per_sec, subcellid):
    """
    get_rtwp_counters_as_dict - get value of rtwp counters calculated from BIP logs as dict
    +------------------+------------+------------+------------+
    |     Example                                             |
    +------------------+------------+------------+------------+
    | get_rtwp_counters_as_dict(rrm_rtwp_in_dbm, subcellid)   |
    +------------------+------------+------------+------------+
    :param rtwp_counters_per_sec: rtwp counters per second
    :param subcellid:             id of subcell
    :return:                      rtwp counter as dict
    """
    rtwp_per_ant = [[rtwp_counters_per_sec[sec][ant] for sec in range(len(rtwp_counters_per_sec))] for ant in range(4)]
    rtwp_counters = {}
    index = 0
    if subcellid == 1:
        index = 4
    for x in range(4):
        rtwp_counters[f'M55369C0000{x + index}'] = round(sum(rtwp_per_ant[x])/len(rtwp_per_ant[x]), 3)
        rtwp_counters[f'M55369C0010{x + index}'] = round(max(rtwp_per_ant[x]), 3)
        rtwp_counters[f'M55369C0020{x + index}'] = round(min(rtwp_per_ant[x]), 3)
    logger.info(rtwp_counters)
    return rtwp_counters


def get_counter_value_from_pm_counters(counter_id, local_moid, pm_counter_file):
    """
    Get counter value from pm counters - get value of single counter from pm counters
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                                 |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    | high_int_value = get_counter_value_from_pm_counters(counter, NR_RTWP_COUNTERS_MOID, high_int_counters)      |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    :param counter_id:       id of counter
    :local_moid:             local moid
    :param pm_counter_file:  path to pm counters
    :return:                 value of counter
    """
    counter_value = ta5g_pm_counters().get_pm_counter_value(counter_id, local_moid, pm_counter_file)
    if len(counter_value) == 0:
        raise ExecutionFailed(
            message=f'The PM counter {counter_id} doesn\'t have value',
            continue_on_failure=True,
        )
    else:
        return counter_value[0]


def verify_counter(counter, gnb_counters, expected_value, margin=3, local_moid=NR_RTWP_COUNTERS_MOID):
    """
    Verify counter - compare expected value and gnb counter
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                                 |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    | Verify counter  counter=M55369C00000  gnb_counters=${pm_counters}  expected_value=${bip_counters}  margin=3 |
    | Verify counter  counter=M55369C00000  gnb_counters=${pm_counters}  expected_value=-49  margin=2             |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    :param counter:         id of counter
    :param gnb_counters:    path to pm counters
    :param expected_value:  expected value as dict or string
    :param margin:          allowed error between expected and pm counters
    :local_moid:            local moid
    :return:
    """
    if isinstance(gnb_counters, dict):
        gnb_counter = gnb_counters[counter]
        print(gnb_counter)
    else:
        gnb_counter = get_counter_value_from_pm_counters(counter, local_moid, gnb_counters)
    if isinstance(expected_value, dict):
        expected_value = get_rtwp_counter(counter, expected_value)
    assert float(expected_value)*(1-margin/100) >= gnb_counter >= float(expected_value)*(1+margin/100), \
        f'{counter}: {round(float(expected_value)*(1-margin/100), 3)} >= {gnb_counter}' \
        f' >= {round(float(expected_value)*(1+margin/100), 3)}'


def verify_group_of_counters(gnb_counters, expected_value, first_ant=0, num_of_ants=2, margin=3,
                             local_moid=NR_RTWP_COUNTERS_MOID):
    """
    Verify group of counters - compare expected values and gnb counters for specific number of antennas.
    Functions verifies NR RTWP Counters from group ,,M55369C00":
    M55369C0000-M55369C0007 Average RTWP for UL Spatial streams 0-7
    M55369C0100-M55369C0107 Maximum RTWP for UL Spatial streams 0-7
    M55369C0200-M55369C0207 Minimum RTWP for UL Spatial streams 0-7
    +------------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    | Verify group of counters  gnb_counters=${pm_counters}  expected_value=${bip_counters}          |
    | ...       first_ant=0  num_of_ants=4  margin=3
    +------------------+------------+------------+------------+------------+------------+------------+
    :param gnb_counters:    path to pm counters
    :param expected_value:  expected value
    :first_ant:             first antenna which will be checked
    :param num_of_ants:     number of antennas which will be checked
    :param margin:          allowed error between expected and pm counters
    :local_moid:            local moid
    :return:
    """
    for hundred in range(0, 3):
        for x in range(first_ant, first_ant + num_of_ants):
            counter = f'M55369C00{hundred}0{x}'
            verify_counter(counter, gnb_counters, expected_value, margin, local_moid)


def check_csv_for_fake_ue(csv_path, subcellid=0):
    """
    Check csv for fake ue - check in csv file if fake ue was scheduled
    +------------------+------------+------------+------------+------------+------------+-------------+
    |     Example                                                                                     |
    +------------------+------------+------------+------------+------------+------------+-------------+
    | check csv for fake ue  csv_path=${OUTPUT_DIR}/BIP_LOGS/small_traffic/BIP_PUSCH.csv  subcellid=0 |
    +------------------+------------+------------+------------+------------+------------+-------------+
    :param csv_path:        path to csv file with BIP
    :param subcellid:       id of a subcell
    :return:
    """
    csv_list = filter_csv_by_subcell(csv_path, subcellid)
    column = "UlData_puschReceiveReqGrant_t.UE1_fakeUe"
    csv_list = csv_bip.filter_csv_by_column_value(csv_list, column_name=column, condition='==', value=1)
    csv_fake_ue_len = len(csv_list)
    assert csv_fake_ue_len > 0, "There is no fake UEs"
    logger.info(f'{csv_fake_ue_len} Fake UEs exists')


def verify_if_pm_counters_show_higher_values_when_high_external_interference_was_generated(
        high_int_counters, low_int_counters, num_of_antennas=2, cell_id=1):
    """
    Verifies if PM Counters collected during high interference period have greater values than
     PM Counters collected during low interference period.
    +------------------+------------+------------+------------+------------+------------+-------------+
    |     Example                                                                                     |
    +------------------+------------+------------+------------+------------+------------+-------------+
    | Verify if PM Counters show higher values when high external interference was generated          |
    | ...  high_int_counters=${High_Int_counters}  low_int_counters=${Low_Int_counters}               |
    +------------------+------------+------------+------------+------------+------------+-------------+
    :param high_int_counters: PM Counter values collected during high interference period
    :param low_int_counters: PM Counter values collected during low interference period
    :param num_of_antennas: Number of configured antenna ports
    :param cell_id: ID of a cell
    """
    NR_RTWP_COUNTERS_MOID = f'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-{cell_id}'
    for hundred in range(0, 3):
        for antenna_number in range(num_of_antennas):
            counter = f'M55369C00{hundred}0{antenna_number}'
            high_int_value = get_counter_value_from_pm_counters(counter, NR_RTWP_COUNTERS_MOID, high_int_counters)
            low_int_value = get_counter_value_from_pm_counters(counter, NR_RTWP_COUNTERS_MOID, low_int_counters)
            logger.info(f'Counter: {counter} High interference value: {high_int_value}'
                        f' Low interference value: {low_int_value}')
            assert high_int_value > low_int_value, f'Counter {counter} High interference value:' \
                                                   f'{high_int_value} is not higher than low interference value:' \
                                                   f'{low_int_value}'


def verify_that_two_subcells_were_used(csv_path):
    """
    verify_that_two_subcells_were_used - verifies that both subcells were used
    +------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                        |
    +============+=========+============+============+============+============+============+============+
    | Verify that two subcells were used  csv_path=${OUTPUT_DIR}/BIP_LOGS/two_subcells/BIP_PUSCH.csv     |
    +------------+---------+------------+------------+------------+------------+------------+------------+
    :param csv_path:    path to csv file
    """
    csv_list_0 = filter_csv_by_subcell(csv_path, 0)
    csv_list_1 = filter_csv_by_subcell(csv_path, 1)
    logger.info(f'len(csv_list_0)={len(csv_list_0)}')
    logger.info(f'len(csv_list_1)={len(csv_list_1)}')
    assert len(csv_list_0) > 0, f'There is no lines with subcellId=0'
    assert len(csv_list_1) > 0, f'There is no lines with subcellId=1'


def reboot_ap():
    ap_ssh_instance = ssh()
    ap_ssh_instance.connect_to(hostname="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu")
    output = ap_ssh_instance.execute("system-module-reboot; sleep 2; echo")
    rc = ap_ssh_instance.get_exit_status()
    ap_ssh_instance.disconnect()
    return rc, output
