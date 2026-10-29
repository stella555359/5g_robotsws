*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG11/Resources/SG11_Common_setup_teardown.robot
Suite Setup       SG11 Common Suite Setup
Suite Teardown    SG11 Common Suite Teardown
Test Setup        SG11 Common Case Setup
Test Teardown     SG11 Common Case Teardown

*** Variables ***
${cell_type}             NR
${ue_index}              ${0}
${UL_TPUT}               150
${DL_TPUT}               600
${UL_EXPECT1}            100
${DL_EXPECT1}            400
${UL_EXPECT2}            50
${DL_EXPECT2}            200
${TARGET_AVG_PERCENT}    0.98
${SCF_FILE}              ${CURDIR}/config/SCF_FDD_TDD.xml
# @{BLOCK_CELL_LIST}       2    3    5
@{cell_list}             ${611844098}    ${611844096}
@{L2STREAM_COMPONENT_CONFIG}    &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
CB012149_ET_BA305_Connection_Setup_With_1F_1T_UL_Tx_Switching_SingleUE_With_SCell RLQ_Scell_Release
    Full Commission With SCF File    ${SCF_FILE}
    Wait Until Keyword Succeeds    10min    30s    Verify All Cells Should Be Onair
    # SBTS Block Cells And Check Status    ${block_cell_list}
    ${ue_type}    ue.Translate Power Ue Type From Testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Get and Set FDD Cell Attenuator    ${0}
    Get and Set TDD Cell Attenuator    ${110}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    #UE Attach
    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify Attach    ue_type=${ue_type}    ue_index=${ue_index}
    ${rc}    ${output}=    Run And Return Rc And Output    sshpass -p "nokia123@" ssh mn5gran@10.64.57.18 "adb shell ifconfig"
    Get and Set TDD Cell Attenuator    ${10}
    # Start Traffic
    Log To Console    ue pdu IP: ${output},start straffic...
    power_ue.Start Traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_tput}
    ...    duration=1200    ue_type=${ue_type}    iperf_type=via_command    protocol=udp
    Sleep    1s
    power_ue.Start Traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_tput}    duration=1200
    ...    ue_type=${ue_type}    protocol=udp    buffer_size=1400B    process_num=${2}    seg_size=1350    window=16M
    Sleep    5s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=10s    check_source=aasyslog
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${DL_EXPECT1}
    ...    target_avg_percent=${TARGET_AVG_PERCENT}    ue_index=${ue_index}    check_source=aasyslog
    ...    cells=${cell_list}    actCarrierAggregation=${true}
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${UL_EXPECT1}
    ...    target_avg_percent=${TARGET_AVG_PERCENT}    ue_index=${ue_index}    check_source=aasyslog
    ...    cells=${cell_list}    actCarrierAggregation=${true}
    Capture Convert Format Ttitrace With Streaming Mode    1s
    Get and Set TDD Cell Attenuator    ${120}
    Sleep    5s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=10s    check_source=aasyslog
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${DL_EXPECT2}
    ...    target_avg_percent=${TARGET_AVG_PERCENT}    ue_index=${ue_index}    check_source=aasyslog
    ...    cells=${cell_list}    actCarrierAggregation=${true}
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${UL_EXPECT2}
    ...    target_avg_percent=${TARGET_AVG_PERCENT}    ue_index=${ue_index}    check_source=aasyslog
    ...    cells=${cell_list}    actCarrierAggregation=${true}
    Capture Convert Format Ttitrace With Streaming Mode    1s
    power_ue.Stop Traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop Traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

*** Keywords ***
Get and Set FDD Cell Attenuator
    [Arguments]    ${value}    ${PA_type}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${PA_type}
    ${value_1}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0]}    attenuator_device=${PA_type}
    ${value_2}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1]}    attenuator_device=${PA_type}
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0]}    value=${value}    attenuator_device=${PA_type}
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1]}    value=${value}    attenuator_device=${PA_type}

Get and Set TDD Cell Attenuator
    [Arguments]    ${value}    ${PA_type}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${PA_type}
    ${value_1}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0]}    attenuator_device=${PA_type}
    ${value_2}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1]}    attenuator_device=${PA_type}
    ${value_3}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2]}    attenuator_device=${PA_type}
    ${value_4}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3]}    attenuator_device=${PA_type}
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0]}    value=${value}    attenuator_device=${PA_type}
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1]}    value=${value}    attenuator_device=${PA_type}
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2]}    value=${value}    attenuator_device=${PA_type}
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3]}    value=${value}    attenuator_device=${PA_type}