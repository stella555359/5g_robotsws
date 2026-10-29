import os
import sys
import pytest

# multiCellDir = os.path.abspath(__file__).split("pytest")[0]
# sys.path.insert(0, multiCellDir)
# import XmlMultiCellCreator
# import XmlConfig as localXml

localXml = localXml.XmlConfig()

iphyPath = "/ebs/alinaro/my_virtual_env/robotws/testsuite/Paris/" \
           "resources/SWENG/python/pytest/testMultiCell/iphy.xml"
iphyPath2 = "/ebs/alinaro/my_virtual_env/robotws/testsuite/Paris/resources/" \
            "SWENG/python/pytest/testMultiCell/blaaaa.xml"
apXmlPath = "/ebs/alinaro/my_virtual_env/robotws/testsuite/Paris/" \
           "resources/SWENG/python/pytest/testMultiCell/AirphoneConfig.xml"

basicCfgPath = "/ebs/alinaro/my_virtual_env/robotws/testsuite/Paris/" \
           "resources/SWENG/python/pytest/testMultiCell/basic_setup.cfg"

cablingAP2 = ["1.1", "2.9", "3.10"]
cablingAP3 = ["1.1", "1.10", "2.9", "2.10", "3.9", "3.10"]

# print("##################### TOTO 1")
# toto0 = XmlMultiCellCreator.Cell(iphyPath=iphyPath, reId=1)
# print("serialno ={}".format(toto0.serialno))
# print("physicalId={}".format(toto0.physicalId))
# print("cell ={}".format(toto0.cell))
# print("phy_cell_id = {}".format(toto0.phy_cell_id))
# print("virtualId = {}".format(toto0.virtualId))
# print("##################### TOTO 2")
# toto = XmlMultiCellCreator.Cell(iphyPath=iphyPath)
# print("serialno ={}".format(toto.serialno))
# print("physicalId={}".format(toto.physicalId))
# print("cell ={}".format(toto.cell))
# print("phy_cell_id = {}".format(toto.phy_cell_id))
# print("virtualId = {}".format(toto.virtualId))
# print("##################### TOTO 2")
# toto2 = XmlMultiCellCreator.Cell(iphyPath=iphyPath, reId=3, newRE=True, lastExistingObj=toto)
# print("serialno ={}".format(toto2.serialno))
# print("physicalId={}".format(toto2.physicalId))
# print("cell ={}".format(toto2.cell))
# print("phy_cell_id = {}".format(toto2.phy_cell_id))
# print("virtualId = {}".format(toto2.virtualId))


def checkValues(iphyPath):
    localXml.startSession(iphyPath)
    refCell = XmlMultiCellCreator.Cell(reId=3)
    y = 1
    for i in range(4, len(cablingAP3)+1):
        cell = XmlMultiCellCreator.Cell(reId=i)
        assert cell.physicalId == cablingAP3[i-1]
        assert cell.virtualId == str(int(refCell.virtualId) + y)
        assert cell.phy_cell_id == str(int(refCell.phy_cell_id) + y)
        y += 1


def testIPHY_2Cellsto6cells():
    newIphy = XmlMultiCellCreator.createMultipleCellIphy(iphyBasePath=iphyPath, cablingAP=cablingAP3)
    # checkValues(newIphy)


def testIPHY_1Cellsto3cells():
    newIphy = XmlMultiCellCreator.createMultipleCellIphy(iphyBasePath=iphyPath, cablingAP=cablingAP2)
    # checkValues(newIphy)


def testBasicCfg_For3Cells():
    XmlMultiCellCreator.createMultipleCellBasicCfg(basicCfgBasePath=basicCfgPath, noOfCells=3)


def testBasicCfg_For6Cells():
    XmlMultiCellCreator.createMultipleCellBasicCfg(basicCfgBasePath=basicCfgPath, noOfCells=6)


def testApXML_For3Cells():
    XmlMultiCellCreator.createMultipleCellApXml(apXmlBasePath=apXmlPath, noOfCells=3)


def testApXML_For6Cells():
    XmlMultiCellCreator.createMultipleCellApXml(apXmlBasePath=apXmlPath, noOfCells=6)


testIPHY_2Cellsto6cells()
testIPHY_1Cellsto3cells()
testBasicCfg_For3Cells()
testBasicCfg_For6Cells()
testApXML_For3Cells()
testApXML_For6Cells()
