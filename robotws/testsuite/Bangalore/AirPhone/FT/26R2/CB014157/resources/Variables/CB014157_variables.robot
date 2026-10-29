*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB012564 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,20.04.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***

${Log_Path}                              /home/ute/logs
${CB014157_TC_01_GNB_SCF}          ${CURDIR}/../../config/gnb/CB014157_TC_01_GNB_SCF.xml
${CB014157_TC_01_IPHY}             ${CURDIR}/../../config/ap/CB014157_IPHY_TC01.xml
${CB014157_TC_01_WTS}              ${CURDIR}/../../config/wts/CB014157_TC_01.cfg

${VAL_SIB1}                        SystemInformationBlockType1-NR updated
${VAL_REG}                         Received REGISTRATION COMPLETE
${VAL_PDU_SESSION}                 Initial Context Setup Successful
${VAL_UE1_DEREG_REL}               AMF-1: UE CONTEXT RELEASE COMPLETE
${CM_UE_1_STATS}                   ue_stats_nr id=1 type=pusch
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off

@{CM_LST_RIM_RS_SET_ID}     11144    11145    11146    11147     11148      11149      11150      11151
...                         11152    11153    11154    11155     11156      11157      11158      11159     RS1     RS2

${NOISE_POWER_FOR_RI_67_TDLTE}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

${CM_RI_PROFILE_7}     remote_interference_testmode_nr profile_id=7 start_symbol_position=0
...      num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI_67_TDLTE}

${CM_RI_PROFILE_7_ACTIVATE}      cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1
...      profile_id=7 action=activate

${CM_RI_PROFILE_7_enable_RI_pilot_window}     remote_interference_testmode_nr profile_id=7 start_symbol_position=0
...      num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI_67_TDLTE} enable_ri_pilot=1 ri_pilot_window=300
...      ri_pilot_period=3 num_ri_pilot_periods=100


${NOISE_POWER_RI_115_SEMISTATIC}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

${CM_RI_PROFILE_7_SEMISTATIC}     remote_interference_testmode_nr profile_id=7 start_symbol_position=0
...     num_of_symbols=32 noise_power_values=${NOISE_POWER_RI_115_SEMISTATIC}


${VAL_RI_PILOT_WINDOW}       RiPilotWindow: DETECTED
${VAL_RI_PILOT_WINDOW_detected}          isRiDetectedInPilotWindow:yes
${VAL_RI_PILOT_DL_MUTE_STATE_ACTIVE}       riPilotDlMuteState:active

${CM_RIM_RS_PROFILE_ID_97}             97
${CM_RIM_RS_CFG_MODE_STAND_ALONE}      standalone
${CM_AGGRESSOR_CELL_1}                 1
${CM_VICTIM_CELL_1}                    1
${CM_RS_SET_ID_11144}                  11144
${CM_NUM_RS_SET_ID_16}                 16
${CM_RIM_RS_TYPE_TYPE1_TYPE2}          rsType1AndType2
${CM_PROPAGATION_DELAY_16}             16
${CM_RIM_RS_TYPE1_NSCID_1TO8}          1,2,3,4,5,6,7,8
${CM_RIM_RS_TYPE2_NSCID_11TO18}        11,12,13,14,15,16,17,18
${CM_RIM_RS_PATTERN1_PERIOD_50}        50
${CM_RIM_RS_PATTERN2_PERIOD_25}        25
${CM_RIM_RS_FACTOR_RS_SEQ_RS1}         1
${CM_RIM_RS_FACTOR_RS_SEQ_RS2}         1
${CM_RIM_RS_OFFSET_SEQ_RS1}            1
${CM_RIM_RS_OFFSET_SEQ_RS2}            1
${CM_RIM_RS_REPETITION_RS_TYPE1_2}     2
${CM_RIM_RS_REPETITION_RS_TYPE2_4}     4
${CM_RIM_RS_FW1}                       framework_1
${CM_RIM_RS_NUM_RB_FOR_RS_96}             96
${CM_RIM_RS_NUM_RS_TYPE1_SETID_65536}     65536
${CM_RIM_RS_NUM_RS_TYPE2_SETID_65536}     65536
${CM_RIM_RS_GLOBAL_F0_FOR_RS}             633390
${CM_RIM_RS_START_F_O_2_100}     2,100

${CM_RIM_RS_PROFILE_97_ACTIVATE}      cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=97
...     action=activate

${CM_DEACTIVATE_RI_PROFILE_97}     cell_testmode_set_nr gnb=2 cell_id=1 testmode=remote_interference profile_id=7
...     action=deactivate

${CM_DEACTIVATE_RIM_RS_PROFILE_97}     cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=97
...     action=deactivate
