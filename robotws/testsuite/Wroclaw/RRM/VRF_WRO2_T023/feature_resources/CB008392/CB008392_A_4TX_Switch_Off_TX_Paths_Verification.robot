*** Settings ***
Documentation
...  contact: Szymon Startek

Library    DateTime
Library    ute_ue
Library    taf.config.scf
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Resource    ../../resources/ca_IWK.robot


*** Variables ***
${NR_CELL_ID1}                                 # ID of main tested NR cell belonging to power group 1
${NR_CELL_ID2}                                 # ID of NR cell belonging to power group 2
${POWER_GROUP_ID1}                             # ID of power group 1 used in TC
${POWER_GROUP_ID2}                             # ID of power group 2 used in TC
${NR_UE_CAPABILITY1}                           # NR UE1 capability
${NR_UE_CAPABILITY2}                           # NR UE2 capability
${TPUT_ABOVE_MIN_LOAD}                         # Value of throughput above minimum load threshold
${TPUT_BELOW_MIN_LOAD}                         # Value of throughput below minimum load threshold
${MODIFICATIONS_LIST}                          # List with SCF parametres to modify


*** Keywords ***
TC__CB008392_A_4TX_Switch_Off_TX_Paths_Verification
    Set Tags    CA-INTER_RAT    AUTHOR-monika.ceglarek@nokia.com    OWNER-santiago.galindo@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS23R1    FEATURE-CB008392-A    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Check Measurements In Syslog
    Step 2: Start DL Data Transfer In Power Group 1
    Step 3: Start Additional DL Data Transfer In Power Group 1
    Step 4: Turn Off Energy Saving
    Step 5: Stop Additional DL Data Transfer In Power Group 1
    Step 6: Start Additional DL Data Transfer In Power Group 2
    Step 7: Turn On Energy Saving
    Step 8: Delete NRPGRP-2
    Step 9: Stop All Data Transfers


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Global Variables
    Check If Feature CB008392 Is Active
    Require UE  NR_UE1  ${NR_UE_CAPABILITY1}
    Require UE  NR_UE2  ${NR_UE_CAPABILITY2}
    Set Attenuation  GNB_CELL_8_1  15dB
    Set Attenuation  GNB_CELL_8_2  15dB
    Log  = Preconditions passed =  console=True


Set Global Variables
    Set Test Variable  ${POWER_SAVING_CHANGED}  False
    Set Test Variable  ${DELETED_POWER_GROUP2}  False

    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${scf_path_gnb}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}
    Set Test Variable  ${PARSED_SCF_GNB}  ${parsed_scf_gnb}

    ${lbps_rtxs_on_time} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID1}
    ...  /p[@name='lbpsRTXSOnTime']  dist_name_substring=True
    ${lbps_rtxs_on_time_for_waiting} =  Evaluate  ${lbps_rtxs_on_time} + 30
    Set Test Variable  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}  ${lbps_rtxs_on_time_for_waiting}

    ${lbps_rtxs_off_time} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID1}
    ...  /p[@name='lbpsRTXSOffTime']  dist_name_substring=True
    ${lbps_rtxs_off_time_for_waiting} =  Evaluate  ${lbps_rtxs_off_time} + 30
    Set Test Variable  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}  ${lbps_rtxs_off_time_for_waiting}

    ${lbps_rtx_max_load} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID1}
    ...  /p[@name='lbpsRTXMaxLoad']  dist_name_substring=True
    Set Test Variable  ${LBPS_RTX_MAX_LOAD}  ${lbps_rtx_max_load}

    ${lbps_rtx_min_load} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID1}
    ...  /p[@name='lbpsRTXMinLoad']  dist_name_substring=True
    Set Test Variable  ${LBPS_RTX_MIN_LOAD}  ${lbps_rtx_min_load}


Step 1: Check Measurements In Syslog
    Log  \n==== Step 1: Check Measurements In Syslog ====  console=True

    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  1min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  NoTpt
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  1min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  2  ${start_time}  NoTpt
    Log  Wait ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.

    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID1}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID2}  reducedEnergySaving  connection=gNB


Step 2: Start DL Data Transfer In Power Group 1
    Log  \n==== Step 2: Start DL Data Transfer In Power Group 1 ====  console=True

    Prepare UE For Data Transfer  NR_UE1  ${NR_CELL_ID1}  connection=gNB  lte_cell=False
    Log  Start NR DL data transfer in cell ${NR_CELL_ID1} on UE1.    console=True
    Start Data Transfer  NR_DL1  NR_UE1  dl  throughput=${TPUT_BELOW_MIN_LOAD}  protocol=tcp  max_segment_size=1400  duration=1200s  buffer=32M

    ${start_time} =  Get Time From BTS
    Check Data Transfer Is Alive  NR_DL1
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  1min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  Lower
    Log  Wait ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.

    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID1}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  Lower


Step 3: Start Additional DL Data Transfer In Power Group 1
    Log  \n==== Step 3: Start Additional DL Data Transfer In Power Group 1 ====  console=True

    Log  Start second NR DL data transfer in cell ${NR_CELL_ID1} on UE1.    console=True
    Start Data Transfer  NR_DL2  NR_UE1  dl  throughput=${TPUT_ABOVE_MIN_LOAD}  protocol=tcp  max_segment_size=1400  duration=600s  buffer=32M

    ${start_time} =  Get Time From BTS
    Check Data Transfer Is Alive  NR_DL2
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  1min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  InRange
    Log  Wait ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.

    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID1}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  InRange


Step 4: Turn Off Energy Saving
    Log  \n==== Step 4: Turn Off Energy Saving ====  console=True

    Set Test Variable  ${POWER_SAVING_CHANGED}  True
    Perform Parameter Recommissioning  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}  actNrLBRTXPowerSaving  update  false  connection=gNB
    Verify BTS States For IWK Test
    Wait Until Keyword Succeeds  10s  1s  Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID1}  notEnergySaving  connection=gNB
    Check Data Transfer Is Alive  NR_DL1
    Check Data Transfer Is Alive  NR_DL2


Step 5: Stop Additional DL Data Transfer In Power Group 1
    Log  \n==== Step 5: Stop Additional DL Data Transfer In Power Group 1 ====  console=True

    Stop Data Transfer  NR_DL2
    Log  Wait ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.

    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID1}  notEnergySaving  connection=gNB


Step 6: Start Additional DL Data Transfer In Power Group 2
    Log  \n==== Step 6: Start Additional DL Data Transfer In Power Group 2 ====  console=True

    Prepare UE For Data Transfer  NR_UE2  ${NR_CELL_ID2}  connection=gNB  lte_cell=False
    Log  Start NR DL data transfer in cell ${NR_CELL_ID2} on UE2.    console=True
    Start Data Transfer  NR_DL3  NR_UE2  dl  throughput=${TPUT_BELOW_MIN_LOAD}  protocol=tcp  max_segment_size=1400  duration=1200s  buffer=32M
    Log  Wait ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.
    Check Data Transfer Is Alive  NR_DL3

    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID1}  notEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID2}  notEnergySaving  connection=gNB


Step 7: Turn On Energy Saving
    Log  \n==== Step 7: Turn On Energy Saving ====  console=True

    Perform Parameter Recommissioning  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}  actNrLBRTXPowerSaving  update  true  connection=gNB
    Set Test Variable  ${POWER_SAVING_CHANGED}  False
    Verify BTS States For IWK Test

    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  1min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  Lower
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  1min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  2  ${start_time}  Lower
    Log  Wait ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.

    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID1}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID2}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  Lower
    Run Keyword And Continue On Failure
    ...  Analyze Power Group Load From Syslog For CB008392  2  ${start_time}  Lower


Step 8: Delete NRPGRP-2
    Log  \n==== Step 8: Delete NRPGRP-2 ====  console=True

    ${original_scf_path}  ${_} =  Save And Parse SCF  original_SCF  alias=gNB
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/original_SCF.xml  console=True
    Log  Creating delta and reverted delta.  console=True
    ${gnb_scf} =  Load SCF  ${original_scf_path}
    Create SCF Modifications List
    Perform SCF Modification  ${MODIFICATIONS_LIST}
    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF.xml
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/modified_SCF.xml  console=True
    Calculate Delta SCF  ${LOG_PATH}/misc_logs/modified_SCF.xml  ${original_scf_path}  ${LOG_PATH}/misc_logs/delta_remove_gr2.json
    Log  Delta saved under: ${LOG_PATH}/misc_logs/delta_remove_gr2.json  console=True
    Calculate Delta SCF  ${original_scf_path}  ${LOG_PATH}/misc_logs/modified_SCF.xml  ${LOG_PATH}/misc_logs/delta_revert.json
    Log  Delta saved under: ${LOG_PATH}/misc_logs/delta_revert.json  console=True
    Log  Performing delta recommissioning...  console=True
    Set Test Variable  ${DELETED_POWER_GROUP2}  True
    Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/delta_remove_gr2.json  connection=gNB
    ${_}  ${_} =  Save And Parse SCF  SCF_removed_gr2  alias=gNB
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/SCF_removed_gr2.xml  console=True
    Verify BTS States For IWK Test

    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  1min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  Lower
    ${double_wait_timer} =  Evaluate  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG} * 2 - 30
    Log  Wait ${double_wait_timer}s to check if energy saving state changed.    console=True
    Sleep  ${double_wait_timer}s  reason=Waiting to check if energy saving state changed.
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID1}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID2}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  Lower


Step 9: Stop All Data Transfers
    Log  \n==== Step 9: Stop All Data Transfers ====  console=True

    Check Data Transfer Is Alive  NR_DL1
    Check Data Transfer Is Alive  NR_DL3
    Stop Data Transfer  NR_DL1
    Stop Data Transfer  NR_DL3
    Detach UE  NR_UE1
    Detach UE  NR_UE2

    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  1min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  NoTpt
    Log  Wait ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.    console=True
    Sleep  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.

    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID1}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID2}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Analyze Power Group Load From Syslog For CB008392  1  ${start_time}  NoTpt


Create SCF Modifications List
    ${modifications_list} =  Create List  delete:NRPGRP-${POWER_GROUP_ID2}
    ...  add:NRPGRP-${POWER_GROUP_ID1}:lbpsCellList:{"lbpsCellSOOrder": "2", "lbpsUseExtConfig": "false", "nrCellId": "${NR_CELL_ID2}"}
    Set Test Variable  ${MODIFICATIONS_LIST}   ${modifications_list}


Revert Power Group Deletion Changes
    Log  Performing delta recommissioning...  console=True
    Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/delta_revert.json  connection=gNB
    ${_}  ${_} =  Save And Parse SCF  SCF_reverted  alias=gNB
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/SCF_reverted.xml  console=True
    Verify BTS States For IWK Test


Debug Syslog Prints
    ${syslog} =  Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=EnergySavingAlgorithm.*  timeout=10s  alias=gNB
    Create File    ${LOG_PATH}/misc_logs/syslogDebug1.txt    ${syslog}
    ${syslog} =  Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=EnergySavingService.*  timeout=10s  alias=gNB
    Create File    ${LOG_PATH}/misc_logs/syslogDebug2.txt    ${syslog}


TC Setup
    IWK Test Setup  local_enb_connection=False


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Set Attenuation For All Cells  100%
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  NR_UE1
    Detach UE  NR_UE2
    Run Keyword If  ${POWER_SAVING_CHANGED}  Run Keywords  Perform Parameter Recommissioning  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}
    ...  actNrLBRTXPowerSaving  update  true  connection=gNB
    ...  AND  Verify BTS States For IWK Test

    Run Keyword If  ${DELETED_POWER_GROUP2}  Revert Power Group Deletion Changes
    Run Keyword And Ignore Error  Debug Syslog Prints
    IWK Test Teardown  delta_exists=False  local_enb_connection=False

