import logging
import json

""" The function "pucch_dtx_counter_analyzer" counts the number of dtx and non dtx packets in Pucch format 0 and 2
The function accepts as input the following parameters:
1. filename -> string : path pointing to the pdml to be analyzed
2. op_type -> string : only 2 values are allowed : "rnti" OR "subcell"
    - rnti : output is a a dictionary with key as rnti found and value as dictionary of Counter values
        - Dictionary of counter values :
            key - counter number
                M55303C11001 - DTX Detections in PUCCH format 0
                M55303C15001 - DTX Detections in PUCCH format 2
                M55303C12001 - Non - DTX Detections in PUCCH format 0
                M55303C16001 - Non - DTX Detections in PUCCH format 2
            value - count
    - subcell (default) : output is a a dictionary with key as subcell found and value as dictionary of Counter values
        (refer to dictionary, key value pair above)
"""

logging.basicConfig(level=logging.INFO)


def pucch_dtx_counter_analyzer(path_to_tti_json, pci):
    count_cell_id = {}
    cell_ids = pci.values()
    for cell_id in range(1, len(cell_ids) + 1):
        count_cell_id[int(cell_id)] = {'M55303C15001': 0, 'M55303C11001': 0, 'M55303C12001': 0, 'M55303C16001': 0}

    with open(path_to_tti_json, "r") as json_file:
        event_to_be_analyzed = json.load(json_file)
    event_to_be_analyzed_ulPucchReceiveRespPsData = event_to_be_analyzed['ulPucchReceiveRespPsData']
    for rnti in event_to_be_analyzed_ulPucchReceiveRespPsData.keys():
        for event in event_to_be_analyzed_ulPucchReceiveRespPsData[rnti]:
            if event["pucchFormat"] == 2 and event["DTX"] == 'DTX':
                count_cell_id[event['CELLID']]['M55303C15001'] += 1
            elif event["pucchFormat"] == 0 and event["DTX"] == 'DTX':
                count_cell_id[event['CELLID']]['M55303C11001'] += 1
            elif event["pucchFormat"] == 0 and event["DTX"] == 'NON_DTX':
                count_cell_id[event['CELLID']]['M55303C12001'] += 1
            elif event["pucchFormat"] == 2 and event["DTX"] == 'NON_DTX':
                count_cell_id[event['CELLID']]['M55303C16001'] += 1
            else:
                logging.debug("Invalid Pucch format or DTX information decoded, check trace manually")

    return count_cell_id


if __name__ == "__main__":
    file_name_of_tti_trace_udp = '/home/ute/logs/5G523-F/20220913-125054-F/\
    5G523-F/SBTS00_ENB_9999_220912_000009/20220913_125106/Logs/\
    tti_trace_scenario_1_default_scenario/ttitrace_streaming.pcap'
    print(pucch_dtx_counter_analyzer(file_name_of_tti_trace_udp, gnb_build="SBTS00_ENB_9999_220912_000009",
                                     num_of_events_to_analyze=None, pci={'NRCELL-1': 50, 'NRCELL-2': 51}))
