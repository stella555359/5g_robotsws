import sys
import StringTool
import xml.etree.ElementTree as ET
import re


class XmlScf:
    NAMESPACE = "raml21.xsd"
    CLASS = "class"
    DIST_NAME = "distName"
    MANAGED_OBJECT = "managedObject"

    def __init__(self):
        pass

    def startSession(self, path, debug=False):
        self.debug = debug
        self.local_path = path
        self.isModified = False
        self.tree = ET.parse(self.local_path)
        self.root = self.tree.getroot()

    def stopSession(self):
        pass

    def getListMO(self, endClass=""):
        listMO = []
        for mo in self.root.iter(XmlScf.toNsPath(XmlScf.MANAGED_OBJECT)):
            className = XmlScf.getMOClass(mo)
            if className.endswith(endClass):
                listMO.append(mo)
                if self.debug:
                    StringTool.datedConsole(XmlScf.moToStr(mo))
        return listMO

    def getScfType(self):
        type = (self.root[0][1].attrib["class"]).split(".")
        scftype = type[2].split(':')[0]
        if scftype == "vdu" or scftype == "cu" or scftype == "srbts":
            return scftype
        else:
            raise Exception("Problem in detecting SCF type : Please contact AF")

    def getVersion(self, endClass=""):
        for mo in self.root.iter(XmlScf.toNsPath(XmlScf.MANAGED_OBJECT)):
            className = XmlScf.getMOClass(mo)
            if className.endswith(endClass):
                return mo.attrib["version"]
        return None

    def getAllVersions(self):
        dicoVersions = {}
        for mo in self.root.iter(XmlScf.toNsPath(XmlScf.MANAGED_OBJECT)):
            className = XmlScf.getMOClass(mo)
            if className.endswith("MNL"):
                dicoVersions["MNL"] = mo.attrib["version"]
            elif className.endswith("TNL"):
                dicoVersions["TNL"] = mo.attrib["version"]
            elif className.endswith("EQM"):
                dicoVersions["EQM"] = mo.attrib["version"]
            elif className.endswith("NRBTS"):
                dicoVersions["NRBTS"] = mo.attrib["version"]
            elif className.endswith("MRBTS"):
                dicoVersions["MRBTS"] = mo.attrib["version"]
        return dicoVersions

    def get_BTS_Info(self):
        dicoBtsInfo = {}
        cellList = []
        cellDN = []
        cellGrpList = []
        cellGrpDN = []
        for mo in self.root.iter(XmlScf.toNsPath(XmlScf.MANAGED_OBJECT)):
            className = XmlScf.getMOClass(mo)
            if className.endswith("MRBTS"):
                val = (mo.attrib["distName"]).split("MRBTS-")
                dicoBtsInfo["mrbts_id"] = val[1]
            if className.endswith("NRBTS"):
                val = (mo.attrib["distName"]).split("NRBTS-")
                dicoBtsInfo["nrbts_id"] = val[1]
            if className.endswith("NRCELL"):
                val = (mo.attrib["distName"]).split("NRCELL-")
                cellList.append(val[1])
                cellDN.append(mo.attrib["distName"])
            if className.endswith("NRCELLGRP"):
                val = (mo.attrib["distName"]).split("NRCELLGRP-")
                cellGrpList.append(val[1])
                cellGrpDN.append(mo.attrib["distName"])
        if cellList is not None:
            dicoBtsInfo["nrcell_Id_list"] = cellList
            dicoBtsInfo["nrcell_DN_list"] = cellDN
            dicoBtsInfo["nrcell_Id"] = cellList[0]
            dicoBtsInfo["nrcell_DN"] = cellDN[0]
        if cellGrpList is not None:
            dicoBtsInfo["cell_Grp_Id_list"] = cellGrpList
            dicoBtsInfo["cell_Grp_DN_list"] = cellGrpDN
            dicoBtsInfo["nrcell_Grp_Id"] = cellGrpList[0]
            dicoBtsInfo["nrcell_Grp_DN"] = cellGrpDN[0]
        return dicoBtsInfo

    def getSimpleAttr(self, mo, attrName):
        for p in mo.iter(XmlScf.toNsPath("p")):
            name = p.get("name")
            if attrName == name:
                return p
        return None

    def getListMOWithAttr(self, endClass, attrName, value):
        listMO = []
        for mo in self.root.iter(XmlScf.toNsPath(XmlScf.MANAGED_OBJECT)):
            className = XmlScf.getMOClass(mo)
            if className.endswith(endClass):
                p = self.getSimpleAttr(mo, attrName=attrName)
                if p is not None and p.text == value:
                    listMO.append(mo)
        return listMO

    def getListMOWithDN(self, endClass, startDN):
        listMO = []
        for mo in self.root.iter(XmlScf.toNsPath(XmlScf.MANAGED_OBJECT)):
            className = XmlScf.getMOClass(mo)
            dn = XmlScf.getMODistName(mo)
            if className.endswith(endClass) and dn.startswith(startDN):
                listMO.append(mo)
        return listMO

    def getBwpProfileId(self, scfFilePath, bwpType="dedicated"):
        self.startSession(scfFilePath)
        bwpMO = self.getListMO(endClass="NRCELL")
        bwpDico = {}
        for listElt in bwpMO[0].iter(XmlScf.toNsPath("list")):
            if listElt.get("name") == "cellBwpList":
                for p in listElt.iter(XmlScf.toNsPath("p")):
                    if p.get("name") == "bwpDN":
                        bwpDN = p.text
                    if p.get("name") == "cellBwpId" and p.text == "0":
                        bwpDico['initial'] = bwpDN
                    elif p.get("name") == "cellBwpId" and p.text == "1":
                        bwpDico['dedicated'] = bwpDN
        self.stopSession()
        StringTool.datedConsole("bwpDN = {}".format(bwpDico[bwpType]))
        bwp = bwpDico[bwpType].split("BWP_PROFILE-")[1]
        return bwp

    @staticmethod
    def toNsPath(path):
        return "{"+"{}".format(XmlScf.NAMESPACE)+"}"+"{}".format(path)

    @staticmethod
    def getMOClass(mo):
        return mo.get(XmlScf.CLASS)

    @staticmethod
    def getMODistName(mo):
        return mo.get(XmlScf.DIST_NAME)

    @staticmethod
    def moToStr(mo):
        return "CLASS={:50} DN={}".format(XmlScf.getMOClass(mo), XmlScf.getMODistName(mo))

    @staticmethod
    def splitBwpGetId(distName):
        bwpProfile = re.split('/', distName)
        bwpId = re.split('-', bwpProfile[2])
        id = bwpId[1]
        return id


def getMRBTSVersion(path):
    return getVersion(path, "MRBTS")


def getEQMVersion(path):
    return getVersion(path, "EQM")


def getMNLVersion(path):
    return getVersion(path, "MNL")


def getTNLVersion(path):
    return getVersion(path, "TNL")


def getNRBTSVersion(path):
    return getVersion(path, "NRBTS")


def get_bts_Infos(path):
    # will be return a dictionary with following tags: dicoBtsInfo{"mrbts_id" , "nrbts_id", "nrcell_id, "nrcell_Id",
    # "nrcell_DN", nrcell_Id_list, nrcell_DN_list, nrcell_Grp_Id, cell_Grp_DN, cell_Grp_DN_list, cell_Grp_Id_list}
    xmlscf = XmlScf()
    xmlscf.startSession(path)
    return xmlscf.get_BTS_Info()


def getVersion(path, endClass):
    xmlscf = XmlScf()
    xmlscf.startSession(path)
    return xmlscf.getVersion(endClass)
