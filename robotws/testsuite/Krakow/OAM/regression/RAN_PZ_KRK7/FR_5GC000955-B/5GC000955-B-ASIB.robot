*** Settings ***
Documentation
...    Author: Kasper Biegun (kasper.biegun@nokia.com)
...    Maintainer: Kasper Biegun (kasper.biegun@nokia.com)
...    Group in charge: MN 5G&SC mmW&SC Pz KRK 5 SG
...    Feature Description: 5GC000955-B

Library     on_air_tl_preparation.testline_preparation
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ./resources/variables.robot
Resource    ./resources/keywords.robot

Force Tags    STATE_SW_UPLOADED    CRT    CLOUD_5G_CLASSICAL_ASIB_ABIL_AHFIB_SFP+QSFP_ENB

Suite Setup    Run keywords    Prepare Testline    should_LTE_neighbour_be_changed=${False}
...                                                should_5G_neighbour_be_changed=${False}
...                                                increase_time_for_checking_bbmod=600
...                                                increase_timeout_for_update_sw=1800
...                                                increase_time_for_checking_radios=2100    AND
...                            Prepare environment
Suite Teardown    Teardown environment

Test Setup        gnb_bbu.Wait For Site To Be Onair
Test Teardown     gnb_bbu.Wait For Site To Be Onair

*** Variables ***
${path_actCli_feature}=         /MRBTS-${mrbts_value}/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/MNL_A-1/MNLENT_A-1/FEATCADM_A-1
${path_SFP}=                    /MRBTS-1/RAT-1/RUNTIME_VIEW-${r_id}/MRBTS_R-${r_id}/EQM_R-${r_id}/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1
${delta_SFP_object_create}=     ${CURDIR}/resources/Delta_SFP_object_create.json
${delta_QSFP_object_create}=    ${CURDIR}/resources/Delta_QSFP_object_create.json
${delta_lane_object_delete}=    ${CURDIR}/resources/Delta_Lane_object_delete.json
${delta_activate_actCli}=       ${CURDIR}/resources/Delta_Activate_ActCli.json
${delta_deactivate_actCli}=     ${CURDIR}/resources/Delta_Deactivate_ActCli.json
${Delta_lockLane}=              ${CURDIR}/resources/Delta_lockLane.json
${Delta_unlockLane}=            ${CURDIR}/resources/Delta_unlockLane.json
${ADMIN_CLI_scripts_path}=      ${CURDIR}/scripts


*** Test Cases ***
[2][1.0] 5GC000955_Lock_Unlock_QSFP_BBMOD
    [Setup]    Prepare lane    QSFP
    Lock LANE by CLI is performed successfully
    Wait Until Keyword Succeeds    180s    10s    Verify Setup Of All Cells
    Unlock LANE by CLI is performed successfully
    Wait Until Keyword Succeeds    180s    10s    Verify Setup Of All Cells
    [Teardown]    Run Keywords    Delete LANE Objects    AND
    ...                           interface.Common step trigger

[1][1.0] 5GC000955_Lock_Unlock_QSFP_BBMOD
    [Setup]    Prepare lane    QSFP
    Lane lock and unlock in Detailed Site View    connector_name="Concentrator ${qsfp_connector}"
    Wait Until Keyword Succeeds    180s    10s    Verify Setup Of All Cells
    [Teardown]    Run Keywords    Delete LANE Objects    AND
    ...                           interface.Common step trigger

[1][2.0] 5GC000955_Configure_QSFP_lanes_in_CM_object
    [Setup]    Prepare lane    QSFP
    Configure QSFP Lanes
    Wait Until Keyword Succeeds    180s    10s    Verify Setup Of All Cells
    [Teardown]    Run Keywords    Delete LANE Objects    AND
    ...                           interface.Common step trigger

[2][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
    [Setup]    Prepare lane    SFP
    Lock LANE by CLI is performed successfully
    Wait Until Keyword Succeeds    180s    10s    Verify Setup Of All Cells
    Unlock LANE by CLI is performed successfully
    Wait Until Keyword Succeeds    180s    10s    Verify Setup Of All Cells
    [Teardown]    Run Keywords    Delete LANE Objects    AND
    ...                           interface.Common step trigger

[1][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
    [Setup]    Prepare lane    SFP
    Lane lock and unlock in Detailed Site View    connector_name="Connector ${sfp_connector}"
    Wait Until Keyword Succeeds    180s    10s    Verify Setup Of All Cells
    [Teardown]    Run Keywords    Delete LANE Objects    AND
    ...                           interface.Common step trigger

[1][1.0] 5GC000955_Parameters_check_for_transmission
    [Setup]    Prepare lane   SFP
    Check transmission rate parameter
    Check max transmission rate parameter does not exist
    Check transmission distance parameter does not exist
    [Teardown]    Run Keywords    Delete LANE Objects    AND
    ...                           interface.Common step trigger
