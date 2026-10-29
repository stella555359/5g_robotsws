*** Settings ***
Documentation
    ...  TC is blocking one LTE cell and waits until counters from this time interval are
    ...  generated in WebEM and NetAct.
    ...  All counters from 'LTE cell availability' measurement must have the same value.
    ...  In the end, LTE cell is unblocked and TC waits until it is operational.

Resource  ../../common_resources/ca_PM_general.robot


*** Keywords ***
TC__PM__LTE_Cell_Availability
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  *******************
    ...  History of changes
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - Adapt PM test cases from robotlte

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-jakub.bielawski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT

    Step0: TC Variables
    Step1: Block First LTE Cell
    Step2: Check Counters On ENB And NetAct
    Step3: Unblock LTE Cell


Step0: TC Variables
    ${lte_cells_distnames}  Get Ids For All  LNCEL
    ${first_lncel_id}  Fetch From Right  ${lte_cells_distnames}[0]  -
    Set Test Variable  ${LNCEL_DISTNAME}  ${lte_cells_distnames}[0]
    Set Test Variable  ${LNCEL_ID}  ${first_lncel_id}
    ${counters_id_name_dict}  Create Dictionary  M8020C0=CHNG_TO_CELL_AVAIL  M8020C1=CHNG_TO_CELL_PLAN_UNAVAIL  M8020C2=CHNG_TO_CELL_UNPLAN_UNAVAIL
    ...  M8020C3=SAMPLES_CELL_AVAIL  M8020C4=SAMPLES_CELL_PLAN_UNAVAIL  M8020C5=SAMPLES_CELL_UNPLAN_UNAVAIL  M8020C6=DENOM_CELL_AVAIL
    ...  M8020C7=SAMPLES_CELL_POWER_SAVING  M8020C8=CHNG_TO_CELL_POWER_SAVING  M8020C9=SAMPLES_CELL_RTX_PWR_SAVING
    ...  M8020C10=CHNG_TO_CELL_RTX_PWR_SAVING  M8020C11=SAMPLES_CELL_S1TRANS_FAILURE  M8020C12=CHNG_TO_CELL_S1TRANS_FAILURE
    ...  M8020C13=DEG_RRCSR_REC_PHASE_I  M8020C14=DEG_RRCSR_REC_PHASE_II  M8020C15=DEG_RRCSR_REC_PHASE_III  M8020C16=ABN_ANTRX_REC_PHASE_I
    ...  M8020C17=ABN_ANTRX_REC_PHASE_II  M8020C18=ABN_ANTRX_REC_PHASE_III  M8020C19=DEG_RACHSR_REC_PHASE_I  M8020C20=DEG_RACHSR_REC_PHASE_II
    ...  M8020C21=DEG_RACHSR_REC_PHASE_III  M8020C22=DEG_RRCATMP_REC_PHASE_I  M8020C23=DEG_RRCATMP_REC_PHASE_II  M8020C24=DEG_RRCATMP_REC_PHASE_III
    ...  M8020C26=ABN_ANTTX_REC_PHASE_I  M8020C27=ABN_ANTTX_REC_PHASE_II  M8020C28=ABN_ANTTX_REC_PHASE_III  M8020C29=DEG_S1COM_REC_PHASE_I
    ...  M8020C30=DEG_S1COM_REC_PHASE_II  M8020C31=DEG_S1COM_REC_PHASE_III  M8020C32=DEG_RACHATT_REC_PHASE_I  M8020C33=DEG_RACHATT_REC_PHASE_II
    ...  M8020C34=DEG_RACHATT_REC_PHASE_III  M8020C35=LTE_DSS_CELL_WAIT_NR_DSS_CELL
    Set Test Variable  ${COUNTERS_ID_NAME_DICT}
    ${lnbts_id}  Admin Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    ${pmrnl_obj}  Query Infomodel  get object //PMRNL_A-*
    Set Test Variable  ${CELL_AVAIL_INTERVAL}  ${pmrnl_obj}[mtCellAvailability]


Step1: Block First LTE Cell
    Log  \nStep1: Block first LTE cell  console=true
    coam.Block Cell  dist_name=${LNCEL_DISTNAME}  timeout=300
    Assert  LNCEL  ${LNCEL_DISTNAME}  blockingState=${BLOCKED}, operationalState=${DISABLED}  timeout=300
    Sleep Until New Cycle  ${CELL_AVAIL_INTERVAL}


Step2: Check Counters On ENB And NetAct
    Log  \nStep2: Check counters on eNB and NetAct  console=true
    Sleep Until New Cycle  ${CELL_AVAIL_INTERVAL}
    Sleep  1min  TC will wait until counters are fully loaded.
    ${enb_counters}  Get Counters Info  timeout=300
    ${enb_lnbts_counters}  Set Variable  ${enb_counters}[BTS][MRBTS-${BTS_ID}][LNBTS-${LNBTS_ID}]
    ${enb_cell_avail_counters}  Set Variable  ${enb_lnbts_counters}[LNCEL-${LNCEL_ID}][MCC-244][MNC-08][LTE_Cell_Avail]
    ${counters_ids_from_enb}  Get Dictionary Keys  ${enb_cell_avail_counters}

    ${netact_lncel_counters}  netact.Get PM Counters  technology=LNBTS-NSN LTE Base Transceiver Station  measurement=LTE Cell Availability
    ...  counters=ALL  filter_by=LNCEL  mo_names=${MRBTS_DN}/LNBTS-${LNBTS_ID}/LNCEL-${LNCEL_ID}  object_aggregation=PLMN  time_aggregation=RAW
    ...  time_filter=today
    ${netact_cell_avail_last_interval}  Set Variable  ${netact_lncel_counters}[-1]

    FOR  ${counter}  IN  @{counters_ids_from_enb}
        ${last_value}  Get Last Value From Dictionary For Specific Counter  ${enb_cell_avail_counters}[${counter}]
        ${key}  Set Variable  ${COUNTERS_ID_NAME_DICT}[${counter}]
        ${status}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${last_value}  ${netact_cell_avail_last_interval}[${key}]
        Run Keyword If  not ${status}
        ...  Set Test Failed  ${COUNTERS_ID_NAME_DICT}[${counter}] (${counter}) has different value in WebEM and NetAct.
    END


Step3: Unblock LTE Cell
    Log  \nStep3: Unblock LTE cell  console=true
    Unblock LTE Cell If Needed


Unblock LTE Cell If Needed
    ${lte_cell_is_blocked}  Run Keyword And Return Status
    ...  Assert  LNCEL  ${LNCEL_DISTNAME}  blockingState=${BLOCKED}
    Return From Keyword If  not ${lte_cell_is_blocked}
    coam.Unblock Cell  dist_name=${LNCEL_DISTNAME}  timeout=300
    Assert  LNCEL  ${LNCEL_DISTNAME}  blockingState=${UNBLOCKED}, operationalState=${ENABLED}  timeout=300


TC Setup
    Common Test Setup  tc_name=PM__LTE_Cell_Availability
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Unblock LTE Cell If Needed
    Teardown NetAct
    Common Test Teardown
