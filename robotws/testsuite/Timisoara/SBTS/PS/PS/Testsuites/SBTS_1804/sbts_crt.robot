*** Settings ***
Documentation
...    Author: dorin.nadasan@nokia.com
...    Description: Suite prepared for Power Saving tests execution in scope of CB0010969 CB0010971
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1806 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1806 testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_1806/sbts_crt.robot



Resource        ../../Testcases/PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day/test.robot
Resource        ../../Testcases/PS.59_CB012087_A_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Time_Of_Day/test.robot
Resource        ../../Testcases/PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage/test.robot
Resource        ../../Testcases/PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage/test.robot
Resource        ../../Testcases/PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features/test.robot
Resource        ../../Testcases/PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features/test.robot
Resource        ../../Testcases/PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage/test.robot
Resource        ../../Testcases/PS.65_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Low_Voltage_Interworking_With_Time_Of_Day/test.robot
Resource        ../../Testcases/PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431/test.robot
Resource        ../../Testcases/PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day/test.robot
Resource        ../../Testcases/PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage/test.robot
Resource        ../../Testcases/PS.71_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Low_Voltage_Interworking_With_CB010443/test.robot
Resource        ../../Testcases/PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443/test.robot
#[1][1.0] PS_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day
#    [Setup]  common.Common Test Setup
#    PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day
#    [Teardown]  PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day.Test Case Teardown
#
#[1][1.0] PS_CB012087_A_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Time_Of_Day
#    [Setup]  common.Common Test Setup
#    PS.59_CB012087_A_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Time_Of_Day
#    [Teardown]  PS.59_CB012087_A_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Time_Of_Day.Test Case Teardown
#
#[1][1.0] PS_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage
#    [Setup]  common.Common Test Setup
#    PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage
#    [Teardown]  PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage.Test Case Teardown

#[1][1.0] PS_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage
#    [Setup]  common.Common Test Setup
#    PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage
#    [Teardown]  PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Test Case Teardown


*** Test Cases ***


#[1][1.0] PS_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day
#    [Setup]  common.Common Test Setup
#    Set Test Variable    ${TDD_RU_SERIAL_NUMBER}  L1244007372
#    PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day
#    [Teardown]  PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day.Test Case Teardown
#
#[1][1.0] PS_CB012087_A_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Time_Of_Day
#    [Setup]  common.Common Test Setup
#    Set Test Variable    ${TDD_RU_SERIAL_NUMBER}  L1244007372
#    PS.59_CB012087_A_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Time_Of_Day
#    [Teardown]  PS.59_CB012087_A_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Time_Of_Day.Test Case Teardown
#
#[1][1.0] PS_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage
#    [Setup]  common.Common Test Setup
#    Set Test Variable    ${TDD_RU_SERIAL_NUMBER}  L1244007372
#    PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage
#    [Teardown]  PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage.Test Case Teardown
#
#[1][1.0] PS_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage
#    [Setup]  common.Common Test Setup
#    Set Test Variable    ${TDD_RU_SERIAL_NUMBER}  L1244007372
#    PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage
#    [Teardown]  PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Test Case Teardown

[1][1.0] PS_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features
    [Setup]  common.Common Test Setup
    Set Test Variable    ${FDD_RU_SERIAL_NUMBER}  BL1844G11L5
    Set Test Variable    ${TDD_RU_SERIAL_NUMBER}  L1244007372
    PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features
    [Teardown]  PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Test Case Teardown

[1][1.0] PS_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features
    [Setup]  common.Common Test Setup
    Set Test Variable    ${FDD_RU_SERIAL_NUMBER}  BL1844G11L5
    Set Test Variable    ${TDD_RU_SERIAL_NUMBER}  L1244007372
    PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features
    [Teardown]  PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Test Case Teardown

[1][1.0] PS_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage
    [Setup]  common.Common Test Setup
    Set Test Variable    ${FDD_RU_SERIAL_NUMBER}  BL1844G11L5
    Set Test Variable    ${TDD_RU_SERIAL_NUMBER}  L1244007372
    PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage
    [Teardown]  PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Test Case Teardown

[1][1.0] PS_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Low_Voltage_Interworking_With_Time_Of_Day
    [Setup]  common.Common Test Setup
    Set Test Variable    ${FDD_RU_SERIAL_NUMBER}  BL1844G11L5
    Set Test Variable    ${TDD_RU_SERIAL_NUMBER}  L1244007372
    PS.65_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Low_Voltage_Interworking_With_Time_Of_Day
    [Teardown]  PS.65_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Low_Voltage_Interworking_With_Time_Of_Day.Test Case Teardown

[1][1.0] PS_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431
    [Setup]  common.Common Test Setup
    Set Test Variable    ${TDD_RU_SERIAL_NUMBER}  L1244007372
    PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431
    [Teardown]  PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Test Case Teardown
#
[1][1.0] PS_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day
    [Setup]  common.Common Test Setup
    PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day
    [Teardown]  PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Test Case Teardown

[1][1.0] PS_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage
    [Setup]  common.Common Test Setup
    Set Test Variable  ${RU_SERIAL_NUMBER}  BL1844G11L5
    PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage
    [Teardown]  PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Test Case Teardown

[1][1.0] PS_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Low_Voltage_Interworking_With_CB010443
    [Setup]  common.Common Test Setup
    #Set Test Variable  ${RU_SERIAL_NUMBER}  BL1844G11L5
    PS.71_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Low_Voltage_Interworking_With_CB010443
    [Teardown]  PS.71_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Low_Voltage_Interworking_With_CB010443.Test Case Teardown

[1][1.0] PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443
    [Setup]  common.Common Test Setup
    #Set Test Variable  ${RU_SERIAL_NUMBER}  BL1844G11L5
    PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443
    [Teardown]  PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Test Case Teardown
