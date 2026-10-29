*** Settings ***
Documentation
...    | [5G24R3]      | PING   |
...    | Test case:    | Simple PING                                                     |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                    |
...    | Author:       | Michele                                                                |
...    | Team:         | Ulm SQD64                                                              |
...    | Contact:      | I_PZ_ULM_SQD_64@internal.nsn.com                                       |
...    | Description:  | Keywords for E2E DT                                                  |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.ue
Library    ute_tshark
Library    String
Library    Collections

Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../../resources/Common/git_handling.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/snapshot.robot
Resource    ../../../resources/Common/tcpdump.robot
Resource    ../../../resources/Common/gnb.robot

Resource    ../../resources/syve_testline.robot
Resource    ../../resources/attenuator.robot
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
${QC_DOMAIN}              MN_RAN
${RP_LOCATION}            VRF_ULM
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL
&{RTT_KPI}                name=rtt
...                       visible_to_db=Yes
...                       category=Customer


*** Test Cases ***
E2E_5G_ping_RTT_TDD
    [Documentation]
    ...  | PING Testing  on NR TDD cell   |
    ...  | This test case is aimed at verifying ping RTT at NR TDD cell |
    ...  | counters check shall be added            |
    [Tags]    E2E_5G_ping_RTT_TDD     CSV_ULM_PING
    [Setup]    commonKeywords.Setup Test Scenario For Data Transfer Testing
    Log To Console    ${\n}PING Testing on NR TDD cell.

    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}
    Log To Console      TL is ${bts_distName}

    E2E Ping RTT    technology_in_use=TDD

    [Teardown]    Run Keywords
    ...    Log To Console    ${\n}The End.
    ...    AND    commonKeywords.Test Scenario Teardown With Reporting


E2E_5G_ping_RTT_FDD
    [Documentation]
    ...  | PING Testing  on NR FDD cell   |
    ...  | This test case is aimed at verifying ping RTT at NR FDD cell |
    ...  | counters check shall be added            |
    [Tags]    E2E_5G_ping_RTT_FDD     CSV_ULM_PING
    [Setup]    commonKeywords.Setup Test Scenario For Data Transfer Testing
    Log To Console    ${\n}PING Testing on NR FDD cell.

    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}
    Log To Console      TL is ${bts_distName}

    E2E Ping RTT    technology_in_use=FDD

    [Teardown]    Run Keywords
    ...    Log To Console    ${\n}The End.
    ...    AND    commonKeywords.Test Scenario Teardown With Reporting


E2E_LTE_ping_RTT_FDD
    [Documentation]
    ...  | PING Testing  on LTE FDD cell   |
    ...  | This test case is aimed at verifying ping RTT at LTE FDD cell |
    ...  | counters check shall be added            |
    [Tags]    E2E_LTE_ping_RTT_FDD     CSV_ULM_PING
    [Setup]    commonKeywords.Setup Test Scenario for Data Transfer Testing
    Log To Console    ${\n}PING Testing on LTE FDD cell

    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}
    Log To Console      TL is ${bts_distName}

    E2E Ping RTT    technology_in_use=FDD    RAT_in_use=lte

    [Teardown]    Run Keywords
    ...    Log To Console    ${\n}The End.
    ...    AND    commonKeywords.Test Scenario Teardown With Reporting


*** Keywords ***
E2E Ping RTT
    [Documentation]
    ...  | PING Testing     |
    ...  | This test case is aimed at verifying the counters that are introduced as part of PING  |
    ...  | to monitor degradations.            |
    [Arguments]    ${technology_in_use}=TDD    ${RAT_in_use}=nr    ${deployment}=SA
    Log To Console    ${\n}PING RTT Testing...

    Log To Console    ${\n}Radio Access Technology (RAT) to use is: ${RAT_in_use}
    Log To Console    ${\n}Technology to use is: ${technology_in_use}
    IF  "${deployment}"=="NSA"    Log To Console    ${\n}Deployment Architecture is: ${deployment}

    IF  "${RAT_in_use}"=="nr"
        Set Test Variable    ${node_type}    gnb
    ELSE IF    "${RAT_in_use}"=="lte"
        Set Test Variable    ${node_type}    enb
    END

    # ToDo: Select it automatically! Used Also in E2E_5G_SA_Data_Transfer
    ${NRRU}=    BTS_Cells_Handler.Set Active NRRU As Variable Based On Technology In Use    technology_in_use=${technology_in_use}

    Log To Console    ${\n}Lock Cells of same RMOD to avoid RF interference.
    IF  "${RAT_in_use}"=="nr" and "${technology_in_use}"=="FDD"
        @{lte_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=lte
        @{gsm_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=gsm
        @{nr_cells_to_block}=    Create List
        # Combine all cells to block/unblock into a single list for teardown
        @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}    Create List    @{lte_cells_to_block}    @{gsm_cells_to_block}  # Used in teardown to unblock the cells.
        Set Test Variable    @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}  # Make available for teardown.
    ELSE IF    "${RAT_in_use}"=="nr" and "${technology_in_use}"=="TDD"
        @{lte_cells_to_block}    Create List  # if no cells shall be blocked, @{CELLS_TO_UNBLOCK_FOR_TEARDOWN} must be defined as empty list
        @{gsm_cells_to_block}    Create List
        @{nr_cells_to_block}=    Create List
        @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}    Create List  @{lte_cells_to_block}  @{gsm_cells_to_block}  @{nr_cells_to_block}
        Set Test Variable    @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}  # Make available for teardown.
    ELSE IF    "${RAT_in_use}"=="lte"
        @{lte_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=lte
        # Remove the first element (at index 0); This is a LTE call we do not need to Block the first LTE Cell.
        Remove From List    ${lte_cells_to_block}    ${0}    # ToDo: Use [Arguments] ${cell_index} to attach to the Second cell.
        @{gsm_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=gsm
        @{nr_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=nr
        # Combine all cells to block/unblock into a single list for teardown
        @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}    Create List  @{lte_cells_to_block}  @{gsm_cells_to_block}  @{nr_cells_to_block}
        Set Test Variable    @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}  # Make available for teardown.
    END

    Log To Console    ${\n}Lock LTE Cells...
    BTS_Cells_Handler.Guarded Block Cells    cells_to_block=@{lte_cells_to_block}    RAT_to_Block=lte
    Log To Console    ${\n}Lock GSM Cells...
    BTS_Cells_Handler.Guarded Block Cells    cells_to_block=@{gsm_cells_to_block}    RAT_to_Block=gsm
    Log To Console    ${\n}Lock NR Cells...
    BTS_Cells_Handler.Guarded Block Cells    cells_to_block=@{nr_cells_to_block}    RAT_to_Block=nr

    Log To Console    ${\n}Open attenuation for serving cell...
    attenuator.Set gNB all ports attenuation    value_in_db=${0}    ru_id=${NRRU}

    ${FirstUE}    UEs_handler.Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${1}
    Set Test Variable    ${FirstUE}

    Log To Console    ${\n}PING From UE to the Application Server.
    taf.ue.Stop Data Transfer    DL_Background_${FirstUE}
    UEs_handler.Start PING    ue_alias=${FirstUE}

    Await data transfer finish    ul_PING_${FirstUE}
    ${PING_Statistics}    Get Data Transfer Statistics    ul_PING_${FirstUE}
    Log To Console    ${\n}PING Statistics: ${\n}${PING_Statistics}

    ${device_model}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['device_model']}    ${EMPTY}
    ${imei}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['imei']}    ${EMPTY}
    ${description}    Set Variable IF    '${device_model}'!='${EMPTY}'    \[${device_model},${imei}\]    ${EMPTY}

    ${packet_loss}    Copy Dictionary    ${RTT_KPI}
    Set To Dictionary    ${packet_loss}    target=${PING_Statistics['packet_loss']}
    ...                                    value=${PING_Statistics['packet_loss']}
    ...                                    type=int
    ...                                    description=${description}
    ...                                    name=rtt_Packet_Loss
    ...                                    unit=packets

    ${rtt_min}    Copy Dictionary    ${RTT_KPI}
    Set To Dictionary    ${rtt_min}    target=${PING_Statistics['rtt_min']}
    ...                                value=${PING_Statistics['rtt_min']}
    ...                                type=float
    ...                                description=${description}
    ...                                name=rtt_Min
    ...                                unit=milliseconds

    ${rtt_max}    Copy Dictionary    ${RTT_KPI}
    Set To Dictionary    ${rtt_max}    target=${PING_Statistics['rtt_max']}
    ...                                value=${PING_Statistics['rtt_max']}
    ...                                type=float
    ...                                description=${description}
    ...                                name=rtt_Max
    ...                                unit=milliseconds

    ${rtt_avg}    Copy Dictionary    ${RTT_KPI}
    Set To Dictionary    ${rtt_avg}    target=${PING_Statistics['rtt_avg']}
    ...                                value=${PING_Statistics['rtt_avg']}
    ...                                type=float
    ...                                description=${description}
    ...                                name=rtt_Avg
    ...                                unit=milliseconds

    ${KPI_RESULTS}    Create List    ${packet_loss}
    ...                              ${rtt_min}
    ...                              ${rtt_max}
    ...                              ${rtt_avg}
    Set Suite Variable    ${KPI_RESULTS}

    taf.ue.Stop Data Transfer    DL_Background_${FirstUE}


Prepare TL For Data Transfer Testing
    Log To Console    Running Test Suite Setup keyword 'Prepare TL for Data Transfer Testing' ...
    testline.Set Console Output
    testline.Create Test Suite Log Folders
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

    Collect and Validate the Current SCF file
    Store original config files

    IF   'FSMF' in ${{ [ value['hardware_type'] for key, value in $PRIMARY_TL_NODES_DICT.items() ] }}
    ...   builtin.Import Variables   ${CURDIR}/../E2E_RAT_Tests/qc_mapping_fsm3.yaml
    Log Variables
    Log To Console    Running Test Suite Setup keyword 'Prepare TL for Data Transfer Testing' completed!


Save all Logs and Teardown TL for Data Transfer Testing
    Log To Console    Running Test Suite Teardown keyword 'Save all Logs and Teardown TL for Data Transfer Testing' ...
    Sleep    3sec
    ${target_dir}=    testline.Get test suite log directory
    Log To Console    ${\n}Stored files under: ${\n}${target_dir}

    taf.ue.Stop Data Transfers For All Ues

    IF    ('syslog' in ${ENABLED_LOGS})    Stop syslog collection for CCRTS

    IF    ('snapshot' in ${ENABLED_LOGS})
        Log To Console    ${\n}Snapshot files under: ${\n}${target_dir}
        snapshot.Get snapshot for node     node_type=gNB    node_id=${0}    target_dir=${target_dir}
    END

    admin.Teardown All Aliases For Admin
    Log To Console    Running Test Suite Setup Teardown 'Save all Logs and Teardown TL for Data Transfer Testing' completed!


Collect and Validate the Current SCF file
    [Documentation]
    ...  |  Get The Current SCF file of ${node_type}${node_id} and Validate it online.  |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    Log To Console    ${\n}Collect current SCF file.
    ${resultSuiteBaseDir}=    testline.Get test suite result base directory
    ${oam_alias}    connect.Setup OAM http session    node_id=${node_id}    node_type=${node_type}
    ${current_SCF_Location}    admin.get current scf file
    ...    local_dir_path=${resultSuiteBaseDir}
    ...    file_name=RunningSCF.xml
    ...    timeout=30
    ...    connection=${oam_alias}
    Log To Console    ${\n}Validate current SCF file.
    admin.validate_scf_online    scf_file=${current_SCF_Location}    detailed_output=True  connection=${oam_alias}


Store original config files
    [Documentation]
    ...  |  Store the Start SCFC and swconfig.txt files.  |
    ${gNB#1_Original_SCF_Path}=  Store Current SCF from gNB
    Set Suite Variable    ${gNB#1_Original_SCF_Path}
    Log To Console    ${\n}Path to gNB#1 Original SCF: ${\n}${gNB#1_Original_SCF_Path}
    ${gNB#1_Original_swconfig_Path}=  Store Current swconfig from gNB    gnb_id=${0}
    Set Suite Variable    ${gNB#1_Original_swconfig_Path}
    Log To Console    ${\n}Path to gNB#1 Original swconfig.txt: ${\n}${gNB#1_Original_swconfig_Path}
