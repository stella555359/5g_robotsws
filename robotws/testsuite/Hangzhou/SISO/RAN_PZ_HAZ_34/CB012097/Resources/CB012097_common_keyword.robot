*** Settings ***
Library      random
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009275_AQQQA/Resources/CB009275_common_keyword.robot
Variables    ./variable.py

Documentation
...    author: Yang Di
...    contact: di.yang@nokia-sbell.com
...    Group: HGZ3_SG5

*** Variables ***
@{FAULT_ID_ALLOW}    1933    1934
@{FAULT_ID_LIST}     1932    1933    1934

*** Keywords ***
Trigger fault 1932 on RMOD
    [Arguments]    ${ru_index}=2
    AlarmWatchdog.add_allow_alarms    fault_id=1932
    ${client}    set variable    frmonShellClient localhost 2000
    Fetch Json Using FRMON    con_file=tcs_fans
    log to console    Modify fanDetectionPeriod, speedResponseDetectionAllowed and fanTestRpmMin in fans file
    log to console    Get init value for fanDetectionPeriod
    ${output}  csn.execute  command=sudo cat /ram/tcs_fans.json | grep -i fanDetectionPeriod    connection=RU_${ru_index}
    ${pattern}   Set Variable    "fanDetectionPeriod": .*,
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}
    ${init_value_fanDetectionPeriod}   Set Variable    ${init_value_list}[0]
    log to console    Get init value for speedResponseDetectionAllowed
    ${output}  csn.execute  command=sudo cat /ram/tcs_fans.json | grep -i speedResponseDetectionAllowed    connection=RU_${ru_index}
    ${pattern}   Set Variable    "speedResponseDetectionAllowed": .*,
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}
    ${init_value_speedResponseDetectionAllowed}   Set Variable    ${init_value_list}[0]
    log to console    Get init value for fanTestRpmMin
    ${output}  csn.execute  command=sudo cat /ram/tcs_fans.json | grep -i fanTestRpmMin    connection=RU_${ru_index}
    ${pattern}   Set Variable    "fanTestRpmMin": .*,
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}
    ${init_value_fanTestRpmMin}   Set Variable    ${init_value_list}[0]
    ${cmd}   Set Variable
    ...    sudo sed -i 's/${init_value_fanDetectionPeriod}/"fanDetectionPeriod": 60000,/g' /ram/tcs_fans.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable
    ...    sudo sed -i 's/${init_value_speedResponseDetectionAllowed}/"speedResponseDetectionAllowed": false,/g' /ram/tcs_fans.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable
    ...    sudo sed -i 's/${init_value_fanTestRpmMin}/"fanTestRpmMin": 900,/g' /ram/tcs_fans.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    Update config to RF
    ${cmd}   catenate    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs_fans.bin"
    ...    "/ram/tcs_fans.json"'|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    ${random_list}=    Evaluate    random.sample(range(0, 3), 2)    modules=random
    Set Test Variable    ${random_list}
    Execute Command on RU to Change Flag
    Reboot RU and Check Cells
    [Teardown]  run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}

Check Fans State
    [Arguments]    ${availabilityStatus}=None    ${operationalState}=enabled    ${ru_index}=2
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    log to console    Check fans status
    ${rmod}    set variable    ${bts_info['radioModules']['rmod']}
    ${rmod_num}    get length      ${rmod}
    FOR    ${index}    IN RANGE    ${rmod_num}
        ${internal}    set variable    ${rmod[${index}]['id']['internal']}
        ${index_ru}    Fetch From Right    ${internal}    -
        Exit For Loop If 	'${index_ru}'=='${ru_index}'
    END
    ${fan_status}    set variable    ${rmod[${index}]['fanStatus']['fans']}
    FOR    ${index}    IN    @{random_list}
        ${administrativeState_fan}    set variable    ${fan_status[${index}]['stateInfo']['administrativeState']}
        should be equal    ${administrativeState_fan}    Unlocked
        ${availabilitystatus_fan}    set variable If  '${availabilityStatus}'!='None'
        ...    ${fan_status[${index}]['stateInfo']['availabilityStatus']}
        Run Keyword If  '${availabilityStatus}'!='None'  should be equal    ${availabilitystatus_fan}
        ...    ${availabilityStatus}
        ${operationalstate_fan}    set variable    ${fan_status[${index}]['stateInfo']['operationalState']}
        should be equal    ${operationalstate_fan}    ${operationalState}
    END

BTS Report Fault on FAN
    [Arguments]    ${faultId}=1932    ${ru_index}=2
    FOR    ${index}    IN    @{random_list}
        ${tmp}  Evaluate  ${index}+1
        Wait For Expect Fault Present    faultId=${faultId}
        ...    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-${tmp}    timeout=5min
    END
    log to console    Check fault ${faultId} present on FAN_R
    Wait Until Keyword Succeeds    5min    30s   CB009275_common_keyword.Expect Fault Should Absent on WebUI
    ...   faultId=${faultId}  source=[${btsname}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}

Cancel Fault via RF Command
    [Arguments]    ${ru_index}=2
    ${client}    set variable    frmonShellClient localhost 2000
    Connect to Common Unit Master
    log to console    ****** Recovery ********
    Connect to RU With Allocated IP    asik_alias=ASIK Master    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    Execute Command on RU to Change Flag    flag_value=0
    ${cmd}   Set Variable   echo "/ action create FanDevice /CI/fan1 /fan/1"|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable   echo "/CI/fan1 set control_state RADIO_SW"|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable   echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/ConfigAccess_Module action delete "tcs_fans.bin"'|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/ConfigAccess_Module action delete "tcs_parameters.bin"'|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo "/CI/ConfigAccess_Module action delete ALL"|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo "/CI/ConfigAccess_Module action terminate"|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo "/CI/fan1 action terminate"|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    Connect To Node Via RU Connection    node_id=1    ru_alias=RU_${ru_index}
    ${cmd}   Set Variable    echo "/CI/ThermoModule action override OFF"|${client}
    ${output}  csn.execute  command=${cmd}    connection=node_1
    sleep    2s
    FOR    ${fault}    IN    @{FAULT_ID_LIST}
        Wait For Expect Fault To Disappear    faultId=${fault}    timeout=4min
    END
    [Teardown]  run keywords    run keyword and ignore error    AlarmWatchdog.remove_allow_alarms
    ...    fault_id=${FAULT_ID_LIST}    AND    run keyword and ignore error    COAM Teardown gnb connections    AND
    ...    run keyword and ignore error    csn.Disconnect  connection=node_1    AND
    ...    run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect  connection=ASIK Master

CB009275 Set
    [Arguments]    ${value}=false
    ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FMCADM-1
    scf.Activate Parameter Value    dist_name=${dist_name}  new_value=${value}  p_name=actRadioFanFailureEarlyNotif

Get BtsName
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${btsName}    selenium_coam.get_bts_name
    Set Suite Variable    ${btsName}
    [Teardown]    Selenium Logout And Close Browser

Get SW version
    Connect to gnb coam via ssl
    ${SW_Version}=    coam.get_sw_version    connection=GNB_OAM
    Set Suite variable    ${SW_Version}
    ${release}    set variable    ${SW_Version.split("_")[0]}
    #${release}=    Evaluate    '${SW_Version}'.split('_')[0]
    Set Suite Variable    ${release}

Trigger fault with High Temperature
    [Arguments]    ${faultId}=1934    ${ru_index}=2
    AlarmWatchdog.add_allow_alarms    fault_id=${FAULT_ID_ALLOW}
    ${client}    set variable    frmonShellClient localhost 2000
	Modify tcs_parameters.json
    Go into TESTABILITY_SW control_state
    log to console    ****** To trigger fault ${faultId} ********
    @{random_list}=    Create List    0     1     2
    Set Test Variable    ${random_list}
    run keyword if    ${faultId}==${1934}   run keywords   Execute Command on RU to Change Flag
    ...    flag_value=0x00000E88    AND    Execute Command on RU to Change Flag    flag_value=0x000002EE    ELSE
    ...    Execute Command on RU to Change Flag    flag_value=0x00000001
    Connect To Node Via RU Connection    node_id=1    ru_alias=RU_${ru_index}
    ${cmd}   Set Variable    echo "/ action create ThermometerDevice /CI/ThermoModule /temp/made1/internal1"|${client}
    ${output}  csn.execute  command=${cmd}    connection=node_1
    sleep    2s
    ${cmd}   Set Variable    echo "/CI/ThermoModule action override TEMPERATURE ${temp_plus}"|${client}
    ${output}  csn.execute  command=${cmd}    connection=node_1
    [Teardown]  run keywords  Run Keyword And Ignore Error    csn.disconnect    connection=node_1    AND
    ...    run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}

Execute Command on RU to Change Flag
    [Arguments]    ${flag_value}=750    ${ru_index}=2
    FOR    ${index}    IN    @{random_list}
        ${cmd}   Set Variable  ccsShell.sh rad -mpw 0x12004${index} ${flag_value}
        ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
        Should Contain    ${output}    written succesfully
        sleep    2s
    END
    ${cmd}   Set Variable   cat /mnt/runtime/swconfig.txt
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable   sync
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    log to console    ****** Log in RU, and execute command *********

Connect To Node Via RU Connection
    [Arguments]    ${node_id}    ${node_alias}=node_${node_id}    ${nodes}=${Node}    ${ru_alias}=RU_${ru_index}
    ${nodes_length}    Get Length    ${nodes}
    FOR    ${i}    IN RANGE    0    ${nodes_length}
        ${node_ip}    run keyword if    ${Node[${i}]}[id]==${node_id}    set variable    ${Node[${i}]}[ip]
        Exit For Loop If    '${node_ip}'!='${None}'
    END
    csn.connect to    alias=${node_alias}
    ...               hostname=${node_ip}
    ...               proxy=${ru_alias}
    ...               username=serviceuser
    ...               password=v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=

Trigger fault 1933 after High Temperature
    [Arguments]    ${ru_index}=2
    Connect to Common Unit Master
    Connect to RU With Allocated IP    asik_alias=ASIK Master    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    log to console    ****** To trigger fault 1933 ********
    Execute Command on RU to Change Flag    flag_value=0x00000001
    log to console    check fault 1934 canceled on RMOD_R
    Wait For Expect Fault To Disappear    faultId=1934    timeout=5min
    Wait until keyword succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EfaultId_FanBroken
    BTS Report Fault on RMOD    faultId=1933

BTS Report Fault on RMOD
    [Arguments]    ${faultId}=1932    ${ru_index}=2
    Connect to gnb coam via ssl
    log to console    Check fault ${faultId} present on RMOD_R
    Wait Until Keyword Succeeds    5min    30s   CB009275_common_keyword.Expect Fault Should Present on WebUI
    ...   faultId=${faultId}  source=[${btsname}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}
    FOR    ${index}    IN    @{random_list}
        ${tmp}  Evaluate  ${index}+1
        Wait For Expect Fault To Disappear    faultId=${faultId}
        ...    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-${tmp}    timeout=5min
    END

Trigger fault with Low Temperature
    [Arguments]    ${faultId}=1933
    AlarmWatchdog.add_allow_alarms    fault_id=${faultId}
    ${client}    set variable    frmonShellClient localhost 2000
    Modify tcs_parameters.json    faultId=${faultId}
    Go into TESTABILITY_SW control_state
    log to console    ****** To trigger fault ${faultId} ********
    ${random_list}=    Evaluate    random.sample(range(0, 3), 2)    modules=random
    Set Test Variable    ${random_list}
    run keyword if    ${faultId}==${1933}    Execute Command on RU to Change Flag    flag_value=0x00000001    ELSE
    ...  run keywords    Execute Command on RU to Change Flag    flag_value=0x00000E88    AND
    ...  Execute Command on RU to Change Flag    flag_value=0x000002EE

Modify tcs_parameters.json
    [Arguments]    ${faultId}=1934    ${ru_index}=2
    ${client}    set variable    frmonShellClient localhost 2000
    Connect to Common Unit Master
    Connect to gnb coam via ssl
    Fetch Json Using FRMON    con_file=tcs_parameters
    log to console    Modify parameters in tcs_parameters file
    log to console    Get init value for Nrpm_fail
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i Nrpm_fail    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Nrpm_fail": .*,
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}
    ${init_value_Nrpm_fail}   Set Variable    ${init_value_list}[0]
    log to console    Get init value for Fmin
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i Fmin    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Fmin": .*,
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}
    ${init_value_Fmin}   Set Variable    ${init_value_list}[0]
    log to console    Get init value for deltaTmulti
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i deltaTmulti    connection=RU_${ru_index}
    ${pattern}   Set Variable    "deltaTmulti": .*,
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}
    ${init_value_deltaTmulti}   Set Variable    ${init_value_list}[0]
    log to console    Get init value for deltaTctl
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i deltaTctl    connection=RU_${ru_index}
    ${pattern}   Set Variable    "deltaTctl": .*,
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}
    ${init_value_deltaTctl}   Set Variable    ${init_value_list}[0]
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i Tblock    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Tblock": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_Tblock}   Set Variable    ${init_value_list}[0]
    ${temp_plus}    Evaluate    ${init_value_Tblock}+1
    Set Test Variable    ${temp_plus}
    ${cmd}   Set Variable
    ...    sudo sed -i 's/${init_value_Nrpm_fail}/"Nrpm_fail": 2,/g' /ram/tcs_parameters.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable
    ...    sudo sed -i 's/${init_value_Fmin}/"Fmin": 45,/g' /ram/tcs_parameters.json
    run keyword if    ${faultId}==${1934}    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable
    ...    sudo sed -i 's/${init_value_deltaTmulti}/"deltaTmulti": 120,/g' /ram/tcs_parameters.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable
    ...    sudo sed -i 's/${init_value_deltaTctl}/"deltaTctl": 120,/g' /ram/tcs_parameters.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    Update config to RF
    ${cmd}   catenate    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs_parameters.bin"
    ...    "/ram/tcs_parameters.json"'|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i Nrpm_fail    connection=RU_${ru_index}
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i Fmin    connection=RU_${ru_index}
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i deltaTmulti    connection=RU_${ru_index}
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i deltaTctl    connection=RU_${ru_index}
    Reboot RU and Check Cells

Reboot RU and Check Cells
    [Arguments]    ${ru_index}=2
    log to console    ****** Reboot RU *********
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset    ru_index=${ru_index}
    Sleep    30s
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair

Go into TESTABILITY_SW control_state
    [Arguments]    ${ru_index}=2
    ${client}    set variable    frmonShellClient localhost 2000
    Connect to RU With Allocated IP    asik_alias=ASIK Master    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    log to console    ****** Go into testability_sw control state *********
    ${cmd}   Set Variable    echo "/ action create FanDevice /CI/fan1 /fan/1"|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable    echo "/CI/fan1 set control_state TESTABILITY_SW"|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s

Check if fault is active on RU in History log
    [Arguments]  ${text}    ${ru_index}=2
    Connect to Common Unit Master
    Connect to RU With Allocated IP    asik_alias=ASIK Master    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    ${output}    csn.execute    command=ls /run -ll | grep fault_history_log_temp.txt    connection=RU_${ru_index}
    ...    timeout=60s
    ${file_status}    run keyword and return status    should not be empty    ${output}
    ${filename}    set variable if      ${file_status}    fault_history_log_temp.txt    fault_history_log.txt
    ${output}  csn.execute  command=cd /run ; cat ${filename}    connection=RU_${ru_index}
    Log to console      ${output}
    ${active}=    Fetch From Left   marker=InActive faults:    string=${output}
    Log to console      ${active}
    ${output}  csn.execute  command=cd /run ; cat ${filename}|grep -i ${text}|grep -i active
    ...    connection=RU_${ru_index}
    should not be empty      ${output}
    [Teardown]  run_keywords    csn.disconnect    connection=RU_${ru_index}  AND
    ...                         csn.disconnect    connection=ASIK Master

Modify optionalFansInstalled
    [Arguments]    ${value}    ${connection}=GNB_OAM    ${ru_index}=2
    Connect to gnb coam via ssl
    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning    connection=${connection}
        ...    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/RMOD-${ru_index}    operation=update
        ...    parameter=optionalFansInstalled    value=${value}
    Wait Until Keyword Succeeds    10min    20s    Verify all cells should be onair

Modify Nrpm_fail
    [Arguments]    ${ru_index}=2
    ${client}    set variable    frmonShellClient localhost 2000
    Fetch Json Using FRMON    con_file=tcs_parameters    ru_index=${ru_index}
    log to console    Modify parameters in tcs_parameters file
    log to console    Get init value for Nrpm_fail
    ${output}  csn.execute  command=sudo cat /ram/tcs_parameters.json | grep -i Nrpm_fail    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Nrpm_fail": .*,
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}
    ${init_value_Nrpm_fail}   Set Variable    ${init_value_list}[0]
    ${cmd}   Set Variable
    ...    sudo sed -i 's/${init_value_Nrpm_fail}/"Nrpm_fail": 2,/g' /ram/tcs_parameters.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   catenate    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs_parameters.bin"
    ...    "/ram/tcs_parameters.json"'|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    ${random_list}  Create List  0  1
    Reboot RU and Check Cells
    Set Test Variable  ${random_list}

Fetch Json Using FRMON
    [Arguments]    ${con_file}=fans    ${ru_index}=2
    ${client}    set variable    frmonShellClient localhost 2000
    Connect to Common Unit Master
    Connect to gnb coam via ssl
    log to console    ******* Log in RU ********
    Connect to RU With Allocated IP    asik_alias=ASIK Master    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    log to console    ******* Modify /ram/${con_file}.json ********
    ${cmd}   Set Variable    echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    Get ${con_file} file
    ${cmd}   Set Variable
    ...   echo '/CI/ConfigAccess_Module action fetch DECODED "${con_file}.bin" "/ram/${con_file}.json"'|${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s

