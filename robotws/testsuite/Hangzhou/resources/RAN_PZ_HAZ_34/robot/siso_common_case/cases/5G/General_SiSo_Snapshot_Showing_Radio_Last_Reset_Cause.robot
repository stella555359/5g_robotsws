*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
*** Variables ***

*** Keywords ***
General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]The purpose of this case is to check runtime log reported in snapshot that shows
        ...	    the radio last reset cause.
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 12.02.2022 - - Created
        ...    *******************
        ...    zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_type}=AQQY
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Verify RU last reset reason WatchDog   ru_type=${ru_type}
    Verify RU last reset reason BTS   ru_type=${ru_type}
    Verify RU last reset reason Unit    ru_type=${ru_type}
    Verify RU last reset reason PowerOn   ru_type=${ru_type}
    [Teardown]  selenium logout and close browser

Verify RU last reset reason PowerOn
    [Arguments]    ${ru_index}=1   ${ru_type}=AQQY
    log to console    \nVerify RU last reset reason PowerOn
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep    120s
    Run Keyword If   "AVQ" not in "${ru_type}"   Check snapshot to verify reset cause   Cause=PowerOn
    ...               ELSE    Check snapshot to verify reset cause With AVQC   Cause=PowerOn

Verify RU last reset reason BTS
    [Arguments]    ${ru_type}=AQQY
    log to console    \nVerify RU last reset reason BTS
    Perform BTS Site Reset On WebUI
    sleep    300s
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep    120s
    Run Keyword If   "AVQ" not in "${ru_type}"  Check snapshot to verify reset cause
    ...                ELSE   Check snapshot to verify reset cause With AVQC


Check snapshot to verify reset cause
    [Arguments]    ${Cause}=BTS   ${ru_index}=1    ${snapshot_path}=${SAVE LOG DIRECTORY}
    log to console    check reset reason is ${Cause}
    &{ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}   connection=GNB_OAM
    ${serial_number}    Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    ${snapshot_unzip_file_path}    Join Path    ${SUITE_LOG_PATH}    snapshot_${timestamp}
    log to console   collect snapshot
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   coverage=Full
    ...    timeout=1500   connection=GNB_OAM
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${pattern}   Set Variable    BTS_part(\\d).zip:[^:]*BTS_${serial_number}_RMOD_L_${ru_index}_startup.zip
    ${btspart_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${btspart}   Set Variable    BTS_part${btspart_list}[0]
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}.zip
    ...                 ${snapshot_unzip_file_path}/${btspart}
    ${start_log_name}    Run    command=cd ${snapshot_unzip_file_path}/${btspart};ls -l | grep startup.tar.gz | awk '{print $9}'
    ${start_log_dir}   Set Variable     ${start_log_name.split('.')[0]}
    ${start_up_file_path}    Join Path    ${snapshot_unzip_file_path}/${btspart}
    ...    ${start_log_dir}
    OperatingSystem.Create Directory   ${start_up_file_path}
    Run    tar -xzf ${start_up_file_path}.tar.gz -C ${start_up_file_path}
    ${start_up_00_file}    Join Path    ${start_up_file_path}
    ...    00_startup
    Run    tar -xvf ${start_up_00_file}.txz -C ${start_up_file_path}
    ${start_up_var_log_file_path}    Join Path    ${start_up_file_path}
    ...    var/log/startup.log
    Run    gzip -d ${start_up_var_log_file_path}.gz
    ${result}    Run    cat ${start_up_var_log_file_path} | grep Last | grep reset | grep cause
    Should Contain    ${result}    ${Cause}
    Run   rm -r ${snapshot_unzip_file_path}
    Run   rm -r ${snapshot_zip_file_path}

Check snapshot to verify reset cause With AVQC
    [Arguments]    ${Cause}=BTS   ${ru_index}=1    ${snapshot_path}=${SAVE LOG DIRECTORY}
    log to console    check reset reason is ${Cause}
    &{ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}   connection=GNB_OAM
    ${serial_number}    Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    ${snapshot_unzip_file_path}    Join Path    ${SUITE_LOG_PATH}    snapshot_${timestamp}
    log to console   collect snapshot
    Wait until keyword succeeds   3x   60s   coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   coverage=Full
    ...    timeout=1500   connection=GNB_OAM
    log to console   collect done
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${pattern}   Set Variable    BTS_part(\\d+).zip:[^:]*BTS_${serial_number}_RMOD_L_${ru_index}_ccs.*-startup.tar.gz
    ${btspart_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${btspart}   Set Variable    BTS_part${btspart_list}[0]
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}.zip
    ...                 ${snapshot_unzip_file_path}/${btspart}
    ${start_log_name}   Run   command=cd ${snapshot_unzip_file_path}/${btspart};ls -l | grep RMOD_L_${ru_index}_ccs.*-startup.tar | awk '{print $9}'
    ${start_log_dir}   Set Variable     ${start_log_name.split('.')[0]}
    ${start_up_file_path}    Join Path    ${snapshot_unzip_file_path}/${btspart}
    ...    ${start_log_dir}
    OperatingSystem.Create Directory   ${start_up_file_path}
    Run    tar -xzf ${start_up_file_path}.tar.gz -C ${start_up_file_path}
    ${start_up_var_log_file_path}    Join Path    ${start_up_file_path}
    ...    var/log/startup.log
    Run    gzip -d ${start_up_var_log_file_path}.gz
    ${result}    Run    cat ${start_up_var_log_file_path} | grep Last | grep reset | grep cause
    Should Contain    ${result}    ${Cause}
    Run   rm -r ${snapshot_unzip_file_path}
    Run   rm -r ${snapshot_zip_file_path}

Verify RU last reset reason WatchDog
    [Arguments]   ${ru_index}=1   ${asik_alias}=ASIK Master  ${ru_type}=AQQY
    log to console    \nVerify RU last reset reason WatchDog
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=${asik_alias}
    Connect to RU With Allocated IP     ru_index=${ru_index}    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
    ${cmd_temp}   Set Variable  echo "/ action create ResetControl /CI/resetControl/module /module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo "/CI/resetControl/module action reset WATCHDOG"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    Wait until keyword succeeds    8 min    20 sec    RU Should Be Online    ru_index=${ru_index}
    sleep   300s
    Wait until keyword succeeds    20 min    30 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep    120s
    log to console    Check snapshot to verify reset cause With AVQC
    Run Keyword If   "AVQ" not in "${ru_type}"   Check snapshot to verify reset cause   Cause=WatchDog
    ...                  ELSE      Check snapshot to verify reset cause With AVQC   Cause=WatchDog
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

Verify RU last reset reason Unit
    [Arguments]   ${ru_index}=1   ${asik_alias}=ASIK Master    ${ru_type}=AQQY
    log to console    \nVerify RU last reset reason Unit
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=${asik_alias}
    log to console    connect RU
    Connect to RU With Allocated IP     ru_index=${ru_index}    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
    log to console    reset RU
    ${cmd_temp}   Set Variable  echo "/ action create ResetControl /CI/resetControl/module /module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo "/CI/resetControl/module action reset MANAGEMENT"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    120s
    log to console    reset done
    Wait until keyword succeeds    8 min    20 sec    RU Should Be Online    ru_index=${ru_index}
    sleep    300s
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    Run Keyword If   "AVQ" not in "${ru_type}"   Check snapshot to verify reset cause   Cause=Unit
    ...                  ELSE      Check snapshot to verify reset cause With AVQC   Cause=Unit
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
