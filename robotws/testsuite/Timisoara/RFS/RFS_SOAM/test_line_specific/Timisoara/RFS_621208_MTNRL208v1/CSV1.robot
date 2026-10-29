*** Settings ***
Documentation  Test Suite
#Resource    ../../../test_resources/E2E_TL_Delta_Commissioning_With_NR_Rat_Reset.robot

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL208
...    SBTS00   STATE_SKIP_AGENT    CRT

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables

${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_TSR
${RP_ORGANIZATION}    VRF_TSR_T06

${EMAIL_RECIPIENTS}         None

${INITIAL_SW}
${TARGET_SW}

${ITERATIONS}               3

@{CUSTOM_ALLOWED_ALARMS}    4773  7107  4385  1815  7300  7319  4452  1898  4700  6134  6132  6129  7513  7511  7509  4694  4530  4602  4592
${NR_RAT_RESET_DELTA}=               ${CURDIR}/../../../test_line_specific/Timisoara/RFS_621208_MTNRL208v1/delta_nr_rat_reset.json

&{node1}                    testline_object=${tl.enbs[0]}
...                         node_alias=BTS1
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{NODES}                    ${node1}
@{UPGRADE_NODES}            ${node1}
@{CUSTOMERS_LIST}           Generic


*** Test Cases ***
[1][1.0] E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES}  ${NODE1}  ${ITERATIONS}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${False}
    ...         delta=${NR_RAT_RESET_DELTA}
    ...         qc_domain=None
    ...         qc_project=None
    ...         qc_id=None

