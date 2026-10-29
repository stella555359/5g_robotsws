*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  : This user scenario describes the gNB behavior, when UEs for which context
...             is being created in a new P(S)Cell is configured with A1 measurements for steering to
...             preferred NR layer.

Resource    resources/Keywords/10378_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${UE1}        1
${UE2}        2

*** Test Cases ***
[1][1.0] CB010378_B4_1_SA_A1_config_for_steering_to_pref_NR_layer_after_initial_access
        [Documentation]    This user scenario describes the gNB behavior, when UEs for which context
        ...           is being created in a new P(S)Cell is configured with A1 measurements for steering to
        ...           preferred NR layer.
        [Tags]    QC_28277  QCD_MN_RAN    QCP_RAN_VRF
        Log to Console      \n Starting the test case
        [Setup]     Prepare for test Case - CB0010378_B4_1
        Log to Console      \n Registering UEs
        UE Register should be Successful for SA     ${UE1}
        UE Register should be Successful for SA     ${UE2}
        Log to Console      \n Starting DL and UL traffic for UEs
        Start and Validate Traffic For SA       UE_ID=${UE1}
        Start and Validate Traffic For SA       UE_ID=${UE2}
        Get Configured Measurements of UE     ${UE2}
        Get Configured Measurements of UE     ${UE1}
        Trigger A1 Measurement      1       1
        Get Configured Measurements of UE     ${UE1}
        Log to Console          \n Starting Test Tear Down...
        [Teardown]      Run Keyword And Ignore Error       Common test case tear down LO AP LO
