*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library     ute_ue
Library     taf.rnc.oms.nwi3
Library     taf.ul.ttitrace_analyzer
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Library     taf.converters.ttitracer
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/ca_INTER_RAT.robot

*** Variables ***
${LTE_CELL_ID}                      # ID of tested LTE cell, that has WL DSS enabled
${NUMBER}       0666002             # Autoresponder

*** Keywords ***
TC__INTER_RAT__DSS_load_increase_low_medium_high__RP002167
    [Documentation]
    ...  Purpose of this test case is to verify WCDMA load change. Operator should change number of data or AMR calls
    ...  and during this procedure BTS should change a load of state. When load is changed then spectrum allocation is also changed.
    ...
    ...  Preconditions:
    ...  - Active DSS WL at least one cell
    ...  - Check below parameters. If BTS configuration is different please set it as below:
    ...    LCELL: actWcdmaLteSharedSpectrum=true
    ...    LCELW: actWcdmaLteSharedSpectrum = Dynamic Shared Spectrum
    ...           wcdmaFilteredBandwidthDL = none
    ...    WNCELG:
    ...           dssLoadFactorDCH = 100
    ...           dssLoadFactorHSDPA = 100
    ...           dssLoadThresholdHigh = 2
    ...           dssLoadThresholdMedium = 1
    ...
    ...  Requirements:
    ...  OM_GEN_SFS_SYSM.6637, SRAN_SFS_Telecom_9, SRAN_SFS_Telecom_10, WBTS_CP_22685, WBTS_CP_22697, WBTS_UP_21054,
    ...  LTE_OPR_REQ_20468, LTE_OPR_REQ_20475, LTE_OPR_REQ_20476
    ...
    ...  Preconditions
    ...  Step 1: Start LTE Data Transfer And Collect TTI Trace
    ...  Step 2: Start WCDMA Data Transfer And Collect TTI Trace
    ...  Step 3: Start WCDMA Voice Call And Collect TTI Trace
    ...  Step 4: Stop WCDMA Data Transfer And Collect TTI Trace
    ...  Step 5: Stop WCDMA Voice Call And Collect TTI Trace
    ...  Step 6: Check The Result
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.04.2020 - https://jiradc.int.net.nokia.com/browse/IWK-43 - initial creation
    ...  - 13.05.2020 - https://jiradc.int.net.nokia.com/browse/IWK-210 - added lte_interface=new to hran_dsp import
    ...  - 25.05.2020 - https://jiradc.int.net.nokia.com/browse/IWK-229 - changed test name from
    ...                 'INTER_RAT__DSS_load_increase_low_medium_high__RP002546' to
    ...                 'INTER_RAT__DSS_load_increase_low_medium_high__RP002167'
    ...  - 21.07.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-378 - changed required UE capabilities
    ...  - 17.12.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-555 - added sleep to 'Collect TTI Trace And Set
    ...                 To Dictionary' so average of totalPrbAvail is not lowered by values of not yet changed load
    ...  - 01.06.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-671 - added packet_size=1400 to keyword 'Start Data Transfer'
    ...  - 08.07.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-693 - 'MAINTAINER' updated
    ...  - 23.03.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-817 - cleared warnings in logs
    ...  - 14.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-905 - modified test and moved it to robotws
    ...  - 22.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-992 - updated whole test case replacing
    ...                 old solutions with new ones
    ...  - 11.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1056 - Replace KWs from hran-dsp library
    ...                 with a KWs based on new libraries
    ...  - 13.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1437 - Removed unnecessary Run Keyword Unless

    Set Tags    CA-INTER_RAT    OWNER-adrian.maziarz@nokia.com    AUTHOR-katarzyna.wasiel@nokia.com
    ...    MAINTAINER-igor.kleschenok@nokia.com    PHASE-CRT    SW-SBTS20A    FEATURE-RP002546
    ...    GROUP_IN_CHARGE-WRO_9_Vrf

    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Preconditions
    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Step 1: Start LTE Data Transfer And Collect TTI Trace
    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Step 2: Start WCDMA Data Transfer And Collect TTI Trace
    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Step 3: Start WCDMA Voice Call And Collect TTI Trace
    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Step 4: Stop WCDMA Data Transfer And Collect TTI Trace
    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Step 5: Stop WCDMA Voice Call And Collect TTI Trace
    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Step 6: Check The Result


Preconditions
    Log  Preconditions  console=True
    Basic Verification Of WL DSS/SSS Enabling  ${LTE_CELL_ID}  LTE
    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Create Test Variables
    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Check Preconditions
    Require UE  LTE_UE  LTE_LOCKED_WL
    Require UE  WCDMA_UE1  WCDMA_LOCKED_WL1
    Require UE  WCDMA_UE2  WCDMA_LOCKED_WL

    Log  PRECONDITIONS FINISHED  console=True


Create Test Variables
    ${bts_id} =  Get BTS ID From ADMIN
    Set Test Variable  ${BTS_ID}  ${bts_id}

    ${wcdma_cell_id} =  Get ID Of WCDMA Cell Paired With LTE Cell  ${LTE_CELL_ID}
    Set Test Variable  ${WCDMA_CELL_ID}  ${wcdma_cell_id}

    ${cell_lcg_dict} =  Create Cells And LCG IDs Dictionary
    ${wncelg_id} =  Get LCG ID For Cell  ${WCDMA_CELL_ID}  ${cell_lcg_dict}
    Set Test Variable  ${WNCELG_ID}  ${wncelg_id}

    Set Test Variable  ${OBTAINED_PRB_AVAILABLE}  &{EMPTY}
    Set Test Variable  ${STATUS}  &{EMPTY}

    ${load_list} =  Create List  LOW  MEDIUM  HIGH
    Set Test Variable  ${LOAD_LIST}  ${load_list}


Check Preconditions
    ${_}  ${parsed_scf} =  Save And Parse SCF  SCF_preconditions_check

    ${first_query} =  Run Keyword And Return Status  Check Every Element In SCF  ${parsed_scf}  WNCELG
    ...  WNCELG-${WNCELG_ID}  /p[@name='dssLoadFactorDCH']  <p name="dssLoadFactorDCH">100</p>  dist_name_substring=True
    Should Be True  ${first_query}
    ...  msg= Value of dssLoadFactorDCH parameter doesn't meet preconditions! Please change this parameter to dssLoadFactorDCH=100.

    ${secound_query} =  Run Keyword And Return Status  Check Every Element In SCF  ${parsed_scf}  WNCELG
    ...  WNCELG-${WNCELG_ID}  /p[@name='dssLoadFactorHSDPA']  <p name="dssLoadFactorHSDPA">100</p>  dist_name_substring=True
    Should Be True  ${secound_query}
    ...  msg= Value of dssLoadFactorHSDPA parameter doesn't meet preconditions! Please change this parameter to dssLoadFactorHSDPA=100.

    ${third_query} =  Run Keyword And Return Status  Check Every Element In SCF  ${parsed_scf}  WNCELG
    ...  WNCELG-${WNCELG_ID}  /p[@name='dssLoadThresholdHigh']  <p name="dssLoadThresholdHigh">2</p>  dist_name_substring=True
    Should Be True  ${third_query}
    ...  msg= Value of dssLoadThresholdHigh parameter doesn't meet preconditions! Please change this parameter to dssLoadThresholdHigh=2.

    ${fourth_query} =  Run Keyword And Return Status  Check Every Element In SCF  ${parsed_scf}  WNCELG
    ...  WNCELG-${WNCELG_ID}  /p[@name='dssLoadThresholdMedium']  <p name="dssLoadThresholdMedium">1</p>  dist_name_substring=True
    Should Be True  ${fourth_query}
    ...  msg= Value of dssLoadThresholdMedium parameter doesn't meet preconditions! Please change this parameter to dssLoadThresholdMedium=1.


Step 1: Start LTE Data Transfer And Collect TTI Trace
    Log  Step 1: Start LTE Data Transfer And Collect TTI Trace  console=True

    Prepare UE For Data Transfer  LTE_UE  ${LTE_CELL_ID}
    Start Data Transfer  LTE_dt  LTE_UE  dl  throughput=50 Mbits/sec  packet_size=1400  duration=1200s  buffer=32M
    Check Data Transfer Is Alive  LTE_dt
    Log  LTE data transfer has started. Wait for stabilize it...  console=True
    Sleep  20s  Reason=Wait for data transfer to stabilize.

    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Collect TTI Trace And Set To Dictionary  step_1


Collect TTI Trace And Set To Dictionary
    [Arguments]  ${step_number}

    Log  Collect TTI Traces...  console=True
    Sleep  5s  reason=waiting for load to change
    Collect 4G TTI Trace   cell_id=${LTE_CELL_ID}
    ...                    trace_time=20s
    ...                    output_path=${LOG_PATH}/TTI_Trace_from_${step_number}

    ${sw_version} =  Get SW Version
    Log  Parsing TTI Traces...  console=True
    Parse 4G TTI Trace  ${sw_version}  DL  ${LOG_PATH}/TTI_Trace_from_${step_number}/ttitrace

    ${obtained_totalprbavail} =  Get Average totalPrbAvail  ${LOG_PATH}/TTI_Trace_from_${step_number}/ttitrace/lte_tti_DL.txt  downlink
    Log  Obtained average totalPRBAvail is equal to ${obtained_totalprbavail}.  console=True

    Set To Dictionary  ${OBTAINED_PRB_AVAILABLE}  ${step_number}=${obtained_totalprbavail}


Step ${index}: ${action} WCDMA Data Transfer And Collect TTI Trace
    Log  Step ${index}: ${action} WCDMA Data Transfer And Collect TTI Trace  console=True

    Check Data Transfer Is Alive  LTE_dt

    Run Keyword If  '${action}' == 'Start'  INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Prepare WCDMA Data Transfer
    ...    ELSE IF  '${action}' == 'Stop'  INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Stop WCDMA Data Transfer

    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Collect TTI Trace And Set To Dictionary  step_${index}


Prepare WCDMA Data Transfer

    Log  Prepare WCDMA UE for data transfer.   console=True
    Prepare UE For Data Transfer  WCDMA_UE1  ${WCDMA_CELL_ID}
    Start Data Transfer  WCDMA_dt  WCDMA_UE1  dl  throughput=50 Mbits/sec  packet_size=1400  duration=900s  buffer=32M
    Check Data Transfer Is Alive  WCDMA_dt
    Log  WCDMA data transfer has started. Wait 10s for stabilize it...  console=True
    Sleep  10s  Reason=Wait for data transfer to stabilize.
    Log  WCDMA data transfer has started.   console=True


Stop WCDMA Data Transfer

    Log  Stop WCDMA data transfer.   console=True
    Stop Datatransfer  WCDMA_dt
    Detach UE  WCDMA_UE1
    Log  WCDMA UE has turned off with success  console=True


Step ${index}: ${action} WCDMA Voice Call And Collect TTI Trace
    Log  Step ${index}: ${action} WCDMA Voice Call And Collect TTI Trace  console=True

    Check Data Transfer Is Alive  LTE_dt

    Run Keyword If  '${action}' == 'Start'  Run Keywords  Check Data Transfer Is Alive  WCDMA_dt
    ...                                              AND  INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Prepare WCDMA Voice Call
    ...    ELSE IF  '${action}' == 'Stop'  Run Keywords  INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Stop WCDMA Vice Call

    INTER_RAT__DSS_load_increase_low_medium_high__RP002167.Collect TTI Trace And Set To Dictionary  step_${index}


Prepare WCDMA Voice Call

    Log  Prepare UE for a voice call.   console=True
    Prepare UE For Data Transfer  WCDMA_UE2  ${WCDMA_CELL_ID}
    Turn Mobile Data Off  WCDMA_UE2
    Start Voice Call  AMR_1  WCDMA_UE2  ${NUMBER}
    Log  WCDMA voice call has started.   console=True


Stop WCDMA Vice Call

    Log  Stop WCDMA voice call.   console=True
    Stop Voice Call  AMR_1
    Detach UE  WCDMA_UE2
    Log  WCDMA UE has turned off with success  console=True


Step 6: Check The Result
    Log  Step 6: Check The Result  console=True

    Stop Datatransfer  LTE_dt

    FOR  ${load}  IN  @{LOAD_LIST}
         ${expected_prb} =  Count Total PRB Available  ${LTE_CELL_ID}  ${WCDMA_CELL_ID}  ${load}

         ${msg_low_load} =  Catenate    SEPARATOR=${SPACE}
         ...  Obtained value of total PRBs available is not equal to expected when load is ${load}!
         ...  Obtained values are equal to ${OBTAINED_PRB_AVAILABLE['step_1']} for step_1 and ${OBTAINED_PRB_AVAILABLE['step_5']}
         ...  for step_5 while expected value for this load is equal to ${expected_prb}.
         ${msg_medium_load} =  Catenate    SEPARATOR=${SPACE}
         ...  Obtained value of total PRBs available is not equal to expected when load is ${load}!
         ...  Obtained values are equal to ${OBTAINED_PRB_AVAILABLE['step_2']} for step_2 and ${OBTAINED_PRB_AVAILABLE['step_4']}
         ...  for step_4 while expected value for this load is equal to ${expected_prb}.
         ${msg_high_load} =  Catenate    SEPARATOR=${SPACE}
         ...  Obtained value of total PRBs available is not equal to expected when load is ${load}!
         ...  Obtained values is equal to ${OBTAINED_PRB_AVAILABLE['step_3']} for step_3 while expected
         ...  value for this load is equal to ${expected_prb}.

         ${condition} =  Run Keyword If  '${load}' == 'LOW'  Run Keyword And Return Status
         ...  Should Be True  ${expected_prb} == ${OBTAINED_PRB_AVAILABLE['step_1']} and ${expected_prb} == ${OBTAINED_PRB_AVAILABLE['step_5']}
         ...  msg=${msg_low_load}
         ...  ELSE IF  '${load}' == 'MEDIUM'  Run Keyword And Return Status
         ...  Should Be True  ${expected_prb} == ${OBTAINED_PRB_AVAILABLE['step_2']} and ${expected_prb} == ${OBTAINED_PRB_AVAILABLE['step_4']}
         ...  msg=${msg_medium_load}
         ...  ELSE IF  '${load}' == 'HIGH'  Run Keyword And Return Status
         ...  Should Be Equal  ${expected_prb}  ${OBTAINED_PRB_AVAILABLE['step_3']}
         ...  msg=${msg_high_load}

         IF  not ${condition}
             Set To Dictionary  ${STATUS}  ${load}_load=${condition}
         END
    END

    Should Be Empty  ${STATUS}  msg=Obtained total PRBs available is not equal to expected in some phase! Please view logs to see more details!
    Log  Obtained total PRBs available is equal to expected in each of phase!  console=True

    _verify bts states for iwk test helper


TC Setup
    Inter RAT Test Setup


TC Teardown
    Detach UE  LTE_UE
    Run Keyword And Ignore Error  Detach UE  WCDMA_UE1
    Run Keyword And Ignore Error  Detach UE  WCDMA_UE2
    Inter RAT Test Teardown
