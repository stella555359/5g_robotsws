# # # @Time    : 2022/2/18 13:47
# # # @Author  : Jian.1.Chen
# # # @Email   : jian.1.chen@nokia-sbell.com
# # # @File    : CB008797_2044.robot
# # # @Software: PyCharm
# # # @Doc     : Some Description
# # *** Settings ***
# # Documentation
# # ...    author: Chen Jian
# # ...    contact: jian.1.chen@nokia-sbell.com
# # ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# # ...    Feature CB008797-SR-B-B1
# # 
# # Resource    CB008797_keywords.robot
# # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# # 
# # Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# # ...    AND     SISO Coam Suite Setup
# # Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown
# # ...    AND     SISO Coam Suite Teardown
# # Test Setup           robot_common_operations.Common Case Setup 
# # Test Teardown        robot_common_operations.Common Case Teardown
# # Force Tags        5G_SISO    5G_RAN_TDD    CRT_TRUNK    CRT_22R3    CRT_22R4
# # 
# # *** Variables ***
# # ${if_commissioning}    True
# # # case008 variables
# # ${SSH_MAX_AUTH_ATTEMPTS_VALUE}    ${4}
# # &{BAND_RF_TEST_THRESHOLDS_DICT}    bandClass=${1}    totalRFPowerHighThreshold=${120}    totalRFPowerLowThreshold=${10}
# # @{BAND_RF_TEST_THRESHOLDS_LIST}    &{BAND_RF_TEST_THRESHOLDS_DICT}
# # 
# # *** Test Cases ***
# # CB008797_B_007_General_SiSo_Link_Diagnostic_and_Monitoring
# #     Connect to gnb coam via ssl
# #     General_SiSo_Link_Diagnostic_and_Monitoring
# #     Run Keyword And Ignore Error    COAM Teardown gnb connections
# # 
# # CB008797_B_008_NIDD_parameters_and_PDL_rule_verification_under_MNL_subcase2
# #     "Step1" check the MNL/MNL_R-productVariant
# #     "Step2" check the MNL/MNLENT/SECADM-sshMaxAuthAttempts
# #     "Step3" change sshMaxAuthAttempts to value 4 --- PDL verification should be passed
# #     "Step4" check the MNL/MNLENT/TEST/RFTHLD-bandRfTestThresholds
# #     "Step5" configure bandRfTestThresholds --- PDL verification should be failed
