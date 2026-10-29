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
    return list(numbers) == [3]*nr_cells
