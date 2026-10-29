*** Settings ***

Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/traffic.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/bip.robot
Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${MRBTS_ID}                           ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${dist_name}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
${node_ip}  192.168.102.2
${sudo}    sudo
${ue_index}  ${0}
${PATH_Storage}    /home/ute/CB009275
${ENB_PATH}  MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
${lnrel_dist}  ${ENB_PATH}/LNCEL-1
${lnrel_para}  defaultLnRelGnbCellId
${lnrel_para1}    administrativeState
#${UL_TP}                       50M
${UL_TP_THRESHOLD}              1
#${DL_TP}                       300M
${DL_TP_THRESHOLD}              1
${ultp}                         0.85
${dltp}                         0.85
${GLOBAL_CELL1_ID}              1
${GLOBAL_CELL2_ID}              2
&{fault_6450}       faultId=${6450}
&{fault_4527}       faultId=${4527}
&{fault_6327}       faultId=${6327}
&{fault_61652}       faultId=${61652}
&{fault_61524}       faultId=${61524}
&{fault_4654}       faultId=${4654}
&{fault_4655}       faultId=${4655}
&{fault_7319}       faultId=${7319}
&{fault_7300}       faultId=${7300}
@{ALLOWED_FAULT}    &{fault_61652}    &{fault_61524}  &{fault_4654}    &{fault_4655}  &{fault_7319}  &{fault_7300}  &{fault_6450}
${cell1_dist}                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
${cell2_dist}                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
${ru_index}  1

*** Keywords ***

Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    robot_common_operations.Common Case Setup
	...    allowed_faults_ids=10,4590,1932,1933,1934
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    #Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min



Test Case Teardown
    [Arguments]    ${protocol}=udp
    #Make one call and detach
    robot_common_operations.Common Case Teardown
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${0}  protocol=${protocol}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api

    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    #Run Keyword If Test Passed  Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True

Suite Case Setup
    Run Keyword And Ignore Error    coam.teardown
    android_ue.Kill ADB application
    ${ue_type}    translate power ue type from testline    ${ue_index}
    set suite variable  ${ue_type}
    power_ue.Prepare UE      ue_index=${0}    ue_type=${ue_type}
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${0}  protocol=tcp
    log to console    Common Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    log to console  Get Active SW Version
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    set suite variable      ${stream}
    ${all_fan_list}  Create List  0  1  2
    set suite variable  ${all_fan_list}
    ${allfans_list}  Create List  fan0  fan1  fan2
    set suite variable  ${allfans_list}
    #Make one call and detach
    COAM get runtime rmod
    ${btsname}    scf.gNB Get Attribute value in SCF     dist_name=MRBTS-${MRBTS_ID}
    ...                 p_name=btsName
    Set Suite Variable  ${btsname}
    [Teardown]  run keyword and ignore error    COAM Teardown gnb connections

Suite Case Teardown
    robot_common_operations.Common Suite Teardown
    log to console    Suite Case Teardown
    CI_interface.Common Suite Setup

UE Dettach and Stop traffic
    [Arguments]    ${protocol}=udp    ${ue_index}=${0}
    Log To Console    \n UE Dettach and Stop traffic

    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    protocol=${protocol}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}    protocol=${protocol}
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}

Modify parameters in tcs_parameters.json
    [Documentation]  raw fault 1408---1933     raw fault 1409---1934
    [Arguments]    ${fault_1409}  ${trigger_high_temp}=disable  ${ru_index}=1
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    log to console    ******* Step 1: log in RU (AQQQA)********
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}

    Set Test Variable  ${sudo}
    log to console    create fan proxy
    ${cmd}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    get tcs_parameters file
    ${cmd}  Set Variable
    ...    echo '/CI/ConfigAccess_Module action fetch DECODED "tcs_parameters.bin" "/ram/tcs_parameters.json"'|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    modify parameters in tcs_parameters file
    csn.Send command  command=${sudo} cat /ram/tcs_parameters.json    connection=RU_${ru_index}
    csn.Send command    command=${sudo} sed -i 's/"Nrpm_fail": 30,/"Nrpm_fail": 2,/g' /ram/tcs_parameters.json    connection=RU_${ru_index}
    sleep    1s
    Run Keyword If  '${fault_1409}'=='enable'
    ...    csn.Send command    command=${sudo} sed -i 's/"Fmin": 35,/"Fmin": 45,/g' /ram/tcs_parameters.json   connection=RU_${ru_index}
    sleep    1s

    Run Keyword If  '${trigger_high_temp}'=='enable'  Run Keywords  csn.Send command
    ...  command=${sudo} sed -i 's/"deltaTmulti": 75,/"deltaTmulti": 120,/g' /ram/tcs_parameters.json    connection=RU_${ru_index}
    ...  AND  sleep    1s
    ...  AND  csn.Send command    command=${sudo} sed -i 's/"deltaTctl": 10,/"deltaTctl": 120,/g' /ram/tcs_parameters.json
    ...  connection=RU_${ru_index}
    ...  AND  sleep    1s
    ${output}  csn.execute    command=${sudo} cat /ram/tcs_parameters.json | grep Nrpm_fail   connection=RU_${ru_index}
    ${output}  csn.execute    command=${sudo} cat /ram/tcs_parameters.json | grep Fmin   connection=RU_${ru_index}
    ${output}  csn.execute    command=${sudo} cat /ram/tcs_parameters.json | grep deltaTmulti    connection=RU_${ru_index}
    ${output}  csn.execute    command=${sudo} cat /ram/tcs_parameters.json | grep deltaTctl    connection=RU_${ru_index}
    log to console    update config to RF
    ${cmd}   Set Variable
    ...  echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs_parameters.bin" "/ram/tcs_parameters.json"'|frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    reboot ru, then wait 5 minutes
    csn.execute    sudo pssreboot hw    connection=RU_${ru_index}
    csn.await execution end    timeout=120s    connection=RU_${ru_index}
    sleep    300s
    Wait Until Keyword Succeeds    3min    30s  RU Should Be Online
    Wait Until Keyword Succeeds    10min    30s  CI_commssion.Verify all cells should be Online
    Get runtime FAN Via Index  index=0
    Get runtime FAN Via Index  index=1
    Get runtime FAN Via Index  index=2
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${output}  Wait Until Keyword Succeeds	5x  60s  csn.execute    command=ls -trl /run | grep fault_history_log | awk -F ' ' '{print $9}'
    ...  connection=RU_${ru_index}
    ${ru_path_tmp}  Set Variable  ${output.split("\r\n")[0]}
    ${ru_fault_log_path}  Catenate  SEPARATOR=/  /run  ${ru_path_tmp}
    Set Test Variable  ${ru_fault_log_path}
   [Teardown]   Run Keyword And Ignore Error  csn.Disconnect    connection=RU_${ru_index}

Get runtime FAN Via Index
    [Arguments]  ${index}=0
    ${fan_r_list}    coam.Get managed objects    class_name=FAN_R    connection=GNB_OAM
    FOR    ${fan}    IN    @{fan_r_list}
        run keyword if  not '${rmod_index}' in '${fan['distName']}'  Continue For Loop
        ${rest}    ${fan_index}    Split String From Right    ${fan['distName']}    /    1
        ${fan_identity}    Set Variable    ${fan['parameters']['fanLocation']}
        Exit For Loop If    ${index}==${fan_identity}
    END
    ${tmp}  Evaluate  ${index}+1
    Set Test Variable  ${FAN_R-${tmp}}  ${fan_index}


Trigger raw fault 1408 or 1409 on fan
    [Arguments]    ${fault_1408}  ${fault_1409}  ${high_temp_1409}  ${flags_1408_list}=${None}  ${flags_1409_list}=${None}  ${ru_index}=1
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    log to console    create driver proxy for fan1
    ${cmd}   Set Variable  echo "/ action create FanDevice /CI/fan /fan/1"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    modify control state
    ${cmd}   Set Variable  echo "/CI/fan set control_state TESTABILITY_SW"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    Run Keyword If  '${fault_1408}'=='enable'  Set flag to trigger raw fault 1408 on fan  flags_1408_list=${flags_1408_list}
    Run Keyword If  '${fault_1409}'=='enable'  Set flag to trigger raw fault 1409 on fan  flags_1409_list=${flags_1409_list}

    Run Keyword If  '${high_temp_1409}'=='enable'  Untrigger raw fault 1409 with high temperture on fan  fan_list=${flags_1409_list}
    ${cmd}   Set Variable  sudo cat /mnt/runtime/swconfig.txt

    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    [Teardown]   Run Keyword And Ignore Error  csn.Disconnect    connection=RU_${ru_index}

Check raw fault exist
    [Arguments]  ${raw_fault}  ${fans_list}
    Log To Console  Check raw fault ${raw_fault} exist for ${fans_list}
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    FOR    ${fan}    IN    @{fans_list}
      Check fault is active for fan in faultlog of RU  fault_filter=${raw_fault}  fan=${fan}   ru_index=1
    END
    [Teardown]   Run Keyword And Ignore Error  csn.Disconnect    connection=RU_${ru_index}

Check raw fault is inactive
    [Arguments]  ${raw_fault}  ${fans_list}
    Log To Console  Check raw fault ${raw_fault} is inactive for ${fans_list}
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    FOR    ${fan}    IN    @{fans_list}
      Check if fault is not active on RU in History log  fault_filter=${raw_fault}  fan=${fan}   ru_index=1
    END
    [Teardown]   Run Keyword And Ignore Error  csn.Disconnect    connection=RU_${ru_index}

Get fault string in faultlog in RU
    [Arguments]  ${ru_index}=1
    sleep    90s
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    csn.send_command    command=${sudo} cat ${ru_fault_log_path}    connection=RU_${ru_index}
    sleep    2s
    ${ru_alarms_string}    csn.read output    connection=RU_${ru_index}
    #csn.disconnect    connection=RU_${ru_index}
    [Return]    ${ru_alarms_string}
    [Teardown]   Run Keyword And Ignore Error  csn.Disconnect    connection=RU_${ru_index}


Trigger high temperature on Made1
    [Arguments]  ${ru_index}=1
    Log To Console    Trigger high temperature on Made1
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds    3min    30s  Connect to Made1 via RU
    ${cmd}   Set Variable
    ...  echo "/ action create ThermometerDevice /CI/ThermoModule /temp/made1/pa2"|${sudo} frmonShellClient localhost 2000
    Run Keyword If    ${status}     Get command output from Made1  cmd=${cmd}
    ${cmd}   Set Variable  echo "/CI/ThermoModule action override TEMPERATURE 139"|${sudo} frmonShellClient localhost 2000
    Run Keyword If    ${status}    Get command output from Made1  cmd=${cmd}  match=done ok
    #Run Keyword If    ${status}    Get command output from Made1  cmd=exit  match=Fronthaul
    Call Method    ${channel}    close
    sleep    2s
    [Teardown]  csn.Disconnect  connection=RU_${ru_index}

Get command output from Made1
    [Arguments]  ${cmd}  ${match}=None
    Call Method    ${channel}    send    ${cmd}\n
    Sleep    3 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ${output}  Convert To String    ${output}
    Run Keyword If    '${match}'!='None'  Should Contain    ${output}    ${match}
    [Return]    ${output}

Stop triggering high temperature on Made1
    [Arguments]  ${ru_index}=1
    Log To Console    Stop triggering high temperature on Made1
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds    3min    30s  Connect to Made1 via RU
    ${cmd}    Set Variable    echo "/CI/ThermoModule action override OFF"|${sudo} frmonShellClient localhost 2000
    Run Keyword If    ${status}    Get command output from Made1  cmd=${cmd}  match=done ok
    Call Method    ${channel}    close
    sleep    2s
    [Teardown]  csn.Disconnect  connection=RU_${ru_index}

Connect to Made1 via RU
    [Arguments]  ${ru_index}=1
    ${connection}    csn.get_connection_by_alias    alias=RU_${ru_index}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    ssh ${node_ip}\n
    Sleep    3 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Should Contain    ${output}    DFE1
    Set Test Variable  ${channel}



Clear raw fault 1408 or 1409 without high temperature on fan
    [Arguments]    ${fault_1408}  ${fault_1409}  ${flags_1408_list}=${None}  ${flags_1409_list}=${None}  ${ru_index}=1
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    Run Keyword If  '${fault_1408}'=='enable'  Clear raw fault 1409 or 1408 on fan   flags_list=${flags_1408_list}
    Run Keyword If  '${fault_1409}'=='enable'  Clear raw fault 1409 or 1408 on fan   flags_list=${flags_1409_list}
    log to console    ******* recovery Fan *******
    ${cmd}   Set Variable  echo "/ action create FanDevice /CI/fan1 /fan/1"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo "/CI/fan1 set control_state RADIO_SW"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    2.2 create fan proxy
    ${cmd}   Set Variable
    ...  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/ConfigAccess_Module action delete "tcs_parameters.bin"'|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo "/CI/ConfigAccess_Module action terminate"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo "/CI/fan1 action terminate"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    [Teardown]  csn.Disconnect   connection=RU_${ru_index}



Set flag to trigger raw fault 1408 on fan
    [Arguments]    ${flags_1408_list}  ${ru_index}=1
    Log To Console  Set flag to trigger raw fault 1408 on fan
    FOR  ${item}  IN    @{flags_1408_list}
      ${cmd}   Set Variable  ccsShell.sh rad -mpw 0x12004${item} 0x00000001
      ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
      sleep    2s
    END


Set flag to trigger raw fault 1409 on fan
    [Arguments]    ${flags_1409_list}  ${ru_index}=1
    Log To Console  Set flag to trigger raw fault 1409 on fan
    FOR  ${item}  IN    @{flags_1409_list}
      ${cmd}   Set Variable  ccsShell.sh rad -mpw 0x12004${item} 0x00000E88
      ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
      sleep    2s
      ${cmd}   Set Variable  ccsShell.sh rad -mpw 0x12004${item} 0x000002EE
      ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
      sleep    2s

    END

Untrigger raw fault 1409 with high temperture on fan
    [Arguments]    ${fan_list}  ${ru_index}=1
    [Documentation]  update speed of fans you dont want to have alarm for, just udpate values once in files:
    ...  /sys/class/hwmon/hwmon0/pwm3 to 20
    Log To Console  Slow down fan speed to untrigger raw fault 1409 with high temperture on fan
    ${cmd}   Set Variable  echo "/CI/fan action set_setpoint 0.35"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    120s
    FOR    ${num}    IN    @{all_fan_list}
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${fan_list}  ${num}
        run keyword if  not ${status}  Update speed of fan  num=${num}
    END

Update speed of fan
    [Arguments]    ${num}  ${ru_index}=1
    Log To Console  Update speed of fan
    ${tmp}  Evaluate  ${num}+1
    ${output}  csn.execute  command=${sudo} cat /sys/class/hwmon/hwmon0/pwm${tmp}    connection=RU_${ru_index}
    sleep    1s
    ${output}  Replace String    ${output}    \r\n    ${EMPTY}

    csn.Send command    command=${sudo} echo '20' > /tmp/1.txt    connection=RU_${ru_index}
    sleep    2s
    ${output}  csn.execute  command=${sudo} cat /tmp/1.txt    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} cat /tmp/1.txt > /sys/class/hwmon/hwmon0/pwm${tmp}    connection=RU_${ru_index}
    sleep    2s
    ${output1}  csn.execute  command=${sudo} cat /sys/class/hwmon/hwmon0/pwm${tmp}    connection=RU_${ru_index}
    ${output1}  Replace String    ${output1}    \r\n    ${EMPTY}
    Should Be Equal As Strings  ${output1}  20


Clear raw fault 1409 or 1408 on fan
    [Arguments]    ${flags_list}  ${ru_index}=1
    Log To Console  Clear raw fault 1409 or 1408 on fan
    FOR  ${item}  IN    @{flags_list}
      ${cmd}   Set Variable  ccsShell.sh rad -mpw 0x12004${item} 0
      ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
      sleep    2s
    END

COAM Check fan status
    [Arguments]  ${fan_administrativeState}=Unlocked  ${fan_operationalState}=enabled  ${fan_availabilityStatus}=None
    ...  ${fans_list}=${None}  ${connection}=GNB_OAM
    Log to console  COAM Check fan status for ${fans_list}
    ${bts}    coam.get_bts_info    connection=${connection}
    ${ru_index_list}  set variable    ${bts['radioModules']['rmod']}
    ${ru_count}	 Get Length  ${ru_index_list}
    ${index}  	Evaluate  ${ru_count}-1
    ${fans_1}    set variable    ${bts['radioModules']['rmod'][0]['fanStatus']['fans']}
    ${fans_2}    set variable    ${bts['radioModules']['rmod'][${index}]['fanStatus']['fans']}
    ${fans_tmp}  Convert To String  ${fans_1[0]['distName']}
    ${fans}  Set Variable If  'RMOD_R-1' in '${fans_tmp}'  ${fans_1}  ${fans_2}
    FOR    ${i}    IN    @{fans_list}
        COAM Check one fan status  fans=${fans}  index=${i}  fan_administrativeState=${fan_administrativeState}
        ...  fan_operationalState=${fan_operationalState}  fan_availabilityStatus=${fan_availabilityStatus}
    END

COAM Check one fan status
    [Arguments]  ${fans}  ${index}=0  ${fan_administrativeState}=Unlocked  ${fan_operationalState}=enabled
    ...  ${fan_availabilityStatus}=None
    ${tmp}  Evaluate  ${index}+1
    Log to console  COAM Check fan status for ${FAN_R-${tmp}}
    FOR    ${fan}    IN    @{fans}
        run keyword if  not '${FAN_R-${tmp}}' in '${fan['distName']}'  Continue For Loop
        ${administrativeState}    set variable    ${fan['stateInfo']['administrativeState']}
        Should Be True    '${administrativeState}'=='${fan_administrativeState}'
        ${operationalState}    set variable    ${fan['stateInfo']['operationalState']}
        Should Be True    '${operationalState}'=='${fan_operationalState}'
        ${availabilityStatus}  Set Variable If  '${fan_availabilityStatus}'!='None'  ${fan['stateInfo']['availabilityStatus']}
        Run Keyword If  '${fan_availabilityStatus}'!='None'  Should Be True    '${availabilityStatus}'=='${fan_availabilityStatus}'

    END

Check fault is active for fan in faultlog of RU
    [Arguments]  ${fault_filter}  ${fan}  ${ru_index}=1
    ${terminal}=    ssh.Execute      command=${sudo} cat ${ru_fault_log_path}   connection=RU_${ru_index}
    Log to console  Check fault ${fault_filter} is active for ${fan} in faultlog of RU
    ${text}=    ssh.Execute
    ...   command=${sudo} cat ${ru_fault_log_path}|grep ${fault_filter}|grep ${fan}|grep active   connection=RU_${ru_index}
    Should Not Be Empty    ${text}


Check if fault is not active on RU in History log
    [Arguments]  ${fault_filter}  ${fan}  ${ru_index}=1
    ${terminal}=    ssh.Execute      command=${sudo} cat ${ru_fault_log_path}    connection=RU_${ru_index}
    Log to console  Check if fault ${fault_filter} is not active for ${fan} on RU in History log
    ${text}=    ssh.Execute
    ...  command=${sudo} cat ${ru_fault_log_path}|grep ${fault_filter}|grep ${fan}|grep cleared   connection=RU_${ru_index}
    Should Not Be Empty    ${text}



Make one call and detach
    Log To Console    Make one call and detach

    ${lnrel_dist_exists}=  Run keyword and return status  Variable Should Exist  ${lnrel_dist}
    Run keyword if  '${lnrel_dist_exists}'=='${True}'  Connect and Modify the parameter on enblte
    ...   dist_name=${lnrel_dist}   parameter=${lnrel_para1}   value=locked

    Unlock BTS All 5G Cells
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    scf.Activate Parameter Value    dist_name=${cell2_dist}    p_name=administrativeState    new_value=Locked
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
    [Teardown]  Run Keywords  Run keyword and ignore error  scf.Activate Parameter Value
    ...    dist_name=${cell2_dist}  p_name=administrativeState  new_value=Unlocked  AND  Run keyword and ignore error
    ...  Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=unlocked
    ...  AND  run keyword and ignore error    COAM Teardown gnb connections

UE Attach And Check Throughput With Detach bk
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]  ${duration}=1200  ${cell_id}=0
    ...    ${ue_index}=${0}  ${actCarrierAggregation}=${False}
    Log To Console  UE Attach And Check Throughput With Detach
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
    Reboot UE If no UE IP
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=251M     duration=${duration}
    ...    ue_index=${ue_index}    iperf_type=via_command
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=33M     duration=${duration}
    ...    ue_index=${ue_index}    iperf_type=via_command
    sleep  2

    Connect to gnb coam via ssl
    ${list_of_cell_ids}  Get List of NR Cell ID
    ${cell_list}  create list
    Run keyword If  ${actCarrierAggregation} == ${False}  Run keywords
    ...  Append To List  ${cell_list}  ${list_of_cell_ids}[${cell_id}]  AND
    ...  set suite variable  ${list_of_cell_ids}  ${cell_list}

    ${log}  power_ue.Collect Tput  check_source=Aasyslog  ue_type=${ue_type}    duration=2m
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${actCarrierAggregation}
    ...    min_percent=0
    ${ul_average}  ${dl_average}  Get UL and DL Average Value  ${all_tp}
    run keyword and ignore error  Get nrCellIdentity for SA UE  nrCId=${list_of_cell_ids}[0]
    [Return]  ${ul_average}  ${dl_average}

#    Sleep    30s
#    power_ue.Check throughput    ue_index=${ue_index}    direction=ul    ue_type=${ue_type}    throughput=${ul_tp_threshold}
#    ...    cellid=${nr_cell_identity}
#    power_ue.Check throughput   ue_index=${ue_index}    direction=dl    ue_type=${ue_type}    throughput=${dl_tp_threshold}
#    ...    cellid=${nr_cell_identity}
#    Connect To BTS Csn Via Lmp
#    ${ul_tp}    Calculate UL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
#    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
#    ${dl_tp}    Calculate DL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
#    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
#    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    [Teardown]    Run Keywords
#    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    ...    Run Keyword And Ignore Error   UE Dettach and Stop traffic  ue_index=${ue_index}
	...    AND    Run Keyword And Ignore Error   COAM Teardown gnb connections
#   [Return]    ${ul_tp}    ${dl_tp}


Get UL and DL Average Value
    [Documentation]     Get average number and print
    [Arguments]       ${all_tp}
    ${x1}=  Get From List  ${all_tp}  0
    ${x3}=  Get From List  ${x1}  0
    ${ul_average}=  Get From Dictionary    ${x3}    average
    Log to console   The UL average result is ${ul_average}
    ${x2}=  Get From List  ${all_tp}  1
    ${x4}=  Get From List  ${x2}  0
    ${dl_average}=  Get From Dictionary    ${x4}    average
    Log to console   The DL average result is ${dl_average}
   [Return]  ${ul_average}  ${dl_average}


Feature Disable with Fault 1933 not raised due radio temperature not reach threshold
  scf.Activate Parameter Value  dist_name=${dist_name}  p_name=actRadioFanFailureEarlyNotif  new_value=true
  Modify parameters in tcs_parameters.json  fault_1409=enable  trigger_high_temp=disable
  ${1409_list}  Create List  fan0
  ${1408_list}  Create List  fan1
  ${flags_1409_list}  Create List  0
  ${flags_1408_list}  Create List  1
  Trigger raw fault 1408 or 1409 on fan  fault_1408=enable  fault_1409=enable  high_temp_1409=disable  flags_1409_list=${flags_1409_list}
  ...  flags_1408_list=${flags_1408_list}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1933
  ...    source=[${btsname}] ${RMOD}/${FAN_R-2}
  Wait Until Keyword Succeeds    3min    30s  Check raw fault exist  raw_fault=1409  fans_list=${1409_list}
  Wait Until Keyword Succeeds    3min    30s  Check raw fault exist  raw_fault=1408  fans_list=${1408_list}
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_operationalState=enabled
  ...  fans_list=${flags_1409_list}  fan_availabilityStatus=degraded
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_operationalState=disabled
  ...  fans_list=${flags_1408_list}  fan_availabilityStatus=failed
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  scf.Activate Parameter Value  dist_name=${dist_name}  p_name=actRadioFanFailureEarlyNotif  new_value=false
  Connect to gnb coam via ssl
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
  ...    source=[${btsname}] ${RMOD}/${FAN_R-2}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
  ...    source=[${btsname}] ${RMOD}
  Wait Until Keyword Succeeds    3min    30s  Check raw fault exist  raw_fault=1409  fans_list=${1409_list}
  Wait Until Keyword Succeeds    3min    30s  Check raw fault exist  raw_fault=1408  fans_list=${1408_list}
  ${ru_alarms_string}  Get fault string in faultlog in RU
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_administrativeState=Unlocked  fan_operationalState=enabled
  ...  fans_list=${all_fan_list}
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  Clear raw fault 1408 or 1409 without high temperature on fan  fault_1408=enable  fault_1409=enable
  ...  flags_1409_list=${flags_1409_list}  flags_1408_list=${flags_1408_list}
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_administrativeState=Unlocked  fan_operationalState=enabled
  ...  fans_list=${all_fan_list}
  ${ru_alarms_string}  Get fault string in faultlog in RU
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
  ...    source=[${btsname}] ${RMOD}/${FAN_R-2}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
  ...    source=[${btsname}] ${RMOD}
  Wait Until Keyword Succeeds    3min    30s  Check raw fault is inactive  raw_fault=1408  fans_list=${1408_list}
  Wait Until Keyword Succeeds    3min    30s  Check raw fault is inactive  raw_fault=1409  fans_list=${1409_list}
  [Teardown]  Run Keywords  Log To Console  case teardown
  ...  AND  Run Keyword And Ignore Error      Clear raw fault 1408 or 1409 without high temperature on fan
  ...  fault_1408=enable  fault_1409=enable  flags_1409_list=${flags_1409_list}  flags_1408_list=${flags_1408_list}
  ...  AND  Run Keyword And Ignore Error  csn.Disconnect    connection=RU_1
  ...  AND  Run Keyword And Ignore Error  csn.disconnect    connection=ASIK Master
  ...  AND  run keyword and ignore error    COAM Teardown gnb connections

Feature Enable with Fault 1933 not raised due radio temperature not reach threshold
  scf.Activate Parameter Value  dist_name=${dist_name}  p_name=actRadioFanFailureEarlyNotif  new_value=false
  Modify parameters in tcs_parameters.json  fault_1409=disable  trigger_high_temp=disable
  ${1408_list}  Create List  fan0  fan1
  ${flags_1408_list}  Create List  0  1
  Trigger raw fault 1408 or 1409 on fan  fault_1408=enable  fault_1409=disable  high_temp_1409=disable
  ...  flags_1408_list=${flags_1408_list}
  Wait Until Keyword Succeeds    3min    30s  Check raw fault exist  raw_fault=1408  fans_list=${1408_list}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
  ...    source=[${btsname}] ${RMOD}
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fans_list=${all_fan_list}
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  scf.Activate Parameter Value  dist_name=${dist_name}  p_name=actRadioFanFailureEarlyNotif  new_value=true
  Connect to gnb coam via ssl
  Wait Until Keyword Succeeds  3min  30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1933
  ...  source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds  3min  30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1933
  ...  source=[${btsname}] ${RMOD}/${FAN_R-2}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
  ...  source=[${btsname}] ${RMOD}

  Wait Until Keyword Succeeds    3min    30s  Check raw fault exist  raw_fault=1408  fans_list=${1408_list}
  ${ru_alarms_string}  Get fault string in faultlog in RU
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_operationalState=disabled
  ...  fans_list=${flags_1408_list}  fan_availabilityStatus=failed
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  Clear raw fault 1408 or 1409 without high temperature on fan  fault_1408=enable  fault_1409=disable
  ...  flags_1408_list=${flags_1408_list}
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_administrativeState=Unlocked  fan_operationalState=enabled
  ...  fans_list=${all_fan_list}
  ${ru_alarms_string}  Get fault string in faultlog in RU
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  Wait Until Keyword Succeeds  3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
  ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds  3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
  ...    source=[${btsname}] ${RMOD}/${FAN_R-2}
  Wait Until Keyword Succeeds    3min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
  ...    source=[${btsname}] ${RMOD}
  Wait Until Keyword Succeeds    3min    30s  Check raw fault is inactive  raw_fault=1408  fans_list=${1408_list}
  [Teardown]  Run Keywords  Log To Console  case teardown
  ...  AND  Run Keyword And Ignore Error      Clear raw fault 1408 or 1409 without high temperature on fan
  ...  fault_1408=enable  fault_1409=disable  flags_1408_list=${flags_1408_list}
  ...  AND  Run Keyword And Ignore Error  csn.Disconnect    connection=RU_1
  ...  AND  Run Keyword And Ignore Error  csn.disconnect    connection=ASIK Master
  ...  AND  run keyword and ignore error    COAM Teardown gnb connections

COAM get runtime rmod
    [Arguments]  ${connection}=GNB_OAM
    ${bts}    coam.get_bts_info    connection=${connection}
    ${ru_index_list}  set variable    ${bts['radioModules']['rmod']}
    ${ru_count}	 Get Length  ${ru_index_list}
    ${index}  	Evaluate  ${ru_count}-1
    ${rmod_1}    set variable    ${bts['radioModules']['rmod'][0]['id']['runtime']}
    ${rmod_2}    set variable    ${bts['radioModules']['rmod'][${index}]['id']['runtime']}
    #${rmod_tmp}  Convert To String  ${rmod_1}
    ${RMOD}  Set Variable If  'RMOD_R-1' in '${rmod_1}'  ${rmod_1}  ${rmod_2}
    Set Suite Variable  ${RMOD}
    Log to console  COAM get ${RMOD}
    ${rest}    ${rmod_index}    Split String From Right    ${RMOD}    /    1
    Set Suite Variable  ${rmod_index}

Feature Enable with Fault 1933 actived
    scf.Activate Parameter Value  dist_name=${dist_name}  p_name=actRadioFanFailureEarlyNotif  new_value=false
    Modify parameters in tcs_parameters.json  fault_1409=enable  trigger_high_temp=enable
    #Connect to gnb coam via ssl
    #Connect to Common Unit Master
    ${fans_1408}  Create List  fan0  fan1
    ${flags_1408_list}  Create List  0  1
    ${module}  Create List  module
    Trigger raw fault 1408 or 1409 on fan  fault_1408=enable  fault_1409=disable  high_temp_1409=disable  flags_1408_list=${flags_1408_list}
    #sleep    120s
    Wait Until Keyword Succeeds    5min    30s  Check raw fault exist  raw_fault=1408  fans_list=${fans_1408}
    CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933    source=[${btsname}] ${RMOD}
    Trigger high temperature on Made1
    #sleep    120s
    Wait Until Keyword Succeeds    5min    30s  Check raw fault exist  raw_fault=1167  fans_list=${module}
    Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1934
    ...    source=[${btsname}] ${RMOD}
    Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_operationalState=enabled  fan_availabilityStatus=None
    ...  fans_list=${flags_1408_list}
    Wait Until Keyword Succeeds    5min    30s  Check raw fault exist  raw_fault=1408  fans_list=${fans_1408}
    Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
    ...    source=[${btsname}] ${RMOD}
    Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1934
    ...    source=[${btsname}] ${RMOD}
    Run Keyword And Continue On Failure  RU Should Be Online
    Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online


    scf.Activate Parameter Value  dist_name=${dist_name}    p_name=actRadioFanFailureEarlyNotif    new_value=true
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1933
    ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
    Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1933
    ...    source=[${btsname}] ${RMOD}/${FAN_R-2}
    Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
    ...    source=[${btsname}] ${RMOD}
    Wait Until Keyword Succeeds    5min    30s  Check raw fault exist   raw_fault=1408  fans_list=${fans_1408}
    Wait Until Keyword Succeeds    5min    30s  Check raw fault exist  raw_fault=1167  fans_list=${module}
    Run Keyword And Continue On Failure  RU Should Be Online
    Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_operationalState=disabled  fan_availabilityStatus=failed
    ...  fans_list=${flags_1408_list}

    Clear raw fault 1408 or 1409 without high temperature on fan  fault_1408=enable  fault_1409=disable
    ...  flags_1408_list=${all_fan_list}

    ${ru_alarms_string}  Get fault string in faultlog in RU
    Stop triggering high temperature on Made1
    Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
    ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
    Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1933
    ...    source=[${btsname}] ${RMOD}/${FAN_R-2}
    Wait Until Keyword Succeeds    1min    30s  Check raw fault is inactive  raw_fault=1408  fans_list=${fans_1408}
    Wait Until Keyword Succeeds    10min    30s  Check raw fault is inactive  raw_fault=1167  fans_list=${module}
    Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_administrativeState=Unlocked  fan_operationalState=enabled
    ...  fans_list=${all_fan_list}
    ${ru_alarms_string}  Get fault string in faultlog in RU
    Run Keyword And Continue On Failure  RU Should Be Online
    Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
    [Teardown]  Run Keywords  Log To Console  case teardown
    ...  AND  Run Keyword And Ignore Error  Clear raw fault 1408 or 1409 without high temperature on fan
    ...  fault_1408=enable  fault_1409=disable  flags_1408_list=${all_fan_list}
    ...  AND  Run Keyword And Ignore Error  Stop triggering high temperature on Made1
    ...  AND  Run Keyword And Ignore Error  csn.Disconnect    connection=RU_1
    ...  AND  Run Keyword And Ignore Error  csn.disconnect    connection=ASIK Master
    ...  AND  run keyword and ignore error    COAM Teardown gnb connections

Feature Enable with Fault 1934 not raised due radio temperature not reach threshold
  scf.Activate Parameter Value  dist_name=${dist_name}  p_name=actRadioFanFailureEarlyNotif  new_value=false
  Modify parameters in tcs_parameters.json  fault_1409=enable  trigger_high_temp=disable
  ${fans_1409}  Create List  fan0  fan1
  ${flags_1409_list}  Create List  0  1
  Trigger raw fault 1408 or 1409 on fan  fault_1408=disable  fault_1409=enable  high_temp_1409=disable  flags_1409_list=${flags_1409_list}
  Wait Until Keyword Succeeds    5min    30s  Check raw fault exist  raw_fault=1409  fans_list=${fans_1409}
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_operationalState=enabled
  ...  fans_list=${flags_1409_list}
  scf.Activate Parameter Value  dist_name=${dist_name}    p_name=actRadioFanFailureEarlyNotif    new_value=true
  Connect to gnb coam via ssl
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-2}
  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934    source=[${btsname}] ${RMOD}
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_operationalState=enabled  fan_availabilityStatus=degraded
  ...  fans_list=${flags_1409_list}
  Wait Until Keyword Succeeds    5min    30s  Check raw fault exist  raw_fault=1409  fans_list=${fans_1409}
  Clear raw fault 1408 or 1409 without high temperature on fan  fault_1408=disable  fault_1409=enable
  ...  flags_1409_list=${all_fan_list}
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-2}

  Wait Until Keyword Succeeds    1min    30s  Check raw fault is inactive  raw_fault=1409  fans_list=${fans_1409}
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_administrativeState=Unlocked  fan_operationalState=enabled
  ...  fans_list=${all_fan_list}
  ${ru_alarms_string}  Get fault string in faultlog in RU
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  [Teardown]  Run Keywords  Log To Console  case teardown
    ...  AND  Run Keyword And Ignore Error  Clear raw fault 1408 or 1409 without high temperature on fan
    ...  fault_1408=disable  fault_1409=enable  flags_1409_list=${all_fan_list}
    ...  AND  Run Keyword And Ignore Error  csn.Disconnect    connection=RU_1
    ...  AND  Run Keyword And Ignore Error  csn.disconnect    connection=ASIK Master
    ...  AND  run keyword and ignore error    COAM Teardown gnb connections

Feature Disable with Fault 1934 not raised due radio temperature not reach threshold
  scf.Activate Parameter Value  dist_name=${dist_name}  p_name=actRadioFanFailureEarlyNotif  new_value=true
  Modify parameters in tcs_parameters.json  fault_1409=enable  trigger_high_temp=disable
  ${fans_1409}  Create List  fan0  fan1
  ${flags_1409_list}  Create List  0  1
  Trigger raw fault 1408 or 1409 on fan  fault_1408=disable  fault_1409=enable  high_temp_1409=disable  flags_1409_list=${flags_1409_list}
  Wait Until Keyword Succeeds    5min    30s  Check raw fault exist  raw_fault=1409  fans_list=${fans_1409}
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Present on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-2}
  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934    source=[${btsname}] ${RMOD}
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_operationalState=enabled  fan_availabilityStatus=degraded
  ...  fans_list=${flags_1409_list}
  scf.Activate Parameter Value  dist_name=${dist_name}    p_name=actRadioFanFailureEarlyNotif    new_value=false
  Connect to gnb coam via ssl
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-2}
  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934    source=[${btsname}] ${RMOD}
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_operationalState=enabled
  ...  fans_list=${flags_1409_list}
  Wait Until Keyword Succeeds    5min    30s  Check raw fault exist  raw_fault=1409  fans_list=${fans_1409}
  Clear raw fault 1408 or 1409 without high temperature on fan  fault_1408=disable  fault_1409=enable
  ...  flags_1409_list=${all_fan_list}
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-1}
  Wait Until Keyword Succeeds    5min    30s  CB009275_common_keyword.Expect Fault Should Absent on WebUI    faultId=1934
  ...    source=[${btsname}] ${RMOD}/${FAN_R-2}

  Wait Until Keyword Succeeds    1min    30s  Check raw fault is inactive  raw_fault=1409  fans_list=${fans_1409}
  Wait Until Keyword Succeeds    3min    30s  COAM Check fan status  fan_administrativeState=Unlocked  fan_operationalState=enabled
  ...  fans_list=${all_fan_list}
  ${ru_alarms_string}  Get fault string in faultlog in RU
  Run Keyword And Continue On Failure  RU Should Be Online
  Run Keyword And Continue On Failure  CI_commssion.Verify all cells should be Online
  [Teardown]  Run Keywords  Log To Console  case teardown
    ...  AND  Run Keyword And Ignore Error  Clear raw fault 1408 or 1409 without high temperature on fan
    ...  fault_1408=disable  fault_1409=enable  flags_1409_list=${all_fan_list}
    ...  AND  Run Keyword And Ignore Error  csn.Disconnect    connection=RU_1
    ...  AND  Run Keyword And Ignore Error  csn.disconnect    connection=ASIK Master
    ...  AND  run keyword and ignore error    COAM Teardown gnb connections
