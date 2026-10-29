import StringTool
import copy
import os
import xml.etree.ElementTree as ET
import XmlConfig as localXml
import CfgConfig as localWts
from taf.config.wts import wts_operations as wts
from collections import OrderedDict

localXml = localXml.XmlConfig()
localWts = localWts.CfgConfig()
tafWtsFunc = wts.WTSOperations()

reListPath = "CPRI-Config/CPRI-RP1-RE_List"
rePath = "CPRI-Config/CPRI-RP1-RE_List/RE"
identityPath = rePath + "/identity"
hardwarePath = rePath + "/hardware"
optlinkPath = hardwarePath + "/optlink_List/optlink"
vcellPath = hardwarePath + "/vcellList/vcell"
cellApXml = "cellConfig/cell"
cellGroupApXml = "cellGroupConfig/cellGroup"
iphyClonedName = "iphyCloned.xml"
finalBasicCfg = "BasicCfg_multiCell_created.cfg"


class Cell(object):
    def __init__(self, reId=None, newRE=False, lastExistingObj=None, cablingPort=None):
        self.reId = reId
        self.reIndex = self.getReIndex()
        self.newRE = newRE
        self.cablingPort = cablingPort
        self.lastExistingObj = lastExistingObj
        self.serialno = self.getValue(identityPath, "serialno")
        self.physicalId = self.getValue(optlinkPath, "physicalId")
        self.cell = self.getValue(vcellPath, "cell")
        self.phy_cell_id = self.getValue(vcellPath, "phy_cell_id")
        self.virtualId = self.getValue(optlinkPath, "virtualId")

    def getReIndex(self):
        if self.reId is None:
            index = -1
        else:
            index = self.reId - 1
        return index

    def calculateVal(self, tagName):
        val = ""
        if tagName == "serialno":
            size = len(self.lastExistingObj.serialno)
            lastCar = int(self.lastExistingObj.serialno[-2:size]) + 1
            val = self.lastExistingObj.serialno[:size - 2] + str(lastCar)
        if tagName == "virtualId":
            val = str(int(self.lastExistingObj.virtualId) + 1)
        if tagName == "cell":
            size = len(self.lastExistingObj.cell)
            lastChar = int(self.lastExistingObj.cell[-1]) + 1
            val = self.lastExistingObj.cell[:size - 1] + str(lastChar)
        if tagName == "phy_cell_id":
            val = str(int(self.lastExistingObj.phy_cell_id) + 1)
        if tagName == "physicalId":
            val = str(self.cablingPort[self.reId])
        StringTool.datedConsole("IPHY Modif Value calculation. TagName: {},  Val: {}".format(tagName, val))
        return val

    def getExistingVal(self, xmlPath, tagName):
        value = localXml.getAttrValByIndex(path=xmlPath, attr_name=tagName, index=self.reIndex, debug=False)
        return value

    def getValue(self, xmlPath, tagName):
        if not self.newRE:
            val = self.getExistingVal(xmlPath=xmlPath, tagName=tagName)
        else:
            val = self.calculateVal(tagName=tagName)
        return val


class CloneModifyIphy(object):
    def __init__(self):
        pass

    def modifyValue(self, object, param, value, index):
        StringTool.datedConsole("IPHY Modification : object -{}, param-{}, value-{},"
                                " index{}".format(object, param, value, index))
        listElt = localXml.getListElt(path=object, debug=False)
        localXml.setSubEltText(elt=listElt[index], subEltName=param, value=value, debug=False)

    def modifyFinalValues(self, initialIphy, clonedIphy, cablingAP, finalIphy):
        desiredObj = []
        localXml.startSession(path=initialIphy)
        lastCell = Cell()
        for i in range(0, len(cablingAP)):
            if i < existingRE:
                desiredObj.append(None)
            else:
                cell = Cell(reId=i, newRE=True, lastExistingObj=lastCell, cablingPort=cablingAP)
                lastCell = cell
                desiredObj.append(cell)
        localXml.startSession(path=clonedIphy)
        for i in range(0, len(desiredObj)):
            if desiredObj[i] is not None:
                self.modifyValue(object=identityPath, param="serialno", value=desiredObj[i].serialno, index=i)
                self.modifyValue(object=optlinkPath, param="physicalId", value=desiredObj[i].physicalId, index=i)
                self.modifyValue(object=vcellPath, param="cell", value=desiredObj[i].cell, index=i)
                self.modifyValue(object=vcellPath, param="phy_cell_id", value=desiredObj[i].phy_cell_id, index=i)
                self.modifyValue(object=optlinkPath, param="virtualId", value=desiredObj[i].virtualId, index=i)
        localXml.stopSessionInNewFile(newFile=finalIphy)
        return finalIphy

    def cloneRE(self, initialIphy, itterationOfRe):
        localXml.startSession(path=initialIphy)
        for i in range(0, itterationOfRe):
            localXml.cloneTree(path=rePath, debug=False)
        iphyCloned = initialFilePath + iphyClonedName
        localXml.stopSessionInNewFile(iphyCloned)
        return iphyCloned


class CloneModifyBasicCfg():
    pdnIp = [OrderedDict([('index', ''), ('set PDN_IP', ''), ('PDN_IP', '')])]
    setCell = [OrderedDict([('index', ''), ('set_cell', ''), ('id', ''), ('gnb', ''), ('pci', ''), ('nrci', '')])]
    setBearer = [OrderedDict([('index', ''), ('set_bearer', ''), ('ue', ''), ('ip', '')])]
    setPduGw = [OrderedDict([('index', ''), ('set_pdu_gateway', ''), ('id', ''), ('ue_nat_ip', '')])]
    ueSA = [OrderedDict([('index', ''), ('set_ue simulated', ''), ('id', ''), ('suci', ''), ('cell', '')]),
            OrderedDict([('index', ''), ('ue_param', ''), ('id', '')])]
    ueNSA = [OrderedDict([('index', ''), ('set_ue simulated', ''), ('id', ''), ('imsi', '')]),
             OrderedDict([('index', ''), ('ue_param', ''), ('id', '')])]
    desiredCells = 0
    listParams = []
    listParams2 = []
    objectsToClone = ["pdnIp", "setCell", "ueSA", "ueNSA", "setPduGw", "setBearer"]

    def __init__(self):
        pass

    def getVal(self, line, param):
        params = dict((j.split("=")[0], j.split("=")[1]) for j in line.split() if "=" in j)
        if "set PDN_IP" in line:
            return list(params.values())[-1]
        StringTool.datedConsole("Basic.cfg getVal returns: {} for {}".format(params[param], param))
        return params[param]

    def calculatePci(self, oldPci):
        left = oldPci.split(":")[0]
        right = oldPci.split(":")[1]
        if right == "2":
            newPci = str(int(left)+1)+":0"
        elif int(right) < 2:
            newPci = left+":"+str(int(right)+1)
        else:
            StringTool.datedConsole("ERROR in PCI format: {}".format(oldPci))
            newPci = ""
        return newPci

    def modifLine(self, line, oldParam, newParam):
        line = line.replace(oldParam, newParam, 1)
        return line

    def calculateVal(self, param, oldVal, cell):
        if param == "gnb":
            return oldVal
        elif param == "PDN_IP" or param == "ue_nat_ip":
            lastNum = int(oldVal.split(".")[-1])+1
            dimension = len(str(lastNum))
            val = oldVal[0:-dimension]+str(lastNum)
        elif param == "pci":
            val = self.calculatePci(oldVal)
        elif param == "ip":
            val = "$PDN_IP_"+str(cell+1)
        else:
            last = str(int(oldVal[-1])+1)
            val = oldVal[0:-1]+last
        StringTool.datedConsole("Basic.Cfg Calculate Value finished: OldVal ={}. NewVal ={}."
                                " Parameter={}".format(oldVal, val, param))
        return val

    def deleteLines(self, startCmd):
        indexList = localWts.getListIdxsUsingListParam(listParams=self.listParams)
        StringTool.datedConsole("Basic.Cfg Delete {} lines in original file."
                                " In order to have one element only. Then clone it".format(str(len(indexList))))
        while len(indexList) > 1:
            if startCmd == "ueSA" or startCmd == "ueNSA":
                if localWts.config[indexList[-1]+1].startswith("ue_param id"):
                    localWts.deleteConfig(indexList[-1]+1)
                localWts.deleteConfig(indexList[-1])
                if localWts.config[indexList[-1]-1].startswith("#UE"):
                    localWts.deleteConfig(indexList[-1]-1)
                localWts.stopSession()
                localWts.startSession(basicCfgClonedPath)
            else:
                localWts.deleteConfig(indexList[-1])
                localWts.stopSession()
                localWts.startSession(basicCfgClonedPath)
            indexList = localWts.getListIdxsUsingListParam(listParams=self.listParams)

    def getModifiedLine(self, newLine, startCmd, idx, listPara, i):
        val = self.getVal(line=newLine, param=listPara)
        if listPara == "PDN_IP" and "\"" in val:
            val = val.split("\"")[1]
        exec('self.'+startCmd+'['+str(idx)+'][\"'+listPara+'\"]=\"'+str(val)+'\"')
        # self.setCell[0][self.listParams[i]] = val
        newVal = self.calculateVal(param=str(listPara), oldVal=val, cell=i)
        if listPara == "PDN_IP":
            if i > 0:
                oldParam = str(listPara)+"_"+str(i)+"=\""+str(val)+"\""
            else:
                oldParam = str(listPara)+"=\""+str(val)+"\""
            newParam = str(listPara)+"_"+str(i+1)+"=\""+newVal+"\""
        else:
            oldParam = str(listPara)+"="+str(val)
            newParam = str(listPara)+"="+newVal
        # self.setCell[0][self.listParams[i]] = newVal
        newline = self.modifLine(line=newLine, oldParam=oldParam, newParam=newParam)
        if listPara == "PDN_IP" and "\"" in newVal:
            newVal = newVal.split("\"")[1]
        exec('self.'+startCmd+'['+str(idx)+'][\"'+listPara+'\"]=\"'+str(newVal)+'\"')
        return newline

    def prepare(self, noOfCells, startCmd):
        localWts.startSession(basicCfgClonedPath)
        cmd = "self."+startCmd+"[0].keys()"
        self.listParams = list(eval(cmd))
        self.listParams.remove("index")
        self.deleteLines(startCmd=startCmd)
        indexList = localWts.getListIdxsUsingListParam(listParams=self.listParams)
        if startCmd == "ueSA" or startCmd == "ueNSA":
            cmd = "self."+startCmd+"[1].keys()"
            self.listParams2 = list(eval(cmd))
            self.listParams2.remove("index")
        return indexList[0]

    def populateLines(self, noOfCells, startCmd):
        newLines = []
        lastIndex = self.prepare(noOfCells=noOfCells, startCmd=startCmd)
        commandLine = localWts.getConfigLineUsingIndex(lastIndex, startingChar=0)
        newline = commandLine
        if startCmd == "ueSA" or startCmd == "ueNSA":
            commandLine2 = localWts.getConfigLineUsingIndex(lastIndex+1, startingChar=0)
            newline2 = commandLine2
        strIdx = str(lastIndex)
        exec('self.'+startCmd+'[0][\"index\"]='+strIdx)
        for j in range(0, noOfCells-1):
            StringTool.datedConsole("Basic.Cfg Modification for cell {}".format(str(j+1)))
            for i in range(1, len(self.listParams)):
                newline = self.getModifiedLine(newLine=newline, startCmd=startCmd, idx=0,
                                               listPara=self.listParams[i], i=j)
                StringTool.datedConsole("Basic.Cfg Adding line {}".format(newline))
            if startCmd == "ueSA" or startCmd == "ueNSA":
                if startCmd == "ueNSA":
                    commentLine = str("#UE id=1{} {}").format(j+2, startCmd)
                else:
                    commentLine = str("#UE id={} {}").format(j+2, startCmd)
                for i in range(1, len(self.listParams2)):
                    newline2 = self.getModifiedLine(newLine=newline2, startCmd=startCmd, idx=1,
                                                    listPara=self.listParams2[i], i=j)
                    StringTool.datedConsole("Basic.Cfg Adding line {}".format(newline2))
                newLines.append(commentLine)
            newLines.append(newline)
            if 'newline2' in locals():
                newLines.append(newline2)
        for i in range(1, len(newLines)+1):
            idxToWrite = lastIndex+i+1 if startCmd == "ueSA" or startCmd == "ueNSA" else lastIndex+i
            if ("\n") in newLines[i-1]:
                linetoadd = newLines[i-1].rstrip("\n")
            else:
                linetoadd = newLines[i-1]
            localWts.insertConfig(cfg=linetoadd, line=idxToWrite)
        localWts.stopSessionInNewFile(basicCfgClonedPath)

    def cloneModifyBasicCfg(self, noOfCells):
        for basiCfgObj in self.objectsToClone:
            StringTool.datedConsole("Basic.Cfg Modification for {}".format(basiCfgObj))
            self.populateLines(noOfCells=noOfCells, startCmd=basiCfgObj)

    def modifyNwslice(self):
        localWts.stopSession()
        localWts.startSession(basicCfgClonedPath)
        indexList = localWts.getListIdxsUsingListParam(listParams=["set_nwslice id=1"])
        commandLine = localWts.getConfigLineUsingIndex(indexList[-1], startingChar=0)
        val = self.getVal(line=commandLine, param="ue")
        localWts.replaceValue(prefix="set_nwslice", param="ue", oldValue=val, newValue="all")


def calculatePath(basePath):
    global initialFileName
    global initialFilePath
    initialFileName = basePath.split('/')[-1].strip()
    initialFilePath = basePath.split(initialFileName)[0]
    return initialFilePath


def createMultipleCellIphy(iphyBasePath, cablingAP, suffixName="XmlMultiCellCreator"):
    calculatePath(basePath=iphyBasePath)
    desiredRE = len(cablingAP)
    global existingRE
    localXml.startSession(path=iphyBasePath)
    existingRE = localXml.countElt(path=rePath, debug=False)
    itterationOfRe = desiredRE - existingRE
    finalName = initialFilePath+"IPHY_modified_"+str(desiredRE)+"cells_"+suffixName+".xml"
    if itterationOfRe > 0:
        StringTool.datedConsole("\n #### START IPHY.xml clonning. It will add {} more cells on existing "
                                "{} cells".format(itterationOfRe, existingRE))
        iphyCloned = CloneModifyIphy().cloneRE(initialIphy=iphyBasePath, itterationOfRe=itterationOfRe)
        finalIphy = CloneModifyIphy().modifyFinalValues(initialIphy=iphyBasePath,
                                                        clonedIphy=iphyCloned, cablingAP=cablingAP,
                                                        finalIphy=finalName)
        os.remove(iphyCloned)
    else:
        StringTool.datedConsole("ERROR: On base iphy exists {} cells. You ask to create iphy with {} cells- "
                                "Operation impossible.Existing cells should be < than "
                                "desired.".format(existingRE, desiredRE))
        return
    StringTool.datedConsole("\n#### New Iphy.xml creation END: {}".format(finalIphy))
    return finalIphy


# To be DELETED when Airphone.xml dissapears
def createMultipleCellApXml(apXmlBasePath, noOfCells=5, suffixName="XmlMultiCellCreator"):
    initialFilePath = calculatePath(basePath=apXmlBasePath)
    localXml.startSession(apXmlBasePath)
    existingCells = localXml.countElt(path=cellApXml)
    desiredCells = noOfCells-existingCells
    if desiredCells > 0:
        StringTool.datedConsole("\n#### START creating Airphone.xml. It will contain "
                                "{} cells ".format(noOfCells))
        lastCellId = localXml.getAttrValByIndex(path=cellApXml, attr_name="cellId",
                                                index=existingCells-1, debug=False)
        lastphysCellId = localXml.getAttrValByIndex(path=cellApXml, attr_name="physCellId",
                                                    index=existingCells-1, debug=False)
        for i in range(0, desiredCells):
            localXml.addTree(path=cellApXml)
        for i in range(0, desiredCells):
            localXml.addTree(path=cellGroupApXml)
        clonedPath = initialFilePath+"_cloned.xml"
        localXml.stopSessionInNewFile(clonedPath)
        localXml.startSession(clonedPath)
        for i in range(0, desiredCells):
            localXml.setText(path='{}[@index="{}"]/cellId'.format(cellApXml, existingCells+i),
                             val=str(int(lastCellId)+i+1), debug=False)
            localXml.setText(path='{}[@index="{}"]/physCellId'.format(cellApXml, existingCells+i),
                             val=str(int(lastphysCellId)+i+1), debug=False)
            # localXml.setText(path='{}[@index="{}"]/cellGroupId'.format(cellGroupApXml, existingCells+i),
            #                  val=str(int(lastphysCellId)+i+1))
        modifiedPath = initialFilePath+"APxml_modified_"+str(noOfCells)+"cells_"+suffixName+".xml"
        localXml.stopSessionInNewFile(modifiedPath)
        os.remove(clonedPath)
    else:
        StringTool.datedConsole("ERROR: On base airphone.xml exists {} cells. You ask to create ap.xml with {} cells- "
                                "Operation impossible.Existing cells should be < than "
                                "desired.".format(existingCells, desiredCells))
        return
    StringTool.datedConsole("\n#### New Airphone.xml creation END: {}".format(modifiedPath))
    return modifiedPath


def createMultipleCellBasicCfg(basicCfgBasePath, noOfCells=6, suffixName="XmlMultiCellCreator"):
    initialFilePath = calculatePath(basePath=basicCfgBasePath)
    global basicCfgClonedPath
    basicCfgClonedPath = initialFilePath+"BasicCfg_modified_"+str(noOfCells)+"cells_"+suffixName+".cfg"
    localWts.startSession(basicCfgBasePath)
    existingCells = len(localWts.getListIdxsUsingListParam(listParams=["set_cell", "nrci"]))
    localWts.stopSessionInNewFile(basicCfgClonedPath)
    if noOfCells > existingCells:
        StringTool.datedConsole("\n#### START creating {}. It will contain {} "
                                "cells ".format(basicCfgClonedPath, noOfCells))
        CloneModifyBasicCfg().cloneModifyBasicCfg(noOfCells=noOfCells)
        CloneModifyBasicCfg().modifyNwslice()
        localWts.stopSessionInNewFile(basicCfgClonedPath)
    else:
        StringTool.datedConsole("ERROR: On base basic.cfg exists {} cells. You ask to create file with {} cells- "
                                "Operation impossible.Existing cells should be < than "
                                "desired.".format(existingCells, noOfCells))
        return
    StringTool.datedConsole("\n##### New BasicWTS.cfg creation END: {}".format(basicCfgClonedPath))
    return basicCfgClonedPath
