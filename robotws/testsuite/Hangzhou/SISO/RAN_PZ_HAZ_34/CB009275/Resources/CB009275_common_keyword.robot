*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Variables    ../TestData/9275_variables.py

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}
@{nr_cell_3}    ${3}
@{nr_cell_4}    ${4}
@{nr_cell_5}    ${5}
@{nr_cell_6}    ${6}


*** Keywords ***
Fault 1932 is triggered
    [Arguments]    ${ru_index}=3
    AlarmWatchdog.add_allow_alarms    fault_id=1932
    ${client}    set variable    frmonShellClient localhost 2000
    log to console    set actRadioFanFailureEarlyNotif  to true
    Modify actRadioFanFailureEarlyNotif    value=true
    Connect to Common Unit Master
    log to console    ******* Step 1: log in RU (AHFII 1)********
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    log to console    ******* Step 2 : modify /ram/fans.json ********
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    log to console    2.2 create fan proxy
    ${cmd}   Set Variable    echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    2.3 get tcs file
    ${cmd}   Set Variable    echo '/CI/ConfigAccess_Module action fetch DECODED "fans.bin" "/ram/fans.json"'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    2.4 modify  fanDetectionPeriod to 60000,  fanTestPeriod to 30000, and fanTestRpmMin to 1300 in tcs file
    log to console    get init value for fanDetectionPeriod
    ${output}  csn.execute  command=${sudo} cat /ram/fans.json | grep -i fanDetectionPeriod    connection=RU_${ru_index}
    ${pattern}   Set Variable    "fanDetectionPeriod": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_fanDetectionPeriod}   Set Variable    ${init_value_list}[0]
    log to console    get init value for fanTestPeriod
    ${output}  csn.execute  command=${sudo} cat /ram/fans.json | grep -i fanTestPeriod    connection=RU_${ru_index}
    ${pattern}   Set Variable    "fanTestPeriod": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_fanTestPeriod}   Set Variable    ${init_value_list}[0]
    log to console    get init value for fanTestRpmMin
    ${output}  csn.execute  command=${sudo} cat /ram/fans.json | grep -i fanTestRpmMin    connection=RU_${ru_index}
    ${pattern}   Set Variable    "fanTestRpmMin": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_fanTestRpmMin}   Set Variable    ${init_value_list}[0]
    ${cmd}   Set Variable    ${sudo} sed -i 's/"fanDetectionPeriod": ${init_value_fanDetectionPeriod},/"fanDetectionPeriod": 60000,/g' /ram/fans.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable    ${sudo} sed -i 's/"fanTestPeriod": ${init_value_fanTestPeriod},/"fanTestPeriod": 30000,/g' /ram/fans.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable    ${sudo} sed -i 's/"fanTestRpmMin": ${init_value_fanTestRpmMin},/"fanTestRpmMin": 1300,/g' /ram/fans.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    2.5 update config to RF
    ${cmd}   catenate    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "fans.bin"
    ...    "/ram/fans.json"'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    log to console    ****** Step 3: log in  AHFII, and execute command*********
    csn.execute    command=${sudo} touch /mnt/runtime/swconfig.txt    connection=RU_${ru_index}
    sleep    2s
    csn.execute    command=${sudo} chmod 777 /mnt/runtime/swconfig.txt    connection=RU_${ru_index}
    sleep    2s
    csn.execute    command=${sudo} echo -e '0x120040=1150\n0x120041=1150' > /mnt/runtime/swconfig.txt    connection=RU_${ru_index}
    sleep    2s
    log to console    ****** Step 4: reboot RU*********
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset    ru_index=${ru_index}
    Sleep    30s
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
    log to console    check fault 1932 present on FAN_R_
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1932
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    log to console    check fault 1932 present on FAN_R_
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1932
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    log to console    ****** Step 5: modify actRadioFanFailureEarlyNotif to false ********
    Modify actRadioFanFailureEarlyNotif    value=false
    log to console    all fault on FAN_R canceled
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent    faultId=1932
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent    faultId=1932
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    log to console    Fault 1932 reported on RMOD
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present With Absolute Source    faultId=1932
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}
    log to console    check fans status
    Connect to gnb coam via ssl
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    ${fan_status}    Get fan status    bts_info=${bts_info}
    ${availabilitystatus_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_1}    failed
    ${availabilitystatus_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_2}    failed
    ${operationalstate_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_1}    disabled
    ${operationalstate_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_2}    disabled
    log to console    check ru status
    # todo
    log to console    ****** Step 6: modify actRadioFanFailureEarlyNotif to true ********
    Modify actRadioFanFailureEarlyNotif    value=true
    log to console    check fault 1932 raised on FAN_R_
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1932
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1932
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    log to console    check fans status
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    ${fan_status}    Get fan status    bts_info=${bts_info}
    ${availabilitystatus_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_1}    failed
    ${availabilitystatus_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_2}    failed
    ${operationalstate_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_1}    disabled
    ${operationalstate_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_2}    disabled
    log to console    check ru status
    # todo
    log to console    ****** Step 7: 1932 recovery********
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    csn.execute    command=${sudo} rm -rf /mnt/runtime/swconfig.txt    connection=RU_${ru_index}
    sleep    2s
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset    ru_index=${ru_index}
    Sleep    30s
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    [Teardown]  run keywords    run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect  connection=ASIK Master    AND
    ...    run keyword and ignore error    env recovery for 9275    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    AND
    ...    run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=1932

Fault 1933 and Fault 1934 with high temperature
    [Arguments]    ${ru_index}=3
    ${ru_index_r}   Evaluate    ${ru_index}-2
    AlarmWatchdog.add_allow_alarms    fault_id=1933
    AlarmWatchdog.add_allow_alarms    fault_id=1934
    Get btsName
    ${client}    set variable    frmonShellClient localhost 2000
    ${flag}    set variable    ${False}
    log to console    set actRadioFanFailureEarlyNotif to false
    Modify actRadioFanFailureEarlyNotif    value=false
    Connect to Common Unit Master
    log to console    ******* Step 1: log in RU (AHFII 1)********
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    log to console    ******* Step 2 : modify trigger time and threshold ********
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    log to console    2.2 create fan proxy
    ${cmd}   Set Variable    echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    2.3 get tcs file
    ${cmd}   Set Variable    echo '/CI/ConfigAccess_Module action fetch DECODED "tcs_parameters.bin" "/ram/tcs.json"'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    2.4 modify  Nrpm_fail to 2,  Fmin to 45, Tblock to ru real temp-3, Tblock_deact to ru real temp -6 in tcs file
    log to console    get init value for Nrpm_fail
    ${output}  csn.execute  command=${sudo} cat /ram/tcs.json | grep -i Nrpm_fail    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Nrpm_fail": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_nrpm_fail}   Set Variable    ${init_value_list}[0]
    log to console    init value for Nrpm_fail is ${init_value_nrpm_fail}
    log to console    get init value for Fmin
    ${output}  csn.execute  command=${sudo} cat /ram/tcs.json | grep -i Fmin    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Fmin": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_fmin}   Set Variable    ${init_value_list}[0]
    log to console    init value for Fmin is ${init_value_fmin}
    log to console    get init value for Tblock
    ${output}  csn.execute  command=${sudo} cat /ram/tcs.json | grep -i Tblock    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Tblock": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_tblock}   Set Variable    ${init_value_list}[0]
    log to console    init value for Tblock is ${init_value_tblock}
    log to console    get init value for Tblock_deact
    ${output}  csn.execute  command=${sudo} cat /ram/tcs.json | grep -i Tblock_deact    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Tblock_deact": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_tblock_deact}   Set Variable    ${init_value_list}[0]
    log to console    init value for Tblock_deact is ${init_value_tblock_deact}
    Get RU Temperature from WEBUI
    ${temp_int}  Convert To Integer    ${temp_ru}
    ${temp_minus_1}    Evaluate    ${temp_int}-3
    ${temp_minus_1}    Convert To String    ${temp_minus_1}
    ${temp_minus_6}    Evaluate    ${temp_int}-6
    ${temp_minus_6}    Convert To String    ${temp_minus_6}
    run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    csn.Send command    command=${sudo} sed -i 's/"Nrpm_fail": ${init_value_nrpm_fail},/"Nrpm_fail": 2,/g' /ram/tcs.json    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} sed -i 's/"Fmin": ${init_value_fmin},/"Fmin": 45,/g' /ram/tcs.json    connection=RU_${ru_index}
    sleep    2s
    ${cmd}    set variable    ${sudo} sed -i 's/"Tblock": ${init_value_tblock},/"Tblock": ${temp_minus_1},/g' /ram/tcs.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}    set variable    ${sudo} sed -i 's/"Tblock_deact": ${init_value_tblock_deact},/"Tblock_deact": ${temp_minus_6},/g' /ram/tcs.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    2.5 update config to RF
    ${cmd}   catenate    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs_parameters.bin"
    ...    "/ram/tcs.json"'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    2.6 reboot ru
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset    ru_index=${ru_index}
    Sleep    30s
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
    sleep    5mins
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    log to console    ****** Step 3: go into testability_sw control state *********
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd}   Set Variable    echo "/ action create FanDevice /CI/fan1 /fan/1"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable    echo "/CI/fan1 set control_state TESTABILITY_SW"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    ****** Step 4: rewrite temperature to trigger fault 1933 and 1934 ********
    ${cmd}   Set Variable    echo "/ action create ThermometerDevice /CI/ThermoModule /temp/pa1ch1"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable    echo "/CI/ThermoModule action override TEMPERATURE ${temp_ru}"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    ****** Step 5: trigger fault 1934 on fan1 and fan2********
    log to console    modify /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses, change value from 2 to 8
    ${cmd}    set variable    chmod 777 /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    sed "s/2/8/g" /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses > /tmp/tmpfile420
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    cat /tmp/tmpfile420 >/sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    modify /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses, change value from 2 to 8
    ${cmd}    set variable    chmod 777 /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    sed "s/2/8/g" /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses > /tmp/tmpfile420
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    cat /tmp/tmpfile420 >/sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    *******************************************************************************************
    ${cmd}    set variable   cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses: ${output}
    ${cmd}    set variable   cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses: ${output}
    ${cmd}    set variable   cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_input
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_input: ${output}
    ${cmd}    set variable   cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_input
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_input: ${output}
    log to console    ********************************************************************************************
    Sleep    180s
    log to console    check fault 1934 present on RMOD_R
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present With Absolute Source    faultId=1934
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}
    log to console    *******************************************************************************************
    ${cmd}    set variable   cat /run/fault_history_log_temp.txt
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /run/fault_history_log_temp.txt: ${output}
    log to console    *******************************************************************************************
    log to console    check fan1 and fan2 avaiability status changed to degraded
    Connect to gnb coam via ssl
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    ${fan_status}    Get fan status    bts_info=${bts_info}
    ${availabilitystatus_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_1}    degraded
    ${availabilitystatus_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_2}    degraded
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    log to console    ****** Step 6: trigger fault 1933 on fan2 ********
    log to console    modify /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses, change value from 8 to 0
    ${cmd}    set variable    chmod 777 /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    sed "s/8/0/g" /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses > /tmp/tmpfile420
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    cat /tmp/tmpfile420 >/sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    modify /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses, change value from 8 to 0
    ${cmd}    set variable    chmod 777 /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    sed "s/8/0/g" /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses > /tmp/tmpfile420
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    cat /tmp/tmpfile420 >/sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    *******************************************************************************************
    Sleep    180s
    log to console    check fault 1933 present on RMOD_R
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present With Absolute Source    faultId=1933
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}
    log to console    check fault 1934 canceled on RMOD_R
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent With Absolute Source    faultId=1934
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}
    log to console    check fan2 avaiability status changed to failed, operational state change to disabled
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    ${fan_status}    Get fan status    bts_info=${bts_info}
    ${availabilitystatus_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_2}    failed
    ${operationalstate_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_2}    disabled
    ${availabilitystatus_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_1}    failed
    ${operationalstate_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_1}    disabled
    log to console    ****** Step 7: modify actRadioFanFailureEarlyNotif to true ********
    Modify actRadioFanFailureEarlyNotif    value=true
    Sleep    300s
    log to console     check no 1933 or 1934 fault reported on RU
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent With Absolute Source    faultId=1933
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent With Absolute Source    faultId=1934
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}
    log to console    fault 1933 reported on FAN_R_1 and FAN_R_2
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1933
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}/FAN_R-1
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1933
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}/FAN_R-2
    log to console    ***************** Step 8***************************
    log to console    modify /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses, change value from 0 to 8
    ${cmd}    set variable    chmod 777 /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    sed "s/0/8/g" /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses > /tmp/tmpfile420
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    cat /tmp/tmpfile420 >/sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    120s
    log to console    fault 1934 reported on FAN_R_1
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1934
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}/FAN_R-1
    log to console    fault 1933 reported on FAN_R_2
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1933
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}/FAN_R-2
    log to console    check fan status
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    ${fan_status}    Get fan status    bts_info=${bts_info}
    ${availabilitystatus_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_1}    degraded
    ${operationalstate_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_2}    disabled
    ${availabilitystatus_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_2}    failed
    ${operationalstate_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_2}    disabled
    log to console    ****** Step 9: modify actRadioFanFailureEarlyNotif to false ********
    Modify actRadioFanFailureEarlyNotif    value=false
    log to console    all fault on FAN_R canceled
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent    faultId=1934
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}/FAN_R-
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent    faultId=1933
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}/FAN_R-
    log to console    Fault 1933 reported on RMOD
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present With Absolute Source    faultId=1933
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index_r}
    ${flag}    set variable    ${True}
    [Teardown]  run keywords    run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect  connection=ASIK Master    AND
    ...    run keyword and ignore error    run keyword if    ${flag}==${True}    env recovery for 9275    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    AND
    ...    run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=1933    AND
    ...    run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=1934   AND
    ...    run keyword and ignore error    Check ERR Or WRN From Syslog    sys_logs_path=/tmp/btslog2/      UTE_logs_path=${UTE_logs_path}
    ...    base_file=${Base_ERR_WRN_csv_path}    Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15    Fail_Case=${False}
    ...    Clear_log=${False}    FilesSystem=/dev/vda2      Max_used_space_ratio=0.85

Get fan status
    [Arguments]    ${bts_info}    ${ru_index}=3
    ${rmod}    set variable    ${bts_info['radioModules']['rmod']}
    ${rmod_num}    get length      ${rmod}
    FOR    ${index}    IN RANGE    ${rmod_num}
        ${internal}    set variable    ${bts_info['radioModules']['rmod'][${index}]['id']['configuration']}
        ${index_ru}    Fetch From Right    ${internal}    -
        Exit For Loop If 	'${index_ru}'=='${ru_index}'
    END
    [Return]    ${bts_info['radioModules']['rmod'][${index}]['fanStatus']}

Fault 1933 and 1934 with low temperature
    [Arguments]    ${ru_index}=3
    ${client}    set variable    frmonShellClient localhost 2000
    ${flag}    set variable    ${False}
    log to console    set actRadioFanFailureEarlyNotif to true
    Modify actRadioFanFailureEarlyNotif    value=true
    Connect to Common Unit Master
    log to console    ******* Step 1: log in RU (AHFII 1)********
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    log to console    ******* Step 2 : modify trigger time and threshold ********
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    log to console    2.2 create fan proxy
    ${cmd}   Set Variable    echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    2.3 get tcs file
    ${cmd}   Set Variable    echo '/CI/ConfigAccess_Module action fetch DECODED "tcs_parameters.bin" "/ram/tcs.json"'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    2.4 modify  Nrpm_fail to 2,  Fmin to 45
    log to console    get init value for Nrpm_fail
    ${output}  csn.execute  command=${sudo} cat /ram/tcs.json | grep -i Nrpm_fail    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Nrpm_fail": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_nrpm_fail}   Set Variable    ${init_value_list}[0]
    log to console    get init value for Fmin
    ${output}  csn.execute  command=${sudo} cat /ram/tcs.json | grep -i Fmin    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Fmin": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_fmin}   Set Variable    ${init_value_list}[0]
    csn.Send command    command=${sudo} sed -i 's/"Nrpm_fail": ${init_value_nrpm_fail},/"Nrpm_fail": 2,/g' /ram/tcs.json    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} sed -i 's/"Fmin": ${init_value_fmin},/"Fmin": 45,/g' /ram/tcs.json    connection=RU_${ru_index}
    sleep    2s
    log to console    2.5 update config to RF
    ${cmd}    catenate    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs_parameters.bin"
    ...    "/ram/tcs.json"'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    2.6 reboot ru
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset    ru_index=${ru_index}
    Sleep    30s
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}
    log to console    check ru reseted, no other alarm reported, after ru lonline, call cells onair
    sleep    5mins
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    log to console    ****** Step 3: go into testability_sw control state *********
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd}   Set Variable    echo "/ action create FanDevice /CI/fan1 /fan/1"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable    echo "/CI/fan1 set control_state TESTABILITY_SW"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    ****** Step 4: trigger fault 1934 on fan1 ********
    log to console    modify /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses, change value from 2 to 4
    ${cmd}    set variable    chmod 777 /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    sed "s/2/4/g" /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses > /tmp/tmpfile420
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    cat /tmp/tmpfile420 >/sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    *******************************************************************************************
    ${cmd}    set variable   cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_pulses: ${output}
    ${cmd}    set variable   cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses: ${output}
    ${cmd}    set variable   cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_input
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan1_input: ${output}
    ${cmd}    set variable   cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_input
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_input: ${output}
    log to console    *******************************************************************************************
    Sleep    180s
    log to console    check fault 1934 present on FAN_R_
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1934
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    log to console    *******************************************************************************************
    ${cmd}    set variable   cat /run/fault_history_log_temp.txt
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    log to console    cat /run/fault_history_log_temp.txt: ${output}
    log to console    *******************************************************************************************
    log to console    check status for fan1
    Connect to gnb coam via ssl
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    ${fan_status}    Get fan status    bts_info=${bts_info}
    ${availabilitystatus_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_1}    degraded
    log to console    ****** Step 5: trigger fault 1933 on fan2 ********
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    log to console    modify /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses, change value from 2 to 0
    ${cmd}    set variable    chmod 777 /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    sed "s/2/0/g" /sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses > /tmp/tmpfile420
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    cat /tmp/tmpfile420 >/sys/devices/platform/pss_pp23/fda73004.hwmon/hwmon/hwmon5/fan2_pulses
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    180s
    log to console    check fault 1933 present on FAN_R_
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1933
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    log to console    check status for fan2
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    ${fan_status}    Get fan status    bts_info=${bts_info}
    ${availabilitystatus_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_2}    failed
    ${operationalstate_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_2}    disabled
    log to console    ****** Step 6: modify actRadioFanFailureEarlyNotif to false ********
    Modify actRadioFanFailureEarlyNotif    value=false
    log to console    check all alarms canceled
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    sleep    300s
    log to console    ****** Step 7: modify actRadioFanFailureEarlyNotif to true ********
    Modify actRadioFanFailureEarlyNotif    value=true
    log to console    fault 1934 reported on FAN_R_, fault 1933 reported on FAN_R_
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1934
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1933
    ...   source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-
    log to console    check fan status
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    ${fan_status}    Get fan status    bts_info=${bts_info}
    ${availabilitystatus_fan_1}    set variable    ${fan_status['fans'][0]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_1}    degraded
    ${availabilitystatus_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_2}    failed
    ${operationalstate_fan_2}    set variable    ${fan_status['fans'][1]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_2}    disabled
    ${flag}    set variable    ${True}
    [Teardown]  run keywords    run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect  connection=ASIK Master    AND
    ...    run keyword and ignore error    run keyword if    ${flag}==${True}    env recovery for 9275    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections

Feature_Enable_and_Disabled_with_Radio_FAN_Work_Normally
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${btsName}    selenium_coam.get_bts_name
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=J
    run keyword and ignore error    Selenium Logout And Close Browser
    FOR    ${index}    IN RANGE    3
        log to console    Modify actRadioFanFailureEarlyNotif to true
        Modify actRadioFanFailureEarlyNotif    value=true
        sleep    60s
        log to console    Modify actRadioFanFailureEarlyNotif to false
        Modify actRadioFanFailureEarlyNotif    value=false
    END
    log to console    make call for nr cell 1
    Set PA Ports For All RUs
    Nr cell access control for 9275
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${600}    tput_from=self_define

Commission SCF Accorfing configuration
    [Arguments]    ${btsName}    ${config_id}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _config${config_id}.xml
    ${config_on_bts}    Fetch From Right    ${btsName}    config
    Run Keyword If    '${config_on_bts}'!='${config_id}'    Commissioning SCF And Check On Air    ${SCF_upload}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

Set PA Ports For All RUs
    ${PA_RU2}    Get PA Ports For each RU    ru_index=${1}
    ${PA_RU3}    Get PA Ports For each RU    ru_index=${2}
    ${PA_RU4}    Get PA Ports For each RU    ru_index=${3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU4}

Nr cell access control for 9275
    [Arguments]    ${mrbtsId}=${948}    ${nrBtsId}=${1116}    ${cell_id_call}=${1}    ${connection}=GNB_OAM
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    @{nr_cell_all}    Evaluate    @{nr_cell_1}+@{nr_cell_2}+@{nr_cell_3}+@{nr_cell_4}+@{nr_cell_5}+@{nr_cell_6}
    ${nr_cell_num}    Get Length    ${nr_cell_all}
    FOR    ${cell_id}    IN RANGE    1    ${nr_cell_num}+1
        run keyword If    '${cell_id}'!='${cell_id_call}'    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    parameter=qRxLevMin    value=${-22}    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrBtsId}/NRCELL-${cell_id}
        ...    operation=update    connection=${connection}
        ...    ELSE    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrBtsId}/NRCELL-${cell_id}    parameter=qRxLevMin    value=${-65}
        ...    operation=update    connection=${connection}
        Sleep    5s
    END
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

Modify actRadioFanFailureEarlyNotif
    [Arguments]    ${value}    ${connection}=GNB_OAM
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    parameter=actRadioFanFailureEarlyNotif    value=${value}
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/FMCADM-1
        ...    operation=update    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

env recovery for 9275
    [Arguments]    ${ru_index}=3
    ${client}    set variable    frmonShellClient localhost 2000
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd}   Set Variable    echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable    echo '/CI/ConfigAccess_Module action delete "fans.bin"'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable    echo '/CI/ConfigAccess_Module action delete "tcs_parameters.bin"'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable    echo '/CI/ConfigAccess_Module action terminate'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset    ru_index=${ru_index}
    Sleep    30s
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
    [Teardown]  run keywords    run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect  connection=ASIK Master

Get RU Temperature from WEBUI
    [Arguments]    ${ru_index}=3
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock    version=${SBTS_verion}
    Wait Until keyword Succeeds    3x    10s    selenium_coam.configure_statistics_diagnostic_test    radio=RMOD-${ru_index}
    Wait Until keyword Succeeds    3x    10s    selenium_coam.start_statistics_diagnostic_test
    sleep    60
    ${result}    selenium_coam.get_rf_temperature_supervision    radio_id=RMOD-${ru_index}
    ${temp_ru}    get from dictionary    ${result}[0]    Temperature value
    log to console    ${temp_ru}
    Set Test Variable    ${temp_ru}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

Get btsName
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
	${btsName}    selenium_coam.get_bts_name
    Set Suite Variable    ${btsName}
    [Teardown]    Selenium Logout And Close Browser
