*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     ute_ue
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/cloud_bts.robot


*** Variables ***
${NR_CELL_ID}                                   # ID of tested NR cell
${NR_UE_CAPABILITY}                             # Capability of UE used for test
${POWER_GROUP_ID}                               # ID of power group used in TC
${CELL_ALIAS}                                   # Alias set for tested cell in attenuator configuration file
${ATTENUATION_VALUE}                            # Value of tested cell attenuation
${NAMESPACE}                                    # vDU namespace used for collecting Cplane logs
${COUNTER_PERIOD}        5                      # Counter collecting interval in minutes. Default value: 5
${APN_CONTAINS}          n26wro/rmnet_data      # Part of APN name that does not change. Default value: n26wro/rmnet_data.

*** Keywords ***
TC__CB007065_B_CB008133_Power_reduction_via_load_based_massive_MIMO_power_saving_with_32TRX_path_switch_off

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-monika.ceglarek@nokia.com
    ...         PHASE-CRT    SW-SBTS25R1    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Collect And Analyze Counters
    Step 2: Perform Attach
    Step 3: Perform Data Transfer
    Step 4: Stop Data Transfer
    Step 5: Collect And Analyze Counters


Preconditions
    Log  \n==== Preconditions ====  console=True

    Get Start Time
    Create Global Variables
    Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving
    Sleep  1s  reason=To make sure there is difference between START_TIME variable and new period.
    Wait For New Counter Period

    Save SCF VDU  vDU_SCF_original.xml
    Save SCF VCU  vCU_SCF_original.xml

    Verify CB007065 Value On VDU

    Require UE  NR_UE  ${NR_UE_CAPABILITY}

    Set Attenuation For All Cells  100%
    Set Test Variable  ${ATTENUATOR_SET}  True
    Set Attenuation  ${CELL_ALIAS}  ${ATTENUATION_VALUE}

    [Teardown]  Run Keywords  Run Keyword And Ignore Error  vcu.Disconnect
    ...  AND  Run Keyword And Ignore Error  vdu.Disconnect


Create Global Variables
    Set Test Variable  ${ATTENUATOR_SET}  False
    Set Test Variable  ${DATA_TRANSFER_FINISHED}  False

    Get MRBTS ID From VDU
    Get NRBTS ID From VDU

    ${lbps_rtxs_on_time_for_waiting} =  Get LBPS RTX Time For Waiting  lbpsRTXSOnTime
    Set Test Variable  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}  ${lbps_rtxs_on_time_for_waiting}

    ${lbps_rtxs_off_time_for_waiting} =  Get LBPS RTX Time For Waiting  lbpsRTXSOffTime
    Set Test Variable  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}  ${lbps_rtxs_off_time_for_waiting}

    ${nr_cell_identity} =  Get NR Cell Identity From VDU  ${NR_CELL_ID}
    Set Test Variable  ${NR_CALL_CELL_ID}  ${nr_cell_identity}


Get LBPS RTX Time For Waiting
    [Arguments]  ${parameter_name}

    Connect To VDU
    ${lbps_rtxs_time} =  vdu.Search Parameter Of Current Plan
    ...  mo_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${POWER_GROUP_ID}
    ...  para_name=${parameter_name}
    ${lbps_rtxs_time_for_waiting} =  Evaluate  ${lbps_rtxs_time} + 30

    [Teardown]  vdu.Disconnect
    [Return]  ${lbps_rtxs_time_for_waiting}


Verify CB007065 Value On VDU
    Connect To VDU
    ${current_value} =  vdu.Search Parameter Of Current Plan  mo_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...  para_name=actNrLBmMimoRTXPowerSaving
    Should Be True  '${current_value}' == 'true'
    ...  msg=Value for actPdcchSharingWithPdsch (${current_value}) on vDU is different than expected (true).
    Log  CB007065 check on vDU successful.  console=True

    [Teardown]  vdu.Disconnect


Step ${index}: Collect And Analyze Counters
    Log  \n==== Step ${index}: Collect Counters ====  console=True

    Wait For New Counter Period
    Sleep  70s  reason=Additional waiting time for counters to update.
    Connect To VDU

    ${vdu_m55601c02001} =  Get Counter List For VDU  counter_id=M55601C02001
    ...  dimension_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  counter_amount=1  start_time=${START_TIME}
    Log  From vDU M55601C02001 = ${vdu_m55601c02001}  console=True
    ${vdu_m55601c02001} =  Set Variable  ${vdu_m55601c02001[0]}

    ${vdu_m55601c02002} =  Get Counter List For VDU  counter_id=M55601C02002
    ...  dimension_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  counter_amount=1  start_time=${START_TIME}
    Log  From vDU M55601C02002 = ${vdu_m55601c02002}  console=True
    ${vdu_m55601c02002} =  Set Variable  ${vdu_m55601c02002[0]}

    vdu.Disconnect

    ${max_number_of_samples} =  Evaluate  ${COUNTER_PERIOD} * 60
    Run Keyword If  ${DATA_TRANSFER_FINISHED}
    ...  Check M55601C02001 And M55601C02002 Values After Data Transfer  ${vdu_m55601c02001}  ${vdu_m55601c02002}
    ...  ${max_number_of_samples}  ${index}
    ...  ELSE  Check M55601C02001 And M55601C02002 Values In The Beginning  ${vdu_m55601c02001}  ${vdu_m55601c02002}
    ...  ${max_number_of_samples}  ${index}

    Get Start Time

    [Teardown]  Collect Counter Files  ${index}


Check M55601C02001 And M55601C02002 Values In The Beginning
    [Arguments]  ${vdu_m55601c02001}  ${vdu_m55601c02002}  ${max_number_of_samples}  ${index}
    Should Be True  ${vdu_m55601c02001} == 0
    ...  msg=M55601C02001 has incorrect value for step${index}. M55601C02001=${vdu_m55601c02001}.
    Should Be True  ${vdu_m55601c02002} == ${max_number_of_samples}
    ...  msg=M55601C02002 has incorrect value for step${index}. M55601C02002=${vdu_m55601c02002}.


Check M55601C02001 And M55601C02002 Values After Data Transfer
    [Arguments]  ${vdu_m55601c02001}  ${vdu_m55601c02002}  ${max_number_of_samples}  ${index}
    Should Be True  ${vdu_m55601c02001} == 1
    ...  msg=M55601C02001 has incorrect value for step${index}. M55601C02001=${vdu_m55601c02001}.
    Should Be True  ${vdu_m55601c02002} < ${max_number_of_samples}
    ...  msg=M55601C02002 has incorrect value for step${index}. M55601C02002=${vdu_m55601c02002}.


Collect Counter Files
    [Arguments]  ${index}
    ${for_last} =  Evaluate  ${COUNTER_PERIOD} * 3
    Log  Collecting counter files form vDU...  console=True
    Collect PM Counters  xml_files_left=2  host=${VDU_OAM_CONNECTION.addr}  user=${VDU_OAM_CONNECTION.username}
    ...  password=${VDU_OAM_CONNECTION.password}  time_interval=${for_last} min  intervals=${COUNTER_PERIOD}  bts_type=vdu
    ...  target_dir_path=${LOG_PATH}/pm_counters/vdu_step${index}


Step 2: Perform Attach
    Log  \n==== Step 2: Perform Attach ====  console=True

    cloud_bts.Prepare UE For Data Transfer  NR_UE  ${NR_CALL_CELL_ID}
    Log  \nUE attached to cell ${NR_CALL_CELL_ID}.\nWaiting for energy saving state change...  console=True
    Sleep  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s  reason=Waiting for timer to run out.
    Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving


Step 3: Perform Data Transfer
    Log  \n==== Step 3: Perform Data Transfer ====  console=True

    ${wait_time} =  Evaluate  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG} + 30
    ${apn} =  Get Full APN Name For UE  ${APN_CONTAINS}  ue_alias=NR_UE
    Start Data Transfer  NR_DL  NR_UE  dl  throughput=200 Mbits/sec  duration=1200s
    ...  protocol=udp  packet=1400  parallel_streams=4  apn=${apn}
    Log  DL data transfer started...  console=True

    Sleep  ${wait_time}s  reason=Running data transfer and waiting for switch on timer to finish.

    Check Data Transfer Is Alive  NR_DL
    Get Average Throughput In Mbps  iperf
    Run Keyword And Ignore Error  Get Average Throughput In Mbps  control_app
    ##TODO remove one when no longer needed


    Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID}  notEnergySaving


Get Average Throughput In Mbps
    [Arguments]  ${tput_collection_src}
    ${nr_dl_tput} =  Get Average Throughput  NR_DL  omit=30  tput_collection_src=${tput_collection_src}
    ${nr_dl_tput} =  Evaluate  ${nr_dl_tput}/1000.0
    Log  \nIperf DL:${nr_dl_tput} Mbps  console=True


Step 4: Stop Data Transfer
    Log  \n==== Step 4: Stop Data Transfer ====  console=True

    Check Data Transfer Is Alive  NR_DL
    Stop Data Transfer  NR_DL
    Detach UE  NR_UE
    Log  Data transfer is stopped and UE is detached.\nWaiting for energy saving state change...  console=True

    Wait Until Keyword Succeeds  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}  10s
    ...  Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving
    ...  log_messages=False
    Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving
    Set Test Variable  ${DATA_TRANSFER_FINISHED}  True


TC Setup
    Cloud BTS Test Setup  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}
    Set Test Variable  ${WIRESHARK_STARTED}  True
    Start Wireshark Log Collection For VCU  namespace=${NAMESPACE}


TC Teardown
    [Timeout]  60 min
    Log  \n === TC Teardown ===   console=True
    Run Keyword And Ignore Error  Stop Data Transfer  NR_DL
    Detach UE  NR_UE
    Run Keyword If  ${ATTENUATOR_SET}  Set Attenuation For All Cells  100%
    Run Keyword If  ${WIRESHARK_STARTED}  Stop Wireshark Log Collection
    Cloud BTS Test Teardown
