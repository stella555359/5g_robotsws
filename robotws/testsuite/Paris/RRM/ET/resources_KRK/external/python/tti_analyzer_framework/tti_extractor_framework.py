import tti_extractor
import tti_info_elements as tti_ie_global
import os
import json
import logging


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

    print("Number of Events Extracted with multiDecoder=%s : %s" % (useMultiDecoder, len(extracted_tti_events)))

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
    path_to_tti_trace_udp_file = "/home/ute/logs/CB006064/20210817-154011-F/CB006064/SBTS00_ENB_9999_210816_000005/\
20210817_154021/Logs/tti_trace_4ues_dl_50_mbps_ul_0_mbps_scenario_defaultScenario/ttitrace_streaming.pcap"
    path_to_tti_trace_pcap_file = "/home/ute/logs/CB006064/20210817-154011-F/CB006064/SBTS00_ENB_9999_210816_000005/\
20210817_154021/Logs/tti_trace_4ues_dl_50_mbps_ul_0_mbps_scenario_defaultScenario/ttitrace_streaming.udp"
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
    test_extract_1 = get_rnti_sorted_tti_data(events_and_contents=extract_dict,
                                              path_to_tti_trace_udp_file=path_to_tti_trace_udp_file,
                                              gnb_build=gnb_build,
                                              num_of_events_to_analyze=None,
                                              useMultiDecoder=True)

    test_extract_2 = get_rnti_sorted_tti_data(events_and_contents=extract_dict,
                                              path_to_tti_trace_udp_file=path_to_tti_trace_pcap_file,
                                              gnb_build=gnb_build,
                                              num_of_events_to_analyze=None,
                                              useMultiDecoder=False)

    write_json('/tmp/', 'multi_extract.json', test_extract_1)
    write_json('/tmp/', 'event_extract.json', test_extract_2)


def write_json(target_path, target_file, data):
    if not os.path.exists(target_path):
        try:
            os.makedirs(target_path)
        except Exception as e:
            print(e)
            raise
    with open(os.path.join(target_path, target_file), 'w') as f:
        json.dump(data, f)


def load_json(filename='/mnt/etfiles/users/srjanard/DEVELOPMENT/robotws5g/885tti_data.json'):
    with open(filename) as json_file:
        events_json_extracted = json.load(json_file)
    return events_json_extracted


def test_extracted_values(path_to_json_multi, path_to_json_event):
    extracted_json_multi = load_json(path_to_json_multi)
    extracted_json_event = load_json(path_to_json_event)
    result = test_number_of_events(extracted_json_multi, extracted_json_event)
    if result:
        test_number_of_instances_per_event(extracted_json_multi, extracted_json_event)
    test_number_of_instances_per_event_per_RNTI(extracted_json_multi, extracted_json_event)


def test_number_of_events(extracted_json_multi, extracted_json_event):
    try:
        assert len(extracted_json_multi) == len(extracted_json_event)
        return True
    except AssertionError:
        logging.error("Number of events decoded from Multi and Event Decoders are not same")
        logging.info("Events decoded in using multi decoder %s" % extracted_json_multi.keys())
        logging.info("Events decoded in event decoder %s" % extracted_json_event.keys())
        return False


def test_number_of_instances_per_event_per_RNTI(extracted_json_multi, extracted_json_event):
    multiResult = getNumberOfEventsPerEventgroupPerRNTI(extracted_json_multi)
    eventResult = getNumberOfEventsPerEventgroupPerRNTI(extracted_json_event)
    multiResult.sort()
    eventResult.sort()
    for index, entry in enumerate(multiResult):
        logging.info(entry, eventResult[index])
    if multiResult == eventResult:
        logging.info("ITs a Match")
    else:
        logging.error("Something went wrong")
        mismatchArray = []
        for index, listentry in enumerate(multiResult):
            if eventResult[index] != listentry:
                mismatchArray.append(index)
        logging.warning("Mismatch in fields", mismatchArray)
        getMismatches(extracted_json_multi, mismatchArray=mismatchArray)


def getMismatches(inputDict, mismatchArray):
    overallCounter = 0
    for eventGroup in inputDict.values():
        for RNTI in eventGroup.keys():
            if overallCounter in mismatchArray:
                print(RNTI)
            overallCounter += 1


def getNumberOfEventsPerEventgroupPerRNTI(inputDict):
    resArray = []
    for eventGroup in inputDict.values():
        for RNTI, Data in eventGroup.items():
            logging.info("number Of events per RNTI: %s" % (len(RNTI)))
            resArray.append({RNTI: len(Data)})
    return resArray


def test_number_of_instances_per_event(extracted_json_multi, extracted_json_event):
    for event in extracted_json_multi:
        try:
            logging.info("Event name : %s | Instances decoded using Multi Decoder %s | \
                Instances decoded using Event Decoder %s" % (event, len(extracted_json_multi[event]),
                                                             len(extracted_json_event[event])))
            assert len(extracted_json_multi[event]) == len(extracted_json_event[event])
        except AssertionError:
            logging.error("Number of instances per events decoded from Multi and Event Decoders are not\
same for the event %s" % event)
            logging.error("Event name : %s | Instances decoded using Multi Decoder %s | \
                          Instances decoded using Event Decoder %s"
                          % (event, len(extracted_json_multi[event]),
                             len(extracted_json_event[event])))


if __name__ == "__main__":
    main()
    test_extracted_values('/tmp/multi_extract.json', '/tmp/event_extract.json')
