*** Settings ***
Documentation
...    Author: yingying.li
...    Contact: yingying.li@nokia-sbell.com

Library    Collections
Library    String
Library    OperatingSystem
Library    XML  lxml=True
Library    taf.gnb.oam.coam.admin   WITH NAME   admin_cli
Library    taf.transport.ssh		WITH NAME	ssh
Library     taf.collectors.core      WITH NAME   core
Library     taf.collectors.btslog    WITH NAME   btslog
Library     5GC000829-D.py
Library     taf.transport.ssh    WITH NAME    trs_ssh


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${testpc_host}    ${tl.test_pc.default_ssh_connection_details.addr}
#${testpc_user}    ${tl.test_pc.default_ssh_connection_details.username}
${testpc_user}     lab5g
#${testpc_pswd}    ${tl.test_pc.default_ssh_connection_details.password}
${testpc_pswd}     Noki@pdz123!
*** Keywords ***
start BTSLOG collection
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    Make empty BTS logs dir     ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}


Set mrbtsId variable
    Connect to gnb coam via ssl
    admin_cli.collect scf   target_file_name=/home/ute/scf.xml    connection=GNB_OAM
    ${XML}=   Parse XML   /home/ute/scf.xml
    ${mrbtsId_element}=   Get Element   ${XML}   .//managedObject[@class="com.nokia.srbts:MRBTS"]
    set suite variable   ${mrbtsId}   ${mrbtsId_element.attrib['distName']}


Set syslogSubstringTrigger parameter
    [Arguments]    ${StringTrigger}
    admin_cli.perform_parameter_recommissioning
    ...                                         dist_name=${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                         parameter=syslogSubstringTrigger
    ...                                         operation=update
    ...                                         value=${StringTrigger}
    ...                                         skip_parameter_relation_errors=True
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM

Change Parameter
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}
    admin_cli.perform_parameter_recommissioning   ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=GNB_OAM

Perform lssConfig complex parameter activation
    [Arguments]    ${lssIPaddress}
    ...            ${lssPortNo}
    ${lss_dict}=
    ...                admin_cli.get_parameters
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1
    ...                pattern=lss
    ...                connection=GNB_OAM
    ${list_parameters}=    Get From Dictionary    ${lss_dict['lssConfig']}
    ...                                           lssIPaddress
    ${list_param_to_change}=    Create Dictionary    lssIPaddress    1.0.0.0
    Set To Dictionary    ${list_param_to_change}    lssIPaddress=${lssIPaddress}
    ...                                             lssPortNo=${lssPortNo}
    @{list}=    create list    ${list_param_to_change}
    admin_cli.perform_parameter_recommissioning    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=lssConfig
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=skip
    ...                                           connection=GNB_OAM

Admin Lock Cell for snapshot
    [Arguments]         ${connection}=GNB_OAM
    ${dist_name_list}     get_admin_cells_mrbts    connection=${connection}
    ${nr_cell}    get from list   ${dist_name_list}    0
    ${status}  admin_cli.lock  dist_name=${nr_cell}    timeout=60s    connection=${connection}
    should be equal as strings   ${status}      completed
    Set test variable    ${nr_cell}



Check if snapshot trigger occured in syslog
    ${log_with_trigger}=    find string in syslog    AUTOMATIC TriggerType
    #${trigger_line}=    Get Line    ${log_with_trigger}    -2
    should contain    ${log_with_trigger}    Trigger: AUTOMATIC TriggerType: On syslog substring -

find string in syslog
    [Arguments]    ${StringTrigger}
     Connect ssh to UTE
     ${syslogstring}=    ssh.execute    command=grep '${StringTrigger}' /tmp/btslog2/SYSLOG_*    connection=UTE
    [Return]    ${syslogstring}

Connect ssh to UTE
    [Documentation]
    ...  Establish connection to UTE via SSH
    trs_ssh.Connect To
    ...    hostname=${testpc_host}
    ...    username=${testpc_user}
    ...    password=${testpc_pswd}
    ...    alias=UTE


Check existence of remote snapshot
    [Arguments]    ${host}     ${user}    ${pass}     ${dir}
    ssh_lib.Open Connection   ${host}
    ssh_lib.Login    ${user}    ${pass}
    ${FileList}=    ssh_lib.List Directory    ${dir}
    log    ${FileList}
#    ${whole_name_lss}    check if snapshot name is defined for lss
#    Should Contain Match    ${FileList1}    ${whole_name_lss}
    Should Contain Match    ${FileList}    Snapshot_${mrbtsId}*



BTSLOG Collect log
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
    run keyword and ignore error    __Stop and collect btslog on local machine
    Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}


Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz
    Run  rm ${bts_logs_dir}/*

delete snapshot files in LSS
    Connect coam to LSS
    log to console    connect to LSS done
    ssh.execute    command=sudo rm -rf /home/coam/*    connection=LSS

Connect coam to LSS
    [Documentation]
    ...  Establish connection to LSS via SSH
    trs_ssh.Connect To
    ...    hostname=${lssIPaddress}
    ...    username=${testpc_user}
    ...    password=${testpc_pswd}
    ...    alias=LSS


Admin Unlock Cell after execution
    [Arguments]         ${connection}=GNB_OAM
    ${status}  admin_cli.unlock  dist_name=${nr_cell}    timeout=60s    connection=${connection}


Clear syslogSubstringTrugger parameter
    admin_cli.perform_parameter_recommissioning
    ...                                         dist_name=${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                         parameter=syslogSubstringTrigger
    ...                                         operation=delete
    ...                                         value=${False}
    ...                                         skip_parameter_relation_errors=True
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM


Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi


__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}



ADMIN CLI disconnection
    [Arguments]       ${connection}=GNB_OAM
    Log    \n *** Case teardown
    admin_cli.teardown    connection=${connection}

check if snapshot name is defined for lss
    ${snap_line}=    find string in syslog    creating remote directory:
    should contain    ${snap_line}    creating remote directory:
    log    ${snap_line}
    @{list_line}=    Split String    ${snap_line}
    ${index_lss}=    get index from list    ${list_line}    directory:
    ${index1}=    Evaluate    ${index_lss}+1
    ${whole_name_lss}=    Get from list    ${list_line}    ${index1}
    log    ${whole_name_lss}
    [Return]    ${whole_name_lss}



