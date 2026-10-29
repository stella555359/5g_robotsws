from ta_pdml_parser import get_msgs_from_pdml_file
from robot.api import logger
from ta5g_enb import ta5g_enb


class NgMessages:
    def __init__(self, ics_ue_1_ue_2_ng_reset_messages):
        self.ics_ue_1 = ics_ue_1_ue_2_ng_reset_messages[0]
        self.ics_ue_2 = ics_ue_1_ue_2_ng_reset_messages[1]
        self.ng_reset = ics_ue_1_ue_2_ng_reset_messages[2]


def verify_if_all_ue_are_invalid_in_ng_reset(pdml_file):
    ng_messages = NgMessages(get_msgs_from_pdml_file(pdml_file))
    ics_ue_1_value_of_amf_ue_ngap_id = ng_messages.ics_ue_1.get_all_values_by_key('AMF-UE-NGAP-ID')[0]
    ics_ue_1_value_of_ran_ue_ngap_id = ng_messages.ics_ue_1.get_all_values_by_key('RAN-UE-NGAP-ID')[0]
    ics_ue_2_value_of_amf_ue_ngap_id = ng_messages.ics_ue_2.get_all_values_by_key('AMF-UE-NGAP-ID')[0]
    ics_ue_2_value_of_ran_ue_ngap_id = ng_messages.ics_ue_2.get_all_values_by_key('RAN-UE-NGAP-ID')[0]
    ng_reset_value_of_amf_ue_ngap_id = ng_messages.ng_reset.get_all_values_by_key('aMF-UE-NGAP-ID')
    ng_reset_value_of_ran_ue_ngap_id = ng_messages.ng_reset.get_all_values_by_key('rAN-UE-NGAP-ID')

    assert (ng_reset_value_of_amf_ue_ngap_id[0] != ics_ue_1_value_of_amf_ue_ngap_id or
            ng_reset_value_of_ran_ue_ngap_id[0] != ics_ue_1_value_of_ran_ue_ngap_id) and\
           (ng_reset_value_of_amf_ue_ngap_id[0] != ics_ue_2_value_of_amf_ue_ngap_id or
            ng_reset_value_of_ran_ue_ngap_id[0] != ics_ue_2_value_of_ran_ue_ngap_id)


def verify_if_invalid_and_valid_ue_in_ng_reset(pdml_file):
    ng_messages = NgMessages(get_msgs_from_pdml_file(pdml_file))
    ics_ue_1_value_of_amf_ue_ngap_id = ng_messages.ics_ue_1.get_all_values_by_key('AMF-UE-NGAP-ID')[0]
    ics_ue_1_value_of_ran_ue_ngap_id = ng_messages.ics_ue_1.get_all_values_by_key('RAN-UE-NGAP-ID')[0]
    ics_ue_2_value_of_amf_ue_ngap_id = ng_messages.ics_ue_2.get_all_values_by_key('AMF-UE-NGAP-ID')[0]
    ics_ue_2_value_of_ran_ue_ngap_id = ng_messages.ics_ue_2.get_all_values_by_key('RAN-UE-NGAP-ID')[0]
    ng_reset_value_of_amf_ue_ngap_id = ng_messages.ng_reset.get_all_values_by_key('aMF-UE-NGAP-ID')
    ng_reset_value_of_ran_ue_ngap_id = ng_messages.ng_reset.get_all_values_by_key('rAN-UE-NGAP-ID')
    assert ((ics_ue_1_value_of_amf_ue_ngap_id == ng_reset_value_of_amf_ue_ngap_id[0] and
            ics_ue_1_value_of_ran_ue_ngap_id == ng_reset_value_of_ran_ue_ngap_id[0]) and
            (ics_ue_2_value_of_amf_ue_ngap_id != ng_reset_value_of_amf_ue_ngap_id[1] or
             ics_ue_2_value_of_ran_ue_ngap_id != ng_reset_value_of_ran_ue_ngap_id[1])) or\
        ((ics_ue_1_value_of_amf_ue_ngap_id == ng_reset_value_of_amf_ue_ngap_id[1] and
         ics_ue_1_value_of_ran_ue_ngap_id == ng_reset_value_of_ran_ue_ngap_id[1]) and
         (ics_ue_2_value_of_amf_ue_ngap_id != ng_reset_value_of_amf_ue_ngap_id[0] or
          ics_ue_2_value_of_ran_ue_ngap_id != ng_reset_value_of_ran_ue_ngap_id[0])) or\
        ((ics_ue_1_value_of_amf_ue_ngap_id != ng_reset_value_of_amf_ue_ngap_id[0] or
         ics_ue_1_value_of_ran_ue_ngap_id != ng_reset_value_of_ran_ue_ngap_id[0]) and
         (ics_ue_2_value_of_amf_ue_ngap_id == ng_reset_value_of_amf_ue_ngap_id[1] and
          ics_ue_2_value_of_ran_ue_ngap_id == ng_reset_value_of_ran_ue_ngap_id[1])) or\
        ((ics_ue_1_value_of_amf_ue_ngap_id != ng_reset_value_of_amf_ue_ngap_id[1] or
         ics_ue_1_value_of_ran_ue_ngap_id != ng_reset_value_of_ran_ue_ngap_id[1]) and
         (ics_ue_2_value_of_amf_ue_ngap_id == ng_reset_value_of_amf_ue_ngap_id[0] and
          ics_ue_2_value_of_ran_ue_ngap_id == ng_reset_value_of_ran_ue_ngap_id[0]))


def verify_valid_ue(pdml_file):
    logger.console("Veryfing valid UE ID")
    ng_messages = NgMessages(get_msgs_from_pdml_file(pdml_file))
    ics_ue_1_value_of_amf_ue_ngap_id = ng_messages.ics_ue_1.get_all_values_by_key('AMF-UE-NGAP-ID')[0]
    ics_ue_1_value_of_ran_ue_ngap_id = ng_messages.ics_ue_1.get_all_values_by_key('RAN-UE-NGAP-ID')[0]
    ics_ue_2_value_of_amf_ue_ngap_id = ng_messages.ics_ue_2.get_all_values_by_key('AMF-UE-NGAP-ID')[0]
    ics_ue_2_value_of_ran_ue_ngap_id = ng_messages.ics_ue_2.get_all_values_by_key('RAN-UE-NGAP-ID')[0]
    ng_reset_value_of_amf_ue_ngap_id = ng_messages.ng_reset.get_all_values_by_key('aMF-UE-NGAP-ID')
    ng_reset_value_of_ran_ue_ngap_id = ng_messages.ng_reset.get_all_values_by_key('rAN-UE-NGAP-ID')
    if ((ics_ue_1_value_of_amf_ue_ngap_id == ng_reset_value_of_amf_ue_ngap_id[0] and
        ics_ue_1_value_of_ran_ue_ngap_id == ng_reset_value_of_ran_ue_ngap_id[0]) and
        (ics_ue_2_value_of_amf_ue_ngap_id != ng_reset_value_of_amf_ue_ngap_id[1] or
         ics_ue_2_value_of_ran_ue_ngap_id != ng_reset_value_of_ran_ue_ngap_id[1])):
        logger.console(ics_ue_1_value_of_ran_ue_ngap_id)
        return ics_ue_1_value_of_ran_ue_ngap_id
    elif ((ics_ue_1_value_of_amf_ue_ngap_id == ng_reset_value_of_amf_ue_ngap_id[1] and
          ics_ue_1_value_of_ran_ue_ngap_id == ng_reset_value_of_ran_ue_ngap_id[1]) and
          (ics_ue_2_value_of_amf_ue_ngap_id != ng_reset_value_of_amf_ue_ngap_id[0] or
           ics_ue_2_value_of_ran_ue_ngap_id != ng_reset_value_of_ran_ue_ngap_id[0])):
        logger.console(ics_ue_1_value_of_ran_ue_ngap_id)
        return ics_ue_1_value_of_ran_ue_ngap_id
    elif ((ics_ue_1_value_of_amf_ue_ngap_id != ng_reset_value_of_amf_ue_ngap_id[0] or
          ics_ue_1_value_of_ran_ue_ngap_id != ng_reset_value_of_ran_ue_ngap_id[0]) and
          (ics_ue_2_value_of_amf_ue_ngap_id == ng_reset_value_of_amf_ue_ngap_id[1] and
           ics_ue_2_value_of_ran_ue_ngap_id == ng_reset_value_of_ran_ue_ngap_id[1])):
        logger.console(ics_ue_2_value_of_ran_ue_ngap_id)
        return ics_ue_2_value_of_ran_ue_ngap_id
    elif ((ics_ue_1_value_of_amf_ue_ngap_id != ng_reset_value_of_amf_ue_ngap_id[1] or
          ics_ue_1_value_of_ran_ue_ngap_id != ng_reset_value_of_ran_ue_ngap_id[1]) and
          (ics_ue_2_value_of_amf_ue_ngap_id == ng_reset_value_of_amf_ue_ngap_id[0] and
           ics_ue_2_value_of_ran_ue_ngap_id == ng_reset_value_of_ran_ue_ngap_id[0])):
        logger.console(ics_ue_2_value_of_ran_ue_ngap_id)
        return ics_ue_2_value_of_ran_ue_ngap_id


def verify_if_ue_associated_logical_ng_connection_is_empty(pdml_file):
    ics_ue_1_ue_2_ng_reset_messages = get_msgs_from_pdml_file(pdml_file)
    ng_reset = ics_ue_1_ue_2_ng_reset_messages[2]
    if "aMF-UE-NGAP-ID" not in ng_reset and "rAN-UE-NGAP-ID" not in ng_reset:
        return True
    else:
        raise Exception("The list is not empty")


def verify_if_ue_ids_the_same_in_ng_reset_and_ng_reset_ack(pdml_file):
    ics_ue_1_ue_2_ng_reset_messages = get_msgs_from_pdml_file(pdml_file)
    ng_reset = ics_ue_1_ue_2_ng_reset_messages[2]
    ng_reset_ack = ics_ue_1_ue_2_ng_reset_messages[3]
    ng_reset_value_of_amf_ue_ngap_id = ng_reset.get_all_values_by_key('aMF-UE-NGAP-ID')
    ng_reset_value_of_ran_ue_ngap_id = ng_reset.get_all_values_by_key('rAN-UE-NGAP-ID')
    ng_reset_ack_value_of_amf_ue_ngap_id = ng_reset_ack.get_all_values_by_key('aMF-UE-NGAP-ID')
    ng_reset_ack_value_of_ran_ue_ngap_id = ng_reset_ack.get_all_values_by_key('rAN-UE-NGAP-ID')

    assert ng_reset_value_of_amf_ue_ngap_id[0] == ng_reset_ack_value_of_amf_ue_ngap_id[0] and\
        ng_reset_value_of_ran_ue_ngap_id[0] == ng_reset_ack_value_of_ran_ue_ngap_id[0] and\
        ng_reset_value_of_amf_ue_ngap_id[1] == ng_reset_ack_value_of_amf_ue_ngap_id[1] and\
        ng_reset_value_of_ran_ue_ngap_id[1] == ng_reset_ack_value_of_ran_ue_ngap_id[1]
