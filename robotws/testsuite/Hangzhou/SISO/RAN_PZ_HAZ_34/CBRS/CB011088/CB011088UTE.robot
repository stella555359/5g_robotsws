*** Settings ***
Suite Setup          CBRS UTE Upgrade Suite Setup    UTECloud=True
Suite Teardown       CBRS Suite Teardown
Test Setup           Run keywords    CBRS Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=49
Test Teardown        CBRS Test Teardown

Resource    resources/CB011088_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB011088

Force Tags    RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36
...    CLOUD_5G_CLASSICAL_SA_ASOG_6xAWHQU_AZQG_HAZ

*** Test Cases ***
[1]CB011088_General_SiSo_E2E_system_setup_with_data_transfer_conducted_1supercell_6subcell
    [Tags]    CRT_TRUNK
    CB011088_General_SiSo_E2E_system_setup_with_data_transfer_conducted_1supercell_6subcell

[1]CB011088_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2supercell_per_3subcell
    [Tags]    CRT_TRUNK
    CB011088_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2supercell_per_3subcell

[1]CB011088_H_General_SiSo_SuperCell_Reconfiguration__2supercell_one_4subcell_and_other_2subcell_remove_one_subcell_from_4 subcells
    [Tags]    CRT_TRUNK
    CB011088_H_General_SiSo_SuperCell_Reconfiguration__2supercell_one_4subcell_and_other_2subcell_remove_one_subcell_from_4 subcells

