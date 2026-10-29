*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  : The aim of the feature is to validate system behaviour to broadcast of SIB1/SIB2 to UEs.

Resource    resources/Keywords/10378_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${UE_ID}        1
${pattern1}      SIB1 FrequencyInfoDL additionalSpectrumEmission: 2
${pattern2}      SIB2 intraFreqCellReselectionInfo additionalSpectrumEmission: 2
${pattern3}      eNB 2 cell 3: SystemInformationBlockType1-NR updated


*** Test Cases ***
[1][1.0] CB010378_B10_1_SIB1_or_SIB2_Cell_Braodcasting_in_3650_to_3980_MHz_cell_with_CB010378_feature_flag_enabled
        [Documentation]     this test is to verify SIB1 and SIB2
        ...                 broadcasting in cell with feature flag enabled
        [Tags]    QC_28279    QCD_MN_RAN    QCP_RAN_VRF
        Log to Console      \n Starting the test case
        [Setup]     Prepare for test Case - CB0010378_B10_1
        Check Pattern in Egate Console Log      ${pattern1}
        Check Pattern in Egate Console Log      ${pattern2}
        sleep     120s
        Disable ff for CB010378_B10_1
        Check Pattern in Egate Console Log      ${pattern3}
        sleep       200s
        Log to Console         \n2nd time feature enabling..
        Enable ff for CB0010378_B10_1
        Check Pattern in Egate Console Log      ${pattern1}
        Check Pattern in Egate Console Log      ${pattern2}
        sleep     300s
        Disable ff for CB010378_B10_1
        Check Pattern in Egate Console Log      ${pattern3}
        Log to Console      \nStarting Tear Down for Test Case
        [Teardown]      Run Keyword And Ignore Error        Common test case tear down LO AP LO

