*** Settings ***
Documentation
...  contact: Szymon Startek

Library    ute_ue
Library    taf.config.scf
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Resource    ../../resources/ca_IWK.robot


*** Variables ***
${NR_CELL_ID}                                 # ID of main tested NR cell
${NR_UE_CAPABILITY}                           # NR UE capability
${COUNTER_PERIOD}                             # Period of checked counters (value of parameters miNrCaDuCp and miNrPowerSavingBwp in minutes)
${POWER_SAVING_BWP_ID}                        # Id of BWP Power Saving
${PCELL_ATTENUATOR_ALIAS}                     # Name of the attenuator ports mapped to the primary cell in ta_ue_config.yaml file
${SCELL_ATTENUATOR_ALIAS}                     # Name of the attenuator ports mapped to the secondary cell in ta_ue_config.yaml file


*** Keywords ***
TC__RRM__CA_SCell_Small_Bwp_Power_Saving_BWP__CB008541-5G-B
    Set Tags    CA-INTER_RAT    AUTHOR-michal.piechowski@nokia.com    OWNER-daniel.majda@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS24R1    FEATURE-CB008541-5G-B    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Start DL Data Transfer
    Step 2: Collect Counters
    Step 3: Stop DL Data Transfer
    Step 4: Check Counters Values


Preconditions
    Log  \n==== Preconditions ====  console=True
    Set Test Variable  ${PRINTS_EXIST}  False
    ${global_nr_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${NR_CELL_ID}
    Set Test Variable  ${NR_CALL_CELL_ID}  ${global_nr_cell_id}
    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    Check If UE Power Saving Is Enabled

    Require UE  NR_UE  ${NR_UE_CAPABILITY}
    Set Attenuation    ${PCELL_ATTENUATOR_ALIAS}    0dB
    Log  \n= Preconditions passed =  console=Truel

Check If UE Power Saving Is Enabled
    ${_}  ${scf_gnb} =  Save And Parse SCF  SCF_gNB_changed  alias=gNB
    Log  Checking if MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID} has actMultipleDedicatedBWPs=true...  console=True
    Check Element In SCF  ${scf_gnb}  NRBTS  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}  /p[@name='actMultipleDedicatedBWPs']
    ...  <p name="actMultipleDedicatedBWPs">true</p>  dist_name_substring=True

    Log  Checking if NRCELL-${NR_CELL_ID} has actPowerSavingBWP=true...  console=True
    Check Element In SCF  ${scf_gnb}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='actPowerSavingBWP']
    ...  <p name="actPowerSavingBWP">true</p>  dist_name_substring=True

    Log  Checking if NRCELL-${NR_CELL_ID} has actEnhMultipleDedicatedBWPs=true...  console=True
    Check Element In SCF  ${scf_gnb}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='actEnhMultipleDedicatedBWPs']
    ...  <p name="actEnhMultipleDedicatedBWPs">true</p>  dist_name_substring=True

    Log  Checking if BWP_PROFILE-${POWER_SAVING_BWP_ID} has bwpType=powerSaving...  console=True
    Check Element In SCF  ${scf_gnb}  BWP_PROFILE  BWP_PROFILE-${POWER_SAVING_BWP_ID}  /p[@name='bwpType']
    ...  <p name="bwpType">powerSaving</p>  dist_name_substring=True

    Log  Checking if NRCELL-${NR_CELL_ID} has bwpDN=MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${POWER_SAVING_BWP_ID}...  console=True
    Check If Element Exists In SCF  ${scf_gnb}  NRCELL  NRCELL-${NR_CELL_ID}
    ...  /list[@name='cellBwpList']/item/p[@name='bwpDN'][.='MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${POWER_SAVING_BWP_ID}']
    ...  dist_name_substring=True

    Log  Checking if value of miNrCaDuCp is equal to ${COUNTER_PERIOD} min...  console=True
    Check Element In SCF  ${scf_gnb}  NRPMRNL  NRPMRNL-1  /p[@name='miNrCaDuCp']
    ...  <p name="miNrCaDuCp">${COUNTER_PERIOD}min</p>  dist_name_substring=True

    Log  Checking if value of miNrPowerSavingBwp is equal to ${COUNTER_PERIOD} min...  console=True
    Check Element In SCF  ${scf_gnb}  NRPMRNL  NRPMRNL-1  /p[@name='miNrPowerSavingBwp']
    ...  <p name="miNrPowerSavingBwp">${COUNTER_PERIOD}min</p>  dist_name_substring=True

Step 1: Start DL Data Transfer
    Log  \n==== Step 1: Start DL Data Transfer ====  console=True
    ${sleep_time} =  ca_IWK.Count Measurement Period    ip=${GNB_OAM_IP}    counter_period=${COUNTER_PERIOD}
    ${end_of_sleep_date} =  Get Current Date  increment=${sleep_time}s  result_format=%H:%M:%S
    Log  \nWaiting for new counters interval until ${end_of_sleep_date}  console=True
    Sleep  ${sleep_time}s  reason=Wait till new counters interval.

    Prepare UE For Data Transfer  NR_UE  ${NR_CELL_ID}  connection=gNB  lte_cell=False
    Set Attenuation    ${SCELL_ATTENUATOR_ALIAS}    0dB
    Start Data Transfer  NR_DT  NR_UE  dl  throughput=500 Mbits/sec  protocol=tcp
    ...                  max_segment_size=1400  duration=600s  buffer=32M
    Sleep  10s  reason=Wait stabilyze data transfer.
    Check Data Transfer Is Alive  NR_DT


Step 2: Collect Counters
    Log  \n==== Step 2: Collect Counters ====  console=True
    ${sleep_time} =  ca_IWK.Count Measurement Period    ip=${GNB_OAM_IP}    counter_period=${COUNTER_PERIOD}    delta=60
    ${end_of_sleep_date} =  Get Current Date  increment=${sleep_time}s  result_format=%H:%M:%S
    Log  \nWaiting for counters collection until ${end_of_sleep_date}  console=True
    Sleep  ${sleep_time}s  reason=Wait till counters are collected.

    Wait Until Keyword Succeeds  5x  10s  Collect PM Counters  ${LOG_PATH}/pm_counters  host=${GNB_OAM_IP}
    ...  time_interval=${COUNTER_PERIOD} min  intervals=${COUNTER_PERIOD}
    ${counter_list}   Create List  M55167C00002  M55167C00003  M55351C00001
    ${counters_dict}  Get Values Of Counters From List  ${LOG_PATH}/pm_counters  ${counter_list}
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  1
    Set Test Variable  ${COUNTERS_DICT}  ${counters_dict}


Step 3: Stop DL Data Transfer
    Log  \n==== Step 3: Stop DL Data Transfer ====  console=True
    Stop Data Transfer  NR_DT


Step 4: Check Counters Values
    Log  \n==== Step 4: Check Counters Values ====  console=True
    Run Keyword And Continue On Failure
    ...  Should Be Equal  ${counters_dict['M55351C00001'][0]}  1
         ...  msg=The value of counter M55351C00001 is not equal to 1
    Run Keyword And Continue On Failure
    ...  Should Be Equal  ${counters_dict['M55167C00003'][0]}  0
         ...  msg=The value of counter M55167C00003 is other than 0
    ${m55167c00002_upper_limit} =  Evaluate  ${COUNTER_PERIOD}*60+1
    Run Keyword And Continue On Failure
    ...  Should Be True  0 < ${counters_dict['M55167C00002'][0]} < ${m55167c00002_upper_limit}
         ...  msg=The value of counter M55167C00002=${counters_dict['M55167C00002'][0]} isn't in given range value (0,${m55167c00002_upper_limit})


TC Setup
    IWK Test Setup  local_enb_connection=False


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  NR_UE
    Set Attenuation For All Cells  100%
    IWK Test Teardown  local_enb_connection=False
