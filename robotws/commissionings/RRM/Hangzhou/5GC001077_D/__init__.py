import os

# from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1')
]

MODIFY_SCF_MCS27_256QAM = [
    dict(
        value='27',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='27',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='true',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='actDl256Qam'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1',
        p_name='rfSharingEnabled'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1',
        p_name='systemAcctPermEnable'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab5Nsa3x',
        p_name='dlFlowControlAlgo'),
    dict(
        value='40MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='chBw')
]

MODIFY_SCF_517_AB_1 = [
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='flexible',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='1Symbol',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio')
]

MODIFY_SCF_517_AB_2 = [
    dict(
        value='11',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='flexible',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='1Symbol',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio')
]

MODIFY_SCF_517_AB_3 = [
    dict(
        value='18',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='flexible',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='1Symbol',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio')
]

MODIFY_SCF_517_AB_4_and_7 = [
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='flexible',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='1Symbol',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio')
]

MODIFY_SCF_517_AB_5 = [
    dict(
        value='11',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='flexible',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='1Symbol',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio')
]

MODIFY_SCF_517_AB_6 = [
    dict(
        value='18',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='flexible',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='1Symbol',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio')
]

#        R&D parameters setting:
#        0x460019=1   set UL rank=1   rdUlRank = 1
#        0x460017=1   set DL rank=1   rdDlRank = 1
#        0x460011=0   rdActIllaDl = 0
#        0x460013=0   rdActOllaDl = 0
#        0x460012=0   rdActIllaUl = 0
#        0x460014=0   rdActOllaUl = 0
#        0x4600CC=16  rdSelect256QamTbsTable (not applicable now)
#        0x46010F=0   rdEnableMcsPrbReduction
#        0x100011=0   disable CSI-RS(does not contain this after master 0.835.438)
#        532 2*2 ul mimo in order to activate SRS when rank 1
#        0x460041=1
#        rdUlTpmiRank1:0 to 5
#        0x46010d = 0
#        rdUlTpmiRank1:0 to 5
#        0x46010e = 0

SWCONFIG_PARA_517_AB_4 = [
    '0x460019=1',
    '0x460017=1',
    '0x460011=0',
    '0x460013=0',
    '0x460012=0',
    '0x460014=0',
    '0x46010F=0',
    '0x46010d=0',
    '0x46010e=0',
    '0x460041=1'
]

#    R&D parameters setting:
#    0x460019=2   set UL rank=2   rdUlRank = 2
#    0x460017=2   set DL rank=2   rdDlRank = 2
#    0x460011=0   rdActIllaDl = 0
#    0x460013=0   rdActOllaDl = 0
#    0x460012=0   rdActIllaUl = 0
#    0x460014=0   rdActOllaUl = 0
#    0x4600CC=16  rdSelect256QamTbsTable (not applicable now)
#    0x46010F=0   rdEnableMcsPrbReduction
#    0x100011=0   disable CSI-RS(does not contain this after master 0.835.438)
#    rdUlTpmiRank1:0 to 5
#    0x46010d = 0
#    rdUlTpmiRank1:0 to 5
#    0x46010e = 0
#    same for AB_5 AB_6

SWCONFIG_PARA_517_AB_RANK2 = [
    '0x460019=2',
    '0x460017=2',
    '0x460011=0',
    '0x460013=0',
    '0x460012=0',
    '0x460014=0',
    '0x46010F=0',
    '0x46010d=0',
    '0x46010e=0'
]


#    R&D parameters setting:
#    0x460019=1   set UL rank=1   rdUlRank = 1
#    0x460017=1   set DL rank=1   rdDlRank = 1
#    0x460011=0   rdActIllaDl = 0
#    0x460013=0   rdActOllaDl = 0
#    0x460012=0   rdActIllaUl = 0
#    0x460014=0   rdActOllaUl = 0
#    0x4600CC=16  rdSelect256QamTbsTable
#    0x46010F=0   rdEnableMcsPrbReduction
#    0x100011=0   disable CSI-RS(does not contain this after master 0.835.438)
#    rdUlTpmiRank1:0 to 5
#    0x46010d = 0
#    rdUlTpmiRank1:0 to 5
#    0x46010e = 0
#    prb is 128 in case AB_124
#    0x460018=128   rdUlNumberPrb

SWCONFIG_PARA_517_AB_124 = [
    '0x460019=1',
    '0x460017=1',
    '0x460011=0',
    '0x460013=0',
    '0x460012=0',
    '0x460014=0',
    '0x46010F=0',
    '0x46010d=0',
    '0x46010e=0',
    '0x460041=1',
    '0x460018=128'
]

#    R&D parameters setting:
#    0x460019=1   set UL rank=1   rdUlRank = 1
#    0x460017=1   set DL rank=1   rdDlRank = 1
#    0x460011=0   rdActIllaDl = 0
#    0x460013=0   rdActOllaDl = 0
#    0x460012=0   rdActIllaUl = 0
#    0x460014=0   rdActOllaUl = 0
#    0x4600CC=16  rdSelect256QamTbsTable
#    0x46010F=0   rdEnableMcsPrbReduction
#    0x100011=0   disable CSI-RS(does not contain this after master 0.835.438)
#    rdUlTpmiRank1:0 to 5
#    0x46010d = 0
#    rdUlTpmiRank1:0 to 5
#    0x46010e = 0
#    enable harq for dl cases due to msg required from via
#    ERadParamIndexL2PS_rdHARQDisable
#    0x460002=0
#    rdDisablePucchReceiveReq
#    0x460121=0

SWCONFIG_PARA_517_AB_1 = [
    '0x460019=1',
    '0x460017=1',
    '0x460011=0',
    '0x460013=0',
    '0x460012=0',
    '0x460014=0',
    '0x46010F=0',
    '0x46010d=0',
    '0x46010e=0',
]

#    R&D parameters setting:
#    0x460019=2   set UL rank=2   rdUlRank = 2
#    0x460017=2   set DL rank=2   rdDlRank = 2
#    0x460011=0   rdActIllaDl = 0
#    0x460013=0   rdActOllaDl = 0
#    0x460012=0   rdActIllaUl = 0
#    0x460014=0   rdActOllaUl = 0
#    0x4600CC=16  rdSelect256QamTbsTable (not applicable now)
#    0x46010F=0   rdEnableMcsPrbReduction
#    0x100011=0   disable CSI-RS(does not contain this after master 0.835.438)
#    rdUlTpmiRank1:0 to 5
#    0x46010d = 0
#    rdUlTpmiRank1:0 to 5
#    0x46010e = 0
#    enable harq for dl cases due to msg required from via
#    ERadParamIndexL2PS_rdHARQDisable
#    0x460002=0
#    rdDisablePucchReceiveReq
#    0x460121=0
#    enable harq for dl cases due to msg required from via
#    ERadParamIndexL2PS_rdHARQDisable
#    0x460002=0
#    rdDisablePucchReceiveReq
#    0x460121=0
#    same for AB_2 AB_3

SWCONFIG_PARA_517_AB_RANK2_DL = [
    '0x460019=2',
    '0x460017=2',
    '0x460011=0',
    '0x460013=0',
    '0x460012=0',
    '0x460014=0',
    '0x46010F=0',
    '0x46010d=0',
    '0x46010e=0',
]
