# @Time    : 2022/2/14 14:11
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CNI-78963_precondition.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    CNI-78963_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
Case Common Precondition
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=0    ${filter}=dldata_pdcchsendreql1sw    ${csv_file}=${BIP_FILE_PATH}/case4569.csv
    Download MCShark To UTE
    Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5min    20s    COAM Check X2 link status from GNB
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Attach UE And Start UL DL Traffic    ul_tp=${UL_TP}    ul_duration=${UL_DURATION}
    ...    dl_tp=${DL_TP}    dl_duration=${DL_DURATION}
#    Capture BIP Log And Convert To CSV    filter=${filter}
    Set Suite Variable    ${CSV_FILE}    ${csv_file}
    Collect Bip Log And Convert To CSV    cell_ids=${NR_PHY_CELL_IDS}    module_location=primary
    ...    bip_file=${csv_file}
    ...    bip_filter=${filter}    bip_fields=${BIP_FIELDS}
    ${ue_type}    translate power ue type from testline    ${ue_index}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}

Case 8 Precondition
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=0    ${filter}=dldata_csirssendreql1sw
    Download MCShark To UTE
    Attach UE And Start UL DL Traffic    ul_tp=${UL_TP}    ul_duration=${UL_DURATION}
    ...    dl_tp=${DL_TP}    dl_duration=${DL_DURATION}
#    Capture BIP Log And Convert To CSV    filter=${filter}
    Collect Bip Log And Convert To CSV    cell_ids=${NR_PHY_CELL_IDS}    module_location=primary
    ...    bip_file=${BIP_FILE_PATH}/case8.csv
    ...    bip_filter=${filter}    bip_fields=${BIP_FIELDS}
    ${ue_type}    translate power ue type from testline    ${ue_index}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}
