# @Time    : 2022/2/14 13:53
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CNI-78963.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CNI78963_B_FGCR2801_5GC001116_C

Resource    CNI-78963_keywords.robot
Resource    CNI-78963_precondition.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
...    AND     CI_interface.Common Suite Setup
...    AND    Case Common Precondition
Suite Teardown       robot_common_operations.Common Suite Teardown
Test Setup           MMW5 Common Case Setup
Test Teardown        MMW5 Common Case Teardown

Force Tags    SBTS00    SBTS22R2    SBTS22R3    RAN_5G
...   PY39
...           RAN_5G_TDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AEQY_ENB

*** Variables ***
${TS_LOG_PATH_BASE}    /home/ute/test_results
${TS_CASE_LOG_PATH}    /home/ute/test_results
${DL_TP}    100M
${DL_DURATION}    100
${UL_TP}    100M
${UL_DURATION}    100
${NR_PHY_CELL_IDS}    232
@{BIP_FIELDS}    3gpp.slot    DlData_DciInfoL1sw.dciSize    DlData_DciInfoL1sw.startCce

*** Test Cases ***
CNI78963_B_FGCR2801_5GC001116_C_3_UE_Attach
    [Tags]    case03
    Log    Verified In Case Common Precondition!

CNI78963_B_FGCR2801_5GC001116_C_4_check_DL_UL_schedling_mechanism_on_slot5_and_slot15
    [Tags]    case04
    ${slot4_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"4"}

    ${slot6_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"6"}

    Verify Special Item Value Exist    file_path=${CSV_FILE}    item=3gpp.slot    item_value=5
    ${slot5_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"5"}
    ${slot5_length}    Get Length    ${slot5_dciSize_list}
    Should Be Equal As Integers    ${slot5_length}    2

    Verify Special Item Value Exist    file_path=${CSV_FILE}    item=3gpp.slot    item_value=15
    ${slot15_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"15"}
    ${slot15_length}    Get Length    ${slot15_dciSize_list}
    Should Be Equal As Integers    ${slot15_length}    2

    List Should Contain Value    ${slot5_dciSize_list}    ${slot4_dciSize_list}[0]
    List Should Contain Value    ${slot5_dciSize_list}    ${slot6_dciSize_list}[0]
    List Should Contain Value    ${slot15_dciSize_list}    ${slot4_dciSize_list}[0]
    List Should Contain Value    ${slot15_dciSize_list}    ${slot6_dciSize_list}[0]

CNI78963_B_FGCR2801_5GC001116_C_5_check_UL_schedling_mechanism_on_slot6_and_slot16
    [Tags]    case05
    ${slot4_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"4"}

    Verify Special Item Value Exist    file_path=${CSV_FILE}    item=3gpp.slot    item_value=6
    ${slot6_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"6"}
    ${length}    Get Length    ${slot6_dciSize_list}
    Should Be Equal As Integers    ${length}    1
    Should Not Be Equal    ${slot6_dciSize_list}[0]    ${slot4_dciSize_list}[0]

    Verify Special Item Value Exist    file_path=${CSV_FILE}    item=3gpp.slot    item_value=16
    ${slot16_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"16"}
    ${length}    Get Length    ${slot16_dciSize_list}
    Should Be Equal As Integers    ${length}    1
    Should Not Be Equal    ${slot16_dciSize_list}[0]    ${slot4_dciSize_list}[0]

CNI78963_B_FGCR2801_5GC001116_C_6_check_DL_schedling_mechanism_on_slot6_and_slot16
    [Tags]    case06
    ${slot4_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"4"}

    Verify Special Item Value Exist    file_path=${CSV_FILE}    item=3gpp.slot    item_value=6
    ${slot6_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"6"}
    ${length}    Get Length    ${slot6_dciSize_list}
    Should Be Equal As Integers    ${length}    1
    Should Not Be Equal    ${slot6_dciSize_list}[0]    ${slot4_dciSize_list}[0]

    Verify Special Item Value Exist    file_path=${CSV_FILE}    item=3gpp.slot    item_value=16
    ${slot16_dciSize_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=DlData_DciInfoL1sw.dciSize    precondition={"3gpp.slot":"16"}
    ${length}    Get Length    ${slot16_dciSize_list}
    Should Be Equal As Integers    ${length}    1
    Should Not Be Equal    ${slot16_dciSize_list}[0]    ${slot4_dciSize_list}[0]

CNI78963_B_FGCR2801_5GC001116_C_9_check_DL_schedling_mechanism_on_slot7_and_slot17
    [Tags]    case09
    ${slot_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=3gpp.slot    precondition={"_ws.col.info":"DlData_PdcchSendReqL1sw"}
    Should Not Be Empty    ${slot_list}
    List Should Not Contain Value    ${slot_list}    7
    List Should Not Contain Value    ${slot_list}    17

CNI78963_B_FGCR2801_5GC001116_C_8_check_CSIRS_for_tracking_mechanism_on_slot6_and_slot16
    [Tags]    case08
    Case Common Precondition    filter=dldata_csirssendreql1sw    csv_file=${BIP_FILE_PATH}/case8.csv
    ${slot_list}    Get Special Item Value List With Precondition    file_path=${CSV_FILE}
    ...    item=3gpp.slot    precondition={"_ws.col.info":"DlData_CsiRsSendReqL1sw"}
    Should Not Be Empty    ${slot_list}
    List Should Not Contain Value    ${slot_list}    6
    List Should Not Contain Value    ${slot_list}    16
