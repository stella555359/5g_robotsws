from telnetlib import Telnet
import re
import time


def egate_telnet_session():
    tn = Telnet('127.0.0.1', port=20000)
    tn.read_until("EGATE>".encode(), timeout=None)
    return tn


def excute_egate_command(command, expected_string, tn):
    command = command + '\r'
    tn.write(command.encode())
    time.sleep(1)
    output = tn.read_until(expected_string.encode(), timeout=20)
    output = output.decode(encoding='UTF-8', errors="ignore")
    output = re.compile(r'\x1b(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])').sub('', output).replace('\r\n', '')
    print(output)
    return output


def verify_data_start(output, expectation):
    if expectation in output:
        return 'Pass'
    else:
        return 'Fail'


def start_data(ue_id, pdu_id, qfi_id, dire, trf_id, rate,
               desired_string="Started Downlink Internal traffic Receiver"):
    command = ('trf_data_start ' + 'ue=' + str(ue_id) + ' pdu=' + str(pdu_id) + ' qfi=' + str(qfi_id) +
               ' dir=' + dire + ' trf_id=' + str(trf_id) + ' kbps=' + str(rate))
    print(command)
    if 'ul' in dire:
        desired_string = "Started Uplink Internal traffic Receiver on Ue:" + str(ue_id)
    elif 'dl' in dire:
        desired_string = "Started Downlink Internal traffic Receiver on Ue:" + str(ue_id)

    session = egate_telnet_session()
    return excute_egate_command(command, desired_string, session)


def modify_pdu_session(ue_id, pdu_id, qosflows_to_add, desired_string="QoS Routing Table"):
    command = ('ue_pdu_session_modify  ue=' + str(ue_id) + '  pdu=' + str(pdu_id) + ' qosflows_to_add=' +
               str(qosflows_to_add) + ' by=amf')
    print(command)
    session = egate_telnet_session()
    return excute_egate_command(command, desired_string, session)


"""
Function Name:modify_pdu_session_verify
Desc: Adds QFI 2,3,4 in PDU ID 2
 Rests are added in PDU ID 1
"""


def modify_pdu_session_verify(ue_id, pdu_id, qosflows_to_add, ue_to_bearer_list,
                              desired_string="QoS Routing Table"):

    qos_list = qosflows_to_add.split(",")
    session = egate_telnet_session()
    print("pdu_id is", pdu_id)
    count = 0
    qfi_id = 2
    length = len(qos_list)

    for qid in qos_list:
        if qid == str(2) or qid == str(3) or qid == str(4):
            command = ('ue_pdu_session_modify  ue=' + str(ue_id) + '  pdu=' + str(2) + ' qosflows_to_add=' +
                       str(qid) + ' by=amf')
        else:
            command = ('ue_pdu_session_modify  ue=' + str(ue_id) + '  pdu=' + str(1) + ' qosflows_to_add=' +
                       str(qid) + ' by=amf')
        print("Executing command \n", command, "\n")
        chk = 0

        while True:
            print("\n ============================================================= \n")
            output = excute_egate_command(command, desired_string, session)
            # print(output)
            print("\n =============================================================  \n")
            if "Adding QosFlow with QFI" in output:
                break
            elif chk == 1:
                print("\n====== Rest of code will go for failure ====== \n")
                break
            chk += 1
        if qid == str(2) or qid == str(3) or qid == str(4):
            qos_strng = "Added QosFlow with QFI:" + str(qid)
            print("Searching ==> VONR cat", qos_strng)
            if qos_strng in output:
                for i in output.split("{"):
                    if "servedRadioBearer drb-Identity" in i:
                        print("before Spliited ", i)
                        print("8379 Feat Bearer id ", i.split(",")[1].split(":")[1])
                        # crnti_indx = int(ue_id)-1
                        bearer_id = i.split(",")[1].split(":")[1]
                        ue_to_bearer_list[ue_id].append(bearer_id)
                count += 1
        else:
            qos_strng = "Added QosFlow with QFI:" + str(qfi_id)
            print("Searching ==> NON VONR cat", qos_strng)
            qfi_id += 1
            if qos_strng in output:
                for i in output.split("{"):
                    if "servedRadioBearer drb-Identity" in i:
                        print("before Spliited ", i)
                        print("non vonr leg 8379 Feat Bearer id ", i.split(",")[1].split(":")[1])
                        # crnti_indx = int(ue_id)-1
                        bearer_id = i.split(",")[1].split(":")[1]
                        ue_to_bearer_list[ue_id].append(bearer_id)
                count += 1
        time.sleep(5)
    print("\n =================================== \n", count, length, "\n ==================")

    if count == length:
        return 'Pass'
    else:
        return 'Fail'


def update_pdu_session_gfbr_mfbr(ue_id, pdu_id, qos_prof, gbr_qfi_list_cfg, gfbr_mfbr_profile,
                                 desired_string="QoS Routing Table"):
    qfi_idx = 2
    print("pdu_id is ", pdu_id)
    session = egate_telnet_session()
    for gbr_idx in qos_prof:  # argument   qos_prof
        mfbr_dl = str(gbr_idx) + "_mfbr_dl"
        mfbr_ul = str(gbr_idx) + "_mfbr_ul"
        gfbr_ul = str(gbr_idx) + "_gfbr_ul"
        gfbr_dl = str(gbr_idx) + "_gfbr_dl"
        if str(gbr_idx) in gbr_qfi_list_cfg:
            # Argument gbr_qfi_list_cfg  gfbr_mfbr_profile
            command = ("qosflow_modify qos_flow=" + str(gbr_idx) + " mfbr_dl=" +
                       gfbr_mfbr_profile[mfbr_dl] + " mfbr_ul=" + gfbr_mfbr_profile[mfbr_ul] + " gfbr_dl="
                       + gfbr_mfbr_profile[gfbr_dl] + " gfbr_ul=" + gfbr_mfbr_profile[gfbr_ul])
            excute_egate_command(command, "EGATE", session)
            if gbr_idx == 2 or gbr_idx == 3 or gbr_idx == 4:
                pdu_id = 2
            else:
                pdu_id = 1

            command = ('ue_pdu_session_modify  ue=' + str(ue_id) + '  pdu=' + str(pdu_id) + ' qosflows_to_modify=' +
                       str(gbr_idx) + ' by=amf')
            print(command)
            chk = 0
            while True:
                print("=============================================================###############################")
                output = excute_egate_command(command, desired_string, session)
                print(output)
                print("$$$$$$$$$$$$$$$$=============================================================################")
                if "PDU SESSION RESOURCE MODIFY RESPONSE" in output:
                    break
                elif chk == 1:
                    print("\n====== Rest of code will go for failure ====== \n")
                    break
                chk += 1
            print("Check ===================================", output, "\n==================")
            qos_strng = "Added QosFlow with QFI:" + str(qfi_idx)
            if qos_strng not in output:
                return 'Fail'
        qfi_idx += 1
    return 'Pass'


def setup_xp_link(enb_id, target_id, pattern):
    output = ''
    session = egate_telnet_session()
    command_list = ["sim_trace  enb=" + str(enb_id) + "  protocol=xp on",
                    "enb_xp_param id=" + str(enb_id) + " xp_peers=none",
                    "enb_xp_param id=" + str(enb_id) + " xp_peers=" + str(target_id),
                    "enb_xp_link_up enb=" + str(enb_id) + " target=" + str(target_id)
                    ]
    desired_string = 'ENB - 2: Cell - 1 has No CRM Partnership created'
    for cmd in command_list:
        output = excute_egate_command(cmd, desired_string, session)
        print("===", output)
    if re.search(pattern, output) is not None:
        return 'Pass'
    else:
        return 'Fail'


def setup_dss_link(enb_id, target_id, pattern):
    output = ''
    session = egate_telnet_session()
    command_list = ["dss_enb_param id=" + str(enb_id) + "  feature_flag=on" + "  message_sets=V1,DMS2",
                    "enb_configure_dss_partnership enb=" + str(enb_id) + " cell=" + str(target_id) + " dss_peer=1:1",
                    ("establish_enb_dss_partnership enb=" + str(enb_id) + " cell=" + str(target_id) + " tgt_enb=" +
                     str(target_id) + " tgt_cell=" + str(target_id))]
    for cmd in command_list:
        output = excute_egate_command(cmd, pattern, session)
        print("===", output)
    if re.search(pattern, output) is not None:
        return 'Pass'
    else:
        return 'Fail'


def set_dl_ul_cell_reservation(enb_id, target_id, min_prb_ratio, max_prb_ratio, pattern):
    output = ''
    session = egate_telnet_session()
    command_list = ["enb_dss_cell_resource_reservation_dl enb=" + str(enb_id) + " cell=" + str(target_id) + " reset",
                    "enb_dss_cell_resource_reservation_ul enb=" + str(enb_id) + " cell=" + str(target_id) + " reset",
                    ("enb_dss_dl_resource_cell_reservation cell=" + str(target_id) + " enb=" + str(enb_id) +
                     " reserved_fixed_normal_subframes=1000010001-1000010001-1000010001-1000010001-1000010001-"
                     "1000010001-1000010001-1000010001"),
                    ("enb_dss_dl_resource_cell_reservation cell=" + str(target_id) + " enb=" + str(enb_id) +
                     " min_lte_nr_dss_ratio=" + str(min_prb_ratio) + " min_lte_nr_dss_ratio=" + str(max_prb_ratio)),
                    ("enb_dss_cell_resource_coordination enb=" + str(enb_id) + "  cell=" + str(target_id) +
                     " tgt_enb=" + str(target_id) + " tgt_cell=" + str(target_id) + " dir=DL"),
                    ("enb_dss_ul_cell_resource_reservation enb=" + str(enb_id) + "  cell=" + str(target_id) +
                     " minimum_prb_share=" + str(min_prb_ratio) + " maximum_prb_share=" + str(max_prb_ratio)),
                    ("enb_dss_cell_resource_coordination enb=" + str(enb_id) + "  cell=" + str(target_id) +
                     " tgt_enb=" + str(target_id) + " tgt_cell=" + str(target_id) + " dir=UL")]
    for cmd in command_list:
        output = excute_egate_command(cmd, pattern, session)
        print("===", output)
    if re.search(pattern, output) is not None:
        return 'Pass'
    else:
        return 'Fail'


def cell_resource_allocation(enb_id, target_id, prb_list, nor_subframe, pattern):
    output = ''
    session = egate_telnet_session()
    command_list = [("enb_dss_resource_allocation enb=" + str(enb_id) + "  cell=" + str(target_id) + "  tgt_enb=" +
                     str(target_id) + " tgt_cell=" + str(target_id) + " dir=DL" + " allocation_start_time=immediate" +
                     " dl_allocated_normal_subframes=" + str(nor_subframe)),
                    ("enb_dss_resource_allocation enb=" + str(enb_id) + "  cell=" + str(target_id) + "  tgt_enb=" +
                     str(target_id) + " tgt_cell=" + str(target_id) + " dir=UL" + " allocation_start_time=immediate"
                     + " ul_allocated_prb_list=" + str(prb_list))]

    for cmd in command_list:
        output = excute_egate_command(cmd, pattern, session)
        print("===", output)
    if re.search(pattern, output) is not None:
        return 'Pass'
    else:
        return 'Fail'
