*** Settings ***
Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup    AND    SISO Suite Setup
Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown    AND    SISO Suite Teardown
Test Setup           Run Keywords    robot_common_operations.Common Case Setup    AND    SISO Test Setup
Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown    AND    SISO Test Teardown
Test Timeout         600 min

Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007758/Resource/CB007758_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Documentation
...    Author:Shi Taotao
...    contact:taotao.shi@nokia-sbell.com
...    squad group:SG_01
...    Feature CB010267 in SBTS24R2 program

Force Tags            5G_RAN    5G_RAN_TDD  CLOUD_5G_CLASSICAL_SA_ASIML_ABINB1_ABIQB2B3_AWHNA_3xAWHQ_AWPTD
...    PY36

*** Test Cases ***
[1][1.1] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]  CRT
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer
    ...          attach_cell_index=${TCCB010267_INPUT['TC24']['UE_Attach_Cell_index']}
    ...          UECFG=${TLCommonConfig['MultiUECFG_10267']}
    ...          UE_index=${TCCB010267_INPUT['TC24']['UE_index']}

[1][3.0] General_SiSo_Cell_block_and_unblock
    [Tags]  CRT
    TC.63_General_SiSo_Cell_block_and_unblock

[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]  CRT
    TC.62_Manual_SiSo_SM_BTS_Site_Reset

