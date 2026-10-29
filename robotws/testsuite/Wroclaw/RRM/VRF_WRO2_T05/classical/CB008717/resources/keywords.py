import re
import os

messages_8717 = [r"SNodeAdditionRequest : {", r"cellGroupID 1\n\s*}\n\s*},", r"uL-PDCP shared",
                 r"cellGroupID 1", r"SNodeAdditionRequestAcknowledge : {",
                 r"rrcReconfiguration : {", r"gapUE release : NULL", r"mrdc-SecondaryCellGroup nr-SCG : {",
                 r"servCellIndex 1", r"rrcReconfigurationComplete : {",
                 r"scg-Response nr-SCG-Response : {"]

messages_8717_PSCell = ["UEContextModificationRequest", "UEContextModificationResponse",
                        "DLRRCMessageTransfer", "rrcReconfiguration", "ULRRCMessageTransfer",
                        "UEContextModificationResponse"]

messages_8717_NRDC = ["UEContextModificationRequest", "DLRRCMessageTransfer", "rrcReconfiguration",
                      "rrcReconfigurationComplete"]

messages_8717_ENDC = ["UEContextModificationRequest", "DLRRCMessageTransfer", "rrcReconfiguration",
                      "rrcReconfigurationComplete"]

messages_8717_NB4 = [r'"sCellToAddModList":\s\[\n\s*(?:\n*.*\n){3}.*"physCellId":\s100',
                     r'"sCellIndex":\s2,(?:(?:\n\s*.*\n\s*){1,5})?"physCellId":\s*118',
                     r'"reportConfigToAddModList":\s\[\n\s*(?:\n*.*\n){7}.*"eventA4"',
                     r'"sCellToReleaseList":\s\[\n\s{60}1,\n\s{60}2\n\s{56}\]',
                     r'"BearerContextModificationResponse"\s*:\s*\{[^{}]*\n(?:[^\n]*\n){0,40}.*"uP-TNL-Information"',
                     r'"cellList":\s\[\n\s{32,35}"\d{9,10}"\n\s{25,28}\],\n\s{25,30}"reason":\s"nrdcSnodeAddition",',
                     r'"mrdc-SecondaryCellGroup":\s\{\n\s*"nr-SCG":']

messages_8717_NB6 = [r'"mrdc-SecondaryCellGroupConfig":\s{\n\s{50,65}"release":\s?null',
                     r'"radioBearerConfig":\s{(?:\s*\n.*){5,9}\s*"statusReportRequired":\s"true"',
                     r'},\n\s{45,50}"measConfig":\s{(?:\s*\n.*){5,9}"ssbFrequency":\s5\d{5},',
                     r'"reportConfigToAddModList":\s\[\n\s*(?:\n*.*\n){7}.*"eventA1"',
                     r'"sCellToAddModList":\s\[\n\s*(?:\n*.*\n){3}.*"physCellId":\s100',
                     r'"sCellIndex":\s2,(?:(?:\n\s*.*\n\s*){1,5})?"physCellId":\s*118',
                     r'"User_data":\s"F1AP:?\s?BufferMonitoringNotification"',
                     r'"User_data":\s"F1AP:?\s?BufferCriterionNotification"']


frequency_band = r"frequencyBandList\s{\n\s*(25[7-9]|26[01])"

messages_found = {}
messages_repeated = {}


def check_8717_emil_messages_flow(exp_mesgs, path):
    """
    This function verifies all the messages required in EMIL by test with respect of order. First, it iterates over
    exp_mesgs (type: list), then it registers repeated values and assigns number of line in which it was discovered.
    In the end all the messages before SNodeAdditionRequest are cleared as not needed. Finally the frequencyBandList
    is checked (range 257-261).
    Args:
        param exp_mesgs (list): list of ordered regex messages needed to be found
        param path      (str):  path of csv emil log
    Returns:
        True if all messages are found in good order, false if otherwise.
    """
    for mesg in exp_mesgs:
        get_message_line(mesg, path)  # for every match from exp_mesgs a line which contains this match is assigned
    messages_found.update(messages_repeated)  # every message that appeared more than once is added to dict
    messages_found_ordered = dict(sorted(messages_found.items(), key=lambda x: x[1]))  # ordering mesgs by line number
    sNodeAdditionRequest_unwanted_mesgs = {key: val for key, val in messages_found_ordered.items() if
                                           key.startswith(r"SNodeAdditionRequest : {")}
    starting_line = list(sNodeAdditionRequest_unwanted_mesgs.values())[-1]  # this message is first to be considered
    messages_found_ordered = {key: val for key, val in messages_found_ordered.items() if val >= starting_line}
    print("*" * 200)
    # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    # othter message that appeared before SNodeAddistionRequest are not necessary so this comprehension removes them
    ################################################################################################################
    # The lines below are clearing all RRC messages leaving only first appearance of rrcReconfiguration and
    # rrcReconfigurationComplete after SNodeAdditionRequest appeared. It also leaves only first two cellGroupID 1s.
    rrcReconfig_unwanted_mesgs = {key: val for key, val in messages_found_ordered.items() if
                                  key.startswith(r"rrcReconfiguration : {")}
    rrcReconfig_unwanted_mesgs.pop(str(list(rrcReconfig_unwanted_mesgs)[0]))  # First item needs to be saved
    rrcReconfigComplete_unwanted_mesgs = {key: val for key, val in messages_found_ordered.items() if
                                          key.startswith(r"rrcReconfigurationComplete : {")}
    rrcReconfigComplete_unwanted_mesgs.pop(str(list(rrcReconfigComplete_unwanted_mesgs)[0]))  # Same as above
    sNodeAdditionRequestAck_unwanted_mesgs = {key: val for key, val in messages_found_ordered.items() if
                                              key.startswith(r"SNodeAdditionRequestAcknowledge : {")}
    sNodeAdditionRequestAck_unwanted_mesgs.pop(str(list(sNodeAdditionRequestAck_unwanted_mesgs)[0]))  # Same as above
    servCellIndex_unwanted_mesgs = {key: val for key, val in messages_found_ordered.items() if
                                    key.startswith(r"servCellIndex 1")}
    servCellIndex_unwanted_mesgs.popitem()  # Here last servCellIndex is saved from removing
    cellGroupID_unwanted_mesgs = {key: val for key, val in messages_found_ordered.items() if
                                  key.startswith(r"cellGroupID 1")}
    for i in reversed(range(len(cellGroupID_unwanted_mesgs.keys()))):
        if i <= 1:
            cellGroupID_unwanted_mesgs.pop(str(list(cellGroupID_unwanted_mesgs)[i]))  # 2 first cellGroup mesgs saved
    for i in rrcReconfig_unwanted_mesgs.keys():
        messages_found_ordered.pop(i)
    for i in rrcReconfigComplete_unwanted_mesgs.keys():
        messages_found_ordered.pop(i)
    for i in sNodeAdditionRequestAck_unwanted_mesgs.keys():
        messages_found_ordered.pop(i)
    for i in servCellIndex_unwanted_mesgs.keys():
        messages_found_ordered.pop(i)
    for i in cellGroupID_unwanted_mesgs.keys():
        messages_found_ordered.pop(i)
    ################################################################################################################
    messages_found_ordered = list(messages_found_ordered.keys())  # ordered list of messages that appeared in log
    get_frequencyBandList(path)  # checking if frequencyBandList is in range 257-261
    print("ALL FOUND MESSAGES ORDERED BY LINES: \n", messages_found_ordered)  # final mesgs found and ordered
    print("EXPECTED MESSAGES: \n", exp_mesgs)  # expected mesgs for visual comparison
    # The loop below is comparing all messages found and expected messages between each other
    for i in range(len(exp_mesgs)):
        print("Comparing '{}' from gotten messages and '{}' from expected pattern..."
              .format(messages_found_ordered[i][:-2], exp_mesgs[i]))  # -2 for avoiding unique number assigned before
        if re.search(messages_found_ordered[i][:-2], exp_mesgs[i], re.IGNORECASE) is None:
            if re.search(exp_mesgs[i], messages_found_ordered[i][:-2], re.IGNORECASE) is None:
                print("Message match not found.\n " + "-" * 30)
                return False
            else:
                print("Message match found.\n" + "-" * 30)
        else:
            print("Message match found.\n" + "-" * 30)
    return True


def get_message_line(message_element, path):
    """
    This function iterates over lines of string in file. If specific message is found, it's placed in
    dict 'messages_found".
    If message found is already repeated, it will get an additional index (i.e. cellGroupID 1)
    and will be placed in dicttionary 'messages_repeated'.
    Args:
        param message_element (str):
        param path            (str):  path of csv emil log
    """
    with open(path) as file:
        for num, line in enumerate(file, 1):
            if re.search(message_element, line, re.MULTILINE) is not None:
                if message_element not in messages_found:
                    messages_found[message_element] = num
                    # every first appearance of message has line number assigned
                    continue
                else:
                    messages_repeated[message_element + "{}".format(len(messages_repeated))] = num
                    # additionally, unique number for every repeated message has line number assigned


def get_frequencyBandList(path):
    """
    This function checks if frequencyBandList is from allowed range of 257-261 (edge values included).
    It was separated from the function get_message_line due to need of checking multiple lines.
    Args:
        param message_element (str):
        param path            (str):  path of csv emil log
    Returns:
        True if frequencyBandList is from allowed range of 257-261, false if otherwise.
    """
    with open(path) as file:
        contents = file.read()
        frequencyBandList = int(re.findall(frequency_band, contents, re.MULTILINE)[0])
        print("frequencyBandList: {}".format(frequencyBandList))
        if frequencyBandList:
            print("FrequencyBandList is from right range of 257-261.")
            return True
        else:
            raise Exception("FrequencyBandList is outside the allowed range of 257-261.")


def check_8717_emil_messages_flow_PSCell(exp_mesgs, path):
    with open(path) as file:
        contents = file.read()
        print(contents)
        print("*" * 40)
        for mesg in exp_mesgs:
            print("Searching " + mesg)
            if mesg not in contents:
                print("Mesg {} not found!".format(mesg))
                return False
            else:
                print(mesg + " found.")
        return True


def check_8717_N_json_messages(exp_mesgs: list, path: str) -> bool:
    """
    This function verifies all the messages required in JSON file by test.
    :param exp_mesgs: list of expected messages that are regex patterns
    :param path: path to JSON file
    :return: True if all messages are found in good order, false if otherwise.
    """
    all_files = os.listdir(path)
    full_logs = [file for file in all_files if "full" in file]
    print(full_logs)

    if not full_logs:
        print("No full logs found.")
        return False

    found_messages = {mesg: False for mesg in exp_mesgs}

    for full_log in full_logs:
        full_dcap_logs_path = f"{path}/{full_log}"

        try:
            with open(full_dcap_logs_path, 'r', encoding='utf-8') as file:
                contents = file.read()

                print("*" * 40)
                for mesg in exp_mesgs:
                    print("Searching " + mesg)
                    if re.search(mesg, contents, re.IGNORECASE) is not None:
                        print(f"{mesg} found.")
                        found_messages[mesg] = True
                    else:
                        print(f"{mesg} not found in {full_log}")
                print("*" * 40)

        except Exception as e:
            print(f"Error: {e}")
            return False

    if all(found_messages.values()):
        return True
    else:
        print("Not all messages were found.")
        return False
