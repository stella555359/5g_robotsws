*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CXT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
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
...    MRBTS-1/NRBTS-1:actGeneralConnectivitySilver=true
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

@{bandlist0}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77, 48
@{bandlist1}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77

${UE2_NR_Capa}  #CC02
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C012A36266B04050D012CB2898183D6C1010
...    1070EF1C39061C00103278FAB80027800E0009E00151B0A3582028680965944C0C1EB608080838778E1C830E0008193C7D5C0013C0070004F
...    0000820E2600000008385000000001C04D80990096014038058080440220F613003000281C1401C0C01E00E000D07C0000000000001CA9A00
...    02000012CB2A00695550500E001600000008010023162600020406080A0C0E10162022242632424A4C4E5094
${UE2_NR_Capa_1}  #CC02
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C012A36266B04050D012CB2898183D6C101
...    01070EF1C39061C00103278FAB80027800E0009E00151B0A3582028680965944C0C1EB608080838778E1C830E0008193C7D5C0013C0070004
...    F0000820E2600000008385000000002404D80990096014402F0700B0100880441EC260060005038280381803C01C001A0F800000000000039
...    5340004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA128
${UE2_RESULT}    Initial Context Setup Successful
${UE2_RESULT1}    801404D804B01300
#Description': 'supportedBandListNR:n77,n41,supportedBandCombinationList:n77,n41,appliedFreqBandListFilter:n78,n77,n38,n41,
#supportedBandCombinationList-v1540:2 element',
#Description1': 'supportedBandListNR:n77,n41,supportedBandCombinationList:n77,n41,
#appliedFreqBandListFilter:n78,n77,n38,n41,n48,supportedBandCombinationList-v1540:2 element'

${UE3_NR_Capa}  #CC03_05_08_09_10_11
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C012A36266B04050D012CB2898183D6C1010
...    1070EF1C39061C00103278FAB80027800E0009E00151B0A3582028680965944C0C1EB608080838778E1C830E0008193C7D5C0013C0070004F
...    0000820E2600000008385000000001C04D80990096014038058080440220F613003000281C1401C0C01E00E000D07C0000000000001CA9A00
...    02000012CB2A00695550500E001600000008010023162600020406080A0C0E10162022242632424A4C4E5094
${UE3_RESULT}    Initial Context Setup Successful
${UE3_RESULT1}    801404D804B01300
#Description': 'supportedBandListNR:n77,n41,supportedBandCombinationList:n77,n41,\
#appliedFreqBandListFilter:n78,n77,n38,n41,supportedBandCombinationList-v1540:2 element

${SGNB_SA_ADMISSION_REQ}    M55138C00001
#The number of radio admission requests for SA user. Updated in the CU when RRC resources are requested for new setup.
${SGNB_SA_ADMISSION_SUCC}    M55138C00002
#The number of admitted radio admission requests for SA user. Updated in the CU when RRC resources are admitted for new setup.
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501
#Number of SA user radio admission requests where request is on the alternative band
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502
#Number of SA user admitted radio admission requests where admission is done on the alternative band

@{PM_Counters_Check_1}
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=1

@{PM_Counters_Check_2}
...    NRCELL-1:${SGNB_SA_ADMISSION_REQ}=2
...    NRCELL-1:${SGNB_SA_ADMISSION_SUCC}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=2

*** Test Cases ***
5GC001416-ET-CC02-Check_ICS_should_include_inter-frequency_band_when_UE-NR-Capability_is_found_but_incomplete
    [Documentation]
    [Tags]    QC_XXXXXX
    Delta Commission Parameters    ${bandlist1}
    Clear Counter files
    register ue with ue_cap    ue_id=2    pdu_id=2
    Check Counters     ${PM_Counters_Check_1}
    Delta Commission Parameters    ${bandlist0}
    Clear Counter files
    add band to ue    ue_id=2
    enter idle state    ue_id=2
    exit idle state for case2    ue_id=2
    Check Counters     ${PM_Counters_Check_1}
    Release Ues  ue_type=all

5GC001416-ET-CC03-Check_ICS_should_include_inter-frequency_band_when_UE-NR-Capability_is_found_and_complete
    [Documentation]
    [Tags]    QC_XXXXXX
	Start To Capture Wireshark Log    CC03
    Delta Commission Parameters    ${bandlist1}
    Clear Counter files
    register ue with ue_cap    ue_id=3    pdu_id=3
    enter idle state    ue_id=3
    exit idle state    ue_id=3
    Check Counters     ${PM_Counters_Check_2}
    Check WireShark Log    ${CURDIR}/a2a_CC002/CC03.ini    name=CC03
    Release Ues  ue_type=all
    register ue with ue_cap    ue_id=3    pdu_id=3
    trigger A2 event
    trigger A1 event
    Release Ues  ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/1cell_ecpri

Modify Cfg
    ${set_gnb51}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
	...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${set_gnb52}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x03 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    ${cmd_1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22
	...    xn=10.0.1.2 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${cmd_1}
    Update Cfg    ${set_gnb51}
    Update Cfg    ${set_gnb52}
	Update Cfg    gnb_param id=5 xn_listening_socket=1 send_xn_setup=false

register ue with ue_cap
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=${UE${ue_id}_RESULT}
    Should Contain    ${ret1}    ueCapabilityEnquiry
    Should Contain    ${ret1}    capabilityRequestFilter '${UE${ue_id}_RESULT1}'H    #lengacy
    Should Contain    ${ret1}    ueCapabilityInformation

add band to ue
    [Arguments]    ${ue_id}=1
    Execute Egate Command
    ...    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa_1}

enter idle state
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release    pass_regexp=UE Context Release Complete
    sleep    2s
    Execute Egate Command    amf_ue_ics_param id=1 ue=${ue_id} include_ue_capabilities=true

exit idle state
    [Arguments]    ${ue_id}=1
    ${ret1}=    Execute Egate Command    ue_im_exit id=${ue_id}    pass_regexp=${UE${ue_id}_RESULT}
    should not contain    ${ret1}    ueCapabilityEnquiry
    should not contain    ${ret1}    ueCapabilityInformation

trigger A2 event
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    measurementReport
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measIdToRemoveList{1}
    Should Contain    ${ret1}    eventIdeventA1
    Should Contain    ${ret1}    eventIdeventA3
    Should Contain    ${ret1}    eventIdeventA5
    Should not Contain    ${ret1}    eventIdeventA2

trigger A1 event
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=4 event=A1 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    measurementReport
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToRemoveList{2}
    Should Contain    ${ret1}    measIdToRemoveList{4,5,6}
    Should Contain    ${ret1}    eventIdeventA2
    Should not Contain    ${ret1}    eventIdeventA1
    Should not Contain    ${ret1}    eventIdeventA3
    Should not Contain    ${ret1}    eventIdeventA5

exit idle state for case2
    [Arguments]   ${ue_id}=2
     ${ret1}=    Execute Egate Command    ue_im_exit id=${ue_id}    pass_regexp=${UE${ue_id}_RESULT}
    should contain    ${ret1}    ueCapabilityEnquiry
    should contain    ${ret1}    ueCapabilityInformation
    Should Contain    ${ret1}    capabilityRequestFilter '801C04D804B013201780'H
