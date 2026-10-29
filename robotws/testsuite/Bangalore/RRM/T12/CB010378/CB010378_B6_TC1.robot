*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  : Configuration of Inter-Frequency A4 measurement on extended n77 (3650 - 3980 MHz)
...              during Idle mode Traffic Steering from NR SA to LTE EN-DC carrier

Resource       resources/Keywords/10378_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${UE1}        1
${UE2}        2
${pattern1}     rrcReconfigurationComplete
${pattern2}     freqPriorityListEUTRA
${pattern3}     rrcRelease
${cell1_phyID}  50
${cell2_phyID}  51
${cell3_phyID}  52

*** Test Cases ***
[1][1.0] CB010378_B6_1_SA_Verify_Configuration_of_Inter_Frequency_A4_measurement_on_extended_n77
        [Documentation]     This user scenario describes the gNB behavior for A4 measurement configuration on extended n77 (3650 - 3980 MHz)
        ...         during Idle mode Traffic Steering from NR SA to LTE EN-DC carrier algorithm
        ...         without mobility profiles.
        [Tags]    QC_28275  QCD_MN_RAN    QCP_RAN_VRF
        Log to Console      Starting the test case\n
        [Setup]     Prepare for test Case - CB0010378_B6_TC1
        UE Register should be Successful for SA     ${UE1}
        Log to Console      \nStarting DL and UL traffic for UE 1
        Start and Validate Traffic For SA       UE_ID=${UE1}
        sleep       10s
        Stop Traffic For SA    ${UE1}
        sleep     20s
        Read WTS Output Until Pattern Matches      ${pattern1}     timeout=120
        Get Configured Measurements of UE     ${UE1}
        Trigger A4 Measurement      ${UE1}      1      ${cell3_phyID}
        Log to Console      \nVerifying  freqPriorityListEUTRA  msg for UE1
        Read WTS Output Until Pattern Matches      ${pattern2}     timeout=200
        Get Configured Measurements of UE     ${UE1}
        UE Register should be Successful for SA     ${UE2}
        Log to Console     \nStarting DL and UL traffic for UE 2
        Start and Validate Traffic For SA       UE_ID=${UE2}
        sleep       10s
        Stop Traffic For SA    ${UE2}
        Log to Console      \nVerifying rrcRelease   msg for UE2
        Check Pattern in Egate Console Log      ${pattern3}
        Log to Console      \nStarting Tear Down for Test Case
        [Teardown]      Run Keyword And Ignore Error        Common test case tear down LO AP LO

