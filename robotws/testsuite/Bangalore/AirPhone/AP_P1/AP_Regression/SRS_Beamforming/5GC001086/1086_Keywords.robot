*** Settings ***
Documentation    Contains keywords related to 1086 feature
Resource    ../../Carrier_Aggregation/CA_Common_Keywords.robot


*** Keywords ***
Perform set SRS Beam profile mode and position
    [Arguments]    ${ue_list}    ${testmode}=ue_srs_beam_pos    ${profile_id}=1    ${scell_index}=0
    ...    ${pass_regex}=${EMPTY}    &{kwargs}
    FOR    ${ue_id}    IN    @{ue_list}
        Create UL mimo SRS Beam profile mode    ${profile_id}    &{kwargs}
        Enable UE to testmode    id=${ue_id}    testmode=${testmode}    profile_id=${profile_id}    scell_index=${scell_index}
        ...    pass_regex=${pass_regex}
    END
