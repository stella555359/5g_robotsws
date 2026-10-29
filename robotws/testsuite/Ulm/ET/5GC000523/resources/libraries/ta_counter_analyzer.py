import logging
import re
import json
from robot.libraries.BuiltIn import BuiltIn

from log_function_progress import log_begin_end_func_name


logging.basicConfig(filename='ta_counter_analyzer.log', level=logging.DEBUG)


@log_begin_end_func_name
def detect_ues_attached(event_to_be_analyzed_csi_sr):
    """Detects the number of UEs that were scheduled in the given trace
       Returns a dictionary with RNTI and corresponding cell id
       Candidate for common tti analyzer framework"""
    rnti_cell_info = {}
    attached_ues_in_tti_trace = event_to_be_analyzed_csi_sr.keys()
    no_of_ues_attached = len(attached_ues_in_tti_trace)
    logging.info("Analyzer detected %s UE(s) attached in TTI Trace with the following RNTI(s) " % no_of_ues_attached)
    for rnti in attached_ues_in_tti_trace:
        logging.info("(RNTI) : %s on Cell: %s" % (rnti, event_to_be_analyzed_csi_sr[rnti][0]["CELLID"]))
        rnti_cell_info[rnti] = event_to_be_analyzed_csi_sr[rnti][0]["CELLID"]
    return rnti_cell_info


@log_begin_end_func_name
def get_ra_resp_stats(event_to_be_analyzed_dlPreScheduler):
    msg2_rnti_peak_metric = {}
    for rnti in event_to_be_analyzed_dlPreScheduler.keys():
        for event in event_to_be_analyzed_dlPreScheduler[rnti]:
            if event['EventList'] == 'ENTRYADDUE':
                logging.info("Msg 2 sent with T-RNTI %s for PRACH with PeakMetric %s in SFN %s and SLOT %s"
                             % (event["RNTI"], event["PrachPeakMetric"], event["SFN"], event["SLOT"]))
                msg2_rnti_peak_metric[event["RNTI"]] = event["PrachPeakMetric"]

    return msg2_rnti_peak_metric


@log_begin_end_func_name
def find_association_temp_rnti_permanent_rnti(event_to_be_analyzed_dlPreScheduler,
                                              msg2_rnti_peak_metric):
    """Returns a dictionary where the Key contains the RNTI and Value contains the corresponding Temp RNTI"""
    rnti_temp_rnti_association = {}
    for rnti, peak_metric in msg2_rnti_peak_metric.items():
        for ue in event_to_be_analyzed_dlPreScheduler:
            for event in event_to_be_analyzed_dlPreScheduler[ue]:
                if (peak_metric == event['PrachPeakMetric']) and (rnti != event['RNTI']):
                    rnti_temp_rnti_association[event['RNTI']] = rnti
                    break
    return rnti_temp_rnti_association


def find_bin(value, bins):
    for index in range(0, len(bins)-1):
        if (value >= bins[index]) and (value < (bins[index + 1])):
            return index + 1
        elif value >= bins[-1]:
            return len(bins)


@log_begin_end_func_name
def generate_dictionary_with_init_counter_value(prefix, bin_upper_limits):
    dict_default_value = {}
    for index in range(1, len(bin_upper_limits)+1):
        index_id = get_formatted_bin_number(index)
        counter_id = prefix+index_id
        dict_default_value[counter_id] = 0
    return dict_default_value


def get_formatted_bin_number(index):
    if len(str(index)) == 1:
        return '0'+str(index)
    else:
        return str(index)


@log_begin_end_func_name
def find_initial_ta(rnti_temp_rnti_pair, event_to_be_analyzed_fdScheduler):
    rnti_initial_ta = {}
    initial_ta_info = {}
    for rnti, temp_rnti in rnti_temp_rnti_pair.items():
        try:
            for event in event_to_be_analyzed_fdScheduler[temp_rnti]:
                if event['taMacCeValue'] == 65535:
                    initial_ta_info['TA_Value'] = 0
                    initial_ta_info['Cell_id'] = event['CELLID']
                    rnti_initial_ta[rnti] = initial_ta_info
                else:
                    initial_ta_info['TA_Value'] = event['taMacCeValue']
                    initial_ta_info['Cell_id'] = event['CELLID']
                    rnti_initial_ta[rnti] = initial_ta_info
                logging.info("The initial timing advance value for RNTI %s is %s" %
                             (rnti, rnti_initial_ta[rnti]['TA_Value']))
        except KeyError:
            logging.info("No Permanent RNTI present for Temp RNTI : %s" % temp_rnti)
    return rnti_initial_ta


@log_begin_end_func_name
def ta_counter_analyzer(path_to_tti_json, pci):
    "Define the Event discriminator and corresponding information elements of interest"
    dict_ta_counter_analyzer_output = {}
    prefix_counter_rrc_connected_ue = "M55307C020"
    prefix_counter_init_ta = "M55307C010"
    bin_upper_limits_ta_rrc_counter = range(0, 256, 8)
    dict_counter_init_ta =  \
        generate_dictionary_with_init_counter_value(prefix=prefix_counter_init_ta,
                                                    bin_upper_limits=bin_upper_limits_ta_rrc_counter)
    with open(path_to_tti_json, "r") as json_file:
        event_to_be_analyzed = json.load(json_file)
    event_to_be_analyzed_csi_sr = event_to_be_analyzed['csiSrReportData']
    event_to_be_analyzed_fdScheduler = event_to_be_analyzed['dlFdSchedData']
    event_to_be_analyzed_dlPreScheduler = event_to_be_analyzed['dlPreSchedData']

    rnti_cell_info = detect_ues_attached(event_to_be_analyzed_csi_sr)
    msg2_rnti_peak_metric = get_ra_resp_stats(event_to_be_analyzed_dlPreScheduler)

    rnti_temp_rnti_pair = find_association_temp_rnti_permanent_rnti(event_to_be_analyzed_dlPreScheduler,
                                                                    msg2_rnti_peak_metric)

    initial_timing_advance = find_initial_ta(rnti_temp_rnti_pair, event_to_be_analyzed_fdScheduler)

    dict_counter_ta_rrc_connected_ues = {}
    dict_counter_init_ta = {}
    cell_ids = pci.values()
    for cell_id in cell_ids:
        dict_counter_ta_rrc_connected_ues[int(cell_id)] = \
            generate_dictionary_with_init_counter_value(prefix=prefix_counter_rrc_connected_ue,
                                                        bin_upper_limits=bin_upper_limits_ta_rrc_counter)
        dict_counter_init_ta[int(cell_id)] = \
            generate_dictionary_with_init_counter_value(prefix=prefix_counter_init_ta,
                                                        bin_upper_limits=bin_upper_limits_ta_rrc_counter)

    for rnti in rnti_cell_info:
        try:
            initial_TA = initial_timing_advance[rnti]['TA_Value']
            logging.info("Initial TA in Msg 2 for RNTI - %s : %s" % (rnti, initial_TA))

            bin_number = (find_bin(initial_TA, bin_upper_limits_ta_rrc_counter))
            bin_number = get_formatted_bin_number(bin_number)
            counter_impacted = prefix_counter_init_ta + str(bin_number)
            event_in_cell_id = initial_timing_advance[rnti]['Cell_id']
            dict_counter_init_ta[event_in_cell_id][counter_impacted] += 1
            cnt_dl_tx_with_macce = 0
            cnt_dl_tx_with_macce_tac = 0
            for index in range(0, len(event_to_be_analyzed_fdScheduler[rnti])):
                cnt_dl_tx_with_macce += 1
                TA_Value = event_to_be_analyzed_fdScheduler[rnti][index]['taMacCeValue']
                logging.info("TAC in DL Tx number %s with MAC CE in SFN %s SLOT %s: %s"
                             % (cnt_dl_tx_with_macce, event_to_be_analyzed_fdScheduler[rnti][index]['SFN'],
                                event_to_be_analyzed_fdScheduler[rnti][index]['SLOT'], TA_Value))
                if cnt_dl_tx_with_macce_tac == 0:
                    old_TA = initial_TA

                if TA_Value != 65535:
                    cnt_dl_tx_with_macce_tac += 1
                    logging.info("OLD TA: %s" % old_TA)
                    logging.info("TA Value: %s" % TA_Value)
                    new_ta_counter_value = old_TA + (TA_Value - 31)
                    logging.info("New TA Value: %s" % new_ta_counter_value)
                    if new_ta_counter_value < 0:
                        new_ta_counter_value = new_ta_counter_value * -1
                    old_TA = new_ta_counter_value
                    bin_number = (find_bin(new_ta_counter_value, bin_upper_limits_ta_rrc_counter))
                    bin_number = get_formatted_bin_number(bin_number)
                    counter_impacted = prefix_counter_rrc_connected_ue + bin_number
                    event_in_cell_id = event_to_be_analyzed_fdScheduler[rnti][index]['CELLID']
                    dict_counter_ta_rrc_connected_ues[event_in_cell_id][counter_impacted] += 1
                    logging.info("TA Counter value at correction number %s: %s | %s Counter: %s "
                                 % (cnt_dl_tx_with_macce_tac, new_ta_counter_value, counter_impacted,
                                    dict_counter_ta_rrc_connected_ues[event_in_cell_id][counter_impacted]))
        except KeyError:
            logging.debug("RNTI not found in TTI Trace: %s" % rnti)

    dict_ta_counter_analyzer_output[prefix_counter_rrc_connected_ue] = dict_counter_ta_rrc_connected_ues
    dict_ta_counter_analyzer_output[prefix_counter_init_ta] = dict_counter_init_ta
    return dict_ta_counter_analyzer_output


if __name__ == "__main__":
    file_name = "/mnt/etfiles/users/srjanard/logs/ute/SBTS_Trunk/5G523-F/20210923-213119-F/5G523-F/\
SBTS00_ENB_9999_210922_000004/20210923_213132/Logs/PMCounterTests/ttitrace_streaming.udp"
    multi_dir = '/opt/tti_dissectors/'
    gnb_build = "5G_0.190.3027"
    counter_prefix = "M55307C020"
    result = ta_counter_analyzer(file_name_of_tti_trace_udp=file_name, gnb_build=gnb_build,
                                 pci="50", num_of_events_to_analyze=None)
    print(result)
