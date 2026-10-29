*** Settings ***

Documentation
...   author: piao
...   contact: yongji.piao@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB007933 in 5G22R2 program

Force Tags    CRT_TRUNK    CRT_22R2
...    PY36

Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Test Timeout

Resource    Resources/CB007933_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot

*** Variables ***
${cell1_index}    1

${host}    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
${username}    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
${password}    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}

${BTS_id}    ${tl.gnbs[${gnb_index}].instance_id}
${UE_TYPE}    askey
${DL_throughput}    450M
${UL_throughput}    100M

*** Test Cases ***
[1]CB007933-B_07_Cell_configuration_setup_AsymBW_with_Guardband_CSI-RS_enhanced_fullband
    [Documentation]    *****************
    ...    Canadian regulatory requirements specify that the n66 downlink bandwidth be divided into 10Mhz channels that
    ...    must be transmitted over the air as 10 Mhz channels. Multiple Canadian operators have adjacent 10Mhz downlink
    ...    channels that they would prefer to use as a single 20Mhz downlink channel. This feature provides the capability
    ...    for the adjacent 10Mhz channels to be offered to the UE as a single 20Mhz channel yet be transmitted over the air
    ...    as two 10Mhz channels. Note that this feature is for FR1 FDD only, i.e. band n66 is FR1 FDD.
    ...    *******************
    [Tags]    CIT_22R2
    [Setup]    Precondition    gscnOrSsPbchArfcn=5462    chbwul=10MHz    chbwdl=20MHz    nrarfcn_dl=436000    nrarfcn_ul=355000
    [Teardown]    Teardown
    Step 1: Confirm The rbAllocation
    Step 2: Start Log Capture And L3 Call SetUp

*** Keywords ***
Step 1: Confirm The rbAllocation
    Confirm The rbAllocation
    Confirm The nrCellType
    Confirm The pucchModeSelect


Step 2: Start Log Capture And L3 Call SetUp
    Run Keyword And Ignore Error     Start Capture BIP Log
    L3 Call SetUp    4G_check=False    dltp=300    ultp=20
	Run Keyword And Ignore Error    stop to capture BIP log And Download
	Check PDSCH NumOfPRB
	Check PDCCH StartCCE
    [Teardown]   run keyword and ignore error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}