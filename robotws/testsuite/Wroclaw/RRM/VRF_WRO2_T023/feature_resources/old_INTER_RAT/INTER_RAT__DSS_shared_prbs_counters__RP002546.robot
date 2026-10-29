*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library     DateTime
Library     SSHLibrary
Library     ute_ue
Library     taf.rnc.oms.nwi3
Library     taf.analyzer.pmcounter
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.collectors.ttitrace_4g    WITH NAME    ttitrace_4g
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/ca_INTER_RAT.robot

*** Variables ***
${LTE_CELL_ID}                                     # ID of tested LTE cell, that has WL DSS enabled
${NUMBER}                     0666002              # Autoresponder
${MCC}                                             # MCC value for which counters should be checked.
${MNC}                                             # MCC value for which counters should be checked.

*** Keywords ***
TC__INTER_RAT__DSS_shared_prbs_counters__RP002546
    [Documentation]
    ...
    ...  The purpose of this test case is to verify counters responsible for Shared PRB calculation. Counters to be checked:
    ...  M8011C294 - This counter provides the maximum number of PRBs from the shared spectrum which are available for allocation to LTE
    ...  in at least one TTI,
    ...  M8011C295 - This counter provides the aggregated number of PRBs from the shared spectrum which are available for allocation to LTE,
    ...  M8011C296 - This counter provides the aggregated number of TTIs in which some PRBs are available for LTE in shared spectrum.
    ...
    ...  Note:
    ...  Counters should be checked for low, medium and high WCDMA load.
    ...  Measurement period should be set to 15 min. You can set it in PMRNL object (parameter mtCellRes=15 min).
    ...
    ...  Step 0: Start Voice Call And Wait Till First Measuremet Period Has Begun
    ...  Step 1: Wait Till First Measurement Period Has Finished When WCDMA Load Is HIGH
    ...  Step 2: Wait Till Second Measurement Period Has Finished When WCDMA Load Is MEDIUM
    ...  Step 3: Wait Till Third Measurement Period Has Finished When WCDMA Load Is LOW
    ...  Step 4: Compare Result Of Test Case With Expectations
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.04.2020 - https://jiradc.int.net.nokia.com/browse/IWK-49
    ...  - 05.05.2020 - https://jiradc.int.net.nokia.com/browse/IWK-204 Added duration to data transfer
    ...  - 13.05.2020 - https://jiradc.int.net.nokia.com/browse/IWK-210 - added lte_interface=new to hran_dsp import
    ...  - 21.07.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-378 - changed required UE capabilities
    ...  - 08.07.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-693 - 'MAINTAINER' updated
    ...  - 23.03.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-817 - cleared warnings in logs
    ...  - 11.05.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-831 - changed maintainer
    ...  - 14.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-903 - modified test and moved it to robotws
    ...  - 23.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-994 - updated whole test case replacing
    ...                 old solutions with new ones
    ...  - 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1000 - Replaced 'Collect LTE TTI Trace'
    ...                 with 'Collect 4G TTI Trace'
    ...  - 11.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1056 - output path in "Collect 4G TTI Trace"
    ...                 changed from ${BTSFiles} to ${LOG_PATH}
    ...  - 13.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1437 - Added ${status_dict} =  Create Dictionary


    Set Tags    CA-INTER_RAT    OWNER-adrian.maziarz@nokia.com    AUTHOR-katarzyna.wasiel@nokia.com
    ...         MAINTAINER-szymon.kotlinski@nokia.com    PHASE-CRT    SW-SBTS20A    FEATURE-RP002546
    ...         GROUP_IN_CHARGE-WRO_9_Vrf

    INTER_RAT__DSS_shared_prbs_counters__RP002546.Preconditions
    INTER_RAT__DSS_shared_prbs_counters__RP002546.Step 0: Prepare UEs And Wait Till First Measuremet Period Has Begun
    INTER_RAT__DSS_shared_prbs_counters__RP002546.Step 1: Wait Till First Measurement Period Has Finished When WCDMA Load Is HIGH
    INTER_RAT__DSS_shared_prbs_counters__RP002546.Step 2: Wait Till Second Measurement Period Has Finished When WCDMA Load Is MEDIUM
    INTER_RAT__DSS_shared_prbs_counters__RP002546.Step 3: Wait Till Third Measurement Period Has Finished When WCDMA Load Is LOW
    INTER_RAT__DSS_shared_prbs_counters__RP002546.Step 4: Compare Result Of Test Case With Expectations


Preconditions
    Log  Preconditions  console=True

    Basic Verification Of WL DSS/SSS Enabling  ${LTE_CELL_ID}  LTE
    Save And Parse SCF  SCF.xml  export_type=configuration
    INTER_RAT__DSS_shared_prbs_counters__RP002546.Create Test Variables
    Require UE  LTE_UE   LTE_LOCKED_WL
    Require UE  WCDMA_UE1  WCDMA_LOCKED_WL1
    Require UE  WCDMA_UE2  WCDMA_LOCKED_WL

    Log  PRECONDITIONS FINISHED  console=True


Step 0: Prepare UEs And Wait Till First Measuremet Period Has Begun
    Log  Step 0: Prepare UEs And Wait Till First Measuremet Period Has Begun  console=True

    Log  Prepare UEs for this test case.\nPerforming attach on WCDMA_UE1...  console=True
    Prepare UE For Data Transfer  WCDMA_UE1  ${WCDMA_CELL_ID}
    Log  Performing attach on WCDMA_UE2...  console=True
    Prepare UE For Data Transfer  WCDMA_UE2  ${WCDMA_CELL_ID}

    Log  Turning off mobile data...  console=True
    Turn Mobile Data Off  WCDMA_UE1
    Turn Mobile Data Off  WCDMA_UE2

    Log  Starting voice calls...  console=True
    Start Voice Call  AMR_1  WCDMA_UE1  ${NUMBER}
    Start Voice Call  AMR_2  WCDMA_UE2  ${NUMBER}

    Log  Prepare LTE UE for data transfer...  console=True
    Prepare UE For Data Transfer  LTE_UE  ${LTE_CELL_ID}
    Log  Starting LTE data transfer...  console=True
    Start Datatransfer  LTE_dt  LTE_UE  dl  throughput=100 Mbits/sec  packet_size=1400  duration=7200s  buffer=32Ms

    Log  All UEs have been prepared with success!   console=True


Step ${index}: Wait Till ${period_number} Measurement Period Has Finished When WCDMA Load Is ${load}
    Log  Step ${index}: Wait Till ${period_number} Measurement Period Has Finished When WCDMA Load Is ${load}  console=True

    Run Keyword If  '${load}' == 'LOW'     Run Keywords  Stop Voice Call  AMR_2
    ...                                    AND           Detach Ue  WCDMA_UE2
    ...    ELSE IF  '${load}' == 'MEDIUM'  Run Keywords  Stop Voice Call  AMR_1
    ...                                    AND           Detach Ue  WCDMA_UE1

    ${time} =  INTER_RAT__DSS_shared_prbs_counters__RP002546.Count Measurement Period
    Log  Wait ${time} minutes till ${period_number} measurement period has begun  console=True
    Sleep  ${time} minutes  Reason=Wait till first measurement period has begun

    ${time} =  INTER_RAT__DSS_shared_prbs_counters__RP002546.Count Measurement Period
    Log  Wait ${time} minutes till ${period_number} measurement period has finished  console=True
    Sleep  ${time} minutes  Reason=Wait till ${period_number} measurement period has finished

    ${counters_dict}=  INTER_RAT__DSS_shared_prbs_counters__RP002546.Gather Counter Value From PM File  ${load}
    Set To Dictionary  ${OBTAINED_DICT}  ${load}=${counters_dict}

    Log  Collect TTI Traces...  console=True
    Collect 4G TTI Trace   cell_id=${LTE_CELL_ID}
    ...                    trace_time=20s
    ...                    output_path=${LOG_PATH}/TTI_Trace_with_${load}_load


Step 4: Compare Result Of Test Case With Expectations
    Log  Step 4: Compare Result Of Test Case With Expectations  console=True

    Stop Datatransfer  LTE_dt
    Detach UE  LTE_UE

    Log  Compare result of test case with expectations  console=True
    FOR  ${load}  IN  @{LOAD_LIST}
         ${expected_results_list} =  Evaluate  $EXPECTED_DICT['${load}'].values()
         ${obtained_results_list} =  Evaluate  $OBTAINED_DICT['${load}'].values()
         ${status_dict} =  INTER_RAT__DSS_shared_prbs_counters__RP002546.Compare Values Of Counters To Expected  ${expected_results_list}
         ...  ${obtained_results_list}  ${load}
    END

    Should Be Empty  ${STATUS}  msg=Some of the counters have incorrect values in one or more phases.! Please view logs to see more details!
    Log  Obtained values of counters M8011C294, M8011C295, M8011C296 are equal than expected in each of phase!  console=True


Create Test Variables
    ${mrbts_id} =  Get BTS ID From ADMIN
    Set Test Variable  ${MRBTS_ID}  ${mrbts_id}

    ${wcdma_cell_id} =  Get ID Of WCDMA Cell Paired With LTE Cell  ${LTE_CELL_ID}
    Set Test Variable  ${WCDMA_CELL_ID}  ${wcdma_cell_id}

    ${counters_list} =  Create List  M8011C294  M8011C295  M8011C296
    Set Test Variable  ${COUNTERS_LIST}  ${counters_list}

    ${load_list} =  Create List  LOW  MEDIUM  HIGH
    Set Test variable  ${LOAD_LIST}  ${load_list}

    Set Test Variable  ${OBTAINED_DICT}  &{EMPTY}
    Set Test Variable  ${STATUS}  &{EMPTY}

    ${expected_prbs_dict}=  INTER_RAT__DSS_shared_prbs_counters__RP002546.Count Expected Total PRB Available And Set To Dictionary

    ${expected_dict}=  INTER_RAT__DSS_shared_prbs_counters__RP002546.Count Expected Values Of Counters And Set To Dictionary  ${expected_prbs_dict}
    Set Test Variable  ${EXPECTED_DICT}  ${expected_dict}


Count Expected Total PRB Available And Set To Dictionary

    ${expected_prbs_dict} =  Create Dictionary
    FOR  ${load}  IN  @{LOAD_LIST}
         ${expected_prb} =  Count Total PRB Available  ${LTE_CELL_ID}  ${WCDMA_CELL_ID}  ${load}
         Set To Dictionary  ${expected_prbs_dict}  ${load}=${expected_prb}
    END

    [Return]  ${expected_prbs_dict}


Count Expected Values Of Counters And Set To Dictionary
    [Arguments]  ${expected_prbs_dict}

    ${expected_low_load} =  Create Dictionary
    ${expected_medium_load} =  Create Dictionary
    ${expected_high_load} =  Create Dictionary
    ${expected_dict} =  Create Dictionary

    ${high_load_value} =  Set Variable  0
    ${high_load_value} =  Convert to Integer  ${high_load_value}

    FOR  ${counter}  IN  @{COUNTERS_LIST}
         ${medium_load_value} =  Run Keyword If  '${counter}' == 'M8011C294'  Evaluate  ${expected_prbs_dict['MEDIUM']}-${expected_prbs_dict['HIGH']}
         ...  ELSE IF  '${counter}' == 'M8011C295'  Evaluate  (${expected_prbs_dict['MEDIUM']}-${expected_prbs_dict['HIGH']})*900000*0.9
         ...  ELSE IF  '${counter}' == 'M8011C296'  Evaluate  900000*0.9

         ${low_load_value} =  Run Keyword If  '${counter}' == 'M8011C294'  Evaluate  ${expected_prbs_dict['LOW']}-${expected_prbs_dict['HIGH']}
         ...  ELSE IF  '${counter}' == 'M8011C295'  Evaluate  (${expected_prbs_dict['LOW']}-${expected_prbs_dict['HIGH']})*900000*0.9
         ...  ELSE IF  '${counter}' == 'M8011C296'  Evaluate  900000*0.9

         Set To Dictionary  ${expected_low_load}  ${counter}=${low_load_value}
         Set To Dictionary  ${expected_medium_load}  ${counter}=${medium_load_value}
         Set To Dictionary  ${expected_high_load}  ${counter}=${high_load_value}

    END

    Set To Dictionary  ${expected_dict}  LOW=${expected_low_load}
    ...                                  MEDIUM=${expected_medium_load}
    ...                                  HIGH=${expected_high_load}

    [Return]  ${expected_dict}


Count Measurement Period
    ${minutes_now} =  Get Time From BTS  host_ip=${SMOD1['IP']}
    ...  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}  date_time_format=%M
    ${minutes_now} =  Convert To Integer  ${minutes_now}
    ${time} =  Run Keyword If    0 <= ${minutes_now} < 15    Subtract Time From Time  15  ${minutes_now}
    ...               ELSE IF   15 <= ${minutes_now} < 30    Subtract Time From Time  30  ${minutes_now}
    ...               ELSE IF   30 <= ${minutes_now} < 45    Subtract Time From Time  45  ${minutes_now}
    ...                  ELSE                                Subtract Time From Time  60  ${minutes_now}
    [Return]  ${time}


Gather Counter Value From PM File
    [Arguments]  ${load}

    Log  Waitnig additional minute for counter values...  console=True
    Sleep  1min  reason=Waiting for counters from last period to be available on BTS.
    Log  Collecting counters from BTS...  console=True
    Wait Until Keyword Succeeds  5x  10s  Collect PM Counters  ${LOG_PATH}/pm_counters_for_${load}_load
    ...  xml_files_left=1  time_interval=90min  intervals=15
    ${counters_dict} =  Get Values Of Counters From List  ${LOG_PATH}/pm_counters_for_${load}_load
    ...                  ${COUNTERS_LIST}
    ...                  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${LTE_CELL_ID}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}
    ...                  1
    [Return]  ${counters_dict}


Compare Values Of Counters To Expected
    [Arguments]  ${expected_results_list}  ${obtained_results_list}  ${load}

    ${expected_m8011c294_value} =  Run Keyword If  '${load}' == 'MEDIUM' or '${load}' == 'LOW'  Evaluate  $EXPECTED_DICT['${load}']['M8011C294']
    ${obtained_m8011c294_value} =  Run Keyword If  '${load}' == 'MEDIUM' or '${load}' == 'LOW'  Evaluate  $OBTAINED_DICT['${load}']['M8011C294'][0]
    ${status_dict} =  Create Dictionary

    FOR  ${obtained_value}  ${expected_value}  IN ZIP  ${obtained_results_list}  ${expected_results_list}
         ${obtained_value} =  Convert To Number  ${obtained_value[0]}  precision=1
         ${condtion} =  Run Keyword If  '${load}' == 'HIGH'  Run Keyword And Return Status  Should Be Equal  ${expected_value}  ${obtained_value}
         ...  msg=Some of obtained value of counters M8011C294, M8011C295, M8011C296 is not equal to expected when load is ${load}!
         ...  ELSE IF  '${load}' == 'MEDIUM'  Run Keyword And Return Status
         ...  Should Be True  ${expected_value} <= ${obtained_value} and ${expected_m8011c294_value} == ${obtained_m8011c294_value}
         ...  msg=Some of obtained value of counters M8011C294, M8011C295, M8011C296 is not equal to expected when load is ${load}!
         ...  ELSE IF  '${load}' == 'LOW'  Run Keyword And Return Status
         ...  Should Be True  ${expected_value} <= ${obtained_value} and ${expected_m8011c294_value} == ${obtained_m8011c294_value}
         ...  msg=Some of obtained value of counters M8011C294, M8011C295, M8011C296 is not equal to expected when load is ${load}!

         IF  not ${condtion}
             ${status_dict} =  Set To Dictionary  ${STATUS}  ${load}=${condtion}
         END
    END

    [Return]  ${status_dict}


TC Setup
    Inter RAT Test Setup


TC Teardown
    Log  TC Teardown  console=True
    Run Keyword And Ignore Error  Detach Ue  WCDMA_UE1
    Run Keyword And Ignore Error  Detach Ue  WCDMA_UE2
    Run Keyword And Ignore Error  Detach UE  LTE_UE
    Inter RAT Test Teardown
