from testsuite.Ulm.resources.Common.python.tti_analyzer_framework import tti_extractor_framework
import json
import logging
import os


def extract_data_for_analysis_from_TTI_Trace(file_name_of_tti_trace_pcap, gnb_build,
                                             log_dir="/tmp/",
                                             num_of_events_to_analyze=None):
    "Define the Event discriminator and corrosponding information elements of interest"
    events_to_be_analyzed = ['csiSrReportData', 'ulFdSchedData', 'ulPreSchedData', 'dlFdSchedData', 'dlPreSchedData']
    extract_contents_csiSrReportData = ["SR", "SFN", "SLOT", "DTX", "RNTI", "CELLID", "CQI", "RI"]
    extract_contents_ulPreSchedData = ["EventList", "SFN", "SLOT", "RNTI", "CELLID"]
    extract_contents_ulFdSchedData = ["SFN", "SLOT", "RNTI", "CELLID"]
    extract_contents_dlFdSchedData = ["SFN", "SLOT", "RNTI", "CELLID", "taMacCeValue", "MCS"]
    extract_contents_dlPreSchedData = ["SFN", "SLOT", "RNTI", "CELLID", "EventList", "PrachPeakMetric"]
    extract_contents_csiRsSchedData = ["SFN", "SLOT", "RNTI", "CELLID"]
    extract_contents_ulPucchReceiveRespPsData = ["pucchFormat", "RNTI", "CELLID", "DTX", "SFN", "SLOT"]

    extract_dict = {'csiSrReportData': extract_contents_csiSrReportData,
                    'ulPreSchedData': extract_contents_ulPreSchedData,
                    'ulFdSchedData': extract_contents_ulFdSchedData,
                    'dlFdSchedData': extract_contents_dlFdSchedData,
                    'dlPreSchedData': extract_contents_dlPreSchedData,
                    'csiRsSchedData': extract_contents_csiRsSchedData,
                    'ulPucchReceiveRespPsData': extract_contents_ulPucchReceiveRespPsData}

    "Extract relevant information from the TTI Trace (PCAP)"
    event_to_be_analyzed = tti_extractor_framework.get_rnti_sorted_tti_data(extract_dict,
                                                                            file_name_of_tti_trace_pcap,
                                                                            gnb_build, num_of_events_to_analyze, False)
    path = log_dir + 'tti_data.json'
    write_json(log_dir, "tti_data.json", event_to_be_analyzed)

    return path


def write_json(target_path, target_file, data):
    if not os.path.exists(target_path):
        try:
            os.makedirs(target_path)
        except Exception as e:
            print(e)
            raise
    with open(os.path.join(target_path, target_file), 'w') as f:
        json.dump(data, f)
