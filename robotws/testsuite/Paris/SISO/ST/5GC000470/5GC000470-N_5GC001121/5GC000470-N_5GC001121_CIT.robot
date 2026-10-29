*** Settings ***
Documentation
...         Description : Testcases for Feature 5GC000470

...         5GC000470 aims to support of 5G classical gNB and cloud gNB-DU on ASIB A102/M02 and ABIL/ABIL2
...         with same feature set as with ASIK and ABIL/ABIL2 units, this feature requires testing:
...             - software management via OAM
...             - Multi-UE at I&V (e.g. with Qualcomm)
...             - other MCSs up to max cell capactiy
...             - ET PM counter validation
...             - Higher stability than -A (startup: >90%; Call setup and release > 90%; throughput: 8-12h with 90% of MSC data rate)

...         AUTHOR (I&V):   Merwane CHEMSSI         merwane.chemssi@nokia.com
...                         Joseph SOQUES           joseph.soques@nokia.com
...                         Philippe GABORIEAU      philippe.gaborieau@nokia.com

Library     OperatingSystem
Library     String
Library     Process
Library     DateTime

Library             ute_reporting_portal
Force Tags          CA_5G_IVPS   QCD_MN_5G    QCP_5G   5G_RAN   5G_RAN_TDD   SISO


Library     taf.gnb.oam.coam.admin          WITH NAME       coam

Resource    ../../../../resources/ST/robot/kw_commissioning_swconfig.robot

Resource    ../../resources/kw_coam_UTECM.robot
Resource    ../../resources/kw_classical.robot
Resource    var_test_suite_UTECM.robot

Suite Setup             Setup Suite


*** Test Cases ***

[1]5GC000470-N_004_5gBTS_Basic_Synchrokw_5GC000470-N_004_5gBTS_Basic_Synchro
    Wait until Keyword Succeeds   300s  5s    Check Sync Status

    [Setup]    Setup Sequence
    Wait until Keyword Succeeds   300s  5s    Check Sync Status
    [Teardown]    Teardown Sequence


[1]5GC000470-N_007_5gBTS_Snapshot
    [Setup]    Setup Sequence
    ${current_date}=                Get Current Date        result_format=%Y%m%d_%H%M%S
    set suite variable              ${current_date}
    Wait until Keyword Succeeds     600s    30s      CreateSnapshot
    [Teardown]    Teardown Sequence


[1]5GC000470-N_008_Check_HW_infos
    [Setup]    Setup Sequence
    Wait until Keyword Succeeds     180s    10s      Check Rack Type
    [Teardown]    Teardown Sequence

[1]5GC000470-N_009_Cell_Setup
    [Setup]    Setup Sequence with OAM
    Wait until Keyword Succeeds     300s        30s         Check FSM Status From WEBUI
    Wait until Keyword Succeeds     300s        30s         Check FBBs Status From WEBUI
    Wait until Keyword Succeeds     300s        30s         Check Cell Status
    [Teardown]    Teardown Sequence with OAM


*** Keywords ***
Setup Suite
    Commissioning Classical and Copy SWConfig file

Setup Sequence
    Create Sessions

Teardown Sequence
    Teardown Sessions

Setup Sequence with OAM
    Create Sessions
    Connect To OAM

Teardown Sequence with OAM
    Teardown Sessions
    disconnect from OAM
