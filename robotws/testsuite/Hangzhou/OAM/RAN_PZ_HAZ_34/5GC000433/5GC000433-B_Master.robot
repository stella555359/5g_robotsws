*** Settings ***
Suite Setup           Run Keywords     SISO Coam Suite Setup
...                   AND     Case Preparation
Suite Teardown        SISO Coam Suite Teardown
Test Setup            SISO Coam Test Setup
Test Teardown         SISO Coam Test Teardown
Test Timeout          200 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      Resource/5GC000433_common_KW.robot

Documentation
...    Author: Annie hu
...    Contact: Annie.hu@nokia-sbell.com
...    squad group:SG_05
...    Feature 5GC000443-B in 5G21A program

Force Tags            5G_RAN_TDD
...    PY36

*** Test Cases ***
[1]5GC000433-B_01_05_Counter_Update_M40002C0_ENERGY_CONSUMPTION_IN_SM
    [Tags]    CIT_TRUNK   CRT_25R2   CDRT_24R3
     #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40002C0
    @{counterid_list}    Create List    M40002C0   M40002C1   M40002C2
    Check_Energy_Measurement_Counter    counterid_list=${counterid_list}

#[1]5GC000433-B_01_06_Counter_Update_M40002C1_ENERGY_CONSUMPTION_IN_RF
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40002C1
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
#
#[1]5GC000433-B_01_07_Counter_Update_M40002C2_ENERGY_CONSUMPTION_IN_BTS
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40002C2
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}


[1]5GC000433-B_01_08_Counter_Update_M40003C0_MIN_INPUT_VOLTAGE_IN_RF
    [Tags]    CRT_22R1    CDRT_TRUNK   CRT_22R2   CRT_22R3   CRT_22R4
#    @{counterid_list}    Create List    M40003C0
    @{counterid_list}    Create List    M40003C0  M40003C1  M40003C2  M40003C3  M40003C4  M40003C5
    Check_Energy_Measurement_Counter    counterid_list=${counterid_list}

#[1]5GC000433-B_01_09_Counter_Update_M40003C1_MAX_INPUT_VOLTAGE_IN_RF
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40003C1
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
#
#[1]5GC000433-B_01_10_Counter_Update_M40003C2_RU_ENERGY_CONSUMPTION
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40003C2
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
#
#[1]5GC000433-B_01_11_Counter_Update_M40003C3_RU_MIN_PWR_USAGE
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40003C3
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
#
#[1]5GC000433-B_01_12_Counter_Update_M40003C4_RU_AVG_PWR_USAGE
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40003C4
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
#
#[1]5GC000433-B_01_13_Counter_Update_M40003C5_RU_MAX_PWR_USAGE
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40003C5
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}

[1]5GC000433-B_01_14_Counter_Update_M40004C0_SM_ENERGY_CONSUMPTION
    [Tags]    CRT_22R1    CDRT_TRUNK   CRT_22R2    CRT_22R3   CRT_22R4
    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40004C0
    @{counterid_list}    Create List    M40004C0  M40004C1  M40004C2  M40004C3  M40004C4  M40004C5
    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}

#[1]5GC000433-B_01_15_Counter_Update_M40004C1_SM_MIN_PWR_USAGE
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40004C1
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
#
#[1]5GC000433-B_01_16_Counter_Update_M40004C2_SM_AVG_PWR_USAGE
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40004C2
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
#
#[1]5GC000433-B_01_17_Counter_Update_M40004C3_SM_MAX_PWR_USAGE
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40004C3
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
#
#[1]5GC000433-B_01_18_Counter_Update_M40004C4_MIN_INPUT_VOLTAGE_IN_SM
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40004C4
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
#
#[1]5GC000433-B_01_19_Counter_Update_M40004C5_MAX_INPUT_VOLTAGE_IN_SM
#    #Modify Energy Consumption Counter Parameter
#    @{counterid_list}    Create List    M40004C5
#    Check_Energy_Measurement_Counter     counterid_list=${counterid_list}
