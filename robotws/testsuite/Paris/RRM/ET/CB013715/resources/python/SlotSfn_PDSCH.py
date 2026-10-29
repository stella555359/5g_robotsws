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
import os

from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine, toDecimalStr
import rbg_order
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tools import (
    check_rgbs_set, return_rbgsize_pdsch, cal_num_of_rgb
)

# Get the name of the current Python file
current_file_name = os.path.splitext(os.path.basename(__file__))[0] + '.log'

# Configure logging to write to a file with the name of the current Python file
# logging.basicConfig(level=logging.INFO)
logging.basicConfig(
    filename=current_file_name,  # Name of the log file
    filemode='a',                # Append mode ('w' for overwrite)
    format='%(asctime)s - %(levelname)s - %(message)s',  # Log format
    level=logging.INFO           # Log level
)


def getFieldValue(raw, fieldName):
    return raw[fieldName]

# ======================================================================================


class BitMap:
    def __init__(self, len, ble=0, bhe=0):
        # Ensure parameters are integers
        if not isinstance(len, int):
            raise TypeError("init BitMap Class, Parameters 'len' must be integers")
        if not isinstance(len, int) or not isinstance(ble, int) or not isinstance(bhe, int):
            raise TypeError("Parameters 'len', 'ble', and 'bhe' must be integers")
        self.len = len
        self.map = list("{}{}{}".format("1" * ble, "0" * (len - ble - bhe), "1" * bhe))
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

    def setRangeFromRat0bitmap(self, rat0bitmap, num_of_rbg, RbgSize, latest_rbgsize=1):
        """rat0bitmap is a RBG_Map"""
        rbgmap_bitmap_list = list(rat0bitmap)[:num_of_rbg]
        # logging.info("=====> rbgmap_bitmap_list=%s" % rbgmap_bitmap_list)
        for index in range(len(rbgmap_bitmap_list)):
            if int(rbgmap_bitmap_list[index]) == 1 and index < (num_of_rbg-1):
                start = index*RbgSize
                len_Rbg = RbgSize
                # logging.info("=====> start=%s" % start)
                # logging.info("=====> len_Rbg=%s" % len_Rbg)
                for index_prb in range(start, start + len_Rbg):
                    self.setBit(index_prb)
            elif int(rbgmap_bitmap_list[index]) == 1 and index == (num_of_rbg-1):
                start = index * RbgSize
                len_Rbg = latest_rbgsize
                # logging.info("=====> start=%s" % start)
                # logging.info("=====> len_Rbg=%s" % len_Rbg)
                for index_prb in range(start, start + len_Rbg):
                    self.setBit(index_prb)

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

    def __init__(self, raw, prbMax, ble, bhe, pattern_3gpp):
        pattern_slot = pattern_3gpp + "slot"
        pattern_sfn = pattern_3gpp + "sfn"
        self.slot = getFieldValue(raw, pattern_slot)
        self.sfn = getFieldValue(raw, pattern_sfn)
        self.rntiList = []
        self.bitMap = BitMap(prbMax, ble, bhe)

    def addRnti(self, raw, pattern, pattern_3gpp, chBW=273):
        rnti = RntiPrb(raw, pattern, pattern_3gpp, chBW=chBW)
        if rnti.isValid():
            self.rntiList.append(rnti)
            if rnti.is_contiguous_rbg_used:
                self.bitMap.setRange(start=rnti.startPrb, len=rnti.numOfPrb)
            else:
                self.bitMap.setRangeFromRat0bitmap(rat0bitmap=rnti.rat0Bitmap_b,
                                                   num_of_rbg=rnti.num_of_rbg,
                                                   RbgSize=rnti.RbgSize,
                                                   latest_rbgsize=rnti.latest_rbgsize)

    def __eq__(self, record):
        return self.slot == record.slot and self.sfn == record.sfn

    def __str__(self):
        return "SLOT={} SFN={} RNTI:{} Check:{} Errors:{}".\
            format(self.slot, self.sfn, len(self.rntiList), self.bitMap.isOK(), self.bitMap.getErrors())

    def isMatchingLastRec(rec):
        if len(SlotSfnRec.SlotSfnList) == 0:
            return None
        lastRec = SlotSfnRec.SlotSfnList[-1]
        if rec == lastRec:
            return lastRec
        return None

    def printRec(self, onlyKO):
        if not self.bitMap.isOK() or not onlyKO:
            datedConsole(self)
            for idx, rnti in enumerate(self.rntiList):
                datedConsole("   {}:{}".format(idx+1, rnti))

    def printBitmap(self, onlyKO):
        if not self.bitMap.isOK() or not onlyKO:
            datedConsole(self.bitMap)
            for idx, rnti in enumerate(self.rntiList):
                datedConsole("   {}:{}".format(idx + 1, rnti))

    def printRat0Bitmap(self, onlyKO):
        for idx, rnti in enumerate(self.rntiList):
            if not self.rntiList[idx].isOK() or not onlyKO:
                datedConsole(self.rntiList[idx].rat0Bitmap_b)
                datedConsole("   {}:{}".format(idx + 1, rnti))

# =======================================================================================


class RntiPrb(object):
    def __init__(self, raw, pattern, pattern_3gpp, chBW=273):
        self.raw = raw
        pattern_rnti = pattern_3gpp + 'rnti'
        self.rnti = getFieldValue(raw, pattern_rnti)
        if self.rnti is None or not self.rnti or self.rnti == '65535' or self.rnti == '15':
            self.rnti = '0xFFFF'
            return
        pattern_start_prb = pattern + ".startPrb"
        pattern_num_prb = pattern + ".numOfPrb"
        pattern_rat0Bitmap = pattern + ".rat0Bitmap"
        self.startPrb = int(float(toDecimalStr(getFieldValue(raw, pattern_start_prb))))
        self.numOfPrb = int(float(toDecimalStr(getFieldValue(raw, pattern_num_prb))))
        self.rat0Bitmap = int(float(toDecimalStr(getFieldValue(raw, pattern_rat0Bitmap))))
        self.errors = []
        # self.rat0Bitmap_b = bin(self.rat0Bitmap).replace("0b", "")
        if pattern_3gpp:
            # L1L2 pcap case
            self.rat0Bitmap_b = "{:032b}".format(self.rat0Bitmap)
            pattern_rbgSize = pattern + ".rbgSize"
            self.rbgSize = int(float(toDecimalStr(getFieldValue(raw, pattern_rbgSize))))
            # if self.rbgSize == 8:
            #     chBW_bwp = 106
            # else:
            #     chBW_bwp = chBW
            chBW_bwp = chBW
            self.rgbs_set = check_rgbs_set(self.rat0Bitmap, chBW_bwp, filetype='pcap')
            if not self.rgbs_set and self.rat0Bitmap != 0:
                self.errors.append("Allocated rbgs Id {} from rgb bitmap should not be empty!!!".format(self.rgbs_set))
        else:
            # TtiTraces case
            # rat0BitMap coded with 18bits (BW=273)
            if chBW == 273:
                self.rat0Bitmap_b = "{:018b}".format(self.rat0Bitmap)
            elif chBW == 52:
                self.rat0Bitmap_b = "{:013b}".format(self.rat0Bitmap)
            elif chBW == 79:
                self.rat0Bitmap_b = "{:010b}".format(self.rat0Bitmap)
            elif chBW == 106:
                self.rat0Bitmap_b = "{:014b}".format(self.rat0Bitmap)
            else:
                self.rat0Bitmap_b = "{:014b}".format(self.rat0Bitmap)
            # if self.rbgSize == 8:
            #    chBW_bwp = 106
            # else:
            #    chBW_bwp = chBW
            # self.rgbs_set = check_rgbs_set(self.rat0Bitmap, chBW_bwp, filetype='TtiTraces')
        # in case of BW=273, 18 RBG with RBGSize=16Prb + LastRBG=1Prb
        # in case of BW=106, 13 RBG with RBGSize=8Prb + LastRBG=2Prb
        self.rbg_order = rbg_order.rbg_order()
        self.is_contiguous_rbg_used = self.rbg_order.is_contiguous_rbg_used(self.rat0Bitmap)
        self.RbgSize, self.latest_rbgsize = return_rbgsize_pdsch(chBW=chBW, ConfigType=1)
        self.num_of_rbg = len(cal_num_of_rgb(chBW=chBW, ConfigType=1))
        self.is_last_rbg_used = self.rbg_order.is_last_rbg_used(self.rat0Bitmap, self.num_of_rbg)

    def isValid(self):
        return toDecimalStr(self.rnti) != toDecimalStr("0xFFFF") and toDecimalStr(self.rnti) != toDecimalStr("15") and\
            toDecimalStr(self.rnti) != toDecimalStr("65535")

    def isOK(self):
        return len(self.errors) == 0

    def getErrors(self):
        str = ""
        for error in self.errors:
            str = str + "{}\n".format(error)
        return str

    def __str__(self):
        str = "{}".format(self.raw)
        msg = "PCK:{:30} RNTI:{} StartPRB:{:3} NumOfPrb:{:3} rat0Bitmap_b:{} is_contiguous_rbg_used:{}"
        msg = msg + " is_last_rbg_used:{} latest_rbgsize:{} Check:{} Errors:{}"
        return msg.format(str, self.rnti, self.startPrb, self.numOfPrb, self.rat0Bitmap_b, self.is_contiguous_rbg_used,
                          self.is_last_rbg_used, self.latest_rbgsize, self.isOK(), self.getErrors())

# =======================================================================================


def createSlotSfnRecords(csvfile, prbMax, ble, bhe, pattern, pattern_3gpp='', chBW=273, verbose=True):
    SlotSfnRec.SlotSfnList = []
    with io.open(csvfile, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile,  delimiter=';')
        for row in reader:
            # print(row)
            rec = SlotSfnRec(row, prbMax, ble, bhe, pattern_3gpp)
            lastRec = SlotSfnRec.isMatchingLastRec(rec)
            if lastRec is not None:
                lastRec.addRnti(row, pattern, pattern_3gpp, chBW=chBW)
            else:
                rec.addRnti(row, pattern, pattern_3gpp, chBW=chBW)
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
        if not rec.bitMap.isOK():
            nbError = nbError + 1
    return nbError


def countRat0BitmapInconsistency(SlotSfnRec) -> object:
    nbError = 0
    for rec in SlotSfnRec.SlotSfnList:
        for rnti in rec.rntiList:
            if not rnti.isOK():
                nbError = nbError + 1
    return nbError


def printSlotSfnRec(SlotSfnRec, onlyKO):
    for rec in SlotSfnRec.SlotSfnList:
        rec.printRec(onlyKO)
        rec.printBitmap(onlyKO)
        rec.printRat0Bitmap(onlyKO)


def main_test_pcap():
    logging.basicConfig(level=logging.DEBUG)
    path = '/home/ute/csamson/TRACES'
    # csvfile = path + '/pcapprocessed_PRb_Blanking_dldata_pdschsendreq_subcellId0_2024-02-23-17_09_36.339.csv'
    csvfile = path + '/pcapprocessed_PRB_Blanking_dldata_pdschsendreq_subcellId1.csv'
    # csvfile = path + '/pcapprocessed_PRb_Blanking_dldata_pdschsendreq_subcellId0_Try.csv'
    SlotSfnRec = createSlotSfnRecords(csvfile=csvfile, prbMax=106, ble=0, bhe=2,
                                      pattern='DlData_PdschGrantL1sw', pattern_3gpp='3gpp.', chBW=106)
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec)
    printSlotSfnRec(SlotSfnRec, onlyKO=True)
    countSlotSfnRecord_dl = countSlotSfnRecord(SlotSfnRec)
    logging.info("=====> dl countSlotSfnRecord==%s" % countSlotSfnRecord_dl)
    countPrbInconsistency_dl = countPrbInconsistency(SlotSfnRec)
    nbr_err = float(countPrbInconsistency_dl / countSlotSfnRecord_dl)
    logging.info("=====> dl nbr_err==%s" % nbr_err)
    countRat0BitmapInconsistency_dl = countRat0BitmapInconsistency(SlotSfnRec)
    logging.info("=====> dl countRat0BitmapInconsistency_dl==%s" % countRat0BitmapInconsistency_dl)
    nbr_err_rat0bitmap = float(countRat0BitmapInconsistency_dl / countSlotSfnRecord_dl)
    logging.info("=====> dl nbr_err_rat0bitmap==%s" % nbr_err_rat0bitmap)

    # printPartOfSlotSfnRecord(SlotSfnRec, onlyKO=True)

    # csvfile = '/home/ute/csamson/TRACES/csv/pcapprocessed_PRb_Blanking_dldata_pdschsendreq_subcellId1.csv'
    # SlotSfnRec2 = createSlotSfnRecords(csvfile=csvfile, prbMax=273, ble=25, bhe=20,
    #                                    pattern='DlData_PdschGrant', pattern_3gpp='3gpp.')
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec2)
    # printSlotSfnRec(SlotSfnRec2, onlyKO=True)
    # countSlotSfnRecord_ul = countSlotSfnRecord(SlotSfnRec2)
    # logging.info("=====> ul countSlotSfnRecord_ul==%s" % countSlotSfnRecord_ul)
    # countPrbInconsistency_ul = countPrbInconsistency(SlotSfnRec2)
    # nbr_err = countPrbInconsistency_ul / countSlotSfnRecord_ul
    # logging.info("=====> ul nbr_err==%s" % nbr_err)
    # printPartOfSlotSfnRecord(SlotSfnRec2, onlyKO=True)


def main_test_tti():
    logger_tti = logging.getLogger('main_test_tti')
    logger_tti.setLevel(logging.INFO)
    path = '/home/ute/csamson/TRACES'
    csvfile = path + '/dl_dataframe_for_manual_analysis_prblanking_cell1.csv'
    SlotSfnRec = createSlotSfnRecords(csvfile=csvfile, prbMax=79, ble=13, bhe=0, pattern='dlFdSchedData', chBW=79)
    # logger_tti.info("=====> SlotSfnRec==%s" % SlotSfnRec)
    printSlotSfnRec(SlotSfnRec, onlyKO=True)
    countSlotSfnRecord_dl = countSlotSfnRecord(SlotSfnRec)
    logger_tti.info("=====> dl countSlotSfnRecord==%s" % countSlotSfnRecord_dl)
    # print("=====> dl countSlotSfnRecord==%s" % countSlotSfnRecord_dl)
    countPrbInconsistency_dl = countPrbInconsistency(SlotSfnRec)
    nbr_err_percent: float = float(countPrbInconsistency_dl / countSlotSfnRecord_dl)*100
    logger_tti.info("=====> dl nbr_err==%s" % countPrbInconsistency_dl)
    logger_tti.info("=====> dl nbr_err percent==%s%%" % nbr_err_percent)
    # print("=====> dl nbr_err==%s" % countPrbInconsistency_dl)
    countRat0BitmapInconsistency_dl = countRat0BitmapInconsistency(SlotSfnRec)
    logger_tti.info("=====> dl countRat0BitmapInconsistency_dl==%s" % countRat0BitmapInconsistency_dl)
    # print("=====> dl countRat0BitmapInconsistency_dl==%s" % countRat0BitmapInconsistency_dl)
    nbr_err_rat0bitmap = float(countRat0BitmapInconsistency_dl / countSlotSfnRecord_dl)
    logger_tti.info("=====> dl nbr_err_rat0bitmap==%s" % nbr_err_rat0bitmap)
    # print("=====> dl nbr_err_rat0bitmap==%s" % nbr_err_rat0bitmap)

    # printPartOfSlotSfnRecord(SlotSfnRec, onlyKO=True)


if __name__ == "__main__":
    # main_test_tti()
    main_test_pcap()
