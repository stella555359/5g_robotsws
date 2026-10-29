*** Settings ***
Documentation
...  **Useful keyword for Android Ue manipulation**

*** Keywords ***
Require UEs
    [Documentation]    Sets up the UEs by requiring them with the specified capabilities.
    [Arguments]    ${ues_alias}    ${ues_capabilities}
    Log    ues capabilities: ${ues_capabilities}
    FOR    ${index}    ${ue_alias}    IN ENUMERATE    @{UEs_alias}
        taf_ue.require_ue    ue_alias=${ue_alias}    capabilities=${capabilities[${index}]}
    END

Attach UEs
    [Documentation]    Attaches the UEs to the network.
    [Arguments]    ${ues_alias}
    FOR    ${ue_alias}    IN    @{ues_alias}
        taf_ue.attach_ue    ue_alias=${ue_alias}
    END

Reboot UEs
    [Documentation]    Reboots the UEs, ignoring errors.
    [Arguments]    ${UEs_alias}
    FOR    ${ue_alias}    IN    @{ues_alias}
        Run Keyword And Ignore Error    taf_ue.reboot_ue    ${ue_alias}    timeout=90
    END

Detach UEs
    [Documentation]    Detaches the UEs, ignoring errors.
    [Arguments]    ${UEs_alias}
    FOR    ${ue_alias}    IN    @{ues_alias}
        Run Keyword And Ignore Error    taf_ue.detach_ue    ue_alias=${ue_alias}
    END

Get UEs Infos
    [Documentation]    Get the UEs infos.
    [Arguments]    ${UEs_alias}
    FOR    ${ue_alias}    IN    @{ues_alias}
        ${UE_INFO}=    taf_ue.Get UE Info    ${ue_alias}    ALL
        Log To Console      ${ue_alias} Info: ${UE_INFO}   Console=True
    END




