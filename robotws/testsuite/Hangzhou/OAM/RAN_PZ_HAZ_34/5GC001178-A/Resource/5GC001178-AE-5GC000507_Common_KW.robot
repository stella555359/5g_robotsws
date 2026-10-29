*** Settings ***
Documentation     author: Liu Yue
...               Group: HGZ_SG5
...               contact: yue.2.liu@nokia-sbell.com

Resource          ../../common/coam_resource.robot
Library           ../../libraries/get_bts_info.py   WITH NAME    lib
Library           ../Library/python_1178-507.py

*** Variables ***
${lssIPaddress}    10.57.157.105
${lssPortNo}    22
${lssAccount}    cOAM
${lssPassword}    zO&n1W*ktp7

*** Keywords ***
Obtain_BTS_Name_ID
    Backup_SCF_file_on_WebEM
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${scf_file_path}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${scf_file_path}
    set suite variable     ${mrbtsId}
    set suite variable     ${nrbtsId}

Backup_SCF_file_on_WebEM
    log to console    Backup_SCF_file_on_WebEM
    ${flag_result}   ${scf_file}    Run Keyword And Ignore Error    selenium_coam.backup_bts_site_configuration    download_timeout=600
    sleep    5s
    ${scf_file_path}    OperatingSystem.Copy File    ${scf_file}    ${SAVE LOG DIRECTORY}
    set suite variable     ${scf_file_path}

Case setup
    cOAM Common Test Setup
    WEBUI Login
    Obtain_BTS_Name_ID
    #check RU STATUS
   # Run Keyword And Ignore Error    "Setup" Delete TRBLCADM Object
    Run Keyword And Ignore Error    Delete faultSnapshotTriggers Element
    Clear lss server

Delete faultSnapshotTriggers Element
    selenium_coam.delete_parameter    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers       timeout=${100}
    Validate and activate and check activate plan status

Case teardown
    WEBUI Login
    Run Keyword And Ignore Error    Delete faultSnapshotTriggers Element
    Run Keyword And Ignore Error    WEBUI Logout

"${Step}" Delete TRBLCADM Object
    selenium_coam.remove_object    object_name=TRBLCADM-1    timeout=60
    Validate and activate and check activate plan status

"${Step}" Add TRBLCADM Under MNLENT
    log to console    "${Step}" Add TRBLCADM Under MNLENT
    #${result}          selenium_coam.get_object_name_list      parent_name=${mrbtsId}/MNL-1/MNLENT-1    parameter_name=TRBLCADM
    #run keyword if       selenium_coam.add_object    object_name=${mrbtsId}/MNL-1/MNLENT-1    object_class_name=TRBLCADM
   # ...   plan_to_copy_from=CURRENT_BTS_CONF-1     is_load_default_values=${false}    id_value=1    timeout=${100}
    #sleep    5s
    run keyword and ignore error       selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Activate core dump file collection      new_value=true    timeout=${100}
    sleep    2s
    run keyword and ignore error      selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Activate internal trace     new_value=true    timeout=${100}
    sleep    2s
    run keyword and ignore error      selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Activate remote syslog transmission      new_value=false     timeout=${100}
    sleep    2s
    run keyword and ignore error      selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Snapshot upload delay for fault 6450      new_value=${0}     timeout=${100}
    Configure lss server
    sleep    5s
    Validate and activate and check activate plan status
    sleep    2s

Configure lss server
    log to console    Configure lss server
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Diagnsostic Snapshot destination     new_value=lss     timeout=${300}
    sleep    5s
    run keyword and ignore error     selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Local symptoms server configuration      timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Local symptoms server IP address     new_value=${lssIPaddress}    timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Local symptoms server IP port number     new_value=${lssPortNo}    timeout=${100}

"${Step}" Set Upto 20 faultNumber And Success
    log to console    "${Step}" Set Upto 20 faultNumber And Success
    log to console    Add 1 to 6 faultNumber
    run keyword and ignore error     selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
     ...    filter_param=Fault snapshot triggers      timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number     parameter_status=Show only modified parameters    new_value=${10}    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type      new_value=onAlarmSend    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error      selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number      new_value=${4520}    node_index=${1}    timeout=${100}
    sleep    2s
    run keyword and ignore error      selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type      new_value=onAlarmSend    node_index=${1}    timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...     filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number    new_value=${1928}    node_index=${2}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type     new_value=onAlarmSend    node_index=${2}    timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number     new_value=${4001}    node_index=${3}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type     new_value=onAlarmSend    node_index=${3}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number     new_value=${4019}    node_index=${4}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type     new_value=onAlarmSend    node_index=${4}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers     timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number     new_value=${30}    node_index=${5}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type    new_value=onAlarmSend    node_index=${5}    timeout=${100}
    sleep    2s
    Validate and activate and check activate plan status
    log to console    Add 7 to 11 faultNumber
    run keyword and ignore error    selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Fault snapshot triggers     timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1    filter_param=Fault number
    ...    parameter_status=Show only modified parameters    new_value=${1927}    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type   new_value=onAlarmSend    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number    new_value=${1900}    node_index=${1}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type    new_value=onAlarmSend    node_index=${1}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number   new_value=${1901}    node_index=${2}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type    new_value=onAlarmSend    node_index=${2}    timeout=${100}
    sleep    2s
    run keyword and ignore error  selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number   new_value=${1907}    node_index=${3}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type    new_value=onAlarmSend    node_index=${3}    timeout=${100}
    sleep    2s
    run keyword and ignore error  selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error  selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number    new_value=${1815}    node_index=${4}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type     new_value=onAlarmSend    node_index=${4}    timeout=${100}
    sleep    2s
    Validate and activate and check activate plan status
    log to console    Add 12 to 16 faultNumber
    run keyword and ignore error     selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1    filter_param=Fault number
    ...    parameter_status=Show only modified parameters    new_value=${1811}    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1    filter_param=Trigger type
    ...    new_value=onAlarmSend    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number    new_value=${1819}    node_index=${1}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type    new_value=onAlarmSend    node_index=${1}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number    new_value=${1850}    node_index=${2}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type    new_value=onAlarmSend    node_index=${2}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number    new_value=${1817}    node_index=${3}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...     filter_param=Trigger type    new_value=onAlarmSend    node_index=${3}    timeout=${100}
    sleep    2s
    run keyword and ignore error    run keyword and ignore error    selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number    new_value=${26}    node_index=${4}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type     new_value=onAlarmSend    node_index=${4}    timeout=${100}
    sleep    2s
    Validate and activate and check activate plan status
    log to console    Add 17 to 19 faultNumber
    run keyword and ignore error    selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number    parameter_status=Show only modified parameters    new_value=${95}    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type    new_value=onAlarmSend    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number   new_value=${94}    node_index=${1}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...     filter_param=Trigger type   new_value=onAlarmSend    node_index=${1}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number   new_value=${16}    node_index=${2}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type   new_value=onAlarmSend    node_index=${2}    timeout=${100}
    sleep    2s
    Validate and activate and check activate plan status
    log to console    Add 20 faultNumber
    run keyword and ignore error   selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1    filter_param=Fault number
    ...    parameter_status=Show only modified parameters    new_value=${23}    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type   new_value=onAlarmSend    node_index=${0}    timeout=${100}
    sleep    2s
    Validate and activate and check activate plan status
    ${output}    Run Keyword And Ignore Error    selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    log    ${output}

"${Step}" Trgger Fault 10
    log to console    "${Step}" Trgger Fault 10
    Turn Off PDU     pdu_type=${PDU_type}     pdu_ip=${powerstation_ip_RU}
    ...    pdu_port=${powerstation_port_RU}     Port_Number=${powerstation_asik_port_RU}
    sleep    15s
    Wait Until Keyword Succeeds    30s    5s    Check Fault occurs    No connection to unit

"${Step}" Cancel Fault 10
    log to console    "${Step}" Cancel Fault 10
    sleep    10s
    Turn On PDU     pdu_type=${PDU_type}     pdu_ip=${powerstation_ip_RU}
    ...   pdu_port=${powerstation_port_RU}     Port_Number=${powerstation_asik_port_RU}
    sleep    10s
    Wait Until Keyword Succeeds    10min    30s    Check Fault cancel    No connection to unit

Check Fault occurs
    [Arguments]    ${FaultId}
    ${Output}    selenium_coam.get_active_alarm_info    alarm_filter=${FaultId}
    Should Not Be Empty    ${Output}

Check Fault cancel
    [Arguments]    ${FaultName}
    ${Output}    selenium_coam.get_active_alarm_info    alarm_filter=${FaultName}
    Should Be Empty    ${Output}

"${Step}" Check snapshot log capture
    log to console    "${Step}" Check snapshot log capture
    sleep    30s
    csn.connect to     hostname=${lssIPaddress}     username=${lssAccount}     password=${lssPassword}    alias=VM
    ${Output}    csn.execute    command=ls | grep Snapshot    connection=VM
    ${Result}    checkSnapshotContent    /home/cOAM/${Output}
    listShouldContain    ${Result}    metadata
    listShouldContain    ${Result}    1011
    csn.disconnect    connection=VM

"${Step}" Check snapshot no log capture
    log to console    "${Step}" Check snapshot no log capture
    sleep    10s
    csn.connect to     hostname=${lssIPaddress}     username=${lssAccount}     password=${lssPassword}    alias=VM
    ${Output}    csn.execute    command=ls | grep Snapshot    connection=VM
    Should Be Empty    ${Output}
    csn.disconnect    connection=VM

Clear lss server
    csn.connect to     hostname=${lssIPaddress}     username=${lssAccount}     password=${lssPassword}    alias=VM
    csn.send_command    command=rm -r Snapshot*    connection=VM
    csn.disconnect    connection=VM

Set Fault Trigger Snapshot Parameter
    [Arguments]    ${triggerType}    ${faultId}    ${index}
    run keyword and ignore error   selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    sleep    2s
    run keyword and ignore error  selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number    new_value=${faultId}    node_index=${index}    timeout=${100}
    sleep    2s
    run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1    filter_param=Trigger type
    ...    new_value=${triggerType}    node_index=${index}    timeout=${100}
    sleep    5s
    Validate and activate and check activate plan status

Remove Fault Trigger Snapshot Parameter
    [Arguments]    ${faultId}    ${index}
    run keyword and ignore error   selenium_coam.remove_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    node_index=${index}   timeout=${100}
    sleep    5s
    Validate and activate and check activate plan status

"${Step}" Set Fault Trigger Snapshot onAlarmSend
    log to console    "${Step}" Set Fault Trigger Snapshot onAlarmSend
    Set Fault Trigger Snapshot Parameter    triggerType=onAlarmSend    faultId=${10}    index=${0}

"${Step}" Set Fault Trigger Snapshot onFaultCancel
    log to console    "${Step}" Set Fault Trigger Snapshot onFaultCancel
    Set Fault Trigger Snapshot Parameter    triggerType=onFaultCancellation     faultId=${10}     index=${0}

"${Step}" Check Fault Trigger Empty
    log to console    "${Step}" Check Fault Trigger Empty
    ${Output}    Run Keyword And Ignore Error    selenium_coam.get_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers    timeout=${100}
    log    ${Output}
    Should Be Equal    ${Output[0]}    FAIL