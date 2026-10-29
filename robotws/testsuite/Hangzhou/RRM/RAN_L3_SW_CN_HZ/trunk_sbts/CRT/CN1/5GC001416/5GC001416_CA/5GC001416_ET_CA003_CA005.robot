*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-Chen.yili  release-20B
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{MFBI_activation}
...    @{MFBI_NRCONNECTEDMODE_Profile}
...    @{MFBI_NRCELL1}
...    @{MFBI_NRNSPMAX_Profile}
...    @{MFBI_NRMULTIBANDINFO_PROFILE}
...    @{HO_Config}

@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
@{MFBI_NRCELL1}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=1
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalPmax=2
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalSpectrumEmission=2
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2:nrNsPmaxList:nrNsPmaxPriority=2
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-3:nrNsPmaxList:additionalPmax=3
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-3:nrNsPmaxList:additionalSpectrumEmission=3
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-3:nrNsPmaxList:nrNsPmaxPriority=3
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-4:nrNsPmaxList:additionalPmax=4
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-4:nrNsPmaxList:additionalSpectrumEmission=4
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-4:nrNsPmaxList:nrNsPmaxPriority=4
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-5:nrNsPmaxList:additionalPmax=5
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-5:nrNsPmaxList:additionalSpectrumEmission=5
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-5:nrNsPmaxList:nrNsPmaxPriority=5
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-6:nrNsPmaxList:additionalPmax=6
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-6:nrNsPmaxList:additionalSpectrumEmission=6
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-6:nrNsPmaxList:nrNsPmaxPriority=6
@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrBandPriority=0
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrBandPriority=1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:freqBandIndicatorNR=38|nrBandPriority=0
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:freqBandIndicatorNR=38|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-3
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:freqBandIndicatorNR=41|nrBandPriority=1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:freqBandIndicatorNR=41|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-4
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:freqBandIndicatorNR=77|nrBandPriority=0
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-5
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:freqBandIndicatorNR=78|nrBandPriority=1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-6
@{HO_Config}
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1:timerXnDataFwdGuard=250

@{bandlist77}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
@{bandlist77_48}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77,48

#-F02 configuration
#online modify in SIB1
@{delta_para1}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=0
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=11
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
#online delete in SIB2/4
@{delta_para3}
...    delete:MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-3:nrNsPmaxList
@{delta_para4}
...    delete:MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-4:nrNsPmaxList
@{delta_para5}
...    delete:MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-5:nrNsPmaxList
@{delta_para6}
...    delete:MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-6:nrNsPmaxList
#online add in SIB2/SIB4
@{delta_para33}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-3:nrNsPmaxList:additionalPmax=6
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-3:nrNsPmaxList:additionalSpectrumEmission=6
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-3:nrNsPmaxList:nrNsPmaxPriority=6
@{delta_para44}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-4:nrNsPmaxList:additionalPmax=5
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-4:nrNsPmaxList:additionalSpectrumEmission=5
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-4:nrNsPmaxList:nrNsPmaxPriority=5
@{delta_para55}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-5:nrNsPmaxList:additionalPmax=4
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-5:nrNsPmaxList:additionalSpectrumEmission=4
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-5:nrNsPmaxList:nrNsPmaxPriority=4
@{delta_para66}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-6:nrNsPmaxList:additionalPmax=3
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-6:nrNsPmaxList:additionalSpectrumEmission=3
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-6:nrNsPmaxList:nrNsPmaxPriority=3


${UE1_NR_Capa}
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012CB2898183D6C10101
...    070EF1C39061C00103278FAB80027800E0009E0000841C4C000000006026C04C07007008089EC260060005038280381803C01C001A0F800000
...    0000000395340004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE1_RESULT}    Initial Context Setup Successful
${UE1_RESULT1}    800C04D80980
#CA03_04_07-UE1
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:n77,appliedFreqBandListFilter:n78,n77'}

${UE2_NR_Capa}
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012CB2898183D6C10101
...    070EF1C39061C00103278FAB80027800E0009E0000841C4C000000006026C04C07007008089EC260060005038280381803C01C001A0F800000
...    0000000395340004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE2_NR_Capa1}
...    SEPARATOR=
...   E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012CB2898183D6C1010
...   1070EF1C39061C00103278FAB80027800E0009E0000841C4C00000000A026C04C805E0E00E010113D84C00C000A070500703007803800341F0
...   00000000000072A68000800004B2CA801A55541403800580000002004008C58980008101820283038405880889098C909293139425
${UE2_RESULT}    Initial Context Setup Successful
${UE2_RESULT1}    800C04D80980
#CA05-UE2
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:n77,appliedFreqBandListFilter:n78,n77',
#Description1': 'supportedBandListNR:n77,supportedBandCombinationList:n77,appliedFreqBandListFilter:n78,n77,n48'

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

@{PM_Counters_Check_2}
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=1

@{PARAMS_IN_SWCONFIG}
...  0x59004D=1    #set now in the QT swconfig file, till we have verified that the UE side is aligned in term of capabilities
*** Test Cases ***
5GC001416-ET-CA003-Check_ICS_procedure_success_with_Not_Optimized_ICS_with_full_UE_Capability
    [Documentation]
    ...    Check_ICS_procedure_success_with_Not_Optimized_ICS_with_full_UE_Capability
    [Tags]    QC_60796
    update alternative band    ${bandlist77}
    Not Optimized ICS with full UE Capability    PM_Counters_Check=${PM_Counters_Check_1}
    Check P-max after online modify
    #F02 - Verify_online_delete_Pmax_broadcast_in_SIB1_2_4
    Check P-max after online delete
    #F02 - Verify_online_add_Pmax_broadcast_in_SIB1_2_4
    Check P-max after online add

5GC001416-ET-CA005-Check_ICS_procedure_success_with_appliedFreqBandListFilter_present_but_incomplete
    [Documentation]
    ...    Check_ICS_procedure_success_with_appliedFreqBandListFilter_present_but_incomplete
    [Tags]    QC_60794
    update alternative band    ${bandlist77}
    Clear Counter files
    register ue with ue_cap    ue_id=2
    Check Counters    ${PM_Counters_Check_2}
    Clear Counter files
    update alternative band    ${bandlist77_48}
    add band to ue
    #enter idle state    ue_id=2
    exit idle state for case5    ue_id=2
    Check Counters    ${PM_Counters_Check_2}
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

update alternative band
    [Arguments]    ${bandlist}
    Delta Commission Parameters    ${bandlist}

Not Optimized ICS with full UE Capability
    [Arguments]    ${PM_Counters_Check}    ${ue_id}=1
    Start To Capture Wireshark Log    pcap_UE${ue_id}
    Clear Counter files
    register ue with ue_cap    ue_id=${ue_id}
    enter idle state
    exit idle state    ue_id=${ue_id}
    Check Counters    ${PM_Counters_Check}
    Stop Capture Wireshark Log    pcap_UE${ue_id}
    #F01 test step
    Check eConsole log in WTS for P-max

register ue with ue_cap
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=${UE${ue_id}_RESULT}
    Should Contain    ${ret1}    ueCapabilityEnquiry
    Should Contain    ${ret1}    capabilityRequestFilter '${UE${ue_id}_RESULT1}'H    #lengacy
    Should Contain    ${ret1}    ueCapabilityInformation

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

Check eConsole log in WTS for P-max
    Execute Egate Command    sim_log_set flush
    ${egate_content}    Run    cat /opt/wts/latest/egate_console.log
    Should contain     ${egate_content}    SIB1 frequencyInfoDL frequencyBand: 78
    Should contain     ${egate_content}    SIB1 FrequencyInfoDL additionalPmax: 1
    Should contain     ${egate_content}    SIB1 FrequencyInfoDL additionalSpectrumEmission: 1
    Should contain     ${egate_content}    SIB1 frequencyInfoDL frequencyBand: 77
    Should contain     ${egate_content}    SIB1 FrequencyInfoDL additionalPmax: 2
    Should contain     ${egate_content}    SIB1 FrequencyInfoDL additionalSpectrumEmission: 2
    Should contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalPmax: 3
    Should contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalSpectrumEmission: 3
    Should contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalPmax: 4
    Should contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalSpectrumEmission: 4
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList frequencyBand: 77
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList additionalPmax: 5
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList additionalSpectrumEmission: 5
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList frequencyBand: 78
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList additionalPmax: 6
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList additionalSpectrumEmission: 6

Check P-max after online modify
    Delta Commission Parameters    ${delta_para1}
    sleep    30s    #wait for console all logs printed in egate console
    Execute Egate Command    sim_log_set flush
    ${egate_content}    Run    cat /opt/wts/latest/egate_console.log
    Should contain     ${egate_content}    SIB1 FrequencyInfoDL additionalPmax: 11
    Should contain     ${egate_content}    SIB1 FrequencyInfoDL additionalSpectrumEmission: 0

Check P-max after online delete
    Delta Commission Parameters    ${delta_para3}
    Delta Commission Parameters    ${delta_para4}
    Delta Commission Parameters    ${delta_para5}
    Delta Commission Parameters    ${delta_para6}
    Execute Egate Command    sim_log_set flush
    ${egate_content}    Run    cat /opt/wts/latest/egate_console.log
    sleep    30s    #wait for console all logs printed in egate console
    Should contain x times    ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalPmax: 3    2
    Should contain x times    ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalSpectrumEmission: 3    2
    Should contain x times    ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalPmax: 4    4
    Should contain x times    ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalSpectrumEmission: 4    4
    Should contain x times    ${egate_content}    SIB4 interFreqCarrierFreqList additionalPmax: 5    6
    Should contain x times    ${egate_content}    SIB4 interFreqCarrierFreqList additionalSpectrumEmission: 5    6
    Should contain x times    ${egate_content}    SIB4 interFreqCarrierFreqList additionalPmax: 6    8
    Should contain x times    ${egate_content}    SIB4 interFreqCarrierFreqList additionalSpectrumEmission: 6    8

Check P-max after online add
    Delta Commission Parameters    ${delta_para33}
    Delta Commission Parameters    ${delta_para44}
    Delta Commission Parameters    ${delta_para55}
    Delta Commission Parameters    ${delta_para66}
    Execute Egate Command    sim_log_set flush
    ${egate_content}    Run    cat /opt/wts/latest/egate_console.log
    sleep    30s    #wait for console all logs printed in egate console
    Execute Egate Command    sim_log_set flush
    ${egate_content}    Run    cat /opt/wts/latest/egate_console.log
    Should contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalPmax: 6
    Should contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalSpectrumEmission: 6
    Should contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalPmax: 5
    Should contain     ${egate_content}    SIB2 intraFreqCellReselectionInfo additionalSpectrumEmission: 5
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList additionalPmax: 4
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList additionalSpectrumEmission: 4
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList additionalPmax: 3
    Should contain     ${egate_content}    SIB4 interFreqCarrierFreqList additionalSpectrumEmission: 3

add band to ue
    [Arguments]    ${ue_id}=2
    Execute Egate Command
    ...    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa1}

exit idle state for case5
    [Arguments]   ${ue_id}=1
    ${ret1}=    Execute Egate Command    ue_im_exit id=${ue_id}    pass_regexp=${UE${ue_id}_RESULT}
    should contain    ${ret1}    ueCapabilityEnquiry
    should contain    ${ret1}    ueCapabilityInformation
    Should Contain    ${ret1}    capabilityRequestFilter '801404D809900BC0'H
