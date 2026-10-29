# -*- coding: utf-8 -*
#          1200_A common required while not show up in QT
#          ***1 enable DlHarqDtx***
#          rdDlHarqDtxEnabled                                        0x580149=1      (0:disable DlHarqDtx)
#          ***2 enable CsiDtx***
#          rdCsiDtxEnabled                                           0x580150=1      (0:disable CsiDtx)
#          ***3 enable PucchDataDtx***
#          rdPuschDataDtxEnabled                                     0x580151=1      (0:disable PuschDataDtx)
#          ***4 configure UlSplitWaiterExpriyTimer***
#          rdUlSplitWaiterExpiryTime                                 0x580152=1000   (unit:ms)
#          ***5 disable feature 532***
#          rdEnableUlDynTransmissionScheme (feature 532)             0x580041=0
#          enable HARQ and PUCCH
#          ERadParamIndexL2PS_rdHARQDisable                          0x580002=0
#          rdDisablePucchReceiveReq                                  0x580121=0


SWCONFIG_PARA_1200_A_COMMON = [
    '0x580002=0',
    '0x580121=0'
]

#          For 1200-A-105
#          ***1 enable DlHarqDtx***
#          rdDlHarqDtxEnabled=true                                   0x580149=1      (0:disable DlHarqDtx)
#          ***2 disable CsiDtx***
#          rdCsiDtxEnabled=false                                     0x580150=0      (0:disable CsiDtx)
#          ***3 disable PucchDataDtx***
#          rdPuschDataDtxEnabled=false                               0x580151=0      (0:disable PuschDataDtx)

SWCONFIG_PARA_1200_A_105 = [
    '0x580149=1',
    '0x580150=0',
    '0x580151=0'
]

#          For 1200-A-106
#          ***1 disable DlHarqDtx***
#          rdDlHarqDtxEnabled=false                                   0x580149=0      (0:disable DlHarqDtx)
#          ***2 enable CsiDtx***
#          rdCsiDtxEnabled=true                                       0x580150=1      (0:disable CsiDtx)
#          ***3 disable PucchDataDtx***
#          rdPuschDataDtxEnabled=false                                0x580151=0      (0:disable PuschDataDtx)
#          ***4 active Csi***
#          rdActivatePerCsi=true                                      0x5800F3=1      (0:Deactive Csi)

SWCONFIG_PARA_1200_A_106 = [
    '0x580149=0',
    '0x580150=1',
    '0x580151=0',
    '0x5800F3=1'
]

#          For 1200-A-113
#          ***1 disable DlHarqDtx***
#          rdDlHarqDtxEnabled=false                                    0x580149=0      (0:disable DlHarqDtx)
#          ***2 disable CsiDtx***
#          rdCsiDtxEnabled=false                                       0x580150=0      (0:disable CsiDtx)
#          ***3 enable PucchDataDtx***
#          rdPuschDataDtxEnabled=true                                  0x580151=1      (0:disable PuschDataDtx)

SWCONFIG_PARA_1200_A_113 = [
    '0x580149=0',
    '0x580150=0',
    '0x580151=1'
]

#          For 1200-A-114
#          ***1 enable DlHarqDtx***
#          rdDlHarqDtxEnabled=true                                      0x580149=1      (0:disable DlHarqDtx)
#          ***2 enable CsiDtx***
#          rdCsiDtxEnabled=true                                         0x580150=1      (0:disable CsiDtx)
#          ***3 disable PucchDataDtx***
#          rdPuschDataDtxEnabled=false                                  0x580151=0      (0:disable PuschDataDtx)

SWCONFIG_PARA_1200_A_114 = [
    '0x580149=1',
    '0x580150=1',
    '0x580151=0'
]


#          For 1200-A-107_108_401
#          ***1 enable DlHarqDtx***
#          rdDlHarqDtxEnabled=true                                   0x580149=1      (0:disable DlHarqDtx)
#          ***2 disable CsiDtx***
#          rdCsiDtxEnabled=false                                     0x580150=0      (0:disable CsiDtx)
#          ***3 disable PucchDataDtx***
#          rdPuschDataDtxEnabled=false                               0x580151=0      (0:disable PuschDataDtx)
#          ***4 configure UlSplitWaiterExpriyTimer***
#          rdUlSplitWaiterExpiryTime                                 0x580152=5   (unit:ms)

SWCONFIG_PARA_1200_A_107_108_401 = [
    '0x580152=5',
    '0x580002=0',
    '0x580121=0'
]


#          1200_B common required while not show up in QT
#          ***1 enable DlHarqDtx***
#          rdDlHarqDtxEnabled                                        0x580149=1      (0:disable DlHarqDtx)
#          ***2 enable CsiDtx***
#          rdCsiDtxEnabled                                           0x580150=0      (0:disable CsiDtx)
#          ***3 enable PucchDataDtx***
#          rdPuschDataDtxEnabled                                     0x580151=0      (0:disable PuschDataDtx)
#          ***4 configure UlSplitWaiterExpriyTimer***
#          rdUlSplitWaiterExpiryTime                                 0x580152=1000   (unit:ms)
#          ***5 enable Multi PHR***
#          RAD param added for ET 1336 testing                       0x580136=1      (0:disable 1336)

SWCONFIG_PARA_1200_B_COMMON = [
    '0x580002=0',
    '0x580121=0'
]

SWCONFIG_PARA_1200_B_204 = [
    '0x580002=0',
    '0x580121=0',
    '0x580152=10'
]

SWCONFIG_PARA_1200_ENABLE_DTX = [
    '0x580002=0',
    '0x580121=0',
    '0x580149=1',
    '0x580150=1',
    '0x580151=1'
]
