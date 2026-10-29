*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library     ute_ue
Library     hran_bsc
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Library     taf.ul.ttitrace_analyzer
Library     taf.converters.ttitracer
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/ca_INTER_RAT.robot

*** Variables ***
${LTE_CELL_ID}                           # ID of LTE cell to which LTE UE should attach
${GSM_CELL_ID}                           # ID of GSM cell paired with tested LTE cell
${EXPECTED_NUMOFPRBSALLOC}               # expected average value of numOfPrbsAlloc in LTE DL TTI trace while shared spectrum is allocated by GSM
${EXPECTED_TOTALPRBAVAIL}                # expected average value of totalPrbAvail in LTE UL TTI trace while shared spectrum is allocated by GSM

*** Keywords ***
TC__INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-13604
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this TC is to verify if GSM uses dedicated and shared TRXs and LTE RAT uses dedicated and shared bandwidth
    ...  when GSM shared TRX is occupied.
    ...
    ...  Preconditions of TC:
    ...  - DSS LG should be active in at least one cell,
    ...  - BTS OnAir, no unexpected alarms.
    ...
    ...  Notes:
    ...  All timeslots in all TRXes of tested GSM sector will be locked inside Preconditions step of this test,
    ...  except two timeslots in dedicated TRX reserved for MBCCH and SDCCH and all timeslots in the last shared TRX reserved for PS GSM call.
    ...  In Preconditions step GPRS is enabled in the last shared TRX in tested GSM sector, so that spectrum allocation by GSM is performed.
    ...
    ...  Steps:
    ...  Step 1: Perform downlink Data Transfer In LTE Cell
    ...  Step 2: Perform uplink Data Transfer In LTE Cell
    ...  Step 3: Verify If GSM Uses The Part Of Shared Spectrum
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-13604 - Initial creation
    ...  - 19.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17517 - added turning off mobile data in teardown
    ...  - 03.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17443 - added BSC logs collecting
    ...  - 09.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17811 - toggle GPRS in one of GSM shared TRX
    ...  - 21.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-17951 - TC reworked to use library ute_ue for UE handling
    ...  - 25.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-19082 - corrections for multiple keywords
    ...                 with the same name declared in test set
    ...  - 24.03.2020 - https://jiradc.int.net.nokia.com/browse/IWK-111 - added KW 'Run Hanging Users Script'
    ...  - 05.05.2020 - https://jiradc.int.net.nokia.com/browse/IWK-204 Added duration to data transfer
    ...  - 21.07.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-378 - changed required UE capabilities
    ...  - 05.07.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-659 - checking if last shared TRX is not
    ...                 dedicated to MBCCH in Set Variables KW.
    ...  - 08.07.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-693 - 'MAINTAINER' updated as well as import of
    ...                 hran_dsp library (lte_interface=new)
    ...  - 11.04.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-819 - added prefix ca_INTER_RAT for 'Open
    ...                 session to BSC' and 'Close all BSC sessions' KWs
    ...  - 11.05.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-831 - changed maintainer
    ...  - 14.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-907 - modified test and moved it to robotws
    ...  - 22.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-993 - updated whole test case replacing
    ...                 old solutions with new ones
    ...  - 11.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1056 - Replace KWs from hran-dsp library
    ...                 with a KWs based on new libraries
    ...  - 17.09.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1556 -  changed UDP DT to TCP
    ...  - 26.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1809 - Added additional verification of BST state and lock, unlock BSC


    Set Tags    CA-INTER_RAT    OWNER-krzysztof.szumski@nokia.com    AUTHOR-katarzyna.wasiel@nokia.com
    ...    MAINTAINER-szymon.kotlinski@nokia.com    PHASE-CRT    SW-SBTS19    FEATURE-RP001783
    ...    GROUP_IN_CHARGE-WRO_9_Vrf

    INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783.Preconditions
    INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783.Step 1: Perform DL Data Transfer In LTE Cell
    INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783.Step 2: Perform UL Data Transfer In LTE Cell
    INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783.Step 3: Verify If GSM Uses The Part Of Shared Spectrum


Preconditions
    Log  Preconditions  console=True
    Basic Verification Of LG DSS Enabling In Given Cells  ${LTE_CELL_ID}
    ca_INTER_RAT.Open session to BSC
    INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783.Set Variables
    Require UE  LTE_UE  LTE_LOCKED_LG
    Set Test Variable  ${GSM_SECTOR_MODIFIED}  True
    Prepare GSM Sector For Shared Spectrum Usage  ${GSM_CELL_ID}
    Wait Until Keyword Succeeds  3m  30s  _Verify Bts States For Iwk Test Helper
    hran_bsc.Lock Sector  ${GSM_CELL_ID}
    Toggle GPRS In GSM TRX  ON  ${GSM_CELL_ID}  ${LAST_SHARED_TRX}
    hran_bsc.Unlock Sector  ${GSM_CELL_ID}
    Wait Until Keyword Succeeds  3m  30s  _Verify Bts States For Iwk Test Helper
    Sleep  30s  reason=Wait for new bitmap form BSC

    Log  Preconditions passed! BTS state after reconfiguration OK - no unexpected alarms are reported!  console=True


Set Variables
    Set Test Variable  ${GSM_SECTOR_MODIFIED}  False
    ${last_shared_trx}=  Get TRXes Of Specified Type For GSM Cell  ${GSM_CELL_ID}  SHARED
    ${trx_parameters}=  Wait Until Keyword Succeeds  2m  10s  Get Transceiver Data  ${GSM_CELL_ID}  ${last_shared_trx}[-1]
    ${bcch_trx}=  Evaluate  'MBCCH' in ${trx_parameters['TYPE']}
    ${last_shared_trx_id}=  Set Variable If  ${bcch_trx}  ${last_shared_trx}[-2]  ${last_shared_trx}[-1]
    Set Test Variable  ${LAST_SHARED_TRX}  ${last_shared_trx_id}
    Set Test Variable  ${RESULTS}  &{EMPTY}
    Set Test Variable  ${EXPECTED}  &{EMPTY}


Step ${index}: Perform ${direction} Data Transfer In LTE Cell
    Log  Step ${index}: Perform ${direction} Data Transfer In LTE Cell  console=True

    Log  Preparing LTE UE for ${direction} data transfer...  console=True

    Prepare UE For Data Transfer  LTE_UE  ${LTE_CELL_ID}
    Start Data Transfer  LTE_DT_${index}  LTE_UE  ${direction}  throughput=150 Mbits/sec  max_segment_size=1400  duration=300s  buffer=32M
    ...    protocol=tcp
    Log  Data transfer ongoing for ~110s...  console=True
    Sleep  90s  reason=Wait for LTE datatransfer to stabilize before collecting TTI trace

    Log  Collect TTI Traces...  console=True
    Collect 4G TTI Trace   cell_id=${LTE_CELL_ID}
    ...                    trace_time=20s
    ...                    output_path=${LOG_PATH}/${direction}_trace

    ${sw_version} =  Get SW Version
    Log  Parsing TTI Traces...  console=True
    Parse 4G TTI Trace  ${sw_version}  ${direction}  ${LOG_PATH}/${direction}_trace/ttitrace

    ${value}=  Run Keyword If  '${direction}' == 'DL'  Get Average numOfPrbsAlloc  ${LOG_PATH}/${direction}_trace/ttitrace/lte_tti_DL.txt  downlink
    ...                  ELSE                          Get Average totalPrbAvail  ${LOG_PATH}/${direction}_trace/ttitrace/lte_tti_UL.txt  uplink

    Set To Dictionary  ${RESULTS}  ${direction}=${value}

    Stop Data Transfer  LTE_DT_${index}


Step 3: Verify If GSM Uses The Part Of Shared Spectrum
    Log  Step 3: Verify If GSM Uses The Part Of Shared Spectrum  console=True

    Set To Dictionary  ${EXPECTED}  ul=${EXPECTED_TOTALPRBAVAIL}  downlink=${EXPECTED_NUMOFPRBSALLOC}
    Log  Expected numbers of total available PRBs: ${EXPECTED} and the result after execution of TC: ${RESULTS}.  console=True
    Should Be Equal As Integers  ${RESULTS['UL']}  ${EXPECTED_TOTALPRBAVAIL}
    ...  msg=A number of total available PRBs is not equal to expected value in uplink direction!
    Should Be Equal As Integers  ${RESULTS['DL']}  ${EXPECTED_NUMOFPRBSALLOC}
    ...  msg=A number of total available PRBs is not equal to expected value in downlink direction!

    Log  Numbers of total available PRBs are equal to expected values in both directions!  console=True


Test Specific Teardown
    Log  Test Specific Teardown  console=True

    Log  Restoring the initial state of BTS...  console=True
    Run Keyword If  ${GSM_SECTOR_MODIFIED}  Prepare GSM Sector For Shared Spectrum Usage - Teardown  ${GSM_CELL_ID}
    Stop Data Transfers For All Ues
    Detach UE  LTE_UE
    ca_INTER_RAT.Close all BSC sessions
    Collect BSC Logs


TC Setup
    Inter RAT Test Setup


TC Teardown
    INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783.Test Specific Teardown
    Inter RAT Test Teardown
