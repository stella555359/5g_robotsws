*** Settings ***
Documentation
...  feature Robustness

Library          taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${5g_source_sw}=       ${EMPTY}
${5g_target_sw}=       ${EMPTY}
${RP_LOCATION}         VRF_WRO1
${RP_CA}               VRF_SiSo
${RP_ORGANIZATION}     VRF_WRO1_T01
&{NODE1}               node_vm=127.0.0.1
...                    source_sw=${5g_source_sw}
...                    target_sw=${5g_target_sw}
@{NODES}               ${NODE1}
${ITERATIONS}          10
@{CUSTOMERS}           Generic

*** Test Cases ***
CSV4ALL_SW_UPGRADE_TEST
    [Timeout]    24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
    ...     customers_list=${CUSTOMERS}
