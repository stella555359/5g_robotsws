from ta_pdml_parser import get_msgs_from_pdml_file


def assert_ue_associated_logical_ng_connection_list_the_same_in_ng_reset_and_ng_reset_acknowledge(pdml_file):
    ng_reset_ng_reset_ack_messages = get_msgs_from_pdml_file(pdml_file)

    ng_reset = ng_reset_ng_reset_ack_messages[0]
    ng_reset_ack = ng_reset_ng_reset_ack_messages[1]

    ng_reset_value_of_amf_ue_ngap_id = ng_reset.get_all_values_by_key('aMF-UE-NGAP-ID')
    ng_reset_value_of_ran_ue_ngap_id = ng_reset.get_all_values_by_key('rAN-UE-NGAP-ID')
    ng_reset_ack_value_of_amf_ue_ngap_id = ng_reset_ack.get_all_values_by_key('aMF-UE-NGAP-ID')
    ng_reset_ack_value_of_ran_ue_ngap_id = ng_reset_ack.get_all_values_by_key('rAN-UE-NGAP-ID')

    assert ng_reset_value_of_amf_ue_ngap_id == ng_reset_ack_value_of_amf_ue_ngap_id
    assert ng_reset_value_of_ran_ue_ngap_id == ng_reset_ack_value_of_ran_ue_ngap_id
