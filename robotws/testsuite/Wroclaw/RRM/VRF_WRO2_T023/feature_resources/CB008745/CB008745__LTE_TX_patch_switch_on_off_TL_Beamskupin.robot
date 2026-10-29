*** Settings ***
Documentation
...   contact: Szymon Startek

Library     DateTime
Library     ute_ue
Resource    ../../resources/ca_INTER_RAT.robot


*** Variables ***
${NSA_UE_CAPABILITY}                            # Capability for UE used in test.
${LTE_CELL_ID}                                  # ID of main tested LTE cell belonging to power group 1
${POWER_GROUP_ID}                               # ID of power group used in TC
${LTE_ONLY}                                     # If True then LTE only is used for TC,
# if False then NSA is used For NRDRB-6 dlDataSplitMode=dlOverX2U initialDLTrafficRouting=initDLoverX2U
${LTE_MIMO_2x2_DL_THROUGHPUT}                   # [Mbit/sec] Average LTE tput including only time when LTE cell is using 2x2 mimo.
${LTE_MIMO_4x4_DL_THROUGHPUT}                   # [Mbit/sec] Average LTE tput including only time when LTE cell is using 4x4 mimo.
${APN}                                          # Variable is used to set APN for keyword 'Start Data Transfer'


*** Keywords ***
TC__CB008745__LTE_TX_patch_switch_on_off
    Set Tags    CA-INTER_RAT    AUTHOR-szymon.startek@nokia.com    OWNER-mariusz.daniel@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS23R2    FEATURE-CB008745   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Attach And Start DL Data Transfer
    Step 2: Check Admin To Confirm That LTE Cell State Is notEnergySaving
    Step 3: Await Data Transfer Finish
    Step 4: Check Admin To Confirm That LTE Cell State Is ReducedEnergySaving


Preconditions
    Log  \n==== Prepare Environment For CB008745 LTE TX Patch Switch On Off ====  console=True
    Set Global Variables
    Activation Parameters For Test Configuration LTE Only Or NSA  True
    Log  \n==== Energy Saving Should Be Activated By Default LTE Cell ${LTE_CELL_ID} On TL ====  console=True
    Log  Check Admin To Confirm That Lte Cell ${LTE_CELL_ID} State Is ReducedEnergySaving.  console=True
    Log  Wait max ${LBPS_MON_WIN_FOR_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.  console=True
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${LBPS_MON_WIN_FOR_RTXS_OFF_TIME_FOR_WAITNIG}s  10s
    ...  Check Energy Saving State For LTE Cell  ${MRBTS_ID}  ${LNBTS_ID}  ${LTE_CELL_ID}  ReducedEnergySaving  connection=gNB
    Set Attenuation For TC
    Require UE  NR_UE  ${NSA_UE_CAPABILITY}
    Log  = Prepare Environment For CB008745 LTE TX Patch Switch On Off passed =  console=True


Step 1: Attach And Start DL Data Transfer
    Log  \n==== Step 1: Attach And Start DL Data Transfer In Power Group ${POWER_GROUP_ID} ====  console=True
    Prepare UE For Data Transfer  NR_UE  ${LTE_CELL_ID}  connection=gNB
    Log  Start LTE DL data transfer in cell ${LTE_CELL_ID} on UE1.  console=True
    ute_ue.Start Data Transfer  dt_name=DT1  ue_alias=NR_UE  direction=dl  protocol=tcp  duration=60s
    ...                         max_segment_size=1400  apn=${APN}
    ${transfer_start_time} =  Get Current Date
    Set Test Variable  ${TRANSFER_START_TIME}  ${transfer_start_time}
    Sleep  5s  Reason=Wait for data transfer to stabilize.
    Check Data Transfer Is Alive  DT1

    Sleep  5s  Reason=Wait 5s before verifying throughput.
    ${dl_tput}  ute_ue.Get Average Throughput  DT1  omit=5
    ${dl_tput} =  Evaluate  ${dl_tput}/1000.0
    Log  \MIMO 2x2 Throughput:${dl_tput} Mbps  console=True
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation  DT1  ${LTE_MIMO_2x2_DL_THROUGHPUT} Mbits/sec  10%  omit=5


Step 2: Check Admin To Confirm That LTE Cell State Is notEnergySaving
    Log  \n==== Step 2: Check Admin To Confirm That Lte Cell ${LTE_CELL_ID} State Is NotEnergySaving ====  console=True
    Log  Wait ${LBPS_MON_WIN_FOR_RTXS_ON_TIME_FOR_WAITNIG}s to check if energy saving state changed.  console=True
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${LBPS_MON_WIN_FOR_RTXS_ON_TIME_FOR_WAITNIG}s  10s
    ...  Check Energy Saving State For LTE Cell  ${MRBTS_ID}  ${LNBTS_ID}  ${LTE_CELL_ID}  NotEnergySaving  connection=gNB
    ${present_time} =  Get Current Date
    ${notenergysaving_time} =  Subtract Date From Date  ${present_time}  ${TRANSFER_START_TIME}  exclude_millis=True
    Set Test Variable  ${NOTENERGYSAVING_TIME}  ${notenergysaving_time}
    Log   ${NOTENERGYSAVING_TIME}    console=True


Step 3: Await Data Transfer Finish
    Log  \n==== Step 3: Await Data Transfer Finish In Power Group ${POWER_GROUP_ID} Verify Tput And Detach UE ====  console=True
    ute_ue.Await Data Transfer Finish  dt_name=DT1
    ${not_energy_saving_omit} =  Evaluate  ${NOTENERGYSAVING_TIME}+2
    ${dl_tput}  ute_ue.Get Average Throughput  DT1  omit=${not_energy_saving_omit}
    ${dl_tput} =  Evaluate  ${dl_tput}/1000.0
    Log  \MIMO 4x4 Throughput:${dl_tput} Mbps  console=True
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation  DT1  ${LTE_MIMO_4x4_DL_THROUGHPUT} Mbits/sec  10%
    ...  omit=${not_energy_saving_omit}
    Detach UE  NR_UE

Step 4: Check Admin To Confirm That LTE Cell State Is ReducedEnergySaving
    Log  \n==== Step 4: Check Admin To Confirm That Lte Cell ${LTE_CELL_ID} State Is ReducedEnergySaving ====  console=True
    Log  Wait max ${LBPS_MON_WIN_FOR_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.  console=True
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${LBPS_MON_WIN_FOR_RTXS_OFF_TIME_FOR_WAITNIG}s  10s
    ...  Check Energy Saving State For LTE Cell  ${MRBTS_ID}  ${LNBTS_ID}  ${LTE_CELL_ID}  ReducedEnergySaving  connection=gNB


Activation Parameters For Test Configuration LTE Only Or NSA
    [Arguments]  ${value}
    Run Keyword If  ${LTE_ONLY}  4G Site Parameters  ${value}
    ...  ELSE  5G Site Parameters  ${value}


4G Site Parameters
    [Arguments]  ${value}
    ${parameter_value} =  Set Variable If  ${value}  enhanced  disabled
    Log  \n==== LTE Only Configuration Will Be Used ====  console=True
    Log  \n==== Recommissioning actPeriodicB1NRMeas value=${parameter_value} ====  console=True
    Set Test Variable  ${SCF_PARAMETERS_CHANGED}  True
    Perform Parameter Recommissioning  dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}
    ...  parameter=actPeriodicB1NRMeas  operation=update  value=${parameter_value}  connection=gNB


5G Site Parameters
    [Arguments]  ${value}
    ${dldatasplitmode} =  Set Variable If  ${value}  dlOverX2U  dlOverF1UX2U
    ${initialdltrafficrouting} =  Set Variable If  ${value}  initDLoverX2U  initDLoverF1U
    Log  \n==== NSA Configuration Will Be Used ====  console=True
    Log  \n==== Recommissioning NRDRB-6 dlDataSplitMode=${dldatasplitmode} And initialDLTrafficRouting=${initialdltrafficrouting} ====  console=True

    &{dictionary}=  Create Dictionary
    ...             actPrioritizeX2AfterInactivity=${false}
    ...             actX2DuplicateTxNSA3x=${false}
    ...             dlDataSplitBufferBuildUpThreshold=${5}
    ...             dlDataSplitBufferBuildUpThresholdPrioritizeX2=${5}
    ...             dlDataSplitGainThreshold=${1}
    ...             dlDataSplitMode=${dldatasplitmode}
    ...             dlNumOfCongOrGainDdds=${2}
    ...             inactivityThresholdForPrioritizeX2=${300}
    ...             inactivityThresholdForRestartPrioritizeX2=${100}
    ...             initialDLTrafficRouting=${initialdltrafficrouting}
    ...             nsa3xBearerAllowed=${true}
    ...             prioritizeX2Period=${500}
    ...             ulDataPath=ulOverLteNr_PrimaryPathOverNr
    ...             ulDataPathForUlSplitNotCapableUe=ulPrimaryPathOverNr
    ...             ulDataSplitThreshold=b102400
    Run Keyword If  '${RELEASE_LOCAL}' == 'SBTS23R4' and '${dldatasplitmode}' == 'dlOverX2U'
    ...  Set To Dictionary  ${dictionary}  dlPreferredPath=X2-U
    ...  ELSE IF  '${RELEASE_LOCAL}' >= 'SBTS24R1' and '${dldatasplitmode}' == 'dlOverX2U'
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

    ${lnbts_id} =  Get LNBTS ID From ADMIN  alias=gNB
    Set Test Variable  ${LNBTS_ID}  ${lnbts_id}

    ${_}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${PARSED_SCF_GNB}  ${parsed_scf_gnb}

    ${lbps_mon_win_for_rtxs_on} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  PSGRP  PSGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsMonWinForRtxSOn']  dist_name_substring=False
    ${lbps_mon_win_for_rtxs_on_time_for_waiting} =  Evaluate  ${lbps_mon_win_for_rtxs_on} + 5
    Set Test Variable  ${LBPS_MON_WIN_FOR_RTXS_ON_TIME_FOR_WAITNIG}  ${lbps_mon_win_for_rtxs_on_time_for_waiting}

    ${lbps_mon_win_for_rtxs_off} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  PSGRP  PSGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsMonWinForRtxSOff']  dist_name_substring=False
    ${lbps_mon_win_for_rtxs_off_time_for_waiting} =  Evaluate  ${lbps_mon_win_for_rtxs_off} + 15
    Set Test Variable  ${LBPS_MON_WIN_FOR_RTXS_OFF_TIME_FOR_WAITNIG}  ${lbps_mon_win_for_rtxs_off_time_for_waiting}


Set Attenuation For TC
    Set Attenuation   GNB_55014_CELL_83_ANCHOR   0dB
    Run Keyword If  '${LTE_ONLY}' == 'False'  Set Attenuation   GNB_55014_CELL_0   10dB


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== Test Specific Teardown ===  console=True
    Stop Data Transfers For All UEs
    Detach UE  NR_UE
    Set Attenuation For All Cells  100%
    Log  \n==== Energy Saving For LTE Cell ${LTE_CELL_ID} Will Remain Enabled By Default On The TL ====  console=True
    Run Keyword If  ${SCF_PARAMETERS_CHANGED}  Activation Parameters For Test Configuration LTE Only Or NSA  False
    IWK Test Teardown  local_enb_connection=False  single_bts=True
