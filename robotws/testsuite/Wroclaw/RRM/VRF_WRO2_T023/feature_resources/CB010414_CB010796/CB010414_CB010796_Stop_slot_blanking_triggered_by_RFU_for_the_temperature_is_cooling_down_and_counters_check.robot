*** Settings ***
Documentation
...   contact: Wojciech Peciak

Resource    ./resources/CB010414_CB010796_KW.robot
Library     ta5g_ue_mobility
Library     ta5g_throughput

*** Variables ***
${NR_CELL_ID}                           1       # ID of tested NR cell. Default value: 1
${UE_ID}                                1       # ID of tested UE. Default value: 1
${RMOD_MO_ID}                           2       # ID of tested RMOD in vDU SCF. Default value: 2
${RMOD_AP_ID}                           1       # ID of tested simulated RMOD in AirPhone OAM. Default value: 1
${NAMESPACE}                                    # vDU namespace used for collecting Cplane logs
${COUNTER_PERIOD}                       5       # Counter collecting interval in minutes. Default value: 5
${MAX_UTF_LOGS_DELAY}                   300s    # Max time in seconds needed for change of UTF logs collecting status to 'running'
                                                # Default value: 300s

*** Keywords ***
TC__CB010414_CB010796_Stop_slot_blanking_triggered_by_RFU_for_the_temperature_is_cooling_down_and_counters_check

    Set Tags    CA-RRM    AUTHOR-wojciech.peciak@nokia.com    MAINTAINER-wojciech.peciak@nokia.com
    ...         PHASE-CRT   SW-SBTS25R2    GROUP_IN_CHARGE-VRF_2_WRO_2

    Step 1: Wait For Clean Counters Period
    Step 2: Counters Collection And Verification With No Previous Slot Blanking

    Step 3: Register UE And Start Data Transfer
    Step 4: Trigger RU Increased Temperature And Wait For 20s
    Step 5: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
    Step 6: Reset Slot Blanking To Lvl 0 And Wait For 20s
    Step 7: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
    Step 8: Reset Slot Blanking To Lvl 0 And Wait For 0s
    Step 9: Counters Collection And Verification With Two Cycles Of Slot Blanking Lvl Increase

    Step 10: Catch TTI Trace To Confirm Slot Blanking With 0%
    Step 11: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
    Step 12: Catch TTI Trace To Confirm Slot Blanking With 17%
    Step 13: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
    Step 14: Catch TTI Trace To Confirm Slot Blanking With 35%
    Step 15: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
    Step 16: Catch TTI Trace To Confirm Slot Blanking With 50%
    Step 17: Counters Collection And Verification With Slot Blanking Increase To All Lvls

Preconditions
    Log  \n==== Preconditions ====  console=True

    Create Global Variables

    Save SCF VCU  vCU_SCF_original.xml
    Save SCF VDU  vDU_SCF_original.xml

    Setup TTI Decoder For Vdu

    Activate CB010414 RF Counters Collection Every ${COUNTER_PERIOD}min
    Step X: Reset Slot Blanking To Lvl 0 And Wait For 0s

Create Global Variables
    Import Variables    ${TA_ATTENUATOR_CONFIG}

    Get MRBTS ID From VDU
    Get NRBTS ID From VDU

    Set Test Variable  ${COUNTER_PERIOD_IN_SEC}  ${{int($COUNTER_PERIOD)*int(60)}}
    Set Test Variable  ${PMMNL_DIST_NAME}  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    Set Test Variable  ${PMCADM_DIST_NAME}  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Set Test Variable  ${NRPMRNL_DIST_NAME}  MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    Set Test Variable  ${PARAMETERS_MODIFIED}  False

Step 1: Wait For Clean Counters Period
    Log  \n==== Step 1: Wait For Clean Counters Period ====  console=True

    Wait For New Counter Period

Step ${index}: Reset Slot Blanking To Lvl 0 And Wait For ${time}
    Log  \n==== Step ${index}: Reset Slot Blanking To Lvl 0 And Wait For ${time} ====  console=True

    Trigger RU Temperature Update Msg  temperature_rating=NORMAL
    Trigger RU Temperature Update Msg  temperature_rating=NORMAL
    Trigger RU Temperature Update Msg  temperature_rating=NORMAL
    Sleep  ${time}  reason=Wait for temperature change msg to be reflected in PM counters and TTI Trace.

Step ${index}: Trigger RU Increased Temperature And Wait For ${time}
    Log  \n==== Step ${index}: Trigger RU Increased Temperature And Wait For ${time} ====  console=True

    Trigger RU Temperature Update Msg  temperature_rating=INCREASED
    Sleep  ${time}  reason=Wait for temperature change msg to be reflected in PM counters and TTI Trace.

Step 2: Counters Collection And Verification With No Previous Slot Blanking
    Log  \n==== Step 2: Counters Collection And Verification With No Previous Slot Blanking ====  console=True

    ${rd_counter_file} =  R&D Counters Collection From vDU  output_dirpath=${LOG_PATH}/counters_vdu_1_Step_2
    Verify Last Counters In File
        ...  NR_RMOD_TEMP_NORMAL_SAMPL       >0                              M40008CRD700
        ...  NR_RMOD_TEMP_NORMAL_SAMPL       <\=${COUNTER_PERIOD_IN_SEC}     M40008CRD700
        ...  NR_RMOD_TEMP_INCREASED_SAMPL    0                               M40008CRD701
        ...  NR_RMOD_TEMP_HIGH_SAMPL         0                               M40008CRD702
        ...  local_moid=PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_MO_ID}
        ...  file_path=${rd_counter_file}

    Verify Last Counters In File
        ...  NR_CELL_RF_COOL_MODE0_CHNG_TO     0                               M55601C00017
        ...  NR_CELL_RF_COOL_MODE0_SAMPLES     >\=0                            M55601C00016
        ...  NR_CELL_RF_COOL_MODE0_SAMPLES     <\=${COUNTER_PERIOD_IN_SEC}     M55601C00016
        ...  NR_CELL_RF_COOL_MODE1_CHNG_TO     0                               M55601C00021
        ...  NR_CELL_RF_COOL_MODE1_SAMPLES     0                               M55601C00020
        ...  NR_CELL_RF_COOL_MODE2_CHNG_TO     0                               M55601C00019
        ...  NR_CELL_RF_COOL_MODE2_SAMPLES     0                               M55601C00018
        ...  NR_CELL_RF_COOL_MODE3_CHNG_TO     0                               M55601C00023
        ...  NR_CELL_RF_COOL_MODE3_SAMPLES     0                               M55601C00022
        ...  local_moid=PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
        ...  file_path=${rd_counter_file}

Step 3: Register UE And Start Data Transfer
    Log  \n==== Step 3: Register UE And Start Data Transfer ====  console=True

    Attach Ue  ue_id=${UE_ID}  cell=${NR_CELL_ID}  enb=2
    Set Internal Traffic Type For Ue  ue=${UE_ID}  pdu=1
    Establish Pdu Session  ue_id=${UE_ID}  pdu_id=1  nwslice=1  gw_id=1
    Start Data Traffic  ues=${UE_ID}  pdu=1  throughput=120mbps  direction=dl
    Start Data Traffic  ues=${UE_ID}  pdu=1  throughput=50mbps  direction=ul

Step ${index}: Trigger One Lvl Increase In RU Slot Blanking And Wait For ${time}
    Log  \n==== Step ${index}: Trigger One Lvl Increase In RU Slot Blanking And Wait For ${time} ====  console=True

    Trigger RU Temperature Update Msg  temperature_rating=HIGH
    Sleep  ${time}  reason=Wait for temperature change msg to be reflected in PM counters and TTI Trace.

Step ${index}: Catch TTI Trace To Confirm Slot Blanking With ${blanking_ratio}%
    Log  \n==== Step ${index}: Catch TTI Trace To Confirm Slot Blanking With ${blanking_ratio}% ====  console=True

    Collect TTI Trace With UTF  ${NR_CELL_ID}  ${UE_ID}
    ${csv_tti_path}=  Extract TTI Trace Data From ZIP To Filtered CSV
    ...                     ${UTF_LOGS_PATH}
    ...                     ${LOG_PATH}/traces/UE${UE_ID}_TC_Step_${index}
    Verify SlotBlanking And Muting Ratio  ${csv_tti_path}  ${blanking_ratio}

Step 9: Counters Collection And Verification With Two Cycles Of Slot Blanking Lvl Increase
    Log  \n==== Step 9: Counters Collection And Verification With Two Cycles Of Slot Blanking Lvl Increase ====  console=True

    ${rd_counter_file} =  R&D Counters Collection From vDU  output_dirpath=${LOG_PATH}/counters_vdu_1_Step_9
    Verify Last Counters In File
        ...  NR_RMOD_TEMP_NORMAL_SAMPL       >0                                 M40008CRD700
        ...  NR_RMOD_TEMP_NORMAL_SAMPL       <${COUNTER_PERIOD_IN_SEC}          M40008CRD700
        ...  NR_RMOD_TEMP_INCREASED_SAMPL    >0                                 M40008CRD701
        ...  NR_RMOD_TEMP_INCREASED_SAMPL    <${COUNTER_PERIOD_IN_SEC}          M40008CRD701
        ...  NR_RMOD_TEMP_HIGH_SAMPL         >0                                 M40008CRD702
        ...  NR_RMOD_TEMP_HIGH_SAMPL         <${COUNTER_PERIOD_IN_SEC}          M40008CRD702
        ...  local_moid=PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_MO_ID}
        ...  file_path=${rd_counter_file}

    Verify Last Counters In File
        ...  NR_CELL_RF_COOL_MODE0_CHNG_TO     2                                  M55601C00017
        ...  NR_CELL_RF_COOL_MODE0_SAMPLES     >0                                 M55601C00016
        ...  NR_CELL_RF_COOL_MODE0_SAMPLES     <${COUNTER_PERIOD_IN_SEC}          M55601C00016
        ...  NR_CELL_RF_COOL_MODE1_CHNG_TO     2                                  M55601C00021
        ...  NR_CELL_RF_COOL_MODE1_SAMPLES     >0                                 M55601C00020
        ...  NR_CELL_RF_COOL_MODE1_SAMPLES     <${COUNTER_PERIOD_IN_SEC}          M55601C00020
        ...  NR_CELL_RF_COOL_MODE2_CHNG_TO     0                                  M55601C00019
        ...  NR_CELL_RF_COOL_MODE2_SAMPLES     0                                  M55601C00018
        ...  NR_CELL_RF_COOL_MODE3_CHNG_TO     0                                  M55601C00023
        ...  NR_CELL_RF_COOL_MODE3_SAMPLES     0                                  M55601C00022
        ...  local_moid=PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
        ...  file_path=${rd_counter_file}

Step 17: Counters Collection And Verification With Slot Blanking Increase To All Lvls
    Log  \n==== Step 17: Counters Collection And Verification With Slot Blanking Increase To All Lvls ====  console=True

    ${rd_counter_file} =  R&D Counters Collection From vDU  output_dirpath=${LOG_PATH}/counters_vdu_1_Step_17
    Verify Last Counters In File
        ...  NR_RMOD_TEMP_NORMAL_SAMPL       >0                                 M40008CRD700
        ...  NR_RMOD_TEMP_NORMAL_SAMPL       <\=${COUNTER_PERIOD_IN_SEC}        M40008CRD700
        ...  NR_RMOD_TEMP_INCREASED_SAMPL    0                                  M40008CRD701
        ...  NR_RMOD_TEMP_HIGH_SAMPL         >0                                 M40008CRD702
        ...  NR_RMOD_TEMP_HIGH_SAMPL         <\=${COUNTER_PERIOD_IN_SEC}        M40008CRD702
        ...  local_moid=PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_MO_ID}
        ...  file_path=${rd_counter_file}

    Verify Last Counters In File
        ...  NR_CELL_RF_COOL_MODE0_CHNG_TO     0                                  M55601C00017
        ...  NR_CELL_RF_COOL_MODE0_SAMPLES     >0                                 M55601C00016
        ...  NR_CELL_RF_COOL_MODE0_SAMPLES     <${COUNTER_PERIOD_IN_SEC}          M55601C00016
        ...  NR_CELL_RF_COOL_MODE1_CHNG_TO     1                                  M55601C00021
        ...  NR_CELL_RF_COOL_MODE1_SAMPLES     >0                                 M55601C00020
        ...  NR_CELL_RF_COOL_MODE1_SAMPLES     <${COUNTER_PERIOD_IN_SEC}          M55601C00020
        ...  NR_CELL_RF_COOL_MODE2_CHNG_TO     1                                  M55601C00019
        ...  NR_CELL_RF_COOL_MODE2_SAMPLES     >0                                 M55601C00018
        ...  NR_CELL_RF_COOL_MODE2_SAMPLES     <${COUNTER_PERIOD_IN_SEC}          M55601C00018
        ...  NR_CELL_RF_COOL_MODE3_CHNG_TO     1                                  M55601C00023
        ...  NR_CELL_RF_COOL_MODE3_SAMPLES     >0                                 M55601C00022
        ...  NR_CELL_RF_COOL_MODE3_SAMPLES     <${COUNTER_PERIOD_IN_SEC}          M55601C00022
        ...  local_moid=PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
        ...  file_path=${rd_counter_file}

Restore Env
    Log  \n==== Restore Env ====  console=True

    Deregister UE And Stop Data Transfer  ue_id=${UE_ID}
    Run Keyword If  ${PARAMETERS_MODIFIED}  Restore CB010414 RF Counters Config
    Step X: Reset Slot Blanking To Lvl 0 And Wait For 0s

TC Setup
    Log  \n === TC Setup ===   console=True

    Cloud BTS Test Setup  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}
    Set Test Variable  ${WIRESHARK_STARTED}  True
    Start Wireshark Log Collection For VCU  namespace=${NAMESPACE}

    Preconditions

TC Teardown
    [Timeout]  60 min
    Log  \n === TC Teardown ===   console=True

    Restore Env
    Run Keyword If  ${WIRESHARK_STARTED}  Stop Wireshark Log Collection
    Cloud BTS Test Teardown
