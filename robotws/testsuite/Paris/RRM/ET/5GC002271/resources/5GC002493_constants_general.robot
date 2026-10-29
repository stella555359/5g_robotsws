*** Settings ***
Documentation
...               Variables settings for 5GC002493 General

*** Variables ***
# Dictionary for Test Case 5GC002493_A001
&{DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE1}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.startSymbol=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.mcs"=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002
...                                                   DlData_PdschSendReq.grants_item_0.mcsTable=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.startPrb=0x00000003


# Dictionary for Test Case 5GC002493_A001
&{DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE2}        DlData_PdschSendReq.grants_item_0.rnti=0x00000001
...                                                   DlData_PdschSendReq.grants_item_0.startSymbol=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.mcs"=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.mcsTable=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002



# Dictionary for Test Case 5GC002493_A001
&{DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE3}        DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                   DlData_PdschSendReq.grants_item_0.startSymbol=0x00000002
...                                                   DlData_PdschSendReq.grants_item_0.mcs"=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.mcsTable=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002
...                                                   DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                                   DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000003


&{DICTONARY_PUCCHRECEIVEREQ_IE_5GC002493}       UlData_PucchReceiveReq.subcells-Length=0x00000001
...											    UlData_PucchReceiveReq.subcells_item_0.subcellId=0x00000000
...											    UlData_PucchReceiveReq.pucchResources-Length=0x00000001
...											    UlData_PucchReceiveReq.pucchResources_item_0.rnti=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.numOfLayers=0x00000001
...											    UlData_PucchReceiveReq.pucchResources_item_0.numOfAntennaPorts=0x00000001
...											    UlData_PucchReceiveReq.pucchResources_item_0.harqProcessIndex=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.startPrb=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.initialCyclicShift=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.numCeAxCIndex=0x0000002
...                                             UlData_PucchReceiveReq.pucchResources_item_0.timeDomainOcc=0x00000000


&{DICTONARY_PUCCHRECEIVEREQ_F2_ACK_IE_5GC002493}         UlData_PucchReceiveReq.pucchResources_item_0.pucchFormat=0x00000002
...											             UlData_PucchReceiveReq.pucchResources_item_0.numOfPrb=0x00000004
#...											           UlData_PucchReceiveReq.pucchResources_item_0.srBitDetection=0x00000000
#...											             UlData_PucchReceiveReq.pucchResources_item_0.nANPucch=0x00000004
...											             UlData_PucchReceiveReq.pucchResources_item_0.firstSymbol=0x0000000d
...											             UlData_PucchReceiveReq.pucchResources_item_0.numOfBitsOfUciInformation=0x00000004
#...											             UlData_PucchReceiveReq.pucchResources_item_0.numOfSymbols=0x00000001
#...											             UlData_PucchReceiveReq.pucchResources_item_0.frequencyHopping=0x00000000


&{DICTONARY_PUCCHRECEIVEREQ_F0_ACK_IE_5GC002493}                UlData_PucchReceiveReq.pucchResources_item_0.pucchFormat=0x00000000
...											                    UlData_PucchReceiveReq.pucchResources_item_0.numOfPrb=0x00000001
...											                    UlData_PucchReceiveReq.pucchResources_item_0.srBitDetection=0x00000000
#...											                    UlData_PucchReceiveReq.pucchResources_item_0.nANPucch=0x00000001
...											                    UlData_PucchReceiveReq.pucchResources_item_0.firstSymbol=0x0000000d
...											                    UlData_PucchReceiveReq.pucchResources_item_0.numOfBitsOfUciInformation=0x00000001
#...											                    UlData_PucchReceiveReq.pucchResources_item_0.numOfSymbols=0x00000001
#...											                    UlData_PucchReceiveReq.pucchResources_item_0.frequencyHopping=0x00000000


&{DICTIONARY_DLCELL_SETUP_REQ_CL_2x2}                  DlCell_SetupReq.SetupReq.dlMimoMode=0x00000000

&{DICTIONARY_DLCELL_SETUP_REQ_CL_4x4_4x2}              DlCell_SetupReq.SetupReq.dlMimoMode=0x00000001

#TM3.1 / TM3.1a/ TM1.1
&{DL_PDSCHSENDREQ_TM3_1_TM3_1A_TM1_1_TDD_UE1_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                                           DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000082
...                                                                           DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a

&{DL_PDSCHSENDREQ_TM3_1_TM3_1A_TM1_1_TDD_UE2_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                                           DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a


# TM1.1 - 50MHZ
&{DL_PDSCHSENDREQ_TM1_1_TDD_UE1_C_50MHz_antPort_ver}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000082
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a
...                                                              DlData_PdschSendReq.grants_item_0.antPort=0xc000
...                                                              DlData_PdschSendReq.grants_item_0.numOfLayers=0x02

&{DL_PDSCHSENDREQ_TM1_1_TDD_UE2_C_50MHz_antPort_ver}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a
...                                                              DlData_PdschSendReq.grants_item_0.antPort=0xc000
...                                                              DlData_PdschSendReq.grants_item_0.numOfLayers=0x02

# TM1.1 - 70MHZ
&{DL_PDSCHSENDREQ_TM1_1_TDD_UE1_C_70MHz_antPort_ver}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x000000ba
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a
...                                                              DlData_PdschSendReq.grants_item_0.antPort=0xc000
...                                                              DlData_PdschSendReq.grants_item_0.numOfLayers=0x02

&{DL_PDSCHSENDREQ_TM1_1_TDD_UE2_C_70MHz_antPort_ver}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a
...                                                              DlData_PdschSendReq.grants_item_0.antPort=0xc000
...                                                              DlData_PdschSendReq.grants_item_0.numOfLayers=0x02

&{DL_PDSCHSENDREQ_TM1_1_TDD_UE1_C_90MHz_antPort_ver}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x000000f2
...                                                              DlData_PdschSendReq.grants_item_0.antPort=0xc000
...                                                              DlData_PdschSendReq.grants_item_0.numOfLayers=0x02

&{DL_PDSCHSENDREQ_TM1_1_TDD_UE2_C_90MHz_antPort_ver}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165
...                                                              DlData_PdschSendReq.grants_item_0.antPort=0xc000
...                                                              DlData_PdschSendReq.grants_item_0.numOfLayers=0x02

# TM3.3
&{DL_PDSCHSENDREQ_TM3.3_TDD_UE1_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000001
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x0000008
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000040
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x186
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000008
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x0000008

&{DL_PDSCHSENDREQ_TM3.3_TDD_UE2_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000042
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x133
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000008
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x0000005

&{DL_PDSCHSENDREQ_TM3.3_TDD_UE3_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a


# TM1.2
&{DL_PDSCHSENDREQ_TM1.2_TDD_UE1_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x0000008
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000030
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x12c
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000008
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x0000008

&{DL_PDSCHSENDREQ_TM1.2_TDD_UE2_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000001
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000052
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x16e
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000008
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x0000005

&{DL_PDSCHSENDREQ_TM1.2_TDD_UE3_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a

# TM 1.1 3.1 3.1A 70MHz
&{DL_PDSCHSENDREQ_TM1_1_TM_3_1_TM_3.1A_TDD_UE1_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x000000ba
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a

&{DL_PDSCHSENDREQ_TM1_1_TM_3_1_TM_3.1A_TDD_UE2_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a

# TM2 - 70MHz
&{DL_PDSCHSENDREQ_TM2_2a_TDD_UE1_C_70MHz_startPrb1}       DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a

&{DL_PDSCHSENDREQ_TM2_2a_TDD_UE1_C_70MHz_startPrb2}       DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x0000005e
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a

&{DL_PDSCHSENDREQ_TM2_2a_TDD_UE1_C_70MHz_startPrb3}       DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x000000bc
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a


# TM2 - 50MHz
&{DL_PDSCHSENDREQ_TM2_TDD_UE1_C_50MHz_startPrb1}       DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a

&{DL_PDSCHSENDREQ_TM2_TDD_UE1_C_50MHz_startPrb2}       DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x00000042
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a

&{DL_PDSCHSENDREQ_TM2_TDD_UE1_C_50MHz_startPrb3}       DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x00000084
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a



# TM3.2-50MHZ
&{DL_PDSCHSENDREQ_TM3_2_TDD_UE2_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000001
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x0000008
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000040
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x168
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000008
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x0000008

&{DL_PDSCHSENDREQ_TM3_2_TDD_UE1_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000042
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x13a
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000008
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x0000005

&{DL_PDSCHSENDREQ_TM3_2_TDD_UE3_C_50MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a

# TM3.2-70MHZ
&{DL_PDSCHSENDREQ_TM3.2_TDD_UE1_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000001
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000060
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x178
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000010
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x0000010
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x00000010


&{DL_PDSCHSENDREQ_TM3.2_TDD_UE2_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x0000005a
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x148
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000010
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x000000d

&{DL_PDSCHSENDREQ_TM3.2_TDD_UE3_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a

# TM2a - 50MHz
&{DL_PDSCHSENDREQ_TM2a_TDD_UE3_C_50MHz_startPrb1}       DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a

&{DL_PDSCHSENDREQ_TM2a_TDD_UE3_C_50MHz_startPrb2}       DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x00000042
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a

&{DL_PDSCHSENDREQ_TM2a_TDD_UE3_C_50MHz_startPrb3}       DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x00000084
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x14a

# TM1.2 - 70MHz
&{DL_PDSCHSENDREQ_TM1_2_TDD_UE1_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x0000010
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000040
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x13c
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000010
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x0000010

&{DL_PDSCHSENDREQ_TM1_2_TDD_UE2_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000001
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x0000007a
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x179
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000010
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x000000d

&{DL_PDSCHSENDREQ_TM1_2_TDD_UE3_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a


# TM3.3 - 70MHz
&{DL_PDSCHSENDREQ_TM3_3_TDD_UE1_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000001
...                                                              DlData_PdschSendReq.grants_item_0.startPrb=0x0000010
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000050
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x196
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000010
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x0000010

&{DL_PDSCHSENDREQ_TM3_3_TDD_UE2_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                                              DlData_PdschSendReq.grants_item_0.numOfPrb=0x0000006a
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x147
...                                                              DlData_PdschSendReq.grants_item_0.rbgSize=0x0000010
...                                                              DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x000000d

&{DL_PDSCHSENDREQ_TM3_3_TDD_UE3_C_70MHz}               DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                                              DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x15a
