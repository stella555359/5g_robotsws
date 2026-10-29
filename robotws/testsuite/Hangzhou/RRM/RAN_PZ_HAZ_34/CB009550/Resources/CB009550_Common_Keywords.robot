*** Settings ***
Documentation
...    author: y63li
...    contact: ying.15.li@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : CB009550

Library           BuiltIn
Library           OperatingSystem
Library           Collections
Library           String
Library           taf.pdu
Library           Process
Library           taf.config.scf    WITH NAME    scf
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001349-AA/Resources/get_pm_counter.py
Library           taf.rfrl.common_resources.python.stream_manager
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/libraries/get_bts_info.py  WITH NAME    lib
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library           taf.ue.pioneer.client            WITH NAME    client

*** Variables ***
${DU_OAM_IP}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${bts_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${bts_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${host_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}    ${tl.test_pc.default_ssh_connection_details.username}
${host_password}    ${tl.test_pc.default_ssh_connection_details.password}
${tl_scf_dir_path}     ${commissionings_path}/HGZ/${testline_name}/CB009550
${app_addr}     ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${app_port}     ${tl.ues[0].iperf_details.port}
${mrbts_id}     ${tl.gnbs[0].global_bts_id}
${nrbts_id}     ${tl.gnbs[0].instance_id}

${20MHz_5G}    20MHz_5G.xml
${scf_name}        scf_CB009550.xml
${tmp_log_dir}     /home/ute/log
${testline}        7_5_UTE5G402T928
###L3_call###
${UE_TYPE}          ${tl.ues[0].capabilities[-1]}
${data_tranfer}     20Mbits/sec
${ul_duration}     20
${dl_duration}     20
${dltp}     5
${ultp}     2
${NSA_UE_MODE}    NSA
${SA_UE_MODE}    SA
${NSA_attach_mode}    5G_NSA
${SA_attach_mode}    5G_SA
${NSA_nettype}    NSA
${SA_nettype}    SA+NSA
${apn_addr}    ${tl.core.pdns[1].apn}
${GNB_COAM_ALIAS}        GNB_OAM
${SSH_FSP}    FSP Conn
${path}           /home/ute/log/
${full_path}    BTS/CELLS/NRCELL-1/NCELA
${full_path1}    BTS/CELLS/NRCELL-1/NRACH
${full_path2}   BTS/MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1/NRACH
${host}   ${tl.ues[0].ssh_connection_details.addr}
${port}    30999
${username}    ${tl.ues[0].ssh_connection_details.username}
${password}    ${tl.ues[0].ssh_connection_details.password}
${alias}     pioneer
${ue_alias}     mate20x_ue
*** Keywords ***
#---------Common keyword--------------#
CB009550_Common Suite Setup for COAM
    Run Keyword And Ignore Error    CI_interface.Common Suite Setup
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup


CB009550_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown
    Run Keyword And Ignore Error    robot_common_operations.Common Suite teardown


CB009550_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     admin_cli.get_sw_version    connection=${GNB_COAM_ALIAS}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Set Suite Variable    ${sw_version}
    Create directory    ${SUITE_LOG_PATH}

CB009550_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    CB009550_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=${GNB_COAM_ALIAS}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    admin_cli.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    Check If BTS Is OnAir

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${GNB_COAM_ALIAS}

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}    connection=${GNB_COAM_ALIAS}
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

Check If BTS Is OnAir
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=${GNB_COAM_ALIAS}
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Check X2 Status
    Log To Console     \n *** Check X2 Status
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${X2linkstatus}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-0
    ...    filter_param=X2C link status
    Should be equal    ${X2linkstatus}    available

Connect to cOAM as toor4nsn
    [Arguments]    ${alias}=${GNB_COAM_ALIAS}
    csn.Connect To    hostname=${DU_OAM_IP}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${alias}

#-------------------------------Case_setup_and_teardown-------------------------------#
Case Setup
    Log To Console    \n *** Case Setup
    Connect to DU via ssl
    wait until keyword succeeds    30min    3min     Precondition: All cells can be on air
    #wait Until Keyword Succeeds    5min    1min    Check X2 status
    Run Keyword And Ignore Error    robot_common_operations.Common case setup

Case Teardown
    Log To Console    \n *** Case Teardown
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown

eNB SCF Commission
    Log To Console     \n *** eNB SCF Commission
    [Arguments]  ${scf_file_path}    ${connection}=enblte    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    run keyword and continue on failure    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...        msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    BuiltIn.Log    Commission with scf file via rest API successfully.
    [Return]  ${result}
#--------------------------------UE operation----------------------------#
Attach ${ue_num} SA UEs and Data Transfer
    Log    \nAttach ${ue_num} SA UEs and Data Transfer   console=yes
    Attach Multi-UEs and Data Transfer    ue_num=${ue_num}    attach_mode=${SA_attach_mode}   ue_mode=${SA_UE_MODE}
    ...    nettpye=${SA_nettype}    apn_address=${apn_addr}

Stop ${ue_num} traffic and SA UEs Detach
    Log    \nStop ${ue_num} traffic and SA UEs Detach    console=yes
    Run keyword and ignore error     stop traffic and ue detach    ue_num=${ue_num}     ue_mode=${SA_UE_MODE}
	...    apn_address=${apn_addr}

Attach Multi-UEs and Data Transfer
    [Arguments]    ${ue_num}    ${ue_mode}   ${apn_address}
    log to console       Attach Multi power ue
    FOR    ${i}    IN RANGE    ${ue_num}
       log to console       Prepare ue${i}
       Run keyword and ignore error     power_ue.Prepare UE    ue_index=${i}    ue_type=${UE_TYPE}
        ...    get_spark_license=${False}
       log to console       configure UE${i} mode
       Run keyword and ignore error      spark.Config 5G Deployment    nettype=${nettpye}    ue_alias=UE_${i}
       log to console       Attach UE${i} and Verify Status
       Run keyword and ignore error     Attach UE and verify Status  ue_index=${i}
        ...    attach_mode=${attach_mode}
       sleep    3s
       Run keyword and ignore error     Start and Check Traffic    ue_index=${i}
        ...     attach_mode=${attach_mode}    ue_mode=${ue_mode}    nettpye=${nettpye}   apn_address=${apn_address}
       sleep    10s
    END

Attach UE and Verify Status
    log to console       UE attach
    [Arguments]    ${attach_mode}   ${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}   attach_mode=${attach_mode}
    log to console       UE attach verify
    sleep   5s
    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False

Start and Check Traffic
    log to console       Start Traffic
    [Arguments]    ${ue_index}    ${ue_mode}   ${apn_address}
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul      apn_address=${apn_address}
    ...    throughput=${data_tranfer}    duration=4000    ue_type=${UE_TYPE}    ue_mode=${ue_mode}    protocol=UDP
    sleep    3s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}
        ...   throughput=${data_tranfer}    duration=4000   ue_type=${UE_TYPE}    ue_mode=${ue_mode}
    sleep    3s
    log to console       Check Traffic
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=${dltp}    ue_index=${ue_index}
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=${ultp}    ue_index=${ue_index}

stop traffic and ue detach
    [Arguments]    ${ue_num}    ${ue_mode}   ${apn_address}
    log to console     Stop traffic    console = yes
    FOR    ${i}    IN RANGE    ${ue_num}
       log to console      Stop traffic    console = yes
       Run keyword and ignore error     power_ue.Stop traffic    direction=dl    ue_index=${i}    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
	...    apn_address=${apn_address}
       Run keyword and ignore error     power_ue.Stop traffic    direction=ul    ue_index=${i}    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
	...    apn_address=${apn_address}
       log to console      UE Detach    console = yes
       Run keyword and ignore error     power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${i}
    END

#------------------------Modify para------------------------------#
Configure ${para} to ${value}
    Log    \nConfigure ${para} to ${value}   console=yes
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    parameter=${para}
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS}

###------------------------------Counter_Check-------------------###
Enable Counter collect
    Log    \nEnable Counter collect    console=yes
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
    ...    parameter=reportingIntervalPm
    ...    value=5min
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS}

Check PM Counter update as Expect
    Log    \nCheck PM Counter update as Expect   console=yes
    Check PM counter Result should update    full_path=${full_path}    counter_id=M55308C00036
    Check PM counter Result should update    full_path=${full_path}    counter_id=M55308C00037

Check PM Counter Empty
    Log    \nCheck PM Counter Empty   console=yes
    Check PM counter Result should empty    full_path=${full_path}    counter_id=M55308C00036
    Check PM counter Result should empty    full_path=${full_path}    counter_id=M55308C00037

Check PM counter Result should update
    [Arguments]    ${counter_id}    ${full_path}
    ${counter_result}    Check PM counter    ${counter_id}    ${full_path}
    ${counter_max}    Convert To Integer    ${counter_result[-1]}
    Should Be True   ${counter_max}>${0}

Check PM counter Result should empty
    [Arguments]    ${counter_id}    ${full_path}
    ${counter_result}    Check PM counter    ${counter_id}    ${full_path}
    ${counter_max}    Convert To Integer    ${counter_result[-1]}
    Should Be True   ${counter_max}==${0}

Check PM counter
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to DU via ssl
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=${GNB_COAM_ALIAS}
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    #AdminCli disconnection and Test teardown

Get PM counter when modify BWP
    log to console   Get PM counter when modify BWP
    [Arguments]    ${counter_id}    ${full_path}
    ${counter_result}    Check PM counter    ${counter_id}    ${full_path}
    ${counter_value}    Convert To Integer    ${counter_result[-1]}
    [Return]    ${counter_value}


