*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Adarsha
...             :contact  : adarsha.p_hegde@nokia.com
...             The TC shall help to validate NSA Intra-gNB handover between cells.

Resource        resources/Keywords/CB008278_Keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Suite TearDown for CB008278

*** Variables ***
${UE_ID_NSA}               11
${IEFR_a3meas_id}           1
${TOPOLOGY}           CLOUD_5G_I_MP_AP_LO

*** Test Cases ***
[1][1.0] CB008278-A-c_3 Intra-gNB Intra-frequency handover between cells configured with 10Mhz ChBw in NSA Mode
    [Documentation]     Intra-gNB Intra-frequency handover between cells configured with 10Mhz ChBw in NSA Mode
    [Tags]    QC_28272   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]             Prepare for test Case - CB008278_AC3
    Log to Console      \n Starting the CB008278_AC3
    LTE Attach should be Successful for NSA     11
    Enb Endc Param      id=1    serving_cell_index_range_scg=5:31
    ${match_str}     UE Attach should be Successful for NSA      11   1
    Sleep   30s
    Log to Console      \n Starting HO
    Trigger A3 Measurement for NSA    ${UE_ID_NSA}    ${IEFR_a3meas_id}    51
    UE 5GDetach should be Successful for NSA    11
#    [Teardown]    Common Test Teardown For MP AP LO
