*** Settings ***

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature 5GC001358-D in 5G22R2 program


Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
Variables       5GC001358-D_variables.py
Library           ./ssh_pcf.py
Library           ssh_pcf.pcf   WITH NAME    PCF

*** Variables ***
${mrbts_ID_enb}        ${tl.enbs[0].instance_id}

${connection}    GNB_OAM
${cell_index}    1
${TEST_LOG_DIRECTORY}    /home/ute/logs/
${ute_host}    ${tl.host[0].default_ssh_connection_details.addr}
${ute_name}    ${tl.host[0].default_ssh_connection_details.username}
${ute_password}    ${tl.host[0].default_ssh_connection_details.password}
${DU_OAM_IP}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}


${PC_HOST}                   ${tl.test_pc.default_ssh_connection_details.addr}
${PC_USER}                   ${tl.test_pc.default_ssh_connection_details.username}
${PC_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
${MRBTS_ID}                  ${tl.gnbs[0].dus.instance_id}
${NRBTS_ID}                  ${tl.gnbs[0].dus.global_bts_id}
${PCF_IP}         ${tl.core.pcf.oam_ssh_connection_details.addr}
${PCF_username}    ${tl.core.pcf.oam_ssh_connection_details.username}
${PCF_password}    ${tl.core.pcf.oam_ssh_connection_details.password}
${ALIAS_PCF}    pcf
${ims}     262033
${priorityLevel}    8
${server_ip}     ${tl.test_pc.default_ssh_connection_details.addr}
${swconfig_path}    ${commissionings_path}/HGZ/7_5_UTE5G402T924/swconfig.txt

*** Keywords ***
PCMD Coam Suite Setup
    [Arguments]    ${asik_addr_temp}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...            ${asik_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...            ${asik_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    log to console    \n update /ffs/run/swconfig.txt
    #Selenium Login And Disable Screen Lock
    log to console  ${CURDIR}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${swconfig_path}
    Run Keyword And Ignore Error    OperatingSystem.Run    sudo rm /root/.ssh/known_hosts
    Run Keyword And Ignore Error    run process
    ...    sudo sshpass -p ${asik_password} scp ${swconfig_path} ${asik_username}@${asik_addr_temp}:/ffs/run/   shell=yes
    csn.connect_to    ${asik_addr_temp}    ${asik_username}    ${asik_password}    alias=GNB_OAM
    csn.execute    command=chmod 777 /ffs/run/swconfig.txt    connection=GNB_OAM
    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=GNB_OAM
    log to console    \n ${swconfig_output}
    csn.execute    command=crasign /ffs/run/swconfig.txt    connection=GNB_OAM
    [Teardown]    csn.Disconnect    connection=GNB_OAM

Suite Teardown with SCF
    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml


Get program version
    [Documentation]    Author: Ding Binmei
    ...                Description: Change the implementation to get program info from GNB.
    ...                Retrun with ${program_version}, valid output: 19A, 19B, 20B, master, ...
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    ${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    [Return]    ${program_version}

L3 call setup for CB008124
    [Arguments]    ${UE_TYPE}=qct_dx50
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start Traffic UL
    [Arguments]    ${ue_type}=qct_dx50    ${ue_index}=${0}    ${ul_tp}=10M    ${duration}=${300}    ${iperf_port}=default
    ${traffic_duration}  evaluate  ${duration}*10+100
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
    ...    duration=${traffic_duration}    iperf_port=${iperf_port}    iperf_type=via_command

Handover and check syslog
    ${range}    set variable    5
    FOR    ${i}    IN RANGE    1    ${range}
        Start Btslog Collect for CB008124
        Set PA HO from cell1 to cell2
        Stop btslog and check
        Start Btslog Collect for CB008124
        Set PA HO from cell2 to cell1
        Stop btslog and check
    END


prepare for BTSLog
# because the btslog can't gather the syslog after UTE cloud deployed, so here need restart btslog.
    Start Btslog Collect for CB008124
    ${btslog_name}    Stop Btslog Collect for CB008124

Set PA prepare
    @{channels}=    create list    1    2    3    4
    Modify HBTE Channel Vaules    channels=${channels}    value=0    ru_id=0    gnb_id=0
    @{channels}=    create list    5    6    7    8
    Modify HBTE Channel Vaules    channels=${channels}    value=60    ru_id=1    gnb_id=0
    @{channels}=    create list    9    10    11    12
    Modify HBTE Channel Vaules    channels=${channels}    value=60    ru_id=2    gnb_id=0

Set PA HO from cell1 to cell2
    @{channels}=    create list    9    10    11    12
    Modify HBTE Channel Vaules    channels=${channels}    value=0    ru_id=1    gnb_id=0
    sleep    5s
    @{channels}=    create list    1    2    3    4    5    6    7    8
    Modify HBTE Channel Vaules    channels=${channels}    value=15    ru_id=0    gnb_id=0
    sleep    30s

Set PA HO from cell2 to cell1
    @{channels}=    create list    1    2    3    4    5    6    7    8
    Modify HBTE Channel Vaules    channels=${channels}    value=0    ru_id=0    gnb_id=0
    sleep    5s
    @{channels}=    create list    9    10    11    12
    Modify HBTE Channel Vaules    channels=${channels}    value=15    ru_id=1    gnb_id=0
    sleep    30s

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

Start Btslog Collect for CB008124
    [Arguments]    ${names}=btslog8124    ${btslog_path}=/opt/btslog/btslog
    ...            ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    Log To Console    \n ### Btslog Collect Start ###
    csn.Connect to    hostname=${ute_host}    username=${ute_name}    password=${ute_password}    alias=ute
    ${executor_test_vm}=  Create Dictionary
    ...  host=${ute_host}
    ...  user=${ute_name}
    ...  password=${ute_password}
    btslog.Create Btslog Collector    name=${names}    btslog_path=${btslog_path}
    ...                               btslog_launcher_path=${btslog_launcher_path}
    ...                               executor=${executor_test_vm}
    btslog.Set Suite Alias    ${names}
    core.Setup Collectors    names=${names}
    core.Start Collectors    names=${names}
    sleep    100s

Stop btslog and check
    ${btslog_name}    Stop Btslog Collect for CB008124
    Check Btslog    btslog_name=${btslog_name}    filter1=Intra gNB handover completed with status Completed
    ...    filter2=SA Intragnb handover completed with status Completed
    Check Btslog    btslog_name=${btslog_name}    filter1=entering state:CGACTIVATED
    ...    filter2=leaving state:CGWAITFORACTIVATIONCONFIRMATION
    sleep    5s


Stop btslog and check CG2 Activate
    sleep    5s
    ${btslog_name}    Stop Btslog Collect for CB008124
    Check Btslog    btslog_name=${btslog_name}    filter1=entering state:CGACTIVATED
    ...    filter2=leaving state:CGWAITFORACTIVATIONCONFIRMATION
    sleep    5s

Stop Btslog Collect for CB008124
    [Arguments]    ${names}=btslog8124
    Log To Console    \n ### Btslog Collect Stop ###
    core.Stop Collectors    names=${names}
    core.Collect Collectors    names=${names}    target_dir=${TEST_LOG_DIRECTORY}

    core.Teardown Collectors    names=${names}
    ${btslog_name}    Join Path    ${TEST_LOG_DIRECTORY}    ${names}
    [Return]    ${btslog_name}

Check Btslog
    [Arguments]    ${btslog_name}    ${filter1}    ${filter2}
    Log    Checking BTS Syslog to confirm parameter change.    console=True
    OperatingSystem.Run    command=tar zxvf ${btslog_name}/syslog_files.tgz -C/${btslog_name}/
    ${output1}    OperatingSystem.Run    command=cat ${btslog_name}/SYSLOG*.LOG | grep -a "${filter1}" | grep -av grep
    ${output2}    OperatingSystem.Run    command=cat ${btslog_name}/SYSLOG*.LOG | grep -a "${filter2}" | grep -av grep
    #append to list    ${output1}    ${output2}
    Should Not Be Empty    ${output1}${output2}

Stop Traffic UL
    [Arguments]    ${ue_type}=qct_dx50
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}

L3 call detach
    [Arguments]    ${UE_TYPE}=qct_dx50
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_type=${UE_TYPE}

Scf commission and wait on-air
    [Arguments]   ${scf_name}   ${connection}=COAM
    log to console    step1:scf commission and wait for on-air
    Conect to DU COAM
    admin_cli.perform_commissioning
    ...   scf_file=${scf_file_path}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
	sleep    60s
    Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair

Conect to DU COAM
    [Arguments]    ${connection}=COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}


L3 call setup
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=askey    ${dltp}=${0}    ${ultp}=${0}    ${4G_check}=${False}
    ...    ${cell_index}=${1}    ${duration}=120
    log to console    L3 call setup and check
    #Log To Console    \n ### Prepare UE ###
    #power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${UE_TYPE}    reset_sol=${True}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    Log To Console    \n ###UE Start traffic and check TP ###
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=150M    duration=${duration}    iperf_type=via_command
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=1500M    duration=${duration}
    ${cell_id}    Get cell ID    cell_index=${cell_index}
    ${cell_id}    convert to string    ${cell_id}
    ${list_of_cell_ids}    create list
    append to list    ${list_of_cell_ids}    ${cell_id}
    ${log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=2m    filter=L2Lo
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${UE_TYPE}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${True}
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${UE_TYPE}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

Check specific cell call normal
    [Arguments]    ${cell_index_list}    ${cell_index}=${1}
    ${cell_index_list_backup}    Copy List    ${cell_index_list}
    Remove Values From List     ${cell_index_list_backup}   ${cell_index}
    FOR    ${cell_idx}    IN    @{cell_index_list_backup}
        ${defaultLnRelGnbCellId_value}=    Set Variable If
        ...    ${cell_idx}==1    8
        ...    ${cell_idx}==2    9
        ...    ${cell_idx}==3    10
        Connect and Modify the parameter on enblte    dist_name=MRBTS-${mrbts_ID_enb}/LNBTS-${mrbts_ID_enb}/LNCEL-1
        ...    parameter=defaultLnRelGnbCellId    value=${defaultLnRelGnbCellId_value}
        L3 call setup    cell_index=${cell_idx}    UE_TYPE=${UE_type}    duration=30
    END


Block cell via WebEM and Check status
    [Arguments]    ${cell_index}=${1}
    Measure Cell Block Via GUI    cell_index=${cell_index}
    ${shutdownNogNBCellTmr}    Get NIDD parameter value    class_name=NRBTS_A    pattern=shutdownNogNBCellTmr    connection=GNB_OAM
    sleep    ${shutdownNogNBCellTmr}
    Wait Until Keyword Succeeds    3min    2s    Check bts status after block cell    cell_index=${cell_index}

Unblock cell via WebEM and Check status
    [Arguments]    ${cell_index}=${1}
    Measure Cell Unblock Via GUI    cell_index=${cell_index}
    Wait Until Keyword Succeeds    10min    10s    Check bts status after unblock cell    cell_index=${cell_index}

Commissioning SCF And Check cell status
    [Arguments]    ${scf_file_path}
    COAM Commission with scf file  scf_file_path=${scf_file_path}    timeout=600
    sleep    300s
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='NSA'

Get bts version
    ${bts_version}    Get NIDD parameter value    class_name=MNL_R    pattern=active5GRATSWVersion    connection=${connection}
    @{sw_version_list}    Get regexp matches    ${bts_version}    (.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    [Return]    ${sw_version}

Login to webEM
    ${version}    Get bts version
    selenium_coam.enable_virtual_display
    sleep    5s
    selenium_coam.login    url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    username=Nemuadmin    password=nemuuser    version=${version}

Check unexpected alarm
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}

Measure Cell Block Via GUI
    [Arguments]    ${cell_index}=${1}
    Login to webEM
    &{cell_status}    Get Cell info    cell_index=${cell_index}
    run keyword if    '${cell_status['Status']['Blocking state']}'!='Blocked'
    ...    selenium_coam.block_cell    cell_idx=${cell_index}
    ...    ELSE    Log    msg=Current status of cell is blocked, no need to block again
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [teardown]    Run Keyword And Ignore Error    selenium_coam.logout

Measure Cell Unblock Via GUI
    [Arguments]    ${cell_index}=${1}
    Login to webEM
    &{cell_status}    Get Cell info    cell_index=${cell_index}
    run keyword if    '${cell_status['Status']['Blocking state']}'=='Blocked'
    ...    selenium_coam.unblock_cell    cell_idx=${cell_index}
    ...    ELSE    Log    msg=Current status of cell is unblocked, no need to unblock again
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [teardown]    Run Keyword And Ignore Error    selenium_coam.logout


Get NIDD_R value
    [Arguments]   ${class_name}=NRCELL_R    ${pattern}=nrCellIdentity    ${connection}=${connection}
    @{MOs}    admin_cli.get_managed_objects    class_name=NRBTS_R    connection=${connection}
    &{dict_pattern}=    admin_cli.get_parameters    dist_name=${MOs[0]['distName']}/${class_name}
    ...    pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Get cell ID
    [Arguments]    ${cell_index}=${1}
    ${cell_id}    Get NIDD_R value    class_name=NRCELL_R-${cell_index}    pattern=nrCellIdentity    connection=${connection}
    [Return]    ${cell_id}

Get Cell info
    [Arguments]    ${cell_index}=${1}
    ${cell_status}    selenium_coam.get_cell_info    cell_idx=${cell_index}
    [Return]    ${cell_status}

Check cell status
    [Arguments]    ${operational_state}    ${availabilityStatus}
    &{cell_status}    Get Cell info
    Should be equal as strings    ${cell_status['Status']['Operational state']}       ${operational_state}
                                  ...  msg=Current Cell operationalStatus is not in correct status    ignore_case=${True}
    Should be equal as strings    ${cell_status['Status']['Availability status']}     ${availabilityStatus}
                                  ...  msg=Current Cell availabilityStatus is not in correct status    ignore_case=${True}

Check bts status after block cell
    [Arguments]    ${cell_index}=${1}
    ${cell_group_idx}    Set Variable    ${${cell_index}-${1}}
    Cell Should Be Blocked    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}
    Wait For Expect Fault Present    faultId=49    timeout=120

Check bts status after unblock cell
    [Arguments]    ${cell_index}=${1}
    ${cell_group_idx}    Set Variable    ${${cell_index}-${1}}
    Cell Should Be UnBlocked    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}
    Wait For Expect Fault To Disappear    faultId=49    timeout=120

Check gnb status after lock RU
    RU Should Be Locked
    ${cell_id}    Get cell ID
    Wait For Expect Fault Present    faultId=7300    timeout=120
    Check cell status    operational_state=Disabled    availabilityStatus=Dependency

Check gnb status after Unlock RU
    RU Should Be Unlocked
    Wait For Expect Fault To Disappear    faultId=7300    timeout=120
    Check cell status    operational_state=Enabled    availabilityStatus=Online

Act cell_1 beamforming para
    FOR    ${beamforming_para}    IN    @{Para_5GC002089}
        ${beamforming_para}    Create Dictionary    parameterName=${Para_5GC002089['p_name']}
        ...    value=${Para_5GC002089['new_value']}    operation=${Para_5GC002089['operate']}
    END
        ${beamforming_related_para_list}    Create List    ${beamforming_para}
    #admin_cli.perform_object_recommissioning
    #...    dist_name=${Para_5GC002089['dist_name']}    parmeter=${Para_5GC002089['new_value']}
    #...    operation=${Para_5GC002089['operate']}

Precondition
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}

Coam Test Teardown
    log to console    \n*** Coam Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOW_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Teardown
    ${cell_id_list}    Get All Cell Id
    FOR    ${cell_index}    IN    @{cell_id_list}
        Measure Cell Unblock Via GUI    cell_index=${cell_index}
    END
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    admin_cli.teardown    connection=${connection}


teardown for CB008124
    log to console    \n in teardown stage
    Run Keyword And Ignore Error     admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error     power_ue.UE Detach    ue_index=${0}    ue_type=qct_dx50
    Run Keyword And Ignore Error     core.Stop Collectors    names=btslog8124
    Run Keyword And Ignore Error     csn.Disconnect     connection=ute
    CI_interface.Common Case Teardown

Case Setup
    Run Keyword And Ignore Error    robot_common_operations.Common case setup
#--------------------------------PCF operation----------------------------#
Start PCF Simulator
    log to console     Start PCF service
    Start PCF service    ims=${ims}    ip=${PCF_IP}

Connect to PCF server
    [Arguments]    ${alias}=${ALIAS_PCF}
    csn.Connect to    hostname=${PCF_IP}
    ...    username=${PCF_username}
    ...    password=${PCF_password}
    ...    alias=${alias}
    [Return]    ${alias}

Exit the PCF service
    Connect to PCF server
    csn.send command  ps -ef | grep sim | grep -v grep | grep 5g | awk '{print $2}' | xargs kill -2    connection=${ALIAS_PCF}
    sleep    5S

Start PCF service
    [Arguments]    ${ims}    ${ip}
    PCF.pcf_connect    ip=${PCF_IP}    username=${PCF_username}    password=${PCF_password}
    PCF.pcf_start    ims=${ims}    ip=${ip}

Configure and commit the QoS
    [Arguments]    ${five_qi}    ${priorityLevel}    ${server_ip}
    PCF.pcf_add_one_QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel}    server_ip=${server_ip}

Attach UE
    log to console    Attach UE
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
    power_ue.UE Attach     ue_index=${0}    ue_type=${ue_type}

Detach UE
    log to console     Detach UE
    UE Detach    ${ue_type}    ue_index=${0}

ADD DRB with 5QI${five_qi}
    log to console    ADD DRB with 5QI${five_qi}
    Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel}    server_ip=${server_ip}
    sleep    2s

Delete DRB with 5QI${five_qi}
    log to console     Delete DRB with 5QI${five_qi}
    PCF.pcf_delete_5Qi8

Connect to DU via ssl
    [Arguments]  ${connection}=${connection}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    admin_cli.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Configure 545 ${para} to ${value}
    Log    \nConfigure ${para} to ${value}   console=yes
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    parameter=${para}
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}

Configure 545 parametrs
    Log To Console    Configure DRX parametrs
    Connect to DU via ssl
    Configure 545 actUlDftSOfdm to true

Stop btslog and check DRX enable
    sleep    5s
    ${btslog_name}    Stop Btslog Collect for CB008124
    Check Btslog    btslog_name=${btslog_name}    filter1="drxRetransmissionTimerUL":"SL24"
    ...    filter2="drxHARQRTTTimerUL":28
    sleep    5s

Stop btslog and check CG2 not enable
    ${btslog_name}    Stop Btslog Collect for CB008124
    Check Btslog    btslog_name=${btslog_name}    filter1=ULCG_Type2
    ...    filter2=The reason for rejecting CG Setup is TransformPrecoder is enabled
    sleep    5s
##PA##
Adjust HBTE ATT Value to poor
    @{channels}=    create list    1    2    3    4    5    6    7    8
    Modify HBTE Channel Vaules    channels=${channels}    value=50    ru_id=0    gnb_id=0

Adjust HBTE ATT Value to good
    @{channels}=    create list    1    2    3    4    5    6    7    8
    Modify HBTE Channel Vaules    channels=${channels}    value=0    ru_id=0    gnb_id=0
