*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com
...   ST_SISO

Suite Setup    Case suite_setup
Suite Teardown    Case Suite Teardown
Force Tags    5G_RAN_TDD    STATE_SW_UPLOADED

Resource    ./resources/comm_9260.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Test Cases ***
[1]CB009260-SR_8_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_interface
    [Documentation]
    ...    This User Scenario is to describe support for cooled SFP+/SFP28 transceiver modules
    ...    when BTS starts up or operator plugs in/replaces a SFP+/SFP28 transceiver module.
    ...    -11.01.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009260
    [Setup]   Case Setup
    Check BTS Should Be Normal
#    SBTS Login
#    run keyword and continue on failure   Check if Unexpected History Alarm Exist
#    ${snapshot_file_path}    Save Snapshot Log
#    Extract logs from snapshot    snapshot_file=${snapshot_file_path}    RMOD_SN=EB2110R1108
#    Check CooledTransceiverDeclaration
#    [Teardown]    run keywords    SBTS Logout    AND    robot_common_operations.Common case Teardown
    [Teardown]    new case teardown

[1]CB009260-SR_10_BTS_startup_SFP+_or_SFP28_transceivers_cold_start_up_support_for_interface
    [Documentation]
    ...    This User Scenario is to describe cold start up of SFP+/SFP28 transceiver modules
    ...    when BTS starts up or operator plugs in/replaces a SFP+/SFP28 transceiver.
    ...    -12.01.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_TRUNK    CB009260
    [Setup]    Case Setup
    Check BTS Should Be Normal
    SBTS Login
    run keyword and continue on failure   Check if Unexpected History Alarm Exist
    Check Port ModTemp
    [Teardown]    run keywords    SBTS Logout    AND    robot_common_operations.Common case Teardown

[1]CB009260-SR_5_Operator_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
    [Documentation]
    ...    This User Scenario is to describe the SFP+/SFP28 transceiver module validation
    ...    when BTS starts up or operator plugs in/replaces a SFP+/SFP28 transceiver module.
    ...    -13.01.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009260
    [Setup]    Case Setup
    Check BTS Should Be Normal
    SBTS Login
#    run keyword and continue on failure   Check if Unexpected History Alarm Exist
#    Delete sfp in sfpwhitelist
#    Reset BTS And Wait Until On Air
#    sleep    15s
#    Check SFP Fault And Check Status
#    Modify Parameter SfpOperatorMode    Actual_value=true
#    sleep    15s
#    Check NO SFP Fault And Check Status
#    sleep    60s
#    Wait Until BTS Should Be Normal
#    Check NO SFP Fault And Check Status
#   Reset BTS And Wait Until On Air
#    sleep    10s
#    Check NO SFP Fault And Check Status
#    Modify Parameter SfpOperatorMode    Actual_value=false
#    sleep    15s
#    Check SFP Fault And Check Status
#    sleep    60s
#    Wait Until BTS Should Be Normal
#    Check SFP Fault And Check Status
    SBTS Logout
#    [Teardown]    case_teardown
    [Teardown]    new case teardown

[1]CB009260-SR_7_The_BTS_shall_support_NIDD_parameter_(EQM_APEQM-SFPOperatorMode)_to_enable_and_disable_SFP+_or_SFP28_compliance_validation
    [Documentation]
    ...    SFPOperatorMode is used to enable/disable skipping compliance validation of the transceiver module.
    ...    True value of the parameter means skip compliance validation
    ...    -13.01.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009260
    [Setup]   Case Setup
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
    [Teardown]    robot_common_operations.Common case Teardown





[1]CB009260-SR_8_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_interface_23R3
    [Documentation]
    ...    This User Scenario is to describe support for cooled SFP+/SFP28 transceiver modules
    ...    when BTS starts up or operator plugs in/replaces a SFP+/SFP28 transceiver module.
    ...    -11.01.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009260
    [Setup]   Case Setup
    Check BTS Should Be Normal
    SBTS Login
#    run keyword and continue on failure   Check if Unexpected History Alarm Exist
#    ${snapshot_file_path}    Save Snapshot Log
#    Extract logs from snapshot    snapshot_file=${snapshot_file_path}    RMOD_SN=EB2110R1108
#    Check CooledTransceiverDeclaration
    [Teardown]    run keywords    SBTS Logout    AND    robot_common_operations.Common case Teardown

[1]CB009260-SR_10_BTS_startup_SFP+_or_SFP28_transceivers_cold_start_up_support_for_interface_23R3
    [Documentation]
    ...    This User Scenario is to describe cold start up of SFP+/SFP28 transceiver modules
    ...    when BTS starts up or operator plugs in/replaces a SFP+/SFP28 transceiver.
    ...    -12.01.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_TRUNK    CB009260
    [Setup]    Case Setup
    Check BTS Should Be Normal
    SBTS Login
#    run keyword and continue on failure   Check if Unexpected History Alarm Exist
#    Check Port ModTemp
    [Teardown]    run keywords    SBTS Logout    AND    robot_common_operations.Common case Teardown

[1]CB009260-SR_5_Operator_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface_23R3
    [Documentation]
    ...    This User Scenario is to describe the SFP+/SFP28 transceiver module validation
    ...    when BTS starts up or operator plugs in/replaces a SFP+/SFP28 transceiver module.
    ...    -13.01.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009260
    [Setup]    Case Setup
    Check BTS Should Be Normal
#    SBTS Login
#    run keyword and continue on failure   Check if Unexpected History Alarm Exist
#    Delete sfp in sfpwhitelist
#    Reset BTS And Wait Until On Air
#    sleep    15s
#    Check SFP Fault And Check Status
#    Modify Parameter SfpOperatorMode    Actual_value=true
#    sleep    15s
#    Check NO SFP Fault And Check Status
#    sleep    60s
#    Wait Until BTS Should Be Normal
#    Check NO SFP Fault And Check Status
#    Reset BTS And Wait Until On Air
#    sleep    10s
#    Check NO SFP Fault And Check Status
#    Modify Parameter SfpOperatorMode    Actual_value=false
#    sleep    15s
#    Check SFP Fault And Check Status
#    sleep    60s
#    Wait Until BTS Should Be Normal
#    Check SFP Fault And Check Status
#    SBTS Logout
#    [Teardown]    case_teardown

[1]CB009260-SR_7_The_BTS_shall_support_NIDD_parameter_(EQM_APEQM-SFPOperatorMode)_to_enable_and_disable_SFP+_or_SFP28_compliance_validation_23R3
    [Documentation]
    ...    SFPOperatorMode is used to enable/disable skipping compliance validation of the transceiver module.
    ...    True value of the parameter means skip compliance validation
    ...    -13.01.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009260
    [Setup]   Case Setup
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
    [Teardown]    robot_common_operations.Common case Teardown
*** Keywords ***
new case teardown
    robot_common_operations.Common case Teardown
    CI interface.Common Case Teardown

Case suite_setup
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
#    ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=${SBTS_scf_name}    Branch_scf_name=${branch_scf_name}
#    ...    branch_version=${branch_version}
#    Commission Default SCF    default_scf=${default_scf}
#    ${branch_scf_name}=SCF_SBTS23R3.xml

Case Suite Teardown
    robot_common_operations.Common Suite Teardown
    CI_interface.Common Case Teardown


Case Setup
        robot_common_operations.Common case Setup

Check SFP Fault And Check Status
    [Arguments]    ${faultID}=${4657}
    Log To Console    Check SFP fault 4657
    ${hwPath_list}    Get Alarm HwPath List    faultID=${faultID}
    ${SFP_list}    create list    eif1/SFP_R    bbext1/SFP_R    s_rf2/SFP_R    s_rf2/RMOD_R-2/opt_if0/SFP_R    q_rf2/RMOD_R-2/opt_if1/SFP_R
    FOR    ${item}    IN    @{SFP_list}
        check value in list    list=${hwPath_list}    value=${item}
    END
    ${RMOD_idx}    Get RMOD Index
    Check SFP Status    OPT_IF_runtime=RMOD_L-${RMOD_idx}

Get RMOD Index
    [Arguments]    ${connection}=default    ${expected_RMOD_SN}=EB2110R1108
    Log To Console    Get RMOD Index
    FOR    ${item}    IN RANGE    ${2}
        ${index}    Evaluate    ${item} + 1
        ${status}    coam.get_parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-${index}    connection=${connection}
        ${RMOD_SN}    get from dictionary    ${status}    serialNumber
        ${RMOD_idx}    run keyword if    '${RMOD_SN}' == '${expected_RMOD_SN}'    set variable    ${index}
        exit for loop if    '${RMOD_SN}' == '${expected_RMOD_SN}'
    END
    [Return]     ${RMOD_idx}

check value in list
    [Arguments]    ${list}    ${value}
    ${num}    set variable    ${0}
    FOR    ${item}    IN    @{list}
        ${status}    run keyword and return status    should contain    ${item}    ${value}
        ${num}    run keyword if    ${status}    evaluate    ${num}+1     ELSE    set variable    ${num}
        Exit For Loop If    ${status}
    END
    should be equal    ${num}    ${1}

Check NO SFP Fault And Check Status
    [Arguments]    ${faultID}=${4657}
    Check No Expected Fault    fault_id=${faultID}
    Check SFP Status    expected_status=Online

case_teardown
    sleep    15s
    Log To Console    Upload whitelist file
    Upload whitelist file    upload_whitelist_path=${SFPwhitelist_PATH}SFPwhitelist.xml
    SBTS Login
    Reset BTS And Wait Until On Air
    Check No Expected Fault    fault_id=${4657}
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=test_pc
    ssh.send command    command=rm -rf ${SFPwhitelist_PATH}${SFPwhitelist_NAME}    connection=test_pc    timeout=15s
    ssh.send command    command=rm -rf ${SFPwhitelist_PATH}log    connection=test_pc    timeout=15s
    ssh.Disconnect    connection=test_pc
    [Teardown]    run keywords    SBTS Logout    AND    robot_common_operations.Common case Teardown
