*** Settings ***
Documentation
...    Author: joanna.wojtowicz@nokia.com
...    Maintainer: joanna.wojtowicz@nokia.com
...    Description: .  The purpose of CB005750-5G-FBAA feature is to introduce functionality which allows to commission
...    BTS with a new category of automated snapshot collection trigger a single substring occurrence in syslog
...    stream.
...    Team in charge: MN 5G&SC mmW&SC Pz KRK 3 SG

Library     on_air_tl_preparation.testline_preparation
Library     taf.sbts.oam.coam.admin    WITH NAME    admin_cli
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    ./resources/CB005750-5G-FBAA_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/recovery_gnb.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED    RAN_5G    PY36    CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AEQE_ECPRI   CRT
...           CA_RAN_PZ_KRK

Suite Setup       Run Keywords
...               Common Suite Setup With Onair Test Line Preparation  increase_timeout_for_update_sw=3600   AND
...               admin_cli.connect_to    AND
...               Setup Logs Collectors

Suite Teardown    Run keywords
...               Teardown Logs Collectors   AND
...               admin_cli.teardown  AND
...               Common Postconditions


*** Test Cases ***
[1]CB005750-5G-FBAA_Automatically_triggered_snapshot_LSS
    [Tags]    RAN_5G__WITH__SBTS22R4
    ...       RAN_5G__WITH__SBTS23R1
    ...       RAN_5G__WITH__SBTS00
    [Documentation]   Purpose of the test is to verify the automatically triggered snapshot functionality on the gNB
    ...   Classical, starting from the configuration of the automatic trigger to the detection of the trigger, snapshot
    ...   collection and upload to the configured snapshot remote destination (LSS).
    [Setup]   Start Collecting gNB Btslog
    Activate lssConfig parameter  ${dest_name}    ${LSS_IPv6}    22
    Set syslogSubstringTrigger param     blockCells started
    Lock gNB Cell
    Wait until keyword succeeds    3 min    1 min     Check if syslogSubstringTrigger occured in syslog
    ...   write Found string pattern=blockCells started
    Acquire snapshot name from BTSlog
    Wait until keyword succeeds    5 min    1 min    Check current remote snapshot on LSS and remove it
    [Teardown]    Run keywords  Stop Collecting gNB Btslog  AND
    ...    Unlock gNB Cell   AND
    ...    Wait For onAir State
