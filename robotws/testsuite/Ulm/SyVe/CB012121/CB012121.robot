*** Settings ***
Documentation   This is a Robot Test Suite for feature: CB012121
...             CB012121-SR-A_Sub-feature_for_strategy_based_on_cell_reported_quality
...             Team: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.sbts.oam.coam.admin           WITH NAME   admin
Library    taf.ue

Library    ute_tshark

Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/pmcounters.robot

Resource   ../resources/attenuator_scenario.robot
Resource   ../resources/syve_testline.robot
Resource   ../resources/attenuator.robot
Resource   ../resources/scf_info.robot
Resource   ../resources/sqd63/common_keywords.robot
Resource    CB012121_commissioning.robot
Resource    CB012121_revert.robot
Resource    CB012121_verification.robot
Resource    CB012121_keywords.robot


Suite Setup     Prepare TL For Testing
Suite Teardown  common_keywords.Save All Logs And Teardown TL


*** Variables ***
${UE_ALIAS_1}            MTK
${WITH_PMCOUNTER_CHECK}  true
@{ALL_CELLS_GNB0}        1  2  3  4  5  6  7  8  9  10  11  12  13
@{ALL_CELLS_GNB1}        1  2  3  4
@{GNB0_CELLS_NOT_BLOCK_TL126_A11}        1  2  3  4  6  7  8  9  10  11  12  13
@{GNB1_CELLS_NOT_BLOCK_TL126_B01}        1  2  4
@{LOGS}                  testSuiteConfigs
@{TL_LIST}               7_15_UTE5GTL126   7_15_UTE5GTL387


*** Test Cases ***
CB012121_A_ST_TC05_BestCell_TimerExpiryNoCell_NoTimerRestart
    [Documentation]    In the scope of this test, the user scenario “CB012121-A#B5: Triggering handover preparation
    ...    with MR report received after best-cell-wait-timer expiry.” This user scenario is to verify gNB’s behaviour
    ...    when gNB receives an RRC: MeasurementReport message (MR) for Inter-Freq A3/A5 event or Inter-RAT B2 event from
    ...    the 5G-UE after best-cell-wait-timer expiry.

    [Tags]    CB012121_A_05  CB012121_A_05_TMO  CB012121_A  CB012121  Handover
    [Setup]    Perform Preconditions Of Test Scenario
    hanging_resources.Get Resources Before Test For All Nodes
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    taf.ue.Detach UE   ${UE_ALIAS_1}
    log to console  Start Test Part I
    CB012121_keywords.Start Tracing
    taf.ue.Attach UE   ${UE_ALIAS_1}
    ${dl_dt_name}    ${ul_dt_name}=    Start UL And DL Traffic    transfer=${1}
    sleep  5s
    IF    '${TL_NAME}' in ${TL_LIST}
        CB012121_keywords. Set GNB Cell Attenuation With File Per Cell
        ...     scenario=SEN_CB012121_A_05_TMO  att_file_path=${CURDIR}/attenuator_scenario_CB012121.txt
    ELSE
        CB012121_keywords.Set GNB Cell Attenuation With File Per Cell
        ...     scenario=SEN_CB012121_A_05  att_file_path=${CURDIR}/attenuator_scenario_CB012121.txt
    END
    CB012121_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    sleep  10s  reason=wait for UEContextRelease
    CB012121_keywords.Stop Tracing and Save As    tcp_file=UE1_CB012121_A_05_Part1

    log to console  Start Test Part II
    CB012121_keywords.Start Tracing
    ${dl_dt_name}    ${ul_dt_name}=    Start UL and DL Traffic    transfer=${2}
    sleep  5s
    IF    '${TL_NAME}' in ${TL_LIST}
        CB012121_keywords.Set GNB Cell Attenuation With File Per Cell
        ...     scenario=SEN_CB012121_A_05_TMO  att_file_path=${CURDIR}/attenuator_scenario_CB012121.txt
    ELSE
        CB012121_keywords.Set GNB Cell Attenuation With File Per Cell
        ...     scenario=SEN_CB012121_A_05  att_file_path=${CURDIR}/attenuator_scenario_CB012121.txt
    END
    CB012121_keywords.Stop DL And UL Traffic And Check Throughput    dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    sleep  10s  reason=wait for UEContextRelease
    CB012121_keywords.Stop Tracing And Save As    tcp_file=UE1_CB012121_A_05_Part2
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part1}=   CB012121_keywords.Fetch and Rename PM Counter Dirs  gnb_id=${0}  PM_Part=${1}
        Set Suite Variable    ${PMCounters_dir_Part1}
    END
    taf.ue.Detach UE   ${UE_ALIAS_1}
    sleep  20s  reason=wait release of resources
    Verify Qc Test Case
    hanging_resources.Get Resources After Test For All Nodes

    [Teardown]    Specific TC Teardown


CB012121_A_ST_TC11_BestCell_ANR_launchedBeforeHo
    [Documentation]    In the scope of this test, the user scenario “CB012121-A#B14: ANR triggered when an unknown PCI is received”.
    ...                This user scenario is to verify gNB’s behavior when Inter-Freq A3/A5 or Inter-RAT B2 RRC:
    ...                MeasurementReport message (MR) is received and ANR will be triggered for the unknown PCI having the best RSRP.
    [Tags]    CB012121_A_11  CB012121_A  CB012121
    [Setup]    Perform Preconditions Of Test Scenario
    hanging_resources.Get Resources Before Test For All Nodes
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_1}
    IF    '${TL_NAME}' in ${TL_LIST}
        common_keywords.Block UnBlock All Cells Except Needed    all_cells=@{ALL_CELLS_GNB0}  needed_cells=@{GNB0_CELLS_NOT_BLOCK_TL126_A11}
        ...    node_type=gnb  cell_op=block  node_id=${0}
    END
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF    '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    log to console  Start Test
    CB012121_keywords.Start Tracing
    taf.ue.Attach UE   ${UE_ALIAS_1}
    ${dl_dt_name}    ${ul_dt_name}=    Start UL And DL Traffic    transfer=${1}
    sleep  5s
    CB012121_keywords.Set GNB Cell Attenuation With File Per Cell
    ...     scenario=SEN_CB012121_A_11  att_file_path=${CURDIR}/attenuator_scenario_CB012121.txt
    CB012121_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    sleep  30s  reason=wait for UEContextRelease
    CB012121_keywords.Stop Tracing And Save As    tcp_file=UE1_CB012121_A_11
    taf.ue.Detach UE   ${UE_ALIAS_1}
    sleep  20s  reason=wait release of resources
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part1}=  CB012121_keywords.Fetch and Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${1}
        Set Suite Variable    ${PMCounters_dir_Part1}
    END
    IF    '${TL_NAME}' in ${TL_LIST}
        common_keywords.Block UnBlock All Cells Except Needed    all_cells=@{ALL_CELLS_GNB0}  needed_cells=@{GNB0_CELLS_NOT_BLOCK_TL126_A11}
        ...    node_type=gnb  cell_op=unblock  node_id=${0}
    END
    Verify qc test case
    hanging_resources.Get Resources After Test For All Nodes

    [Teardown]    Specific TC Teardown


CB012121_B_ST_TC01_Priority_PmCounter
    [Documentation]    In the scope of this test, the user scenario “CB012121-A#B14: ANR triggered when an unknown PCI is received”.
    ...                This user scenario is to verify gNB’s behavior when Inter-Freq A3/A5 or Inter-RAT B2 RRC:
    ...                MeasurementReport message (MR) is received and ANR will be triggered for the unknown PCI having the best RSRP.
    [Tags]    CB012121_B_01  CB012121_B  CB012121  Handover
    [Setup]    Perform Preconditions Of Test Scenario
    hanging_resources.Get Resources Before Test For All Nodes
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_1}
    IF    '${TL_NAME}' in ${TL_LIST}
        common_keywords.Block UnBlock All Cells Except Needed    all_cells=@{ALL_CELLS_GNB1}  needed_cells=@{GNB1_CELLS_NOT_BLOCK_TL126_B01}
        ...    node_type=gnb  cell_op=block  node_id=${1}
    END
    log to console  Start Tracing
    CB012121_keywords.Start Tracing
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    taf.ue.Attach UE   ${UE_ALIAS_1}
    ${dl_dt_name}    ${ul_dt_name}=    Start UL and DL Traffic    transfer=${1}
    sleep  5s
    IF    '${TL_NAME}' in ${TL_LIST}
        CB012121_keywords.Set GNB Cell Attenuation With File Per Cell
        ...     scenario=SEN_CB012121_B_01_TMO  att_file_path=${CURDIR}/attenuator_scenario_CB012121.txt
    ELSE
        CB012121_keywords.Set GNB Cell Attenuation With File Per Cell
        ...     scenario=SEN_CB012121_B_01  att_file_path=${CURDIR}/attenuator_scenario_CB012121.txt
    END
    CB012121_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    sleep  20s  reason=wait for UEContextRelease
    taf.ue.Detach UE   ${UE_ALIAS_1}
    sleep  20s  reason=wait release of resources
    CB012121_keywords.Stop Tracing And Save As    tcp_file=UE1_CB012121_B_01
    log to console  Stop Tracing
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part1}=    CB012121_keywords.Fetch and Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${1}
        Set Suite Variable    ${PMCounters_dir_Part1}
    END
    IF    '${TL_NAME}' in ${TL_LIST}
        common_keywords.Block UnBlock All Cells Except Needed    all_cells=@{ALL_CELLS_GNB1}  needed_cells=@{GNB1_CELLS_NOT_BLOCK_TL126_B01}
        ...    node_type=gnb  cell_op=unblock  node_id=${1}
    END
    Verify QC Test Case
    hanging_resources.Get Resources After Test For All Nodes
    [Teardown]    Specific TC Teardown


CB012121_B_ST_TC11_Priority_ANR_launchedBeforeHo_IntraFreqPci
    [Documentation]    In the scope of this test, the user scenario “CB012121-A#B14: ANR triggered when an unknown PCI is received”.
    ...                This user scenario is to verify gNB’s behavior when Inter-Freq A3/A5 or Inter-RAT B2 RRC:
    ...                MeasurementReport message (MR) is received and ANR will be triggered for the unknown PCI having the best RSRP.
    [Tags]    CB012121_B_11  CB012121_B  CB012121  Handover
    [Setup]    Perform Preconditions Of Test Scenario
    hanging_resources.Get Resources Before Test For All Nodes
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_1}
    IF    '${TL_NAME}' in ${TL_LIST}
        common_keywords.Block UnBlock All Cells Except Needed    all_cells=@{ALL_CELLS_GNB0}  needed_cells=@{GNB0_CELLS_NOT_BLOCK_TL126_A11}
        ...    node_type=gnb  cell_op=block  node_id=${0}
    END
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    CB012121_keywords.Start Tracing
    taf.ue.Attach UE   ${UE_ALIAS_1}
    ${dl_dt_name}    ${ul_dt_name}=    Start UL And DL Traffic    transfer=${1}
    sleep  5s
    CB012121_keywords.Set GNB Cell Attenuation With File Per Cell
    ...     scenario=SEN_CB012121_B_11  att_file_path=${CURDIR}/attenuator_scenario_CB012121.txt
    CB012121_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    sleep  20s  reason=wait for UEContextRelease
    CB012121_keywords.Stop Tracing And Save As    tcp_file=UE1_CB012121_B_11
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part1}=  CB012121_keywords.Fetch and Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${1}
        Set Suite Variable    ${PMCounters_dir_Part1}
    END
    taf.ue.Detach UE   ${UE_ALIAS_1}
    sleep  20s  reason=wait release of resources
    IF    '${TL_NAME}' in ${TL_LIST}
        common_keywords.Block UnBlock All Cells Except Needed    all_cells=@{ALL_CELLS_GNB0}  needed_cells=@{GNB0_CELLS_NOT_BLOCK_TL126_A11}
        ...    node_type=gnb  cell_op=unblock  node_id=${0}
    END
    Verify QC Test Case
    hanging_resources.Get Resources After Test For All Nodes

    [Teardown]    Specific TC Teardown


*** Keywords ***

Perform Preconditions Of Test Scenario
    Create Testcase Log Directory
    Log Variables
    Log To Console    \n
    syve_testline.Testline Setup For CCRT
    ${RESULTTESTDIR}=    testline.Get Testcase Log Directory
    Set Suite Variable  ${RESULTTESTDIR}
    Log To Console    SW Branch: ${GNB_SW_BRANCH}
    Log To Console  TL_NAME: ${TL_NAME}

    IF    '${TL_NAME}' in ${TL_LIST}
        IF    'CB012121_A_05_TMO' in ${TEST TAGS}
            Set GNB Ids  source_node_id=${0}  target_node_id=${1}  source_cell=3  target_cell1=2  target_cell2=4
        ELSE IF    'CB012121_A_11' in ${TEST TAGS}
            Set GNB Ids  source_node_id=${0}  target_node_id=${0}  source_cell=3  target_cell1=4  target_cell2=10
        ELSE IF    'CB012121_B_01' in ${TEST TAGS}
            Set GNB Ids  source_node_id=${0}  target_node_id=${1}  source_cell=3  target_cell1=4  target_cell2=2
        ELSE IF    'CB012121_B_11' in ${TEST TAGS}
            Set GNB Ids  source_node_id=${0}  target_node_id=${1}  source_cell=1  target_cell1=4  target_cell2=1
        END
    ELSE
        IF    'CB012121_A_05' in ${TEST TAGS}
            Set GNB Ids  source_node_id=${0}  target_node_id=${1}  source_cell=3  target_cell1=1  target_cell2=2
        ELSE IF    'CB012121_A_11' in ${TEST TAGS}
            Set GNB Ids  source_node_id=${0}  target_node_id=${0}  source_cell=3  target_cell1=1  target_cell2=2
        ELSE IF    'CB012121_B_01' in ${TEST TAGS}
            Set GNB Ids  source_node_id=${0}  target_node_id=${1}  source_cell=3  target_cell1=2  target_cell2=1
        ELSE IF    'CB012121_B_11' in ${TEST TAGS}
            Set GNB Ids  source_node_id=${0}  target_node_id=${1}  source_cell=1  target_cell1=3  target_cell2=1
        END
    END

    gnb.Wait Until Node To Be Onair State   node_id=${source_node_id}
    Log To Console    Source gNB: ${nrbts_id_${source_node_id}}
    Log To Console    Target gNB: ${nrbts_id_${target_node_id}}
    gnb.Get SCF From gNB    gnb_id=${source_node_id}    target_dir=${configSuiteDir}
    gnb.Get SCF From gNB    gnb_id=${target_node_id}    target_dir=${configSuiteDir}

    ${physCellIdSource}=  scf_info.Get PhysCellId  gnb_id=${source_node_id}  nrcell_id=${source_cell}
    Set Test Variable     ${physCellIdSource}
    IF    'CB012121_B_11' in ${TEST TAGS}
        ${physCellIdTarget1}=  scf_info.Get PhysCellId  gnb_id=${source_node_id}  nrcell_id=${target_cell1}
    ELSE
        ${physCellIdTarget1}=  scf_info.Get PhysCellId  gnb_id=${target_node_id}  nrcell_id=${target_cell1}
    END
    Set Test Variable     ${physCellIdTarget1}
    ${physCellIdTarget2}=  scf_info.Get PhysCellId  gnb_id=${target_node_id}  nrcell_id=${target_cell2}
    Set Test Variable     ${physCellIdTarget2}
    Log To Console    Source physical Cell Id: ${physCellIdSource}
    Log To Console    Target physical Cell Id 1: ${physCellIdTarget1}
    Log To Console    Target physical Cell Id 2: ${physCellIdTarget2}

    CB012121_keywords.Commission Delta GNB_SCF
    IF    '${TL_NAME}' in ${TL_LIST}
        ${enb_alias}=  connect.Setup OAM HTTP Session  node_type=enb  node_id=${0}
        admin.block_all_cells  rat=LTE  timeout=${20}  connection=${enb_alias}
        ${enb_alias}=  connect.Setup OAM HTTP Session  node_type=enb  node_id=${1}
        admin.block_all_cells  rat=LTE  timeout=${20}  connection=${enb_alias}
    END

    Log To Console    \nSet Attenuation to max for all cells
    attenuator.Set Attenuator To Max Value
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_cell}  value=${30}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    ute_tshark.Setup Tshark    eth1  preferences=ntrstr.port:20500,20501,49148,4321 ntrstr.defragment:TRUE


Verify QC Test Case
    log To Console    \nStarting TC Verification and PM Counter validation
    IF    'CB012121_A_05' in ${TEST TAGS}
        CB012121_verification.Verification For CB012121_A_TC05  tcp_files=UE1_CB012121_A_05_Part1,UE1_CB012121_A_05_Part2
        CB012121_keywords.Verify PM Counters CB012121_A_05  PMCounters_dir=${PMCounters_dir_Part1}
    ELSE IF    'CB012121_A_11' in ${TEST TAGS}
        CB012121_verification.Verification For CB012121_A_TC11  tcp_file=UE1_CB012121_A_11
        CB012121_keywords.Verify PM Counters CB012121_A_11  PMCounters_dir=${PMCounters_dir_Part1}
    ELSE IF    'CB012121_B_01' in ${TEST TAGS}
        CB012121_verification.Verification For CB012121_B_TC01  tcp_file=UE1_CB012121_B_01
        CB012121_keywords.Verify PM Counters CB012121_B_01  PMCounters_dir=${PMCounters_dir_Part1}
    ELSE IF    'CB012121_B_11' in ${TEST TAGS}
        CB012121_verification.Verification For CB012121_B_TC11  tcp_file=UE1_CB012121_B_11
        CB012121_keywords.Verify PM Counters CB012121_B_11  PMCounters_dir=${PMCounters_dir_Part1}
    END


Prepare TL For Testing
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    syve_testline.Testline Setup For CCRT
    Set All Suite Variables
    attenuator_scenario.Register All Attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=0
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=1


Set All Suite Variables
    ${CONFIGSUITEDIR}  testline.Get Test Suite Config Directory
    Set Suite Variable  ${CONFIGSUITEDIR}
    ${TL_NAME}  testline.Get Testline Name
    Set Suite Variable  ${TL_NAME}
    ${GNB_SW_BRANCH}  Get GNB SW Branch
    Set Suite Variable  ${GNB_SW_BRANCH}
    ${MRBTS_ID_0}=  scf_info.Get MRBTS-Id  enb_id=${0}
    Set Suite Variable  ${MRBTS_ID_0}
    ${NRBTS_ID_0}=  scf_info.Get NRBTS-Id  gnb_id=${0}
    Set Suite Variable  ${NRBTS_ID_0}
    ${NRBTS_ID_1}=  scf_info.Get NRBTS-Id  gnb_id=${1}
    Set Suite Variable  ${NRBTS_ID_1}


Set GNB Ids
    [Arguments]    ${target_node_id}  ${source_node_id}  ${source_cell}  ${target_cell1}  ${target_cell2}
    [Documentation]     set test variables for target and source ids
    Set Test Variable  ${target_node_id}    ${target_node_id}
    Set Test Variable  ${source_node_id}    ${source_node_id}
    Set Test Variable  ${target_node_type}  gnb
    Set Test Variable  ${source_node_type}  gnb
    Set Test Variable  ${source_cell}        ${source_cell}
    Set Test Variable  ${target_cell1}       ${target_cell1}
    Set Test Variable  ${target_cell2}       ${target_cell2}


Specific TC Teardown
    [Documentation]     Sepcific TC teardown due to IF construction for TMO case
    CB012121_keywords.Revert Commission Delta GNB_SCF
    common_keywords.Combined Test Teardown
    IF    '${TL_NAME}' in ${TL_LIST}
        ${enb_alias}  Setup OAM HTTP Session  node_type=enb  node_id=${0}
        admin.Unblock All Cells  rat=LTE  timeout=${20}  connection=${enb_alias}
        Teardown OAM HTTP Session  node_id=${0}   node_type=enb
        ${enb_alias}  Setup OAM HTTP Session  node_type=enb  node_id=${1}
        admin.Unblock All Cells  rat=LTE  timeout=${20}  connection=${enb_alias}
        Teardown OAM HTTP Session  node_id=${1}   node_type=enb
    END