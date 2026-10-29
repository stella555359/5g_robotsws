*** Settings ***
Documentation
...  Author:        Pawel Wisniewski
...  Contact:       pawel.1.wisniewski@nokia.com
...  Feature owner: Maciej Haladewicz, Patrycja Lis
...  Description:   CB008204. Test cases which were migrated to T177 TMO test line.

Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/keywords.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/tests_8204.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_SFE.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot
Library           taf.sbts.oam.coam.admin  WITH NAME    coam
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/utils.py    WITH NAME    utils

Suite Setup  Run Keywords
...    Setup attenuators  AND
...    Turn off attenuation

Test Setup  run keywords
...    Get UEs  ${UE}  RFCX51BXKLV  AND
...    Start syslog capture

Test Teardown  run keywords
...      Stop syslog capture                 AND
...      Add Scout Data Info To Testcase     AND
...      Collect snapshot if test failed


*** Variables ***
@{UE}  ue1

*** Test Cases ***
[1]CB008204-D#3_01_DL_PRB_UTIL_SLOT_MAX_and_UL_PRB_UTIL_SLOT_MAX_SA_TDD
    [Tags]    sa    tdd    d301
    [Documentation]
    ...    This user scenario is aimed at verifying the counters which are introduced as part of CB008204-D
    ...    to monitor max DL UL PRB usage.
    [1]CB008204-D#3_01_DL_PRB_UTIL_SLOT_MAX_and_UL_PRB_UTIL_SLOT_MAX_SA_TDD

[1]CB008204-A#1_17_DL_PDCP_SDU_USDAT_CU_PMQAP_and_DL_PDCP_SDU_DISC_CU_PMQAP_SA_TDD
    [Tags]   sa    tdd    a117
    [Documentation]
    ...    This user scenario is aimed at verifying the PMQAP counters which are introduced as part of CB008204-A
    ...    to monitor Integrity through DL PDCP Drop rate.
    [1]CB008204-A#1_17_DL_PDCP_SDU_USDAT_CU_PMQAP_and_DL_PDCP_SDU_DISC_CU_PMQAP_SA_TDD

[1]CB008204-F#2_04_DL_RLC_SDU_TX_AIR_PMQAP_and_DL_RLC_SDU_LOST_AIR_PMQAP_SA_FDD
    [Tags]   sa    fdd    f204
    [Documentation]
    ...    This user scenario is aimed at verifying the PMQAP counters which are introduced as part of CB008204-F
    ...    to monitor Integrity through Packet Uu Loss Rate in the DL.
    [1]CB008204-F#2_04_DL_RLC_SDU_TX_AIR_PMQAP_and_DL_RLC_SDU_LOST_AIR_PMQAP_SA_FDD
