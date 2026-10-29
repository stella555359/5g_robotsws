# #*** Settings ***
# #Force Tags    PY36
# #Documentation
# #...   author: yuegong & xiaodan.li
# #...   contact: yue.1.gong@nokia-sbell.com
# #...   squad group: SG_03
# #...   Feature CB007657
# #
# #
# #Resource    ../Resource/CB007657_common_keywords.robot
# #
# #Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# #Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #Resource    ../../../../resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
# #Variables    ../Resource/7657_variables.py
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
# #
# #Suite Setup    Run Keywords
# #...    Get gnb release info    AND
# #...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# #...            Load SCF for each TL
# #
# #Suite Teardown    Run Keywords
# #...               Run Keyword And Ignore Error    CB007657_common_keywords.Common Suite Teardown for COAM   AND
# #...               Run Keyword And Ignore Error    COAM Teardown gnb connections
# #
# #
# #*** Variables ***
# ##${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
# ##${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
# ##${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
# #${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
# #${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
# #${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
# #${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
# #${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
# #${tl_23312_scf_gnb2}    gy_23312_GNB2.xml
# #@{BTSID}    36011    34711    23311
# #${enb1_gnb1_x2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
# #${enb2_gnb1_x2_dist}    MRBTS-${enb2_instance}/LNBTS-${enb2_instance}/LNADJGNB-1
# #${enb1_gnb2_x2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
# #${eNB_X2_ON_OFF}    administrativeState
# #${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
# #${enb2_def_gnb_dist}     MRBTS-${enb2_instance}/LNBTS-${enb2_instance}/LNCEL-1
# #${enb_def_cell_para}     defaultLnRelGnbCellId
# #
# #${vendor}                    ${tl.attenuators[0].vendor}
# #${att_api_port}              ${tl.attenuator[0].port}
# #${max_attenuation_value}     ${127}
# #${att_connection_port}       ${tl.attenuator[0].attenuator_ports[1]}
# #${att_ipaddr}      ${tl.attenuator[0].ip_addr}
# #${att_port_1_}                ${tl.attenuator[0].attenuator_ports[1]}
# #${att_port_2_}                ${tl.attenuator[0].attenuator_ports[2]}
# #${att_port_3_}                ${tl.attenuator[0].attenuator_ports[3]}
# #${att_port_4_}                ${tl.attenuator[0].attenuator_ports[4]}
# #${att_port_5_}                ${tl.attenuator[0].attenuator_ports[5]}
# #${att_port_6_}                ${tl.attenuator[0].attenuator_ports[6]}
# #${att_port_7_}                ${tl.attenuator[0].attenuator_ports[7]}
# #${att_port_8_}                ${tl.attenuator[0].attenuator_ports[8]}
# #${att_port_9_}                ${tl.attenuator[0].attenuator_ports[9]}
# #${att_port_10_}                ${tl.attenuator[0].attenuator_ports[10]}
# #${att_port_11_}                ${tl.attenuator[0].attenuator_ports[11]}
# #${att_port_12_}                ${tl.attenuator[0].attenuator_ports[12]}
# #${att_port_13_}                ${tl.attenuator[0].attenuator_ports[13]}
# #${att_port_14_}                ${tl.attenuator[0].attenuator_ports[14]}
# #${att_port_15_}                ${tl.attenuator[0].attenuator_ports[15]}
# #${att_port_16_}                ${tl.attenuator[0].attenuator_ports[16]}
# #
# ##${tl_scf_filename_A22}    ecpri_7657_A_22_CL_Peak.xml
# #${gnb_id}    ${tl.gnbs[0].instance_id}
# #${interface1}    any
# #${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
# #${enb_instance}    ${tl.enbs[0].instance_id}
# #${enb2_instance}    ${tl.enbs[1].instance_id}
# #${enbx2_para}             administrativeState
# #${dl_expect_throughput_false_trunk}        635
# #${dl_expect_throughput_true_trunk}        790
# #${ue_yaml}                ${tl.ues[0]}
# #${dl_throughput}            840M
# #${dl_throughput_22R2}            1500M
# #${DL_TIME}                  9999
# #${DL_LENGTH}                1024B
# #${ue_type}    ${tl.ues[1].capabilities[0]}
# #${bts_host}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# #${max_attenuation_value}    ${127}
# #${time}    600
# #@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
# #
# #*** Test Cases ***
# #[1]CB007657_A_22_US6_Low_PAPR_Close_Loop_8x4_SU_MIMO_with_beamforming_TDD_eCPRI_Peak
# #    [Documentation]
# #    ...    This test scenario is used to verify the E2E data transfer functionality of RF in full-panel mode.
# #    [Tags]     classical    CRT_TRUNK    CRT_22R4    CRT_23R1    CRT_22R3
# #    [Timeout]    1.5 hour
# #    [Setup]
# #    robot_common_operations.Common Case Setup
# #    Connect and Modify the ENB parameter    value=locked    dist_name=${enb2_gnb1_x2_dist}
# #    ...    enb_index=${1}    parameter=${eNB_X2_ON_OFF}
# #    Connect and Modify the ENB parameter    value=1    dist_name=${enb2_def_gnb_dist}
# #    ...    enb_index=${1}    parameter=${enb_def_cell_para}
# #    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online=${Lock_gnb1_AMF1}
# #    ...    ModifySCF_Aftercommission=True
# #    Connect and Modify the ENB parameter    value=unlocked    dist_name=${enb2_gnb1_x2_dist}
# #    ...    enb_index=${1}    parameter=${eNB_X2_ON_OFF}
# #    Prepare the atten for each TL
# #    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${1}
# #    ${list_of_cell_ids}    Create list    ${cell1_id}
# #    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
# #    ${PAPR_false_output}    Attach ue and check tput    ue_index=${0}
# #    ...    dl_expect_throughput=${dl_expect_throughput_false_trunk}    list_of_cell_ids=${list_of_cell_ids}
# #    ${peak_false}=    get peak value    ${PAPR_false_output}
# #    Modify gnb parameter and gnb on air    parameters=${PARAMS_TO_actDlLowPAPRoptimizedPrecoding_True}
# #    ${PAPR_true_output}     Attach ue and check tput    ue_index=${0}
# #    ...    dl_expect_throughput=${dl_expect_throughput_true_trunk}    list_of_cell_ids=${list_of_cell_ids}
# #    ${peak_true}=    get peak value    ${PAPR_true_output}
# #    Should be True    ${peak_true} - ${peak_false} > ${15}
# #    [Teardown]    Run Keywords
# #    ...    Run Keyword And Ignore Error    Connect and Modify the ENB parameter    value=3
# #    ...    dist_name=${enb2_def_gnb_dist}    parameter=${enb_def_cell_para}    AND
# #    ...    Run Keyword And Ignore Error    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online=${Unlock_gnb1_AMF1}
# #    ...    ModifySCF_Aftercommission=True    AND
# #    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
# #    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}    AND
# #    ...    Run Keyword And Ignore Error     Tests Recover    AND
# #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# #
# #*** Keywords ***
# #Load SCF for each TL
# #    Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'
# #    ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=False
# #    ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2}
# #    Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'
# #    ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=False
# #    ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2}
# #    Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'
# #    ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=False
# #    ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2}
# #
# #Online modify NIDD on gnb1 and gnb2
# #    [Arguments]    ${Modify_Para_Online}='NULL'    ${Modify_Para_Online_GNB2}='NULL'
# #    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
# #    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
# #    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
# #    ...    Modify_Para_Online=${Modify_Para_Online}    Modify_Para_Online_GNB2=${Modify_Para_Online_GNB2}
# #    sleep    5s
# #
# #Prepare the atten for each TL
# #    Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'
# #    ...    Adjust the TL HBTE attenuation value    enb2_cell1_value=${0}   gnb1_cell1_value=${0}
# #    Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'
# #    ...    Adjust the TL HBTE attenuation value    enb2_cell1_value=${0}   gnb1_cell1_value=${0}
# #    Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'
# #    ...    Adjust the TL HBTE attenuation value    enb2_cell1_value=${0}   gnb1_cell1_value=${0}
# #
# #
# #Adjust the TL HBTE attenuation value
# #    [Arguments]    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}    ${gnb1_cell1_value}=${127}
# #    ...    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
# #    ####create cell list#####
# #    @{att_ports_enb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}
# #    @{att_ports_enb2_cell1}    Create List    ${att_port_3_}    ${att_port_4_}
# #    @{att_ports_gnb1_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
# #    ...    ${att_port_15_}    ${att_port_16_}
# #    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_}    ${att_port_6_}
# #    ...    ${att_port_7_}    ${att_port_8_}
# #    @{att_ports_gnb2_cell1}    Create List    ${att_port_9_}    ${att_port_10_}
# #    ...    ${att_port_11_}    ${att_port_12_}
# #
# #    ###create value list####
# #    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
# #    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}
# #    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
# #    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
# #    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
# #
# #    ###Adjust the HBTE attenuation value###
# #    Set the attenuation value    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
# #    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
# #    Set the attenuation value    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
# #    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
# #    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
# #    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
# #    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
# #    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
# #    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
# #    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
# #
# #
# #
# #Modify gnb parameter and gnb on air of 7657 A22
# #    Modify gnb parameter and gnb on air    parameters=${PARAMS_TO_actDlLowPAPRoptimizedPrecoding_False}
# #    Modify gnb parameter and gnb on air    parameters=${PARAM_7326_pmax_37}
# #    Modify gnb parameter and gnb on air    parameters=${PARAMS_TO_dlQam256PowerBackoffSub6}
# #
# #
# #Tests Recover
# #    Power UE stop dl traffic and detach
# #    disconect all connections
# #    CI_interface.Common Case Teardown
# #
# #Attach ue and check tput
# #    [Arguments]    ${dl_expect_throughput}=${dl_expect_throughput}    ${list_of_cell_ids}=${list_of_cell_ids}
# #    ...    ${ue_index}=${0}
# ##    wait until keyword succeeds    3X    10s
# #    Attach and check power UE     ue_type=${ue_type}    4G_check=False     ue_index=${ue_index}
# #    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${time}    ue_index=${ue_index}
# #    sleep    150s
# #    ${output}    Check single direction throughput    expect_throughput=${dl_expect_throughput}
# #    ...    list_of_cell_ids=${list_of_cell_ids}    duration=5m    ue_index=${ue_index}
# #    Power UE stop dl traffic and detach    ue_index=${ue_index}
# #    [Return]    ${output}
# #
# #Commercial UE click AIRPLANE once
# #    [Documentation]    click AIRPLANE switch once
# #    ...    :param  swipe: Swipe the phone screen up
# #    ...    :param  Home_button: UE home button keycode
# #    ...    :param  airplane: airplane switch pointer variable
# #    ...    :param  close_task: close all UE's task pointer variable
# #    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${airplane}=${airplane}    ${close_task}=${close_task}
# #    ...   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
# #    sleep   2s
# #    #####Press the Home button to open the screen#####
# #    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
# #    sleep   2s
# #    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
# #    sleep   4s
# #    #####Swipe up to unlock the phone#####
# #    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
# #    sleep   4s
# #    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
# #    sleep   4s
# #    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=cygwin
# #    sleep   2s
# #    ${output}   csn.read_output    connection=cygwin
# #    #####Tap the airplane mode switch to enable airplane mode#####
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
# #    sleep   8s
# #    #####Click the task button#####
# #    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
# #    ...   Close Airmode confirm window for lg_v50   old_output=${output}    connection=cygwin
# ##    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
# #    sleep   4s
# #    #####Turn off all running tasks on the phone#####
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
# #    [Teardown]    csn.disconnect      connection=cygwin
# #
# #
# #Commercial UE click AIRPLANE twice
# #    [Documentation]    click AIRPLANE switch twice
# #    ...    :param  swipe: Swipe the phone screen up
# #    ...    :param  Home_button: UE home button keycode
# #    ...    :param  airplane: airplane switch pointer variable
# #    ...    :param  close_task: close all UE's task pointer variable
# #    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${airplane}=${airplane}    ${close_task}=${close_task}
# #    ...   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
# #    sleep   4s
# #    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
# #    sleep   2s
# #    #####Press the Home button to open the screen#####
# #    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
# #    sleep   4s
# #    #####Swipe up to unlock the phone#####
# #    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
# #    sleep   4s
# #    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
# #    sleep   4s
# #    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=cygwin
# #    sleep   2s
# #    ${output}   csn.read_output    connection=cygwin
# #    #####Tap the airplane mode switch to disable airplane mode#####
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
# #    sleep   4s
# #    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
# #    ...   Close Airmode confirm window for lg_v50   old_output=${output}    connection=cygwin
# #    sleep   50s
# #    #####Tap the airplane mode switch to enable airplane mode#####
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
# #    sleep   4s
# #    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
# #    ...   Close Airmode confirm window for lg_v50   old_output=${output}    connection=cygwin
# #    #####Click the task button#####
# ##    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
# #    sleep   4s
# #    #####Turn off all running tasks on the phone#####
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
# #    [Teardown]    csn.disconnect      connection=cygwin
# #
# #
# #Commercial UE click 5G once
# #    [Documentation]    click 5G switch once
# #    ...    :param  swipe: Swipe the phone screen up
# #    ...    :param  Home_button: UE home button keycode
# #    ...    :param  5G: 5G switch pointer variable
# #    ...    :param  close_task: close all UE's task pointer variable
# #    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${5G}=${5G}    ${close_task}=${close_task}   ${ue_index}=${0}
# #    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
# #    Connect to control pc via cygwin    ue_index=${ue_index}
# #    sleep   2s
# #    #####Press the Home button to open the screen#####
# #    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
# #    sleep   2s
# #    #####Swipe up to unlock the phone#####
# #    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
# #    sleep   2s
# #    csn.send_command    command=adb -s ${serial_number} shell am start -n com.android.phone/.MobileNetworkSettings    connection=cygwin
# #    sleep   2s
# #    #####Tap the 5G mode switch to enable 5G mode#####
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${5G}    connection=cygwin
# #    sleep   5s
# #    #####Click the task button#####
# ##    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
# #    sleep   2s
# #    #####Turn off all running tasks on the phone#####
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
# #    sleep   2s
# #    [Teardown]    csn.disconnect      connection=cygwin
