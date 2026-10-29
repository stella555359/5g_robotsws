# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource     Resources/CB005770_common_keyword.robot
# Variables    Resources/variables_5770.py
# 
# Documentation
# ...    Author: shufei.chen
# ...    Contact: shufei.chen@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB005770
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
# ...   PY36
# ...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_5GC002374
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_ANT_PHYANT_Configuration
#    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    WebEM_Online_Static_HW_Capabilities_Validation_With_ANT_PHYANT_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_ANT_Port_ID_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    WebEM_Online_Static_HW_Capabilities_Validation_With_ANT_Port_ID_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Bandwidth_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    WebEM_Online_Static_HW_Capabilities_Validation_With_Bandwidth_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Beamforming_Type_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Beamforming_Type_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Beamforming_Set_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Beamforming_Set_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_RMOD_EAC_lines_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_RMOD_EAC_lines_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_SMOD_EAC_lines_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_SMOD_EAC_lines_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Passive_MHA_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Passive_MHA_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_MultiBand_Bandwidth_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_MultiBand_Bandwidth_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Carriers_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Carriers_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Cell_Power_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Cell_Power_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Frequency_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Frequency_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_MHA_TxGain_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_MHA_TxGain_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_VSWR_Measurement_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_VSWR_Measurement_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Split_Mode_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Split_Mode_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_SFP_Speed_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_SFP_Speed_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Path_Delay_Measurement_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Path_Delay_Measurement_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_RAT_Sharing_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_RAT_Sharing_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_RET_Port_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_RET_Port_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Cell_Duplex_Mode_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Cell_Duplex_Mode_Configuration
# 
# [1]WebEM_Online_Static_HW_Capabilities_Validation_With_Radio_Protocol_Type_Configuration
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     WebEM_Online_Static_HW_Capabilities_Validation_With_Radio_Protocol_Type_Configuration
