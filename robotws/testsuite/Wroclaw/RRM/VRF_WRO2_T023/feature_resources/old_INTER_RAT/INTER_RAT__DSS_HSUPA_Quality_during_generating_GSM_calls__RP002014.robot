*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library     ute_ue
Library     hran_bsc
Library     taf.ul.ttitrace_analyzer
Library     taf.sbts.browser_server
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/ca_INTER_RAT.robot

*** Variables ***
${WCDMA_CELL_ID}                                                 # ID of WCDMA cell to which UEs should attach to during the test
${CALL_TIME}                  900                                # Max duration of HSPA UL data transfer in seconds. (Min value is 900 seconds)
${NUMBER}                     0666002                            # Autoresponder


*** Keywords ***
TC__INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14312
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this TC is to verify HSUPA throughput before, during and after GSM call
    ...  established in shared WCDMA spectrum.
    ...  During this test HSPA UL data transfer and GSM Voice call are performed with activated
    ...  feature RP002014 (WCDMA+GSM DSS). HSUPA cat.6 data transfer is started before and is active during
    ...  voice call as well as for a couple minutes after voice call is finished. This is repeated
    ...  three times. Throughput from test is analyzed in the last step.
    ...  Preconditions:
    ...  - BTS is configured, up and running, all cells are operational
    ...  - WCDMA+GSM DSS RP002014 is enabled in tested cell
    ...  - 1 UE with HSUPA cat.6, 1 UE which will be used for GSM voice call
    ...
    ...  Steps:
    ...  Step 1: Start HSUPA Call And Collect Traces
    ...  Step 2: Perform GSM Call And Collect Traces
    ...  Step 3: Collect Traces And Release HSUPA Call
    ...  Step 4: Repeat Steps 1-4 Two More Times
    ...  Step 5: Verify Throughput Values
    ...
    ...  During test timeslots for dedicated trxes are locked and GPRS is disabled. At the end all dedicated trxes
    ...  should be unlocked and GPRS should be enabled again. In case something went wrong,
    ...  please change those parameters back manually.
    ...  All UE serial numbers can be found in ues.yaml. This file can be found in config directory of each TL.
    ...  The unit of throughput returned by 'Get Average Uplink Throughput' is kbps, so to get Mbps the following
    ...  operations have to be done:
    ...   tput = Get Average Uplink Throughput
    ...   tput [kbits/s] = tput / 1000 [Mbits/s]
    ...  Files specific for this test case:
    ...  - cpuAddress_HSUPA_L2_Trace_YYYYMMDD_HHMMSS_master.txt - nine HSUPA L2 Master Trace files saved in BTS_Files
    ...    (e.g. 0x235a_HSUPA_L2_Trace_20180625_101308_master.txt)
    ...  - cpuAddress_HSUPA_L2_Trace_YYYYMMDD_HHMMSS_slave.txt - nine HSUPA L2 Slave Trace files saved in BTS_Files
    ...    (e.g. 0x235a_HSUPA_L2_Trace_20180625_102650_slave.txt)
    ...  - cpuAddress_Cell_throughput_YYYYMMDD_HHMMSS.txt - nine Throughput log files saved in BTS_Files
    ...    (e.g. 0x235a_Cell_throughput_20180625_102650.txt)
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-14312 - initial creation
    ...  - 11.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16561 - removed airplane mode switching
    ...  - 19.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-16834 - changed names of user variables
    ...               - https://jira3.int.net.nokia.com/browse/TAT-17516 - added toggling of mobile data
    ...  - 03.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17403 - added variable 'use_existing_trx_list'
    ...                                                                    'Unlock All Transport Channels For All
    ...                                                                    Dedicated TRXes'
    ...  - 03.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17443 - added BSC logs collecting
    ...  - 21.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-17951 - TC reworked to use library ute_ue for UE handling
    ...  - 25.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-19082 - corrections for multiple keywords
    ...                 with the same name declared in test set
    ...  - 05.03.2020 - https://jiradc.int.net.nokia.com/browse/IWK-76 - setting parameters for connection to RNC
    ...                 removed from Preconditions step
    ...  - 24.03.2020 - https://jiradc.int.net.nokia.com/browse/IWK-111 - added KW 'Run Hanging Users Script'
    ...  - 05.05.2020 - https://jiradc.int.net.nokia.com/browse/IWK-204 - added duration to data transfer
    ...  - 09.07.2020 - https://jiradc.int.net.nokia.com/browse/IWK-353 - added "protocol=tcp" to Start Data Transfer keywords
    ...  - 21.07.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-378 - changed required UE capabilities
    ...  - 02.04.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-629 - Added keyword "Teardown DSP"
    ...  - 12.04.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-646 - Delete keyword "Teardown DSP" from TC Teardown
    ...  - 08.07.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-693 - import of hran_dsp library (lte_interface=new)
    ...  - 11.04.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-819 - added prefix ca_INTER_RAT for 'Open
    ...                 session to BSC' and 'Close all BSC sessions' KWs
    ...  - 14.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-906 - modified test and moved it to robotws
    ...  - 05.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-835 - updated whole test case replacing
    ...                 old solutions with new ones
    ...  - 11.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1056 - Replace KWs from hran-dsp library
    ...                 with a KWs based on new libraries


    Set Tags    CA-INTER_RAT    OWNER-adam.chamera@nokia.com    AUTHOR-monika.ceglarek@nokia.com
    ...    MAINTAINER-monika.ceglarek@nokia.com    PHASE-CRT    SW-SBTS19    FEATURE-RP002014
    ...    GROUP_IN_CHARGE-WRO_2_Vrf


    INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Step 0: Set Preconditions
    INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Step 1: Start HSUPA Call And Collect Traces
    INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Step 2: Perform GSM Call And Collect Traces
    INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Step 3: Collect Traces And Release HSUPA Call
    INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Step 4: Verify Throughput Values


Step 0: Set Preconditions
    Log  \nStep 0: Set Preconditions  console=True

    ca_INTER_RAT.Open session to BSC
    INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Create Global Variables
    INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Prepare BSC
    Setup Client
    Require UE  WCDMA_UE  WCDMA_LOCKED_WG
    Require UE  GSM_UE  GSM_LOCKED_WG
    Basic Verification Of WG DSS Enabling In Given Cells  ${WCDMA_CELL_ID}
    Log  PREPARATIONS FINISHED - ALL PRECONDITIONS PASSED  console=True


Create Global Variables
    Set Test Variable  ${BSC_CONNECTED}     ${TRUE}
    Set Test Variable  ${TIMESLOTS_LOCKED}  ${FALSE}
    Set Test Variable  ${GENA_DISABLED}     ${FALSE}

    ${_}  ${parsed_scf} =  Save And Parse SCF  scf_name=SCF_runtime  export_type=configurationAndRuntimeObjects
    Set Test Variable  ${PARSED_SCF}  ${parsed_scf}

    ${wcdma_cells} =   Get Wcdma Cells IDs
    Set Test Variable  ${WCDMA_CELLS}  ${wcdma_cells}

    ${bcf_id} =  Get Parameter Value From SCF  ${parsed_scf}  GNBCF  GNBCF  /p[@name='bcfId']
    Set Test Variable  ${BCF_ID}  ${bcf_id}

    ${gsm_sector_ids} =  hran_bsc.Get Sectors IDs  ${BCF_ID}  ${FALSE}
    Set Test Variable  ${GSM_SECTOR_IDS}  ${gsm_sector_ids}

    ${sector_id} =  Get IDs of GSM Sectors Mapped To WCDMA Cells For WG DSS  ${WCDMA_CELL_ID}
    Set Test Variable  ${GSM_SECTOR_ID}  ${sector_id[0]}

    ${rac} =  hran_bsc.Get BTS Parameters  ${GSM_SECTOR_ID}  GPRS  RAC
    Set Test Variable  ${RAC}  ${rac}

    ${throughputs} =  Create Dictionary
    Set Test Variable  ${THROUGHPUTS}  ${throughputs}


Prepare BSC
    Set Test Variable  ${TIMESLOTS_LOCKED}  ${TRUE}
    Wait Until Keyword Succeeds  3x  1min
    ...  Lock All Transport Channels For All Dedicated TRXes  ${GSM_SECTOR_ID}

    Set Test Variable  ${GENA_DISABLED}  ${TRUE}
    Wait Until Keyword Succeeds  3x  1min  Turn Off GENA  ${GSM_SECTOR_ID}


Step 1: Start HSUPA Call And Collect Traces
    Log  \nStep 1: Start HSUPA Call And Collect Traces  console=True

    Prepare UE For Data Transfer  WCDMA_UE  ${WCDMA_CELL_ID}
    Log  Starting datatransfer. Please wait around ${CALL_TIME}s for results (it may take ~60s more).  console=True
    ${start_time} =  Get Time  epoch
    Set Test Variable  ${START_TIME}  ${start_time}
    Start Data Transfer  WCDMA_DT  WCDMA_UE  ul  duration=7200s  protocol=tcp  buffer=32M  max_segment_size=1400
    Sleep  120s  Wait for calls to stabilize.

    ${status}   ${msg}=  Run Keyword And Ignore Error  INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Collect Traces
    ...  hsupa_before_gsm
    Run Keyword If  '${status}' == 'FAIL'
    ...  Run Keywords  Log  A problem occured while collecting traces in phase: hsupa_before_gsm\n Error message:${msg}  level=WARN
    ...  AND           Return From Keyword
    ${tput} =  Get Average Uplink Throughput  ${trace_file_path}
    ${tput} =  Evaluate  ${tput} / 1000
    Log  Throughput for phase 'hsupa_before_gsm' was: ${tput} Mbps  console=True
    Set To Dictionary  ${THROUGHPUTS}  hsupa_before_gsm  ${tput}
    Set Test Variable  ${THROUGHPUTS}


Step 2: Perform GSM Call And Collect Traces
    Log  \nStep 2: Perform GSM Call And Collect Traces  console=True

    Prepare UE For Data Transfer  GSM_UE  ${GSM_SECTOR_ID}  ip_check=False
    Turn Mobile Data Off  GSM_UE

    Start Voice Call  AMR  GSM_UE  ${number}
    Sleep  120s  reason=Wait until resources are allocated by voice call

    Run Keyword If  not ${BSC_CONNECTED}  ca_INTER_RAT.Open session to BSC
    Check If GSM Call Is Performed On Shared TRx  ${GSM_SECTOR_ID}

    ${status}   ${msg}=  Run Keyword And Ignore Error  INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Collect Traces
    ...  with_gsm

    Stop Voice Call  AMR
    Log  End of voice call.  console=True

    Run Keyword If  '${status}' == 'FAIL'
    ...  Run Keywords  Log  A problem occured while collecting traces in phase: with_gsm\n Error message:${msg}  level=WARN
    ...  AND           Return From Keyword
    ${tput} =  Get Average Uplink Throughput  ${trace_file_path}
    ${tput} =  Evaluate  ${tput} / 1000
    Log  Throughput for phase 'with_gsm' was: ${tput} Mbps  console=True
    Set To Dictionary  ${THROUGHPUTS}  with_gsm  ${tput}
    Set Test Variable  ${THROUGHPUTS}


Step 3: Collect Traces And Release HSUPA Call
    Log  \nStep 3: Collect Traces And Release HSUPA Call  console=True

    Check Data Transfer Is Alive  WCDMA_DT
    ${status}   ${msg}=  Run Keyword And Ignore Error  INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Collect Traces
    ...  hsupa_after_gsm

    Check Data Transfer Is Alive  WCDMA_DT
    Stop Data Transfer  WCDMA_DT

    Run Keyword If  '${status}' == 'FAIL'
    ...  Run Keywords  Log  A problem occured while collecting traces in phase: hsupa_after_gsm\n Error message:${msg}  level=WARN
    ...  AND           Return From Keyword
    ${tput} =  Get Average Uplink Throughput  ${trace_file_path}
    ${tput} =  Evaluate  ${tput} / 1000
    Log  Throughput for phase 'hsupa_after_gsm' was: ${tput} Mbps  console=True
    Set To Dictionary  ${THROUGHPUTS}  hsupa_after_gsm  ${tput}
    Set Test Variable  ${THROUGHPUTS}


Collect Traces
    [Arguments]  ${phase}
    Log  Collect Traces for 2 min  console=True
    Start Cell Throughput  cell_id=${WCDMA_CELL_ID}  trace_alias=ul_tput_${phase}
    Start HSUPA L2 Trace  cell_id=${WCDMA_CELL_ID}  trace_alias=hsupa_l2_${phase}
    Sleep  2min
    Stop And Save Trace  ${LOG_PATH}  hsupa_l2_${phase}
    ${trace_file_path} =  Stop And Save Trace  ${LOG_PATH}  ul_tput_${phase}
    Set Test Variable  ${trace_file_path}


Check If Data Transfer Is Still Ongoing
    ${current_time} =  Get Time  epoch
    ${time_delta} =  Evaluate  ${current_time} - ${START_TIME}
    Should Be True  ${time_delta} <= ${CALL_TIME}
    ...  msg=Test took longer than declared time: ${CALL_TIME} s. Duration time of test was: ${time_delta}s
    ${waiting_time} =  Evaluate  ${CALL_TIME} - ${time_delta}
    ${current_time} =  Get Time  time_=${current_time}
    Log  \nSeconds left till end of data transfer: ${waiting_time}s (counted from ${current_time}).  console=True


Step 4: Verify Throughput Values
    Log  \nStep 4: Verify Throughput Values  console=True

    Run Keyword And Continue On Failure  Should Be True  2.7 < ${THROUGHPUTS['hsupa_before_gsm']} < 5.0
    ...  msg=Throughput during hsupa_before_gsm is not in range: <2.7 Mbps; 5.0 Mbps>. Throughput value was: ${THROUGHPUTS['hsupa_before_gsm']} Mbps.
    Run Keyword And Continue On Failure  Should Be True  0.9 < ${THROUGHPUTS['with_gsm']} < 5.0
    ...  msg=Throughput with GSM call during with_gsm is not in range <0.9 Mbps; 5.0 Mbps>. Throughput value was: ${THROUGHPUTS['with_gsm']} Mbps.
    Run Keyword And Continue On Failure  Should Be True  2.7 < ${THROUGHPUTS['hsupa_after_gsm']} < 5.0
    ...  msg=Throughput during hsupa_after_gsm is not in range: <2.7 Mbps; 5.0 Mbps>. Throughput value was: ${THROUGHPUTS['hsupa_after_gsm']} Mbps.

    Log  \nThroughputs from each phase:   console=True
    ${tputs_dictionary}=  Create Dictionary
    ...  hsupa_before_gsm=${THROUGHPUTS['hsupa_before_gsm']} Mbps
    ...  with_gsm=${THROUGHPUTS['with_gsm']} Mbps
    ...  hsupa_after_gsm=${THROUGHPUTS['hsupa_after_gsm']} Mbps
    ${pretty_statuses}=  Evaluate  pprint.pformat(${tputs_dictionary}, indent=4)  modules=pprint

    Log  \n${pretty_statuses}  console=True
    Length Should Be  ${THROUGHPUTS}  3  msg=Throughput values were not collected from all phases.


Call Test Teardown

    ${var} =  Run Keyword And Return Status   Variable Should Exist  ${GENA_DISABLED}
    Run Keyword If  not ${var}  Run Keywords  ca_INTER_RAT.Close All BSC Sessions
    ...                         AND           Teardown Client
    Return From Keyword If  not ${var}

    Log  Call Test Teardown  console=True

    Run Keyword If  (${TIMESLOTS_LOCKED} or ${GENA_DISABLED}) and not ${BSC_CONNECTED}
    ...                                  ca_INTER_RAT.Open session to BSC
    Run Keyword If  ${TIMESLOTS_LOCKED}  Wait Until Keyword Succeeds  3x  1min
    ...                                  Unlock All Transport Channels For All Dedicated TRXes  ${GSM_SECTOR_ID}
    ...                                                                                         use_existing_trx_list=True
    Run Keyword If  ${GENA_DISABLED}     Wait Until Keyword Succeeds  3x  1min
    ...                                  Turn On GENA  ${GSM_SECTOR_ID}  ${RAC}
    ca_INTER_RAT.Close all BSC sessions
    Teardown Client
    Collect BSC Logs
    Stop Data Transfers For All Ues
    Detach UE  WCDMA_UE
    Detach UE  GSM_UE

    Run Keyword If Test Passed  Log  \nTest case finished successfully.\n  console=True


TC Setup
    Inter RAT Test Setup


TC Teardown
    [Timeout]  1h
    INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.Call Test Teardown
    Inter RAT Test Teardown
