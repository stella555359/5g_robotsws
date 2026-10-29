*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library        ute_ue
Library        taf.collectors.core
Library        taf.analyzer.pmcounter
Library        taf.collectors.ttitrace_4g    WITH NAME    ttitrace_4g
Resource       ../../resources/ca_IWK.robot
Resource       ../../resources/ca_INTER_RAT.robot

*** Variables ***
${LTE_ANCHOR_CELL_ID}                   # ID of LTE Anchor cell for which LTE4750 will be tested
${LTE_CELL_ID}                          # ID of LTE cell which will be tested
${BLANKED_PUCCH}                        # Value of 'blankedPucch' parameter.
${NR_UE_CAPABILITY}                     # NR UE capability
${LTE_UE_CAPABILITY}                    # LTE UE capability
${EXPECTED_M8029C217_STEP3}             # Expected value of M8029C217 counter STEP3 LTE DL call ongoing
${EXPECTED_M8029C217_STEP7}             # Expected value of M8029C217 counter STEP7 NR DL call ongoing
${EXPECTED_M8029C217_STEP11}            # Expected value of M8029C217 counter STEP11 LTE DL call ongoing
${MCC}                                  # Value of MCC related with PLMN
${MNC}                                  # Value of MNC related with PLMN

*** Keywords ***
TC__IWK__dl_single_user_sharing_ratio_dynamic_adaptation__LTE4750
    Set Tags    CA-INTER_RAT    AUTHOR-igor.kleschenok@nokia.com    OWNER-piotr.1.maj@nokia.com
    ...         MAINTAINER-igor.kleschenok@nokia.com    PHASE-CRT   SW-SBTS20    FEATURE-LTE4750    GROUP_IN_CHARGE-WRO_9_Vrf

    Preconditions
    Step 1: Start LTE DL call in DSS cell
    Step 2: Collect TTI Trace
    Step 3: Collect And Compare Counters
    Step 4: Stop LTE DL Data Transfer
    Step 5: Start NR DL call in DSS cell
    Step 6: Collect TTI Trace Based On NR Call
    Step 7: Collect And Compare Counters
    Step 8: Stop NR DL Data Transfer
    Step 9: Start LTE DL call in DSS cell
    Step 10: Collect TTI Trace
    Step 11: Collect And Compare Counters
    Step 12: Stop LTE DL Data Transfer

Preconditions
    Log  \n=== Preconditions ===  console=True
    Set Test Variables
    Check Preconditions For Test
    Require UE  NR_UE  ${NR_UE_CAPABILITY}
    Require UE  LTE_UE  ${LTE_UE_CAPABILITY}
    Log  \n=== Preconditions passed ===  console=True

Set Test Variables
    Log  \n=== Set Test Variables ===  console=True
    ${LNBTS_ID}=    Get BTS ID From ADMIN
    Set Test Variable  ${LNBTS_ID}
    ${scf_path_enb}  ${parsed_scf_enb}=  Save And Parse SCF  SCF_eNB
    Set Test Variable  ${SCF_PATH_ENB}  ${scf_path_enb}
    Set Test Variable  ${PARSED_SCF_ENB}  ${parsed_scf_enb}
    ${localNeDN_str} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  XPIF  MRBTS-${LNBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...  /p[@name='localNeDN']
    ${nrbts_id} =  Fetch From Right  ${localNeDN_str}  -
    Set Test Variable  ${NRBTS_ID}    ${nrbts_id}
    Set Test Variable  ${SELECT_OUTER_PUSCH_REGION}  (None|UpperEdge)
    Set Test Variable  ${SELECT_PRACH_REGION}    InnerUpperEdge

Check Preconditions For Test
    Log  \n=== Check Preconditions For Test ===  console=True
    Check Element In SCF  ${PARSED_SCF_ENB}  LNBTS  LNBTS-${LNBTS_ID}  /p[@name='actLteNrDss']
    ...  <p name="actLteNrDss">true</p>  dist_name_substring=True
    Check Element In SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${LTE_CELL_ID}  /p[@name='lteNrDssMode']
    ...  <p name="lteNrDssMode">DL_CRS_TDM_UL_FDM</p>  dist_name_substring=True
    Check Element In SCF  ${PARSED_SCF_ENB}  LNCEL_FDD  LNCEL-${LTE_CELL_ID}/  /p[@name='blankedPucch']
    ...  <p name="blankedPucch">${BLANKED_PUCCH}</p>
    Check Element In SCF  ${PARSED_SCF_ENB}  LNCEL_FDD  LNCEL-${LTE_CELL_ID}/
    ...  /p[@name='selectOuterPuschRegion']  <p name="selectOuterPuschRegion">${SELECT_OUTER_PUSCH_REGION}</p>  True
    Check Element In SCF  ${PARSED_SCF_ENB}  APUCCH_FDD  LNCEL-${LTE_CELL_ID}/  /p[@name='selectPrachRegion']
    ...  <p name="selectPrachRegion">${SELECT_PRACH_REGION}</p>
    Check If Element Exists In SCF  ${PARSED_SCF_ENB}  DSSNR  LNCEL-${LTE_CELL_ID}/DSSNR-
    Check Element In SCF  ${PARSED_SCF_ENB}  NRBTS  NRBTS-${NRBTS_ID}  /p[@name='actLteNrDss']
    ...  <p name="actLteNrDss">true</p>  dist_name_substring=True
    Check Element In SCF  ${PARSED_SCF_ENB}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='lteNrDssMode']
    ...  <p name="lteNrDssMode">DL_CRS_TDM_UL_FDM</p>  dist_name_substring=True
    ${gnb_cu_type} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  NRBTS  NRBTS-${NRBTS_ID}  /p[@name='gNbCuType']
    ...  dist_name_substring=True

    Log  All precondition parameters are correct.  console=True


Step ${index}: Start LTE DL call in DSS cell
    Log  \n=== Step ${index}: Start LTE DL call in DSS cell ===  console=True
    ${waiting_time} =  ca_IWK.Count Measurement Period  ${MPLANE_IP}  15    delta=-120
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.
    Log  Prepare UE For Data Transfer  console=True
    Prepare UE For Data Transfer  LTE_UE  ${LTE_CELL_ID}
    Log  Start DL Data Transfer  console=True
    Start Data Transfer  LTE_DT  LTE_UE  dl  throughput=${LTE_DL_THROUGHPUT} Mbits/sec  protocol=tcp
    ...                  max_segment_size=1400  duration=30min  buffer=32M  apn=${APN}
    Sleep  4min  reason=Wait until the call is stable for collect TTI and counters.
    Check Data Transfer Is Alive  LTE_DT

Step ${index}: Collect TTI Trace
    Log  \n=== Step ${index}: Collect TTI Trace ====  console=True
    Log  Collecting of TTI Traces  console=True
    Collect 4G TTI Trace   cell_id=${LTE_CELL_ID}
    ...                    trace_time=5 seconds
    ...                    output_path=${LOG_PATH}/trace

Step ${index}: Collect And Compare Counters
    Log  ==== Step ${index}: Collect And Compare Counters ====  console=True
    ${waiting_time} =  ca_IWK.Count Measurement Period  ${MPLANE_IP}  15    delta=120
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.

    Run Keyword And Continue On Failure  Run Keywords  Wait Until Keyword Succeeds  5x  10s
    ...  Collect PM Counters      ${LOG_PATH}/pm_counters_s${index}    time_interval=30 min  intervals=15
    ...  AND  Compare Counters Values  ${LOG_PATH}/pm_counters_s${index}  M8029C217
    ...  MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}  ${EXPECTED_M8029C217_STEP${index}}  1

Step ${index}: Stop LTE DL Data Transfer
    Log  \n=== Step ${index}: Stop LTE DL Data Transfer ====  console=True
    Stop Data Transfer  LTE_DT

Step 5: Start NR DL call in DSS cell
    Log  \n=== Step 5: Start NR DL call in DSS cell ===  console=True
    ${waiting_time} =  ca_IWK.Count Measurement Period  ${MPLANE_IP}  15    delta=-120
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.
    Log  Prepare UE For Data Transfer  console=True
    Prepare UE For Data Transfer  NR_UE  ${NR_CALL_CELL_ID}
    Log  Start DL Data Transfer  console=True
    Start Data Transfer  NR_DT  NR_UE  dl  throughput=${NR_DL_THROUGHPUT} Mbits/sec  protocol=tcp
    ...                  max_segment_size=1400  duration=30min  buffer=32M  apn=${APN}
    Sleep  4min  reason=Wait until the call is stable for collect TTI and counters.

Step 6: Collect TTI Trace Based On NR Call
    Log  \n==== Step 6: Collect TTI Trace ====  console=True
    Log  Collecting of TTI Traces  console=True
    Run Keyword If  '${NR_UE_CAPABILITY}' == 'NR_NSA'
         ...  Collect 4G TTI Trace   cell_id=${LTE_CELL_ID}
         ...                    trace_time=5 seconds
         ...                    output_path=${LOG_PATH}/trace

Step 8: Stop NR DL Data Transfer
    Log  \n=== Step 8: Stop NR DL Data Transfer ====  console=True
    Stop Datatransfer  NR_DT

TC Setup
    Inter RAT Test Setup

TC Teardown
    Stop Data Transfers For All Ues
    Detach UE  LTE_UE
    Detach UE  NR_UE  timeout=60
    Inter RAT Test Teardown
