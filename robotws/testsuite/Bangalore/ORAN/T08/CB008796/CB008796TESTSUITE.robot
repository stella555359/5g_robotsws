*** Settings ***
Library    BuiltIn
Library    OperatingSystem
Documentation
...   author: Dubey Rahul Kumar, Sreekumar Narimuri Kumaran
...   contact: rahul.kumar_dubey@nokia.com
...   Description: Test Suite for CB008796

Resource    ${CURDIR}/resources/expected_alarm.robot
Resource    ${CURDIR}/resources/CB008796_Common_keywords.robot
Resource    ${CURDIR}/resources/CB008796_Mobility_Keywords.robot
Resource    ${CURDIR}/resources/CB008796_Qos_keywords.robot
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/CommonKeywordResourceFile.robot
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/Topyoung_Attenuator_T08.robot

Library             DateTime

Force Tags      QCD_MN_RAN    QCP_RAN_ST

Suite Setup    Run Keywords      UTE_ORAN_TL_Bringup_Precondition
...    AND    Check fault 23 and fix
...    AND    Wait Until BTS is OnAir
...    AND    Set export yml    ${VM_IP}
...    AND    Copy swconfig to BTS    ${swconfig_path}
...    AND    Suite Setup

Suite Teardown      Suite Postcondition
Test Setup      Admin_setup
Test Teardown   Admin_teardown


*** Variables ***
${VM_usn}    ute
${VM_pwd}    BT5l@bus3rl0g1n
${VM_IP}    10.58.238.125

${DURATION}    800s
@{timeout}=    100

@{UE_alias_1}=  UE1
@{UE_alias_2}=  UE2
@{UE_alias_3}=  UE3
@{UE_alias_4}=  UE4
@{New_UE_alias}=    UE_1    UE_2

@{capabilities_1}    Legacy_1
@{capabilities_2}    Legacy_2
@{capabilities_3}    Legacy_3
@{capabilities_4}    Legacy_4
@{new_capabilities}    Legacy_1    Legacy_2

${dt_name_v}=    test_voice_call
${dt_name_dl}=    UDP
${dl_name}=    iperf_dl_test_1
@{deviation_dl}=    100
@{throughput_dl}=    100
@{direction_dl}=      dl
${dt_name}=     iperf_dl_test_1

${actsrb1_dist}   MRBTS-1024/LNBTS-1024/LNCEL-0
${actsrb1_dist2}   MRBTS-1024/LNBTS-1024/LNCEL-0/LNCEL_FDD-0
${par_name}    Activate SRB1 robustness
${par_abbr}    actSrb1Robustness
${par1_name}   Downlink SRB MIMO mode
${par1_abbr}   dlSrbMimoMode
${par2_name}   Enable OLQC
${par2_abbr}   dlOlqcEnable
${par3_name}   Enable DL AMC
${par3_abbr}   dlamcEnable
${par4_name}    Enable AMC for PDCCH link adaptation
${par4_abbr}   enableAmcPdcch
${par5_name}    Activate outer loop link adaptation
${par5_abbr}    actOlLaPdcch

${LNREL_DISTNAME}   MRBTS-1024/LNBTS-1024/LNCEL-0/LNREL-388
${HO_PAR_NAME}    Handover allowed
${HO_PAR_ABBR}    handoverAllowed

${filter_S1HO}    s1ap.radioNetwork == 2 || s1ap.radioNetwork == 16
${filter_X2HO}    x2ap
${filter_S1_for_LB}    s1ap

@{MI_12_stop_Voice_call_cmd}    adb -s e10355c0 shell input keyevent 6    adb -s 6266dd71 shell input keyevent 6
@{MI_12_start_Voice_call_cmd}    adb -s e10355c0 shell am start -a android.intent.action.CALL -d tel:+123456

@{adb_cmd1_emergency}    adb -s 6e152fc6 shell am start -a android.intent.action.CALL -d tel:911
@{adb_cmd2_emergency}    adb -s 6e152fc6 shell input tap 530 2250
@{adb_cmd3_emergency}    adb -s 6e152fc6 shell input tap 530 2150

@{UE1_stop_Voice_call_cmd}    adb -s AQKSLVH002N33100483 shell input keyevent 6    adb -s 6266dd71 shell input keyevent 6
@{UE1_start_Voice_call_cmd}    adb -s AQKSLVH002N33100483 shell am start -a android.intent.action.CALL -d tel:+123456

@{adb_cmd_stop_call_CSFB}    adb -s HQOZ8T85WOCEIBAY shell input keyevent 6    adb -s 6266dd71 shell input keyevent 6
@{adb_cmd_voice_call_CSFB}    adb -s HQOZ8T85WOCEIBAY shell am start -a android.intent.action.CALL -d tel:+123456


${BTS_IP}    10.58.239.191
${BTS1_ip}    10.58.239.191
${BTS2_ip}    10.58.239.192

${pva_ip}    10.45.153.212
${pva_vendor}    TOPYOUNG
${pva_model}	 TAS16T16-51-120-1N-DEJS

${connection1}    tcpdump
${connection2}    tcpdump1
@{counter_values}
${counter_LTE_Cell_Load}		LTE_Cell_Load
${counter_LTE_Cell_Resource}	LTE_Cell_Resource
${counter_LTE_Pwr_and_Qual_DL}    LTE_Pwr_and_Qual_DL
${scf_ofegsa_only}=	/home/ute/testline_configuration/7_2_UTE5GCLOUD1024/node1/SCF_MRBTS_1024_OFEGSA_ONLY.xml
${swconfig_path}=     testsuite/Bangalore/ORAN/T08/resources/config/swconfig.txt

*** Test Cases ***
CB008796_LTE2026_Verification_of_RRC_Signalling_Robustness_in_downlink
    [Tags]    QC_31740    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies rrc signalling robustness in downlink
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/CB008796_LTE2026_Verification_of_RRC_Signalling_Robustness_in_downlink/
    set test variable    ${out}
    create directory     ${out}
    CB008796QOS_TC_002

CB008796_LTE54_Verification_of_Inter_Frequency_Inter_eNB_S1_HO
    [Tags]    QC_31739    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies rrc signalling robustness in downlink
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/CB008796_LTE54_Verification_of_Inter_Frequency_Inter_eNB_S1_HO/
    set test variable    ${out}
    create directory     ${out}
    CB008796Mobility_TC_003

CB008796_CB0108827_LTE568_LTE53_Verification_of_Inter_Frequency_Inter_eNB_X2_HO
    [Tags]    QC_31744    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies rrc signalling robustness in downlink
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/CB008796_CB0108827_LTE568_LTE53_Verification_of_Inter_Frequency_Inter_eNB_X2_HO/
    set test variable    ${out}
    create directory     ${out}
    CB008796Mobility_TC_005

Test_LTE2149_CB012255_Verification_of_counters
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/Test_LTE2149_CB012255_Verification_of_counters/
    set test variable    ${out}
    create directory     ${out}
    CoamAdmin.unlock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-2    timeout=60    connection=oam
    sleep    30s
	Verify_uplink_Counters_with_SDLC_in_carrier_agrregation_EDA		M8001C217	${counter_LTE_Cell_Load}    0
	Verify_uplink_Counters_with_SDLC_in_carrier_agrregation_EDA		M8001C303	${counter_LTE_Cell_Load}    0
	Verify_uplink_Counters_with_SDLC_in_carrier_agrregation_EDA		M8011C74	${counter_LTE_Cell_Resource}    0
	Verify_uplink_Counters_with_SDLC_in_carrier_agrregation_EDA		M8011C50	${counter_LTE_Cell_Resource}    0
	Verify_MicroDTX_Counters_CB012255	 M8010C94  	 ${counter_LTE_Pwr_and_Qual_DL}		0

CB008796_490_LTE_to_LTE_mobility_Profileinstance_SPID
    [Tags]    QC_31738    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies successful PMCounter increment based on PLMN ID
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/CB008796_490_LTE_to_LTE_mobility_Profileinstance_SPID/
    set test variable    ${out}
    create directory     ${out}
	Log To Console    Attenuation successfull
    CB008796Mobility_TC_006


CB008796_LTE11_Verification_of_VoLTE_call_with_RoHC_enabled
    [Tags]    QC_31743    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies rrc signalling robustness in downlink
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/CB008796_LTE11_Verification_of_VoLTE_call_with_RoHC_enabled/
    set test variable    ${out}
    create directory     ${out}
    CB008796QOS_TC_004

CB008796_LTE2915_Verification_of_PMCOUNTER_basesd_on_PLMNID
    [Tags]    QC_31741    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies successful PMCounter increment based on PLMN ID
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/CB008796_LTE2915_Verification_of_PMCOUNTER_basesd_on_PLMNID/
    set test variable    ${out}
    create directory     ${out}
    CB008796QOS_TC_001

CB008796_LTE873_SRVCC_to_GSM_with_DTM_support
    [Tags]    QC_31745    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies rrc signalling robustness in downlink
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/CB008796_LTE873_SRVCC_to_GSM_with_DTM_support/
    set test variable    ${out}
    create directory     ${out}
    CB008796Mobility_TC_002


CB008796_LTE562_CSFB_Emergency_VoLTE_Call_To_GSM_Via_Redirect
    [Tags]   QC_31746    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies rrc signalling robustness in downlink
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/CB008796_LTE562_CSFB_Emergency_VoLTE_Call_To_GSM_Via_Redirect/
    set test variable    ${out}
    create directory     ${out}
    CB008796Mobility_TC_001_part1
    CB008796Mobility_TC_001_part2

CB008796_LTE496_Support_of_establishment_and_release_of_QCI2_GBR_bearer
    [Tags]    QC_31742    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies rrc signalling robustness in downlink
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/CB008796_LTE496_Support_of_establishment_and_release_of_QCI2_GBR_bearer/
    set test variable    ${out}
    create directory     ${out}
	Log To Console    Attenuation successfull
    CB008796QOS_TC_003

TC_LTE_Attach_for_CB012647_A
    [Tags]    QC_163283    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase only check LTE attach on ASOG is verified.
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB008796TESTSUITE/TC_LTE_Attach_for_CB012647_A/
    set test variable    ${out}
    create directory     ${out}
    CB008796_CB012646_TC_ASOG_cover_LTE


*** Keywords ***


Suite Setup
    Log to console    \n--Suite Setup--\n
    Open_Admin_Connection
    SCF commissioning    ${scf_ofegsa_only}   600   oam
    Wait Until BTS is OnAir
    ${SUITE_PATH}    set variable    ${OUTPUT_DIR}/
    Set Suite Variable    ${SUITE_PATH}
    log to console    .....--Precondition--.....
    ${scf_path}    Download SCF    ${SUITE_PATH}
    set global variable    ${scf_path}
    Get_Pre_Active_alarms
    Wait Until Keyword Succeeds    4min    1s    Lock_Cell_precondition
    PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Close_Admin_Connection

Suite Postcondition
    Open_Admin_Connection
    ${scf_path}    Download SCF    ${SUITE_PATH}
    Get_Pre_Active_alarms
    Get_Post_Active_alarms
    Wait Until Keyword Succeeds    4min    1s    Unlock_Cell_postcondition
    Close_Admin_Connection

Open_Admin_Connection
    Log To Console    connecting to BTS
    CoamAdmin.teardown_all_aliases_for_admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam

Close_Admin_Connection
    CoamAdmin.teardown    oam
    Log To Console    BTS IS Disconnected

Test_Setup
    Admin_setup
    ${scf_path}    Download SCF    ${out}
    Get_Pre_Active_alarms

Test_TearDown
    Admin_teardown
    Get_Post_Active_alarms
    Dcap check if still running and Stop Trace in teardown    ${START_TRACE_ID}
