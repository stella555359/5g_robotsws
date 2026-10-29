*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
#Library    taf.sbts.oam.coam.admin       WITH NAME    coam
#Library    taf.sbts.oam.coam.admin      WITH NAME    sbts
Library    taf.collectors.btslog        WITH NAME    btslog
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

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
${TOP_DN}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/SYNC_CONF_M-1/CLOCK_CONF_M-1/TOP_CONF_M-1
${TOPMASTERIP}    10.57.249.62
${default_scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/

*** Keywords ***
Rest Login DU
    [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
    ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
    [Documentation]   Rest Login DU
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
    Sleep  2
    Connect to gnb coam via ssl  bts_host=${ip_address}
    ...                                    connection=${alias}
    ...                                    username=${username}  password=${password}
    [Return]  ${alias}

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown  connection=${alias}

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
#    Log To Console  Try to logout before login...
#    Run Keyword And Ignore Error    selenium_coam.Logout
#    Log To Console  Logout successfully...
    selenium_coam.Enable_Virtual_Display
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
    Sleep    3s
    Log To Console  END:WEBUI Logout!

SBTS Login
    [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
    ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
    [Documentation]   SBTS Login
    Connect to gnb coam via ssl    connection=${alias}    bts_host=${ip_address}    username=${username}    password=${password}
    [Return]  ${alias}

SBTS Logout
    [Arguments]  ${alias}=default
    [Documentation]   SBTS Logout
    coam.Teardown    connection=${alias}

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=1000s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=default

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
#    Should Be Equal    ${operationalState}    Enabled
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
#    Should Be Equal    ${tmp}    Enabled
#    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
#    Should Be Equal    ${tmp}    Online
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active

Setup Commission SCF
    [Arguments]    ${SBTS_scf_name}=SCF_SBTS00_DU.xml    ${Branch_scf_name}=SCF_SBTS21B_DU.xml
    ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=${SBTS_scf_name}    Branch_scf_name=${Branch_scf_name}
    Rest Login DU
    COAM Commission with scf file    scf_file_path=${default_scf}     connection=default
    [Teardown]    Rest Logout DU

suite setup to prepare default scf
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}    ${connection}=GNB_OAM
    Log To Console    Set Default Scf
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}     connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${default_scf_path}${SBTS_scf_name}
    ...    ${default_scf_path}${Branch_scf_name}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Check Sync Status
    [Arguments]    ${target}   ${expect_syncInputType}    ${expect_isActive}
    ...    ${expect_availability}=Available    ${expect_usability}=Usable    ${expect_tuningMode}=Normal tuning    ${index}=${0}
    Log To Console    Check Sync Status
    ${connection}    SBTS Login
    ${bts_sync_status}    coam.get_bts_sync_source_status    connection=${connection}    target=${target}
    Log To Console    Check syncMode
    ${bts_syncMode}    Get From Dictionary    ${bts_sync_status}    syncMode
    should be equal    ${bts_syncMode}    PhaseSync
    Log To Console    Check syncSourceInfo
    ${syncSourceInfo}    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
    ${isActive}    Get From Dictionary    ${syncSourceInfo[${index}]}    isActive
    should be equal    ${isActive}    ${expect_isActive}
    ${status}    Get From Dictionary    ${syncSourceInfo[${index}]}    status
    ${availability}    Get From Dictionary    ${status}    availability
    should be equal    ${availability}    ${expect_availability}
    ${usability}    Get From Dictionary    ${status}    usability
    should be equal    ${usability}    ${expect_usability}
    ${syncInputType}    Get From Dictionary    ${syncSourceInfo[${index}]}    syncInputType
    should be equal    ${syncInputType}    ${expect_syncInputType}
    Log To Console    Check tuningMode
    ${tuningMode}    Get From Dictionary    ${bts_sync_status}    tuningMode
    should be equal    ${tuningMode}    ${expect_tuningMode}
    [Teardown]    coam.Teardown    connection=${connection}

Change Sync Input Type
    [Arguments]    ${expect_SMOD}    ${synctype}
    Log To Console    Change Sync Input Type
    Rest Login DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sModDN}    get from dictionary    ${parameter_list}    sModDN
        Continue for loop If    '${sModDN}' == '${None}'
        ${SMODlist}    split string    ${sModDN}    /
        ${object}    set variable if    '${SMODlist}[-1]' == '${expect_SMOD}'    ${item}
        Exit For loop if    '${SMODlist}[-1]' == '${expect_SMOD}'
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=${1}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change GNSS Operation Mode
    [Arguments]    ${Actual_value}
    Log To Console    Change GNSS Operation Mode
    Rest Login DU
    Wait Until BTS Should Be Normal
    ${dict}    create dictionary    parameterName=gnssControlMode    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    200s
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change_GNSS_Mode_TRUNK
    [Arguments]    ${beidou_value}=false    ${glonass_value}=true    ${gps_value}=true
    Log To Console    Trunk change GNSS Operation Mode
    Rest Login DU
    ${dict1}    create dictionary    parameterName=actBeidou    operation=update    value=${beidou_value}
    ${dict2}    create dictionary    parameterName=actGlonass    operation=update    value=${glonass_value}
    ${dict3}    create dictionary    parameterName=actGps    operation=update    value=${gps_value}
    ${list}    create list    ${dict1}    ${dict2}    ${dict3}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    200s
    Wait Until BTS Should Be Normal

Check GNSS Mode_trunk
    [Arguments]    ${expect_Beidou_usage}=No    ${expect_Glonass_usage}=Yes    ${expect_Gps_usage}=Yes
#    ${version}     Get Version
    comm_829D.WEBUI Login
    Log To Console    Check GNSS Mode
    ${Get_information_GNSS}    selenium_coam.get_gnss_info
    ${Beidou_usage}    get from dictionary    ${Get_information_GNSS}     Allow usage of BeiDou
    ${Glonass_usage}    get from dictionary    ${Get_information_GNSS}     Allow usage of GLONASS
    ${Gps_usage}    get from dictionary    ${Get_information_GNSS}     Allow usage of GPS
    Should be equal as strings    ${Beidou_usage}    ${expect_Beidou_usage}    ignore_case=${True}
    Should be equal as strings    ${Glonass_usage}    ${expect_Glonass_usage}    ignore_case=${True}
    Should be equal as strings    ${Gps_usage}    ${expect_Gps_usage}    ignore_case=${True}
    [Teardown]    comm_829D.WEBUI Logout

Check GNSS Product Name And status
    [Arguments]  ${expect_product_name}
    comm_829D.WEBUI Login
    Log To Console    Get GNSS Info
    ${Get_information_GNSS}    selenium_coam.get_gnss_info
    ${product_name}    get from dictionary    ${Get_information_GNSS}    Product name
    ${product_code}    get from dictionary    ${Get_information_GNSS}    Product code
    ${serial_num}    get from dictionary    ${Get_information_GNSS}     Serial number
    ${Location_mode}    get from dictionary    ${Get_information_GNSS}     Location mode
    ${Position}    get from dictionary    ${Get_information_GNSS}    Position
    ${Latitude}    get from dictionary    ${Position}    Latitude
    ${Longitude}    get from dictionary    ${Position}    Longitude
    ${Altitude}    get from dictionary    ${Position}    Altitude
    Log To Console    Check status
    should not be equal    ${product_code}    -
    should not be equal    ${serial_num}    -
    should not be equal    ${Latitude}    -
    should not be equal    ${Longitude}    -
    should not be equal    ${Altitude}    -
    Should be equal as strings    ${Location_mode}    automatic
    Should be equal as strings    ${product_name}    ${expect_product_name}
    [Teardown]    comm_829D.WEBUI Logout

Check GNSS Mode
    [Arguments]    ${expect_control_mode}    ${expect_constellation_mode}
    comm_829D.WEBUI Login
    Log To Console    Check GNSS Mode
    ${Get_information_GNSS}    selenium_coam.get_gnss_info
    ${control_mode}    get from dictionary    ${Get_information_GNSS}    Control mode
    ${constellation_mode}    get from dictionary    ${Get_information_GNSS}    Constellation mode
    Should be equal as strings    ${control_mode}    ${expect_control_mode}
    Should be equal as strings    ${constellation_mode}    ${expect_constellation_mode}
    [Teardown]    comm_829D.WEBUI Logout

Delete Structure2 And Change Sync Input Type
    [Arguments]    ${expect_SMOD}    ${synctype}
    Log To Console    Delete Structure2 And Change Sync Input Type
    Rest Login DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sModDN}    get from dictionary    ${parameter_list}    sModDN
        Continue for loop If    '${sModDN}' == '${None}'
        ${SMODlist}    split string    ${sModDN}    /
        ${object}    set variable if    '${SMODlist}[-1]' == '${expect_SMOD}'    ${item}
        Exit For loop if    '${SMODlist}[-1]' == '${expect_SMOD}'
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    remove from list    ${syncInputList}    1
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=${1}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Add Structure2 And Change Sync Input Type
    [Arguments]    ${expect_SMOD}    ${synctype1}    ${synctype2}
    Log To Console    Add Structure2 And Change Sync Input Type
    Rest Login DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sModDN}    get from dictionary    ${parameter_list}    sModDN
        Continue for loop If    '${sModDN}' == '${None}'
        ${SMODlist}    split string    ${sModDN}    /
        ${object}    set variable if    '${SMODlist}[-1]' == '${expect_SMOD}'    ${item}
        Exit For loop if    '${SMODlist}[-1]' == '${expect_SMOD}'
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype1}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=${1}
    ${structure2}    create dictionary     syncInputPrio=${2}    syncInputType=${synctype2}
    append to list    ${syncInputList}    ${structure2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change Two Sync Input Type
    [Arguments]    ${expect_SMOD}    ${synctype1}    ${synctype2}
    Log To Console    Change Two Sync Input Type
    Rest Login DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sModDN}    get from dictionary    ${parameter_list}    sModDN
        Continue for loop If    '${sModDN}' == '${None}'
        ${SMODlist}    split string    ${sModDN}    /
        ${object}    set variable if    '${SMODlist}[-1]' == '${expect_SMOD}'    ${item}
        Exit For loop if    '${SMODlist}[-1]' == '${expect_SMOD}'
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype1}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=${1}
    set to dictionary    ${syncInputList}[1]     syncInputType=${synctype2}
    set to dictionary    ${syncInputList}[1]     syncInputPrio=${2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Check Web TOP Synchronization Detail
    [Arguments]    ${expect_detail_list}
    Log To Console    Check Web TOP Synchronization Detail
    Rest Login DU
    ${topmasterlistinfo}   coam.get_parameters    dist_name=${TOP_DN}/TOPP_CONF_M-1/TOPP_R-1    pattern=topMasterList
    ${Webui_detail_list}    Create List
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['currentUtcOffset']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['currentUtcOffsetValid']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['freqTraceable']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['leap59']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['leap61']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['masterIpAddr']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['ptpTimescale']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['receivedPriority_1']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['receivedPriority_2']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['timeSource']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['timeTraceable']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterClockAccuracy']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterClockClass']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterClockIdentity']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterOffsetScaledLogVariance']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topMasterClockIdentity']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topMasterClockState']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topMasterId']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topMasterPortNumber']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topMasterUsed']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topSlavePortNumber']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topStepsRemoved']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['twoStepFlag']}
    ${len}    get length    ${Webui_detail_list}
    FOR    ${i}    IN RANGE    ${len}
        should be equal as strings    ${expect_detail_list[${i}]}    ${Webui_detail_list[${i}]}
    END
    [Teardown]    Rest Logout DU

Change Top Domain Number
    [Arguments]    ${Domain_value}
    Log To Console    Change Top Domain Number
    Rest Login DU
    ${dict}    create dictionary    parameterName=topDomainNumber    operation=update    value=${Domain_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

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
    Run Keyword And Ignore error    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Check Phase Error
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Check Phase Error
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'phase error'| grep 'time_object:' | rev |cut -d ' ' -f 1| rev | tail -n 1
    ...    connection=VM
    sleep    2s
    ${output}    ssh.read output    connection=VM
    ${number}    evaluate    abs(float(${output}))
    should be true    ${number} < ${1500.0}
    [Teardown]    ssh.disconnect    connection=VM

Check ESelectedClockSource Phase Error
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2    ${Eselect}=ESelectedClockSource_Pps
    Log To Console    Check Phase Error
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command
    ...    cat ${bts_logs_dir}/SYSLOG_*.LOG |grep '${Eselect}'| grep 'phase error'| grep 'time_object:' | rev |cut -d ' ' -f 1| rev | tail -n 1
    ...    connection=VM
    sleep    2s
    ${output}    ssh.read output    connection=VM
    ${number}    evaluate    abs(float(${output}))
    should be true    ${number} < ${1500.0}
    [Teardown]    ssh.disconnect    connection=VM

Disconnect Sync Connector Less Than 5s
    Log To Console    Disconnect Sync Connector Less Than 5s
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    command=iptables -I INPUT -s ${TOPMASTERIP} -j DROP    connection=VM
    sleep    3s
    ssh.send_command    command=iptables -D INPUT -s ${TOPMASTERIP} -j DROP    connection=VM
    [Teardown]    ssh.disconnect    connection=VM

Get BTS Alarm FaultID
    ${connection}    Rest Login DU
    Log To Console    get active alarm
    ${alarm_info}    coam.get_active_alarms    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}
    [Teardown]    Rest Logout DU

Change Secondary SMOD Sync
    [Arguments]   ${command}    ${alias}=ssh
    Log To Console    Change Secondary SMOD Sync
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=${alias}
    sleep    2s
    ssh.send_command    command=${command}    connection=${alias}
    [Teardown]    ssh.disconnect    connection=${alias}

test
    ${connection}    SBTS Login
    ${bts_sync_status}    coam.get_bts_sync_source_status    connection=${connection}    target=secondary
    Log To Console    Check syncMode
    ${bts_syncMode}    Get From Dictionary    ${bts_sync_status}    syncMode
    [Teardown]    coam.Teardown    connection=${connection}
