*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

*** Keywords ***
Dc Release For NSA
    [Arguments]    ${first_ue}    ${last_ue}    ${cause}
    FOR    ${ue_id}    IN RANGE    ${first_ue}    ${last_ue}+${1}
        Execute Egate Command And Wait For Data
        ...    cmd=enb_ue_dc_release ue=${ue_id} by=enb cause=${cause} bearer=2
        ...    pass_regexp=UE${ue_id}:  === Bearer-type change from SCG-split to MCG is successful
    END

NSA RLF
    [Arguments]    ${first_ue}    ${last_ue}    ${failure}    ${at}
    FOR    ${ue_id}    IN RANGE    ${first_ue}    ${last_ue}+${1}
        Execute Egate Command And Wait For Data
        ...    cmd=ue_dc_rlf ue=${ue_id} failure_type=${failure} at=${at}
        ...    pass_regexp=UE${ue_id}:  === Bearer-type change from SCG-split to MCG is successful ===
    END
