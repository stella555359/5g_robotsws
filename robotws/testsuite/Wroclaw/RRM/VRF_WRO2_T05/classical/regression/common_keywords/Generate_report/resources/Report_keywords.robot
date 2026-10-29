*** Settings ***
Documentation    Keywords for report creation.

*** Keywords ***

Get data from list
    [Arguments]    ${xml_output}    ${target_release}    ${actal_auto_lvl}
    ${xml_1}    get from dictionary    ${xml_output}    results
    ${tmp_list}=     create list
    FOR    ${element}    IN    @{xml_1}
        ${release}    get from dictionary    ${element}    release
        ${det_auto_lvl}    get from dictionary    ${element}    det_auto_lvl
        log    ${release}
        run keyword if    '${release}'=='${target_release}'    run keyword if    '${det_auto_lvl}'=='${actal_auto_lvl}'
        ...   append to list    ${tmp_list}    ${element}
    END
    [Return]    ${tmp_list}

Prepare list of TCs
    [Arguments]    ${list_sorted_TC}
    ${feature_list}=     create list
    FOR    ${element1}    IN    @{list_sorted_TC}
        ${feature}    get from dictionary    ${element1}    feature
        append to list    ${feature_list}    ${feature}
    END
    ${feature_list_clear}    remove duplicates    ${feature_list}
    ${final_features_list}=    create list
    FOR    ${element3}    IN    @{feature_list_clear}
        ${new_dict}=    create dictionary
        ${values}    count values in list    ${feature_list}    ${element3}
        set to dictionary    ${new_dict}    feature=${element3}    not_automated=${values}
        append to list      ${final_features_list}    ${new_dict}
    END
    [Return]    ${final_features_list}
