import testsuite.Ulm.resources.Common.python.tti_analyzer_framework.tti_extractor_framework as tti
import tools_523
import json


def sr_check(path_to_json, gnb_build, frconfig, num_of_events_to_analyze=None):
    "Define the Event discriminator and corrosponding information elements of interest"
    with open(path_to_json, "r") as json_file:
        event_to_be_analyzed = json.load(json_file)

    event_to_be_analyzed_csi_sr = event_to_be_analyzed['csiSrReportData']
    event_to_be_analyzed_ulPreScheduler = event_to_be_analyzed['ulPreSchedData']
    event_to_be_analyzed_fdScheduler = event_to_be_analyzed['ulFdSchedData']

    """ Count UEs recorded in TTI Trace and look for UEs with event csiSrReportData"""
    ue_with_csisr_event = []
    print("Number of RNTI(s) detected in TTI Trace:", len(event_to_be_analyzed_csi_sr.keys()))
    for key in event_to_be_analyzed_csi_sr.keys():
        ue_with_csisr_event.append(key)

    if len(ue_with_csisr_event) > 0:
        print("RNTI of UE(s) with csiSrReportData event:%s" % ue_with_csisr_event)
    else:
        print("ERR:Check TTI Trace, csiSrReportData not found")
        return False

    """ Run analysis on UE(s) containing CSI Reports """
    result_per_ue = {}
    result = True
    for ue in ue_with_csisr_event:
        print("Analyzing UE : %s" % ue)
        result_per_ue[ue] = tools_523.analyze(event_to_be_analyzed_csi_sr, event_to_be_analyzed_ulPreScheduler,
                                              event_to_be_analyzed_fdScheduler, ue, frconfig)
        result = result and result_per_ue[ue]
    return result


if __name__ == "__main__":
    file_name = "/mnt/etfiles/users/srjanard/robottest/schedulingRequest/ttitrace_streaming.udp"
    multi_dir = '/opt/tti_trace'
    result = sr_check(file_name_of_tti_trace_udp=file_name, gnb_build="5G_0.800.252",
                      tti_dissector_path=multi_dir, frconfig="cmW", num_of_events_to_analyze=None)
    print(result)
