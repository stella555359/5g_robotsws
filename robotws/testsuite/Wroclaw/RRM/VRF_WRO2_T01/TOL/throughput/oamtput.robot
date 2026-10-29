*** Settings ***
Documentation
...   author: Wiktor Jarosinski
...   contact: wiktor.jarosinski@nokia.com
...   Description:   Robustness tests for TOL with TPUT

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/TOL/throughput/tput_tol_keywords.resource
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.resource
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.py
Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         Collections

Force Tags       CA_VRF_WRO2

Test Setup     Run keywords
...             Set Tester Name                                    AND
...             check_and_update_flag

*** Variables ***
${TL_type}                            SA
${TEST_ITERATION}                     1
${TEST_ITERATION2}                    1
${RP_CA}                              VRF_RRM
${RP_LOCATION}                        VRF_WRO2
${RP_ORGANIZATION}                    VRF_WRO2_T01
@{customers_list}                     General
@{CRITICAL_FAULTS}                    10
@{custom_alarms}                      4681  2002
${rep_comment}                        VRF_WRO2_T01_01
@{CUSTOM_ALARMS_LTE_LOCK}             61631  7509  6351  6134  4011  7513  8150  7511  8000
${tester_name}                        ${None}
${domain}                             MN_RAN
${project}                            RAN_VRF
${q_id}                               ${None}
${INITIAL_SW}                         ${None}
${TARGET_SW}                          ${None}
@{BB_short}                   BBMOD-1    BBMOD-2    BBMOD-3
@{RU_short}                   RMOD-1    RMOD-2    RMOD-3    RMOD-4    RMOD-5    RMOD-6    RMOD-7    RMOD-8    RMOD-9

&{PDU_RU1}              model=GUDE  host=10.44.200.183  port=@{1, }  version=8041-1      # AHLOA
&{PDU_RU2}              model=GUDE  host=10.44.200.187  port=@{1, }  version=8041-1      # AHFIB
&{PDU_SMOD_ASIB}        model=GUDE  host=10.44.205.242  port=@{8, }  version=8041-1      # ASIB
&{RU1}                  BL2004G104L=${PDU_RU1}
&{RU2}                  BL1913V008L=${PDU_RU2}
&{SMOD_ASIB}            L1191304511=${PDU_SMOD_ASIB}

@{PDU_LIST1}=            ${RU1}
@{PDU_LIST2}=            ${RU2}

@{BB_target}                 MRBTS-8816/EQM-1/APEQM-1/CABINET-1/BBMOD-1
...                          MRBTS-8816/EQM-1/APEQM-1/CABINET-1/BBMOD-2
...                          MRBTS-8816/EQM-1/APEQM-1/CABINET-1/BBMOD-3
...                          MRBTS-8816/EQM-1/APEQM-1/CABINET-1/BBMOD-4

@{RU_target}                 MRBTS-8816/EQM-1/APEQM-1/RMOD-1
...                          MRBTS-8816/EQM-1/APEQM-1/RMOD-2
...                          MRBTS-8816/EQM-1/APEQM-1/RMOD-3
...                          MRBTS-8816/EQM-1/APEQM-1/RMOD-5
...                          MRBTS-8816/EQM-1/APEQM-1/RMOD-6
...                          MRBTS-8816/EQM-1/APEQM-1/RMOD-7

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${custom_alarms}
...                         modules_for_test=${RU_target}      # OK
#...                         modules_for_test=${None}           # argument of type 'NoneType' is not iterable
#...                         modules_for_test=MRBTS-51778/EQM-1/APEQM-1/${RU_target[0]}
#...                         modules_for_test=MRBTS-51778/EQM-1/APEQM-1/CABINET-1/${BB_target[0]}

&{NODE3}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
...                         modules_for_test=${RU_target}

@{NODES}           ${NODE3}


*** Test Cases ***
# Thoughput_1 BTS_Block_Unblock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
[1]BTS_Block_Unblock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
    [Documentation]    Thoughput_1 BTS_Block_Unblock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
        e2e_tl_bts_block_unblock
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    l3_call_method=TOL_TPUT_AHLOA
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

# Thoughput_2 BTS_Block_Unblock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
[1]BTS_Block_Unblock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
    [Documentation]    Thoughput_2 BTS_Block_Unblock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
        e2e_tl_bts_block_unblock
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    l3_call_method=TOL_TPUT_AHFIB
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}


# Thoughput_5 RAT_Block_Unblock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
[1]RAT_Block_Unblock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
    [Documentation]    Thoughput_5 RAT_Block_Unblock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
        e2e_tl_bts_block_unblock
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    l3_call_method=TOL_TPUT_AHLOA
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}


# Thoughput_6 RAT_Block_Unblock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
[1]RAT_Block_Unblock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
    [Documentation]    Thoughput_6 RAT_Block_Unblock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
        e2e_tl_bts_block_unblock
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    l3_call_method=TOL_TPUT_AHFIB
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

# Thoughput_9 BBMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
[1]BBMOD_Lock_Unlock_Attach_Tput_ASIM_ABIA_AHLOB_Webem
    [Documentation]    Thoughput_9 BBMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
    ${modifications_dict} =  Create Dictionary  modules_for_test=${BB_target[2]}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE3}  ${modifications_dict}
    CSV4AllTestCases.e2e_tl_capacity_module_lock_unlock
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    l3_call_method=TOL_TPUT_AHLOA
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

# Thoughput_10 BBMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
[1]BBMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
    [Documentation]    Thoughput_10 BBMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
    ${modifications_dict} =  Create Dictionary  modules_for_test=${BB_target[0]}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE3}  ${modifications_dict}
    CSV4AllTestCases.e2e_tl_capacity_module_lock_unlock
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    l3_call_method=TOL_TPUT_AHFIB
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}



# Thoughput_13 RMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
[1]RMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
    [Documentation]    Thoughput_13 RMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHLOA_Webem
    ${modifications_dict} =  Create Dictionary  modules_for_test=${RU_target[4]}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE3}  ${modifications_dict}
    e2e_tl_ru_lock_unlock
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    l3_call_method=TOL_TPUT_AHLOA
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}


# Thoughput_14 RMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
[1]RMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
    [Documentation]     Thoughput_14 RMOD_Lock_Unlock_Attach_Tput_ASIB_ABIA_AHFIB_Webem
    ${modifications_dict} =  Create Dictionary  modules_for_test=${RU_target[0]}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE3}  ${modifications_dict}
    e2e_tl_ru_lock_unlock
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    l3_call_method=TOL_TPUT_AHFIB
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}


# Thoughput_17 RMOD_Reset_Attach_Tput_ASIB_ABIA_AHLOA_Webem
[1]RMOD_Reset_Attach_Tput_ASIB_ABIA_AHLOA_Webem
    [Documentation]     Thoughput_17 RMOD_Reset_Attach_Tput_ASIB_ABIA_AHLOA_Webem
    ${modifications_dict} =  Create Dictionary  modules_for_test=${RU_target[4]}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE3}  ${modifications_dict}
    e2e_tl_ru_reset_with_oam_kpi
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    l3_call_method=TOL_TPUT_AHLOA
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}


# Thoughput_18 RMOD_Reset_Attach_Tput_ASIB_ABIA_AHFIB_Webem
[1]RMOD_Reset_Attach_Tput_ASIB_ABIA_AHFIB_Webem
    [Documentation]     Thoughput_18 RMOD_Reset_Attach_Tput_ASIB_ABIA_AHFIB_Webem
    ${modifications_dict} =  Create Dictionary  modules_for_test=${RU_target[0]}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE3}  ${modifications_dict}
    e2e_tl_ru_reset_with_oam_kpi
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    l3_call_method=TOL_TPUT_AHFIB
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}


*** Keywords ***
Temporarily Modify Node
    [Arguments]  ${node}  ${modifications_dict}  ${print_to_console}=False
    ${NODE2} =  Create Dictionary  &{node}
    Set To Dictionary  ${NODE2}  &{modifications_dict}
    ${NODES2} =  Create List  ${NODE2}
    Log  Nodes are modified for ${TEST_NAME} test case.\n\nNODE2: ${NODE2}\n\nNODES2: ${NODES2}  console=${print_to_console}
    [Return]  ${NODE2}  ${NODES2}
