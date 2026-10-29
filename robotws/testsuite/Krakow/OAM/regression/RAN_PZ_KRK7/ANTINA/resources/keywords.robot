*** Settings ***
Documentation
...   Keywords file for Antina test cases
...   author: maksymilian.wolek@nokia.com

Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py     WITH NAME     sg7keywords
Library      taf.sbts.oam.coam.admin  WITH NAME  admin_sbts
Library      taf/rfrl/procedures/resources/python/connections.py
Library      keywords.py
Library      taf/rfrl/bts/devices/du/commissioning.py
Library      taf.ue
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      taf.rfrl.utilities.logger.custom_logger    WITH NAME    logger
Library      taf.hw.pdu    WITH NAME    pdu
Resource     testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_UE_keywords.robot

*** Keywords ***

Custom Suite Setup
    gnbbbu.Install certificate    cert_file=${CA_1_PATH}    cert_type=AdditionalCa    cert_format=PEM
    gnbbbu.install certificate    cert_file=${CA_2_PATH}    cert_type=AdditionalCa    cert_format=PEM

    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         swconfig_from_path=${SWCONFIG_PATH}
    ...                         list_of_additional_allowed_alarms=${PREP_ALLOWED_ALARMS}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}


Teardown Cell Addition
    gnbbbu.connect    force=${True}
    Common Postconditions           collect_syslog=${True}
    ...                             collect_snapshot_from_ru=${True}
    Perform Full Commissioning on gNB    scf_file=${scf_local_path}
    ...                                  timeout=600


Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Check current [${param}] value from [${object}]
    @{param_list}=     Create List    ${param}
    ${alias}    connections.Get Default Admin Connection Alias
    ${current_value}=    admin_sbts.get_parameter_by_distname    dist_name=${object}
    ...    parameter_list=@{param_list}
    ...    detailed_output=true
    ...    connection=${alias}
    Log to Console    Current ${param} value: ${current_value}

Set parameter [${param}] from [${object}] to [${value}]
    Log to Console    Changing parameter ${param} to value ${value}
    sg7keywords.perform_parameter_recommissioning    dist_name=${object}
    ...                                              parameter=${param}
    ...                                              operation=update
    ...                                              value=${value}

Restore [${param}] from [${object}] to default value [${value}]
    Log To Console    Cleanup after test
    sg7keywords.perform_parameter_recommissioning    dist_name=${object}
    ...                                              parameter=${param}
    ...                                              operation=update
    ...                                              value=${value}

Prepare Cell Before Test
    [Arguments]     ${cell_id_to_l3_call}
    Log To Console    Preparing cell ${cell_id_to_l3_call} before test

    ${cell}=    keywords.get_cell_parameters    ${cell_id_to_l3_call}
    Run Keyword If    ${cell} == None    Fail    Cell with id ${cell_id_to_l3_call} not found

    ${bts_id}=    sg7keywords.get_mrbts_id
    ${delta}=    Generate 50Mhz Delta    bts_id=${bts_id}    cell_id=${cell}[cell_id_to_copy_from]
    Perform Bts Delta Commissioning    delta=${delta}
    Set Test Variable   ${cell}    ${cell}
    Log To Console    Cell ready for testing

Prepare QC Ids And UE Data For Test Cases
    ${HOSTNAME}=   Get Hostname
    &{QC_IDS}=     Get Qc Ids  hostname=${HOSTNAME}    sw_version=${TARGET_SW}
    &{UE_DATA}=    Get Ue Data  hostname=${HOSTNAME}
    Set Suite Variable  ${QC_IDS}     &{QC_IDS}
    Set Suite Variable  ${UE_DATA}    &{UE_DATA}

Restart SMAWave
    [Arguments]    ${SMAwave_address}    ${ue_index}=1
    logger.log_info_to_console    -- Restarting SMAWave (IP address = ${SMAwave_address}) --\n
    Reboot UEs    ue_index=${ue_index}

Power ON SMAwave
    [Arguments]    ${SMAwave_address}    ${pdu_port}    ${host}    ${snmp_user}
    logger.log_info_to_console    -- Power ON SMAWave (IP address = ${SMAwave_address}) --\n
    pdu.setup_pdu    model=HPE    host=${host}   alias=smawave_hpe    snmp_user=${snmp_user}
    pdu.power_on    port=${pdu_port}    pdu_device=smawave_hpe
    BuiltIn.sleep    1m

Power OFF SMAwave
    [Arguments]    ${SMAwave_address}    ${pdu_port}    ${host}    ${snmp_user}
    logger.log_info_to_console    -- Power OFF SMAWave (IP address = ${SMAwave_address}) --\n
    pdu.setup_pdu    model=HPE    host=${host}   alias=smawave_hpe    snmp_user=${snmp_user}
    pdu.power_off    port=${pdu_port}    pdu_device=smawave_hpe

Start DLUL Data Transfer And Verify Throughput
    [Arguments]    ${ue_index}    ${duration}
    ...    ${iperf_throughput}    ${dl_expect_tput}    ${dl_deviation}
    ...    ${iperf_ul_throughput}    ${ul_expect_tput}    ${ul_deviation}
    UE Attach And Start ADB Log    ue_index=${ue_index}
    Sleep    15s
    Log    \n--Starting DLUL data transfer--\n    console=${True}
    Start and Verify Downlink UDP    dt_name=dl_test    ue_index=${ue_index}
    ...    direction=dl    duration=${duration}    iperf_throughput=${iperf_throughput}
    ...    protocol=udp    dl_expect_tput=${dl_expect_tput}    dl_deviation=${dl_deviation}
    Start and Verify Uplink UDP      dt_name=ul_test    ue_index=${ue_index}
    ...    direction=ul    duration=${duration}    iperf_ul_throughput=${iperf_ul_throughput}
    ...    protocol=udp    ul_expect_tput=${ul_expect_tput}    ul_deviation=${ul_deviation}
    Postconditions_ForUE
    Log    \n--Finished DLUL data transfer--\n    console=${True}

UE Throughput Cycle
    [Arguments]    ${cells_to_block}    ${ue_data}    ${ue_key}     ${ue_index}

    sg7keywords.block cells     ${cells_to_block}

    Power ON SMAwave      SMAwave_address=${ue_data}[${ue_key}_address]    pdu_port=${ue_data}[${ue_key}_pdu_port]
    ...                   host=${PDU_HOST}   snmp_user=${snmp_user}

    Start DLUL Data Transfer And Verify Throughput      ue_index=${ue_index}    duration=120
    ...             iperf_throughput=250M    dl_expect_tput=250M    dl_deviation=25%
    ...             iperf_ul_throughput=100M    ul_expect_tput=100M    ul_deviation=75%

    Power OFF SMAwave     SMAwave_address=${ue_data}[${ue_key}_address]    pdu_port=${ue_data}[${ue_key}_pdu_port]
    ...                   host=${PDU_HOST}   snmp_user=${snmp_user}

    Unblock Cells   ${cells_to_block}

    [Teardown]    Run Keywords    Postconditions_ForUE
    ...     AND     Power OFF SMAwave     SMAwave_address=${ue_data}[${ue_key}_address]
    ...             pdu_port=${ue_data}[${ue_key}_pdu_port]     host=${PDU_HOST}   snmp_user=${snmp_user}
    ...     AND     sg7keywords.Unblock cells   [1001,1002,1003,3001,3002,3003]     ignore_error=${True}

L3_call_test
    [Arguments]    ${arg1}=${None}   ${arg2}=${None}
    log    \n--L3_call_test with arg: ${arg1}, ${arg2}--\n    console=${True}

    ${ue_cycles}=   Get Ue Cycles   tl_data=${UE_DATA}

    FOR    ${cycle}    IN    @{ue_cycles}
        IF    '_new_cell' in $cycle['name']
            CONTINUE
        END
        Log To Console  data chosen for cycle ${cycle}
        UE Throughput Cycle    cells_to_block=${cycle['cells_to_block']}
        ...                    ue_data=${UE_DATA}
        ...                    ue_key=${cycle['ue_key']}
        ...                    ue_index=${cycle['ue_index']}
    END
