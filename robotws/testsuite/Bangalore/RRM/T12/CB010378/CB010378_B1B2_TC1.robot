*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  : The aim of the feature is to validate system behaviour to broadcast of SIB1/SIB2 to UEs.

Resource    resources/Keywords/10378_KW.robot

Suite Setup        Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${UE1}        1
${UE2}        2
${cell1_phyID}  50
${cell2_phyID}  51
${cell3_phyID}  52


*** Test Cases ***
[1][1.0] CB010378_B1B2_1_SA_inter_freq_HO_after_initial_access
        [Documentation]     This test is to verify UE measurements as mentioned below
        ...                 1) UE1 is supporting Band n77 and field extendedBand-n77-2-r17 in its UE Capabilities
        ...                 should receive measurement report from cell which is having extended freq band 77, i.e. cell 3.
        ...                 2) UE2 is supporting Band n77 but field extendedBand-n77-2-r17 is not supported in its UE Capabilities
        ...                 should recevie measurement report from cell which is having normal freq range in band 77, i.e. cell 2.
        [Tags]    QC_28278      QCD_MN_RAN        QCP_RAN_VRF
        Log to Console      Starting the test case\n
        [Setup]     Prepare for test Case - CB0010378_B1B2_TC1
        Log to Console      Registering UEs\n
        UE Register should be Successful for SA     ${UE1}
        UE Register should be Successful for SA     ${UE2}
        Log to Console      Starting DL and UL traffic for UEs\n
        Start and Validate Traffic For SA       UE_ID=${UE1}
        Start and Validate Traffic For SA       UE_ID=${UE2}
        Log to Console      Trigering A2 event for UE1
        ${Meas_id_for_UE1}      Display Measurement Configuration for UE         1       A2
        Trigger A2 Measurement      ${UE1}      ${Meas_id_for_UE1}      ${cell1_phyID}
        Log to Console      Trigering A2 event for UE2
        ${Meas_id_for_UE2}     Display Measurement Configuration for UE         2       A2
        Trigger A2 Measurement      ${UE2}      ${Meas_id_for_UE2}      ${cell1_phyID}
        Log to Console      Trigering A3 event for UE2 to cell2
        ${Meas_id_for_UE2}      Display Measurement Configuration for UE         2       A3
        Trigger A3 Measurement      ${UE2}      ${Meas_id_for_UE2}      ${cell2_phyID}
        Log to Console      Trigering A3 event for UE1 from cell1 to cell3
        ${Meas_id_for_UE1}      Display Measurement Configuration for UE         1       A3
        Trigger A3 Measurement      ${UE1}      4       ${cell3_phyID}
        Log to Console      Trigering A2 event for UE1 (For cell 3)
        ${Meas_id_for_UE1}      Display Measurement Configuration for UE         1       A2
        Run Keyword And Ignore Error       Trigger A2 Measurement      ${UE1}      5      ${cell3_phyID}
        Log to Console      Trigering A3 event for UE1 from cell3 to cell1
        ${Meas_id_for_UE1}      Display Measurement Configuration for UE         1       A3
        Run Keyword And Ignore Error       Trigger A3 Measurement      ${UE1}     7       ${cell1_phyID}
        Log to Console      Trigering A2 event for UE1 (For cell1)
        ${Meas_id_for_UE1}      Display Measurement Configuration for UE         1       A2
        Run Keyword And Ignore Error       Trigger A2 Measurement      ${UE1}      8      ${cell1_phyID}
        Log to Console      Trigering A3 event for UE1 from cell1 to cell3
        ${Meas_id_for_UE1}      Display Measurement Configuration for UE         1       A3
        Run Keyword And Ignore Error        Trigger A3 Measurement      ${UE1}      11       ${cell3_phyID}
        Log to Console      \n Starting Tear Down for Test Case
        [Teardown]      Run Keyword And Ignore Error       Common test case tear down LO AP LO

