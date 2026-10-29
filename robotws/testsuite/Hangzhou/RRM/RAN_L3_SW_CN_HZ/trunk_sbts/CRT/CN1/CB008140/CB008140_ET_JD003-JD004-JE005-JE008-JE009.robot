*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN1_SG14
...    owner-jun.15.zhang    release-SBTS23R3    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=30
...    NRBTS:actIncXn=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3

@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=40
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

@{PARAMS_FOR_OTHERS}

...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:ngInducedCellDeactDelayTimer=60
...    NRCELL:actCDrx=false

@{Lock_Xn}
...    NRADJGNB-2:administrativeState=Locked

@{Unlock_Xn}
...    NRADJGNB-2:administrativeState=Unlocked

@{UE1_expect}
...    pcid:60, scellIdx:1
...    pcid:61, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{UE2_expect}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{UE3_expect}
...    pcid:51, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{RLFUE_detach}
...    pduSessioncontext not found
...    detached

@{DELETE_XN_related_Object}
...    delete:MRBTS-1/NRBTS-1/XNLINK-1
...    delete:MRBTS-1/NRBTS-1/NRADJGNB-2
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-11
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-12

@{Lock_Xn_EDA}
...    MRBTS-2/NRBTS-2/NRADJGNB-1:administrativeState=Locked

@{Unlock_Xn_EDA}
...    MRBTS-2/NRBTS-2/NRADJGNB-1:administrativeState=Unlocked



${XN_RESET_REQUEST_RECEIVED}         M55126C00010
${XN_RESET_RESPONSE_SENT}            M55126C00011
${XN_RESET_REQUEST_SENT}             M55126C00012
${XN_RESET_RESPONSE_RECEIVED}        M55126C00013
${XN_SHUTDOWN_LOCKED}                M55126C00008
${XN_SHUTDOWN_DETECTED}              M55126C00002
${F1_DU_P_RESET_RCV}                 M55117C01512
${F1_DU_P_RESET_ACK_SENT}            M55117C01513
${E1_RESET_SENT_CUCP}                M55121C00501
${E1_RESET_ACK_RECD_CUCP}            M55121C00502
${NG_CU_RESET_REQ_SENT}              M55119C00011
${NG_CU_RESET_ACK_RCV}               M55119C00014
${IGCA_UE_CTX_REL_XN_UNAV_ADJ_SA}    M55199C00003
${IGCA_UE_CTX_REL_XP_LOST_ADJ_SA}    M55199C00004
${IGCA_UE_CTX_REL_XN_RSET_ADJ_SA}    M55199C00005

@{JD03_PM_Counters_Check_GNB1}
...    NRBTS-1:NXNCB:${XN_RESET_REQUEST_SENT}>=1    #if UE1/2 in one CPUE, then only one XN reset with two ue-contexts-ToBeReleasedList items
...    NRBTS-1:NXNCB:${XN_RESET_RESPONSE_RECEIVED}=1
...    NRBTS-1:NXNCB:${XN_SHUTDOWN_LOCKED}=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}>=1    #if UE1/2 in one CPUE, then only one F1 reset with two id-UE-associatedLogicalF1-ConnectionItem items
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}>=1
...    NRBTS-1:NE1CB:${E1_RESET_SENT_CUCP}=1
...    NRBTS-1:NE1CB:${E1_RESET_ACK_RECD_CUCP}=1
...    NRBTS-1:NNGCB:${NG_CU_RESET_REQ_SENT}=1
...    NRBTS-1:NNGCB:${NG_CU_RESET_ACK_RCV}=1
...    NRBTS-2/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_UNAV_ADJ_SA}=1    #only two ":" is supported by TA FW
...    NRBTS-2/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XP_LOST_ADJ_SA}=0
...    NRBTS-2/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_RSET_ADJ_SA}=0
@{JD03_PM_Counters_Check_GNB2}
...    NRBTS-2:NXNCB:${XN_RESET_REQUEST_RECEIVED}>=1
...    NRBTS-2:NXNCB:${XN_RESET_RESPONSE_SENT}=1
...    NRBTS-2:NXNCB:${XN_SHUTDOWN_DETECTED}=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}>=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}>=1
...    NRBTS-2:NE1CB:${E1_RESET_SENT_CUCP}=1
...    NRBTS-2:NE1CB:${E1_RESET_ACK_RECD_CUCP}=1
...    NRBTS-2:NNGCB:${NG_CU_RESET_REQ_SENT}=1
...    NRBTS-2:NNGCB:${NG_CU_RESET_ACK_RCV}=1
...    NRBTS-1/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_UNAV_ADJ_SA}=0
...    NRBTS-1/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XP_LOST_ADJ_SA}=0
...    NRBTS-1/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_RSET_ADJ_SA}=1

@{JE05_PM_Counters_Check_GNB1}
...    NRBTS-1:NXNCB:${XN_RESET_REQUEST_SENT}>=1
...    NRBTS-1:NXNCB:${XN_RESET_RESPONSE_RECEIVED}>=1
...    NRBTS-1:NXNCB:${XN_RESET_REQUEST_RECEIVED}>=0
...    NRBTS-1:NXNCB:${XN_RESET_RESPONSE_SENT}>=0
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}>=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}>=1
...    NRBTS-1:NE1CB:${E1_RESET_SENT_CUCP}=1
...    NRBTS-1:NE1CB:${E1_RESET_ACK_RECD_CUCP}=1
...    NRBTS-1:NNGCB:${NG_CU_RESET_REQ_SENT}=1
...    NRBTS-1:NNGCB:${NG_CU_RESET_ACK_RCV}=1
...    NRBTS-2/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_UNAV_ADJ_SA}=0
...    NRBTS-2/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XP_LOST_ADJ_SA}=1    #UE1 will released by XP link break
...    NRBTS-2/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_RSET_ADJ_SA}=0
@{JE05_PM_Counters_Check_GNB2}
...    NRBTS-2:NXNCB:${XN_RESET_REQUEST_SENT}>=0
...    NRBTS-2:NXNCB:${XN_RESET_RESPONSE_RECEIVED}>=0
...    NRBTS-2:NXNCB:${XN_RESET_REQUEST_RECEIVED}>=1
...    NRBTS-2:NXNCB:${XN_RESET_RESPONSE_SENT}>=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}>=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}>=1
...    NRBTS-2:NE1CB:${E1_RESET_SENT_CUCP}=1
...    NRBTS-2:NE1CB:${E1_RESET_ACK_RECD_CUCP}=1
...    NRBTS-2:NNGCB:${NG_CU_RESET_REQ_SENT}=1
...    NRBTS-2:NNGCB:${NG_CU_RESET_ACK_RCV}=1
...    NRBTS-1/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_UNAV_ADJ_SA}=0
...    NRBTS-1/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XP_LOST_ADJ_SA}>=0    #UE2 may released by XP link break or XN reset, not check
...    NRBTS-1/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_RSET_ADJ_SA}>=0    #UE2 may released by XP link break or XN reset, not check

@{JE09_PM_Counters_Check_GNB1}
...    NRBTS-1:NXNCB:${XN_SHUTDOWN_DETECTED}=1
...    NRBTS-1:NXNCB:${XN_RESET_REQUEST_SENT}>=1
...    NRBTS-1:NXNCB:${XN_RESET_RESPONSE_RECEIVED}>=1
...    NRBTS-1:NXNCB:${XN_RESET_REQUEST_RECEIVED}>=0
...    NRBTS-1:NXNCB:${XN_RESET_RESPONSE_SENT}>=0
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}>=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}>=1
...    NRBTS-1:NE1CB:${E1_RESET_SENT_CUCP}=1
...    NRBTS-1:NE1CB:${E1_RESET_ACK_RECD_CUCP}=1
...    NRBTS-1:NNGCB:${NG_CU_RESET_REQ_SENT}=1
...    NRBTS-1:NNGCB:${NG_CU_RESET_ACK_RCV}=1
...    NRBTS-2/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_UNAV_ADJ_SA}=0
...    NRBTS-2/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XP_LOST_ADJ_SA}=1    #UE1 will released by XP link break
...    NRBTS-2/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_RSET_ADJ_SA}=0
@{JE09_PM_Counters_Check_GNB2}
...    NRBTS-2:NXNCB:${XN_SHUTDOWN_DETECTED}=1
...    NRBTS-2:NXNCB:${XN_RESET_REQUEST_SENT}>=0
...    NRBTS-2:NXNCB:${XN_RESET_RESPONSE_RECEIVED}>=0
...    NRBTS-2:NXNCB:${XN_RESET_REQUEST_RECEIVED}>=1
...    NRBTS-2:NXNCB:${XN_RESET_RESPONSE_SENT}>=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}>=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}>=1
...    NRBTS-2:NE1CB:${E1_RESET_SENT_CUCP}=1
...    NRBTS-2:NE1CB:${E1_RESET_ACK_RECD_CUCP}=1
...    NRBTS-2:NNGCB:${NG_CU_RESET_REQ_SENT}=1
...    NRBTS-2:NNGCB:${NG_CU_RESET_ACK_RCV}=1
...    NRBTS-1/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_UNAV_ADJ_SA}=0
...    NRBTS-1/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XP_LOST_ADJ_SA}>=0    #UE2 may released by XP link break or XN reset, not check
...    NRBTS-1/MCC-311/MNC-489:ADJNB:${IGCA_UE_CTX_REL_XN_RSET_ADJ_SA}>=0    #UE2 may released by XP link break or XN reset, not check

#NSA UE ue_nr_capabilities
${SA_Capa_Support_CA}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C47013B8D80D81AC1184341020E90186D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D805AC1184341020F1018656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B133582308682041D2030C2D931544439F11C788E3D033EC09F18E
...    7CC31E50B0381C3C17003FF001C00FFC000B000E0541B06F582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE0000016001C0AA3626EB04610D000002006185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F55555553
...    D555555416001C012587898001C4C000000160562E2600071300038980000042C0AC5C02000C260184C0001058158F80400181B030980613
...    00006160562E0100060080C0D800102C0AC7C02000C030181B0309A00050B02B1700800303606130000C160561E010006130000E160561E0
...    100060080010160561E0D800606C0012160561E0100060180014160561E03000606C0016160562E0100060180C0D800302C0AC3C1B000E26
...    00000D0B02B1713000309806008001C160563E2600061300C010181B0007858158B8980018020303600100B02B1F134003004060180C0D80
...    0442C08048037001A0264002809A0E9D212851226C73E1C4891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1C
...    F871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226C73E1C68
...    912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D04C00F000A07050070300740380030120020301F04
...    8010000000080040000001000002008000010040000100200000C01000008008000050040020080200800006004000038020010000000400
...    004002000024010000060080000A004000058020010240900400006019CA9BCA9AC14AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA06
...    82000012CA4A080000CB29202000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB
...    29202000152CA48080005CB29282000192CA480800018B292019A55574AA2A9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F
...    1414178095028140A05028140A05028140A05028140A05028140044202004008080100220100200404008010100200440201802808010020
...    2004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A020
...    040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840
...    40300601002004402004008080100202018028C04010020100400804030050100C014402004008080600C02018030C04008010100C014040
...    30060100C0146A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

#NSA UE ue_eutra_nr_capabilities
${Capa_LTE}    SEPARATOR=
...    A11FF82384C0C03898001C46000000122205C160601C46000002022205C16060184C00010488817078500018460001848881007011A014003
...    80982E0006504893A24ED8E7C3853A76C0000449D1276C000044036000000C018800020101002008040300608000402020180304000201010
...    0200020200401008060000

${Xn-c_link_unavailable}    7311

${Xp-c_link_unavailable}    62003

${Inter-gNB_CA_Xp_communication_failure}    7331

*** Test Cases ***
CB008140-ET-JD003_Xn-C lock between_gNB1-gNB2 caused related UE bulk release And then unlock
    [Documentation]
    ...    The purpose of this test case is to verify bulk UE context release caused by lock of Xn-C link used for inter-gNB CA
    ...      and unlock of Xn-C link between gNBs configured for inter-gNB CA
    ...    Requirement Coverage:
    ...      5G_RAN_USR_RRM_19083, fully covered
    ...        CB008140-JD#B3: Xn-C link used for inter-gNB CA locked by operator
    ...      5G_RAN_USR_RRM_19084, fully covered
    ...        CB008140-JD#B4: Unlock of Xn-C link
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50 Cellid=0x800c/32780
    ...    UE1 inter gNB2+gNB3 TFF 3CC CA
    ...    UE2 inter gNB3+gNB2 FTT 3CC CA
    ...    UE3 intra gNB2 TT 2CC CA
    ...    2.Test Case Steps:
    ...         Step a. NSA UE11 attch on Cell1_1 and trigger EN-DC setup with Cell2_1
    ...         Step b: UE1 register and PDU session Setup On Cell2_1,UE2 Register And PDU Session Setup On Cell3_11,then trigger A1 to add scells,
    ...                 verify both traffic
    ...         Step c: UE3 register and PDU session Setup On Cell2_1,then trigger A1 to add scell
    ...         Step d: Online modify to lock XNLINK-1 firstly,while fault id raises, deregister UE1/2,then unlock XNLINK-1
    ...         Step e: Repeat step b
    ...         Step f: check wireshark log and counters
    ...    3. Expected Results:
    ...         Step a: NSA UE11 successfully setup EN-DC 
    ...         Step b: UE1 add Cell3_11 and Cell3_12 as scells,UE2 add Cell2_1 and Cell2_2 as scells,both trafiic are ok
    ...         Step c: UE3 add Cell2_2 as scell
    ...         Step d: After lock operation done,fault id 7311 raises,meanwhile deregister UE1/2 successfully and report pduSessioncontext not
    ...                found,at last unlock successfully,fault id 7311 is cleared and XNLINK-1 is available
    ...         Step e: UE1 add Cell3_11 and Cell3_12 as scells,UE2 add Cell2_1 and Cell2_2 as scells,both trafiic are ok
    ...         Step f: Wireshark log checing detail see in PDM files,for counters checking:
    ...           XN_RESET_REQUEST_SENT(M55126C00012) shall be increased by gNB-2-CU-CP when a RESET REQUEST message for
    ...             Full Reset is sent out on Xn
    ...           XN_RESET_REQUEST_RECEIVED(M55126C00010) shall be increased by gNB-3-CU-CP when a RESET REQUEST message for
    ...             Full Reset is received on Xn
    ...           XN_RESET_RESPONSE_SENT(M55126C00011) shall be increased by gNB-3-CU-CP when a RESET RESPONSE for
    ...             Full Reset is sent out on Xn
    ...           XN_RESET_RESPONSE_RECEIVED(M55126C00013) shall be increased by gNB-2-CU-CP when a RESET RESPONSE for Full Reset is received on Xn
    ...           XN_SHUTDOWN_LOCKED (M55126C00008) shall be increased by gNB-2-CU-CP when SCTP shutdown is initiated
    ...           XN_SHUTDOWN_DETECTED (M55126C00002) shall be increased by gNB-3-CU-CP when SCTP shutdown notification is received from SCTP layer
    ...           F1_DU_P_RESET_RCV (M55117C01512) shall be increased by gNB-2-DU and gNB-3-DU when a RESET message for
    ...             Partial Reset is received on F1
    ...           F1_DU_P_RESET_ACK_SENT (M55117C01513) shall be increased by gNB-2-DU and gNB-3-DU when a RESET ACKNOWLEDGE for
    ...             Partial Reset is sent out on F1
    ...           E1_RESET_SENT_CUCP (M55121C00501) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a RESET message for
    ...             Partial Reset is sent out on E1
    ...           E1_RESET_ACK_RECD_CUCP (M55121C00502) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a RESET ACKNOWLEDGE message
    ...             is received on E1
    ...           NG_CU_RESET_REQ_SENT (M55119C00011) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a NG RESET message is sent out on NG
    ...           NG_CU_RESET_ACK_RCV (M55119C00014) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a NG RESET ACKNOWLEDGE message
    ...             is received on NG
    ...           IGCA_UE_CTX_REL_XN_UNAV_ADJ_SA(M55175C00003) shall be increased by gNB1-CU-CP when UE context with Inter-gNB CA established is
    ...              released in Prime-gNB due to Xn link
    ...           IGCA_UE_CTX_REL_XP_LOST_ADJ shall be increased by gNB-2-CU-CP by 1
    ...             If 4.D.2.Alt#1 applies, IGCA_UE_CTX_REL_XN_RESET_ADJ shall be increased by gNB-2-CU-CP by 1
    ...             If 4.D.2.Alt#2 applies, IGCA_UE_CTX_REL_XP_LOST_ADJ shall be increased by gNB-2-CU-CP by 1
    [Tags]    QC_278865    JD003    JD004    CA_LABEL-TFF(100MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)
    ...    CA_LABEL-FTT(10MHz_FDD_n3+100MHz_TDD_n77+40MHz_TDD_n77)
    Clear Counter Files for 2GNB
    NSA UE Attach And Start ENDC
    SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    SA UE3 Register And Trigger Intra-gNB By A1
    Lock Unlock Xn On GNB1
    SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    Release UEs    ue_type=all
    Check Counters    ${JD03_PM_Counters_Check_GNB1}
    Check Counters GNB2    ${JD03_PM_Counters_Check_GNB2}
    Check WireShark Log    ${CURDIR}${/}A2A_JD_003${/}a2a.ini    wait_string=IgNBCAXpRemovalResponse::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_JD_003${/}a2a_gnb2.ini    wait_string=IgNBCAXpRemovalResponse::1

CB008140-ET-JE005_SCTP link failure for Xp-C link caused related UE bulk release and then recover
    [Documentation]
    ...    The purpose of this test case is to verify SCTP association of Xp-C link;
    ...      Due to failure UE contexts using failed link for inter-gNB CA are released in bulk release procedure;
    ...      It will cause F1/E1/NG/Xn partial reset
    ...      Recovery of Xp-C link,after recovery CA relations from neighboring gNB can be used again
    ...    Requirement Coverage:
    ...      5G_RAN_USR_RRM_19085, fully covered
    ...        CB008140-JE#B1: SCTP association failure for Xp-C link
    ...      5G_RAN_USR_RRM_19088, fully covered
    ...        CB008140-JE#B3: Recovery of Xp-C link
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50 Cellid=0x800c/32780
    ...    UE1 inter gNB2+gNB3 TFF 3CC CA
    ...    UE2 inter gNB3+gNB2 FTT 3CC CA
    ...    UE3 intra gNB2 TT 2CC CA
    ...    2.Test Case Steps:
    ...         Step a: UE1 register and PDU session Setup On Cell2_1,UE2 Register And PDU Session Setup On Cell3_11,then trigger A1 to add scells,
    ...                 verify both traffic
    ...         Step b: UE3 register and PDU session Setup On Cell2_1,then trigger A1 to add scell
    ...         Step c: Drop XP link between gNB-2 and gNB-3
    ...         Step d: Recover XP link between gNB-2 and gNB-3,then verify UE3 trafiic
    ...         Step e: Repeat step a
    ...         Step f: check wireshark log and counters
    ...    3. Expected Results:
    ...         Step a: UE1 add Cell3_11 and Cell3_12 as scells,UE2 add Cell2_1 and Cell2_2 as scells,both trafiic are ok
    ...         Step b: UE3 add Cell2_2 as scell
    ...         Step c: Both gNB xpLinkStatus=unavailable and fault id 62003/7311 raises
    ...         Step d: Both gNB xpLinkStatus=available and fault id 62003/7311 are cleared,taffic for UE3 is ok
    ...         Step e: UE1 add Cell3_11 and Cell3_12 as scells,UE2 add Cell2_1 and Cell2_2 as scells,both trafiic are ok
    ...         Step f: Wireshark log checing detail see in PDM files,for counters checking:
    ...           F1_CU_P_RESET_ATT (M55117C01537) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a RESET message
    ...             for Partial Reset is sent out on F1
    ...           F1_DU_P_RESET_RCV (M55117C01512) shall be increased by gNB-2-DU and gNB-3-DU when a RESET message
    ...             for Partial Reset is received on F1
    ...           F1_DU_P_RESET_ACK_SENT (M55117C01513) shall be increased by gNB-2-DU and gNB-3-DU when a RESET ACKNOWLEDGE
    ...             for Partial Reset is sent out on F1
    ...           F1_CU_P_RESET_SUCC (M55117C01538) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a RESET ACKNOWLEDGE for
    ...             Partial Reset is received on F1
    ...           E1_RESET_SENT_CUCP (M55121C00501) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a RESET message for
    ...             Partial Reset is sent out on E1
    ...           E1_RESET_ACK_RECD_CUCP (M55121C00502) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a RESET ACKNOWLEDGE message
    ...             is received on E1
    ...           NG_CU_RESET_REQ_SENT (M55119C00011) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a NG RESET message is sent out on NG
    ...           NG_CU_RESET_ACK_RCV (M55119C00014) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a NG RESET ACKNOWLEDGE message
    ...             is received on NG
    ...           XN_RESET_REQUEST_SENT(M55126C00012) shall be increased by gNB-2-CU-CP when a RESET REQUEST message for
    ...             Partial Reset is sent out on Xn
    ...             If 4.D.2.Alt#2 applies, counter should be also incremented by gNB-3-CU-CP
    ...           XN_RESET_REQUEST_RECEIVED(M55126C00010) shall be increased by gNB-3-CU-CP when a RESET REQUEST message for
    ...             Partial Reset is received on Xn
    ...             If 4.D.2.Alt#2 applies, counter should be also incremented by gNB-2-CU-CP
    ...           XN_RESET_RESPONSE_SENT(M55126C00011) shall be increased by gNB-3-CU-CP when a RESET RESPONSE for Partial Reset is sent out on Xn.
    ...             If 4.D.2.Alt#2 applies, counter should be also incremented by gNB-2-CU-CP
    ...           XN_RESET_RESPONSE_RECEIVED(M55126C00013) shall be increased by gNB-2-CU-CP when a RESET RESPONSE for
    ...             Partial Reset is received on Xn
    ...             If 4.D.2.Alt#2 applies, counter should be also incremented by gNB-3-CU-CP
    ...           XP_LINK_LOST_IGCA_UE_CTX_PRIME_GNB shall be increased by gNB-2-CU-CP by 1 (for 5G-UE#3)
    ...             If 4.D.2.Alt#1 applies, XN_RESET_IGCA_UE_CTX_PRIME_GNB shall be increased by gNB-3-CU-CP by 1 (for 5G-UE#7)
    ...             If 4.D.2.Alt#2 applies, XP_LINK_LOST_IGCA_UE_CTX_PRIME_GNB shall be increased by gNB-3-CU-CP by 1 (for 5G-UE#7)
    [Tags]    QC_278853    JE005    JE008    CA_LABEL-TFF(100MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)
    ...    CA_LABEL-FTT(10MHz_FDD_n3+100MHz_TDD_n77+40MHz_TDD_n77)
    Clear Counter Files for 2GNB
    SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    SA UE3 Register And Trigger Intra-gNB By A1
    Check Xn Link Status Then Drop Xp Sctp And Check Alarm
    Release Inter gNB CA UE1 And UE2
    Recover Xp Sctp And Check Alarm
    Check No effect for UE3
    SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    Release UEs    ue_type=all
    Check Counters    ${JE05_PM_Counters_Check_GNB1}
    Check Counters GNB2    ${JE05_PM_Counters_Check_GNB2}
    Check WireShark Log    ${CURDIR}${/}A2A_JE_005${/}a2a.ini    wait_string=NGResetAcknowledge::2
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_JE_005${/}a2a_gnb2.ini    wait_string=IgNBCAConfigurationUpdateIndication::4

CB008140-ET-JE009_Paraller SCTP link failure for Xp-C and Xn-C link caused related UE bulk release
    [Documentation]
    ...    The purpose of this test case is to verify parallel failure of SCTP associations for Xn-C and Xp-C link
    ...      Due to failure UE contexts using failed link for inter-gNB CA are released in bulk release procedure
    ...    Requirement Coverage:
    ...      5G_RAN_USR_RRM_19089, fully covered
    ...      CB008140-JE#B4: Parallel failure of SCTP associations for Xn-C and Xp-C link
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50 Cellid=0x800c/32780
    ...    UE1 inter gNB2+gNB3 TFF 3CC CA
    ...    UE2 inter gNB3+gNB2 FTT 3CC CA
    ...    UE3 intra gNB2 TT 2CC CA
    ...    2.Test Case Steps:
    ...         Step a. NSA UE11 attch on Cell1_1 and trigger EN-DC setup with Cell2_1
    ...         Step b: UE1 register and PDU session Setup On Cell2_1,UE2 Register And PDU Session Setup On Cell3_11,then trigger A1 to add scells,
    ...                 verify both traffic
    ...         Step c: UE3 register and PDU session Setup On Cell2_1,then trigger A1 to add scell
    ...         Step d: Online modify to lock XNLINK-1 firstly,drop XP link between gNB-2 and gNB-3,while fault ids raise,deregister UE1/2,
    ...                 at last recover them
    ...         Step e: Repeat step b
    ...         Step f: check wireshark log and counters
    ...         EDA: PR702403: [Trunk][637] The xnlink cannot setup directly after NRADJGNB change from lock to unlock will waiting more
    ...    	                   than 5 minutes established success
    ...    3. Expected Results:
    ...         Step a: NSA UE11 successfully setup EN-DC 
    ...         Step b: UE1 add Cell3_11 and Cell3_12 as scells,UE2 add Cell2_1 and Cell2_2 as scells,both trafiic are ok
    ...         Step c: UE3 add Cell2_2 as scell
    ...         Step d: XNLINK-1=unavailable and oth gNB xpLinkStatus=unavailable,fault id 7331/62003/7311 raise,UE1/2 deregister successfully,
    ...                 recover successfully,fault ids are cleared
    ...         Step e: UE1 add Cell3_11 and Cell3_12 as scells,UE2 add Cell2_1 and Cell2_2 as scells,both trafiic are ok
    ...         Step f: Wireshark log checing detail see in PDM files,for counters checking:
    ...           XN_RESET_REQUEST_SENT(M55126C00012) shall be increased by gNB-2-CU-CP when a RESET REQUEST message
    ...             for Full Reset is sent out on Xn
    ...           XN_RESET_REQUEST_RECEIVED(M55126C00010) shall be increased by gNB-3-CU-CP when a RESET REQUEST message for
    ...             Full Reset is received on Xn
    ...           XN_RESET_RESPONSE_SENT(M55126C00011) shall be increased by gNB-3-CU-CP when a RESET RESPONSE for Full Reset is sent out on Xn
    ...           XN_RESET_RESPONSE_RECEIVED(M55126C00013) shall be increased by gNB-2-CU-CP when a RESET RESPONSE for Full Reset is received on Xn
    ...           XN_SHUTDOWN_LOCKED (M55126C00008) shall be increased by gNB-2-CU-CP when SCTP shutdown is initiated
    ...           XN_SHUTDOWN_DETECTED (M55126C00002) shall be increased by gNB-3-CU-CP when SCTP shutdown notification is received from SCTP layer
    ...           F1_DU_P_RESET_RCV (M55117C01512) shall be increased by gNB-2-DU and gNB-3-DU when a RESET message for
    ...             Partial Reset is received on F1
    ...           F1_DU_P_RESET_ACK_SENT (M55117C01513) shall be increased by gNB-2-DU and gNB-3-DU when a RESET ACKNOWLEDGE for
    ...             Partial Reset is sent out on F1
    ...           E1_RESET_SENT_CUCP (M55121C00501) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a RESET message for
    ...             Partial Reset is sent out on E1
    ...           E1_RESET_ACK_RECD_CUCP (M55121C00502) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a RESET ACKNOWLEDGE message
    ...             is received on E1
    ...           NG_CU_RESET_REQ_SENT (M55119C00011) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a NG RESET message is sent out on NG
    ...           NG_CU_RESET_ACK_RCV (M55119C00014) shall be increased by gNB-2-CU-CP and gNB-3-CU-CP when a NG RESET ACKNOWLEDGE message
    ...             is received on NG
    ...           IGCA_UE_CTX_REL_XN_UNAV_ADJ_SA(M55175C00003) shall be increased by gNB1-CU-CP when UE context with Inter-gNB CA established
    ...             is released in Prime-gNB due to Xn link
    ...           IGCA_UE_CTX_REL_XP_LOST_ADJ shall be increased by gNB-2-CU-CP by 1
    ...             If 4.D.2.Alt#1 applies, IGCA_UE_CTX_REL_XN_RESET_ADJ shall be increased by gNB-2-CU-CP by 1
    ...             If 4.D.2.Alt#2 applies, IGCA_UE_CTX_REL_XP_LOST_ADJ shall be increased by gNB-2-CU-CP by 1
    [Tags]    QC_278849    JE009    CA_LABEL-TFF(100MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)    CA_LABEL-FTT(10MHz_FDD_n3+100MHz_TDD_n77+40MHz_TDD_n77)
    Clear Counter Files for 2GNB
    NSA UE Attach And Start ENDC
    SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    SA UE3 Register And Trigger Intra-gNB By A1
    Check Xn Link Status Then Paraller Drop Xp-C And Xn-C Sctp And Check Alarm
    Release Inter gNB CA UE1 And UE2
    Recover Xp-C And Xn-C Sctp And Check Alarm
    Sleep    60s    #wait Xp setup
    SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    Release UEs    ue_type=all
    Check Counters    ${JE09_PM_Counters_Check_GNB1}
    Check Counters GNB2    ${JE09_PM_Counters_Check_GNB2}
    Check WireShark Log    ${CURDIR}${/}A2A_JE_009${/}a2a.ini    wait_string=IgNBCAXpRemovalResponse::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_JE_009${/}a2a_gnb2.ini    wait_string=IgNBCAXpRemovalResponse::1
	Delete XN NRADJGNB NRREL
	Lock Xn for the first time
	Unlock Xn for the first time
	Lock Xn for the second time
	Unlock Xn for the second time

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F    ue_count=3
	
Delete XN NRADJGNB NRREL
    Delta Commission Parameters    ${DELETE_XN_related_Object}
	
Lock Xn for the first time
    Delta Commission Parameters Gnb2    ${Lock_Xn_EDA}
	
Unlock Xn for the first time
    Delta Commission Parameters Gnb2    ${Unlock_Xn_EDA}
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK:xnLinkStatus=available
    Sleep    60s    #wait Xp setup

Lock Xn for the second time
    Delta Commission Parameters Gnb2    ${Lock_Xn_EDA}
	
Unlock Xn for the second time
    Delta Commission Parameters Gnb2    ${Unlock_Xn_EDA}
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK:xnLinkStatus=available
    Sleep    60s    #wait Xp setup


Perform Steps After Onair
    sleep    60    #wait Xp setup msg

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

NSA UE Attach And Start ENDC
    Execute Egate Command    ue_param id=11 ue_nr_capabilities=${SA_Capa_Support_CA} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ue_attach id=11 profile=1    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE11: Proxy \\(eNB 2 cell 1\\) reported successful RA

SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    UE Register And Setup PDU Session    ue_id=1
    UE1 Send A1 To Trigger Scell Addition
    Run Traffic And Verify Throughput
    UE Register And Setup PDU Session    ue_id=2    gateway=2    enb_id=3    cell_id=11
    UE2 Send A1 To Trigger Scell Addition
    Run Traffic And Verify Throughput    ue_id=2

SA UE3 Register And Trigger Intra-gNB By A1
    UE Register And Setup PDU Session    ue_id=3    gateway=3
    UE3 Send A1 To Trigger Scell Addition
    Run Traffic And Verify Throughput    ue_id=3

UE Register And Setup PDU Session
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=QoS Routing Table    timeout=20s

UE1 Send A1 To Trigger Scell Addition
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=663360    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE1_expect}    fail_regexp=SCellIndex 3 activated successfully at airphone    timeout=20s

UE2 Send A1 To Trigger Scell Addition
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=2    carrierfreq=368430    event_type=A1
    ...    threshold=RSRP\ 111
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE2_expect}    fail_regexp=SCellIndex 3 activated successfully at airphone    timeout=20s

UE3 Send A1 To Trigger Scell Addition
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=3    carrierfreq=663360    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE3_expect}    fail_regexp=SCellIndex 2 activated successfully at airphone    timeout=20s

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    540    25
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=4    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1    pass_regexp=Stopping Uplink Internal traffic on Ue

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Check Xn Link Status Then Drop Xn-C Sctp And Check Alarm
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Execute Command On Enb    iptables -t filter -A OUTPUT -p sctp --dport 38422 -j DROP
    Execute Command On Enb    ip6tables -t filter -A OUTPUT -p sctp --dport 38422 -j DROP
    Sleep    60s    #igNBCaXnSetupRespTmr
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised    fault_id=${Xn-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised GNB2    fault_id=${Xn-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=unavailable

Lock Unlock Xn On GNB1
    Check Xn Link Status Then Lock Xn And Check Alarm
    Release Inter gNB CA UE1 And UE2
    Unlock Xn And Check Alarm

Check Xn Link Status Then Lock Xn And Check Alarm
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Delta Commission Parameters    ${Lock_Xn}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised GNB2    fault_id=${Xn-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=unavailable

Release Inter gNB CA UE1 And UE2
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    pass_regexp=${RLFUE_detach}
    Execute Egate Command    ue_deregister id=2 ue_deregister_type=switch_off    pass_regexp=${RLFUE_detach}

Unlock Xn And Check Alarm
    Delta Commission Parameters    ${Unlock_Xn}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared GNB2    fault_id=${Xn-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Sleep    60s    #wait Xp setup

Check Xn Link Status Then Drop Xp Sctp And Check Alarm
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    Execute Command On Enb    iptables -t filter -A OUTPUT -p sctp --dport 32742 -j DROP
    Execute Command On Enb    ip6tables -t filter -A OUTPUT -p sctp --dport 32742 -j DROP
    Wait Until Keyword Succeeds    300s    2s    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=unavailable
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised    fault_id=${Xp-c_link_unavailable}
    Wait Until Keyword Succeeds    300s    2s    Object Should Exist GNB2
    ...    MRBTS-2/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=unavailable
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised GNB2    fault_id=${Xp-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised    fault_id=${Inter-gNB_CA_Xp_communication_failure}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised GNB2    fault_id=${Inter-gNB_CA_Xp_communication_failure}

Check No effect for UE3
    Run Traffic And Verify Throughput    ue_id=3

Recover Xp Sctp And Check Alarm
    Execute Command On Enb     iptables -t filter -F OUTPUT
    Execute Command On Enb     ip6tables -t filter -F OUTPUT
    Wait Until Keyword Succeeds    300s    2s    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared    fault_id=${Xp-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared GNB2    fault_id=${Xp-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared    fault_id=${Inter-gNB_CA_Xp_communication_failure}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared GNB2    fault_id=${Inter-gNB_CA_Xp_communication_failure}

Check Xn Link Status Then Paraller Drop Xp-C And Xn-C Sctp And Check Alarm
    Check Xn Link Status Then Drop Xp Sctp And Check Alarm
    Check Xn Link Status Then Drop Xn-C Sctp And Check Alarm

Recover Xp-C And Xn-C Sctp And Check Alarm
    Execute Command On Enb    iptables -t filter -F OUTPUT
    Execute Command On Enb    ip6tables -t filter -F OUTPUT
    Wait Until Keyword Succeeds    300s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Wait Until Keyword Succeeds    300s    2s    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared    fault_id=${Xn-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared GNB2    fault_id=${Xn-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared    fault_id=${Xp-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared GNB2    fault_id=${Xp-c_link_unavailable}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared    fault_id=${Inter-gNB_CA_Xp_communication_failure}
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Cleared GNB2    fault_id=${Inter-gNB_CA_Xp_communication_failure}
