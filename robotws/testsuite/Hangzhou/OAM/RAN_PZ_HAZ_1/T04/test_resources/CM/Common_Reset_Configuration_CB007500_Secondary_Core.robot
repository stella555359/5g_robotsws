*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Library           taf.fdsw.rc    WITH NAME    fdswrc
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           String

*** Variables ***
${remove_operator_certificates}     False
${remove_user_account_credentials}    False
${repair_center_reset}    False
${fdsw_ip}    192.168.255.129
${fdsw_username}    Nemuadmin
${fdsw_password}    nemuuser
${timeout}     500
${active_SW_version}    None

*** Keywords ***
Common_Reset_Configuration_CB007500_Secondary_Core
    [Documentation]    Test for performing configuration reset on secondary core only when it's already on CB007500 fdsw mode.
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    The main steps performed for the test are:

    ...    Pass criteria: config reset successful
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.04.2023 - New added
    Set Tags    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    AUTHOR-lixkang@nokia-sbell.com
    Log To Console    Common_Reset_Configuration_CB007500_Secondary_Core
    Reset Configuration After CB007500

Reset Configuration After CB007500
    Log To Console    Start Reset Configuration After CB007500 On Secondary Core
    ${sw_inventory}    fdswrc.Get All Software Inventory    connection=fdswcon
    Log To Console    ${sw_inventory}
    ${target_slot_id}   fdswrc.Get Active SW Partition    connection=fdswcon
    ${rollback_restType_tmp}    Get Proper Reset Type
    ...    ${remove_operator_certificates}    ${remove_user_account_credentials}    ${repair_center_reset}
    ${DR_SWversion}    Get D&R Mode SW Version    ${sw_inventory}
    ${fdswRelCurrent}    Get Regexp Matches    ${DR_SWversion}      FDSW+\\d{2}\\w{1}
    ${oldRelease}    Create List     FDSW23B    FDSW23C
    ${status}    Run Keyword And Return Status    Should Contain    ${oldRelease}    ${fdswRelCurrent[0]}
    ${rollback_restType}    Run Keyword If    ${status}    Set Variable    ${rollback_restType_tmp}
    ...    ELSE    Create List    ${rollback_restType_tmp}
    fdswrc.Software Rollback    sw_slot_id=${target_slot_id}    reset_type=${rollback_restType}    timeout=${timeout}    connection=fdswcon

Get Proper Reset Type
    [Arguments]    ${remove_operator_certificates}=False    ${remove_user_account_credentials}=False    ${repair_center_reset}=False
    ${reset_type}    Set Variable If    ${repair_center_reset}    RepairCenterReset
    ...    ${remove_operator_certificates} and ${remove_user_account_credentials}   WithCertsAndCredsFromActive
    ...    ${remove_operator_certificates}    WithCertFromActive
    ...    ${remove_user_account_credentials}    WithCredsFromActive
    ...    FromActive
    [Return]    ${reset_type}

Get D&R Mode SW Version
    [Arguments]    ${sw_inventory}
    ${version}    Set Variable
    FOR    ${item}    IN     @{sw_inventory["slots"]}
        ${version}    Run Keyword If    "${item["mode"]}"=="D&R"    Set Variable    ${item["version"]}
        Exit For Loop If    "${item["mode"]}"=="D&R"
    END
    [Return]    ${version}

TC Setup
    Wait Until Keyword Succeeds    5m    2m    fdswrc.Connect To    ${fdsw_ip}    443    ${fdsw_username}    ${fdsw_password}    name=fdswcon

TC Teardown
    run keyword and ignore error    Wait Until Keyword Succeeds    6m    30s    coam.Setup Admin    bts_host=192.168.255.129
    ...                                                                                             bts_port=443   use_ssl=True
    run keyword and ignore error    Wait Until Keyword Succeeds    6m    30s    coam.Setup Admin    bts_host=192.168.255.119
    ...                                                                                             bts_port=443   use_ssl=True
    ${btsState}    coam.Get Mrbts State    timeout=30s
    #Should Be Equal As Strings     ${btsState}    NotCommissioned
    ${current_sw}    Wait Until Keyword Succeeds    6x    10s    coam.Get SW Version
    Should Be Equal As Strings     ${current_sw}    ${active_SW_version}