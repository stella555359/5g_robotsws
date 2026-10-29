*** Settings ***
Documentation    ...
#Documentation    https://taf-sw-dcap-rd.docs.taf.ute.nsn-rdnet.net/en/stable/interfaces/interface.html#module-taf.sw.dcap.rd.interface
#Suite Setup       Run Keywords    Suite Setup Update GNB    #force_reboot=True    #scf_file=${DELTA_FILE}    skip_reboot=${False}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
##Suite Teardown    Common Suite Teardown    debug
##Test Setup        Common Test Setup
##Test Teardown     Run Keywords    Common Test Teardown    debug
##...                AND    Get Current Testline Config Files    log_path=${TEST_LOG_DIRECTORY}/myconfigs/
#Force Tags        CIT    RAN_5G_TDD
#...               CDRT    FR1    Owner_yuema    PRI-High
#...               SBTS00    SBTS23R1    SBTS22R3    SBTS22R4    RAN_5G    CN1_SQ
#...               CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    AP_REG
#Library           taf.sw.dcap.rd       WITH NAME    rd
#Library           taf.collectors.dcap    WITH NAME    dcap
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}            ${CURDIR}/config
#${DELTA_FILE}          ${CURDIR}/Delta_Conf_5GC001208_A.json
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot    sosreport
#${COUNT}               0
#${DU_HOST}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${DU_USER}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#${DU_PWD}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#${filepath}           /tmp/ASP-1740_startup.log
#${LOG_PATH}           ${OUTPUT DIR}
#
#*** Test Cases ***
#
#5GC001208 ET test for catching log by classical method
#    [Tags]    case1
#    Start GNB AP Syslog    ${LOG_PATH}
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=10    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=5    trf_id=1
#    Wait Until Keyword Succeeds    3min    5s    SA UE Check Throughput    ${UE_ID}    9    4
#    Start GNB BIP By Admin Method
#    Sleep    5s
#    Stop Gnb BIP By Admin Method
#    Setup Ttitrace
#    Begin Ttitrace
#    Sleep    5s
#    Stop Ttitrace
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA 5G Detach    ue_id=${UE_ID}
#    Stop And Collect Syslog    log_dir=${LOG_PATH}
#
#5GC001208 ET test for catching all log by DCAP
#    [Tags]    case2
#    ${trace_id}    DCAP start collect log      10.0.1.2
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=10    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=5    trf_id=1
#    Wait Until Keyword Succeeds    3min    5s    SA UE Check Throughput    ${UE_ID}    9    4
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA 5G Detach    ue_id=${UE_ID}
#    [Teardown]    DCAP stop collect log    ${trace_id}    log_save_path=${LOG_PATH}/dcp1/
#
#5GC001208 ET test for catching specific log by DCAP
#    [Tags]    case3
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=10    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=5    trf_id=1
#    Wait Until Keyword Succeeds    3min    5s    SA UE Check Throughput    ${UE_ID}    9    4
#    Collect Specific Log By Dcap    5s    cp_5g
#    Collect Specific Log By Dcap    5s    L2Ps_Component
#    Collect Specific Log By Dcap    5s    bip_interface_mirroring
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA 5G Detach    ue_id=${UE_ID}
#
##Test For Collect C-plane Traces
##    Collect C-plane Traces
#
#*** Keywords ***
#
#DCAP start collect log
#    [Documentation]     start Capture log by DCAP
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${bts_host} | Yes | ie. "10.0.1.2" |
#    ...    | ${bts_port} | No | default "443" |
#    ...    | ${bts_username} | No | default "Nemuadmin" |
#    ...    | ${bts_password} | No | ie. "nemuuser" |
#    ...    | ${remote_host} | No | default "None" |
#    ...    | ${remote_username} | No | default. "None" |
#    ...    | ${remote_password} | No | default "None" |
#    ...    | ${gnb_trace_profile} | No | default "None" |
#    ...    | ${enb_trace_profile} | No | default "None" |
#    ...    | ${bts_trace_profile} | No | default "None" |
#    ...    | ${vdu_trace_profile} | No | default "None" |
#    ...    | ${vcu_trace_profile} | No | default "None" |
#    ...
#    ...    Examples:
#    ...    | ${tarce_id}    |     DCAP start collect log  |  enb_trace_profile=dcap-lite-default |   bts_trace_profile=dcap-lite-default     |
#    ...    | DCAP stop collect log   |     ${trace_id}    |
#    ...    | ${tarce_id}    |   DCAP start collect log  |  bts_host=192.168.100.129 | bts_password=Nokia@123  |
#    ...    | DCAP stop collect log   |     ${trace_id}    |
#    ...    | ...      vdu_trace_profile=dcap-lite-default |   vcu_trace_profile=dcap-lite-default     |
#    [Arguments]      ${bts_host}=10.0.1.2     ${bts_port}=443      ${bts_username}=Nemuadmin     ${bts_password}=nemuuser
#    ...    ${remote_host}=${None}     ${remote_username}=${None}     ${remote_password}=${None}
#    ...    ${gnb_trace_profile}=${None}    ${enb_trace_profile}=${None}    ${bts_trace_profile}=${None}
#    ...    ${vdu_trace_profile}=${None}    ${vcu_trace_profile}=${None}
#    ...    ${duration}=1
#    Run Keyword And Ignore Error     Run    DCAP_Basic_controller start
#    ${dcap_ip}     set variable if    ${remote_host}==${None}      127.0.0.1       ${remote_host}
#    Wait Until Keyword Succeeds    60    10    rd.connect_to     host=${dcap_ip}      port=9443     rd_version=dcapv3    secure=${True}
#    &{bts_info}     create dictionary    host=${bts_host}    port=${bts_port}
#    ...    username=${bts_username}     password=${bts_password}
#    ${output}     rd.start_trace    tag=ta_trace      duration=${duration}     bts=${bts_info}
#    ...           gnb_trace_profile=${gnb_trace_profile}     bts_trace_profile=${bts_trace_profile}
#    ...           enb_trace_profile=${enb_trace_profile}
#    ...           vdu_trace_profile=${vdu_trace_profile}     vcu_trace_profile=${vcu_trace_profile}
#    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
#    [Return]   ${trace_id}
#
#DCAP start collect specific log
#    [Documentation]     start Capture log by DCAP
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${bts_host} | Yes | ie. "10.0.1.2" |
#    ...    | ${bts_port} | No | default "443" |
#    ...    | ${bts_username} | No | default "Nemuadmin" |
#    ...    | ${bts_password} | No | ie. "nemuuser" |
#    ...    | ${remote_host} | No | default "None" |
#    ...    | ${remote_username} | No | default. "None" |
#    ...    | ${remote_password} | No | default "None" |
#    ...    | ${gnb_trace_profile} | No | default "None" |
#    ...    | ${enb_trace_profile} | No | default "None" |
#    ...    | ${bts_trace_profile} | No | default "None" |
#    ...    | ${vdu_trace_profile} | No | default "None" |
#    ...    | ${vcu_trace_profile} | No | default "None" |
#    ...    | ${gnb_custom_profile} | No | cp_5g, immediateSnapshot_5g, pmFiles5g, condor5gSyslog, SCF5g, L2Ps_Component, L2Lo_Component,
#    ...    L2HiRlc_Component, L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa, bip_interface_mirroring,
#    ...    L1stream, Tracer_5g |
#    ...    Examples:
#    ...    | ${tarce_id}    |     DCAP start collect log  |  enb_trace_profile=dcap-lite-default |   bts_trace_profile=dcap-lite-default     |
#    ...    | DCAP stop collect log   |     ${trace_id}    |
#    ...    | ${tarce_id}    |   DCAP start collect log  |  bts_host=192.168.100.129 | bts_password=Nokia@123  |
#    ...    | DCAP stop collect log   |     ${trace_id}    |
#    ...    | ...      vdu_trace_profile=dcap-lite-default |   vcu_trace_profile=dcap-lite-default     |
#    [Arguments]      ${bts_host}=10.0.1.2     ${bts_port}=443      ${bts_username}=Nemuadmin     ${bts_password}=nemuuser
#    ...    ${remote_host}=${None}     ${remote_username}=${None}     ${remote_password}=${None}
#    ...    ${gnb_trace_profile}=${None}    ${enb_trace_profile}=${None}    ${bts_trace_profile}=${None}
#    ...    ${vdu_trace_profile}=${None}    ${vcu_trace_profile}=${None}
#    ...    ${duration}=1    ${gnb_custom_profile}=${None}
#    Run Keyword And Ignore Error     Run    DCAP_Basic_controller start
#    ${dcap_ip}     set variable if    ${remote_host}==${None}      127.0.0.1       ${remote_host}
#    Wait Until Keyword Succeeds    60    10    rd.connect_to     host=${dcap_ip}      port=9443     rd_version=dcapv3    secure=${True}
#    &{bts_info}     create dictionary    host=${bts_host}    port=${bts_port}
#    ...    username=${bts_username}     password=${bts_password}
#    ${output}     rd.start_trace    tag=ta_trace      duration=${duration}     bts=${bts_info}
#    ...           gnb_trace_profile=${gnb_trace_profile}     bts_trace_profile=${bts_trace_profile}
#    ...           enb_trace_profile=${enb_trace_profile}
#    ...           vdu_trace_profile=${vdu_trace_profile}     vcu_trace_profile=${vcu_trace_profile}
#    ...           gnb_custom_profile=${gnb_custom_profile}
#    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
#    [Return]   ${trace_id}
#
#DCAP stop collect log
#    [Documentation]     stop Capture log by DCAP
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${trace_id} | Yes | ${trace_id} |
#    ...    | ${log_save_path} | No | default as ${TEST_LOG_DIRECTORY()}/dcap/ |
#    [Arguments]   ${trace_id}    ${log_save_path}=${TEST_LOG_DIRECTORY()}/dcap/
#    rd.stop_trace     trace_id=${trace_id}
#    ${ret}    run keyword and ignore error     Directory Should Exist      ${log_save_path}
#    run keyword if     '${ret[0]}'=='FAIL'       Create Directory     ${log_save_path}
#    ${zip_path}    rd.get_results    result_id=${trace_id}       target_dir=${log_save_path}/    timeout=200
#    [Return]    ${zip_path}
#
##Collect EMIL from GNB DCAP
##    Set Suite Variable    ${DCAP_ALIAS}    DCAP
##    Set Suite Variable    ${GNB_TRACE_ID}    ${EMPTY}
##    Dcap Setup for GNB1
##    Log    Start collecting Snapshot with DCAP     console=True
##    Create Dcap Session    host=${testline_ip}    alias=${DCAP_ALIAS}
##    ${GNB_TRACE_ID}    DCAP Start Trace    alias=${DCAP_ALIAS}
##    Set suite variable    ${GNB_TRACE_ID}    ${GNB_TRACE_ID['tracer_id']}
##
##Collect EMIL from GNB2 DCAP
##    Get GNB2 testline ip address
##    Set Suite Variable    ${GNB2_DCAP_ALIAS}    GNB2_DCAP
##    Set Suite Variable    ${GNB2_TRACE_ID}    ${EMPTY}
##    Dcap Setup for GNB2
##    Log    Start collecting Snapshot with DCAP     console=True
##    Create Dcap Session    host=${testline2_ip}    alias=${GNB2_DCAP_ALIAS}
##    ${GNB2_TRACE_ID}    DCAP Start Trace    alias=${GNB2_DCAP_ALIAS}
##    Set suite variable    ${GNB2_TRACE_ID}    ${GNB2_TRACE_ID['tracer_id']}
##
##Create Dcap Session
##    [Arguments]      ${host}    ${alias}
##    ${gnb_dcap_conn}=    rd.connect_to    host=${host}    port=9443
##    ...    username=dcapuser   password=dcapadmin!    rd_version=dcapv3    secure=True    alias=${alias}
##
##Dcap Start Trace
##    [Arguments]      ${alias}=${DCAP_ALIAS}
##    ${gnb_custom_profile}=    Create List    cp_5g
##    ${index}    set variable if    'GNB2' in '${alias}'    1    0
##    ${TRACE_ID}=    rd.start_trace    bts=${bts_info[${index}]}    gnb_custom_profile=${gnb_custom_profile}
##    ...    connection=${alias}
##    [return]    ${TRACE_ID}
##
##Dcap Stop Trace
##    [Arguments]    ${trace_id}=${GNB_TRACE_ID}   ${connection}=${DCAP_ALIAS}
##    ${trace_id}    Evaluate    int(${trace_id})
##    ${status}=    rd.stop_trace    trace_id=${trace_id}    connection=${connection}
##    DCAP Get Results    result_id=${trace_id}    connection=${connection}
##    Create EMIL log folder and save log    alias=${connection}
##
##Create EMIL log folder and save log
##    [Arguments]    ${alias}=${DCAP_ALIAS}
##    Run Keyword If   'GNB2' not in '${alias}'   execute cmd on pc   mkdir -p ${SAVE LOG DIRECTORY}/GNB1_EMIL/
##    Run Keyword If   'GNB2' not in '${alias}'   execute cmd on pc
##    ...    mv /tmp/dcap*.zip ${SAVE LOG DIRECTORY}/GNB1_EMIL/
##    Run Keyword If   'GNB2' in '${alias}'   execute cmd on pc   mkdir -p ${SAVE LOG DIRECTORY}/GNB2_EMIL/
##    Run Keyword If   'GNB2' in '${alias}'   execute cmd on pc
##    ...    mv /tmp/dcap*.zip ${SAVE LOG DIRECTORY}/GNB2_EMIL/
##
##Dcap Get Results
##    [Arguments]    ${result_id}    ${target_dir}=${None}    ${connection}=${DCAP_ALIAS}
##    ${filepath}=    rd.get_results    result_id=${result_id}    connection=${connection}
##    [Return]    ${filepath}
##
##Wait until DCAP is active
##    [Arguments]    ${host_ip}=${tl.test_pc[0].default_ssh_connection_details.addr}
##    Wait until Keyword Succeeds    20x    3s   Create dcap session    ${host_ip}
##
##Start DCAP Containers
##    [Arguments]    ${host_ip}=${testline_ip}
##    Start Process    DCAP_Basic_controller    start    alias=dcap_control
##    ${result}=    Wait For Process    dcap_control
##    Log to console    ${result.stdout}
##    Should contain    ${result.stdout}    All DCAP Basic containers started successfully
##    Wait Until Keyword Succeeds    60s    5s    Check DCAP status
##
##Check DCAP status GNB1
##    ${DCAP_STATUS}=    execute cmd on pc   DCAP_Basic_controller status
##    should contain    ${DCAP_STATUS}    DCAP Basic health check passed. Have a nice trace !
##
##Check DCAP status GNB2
##    ${DCAP_STATUS}=    execute cmd on pc gnb2   DCAP_Basic_controller status
##    should contain    ${DCAP_STATUS}    DCAP Basic health check passed. Have a nice trace !
##
##Dcap Setup for GNB1
##    ${DCAP_VERSION}=    execute cmd on pc    DCAP_Basic_updates
##    run keyword if    'FB2307' in '${DCAP_VERSION}'    log
##    ...    the DCAP version less FB2309, capture EMIL will failure    level=WARN
##    ${DCAP_STATUS}=    execute cmd on pc    DCAP_Basic_controller status
##    Run keyword if    'DCAP Basic health check passed' not in '''${DCAP_STATUS}'''
##    ...    execute cmd on pc    DCAP_Basic_controller restart    120
##    Wait Until Keyword Succeeds    100s    5s    Check DCAP status GNB1
##    &{bts_dict}=    Create Dictionary    host=10.0.1.2    port=443    username=Nemuadmin    password=nemuuser
##    ${bts_info}=     Create List    ${bts_dict}
##    Set Suite Variable    ${bts_info}
##
##Dcap Setup for GNB2
##    ${DCAP_VERSION}=    execute cmd on pc gnb2   DCAP_Basic_update
##    run keyword if    'FB2307' in '${DCAP_VERSION}'    log
##    ...    the DCAP version less FB2309, capture EMIL will failure    level=WARN
##    ${DCAP_STATUS}=    execute cmd on pc gnb2    DCAP_Basic_controller status
##    Run keyword if    'DCAP Basic health check passed' not in '''${DCAP_STATUS}'''
##    ...    execute cmd on pc gnb2    DCAP_Basic_controller restart    120
##    Wait Until Keyword Succeeds    100s    5s    Check DCAP status GNB2
##    &{bts2_dict}=    Create Dictionary    host=10.0.1.3    port=443    username=Nemuadmin    password=nemuuser
##    append to List    ${bts_info}     ${bts2_dict}
##    Set Suite Variable    ${bts_info}
##
##Execute Cmd On PC
##    [Arguments]    ${cmd}
##    ${ret}=    Run    ${cmd}
##    [Return]    ${ret}
#
#Collect C-plane Traces
#    Collect Specific Log By Dcap    5s    cp_5g
#
#Collect Specific Log By Dcap
#    [Arguments]    ${time}    ${log_type}=cp_5g
#    &{bts}=  Create Dictionary
#    ...  host=10.0.1.2
#    ...  port=443
#    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#    @{gnb_custom_profile}=  Create List  ${log_type}
#    &{trace}=  Create Dictionary
#    ...  bts=${bts}
#    ...  gnb_custom_profile=${gnb_custom_profile}
#    dcap.Create DCAP Trace Collector
#    ...  name=dcap
#    ...  trace=${trace}
#    dcap.Setup Collectors   names=dcap
#    dcap.Start Collectors   names=dcap
#    Sleep    ${time}
#    dcap.Stop_collectors     names=dcap
#    dcap.Collect Collectors  names=dcap
#    [teardown]    dcap.Teardown Collectors  names=dcap
