*** Settings ***
Documentation
...                 author: Michal Kornacki
...                 contact: michal.kornacki@nokia.com
Resource      ../../../test_resources/SWM/SiSo_SWM_RU_Logs_Snapshot_Collection.robot

*** Variables ***
${HW_LOCATION_CODE}         Wroclaw
${COMMISSIONING_PATH}      /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO093_DEFAULT.xml
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${TESTLINE_NAME}            10_16_UTESRANSISO093
${node}  default
${ADDITIONAL_IGNORED_ALARMS}  1300

*** Test Cases ***
[Fullrack_FHS][1.0] General_SiSo_Auto_RU_Logs_Snapshot_Collection
   [Setup]  Run Keywords    Set Test Variable   ${COMMISSIONING_PATH}
   ...   AND    Set Test Variable    ${RMOD_SN}    K9192414089
   ...   AND   SiSo_SWM_RU_Logs_Snapshot_Collection.TC Setup
   ...   AND    Set Library Search Order   SiSo_SWM_RU_Logs_Snapshot_Collection
   [Timeout]  14400
   TC__SiSo_SWM_RU_Logs_Snapshot_Collection
   [Teardown]  SiSo_SWM_RU_Logs_Snapshot_Collection.TC Teardown
