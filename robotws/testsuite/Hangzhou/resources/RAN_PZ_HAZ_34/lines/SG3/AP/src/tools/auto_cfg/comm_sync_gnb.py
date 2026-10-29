# -*- coding: utf-8 -*-

"""
:author:     eric.jiang
:contact:    eric.jiang@nokia-sbell.com
:maintainer: eric.jiang@nokia-sbell.com
"""

import re
from lxml.objectify import parse as PARSE
from collections import OrderedDict


class Real_GNB(object):
    def __init__(self, scfc_path):
        self.scfc_path = scfc_path
        self.scfc = PARSE(self.scfc_path)
        self.ipv4_ip = self.__get_ipv4_ip()
        self.plmn = self.__get_plmn()
        self.gnb_id = self.__get_gnb_id()
        self.cells_info = self.__get_cells_info()

    def __get_ipv4_ip(self):
        ipv4_ip_L = self.scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.tnl:IPADDRESSV4"]/'
                                    'ns:p[@name="localIpAddr"]/text()', namespaces={"ns": "raml21.xsd"})
        return ipv4_ip_L[0]

    def __get_plmn(self):
        mcc = self.scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/ns:p[@name="mcc"]/text()',
                              namespaces={"ns": "raml21.xsd"})
        mnc = self.scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/ns:p[@name="mnc"]/text()',
                              namespaces={"ns": "raml21.xsd"})
        return "%d:%02d" % (int(mcc[0]), int(mnc[0]))

    def __get_gnb_id(self):
        ret1 = self.scfc.xpath('//ns:managedObject[starts-with(@class,"com.nokia.srbts.nrbts:NRBTS")]/@distName',
                               namespaces={"ns": "raml21.xsd"})
        ret2 = self.scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/'
                               'ns:p[@name="gNbIdLength"]/text()', namespaces={"ns": "raml21.xsd"})
        bts_id = '0x{0:02X}'.format(int(re.search(r"NRBTS-(\d+)", ret1[0]).group(1)))
        length = ret2[0]
        return "%s:%s" % (bts_id, length)

    def __get_cells_info(self):
        cells_info = {}

        # cells_distname = ['MRBTS-1/NRBTS-1/NRCELL-1', 'MRBTS-1/NRBTS-1/NRCELL-12']
        cells_distname = self.scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/@distName',
                                         namespaces={"ns": "raml21.xsd"})

        # own_fdd_nrarfcn = ['MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1', 'MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1']
        own_fdd_nrarfcn = self.scfc.xpath(
            './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL_FDD" ]/'
            'ns:p[@name="nrarfcnDl"]/../@distName',
            namespaces={"ns": "raml21.xsd"})

        # own_fdd_nrarfcn_distname = ['MRBTS-1/NRBTS-1/NRCELL-11', 'MRBTS-1/NRBTS-1/NRCELL-12']
        own_fdd_nrarfcn_distname = []
        for i in own_fdd_nrarfcn:
            distname = "/".join(i.split("/")[:-1])
            own_fdd_nrarfcn_distname.append(distname)

        for i in cells_distname:
            # lcrid
            lcrId = self.scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="lcrId"]/text()' % i,
                namespaces={"ns": "raml21.xsd"})[0]
            cells_info[lcrId] = OrderedDict()
            cells_info[lcrId]["lcrid"] = lcrId

            # pci
            pci = self.scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="physCellId"]/text()' % i,
                namespaces={"ns": "raml21.xsd"})[0]
            cells_info[lcrId]["pci"] = pci

            # Before is wrong, should sync "fiveGsTac" under TRACKINGAREA, not configuredEpsTac update 20220711
            # tac actRanSharing=false
            ret = self.scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="trackingAreaDN"]/text()' % i,
                namespaces={"ns": "raml21.xsd"})
            if ret != []:
                traceing_area = ret[0]  # Usually, there is just one element
                ret1 = self.scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA" and '
                                       '@distName="%s"]/ns:p[@name="fiveGsTac"]/text()' % traceing_area,
                                       namespaces={"ns": "raml21.xsd"})
                if ret1 != []:
                    tac = ret1[0]
            else:
                # tac  actRanSharing=true
                ret1 = self.scfc.xpath(
                    './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRPLMNSET_NSA" and '
                    'starts-with(@distName,"%s/NRPLMNSET_NSA")]/ns:p[@name="trackingAreaDN"]/text()' % i,
                    namespaces={"ns": "raml21.xsd"})
                ret2 = self.scfc.xpath(
                    './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRPLMNSET_SA" and '
                    'starts-with(@distName,"%s/NRPLMNSET_SA")]/ns:p[@name="trackingAreaDN"]/text()' % i,
                    namespaces={"ns": "raml21.xsd"})
                if ret1 != [] and ret2 == []:
                    traceing_area = ret1[0]
                elif ret1 == [] and ret2 != []:
                    traceing_area = ret2[0]
                if 'traceing_area' in dir():
                    ret3 = self.scfc.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA" and '
                                           '@distName="%s"]/ns:p[@name="fiveGsTac"]/text()' % traceing_area,
                                           namespaces={"ns": "raml21.xsd"})
                    if ret3 != []:
                        tac = ret3[0]
            if 'tac' in dir():
                cells_info[lcrId]["tac"] = tac

            # gscn
            gscn = self.scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="gscnOrSsPbchArfcn" or @name="gscn"]/text()' % i,
                namespaces={"ns": "raml21.xsd"})[0]
            cells_info[lcrId]["gscn"] = gscn

            # nrarfcn
            own_tdd_nrarfcn = self.scfc.xpath(
                './/ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL" and @distName="%s"]/'
                'ns:p[@name="nrarfcn"]/text()' % i,
                namespaces={"ns": "raml21.xsd"})  # ['634000']

            if own_tdd_nrarfcn != [] and i not in own_fdd_nrarfcn_distname:  # TDD
                tdd_nrarfcn = own_tdd_nrarfcn[0]
                cells_info[lcrId]["nrarfcn"] = "%s:%s" % (tdd_nrarfcn, tdd_nrarfcn)
            else:  # FDD
                for j in own_fdd_nrarfcn:
                    if j.startswith(i):
                        fdd_nrarfcn_ul = self.scfc.xpath(
                            r'.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL_FDD" and '
                            r'@distName="%s/NRCELL_FDD-1"]/ns:p[@name="nrarfcnUl"]/text()' % i,
                            namespaces={"ns": "raml21.xsd"})[0]
                        fdd_nrarfcn_dl = self.scfc.xpath(
                            r'.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL_FDD" and '
                            r'@distName="%s/NRCELL_FDD-1"]/ns:p[@name="nrarfcnDl"]/text()' % i,
                            namespaces={"ns": "raml21.xsd"})[0]
                        cells_info[lcrId]["nrarfcn"] = "%s:%s" % (fdd_nrarfcn_ul, fdd_nrarfcn_dl)

        return cells_info
