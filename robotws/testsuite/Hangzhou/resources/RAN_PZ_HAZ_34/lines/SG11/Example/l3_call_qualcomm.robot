*** Settings ***
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library    taf.hw.rf_attenuator    WITH NAME    attenuator

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G

*** Variables ***

*** Test Cases ***
[1]l3_call
    log variables
    log    ${tl}
    #test PA
    test l3 call

*** Keywords ***
test l3 call
    [Arguments]    ${ue_index}=${0}    ${dl_tp}=200    ${ul_tp}=100    ${duration}=30    ${target_avg_percent}=0.98
    # ***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    # Here we use keyword from ue.py to get last value of TL ue capabilities.
    # It can also be hard coded with ue_type like ue_type=nokia_fastmile.
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    # ***UE Attach***
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}     log_type=aasyslog
    power_ue.Verify Attach    ue_type=${ue_type}    ue_index=${ue_index}
    ${rc}    ${output}=    Run And Return Rc And Output    sshpass -p "nokia123@" ssh mn5gran@10.64.57.10 "adb shell ifconfig"
    log to console    ue pdu IP: ${output},start straffic...
    # ***start traffic***
    ${start_traffic_duration}    evaluate    ${duration}+${120}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}    #apn=dxdata4
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}    #apn=dxdata4
    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    check_source=aasyslog
    # check_source can be iperf when ue_type support iperf checking. Same for attach and check tput

    # ***Stop traffic ***
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}

    # ***check tput Pcell***
    # ${cells}    Create List    ${611516422}    ${611516417}
    # run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${dl_tp}
    # ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}    check_source=aasyslog
    #...    cells=${cells}    actCarrierAggregation=${True}

    # ***check tput Scell,no UL CA***
    ${cells}    Create List    ${611844098}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${ul_tp}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}    check_source=aasyslog    cells=${cells}

    # ***UE Detach ***
    [Teardown]    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}


Test PA
    attenuator.setup_attenuator    attenuator=${tl.attenuator}
    attenuator.read_attenuation    port=${1}
    attenuator.set_attenuation    port=${1}    value=${10}
    attenuator.read_attenuation    port=${1}
    attenuator.read_attenuation    port=${2}
    attenuator.set_attenuation    port=${2}    value=${10}
    attenuator.read_attenuation    port=${2}
