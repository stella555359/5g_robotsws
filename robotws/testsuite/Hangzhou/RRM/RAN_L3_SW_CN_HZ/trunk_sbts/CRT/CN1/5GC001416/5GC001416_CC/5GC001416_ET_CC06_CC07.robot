*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-yili.chen@nokia-sbell.com  release-20B
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{MFBI_activation}
...    @{MFBI_NRCONNECTEDMODE_Profile}
...    @{MFBI_NRCELL1}
...    @{MFBI_NRMULTIBANDINFO_PROFILE}
...    @{MFBI_NRNSPMAX_Profile}
...    @{HO}
...    @{Measho}

@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true

@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=10
@{MFBI_NRCELL1}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
@{HO}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=633364
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7845
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7847
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=633216
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:measGapSelectionSA=favourUeThroughput

@{Measho}
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=10
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=10
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64

@{ADD_DN}
...    MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
@{DELETE_DN}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN

${UE1_NR_Capa}  #CC06_07
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012CB2898183D6C10101
...    070EF1C39061C00103278FAB80027800E0009E0000841C4C000000006026C04C07007008089EC260060005038280381803C01C001A0F800000
...    0000000395340004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE1_RESULT}    Initial Context Setup Successful
${UE1_RESULT1}    800C04D80980
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:n77,appliedFreqBandListFilter:n78,n77'},

${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504
${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}    M55139C02007
${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}    M55139C02008
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550
${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322

@{PM_Counters_Check_1}
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-2:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=1
...    NRCELL-2:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=1
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_SUCC}==1

@{PM_Counters_Check_2}
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=1
...    NRCELL-1:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=1
...    NRCELL-2:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    ${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=1
...    ${ATT_IF_GNB_INTRA_DU_HO_SLICE}=1

*** Test Cases ***
5GC001416-ET-CC06-Check_Intra-gNB_Intra-DU_Handover_for_UE_using_alternative_bands_should_be_Successful
    [Documentation]
    [Tags]    QC_47229
    Delta Commission Parameters    ${ADD_DN}
    Clear Counter files
    register ue with ue_cap
    trigger A2 event
    trigger A3 event
    Check Counters    ${PM_Counters_Check_1}
    Clear Counter files
    trigger A2 event    7
    trigger A3 event    11    50    2    1
    Check Counters    ${PM_Counters_Check_2}
    Release Ues    ue_type=all
    Delta Commission Parameters    ${DELETE_DN}
    register ue with ue_cap
    trigger A2 event
    trigger A3 event failed

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${set_CELL1}    catenate    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633364:633364 gscn=7845 mandatory_for_activation=off
    ${set_CELL2}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633372:633372 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_CELL1}
    Update Cfg    ${set_CELL2}

register ue with ue_cap
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=${UE${ue_id}_RESULT}
    Should Contain    ${ret1}    ueCapabilityEnquiry
    Should Contain    ${ret1}    capabilityRequestFilter '${UE${ue_id}_RESULT1}'H    #lengacy
    Should Contain    ${ret1}    ueCapabilityInformation
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=10 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP UL

trigger A2 event
    [Arguments]    ${meas_id}=1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    measurementReport
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    freqBandIndicatorNR77
    Should Contain    ${ret1}    measIdToRemoveList{${meas_id}}
    Should Contain    ${ret1}    eventIdeventA1
    Should Contain    ${ret1}    eventIdeventA3
    Should Contain    ${ret1}    eventIdeventA5
    Should not Contain    ${ret1}    eventIdeventA2

trigger A3 event
    [Arguments]    ${meas_id}=5    ${phycell_id}=51    ${sourcecell_id}=1    ${targetcell_id}=2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=20 srsrq_nr=20 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.${sourcecell_id} to EXT_ENB-2.${targetcell_id} performed
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToAddModList
    Should Contain    ${ret1}    measObject measObjectNR
    Should Contain    ${ret1}    freqBandIndicatorNR 77
    Should Contain    ${ret1}    eventId eventA2

trigger A3 event failed
    [Arguments]    ${meas_id}=5    ${phycell_id}=51
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=20 srsrq_nr=20 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=measurementReport
    Should not Contain    ${ret1}    Intra-eNB handover
