*** Settings ***
Resource    ../../common_resources.robot


*** Keywords ***
_WA_for_ssh_issue
    run keyword and ignore error    Close all connection
    Connect to gnb coam via ssl

Switch network mode between NSA and SA
    [Documentation]  Author: Ding Binmei
    ...              Description: ${prefer_5g_nr_mode}: Supported values: SA / NSA
    ...    if prefer_5g_nr_mode is set to SA: prefer 5G NR mode will set to 'SA Mode', network mode will set to 'NR Only'
    ...    if prefer_5g_nr_mode is set to NSA: prefer 5G NR mode will set to 'NSA Mode', network mode will set to 'NR/LTE'
    ...    This keyword will try to attach after switch mode, but if attach failed it can still continue on the case execution,
    ...    as based on our testing, attach can be passed after several retry.
    [Arguments]  ${ue_index}=${0}    ${is_prepare_ue_needed}=${True}    ${prefer_5g_nr_mode}=SA
    ${UE_TYPE}    ue.translate_power_ue_type_from_testline
    set suite variable    ${UE_TYPE}
    Run keyword if   ${is_prepare_ue_needed}    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
    Run keyword and ignore error    android_common_keyword.Ue attach with index    ue_index=${ue_index}
    ${5g_nr_mode}    Set variable if    '${prefer_5g_nr_mode}'=='SA'    SA Mode    NSA Mode
    ${network_mode}    Set variable if    '${prefer_5g_nr_mode}'=='SA'    NR only    NR/LTE
    ${validate_net_mode_text}    Set variable if    '${network_mode}'=='NR/LTE'    NR / LTE
    ...    '${network_mode}'=='NR only'    NR only
    ...    Un_supported
    ${is_lte_attach_check_needed}    Set variable if    '${prefer_5g_nr_mode}'=='SA'    ${False}    ${True}
    ${is_network_mode_as_expected}    Is network mode as expected    exp_net_mode=${validate_net_mode_text}    ue_index=${ue_index}
    run keyword if   ${is_network_mode_as_expected}    log to console    cur network mode is ${network_mode} which is as expected. No need to switch.

    ${swicth_mode_status}    run keyword if    ${is_network_mode_as_expected}==${FALSE}    run keyword and return status
    ...    run keywords    Wait Until Keyword Succeeds    2X    2s    android_common_keyword.Change network mode on UE   net_mode=${network_mode}
    ...              validate_net_mode_text=${validate_net_mode_text}
    ...    AND    Wait Until Keyword Succeeds    2X    2s    android_common_keyword.Switch prefer 5G NR mode    5g_nr_mode=${5g_nr_mode}
    ...    AND    Run keyword and ignore error    UE detach should be successed    ue_index=${ue_index}    ue_type=${UE_TYPE}
    ...    AND    Run keyword and ignore error    Retry commercial ue attach if failed    prepare_ue_needed=${False}
    ...    retry_time=1    4G_check=${is_lte_attach_check_needed}
    run keyword if    ${is_network_mode_as_expected}==${FALSE}    Run keywords    Should be True    ${swicth_mode_status}    AND
    ...    Log to console    Switch mode to ${prefer_5g_nr_mode} successfully.
    [Teardown]  Run keyword and ignore error    Retry commercial ue detach if failed    ue_index=${ue_index}

Switch NSA SA mode via cell bar/unbar nr cells
    [Documentation]  Author: Ding Binmei
    ...    From latest Android 13, prefer_5g_nr_mode option no longer displayed in developer option on QCOM UE
    ...    Please set network mode on UE to NR/LTE by default since after SDX75, auto update keyword is no longer supported
    ...    So currently our solution for NSA SA swith is to via cell bar or unbar nr cells and meanwhile adjust PA for LTE
    ...    ${pa_values_mapping}: PA initilize for NR RUs. Example input as bellow: {0: [0, 0, 0, 0]}
    ...        { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
    ...    ${prefer_5g_nr_mode}: SA, NSA
    ...    ${timeout}: Refers to timeout value when send cell bar/unbar via rest api
    ...    Steps: 1. Initialize PA based on NSA or SA
    ...           2. Need to set network mode to NR/LTE from UE side
    ...           3. Need to set prefer 5g nr mode to SA+NSA if it still exist on UE under developer option(This action is done only for SDX60 UE)
    ...           4. if ${prefer_5g_nr_mode} is NSA: Bar all NR cells and set ENB PA to 0.
    ...           5. if ${prefer_5g_nr_mode} is SA: Bar NR cells except for pcell and set ENB PA to 127

    [Arguments]   ${pa_values_mapping}    ${pcell_id}    ${ue_index}=${0}    ${is_prepare_ue_needed}=${True}    ${prefer_5g_nr_mode}=SA
    ...    ${timeout}=2min    ${connection}=GNB_OAM    ${gnb_index}=0    ${if_change_ENB_PA}=${True}
    ${UE_TYPE}    ue.translate_power_ue_type_from_testline
    set suite variable    ${UE_TYPE}
    Run keyword and ignore error    Run keyword if    '${tl.attenuators}'!='[None]' and "${pa_values_mapping}"!="${None}"
    ...    Initialize attenuator values for testline    pa_values_mapping=${pa_values_mapping}    if_change_ENB_PA=${if_change_ENB_PA}
    ...        NSA_SA=${prefer_5g_nr_mode}
    Run keyword if   ${is_prepare_ue_needed}    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
    run keyword if    '${prefer_5g_nr_mode}'=='SA'
    ...    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${pcell_id}    timeout=${timeout}
    ...        connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE    Change status for parameter cellBarred on GNB    exp_status=barred   list_cell_ids=all   timeout=${timeout}
    ...        connection=${connection}    gnb_index=${gnb_index}

    ${is_lte_attach_check_needed}    Set variable if    '${prefer_5g_nr_mode}'=='SA'    ${False}    ${True}
    Retry commercial ue attach if failed    prepare_ue_needed=${False}
    ...    retry_time=1    4G_check=${is_lte_attach_check_needed}
    [Teardown]  Run keyword and ignore error    Retry commercial ue detach if failed    ue_index=${ue_index}
