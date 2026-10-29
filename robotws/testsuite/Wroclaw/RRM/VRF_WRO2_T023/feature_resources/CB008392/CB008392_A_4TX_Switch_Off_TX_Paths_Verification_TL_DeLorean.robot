*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library    ute_ue
Library    taf.config.scf
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Resource    ../../resources/ca_IWK.robot


*** Variables ***
${NR_CELL_ID}                                 # ID of main tested NR cell belonging to power group 1
${POWER_GROUP_ID}                             # ID of power group 1 used in TC
${NR_UE_CAPABILITY}                           # NR UE1 capability


*** Keywords ***
TC__CB008392_A_4TX_Switch_Off_TX_Paths_Verification_TL_DeLorean
    Set Tags    CA-INTER_RAT    AUTHOR-monika.ceglarek@nokia.com    OWNER-santiago.galindo@nokia.com
    ...         MAINTAINER-igor.kleschenok@nokia.com    PHASE-CRT   SW-SBTS24R1    FEATURE-CB008392-A    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Check If Energy Saving State Changed
    Step 2: Start DL Data Transfer
    Step 3: Start Additional DL Data Transfer
    Step 4: Turn Off Energy Saving
    Step 5: Stop Additional DL Data Transfer
    Step 6: Turn On Energy Saving
    Step 7: Stop All Data Transfers


Preconditions
    Log  \n==== Preconditions ====  console=True
    Set Global Variables
    Check If Feature CB008392 Is Active
    Require UE  NR_UE1  ${NR_UE_CAPABILITY}
    Log  = Preconditions passed =  console=True


Set Global Variables
    Set Test Variable  ${POWER_SAVING_CHANGED}  False

    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${scf_path_gnb}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}
    Set Test Variable  ${PARSED_SCF_GNB}  ${parsed_scf_gnb}

    ${lbps_rtxs_on_time} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsRTXSOnTime']  dist_name_substring=True
    ${lbps_rtxs_on_time_for_waiting} =  Evaluate  ${lbps_rtxs_on_time} + 30
    Set Test Variable  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}  ${lbps_rtxs_on_time_for_waiting}

    ${lbps_rtxs_off_time} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsRTXSOffTime']  dist_name_substring=True
    ${lbps_rtxs_off_time_for_waiting} =  Evaluate  ${lbps_rtxs_off_time} + 30
    Set Test Variable  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}  ${lbps_rtxs_off_time_for_waiting}


Step 1: Check If Energy Saving State Changed
    Log  \n==== Step 1: Check If Energy Saving State Changed ====  console=True
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving  connection=gNB


Step 2: Start DL Data Transfer
    Log  \n==== Step 2: Start DL Data Transfer ====  console=True
    Prepare UE For Data Transfer  NR_UE1  ${NR_CELL_ID}  connection=gNB  lte_cell=${LTE_CELL}
    Log  Start NR DL data transfer in cell ${NR_CELL_ID} on UE1.    console=True
    Start Data Transfer  NR_DL1  NR_UE1  dl  throughput=1 Mbits/sec  protocol=tcp  max_segment_size=1400  duration=1200s
    ...  buffer=32M  packet_size=125000
    Check Data Transfer Is Alive  NR_DL1
    Log  Wait ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving  connection=gNB


Step 3: Start Additional DL Data Transfer
    Log  \n==== Step 3: Start Additional DL Data Transfer ====  console=True
    Log  Start second NR DL data transfer in cell ${NR_CELL_ID} on UE1.    console=True
    Start Data Transfer  NR_DL2  NR_UE1  dl  throughput=50 Mbits/sec  protocol=tcp  max_segment_size=1400  duration=600s  buffer=32M
    Check Data Transfer Is Alive  NR_DL2
    Log  Wait ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving  connection=gNB


Step 4: Turn Off Energy Saving
    Log  \n==== Step 4: Turn Off Energy Saving ====  console=True
    Set Test Variable  ${POWER_SAVING_CHANGED}  True
    Perform Parameter Recommissioning  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}  actNrLBRTXPowerSaving  update  false  connection=gNB
    Verify BTS States For IWK Test  eNB_alias=gNB
    Wait Until Keyword Succeeds  10s  1s  Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  notEnergySaving  connection=gNB
    Check Data Transfer Is Alive  NR_DL1
    Check Data Transfer Is Alive  NR_DL2


Step 5: Stop Additional DL Data Transfer
    Log  \n==== Step 5: Stop Additional DL Data Transfer ====  console=True
    Stop Data Transfer  NR_DL2
    Log  Wait ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  notEnergySaving  connection=gNB


Step 6: Turn On Energy Saving
    Log  \n==== Step 6: Turn On Energy Saving ====  console=True
    Perform Parameter Recommissioning  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}  actNrLBRTXPowerSaving  update  true  connection=gNB
    Set Test Variable  ${POWER_SAVING_CHANGED}  False
    Verify BTS States For IWK Test  eNB_alias=gNB
    Log  Wait ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving  connection=gNB


Step 7: Stop All Data Transfers
    Log  \n==== Step 7: Stop All Data Transfers ====  console=True
    Check Data Transfer Is Alive  NR_DL1
    Stop Data Transfer  NR_DL1
    Detach UE  NR_UE1
    Log  Wait ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving  connection=gNB


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  NR_UE1
    Run Keyword If  ${POWER_SAVING_CHANGED}  Run Keywords  Perform Parameter Recommissioning  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}
    ...  actNrLBRTXPowerSaving  update  true  connection=gNB
    ...  AND  Verify BTS States For IWK Test  eNB_alias=gNB
    IWK Test Teardown    local_enb_connection=False  single_bts=True
