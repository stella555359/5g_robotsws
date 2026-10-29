*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com

Library         taf.sbts.oam.coam.admin  WITH NAME    coam
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/OAM_keywords.robot

*** Variables ***

@{ALLOWED_FAULT_ID}  4655  61649  61652  4654  61524  4681  4592  1936  8150

*** Keywords ***

Check for unexpected active alarms
    Connect with runtime release    Alarm
    FOR  ${faultId}   IN   @{ALLOWED_FAULT_ID}
        coam.add_allowed_alarm    faultId=${faultId}   connection=Alarm
    END
    coam.assert_no_unexpected_active_alarms   connection=Alarm
    [Teardown]    coam.Teardown     connection=Alarm

Reset BBMOD
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${bbmods}  Get BBMODs dist names   connection=${alias}
    Log to console  ...Performing bbmods reset
    FOR    ${bbmod}    IN  @{bbmods}
        coam.reset_unit  dist_name=${bbmod}  timeout=600s  connection=${alias}  reset_type=Warm  force_radio_reset=False
    END
    Sleep  60s
    Log to console  ...Checking if BBMODs operational:
    OAM_keywords.Check BBMODs state   connection=${alias}
    Sleep  1 min
    Log to console  ...Checking alarms
    Verify if all cells are onair
    Check for unexpected active alarms
    [Teardown]    coam.Teardown     connection=${alias}

Reset all rmods
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${RMODS}  coam.get_ids_for_all   RMOD   timeout=30s  connection=${alias}
    FOR    ${RMOD}    IN  @{RMODS}
        coam.reset_unit  dist_name=${RMOD}   timeout=900s   connection=${alias}  reset_type=Soft
    END
    Verify if all cells are onair
    Check for unexpected active alarms
    [Teardown]    coam.Teardown     connection=${alias}

Lock/Unlock BBmod
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${bbmods}  Get BBMODs dist names  connection=${alias}
    Log to console  ...Performing bbmods lock
    FOR    ${bbmod}    IN  @{bbmods}
        coam.lock  dist_name=${bbmod}   timeout=600s   connection=${alias}
    END
    Sleep  60s
    Log to console  ...Checking if BBMODs status:
    OAM_keywords.Check BBMODs state     administrativeState=Locked  connection=${alias}
    Log to console  ... Perform bbmod unblocks Unlock
    FOR    ${bbmod}    IN  @{bbmods}
        coam.unlock  dist_name=${bbmod}  timeout=600s  connection=${alias}
    END
    sleep   60s
    OAM_keywords.Check BBMODs state   connection=${alias}
    Verify if all cells are onair
    Check for unexpected active alarms
    [Teardown]    coam.Teardown     connection=${alias}

Site reset
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    coam.reset_site   connection=${alias}
    Verify if all cells are onair
    Check for unexpected active alarms
    [Teardown]    coam.Teardown     connection=${alias}

SW_ROLLBACK
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    Log to console  Perform sw rollback
    coam.rollback_software   timeout=900s  connection=${alias}
    Log to console  Veryfiy OnAir
    Verify if all cells are onair
    Log to console  Checking alarms
    Check for unexpected active alarms
    [Teardown]    coam.Teardown     connection=${alias}

Lock all rmods
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${RMODS}  coam.get_ids_for_all  RMOD   timeout=30s  connection=${alias}
    FOR    ${RMOD}    IN  @{RMODS}
        Log to console   __Lock RMOD:${RMOD}
        coam.lock  dist_name=${RMOD}  timeout=600s  connection=${alias}
    END
    [Teardown]    coam.Teardown     connection=${alias}

Unlock all rmods
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${RMODS}  coam.get_ids_for_all  RMOD   timeout=30s  connection=${alias}
    FOR    ${RMOD}    IN  @{RMODS}
        Log to console   __Unock RMOD:${RMOD}
        coam.unlock  dist_name=${RMOD}  timeout=600s  connection=${alias}
    END
    [Teardown]    coam.Teardown     connection=${alias}

Lock\Unlock bts
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${id}  coam.get_managed_objects  NRDU_R    connection=${alias}
    ${dist}  set variable   ${id[0]['distName']}
    Log to console   __Lock BTS
    coam.lock  dist_name=${dist}  timeout=60s  connection=${alias}
    Log to console   __Unlock BTS
    coam.unlock   dist_name=${dist}  timeout=60s  connection=${alias}
    [Teardown]    coam.Teardown     connection=${alias}

Lock Cells
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${ids}  get_nrcell_r_distname_list
    FOR    ${cell_id}    IN    @{ids}
        Log to console  __Lock cell: ${cell_id}
        coam.lock  ${cell_id}  timeout=600s  connection=${alias}
    END
    [Teardown]    coam.Teardown     connection=${alias}

Unlock Cells
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${ids}  get_nrcell_r_distname_list
    FOR    ${cell_id}    IN    @{ids}
        Log to console  __Unlock cell: ${cell_id}
        coam.unlock   ${cell_id}  timeout=600s  connection=${alias}
    END
    [Teardown]    coam.Teardown     connection=${alias}

Reset BBMOD 22r2
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${bbmods}  Get BBMODs dist names   connection=${alias}
    Log to console  ...Performing bbmods reset
    FOR    ${bbmod}    IN  @{bbmods}
        coam.reset_unit  dist_name=${bbmod}  timeout=600s  connection=${alias}  reset_type=Warm  force_radio_reset=False
    END
    Sleep  60s
    Log to console  ...Checking if BBMODs operational:
    OAM_keywords.Check BBMODs state 22r2  connection=${alias}
    Sleep  1 min
    Log to console  ...Checking alarms
    Verify if all cells are onair
    Check for unexpected active alarms
    [Teardown]    coam.Teardown     connection=${alias}

Lock/Unlock BBmod 22r2
    [Arguments]     ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${bbmods}  Get BBMODs dist names  connection=${alias}
    Log to console  ...Performing bbmods lock
    FOR    ${bbmod}    IN  @{bbmods}
        coam.lock  dist_name=${bbmod}   timeout=180s   connection=${alias}
    END
    Sleep  60s
    Log to console  ...Checking if BBMODs status:
    OAM_keywords.Check BBMODs state 22r2     administrativeState=Locked  connection=${alias}
    Log to console  ... Perform bbmod unblocks Unlock
    FOR    ${bbmod}    IN  @{bbmods}
        coam.unlock  dist_name=${bbmod}  timeout=180s  connection=${alias}
    END
    sleep   60s
    OAM_keywords.Check BBMODs state 22r2   connection=${alias}
    Verify if all cells are onair
    Check for unexpected active alarms
    [Teardown]    coam.Teardown     connection=${alias}
