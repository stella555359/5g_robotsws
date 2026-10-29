*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008574

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Variables ***

@{SOURCE_COUNTERS}                  M55125C07521  ==  1  NG_HO_EXEC_TIME_EXP_SRC
...                                 M55125C07514  ==  1  NG_HO_EXEC_ATT_SRC_IAF

@{RRC_REESTAB_FAIL_TARGET_CELL_PMQAP}
...                                 M55163C00513  ==  2  NG_FLOW_STP_ATT_INC_HO_PMQAP
...                                 M55163C00530  ==  0  NG_FLOW_STP_ATT_RES_IADU_PMQAP
...                                 M55163C00531  ==  0  NG_FLOW_STP_SUC_RES_IADU_PMQAP

@{RRC_REESTAB_FAIL_TARGET_CELL_NG_FLOW}
...                                 M55125C09023  ==  0  NG_FLOW_STP_ATT_REEST_IADU
...                                 M55125C09024  ==  0  NG_FLOW_STP_SUC_REEST_IADU
...                                 M55125C09531  ==  0  NG_FLOW_STP_ATT_RES_IADU_5QI1
...                                 M55125C09532  ==  0  NG_FLOW_STP_SUC_RES_IADU_5QI1

@{RRC_REESTAB_FAIL_PREP_CELL_PMQAP}
...                                 M55163C00513  ==  0  NG_FLOW_STP_ATT_INC_HO_PMQAP
...                                 M55163C00530  ==  0  NG_FLOW_STP_ATT_RES_IADU_PMQAP
...                                 M55163C00531  ==  0  NG_FLOW_STP_SUC_RES_IADU_PMQAP

@{RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}
...                                 M55125C09023  ==  0  NG_FLOW_STP_ATT_REEST_IADU
...                                 M55125C09024  ==  0  NG_FLOW_STP_SUC_REEST_IADU
...                                 M55125C09531  ==  0  NG_FLOW_STP_ATT_RES_IADU_5QI1
...                                 M55125C09532  ==  0  NG_FLOW_STP_SUC_RES_IADU_5QI1

@{RRC_REESTAB_FAIL_TARGET_CELL}
...                                 M55113C01009  ==  1  NF1CC_UECTXT_REL_CMDSENT
...                                 M55113C01010  ==  1  NF1CC_UE_CTXT_REL_CMP_RECD
...                                 M55125C07504  ==  1  NG_HO_RES_ALC_SUCC_TRG
...                                 M55125C07515  ==  0  NG_HO_FAIL_TIME_EXP_TRG
...                                 M55125C07520  ==  0  NG_HO_EXEC_NOTIFY_TRG
...                                 M55125C09013  ==  2  NG_FLOW_STP_ATT_INC_HO
...                                 M55125C09014  ==  0  NG_FLOW_STP_SUC_INC_HO
...                                 M55125C09524  ==  1  NG_FLOW_STP_ATT_INC_HO_5QI1
...                                 M55125C09525  ==  0  NG_FLOW_STP_SUC_INC_HO_5QI1
...                                 M55138C00023  ==  1  SGNB_SA_HO_ADMISSION_REQ
...                                 M55138C00024  ==  1  SGNB_SA_HO_ADMISSION_SUCC
...                                 M55138C00025  ==  1  SGNB_SA_HO_NGBR_DRB_REQ
...                                 M55138C00026  ==  1  SGNB_SA_HO_NGBR_DRB_SUCC
...                                 M55138C00503  ==  0  GNB_SA_HO_ADMISSION_MFBI_REQ
...                                 M55138C00504  ==  0  GNB_SA_HO_ADMISSION_MFBI_SUCC
...                                 M55138C01011  ==  1  SA_HO_GBR_DRB_REQ
...                                 M55138C01013  ==  1  SA_HO_GBR_DRB_SUCC
...                                 M55139C00005  ==  1  SGNB_SA_DU_HO_ADMISSION_REQ
...                                 M55139C00006  ==  1  SGNB_SA_DU_HO_ADMISSION_SUCC
...                                 M55139C00007  ==  1  SGNB_SA_DU_HO_NGBR_DRB_REQ
...                                 M55139C00008  ==  1  SGNB_SA_DU_HO_NGBR_DRB_SUCC
...                                 M55139C00505  ==  1  SA_DU_HO_GBR_DRB_REQ
...                                 M55139C02005  ==  0  GNB_SA_DU_HO_ADMISS_MFBI_REQ
...                                 M55139C02006  ==  0  GNB_SA_DU_HO_ADMISS_MFBI_SUCC
...                                 M55124C00502  ==  0  RRC_REESTAB_FALLBACK
...                                 M55124C00515  ==  0  REESTAB_ACC_FALLBACK
...                                 M55124C00504  ==  0  RRC_REESTAB_HO_FAILURE
...                                 M55124C00505  ==  0  RRC_REESTAB_OTHER_FAILURE
...                                 M55124C00520  ==  0  RRC_REESTAB_ATT_VONR
...                                 M55124C00503  ==  0  RRC_REESTAB_RECONF_FAILURE
...                                 M55147C00036  ==  0  HO_PREP_SUCC_FULLCONF_TRG
...                                 M55124C00501  ==  0  RRC_REESTAB_DISCARD

@{RRC_REESTAB_FAIL_PREP_CELL}
...                                 M55113C01009  ==  0  NF1CC_UECTXT_REL_CMDSENT
...                                 M55113C01010  ==  0  NF1CC_UE_CTXT_REL_CMP_RECD
...                                 M55125C07504  ==  0  NG_HO_RES_ALC_SUCC_TRG
...                                 M55125C07515  ==  0  NG_HO_FAIL_TIME_EXP_TRG
...                                 M55125C07520  ==  0  NG_HO_EXEC_NOTIFY_TRG
...                                 M55125C09013  ==  0  NG_FLOW_STP_ATT_INC_HO
...                                 M55125C09014  ==  0  NG_FLOW_STP_SUC_INC_HO
...                                 M55125C09524  ==  0  NG_FLOW_STP_ATT_INC_HO_5QI1
...                                 M55125C09525  ==  0  NG_FLOW_STP_SUC_INC_HO_5QI1
...                                 M55138C00023  ==  0  SGNB_SA_HO_ADMISSION_REQ
...                                 M55138C00024  ==  0  SGNB_SA_HO_ADMISSION_SUCC
...                                 M55138C00025  ==  0  SGNB_SA_HO_NGBR_DRB_REQ
...                                 M55138C00026  ==  0  SGNB_SA_HO_NGBR_DRB_SUCC
...                                 M55138C00503  ==  0  GNB_SA_HO_ADMISSION_MFBI_REQ
...                                 M55138C00504  ==  0  GNB_SA_HO_ADMISSION_MFBI_SUCC
...                                 M55138C01011  ==  0  SA_DU_HO_GBR_DRB_REQ
...                                 M55138C01013  ==  0  SA_HO_GBR_DRB_SUCC
...                                 M55139C00005  ==  0  SGNB_SA_DU_HO_ADMISSION_REQ
...                                 M55139C00006  ==  0  SGNB_SA_DU_HO_ADMISSION_SUCC
...                                 M55139C00007  ==  0  SGNB_SA_DU_HO_NGBR_DRB_REQ
...                                 M55139C00008  ==  0  SGNB_SA_DU_HO_NGBR_DRB_SUCC
...                                 M55139C00505  ==  0  SA_DU_HO_GBR_DRB_REQ
...                                 M55139C00507  ==  0  SA_HO_DU_GBR_LACK_DRB
...                                 M55139C00508  ==  0  SA_HO_DU_GBR_LACK_RAD_RES
...                                 M55139C02005  ==  0  GNB_SA_DU_HO_ADMISS_MFBI_REQ
...                                 M55139C02006  ==  0  GNB_SA_DU_HO_ADMISS_MFBI_SUCC
...                                 M55124C00502  ==  0  RRC_REESTAB_FALLBACK
...                                 M55124C00515  ==  0  REESTAB_ACC_FALLBACK
...                                 M55124C00504  ==  0  RRC_REESTAB_HO_FAILURE
...                                 M55124C00505  ==  0  RRC_REESTAB_OTHER_FAILURE
...                                 M55124C00520  ==  0  RRC_REESTAB_ATT_VONR
...                                 M55124C00503  ==  0  RRC_REESTAB_RECONF_FAILURE
...                                 M55147C00036  ==  0  HO_PREP_SUCC_FULLCONF_TRG
...                                 M55124C00501  ==  0  RRC_REESTAB_DISCARD

@{RRC_REESTAB_FAIL_TARGET_DU}
...                                 M55127C00501  ==  0  RRC_REESTAB_RECONF_FAILURE_DU
...                                 M55127C00502  ==  0  RRC_REESTAB_HO_FAILURE_DU
...                                 M55127C00503  ==  0  RRC_REESTAB_OTHER_FAILURE_DU
...                                 M55127C00513  ==  0  RRC_REESTAB_DISCARD_DU
