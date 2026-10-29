*** Settings ***
Documentation     author: Shenrao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shengrong.rao@nokia-sbell.com

Resource          ../../common/taf_coam.robot   
Resource          ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Library           PM_files.py


*** Variables ***
${mrbts_id}    MRBTS-${tl.gnbs[0].instance_id}
${nrbts_id}    NRBTS-${tl.gnbs[0].global_bts_id}
${reportingIntervalPm_1}    5min
${mrbts_instance_id}     ${tl.gnbs[0].instance_id}

*** Keywords ***
AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    #admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    admin_cli.teardown    connection=COAM
    CI_interface.Common Case Teardown

Case_teardown
    Run Keyword And Ignore Error    csn.send_command     command=rm -rf /home/ute/snapshot/*    connection=ute
    run keyword and ignore error    AdminCli disconnection and Test teardown


unzip snapshot log and check PM files
    [Arguments]    ${local_file_path}
    csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=ute
    #csn.execute    command=cp ${snapshot_log} ${SAVE LOG DIRECTORY}    connection=ute
    csn.SendCommand    command=mkdir /home/ute/snapshot    connection=ute
    ${snapshot_extract}    Set Variable    /home/ute/snapshot
    csn.execute    command=unzip -o ${local_file_path} -d ${snapshot_extract}    connection=ute
    sleep     5s
    csn.SendCommand    command=cat /home/ute/snapshot/snapshot_file_list.txt    connection=ute
    ${pmfile}    csn.read output    connection=ute
    ${matched_content}    Should Match Regexp      ${pmfile}    BTS${mrbts_instance_id}_1011_PM.BTS.*?.xml
    should not be empty    ${matched_content}
    csn.send_command     command=rm -rf /home/ute/snapshot/*    connection=ute
    #csn.Disconnect    connection=ute

Set reportingIntervalPm to 5min
    COAM Update Parameter    dist_name=${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1    parameter=reportingIntervalPm    value=5min
    sleep    5s

Set miNrHighRlcReport to 5min
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}/NRPMRNL-1    parameter=miNrHighRlcReport     value=5min
    sleep    5s

Set reportingIntervalPm to 15min
    COAM Update Parameter    dist_name=${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1    parameter=reportingIntervalPm    value=15min
    sleep    5s

Set miNrHighRlcReport to 15min
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}/NRPMRNL-1    parameter=miNrHighRlcReport     value=15min
    sleep    5s

Set miNrF1CD to 5min
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}/NRPMRNL-1    parameter=miNrF1CD     value=5min
    sleep    5s

Set miNrF1CD to 15min
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}/NRPMRNL-1    parameter=miNrF1CD     value=15min
    sleep    5s

Set miNrF1UDInterface to 5min
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}/NRPMRNL-1    parameter=miNrF1UDInterface     value=5min
    sleep    5s

Set miNrF1UDInterface to 15min
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}/NRPMRNL-1    parameter=miNrF1UDInterface     value=15min
    sleep    5s

Get parameters from webui and set parameters   
    log to console    Get parameter "reportingIntervalPm" and "miNrHighRlcReport"    
    ${reportingIntervalPm}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    ${miNrHighRlcReport}    Get NIDD parameter value    class_name=NRPMRNL_A    pattern=miNrHighRlcReport    connection=COAM
    run keyword if    "${reportingIntervalPm}" != "5min"     Set reportingIntervalPm to 5min    ELSE    Set reportingIntervalPm to 15min
    run keyword if    "${miNrHighRlcReport}" != "5min"     Set miNrHighRlcReport to 5min    ELSE    Set miNrHighRlcReport to 15min
    ${reportingIntervalPm_1}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    ${miNrHighRlcReport_1}    Get NIDD parameter value    class_name=NRPMRNL_A    pattern=miNrHighRlcReport    connection=COAM
    Set Suite Variable    ${reportingIntervalPm_1}
    Set Suite Variable    ${miNrHighRlcReport_1}
    should be true    '${reportingIntervalPm}'!='${reportingIntervalPm_1}'
    should be true    '${miNrHighRlcReport}'!='${miNrHighRlcReport_1}'

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

Check PM files in OAM
    wait until keyword succeeds     2s    1s
    ...    csn.connect_to    hostname=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    username=toor4nsn
    ...    password=oZPS0POrRieRtu
    ...    alias=gnb
    csn.SendCommand    command=ls -l /rom/uri/PERFMON_FILES    connection=gnb
    ${pmfiles}    csn.read output    connection=gnb
    ${time_list}    Check pm files on oam    output=${pmfiles}
    Check config is correct    pmtime_list=${time_list}    time_value=${reportingIntervalPm_1}
    ${matched_content}    Should Match Regexp      ${pmfiles}    PM.BTS.*?.xml
    should not be empty    ${pmfiles}
    csn.disconnect    connection=gnb

Remove PM files before check PM files
    wait until keyword succeeds     2s    1s
    ...    csn.connect_to    hostname=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    username=toor4nsn
    ...    password=oZPS0POrRieRtu
    ...    alias=gnb
    csn.SendCommand    command=rm -rf /rom/uri/PERFMON_FILES/*  connection=gnb
    csn.disconnect    connection=gnb