*** Settings ***
Documentation
...    The purpose of this test case is to evaluate call establishment (attach, detach) success rate.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50


Resource    ../../resources/main_resources.robot

# -- extra resources --
Library    taf.sw.reporting_portal    WITH NAME    taf_reporting_portal

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/Call_establishment_success_rate.resources

${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${RADIO_NAME}    AEQE
${CELL_ID}    1
${FIRST_UE_ID}    101
${NUMBER OF ATTEMPTS}     ${20}
${SUCCESSFUL ATTEMPTS}    ${0}
${TSHARK_SUBDIR_SIZE_MAX_BYTES}    200000000

*** Test Cases ***
CNI62781_Call_establishment_success_rate_-_attach_and_detach_ue_multiple_times
    [Setup]    [PRE]CNI62781_Call_establishment_success_rate_-_attach_and_detach_ue_multiple_times
    [Teardown]    [POST]CNI62781_Call_establishment_success_rate_-_attach_and_detach_ue_multiple_times
    Check Call Establishment "${NUMBER OF ATTEMPTS}" Times

*** Keywords ***
[PRE]CNI62781_Call_establishment_success_rate_-_attach_and_detach_ue_multiple_times
    Start WTS    ${LUA_CONFIG}    nr_mode=NSA    check_version=False
    Check if BTS is OnAir

[POST]CNI62781_Call_establishment_success_rate_-_attach_and_detach_ue_multiple_times
    Report miscellaneous KPIs
    ${success_rate}    Evaluate    int($SUCCESSFUL_ATTEMPTS / $NUMBER_OF_ATTEMPTS * 100)
    LOG    NUMBER OF ATTEMPTS: ${NUMBER OF ATTEMPTS} SUCCESSFUL ATTEMPTS: ${SUCCESSFUL ATTEMPTS}    INFO
    LOG    SUCCESS RATE: ${success_rate}%    INFO
    Send KPI    ${success_rate}
    RUN KEYWORD IF    ${success_rate}!=${100}    FAIL    Success rate less than 100%: ${success_rate}%
    Stop WTS

# -- test steps --
Check Call Establishment "${number}" Times
    [Tags]    DESIGNSTEP
    LOG TO CONSOLE    \n####### Check Call Establishment "${number}" Times #######
    ${ue_id}=    SET VARIABLE    ${FIRST_UE_ID}
    FOR    ${attempt}    IN RANGE    1    ${number + 1}
        Check If Cell"${CELL_ID}" Is OnAir
        ${successful_call}    RUN KEYWORD AND RETURN STATUS    UE"${ue_id}" Call Establishment
        RUN KEYWORD IF    ${successful_call}    Increment Value Of Successful Attempts
        ${tshark_logs_size}    Return size of SUBDIRECTORY "tshark" in bytes
        ${remove_logs}    Evaluate    ${successful_call} and ${SUCCESSFUL ATTEMPTS} > ${1} or ${tshark_logs_size} > ${TSHARK_SUBDIR_SIZE_MAX_BYTES}
        RUN KEYWORD IF    ${remove_logs}    Remove tshark log files for UE"${ue_id}"
        ${ue_id}=    EVALUATE    ${FIRST_UE_ID} + ${attempt}
    END

# -- internals --
Check If Cell"${physical_layer_cell_id}" Is OnAir
    ute_admin_infomodel.query_infomodel
    ...    query=/MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/NRBTS_M-1/CELL_M-${physical_layer_cell_id} is [stateInfo.proceduralState=OnAirDone]
    ...    timeout=5

UE"${ue_id}" Call Establishment
    LOG TO CONSOLE    \n####### UE${ue_id} Call Establishment #######
    NSA Attach 5G UE"${ue_id}"
    NSA Detach 5G UE"${ue_id}"

Increment Value Of Successful Attempts
    SET SUITE VARIABLE    ${SUCCESSFUL ATTEMPTS}    ${SUCCESSFUL ATTEMPTS + 1}

Send KPI
    [Arguments]    ${success_rate}
    ${success_rate}    CONVERT TO STRING    ${success_rate}
    ${description}    SET VARIABLE    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE, 1xCell, 1x${RADIO_NAME}
    taf_reporting_portal.report_kpi_results
    ...    target=100
    ...    name=5G Call establishment success rate: attach/detach
    ...    visible_to_db=True
    ...    value=${success_rate}
    ...    kpi_type=int
    ...    description=${description}
    ...    category=Performance
    ...    unit=%

Remove tshark log files for UE"${ue_id}"
    Remove FILES "*attach_ue${ue_id}" from SUBDIRECTORY "tshark/attach_keyword"
    Remove FILES "sgnb_addition${ue_id}" from SUBDIRECTORY "tshark/sgnb_addition"
    Remove FILES "*detach_ue${ue_id}" from SUBDIRECTORY "tshark/detach_keyword"
