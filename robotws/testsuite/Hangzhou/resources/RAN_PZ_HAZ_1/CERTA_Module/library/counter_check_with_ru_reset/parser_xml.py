# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function
from robot.libraries.XML import XML


class SiteInfo(object):
    def __init__(self, scfc):
        self.rmod_cell = {}
        self.cell_list = []
        self.xml = XML()
        self.parser = self.xml.parse_xml(scfc)

    def get_ru_of_cell(self, cell_distname_id):
        for cell_info in self.cell_list:
            if cell_info['distName'].split('/')[-1] == cell_distname_id:
                ru_distname_list = [rf['distName'] for rf in cell_info['RF']]
                return ru_distname_list, cell_info

    def get_cells_for_same_ru(self, cell_distname_id):
        ru_distname_list, cell_info = self.get_ru_of_cell(cell_distname_id)
        cells_for_same_ru = []
        for cell_info in self.cell_list:
            if cell_info['distName'].split('/')[-1] != cell_distname_id:
                for rf in cell_info['RF']:
                    if rf['distName'] in ru_distname_list:
                        cells_for_same_ru.append(cell_info['distName'])
        return cells_for_same_ru

    def get_cell_info(self, cell_distname_id):
        ru_distname_list = []
        rf_list = []
        for cell_info in self.cell_list:
            if cell_info['distName'].split('/')[-1] == cell_distname_id:
                rf_list = cell_info['RF']
                ru_distname_list = [rf['distName'] for rf in cell_info['RF']]
        other_cells = []
        for cell_info in self.cell_list:
            if cell_info['distName'].split('/')[-1] != cell_distname_id:
                for rf in cell_info['RF']:
                    if rf['distName'] in ru_distname_list:
                        other_cells.append(cell_info['distName'])
        return ru_distname_list, other_cells, rf_list

    def get_nrcel_info(self):
        try:
            nrcells = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
            for nrcell in nrcells:
                cellDict = {}
                distName = nrcell.attrib["distName"]
                cellDict['distName'] = distName
                cellDict['cellId'] = str(distName.split('/')[-1].split('-')[-1])
                cellDict['lcrId'] = self.xml.get_element_text(nrcell, './p[@name="lcrId"]')
                cellDict['band'] = self.xml.get_element_text(nrcell, './p[@name="freqBandIndicatorNR"]')
                cellDict['phyCellId'] = self.xml.get_element_text(nrcell, './p[@name="physCellId"]')
                rfRefList = self.xml.get_element(nrcell, './list[@name="frRefList"]')
                rfmod = []
                for rfRef in rfRefList:
                    rfmod.append(rfRef.text)
                print(cellDict['cellId'])
                print(rfmod)
                cellDict['RF'] = self.cell_Map_Rmod_Ant(cellDict['lcrId'], 'NR', rfmod)
                self.cell_list.append(cellDict)
        except Exception as e:
            print(e)

    def get_lncel_info(self):
        lncel_list = self.xml.get_elements(self.parser, './/managedObject[@class="NOKLTE:LNCEL"]')
        for lncel in lncel_list:
            cellDict = {}
            distName = lncel.attrib["distName"]
            cellDict['distName'] = distName
            cellDict['cellId'] = str(distName.split('-')[-1])
            cellDict['lcrId'] = self.xml.get_element_text(lncel, './p[@name="lcrId"]')
            cellDict['eutraCelId'] = self.xml.get_element_text(lncel, './p[@name="eutraCelId"]')
            cellDict['phyCellId'] = self.xml.get_element_text(lncel, './p[@name="phyCellId"]')
            cellDict['cellTechnology'] = self.xml.get_element_text(lncel, './p[@name="cellTechnology"]')
            cellDict = self.cell_ChBw_Earfcn('LN', cellDict['cellTechnology'], cellDict)
            cellDict['RF'] = self.cell_Map_Rmod_Ant(cellDict['lcrId'], 'L', None)
            self.cell_list.append(cellDict)

    def cell_ChBw_Earfcn(self, profix, technology, cellDict):
        classDict = {'NR': 'com.nokia.srbts.nrbts:NRCELL_%s' % technology, 'LN': 'NOKLTE:LNCEL_%s' % technology}
        profixText = classDict['%s' % profix]
        try:
            cells = self.xml.get_elements(self.parser, './/managedObject[@class="%s"]' % profixText)
            for cell in cells:
                cell_id = str(cell.attrib["distName"].split('/')[-2].split('-')[-1])
                if cell_id == cellDict['cellId']:
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
                            # cellDict['band'] = self.earfcn_convert_band(cellDict['earfcn'])
                            # cellDict['freq'] = self.earfcn_convert_freq(cellDict['earfcn'])
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
                            # cellDict['band'] = self.earfcn_convert_band(cellDict['earfcnDl'])
                            # cellDict['freq'] = self.earfcn_convert_freq(cellDict['earfcnDl'])
                            cellDict['dlMimoMode'] = self.xml.get_element_text(cell, './p[@name="dlMimoMode"]')
            return cellDict
        except Exception as e:
            print(e)

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
                    rmod_distname_id = antlDN.split('/')[-2]
                    if refRfList:
                        if len(refRfList) == 1:
                            rmod_distname_id = refRfList[0]
                    sn = self.get_rmod_sn(rmod_distname_id)
                    sn_ant_dict[sn] = {'antl': ['1', '2'], 'distName': rmod_distname_id}
                    # if cell_id in self.supercell.keys():
                    #     self.get_sub_cell(channel_id, sn, '1')
                    #     self.get_sub_cell(channel_id, sn, '2')
                else:
                    ant_id = self.get_ant_port(antlDN[0].text)
                    rmod_distname_id = antlDN[0].text.split('/')[-2]
                    if refRfList:
                        if len(refRfList) == 1:
                            rmod_distname_id = refRfList[0]
                    sn = self.get_rmod_sn(rmod_distname_id)
                    if sn not in sn_ant_dict.keys():
                        sn_ant_dict[sn] = {'antl': [ant_id], 'distName': rmod_distname_id}
                    else:
                        if ant_id not in sn_ant_dict[sn]:
                            sn_ant_dict[sn]['antl'].append(ant_id)
                    # if cell_id in self.supercell.keys():
                    #     self.get_sub_cell(channel_id, sn, ant_id)

                if sn not in self.rmod_cell.keys():
                    self.rmod_cell[sn] = [cell_id]
                else:
                    if cell_id not in self.rmod_cell[sn]:
                        self.rmod_cell[sn].append(cell_id)

        for sn, ant in sn_ant_dict.items():
            ant.update({'serialNumber': sn})
            rmods_ants_list.append(ant)
        return rmods_ants_list

    def get_rmod_sn(self, distname_id):
        rmod_r_list = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]')
        for rmod_r in rmod_r_list:
            configDN = self.xml.get_element_text(rmod_r, './p[@name="configDN"]')
            if configDN == distname_id:
                return self.xml.get_element_text(rmod_r, './p[@name="serialNumber"]')

    def get_ant_port(self, antdist):
        ants = self.xml.get_elements(self.parser, './/managedObject[@class="com.nokia.srbts.eqm:ANTL"]')
        for ant in ants:
            if str(antdist) == str(ant.attrib["distName"]):
                return self.xml.get_element_text(ant, './p[@name="antPortId"]')


def get_cells_info(scfc):
    site = SiteInfo(scfc)
    site.get_nrcel_info()
    site.get_lncel_info()
    return site.cell_list


def get_cell_bar_for_same_ru(product_type, cell_info, cell_list):
    cell_bar = []
    ru_distname = []
    for rf in cell_info["RF"]:
        ru_distname.append(rf["distName"])
    for cell in cell_list:
        if cell["distName"] != cell_info["distName"]:
            for rf in cell["RF"]:
                if rf["distName"] in ru_distname:
                    if product_type == "enb":
                        cell_bar.append("{}/SIB-0".format(cell["distName"]))
                    else:
                        cell_bar.append(cell["distName"])
                    break
    return cell_bar


def get_attention_with_rf(tl_description_path, serial_num, pipes):
    rfs = {"serial_num": serial_num, "pipes": pipes, "att": {}}
    pa_list = []
    for pipe in pipes:
        expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Port'. \
            format(serial_num, pipe)
        os_att_port_id = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                                           expression=expression)
        if not os_att_port_id:
            continue
        os_att_port_id = os_att_port_id[0]
        expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Number'. \
            format(serial_num, pipe)
        os_att_number_id = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                                             expression=expression)[0]

        expression = '//Unit[@Type="ATT"][@Number="{}"]/Attenuator/@IP'. \
            format(os_att_number_id)
        ip = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                               expression=expression)[0]

        expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Enable'. \
            format(serial_num, pipe)
        os_att_enable = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                                          expression=expression)[0]
        expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Disable'. \
            format(serial_num, pipe)

        os_att_disable = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                                           expression=expression)[0]

        if os_att_number_id not in rfs["att"].keys():
            rfs["att"][os_att_number_id] = {}
            rfs["att"][os_att_number_id]["ports"] = []
            rfs["att"][os_att_number_id]["port_id_list"] = []
            pa_list.append(ip)
        if os_att_port_id in rfs["att"][os_att_number_id]["port_id_list"]:
            continue
        rfs["att"][os_att_number_id]["port_id_list"].append(os_att_port_id)
        rfs["att"][os_att_number_id]["ports"].append({"port": os_att_port_id, "enable": os_att_enable,
                                                      "disable": os_att_disable})
    return rfs, pa_list


if __name__ == "__main__":
    pass
