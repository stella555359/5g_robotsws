*** Settings ***
Documentation
...  author: Pawel Wisniewski, Mikolaj Guszpit
...  contact:       pawel.1.wisniewski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com
...  Description:   Test Cases for CB007090 feature: This sector will be filled in the future.
...  Topology: CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1_AHFIB_3xAHLOA_20B

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/btslog_checker.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.l2_trace    WITH NAME    l2_trace
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.PmUtils    WITH NAME    pu
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot

Suite Setup     setup_teardown.Get BTS id and set as suite variable

Test Setup      Get UEs  ${MULTI_UE}  ue_capabilities=IPHONE

Test Teardown   Run Keywords
...             Unlock all locked cells                                         AND
...             run keyword and ignore error  Stop data transfers for all ues   AND
...             Add Scout Data Info To Testcase                                 AND
...             Collect snapshot if test failed


*** Variables ***
${TIMER}        26 min
${MSG}          Lack of PDCCH detected
${COUNTERS_TO_GET}     M55335C05001,M55335C05002
${counter_to_get}      M55335C05007
${SCF_PATH_3RD_TC}   ${OUTPUT DIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/7090_3rd_TC.xml
${SCF_PATH_4TH_TC}   ${OUTPUT DIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/7090_4th_TC.xml
${SCF_PATH_5TH_TC}   ${OUTPUT DIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/7090_5th_TC.xml
${COUNTER_DICT}  M55335C05001,M55335C05002,M55335C05006,M55335C05007,M55335C05008
@{MULTI_UE}   UE_1
${counters_interval}  5min
${test_cell}  1

*** Test Cases ***
[1]CB007090-C_11_NSA_CCE_STARVATION_COUNTERS
    [Tags]  NSA
    Log to console   __Locking unnecessary cells
    Lock all cells except first
    Log to console   __Cells locked
    ${first_cell_id}   Get global cell id of first cell

    detach ues from cell  ${MULTI_UE}
    attach ues to cell  ${MULTI_UE}

    run keyword and ignore error    Start ULDL for UEs
    ...    ${MULTI_UE}
    ...    duration=960s
    ...    dl_throughput=1024 kbits/sec
    ...    ul_throughput=1024 kbits/sec
    ...    protocol=tcp

    Wait for counters  5 min
    run keyword and ignore error    Stop data transfers for all ues
    run keyword and ignore error  detach ues from cell  ${MULTI_UE}


    &{counters}    Get counters    ${counter_to_get}
    &{last_counters}   pu.get last counters values
    ...  ${counters['BTS']['MRBTS-${MRBTS_5G_ID}']['NRBTS-${MRBTS_5G_ID}']['NRCELL-${test_cell}']['PDCCH']}
    pu.check counters are greater than zero    ${last_counters}


[1]CB007090-C.B1_1_NSA_FDD_MultiUEs_UL.DL_traffic_1symbol_PDCCH
    [Tags]  NSA
    Perform 7090 SCF commissioning  TC2
    Log to console   __Locking unnecessary cells
    Lock all cells except first
    Log to console   __Cells locked
    ${first_cell_id}   Get global cell id of first cell
    Detach UEs from cell   ${MULTI_UE}
    Attach UEs to cell   ${MULTI_UE}
    Start ULDL for UEs   ue_aliases=${MULTI_UE}   duration=3600s   dl_throughput=1 Mbits/sec   ul_throughput=500 kbits/sec
    Wait for counters  ${TIMER}
    &{counter_values}    Get counters    ${COUNTER_DICT}
    &{counter_values_lasts}   pu.get last counters values   ${counter_values['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    @{counter_list}  Create list  M55335C05001  M55335C05002  M55335C05006  M55335C05007  M55335C05008
    Get counters from dictionary   ${counter_values_lasts}   @{counter_list}
    Check counters value 7090-C-B1_1 feature on
    Get average throughputs with feature on
    Stop data transfers for all ues
    Feature off   pdcchBlockingThreshold=30   pdcchFreeThreshold=50
    Detach UEs from cell   ${MULTI_UE}
    Attach UEs to cell   ${MULTI_UE}
    Start ULDL for UEs   ue_aliases=${MULTI_UE}   duration=3600s   dl_throughput=1 Mbits/sec   ul_throughput=500 kbits/sec
    Wait for counters  ${TIMER}
    &{counter_values}    Get counters    ${counter_dict}
    &{counter_values_lasts}   pu.get last counters values   ${counter_values['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    Get counters from dictionary   ${counter_values_lasts}   @{counter_list}
    Check counters value 7090-C-B1_1 feature off
    Get average throughputs with feature off
    Compare throughputs

[1]CB007090-C.B2_3_NSA_FDD_MultiUEs_UL.DL_traffic_2symbols_PDCCH_AL4
    [Tags]  NSA
    Perform 7090 SCF commissioning  TC3
    Verify if all cells are onair
    Log to console   __Locking unnecessary cells
    Lock all cells except first
    Log to console   __Cells locked
    ${first_cell_id}   Get global cell id of first cell
    Detach UEs from cell   ${MULTI_UE}
    Attach UEs to cell   ${MULTI_UE}
    Start different ULDL tput on all UEs
    Wait for counters  ${TIMER}
    &{counter_values}    Get counters    ${COUNTER_DICT}
    &{counter_values_lasts}   pu.get last counters values   ${counter_values['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    @{counter_list}  Create list  M55335C05001  M55335C05002  M55335C05006  M55335C05007  M55335C05008
    Get counters from dictionary   ${counter_values_lasts}   @{counter_list}
    Check counters value 7090-C-B2_3_NSA feature on
    Get average throughputs with feature on
    Stop data transfers for all ues
    Feature off   pdcchBlockingThreshold=30   pdcchFreeThreshold=50
    Detach UEs from cell   ${MULTI_UE}
    Attach UEs to cell   ${MULTI_UE}
    Start different ULDL tput on all UEs
    Wait for counters  ${TIMER}
    &{counter_values}    Get counters    ${COUNTER_DICT}
    &{counter_values_lasts}   pu.get last counters values   ${counter_values['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    Get counters from dictionary   ${counter_values_lasts}   @{counter_list}
    Check counters value 7090-C-B2_3_NSA feature off
    Get average throughputs with feature off
    Compare different throughputs

[1]CB007090-C.B1_2_SA_FDD_MultiUEs_UL.DL_traffic_1symbol_PDCCH
    [Tags]  SA
    Perform 7090 SCF commissioning  TC4
    Verify if all cells are onair
    Log to console   __Locking unnecessary cells
    Lock all cells except first
    Log to console   __Cells locked
    ${first_cell_id}   Get global cell id of first cell
    Detach UEs from cell   ${MULTI_UE}
    Attach UEs to cell   ${MULTI_UE}
    Start ULDL for UEs   ue_aliases=${MULTI_UE}   duration=3600s   dl_throughput=1 Mbits/sec   ul_throughput=500 kbits/sec
    Wait for counters  ${TIMER}
    &{counter_values}    Get counters    ${COUNTER_DICT}
    &{counter_values_lasts}   pu.get last counters values   ${counters_values['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    @{counter_list}  Create list  M55335C05001  M55335C05002  M55335C05006  M55335C05007  M55335C05008
    Get counters from dictionary  ${counter_values_lasts}   @{counter_list}
    ${M55335C05001_ON}=   Set variable   ${M55335C05001}
    ${M55335C05002_ON}=   Set variable   ${M55335C05002}
    Check counters value 7090-C-B1_2 feature on
    Get average throughputs with feature on
    Stop data transfers for all ues
    Feature off   pdcchBlockingThreshold=30   pdcchFreeThreshold=50
    Detach UEs from cell   ${MULTI_UE}
    Attach UEs to cell   ${MULTI_UE}
    Start ULDL for UEs   ue_aliases=${MULTI_UE}   duration=3600s   dl_throughput=1 Mbits/sec   ul_throughput=500 kbits/sec
    Wait for counters  ${TIMER}
    &{counter_values}    Get counters    ${COUNTER_DICT}
    &{counter_values_lasts}   pu.get last counters values   ${counters_values['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    Get counters from dictionary  ${counter_values_lasts}   @{counter_list}
    Check counters value 7090-C-B1_2 & 7090-C-B2_3_SA feature off
    Get average throughputs with feature off
    Compare throughputs

[1]CB007090-C.B2_3_SA_FDD_MultiUEs_UL.DL_traffic_2symbols_PDCCH_AL4
    [Tags]  SA
    Perform 7090 SCF commissioning  TC5
    Verify if all cells are onair
    Log to console   __Locking unnecessary cells
    Lock all cells except first
    Log to console   __Cells locked
    ${first_cell_id}   Get global cell id of first cell
    Detach UEs from cell   ${MULTI_UE}
    Attach UEs to cell   ${MULTI_UE}
    Start ULDL for UEs   ue_aliases=${MULTI_UE}   duration=3600s   dl_throughput=200 Mbits/sec   ul_throughput=2000 kbits/sec
    Wait for counters  ${TIMER}
    &{counter_values}    Get counters    ${COUNTER_DICT}
    &{counter_values_lasts}   pu.get last counters values   ${counters_values['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    @{counter_list}  Create list  M55335C05001  M55335C05002  M55335C05006  M55335C05007  M55335C05008
    Get counters from dictionary  ${counter_values_lasts}   @{counter_list}
    ${M55335C05001_ON}=   Set variable   ${M55335C05001}
    ${M55335C05002_ON}=   Set variable   ${M55335C05002}
    Check counters value 7090-C-B2_3_SA feature on
    Get average throughputs with feature on
    Stop data transfers for all ues
    Feature off   pdcchBlockingThreshold=30   pdcchFreeThreshold=50
    Detach UEs from cell   ${MULTI_UE}
    Attach UEs to cell   ${MULTI_UE}
    Start ULDL for UEs   ue_aliases=${MULTI_UE}   duration=3600s   dl_throughput=200 Mbits/sec   ul_throughput=2000 kbits/sec
    Wait for counters  ${TIMER}
    &{counter_values}    Get counters    ${COUNTER_DICT}
    &{counter_values_lasts}   pu.get last counters values   ${counters_values['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    Get counters from dictionary  ${counter_values_lasts}   @{counter_list}
    Check counters value 7090-C-B1_2 & 7090-C-B2_3_SA feature off
    Get average throughputs with feature off
    Compare high throughputs
