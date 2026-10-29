*** Settings ***
Documentation     author: shanxu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shangyu.xu@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.analyzer.pcap    WITH NAME    pcap
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot


*** Variables ***
${SCF_TEMPLATE_PATH}    ${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G402T921
${du_scf_name}    SCF_0.800.xml

${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${bip_log_file}    /home/ute/casetest/biplog.pcap


*** Keywords ***
Suite setup
    admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=COAM

Suite teardown
    admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error    COAM WEBUI Logout    display=${true}

Precondition
    [Arguments]    ${ChBwdl_except}=20MHz    ${ChBwul_except}=20MHz
    ...    ${actUlDataDmrsFdm_except}=${true}    ${ul64QamMcs_except}=${20}    ${ul256QamMcs_except}=${20}
    ...    ${actUl256Qam_expect}=${false}    ${actUlPtrs_except}=${false}    ${actUlDftSOfdm_expect}=${false}
    ...    ${ulDMRSAdditionalPosition_except}=One additional DMRS    ${pucchModeSelect_except}=longPucch
    ...    ${actDlDataDmrsFdm_except}=${true}    ${dl64QamMcs_except}=${20}    ${dl256QamMcs_except}=${20}
    ...    ${actDl256Qam_expect}=${true}    ${actDlPtrs_except}=${false}    #${actEnhancedLinkAdaptation_except}=${true}
    ...    ${dlDMRSAdditionalPosition_except}=One additional DMRS
    log to console    \n in precondition stage
    Check GNB cell on air
    #run keyword if    ${actPrachMultiplexing_except}==${true}
    #...    Scf commission and wait on-air    scf_name=${du_scf_name}
    @{MOs}    enblte.get_managed_objects    class_name=NRCELL_A    connection=COAM
    &{dict_pattern}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}   connection=COAM
    set suite variable    &{dict_pattern}

    run keyword if    ${dict_pattern['actUlDftSOfdm']} != ${actUlDftSOfdm_expect}
    ...    Set parameter    key=actUlDftSOfdm    value=${actUlDftSOfdm_expect}
    run keyword if    '${dict_pattern['actUl256Qam']}' != '${actUl256Qam_expect}'
    ...    Set parameter    key=actUl256Qam    value=${actUl256Qam_expect}
    run keyword if    '${dict_pattern['ulDMRSAdditionalPosition']}' != '${ulDMRSAdditionalPosition_except}'
    ...    Set parameter    key=ulDMRSAdditionalPosition    value=${ulDMRSAdditionalPosition_except}
    ${ulDataDmrsFdm_input}    Create Dictionary
    ...    actUlDataDmrsFdm=${actUlDataDmrsFdm_except}
    ...    ulDataDmrsFdmThres64QamMcs=${ul64QamMcs_except}
    ...    ulDataDmrsFdmThres256QamMcs=${ul256QamMcs_except}
    ${ulDataDmrsFdm_input}    create list    ${ulDataDmrsFdm_input}
    ${ulDataDmrsFdmThres64QamMcs}    Set Variable    ${dict_pattern['ulDataDmrsFdm']['ulDataDmrsFdmThres64QamMcs']}
    ${ulDataDmrsFdmThres256QamMcs}    Set Variable    ${dict_pattern['ulDataDmrsFdm']['ulDataDmrsFdmThres256QamMcs']}
    run keyword if    '${ulDataDmrsFdmThres64QamMcs}' != '${ul64QamMcs_except}' or '${ulDataDmrsFdmThres256QamMcs}' != '${ul256QamMcs_except}'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=ulDataDmrsFdm    value=${ulDataDmrsFdm_input}
    ${actUlPtrs_input}    Create Dictionary    actUlPtrs=${actUlPtrs_except}    ulPtrsFreqDensityThresNrb0=26    ulPtrsFreqDensityThresNrb1=26
    ${actUlPtrs_input}    create list    ${actUlPtrs_input}
    run keyword if    '${dict_pattern['ulPtrs']['actUlPtrs']}' != '${actUlPtrs_except}'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=ulPtrs    value=${actUlPtrs_input}

    run keyword if    ${dict_pattern['actDl256Qam']} != ${actDl256Qam_expect}
    ...    Set parameter    key=actDl256Qam    value=${actDl256Qam_expect}
    #run keyword if    '${dict_pattern['actEnhancedLinkAdaptation']}' != '${actEnhancedLinkAdaptation_except}'
    #...    Set parameter    key=actEnhancedLinkAdaptation    value=${actEnhancedLinkAdaptation_except}
    run keyword if    '${dict_pattern['dlDMRSAdditionalPosition']}' != '${dlDMRSAdditionalPosition_except}'
    ...    Set parameter    key=dlDMRSAdditionalPosition    value=${dlDMRSAdditionalPosition_except}
    ${dlDataDmrsFdm_input}    Create Dictionary
    ...    actDlDataDmrsFdm=${actDlDataDmrsFdm_except}
    ...    dlDataDmrsFdmThres64QamMcs=${dl64QamMcs_except}
    ...    dlDataDmrsFdmThres256QamMcs=${dl256QamMcs_except}
    ${dlDataDmrsFdm_input}    create list    ${dlDataDmrsFdm_input}
    ${dlDataDmrsFdmThres64QamMcs}    Set Variable    ${dict_pattern['dlDataDmrsFdm']['dlDataDmrsFdmThres64QamMcs']}
    ${dlDataDmrsFdmThres256QamMcs}    Set Variable    ${dict_pattern['dlDataDmrsFdm']['dlDataDmrsFdmThres256QamMcs']}
    run keyword if    '${dlDataDmrsFdmThres64QamMcs}' != '${dl64QamMcs_except}' or '${dlDataDmrsFdmThres256QamMcs}' != '${dl256QamMcs_except}'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=dlDataDmrsFdm    value=${dlDataDmrsFdm_input}
    ${actDlPtrs_input}    Create Dictionary    actDlPtrs=${actDlPtrs_except}    dlPtrsFreqDensityThresNrb0=26    dlPtrsFreqDensityThresNrb1=26
    ${actDlPtrs_input}    create list    ${actDlPtrs_input}
    run keyword if    '${dict_pattern['dlPtrs']['actDlPtrs']}' != '${actDlPtrs_except}'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=dlPtrs    value=${actDlPtrs_input}

    ${ChBwdl}    Get NIDD parameter value    class_name=NRCELL_FDD_A    pattern=chBwDl    connection=COAM
    run keyword if    '${ChBwdl}' != '${ChBwdl_except}'
    ...    set bandwidth    value=${ChBwdl_except}

    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

Check GNB cell on air
    [Documentation]
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

Scf commission and wait on-air
    [Arguments]   ${scf_name}   ${connection}=COAM
    log to console    step1:scf commission and wait for on-air
    Conect to DU COAM
    admin_cli.perform_commissioning
    ...   scf_file=${SCF_TEMPLATE_PATH}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
	sleep    60s
    Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair
#   Get cell numbers

Conect to DU COAM
    [Arguments]    ${connection}=COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}

Set parameter
    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

set bandwidth
    [Arguments]    ${value}

    ${cellBwpList0_5}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-9    cellBwpId=0
    ${cellBwpList1_5}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-30    cellBwpId=1
    @{cellBwpList_params_5}    create list    ${cellBwpList0_5}    ${cellBwpList1_5}

    ${cellBwpList0_10}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_10}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-33    cellBwpId=1
    @{cellBwpList_params_10}    create list    ${cellBwpList0_10}    ${cellBwpList1_10}

    ${cellBwpList0_15}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_15}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-33    cellBwpId=1
    @{cellBwpList_params_15}    create list    ${cellBwpList0_15}    ${cellBwpList1_15}

    ${cellBwpList0_20}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_20}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-33    cellBwpId=1
    @{cellBwpList_params_20}    create list    ${cellBwpList0_20}    ${cellBwpList1_20}

    run keyword if    '${value}'=='5MHz'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_5}

    run keyword if    '${value}'=='10MHz'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_10}

    run keyword if    '${value}'=='15MHz'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_15}

    run keyword if    '${value}'=='20MHz'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_20}
    log to console    Open WEBEM
    selenium_coam.enable_virtual_display

    selenium_coam.login    url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
    ...    username=Nemuadmin    password=nemuuser    version=SBTS22R3

    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink    new_value=350000
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink    new_value=430160
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Synchronization channel number    new_value=5377
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink    new_value=${value}

    run keyword if    '${value}'=='5MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=0
    run keyword if    '${value}'=='10MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=6
    run keyword if    '${value}'=='15MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7
    run keyword if    '${value}'=='20MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7
    log to console    Active parameter
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}

    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair
    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    OperatingSystem.Run    ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9

Set actUlDataDmrsFdm
    [Arguments]    ${actUlDataDmrsFdm_except}    ${ulDataDmrsFdmThres64QamMcs_except}    ${ulDataDmrsFdmThres256QamMcs_except}
    @{MOs}    enblte.get_managed_objects    class_name=NRCELL_A    connection=COAM
    &{dict_pattern}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}   connection=COAM
    set suite variable    &{dict_pattern}
    ${ulDataDmrsFdm_input}    Create Dictionary
    ...    actUlDataDmrsFdm=${actUlDataDmrsFdm_except}
    ...    ulDataDmrsFdmThres64QamMcs=${ulDataDmrsFdmThres64QamMcs_except}
    ...    ulDataDmrsFdmThres256QamMcs=${ulDataDmrsFdmThres256QamMcs_except}
    ${ulDataDmrsFdm_input}    create list    ${ulDataDmrsFdm_input}
    run keyword if    '${dict_pattern['ulDataDmrsFdm']['actUlDataDmrsFdm']}' != '${actUlDataDmrsFdm_except}'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=ulDataDmrsFdm    value=${ulDataDmrsFdm_input}
    Wait Until Keyword Succeeds    5min    20s    COAM Check All Cells Onair

Set actDlDataDmrsFdm
    [Arguments]    ${actDlDataDmrsFdm_except}    ${dlDataDmrsFdmThres64QamMcs_except}    ${dlDataDmrsFdmThres256QamMcs_except}
    @{MOs}    enblte.get_managed_objects    class_name=NRCELL_A    connection=COAM
    &{dict_pattern}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}   connection=COAM
    set suite variable    &{dict_pattern}
    ${dlDataDmrsFdm_input}    Create Dictionary
    ...    actDlDataDmrsFdm=${actDlDataDmrsFdm_except}
    ...    dlDataDmrsFdmThres64QamMcs=${dlDataDmrsFdmThres64QamMcs_except}
    ...    dlDataDmrsFdmThres256QamMcs=${dlDataDmrsFdmThres256QamMcs_except}
    ${dlDataDmrsFdm_input}    create list    ${dlDataDmrsFdm_input}
    run keyword if    '${dict_pattern['dlDataDmrsFdm']['actDlDataDmrsFdm']}' != '${actDlDataDmrsFdm_except}'
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=dlDataDmrsFdm    value=${dlDataDmrsFdm_input}
    Wait Until Keyword Succeeds    5min    20s    COAM Check All Cells Onair

L3 call setup for NSA
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    #power_ue.Verify attach    ue_type=${UE_TYPE}    4G_check=True   5Grach_ed=${5Grach_ed_0}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    \n ### UE Detach ###
    #power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup second
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}    ${4G_check}=Flase
    log to console    L3 call setup and check
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}

Start Device traffic
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${direction}=dl    ${throughput}=1M    ${reset_sol}=${True}
    ...    ${iperf_port}=default
    Log To Console    \n ###UE Start traffic ###
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throughput}    duration=900    #iperf_type=via_command
    ...    iperf_port=${iperf_port}

Stop Device traffic
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${direction}=dl    ${iperf_port}=default
    Log To Console    \n ###UE Stop traffic###
    power_ue.Stop traffic    direction=${direction}    ue_index=${ue_index}    ue_type=${UE_TYPE}    iperf_port=${iperf_port}


Modify HBTE Channel Vaules
    [Arguments]    ${channels}    ${value}=63    ${ru_id}=0    ${gnb_id}=0
    #${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=HBTE
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}

Capture BIP Logs
    ${connection}    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...    password=${DU_OAM_SSH_PASSWORD}    alias=DU
    Log To Console    prepare for capture bip
    run keyword and continue on failure    _delete_biplog_pcap
    Precondition for bip capture with gnbMirroring scripts    connection=${connection}
    Log To Console    Capture BIP Logs
    ssh.send_command   command=sh /ffs/fs1/config/toor4nsn/gnbMirroring.sh > /dev/null    connection=${connection}
    sleep    7s
    ${PID}    wait until keyword succeeds    1min    2s    Get PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | grep tcpdump_L2L1 | tail -n 1 |awk '{print $2}'
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    ${output}    ssh.read_output    connection=${connection}
    should be empty    ${output}
    ssh.send_command    command=bget 1:0 /tmp/tcpdump_L2L1_bip* /tmp    connection=${connection}
    sleep    10s
    Log To Console    Copy BIP Logs To Test PC
    ssh.download_file    remote_path=/tmp/tcpdump_L2L1_bip_filtering_off.pcap00    local_path=${bip_log_file}    connection=${connection}
    [Teardown]    ssh.Disconnect    connection=${connection}

_delete_biplog_pcap
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...    password=${DU_OAM_SSH_PASSWORD}    alias=DU
    ssh.send_command    command=bsh 1:0    connection=DU
    ssh.send_command    command=cd /tmp && rm -rf tcpdump_L2L1_bip*    connection=DU

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Check from Bip logs
    [Arguments]    ${pcap_filter}=/usr/bin/tshark -r {pcap_file} -Y "uldata_puschreceivereq" -T pdml
    pcap.load_pcap_file    command_template=${pcap_filter}    pcap_file=/home/ute/casetest/biplog.pcap
    ${numOfDmrsCdmGroupWithoutData}=    pcap.get_field_value_by_xpath    xpath=.//UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
    ${tbSize_bits}=    pcap.get_field_value_by_xpath    xpath=.//UlData_puschReceiveReqGrant_t.tbSize_bits
    [Return]    ${numOfDmrsCdmGroupWithoutData}    ${tbSize_bits}

Check from Bip logs for DL
    [Arguments]    ${pcap_filter}=/usr/bin/tshark -r {pcap_file} -Y "dldata_pdschsendreq" -T pdml
    pcap.load_pcap_file    command_template=${pcap_filter}    pcap_file=/home/ute/casetest/biplog.pcap
    ${numOfDmrsCdmGroupWithoutData}=    pcap.get_field_value_by_xpath    xpath=.//DlData_PdschGrant.numOfDmrsCdmGroupWithoutData
    ${tbSize_bits}=    pcap.get_field_value_by_xpath    xpath=.//DlData_PdschGrant.tbSize_bits
    ${numberoflayer}=    pcap.get_field_value_by_xpath    xpath=.//DlData_PdschGrant.numOfLayers
    [Return]    ${numOfDmrsCdmGroupWithoutData}    ${tbSize_bits}    ${numberoflayer}

teardown
    [Arguments]    ${value}=NSA
    log to console    \n in teardown stage
    Run Keyword And Ignore Error     admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error     power_ue.UE Detach    ue_index=${0}    ue_type=qct_dx50
    Run Keyword And Ignore Error
    ...    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-925/LNBTS-925/LNCEL-44922    parameter=administrativeState    value=unlocked
    Run Keyword If    '${value}' == 'NSA'
    ...    Run Keyword And Ignore Error
    ...    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-925/LNBTS-925/LNCEL-44922    parameter=administrativeState    value=unlocked
    CI_interface.Common Case Teardown

