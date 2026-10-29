*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Manual_SiSo_CM_Recommissionin test case

Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB012614/resources/Keywords.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Library     taf.ue    WITH NAME    ute_ue
Variables   ./data_transfer_configuration_9.py

*** Keywords ***
Manual_SiSo_CM_Recommissioning
    [Arguments]     ${parameters_to_change}     ${incorrect_parameters}
    ${len}=     Get Length              ${parameters_to_change}
    FOR    ${idx}    IN RANGE    ${len}
        Change Parameters Set           parameters_set=@{parameters_to_change}[${idx}]
        gnbscf.Activate Plan
        Wait For Site To Be onAir
        Verify Parameters Change        parameters_set=@{parameters_to_change}[${idx}]
        Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
        # Perform Bidirectional Data Transfer With Throughput Verification on all cells
        # ...    data_transfer_configuration=${data_transfer_configuration_9}
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
    Verify If All Radio Modules Online
    Perform Bidirectional Data Transfer With Throughput Verification on all cells
    ...    data_transfer_configuration=${data_transfer_configuration_9}

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
