*** Settings ***
Documentation     author: Shenrao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shengrong.rao@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
#Library    taf.selenium.gnb.oam.coam.classical        WITH NAME    selenium_coam
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Library     taf.sw.dcap.rd		WITH NAME	DCAP
Library     robot.libraries.DateTime
Library     taf.transport.ssh.interface.ssh       WITH NAME    tafssh

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/DCAP.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/emil.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot

*** Variables ***

${dltp}    10
${ultp}    5
${counter_path2}    BTS/CELLS/NRCELL-1/NRACH
${counter_path1}    BTS/MRBTS-10042/NRBTS-10042/NRCELL-1/NRACH
#${SCF_TEMPLATE_PATH}    ${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G402T923
${scf_file_path}    ${commissionings_path}/HGZ/7_5_UTE5G402T923
${du_scf_name}    SCF_0.800.xml
${SCF_20M}     SCF_20MHz_DU.xml
${SCF_15MHz_DU.xml}    SCF_15MHz_DU.xml
${SCF_5MHz_DU.xml}    SCF_5MHz_DU.xml
${SCF_5MHz_DU_40ms.xml}     SCF_5MHz_DU_40ms.xml
${provider_create}   ${docker_cmd} cp provider ${asik_addr}:20401\'
${docker_cmd}        docker exec -it FlowTracer /bin/bash -c \'./fcmd ${trace_host}:50001
${trace_host}    ${tl.host[0].default_ssh_connection_details.addr}
${swconfig_path}    ${commissionings_path}/HGZ/7_5_UTE5G402T923/swconfig.txt

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
    csn.execute    command=uboot_env set netboot=netboot_first    connection=GNB_OAM
    [Teardown]    csn.Disconnect    connection=GNB_OAM

Suite setup
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=COAM

Suite teardown
    admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error    COAM WEBUI Logout    display=${true}

Conect to DU COAM
    [Arguments]    ${connection}=COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}


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

Reboot UE for NSA
    _Prepare Variables    ue_index=${0}
     csn.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=cpc_${0}
    _Reboot_UE    connection=cpc_${0}
    csn.disconnect      connection=cpc_${0}


Check X2 Status
    [Arguments]    ${connection}=COAM
    sleep    60s
    coam.connect_to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    bts_port=${443}    username=Nemuadmin    password=nemuuser
    ...   name=${connection}
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LTEENB_A    connection=${connection}
    @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LTEENB_R    connection=${connection}
    &{dict_x2LinkLock}     coam.get_parameters    dist_name=${MOs_lteenb_a[0]['distName']}  pattern=x2LinkLock    connection=${connection}
    &{dict_x2LinkStatus}    coam.get_parameters    dist_name=${MOs_lteenb_r[0]['distName']}  pattern=x2LinkStatus    connection=${connection}
    should be equal as strings    ${dict_x2LinkLock['x2LinkLock']}    unlocked    msg=x2LinkLock is not in unlocked status    ignore_case=${True}
    should be equal as strings    ${dict_x2LinkStatus['x2LinkStatus']}    available    msg=x2LinkStatus is not in available status
    ...                            ignore_case=${True}

change prachConfigurationIndex and check for 20ms
    log to console    change prachConfigurationIndex to 41 and check
    Set parameter    key=prachConfigurationIndex    value=${41}
    Reboot UE for NSA
    L3 call setup second     UE_TYPE=askey
    #Check PM counters
    log to console    change prachConfigurationIndex to 42 and check
    Set parameter    key=prachConfigurationIndex    value=${42}
    Reboot UE for NSA
    L3 call setup second    UE_TYPE=askey
    #Check PM counters

change prachConfigurationIndex and check for 40ms
    log to console    change prachConfigurationIndex to 37 and check
    Set parameter    key=prachConfigurationIndex    value=${37}
    Reboot UE for NSA
    L3 call setup second     UE_TYPE=askey
    #Check PM counters
    log to console    change prachConfigurationIndex to 38 and check
    Set parameter    key=prachConfigurationIndex    value=${38}
    Reboot UE for NSA
    L3 call setup second    UE_TYPE=askey
    #Check PM counters


L3 call setup for NSA
    [Arguments]    ${UE_TYPE}=askey
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup for PCMD
    [Arguments]    ${UE_TYPE}=askey
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    \n ###UE Start traffic and check TP ###
    #Get Askey UE Ipef Port    ue_index=${0}
    power_ue.Start traffic   ue_type=${UE_TYPE}    direction=ul   throughput=70M    duration=600    iperf_type=via_command
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=200M    duration=600    iperf_type=via_command

L3 call setup
    [Arguments]    ${UE_TYPE}=askey
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=True
#    Log To Console    \n ###UE Start traffic and check TP ###
#    Get Askey UE Ipef Port    ue_index=${0}
#    power_ue.Start traffic   ue_type=${UE_TYPE}    direction=ul   throughput=5M    duration=600    iperf_port=${None}
#    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=5M    duration=600
#    power_ue.Check throughput    ue_index=${0}    direction=dl    ue_type=askey    throughput=${0}
#    power_ue.Check throughput    ue_index=${0}    direction=ul    ue_type=askey    throughput=${0}
#    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
#    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup second
    [Arguments]    ${UE_TYPE}=askey
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
#    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
#    Log To Console    \n ###UE Start traffic and check TP ###
#    Get ASkey UE Ipef Port    ue_index=${0}
#    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=5M    duration=600    iperf_port=${None}
#    traffic_via_iperf.Start DL traffic via iperf on Appserver    ue_addr=${ue_ip}
#    ...                                                          dl_time=600
#    ...                                                          dl_port=${DL_PORT}
#    ...                                                          dl_throughput=10M
#    ...                                                          dl_length=1400
#    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=5M    duration=600
#    ${all_tp}    Get ul and dl peak and ave throughput and return result
#    Run keyword and continue on failure    should be true    ${all_tp[1]}>${dltp}
#    Run keyword and continue on failure    should be true    ${all_tp[4]}>${ultp}
#    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
#    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
#    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Site reset
    wait until keyword succeeds   1min   2s    COAM Reset Site
    Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair


COAM Check All NR Cells Onair
    [Arguments]   ${connection}=COAM
    log to console     Check NR cells onair
    #Conect to DU COAM
    ${cell_list}   COAM Get Cell List   connection=${connection}
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        ${output}    convert to string    ${status}
        Run Keywords
        ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
        ...      should not contain    ${output.lower()}    degraded    AND
        ...      Should Be Equal   ${status['operationalState']}   enabled
    END

Check PM counters
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    ${reportingIntervalPm}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    run keyword if    "${reportingIntervalPm}" != "5min"     Set reportingIntervalPm to 5min
    ...    ELSE    log   Already 5min!
    ${reportingIntervalPm_1}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    sleep    ${reportingIntervalPm_1}
    log to console    sleep
    ${RELEASE}=   Get program version
    #${sb1_dlcounter}    run keyword if    '${RELEASE}'=='24R3'    Get the Counter value from COAM    counter_id=M55306C06001
    #...    dic_path=${counter_path1}    min_len=${0}
    #...    ELSE    Get the Counter value from COAM    counter_id=M55306C06001
    #...    dic_path=${counter_path2}    min_len=${0}
    ${sb1_dlcounter} =    Get the Counter value from COAM    counter_id=M55306C06001
    ...    dic_path=${counter_path1}    min_len=${0}
    log to console    ${sb1_dlcounter}
    should be true    ${sb1_dlcounter} > 0

Get the Counter value from COAM
    [Arguments]    ${counter_id}    ${dic_path}=full    ${date}=all    ${min_len}=1
    log to console    ${counter_id}    ${dic_path}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${dic_path}    date=${date}
    ${len}    get length  ${counter_value}
    should be true  ${len} > ${min_len}
    [Return]    ${counter_value[0]}

Set reportingIntervalPm to 5min
    COAM Update Parameter    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1    parameter=reportingIntervalPm    value=5min
    sleep    5s

Check GNB cell on air
    [Documentation]  Author: Ding Binmei
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

Set parameter
    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-10042/NRBTS-10042/NRCELL-1
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    120s

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

set gscn parameter
    [Documentation]    22R1 the gscn parameter is modified to gscnOrSsPbchArfcn
    ${RELEASE}=   Get program version
    run keyword if  '${RELEASE}'=='21B'  Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=gscn    value=1949
    ...    ELSE  Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=gscnOrSsPbchArfcn    value=1949

set bandwidth
    [Arguments]    ${value}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=${value}   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=${value}    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}

    ${cellBwpList0_5}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-9    cellBwpId=0
    ${cellBwpList1_5}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-30    cellBwpId=1
    @{cellBwpList_params_5}    create list    ${cellBwpList0_5}    ${cellBwpList1_5}

    ${cellBwpList0_10}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_10}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-31    cellBwpId=1
    @{cellBwpList_params_10}    create list    ${cellBwpList0_10}    ${cellBwpList1_10}

    ${cellBwpList0_15}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_15}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-32    cellBwpId=1
    @{cellBwpList_params_15}    create list    ${cellBwpList0_15}    ${cellBwpList1_15}

    ${cellBwpList0_20}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_20}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-33    cellBwpId=1
    @{cellBwpList_params_20}    create list    ${cellBwpList0_20}    ${cellBwpList1_20}

    run keyword if    '${value}'=='5MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    key=nrarfcnUl    value=145100    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    key=nrarfcnDl    value=156100    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=0    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_5}    AND
    ...    set gscn parameter

    run keyword if    '${value}'=='10MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    key=nrarfcnUl    value=145100    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    key=nrarfcnDl    value=156100    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=6    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_10}    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=6    AND
    ...    set gscn parameter

    run keyword if    '${value}'=='15MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    key=nrarfcnUl    value=145100    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    key=nrarfcnDl    value=156100    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=7    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_15}    AND
    ...    set gscn parameter

    run keyword if    '${value}'=='20MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    key=nrarfcnUl    value=145100    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    key=nrarfcnDl    value=156100    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=7    AND
    ...    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_20}    AND
    ...    set gscn parameter

    sleep    3s

    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

set bandwidth with 5MHz
    ${cellBwpList0_5}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-9    cellBwpId=0
    ${cellBwpList1_5}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-30    cellBwpId=1
    @{cellBwpList_params_5}    create list    ${cellBwpList0_5}    ${cellBwpList1_5}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=5MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=5MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=0
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_5}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

set bandwidth with 5MHz for 23R4
    ${cellBwpList0_5}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-9    actPdcchCceFragmentControl=false
    ...    pdcchResourcePreference=peakRate    cellBwpId=0
    ${cellBwpList1_5}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-30    actPdcchCceFragmentControl=false
    ...    pdcchResourcePreference=peakRate    cellBwpId=1
    @{cellBwpList_params_5}    create list    ${cellBwpList0_5}    ${cellBwpList1_5}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=5MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=5MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=0
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_5}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

set bandwidth with 5MHz for Trunk
    ${cellBwpList0_5}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-9    actPdcchCceFragmentControl=false
    ...    actUpperThrAckNackFiltering=false    actUpperThrAckNackHrFiltering==false    pdcchResourcePreference=peakRate    cellBwpId=0
    ${cellBwpList1_5}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-30    actPdcchCceFragmentControl=false
    ...    actUpperThrAckNackFiltering=false    actUpperThrAckNackHrFiltering==false    pdcchResourcePreference=peakRate    cellBwpId=1
    @{cellBwpList_params_5}    create list    ${cellBwpList0_5}    ${cellBwpList1_5}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=5MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=5MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=0
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_5}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

set bandwidth with 10MHz
    ${cellBwpList0_10}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_10}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-32    cellBwpId=1
    @{cellBwpList_params_10}    create list    ${cellBwpList0_10}    ${cellBwpList1_10}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=10MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=10MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=6
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_10}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair


set bandwidth with 10MHz for 23R4
    ${cellBwpList0_10}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    actPdcchCceFragmentControl=false
    ...    pdcchResourcePreference=peakRate    cellBwpId=0
    ${cellBwpList1_10}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-32    actPdcchCceFragmentControl=false
    ...    pdcchResourcePreference=peakRate    cellBwpId=1
    @{cellBwpList_params_10}    create list    ${cellBwpList0_10}    ${cellBwpList1_10}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=10MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=10MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=6
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_10}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

set bandwidth with 15MHz
    ${cellBwpList0_15}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_15}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-32    cellBwpId=1
    @{cellBwpList_params_15}    create list    ${cellBwpList0_15}    ${cellBwpList1_15}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=15MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=15MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=7
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_15}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

set bandwidth with 15MHz for 23R4
    ${cellBwpList0_15}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    actPdcchCceFragmentControl=false
    ...    pdcchResourcePreference=peakRate    cellBwpId=0
    ${cellBwpList1_15}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-32    actPdcchCceFragmentControl=false
    ...    pdcchResourcePreference=peakRate    cellBwpId=1
    @{cellBwpList_params_15}    create list    ${cellBwpList0_15}    ${cellBwpList1_15}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=15MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=15MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=7
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_15}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

set bandwidth with 15MHz for Trunk
    ${cellBwpList0_15}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    actPdcchCceFragmentControl=false
    ...    actUpperThrAckNackFiltering=false    actUpperThrAckNackHrFiltering==false    pdcchResourcePreference=peakRate    cellBwpId=0
    ${cellBwpList1_15}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-32    actPdcchCceFragmentControl=false
    ...    actUpperThrAckNackFiltering=false    actUpperThrAckNackHrFiltering==false    pdcchResourcePreference=peakRate    cellBwpId=1
    @{cellBwpList_params_15}    create list    ${cellBwpList0_15}    ${cellBwpList1_15}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=15MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=15MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=7
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_15}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

set bandwidth with 20MHz
    ${cellBwpList0_20}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_20}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-33    cellBwpId=1
    @{cellBwpList_params_20}    create list    ${cellBwpList0_20}    ${cellBwpList1_20}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=20MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=20MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=7
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_20}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair


set bandwidth with 20MHz for 23R4
    ${cellBwpList0_20}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    actPdcchCceFragmentControl=false
    ...    pdcchResourcePreference=peakRate    cellBwpId=0
    ${cellBwpList1_20}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-33    actPdcchCceFragmentControl=false
    ...    pdcchResourcePreference=peakRate    cellBwpId=1
    @{cellBwpList_params_20}    create list    ${cellBwpList0_20}    ${cellBwpList1_20}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=20MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=20MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=7
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_20}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

set bandwidth with 20MHz for Trunk
    ${cellBwpList0_20}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-4    actPdcchCceFragmentControl=false
    ...    actUpperThrAckNackFiltering=false    actUpperThrAckNackHrFiltering==false    pdcchResourcePreference=peakRate    cellBwpId=0
    ${cellBwpList1_20}    Create Dictionary    bwpDN=MRBTS-10042/NRBTS-10042/BWP_PROFILE-33    actPdcchCceFragmentControl=false
    ...    actUpperThrAckNackFiltering=false    actUpperThrAckNackHrFiltering==false    pdcchResourcePreference=peakRate    cellBwpId=1
    @{cellBwpList_params_20}    create list    ${cellBwpList0_20}    ${cellBwpList1_20}
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=20MHz   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=20MHz    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=type0CoresetConfigurationIndex    value=7
    Set parameter    dict_name=MRBTS-10042/NRBTS-10042/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_20}
    set gscn parameter
    sleep    3s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10042/NRBTS-10042/NRCELL-1/NRCELL_FDD-1    parameter=${bandwidth}
    ...    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

Get the exact emil log and convert to txt
    [Arguments]    ${DCAP_log_path}    ${txt_log_name}    ${profile_file}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    csn.Execute   command=find ${TS_CASE_LOG_PATH} -type f -not -name '*.zip' -delete    connection=ute
    #csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp/    connection=ute
    csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp/    connection=ute
    csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp/ | grep .5gm > ${TS_CASE_LOG_PATH}dcap_log_name.txt
    ...    connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt
    ...    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}
        ...    connection=ute
        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
        ${emil_log}    convert to txt    @{emil_dcap_log}    profile_file=${profile_file}
        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}${txt_log_name}    connection=ute
        sleep    60s
    END
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap*    connection=ute
    [Teardown]    csn.Disconnect     connection=ute

Stop traffic and UE detach
    [Arguments]    ${UE_TYPE}=askey
    Log To Console    \n ###UE Stop traffic and check TP ###
    #Get Askey UE Ipef Port    ue_index=${0}
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Input PCMD search value
    [Arguments]    ${offset}    ${length}    ${all_length}
    ${length}=    Evaluate    ${length}+${offset}
    ${all_length}    Convert To Integer    ${all_length}
    ${all_length}    get_pcmd_line_nu    ${all_length}
    ${all_length}    Convert To Integer    ${all_length}
    ${all_length}=    Evaluate    ${all_length}+1
    [Return]    ${offset}    ${length}    ${all_length}

Check PCMD Event
    [Arguments]    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    csn.Execute   command=awk '/${pcmd_event_name}/{print NR}' ${pcmd_log_path}/${txt_log_name} > ${pcmd_log_path}/pcmd_line_nu.txt
    ...    connection=ute
    csn.Execute   command=wc -l ${pcmd_log_path}/pcmd_line_nu.txt >> ${pcmd_log_path}/pcmd_line_nu.txt    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${pcmd_log_path}/pcmd_line_nu.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    Log To Console    \n ### There are ${range} of ${pcmd_event_name} PCMD Event ###
    ${Turerange}=    Evaluate    ${range}+2
    ${Failrange}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${Turerange}
        should be True    ${i}!=${Failrange}
        Log To Console    \n ### NO.${i} of ${pcmd_event_name} is being checked ###
        ${flag}    run keyword and return status
        ...    Get PCMD dec data    i=${i}    offset=${offset}    length=${length}    all_length=${all_length}
        ...    conditions=${conditions}
        exit for loop if    ${flag}==True
    END
    csn.Execute   command=rm -rf ${pcmd_log_path}/pcmd*    connection=ute

Get PCMD dec data
    [Arguments]    ${offset}    ${length}    ${all_length}    ${conditions}    ${i}=1
    csn.Execute   command=chmod 777 ${CURDIR}/pcmd.sh    connection=ute
    csn.Execute   command=${CURDIR}/pcmd.sh '${pcmd_log_path}' ${all_length} ${i}    connection=ute
    ${pcmd_list}    get_pcmd_list    ${pcmd_log_path}/pcmd
    ${pcmd_data}    Get Slice From List    ${pcmd_list}    ${offset}    ${length}
    Reverse List    ${pcmd_data}
    ${pcmd_hex}    get_pcmd_str_hex    ${pcmd_data}
    ${pcmd_dec}    hex_to_dec    ${pcmd_hex}
    Log To Console    \n ${pcmd_dec}
    Run Keyword If    ${conditions}==0    should be true    ${pcmd_dec}>0
    Run Keyword If    ${conditions}==1    should be true    ${pcmd_dec}>=0

convert to txt
    [Arguments]    @{emil_dcap_log}    ${profile_file}
    log to console    \n Upload emil script
    Csn.Connect to   hostname=${EMIL_HOST}    username=${EMIL_USER}    password=${EMIL_PASSWORD}
    ...    alias=Emil_decode
    csn.Upload File   local_path=${CURDIR}/${profile_file}   remote_path=${profile_path}\\SourceProfileUser.ini
    ...    connection=Emil_decode
    log to console    \n convert to txt
    ${emil_log}=    Covert Emil Logs to TXT    file_list=${emil_dcap_log}   local_dir=${TS_CASE_LOG_PATH}
    ...    emil_host=${EMIL_HOST}    emil_user=${EMIL_USER}    emil_password=${EMIL_PASSWORD}
    ...    emil_protocol=${profiles}
    [Return]    ${emil_log}
    [Teardown]    csn.Disconnect    connection=Emil_decode

teardown
    log to console    \n in teardown stage
    Run Keyword And Ignore Error     admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error     power_ue.UE Detach    ue_index=${0}    ue_type=inseego
    CI_interface.Common Case Teardown

