import numpi as numpy
import logging

logging.basicConfig(filename='csi_periodicity_validator.log', level=logging.DEBUG)


def analyzer(events):
    cnt = 0
    snf_buffer = 0
    detected_periodicites_sfn = []
    dtx_counter = 0
    result_compute_periodicity = {}
    detected_cqi = []
    detected_ri = []
    detected_slot_offset = []
    for csi_event in events:
        # Try block to exclude DTX validation and CSI Report acquisition for CSI RS events
        try:
            detected_cqi.append(csi_event['CQI'])
            detected_ri.append(csi_event['RI'])
            if (csi_event['DTX']) == "DTX":
                logging.warning("DTX Found ! @ SFN %s | SLOT %s" % (csi_event['SFN'], csi_event['SLOT']))
                dtx_counter += 1
        except KeyError:
            pass
        detected_slot_offset.append(csi_event['SLOT'])
        if cnt == 0:
            snf_buffer = csi_event['SFN']
            cnt += 1
        else:
            if csi_event['SFN'] - snf_buffer < 0:
                detected_periodicites_sfn.append((csi_event['SFN'] + 1024) - snf_buffer)
            else:
                detected_periodicites_sfn.append(csi_event['SFN'] - snf_buffer)
            snf_buffer = csi_event['SFN']
            cnt += 1
        # Returns detected CSI Report periodicity (Frames) and the total number of reports
        result_compute_periodicity[csi_event['RNTI']] = {"Detected_periodicity": detected_periodicites_sfn,
                                                         "Total_no_of_reports": len(events),
                                                         "DTX_Count": dtx_counter,
                                                         "CQI_Report": detected_cqi,
                                                         "RI_Report": detected_ri, "Slot_Offset": detected_slot_offset}
    return result_compute_periodicity


def periodicity_validator(csi_periodicity_analysis, slotsperframe, expectedperiodicity,
                          dtx_threshold_percentage, type):
    rnti = list(csi_periodicity_analysis.keys())[0]
    logging.info("Analyzing %s Periodicity for UE with RNTI %s" % (type, rnti))
    csi_periodicity_analysis = csi_periodicity_analysis[rnti]
    detectedperiodicity = csi_periodicity_analysis["Detected_periodicity"]
    total_no_of_reports = csi_periodicity_analysis["Total_no_of_reports"]
    dtx_count = csi_periodicity_analysis["DTX_Count"]
    logging.debug("DTX Count: %s / %s" % (dtx_count, total_no_of_reports))
    if (float(dtx_count) / float(total_no_of_reports)) * 100.0 > float(dtx_threshold_percentage):
        logging.warning("%s of CSI Reports have DTX " % ((float(dtx_count) / float(total_no_of_reports))*100))
        logging.warning("Error, percentage of messages with DTX exceeds threshold | "
                        "CSI Periodicity test not evaluated")
        return False

    if len(numpy.unique(detectedperiodicity)) == 1:
        logging.debug("Detected periodicity: %s slots" % (numpy.unique(detectedperiodicity)[0]*slotsperframe))
        if int(numpy.unique(detectedperiodicity)[0]*slotsperframe) == int(expectedperiodicity):
            logging.info("CSI periodicity Test Passed for UE with RNTI: %s" % rnti)
            return True
        elif int(numpy.unique(detectedperiodicity)[0]*slotsperframe) != int(expectedperiodicity):
            logging.error("CSI periodicity Test Failed for UE: %s | Detected:%s | Expected:%s"
                          % (rnti, numpy.unique(detectedperiodicity)[0]*slotsperframe, expectedperiodicity))
            return False
    else:
        for periodicity_detected in numpy.unique(detectedperiodicity):
            logging.error("Invalid CSI Periodicity, multiple periodicites detected %s" % periodicity_detected)
        return False


def report_validator(csi_analysis, expected_cqi, expected_ri):
    rnti = list(csi_analysis.keys())[0]
    detected_cqi = csi_analysis[rnti]["CQI_Report"]
    detected_ri = csi_analysis[rnti]["RI_Report"]
    result_cqi_test = False
    result_ri_test = False
    logging.info("Analyzing Report for UE with RNTI %s" % rnti)
    if len(numpy.unique(detected_cqi)) >= 2:
        if 15 in numpy.unique(detected_cqi) and int(expected_cqi) in numpy.unique(detected_cqi) and \
                len(numpy.unique(detected_cqi)) == 2:
            logging.info("Detected CQI matches expected CQI :%s for RNTI: %s" % (expected_cqi, rnti))
            result_cqi_test = True
        else:
            logging.debug("CQI value for RNTI : %s | Detected:%s | Expected: %s"
                          % (rnti, detected_cqi, expected_cqi))
    elif len(numpy.unique(detected_cqi)) == 1 and int(numpy.unique(detected_cqi)[0]) == int(expected_cqi):
        logging.info("Detected CQI matches expected CQI :%s for RNTI: %s"
                     % (expected_cqi, rnti))
        result_cqi_test = True
    elif len(numpy.unique(detected_cqi)) == 0:
        logging.error("No CQI Reports, please check if CSI Reports are present in TTI Trace")
    elif len(numpy.unique(detected_cqi)) == 1 and numpy.unique(detected_cqi)[0] != \
            expected_cqi:
        logging.error("Detected CQI :%s for RNTI: %s does not match expected CQI %s"
                      % (numpy.unique(detected_cqi)[0], rnti, expected_cqi))
    else:
        logging.debug("Unknown exception, debug CQI report validator")

    if len(numpy.unique(detected_ri)) >= 2:
        if 1 in numpy.unique(detected_ri) and int(expected_ri) in numpy.unique(detected_ri) and \
                len(numpy.unique(detected_ri)) == 2:
            logging.info("Detected RI matches expected RI: %s for RNTI: %s"
                         % (expected_ri, rnti))
            result_ri_test = True
        else:
            logging.debug("RI value for RNTI : %s | Detected: %s | Expected: %s"
                          % (rnti, numpy.unique(detected_ri), expected_ri))
    elif len(numpy.unique(detected_ri)) == 1 and int(numpy.unique(detected_ri)[0]) == int(expected_ri):
        logging.info("Detected RI matches expected RI: %s for RNTI: %s"
                     % (numpy.unique(detected_ri)[0], rnti))
        result_ri_test = True
    elif len(numpy.unique(detected_ri)) == 0:
        logging.error("No RI Reports, please check if CSI Reports are present in TTI Trace")
    elif len(numpy.unique(detected_ri)) == 1 and numpy.unique(detected_ri)[0] != \
            expected_ri:
        logging.error("Detected RI :%s for RNTI: %s does not match expected RI %s"
                      % (numpy.unique(detected_ri)[0], rnti, expected_ri))
    else:
        logging.debug("Unknown exception, debug RI report validator")

    return result_cqi_test and result_ri_test


def slot_validator(csi_analysis, expected_slot_offset, slotsperframe):
    result_slot_offset = False
    rnti = list(csi_analysis.keys())[0]
    detected_slot_offset = numpy.unique(csi_analysis[rnti]["Slot_Offset"])
    if len(numpy.unique(detected_slot_offset)) > 1:
        logging.debug("Slot offset for RNTI : %s | Detected:%s | Expected:%s"
                      % (rnti, detected_slot_offset, expected_slot_offset))
    elif len(numpy.unique(detected_slot_offset)) == 1 and numpy.unique(detected_slot_offset)[0] == \
            expected_slot_offset:
        logging.info("Detected Slot offset :%s for RNTI: %s matches expected slot offset"
                     % (numpy.unique(detected_slot_offset)[0], rnti))
        result_slot_offset = True
    elif len(numpy.unique(detected_slot_offset)) == 0:
        logging.error("No CQI Reports, please check if CSI Reports are present in TTI Trace")
    elif len(numpy.unique(detected_slot_offset)) == 1 and numpy.unique(detected_slot_offset)[0] != \
            expected_slot_offset:
        detected_slot_offset = detected_slot_offset[0]
        expected_slot_offset = expected_slot_offset % slotsperframe
        if detected_slot_offset == expected_slot_offset:
            logging.info("Detected Slot offset :%s for RNTI: %s matches expected slot offset"
                         % (detected_slot_offset, rnti))
            result_slot_offset = True
        else:
            logging.error("Detected Slot offset :%s for RNTI: %s does not match expected slot offset %s"
                          % (detected_slot_offset, rnti, expected_slot_offset))
    else:
        logging.debug("Unknown exception, debug Slot offset validator")
    return result_slot_offset
