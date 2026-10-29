*** Settings ***
Documentation
...   author: Lekhashree S N
...   Description: Test Suite for CB012113
Test Setup      Admin_setup
Test Teardown   Admin_teardown
Resource    CB012113_keywords.robot
Resource    expected_alarms.robot

Force Tags      VRF_BLR1_T08_VRF_ORAN    VRF_BLR1

*** Variables ***
${pva_ip}    10.45.153.212
@{UE_alias}=    UE_1
@{capabilities}=    Legacy_1
${TC_AP_ON}    test_UE_AP_on
${TC_AP_Off}    test_UE_AP_off
${SCF_VONR_Disabled}    /home/ute/testline_configuration/7_2_UTE5GCLOUD1042/node1/Configuration_scf_MRBTS-1402_12113_vonr_disabled.xml
${SCF_VONR_enabled}    /home/ute/testline_configuration/7_2_UTE5GCLOUD1042/node1/Configuration_scf_MRBTS-1402_12113_vonr_enabled.xml
${msg0}    InitialULRRCMessageTransfer:-22970369
${msg1}    rrcReestablishmentRequest:-0
${msg2}    InitialUEMessage:-REGISTRATION REQUEST
${msg3}    InitialContextSetupRequest:-fiveQI 1,fiveQI 5,REGISTRATION ACCEPT,RedirectionVoiceFallback : possible
${msg5}    InitialContextSetupResponse:-pDUSessionResourceSetupUnsuccessfulTransfer,${mss}
${msg7}    rrcRelease:-redirectedCarrierInfo eutra,eutraFrequency 1575
${msg4}    InitialContextSetupFailure:-pDUSessionResourceSetupUnsuccessfulTransfer,${mss}
${msg6}    dlInformationTransfer:-REGISTRATION ACCEPT
${mss}     cause radioNetwork : ims-voice-eps-fallback-or-rat-fallback-triggered

*** Test Cases ***
CB012113_A_Verification_With_Feature_Disabled_And_Enabled_Performs_RRE__With_VoNR_Disabled
    [Tags]    QC_605445    CRT    SBTS00
	${out}    set variable
    ...    ${OUTPUT_DIR}/CB012113/CB012113_A_Verification_With_Feature_Disabled_And_Enabled_Performs_RRE__With_VoNR_Disabled/
    set test variable    ${out}
    create directory     ${out}
    Log To Console    \n --- CB012113_A_Verification_With_Feature_Disabled_And_Enabled_Performs_RRE__With_VoNR_Disabled ---
	Testcase execution    ${SCF_VONR_Disabled}
    Log To Console    --- CB012113 VoNR Disable part is successfully verified --- \n

CB012113_A_Verification_With_Feature_Disabled_And_Enabled_Performs_RRE__With_VoNR_Enabled
    [Tags]    QC_616500    CRT    SBTS00
	${out}    set variable
    ...    ${OUTPUT_DIR}/CB012113/CB012113_A_Verification_With_Feature_Disabled_And_Enabled_Performs_RRE__With_VoNR_Enabled/
    set test variable    ${out}
    create directory     ${out}
    Log To Console    \n --- CB012113_A_Verification_With_Feature_Disabled_And_Enabled_Performs_RRE__With_VoNR_Enabled ---
	Testcase execution    ${SCF_VONR_enabled}
    Log To Console    --- CB012113 VoNR Enabled part is successfully verified --- \n

*** Keywords ***
Testcase execution
	[Arguments]    ${scf}
	SCF commissioning and check ONAIR    ${scf}
	Prepare UE    ${UE_alias}     ${capabilities}
	log to console    --UE AP mode turning ON
	ta_ultracaller.start_voice_call    ue_alias=${UE_alias}    testcasename=${TC_AP_ON}
    Sleep    30
    Trigger_RRE    DCAPLog1
    EMIL_Log_Validation    ${out}    ${msg0}|${msg1}|${msg2}|${msg3}|${msg4}|${msg7}    DCAPLog1
    EMIL_Log_Validation_msg_notpresent    ${out}    ${msg6}    DCAPLog1
    Validating_counters_for_feature_disable
	Enable Feature
    Trigger_RRE    DCAPLog2
    EMIL_Log_Validation    ${out}    ${msg0}|${msg1}|${msg2}|${msg3}|${msg6}|${msg5}|${msg7}    DCAPLog2
    Validating_counters_for_feature_enable

Trigger_RRE
	[Arguments]    ${dcap_file_name}
	pva.PVA_Attenuator_Cell2    ${pva_ip}
    Log to Console    --- PVA Port 13 Set to 0 ---
	log to console    --UE AP mode turning OFF
    ta_ultracaller.start_voice_call    ue_alias=${UE_alias}    testcasename=${TC_AP_Off}
    Dcap Start Trace SA
	Volte_Call_using_adb_command
    sleep    1min
	pva.PVA_Attenuator_Cell5    ${pva_ip}
    Log to Console    --- PVA Port 14 Set to 0 and port 13 to 80 ---
	#sleep    5s
	pva.PVA_Attenuator_Cell8    ${pva_ip}
    Log to Console    --- PVA Port 14 Set to 120 ---
	Stop_Volte_Call_using_adb_command
	log to console    --UE AP mode turning ON
    ta_ultracaller.start_voice_call    ue_alias=${UE_alias}    testcasename=${TC_AP_ON}
    Sleep    30
    Dcap Stop Trace and Get results SA    ${dcap_file_name}
