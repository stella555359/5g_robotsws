*** Settings ***
Suite Setup          CBRS UTE Upgrade Suite Setup    UTECloud=True
Suite Teardown       CBRS Suite Teardown
Test Setup           Run keywords    CBRS Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=49
Test Teardown        CBRS Test Teardown For CB011091

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB011091_common_keyword.robot
Variables    TestData/11091_variables.py
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/cbrs_common_keywords.robot

Documentation
...    Author:linjiangjing
...    contact:jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB011091

Force Tags    RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36
...    CLOUD_5G_CLASSICAL_SA_ASOG_6xAWHQU_AZQG_HAZ

*** Test Cases ***
[1]CB011091_G_General_SiSo_SuperCell_Reconfiguration_G2_to_1supercell_per_6subcell
    [Tags]    CRT_TRUNK
    CB011091_G_General_SiSo_SuperCell_Reconfiguration_G2_to_1supercell_per_6subcell

[1]CB011091_E_General_SiSo_E2E_system_setup_with_data_transfer_E2_E3_combination
    [Tags]    CRT_TRUNK
    CB011091_E_General_SiSo_E2E_system_setup_with_data_transfer_E2_E3_combination

[1]CB011091_E_General_SiSo_Commissioning_BTS_Template_Commissioning_E1_1*AZQG_3*AWHQU
    [Tags]    CRT_TRUNK
    CB011091_E_General_SiSo_Commissioning_BTS_Template_Commissioning_E1_1*AZQG_3*AWHQU

[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    CRT_TRUNK
    CB011091_common_keyword.E2E_TL_Site_reset_without_HWF_with_OAM_KPI

[1]E2E_TL_Activation_Reset_with_OAM_KPI
    [Tags]    CRT_TRUNK
    E2E_TL_Activation_Reset_with_OAM_KPI_CB011091
