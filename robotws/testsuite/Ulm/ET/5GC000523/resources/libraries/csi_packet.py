class CsiSendReq:
    def __init__(self):
        self.sfn = []
        self.slots = []

    def add_sfn(self, sfn):
        self.sfn.append(sfn)

    def add_slot(self, slot):
        self.slots.append(slot)

    def extractPacket(self, root):
        CSI_RefSignal_sfn = root.xpath("icom_5g//dldata_csirssendreq//DlData_CsiRsSendReq.CsiRsSendReq.sfn")[0].show
        CSI_RefSignal_slot = root.xpath("icom_5g//dldata_csirssendreq//DlData_CsiRsSendReq.CsiRsSendReq.slot")[0].show
        CSI_RefSignal_trs = root.xpath("icom_5g//dldata_csirssendreq//..//"
                                       "DlData_CsiRsSendReq.csiRsResources_item_19.trsInfo")[0].show
        if int(CSI_RefSignal_trs, 16) == 0:
            self.sfn.append(CSI_RefSignal_sfn)
            self.slots.append(CSI_RefSignal_slot)

    def get_sfn(self):
        return self.sfn

    def get_slots(self):
        return self.slots


class PucchReceiveReq:
    def __init__(self):
        self.sfn = []
        self.slots = []
        self.rnti = []
        self.pucchFormat = []

    def extractPacket(self, root):
        PucchReceiveReq_sfn = root.xpath("icom_5g//uldata_pucchreceivereq//"
                                         "UlData_PucchReceiveReq.PucchReceiveReq.sfn")[0].show
        PucchReceiveReq_slot = root.xpath("icom_5g//uldata_pucchreceivereq//"
                                          "UlData_PucchReceiveReq.PucchReceiveReq.slot")[0].show
        PucchReceiveReq_pucchFormat = root.xpath("icom_5g//uldata_pucchreceivereq//..//"
                                                 "UlData_PucchReceiveReq.pucchResources_item_15.pucchFormat")
        PucchReceiveReq_rnti = root.xpath("icom_5g//uldata_pucchreceivereq//..//"
                                          "uldata_pucchreceivereq/UlData_PucchReceiveReq.pucchResources_item_15.rnti")
        PucchReceiveReq_nANPucch = root.xpath("icom_5g/uldata_pucchreceivereq//..//"
                                              "UlData_PucchReceiveReq.pucchResources_item_15.nANPucch")
        for itr in range(len(PucchReceiveReq_pucchFormat)):
            if int(PucchReceiveReq_pucchFormat[itr].show, 16) == 2 and \
                    int(PucchReceiveReq_nANPucch[itr].show, 16) == 0:
                self.sfn.append(PucchReceiveReq_sfn)
                self.slots.append(PucchReceiveReq_slot)
                self.rnti.append(PucchReceiveReq_rnti[itr].show)

    def get_sfn(self):
        return self.sfn

    def get_slots(self):
        return self.slots

    def get_rnti(self):
        return self.rnti

    def get_pucchFormat(self):
        return self.pucchFormat


class PucchReceiveResp:
    def __init__(self):
        self.sfn = []
        self.slots = []
        self.rnti = []
        self.dtx = []
        self.crc = []
        self.UCI_bits = []

    def extractPacket(self, root):
        PucchReceiveResp_sfn = root.xpath("icom_5g//uldata_pucchreceiverespps//"
                                          "UlData_PucchReceiveRespPs.PucchReceiveRespPs.sfn")[0].show
        PucchReceiveResp_slot = root.xpath("icom_5g//uldata_pucchreceiverespps//"
                                           "UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot")[0].show
        PucchReceiveResp_rnti = root.xpath("icom_5g//uldata_pucchreceiverespps//..//"
                                           "UlData_PucchReceiveRespPs.pucchResources_item_15.rnti")
        PucchReceiveResp_dtx = root.xpath("icom_5g/uldata_pucchreceiverespps//..//"
                                          "UlData_PucchReceiveRespPs.pucchResources_item_15.dtx")
        PucchReceiveResp_crc = root.xpath("icom_5g/uldata_pucchreceiverespps//..//"
                                          "UlData_PucchReceiveRespPs.pucchResources_item_15.crc")
        PucchReceiveResp_PucchFormat = root.xpath("icom_5g//uldata_pucchreceiverespps//..//"
                                                  "UlData_PucchReceiveRespPs.pucchResources_item_15.pucchFormat")
        PucchReceiveResp_UCIBits = root.xpath("icom_5g//uldata_pucchreceiverespps//..//"
                                              "UlData_PucchReceiveRespPs.uciBits.uciBits")
        for itr in range(len(PucchReceiveResp_PucchFormat)):
            if int(PucchReceiveResp_PucchFormat[itr].show, 16) == 2:
                self.sfn.append(PucchReceiveResp_sfn)
                self.slots.append(PucchReceiveResp_slot)
                self.crc.append(PucchReceiveResp_crc[itr].show)
                self.rnti.append(PucchReceiveResp_rnti[itr].show)
                self.dtx.append(PucchReceiveResp_dtx[itr].show)
                self.UCI_bits.append(PucchReceiveResp_UCIBits[itr].show[0:2])

    def get_sfn(self):
        return self.sfn

    def get_slots(self):
        return self.slots

    def get_rnti(self):
        return self.rnti

    def get_dtx(self):
        return self.dtx

    def get_crc(self):
        return self.crc

    def get_UCIbits(self):
        return self.UCI_bits


class sortPerUE:
    def __init__(self, ip_rnti):
        self.sfn_pucchReq = []
        self.slots_pucchReq = []
        self.sfn_PucchResp = []
        self.slots_PucchResp = []
        self.rnti = ip_rnti
        self.dtx = []
        self.crc = []
        self.report = []

    def get_sfn(self):
        return self.sfn_pucchReq

    def get_slots(self):
        return self.slots_pucchReq

    def get_sfn_PucchResp(self):
        return self.sfn_PucchResp

    def get_slots_PucchResp(self):
        return self.slots_PucchResp

    def get_rnti(self):
        return self.rnti

    def get_dtx(self):
        return self.dtx

    def get_crc(self):
        return self.crc

    def get_report(self):
        return self.report

    def add_sfn_PucchReq(self, ip_sfn):
        self.sfn_pucchReq.append(ip_sfn)

    def add_slots_PucchReq(self, ip_slot):
        self.slots_pucchReq.append(ip_slot)

    def add_sfn_PucchResp(self, ip_sfn):
        self.sfn_PucchResp.append(ip_sfn)

    def add_slots_PucchResp(self, ip_slot):
        self.slots_PucchResp.append(ip_slot)

    def add_rnti(self, ip_rnti):
        self.rnti.append(ip_rnti)

    def add_dtx(self, ip_dtx):
        self.dtx.append(int(ip_dtx, 16))

    def add_crc(self, ip_crc):
        self.crc.append(int(ip_crc, 16))

    def add_report(self, ip_report):
        self.report.append(ip_report)
