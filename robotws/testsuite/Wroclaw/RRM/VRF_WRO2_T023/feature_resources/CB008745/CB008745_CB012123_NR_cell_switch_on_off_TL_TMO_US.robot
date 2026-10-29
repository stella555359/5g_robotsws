*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library    ute_ue
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    taf.collectors.core
Resource   ../../resources/ca_IWK.robot



*** Variables ***
${NR_CELL_ID1}                                  # ID of first NR cell belonging to ${POWER_GROUP_ID}
${NR_CELL_ID2}                                  # ID of second NR cell belonging to ${POWER_GROUP_ID}
${POWER_GROUP_ID}                               # ID of power group used in TC
${APN}                                          # Variable is used to set APN for keyword 'Start Data Transfer'
${NR_CELL_ID1_FOR_CALL}                         # ID of first NR cell belonging to power group for call
${NR_CELL_ID2_FOR_CALL}                         # ID of second NR cell belonging to power group for call
${GNB_ID}                                       # NR bts ID


*** Keywords ***
TC__CB008745_CB012123_NR_cell_switch_on_off_TL_TMO_US
    Set Tags    CA-INTER_RAT    AUTHOR-igor.kleschenok@nokia.com    OWNER-mariusz.daniel@nokia.com
    ...         MAINTAINER-igor.kleschenok@nokia.com    PHASE-CRT   SW-SBTS23R2    FEATURE-CB008745_CB012123   GROUP_IN_CHARGE-VRF_WRO2_T03

    Preconditions
    Step 1: Start DL Data Transfer In First NR Cell Belonging To Power Group
    Step 2: Check If State Of Second NR Cell Is NotEnergySaving
    Step 3: Perform Data Transfer In Second NR Cell
    Step 4: Stop DL Data Transfer In First NR Cell Belonging To Power Group
    Step 5: Check If State Of Second NR Cell Is EnergySaving


Preconditions

    Log  \n==== Prepare Environment For CB008745 NR Cell Switch On Off ====  console=True
    Set Global Variables
    Log  \n==== Energy Saving Should Be Activated By Default NR Cell ${NR_CELL_ID2} On TL ====  console=True
    Log  Check Admin To Confirm That NR Cell ${NR_CELL_ID2} State Is energySaving.  console=True
    Log  Wait max ${LBPS_MON_WIN_FOR_CELLS_OFF_TIME_FOR_WAITING}s to check if energy saving state changed.  console=True
    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  90s  10s
    ...  Analyze Power Group Load From Syslog For CB008392  ${POWER_GROUP_ID}  ${start_time}  NoTpt
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${LBPS_MON_WIN_FOR_CELLS_OFF_TIME_FOR_WAITING}s  10s
    ...  Check Energy Saving State For NR Cell TL TMO  ${NRBTS_ID}  ${GNB_ID}  ${NR_CELL_ID2}  energySaving  connection=gNB
    Set Attenuation  GNB_CELL_4  0dB
    Require UE  NR_UE1  NR_L3_CALL
    Require UE  NR_UE2  NR_KONA_CALL
    Log  = Prepare Environment For CB008745 NR Cell Switch On Off passed =  console=True


Step 1: Start DL Data Transfer In First NR Cell Belonging To Power Group

    Log  \n=== Step 1: Start DL Data Transfer In First NR Cell Belonging To Power Group ${POWER_GROUP_ID} ===  console=True
    Prepare UE For Data Transfer  NR_UE1  ${NR_CELL_ID1_FOR_CALL}  connection=gNB
    Start Data Transfer  NR_DL1  NR_UE1  dl  protocol=tcp  max_segment_size=1400  duration=1200s  buffer=32M  apn=${APN}  parallel_streams=4
    Log  \n Data Transfer Is Started In First NR Cell  console=True


Step 2: Check If State Of Second NR Cell Is NotEnergySaving
    Log  \n==== Step 2: Check Measurements In Syslog And Admin To Confirm That Second NR Cell State Is notEnergySaving ====  console=True
    Check Data Transfer Is Alive  NR_DL1
    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  90s  10s
    ...  Analyze Power Group Load From Syslog For CB008392  ${POWER_GROUP_ID}  ${start_time}  Higher
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${LBPS_MON_WIN_FOR_CELLS_ON_TIME_FOR_WAITING}s  10s
    ...  Check Energy Saving State For NR Cell TL TMO  ${NRBTS_ID}  ${GNB_ID}  ${NR_CELL_ID2}  notEnergySaving  connection=gNB


Step 3: Perform Data Transfer In Second NR Cell

    Log  \n==== Step 3: Perform Data Transfer In Second NR Cell ====  console=True
    Set Attenuation   GNB_CELL_21   0dB
    Prepare UE For Data Transfer  NR_UE2  ${NR_CELL_ID2_FOR_CALL}  connection=gNB
    Start Data Transfer  NR_DL2  NR_UE2  dl  protocol=tcp  max_segment_size=1400  duration=1200s  buffer=32M  apn=${APN}
    Sleep  15s  reason=Wait until the call is stable.
    Check Data Transfer Is Alive  NR_DL2
    Log  \n Data Transfer Is Started In Secondary NR Cell console=True
    Stop Data Transfer  NR_DL2


Step 4: Stop DL Data Transfer In First NR Cell Belonging To Power Group
    Log  \n=== Step 4: Stop DL Data Transfer In First NR Cell Belonging To Power Group ===  console=True
    Stop Data Transfer  NR_DL1
    Log  \n Data Transfer Is Stopped In First NR Cell  console=True


Step 5: Check If State Of Second NR Cell Is EnergySaving
    Log  \n==== Step 5: Check That Second NR Cell State Is EnergySaving ====  console=True
    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  90s  10s
    ...  Analyze Power Group Load From Syslog For CB008392  ${POWER_GROUP_ID}  ${start_time}  NoTpt
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${LBPS_MON_WIN_FOR_CELLS_OFF_TIME_FOR_WAITING}s  10s
    ...  Check Energy Saving State For NR Cell TL TMO  ${NRBTS_ID}  ${GNB_ID}  ${NR_CELL_ID2}  energySaving  connection=gNB


Set Global Variables

    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${_}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${PARSED_SCF_GNB}  ${parsed_scf_gnb}

    ${lbps_mon_win_for_cells_on} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsMonWinForCellSOn']  dist_name_substring=False
    ${lbps_mon_win_for_cells_on_time_for_waiting} =  Evaluate  ${lbps_mon_win_for_cells_on} + 60
    Set Test Variable  ${LBPS_MON_WIN_FOR_CELLS_ON_TIME_FOR_WAITING}  ${lbps_mon_win_for_cells_on_time_for_waiting}

    ${lbps_mon_win_for_cells_off} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsMonWinForCellSOff']  dist_name_substring=False
    ${lbps_mon_win_for_cells_off_time_for_waiting} =  Evaluate  ${lbps_mon_win_for_cells_off} + 120
    Set Test Variable  ${LBPS_MON_WIN_FOR_CELLS_OFF_TIME_FOR_WAITING}  ${lbps_mon_win_for_cells_off_time_for_waiting}


Check Energy Saving State For NR Cell TL TMO
    [Arguments]  ${bts_id}  ${gnb_id}  ${nr_cell_id}  ${expected_saving_state}  ${connection}=gNB
    ${nr_cell1_info} =  Get Cell Specific Info  MRBTS-${bts_id}/NRBTS-${gnb_id}/NRCELL-${nr_cell_id}  connection=${connection}
    Log  \nFor cell ${nr_cell_id}: \nCurrent energy saving state: ${nr_cell1_info['energySavingState']}.  console=True
    Log  \nExpected energy saving state: ${expected_saving_state}  console=True
    Should Be Equal As Strings  ${nr_cell1_info['energySavingState']}  ${expected_saving_state}
    ...  msg=Current energy saving state: ${nr_cell1_info['energySavingState']} is different than expected: ${expected_saving_state}


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  NR_UE1
    Detach UE  NR_UE2
    IWK Test Teardown  local_enb_connection=False  single_bts=True
