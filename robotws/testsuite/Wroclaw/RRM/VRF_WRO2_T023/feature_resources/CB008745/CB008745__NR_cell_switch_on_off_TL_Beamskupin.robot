*** Settings ***
Documentation
...   contact: Szymon Startek

Library     DateTime
Library     ute_ue
Resource    ../../resources/ca_INTER_RAT.robot


*** Variables ***
${NSA_UE_CAPABILITY}                            # Capability for UE used in test.
${LTE_CELL_ID}                                  # ID of anchor LTE cell
${NR_CELL_ID1}                                  # ID of NR cell belonging to ${POWER_GROUP_ID} where UE start data transfer
${NR_CELL_ID2}                                  # ID of NR cell belonging to ${POWER_GROUP_ID} where UE end data transfer
${POWER_GROUP_ID}                               # ID of power group used in TC
${NR_CELL_ID1_AVG_DL_THROUGHPUT}                # [Mbit/sec] Average NR tput before HO.
${NR_CELL_ID2_AVG_DL_THROUGHPUT}                # [Mbit/sec] Average NR tput after HO.
${APN}                                          # Variable is used to set APN for keyword 'Start Data Transfer'


*** Keywords ***
TC__CB008745__NR_cell_switch_on_off
    Set Tags    CA-INTER_RAT    AUTHOR-szymon.startek@nokia.com    OWNER-mariusz.daniel@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS23R2    FEATURE-CB008745   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Attach And Start DL Data Transfer
    Step 2: Check Measurements In Syslog And Admin To Confirm That 2nd Cell State Is notEnergySaving
    Step 3: Trigger HO To 2nd Cell
    Step 4: Await Data Transfer Finish
    Step 5: Check Measurements In Syslog And Admin To Confirm That 2nd Cell State Is energySaving


Preconditions
    Log  \n==== Prepare Environment For CB008745 NR Cell Switch On Off ====  console=True
    Set Global Variables
    5G Site Parameters Recommissioning For NRDRB-6  True
    Log  \n==== Energy Saving Should Be Activated By Default NR Cell ${NR_CELL_ID2} On TL ====  console=True
    Log  Check Admin To Confirm That NR Cell ${NR_CELL_ID2} State Is energySaving.  console=True
    Log  Wait max ${LBPS_MON_WIN_FOR_CELLS_OFF_TIME_FOR_WAITING}s to check if energy saving state changed.  console=True
    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  90s  10s
    ...  Analyze Power Group Load From Syslog For CB008745  ${POWER_GROUP_ID}  ${start_time}  NoTpt
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${LBPS_MON_WIN_FOR_CELLS_OFF_TIME_FOR_WAITING}s  10s
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID2}  energySaving  connection=gNB
    Set Attenuation For TC
    Require UE  NR_UE  ${NSA_UE_CAPABILITY}
    Log  = Prepare Environment For CB008745 NR Cell Switch On Off passed =  console=True


Step 1: Attach And Start DL Data Transfer
    Log  \n==== Step 1: Attach And Start DL Data Transfer In Power Group ${POWER_GROUP_ID} ====  console=True
    Prepare UE For Data Transfer  NR_UE  ${LTE_CELL_ID}  connection=gNB
    Log  Start LTE DL data transfer in cell ${NR_CELL_ID1} on UE1.  console=True
    ute_ue.Start Data Transfer  dt_name=DT1  ue_alias=NR_UE  direction=dl  protocol=tcp  duration=300s
    ...                         max_segment_size=1400  buffer=32M  apn=${APN}
    ${transfer_start_time} =  Get Current Date
    Set Test Variable  ${TRANSFER_START_TIME}  ${transfer_start_time}
    Sleep  5s  Reason=Wait for data transfer to stabilize.
    Check Data Transfer Is Alive  DT1


Step 2: Check Measurements In Syslog And Admin To Confirm That 2nd Cell State Is notEnergySaving
    Log  \n==== Step 2: Check Measurements In Syslog And Admin To Confirm That Nr Cell ${NR_CELL_ID2} State Is notEnergySaving ====  console=True
    Log  Wait ${LBPS_MON_WIN_FOR_CELLS_ON_TIME_FOR_WAITING}s to check if energy saving state changed.  console=True
    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  90s  10s
    ...  Analyze Power Group Load From Syslog For CB008745  ${POWER_GROUP_ID}  ${start_time}  Higher
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${LBPS_MON_WIN_FOR_CELLS_ON_TIME_FOR_WAITING}s  10s
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID2}  notEnergySaving  connection=gNB


Step 3: Trigger HO To 2nd Cell
    Log  \n==== Step 3: Trigger HO To Nr Cell ${NR_CELL_ID2} ====  console=True
    ${dl_tput}  ute_ue.Get Average Throughput  DT1  omit=10
    ${dl_tput} =  Evaluate  ${dl_tput}/1000.0
    Log  \nBefore HO Throughput:${dl_tput} Mbps  console=True
    Run Keyword And Continue On Failure
    ...  Verify Average Throughput With Deviation  DT1  ${NR_CELL_ID1_AVG_DL_THROUGHPUT} Mbits/sec  10%  omit=10
    Trigger HO
    ${get_ho_start_time} =  Get Current Date
    ${after_ho_time} =  Subtract Date From Date  ${get_ho_start_time}  ${TRANSFER_START_TIME}  exclude_millis=True
    Set Test Variable  ${AFTER_HO_TIME}  ${after_ho_time}


Step 4: Await Data Transfer Finish
    Log  \n==== Step 4: Await Data Transfer Finish In Power Group ${POWER_GROUP_ID} Verify Tput And Detach UE ====  console=True
    ute_ue.Await Data Transfer Finish  dt_name=DT1
    ${dl_tput}  ute_ue.Get Average Throughput  DT1  omit=${AFTER_HO_TIME}
    ${dl_tput} =  Evaluate  ${dl_tput}/1000.0
    Log  \After HO Throughput:${dl_tput} Mbps  console=True
    Run Keyword And Continue On Failure
    ...  Verify Average Throughput With Deviation  DT1  ${NR_CELL_ID2_AVG_DL_THROUGHPUT} Mbits/sec  10%  omit=${AFTER_HO_TIME}
    Detach UE  NR_UE


Step 5: Check Measurements In Syslog And Admin To Confirm That 2nd Cell State Is energySaving
    Log  \n==== Step 5: Check Measurements In Syslog And Admin To Confirm That Nr Cell ${NR_CELL_ID2} State Is energySaving ====  console=True
    Log  Wait max ${LBPS_MON_WIN_FOR_CELLS_OFF_TIME_FOR_WAITING}s to check if energy saving state changed.  console=True
    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  90s  10s
    ...  Analyze Power Group Load From Syslog For CB008745  ${POWER_GROUP_ID}  ${start_time}  NoTpt
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${LBPS_MON_WIN_FOR_CELLS_OFF_TIME_FOR_WAITING}s  10s
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID2}  energySaving  connection=gNB


5G Site Parameters Recommissioning For NRDRB-6
    [Arguments]  ${value}
    ${dldatasplitmode} =  Set Variable If  ${value}  dlOverF1U  dlOverF1UX2U
    Log  \n==== NSA Configuration Will Be Used ====  console=True
    Log  \n==== Recommissioning NRDRB-6 dlDataSplitMode=${dldatasplitmode} ====  console=True

    &{dictionary}=  Create Dictionary
    ...             actPrioritizeX2AfterInactivity=${false}
    ...             actX2DuplicateTxNSA3x=${false}
    ...             dlDataSplitBufferBuildUpThreshold=${5}
    ...             dlDataSplitBufferBuildUpThresholdPrioritizeX2=${5}
    ...             dlDataSplitGainThreshold=${5}
    ...             dlDataSplitMode=${dldatasplitmode}
    ...             dlNumOfCongOrGainDdds=${2}
    ...             inactivityThresholdForPrioritizeX2=${300}
    ...             inactivityThresholdForRestartPrioritizeX2=${100}
    ...             initialDLTrafficRouting=initDLoverF1U
    ...             nsa3xBearerAllowed=${true}
    ...             prioritizeX2Period=${500}
    ...             ulDataPath=ulOverNr
    ...             ulDataSplitThreshold=infinity
    Run Keyword If  '${RELEASE_LOCAL}' == 'SBTS23R4' and '${dldatasplitmode}' == 'dlOverF1U'
    ...  Set To Dictionary  ${dictionary}  dlPreferredPath=F1-U
    ...  ELSE IF  '${RELEASE_LOCAL}' >= 'SBTS24R1' and '${dldatasplitmode}' == 'dlOverF1U'
    ...  Set To Dictionary  ${dictionary}  dlPreferredPath=${EMPTY}
    ...  ELSE IF  '${RELEASE_LOCAL}' != 'SBTS23R2' and '${RELEASE_LOCAL}' != 'SBTS23R3' and '${dldatasplitmode}' == 'dlOverF1UX2U'
    ...  Set To Dictionary  ${dictionary}  dlPreferredPath=F1-U
    ${list}=  Create List
    Append To List  ${list}  ${dictionary}
    Set Test Variable  ${SCF_PARAMETERS_CHANGED}  True
    Perform Parameter Recommissioning  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-6
    ...  parameter=nsaDrbParam  operation=update  value=@{list}  connection=gNB


Set Global Variables
    Set Test Variable  ${SCF_PARAMETERS_CHANGED}  False

    ${bts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${MRBTS_ID}  ${bts_id}
    Set Test Variable  ${NRBTS_ID}  ${bts_id}

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

    ${lbps_max_load} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsMaxLoad']  dist_name_substring=False
    Set Test Variable  ${LBPS_MAX_LOAD}  ${lbps_max_load}

    ${lbps_min_load} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsMinLoad']  dist_name_substring=False
    Set Test Variable  ${LBPS_MIN_LOAD}  ${lbps_min_load}


Analyze Power Group Load From Syslog For CB008745
    [Documentation]
    ...  KW used to check check power group load for CB008745 feature based on syslog prints.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to check check power group load for CB008745 feature based on syslog prints.
    ...  If keyword fails it prints 'Analyzing power group load failed - retrying...' in teardown
    ...  since in most cases it will be run multiple times, before print's time and load of power
    ...  group is correct. It checks if time for print is newer than time passed in 'start_time'
    ...  argument and fails if no newer prints appeared. Load (pg_load) is compared to specific
    ...  conditions based on value passed in 'condition' argument:
    ...  NoTpt - 0 <= pg_load < min_treshold
    ...  Lower - 0 < pg_load < min_treshold
    ...  InRange - min_treshold <= pg_load <= max_treshold
    ...  Higher - max_treshold < pg_load
    ...  If condition is not fulfilled this keyword will fail.
    ...  This keyword returns value of pgload extracted from last print.
    ...  This keyword requires DateTime robot framework library to work correctly.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                                               |
    ...  +===================+======+===========================================================================+
    ...  | pwr_gr_id         | Yes  | ID of checked power group.                                                |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | start_time        | Yes  | Time from which it should be checked if new prints appeared.              |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | condition         | Yes  | Condition which power group load should fulfill. Possible values:         |
    ...  |                   |      | NoTpt (no data transfer is currently performed in power group and power   |
    ...  |                   |      | group load is lower than min threshold, can be equal to 0),               |
    ...  |                   |      | Lower (power group load is lower than min threshold, but should be        |
    ...  |                   |      | greater than 0), InRange (power group load is greater than min            |
    ...  |                   |      | threshold, but lower than max threshold), Higher (power group load        |
    ...  |                   |      | is greater than max threshold).                                           |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | min_treshold      | No   | Min threshold for power group load. Default value: ${LBPS_MIN_LOAD}.      |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | max_treshold      | No   | Max threshold for power group load. Default value: ${LBPS_MAX_LOAD}.      |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | alias             | No   | Alias for syslog. Default value: gNB.                                     |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  ${start_time} =  Get Time From BTS
    ...  Analyze Power Group Load From Syslog For CB008745  2  ${start_time}  NoTpt

    [Arguments]  ${pwr_gr_id}  ${start_time}  ${condition}  ${min_treshold}=${LBPS_MIN_LOAD}
    ...  ${max_treshold}=${LBPS_MAX_LOAD}  ${alias}=gNB

    ${syslog_msg} =  Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=EnergySavingAlgorithm.*powerGroup\\.id:\\s${pwr_gr_id},\\spgLoadAverCellSwitchOn:.*  timeout=10s  alias=${alias}
    Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=EnergySavingAlgorithm.*powerGroup.*  timeout=10s  alias=${alias}

    ${syslog_list} =  Split To Lines  ${syslog_msg}
    ${all_prints} =  Get Length  ${syslog_list}
    Should Be True  ${all_prints} > 0  msg=There were no prints found in syslog.

    ${current_line_time} =  Get Regexp Matches  ${syslog_list[-1]}
    ...  ^\\d+:([0-9]{2}\\.[0-9]{2}\\s[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\\.[0-9]{6})  1
    ${current_time} =  Convert Date  ${current_line_time[0]}  date_format=%d.%m %H:%M:%S.%f  result_format=%d.%m %H:%M:%S
    ${difference} =  Subtract Date From Date  ${current_time}  ${start_time}  exclude_millis=True
    ...  date1_format=%d.%m %H:%M:%S  date2_format=%d.%m %H:%M:%S
    Should Be True  ${difference} > 0  msg=Timestamp is not older than start time.

    ${current_line_pgload} =  Run Keyword And Continue On Failure  Get Regexp Matches  ${syslog_list[-1]}
    ...  EnergySavingAlgorithm.*powerGroup\\.id:\\s${pwr_gr_id},\\spgLoadAverCellSwitchOn:\\s(\\d+)  1
    Log  \nPower group load for PG${pwr_gr_id}=${current_line_pgload[0]}  console=True
    ${pg_load} =  Set Variable  ${current_line_pgload[0]}
    Run Keyword If  '${condition}' == 'NoTpt'  Should Be True  0 <= ${pg_load} < ${min_treshold}
    ...  msg=Power group load for PG${pwr_gr_id} (${pg_load}) is not lower than min treshold (${min_treshold}).
    ...  ELSE IF  '${condition}' == 'Lower'  Should Be True  0 < ${pg_load} < ${min_treshold}
    ...  msg=Power group load for PG${pwr_gr_id} (${pg_load}) is not in range (0;min treshold) (0;${min_treshold}).
    ...  ELSE IF  '${condition}' == 'InRange'  Should Be True  ${min_treshold} <= ${pg_load} <= ${max_treshold}
    ...  msg=Power group load for PG${pwr_gr_id} (${pg_load}) is not in range of <min treshold;max threshold> <${min_treshold};${max_treshold}>.
    ...  ELSE IF  '${condition}' == 'Higher'  Should Be True  ${max_treshold} < ${pg_load}
    ...  msg=Power group load for PG${pwr_gr_id} (${pg_load}) is not higher than max treshold (${max_treshold}).
    ...  ELSE  Fail  msg=Incorrect condition.
    [Return]  ${pg_load}
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Log  Analyzing power group load failed - retrying...  console=True


Set Attenuation For TC
    Set Attenuation   GNB_55014_CELL_83_ANCHOR   0dB
    Set Attenuation   GNB_55014_CELL_0   10dB


Trigger HO
    Get UE Info  NR_UE  ALL
    Set Attenuation  GNB_55014_CELL_5  0dB
    FOR  ${i}  IN RANGE  12  90  3
        Set Attenuation  GNB_55014_CELL_0  ${i}db
        Sleep  1s
    END
    Get UE Info  NR_UE  ALL


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== Test Specific Teardown ===  console=True
    Stop Data Transfers For All UEs
    Detach UE  NR_UE
    Set Attenuation For All Cells  100%
    Log  \n==== Energy Saving For NR Cell ${NR_CELL_ID2} Will Remain Enabled By Default On The TL ====  console=True
    Run Keyword If  ${SCF_PARAMETERS_CHANGED}  5G Site Parameters Recommissioning For NRDRB-6  False
    IWK Test Teardown  local_enb_connection=False  single_bts=True
