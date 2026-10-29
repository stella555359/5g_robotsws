*** Settings ***
Documentation
...  feature Robustness

Library          taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_LOCATION}         VRF_WRO1
${RP_CA}               VRF_SiSo
${RP_ORGANIZATION}     VRF_WRO1_T01
&{NODE1}               node_vm=127.0.0.1
@{NODES}               ${NODE1}
${ITERATIONS}          10
@{CUSTOMERS}           Generic

*** Test Cases ***
CSV4ALL_RU_LOCK_UNLOCK_TEST
    [Timeout]    24h
    E2E TL RU LOCK UNLOCK   ${NODES}  ${NODE1}  ${ITERATIONS}
    ...     customers_list=${CUSTOMERS}
