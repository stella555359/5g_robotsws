*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  : The purpose of this TC is to verify successful UE configuration of the
...                         Inter-band FDD - TDD FR1 UL CA feature for single UE with 2 aggregated
...                         PCell is FDD carrier and single SCell is TDD FR1 carrier in SA mode.
Resource    resources/Keywords/CB008152_KW.robot
Suite Setup        Updated Suite Setup
Suite Teardown     Common Suite Teardown


*** Variables  ***
${UE1}        1
${UE2}        2
@{ids}      1    2    3    4    5
${pattern1}    SCellIndex 1 activated successfully at airphone.
${pattern2}     sCellToAddModList


*** Test Cases ***
[1][1.0] CB008152_B_IWK.7_TC7_UL_CA_F+T_with_35MHz_FDD_cell_SA
        [Tags]    QC_28296   QCD_MN_RAN    QCP_RAN_VRF
        Log to Console      \nStarting the test case
        ${Test_CaseNumber}=     Set Variable    CB008152_TC7
        ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
        [Setup]    Prepare for test Case - CB008251_TC7_TC8
        Log to Console      \n Registering UE1
        UE Register should be Successful for SA     ${UE1}
        sleep    30s
        Log to Console   \n Verification of Scell index addition and activation from EGATE LOG
        Run Keyword And Ignore Error    Check Pattern in Egate Console Log      ${pattern2}
        Run Keyword And Ignore Error    Check Pattern in Egate Console Log      ${pattern1}
        Log to Console      \n Starting DL and UL traffic for UE1
        FOR    ${id}    IN      @{ids}
            Log to Console      ${id}
            Start and Validate Traffic For CA       UE_ID=${UE1}
        END
        sleep     30s
        Verification of Downlink throughput     id=1
        sleep    30s
        [Teardown]     Run Keyword And Ignore Error     Common test case tear down LO AP LO


*** keywords ***
Start and Validate Traffic For CA
    [Arguments]    ${dl_rate}=150    ${ul_rate}=150    ${UE_ID}=${UE_ID}
    Log to Console    \nRunning DL + UL Traffic
    wtsrunner.trf_data_start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}
    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=1   qfi=1    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}