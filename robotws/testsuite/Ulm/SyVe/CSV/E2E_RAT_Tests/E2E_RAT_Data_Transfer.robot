*** Settings ***
Documentation
...    | [5G24R3]      | Data_Volumes_and_Throughput   |
...    | Test case:    | Simple Data Tranfer                                                 |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                 |
...    | Author:       | Michele                                                             |
...    | Team:         | Ulm SQD64                                                           |
...    | Contact:      | I_PZ_ULM_SQD_64@internal.nsn.com                                    |
...    | Description:  | Keywords for E2E DT                                                 |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.ue
Library    ute_tshark
Library    String
Library    Collections

Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../../resources/Common/git_handling.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/snapshot.robot
Resource    ../../../resources/Common/gnb.robot

Resource    ../../resources/syve_testline.robot
Resource    ../../resources/UEs_handler.robot
Resource    ../../resources/scf_info.robot

Resource    ../resources/commonKeywords.robot
Resource    ../resources/BTS_Cells_Handler.robot

Variables   qc_mapping.yaml

Suite Setup     Prepare TL For Data Transfer Testing
Suite Teardown  Save All Logs And Teardown TL For Data Transfer Testing


*** Variables ***
${RP_CA}                  VRF_RRM
${RP_ORGANIZATION}        VRF_ULM_T03
${RP_LOCATION}            VRF_ULM
${QC_DOMAIN}              MN_RAN
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL


*** Test Cases ***
E2E_5G_SA_Data_Transfer_TDD
    [Documentation]
    ...  | TCP Data Transfer Testing  on NR TDD cell   |
    ...  | This test case is aimed at verifying TCP Tput at NR TDD cell |
    ...  | counters check shall be added            |
    [Tags]     E2E_5G_SA_Data_Transfer_TDD       CSV_ULM_TPUT
    [Setup]    commonKeywords.Setup Test Scenario For Data Transfer Testing
    Log To Console    ${\n}Data Transfer Testing on NR TDD cell

    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    commonKeywords.E2E Data Transfer    technology_in_use=TDD

    Log To Console    ${\n}Stop Data Transfers For All Ues.
    taf.ue.Stop Data Transfers For All Ues

    Log To Console    ${\n}The End...
    [Teardown]    commonKeywords.Test Scenario Teardown With Reporting


E2E_5G_SA_Data_Transfer_FDD
    [Documentation]
    ...  | TCP Data Transfer Testing  on NR FDD cell   |
    ...  | This test case is aimed at verifying TCP Tput at NR FDD cell |
    ...  | counters check shall be added            |
    [Tags]     E2E_5G_SA_Data_Transfer_FDD        CSV_ULM_TPUT
    [Setup]    commonKeywords.Setup Test Scenario For Data Transfer Testing
    Log To Console    ${\n}Data Transfer Testing on NR FDD cell

    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    commonKeywords.E2E Data Transfer    technology_in_use=FDD

    Log To Console    ${\n}Stop Data Transfers For All Ues.
    taf.ue.Stop Data Transfers For All UEs

    Log To Console    ${\n}The End...
    [Teardown]    commonKeywords.Test Scenario Teardown With Reporting


E2E_LTE_Data_Transfer_FDD
    [Documentation]
    ...  | TCP Data Transfer Testing  on LTE FDD cell   |
    ...  | This test case is aimed at verifying TCP Tput at LTE FDD cell |
    ...  | counters check shall be added            |
    [Tags]     E2E_LTE_Data_Transfer_FDD        CSV_ULM_TPUT
    [Setup]    commonKeywords.Setup Test Scenario For Data Transfer Testing
    Log To Console    ${\n}Data Transfer Testing on LTE FDD cell

    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    commonKeywords.E2E Data Transfer    technology_in_use=FDD    RAT_in_use=lte

    Log To Console    ${\n}Stop Data Transfers For All Ues.
    taf.ue.Stop Data Transfers For All UEs

    Log To Console    ${\n}The End...
    [Teardown]    commonKeywords.Test Scenario Teardown With Reporting


E2E_NSA_Data_Transfer_FDD
    [Documentation]
    ...  | TCP Data Transfer Testing  on LTE FDD cell then also a 5G cell is available under the same RMOD. This will start in NSA.  |
    ...  | This test case is aimed at verifying TCP Tput at LTE FDD cell plus a 5G cell (NSA).  |
    ...  | counters check shall be added            |
    [Tags]     E2E_NSA_Data_Transfer_FDD        CSV_ULM_TPUT
    [Setup]    commonKeywords.Setup Test Scenario For Data Transfer Testing
    Log To Console    ${\n}Data Transfer Testing NSA. LTE FDD cell Plus the 5G cell in the same RMOD. (NSA)

# ToDo: Once the new test is available in Quality Center, adjust the testsuite/Ulm/SyVe/CSV/E2E_RAT_Tests/qc_mapping.yaml.
    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    commonKeywords.E2E Data Transfer    technology_in_use=FDD    RAT_in_use=lte    deployment=NSA

    Log To Console    ${\n}Stop Data Transfers For All Ues.
    taf.ue.Stop Data Transfers For All UEs

    Log To Console    ${\n}The End...
    [Teardown]    commonKeywords.Test Scenario Teardown With Reporting


*** Keywords ***
Prepare TL for Data Transfer Testing
    Log To Console    Running Test Suite Setup keyword 'Prepare TL for Data Transfer Testing' ...
    testline.Set Console Output
    testline.Create Test Suite Log Folders
    ${ts_log_dir}=    testline.Get Test Suite Log Directory
    Set Suite Variable    ${ts_log_dir}
    builtin.Log To Console   The logs of this test run will be available at: ${P_resultSuiteBaseDir}

    Log To Console    ${\n}Wait that gNBs are Onair...
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=gnb    node_id=${0}    timeout=30s
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=enb    node_id=${0}    timeout=30s

    commonKeywords.Get CSV TL customer mapping from TL name and set it as Suite Variable CUSTOMERS_LIST
    commonKeywords.Get CURRENT_SW_BRANCH And Set It As Suite Variable
    commonKeywords.Identify the list of unique SMODs and associated primary SBTS nodes of the testline   log_to_console=${True}
    ${gnb_sw_version}=   commonKeywords.Get The SW Version Of SBTS Node And Set It To Suite Variable P_GNBSWVERSION   node_type=gnb    node_id=${0}
    Log to console    ${\n}INFO: GNB SW Version is: ${gnb_sw_version}
    ${current_oru_fw_version}=    commonKeywords.Get Running ORAN RU FW version if applicable

    testline.Check TL Infos
    syve_testline.Save current loads

    IF    ('syslog' in ${ENABLED_LOGS})    Start syslog collection for CCRTS

    git_handling.Save Current Workspace Info
    ${capacityUnitType}=     testline.Get Capacity Unit Type    gnb_id=${0}
    Set Suite Variable    ${capacityUnitType}
    Log To Console    ${\n}Identified Capacity Unit Type: ${capacityUnitType}

    scf_info.Collect and Validate the Current SCF file
    scf_info.Store original config files

    IF   'FSMF' in ${{ [ value['hardware_type'] for key, value in $PRIMARY_TL_NODES_DICT.items() ] }}
    ...   builtin.Import Variables   ${CURDIR}/../E2E_RAT_Tests/qc_mapping_fsm3.yaml
    Log Variables
    Log To Console    Running Test Suite Setup keyword 'Prepare TL for Data Transfer Testing' completed!


Save All Logs And Teardown TL For Data Transfer Testing
    Log To Console    Running Test Suite Teardown keyword 'Save all Logs and Teardown TL for Data Transfer Testing' ...
    Sleep    3sec
    Log To Console    ${\n}Suite Teardown...
    Log To Console    ${\n}Stored files under: ${\n}${ts_log_dir}

    taf.ue.Stop Data Transfers For All Ues

    IF    ('syslog' in ${ENABLED_LOGS})    Stop syslog collection for CCRTS

    IF    ('snapshot' in ${ENABLED_LOGS})
        Log To Console    ${\n}Snapshot files under: ${\n}${ts_log_dir}
        snapshot.Get snapshot for node     node_type=gNB    node_id=${0}    target_dir=${ts_log_dir}
    END

    admin.Teardown All Aliases For Admin
    Log To Console    Running Test Suite Teardown keyword 'Save all Logs and Teardown TL for Data Transfer Testing' completed!
