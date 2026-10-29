# -*- coding: utf-8 -*

"""
:copyright: Nokia Networks
:author: Christophe SAMSON
:contact: christophe.samson@nokia.com
:maintainer:
:contact:
"""

import csv
import io
import logging
from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine, toDecimalStr


def getFieldValue(raw, fieldName):
    return raw[fieldName]

# ======================================================================================


class BitMap:
    def __init__(self, len, ble=0, bhe=0):
        self.len = len
        self.map = list("{}{}{}".format("1" * ble, "0" * (len-ble-bhe), "1" * bhe))
        self.errors = []

    def __str__(self):
        return "".join(self.map)

    def setBit(self, index):
        if index >= self.len:
            self.errors.append("Unable to set bit {} since len is {}".format(index, self.len))
        else:
            val = int(self.map[index])
            self.map[index] = "{}".format(val+1)
            if val != 0:
                self.errors.append("Overlap of bit {}".format(index))

    def setRange(self, start=0, len=1):
        for index in range(start, start+len):
            self.setBit(index)

    def isOK(self):
        return len(self.errors) == 0

    def getErrors(self):
        str = ""
        for error in self.errors:
            str = str + "{}\n".format(error)
        return str

# =======================================================================================


class SlotSfnRec:
    SlotSfnList = []

    def __init__(self, raw, prbMax, ble, bhe, pattern):
        self.slot = getFieldValue(raw, "3gpp.slot")
        self.sfn = getFieldValue(raw, "3gpp.sfn")
        self.rntiList = []
        self.csList = []
        self.bitMap = []
        # range of initialCyclicShift
        for cs_i in range(0, 11):
            self.bitMap.append(BitMap(prbMax, ble, bhe))

    def addRnti(self, raw, pattern):
        rnti = RntiPrb(raw, pattern, rnti_number=0)
        if rnti.isValid():
            self.rntiList.append(rnti)
            self.csList.append(rnti.cs)
            self.bitMap[rnti.cs].setRange(start=rnti.startPrb, len=rnti.numOfPrb)
        if rnti.nextRnti != 0:
            rnti = RntiPrb(raw, pattern, rnti_number=rnti.nextRnti)
            if rnti.isValid():
                self.rntiList.append(rnti)
                self.csList.append(rnti.cs)
                self.bitMap[rnti.cs].setRange(start=rnti.startPrb, len=rnti.numOfPrb)
            if rnti.nextRnti != 0:
                rnti = RntiPrb(raw, pattern, rnti_number=rnti.nextRnti)
                if rnti.isValid():
                    self.rntiList.append(rnti)
                    self.csList.append(rnti.cs)
                    self.bitMap[rnti.cs].setRange(start=rnti.startPrb, len=rnti.numOfPrb)

    def __eq__(self, record):
        return self.slot == record.slot and self.sfn == record.sfn

    def __str__(self):
        if len(self.csList) == 1:
            text = "SLOT={} SFN={} RNTI:{} CS:{} Check:{}".\
                format(self.slot, self.sfn, len(self.rntiList), len(self.csList), self.bitMap[self.csList[0]].isOK())
        if len(self.csList) == 2:
            text = "SLOT={} SFN={} RNTI:{} CS:{} Check:{} Check:{}".\
                format(self.slot, self.sfn, len(self.rntiList), len(self.csList),
                       self.bitMap[self.csList[0]].isOK(), self.bitMap[self.csList[1]].isOK())
        if len(self.csList) == 3:
            text = "SLOT={} SFN={} RNTI:{} CS:{} Check:{} Check:{} Check:{}".\
                format(self.slot, self.sfn, len(self.rntiList), len(self.csList),
                       self.bitMap[self.csList[0]].isOK(),
                       self.bitMap[self.csList[1]].isOK(),
                       self.bitMap[self.csList[2]].isOK())
        return text

    def isMatchingLastRec(rec):
        if len(SlotSfnRec.SlotSfnList) == 0:
            return None
        lastRec = SlotSfnRec.SlotSfnList[-1]
        if rec == lastRec:
            return lastRec
        return None

    def printRec(self, onlyKO):
        for cs_i in self.csList:
            if not self.bitMap[cs_i].isOK() or not onlyKO:
                datedConsole(self)
                self.printBitmap(onlyKO)
                if not self.bitMap[cs_i].isOK():
                    datedConsole("   getErrorsBitMap:{}".format(self.bitMap[cs_i].getErrors()))
                for idx, rnti in enumerate(self.rntiList):
                    datedConsole("   {}:{}".format(idx+1, rnti))

    def printBitmap(self, onlyKO, onlyBitmap=True):
        for cs_i in self.csList:
            if not self.bitMap[cs_i].isOK() or not onlyKO:
                datedConsole(self.bitMap[cs_i])
                if not onlyBitmap:
                    for idx, rnti in enumerate(self.rntiList):
                        datedConsole("   {}:{}".format(idx + 1, rnti))


# =======================================================================================


class RntiPrb(object):
    def __init__(self, raw, pattern, rnti_number=0):
        self.raw = raw
        pattern_start_prb = pattern + ".startPrb"
        pattern_num_prb = pattern + ".numOfPrb"
        pattern_cs = pattern + ".initialCyclicShift"
        start_prb = getFieldValue(raw, pattern_start_prb)
        num_prb = getFieldValue(raw, pattern_num_prb)
        cs = getFieldValue(raw, pattern_cs)
        rnti = getFieldValue(raw, "3gpp.rnti")
        start_prb_list = []
        num_prb_list = []
        cs_list = []
        if ',' in rnti:
            rntilist = rnti.split(',')
            self.rnti = rntilist[rnti_number]
            start_prb_list = start_prb.split(',')
            num_prb_list = num_prb.split(',')
            cs_list = cs.split(',')
            self.startPrb = int(float(toDecimalStr(start_prb_list[rnti_number])))
            self.numOfPrb = int(float(toDecimalStr(num_prb_list[rnti_number])))
            self.cs = int(float(toDecimalStr(cs_list[rnti_number])))
            # logging.info("=====> rntilist=%s" % rntilist)
            # logging.info("=====> start_prb_list=%s" % start_prb_list)
            # logging.info("=====> num_prb_list=%s" % num_prb_list)
            lastitem = start_prb_list[-1]
            if start_prb_list[rnti_number] == lastitem:
                self.nextRnti = 0
            else:
                self.nextRnti = rnti_number + 1
        else:
            self.rnti = rnti
            self.startPrb = int(float(toDecimalStr(start_prb)))
            self.numOfPrb = int(float(toDecimalStr(num_prb)))
            self.cs = int(float(toDecimalStr(cs)))
            self.nextRnti = 0
        # logging.info("=====> rnti=%s" % self.rnti)
        # logging.info("=====> startPrb=%s" % self.startPrb)
        # logging.info("=====> numOfPrb=%s" % self.numOfPrb)

#    def isValid(self):
#        return self.rnti != "0x0000ffff"
    def isValid(self):
        return toDecimalStr(self.rnti) != toDecimalStr("0xFFFF")

    def __str__(self):
        str = "{}".format(self.raw)
        return "PCK:{:30} RNTI:{} StartPRB:{:3} NumOfPrb:{:3}"\
            .format(str, self.rnti, self.startPrb, self.numOfPrb)

# =======================================================================================


def createSlotSfnRecords(csvfile, prbMax, ble, bhe, pattern, verbose=True):
    SlotSfnRec.SlotSfnList = []
    with io.open(csvfile, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile,  delimiter=';')
        for row in reader:
            if verbose:
                print(row)
            rec = SlotSfnRec(row, prbMax, ble, bhe, pattern)
            lastRec = SlotSfnRec.isMatchingLastRec(rec)
            if lastRec is not None:
                lastRec.addRnti(row, pattern)
            else:
                rec.addRnti(row, pattern)
                SlotSfnRec.SlotSfnList.append(rec)
    return SlotSfnRec


def countSlotSfnRecord(SlotSfnRec):
    return len(SlotSfnRec.SlotSfnList)


def printPartOfSlotSfnRecord(SlotSfnRec, onlyKO):
    for rec in SlotSfnRec.SlotSfnList:
        rec.printBitmap(onlyKO)
    return len(SlotSfnRec.SlotSfnList)


def countPrbInconsistency(SlotSfnRec) -> object:
    nbError = 0
    for rec in SlotSfnRec.SlotSfnList:
        for cs_i in rec.csList:
            if not rec.bitMap[cs_i].isOK():
                nbError = nbError + 1
    return nbError


def printSlotSfnRec(SlotSfnRec, onlyKO):
    for rec in SlotSfnRec.SlotSfnList:
        rec.printRec(onlyKO)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    path = '/home/ute/csamson/TRACES/IssuePUCCH2'
    csvfile = path + '/pcapprocessed_pucchResources_PRB_Blanking_uldata_pucchreceivereq_subcellId0.csv'
    SlotSfnRec = createSlotSfnRecords(csvfile=csvfile, prbMax=273, ble=55, bhe=0,
                                      pattern='UlData_pucchReceiveReqPucchResource_t')
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec)
    printSlotSfnRec(SlotSfnRec, onlyKO=True)
    countSlotSfnRecord_ul = countSlotSfnRecord(SlotSfnRec)
    countPrbInconsistency_ul = countPrbInconsistency(SlotSfnRec)
    logging.info("=====> ul countSlotSfnRecord==%s" % countSlotSfnRecord_ul)
    logging.info("=====> ul countPrbInconsistency==%s" % countPrbInconsistency_ul)
    nbr_err = countPrbInconsistency_ul / countSlotSfnRecord_ul
    logging.info("=====> ul pucchResource nbr_err==%s" % nbr_err)
    # printPartOfSlotSfnRecord(SlotSfnRec, onlyKO=True)

    csvfile = path + '/pcapprocessed_pucchResources_PRB_Blanking_uldata_pucchreceivereq_subcellId1.csv'
    SlotSfnRec_2 = createSlotSfnRecords(csvfile=csvfile, prbMax=273, ble=20, bhe=25,
                                        pattern='UlData_pucchReceiveReqPucchResource_t')
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec)
    printSlotSfnRec(SlotSfnRec_2, onlyKO=True)
    countSlotSfnRecord_ul = countSlotSfnRecord(SlotSfnRec_2)
    countPrbInconsistency_ul = countPrbInconsistency(SlotSfnRec_2)
    logging.info("=====> ul countSlotSfnRecord==%s" % countSlotSfnRecord_ul)
    logging.info("=====> ul countPrbInconsistency==%s" % countPrbInconsistency_ul)
    nbr_err = countPrbInconsistency_ul / countSlotSfnRecord_ul
    logging.info("=====> ul pucchResource nbr_err==%s" % nbr_err)
    # printPartOfSlotSfnRecord(SlotSfnRec_2, onlyKO=True)
