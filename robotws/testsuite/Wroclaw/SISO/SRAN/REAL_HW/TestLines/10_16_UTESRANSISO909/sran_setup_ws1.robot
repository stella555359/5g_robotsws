*** Settings ***
Documentation
...                 author: Piotr Korczynski
...                 contact: piotr.korczynski@nokia.com

Resource            ../../Resources/Setup/setup_and_teardown.robot
Resource            testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource            testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset.robot
Resource            testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset.robot
Resource            testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset.robot
Resource            testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset.robot
Resource            testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset.robot
Resource            testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/LOGS/LOGS_Enabling_Bts_Debug_Logs_In_Run_Time.robot

Suite Setup         Suite Precondition
Suite Teardown      Suite Postcondition


*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=      None    # possible settings : Failed, Always, None
# ${CUSTOM_SWITCH_PERFORM_HW_SETUP}=    ${True}    # to disable hardware reconfiguration ( PDU and Optical part ) set value ${False}
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=      ${True}    # to disable hardware reconfiguration ( PDU and Optical part ) set value ${False}

${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}=    10.42.184.146
@{CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST}=

# ${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=    10.42.106.133
# @{CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST}=
#
# ${CUSTOM_FILE_MODE_MASTER_NODE_IP}
# @{CUSTOM_FILE_MODE_AUXILLARY_NODES_IPS_LIST}
#
# ${CUSTOM_MANUAL_MODE_SCF_PATH}=    /home/ute/scf_files/

#
&{SM_VM_IP_ADDRESS_DICT}=
...    L1173212304=10.42.184.146
...    L1173212320=10.42.184.125
#
# &{CUSTOM_PDU_CONFIG}=
# ...    L1141527943=Aten,,10.42.51.180,4
# ...    L123456=APC,default,10.44.11.11,1
# ...    L123456=APC,default,10.44.11.11,1
# ...    L123456=APC,default,10.44.11.11,1

#
#
# &{CLOUD_RF_AILR_B1-3_B4-5_UTE_SRAN_SISO_CRT_035}=
# ...    OS=192.168.255.222:1-2,2-1,3-1,4-1,5-1|192.168.255.33:1-2,2-1,3-1,4-1,5-1

${SKIP_TRUCK_ROLL}=                     ${True}
@{additional_common_fault_list}=
...                                     faultId=2403
...                                     faultId=1898
...                                     faultId=4261
...                                     faultId=4003

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=    common=@{additional_common_fault_list}

&{10_16_UTESRANSISO115_DEFAULT}=        OS=192.168.255.555:1-1,2-1,3-1,4-1,5-1

&{Legacy}=                              name=FEAT_DBG_BTSOM_ALMAG    type=OneReset    value=1    value_reset=0
&{OamUri}=                              name=PrintRuntime    type=Persistent    value=true    value_reset=false
&{OamFri}=                              name=FriPrintLog    type=NotPersistent    value=true    value_reset=false
&{rd_parameters_dict}=
...                                     Legacy=${Legacy}
...                                     OamUri=${OamUri}
...                                     OamFri=${OamFri}


*** Test Cases ***
# [1][0.1] LOGS_Enabling_Bts_Debug_Logs_In_Run_Time
#    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    LOGS_Enabling_Bts_Debug_Logs_In_Run_Time
#    [Teardown]    Configuration Postcondition

[1][0.1] SiSo STARTUP Site Reset
    [Tags]    siso startup site reset
    [Setup]    Run Keywords
#    ...    Configuration Precondition    CN=MANUAL_FIRST
    ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
    ...    AND    Set Test Variable    ${CONFIGURATION_STARTUP_TIMEOUT}    2000
    Execute Test In Loop    Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    [Teardown]    Configuration Postcondition

# [1][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
#     [Setup]    Run Keywords
#     ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#     ...    AND    Set Test Variable    ${CONFIGURATION_STARTUP_TIMEOUT}    600
#     Execute Test In Loop    Execute Recommissioning With Configuration Reset On Every Node
#     [Teardown]    Configuration Postcondition

# [1][1.0] Automated__SiSo__BTS_Block_Unblock_without_call
#     [Setup]    Run Keywords
#     ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909    N=2
#     ...    AND    Set Test Variable    ${CONFIGURATION_STARTUP_TIMEOUT}    600
#     ...    AND    Set Test Variable    ${CUSTOM_EXPECTED_SITE_RESET_TIME}    350
#     Execute Test In Loop    Execute Block BTS On Every Node
#     [Teardown]    Configuration Postcondition

# [1.0] Automated__SiSo__FV_Testing_RF_Factory_SW_update
#    [Setup]    Run Keywords
#    ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...    AND    Set Test Variable    @{CUSTOM_RADIO_UNIT_LIST}    L6141629878
#    ...    AND    Set Test Variable    ${FACTORYSW}    factory
#    Incompatible Software Detection and Update
#    [Teardown]    Configuration Postcondition

# [1][2] SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset
#    [Tags]    SiSo STARTUP Site Reset
#    [Setup]    Run Keywords
#    ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...    AND    Set Test Variable    @{CUSTOM_RADIO_UNIT_LIST}    L1154809204    L6141629878
# #    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTime_EXPECTED_VALUE}    180
# #    ...    AND    Set Test Variable    ${SELECTED_CELLS}    21
#    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset
#    [Teardown]    Configuration Postcondition

# xxxxxx SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset
#    [Setup]    Run Keywords
#    ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...    AND    Set Test Variable    @{CUSTOM_RADIO_UNIT_LIST}    L1154809204
#    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTime_EXPECTED_VALUE}    180
#    ...    AND    Set Test Variable    ${uncntrldResetMplaneBreakTime_EXPECTED_VALUE}    180
#    ...    AND    Set Test Variable    ${SELECTED_CELLS}    21
#    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset
#    [Teardown]    Configuration Postcondition
#
#
# xxxxxx SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset
#    [Setup]    Run Keywords
#    ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...    AND    Set Test Variable    @{CUSTOM_RADIO_UNIT_LIST}    L1154809204
#    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTime_EXPECTED_VALUE}    180
#    ...    AND    Set Test Variable    ${uncntrldResetMplaneBreakTime_EXPECTED_VALUE}    180
#    ...    AND    Set Test Variable    ${SELECTED_CELLS}    21
#    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset
#    [Teardown]    Configuration Postcondition

# [1][2] SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset.robot
#    [Tags]    SiSo STARTUP Site Reset
#    [Setup]    Run Keywords
#    ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...    AND    Set Test Variable    @{CUSTOM_RADIO_UNIT_LIST}    L1154809204
# #    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTime_EXPECTED_VALUE}    180
#    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset
#    [Teardown]    Configuration Postcondition

# [1][4.0] Automated__SiSo__Configuration_Testing_SW Download and Activation
#    [Setup]    Run Keywords
#    ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...    AND    Set Test Variable    ${CONFIGURATION_STARTUP_TIMEOUT}    600
#    ...    AND    Set Test Variable    ${${CONFIGURATION_SWUPDATE_TIMEOUT}}    350
#    Execute Test In Loop    Execute SW Upgrade On Every Node
#    [Teardown]    Configuration Postcondition
#

# [1][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
#     [Setup]    Run Keywords
#     ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#     ...    AND    Set Test Variable    ${CONFIGURATION_STARTUP_TIMEOUT}    600
#     ...    AND    Set Test Variable    ${FAULT_10_TIMEOUT}    20
# #    ...    AND    Set Test Variable    ${FR_AVAILABILITY_TIMEOUT}    150
#     ...    AND    Set Test Variable    @{CUSTOM_RADIO_UNIT_LIST}    L6141629878
# #    ...    AND    Set Test Variable    ${CUSTOM_RU_STABILITY_BREAK}    25
#     Execute RU Power Hot Remove Insert On Every Node
#     [Teardown]    Configuration Postcondition

# [1.0] Automated__SiSo__FV_Testing_RF_Factory_SW_update
#    [Setup]    Run Keywords
#    ...    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...    AND    Set Test Variable    @{CUSTOM_RADIO_UNIT_LIST}    L6141629878
#    ...    AND    Set Test Variable    ${FACTORYSW}    factory
#    Incompatible Software Detection and Update
#    [Teardown]    Configuration Postcondition

# [2][0.1] Siso SRAN Site Reset
#    [Tags]    Siso SRAN Site Reset
#    [Timeout]    14400
#    [Setup]    Run Keywords
#    ...    Configuration Precondition    CN=REF_CLOUD_RF_AILR_B1-3_B4-5_UTE_SRAN_SISO_CRT_035
#    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    10
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}    ${CFG['NODES']['1411']['scf_file_path']}
#    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
#    ...    AND    Set Test Variable    ${ENABLE_TRUCK_ROLL_FLAG}    ${False}
#    ...    AND    Set Library Search Order    STATE__Site_reset    admin_im
#    ...    AND    STATE__Site_reset.TC Setup
#    TC__STATE__Site_reset
#    [Teardown]    Run Keywords
#    ...    STATE__Site_reset.TC Teardown
#    ...    AND    Configuration Postcondition    status=${TEST_STATUS}
#    ...    AND    Recover Testline
