*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Resource    ./resources/keywords_8225.robot


*** Keywords ***
CB008225_RRC_Inactive_State
    [Documentation]   This test case checks dl, ul and dl ca tput for Idle and Inactive states and compare these values
    ${tl_name}   Set Variables Related to Testline
    Run Keyword If   '${tl_name}' == 'HASTROMUTANT1'
    ...            Require Ue   ${ue_alias}  capabilities=${ue_alias}
    ...   ELSE
    ...     Run Keywords
    ...            Enable Inactive State Feature On Ue    ${ue_alias}
    ...     AND    Require Ue If Not Reserved    ${ue_alias}
    Get timers settings from BTS
    set_preferred_cell   cell_id=${serving_cell}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    logs.Start Tracing On SMOD   smod slave=False

    Deactivate RRC Inactive feature

    FOR  ${tput_variant}  IN  @{triggers}
        Show Text on Console    Run ${tput_variant} TPUT to go from IDLE to CONNECTED state   colour=${REDBG}  show_timestamp=no
        Attach UE and verify it   ${serving_cell}
        Wait Inactivity timer expired and UE moves to IDLE state

        ${avg_tput}   Start Traffic and get result   ${tput_variant}
        Set To Dictionary   ${TPUT}[IDLE]   ${tput_variant}=${avg_tput}

        Detach Ue   ${ue_alias}
    END

    Activate RRC Inactive feature

    FOR  ${tput_variant}  IN  @{triggers}
        Show Text on Console    Run ${tput_variant} TPUT to go from INACTIVE to CONNECTED state   colour=${REDBG}  show_timestamp=no
        Attach UE and verify it   ${serving_cell}
        Wait Inactivity timer expired and UE moves to INACTIVE state

        ${avg_tput}   Start Traffic and get result   ${tput_variant}
        Set To Dictionary   ${TPUT}[INACTIVE]   ${tput_variant}=${avg_tput}

        Detach Ue   ${ue_alias}

        Run Keyword And Continue On Failure   compare_tputs
        ...                                         ${TPUT}[IDLE][${tput_variant}]
        ...                                         ${TPUT}[INACTIVE][${tput_variant}]
        ...                                         ${tput_deviation}
    END

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    Collect Counters And Verify Them    ${pm_start_time}  ${pm_stop_time}  ${log_path}  ${serving_cell}

    [Teardown]   Run Keywords
    ...        Stop Data Transfer   DT_DATA
    ...   AND  Detach Ue   ${ue_alias}
    ...   AND  logs.Stop Tracing On SMOD
    ...   AND  set_rrc_inactive_feature   action=activate
    ...   AND  unset_preferred_cell
