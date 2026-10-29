*** Settings ***
Documentation    This is for RJIO E2E Keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_Auto_BTS_site_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/sigspark.py    WITH NAME    spark
#Resource    ../TestData/Rjio_variables.py
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Variables    ../TestData/Rjio_variables.py
Library    ../TestData/Rjio_variables.py
Library    taf.selenium.sbts    WITH NAME    selenium_sbts
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library    taf.nms.netact    WITH NAME    nms_netact
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.l1l2bip        WITH NAME      l1l2bip
Library           taf.collectors.core           WITH NAME      core
Library    taf.ul.mobile.ui.android    WITH NAME    mobile
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.sigspark.SigSpark    WITH NAME    spark
Library    String
Library    DateTime
Library    OperatingSystem
#Library    SSHLibrary
Library     taf.analyzer.pcap    WITH NAME    cap
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/KDDI/resources/KDDI_common_keywords.robot
Resource    Rjio_check_tx_power_keywords.robot

*** Variables ***
@{cell_id61}    ${61}
@{cell_id62}    ${62}
@{cell_id61_62}    ${61}  ${62}
@{cell_id63}    ${63}
@{cell_id72}    ${72}
@{cell_id63_72}    ${63}  ${72}
@{RU_1}    ${1}
@{RU_1_2}    ${1}    ${2}
@{RU_1_2_3}    ${1}    ${2}   ${3}
@{PA_Port_list}    ${5}  ${6}  ${15}  ${16}
@{PA_Port_list_5_6}    ${5}  ${6}
@{PA2_Port_list_1_2}    ${1}  ${2}
@{PA_Port_list_1_2}    ${1}  ${2}
@{PA2_Port_list_13_14}    ${13}  ${14}
@{PA2_Port_list_1_3_4_7}    ${1}  ${3}  ${4}  ${7}
@{PA_Port_list_15}    ${15}
@{PA_Port_list_8}    ${8}
@{PA_Port_list_11_12}    ${11}  ${12}
@{PA_Port_list_13_14}    ${13}  ${14}
@{PA_Port_list_8_10}    ${8}  ${10}
@{PA_Port_list_8_11_12_13_14}    ${8}  ${11}  ${12}  ${13}  ${14}
@{PA_Port_list_8_11_12}    ${8}  ${11}  ${12}
@{PA_Port_list_8_13_14}    ${8}  ${13}  ${14}
@{PA_Port_list_11_12_13_14}    ${11}  ${12}  ${13}  ${14}
@{PA_Port_list_5_6_15}    ${5}  ${6}  ${15}
@{PA_Port_list_1_2_15}    ${1}  ${2}  ${15}
@{PA_Port_list_1_3_4_7}    ${1}  ${3}  ${4}  ${7}
@{PA_Port_list_2}    ${2}


@{AEQZ_cells}    ${61}   ${62}   ${63}
@{AEQZ_index}    ${1}    ${2}    ${3}
@{AEQZ_1}    ${1}
@{cells_62_63_71_72_73}    ${62}   ${63}   ${71}  ${72}   ${73}

${cell_63}    ${63}
${cell_61}    ${61}
${cell_62}    ${62}
${cell_72}    ${72}

${NetAct_22R4_SW}    SBTS22R4_ENB_0000_001421_000000
${NetAct_23R1_SW}    SBTS23R1_ENB_0000_000881_000000
${NetAct_23R2_SW}    SBTS23R2_ENB_0000_000036_000000
${NetAct_23R3_SW}    SBTS23R3_ENB_0000_000212_000000
${NetAct_23R4_SW}    SBTS23R4_ENB_9999_230626_000008

${NetAct_url}    ${tl.nms.https_main_info.addr}
${NetAct_Account}    ${tl.nms.https_main_info.username}
${NetAct_Password}    ${tl.nms.https_main_info.password}
${NetAct_node}    ${tl.nms.ssh_connections_info[0].addr}
${NetAct_ssh_username}    ${tl.nms.ssh_connections_info[0].username}
${NetAct_ssh_password}    ${tl.nms.ssh_connections_info[0].password}

${BTS_ID}    ${tl.gnbs[0].instance_id}

${gNB_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_ssh_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

${UE_SN}    ${tl.ues[0].serial_number}
${CtrlPC_IP}    ${tl.ues[0].ssh_connection_details.addr}
${CtrlPC_username}    ${tl.ues[0].ssh_connection_details.username}
${CtrlPC_password}    ${tl.ues[0].ssh_connection_details.password}

${ute_ip}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_username}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}

${gnb_logs_tool_path}    /tmp/gnb_logs/

${sleep_power_AEQZ}    120
${sleep_power_AEQZ_23R2}    160

${awake_power_AEQZ}    285

${download_path}    /home/ute/NetAct_scf_plan

${xpath_StartPage_showApplications}    //a[@id="linkShowAppFolder"]
${xpath_StartPage_showAllAplications}    //span[text()="Show all applications"]
${xpath_Network_Status_MO_type}    //*[@id="ccMOTypecomboboxField"]
${xpath_Network_Status_Parents_checkbox}    //*[@id="mot:::c"]
${xpath_Network_Status_MODN}    //*[@id="swmTable_networkView_header"]/table/thead/tr[2]/th[3]/div/input
#${xpath_network_status_gNB_checkbox}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[1]/input
${xpath_network_status_gNB_checkbox}    //*[@id="swmTable_networkView_header"]/table/thead/tr[2]/th[1]/span/div[1]/input
${xpath_network_status_select_all}    //*[@id="swmTable_networkView_header"]/table/thead/tr[2]/th[1]/span/div[2]/ul/li[1]/a
${xpath_network_status_NewTask_button}    //*[@id="belowTableActions:btnStartTask"]
${xpath_network_status_NewTask_popwindow_SW_Operations}    //*[@id="include:createWizardForm:opTreeFilter"]
${xpath_network_status_NewTask_popwindow_finish_button}    //*[@id="include:createWizardForm:btnFinish"]
${xpath_network_status_NewTask_popwindow_continue_button}
...    //*[@id="confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk"]
${xpath_Network_Operations_page}    //*[@id="n-banner-collapse"]/div[2]/ul/li[2]/a
${xpath_Network_Operations_MO_type}    //*[@id="TViewCombo:cccomboboxField"]
${xpath_Network_Operations_Task_type_button}    //*[@id="taskTypeFilterId_comboButton_id"]
${xpath_Network_Operations_Task_Apply_button}    //*[@id="TView:taskTypeFilterId_apply_button"]
${xpath_Network_Operations_MODN}    //*[@id="TView:moDn"]
${xpath_Network_Operations_SW_package}    //*[@id="TView:versionId"]
${xpath_Network_Operations_MODN_content}    //*[@id="TView:TTable:0:0:colTasksDN"]
${xpath_Network_Operations_status}          //*[@id="TView:TTable:0:0:colTasksStatus"]

${xpath_Software_Archive_page}    //*[@id="n-banner-collapse"]/div[2]/ul/li[4]/a/span
${xpath_Software_Archive_MO_type}    //*[@id="embTreeFrm:cccomboboxField"]
${xpath_Software_Archive_Add_Software_package}    //*[@id="embTreeFrm:cmdLinkImport"]/div/span
${tshark_path}      /usr/bin/tshark
${gnb_path}    /tmp/
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap or s1ap\"  -T pdml
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_address_msg}    ${tl.enbs[0].oam_ip}
${MAX_LOOP_case69_block_unlock}    50
*** Keywords ***
create deepSleepTimeSchedule list
    [Arguments]    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35
    ${tmp}    create dictionary
    ...    dayOfWeek    ${dayOfWeek}
    ...    startTime    ${startTime}
    ...    windowDuration    ${windowDuration}
    ${tmp}     Create List    ${tmp}
    [Return]    ${tmp}

modify deepSleepTimeSchedule
    [Arguments]    ${dist_name}    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35    ${connection}=GNB_OAM
    ${tmp}    create deepSleepTimeSchedule list    dayOfWeek=${dayOfWeek}    startTime=${startTime}    windowDuration=${windowDuration}
    ${deepSleepTimeSchedule}      create dictionary
    ...    dist_name    ${dist_name}
    ...    parameter    deepSleepTimeSchedule
    ...    value        ${tmp}
    ${parameters}    Create List    ${deepSleepTimeSchedule}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    20s

Open and Config 10766 feature
    [Arguments]    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35    ${connection}=GNB_OAM
    COAM modify parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    modify deepSleepTimeSchedule    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-2    dayOfWeek=${dayOfWeek}
    ...    startTime=${startTime}    windowDuration=${windowDuration}    connection=${connection}   
    modify deepSleepTimeSchedule    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-5    dayOfWeek=${dayOfWeek}
    ...    startTime=${startTime}    windowDuration=${windowDuration}    connection=${connection}  

rjio get RU Power State
    [Arguments]     ${ru_index}=1   ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}    connection=${connection}
	[Return]    ${ru_status['status']['powerState']}

rjio Check RU Power State
    [Arguments]     ${expect_state}=SLEEP    ${ru_index}=1
    ${powerState}    rjio get RU Power State    ru_index=${ru_index}
	Should Be Equal As Strings  ${powerState}  ${expect_state}

create lbpsCellPeriodList list
    [Arguments]    ${lbpsCellDayOfWeek}=Fri    ${lbpsCellDuration}=1440    ${lbpsCellSOMethod}=TX switch off    ${lbpsCellStartTimeHour}=0
    ...    ${lbpsCellStartTimeMinute}=0    ${nrCellId}=1
    ${tmp}    create dictionary
    ...    lbpsCellDayOfWeek    ${lbpsCellDayOfWeek}
    ...    lbpsCellDuration    ${lbpsCellDuration}
    ...    lbpsCellSOMethod    ${lbpsCellSOMethod}
    ...    lbpsCellStartTimeHour    ${lbpsCellStartTimeHour}
    ...    lbpsCellStartTimeMinute    ${lbpsCellStartTimeMinute}
    ...    nrCellId    ${nrCellId}
    [Return]    ${tmp}

Change lbpsCellPeriodList by Coam
    [Arguments]    ${NRPGRP_index}=1    ${nrCellId}=62    ${connection}=GNB_OAM
    ${lbpsCellDayOfWeek}    ${lbpsCellStartTimeHour}    ${lbpsCellStartTimeMinute}    get_lbps_current_week_and_time
    ${tmp1}    create lbpsCellPeriodList list    lbpsCellDayOfWeek=${lbpsCellDayOfWeek}    lbpsCellDuration=25
    ...    lbpsCellSOMethod=TX switch off    lbpsCellStartTimeHour=${lbpsCellStartTimeHour}    lbpsCellStartTimeMinute=${lbpsCellStartTimeMinute}
    ...    nrCellId=${nrCellId}
    ${hour}    ${minute}    get_current_time_after_add_several    hour=${lbpsCellStartTimeHour}    minute=${lbpsCellStartTimeMinute}    several=30
    ${tmp2}    create lbpsCellPeriodList list    lbpsCellDayOfWeek=${lbpsCellDayOfWeek}    lbpsCellDuration=10
    ...    lbpsCellSOMethod=cell switch off    lbpsCellStartTimeHour=${hour}    lbpsCellStartTimeMinute=${minute}
    ...    nrCellId=${nrCellId}
    ${tmp}    Create List    ${tmp1}    ${tmp2}
    ${lbpsCellPeriodList}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter    lbpsCellPeriodList
    ...    value        ${tmp}
    ${parameters}    Create List    ${lbpsCellPeriodList}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}

Rjio_E2E_70_Mixed_Power_Saving_Check
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"!="SBTS23R4"
    ...     Open and Config 10766 feature    dayOfWeek=${lbpsDayOfWeek}    startTime=${startTime}    windowDuration=1440
    Change lbpsPeriodList by Coam    NRPGRP_index=1
    Change lbpsPeriodList by Coam    NRPGRP_index=2
    Change lbpsCellPeriodList by Coam
    Wait Until Keyword Succeeds    8min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=reducedEnergySaving    cellID=62
    Run Keyword If    '${mrbtsID}'=='1139'
    ...    call_RJIO_AEQZ_and_check_energysaving_status    tput_info=${tput_define_reduce}    made35_power=${False}    CRT_flag=${True}
    Run Keyword If    '${mrbtsID}'=='2300'    call_RJIO_AQQJ_and_check_energysaving_status    tput_info=${tput_define_2300_reduce}
    ...    made69_power=${False}
    Wait Until Keyword Succeeds    5min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=71
    Wait Until Keyword Succeeds    5min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=72
    Wait Until Keyword Succeeds    5min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=73
    Wait Until Keyword Succeeds    20min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=62
    Wait Until Keyword Succeeds    10min    30s    rjio Check RU Power State    ru_index=5
    Wait Until Keyword Succeeds    10min    30s    rjio Check RU Power State    ru_index=2
    Change lbpsPeriodList by Coam    lbpsSuspended=suspended    NRPGRP_index=1
    Change lbpsPeriodList by Coam    lbpsSuspended=suspended    NRPGRP_index=2
    Wait Until Keyword Succeeds    10min    30s    rjio Check RU Power State    expect_state=AWAKE    ru_index=2
    Wait Until Keyword Succeeds    10min    30s    rjio Check RU Power State    expect_state=AWAKE    ru_index=5
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Run Keyword If    '${mrbtsID}'=='1139'    call_RJIO_AEQZ_and_check_energysaving_status    tput_info=${tput_define}
    ...    made35_power=${True}    CRT_flag=${True}
    Run Keyword If    '${mrbtsID}'=='2300'    call_RJIO_AQQJ_and_check_energysaving_status    tput_info=${tput_define_S23}
    ...    made69_power=${True}    idx=5
    [Teardown]    Rjio E2E 70 recovery ENV

Rjio E2E 70 recovery ENV
    run keyword and ignore error    Change lbpsPeriodList by Coam    lbpsSuspended=suspended    NRPGRP_index=1
    run keyword and ignore error    Change lbpsPeriodList by Coam    lbpsSuspended=suspended    NRPGRP_index=2

Rjio E2E 69 recovery ENV
    Connect to gnb coam via ssl
    run keyword and ignore error    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-62    connection=GNB_OAM
    run keyword and ignore error    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-73    connection=GNB_OAM

Rjio_E2E_69_RU_Entering_And_Existing_Deep_Sleep_Mode_By_Cell_Block_and_Unblock
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"!="SBTS23R4"
    ...     Open and Config 10766 feature    dayOfWeek=${lbpsDayOfWeek}    startTime=${startTime}    windowDuration=1440
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP_case69_block_unlock}
        Connect to gnb coam via ssl
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-62    connection=GNB_OAM
        sleep    10s
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-73    connection=GNB_OAM
        sleep    10s
        Wait Until Keyword Succeeds    10min    30s    rjio Check RU Power State    ru_index=2
        Wait Until Keyword Succeeds    10min    30s    rjio Check RU Power State    ru_index=5
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-62    connection=GNB_OAM
        sleep    10s
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-73    connection=GNB_OAM
        sleep    10s
        Wait Until Keyword Succeeds    10min    30s    rjio Check RU Power State    expect_state=AWAKE    ru_index=2
        Wait Until Keyword Succeeds    10min    30s    rjio Check RU Power State    expect_state=AWAKE    ru_index=5
        Wait until keyword succeeds    5min    30s    verify all cells should be onair
        check_unexpected_alarms
        csn.reset_cache
    END
    [Teardown]    Rjio E2E 69 recovery ENV
	
RU_lock_unlock_execute
    [Arguments]    ${CRT_flag}
    log to console    ++++ start lock all RUs ++++
    RJIO Sbts Login And Disable Screen Lock
    Close Start Up View    timeout=60
    ${ru_index_list}    Get All RU Index
    FOR    ${RU_idx}    IN    @{ru_index_list}
        Wait Until Keyword Succeeds   3x   30s    selenium_sbts.lock_ru    ru_index=${RU_idx}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
    END
    log to console    ++++ start unlock all RUs ++++
    FOR    ${RU_idx}    IN    @{ru_index_list}
        Wait Until Keyword Succeeds   3x   30s    selenium_sbts.unlock_ru    ru_index=${RU_idx}
        wait until keyword succeeds    20min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
    END
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    Run Keyword If    '${mrbtsID}'=='1139'    call_RJIO_AEQZ    CRT_flag=${CRT_flag}
    Run Keyword If    '${mrbtsID}'=='2300'    call_RJIO_AQQJ
    check hanging resource
    [Teardown]    RJIO Sbts Logout And Close Browser

cell_block_unblock_execute
    [Arguments]    ${CRT_flag}    ${alias}=GNB_OAM
    RJIO Sbts Login And Disable Screen Lock
    ${cell_block_list}    Create List    ${61}  ${62}  ${63}  ${71}  ${72}  ${73}
    log to console    ++++ start block cells++++
    FOR    ${idx}  IN  @{cell_block_list}
        selenium_sbts.block_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${idx}   cell_group_idx=${cellgrp_id}
        Wait For Expect Fault Present    faultId=49    timeout=120
    END
    log to console    ++++ start unblock cells ++++
    FOR    ${idx}  IN  @{cell_block_list}
        selenium_sbts.unblock_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   5 min  10 sec   cell should be unblocked   cell_idx=${idx}    cell_group_idx=${cellgrp_id}
    END
    Wait For Expect Fault To Disappear    faultId=49    timeout=120
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    Run Keyword If    '${mrbtsID}'=='1139'    call_RJIO_AEQZ    CRT_flag=${CRT_flag}
    Run Keyword If    '${mrbtsID}'=='2300'    call_RJIO_AQQJ
    check hanging resource
    [Teardown]    RJIO Sbts Logout And Close Browser

Save Full Snapshot
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${snapshot_zip_file_full}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_full}    coverage=Full    timeout=1500    connection=${connection}
    [Return]    ${snapshot_zip_file_full}

check_unexpected_alarms
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    Run Keyword And Continue On Failure    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist
    ...    file_path=${TS_CASE_LOG_PATH}   allowed_faults=@{ALLOWED_FAULT}
    Run Keyword And Continue On Failure    should be true    ${alarm_status}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_7313}
    &{fault_49}     Create Dictionary     faultId=${49}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_49}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    file_path=${TS_CASE_LOG_PATH}    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    Run Keyword And Continue On Failure    should be true    ${history_alarm_status}
    Run Keyword If    ${cell_status}==${False} or ${alarm_status}==${False} or ${history_alarm_status}==${False}    save full snapshot

collect_RFSW_log_Continuous_check_unexpected_alarms
    [Arguments]   ${snapshot_path}=${TS_CASE_LOG_PATH}
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${log_on_ru}   Get RFSW Log File List On RU    connection=RU_${ru_index}
        csn.Disconnect  connection=RU_${ru_index}
        check_unexpected_alarms
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

General_SiSo_Beamforming_calibration_ASOE
    [Arguments]  ${check_time}=15    ${connection}=GNB_OAM
    log to console    \n***SITE Reset from GUI***
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    connection=${connection}
    sleep    60s
    Wait Until Keyword Succeeds    3min    5s    Connect to gnb coam via ssl
    Check All Components Status ASOE    operation_component=site    gnb_type=${gNb_CuType}
    log to console    sleep ${check_time}min to get beamforming calibration
    sleep  ${check_time}min
    ${ru_index_list}    get all ru index    connection=${connection}
    ${ru_num}    get length    ${ru_index_list}
    ${collect_file_mum}    set variable    ${0}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${status}    run keyword and return status    Collect RF Logs To TestPC    ru_index=${ru_index}    log_name=ru_fault_history_log
        run keyword if    ${status}    run keyword and continue on failure    Check fault history log    log_name=ru_fault_history_log
        ${collect_file_mum}    set variable if    not ${status}    ${collect_file_mum+1}    ${collect_file_mum}
    END
    ${bf_status}    Run Keyword And Return Status    Check RU Beamforming Status    check_count=${True}
    ...    check_ru_connect=${True}    connection=${connection}
    should be true  ${bf_status}
    should be true  ${collect_file_mum}<${ru_num}

Check All Components Status ASOE
    [Arguments]    ${operation_component}=cell   ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    ...    ${smod_checktime}=5min    ${bbmod_checktime}=5min    ${rmod_checktime}=10min    ${x2link_checktime}=5min    ${cell_checktime}=15min
    ...    ${interval}=10s
    ${component_list}    create list    site    smod    bbmod    rmod    cell    no
    ${component_index}    get index from list    ${component_list}    ${operation_component}
    ${smod_checktime}    set variable if    ${component_index}<=${1}   ${smod_checktime}    ${interval}
    ${bbmod_checktime}    set variable if    ${component_index}<=${2}   ${bbmod_checktime}    ${interval}
    ${rmod_checktime}    set variable if    ${component_index}<=${3}     ${rmod_checktime}    ${interval}
    ${cell_checktime}    set variable if    ${component_index}<=${4}     ${cell_checktime}    ${interval}
    ${x2link_checktime}    set variable if    ${component_index}<=${4}     ${x2link_checktime}    ${interval}
    Wait until keyword succeeds    ${smod_checktime}    ${interval}     COAM Check GNB ASIK status     connection=${connection}
    Wait until keyword succeeds    ${rmod_checktime}    ${interval}     COAM Check GNB RU status     connection=${connection}
    Run keyword if    '${gnb_type}'!='SA'
    ...    Wait until keyword succeeds    ${x2link_checktime}    ${interval}     COAM Check X2 link status from GNB    connection=${connection}
    Wait until keyword succeeds    ${cell_checktime}    ${interval}     verify all cells should be onair    connection=${connection}

Perform_SW_rollback
    [Arguments]  ${connection}=GNB_OAM
    log to console    start rollback...
    coam.rollback_software    connection=${connection}
    sleep    2min
    COAM Wait gnb And Cells ready    timeout=30min    gnb_type='${gNb_CuType}'

Perform_SW_rollback_without_check_cell_status
    [Arguments]  ${connection}=GNB_OAM
    log to console    start rollback...
    coam.rollback_software    connection=${connection}
#    sleep    2min
#    COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'

Rjio_Initiate_SFP_Monitoring_from_WebEM_for_RU(dynamic_data)
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_1}=    Check_if_dynamic_parameters_have_a_valid_value_for_ports   links=${links}    dict_of_links=${RMOD}
    Sleep    120s
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_2}=    Check_if_dynamic_parameters_have_a_valid_value_for_ports   links=${links}    dict_of_links=${RMOD}

Check_if_dynamic_parameters_have_a_valid_value_for_ports
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    &{dynamic_port}=    Create Dictionary
    FOR    ${port}    IN    @{list_of_links}
        ${dynamic_direction}=    Check_if_dynamic_parameters_have_a_valid_value_for_directions   links=${links}
        ...    dict_of_links=${dict_of_links}    port=${port}
        Set To Dictionary    ${dynamic_port}    ${port}    ${dynamic_direction}
    END
    [Return]    ${dynamic_port}

Check_if_dynamic_parameters_have_a_valid_value_for_directions
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    &{dynamic_direction}=    Create Dictionary
    @{list_of_dynamic_params}=    Create List
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Run Keyword If   '${direction}'=='source'    Set Suite Variable    ${initial_direction}    initialSource
        Run Keyword If   '${direction}'=='destination'    Set Suite Variable    ${initial_direction}    initialDestination
        Set Suite Variable   ${moduleTemperature}
        ...    ${links["connected"][${port}]["data"]["measurements"]["moduleTemperature"]["${direction}"]}
        Should Be True  20<=${moduleTemperature}<=65
        Set Suite Variable   ${TXSupplyVoltage}
        ...    ${links["connected"][${port}]["data"]["measurements"]["TXSupplyVoltage"]["${direction}"]}
        Should Be True  2000<=${TXSupplyVoltage}<=4500
        Set Suite Variable   ${TXBiasCurrent}
        ...    ${links["connected"][${port}]["data"]["measurements"]["TXBiasCurrent"]["${direction}"][0]}
        Should Be True  0<=${TXBiasCurrent}<=50
        Set Suite Variable   ${TXOpticalPower}
        ...    ${links["connected"][${port}]["data"]["measurements"]["TXOpticalPower"]["${initial_direction}"][0]}
        Should Be True  300<=${TXOpticalPower}<=2000
        Set Suite Variable   ${RXOpticalPower}
        ...    ${links["connected"][${port}]["data"]["measurements"]["RXOpticalPower"]["${initial_direction}"][0]}
        Should Be True    100<=${RXOpticalPower}<=2000
        Append To List    ${list_of_dynamic_params}    ${moduleTemperature}    ${TXSupplyVoltage}
        ...    ${TXBiasCurrent}    ${RXOpticalPower}
        ...    ${TXBiasCurrent}    ${TXOpticalPower}    ${RXOpticalPower}
        Set To Dictionary    ${dynamic_direction}    ${direction}    ${list_of_dynamic_params}
    END
    [Return]    ${dynamic_direction}

Site_reset_with_call
    [Arguments]    ${CRT_flag}
    Perform BTS Site Reset
    Sleep    10s
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Run Keyword If    '${mrbtsID}'=='1139'    call_RJIO_AEQZ    CRT_flag=${CRT_flag}
    Run Keyword If    '${mrbtsID}'=='2300'    call_RJIO_AQQJ
    check hanging resource

TDD_prach_index_190_L3_call
    Run Keyword If    '${mrbtsID}'=='1139'    TDD_prach_index_190_L3_call_AEQZ
    Run Keyword If    '${mrbtsID}'=='2300'    log     AQQJ don't need to execute this case!

TDD_prach_index_190_L3_call_AEQZ
    RJIO Sbts Login And Disable Screen Lock
    ${SCF_PRACH_190}    Replace String    ${Golden_SCF_Path}    .xml    _190_1116_3ms.xml
    COAM Commission with scf file    scf_file_path=${SCF_PRACH_190}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
#    log to console    Control PC:10.71.217.204--MTK_cell63_cell72
    log to console    set PA2 port 1-2 to 0,port 8/11/12/13/14 to 127 and call for TDD cell62
#    Set PA Port Value    value=${127}
#    Set PA Port Value    value=${60}
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_1_2}    attenuator_index=${1}    value=${0}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12_13_14}    attenuator_index=${3}    value=${127}
    log to console    start traffic on PRACH=190_cell62...
    call_RJIO    tput_info=${tput_define}    cell_id_list=${cell_id62}    duration_call=${1800}    duration=${120}
    ...    target_avg_percent=${0.5}    min_percent=${0.4}
    ${hanging_resource_result}    check hanging resource
    [Teardown]    run keywords    RJIO Sbts Logout And Close Browser  AND
    ...           Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}  AND
    ...           Save Full Snapshot

PTP failure between SM and RM reference
    [Arguments]    ${CRT_flag}
    ${sync_old}    get sync info of GNB
    set suite variable  ${sync_old}
    set sync info of GNB
    check sync status change of GNB
    Wait For Expect Fault Present    faultId=${16}    timeout=1200
    Wait For Expect Fault Present    faultId=${4298}    timeout=1200
#    check sync info of RU    status='abnormal'
    check RU sync info    RU_index_list=${AEQZ_index}    status='abnormal'
    set sync info of GNB    syncinput=${sync_old['syncinput']}    acceptclock=${sync_old['acceptclock']}
    Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
    Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
#    check sync info of RU    status='normal'
    Wait until keyword succeeds    5min    10s    check RU sync info    RU_index_list=${AEQZ_index}    status='normal'
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Run Keyword If    '${mrbtsID}'=='1139'    call_RJIO_AEQZ    CRT_flag=${CRT_flag}
    Run Keyword If    '${mrbtsID}'=='2300'    call_RJIO_AQQJ
    check hanging resource
    [Teardown]      Save Full Snapshot

check RU sync info
    [Arguments]    ${RU_index_list}    ${status}
    FOR    ${RU_index}    IN    @{RU_index_list}
        RJIO Sbts Login And Disable Screen Lock
        Close Start Up View    timeout=60
        ${lockstate}    selenium_sbts.get_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1    filter_param=ToP slave lock state
        ...    abbr=lockState
        ${syncstatus}    selenium_sbts.get_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-${RU_index}    filter_param=Clock synchronization status
        ...    abbr=syncStatus
        RJIO Sbts Logout And Close Browser
        Run Keyword If    ${status}=='abnormal'    Run Keywords    should be true    '${lockstate}'=='OutOfLock'    AND
        ...    should be true    '${syncstatus}'=='Freerun'
        Run Keyword If    ${status}=='normal'    Run Keywords    should be true    '${lockstate}'=='Locked'    AND
        ...    should be true    '${syncstatus}'=='Locked'
    END
    [Teardown]    RJIO Sbts Logout And Close Browser

Set PA Port Value
    [Arguments]    ${value}    ${attenuator_index}=${3}
    ${ports_info}    set variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ports}    Get Dictionary Keys    ${ports_info}
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=HBTE
    FOR    ${port}    IN    @{ports}
        attenuator.set_attenuation    port=${port}    value=${value}    attenuator_device=${PA}
    END

Catch_BIP_log_ASOE
    ${timestamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%-H:%M:%S
    ${connection}    csn.connect_to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ${bip_step1}    set variable    cd /usr/bin;./lfs-nw_switch-mirror-tool.sh -S 1010 -f L1_L2_LOKIA_SNF -d 2
    ${bip_step2}    set variable    ./lfs-nw_switch-mirror-tool.sh -L
    ${bip_step3}    set variable    timeout 10 tcpdump -i nac_eth2 -w /tmp/nac_eth2_BIP_${timestamp}.pcap
    log to console    start catch BIP log ${timestamp}......
    csn.execute     command=${bip_step1};${bip_step2};${bip_step3}    connection=${connection}
    csn.disconnect    connection=${connection}
    ${BIP_log_remote_path}    set variable    /tmp/nac_eth2_BIP_${timestamp}.pcap
#    csn.download_file    remote_path=${BIP_log_remote_path}    local_path=${TS_CASE_LOG_PATH}    connection=${connection}

Start Collect BIP log ASOE
    [Arguments]    ${collect_time}=10s
    ${timestamp_BIP}    DateTime.Get Current Date    result_format=%Y-%m-%d-%-H:%M:%S
    Set Test Variable    ${timestamp_BIP}
    ${connection_ssh}    csn.connect_to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Set Test Variable    ${connection_ssh}
    ${bip_step1}    set variable    cd /usr/bin;./lfs-nw_switch-mirror-tool.sh -S 1010 -f L1_L2_LOKIA_SNF -d 2
    ${bip_step2}    set variable    ./lfs-nw_switch-mirror-tool.sh -L
    ${bip_step3}    set variable    tcpdump -i nac_eth2 -w /tmp/nac_eth2_BIP_${timestamp_BIP}.pcap
    log to console    start catch BIP log ${timestamp_BIP}......
    csn.execute     command=${bip_step1};${bip_step2};${bip_step3}    connection=${connection_ssh}
    sleep    ${collect_time}

#Stop Collect BIP log ASOE
#    ${Ctrl_C}    Evaluate    chr(int(3))
#    SSHLibrary.Write Bare    ${Ctrl_C}
#    csn.disconnect    connection=${connection_ssh}
#    ${BIP_log_remote_path}    set variable    /tmp/nac_eth2_BIP_${timestamp_BIP}.pcap

catch_IQ_Data_ASOE
    [Arguments]    ${LOKI-part}    ${ASOE}=SMOD_R-1(ASOE)    ${cell_id1}=63    ${cell_id2}=72    ${subcell_id1}=2    ${subcell_id1}=7
    ...    ${PCI1}=909    ${PCI2}=911
    ${Loki-A}    set variable    A
    ${Loki-B}    set variable    B
    ${Loki-all}    set variable    all
    ${ul_cell63_cell72_index}    create list    [PCI: ${PCI1}][TDD Cell3]NRCELL_R-${cell_id1}: Subcell ${subcell_id1}
    ...    [PCI: ${PCI2}][FDD Cell2]NRCELL_R-${cell_id2}: Subcell ${subcell_id1}
#    ${ul_cell63_index}    create list    [PCI: ${PCI2}][FDD Cell2]NRCELL_R-${cell_id2}: Subcell ${subcell_id1}
    ${LOKI-A_config}    set variable    bsh 1
    ${LOKI-B_config}    set variable    bsh 2
    ${ULconfig_1}    set variable    confmgmtbrowser write NrUlPhy phyEventEnable 16
    ${ULconfig_2}    set variable    confmgmtbrowser write NrUlPhy phyEventFilterSelection 0
    ${ULconfig_3}    set variable    confmgmtbrowser write NrUlPhy phyEventFilterA 15376
    ${ULconfig_4}    set variable    confmgmtbrowser write NrUlPhy phyEventSumFilter 15376
    ${ULconfig_5}    set variable    confmgmtbrowser write NrUlPhy puschGoodSinrThreshold 5
    ${ULconfig_Loki_A}    set variable    ${LOKI-A_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    ${ULconfig_Loki_B}    set variable    ${LOKI-B_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    ${connection}    csn.connect_to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    log to console    start catch UL IQ data......
    log    ${LOKI-A_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    run keyword and ignore error
    ...    run keyword if    '${LOKI-part}'=='${Loki-A}'
    ...    csn.execute    command=${LOKI-A_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    ...    connection=${connection}
    run keyword and ignore error
    ...    run keyword if    '${LOKI-part}'=='${Loki-B}'
    ...    csn.execute    command=${LOKI-B_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    ...    connection=${connection}
    run keyword and ignore error
    ...    run keyword if    '${LOKI-part}'=='all'    run keywords
    ...    csn.execute    command=${ULconfig_Loki_A}    AND
    ...    ${connection1}    csn.connect_to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    AND
    ...    csn.execute    command=${ULconfig_Loki_B}
    log to console   start catch on WebEM
    RJIO Sbts Login And Disable Screen Lock
    selenium_sbts.configure_iq_capture    bbmod=${ASOE}  ul_subcell_index=${ul_cell63_cell72_index}
    ...    dl_subcell_index=${ul_cell63_cell72_index}    enable_capture_on_event=${true}
    selenium_sbts.save_iq_capture    bbmod=${ASOE}   sfn_value=${0}   slot_value=${1}
    csn.Disconnect  connection=${connection1}
    [Teardown]    run keywords    RJIO Sbts Logout And Close Browser  AND  csn.Disconnect  connection=${connection}

commission_KPI_SCF
    ${SCF_KPI}    Replace String    ${Golden_SCF_Path}    .xml    _KPI.xml
    COAM Commission with scf file    scf_file_path=${SCF_KPI}    timeout=600    is_pdl_checking_needed=${True}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

commission_origin_SCF
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    timeout=600    is_pdl_checking_needed=${True}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

KPI_Counter_detach_attach_HO
    [Arguments]   ${ue_index}=0    ${gnb_index}=0    ${du_index}=0    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ...     ${ui_version}=default
    log to console    set PA1 port 13/14 to 0, PA1 port 11/12 to 127....to attach cell62
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${0}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_11_12}    attenuator_index=${3}    value=${127}
    FOR   ${index}   IN RANGE   0    50
        ${start_time}    DateTime.Get Current Date    result_format=timestamp
        log    ${start_time}
#        detach_attach_UE_repeat    tput_self_define=${tput_define}    cell_id=${cell_id72}    loop_times=${10}
        attch_detach_UE   ue_index=${ue_index}    ui_version=M40PUI1.1
        ...    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}    connection=${connection}
        ${end_time}    DateTime.Get Current Date    result_format=timestamp
        log    ${end_time}
        ${elapsed_time}    DateTime.Subtract Date From Date    ${end_time}    ${start_time}
        log    ${elapsed_time}
    END
    HandOver_KPI

detach_attach_UE_repeat
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}
    ...    ${gnb_index}=0    ${du_index}=0    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${cell_list}    run keyword if    ${cell_id}!=${None}    set variable    ${cell_id}
    ...    ELSE    Get All Cell Id    ru_index=${ru_index}
    FOR  ${i}  IN RANGE  ${loop_times}
        ${status}    run keyword and return status    RJIO_attach_detach_UE_cells    tput_info=${tput_self_define}
        ...    cell_list=${cell_list}
        ...    gnb_index=${gnb_index}    du_index=${du_index}
        ...    alias=${alias}    connection=${connection}
        exit for loop if    ${status}==${False}
    END
    run keyword if      not ${status}    FAIL

RJIO_attach_detach_UE_cells
    [Arguments]    ${tput_info}    ${cell_list}    ${gnb_index}=0    ${du_index}=0
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${tput_info_total}    create dictionary
    FOR  ${cell_index}  IN  @{cell_list}
        ${ue_index}    set variable    ${tput_info[${cell_index}]['ue_index']}
        log to console    use ue${ue_index} to make call on cell${cell_index}
        attch_detach_UE   ue_index=${ue_index}
        ...    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}    connection=${connection}
    END

attch_detach_UE
    [Arguments]   ${ue_index}=0    ${gnb_index}=0    ${du_index}=0    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ...     ${ui_version}=default
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${cell_id}    Rjio_get_ue_attached_cell_id    ue_index=${ue_index}    alias=${alias}    connection=${connection}
    run keyword and ignore error    log to console    ue attached to cell ${cell_id}
    run keyword and ignore error    power_ue.verify attach    ue_type=${ue_type}  ue_index=${ue_index}    4G_check=False
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    sleep    10s
    run keyword and ignore error    check hanging resource

data_transfer_KPI
    [Arguments]    ${tput_info}    ${find_btslog}=${None}    ${ru_index}=${None}    ${cell_id}=${None}    ${target_avg_percent}=${None}
    ...    ${min_percent}=${None}    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${duration_call}=${1800}   ${ue_index}=${0}    ${ui_version}=default
    ...    ${tput_from}=tool    ${DL_traffic}=${True}    ${UL_traffic}=${True}    ${check_btslog}=${False}
#    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
#    ...    set variable    ${target_avg_percent}
#    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
#    ...    set variable    ${min_percent}
    ${tput_info_total}    create dictionary
    log to console    use ue${ue_index} to make call on cell${cell_id}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_id}]}
    log to console    tput info for cell ${cell_id} is: ${tput_cell}
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    Set Suite Variable    ${tput_info_total}
    ${tput_info}   set variable    ${tput_cell}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    Wait until keyword succeeds    5min    5s
    ...    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${attached_cell_id}    Rjio_get_ue_attached_cell_id    ue_index=${ue_index}    alias=${alias}    connection=${connection}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${dl_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable     ${tput_spark[0]}   ELSE    set variable   ${dl_tp}
    ${ul_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    ${tput_spark[1]}    ELSE    set variable   ${ul_tp}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    start dl traffic...
    Run Keyword If    ${DL_traffic}==${True}
    ...    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    log to console    start ul traffic...
    Run Keyword If    ${UL_traffic}==${True}
    ...    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}
    Run Keyword If    ${check_btslog}==${True}    Run Keywords    Stop Btslog With Path Check    target_dir=/home/ute/btslog    AND
    ...    check bts log info    find_log=${find_btslog}    AND    RJIO Start Btslog With Path Check
    [Return]    ${attached_cell_id}

data_transfer_KPI_except_attach
    [Arguments]    ${tput_info}    ${find_btslog}=${None}    ${ru_index}=${None}    ${cell_id}=${None}    ${target_avg_percent}=${None}
    ...    ${min_percent}=${None}    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${duration_call}=${1800}   ${ue_index}=${0}    ${ui_version}=default
    ...    ${tput_from}=tool    ${DL_traffic}=${True}    ${UL_traffic}=${True}    ${check_btslog}=${False}
#    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
#    ...    set variable    ${target_avg_percent}
#    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
#    ...    set variable    ${min_percent}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${tput_info_total}    create dictionary
    log to console    use ue${ue_index} to make call on cell${cell_id}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_id}]}
    log to console    tput info for cell ${cell_id} is: ${tput_cell}
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    Set Suite Variable    ${tput_info_total}
    ${tput_info}   set variable    ${tput_cell}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${dl_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable     ${tput_spark[0]}   ELSE    set variable   ${dl_tp}
    ${ul_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    ${tput_spark[1]}    ELSE    set variable   ${ul_tp}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    start dl traffic...
    Run Keyword If    ${DL_traffic}==${True}    Wait until keyword succeeds    10x    5s
    ...    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    log to console    start ul traffic...
    Run Keyword If    ${UL_traffic}==${True}    Wait until keyword succeeds    10x    5s
    ...    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}
    sleep    5s
#    Run Keyword If    ${check_btslog}==${True}    Run Keywords    Stop Btslog With Path Check    target_dir=/home/ute/btslog    AND
#    ...    check bts log info    find_log=${find_btslog}    AND    RJIO Start Btslog With Path Check
#    Run Keyword If    ${check_btslog}==${True}    Run Keywords    check bts log info on control pc    find_log=${find_btslog}    AND
#    ...    clear existing btslogs on contorl pc


collect_check_tput
    [Arguments]    ${duration}=${1200}    ${cell_id}=1    ${ue_index}=0    ${connection}=GNB_OAM
    ...    ${target_avg_percent}=${0.9}    ${min_percent}=${0.85}    ${ue_type}=huawei
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id}    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${duration}    connection=${connection}

detach_UE_stop_traffic
    [Arguments]    ${apn_address}=${None}    ${ue_index}=${0}    ${protocol}=udp
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}    apn_address=${apn_address}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_type=${iperf_type}    protocol=${protocol}    apn_address=${apn_address}
    sleep    10s
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

prepare_aasyslog_process_RJIO
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt

HandOver_KPI
    [Arguments]    ${target_avg_percent}=${0.4}    ${min_percent}=${0.4}
    log to console    +++ set PA 10.71.204.118 port 1/3/4/7 to 30, for call TDD cell61 +++
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_1_3_4_7}    attenuator_index=${3}    value=${30}
    data_transfer_KPI    tput_info=${tput_define_HO}    cell_id=${cell_61}     duration_call=${1800}
    ...    target_avg_percent=${0.8}    min_percent=${0.7}    duration=${1200}    tput_from=self_define
    log to console    start HandOver between TDD cell62 and FDD cell72...
#    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_1_2}    attenuator_index=${1}    value=${60}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8}    attenuator_index=${3}    value=${127}
    FOR   ${index}   IN RANGE   0    45
        log to console    /n**** set PA1 port 13/14 to 0,PA1 port 11/12 to 127 to attach TDD cell 62 ***
        Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${0}
        Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_11_12}    attenuator_index=${3}    value=${127}
        sleep    10s
        log to console    /n**** set PA1 port 13/14 to 127,PA1 port 11/12 to 0 to attach FDD cell 72 ***
        Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${127}
        Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_11_12}    attenuator_index=${3}    value=${0}
#        Set PA Port Value    value=${30}
        sleep    10s
    END
#    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_1_2}    attenuator_index=${1}    value=${0}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12_13_14}    attenuator_index=${3}    value=${127}
    run keyword and ignore error
    ...    collect_check_tput    duration=${1200}    cell_id=${cell_id61}    target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    detach_UE_stop_traffic    ue_index=${2}

Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset
    [Arguments]    ${RU_idx}=${1}    ${connection}=GNB_OAM
#    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
#    Close Start Up View    timeout=60
    wait until keyword succeeds     5min    5s    coam.lock
    ...   dist_name=MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${RU_idx}    timeout=120    connection=${connection}
#    RJIO Sbts Logout And Close Browser
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#    RJIO Sbts Login And Disable Screen Lock
#    Close Start Up View    timeout=60
    wait until keyword succeeds     5min    5s    coam.reset_site    connection=${connection}
#    RJIO Sbts Logout And Close Browser
    sleep    10min
    ${AEQZ1_power_state}    Run Keyword And Return Status    Check RUs Power State    ru_list=${AEQZ_1}
    RU_unblock    RU_idx=${RU_idx}
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    RU_unblock    RU_idx=${RU_idx}    AND
    ...    wait until keyword succeeds    10min    30s    verify all cells should be onair    AND
    ...    RJIO Sbts Logout And Close Browser    AND    Save Full Snapshot

Rjio_E2E_58_Parallel_Operation_RU_Lock_And_Parameter_Change
    [Arguments]    ${RU_idx}=${1}    ${cellid}=61    ${connection}=GNB_OAM
#    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
#    Close Start Up View    timeout=60
#    wait until keyword succeeds     5x    5s    selenium_sbts.lock_ru    ru_index=${RU_idx}
    wait until keyword succeeds     5min    5s    coam.lock
    ...   dist_name=MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${RU_idx}    timeout=120    connection=${connection}
#    RJIO Sbts Logout And Close Browser
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#    check_unexpected_alarms
#    sleep    2min
    log to console    start modify parameter...
    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
    Close Start Up View    timeout=60
    ${qRXLevMin_origin_value}    wait until keyword succeeds     5x    5s    selenium_sbts.get_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}    filter_param=Minimum required RX level in the cell (dBm)
    ...    abbr=qRxLevMin
#    ${qRXLevMin_origin_value}    coam.get_parameters   dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
#    ...    pattern=qRxLevMin   connection=${connection}
    wait until keyword succeeds     5x    5s    selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
    ...    filter_param=Minimum required RX level in the cell (dBm)    abbr=qRxLevMin    new_value=-70
    wait until keyword succeeds     5x    5s    selenium_sbts.validate_plan
    wait until keyword succeeds     5x    5s    selenium_sbts.activate_plan    activate_plan_despite_errors=${True}
    RJIO Sbts Logout And Close Browser
#    check_unexpected_alarms
#    wait until keyword succeeds    10min    30s    verify all cells should be onair
    sleep    2min
    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
    Close Start Up View    timeout=60
    wait until keyword succeeds     5x    5s    selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
    ...    filter_param=Minimum required RX level in the cell (dBm)    abbr=qRxLevMin    new_value=${qRXLevMin_origin_value}
    wait until keyword succeeds     5x    5s    selenium_sbts.validate_plan
    wait until keyword succeeds     5x    5s    selenium_sbts.activate_plan    activate_plan_despite_errors=${True}
    RJIO Sbts Logout And Close Browser
    sleep    2min
    ${AEQZ1_power_state}    Run Keyword And Return Status    Check RUs Power State    ru_list=${AEQZ_1}
    RU_unblock    RU_idx=${RU_idx}
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    RU_unblock    RU_idx=${RU_idx}    AND
    ...    wait until keyword succeeds    10min    30s    verify all cells should be onair    AND
    ...    RJIO Sbts Logout And Close Browser    AND    Save Full Snapshot

Rjio_E2E_59_Parallel_Operation_RU_Lock_And_SW_Upgrade
    [Arguments]    ${RU_idx}=${1}    ${connection}=GNB_OAM
#    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
#    Close Start Up View    timeout=60
    wait until keyword succeeds     5min    5s    coam.lock
    ...   dist_name=MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${RU_idx}    timeout=120    connection=${connection}
#    RJIO Sbts Logout And Close Browser
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
    ${software_info}    coam.get_software_info     connection=${connection}
    ${sw_version}    set variable    ${software_info['Active SW version']}
    ${passive_sw_version}    set variable    ${software_info['Passive SW version']}
    log to console    start upgrade SW by rollback...
    wait until keyword succeeds    15min    20s    Perform_SW_rollback_without_check_cell_status
    sleep    300s
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    wait until keyword succeeds    15min    15s    verify speicific cell is onair    specific_cell_list=${cells_62_63_71_72_73}
#    wait until keyword succeeds    15min    15s    verify all cells should be onair
    Expect Fault Should Absent    faultId=10
    ${software_info}    coam.get_software_info     connection=${connection}
    ${sw_version_tmp}    set variable    ${software_info['Active SW version']}
    ${passive_sw_version_tmp}    set variable    ${software_info['Passive SW version']}
    should be equal    ${sw_version}    ${passive_sw_version_tmp}
    should be equal    ${passive_sw_version}      ${sw_version_tmp}
    ${lmi_status_1}    Run Keyword And Return Status    wait until keyword succeeds     5min    5s    set_lmi-eth_on    RU_index_list=${RU_1_2}
    log to console    ++++ lmi-eth_on 1 is ${lmi_status_1} ++++
    wait until keyword succeeds    15min    20s    Perform_SW_rollback_without_check_cell_status
    sleep    300s
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    wait until keyword succeeds    15min    15s    verify speicific cell is onair    specific_cell_list=${cells_62_63_71_72_73}
#    wait until keyword succeeds    15min    15s    verify all cells should be onair
    ${software_info}    coam.get_software_info     connection=${connection}
    ${sw_version_tmp}    set variable    ${software_info['Active SW version']}
    ${passive_sw_version_tmp}    set variable    ${software_info['Passive SW version']}
    should be equal    ${sw_version}    ${sw_version_tmp}
    should be equal    ${passive_sw_version}      ${passive_sw_version_tmp}
    ${lmi_status_2}    Run Keyword And Return Status    wait until keyword succeeds     5min    5s    set_lmi-eth_on    RU_index_list=${RU_1_2}
    log to console    ++++ lmi-eth_on 2 is ${lmi_status_2} ++++
    ${AEQZ1_power_state}    Run Keyword And Return Status    Check RUs Power State    ru_list=${AEQZ_1}
    RU_unblock    RU_idx=${RU_idx}
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    RU_unblock    RU_idx=${RU_idx}    AND
    ...    wait until keyword succeeds    10min    30s    verify all cells should be onair    AND
    ...    Save Full Snapshot

set_lmi-eth_on
    [Arguments]    ${RU_index_list}
    Connect to Common Unit Master
    FOR    ${RU_index}    IN    @{RU_index_list}
        Connect to RU With Allocated IP    ru_index=${RU_index}    ru_alias=RU_${RU_index}
        ${connection_RU_alias}    Set Variable    RU_${RU_index}
        csn.execute     sudo lmi-eth on    connection=${connection_RU_alias}    timeout=300
        csn.Disconnect  connection=${connection_RU_alias}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

Rjio_E2E_60_Parallel_Operation_RU_Lock_And_RU_reset
    [Arguments]    ${RU_idx}=${1}    ${connection}=GNB_OAM    ${gnb_index}=${0}
#    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
#    Close Start Up View    timeout=60
#    wait until keyword succeeds     5x    5s    selenium_sbts.lock_ru    ru_index=${RU_idx}
#    RJIO Sbts Logout And Close Browser
    wait until keyword succeeds     5min    5s    coam.lock
    ...   dist_name=MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${RU_idx}    timeout=120    connection=${connection}
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#    check_unexpected_alarms
    log to console    start RU reset after RU locked...
#    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
#    Close Start Up View    timeout=60
#    wait until keyword succeeds     5x    5s    selenium_sbts.reset_ru  ru_index=${RU_idx}
    wait until keyword succeeds     5min    5s
    ...    coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${RU_idx}    timeout=300    connection=${connection}
#    RJIO Sbts Logout And Close Browser
    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${RU_idx}   connection=${connection}
#    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
#    Close Start Up View    timeout=60
#    wait until keyword succeeds     5x    5s    selenium_sbts.unlock_ru    ru_index=${RU_idx}
    RU_unblock    RU_idx=${RU_idx}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${gnb_index}    connection=${connection}
    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
    run keyword and ignore error    COAM Teardown gnb connections
    Check RF Startup and Gnb Status    ru_index_list=${RU_1}    gnb_index=${gnb_index}    connection=${connection}
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    RU_unblock    RU_idx=${RU_idx}    AND
    ...    RJIO Sbts Logout And Close Browser    AND    Save Full Snapshot

Rjio_E2E_61_Parallel_Operation_RU_Lock_And_Snapshot
    [Arguments]    ${RU_idx}=${1}    ${connection}=GNB_OAM    ${gnb_index}=${0}
#    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
#    Close Start Up View    timeout=60
#    wait until keyword succeeds     5x    5s    selenium_sbts.lock_ru    ru_index=${RU_idx}
#    RJIO Sbts Logout And Close Browser
    log to console    ++++ start lock RU ++++
    wait until keyword succeeds     5min    5s    coam.lock
    ...   dist_name=MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${RU_idx}    timeout=120    connection=${connection}
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#    check_unexpected_alarms
    ${AEQZ1_power_state1}    Run Keyword And Return Status    Check RUs Power State    ru_list=${AEQZ_1}
    Run Keyword If    ${AEQZ1_power_state1}==${False}    Run Keyword And Ignore Error    check_snapshot_info_compare_RU
    ${AEQZ1_power_state}    Run Keyword And Return Status    Check RUs Power State    ru_list=${AEQZ_1}
    Run Keyword If    ${AEQZ1_power_state}==${True}    save full snapshot
    RU_unblock    RU_idx=${RU_idx}
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    save full snapshot
#    sleep    120s
#    check_snapshot_info_compare_RU
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    RU_unblock    RU_idx=${RU_idx}    AND
    ...    wait until keyword succeeds    10min    30s    verify all cells should be onair    AND
    ...    RJIO Sbts Logout And Close Browser

check_snapshot_info_compare_RU
    [Arguments]    ${ru_index}=${1}    ${is_get_snapshot_via_selenium}=${True}
    log to console    start check snapshot info...
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
    Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
    ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
    csn.Disconnect  connection=RU_${ru_index}
    csn.Disconnect  connection=ASIK Master

Rjio_E2E_62_Parallel_Operation_Cell_Block_And_RU_Lock_Unlock
    [Arguments]    ${cellid}=${61}    ${RU_idx}=${1}
    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
    Close Start Up View    timeout=60
    wait until keyword succeeds     5x    5s    selenium_sbts.block_cell    cell_idx=${cellid}
    RJIO Sbts Logout And Close Browser
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cellid}
    Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${cellid}   cell_group_idx=${cellgrp_id}
    Wait For Expect Fault Present    faultId=49    timeout=120
    log to console    ++++ start lock RU ++++
    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
    Close Start Up View    timeout=60
    wait until keyword succeeds     5x    5s    selenium_sbts.lock_ru    ru_index=${RU_idx}
    RJIO Sbts Logout And Close Browser
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
    ${AEQZ1_power_state}    Run Keyword And Return Status    Check RUs Power State    ru_list=${AEQZ_1}
    RU_unblock    RU_idx=${RU_idx}
    wait until keyword succeeds     5x    5s    RJIO Sbts Login And Disable Screen Lock
    cell_unblock
    RJIO Sbts Logout And Close Browser
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords    run keyword and ignore error    cell_unblock    AND
    ...    RJIO Sbts Logout And Close Browser    AND    Save Full Snapshot

RU_unblock
    [Arguments]    ${RU_idx}=${1}    ${connection}=GNB_OAM
    log to console    ++++ start unlock RU ++++
#    RJIO Sbts Login And Disable Screen Lock
#    Close Start Up View    timeout=60
    wait until keyword succeeds     15min    5s    coam.unlock
    ...   dist_name=MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${RU_idx}    timeout=120    connection=${connection}
    wait until keyword succeeds    20min    20sec     Check RUs Power State    ru_list=${AEQZ_1}    expect_state=AWAKE
    wait until keyword succeeds    20min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#    RJIO Sbts Logout And Close Browser

cell_unblock
    [Arguments]    ${cellid}=${61}
    wait until keyword succeeds     5x    5s    selenium_sbts.unblock_cell    cell_idx=${cellid}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cellid}
    Wait Until Keyword Succeeds   5 min  10 sec   cell should be unblocked   cell_idx=${cellid}    cell_group_idx=${cellgrp_id}

Rjio_E2E_18_Radio_Unit_Restart_After_The_Software_Upgrade(_Minor)
    Perform_SW_rollback
    Perform_SW_rollback
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    General_SiSo_RF_module_reset_from_GUI

Rjio_E2E_25_Data_Call_Dl_Ul_Throughput_Check
    [Arguments]    ${cellID}=${63}
#    log to console    Control PC:10.71.217.204--MTK_cell63_cell72
    log to console    set PA2 port 1-2 to 0,port 8/11/12/13/14 to 127 and call for TDD cell62
#    Set PA Port Value    value=${30}
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_1_2}    attenuator_index=${1}    value=${0}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12_13_14}    attenuator_index=${3}    value=${127}
    log to console    start traffic on cell62...
    ${status1}    run keyword and return status
    ...    data_transfer_common    tput_self_define=${tput_define_single_cell}    cell_id=${cell_id63}    target_avg_percent=${0.8}
    ...    min_percent=${0.7}    loop_times=${1}    duration=${120}    tput_from=self_define
    run keyword if  ${status1}==${False}    Catch_BIP_log_ASOE
    log to console    start block cell63...
    RJIO Sbts Login And Disable Screen Lock
    selenium_sbts.block_cell    cell_idx=${cellID}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cellID}
    Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${cellID}   cell_group_idx=${cellgrp_id}
    Wait For Expect Fault Present    faultId=49    timeout=120
    log to console    set PA2 port 1-2 to 127,port 8/13/14 to 127 and call for FDD cell72
#    Set PA Port Value    value=${30}
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_1_2}    attenuator_index=${1}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_13_14}    attenuator_index=${3}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_11_12}    attenuator_index=${3}    value=${0}
    log to console    start traffic on cell72...
    ${status2}    run keyword and return status
    ...    data_transfer_common    tput_self_define=${tput_define_single_cell}    cell_id=${cell_id72}    target_avg_percent=${0.8}
    ...    min_percent=${0.7}    loop_times=${1}    duration=${120}    tput_from=self_define
    run keyword if  ${status2}==${False}    Catch_BIP_log_ASOE
    [Teardown]    run keywords    cell_unblock    cellid=${cellID}    AND    RJIO Sbts Logout And Close Browser

RJIO Suite Setup
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Suite Setup
    log to console    \n*** RJIO Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${SW_stream}   String.Split String    string=${Active_SW_version}   separator=_    max_split=1
    set suite variable    ${SW_stream}
    run keyword and ignore error    set suite variable    ${abbr_SW_stream}    ${SW_stream}[0]
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    ${BTS_name}    set variable    MRBTS-${mrbtsID}
    set suite variable    ${BTS_name}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if     '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    get eNB active version
    add fault to the allowed fault list    faultId=${7311}
    add fault to the allowed fault list    faultId=${7307}
    add fault to the allowed fault list    faultId=${4293}
    add fault to the allowed history fault list    faultId=${7311}
    set suite variable    ${suite_setup_fail_flag}    ${False}

add fault to the allowed history fault list
    [Arguments]    ${faultId}
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault_dic}
    Set suite Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}

replace_commission_scf_to_current_bts_scf
    [Arguments]    ${connection}    ${file_name}=SCF_SBTS22R4.xml
    log    ${Golden_SCF_Path}
    ${local_scf_path}    set variable    ${TS_CASE_LOG_PATH}/Current_SCF_${BTS_ID}
    create directory    ${local_scf_path}
    log    ${local_scf_path}
    ${current_BTS_scf}    coam.get_current_scf_file    local_dir_path=${local_scf_path}    file_name=${file_name}    connection=${connection}
    log    ${current_BTS_scf}
    replace_scf_file_to_current_bts    current_path_file=${Golden_SCF_Path}    new_file=${current_BTS_scf}

call_RJIO
    [Arguments]    ${tput_info}=${tput_define}    ${cell_id_list}=${cell_id61}   ${duration_call}=${1800}    ${duration}=${120}
    ...    ${target_avg_percent}=${0.85}    ${min_percent}=${0.6}
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${ui_version}    Set Variable    ${tput_info[${cell_id}]['ui_version']}
        ${ue_index}    Set Variable    ${tput_info[${cell_id}]['ue_index']}
        data_transfer_KPI    tput_info=${tput_info}    cell_id=${cell_id}     duration_call=${duration_call}    ue_index=${ue_index}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${duration}    tput_from=self_define
        ...    ui_version=${ui_version}
        collect_check_tput    duration=${duration}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        detach_UE_stop_traffic    ue_index=${ue_index}
    END

UE_attach_specific_cell
    [Arguments]   ${ue_index}=0    ${gnb_index}=0    ${du_index}=0    ${connection}=GNB_OAM    ${alias}=ASIK MASTER
    ...     ${ui_version}=M40PUI1.1
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    Wait until keyword succeeds    10x    5s
    ...    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    run keyword and ignore error    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    ${cell_id}    Rjio_get_ue_attached_cell_id    ue_index=${ue_index}    alias=${alias}    connection=${connection}
    [Return]    ${cell_id}

UE_attach_specific_cell_muduleUE_spark
    [Arguments]   ${ue_index}=0    ${gnb_index}=0    ${du_index}=0    ${connection}=GNB_OAM    ${alias}=ASIK MASTER
    ...    ${ue_type}=huawei_sigspark    ${PowerOn}=${True}    ${PowerOff}=${True}    ${ue_alias}=UE_${ue_index}
    Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${True}
    prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    log to console    **** UE Power-Off ****
    Run Keyword If    ${PowerOff}==${True}    spark.power_off    ue_alias=${ue_alias}
    log to console    **** UE Power-On ****
    Run Keyword If    ${PowerOn}==${True}    spark.power_on    ue_alias=${ue_alias}
#    sleep    5s
#    log to console    **** UE attach ****
#    Wait Until Keyword Succeeds    5min    30s    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${cell_id}    wait until keyword succeeds   1min    5s    Rjio_get_ue_attached_cell_id    ue_index=${ue_index}
    ...    alias=${alias}    connection=${connection}
    [Return]    ${cell_id}

UE_detach_specific_cell_muduleUE_spark
    [Arguments]   ${ue_index}=0    ${ue_type}=huawei_sigspark
    log to console    **** UE detach ****
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}

UE_detach_specific_cell
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

Rjio_get_ue_attached_cell_id
    [Arguments]    ${ue_index}=0    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    Connect to Common Unit Master  alias=${alias}
    connect to gnb coam via ssl    connection=${connection}
    ${time}  get time  epoch
    ${attach_log}    set variable    /tmp/5Grach.txt
    ${local_dir}    set variable    ${SAVE LOG DIRECTORY}/attach_ue_${ue_index}/${time}
    run keyword and ignore error    run keywords    Create directory    ${local_dir}    AND
    ...    csn.download file    remote_path=${attach_log}    local_path=${local_dir}/5Grach.txt   connection=${alias}
    ${cell_id}    run keyword and ignore error    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log
    ...    log_path=${attach_log}    alias=${alias}    connection=${connection}
    log to console    ue attached to cell ${cell_id}
    run keyword and ignore error    csn.Execute    rm ${attach_log}   connection=${alias}
    [Return]    ${cell_id}

Rjio_E2E_ANR_EUTRA
    [Arguments]    ${check_HO}=${False}    ${NRADJECELL_ID}=5000    ${NRCELL_ID}=${62}    ${NRRELE_ID}=256
    log to console    \n******Delete NR-LTE neighbor Object If Exist*****
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${neighbor_NRADJECELLL}    selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJECELL-${NRADJECELL_ID}
    ${neighbor_NRRELE}  selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_ID}/NRRELE-${NRRELE_ID}
    ${neighbor_NRADJECELLL_length}    Get Length    ${neighbor_NRADJECELLL}
    ${neighbor_NRRELE_length}    Get Length    ${neighbor_NRRELE}
    Run Keyword If    ${neighbor_NRADJECELLL_length}!=${0}    selenium_sbts.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJECELL-${NRADJECELL_ID}
    Run Keyword If    ${neighbor_NRRELE_length}!=${0}    selenium_sbts.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_ID}/NRRELE-${NRRELE_ID}
    Run Keyword If    ${neighbor_NRADJECELLL_length}!=${0} or ${neighbor_NRRELE_length}!=${0}    selenium_sbts.validate_plan
    Run Keyword If    ${neighbor_NRADJECELLL_length}!=${0} or ${neighbor_NRRELE_length}!=${0}    selenium_sbts.activate_plan
    ...    activate_plan_despite_errors=${True}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    RJIO Sbts Logout And Close Browser
    FOR   ${index}   IN RANGE   0    2
        Run Keyword If    '${mrbtsID}'=='1139'    ANR_EUTRA_HO_AEQZ_1139    flag_call=${False}
        Run Keyword If    '${mrbtsID}'=='2300'    ANR_EUTRA_HO_AQQJ_2300    flag_call=${False}    ue_index=4
    END
    sleep    3min    wait NR-LTE neighbor create
    log to console    \n***check NR-LTE neighbor if created***
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${neighbor_NRADJECELLL}    selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJECELL-${NRADJECELL_ID}
    ${neighbor_NRRELE}  selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_ID}/NRRELE-${NRRELE_ID}
    ${neighbor_NRADJECELLL_length}    Get Length    ${neighbor_NRADJECELLL}
    ${neighbor_NRRELE_length}    Get Length    ${neighbor_NRRELE}
    ${NRADJECELL_creat_status}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${neighbor_NRADJECELLL_length}    ${0}
    ${NRRELEL_creat_status}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${neighbor_NRRELE_length}    ${0}
    Run Keyword If    ${check_HO}==${True}    Run Keywords
    ...    log to console    +++ check HO from TDD908 to LTE cell81 +++    AND
#    Run Keyword If    '${mrbtsID}'=='2300'    ANR_EUTRA_HO_AQQJ_2300    flag_call=${True}    ue_index=4
    ...    log to console    begin to call...    AND
    ...    Run Keyword If    '${mrbtsID}'=='1139'    ANR_EUTRA_HO_AEQZ_1139    flag_call=${True}
    [Return]    ${NRADJECELL_creat_status}    ${NRRELEL_creat_status}
    [Teardown]    Run Keywords    RJIO Sbts Logout And Close Browser    AND    save full snapshot

Get qRxLevMin of cell
    [Arguments]    ${filter_param}=Minimum required RX level in the cell (dBm)    ${abbr}=qRxLevMin
    ...    ${cell61}=${61}    ${cell63}=${63}    ${cell71}=${71}    ${cell72}=${72}    ${cell73}=${73}
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    log to console    \n***** start get qRxLevMin *****
    ${cell61_origin_qRxLevMin}    selenium_sbts.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell61}
    ...    filter_param=${filter_param}    abbr=${abbr}
    ${cell63_origin_qRxLevMin}    selenium_sbts.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell63}
    ...    filter_param=${filter_param}    abbr=${abbr}
    ${cell71_origin_qRxLevMin}    selenium_sbts.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell71}
    ...    filter_param=${filter_param}    abbr=${abbr}
    ${cell72_origin_qRxLevMin}    selenium_sbts.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell72}
    ...    filter_param=${filter_param}    abbr=${abbr}
    ${cell73_origin_qRxLevMin}    selenium_sbts.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell73}
    ...    filter_param=${filter_param}    abbr=${abbr}
    [Return]    ${cell61_origin_qRxLevMin}    ${cell63_origin_qRxLevMin}    ${cell71_origin_qRxLevMin}    ${cell72_origin_qRxLevMin}
    ...    ${cell73_origin_qRxLevMin}
    [Teardown]    RJIO Sbts Logout And Close Browser

Set qRxLevMin of cell
    [Arguments]    ${cell61_qRxLevMin}    ${cell63_qRxLevMin}    ${cell71_qRxLevMin}    ${cell72_qRxLevMin}    ${cell73_qRxLevMin}
    ...    ${filter_param}=Minimum required RX level in the cell (dBm)    ${abbr}=qRxLevMin
    ...    ${cell61}=${61}    ${cell63}=${63}    ${cell71}=${71}    ${cell72}=${72}    ${cell73}=${73}
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    log to console    \n***** start set qRxLevMin *****
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell61}    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${cell61_qRxLevMin}
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell63}    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${cell63_qRxLevMin}
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell71}    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${cell71_qRxLevMin}
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell72}    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${cell72_qRxLevMin}
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell73}    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${cell73_qRxLevMin}
    selenium_sbts.validate_plan
    wait until keyword succeeds     5x    5s    selenium_sbts.activate_plan
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    RJIO Sbts Logout And Close Browser

get NRREL0 for cell72
    [Arguments]   ${cell72}=${72}    ${NRREL_ID}=${0}
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    log to console    \n***** start get NRREL-0 for cell72 *****
    ${NRREL_0_cell72}    selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell72}/NRREL-${NRREL_ID}
    ${NRREL_0_length}    Get Length    ${NRREL_0_cell72}
    [Return]    ${NRREL_0_length}
    [Teardown]    RJIO Sbts Logout And Close Browser

Rjio_E2E_ANR_for_NR_Neighbor
    [Arguments]    ${check_HO}=${False}    ${NRADJNRCELL}=${12288}    ${NRCELL}=${61}    ${NRREL}=${256}    ${ue_index}=${0}
    log to console    \n******Delete NR-NR neighbor Object If Exist*****
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${neighbor_NRADJNRCELL}    selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJNRCELL-${NRADJNRCELL}
    ${neighbor_NRREL}  selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL}/NRREL-${NRREL}
    ${neighbor_NRADJNRCELL_length}    Get Length    ${neighbor_NRADJNRCELL}
    ${neighbor_NRREL_length}    Get Length    ${neighbor_NRREL}
    Run Keyword If    ${neighbor_NRADJNRCELL_length}!=${0}    selenium_sbts.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJNRCELL-${NRADJNRCELL}
    Run Keyword If    ${neighbor_NRREL_length}!=${0}    selenium_sbts.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL}/NRREL-${NRREL}
    Run Keyword If    ${neighbor_NRADJNRCELL_length}!=${0} or ${neighbor_NRREL_length}!=${0}    selenium_sbts.validate_plan
    Run Keyword If    ${neighbor_NRADJNRCELL_length}!=${0} or ${neighbor_NRREL_length}!=${0}    selenium_sbts.activate_plan
    ...    activate_plan_despite_errors=${True}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    RJIO Sbts Logout And Close Browser
    FOR   ${index}   IN RANGE   0    2
        Run Keyword If    '${mrbtsID}'=='1139'    NR_NR_ANR_HO_AEQZ_1139    ue_index=${ue_index}
        Run Keyword If    '${mrbtsID}'=='2300'    NR_NR_ANR_HO_AQQJ_2300    flag_call=${False}    ue_index=4
    END
    sleep    3min    wait NR-NR neighbor create
    log to console    \n***check NR-NR neighbor if created***
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${neighbor_NRADJNRCELL}    selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJNRCELL-${NRADJNRCELL}
    ${neighbor_NRREL}  selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL}/NRREL-${NRREL}
    ${neighbor_NRADJNRCELL_length}    Get Length    ${neighbor_NRADJNRCELL}
    ${neighbor_NRREL_length}    Get Length    ${neighbor_NRREL}
    ${NRADJNRCELL_creat_status}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${neighbor_NRADJNRCELL_length}    ${0}
    ${NRREL_creat_status}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${neighbor_NRREL_length}    ${0}
    Run Keyword If   ${check_HO}==${True}    Run Keywords
    ...    log to console    +++ check HO from TDD908 to NR cell500 +++    AND
#    Run Keyword If    '${mrbtsID}'=='2300'    NR_NR_ANR_HO_AQQJ_2300    flag_call=${True}    ue_index=4
    ...    Run Keyword If    '${mrbtsID}'=='1139'    NR_NR_ANR_HO_AEQZ_1139    flag_call=${True}    ue_index=${ue_index}
    [Return]    ${NRADJNRCELL_creat_status}    ${NRREL_creat_status}
    [Teardown]    Run Keywords    RJIO Sbts Logout And Close Browser    AND    save full snapshot

Selenium Close StartUp View
    [Arguments]    ${timeout}=120
    ${close_flag}    selenium_sbts.start_up_view_window_exists    timeout=120
    run keyword if    ${close_flag}    selenium_sbts.close_start_up_view_window

RJIO Sbts Login And Disable Screen Lock
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${version}=SBTS23R3
    ...            ${browser}=Firefox
    selenium_sbts.enable_virtual_display
    selenium_sbts.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    ...                    browser=${browser}
    selenium_sbts.disable_message_box
    selenium_sbts.disable_screen_lock

RJIO Sbts Logout And Close Browser
    Run Keyword And Ignore Error    Selenium Close StartUp View    timeout=5
    Run Keyword And Ignore Error    selenium_sbts.logout
    Run Keyword And Ignore Error    selenium_sbts.disable_virtual_display
    Run Keyword And Ignore Error    selenium_sbts.close_browser

NetAct_SW_Upgrade_and_rollback
    [Arguments]     ${Download}=Download    ${Activation}=Activation    ${Rollback}=Rollback
    Run Keyword If    '${abbr_SW_stream}'=='SBTS22R4'    Set Suite Variable    ${upgrade_SW}    ${NetAct_22R4_SW}
    Run Keyword If    '${abbr_SW_stream}'=='SBTS23R1'    Set Suite Variable    ${upgrade_SW}    ${NetAct_23R1_SW}
    Run Keyword If    '${abbr_SW_stream}'=='SBTS23R2'    Set Suite Variable    ${upgrade_SW}    ${NetAct_23R2_SW}
    Run Keyword If    '${abbr_SW_stream}'=='SBTS23R3'    Set Suite Variable    ${upgrade_SW}    ${NetAct_23R3_SW}
    Run Keyword If    '${abbr_SW_stream}'=='SBTS23R4'    Set Suite Variable    ${upgrade_SW}    ${NetAct_23R4_SW}
    NetAct SW Operation    upgrade_SW=${upgrade_SW}    operation=${Download}
    ${download_status}    NetAct check operation status    operation=${Download}    upgrade_SW=${upgrade_SW}
    Should Contain Any    ${download_status}    Successful    Timeout-Success
    NetAct SW Operation    upgrade_SW=${upgrade_SW}    operation=${Activation}
    ${activation_status}    NetAct check operation status    operation=${Activation}    upgrade_SW=${upgrade_SW}
    Should Contain Any    ${activation_status}    Successful    Timeout-Success
    Wait until keyword succeeds    60min    30s    verify all cells should be onair
    ${active_SW}    ${passive_SW}    get_activate_and_passive_sw    gnb_ip=${gNB_IP}  username=${gNB_ssh_username}  password=${gNB_ssh_password}
    log to console    Active SW build is ${active_SW}, Passive SW build is ${passive_SW} after upgrade
    should be equal    ${active_SW}    ${upgrade_SW}
    should be equal    ${passive_SW}    ${Active_SW_version}
    NetAct SW rollback
#    ${rollback_status}    NetAct check operation status    operation=${Rollback}    upgrade_SW=${upgrade_SW}
    sleep    7min
    Wait until keyword succeeds    60min    30s    verify all cells should be onair
    ${rollback_active_SW}    ${rollback_passive_SW}    get_activate_and_passive_sw    gnb_ip=${gNB_IP}  username=${gNB_ssh_username}
    ...    password=${gNB_ssh_password}
    log to console    Active SW build is ${rollback_active_SW}, Passive SW build is ${rollback_passive_SW} after rollback
    should be equal    ${rollback_active_SW}    ${Active_SW_version}
    should be equal    ${rollback_passive_SW}    ${upgrade_SW}
    [Teardown]    NetAct Logout    close_page=Software Manager

NetAct SW Operation
    [Arguments]     ${upgrade_SW}    ${operation}=Download
    ...    ${showAll}=${False}
    log to console    Start ${operation} SW in NetAct...
    # login start page
    Set Suite Variable    ${Download_dir}    ${SAVE LOG DIRECTORY}
    selenium_netact.set_download_dir    download_dir=${Download_dir}
    NetAct Login
    # switch to All Aplications page
    NetAct StartPage Show All Aplications    showAll=${showAll}
    sleep    5s
    selenium_netact.open_configuration_software_manager
#     select gNB
    NetAct input value    Xpath=${xpath_Network_Status_MO_type}    input_value=MRBTS
    NetAct select checkBox    Xpath=${xpath_Network_Status_Parents_checkbox}
    NetAct input value    Xpath=${xpath_Network_Status_MODN}    input_value=${BTS_name}
    wait until keyword succeeds     5min    10s    Wait checkbox visible    Xpath=${xpath_network_status_gNB_checkbox}
    NetAct select checkBox    Xpath=${xpath_network_status_gNB_checkbox}
    # select operation in new task
    wait until keyword succeeds     5x    5s    NetAct Click Button    Xpath=${xpath_network_status_select_all}
    sleep    5s
    wait until keyword succeeds     5x    5s    NetAct Click Button    Xpath=${xpath_network_status_NewTask_button}
    NetAct input value    Xpath=${xpath_network_status_NewTask_popwindow_SW_Operations}    input_value=${operation}
    # select SW
    ${Provision_Xpath}    NetAct replace and select    Xpath_origin=//*[@title="Version ID: ${upgrade_SW}"]    attr_text=id
    ...    replace_origin=swpackName    replace_dest=radioSelectSWPackage_:0
    selenium_netact.select_radio    radio_xpath=//*[@id="${Provision_Xpath}"]
    NetAct Click Button    Xpath=${xpath_network_status_NewTask_popwindow_finish_button}  # finish button
    sleep    10s
    Run Keyword If    '${Operation}'=='Provision' or '${Operation}'=='Activation'    NetAct Click Button
    ...    Xpath=${xpath_network_status_NewTask_popwindow_continue_button}
    sleep    5s
    [Teardown]    NetAct Logout    close_page=Software Manager

NetAct SW rollback
    [Arguments]    ${operation}=Rollback    ${showAll}=${False}
    log to console    Start trigger SW rollback via NetAct...
    NetAct Login
    NetAct StartPage Show All Aplications    showAll=${showAll}
    selenium_netact.open_configuration_software_manager
    # select gNB
    NetAct input value    Xpath=${xpath_Network_Status_MO_type}    input_value=MRBTS
    NetAct select checkBox    Xpath=${xpath_Network_Status_Parents_checkbox}
    NetAct input value    Xpath=${xpath_Network_Status_MODN}    input_value=${BTS_name}
    wait until keyword succeeds     5min    10s    Wait checkbox visible    Xpath=${xpath_network_status_gNB_checkbox}
    NetAct select checkBox    Xpath=${xpath_network_status_gNB_checkbox}
    # select operation in new task
    wait until keyword succeeds     5x    5s    NetAct Click Button    Xpath=${xpath_network_status_select_all}
    sleep    5s
    wait until keyword succeeds     5x    5s        NetAct Click Button    Xpath=${xpath_network_status_NewTask_button}
    NetAct input value    Xpath=${xpath_network_status_NewTask_popwindow_SW_Operations}    input_value=${operation}
    NetAct Click Button    Xpath=${xpath_network_status_NewTask_popwindow_finish_button}  # finish button
    sleep    10s
    NetAct Click Button    Xpath=${xpath_network_status_NewTask_popwindow_continue_button}
    sleep    5s
    [Teardown]    NetAct Logout    close_page=Software Manager

NetAct StartPage Show All Aplications
    [Arguments]    ${showAll}=${True}
    Run Keyword If    ${showAll}    Show All Aplications

Show All Aplications
    selenium_netact.Wait For Visibility    elem_xpath=${xpath_StartPage_showApplications}
    selenium_netact.click_button    button_xpath=${xpath_StartPage_showApplications}
    ${show_all_mode}    Run Keyword and Return Status    selenium_netact.Wait For Visibility    elem_xpath=${xpath_StartPage_showAllAplications}
    Run Keyword If    ${show_all_mode}    selenium_netact.click_button    button_xpath=${xpath_StartPage_showAllAplications}
    log to console    Open NetAct Start Page and Show All Aplications Succeeds!

NetAct input value
    [Arguments]    ${Xpath}    ${input_value}
    sleep    5s
    wait until keyword succeeds     3x    5s    selenium_netact.Wait For Visibility    elem_xpath=${Xpath}
    wait until keyword succeeds     3x    30s    selenium_netact.write_value_and_enter    input_xpath=${Xpath}    value=${input_value}

NetAct select checkBox
    [Arguments]    ${Xpath}
    wait until keyword succeeds    3x    10s    selenium_netact.Wait For Visibility    elem_xpath=${Xpath}
    wait until keyword succeeds     3x    5s    selenium_netact.select_checkbox    checkbox_xpath=${Xpath}

NetAct Click Button
    [Arguments]    ${Xpath}
    sleep    5s
    ${status}    run keyword and return status
    ...    wait until keyword succeeds    3x    5s    selenium_netact.wait_for_enable    elem_xpath=${Xpath}     timeout=60
    run keyword if  not ${status}    run keywords    NetAct Catch Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    ...    AND    FAIL    [ERROR] click button failed!
    ${status_click}    run keyword and return status
    ...    wait until keyword succeeds    3x    30s    selenium_netact.click_button    button_xpath=${Xpath}
    run keyword if  not ${status_click}    run keywords    NetAct Catch Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    ...    AND    FAIL    [ERROR] click button failed!

Wait checkbox visible
    [Arguments]    ${Xpath}
    ${visible_status}    Run Keyword And Return Status    selenium_netact.Wait For Visibility    elem_xpath=${Xpath}
    run keyword if    '${visible_status}' == 'False'    selenium_netact.execute_script    script_cmd=location.reload();
    selenium_netact.Wait For Visibility    elem_xpath=${Xpath}

NetAct Login
    Run Keyword And Ignore Error    selenium_netact.enable_virtual_display
    Wait Until Keyword Succeeds   10m   1m   selenium_netact.Login   url=${NetAct_url}    username=${NetAct_Account}
    ...    password=${NetAct_Password}

NetAct Logout
    [Arguments]    ${close_page}=${None}
    Run Keyword And Ignore Error    selenium_netact.close_page    page_name=${close_page}
    Run Keyword And Ignore Error    selenium_netact.logout
    Run Keyword And Ignore Error    selenium_netact.disable_virtual_display

NetAct replace and select
    [Arguments]    ${Xpath_origin}    ${attr_text}    ${replace_origin}    ${replace_dest}
    sleep   5s
    wait until keyword succeeds     3x    10s    selenium_netact.wait_for_visibility    elem_xpath=${Xpath_origin}
    ${attr_content}    selenium_netact.execute_script    script_cmd=return arguments[0].parentNode.getAttribute('${attr_text}');
    ...     elem_xpath=${Xpath_origin}
    ${attr_content}    run keyword if   '${attr_content}' == 'None'    selenium_netact.execute_script
    ...   script_cmd=return arguments[0].getAttribute('${attr_text}');   elem_xpath=${Xpath_origin}
    ...   ELSE    set variable     ${attr_content}
    ${xpath_dest}    Replace String	  ${attr_content} 	${replace_origin}	 ${replace_dest}
    [Return]     ${xpath_dest}

NetAct check operation status
    [Arguments]    ${operation}    ${upgrade_SW}    ${times}=${60}
    log to console    Start check ${operation} status in NetAct
    NetAct Login
    NetAct StartPage Show All Aplications    showAll=${False}
    selenium_netact.open_configuration_software_manager
    NetAct Click Button    Xpath=${xpath_Network_Operations_page}
    selenium_netact.wait_for_visibility    elem_xpath=${xpath_Network_Operations_MO_type}
    NetAct input value    Xpath=${xpath_Network_Operations_MO_type}    input_value=MRBTS
    NetAct Click Button    Xpath=${xpath_Network_Operations_Task_type_button}
    FOR    ${index}    IN RANGE    ${times}
        ${type}    wait until keyword succeeds     5x    5s    selenium_netact.get_elem_text
        ...    elem_xpath=//*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[${index}+1]/td/label
        Run Keyword If    '${type}'=='${SPACE}${operation}'    Run Keywords    NetAct select checkBox
        ...    Xpath=//*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[${index}+1]/td/label
        ...    AND    NetAct Click Button    Xpath=${xpath_Network_Operations_Task_Apply_button}
        Exit For Loop If    '${type}'=='${SPACE}${operation}'
    END
    NetAct input value    Xpath=${xpath_Network_Operations_MODN}    input_value=${BTS_name}
    NetAct input value    Xpath=${xpath_Network_Operations_SW_package}    input_value=${upgrade_SW}
    ${MODN_name_content}    wait until keyword succeeds  5x   5s   selenium_netact.get_elem_text
    ...    elem_xpath=${xpath_Network_Operations_MODN_content}
    should be equal    ${MODN_name_content}    	.../${BTS_name}
    FOR    ${index}   IN RANGE    ${times}
#        ${operation_type}    run keyword and return status    should not contain any    ${operation}   Download   Provision   Activation
#        Exit For Loop If    ${operation_type}
        ${opetation_status}    wait until keyword succeeds  5x   5s   selenium_netact.get_elem_text    elem_xpath=${xpath_Network_Operations_status}
        ${if_status}    run keyword and return status   should not contain    ${opetation_status}    %
        ${if_empty}    run keyword and return status    should not be empty    ${opetation_status}
        Exit For Loop If    ${if_status} and ${if_empty}
        sleep    1min
    END
    [Return]    ${opetation_status}
    [Teardown]    NetAct Logout

NetAct Catch Screenshot by xpath
    [Arguments]   ${xpath}    ${dir}=${OUTPUT_DIR}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${mz_lib} =    Get Library Instance    selenium_netact
    ${element} =    Call Method    ${mz_lib._driver}    find_element_by_xpath    ${xpath}
    Call Method    ${element}    screenshot    ${dir}/Screen_${curr_data}.png

Rjio_E2E_11_Parameter_Modification_Netact
    NetAct commission scf
#    [Arguments]    ${filter_param}=Minimum required RX level in the cell (dBm)    ${abbr}=qRxLevMin
#    ...    ${cell61}=${61}
#    RJIO Sbts Login And Disable Screen Lock
#    Run Keyword And Ignore Error    Close Start Up View    timeout=120
#    log to console    \n***** start get qRxLevMin *****
#    ${cell61_origin_qRxLevMin}    selenium_sbts.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell61}
#    ...    filter_param=${filter_param}    abbr=${abbr}
#    RJIO Sbts Logout And Close Browser
#    NetAct modify parameter via CM Editor
#    [Teardown]    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}

NetAct commission scf
    [Arguments]  ${alias}=Gansu    ${dist_name}=PLMN-PLMN/MRBTS-${mrbtsID}    ${plan_scf_name}=netact_1139_plan
    ...    ${actual_plan}=1139_netact_actual_plan.xml
    nms_netact.add_node    service_name=cmwas    hostname=${NetAct_node}    username=${NetAct_ssh_username}
    ...    password=${NetAct_ssh_password}    alias=${alias}
    nms_netact.add_web_url    web_url=${NetAct_url}    username=${NetAct_Account}    password=${NetAct_Password}    alias=${alias}
    ${parameters_1}=   Create Dictionary    -lteHwContentInUse=${TRUE}    -sranBtsHwContentInUse=${TRUE}
    log to console    ++++ CM operatons Upload plan... ++++
    nms_netact.upload_configuration    dist_names=${dist_name}    parameters=${parameters_1}    alias=${alias}
    log to console    ++++ CM operations Export plan... ++++
    nms_netact.export_configuration    file_name=${actual_plan}    local_dir=${download_path}    dist_names=${dist_name}
    ...    alias=${alias}
    log to console    ++++ CM operations Delete plan... ++++
    Run keyword and ignore error    nms_netact.delete_plan    plan_name=${plan_scf_name}    alias=${alias}
    log to console    ++++ CM operations Import plan... ++++
    nms_netact.import_configuration    file_name=${actual_plan}    local_dir=${download_path}    plan_name=${plan_scf_name}
    ...    alias=${alias}
    log to console    ++++ CM operations Provision plan... ++++
    nms_netact.provision_plan    plan_name=${plan_scf_name}    dist_names=${dist_name}    backup_plan_name=${BTS_ID}_netact_backup
    ...    create_backup_plan=${False}    provisioning_operation=preactivate    alias=${alias}
    log to console    ++++ CM operations Validate plan... ++++
    nms_netact.validate_plan    plan_name=${plan_scf_name}    dist_names=${dist_name}    alias=${alias}
    log to console    ++++ CM operations Activate plan... ++++
    nms_netact.activate_preactivated_plan    plan_name=${plan_scf_name}    dist_names=${dist_name}    alias=${alias}
    nms_netact.delete_node    service_name=cmwas    alias=${alias}
    nms_netact.clean_all    alias=${alias}
    Wait until keyword succeeds    15min    30s    verify all cells should be onair

NetAct modify parameter via CM Editor
    [Arguments]    ${alias}=Gansu    ${cell61}=${61}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    log to console    Add node
    nms_netact.add_node    service_name=cmwas    hostname=${NetAct_node}    username=${NetAct_ssh_username}
    ...    password=${NetAct_ssh_password}    alias=${alias}
    nms_netact.add_web_url    web_url=${NetAct_url}    username=${NetAct_Account}    password=${NetAct_Password}    alias=${alias}

    ${MO_id}    Set Variable    PLMN-PLMN/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell61}
    ${plan_conf}    nms_netact.create_plan_configuration    name=NetAct new plan_${timestamp}
    ...    description=NetAct new plan_${timestamp}    alias=${alias}
    ${meta_class}     ${meta_version}    ${parameters}=    NetAct get actual configuration MO data    MO_ID=${MO_id}
#    ${structure_1}    Create Dictionary     qRxLevMin=-65
#    ${list_structure}    Create List    ${structure_1}
    ${managed_object}=    nms_netact.create_managed_object    plan=${plan_conf}    meta_class=${meta_class}    meta_version=${meta_version}
    ...    mo_id=${MO_id}    alias=${alias}
#    ${managed_object}=    nms_netact.get_managed_object    configuration=${plan_conf}    mo_id=${MO_id}    alias=${alias}
    nms_netact.edit_managed_object    managed_object=${managed_object}    operation=UPDATE    qRxLevMin=${-65}
    log    cell_${cell61} qRxLevMin: ${managed_object.parameters['qRxLevMin']}    console=${True}
#    nms_netact.delete_managed_object    managed_object=${managed_object}
    [Teardown]    nms_netact.delete_plan_configuration    plan=${plan_conf}

NetAct get actual configuration MO data
    [Arguments]    ${MO_ID}    ${alias}=Gansu
    ${actual_conf}    nms_netact.get_actual_configuration    alias=${alias}
    ${managed_object}    nms_netact.get_managed_object    configuration=${actual_conf}    mo_id=${MO_ID}    alias=${alias}
    log    Managed Object: ${managed_object}    console=${True}
    log    Meta Class: ${managed_object.meta_class}    console=${True}
    log    Meta Version: ${managed_object.meta_version}    console=${True}
    log    Parameters: ${managed_object.parameters}    console=${True}
    [Return]    ${managed_object.meta_class}    ${managed_object.meta_version}    ${managed_object.parameters}

Rjio_E2E_69_RU_Entering_Deep_Sleep_Mode_During_Low_Traffic_Periods_IWK_5GC000431_CB009925
    #COAM modify parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-0   parameter_name=lbpsSOMethod    value=cell switch off
    FOR    ${RU_index}    IN    @{AEQZ_index}
        COAM modify parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${RU_index}    parameter_name=energySavingMode    value=DEEPSLEEP
    END
    sleep    1min
    operate 5GC000431 feature flag    feature_flag=true
    set lbpstime by selenium    lbpsDuration=720
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    15min    30s    check cells energy saving status    cell_list=${AEQZ_cells}    expected_status=energySaving
    Wait Until Keyword Succeeds    15min    30s    Check RUs Power State    ru_list=${AEQZ_index}
    check power after RU enter deep sleep    interval=15min
    FOR    ${RU_index}    IN    @{AEQZ_index}
        COAM modify parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${RU_index}    parameter_name=energySavingMode    value=NORMAL
    END
    sleep    1min
    operate 5GC000431 feature flag    feature_flag=false
    sleep    30s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    run keyword and ignore error    operate 5GC000431 feature flag    feature_flag=false

Rjio_E2E_70_RU_Exiting_Deep_Sleep_Mode_Due_to_at_least_one_carrier_enabling_on_RU_IWK_5GC000431_CB009925
    [Arguments]    ${CRT_flag}=${False}
    log to console    set PA2 port 1-2 to 0,port 8/11/12/13/14 to 127 and call for TDD cell62
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_1_2}    attenuator_index=${1}    value=${0}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12_13_14}    attenuator_index=${3}    value=${127}
    log to console    start traffic on cell62...
    Run Keyword If    '${mrbtsID}'=='1139'    call_RJIO_AEQZ    CRT_flag=${True}
    Run Keyword If    '${mrbtsID}'=='2300'    call_RJIO_AQQJ
    ${avg_old}    get_average_list    output_info_list=${output}
    ${ul_avg_old}    set variable    ${avg_old}[0]
    ${dl_avg_old}    set variable    ${avg_old}[1]
    #COAM modify parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-0   parameter_name=lbpsSOMethod    value=cell switch off
    FOR    ${RU_index}    IN    @{AEQZ_index}
        COAM modify parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${RU_index}    parameter_name=energySavingMode    value=DEEPSLEEP
    END
    sleep    1min
    operate 5GC000431 feature flag    feature_flag=true
    set lbpstime by selenium    lbpsDuration=720
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    sleep    1min
    Wait Until Keyword Succeeds    15min    30s    check cells energy saving status    cell_list=${AEQZ_cells}    expected_status=energySaving
    Wait Until Keyword Succeeds    15min    30s    Check RUs Power State    ru_list=${AEQZ_index}    expect_state=SLEEP
    sleep    30s
    operate 5GC000431 feature flag    feature_flag=false
    sleep    1min
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    15min    30s    Check RUs Power State    ru_list=${AEQZ_index}    expect_state=AWAKE
    check power after RU exit sleep mode    interval=1min    RU_list=${AEQZ_index}
    Run Keyword If    '${mrbtsID}'=='1139'    call_RJIO_AEQZ    CRT_flag=${True}
    Run Keyword If    '${mrbtsID}'=='2300'    call_RJIO_AQQJ
    ${avg_new}    get_average_list    output_info_list=${output}
    ${ul_avg_new}    set variable    ${avg_new}[0]
    ${dl_avg_new}    set variable    ${avg_new}[1]
    ${ul_D_value}    Get the diff    num1=${ul_avg_new}    num2=${ul_avg_old}
    ${dl_D_value}    Get the diff    num1=${dl_avg_new}    num2=${dl_avg_old}
    ${tmp_ul}    Evaluate    ${ul_avg_old}*0.1
    ${tmp_dl}    Evaluate    ${dl_avg_old}*0.1
    should be true   ${ul_D_value} < ${tmp_ul}
    should be true   ${dl_D_value} < ${tmp_dl}
    sleep    30s
    FOR    ${RU_index}    IN    @{AEQZ_index}
        COAM modify parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${RU_index}    parameter_name=energySavingMode    value=NORMAL
    END
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    run keyword and ignore error    operate 5GC000431 feature flag    feature_flag=false

Selenium set parameter and verify cell onair
    [Arguments]    ${dist_name}    ${filter_param}    ${abbr}    ${new_value}
    wait until keyword succeeds     3x    5s    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    selenium_sbts.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    abbr=${abbr}    new_value=${new_value}
    selenium_sbts.validate_plan
    wait until keyword succeeds     5x    5s    selenium_sbts.activate_plan
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    RJIO Sbts Logout And Close Browser

COAM modify parameter
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    coam.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=GNB_OAM

operate 5GC000431 feature flag
    [Arguments]    ${feature_flag}
    Selenium set parameter and verify cell onair    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}    filter_param=Activate NR load-based power saving
    ...   abbr=actNrLBPowerSaving    new_value=${feature_flag}

set lbpstime by selenium
    [Arguments]    ${lbpsDuration}=60    ${NRPGRP}=0
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_current_time
    log to console    start set lbps time duration:${lbpsDuration}, day:${lbpsDayOfWeek}, hour:${lbpsStartTimeHour}, min:${lbpsStartTimeMinute}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving day of week    abbr=lbpsDayOfWeek    new_value=${lbpsDayOfWeek}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving duration    abbr=lbpsDuration    new_value=${lbpsDuration}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving start time hour    abbr=lbpsStartTimeHour    new_value=${lbpsStartTimeHour}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving start time minute    abbr=lbpsStartTimeMinute    new_value=${lbpsStartTimeMinute}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    RJIO Sbts Logout And Close Browser

check cells energy saving status
    [Arguments]      ${cell_list}    ${expected_status}=energySaving    ${connection}=GNB_OAM
    FOR    ${cell_index}    IN    @{cell_list}
        ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}    connection=${connection}
        ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
        log    cell_${cell_index}: ${energysaving_status}
        should be equal    ${energysaving_status}    ${expected_status}
    END

Check RUs Power State
    [Arguments]     ${ru_list}   ${connection}=GNB_OAM    ${expect_state}=SLEEP
    FOR    ${ru_index}    IN    @{ru_list}
        &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}    connection=${connection}
        ${RU_Power_State}    Set Variable    ${ru_status['status']['powerState']}
        Should Be Equal As Strings    ${RU_Power_State}    ${expect_state}
    END

check power after RU enter deep sleep
    [Arguments]    ${interval}
    ${wait_time}    get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    sleep    ${interval}
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${counter_3C4}    Get PM Counter via Webem    counter_id=M40003C4    interval=${interval}
    ${counter_3C4_value}    Evaluate    ${counter_3C4}/1000
    ${sleep_power_AEQZ_final}    Set Variable If    '${SW_stream}[0]'=='SBTS23R2'    ${sleep_power_AEQZ_23R2}    ${sleep_power_AEQZ}
    ${AEQZ_D_value}    Get the diff    num1=${counter_3C4_value}    num2=${sleep_power_AEQZ_final}
    ${tmp_AEQZ}    Evaluate    ${sleep_power_AEQZ_final}*0.1
    should be true    ${AEQZ_D_value} < ${tmp_AEQZ}
    [Teardown]    RJIO Sbts Logout And Close Browser

check power after RU exit sleep mode
    [Arguments]    ${interval}    ${RU_list}
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${content}    selenium_sbts.get_real_time_measurements    object_names=RMOD
    FOR    ${RU_index}   IN    @{RU_list}
        ${value_dict}    Get From Dictionary    ${content}    RMOD/RMOD_R-${RU_index}
        ${time_list}    Convert To List    ${value_dict}
        log    ${time_list}
        ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[0]}
        ${current_time}   Get time from bbmod
        ${end_time}    robot.libraries.DateTime.add_time_to_date    ${last_time}    ${interval}
        ${diff}    robot.libraries.DateTime.subtract_date_from_date    ${end_time}    ${current_time}
        ${diff1}    robot.libraries.DateTime.subtract_time_from_time    ${diff}    ${interval}
        should be true    ${diff1}<0
        ${wait_time}=  evaluate  ${diff1} + 60
        ${power_voltage}    get_from_dictionary   ${value_dict}    ${last_time}
        ${Voltage}    get_from_dictionary    ${power_voltage}    Voltage
        ${Power}    get_from_dictionary    ${power_voltage}    Power
        should be true    ${Power} > ${awake_power_AEQZ}
    END
    [Teardown]    RJIO Sbts Logout And Close Browser

get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${time}

RJIO E2E Voice call via EPS fallback
#    [Arguments]    ${cell_id}=${62}

#    Get gnb logs from gnb logs tool
#    UE_attach_specific_cell
#    ${attach_cell_status}    Run Keyword And Return Status    should contain    ${attached_cell}    ${cell_id}
#    Run Keyword and Ignore Error    should contain    ${attached_cell}    ${cell_id}
#    wait until keyword succeeds   1min    5s    check android mobile network type    network_type=NR
#    Run Keyword If    ${network_NR_status}==${False}    Save Full Snapshot
    # step2: Use Mate40 Pro to call 6688
    #
    make call 6688
    Run Keyword and Ignore Error    check android voice call status
    Run Keyword and Ignore Error    check android mobile network type    network_type=LTE
    sleep    5s
    # step3: Hang up and UE come back to NR
    hang up call
    sleep    5s
#    Run Keyword and Ignore Error    wait until keyword succeeds   1min    5s    check android mobile network type    network_type=NR
    # step4: Turn on and off flight mode
    Run Keyword and Ignore Error    UE_detach_specific_cell
#    Capture Bip and TTI trace via gnb_logs tool    duration=180
    log to console    ue attach...
    UE_attach_specific_cell
    log to console    stop bts log...
    Stop Btslog With Path Check    target_dir=/home/ute/btslog
    log to console    check error in btslog...
    ${check_status}    check bts log info
    Run Keyword If    ${check_status}!=0    Run Keywords   sleep   6min    AND    move logs to secific folder    AND
    ...    Save Full Snapshot    snapshot_path=/tmp/a_logs
    log to console    restart btslog...
    Start Btslog With Path Check

#    Get gnb logs from gnb logs tool
#    UE_attach_specific_cell
#    Run Keyword and Ignore Error    should contain    ${attach_cell}    ${cell_id}
#    wait until keyword succeeds   1min    5s    check android mobile network type    network_type=NR
#    Run Keyword If    ${network_NR}==${False}    Save Full Snapshot
#    Run Keyword and Ignore Error    UE_detach_specific_cell
    [Teardown]    Run Keyword and Ignore Error    hang up call

make call 6688
    [Arguments]    ${ue_index}=${0}    ${phone_number}=6688    ${sleep_time}=30s
    ${alias}    set variable    cygwin${ue_index}
    csn.connect_to    hostname=${CtrlPC_IP}    username=${CtrlPC_username}    password=${CtrlPC_password}    alias=${alias}
    sleep    5s
    #####Press the Home button to open the screen#####
    Run Keyword and Ignore Error    csn.send_command    command=adb -s ${UE_SN} shell input keyevent 82    connection=${alias}
    sleep    2s
    #####Swipe up to unlock the phone#####
    Run Keyword and Ignore Error    csn.send_command    command=adb -s ${UE_SN} shell input swipe 500 2050 500 800    connection=${alias}
    sleep    2s
    log to console    make 6688 call...
    csn.send_command    command=adb -s ${UE_SN} shell am start -a android.intent.action.CALL tel:+${phone_number}    connection=${alias}
    sleep    ${sleep_time}
    csn.disconnect    connection=${alias}

hang up call
    [Arguments]    ${ue_index}=${0}
    ${alias}    set variable    cygwin${ue_index}
    csn.connect_to    hostname=${CtrlPC_IP}    username=${CtrlPC_username}    password=${CtrlPC_password}    alias=${alias}
    sleep    5s
    csn.send_command    command=adb -s ${UE_SN} shell input keyevent 6    connection=${alias}

check android voice call status
    [Arguments]    ${ue_index}=${0}    ${mCallState_status}=${2}
    ${alias}    set variable    cpc_${ue_index}
    csn.connect_to    hostname=${CtrlPC_IP}    username=${CtrlPC_username}    password=${CtrlPC_password}    alias=${alias}
    sleep    3s
    ### check voice call enable ###
    log to console    mCallState: 0: Phone standby; 1: The call is not answerd; 2: The phone's line is busy
    csn.send_command    command=adb -s ${UE_SN} shell dumpsys telephony.registry |grep mCallState   connection=${alias}
    sleep    2s
    ${result}    csn.read output    connection=${alias}
    sleep    1s
    csn.disconnect    connection=${alias}
    should contain    ${result}    mCallState=${mCallState_status}

check android mobile network type
    [Arguments]    ${ue_index}=${0}    ${network_type}=NR
    ${alias}    set variable    CPC_${${ue_index}}
    csn.connect_to    hostname=${CtrlPC_IP}    username=${CtrlPC_username}    password=${CtrlPC_password}    alias=${alias}
    sleep    5s
    csn.send_command    command=adb -s ${UE_SN} shell getprop gsm.network.type    connection=${alias}
    sleep    2s
    ${network_type_result}    csn.read output    connection=${alias}
    sleep    2s
    csn.disconnect    connection=${alias}
    should contain    ${network_type_result}    ${network_type}

catch BIP log and snapshot
    Run Keyword and Ignore Error    Catch_BIP_log_ASOE
    Save Full Snapshot

catch bts log
    RJIO Start Btslog With Path Check
    sleep    10s
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}

RJIO Start Btslog With Path Check
    [Documentation]    Need to set suite variable for stopping btslog in teardown
    FOR   ${btslog_dir}     IN     @{btslog_dirs}
          ${file_exist}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${btslog_dir}/btslog
          run keyword if      '${file_exist}'=='True'       run keywords       Start Btslog Collect
          ...    btslog_dir=${btslog_dir}    AND    Exit For Loop
    END
    Set Suite Variable    ${btslog_dir}
    run keyword if    '${btslog_dir}'=='none'    Log    Can't find btslog.    WARN

PowerSaving BWP switch
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${start_traffic_btslog}="switched to bwpType=DEDICATED"
    ...     ${stop_traffic_btslog}="switched to bwpType=POWER_SAVING"
    kill python process on control pc    ue_index=${ue_index}
    reset_actRemoteSyslogTransmission
    #modify remote syslog server
    ${ui_version}    Set Variable If    '${mrbtsID}'=='1139'    M40PUI1.1    default
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Run Keyword If    '${mrbtsID}'=='1139'    Run Keywords
    ...    log to console    +++ set PA2 port13-14 to 0,port 8/11/12 to 127 and call for AEQZ TDD cell62 +++    AND
    ...    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${0}    AND
    ...    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12}    attenuator_index=${3}    value=${127}
    Run Keyword If    '${mrbtsID}'=='2300'    set matrix PA for TDD cell
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    run keyword and ignore error    Wait until keyword succeeds    5min    5s
    ...    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${attached_cell_id}    Rjio_get_ue_attached_cell_id    ue_index=${ue_index}    alias=ASIK_MASTER    connection=GNB_OAM
    FOR    ${i}    IN RANGE    0    2
        clear existing btslogs on contorl pc
        ${match_start_before}    check bts log info on control pc    find_log=${start_traffic_btslog}
        ${match_stop_before}     check bts log info on control pc    find_log=${stop_traffic_btslog}
        data_transfer_KPI_except_attach    tput_info=${tput_define_BWP}    cell_id=${cell_62}
        ...    duration_call=${600}    target_avg_percent=${0.4}    min_percent=${0.4}    duration=${20}    tput_from=self_define
        ...    DL_traffic=${True}    UL_traffic=${False}    ue_index=${ue_index}    ui_version=${ui_version}
        ${match_start_after}    check bts log info on control pc    find_log=${start_traffic_btslog}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
        ...    protocol=${protocol}
        sleep   3s
        ${match_stop_after}    check bts log info on control pc    find_log=${stop_traffic_btslog}
#        run keyword if    ${i}!=${1}    clear existing btslogs on contorl pc
#        Stop Btslog With Path Check    target_dir=/home/ute/btslog
#        check bts log info    find_log=${stop_traffic_btslog}
#        RJIO Start Btslog With Path Check
         should be true    ${match_start_after} > ${match_start_before}
         should be true    ${match_stop_after} > ${match_stop_before}
    END
#    [Teardown]    run keywords    run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}    AND
#    ...    run keyword and ignore error    modify remote syslog server    ip=${tl.ues[0].ssh_connection_details.addr}
    [Teardown]    run keywords    run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}    AND
    ...    run keyword and ignore error    kill python process on control pc    ue_index=${ue_index}

RJIO 960 Suite Setup
    log to console    \n*** RJIO 960 Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    ${connection}    set variable    GNB_OAM
    set suite variable      ${gNb_CuType}    SA
    set suite variable    ${SUITE_LOG_PATH}    /tmp/[1]PowerSaving BWP switch
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    set suite variable    ${suite_setup_fail_flag}    ${False}

RJIO 960 Test Setup
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Case Setup
    log to console    \n***SISO Coam Test Setup***
    log to console    gNB CU type:${gNb_CuType}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}

Capture Bip and TTI trace via gnb_logs tool
    [Arguments]    ${bbmod_slots}=1
    ...            ${duration}=2
    ...            ${gnb_logs_script_path}=${gnb_logs_tool_path}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
#    ...            ${log_type}=BIP
    log to console    --- start gnb_logs collection---
#    ${log_type_to_command_mapping}    Create Dictionary    TTI=T    BIP=b   m=m
    ${gnb_ip}    Set Variable    ${gNB_IP}
#    ${gnb_ip}    Set Variable    10.101.51.12
    csn.Connect to    hostname=${ute_ip}
    ...               username=${ute_username}
    ...               password=${ute_password}
    ...               alias=ute
    csn.send command    command=cd ${gnb_logs_script_path}&&rm *bip_tti.zip   connection=ute
    sleep    2s
#    ${start_capture_command}     Catenate    ./gnb_logs ${gnb_ip} -c${bbmod_slots} -t -b ${duration}
    ${start_capture_command}     Catenate    ./gnb_logs ${gnb_ip} -c${bbmod_slots} -t -b
    csn.send command    command=cd ${gnb_logs_script_path}&&./${start_capture_command}   connection=ute
#    ${output_status}    Run Keyword And Return Status    csn.read output until    finished    timeout=600    connection=ute
#    Run Keyword If    '${output_status}' == 'False'    Run Keywords
#    ...    upgrade_gnb_logs    cd_command=cd ${gnb_logs_script_path}    ex_command=./${start_capture_command}
#    ...    pc_ip=${ute_ip}    pc_name=${ute_username}    pc_pwd=${ute_password}    AND
#    ...    csn.send command    command=./${start_capture_command}   connection=ute    AND
#    ...    csn.read output until    finished    timeout=1200    connection=ute
    sleep    60s
    simulate_keyboard_operation    key_code=108
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ute

# ${gnb_ip}=${gNB_IP}
Get gnb logs from gnb logs tool
    [Arguments]  ${tti_script_path}=${gnb_logs_tool_path}    ${gnb_ip}=${gNB_IP}    ${epc_log_path}=/tmp/allien_gnblogs
    ...    ${tti_logs_rename}=gnblogs_bip_tti
    log to console    get tti trace to Case_Logs file...
    csn.Connect to    hostname=${ute_ip}    username=${ute_username}    password=${ute_password}    alias=ute
    csn.send command    command=cd ${tti_script_path}&&ls -l | grep ${gnb_ip} |awk '{print $9}'  connection=ute
    ${tti_logs_zip}=    csn.Read Output    connection=ute
    ${len}    Get Length    ${tti_logs_zip}
    wait until keyword succeeds  10min   5s    should be true    ${len} > 0
    @{tti_logs_file}    String.split string    string=${tti_logs_zip}    separator=.zip
    csn.send command    command=cd ${tti_script_path}&&unzip ${tti_logs_file}[0].zip&&rm ${tti_logs_file}[0].zip    connection=ute
    sleep    3s
    csn.send command    command=cd ${tti_script_path}&&mv ${tti_script_path}/${tti_logs_file}[0] ${epc_log_path}${tti_logs_rename}
    ...    connection=ute
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ute

move logs to secific folder
    csn.Connect to    hostname=${ute_ip}    username=${ute_username}    password=${ute_password}    alias=ute
    csn.send command    command=cd ${gnb_logs_tool_path}&&mv *.zip /tmp/a_logs
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ute

check bts log info
    [Arguments]    ${find_log}="RRCReconfigurationComplete timeout"
    csn.Connect to    hostname=${ute_ip}    username=${ute_username}    password=${ute_password}    alias=ute
    csn.send command    ls -l /tmp/btslog2|grep LOG| awk '{print $9}'    connection=ute
    ${bts_log_name}    csn.read output    connection=ute
    Should Not Be Empty    ${bts_log_name}
    ${bts_log_name}    set variable    ${bts_log_name.strip().split('\n')[-1]}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${bts_log_name_new}    Replace String    ${bts_log_name}    .LOG    _${timestamp}.LOG
    csn.send command    mv /tmp/btslog2/${bts_log_name} /tmp/btslog2/${bts_log_name_new}    connection=ute
    sleep    2s
    csn.send command    cat /tmp/btslog2/${bts_log_name_new}|grep ${find_log}|wc -l    connection=ute
    ${match_result}    csn.read output    connection=ute
    ${match_result}    convert to integer    ${match_result}
    Run Keyword If    ${match_result}==0    Run Keywords    csn.send command    mv /tmp/btslog2/${bts_log_name_new} /tmp/a_logs/${bts_log_name_new}
    ...    connection=ute    AND    Fail    can't find log ${find_log} from ${bts_log_name_new}!
    [Teardown]    Run Keywords    csn.send command    rm -rf /tmp/btslog2/*    connection=ute    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ute
    [Return]    ${match_result}

Download SW and loop uograde_rollback for knife test
    [Arguments]    ${download_SW_path}=/tmp/Download_SW    ${SW_release}=SBTS22R4    ${connection}=GNB_OAM
    ...    ${match_passive_SW}=SBTS22R4_ENB_0000_001302_000000
    OperatingSystem.File Should Exist    ${download_SW_path}/${SW_release}_ENB_*_release_BTSSM_downloadable_A54.zip
    csn.Connect to    hostname=${ute_ip}    username=${ute_username}    password=${ute_password}    alias=ute
    csn.send command    ls ${download_SW_path}    connection=ute
    ${before_knife_result}    csn.read output    connection=ute
    csn.disconnect    connection=ute
    ${knife_result}    delete_newline_symbol    str=${before_knife_result}
    set variable    ${knife_result}
    log    ${knife_result}
    ${knife_SW_name}   String.Split String    string=${knife_result}   separator=_release_    max_split=1
    log    ${knife_SW_name}[0]
    log to console    --- knife is ${knife_result} ---
    ${before_Active_SW_version}    Get Active SW Version    connection=${connection}
    Run Keyword If    '${before_Active_SW_version}'!='${match_passive_SW}'    Perform_SW_rollback
    ${current_Active_SW_version}    Get Active SW Version    connection=${connection}
    should be equal    ${current_Active_SW_version}    ${match_passive_SW}

    FOR    ${i}    IN RANGE    0    4
        log to console    start upgrade knife: ${knife_result}...
        Perform SW Update    package=${download_SW_path}/${knife_result}
        Wait until keyword succeeds    15min    30s    verify all cells should be onair
        ${current_active_SW}    Get Active SW Version    connection=${connection}
        should be equal    ${current_active_SW}    ${knife_SW_name}[0]
        Perform_SW_rollback
        Wait until keyword succeeds    15min    30s    verify all cells should be onair
        ${current_active_SW_1}    Get Active SW Version    connection=${connection}
        should be equal    ${current_active_SW_1}    ${match_passive_SW}
    END
    log to console    start upgrade knife: ${knife_result}...
    Perform SW Update    package=${download_SW_path}/${knife_result}
    Wait until keyword succeeds    15min    30s    verify all cells should be onair
    ${current_active_SW_after_loopRollback}    Get Active SW Version    connection=${connection}
    should be equal    ${current_active_SW_after_loopRollback}    ${knife_SW_name}[0]
    [Teardown]    Remove Download SW    download_SW=${download_SW_path}/${knife_result}

Remove Download SW
    [Arguments]    ${download_SW}
    csn.Connect to    hostname=${ute_ip}    username=${ute_username}    password=${ute_password}    alias=ute
    csn.send command    rm -rf ${download_SW}    connection=ute
    csn.disconnect    connection=ute

Get counter info
    [Arguments]    ${Counter_1}=M55125C02503    ${Conuter_2}=M55124C03006
    ...    ${fullPath_Counter_1}=[TDD Cell2] CELLS/NRCELL-62/NNGCC/NNGCC_UE_CTXT_STP_FAIL_SENT
    ...    ${fullPath_Counter_2}=[TDD Cell2] CELLS/NRCELL-62/NRRCC/NRRCC_RRC_RECONF_CMP_TMR
    RJIO Sbts Login And Disable Screen Lock
    ${Counter_1_dict}    selenium_sbts.get_bts_counters_info    counter_id=${Counter_1}    full_path=${fullPath_Counter_1}
    ${Counter_2_dict}    selenium_sbts.get_bts_counters_info    counter_id=${Conuter_2}    full_path=${fullPath_Counter_2}
    RJIO Sbts Logout And Close Browser
    ${Counter_1_value}    Get Dictionary Values    ${Counter_1_dict}    sort_keys=False
    ${Counter_2_value}    Get Dictionary Values    ${Counter_2_dict}    sort_keys=False
#    FOR    ${item_1}    IN    @{Counter_1_value}
#        Run Keyword If    ${item_1} > ${0}
    [Teardown]  RJIO Sbts Logout And Close Browser

call_RJIO_AEQZ
    [Arguments]    ${CRT_flag}=${False}
    [Documentation]    PA1: 10.71.204.123
    ...                PA2: 10.71.204.118
    Run Keyword And Ignore Error    Precondition for MTK    ue_index=${2}    reboot_ue=${True}
    log to console    +++ set PA2 port13-14 to 10,port 8/11/12 to 127 and call for AEQZ TDD cell62 +++
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${10}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12}    attenuator_index=${3}    value=${127}
    log to console    +++ set PA 10.71.204.118 port 1/3/4/7 to 30, for call TDD cell61 +++
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_1_3_4_7}    attenuator_index=${3}    value=${30}
    log to console    start traffic...
    ${cell_list}    Set Variable If    ${CRT_flag}==${True}    ${cell_id62}    ${cell_id61_62}
#    ${cell_list}    set variable    ${cell_id61_62}
    call_RJIO    tput_info=${tput_define}    cell_id_list=${cell_list}    duration_call=${1800}    duration=${120}
    ...    target_avg_percent=${0.4}    min_percent=${0.3}

call_RJIO_AQQJ
    set matrix PA for TDD cell
    log to console    start traffic on cell62...
    call_RJIO    tput_info=${tput_define_S23}    cell_id_list=${cell_id62}    duration_call=${1800}    duration=${120}
    ...    target_avg_percent=${0.3}    min_percent=${0.3}

set matrix PA for TDD cell
    log to console    +++ set B1~B4 to 63, B1-A1/B2-A2/B3-A3/B4-A4 to 0 and call for AQQJ TDD cell62 +++
    Set Whole Attenuator Ports    attenuator_out_ports=${matrixPA_out_ports}     attenuator_rows=${matrixPA_rows}    exp_pa_value=${63}
    Set PA Value For Pointed Port    PA_Port_List=${matrixPA_TDD908}    attenuator_index=${1}    value=${0}

set matrix PA for TDD cell 908 with moduleUE
    log to console    +++ set B9~B12 to 63, B9-A1/B10-A2/B11-A3/B12-A4 to 20 for attach AQQJ TDD cell62 +++
    Set Whole Attenuator Ports    attenuator_out_ports=${matrixPA_out_ports_9_12}     attenuator_rows=${matrixPA_rows}    exp_pa_value=${63}
    Set PA Value For Pointed Port    PA_Port_List=${matrixPA_moduleUE_B9A1_B10A2_B11A3_B12_A4}    attenuator_index=${1}    value=${20}

set matrix PA for ANR_EUTRA with moduleUE
    log to console    +++ set B9A9~B10A10 to 0, B9-A1/B10-A2/B11-A3/B12-A4 to 45 +++
    Set PA Value For Pointed Port    PA_Port_List=${matrixPA_B9A9_B10A10}    attenuator_index=${1}    value=${0}
    Set PA Value For Pointed Port    PA_Port_List=${matrixPA_moduleUE_B9A1_B10A2_B11A3_B12_A4}    attenuator_index=${1}    value=${45}

set matrix PA for NR_NR with moduleUE
    log to console    +++ set B9A7/B10A8 to 20, B9-A1/B10-A2/B11-A3/B12-A4 to 35 +++
    Set PA Value For Pointed Port    PA_Port_List=${matrixPA_B9A7_B10A8}    attenuator_index=${1}    value=${20}
    Set PA Value For Pointed Port    PA_Port_List=${matrixPA_moduleUE_B9A1_B10A2_B11A3_B12_A4}    attenuator_index=${1}    value=${35}

check hanging resource
    sleep    10s
    ${file_path}    Set Variable    /home/ute/hanging_resource/hanging_check_4G_5G_${BTS_ID}.py
    ${result}    check_hanging_resources    host=${ute_ip}    username=${ute_username}    password=${ute_password}    file_path=${file_path}
    ${hanging_resource_result}    set variable    ${result}[2]
    log to console    ++++ hanging resource result is : ${hanging_resource_result} ++++
    ${hanging_resource_status}    Run Keyword And Return Status    Should Be Equal As Strings    ${hanging_resource_result}    No hanging resources
    Run Keyword If    ${hanging_resource_status}==${False}    save full snapshot

monitor fault1907
     ${1907_status}    Run Keyword And Return Status    Wait For Expect Fault Present    faultId=1907    timeout=86400
     Run Keyword If    ${1907_status}==${True}    Save Full Snapshot    snapshot_path=/home/ute/snapshot_path

multiUE call spark
    [Arguments]    ${ue_index_list}    ${tput_expect}    ${ue_type}=huawei_sigspark    ${duration}=300    ${protocol}=udp
    ...    ${attach_mode}=5G_SA    ${gnb_index}=${0}    ${du_index}=0    ${iperf_type}=via_command
    ...    ${target_avg_percent}=0.4    ${min_percent}=0.4    ${duration_call}=300
    ${ue_cell_mapping}    create dictionary
    ${ue_tput_mapping}    create dictionary
    FOR    ${ue_index}    IN    @{ue_index_list}
        log to console    \n***Prepare for UE_${ue_index}***
        Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
        Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
        Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
        log to console    \n***Attach for UE_${ue_index}***
        power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
        Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
        Connect to Common Unit Master
        ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
        ...    alias=ASIK Master
        csn.Disconnect  connection=ASIK Master
        log to console    UE_${ue_index} attached to cell ${cell_id}
        set to dictionary    ${ue_cell_mapping}    ${ue_index}    ${cell_id}
        ${ue_mode}    Replace String    ${attach_mode}    5G_    ${EMPTY}
        log to console    \n***Start traffic for UE_${ue_index}***
#        ${duration_call}    Evaluate    ${duration}+${600}
        ${dl_tp}    set variable    ${tput_expect['${cell_id}']['dl_tp']}
        ${ul_tp}    set variable    ${tput_expect['${cell_id}']['ul_tp']}
        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}/sec
        ...    duration=${duration_call}    protocol=${protocol}    ue_mode=${ue_mode}
        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}/sec
        ...    duration=${duration_call}    protocol=${protocol}    iperf_type=${iperf_type}
    END
    log to console    \n***Start Collect Throughput for UE***
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    FOR    ${ue_index}    IN    @{ue_index_list}
        ${cell_id}     Get From Dictionary    ${ue_cell_mapping}     ${ue_index}
        ${dl_exp}    set variable    ${tput_expect['${cell_id}']['dl_exp']}
        ${ul_exp}    set variable    ${tput_expect['${cell_id}']['ul_exp']}
        ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
        ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
        ${cell_id}    Create List    ${cell_id}
        log to console    \n***Check tput for UE_${ue_index}***
        power_ue.Check Bi Tput    ue_type=nokia_fastmile    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
        ...    dltarget_throughput=${dl_exp}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    END
    FOR    ${ue_index}    IN    @{ue_index_list}
        log to console    \n***Stop traffic and Detach for UE_${ue_index}***
        run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
        run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
        run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}
    END

ANR_EUTRA_HO_AEQZ_1139
    [Documentation]    PA1: 10.71.204.123
    ...                PA2: 10.71.204.118
    [Arguments]    ${flag_call}=${False}    ${ue_index}=${0}
    log to console    \n*****change PA2 port13-14 to 10*****
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${10}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12}    attenuator_index=${3}    value=${127}
    log to console    \n****UE attach****
    ${attach_cell_id}    UE_attach_specific_cell
    sleep    5s
    Run Keyword If    ${flag_call}==${True}    Run Keywords    Start to collect the log on eNB(gnb1)    log_name=enb.pcap    interface=any    AND
    ...    data_transfer_KPI_except_attach    tput_info=${tput_define_NR_LTE_ANR}    cell_id=${cell_62}     duration_call=${1800}
    ...    ui_version=M40PUI1.1    tput_from=self_define    UL_traffic=${False}
    log to console    \n*****change PA2 port13-14 to 50 to attach LTE*****
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${38}
    Run Keyword If    ${flag_call}==${True}    Run Keywords    Stop and download Logs from eNB(gnb1) to local    log_name=enb.pcap    AND
    ...    detach_UE_stop_traffic    ue_index=${ue_index}    AND
    ...    check message with B2 event of Inter_RAT HO for enb    logname=enb.pcap    enb_address_msg=${enb_address_msg}
    [Teardown]    Run Keyword If    ${flag_call}==${True}    Run Keyword And Ignore Error    detach_UE_stop_traffic    ue_index=${ue_index}

Start to collect the log on eNB(gnb1)
    [Arguments]    ${log_name}    ${eNB_index}=${0}    ${interface}=any
    wait until keyword succeeds    2 min    10 sec    Connect to eNB node    eNB_index=${eNB_index}
    sleep    3s
    csn.send command    command=tcpdump -i ${interface} sctp -w /tmp/${log_name}   connection=ENB${eNB_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=ENB${eNB_index}

Connect to eNB node
    [Arguments]    ${eNB_index}
    csn.Connect to    hostname=${tl.enbs[${eNB_index}].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.enbs[${eNB_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.enbs[${eNB_index}].airscale.common_units[0].lmp_connection.password}    alias=ENB${eNB_index}

Stop and download Logs from eNB(gnb1) to local
    [Arguments]     ${log_name}    ${eNB_index}=${0}    ${local_dir}=${TS_CASE_LOG_PATH}
    wait until keyword succeeds    2 min    10 sec    Connect to eNB node    eNB_index=${eNB_index}
    sleep    10
    csn.send command    command=killall tcpdump     connection=ENB${eNB_index}
    sleep    5
    csn.download_file   remote_path=/tmp/${log_name}   local_path=${local_dir}${log_name}   connection=ENB${eNB_index}
    [Teardown]    csn.disconnect    connection=ENB${eNB_index}

check message with B2 event of Inter_RAT HO for enb
    [Arguments]    ${logname}    ${enb_address_msg}    ${local_dir}=${TS_CASE_LOG_PATH}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${local_dir}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${HO_req_filter}=     Catenate    s1ap.procedureCode == 1 and ip.dst == ${enb_address_msg}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//s1ap.radioNetwork    pcap_parser=test6
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    should contain    ${HO_req}    18
#    ...    ELSE    should contain    ${HO_req}    17
    ####    2022/10/18 PR671279 change meaasge HandoverRequired "radio Network" from radioNetwork: ng-inter-system-handover-triggered (32)
    ####    to radioNetwork: time-critical-handover (17)
    ####    2011/11/11 22R4/23R1/TRUNK are the same filter
    should contain    ${HO_req}    17
    ${HO_res_filter}=     Catenate    s1ap.procedureCode == 1 and ip.src == ${enb_address_msg}
    ${HO_res_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_res_filter}    pcap_parser=test6
    ${HO_res}=     cap.get_field_value_by_xpath    xpath=.//s1ap.procedureCode    pcap_parser=test6
    should contain    ${HO_res}    1
    ${notify_filter}=     Catenate    s1ap.procedureCode == 2
    ${notify_packets}=    cap.filter_packets_by_expression    filter_expression=${notify_filter}    pcap_parser=test6
    ${notify}=     cap.get_field_value_by_xpath    xpath=.//s1ap.procedureCode    pcap_parser=test6
    should contain    ${notify}    2
    ${DL_accept_filter}=     Catenate    s1ap.procedureCode == 11 and s1ap.id == 124
    ${DL_accept_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${DL_accept_filter}    pcap_parser=test6
    ${DL_accept}=     cap.get_field_value_by_xpath    xpath=.//s1ap.id    pcap_parser=test6
    should contain    ${DL_accept}    124
    ${ul_update_filter}=     Catenate    s1ap.procedureCode == 13
    ${ul_update_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${ul_update_filter}    pcap_parser=test6
    ${ul_update}=     cap.get_field_value_by_xpath    xpath=.//nas_eps.nas_msg_emm_type    pcap_parser=test6
    should contain    ${ul_update}    74

ANR_EUTRA_HO_AQQJ_2300
    [Arguments]    ${flag_call}=${False}    ${ue_index}=${0}
    set matrix PA for TDD cell 908 with moduleUE
    UE_attach_specific_cell_muduleUE_spark    ue_index=${ue_index}
    Run Keyword If    ${flag_call}==${True}    Run Keywords    start collect spark log    ue_index=${ue_index}    AND
    ...    data_transfer_moduleUE    tput_info=${tput_define_case64}    cell_id=${cell_62}    ue_index=${ue_index}    UL_traffic=${False}
    ...    tput_from=self_define    duration_call=${1800}
    set matrix PA for ANR_EUTRA with moduleUE
#    sleep    10s
#    UE_detach_specific_cell_muduleUE_spark    ue_index=${ue_index}
    Run Keyword If    ${flag_call}==${True}    Run Keywords    check info from spark log    ue_index=${ue_index}
    ...    msg=(634080,908)->(1300,81)    AND
    ...    Run Keyword And Ignore Error    collect_check_tput    duration=${120}    cell_id=${cell_62}    target_avg_percent=${0.95}
    ...    min_percent=${0.85}    ue_type=${ue_type}    AND
    ...    detach_UE_stop_traffic    apn_address=${apn_address}    ue_index=${ue_index}
    [Teardown]    Run Keyword If    ${flag_call}==${True}    Run Keyword And Ignore Error    detach_UE_stop_traffic
    ...    apn_address=${apn_address}    ue_index=${ue_index}

RJIO_ANR_EUTRA_AEQZ_1139
    [Arguments]    ${check_HO}=${False}
    @{NRADJECELL_create_list}=    Create List
    @{NRRELEL_create_list}=    Create List
#    ${cell61_ori_qRx}  ${cell63_ori_qRx}  ${cell71_ori_qRx}  ${cell72_ori_qRx}  ${cell73_ori_qRx}    Get qRxLevMin of cell
#    Set qRxLevMin of cell    cell61_qRxLevMin=${-22}    cell63_qRxLevMin=${-22}   cell71_qRxLevMin=${-22}
#    ...     cell72_qRxLevMin=${-22}    cell73_qRxLevMin=${-22}
    log to console    set LTE PA port15 to 0, other PA port to 127...
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_15}    attenuator_index=${3}    value=${0}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_1_2}    attenuator_index=${1}    value=${0}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12_13_14}    attenuator_index=${3}    value=${127}
    FOR   ${index}   IN RANGE   0    1
        ${NRADJECELL_creat_status}    ${NRRELEL_creat_status}    Rjio_E2E_ANR_EUTRA    check_HO=${check_HO}
        append to list    ${NRADJECELL_create_list}   ${NRADJECELL_creat_status}
        append to list    ${NRRELEL_create_list}   ${NRRELEL_creat_status}
    END
    log to console    ${NRADJECELL_create_list}
    log to console    ${NRRELEL_create_list}
    ${NRADJECELL_fail_status}    get_item_in_list    item_list=${NRADJECELL_create_list}    item=${False}
    ${NRRELEL_fail_status}    get_item_in_list    item_list=${NRRELEL_create_list}    item=${False}
    should be equal    ${NRADJECELL_fail_status}    ${0}
    should be equal    ${NRRELEL_fail_status}    ${0}
#    [Teardown]   Set qRxLevMin of cell    cell61_qRxLevMin=${cell61_ori_qRx}    cell63_qRxLevMin=${cell63_ori_qRx}
#    ...    cell71_qRxLevMin=${cell71_ori_qRx}    cell72_qRxLevMin=${cell72_ori_qRx}    cell73_qRxLevMin=${cell73_ori_qRx}

RJIO_ANR_EUTRA_AQQJ_2300
    @{NRADJECELL_create_list}=    Create List
    @{NRRELEL_create_list}=    Create List
    FOR   ${index}   IN RANGE   0    3
        ${NRADJECELL_creat_status}    ${NRRELEL_creat_status}    Rjio_E2E_ANR_EUTRA
        append to list    ${NRADJECELL_create_list}   ${NRADJECELL_creat_status}
        append to list    ${NRRELEL_create_list}   ${NRRELEL_creat_status}
    END
    log    ${NRADJECELL_create_list}
    log    ${NRRELEL_create_list}
    ${NRADJECELL_fail_status}    get_item_in_list    item_list=${NRADJECELL_create_list}    item=${False}
    ${NRRELEL_fail_status}    get_item_in_list    item_list=${NRRELEL_create_list}    item=${False}
    should be equal    ${NRADJECELL_fail_status}    ${0}
    should be equal    ${NRRELEL_fail_status}    ${0}

Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor-64
#    UE_attach_specific_cell_muduleUE_spark    ue_index=${4}
    Run Keyword If    '${mrbtsID}'=='1139'    RJIO_ANR_EUTRA_AEQZ_1139    check_HO=${True}
    Run Keyword If    '${mrbtsID}'=='2300'    RJIO_ANR_EUTRA_AQQJ_2300

Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor
    Run Keyword If    '${mrbtsID}'=='1139'    RJIO_ANR_EUTRA_AEQZ_1139    check_HO=${False}

NR_NR_ANR_HO_AEQZ_1139
    [Arguments]    ${flag_call}=${False}    ${ue_index}=${0}
    log to console    \n*****change PA2 port13-14 to 10, to attach cell 62*****
#    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${10}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12}    attenuator_index=${3}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_1_3_4_7}    attenuator_index=${3}    value=${30}
    log to console    \n****UE attach and traffic****
    ${attach_cell_id}    UE_attach_specific_cell    ue_index=${ue_index}
    run keyword if    ${flag_call}==${True}    Start to collect the log on eNB(gnb1)    log_name=gnb.pcap
    ${tput_info_define}    Set Variable If    ${flag_call}==${True}    ${tput_define_case34}    ${tput_define_case63}
    data_transfer_KPI_except_attach    tput_info=${tput_info_define}    cell_id=${cell_61}     duration_call=${300}
    ...    ui_version=M40PUI1.1    target_avg_percent=${0.5}    min_percent=${0.5}    duration=${120}
    ...    tput_from=self_define    UL_traffic=${False}    ue_index=${ue_index}
    log to console    \n*****change PA2 port13-14 to 30, PA1 port 8 to 10*****
#    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8}    attenuator_index=${3}    value=${10}
#    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${30}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_1_3_4_7}    attenuator_index=${3}    value=${70}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_2}    attenuator_index=${3}    value=${0}
    run keyword if    ${flag_call}==${True}    run keywords    Stop and download Logs from eNB(gnb1) to local    log_name=gnb.pcap    AND
    ...     Check message with inter gnb HO on target    logname=gnb.pcap
    run keyword and ignore error    detach_UE_stop_traffic    ue_index=${ue_index}

Stop and download Logs from gNB to local
    [Arguments]    ${filename}    ${local_dir}=${TS_CASE_LOG_PATH}
    Connect to Common Unit Master
    csn.send command    command=killall tcpdump     connection=ASIK Master
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${local_dir}${filename}   connection=ASIK Master
    sleep    3
    [Teardown]    csn.Disconnect  connection=ASIK Master

Check message with inter gnb HO on target
    [Arguments]    ${logname}    ${local_dir}=${TS_CASE_LOG_PATH}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${local_dir}${logname}    tshark_path=${tshark_path}
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${enb_address}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}
    ${HO_req}=     cap.get_field_value_by_xpath    pdml_list=${HO_req_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_req}    0
    ${HO_res_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${enb_address}
    ${HO_res_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_res_filter}
    ${HO_res}=     cap.get_field_value_by_xpath    pdml_list=${HO_res_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_res}    0
    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${enb_address}
    ${PathS_req_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PathS_req_filter}
    ${PathS_req}=     cap.get_field_value_by_xpath    pdml_list=${PathS_req_packets}
    ...                                                xpath=.//ngap.procedureCode
    should contain    ${PathS_req}    25
    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${enb_address}
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PathS_ACK_filter}
    ${PathS_ACK}=     cap.get_field_value_by_xpath    pdml_list=${PathS_ACK_packets}
    ...                                                xpath=.//ngap.procedureCode
    should contain    ${PathS_ACK}    25
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}
    ${UE_rel}=     cap.get_field_value_by_xpath    pdml_list=${UE_rel_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${UE_rel}    6

NR_NR_ANR_HO_AQQJ_2300
    [Arguments]    ${flag_call}=${False}    ${ue_index}=${0}
    set matrix PA for TDD cell 908 with moduleUE
    UE_attach_specific_cell_muduleUE_spark    ue_index=${ue_index}
    Run Keyword If    ${flag_call}==${True}    start collect spark log    ue_index=${ue_index}
    ${tput_info_define}    Set Variable If    ${flag_call}==${True}    ${tput_define_case34}    ${tput_define_case63}
    data_transfer_moduleUE    tput_info=${tput_info_define}    cell_id=${cell_62}    ue_index=${ue_index}    UL_traffic=${False}
    ...    tput_from=self_define    duration_call=${1800}
    set matrix PA for NR_NR with moduleUE
    Run Keyword If    ${flag_call}==${True}    Run Keywords    check info from spark log    ue_index=${ue_index}
    ...    msg=HO (634080,908)->(634080,500)    AND
    ...    Run Keyword And Ignore Error    collect_check_tput    duration=${120}    cell_id=${cell_62}    target_avg_percent=${0.95}
    ...    min_percent=${0.85}    ue_type=${ue_type}    AND
    ...    detach_UE_stop_traffic    apn_address=${apn_address}    ue_index=${ue_index}
    sleep    10s
    UE_detach_specific_cell_muduleUE_spark    ue_index=${ue_index}
    [Teardown]    Run Keyword If    ${flag_call}==${True}    Run Keyword And Ignore Error    detach_UE_stop_traffic
    ...    apn_address=${apn_address}    ue_index=${ue_index}

Rjio_E2E_63_Mobility_UE_based_ANR_for_NR_Neighbor-34
    [Arguments]    ${check_HO}=${False}    ${ue_index}=${0}
    kill python process on control pc    ue_index=${ue_index}
    @{NRADJNRCELL_create_list}=    Create List
    @{NRREL_create_list}=    Create List
    Run Keyword If    '${mrbtsID}'=='1139'
    ...    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_11_12_13_14}    attenuator_index=${3}    value=${127}
    FOR   ${index}   IN RANGE   0    1
        ${NRADJNRCELL_creat_status}    ${NRREL_creat_status}    Rjio_E2E_ANR_for_NR_Neighbor    check_HO=${check_HO}    ue_index=${ue_index}
        append to list    ${NRADJNRCELL_create_list}   ${NRADJNRCELL_creat_status}
        append to list    ${NRREL_create_list}   ${NRREL_creat_status}
    END
    log    ${NRADJNRCELL_create_list}
    log    ${NRREL_create_list}
    ${NRADJNRCELL_fail_status}    get_item_in_list    item_list=${NRADJNRCELL_create_list}    item=${False}
    ${NRREL_fail_status}    get_item_in_list    item_list=${NRREL_create_list}    item=${False}
    should be equal    ${NRADJNRCELL_fail_status}    ${0}
    should be equal    ${NRREL_fail_status}    ${0}
    [Teardown]    Run keywords    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_1_3_4_7}    attenuator_index=${3}    value=${30}   AND
    ...    run keyword and ignore error    kill python process on control pc    ue_index=${ue_index}

verify speicific cell is onair
    [Arguments]    ${specific_cell_list}    ${connection}=GNB_OAM
    FOR    ${cell}    IN    @{specific_cell_list}
        log to console    ++++ verify cell ${cell} is onair... ++++
#        ${cell_info}    coam.get_cell_specific_info    cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${nrbtsID}/NRCELL_R-${cell}
#        ...    connection=${connection}
        ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell}    connection=${connection}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell_info['status']['administrativeState']}     Unlocked
        Run keyword and continue on failure    Should be equal as strings    ${cell_info['status']['operationalState']}    enabled
    END

RJIO reboot UE
    [Arguments]    ${ue_index}=${0}
    ${alias}    set variable    cygwin_${ue_index}
#    ${alias_mobile}    Set Variable    UE_${ue_index}
    ${PC_IP}     Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${PC_username}    Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${PC_password}    Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    csn.connect_to    hostname=${PC_IP}    username=${PC_username}    password=${PC_password}    alias=${alias}
    csn.send_command    command=adb reboot    connection=${alias}    timeout=10
    sleep    5s
    wait until keyword succeeds    3 min    10s    check connect adb devices    alias=${alias}    serial_number=${serial_number}
#    mobile.setup    ui_version=${None}    host=${PC_IP}    username=${PC_username}    password=${PC_password}    serial_number=${serial_number}
#    ...    alias=${alias_mobile}
#    mobile.restart_debuglogger    waiting_time=10    mobile=${alias_mobile}
#    mobile.teardown    mobile=${alias_mobile}
    [Teardown]    csn.disconnect    connection=${alias}

check adb devices output
    [Arguments]    ${alias}    ${serial_number}
    csn.send_command    command=adb devices    connection=${alias}    timeout=10
    sleep    5s
    ${output}    csn.read_output    connection=${alias}
    Should contain   ${output}   ${serial_number}
    ${ue_status_info}   ${ue_status}   Should Match Regexp   ${output}   ${serial_number}\[\\s,\\t\]+(\\w+)
    [Return]    ${ue_status}

check connect adb devices
    [Arguments]    ${alias}    ${serial_number}
    ${result}    check adb devices output    alias=${alias}    serial_number=${serial_number}
    should contain    ${result}    device
    should not contain  ${result}   connecting
    should not contain  ${result}   offline

Reboot remote PC
    [Arguments]    ${ue_index}=${0}
    ${alias}    set variable    ctrlPC_${ue_index}
    ${PC_IP}     Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${PC_username}    Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${PC_password}    Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    csn.connect_to    hostname=${PC_IP}    username=${PC_username}    password=${PC_password}    alias=${alias}
    csn.send_command    command=shutdown -r -t 0    connection=${alias}    timeout=120
    sleep    20s
    [Teardown]    csn.disconnect    connection=${alias}

check remote PC status
    [Arguments]    ${ue_index}=${0}    ${ping_time}=60
    ${alias}    Set Variable    ute
    ${PC_IP}     Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    csn.connect_to    hostname=${ute_ip}    username=${ute_username}    password=${ute_password}    alias=${alias}
    csn.send_command    command=ping ${PC_IP} -w ${ping_time}   connection=${alias}    timeout=120
    ${output}    csn.read_output    connection=${alias}
    should contain    ${output}    64 bytes from ${PC_IP}
    should not contain    ${output}    100% packet loss
    [Teardown]    csn.disconnect    connection=${alias}

Clear log files for ELT
    [Arguments]    ${ELT_install_path}    ${log_pattern}=*.tmp    ${ue_index}=0    ${cpc_alias}=cpc_${ue_index}
    Wait until keyword succeeds    1 min    2 sec    Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ${output}    csn.send command    command=rm -rf ${ELT_install_path}/${log_pattern}   connection=${cpc_alias}
    [Teardown]    Run keyword and ignore error    ssh.disconnect    connection=${cpc_alias}

Precondition for MTK
    [Arguments]    ${ue_index}=${0}    ${reboot_ue}=${False}
#    Reboot remote PC    ue_index=${ue_index}
#    wait until keyword succeeds    3min    10s    check remote PC status    ue_index=${ue_index}
    ${Reboot_UE_status}    Run Keyword If    ${reboot_ue}==${True}    Run Keyword And Return Status    RJIO reboot UE    ue_index=${ue_index}
    log to console    ++++ reboot UE status is: ${Reboot_UE_status} ++++
    Kill ELT process on ue control pc if exists    ue_index=${ue_index}
    Clear log files for ELT    ELT_install_path=C:/ELT/ELT_exe_v3.2316.1_customer/ELT_v3.2316.1/Temp    ue_index=${ue_index}
    Clear log files for ELT    ELT_install_path=C:/ELT/ELT_exe_v3.2316.1_customer/ELT_v3.2316.1/Temp/Logs    log_pattern=*    ue_index=${ue_index}

data_transfer_moduleUE
    [Arguments]    ${tput_info}    ${ru_index}=${None}    ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration_call}=${1800}    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${ue_index}=${0}    ${ui_version}=default    ${iperf_type}=via_command
    ...    ${DL_traffic}=${True}    ${UL_traffic}=${True}    ${ue_alias}=UE_${ue_index}    ${tput_from}=tool
    ${tput_info_total}    create dictionary
    log to console    use ue${ue_index} to make call on cell${cell_id}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_id}]}
    log to console    tput info for cell ${cell_id} is: ${tput_cell}
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    Set Suite Variable    ${tput_info_total}
    ${tput_info}   set variable    ${tput_cell}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    spark.power_off    ue_alias=${ue_alias}
    spark.power_on    ue_alias=${ue_alias}
#    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${attached_cell_id}    Rjio_get_ue_attached_cell_id    ue_index=${ue_index}    alias=${alias}    connection=${connection}
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    ${apn_address}    Get From Dictionary    ${apn_info}    ${ue_index}
    Set Test Variable    ${apn_address}
    Run Keyword If    ${UL_traffic}==${True}    Run Keywords
    ...    log to console    start ul traffic...    AND
    ...    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}    apn_address=${apn_address}
    Run Keyword If    ${DL_traffic}==${True}    Run Keywords
    ...    log to console    start dl traffic...    AND
    ...    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    apn_address=${apn_address}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    [Return]    ${attached_cell_id}

Rjio_E2E_71_HO_Between_CA_And_TDD_With_BWP_Test
    [Arguments]    ${ue_index}=${4}    ${gnb_index}=0    ${du_index}=0    ${protocol}=udp    ${iperf_type}=via_command
    ...    ${loop_times}=${500}    ${ue_alias}=UE_${ue_index}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    log to console    set all B9-B12 port to 63
    Set Whole Attenuator Ports    attenuator_out_ports=${matrixPA_out_ports_9_12}     attenuator_rows=${matrixPA_rows}    exp_pa_value=${63}
    log to console    set A13B9/A14B10 to 39
    Set PA Value For Pointed Port    PA_Port_List=${matrixPA_B9A13_B10A14}    attenuator_index=${1}    value=${39}
    log to console    set    A1B9/A2B10/A3B11/A4B12 to 45
    Set PA Value For Pointed Port    PA_Port_List=${matrixPA_moduleUE_B9A1_B10A2_B11A3_B12_A4}    attenuator_index=${1}    value=${45}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=false    detach_request=false
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    ${ue_index_str}    Convert To String    ${ue_index}
    ${apn_address}    Get From Dictionary    ${apn_info}    ${ue_index_str}
    spark.configure_apn    ue_alias=${ue_alias}    apn=${apn_address}
    log to console    make ue3 (the third spark ue) attach
#    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
#    sleep    30s
    spark ue attach    ue_alias=${ue_alias}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Connect to Common Unit Master
    ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt    alias=ASIK Master
    log to console    ue${ue_index} attached to cell ${cell_id}
    csn.Disconnect  connection=ASIK Master
    ${duration_call_DL_low}    Set Variable    ${172800}
    log to console    start dl traffic(low)...
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=50K/sec    apn_address=${apn_address}
        ...    protocol=${protocol}    duration=${duration_call_DL_low}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    FOR    ${index}   IN RANGE    0    ${loop_times}
        ${duration_call_DL}    Evaluate    random.randint(10, 20)    modules=random
        log to console    +++ call duration is: ${duration_call_DL}s +++
        log to console    start dl traffic...
        ${status_dl}  Run Keyword And Return Status    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=200M/sec
        ...    apn_address=${apn_address}    protocol=${protocol}    duration=${duration_call_DL}    ue_index=${ue_index}
        ...    process_num=${process_num}    ue_mode=${gNb_CuType}
        ${status_ul}  Run Keyword And Return Status    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=10M/sec
        ...    apn_address=${apn_address}    protocol=${protocol}    duration=${duration_call_DL}    ue_index=${ue_index}
        ...    process_num=${process_num}    ue_mode=${gNb_CuType}
        ${sleep_time}=    Evaluate    random.randint(10, 20)    modules=random
        log to console    +++ stop traffic time is: ${sleep_time}s +++
        sleep    ${sleep_time}
        check_unexpected_alarms
        Run Keyword If  ${status_dl}==False or ${status_ul}==False    spark ue attach    ue_alias=${ue_alias}
    END
    check hanging resource
    [Teardown]    run keywords    run keyword and ignore error    detach_UE_stop_traffic    apn_address=${apn_address}    ue_index=${ue_index}    AND
    ...    run keyword and ignore error    stop_background_pa_adjust

Rjio_E2E_73_BWP_Test​_At_Cell_Edge
    [Arguments]    ${ue_index}=${4}    ${gnb_index}=0    ${du_index}=0    ${protocol}=udp    ${iperf_type}=via_command
    ...    ${loop_times}=${500}    ${ue_alias}=UE_${ue_index}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    log to console    change PA to make RSRP -100. set A1B9-A2B10-A3B11-A4B12 to 30
    Set Whole Attenuator Ports    attenuator_out_ports=${matrixPA_out_ports_9_12}     attenuator_rows=${matrixPA_rows}    exp_pa_value=${63}
    Set PA Value For Pointed Port    PA_Port_List=${matrixPA_moduleUE_B9A1_B10A2_B11A3_B12_A4}    attenuator_index=${1}    value=${30}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=false    detach_request=false
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    ${ue_index_str}    Convert To String    ${ue_index}
    ${apn_address}    Get From Dictionary    ${apn_info}    ${ue_index_str}
    spark.configure_apn    ue_alias=${ue_alias}    apn=${apn_address}
    log to console    make ue3 (the third spark ue) attach
#    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}    power_reset=false    detach_request=true
#    sleep    30s
    spark ue attach    ue_alias=${ue_alias}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Connect to Common Unit Master
    ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt    alias=ASIK Master
    log to console    ue${ue_index} attached to cell ${cell_id}
    csn.Disconnect  connection=ASIK Master
    log to console    trigger BWP switch by Data rate changes.--ul 50K, dl 200M and 0
    ${duration_call_DL_low}    Set Variable    ${172800}
    log to console    start dl traffic(low)...
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=50K/sec    apn_address=${apn_address}
        ...    protocol=${protocol}    duration=${duration_call_DL_low}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    FOR    ${index}   IN RANGE    0    ${loop_times}
        ${duration_call_DL}    Evaluate    random.randint(10, 20)    modules=random
        log to console    +++ call duration is: ${duration_call_DL}s +++
        log to console    start dl traffic...
        ${status_dl}  Run Keyword And Return Status    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=200M/sec
        ...    apn_address=${apn_address}    protocol=${protocol}    duration=${duration_call_DL}    ue_index=${ue_index}
        ...    process_num=${process_num}    ue_mode=${gNb_CuType}
        ${status_ul}  Run Keyword And Return Status    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=10M/sec
        ...    apn_address=${apn_address}    protocol=${protocol}    duration=${duration_call_DL}    ue_index=${ue_index}
        ...    process_num=${process_num}    ue_mode=${gNb_CuType}
        ${sleep_time}=    Evaluate    random.randint(10, 20)    modules=random
        log to console    +++ stop traffic time is: ${sleep_time}s +++
        sleep    ${sleep_time}
        check_unexpected_alarms
        Run Keyword If  ${status_dl}==False or ${status_ul}==False    spark ue attach    ue_alias=${ue_alias}
    END
    check hanging resource
    [Teardown]    Run Keywords    run keyword and ignore error    detach_UE_stop_traffic    apn_address=${apn_address}    ue_index=${ue_index}    AND
    ...    run keyword and ignore error    stop_backgroupd_ue_operation

spark ue attach
    [Arguments]    ${ue_alias}
    spark.power_off    ue_alias=${ue_alias}
    sleep    30s
    spark.power_off    ue_alias=${ue_alias}
    sleep    30s
    spark.power_on    ue_alias=${ue_alias}
    sleep    30s
    spark.power_on    ue_alias=${ue_alias}
    sleep    30s

data_transfer_BWP_moduleUE
    [Arguments]    ${tput_info}    ${ru_index}=${None}    ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${ue_index}=${0}    ${ui_version}=default    ${iperf_type}=via_command
    ...    ${DL_traffic}=${True}    ${UL_traffic}=${True}    ${loop_times}=${1}    ${ue_alias}=UE_${ue_index}
    ${tput_info_total}    create dictionary
    log to console    use ue${ue_index} to make call on cell${cell_id}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_id}]}
    log to console    tput info for cell ${cell_id} is: ${tput_cell}
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    Set Suite Variable    ${tput_info_total}
    ${tput_info}   set variable    ${tput_cell}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    spark.power_off    ue_alias=${ue_alias}
    spark.power_on    ue_alias=${ue_alias}
#    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${attached_cell_id}    Rjio_get_ue_attached_cell_id    ue_index=${ue_index}    alias=${alias}    connection=${connection}
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    ${apn_address}    Get From Dictionary    ${apn_info}    ${ue_index}
    ${duration_call_UL}    Set Variable    ${172800}
    Run Keyword If    ${UL_traffic}==${True}   Run Keywords
    ...    log to console    start ul traffic...    AND
    ...    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call_UL}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}    apn_address=${apn_address}
    FOR    ${index}   IN RANGE    0    ${loop_times}
        ${duration_call_DL}=    Evaluate    random.randint(10, 20)    modules=random
        log to console    +++ call duration is: ${duration_call_DL}s +++
        Run Keyword If    ${DL_traffic}==${True}    Run Keywords
        ...    log to console    start dl traffic...    AND
        ...    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    apn_address=${apn_address}
        ...    protocol=${protocol}    duration=${duration_call_DL}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
        ${sleep_time}=    Evaluate    random.randint(10, 20)    modules=random
        log to console    +++ stop traffic time is: ${sleep_time}s +++
        sleep    ${sleep_time}
    END
    [Teardown]    Run Keyword And Ignore Error    detach_UE_stop_traffic    apn_address=${apn_address}    ue_index=${ue_index}
    [Return]    ${attached_cell_id}

start collect spark log
    [Arguments]    ${ue_index}    ${power_reset}=${False}    ${detach_request}=${True}
    log to console    ++++ start collect spark log... ++++
    spark.require_ue    ue_alias=UE_${ue_index}    power_reset=${power_reset}    detach_request=${detach_request}    index=${ue_index}
    spark.start_log    ue_alias=UE_${ue_index}

check info from spark log
    [Arguments]    ${ue_index}    ${msg}
    ${alias_ute}    Set Variable    ute
    log to console    ++++ stop collect spark log and check info ++++
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    csn.Connect to    hostname=10.57.177.20    username=${ute_username}    password=${ute_password}    alias=${alias_ute}
    csn.send command    command=cd /home/ute/sparklog;touch ${timestamp}_sparklog_UE${ue_index}.xml;touch ${timestamp}_sparklog_UE${ue_index}.csv
    ...    connection=${alias_ute}
    csn.disconnect    connection=${alias_ute}
    ${log_name}    Set Variable    /home/ute/sparklog/${timestamp}_sparklog_UE${ue_index}.xml
    spark.stop_log    ue_alias=UE_${ue_index}    logname=${log_name}
    spark.read_log    logname=${log_name}
    ${result}    spark.get_expected_val    msg=${msg}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${alias_ute}

Rjio_E2E_38_SRS-Based_Mu-Mimo_Upto_8_Layers
    [Arguments]    ${ue_index_list}    ${ue_type}=huawei_sigspark    ${duration}=600    ${protocol}=udp
      ...    ${attach_mode}=5G_SA    ${gnb_index}=${0}    ${du_index}=0    ${iperf_type}=via_command
      ...    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${dl_tp}=1600M    ${dl_exp}=2975
    log to console    Use UE1 and UE2 attach TDD cell 907 directly. Do DL traffic 1.6G
    ${ue_cell_mapping}    create dictionary
    FOR    ${ue_index}    IN    @{ue_index_list}
          log to console    \n***Prepare for UE_${ue_index}***
          Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
          run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
          ${ue_index_str}    Convert To String    ${ue_index}
          ${apn_address}    Get From Dictionary    ${apn_info}    ${ue_index_str}
          spark.configure_apn    ue_alias=UE_${ue_index}    apn=${apn_address}
          log to console    \n***Attach for UE_${ue_index}***
          power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
          sleep    30s
          Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
          Connect to Common Unit Master
          ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
          ...    alias=ASIK Master
          ${cell_id}    Convert To Integer    ${cell_id}
          csn.Disconnect  connection=ASIK Master
          log to console    UE_${ue_index} attached to cell ${cell_id}
          set to dictionary    ${ue_cell_mapping}    ${ue_index}    ${cell_id}
          ${ue_mode}    Replace String    ${attach_mode}    5G_    ${EMPTY}
          log to console    \n***Start traffic for UE_${ue_index}***
          ${duration_call}    Evaluate    ${duration}+${600}*2
          ${apn_address}    Get From Dictionary    ${apn_info}    ${ue_index}
          power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}/sec
          ...    duration=${duration_call}    protocol=${protocol}    ue_mode=${ue_mode}    apn_address=${apn_address}
    END
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    ${cell_id}     Get From Dictionary    ${ue_cell_mapping}     ${ue_index_list}[0]
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    log to console    Check totally tput, Check totally tput
    ${tput_result}    power_ue.Check Tput    ue_type=huawei    direction=dl
    ...    log=${tput_log}    cells=${cell_id}    target_throughput=${dl_exp}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    run keyword and ignore error    UE detach and stop traffic    ue_index_list=${ue_index_list}    ue_type=${ue_type}

Rjio_E2E_74_Cell_Lock_Unlock
    [Arguments]    ${timeout}=${60}    ${gnb_id}=0    ${CRT_flag}=${False}    ${connection}=GNB_OAM
    call_RJIO_AEQZ    CRT_flag=${CRT_flag}
    log to console    change all cells' administrative State to locked, and check all cells are locked
    ${cell_id_list}  Get All Cell Id
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    ${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    FOR    ${cell_id}    IN    @{cell_id_list}
        coam.lock    dist_name=MRBTS-${mr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_id}    timeout=${timeout}    connection=${connection}
        Wait until keyword succeeds    1min    5s    Check cell should be locked    cell_id=${cell_id}
    END
    log to console    change all cells' administrative State to unlocked, and all cells are unlocked
    FOR    ${cell_id}    IN     @{cell_id_list}
        coam.unlock    dist_name=MRBTS-${mr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_id}    timeout=${timeout}    connection=${connection}
        Wait until keyword succeeds    1min    5s    Check cell should be unlocked    cell_id=${cell_id}
    END
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    call_RJIO_AEQZ    CRT_flag=${CRT_flag}

UE detach and stop traffic
    [Arguments]    ${ue_index_list}    ${ue_type}
    FOR    ${ue_index}    IN    @{ue_index_list}
          log to console    \n***Stop traffic and Detach for UE_${ue_index}***
          run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
          run keyword and ignore error    power_ue.ue detach  ue_type=${ue_type}    ue_index=${ue_index}
#          run keyword and ignore error    spark.power_off    ue_alias=UE_${ue_index}
    END

multe_ue_detach_attach
    [Arguments]    ${times}    ${ue_index_list}
    Connect to gnb coam via ssl
    FOR    ${index}    IN RANGE    ${times}
        run keyword and ignore error    ue_attach_samsung_2300    ue_index_list=${ue_index_list}
        run keyword and ignore error    ue_detach_samsung_2300    ue_index_list=${ue_index_list}
    END
    [Teardown]    COAM Teardown gnb connections

ue_attach_samsung_2300
    [Arguments]    ${ue_index_list}    ${gnb_index}=${0}    ${du_index}=0
    FOR    ${ue_index}    IN    @{ue_index_list}
          log to console    \n***Prepare for UE_${ue_index}***
          ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
          ${ui_version}    Run Keyword If   '${ue_type}'=='xiaomi'    Set Variable    Mi12UI13.0.12    ELSE   Set Variable   default
          Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
          ...    ui_version=${ui_version}
          log to console    ui_version if ${ui_version}
          log to console    \n***Attach for UE_${ue_index}***
          power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
          Connect to Common Unit Master
          ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
          ...    alias=ASIK Master
          csn.Disconnect  connection=ASIK Master
          log to console    UE_${ue_index} attached to cell ${cell_id}
    END

ue_detach_samsung_2300
    [Arguments]    ${ue_index_list}
    FOR    ${ue_index}    IN    @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}
    END

RJIO Test Teardown
    [Arguments]    ${gnb_index}=0    ${is_case_teardown}=${True}    ${is_check_historyalarm}=${False}
    robot_common_operations.Common Case Teardown
    log to console    \n***SISO Coam Test Teardown***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status    connection=${connection}
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    ...    connection=${connection}
    should be true    ${alarm_status}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_7313}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    run keyword if    ${is_check_historyalarm}    should be true    ${history_alarm_status}
    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    ${test_fail_flag}    run keyword if    ${is_case_teardown}    run keyword if test failed
    ...    set variable    ${True}
    ${test_fail_flag}    set variable if    ${test_fail_flag}    ${True}    ${False}
    AlarmWatchdog.teardown_watchdog
    run keyword if    ${save_snapshot} and ${test_fail_flag}    run keywords
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}    AND
    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}     gnb_index=${gnb_index}
    ...    ELSE
    ...    log to console    don't collect snapshot in test teardown!!!
    CI_interface.Common Case Teardown    connection=${connection}    gnb_index=${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    run keyword and ignore error    csn.Disconnect    connection=ASIK Master

alarm_1907_check
    [Arguments]    ${loop_times}=${50}    ${connection}=GNB_OAM
    FOR  ${i}  IN RANGE  ${loop_times}
        log to console    set actNrLBmMimoRTXPowerSaving from true to false
        ${parameters}    create list
        ${item}    create dictionary  parameterName=actNrLBmMimoRTXPowerSaving    operation=update    value=false
        append to list    ${parameters}    ${item}
        coam.perform_object_recommissioning    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}    parameter=${parameters}
        ...    operation=update    skip_parameter_relation_errors=${True}    connection=${connection}
        sleep    5s
        log to console    check cells status
        Wait until keyword succeeds    20min    30s    verify all cells should be onair
        log to console    set actNrLBmMimoRTXPowerSaving from false to true(will trigger nr rat reset)
        ${parameters}    create list
        ${item}    create dictionary  parameterName=actNrLBmMimoRTXPowerSaving    operation=update    value=true
        append to list    ${parameters}    ${item}
        coam.perform_object_recommissioning    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}    parameter=${parameters}
        ...    operation=update    skip_parameter_relation_errors=${True}    connection=${connection}
        sleep    5s
        log to console    check cells status
        Wait until keyword succeeds    20min    30s    verify all cells should be onair
        log to console    login ru1-ru3 to send command  lmi-eth on
        run keyword and ignore error    set_lmi-eth_on    RU_index_list=${RU_1_2_3}
        sleep    300s
        log to console    check 1907 fault not reported
        Expect Fault Should Absent    faultId=1907
    END

alarm_1907_check_by_rat_reset
    [Arguments]    ${loop_times}=${50}    ${connection}=GNB_OAM
    FOR  ${i}  IN RANGE  ${loop_times}
        run keyword and ignore error    COAM Teardown gnb connections
        Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
        log to console    rat reset
        coam.rat reset    rat_type=NR    connection=${connection}    timeout=300
        sleep    2s
        log to console    check cells status
        Wait until keyword succeeds    20min    30s    verify all cells should be onair
        set_lmi-eth_on    RU_index_list=${RU_1}
    END
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

BB Reset
    log to console    this is BB Reset

Reset w/o HWF
    Modify File Of Swconfig    swconfig_path=${CURDIR}/swconfig_new.txt
    # add call
    [Teardown]    Modify File Of Swconfig    swconfig_path=${CURDIR}/swconfig_old.txt

Delto Commissioning
    log to console    this is delto comissioning

stop_background_pa_adjust
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=UTE
    ${pa_adjust_old_pid}    csn.execute    command=ps -ef |grep background_PA_adjust.robot| grep -v grep | awk '{print $2}'    connection=UTE
    csn.send_command    command=ps -ef |grep background_PA_adjust.robot| grep -v grep | awk '{print $2}'|xargs kill -9    connection=UTE
    sleep   3s
    ${pa_adjust_pid}    csn.execute    command=ps -ef |grep background_PA_adjust.robot| grep -v grep | awk '{print $2}'    connection=UTE
    should be empty  ${pa_adjust_pid}
    [Teardown]    csn.disconnect    connection=UTE

stop_backgroupd_ue_operation
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=UTE
    ${multi_ue_old_pid}    csn.execute    command=ps -ef |grep multi_ue_operation.robot| grep -v grep | awk '{print $2}'    connection=UTE
    csn.send_command    command=ps -ef |grep multi_ue_operation.robot| grep -v grep | awk '{print $2}'|xargs kill -9    connection=UTE
    sleep   3s
    ${multi_ue_pid}    csn.execute    command=ps -ef |grep multi_ue_operation.robot| grep -v grep | awk '{print $2}'    connection=UTE
    should be empty  ${multi_ue_pid}
    [Teardown]    csn.disconnect    connection=UTE

reset_actRemoteSyslogTransmission
    update_parameter_value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1    parameter_name=actRemoteSyslogTransmission
    ...    value=false
    update_parameter_value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1    parameter_name=actRemoteSyslogTransmission
    ...    value=true

pcmd check with cell L3call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Start multicell traffic
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${protocol}=udp
    ...    ${target_avg_percent}=0.5
    ...    ${min_percent}=0.2
    ...    ${duration}=${120}
    ...    ${ue_index}=${0}
    log to console    \n***Start UE attach and start traffic***
    start collect pcmd logs    cmd=br0
    KDDI UE attach and start traffic    ue_index=${ue_index}    dl_tp=700M     ul_tp=50M
    sleep    30s
    Stop and download pcmd log
    pcmd log analysis sa
    log to console    \n***Start Collect Throughput***
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id}    Convert To String    ${cell_mapping[72]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    log to console    \n***Start Check cell301(40M) Throughput***
    power_ue.Check Bi Tput    ue_type=nokia_fastmile
    ...    log=${tput_log}    cells=${cell_id}    ultarget_throughput=10
    ...     dltarget_throughput=50    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    Stop UE L3 Call

Stop UE L3 Call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Stop multi UE L3 Call
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    log to console    \n***Stop UE L3 Call***
    run keyword and ignore error  huawei.Stop traffic   direction=dl    ue_index=${ue_index}
    run keyword and ignore error  huawei.Stop traffic   direction=ul    ue_index=${ue_index}
    ${status}  ${5Grach_ed}  run keyword and ignore error   huawei.UE Detach   ue_index=${0}

modify remote syslog server
    [Arguments]    ${ip}=${tl.test_pc.default_ssh_connection_details.addr}    ${connection}=GNB_OAM
    log to console    start to set remoteSyslogServerIPaddress to ${ip}
    ${tmp}    create dictionary
    ...    remoteSyslogDSCP    ${54}
    ...    remoteSyslogFormat    RFC5424
    ...    remoteSyslogServerIPaddress    ${ip}
    ...    remoteSyslogServerPortNo    ${51000}
    ...    remoteSyslogTransmitDuration    ${240}
    ...    remoteSyslogTransportProtocol    UDP
    ${tmp}     Create List    ${tmp}
    ${remoteSyslogConfig_List}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter    remoteSyslogConfig
    ...    value        ${tmp}
    ${parameters}    Create List    ${remoteSyslogConfig_List}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

clear existing btslogs on contorl pc
    [Arguments]    ${log_path}=/cygdrive/c/TEMP/Logs/    ${ue_index}=${0}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=ls -l ${log_path}    connection=cygwin
    ${files}    csn.Read Output    connection=cygwin
    csn.send_command    command=rm -rf ${log_path}*    connection=cygwin
    sleep    2s
    ${result}    csn.Read Output    connection=cygwin
    csn.send_command    command=ls -l ${log_path}|grep SYSLOG_*|awk '{print $NF}'    connection=cygwin
    ${file}    csn.Read Output    connection=cygwin
#    ${length}    Get Length    ${file}
#    Return From Keyword If    ${length}==${0}
#    ${file}    Strip string    ${file}
#    log to console    file ${file} being writing, try to delete is until it is reached the max size!
#    FOR    ${index}    IN RANGE    ${60}
#        csn.send_command    command=rm -rf ${log_path}${file}    connection=cygwin
#        sleep    2s
#        csn.send_command    command=ls -l ${log_path}|grep ${file}|wc -l    connection=cygwin
#        ${result}    csn.Read Output    connection=cygwin
#        ${result}    Strip string    ${result}
#        EXIT FOR LOOP IF   '${result}'=='${0}'
#        sleep    30s
#    END
#    log to console    cleared all existing files!
    [Teardown]    csn.disconnect      connection=cygwin

check bts log info on control pc
    [Arguments]    ${find_log}    ${log_path}=/cygdrive/c/TEMP/Logs/     ${ue_index}=${0}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=ls -l ${log_path}|grep SYSLOG_*|awk '{print $NF}'    connection=cygwin
    ${files}    csn.Read Output    connection=cygwin
    ${files}    Split String   ${files}    \n
    ${match_number}    set variable    ${0}
    FOR    ${file}    IN    @{files}
        log to console    check file ${file}
        csn.send_command    command=cat ${log_path}${file}|grep ${find_log}|wc -l    connection=cygwin
        ${result}    csn.Read Output    connection=cygwin
        ${result}    Strip string    ${result}
        ${result}   convert to integer   ${result}
        ${match_number}    Evaluate    ${match_number} + ${result}
#        EXIT FOR LOOP IF   '${result}'!='${0}'
    END
#    should not be equal    '${result}'    '${0}'
#    log to console    find ${find_log} in ${file}!
    [Teardown]    csn.disconnect      connection=cygwin
    [Return]    ${match_number}
