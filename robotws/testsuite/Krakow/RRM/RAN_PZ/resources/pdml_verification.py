import os
from taf.analyzer.pdml import pdml
from taf.rfrl.utilities.robot.general import get_builtin_value


def get_pdml_file_path():
    log_dir = get_builtin_value('OUTPUT_DIR')
    pdml_file = os.path.join(log_dir, "tcpdump.xml")
    return pdml_file


def convert_pcap_to_xml():
    log_dir = get_builtin_value('OUTPUT_DIR')
    tcpdump_collector_name = get_builtin_value('tcpdump_collector_name')
    tcpdump_file = os.path.join(log_dir, tcpdump_collector_name, "{}.pcap".format(tcpdump_collector_name))
    pdml_file = get_pdml_file_path()
    code = os.system("tshark -r {} -T pdml > {}".format(tcpdump_file, pdml_file))

    assert code == 0, "Cannot convert the file."

    return pdml_file


def verify_messages_in_pdml_file(messages, pdml_file=None):
    """
    General keywords for verify messages in pdml files.
    Sample usage in robot:
        *** Variables ***
        @{messages}  SgNBAdditionRequest  SgNBAdditionRequestAcknowledge  SgNBReconfigurationComplete  SNStatusTransfer
        *** Test Cases ***
        Sample_TC
            verify_messages_in_pdml_file  messages=@{messages}
    :param messages: list of message fields
    :param pdml_file: path to pdml file
    :return:
    """

    if pdml_file is None:
        pdml_file = get_pdml_file_path()

    msg_seq_list = ["{}.*".format(message) for message in messages]
    msg_seq = "\n".join(msg_seq_list)
    pdml.check_msc(file_name=pdml_file,
                   field_name_list=messages,
                   message_sequence=msg_seq)


def verify_pdml_attribute_value_exists(message_mapping, mode='any', pdml_file=None):
    """

    :param message_mapping: list of message dicts: [{'field_name: some, name: some. value:some}, ...]
    :param mode: any|all - indicate if any or all messages should occurs in the pdml file
    :param pdml_file: source file
    :return:
    """

    error_message = []
    if pdml_file is None:
        pdml_file = get_pdml_file_path()

    for record in message_mapping:

        pdml_entries = pdml.get_pdml_entries(file_name=pdml_file,
                                             field_name=record['field_name'],
                                             attrib_name=record['name'],
                                             attrib_value=record['value'])

        collected_value = pdml.get_attrib_value_from_pdml_entries(pdml_entries=pdml_entries,
                                                                  field_name=record['field_name'],
                                                                  attrib_name=record['name'])
        if collected_value:
            print("Collected value {}".format(collected_value))
            if mode == 'any':
                break
        else:
            error_message.append("Cannot find filed name '{}' with attribute '{}'".format(record['field_name'],
                                                                                          record['value']))
    else:
        assert not error_message, error_message
