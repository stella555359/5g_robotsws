*** Settings ***
Documentation
...    Author:  You Xingkai
...    Contact: xingkai.you@nokia-sbell.com
...    Feature: CB008609
...    Release: 22R4
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}
${scfc_file_TC17}    CB008609_TC17_ASOE_3xAZHL_TDD_eCPRI_12LNCEL_4T4R_2T2R_mixed.xml
${scfc_file_TC25}    CB008609_TC25_ASOE_2xAZHL_TDD_eCPRI_6LNCEL_2T2R.xml
${scfc_file_TC26}    CB008609_TC26_ASOE_2xAZHL_TDD_eCPRI_6LNCEL_8T8R.xml
${scfc_file_TC34}    CB008609_TC34_ASOE_2xAZHL_TDD_eCPRI_6LNCEL_8T8R.xml
${scfc_file_TC35}    CB008609_TC35_ASOE_3xAZHL_TDD_eCPRI_12LNCEL_8T8R.xml

*** Test Cases ***
TC17_CB008609_SR_B_US02_Automatic_allocation_of_cells_to_pools_IQ_farward_from_LokiB_to_LokiA_ecpri_trunk
    [Tags]    CB008609    TC17    QL3    QC_339352    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC17}
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:20; 10:20; 13:20; 14:20; 3:20; 4:20; 7:20; 8:20; 11:20; 12:20; 15:20; 16:20
    Adjust HBTE attenuation values    10.108.241.29    1:20; 2:20; 3:20; 4:20; 5:20; 6:20; 7:20; 8:20
    Perform 4G Cell block 2,3,4,5,6,7,8,9,10,11,12 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6,7,8,9,10,11,12 via AdminCLI
    Check bbPool Cell Mapping TC1735

TC25_CB008609_SR_B_US02_Automatic_allocation_of_cells_to_pools_IQ_farward_from_LokiB_to_LokiA_ecpri_trunk
    [Tags]    CB008609    TC25    QL3    QC_339353    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC25}
    Perform 4G Cell block 2,3,4,5,6 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6 via AdminCLI
    Check bbPool Cell Mapping TC252634

TC26_CB008609_SR_B_US06_Manual_allocation_of_cells_to_pools_ecpri_trunk
    [Tags]    CB008609    TC26    QL3    QC_339354    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC26}
    Perform 4G Cell block 2,3,4,5,6 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6 via AdminCLI
    Check bbPool Cell Mapping TC252634

TC34_CB008609_SR_B_US05_Automatic_allocation_of_cells_to_pools_using_L1_balanced_mode_and_logical_group_identifier_cell_block_unblock_ecpri_trunk
    [Tags]    CB008609    TC34    QL3    QC_339355    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC25}
    Perform 4G Cell block 1,3,4 via AdminCLI
    sleep    20s
    Perform 4G Cell unblock 4,3,1 via AdminCLI
    Check bbPool Cell Mapping TC252634
    Perform 4G Cell block 2,3,4,5,6 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6 via AdminCLI

TC35_CB008609_SR_B_US02_Automatic_allocation_of_cells_to_pools_IQ_farward_from_LokiB_to_LokiA_IQ_data_collection_ecpri_trunk
    [Tags]    CB008609    TC35    QL3    QC_339356    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC35}
    Perform 4G Cell block 2,3,4,5,6,7,8,9,10,11,12 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6,7,8,9,10,11,12 via AdminCLI
    Check bbPool Cell Mapping TC1735

TC17_CB008609_SR_B_US02_Automatic_allocation_of_cells_to_pools_IQ_farward_from_LokiB_to_LokiA_ecpri_branch
    [Tags]    CB008609    TC17    QL3    Branch    QC_538340
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC17}
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:20; 10:20; 13:20; 14:20; 3:20; 4:20; 7:20; 8:20; 11:20; 12:20; 15:20; 16:20
    Adjust HBTE attenuation values    10.108.241.29    1:20; 2:20; 3:20; 4:20; 5:20; 6:20; 7:20; 8:20
    Perform 4G Cell block 2,3,4,5,6,7,8,9,10,11,12 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6,7,8,9,10,11,12 via AdminCLI
    Check bbPool Cell Mapping TC1735

TC25_CB008609_SR_B_US02_Automatic_allocation_of_cells_to_pools_IQ_farward_from_LokiB_to_LokiA_ecpri_branch
    [Tags]    CB008609    TC25    QL3    Branch    QC_538339
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC25}
    Perform 4G Cell block 2,3,4,5,6 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6 via AdminCLI
    Check bbPool Cell Mapping TC252634

TC26_CB008609_SR_B_US06_Manual_allocation_of_cells_to_pools_ecpri_branch
    [Tags]    CB008609    TC26    QL3    Branch    QC_538338
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC26}
    Perform 4G Cell block 2,3,4,5,6 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6 via AdminCLI
    Check bbPool Cell Mapping TC252634

TC34_CB008609_SR_B_US05_Automatic_allocation_of_cells_to_pools_using_L1_balanced_mode_and_logical_group_identifier_cell_block_unblock_ecpri_branch
    [Tags]    CB008609    TC34    QL3    Branch    QC_538337
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC25}
    Perform 4G Cell block 1,3,4 via AdminCLI
    sleep    20s
    Perform 4G Cell unblock 4,3,1 via AdminCLI
    Check bbPool Cell Mapping TC252634
    Perform 4G Cell block 2,3,4,5,6 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6 via AdminCLI

TC35_CB008609_SR_B_US02_Automatic_allocation_of_cells_to_pools_IQ_farward_from_LokiB_to_LokiA_IQ_data_collection_ecpri_branch
    [Tags]    CB008609    TC35    QL3    Branch    QC_538336
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008609${/}${scfc_file_TC35}
    Perform 4G Cell block 2,3,4,5,6,7,8,9,10,11,12 via AdminCLI
    SMAwave L3 call    1    110M    9M    50%    4G    41
    Perform 4G Cell unblock 2,3,4,5,6,7,8,9,10,11,12 via AdminCLI
    Check bbPool Cell Mapping TC1735

*** Keywords ***
Check bbPool Cell Mapping TC1735
    ${expect_lokiB_cell_list}    Create List    1    2    3    10    11    12
    ${expect_lokiA_cell_list}    Create List    4    5    6    7    8    9
    Run Keyword If    'Trunk' in ${TEST TAGS}    Check bbPool Cell Mapping    BBPOOL-11    ${expect_lokiA_cell_list}    Loki-A
    ...    ELSE    Check bbPool Cell Mapping    BBPOOL-11    ${expect_lokiA_cell_list}    Loki-A
    Run Keyword If    'Trunk' in ${TEST TAGS}    Check bbPool Cell Mapping    BBPOOL-12    ${expect_lokiB_cell_list}    Loki-B
    ...    ELSE    Check bbPool Cell Mapping    BBPOOL-12    ${expect_lokiB_cell_list}    Loki-B

Check bbPool Cell Mapping TC252634
    ${expect_lokiB_cell_list}    Create List    1    2    3
    ${expect_lokiA_cell_list}    Create List    4    5    6
    Run Keyword If    'Trunk' in ${TEST TAGS}    Check bbPool Cell Mapping    BBPOOL-11    ${expect_lokiA_cell_list}    Loki-A
    ...    ELSE    Check bbPool Cell Mapping    BBPOOL-11    ${expect_lokiA_cell_list}    Loki-A
    Run Keyword If    'Trunk' in ${TEST TAGS}    Check bbPool Cell Mapping    BBPOOL-12    ${expect_lokiB_cell_list}    Loki-B
    ...    ELSE    Check bbPool Cell Mapping    BBPOOL-12    ${expect_lokiB_cell_list}    Loki-B
