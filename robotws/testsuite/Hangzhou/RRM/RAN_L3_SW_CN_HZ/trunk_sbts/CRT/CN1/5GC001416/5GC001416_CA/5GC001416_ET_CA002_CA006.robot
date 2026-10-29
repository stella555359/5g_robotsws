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

@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
@{MFBI_NRCELL1}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrBandPriority=0
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrBandPriority=1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=1
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
@{MFBI_deactivation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=false

${UE1_NR_Capa}
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C0203014002A36266B04050D012CB2898183D6C10101
...    070EF1C39061C00103278FAB80027800E0009E00001809B01301C01C020227B09801800140E0A00E0600F007000683E0000000000000E54D00
...    0100000965950034AAA82807000B000000040080118B130001020304050607080B101112131921252627284A0
${UE1_RESULT}    Initial Context Setup Failure
${UE1_RESULT1}    800C04D80980
${UE1_RESULT2}    cause RAN failure in radio interface procedure
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:no,appliedFreqBandListFilter:n78,n77'

${UE2_NR_Capa}
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012CB2898183D6C101010
...    70EF1C39061C00103278FAB80027800E0009E0000841C4C000000006026C04C07007008089EC260060005038280381803C01C001A0F80000000
...    00000394B40004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE2_RESULT}    Initial Context Setup Failure
${UE2_RESULT1}    800C04D80980
${UE2_RESULT2}    cause RAN radio resources not available
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:n77,appliedFreqBandListFilter:n78,n77,supportedBandwidthDL fr1:mhz80'},

${NNGCC_UE_CTXT_STP_FAIL_SENT}    M55125C02503
#Number of INITIAL CONTEXT SETUP FAILURE sent
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501
#Number of SA user radio admission requests where request is on the alternative band
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502
#Number of SA user admitted radio admission requests where admission is done on the alternative band
@{PM_Counters_Check}
...    NRCELL-1:${NNGCC_UE_CTXT_STP_FAIL_SENT}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=0

*** Test Cases ***
5GC001416-ET-CA002-CA006-Check_ICS_procedure_faile_with_Not_Optimized_ICS_without_UE_Capability_and_supportedBandCombinationList_missing
    [Documentation]
    ...    Check_ICS_procedure_faile_with_Not_Optimized_ICS_without_UE_Capability_and_supportedBandCombinationList_missing
    ...    Check_ICS_procedure_fail_with_Optimized_ICS_with_full_UE_Capability_but_wrong_bandwidth
    [Tags]    QC_60797
    Clear Counter files
    Check eConsole log in WTS
    register ue with ue_cap    ue_id=1
    register ue with ue_cap    ue_id=2
    Check Counters    ${PM_Counters_Check}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Check eConsole log in WTS
    Execute Egate Command    sim_log_set flush
    ${egate_content}    Run    cat /opt/wts/latest/egate_console.log
    Should contain     ${egate_content}    SIB1 frequencyInfoDL frequencyBand: 78
    Should contain     ${egate_content}    SIB1 frequencyInfoDL frequencyBand: 77
    Should contain     ${egate_content}    SIB1 FrequencyInfoDL additionalPmax: 1
    Should contain     ${egate_content}    SIB1 FrequencyInfoDL additionalSpectrumEmission: 1

register ue with ue_cap
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=${UE${ue_id}_RESULT}
    Should Contain    ${ret1}    ueCapabilityEnquiry
    Should Contain    ${ret1}    capabilityRequestFilter '${UE${ue_id}_RESULT1}'H    #lengacy
    Should Contain    ${ret1}    ueCapabilityInformation
    Should Contain    ${ret1}    ${UE${ue_id}_RESULT2}
