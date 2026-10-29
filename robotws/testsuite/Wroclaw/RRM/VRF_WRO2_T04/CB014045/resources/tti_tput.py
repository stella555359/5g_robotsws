import json
from itertools import groupby
from robot.api import logger


def get_ue_rnti_from_tti(other_ue_rnti, json_file):
    """
    Extract new RNTI for existing UE based on another UE's RNTI
    """
    rntis = get_all_rntis(json_file)
    rntis.remove(int(other_ue_rnti))
    assert len(rntis) == 1
    return rntis[0]


def get_all_rntis(json_file):
    all_rntis = []
    with open(json_file) as f:
        tti = json.load(f)
    for i, x in enumerate(tti['events']):
        if "ulFdSchedData" in x:
            all_rntis.append(x["ulFdSchedData"]['body']['eventHeader']['rnti'])
    print(list(set(all_rntis)))
    return list(set(all_rntis))


def calculate_tti_tput(rnti, json_file):
    with open(json_file) as f:
        tti = json.load(f)

    tb_sum = 0
    sfn_list = []
    crc = 0
    dtx = 0
    prb_values = []
    phr_values = []
    for i, x in enumerate(tti['events']):
        if "ulLaPhr" in x:
            if x["ulLaPhr"]['body']['eventHeader']['rnti'] == int(rnti):
                phr_values.append(x["ulLaPhr"]['body']["rrmPhrScaled"])
        if "ulHarqRxData" in x:
            if x["ulHarqRxData"]['body']['eventHeader']['rnti'] == int(rnti):
                if x["ulHarqRxData"]['body']['dtx'] == 'DTX':
                    dtx += 1
                if x["ulHarqRxData"]['body']['crcResult'] == 'NOK':
                    crc += 1
        if "ulFdSchedData" in x:
            if x["ulFdSchedData"]['body']['eventHeader']['rnti'] == int(rnti):
                prb_values.append(x["ulFdSchedData"]['body']['numOfPrb'])
                sfn_list.append((x['ulFdSchedData']['body']['eventHeader']['sfn']))
                tb_sum += x['ulFdSchedData']['body']['tbSize']
    sfn_list = [s for s, _ in groupby(sfn_list)]
    wraps = sum(1 for a, b in zip(sfn_list, sfn_list[1:]) if a == 1023 and b < 1023)
    logger.info(f"\n<= Stats for RNTI: {rnti} =>", also_console=True)
    logger.info(f"DTX: {dtx}", also_console=True)
    logger.info(f"CRC NOK: {crc}", also_console=True)
    logger.debug(f"1st sfn: {sfn_list[0]}, last sfn: {sfn_list[-1]}")
    logger.debug(f"wraps: {wraps}")
    all_frames = (wraps * 1024) + (sfn_list[-1] - sfn_list[0])
    t_ms = all_frames * 10
    t_s = t_ms / 1000
    logger.debug(f"Total TB size: {tb_sum}")
    logger.debug(f"Time[s]: {t_s}")

    harq_tbsize = calculate_tb_size(match_ul_data(tti), rnti)
    avg_tput = round(((tb_sum - harq_tbsize) / t_s) / 1000000, 2)

    avg_prb = round(sum(prb_values) / len(prb_values), 2)
    phr_is_below_zero = not any(x > 0 for x in phr_values)
    logger.info(f"AVG Tput: {avg_tput}", also_console=True)
    logger.info(f"AVG PRB: {avg_prb}", also_console=True)
    logger.info(f"UE is power limited: {phr_is_below_zero}", also_console=True)

    return avg_tput


def match_ul_data(tti):
    # List to store filtered ulHarqRxData objects
    filtered_harq_data = []
    for data in tti['events']:
        if 'ulHarqRxData' in data:
            if (data['ulHarqRxData'].get('body', {}).get('dtx') == 'DTX' or
                    data['ulHarqRxData'].get('body', {}).get('crcResult') == 'NOK'):
                filtered_harq_data.append(data)

    matched_data = []

    for harq_data in filtered_harq_data:
        harq_key = (
            harq_data['ulHarqRxData'].get('body', {}).get('eventHeader', {}).get('sfn'),
            harq_data['ulHarqRxData'].get('body', {}).get('eventHeader', {}).get('slot'),
            harq_data['ulHarqRxData'].get('body', {}).get('ulHarqProcessIndex')
        )

        sched_data = None
        for data in tti['events']:
            if 'ulFdSchedData' in data:
                sched_key = (
                    data['ulFdSchedData'].get('body', {}).get('eventHeader', {}).get('sfn'),
                    data['ulFdSchedData'].get('body', {}).get('eventHeader', {}).get('slot'),
                    data['ulFdSchedData'].get('body', {}).get('ulHarqProcessIndex')
                )
                if harq_key == sched_key:
                    sched_data = data['ulFdSchedData']

                    tti['events'].remove(data)
                    break

        if sched_data:
            matched_data.append({
                'ulHarqRxData': harq_data['ulHarqRxData'],
                'ulFdSchedData': sched_data
            })
    return matched_data


def calculate_tb_size(data, rnti):
    tb_sum = 0
    for x in data:
        if x["ulFdSchedData"]['body']['eventHeader']['rnti'] == int(rnti):
            tb_sum += x['ulFdSchedData']['body']['tbSize']
    return tb_sum
