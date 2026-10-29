# -*- coding: utf-8 -*
#        R&D parameters setting:
#        0x580019=1   set UL rank=1   rdUlRank = 1
#        0x580017=1   set DL rank=1   rdDlRank = 1
#        0x580011=0   rdActIllaDl = 0
#        0x580013=0   rdActOllaDl = 0
#        0x580012=0   rdActIllaUl = 0
#        0x580014=0   rdActOllaUl = 0
#        0x4600CC=16  rdSelect256QamTbsTable (not applicable now)
#        0x46010F=0   rdEnableMcsPrbReduction
#        0x100011=0   disable CSI-RS(does not contain this after master 0.835.438)
#        532 2*2 ul mimo in order to activate SRS when rank 1
#        0x460041=1
#        rdUlTpmiRank1:0 to 5
#        0x46010d = 0
#        rdUlTpmiRank1:0 to 5
#        0x46010e = 0
#        0x10000c=0    Disable DL PTRS for FR1 only(cmw)
#        0x46000E=130048 rdSupportedDl64QamMcs = 0x1FC00   supported DL mcs is mcs10...mcs16
#        0x580025      ,rdEarlyDllaStepDown
#        0x580145     ,rdIsDlPtrsEnabledInCellForFr1
#        0x580171     ,rdActNewMappingTables
#        0x580032     ,rdActivateATB
#        0x580010     ,rdSupportedUlMCS
#        0x580146     ,rdIsUlPtrsEnabledInCellForFr1

#
SWCONFIG_2040_1000_01 = [
    '0x580011=0',
    '0x580013=1',
    '0x580015=663',
    '0x580017=2',
    '0x58000E=0x1FC00',
    '0x580145=0',
    '0x580171=1'
]

SWCONFIG_2040_1000_02 = [
    '0x580012=1',
    '0x580014=1',
    '0x580032=1',
    '0x580010=0x1FFFFFFF',
    '0x580146=0',
    '0x580171=1'
]

SWCONFIG_2040_1000_05 = [
    '0x580171=1'
]


SWCONFIG_2040_1000_07 = [
    '0x580012=1',
    '0x580014=1',
    '0x580032=1',
    '0x580171=1',
    '0x580010=0x1FFFFFFF',
    '0x580146=0',
    '0x580171=1',
    '0x580019=1'
]

SWCONFIG_2040_1000_08 = [
    '0x580017=1',
    '0x580011=0',
    '0x580013=0',
    '0x580012=0',
    '0x580171=1',
    '0x580014=0'
]


SWCONFIG_2040_1000_09 = [
    '0x580011=0',
    '0x580013=0',
    '0x580171=1'
]

SWCONFIG_2040_1000_10 = [
    '0x580012=0',
    '0x580014=0',
    '0x580171=1'
]

SWCONFIG_2040_1000_03 = [
    '#0x580011=1',
    '#0x580013=1',
    '#0x58000E=0x1FFFFFFF',
    '#0x580025=1',
    '0x580171=1',
    '#0x580145=0'
]
SWCONFIG_2040_1000_04 = [
    '#0x580011=1',
    '#0x580013=1',
    '#0x58000E=0x1FFFFFFF',
    '#0x580025=1',
    '0x580171=1',
    '#0x580145=0'
]
SWCONFIG_2040_1000_06 = [
    '#0x580011=1',
    '#0x580013=1',
    '#0x58000E=0x1FFFFFFF',
    '#0x580025=1',
    '0x580171=1',
    '#0x580145=0'
]

SWCONFIG_2040_1138_06 = [
    '0x580171=1'
]

SWCONFIG_2040_1138_03 = [
    '0x580171=1'
]
