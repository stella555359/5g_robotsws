*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS24R3    tl-7_5_UTE5G402T2405
Resource          ./resources/CB013303_resource.robot

*** Variables ***
${EMIL_FLAG}    False

*** Test Cases ***
CB013303_SR_C1_14_Check NRPDSCHBRLA and NRPUSCHBRLA counters on PCell and NRPDSCHBRLA on SCells during DL CA is active
    clear counter files    wait=False
    adjust pa all ports max value

    log    step: check peak throughput    console=True
    adjust pa for cell    cell_id=11    value=0
    # prepare and attach UE
    attach and check peak tput    cell_id=11

    log    step: add 2scells + adjust PA, la from cell    console=True
    adjust pa for cell    cell_id=31    value=0    # cell31 and cell32 share same RRU ports
    # start ul and dl traffic    send_traffic_ul=200M    send_traffic_dl=600M
    start to capture gnb ttitrace    tag=1_attach    cell_id=11,31,32
    adjust pa stepwise for cell    cell_id=11    start_value=20    end_value=50    step=5
    adjust pa stepwise for cell    cell_id=31    start_value=20    end_value=50    step=5
    stop capture gnb ttitrace   tag=1_attach
    ${counters}    combine lists
    ...    ${CELL11_PDSCH_PRFL1_NOT_INCREASE}    ${CELL11_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL11_PUSCH_PRFL1_NOT_INCREASE}    ${CELL11_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL31_PDSCH_PRFL1_NOT_INCREASE}    ${CELL31_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL31_PUSCH_PRFL1_NOT_INCREASE}    ${CELL31_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL32_PDSCH_PRFL1_NOT_INCREASE}    ${CELL32_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL32_PUSCH_PRFL1_NOT_INCREASE}    ${CELL32_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}

    log    step: add 5qi9, la from NRPDSCHBRLA-1 and NRPUSCHBRLA-1    console=True
    clear counter files    wait=False
    add 5qi bearer    5qi=9
    capture gnb ttitrace for a while    tag=2_add_5qi9    cell_id=11,31,32    decode_flag=False
    ${counters}    combine lists
    ...    ${CELL11_PDSCH_PRFL1_INCREASE}        ${CELL11_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL11_PUSCH_PRFL1_INCREASE}        ${CELL11_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL31_PDSCH_PRFL1_INCREASE}        ${CELL31_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL31_PUSCH_PRFL1_NOT_INCREASE}    ${CELL31_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL32_PDSCH_PRFL1_INCREASE}        ${CELL32_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL32_PUSCH_PRFL1_NOT_INCREASE}    ${CELL32_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}
    check ibler based on counters    cell_id=11    phy_prfl=PDSCH_PRFL1    target_bler=5
    check ibler based on counters    cell_id=11    phy_prfl=PUSCH_PRFL1    target_bler=5
    check ibler based on counters    cell_id=31    phy_prfl=PDSCH_PRFL1    target_bler=5
    check ibler based on counters    cell_id=32    phy_prfl=PDSCH_PRFL1    target_bler=5

    log    step: add 5qi8, la from NRPDSCHBRLA-2 and NRPUSCHBRLA-2    console=True
    clear counter files    wait=False
    add 5qi bearer    5qi=8
    capture gnb ttitrace for a while    tag=3_add_5qi8    cell_id=11,31,32    decode_flag=False
    ${counters}    combine lists
    ...    ${CELL11_PDSCH_PRFL1_NOT_INCREASE}    ${CELL11_PDSCH_PRFL2_INCREASE}
    ...    ${CELL11_PUSCH_PRFL1_NOT_INCREASE}    ${CELL11_PUSCH_PRFL2_INCREASE}
    ...    ${CELL31_PDSCH_PRFL1_NOT_INCREASE}    ${CELL31_PDSCH_PRFL2_INCREASE}
    ...    ${CELL31_PUSCH_PRFL1_NOT_INCREASE}    ${CELL31_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL32_PDSCH_PRFL1_NOT_INCREASE}    ${CELL32_PDSCH_PRFL2_INCREASE}
    ...    ${CELL32_PUSCH_PRFL1_NOT_INCREASE}    ${CELL32_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}
    check ibler based on counters    cell_id=11    phy_prfl=PDSCH_PRFL2    target_bler=8
    check ibler based on counters    cell_id=11    phy_prfl=PUSCH_PRFL2    target_bler=8
    check ibler based on counters    cell_id=31    phy_prfl=PDSCH_PRFL2    target_bler=8
    check ibler based on counters    cell_id=32    phy_prfl=PDSCH_PRFL2    target_bler=8

    log    step: release 5qi8 and 5qi9, la from cell    console=True
    clear counter files    wait=False
    del 5qi bearer    5qi=8
    del 5qi bearer    5qi=9
    capture gnb ttitrace for a while    tag=4_del_5qi8_5qi9    cell_id=11,31,32    decode_flag=False
    ${counters}    combine lists
    ...    ${CELL11_PDSCH_PRFL1_NOT_INCREASE}    ${CELL11_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL11_PUSCH_PRFL1_NOT_INCREASE}    ${CELL11_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL31_PDSCH_PRFL1_NOT_INCREASE}    ${CELL31_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL31_PUSCH_PRFL1_NOT_INCREASE}    ${CELL31_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL32_PDSCH_PRFL1_NOT_INCREASE}    ${CELL32_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL32_PUSCH_PRFL1_NOT_INCREASE}    ${CELL32_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}
    Report KPI Report To Scout    template_id=1941
    [Teardown]    Run Keywords    Stop UL And DL traffic
    ...                           Detach UE
    ...                           Common Test Teardown And Stop Capture Logs


*** Keywords ***
check ibler based on counters
    [Arguments]    ${cell_id}    ${phy_prfl}    ${target_bler}
    ${phy_type}    ${prfl}    Split String    ${phy_prfl}    _
    ${counters_value}    create list
    ...    last NRCELL-${cell_id}:${${phy_type}_INI_TX_BRD_${prfl}}
    ...    last NRCELL-${cell_id}:${${phy_type}_SUCC_INI_TX_BRD_${prfl}}
    ${int_tx}    ${succ_int_tx}    get counters value     ${counters_value}    wait=False
    ${iber}    evaluate    ${${int_tx}-${succ_int_tx}}/${int_tx}*100
    ${status}    run keyword and return status    should be true    ${${target_bler}-2}<${iber}<${${target_bler}+2}
    run keyword if    not ${status}    log    ${${target_bler}-2}<${iber}<${${target_bler}+2} not satisfied    level=WARN

