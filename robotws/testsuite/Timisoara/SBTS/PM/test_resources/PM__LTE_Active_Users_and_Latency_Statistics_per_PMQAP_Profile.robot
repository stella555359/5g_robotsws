*** Settings ***
Documentation
    ...  TC is checking counters from 'LTE active users and latency statistics per PMQAP profile'
    ...  measurement to have the same values in WebEM and Netact.
    ...  Before checking their values, TC is waiting until 2 new cycles of counters to be generated
    ...  based on mtActUsersLatencyPMQAPProfile interval to compare the values from the time interval when
    ...  TC started.

Resource  ../../common_resources/ca_PM_general.robot


*** Keywords ***
TC__PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  *******************
    ...  History of changes
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - Adapt PM test cases from robotlte

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-jakub.bielawski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT

    Step0: TC Variables
    Step1: Check Counters For First LTE Cell


Step0: TC Variables
    ${lte_cells_distnames}  Get Ids For All  LNCEL
    ${first_lncel_id}  Fetch From Right  ${lte_cells_distnames}[0]  -
    Set Test Variable  ${LNCEL_DISTNAME}  ${lte_cells_distnames}[0]
    Set Test Variable  ${LNCEL_ID}  ${first_lncel_id}
    ${counters_id_name_dict}  Create Dictionary  M8046C0=MAX_ACT_UE_CELL_PROFILE  M8046C1=AVG_ACT_UE_CELL_PROFILE
    ...  M8046C2=AVG_PDCP_RET_DL_DEL_PROFILE  M8046C3=AVG_HARQ_DURATION_PROFILE  M8046C4=MAX_PDCP_RET_DL_DEL_PROFILE
    ...  M8046C5=UE_DRB_BUF_DL_DATA_PROFILE
    Set Test Variable  ${COUNTERS_ID_NAME_DICT}
    ${lnbts_id}  Admin Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    ${pmrnl_obj}  Query Infomodel  get object //PMRNL_A-*
    Set Test Variable  ${LATENCY_PMQAP_PROFILE_INTERVAL}  ${pmrnl_obj}[mtActUsersLatencyPMQAPProfile]


Step1: Check Counters For First LTE Cell
    Log  \nStep1: Check counters for first LTE cell  console=true
    Sleep Until New Cycle  ${LATENCY_PMQAP_PROFILE_INTERVAL}
    Sleep Until New Cycle  ${LATENCY_PMQAP_PROFILE_INTERVAL}
    Sleep  1min  TC will wait until counters are fully loaded.
    ${enb_counters}  Get Counters Info  timeout=300
    ${enb_lnbts_counters}  Set Variable  ${enb_counters}[BTS][MRBTS-${BTS_ID}][LNBTS-${LNBTS_ID}]
    ${meas_name}  Set Variable  LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile
    ${enb_latency_pmqap_profile_counters}  Set Variable  ${enb_lnbts_counters}[LNCEL-${LNCEL_ID}][MCC-244][MNC-08][PMQAP-1][${meas_name}]
    ${counters_ids_from_enb}  Get Dictionary Keys  ${enb_latency_pmqap_profile_counters}

    ${netact_lncel_counters}  netact.Get PM Counters  technology=LNBTS-NSN LTE Base Transceiver Station
    ...  measurement=LTE Active Users and Latency Statistics per PMQAP Profile  counters=ALL  filter_by=LNCEL
    ...  mo_names=${MRBTS_DN}/LNBTS-${LNBTS_ID}/LNCEL-${LNCEL_ID}  object_aggregation=PLMN  time_aggregation=RAW  time_filter=today
    ${netact_latency_pmqap_profile_last_interval}  Set Variable  ${netact_lncel_counters}[-1]

    FOR  ${counter}  IN  @{counters_ids_from_enb}
        ${last_value}  Get Last Value From Dictionary For Specific Counter  ${enb_latency_pmqap_profile_counters}[${counter}]
        ${key}  Set Variable  ${COUNTERS_ID_NAME_DICT}[${counter}]
        ${status}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${last_value}  ${netact_latency_pmqap_profile_last_interval}[${key}]
        Run Keyword If  not ${status}
        ...  Set Test Failed  ${COUNTERS_ID_NAME_DICT}[${counter}] (${counter}) has different value in WebEM and NetAct.
    END


TC Setup
    Common Test Setup
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
