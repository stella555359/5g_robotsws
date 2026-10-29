*** Settings ***
Documentation
...    Maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    Original Author: Chao Kuang
...    Original Contact: chao.kuang@nokia-sbell.com
...    Transition Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Feature CB009351

Resource       resources/CB009351_CommonKeywords.robot
Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Force Tags    STATE_SW_UPLOADED    CRT    RAN_5G    PY39

Suite Setup       Run Keywords
...               Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt    AND
...               Connect to gNB cOAM via SSL    connection=default
Suite Teardown    Run Keyword And Ignore Error    Teardown gNB cOAM SSL Connection    connection=default


*** Variables ***
${GNB_HTTP_ADDR}        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GNB_ID}               ${tl.gnbs[0].global_bts_id}
${FEATCADM_DistName}    MRBTS-${GNB_ID}/MNL-1/MNLENT-1/FEATCADM-1


*** Test Cases ***
[1][3.0] CB009351-A_3_Reset_RU_trigger_fault_1901
    [Tags]         SBTS00    SBTS24R1
    [Setup]        Run Keywords
    ...            Set Allowed Alarms With Diagnostic Files    AND
    ...            Common Preconditions
    Perform Site Reset    connection=default
    Wait Until Keyword Succeeds    600 sec    30 sec    Verify gNB is onAir
    Enable FaultSignature If Necessary    ${FEATCADM_DistName}
    Rename Radio File Via Cmd    ${mv_cmd}
    Wait Until Keyword Succeeds    300 sec    30 sec    Process Alarm History
    ...    fid=${FID_1901}
    ...    fname=${FName_1901}
    ...    &{Signature_1901}
    [Teardown]    Run Keywords
    ...           Cancel Fault 1901    AND
    ...           Common Postconditions
