*** Settings ***
Documentation
...   author: Tomasz Pawlaczyk
...   contact: tomasz.pawlaczyk@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot


#Resource    ../../Resources/SiSo_L3_Call.robot
#Resource    ${PATH}/test_resources/STATE/STATE__Radio_module_reset_from_admin.robot
#Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Data_Transfer.robot
#Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Voice_Call.robot
#Resource    ${PATH}/test_resources/4G_RRM/Automated_SiSo_CALL_LTE_Data_Transfer.robot
#Resource    ${PATH}/test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Data_Transfer.robot
#Resource    ${PATH}/test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Voice_Call.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}=
#...  faultId=1898
#...  faultId=4003
#...  faultId=7107
#...  faultId=6327
...  faultId=61675

@{tc_additional_1369_fault_list3}=
...  faultId=1815
...  faultId=61675
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

${CELLS_YAML_PATH}=                  /home/ute/testline_configuration/10_16_UTESRANSISO100/100cells.yaml
#${TESTLINE_NAME}      10_16_UTESRANSISO100
#${COMMISSIONING_PATH}
#...  /home/ute/testline_configuration/10_16_UTESRANSISO100/node1/SBTS00/G21_ASOG.xml
#${PATH}    testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS   #DO NOT CHANGE

${FORCE_RESET_CONFIGURATION}=    False
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    Failed  #     Always
${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=    ${TRUE}
${CHECK_SWCONFIG}  True
##mandatory variables

${SKIP_TRUCK_ROLL}=          ${False}       # to disable Truck And Roll feature set this flag to False
${ENABLE_TRUCK_ROLL_FLAG}    ${False}

*** Test Cases ***

[G21][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset        ##OKOK
   [Setup]  Run Keywords
   ...  Configuration Precondition        CN=REF_10_16_UTESRANSISO100_G21    N=40
   ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  350
   Execute Test In Loop  Execute Site Reset On Every Node
   [Teardown]  Configuration Postcondition

[G21TRUE][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_G21   N=10
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        EA203761974      K9183633079
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{tc_additional_1369_fault_list3}
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
     [Teardown]  Run Keywords
     ...  Configuration Postcondition
     ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{EMPTY}

#### call

[G21][1.0] Automated_SiSo_CALL_WCDMA_Data_Transfer            #OK
    [Setup]  Run Keywords
    ...  Configuration Precondition     CN=REF_10_16_UTESRANSISO100_G21
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   45603
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[G20][1.0] Automated_SiSo_CALL_NR_Data_Transfer                 #   Trunk  $ 25R1
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_G21
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   22429700
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop    SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition


#[G21FALSE][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_G21   N=1
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        L1184200033      L1181207097
#    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${FALSE}     # user can turn off dyinggasp verification in case of any
#    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{tc_additional_1369_fault_list3}
#     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
#     [Teardown]  Run Keywords
#     ...  Configuration Postcondition
#     ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{EMPTY}
#
#[G21][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset            #OK
#    [Setup]  Run Keywords
#    ...  Configuration Precondition      CN=REF_10_16_UTESRANSISO100_G21    N=5
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     35    #20
#    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     150
#    #...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     EA203761974  L1184200033    L1181207097    K9183633079
#    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{tc_additional_1369_fault_list3}
#    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     180
#    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
#     [Teardown]  Run Keywords
#     ...  Configuration Postcondition
#     ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{EMPTY}