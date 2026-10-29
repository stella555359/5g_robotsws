*** Settings ***
Documentation
...    | CB012474 Periodic retries of EN-DC Configuration Update to MeNB from SgNB  |
...    | Test case:    | CB012474                                                               |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60, S24, S24 Ultra                     |
...    | Author:       | Michele                                                                |
...    | Team:         | MN RAN RD VRF ULM 3                                                    |
...    | Contact:      | I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com                               |
...    | Description:  | TCs for CB012474                                                       |

Library  OperatingSystem
Library  String
Library  BuiltIn

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource    testsuite/Ulm/SyVe/CB012474/resources/CB012474_Workbench_KW.robot
Resource    testsuite/Ulm/SyVe/resources/scf_info.robot

Suite Setup     Prepare TL For CB012474 Testing
Suite Teardown  Save All Logs And Teardown TL For CB012474


*** Test Cases ***
CB012474_TC01_feature_activation
    [Documentation]
    ...  | CB012474_TC01     |
    ...  | The purpose of test case is to verify the CB012474 feature activation.  |
    ...  | CB012474_Periodic_retries_of_EN-DC_Configuration_Update_to_MeNB_from_SgNB  |
    [Tags]    QCD_MN_RAN
    ...    CB012474_TC01
    [Setup]    Setup Test Scenario For CB012474
    Log To Console    ${\n}CB012474 TC01 feature activation.

    ${qc_project_to_Use}=    scf_info.Setup QCP_ for report    SBTS00=RAN_VRF    SBTS25R2=RAN_VRF    SBTS25R1=RAN_VRF    SBTS24R3=RAN_ST
    ${QC_ID_to_Use}=    scf_info.Setup QC_ID for report    SBTS00=50867    SBTS25R2=125012    SBTS25R1=789012    SBTS24R3=123456
    Log To Console    ${\n}Report to: ${qc_project_to_Use} ${QC_ID_to_Use}.

    Log To Console    ${\n}Commissioning...

    [Teardown]    Run Keywords
    ...    Log To Console    ${\n}DeCommissioning...
    ...    AND
    ...    Test Scenario Teardown


[1]CB012474_TC02_Successful_reattempt_of_EN-DC_Configuration_and_completion_of_cell_addition_upon_reattempt_timer_expiry
    [Documentation]
    ...  | CB012474_TC02     |
    ...  | The purpose of test case is to verify the CB012474 feature activation.  |
    ...  | CB012474_Periodic_retries_of_EN-DC_Configuration_Update_to_MeNB_from_SgNB  |
    [Tags]    QCD_MN_RAN
    ...    CB012474_TC02
    [Setup]    Setup Test Scenario For CB012474
    Log To Console    ${\n}CB012474 TC02 Successful reattempt of EN-DC Configuration and completion of cell addition upon reattempt timer expiry.

    ${qc_project_to_Use}=    scf_info.Setup QCP_ For Report    SBTS00=RAN_VRF    SBTS25R2=RAN_VRF    SBTS25R1=RAN_VRF    SBTS24R3=RAN_ST
    ${QC_ID_to_Use}=         scf_info.Setup QC_ID For Report    SBTS00=123456    SBTS25R2=125013    SBTS25R1=123456    SBTS24R3=123456
    Log To Console    ${\n}Report to: ${qc_project_to_Use} ${QC_ID_to_Use}.

    Log To Console    ${\n}Commissioning...

    [Teardown]    Run Keywords
    ...    Log To Console    ${\n}DeCommissioning...
    ...    AND
    ...    Test Scenario Teardown
