*** Settings ***
Documentation    CA Feature CB008423 Automation cases common steps
...              Author: lanwen.cai@nokia-sbell.com


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    CB007028_SG08_kw.robot

*** Variables ***
${TS_LOG_PATH_BASE}   ${OUTPUT DIR}

*** Keywords ***
CB008423-5G-B-SyVe_20_CB007922_SA_ Single_UE_Peak_Throughput_20M_20M
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Test 20+20 AZQF+AZQR CA
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    Log to console    Start Test 20+20 AZQF+AZQD CA
    Set PA Vaules to 127
    Set PA To Attach PCELL
    Start UE attach    ue_index=${1}
    Set PA For CA To SCELL
    CB008423_common_keywords.Start traffic    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${300}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
    ${cell_id1}    Create List    ${cell_id1}
    ${cell_id2}    Convert To String    ${cell_mapping[2]['nrCellIdentity']}
    ${cell_id2}    Create List    ${cell_id2}
    log to console    \n***Start Check Throughput***
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id1}
    ...    ultarget_throughput=${TPUT_EXP['ul_exp_Pcell']}    dltarget_throughput=${TPUT_EXP['dl_exp_Pcell']}
    ...    target_avg_percent=0.95    min_percent=0.85
    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${cell_id2}
    ...    target_throughput=${TPUT_EXP['dl_exp_Scell']}
    ...    target_avg_percent=0.95   min_percent=0.85
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    Stop Single UE L3 Call    ue_index=${1}

Set PA To Attach PCELL
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Set Scell PA to 127
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    ${PA_124}    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=HBTE
    attenuator.set_attenuation    port=${1}    value=${5}    attenuator_device=${PA_124}
    attenuator.set_attenuation    port=${2}    value=${5}    attenuator_device=${PA_124}
    attenuator.set_attenuation    port=${3}    value=${5}    attenuator_device=${PA_124}
    attenuator.set_attenuation    port=${4}    value=${5}    attenuator_device=${PA_124}

Set PA For CA To SCELL
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Set Scell PA to 127
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    ${PA_124}    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=HBTE
    attenuator.set_attenuation    port=${5}    value=${15}    attenuator_device=${PA_124}
    attenuator.set_attenuation    port=${6}    value=${15}    attenuator_device=${PA_124}
    attenuator.set_attenuation    port=${7}    value=${15}    attenuator_device=${PA_124}
    attenuator.set_attenuation    port=${8}    value=${15}    attenuator_device=${PA_124}

Start UE attach
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]start UE attach
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set test variable    ${ue_type}
    log to console    \n***Start UE attach***
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    2s
    Connect to Common Unit Master    alias=ASIK MASTER
    connect to gnb coam via ssl    connection=GNB_OAM
    ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
        ...    alias=ASIK MASTER    connection=GNB_OAM

Start traffic
    [Documentation]   Owner_lanwen.cai@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}    ${dl_tp}=600M    ${ul_tp}=100M    ${traffic_duration}=${1200}    ${protocol}=udp
    ...     ${iperf_type}=via_command
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    log to console    \n***Start traffic***
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}
    ...    duration=${traffic_duration}    protocol=${protocol}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
    ...    duration=${traffic_duration}    protocol=${protocol}    iperf_type=${iperf_type}
