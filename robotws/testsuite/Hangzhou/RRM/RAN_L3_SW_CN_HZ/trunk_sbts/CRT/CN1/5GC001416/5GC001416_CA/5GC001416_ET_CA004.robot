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

@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
@{MFBI_NRCELL1}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=38
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1:multiFreqBandIndicatorNR=77

${UE1_NR_Capa}
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012CB2898183D6C10101
...    070EF1C39061C00103278FAB80027800E0009E0000841C4C000000006026C04C07007008089EC260060005038280381803C01C001A0F800000
...    0000000395340004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE1_RESULT}    Initial Context Setup Successful
${UE1_RESULT1}    800C04D80980
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:n77,appliedFreqBandListFilter:n78,n77'},

${SGNB_SA_ADMISSION_REQ}    M55138C00001
#The number of radio admission requests for SA user. Updated in the CU when RRC resources are requested for new setup.
${SGNB_SA_ADMISSION_SUCC}    M55138C00002
#The number of admitted radio admission requests for SA user. Updated in the CU when RRC resources are admitted for new setup.
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501
#Number of SA user radio admission requests where request is on the alternative band
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502
#Number of SA user admitted radio admission requests where admission is done on the alternative band
@{PM_Counters_Check_1}
...    NRCELL-1:${SGNB_SA_ADMISSION_REQ}=2
...    NRCELL-1:${SGNB_SA_ADMISSION_SUCC}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=2

@{PARAMS_IN_CP_UE_RD}    rdUeContextRequest=True
@{PARAMS_IN_CP_CL_RD}    rdUeContextRequest=True
*** Test Cases ***
5GC001416-ET-CA004-Check_ICS_procedure_success_with_Optimized_ICS_with_full_UE_Capability
    [Documentation]
    ...    Check_ICS_procedure_success_with_Optimized_ICS_with_full_UE_Capability
    [Tags]    QC_60795
    Clear Counter files
    register ue with ue_cap for case4
    enter idle state
    exit idle state
    Check Counters    ${PM_Counters_Check_1}
    Check eConsole log in WTS                #A01/02/03 test setup

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Check eConsole log in WTS
    Execute Egate Command    sim_log_set flush
    ${egate_content}    Run    cat /opt/wts/latest/egate_console.log
    Should contain     ${egate_content}    SIB1 frequencyInfoDL frequencyBand: 78
    Should contain     ${egate_content}    SIB1 frequencyInfoDL frequencyBand: 77
    Should not contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo frequencyBand: 78
    Should not contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo frequencyBand: 77
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList frequencyBand: 38

register ue with ue_cap for case4
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa}
    ${ret1}=    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    Should Contain    ${ret1}    ueCapabilityEnquiry
    Should Contain    ${ret1}    capabilityRequestFilter '${UE${ue_id}_RESULT1}'H    #lengacy
    Should Contain    ${ret1}    ueCapabilityInformation
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=Pdu Session Resource Setup Response

enter idle state
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release    pass_regexp=UE Context Release Complete
    sleep    2s    #wait for log print finished
    Execute Egate Command    amf_ue_ics_param id=1 ue=${ue_id} include_ue_capabilities=true

exit idle state
    [Arguments]   ${ue_id}=1
    ${ret1}=    Execute Egate Command    ue_im_exit id=${ue_id}    pass_regexp=${UE${ue_id}_RESULT}
    should not contain    ${ret1}    ueCapabilityEnquiry
    should not contain    ${ret1}    ueCapabilityInformation
