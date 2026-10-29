from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.admin.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.admin.AdminHelper import AdminHelper
import re

messages_8140 = ["ULRRCMessageTransfer", "UEContextModificationRequest", r'"sCellToReleaseList":\s?\[\n\s{1,95}2',
                 "DLRRCMessageTransfer", r'"resourceToReleaseList":\s?\[\n\s{1,125}\d\d?,\n\s{1,125}\d\d?',
                 "rrcReconfigurationComplete", r'"RRCReconfigurationCompleteIndicator":\s?"true"']

messages_8140_CB = ["BearerContextModificationRequest",
                    "BearerContextModificationResponse", "UEContextModificationRequest",
                    "UEContextModificationResponse", "DLRRCMessageTransfer", "rrcReconfiguration",
                    "rrcReconfigurationComplete", "ULRRCMessageTransfer"]

messages_8140_FA = ["ULRRCMessageTransfer", "UEContextModificationRequest", "DLRRCMessageTransfer",
                    r'"sCellToAddModList":\s?\[\s[A-Za-z0-9\s{}":,]{10,450}"physCellId":\s?60',
                    "rrcReconfigurationComplete", r'"RRCReconfigurationCompleteIndicator":\s?"true"',
                    "BearerContextModificationResponse", "pDUSessionResourceSetupResponse"]

messages_8140_CF = ["ULRRCMessageTransfer", "UEContextModificationRequest", "DLRRCMessageTransfer",
                    "rrcReconfigurationComplete", r'"RRCReconfigurationCompleteIndicator":\s?"true"']

filters_8140_FA = ["nokiaxnap.SCell_For_IgNB_CA_Establishment_Setup_List == 2",
                   "nokiaxnap.radioNetwork == 29",
                   "nokiaxnap.IgNBCAAdditionRequest_element",
                   "nokiaxnap.IgNBCAModificationRequest_element",
                   "nokiaxnap.IgNBCAModificationRequestAcknowledge_element",
                   "nokiaf1ap.IgNB_CA_SCell_ToBeSetup_List == 2",
                   "nokiaf1ap.IgNB_CA_SCell_Failed_to_Setup_List == 1",
                   "nokiaf1ap.UEContextModificationResponse_element",
                   "e1ap.BearerContextModificationRequest_element",
                   "e1ap.BearerContextModificationResponse_element"]


def check_messages_in_csv(exp_mesgs, path):
    with open(path) as file:
        contents = file.read()
        print(contents)
        print("*" * 40)
        if re.search("srs-config IE", contents, re.IGNORECASE):
            return False
        for mesg in exp_mesgs:
            print("Searching " + mesg)
            if re.search(mesg, contents, re.IGNORECASE) is None:
                print("Mesg {} not found!".format(mesg))
                return False
            else:
                print(mesg + " found.")
        return True


def check_drb_messages_in_csv(exp_mesgs, path):
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


def verify_tshark_messages(pcap_path, filters):
    results_list = []
    for filter in filters:
        results_list.append(generated_pcap_data(pcap_path, filter=filter))
    for i in range(len(filters)):
        if results_list[i] is not False:
            print(filters[i] + " found." + "\n" + "*" * 50)
        else:
            print(filters[i] + " not found." + "\n" + "*" * 50)
            return False


def generated_pcap_data(pcap_path, filter):
    tshark = TSharkCommandAssembler()
    output = tshark \
        .with_filter(filter) \
        .with_pcap_file(pcap_file=pcap_path) \
        .build()
    return output


def verify_8140_bts_counter(counter_list, counter_id, moid, moid_2="260"):
    for counter_dict in counter_list:
        if counter_id in counter_dict.keys():
            try:
                return counter_dict[counter_id][moid]
            except KeyError:
                return counter_dict[counter_id][moid_2]


def change_weight_for_ignb_ca(bts_id, nradjgnb_id, weight):
    """
    This function changes the weight parameter for inter-gNB CA by its id.
    :param nradjgnb_id: (tuple of ints), nradjgnb_id separated by comma (at least one object)
    :param weight: (int), weight for inter-gNB CA
    :return: None
    """
    delta = DeltaStore()
    delta.initialise_delta_store()
    objects_list = []

    if isinstance(nradjgnb_id, tuple):
        objects_list = list(nradjgnb_id)
    else:
        objects_list = nradjgnb_id.split(',')

    for object_id in objects_list:
        delta.add_param_to_delta(
            dist_name=f"MRBTS-{bts_id}/NRBTS-{bts_id}/NRADJGNB-{object_id}",
            param_name="weightForIgnbCaSelection",
            value=weight
        )

    delta_values = delta.collect_delta_store()
    admin = AdminHelper()
    admin.recommission_with_delta_from_admin(delta_values)


def change_pmcounter_group(bts_id, drb_group, value):
    """
    This function changes the pmCounterGroup NIDD parameter for MO NRDRB.
    :param drb_group: int, NRDRB ID for which pmCounterGroup will be changed
    :param value: (int), value of NIDD pmCounterGroup
    :return: None
    """
    delta = DeltaStore()
    delta.initialise_delta_store()

    delta.add_param_to_delta(
        dist_name=f"MRBTS-{bts_id}/NRBTS-{bts_id}/NRDRB-{drb_group}",
        param_name="pmCounterGroup",
        value=value
    )

    delta_values = delta.collect_delta_store()
    admin = AdminHelper()
    admin.recommission_with_delta_from_admin(delta_values)


def search_syslog_for_ue_bulk_release(syslog_path, idcu_num=2):
    """
    This function searches the syslog to find UE bulk release for 3UEs (can be changed in the end).
    :param syslog_path: path to BTS log
    :param idcu_num:    number of expected idCus found in syslog (-JA: 3, JD: 2)
    :return: True if number of expected UEs with Bulk release messages were found, false if otherwise.
    """
    found_ueids = set()
    pattern = r'UeBulkReleaseReq.*\s*\[ueIdCu:(?P<ue_id>\d+)]\sReceived\sUeBulkReleaseReq\s' \
              r'UeContextReleaseCause:oAndMIntervention'
    with open(syslog_path) as syslog_file:
        contents = syslog_file.read()
        for match in re.finditer(pattern, contents):
            ueid = int(match.group('ue_id'))
            if ueid not in found_ueids:
                found_ueids.add(ueid)
                print(f"Found message with ueIdCu={ueid}")
    return len(found_ueids) >= idcu_num


def check_ca_establishment(pcap_path, *cc_num):
    """
    This function checks tshark logs to verify that all UEs (determined by number of *cc_num arguments)
    have proper CA established.

    :param pcap_path: pcap file path
    :param cc_num: number of cc for every UE used (example: 1 UE with 3CC and 1 UE with 2CC would be: 3, 2)
    :return: True if every UE has expected number of CC
    """

    results_list = []
    cc_dict = {}

    output = generated_pcap_data(pcap_path, filter="nokiaf1ap.C_RNTI and nokiaf1ap.procedureCode == 11")

    for mesg in output:
        if re.search("C-RNTI: ", mesg, re.IGNORECASE):
            results_list.append(mesg)

    rntis = {int(word) for mesg in results_list
             for word in mesg.split()
             if word.isnumeric()}
    print("RNTIs found: {}".format(rntis))

    for rnti in rntis:
        output = generated_pcap_data(pcap_path, filter="nr-rrc.physCellId and nokiaf1ap.C_RNTI == {}".format(rnti))
        ca_cells_set = set()

        for mesg in output:
            if re.search("physCellId: ", mesg, re.IGNORECASE):
                ca_cells_set.add(mesg)

        cc_dict[rnti] = {int(val.split(':')[1].strip()) for val in ca_cells_set}
    print("RNTIs and their cells: {}".format(cc_dict))
    exp_cc_list = [int(cc) for cc in cc_num]
    print("Expected CA established by UEs: {}".format(exp_cc_list))
    act_cc_list = [len(exp_cc_list) for exp_cc_list in cc_dict.values()]
    print("List of CA established by UEs: {}".format(act_cc_list))
    return True if len(exp_cc_list) == len(act_cc_list) and sorted(exp_cc_list) == sorted(act_cc_list) else False


def check_reset_f1ap_messages(pcap_path, ue_count):
    """
    This function returns all unique ue ids from tshark pcap filtering F1AP resets.
    :param pcap_path: pcap file path
    :param ue_count:  int number of message occurrence (determined by amount of UEs with F1 reset detected)
    :return: True if number of F1AP reset messages are as expected, False if otherwise.
    """
    results_list = []
    output = generated_pcap_data(pcap_path, filter="nokiaf1ap.procedureCode == 0")
    print(output)
    for mesg in output:
        if re.search("gNB-CU-UE-F1AP-ID: ", mesg, re.IGNORECASE):
            results_list.append(mesg)
    ueidcu = {int(word) for mesg in results_list
              for word in mesg.split()
              if word.isnumeric()}
    print("UeIdCu found: ", ueidcu)
    return True if len(ueidcu) == int(ue_count) else False  # Looking for UEs that had F1 Reset detected.


def check_reset_e1ap_messages(pcap_path, ue_count):
    """
    This function returns all unique ue ids from tshark pcap filtering E1AP resets.
    :param pcap_path: pcap file path
    :param ue_count:  int number of message occurrence (determined by amount of UEs with E1 reset detected)
    :return: True if number of F1AP reset messages are as expected, False if otherwise.
    """
    results_list = []
    output = generated_pcap_data(pcap_path, filter="e1ap.procedureCode == 0")
    print(output)
    for mesg in output:
        if re.search("gNB-CU-CP-UE-E1AP-ID:", mesg, re.IGNORECASE):
            results_list.append(mesg)
    ueidcu = {int(word) for mesg in results_list
              for word in mesg.split()
              if word.isnumeric()}
    print("UeIdCu found: ", ueidcu)
    return True if len(ueidcu) == int(ue_count) else False  # Looking for UEs that had E1 Reset detected.


def check_reset_xnap_messages(pcap_path, xnlink_count):
    """
    This function returns all occurrences of XN link resets.
    :param pcap_path: pcap file path
    :param xnlink_count:  int number of expected xnlink reset occurrences.
    :return: True if number of message occurrences is as expected, False if otherwise.
    """
    results_list = []
    output = generated_pcap_data(pcap_path, filter="nokiaxnap.procedureCode == 20")
    print(output)
    for mesg in output:
        if re.search("ng-ran-node1UEXnAPID: ", mesg, re.IGNORECASE):
            results_list.append(mesg)
    xnapid = {int(word) for mesg in results_list
              for word in mesg.split()
              if word.isnumeric()}
    print("XnAP ids found: ", xnapid)
    return True if len(xnapid) == int(xnlink_count) else False  # 2 occurrences for prime, 1 for external gNB.
