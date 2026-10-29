*** Settings ***
Documentation     author: shanxu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shangyu.xu@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
#Library    taf.selenium.gnb.oam.coam.classical        WITH NAME    selenium_coam
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py


*** Variables ***
${TEST_LOG_DIRECTORY}    /home/ute/casetest_924/
${SCF_TEMPLATE_PATH}    ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G402T924


*** Keywords ***
Suite setup
    admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=COAM

Suite teardown
    admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error    COAM WEBUI Logout    display=${true}

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

L3 call setup
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

L3 call detach
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup second
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}    ${4G_check}=Flase
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Start Traffic UL
    [Arguments]    ${ue_type}=qct_dx50    ${ue_index}=${0}    ${ul_tp}=120M    ${duration}=${300}    ${iperf_port}=default
    ...    ${iperf_path}=/data/local/tmp/iperf
    ${traffic_duration}  evaluate  ${duration}*10+100
    qct_dx50.power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
    ...    duration=${traffic_duration}    iperf_port=${iperf_port}    iperf_path=${iperf_path}    iperf_type=via_command

qct_dx50.power_ue.Start traffic
    [Arguments]    ${ue_type}    ${direction}   ${throughput}=10   ${apn_address}=wap1nokiacom
    ...            ${duration}=10   ${protocol}=udp    ${ue_index}=${0}    ${ue_mode}=SA
    ...            ${cap_index}=${0}   ${dt_index}=${0}    ${iperf_port}=default
    ...            ${interval}=1    ${buffer_size}=1400B    ${dt_name}=DT_1
    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}    ${appserver}=APPserver    ${iperf_type}=via_app
    ...            ${data_amount}=1M    ${connection_type}=app    ${process_num}=default
    ...            ${seg_size}=1180    ${window}=2M    ${iperf_path}=/data/local/tmp/iperf
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  dt_index: The new data transfer index alias.
    ...  :param  iperf_port: port number used for traffic start via iperf.
    ...  :param  dt_name: alias name for created data transfer.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  multidrb_QoS_dest: <optional> default None,
    ...                             multidrb_QoS_dest is a optional input,
    ...                             Setup UL traffic dest ip address for multidrb testing,
    ...                             Normal UL traffic ignore this param.
    ...  :param  cap_index: The list index from ue.capabilities[], will use the index capability for reserve.
    ...  :param  iperf_type: Traffic use iperf command or iperf app type.
    ...  :param  connection_type: net connection type, "app" or "current", "app" default.
    ...  :param  process_num: the number of process which are used for tcp data transfer, the more the better.
    ...  :param  seg_size: set TCP maximum segment size (MTU - 40 bytes)
    ...  :param  window: set TCP window size. eg, default value is 2M
    ${direction}=    Convert To Lowercase    ${direction}
    # If process_num was given by user, use the users value.
    # If not given, set default value by protocal, udp -> ${1} | tcp -> ${5}
    ${process_num}    run keyword if
    ...               '${process_num}'!='default'    set variable    ${process_num}
    ...               ELSE                           set variable if
    ...                                              '${protocol}'=='udp'    ${1}
    ...                                                                      ${5}
    ${output}    run keyword    UE.qct_dx50.Start traffic    direction=${direction}
    ...                                                     ue_index=${ue_index}
    ...                                                     dt_index=${dt_index}
    ...                                                     duration=${duration}
    ...                                                     throughput=${throughput}
    ...                                                     protocol=${protocol}
    ...                                                     iperf_port=${iperf_port}
    ...                                                     interval=${interval}
    ...                                                     buffer_size=${buffer_size}
    ...                                                     dt_name=${dt_name}
    ...                                                     ue_alias=${ue_alias}
    ...                                                     multidrb_QoS_dest=${multidrb_QoS_dest}
    ...                                                     cap_index=${cap_index}
    ...                                                     appserver=${appserver}
    ...                                                     iperf_type=${iperf_type}
    ...                                                     data_amount=${data_amount}
    ...                                                     apn_address=${apn_address}
    ...                                                     ue_mode=${ue_mode}
    ...                                                     connection_type=${connection_type}
    ...                                                     process_num=${process_num}
    ...                                                     seg_size=${seg_size}
    ...                                                     window=${window}
    ...                                                     iperf_path=${iperf_path}
    [Return]    ${output}

UE.qct_dx50.Start traffic
    [Arguments]    ${direction}    ${throughput}    ${duration}    ${iperf_port}    ${ue_index}=${0}
    ...            ${cap_index}=${0}    ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${process_num}=${5}
    ...            ${seg_size}=${1180}    ${window}=2M    ${iperf_path}=/data/local/tmp/iperf    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer, like 10M
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  iperf_port: port number used for traffic start via iperf.
    ...  :param  process_num: the number of process which are used for tcp data transfer, the more the better.
    ...  :param  window: tcp window size. eg, default value is 2M
    ${ue_addr} =    Get the UE Ip address    ue_index=${ue_index}
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    wait until keyword succeeds    3x    10s    Start DL traffic via iperf on Appserver
    ...                                                                                    ue_addr=${ue_addr}
    ...                                                                                    dl_time=${duration}
    ...                                                                                    dl_port=${port}
    ...                                                                                    dl_throughput=${throughput}
    ...                                                                                    dl_length=${buffer_size}
    ...                                                                                    appserver=${appserver}
    ...                                                                                    protocol=${protocol}
    ...                                                                                    ue_index=${ue_index}
    ...                                                                                    process_num=${process_num}
    ...                                                                                    seg_size=${seg_size}
    ...                                                                                    window=${window}
    ...    ELSE IF    '${direction}' == 'ul'    wait until keyword succeeds    3x    10s    Start UL traffic via iperf from andriod UE
    ...                                                                                       ue_index=${ue_index}
    ...                                                                                       ul_time=${duration}
    ...                                                                                       ul_port=${port}
    ...                                                                                       ul_throughput=${throughput}
    ...                                                                                       ul_length=${buffer_size}
    ...                                                                                       appserver=${appserver}
    ...                                                                                       protocol=${protocol}
    ...                                                                                       process_num=${process_num}
    ...                                                                                       window=${window}
    ...                                                                                       iperf_path=${iperf_path}

Stop Traffic UL
    [Arguments]    ${ue_type}=qct_dx50    ${ue_index}=${0}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}    ue_index=${ue_index}

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

Start Btslog Collect
    [Arguments]    ${names}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...            ${btslog_launcher_path}=/opt/btslog/btslog_launcher    ${log_dir}=/tmp/btslog2
    Log To Console    \n ### Btslog Collect Start ###
    btslog.Create Btslog Collector    name=${names}    btslog_path=${btslog_path}
    ...                               btslog_launcher_path=${btslog_launcher_path}
    btslog.Set Suite Alias    ${names}
    core.Setup Collectors    names=${names}
    core.Start Collectors    names=${names}
    sleep    5s

Stop Btslog Collect
    [Arguments]    ${names}=btslog
    Log To Console    \n ### Btslog Collect Stop ###
    core.Stop Collectors    names=${names}
    core.Collect Collectors    names=${names}    target_dir=${TEST_LOG_DIRECTORY}

    core.Teardown Collectors    names=${names}
    ${btslog_name}    Join Path    ${TEST_LOG_DIRECTORY}    ${names}
    [Return]    ${btslog_name}

Check Btslog
    [Arguments]    ${btslog_name}    ${filter}
    Log    Checking BTS Syslog to confirm parameter change.    console=True
    OperatingSystem.Run    command=tar zxvf ${btslog_name}/syslog_files.tgz -C/${btslog_name}/
    ${output}    OperatingSystem.Run    command=cat ${btslog_name}/SYSLOG*.LOG | grep -a "${filter}" | grep -av grep
    Should Not Be Empty    ${output}

Stop btslog and check
    ${btslog_name}    Stop Btslog Collect
    Check Btslog    btslog_name=${btslog_name}    filter=SA handover completed with status Completed
    Check Btslog    btslog_name=${btslog_name}    filter=entering state:CGACTIVATED
    sleep    5s

teardown
    log to console    \n in teardown stage
    Run Keyword And Ignore Error     admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error     power_ue.UE Detach    ue_index=${0}    ue_type=inseego
    Run Keyword And Ignore Error     core.Stop Collectors    names=btslog
    CI_interface.Common Case Teardown

