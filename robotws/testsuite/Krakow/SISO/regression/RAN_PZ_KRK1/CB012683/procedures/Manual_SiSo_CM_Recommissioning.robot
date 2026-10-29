*** Settings ***
Documentation
...    Test CB012683 - Manual_SiSo_CM_Recommissioning
...    author/contact: damian.silkowski@nokia.com, agnieszka.bylica@nokia.com, julia.luszcz@nokia.com


*** Keywords ***
Manual_SiSo_CM_Recommissioning
    [Arguments]     ${parameters_to_change}     ${incorrect_parameters}
    ${len}=     Get Length              ${parameters_to_change}
    FOR    ${idx}    IN RANGE    ${len}
        Change Parameters Set           parameters_set=@{parameters_to_change}[${idx}]
        gnbscf.Activate Plan
        Verify Parameters Change        parameters_set=@{parameters_to_change}[${idx}]
        Wait For Site To Be onAir
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

Change_Parameters_Set
    [Arguments]     ${parameters_set}
    FOR    ${parameter}    IN     @{parameters_set}
        gnbscf.Change Parameter   dist_name=${parameter}[dist_name]
        ...                       parameter=${parameter}[parameter]
        ...                       value=${parameter}[value]
    END

Verify_Parameters_Change
    [Arguments]     ${parameters_set}
    FOR    ${parameter}    IN    @{parameters_set}
        gnbscf.Verify Parameter After Change    dist_name=${parameter}[dist_name]
        ...                                     parameter=${parameter}[parameter]
        ...                                     value=${parameter}[verification_value]
    END