*** Settings ***
Documentation    This is common keywords for siso RU related cases
...              Please do not modify the file without notification to author
...              Author: zhihao.shi@nokia-sbell.com
...              Squard: HZ SG4   HZ SG8

Library    taf.transport.ssh    WITH NAME    csn
Library    ../../lib/analyse_snapshot.py
Library    ../../../../python/parse_soap.py
Library       testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/common_ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nrarfcn_and_gscn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/soap.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/btslog_check.robot

*** Keywords ***
Perform RU Power reset
    [Arguments]  ${ru_index}=1
    log to console    \n***Perform RU Power reset**
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait until keyword succeeds    3 min    20 sec    RU Should Be Power Off    ru_index=${ru_index}
    Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait until keyword succeeds    8 min    20 sec    RU Should Be Online    ru_index=${ru_index}

Perform Site Power reset
    log to console    \n***Perform Site Power reset**
    Perform Site Power Off    model=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    sleep  5
    Perform Site Power On    model=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    sleep  5

Perform RU Power Off And On
    [Arguments]    ${ru_index_list}    ${ru_index}=${1}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        sleep  10s
    END

Power On RU_and_check RF Delayed Startup
    [Arguments]  ${ru_index_list}
    log to console    \n***Power On RU_and_check RF Delayed Startup***
    FOR  ${ru_index}  IN  @{ru_index_list}
         Perform RU Power On     ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    END
    Wait Until Keyword Succeeds    20min    1min     COAM Check GNB RU status
    Wait Until Keyword Succeeds    20min     30s     verify all cells should be onair

Power On RU And Check
    [Arguments]  ${ru_index_list}
    log to console    \n***Power On RU And Check***
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
    END
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'

Get RU IP Address
    [Arguments]  ${ru_index}=1
    log to console  \n***Get RU IP Address***
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    &{ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
    ${ru_ip_addr}   Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}
    should not be equal    ${ru_ip_addr}    0.0.0.0
    [Return]    ${ru_ip_addr}
    [Teardown]    csn.disconnect    connection=ASIK Master

get RFSW version from radio module
    [Arguments]   ${ru_index}=1
    connect to common unit master
    sleep   1s
    Connect to RU With Allocated IP    ru_index=${ru_index}
    sleep   1s
    ${sudo}    csn.execute    command=which sudo    connection=RU
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    set test variable    ${cmd_ruSW}    ${sudo} SWmanShellCommand -i
    ${output_cmd_ruSW}    csn.execute    command=${cmd_ruSW}    connection=RU    timeout=60s
    ${pattern}   Set Variable    Current runningBuildName:(.*)
    @{ruSW_fromModule_temp}    Get Regexp Matches     ${output_cmd_ruSW}    ${pattern}    1
    ${ruSW_fromModule}    Fetch From Right   string=${ruSW_fromModule_temp}[0]    marker=${SPACE}
    ${ruSW_fromModule}    Strip string    ${ruSW_fromModule}
    run keyword and ignore error    csn.disconnect    connection=RU
    run keyword and ignore error    csn.disconnect    connection=ASIK Master
    [Return]    ${ruSW_fromModule}

Modify AUTONOMOUS Value In Json File
    [Arguments]    ${init_value}    ${target_value}    ${file_cmd}    ${ru_index}=1
    log to console    \n Modify AUTONOMOUS Value In Json File
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable
    ...    echo '/ca action fetch DECODED "hw_capabilities.bin" "/tmp/hw_capabilities.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  sed -i '111{s/"defaultValue": ${init_value},/"defaultValue": ${target_value},/g}' /tmp/hw_capabilities.json
    csn.send_command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${output}  csn.execute  command=cat /tmp/hw_capabilities.json| head -n 111 | tail -n +110   connection=RU_${ru_index}
    sleep    2s
    log to console    \n ${output}
    csn.Send command    command=${file_cmd} /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    sleep    2s
    ${output}  csn.execute  command=ls -l /mnt/runtime/runtime_config.txt   connection=RU_${ru_index}
    sleep    2s
    log to console    \n ${output}
    ${cmd}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "hw_capabilities.bin" "/tmp/hw_capabilities.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo "/ca action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep    120s
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'

Get RMOD Power Measurement
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${made2_status}    run keyword and return status     Should contain    ${ru_type_init}    AQQ
    ${cmd_temp}   set variable if    ${made2_status}   "/ action create PsuMeasurements /rf_psu /rf/psu"
    ...    "/ action create PsuMeasurements /CI/PsuMeasurements /module"
    ${cmd_temp2}   set variable if    ${made2_status}   "/rf_psu action measure"    "/CI/PsuMeasurements action measure"
    ${output}  csn.execute  command=echo ${cmd_temp}|${sudo} frmonShellClient 127.0.0.1 2000    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    ${power_measure}  Convert to number  0
    FOR   ${index}  IN RANGE  10
        ${output}   csn.execute  command=echo ${cmd_temp2}|${sudo} frmonShellClient 127.0.0.1 2000
        ...    connection=RU_${ru_index}
        Should Contain    ${output}    done ok
        @{measure}  Split string     ${output}
        ${power}    convert to number  ${measure[-3]}    2
        ${index}    Evaluate  ${index}+1
        ${power_measure}  Evaluate  ${power_measure}+${power}
        Sleep  5
    END
    ${average}   Evaluate   ${power_measure}/10
    ${power}   Convert to number   ${average}    0
    Builtin.log   \npower_average = ${power}     console=yes
    csn.disconnect    connection=RU_${ru_index}
    [Return]    ${power}
    [Teardown]    csn.disconnect    connection=ASIK Master

Modify Calibration File On RU Unit
    [Arguments]    ${current_name}    ${new_name}    ${ru_index}=1
    ${cd_cmd}   Set Variable    cd /mnt/factory/configs/unit;
    ${ru_ip_addr}    wait until keyword succeeds    5min    10s   Get RU IP Address    ru_index=${ru_index}
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    csn.send_command    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=ASIK Master
    sleep    2s
    csn.send_command    command=ssh -o StrictHostKeyChecking\=no ${ru_username}@${ru_ip_addr}    connection=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    sleep    2s
    #####20231211:remount RF file system to get read-write right, avoid fault--Read-only file system######
    log to console  \n***mount RF file for rw***
    csn.send_command    command=${sudo} mount -o remount,rw /mnt/factory
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.send_command    command=cd /rom/factory_backup;ls -l | grep calibration_dlpath1.bin | awk '{print $9}'
    ...    connection=RU_${ru_index}
    sleep    2s
    ${backup_result}    csn.read_output    connection=RU_${ru_index}
    ${backup_status}    Run Keyword And Return Status    should match regexp    ${backup_result}    calibration_dlpath1
    Run Keyword If    '${backup_status}' == 'True'    csn.send_command
    ...     command=cd /rom/factory_backup;rm -rf calibration_dlpath1*     connection=RU_${ru_index}
    sleep    2s
    csn.send_command    command=${cd_cmd}${sudo} ls -l | grep ${current_name}.bin | awk '{print $9}'     connection=RU_${ru_index}
    sleep    2s
    ${result}    csn.read_output    connection=RU_${ru_index}
    ${status}    Run Keyword And Return Status    should match regexp    ${result}    ${current_name}
    sleep    1s
    Run Keyword If    '${status}' == 'True'    csn.send_command
    ...     command=${cd_cmd}${sudo} mv ${current_name}.bin ${new_name}.bin     connection=RU_${ru_index}
    sleep    2s
    Run Keyword If    '${status}' == 'True'    csn.send_command
    ...     command=${cd_cmd}${sudo} mv ${current_name}.bin.md5 ${new_name}.bin.md5     connection=RU_${ru_index}
    sleep    2s
    #####20231211:remount RF file system to recovery read-only right######
    log to console  \n***remount RF file for ro***
    csn.send_command    command=${sudo} mount -o remount,ro /mnt/factory
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    Run Keyword If    '${status}' == 'True'    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    Run Keyword If    '${status}' == 'True'    sleep    900s
    [Teardown]    csn.disconnect    connection=ASIK Master

Modify fbMinThreshold_min Value In Json File
    [Arguments]    ${init_value}    ${target_value}    ${SnapshotTimeoutS}   ${new_timeout}   ${ru_index}=1
    log to console    \n Modify fbMinThreshold_min Value In Json File
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action fetch DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat /run/fault_logger.json | grep -i SnapshotTimeoutS
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  before Modify Snapshot timeout:${output}
    sleep    2s
    csn.Send command
    ...    command=${sudo} sed -i 's/"SnapshotTimeoutS": ${SnapshotTimeoutS},/"SnapshotTimeoutS": ${new_timeout},/' /run/fault_logger.json
    ...    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat /run/fault_logger.json | grep -i SnapshotTimeoutS
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  after Modify Snapshot timeout:${output}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable    echo '/ca action fetch DECODED "gc.bin" "/ram/gc.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat -n /ram/gc.json | grep -i fbMinThreshold_min
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  before Modify fbMinThreshold_min:\n ${output}
    sleep    2s
    csn.Send command
    ...    command=${sudo} sed -i 's/"fbMinThreshold_min": ${init_value},/"fbMinThreshold_min": ${target_value},/' /ram/gc.json
    ...    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat -n /ram/gc.json | grep -i fbMinThreshold_min
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  after Modify fbMinThreshold_min:\n ${output}
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat /ram/gc.json| head -n 66 | tail -n +65
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  before Modify enable:\n ${output}
    ${flag}    run keyword and return status     Should contain    ${output}    true
    ${enable_cmd}    set variable if      ${flag}==${true}    "enable": true,/"enable": false,
    ...    "enable": false,/"enable": true,
    sleep    2s
    csn.Send command
    ...    command=${sudo} sed -i '66{s/${enable_cmd}/g}' /ram/gc.json
    ...    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat /ram/gc.json| head -n 66 | tail -n +65
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  after Modify enable:\n ${output}
    sleep    2s
    ${cmd_temp}   Set Variable    echo '/ca action store PERMANENT DECODED "gc.bin" "/ram/gc.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ca action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Get Tdanger Value from Json File
    [Arguments]    ${ru_index}=1    ${tcs_parameter}=tcs   ${get_parameter}=Tdanger
    log to console    \n Get Tdanger Value from Json File
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp_base}    Set Variable   ${sudo} frmonShellClient 127.0.0.1 2000
    ${cmd_temp}   Set Variable
    ...   echo '/CI/ConfigAccess_Module action fetch DECODED "${tcs_parameter}.bin" "/var/tmp/${tcs_parameter}.json"'|${cmd_temp_base}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${output}  csn.execute  command=${sudo} cat /var/tmp/${tcs_parameter}.json | grep -i ${get_parameter}    connection=RU_${ru_index}
    ${pattern}   Set Variable    "${get_parameter}": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value}   Set Variable    ${init_value_list}[0]
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "${tcs_parameter}.bin" "/var/tmp/${tcs_parameter}.json"'|${cmd_temp_base}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    [Return]  ${init_value}

Get Tdanger Value from Json File in SBTS00
    [Arguments]    ${ru_index}=1
    log to console    \n Get Tdanger Value from Json File
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...   echo '/ca action fetch DECODED "tcs_parameters.bin" "/var/tmp/tcs_parameters.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${output}  csn.execute  command=${sudo} cat /var/tmp/tcs_parameters.json | grep -i Tdanger    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Tdanger": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value}   Set Variable    ${init_value_list}[0]
    ${cmd_temp}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "tcs_parameters.bin" "/var/tmp/tcs_parameters.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ca action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    [Return]  ${init_value}

Modify Tdanger Value In Json File
    [Arguments]    ${init_value}    ${target_value}    ${cmd}    ${ru_index}=1   ${tcs_parameter}=tcs
    ...   ${get_parameter}=Tdanger
    log to console    \n Modify Tdanger Value In Json File
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp_base}    Set Variable   ${sudo} frmonShellClient 127.0.0.1 2000
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...  echo '/CI/ConfigAccess_Module action fetch DECODED "${tcs_parameter}.bin" "/var/tmp/${tcs_parameter}.json"'|${cmd_temp_base}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.execute  command=cat /var/tmp/${tcs_parameter}.json | grep -i ${get_parameter}    connection=RU_${ru_index}
    ${modify_paramter_base}   Set Variable
    ...   sed -i 's/"${get_parameter}": ${init_value},/"${get_parameter}": ${target_value},/g' /var/tmp/${tcs_parameter}.json
    csn.Send command    command=${sudo} ${modify_paramter_base}   connection=RU_${ru_index}
    sleep    2s
    csn.execute    command=${sudo} cat /var/tmp/${tcs_parameter}.json | grep -i ${get_parameter}    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} ${cmd} /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "${tcs_parameter}.bin" "/var/tmp/${tcs_parameter}.json"'|${cmd_temp_base}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Create file in RU
    [Arguments]  ${log_name}=123.txt    ${ru_index}=1
    connect to common unit master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    csn.execute     cd /tmp;${sudo} touch ${log_name}    connection=RU_${ru_index}
    sleep  2
    ${output}    csn.execute    command=${sudo} ls -l /tmp/${log_name}    connection=RU_${ru_index}
    sleep  2
    Builtin.log    ${output}
    Should Not Contain      ${output}      No such file or directory
    [Teardown]  Run Keywords   Run Keyword And Ignore Error   csn.disconnect   connection=RU_${ru_index}  AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=Container   AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=ASIK Master

Check file Exist in RU
    [Arguments]  ${log_name}=123.txt    ${ru_index}=1
    connect to common unit master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${output}    csn.execute    command=${sudo} ls -l /tmp/${log_name}    connection=RU_${ru_index}
    sleep  2
    log to console    ${output}
    Should Not Contain      ${output}      No such file or directory
    [Teardown]  Run Keywords   Run Keyword And Ignore Error   csn.disconnect   connection=RU_${ru_index}  AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=Container   AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=ASIK Master

Connect to Ru and check if certificate exists
    [Arguments]    ${ru_index}=1
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd}   Set Variable  ls /etc/ssl/certs -l | grep "Nokia*"
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    csn.disconnect    connection=RU_${ru_index}
    Should Contain    ${output}    NokiaFactoryCA.pem
    Should Contain    ${output}    NokiaFactoryCA2067.pem
    Should Contain    ${output}    NokiaRootCA.pem
    Should Contain    ${output}    NokiaRootCA2067.pem
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIK Master

Check_Integrity_On_RU
    [Arguments]    ${ru_index}=1
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd}   Set Variable  sudo openssl x509 -in /etc/ssl/certs/NokiaRootCA.pem -text -noout
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    csn.disconnect    connection=RU_${ru_index}
    Should contain  ${output}  Signature Algorithm: sha256WithRSAEncryption
    Should contain  ${output}  Digital Signature, Certificate Sign, CRL Sign
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIK Master

Modify RU SnapshotTimeoutS
    [Arguments]    ${ru_index}=1    ${SnapshotTimeoutS}=43200    ${new_timeout}=240
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action fetch DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat /run/fault_logger.json | grep -i SnapshotTimeoutS
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  before Modify Snapshot timeout:${output}
    sleep    2s
    csn.Send command
    ...    command=${sudo} sed -i 's/"SnapshotTimeoutS": ${SnapshotTimeoutS},/"SnapshotTimeoutS": ${new_timeout},/' /run/fault_logger.json
    ...    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat /run/fault_logger.json | grep -i SnapshotTimeoutS
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  after Modify Snapshot timeout:${output}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ca action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Get SnapshotTimeoutS original value
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action fetch DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat /run/fault_logger.json | grep -i SnapshotTimeoutS
    ${output_value}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    ${pattern}   Set Variable    "SnapshotTimeoutS": (.*),
    ${original_value_list}    Get Regexp Matches     ${output_value}    ${pattern}    1
    ${original_value}   Set Variable    ${original_value_list}[0]
    log to console   \n original Snapshot timeout value:${original_value}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ca action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Return]    ${original_value}
    [Teardown]    csn.disconnect    connection=ASIK Master

Trigger Fault 1937
    [Arguments]   ${Tdanger_target}    ${Tdanger_init}=120   ${ru_index}=1   ${tcs_parameter}=tcs  ${TPro_if}=${False}
    ...   ${Tprot_init}=110   ${Tprot_target}=20
    log to console    \n Trigger Fault 1937
    Connect to gnb coam via ssl
    Modify Tdanger Value In Json File    init_value=${Tdanger_init}    target_value=${Tdanger_target}    cmd=touch    ru_index=${ru_index}
    ...    tcs_parameter=${tcs_parameter}
    Run Keyword If   ${TPro_if}   Modify Tdanger Value In Json File    init_value=${Tprot_init}    target_value=${Tprot_target}
    ...   cmd=touch    ru_index=${ru_index}
    ...   tcs_parameter=${tcs_parameter}   get_parameter=Tprot
    Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep    60s
    log to console   \n Check Fault 1937 Appear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1937
    log to console    \n Check Fault 1937 Exist in RawAlarmHistory
    Wait until keyword succeeds    5min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1937

Recovery Fault 1937
    [Arguments]   ${Tdanger_target}     ${Tdanger_trriger}=30.0   ${ru_index}=1   ${tcs_parameter}=tcs  ${TPro_if}=${False}
    ...    ${Tprot_init}=110   ${Tprot_target}=20
    log to console    \n Recovery Fault 1937
    Modify Tdanger Value In Json File    init_value=${Tdanger_trriger}    target_value=${Tdanger_target}    cmd=rm -rf    ru_index=${ru_index}
    ...    tcs_parameter=${tcs_parameter}
    Run Keyword If   ${TPro_if}   Modify Tdanger Value In Json File    init_value=${Tprot_init}    target_value=${Tprot_target}
    ...   cmd=rm -rf    ru_index=${ru_index}
    ...    tcs_parameter=${tcs_parameter}     get_parameter=Tprot
    Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep    60s
    log to console    \n Check Fault 1937 Disappear On WebEM
    Repeat Keyword    5 times    Expect Fault Should Absent    faultId=1937
    coam wait gnb and cells ready    timeout=10min    gnb_type='${gNb_CuType}'

Trigger Fault 1920 and 1907
    [Arguments]    ${init_value}    ${target_value}    ${SnapshotTimeoutS}   ${new_timeout}   ${ru_index}=1
    log to console    \n Trigger Fault 1920 and 1907
    Modify fbMinThreshold_min Value In Json File    init_value=${init_value}    target_value=${target_value}
    ...    SnapshotTimeoutS=${SnapshotTimeoutS}    new_timeout=${new_timeout}    ru_index=${ru_index}
    Perform RF Module Reset from GUI    ru_index=${ru_index}
    sleep    600s
    log to console   \n Check Fault 1920 Appear in RawAlarmHistory
    Wait until keyword succeeds    10min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1920
    log to console   \n Check Fault 1907 Appear in RawAlarmHistory
    Wait until keyword succeeds    10min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1907

Recovery Fault 1920 and 1907
    [Arguments]    ${init_value}    ${target_value}    ${SnapshotTimeoutS}   ${new_timeout}   ${ru_index}=1
    log to console    \n Recovery Fault 1920 and 1907
    Modify fbMinThreshold_min Value In Json File    init_value=${init_value}     target_value=${target_value}
    ...    SnapshotTimeoutS=${SnapshotTimeoutS}    new_timeout=${new_timeout}    ru_index=${ru_index}
    Perform RF Module Reset from GUI    ru_index=${ru_index}
    sleep    60min
    Wait until keyword succeeds    20 min    60 sec   verify all cells should be onair
    log to console    \n Check Fault 1920 and 1907 Disappear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1920
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1907

Check fault Exist in faultlog in RU
    [Arguments]    ${fault_filter}    ${ru_index}=1    ${ru_fault_log_path}=/mnt/runtime/fault-log/snapshot_status.txt
    ${ru_ip_addr}    wait until keyword succeeds    10min    10s   Get RU IP Address    ru_index=${ru_index}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    sleep    2s
    csn.send_command    command=${sudo} cat ${ru_fault_log_path}| grep ${fault_filter}    connection=RU_${ru_index}
    sleep    2s
    ${1247_alarms_string}    csn.read output    connection=RU_${ru_index}
    Should Contain    ${1247_alarms_string}    ${fault_filter}
    csn.send_command    command=${sudo} cat ${ru_fault_log_path}    connection=RU_${ru_index}
    sleep    2s
    ${ru_alarms_string}    csn.read output    connection=RU_${ru_index}
    csn.disconnect    connection=RU_${ru_index}
    [Return]    ${ru_alarms_string}

Modify Core Assembly File On RU Unit
    [Arguments]    ${modify_file}    ${tobak}=True    ${ru_index}=1
    log to console    \nModify Core Assembly File On RU Unit
    ${cd_cmd}   Set Variable    cd /mnt/factory/configs/unit;
    ${ru_ip_addr}    wait until keyword succeeds    5min    10s   Get RU IP Address    ru_index=${ru_index}
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${status}   Set Variable    True
    FOR  ${item}  IN  @{modify_file}
        ${current_name}   set variable if      '${tobak}' == 'True'    ${item}[current_name]    ${item}[new_name]
        ${new_name}   set variable if      '${tobak}' == 'True'    ${item}[new_name]    ${item}[current_name]
        csn.send_command    command=${cd_cmd}${sudo} ls -l | grep ${current_name} | awk '{print $9}'     connection=RU_${ru_index}
        ${result}    csn.read_output    connection=RU_${ru_index}
        ${status}    Run Keyword And Return Status    should match regexp    ${result}    ${current_name}
        Exit For Loop If  '${status}'=='False'
        Run Keyword If    '${status}' == 'True'    csn.send_command
        ...     command=${cd_cmd}${sudo} mv ${current_name} ${new_name}     connection=RU_${ru_index}
    END
    [Teardown]    csn.disconnect    connection=ASIK Master

RM Command To Trigger RU Reboot
    [Arguments]    ${ru_index}=1    ${cmd}=${None}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ResetControl /CI/resetControl/module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo "/CI/resetControl/module action reset "${cmd}|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    [Teardown]    csn.Reset Cache

Modify Tdanger Value In Json File with RU reset
    [Arguments]    ${init_value}    ${target_value}    ${cmd}    ${ru_index}=1
    log to console    \n Modify Tdanger Value In Json File
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    #${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    csn.Send command  command=${cmd_temp}    timeout=120s    connection=RU_${ru_index}
    sleep    2s
    ${output}    csn.Read Output    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/var/tmp/tcs.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    #${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    csn.Send command  command=${cmd_temp}    timeout=120s    connection=RU_${ru_index}
    sleep    2s
    ${output}    csn.Read Output    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.Send command  command=${sudo} cat /var/tmp/tcs.json | grep -i Tdanger    connection=RU_${ru_index}
    csn.Send command    command=${sudo} sed -i 's/"Tdanger": ${init_value},/"Tdanger": ${target_value},/g' /var/tmp/tcs.json
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} cat /var/tmp/tcs.json | grep -i Tdanger    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} ${cmd} /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs.bin" "/var/tmp/tcs.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    #${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    csn.Send command  command=${cmd_temp}    timeout=120s    connection=RU_${ru_index}
    sleep    2s
    ${output}    csn.Read Output    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    #${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    csn.Send command  command=${cmd_temp}    timeout=120s    connection=RU_${ru_index}
    sleep    2s
    ${output}    csn.Read Output    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    Perform RU Reset     ru_index=${ru_index}
    sleep    90s
    [Teardown]    csn.disconnect    connection=ASIK Master

Modify Tdanger Value In Json File with RU reset in SBTS00
    [Arguments]    ${init_value}    ${target_value}    ${cmd}    ${ru_index}=1
    log to console    \n Modify Tdanger Value In Json File
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    #${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    csn.Send command  command=${cmd_temp}    timeout=120s    connection=RU_${ru_index}
    sleep    2s
    ${output}    csn.Read Output    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action fetch DECODED "tcs_parameters.bin" "/var/tmp/tcs_parameters.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    #${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    csn.Send command  command=${cmd_temp}    timeout=120s    connection=RU_${ru_index}
    sleep    2s
    ${output}    csn.Read Output    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.Send command  command=${sudo} cat /var/tmp/tcs_parameters.json | grep -i Tdanger    connection=RU_${ru_index}
    csn.Send command    command=${sudo} sed -i 's/"Tdanger": ${init_value},/"Tdanger": ${target_value},/g' /var/tmp/tcs_parameters.json
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} cat /var/tmp/tcs_parameters.json | grep -i Tdanger    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} ${cmd} /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    ${cmd_temp}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "tcs_parameters.bin" "/var/tmp/tcs_parameters.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    #${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    csn.Send command  command=${cmd_temp}    timeout=120s    connection=RU_${ru_index}
    sleep    2s
    ${output}    csn.Read Output    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ca action update"|${sudo} frmonShellClient 127.0.0.1 2000
    #${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    csn.Send command  command=${cmd_temp}    timeout=120s    connection=RU_${ru_index}
    sleep    2s
    ${output}    csn.Read Output    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    Perform RU Reset     ru_index=${ru_index}
    sleep    90s
    [Teardown]    csn.disconnect    connection=ASIK Master

Check PtpState in startup default log
    [Arguments]    ${ru_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}  ${pre_log_num}=${pre_log_num}    ${clks_num}=${clks_num}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${rfsw_log_path_on_ru}   Capture RFSW Log On RU    connection=RU_${ru_index}
    ${rfsw_log_path_on_testPC}    Download RU File To TestPC    ru_file_path=${rfsw_log_path_on_ru}
    ...                                                         connection=RU_${ru_index}
    ...                                                         download_dir=${download_dir}
    ${full_ru_file_name}    Set Variable    ${rfsw_log_path_on_ru.split('/')}[-1]
    ${ru_file_name}    Set Variable    ${full_ru_file_name.split('.')}[-2]
    ${clks_file}    Set Variable    ${pre_log_num}_frozenFrame_Coco_clks${clks_num}.log
    Run  unzip ${download_dir}/${ru_file_name}.zip -d ${download_dir}/${ru_file_name}
    Run  unzip ${download_dir}/${ru_file_name}/${pre_log_num}_startup.zip -d ${download_dir}/${ru_file_name}/${pre_log_num}_startup
    Run  unxz ${download_dir}/${ru_file_name}/${pre_log_num}_startup/startup_DEFAULT.log.xz
    ${start_up_path}    Set Variable    ${download_dir}startup_DEFAULT.log
    ${clks_path}    Set Variable    ${download_dir}${pre_log_num}_frozenFrame_Coco_clks${clks_num}.log
    Run  scp ${download_dir}/${ru_file_name}/${pre_log_num}_startup/startup_DEFAULT.log ${start_up_path}
    Run  scp ${download_dir}/${ru_file_name}/${pre_log_num}_frozenFrame_Coco_clks${clks_num}.log ${clks_path}
    Run  rm -rf ${download_dir}/${ru_file_name}
    Run  cd ${download_dir};cat startup_DEFAULT.log | grep LINUX-0-clk::s${clks_num} > clkstartup.log
    ${clkstartup_path}    Set Variable    ${download_dir}clkstartup.log
    ${PtpLockState_result}    OperatingSystem.Run    cd ${download_dir};cat clkstartup.log | grep PtpLockState::
    Should Contain   ${PtpLockState_result}    PtpLockState::LOCKED=1
    Should Contain   ${PtpLockState_result}    PtpLockState::LOCKED_HOLDOVER=2
    Should Contain   ${PtpLockState_result}    PtpLockState::UNLOCKED=0
    [Return]  ${clkstartup_path}    ${clks_path}

operate interface in ru
    [Arguments]    ${ru_index}=1    ${interface}=eth2.s0.m0.1    ${operate}=down
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    csn.Send command  command=${sudo} ifconfig ${interface} ${operate}    connection=RU_${ru_index}
    sleep    2s
    [Teardown]    csn.Reset Cache

get ru gateway interface
    [Arguments]    ${ru_index}=1    ${grep}=UGH
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${output}  csn.execute  command=route |grep ${grep}|head -1|awk '{print $8}'    connection=RU_${ru_index}
    ${output}    Replace String    ${output}    \r\n    ${EMPTY}
    sleep    2s
    [Return]    ${output}
    [Teardown]    csn.Reset Cache

add nft table udp_table0 in ru
    [Arguments]    ${ru_index}=1    ${saddr}=20.1.1.2    ${daddr}=20.1.1.1    ${dport}=3784
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    csn.Send command  command=${sudo} nft add table udp_table0    connection=RU_${ru_index}
    sleep    2s
    csn.Send command  command=${sudo} nft 'add chain ip udp_table0 ch0_input { type filter hook input priority 0 ; policy accept; }'
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.Send command  command=${sudo} nft add rule udp_table0 ch0_input ip saddr ${saddr} ip daddr ${daddr} udp dport ${dport} drop
    ...    connection=RU_${ru_index}
    sleep    2s
    [Teardown]    csn.Reset Cache

delete nft table udp_table0 in ru
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    csn.Send command  command=${sudo} nft flush chain udp_table0 ch0_input    connection=RU_${ru_index}
    sleep    2s
    csn.Send command  command=${sudo} nft delete table udp_table0    connection=RU_${ru_index}
    sleep    2s
    [Teardown]    csn.Reset Cache

Get RU IP AND Check Pingable
    [Arguments]    ${ru_index}    ${asik_alias}=ASIK Master
    Connect to Common Unit Master  alias=${asik_alias}
    ${ip}=            ssh.execute    command=lxc-attach -n 0x1018 -- cat /ffs/run/config/FRIps.txt | cut -d";" -f3 | sed -n '${ru_index}p'
    ...                              connection=${asik_alias}
    ${ip}=    Split String    ${ip}    \r\n
    ${output}=    ssh.execute    command=lxc-attach -n 0x1018 -- ping -c 30 -W 10 ${ip[0]}    connection=${asik_alias}
    Should contain    ${output}    30 packets transmitted, 30 received
    ssh.disconnect                   connection=${asik_alias}

Get RU Beamforming Count Enhance
    [Arguments]  ${ru_index}=1    ${get_count}=${False}    ${connection}=GNB_OAM    ${check_time}=15
    Connect to Common Unit Master
    ${bfcali_flag}    set variable    ${True}
    ${actBeamforming}    Check Activate Beamforming for RU Enhance   ru_index=${ru_index}    connection=${connection}
    run keyword if    not ${actBeamforming}
    ...    Log to console    \nRU_${ru_index} activate beamforming is false, no need to check beamforming calibration
    return from keyword if    not ${actBeamforming}    ${None}    ${None}
    ${radio_protocol}    get_radio_protocal_via_admin    ru_index=${ru_index}    connection=${connection}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    connection=${connection}
    ${tx_num}    ${rx_num}    ${time}    Check ECPRI RU Beamforming Enhance    ru_alais=RU_${ru_index}
    ...    get_count=${get_count}
    csn.execute    command=sudo bfcali -forceStart    connection=RU_${ru_index}
    sleep    30s
    ${tx_num_force}    ${rx_num_force}    ${time_force}    Check ECPRI RU Beamforming Enhance    ru_alais=RU_${ru_index}
    ...    get_count=${get_count}
    should be true    ${tx_num_force}>${tx_num}
    should be true    ${rx_num_force}>${rx_num}
    ${time_diff}=  Subtract Date From Date    ${time_force}    ${time}
    should be true    ${time_diff}>0
    sleep    ${check_time}min
    ${tx_num_wait}    ${rx_num_wait}    ${time_wait}    Check ECPRI RU Beamforming Enhance    ru_alais=RU_${ru_index}
    ...    get_count=${get_count}
    should be true    ${tx_num_wait}>${tx_num_force}
    should be true    ${rx_num_wait}>${rx_num_force}
    ${time_diff_wait}=  Subtract Date From Date    ${time_wait}    ${time_force}
    should be true    ${time_diff_wait}>0
    csn.execute    command=sudo bfcali -stop    connection=RU_${ru_index}
    sleep    ${check_time}min
    ${tx_num_stop}    ${rx_num_stop}    ${time_stop}    Check ECPRI RU Beamforming Enhance    ru_alais=RU_${ru_index}
    ...    get_count=${get_count}
    Should Be Equal    ${tx_num_stop}  ${tx_num_wait}
    Should Be Equal    ${rx_num_stop}  ${rx_num_wait}
    ${time_diff_stop}=  Subtract Date From Date    ${time_stop}    ${time_wait}
    ${time_diff_stop}    convert to string    ${time_diff_stop}
    Should be Equal As Strings    ${time_diff_stop}  0.0
    csn.execute    command=sudo bfcali -forceStart    connection=RU_${ru_index}
    sleep    30s
    ${tx_num_force_2}    ${rx_num_force_2}    ${time_force_2}    Check ECPRI RU Beamforming Enhance
    ...    ru_alais=RU_${ru_index}    get_count=${get_count}
    should be true    ${tx_num_force_2}>${tx_num_stop}
    should be true    ${rx_num_force_2}>${rx_num_stop}
    ${time_diff_force_2}=  Subtract Date From Date    ${time_force_2}    ${time_stop}
    should be true    ${time_diff_force_2}>0
    csn.Disconnect  connection=RU_${ru_index}
    [Return]    ${tx_num}    ${rx_num}    ${time}
    [Teardown]    csn.Disconnect  connection=ASIK Master

Download Soap and Check Ru Lock Unlock Message
    [Arguments]  ${type}=lock    ${ru_index}=1
    connect to common unit master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
    Connect to gnb coam via ssl
    ${ru_type}    get ru type    ru_index=${ru_index}
    run keyword if    '${type}'=='lock'    Check SOAP message_RU_lock    PC_soap_path=${PC_soap_path}
    ...       ELSE    Check SOAP message_RU_unlock    PC_soap_path=${PC_soap_path}
    [Teardown]  run keywords  csn.disconnect   connection=RU_${ru_index}    AND
    ...    csn.Disconnect   connection=ASIK Master

check RU registration info
    [Arguments]    ${TargetBD_FileName}  ${ru_index}=1  ${radio_type}=${ru_type_init}
    ${ru_type}  Get RU type  ru_index=${ru_index}
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=RegistRU
    sleep   2s
    csn.send command    command=cd /ffs/run/;grep -o ${radio_type} /ffs/run/${TargetBD_FileName}|wc -l    connection=RegistRU
    ${output_grep}=    csn.read output    connection=RegistRU
    ${output_grep}=    convert to integer    ${output_grep}
    should be true    ${output_grep}>=4
    csn.send command    command=cd /ffs/run/;find /ffs/run/${TargetBD_FileName}|xargs grep ${ru_type}    connection=RegistRU
    ${regist_info}=    csn.read output    connection=RegistRU
    csn.disconnect    connection=RegistRU
    [Return]    ${regist_info}

Get RU Reset Cause
    [Arguments]    ${snapshot_path}    ${runtime_name}    ${snapshot_unzip_path}=${None}    ${expected_cause}={None}
    log to console    ${snapshot_unzip_path}
    ${info}    get_ru_reset_cause_from_snapshot    snapshot_log_path=${snapshot_path}    runtime_name=${runtime_name}
    ${result}=    run keyword if    "${info}"=="${expected_cause}"    set variable    1
    ...           ELSE    set variable    0
    [Return]    ${result}

Download soap Log from RU
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Download soap Log from RU
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]    ${ru_alias}=RU    ${sub_dir}=*
    log to console  \n**Download soap Log from RU ***
    ${local_path}    Wait Until Keyword Succeeds   3x   10s    getsoapfile    connection=${ru_alias}    subdir=${sub_dir}
    [Return]    ${local_path}

check RU config
    [Arguments]    ${ru_index_list}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to all rus with allocated IP
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        ${productCode_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep productCode
        ...    | sed -n '1p' | awk -F'productCode>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_productCode_cmd_catSOAP}    run    command=${productCode_cmd_cat}
        ${serialNum_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep serialNum |
        ...    sed -n '1p' | awk -F'serialNum>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_serialNum_cmd_catSOAP}    run    command=${serialNum_cmd_cat}
        ${bldName_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep bldName |
        ...    sed -n '1p' | awk -F'bldName>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_bldName_cmd_catSOAP}    run    command=${bldName_cmd_cat}
        log to console    \n***Check RF config from webui***
        ${active_version}     coam.get_sw_version    connection=GNB_OAM
        Selenium Login And Disable Screen Lock
        ${radio_type}    get ru type  ru_index=${ru_index}
        ${Radio_Protocol_Type}  Get Radio Protocol
        ${ruSW_expect}=    get RFSW version from TargetBD    radio_type=${radio_type}   Radio_Protocol_Type=${Radio_Protocol_Type}
        ...    active_version=${active_version}
        ${pCode_webui}  ${pName_webui}  ${pName_webui}  ${serNum_webui}  ${hwVer_webui}  ${nrBand_webui}
        ...    ${ruSW_webui}  get RF configuration from webui  ru_index=${ru_index}
        Should Be Equal As Strings    ${output_productCode_cmd_catSOAP}    ${pCode_webui}
        Should Be Equal As Strings    ${output_serialNum_cmd_catSOAP}    ${serNum_webui}
        Should Be Equal As Strings    ${output_bldName_cmd_catSOAP}    ${ruSW_expect}
    END
    [Teardown]    Selenium Logout And Close Browser

get RF configuration from webui
    [Arguments]  ${ru_index}=1
    log to console    \n get RF configuration from webui
    ${output_ru}      selenium_coam.get_ru_info    ru_index=${ru_index}
    log to console    ${output_ru}
    ${get_cell_from_ru}    Get All Cell Id    ru_index=${ru_index}
    ${output_cell}    selenium_coam.get_cell_info    ${get_cell_from_ru[0]}
    &{rmodInfo_webui}    selenium_coam.get_hw_parameters     hw_type=RMOD    ###index=1
    ${pCode_webui}     set variable      ${output_ru}[Product code]    # 474877A.X21
    ${pName_webui}     set variable      ${output_ru}[Product name]    # AWHQG
    ${serNum_webui}    set variable      ${output_ru}[Serial number]   # EB193764266
    ${hwVer_webui}     set variable      ${output_ru}[HW version]      # X21
    ${nrBand_webui}    set variable      ${output_cell}[Band]          # n78
    ${runtimeParam_ru}     set variable    ${rmodInfo_webui}[Runtime parameters]
    ${ruSW_webui}          set variable    ${runtimeParam_ru}[RU active SW version]    # MRM69.11.R03
    [Return]  ${pCode_webui}  ${pName_webui}  ${pName_webui}  ${serNum_webui}  ${hwVer_webui}  ${nrBand_webui}  ${ruSW_webui}

Get Radio Protocol
    [Arguments]  ${ru_index}=1
    &{Distname_dict}     Get distname for RMOD_R
    ${distname_RMOD_R}=    get from dictionary   ${Distname_dict}    ${ru_index}
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=${distname_RMOD_R}
    ...    filter_param=L3 Protocol
    ...    abbr=l3Protocol
    ${Radio_Protocol_Type}    set variable if      '${currect_status}' == 'CPRI_RP1'    CPRI    ECPRI
    [Return]   ${Radio_Protocol_Type}

Lock and Unlock all RUs
    [Arguments]  ${lock_list}
    log to console  \n***Lock ${lock_list} and check status***
    Lock all RUs and check status  ru_index_list=${lock_list}  check_alarm=${True}  gnb_type='${gNb_CuType}'
    #WA for RU locking with DEESLEEP MODE enabled; aims to avoid misoperation with RU transient state 'locked+AWAKE'
    log to console  \n***sleep 5 min and then perform RU unlock***
    Sleep   5min
    log to console  \n***unLock ${lock_list} and check status***
    Unlock all RUs and check status  ru_index_list=${lock_list}  check_alarm=${True}  gnb_type='${gNb_CuType}'

Lock all RUs and check status
    [Arguments]    ${ru_index_list}  ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    log to console  \n***Lock RUs ${ru_index_list} and check status ***
    ${status}    run keyword and return status    variable should not exist    ${check_ru_details}
    ${check_ru_details}    run keyword if    ${status}    create dictionary
    ...    ELSE    set variable    ${check_ru_details}
    set test variable    ${check_ru_details}
    connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${status}    run keyword and return status    Create file in RU    ru_index=${ru_index}
        ${check_details}    create dictionary    with_file=${status}
        set to dictionary    ${check_ru_details}    ${ru_index}=${check_details}
        selenium_coam.lock_ru  ru_index=${ru_index}
        sleep    30s
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}    connection=${connection}
    END
    ${sleep_time}       Evaluate    ${X2_link_shutdown_time}-1
    run keyword if  ${check_alarm}==${True} and ${gNB_type}!='SA'    run keywords
    ...    Expect Fault Should Absent    faultId=7300    AND
    ...    sleep    ${sleep_time}min    AND
    ...    Wait until keyword succeeds  2min  20sec  Expect Fault Should Present    faultId=7300    connection=${connection}
Unlock all RUs and check status
    [Arguments]      ${ru_index_list}  ${check_alarm}=${True}    ${gnb_type}='NSA'   ${timeout}=300   ${connection}=GNB_OAM
    log to console  \n***Unlock ${ru_index_list} RUs and check status ***
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${status}    run keyword and return status    RU Status Info Should Be as Expect    ru_index=${ru_index}    powerState=SLEEP
        set to dictionary    ${check_ru_details}[${ru_index}]    allowed_reset=${status}
        run keyword if    ${status}    set to dictionary    ${check_ru_details}[${ru_index}]    with_file=${False}
        selenium_coam.unlock_ru   ru_index=${ru_index}   timeout=${timeout}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${check_ru}    set variable    ${check_ru_details['${ru_index}']['allowed_reset']}
        run keyword if    ${check_ru}
        ...    Wait until keyword succeeds    10min    10sec    RU Should Be Online    ru_index=${ru_index}    connection=${connection}
        ...    ELSE    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}    connection=${connection}
        ${check_start_time}    Run Keyword If    ${check_ru}    Btslog Get Check Start time
        Run Keyword If    '${check_start_time}'!='${None}'    run keyword and continue on failure
        ...    Btslog Check RU Reset no More than Once    check_start_time=${check_start_time}    ru_index=${ru_index}
        ${status}    run keyword and return status    Check file Exist in RU    ru_index=${ru_index}
        should be equal as strings    ${status}    ${check_ru_details['${ru_index}']['with_file']}
    END
    run keyword if  ${check_alarm}==${True} and ${gNB_type}!='SA'
    ...  Wait until keyword succeeds  5min  20sec  Expect Fault Should Absent    faultId=7300    connection=${connection}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    connection=${connection}

Check RF Startup and Gnb Status
    [Arguments]  ${ru_index_list}    ${gnb_index}=${0}     ${connection}=GNB_OAM
    log to console    \n***Check RF Startup and Gnb Status***
    connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${result}    get release flag    connection=${connection}
    ${led_status}       set variable if      ${result}    Online    Enabled
    ${fsm_id_list}   Get All FSM Id    connection=${connection}
    FOR  ${fsm}  IN    @{fsm_id_list}
        ${led_ASIK}    run keyword and ignore error       Check Given ASIK Led State    asik=${fsm}
        should be equal   ${led_ASIK[1]}   ${led_status}
    END
    ${fbb_id_list}   Get All FBB Id    connection=${connection}
    FOR  ${fbb}  IN    @{fbb_id_list}
        ${led_FBB}    run keyword and ignore error       Check Given ABIL Led State   abil=${fbb}
        should be equal   ${led_FBB[1]}   ${led_status}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${led_RU}    run keyword and ignore error       Check Given RU Led State    ru=${ru_index}
        should be equal   ${led_RU[1]}   ${led_status}
    END

Check fault Exist in RU and snapshot
    [Arguments]  ${ru_index}=1    ${fault_filter}=1168    ${ru_fault_log_path}=/mnt/fault-log/snapshot_status.txt
    ...   ${RF7}=${False}
    log to console    \n Check fault Exist in RU and snapshot
    ${ru_alarms_string}    Wait until keyword succeeds    5min   30s    Check fault Exist in faultlog in RU
    ...    fault_filter=${fault_filter}   ru_index=${ru_index}   ru_fault_log_path=${ru_fault_log_path}
    ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
    ${snapshot_alarms_string}    Run Keyword If  not ${RF7}   Extract fault logs from snapshot
    ...    snapshot_file=${snapshot_file_path}    fault_id=${fault_filter}
    ...   ELSE   Extract fault logs from snapshot RF7   snapshot_file=${snapshot_file_path}    fault_id=${fault_filter}  ru_index=${ru_index}
    should be equal as strings    ${ru_alarms_string}    ${snapshot_alarms_string}

Lock all RUs and check all status
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Lock all RUs and check all status
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]  ${ru_index_list}    ${cell_list}    ${ue_num}    ${gnb_type}='${gNb_CuType}'
    ...    ${check_alarm}=${True}    ${with_call}=${True}    ${4G_check}=${False}    ${special_ru}=AVQL
    log to console  \n**Lock all RUs and check all status***
    ${led_status_list_lock}    create list    YELLOW YELLOW
    ${cell_list_new}    samelist    ${cell_list}
    ${ru_index_type_mapping}    Get All RU Type Mapping Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Create file in RU    ru_index=${ru_index}
        Collect RF Logs To TestPC    log_name=before_ru${ru_index}_lock    ru_index=${ru_index}
        ${status}    run keyword and return status    Should Be Equal    ${ru_index_type_mapping['${ru_index}']}    ${special_ru}
        ${mathes}    ${new_timestamp}    Run Keyword If    '${status}'=='${False}'    Get Last LED Timestamp and Status
        ...    log_name=before_ru${ru_index}_lock
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        Run Keyword If    '${status}'=='${False}'    Check LED Status In RU Log    led_status_list=${led_status_list_lock}
        ...    log_name=after_ru${ru_index}_lock    ru_index=${ru_index}
        ...    timestamp=${new_timestamp}    exclude_led_status=GREEN GREEN
        Download Soap and Check Ru Lock Unlock Message    type=lock    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
        ${flag}    ${cell_list_new}    getusefulid    ${cell_id_ru}    ${cell_list_new}
        sort list    ${cell_list_new}
        run keyword if    ${flag}==1 and ${gnb_type}=='NSA' and ${with_call}   start traffic all cells nsa
        ...    cell_list=${cell_list_new}    4G_check=${4G_check}
        run keyword if    ${flag}==1 and ${gnb_type}=='SA' and ${with_call}    start traffic all cells sa
        ...    cell_list=${cell_list_new}    ue_num=${ue_num}    4G_check=${4G_check}
    END
    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_list}
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'    sleep    ${X2_link_shutdown_time}min
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...    Wait until keyword succeeds    2min    20sec    Expect Fault Should Present    faultId=7300

UnLock all RUs and check all status
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] UnLock all RUs and check all status
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]  ${start_time}    ${ru_index_list}    ${cell_list}    ${ue_num}    ${gnb_type}='${gNb_CuType}'
    ...   ${check_alarm}=${True}    ${with_call}=${True}    ${4G_check}=${False}    ${special_ru}=AVQL
    log to console  \n**UnLock all RUs and check all status***
    log to console   start_time is ${start_time}
    ${ru_index_type_mapping}    Get All RU Type Mapping Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Collect RF Logs To TestPC    log_name=before_ru${ru_index}_unlock    ru_index=${ru_index}
        ${status_compare}    run keyword and return status    Should Be Equal    ${ru_index_type_mapping['${ru_index}']}    ${special_ru}
        ${mathes}    ${new_timestamp}    Run Keyword If    '${status_compare}'=='${False}'    Get Last LED Timestamp and Status
        ...    log_name=before_ru${ru_index}_unlock
        ${power_state}    Get RU Power State    ru_index=${ru_index}
        ${led_status_list}    run keyword if    '${power_state}'!='SLEEP'    create list   GREEN GREEN    ELSE
        ...    create list    YELLOW OFF  GREEN GREEN
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        Run Keyword If  ${status}==${False} and '${status_compare}'=='${False}'    Check LED Status In RU Log
        ...    led_status_list=${led_status_list}    log_name=after_ru${ru_index}_unlock
        ...    ru_index=${ru_index}    timestamp=${new_timestamp}    exclude_led_status=YELLOW YELLOW
        Download Soap and Check Ru Lock Unlock Message    type=unlock    ru_index=${ru_index}
        Run Keyword If  ${status}==${False} and '${power_state}'!='SLEEP'    Check file Exist in RU    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
        run keyword if    ${gnb_type}=='NSA' and ${with_call}    start traffic all cells nsa    cell_list=${cell_id_ru}   4G_check=${4G_check}
        run keyword if    ${gnb_type}=='SA' and ${with_call}     start traffic all cells sa     cell_list=${cell_id_ru}
        ...    ue_num=${ue_num}    4G_check=${4G_check}
    END
    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_list}
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...  Wait until keyword succeeds  5min  20sec  Expect Fault Should Absent    faultId=7300

Collect RF Logs To TestPC
    [Arguments]  ${log_name}=ru_log  ${ru_index}=1  ${asik_alias}=ASIK Master  ${log_path}=${TS_CASE_LOG_PATH}
    ${ru_log_name}    set variable    ${log_name}.zip
    Connect to Common Unit Master  alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
    FOR  ${i}    IN RANGE    3
        csn.execute     cd /usr/bin;ccsShell.sh log -a -c full -z /ram/${log_name}.zip    connection=RU_${ru_index}    timeout=900
        sleep  15
        ${output_log}    csn.execute    ls /ram/ |grep -i ${log_name}.zip    connection=RU_${ru_index}
        ${output_log}    replace string    ${output_log}    \r\n    ${EMPTY}
        ${status_log}    run keyword and return status    should contain    ${output_log}    ${log_name}.zip
        Exit For Loop if    ${status_log}==True
    END
    &{ru_info}    COAM get ru detial info by ru index   connection=GNB_OAM
    ${ru_ip_addr}   Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=GNB_OAM
    Wait until keyword succeeds    5 min    20 sec    csn.download file    remote_path=/ram/${log_name}.zip
    ...    local_path=${log_path}/${log_name}.zip   connection=RU_${ru_index}
    [Teardown]  Run Keywords   Run Keyword And Ignore Error   csn.disconnect   connection=RU_${ru_index}  AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=Container   AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=${asik_alias}

Check RF config from webui
    [Arguments]  ${ru_index}=1
    log to console    \n***Check RF config from webui***
    ${radio_type}    get ru type  ru_index=${ru_index}
    ${Radio_Protocol_Type}  Get Radio Protocol
    ${active_version}     coam.get_sw_version    connection=GNB_OAM
    ${ruSW_expect}    get RFSW version from TargetBD    radio_type=${radio_type}   Radio_Protocol_Type=${Radio_Protocol_Type}
    ...    active_version=${active_version}
    #get RF SW from RF module
    log to console    \nget RF SW from RF module
    ${ru_ip}    get ru ip address  ru_index=${ru_index}
    ${ruSW_fromModule}=    get RFSW version from radio module    ru_index=${ru_index}
    ${pCode_webui}  ${pName_webui}  ${pName_webui}  ${serNum_webui}  ${hwVer_webui}  ${nrBand_webui}
    ...    ${ruSW_webui}  get RF configuration from webui  ru_index=${ru_index}
    ${pCode_oam}  ${pName_oam}  ${serNum_oam}  ${hwVer_oam}  get RF configuration from M-Plane (OAM)  ru_index=${ru_index}
    ${prodCode_expect}  ${pName_expect}  ${NRFreqBand_expect}  get RF configuration from spec  ru_index=${ru_index}
    #compare RF configuration
    log to console    \ncompare RF configuration
    should be true    '${ruSW_fromModule}'=='${ruSW_webui}' and '${ruSW_webui}'=='${ruSW_expect}'
    should be true    '${serNum_webui}'=='${serNum_oam}'
    should be true    '${hwVer_webui}'=='${hwVer_oam}'
    should be true    '${pCode_webui}'=='${pCode_oam}' and '${pCode_oam}'=='${prodCode_expect}.${hwVer_webui}'
    should be true    '${pName_webui}'=='${pName_oam}' and '${pName_oam}'=='${pName_expect}'
    List Should Contain Value    ${NRFreqBand_expect}    ${nrBand_webui}

verify content of TargetBD file
    [Arguments]  ${ru_index}=1  ${radio_type}=${ru_type_init}
    log to console    \n***verify content of TargetBD file***
    ${active_version}     coam.get_sw_version    connection=GNB_OAM
    ${TargetBD_FileName}   ${save_path}    check TargetBD exist and match    active_version=${active_version}
    ${regist_info}    check RU registration info    ${TargetBD_FileName}    ru_index=${ru_index}    radio_type=${radio_type}

Action After Stability Case Failed
    [Arguments]  ${target_dir}    ${time}    ${connection}=GNB_OAM    ${common_setup_each_time}=${False}    ${gnb_index}=0
    log to console    ${common_setup_each_time}
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d_%H-%M-%S
    ${snapshot_name}   Set Variable  Snapshot_${time_stamp}_Time${time}
    connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${ru_index_list}  Get All RU Index    connection=${connection}
    Log to console    \n Start to Collect RU logs
    Connect to Common Unit Master    gnb_index=${gnb_index}
    ${ru_index_list_num}    Get Length    ${ru_index_list}
    ${ru_index_list_num_TLconfigiration}    Get Length    ${tl.gnbs[${gnb_index}].dus[0].rus}
    should be equal    ${ru_index_list_num}    ${ru_index_list_num_TLconfigiration}
    ...   msg=ru number mismatch between site and ini.txt
    FOR  ${ru_index}  IN  @{ru_index_list}
        run keyword and ignore error    Collect RF Logs To TestPC   ru_index=${ru_index}   log_name=rulog_${ru_index}_time${time}
    END
    Log to console    \n Start to Collect Snapshot
    run keyword and ignore error  Save Coam Snapshot   target_dir=${target_dir}    timeout=1800
    ${fsm_status}  ${fsm_name}    Coam Get FSM operationalState and Name    connection=${connection}
    ${fbb_status}  ${fbb_name}    Coam Get FBB operationalState and Name    connection=${connection}
    ${fsm_status}  run keyword and return status  should contain  ${fsm_status}  Disabled
    ${fbb_status}  run keyword and return status  should contain  ${fbb_status}  Disabled
    FOR  ${ru_index}  IN  @{ru_index_list}
       ${ru_status}  run keyword and return status  ru should be offline  ru_index=${ru_index}
       run keyword if  ${ru_status}   perform ru power reset  ru_index=${ru_index}
    END
    run keyword if  ${fsm_status} or ${fbb_status}   perform site power reset
    COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'

Check LED Status In RU Log
    [Arguments]  ${led_status_list}  ${log_name}=RU_log    ${ru_index}=1  ${timestamp}=${None}  ${exclude_led_status}=GREEN GREEN
    log to console    \n***Check LED Status In RU Log***
    Collect RF Logs To TestPC    log_name=${log_name}    ru_index=${ru_index}
    ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=${log_name}    timestamp=${timestamp}
    check LED list    matches=${mathes}    led_status_list=${led_status_list}    exclude_led_status=${exclude_led_status}
    [Return]  ${new_timestamp}

Verify SOAP RP1
    [Arguments]  ${ru_index}=1  ${ru_type}=${ru_type_init}
    log to console  \n*** Verify SOAP RP1 ***
    Enable capture soap msg flag on RU    ru_alias=RU_${ru_index}
    sleep  20s
    ${soap_log_path}    Download soap msg from RU    ru_alias=RU_${ru_index}    log_path=${SAVE LOG DIRECTORY}
    Connect to gnb coam via ssl
    ${radio_protocol}    get_radio_protocal_via_admin    ru_index=${ru_index}
    &{soap_info}    Get Detail Info In SOAP Message    Soap_log_path=${soap_log_path}
    ${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
    ${ru_target_build}    COAM get expected ru sw version from target BD file    ru_resource_build_key=LTX_${ru_type}
    Should Be Equal As Strings    ${soap_info['productCode']}    ${ru_info['productCode']}
    Should Be Equal As Strings    ${soap_info['serialNum']}    ${ru_info['serialNumber']}
    Should Be Equal As Strings    ${soap_info['moduleType']}    RRH
    ${soap_interfaceType}    convert to uppercase    ${soap_info['interfaceType']}
    Should Be Equal As Strings    ${soap_interfaceType}    ${radio_protocol}
    Should Be Equal As Strings    ${soap_info['bldName']}    ${ru_target_build}
    Should Contain    ${soap_info['bldVersion']}    ${ru_target_build}

Get T_sym_blank Value from Json File
    [Arguments]    ${ru_index}=1  ${key_word_T_sym_blank_off}=T_sym_blank_off  ${key_word_T_sym_blank_on}=T_sym_blank_on
    ...    ${key_word_T_sym_blank_timer}=T_sym_blank_timer   ${tcs_parameter}=tcs
    log to console    \n Get T_sym_blank Value from Json File
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp_base}    Set Variable   ${sudo} frmonShellClient 127.0.0.1 2000
    ${cmd_temp}   Set Variable
    ...   echo '/CI/ConfigAccess_Module action fetch DECODED "${tcs_parameter}.bin" "/var/tmp/${tcs_parameter}.json"'|${cmd_temp_base}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cat_tcs_parameter}    Set Variable    ${sudo} cat /var/tmp/${tcs_parameter}.json
    ${blank_off_output}  csn.execute  command=${cat_tcs_parameter} | grep -i ${key_word_T_sym_blank_off}    connection=RU_${ru_index}
    ${pattern}   Set Variable    "T_sym_blank_off": (.*),
    ${blank_off_init_value_list}    Get Regexp Matches     ${blank_off_output}    ${pattern}    1
    ${blank_off_init_value}   Set Variable    ${blank_off_init_value_list}[0]
    ${blank_on_output}  csn.execute  command=${cat_tcs_parameter} | grep -i ${key_word_T_sym_blank_on}    connection=RU_${ru_index}
    ${pattern}   Set Variable    "T_sym_blank_on": (.*),
    ${blank_on_init_value_list}    Get Regexp Matches     ${blank_on_output}    ${pattern}    1
    ${blank_on_init_value}   Set Variable    ${blank_on_init_value_list}[0]
    ${blank_timer_output}  csn.execute  command=${cat_tcs_parameter} | grep -i ${key_word_T_sym_blank_timer}    connection=RU_${ru_index}
    ${pattern}   Set Variable    "T_sym_blank_timer": (.*),
    ${blank_timer_init_value_list}    Get Regexp Matches     ${blank_timer_output}    ${pattern}    1
    ${blank_timer_init_value}   Set Variable    ${blank_timer_init_value_list}[0]
    [Return]   ${blank_off_init_value}   ${blank_on_init_value}  ${blank_timer_init_value}
    [Teardown]  Run Keywords  csn.disconnect    connection=RU_${ru_index}   AND   csn.disconnect    connection=ASIK Master

Modify T_sym_blank Value In Json File
    [Arguments]    ${init_value_blank_off}    ${target_value_blank_off}   ${init_value_blank_on}
    ...            ${target_value_blank_on}    ${init_value_blank_timer}
    ...            ${target_value_blank_timer}    ${cmd}
    ...            ${ru_index}=1    ${connection}=GNB_OAM
    ...            ${blank_off}=T_sym_blank_off    ${blank_on}=T_sym_blank_on
    ...            ${blank_timer}=T_sym_blank_timer  ${tcs_parameter}=tcs
    log to console    \n Modify T_sym_blank Value In Json File
    log to console    ${connection}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp_base}    Set Variable   ${sudo} frmonShellClient 127.0.0.1 2000
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action fetch DECODED "${tcs_parameter}.bin" "/var/tmp/${tcs_parameter}.json"'|${cmd_temp_base}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.execute      command=cat /var/tmp/${tcs_parameter}.json | grep -i ${blank_off}    connection=RU_${ru_index}
    ${tcs_parameter_base}   Set Variable   /var/tmp/${tcs_parameter}.json
    csn.Send command
    ...   command=${sudo} sed -i 's/"${blank_off}": ${init_value_blank_off},/"${blank_off}": ${target_value_blank_off},/g' ${tcs_parameter_base}
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.execute   command=${sudo} cat /var/tmp/${tcs_parameter}.json | grep -i ${blank_off}    connection=RU_${ru_index}
    sleep    2s
    csn.execute  command=cat /var/tmp/${tcs_parameter}.json | grep -i ${blank_on}    connection=RU_${ru_index}
    csn.Send command
    ...   command=${sudo} sed -i 's/"${blank_on}": ${init_value_blank_on},/"${blank_on}": ${target_value_blank_on},/g' ${tcs_parameter_base}
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.execute    command=${sudo} cat /var/tmp/${tcs_parameter}.json | grep -i ${blank_on}    connection=RU_${ru_index}
    sleep    2s
    csn.execute  command=cat /var/tmp/${tcs_parameter}.json | grep -i ${blank_timer}    connection=RU_${ru_index}
    ${cmd_str_base}   Set Variable   's/"${blank_timer}": ${init_value_blank_timer},/"${blank_timer}": ${target_value_blank_timer},/g'
    csn.Send command
    ...   command=${sudo} sed -i ${cmd_str_base} ${tcs_parameter_base}
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.execute    command=${sudo} cat /var/tmp/${tcs_parameter}.json | grep -i ${blank_timer}    connection=RU_${ru_index}
    csn.Send command    command=${sudo} ${cmd} /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "${tcs_parameter}.bin" "/var/tmp/${tcs_parameter}.json"'|${cmd_temp_base}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Adjusting RRU Temperature
    [Arguments]    ${ru_temperature}=90   ${ru_index}=1
    log to console    \n Adjusting RRU Temperature
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ action create ThermometerDevice /pa1 /temp/pam/antenna26a"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/pa1 get subnodes'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/pa1 action override TEMPERATURE ${ru_temperature}'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Trigger Fault 1103 And Cancel Within 30s On Single Made
    [Arguments]  ${ru_index}=1    ${ip}=192.168.101.2    ${alias}=made1    ${proxy}=RU_1    ${count_fault1103}=${1}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    log to console     \n trigger fault 1103 on ${alias}
    ${result_trigger}   Connect to made With Command   ru_index=${ru_index}  ip=${ip}  cmd=sudo ifconfig arb0p0 down
    ...                 alias=${alias}   proxy=${proxy}   ssh_made=${True}
    log to console     \n check 1103 trigger on RU
    Wait Until Keyword Succeeds   1min   3s   Check Fault In RU Fault History Log   ru_index=${ru_index}     fault_id=1103
    ...                count_fault1103=${count_fault1103}    ru_reset_flag=${False}
    sleep   10s
    log to console     \n cancel fault 1103 on ${alias}
    ${result_cancel}   Connect to made With Command   ru_index=${ru_index}  ip=${ip}  cmd=sudo ifconfig arb0p0 up
    ...                 alias=${alias}   proxy=${proxy}     ssh_made=${False}
    log to console     \n check 1103 disapear on RU
    Wait Until Keyword Succeeds   2min   10s   Check Fault Disappear In RU Fault History Log   ru_index=${ru_index}
    ...                fault_id=1103  count_fault1103=${count_fault1103}   ru_reset_flag=${False}
    log to console    check 1min fault 1904 not exist
    Repeat Keyword    1 minutes    Expect Fault Should Absent    faultId=1904
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]  Run Keywords   run keyword and ignore error    csn.disconnect    connection=${alias}
    ...     AND   run keyword and ignore error    csn.disconnect    connection=RU_${ru_index}
    ...     AND   run keyword and ignore error    csn.disconnect    connection=ASIK Master
    [Return]  ${result_trigger}   ${result_cancel}

Trigger Fault 1904/1981 And Check On WEBEM
    [Documentation]  alarm：select 1904/1981,which RU support these command trigger: ifconfig arb0p0/arb0p2 down
    ...   CB8990: alarmId=1904
    ...   CNI112018:alarmId=1981
    [Arguments]  ${ru_index}=1    ${ip}=192.168.101.2    ${alias}=made1    ${proxy}=RU_1  ${count_history_fault}=${1}
    ...     ${connection}=GNB_OAM   ${cmd}=sudo ifconfig arb0p0 down  ${check_ru_fault}=1103  ${CNI112018}=${False}
    ...    ${alarmId}=1904
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    log to console     \n trigger fault ${alarmId} on ${alias}
    ${result_trigger}   Connect to made With Command   ru_index=${ru_index}  ip=${ip}  cmd=${cmd}
    ...   alias=${alias}   proxy=${proxy}
    Run Keyword If   ${CNI112018}   Trigger Fault 1981 With Rel7   alias=${alias}
    #for this scenario only need check 1482 not need to check 1103 WESTLAKE-12523
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   40s   5s   Check Fault In RU Fault History Log   ru_index=${ru_index}
    ...    fault_id=${check_ru_fault}    count_fault1103=${count_history_fault}
    IF   ${CNI112018}
        ${cni112018_ru_fault_id}    Set Variable If    '${alarmId}'=='1907'    1482    1295
        Wait Until Keyword Succeeds   1min   5s   Check Fault In RU Fault History Log    ru_index=${ru_index}
        ...    fault_id=${cni112018_ru_fault_id}    count_fault1103=${count_history_fault}
    END
    log to console     \n check ${alarmId} produce on RU
    Wait Until Keyword Succeeds   2min   2s    Expect Fault Should Present Without Login BTS    faultId=${alarmId}  connection=${connection}
    log to console     \n check RU reset onair to offline
    Wait Until Keyword Succeeds   2min   10s    RU Should Be Offline    ru_index=${ru_index}  connection=${connection}
    log to console    check fault 1904 disappear
    Wait Until Keyword Succeeds   2min   10s    Expect Fault Should Absent    faultId=${alarmId}  connection=${connection}
    log to console     \n check RU offine to onair
    Wait Until Keyword Succeeds   5min   30s    RU Should Be Online    ru_index=${ru_index}  connection=${connection}
    log to console     \n check cell offine to onair
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]  Run Keywords   run keyword and ignore error    csn.disconnect    connection=${alias}
    ...     AND    run keyword and ignore error    csn.disconnect    connection=RU_${ru_index}
    ...     AND   run keyword and ignore error    csn.disconnect    connection=ASIK Master
    [Return]  ${result_trigger}

Trigger Fault 1981 And Check On WEBEM
    [Arguments]  ${ru_index}=1    ${ip}=192.168.101.2    ${alias}=made1    ${proxy}=RU_1   ${carrier_name}=NR958.TX1_1_1
    ...          ${path_name}=antenna1a     ${count_history_fault}=${1}   ${connection}=GNB_OAM
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    log to console     \n trigger fault 1981 on ${alias}
    ${result_trigger}   Connect to made and Trigger Fault1981   ru_index=${ru_index}  ip=${ip}   carrier_name=${carrier_name}
    ...   path_name=${path_name}   alias=${alias}   proxy=${proxy}
    log to console    \n check fault 1295  exist
    Wait Until Keyword Succeeds   1min   3s   Check Fault In RU Fault History Log   ru_index=${ru_index}     fault_id=1295
    ...    count_fault1103=${count_history_fault}
    log to console     \n check 1981 produce on RU
    Wait Until Keyword Succeeds   2min   2s    Expect Fault Should Present Without Login BTS    faultId=1981  connection=${connection}
    log to console     \n check RU reset onair to offline
    Wait Until Keyword Succeeds   2min   10s    RU Should Be Offline    ru_index=${ru_index}  connection=${connection}
    log to console    check fault 1981 disappear
    Wait Until Keyword Succeeds   2min   10s    Expect Fault Should Absent    faultId=1981  connection=${connection}
    log to console     \n check RU offline to onair
    Wait Until Keyword Succeeds   5min   30s    RU Should Be Online    ru_index=${ru_index}  connection=${connection}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]    Run Keywords   run keyword and ignore error    csn.disconnect    connection=${alias}
    ...     AND   run keyword and ignore error    csn.disconnect    connection=RU_${ru_index}
    ...     AND   run keyword and ignore error    csn.disconnect    connection=ASIK Master
    [Return]  ${result_trigger}

Connect to made With Command
    [Arguments]  ${ru_index}=1   ${ip}=192.168.101.2    ${cmd}=sudo ifconfig arb0p0 down    ${alias}=made1    ${proxy}=RU_1
    ...          ${ssh_made}=${True}
    ...          ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    log to console     \n connection ${alias} via ${ip}
    Run Keyword If   ${ssh_made}   csn.Connect to   hostname=${ip}   username=${ru_username}
    ...               password=${ru_password}   proxy=${proxy}   alias=${alias}
    ${result}   csn.execute   command=${cmd}    connection=${alias}
    [Return]  ${result}

Connect to made and Trigger Fault1981
    [Arguments]  ${ru_index}=1   ${ip}=192.168.101.2     ${alias}=made1    ${proxy}=RU_1   ${carrier_name}=NR958.TX1_1_1
    ...          ${path_name}=antenna1a
    ...          ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    log to console     \n connection ${alias} via ${ip}
    csn.Connect to   hostname=${ip}   username=${ru_username}   password=${ru_password}   proxy=${proxy}   alias=${alias}
    log to console    execute    '/ action create CarrierFaultInjection /${alias}'
    ${cmd}    Set Variable    echo "/ action create CarrierFaultInjection /${alias}"|frmonShellClient 127.0.0.1 2000
    ${result}   csn.execute   command=${cmd}    connection=${alias}
    sleep    2s
    log to console    execute    '/${alias} action break_tx_data_transmission "${carrier_name}" "${path_name}"'
    ${cmd}   Set Variable    echo '/${alias} action break_tx_data_transmission "${carrier_name}" "${path_name}"'|frmonShellClient 127.0.0.1 2000
    ${output}    csn.execute    command=${cmd}    connection=${alias}
    Should Contain    ${output}    done ok
    [Return]  ${result}

Check Fault In RU Fault History Log
    [Arguments]    ${ru_index}=1   ${fault_id}=1103   ${count_fault1103}=${1}   ${ru_reset_flag}=${True}
    ${1103_cmd}   Set Variable  cat /ram/fault_history_log_temp.txt | grep -a "${fault_id}" | grep -a "active"| grep -a "critical"| grep -av grep
    Run Keyword And Ignore Error    csn.download file    remote_path=/ram/fault_history_log_temp.txt
    ...    local_path=${SAVE LOG DIRECTORY}   connection=RU_${ru_index}
    ${output}    csn.execute    command=${1103_cmd}    timeout=10  connection=RU_${ru_index}
    log to console   \n check fault_history_log_temp.txt result ${output}
    ${output_list}   split to lines  ${output}
    ${count}    Get Length    ${output_list}
    Run Keyword If   not ${ru_reset_flag}   Should Be Equal As Strings   ${count}   ${count_fault1103}   msg=1103 is not triggered
    Run Keyword If   ${ru_reset_flag}   Should Not Be Empty   ${output}   msg=1103 not disappear

Check Fault Disappear In RU Fault History Log
    [Arguments]   ${ru_index}=1   ${fault_id}=1103    ${count_fault1103}=${1}   ${ru_reset_flag}=${True}
    ${1103_cmd}    Set Variable   cat /ram/fault_history_log_temp.txt | grep -a "${fault_id}" | grep -a "cleared"| grep -a "critical"| grep -av grep
    log to console   ${1103_cmd}
    ${output}    csn.execute    command=${1103_cmd}    connection=RU_${ru_index}
    log to console   ${output}
    ${output_list}   split to lines  ${output}
    ${count}    Get Length     ${output_list}
    Run Keyword If   not ${ru_reset_flag}    Should Be Equal As Strings   ${count}    ${count_fault1103}       msg=1103 is not triggered
    Run Keyword If   ${ru_reset_flag}   Should Not Be Empty    ${output}    msg=1103 not disappear
    Run Keyword If   '${count_fault1103}'=='4' and not ${ru_reset_flag}
    ...           csn.execute    command=sudo rm -rf /ram/fault_history_log_temp.txt    connection=RU_${ru_index}

Expect Fault Should Present Without Login BTS
    [Documentation]  This keyowrd is different from common which need login in bts
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}     ${supplementary}=${None}    ${supplementary_not_contain}=${None}
    ...            ${timeout}=10
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}    timeout=${timeout}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}    AND
                  ...                      Run Keyword If    '${Supplementary}'!='${None}'
                  ...                      Should Contain   ${alarm['supplAlarmInfo']}    ${Supplementary}    AND
                  ...                      Run Keyword If    '${supplementary_not_contain}'!='${None}'
                  ...                      Should not Contain   ${alarm['supplAlarmInfo']}    ${supplementary_not_contain}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Trigger Fault 1981 With Rel7
    [Arguments]  ${alias}=made1   ${cmd}=sudo ifconfig arb0p2 down
    log to console     \n trigger fault 1981 on ${alias} with twice ifconfig eth down
    csn.Send Command
    ...   sudo -i
    ...   get_pty=True   connection=${alias}
    ${output} =    Run Keyword And Ignore Error
    ...                csn.read output until    match=root    timeout=10    connection=${alias}
    sleep  10s
    log to console   ifconfig arb0p2 down
    ${result}   csn.execute   command=${cmd}   connection=${alias}
    sleep  2
    ${result}   csn.execute   command=${cmd}    connection=${alias}
    ${result}   csn.execute   command=ethtool arb0p2    connection=${alias}

Modify timeBetweenSaveOnNVM Value In BBOX File
    [Arguments]    ${init_value}    ${target_value}    ${ru_index}=1    ${connection}=default
    ...   ${get_parameter}=timeBetweenSaveOnNVM
    log to console    \n Modify timeBetweenSaveOnNVM Value In Json File for RU_${ru_index}
    Connect to Common Unit Master
    ${ismaster_status}    run keyword and return status
    ...    Connect to RU With Allocated IP
    ...    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master    connection=${connection}
    run keyword if  not ${ismaster_status}   Connect To MultiRAT GNB Common Unit Master
    run keyword if  not ${ismaster_status}
    ...   Connect to RU With Allocated IP
    ...    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=MultiRAT GNB Master   connection=${connection}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp_base}    Set Variable   ${sudo} frmonShellClient 127.0.0.1 2000
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...  echo '/CI/ConfigAccess action fetch DECODED "black_box_logger.bin" "/ram/black_box_logger.json"'|${cmd_temp_base}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.execute  command=cat /ram/black_box_logger.json | grep -i ${get_parameter}    connection=RU_${ru_index}
    ${modify_paramter_base}   Set Variable
    ...   sed -i 's/"${get_parameter}": ${init_value},/"${get_parameter}": ${target_value},/g' /ram/black_box_logger.json
    csn.Send command    command=${sudo} ${modify_paramter_base}   connection=RU_${ru_index}
    sleep    2s
    csn.execute    command=${sudo} cat /ram/black_box_logger.json | grep -i ${get_parameter}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess action store PERMANENT DECODED "black_box_logger.bin" "/ram/black_box_logger.json"'|${cmd_temp_base}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    run keywords    run keyword if  not ${ismaster_status}   csn.disconnect    connection=MultiRAT GNB Master
     ...   AND   csn.disconnect    connection=ASIK Master

Execute Command With RU rfsw Account
    [Arguments]  ${ru_alias}   ${cmd}
    ${connection_service}    csn.get_connection_by_alias    alias=${ru_alias}
    ${channel_service}    Call Method    ${connection_service}    invoke_shell
    Call Method    ${channel_service}    send    sudo su rfsw\n
    Sleep    3 sec
    ${account_output}    Call Method    ${channel_service}    recv    ${65535}
    ${account_output}    Convert To String    ${account_output}
    ${status}    Run Keyword And Return Status    Should Contain    ${account_output}    rfsw@
    IF    ${status}==${True}
       Call Method    ${channel_service}    send    ${cmd}\n
       Sleep    3 sec
       ${output}    Call Method    ${channel_service}    recv    ${65535}
       ${output}    Convert To String    ${output}
    ELSE
       Fail   Switch to rfsw account failed
    END
    Call Method    ${channel_service}    close
    [Return]  ${output}
