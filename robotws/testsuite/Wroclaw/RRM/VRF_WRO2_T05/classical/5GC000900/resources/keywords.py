from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
from collections import Counter
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *

# using_mcshark = False


class SubCell(object):
    def __init__(self, subcellid, sfn, slot, rnti):
        self.subcellid = subcellid
        self.sfn = sfn
        self.slot = slot
        self.rnti = rnti

    def is_sfn_even(self):
        return int(self.sfn, 16) % 2 == 0

    def check_rnti(self):
        return int(self.rnti, 16) == 65535

    def check_slot(self):
        return int(self.slot, 16) == 5


class TShark_for_900_D(TSharkCommandAssembler):
    def __init__(self, tshark_path="tshark"):
        self.parameters = []
        self.grep = ""
        self.parameters.extend([tshark_path])

    def with_filter(self, wireshark_filter):
        self.parameters.extend(["-Y", wireshark_filter])
        return self


def generated_pcap_data(pcap_path):
    tshark = TSharkCommandAssembler()
    if using_mcshark:
        output = tshark \
            .with_filter("dldata_pdschpayloadtbsendreq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e 3gpp.subcellid '
                                          '-e 3gpp.sfn '
                                          '-e 3gpp.slot '
                                          '-e 3gpp.rnti') \
            .build()
    else:
        output = tshark.with_attached_lua_scripts() \
            .with_filter("dldata_pdschpayloadtbsendreq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId '
                                          '-e DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn '
                                          '-e DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot '
                                          '-e DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti') \
            .build()
    remove_luashark_loading_from_output(output=output)
    output = output[:-1]
    pcap_data = []
    for line in output:
        line = line.split("\t")
        message = SubCell(line[0], line[1], line[2], line[3])
        pcap_data.append(message)
    return pcap_data


def generated_pcap_data_for_handover(pcap_path):
    tshark = TShark_for_900_D()
    output = tshark \
        .with_filter("x2ap || s1ap") \
        .with_pcap_file(pcap_file=pcap_path) \
        .inject_additional_parameters('-T fields -e x2ap.X2AP_PDU '
                                      '-e nr-rrc.physCellId '
                                      '-e x2ap.procedureCode') \
        .build()
    pcap_data = []
    for line in output:
        if line != "\t\t":
            line = line.split("\t")
            pcap_data.append(line)
    return pcap_data


def check_values(pcap_path):
    sfn = True
    rnti = True
    slot = True
    temp = generated_pcap_data(pcap_path)
    for a in temp:
        if a.is_sfn_even():
            sfn &= True
        else:
            sfn &= False
        if a.check_rnti():
            rnti &= True
        else:
            rnti &= False
        if a.check_slot():
            slot &= True
        else:
            slot &= False
    result = [sfn, rnti, slot]
    return result


def check_sfn_for_cellid(pcap_path):
    lista = generated_pcap_data(pcap_path)
    nr_cells = 3
    sfns = []
    for i in lista:
        sfns.append(i.sfn)
    numbers = Counter(sfns).values()
    return list(numbers)


def check_measurements_success(pcap_path, cell_measurement, cell_id_before_ho):
    print("cell_measurement: ", cell_measurement)
    pcap_msgs = generated_pcap_data_for_handover(pcap_path)
    print("raw: ", pcap_msgs)
    is_handover = []
    mgs_name = {27: "SgNBAdditionRequest", 35: "Measurement Report", 34: "SgNBChangeReuired"}
    handover_msg = [['1', str(cell_id_before_ho), '27'],
                    ['0', str(cell_id_before_ho + "," + cell_measurement), '35']]
    print("handover_msg: ", handover_msg)
    for mandatory_ho_msg in handover_msg:
        if mandatory_ho_msg in pcap_msgs:
            is_handover.append(1)
        else:
            is_handover.append(0)
    if 0 in is_handover:
        return False
    else:
        return True


def check_measurements_success_in_NSA_SA_cell(pcap_path, cell_measurement):
    print("cell_measurement: ", cell_measurement)
    pcap_msgs = generated_pcap_data_for_handover(pcap_path)
    print("raw: ", pcap_msgs)
    is_handover = []
    mgs_name = {27: "SgNBAdditionRequest", 35: "Measurement Report", 34: "SgNBChangeReuired"}
    handover_msg = [['1', str(cell_measurement), '27']]
    print("handover_msg: ", handover_msg)
    for mandatory_ho_msg in handover_msg:
        if mandatory_ho_msg in pcap_msgs:
            is_handover.append(1)
        else:
            is_handover.append(0)
    if 0 in is_handover:
        return False
    else:
        return True


def check_handover_intra_freq_inter_gnb_success(pcap_path, cell_id_before_ho, cell_id_after_ho):
    print("cell_id_before_ho: ", cell_id_before_ho)
    print("cell_id_after_ho: ", cell_id_after_ho)
    pcap_msgs = generated_pcap_data_for_handover(pcap_path)
    print("raw: ", pcap_msgs)
    flat_msgs = []
    is_handover = []
    mgs_name = {27: "SgNBAdditionRequest", 35: "Measurement Report", 34: "SgNBChangeReuired"}
    for msgs in pcap_msgs:
        for msg in msgs:
            flat_msgs.append(msg)
    print("msgs: ", flat_msgs)
    # to check if mandatory messages for propper cells exist in pcap
    # {27: "SgNBAdditionRequest", 35:"Measurement Report", 34:"SgNBChangeReuired"}
    handover_msg = [['1', str(cell_id_before_ho), '27'],
                    ['1', str(cell_id_after_ho), '27'],
                    ['1', '', '34'],
                    ['0', str(cell_id_before_ho + "," + cell_id_after_ho), '35'],
                    ['0', str(cell_id_after_ho + "," + cell_id_before_ho), '35']]
    print("handover_msg: ", handover_msg)
    for mandatory_ho_msg in handover_msg:
        if mandatory_ho_msg in pcap_msgs:
            is_handover.append(1)
        else:
            is_handover.append(0)
    # if 0 in is_handover:
    if is_handover.count(0) > 1:
        print("Handover failed. Not all mandatory massages in pcap")
        return False
    else:
        return True
