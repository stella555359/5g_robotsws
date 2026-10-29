*** Settings ***
Documentation
...   author: PZ_2_WRO_5

Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.py  WITH NAME  key
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.py

*** Keywords ***
Verify EMIL file from DCAP
    [Arguments]    ${expected_messages}=${messages_8717}
    ${CSV_verify}  key.check_8717_emil_messages_flow  exp_mesgs=${expected_messages}  path=${OUTPUT_DIR}/DCAPs/${test_name}.csv
    Should be true    ${CSV_verify}

Verify EMIL file from DCAP PSCell
    [Arguments]    ${expected_messages}=${messages_8717_PSCell}
    ${CSV_verify}  key.check_8717_emil_messages_flow_PSCell  exp_mesgs=${expected_messages}  path=${OUTPUT_DIR}/DCAPs/${test_name}.csv
    Should be true    ${CSV_verify}

Verify EMIL file from DCAP NRDC
    [Arguments]    ${expected_messages}=${messages_8717_NRDC}
    ${CSV_verify}  key.check_8717_emil_messages_flow_PSCell  exp_mesgs=${expected_messages}  path=${OUTPUT_DIR}/DCAPs/${test_name}.csv
    Should be true    ${CSV_verify}

Verify EMIL file from DCAP ENDC
    [Arguments]    ${expected_messages}=${messages_8717_NRDC}
    ${CSV_verify}  key.check_8717_emil_messages_flow_PSCell  exp_mesgs=${expected_messages}  path=${OUTPUT_DIR}/DCAPs/${test_name}.csv
    Should be true    ${CSV_verify}

Verify JSON file from DCAP
    [Arguments]     ${expected_messages}=${messages_8717_NB4}
    ${JSON_verify}  key.check_8717_N_json_messages  exp_mesgs=${expected_messages}
    ...             path=${OUTPUT_DIR}/DCAPs/${test_name}/
    Should be true  ${JSON_verify}

Read Counters Value 8717-D
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list    M55116C00016    M55116C00017    M55116C00020    M55124C00020    M55124C00021
    ...                          M55138C00038    M55156C00004
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 8717-D
    log to console    Verify PM counters values
    Sleep             300s
    ${counters}       Read Counters Value 8717-D
    ${NRDC_IA_MN_CU_ADD_REQ}         Get Counter Value From Single Cell      ${counters}    108    M55116C00016
    ${NRDC_IA_MN_CU_ADD_RESP}        Get Counter Value From Single Cell      ${counters}    108    M55116C00017
    ${NRDC_IA_MN_CU_ADD_RCF_CMPL}    Get Counter Value From Single Cell      ${counters}    108    M55116C00020
    ${IA_NRDC_MN_CU_DRB_STP_ATT}     Get Counter Value From Single Cell      ${counters}    108    M55124C00020
    ${IA_NRDC_MN_CU_DRB_STP_SUC}     Get Counter Value From Single Cell      ${counters}    108    M55124C00021
    ${SUM_UE_NRDC_CAP}               Get Counter Value From Single Cell      ${counters}    108    M55138C00038
    ${MAX_UE_NRDC_CAP}               Get Counter Value From Single Cell      ${counters}    108    M55156C00004
    Should Be True      1<=${NRDC_IA_MN_CU_ADD_REQ}
    Should Be True      1<=${NRDC_IA_MN_CU_ADD_RESP}
    Should Be True      1<=${NRDC_IA_MN_CU_ADD_RCF_CMPL}
    Should Be True      1<=${IA_NRDC_MN_CU_DRB_STP_ATT}
    Should Be True      1<=${IA_NRDC_MN_CU_DRB_STP_SUC}
    Should Be True      1<=${SUM_UE_NRDC_CAP}
    Should Be True      1<=${MAX_UE_NRDC_CAP}
