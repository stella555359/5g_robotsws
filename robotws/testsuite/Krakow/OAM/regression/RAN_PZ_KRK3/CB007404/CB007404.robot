*** Settings ***
Documentation
...    Author: Krzysztof Domino
...    Maintainer: krzysztof.domino@nokia.com
...    Description: CB007404-A Parameter modification type improvement.
...    Purpose of this feature is to reduce number of parameters which required BTS reset
...    Team in charge: MN 5G&SC mmW&SC Pz KRK 3 SG

Library  BuiltIn
Library  String
Library  OperatingSystem
Library  Collections
Library    taf.gnb.oam.coam.admin    WITH NAME  admin
Resource    resources/CB007404_keywords.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables     resources/deltas.py

Force Tags    STATE_SW_UPLOADED    CIT  PY36
...     RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIKR_ABILB4_AEUB
...     RAN_5G_MP__WITH__SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASIKR_ABILB4_AEUB
...     RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ASIKR_ABILB4_AEUB
...     RAN_5G_MP__WITH__SBTS22R2__WITH__CLOUD_5G_CLASSICAL_ASIKL_3xABILB1B3B5_3xAEUD
...     RAN_5G__WITH__SBTS23R1__WITH__CLOUD_5G_CLASSICAL_ASIKR_ABILB4_AEUB



Suite Setup  Preconditions_7404

Suite Teardown   Run Keywords   Teardown Logs Collectors
                 ...            AND   admin.teardown
                 ...            AND   Common Postconditions

*** Variables ***
@{allowed_alarms}     SSH enabled
...                   R&D Service Port enabled
...                   LMP access via port 443
...                   Diagnostic Files collected
...                   Radio Diagnostic Files collected
...                   Service account root access is enabled
...                   Ethernet port security is disabled
...                   Sanity Check Error
...                   User Account has Default Password
${MRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${NRBTS_ID}    ${tl.gnbs[0].instance_id}
${gNB_IP_MPLANE_LOCAL}     192.168.255.1
${gNB_MPLANE_IF_PORT}      443
${CELL_ID}    1
${CELLGRP_ID}    0

*** Test Cases ***
[14]CB007404_[Robustness]_[WebEM]_Modify_NRCELL.pMax_and_NRCELL.ssPbchBlockPower_parameters_with_cell_locking
    [Documentation]  In this scenario, operator modifies the parameter NRCELL. pMax and NRCELL. ssPbchBlockPower on existing NRCELL
    ...              from WebEM without BTS restart.
    [Setup]  Start watching alarms    allowed_alarms=${allowed_alarms}
    ${pMax_value}  get gnb parameter value via gui  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELL_ID}
    ...  param_name=Maximum output power  param_abbr=pMax
    ${pMax_value}  Remove String  ${pMax_value}  (dBm)
    ${pmax_value}  Evaluate  ${pMax_value}*10
    ${sspbch_value}  Get gNB Parameter Value via GUI  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELL_ID}
    ...  param_name=SS PBCH Block Power  param_abbr=ssPbchBlockPower
    ${sspbch_value}  Remove String  ${sspbch_value}  (dBm)
    Perform Delta Commissioning On gNB  ${delta_robustness_cell}
    Wait until keyword succeeds  10min  2sec  Check if cell is disabled  ${result}
    Wait until keyword succeeds  10min  20sec  Check if cell is enabled  ${result}
    Verify gNB Cell is onAir
    [Teardown]  Run keywords
    ...    Stop watching alarms  AND
    ...    Perform Configuration Parameter Recommissioning On gNB  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELL_ID}
    ...    ssPbchBlockPower
    ...    ${sspbch_value}  AND
    ...    Perform Configuration Parameter Recommissioning On gNB  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELL_ID}
    ...    pMax
    ...    ${pmax_value}
