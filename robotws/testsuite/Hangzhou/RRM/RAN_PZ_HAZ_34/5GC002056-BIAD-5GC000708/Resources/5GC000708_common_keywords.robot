*** Settings ***
Documentation
...    author: Charlotte Wu
...    contact: charlotte.wu@nokia-sbell.com
...    squad group: I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02_GMS

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.config.scf    WITH NAME    scf
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Library    taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library    taf.analyzer.pcap   WITH NAME    pcap
Library      taf.ul.messaging.mtk    WITH NAME    message
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb1_host}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gnb_path}    /tmp/
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${tl_scf_dir_path}    /home/ute/SCF/
${gnb_instance}     ${tl.gnbs[0].global_bts_id}
${cell1_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${bts_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${ALIAS_ASIK}    gnb1
${gNB_CPUE}    /rom/cp_runtime.ini
${UTE_CPUE}    ${CURDIR}/cp_runtime.ini
${gNB_CPUE_PATH}    /tmp/node_CPUE20/tmp
${CPUE_LOG}    startup_cp_ue.log
${gNB_CPUE_LOG_XZ_PATH}    /ffs/run/logs/CPUE20_aasyslog/
${gNB_CPUE_LOG_XZ}    startup_cp_ue.log.xz
${5G1_ANT1}    ${tl.attenuator.attenuator_ports[13].port_no}
${5G1_ANT2}    ${tl.attenuator.attenuator_ports[14].port_no}
${atten_ip}    ${tl.attenuator.ip_addr}
${atten_port}    ${tl.attenuator.port}

*** Keywords ***
## GNB BTS Precondition ##
Prepare the Trunk BTS cell onair
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with Trunk BTS cell onair    ip_addr=${ip_addr}    gnb=${gnb}
    set suite variable    ${cell_status}

Prepare with Trunk BTS cell onair
    [Arguments]     ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}    ${WEBUI_COAM}=${WEBUI_COAM}
    ...     ${tl_scf_filename}=${tl_scf_filename}
    wait until keyword succeeds    3min   30s    Enable RD flag of rdUeContextRequest    ip_addr=${ip_addr}    gnb=${gnb}
    wait until keyword succeeds    3min   30s    Active CPUE log    ip_addr=${ip_addr}    gnb=${gnb}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_filename}
    ...                              timeout=${600}    is_pdl_checking_needed=${False}
    Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air
    #Perform full commission for COAM gnb    WEBUI_COAM=${WEBUI_COAM}    tl_scf_filename=${tl_scf_filename}
    #Wait the gNB cell onair

Perform full commission for COAM gnb
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}    ${tl_scf_filename}=${tl_scf_filename}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.load_commissioning_file_and_check_load_status    ${tl_scf_dir_path}${tl_scf_filename}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    sleep    1min

Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}    ${WEBUI}=${WEBUI_COAM}
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}    WEBUI_COAM=${WEBUI}

COAM modify several parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...       ${WEBUI_COAM}=${WEBUI_COAM}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${False}
    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}
    @{diff_para} =    create list
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        ${cur_para_value}    selenium_coam.get_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
        ...    Log to console    current value is ${cur_para_value}, no need to update
        ...    ELSE    run keywords
        ...    selenium_coam.set_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}    AND
        ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND
    ...    COAM Verify gnb on air after activate plan via webUI    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    [Teardown]    selenium_coam.logout

COAM login page via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

Check gnb COAM classical start normally
    Check Airscale HW module status
    #wait until keyword succeeds    8min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    wait until keyword succeeds    15min   60s    Check the gnb RU status ready
    #wait until keyword succeeds    8min   30s    Check the sctp port UP    port_num=${x2_sctp_port}

Check the sctp port UP
    [Arguments]    ${port_num}
    csn.sendCommand    command=netstat -anl |grep sctp    connection=${asik}
    sleep    3s
    ${sctp_status} =    csn.read_output    connection=${asik}
    should contain     ${sctp_status}     ${port_num}

Check the gnb RU status ready
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${ru_status} =    selenium_coam.get_ru_info
    sleep    8s
    selenium_coam.logout
    Get info status check    info_status=${ru_status}

Check the gnb cell status onair
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell_status} =    selenium_coam.get_cell_info
    sleep    8s
    selenium_coam.logout
    Get info status check    info_status=${cell_status}

Wait the gNB cell onair
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    wait until keyword succeeds    15min   1min    Check the gnb cell status onair    WEBUI_COAM=${WEBUI_COAM}

Get info status check
    [Arguments]    ${info_status}
    ${status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${status}   Availability status
    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}    ${bts_host}=${gnb1_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Common Suite Setup for COAM
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
	connect to gnb coam via ssl
	${SCF_backup}=    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
	COAM Teardown gnb connections
	Set Suite Variable    ${SCF_backup}

Common Suite Teardown for COAM
    connect to gnb coam via ssl
	Run keyword and ignore error
	...    wait until keyword succeeds
	...    3min   30s    Disable RD flag of rdUeContextRequest    ip_addr=${asik_addr}    gnb=${ALIAS_ASIK}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
	COAM Commission with scf file    scf_file_path=${SCF_backup}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    csn.connect_to    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Start To Capture Wireshark Logs
    [Arguments]    ${interface}    ${filename}
	csn.Disconnect    connection=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    gNB connections
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}   connection=${ALIAS_ASIK}

Stop and download Logs
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    gNB connections
    csn.send command    command=killall tcpdump     connection=${ALIAS_ASIK}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${ALIAS_ASIK}
    sleep    3

Enable RD flag of rdUeContextRequest
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=False    after_value=rdUeContextRequest=True
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}

Disable RD flag of rdUeContextRequest
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=True    after_value=rdUeContextRequest=False
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}

Modify RD flag of rdUeContextRequest
    [Arguments]    ${before_value}    ${after_value}    ${file}     ${ALIAS_ASIK}=${ALIAS_ASIK}
    csn.Execute    command=rm -rf /tmp/cpue && mkdir /tmp/cpue    connection=${ALIAS_ASIK}
    ${output}    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE/addons/ && ls cp_ue_*.txz    connection=${ALIAS_ASIK}
    ${filename}=    Remove String    ${output}    \r\n
    csn.Execute    command=tar -xvf /ffs/run/swpool/5G/CPUENODE/addons/${filename} -C /tmp/cpue   connection=${ALIAS_ASIK}
    csn.Execute    command=sed -i "s/${before_value}/${after_value}/g" /tmp/cpue/opt/nokia/SS_CPLANE/etc/${file}  connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && tar -Jcvf ${filename} opt/ usr/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && cp ${filename} /ffs/run/swpool/5G/CPUENODE/addons/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE/addons/ && crasign ${filename} && rm /ffs/run/HashContainer*    connection=${ALIAS_ASIK}
    #csn.Execute    command=reboot    connection=${ALIAS_ASIK}
    csn.Disconnect    connection=${ALIAS_ASIK}
    #Sleep    3min

Active CPUE log
    [Arguments]    ${ip_addr}=${asik2_addr}    ${gnb}=${ALIAS_ASIK2}
    wait until keyword succeeds    1min   10s    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    csn.upload_file   remote_path=${gNB_CPUE}   local_path=${UTE_CPUE}   connection=${gnb}
    csn.send command    command=sync    connection=${gnb}
    sleep    1s
    csn.send command    command=sync    connection=${gnb}

Analysis wireshark log to check RRC_Release with redirection
    [Arguments]     ${logname}    ${asik_addr}=${asik_addr}
    cap.read_cap      cap_file=${epc_log_path}${logname}    display_filter=ngap
    ${releaserequest}     Catenate   ngap.procedureCode == 42 and ip.src == ${asik_addr} and ngap.radioNetwork == 41
    cap.Check Expression    condition_expression=${releaserequest}
    ${releasecommand}     Catenate   ngap.procedureCode == 41 and ip.dst == ${asik_addr} and ngap.radioNetwork == 41
    cap.Check Expression    condition_expression=${releasecommand}
    ${releasecomplete}     Catenate   ngap.procedureCode == 41 and ip.src == ${asik_addr}
    cap.Check Expression    condition_expression=${releasecomplete}

## Huawei ##
Huawei UE setup
    power_ue.Prepare UE    ue_type=${tl.ues[0].capabilities[1]}

Huawei UE teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${tl.ues[0].capabilities[1]}    direction=ul
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${tl.ues[0].capabilities[1]}    direction=dl
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${tl.ues[0].capabilities[1]}

Huawei UE attach
    [Arguments]    ${gnb_index}=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${tl.ues[0].capabilities[1]}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${tl.ues[0].capabilities[1]}    gnb_index=${gnb_index}    4G_check=False    5Grach_ed=${5Grach_ed}

Start ul data transfer
    [Arguments]    ${throughput}=10MKbits/sec
    power_ue.Start traffic    ue_type=${tl.ues[0].capabilities[1]}    direction=ul    throughput=${throughput}   duration=90    apn_address=dxdata1

## modify PA ##
#Adjust ${RU} Attenuation to ${value}
    #Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}
    #Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}

#Adjust the Attenuation Value
    #[Arguments]    ${ports}    ${value}
    #atten.connect to    ip=${atten_ip}    port=${atten_port}
   # atten.get_value    channel=${ports}
   # atten.set_value    channel=${ports}    value=${value}
    #${value2}    atten.get_value    channel=${ports}
    #Should Be Equal    ${value}    ${value2}
    #atten.disconnect

#Get ${RU} Attenuation Port ${port} Value
   # atten.connect to    ip=${atten_ip}    port=${atten_port}
    #${value}=    atten.get_value    channel=${5G${RU}_ANT${port}}
    #atten.disconnect
   # [Return]    ${value}

TopYong Attenuation Initial Value set
    attenuator.setup_attenuator    attenuator=${tl.attenuator}
    atten.set_attenuation    ${5G1_ANT1}    ${10}
    atten.set_attenuation    ${5G1_ANT2}    ${10}
    sleep    3s

TopYong Attenuation Value Change
    attenuator.setup_attenuator    attenuator=${tl.attenuator}
    atten.set_attenuation    ${5G1_ANT1}    ${30}
    atten.set_attenuation    ${5G1_ANT2}    ${30}
    sleep    3s


