import tti_extractor
import tti_info_elements as tti_ie_global
import os
import json


"""The inputs to the tti extractor framework should be as follows:
extract_contents_ulPucchReceiveRespPsData = ["pucchFormat", "RNTI", "CELLID", "DTX"]
               -> List of alias' of event discriminators as described in tti_events.py
events_and_contents = {'ulPucchReceiveRespPsData': extract_contents_ulPucchReceiveRespPsData}
               Key: -> event name as described in TTI Trace
The function returns a dictionary where the key is the RNTI of the UE and the Values are user defined dictionaries
of event names and corresponding event discriminators

Example:
{'ulPucchReceiveRespPsData': {209: [{'RNTI': 209, 'pucchFormat': 0, 'DTX': 0, 'CELLID': 50},
                                    {'RNTI': 209, 'pucchFormat': 2, 'DTX': 0, 'CELLID': 50},
                                    {'RNTI': 209, 'pucchFormat': 2, 'DTX': 0, 'CELLID': 50}],
                               61: [{'RNTI': 61, 'pucchFormat': 0, 'DTX': 0, 'CELLID': 50},
                                    {'RNTI': 61, 'pucchFormat': 2, 'DTX': 0, 'CELLID': 50},
                                    {'RNTI': 61, 'pucchFormat': 2, 'DTX': 0, 'CELLID': 50}]}}

num_of_events_to_analyze -> None is the default value, i.e. all events in the tti trace are parsed,
                            if a number 'x' is defined then only the first x elements of the tti trace will be parsed

"""


def get_rnti_sorted_tti_data(events_and_contents, path_to_tti_trace_udp_file,
                             gnb_build, num_of_events_to_analyze=None, useMultiDecoder=True,
                             return_filtered_json=False, json_target_path="/tmp/",
                             json_target_file="filtered_tti.json"):

    extracted_tti_events = tti_extractor.ttieventextractor(path_to_tti_trace_udp_file,
                                                           events_and_contents.keys(),
                                                           useMultiDecoder,
                                                           num_of_events_to_analyze)

    tti_trace_extract = tti_ie_global.TTITraceDecoder(dict_events_to_be_extracted=events_and_contents,
                                                      extracted_tti_trace=extracted_tti_events,
                                                      gnb_build=gnb_build, useMultiDecoder=useMultiDecoder)
    if return_filtered_json:
        path = write_json(json_target_path, json_target_file,
                          tti_trace_extract.retrieve_all_events())
        return path

    return tti_trace_extract.retrieve_all_events()


def write_json(target_path, target_file, data):
    if not os.path.exists(target_path):
        try:
            os.makedirs(target_path)
        except Exception as e:
            print(e)
            raise
    with open(os.path.join(target_path, target_file), 'w') as f:
        json.dump(data, f)
        return target_path+target_file


def main():
    path_to_tti_trace_udp_file = "/mnt/etfiles/users/srjanard/logs/ute/Branch/5G885-E/20210420-104210-F/5G885-E/" \
        "5G21A_11.800.765/20210420_104256/" \
        "[1]5GC000885_E_Long_PUCCH_Removal_of_scheduling_restrictions/tti_data_dl_ul/" \
        "ttitrace_streaming.pcap"
    extract_contents_ulFdSchedData = [
        "SFN", "SLOT", "NUMBITSCSI", "NUMBITSDLHARQ", "CELLID", "RNTI"]
    extract_contents_ulHarqRxData = [
        "SFN", "SLOT", "CRC", "DTX", "CELLID", "RNTI"]
    extract_contents_dlHarqRxDataArray = [
        "SFN", "SLOT", "pucchFormat", "ACKNACK", "DTX", "CELLID", "RNTI"]
    extract_contents_csiSrReportData = [
        "SR", "SFN", "SLOT", "DTX", "RNTI", "CELLID", "pucchFormat", "CQI", "RI"]
    extract_dict = {'ulFdSchedData': extract_contents_ulFdSchedData,
                    'ulHarqRxData': extract_contents_ulHarqRxData,
                    'csiSrReportData': extract_contents_csiSrReportData,
                    'dlHarqRxDataArray': extract_contents_dlHarqRxDataArray}
    gnb_build = "5G_0.800.3091"
    print(get_rnti_sorted_tti_data(events_and_contents=extract_dict,
                                   path_to_tti_trace_udp_file=path_to_tti_trace_udp_file,
                                   gnb_build=gnb_build,
                                   num_of_events_to_analyze=None,
                                   useMultiDecoder=False))


if __name__ == "__main__":
    main()
