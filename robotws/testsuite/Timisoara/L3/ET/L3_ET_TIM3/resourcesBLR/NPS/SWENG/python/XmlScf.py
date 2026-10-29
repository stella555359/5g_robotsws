import sys
import StringTool
import xml.etree.ElementTree as ET


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
