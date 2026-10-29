*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
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
        ...    - 7.23.2022 - - Created
        ...    *******************
        ...    yue.2.liu@nokia-sbell.com
    Verify RU last reset reason BTS
    Verify RU last reset reason PowerOn
    Verify RU last reset reason WatchDog
    Verify RU last reset reason Unit

Verify RU last reset reason PowerOn
    log to console    \nVerify RU last reset reason PowerOn
    Perform RU Power reset LTE
    sleep    300s
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep    120s
    Check snapshot to verify reset cause    Cause=PowerOn   serial_number=${ru_serial_number}

Verify RU last reset reason BTS
    log to console    \nVerify RU last reset reason BTS
    Perform BTS Site Reset On WebUI
    sleep    300s
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep    120s
    Check snapshot to verify reset cause   serial_number=${ru_serial_number}

Check snapshot to verify reset cause
    [Arguments]    ${Cause}=BTS   ${ru_index}=1   ${serial_number}=${tl.enbs[0].rms[${ru_index}-1].serial_number}
    ...    ${snapshot_path}=${CASE_LOG_PATH}    ${file_name}=startup
    log to console    check reset reason is ${Cause}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   coverage=Full
    ...    timeout=1500   connection=GNB_OAM
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${pattern}   Set Variable    BTS_part(\\d).zip:[^:]*BTS_${serial_number}_RMOD_L_${ru_index}_${file_name}.zip
    ${btspart_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${btspart}   Set Variable    BTS_part${btspart_list}[0]
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}.zip
    ...                 ${snapshot_unzip_file_path}/${btspart}
    ${start_up_file_path}    Join Path    ${snapshot_unzip_file_path}/${btspart}
    ...    BTS_${serial_number}_RMOD_L_${ru_index}_${file_name}
    Extract Zip File    ${start_up_file_path}.zip    ${start_up_file_path}
    Run    xz -d ${start_up_file_path}/${file_name}_DEFAULT.log.xz
    ${result}    Run    cat ${start_up_file_path}/${file_name}_DEFAULT.log | grep Last | grep reset | grep cause
    Should Contain    ${result}    ${Cause}
    [Teardown]    Run Keywords    Run   rm -r ${snapshot_unzip_file_path}    AND    Run    rm -r ${snapshot_zip_file_path}

Verify RU last reset reason WatchDog
    [Arguments]   ${ru_index}=1   ${asik_alias}=ASIK Master
    log to console    \nVerify RU last reset reason WatchDog
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=${asik_alias}
    Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}     ru_index=${ru_index}
    ...    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
    ${cmd_temp}   Set Variable  echo "/ action create ResetControl /CI/resetControl/module /module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo "/CI/resetControl/module action reset WATCHDOG"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    Wait until keyword succeeds    8 min    20 sec    RU Should Be Online    ru_index=${ru_index}
    sleep    300s
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    Check snapshot to verify reset cause    Cause=WatchDog    serial_number=${ru_serial_number}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

Verify RU last reset reason Unit
    [Arguments]   ${ru_index}=1   ${asik_alias}=ASIK Master
    log to console    \nVerify RU last reset reason Unit
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=${asik_alias}
    log to console    connect RU
    Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}     ru_index=${ru_index}
    ...    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
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
    Check snapshot to verify reset cause    Cause=Unit    serial_number=${ru_serial_number}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
