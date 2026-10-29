*** Settings ***
Documentation
...    author: Kang Xiang
...    contact: kang.xiang@nokia.com
...    squal group: SG03
...    feature: CB013395

Force Tags  tl-7_5_UTE5G402T2470
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get sagnb version for selenium
...                            AND    Common Case TestLine Setup    is_commission=False    scf_path=${tl_scf_dir_path}
...                                   golden_scf_name=SCFC_TRUNK_ABIQ_13395.xml

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot

*** Variables ***
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
@{gnb_list}    ${0}
${Allowed_Faults_Ids_13395}    49,2002

#bts id
${MRBTS_ID}    2470    #${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${NRCELL_ID}   13
${FDD_NR_Cell_disname}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}
${LNBTS_ID}                 11393    #${tl.gnbs[0].global_bts_id_LTE}
${LNCELL_ID_1.4M}    132
${FDD_LTE1.4Cell_disname}    MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LNCELL_ID_1.4M}
${LNCELL_ID_3M}    133
${FDD_LTE3Cell_disname}    MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LNCELL_ID_3M}

${UE_TYPE}    ${tl.ues[1].capabilities[0]}

# TL2470
${4Gcell_1.4M_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${4Gcell_1.4M_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${4Gcell_1.4M_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${4Gcell_1.4M_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}

@{4Gcell_1.4M_ANTS}    ${4Gcell_1.4M_ANT1}    ${4Gcell_1.4M_ANT2}    ${4Gcell_1.4M_ANT3}    ${4Gcell_1.4M_ANT4}
@{4Gcell_1.4M_VALUES}    ${28}    ${28}    ${28}    ${28}

*** Test Cases ***
CB013395_SR_Basic operation for multiRAT FDD NR LTE cell with 1.4M 3M
    [Documentation]
    ...    1. gNB_startup_with_multiRAT_FDD_NR_LTE_cell_with_1.4M_3M
    ...    2. lock/unlock NR cell
    ...    3. lock/unlock LTE_1.4M/LTE_3M cell
    ...    4. reset NR cell
    ...    5. reset LTE_1.4M/LTE_3M cell
    ...    6. L3 call for NR/LTE cells.

    [Tags]    CB013395_SR    CRT_TRUNK
    [Setup]    Prerequisite For Case
    Lock Unlock FDD NR Cell
    Lock Unlock FDD LTE1.4M Cell
    Lock Unlock FDD LTE3M Cell
    Lock FDD NR Cell And FDD LTE3M Cell
    UE Attach To FDD LTE1.4M Cell With Traffic
    Unlock And Lock FDD NR Cell
    Unlock And Lock FDD LTE3M Cell
    Reset FDD NR Cell
    Reset FDD LTE3M Cell
    Reset FDD LTE1.4M Cell
#    Delta Commission For FDD NR Cell
#    Delta Commission For FDD LTE3M Cell
#    Delta Commission For FDD LTE1.4M Cell
    [Teardown]    CB013395 Teardown


*** Keywords ***
Prerequisite For Case
    Robot_common_operations.Common Case Setup    allowed_faults_ids=${Allowed_Faults_Ids_13395}

Check NR cell locked
    [Arguments]  ${cell_id}   ${connection}=coam_admin_lock
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Check cell should be locked    ${cell_id}   connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check NR cell unlocked
    [Arguments]  ${cell_id}   ${connection}=coam_admin_unlock
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Check cell should be unlocked    ${cell_id}   connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check LTE cell locked
    [Arguments]  ${cell_id}   ${connection}=coam_admin_lock
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_info}        coam.Get cell specific info
    ...   cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${LNBTS_ID}/LNCEL_R-${cell_id}   connection=${connection}
    ${cell_status}      Get from dictionary  ${cell_info}  status
    Dictionary should contain item  ${cell_status}  administrativeState  locked
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check LTE cell unlocked
    [Arguments]  ${cell_id}   ${connection}=coam_admin_unlock
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_info}        coam.Get cell specific info
    ...   cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${LNBTS_ID}/LNCEL_R-${cell_id}   connection=${connection}
    ${cell_status}      Get from dictionary  ${cell_info}  status
    Dictionary should contain item  ${cell_status}  administrativeState  unlocked
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock FDD NR Cell
    Operate state of one cell    dist_name=${FDD_NR_Cell_disname}  operation=Lock
    Wait Until Keyword Succeeds   5 min  5 sec    Check NR cell locked    cell_id=${NRCELL_ID}

Unlock FDD NR Cell
    Operate state of one cell    dist_name=${FDD_NR_Cell_disname}  operation=Unlock
    Wait Until Keyword Succeeds   5 min  5 sec   Check NR cell unlocked   cell_id=${NRCELL_ID}

Lock Unlock FDD NR Cell
    log to console    Lock And Unlock FDD NR Cell
    Lock FDD NR Cell
    Unlock FDD NR Cell

Lock FDD LTE1.4M Cell
    Operate state of one cell    dist_name=${FDD_LTE1.4Cell_disname}  operation=Lock
    Wait Until Keyword Succeeds   5 min  5 sec   Check LTE cell locked   cell_id=${LNCELL_ID_1.4M}

Unlock FDD LTE1.4M Cell
    Operate state of one cell    dist_name=${FDD_LTE1.4Cell_disname}  operation=Unlock
    Wait Until Keyword Succeeds   5 min  5 sec    Check LTE cell unlocked    cell_id=${LNCELL_ID_1.4M}

Lock Unlock FDD LTE1.4M Cell
    log to console    Lock And Unlock FDD LTE1.4M Cell
    Lock FDD LTE1.4M Cell
    Unlock FDD LTE1.4M Cell

Lock FDD LTE3M Cell
    Operate state of one cell    dist_name=${FDD_LTE3Cell_disname}  operation=Lock
    Wait Until Keyword Succeeds   5 min  5 sec   Check LTE cell locked   cell_id=${LNCELL_ID_3M}

Unlock FDD LTE3M Cell
    Operate state of one cell    dist_name=${FDD_LTE3Cell_disname}  operation=Unlock
    Wait Until Keyword Succeeds   5 min  5 sec    Check LTE cell unlocked    cell_id=${LNCELL_ID_3M}

Lock Unlock FDD LTE3M Cell
    log to console    Lock And Unlock FDD LTE3M Cell
    Lock FDD LTE3M Cell
    Unlock FDD LTE3M Cell

Lock FDD NR Cell And FDD LTE3M Cell
    Lock FDD NR Cell
    Lock FDD LTE3M Cell

Unlock And Lock FDD NR Cell
    Unlock FDD NR Cell
    Lock FDD NR Cell

Unlock And Lock FDD LTE3M Cell
    Unlock FDD LTE3M Cell
    Lock FDD LTE3M Cell

Reset FDD NR Cell
    Unlock FDD NR Cell
    COAM gNB Reset cell via api    cell_id=${FDD_NR_Cell_disname}
    Wait until keyword succeeds    5 min  5 sec   Check Cell Onair
    ...    cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${NRBTS_ID}/NRCELL_R-${NRCELL_ID}    cell_type=NR

Reset FDD LTE3M Cell
    Unlock FDD LTE3M Cell
    COAM gNB Reset cell via api    cell_id=${FDD_LTE3Cell_disname}
    Wait until keyword succeeds    5 min  5 sec   Check Cell Onair
    ...    cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${LNBTS_ID}/LNCEL_R-${LNCELL_ID_3M}    cell_type=lte

Reset FDD LTE1.4M Cell
    Unlock FDD LTE1.4M Cell
    COAM gNB Reset cell via api    cell_id=${LNCELL_ID_1.4M}
    Wait until keyword succeeds    5 min  5 sec   Check Cell Onair
    ...    cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${LNBTS_ID}/LNCEL_R-${LNCELL_ID_1.4M}    cell_type=lte

COAM gNB Reset cell via api
    [Arguments]   ${cell_id}=${13}    ${gnb_index}=${0}    ${connection}=coam_admin_reset
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    coam.reset_cell    cell_id=${cell_id}    timeout=60    connection=${connection}
    sleep    5s    wait cell resetting
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=coam_admin_reset

Check Cell Onair
    [Arguments]   ${cell_id}=${13}    ${gnb_index}=${0}    ${connection}=coam_admin_check    ${cell_type}=NR
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_info}    coam.get_cell_specific_info    cell_id=${cell_id}    timeout=20    connection=${connection}
    ${administrative_expected}    Set Variable      Unlocked      # NR
    ${administrative_expected}    Set Variable If   '${cell_type}'=='lte'    unlocked    ${administrative_expected}
    Should Be Equal As Strings    ${cell_info['status']['administrativeState']}    ${administrative_expected}
    Should Be Equal As Strings    ${cell_info['status']['operationalState']}    enabled
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=coam_admin_check

UE Attach To FDD LTE1.4M Cell With Traffic
    log to console    set attenuation for 1.4M LTE cell
    log to console    ${att_ipaddr}
    Set the attenuation value of ports simultaneously
    ...    att_ports=${4Gcell_1.4M_ANTS}    values=${4Gcell_1.4M_VALUES}    att_ipaddr=${att_ipaddr}
    log to console    ue attach to FDD 1.4M cell
#    Start capture gNB log on master    filename=LTE1.4M_L3call.pcap
    Prepare and attach UE For LTE Cell    ue_id=1    attach_mode=4G    apn=dxdata1

Prepare and attach UE For LTE Cell
    [Documentation]    this keyword includes prepare ue and attach ue. For single UE, suggest to use this keyword.
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${get_spark_license}=${true}    ${apn}=mdrb.nokia.com
    Prepare UEs For LTE Cell   ue_ids=1,2    get_spark_license=${get_spark_license}
    Attach UE For LTE Cell    ${ue_id}    ${attach_mode}     ${apn}

Prepare UEs For LTE Cell
    [Documentation]    After prepare UEs, all UEs will be in detach state.
    ...    For mutiple UEs, suggest to use this keyword at first, and then attach UEs. Otherwise
    ...        1) maybe some of UEs are attached unexpected,
    ...        2) spark GUI log will be cleared after power_ue.Prepare UE
    ...    Note: cell signal must be opened before this keyword, otherwise at command will have no repsonse
    [Arguments]    ${ue_ids}=1,2    ${get_spark_license}=${true}
#    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
    @{ues}    Split String    ${ue_ids}    ,
    FOR    ${ue_id}    IN    @{ues}
        wait until keyword succeeds    6x    10s
        ...    power_ue.Prepare UE    ue_type=${UE_TYPE}
        ...                           ue_index=${${ue_id}-1}
        ...                           get_spark_license=${get_spark_license}
        ...                           force_check_ue=${True}
    END

Attach UE For LTE Cell
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${apn}=mdrb.nokia.com    ${attach_way}=popo_atreboot
    # fix AT command stuck issue,AT+QRNRU must be set to 1 after firmware update
    run keyword and ignore error    Execute AT Command    AT+QRNRU=1    ${ue_id}
    # set APN
    Execute AT Command    AT+CGDCONT=1,"IPV4V6","${apn}"    ${ue_id}
    # set attach mode
     Run Keyword If    '${attach_mode}' == '5G_SA'     Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",2    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",NR5G    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="ue_capability_band"    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '5G_NSA'    Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",1    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",auto    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="ue_capability_band"    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '4G'       Execute AT Command    AT+QNWPREFCFG="mode_pref",LTE    ue_id=${ue_id}
    ...    ELSE    Fail    not support attach_mode=${attach_mode}
    IF    '${attach_way.lower()}' == 'popo'
        _Attach With AT POPO    ${ue_id}    ${attach_mode}    ${apn}
    ELSE IF    '${attach_way.lower()}' == 'atreboot'
        _Attach With AT Reboot    ${ue_id}    ${attach_mode}    ${apn}
    ELSE
        ${attach_status1}    run keyword and return status    _Attach With AT POPO    ${ue_id}    ${attach_mode}    ${apn}
        return from keyword if    ${attach_status1}
        _Attach With AT Reboot    ${ue_id}    ${attach_mode}    ${apn}
    END

_Attach With AT POPO
    [Arguments]    ${ue_id}    ${attach_mode}    ${apn}
    Execute AT Command    AT+CFUN=0   ${ue_id}
    Sleep    30s
    Execute AT Command    AT+CFUN=1   ${ue_id}
    Sleep    30s
    ${apn}    Remove String    ${apn}    .
    ${ue_mode}    set variable if    '${attach_mode}' == '5G_SA'    SA    ${attach_mode}
    spark.get_ue_ip_on_ue    ue_alias=UE_${${ue_id}-1}
    ...                      apnaddress=${apn}
    ...                      ue_mode=${ue_mode}
    ...                      timeout=60
    Get UE RNTI    ${ue_id}
    [Teardown]    _Print Events    ${ue_id}

_Attach With AT Reboot
    [Arguments]    ${ue_id}    ${attach_mode}    ${apn}
    _Run AT Cmd    AT+CFUN=1,1   ${ue_id}
    Sleep    60s
    ${apn}    Remove String    ${apn}    .
    ${ue_mode}    set variable if    '${attach_mode}' == '5G_SA'    SA    ${attach_mode}
    spark.get_ue_ip_on_ue    ue_alias=UE_${${ue_id}-1}
    ...                      apnaddress=${apn}
    ...                      ue_mode=${ue_mode}
    ...                      timeout=60
    Get UE RNTI    ${ue_id}
    [Teardown]    _Print Events    ${ue_id}

Execute AT Command
    [Arguments]    ${cmd}    ${ue_id}=1
    ${resp}    wait until keyword succeeds    3x    20sec    _Run AT Cmd    ${cmd}    ${ue_id}
    [Return]    ${resp}

_Run AT Cmd
    [Arguments]    ${cmd}    ${ue_id}
    ${ue_index}    Set Variable    ${${ue_id}-1}
    ${resp}    spark.send AT command On UE     command=${cmd}     ue_alias=UE_${ue_index}
    list should contain value    ${resp.split()}    OK
    [Return]    ${resp}

_Print Events
    [Arguments]     ${ue_id}=1
#    run keyword and ignore error    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    ${event}    create list    LTE RACH Complete
    run keyword and ignore error    spark.get_event_count_on_ue    index=${${ue_id}-1}
    ...                                                            event_name=${event}
    ...                                                            ue_alias=UE_${${ue_id}-1}

Get UE RNTI
    [Arguments]    ${ue_id}=1
    wait until keyword succeeds    12x    10s    _Get UE RNTI for Once    ${ue_id}


_Get UE RNTI For Once
    [Arguments]    ${ue_id}=1
    ${params}    create list    LTE PCI    LTE RSRP[dBm]
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=UE_${${ue_id}-1}    param=${params}
    ${rnti_var_name}    Set Variable   UE${ue_id}_RNTI
    Set Test Variable    ${${rnti_var_name}}    ${value_list[0]}
    Set Test Variable    ${ue_param_value}    ${value_list}
    Run Keyword If    '${value_list[0]}' == ''    Fail    fail to attach UE${ue_id}

CB013395 Teardown
#    Stop and download Logs on gNB on master    filename=LTE1.4M_L3call.pcap
    Robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
