*** Settings ***
Documentation    Commissioning keywords for CB011006 B03



*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]
Initial commissioning for IWK16
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${distName_BWP_Init_tmp}=     gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{1}/
    sort list    ${distName_BWP_Init_tmp}
    ${distName_BWP_Dedi}=     gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}
    sort list    ${distName_BWP_Dedi}

    # Clone and rename initial FDD BWP profile. It will be used by the second FDD cell
    ${distName_BWP_Init_cell1}=    Get Substring    ${distName_BWP_Init_tmp[1]}    0    -1
    ${distName_BWP_Init_cell2}=    Replace String    ${distName_BWP_Init_cell1}    4    5
    scf.clone_mo_with_descendant_mos    source_mo_dist_name=${distName_BWP_Init_cell1}    target_mo_dist_name=${distName_BWP_Init_cell2}

    # Map second FDD cell to new BWP profile
    Set List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}    list_name=cellBwpList
    ${cellBwpList_init_bwp}=  create dictionary
    ...    actPdcchCceFragmentControl           false
    ...    actUpperThrAckNackFiltering          false
    ...    actUpperThrAckNackHrFiltering        false
    ...    bwpDN                                ${distName_BWP_Init_cell2}
    ...    cellBwpId                            0
    ...    pdcchResourcePreference              peakRate
    scf.add_item_to_list    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}    list_name=cellBwpList   elements=${cellBwpList_init_bwp}
    ${cellBwpList_dedi_bwp}=  create dictionary
    ...    actPdcchCceFragmentControl           false
    ...    actUpperThrAckNackFiltering          false
    ...    actUpperThrAckNackHrFiltering        false
    ...    bwpDN                                ${distName_BWP_Dedi[0]}
    ...    cellBwpId                            1
    ...    pdcchResourcePreference              peakRate
    scf.add_item_to_list    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}    list_name=cellBwpList   elements=${cellBwpList_dedi_bwp}

    # Apply preconditions from test description for first FDD cell
    FOR    ${dist_name}                                       ${p_name}                      ${value}         IN
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actPRBBlanking                 true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                nbrOfBlankedPRBsLowEdgeUL      27
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    ${bwpDN_init}=    get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    list_name=cellBwpList    p_name=bwpDN    index=0
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbStartUl    value=crb27
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbSizeUl     value=n243