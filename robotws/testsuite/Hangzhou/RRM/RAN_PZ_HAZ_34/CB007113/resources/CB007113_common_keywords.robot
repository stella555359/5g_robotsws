*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02

Library           taf.hw.rf_attenuator.attenuator    WITH NAME    attenuator
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource          ../../CB006915/resources/CB006915_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot

*** Variables ***
${att_port_1_gnb_cell1_83}    ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb_cell1_83}    ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb_cell1_83}    ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb_cell1_83}    ${tl.attenuator[0].attenuator_ports[8]}
${att_ipaddr_gnb_cell1_83}    ${tl.attenuator[0].ip_addr}
${value_PA}    ${80}
${value_default_PA}    ${20}
@{2mimocell_ids}    185663489    185663490
@{cell_id}    185663491
${exp_2ues_ul_tput}    100
${exp_ul_tput}    240
@{cpe_ue_index}    0    1    2    3    4
@{single_ue_index}    4
@{counter_id}   M55308C35004    M55308C35007    M55308C35006
@{full_path}    [TL169_ECPRI_SA] MRBTS-11332/NRBTS-11332/NRCELL-1/NCELA/PRB_UL_MU_MIMO_3LAYER
...             [TL169_ECPRI_SA] MRBTS-11332/NRBTS-11332/NRCELL-1/NCELA/PRB_UL_MU_MIMO_2PAIR_UE
...             [TL169_ECPRI_SA] MRBTS-11332/NRBTS-11332/NRCELL-1/NCELA/PRB_UL_MU_MIMO_NOPAIR_UE
${mcs_type}    hbte
${mcs_index}   0

*** Keywords ***
Multi_UEs_Attach_And_UL_Traffic_For_7113
    [Documentation]    Author: Chen Helen
    ...                This keyword is Multi UEs attach and UL traffic
    [Arguments]    ${ue_index}=${1}    ${cpe_ue_index}=${cpe_ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=1
    log to console    Prepare Multi UE and Start UL Traffic
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}
    Catch_Logs_with_gnb_logs
    Check_2UE_Mumimo_Paired
    log to console  3 layer paired
    Modify_MCS_To_UL_3_Layer_Paired
    Check_2UE_UL_3Layer_Paired
    Log to console   add bler to mumimo cell
    Modify_Att_To_Add_BLER
    Check_UE_UL_Not_Paired

Multi_UEs_Attach_And_UL_Traffic_For_IWK_8662
    [Documentation]    Author: Chen Helen
    ...                This keyword is for IWK with 8662
    [Arguments]    ${ue_index}=${1}
    Log to console    step1 start traffic
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=0
    Muti_CPE_UEs_UL_DL_Traffic    ue_index= ${ue_index}    cpe_ue_index
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m
    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    min_percent=0
    ...    target_throughput=${exp_2ues_ul_tput}    log=${log}    cells=${2mimocell_ids}
    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    min_percent=0
    ...    target_throughput=${exp_ul_tput}    log=${log}    cells=${cell_id}
    Log to console    step2 adjust PA for Cell 94 and start traffic
    Adjust_HBTE_attenuation_value    att_port_1=${att_port_1_gnb_cell1_94}
    ...    att_port_2=${att_port_2_gnb_cell1_94}    att_port_3=${att_port_3_gnb_cell1_94}
    ...    att_port_4=${att_port_4_gnb_cell1_94}    atten_ip=${att_ipaddr_gnb_cell1_94}
    ...    value_PA=${value_PA}
    sleep    60s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m
    ${UL_step2_tput}    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    min_percent=0
    ...    target_throughput=${exp_ul_tput}    log=${log}    cells=${cell_id}
    Log to console    step3 modify CB008662 parameter and start traffic
    Set_IWK_CB008662_Parameter    cell_index=${3}
    Muti_CPE_UEs_UL_DL_Traffic    ue_index= ${ue_index}    cpe_ue_index
    sleep    60s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m
    ${UL_step3_tput}    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    min_percent=0
    ...    target_throughput=${exp_ul_tput}    log=${log}    cells=${cell_id}
    Should Be True    ${UL_step2_tput[0]}[average] < ${UL_step3_tput[0]}[average]

Adjust_HBTE_attenuation_value
    [Arguments]     ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}
    ...    ${att_port_3}=${att_port_3}    ${att_port_4}=${att_port_4}
    ...    ${atten_ip}=${atten_ip}    ${value_PA}=${value_PA}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=5000
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=127    vendor=HBTE
    attenuator.set_attenuation     port=${att_port_1}    value=${value_PA}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_PA}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_PA}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_PA}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_PA}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_PA}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_PA}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_PA}
    sleep    5s

Set_IWK_CB008662_Parameter
    [Documentation]    Author: Chen Helen
    ...                This keyword is modify the parameter in webui to activate pooling
    [Arguments]    ${cell_index}
    Selenium Login And Disable Screen Lock
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
    ...    filter_param=Activate adaptive retransmission based on reserved MCS
    ...    new_value=true
    selenium_coam.validate_plan
    selenium_coam.activate_plan     activate_plan_despite_errors=True
    Selenium Logout And Close Browser
    Wait until keyword succeeds    5min    30sec    coam_gnb_classical.Connect to gnb coam via ssl
    Wait until keyword succeeds    20min    20sec    coam_gnb_classical.Verify all cells should be on air
    Run Keyword And Ignore Error    coam_gnb_classical.COAM Teardown gnb connections

MCS SETUP AND SET ATT
    [Arguments]
    ${mcs_type}    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    att_value1=${20}    att_value2=${20}    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}

HBTE MCS SETUP AND SET ATT for MultiUE
    [Arguments]    ${mcs_type}    ${att_value_UE0}    ${att_value_UE1}
    ...    ${horizontal_angle_1}    ${horizontal_angle_2}
    ...    ${horizontal_angle_3}    ${horizontal_angle_4}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HBTE
    HBTE MCS change UE Phases     mcs_type=${mcs_type}
    ...    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${horizontal_angle_1}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${horizontal_angle_2}
    HBTE MCS change UE Phases     mcs_type=${mcs_type}
    ...    vertical_angle=${96}
    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${horizontal_angle_3}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${horizontal_angle_4}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE0}
    ...    begin_output_port=${1}    end_output_port=${4}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE1}
    ...    begin_output_port=${5}    end_output_port=${8}

Add_Bler_with_paired_Ues
    MCS_Setup    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    MCS_Set_ATT   mcs_type=${mcs_type}    att_value=${50}
    ...    begin_output_port=${3}    end_output_port=${3}

CB007113_Case_Teardown
    mcs_common.Teardown MCS    mcs_type=${mcs_type}    mcs_index=0    mcs_alias=MCS_${mcs_index}

MCS_Setup
    [Arguments]    ${mcs_type}    ${mcs_index}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    mcs_index=${mcs_index}    mcs_alias=MCS_${mcs_index}
    ...            server_ip=${tl.mcses[${mcs_index}].ip_addr}
    ...            server_port=${tl.mcses[${mcs_index}].port}
    ...            vendor=${tl.mcses[${mcs_index}].vendor}
    ...            model=${tl.mcses[${mcs_index}].model}
    ...            frequency=${None}

MCS_Set_ATT
    [Arguments]    ${att_value}    ${mcs_type}    ${begin_output_port}    ${end_output_port}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}

Modify_Att_To_Add_BLER
    MCS_Setup    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    MCS_Set_ATT   mcs_type=${mcs_type}    att_value=${50}
    ...    begin_output_port=${4}    end_output_port=${4}
    MCS_Set_ATT   mcs_type=${mcs_type}    att_value=${50}
    ...    begin_output_port=${7}    end_output_port=${8}
    mcs_common.Teardown MCS    mcs_type=${mcs_type}    mcs_index=0    mcs_alias=MCS_${mcs_index}

Modify_MCS_To_UL_3_Layer_Paired
    MCS_Setup    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    MCS_Set_ATT   mcs_type=${mcs_type}    att_value=${90}
    ...    begin_output_port=${1}    end_output_port=${2}
    mcs_common.Teardown MCS    mcs_type=${mcs_type}    mcs_index=0    mcs_alias=MCS_${mcs_index}

Check_2UE_UL_3Layer_Paired
    ${PM_counter_PRB_UL_MU_MIMO_3LAYER}    Check PM counter from webui    counter_id=${counter_id}[0]    full_path=${full_path}[0]
    ${PM_counter_PRB_UL_MU_MIMO_2PAIR_UE}    Check PM counter from webui    counter_id=${counter_id}[1]    full_path=${full_path}[1]
    should be true    ${PM_counter_PRB_UL_MU_MIMO_2PAIR_UE} != 0
    should be true    ${PM_counter_PRB_UL_MU_MIMO_2PAIR_UE} != 0

Check_UE_UL_Not_Paired
    ${PM_counter_PRB_UL_MU_MIMO_NOPAIR_UE}    Check PM counter from webui    counter_id=${counter_id}[2]    full_path=${full_path}[2]
    should be true    ${PM_counter_PRB_UL_MU_MIMO_NOPAIR_UE} != 0
