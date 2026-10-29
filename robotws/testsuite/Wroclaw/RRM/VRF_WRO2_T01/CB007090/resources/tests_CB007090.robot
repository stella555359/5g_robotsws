*** Settings ***
Documentation
...  author: Pawel Wisniewski, Mikolaj Guszpit
...  contact:       pawel.1.wisniewski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com
...  Description:   Test Cases for CB007090 feature: This sector will be filled in the future.

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/btslog_checker.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.l2_trace    WITH NAME    l2_trace
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.PmUtils    WITH NAME    pu
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot

*** Variables ***
${TIMER}        26 min
${MSG}          Lack of PDCCH detected
${COUNTERS_TO_GET}     M55335C05001,M55335C05002,M55335C05007
${COUNTERS_TO_GET_2}     M55335C05008
${SCF_PATH_3RD_TC}   ${OUTPUT DIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/7090_3rd_TC.xml
${SCF_PATH_4TH_TC}   ${OUTPUT DIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/7090_4th_TC.xml
${SCF_PATH_5TH_TC}   ${OUTPUT DIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/7090_5th_TC.xml
${COUNTER_DICT}  M55335C05001,M55335C05002,M55335C05006,M55335C05007,M55335C05008
@{MULTI_UE}   UE_1   UE_2   UE_3   UE_4

*** Keywords ***
[1]CB007090-C_11_NSA_CCE_STARVATION_COUNTERS
    [Tags]  NSA
    Perform 7090 SCF commissioning  TC1
    Log to console   __Locking unnecessary cells
    Lock all cells except first
    Log to console   __Cells locked
    ${first_cell_id}   Get global cell id of first cell
    Start syslog capture     log_name=SYSLOG_7090.LOG    alias=syslog_7090
    Detach and attach 2 UEs
    Start low ULDL tput  protocol=udp  tput_duration=3600s
    ...                  tput_DL_bandwidth=2024 kbits/sec
    ...                  tput_UL_bandwidth=2024 kbits/sec
    Start low ULDL tput  ue_alias=UE_2  protocol=udp  tput_duration=3600s
    ...                  dt_DL_name=DT_DL_7090_UE_2  dt_UL_name=DT_UL_7090_UE_2
    ...                  tput_DL_bandwidth=2024 kbits/sec
    ...                  tput_UL_bandwidth=2024 kbits/sec
    Wait for counters  16 min
    &{counters}    Get counters    ${COUNTERS_TO_GET}
    &{last_counters}   pu.get last counters values   ${counters['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    &{counters_2}    Get counters    ${COUNTERS_TO_GET_2}
    &{last_counters_2}   pu.get last counters values   ${counters_2['BTS']['CELLS']['NRCELL-${first_cell_id}']['PDCCH']}
    pu.check counters are greater than zero    ${last_counters}
    pu.check counters are zero    ${last_counters_2}
    Stop syslog capture    alias=syslog_7090
    Check if message appeared  ${MSG}  '${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/SYSLOG_7090.LOG'

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
    Check counters value 7090-C-B1_2 & 7090-C-B2_3 feature off
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
    Check counters value 7090-C-B2_3 feature on
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
    Check counters value 7090-C-B1_2 & 7090-C-B2_3 feature off
    Get average throughputs with feature off
    Compare high throughputs
