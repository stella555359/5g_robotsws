# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Robot Keywords used in 5GC001927.robot
# Team: 'MN ECE ULM R&D L3NRT 07 SqdGp65'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_65@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]


# Robot Framework Libraries:


# TAF & UTE Libraries:
from taf.analyzer.pdml import pdml


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]


# ====================================================================================================[120 characters]
#   Keywords for 5GC001927-Q
# ====================================================================================================[120 characters]


def verify_message_sequence_in_pdml_file(pdml_file, messages):
    # ------------------------------------------------------------------------------------------------[120 characters]
    # Private Keyword: Verify X2 Messages in PDML File
    # General keyword for verify message sequence in pdml(xml) files
    # Input Argument(s): message sequence,  pdml file
    # Output Argument(s): N/A
    # ------------------------------------------------------------------------------------------------[120 characters]
    msg_seq = messages.split(" ")
    messages = ".*\n".join(msg_seq)
    field_name_list = ["x2ap." + message for message in msg_seq]
    field_name_list = [message + "_element" for message in field_name_list]
    pdml.check_msc(pdml_file, field_name_list, messages)


def verify_message_sequence_not_in_pdml_file(pdml_file, messages):
    # ------------------------------------------------------------------------------------------------[120 characters]
    # Private Keyword: Verify X2 Messages in PDML File
    # General keyword for verify message which should not found in pdml(xml) files
    # Input Argument(s): message sequence,  pdml file
    # Output Argument(s): N/A
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        verify_message_sequence_in_pdml_file(pdml_file, messages)
    except AssertionError as error:
        return
    raise AssertionError("unexpected x2ap messages:" + messages)


# ====================================================================================================[120 characters]
#   Internal Helper Functions for 5GC001927
# ====================================================================================================[120 characters]
