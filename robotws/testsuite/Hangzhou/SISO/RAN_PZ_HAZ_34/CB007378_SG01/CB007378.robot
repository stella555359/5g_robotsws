# *** Settings ***
# Suite Setup          SISO Suite Setup
# Suite Teardown       SISO Suite Teardown
# Test Setup           SISO Test Setup
# Test Teardown        SISO Test Teardown
# 
# 
# Resource     Resource/CB007378_Resource.robot
# 
# Documentation
# ...    Author:Hu Caoli
# ...    contact:caoli.hu@nokia-sbell.com
# ...    squad group:SG_01
# ...    Feature CB007378 in 5G22R3 program
# 
# Force Tags            RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED  SBTS00   SBTS22R4
# ...    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABINB1_2xAEQE    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# 
# [1]CB007378-5G_12_General_SiSo_RU_lock_unlock
#     [Tags]  CRT_UTE   CRT_TRUNK   CRT_22R4
#     [Timeout]  60 minutes
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SISO Test Setup
#     TC.CB007378-5G_12_General_SiSo_RU_lock_unlock
# 
# [1]CB007378-5G_General_SiSo_BBMOD_reset
#     [Tags]  CRT_UTE   CRT_TRUNK   CRT_22R4
#     [Timeout]  60 minutes
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SISO Test Setup
#     TC.CB007378-5G_General_SiSo_BBMOD_reset
# 
