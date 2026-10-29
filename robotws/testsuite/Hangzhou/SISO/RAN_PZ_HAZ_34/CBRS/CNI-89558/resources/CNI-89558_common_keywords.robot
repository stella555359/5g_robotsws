*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CNI-89558

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot
Variables    ../TestData/89558_variables.py

*** Variables ***
@{cell_id1}    ${1}
@{cell_id2}    ${2}
*** Keywords ***
CNI-89558 CBRS Suite Setup
    CBRS Suite Setup    feature_scf_flag=${True}
    ${SCF_CNI_89558}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CNI_89558_
    set suite variable  ${SCF_CNI_89558}
    ${SCF_CNI_89558_1CC_20M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CNI_89558_1CC_20M_
    set suite variable  ${SCF_CNI_89558_1CC_20M}
    ${SCF_CNI_89558_2CC_20M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CNI_89558_2CC_20M_
    set suite variable  ${SCF_CNI_89558_2CC_20M}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CNI_89558}

CNI-89558_1_Activation of NR CBRS with two CBSD cells on one AEQM_40MHz+20MHz
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair

Check case 6 relinquish
    [Arguments]    ${grantid_new}    ${grantid_old}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*"grantId":\"${grantid_old}"\.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"grantId": \"${grantid_old}"\.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantid_new}"\.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check case 6 no relinquish
    [Arguments]    ${grantid}
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*"grantId":\"${grantid}"\.*
    [Teardown]    end_to_check

CNI-89558_6_Online_upgrade_combination_from 20MHz+20MHz_to_40MHz+20MHz
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CNI_89558_2CC_20M}
    Activate feature CBRS By Coam
    Sleep    30s
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    selenium login and disable screen lock
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
    ...    filter_param=Desired channel bandwidth    abbr=desiredChBw     new_value=40MHz
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
    ...    filter_param=Bandwidth Part Profile distinguished name 2     abbr=bwpDN2
    ...    new_value=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-40
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
    ...    filter_param=Channel bandwidth     abbr=chBw    new_value=40MHz
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Sleep    180s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell1}[grantId]'=='${grant_info_cell1_new}[grantId]'
    Should be True    '${grant_info_cell2}[grantId]'!='${grant_info_cell2_new}[grantId]'
    Check case 6 relinquish    grantid_new=${grant_info_cell2_new}[grantId]    grantid_old=${grant_info_cell2}[grantId]
    Check case 6 no relinquish    grantid=${grant_info_cell1}[grantId]
    [Return]  selenium logout and close browser

CNI-89558_2_Online_add_one_same_priority_CBRS_cell
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CNI_89558_1CC_20M}
    Activate feature CBRS By Coam
    Sleep    30s
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Online Cell addition    file_path=${SCF_CNI_89558_2CC_20M}
    Sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Sleep    60s
    Online Cell deletion    deletion_cell=2    deletion_cellgrp=1
    Sleep    60s
    Wait until keyword succeeds    3min    30s    verify all cells should be onair
    Online Cell addition    file_path=${SCF_CNI_89558}
    Sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Sleep    60s
    Online Cell deletion    deletion_cell=2    deletion_cellgrp=1
    Sleep    60s
    Wait until keyword succeeds    3min    30s    verify all cells should be onair
    Online Cell addition    file_path=${SCF_CNI_89558_2CC_20M}
    Sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Set qRxLevMin value    value=${-40}    cellid=1
    Set qRxLevMin value    value=${-22}    cellid=2
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2