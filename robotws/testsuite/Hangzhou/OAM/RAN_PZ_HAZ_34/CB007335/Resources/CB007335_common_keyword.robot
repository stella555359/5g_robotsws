*** Settings ***
Documentation
...              author: miao.1.lu@nokia-sbell.com

Library          taf.selenium.sbts    WITH NAME    selenium_coam
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library          ute_syslog
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
${epc_log_path}              /tmp
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${btslog_port}                     51000
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
#${gNB_ip}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${NetAct_URL}                https://shanxilbwas.sui6.srnhz.nsn-rdnet.net
${NETACT_USERNAME}                omc
${NETACT_PASSWORD}                Nokia126_

*** Keywords ***
Common setup for 7335
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}
    ...     password=${gNB_password}    connection=${connection}
     ${version}   coam.get_sw_version    connection=${connection}
     ${version_list}    split string    ${version}    _
     ${versiontitle}    set variable    ${version_list[0]}
    Run keyword if    '${versiontitle}'=='SBTS22R4'
    ...    Setup Commission 7335SCF    CURDIR_path=${CURDIR_path1}
    ...    ELSE    Setup Commission 7335SCF    CURDIR_path=${CURDIR_path1_trunk}
    Wait Until Keyword Succeeds   20min     30s    Check BTS Should Be Normal
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission 7335SCF
    [Arguments]    ${CURDIR_path}
#    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
#    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    COAM Commission with scf file     scf_file_path=${CURDIR_path}
    log to console    active DU scf successful

Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TL_NAME_1}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TL_NAME_1}   Set Variable    7_5${TL_NAME_1}[0]
    Set Suite Variable    ${scf_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TL_NAME_1}/

Check BTS Should Be Normal
    [Timeout]  15min
    [Arguments]    ${retry}=800s    ${retry_interval}=10s     ${connection}=GNB_OAM
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Check cell on air    alias=${connection}

Check cell on air
    [Arguments]  ${alias}
    log_to_console    Check cell on air
    ${status}            coam.get_bts_statuses       connection=${alias}
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=800s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=GNB_OAM

Iptables UDP destination port ACCEPT
    [Arguments]    ${connection}=ute
    ssh.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    ssh.Send Command
    ...    command=sudo iptables -I INPUT -i eth0 -p udp --destination-port 51000 -j ACCEPT    connection=${connection}
    [Teardown]       ssh.Disconnect    connection=${connection}

Add COPYSWTOPASSIVEREQ-1
    selenium_coam.add_object
    ...     object_name=MRBTS-${gNB_MRBTS_ID}/MNL-1/CMD-1
    ...     object_class_name=COPYSWTOPASSIVEREQ
    ...     id_value=1
    ...     is_load_default_values=true
    selenium_coam.set_parameter_value   dist_name=MRBTS-${gNB_MRBTS_ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    ...  filter_param=Copy SW and config to passive partition command    new_value=SW and config with health check
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Check Version not equal
    ${version}     selenium_coam.check_current_software_version
    ${active_version}    Collections.get from dictionary    ${version}    Active
    ${passive_version}    Collections.get from dictionary    ${version}    Passive
    Should Not Be Equal     ${active_version}     ${passive_version}

Validate Copy Plan
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Delete COPYSWTOPASSIVEREQ-1
    selenium_coam.delete_parameter    dist_name=MRBTS-${gNB_MRBTS_ID}/MNL-1/CMD-1
    ...  filter_param=Copy SW and config to passive partition command

Add COPYSWTOPASSIVEREQ-1 By Netact
   netact.add_node
   ...   service_name=cmwas
   ...   hostname=${NetAct_URL}
   ...   username=${NetAct_usr}
   ...   password=${NetAct_pwd}
   ...   alias=default

Login netact
    log to console    Login netact
    Wait Until Keyword Succeeds   5m   30s   selenetact.Login    ${NetAct_URL}   ${NetAct_usr}   ${NetAct_pwd}

Logout netact
    log to console    Logout netact
    selenetact.logout

Connect to Netact
     netact_cm.connect_to    hostname=${NetAct_URL}
     ...                     username=${NETACT_USERNAME}
     ...                     password=${NETACT_PASSWORD}

Disconnect from Netact
    [Timeout]           30 seconds
     netact_cm.disconnect

Netact CM Upload
    [Timeout]  3 minutes
    netact_cm.upload    bts_dist_name=MRBTS-${mrbts_id}

Netact CM Import
    [Timeout]  3 minutes
    netact_cm.import_plan    path_to_file=${epc_log_path}/SCF_${mrbts_id}.xml     planname=SCF_${mrbts_id}

Netact Provision Plan
    [Timeout]  3 minutes
    netact_cm.provision    plan_name=SCF_${mrbts_id}

Rest Login DU
    [Arguments]    ${ip_address}=${gNB_ip}    ${username}=${gNB_username}
    ...    ${password}=${gNB_password}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${conn}     set variable    ${alias}
    [Return]    ${conn}

Get BTS release
    ${conn}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    separator=_
    ${bts_release}    set variable    ${version_list[0]}
    [Return]    ${bts_release}
    [Teardown]    Disconnect from DU


Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    ${version}    Get BTS release
    selenium_coam.Enable_Virtual_Display
    ${conn}=    selenium_coam.Login    url=${DU_OAM_IP_URL}    username=${gNB_username}
    ...     password=${gNB_password}
    ...     version=${version}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    selenium_coam.disable_screen_lock
    Log To Console  END:WEBUI Login!
    [Return]    ${alias}

#    [Arguments]    ${version}    ${alias}=cOAM_admin
#    selenium_coam.enable_virtual_display
#    ${conn}=    selenium_coam.login
#    ...    url=${DU_OAM_IP_URL}
#    ...    username=${gNB_username}
#    ...    password=${gNB_password}
#    ...    version=${version}
#    [Return]    ${alias}

Disconnect from DU
#    [Arguments]    ${alias}=cOAM_admin
    Run Keyword And Ignore Error    selenium_coam.logout
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display

Get Active Alarm List
    [Arguments]    ${connection}=default
    Log To Console    Get Active Alarm List
    coam.connect_to    bts_host=${gNB_ip}    bts_port=${443}    username=${gNB_username}    password=${gNB_password}
    ...   name=${connection}
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${faultid_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${faultid_list}    ${fault_id_dic}
    END
    sort list    ${faultid_list}
    [Return]    ${faultid_list}
    [Teardown]    coam.teardown     connection=${connection}

Get history Alarm List
    [Arguments]    ${connection}=default
    Log To Console    Get history Alarm List
    coam.connect_to    bts_host=${gNB_ip}    bts_port=${443}    username=${gNB_username}    password=${gNB_password}
    ...   name=${connection}
    ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
    ${faultid_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${faultid_list}    ${fault_id_dic}
    END
    sort list    ${faultid_list}
    [Return]    ${faultid_list}
    [Teardown]    coam.teardown     connection=${connection}

Check copy version
    [Arguments]
    ${version}     selenium_coam.check_current_software_version
    ${active_version}    Collections.get from dictionary    ${version}    Active
    ${passive_version}    Collections.get from dictionary    ${version}    Passive
    should be equal     ${active_version}     ${passive_version}
    [Return]    ${active_version}

Check copy response
    ${responce}     selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${gNB_MRBTS_ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1/COPYSWTOPASSIVERES-1
    ...  filter_param=Copy SW and config to passive partition result
    should be equal   ${responce}   success

Rollback SW And Check BTS Normal
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}
    ...     password=${gNB_password}    connection=${connection}
    Log To Console    rollback software
    coam.rollback_software    connection=${connection}
    sleep    2min
    Log To Console    wait until BTS normal
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

Check BTS Normal
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}    connection=${connection}
    Log To Console    check BTS normal
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

#***********BTSLOG***********
Start BTSlog
    [Arguments]   ${connection}=ute        ${btslog_name}=btslog.log
    log to console    start capture btslog.
    ${virtualenv_dir}    Adapt Virtualenv
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}
    ...     password=${TEST_PC_PASSWORD}  alias=${connection}
    start syslog    log_dir=${OUTPUT_DIR}    log_name=${btslog_name}    ports=${btslog_port}
    ...    host_ip=${TEST_PC_IP}    alias=${connection}
    ...         ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}
    ...    virtualenv_dir=${virtualenv_dir}

Adapt Virtualenv
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TL_NAME_2}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TL_NAME_2}   Set Variable    7_5${TL_NAME_2}[0]
    ${virtualenv_dir}    set variable if      '${testline_name}' == '${EMPTY}'    /home/ute/test_repo    /home/ute/CIENV/${TL_NAME_2}
    [Return]  ${virtualenv_dir}

Stop BTSlog and check Message
    [Arguments]     ${regexp}    ${connection}=ute
    log to console    stop btslog and check message.
    Wait until keyword succeeds    2x    5s
    ...         wait_for_message_in_syslog_file    alias=${connection}
    ...         regexp=${regexp}
    ...         timeout=3s
    stop syslog     alias=${connection}
    [Teardown]  csn.Disconnect     connection=${connection}
