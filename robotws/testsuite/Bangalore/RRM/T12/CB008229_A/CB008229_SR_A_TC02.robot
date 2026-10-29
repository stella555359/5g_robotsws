*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO
...           RAN_5G_FDD     RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Adarsh
...             :contact  : adarsha.p_hegde@nokia.com
...             Aim of the feature is to validate
...             the Basic functionality for 25MHz cell bandwidth.

Resource    resources/Keywords/CB008229_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${NSA_UEID_151}       11
${TOPOLOGY}           CLOUD_5G_I_MP_AP_LO


*** Test Cases ***
[1][1.0] CB008229-SR-A-b Successful UE attachment and traffic NSA Mode
    [Documentation]      Successful UE attachment to 25MHz FDD NR Cell
    ...                  and UE UL/DL traffic validation in NSA Mode
	[Tags]    QC_28269   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare For Test Case - CB008229A
    Basic Bring Up
    Make ENDC Call
    Sleep   10s
    Traffic Should Be Successful For NSA    ${NSA_UEID_151}      5       4
    Stop Traffic    ${NSA_UEID_151}         1
    UE 5GDetach should be Successful for NSA         ${NSA_UEID_151}
    Stop Pcap Collection In GNB      gnbTcpdump      ${Log_Path}
    [Teardown]      Common Test Case Tear Down MP AP LO