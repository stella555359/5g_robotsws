*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835
...   author: Malgorzata Wegrzyn, Szymon Misiolek
...   contact: malgorzata.1.wegrzyn@nokia.com, szymon.misiolek@nokia.com

Library     taf.ue
Library     taf.hw.rf_attenuator
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Variables   resources/call_delta.py
Resource    resources/CellOperations.robot
Variables    ./resources/data_transfer_configuration.py
Library      taf.rfrl.bts.commissioning
Variables    ../../RAN_PZ_KRK4/resources/variables.py
#Library     ../python/common_allowed_alarms.py
Variables    taf/rfrl/bts/alarms/classical_alarms_definition.py

Force Tags      CA_VRF_KRK

Suite Setup     Common Suite Setup With OnAir Test Line Preparation
...  swconfig_from_path=${swconfig_from_path}
...  increase_timeout_for_update_sw=${3600}
...  list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
Suite Teardown  Common Suite Teardown
Test Setup      Common Preconditions
Test Teardown   Common Postconditions

*** Variables ***
${GNB_ID}      ${tl.gnbs[0].global_bts_id}
${alias}=      Samsung
# ${swconfig_from_path}=  commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
${swconfig_from_path}=  commissionings/Krakow/7_7_T01PY002/swconfig.txt
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}    ${CLASSICAL_FAULT_4459}    ${CLASSICAL_FAULT_6328}
@{CUSTOM_ALLOWED_ALARMS}    ${CLASSICAL_FAULT_4459}    ${CLASSICAL_FAULT_6328}

*** Test Cases ***
[1][2.0] CB007835-5G-A_13_ENDC_BiDir_TCP_SU_throughput_3S-2CC-2DL-2UL-2CC-2DL-0UL
##5G+LTE
    [Setup]        Require Ue    ${alias}    capabilities=REAL_ANDROID_UE
    Perform Delta Commissioning On gNB    ${nr_lte}
    Attenuator Setup    ${NSA}

    Attach Ue      ${alias}

    Sleep    35
#    Wait until keyword succeeds     5min   5sec    Validate ue info    ${alias}    NR_STATE   5G_NSA
    Log Ue Info    ${alias}    ALL

    Start Data Transfer     DT_1     ${alias}    DL    protocol=tcp    duration=1200s    packet=8600B
    ...    apn=5gkrk
#    ...    apn=5gsakrk
#    ...    apn=5gkrkpych2
    ...    parallel_streams=4
    ...    max_segment_size=1300
    Sleep    10
    Start Data Transfer     DT_2     ${alias}    UL    protocol=tcp    duration=1200s    packet=8600B
    ...    apn=5gkrk
#    ...    apn=5gsakrk
#    ...    apn=5gkrkpych2
    ...    parallel_streams=4
    ...    max_segment_size=1300
    ...    linux_congestion=cubic

    Await data transfer finish    DT_1
    Await data transfer finish    DT_2
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_1    1100Mbits/sec    50%
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_2    170Mbits/sec    40%

    [Teardown]    Run Keywords    Detach Ue    ${alias}    AND    Attenuator Setup    ${ATT_OFF}

[2][2.0] CB007835-5G-A_13_ENDC_BiDir_TCP_SU_throughput_3S-2CC-2DL-2UL-2CC-2DL-0UL
# 5G
    [Setup]     Require Ue    ${alias}    capabilities=REAL_ANDROID_UE
    Perform Delta Commissioning On gNB    ${nr_only}
    Attenuator Setup    ${NSA}

    Attach Ue    ${alias}
    Sleep    35
#    Wait until keyword succeeds     5min   5sec    Validate ue info    ${alias}    NR_STATE    5G_NSA
    Log Ue Info    ${alias}    ALL

    Start Data Transfer     DT_1     ${alias}    DL    protocol=tcp    duration=1200s    packet=8600B
    ...    apn=5gkrk
    ...    parallel_streams=4
    ...    max_segment_size=1300
    Sleep    10
    Start Data Transfer     DT_2     ${alias}    UL    protocol=tcp    duration=1200s    packet=8600B
    ...    apn=5gkrk
    ...    parallel_streams=4
    ...    max_segment_size=1300
    ...    linux_congestion=cubic

    Await data transfer finish    DT_1
    Await data transfer finish    DT_2
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_1    1200Mbits/sec    40%
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_2    115Mbits/sec    40%

    [Teardown]    Run Keywords    Detach Ue    ${alias}    AND    Attenuator Setup    ${ATT_OFF}


*** Keywords ***
Attenuator Setup
    [Arguments]    ${mode}
    setup_attenuator    attenuator=${tl.attenuator}  alias=att
    set_ports_attenuation    ports=${mode[0]['ports']}      values=${mode[0]['values']}      attenuator_device=att

# Suite Setup
# 	gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
# 	Common Suite Setup With Commissioning

