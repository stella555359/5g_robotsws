*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04


Library           taf.config.scf.interface.scf     WITH NAME   scf
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Keywords ***
################ common modify scf ######################
Remove Multiple Mo
    [Arguments]  ${dist_name_list}
    FOR  ${dist_name}  IN  @{dist_name_list}
        scf.remove_mo_with_descendant_mos    dist_name=${dist_name}
    END

Clone Multiple Mo
    [Arguments]  ${source_dist_name_list}     ${target_dist_name_list}
    ${list_len}    Get Length    ${source_dist_name_list}
    FOR  ${item}  IN RANGE  0  ${list_len}
        scf.clone_mo_with_descendant_mos    source_mo_dist_name=${source_dist_name_list}[${item}]
        ...    target_mo_dist_name=${target_dist_name_list}[${item}]
    END

Modify Ordinary Parameter Value
    [Arguments]  ${dist_name_list}    ${p_name_list}    ${new_value_list}
    ${list_len}    Get Length    ${new_value_list}
    FOR  ${item}  IN RANGE  0  ${list_len}
        scf.modify_scf_element     dist_name=${dist_name_list}[${item}]    p_name=${p_name_list}[${item}]     value=${new_value_list}[${item}]
    END

Modify Structure Parameter Value With P_name
    [Arguments]  ${dist_name_list}    ${list_name_list}    ${p_name_list}    ${value_list}    ${index_list}
    ${list_len}    Get Length    ${dist_name_list}
    FOR  ${item}  IN RANGE  0  ${list_len}
        scf.modify_scf_element    dist_name=${dist_name_list}[${item}]    list_name=${list_name_list}[${item}]    p_name=${p_name_list}[${item}]
        ...    value=${value_list}[${item}]    index=${index_list}[${item}]
    END

Modify Structure Parameter Value Without P_name
    [Arguments]  ${dist_name_list}    ${list_name_list}    ${value_list}    ${index_list}
    ${list_len}    Get Length    ${dist_name_list}
    FOR  ${item}  IN RANGE  0  ${list_len}
        scf.modify_scf_element    dist_name=${dist_name_list}[${item}]    list_name=${list_name_list}[${item}]
        ...    value=${value_list}[${item}]    index=${index_list}[${item}]
    END

Add Structure Elements Without P_name
    [Arguments]  ${dist_name_list}    ${list_name_list}    ${elements_list}
    ${list_len}    Get Length    ${dist_name_list}
    FOR  ${item}  IN RANGE  0  ${list_len}
        scf.add_elements_to_list    dist_name=${dist_name_list}[${item}]    list_name=${list_name_list}[${item}]
        ...    elements=${elements_list}[${item}]
    END

Add New Structure
    [Arguments]  ${dist_name_list}    ${list_name_list}    ${struct_para_list}
    FOR  ${item}  IN RANGE  0  ${list_len}
        scf.add_list_to_scf    dist_name=${dist_name_list}[${item}]    list_name=${list_name_list}[${item}]
        scf.add_item_to_list    dist_name=${dist_name_list}[${item}]    list_name=${list_name_list}[${item}]
        ...    elements=${struct_para_list}[${item}]
    END

################## logic common KW ####################
Generate Mo distname ID
    [Arguments]  ${dist_name}    ${ID_list}
    ${dist_name_list}   Create List
    FOR  ${ID}  IN  @{ID_list}
        ${dist_name_tmp}    Catenate  SEPARATOR=-    ${dist_name}    ${ID}
        Append to List  ${dist_name_list}  ${dist_name_tmp}
    END
    [Return]  ${dist_name_list}

Generate Corresponding Mo distname
    [Arguments]  ${dist_list}    ${ID_list}
    ${dist_name_list}   Create List
    FOR  ${dist_name}  IN  @{dist_list}
        ${dist_name_list_tmp}    Generate Mo distname ID    dist_name=${dist_name}    ID_list=${ID_list}
        Append to List  ${dist_name_list}  @{dist_name_list_tmp}
    END
    [Return]  ${dist_name_list}

Generate Parameter With Same P_name On same Father Mo
    [Arguments]  ${dist_name}    ${id_list}    ${p_name}
    ${dist_name_list}    Generate Mo distname ID    dist_name=${dist_name}    ID_list=${id_list}
    ${p_name_list}   Create List
    ${list_len}    Get length    ${id_list}
    FOR    ${item}    IN RANGE  0  ${list_len}
        Append to list    ${p_name_list}    ${p_name}
    END
    [Return]  ${dist_name_list}    ${p_name_list}

Generate Parameter With Same P_name On Diff Father Mo
    [Arguments]  ${f_dist_name}    ${f_id_list}    ${c_dist_name}    ${c_id_list}    ${p_name}
    ${dist_name_list}    Create List
    ${p_name_list}   Create List
    ${f_dist_name_list}    Generate Mo distname ID    dist_name=${f_dist_name}    ID_list=${f_id_list}
    ${list_len}    Get length    ${f_id_list}
    FOR  ${item}  IN RANGE  0    ${list_len}
        ${new_dist_name}    Catenate  SEPARATOR=/    ${f_dist_name_list}[${item}]    ${c_dist_name}
        ${dist_name_list_tmp}    ${p_name_list_tmp}    Generate Parameter With Same P_name On same Father Mo    dist_name=${new_dist_name}
        ...    id_list=${c_id_list}    p_name=${p_name}
        Append to list    ${p_name_list}    @{p_name_list_tmp}
        Append to list    ${dist_name_list}    @{dist_name_list_tmp}
    END
    [Return]  ${dist_name_list}    ${p_name_list}

Modify Parameter With Same list_name And Empty p_name
    [Arguments]  ${dist_name}    ${list_name}    ${id_list}    ${value_list}    ${index_id}
    ${list_len}    Get length    ${id_list}
    ${index_id_list}    Create List
    ${list_name_list}    Create List
    FOR  ${item}  IN RANGE  0   ${list_len}
        Append to list    ${index_id_list}    ${index_id}
        Append to list    ${list_name_list}    ${list_name}
    END
    ${dist_name_list}    Generate Mo distname ID    dist_name=${dist_name}    ID_list=${id_list}
    Modify Structure Parameter Value Without P_name    dist_name_list=${dist_name_list}    list_name_list=${list_name_list}
    ...    value_list=${value_list}    index_list=${index_id_list}

Modify Parameter With Same list_name With p_name
    [Arguments]  ${dist_name}    ${list_name}    ${id_list}    ${value_list}    ${index_id}    ${p_name}
    ${list_len}    Get length    ${id_list}
    ${index_id_list}    Create List
    ${list_name_list}    Create List
    ${p_name_list}    Create List
    FOR  ${item}  IN RANGE  0   ${list_len}
        Append to list    ${index_id_list}    ${index_id}
        Append to list    ${list_name_list}    ${list_name}
        Append to list    ${p_name_list}    ${p_name}
    END
    ${dist_name_list}    Generate Mo distname ID    dist_name=${dist_name}    ID_list=${id_list}
    Modify Structure Parameter Value With P_name    dist_name_list=${dist_name_list}    list_name_list=${list_name_list}
    ...    p_name_list=${p_name_list}    value_list=${value_list}    index_list=${index_id_list}

Generate Same Vlaue List
    [Arguments]  ${value}    ${count}
    ${value_list}    Create List
    FOR  ${item}  IN RANGE  0  ${count}
        Append to list    ${value_list}    ${value}
    END
    [Return]  ${value_list}

Generate the LCELNR Corresponding RMOD
    [Arguments]    ${CHANNEL_id_list}   ${dist_name_list}    ${p_name_list}    ${rmod_id}
    ${LCELNR_Rmod_value_list}    Create List
    ${list_len}    get length    ${CHANNEL_id_list}
    FOR  ${item}  IN RANGE  0   ${list_len}
        ${p_name_value}    scf.get_value_from_scf    dist_name=${dist_name_list}[${item}]    p_name=${p_name_list}[${item}]
        ${new_value}=    Replace String Using Regexp    ${p_name_value}    RMOD-[A-Za-z0-9]*\    RMOD-${rmod_id}
        Append to list    ${LCELNR_Rmod_value_list}    ${new_value}
    END
    [Return]  ${LCELNR_Rmod_value_list}

Generate the bwpDN Corresponding value
    [Arguments]  ${dist_name_list}    ${old_value}    ${new_value}    ${index}
    ${new_p_name_value_list}    Create List
    FOR  ${dist_name}  IN  @{dist_name_list}
        ${p_name_value}    scf.get_value_from_scf    dist_name=${dist_name}    p_name=bwpDN    list_name=cellBwpList    index=${index}
        ${new_p_name_value}=    Replace String Using Regexp    ${p_name_value}    BWP_PROFILE-${old_value}*\    BWP_PROFILE-${new_value}
        Append to list    ${new_p_name_value_list}    ${new_p_name_value}
    END
    [Return]  ${new_p_name_value_list}

Generate New cell Corresponding RMOD
    [Arguments]  ${rmod_id_list}    ${add_cell_list}    ${CHANNEL_id_list}    ${p_name}=antlDN
    ${dist_name_list}    Create List
    ${p_name_list}    Create List
    ${new_value_list}    Create List
    ${list_len}    Get length    ${rmod_id_list}
    FOR  ${item}  IN RANGE   0  ${list_len}
        ${dist_name}    set variable    ${LCELNR_ID}-${add_cell_list}[${item}]/CHANNELGROUP-1/CHANNEL
        ${dist_name_list_tmp}    ${p_name_list_tmp}    Generate Parameter With Same P_name On same Father Mo    dist_name=${dist_name}
        ...    id_list=${CHANNEL_id_list}    p_name=${p_name}
        ${single_LCELNR_Rmod_value_list}    Generate the LCELNR Corresponding RMOD    CHANNEL_id_list=${CHANNEL_id_list}
        ...    dist_name_list=${dist_name_list_tmp}    p_name_list=${p_name_list_tmp}    rmod_id=${rmod_id_list}[${item}]
        Append to list    ${dist_name_list}    @{dist_name_list_tmp}
        Append to list    ${p_name_list}    @{p_name_list_tmp}
        Append to list    ${new_value_list}    @{single_LCELNR_Rmod_value_list}
    END
    [Return]  ${dist_name_list}    ${p_name_list}    ${new_value_list}

Remove Multiple Mo In Scf
    [Arguments]  ${dist_list}    ${ID_list}
    ${dist_name_list}    Generate Corresponding Mo distname    dist_list=${dist_list}    ID_list=${ID_list}
    Remove Multiple Mo    dist_name_list=${dist_name_list}

Clone Multiple Mo In Scf
    [Arguments]  ${dist_list}    ${source_ID_list}    ${target_ID_list}
    ${source_dist_name_list}    Generate Corresponding Mo distname    dist_list=${dist_list}    ID_list=${source_ID_list}
    ${target_dist_name_list}    Generate Corresponding Mo distname    dist_list=${dist_list}    ID_list=${target_ID_list}
    Clone Multiple Mo    source_dist_name_list=${source_dist_name_list}     target_dist_name_list=${target_dist_name_list}
    [Return]  ${target_dist_name_list}

Generate multiple Parameter With Same P_name
    [Arguments]    ${dist_name_list}    ${p_name_list}    ${all_id_list}    ${new_value_list}
    @{out_dist_name_list}    create list
    @{out_p_name_list}    create list
    @{out_new_value_list}    create list
    ${list_len}    Get length    ${p_name_list}
    FOR  ${i}  IN RANGE  0  ${list_len}
        ${tmp_value}    set variable    ${new_value_list[${i}]}
        ${dist_name_list_tmp}    ${p_name_list_tmp}    Generate Parameter With Same P_name On same Father Mo    dist_name=${dist_name_list}[${i}]
        ...    id_list=${all_id_list}[${i}]    p_name=${p_name_list}[${i}]
        Append to list    ${out_dist_name_list}    @{dist_name_list_tmp}
        Append to list    ${out_p_name_list}    @{p_name_list_tmp}
        Append to list    ${out_new_value_list}   @{tmp_value}
    END
    [Return]  ${out_dist_name_list}    ${out_p_name_list}    ${out_new_value_list}

Generate multiple Parameter With Diff Father Mo
    [Arguments]  ${f_dist_name_list}    ${f_id_list_list}    ${c_dist_name}    ${c_id_list_list}    ${p_name_list}    ${new_value_list}
    @{out_dist_name_list}    create list
    @{out_p_name_list}    create list
    @{out_new_value_list}    create list
    ${list_len}    Get length    ${p_name_list}
    FOR  ${i}  IN RANGE  0  ${list_len}
        ${tmp_value}    set variable    ${new_value_list[${i}]}
        ${dist_name_list_tmp}    ${p_name_list_tmp}    Generate Parameter With Same P_name On Diff Father Mo
        ...    f_dist_name=${f_dist_name_list}[${i}]    f_id_list=${f_id_list_list}[${i}]
        ...    c_dist_name=${c_dist_name}[${i}]    c_id_list=${c_id_list_list}[${i}]    p_name=${p_name_list}[${i}]
        Append to list    ${out_dist_name_list}    @{dist_name_list_tmp}
        Append to list    ${out_p_name_list}    @{p_name_list_tmp}
        Append to list    ${out_new_value_list}    @{tmp_value}
    END
    [Return]  ${out_dist_name_list}    ${out_p_name_list}    ${out_new_value_list}

Modify bwpDN Value
    [Arguments]  ${dist_name}   ${id_list}   ${old_value}    ${new_value}    ${index}
    ${dist_name_list}    Generate Mo distname ID    dist_name=${dist_name}    ID_list=${id_list}
    ${new_p_name_value_list1}    Generate the bwpDN Corresponding value    dist_name_list=${dist_name_list}    old_value=${old_value}
    ...    new_value=${new_value}    index=${index}
    Modify Parameter With Same list_name With p_name    dist_name=${dist_name}    list_name=cellBwpList    id_list=${id_list}
    ...    value_list=${new_p_name_value_list1}    index_id=${index}    p_name=bwpDN
