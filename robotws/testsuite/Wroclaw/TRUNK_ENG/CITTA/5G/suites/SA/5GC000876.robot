*** Settings ***
Documentation
...    This test suite verifies the feature 5GC000876 Radio Admission Control - SA mode
...    Subfeatures covered: 5GC000876-A and 5GC000876-G

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_WO_TTI    PY310    RF50

Resource    ../../resources/main_resources.robot

# -- extra resources --
Variables    ${RESOURCES}/messages_definition.py
Library    ute_tshark

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/5GC000876.resources
${TPUT_MBPS_DL}    ${50}
${TPUT_MBPS_UL}    ${50}

# -- test scenario variables --
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg

*** Test Cases ***
5GC000876-A_-_PDU_Session_Resource_Release_For_Multiple_PDU_Sessions_With_One_PDU_Session_Remaining
    [Documentation]    This test case verifies if dmission Control works during PDU Session Resource Release procedure
    ...    where AMF requests multiple PDU Sessions to be released while one PDU Session remains
    [Setup]    [PRE]5GC000876-A_-_PDU_Session_Resource_Release_For_Multiple_PDU_Sessions_With_One_PDU_Session_Remaining
    [Teardown]    [POST]5GC000876-A_-_PDU_Session_Resource_Release_For_Multiple_PDU_Sessions_With_One_PDU_Session_Remaining
    SA 5G Attach UE"1"
    Establish Three PDU Sessions
    Start Collecting Tcpdump - First PDU Session
    Release First PDU Session Initiated By AMF
    Stop Collecting Tcpdump - First PDU Session
    Verify PDU Session Release Messages Flow
    Start DL And UL Traffic For PDU"2" UE"1" QFI"1"
    Start Collecting Tcpdump - Second PDU Session
    Release Second PDU Session Initiated By AMF
    Stop Collecting Tcpdump - Second PDU Session
    Verify PDU Session Release Messages Flow
    Release Third PDU Session Initiated By AMF

5GC000876-G_-_Initial_Context_Setup_Without_UE_Radio_Capability
    [Documentation]    This test case verifies if Admission Control works during Initial Context Setup procedure where
    ...    AMF requests one PDU session without UE Radio Capability.
    [Setup]    [PRE]5GC000876-G_-_Initial_Context_Setup_Without_UE_Radio_Capability
    [Teardown]    [POST]5GC000876-G_-_Initial_Context_Setup_Without_UE_Radio_Capability
    Start Collecting Pcap Logs
    Turn Off UE Capabilities Information In NGAP Initial Context Setup Request
    SA 5G Attach UE"1"
    Establish PDU Session And Verify Ngap InitialContextSetupResponse Message
    Trigger AMF-Initiated UE Context Release Procedure
    Exit Idle Mode
    Stop Collecting Pcap Logs
    Verify "2" Ngap InitialContextSetupRequest Message Exist
    Verify UE Radio Capability Is Not Visible In Ngap InitialContextSetupRequest Messages
    Verify "2" Ngap InitialContextSetupResponse Message Exist
    Verify "4" Ngap UERadioCapabilityInfoIndication Message exist
    Verify "2" E1AP BearerContextSetupRequest Message Exist
    Verify "2" E1AP BearerContextSetupResponse Message Exist
    Verify "2" F1AP UEContextSetupRequest Message Exist
    Verify "2" F1AP UEContextSetupResponse Message Exist

*** Keywords ***
Test suite preconditions
    Commission eNB To SA Mode

[PRE]5GC000876-A_-_PDU_Session_Resource_Release_For_Multiple_PDU_Sessions_With_One_PDU_Session_Remaining
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[POST]5GC000876-A_-_PDU_Session_Resource_Release_For_Multiple_PDU_Sessions_With_One_PDU_Session_Remaining
    SA 5G Detach UE"1"
    Report miscellaneous KPIs
    Stop WTS

[PRE]5GC000876-G_-_Initial_Context_Setup_Without_UE_Radio_Capability
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[POST]5GC000876-G_-_Initial_Context_Setup_Without_UE_Radio_Capability
    SA 5G Detach UE"1"
    Report miscellaneous KPIs
    Stop WTS

# -- test steps --
Establish Three PDU Sessions
    [Tags]    DESIGNSTEP
    SA Set Traffic Type For PDU"2" UE"1"
    SA Setup Primary PDU Session For PDU"1" UE"1" GW"1" NWSLICE"1"
    SA Setup Additional PDU Session For PDU"2" UE"1" GW"2" NWSLICE"1"
    SA Setup Additional PDU Session For PDU"3" UE"1" GW"3" NWSLICE"1"

Start Collecting Tcpdump - First PDU Session
    [Tags]    DESIGNSTEP
    Start Collecting Tcpdump    tcpdump_file_name=e1_f1_pdu1

Release First PDU Session Initiated By AMF
    [Tags]    DESIGNSTEP
    Release PDU Session "1" For UE "1" Initiated By AMF

Stop Collecting Tcpdump - First PDU Session
    [Tags]    DESIGNSTEP
    Stop Collecting Tcpdump Logs    tcpdump_file_name=e1_f1_pdu1

Verify PDU Session Release Messages Flow
    [Tags]    DESIGNSTEP
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    alias=Admission_control
    FOR    ${message}    IN    @{REQUIRED_MESSAGES}
        ${packets_count}=    ute_tshark.get_packets_count
        ...    packet_filter=${message['filter']}
        ...    packet_name=${message['name']}
        ...    pcap_file_path=${TCPDUMP_FILE}
        ...    alias=Admission_control
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${packets_count}>=${1}
        ...    msg=Packet ${message['name']} is missing.
    END
    ute_tshark.teardown_tshark    alias=Admission_control

Start Collecting Tcpdump - Second PDU Session
    [Tags]    DESIGNSTEP
    Start Collecting Tcpdump    tcpdump_file_name=e1_f1_pdu2

Start DL And UL Traffic For PDU"${pdu_id}" UE"${ue_id}" QFI"${qfi}"
    [Tags]    DESIGNSTEP
    LOG TO CONSOLE    \n------- Start traffic -------
    SA Start Traffic In SA Mode    pdu=${pdu_id}    ue=${ue_id}    qfi=${qfi}    dir=dl    mbps=${TPUT_MBPS_DL}
    SLEEP    5
    SA Verify If Throughput Is Started    ue=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    dir=dl
    SA Start Traffic In SA Mode    pdu=${pdu_id}    ue=${ue_id}    qfi=${qfi}    dir=ul    mbps=${TPUT_MBPS_UL}
    SLEEP    5
    SA Verify If Throughput Is Started    ue=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    dir=ul

Release Second PDU Session Initiated By AMF
    [Tags]    DESIGNSTEP
    Release PDU Session "2" For UE "1" Initiated By AMF

Stop Collecting Tcpdump - Second PDU Session
    [Tags]    DESIGNSTEP
    Stop Collecting Tcpdump Logs    tcpdump_file_name=e1_f1_pdu2

Release Third PDU Session Initiated By AMF
    [Tags]    DESIGNSTEP
    Release PDU Session "3" For UE "1" Initiated By AMF

Start Collecting Pcap Logs
    [Tags]    DESIGNSTEP
    Start Tshark Packet Capturing
    Start Collecting Tcpdump    tcpdump_file_name=e1_f1_without_ue_radio_capability

Turn Off UE Capabilities Information In NGAP Initial Context Setup Request
    [Tags]    DESIGNSTEP
    [Documentation]    Command 'amf_ue_ics_param' updates/displays online changeable AMF Initial Context Setup parameters.
    ...    Argument 'include_ue_capabilities=off' exclude UE Capability IE in NGAP Initial Context Setup Request.
    ${command}    SET VARIABLE    amf_ue_ics_param id=1 ue=1 include_ue_capabilities=off
    ute_wtssim.execute_egate_command
    ...    cmd=${command}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    Verify If UE Capabilities Information Is Turn Off In NGAP Initial Context Setup Request

Establish PDU Session And Verify Ngap InitialContextSetupResponse Message
    [Tags]    DESIGNSTEP
    SA Setup Primary PDU Session For PDU"1" UE"1" GW"1" NWSLICE"1"

Trigger AMF-Initiated UE Context Release Procedure
    [Tags]    DESIGNSTEP
    LOG TO CONSOLE    \n------- Trigger AMF-Initiated UE Context Release Procedure -------
    ${command}    SET VARIABLE     ue_ng_ctx_release id=1 cause=NAS_normal_release
    ${pass_regexp}    SET VARIABLE    UE.*: IS IDLE
    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=30s

Exit Idle Mode
    [Tags]    DESIGNSTEP
    LOG TO CONSOLE    \n------- Exit Idle Mode -------
    ${command}    SET VARIABLE     ue_im_exit id=1
    ${pass_regexp}    SET VARIABLE    UE.*: UE performed IM exit
    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=30s

Stop Collecting Pcap Logs
    [Tags]    DESIGNSTEP
    SLEEP    5    reason=Ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=admission_control
    Stop Collecting Tcpdump Logs   tcpdump_file_name=e1_f1_without_ue_radio_capability

Verify "${amount}" Ngap InitialContextSetupRequest Message Exist
    [Tags]    DESIGNSTEP
    ${initial_context_setup_request}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.pDUSessionID == 1 && ngap.InitialContextSetupRequest_element
    ...    alias=admission_control
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${initial_context_setup_request}==${amount}
    ...    msg=Amount of Ngap InitialContextSetupRequest (${initial_context_setup_request}) is not equal to ${amount}

Verify UE Radio Capability Is Not Visible In Ngap InitialContextSetupRequest Messages
    [Tags]    DESIGNSTEP
    ${capability_in_initial_context_setup_request}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.id == 117 && ngap.InitialContextSetupRequest_element
    ...    alias=admission_control
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${capability_in_initial_context_setup_request}==${0}
    ...    msg=UE Radio Capability Is Visible In Ngap InitialContextSetupRequest

Verify "${amount}" Ngap InitialContextSetupResponse Message Exist
    [Tags]    DESIGNSTEP
    ${initial_context_setup_response}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.InitialContextSetupResponse_element
    ...    alias=admission_control
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${initial_context_setup_response}==${amount}
    ...    msg=Amount of Ngap InitialContextSetupResponse (${initial_context_setup_response}) is not equal to ${amount}

Verify "${amount}" Ngap UERadioCapabilityInfoIndication Message exist
    [Tags]    DESIGNSTEP
    ${capability_info_indicator}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.UERadioCapabilityInfoIndication_element
    ...    alias=admission_control
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${capability_info_indicator}==${amount}
    ...    msg=Amount of Ngap UERadioCapabilityInfoIndication (${capability_info_indicator}) is not equal to ${amount}

Verify "${amount}" E1AP BearerContextSetupRequest Message Exist
    [Tags]    DESIGNSTEP
    ${e1ap_bearer_context_setup_request}    ute_tshark.get_packets_count
    ...    packet_filter=e1ap.BearerContextSetupRequest_element
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=admission_control
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${e1ap_bearer_context_setup_request}==${amount}
    ...    msg=Amount of E1AP BearerContextSetupRequest (${e1ap_bearer_context_setup_request}) is not equal to ${amount}

Verify "${amount}" E1AP BearerContextSetupResponse Message Exist
    [Tags]    DESIGNSTEP
    ${e1ap_bearer_context_setup_response}    ute_tshark.get_packets_count
    ...    packet_filter=e1ap.BearerContextSetupResponse_element
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=admission_control
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${e1ap_bearer_context_setup_response}==${amount}
    ...    msg=Amount of E1AP BearerContextSetupResponse (${e1ap_bearer_context_setup_response}) is not equal to ${amount}

Verify "${amount}" F1AP UEContextSetupRequest Message Exist
    [Tags]    DESIGNSTEP
    ${f1ap_ue_context_setup_request}    ute_tshark.get_packets_count
    ...    packet_filter=f1ap.UEContextSetupRequest_element
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=admission_control
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${f1ap_ue_context_setup_request}==${amount}
    ...    msg=Amount of F1AP UEContextSetupRequest (${f1ap_ue_context_setup_request}) is not equal to ${amount}

Verify "${amount}" F1AP UEContextSetupResponse Message Exist
    [Tags]    DESIGNSTEP
    ${f1ap_ue_context_setup_response}    ute_tshark.get_packets_count
    ...    packet_filter=f1ap.UEContextSetupResponse_element
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=admission_control
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${f1ap_ue_context_setup_response}==${amount}
    ...    msg=Amount of F1AP UEContextSetupResponse (${f1ap_ue_context_setup_response}) is not equal to ${amount}

# -- internals --
Release PDU Session "${pdu_number}" For UE "${ue_id}" Initiated By AMF
    LOG TO CONSOLE    \n------- AMF Initiated PDU Session "${pdu_number}" Release Procedure -------
    ${command}    SET VARIABLE    ue_pdu_session_release ue=${ue_id} pdu=${pdu_number} by=amf
    ${pass_regexp}    SET VARIABLE    Successfully released PDU Session with ID ${pdu_number}
    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=30s

Stop Collecting Tcpdump Logs
    [Arguments]    ${tcpdump_file_name}
    SLEEP    5    reason=Ensure all essential packets has been captured
    Stop Collecting Tcpdump    ${tcpdump_file_name}
    Download Tcpdump File From GNB    ${tcpdump_file_name}

Start Collecting Tcpdump
    [Arguments]    ${tcpdump_file_name}
    SET SUITE VARIABLE    ${TCPDUMP_FILE_PATH_ON_GNB}    /tmp/${tcpdump_file_name}.pcap
    ${cmd}=    SET VARIABLE    ${__SSHPASS_TO_ENB_CMD__} "cd /tmp && tcpdump -i any -f sctp -U -w ${tcpdump_file_name}.pcap"
    Start Process    ${cmd}    shell=yes
    SLEEP    5    reason=Ensure all essential packets has been captured

Stop Collecting Tcpdump
    [Arguments]    ${tcpdump_file_name}
    ${kill_tcpdump_proces}=    SET VARIABLE
    ...    ps -ef | grep ${tcpdump_file_name}.pcap | grep -v grep | awk '{print $2}' | xargs kill -s SIGTERM
    Run On Smod    ${kill_tcpdump_proces}
    SLEEP    5    reason=Ensure tcpdump finished working after sending SIGTERM

Download Tcpdump File From GNB
    [Documentation]    Download tcpdump file from /tmp directory
    [Arguments]    ${tcpdump_file_name}
    ${TCPDUMP_logs}    Prepare Logs Directory Path    TCPDUMP_${tcpdump_file_name}    with_timestamp=${FALSE}
    SET SUITE VARIABLE    ${TCPDUMP_FILE}    ${TCPDUMP_logs}/${tcpdump_file_name}.pcap
    Fetch From Smod    ${TCPDUMP_FILE_PATH_ON_GNB}    ${TCPDUMP_FILE}
    Run On Smod    rm ${TCPDUMP_FILE_PATH_ON_GNB}

Verify If UE Capabilities Information Is Turn Off In NGAP Initial Context Setup Request
    ${pass_regexp}=    SET VARIABLE    AMF 1 Initial Context Setup Parameters
    ${egate_cmd}=    SET VARIABLE    amf_ue_ics_param id=1 ue=1
    ${command_result}    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=${egate_cmd}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=30s
    ${match}    ${ue_capabilities}=    SHOULD MATCH REGEXP    ${command_result}    include_ue_capabilities\\s*(off)
    SHOULD BE TRUE    '${ue_capabilities}'=='off'
    ...    msg=UE Capabilities Information Is Not Turn Off In NGAP Initial Context Setup Request

Start Tshark Packet Capturing
    ${tshark_logs}    Prepare Logs Directory Path    tshark/admission_control    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    alias=admission_control
    ...    log_dir=${tshark_logs}
    ...    log_name=admission_control
    ute_tshark.start_capturing    capture_filter=sctp    alias=admission_control
