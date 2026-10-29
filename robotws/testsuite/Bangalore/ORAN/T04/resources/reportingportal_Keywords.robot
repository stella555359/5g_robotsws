*** Settings ***
Documentation       :copyright: Nokia
...                 :author:
...                 :contact:

Library             taf.transport.ssh    WITH NAME    ssh
Library             taf.gnb.oam.coam.admin    WITH NAME    coam.admin
Library             ute_fsmaccess
Library             String


*** Keywords ***
RP Settings
    FSM Access Open Connection
    FSM Access Get eNB HW Version And Set eNB Side
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
    Teardown All Aliases For Enb FSM Access

FSM Access Get eNB HW Version And Set eNB Side
    [Documentation]    Author:    artur.krolak@nokia.com
    [Arguments]    ${alias}=fsm_access
    FSM Access Get eNB HW Version    alias=${alias}
    FSM Access Set eNB Side    alias=${alias}

FSM Access Get eNB HW Version
    [Arguments]    ${alias}=fsm_access
    ${out_hw_version}=    Get Enb Hw Version    alias=${alias}
    Set Suite Variable    ${OUT_HW_VERSION}    ${out_hw_version}
    RETURN    ${out_hw_version}

FSM Access Get Enb Sw Version
    [Arguments]    ${partition}=active
    ...    ${alias}=fsm_access
    ${out_enb_sw}=    Get Enb Sw Version    partition=${partition}
    ...    alias=${alias}
    RETURN    ${out_enb_sw}

FSM Access Open Connection
    [Arguments]    ${alias}=fsm_access
    IF    ${use_diff_bts_IP}
        Setup Enb Fsm Access    host=${non_def_BTS_IP}    alias=${alias}
    ELSE
        Setup Enb Fsm Access    alias=${alias}
    END

FSM Access Get Active And Passive Enb Sw Versions
    ${out_enb_active_sw}=    FSM Access Get Acive Enb Sw Version
    RETURN    ${out_enb_active_sw}

FSM Access Get Acive Enb Sw Version
    ${out_enb_active_sw}=    FSM Access Get Enb Sw Version    partition=active
    Set Suite Variable    ${OUT_ENB_ACTIVE_SW}    ${out_enb_active_sw}
    RETURN    ${out_enb_active_sw}

FSM Access Set eNB Side
    [Arguments]    ${alias}=fsm_access
    ${out_bts_side}=    Execute Command On Enb
    ...    ddal -s ddal_sysinfo_module_get_domain_id 0| tail -c 2
    ...    alias=${alias}
    ${out_bts_side}=    Set Variable If    ('${out_bts_side}'=='1' or '${out_bts_side}'=='0')    1
    ...    ('${out_bts_side}'=='2')    4
    Set Suite Variable    ${OUT_BTS_SIDE}    ${out_bts_side}
    RETURN    ${out_bts_side}

Get BTS SW Active Release
    ${release}=    Fetch From Left    ${OUT_ENB_ACTIVE_SW}    _
    ${branch_check}=    Split string    ${OUT_ENB_ACTIVE_SW}    separator=_    max_split=3
    IF    "${branch_check[2]}"=="9999"
        ${sw_release}=    Set Variable    FL00
    ELSE
        ${sw_release}=    Set Variable    ${release}
    END
    Set Suite Variable    ${sw_release}

Set QC_Tag
    [Documentation]    Author:    kacper.halas@nokia.com
    ...    Maintainer:    kacper.halas@nokia.com, tomasz.blaszczyszyn@nokia.com, dawid.wojciechowski@nokia.com
    ${QC_ID}=    Set Variable    ${${TEST_NAME}}[QC_ID_${sw_release}]
    IF    "${QC_ID}" == "None"
        Log
        ...    -- Set QC_Tag step is for reporting portal purpose only, if this step alone fails, you can update QC manually
        ...    html=true
        ...    console=true
    END
    Set Tags    ${QC_ID}

Set QC_Tag depending on SW version and HW version
    [Documentation]    Author:    dawid.wojciechowski@nokia.com
    ...    Maintainer:    kacper.halas@nokia.com, tomasz.blaszczyszyn@nokia.com
    ${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_${sw_release}_${OUT_HW_VERSION}]
    IF    "${QC_ID}" == "None"
        Log
        ...    -- Set QC_Tag step is for reporting portal purpose only, if this step alone fails, you can update QC manually
        ...    html=true
        ...    console=true
    END
    Set Tags    ${QC_ID}

Set QC_Tag_vdu
    [Documentation]    Author:    kacper.halas@nokia.com
    ...    Maintainer:    kacper.halas@nokia.com, tomasz.blaszczyszyn@nokia.com, dawid.wojciechowski@nokia.com
    ${QC_ID}=    Set Variable    ${${TEST_NAME}}[QC_ID_VDU]
    IF    "${QC_ID}" == "None"
        Log
        ...    -- Set QC_Tag step is for reporting portal purpose only, if this step alone fails, you can update QC manually
        ...    html=true
        ...    console=true
    END
    Set Tags    ${QC_ID}
