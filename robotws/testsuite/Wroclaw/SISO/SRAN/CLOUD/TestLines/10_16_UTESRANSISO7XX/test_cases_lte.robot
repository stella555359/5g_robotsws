*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/lte_cloud_setup_teardown.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_LTE_vDU_Reset.robot
Resource    ../../TestCases/CM/Cloud_CM_LTE_vDU_Commissioning.robot

Suite Setup       Lte Cloud Suite Setup
Suite Teardown    Lte Cloud Suite Teardown

*** Variables ***
# EXAMPLE VARIABLES USED IN TEST CASES.
# REMEMBER TO ALWAYS DECLARE ONLY THOSE VARIABLES THAT YOU USE IN TEST CASES.

# Configuration files
${LTE_VDU_SCF_PATH}=         ${CURDIR}/SCF_LTE/SCFC_vDU.xml

#IN THE EXAMPLE TEST SUITE IN THE TEST CASES THE MOST FREQUENTLY USED ARGUMENTS WERE SHOWN.
#IF YOU WANT TO CHECK WHAT ARGUMENTS CAN BE USED, ALWAYS CHECK THE TEST CASE DOCUMENTATION SECTION
*** Test Cases ***
[1][1.0] General_SiSo_Auto_Cloud_LTE_vDU_Commissioning
    [Setup]  Lte Cloud Test Setup
    TC__Cloud_CM_LTE_vDU_Commissioning
    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
    [Teardown]  Lte Cloud Test Teardown

# Example without logs collection when test case PASSED
[1][1.0] General_SiSo_Auto_Cloud_LTE_vDU_Reset_Example_1
    [Setup]  Lte Cloud Test Setup
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
    TC__Cloud_STARTUP_LTE_vDU_Reset
    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
    [Teardown]  Lte Cloud Test Teardown
    ...  get_logs=${False}
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}

# Example with always logs collection
[1][1.0] General_SiSo_Auto_Cloud_LTE_vDU_Reset_Example_2
    [Setup]  Lte Cloud Test Setup
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
    TC__Cloud_STARTUP_LTE_vDU_Reset
    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
    [Teardown]  Lte Cloud Test Teardown
    ...  get_logs=${True}
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
