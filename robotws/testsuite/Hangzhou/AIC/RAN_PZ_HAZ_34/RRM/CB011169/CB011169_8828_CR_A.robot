*** Settings ***
Documentation
...   author: di.yang@nokia-sbell.com
...   This case can cover case 3 in QC
Resource          resource/common_keyword.robot

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

Test Setup   Case Setup
Test Teardown   Case Teardown

*** Variables ***
${GNB_INDEX}       ${0}
${if_commissioning}                 False
${sa_ue_index}        0
${VDU_INDEX}       ${0}
${VDU_2_INDEX}       ${1}

*** Test Cases ***
CB011169_CR_A_003_Intra-GNB_inter-DU_inter-frequency_handover_success_per_PMQAP_CB008828_Enabled
    Wait for New Interval BTS counters Generate    interval=5min
    Run Keyword And Continue On Failure   _Get CU Pcell Update Counters
    _Get DU Update Counters

*** Keywords ***
Common Suite Setup
    Cloud Suite Setup
    Log To Console    Suite Setup...
    Get ALL Suite Variables on VCU

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    Log To Console    TearDown...

Case Setup
#    robot_common_operations.Common Case Setup
    Trigger SA Intra-gNB Inter-DU HO

Case Teardown
    Run Keyword And Ignore Error    Simple Ue Stop DL UL Traffic    ue_index_list=${ue_index_list}
    Run Keyword And Ignore Error    Simple Ue Detach    ue_index_list=${ue_index_list}
    robot_common_operations.Common Case Teardown

Trigger SA Intra-gNB Inter-DU HO
    Initialise Attenuator
    attenuator_keywords.Set Attenuation   0dB   confirm=${TRUE}  port=${ATTENUATOR_CELLS[0]['ports']}
    attenuator_keywords.Set Attenuation   70dB  confirm=${TRUE}  port=${ATTENUATOR_CELLS[1]['ports']}
    ${cell_list}    Cloud Get Cells Id List
    ${ue_index_list}    create list
    Append To List    ${ue_index_list}    ${sa_ue_index}
    set suite variable    ${ue_index_list}
    Wait for New Interval BTS counters Generate    interval=5min
    UE attach with ULDL traffic
    Perform Handover  initial_port=${ATTENUATOR_CELLS[0]['ports']}
    ...               target_port=${ATTENUATOR_CELLS[1]['ports']}
    ...               open_value=0
    ...               closed_value=40
    ...               period=60
    ...               interval=4
    Sleep    5s

_Get CU Pcell Update Counters
    ${temp_object}   Set Variable  ${CU_PCELL_DN}/NRPMQAP-1
    ${temp_object_2}   Set Variable  ${LOCAL_INSID}/MCC-262/MNC-03/SST-1/SD-13714341
    ${temp_object_3}   Set Variable  ${CU_PCELL_DN_2NDCELL}/NRPMQAP-1
    ${M55184C00019}    create dictionary       counter_id=M55184C00019    dimension_dist_name=${temp_object}
    ...   expect_value=${1}
    ${M55184C00020}    create dictionary       counter_id=M55184C00020    dimension_dist_name=${temp_object}
    ...   expect_value=${1}
    ${M55184C00017}    create dictionary       counter_id=M55184C00017    dimension_dist_name=${temp_object}
    ...   expect_value=${0}
    ${M55184C00018}    create dictionary       counter_id=M55184C00018    dimension_dist_name=${temp_object}
    ...   expect_value=${0}

    ${M55161C00002}    create dictionary       counter_id=M55161C00002    dimension_dist_name=${temp_object}
    ...   expect_value=${500}
    ${M55163C00021}    create dictionary       counter_id=M55163C00021    dimension_dist_name=${temp_object}
    ...   expect_value=${0}
    ${M55161C00001}    create dictionary       counter_id=M55161C00001    dimension_dist_name=${temp_object}
    ...   expect_value=${0}
    ${M55161C00003}    create dictionary       counter_id=M55161C00003    dimension_dist_name=${temp_object}
    ...   expect_value=${0}
    ${M55161C00008}    create dictionary       counter_id=M55161C00008    dimension_dist_name=${temp_object}
    ...   expect_value=${0}
    ${M55161C00009}    create dictionary       counter_id=M55161C00009    dimension_dist_name=${temp_object}
    ...   expect_value=${0}
    ${M55161C00010}    create dictionary       counter_id=M55161C00010    dimension_dist_name=${temp_object_3}
    ...   expect_value=${0}
    ${M55161C00011}    create dictionary       counter_id=M55161C00011    dimension_dist_name=${temp_object_3}
    ...   expect_value=${0}

    @{list_counters}   create list     ${M55184C00019}    ${M55184C00020}  ${M55184C00017}  ${M55184C00018}
    @{list_counters_2}   create list     ${M55163C00021}    ${M55161C00001}    ${M55161C00003}    ${M55161C00008}
    ...    ${M55161C00009}    ${M55161C00010}    ${M55161C00011}    ${M55161C00002}
    Wait Until Keyword Succeeds  3x  30s  Compare Counters to Expect Value    gnb_index=${GNB_INDEX}
    ...    list_counters=${list_counters}   bts_type=cu
    Wait Until Keyword Succeeds  3x  30s  Compare Counters to Expect Value    gnb_index=${GNB_INDEX}
    ...    list_counters=${list_counters_2}   bts_type=cu   verify=bigger

_Get DU Update Counters
    ${temp_object}   Set Variable  ${DU_PCELL_DN}/NRPMQAP-1
    ${temp_object_2}   Set Variable  ${DU_2_CELL_DN}/NRPMQAP-1
    ${M55193C00001}    create dictionary       counter_id=M55193C00001
    ...      dimension_dn=${temp_object}   expect_value=${0}
    ${M55193C00002}    create dictionary       counter_id=M55193C00002
    ...      dimension_dn=${temp_object}   expect_value=${0}
    ${M55193C00003}    create dictionary       counter_id=M55193C00003
    ...      dimension_dn=${temp_object_2}   expect_value=${0}
    ${M55193C00004}    create dictionary       counter_id=M55193C00004
    ...      dimension_dn=${temp_object_2}   expect_value=${0}

    @{DU_1_list_counters}   create list     ${M55193C00001}    ${M55193C00002}
    @{DU_2_list_counters}   create list     ${M55193C00003}    ${M55193C00004}

    Wait Until Keyword Succeeds  3x  30s  Compare Counters to Expect Value   gnb_index=${GNB_INDEX}
    ...    vdu_index=${VDU_INDEX}    list_counters=${DU_1_list_counters}   bts_type=du   verify=bigger
    Wait Until Keyword Succeeds  3x  30s  Compare Counters to Expect Value   gnb_index=${GNB_INDEX}
    ...    vdu_index=${VDU_2_INDEX}    list_counters=${DU_2_list_counters}   bts_type=du   verify=bigger

