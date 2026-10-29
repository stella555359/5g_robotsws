try:
    import tti_extractor
    import tti_info_elements as tti_ie_global
except ModuleNotFoundError:
    from . import tti_extractor
    from . import tti_info_elements as tti_ie_global
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
    events_and_contents['utcTimestampData'] = [
        'MICROSEC', 'SEC', 'MIN', 'HOUR', 'DAY', 'MONTH', 'YEAR', 'SFN', 'SLOT', 'SLOTDURATION', 'CELLID']
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
    target_file_path = os.path.join(target_path, target_file)
    with open(target_file_path, 'w') as f:
        json.dump(data, f)
        return target_file_path


def main():

    path_to_tti_trace_udp_file = "/mnt/etfiles/users/Vasileios/gnb-0-tti-traces.udp"
    path_to_tti_trace_pcap_file = "/mnt/etfiles/users/srjanard/DEVELOPMENT/robotws/tti_test/gnb-0-tti-traces_00.pcap"
    extract_dict = {'csiSrReportData': ['SFN', 'SLOT', 'CQI', 'DTX', 'pucchFormat', 'ULChannel',
                                        'SR', 'RNTI', 'RI', 'CELLID'],
                    'ulPuschReceiveRespPsData': ['shortTermTaMetric', 'ULRANK', 'SINR', 'DTX',
                                                 'RNTI', 'SLOT', 'SFN', 'shortTermTaPeakAmp', 'RSSI', 'CELLID'],
                    'dlBeamData': ['SFN', 'SLOT', 'CURRENTBESTBEAM', 'CELLID', 'RNTI'],
                    'dlLaDeltaCqiArray': ['SFN', 'SLOT', 'deltaCQI', 'CELLID', 'RNTI'],
                    'ulLaPhr': ['SLOT', 'rrmNumPuschPrb', 'rrmPhr', 'SFN', 'rrmPhrScaled', 'RNTI', 'CELLID'],
                    'ulLaDeltaSinr': ['SFN', 'SLOT', 'rrmDeltaSinr', 'CELLID', 'RNTI'],
                    'csiRsSchedData': ['SLOT', 'startPrb', 'SFN', 'RNTI', 'numOfPrb', 'CELLID'],
                    'dlPreSchedData': ['SLOT', 'EventList', 'PrachPeakMetric', 'SFN', 'ClassPrio', 'RNTI', 'CELLID'],
                    'ulHarqRxData': ['SLOT', 'SFN', 'CRC', 'DTX', 'RNTI', 'CELLID'],
                    'dlFdSchedData': ['SFN', 'SLOT', 'numOfPrb', 'startPrb', 'RNTI', 'ProposedMCS', 'txNumber',
                                      'MCS', 'CELLID', 'taMacCeValue'],
                    'ulFdSchedData': ['txNumber', 'rrmMaxNumPrbUl', 'NUMBITSDLHARQ', 'RNTI', 'SLOT', 'NUMBITSCSI',
                                      'startPrb', 'SFN', 'numOfPrb', 'MCS', 'CELLID'],
                    'ulPucchReceiveRespPsData': ['shortTermTaMetric', 'SINR', 'srBit', 'DTX', 'RNTI', 'SLOT',
                                                 'startPrb', 'pucchFormat', 'SFN', 'shortTermTaPeakAmp',
                                                 'RSSI', 'CELLID'],
                    'ulPreSchedData': ['SLOT', 'EventList', 'SFN', 'ClassPrio', 'RNTI', 'CELLID'],
                    'dlHarqRxDataArray': ['SLOT', 'pucchFormat', 'SFN', 'DTX', 'RNTI', 'ACKNACK', 'CELLID'],
                    'ulLaAverageSinr': ['SLOT', 'InstSinr', 'La_Avg_UL_RANK', 'SFN', 'RNTI', 'CELLID']}
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
