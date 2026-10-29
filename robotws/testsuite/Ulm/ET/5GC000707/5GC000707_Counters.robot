*** Settings ***
Documentation   This is a Robot Test Suite for feature 5GC000707 'InterRat HO LTE' testing
...             Link to Test Strategy: https://nokia.sharepoint.com/:w:/r/sites/MN5GSCProductization/Shared%20Documents/General/
...                                    5G%26SC%20Collaborator/5GC000600%E2%80%935GC000799/5GC000707/5GC000707_Feature_Test_Strategy.docx
...                                    ?d=w5d3c577623544040aa955e7c98eeb3b4&csf=1&web=1&e=Et8mkt
...             Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...             Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Variables ***

@{A_13_COUNTERs}              M55124C02002  ==  1  NRRCC_MEAS_A2_REC
...                           M55124C02003  ==  1  NRRCC_MEAS_A1_REC

@{A_25_COUNTERs}              M55124C02002  ==  1  NRRCC_MEAS_A2_REC
...                           M55124C02003  ==  1  NRRCC_MEAS_A1_REC


@{B_B1_COUNTERs}              M55113C00501  ==  2  NF1CC_DL_RRC_MSG_TRANSFER
...                           M55124C02001  ==  1  NRRCC_MEAS_B2_REC
...                           M55125C00501  ==  1  NNGCC_UE_CTXT_REL_CMD_RECD
...                           M55125C00502  ==  1  NNGCC_UE_CTXT_REL_CMP_SENT
...                           M55125C02001  ==  1  NNGCC_IRATHO_ATT
...                           M55125C02002  ==  1  NNGCC_IRATHO_SUC
...                           M55125C02006  ==  1  NNGCC_IRATHO_EXE_SUC

@{B_B1_NREMO_COUNTERs}        M55144C00001  ==  1  NREMO_IRATHO_ATT
...                           M55144C00002  ==  1  NREMO_IRATHO_SUC
...                           M55144C00006  ==  1  NREMO_IRATHO_EXE_SUC

@{B_B2_COUNTERs}              M55124C02001  ==  1  NRRCC_MEAS_B2_REC
...                           M55124C02004  ==  1  NRRCC_MEAS_B2_REC_UNKEPCI

@{B_B3_COUNTERs}              M55124C02002  ==  1  NRRCC_MEAS_A2_REC

@{B_B4_COUNTERs}              M55124C02002  ==  1  NRRCC_MEAS_A2_REC
...                           M55124C02003  ==  1  NRRCC_MEAS_A1_REC

@{B_EC1_COUNTERs}             M55125C02001  ==  1  NNGCC_IRATHO_ATT
...                           M55125C02005  ==  1  NNGCC_IRATHO_CANCEL
...                           M55125C02009  ==  1  NNGCC_IRATHO_CANCEL_ACK_RCVD
...                           M55124C02003  ==  1  NRRCC_MEAS_A1_REC

@{B_EC1_NREMO_COUNTERs}       M55144C00001  ==  1  NREMO_IRATHO_ATT
...                           M55144C00005  ==  1  NREMO_IRATHO_CANCEL
...                           M55144C00009  ==  1  NREMO_IRATHO_CANCEL_ACK_RCVD

@{B_EC3_COUNTERs}             M55124C02001  ==  2  NRRCC_MEAS_B2_REC
...                           M55125C02001  ==  2  NNGCC_IRATHO_ATT
...                           M55125C02003  ==  1  NNGCC_IRATHO_FAIL_NO_RADIO_RES
...                           M55125C02004  ==  1  NNGCC_IRATHO_FAIL

@{B_EC3_NREMO_COUNTERs}       M55144C00001  ==  2  NREMO_IRATHO_ATT
...                           M55144C00003  ==  1  NREMO_IRATHO_FAIL_NO_RADIO_RES
...                           M55144C00004  ==  1  NREMO_IRATHO_FAIL

@{B_EC4_COUNTERs}             M55125C02008  ==  1  NNGCC_IRATHO_FAIL_RELOC_PREP
@{B_EC4_NREMO_COUNTERs}       M55144C00008  ==  1  NREMO_IRATHO_FAIL_RELOC_PREP

@{B_EC5_COUNTERs}             M55125C00501  ==  1  NNGCC_UE_CTXT_REL_CMD_RECD
...                           M55125C00502  ==  1  NNGCC_UE_CTXT_REL_CMP_SENT
...                           M55125C02001  ==  1  NNGCC_IRATHO_ATT
...                           M55125C02002  ==  1  NNGCC_IRATHO_SUC
...                           M55125C02007  ==  1  NNGCC_UE_CTX_REL_RELOC_OVERALL

@{B_EC5_NREMO_COUNTERs}       M55144C00001  ==  1  NREMO_IRATHO_ATT
...                           M55144C00002  ==  1  NREMO_IRATHO_SUC
...                           M55144C00007  ==  1  NREMO_UE_CTX_REL_RELOC_OVERALL

@{D_B1_COUNTERs}              M55124C02001  ==  1  NRRCC_MEAS_B2_REC
...                           M55125C02001  ==  0  NNGCC_IRATHO_ATT

@{D_B2_COUNTERs}              M55124C02002  ==  1  NRRCC_MEAS_A2_REC

@{D_B3_COUNTERs}              M55124C02002  ==  1  NRRCC_MEAS_A2_REC
...                           M55124C02001  ==  1  NRRCC_MEAS_B2_REC
...                           M55125C02001  ==  0  NNGCC_IRATHO_ATT

@{J_B1_COUNTERs}              M55149C00600  ==  1  ATT_IRATHO_PRE_SLICE
...                           M55149C00601  ==  1  SUCC_IRATHO_PRE_SLICE
...                           M55149C00602  ==  1  SUCC_IRATHO_SLICE
...                           M55124C02001  ==  1  NRRCC_MEAS_B2_REC

@{E_B3_COUNTERs}              M55124C02001  ==  1  NRRCC_MEAS_B2_REC
...                           M55125C02001  ==  0  NNGCC_IRATHO_ATT

@{CNI-112742_Counters}        M55125C13008  ==  0  NG_FLOW_REL_IRAT_FAIL_HO_5QI1
...                           M55125C09515  ==  0  NG_FLOW_REL_ABNORMAL_5QI1
...                           M55113C00501  ==  2  NF1CC_DL_RRC_MSG_TRANSFER
...                           M55124C02001  ==  1  NRRCC_MEAS_B2_REC
...                           M55125C01001  ==  0  NNGCC_UE_CTXT_REL_REQ_SENT
...                           M55125C00501  ==  1  NNGCC_UE_CTXT_REL_CMD_RECD
...                           M55125C00502  ==  1  NNGCC_UE_CTXT_REL_CMP_SENT
...                           M55125C02001  ==  1  NNGCC_IRATHO_ATT
...                           M55125C02002  ==  1  NNGCC_IRATHO_SUC
...                           M55125C02006  ==  1  NNGCC_IRATHO_EXE_SUC

@{03805465_Counters}          M55125C02001  >=  1  NNGCC_IRATHO_ATT
...                           M55125C02002  >=  1  NNGCC_IRATHO_SUC
...                           M55125C02006  >=  1  NNGCC_IRATHO_EXE_SUC
...                           M55125C09005  >=  1  NG_FLOW_REL_GNB_UE_LOST
...                           M55125C09006  ==  0  NG_FLOW_REL_GNB_UNSPECIFIED
