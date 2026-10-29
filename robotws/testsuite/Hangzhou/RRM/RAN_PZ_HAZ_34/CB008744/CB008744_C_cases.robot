*** Settings ***
Documentation     author: yulu
...               contact: lu.1.yu@nokia-sbell.com
...               squad group: SG_02
Force Tags        5G_RRM
...    PY36
Suite Setup       robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008744/Resources/CB008744_C_commen_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot



*** Variables ***



*** Test Cases ***
[1]CB008744_5G_C_General_SiSo_Single_UE_Throughput_Curves_Execution_Enable
    [Tags]  CB008744   CIT_TRUNK
    [Setup]  CB008744 Case Setup
    Load Case SCF and Commission SCF       default_scf=${scf_path}/3xLTE20+NR100+20MHz_scf.xml
    Check CRPT file
    MultiUE check tput and check ue attach log
    Check L2L1 Bip log
   [Teardown]  CB008744 Case Teardown
