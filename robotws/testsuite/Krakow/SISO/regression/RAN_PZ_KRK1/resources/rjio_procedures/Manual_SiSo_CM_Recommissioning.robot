*** Settings ***
Documentation
...    Test CB012524 - General_SiSo_RF_module_reset_from_WebUI_with_L3_call
...    author/contact: damian.silkowski@nokia.com, agnieszka.bylica@nokia.com


*** Keywords ***
Manual_SiSo_CM_Recommissioning
    [Arguments]     ${parameters_to_change}     ${incorrect_parameters}
    ${len}=     Get Length              ${parameters_to_change}
    FOR    ${idx}    IN RANGE    ${len}
        Change Parameters Set           parameters_set=@{parameters_to_change}[${idx}]
        Verify Parameters Change        parameters_set=@{parameters_to_change}[${idx}]
        Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
    END
    gnblog.Save And Verify Report
    FOR    ${parameter}    IN    @{incorrect_parameters}
        gnbscf.Verify Parameters Value Can Be Set Incorrectly   dist_name=${parameter}[dist_name]
        ...                                                     parameter=${parameter}[parameter]
        ...                                                     value=${parameter}[value]
        gnbscf.Verify Parameter After Change                    dist_name=${parameter}[dist_name]
        ...                                                     parameter=${parameter}[parameter]
        ...                                                     value=${parameter}[verification_value]
    END
    Prepare Ue
    Run L3 call on all cells one by one and verify tput    sheetname_in_tput_table=SiSo CM Recommissioning
    Verify If All Radio Modules Online

Change_Parameters_Set
    [Arguments]     ${parameters_set}
    Log to console    Setting parameters: ${parameters_set}
    Set Local Variable    ${should_trigger_reset}    ${False}

    FOR    ${parameter}    IN     @{parameters_set}
        gnbscf.Change Parameter   dist_name=${parameter}[dist_name]
        ...                       parameter=${parameter}[parameter]
        ...                       value=${parameter}[value]
        IF    ${parameter}[online] == ${False}
            Set Local Variable    ${should_trigger_reset}    ${True}
        END
    END
    Log to console    Activating plan...
    gnbscf.Activate Plan
    Log to console    Plan activated

    IF    ${should_trigger_reset} == ${True}
        Wait Until Keyword Succeeds    60s    10s    Verify gNB Does Not Respond
        Log to console    Waiting for onAir...
        Wait Until Keyword Succeeds    900s    30s    gnbcell.Verify All Cells Are Onair
    END


Verify_Parameters_Change
    [Arguments]     ${parameters_set}
    Log to console    Verifying parameters changed to values: ${parameters_set}
    FOR    ${parameter}    IN    @{parameters_set}
        gnbscf.Verify Parameter After Change    dist_name=${parameter}[dist_name]
        ...                                     parameter=${parameter}[parameter]
        ...                                     value=${parameter}[verification_value]
    END
    Log to console    Params verification finished!
