*** Settings ***
Suite Setup          SISO Suite Setup
Suite Teardown       SISO Suite Teardown
Test Setup           SISO Test Setup
Test Teardown        SISO Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource          Resources/CB007963_Resouce.robot

Documentation
...    Author:Lixia Wang
...    contact:lixia.wang@nokia-sbell.com
...    squad group:SG_01
...    Feature CB007963

Force Tags            RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED  SBTS00   SBTS22R4
...    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABINB1_2xAEQE
...    CLOUD_5G_CLASSICAL_FULLRACK_QC_SA_ASIBL_ABIOB1_AWHQN-ASIBR_ABINB4_AWHQX     PY36

*** Variables ***

*** Test Cases ***
[1]CB007963-SR-B_010_Parameter ruECpriPortNumber of ToP Master_1 configured to value which is out of scope
    [Tags]    CRT_TRUNK    CRT_UTE
    KW.Parameter_ruECpriPortNumber_of_ToP_Master_1_configured_to_value_which_is_out_of_scope

*** Keywords ***
