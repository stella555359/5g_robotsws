*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop with CB008490 enabled.
...                 Author: Pawel Sniady
...                 Contact: pawel.sniady@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

Test Timeout        60h

*** Variables ***
${INITIAL_SW}               SBTS00_ENB_9999_250701_000013
${TARGET_SW}                SBTS00_ENB_9999_250702_000003

${ITERATIONS_UPGRADE}       10
${ITERATIONS_SITE_RESET}    20

@{NODE1_CUSTOM_FAULTS}      4654  4655  61524  61649  61652
@{NODE2_CUSTOM_FAULTS}      4654  4655  61524  61649  61652
#4654  Ethernet port security is disabled
#4655  Service account root access is enabled
#61524 SSH enabled
#61649 LMP access via port 443
#61652 R&D Service Port enabled

@{NODE1_TMP_FAULTS}         4298  4385  7107  7311
@{NODE2_TMP_FAULTS}         4298  7107  7311
#4298    ToP reference missing
#4385    PPS reference from backplane missing
#7107    Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
#7311    No Xn link available

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         node_alias=MN
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${NODE1_CUSTOM_FAULTS}
...                         temporary_allowed_alarms=${NODE1_TMP_FAULTS}
&{NODE2}                    testline_object=${tl.gnbs[1]}
...                         node_alias=SN
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${NODE2_CUSTOM_FAULTS}
...                         temporary_allowed_alarms=${NODE2_TMP_FAULTS}

@{NODES}                    ${NODE1}    ${NODE2}
@{UPGRADE_NODES}            ${NODE1}    ${NODE2}

${RP_CA}                    VRF_RRM
${RP_LOCATION}              VRF_WRO2
${RP_ORGANIZATION}          VRF_WRO2_T05
${LABEL}                    VRF_WRO2_T05_Pawel_Sniady
@{CUSTOMERS}                Generic
${REPORT}                   ${TRUE}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_multiple_node_upgrade
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATIONS_UPGRADE}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_Site_Reset_with_OAM_KPI
    E2E TL SITE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATIONS_SITE_RESET}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}
