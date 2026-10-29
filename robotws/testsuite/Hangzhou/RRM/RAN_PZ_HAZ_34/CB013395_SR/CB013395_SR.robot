*** Settings ***
Documentation
...    author: Kang Xiang
...    contact: kang.xiang@nokia.com
...    squal group: SG03
...    feature: CB013395

Force Tags  tl-7_5_UTE5G402T2410
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
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Library     taf.transport.ssh    WITH NAME    csn

*** Variables ***
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
@{gnb_list}        ${0}
${Allowed_Faults_Ids_13395}    49

#bts id
${MRBTS_ID}       2410    #${tl.gnbs[0].instance_id}
${NRBTS_ID}       ${tl.gnbs[0].global_bts_id}
${NRCELL111_ID}   111
${NRCELL112_ID}   112
${FDD_NR_Cell111_disname}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL111_ID}
${FDD_NR_Cell112_disname}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL112_ID}
${LNBTS_ID}                  11396    #${tl.gnbs[0].global_bts_id_LTE}
${LNCELL_ID_1.4M}    41
${LNCELL21_ID}       21
${LNCELL31_ID}       31
${FDD_LTE1.4Cell_disname}    MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LNCELL_ID_1.4M}
${FDD_LTE_Cell21_disname}    MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LNCELL21_ID}
${FDD_LTE_Cell31_disname}    MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LNCELL31_ID}
${LNCELL_ID_3M}    42
${LNCELL22_ID}     22
${LNCELL32_ID}     32
${FDD_LTE3Cell_disname}      MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LNCELL_ID_3M}
${FDD_LTE_Cell22_disname}    MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LNCELL22_ID}
${FDD_LTE_Cell32_disname}    MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LNCELL32_ID}
${GCELL1_ID}    1
${GCELL2_ID}    2
${GCELL3_ID}    3

${UE_TYPE}      ${tl.ues[0].capabilities[0]}

# TL2410
${4Gcell_1.4M_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${4Gcell_1.4M_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${4Gcell_1.4M_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${4Gcell_1.4M_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}

${4Gcell_3M_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${4Gcell_3M_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${4Gcell_3M_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${4Gcell_3M_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}

@{4Gcell_1.4M_ANTS}    ${4Gcell_1.4M_ANT1}    ${4Gcell_1.4M_ANT2}    ${4Gcell_1.4M_ANT3}    ${4Gcell_1.4M_ANT4}
@{4Gcell_1.4M_VALUES}  ${10}    ${10}    ${10}    ${10}
@{4Gcell_VALUES_MAX}  ${127}    ${127}    ${127}    ${127}
@{4Gcell_3M_ANTS}      ${4Gcell_3M_ANT1}    ${4Gcell_3M_ANT2}    ${4Gcell_3M_ANT3}    ${4Gcell_3M_ANT4}
@{4Gcell_3M_VALUES}    ${10}    ${10}    ${10}    ${10}

${ue0_type}            ${tl.ues[0].capabilities[0]}
${ue0_type_lte}            ${tl.ues[0].capabilities[1]}

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
    Reset BTS And Wait Until On Air
    Lock Unlock FDD NR Cell_111
    Lock Unlock FDD NR Cell_112
    Lock Unlock FDD LTE Cell_21_31
    Lock Unlock FDD LTE Cell_22_32
    Lock Unlock FDD LTE1.4M Cell
    Lock Unlock FDD LTE3M Cell
    Lock FDD NR Cell And Other FDD LTE Cell In RMOD1
    UE Attach To FDD LTE1.4M Cell
    Unlock And Lock FDD NR Cell In RMOD1
    Unlock And Lock FDD LTE Cell_21_31
    Reset FDD NR Cell In RMOD1
    Reset FDD LTE3M Cell In RMOD2
    Lock FDD NR Cell And Other FDD LTE Cell In RMOD2
    UE Attach To FDD LTE3M Cell
    Reset FDD LTE1.4M Cell
    Delta Commission For FDD NR LTE3M_1.4M Cell
    [Teardown]    CB013395 Teardown

*** Keywords ***
Prerequisite For Case
    Robot_common_operations.Common Case Setup    allowed_faults_ids=${Allowed_Faults_Ids_13395}

Reset BTS And Wait Until On Air
    [Arguments]  ${connection}=GNB_OAM    ${gnb_web_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Log To Console    Reset BTS And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${gnb_web_ip}    connection=${connection}
    sleep    2s
    coam.reset_site    connection=${connection}
    Wait Until Keyword Succeeds    1200s    20s    Verify all nr_lte cells should be onair    cell_type=nr    connection=${connection}
    Wait Until Keyword Succeeds    1200s    20s    Verify all nr_lte cells should be onair    cell_type=lte    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify all nr_lte cells should be onair
    [Documentation]    Description: verify all the cells status should be correct.
    [Arguments]    ${cell_type}=nr  ${connection}=GNB_OAM
    Log to console    Verify all cells are on air
    ${administrative_expected}    Set Variable      Unlocked      # NR
    ${administrative_expected}    Set Variable If   '${cell_type}'=='lte'    unlocked    ${administrative_expected}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}
        ...      ${administrative_expected}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}    enabled
        Run keyword and continue on failure    Dictionary Should Not Contain Key    ${cell['status']}     availabilityStatus
        ...   msg=Cell-${cell['physicalCellId']}'s availabilityStatus present, means cell is disable or degraded, please check.
    END

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
    [Arguments]    ${FDD_NR_Cell_disname}    ${NRCELL_ID}
    Operate state of one cell    dist_name=${FDD_NR_Cell_disname}  operation=Lock
    Wait Until Keyword Succeeds   5 min  5 sec    Check NR cell locked    cell_id=${NRCELL_ID}

Unlock FDD NR Cell
    [Arguments]    ${FDD_NR_Cell_disname}    ${NRCELL_ID}
    Operate state of one cell    dist_name=${FDD_NR_Cell_disname}  operation=Unlock
    Wait Until Keyword Succeeds   5 min  5 sec   Check NR cell unlocked   cell_id=${NRCELL_ID}

Lock Unlock FDD NR Cell_111
    log to console    Lock And Unlock FDD NR Cell_111
    Lock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell111_disname}    NRCELL_ID=${NRCELL111_ID}
    Unlock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell111_disname}    NRCELL_ID=${NRCELL111_ID}

Lock Unlock FDD NR Cell_112
    log to console    Lock And Unlock FDD NR Cell_112
    Lock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell112_disname}    NRCELL_ID=${NRCELL112_ID}
    Unlock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell112_disname}    NRCELL_ID=${NRCELL112_ID}

Lock Unlock FDD LTE Cell_21_31
    log to console    Lock And Unlock FDD LTE Cell_21_31
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell21_disname}  LTE_CELL_ID=${LNCELL21_ID}
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell31_disname}  LTE_CELL_ID=${LNCELL31_ID}
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell21_disname}  LTE_CELL_ID=${LNCELL21_ID}
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell31_disname}  LTE_CELL_ID=${LNCELL31_ID}

Lock Unlock FDD LTE Cell_22_32
    log to console    Lock And Unlock FDD LTE Cell_22_32
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell22_disname}  LTE_CELL_ID=${LNCELL22_ID}
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell32_disname}  LTE_CELL_ID=${LNCELL32_ID}
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell22_disname}  LTE_CELL_ID=${LNCELL22_ID}
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell32_disname}  LTE_CELL_ID=${LNCELL32_ID}

Lock FDD LTE Cell
    [Arguments]    ${FDD_LTE_cell_disname}    ${LTE_CELL_ID}
    Operate state of one cell    dist_name=${FDD_LTE_cell_disname}  operation=Lock
    Wait Until Keyword Succeeds   5 min  5 sec    Check LTE cell locked    cell_id=${LTE_CELL_ID}

Unlock FDD LTE Cell
    [Arguments]    ${FDD_LTE_cell_disname}    ${LTE_CELL_ID}
    Operate state of one cell    dist_name=${FDD_LTE_cell_disname}  operation=Unlock
    Wait Until Keyword Succeeds   5 min  5 sec    Check LTE cell unlocked    cell_id=${LTE_CELL_ID}

Lock FDD LTE1.4M Cell
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE1.4Cell_disname}  LTE_CELL_ID=${LNCELL_ID_1.4M}

Unlock FDD LTE1.4M Cell
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE1.4Cell_disname}  LTE_CELL_ID=${LNCELL_ID_1.4M}

Lock Unlock FDD LTE1.4M Cell
    log to console    Lock And Unlock FDD LTE1.4M Cell
    Lock FDD LTE1.4M Cell
    Unlock FDD LTE1.4M Cell

Lock FDD LTE3M Cell
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE3Cell_disname}  LTE_CELL_ID=${LNCELL_ID_3M}

Unlock FDD LTE3M Cell
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE3Cell_disname}  LTE_CELL_ID=${LNCELL_ID_3M}

Lock Unlock FDD LTE3M Cell
    log to console    Lock And Unlock FDD LTE3M Cell
    Lock FDD LTE3M Cell
    Unlock FDD LTE3M Cell

Lock FDD NR Cell And Other FDD LTE Cell In RMOD1
    Lock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell111_disname}    NRCELL_ID=${NRCELL111_ID}
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell21_disname}  LTE_CELL_ID=${LNCELL21_ID}
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell31_disname}  LTE_CELL_ID=${LNCELL31_ID}

Unlock And Lock FDD NR Cell In RMOD1
    Unlock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell111_disname}    NRCELL_ID=${NRCELL111_ID}
    Lock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell111_disname}    NRCELL_ID=${NRCELL111_ID}

Unlock And Lock FDD LTE Cell_21_31
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell21_disname}  LTE_CELL_ID=${LNCELL21_ID}
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell31_disname}  LTE_CELL_ID=${LNCELL31_ID}
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell21_disname}  LTE_CELL_ID=${LNCELL21_ID}
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell31_disname}  LTE_CELL_ID=${LNCELL31_ID}

Reset FDD NR Cell In RMOD1
    Unlock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell111_disname}    NRCELL_ID=${NRCELL111_ID}
    COAM gNB Reset cell via api    cell_id=${FDD_NR_Cell111_disname}
    Wait until keyword succeeds    5 min  5 sec   Check Cell Onair
    ...    cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${NRBTS_ID}/NRCELL_R-${NRCELL111_ID}    cell_type=NR

Reset FDD LTE3M Cell In RMOD2
    Unlock FDD LTE3M Cell
    COAM gNB Reset cell via api    cell_id=${FDD_LTE3Cell_disname}
    Wait until keyword succeeds    5 min  5 sec   Check Cell Onair
    ...    cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${LNBTS_ID}/LNCEL_R-${LNCELL_ID_3M}    cell_type=lte

Lock FDD NR Cell And Other FDD LTE Cell In RMOD2
    Lock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell112_disname}    NRCELL_ID=${NRCELL112_ID}
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell22_disname}  LTE_CELL_ID=${LNCELL22_ID}
    Lock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell32_disname}  LTE_CELL_ID=${LNCELL32_ID}

Reset FDD LTE1.4M Cell
    Unlock FDD LTE1.4M Cell
    COAM gNB Reset cell via api    cell_id=${FDD_LTE1.4Cell_disname}
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

UE Attach To FDD LTE1.4M Cell
    log to console    set attenuation for 1.4M LTE cell
    log to console    ${att_ipaddr}
    Set the attenuation value of ports simultaneously
    ...    att_ports=${4Gcell_3M_ANTS}    values=${4Gcell_VALUES_MAX}    att_ipaddr=${att_ipaddr}
    Set the attenuation value of ports simultaneously
    ...    att_ports=${4Gcell_1.4M_ANTS}    values=${4Gcell_1.4M_VALUES}    att_ipaddr=${att_ipaddr}
    log to console    ue attach to FDD 1.4M cell
    Start capture gNB log on master    filename=LTE1.4M_3M_L3call.pcap
    Power_ue.Prepare UE    ue_type=${ue0_type_lte}    ue_index=${0}
    Switch airplane mode for S21    type=detach
    Verify UE Status For S21    type=detach
    Switch airplane mode for S21    type=attach
    Verify UE Status For S21    type=attach
    Wait Until Keyword Succeeds    2min    5sec    Get UE Ip for S21

UE Attach To FDD LTE3M Cell
    log to console    set attenuation for 3M LTE cell
    log to console    ${att_ipaddr}
    Set the attenuation value of ports simultaneously
    ...    att_ports=${4Gcell_1.4M_ANTS}    values=${4Gcell_VALUES_MAX}    att_ipaddr=${att_ipaddr}
    Set the attenuation value of ports simultaneously
    ...    att_ports=${4Gcell_3M_ANTS}    values=${4Gcell_3M_VALUES}    att_ipaddr=${att_ipaddr}
    log to console    ue attach to FDD 3M cell
    Power_ue.Prepare UE    ue_type=${ue0_type_lte}    ue_index=${0}
    Switch airplane mode for S21    type=detach
    Verify UE Status For S21    type=detach
    Switch airplane mode for S21    type=attach
    Verify UE Status For S21    type=attach
    Wait Until Keyword Succeeds    2min    5sec    Get UE Ip for S21

Switch airplane mode for S21
    [Arguments]    ${type}    ${ue_index}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    switch airplane mode for UE${ue_index} ${type}
    ${status} =    Check airplane mode status on    ue_index=${ue_index}
    Run keyword if  ('${status}' == '${True}' and '${type}' == 'attach') or ('${status}' == '${False}' and '${type}' == 'detach')
    ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
    ...    AND    Commercial UE click AIRPLANE once for S21    Home_button=3    swipe=500 2000 500 500
    ...    airplane=905 1132    close_task=540 2333    ue_index=${ue_index}
    log to console    UE${ue_index} ${type} + sleep 3s
    sleep    3s

Verify UE Status For S21
    [Arguments]    ${type}=attach    ${ue_index}=${0}
    ${return_value} =    Check airplane mode status on    ue_index=${ue_index}
    Run keyword if    "${type}" == "detach"    Should be true    ${return_value}
    ...  ELSE IF    "${type}" == "attach"    Should not be true    ${return_value}

Commercial UE click AIRPLANE once for S21
    [Documentation]    click AIRPLANE switch once
    ...    :param  swipe: Swipe the phone screen up
    ...    :param  Home_button: UE home button keycode
    ...    :param  airplane: airplane switch pointer variable
    ...    :param  close_task: close all UE's task pointer variable
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${airplane}=${airplane}    ${close_task}=${close_task}
    ...   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   4s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=cygwin
    sleep   2s
    ${output}   csn.read_output    connection=cygwin
    #####Tap the airplane mode switch to enable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
    sleep   8s
    #####Return to screen on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

Get UE Ip for S21
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr | grep 'global rmnet0' | cut -d '/' -f 1 | head -1 |awk '{print $2}'
    Should not contain    ${UE_IP}    127.0.0
    log to console  ${UE_IP}

Delta Commission For FDD NR LTE3M_1.4M Cell
    [Arguments]
    ...    ${json_file}=${CURDIR}/test_data/CB013395_parameters_recommission.json
    ...    ${gnb_index}=${0}
    ...    ${skip_parameter_relation_errors}=True
    ...    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    connection=${connection}
    coam.perform_delta_recommissioning    delta_file=${json_file}    timeout=${300}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    sleep    5    wait to stable
    Wait Until Keyword Succeeds    1200s    20s    Verify all nr_lte cells should be onair    cell_type=nr    connection=${connection}
    Wait Until Keyword Succeeds    1200s    20s    Verify all nr_lte cells should be onair    cell_type=lte    connection=${connection}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Recover Cell With Commission
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell21_disname}  LTE_CELL_ID=${LNCELL21_ID}
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell31_disname}  LTE_CELL_ID=${LNCELL31_ID}
    Unlock FDD NR Cell    FDD_NR_Cell_disname=${FDD_NR_Cell112_disname}    NRCELL_ID=${NRCELL112_ID}
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell22_disname}  LTE_CELL_ID=${LNCELL22_ID}
    Unlock FDD LTE Cell    FDD_LTE_cell_disname=${FDD_LTE_Cell32_disname}  LTE_CELL_ID=${LNCELL32_ID}
    Delta Commission For FDD NR LTE3M_1.4M Cell    json_file=${CURDIR}/test_data/CB013395_parameters_recover.json

CB013395 Teardown
    Recover Cell With Commission
    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=LTE1.4M_3M_L3call.pcap
    Robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
