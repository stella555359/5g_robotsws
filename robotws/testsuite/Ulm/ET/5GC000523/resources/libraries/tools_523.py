import database_sr
import logging


def manage_database(entry, ie_object, rnti_dict, dict_attribs):
    if entry[ie_object.rnti] not in rnti_dict.keys():
        rnti_dict[entry[ie_object.rnti]] = database_sr.SchedulingRequest_sorted_rnti(dict_attribs, ie_object.event)
    elif entry[ie_object.rnti] in rnti_dict.keys():
        rnti_dict[entry[ie_object.rnti]].process_attrib(ie_object.event, dict_attribs)

    return rnti_dict


def extract_data(event_db):
    rnti_dict = {}
    for event in event_db.items():
        ie_object = event_db[event[0]][1]
        for entry in event_db[event[0]][0]:
            dict_attribs = ie_object.GenDictOfAttribs(entry)
            manage_database(entry, ie_object, rnti_dict, dict_attribs)

    return rnti_dict


def analyze(event_to_be_analyzed_csi_sr, event_to_be_analyzed_ulPreScheduler, event_to_be_analyzed_fdScheduler,
            ue_rnti, frconfig, tolerance=10):
    logging.info("Analyzing UE: %s" % ue_rnti)
    sr_count = 0
    cs1_count = 0
    intermediate_result_cs1 = False
    intermediate_result_sr = False
    intermediate_result_fdSched = False

    for element in event_to_be_analyzed_ulPreScheduler[ue_rnti]:
        if element['EventList'] == "ENTRYSR":
            cs1_count += 1

    for element in event_to_be_analyzed_csi_sr[ue_rnti]:
        if element['SR'] == "SR":
            sr_count += 1

    logging.info("UE RNTI: %s  No of SRs found: %s  No of Events in CS1 list for SRs: %s"
                 % (int(ue_rnti), int(sr_count), int(cs1_count)))

    if sr_count == 0:
        logging.error("No SRs found for RNTI %s" % ue_rnti)
    else:
        intermediate_result_sr = True

    if cs1_count >= sr_count:
        logging.info("All SRs are acknowledge by prescheduler")
        intermediate_result_cs1 = True
    else:
        logging.warn("All SRs are not acknowledged by Prescheduler")
        if 1.0 + (1.0 / tolerance) * cs1_count * cs1_count >= sr_count:
            logging.info("All SRs are most likely acknowledge by prescheduler with tolerance of %s percent"
                         % tolerance)
            intermediate_result_cs1 = True
        else:
            logging.error("All SRs are most likely NOT acknowledge by prescheduler with tolerance of %s percent"
                          % tolerance)

    if len(event_to_be_analyzed_fdScheduler[ue_rnti]) >= cs1_count:
        logging.info("All SRs are most likely scheduled")
        intermediate_result_fdSched = True
    else:
        logging.error("All SRs are most likely NOT scheduled")

    logging.info("*************************************************")
    return intermediate_result_fdSched and intermediate_result_cs1 and intermediate_result_sr


def determine_slots_per_frame(FRconfig):
    if FRconfig == "mmW":
        slotsperframe = 80
    elif FRconfig == "cmW":
        slotsperframe = 20
    else:
        print("Invalid Configuration chosen : Choose only valid config mmW | cmW")
    return slotsperframe


def determine_tl_freq_configuration(nrband):
    nr_band_dict = {"257": "mmW", "258": "mmW", "260": "mmW", "261": "mmW",
                    "34": "cmW", "38": "cmW", "39": "cmW", "40": "cmW", "41": "cmW", "50": "cmW",
                    "71": "cmW", "77": "cmW", "78": "cmW", "79": "cmW"}
    return nr_band_dict[str(nrband)]
