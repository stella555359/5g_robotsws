*** Settings ***
Documentation
...    The purpose of this test case is to verify if attach and DL|UL throughput for Multi UEs is performed successfully
...    and throughput reaches expected level.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Variables    ${RESOURCES}/dist_names.py

Resource    ../../resources/main_resources.robot

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown  RUN KEYWORDS
...    Stop WTS    AND
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/Multi_ue_throughput_for_single_cell.resources

${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${DELTA}    ${RESOURCES}/delta.json
${START_TPUT_MBPS_DL}    ${100}
${EXPECTED_TPUT_MBPS_DL}    ${95}
${EXPECTED_TPUT_MBPS_UL}    ${20}
${START_TPUT_MBPS_UL}    ${25}
${UES_AMOUNT}     ${5}
${TPUT_INTERVAL_MINUTES}    ${10}
${RMODS_NUMBER}    4

*** Test Cases ***
CNI67972_Multi_UE_DL_Throughput_For_Single_Cell
    [Documentation]
    ...    The purpose of this test case is to verify if attach and DL throughput for Multi UEs is performed
    ...    successfully and throughput reaches expected level.
    [Setup]    [PRE]CNI67972_Multi_UE_DL_Throughput_For_Single_Cell
    [Teardown]    [POST]CNI67972_Multi_UE_DL_Throughput_For_Single_Cell
    Attach And Start "dl" Traffic For "${UES_AMOUNT}" UEs
    Detach And Reestablish Attach And "dl" Traffic For UE3
    SLEEP    ${TPUT_INTERVAL_MINUTES} Minutes
    Verify 'dl' Throughput For '${UES_AMOUNT}' UEs Based On Egate
    Verify Throughput Using PM Counter

CNI67972_Multi_UE_UL_Throughput_For_Single_Cell
    [Documentation]
    ...    The purpose of this test case is to verify if attach and UL throughput for Multi UEs is performed
    ...    successfully and throughput reaches expected level.
    [Setup]    [PRE]CNI67972_Multi_UE_UL_Throughput_For_Single_Cell
    [Teardown]    [POST]CNI67972_Multi_UE_UL_Throughput_For_Single_Cell
    Attach And Start "ul" Traffic For "${UES_AMOUNT}" UEs
    Detach And Reestablish Attach And "ul" Traffic For UE3
    SLEEP    ${TPUT_INTERVAL_MINUTES} Minutes
    Verify 'ul' Throughput For '${UES_AMOUNT}' UEs Based On Egate
    Verify Throughput Using PM Counter

*** Keywords ***
Test suite preconditions
    Add Flag To Swconfig    0x340000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Add Flag To Swconfig    0x9D0000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Reboot BTS    rmods_number=${RMODS_NUMBER}
    Commission eNB To SA Mode
    Delta Commissisoning    ${DELTA}
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[PRE]CNI67972_Multi_UE_DL_Throughput_For_Single_Cell
    SET TEST VARIABLE    ${DIR_LABEL}    DL
    SET TEST VARIABLE    ${PM_COUNTER}    ${PM_COUNTER_DL_PATH}
    SET TEST VARIABLE    ${EXPECTED_TPUT_MBPS}    ${EXPECTED_TPUT_MBPS_DL}
    SET TEST VARIABLE    ${START_TPUT_MBPS}    ${START_TPUT_MBPS_DL}

[POST]CNI67972_Multi_UE_DL_Throughput_For_Single_Cell
    Report miscellaneous KPIs
    Detach All UEs
    Get BTS Alarm History

[PRE]CNI67972_Multi_UE_UL_Throughput_For_Single_Cell
    SET TEST VARIABLE    ${DIR_LABEL}    UL
    SET TEST VARIABLE    ${PM_COUNTER}    ${PM_COUNTER_UL_PATH}
    SET TEST VARIABLE    ${EXPECTED_TPUT_MBPS}    ${EXPECTED_TPUT_MBPS_UL}
    SET TEST VARIABLE    ${START_TPUT_MBPS}    ${START_TPUT_MBPS_UL}

[POST]CNI67972_Multi_UE_UL_Throughput_For_Single_Cell
    Report miscellaneous KPIs
    Detach All UEs
    Get BTS Alarm History

# -- test steps --
Attach And Start "${direction}" Traffic For "${ues_ammount}" UEs
    [Tags]    DESIGNSTEP
    #Attach UEs
    FOR    ${id}    IN RANGE    1    ${ues_ammount}+1
        SA 5G Attach UE"${id}"
    END
    #Setup PDU session for UEs
    FOR    ${id}    IN RANGE    1    ${ues_ammount}+1
        SA Set Traffic Type For PDU"${id}" UE"${id}"
        SA Setup Primary PDU Session For PDU"${id}" UE"${id}" GW"${id}" NWSLICE"1"
    END
    #Start traffic for UEs
    FOR    ${id}    IN RANGE    1    ${ues_ammount}+1
        Start "${direction}" Traffic For PDU"${id}" UE"${id}" QFI"1"
    END

Detach And Reestablish Attach And "${direction}" Traffic For UE3
    [Tags]    DESIGNSTEP
    SA 5G Detach UE"3"
    SA 5G Attach UE"3"
    SA Set Traffic Type For PDU"3" UE"3"
    SA Setup Primary PDU Session For PDU"3" UE"3" GW"3" NWSLICE"1"
    Start "${direction}" Traffic For PDU"3" UE"3" QFI"1"

Verify '${dir}' Throughput For '${ues_amount}' UEs Based On Egate
    [Tags]    DESIGNSTEP
    FOR    ${id}    IN RANGE    1    ${ues_amount}+1
        Run Keyword And Continue On Failure    SA Verify Throughput Using Egate    ue_id=${id}    dir=${dir}    pdu_id=${id}    qfi=1
    END

Verify Throughput Using PM Counter
    [Tags]    DESIGNSTEP
    [Documentation]    Checks if throughput is greater than "${EXPECTED_TPUT_MBPS}" mbps using
    ...                PM counter "${PM_COUNTER}"
    LOG TO CONSOLE    \n------- Verify Throughput Using PM Counter -------
    ${avg_tput_kilobytes}    Get Average Value Of PM Counter    ${PM_COUNTER}    ${TPUT_INTERVAL_MINUTES}
    ${avg_tput_mbps}    EVALUATE    ${avg_tput_kilobytes} * 8 / 1000 / 60 / ${UES_AMOUNT}
    SET TEST VARIABLE    ${REAL_TPUT_MBPS_PM_COUNTER}    ${avg_tput_mbps}
    SHOULD BE TRUE    ${avg_tput_mbps} >= ${EXPECTED_TPUT_MBPS}
    ...    msg=Throughput less than expected ${EXPECTED_TPUT_MBPS} mbps: ${avg_tput_mbps} mbps

# -- internals --
Start "${direction}" Traffic For PDU"${pdu_id}" UE"${ue_id}" QFI"${qfi}"
    [Tags]    DESIGNSTEP
    LOG TO CONSOLE    \n------- Start traffic -------
    SA Start Traffic In SA Mode    pdu=${pdu_id}    ue=${ue_id}    qfi=${qfi}    dir=${direction}    mbps=${START_TPUT_MBPS}
    SLEEP    5
    SA Verify If Throughput Is Started    ue=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    dir=${direction}

SA Verify Throughput Using Egate
    [Arguments]    ${ue_id}    ${dir}    ${pdu_id}    ${qfi}=1
    [Documentation]    Checks if throughput reached expected level using egate command bearer_stats.
    ...    Parameters:
    ...    `ue` - specified UE ID
    ...    `dir` - traffic direction: ul|dl
    ...    `pdu_id` - id of PDU
    LOG TO CONSOLE    \n------- Verify Throughput Using Egate FOR UE "${ue_id}" -------
    ${throughput}    SA Get Traffic Bearer Statistics    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi}    traffic_direction=${dir}
    ${avg_tput_mbps}=    Evaluate    ${throughput}[average_traffic]/1000000
    Should Be True    ${avg_tput_mbps} >= ${EXPECTED_TPUT_MBPS}    msg=Throughput less than expected ${EXPECTED_TPUT_MBPS}Mbps: ${avg_tput_mbps}Mbps

Detach All UEs
    FOR    ${id}    IN RANGE    1     ${UES_AMOUNT}+1
        SA 5G Detach UE"${id}"
    END

Get BTS Alarm History
    ${connection}=    Set Variable    historic_alarms
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    ${historic_alarms}=    admin.get_historic_alarms    timeout=60    connection=${connection}
    FOR    ${alarm}    IN    @{historic_alarms}
        LOG    Fault: ${alarm['faultId']}, Alarm: ${alarm['alarmId']}, Name: ${alarm['faultName']}, Severity: ${alarm['severity']}
    END
    [Teardown]    admin.teardown    connection=${connection}
