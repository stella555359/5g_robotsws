from taf.analyzer.pdml import pdml


def verify_message_sequence_in_pdml_file(pdml_file, messages):
    msg_seq = messages.split(" ")
    messages = ".*\n".join(msg_seq)
    field_name_list = ["x2ap." + message for message in msg_seq]
    field_name_list = [message + "_element" for message in field_name_list]
    pdml.check_msc(pdml_file, field_name_list, messages)


def verify_message_sequence_not_in_pdml_file(pdml_file, messages):
    try:
        verify_message_sequence_in_pdml_file(pdml_file, messages)
    except AssertionError as error:
        return
    raise AssertionError("unexpected x2ap messages:" + messages)
