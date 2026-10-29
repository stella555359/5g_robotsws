*** Settings ***
Force Tags    PY36
Documentation     author: jiang johnny
...                 contact: johnny.1.jiang@nokia-sbell.com
...                 squad group: SG_07
...                 feature : 5GC002426

Resource     Resources/5GC002426_common_keyword.robot
Variables    Resources/variables.py
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    run keywords    Common Suite Setup for COAM
Suite Teardown   run keywords    robot_common_operations.Common Suite Teardown
...  AND   Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
@{ALL_TEST_STATUS}

*** Test Cases ***
[1]5GC002426_D_3_1_01_update_resource_by_DU_when_add_3rd_cell_for_ABIO_FDD
     [Tags]    CRT_TRUNK    CRT_22R2
     [Timeout]    120 min
     [Setup]     Run Keywords
     ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
     ...    2426 Case Setup   open_spark=False
     #step1 env setup
     Modify Venfor file   cellnum=2
#     Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#     ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
     #step2 add cell3-4 online and no cell degrade
     COAM WEBUI Login
     Remove Cells   index=${2}
     selenium_coam.validate_plan
     ${exists}   selenium_coam.start_up_view_window_exists   timeout=120
     Run Keyword If   ${exists}   selenium_coam.close_start_up_view_window
     selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    #sleep  2m
     Wait Until Keyword Succeeds    3m  15s  COAM Check Cell Status
     Add Cells   index=${2}
     Add Cell Groups   index=${2}
     Add Cells   index=${3}
     Add Cell Groups   index=${3}
     Add Cells   index=${4}
     Add Cell Groups   index=${4}
     selenium_coam.validate_plan
     ${exists}   selenium_coam.start_up_view_window_exists   timeout=120
     Run Keyword If   ${exists}   selenium_coam.close_start_up_view_window
     selenium_coam.activate_plan   activate_plan_despite_errors=${True}
     Wait Until Keyword Succeeds    3m  15s  COAM Check Cell Status
     Wait Until Keyword Succeeds   7m   60s   COAM Check All Cells Onair
     Run Keyword And Ignore Error    COAM WEBUI Logout
     #syslog start
     Syslog Capture Start
     #step2 xiaomi 1 attach to cell1 then start vonr or emer then hangup then detach
     Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
     Power UE Precondition
     Run keyword and ignore error   Power UE attach
#     Run keyword and ignore error   hold on an VONR
#     Run keyword and ignore error   Stop the VONR call
     Run keyword and ignore error   Power UE detach
     Run keyword and ignore error   Power UE attach
#     Run keyword and ignore error   hold on an VONR
#     Run keyword and ignore error   Stop the VONR call
     Run keyword and ignore error   Power UE detach
#     Run keyword and ignore error   Power UE attach
#     Run keyword and ignore error   Start a emergency call
#     Run keyword and ignore error   Stop the emergency call
#     Run keyword and ignore error   Power UE detach
     Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
     #syslog stop
     Syslog Capture Stop and Collect
     #syslog print
     ${message}   Run keyword and ignore error   Print Message
     ${message2}   Run keyword and ignore error   Print Message
     ...   message_name=NR users
     ${message3}   Run keyword and ignore error   Print Message
     ...   message_name=drb_count
     #step4 check reource
     Get_Print_Message_of_AreaCapacityPool
     Run Keyword If   '${gnb_release}'=='SBTS24R1' or '${gnb_release}'=='SBTS24R2' or '${gnb_release}'=='SBTS24R3' or '${gnb_release}'=='SBTS25R1'
     ...   Check_occupiedCapacityPool_of_AreaCapacityPool
     ...   ELSE   Check_curUnusableCapacityPool_of_AreaCapacityPool
    Check_guaranteedCapacityCell_of_AreaCapacityPool

     [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover

[1]5GC002426_ACDL
    [Tags]    CRT_TRUNK    CRT_22R2
    [Setup]    robot_common_operations.Common Case Setup
    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
    List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL


*** Keywords ***
Get_Print_Message_of_AreaCapacityPool
    ${nameOfpool}    Return name of pool in syslog
    Set Test Variable   ${nameOfpool}   ${nameOfpool}
#     ${NRuser}   Print Message   message_name=capacityPool: 40${comma} ${nameOfpool}AreaCapacityPool: 36
    ${NRuser}   Print Message   message_name=Pool: 40${comma} ${nameOfpool}AreaCapacityPool: 36
    Set Test Variable   ${NRuser}   ${NRuser}
    ${pcsi}   Print Message   message_name=Pool: 640${comma} ${nameOfpool}AreaCapacityPool: 576
    Set Test Variable  ${pcsi}   ${pcsi}
    ${SR}   Print Message   message_name=Pool: 320${comma} ${nameOfpool}AreaCapacityPool: 288
    Set Test Variable  ${SR}   ${SR}
    ${DRB}   Print Message   message_name=Pool: 80${comma} ${nameOfpool}AreaCapacityPool: 72
    Set Test Variable  ${DRB}   ${DRB}
    ${GBR}   Print Message   message_name=Pool: 20${comma} ${nameOfpool}AreaCapacityPool: 16
    Set Test Variable  ${GBR}   ${GBR}

Check_occupiedCapacityPool_of_AreaCapacityPool
    [Documentation]    CB002426 occupiedCapacityPool for SW gNB_release 25R1 and before
    [Arguments]   ${NRuser}=${NRuser}   ${pcsi}=${pcsi}   ${SR}=${SR}   ${DRB}=${DRB}   ${GBR}=${GBR}
    Log To Console    occupiedCapacityPool for SW gNB_release 25R1 and before
    Should Contain    ${NRuser}   occupiedCapacityPool: 4
    Should Contain    ${pcsi}   occupiedCapacityPool: 64
    Should Contain    ${SR}   occupiedCapacityPool: 32
    Should Contain    ${DRB}   occupiedCapacityPool: 8
#     Should Contain    ${GBR}   occupiedCapacityPool: 4
    Log To Console    'GBR'=${GBR}

Check_curUnusableCapacityPool_of_AreaCapacityPool
    [Documentation]    CB002426 curUnusableCapacityPool for SW gNB_release 25R2 and late
    [Arguments]   ${NRuser}=${NRuser}   ${pcsi}=${pcsi}   ${SR}=${SR}   ${DRB}=${DRB}   ${GBR}=${GBR}
    Log To Console   curUnusableCapacityPool for SW gNB_release 25R2 and late
    Should Contain    ${NRuser}   curUnusableCapacityPool: 3
    Should Contain    ${pcsi}   curUnusableCapacityPool: 48
    Should Contain    ${SR}   curUnusableCapacityPool: 24
    Should Contain    ${DRB}   curUnusableCapacityPool: 6
#     Should Contain    ${GBR}   curUnusableCapacityPool: 3
    Log To Console    'GBR'=${GBR}

Check_guaranteedCapacityCell_of_AreaCapacityPool
    [Documentation]    CB002426 guaranteedCapacityCell
    [Arguments]   ${NRuser}=${NRuser}   ${pcsi}=${pcsi}   ${SR}=${SR}   ${DRB}=${DRB}   ${GBR}=${GBR}
    Log To Console   guaranteedCapacityCell
    Should Contain    ${NRuser}   guaranteedCapacityCell: 1
    Should Contain    ${pcsi}   guaranteedCapacityCell: 16
    Should Contain    ${SR}   guaranteedCapacityCell: 8
    Should Contain    ${DRB}   guaranteedCapacityCell: 2
#     Should Contain    ${GBR}   guaranteedCapacityCell: 1
    Log To Console    'GBR'=${GBR}
