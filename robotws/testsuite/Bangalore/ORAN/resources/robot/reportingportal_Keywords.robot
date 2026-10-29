*** Settings ***
Documentation    :copyright: Nokia
...              :author:
...              :contact:


Library      taf.gnb.oam.coam.admin    WITH NAME    coam.admin

*** Keywords ***
RP Settings
    FSM Access Teardown
    FSM Access Open Connection
    FSM Access Get eNB HW Version And Set eNB Side
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
FSM Access Get eNB HW Version And Set eNB Side
    [Arguments]    ${alias}=fsm_access
    [Documentation]    Author:    artur.krolak@nokia.com
    FSM Access Get eNB HW Version    alias=${alias}
    FSM Access Set eNB Side    alias=${alias}

FSM Access Get eNB HW Version
    [Arguments]    ${alias}=fsm_access
    ${out_hw_version}=    Get Enb Hw Version    alias=${alias}
    Set Suite Variable    ${OUT_HW_VERSION}    ${out_hw_version}
    [Return]    ${out_hw_version}

FSM Access Teardown
    Teardown All Aliases For Enb Fsmaccess

FSM Access Get Enb Sw Version
    [Arguments]    ${partition}=active
    ...            ${alias}=fsm_access
    ${out_enb_sw}=    Get Enb Sw Version    partition=${partition}
    ...                                     alias=${alias}
    [Return]    ${out_enb_sw}

FSM Access Open Connection
    [Arguments]    ${alias}=fsm_access
    Setup Enb Fsm Access    alias=${alias}

FSM Access Get Active And Passive Enb Sw Versions
    ${out_enb_active_sw}=    FSM Access Get Acive Enb Sw Version
    [Return]    ${out_enb_active_sw}

FSM Access Get Acive Enb Sw Version
    ${out_enb_active_sw}=    FSM Access Get Enb Sw Version    partition=active
    Set Suite Variable    ${OUT_ENB_ACTIVE_SW}    ${out_enb_active_sw}
    [Return]    ${out_enb_active_sw}

FSM Access Set eNB Side
    [Arguments]    ${alias}=fsm_access
    ${out_bts_side}=    Execute Command On Enb    ddal -s ddal_sysinfo_module_get_domain_id 0| tail -c 2    alias=${alias}
    ${out_bts_side}=    Set Variable If    ('${out_bts_side}'=='1' or '${out_bts_side}'=='0')    1
    ...                                    ('${out_bts_side}'=='2')    4
    Set Suite Variable    ${OUT_BTS_SIDE}    ${out_bts_side}
    [Return]    ${out_bts_side}

Get BTS SW Active Release
    ${release}=    Fetch From Left    ${OUT_ENB_ACTIVE_SW}    _
    ${branch_check}=    Split string    ${OUT_ENB_ACTIVE_SW}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    FL00
    ...     ELSE    Set Variable    ${release}
    Set Suite Variable    ${sw_release}

Set QC_Tag
    [Documentation]    Author:    kacper.halas@nokia.com
    ...                Maintainer:    kacper.halas@nokia.com, tomasz.blaszczyszyn@nokia.com, dawid.wojciechowski@nokia.com
    ${QC_ID}=    Set Variable    ${${TEST_NAME}}[QC_ID_${sw_release}]
    Set Tags    ${QC_ID}

Set QC_Tag depending on SW version and HW version
    [Documentation]    Author:    dawid.wojciechowski@nokia.com
    ...                Maintainer:    kacper.halas@nokia.com, tomasz.blaszczyszyn@nokia.com
    ${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_${sw_release}_${OUT_HW_VERSION}]
    Set Tags    ${QC_ID}