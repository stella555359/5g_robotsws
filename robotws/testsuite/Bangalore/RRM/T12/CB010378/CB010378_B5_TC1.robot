*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  : This user scenario describes the gNB behavior, when a UE
...                         for which context is being created in a cell is configured with required
...                         A2 measurement for redirection.

Resource    resources/Keywords/10378_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${UE1}        1
${UE2}        2
${cell1_phyID}  50
${cell2_phyID}  51
${cell3_phyID}  52
${pattern1}     RRCConnectionRelease with NR redirectedCarrierInfo=648000
${pattern2}     UE2: Received RRCConnectionRelease with NR redirectedCarrierInfo=633364;


*** Test Cases ***
[1][1.0] CB010378_B5_1_SA_Redirection_to_5G_n77_band_(3650_to_3980_MHz)_based_on_A2_measurements
        [Documentation]     This user scenario describes the gNB behavior, when a UE
        ...     for which context is being created in a cell is configured with required
        ...     A2 measurement for redirection.
        [Tags]    QC_28276  QCD_MN_RAN    QCP_RAN_VRF
        Log to Console      Starting the test case\n
        [Setup]     Prepare for test Case - CB0010378_B5_TC1
        Log to console      Registering UEs\n
        UE Register should be Successful for SA     ${UE1}
        UE Register should be Successful for SA     ${UE2}
        Log to Console      Trigering A2 event for UE 1\n
        ${Meas_id_for_UE1}      Display Measurement Configuration for UE        1       A2
        Trigger A2 redirect Measurement      ${UE1}      ${Meas_id_for_UE1}
        Log to Console      \n Verifying UE 1 rrcReconnection release Pattern
        Run Keyword And Ignore Error    Check Pattern in Egate Console Log      ${pattern1}
        sleep       60s
        Log to Console      Trigering A2 event for UE 2\n
        ${Meas_id_for_UE2}      Display Measurement Configuration for UE        2       A2
        Trigger A2 redirect Measurement     ${UE2}      ${Meas_id_for_UE2}
        Log to Console      Starting Tear Down for Test Case
        [Teardown]      Run Keyword And Ignore Error      Common test case tear down LO AP LO
