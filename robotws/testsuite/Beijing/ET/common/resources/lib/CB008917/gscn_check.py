# -*- coding: utf-8 -*-
"""
2022/07/07 first version by @author: xiang.5.li@nokia-sbell.com
2022/07/07 GSCN checker for feature CB008917

"""

import copy
import math
import os


try:
    from testsuite.Beijing.ET.common.resources.lib.logger_et import LoggingEt
    from testsuite.Beijing.ET.common.resources.lib.xml_file import ReadGnbScf
    from testsuite.Beijing.ET.common.resources.lib.egate_file import ReadEgateByMessage, ParserEgate
    from testsuite.Beijing.ET.common.resources.lib.exception_et import RaiseExceptionEt
    from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
    from testsuite.Beijing.ET.common.resources.lib.text_file import ReadPcapMessage
except Exception:
    from .logger_et import LoggingEt
    from .xml_file import ReadGnbScf
    from .egate_file import ReadEgateByMessage, ParserEgate
    from .exception_et import RaiseExceptionEt
    from info_parser import InfoParser
    from .text_file import ReadPcapMessage
LoggingEt.log.handlers = []


class TdraChecker(object):
    def __init__(self, log_path='', scf_file='', egate_file='', x2_file=''):
        self.log_path = log_path
        self.scf_file = scf_file
        self.egate_file = egate_file
        self.x2_file = x2_file
        __logger_name = os.path.basename(__file__)
        self.log = LoggingEt(self.log_path, __logger_name).log()
        self.raise_exception = RaiseExceptionEt(self.log_path)

        self.arfcn_raster_list = [5, 15, 60]
        self.gscn_raster_list = [1200, 1440, 17280]
        self.fre_range_index = None

        self.scf_nrccell = []
        self.egate_rrc_cfg = []
        self.x2_info = []
        self.cell_total_info = {}

        self.nr_arfcn_dl = 0
        self.scs_ref = 0
        self.arfcn_raster = 0
        self.gscn_raster = 0
        self.scs_common = 0
        self.scs_ssb = 0
        self.n_rb_bandwidth = 0
        self.point_a_report = 0
        self.point_a_calc = 0
        self.min_cell_arfcn = 0
        self.max_cell_arfcn = 0
        self.min_bwp_arfcn = 0
        self.max_bwp_arfcn = 0
        self.rb_start, self.rb_lens = 0, 0
        self.gscn_or_sspbch_arfcn = None

        # auto gscn related parameters
        self.min_arfcn_gscn = 0
        self.max_arfcn_gscn = 0
        self.mid_arfcn_gscn = 0
        self.input_arfcn = 0
        self.gscn_arfcn = 0
        self.step = 0
        self.step_sqrt = 0
        self.step_sqrt_floor = 0
        self.gscn_calc = 0
        self.low_ss_pbch_arfcn = 0
        self.ss_block_prb_offset = 0
        self.ss_block_subcarrier_offset = 0
        self.Kssb = 0

        self.ok_cnt = 0
        self.error_cnt = 0

    def get_scf_parameters(self):
        """
        find the cell info from cell 1 to cell 9, if not enouth adjust the range.
        :return:
        """
        for i in range(1, 10):
            managedObject_distName = "MRBTS-1/NRBTS-1/NRCELL-" + str(i)
            paras = ["nrarfcn", "ssbScs", "cellDepType", "gscnOrSsPbchArfcn", "physCellId", "actSpecificBwpSize"]
            scf_obj = ReadGnbScf(self.log_path, self.scf_file, managedObject_distName, paras)
            cell_result = scf_obj.parser_scf_by_managed()
            # self.log.info("scf info for distname:%s, result:%s" % (managedObject_distName, cell_result))
            managedObject_distName = "MRBTS-1/NRBTS-1/NRCELL-%s/NRCELL_FDD-1" % str(i)
            paras = ["nrarfcnDl"]
            scf_obj = ReadGnbScf(self.log_path, self.scf_file, managedObject_distName, paras)
            fdd_cell_result = scf_obj.parser_scf_by_managed()
            if fdd_cell_result:
                cell_result.update(fdd_cell_result)
            if cell_result:
                self.scf_nrccell.append(cell_result)
        self.log.info("scf info: %s" % self.scf_nrccell)

    def get_egate_parameters(self):
        message_anchor_paras = {
            "value BCCH-DL-SCH-Message ::=":
                {"frequencyInfoDL": ["freqBandIndicatorNR", "offsetToPointA",
                                     "subcarrierSpacing##dl", "carrierBandwidth"],
                 "sib4": ["ssbSubcarrierSpacing"]
                 },
            "BCCH-BCH-Message ::=":
                {
                    "message mib": ['subCarrierSpacingCommon', "ssb-SubcarrierOffset"]
                },
            "DL-CCCH-Message ::=":
                {
                    "downlinkBWP-ToAddModList": ["locationAndBandwidth", "subcarrierSpacing##bwp"]
                },
            "RRCReconfiguration ::=":  # TDD
                {
                    "downlinkConfigCommon": ["absoluteFrequencyPointA", "absoluteFrequencySSB"],
                    "spCellConfigCommon": ['physCellId']
                },
            "DL-DCCH-Message ::=":
                {
                    "measObject measObjectNR": ["ssbFrequency", "freqBandIndicatorNR"]

                },
            "X2AP-PDU ::= initiatingMessage":
                {
                    "protocolIEs": ["meNBtoSgNBContainer"]
                }
        }
        egate_obj = ParserEgate(log_path=self.log_path, egateFile=self.egate_file,
                                message_anchor_paras=message_anchor_paras)
        self.egate_rrc_cfg = egate_obj.parser_egate()
        self.log.info("self.egate_rrc_cfg:%s" % (self.egate_rrc_cfg))

    def get_x2_parameters(self):
        message_anchor_paras = {
            "SgNBAdditionRequestAcknowledge": {
                "nzp-CSI-RS-ResourceToAddModList":
                    ["nzp-CSI-RS-ResourceId", "firstOFDMSymbolInTimeDomain", "periodicityAndOffset"],
                "pdsch-ConfigCommon: setup (1)": ["startSymbolAndLength##common"], "pdsch-Config: setup (1)": [
                    'startSymbolAndLength##dedicate']
            }
        }
        if self.x2_file:
            self.x2_parser = ReadPcapMessage(self.log_path, self.x2_file, message_anchor_paras)
        self.x2ap_info = self.x2_parser.parser_pcap_file()
        self.log.info("x2 pcap:%s" % self.x2ap_info)

    def arfcn2fre(self, n_ref):
        """
        convert arfcn to frequency.
        :param n_ref: unit:kHz
        :return:
        """
        delta_f_global = [5, 15, 60]  # kHz
        f_ref_offs = [0, 3000000, 24250080]  # kHz
        n_ref_offs = [0, 600000, 2016667]
        f_ref = None
        if 0 <= n_ref <= 599999:
            gscn_index = 0
        elif 600000 <= n_ref <= 2016666:
            gscn_index = 1
        elif n_ref <= 3279165:
            gscn_index = 2
        else:
            gscn_index = None
            self.raise_exception.case_invalid("The arfcn not in range 0 - 3279165")
        if gscn_index in [0, 1, 2]:
            f_ref = f_ref_offs[gscn_index] + delta_f_global[gscn_index] * (n_ref - n_ref_offs[gscn_index])
        return f_ref, gscn_index

    def freq2gscn(self, fre):
        """
        convert the frequency to gscn value.
        :param fre: unit: kHz
        :return:
        """
        gscn_calc = 0
        if 0 <= fre <= 3000000:
            n = int(fre / 1200)
            m = int((fre % 1200) / 50)
            gscn_calc = 3 * n + (m - 3) / 2
        elif 3000000 <= fre <= 24250000:
            n = int((fre - 3000000) / 1440)
            gscn_calc = 7499 + n
        elif 24250000 <= fre <= 100000000:
            n = int((fre - 24250080) / 17280)
            gscn_calc = 22256 + n
        if gscn_calc == 0:
            self.log.error("GSCN calc ERROR, frequency range 0-100000000 and unit kHz, input frequency:%s" % fre)
        return gscn_calc

    def gscn2freq(self, gscn):
        gscn = int(gscn)
        if 2 < gscn < 7498:
            n = int(gscn / 3)
            m = (gscn % 3)
            if m == 2:
                n = n + 1
                m = 1

    def freq2gscn_auto_freq_range1(self):
        """
        convert the frequency to gscn list
        when scf config gscnOrSsPbchArfcn=0, if N is decimal，round up a integer.
        when scf config gscnOrSsPbchArfcn=1, 2, if N is decimal，round down a integer.
        """
        gscn_arfcn_offset = 0  # gscnArfcnOffset
        m_lst = [1, 3, 5]
        self.gscn_calc = 0
        fre = 0
        for m in m_lst:
            if self.gscn_or_sspbch_arfcn in ["0", 0]:
                fre = self.arfcn2fre(self.min_arfcn_gscn)[0]
                n = float(fre - m * 50) / 1200
                n_floor = math.floor(n / self.step_sqrt)
                n_ceil_equal = self.step_sqrt_floor * (n_floor + math.ceil((n - self.step_sqrt_floor * n_floor)
                                                                           / self.step_sqrt_floor))
                n_ceil_not_equal = self.step_sqrt_floor * n_floor
                n_tmp = n_ceil_equal
                self.log.info("self.min_arfcn_gscn:%s, fre:%s, N:%s, n_floor:%s, n_ceil_equal:%s" %
                              (self.min_arfcn_gscn, fre, n, n_floor, n_ceil_equal))
                gscn_arfcn_tmp = (m * 50 + n_tmp * self.gscn_raster) / self.arfcn_raster
                self.log.info("gscn_arfcn_tmp:%s, self.point_a_calc:%s" % (gscn_arfcn_tmp, self.point_a_calc))
                if (gscn_arfcn_tmp - self.point_a_calc) % 3 == 0:
                    self.gscn_calc = int(n_tmp * 3 + (m - 3) / 2)
                    self.gscn_arfcn = int((n_tmp * self.gscn_raster + m * 50) / self.arfcn_raster + gscn_arfcn_offset)
                    break
            else:
                fre = self.arfcn2fre(self.mid_arfcn_gscn)[0] \
                    if self.gscn_or_sspbch_arfcn in ["1", 1] else self.arfcn2fre(self.max_arfcn_gscn)[0]
                n = float(fre - m * 50) / 1200
                n_floor = math.floor(n / self.step_sqrt)
                n_ceil_equal = self.step_sqrt_floor * (n_floor + math.ceil((n - self.step_sqrt_floor * n_floor)
                                                                           / self.step_sqrt_floor))
                n_ceil_not_equal = self.step_sqrt_floor * n_floor
                n_tmp = n_ceil_not_equal
                gscn_arfcn_tmp = (m * 50 + n_tmp * self.gscn_raster) / self.arfcn_raster
                if (gscn_arfcn_tmp - self.point_a_calc) % 3 == 0:
                    self.gscn_calc = int(n_tmp * 3 + (m - 3) / 2)
                    self.gscn_arfcn = int((n_tmp * self.gscn_raster + m * 50) / self.arfcn_raster + gscn_arfcn_offset)
                    break
        if self.gscn_calc == 0:
            self.log.error("Auto: GSCN calc ERROR, frequency range 0-3000000 and unit kHz, input frequency:%s" % fre)
        self.log.info("gscn calc:%s, gscn arfcn:%s" % (self.gscn_calc, self.gscn_arfcn))

    def freq2gscn_auto_freq_range_2and3(self):
        self.gscn_calc = 0
        fre = 0
        if self.gscn_or_sspbch_arfcn in ["0", 0]:
            fre = self.arfcn2fre(self.min_arfcn_gscn)[0]
        elif self.gscn_or_sspbch_arfcn in ["1", 1]:
            fre = self.arfcn2fre(self.mid_arfcn_gscn)[0]
        elif self.gscn_or_sspbch_arfcn in ["2", 2]:
            fre = self.arfcn2fre(self.max_arfcn_gscn)[0]
        if 3000000 <= fre <= 24250000:
            gscn_arfcn_offset = 600000  # gscnArfcnOffset
            # round down
            n = math.floor((fre - 3000000) / 1440)
            if self.gscn_or_sspbch_arfcn in ["0", 0]:
                # round up
                n = math.ceil((fre - 3000000) / 1440)
            self.gscn_calc = int(7499 + n)
            self.gscn_arfcn = int(((3000000 + n * 1440) - 3000000) / self.arfcn_raster + gscn_arfcn_offset)
        elif 24250000 <= fre <= 100000000:
            gscn_arfcn_offset = 2016667  # gscnArfcnOffset
            # round down
            n = math.floor((fre - 24250080) / 17280)
            if self.gscn_or_sspbch_arfcn in ["0", 0]:
                # round up
                n = math.ceil((fre - 24250080) / 17280)
            self.gscn_calc = int(22256 + n)
            self.gscn_arfcn = int(((24250080 + 17280 * n) - 24250080) / self.arfcn_raster + gscn_arfcn_offset)
        if self.gscn_calc == 0:
            self.log.error("Auto: GSCN calc ERROR, frequency range 3000000-100000000 and unit kHz, "
                           "input frequency:%s" % fre)
        self.log.info("gscn calc:%s, gscn arfcn:%s" % (self.gscn_calc, self.gscn_arfcn))

    def decode_LocationAndBandwidth(self, riv):
        bwp_size = 275
        tmp_rb_lens = int(riv / bwp_size)
        tmp = tmp_rb_lens + riv % bwp_size
        rb_lens, rb_start = 0, 0
        if tmp < bwp_size:
            rb_lens = tmp_rb_lens + 1
            rb_start = riv % bwp_size
        else:
            rb_lens = bwp_size - tmp_rb_lens + 1
            rb_start = bwp_size - 1 - (riv % bwp_size)
        return rb_start, rb_lens

    def get_required_info(self, scf_cell_info):
        self.cell_total_info = copy.deepcopy(scf_cell_info)
        for egate_info in self.egate_rrc_cfg:
            if egate_info['msg_type'] == "cell_info" and scf_cell_info['physCellId'] == egate_info['pci']:
                # update info from cell info of egate console log.
                for item in ['enb_id', 'cell_id', 'dl_fre', 'technology']:
                    self.cell_total_info[item] = egate_info[item]
            # update info from mib info of egate console log.
            elif egate_info['msg_type'] == "mib" and egate_info['technology'] == 'nr':
                if "enb_id" in self.cell_total_info and self.cell_total_info['enb_id'] == egate_info['enb_id'] and \
                        "cell_id" in self.cell_total_info and self.cell_total_info['cell_id'] == egate_info['cell_id']:
                    for item in ['subCarrierSpacingCommon', "ssb-SubcarrierOffset"]:
                        self.cell_total_info[item] = egate_info[item]
            # update info from sib1
            elif egate_info['msg_type'] == "systemInformationBlockType1":
                if "enb_id" in self.cell_total_info and self.cell_total_info['enb_id'] == egate_info['enb_id'] and \
                        "cell_id" in self.cell_total_info and self.cell_total_info['cell_id'] == egate_info['cell_id']:
                    for item in ['freqBandIndicatorNR', "offsetToPointA", "subcarrierSpacing##dl", "carrierBandwidth"]:
                        self.cell_total_info[item] = egate_info[item]
            # update ssbSubcarrierSpacing from system info(sib4)
            elif egate_info['msg_type'] == "systemInformation":
                if "enb_id" in self.cell_total_info and self.cell_total_info['enb_id'] == egate_info['enb_id'] and \
                        "cell_id" in self.cell_total_info and self.cell_total_info['cell_id'] == egate_info['cell_id']:
                    self.cell_total_info["ssbSubcarrierSpacing"] = egate_info["ssbSubcarrierSpacing"]
            # update info from rrc setup
            elif egate_info['msg_type'] == "rrcSetup":
                if "physCellId" in self.cell_total_info and \
                        self.cell_total_info['physCellId'] == egate_info['pciId']:
                    for item in ["subcarrierSpacing##bwp", "locationAndBandwidth", "pciId"]:
                        self.cell_total_info[item] = egate_info[item]
            # update absoluteFrequencyPointA if rrcReconfiguration exist.
            elif egate_info['msg_type'] == "rrcReconfiguration":
                if "physCellId" in self.cell_total_info and \
                        self.cell_total_info['physCellId'] == egate_info['pciId']:
                    for item in ["ssbFrequency", "pciId", "absoluteFrequencySSB", "absoluteFrequencyPointA"]:
                        try:
                            self.cell_total_info[item] = egate_info[item]
                        except Exception:
                            pass
        self.log.info("prepare to check cells info: %s" % self.cell_total_info)

    def calc_basic_config(self):
        arfcn_range_index = 0
        if "nrarfcn" in self.cell_total_info:
            self.nr_arfcn_dl = int(self.cell_total_info["nrarfcn"])
            arfcn_range_index = 0 if self.nr_arfcn_dl <= 599999 else 2 if self.nr_arfcn_dl >= 2016667 else 1
        elif "nrarfcnDl" in self.cell_total_info:
            self.nr_arfcn_dl = int(self.cell_total_info["nrarfcnDl"])
            arfcn_range_index = 0 if self.nr_arfcn_dl <= 599999 else 2 if self.nr_arfcn_dl >= 2016667 else 1
        self.scs_ref = 15 if float(self.cell_total_info['dl_fre']) <= 60000 else 60
        self.arfcn_raster = self.arfcn_raster_list[arfcn_range_index]
        self.gscn_raster = self.gscn_raster_list[arfcn_range_index]
        self.scs_common = int(self.cell_total_info['subcarrierSpacing##dl'][3:])
        self.scs_ssb = int(self.cell_total_info['ssbSubcarrierSpacing'][3:])
        self.n_rb_bandwidth = int(self.cell_total_info['carrierBandwidth'])
        self.point_a_report = int(self.cell_total_info['absoluteFrequencyPointA']) \
            if "absoluteFrequencyPointA" in self.cell_total_info else 0
        self.log.info("self.nr_arfcn_dl:%s, self.scs_ref:%s, self.arfcn_raster:%s, self.gscn_raster:%s, "
                      "self.scs_common:%s, self.scs_ssb:%s, self.n_rb_bandwidth:%s, self.point_a_report:%s" %
                      (self.nr_arfcn_dl, self.scs_ref, self.arfcn_raster, self.gscn_raster,
                       self.scs_common, self.scs_ssb, self.n_rb_bandwidth, self.point_a_report))

    def calc_absolute_fre_point_a(self):
        self.point_a_calc = int(self.nr_arfcn_dl - (self.n_rb_bandwidth * 12 / 2) * self.scs_common / self.arfcn_raster)
        # self.log.info("cell: %s, calc point a: %s" % (self.cell_total_info['cell_id'], self.point_a_calc))
        self.log.info("calc absoluteFrequencyPointA:%s" % (self.point_a_calc))
        if self.point_a_report != 0:
            if self.point_a_calc != self.point_a_report:
                self.error_cnt += 1
                self.log.error("The absoluteFrequencyPointA is not match! report:%s, calc:%s" %
                               (self.point_a_report, self.point_a_calc))
            else:
                self.ok_cnt += 1

    def calc_min_max_cell_arfcn(self):
        if self.point_a_calc != 0:
            self.min_cell_arfcn = self.point_a_calc
        self.max_cell_arfcn = int(self.nr_arfcn_dl +
                                  (self.n_rb_bandwidth * 12 / 2) * self.scs_common / self.arfcn_raster)
        self.log.info("minCellArfcn:%s, maxCellArfcn:%s" % (self.min_cell_arfcn, self.max_cell_arfcn))

    def calc_riv_s_l(self):
        riv = self.cell_total_info['locationAndBandwidth']
        self.rb_start, self.rb_lens = self.decode_LocationAndBandwidth(int(riv))
        self.log.info("locationAndBandwidth->s:%s, l:%s" % (self.rb_start, self.rb_lens))

    def calc_min_max_bwp_arfcn(self):
        # print("rb", self.n_rb_bandwidth)
        self.min_bwp_arfcn = self.nr_arfcn_dl + \
                             (self.rb_start * 12 - 6 * self.n_rb_bandwidth) * (self.scs_common / self.arfcn_raster)
        self.max_bwp_arfcn = self.min_bwp_arfcn + self.rb_lens * 12 * self.scs_common / self.arfcn_raster
        self.log.info("minBWPArfcn:%s, maxBWPArfcn:%s" % (self.min_bwp_arfcn, self.max_bwp_arfcn))

    def compare_gscn_manual_mode(self, scf_cell_info):
        absolute_fre_ssb = self.cell_total_info['ssbFrequency']
        ssb_fre = self.arfcn2fre(int(absolute_fre_ssb))
        gscn_calc = self.freq2gscn(ssb_fre[0])
        gscn_scf = scf_cell_info['gscnOrSsPbchArfcn']
        if int(gscn_calc) != int(gscn_scf):
            self.error_cnt += 1
            self.log.error("The gscn not match between scf and rrc info! scf: %s, rrcSetup: %s" % (gscn_scf, gscn_calc))
        else:
            self.ok_cnt += 1

    def calc_gscn_auto_relate_paras(self):
        self.min_arfcn_gscn = self.min_bwp_arfcn + 120 * self.scs_ssb / self.arfcn_raster
        self.max_arfcn_gscn = self.max_bwp_arfcn - 120 * self.scs_ssb / self.arfcn_raster
        self.mid_arfcn_gscn = math.floor((self.min_bwp_arfcn + self.max_bwp_arfcn) / 2)
        # self.mid_arfcn_gscn = int(self.cell_total_info['nrarfcnDl'])
        self.input_arfcn = [self.min_arfcn_gscn, self.mid_arfcn_gscn, self.max_arfcn_gscn][
            int(self.gscn_or_sspbch_arfcn)]
        self.step = 3 if self.cell_total_info['freqBandIndicatorNR'] in [41, "41"] else 1
        self.step_sqrt = math.sqrt(self.step)
        self.step_sqrt_floor = math.floor(self.step_sqrt)
        self.log.info("min GSCN arfcn:%s, mid GSCN arfcn:%s, max GSCN arfcn:%s, input_arfcn:%s, step:%s, step sqrt:%s, "
                      "step sqrt floor:%s" % (self.min_arfcn_gscn, self.mid_arfcn_gscn, self.max_arfcn_gscn,
                                              self.input_arfcn, self.step, self.step_sqrt, self.step_sqrt_floor))

    def calc_gscn_auto(self):
        dl_freq = float(self.cell_total_info['dl_fre'])
        if dl_freq < 3000:
            self.freq2gscn_auto_freq_range1()
        elif dl_freq > 3000:
            self.freq2gscn_auto_freq_range_2and3()

    def compare_gscn_auto_mode(self, scf_cell_info):
        """
        compare:
        ssBlockPrbOffset -> egate console sib1:offsetToPointA
        ssBlockSubcarrierOffset -> egate console mib:ssb-SubcarrierOffset
        :param scf_cell_info:
        :return:
        """
        # self.calc_gscn_auto()
        self.low_ss_pbch_arfcn = self.gscn_arfcn - (120 * self.scs_ssb / self.arfcn_raster)
        self.log.info("self.low_ss_pbch_arfcn:%s, self.min_cell_arfcn:%s" %
                      (self.low_ss_pbch_arfcn, self.min_cell_arfcn))
        # print(self.low_ss_pbch_arfcn, self.min_cell_arfcn, self.arfcn_raster, self.scs_common)
        # step1 = (self.low_ss_pbch_arfcn - self.min_cell_arfcn) * self.arfcn_raster
        # self.log.info("step1:%s" % step1)
        # step2 = (self.low_ss_pbch_arfcn - self.min_cell_arfcn) * self.arfcn_raster / (12 * self.scs_common)
        # self.log.info("step2: %s" % step2)
        # step3 = ((self.low_ss_pbch_arfcn - self.min_cell_arfcn) * self.arfcn_raster / self.scs_common)
        # self.log.info("step3:%s" % step3)
        self.ss_block_prb_offset = math.floor((self.low_ss_pbch_arfcn - self.min_cell_arfcn) *
                                              self.arfcn_raster / (12 * self.scs_common))
        offset_to_point_a_calc = self.ss_block_prb_offset * (self.scs_common / self.scs_ref)
        self.ss_block_subcarrier_offset = ((self.low_ss_pbch_arfcn - self.min_cell_arfcn) *
                                           self.arfcn_raster / self.scs_common) % 12
        if self.scs_ssb in [15, 30, '15', '30']:
            self.Kssb = self.ss_block_subcarrier_offset * self.scs_common / self.scs_ref
        else:
            self.Kssb = self.ss_block_subcarrier_offset
        # print("scs common:%s" % self.scs_common, self.arfcn_raster)
        offset_to_point_a = int(self.cell_total_info['offsetToPointA'])
        self.log.info("self.ss_block_prb_offset:%s, offsetToPointA calc:%s, offsetToPointA report:%s" %
                      (self.ss_block_prb_offset, offset_to_point_a_calc, offset_to_point_a))
        ssb_subcarrier_offset = int(self.cell_total_info["ssb-SubcarrierOffset"])
        self.log.info("lowSsPbchArfcn:%s, ssBlockSubcarrierOffset:%s, Kssb calc:%s, Kssb report:%s" %
                      (self.low_ss_pbch_arfcn, self.ss_block_subcarrier_offset, self.Kssb, ssb_subcarrier_offset))
        if int(offset_to_point_a_calc) == offset_to_point_a and int(self.Kssb) == ssb_subcarrier_offset:
            self.ok_cnt += 1
        else:
            self.error_cnt += 1
            self.log.error("ssBlockPrbOffset(calc:%s, report:%s) or ssBlockSubcarrierOffset(calc:%s, report:%s) "
                           "calc and report not same!" % (offset_to_point_a_calc, offset_to_point_a,
                                                          self.Kssb, ssb_subcarrier_offset))

    def gscn_checker(self):
        self.get_scf_parameters()
        if self.x2_file:
            self.get_x2_parameters()
        elif self.egate_file:
            self.get_egate_parameters()
        else:
            self.raise_exception.case_invalid("No egate or x2 log!")
        for scf_cell_info in self.scf_nrccell:
            self.log.info("PCI: %s".center(80, "=") % (scf_cell_info['physCellId']))
            if scf_cell_info['actSpecificBwpSize'] == "False":
                self.log.info("actSpecificBwpSize: %s, Feature CB008917 is disable!"
                              % scf_cell_info['actSpecificBwpSize'])
                continue
            self.gscn_or_sspbch_arfcn = scf_cell_info["gscnOrSsPbchArfcn"]
            self.get_required_info(scf_cell_info)
            if "locationAndBandwidth" not in self.cell_total_info:
                continue
            self.calc_basic_config()
            self.calc_absolute_fre_point_a()
            self.calc_min_max_cell_arfcn()
            self.calc_riv_s_l()
            self.calc_min_max_bwp_arfcn()
            # scf config gscnOrSsPbchArfcn >= 3
            if scf_cell_info['gscnOrSsPbchArfcn'] not in ['0', '1', '2', 0, 1, 2]:
                # compare the rrcsetup info ssbFrequency and scf info scnOrSsPbchArfcn
                self.compare_gscn_manual_mode(scf_cell_info)
            else:
                # scf config gscnOrSsPbchArfcn in [0, 1, 2]
                self.calc_gscn_auto_relate_paras()
                self.calc_gscn_auto()
                self.compare_gscn_auto_mode(scf_cell_info)
        self.log.info("ok count:%s, error count:%s" % (self.ok_cnt, self.error_cnt))
        if self.ok_cnt >= 1 and self.error_cnt == 0:

            self.raise_exception.case_pass("GSCN check PASS!")
        else:
            self.raise_exception.case_fail("GSCN check Fail!")


def gscn_check_py(log_path='', scf_file='', egate_file='', x2_file=''):
    TdraChecker(log_path=log_path, scf_file=scf_file, egate_file=egate_file, x2_file=x2_file).gscn_checker()


if __name__ == "__main__":
    # log_path = r'C:\work\data\017-Feature\5G\8917\logs\CB008917-B-a_TC049_20220706143725019\CB008917-B-a_TC049'
    # scf_file = r'C:\work\data\017-Feature\5G\8917\logs\CB008917-B-a_TC049_20220706143725019
    # \CB008917-B-a_TC049\SCF_running.xml'
    # egate_file = r'C:\work\data\017-Feature\5G\8917\logs\CB008917-B-a_TC049_20220706143725019
    # \CB008917-B-a_TC049\egate_console.log'
    # log_path = r'C:\work\data\017-Feature\5G\8917\logs\CB008917-A-a_TC002_20220707101418016\CB008917-A-a_TC002'
    # scf_file = r'C:\work\data\017-Feature\5G\8917\logs\CB008917-A-a_TC002_20220707101418016
    # \CB008917-A-a_TC002\SCF_running.xml'
    # egate_file = r'C:\work\data\017-Feature\5G\8917\logs\CB008917-A-a_TC002_20220707101418016\CB008917-A-a_TC002
    # \egate_console.log'
    # log_path = r"C:\work\data\017-Feature\5G\8917\logs\CB008917-B-a_TC049_20220720095321785\CB008917-B-a_TC049"
    # scf_file = (r'C:\work\data\017-Feature\5G\8917\logs\CB008917-B-a_TC049_20220720095321785\CB008917-B-a_TC049'
    #             r'\SCF_running.xml')
    # egate_file = (r'C:\work\data\017-Feature\5G\8917\logs\CB008917-B-a_TC049_20220720095321785\CB008917-B-a_TC049'
    #               r'\egate_console.log')
    # 4ue
    # log_path = r"C:\work\data\017-Feature\5G\8917\logs\type6failed"
    # scf_file = r'C:\work\data\017-Feature\5G\8917\logs\type6failed\SCF_running.xml'
    # egate_file = r'C:\work\data\017-Feature\5G\8917\logs\type6failed\egate_console.log'

    log_path = (r"C:\work\data\017-Feature\5G\8917\CB008917-A-a_TC012.CB008917-A-a_TC012_20220825180304808_0"
                r"\CB008917-A-a_TC012")
    scf_file = (r"C:\work\data\017-Feature\5G\8917\CB008917-A-a_TC012.CB008917-A-a_TC012_20220825180304808_0"
                r"\CB008917-A-a_TC012\SCF_running.xml")
    egate_file = (r"C:\work\data\017-Feature\5G\8917\CB008917-A-a_TC012.CB008917-A-a_TC012_20220825180304808_0"
                  r"\CB008917-A-a_TC012\egate_console.log")

    # log_path = r"C:\work\data\017-Feature\5G\8917\CB008917-A-a_TC012.CB008917-A-a_TC012_20220825111138111
    # \CB008917-A-a_TC012"
    # scf_file = r"C:\work\data\017-Feature\5G\8917\CB008917-A-a_TC012.CB008917-A-a_TC012_20220825111138111
    # \CB008917-A-a_TC012\SCF_running.xml"
    # egate_file = r"C:\work\data\017-Feature\5G\8917\CB008917-A-a_TC012.CB008917-A-a_TC012_20220825111138111
    # \CB008917-A-a_TC012\egate_console.log"

    gscn_check_py(log_path=log_path, scf_file=scf_file, egate_file=egate_file)
