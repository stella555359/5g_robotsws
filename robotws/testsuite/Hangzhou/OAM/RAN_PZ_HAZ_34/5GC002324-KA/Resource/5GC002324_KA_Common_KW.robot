*** Settings ***
Documentation     author: Shenrao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shengrong.rao@nokia-sbell.com

Resource          ../../common/taf_coam.robot
Resource          ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.selenium.gnb.oam.coam.cu    WITH NAME   coam_cu
Library    taf.gnb.oam.coam.cu    WITH NAME   cu
Library    PM_file.py
Library    taf.ul.oam.netact.cm     WITH NAME     netact_cm
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot

*** Variables ***
${mrbts_id}    MRBTS-${tl.gnbs[0].instance_id}
${nrbts_id}    NRBTS-${tl.gnbs[0].global_bts_id}
${mrbts_instance_id}     ${tl.gnbs[0].instance_id}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${Plan_Name}    ADD_MO
${Netact_username}    omc
${Netact_password}    Nokia126_


*** Keywords ***
Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    Connect to CU admin
    Cell status should be Enabled

Connect to CU admin
    cu.connect to     host=${CU_OAM_IP}
    ...               username=Nemuadmin
    ...               password=nemuuser
    ...               port=${EMPTY}
    ...               cu_version=cuoam_19b
    ...               secure=${True}

Cell status should be Enabled
     ${result_cell_status}=     cu.get_cells_statuses
     ${operability_state}=     set variable    ${result_cell_status[0]['operational_state']}
     should be equal       ${operability_state}     enabled
     cu.disconnect


Case_teardown
    Run Keyword And Ignore Error    coam_cu.Choose Plan    plan_name=DELTA-PLAN-1
    Run Keyword And Ignore Error    coam_cu.delete_plan
    Run Keyword And Ignore Error    coam_cu.logout
    Run Keyword And Ignore Error    coam_cu.disable_virtual_display
    CI_interface.Common Case Teardown

Get version based on stream version
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    #${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    ssh.disconnect  connection=ASIK Master
    [Return]    ${sw_version}


Set reportingIntervalPm to 5min
    coam_cu.set_parameter_value    object_name=${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
    ...    filter_param=Performance measurement data reporting interval
    ...    new_value=5min    abbr=reportingIntervalPm
    sleep    5s

Set miVnfVirtCpuUsage to 5min
    coam_cu.set_parameter_value   object_name=${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=Measurement interval for virtual CPU usage by VNF
    ...    new_value=5min     abbr=miVnfVirtCpuUsage
    sleep    5s

Set reportingIntervalPm to 15min
    coam_cu.set_parameter_value   object_name=${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
    ...    filter_param=Performance measurement data reporting interval
    ...    new_value=15min     abbr=reportingIntervalPm
    sleep    5s

Set miVnfVirtCpuUsage to 15min
    coam_cu.set_parameter_value   object_name=${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=Measurement interval for virtual CPU usage by VNF
    ...    new_value=15min     abbr=miVnfVirtCpuUsage
    sleep    5s

Get parameters from webui and set parameters
    log to console    Get parameter "reportingIntervalPm" and "miVnfVirtCpuUsage"
    coam_cu.enable_virtual_display
    sleep    5s
    coam_cu.login    url=${WEBUI_URL}     browser=Firefox
    coam_cu.create_delta_plan   plan_name=${Plan_Name}
    sleep    5s
    coam_cu.Choose Plan    plan_name=${Plan_Name}
    sleep    5s
    ${reportingIntervalPm}    coam_cu.get_parameter_value    object_name=${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
    ...    filter_param=Performance measurement data reporting interval    abbreviation=reportingIntervalPm
    ${miVnfVirtCpuUsage}    coam_cu.get_parameter_value    object_name=${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...     filter_param=Measurement interval for virtual CPU usage by VNF	    abbreviation=miVnfVirtCpuUsage
    run keyword if    "${reportingIntervalPm}" != "5min"     Set reportingIntervalPm to 5min    ELSE    Set reportingIntervalPm to 15min
    run keyword if    "${miVnfVirtCpuUsage}" != "5min"     Set miVnfVirtCpuUsage to 5min    ELSE    Set miVnfVirtCpuUsage to 15min
    ${reportingIntervalPm_1}    coam_cu.get_parameter_value    object_name=${mrbts_id}/MNL-1/MNLENT-1/PMCADM-
    ...     filter_param=Performance measurement data reporting interval    abbreviation=reportingIntervalPm
    ${miVnfVirtCpuUsage_1}    coam_cu.get_parameter_value    object_name=${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...     filter_param=Measurement interval for virtual CPU usage by VNF	    abbreviation=miVnfVirtCpuUsage
    Set Suite Variable    ${reportingIntervalPm_1}
    Set Suite Variable    ${miVnfVirtCpuUsage_1}
    should be true    '${reportingIntervalPm}'!='${reportingIntervalPm_1}'
    should be true    '${miVnfVirtCpuUsage}'!='${miVnfVirtCpuUsage_1}'

Check PM files in OAM
    wait until keyword succeeds     2s    1s
    ...    ssh.connect_to    hostname=${CU_OAM_IP}
    ...    username=robot
    ...    password=rastre1
    ...    alias=com
    csn.SendCommand    command=ls -l /mnt/services/PM9/storage/results    connection=com
    ${pmfiles}    csn.read output    connection=com
    ${time_list}  Check pm files on oam    output=${pmfiles}
    Check config is correct    pmtime_list=${time_list}    time_value=${reportingIntervalPm_1}
    ${matched_content}    Should Match Regexp      ${pmfiles}    A?.*?.xml
    should not be empty    ${pmfiles}
    csn.disconnect    connection=com

Remove PM files before check PM files
    wait until keyword succeeds     2s    1s
    ...    ssh.connect_to    hostname=${CU_OAM_IP}
    ...    username=robot
    ...    password=rastre1
    ...    alias=com
    csn.SendCommand    command=rm -rf /mnt/services/PM9/storage/results/*  connection=com
    csn.disconnect    connection=com

Connect to Netact
     netact_cm.connect_to    hostname=${NetAct_dmgr}
     ...                     username=${NETACT_USERNAME}
     ...                     password=${NETACT_PASSWORD}

