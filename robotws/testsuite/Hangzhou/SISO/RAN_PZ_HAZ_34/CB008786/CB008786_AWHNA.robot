*** Settings ***
Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup    AND    SISO Suite Setup AWHNA
Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown    AND    SISO Suite Teardown
Test Setup           Run Keywords    robot_common_operations.Common Case Setup    AND    SISO Test Setup
Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown    AND    SISO Test Teardown
Test Timeout         600 min

Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007758/Resource/CB007758_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Documentation
...    Author:Shi Taotao
...    contact:taotao.shi@nokia-sbell.com
...    squad group:SG_01
...    Feature CB008786 in SBTS24R2 program
...    Add Feature CB009783 in SBTS24R3 program
Force Tags            5G_RAN    5G_RAN_TDD  CLOUD_5G_CLASSICAL_SA_ASIML_ABINB1_ABIQB2B3_AWHNA_3xAWHQ_AWPTD
...    PY36

*** Test Cases ***
[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]  CRT
    run keyword if    '${Branch_version}'!='SBTS24R2'
    ...    COAM_Admin.commission    ${CFGFILE_PATH}/SBTS24R3_CB009783_NR2CC_LTE4CC.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Check Alarm and stop robot testing when unexpected alarm raised
    TC.62_Manual_SiSo_SM_BTS_Site_Reset

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]  CRT
    run keyword if    '${Branch_version}'!='SBTS24R2'
    ...    COAM_Admin.commission    ${CFGFILE_PATH}/SBTS24R3_CB009783_LTE4CC.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Check Alarm and stop robot testing when unexpected alarm raised
    TC.60_General_SiSo_RU_lock_unlock

[1][1.0] Manual_SiSo_REC_Radio_Module_power_reset
   [Tags]  CRT
#   TC.x85_L3Call_For_N53
   run keyword if    '${Branch_version}'!='SBTS24R2'
   ...    COAM_Admin.commission    ${CFGFILE_PATH}/SBTS24R3_CB009783_NR4CC.xml
   wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
   Check Alarm and stop robot testing when unexpected alarm raised
   TC.11_General_SiSo_RF_module_power_reset
