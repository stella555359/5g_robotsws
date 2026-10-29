*** Settings ***
Documentation
    ...  This TC is performing DL and UL data transfer for 10 seconds.
    ...  It waits until new counters are reported in WebEM.
    ...  MAX_TPUT_PDCP_DL_ENB (M8049C1), MAX_TPUT_PDCP_UL_ENB (M8049C2), MAX_TPUT_PDCP_DL_UL_ENB (M8049C3)
    ...  and PDCP_DATA_RATE_MAX_DL (M8012C25) counters are checked based on DL and UL throughput.
    ...  Each value from WebEM report should be greater than maximum throughput returned by DL and UL
    ...  operations.

Resource  ../../common_resources/sbts_ue.robot
Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${UE_ALIAS}  UE_LTE
${PS_DURATION}  10s
${MIN_LTE_THROUGHPUT_UPLINK}  120 Mbits/sec
${MIN_LTE_THROUGHPUT_DOWNLINK}  120 Mbits/sec


*** Keywords ***
TC__PM__LTE_DL_UL_Throughput_Check
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.int.net.nokia.com/browse/TAT-27425
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  26.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27425 - Initial TAT creation
    ...  13.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28611 - Change name for sbts ue resource
    ...  12.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29225 - Add packet parameter to uplink data transfer
    ...  11.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29540 - Set mtCellThruput to 15min before test starts
    ...  03.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29518 - Start proxy server in case it's not

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT

    Step0: TC Preconditions
    Step1: Make PS Downlink And Uplink Calls
    Step2: Check Counters


Step0: TC Preconditions
    ${ue_details}  Get UE For Technology  LTE_only
    ssh.Connect To  ${ue_details.ssh_connection_details.addr}  ${ue_details.ssh_connection_details.username}
    ...  ${ue_details.ssh_connection_details.password}
    ${port}  Get Port For Proxy Server
    ${command}  ssh.Execute  ss -tulnp | grep :${port}  timeout=10s
    ${listening_status}  Run Keyword And Return Status  Should Contain  ${command}  ${ue_details.ssh_connection_details.addr}:${port}
    IF  '${listening_status}' == 'False'  Start Proxy Server  ue_details=${ue_details}  port=${port}  network_interface=--network_interface eno1

    ${cells_ids}  Get Ids For LTE Cells
    Require Ue  ${UE_ALIAS}  capabilities=LTE_only
    Attach UE If Needed  ${UE_ALIAS}  ${cells_ids}

    ${lncel_id}  Get LNCEL Id For UE
    ${lnbts_id}  Admin Get LNBTS ID
    Set Test Variable  ${LNCEL_ID}
    Set Test Variable  ${LNBTS_ID}

    Set Parameter To New Value  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/PMRNL-1  mtCellThruput  15min
    Set Test Variable  ${INTERVAL_TO_WAIT}  15

    [Teardown]  ssh.Disconnect


Step1: Make PS Downlink And Uplink Calls
    Log  \nStep1: Make PS Downlink And Uplink Calls  console=true
    Sleep Until New Cycle  ${INTERVAL_TO_WAIT}

    Check If UE Has IP Address  ${UE_ALIAS}
    Start Data Transfer  DT_DL  ${UE_ALIAS}  direction=dl  duration=${PS_DURATION}  protocol=udp  packet=1000
    ...  throughput=${MIN_LTE_THROUGHPUT_DOWNLINK}
    Await Data Transfer Finish  DT_DL
    Log  DL data transfer was performed for ${PS_DURATION} seconds.  console=true

    Check If UE Has IP Address  ${UE_ALIAS}
    Start Data Transfer  DT_UL  ${UE_ALIAS}  direction=ul  duration=${PS_DURATION}  protocol=udp  packet=1000  iperf_len=1000
    ...  throughput=${MIN_LTE_THROUGHPUT_UPLINK}
    ${data_transfer}  Await Data Transfer Finish  DT_UL
    Log  UL data transfer was performed for ${PS_DURATION} seconds.  console=true

    ${statistics_dl}  Get Data Transfer Statistics  DT_DL
    ${statistics_dl}  Fetch From Right  ${statistics_dl}  ;
    ${statistics_dl}  Split String  ${statistics_dl}  ,
    ${expected_max_dl_tput}  Evaluate  int(max(${statistics_dl}))/1000

    ${statistics_ul}  Get Data Transfer Statistics  DT_UL
    ${statistics_ul}  Fetch From Right  ${statistics_ul}  ;
    ${statistics_ul}  Split String  ${statistics_ul}  ,
    ${expected_max_ul_tput}  Evaluate  int(max(${statistics_ul}))/1000

    Set Test Variable  ${EXPECTED_MAX_DL_TPUT}
    Set Test Variable  ${EXPECTED_MAX_UL_TPUT}

    [Teardown]  Run Keyword And Ignore Error  Stop Proxy Server


Step2: Check Counters
    Log  \nStep2: Check Counters  console=true
    Sleep Until New Cycle  ${INTERVAL_TO_WAIT}
    Sleep  1min  TC waits until counters are fully loaded.
    ${enb_counters}  Get Counters Info  timeout=300
    ${enb_lnbts_counters}  Set Variable  ${enb_counters}[BTS][MRBTS-${BTS_ID}][LNBTS-${LNBTS_ID}]

    ${si_monitoring_counters}  Set Variable  ${enb_lnbts_counters}[LTE_Sales_Item_Monitoring]
    ${max_dl_tput_enb}  Get Last Value From Dictionary For Specific Counter  ${si_monitoring_counters}[M8049C1]
    ${max_ul_tput_enb}  Get Last Value From Dictionary For Specific Counter  ${si_monitoring_counters}[M8049C2]
    ${max_dl_plus_ul_tput_enb}  Get Last Value From Dictionary For Specific Counter  ${si_monitoring_counters}[M8049C3]

    ${cell_throughput_counters}  Set Variable  ${enb_lnbts_counters}[LNCEL-${LNCEL_ID}][MCC-244][MNC-08][LTE_Cell_Throughput]
    ${max_dl_tput_cell}  Get Last Value From Dictionary For Specific Counter  ${cell_throughput_counters}[M8012C25]

    ${expected_max_dl_plus_ul_enb}  Evaluate  max(${EXPECTED_MAX_DL_TPUT},${EXPECTED_MAX_UL_TPUT})

    Should Be True  ${max_dl_tput_enb} >= ${EXPECTED_MAX_DL_TPUT}  MAX_TPUT_PDCP_DL_ENB (M8049C1) counter has unexpected value.
    Should Be True  ${max_ul_tput_enb} >= ${EXPECTED_MAX_UL_TPUT}  MAX_TPUT_PDCP_UL_ENB (M8049C2) counter has unexpected value.

    Should Be True  ${max_dl_plus_ul_tput_enb} >= ${expected_max_dl_plus_ul_enb}  MAX_TPUT_PDCP_DL_UL_ENB (M8049C3) counter has unexpected value.

    Should Be True  ${max_dl_tput_cell} >= ${EXPECTED_MAX_DL_TPUT}  PDCP_DATA_RATE_MAX_DL (M8012C25) counter has unexpected value.


Get LNCEL Id For UE
    ${ue_cell_id}  Get UE Info  ${UE_ALIAS}  CELL_ID
    ${info_lte_cells}  Get Parameters For All  LNCEL
    FOR  ${cell}  IN  @{info_lte_cells}
        ${eutra_cell_id}  Get From Dictionary  ${cell}  eutraCelId
        ${eutra_cell_id}  Convert To String  ${eutra_cell_id}
        Exit For Loop If  '${eutra_cell_id}'=='${ue_cell_id}'
    END
    ${lncel_id}  Fetch From Right  ${cell}[id]  -

    [Return]  ${lncel_id}


TC Setup
    Common Test Setup  tc_name=PM__LTE_DL_UL_Throughput_Check


TC Teardown
    Common Test Teardown
