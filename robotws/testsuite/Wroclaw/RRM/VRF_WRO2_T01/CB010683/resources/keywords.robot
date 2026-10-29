*** Settings ***
Documentation
...  Description:   Feature CB010683

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot

*** Variables ***
${SCF_CB010683}           ${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010683/resources/SCFs
@{allowed_alarms}     61649  4681  4655  61524  4654  8150  61652  4592
@{ue_aliases}         UE_1
${PS_CELL_PATH_NR}    MRBTS-51015/NRBTS-51015/NRCELL-501

*** Keywords ***
Perform commissioning with CB010683 SCF
    Log to console  Performing commissioning with CB010683 SCF
    Connect with runtime release  alias=cOAM
    ${release}  coam.Get sw release name    connection=cOAM
    coam.perform commissioning   bts_id=${MRBTS_5G_ID}
    ...                                                  scf_file=${SCF_CB010683}/${MRBTS_5G_ID}.xml
    ...                                                  skip_parameter_relation_errors=${True}
    ...                                                  should_activate=${True}
    ...                                                  timeout=600
    ...                                                  connection=cOAM

    Wait until keyword succeeds  10min   1min   Verify all cells are onair with admin

Activate/Deactivate CB010683 with delta commissioning
    [Arguments]         ${actNrExtCellSOMethod}=true

    Run Keyword If      "${actNrExtCellSOMethod}" == "true"
    ...     Log to console  Activate a CB010683 feature with delta commissioning
    ...     ELSE
    ...     Log to console  Deactivate a CB010683 feature with delta commissioning

    ${cell_dists}       Get cells distname list
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    Initialise delta store
    Add param to delta  ${object_path}   actNrExtCellSOMethod    value=${actNrExtCellSOMethod}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

Check alarms after activation/deactivation
    log to console  Check for unexpected alarms
    coam.connect to                                name=alarm_conn
    FOR    ${fid}    IN    @{allowed_alarms}
        coam.add allowed alarm    faultId=${fid}        connection=alarm_conn
    END
    coam.assert_no_unexpected_active_alarms        connection=alarm_conn
    [Teardown]    coam.teardown                    connection=alarm_conn

Check L3 Call
    Get UEs  ${ue_aliases}  ue_capabilities=REAL_UE
    Attach UEs to cell  ${ue_aliases}
    Start ULDL for UEs  ${ue_aliases}  duration=10s  protocol=udp
    Await datatransfers finish
    Detach UEs from cell  ${ue_aliases}


Check power saving status
    Connect with runtime release    cell_status

    ${cell_status}    coam.get cell specific info
    ...    cell_id=${PS_CELL_PATH_NR}
    ...    connection=cell_status

    # Comparision is based on WEBEM info status of a cell.
    should be equal    ${cell_status['energySavingState']}    energySaving

    [Teardown]    coam.teardown    connection=cell_status


Wait for energy saving status
    wait until keyword succeeds    30min    1min    Check power saving status
