*** Settings ***
Suite Setup          SBTS Suite Setup
Suite Teardown       SBTS Suite Teardown
Test Setup           SBTS Test Setup
Test Teardown        SBTS Test Teardown
Test Timeout         4h

Resource    ./resource/CB009077_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009077 in SBTS24R3 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***
@{fault_list}   61074

*** Test Cases ***
[1]CB009077-SR-C-b_01_Configure_customer_LCS_parameters_manually_for_4G_AQQL
    [Tags]    1S-2CC-1D1U-LTE   CIT_TRUNK
    Configure_customer_LCS_parameters_manually_for_4G_AQQL

[1]CB009077-SR-E-a_02_Storing_location_into_RU_NVM_5G_AQQL
    [Tags]    CRT_TRUNK
    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    Set Suite Variable    ${gNb_CuType}    SA
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    Storing_location_into_RU_NVM_5G_AQQL

[1]CB009077-SR-E-a_01_Storing_location_into_RU_NVM_4G_AQQL
    [Tags]    1S-2CC-1D1U-LTE   CRT_TRUNK
    Storing_location_into_RU_NVM_4G_AQQL

[1]CB009077-SR-E-a_02_Storing_location_into_RU_NVM_5G_AWHHF
    [Tags]    CRT_TRUNK   1S-2CC-NR70-NR70   SBTS00
    [Setup]    Run keywords     Allowed Watchdog additional alarms    fault_list=${fault_list}
    ...    AND   SBTS Test Setup
    Storing_location_into_RU_NVM_5G_AWHHF    ru_index=1

[1]CB009077-SR-E-a_03_Storing_location_into_RU_NVM_with_removing_configured modulePositionInformation_5G_AQQL
    [Tags]    CRT_TRUNK
    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ${gNb_CuType}    Get gNB CU type
    Set Suite Variable    ${gNb_CuType}
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    Storing_location_into_RU_NVM_with_removing_configured_modulePositionInformation

[1]CB009077-SR-E-a_04_Clear_location_info_in_RU_NVM_5G_AQQL
    [Tags]    CRT_TRUNK
    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ${gNb_CuType}    Get gNB CU type
    Set Suite Variable    ${gNb_CuType}
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    Clear_location_info_in_RU_NVM
