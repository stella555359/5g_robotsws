*** Settings ***
Documentation     author: Shenrao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shengrong.rao@nokia-sbell.com

Resource          ../../common/taf_coam.robot   
Resource          ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource          ../../5GC001187-E/Resource/5GC001187-E-5GC000157_Common_KW.robot
Library    taf.ul.selenium.netact    WITH NAME    selenetact
Library    taf.ul.swing.core    WITH NAME    swing
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${mrbts_id}    MRBTS-${tl.gnbs[0].instance_id}
${nrbts_id}    NRBTS-${tl.gnbs[0].global_bts_id}
${linkcapacity}    9830
*** Keywords ***
AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=COAM
    admin_cli.teardown    connection=LCOAM
    CI_interface.Common Case Teardown

Case_teardown
    run keyword and ignore error    AdminCli disconnection and Test teardown

COAM Check GNB_DU cell on air
    [Documentation]  Author: Ding Binmei
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

Connect to control pc and Trigger alarm and clear alarm
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${alias}=cygwin
    csn.Connect to    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=${alias}
    COAM Update Parameter    dist_name=${mrbts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1    parameter=speedAndDuplex    value=25GBIT_FULL
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...    name=LCOAM
    Wait For Expect Fault Present    faultId=61029    timeout=3min    connection=LCOAM
    COAM Update Parameter    dist_name=${mrbts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1    parameter=speedAndDuplex    value=${speedAndDuplex}
    Wait For Expect Fault To Disappear    faultId=61029    timeout=3min    connection=LCOAM

Get parameters from webui   
    log to console    Get parameters from webui and set parameters    
    ${speedAndDuplex}    Get NIDD parameter value    class_name=ETHLK_A    pattern=speedAndDuplex    connection=COAM
    Set Suite Variable    ${speedAndDuplex}

Get current alarms
    [Arguments]    ${connection}=COAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    @{alarms}    Create List
    FOR    ${active_alarm}    IN    @{active_alarms_list}
        ${alarm}    Create Dictionary    faultId=${active_alarm}[faultId]
        Append To List    ${alarms}    ${alarm}
    END
    log to console     Current Testline Fault is: ${alarms}
    [Return]    ${alarms}
