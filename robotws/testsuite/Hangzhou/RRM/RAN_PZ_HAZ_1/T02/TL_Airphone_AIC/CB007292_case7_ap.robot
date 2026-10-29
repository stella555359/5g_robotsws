*** Settings ***
Documentation
...    Author: Zhao Lanhua
...    Contact: lanhua.zhao@nokia-sbell.com
...    this file is for CB007292.
...    Please do not modify the file without notification to author

Suite Setup    Run keywords    Common Suite Setup For AIC
...            AND    Config network For Local Env_250
Suite Teardown    Run keywords     Custom Suite Teardown For AIC

Force Tags
...      CRT               #Tag Item
...      VRF_HAZ1          #Competence Area
...      TA_LEVEL_22       #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
${SA_UE_ID}    1

*** Test Cases ***
Upgrade_airphone_and_wts_build
    [Tags]     Upgrade_Airphone
    Config Iphy Ip For Local Env_250
    [Teardown]     Case Postcondition

CB007292-C_B1_Emergency_Non_GBR_QoS_flow_other_than_5QI5_Successful_initiation_of_Emergency_call
    [Documentation]
    ...    1. The purpose of this test case is:
    ...         This case will cover Successful Emergency call
    ...    2. Test Case Steps:
    ...         UE1 setup emergenct call with 5QI6 , with emergency ARP2
    ...         and 5QI2, with emergency ARP1
    ...    3. Expected Results:
    ...         EC call with PDU setup successfully
    [Tags]     CB007292_TC7    CRT    CLOUD_5G_AIC_SA_1xDingli_1xvDU_OE20_1xFHGW_3xAEQQ
    [Setup]    Case Precondition
    Start Counter For CB007292_TC7
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Sleep    5s
    Log to Console    \nUE1 Register
    Send AP Command    cmd=ue_register id=1
    ...                pass_regexp=UE now in NG RM Registered state
    ...                timeout=100s
    Log to Console		\nUE1 Trigger emergency call on 5QI-2\n
    Send AP Command    cmd=smf_param additional_qosflows_to_activate=2 id=1
    ...                pass_regexp=${None}
    ...                timeout=100s
    Send AP Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1 request_type=initial-emergency-request
    ...                pass_regexp=UE-1 PDU SESSION ID-1 setup/reestablishment complete
    ...                timeout=100s
    Sleep    5s
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nWireshark log of VCU: ${local_file_path}
    Check Wireshark Log for 5QI6      wireshark_path=${local_file_path}
    sleep    10min
    Log to Console		\nwaiting for CU counters update
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]     Case Postcondition

*** Keywords ***
Case Precondition
    Case Precondition For AP    tag=CB007292_TC7    product_type=vdu    operation=env_setup_sa

Case Postcondition
    Case Postcondition For AP

Custom Suite Teardown For AIC
    Common Suite Teardown For AIC
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}

    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}

Enter Egate
	Airphone Operation    operation=edaemon_egate_setup
	...                   product_type=${None}
	...                   traffic_info_dic=${None}
	...                   tag=${None}
	...                   cmd=${None}
	...                   pass_regexp=${None}
	...                   timeout=100s

Start Counter For CB007292_TC7
    ${rule1}    Catenate
#        ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
		...         Distname: MRBTS-11073/NRBTS-11073/NRCELL-1;
        ...         Counter: M55125C13030;
        ...         Counter rule: max(M55125C13030)==2;
    ${rule2}    Catenate
		...         Distname: MRBTS-11073/NRBTS-11073/NRCELL-1;
        ...         Counter: M55125C13031;
        ...         Counter rule: max(M55125C13031)==2;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0

Check Wireshark Log for 5QI6
    [Arguments]    ${wireshark_path}=${wireshark_local_file_path_vCU}
    &{analysis_dict}       Create Dictionary    filter_conditions=ngap.fiveQI == 6 && ngap.priorityLevelARP == 2
    ${expect_message}=    Set Variable    InitialContextSetupRequest
    ${result}=    Log Analysis    operation=filter    log_type=wireshark    log_path=${wireshark_path}
    ...                           analysis_dict=${analysis_dict}
    Should Contain    ${result}    ${expect_message}
