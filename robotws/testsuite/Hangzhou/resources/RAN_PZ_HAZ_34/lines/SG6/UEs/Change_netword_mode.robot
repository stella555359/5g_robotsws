*** Settings ***
Documentation    The keyword for change network mode of ue
...              Author: Chen Jun
...              Contact: jun.8.chen@nokia-sbell.com
...              Usefull_link:
...              https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1168008818#taf.ul.mobile.ui.android-SupportedFeatures(v0.11.0)


*** Keywords ***
Change Network Mode Between SA And NSA
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ...    This keyword is tested with QCOM UE, for other UE types, need to do additional adaption
    ...    ${prefer_5g_nr_mode}: Supported values: SA / NSA / NSA+SA / LTE
    ...    if prefer_5g_nr_mode is set to SA: prefer 5G NR mode will set to 'SA Mode', network mode will set to 'NR Only'
    ...    if prefer_5g_nr_mode is set to NSA: prefer 5G NR mode will set to 'NSA Mode', network mode will set to 'NR/LTE'
    ...    if prefer_5g_nr_mode is set to NSA+SA: prefer 5G NR mode will set to 'NSA + SA Mode', network mode will set to 'NR/LTE'
    ...    This keyword need to do precondition after ue software upgrade.
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${is_prepare_ue_needed}=${True}    ${prefer_5g_nr_mode}=SA
    ...    ${network_mode_switch_method}=${tl.ues[${ue_index}].network_mode_switch_method}
    ...    ${mobile_network_text}=${tl.ues[${ue_index}].mobile_network_text}
    ...    ${setting_network_mode_text}=${tl.ues[${ue_index}].setting_network_mode_text}
    Run Keyword If   ${is_prepare_ue_needed}    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    android_common_keyword.Ue attach with index    ue_index=${ue_index}
#    ${5g_nr_mode}    Set Variable If    '${prefer_5g_nr_mode}'=='SA'    SA Mode
#    ...                                 '${prefer_5g_nr_mode}'=='NSA'    NSA Mode
#    ...                                 '${prefer_5g_nr_mode}'=='NSA+SA'    NSA + SA Mode
    ${network_mode}    Set Variable If    '${prefer_5g_nr_mode}'=='SA'    NR only
    ...                                   '${prefer_5g_nr_mode}'=='NSA'    NR/LTE
    ...                                   '${prefer_5g_nr_mode}'=='NSA+SA'    NR/LTE
    ...                                   '${prefer_5g_nr_mode}'=='LTE'    LTE
    ...                                   Un_supported
    ${validate_net_mode_text}    Set Variable If    '${network_mode}'=='NR/LTE'    NR / LTE
    ...                                             '${network_mode}'=='NR only'    NR only
    ...                                             '${network_mode}'=='LTE'    LTE
    ...                                             Un_supported
    ${is_network_mode_as_expected}    Is network mode as expected    exp_net_mode=${validate_net_mode_text}    ue_index=${ue_index}
    ...    network_mode_switch_method=${network_mode_switch_method}    mobile_network_text=${mobile_network_text}
    ...    setting_network_mode_text=${setting_network_mode_text}
    Run Keyword If   ${is_network_mode_as_expected}
    ...    Log To Console    cur network mode is ${network_mode} which is as expected. No need to switch.
#    ${swicth_mode_status}    Run Keyword If    ${is_network_mode_as_expected}==${FALSE}    Run Keyword And Return Status
#    ...    Run Keywords    Wait Until Keyword Succeeds    2X    2s    android_common_keyword.Switch prefer 5G NR mode    5g_nr_mode=${5g_nr_mode}
#    ...    AND    Wait Until Keyword Succeeds    2X    2s    android_common_keyword.Change network mode on UE    net_mode=${network_mode}
#    ...              validate_net_mode_text=${validate_net_mode_text}    ue_index=${ue_index}
#    Run Keyword If    ${is_network_mode_as_expected}==${FALSE}    Run keywords    Should Be True    ${swicth_mode_status}    AND
#    ...    Log To Console    Switch mode to ${prefer_5g_nr_mode} successfully.
    ${swicth_mode_status}    Run Keyword If    ${is_network_mode_as_expected}==${FALSE}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    2X    2s    android_common_keyword.Change network mode on UE    net_mode=${network_mode}
    ...        validate_net_mode_text=${validate_net_mode_text}    ue_index=${ue_index}
    Run Keyword If    ${is_network_mode_as_expected}==${FALSE}    Should Be True    ${swicth_mode_status}
    [Teardown]    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Switch Apn
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ...    This keyword is tested with QCOM UE, for other UE types, need to do additional adaption
    ...    ${apn_address}: specified the mode name e.g 'dxdata2', 'wap2.nokia.com'.
    ...    ${ui_version}: For QCOM it's ${EMPTY}, for other UE type like Huawei, need to fill with specific UI version
    [Arguments]    ${apn_address}    ${ue_index}=${0}   ${ui_version}=${EMPTY}    ${ue_alias}=UE_UI_${ue_index}
    ${status}    Run Keyword And Return Status    Should Contain    ${apn_address}    nokiacom
    ${wap_name}    Run Keyword If    ${status}    Get Substring    ${apn_address}    0    4
    ${apn_address}    Set Variable If    ${status}    ${wap_name}.nokia.com    ${apn_address}
    android_ui.setup    ui_version=${ui_version}    host=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    serial_number=${tl.ues[${ue_index}].serial_number}    alias=${ue_alias}
    android_ui.switch_apn    apn_name=${apn_address}    mobile=${ue_alias}
    [Teardown]    Run Keyword And Ignore Error    android_ui.teardown    mobile=${ue_alias}

Switch 5G NR Mode
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ...    This keyword is tested with QCOM UE, for other UE types, need to do additional adaption
    ...    ${5g_nr_mode}: specified the prefer 5g nr mode name e.g : 'NSA Mode', 'SA Mode', 'NSA + SA Mode'
    [Arguments]    ${ue_type}    ${5g_nr_mode}    ${ue_index}=${0}
    Run Keyword And Ignore Error    android_common_keyword.Ue attach with index    ue_index=${ue_index}
    Wait Until Keyword Succeeds    2X    2s    android_common_keyword.Switch prefer 5G NR mode    5g_nr_mode=${5g_nr_mode}
    [Teardown]    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Change Network Mode For Samsung
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ...    This keyword is tested with Samsung S22 UE, for other UE types, need to do additional adaption
    ...    ${netword_mode}: Supported values: 5G/LTE/3G/2G (auto connect), LTE/3G/2G (auto connect)
    ...    if prefer_5g_nr_mode is set to SA: prefer 5G NR mode will set to 'SA Mode', network mode will set to 'NR Only'
    ...    if prefer_5g_nr_mode is set to NSA: prefer 5G NR mode will set to 'NSA Mode', network mode will set to 'NR/LTE'
    ...    if prefer_5g_nr_mode is set to NSA+SA: prefer 5G NR mode will set to 'NSA + SA Mode', network mode will set to 'NR/LTE'
    ...    This keyword need to do precondition after ue software upgrade.
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${gnb_index}=${0}
    ...            ${hwcheck_index}=${1}    ${du_index}=0    ${power_reset}=False
    ...            ${is_prepare_ue_needed}=${True}    ${netword_mode}=5G
    ...            ${network_mode_switch_method}=${tl.ues[${ue_index}].network_mode_switch_method}
    ...            ${mobile_network_text}=${tl.ues[${ue_index}].mobile_network_text}
    ...            ${setting_network_mode_text}=${tl.ues[${ue_index}].setting_network_mode_text}
    ...            ${cap_index}=${0}    ${ue_cap}=${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ...            ${whether_do_ute_require_ue}=${True}
    Run Keyword If   ${is_prepare_ue_needed}    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    power_ue.UE Attach    ue_type=${ue_type}
    ...                                                   ue_index=${ue_index}
    ...                                                   gnb_index=${gnb_index}
    ...                                                   hwcheck_index=${hwcheck_index}
    ...                                                   du_index=${du_index}
    ...                                                   power_reset=${power_reset}
    ${network_mode}    Set Variable If    '${netword_mode}'=='5G'    5G/LTE/3G/2G (auto connect)    LTE/3G/2G (auto connect)
    Run Keyword If   ${whether_do_ute_require_ue}    ute_ue.require Ue    ue_alias=alias_${ue_index}    capabilities=${ue_cap}
    ${swicth_mode_status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    2X    2s    ute_ue.change_network_mode    alias_${ue_index}    ${network_mode}
    ...        network_mode_switch_method=${network_mode_switch_method}    mobile_network_text=${mobile_network_text}
    ...        setting_network_mode_text=${setting_network_mode_text}
    Run Keyword If    ${swicth_mode_status}    Log To Console    Switch mode to ${network_mode} successfully.
    Should Be True    ${swicth_mode_status}
    [Teardown]    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}