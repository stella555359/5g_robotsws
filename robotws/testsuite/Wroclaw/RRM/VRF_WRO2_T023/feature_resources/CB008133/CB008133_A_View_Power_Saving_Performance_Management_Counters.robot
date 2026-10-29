*** Settings ***
Documentation
...   contact: Szymon Startek

Library    ute_ue
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    taf.collectors.core
Library    taf.analyzer.pmcounter
Resource    ../../resources/ca_IWK.robot


*** Variables ***
${NR_CELL_ID}                              # ID of main tested NR cell
${CELL_ID_FOR_CALL}                        # ID of cell to which UE should attach during the test
${POWER_GROUP_ID}                          # ID of power group used in TC for which tested NR cell belong
${NR_UE_CAPABILITY}                        # NR UE capability
${CYCLE_COUNT}                             # Cycle count of start and stop DL data transfer above maximum load threshold
${M55601C02001_EXPECTED_VALUE}             # Expected value of M55601C02001 counter
${M55601C02002_LOWER_THRESHOLD}            # M55601C02002 counter lower threshold
${M55601C02002_HIGHER_THRESHOLD}           # M55601C02002 counter higher threshold
${COUNTER_PERIOD}                          # Period of counter
${TPUT_ABOVE_MAX_LOAD}                     # Value of throughput above maximum load threshold
${TPUT_BELOW_MIN_LOAD}                     # Value of throughput below minimum load threshold
${STATUS_CHECK_DELAY}                      # Value of delay before checking if energy saving state changed


*** Keywords ***
TC__CB008133_A_View_Power_Saving_Performance_Management_Counters
    Set Tags    CA-INTER_RAT    AUTHOR-igor.kleschenok@nokia.com   OWNER-piotr.1.maj@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com   PHASE-CRT   SW-SBTS23R1   FEATURE-CB008133   GROUP_IN_CHARGE-WRO_3_Vrf

    Preconditions
    Step 1: Start DL Data Transfer Below Minimum Load Threshold
    Step 2: Start and Stop DL Data Transfer Above Maximum Load Threshold Several Times
    Step 3: Collect And Compare Counters M55601C02001 M55601C02002


Preconditions
    Log  \n==== Preconditions ====  console=True
    Set Global Variables
    Check Element In SCF  ${PARSED_SCF_GNB}  NRBTS  NRBTS-${NRBTS_ID}  /p[@name='actNrLBmMimoRTXPowerSaving']
    ...  <p name="actNrLBmMimoRTXPowerSaving">true</p>  dist_name_substring=True
    Require UE  NR_UE  ${NR_UE_CAPABILITY}
    Log  = Preconditions passed =  console=True


Set Global Variables

    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${scf_path_gnb}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}
    Set Test Variable  ${PARSED_SCF_GNB}  ${parsed_scf_gnb}

    ${lbps_rtxs_on_time} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsRTXSOnTime']  dist_name_substring=True
    ${lbps_rtxs_on_time_for_waiting} =  Evaluate  ${lbps_rtxs_on_time} + ${STATUS_CHECK_DELAY}
    Set Test Variable  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}  ${lbps_rtxs_on_time_for_waiting}

    ${lbps_rtxs_off_time} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsRTXSOffTime']  dist_name_substring=True
    ${lbps_rtxs_off_time_for_waiting} =  Evaluate  ${lbps_rtxs_off_time} + ${STATUS_CHECK_DELAY}
    Set Test Variable  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}  ${lbps_rtxs_off_time_for_waiting}


Step 1: Start DL Data Transfer Below Minimum Load Threshold
    Log  \n=== Step 1: Start DL Data Transfer Below Minimum Load Threshold ===  console=True
    Prepare UE For Data Transfer  NR_UE  ${CELL_ID_FOR_CALL}  connection=gNB
    Log  NR_UE is connected to anchor LTE cell ${CELL_ID_FOR_CALL}    console=True
    Log  Start NR data transfer in cell ${NR_CELL_ID}    console=True
    Start Data Transfer  NR_DL1  NR_UE  dl  throughput=${TPUT_BELOW_MIN_LOAD}  protocol=tcp  max_segment_size=1400  duration=3600s
    ...  buffer=32M  packet_size=125000
    Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving  connection=gNB


Start DL Data Transfer Above Maximum Load Threshold
    Log  \n==== Start DL Data Transfer Above Maximum Load Threshold ====  console=True
    Log  Start second NR DL data transfer in cell ${NR_CELL_ID} on UE.    console=True
    Start Data Transfer  NR_DL2  NR_UE  dl  throughput=${TPUT_ABOVE_MAX_LOAD}  protocol=tcp  max_segment_size=1400  duration=600s  buffer=32M
    Log  Wait ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.
    Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  notEnergySaving  connection=gNB


Stop DL Data Transfer Above Maximum Load Threshold
    Log  \n==== Stop DL Data Transfer Above Maximum Load Threshold ====  console=True
    Stop Data Transfer  NR_DL2
    Log  Wait ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.
    Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving  connection=gNB


Step 2: Start and Stop DL Data Transfer Above Maximum Load Threshold Several Times
    Log  \n==== Step 2: Start and Stop DL Data Transfer Above Maximum Load Threshold Several Times ====  console=True
    ${sleep_time} =  Count Measurement Period
    Log  Wait ${sleep_time} till new period of counter is started..    console=True
    Sleep  ${sleep_time}s  reason=Wait till new period of counter is started.
    FOR    ${index}    IN RANGE    ${CYCLE_COUNT}
        Start DL Data Transfer Above Maximum Load Threshold
        Stop DL Data Transfer Above Maximum Load Threshold
        Log  Cycle number ${index} is finished ====  console=True
    END
    Log  Stop DL Data Transfer Below Minimum Load Threshold ====  console=True
    Stop Data Transfer  NR_DL1

Count Measurement Period

    ${current_time_on_sbts} =  Get Time From BTS  host_ip=${GNB_OAM_IP}  date_time_format=%M:%S
    ${minutes_now} =  Fetch From Left  ${current_time_on_sbts}  :
    ${seconds_now} =  Fetch From Right  ${current_time_on_sbts}  :
    ${minutes_int} =  Convert To Integer  ${minutes_now}
    ${seconds_int} =  Convert To Integer  ${seconds_now}
    ${waiting_time}  Evaluate  ${COUNTER_PERIOD}*60-(${minutes_int}%${COUNTER_PERIOD}*60+${seconds_int})
    [Return]  ${waiting_time}


Step 3: Collect And Compare Counters M55601C02001 M55601C02002
    Log  ==== Step 3: Collect And Compare Counters M55601C02001 M55601C02002 ====  console=True
    ${sleep_time} =  Count Measurement Period
    ${time_for_waiting} =  Evaluate  ${sleep_time} + 60
    Log  Wait ${time_for_waiting}s for counters from last period to be available on SBTS...    console=True
    Sleep  ${time_for_waiting}s  reason=Waiting for counters from last period to be available on SBTS.

    Wait Until Keyword Succeeds  5x  10s  Collect PM Counters  ${LOG_PATH}/pm_counters  host=${GNB_OAM_IP}
    ...                                                                    time_interval=15 min  intervals=15
    ${counter_list}   Create List  M55601C02001  M55601C02002
    ${counters_dict}  Get Values Of Counters From List  ${LOG_PATH}/pm_counters  ${counter_list}
    ...               MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  1

    Should Be Equal  ${counters_dict['M55601C02001'][0]}  ${M55601C02001_EXPECTED_VALUE}
    ...  msg=The value of counter M55601C02001 is other than ${M55601C02001_EXPECTED_VALUE}
    Should Be True  ${M55601C02002_LOWER_THRESHOLD} < ${counters_dict['M55601C02002'][0]} < ${M55601C02002_HIGHER_THRESHOLD}
    ...  msg=The value of counter M55601C02002 isn't in given range value


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  NR_UE
    IWK Test Teardown  local_enb_connection=False  single_bts=True
