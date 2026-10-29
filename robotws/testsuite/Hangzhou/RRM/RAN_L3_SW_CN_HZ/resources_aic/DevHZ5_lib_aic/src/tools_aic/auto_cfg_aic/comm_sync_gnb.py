# -*- coding: utf-8 -*-

"""
:author:     eric.jiang
:contact:    eric.jiang@nokia-sbell.com
:maintainer: eric.jiang@nokia-sbell.com
"""

import re
from lxml.objectify import parse as PARSE
from collections import OrderedDict


class Real_GNB_AIC(object):
    def __init__(self, cu_scfc_path, du_scfc_path, du2_scfc_path=None, du3_scfc_path=None, du4_scfc_path=None):
        self.cu_scfc_path = cu_scfc_path
        self.cu_scfc = PARSE(self.cu_scfc_path)

        self.du_scfc_path = du_scfc_path
        self.du_scfc = PARSE(self.du_scfc_path)

        self.du2_scfc_path = du2_scfc_path
        if self.du2_scfc_path is not None:
            self.du2_scfc = PARSE(self.du2_scfc_path)
        else:
            self.du2_scfc = None

        self.du3_scfc_path = du3_scfc_path
        if self.du3_scfc_path is not None:
            self.du3_scfc = PARSE(self.du3_scfc_path)
        else:
            self.du3_scfc = None

        self.du4_scfc_path = du4_scfc_path
        if self.du4_scfc_path is not None:
            self.du4_scfc = PARSE(self.du4_scfc_path)
        else:
            self.du4_scfc = None

        self.__get_plmn_aic()
        self.__get_gnb_id_aic()
        self.__get_cells_info_aic()
        self.__get_gscn_aic()

    def __get_plmn_aic(self):
        mcc = self.cu_scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/ns:p[@name="mcc"]/text()',
                                 namespaces={"ns": "raml21.xsd"})
        mnc = self.cu_scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/ns:p[@name="mnc"]/text()',
                                 namespaces={"ns": "raml21.xsd"})
        self.plmn = "%d:%02d" % (int(mcc[0]), int(mnc[0]))

    def __get_gnb_id_aic(self):
        ret1 = self.cu_scfc.xpath('//ns:managedObject[starts-with(@class,"com.nokia.srbts.nrbts:NRBTS")]/@distName',
                                  namespaces={"ns": "raml21.xsd"})
        ret2 = self.cu_scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/'
                                  'ns:p[@name="gNbIdLength"]/text()', namespaces={"ns": "raml21.xsd"})
        bts_id = '0x{0:02X}'.format(int(re.search(r"NRBTS-(\d+)", ret1[0]).group(1)))
        length = ret2[0]
        self.gnb_id = "%s:%s" % (bts_id, length)

    def __get_cells_info_aic(self):
        self.cells_info = {}

        cells_distname = self.cu_scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/@distName',
                                            namespaces={"ns": "raml21.xsd"})

        own_fdd_nrarfcn = self.cu_scfc.xpath(
            './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL_FDD" ]/'
            'ns:p[@name="nrarfcnDl"]/../@distName',
            namespaces={"ns": "raml21.xsd"})

        own_fdd_nrarfcn_distname = []
        for i in own_fdd_nrarfcn:
            distname = "/".join(i.split("/")[:-1])
            own_fdd_nrarfcn_distname.append(distname)

        for i in cells_distname:
            lcrId = self.cu_scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="lcrId"]/text()' % i,
                namespaces={"ns": "raml21.xsd"})[0]
            self.cells_info[lcrId] = OrderedDict()
            self.cells_info[lcrId]["lcrid"] = lcrId
            self.cells_info[lcrId]["distname"] = i

            pci = self.cu_scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="physCellId"]/text()' % i,
                namespaces={"ns": "raml21.xsd"})[0]
            self.cells_info[lcrId]["pci"] = pci

            ret = self.cu_scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="trackingAreaDN"]/text()' % i,
                namespaces={"ns": "raml21.xsd"})
            if ret != []:
                traceing_area = ret[0]
                ret1 = self.cu_scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA" and '
                                          '@distName="%s"]/ns:p[@name="fiveGsTac"]/text()' % traceing_area,
                                          namespaces={"ns": "raml21.xsd"})
                if ret1 != []:
                    tac = ret1[0]
            else:
                ret1 = self.cu_scfc.xpath(
                    './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRPLMNSET_NSA" and '
                    'starts-with(@distName,"%s/NRPLMNSET_NSA")]/ns:p[@name="trackingAreaDN"]/text()' % i,
                    namespaces={"ns": "raml21.xsd"})
                ret2 = self.cu_scfc.xpath(
                    './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRPLMNSET_SA" and '
                    'starts-with(@distName,"%s/NRPLMNSET_SA")]/ns:p[@name="trackingAreaDN"]/text()' % i,
                    namespaces={"ns": "raml21.xsd"})
                if ret1 != [] and ret2 == []:
                    traceing_area = ret1[0]
                elif ret1 == [] and ret2 != []:
                    traceing_area = ret2[0]
                if 'traceing_area' in dir():
                    ret3 = self.cu_scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA" and '
                                              '@distName="%s"]/ns:p[@name="fiveGsTac"]/text()' % traceing_area,
                                              namespaces={"ns": "raml21.xsd"})
                    if ret3 != []:
                        tac = ret3[0]
            if 'tac' in dir():
                self.cells_info[lcrId]["tac"] = tac

            own_tdd_nrarfcn = self.cu_scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="nrarfcn"]/text()' % i,
                namespaces={"ns": "raml21.xsd"})

            if own_tdd_nrarfcn != [] and i not in own_fdd_nrarfcn_distname:
                tdd_nrarfcn = own_tdd_nrarfcn[0]
                self.cells_info[lcrId]["nrarfcn"] = "%s:%s" % (tdd_nrarfcn, tdd_nrarfcn)
            else:
                for j in own_fdd_nrarfcn:
                    if j.startswith(i):
                        fdd_nrarfcn_ul = self.cu_scfc.xpath(
                            r'.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL_FDD" and '
                            r'@distName="%s/NRCELL_FDD-1"]/ns:p[@name="nrarfcnUl"]/text()' % i,
                            namespaces={"ns": "raml21.xsd"})[0]
                        fdd_nrarfcn_dl = self.cu_scfc.xpath(
                            r'.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL_FDD" and '
                            r'@distName="%s/NRCELL_FDD-1"]/ns:p[@name="nrarfcnDl"]/text()' % i,
                            namespaces={"ns": "raml21.xsd"})[0]
                        self.cells_info[lcrId]["nrarfcn"] = "%s:%s" % (fdd_nrarfcn_ul, fdd_nrarfcn_dl)

    def __get_gscn_aic(self):
        for lcrId in self.cells_info.keys():
            ret1 = self.du_scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="gscnOrSsPbchArfcn" or @name="gscn"]/text()' % self.cells_info[lcrId]["distname"],
                namespaces={"ns": "raml21.xsd"})
            if ret1 != []:
                self.cells_info[lcrId]["gscn"] = ret1[0]
            else:
                for du in [self.du2_scfc, self.du3_scfc, self.du4_scfc]:
                    if du is not None:
                        ret2 = du.xpath(
                            './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                            'ns:p[@name="gscnOrSsPbchArfcn" or @name="gscn"]/text()'
                            % self.cells_info[lcrId]["distname"], namespaces={"ns": "raml21.xsd"})
                        if ret2 != []:
                            self.cells_info[lcrId]["gscn"] = ret2[0]
                            break
