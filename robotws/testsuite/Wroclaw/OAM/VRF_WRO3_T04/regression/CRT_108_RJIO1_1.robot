*** Settings ***
Documentation         Suite for trunk for TL108

Resource        ../features/CB013483/TestCases/CB013483.robot
Resource        ../features/CB007962-EF/TestCases/CB007962-F-SyVe.robot
Resource        ../features/5GC001599-G/TestCases/Product_Security_Improvements.robot
Resource        ../features/CB007962-B/Testcases/CB007962-B_bts_security_improvements.robot
Resource        ../features/5GC001599-G/TestCases/CB007962-D.robot
Resource        ../features/5GC002284/TestCases/lldp_suite.robot

Resource        ../common_resources/mantaray/mantaray.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1]CB013483-SR-A_02_ITSAR_Compliance_for_India_Deployment_via_NMS
    [Tags]    13483    T01    trunk    25R2
    [Setup]       Test Setup NMS
    CB013483-SR-A_02_ITSAR_Compliance_for_India_Deployment_via_NMS
    [Teardown]    Test Teardown NMS

[1]CB013483-SR-A_04_ITSAR_Compliance_for_non-India_Deployment_via_NMS
    [Tags]    13483    T02    trunk    25R2
    [Setup]       Test Setup NMS
    CB013483-SR-A_04_ITSAR_Compliance_for_non-India_Deployment_via_NMS
    [Teardown]    Test Teardown NMS

[1]CB010546_CB007962-D-SyVe_files_permission_hardening_ABIQ
    [Tags]    7962-D    T03    trunk
    ...     [1]CB010546_CB007962-D-SyVe_files_permission_hardening_ABIQ
    Files_Permission_Hardening

[1]5GC001599-G_Sensitive_data_is_not_world_readable_ABIP
    [Tags]    1599    T05    trunk    25R2    25R1_MP
	...     [1]5GC001599-G_Sensitive_data_is_not_world_readable_ABIP
    [1]5GC001599-G_Sensitive_data_is_not_world_readable_ASIL

[1]5GC002284_LLDP_Network_discovery_table_verification_ASOE
    [Tags]  2284    T08    trunk    25R2
	...     [1]5GC002284_LLDP_Network_discovery_table_verification_ASOE
    5GC002284_LLDP_Network_discovery_table_verification

[1]CB010546_CB007962-B_Check_if_SSH_user_events_are_visible_in_RUEM_file_in_SLNBI_application_ABIQ
    [Tags]   7962   trunk
    CB007962-B_Check_if_SSH_user_events_are_visible_in_RUEM_file_in_SLNBI_application

[1]CB010546_CB007962-B_Check_if_SSH_user_is_automatically_logged-out_after_reach_set_period_of_inactivity_ABIQ
    [Tags]   7962   trunk
    CB007962-B_Check_if_SSH_user_is_automatically_logged-out_after_reach_set_period_of_inactivity

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Setup NMS
    Add Multiple Alarms to Watchdog List    7316    7317
    Common Gathering Logs for Test Setup
    Download SCF    local_path=${CURDIR}
    Run Keyword and Ignore Error    Delete Object From BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-1/NRREL-2
    Run Keyword and Ignore Error    Delete Object From BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-2/NRREL-1

Test Teardown
    Common Gathering Logs for Test Teardown

Test Teardown NMS
    Common Gathering Logs for Test Teardown
    ${scf_file}=      Set Variable    ${CURDIR}/scf.xml
    Commission SCF    ${scf_file}
    Wait until BTS reach Configured or OnAir state
