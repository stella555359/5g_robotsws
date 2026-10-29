*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs for debug
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN3ET    release-SBTS24R2    owner-carol.an
Resource    testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000786}
...    @{CB006112-A}
...    @{5GC000704}
...    @{CB006112-C}
...    @{5GC000707_InterRAT}
...    @{5GC000784}
...    @{CB008700}
...    @{5GC002145}
...    @{CB008379}
...    @{5GC000772}
...    @{5GC000749}
...    @{5GC000710}
...    @{ngho}
...    @{5GC001468}
...    @{5GC000711}
...    @{5GC000732}
...    @{CB008698}
...    @{CB008232}
...    @{PMQAP}
...    NRCELL/NRREDRT-1:redirPrioBadUlRadio=1
...    NRCELL/NRREDRT-2:redirPrioBadUlRadio=2
...    NRBTS-1/NRMORED-1:redirPrioBadUlRadio=1
...    NRBTS-1/NRMORED-2:redirPrioBadUlRadio=2
...    NRBTS-1/NRDRX-1:drxLongCycle=40ms

@{counterEnable}
...    NRPMRNL-1:miNrF1CD=5min
...    NRPMRNL-1:miNrRRCD=5min

@{counterDisable}
...    NRPMRNL-1:miNrF1CD=disabled
...    NRPMRNL-1:miNrRRCD=disabled

${F1_UE_CTXT_MOD_REQ_RECEIVED}    M55117C00001
${F1_UE_CTXT_MOD_RESP_SENT}    M55117C00002
${F1_UE_CTXT_MOD_FAIL_SENT}    M55117C00003
${NF1CD_RAN_PAGING_SUCC_SENT}    M55117C00004
${F1_DU_CU_CNF_UPD_ATT}    M55117C00528
${F1_DU_CU_CNF_UPD_ACT}    M55117C00529
${F1_DU_CU_CNF_UPD_RECNF}    M55117C00530
${F1_DU_CU_CNF_UPD_DEACT}    M55117C00531
${F1_DU_CU_CNF_UPD_SUC}    M55117C00532
${F1_DU_CU_CNF_UPD_SUC_ACT}    M55117C00533
${F1_DU_CU_CNF_UPD_SUC_RECNF}    M55117C00534
${F1_DU_CU_CNF_UPD_SUC_DEACT}    M55117C00535
${F1_DU_CU_CNF_UPD_P_SUC}    M55117C00536
${F1_DU_CU_CNF_UPD_ACT_FL}    M55117C00538
${F1_DU_CU_CNF_UPD_FL}    M55117C00542
${F1_DU_CU_CNF_UPD_FL_SEM_ERR}    M55117C00543
${F1_DU_CU_CNF_UPD_FL_MSG_STATE}    M55117C00544
${F1_DU_CU_CNF_UPD_FL_OTH}    M55117C00545
${F1_DU_DU_CNF_UPD}    M55117C00546
${F1_DU_DU_CNF_UPD_ACT}    M55117C00547
${F1_DU_DU_CNF_UPD_RECNF}    M55117C00548
${F1_DU_DU_CNF_UPD_DEL}    M55117C00549
${F1_DU_DU_CNF_UPD_ACK}    M55117C00550
${F1_DU_DU_CNF_UPD_FL}    M55117C00551
${F1_DU_DU_CNF_UPD_FL_SEM_ERR}    M55117C00552
${F1_DU_DU_CNF_UPD_FL_MSG_STATE}    M55117C00553
${F1_DU_DU_CNF_UPD_FL_NRESP}    M55117C00554
${NF1CD_UECTXT_STP_REQRECD}    M55117C01001
${NF1CD_UECTXT_STP_RESPSENT}    M55117C01002
${NF1CD_UECTXT_STP_QCINOTSUPP}    M55117C01003
${NF1CD_UECTXT_STP_IPNOTSUPP}    M55117C01004
${NF1CD_UECTXT_STP_FAILMISC}    M55117C01005
${NF1CD_UECTXT_MOD_REQSENT}    M55117C01006
${NF1CD_UECTXT_REL_REQSENT}    M55117C01008
${NF1CD_UECTXT_REL_CMDRECD}    M55117C01009
${NF1CD_UECTXT_REL_CMPSENT}    M55117C01010
${NF1CD_UECTXT_MOD_CNFRECD}    M55117C01011
${F1_SETUP_ATT}    M55117C01505
${F1_SETUP_SUCC}    M55117C01506
${F1_SETUP_FAIL}    M55117C01507
${F1_SETUP_FAIL_NRESP}    M55117C01508
${F1_SETUP_FAIL_OVERLOAD}    M55117C01509
${F1_SETUP_FAIL_PROT_ERR}    M55117C01510
${F1_DU_RESET_RCV_PROT_ERR}    M55117C01511
${F1_DU_P_RESET_RCV}    M55117C01512
${F1_DU_P_RESET_ACK_SENT}    M55117C01513
${F1_DU_P_RESET_ATT}    M55117C01514
${F1_DU_P_RESET_SUCC}    M55117C01515
${F1_DU_P_RESET_FAIL}    M55117C01516
${F1_DU_P_RESET_FAIL_NRESP}    M55117C01517
${F1_DU_G_RESET_RCV}    M55117C01518
${F1_DU_G_RESET_ACK_SENT}    M55117C01519
${F1_DU_G_RESET_ATT}    M55117C01520
${F1_DU_G_RESET_SUCC}    M55117C01521
${F1_DU_G_RESET_FAIL}    M55117C01522
${F1_DU_G_RESET_FAIL_NRESP}    M55117C01523
${F1_DU_RESET_FAIL_PROT_ERR}    M55117C01524
${F1_DU_ERR_IND_SENT}    M55117C01530
${F1_DU_ERR_IND_RCV}    M55117C01531
${F1_DU_ERR_IND_RCV_ERR}    M55117C01532
${F1_DU_UNKNOWN_MSG_RCV}    M55117C01533
${NRRCD_RRC_STPREQ_MO_SIGNALLING}    M55127C00001
${NRRCD_RRC_STPREQ_MO_DATA}    M55127C00002
${NRRCD_RRC_STPREQ_MT_ACCESS}    M55127C00003
${NRRCD_RRC_STPREQ_EMERGENCY}    M55127C00004
${NRRCD_RRC_STPREQ_HIPRIO_ACCESS}    M55127C00005
${NRRCD_RRC_STPREQ_MO_VOICECALL}    M55127C00006
${NRRRD_RRC_SETUP_FAIL}    M55127C00010
${NRRCD_RRC_STPREQ_MO_VIDEOCALL}    M55127C00011
${NRRCD_RRC_STPREQ_MO_SMS}    M55127C00012
${NRRCD_RRC_STPREQ_MPS}    M55127C00013
${NRRCD_RRC_STPREQ_MCS}    M55127C00014
${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501
${RRC_REESTAB_HO_FAILURE_DU}    M55127C00502
${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
${REESTAB_ACC_RECONF_FAIL_DU}    M55127C00510
${REESTAB_ACC_HO_FAIL_DU}    M55127C00511
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
${RRC_REESTAB_DISCARD_DU}    M55127C00513
${NRRCD_RRC_STPSUCC_HPA}    M55127C03001
${NRRCD_RRC_STPSUCC_MCS}    M55127C03002
${NRRCD_RRC_STPSUCC_MPS}    M55127C03003
${NRRCD_RRC_STPREQ_PAG_PRIO}    M55127C03004
${NRRCD_RRC_STPSUCC_PAG_PRIO}    M55127C03005
${NF1CD_DL_RRC_MSG_TRANSFER}    M55117C02001
${NF1CD_UL_RRC_MSG_TRANSFER}    M55117C02002
${NF1CD_DL_RRC_MSG_TRANSFER_SRB3}    M55117C02003
${NF1CD_UL_RRC_MSG_TRANSFER_SRB3}    M55117C02004
${NF1CD_UECTXT_MOD_REQSENT_SRB3}    M55117C02006
${NF1CD_UECTXT_MOD_CNFRECD_SRB3}    M55117C02007
${NF1CD_F1AP_PAGING_RECD}    M55117C03001
${NF1CD_PAG_DROP_CELL_MISMATCH}    M55117C03002
${NF1CD_UE_CTXT_STP_FAIL_SENT}    M55117C04001
${NF1CD_UE_CTXT_MOD_REQD_SENT}    M55117C04002
${NF1CD_UE_CTXT_MOD_CONF_T}    M55117C04003
${NF1CD_UE_CTXT_MOD_CONF_RECD}    M55117C04004
${NF1CD_UE_CTXT_MOD_REF_RECD}    M55117C04005
${F1AP_PAGING_RECD_PAG_PRIO}    M55117C04501

@{PM_Counters_Check_CNI83429}
...    ${F1_UE_CTXT_MOD_REQ_RECEIVED}=existing
...    ${F1_UE_CTXT_MOD_RESP_SENT}=existing
...    ${F1_UE_CTXT_MOD_FAIL_SENT}=existing
...    ${NF1CD_RAN_PAGING_SUCC_SENT}=existing
...    ${F1_DU_CU_CNF_UPD_ATT}=existing
...    ${F1_DU_CU_CNF_UPD_ACT}=existing
...    ${F1_DU_CU_CNF_UPD_RECNF}=existing
...    ${F1_DU_CU_CNF_UPD_DEACT}=existing
...    ${F1_DU_CU_CNF_UPD_SUC}=existing
...    ${F1_DU_CU_CNF_UPD_SUC_ACT}=existing
...    ${F1_DU_CU_CNF_UPD_SUC_RECNF}=existing
...    ${F1_DU_CU_CNF_UPD_SUC_DEACT}=existing
...    ${F1_DU_CU_CNF_UPD_P_SUC}=existing
...    ${F1_DU_CU_CNF_UPD_ACT_FL}=existing
...    ${F1_DU_CU_CNF_UPD_FL}=existing
...    ${F1_DU_CU_CNF_UPD_FL_SEM_ERR}=existing
...    ${F1_DU_CU_CNF_UPD_FL_MSG_STATE}=existing
...    ${F1_DU_CU_CNF_UPD_FL_OTH}=existing
...    ${F1_DU_DU_CNF_UPD}=existing
...    ${F1_DU_DU_CNF_UPD_ACT}=existing
...    ${F1_DU_DU_CNF_UPD_RECNF}=existing
...    ${F1_DU_DU_CNF_UPD_DEL}=existing
...    ${F1_DU_DU_CNF_UPD_ACK}=existing
...    ${F1_DU_DU_CNF_UPD_FL}=existing
...    ${F1_DU_DU_CNF_UPD_FL_SEM_ERR}=existing
...    ${F1_DU_DU_CNF_UPD_FL_MSG_STATE}=existing
...    ${F1_DU_DU_CNF_UPD_FL_NRESP}=existing
...    ${NF1CD_UECTXT_STP_REQRECD}=existing
...    ${NF1CD_UECTXT_STP_RESPSENT}=existing
...    ${NF1CD_UECTXT_STP_QCINOTSUPP}=existing
...    ${NF1CD_UECTXT_STP_IPNOTSUPP}=existing
...    ${NF1CD_UECTXT_STP_FAILMISC}=existing
...    ${NF1CD_UECTXT_MOD_REQSENT}=existing
...    ${NF1CD_UECTXT_REL_REQSENT}=existing
...    ${NF1CD_UECTXT_REL_CMDRECD}=existing
...    ${NF1CD_UECTXT_REL_CMPSENT}=existing
...    ${NF1CD_UECTXT_MOD_CNFRECD}=existing
...    ${F1_SETUP_ATT}=existing
...    ${F1_SETUP_SUCC}=existing
...    ${F1_SETUP_FAIL}=existing
...    ${F1_SETUP_FAIL_NRESP}=existing
...    ${F1_SETUP_FAIL_OVERLOAD}=existing
...    ${F1_SETUP_FAIL_PROT_ERR}=existing
...    ${F1_DU_RESET_RCV_PROT_ERR}=existing
...    ${F1_DU_P_RESET_RCV}=existing
...    ${F1_DU_P_RESET_ACK_SENT}=existing
...    ${F1_DU_P_RESET_ATT}=existing
...    ${F1_DU_P_RESET_SUCC}=existing
...    ${F1_DU_P_RESET_FAIL}=existing
...    ${F1_DU_P_RESET_FAIL_NRESP}=existing
...    ${F1_DU_G_RESET_RCV}=existing
...    ${F1_DU_G_RESET_ACK_SENT}=existing
...    ${F1_DU_G_RESET_ATT}=existing
...    ${F1_DU_G_RESET_SUCC}=existing
...    ${F1_DU_G_RESET_FAIL}=existing
...    ${F1_DU_G_RESET_FAIL_NRESP}=existing
...    ${F1_DU_RESET_FAIL_PROT_ERR}=existing
...    ${F1_DU_ERR_IND_SENT}=existing
...    ${F1_DU_ERR_IND_RCV}=existing
...    ${F1_DU_ERR_IND_RCV_ERR}=existing
...    ${F1_DU_UNKNOWN_MSG_RCV}=existing
...    ${NRRCD_RRC_STPREQ_MO_SIGNALLING}=existing
...    ${NRRCD_RRC_STPREQ_MO_DATA}=existing
...    ${NRRCD_RRC_STPREQ_MT_ACCESS}=existing
...    ${NRRCD_RRC_STPREQ_EMERGENCY}=existing
...    ${NRRCD_RRC_STPREQ_HIPRIO_ACCESS}=existing
...    ${NRRCD_RRC_STPREQ_MO_VOICECALL}=existing
...    ${NRRRD_RRC_SETUP_FAIL}=existing
...    ${NRRCD_RRC_STPREQ_MO_VIDEOCALL}=existing
...    ${NRRCD_RRC_STPREQ_MO_SMS}=existing
...    ${NRRCD_RRC_STPREQ_MPS}=existing
...    ${NRRCD_RRC_STPREQ_MCS}=existing
...    ${RRC_REESTAB_RECONF_FAILURE_DU}=existing
...    ${RRC_REESTAB_HO_FAILURE_DU}=existing
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=existing
...    ${REESTAB_ACC_RECONF_FAIL_DU}=existing
...    ${REESTAB_ACC_HO_FAIL_DU}=existing
...    ${REESTAB_ACC_OTHER_FAIL_DU}=existing
...    ${RRC_REESTAB_DISCARD_DU}=existing
...    ${NRRCD_RRC_STPSUCC_HPA}=existing
...    ${NRRCD_RRC_STPSUCC_MCS}=existing
...    ${NRRCD_RRC_STPSUCC_MPS}=existing
...    ${NRRCD_RRC_STPREQ_PAG_PRIO}=existing
...    ${NRRCD_RRC_STPSUCC_PAG_PRIO}=existing


@{PM_Counters_Check_other}
...    ${NF1CD_DL_RRC_MSG_TRANSFER}=existing
...    ${NF1CD_UL_RRC_MSG_TRANSFER}=existing
...    ${NF1CD_DL_RRC_MSG_TRANSFER_SRB3}=existing
...    ${NF1CD_UL_RRC_MSG_TRANSFER_SRB3}=existing
...    ${NF1CD_UECTXT_MOD_REQSENT_SRB3}=existing
...    ${NF1CD_UECTXT_MOD_CNFRECD_SRB3}=existing
...    ${NF1CD_F1AP_PAGING_RECD}=existing
...    ${NF1CD_PAG_DROP_CELL_MISMATCH}=existing
...    ${NF1CD_UE_CTXT_STP_FAIL_SENT}=existing
...    ${NF1CD_UE_CTXT_MOD_REQD_SENT}=existing
...    ${NF1CD_UE_CTXT_MOD_CONF_T}=existing
...    ${NF1CD_UE_CTXT_MOD_CONF_RECD}=existing
...    ${NF1CD_UE_CTXT_MOD_REF_RECD}=existing
...    ${F1AP_PAGING_RECD_PAG_PRIO}=existing

@{5GC000786}
...    NRCELL:actVoNR=true
...    NRBTS:gNbCuType=SA+NSA
...    NRBTS:suppCnPartialAdNgHo=true
...    NRDRB_5QI-1:fiveqiValueList=5
...    NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-2:fiveqiValueList=6
...    NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-3:fiveqiValueList=1
...    NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB_5QI-5:fiveqiValueList=9
...    NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-6:fiveqiValueList=7
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-7:fiveqiValueList=3
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-4
...    NRDRB_5QI-8:fiveqiValueList=4
...    NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-4
...    NRDRB_5QI-9:fiveqiValueList=128
...    NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-4
...    NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...    NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-2:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-2:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-2:rlcMode=RLC_AM
...    NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-3:resType=GBR
...    NRDRB-3:cellAggrLevel=Not FR1 CA eligible
...    NRDRB-3:rlcMode=RLC_UM
...    NRDRB-3:maxDataRateGbrDl=1000
...    NRDRB-3:maxDataRateGbrUl=1000
...    NRDRB-3:l2OHFactorDl=16
...    NRDRB-3:l2OHFactorUl=35
...    NRDRB-3:queuingDelayDiscarding=Disabled
...    NRDRB-3:dscp=46
...    NRDRB-4:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-4:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-4:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-4:resType=GBR
...    NRDRB-4:cellAggrLevel=Not FR1 CA eligible
...    NRDRB-4:rlcMode=RLC_UM
...    NRDRB-4:maxDataRateGbrDl=1000
...    NRDRB-4:maxDataRateGbrUl=1000
...    NRDRB-4:l2OHFactorDl=16
...    NRDRB-4:l2OHFactorUl=35
...    NRDRB-4:queuingDelayDiscarding=Disabled
...    NRDRB-4:dscp=46
...    NRDRB-4:discardTimer=150ms
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRDRB_MAC-3:lcgid=4
...    NRDRB_MAC-3:delayTarget=50
...    NRDRB_MAC-4:lcgid=5
...    NRDRB_MAC-4:delayTarget=50
...    NRDRB-2:discardTimer=infinity
...    NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB_MAC-5:lcgid=0
...    NRDRB_MAC-5:delayTarget=50

@{CB006112-A}
...    NRCELL:actEnhancedVoNR=true
...    NRBTS:tRLFindForDUVoNR=2000ms
...    NRCELL:n310VoNR=n20
...    NRCELL:t310VoNR=4000ms
...    NRDRB-3:discardTimer=150ms
...    NRDRB-3:dlFlowControlAlgo=none
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN

@{CB006112-C}
...    NRCELL:actGBRAdmissionControl=off
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxGBRTrafficLimit=${EMPTY}
...    NRCELL:addNumOfGBRBearers=0
...    NRCELL:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRBTS:actInterFreqHoSA=true
...    NRCELL:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=3|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=2|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=60|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms480|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=2|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=10|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=30|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms480|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=126530
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31|a2TimeToTriggerhoSsbRsrq=ms480
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34|a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=19|a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=39
...    NRCELL:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=36|a1TimeToTriggerhoSsbRsrq=ms480

@{5GC000704}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:absThreshSsbRsrpConsolidation=80
...    NRCELL-1:sMeasConfigSsbRsrp=20
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-2:absThreshSsbRsrpConsolidation=80
...    NRCELL-2:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    XNLINK-1:cPlaneIpAddr=10.0.1.124
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    XNLINK-10:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-10:administrativeState=Unlocked
...    NRADJGNB-10:gNbIdLength=22
...    NRADJGNB-10:gNodeBId=35
...    NRADJGNB-10:xnLinkRef=10
...    NRADJGNB-10:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-10:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    delete:NRADJNRCELL-1:freqBandIndicatorNR
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=35
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3

@{5GC000707_InterRAT}
...    NRBTS:actInterRatHoSA=true
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRHOIR-1:allowedMeasBandwidth=mbw50
...    NRHOIR-1:b2MeashoEnabled=rsrpAndRsrq
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=45
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=55
...    NRHOIR-1:earfcnValue=39750
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRADJECELL-1:eNodeBId=25
...    NRADJECELL-1:ePSTrackingAreaCode=222
...    NRADJECELL-1:earfcnValue=39750
...    NRADJECELL-1:lcrId=1
...    NRADJECELL-1:physCellId=12
...    NRADJECELL-1:eUtraMultibandInfoList=41
...    NRADJECELL-1:ecgiPlmn:mcc=311|mncLength=3
...    NRADJECELL-1:ecgiPlmn:mnc=489|mncLength=3
...    NRADJECELL-1:enbPlmn:mcc=311|mncLength=3
...    NRADJECELL-1:enbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-1/NRRELE-1:eNodeBId=25
...    NRCELL-1/NRRELE-1:eutranCellExcluded=false
...    NRCELL-1/NRRELE-1:lcrId=1
...    NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3

${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D220624FAC41E420F081425BE7E57
...    771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840A12DF3F33BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE08
...    21FD502820F65474881893EB1079083C205096F9F95DFC7FC0077F1FF000330014001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E2684000331
...    02B070A02000218815078500018280002988100900A2026C04605000C2508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C631
...    BFFFE000138036002800301C1401C0C4270070007000603E04882000000410000022080040000041000800008820010040010400200802208004020084100080401882001
...    00C021040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA02000072CB2801A83D5D2AAAA0F174AA283839804F9BF01C070079BF01C070079B
...    F01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C0700001400600400C010020808020040200801001C0180180400300A
...    00A01801001C0180380400700A01201802001C0380180800301200A02801041C0080180100300400A0080103801001004002004004010001AB06020721252627287700000
...    00361781C06000601A
${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B03004040CA00389A0000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA0000000010370B0200E8080000303
...    F400000000206E26040081838040000100FD0000000008100800803004809B000804180004020001008000402020080108000201000080404008011800040200010080004
...    020200400840002010100200440001008000402020040080
${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF43081A808081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C1082080304218018018200C1006084300
...    30022104002D1F5518502038410041460821610401051820A30410B082008284105182083841004142082061040105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887
...    878787000045F830000081010440668003E71E00020406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC000
...    00A00000061000880004

@{5GC000784}
...    NRCELL-1:arpPrioEmergencyCall=2
...    NRCELL-1:actEmergencyCall=true
...    NRCELL-1:emergencyCallFails=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS:timerXnDataFwdGuard=2000
...    NRCELL-2:arpPrioEmergencyCall=2
...    NRCELL-2:actEmergencyCall=true
...    NRCELL-2:emergencyCallFails=true
...    NRCELL-2:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-2:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true

@{CB008700}
...    NRCELL-1:actARPBasedAC=off
...    NRCELL-2:actARPBasedAC=off

@{5GC002145}
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS/TRACKINGAREA-200:fiveGsTac=0
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-201:fiveGsTac=1
...    NRBTS/TRACKINGAREA-201:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-201:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/SNSSAI-2:sd=13714342

@{CB008379}
...    NRCELL:actNonVoNRGbrService=true

@{5GC000772}
...    NRCELL-1:actCDrx=true
# ...    NRCELL-1:drxProfile1:drxInactivityTimer=200ms
...    NRCELL-2:actCDrx=true
# ...    NRCELL-2:drxProfile1:drxInactivityTimer=200ms

@{ngho}
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000

@{5GC000749}
...    NRBTS:actNormVCFallback=false
...    NRBTS:actRedirect=false
...    NRCELL-1:voiceFBMode=disabled
...    NRCELL/NRREDRT-1:redirFreqEutra=39750
...    NRCELL/NRREDRT-1:redirRat=eutra
...    NRCELL/NRREDRT-1:redirPrio=5
...    NRCELL/NRREDRT-2:redirRat=nr
...    NRCELL/NRREDRT-2:redirSsbScs=30 KHz
...    NRCELL/NRREDRT-2:redirFreqNr=636666
...    NRCELL/NRREDRT-2:redirPrio=4

@{5GC000710}
...    NRBTS:actMobilityProfile=true
...    NRBTS:actSPID=true
...    NRBTS/NRMOPR_NSA-1:a2MeashoEnabled=none
...    NRBTS/NRMOPR_NSA-1:a3MeasEnabled=none
...    NRBTS/NRMOPR_NSA-1:a5MeasEnabled=none
...    NRCELL:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRBTS/NRMORED-1:redirFreqNr=636666
...    NRBTS/NRMORED-1:redirRat=nr
...    NRBTS/NRMORED-1:redirPrio=3
...    NRBTS/NRMORED-2:redirFreqEutra=39750
...    NRBTS/NRMORED-2:redirRat=eutra
...    NRBTS/NRMORED-2:redirPrio=2
...    NRBTS/NRMOPR_SA-1:nrMoRedDNList=MRBTS-1/NRBTS-1/NRMORED-1,MRBTS-1/NRBTS-1/NRMORED-2

@{5GC001468}
...    NRBTS:actEmergencyFallback=true
...    NRCELL:emergencyFBMode=redirection
...    NRCELL/NRREDRT-1:redirFreqEutra=39750
...    NRCELL/NRREDRT-1:redirRat=eutra
...    delete:NRCELL/NRREDRT-1:redirSsbScs
...    delete:NRCELL/NRREDRT-1:redirFreqNr

@{5GC000711}
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:nonContentRachAcFullConfigHo=false
...    NRBTS:tNgRelocExecDeltL=5000

@{5GC000732}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=10000ms

@{CB008698}
...    NRBTS:actDrbPreemption=true
...    NRBTS:actUserPreemption=true
...    NRBTS:maxNumOfPreemptions=20
...    NRCELL-1:allowEmergencyReservForTempUse=true
...    NRCELL-1:numOfRadioResReservForTempUse=2
...    NRCELL:preferNsaPreemption=false
...    NRCELL:numOfRadioResReservForEmergency=2
...    NRCELL:maxNumOfRrcSA=2
...    NRCELL-1:maxNumOfUsersPerNRCell=6
...    NRCELL-1:maxNumOfNrDcSnUsers=6
...    NRCELL:maxNumOfCaUsersNRCell=2
...    NRCELL:maxNumOfSCellAlloc=2
...    NRCELL:maxNumOfUsersPerCell=2
...    NRCELL-1:maxNumOfNonGBRBearersSA=30
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:addGbrTrafficHo=${EMPTY}
...    NRBTS/NRCELLGRP-0:maxNumOfRrcCGRPSA=10
...    NRBTS/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=27
...    NRCELL-2:allowEmergencyReservForTempUse=false
...    NRCELL-2:numOfRadioResReservForTempUse=30
...    NRCELL-2:maxNumOfUsersPerNRCell=2
...    NRCELL-2:maxNumOfNrDcSnUsers=2
...    NRCELL-2:maxNumOfNonGBRBearersSA=550
...    NRBTS/NRCELLGRP-1:maxNumOfRrcCGRPSA=10
...    NRCELL-3:allowEmergencyReservForTempUse=false
...    NRCELL-3:numOfRadioResReservForTempUse=30
...    NRCELL-3:maxNumOfUsersPerNRCell=2
...    NRCELL-3:maxNumOfNrDcSnUsers=2
...    NRCELL-3:maxNumOfNonGBRBearersSA=550
...    NRBTS/NRCELLGRP-2:maxNumOfRrcCGRPSA=10
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120
...    NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=10
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=120
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:timerRejectWait=5
...    NRBTS/NRCELLGRP-0:addNumOfRrcCGRPSAHo=0
...    NRBTS/NRCELLGRP-1:addNumOfRrcCGRPSAHo=0
...    NRBTS/NRCELLGRP-2:addNumOfRrcCGRPSAHo=0

@{CB008232}
...    NRCELL-1:actPriorityAccess=true
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=8
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=4
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1
...    NRCELL-1:numOfRadioResReservForPa=2
...    NRBTS/NRDU-1:numOfDrbsReservForPa=0
...    NRCELL-1:tPageCorrInt=3000
...    NRCELL-1:raPrioritizationForAI=MPS
...    NRCELL-1:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-1:powerRampingStep=dB2
...    NRCELL-1:pagingPrioLevelPaMax=1
...    NRCELL-1:pagingPrioLevelPaMin=1

@{CB008232_A_B1_1}
...    NRBTS:applyPriorityAccess=HPA
...    NRCELL:maxNumOfRrcSA=1
...    NRCELL:maxNumOfUsersPerNRCell=10
...    NRCELL:maxNumOfNrDcSnUsers=10
...    NRBTS/NRCELLGRP-0:maxNumOfRrcCGRPSA=10
...    NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=10
...    NRCELL:numOfRadioResReservForPa=1
...    NRCELL:numOfRadioResReservForTempUse=1
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRCELL:allowEmergencyReservForTempUse=false
...    NRBTS:actUserPreemption=true
...    NRBTS:actDrbPreemption=false
...    NRCELL-1:actEmergencyCall=true

@{PMQAP}
...    NRBTS:actNrpmqapProfiles=true
...    NRBTS:actIpThpt=true
...    NRPMRNL-1:miNrNGCC=15min
...    NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
...    NRPMRNL-1:miNrNgInterfaceNrpmqap=15min
...    NRPMRNL-1:miNrNsaAcCuNrpmqap=15min
...    NRPMRNL-1:miNrPdcpCellNrpmqap=15min
...    NRPMRNL-1:miNrSaCuNrpmqap=15min
...    NRPMRNL-1:miNrUeStatNrpmqap=15min
...    NRPMRNL-1:miNrX2ccNrpmqap=15min
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=both
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=1-15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341

@{Counters_A_B1_1}
...    NRCELL-1:${NRRCC_RRC_STPSUCC_HPA}=3
...    NRCELL-1:${NRRCC_RRC_STPSUCC_MCS}=1
...    NRCELL-1:${NRRCC_RRC_STPSUCC_MPS}=0
...    NRDU-1:${NRRCD_RRC_STPSUCC_HPA}=3
...    NRDU-1:${NRRCD_RRC_STPSUCC_MCS}=1
...    NRDU-1:${NRRCD_RRC_STPSUCC_MPS}=0
...    NRDU-1:${NRRCD_RRC_STPREQ_HIPRIO_ACCESS}=4
...    NRDU-1:${NRRCD_RRC_STPREQ_MPS}=1
...    NRDU-1:${NRRCD_RRC_STPREQ_MCS}=2
...    NRCELL-1:${NRRCC_RRC_STPREQ_MPS}=1
...    NRCELL-1:${NRRCC_RRC_STPREQ_MCS}=2
...    NRCELL-1:${NRRCC_RRC_STPREQ_HIPRIO_ACCESS}=4
...    NRCELL-1:${NRRCC_RRC_STPREJ_MCS}=1
...    NRCELL-1:${NRRCC_RRC_STPREJ_MPS}=1
...    NRCELL-1:${NRRCC_RRC_STPREJ_HIPRIO_ACCESS}=1
...    NRCELL-1:${NRRCC_RRC_STPREQ_SMS}=1
...    NRCELL-1:${NRRCC_RRC_STPREQ_VDO}=1

${NRRCC_RRC_STPSUCC_HPA}    M55124C09001
${NRRCC_RRC_STPSUCC_MCS}    M55124C09002
${NRRCC_RRC_STPSUCC_MPS}    M55124C09003
${NRRCC_RRC_STPREQ_MCS}    M55124C01016
${NRRCC_RRC_STPREQ_MPS}    M55124C01015
${NRRCC_RRC_STPREQ_SMS}    M55124C01014
${NRRCC_RRC_STPREQ_VDO}    M55124C01017
${NRRCC_RRC_STPREQ_HIPRIO_ACCESS}    M55124C01005
${NRRCC_RRC_STPREJ_MCS}    M55124C01030
${NRRCC_RRC_STPREJ_MPS}    M55124C01029
${NRRCC_RRC_STPREJ_HIPRIO_ACCESS}    M55124C01025

${prevent_immediate_reset}    0x10077
${enableOAMcoreDump}    0x100b7
${biggerCoreDump}    0x10079
${noSyslogFreeze}    412
${enableCoreDumpDuringShutdown}    0x1001E
${enableBStatCoreFlag}    0x340001
${enableBStatPMflag}    0x340002

@{PARAMS_IN_SWCONFIG}
...    ${prevent_immediate_reset}=1
...    ${enableOAMcoreDump}=1
...    ${biggerCoreDump}=300000
...    ${noSyslogFreeze}=1
...    ${enableCoreDumpDuringShutdown}=1
...    ${enableBStatCoreFlag}=1
...    ${enableBStatPMflag}=1

*** Test Cases ***
CNI-83429-SR-A_ET_08_01_PM_object_creation_by_CPRT_for_NRDU_level_measurement_with_initialized_zero
    [Tags]
    Set UE Parameters Before Register
    modify counterEnable to check counter exist
    UE Register with Service and Deregister    ue_id=7    estab_cause=mo-SMS
    UE Register with Service and Deregister    ue_id=8    estab_cause=mo-VideoCall
    UE Register with PA    ue_id=1
    UE Register with PA    ue_id=2
    UE Register with PA    ue_id=3    estab_cause=mcs-PriorityAccess
    UE Register with PA RRCreject
    Check Counters    ${Counters_A_B1_1}
    Check Counters    ${PM_Counters_Check_CNI83429}
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri
    Execute Egate Command    trace_sim protocol=xn uec=1 amf=1 enb=3 on

Common Test Teardown And Stop Capture Logs for debug
    Run Keyword If Test Failed    sleep    25min
    Common Test Teardown And Stop Capture Logs
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=4 5qi=4 priority=4 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=7 5qi=7 default=on priority=7 pci=may_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=8 5qi=8 priority=8 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=9 5qi=9 priority=9 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A6 default=off ue=all amf=1
    Update Cfg    ue_nr_capabilities id=1-9 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    ue_param id=1-9 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    ${V_2}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg    ${V_2}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=3000
    ${V_3}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 daemon=10.0.2.1:22222 gnb_id=0x19:28 nssai=0x01:0xD143A5
    ...    x2_peers=none xn=10.0.1.126 amf=1
    Update Cfg    ${V_3}
    ${V_4}    catenate
    ...    set_cell id=1 gnb=4 pci=4:0 earfcn=39750:39750 tac=200 proxy=10.0.2.93:9999 nrci=0x1 tdd_cell=on bw=20MHz
    ...    technology=lte mandatory_for_activation=off
    Update Cfg    ${V_4}
    Update Cfg    gnb_param id=4 xn_listening_socket=1 send_xn_setup=false
    Update Cfg    ue_param id=1-9 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities}
    ${V_5}    catenate
    ...    ue_param id=31-35 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities}
    Update Cfg    ${V_5}

Set UE Parameters Before Register
    set UE history info    ue_id=1,2,3,4,5    history_id=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    pass_regexp=GNB-3: XnAP Link with GNB-2
    Execute Egate Command    set_pdu_param ue=1-9 pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=1-9 pdu=2 trf_type=internal
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1

set UE history info
    [Arguments]    ${ue_id}=1    ${history_id}=1
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${history_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${history_id}

modify counterEnable to check counter exist
    OnlineParamChange    ${CB008232_A_B1_1}
    Check Counters    ${PM_Counters_Check_CNI83429}
    Clean up AMF param to startup
    Check Counters    ${PM_Counters_Check_CNI83429}
    Check Counters    ${PM_Counters_Check_other}
    OnlineParamChange    ${counterDisable}
    Check Counters    ${PM_Counters_Check_CNI83429}
    Check Counters    ${PM_Counters_Check_other}
    OnlineParamChange    ${counterEnable}
    Check Counters    ${PM_Counters_Check_CNI83429}
    Check Counters    ${PM_Counters_Check_other}

UE Register To GNB
    [Arguments]    ${ue_id}=1    ${pass_regexp}=UE now in NG RM Regist    ${output_1}=1    ${output_2}=1
    ${ret}=    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    pass_regexp=${pass_regexp}
    Should Contain    ${ret}    ${output_1}
    Should Contain    ${ret}    ${output_2}

Clean up AMF param to startup
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    amf_ue_ics_param id=1 reset

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE Register with PA RRCreject
    UE Register with PA    ue_id=4    estab_cause=emergency    pass_regexp=rrcReject    output=detached
    UE Register with PA    ue_id=4    estab_cause=mps-PriorityAccess    pass_regexp=rrcReject    output=detached
    UE Register with PA    ue_id=4    estab_cause=mo-Signalling    pass_regexp=rrcReject    output=detached
    UE Register with PA    ue_id=4    estab_cause=mcs-PriorityAccess    pass_regexp=rrcReject    output=detached
    UE Register with PA    ue_id=5
    UE Register with PA    ue_id=6    estab_cause=highPriorityAccess    pass_regexp=rrcReject    output=detached

UE Register with PA
    [Arguments]    ${ue_id}=1    ${estab_cause}=highPriorityAccess    ${pass_regexp}=UE now in NG RM Regist    ${output}=1    ${output_1}=1
    ...    ${output_2}=1
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${estab_cause}
    UE Register To GNB    ue_id=${ue_id}    pass_regexp=${pass_regexp}    output_1=${output_1}    output_2=${output_2}
    Execute egate command    ue_disp    pass_regexp=${output}

UE Register with Service and Deregister
    [Arguments]    ${ue_id}    ${estab_cause}    ${reg_pass_regexp}=UE now in NG RM Regist    ${dereg_pass_regexp}=UE CONTEXT RELEASE COMPLETE
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${estab_cause}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    pass_regexp=${reg_pass_regexp}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=${dereg_pass_regexp}
