*** Settings ***
Documentation
...   Keywords for ANTINA UUF suite
...   author: Michal Chrzanowski
...   contact: michal.a.chrzanowski@nokia.com

Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations  WITH NAME  GnbAsir
Library      taf.rfrl.bts.devices.asir.basic_logs.GnbAsirHubLog  WITH NAME  AsirLog

Library      xml_parser.py
Library      ./sbts_keywords.py
Library      testsuite.Krakow.RRM.RAN_PZ.features.CB008229.resources.pcap_collector.PcapCollector    WITH NAME    pcap

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      bts_data.py
Library      on_air_tl_preparation.testline_preparation              WITH NAME     tl_prep
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py
Library      taf.rfrl.utilities.logger.custom_logger    WITH NAME    logger
Library      taf.hw.pdu    WITH NAME    pdu

Resource     taf/rfrl/bts/robot/enb.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_UE_keywords.robot


Variables    ./targets.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
# -----------------------------UE-----------------------------
${SMAwave_1_address}                 10.255.60.153
${SMAwave_2_address}                 10.255.60.154
&{snmp_user}                         userName=administrator    authKey=password    privKey=password    authProtocol=MD5    privProtocol=AES
${PDU_HOST}                          pa06.mgt.krk-lab.nsn-rdnet.net

# -----------------------------TL PREP ------------------------------
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}    4689    4479    8000
${SYSLOG_IGNORED_PRINTS}                          ${None}     # String separated by |
${SWCONFIG_PATH}                                  commissionings/Krakow/swconfig/default_swconfig.txt

*** Keywords ***
Custom Suite Setup
    gnbbbu.Install certificate    cert_file=${CA_1_PATH}    cert_type=AdditionalCa    cert_format=PEM
    gnbbbu.install certificate    cert_file=${CA_2_PATH}    cert_type=AdditionalCa    cert_format=PEM

    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                         swconfig_from_path=${SWCONFIG_PATH}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${True}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}

E2E TL ASiR Recommissioning
    update_parameter_of_asir_configuration
    ...    asir_dist_name=ASI-1/BTS-1
    ...    parameter=userLabel
    ...    value=ANTINA

Restart SMAWave
    [Arguments]    ${SMAwave_address}    ${ue_index}=1
    logger.log_info_to_console    -- Restarting SMAWave (IP address = ${SMAwave_address}) --\n
    Reboot UEs    ue_index=${ue_index}
    BuiltIn.sleep    15s

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

Full_bidrectional_L3_call_test
    [Documentation]
    ...    This keyword verifies full combination of Antinas' configs with SMAwave as UE. Due to limited usage
    ...    part of parameters should be correctly set inside keyword.
    ...    00101_N78:   allowing test PLMN 00101 on band 78
    ...    00101_N1:    allowing test PLMN 00101 on band 1
    ...    24408_N78:   allowing test PLMN 24408 on band 78
    ...    24408_N1:    allowing test PLMN 24408 on band 1

    [Arguments]    ${00101_N78}=True    ${00101_N1}=True    ${24408_N78}=True    ${24408_N1}=True
    Block_cells          [4001,4002,4003,4004,4005,2001,2002]

    Power ON SMAwave     SMAwave_address=${SMAwave_1_address}    pdu_port=10    host=${PDU_HOST}
    ...                  snmp_user=${snmp_user}
    Run_keyword_if       ${00101_N78}    Start DLUL Data Transfer And Verify Throughput
    ...                  ue_index=1    duration=120
    ...                  iperf_throughput=250M    dl_expect_tput=250M    dl_deviation=25%
    ...                  iperf_ul_throughput=100M    ul_expect_tput=100M    ul_deviation=75%

    Block_cells          [2003]
    Unblock_cells        [4005]

    Restart SMAWave      ${SMAwave_1_address}
    Run_keyword_if       ${00101_N1}    Start DLUL Data Transfer And Verify Throughput
    ...                  ue_index=1    duration=120
    ...                  iperf_throughput=250M    dl_expect_tput=140M    dl_deviation=25%
    ...                  iperf_ul_throughput=100M    ul_expect_tput=100M    ul_deviation=75%

    Power OFF SMAwave    SMAwave_address=${SMAwave_1_address}    pdu_port=10    host=${PDU_HOST}
    ...                  snmp_user=${snmp_user}

    Block_cells          [4005]
    Unblock_cells        [2003]

    Power ON SMAwave     SMAwave_address=${SMAwave_2_address}    pdu_port=12    host=${PDU_HOST}
    ...                  snmp_user=${snmp_user}

    Run_keyword_if       ${24408_N78}    Start DLUL Data Transfer And Verify Throughput
    ...                  ue_index=2    duration=120
    ...                  iperf_throughput=250M    dl_expect_tput=250M    dl_deviation=25%
    ...                  iperf_ul_throughput=100M    ul_expect_tput=100M    ul_deviation=75%

    Block_cells          [2003]
    Unblock_cells        [4005]

    Restart SMAWave      ${SMAwave_2_address}    ue_index=2
    Run_keyword_if       ${24408_N1}    Start DLUL Data Transfer And Verify Throughput
    ...                  ue_index=2    duration=120
    ...                  iperf_throughput=250M    dl_expect_tput=140M    dl_deviation=25%
    ...                  iperf_ul_throughput=100M    ul_expect_tput=50M    ul_deviation=75%

    Unblock_cells        [4001,4002,4003,4004,2001,2002,2003]

    Power OFF SMAwave    SMAwave_address=${SMAwave_2_address}    pdu_port=12    host=${PDU_HOST}
    ...                  snmp_user=${snmp_user}

    [Teardown]    Run keywords        Postconditions_ForUE    AND
    ...    Power OFF SMAwave    SMAwave_address=${SMAwave_1_address}    pdu_port=10    host=${PDU_HOST}
    ...    snmp_user=${snmp_user}    AND
    ...    Power OFF SMAwave    SMAwave_address=${SMAwave_2_address}    pdu_port=12    host=${PDU_HOST}
    ...    snmp_user=${snmp_user}    AND
    ...    Unblock_cells        [4001,4002,4003,4004,4005,2001,2002,2003]    ignore_error=True

L3_call_test
    [Arguments]    ${arg1}=${None}   ${arg2}=${None}
    log    \n--L3_call_test with arg: ${arg1}, ${arg2}--\n    console=${True}
    Full_bidrectional_L3_call_test    24408_N1=False
