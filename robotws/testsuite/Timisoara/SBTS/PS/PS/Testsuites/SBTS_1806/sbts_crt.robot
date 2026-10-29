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


*** Test Cases ***


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
#
#[1][1.0] PS_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage
#    [Setup]  common.Common Test Setup
#    PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage
#    [Teardown]  PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Test Case Teardown

#[1][1.0] PS_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features
#    [Setup]  common.Common Test Setup
#    Set Test Variable   ${FDD_RU_SERIAL_NUMBER}  BL2146V0QE6
#    Set Test Variable   ${TDD_RU_SERIAL_NUMBER}  AH231800653
#    PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features
#    [Teardown]  PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Test Case Teardown
#
#[1][1.0] PS_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features
#    [Setup]  common.Common Test Setup
#    Set Test Variable   ${FDD_RU_SERIAL_NUMBER}  BL2146V0QE6
#    Set Test Variable   ${TDD_RU_SERIAL_NUMBER}  AH231800653
#    PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features
#    [Teardown]  PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Test Case Teardown

[1][1.0] PS_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage
    [Setup]  common.Common Test Setup
    Set Test Variable   ${FDD_RU_SERIAL_NUMBER}  BL2146V0QE6
    Set Test Variable   ${TDD_RU_SERIAL_NUMBER}  AH231800653
    PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage

    [Teardown]  PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Test Case Teardown

#[1][1.0] PS_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Low_Voltage_Interworking_With_Time_Of_Day
#    [Setup]  common.Common Test Setup
#    Set Test Variable   ${FDD_RU_SERIAL_NUMBER}  BL2146V0QE6
#    Set Test Variable   ${TDD_RU_SERIAL_NUMBER}  AH231800653
#    PS.65_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Low_Voltage_Interworking_With_Time_Of_Day
#    [Teardown]  PS.65_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Low_Voltage_Interworking_With_Time_Of_Day.Test Case Teardown
##
#[1][1.0] PS_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431
#    [Setup]  common.Common Test Setup
#    PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431
#    [Teardown]  PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Test Case Teardown
