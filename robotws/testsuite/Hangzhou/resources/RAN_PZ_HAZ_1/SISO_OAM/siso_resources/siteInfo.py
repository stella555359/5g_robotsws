# -*- coding: utf-8 -*-
"""
:author:  Lisa Ding
:contact: Ding, Lisa (NSB - CN/Hangzhou) <lisa.ding@nokia-sbell.com>
:Function: parse scfc to gain the related info such as bbu info, rmod info, cell info ect.

******************************************BBU INFO**********************************************
[{'smodId': '2', 'serialNumber': 'DH203864071', 'horizontalPosition': '2', 'verticalPosition': '1'},
 {'smodId': '1', 'serialNumber': 'DH203864073', 'horizontalPosition': '1', 'verticalPosition': '1'},
 {'bbmodId': '4', 'serialNumber': 'EA200950182', 'horizontalPosition': '2', 'verticalPosition': '2'},
 {'bbmodId': '5', 'serialNumber': 'EA200950216', 'horizontalPosition': '2', 'verticalPosition': '3'},
 {'bbmodId': '6', 'serialNumber': 'EA184380689', 'horizontalPosition': '2', 'verticalPosition': '4'},
 {'bbmodId': '1', 'serialNumber': 'EA184380597', 'horizontalPosition': '1', 'verticalPosition': '2'},
 {'bbmodId': '2', 'serialNumber': '6Q174907932', 'horizontalPosition': '1', 'verticalPosition': '3'},
 {'bbmodId': '3', 'serialNumber': 'L1170303356', 'horizontalPosition': '1', 'verticalPosition': '4'}]


******************************************RRU INFO**********************************************
[{'distName': 'MRBTS-6435/EQM-1/APEQM-1/RMOD-5', 'rmodId': '5', 'locatedCells': ['100', '101', '102', '103'],
'serialNumber': '6Q190108279'},
{'distName': 'MRBTS-6435/EQM-1/APEQM-1/RMOD-6', 'rmodId': '6', 'locatedCells': ['1', '2'],
'serialNumber': '1M203909482'},
{'distName': 'MRBTS-6435/EQM-1/APEQM-1/RMOD-2', 'rmodId': '2', 'serialNumber': 'BL2032V0IIP'},
{'distName': 'MRBTS-6435/EQM-1/APEQM-1/RMOD-1', 'rmodId': '1', 'locatedCells': ['12'], 'serialNumber': 'BL2032V0I5O'},
{'distName': 'MRBTS-6435/EQM-1/APEQM-1/RMOD-3', 'rmodId': '3', 'locatedCells': ['8'], 'serialNumber': 'EA203660216'},
{'distName': 'MRBTS-6435/EQM-1/APEQM-1/RMOD-4', 'rmodId': '4', 'locatedCells': ['9'], 'serialNumber': 'EA203660126'}]

******************************************CELL INFO**********************************************
[{'nrarfcn': '636666', 'chBw': '40MHz', 'nrCellGRP': '0', 'distName': 'MRBTS-6435/NRBTS-10069/NRCELL-1',
'nrCellId': '164970497', 'cellTechnology': 'TDD', 'phyCellId': '111', 'tddFrameConf': '1', 'band': '78',
'btsId': '10069', 'cellType': 'Normal', 'lcrId': '1', 'NetworkType': 'NSA', 'tddSpecSubfConf': '4',
'cellId': '1', 'scfc': '2G3G4G5G.xml'}, {'nrarfcn': '640000', 'chBw': '40MHz', 'nrCellGRP': '0',
'distName': 'MRBTS-6435/NRBTS-10069/NRCELL-2', 'nrCellId': '164970498', 'cellTechnology': 'TDD',
'phyCellId': '222', 'tddFrameConf': '1', 'band': '78', 'btsId': '10069', 'cellType': 'Normal', 'lcrId': '2',
'NetworkType': 'NSA', 'tddSpecSubfConf': '4', 'cellId': '2', 'scfc': '2G3G4G5G.xml'}, {'chBwDl': '20MHz',
'nrCellGRP': '1', 'distName': 'MRBTS-6435/NRBTS-10069/NRCELL-8', 'nrCellId': '164970504', 'cellTechnology': 'FDD',
'phyCellId': '112', 'band': '3', 'RF': [{'antl': ['1', '2', '3', '4'], 'serialNumber': 'EA203660216'}],
'btsId': '10069', 'cellType': 'Normal', 'lcrId': '8', 'NetworkType': 'NSA', 'earfcnUl': '350000', 'cellId': '8',
'earfcnDl': '363000', 'scfc': '2G3G4G5G.xml'}, {'chBw': '20 MHz', 'distName': 'MRBTS-6435/LNBTS-6435/LNCEL-100',
'cellTechnology': 'TDD', 'RF': [{'antl': ['1', '5', '6', '7', '8', '2', '3', '4'], 'serialNumber': '6Q190108279'}],
'phyCellId': '311', 'tddFrameConf': '2', 'band': '42', 'eutraCelId': '1647460', 'btsId': '6435', 'cellType': 'Normal',
'lcrId': '100', 'earfcn': '42290', 'NetworkType': '4G', 'freq': 3470.0, 'actMMimo': 'false', 'tddSpecSubfConf': '7',
'cellId': '100', 'scfc': '2G3G4G5G.xml'}, {'chBw': '20 MHz', 'distName': 'MRBTS-6435/LNBTS-6435/LNCEL-101',
'cellTechnology': 'TDD', 'RF': [{'antl': ['1', '5', '6', '7', '8', '2', '3', '4'], 'serialNumber': '6Q190108279'}],
'phyCellId': '312', 'tddFrameConf': '2', 'band': '42', 'eutraCelId': '1647461', 'btsId': '6435', 'cellType': 'Normal',
'lcrId': '101', 'earfcn': '42290', 'NetworkType': '4G', 'freq': 3470.0, 'actMMimo': 'false', 'tddSpecSubfConf': '7',
'cellId': '101', 'scfc': '2G3G4G5G.xml'}, {'chBw': '20 MHz', 'distName': 'MRBTS-6435/LNBTS-6435/LNCEL-102',
'cellTechnology': 'TDD', 'RF': [{'antl': ['1', '5', '6', '7', '8', '2', '3', '4'], 'serialNumber': '6Q190108279'}],
'phyCellId': '313', 'tddFrameConf': '2', 'band': '42', 'eutraCelId': '1647462', 'btsId': '6435', 'cellType': 'Normal',
'lcrId': '102', 'earfcn': '42290', 'NetworkType': '4G', 'freq': 3470.0, 'actMMimo': 'false', 'tddSpecSubfConf': '7',
'cellId': '102', 'scfc': '2G3G4G5G.xml'}, {'chBw': '20 MHz', 'distName': 'MRBTS-6435/LNBTS-6435/LNCEL-103',
'cellTechnology': 'TDD', 'RF': [{'antl': ['1', '5', '6', '7', '8', '2', '3', '4'], 'serialNumber': '6Q190108279'}],
'phyCellId': '314', 'tddFrameConf': '2', 'band': '42', 'eutraCelId': '1647463', 'btsId': '6435', 'cellType': 'Normal',
'lcrId': '103', 'earfcn': '42290', 'NetworkType': '4G', 'freq': 3470.0, 'actMMimo': 'false', 'tddSpecSubfConf': '7',
'cellId': '103', 'scfc': '2G3G4G5G.xml'}, {'chBwDl': '20 MHz', 'freq': 1815.0,
'distName': 'MRBTS-6435/LNBTS-6435/LNCEL-12', 'nrCellId': '164970497', 'cellTechnology': 'FDD',
'RF': [{'antl': ['1', '2'], 'serialNumber': 'BL2032V0I5O'}], 'phyCellId': '151', 'band': '3', 'eutraCelId': '1647372',
'btsId': '6435', 'cellType': 'Normal', 'lcrId': '12', 'NetworkType': '4G', 'earfcnUl': '19300', 'actMMimo': 'false',
'cellId': '12', 'earfcnDl': '1300', 'scfc': '2G3G4G5G.xml'}, {'chBwDl': '20 MHz', 'freq': 1815.0,
'distName': 'MRBTS-6435/LNBTS-6435/LNCEL-9', 'nrCellId': '164970497', 'cellTechnology': 'FDD',
'RF': [{'antl': ['1', '2'], 'serialNumber': 'EA203660126'}], 'phyCellId': '128', 'band': '3', 'eutraCelId': '1647369',
'btsId': '6435', 'cellType': 'Normal', 'lcrId': '9', 'NetworkType': '4G', 'earfcnUl': '19300', 'actMMimo': 'false',
'cellId': '9', 'earfcnDl': '1300', 'scfc': '2G3G4G5G.xml'}]

"""
from __future__ import absolute_import
from __future__ import print_function
import math
import random
from robot.libraries.XML import XML
import re


class site_Info(object):
    def __init__(self, scfc):
        self.scfc = scfc
        self.btsId = ''
        self.rmod_cell = {}
        self.cell_list = []
        self.rmod_list = []
        self.bbu_list = []
        self.ca = {}
        self.rmod_antl_port = {}
        self.supercell = {}
        self.techType = {}
        self.cell_sn = {}
        self.subCell = {}
        self.rmod_sn = {}
        self.rmod_chain = []
        self.nr_channelgroup_list = []
        self.xml = XML()
        self.parser = self.xml.parse_xml(self.scfc)

    def get_Nrcel_Info(self):
        try:
            nrcells = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
            for nrcell in nrcells:
                cellDict = {}
                self.subCell = {}
                distName = nrcell.attrib["distName"]
                cellDict['distName'] = distName
                cellDict['scfc'] = self.scfc
                cellDict['cellType'] = 'Normal'
                cellDict['cellId'] = str(distName.split('/')[-1].split('-')[-1])
                cellDict['nrCellGRP'] = self.nrcell_Group(cellDict['cellId'])
                cellDict['btsId'] = str(distName.split('/')[0].split('-')[-1])
                cellDict['lcrId'] = self.xml.get_element_text(nrcell, './p[@name="lcrId"]')
                cellDict['band'] = self.xml.get_element_text(nrcell, './p[@name="freqBandIndicatorNR"]')
                cellDict['NetworkType'] = self.xml.get_element_text(nrcell, './p[@name="cellDepType"]')
                cellDict['cellTechnology'] = self.xml.get_element_text(nrcell, './p[@name="cellTechnology"]')
                cellDict['nrCellId'] = self.xml.get_element_text(nrcell, './p[@name="nrCellIdentity"]')
                cellDict['phyCellId'] = self.xml.get_element_text(nrcell, './p[@name="physCellId"]')
                count = self.xml.get_element_count(nrcell, './p[@name="actSuperCell"]')
                count1 = self.xml.get_element_count(nrcell, './p[@name="actCombSuperCell"]')
                actSuperCell = 'false'
                actCombSuperCell = 'false'
                if count:
                    actSuperCell = self.xml.get_element_text(nrcell, './p[@name="actSuperCell"]')
                if count1:
                    actCombSuperCell = self.xml.get_element_text(nrcell, './p[@name="actCombSuperCell"]')
                if str(actSuperCell) == 'true' or str(actCombSuperCell) == 'true':
                    cellDict['cellType'] = 'Supercell'
                    self.supercell[cellDict['cellId']] = 'true'
                if cellDict['cellTechnology'] == 'TDD':
                    tddFrameStructure = self.xml.get_element(nrcell, './list[@name="tddFrameStructure"]')
                    items = self.xml.get_element(tddFrameStructure, 'item')
                    count2 = self.xml.get_element_count(nrcell, './p[@name="ulDlDataSlotRatio"]')
                    if count2:
                        ulDlDataSlot = self.xml.get_element_text(items, './p[@name="ulDlDataSlotRatio"]')
                        cellDict['tddFrameConf'] = ulDlDataSlot.split('/')[0]
                        cellDict['tddSpecSubfConf'] = ulDlDataSlot.split('/')[1]
                    else:
                        cellDict['tddFrameConf'] = 4
                        cellDict['tddSpecSubfConf'] = 6
                    cellDict['chBw'] = self.xml.get_element_text(nrcell, './p[@name="chBw"]')
                    cellDict['nrarfcn'] = self.xml.get_element_text(nrcell, './p[@name="nrarfcn"]')
                    cellDict['dlMimoMode'] = self.xml.get_element_text(nrcell, './p[@name="dlMimoMode"]')
                else:
                    cellDict['dlMimoMode'] = self.xml.get_element_text(nrcell, './p[@name="dlMimoMode"]')
                    cellDict = self.cell_ChBw_Earfcn('NR', cellDict['cellTechnology'], cellDict)
                    cellDict = self.update_nbiot_cell_info('NR', cellDict['cellTechnology'], cellDict)
                count = self.xml.get_element_count(nrcell, './p[@name="nbIotLinkedCellId"]')
                if count:
                    if 'related_cell' not in cellDict.keys():
                        nbIotLinkedCellId = self.xml.get_element_text(nrcell, './p[@name="nbIotLinkedCellId"]')
                        cellDict['related_cell'] = [nbIotLinkedCellId]
                    else:
                        cellDict['related_cell'] = cellDict['related_cell'].append(nbIotLinkedCellId)
                    cellDict['nbIoTMode'] = self.xml.get_element_text(nrcell, './p[@name="nbIoTMode"]')
                rfRefList = self.xml.get_element(nrcell, './list[@name="frRefList"]')
                rfmod = []
                for rfRef in rfRefList:
                    rfmod.append(rfRef.text)
                print(cellDict['cellId'])
                print(rfmod)
                cellDict['RF'] = self.cell_Map_Rmod_Ant(cellDict['lcrId'], 'NR', rfmod)
                cellDict['subCell'] = self.subCell.values()
                cellDict['channelgroup'] = self.subCell
                self.cell_list.append(cellDict)
        except Exception as e:
            print(e)

    def get_Nr_Channelgroup_Info(self):
        try:
            nr_channelgroups = self.xml.get_elements(self.parser,
                                                     './/managedObject[@class="com.nokia.srbts.mnl:CHANNELGROUP"]')
            for nr_channelgroup in nr_channelgroups:
                channelgroupDict = {}
                distName = nr_channelgroup.attrib['distName']
                channelgroupDict['distName'] = distName + "/"
                self.nr_channelgroup_list.append(channelgroupDict)
        except Exception as e:
            print(e)

    def get_Lncel_Info(self):
        lncel_list = self.xml.get_elements(self.parser, './/managedObject[@class="NOKLTE:LNCEL"]')
        for lncel in lncel_list:
            cellDict = {}
            self.subCell = {}
            distName = lncel.attrib["distName"]
            cellDict['distName'] = distName
            cellDict['scfc'] = self.scfc
            cellDict['NetworkType'] = '4G'
            cellDict['cellType'] = 'Normal'
            cellDict['cellId'] = str(distName.split('-')[-1])
            cellDict['btsId'] = str(distName.split('/')[0].split('-')[-1])
            cellDict['lcrId'] = self.xml.get_element_text(lncel, './p[@name="lcrId"]')
            cellDict['cellTechnology'] = self.xml.get_element_text(lncel, './p[@name="cellTechnology"]')
            cellDict['eutraCelId'] = self.xml.get_element_text(lncel, './p[@name="eutraCelId"]')
            cellDict['phyCellId'] = self.xml.get_element_text(lncel, './p[@name="phyCellId"]')
            count = self.xml.get_element_count(lncel, './p[@name="nbIotLinkedCellId"]')
            if count:
                if 'related_cell' not in cellDict.keys():
                    nbIotLinkedCellId = self.xml.get_element_text(lncel, './p[@name="nbIotLinkedCellId"]')
                    cellDict['related_cell'] = [nbIotLinkedCellId]
                else:
                    cellDict['related_cell'] = cellDict['related_cell'].append(nbIotLinkedCellId)
                cellDict['nbIoTMode'] = self.xml.get_element_text(lncel, './p[@name="nbIoTMode"]')
            count = self.xml.get_element_count(lncel, './p[@name="defaultLnRelGnbCellId"]')
            if count:
                defaultLnRelGnbCellId = self.xml.get_element_text(lncel, './p[@name="defaultLnRelGnbCellId"]')
                cellDict['defaultLnRelGnbCellId'] = int(defaultLnRelGnbCellId)
            cellDict = self.cell_ChBw_Earfcn('LN', cellDict['cellTechnology'], cellDict)
            cellDict = self.update_nbiot_cell_info('LN', cellDict['cellTechnology'], cellDict)
            cellDict['RF'] = self.cell_Map_Rmod_Ant(cellDict['lcrId'], 'L', None)
            cellDict['subCell'] = self.subCell.values()
            cellDict['channelgroup'] = self.subCell
            self.cell_list.append(cellDict)

    def cell_ChBw_Earfcn(self, profix, technology, cellDict):
        classDict = {'NR': 'com.nokia.srbts.nrbts:NRCELL_%s' % technology, 'LN': 'NOKLTE:LNCEL_%s' % technology}
        profixText = classDict['%s' % profix]
        try:
            cells = self.xml.get_elements(self.parser, './/managedObject[@class="%s"]' % profixText)
            for cell in cells:
                cell_id = str(cell.attrib["distName"].split('/')[-2].split('-')[-1])
                if cell_id == cellDict['cellId']:
                    count = self.xml.get_element_count(cell, './p[@name="actSuperCell"]')
                    count1 = self.xml.get_element_count(cell, './p[@name="actCombSuperCell"]')
                    actSuperCell = 'false'
                    actCombSuperCell = 'false'
                    if count:
                        actSuperCell = self.xml.get_element_text(cell, './p[@name="actSuperCell"]')
                    if count1:
                        actCombSuperCell = self.xml.get_element_text(cell, './p[@name="actCombSuperCell"]')
                    if str(actSuperCell) == 'true' or str(actCombSuperCell) == 'true':
                        cellDict['cellType'] = 'Supercell'
                        self.supercell[cell_id] = 'true'
                    if technology == 'TDD':
                        cellDict['tddFrameConf'] = self.xml.get_element_text(cell, './p[@name="tddFrameConf"]')
                        cellDict['tddSpecSubfConf'] = self.xml.get_element_text(cell, './p[@name="tddSpecSubfConf"]')
                        cellDict['chBw'] = self.xml.get_element_text(cell, './p[@name="chBw"]')
                        cellDict['dlMimoMode'] = self.xml.get_element_text(cell, './p[@name="dlMimoMode"]')
                        if profix == 'NR':
                            cellDict['earfcn'] = self.xml.get_element_text(cell, './p[@name="nrarfcn"]')
                        else:
                            cellDict['actMMimo'] = self.xml.get_element_text(cell, './p[@name="actMMimo"]')
                            cellDict['earfcn'] = self.xml.get_element_text(cell, './p[@name="earfcn"]')
                            cellDict['band'] = self.earfcn_convert_band(cellDict['earfcn'])
                            cellDict['freq'] = self.earfcn_convert_freq(cellDict['earfcn'])
                    else:
                        if profix == 'NR':
                            cellDict['chBwDl'] = self.xml.get_element_text(cell, './p[@name="chBwDl"]')
                            cellDict['chBwDl'] = self.xml.get_element_text(cell, './p[@name="chBwUl"]')
                            cellDict['earfcnDl'] = self.xml.get_element_text(cell, './p[@name="nrarfcnDl"]')
                            cellDict['earfcnUl'] = self.xml.get_element_text(cell, './p[@name="nrarfcnUl"]')
                        else:
                            cellDict['actMMimo'] = self.xml.get_element_text(cell, './p[@name="actMMimo"]')
                            cellDict['chBwDl'] = self.xml.get_element_text(cell, './p[@name="dlChBw"]')
                            cellDict['chBwDl'] = self.xml.get_element_text(cell, './p[@name="ulChBw"]')
                            cellDict['earfcnDl'] = self.xml.get_element_text(cell, './p[@name="earfcnDL"]')
                            cellDict['earfcn'] = cellDict['earfcnDl']
                            cellDict['earfcnUl'] = self.xml.get_element_text(cell, './p[@name="earfcnUL"]')
                            cellDict['band'] = self.earfcn_convert_band(cellDict['earfcnDl'])
                            cellDict['freq'] = self.earfcn_convert_freq(cellDict['earfcnDl'])
                            cellDict['dlMimoMode'] = self.xml.get_element_text(cell, './p[@name="dlMimoMode"]')
            return cellDict
        except Exception as e:
            print(e)

    def update_nbiot_cell_info(self, profix, technology, cellDict):
        nbiot_list = self.xml.get_elements(self.parser, './/managedObject[@class="NOKLTE:ANBIOTCARR"]')
        for nbiot in nbiot_list:
            cell_id = str(nbiot.attrib["distName"].split('/')[-4].split('-')[-1])
            if cellDict['cellId'] == cell_id:
                if 'TDD' in technology:
                    if profix == 'NR':
                        cellDict['earfcn'] = self.xml.get_element_text(nbiot, './p[@name="assignedNrarfcn"]')
                    if profix == 'LN':
                        cellDict['earfcn'] = self.xml.get_element_text(nbiot, './p[@name="assignedEarfcn"]')
                    cellDict['band'] = self.earfcn_convert_band(cellDict['earfcn'])
                if 'FDD' in technology:
                    if profix == 'NR':
                        cellDict['earfcnDl'] = self.xml.get_element_text(nbiot, './p[@name="assignedNrarfcnDL"]')
                        cellDict['earfcn'] = cellDict['earfcnDl']
                        cellDict['earfcnUl'] = self.xml.get_element_text(nbiot, './p[@name="assignedNrarfcnUL"]')
                    if profix == 'LN':
                        cellDict['earfcnDl'] = self.xml.get_element_text(nbiot, './p[@name="assignedEarfcnDL"]')
                        cellDict['earfcn'] = cellDict['earfcnDl']
                        cellDict['earfcnUl'] = self.xml.get_element_text(nbiot, './p[@name="assignedEarfcnUL"]')
                    cellDict['band'] = self.earfcn_convert_band(cellDict['earfcnDl'])
        return cellDict

    def nrcell_Group(self, cell_id):
        try:
            nrcell_gs = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]')
            for nrcell_g in nrcell_gs:
                grp_id = str(nrcell_g.attrib["distName"].split('/')[-1].split('-')[-1])
                celllist = self.xml.get_element(nrcell_g, './list[@name="nrCellList"]')
                for cell in celllist:
                    if str(cell_id) == cell.text:
                        return grp_id
        except Exception as e:
            print(e)

    def get_Nsa_Mapping(self):
        try:
            lnrelgnbcell = self.xml.get_elements(self.parser, './/managedObject[@class="NOKLTE:LNRELGNBCELL"]')
            for gnbcell in lnrelgnbcell:
                lncellid = str(gnbcell.attrib["distName"].split('/')[-2].split('-')[-1])
                nrcellIndex = str(gnbcell.attrib["distName"].split('/')[-1].split('-')[-1])
                nrCellId = self.xml.get_element_text(gnbcell, './p[@name="nrCellId"]')
                nrStatus = self.xml.get_element_text(gnbcell, './p[@name="nrStatus"]')
                for i in range(len(self.cell_list)):
                    if nrStatus == 'available' and lncellid == self.cell_list[i]['cellId']:
                        if "nrCellList" not in self.cell_list[i].keys():
                            self.cell_list[i]['nrCellList'] = []
                        self.cell_list[i]['nrCellList'].append((nrcellIndex, nrCellId))
                        break
        except Exception as e:
            print(e)

    def get_Rmod_Info(self):
        rmod_r = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]')
        for rmod in rmod_r:
            rmodDict = dict()
            count = self.xml.get_element_count(rmod, './p[@name="configDN"]')
            if count:
                rmodDict['rmodId'] = self.xml.get_element_text(rmod, './p[@name="configDN"]').split('-')[-1]
                rmodDict['serialNumber'] = self.xml.get_element_text(rmod, './p[@name="serialNumber"]')
                rmodDict['distName'] = self.xml.get_element_text(rmod, './p[@name="configDN"]')
                if rmodDict not in self.rmod_list:
                    self.rmod_list.append(rmodDict)
        print(self.rmod_list)

    def update_Rmod_Info(self):
        for i in range(len(self.rmod_list)):
            if self.rmod_list[i]['serialNumber'] in self.rmod_cell:
                self.rmod_list[i]['locatedCells'] = self.rmod_cell[self.rmod_list[i]['serialNumber']]

    def rmod_sn_info(self):
        rmod_r = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]')
        for rmod in rmod_r:
            try:
                rmod_index = self.xml.get_element_text(rmod, './p[@name="configDN"]').split('-')[-1]
                sn = self.xml.get_element_text(rmod, './p[@name="serialNumber"]')
                self.rmod_sn[rmod_index] = sn
            except Exception as ex:
                print(ex)
                pass

    def dict_chain(self, chain_dict, key, chain):
        if key not in chain_dict.keys():
            return chain
        else:
            if chain == '':
                chain = '%s->%s' % (key, chain_dict[key])
            else:
                chain = '%s->%s' % (chain, chain_dict[key])
            return self.dict_chain(chain_dict, chain_dict[key], chain)

    def rmod_chain_info(self):
        cablinks = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.eqm:CABLINK"]')
        chain_dict = {}
        first_rf = []
        self.rmod_sn_info()
        for cablink in cablinks:
            firstDN = self.xml.get_element_text(cablink, './p[@name="firstEndpointDN"]').split('/')[-1]
            secondDN = self.xml.get_element_text(cablink, './p[@name="secondEndpointDN"]').split('/')[-1]
            if 'RMOD' not in firstDN and 'RMOD' in secondDN:
                secondRMOD = secondDN.split('-')[-1]
                first_rf.append(self.rmod_sn[secondRMOD])
            if 'RMOD' in firstDN and 'RMOD' in secondDN:
                firstRMOD = firstDN.split('-')[-1]
                secondRMOD = secondDN.split('-')[-1]
                chain_dict[self.rmod_sn[firstRMOD]] = self.rmod_sn[secondRMOD]
        for sn in first_rf:
            self.rmod_chain.append(self.dict_chain(chain_dict, sn, ''))
        self.rmod_chain = list(set(self.rmod_chain))
        if '' in self.rmod_chain:
            self.rmod_chain.remove('')

    def cell_Map_Rmod_Ant(self, cell_id, postfix='NR', refRfList=None):
        rmods_ants_list = []
        channels = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.mnl:CHANNEL"]')
        sn_ant_dict = {}
        for channel in channels:
            cell_info = str(channel.attrib["distName"].split('/')[-3])
            channelt = str(channel.attrib["distName"].split('/')[-2])
            channel_id = channelt.split('-')[-1]
            if 'LCEL%s-%s' % (postfix, cell_id) == cell_info:
                antlDN = self.xml.get_elements(channel, './p[@name="antlDN"]')
                if not antlDN:
                    antlDN = self.xml.get_element_text(channel, './p[@name="resourceDN"]')
                    rmod_id = antlDN.split('/')[-2].split('-')[-1]
                    if refRfList:
                        if len(refRfList) == 1:
                            rmod_id = refRfList[0].split('/')[-1].split('-')[-1]
                    sn = self.get_Rmod_SerialNumber(rmod_id)
                    sn_ant_dict[sn] = ['1', '2']
                    if cell_id in self.supercell.keys():
                        self.get_sub_cell(channel_id, sn, '1')
                        self.get_sub_cell(channel_id, sn, '2')
                else:
                    ant_id = self.get_ant_port(antlDN[0].text)
                    rmod_id = antlDN[0].text.split('/')[-2].split('-')[-1]
                    if refRfList:
                        if len(refRfList) == 1:
                            rmod_id = refRfList[0].split('/')[-1].split('-')[-1]
                    sn = self.get_Rmod_SerialNumber(rmod_id)
                    if sn not in sn_ant_dict.keys():
                        sn_ant_dict[sn] = [ant_id]
                    else:
                        if ant_id not in sn_ant_dict[sn]:
                            sn_ant_dict[sn].append(ant_id)
                    if cell_id in self.supercell.keys():
                        self.get_sub_cell(channel_id, sn, ant_id)

                if sn not in self.rmod_cell.keys():
                    self.rmod_cell[sn] = [cell_id]
                else:
                    if cell_id not in self.rmod_cell[sn]:
                        self.rmod_cell[sn].append(cell_id)
        for sn, ant in sn_ant_dict.items():
            rmods_ants_list.append({'serialNumber': sn, 'antl': ant})
        return rmods_ants_list

    def get_sub_cell(self, channel_id, sn, ant):
        if channel_id not in self.subCell.keys():
            self.subCell[channel_id] = [{'antl': [ant], 'serialNumber': sn}]
        else:
            for ant_sn in self.subCell[channel_id]:
                if sn == ant_sn['serialNumber'] and ant not in ant_sn['antl']:
                    ant_sn['antl'].append(ant)
                    break

    def get_nbiot_map(self):
        for i in range(len(self.cell_list)):
            if 'nbIoTMode' in self.cell_list[i].keys():
                nbiot_phycell_list = []
                for cell in self.cell_list[i]['related_cell']:
                    for celldict in self.cell_list:
                        if str(cell) == str(celldict['cellId']):
                            nbiot_phycell_list.append(celldict['phyCellId'])
                            break
                self.cell_list[i]['related_cell'] = nbiot_phycell_list
        for i in range(len(self.cell_list)):
            if 'nbIoTMode' in self.cell_list[i].keys() and "NB-IoT" in self.cell_list[i]["cellTechnology"]:
                pci = self.cell_list[i]["phyCellId"]
                for cell in self.cell_list:
                    if pci == cell["phyCellId"] and "NB-IoT" not in cell["cellTechnology"]:
                        self.cell_list[i]["band"] = cell['band']

    def get_ca_map(self):
        nrrels = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.nrbts:NRREL"]')
        ca_cellId_dict = {}
        for nrrel in nrrels:
            nrrel_distName_master_cellId_list = []
            nrrel_distName_master_cellId = nrrel.attrib['distName'].split('/')[-2].split('-')[-1]
            slave_cellId = self.xml.get_element_text(nrrel, './p[@name="lcrId"]')
            phyid = 1
            for cell in self.cell_list:
                if cell['lcrId'] == slave_cellId:
                    phyid = cell['phyCellId']
            nrrel_distName_master_cellId_list.append(phyid)
            if nrrel_distName_master_cellId in ca_cellId_dict.keys():
                ca_cellId_dict[nrrel_distName_master_cellId].append(phyid)
            else:
                ca_cellId_dict[nrrel_distName_master_cellId] = nrrel_distName_master_cellId_list
        for cell in self.cell_list:
            ca_phycellId_list = []
            for key, value in ca_cellId_dict.items():
                if cell['lcrId'] == key:
                    ca_phycellId_list.append(value)
                    cell['CA_MAP'] = ca_phycellId_list

    def get_ant_port(self, antdist):
        ants = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.eqm:ANTL"]')
        for ant in ants:
            if str(antdist) == str(ant.attrib["distName"]):
                return self.xml.get_element_text(ant, './p[@name="antPortId"]')

    def get_Bbu_Info(self):
        self.smod_bbmod_sn('smod')
        self.smod_bbmod_sn('bbmod')

    def smod_bbmod_sn(self, profix='smod'):
        count = self.xml.get_element_count(self.parser,
                                           './/managedObject[@class="com.nokia.srbts.eqmr:%s_R"]' % (profix.upper()))
        if not count:
            return
        mods = self.xml.get_elements(self.parser,
                                     './/managedObject[@class="com.nokia.srbts.eqmr:%s_R"]' % (profix.upper()))
        for mod in mods:
            modDict = dict()
            count = self.xml.get_element_count(mod, './p[@name="serialNumber"]')
            if count:
                modDict['serialNumber'] = self.xml.get_element_text(mod, './p[@name="serialNumber"]')
            count = self.xml.get_element_count(mod, './p[@name="configDN"]')
            if count:
                modDict['%sId' % profix] = self.xml.get_element_text(mod, './p[@name="configDN"]').split('-')[-1]
            else:
                modDict['%sId' % profix] = str(mod.attrib["distName"]).split('-')[-1]
            count = self.xml.get_element_count(mod, './p[@name="horizontalPosition"]')
            if count:
                modDict['horizontalPosition'] = self.xml.get_element_text(mod, './p[@name="horizontalPosition"]')
            count = self.xml.get_element_count(mod, './p[@name="verticalPosition"]')
            if count:
                modDict['verticalPosition'] = self.xml.get_element_text(mod, './p[@name="verticalPosition"]')
            self.bbu_list.append(modDict)

    def get_Rmod_SerialNumber(self, rmod_id):
        for rmd in self.rmod_list:
            if str(rmod_id) == str(rmd['rmodId']):
                return rmd['serialNumber']

    def earfcn_convert_freq(self, earfcn):
        F_DL_LOW = {1: 2110, 2: 1930, 3: 1805, 4: 2110, 5: 869, 6: 875, 7: 2620, 8: 925, 9: 1844.9, 10: 2110,
                    11: 1475.9, 12: 729, 13: 746, 14: 758, 17: 734, 18: 860, 19: 875, 20: 791, 21: 1495.9,
                    22: 3510, 23: 2180, 24: 1525, 25: 1930, 26: 859, 27: 852, 28: 758, 29: 717, 33: 1900, 34: 2010,
                    35: 1850, 36: 1930, 37: 1910, 38: 2570, 39: 1880, 40: 2300, 41: 2496, 42: 3400, 43: 3600, 44: 703,
                    48: 3550, 66: 2110, 71: 617}
        N_DL_OFF = {1: 0, 2: 600, 3: 1200, 4: 1950, 5: 2400, 6: 2650, 7: 2750, 8: 3450, 9: 3800, 10: 4150, 11: 4750,
                    12: 5010, 13: 5180, 14: 5280, 17: 5730, 18: 5850, 19: 6000, 20: 6150, 21: 6450, 22: 6600, 23: 7500,
                    24: 7700, 25: 8040, 26: 8690, 27: 9040, 28: 9210, 29: 9660, 33: 36000, 34: 36200, 35: 36350,
                    36: 36950, 37: 37550, 38: 37750, 39: 38250, 40: 38650, 41: 39650, 42: 41590, 43: 43590, 44: 45590,
                    48: 55240, 66: 66436, 71: 68586}
        band = int(self.earfcn_convert_band(earfcn))
        freq = F_DL_LOW[band] + 0.1 * (float(earfcn) - N_DL_OFF[band])
        return freq

    def earfcn_convert_band(self, earfcn):
        earfcn_int = int(earfcn)
        # TDD
        if earfcn_int >= 36000 and earfcn_int <= 36199:
            return str(33)
        if earfcn_int >= 36200 and earfcn_int <= 36349:
            return str(34)
        if earfcn_int >= 36350 and earfcn_int <= 36949:
            return str(35)
        if earfcn_int >= 36950 and earfcn_int <= 37549:
            return str(36)
        if earfcn_int >= 37550 and earfcn_int <= 37749:
            return str(37)
        if earfcn_int >= 37750 and earfcn_int <= 38249:
            return str(38)
        if earfcn_int >= 38250 and earfcn_int <= 38649:
            return str(39)
        if earfcn_int >= 38650 and earfcn_int <= 39649:
            return str(40)
        if earfcn_int >= 39650 and earfcn_int <= 41589:
            return str(41)
        if earfcn_int >= 41590 and earfcn_int <= 43589:
            return str(42)
        if earfcn_int >= 43590 and earfcn_int <= 45589:
            return str(43)
        if earfcn_int >= 45590 and earfcn_int <= 46589:
            return str(44)
        if earfcn_int >= 55240 and earfcn_int <= 56739:
            return str(48)
        # FDD
        if earfcn_int >= 0 and earfcn_int <= 599:
            return str(1)
        if earfcn_int >= 600 and earfcn_int <= 1199:
            return str(2)
        if earfcn_int >= 1200 and earfcn_int <= 1949:
            return str(3)
        if earfcn_int >= 1950 and earfcn_int <= 2399:
            return str(4)
        if earfcn_int >= 2400 and earfcn_int <= 2649:
            return str(5)
        if earfcn_int >= 2650 and earfcn_int <= 2749:
            return str(6)
        if earfcn_int >= 2750 and earfcn_int <= 3449:
            return str(7)
        if earfcn_int >= 3450 and earfcn_int <= 3799:
            return str(8)
        if earfcn_int >= 3800 and earfcn_int <= 4149:
            return str(9)
        if earfcn_int >= 4150 and earfcn_int <= 4749:
            return str(10)
        if earfcn_int >= 4750 and earfcn_int <= 4949:
            return str(11)
        if earfcn_int >= 5010 and earfcn_int <= 5179:
            return str(12)
        if earfcn_int >= 5180 and earfcn_int <= 5279:
            return str(13)
        if earfcn_int >= 5280 and earfcn_int <= 5379:
            return str(14)
        if earfcn_int >= 5730 and earfcn_int <= 5849:
            return str(17)
        if earfcn_int >= 5850 and earfcn_int <= 5999:
            return str(18)
        if earfcn_int >= 6000 and earfcn_int <= 6149:
            return str(19)
        if earfcn_int >= 6150 and earfcn_int <= 6449:
            return str(20)
        if earfcn_int >= 6450 and earfcn_int <= 6599:
            return str(21)
        if earfcn_int >= 6600 and earfcn_int <= 7399:
            return str(22)
        if earfcn_int >= 7500 and earfcn_int <= 7699:
            return str(23)
        if earfcn_int >= 7700 and earfcn_int <= 8039:
            return str(24)
        if earfcn_int >= 8040 and earfcn_int <= 8689:
            return str(25)
        if earfcn_int >= 8690 and earfcn_int <= 9039:
            return str(26)
        if earfcn_int >= 9210 and earfcn_int <= 9559:
            return str(28)
        if earfcn_int >= 9660 and earfcn_int <= 9769:
            return str(29)
        if earfcn_int >= 66436 and earfcn_int <= 67335:
            return str(66)
        if earfcn_int >= 68586 and earfcn_int <= 68935:
            return str(71)


def btsInfo(scfc):
    site = site_Info(scfc)
    site.get_Bbu_Info()
    site.get_Rmod_Info()
    site.get_Nrcel_Info()
    site.get_Lncel_Info()
    site.get_nbiot_map()
    site.get_ca_map()
    site.update_Rmod_Info()
    site.get_Nsa_Mapping()
    site.rmod_chain_info()
    return site.bbu_list, site.rmod_list, site.cell_list, site.rmod_chain


def channelGroup(scfc):
    channelgroup = site_Info(scfc)
    channelgroup.get_Nr_Channelgroup_Info()
    nr_channelgroup_list_merge = []
    nr_channelgroup_merge = ""
    for nr_channelgroup in channelgroup.nr_channelgroup_list:
        nr_channelgroup_merge += nr_channelgroup['distName']
    nr_channelgroup_list_merge.append(nr_channelgroup_merge)
    return nr_channelgroup_list_merge


def update_nsa_anchor_cell(*args):
    anchor_4G = []
    anchor_5G = []
    for bts in args:
        for cell in bts:
            if cell['NetworkType'] == '4G':
                if 'defaultLnRelGnbCellId' in cell.keys():
                    defaultLnRelGnbCellId = cell["defaultLnRelGnbCellId"]
                    if 'nrCellList' in cell.keys() and cell["nrCellList"] != []:
                        for nrcelllist in cell["nrCellList"]:
                            if str(nrcelllist[0]) == str(defaultLnRelGnbCellId):
                                cell["nrCellId"] = nrcelllist[1]
                                break
                    anchor_4G.append(cell)
            elif cell['NetworkType'] == 'NSA':
                anchor_5G.append(cell)
                if "related_cell" not in cell.keys():
                    cell["related_cell"] = []
                else:
                    del cell["related_cell"][:]
    for cell4g in anchor_4G:
        for cell5g in anchor_5G:
            if 'nrCellId' in cell5g.keys() and 'nrCellId' in cell4g.keys():
                if cell5g['nrCellId'] == cell4g['nrCellId']:
                    cell5g["related_cell"].append(cell4g['phyCellId'])
                    if cell4g['cellTechnology'] == 'TDD':
                        cell5g['anchor'] = {'phyCellId': cell4g['phyCellId'], 'earfcn': cell4g['earfcn']}
                    else:
                        cell5g['anchor'] = {'phyCellId': cell4g['phyCellId'], 'earfcnDl': cell4g['earfcnDl']}
    return args


def random_selected_cells(cell_basic_info):
    total_cells = len(cell_basic_info)
    random_cells = cell_basic_info.keys()
    if total_cells >= 6:
        random_cells = random.sample(cell_basic_info.keys(), int(math.ceil(float(total_cells) / 2)))
    subcells = 0
    selected_attach_cells = {}
    attach_cells = {}
    for cell, value in cell_basic_info.items():
        cell_type = value['cell_type']
        if cell_type == 'supercell' and cell in random_cells:
            subcells = subcells + len(value['subcell'])
            selected_attach_cells[cell] = random.sample(value['subcell'],
                                                        int(math.ceil(float(len(value['subcell']) / 2))))
            attach_cells[cell] = value['subcell']
    if subcells <= 6:
        selected_attach_cells = attach_cells
    return random_cells, selected_attach_cells


def random_selected_frs(rmod_chain, rmod_cell):
    total_frs = len(rmod_cell)
    if total_frs >= 6:
        if len(rmod_chain) > 0:
            rmod = []
            for chain in rmod_chain:
                chain_rmods = chain.split('->')
                rmod.extend(random.sample(chain_rmods, int(math.ceil(float(len(chain_rmods)) / 2))))
            return rmod
        else:
            return random.sample(rmod_cell.keys(), int(math.ceil(float(total_frs) / 2)))
    return list(rmod_cell.keys())


def merge_list(dst_list, src_list):
    for value in src_list:
        if value not in dst_list:
            dst_list.append(value)


def merge_dict(dst_dict, src_dict):
    for key in src_dict.keys():
        if len(src_dict[key]) == 0:
            continue
        if key in dst_dict.keys():
            merge_list(dst_dict[key], src_dict[key])
        else:
            dst_dict[key] = []
            dst_dict[key].extend(src_dict[key])


def get_no_used_RF_List(node, used_RF_list):
    resource_ids = []
    un_used_rf_list = []
    TLs = ["TL1", "TL2"]
    for tl_id in TLs:
        if tl_id in node.keys():
            if "FR" not in node[tl_id].keys():
                continue
            tl = node[tl_id]["FR"]
            for rf in used_RF_list:
                if rf in tl.keys():
                    if "resource_id" in tl[rf].keys():
                        resource_ids.append(tl[rf]["resource_id"])

    for tl_id in TLs:
        if tl_id in node.keys():
            if "FR" not in node[tl_id].keys():
                continue
            tl = node[tl_id]["FR"]
            for rf_id in tl.keys():
                if rf_id in used_RF_list:
                    continue
                if "resource_id" not in tl[rf_id].keys():
                    un_used_rf_list.append(rf_id)
                elif tl[rf_id]["resource_id"] in resource_ids:
                    un_used_rf_list.append(rf_id)
    return un_used_rf_list


def get_no_used_SM_list(node, sm_list):
    un_used_sm_list = []
    TLs = ["TL1", "TL2"]
    for tl_id in TLs:
        if tl_id in node.keys():
            if "FSM" not in node[tl_id].keys():
                continue
            tl = node[tl_id]["FSM"]
            for SM in tl.keys():
                if SM not in sm_list:
                    un_used_sm_list.append(SM)

    return un_used_sm_list


def get_current_topo(cablinks, rmod, bbmod, smod, fsh=[]):
    # BBMOD(port)<->RMOD(port)
    topo_dict = {}
    rmod_dict = {}
    bbmod_dict = {}
    smod_dict = {}
    fsh_dict = {}
    source = ''
    dst = ''
    for rd in rmod:
        rmod_dict[rd['distName']] = rd['parameters']['serialNumber']
    for bd in bbmod:
        bbmod_dict[bd['distName']] = bd['parameters']['serialNumber']
    for sd in smod:
        smod_dict[sd['distName']] = sd['parameters']['serialNumber']
    for fs in fsh:
        fsh_dict[fs['distName']] = fs['parameters']['serialNumber']

    for cablnk in cablinks:
        sourceDistName = cablnk['parameters']['secondEndpointDN']
        sourcePort = int(cablnk['parameters']['secondEndpointPortId'])
        destinationDistName = cablnk['parameters']['firstEndpointDN']
        destPort = int(cablnk['parameters']['firstEndpointPortId'])
        linkModeConfiguration = cablnk['parameters']['linkModeConfiguration']
        linkModeData = cablnk['parameters']['linkModeData']
        cablinkType = cablnk['parameters']['cablinkType']
        linkSpeed = cablnk['parameters']['linkSpeed']
        if cablinkType:
            if sourceDistName in rmod_dict.keys():
                source = '%s:%s(%s)' % (sourceDistName.split('/')[-1], rmod_dict[sourceDistName], sourcePort)
            if sourceDistName in fsh_dict.keys():
                source = '%s:%s(%s)' % (sourceDistName.split('/')[-1], fsh_dict[sourceDistName], sourcePort)
            if destinationDistName in rmod_dict.keys():
                dst = '%s:%s(%s)' % (destinationDistName.split('/')[-1], rmod_dict[destinationDistName], destPort)
            if destinationDistName in smod_dict.keys():
                dst = '%s:%s(%s)' % (destinationDistName.split('/')[-1], smod_dict[destinationDistName], destPort)
            if destinationDistName in bbmod_dict.keys():
                dst = '%s:%s(%s)' % (destinationDistName.split('/')[-1], bbmod_dict[destinationDistName], destPort)
            if destinationDistName in fsh_dict.keys():
                dst = '%s:%s(%s)' % (destinationDistName.split('/')[-1], fsh_dict[destinationDistName], destPort)
            topo_dict['%s<->%s' % (source, dst)] = {'linkModeConfiguration': linkModeConfiguration,
                                                    'linkModeData': linkModeData, 'linkSpeed': linkSpeed}
    return topo_dict


def get_selected_link(topo, ggmap, filters='L1202407672', link='primary'):
    # filters=sn , link=primary | secondary
    for stopo in topo.keys():
        source = stopo.split('<->')[0]
        dst = stopo.split('<->')[1]
        linktype = 'secondary'
        print(str(topo[stopo]['linkModeConfiguration']))
        if str(topo[stopo]['linkModeConfiguration']) == 'True':
            linktype = 'primary'
        sourcesn = source.split('(')[0].split(':')[-1]
        sport = source.split('(')[-1].replace(')', '')
        dport = dst.split('(')[-1].replace(')', '')
        dstsn = dst.split('(')[0].split(':')[-1]
        if filters in source and link in linktype:
            if sourcesn in ggmap.keys() and sport in ggmap[sourcesn].keys():
                if ':' in ggmap[sourcesn][sport]:
                    return ggmap[sourcesn][sport], link
                else:
                    print('Selected link(%s=> %s : %s)' % (linktype, stopo,
                                                           '%s:%s' % (ggmap[sourcesn][sport], ggmap[dstsn][dport])))
                    return '%s:%s' % (ggmap[sourcesn][sport], ggmap[dstsn][dport]), str(topo[stopo]['linkSpeed'])
        if filters in dst and link in linktype:
            if dstsn in ggmap.keys() and dport in ggmap[dstsn].keys():
                if ':' in ggmap[dstsn][dport]:
                    return ggmap[dstsn][dport], link
                else:
                    print('Selected link(%s=> %s : %s)' % (linktype, stopo,
                                                           '%s:%s' % (ggmap[dstsn][dport], ggmap[sourcesn][sport])))
                    return '%s:%s' % (ggmap[dstsn][dport], ggmap[sourcesn][sport]), str(topo[stopo]['linkSpeed'])


def get_rf_link_with_link_type(link_config, rf_ser_num, link_type):
    pattern = r"RMOD_R-\d+?:{}\((\d+)\)<->BBMOD_R-\d+?:([\w|\d]+)\((\d+)\)".format(rf_ser_num)
    link_list = []

    for key in link_config.keys():
        result = re.search(pattern, key)
        if not result:
            continue
        print("{}:{}:{}".format(result.groups()[0], result.groups()[1], result.groups()[2]))
        param = link_config[key]
        if link_type == "primary" and param["linkModeConfiguration"]:
            link_list.append([rf_ser_num, result.groups()[0], result.groups()[1], result.groups()[2]])
        elif link_type == "data" and not param["linkModeConfiguration"]:
            link_list.append([rf_ser_num, result.groups()[0], result.groups()[1], result.groups()[2]])

    return link_list


def get_exchange_fw_link(ggmap, link_list_rf1, link_list_rf2):
    rf1 = link_list_rf1[0]
    rf2 = link_list_rf2[0]
    a = "{}:{};{}:{}".format(ggmap[rf1[0]][rf1[1]], ggmap[rf2[2]][rf2[3]],
                             ggmap[rf2[0]][rf2[1]], ggmap[rf1[2]][rf1[3]])
    b = "{}:{};{}:{}".format(ggmap[rf1[0]][rf1[1]], ggmap[rf1[2]][rf1[3]],
                             ggmap[rf2[0]][rf2[1]], ggmap[rf2[2]][rf2[3]])
    return a, b


def get_breaked_link_list(topo, ggmap, filters='L1202407672'):
    break_GG_list = []
    for stopo in topo.keys():
        source = stopo.split('<->')[0]
        dst = stopo.split('<->')[1]
        sourcesn = source.split('(')[0].split(':')[-1]
        sport = source.split('(')[-1].replace(')', '')
        dport = dst.split('(')[-1].replace(')', '')
        dstsn = dst.split('(')[0].split(':')[-1]
        if filters in source:
            if ':' in ggmap[sourcesn][sport]:
                return ggmap[sourcesn][sport],
            else:
                print('Selected link(%s : %s)' % (stopo, '%s:%s' % (ggmap[sourcesn][sport], ggmap[dstsn][dport])))
                temp = '%s:%s' % (ggmap[sourcesn][sport], ggmap[dstsn][dport])
                break_GG_list.append(temp)
        if filters in dst:
            if ':' in ggmap[dstsn][dport]:
                return ggmap[dstsn][dport],
            else:
                print('Selected link(%s : %s)' % (stopo, '%s:%s' % (ggmap[sourcesn][sport], ggmap[dstsn][dport])))
                temp = '%s:%s' % (ggmap[sourcesn][sport], ggmap[dstsn][dport])
                break_GG_list.append(temp)
    return break_GG_list


def get_connect_link_list(topo, ggmap, rfgroup, filters='L1202407672'):
    connect_GG_list = []
    for stopo in topo.keys():
        source = stopo.split('<->')[0]
        dst = stopo.split('<->')[1]
        sourcesn = source.split('(')[0].split(':')[-1]
        if sourcesn in rfgroup.keys():
            newsourcesn = rfgroup[sourcesn]
        sport = source.split('(')[-1].replace(')', '')
        dport = dst.split('(')[-1].replace(')', '')
        dstsn = dst.split('(')[0].split(':')[-1]
        if dstsn in rfgroup.keys():
            newdetsn = rfgroup[dstsn]
        if filters in source:
            if ':' in ggmap[sourcesn][sport]:
                return ggmap[sourcesn][sport]
            else:
                print('Selected link(%s : %s)' % (stopo, '%s:%s' % (ggmap[sourcesn][sport], ggmap[dstsn][dport])))
                print('replace port %s=> %s' % (ggmap[sourcesn][sport], ggmap[newsourcesn][sport]))
                temp = '%s:%s' % (ggmap[newsourcesn][sport], ggmap[dstsn][dport])
                connect_GG_list.append(temp)
        if filters in dst:
            if ':' in ggmap[dstsn][dport]:
                return ggmap[dstsn][dport]
            else:
                print('Selected link(%s : %s)' % (stopo, '%s:%s' % (ggmap[sourcesn][sport], ggmap[dstsn][dport])))
                print('replace port %s=> %s' % (ggmap[dstsn][dport], ggmap[newdetsn][dport]))
                temp = '%s:%s' % (ggmap[sourcesn][sport], ggmap[newdetsn][dport])
                connect_GG_list.append(temp)
    return connect_GG_list


def add_items_to_dict(key, value, indict):
    if key in indict.keys():
        tmp_list = indict[key]
        tmp_list.append(value)
        indict[key] = tmp_list
    else:
        indict[key] = [value]
    return indict


def get_rmod_l_sn_mapping(rmods_list):
    rmod_sn = {}
    for rmod_info in rmods_list:
        rmod_index = rmod_info['dist_name'].split('/')[-1]
        rmod_sn[rmod_index] = rmod_info['serialNumber']
    return rmod_sn


def get_cell_allocated_board(bbpools):
    cells_allocation = {}
    for bbpool in bbpools:
        assignedLCellsDNs = bbpool['assignedLCellsDNs']
        dspDNs = bbpool['dspsDNs']
        board = dspDNs[0].split('/')[6]
        for cells in assignedLCellsDNs:
            cell = cells.split('-')[-1]
            if cell in cells_allocation.keys():
                cells_list = cells_allocation[cell]
                if board not in cells_list:
                    cells_list.append(board)
                cells_allocation[cell] = cells_list
            else:
                cells_allocation[cell] = [board]
    return cells_allocation


def get_pre_install_fiber(current_topo, rmod_sn, cell_board, cell_rmod):
    pre_install_link = current_topo
    for cell in cell_rmod.keys():
        rmod_l = cell_rmod[cell]
        boards = cell_board[cell]
        rmod_l_sn = rmod_sn['RMOD_L-%s' % rmod_l]
        links_list = pre_install_link[rmod_l_sn]
        tmp_list = []
        for board in boards:
            for link in links_list:
                if board not in link:
                    tmp_list.append(link)
        pre_install_link[rmod_l_sn] = tmp_list
    return pre_install_link


def get_random_links(pre_install_link, num):
    total_preinstall_links = []
    radom_preinstall_links = {}

    for key, value in pre_install_link.items():
        total_preinstall_links.extend(value)

    random_links = random.sample(total_preinstall_links, int(num))
    print(random_links)

    for key, value in pre_install_link.items():
        for link in value:
            if link in random_links:
                if key not in radom_preinstall_links.keys():
                    radom_preinstall_links[key] = [link]
                else:
                    tmp_list = radom_preinstall_links[key]
                    tmp_list.append(link)
                    radom_preinstall_links


def get_sfp_info(scfc_path, sfp_type):
    xml = XML()
    parser = xml.parse_xml(scfc_path)
    sfp_info_list = xml.get_elements(parser, './/managedObject[@class="com.nokia.srbts.eqm:SFP"]')

    sfp_info = []
    for sfp in sfp_info_list:
        hw_port_id = xml.get_element_text(sfp, './p[@name="hwPortId"]')

        if len(hw_port_id) != 0:
            sfp_dist_name = sfp.attrib["distName"]
            hw_name = sfp_dist_name.split('/')[-2]
            lane_info_list = xml.get_elements(parser, './/managedObject[@class="com.nokia.srbts.eqm:LANE"]')
            lane_r_info_list = xml.get_elements(parser, './/managedObject[@class="com.nokia.srbts.eqmr:LANE_R"]')

            for lane in lane_info_list:
                dist_name = lane.attrib["distName"]
                for lane_r_info in lane_r_info_list:
                    attrs = xml.get_elements(lane_r_info, './p')
                    for attr in attrs:
                        if attr.attrib["name"] == "configDN":
                            config_dn = xml.get_element_text(lane_r_info, './p[@name="configDN"]')
                            if config_dn == dist_name:
                                operational_state = xml.get_element_text(lane_r_info, './p[@name="operationalState"]')
                                if operational_state == "enabled" and sfp_dist_name in dist_name:
                                    lane_id = dist_name.split("/")[-1]
                                    sfp_info.append([hw_name, hw_port_id, lane_id, dist_name])
    return sfp_info
