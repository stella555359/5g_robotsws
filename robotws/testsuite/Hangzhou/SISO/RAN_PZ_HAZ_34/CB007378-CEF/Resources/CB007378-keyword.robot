*** Settings ***
Documentation     author: shanxu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shangyu.xu@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
#Library    taf.selenium.gnb.oam.coam.classical        WITH NAME    selenium_coam
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py


*** Variables ***
${dltp}    10
${ultp}    5
${counter_path}    BTS/CELLS/NRCELL-2/NRACH/RA_MSG3_RECEP    #BTS/CELLS/NRCELL-2/NRACH
${SCF_TEMPLATE_PATH}    ${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G402T920
${du_scf_name}    SCF_0.800.xml

*** Keywords ***
Precondition
    [Arguments]    ${ChBw_except}
    log to console    \n in precondition stage
    Check GNB cell on air
    ${ChBw}    Get NIDD parameter value    class_name=NRCELL_A    pattern=chBw    connection=COAM
    run keyword if    '${ChBw}' != '${ChBw_except}'
    ...    set bandwidth    value=${ChBw_except}

    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

Suite Teardown with SCF
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='24R3'    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    ...   ELSE IF    '${RELEASE}'=='24R1'     Scf commission and wait on-air    scf_name=SCF_SBTS24R1.xml

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

Check GNB cell on air
    [Documentation]
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

set bandwidth
    [Arguments]    ${value}
    ${cellBwpList0}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-5    cellBwpId=0
    ${cellBwpList1}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-50    cellBwpId=1
    @{cellBwpList_params}    create list    ${cellBwpList0}    ${cellBwpList1}

    run keyword if    '${value}'=='20MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-1    key=cellBwpList    value=${cellBwpList_params}    AND
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=cellBwpList    value=${cellBwpList_params}    AND
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-3    key=cellBwpList    value=${cellBwpList_params}
    log to console    Open WEBEM
    selenium_coam.enable_virtual_display

    selenium_coam.login    url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
    ...    username=Nemuadmin    password=nemuuser    version=SBTS22R3

    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-1
    ...    filter_param=Channel bandwidth    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Channel bandwidth    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-3
    ...    filter_param=Channel bandwidth    new_value=${value}

    run keyword if    '${value}'!='20MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=12
    run keyword if    '${value}'=='20MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=0
    run keyword if    '${value}'!='20MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=12
    run keyword if    '${value}'=='20MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=0
    run keyword if    '${value}'!='20MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=12
    run keyword if    '${value}'=='20MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=0

    log to console    Active parameter
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}

    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair
    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    OperatingSystem.Run    ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -

Set parameter
    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-1
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

#L3 call setup for NSA
#    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
#    log to console    L3 call setup and check
#    Log To Console    \n ### Prepare UE ###
#    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
#    Log To Console    \n ### UE Attach ###
#    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
#    Log To Console    \n ### verify UE Attach ###
#    #power_ue.Verify attach    ue_type=${UE_TYPE}    4G_check=True   5Grach_ed=${5Grach_ed_0}
#    Log To Console    \n ### UE Detach ###
#    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 Call And Check Throughput
    [Arguments]  ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=100M    ${duration}=${30}
    ...    ${dl_exp}=60    ${ul_exp}=20    ${actual_rate}=0.1
    ${ue_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    Teardown the Aasyslog save progress
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=${4G_check}
    ${traffic_duration}  evaluate  ${duration}*10+100
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${traffic_duration}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${traffic_duration}
#    ${dl_status}  ${output}  run keyword and ignore error  power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#    ...    throughput=${dl_exp}    sample=${duration}    start_offset=${duration}
#    ${ul_status}  ${output}  run keyword and ignore error  power_ue.Check throughput    ue_type=${ue_type}    direction=ul
#    ...    throughput=${ul_exp}    sample=${duration}    start_offset=${duration}
    Verify tput from GNB within duration and record data to csv    total_time=60    exp_dl_tput=${dl_exp}
    ...    exp_ul_tput=${ul_exp}    interval=10    duration_time_for_once=200s    nr_cell_index=${2}
    ...    tput_percentage=${actual_rate}    is_need_to_capture_log=${False}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
#    run keyword if  '${dl_status}'=='FAIL' or '${ul_status}'=='FAIL'  FAIL  throughput are less than expect
    [Teardown]  run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    run keyword and ignore error   power_ue.UE Detach  ue_type=${ue_type}

