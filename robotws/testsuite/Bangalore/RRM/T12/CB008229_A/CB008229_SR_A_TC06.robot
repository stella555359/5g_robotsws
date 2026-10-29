*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO

Documentation   :copyright: Nokia
...             :author   : Adarsha
...             :contact  : adarsha.p_hegde@nokia.com
...             The TC shall help to validate Intra-gNB handover between cells configured between different BW.
Resource    resources/Keywords/CB008229_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${UE_51}            51
${IEFR_A2MEAS_ID}   1
${IEFR_A3MEAS_ID}   5


*** Test Cases ***
[1][1.0] CB008229-SR-A-f Intra-gNB handover between cells configured between different BW
    [Documentation]     25MHz FDD Inter frequency mobility from 25Mhz to 20Mhz Cell.
    [Tags]    QC_28268   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]      Prepare For Test Case - CB008229 TC06
    Start Pcap Collection In GNB CU
    Basic Bring Up
    Log To Console       \nRegistering & validating traffice for UE id 51
    Make SA Call         ${UE_51}    ${GW_ID}
    Log To Console       \nStarting HO
    Trigger A2 Measurement    ${UE_51}    ${IEFR_A2MEAS_ID}    51
    Trigger A3 Measurement    ${UE_51}    ${IEFR_A3MEAS_ID}    52
    Sleep   30s
    Stop Data Traffic For SA    ${UE_51}
    Stop Pcap Collection In GNB     gnbTcpdump      ${Log_Path}
    [Teardown]    Common Test Case Tear Down LO AP LO
