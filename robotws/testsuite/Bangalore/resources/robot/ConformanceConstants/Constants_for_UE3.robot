*** Settings  ***
Documentation      Variables for conformance
*** Variables ***

&{DICTONARY_PRACHRECEIVEREQ_IE_UE3}             UlData_PrachReceiveReq.subcells-Length.rnti=0x00000001
...                                             UlData_PrachReceiveReq.subcells-Length=0x00000001
...                                             UlData_PrachReceiveReq.subcells_item_0.subcellId=0x00000000
...								                UlData_PrachReceiveReq.subcells_item_0.prachPrbOffset=0x00000000
...								                UlData_PrachReceiveReq.occasions_item_23.numCeAxCIndex=2


&{DICTONARY_PDSCHSENDREQ_TM_1.2_TDD_FR1_IE_UE3}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000003
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000002

&{DICTONARY_PDSCHSENDREQ_TM_TDD_1.1_FR1_IE_UE3}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000003

&{DICTONARY_PDSCHSENDREQ_TM_TDD_3.1_FR1_IE_UE3}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x0000000b
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000006
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000003


&{DICTONARY_PDSCHSENDREQ_TM_2a_FDD_FR1_IE}     DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000014
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.pdschBundleSize=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000008
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.rat0Bitmap=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbIndex=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbStartOffset_bits=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000002

&{DICTONARY_PDSCHSENDREQ_TM_2_TDD_FR1_IE}      DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x0000000b
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.pdschBundleSize=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000006
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.tbIndex=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbStartOffset_bits=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.rat0Bitmap=0x00000000


&{DICTONARY_PDSCHSENDREQ_TM_3.2_FDD_FR1_IE_UE3}     DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                             DlData_PdschSendReq.grants_item_0.mcsTable=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000000


&{DICTONARY_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_UE3}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000003


&{DL_PDSCHSENDREQ_TM3.2_TDD_UE3_C_90MHz}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165

&{DL_PDSCHSENDREQ_TM1.2_TDD_UE3_C_90MHz}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165

&{DL_PDSCHSENDREQ_TM3.3_TDD_UE3_C_90MHz}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165

&{DICTONARY_PDSCHPAYLOADTBSENDREQ_IE_UE3}          DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti=0x00000001
...                                            DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.tbIndex=0x00000000
