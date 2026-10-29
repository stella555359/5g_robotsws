*** Settings ***
Documentation
    ...  TC is checking counters from 'LTE intra eNB handover extension' measurement
    ...  to have the same values in WebEM and Netact.
    ...  Before checking their values, TC is waiting until 2 new cycles of counters to be generated
    ...  based on mtIntraeNBHoExt interval to compare the values from the time interval when
    ...  TC started.

Resource  ../../common_resources/ca_PM_general.robot


*** Keywords ***
TC__PM__LTE_Intra_eNB_Handover_Extension
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
    ${counters_id_name_dict}  Create Dictionary  M8071C0=INTRA_ENB_IAF_HO_PREP  M8071C1=F_INTRA_ENB_IAF_HO_PREP_AC
    ...  M8071C2=F_INTRA_ENB_IAF_HO_PREP_TMR  M8071C3=F_INTRA_ENB_IAF_HO_PREP_OTH  M8071C4=RRE_S_SENB_INTRA_ENB_IAF_HO
    ...  M8071C5=RRE_O_SENB_INTRA_ENB_IAF_HO  M8071C6=RRE_O_OENB_INTRA_ENB_IAF_HO  M8071C7=RRE_T_SENB_INTRA_ENB_IAF_HO
    ...  M8071C8=DOUBLE_S1_INTRA_ENB_IAF_HO  M8071C9=INTRA_ENB_IAF_HO_ATT  M8071C10=INTRA_ENB_IAF_HO_SUCC  M8071C11=INTRA_ENB_IAF_HO_FAIL_TMR
    ...  M8071C24=INTRA_ENB_IEF_LB_HO_PREP  M8071C25=INTRA_ENB_IEF_LB_HO_ATT  M8071C26=INTRA_ENB_IEF_LB_HO_SUCC  M8071C27=INTRA_ENB_IEF_LEQ_HO_PREP
    ...  M8071C28=INTRA_ENB_IEF_LEQ_HO_ATT  M8071C29=INTRA_ENB_IEF_LEQ_HO_SUCC
    Set Test Variable  ${COUNTERS_ID_NAME_DICT}
    ${lnbts_id}  Admin Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    ${pmrnl_obj}  Query Infomodel  get object //PMRNL_A-*
    Set Test Variable  ${INTRA_ENB_HO_EXT_INTERVAL}  ${pmrnl_obj}[mtIntraeNBHoExt]


Step1: Check Counters For First LTE Cell
    Log  \nStep1: Check counters for first LTE cell  console=true
    Sleep Until New Cycle  ${INTRA_ENB_HO_EXT_INTERVAL}
    Sleep Until New Cycle  ${INTRA_ENB_HO_EXT_INTERVAL}
    Sleep  1min  TC will wait until counters are fully loaded.
    ${enb_counters}  Get Counters Info  timeout=300
    ${enb_lnbts_counters}  Set Variable  ${enb_counters}[BTS][MRBTS-${BTS_ID}][LNBTS-${LNBTS_ID}]
    ${enb_ho_ext_counters}  Set Variable  ${enb_lnbts_counters}[LNCEL-${LNCEL_ID}][MCC-244][MNC-08][LTE_Intra_eNB_Handover_Extension]
    ${counters_ids_from_enb}  Get Dictionary Keys  ${enb_ho_ext_counters}

    ${netact_lncel_counters}  netact.Get PM Counters  technology=LNBTS-NSN LTE Base Transceiver Station  measurement=LTE Intra eNB Handover Extension
    ...  counters=ALL  filter_by=LNCEL  mo_names=${MRBTS_DN}/LNBTS-${LNBTS_ID}/LNCEL-${LNCEL_ID}  object_aggregation=PLMN  time_aggregation=RAW
    ...  time_filter=today
    ${netact_ho_ext_last_interval}  Set Variable  ${netact_lncel_counters}[-1]

    FOR  ${counter}  IN  @{counters_ids_from_enb}
        ${last_value}  Get Last Value From Dictionary For Specific Counter  ${enb_ho_ext_counters}[${counter}]
        ${key}  Set Variable  ${COUNTERS_ID_NAME_DICT}[${counter}]
        ${status}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${last_value}  ${netact_ho_ext_last_interval}[${key}]
        Run Keyword If  not ${status}
        ...  Set Test Failed  ${COUNTERS_ID_NAME_DICT}[${counter}] (${counter}) has different value in WebEM and NetAct.
    END


TC Setup
    Common Test Setup
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
