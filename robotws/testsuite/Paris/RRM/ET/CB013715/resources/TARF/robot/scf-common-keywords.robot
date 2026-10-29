*** Settings ***
Documentation    Common keywords for scf managements

Library     taf.config.scf    WITH NAME    scf

Resource    Scenario-Common-Keywords.robot
Resource    testline-Keywords.robot

*** Keywords ***
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Activate multiple BWPs feature
    ${distName_NRBTS}=      Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    Set Element     dist_name=${distName_NRBTS[0]}    p_name=actMultipleDedicatedBWPs    value=true


Change small BWP
    [Arguments]  ${distName_FDD_cell}  ${n_value}
    ${bwpDN_init}=    scf.get_value_from_scf    dist_name=${distName_FDD_cell}    list_name=cellBwpList    p_name=bwpDN    index=0
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthDl    p_name=cRbSizeDl    value=${n_value}
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthDl    p_name=cRbStartDl   value=crb0
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbSizeUl    value=sameAsDl
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbStartUl   value=sameAsDl


Get new BWP for cell
    [Arguments]  ${distName_FDD_cell}

    ${bwpDN_dedicated_list}=    scf.get_all_values_from_scf    dist_name=${distName_FDD_cell}    list_name=cellBwpList    p_name=bwpDN
    ${last_bwpDN_dedicated}=    Get From List    ${bwpDN_dedicated_list}    -1

    ${nr_dedicated_bwp}=    Get Substring  ${last_bwpDN_dedicated}  -2
    ${nr_new_bwp}=    Evaluate    ${nr_dedicated_bwp} + 1
    ${nr_new_bwp}=    Convert To String    ${nr_new_bwp}
    ${bwpDN_dedicated_new}    Replace String    ${last_bwpDN_dedicated}    ${nr_dedicated_bwp}    ${nr_new_bwp}

    ${bwpId_list}=    scf.get_all_values_from_scf    dist_name=${distName_FDD_cell}    list_name=cellBwpList    p_name=cellBwpId
    ${max_cellBwpId}=    Evaluate    max(${bwpId_list})
    ${max_cellBwpId}=    Convert To Integer    ${max_cellBwpId}

    [Return]    ${last_bwpDN_dedicated}  ${bwpDN_dedicated_new}  ${max_cellBwpId}


Map BWP to cell
    [Arguments]  ${distName_FDD_cell}  ${target_bwp_mo}  ${max_cellBwpId}
    # Set Element     dist_name=${distName_FDD_cell}    p_name=msg1FrequencyStart    value=20
    ${item}=  Create Dictionary
    ...    actPdcchCceFragmentControl        false
    ...    actUpperThrAckNackFiltering       false
    ...    actUpperThrAckNackHrFiltering     false
    ...    bwpDN                             ${target_bwp_mo}
    ...    cellBwpId                         ${max_cellBwpId + 1}
    ...    pdcchResourcePreference           peakRate
    scf.add_item_to_list  dist_name=${distName_FDD_cell}  list_name=cellBwpList  elements=${item}


Add BWP
    [Arguments]  ${src_bwp_mo}  ${target_bwp_mo}  ${n_value}  ${bwp_type}=dedicated
    # Clone the dedicated BWP profile
    scf.clone_mo_with_descendant_mos    source_mo_dist_name=${src_bwp_mo}    target_mo_dist_name=${target_bwp_mo}

    ${searchSpace_list}=    scf.get_all_values_from_scf    dist_name=${src_bwp_mo}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...    list_name=searchSpaceDedicated    p_name=searchSpaceId
    ${max_searchSpaceId}=    Evaluate    max(${searchSpace_list})
    ${max_searchSpaceId}=    Convert To Integer    ${max_searchSpaceId}

    # Adapt a few parameters of the BWP clone
    FOR    ${dist_name}                                          ${list_name}       ${p_name}      ${index}  ${value}   IN
    ...    ${target_bwp_mo}/PDCCH-1/PDCCH_CONFIG_COMMON-1  searchSpaceCommon  searchSpaceId  0  ${max_searchSpaceId + 1}
    ...    ${target_bwp_mo}/PDCCH-1/PDCCH_CONFIG_COMMON-1  searchSpaceCommon  searchSpaceId  1  ${max_searchSpaceId + 2}
    ...    ${target_bwp_mo}/PDCCH-1/PDCCH_CONFIG_COMMON-1  searchSpaceCommon  searchSpaceId  2  ${max_searchSpaceId + 3}
    ...    ${target_bwp_mo}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1  searchSpaceDedicated  searchSpaceId  0  ${max_searchSpaceId + 4}
    ...    ${target_bwp_mo}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1  searchSpaceDedicated  searchSpaceId  1  ${max_searchSpaceId + 5}
        scf.modify_scf_element    dist_name=${dist_name}    list_name=${list_name}    p_name=${p_name}    index=${index}    value=${value}
    END

    scf.modify_scf_element    dist_name=${target_bwp_mo}    list_name=locationAndBandwidthDl    p_name=cRbSizeDl    value=${n_value}
    scf.modify_scf_element    dist_name=${target_bwp_mo}    p_name=bwpType    value=${bwp_type}


Add BWP to cell
    [Arguments]  ${distName_FDD_cell}  ${n_value}  ${bwp_type}=dedicated
    ${src_bwp_mo}  ${target_bwp_mo}  ${max_cellBwpId} =    Get new BWP for cell    ${distName_FDD_cell}
    Map BWP to cell  ${distName_FDD_cell}  ${target_bwp_mo}  ${max_cellBwpId}
    Add BWP  ${src_bwp_mo}  ${target_bwp_mo}  ${n_value}  ${bwp_type}


Add power saving BWP to cell
    [Arguments]  ${distName_FDD_cell}  ${n_value}
    Set Element     dist_name=${distName_FDD_cell}    p_name=actPowerSavingBWP    value=true

    Add BWP to cell    ${distName_FDD_cell}    ${n_value}    powerSaving

#-----change BW----------------------------------------------------------------------------------------------------------------------[150 characters]
change BWP to cell
    [Arguments]  ${distName_FDD_cell}  ${n_value}  ${bwp_type}=dedicated
    ${src_bwp_mo}  ${target_bwp_mo}  ${max_cellBwpId} =    Get new BW for cell    ${distName_FDD_cell}
    Map BWP to cell  ${distName_FDD_cell}  ${target_bwp_mo}  ${max_cellBwpId}
    Add BWP  ${src_bwp_mo}  ${target_bwp_mo}  ${n_value}  ${bwp_type}

Get new BW for cell
    [Arguments]  ${distName_FDD_cell}

    ${bwpDN_dedicated_list}=    scf.get_all_values_from_scf    dist_name=${distName_FDD_cell}    list_name=cellBwpList    p_name=bwpDN
    ${last_bwpDN_dedicated}=    Get From List    ${bwpDN_dedicated_list}    -1

    ${nr_dedicated_bwp}=    Get Substring  ${last_bwpDN_dedicated}  -2
    ${nr_new_bwp}=    Evaluate    ${nr_dedicated_bwp} + 1
    ${nr_new_bwp}=    Convert To String    ${nr_new_bwp}
    ${bwpDN_dedicated_new}    Replace String    ${last_bwpDN_dedicated}    ${nr_dedicated_bwp}    ${nr_new_bwp}

    ${bwpId_list}=    scf.get_all_values_from_scf    dist_name=${distName_FDD_cell}    list_name=cellBwpList    p_name=cellBwpId
    ${max_cellBwpId}=    Evaluate    max(${bwpId_list})
    ${max_cellBwpId}=    Convert To Integer    ${max_cellBwpId}

    [Return]    ${last_bwpDN_dedicated}  ${bwpDN_dedicated_new}  ${max_cellBwpId}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Load SCF
    ${scf_file}=    TARF-Keywords.COAM Get SCF
    scf.load scf    ${scf_file}
    [Return]    ${scf_file}


Save SCF, delta commissioning and wait for onair
    [Arguments]  ${scf_file}    ${timeout}=300
    # this will overwrite the saved SCF of the current scenario
    scf.save_scf    ${configuration_directory}/scf_${scenario_name}.xml
    scf.calculate_delta_scf     ${configuration_directory}/scf_${scenario_name}.xml  ${scf_file}  ${configuration_directory}/SCF_delta.json
    Log To Console          Perform delta commissioning...
    ${oam_alias}            connect.Setup OAM http session  node_type=gnb  node_id=0
    admin.Perform Delta Recommissioning
    ...    delta_file=${configuration_directory}/SCF_delta.json
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=${timeout}
    ...    alias=${oam_alias}

    testline-Keywords.Wait until Node to be onair state
