*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin       WITH NAME    coam
Library    taf.hw.rf_attenuator           WITH NAME    att
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Library    ../../UUF/Scripts/UUF_common.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${ue_type}    ${tl.ues[0].capabilities[1]}
${att_ipaddr}    ${tl.attenuator.ip_addr}
${att_api_port}    ${tl.attenuator.port}
${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_5}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_6}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_11}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_12}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${vendor}    HBTE
${max_attenuation_value}    ${127}
${IPERF_ADDR}    ${tl.appserver.iperf_details.network_interface_address}
${IPERF_PORT}    ${tl.appserver.iperf_details.port}
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${default_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_0.800_DU.xml
${default_scf_21A}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_11.800_DU.xml

*** Keywords ***
Rest Login DU
    [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
    ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
    [Documentation]   Rest Login DU
    Run Keyword And Ignore Error    comm_5958D.Rest Logout DU   alias=${alias}
    Sleep  2
    ${connection}   coam.Connect To  bts_host=${ip_address}  bts_port=443
    ...                                    name=${alias}
    ...                                    username=${username}  password=${password}
    [Return]  ${connection}

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown  connection=${alias}

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to logout before login...
    Run Keyword And Ignore Error    selenium_coam.Logout
    Log To Console  Logout successfully...
    Log To Console  Try to login...
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    Log To Console  END:WEBUI Login!

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    1s
    Log To Console  END:WEBUI Logout!

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=400s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=default

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should be equal as strings    ${operationalState}      Enabled      ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should be equal as strings    ${tmp}      Enabled      ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active

Setup Commission SCF
    ${connection}    Rest Login DU
    ${versiontitle}    Get Version
    Run keyword if    '${versiontitle}'=='SBTS22R2'
    ...    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    ...    ELSE    COAM Commission with scf file    scf_file_path=${default_scf_21A}    connection=${connection}
    Sleep   10min
    [Teardown]    Rest Logout DU

Get Version
    [Arguments]    ${connection}=GNB_OAM
    Log To Console    Get Version
    Connect to gnb coam via ssl   bts_host=${DU_OAM_IP}     connection=GNB_OAM
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${connection}

Lock BTS Cell
    [Arguments]    ${alias}=default
    Log To Console    Lock BTS Cell
    Rest Login DU
    Perform cell lock via rest api    connection=${alias}
    [Teardown]    Rest Logout DU

Unlock BTS Cell
    [Arguments]    ${alias}=default
    Log To Console    Unlock BTS Cell
    Rest Login DU
    Perform cell unlock via rest api    connection=${alias}
    sleep    3s
    [Teardown]    Rest Logout DU

Lock And Unlock Cell And Sleep
    [Arguments]    ${alias}=default
    Log To Console    Lock And Unlock Cell And Sleep
    Rest Login DU
    Perform cell lock via rest api    connection=${alias}
    _check_cell_status    expect_prostate=IntegratedToRan    expect_lockstate=Locked
    sleep    3min
    Perform cell unlock via rest api    connection=${alias}
    wait until keyword succeeds    400s    10s    _check_cell_status    expect_prostate=OnAir    expect_lockstate=Unlocked
    [Teardown]    Rest Logout DU

Check Cell Locking Status
    [Arguments]    ${expect_prostate}    ${expect_lockstate}=Unlocked    ${alias}=default    ${cell_type }=nr
    Rest Login DU
    Log To Console    Check Cell Locking Status
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    ${expect_prostate}
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    ${expect_lockstate}
    [Teardown]    Rest Logout DU

_check_cell_status
     [Arguments]    ${expect_prostate}    ${expect_lockstate}=Unlocked    ${alias}=default    ${cell_type }=nr
    Log To Console    check cell status
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    ${expect_prostate}
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    ${expect_lockstate}

Get NR_CELL PM Counter
    [Arguments]    ${counter_id}    ${alias}=default
    Log To Console    Get NR_CELL PM Counter
    Rest Login DU
    ${result}    coam.get_PM_counters    couter_ids=${counter_id}    connection=${alias}
    ${counter_list}    get dictionary values    ${result['BTS']['CELLS']['NRCELL-1']['NCAV']['${counter_id}']}
    [Return]    ${counter_list}
    [Teardown]    Rest Logout DU

Change aperiodic CSI reporting
    [Arguments]    ${Actual_value}
    Log To Console    Change aperiodic CSI reporting
    Rest Login DU
    ${dict}    create dictionary    parameterName=actAperCsi    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    10s
    [Teardown]    Rest Logout DU

Change RMOD Administrative
    [Arguments]    ${Actual_value}
    Log To Console    Change RMOD Administrative
    Rest Login DU
    ${dict}    create dictionary    parameterName=administrativeState    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    10s
    [Teardown]    Rest Logout DU

Adjust HBTE Attenuation
    [Arguments]    ${port_value1}    ${port_value2}   ${port_value3}   ${port_value4}
    Log To Console    Adjust HBTE Attenuation
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_5}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation    port=${att_port_1}    value=${port_value1}
    att.set_attenuation    port=${att_port_2}    value=${port_value1}
    att.set_attenuation    port=${att_port_5}    value=${port_value3}
    att.set_attenuation    port=${att_port_6}    value=${port_value3}
    att.set_attenuation    port=${att_port_11}    value=${port_value4}
    att.set_attenuation    port=${att_port_12}    value=${port_value4}

Check UE Attach
    Adjust HBTE Attenuation    port_value1=${10}    port_value2=${max_attenuation_value}
    ...    port_value3=${10}    port_value4=${50}
    Log To Console    Prepare UE
    power_ue.Prepare UE    ue_type=${ue_type}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    UE Detach
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}

Get PM Counter From NecAct
    [Arguments]    ${pmcounter}    ${expect_counter_value}    ${cellid}=${1}    ${host}=${DU_OAM_IP}
    sleep    5s
    ${pm_counter_value}    get_pm_counter_from_gnb    cellid=${cellid}    pmcounter=${pmcounter}    host=${host}
    should be true    ${pm_counter_value}[-1] == ${expect_counter_value}

Start Catch BTS Log
    [Arguments]   ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Start Catch BTS Log
    __Make empty BTS logs dir      bts_logs_dir=${bts_logs_dir}
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    Log To Console    Stop and collect btslog on local machine
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Check M55601C01001 Counter In BTS Log
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Check M55601C01001 Counter
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'CellAutoBlockerNG'| grep 'unblockCells finished' | awk '{print $6}'
    ...    connection=VM
    sleep    2s
    ${output}    ssh.read output    connection=VM
    ${output_list}    split string    ${output}    \n
    ${time1}    replace string    ${output_list}[0]    T    ${SPACE}
    ${time1}    replace string    ${time1}    Z    ${EMPTY}
    ${time2}    replace string    ${output_list}[1]    T    ${SPACE}
    ${time2}    replace string    ${time2}    Z    ${EMPTY}
    ${time}   subtract date from date    ${time1}    ${time2}
    ${time_value}    evaluate    abs(float(${time}))
    [Teardown]    ssh.disconnect    connection=VM
    [Return]    ${time_value}

test
    ${pm_counter_value}    get_pm_counter_from_gnb    cellid=${1}    pmcounter=M55601C01002    host=${DU_OAM_IP}
