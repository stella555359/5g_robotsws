*** Settings ***
Resource    ./Resource/CNI132544_A_common_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_5G_A_common_keyword.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008140/Resources/CB008140_common_keywords_multiUE.robot
Variables    ./Resource/CNI132544_A_variables.py
Library    DateTime
Library    ./Resource/CNI132544_A_common_keywords.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/upgrade_rollback_keywords.robot

Documentation
...   author: qingqing zhang
...   contact: qingqing.zhang@nokia-sbell.com
...   squad group: SG_03

Suite Setup    Run keywords    Common Suite Setup for COAM
...    AND    Case Setup

Suite Teardown    Common Suite Teardown for COAM

*** Variables ***
#${golden_scf_name_357}    Configuration_scf_132544_TL357
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
@{allow_fault_list}    62003    7311    7307    7107    8000     7331    4291
@{ue_index_MTU_all}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
@{ue_index_MTU_UE1}    ${1}
@{ue_index_MTU_powerall}    ${-1}
${APN}    wustatic
${dl_throughput_AVHA}    2500M
${dl_expect_tput_AVHA}    1000
@{CEll_list_3RU}    311    312    313    301    302    303
@{RU_list_3RU}    1    2    3
@{CEll_list_1RU}    700    701
@{RU_list_1RU}    9
${RMOD_index}    9
${ue_type_QPM}      ${tl.ues[1].capabilities[0]}
${traffic_dl_port}    ${tl.ues[1].iperf_details.port}
@{enb_id}    34821    38321
${enb_instance}     ${tl.enbs[0].instance_id}

*** Test Cases ***
[1]CNI132544_15_SiSo_Exploratory
    [Documentation]
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    5 hours
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,49,4291
    Wait Until Keyword Succeeds    10min    10s    reset needed RMOD action    RMOD_index=${RMOD_index}
    Wait until keyword succeeds    20 min    20s    Check the cells status on air
    Action Enter EDSM by lock cell
    Wait Until Keyword Succeeds    10min    10s    Get RU DSM/EDSM    status=SLEEP_EXTREME    RU_index=${RMOD_index}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Modify Parameters for Cases and not check RU status    Modify_Para_Online=${Modify_Para_Online_132544_15_1}
    Wait Until Keyword Succeeds    5min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    Wait Until Keyword Succeeds    10min    10s    reset needed RMOD action    RMOD_index=${RMOD_index}
    Wait until keyword succeeds    20 min    20s    Check the cells status on air
    Action Enter EDSM by block cell
    Wait Until Keyword Succeeds    130min    10s    Get RU DSM/EDSM    status=SLEEP_EXTREME    RU_index=${RMOD_index}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Modify Parameters for Cases and not check RU status    Modify_Para_Online=${Modify_Para_Online_132544_15_2}
    Wait Until Keyword Succeeds    5min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    [Teardown]    Run keywords
    ...    Case 15 Recovery    AND
    ...    Common Case Teardown for COAM

[1]CNI132544_06_RU_returnin_ from_PowerSaving_Mode_to_normal_operation_due_to_change_of_EnergySavingMode
    [Documentation]
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    5 hours
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,49,10,4291
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Log to console    \n*** Enter to RU1 enter to EDSM ***
    Trigger RU enter to EDSM    duration=240
    Log to console    \n*** Modify parameter trigger RU1 autoreset and status change to AWAKE ***
    Modify Parameters for Cases and not check RU status    Modify_Para_Online=${Modify_Para_Online_132544_06}
    Wait Until Keyword Succeeds    10min    10s    reset needed RMOD action    RMOD_index=${RMOD_index}    need_reset=false
    Wait Until Keyword Succeeds    10min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    Log to console    \n*** Reset RU1 for the next enter to EDSM time restore to 5min***
    reset needed RMOD action    RMOD_index=${RMOD_index}
    Wait Until Keyword Succeeds    15min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    Log to console    \n*** Modify parameter to DEEPSLEEP_EXTREME_SFP***
    Modify Parameters for Cases and not check RU status    Modify_Para_Online=${Modify_Para_Online_132544_06_1}
    Wait Until Keyword Succeeds    130min    10s    Get RU DSM/EDSM    status=SLEEP_EXTREME    RU_index=${RMOD_index}
    Log to console    \n*** Reset site and  RU1/RU2/RU3 status change to AWAKE ***
    COAM gNB Reset site via api
    Wait Until Keyword Succeeds    5min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    [Teardown]    Run keywords
    ...    EDSM Recovery
    ...    AND    Common Case Teardown for COAM

[1]CNI132544_17_SWMGMNT_interworking_with_rollback
    [Documentation]
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    10 hours
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,49,10,4589,4291
    ${initial_active_version}=    get active version to check    gnb_index=${0}
    Set Test Variable    ${initial_active_version}
    Log to console    \n*** Enter to RU1/RU2/RU3 enter to EDSM ***
    Adjust the HBTE attenuation value
    Power_ue.Prepare UE    ue_type=${ue_type_QPM}    ue_index=${1}
    power_ue.UE Detach    ue_type=${ue_type_QPM}    ue_index=${1}
    Trigger RU enter to EDSM    duration=1440
    Log to console    \n*** Lock cell 311 and trigger RU1/RU2/RU3 autoreset and status change to AWAKE ***
    Modify Parameters for Cases and not check RU status    Modify_Para_Online=${Modify_Para_Online_132544_17}
    Wait Until Keyword Succeeds    10min    10s    reset needed RMOD action    RMOD_index=${RMOD_index}    need_reset=false
    Wait Until Keyword Succeeds    10min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    Log to console    \n*** Reset RU1 for the next enter to EDSM time restore to 5min***
    reset needed RMOD action    RMOD_index=${RMOD_index}
    Wait Until Keyword Succeeds    15min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    FOR    ${index}    IN RANGE    ${1}
        Attach and start tput and check EDSM
    END
    Attach and check power UE    ue_type=${ue_type_QPM}    ue_index=${1}    gnb_index=${0}
    Power UE Start DL traffic    ue_index=${1}    ue_type=${ue_type_QPM}    dl_throughput=${dl_throughput_AVHA}
    ...    duration=2400    dl_port=${traffic_dl_port}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=notEnergySaving
    power_ue.Stop traffic    ue_index=${1}    ue_type=${ue_type_QPM}   direction=DL
    Power UE Start DL traffic    ue_index=${1}    ue_type=${ue_type_QPM}    dl_throughput=1M
    ...    duration=2400    dl_port=${traffic_dl_port}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=reducedEnergySaving
    power_ue.Stop traffic    ue_index=${1}    ue_type=${ue_type_QPM}   direction=DL
    power_ue.UE Detach    ue_type=${ue_type_QPM}    ue_index=${1}
    Wait Until Keyword Succeeds    130min    10s    Get RU DSM/EDSM    status=SLEEP_EXTREME    RU_index=${RMOD_index}
    Log to console    \n*** rollback to Passive build ***
    AlarmWatchdog.add_allow_alarms    fault_id=4420
    rollback_build
    sleep    2m
    Wait Until Keyword Succeeds    30min    10s    check build is not euqal
    Wait Until Keyword Succeeds    15min    10s    check gNB Staus Air
    Wait Until Keyword Succeeds    15min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    Wait Until Keyword Succeeds    30m    10s    check firmware upgrade ongoing fid 4420 on CNI132544    gnb_index=${0}
    Sleep    2m
    AlarmWatchdog.remove_allow_alarms    fault_id=4420
    [Teardown]    Run keywords
    ...    Check if need rollback via ssh
    ...    AND    Common Case Teardown for COAM

*** Keywords ***
check build is not euqal
    ${current_active_version}=    get active version to check
    Should Not Be Equal    ${initial_active_version}    ${current_active_version}

Case Setup
    ${sw_version}=    Get sagnb version for selenium
    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
    Common Case TestLine Setup    is_commission=True
    ...    golden_scf_name=${tl_gnb1_scf_${sw_version}}    scf_path=${scf_path}
    Wait until keyword succeeds    20 min    20s    Check the cells status on air
    Online Modify Cell Status    Modify_Para_Online=${Modify_Para_Online_EDSM}
    Wait until keyword succeeds    20 min    20s    Check the cells status on air

Online Modify Cell Status
    [Arguments]    ${Modify_Para_Online}    ${Add_Para_Online}='NULL'    ${Delete_Para_Online}='NULL'
    Modify Parameters for Cases    Modify_Para_Online=${Modify_Para_Online}    skip_parameter_relation_errors=False
    ...    Add_Para_Online=${Add_Para_Online}     Delete_Para_Online=${Delete_Para_Online}
    Wait until keyword succeeds    20 min    20s    Check the cells status on air

Action Enter EDSM by lock cell
    Modify Parameters for Cases    Modify_Para_Online=${Modify_Para_Online_132544_15}
    ...    skip_parameter_relation_errors=False

Action Enter EDSM by block cell
    block unblock needed cell action    cell_type_need=nr    action=block    cell_index=${700}
    block unblock needed cell action    cell_type_need=nr    action=block    cell_index=${701}

Case 15 Recovery
    Modify Parameters for Cases and not check RU status    Modify_Para_Online=${Modify_Para_Online_132544_15_unlock}
    sleep    35s
    block unblock needed cell action    cell_type_need=nr    action=unblock    cell_index=${700}
    block unblock needed cell action    cell_type_need=nr    action=unblock    cell_index=${701}
    Wait Until Keyword Succeeds    5min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    reset needed RMOD action    RMOD_index=${RMOD_index}
    Wait until keyword succeeds    20 min    20s    Check the cells status on air

EDSM Recovery
    [Arguments]
#    ...    ${ADD_Para_Online_AVHA_DSM_Recovey}=${ADD_Para_Online_AVHA_DSM_Recovey}
    ...    ${paras}=${PARAMETERS_DSM_RECOVER}    ${delta_file_name}=${epc_log_path}${PARAMETERS_DSM_RECOVER_JSON_FILE}
#    Online Modify Cell Status    Modify_Para_Online=${Modify_Para_Online_Recovey}
#    ...    Add_Para_Online=${ADD_Para_Online_AVHA_DSM_Recovey}    Delete_Para_Online=${PARAMETERS_TO_DELETE_NRPGRP}
    paras change on BTS    paras=${paras}    delta_file_name=${delta_file_name}
    Wait until keyword succeeds    10 min    20s    Check the cells status on air
    Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
#    reset needed RMOD action    RMOD_index=${RMOD_index}
#    Wait until keyword succeeds    20 min    20s    Check the cells status on air


Trigger RU enter to EDSM
    [Arguments]
#    ...    ${ADD_Para_Online_AVHA}=${ADD_Para_Online_AVHA_DSM}
    ...    ${paras}=${PARAMETERS_DSM}    ${delta_file_name}=${epc_log_path}${PARAMETERS_DSM_JSON_FILE}
    ...    ${CEll_list}=${CEll_list_1RU}    ${RU_list}=${RU_list_1RU}    ${duration}=140
    reset needed RMOD action    RMOD_index=${RMOD_index}
#    Online Modify Cell Status    Modify_Para_Online=${Modify_Para_Online_AVHA_DSM}
#    ...    Add_Para_Online=${ADD_Para_Online_AVHA}    Delete_Para_Online=${PARAMETERS_TO_DELETE_NRPGRP}
    paras change on BTS    paras=${paras}    delta_file_name=${delta_file_name}
    Wait until keyword succeeds    10 min    20s    Check the cells status on air
    ${current_time}=    Get Current Date    result_format=%H:%M:%S
    ${Modify_Para_Online_AVHA_DSM_Modified}    Auto_Modify_DSM_Value    duration=${duration}
    Online Modify Cell Status    Modify_Para_Online=${Modify_Para_Online_AVHA_DSM_Modified}
    Check Cell RU enter to DSM/EDSM    RU_status=SLEEP_EXTREME    CEll_list=${CEll_list}    RU_list=${RU_list}

Trigger RU enter to SLEEP_EXTREME
    [Arguments]
    ...    ${paras}=${PARAMETERS_DSM}    ${delta_file_name}=${epc_log_path}${PARAMETERS_DSM_JSON_FILE}
    ...    ${CEll_list}=${CEll_list_1RU}    ${RU_list}=${RU_list_1RU}    ${duration}=140
    paras change on BTS    paras=${paras}    delta_file_name=${delta_file_name}
    Wait until keyword succeeds    10 min    20s    Check the cells status on air
    ${current_time}=    Get Current Date    result_format=%H:%M:%S
    ${Modify_Para_Online_AVHA_DSM_Modified}    Auto_Modify_DSM_Value    duration=${duration}
    Online Modify Cell Status    Modify_Para_Online=${Modify_Para_Online_AVHA_DSM_Modified}
    Check Cell RU enter to DSM/EDSM    RU_status=SLEEP_EXTREME    CEll_list=${CEll_list}    RU_list=${RU_list}

Check Cell RU enter to DSM/EDSM
    [Arguments]    ${RU_status}=SLEEP_EXTREME    ${RU_list}=${RU_list_1RU}
    ...    ${CEll_list}=${CEll_list_3RU}
#    FOR    ${cell_index}    IN    @{CEll_list}
#        Wait until keyword succeeds    30 min    20s    Get Cell EnergySavingState    cell_index=${cell_index}
#    END
    FOR    ${cell_index}    IN    @{CEll_list}
        Wait until keyword succeeds    20 min    20s    Get Cell EnergySavingState    status=energySaving    cell_index=${cell_index}
    END
    FOR    ${cell_index}    IN    @{CEll_list}
        Wait until keyword succeeds    10 min    20s    Get require Cell status    status=off line    cell_index=${cell_index}
    END
    FOR    ${RU_index}    IN    @{RU_list}
        Wait until keyword succeeds    130 min    20s    Get RU DSM/EDSM    RU_index=${RU_index}    status=${RU_status}
    END

MutlUE attach and check tput
    [Arguments]    ${dl_throughput}=${dl_throughput_FDD}    ${APN}=${APN}
    ...    ${ue_index}=${3}
    Attach and check IP OK    ue_index=${ue_index}    APN=${APN}
    MultiUE.Start DL Traffic    throughput_for_DL=${dl_throughput}    ue_index=${ue_index}    duration=2400    APN=${APN}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    MultiUE.Stop DL Traffic    ue_index=${ue_index}    APN=${APN}
    ...    AND    Run Keyword And Ignore Error    MultiUE.Detach    ue_index=${ue_index}

Get EnergySavingState
    [Arguments]    ${required_info}=energySavingState    ${status}=reducedEnergySaving    ${cell_index}=${700}
    ${get_status}    get required cell info    required_info=${required_info}    cell_index=${cell_index}
    should be equal    ${get_status}    ${status}

Attach and start tput and check EDSM
    Log to console    \n*** attach cell 700 and check cell700 is notEnergySaving ***
    Attach and check power UE    ue_type=${ue_type_QPM}    ue_index=${1}    gnb_index=${0}
    Power UE Start DL traffic    ue_index=${1}    ue_type=${ue_type_QPM}    dl_throughput=${dl_throughput_AVHA}
    ...    duration=2400    dl_port=${traffic_dl_port}
    Wait until keyword succeeds    5 min    5s    Get EnergySavingState    status=notEnergySaving
    power_ue.Stop traffic    ue_index=${1}    ue_type=${ue_type_QPM}   direction=DL
    Power UE Start DL traffic    ue_index=${1}    ue_type=${ue_type_QPM}    dl_throughput=1M
    ...    duration=2400    dl_port=${traffic_dl_port}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=reducedEnergySaving
    power_ue.Stop traffic    ue_index=${1}    ue_type=${ue_type_QPM}   direction=DL
    power_ue.UE Detach    ue_type=${ue_type_QPM}    ue_index=${1}
#    Wait Until Keyword Succeeds    25min    10s    Get RU DSM/EDSM    status=SLEEP_EXTREME    RU_index=${RMOD_index}
    Wait Until Keyword Succeeds    130min    10s    Get RU DSM/EDSM    status=SLEEP_EXTREME    RU_index=${RMOD_index}
    Modify Parameters for Cases and not check RU status    Modify_Para_Online=${Modify_Para_Online_132544_17_1}
    Wait Until Keyword Succeeds    10min    10s    reset needed RMOD action    RMOD_index=${RMOD_index}    need_reset=false
    Wait Until Keyword Succeeds    10min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}
    Modify Parameters for Cases and not check RU status    Modify_Para_Online=${Modify_Para_Online_132544_17_2}
    reset needed RMOD action    RMOD_index=${RMOD_index}
    Wait Until Keyword Succeeds    15min    10s    Get RU DSM/EDSM    status=AWAKE    RU_index=${RMOD_index}

check firmware upgrade ongoing fid 4420 on CNI132544
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}
    ${faultIds}=    Create List
    FOR    ${alarm}    IN    @{activate_alarms}
        append to list    ${faultIds}    ${alarm}[faultId]
    END
    ${fid_4420_status}=    Run Keyword And Return Status    Should Contain    ${faultIds}    ${4420}
    Should Be Equal    ${fid_4420_status}    ${False}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Check if need rollback via ssh
    ${current_active_version}=    get active version to check
    IF    '${initial_active_version}' != '${current_active_version}'
        rollback_build
        sleep    10m
        Wait Until Keyword Succeeds    15min    10s    check gNB Staus Air
        Wait Until Keyword Succeeds    30m    10s    check firmware upgrade ongoing fid 4420 on CNI132544    gnb_index=${0}
        sleep    2m
        EDSM Recovery
    ELSE
        EDSM Recovery
    END

get active version to check
    [Arguments]
    ...    ${gnb_index}=${0}
    ${active_version}    Get completed release of BTS    bts_index=${gnb_index}
    [Return]    ${active_version}

#get current active version
#    ${current_active_version}=    get active version to check    gnb_index=${0}
#    Set Test Variable    ${current_active_version}

Get completed release of BTS
    [Arguments]
    ...    ${bts_index}=${0}
    ...    ${bts_addr}=${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${bts_username}=${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${bts_password}=${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    Wait Until Keyword Succeeds    15min    1m
    ...    csn.Connect To   hostname=${bts_addr}   username=${bts_username}   password=${bts_password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${Strip_info}     Strip String    ${info}
    ${release}     Split String    string=${Strip_info}    separator=_    max_split=1
    ${build_info}=    Set Variable    ${release}[1][:-4]
    [Return]    ${build_info}
    [Teardown]   csn.Disconnect   connection=release_info
