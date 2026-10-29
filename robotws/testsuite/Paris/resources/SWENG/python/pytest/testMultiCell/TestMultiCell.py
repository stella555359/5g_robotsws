import os
import sys
import pytest

# multiCellDir = os.path.abspath(__file__).split("pytest")[0]
# sys.path.insert(0, multiCellDir)
# import ScfMultiCellsCreator


scf1cell = "SCF_1cell.xml"
scf2cell = "SCF_2cell.xml"

scfPath1cell = multiCellDir + "pytest/testMultiCell/" + scf1cell
scfPath2cell = multiCellDir + "pytest/testMultiCell/" + scf2cell


def checkValues(scfPath, channelConfig=22):
    referenceCell = ScfMultiCellsCreator.ExistingCells(scfPath)
    existingNoOfCells = referenceCell.existingNumOfCells
    for i in range(1, existingNoOfCells + 1):
        refCell = ScfMultiCellsCreator.ExistingCells(scfPath, cellId=i)
        assert refCell.MRBTSname == "MRBTS-1"
        assert refCell.RMODDN == "MRBTS-1/EQM-1/APEQM-1/RMOD-" + str(i)
        assert refCell.NRCELLDN == "MRBTS-1/NRBTS-1/NRCELL-" + str(i)
        assert refCell.Antl1 == "MRBTS-1/EQM-1/APEQM-1/RMOD-" + str(i) + "/ANTL-1"
        assert refCell.Antl2 == "MRBTS-1/EQM-1/APEQM-1/RMOD-" + str(i) + "/ANTL-2"
        assert refCell.Antl3 == "MRBTS-1/EQM-1/APEQM-1/RMOD-" + str(i) + "/ANTL-3"
        assert refCell.Antl4 == "MRBTS-1/EQM-1/APEQM-1/RMOD-" + str(i) + "/ANTL-4"
        assert refCell.channel1 == "MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-" + str(i) \
                                   + "/CHANNELGROUP-1/CHANNEL-1"
        assert refCell.channel2 == "MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-" + str(i) \
                                   + "/CHANNELGROUP-1/CHANNEL-2"
        if channelConfig == 44:
            assert refCell.channel8 == "MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-" + str(
                i) + "/CHANNELGROUP-1/CHANNEL-8"
        assert refCell.NRCELLGRPDN == "MRBTS-1/NRBTS-1/NRCELLGRP-" + str(i - 1)


def test4ul4dl():
    ScfMultiCellsCreator.dispalySCFInfo(scfPath=scfPath1cell)
    newScfCreated = ScfMultiCellsCreator.createMultipleCellScf(scfBasePath=scfPath1cell,
                                                               desiredNumOfCells=6, channelConfig="4UL4DL")
    checkValues(scfPath=newScfCreated, channelConfig=44)
    # MultiCellsCreator.dispalySCFInfo(scfPath=newScfCreated)


def test2ul2dl():
    ScfMultiCellsCreator.dispalySCFInfo(scfPath=scfPath1cell)
    newScfCreated = ScfMultiCellsCreator.createMultipleCellScf(scfBasePath=scfPath1cell,
                                                               desiredNumOfCells=6, channelConfig="2UL2DL")
    checkValues(scfPath=newScfCreated, channelConfig=22)
    # MultiCellsCreator.dispalySCFInfo(scfPath=newScfCreated)


def test4ul4dl_StartingWith_2cells():
    ScfMultiCellsCreator.dispalySCFInfo(scfPath=scfPath2cell)
    newScfCreated = ScfMultiCellsCreator.createMultipleCellScf(scfBasePath=scfPath2cell,
                                                               desiredNumOfCells=6, channelConfig="4UL4DL")
    checkValues(scfPath=newScfCreated, channelConfig=44)
    # MultiCellsCreator.dispalySCFInfo(scfPath=newScfCreated)


# test4ul4dl()
# test2ul2dl()
# test4ul4dl_StartingWith_2cells()
ScfMultiCellsCreator.dispalySCFInfo(scfPath=scfPath2cell)
