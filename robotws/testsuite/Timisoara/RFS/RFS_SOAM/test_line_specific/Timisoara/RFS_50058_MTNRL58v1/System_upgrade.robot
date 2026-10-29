*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}    ${True}
${POWER_ON_FLAG}    ${True}
${custom_allowed_alarms}    4773,1815,7300,7513,7511,7509,4401,4110,7308,4452,62003,4590,4530,6134,1994,8150,4764,6351,4694,4681,6129
&{ADD_IGNORED_ALARM_SANITY_1}    faultId=1994
&{ADD_IGNORED_ALARM_SANITY_2}    faultId=6129

*** Test Cases ***
[1]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    NR_UE
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    LTE_UE
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    10208182282 158990853
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    158990850
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]NRL__SWM__SW_Update_CNI_103974
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_cni_103974_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    BTS1
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS3}
    ...    AND    Set Test Variable    ${Target SW dir BTS3}
    ...    AND    Set Test Variable    ${Target SW name BTS4}
    ...    AND    Set Test Variable    ${Target SW dir BTS4}
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    897
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${FORCE_TARGET_BTS_SW_DL}    True
    ...    AND    Set Test Variable    ${WFT_BTS1_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS2_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS3_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS4_target_sw}
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${Remote target SW path BTS1}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS2}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS3}
    ...    AND    Set Test Variable    ${Remote target SW path BTS4}
    ...    AND    Set Test Variable    ${TWO_STEP_DOWNLOAD_ACTIVATE}    False
    ...    AND    Set Test Variable    ${SYNCHRONIZE_ACTIVE_PASSIVE_SW_VERSION}    False
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    Set Test Variable    ${CHECK_BTS_RESET_CAUSE}    True
    ...    AND    Set Test Variable    ${SNAPSHOT_CHECK}    True
    ...    AND    Append To List  ${SBTS_TEMP_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_SANITY_1}
    ...    AND    Append To List  ${SBTS_TEMP_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_SANITY_2}
    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.TC Teardown
    ...    AND    Restore Resource Search Order


[3]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    NR_UE
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    LTE_UE
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    10208182282 158990853
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    158990850
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[4]NRL__SWM__SW_Update_CNI_103974
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_cni_103974_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    BTS2
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS3}
    ...    AND    Set Test Variable    ${Target SW name BTS4}
    ...    AND    Set Test Variable    ${Target SW dir BTS4}
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    897
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${FORCE_TARGET_BTS_SW_DL}    True
    ...    AND    Set Test Variable    ${WFT_BTS1_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS2_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS3_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS4_target_sw}
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${Remote target SW path BTS1}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS2}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS3}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS4}    None
    ...    AND    Set Test Variable    ${TWO_STEP_DOWNLOAD_ACTIVATE}    False
    ...    AND    Set Test Variable    ${SYNCHRONIZE_ACTIVE_PASSIVE_SW_VERSION}    False
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    Set Test Variable    ${CHECK_BTS_RESET_CAUSE}    True
    ...    AND    Set Test Variable    ${SNAPSHOT_CHECK}    True
    ...    AND    Append To List  ${SBTS_TEMP_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_SANITY_1}
    ...    AND    Append To List  ${SBTS_TEMP_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_SANITY_2}
    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.TC Teardown
    ...    AND    Restore Resource Search Order

[5]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    NR_UE
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    LTE_UE
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    10208182282 158990853
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    158990850
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[6]SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    BTS1
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    650
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    900
    ...    AND    Append To List  ${SBTS_TEMP_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_SANITY_1}
    ...    AND    Append To List  ${SBTS_TEMP_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_SANITY_2}
    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order


[7]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    NR_UE
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    LTE_UE
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    10208182282 158990853
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    158990850
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False


    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[8]SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    BTS2
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    650
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    900
    ...    AND    Append To List  ${SBTS_TEMP_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_SANITY_1}
    ...    AND    Append To List  ${SBTS_TEMP_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_SANITY_2}
    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order


[9]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    NR_UE
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    LTE_UE
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    10208182282 158990853
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    158990850
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order