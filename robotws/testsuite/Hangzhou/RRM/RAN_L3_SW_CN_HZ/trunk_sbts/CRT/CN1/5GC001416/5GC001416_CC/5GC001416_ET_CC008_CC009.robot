*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-yili.chen@nokia-sbell.com  release-20B
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{MFBI_activation}
...    @{MFBI_NRCONNECTEDMODE_Profile}
...    @{MFBI_NRCELL1}
...    @{MFBI_NRMULTIBANDINFO_PROFILE}
...    @{MFBI_NRNSPMAX_Profile}
...    @{NRADJGNB}
...    @{NRADJNRCELL}
...    @{HO}
...    @{NRREL}
...    @{Measho}

@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true

@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=41
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=10
@{MFBI_NRCELL1}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=36
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1:actIncXn=true
@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=38
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=36
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=524000
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=48
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
@{HO}
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=38
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=523490
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
@{NRREL}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gNbId=36
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:lcrId=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
@{Measho}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=636668
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7881
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

@{multibandlist1}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
@{multibandlist2}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=48
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=48|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1

${UE1_NR_Capa}  #CC03_05_08_09_10_11
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C012A36266B04050D012CB2898183D6C1010
...    1070EF1C39061C00103278FAB80027800E0009E00151B0A3582028680965944C0C1EB608080838778E1C830E0008193C7D5C0013C0070004F
...    0000820E2600000008385000000001C04D80990096014038058080440220F613003000281C1401C0C01E00E000D07C0000000000001CA9A00
...    02000012CB2A00695550500E001600000008010023162600020406080A0C0E10162022242632424A4C4E5094
${UE1_RESULT}    Initial Context Setup Successful
${UE1_RESULT1}    801C04D804B00A202600
#Description': 'supportedBandListNR:n77,n41,supportedBandCombinationList:n77,n41,\
#appliedFreqBandListFilter:n78,n77,n38,n41,supportedBandCombinationList-v1540:2 element'},

${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504
${GNB_SA_DU_HO_ADMISS_MFBI_REQ}    M55139C02005
${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}    M55139C02006

@{PM_Counters_Check_1}
...    ${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    ${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0

@{PM_Counters_Check_2}
...    ${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    ${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    ${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=1
...    ${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=1

*** Test Cases ***
5GC001416-ET-CC08-Check_Inter-gNB_Handover_for_UE_using_alternative_bands_should_be_Successful
    [Documentation]
    [Tags]    QC_60824
    Delta Commission Parameters    ${multibandlist1}
    Clear Counter files
    ue history
    register ue with ue_cap
    trigger A2 event
    trigger A3 event
    Check Counters     ${PM_Counters_Check_1}
    Clear Counter files
    trigger A2 event    2    1,2
    trigger A3 event    9    50    ENB-5.1    EXT_ENB-2.1    77
    Check Counters     ${PM_Counters_Check_2}
    Release Ues  ue_type=all

5GC001416-ET-CC09-Check_Inter-gNB_Handover_failed_when_UE_not_support_alternative_band
    [Documentation]
    [Tags]    QC_60823
    Delta Commission Parameters    ${multibandlist1}
    Clear Counter files
    ue history
    register ue with ue_cap
    trigger A2 event
    trigger A3 event
    Check Counters     ${PM_Counters_Check_1}
    Clear Counter files
    Delta Commission Parameters    ${multibandlist2}
    trigger A2 event    2    1,2
    Start To Capture Wireshark Log    CC09
    trigger A3 event failed
    Check WireShark Log    ${CURDIR}/a2a_CC008/HandoverPreparationFailure.ini    name=CC09    wait_string=HandoverPreparationFailure
    Check Counters     ${PM_Counters_Check_1}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    BuiltIn.Log    check expect xnlink setup as expect    console=${True}
    Object Should Exist    XNLINK-1:xnLinkStatus=available

Modify Cfg
    ${set_gnb51}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${set_gnb52}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x03 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=524000:524000
    ...    gscn=6544 mapped_MFBI=41 mandatory_for_activation=off
    ${cmd_1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22
    ...    xn=10.0.1.2 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${cmd_1}
    Update Cfg    ${set_gnb51}
    Update Cfg    ${set_gnb52}
    Update Cfg    gnb_param id=5 xn_listening_socket=1 send_xn_setup=false

ue history
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=5 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=1 ue_history_list=1

register ue with ue_cap
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=${UE${ue_id}_RESULT}
    Should Contain    ${ret1}    ueCapabilityEnquiry
    Should Contain    ${ret1}    capabilityRequestFilter '${UE${ue_id}_RESULT1}'H    #lengacy
    Should Contain    ${ret1}    ueCapabilityInformation

trigger A2 event
    [Arguments]    ${meas_id}=1    ${measIdToRemoveList}=1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    measurementReport
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    freqBandIndicatorNR41
    Should Contain    ${ret1}    measIdToRemoveList{${measIdToRemoveList}}
    Should Contain    ${ret1}    eventIdeventA1
    Should Contain    ${ret1}    eventIdeventA3
    Should Contain    ${ret1}    eventIdeventA5
    Should not Contain    ${ret1}    eventIdeventA2

trigger A3 event
    [Arguments]    ${meas_id}=5    ${phycell_id}=48    ${sourcegnb}=EXT_ENB-2.1    ${targetgnb}=ENB-5.1    ${band}=41
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=20 srsrq_nr=20 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=Inter-eNB handover from ${sourcegnb} to ${targetgnb} performed
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToAddModList
    Should Contain    ${ret1}    measObject measObjectNR
    Should Contain    ${ret1}    freqBandIndicatorNR ${band}

trigger A3 event failed
    [Arguments]    ${meas_id}=9    ${phycell_id}=50
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=20 srsrq_nr=20 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=Handover canceled
    Should Contain    ${ret1}    measurementReport
    Should Contain    ${ret1}    HandoverPreparation
