*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB011088

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Resource    ../../resources/cbrs_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/11088_variables.py

*** Variables ***
@{cell_id1}    ${1}
${UTESASip}    ${tl.test_pc.default_ssh_connection_details.addr}

*** Keywords ***
CB011088 Online delete channel
    [Documentation]
    [Arguments]    ${lcellnr}=1    ${index}=4
    selenium login and disable screen lock
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcellnr}/CHANNELGROUP-${index}    timeout=15
    selenium_coam.validate_plan
    selenium_coam.activate_plan		activate_plan_despite_errors=${True}    timeout=180
	[Teardown]    Selenium Logout And Close Browser

CB011088_H_General_SiSo_SuperCell_Reconfiguration__2supercell_one_4subcell_and_other_2subcell_remove_one_subcell_from_4 subcells
    ${SCF_2supcell_4subcell}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_2supcell_4subcell_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_2supcell_4subcell}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTESASip}:4433
    Activate feature CBRS By Coam
    start SAS server    path=${sas_3}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=189
    ...    administrative=Unlocked    operationalState=enabled
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Sleep    30s
    Reset all RMOD via coam
    Sleep    60s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=189
    ...    administrative=Unlocked    operationalState=enabled
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Sleep    30s
    Deactivate feature CBRS By Coam
    Sleep    30s
    Connect to gnb coam via ssl
    CB011088 Online delete channel
    Sleep    300s
    Activate feature CBRS By Coam
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=189
    ...    administrative=Unlocked    operationalState=enabled

CB011088_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2supercell_per_3subcell
    ${SCF_2supcell_3subcell}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_2supcell_3subcell_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_2supcell_3subcell}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTESASip}:4433
    Activate feature CBRS By Coam
    start SAS server    path=${sas_3}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Sleep    30s
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=GNB_OAM
        ...    timeout=60
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single NR cell status    cell_idx=${cell_index}
        ...    operationalState=disabled     usageState=idle    blockState=blocked
    END
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=GNB_OAM
        ...    timeout=60
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single NR cell status    cell_idx=${cell_index}
    END
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    data_transfer_common    tput_self_define=${tput_define_11088}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.95    min_percent=0.85

CB011088_General_SiSo_E2E_system_setup_with_data_transfer_conducted_1supercell_6subcell
    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTESASip}:4433
    Activate feature CBRS By Coam
    start SAS server    path=${sas_3}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Sleep    30s
    coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
    Sleep    60s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    data_transfer_common    tput_self_define=${tput_define_11088}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85
