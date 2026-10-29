*** Settings ***
Documentation
...    CB007949_B_B4c - this user scenario describes the successful operation of SCell Change with TDD PCell to homogenous 3CC TDD
...    using legacy CB006138 3CC mixed configurations upon reception of A1-PCell measurement from UE.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LPQ_AP_LOO
Metadata    variant    SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_WO_TTI    PY310    RF50

Variables    ${RESOURCES}/dist_names.py

Resource    ../../resources/main_resources.robot
Resource    ../../../resources/iphy/iphy.resource

Library    ${RESOURCES}/workarounds.py

# -- Setup / Teardown
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/CB007949-B.resources
${LUA}    ${RESOURCES}/egate.cfg
${SCFC}    ${RESOURCES}/scf.xml
${IPHY}    ${RESOURCES}/iphy.xml
${UE_ID}    ${1}
${NUMBER_OF_RMODS}    ${4}
${timeout}    ${1800}
${counter_ids}    M55118C06506,M55118C06507
${NUMBER_OF_MEASUREMENTS}    ${5}

*** Test Cases ***
CB007949_B_B4c_Successful_SCell_change_from_mixed_3CC_configuration_to_homogenous_3CC_TDD_configuration
    [Documentation]
    ...    This test case verifies SCell Change functionality from mixed 3CC configuration to homogenous 3CC TDD configuration.
    [Setup]    [PRE]CB007949_B_B4c_Successful_SCell_change_from_mixed_3CC_configuration_to_homogenous_3CC_TDD_configuration
    [Teardown]    [POST]CB007949_B_B4c_Successful_SCell_change_from_mixed_3CC_configuration_to_homogenous_3CC_TDD_configuration
    Attach and setup PDU for UE
    Send A1 measurement and verify if two FDD SCells are configured
    Send A1 measurement and verify if two TDD SCells are configured
    Verify MaxPayloadSize value change
    Verify SCell Change with PM counters

*** Keywords ***
[PRE]CB007949_B_B4c_Successful_SCell_change_from_mixed_3CC_configuration_to_homogenous_3CC_TDD_configuration
    workarounds.patch_iphy_plugin
    Apply Iphy Configuration    ${IPHY}
    Perform Commissioning    scfc_path=${SCFC}
    Check if BTS is correctly configured    ${NUMBER_OF_RMODS}    ${timeout}
    Start WTS    ${LUA}    check_version=False
    Check if BTS is OnAir

[POST]CB007949_B_B4c_Successful_SCell_change_from_mixed_3CC_configuration_to_homogenous_3CC_TDD_configuration
    Report miscellaneous KPIs
    SA 5G Detach UE"${UE_ID}"
    Stop WTS

# -- test steps --
Attach and setup PDU for UE
    [Tags]    DESIGNSTEP
    SA 5G Attach UE"${UE_ID}"
    SA Set Traffic Type For PDU"1" UE"${UE_ID}"
    SA Setup Primary PDU Session For PDU"1" UE"${UE_ID}" GW"1" NWSLICE"1"

Send A1 measurement and verify if two FDD SCells are configured
    [Tags]    DESIGNSTEP
    Start collecting tcpdump    tcpdump_file_name=F1AP_mixed_3CC_configuration    # for F1AP packets
    ${tshark_logs}    Prepare Logs Directory Path    tshark/    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth4
    ...    alias=mixed_3CC_configuration
    ...    log_dir=${tshark_logs}
    ...    log_name=mixed_3CC_configuration.pcap
    ute_tshark.start_capturing    alias=mixed_3CC_configuration    capture_filter=sctp
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} event=A1 meas_id=1 srsrp_nr=75
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    Sleep    5s    reason=Ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=mixed_3CC_configuration
    LOG TO CONSOLE    \n------- Verify Messages mixed 3CC configuration ------
    ${packets_count}    ute_tshark.get_packets_count
    ...    packet_filter=nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 50 && nr-rrc.physCellId == 54
    ...    alias=mixed_3CC_configuration
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${packets_count}==${1}
    ...    msg=Mixed 3CC configuration was not configured using A1 event.
    [Teardown]    Stop collecting tcpdump    tcpdump_file_name=F1AP_mixed_3CC_configuration

Send A1 measurement and verify if two TDD SCells are configured
    [Tags]    DESIGNSTEP
    Start collecting tcpdump    tcpdump_file_name=F1AP_homogenous_3CC_TDD_configuration    # for F1AP packets
    ${tshark_logs}    Prepare Logs Directory Path    tshark/    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth4
    ...    alias=homogenous_3CC_TDD_configuration
    ...    log_dir=${tshark_logs}
    ...    log_name=homogenous_3CC_TDD_configuration.pcap
    ute_tshark.start_capturing    alias=homogenous_3CC_TDD_configuration    capture_filter=sctp
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} event=A1 meas_id=4 srsrp_nr=85
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    Sleep    5s    reason=Ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=homogenous_3CC_TDD_configuration
    LOG TO CONSOLE    \n------- Verify Messages homogenous 3CC TDD configuration ------
    ${packets_count}    ute_tshark.get_packets_count
    ...    packet_filter=nr-rrc.sCellToReleaseList == 2 && nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 53 && nr-rrc.physCellId == 55
    ...    alias=homogenous_3CC_TDD_configuration
    SHOULD BE TRUE    ${packets_count}==${1}
    ...    msg=Homogenous 3CC TDD configuration was not configured using A1 event.
    [Teardown]    Stop collecting tcpdump    tcpdump_file_name=F1AP_homogenous_3CC_TDD_configuration

Verify MaxPayloadSize value change
    [Tags]    DESIGNSTEP
    LOG TO CONSOLE    \n------- Verify Messages MaxPayloadSize value change ------
    ${packets_count_mixed_3CC_configuration}    ute_tshark.get_packets_count
    ...    packet_filter=nr-rrc.maxPayloadSize == 12
    ...    alias=mixed_3CC_configuration
    SHOULD BE TRUE    ${packets_count_mixed_3CC_configuration}==${1}
    ...    msg=MaxPayloadSize value was not set to "12".
    ${packets_count_homogenous_3CC_TDD_configuration}    ute_tshark.get_packets_count
    ...    packet_filter=nr-rrc.maxPayloadSize == 16
    ...    alias=homogenous_3CC_TDD_configuration
    SHOULD BE TRUE    ${packets_count_homogenous_3CC_TDD_configuration}==${1}
    ...    msg=MaxPayloadSize value was not changed from "12" to "16".

Verify SCell Change with PM counters
    [Tags]    DESIGNSTEP
    Get PM counters
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55118C06506 counter
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55118C06507 counter

# -- internals --
Start collecting tcpdump
    [Arguments]    ${tcpdump_file_name}
    SET SUITE VARIABLE    ${TCPDUMP_FILE_PATH_ON_GNB}    /tmp/${tcpdump_file_name}.pcap
    ${cmd}=    SET VARIABLE    ${__SSHPASS_TO_ENB_CMD__} "cd /tmp && tcpdump -i any -f sctp -U -w ${tcpdump_file_name}.pcap"
    Start Process    ${cmd}    shell=yes
    SLEEP    5    reason=Ensure all essential packets has been captured

Stop collecting tcpdump
    [Arguments]    ${tcpdump_file_name}
    SLEEP    5    reason=Ensure all essential packets has been captured
    Stop Tcpdump    ${tcpdump_file_name}
    Download Tcpdump File From GNB    ${tcpdump_file_name}

Stop Tcpdump
    [Arguments]    ${tcpdump_file_name}
    ${kill_tcpdump_proces}=    SET VARIABLE
    ...    ps -ef | grep ${tcpdump_file_name}.pcap | grep -v grep | awk '{print $2}' | xargs kill -s SIGTERM
    SLEEP    3    reason=Ensure all essential packets has been captured
    Run On Smod    ${kill_tcpdump_proces}

Download Tcpdump File From GNB
    [Documentation]    Download tcpdump file from /tmp directory
    [Arguments]    ${tcpdump_file_name}
    ${TCPDUMP_logs}    Prepare Logs Directory Path    TCPDUMP_${tcpdump_file_name}
    SET SUITE VARIABLE    ${TCPDUMP_FILE}    ${TCPDUMP_logs}/${tcpdump_file_name}.pcap
    Fetch From Smod    ${TCPDUMP_FILE_PATH_ON_GNB}    ${TCPDUMP_FILE}
    Run On Smod    rm ${TCPDUMP_FILE_PATH_ON_GNB}

Get PM counters
    SLEEP    5 min   reason=Wait for generating at least one PM counter
    ${connection}=    Set Variable    get_pm_counters
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    ${counters_info}=    admin.get_pm_counters    counter_ids=${counter_ids}    connection=${connection}
    SET SUITE VARIABLE    ${COUNTERS_INFO}    ${counters_info}

Verify M55118C06506 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${SCELL_CHANGE_ATT_SA}    ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    The number of RRC Reconfigurations attempts in SA mode to change SCells didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "1".
    SHOULD BE TRUE    ${actual_value} == ${1}
    ...    msg=${error_msg}

Verify M55118C06507 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${SCELL_CHANGE_SUCC_SA}    ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    The number of Successful RRC Reconfigurations in SA mode to change SCells didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "1".
    SHOULD BE TRUE    ${actual_value} == ${1}
    ...    msg=${error_msg}
