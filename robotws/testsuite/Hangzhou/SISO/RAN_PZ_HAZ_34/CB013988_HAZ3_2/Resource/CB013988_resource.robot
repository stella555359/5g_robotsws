*** Settings ***
Documentation
...    author: zhang yu
...    contact: yu.8.zhang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_CM_Recommissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot

Library    BuiltIn
Library    Collections
Library    taf.selenium.sbts   WITH NAME   selenium_coam

*** Variables ***
${TS_CASE_LOG_PATH}      /home/ute
${BASIC_PATH_5G}         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G
${UTE_syslogs_path}      /home/ute
${resetlogfile}          /mnt/runtime/RecovPorLogs/RecovPorLogs1.zip

*** Keywords ***
RU Power Reset Escalation For Missing M-Plane Connection
    [Documentation]    This keyword escalates RU power reset when M-Plane connection is missing.
    [Arguments]    ${ru_index}=1    ${hw_name}=BBMOD-1    ${sfp_port1}=RF1    ${sfp_port2}=RF2
    Enable Feature CB013988    ru_index=${ru_index}
    ${org_counter}=    Get Poor Reset Counter    ru_index=${ru_index}
    Lock RU SFP to Trigger RU Recovery
    ...    ru_index=${ru_index}    hw_name=${hw_name}    sfp_port1=${sfp_port1}    sfp_port2=${sfp_port2}
    ${new_counter}=    Get Poor Reset Counter    ru_index=${ru_index}
    Check Poor Reset Counter    org_counter=${org_counter}    new_counter=${new_counter}    reset_num=1
    Check File Should Exist ON RU    ru_index=${ru_index}    file=${resetlogfile}

RU Power Reset Escalation For Internal Radio Recovery
    [Documentation]    This keyword escalates RU power reset for internal radio recovery.
    [Arguments]    ${ru_index}=1
    Enable Feature CB013988    ru_index=${ru_index}
    ${org_counter}=    Get Poor Reset Counter    ru_index=${ru_index}
    Kill Testability Instance to Trigger RU Recovery    ru_index=${ru_index}
    ${new_counter}=    Get Poor Reset Counter    ru_index=${ru_index}
    Check Poor Reset Counter    org_counter=${org_counter}    new_counter=${new_counter}    reset_num=1
    Check File Should Exist ON RU    ru_index=${ru_index}    file=${resetlogfile}
    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}

Get Poor Reset Counter
    [Documentation]    Get the current value of the POOR Reset Counter from the RU.
    [Arguments]    ${ru_index}=1    ${asik_alias}=ASIK Master    ${ru_alias}=RU_${ru_index}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=${ru_alias}
    ${poor_reset_counter}=    csn.execute
    ...    command=cat /mnt/runtime/BBOX5 |grep 'POOR Reset Counter' |grep -v BTS |awk '{print $4}'
    ...    connection=${ru_alias}
    ${poor_reset_counter}=    Strip String    ${poor_reset_counter}
    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
    [Return]    ${poor_reset_counter}

Enable Feature CB013988
    [Documentation]    Enable the CB013988 feature on the RU.
    [Arguments]    ${asik_alias}=ASIK Master    ${ru_index}=1    ${ru_alias}=RU_${ru_index}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=${ru_alias}
    ${output}=    csn.execute    command=ccsShell.sh rad -mpw 0xc001d 0    connection=${ru_alias}
    Should Contain    ${output}    written succesfully
    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

Check Poor Reset Counter
    [Documentation]    Check if the new POOR Reset Counter equals the original counter plus the expected reset number.
    # The Poor Reset Counter will increase when poor reset interval exceeds 1 hour.
    [Arguments]    ${org_counter}=1    ${new_counter}=2    ${reset_num}=1
    ${expected_counter}=    Evaluate    ${org_counter} + ${reset_num}
    Should Be Equal As Numbers    ${new_counter}    ${expected_counter}

Check File Should Exist ON RU
    [Documentation]    Get if the file exists on RU.
    [Arguments]    ${file}    ${ru_index}=1    ${asik_alias}=ASIK Master    ${ru_alias}=RU_${ru_index}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=${ru_alias}
    ${output}=    csn.execute    command=ls ${file}    connection=${ru_alias}
    Should Contain    ${output}    ${file}
    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

Kill Testability Instance to Trigger RU Recovery
    [Documentation]    Kill the testabilitytcp application process on the RU and verify RU offline/online status.
    [Arguments]    ${ru_index}=1
    Kill PID ON RU    process_name=testabilitytcp    ru_index=${ru_index}
    Wait until keyword succeeds    10 min    30 sec    RU Should Be Offline    ru_index=${ru_index}
    Wait until keyword succeeds    10 min    30 sec    RU Should Be Online    ru_index=${ru_index}
    # Kill again
    Kill PID ON RU    process_name=testabilitytcp    ru_index=${ru_index}
    Wait until keyword succeeds    10 min    30 sec    RU Should Be Offline    ru_index=${ru_index}
    Wait until keyword succeeds    10 min    30 sec    RU Should Be Online    ru_index=${ru_index}

Kill PID ON RU
    [Documentation]    Get the PID of the specified process on RU and kill it if found.
    ...    Returns PID or empty string if not found.
    [Arguments]    ${process_name}=uoamapp    ${ru_index}=1    ${ru_alias}=RU_${ru_index}    ${asik_alias}=ASIK Master
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=${ru_alias}
    ${pid}=    csn.execute    command=ps |grep ${process_name} |grep -v grep |awk '{print $1}'    connection=${ru_alias}
    ${pid}=    Strip String    ${pid}
    Run Keyword If    '${pid}'!='' and '${pid}'.isdigit()    csn.execute
    ...    command=sudo kill -9 ${pid}    connection=${ru_alias}
    ...    ELSE    csn.execute
    ...    command=ps -ef |grep ${process_name} |grep -v grep |awk '{print $2}' | xargs sudo kill -9    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

Lock RU SFP to Trigger RU Recovery
    [Documentation]    Lock the SFP port of RU to simulate M-Plane disconnection.
    [Arguments]    ${ru_index}=1    ${hw_name}=BBMOD-1    ${sfp_port1}=RF1    ${sfp_port2}=RF2
    selenium login and disable screen lock
    selenium_coam.lock_lane_from_sfp    hw_name=${hw_name}    object_name=${sfp_port1}    lane_id=LANE-1
    selenium_coam.lock_lane_from_sfp    hw_name=${hw_name}    object_name=${sfp_port2}    lane_id=LANE-1
    Sleep    60 min
    Wait until keyword succeeds    3 min    30 sec    Expect Fault Should Present    faultId=${10}
    selenium_coam.unlock_lane_from_sfp    hw_name=${hw_name}    object_name=${sfp_port1}    lane_id=LANE-1
    selenium_coam.unlock_lane_from_sfp    hw_name=${hw_name}    object_name=${sfp_port2}    lane_id=LANE-1
    Wait until keyword succeeds    10 min    30 sec    RU Should Be Online    ru_index=${ru_index}
    selenium logout and close browser
