import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.harq_verification.harq_utils as hu


def check_positive_harq_transmissions(pcap_file=None, margin=5):
    harq = hu.Harq(ts_filter='uldata_puschreceiverespharqu || uldata_pucchreceiverespharqd',
                   message_name_patterns=['UlData_PuschReceiveRespHarqU_t', 'UlData_PucchReceiveRespHarqD_t'],
                   pcap_path=pcap_file)
    margin = int(margin)
    harq.verify_positive_harq_feedback(percent_margin_of_error=margin)


def check_negative_harq_transmissions(pcap_file=None, threshold=92):
    harq = hu.Harq(ts_filter='uldata_puschreceiverespharqu || uldata_pucchreceiverespharqd',
                   message_name_patterns=['UlData_PuschReceiveRespHarqU_t', 'UlData_PucchReceiveRespHarqD_t'],
                   pcap_path=pcap_file)
    threshold = int(threshold)
    harq.verify_negative_harq_feedback(percent_margin_of_error=threshold)
