*** Settings ***
Resource    ./SG11_Common_lib_variable.robot
Resource    ./SG11_Common_admin.robot
Resource    ./SG11_Common_selenium.robot
Resource    ./SG11_Common_log_capture.robot
Resource    ./SG11_Common_log_analyzer.robot

*** Variables ***


*** Keywords ***
Clean Up Env
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=l2stream
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=btslog
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=testVM_Tcpdump
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=oamTShark
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=gnb_pm_counters
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=gnb_coam_snapShot
    Run Keyword And Ignore Error    COAM.Teardown Admin
    Run Keyword And Ignore Error    SHERPA.Teardown    sherpa
    Run Keyword And Ignore Error    Run    rm ${OUTPUT_DIR}/*Aasys*.txt
    Run Keyword And Ignore Error    Run    rm ${OUTPUT_DIR}/ue_proxy_logs*.zip

Common Setting
    Import Testline Variables
    Clean Up Env
    Create Suite Directory
    Backup Scf    ${SUITE_LOG_DIRECTORY}    before_suite
    Run Keyword And Ignore Error    Get All Testline Information And Set Suite Variable

Import Testline Variables
    ${ret}    ${host_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${testline_config_path}=    Set Variable    /home/ute/testline_configuration/${host_name}/
    ${ret}=    Run Keyword And Return Status    File Should Exist    ${testline_config_path}/__init__.py
    ${testline_config_path}=    Set Variable If    "${ret}"=="${True}"    ${testline_config_path}
    ...    /home/ute/testline_init_results/configs/${host_name}/
    Log    Testline init file is ${testline_config_path}      console=${True}
    Import Variables    ${testline_config_path}
    Set Suite Variable    ${GNB_PDU_IP}            ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    Set Suite Variable    ${GNB_PDU_PORT}          ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    Set Suite Variable    ${GNB_PDU}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
    Set Suite Variable    ${TLPC_IP}               ${tl.test_pc.default_ssh_connection_details.addr}
    Set Suite Variable    ${TLPC_SSH_UE}           ${tl.test_pc.default_ssh_connection_details.username}
    Set Suite Variable    ${TLPC_SSH_PWD}          ${tl.test_pc.default_ssh_connection_details.password}
    Set Suite Variable    ${NRBTSID}               ${tl.gnbs[0].global_bts_id}
    Set Suite Variable    ${MRBTSID}               ${tl.gnbs[0].instance_id}
    Set Suite Variable    ${SBTS_ADDR}             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable    ${SSH_USERNAME}          ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable    ${SSH_PASSWORD}          ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Set Suite Variable    ${HTTP_USERNAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
    Set Suite Variable    ${HTTP_PASSWORD}         ${tl.gnbs[0].cu.oam_http_connection_details.password}

Create Suite Directory
    [Documentation]    This keyword is to create a directory for storing suite level logs.
    ...
    ...    ${SUITE_LOG_DIRECTORY} is a suite variable.
    ...    before refine: Test_Suite_Folder_1605087516120
    ...    after refine: Test_Suite_Folder_20201112151625116
    Log To Console    Create Suite Directory...
    Log    ${SUITE_NAME}
    ${time_string}    DateTime.Get Current Date    result_format=timestamp
    ${time_string}    String.Replace String Using Regexp    ${time_string}    (-|:|\\.|\\s)    ${EMPTY}
    ${suite_name2}    String.Replace String    ${SUITE_NAME}    ${SPACE}    _
    Create Directory    ${OUTPUT_DIR}/log/${suite_name2}_${time_string}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}    ${OUTPUT_DIR}/log/${suite_name2}_${time_string}

Get All Testline Information And Set Suite Variable
    SG11_Common_admin.Get Software Version
    Get BTS Type And Status
    Print Testline Info Ahead Of Report

Print Testline Info Ahead Of Report
    Set Suite Metadata    Software Version Total    ${SW_VERSION_TOTAL}
    Set Suite Metadata    Software Version    ${SW_VERSION}

SG11 Common Suite Setup
    Common Setting


SG11 Common Suite Teardown
    Backup Scf    ${SUITE_LOG_DIRECTORY}    after_suite


SG11 Common Case Setup
    Create Test Directory
    # Start GNB Syslog
    Start BTSlog

Create Test Directory
    [Documentation]    This keyword is to create a directory for storing case level logs.
    ...
    ...        ${TEST_LOG_DIRECTORY} is a test variable.
    Log To Console    Create Case Directory...
    ${SUITE_LOG_DIRECTORY}    Get Variable Value    ${SUITE_LOG_DIRECTORY}    ${EMPTY}
    Run Keyword If    "${SUITE_LOG_DIRECTORY}"=="${EMPTY}"    Create Suite Directory
    ${test_name2}    string.Replace String    ${TEST_NAME[:50]}    ${space}    _
    Create Directory    ${SUITE_LOG_DIRECTORY}/${test_name2}
    Set Test Variable    ${TEST_LOG_DIRECTORY}    ${SUITE_LOG_DIRECTORY}/${test_name2}


SG11 Common Case Teardown
    [Arguments]    ${mode}=${EMPTY}    ${ue_index_list}=None
    ${ue_index_list_0}    Create List    ${0}
    ${ue_index_list}    Set Variable If    '${ue_index_list}'=='None'    ${ue_index_list_0}    ${ue_index_list}
    FOR    ${ue_index}    IN    @{ue_index_list}
        Run Keyword And Ignore Error    Power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}
    END
    Run Keyword If    '${mode}'!='debug'    Backup Scf    ${SUITE_LOG_DIRECTORY}    after_case
    # Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Copy UE Log
    # Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Stop And Collect GNB Syslog
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Stop BTSlog
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Save Coam SnapShot
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Display All Active Alarms
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${TEST_LOG_DIRECTORY}
    ...    ${CURDIR}/filter_msg.txt    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt

Copy UE Log
    Run Keyword And Ignore Error    Run    cp ${OUTPUT_DIR}/*Aasys*.txt ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Run    cp ${OUTPUT_DIR}/ue_proxy_logs*.zip ${TEST_LOG_DIRECTORY}

Hard Reboot GNB
    PDU.Setup Pdu    ${GNB_PDU}    alias=pdu_alias_gnb
    PDU.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    Sleep    2s
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb

#=======PA=======
Get HBTE Attenuation value
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]get PA value
    ...    *******************
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    ${value_1}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[${ru_id}].attenuation_ports[0]}    attenuator_device=HBTE
    ${value_2}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[${ru_id}].attenuation_ports[1]}    attenuator_device=HBTE
    ${value_3}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[${ru_id}].attenuation_ports[2]}    attenuator_device=HBTE
    ${value_4}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[${ru_id}].attenuation_ports[3]}    attenuator_device=HBTE
    ${PA_original_value}    create list    ${value_1}    ${value_2}
    set suite variable    ${PA_original_value}
    [return]    ${PA_original_value}

Set HBTE Attenuation value
    [Arguments]    ${value}
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0]}    value=${value[0]}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1]}    value=${value[1]}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2]}    value=${value[2]}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3]}    value=${value[3]}    attenuator_device=HBTE