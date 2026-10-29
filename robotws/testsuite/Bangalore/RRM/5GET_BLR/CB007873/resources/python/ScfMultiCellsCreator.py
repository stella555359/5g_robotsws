import sys
import os
import re
from taf.config.scf import scf_operations as scf
import XmlScf as localScf
import StringTool

tafScfFunc = scf.SCFOperations()
localScfFunc = localScf.XmlScf()
scfOut = "SCF_multiCell_created.xml"
scfTemp = "SCF_multiCell_created_temp.xml"


class ExistingCells(object):
    def __init__(self, scfPath=None, cellId=None):
        tafScfFunc.load_scf(file_path=scfPath)
        self.scfPath = scfPath
        self.cellId = cellId
        self.cellIndex = self._getLastCellIndex(cellId=cellId)
        self.existingNumOfCells = len(self._getMrbtsObjs("NRCELL"))
        self.MRBTSname = self._getName("MRBTS")
        self.NRBTSname = self._getName("NRBTS")
        self.NRCELLDN = self.getDN("NRCELL", self.cellIndex)
        self.RMODDN = self.getDN("RMOD", self.cellIndex)
        self.RSLDN = self.getDN("RSL", self.cellIndex)
        self.CABLINKDN = self.getDN("CABLINK", self.cellIndex)
        self.LCELNRDN = self.getDN("LCELNR", self.cellIndex)
        self.CHANNELGROUPDN = self.getDN("CHANNELGROUP", self.cellIndex)
        self.NRCELL_FDD_DN = self.getDN("NRCELL_FDD", self.cellIndex)
        # self.NRCELL_TDD_DN = self.getDN("NRCELL_TDD", self.cellId)
        self.NRPLMNSET_NSA_DN = self.getDN("NRPLMNSET_NSA", self.cellIndex)
        self.NRPLMNSET_SA_DN = self.getDN("NRPLMNSET_SA", self.cellIndex)
        self.NRREDRTDN = self.getDN("NRREDRT", self.cellIndex)
        self.NRCELLGRPDN = self.getDN("NRCELLGRP", self.cellIndex)
        self.NRDUDN = self.getDN("NRDU", self.cellIndex)
        self.Antl1 = self._getAntlDN(antlId=1)
        self.Antl2 = self._getAntlDN(antlId=2)
        self.Antl3 = self._getAntlDN(antlId=3)
        self.Antl4 = self._getAntlDN(antlId=4)
        self.antl = [self.Antl1, self.Antl2, self.Antl3, self.Antl4]
        self.channel1 = self._getChannelDN(id=1)
        self.channel2 = self._getChannelDN(id=2)
        self.channel3 = self._getChannelDN(id=3)
        self.channel4 = self._getChannelDN(id=4)
        self.channel5 = self._getChannelDN(id=5)
        self.channel6 = self._getChannelDN(id=6)
        self.channel7 = self._getChannelDN(id=7)
        self.channel8 = self._getChannelDN(id=8)
        self.channel = [self.channel1, self.channel2, self.channel3, self.channel4,
                        self.channel5, self.channel6, self.channel7, self.channel8]
        self.cellName = self.getPvalueOfNrcell(DN=self.NRCELLDN, p_name="cellName")
        self.lcrId = self.getPvalueOfNrcell(DN=self.NRCELLDN, p_name="lcrId")
        self.phyCellId = self.getPvalueOfNrcell(DN=self.NRCELLDN, p_name="physCellId")
        self.prachCfgIndex = self.getPvalueOfNrcell(DN=self.NRCELLDN, p_name="prachConfigurationIndex")
        self.nrcellList = self._getListPvalue(self.NRCELLGRPDN, "nrCellList")
        self.refNrCellGroup = self._getListPvalue(self.NRDUDN, "refNrCellGroup")

    def _getLastCellIndex(self, cellId):
        # it returns eg:1
        if cellId is None or cellId == "last":
            mrbtsObjs = self._getMrbtsObjs("NRCELL")
            DN = mrbtsObjs[-1].get("distName")
            self.cellId = int(DN[-1])
            cellIndex = self.cellId - 1
        else:
            cellIndex = cellId - 1
        return cellIndex

    def _getMrbtsObjs(self, name):
        localScfFunc.startSession(path=self.scfPath)
        mrbtsObjs = localScfFunc.getListMO(endClass=name)
        return mrbtsObjs

    def getDN(self, name, id):
        # for Id will pass cellId but it starts with 1 and objects starts from 0
        if name == "CABLINK" or name == "NRDU" or name == "NRCELL_TDD":
            id = -1
        DN = None
        try:
            mrbtsObjs = self._getMrbtsObjs(name)
            DN = mrbtsObjs[id].get("distName")
        except IndexError:
            StringTool.datedConsole("Object {} does not exist ".format(name))
        return DN

    def _getName(self, name):
        # it returns eg:MRBTS-x or NRBTS-x
        ObjName = self.getDN(name=name, id=0)
        ObjName = re.split('/', ObjName)[-1]
        return ObjName

    def _getAntlDN(self, antlId):
        antlObjs = self._getMrbtsObjs("ANTL")
        AntlDN = None
        for obj in antlObjs:
            stringTocheck = "RMOD-" + str(self.cellId) + "/ANTL-" + str(antlId)
            DN = obj.get("distName")
            if stringTocheck in DN:
                AntlDN = DN
        return AntlDN

    def _getChannelDN(self, id):
        channelObjs = self._getMrbtsObjs("CHANNEL")
        channelDN = None
        for obj in channelObjs:
            stringTocheck = self.LCELNRDN + "/CHANNELGROUP-1/CHANNEL-" + str(id)
            DN = obj.get("distName")
            if stringTocheck in DN:
                channelDN = DN
        return channelDN

    def getPvalueOfNrcell(self, DN, p_name):
        p_val = tafScfFunc.get_value_from_scf(dist_name=DN, p_name=p_name)
        return p_val

    def _getListPvalue(self, DN, p_name):
        p_val = tafScfFunc.get_all_values_from_scf(dist_name=DN, list_name=p_name)
        p_val = p_val[-1]
        return p_val


class CellToCreate(object):
    def __init__(self, cellIdToCreate=1, refCell=None):
        self.cellIdToCreate = cellIdToCreate
        self.refCell = refCell
        self.MRBTSname = self.refCell.MRBTSname
        self.NRBTSname = self.refCell.NRBTSname
        self.NRDUDN = self.refCell.NRDUDN
        self.NRCELLDN = self._incrementLastInt(self.refCell.NRCELLDN)
        self.RMODDN = self._incrementLastInt(self.refCell.RMODDN)
        self.CABLINKDN = self._incrementLastInt(self.refCell.CABLINKDN)
        self.RSLDN = self.RMODDN + "/RSL-1"
        self.LCELNRDN = self._incrementLastInt(self.refCell.LCELNRDN)
        self.CHANNELGROUPDN = self.LCELNRDN + "/CHANNELGROUP-1"
        self.NRCELL_FDD_DN = self.NRCELLDN + "/NRCELL_FDD-1"
        # add TDD object
        self.NRPLMNSET_NSA_DN = self.NRCELLDN + "/NRPLMNSET_NSA-1"
        self.NRPLMNSET_SA_DN = self.NRCELLDN + "/NRPLMNSET_SA-1"
        self.NRREDRTDN = self.NRCELLDN + "/NRREDRT-0"
        self.NRCELLGRPDN = self._incrementLastInt(self.refCell.NRCELLGRPDN)
        self.Antl1 = self._getAntlDN(antlId=1)
        self.Antl2 = self._getAntlDN(antlId=2)
        self.Antl3 = self._getAntlDN(antlId=3)
        self.Antl4 = self._getAntlDN(antlId=4)
        self.channel1 = self._getChannelDN(id=1)
        self.channel2 = self._getChannelDN(id=2)
        self.channel3 = self._getChannelDN(id=3)
        self.channel4 = self._getChannelDN(id=4)
        self.channel5 = self._getChannelDN(id=5)
        self.channel6 = self._getChannelDN(id=6)
        self.channel7 = self._getChannelDN(id=7)
        self.channel8 = self._getChannelDN(id=8)
        self.cellName = self._incrementLastInt(self.refCell.cellName)
        self.lcrId = self._incrementLastInt(self.refCell.lcrId)
        self.phyCellId = self._incrementLastInt(self.refCell.phyCellId)
        self.prachCfgIndex = self._incrementLastInt(self.refCell.prachCfgIndex)
        self.nrcellList = self._incrementLastInt(self.refCell.nrcellList)
        self.refNrCellGroup = self._incrementLastInt(self.refCell.refNrCellGroup)

    def _incrementLastInt(self, DN):
        lastId = int(DN[-1])
        newId = lastId + self.cellIdToCreate
        newnrcellDN = DN[:-1] + str(newId)
        return newnrcellDN

    def _getAntlDN(self, antlId=1):
        newAntlDN = self.RMODDN + "/" + "ANTL-" + str(antlId)
        return newAntlDN

    def _getChannelDN(self, id=1):
        newChannelDN = self.LCELNRDN + "/" + "CHANNELGROUP-1/CHANNEL-" + str(id)
        return newChannelDN


class PrerequisiteOnBaseScf(object):
    def __init__(self):
        self.channelConfig = {"noOfUl": 2, "noOfDl": 2}

    def createNewChannelDN(self, id, refCell, modified):
        if refCell.channel[int(id) - 1] is None and refCell.channel4 is not None:
            newChannelDN = refCell.LCELNRDN + "/" + "CHANNELGROUP-1/CHANNEL-" + str(id)
            tafScfFunc.clone_mo_with_descendant_mos(source_mo_dist_name=refCell.channel4, new_dist_name=newChannelDN)
            StringTool.datedConsole("OK: Object cloned: {} , based on: {}".format(newChannelDN, refCell.channel4))
            modified = True
        return modified

    def createNewAntlDN(self, id, refCell, modified):
        if refCell.antl[int(id) - 1] is None and refCell.Antl2 is not None:
            newAntlDN = refCell.RMODDN + "/" + "ANTL-" + str(id)
            tafScfFunc.clone_mo_with_descendant_mos(source_mo_dist_name=refCell.Antl2, new_dist_name=newAntlDN)
            StringTool.datedConsole("OK: Object cloned: {} , based on: {}".format(newAntlDN, refCell.Antl2))
            modified = True
        return modified

    def cloneChAndAntlOnBaseScf(self, refCell, scfBasePath):
        modified = False
        modified = self.createNewAntlDN(id=3, refCell=refCell, modified=modified)
        modified = self.createNewAntlDN(id=4, refCell=refCell, modified=modified)

        if self.channelConfig["noOfUl"] == 2 and self.channelConfig["noOfDl"] == 2:
            pass
        elif self.channelConfig["noOfUl"] == 4 and self.channelConfig["noOfDl"] == 4:
            modified = self.createNewChannelDN(id=5, refCell=refCell, modified=modified)
            modified = self.createNewChannelDN(id=6, refCell=refCell, modified=modified)
            modified = self.createNewChannelDN(id=7, refCell=refCell, modified=modified)
            modified = self.createNewChannelDN(id=8, refCell=refCell, modified=modified)
        elif self.channelConfig["noOfUl"] == 4 or self.channelConfig["noOfDl"] == 4:
            modified = self.createNewChannelDN(id=5, refCell=refCell, modified=modified)
            modified = self.createNewChannelDN(id=6, refCell=refCell, modified=modified)

        if modified is True:
            tafScfFunc.save_scf(file_path=initialSCFPath + scfTemp)
        return modified

    def modifyChAndAntlOnTempScf(self, refCell):
        modified = False
        if refCell.Antl3 is not None:
            tafScfFunc.modify_scf_element(value="3", dist_name=refCell.Antl3, p_name="antPortId")
            modified = True
        if refCell.Antl4 is not None:
            tafScfFunc.modify_scf_element(value="4", dist_name=refCell.Antl4, p_name="antPortId")
            modified = True
        if self.channelConfig["noOfUl"] == 2 and self.channelConfig["noOfDl"] == 2:
            pass
        elif self.channelConfig["noOfUl"] == 4 and self.channelConfig["noOfDl"] == 4:
            if refCell.channel5 is not None and refCell.channel8 is not None:
                tafScfFunc.modify_scf_element(value=refCell.Antl3, dist_name=refCell.channel5, p_name="antlDN")
                tafScfFunc.modify_scf_element(value="RX", dist_name=refCell.channel5, p_name="direction")
                tafScfFunc.modify_scf_element(value=refCell.Antl4, dist_name=refCell.channel6, p_name="antlDN")
                tafScfFunc.modify_scf_element(value="RX", dist_name=refCell.channel6, p_name="direction")
                tafScfFunc.modify_scf_element(value=refCell.Antl3, dist_name=refCell.channel7, p_name="antlDN")
                tafScfFunc.modify_scf_element(value="TX", dist_name=refCell.channel7, p_name="direction")
                tafScfFunc.modify_scf_element(value=refCell.Antl4, dist_name=refCell.channel8, p_name="antlDN")
                tafScfFunc.modify_scf_element(value="TX", dist_name=refCell.channel8, p_name="direction")
                tafScfFunc.modify_scf_element(value="4DL4UL", dist_name=refCell.NRCELLDN, p_name="nrCellType")
                tafScfFunc.modify_scf_element(value="4x4 or 4x2 Open Loop Spatial Multiplexing",
                                              dist_name=refCell.NRCELLDN, p_name="dlMimoMode")
                modified = True
        else:
            if refCell.channel5 is not None and refCell.channel6 is not None:
                tafScfFunc.modify_scf_element(value=refCell.Antl3, dist_name=refCell.channel5, p_name="antlDN")
                tafScfFunc.modify_scf_element(value="RX", dist_name=refCell.channel5, p_name="direction")
                tafScfFunc.modify_scf_element(value=refCell.Antl4, dist_name=refCell.channel6, p_name="antlDN")
                tafScfFunc.modify_scf_element(value="RX", dist_name=refCell.channel6, p_name="direction")
                modified = True
        if modified is True:
            tafScfFunc.save_scf(file_path=initialSCFPath + scfTemp)

    # Channel Modifs
    def calculateChannelConfig(self, channelConfig="2dl2ul"):
        channelConfig = channelConfig.upper()
        channelConfigDico = {"noOfUl": 2, "noOfDl": 2}
        ulpos = int(channelConfig.find("UL")) - 1
        dlpos = int(channelConfig.find("DL")) - 1
        noOfUl = channelConfig[ulpos]
        noOfDl = channelConfig[dlpos]
        channelConfigDico["noOfUl"] = int(noOfUl)
        channelConfigDico["noOfDl"] = int(noOfDl)
        return channelConfigDico

    def createAndMofifBaseScf(self, refCells, scfBasePath, channelConfig):
        newPath = scfBasePath
        for refCell in refCells:
            self.channelConfig = self.calculateChannelConfig(channelConfig)
            modified = self.cloneChAndAntlOnBaseScf(refCell=refCell, scfBasePath=scfBasePath)
        if modified:
            tafScfFunc.load_scf(file_path=initialSCFPath + scfTemp)
            refCells = getListOfExistingCells(scfBasePath=initialSCFPath + scfTemp)
            for refCell in refCells:
                self.modifyChAndAntlOnTempScf(refCell=refCell)
            newPath = initialSCFPath + scfTemp
        return newPath


class CloneObjects(object):
    def _objToCloneAndCheck(self, refObj, toCreateObj):
        if refObj is None:
            StringTool.datedConsole("NOK: Object NOT cloned (doesn't exists in base SCF): {}".format(toCreateObj))
        else:
            paramCheck = tafScfFunc.is_in_scf(dist_name=toCreateObj)
            if paramCheck is False:
                tafScfFunc.clone_mo_with_descendant_mos(source_mo_dist_name=refObj, new_dist_name=toCreateObj)
                StringTool.datedConsole("OK: Object cloned: {} , based on: {}".format(toCreateObj, refObj))

    def _prepareCloneObjects(self, scfPath, cellId, refCell):
        toCreateCell = CellToCreate(cellIdToCreate=cellId, refCell=refCell)
        # clone RMOD
        self._objToCloneAndCheck(refCell.RMODDN, toCreateCell.RMODDN)
        # clone ANTL
        self._objToCloneAndCheck(refCell.Antl1, toCreateCell.Antl1)
        self._objToCloneAndCheck(refCell.Antl2, toCreateCell.Antl2)
        self._objToCloneAndCheck(refCell.Antl3, toCreateCell.Antl3)
        self._objToCloneAndCheck(refCell.Antl4, toCreateCell.Antl4)
        # clone RSL
        self._objToCloneAndCheck(refCell.RSLDN, toCreateCell.RSLDN)
        # clone CABLINK
        self._objToCloneAndCheck(refCell.CABLINKDN, toCreateCell.CABLINKDN)
        # clone CHANNELGROUP
        self._objToCloneAndCheck(refCell.LCELNRDN, toCreateCell.LCELNRDN)
        self._objToCloneAndCheck(refCell.CHANNELGROUPDN, toCreateCell.CHANNELGROUPDN)
        # clone CHANNEL
        self._objToCloneAndCheck(refCell.channel1, toCreateCell.channel1)
        self._objToCloneAndCheck(refCell.channel2, toCreateCell.channel2)
        self._objToCloneAndCheck(refCell.channel3, toCreateCell.channel3)
        self._objToCloneAndCheck(refCell.channel4, toCreateCell.channel4)
        self._objToCloneAndCheck(refCell.channel5, toCreateCell.channel5)
        self._objToCloneAndCheck(refCell.channel6, toCreateCell.channel6)
        self._objToCloneAndCheck(refCell.channel7, toCreateCell.channel7)
        self._objToCloneAndCheck(refCell.channel8, toCreateCell.channel8)
        # clone NRCELL
        self._objToCloneAndCheck(refCell.NRCELLDN, toCreateCell.NRCELLDN)
        # clone NRCELL_FDD
        self._objToCloneAndCheck(refCell.NRCELL_FDD_DN, toCreateCell.NRCELL_FDD_DN)
        # clone NRPLMNSET NSA  and SA
        self._objToCloneAndCheck(refCell.NRPLMNSET_NSA_DN, toCreateCell.NRPLMNSET_NSA_DN)
        self._objToCloneAndCheck(refCell.NRPLMNSET_SA_DN, toCreateCell.NRPLMNSET_SA_DN)
        self._objToCloneAndCheck(refCell.NRREDRTDN, toCreateCell.NRREDRTDN)
        self._objToCloneAndCheck(refCell.NRCELLGRPDN, toCreateCell.NRCELLGRPDN)

    def cloneObjects(self, scfPath, refCell, iterrationOfCells, sufixScf):
        newSCFCreated = initialSCFPath + sufixScf + "_" + scfOut
        for i in range(1, iterrationOfCells):
            self._prepareCloneObjects(scfPath=scfPath, cellId=i, refCell=refCell)
        tafScfFunc.save_scf(file_path=newSCFCreated)
        return newSCFCreated


class ModifyClonedObjects(object):
    def _paramToModifyAndCheck(self, DN, newVal, param, pType):
        paramCheck = tafScfFunc.is_in_scf(dist_name=DN)
        if paramCheck:
            StringTool.datedConsole("OK: Parameter modified: {} = {}".format(param, newVal))
            if param == "refNrCellGroup":
                # tafScfFunc2.add_scf_parameter_inside_list_by_mo(mo_name = DN, list_name = param, value=newVal)
                tafScfFunc.add_scf_parameter_inside_list_by_mo(mo_name=DN, list_name=param, value=newVal)
            elif pType == "p_name":
                tafScfFunc.modify_scf_element(value=newVal, dist_name=DN, p_name=param)
            elif pType == "list_name":
                tafScfFunc.modify_scf_element(value=newVal, dist_name=DN, list_name=param)
        else:
            StringTool.datedConsole("NOK: Parameter NOT modified: {}".format(param))

    def modifyCreatedObjects(self, scfPathInitial, scfPathModified, refCell, iterrationOfCells):
        tafScfFunc.load_scf(file_path=scfPathModified)
        for i in range(1, iterrationOfCells):
            toCreateCell = CellToCreate(cellIdToCreate=i, refCell=refCell)
            # NRCELL
            self._paramToModifyAndCheck(DN=toCreateCell.NRCELLDN, newVal=toCreateCell.cellName, param="cellName",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.NRCELLDN, newVal=toCreateCell.lcrId, param="lcrId",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.NRCELLDN, newVal=toCreateCell.phyCellId, param="physCellId",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.NRCELLDN, newVal=toCreateCell.prachCfgIndex,
                                        param="prachConfigurationIndex", pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.NRCELLDN, newVal=toCreateCell.RMODDN, param="rModDNList",
                                        pType="list_name")
            # CHANNEL
            self._paramToModifyAndCheck(DN=toCreateCell.channel1, newVal=toCreateCell.Antl1, param="antlDN",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.channel2, newVal=toCreateCell.Antl1, param="antlDN",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.channel3, newVal=toCreateCell.Antl2, param="antlDN",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.channel4, newVal=toCreateCell.Antl2, param="antlDN",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.channel5, newVal=toCreateCell.Antl3, param="antlDN",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.channel6, newVal=toCreateCell.Antl4, param="antlDN",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.channel7, newVal=toCreateCell.Antl3, param="antlDN",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.channel8, newVal=toCreateCell.Antl4, param="antlDN",
                                        pType="p_name")
            # CABLINK
            self._paramToModifyAndCheck(DN=toCreateCell.CABLINKDN, newVal="SFP", param="firstEndpointLabel",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.CABLINKDN, newVal=toCreateCell.RMODDN,
                                        param="secondEndpointDN", pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.CABLINKDN, newVal=i, param="firstEndpointPortId",
                                        pType="p_name")
            self._paramToModifyAndCheck(DN=toCreateCell.CABLINKDN, newVal=i, param="secondEndpointPortId",
                                        pType="p_name")
            # NRCELLGRP
            self._paramToModifyAndCheck(DN=toCreateCell.NRCELLGRPDN, newVal=toCreateCell.nrcellList,
                                        param="nrCellList", pType="list_name")
            # NRDU
            self._paramToModifyAndCheck(DN=toCreateCell.NRDUDN, newVal=toCreateCell.refNrCellGroup,
                                        param="refNrCellGroup",
                                        pType="list_name")
        tafScfFunc.save_scf(file_path=scfPathModified)


def calculatePath(scfPath):
    global initialSCFName
    global initialSCFPath
    initialSCFName = scfPath.split('/')[-1].strip()
    initialSCFPath = scfPath.split(initialSCFName)[0]


def getListOfExistingCells(scfBasePath):
    refCells = []
    for i in range(1, existingNoOfCells + 1):
        cell = ExistingCells(scfPath=scfBasePath, cellId=i)
        refCells.append(cell)
    return refCells


# this function will return the path of new SCF created with desiredNumOfCells and channelConfig
# newScfCreated = createMultipleCellScf(scfBasePath=scfPath, desiredNumOfCells=3. channelConfig="2dl2ul")


def createMultipleCellScf(scfBasePath, desiredNumOfCells=3, channelConfig="2dl2ul", suffixScfName=""):
    calculatePath(scfBasePath)
    NRCELL_TDD_DN = ExistingCells(scfPath=scfBasePath).getDN("NRCELL_TDD", id=1)
    print("global {}".format(initialSCFName))
    referenceCell = ExistingCells(scfPath=scfBasePath)
    global existingNoOfCells
    existingNoOfCells = referenceCell.existingNumOfCells
    newSCFCreated = None
    if desiredNumOfCells > existingNoOfCells:
        iterrationOfClone = (desiredNumOfCells - existingNoOfCells) + 1
        suffixName = suffixScfName + "_" + channelConfig
        StringTool.datedConsole("########## SCF {} cells creation START ###########".format(desiredNumOfCells))
        StringTool.datedConsole("INFO: On base SCF exists {} cells. This tool will add {} "
                                "cells".format(existingNoOfCells, iterrationOfClone - 1))
        # stop everything if DN = "NRCELL_TDD" encountered
        if NRCELL_TDD_DN is not None:
            StringTool.datedConsole("ERROR: Funtion will stop because  NRCELL_TDD_DN encountered")
            return
        # prereq to create 4 antenas
        refCells = getListOfExistingCells(scfBasePath=scfBasePath)
        tempScf = PrerequisiteOnBaseScf().createAndMofifBaseScf(refCells=refCells, scfBasePath=scfBasePath,
                                                                channelConfig=channelConfig)
        refCell = ExistingCells(scfPath=tempScf)
        newSCFCreated = CloneObjects().cloneObjects(scfPath=tempScf, refCell=refCell,
                                                    iterrationOfCells=iterrationOfClone, sufixScf=suffixName)
        StringTool.datedConsole("INFO: New SCF with cloned obj :{}. Now parameters are "
                                "modified".format(os.path.isfile(newSCFCreated)))
        ModifyClonedObjects().modifyCreatedObjects(tempScf, newSCFCreated, refCell=referenceCell,
                                                   iterrationOfCells=iterrationOfClone)
        os.remove(tempScf)
        StringTool.datedConsole("########## SCF {} cells creation END ###########".format(desiredNumOfCells))
    else:
        StringTool.datedConsole("ERROR: On base SCF exists {} cells. You ask this tool to create SCF with {} cells- "
                                "Operation impossible".format(existingNoOfCells, desiredNumOfCells))
    return newSCFCreated


def dispalySCFInfo(scfPath):
    referenceCell = ExistingCells(scfPath)
    existingNoOfCells = referenceCell.existingNumOfCells
    myPrint("Total number of cells ", existingNoOfCells)
    for i in range(1, existingNoOfCells + 1):
        refCell = ExistingCells(scfPath, cellId=i)
        myPrint("CELL " + str(i) + ": MRBTS name: ", refCell.MRBTSname)
        myPrint("CELL " + str(i) + ": NRBTS name: ", refCell.NRBTSname)
        myPrint("CELL " + str(i) + ": RMOD DN: ", refCell.RMODDN)
        myPrint("CELL " + str(i) + ": NRCELL DN: ", refCell.NRCELLDN)
        myPrint("CELL " + str(i) + ": Antl 1 DN: ", refCell.Antl1)
        myPrint("CELL " + str(i) + ": Antl 2 DN: ", refCell.Antl2)
        myPrint("CELL " + str(i) + ": Antl 3 DN: ", refCell.Antl3)
        myPrint("CELL " + str(i) + ": Antl 4 DN: ", refCell.Antl4)
        myPrint("CELL " + str(i) + ": Channel 1 DN: ", refCell.channel1)
        myPrint("CELL " + str(i) + ": Channel 2 DN: ", refCell.channel2)
        myPrint("CELL " + str(i) + ": Channel 3 DN: ", refCell.channel3)
        myPrint("CELL " + str(i) + ": Channel 4 DN: ", refCell.channel4)
        myPrint("CELL " + str(i) + ": Channel 5 DN: ", refCell.channel5)
        myPrint("CELL " + str(i) + ": Channel 6 DN: ", refCell.channel6)
        myPrint("CELL " + str(i) + ": Channel 7 DN: ", refCell.channel7)
        myPrint("CELL " + str(i) + ": Channel 8 DN: ", refCell.channel8)
        myPrint("CELL " + str(i) + ": NRCELL_FDD DN: ", refCell.NRCELL_FDD_DN)
        chBwDl = ExistingCells(scfPath=scfPath).getPvalueOfNrcell(DN=refCell.NRCELL_FDD_DN, p_name="chBwDl")
        myPrint("CELL " + str(i) + ": chBwDL Value: ", chBwDl)
        chBwUl = ExistingCells(scfPath=scfPath).getPvalueOfNrcell(DN=refCell.NRCELL_FDD_DN, p_name="chBwUl")
        myPrint("CELL " + str(i) + ": chBwUL Value: ", chBwUl)
        nrarfcnDl = ExistingCells(scfPath=scfPath).getPvalueOfNrcell(DN=refCell.NRCELL_FDD_DN, p_name="nrarfcnDl")
        myPrint("CELL " + str(i) + ": nrarfcnDl Value: ", nrarfcnDl)
        nrarfcnUl = ExistingCells(scfPath=scfPath).getPvalueOfNrcell(DN=refCell.NRCELL_FDD_DN, p_name="nrarfcnUl")
        myPrint("CELL " + str(i) + ": nrarfcnDl Value: ", nrarfcnUl)
        dlMimoMode = ExistingCells(scfPath=scfPath).getPvalueOfNrcell(DN=refCell.NRCELLDN, p_name="dlMimoMode")
        myPrint("CELL " + str(i) + ": dlMimoMode Value: ", dlMimoMode)
        nrCellType = ExistingCells(scfPath=scfPath).getPvalueOfNrcell(DN=refCell.NRCELLDN, p_name="nrCellType")
        myPrint("CELL " + str(i) + ": dlMimoMode Value: ", nrCellType)


def myPrint(name, val):
    StringTool.datedConsole(StringTool.getHeaderLine(name, val))
