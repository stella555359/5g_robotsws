# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:reference: http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php
"""

import csv
import math
import os
import re
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis import ScfAnalysis
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.variable.table_3gpp import *

__all__ = ['calculate_rbStartCoreset0_tdd', 'calculate_pucchprb_tdd']


def get_value_from_scf(scf_path, cell_id):
    scf_value_dic = {}
    scf_analysis = ScfAnalysis()
    scf_analysis.setup(scf_path=scf_path)
    chbw = scf_analysis.get_band_from_scf(cell_id=cell_id)
    scf_value_dic['chbw'] = int(chbw)
    gscn = scf_analysis.get_gscn_from_scf(cell_id=cell_id)
    scf_value_dic['gscn'] = int(gscn)
    cellArfcn = scf_analysis.get_nrarfcn_from_scf(cell_id=cell_id)
    scf_value_dic['cellArfcn'] = int(cellArfcn)
    scsSsb = scf_analysis.get_scsSsb_from_scf(cell_id=cell_id)
    scf_value_dic['scsSsb'] = int(scsSsb)
    scs = scf_analysis.get_scs_from_scf(cell_id=cell_id)
    scf_value_dic['scs'] = int(scs)
    type0CoresetConfigurationIndex = scf_analysis.get_type0CoresetConfigurationIndex_from_scf(cell_id=cell_id)
    scf_value_dic['type0CoresetConfigurationIndex'] = int(type0CoresetConfigurationIndex)
    actBeamforming = scf_analysis.get_actBeamforming_from_scf(cell_id=cell_id)
    scf_value_dic['actBeamforming'] = actBeamforming
    actPerCsiReportBundlingTddFr1 = scf_analysis.get_actPerCsiReportBundlingTddFr1_from_scf(cell_id=cell_id)
    scf_value_dic['actPerCsiReportBundlingTddFr1'] = actPerCsiReportBundlingTddFr1
    pucchF3ModulationScheme = scf_analysis.get_pucchF3ModulationScheme_from_scf(cell_id=cell_id)
    scf_value_dic['pucchF3ModulationScheme'] = pucchF3ModulationScheme
    dlMimoMode = scf_analysis.get_dlMimoMode_from_scf(cell_id=cell_id)
    scf_value_dic['dlMimoMode'] = dlMimoMode
    reqMinNumPuschPrb = scf_analysis.get_reqMinNumPuschPrb_from_scf(cell_id=cell_id)
    scf_value_dic['reqMinNumPuschPrb'] = int(reqMinNumPuschPrb)
    pucchF3MaxCodeRate = scf_analysis.get_pucchF3MaxCodeRate_from_scf(cell_id=cell_id)
    scf_value_dic['pucchF3MaxCodeRate'] = pucchF3MaxCodeRate
    numberOfTransmittedSsBlocks = scf_analysis.get_beamset_num_from_scf(cell_id=cell_id)
    scf_value_dic['numberOfTransmittedSsBlocks'] = numberOfTransmittedSsBlocks
    srPeriodicity = scf_analysis.get_srPeriodicity_from_scf(cell_id=cell_id)
    scf_value_dic['srPeriodicity'] = int(srPeriodicity)
    numberOfRxBeamforming = scf_analysis.get_numberOfRxBeamforming_from_scf(cell_id=cell_id)
    scf_value_dic['numberOfRxBeamforming'] = numberOfRxBeamforming
    nrCellType = scf_analysis.get_nrcell_type_from_scf(cell_id=cell_id)
    scf_value_dic['nrCellType'] = nrCellType
    msg1FrequencyStart = scf_analysis.get_msg1FrequencyStart_from_scf(cell_id=cell_id)
    scf_value_dic['msg1FrequencyStart'] = msg1FrequencyStart
    actLongPucchF1F3BfOnOranExtT6 = scf_analysis.get_actLongPucchF1F3BfOnOranExtT6_from_scf(cell_id=cell_id)
    scf_value_dic['actLongPucchF1F3BfOnOranExtT6'] = actLongPucchF1F3BfOnOranExtT6
    nrBtsBeamRefinementP2 = scf_analysis.get_nrBtsBeamRefinementP2_from_scf(cell_id=cell_id)
    scf_value_dic['nrBtsBeamRefinementP2'] = nrBtsBeamRefinementP2
    actLongPucchPhase2 = scf_analysis.get_actLongPucchPhase2_from_scf(cell_id=cell_id)
    scf_value_dic['actLongPucchPhase2'] = actLongPucchPhase2
    csiReportPeriodicity = scf_analysis.get_csiReportPeriodicity_from_scf(cell_id=cell_id)
    scf_value_dic['csiReportPeriodicity'] = csiReportPeriodicity
    actMultipleDedicatedBWPs = scf_analysis.get_actMultipleDedicatedBWPs_from_scf()
    scf_value_dic['actMultipleDedicatedBWPs'] = actMultipleDedicatedBWPs
    actConnRrcPooling = scf_analysis.get_actConnRrcPooling_from_scf()
    scf_value_dic['actConnRrcPooling'] = actConnRrcPooling
    actSharedSr = scf_analysis.get_actSharedSr_from_scf(cell_id=cell_id)
    scf_value_dic['actSharedSr'] = actSharedSr
    actLongPucchResourceOpt = scf_analysis.get_actLongPucchResourceOpt_from_scf(cell_id=cell_id)
    scf_value_dic['actLongPucchResourceOpt'] = actLongPucchResourceOpt
    actDynUlResAlloc = scf_analysis.get_actDynUlResAlloc_from_scf(cell_id=cell_id)
    scf_value_dic['actDynUlResAlloc'] = actDynUlResAlloc
    pucchF1ResOccConf = scf_analysis.get_pucchF1ResOccConf_from_scf(cell_id=cell_id)
    scf_value_dic['pucchF1ResOccConf'] = pucchF1ResOccConf
    pucchNumberHarqAnPrbs = scf_analysis.get_pucchNumberHarqAnPrbs_from_scf(cell_id=cell_id)
    scf_value_dic['pucchNumberHarqAnPrbs'] = pucchNumberHarqAnPrbs
    return scf_value_dic


class CalculateFreq(object):
    def __init__(self, scf_path, cell_id, nband):
        self.scf_value_dic = get_value_from_scf(scf_path=scf_path, cell_id=cell_id)
        self.cellArfcn = self.scf_value_dic['cellArfcn']
        self.chbw = self.scf_value_dic['chbw']
        self.scsSsb = self.scf_value_dic['scsSsb']
        self.scs = self.scf_value_dic['scs']
        self.nband = nband
        self.type0CoresetConfigurationIndex = self.scf_value_dic['type0CoresetConfigurationIndex']
        self.nbPRB = self.get_nbPRB()
        self.arfcnRaster = self.get_arfcnRaster()

    def get_nbPRB(self):
        tdd_type = ''
        if self.cellArfcn <= 800000:
            tdd_type = 'FR1'
        elif self.cellArfcn >= 2016667:
            tdd_type = 'FR2'
        nbPRB = prbAndGuard[tdd_type][str(self.chbw)][str(self.scs)]["PRB"]
        return nbPRB

    def get_arfcnRaster(self):
        arfcnRaster = ''
        if self.cellArfcn <= 599999:
            arfcnRaster = 5
        elif self.cellArfcn >= 600000 and self.cellArfcn <= 2016666:
            arfcnRaster = 15
        elif self.cellArfcn >= 2016667 and self.cellArfcn <= 3279165:
            arfcnRaster = 60
        return arfcnRaster

    def check_raster15(self, arfcnPtA, param1, param2, param3):
        if (param1 - arfcnPtA) % 3 == 0:
            return param1
        elif (param2 - arfcnPtA) % 3 == 0:
            return param2
        elif (param3 - arfcnPtA) % 3 == 0:
            return param3
        return param1

    def calculate_gscnArfcn(self):
        freq_dic = {}
        kssbmin = 0
        kssbmax = 11
        value = self.type0CoresetConfigurationIndex
        coresetPRB = supportedCoresetType0[str(self.scsSsb)][str(self.scs)][str(value)]["nbPRB"]
        coresetOffset = supportedCoresetType0[str(self.scsSsb)][str(self.scs)][str(value)]["offset"]
        freq_dic['coresetOffset'] = coresetOffset
        coresetSize = coresetPRB
        addArfcnScsGuardBand = 0
        if self.scsSsb == 240:
            if self.nbPRB == 66:
                addArfcnScsGuardBand = 23
            elif self.nbPRB == 132:
                addArfcnScsGuardBand = 47
            elif self.nbPRB == 264:
                addArfcnScsGuardBand = 96
        minArfcn = (self.cellArfcn +
                    ((10 * self.scsSsb / self.scs +
                      max(coresetOffset, (addArfcnScsGuardBand * self.arfcnRaster) / (12 * self.scs))) * 12 +
                     kssbmin - (math.floor(self.nbPRB / 2) * 12 + 6 * (self.nbPRB % 2))) * self.scs / self.arfcnRaster)
        freq_dic['minArfcn'] = minArfcn
        maxArfcn = (self.cellArfcn +
                    (self.scs / self.arfcnRaster) *
                    ((math.floor(self.nbPRB / 2) * 12 + 6 * (self.nbPRB % 2)) -
                     max((120 * self.scsSsb + self.arfcnRaster * addArfcnScsGuardBand) / self.scs,
                         (coresetSize - 10 * self.scsSsb / self.scs - coresetOffset) * 12 - kssbmax)))
        freq_dic['maxArfcn'] = maxArfcn
        if self.cellArfcn <= 599999:
            gscnRaster = 1200
            offsetM1 = 50
            offsetM3 = 150
            offsetM5 = 250
            nM1 = (minArfcn * self.arfcnRaster - offsetM1) / gscnRaster
            nM3 = (minArfcn * self.arfcnRaster - offsetM3) / gscnRaster
            nM5 = (minArfcn * self.arfcnRaster - offsetM5) / gscnRaster

            nMidM1 = (self.cellArfcn * self.arfcnRaster - offsetM1) / gscnRaster
            nMidM3 = (self.cellArfcn * self.arfcnRaster - offsetM3) / gscnRaster
            nMidM5 = (self.cellArfcn * self.arfcnRaster - offsetM5) / gscnRaster

            nMaxM1 = (maxArfcn * self.arfcnRaster - offsetM1) / gscnRaster
            nMaxM3 = (maxArfcn * self.arfcnRaster - offsetM3) / gscnRaster
            nMaxM5 = (maxArfcn * self.arfcnRaster - offsetM5) / gscnRaster

            if self.nband == 'n41':
                step = 3
            else:
                step = 1

            nMinM1 = math.floor(math.sqrt(step)) * math.floor(nM1 / math.floor(math.sqrt(step))) + math.ceil(
                (nM1 - math.floor(math.sqrt(step)) * math.floor(nM1 / math.floor(math.sqrt(step)))) / math.floor(
                    math.sqrt(step)))
            nMinM3 = math.floor(math.sqrt(step)) * math.floor(nM3 / math.floor(math.sqrt(step))) + math.ceil(
                (nM3 - math.floor(math.sqrt(step)) * math.floor(nM3 / math.floor(math.sqrt(step)))) / math.floor(
                    math.sqrt(step)))
            nMinM5 = math.floor(math.sqrt(step)) * math.floor(nM5 / math.floor(math.sqrt(step))) + math.ceil(
                (nM5 - math.floor(math.sqrt(step)) * math.floor(nM5 / math.floor(math.sqrt(step)))) / math.floor(
                    math.sqrt(step)))
            nMinMidM1 = math.floor(math.sqrt(step)) * math.floor(nMidM1 / math.floor(math.sqrt(step)))
            nMinMidM3 = math.floor(math.sqrt(step)) * math.floor(nMidM3 / math.floor(math.sqrt(step)))
            nMinMidM5 = math.floor(math.sqrt(step)) * math.floor(nMidM5 / math.floor(math.sqrt(step)))
            nMinMaxM1 = math.floor(math.sqrt(step)) * math.floor(nMaxM1 / math.floor(math.sqrt(step)))
            nMinMaxM3 = math.floor(math.sqrt(step)) * math.floor(nMaxM3 / math.floor(math.sqrt(step)))
            nMinMaxM5 = math.floor(math.sqrt(step)) * math.floor(nMaxM5 / math.floor(math.sqrt(step)))
            arfcnPtA = (self.cellArfcn -
                        (math.floor(self.nbPRB / 2) * 12 + 6 * (self.nbPRB % 2)) * self.scs / self.arfcnRaster)
            gscnArfcnM1 = (offsetM1 + nMinM1 * gscnRaster) / self.arfcnRaster
            gscnArfcnM3 = (offsetM3 + nMinM3 * gscnRaster) / self.arfcnRaster
            gscnArfcnM5 = (offsetM5 + nMinM5 * gscnRaster) / self.arfcnRaster
            gscnArfcnMidM1 = (offsetM1 + nMinMidM1 * gscnRaster) / self.arfcnRaster
            gscnArfcnMidM3 = (offsetM3 + nMinMidM3 * gscnRaster) / self.arfcnRaster
            gscnArfcnMidM5 = (offsetM5 + nMinMidM3 * gscnRaster) / self.arfcnRaster
            gscnArfcnMaxM1 = (offsetM1 + nMinMaxM1 * gscnRaster) / self.arfcnRaster
            gscnArfcnMaxM3 = (offsetM3 + nMinMaxM3 * gscnRaster) / self.arfcnRaster
            gscnArfcnMaxM5 = (offsetM5 + nMinMaxM5 * gscnRaster) / self.arfcnRaster

            if self.nband == 'n41':
                gscnArfcnLowerEdge = self.check_raster15(arfcnPtA, gscnArfcnM3, gscnArfcnM1, gscnArfcnM5)
                gscnArfcnMiddle = max(gscnArfcnLowerEdge,
                                      self.check_raster15(arfcnPtA, gscnArfcnMidM3, gscnArfcnMidM1, gscnArfcnMidM5))
                gscnArfcnUpperEdge = max(gscnArfcnMiddle,
                                         self.check_raster15(arfcnPtA, gscnArfcnMaxM1, gscnArfcnMaxM3, gscnArfcnMaxM5))
            else:
                gscnArfcnLowerEdge = self.check_raster15(arfcnPtA, gscnArfcnM1, gscnArfcnM3, gscnArfcnM5)
                gscnArfcnMiddle = max(gscnArfcnLowerEdge,
                                      self.check_raster15(arfcnPtA, gscnArfcnMidM3, gscnArfcnMidM1, gscnArfcnMidM5))
                gscnArfcnUpperEdge = max(gscnArfcnMiddle,
                                         self.check_raster15(arfcnPtA, gscnArfcnMaxM1, gscnArfcnMaxM3, gscnArfcnMaxM5))
        elif self.cellArfcn >= 600000 and self.cellArfcn <= 2016666:
            gscnRaster = 1440
            gscnArfcnOffset = 600000
            N = self.arfcnRaster * 1.0 / gscnRaster * (minArfcn - gscnArfcnOffset)
            Nmid = self.arfcnRaster * 1.0 / gscnRaster * (self.cellArfcn - gscnArfcnOffset)
            Nmax = self.arfcnRaster * 1.0 / gscnRaster * (maxArfcn - gscnArfcnOffset)
            if self.nband == 'n79':
                step = 16
                offsetN = 5
            else:
                step = 1
                offsetN = 0
            minN = step * (math.floor((N - offsetN) / step) + math.ceil(
                (N - (step * math.floor((N - offsetN) / step) + offsetN)) / step)) + offsetN
            gscnArfcnLowerEdge = gscnArfcnOffset + minN * gscnRaster / self.arfcnRaster
            minNmid = step * math.floor((Nmid - offsetN) / step) + offsetN
            gscnArfcnMiddle = max(gscnArfcnLowerEdge, gscnArfcnOffset + minNmid * gscnRaster / self.arfcnRaster)
            minNmax = step * math.floor((Nmax - offsetN) / step) + offsetN
            gscnArfcnUpperEdge = max(gscnArfcnMiddle, gscnArfcnOffset + minNmax * gscnRaster / self.arfcnRaster)
        else:
            gscnRaster = 17280
            gscnArfcnOffset = 2016667
            N = self.arfcnRaster / gscnRaster * (minArfcn - gscnArfcnOffset)
            Nmid = self.arfcnRaster / gscnRaster * (self.cellArfcn - gscnArfcnOffset)
            Nmax = self.arfcnRaster / gscnRaster * (maxArfcn - gscnArfcnOffset)
            if self.scsSsb == 120:
                step = 1
            else:
                step = 2

            minN = step * (math.floor(N / step) + math.ceil((N - (step * math.floor(N / step))) / step))
            gscnArfcnLowerEdge = gscnArfcnOffset + minN * gscnRaster / self.arfcnRaster

            minNmid = step * math.floor(Nmid / step)
            gscnArfcnMiddle = max(gscnArfcnLowerEdge, gscnArfcnOffset + minNmid * gscnRaster / self.arfcnRaster)

            minNmax = step * math.floor(Nmax / step)
            gscnArfcnUpperEdge = max(gscnArfcnMiddle, gscnArfcnOffset + minNmax * gscnRaster / self.arfcnRaster)

        freq_dic['gscnArfcnLowerEdge'] = gscnArfcnLowerEdge
        freq_dic['gscnArfcnMiddle'] = gscnArfcnMiddle
        freq_dic['gscnArfcnUpperEdge'] = gscnArfcnUpperEdge
        print(freq_dic)
        return freq_dic


class CalculateLongPucch(object):
    def __init__(self, productName, scf_path, cell_id, release='master'):
        self.productName = productName
        self.scf_value_dic = get_value_from_scf(scf_path=scf_path, cell_id=cell_id)
        self.release = release

    def read_csv(self, csv_path, row_name, col_name):
        with open(csv_path, 'r') as f:
            f_csv = csv.reader(f)
            headings = next(f_csv)
            for head in headings:
                if str(head) == str(col_name):
                    col_index = headings.index(head)
                    break
            for row in f_csv:
                if str(row[0]) == str(row_name):
                    return int(row[col_index])

    def get_HARQ(self):
        chbw = self.scf_value_dic['chbw']
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        if chbw >= 80:
            if actLongPucchF1F3BfOnOranExtT6.lower() == 'false':
                HARQ = 16
            else:
                HARQ = 22
        elif 50 <= chbw < 80:
            HARQ = 16
        elif chbw == 40:
            HARQ = 12
        elif chbw == 30 or chbw == 20:
            HARQ = 6
        else:
            HARQ = 4
        return HARQ

    def get_dlMimoMode_and_channelacq(self):
        nrcell_dlMimoMode = self.scf_value_dic['dlMimoMode']
        if nrcell_dlMimoMode == '2x2 Closed Loop Spatial Multiplexing':
            dlMimoMode = 30
            channelacq = 7
        elif nrcell_dlMimoMode == '2x2 Open Loop Spatial Multiplexing':
            dlMimoMode = 50
            channelacq = 7
        elif nrcell_dlMimoMode == '4x4 or 4x2 Closed Loop Spatial Multiplexing':
            dlMimoMode = 40
            channelacq = 11
        elif nrcell_dlMimoMode == '4x4 or 4x2 Open Loop Spatial Multiplexing':
            dlMimoMode = 60
            channelacq = 11
        elif nrcell_dlMimoMode == '8x4 Closed Loop Spatial Multiplexing':
            dlMimoMode = 70
            channelacq = 19
        return dlMimoMode, channelacq

    def get_uci_chacq(self):
        _, channelacq = self.get_dlMimoMode_and_channelacq()
        uci_chacq = channelacq + 5
        return uci_chacq

    def get_Beamreport(self):
        nrBtsBeamRefinementP2 = self.scf_value_dic['nrBtsBeamRefinementP2']
        numberOfTransmittedSsBlocks = self.scf_value_dic['numberOfTransmittedSsBlocks']
        numberOfTransmittedSsBlocks = int(re.search(r'\d+', numberOfTransmittedSsBlocks).group(0))
        if nrBtsBeamRefinementP2.lower() == 'false' and numberOfTransmittedSsBlocks == 1:
            Beamreport = 7
        elif nrBtsBeamRefinementP2.lower() == 'false' and numberOfTransmittedSsBlocks == 2:
            Beamreport = 13
        elif nrBtsBeamRefinementP2.lower() == 'false' and (3 <= numberOfTransmittedSsBlocks <= 4):
            Beamreport = 15
        elif nrBtsBeamRefinementP2.lower() == 'false' and (5 <= numberOfTransmittedSsBlocks <= 8):
            Beamreport = 17
        elif nrBtsBeamRefinementP2.lower() == 'true' and numberOfTransmittedSsBlocks == 1:
            Beamreport = 15
        elif nrBtsBeamRefinementP2.lower() == 'true' and numberOfTransmittedSsBlocks == 2:
            Beamreport = 17
        elif nrBtsBeamRefinementP2.lower() == 'true' and (3 <= numberOfTransmittedSsBlocks <= 4):
            Beamreport = 19
        elif nrBtsBeamRefinementP2.lower() == 'true' and (5 <= numberOfTransmittedSsBlocks <= 8):
            Beamreport = 21
        return Beamreport

    def get_uci_beam(self):
        Beamreport = self.get_Beamreport()
        uci_beam = Beamreport + 5
        return uci_beam

    def get_pCSI(self, uci_chacq, uci_beam, uci_bundle):
        pucchF3ModulationScheme = self.scf_value_dic['pucchF3ModulationScheme']
        actBeamforming = self.scf_value_dic['actBeamforming']
        actPerCsiReportBundlingTddFr1 = self.scf_value_dic['actPerCsiReportBundlingTddFr1']
        pucchF3MaxCodeRate = self.scf_value_dic['pucchF3MaxCodeRate']
        if pucchF3ModulationScheme == 'qpsk_4psk':
            csv_path = os.path.join(os.path.dirname(__file__), 'variable/csv/qpsk.csv')
        else:
            csv_path = os.path.join(os.path.dirname(__file__), 'variable/csv/pi2bpsk.csv')
        if actBeamforming.lower() == 'true':
            if actPerCsiReportBundlingTddFr1.lower() == 'true':
                pCSI = self.read_csv(csv_path=csv_path,
                                     row_name=uci_bundle,
                                     col_name=pucchF3MaxCodeRate)
            else:
                pCSI_1 = self.read_csv(csv_path=csv_path,
                                       row_name=uci_chacq,
                                       col_name=pucchF3MaxCodeRate)
                pCSI_2 = self.read_csv(csv_path=csv_path,
                                       row_name=uci_beam,
                                       col_name=pucchF3MaxCodeRate)
                pCSI = min(pCSI_1, pCSI_2)

        else:
            pCSI = self.read_csv(csv_path=csv_path,
                                 row_name=uci_chacq,
                                 col_name=pucchF3MaxCodeRate)
        return pCSI

    def get_pCSI_per_ue(self):
        actPerCsiReportBundlingTddFr1 = self.scf_value_dic['actPerCsiReportBundlingTddFr1']
        actBeamforming = self.scf_value_dic['actBeamforming']
        if actPerCsiReportBundlingTddFr1.lower() == 'false' and actBeamforming.lower() == 'true':
            pCSI_per_ue = 2
        else:
            pCSI_per_ue = 1
        return pCSI_per_ue

    def get_bbtype(self):
        nrCellType = self.scf_value_dic['nrCellType']
        numberOfRxBeamforming = self.scf_value_dic['numberOfRxBeamforming']
        BBtype = 'ABIO'
        if self.productName == 'ABIL AirScale Capacity':
            if '2UL' in nrCellType:
                BBtype = 'ABIL/C2/1subcell'
            else:
                if numberOfRxBeamforming.lower() == '2rx':
                    BBtype = 'ABIL/C2/2subcell'
                else:
                    BBtype = 'ABIL/C4/1subcell'
        print("BBtype:{}".format(BBtype))
        return BBtype

    def get_f1_f3(self, BBtype):
        actLongPucchPhase2 = self.scf_value_dic['actLongPucchPhase2']
        processor = self.get_processor(BBtype=BBtype)
        f1, f3 = 62, 22
        if processor == 'Loner':
            if BBtype == 'ABIL/C2/1subcell':
                f1, f3 = 64, 24
            elif BBtype == 'ABIL/C4/1subcell':
                f1, f3 = 96, 36
            elif BBtype == 'ABIL/C2/2subcell':
                f1, f3 = 128, 48
        elif (processor == 'Loki' or processor == 'Thor') and actLongPucchPhase2.lower() == 'false':
            f1, f3 = 44, 20
        elif (processor == 'Loki' or processor == 'Thor') and actLongPucchPhase2.lower() == 'true':
            f1, f3 = 62, 22
        else:
            f1, f3 = 78, 22
        return f1, f3

    def get_processor(self, BBtype):
        if 'ABIL' in BBtype:
            processor = 'Loner'
        elif BBtype == 'ABIN' or BBtype == 'ABIO' or BBtype == 'ABIP':
            processor = 'Loki'
        elif BBtype == 'ASOE':
            processor = 'Thor'
        else:
            processor = 'vDU'
        return processor

    def get_cs_per_prb(self):
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        if actLongPucchF1F3BfOnOranExtT6.lower() == 'true':
            cs_per_prb = 1
        else:
            cs_per_prb = 6
        return cs_per_prb

    def get_helper2(self, helper1):
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        if actLongPucchF1F3BfOnOranExtT6.lower() == 'true':
            helper2 = (2 * self.get_cs_per_prb()
                       * math.ceil(helper1 / (2 * 2 * self.get_cs_per_prb())))
        else:
            if helper1 <= 12:
                helper2 = 12
            elif helper1 > 12 and helper1 <= 24:
                helper2 = 24
            elif helper1 > 24 and helper1 <= 36:
                helper2 = 36
            else:
                helper2 = 48
        return helper2

    def get_helper3(self, pCSI, chbw):
        csv_path_refer2 = os.path.join(os.path.dirname(__file__), 'variable/csv/refer2.csv')
        value = self.read_csv(csv_path=csv_path_refer2,
                              row_name=pCSI,
                              col_name=chbw)
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        if actLongPucchF1F3BfOnOranExtT6.lower() == 'true':
            helper3 = min(self.get_pCSI_per_ue() * value, 12)
        else:
            helper3 = 6 * value
        return helper3

    def get_value(self, pCSI, chbw):
        if 'ABIO' in self.productName:
            csv_path = os.path.join(os.path.dirname(__file__), 'variable/csv/refer1_new.csv')
        else:
            csv_path = os.path.join(os.path.dirname(__file__), 'variable/csv/refer1.csv')
        value = self.read_csv(csv_path=csv_path,
                              row_name=pCSI,
                              col_name=chbw)
        return value

    def get_f1_HARQ(self):
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        if actLongPucchF1F3BfOnOranExtT6.lower() == 'true':
            f1_HARQ = 22
        else:
            f1_HARQ = 16 if 'ABIO' in self.productName else 32
        return f1_HARQ

    def get_eq2(self, f3, f3_HARQ, k):
        if self.release == '23R1':
            eq2 = True if f3 - f3_HARQ >= k else False
        else:
            actConnRrcPooling = self.scf_value_dic['actConnRrcPooling']
            if actConnRrcPooling.lower() == 'true':
                eq2 = 48
            else:
                eq2 = True if f3 - f3_HARQ >= k else False
        return eq2

    def get_eq3(self, f1, f1_HARQ, helper4, k, pCSI_SR_Ratio, pCSI_per_ue):
        actSharedSr = self.scf_value_dic['actSharedSr']
        if actSharedSr.lower() == 'true':
            eq3 = 'N/A'
        else:
            eq3 = True if min(f1 - f1_HARQ, helper4) >= k * (pCSI_SR_Ratio / pCSI_per_ue) else False
        return eq3

    def get_eq4(self, sr, HARQ, k, pCSI, nbPRB):
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        actSharedSr = self.scf_value_dic['actSharedSr']
        if not (actLongPucchF1F3BfOnOranExtT6.lower() == 'true' and actSharedSr.lower() == 'true'):
            eq4 = 'N/A'
        else:
            if (sr + HARQ + k * pCSI <= nbPRB * 20 / 100) and (k <= 12):
                eq4 = True
            else:
                eq4 = False
        return eq4

    def get_f3_HARQ(self, HARQ):
        actLongPucchResourceOpt = self.scf_value_dic['actLongPucchResourceOpt']
        if self.release == '23R1':
            f3_HARQ = 6
        else:
            f3_HARQ = min(6, HARQ) if actLongPucchResourceOpt.lower() == 'true' else 6
        return f3_HARQ

    def get_f1_occ_for_sr(self):
        actLongPucchResourceOpt = self.scf_value_dic['actLongPucchResourceOpt']
        f1_occ_for_sr = 1
        if actLongPucchResourceOpt.lower() == 'false':
            f1_occ_for_sr = 1
        else:
            pucchF1ResOccConf = self.scf_value_dic['pucchF1ResOccConf']
            if pucchF1ResOccConf == '1-1-0_OCCs':
                f1_occ_for_sr = 1
            elif pucchF1ResOccConf == '2-2-0_OCCs':
                f1_occ_for_sr = 2
            elif pucchF1ResOccConf == '3-2-0_OCCs':
                f1_occ_for_sr = 3
            elif pucchF1ResOccConf == '2-2-1_OCCs':
                f1_occ_for_sr = 2
        return f1_occ_for_sr

    def get_f1_resources_per_prb(self):
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        if actLongPucchF1F3BfOnOranExtT6.lower() == 'true':
            f1_resources_per_prb = 1
        else:
            f1_resources_per_prb = 6 * self.get_f1_occ_for_sr()
        return f1_resources_per_prb

    def get_working_pcsi_resources_per_ue(self, pCSI_per_ue):
        connRrcPoolingAllowed_TDD = self.scf_value_dic['actConnRrcPooling']
        if connRrcPoolingAllowed_TDD.lower() == 'true':
            working_pcsi_resources_per_ue = pCSI_per_ue
        else:
            working_pcsi_resources_per_ue = pCSI_per_ue
        return working_pcsi_resources_per_ue

    def get_sr(self, chbw, pCSI, k, pCSI_per_ue):
        reqMinNumPuschPrb = self.scf_value_dic['reqMinNumPuschPrb']
        actLongPucchResourceOpt = self.scf_value_dic['actLongPucchResourceOpt']
        if str(reqMinNumPuschPrb) == '0':
            sr = 1 if actLongPucchResourceOpt.lower() == 'true' else 2
            return sr
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        actSharedSr = self.scf_value_dic['actSharedSr']
        connRrcPoolingAllowed_TDD = self.scf_value_dic['actConnRrcPooling']
        maximum_sr = self.get_maximum_sr(chbw=chbw, pCSI=pCSI)
        if (actLongPucchF1F3BfOnOranExtT6.lower() == 'true' and actSharedSr.lower() == 'true' and
                connRrcPoolingAllowed_TDD.lower() == 'false'):
            sr = maximum_sr
        else:
            f1_resources_per_prb = self.get_f1_resources_per_prb()
            csiReportPeriodicity_TDD = self.scf_value_dic['csiReportPeriodicity']
            srPeriodicity_TDD = self.scf_value_dic['srPeriodicity']
            working_pcsi_resources_per_ue = self.get_working_pcsi_resources_per_ue(pCSI_per_ue=pCSI_per_ue)
            sr = min(2*math.ceil(int(csiReportPeriodicity_TDD)/int(srPeriodicity_TDD)*k/working_pcsi_resources_per_ue /
                                 (2 * f1_resources_per_prb)), maximum_sr)
        return sr

    def get_harq(self, chbw):
        reqMinNumPuschPrb = self.scf_value_dic['reqMinNumPuschPrb']
        actLongPucchResourceOpt = self.scf_value_dic['actLongPucchResourceOpt']
        if str(reqMinNumPuschPrb) == '0':
            harq = 1 if actLongPucchResourceOpt.lower() == 'true' else 2
        else:

            harq = self.get_prbs_harq(chbw=chbw)
        return harq

    def get_harq_with_actLongPucchResourceOpt_on(self, chbw):
        pucchNumberHarqAnPrbs = self.scf_value_dic['pucchNumberHarqAnPrbs']
        harq = re.search(r'\d+', pucchNumberHarqAnPrbs)
        if harq:
            harq = int(harq.group(0))
        else:
            if int(chbw) >= 50:
                harq = 16
            elif int(chbw) == 40:
                harq = 8
            elif int(chbw) == 20 or int(chbw) == 30:
                harq = 6
            else:
                harq = 4
        return harq

    def get_prbs_harq(self, chbw):
        csv_path_maximum_prbs_sr = os.path.join(os.path.dirname(__file__), 'variable/csv/prbs_harq.csv')
        actLongPucchResourceOpt = self.scf_value_dic['actLongPucchResourceOpt']
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        if actLongPucchResourceOpt.lower() == 'true':
            return self.get_harq_with_actLongPucchResourceOpt_on(chbw=chbw)
        with open(csv_path_maximum_prbs_sr, 'r') as f:
            f_csv = csv.reader(f)
            headings = next(f_csv)
            for head in headings:
                if str(head) == str(chbw):
                    col_index = headings.index(head)
                    break
            for row in f_csv:
                if (str(row[0]) == str(actLongPucchResourceOpt.upper()) and
                        str(row[1]) == str(actLongPucchF1F3BfOnOranExtT6.upper())):
                    return int(row[col_index])

    def get_maximum_sr(self, chbw, pCSI):
        actLongPucchF1F3BfOnOranExtT6 = self.scf_value_dic['actLongPucchF1F3BfOnOranExtT6']
        actSharedSr = self.scf_value_dic['actSharedSr']
        csv_path_maximum_prbs_sr = os.path.join(os.path.dirname(__file__), 'variable/csv/maximum_prbs_sr.csv')
        with open(csv_path_maximum_prbs_sr, 'r') as f:
            f_csv = csv.reader(f)
            headings = next(f_csv)
            for head in headings:
                if str(head) == str(chbw):
                    col_index = headings.index(head)
                    break
            for row in f_csv:
                if (str(row[0]) == str(actLongPucchF1F3BfOnOranExtT6.upper()) and
                        str(row[1]) == str(actSharedSr.upper()) and str(row[2]) == str(pCSI)):
                    return int(row[col_index])

    def get_reqMaxNumPuschPrb_and_pucchprb_list(self, pCSI_SR_Ratio, pCSI_per_ue, pCSI, HARQ, nbPRB):
        chbw = self.scf_value_dic['chbw']
        BBtype = self.get_bbtype()
        f1, f3 = self.get_f1_f3(BBtype=BBtype)
        k_list = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24]
        reqMaxNumPuschPrb_list = []
        pucchprb_list = []
        new_k_list = []
        for k in k_list:
            helper1 = pCSI_SR_Ratio * k / pCSI_per_ue
            helper3 = self.get_helper3(pCSI=pCSI, chbw=chbw)
            sr_per_slot = max(min(helper1, helper3), 2)
            cs_per_prb = self.get_cs_per_prb()
            helper4 = 2 * cs_per_prb * math.ceil(sr_per_slot / (2 * cs_per_prb))
            sr = helper4 / cs_per_prb
            value = self.get_value(pCSI=pCSI, chbw=chbw)
            f3_HARQ = self.get_f3_HARQ(HARQ=HARQ)
            eq2 = self.get_eq2(f3=f3, f3_HARQ=f3_HARQ, k=k)
            f1_HARQ = self.get_f1_HARQ()
            eq3 = self.get_eq3(f1=f1, f1_HARQ=f1_HARQ, helper4=helper4,
                               k=k, pCSI_SR_Ratio=pCSI_SR_Ratio, pCSI_per_ue=pCSI_per_ue)
            eq4 = self.get_eq4(sr=sr, HARQ=HARQ, k=k, pCSI=pCSI, nbPRB=nbPRB)
            print("Eq2:{}, Eq3:{}, Eq4:{}".format(eq2, eq3, eq4))
            if k > value:
                conf_allow = 'k!'
            elif (eq2 is True and eq3 is not False and eq4 is not False) or k == 2:
                conf_allow = 'yes'
            else:
                conf_allow = 'no'
            if conf_allow == 'yes':
                reqMaxNumPuschPrb = int(nbPRB - (sr + HARQ + k * pCSI))
                pucchprb = int(sr + HARQ + k * pCSI)
                reqMaxNumPuschPrb_list.append(reqMaxNumPuschPrb)
                pucchprb_list.append(pucchprb)
                new_k_list.append(k)
        return reqMaxNumPuschPrb_list, pucchprb_list, new_k_list


def calculate_rbStartCoreset0_tdd(scf_path, cell_id, nband):
    scf_value_dic = get_value_from_scf(scf_path=scf_path, cell_id=cell_id)
    print("scf value for cell id {}: {}".format(cell_id, scf_value_dic))
    calfreq = CalculateFreq(scf_path=scf_path,
                            cell_id=cell_id,
                            nband=nband)
    freq_dic = calfreq.calculate_gscnArfcn()
    gscn = int(scf_value_dic['gscn'])
    if gscn == 0:
        gscnArfcn = freq_dic['gscnArfcnLowerEdge']
    elif gscn == 1:
        gscnArfcn = freq_dic['gscnArfcnMiddle']
    elif gscn == 2:
        gscnArfcn = freq_dic['gscnArfcnUpperEdge']
    else:
        gscnArfcn = scf_value_dic['cellArfcn']
    rbStartCoreset0 = \
        int((gscnArfcn - freq_dic['minArfcn']) * calfreq.arfcnRaster / (12 * scf_value_dic['scs']) +
            int(scf_value_dic['msg1FrequencyStart']))
    print('rbStartCoreset0: {}'.format(rbStartCoreset0))
    return rbStartCoreset0


def calculate_pucchprb_tdd(scf_path, cell_id, nband, productName, release='master'):
    scf_value_dic = get_value_from_scf(scf_path=scf_path, cell_id=cell_id)
    print("scf value for cell id {}: {}".format(cell_id, scf_value_dic))
    calfreq = CalculateFreq(scf_path=scf_path,
                            cell_id=cell_id,
                            nband=nband)
    callo = CalculateLongPucch(productName=productName,
                               scf_path=scf_path,
                               cell_id=cell_id,
                               release=release)
    uci_chacq = callo.get_uci_chacq()
    print('uci_chacq:{}'.format(uci_chacq))
    uci_beam = callo.get_uci_beam()
    print('uci_beam:{}'.format(uci_beam))
    uci_bundle = uci_chacq + uci_beam - 5
    print('uci_bundle:{}'.format(uci_bundle))
    HARQ = callo.get_HARQ()
    pCSI = callo.get_pCSI(uci_chacq=uci_chacq,
                          uci_beam=uci_beam,
                          uci_bundle=uci_bundle)
    print('pCSI:{}'.format(pCSI))
    pCSI_per_ue = callo.get_pCSI_per_ue()
    pCSI_SR_Ratio = int(scf_value_dic['csiReportPeriodicity']) / int(scf_value_dic['srPeriodicity'])
    reqMaxNumPuschPrb_list, pucchprb_list, new_k_list = callo.get_reqMaxNumPuschPrb_and_pucchprb_list(
        pCSI_SR_Ratio=pCSI_SR_Ratio,
        pCSI_per_ue=pCSI_per_ue,
        pCSI=pCSI,
        nbPRB=calfreq.nbPRB,
        HARQ=HARQ
    )
    print('reqMaxNumPuschPrb_list: {}'.format(reqMaxNumPuschPrb_list))
    print('pucchprb_list: {}'.format(pucchprb_list))
    diff_value = reqMaxNumPuschPrb_list[0] - scf_value_dic['reqMinNumPuschPrb']
    index = 0
    for reqMaxNumPuschPrb in reqMaxNumPuschPrb_list:
        get_diff_value = reqMaxNumPuschPrb - scf_value_dic['reqMinNumPuschPrb']
        if 0 <= get_diff_value <= diff_value:
            diff_value = get_diff_value
            index = reqMaxNumPuschPrb_list.index(reqMaxNumPuschPrb)
    print('reqMaxNumPuschPrb_list: {}'.format(reqMaxNumPuschPrb_list))
    print('pucchprb_list: {}'.format(pucchprb_list))
    pucchprb = pucchprb_list[index]
    print('pucchprb: {}'.format(pucchprb))
    k = new_k_list[index]
    print('k: {}'.format(k))
    long_pucch_sr = callo.get_sr(chbw=scf_value_dic['chbw'], pCSI=pCSI, k=k, pCSI_per_ue=pCSI_per_ue)
    print('long_pucch_sr: {}'.format(long_pucch_sr))
    long_pucch_harq = callo.get_harq(chbw=scf_value_dic['chbw'])
    print('long_pucch_harq: {}'.format(long_pucch_harq))
    actDynUlResAlloc = scf_value_dic['actDynUlResAlloc']
    if actDynUlResAlloc.lower() == 'true':
        final_pucchprb = int(long_pucch_sr) + int(long_pucch_harq)
    else:
        final_pucchprb = pucchprb
    print('final pucchprb: {}'.format(pucchprb))
    return pucchprb, final_pucchprb


# if __name__ == '__main__':
#     scf_path = '/home/ute/ztt/593_30_90.xml'
#
#     rbStartCoreset0 = calculate_rbStartCoreset0_tdd(
#         scf_path=scf_path,
#         cell_id=1,
#         nband='n78'
#     )
#     print(rbStartCoreset0)
#     pucchprb = calculate_pucchprb_tdd(
#                 scf_path=scf_path,
#                 cell_id=1,
#                 nband='n78',
#                 productName='ABIO',
#                 release='master')
#     print(pucchprb)
