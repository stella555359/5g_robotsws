*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    The Demo for how to use modify_scf.robot


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/modify_scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${MRBTS_ID}             MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}             NRBTS-${tl.gnbs[0].global_bts_id}
${ENB_LNBTS_ID}         ${MRBTS_ID}/LNBTS-${tl.enbs[0].instance_id}
${LNCEL_ID}             ${ENB_LNBTS_ID}/LNCEL
${LCELL_ID}             ${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL
${LCELNR_ID}            ${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR
${NRCELL_ID}            ${MRBTS_ID}/${NRBTS_ID}/NRCELL
${NRCELLGRP_ID}         ${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP
${NRDU_ID}              ${MRBTS_ID}/${NRBTS_ID}/NRDU-1
@{LTE_dist_name_list1}        ${LNCEL_ID}    ${LCELL_ID}
@{NR_dist_name_list1}         ${LCELNR_ID}    ${NRCELL_ID}    ${NRCELLGRP_ID}
@{nrarfcnUl_list}             373900    373900    373900
@{nrarfcnDl_list}             393760    393760    393760
@{Rmod_id_list}               ${1}    ${5}    ${6}
@{CHANNEL_id_list}            ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
@{copy_NR_cell_list}          ${4}    ${4}    ${4}
@{NR_cell_list}               ${1}    ${2}    ${3}
@{NR_cell_list1}              ${4}    ${5}    ${6}
@{LTE_cell_list}              ${2}    ${6}    ${10}
@{NR_physCellId}              ${218}    ${219}    ${220}
@{freqBandIndicatorNR}        ${2}    ${2}    ${2}
@{chbw_list}                  40MHz    40MHz    40MHz
@{i_new_value_list1}          ${NR_cell_list}    ${NR_physCellId}    ${freqBandIndicatorNR}
@{mo_name_list1}              ${NRCELL_ID}    ${NRCELL_ID}    ${NRCELL_ID}
@{all_id_list1}               ${NR_cell_list}    ${NR_cell_list}    ${NR_cell_list}
@{f_dist_name_list1}          ${NRCELL_ID}    ${NRCELL_ID}
@{f_id_list_list1}            ${NR_cell_list}    ${NR_cell_list}
@{c_dist_name1}               NRCELL_FDD    NRCELL_FDD
@{c_id_list_list1}            ${CHANNEL_id_list[0:1]}    ${CHANNEL_id_list[0:1]}
@{i_pname_list1}              lcrId     physCellId    freqBandIndicatorNR
@{i_pname_list2}              nrarfcnDl     nrarfcnUl
@{i_pname_list3}              chBwDl    chBwUl
@{i_new_value_list2}          ${nrarfcnDl_list}    ${nrarfcnUl_list}
@{i_new_value_list3}          ${chbw_list}    ${chbw_list}
@{f_id_list_list2}            ${NR_cell_list1}    ${NR_cell_list1}
${RMOD_name}                  ${MRBTS_ID}/EQM-1/APEQM-1/RMOD
@{empty_list}
${default_scf}                ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00.xml



*** Test Cases ***
[1]Test1
    Demo A to C    new_scf_path=${output_dir}/new1.xml

[1]Test2
    Demo A to B    new_scf_path=${output_dir}/new2.xml


*** Keywords ***
#################### case Demo KW #########################
Generate Common Parameter For Add NRcell
    [Arguments]    ${rmod_id_list}=${Rmod_id_list}    ${add_cell_list}=${NR_cell_list}    ${CHANNEL_id_list}=${CHANNEL_id_list}
    ...    ${i_dist_name_list1}=${mo_name_list1}    ${i_p_name_list1}=${i_pname_list1}    ${id_list1}=${all_id_list1}
    ...    ${i_new_value_list1}=${i_new_value_list1}    ${f_dist_name_list}=${f_dist_name_list1}    ${f_id_list_list}=${f_id_list_list1}
    ...    ${c_dist_name}=${c_dist_name1}    ${c_id_list_list}=${c_id_list_list1}    ${i_p_name_list2}=${i_pname_list2}
    ...    ${i_new_value_list2}=${i_new_value_list2}
    @{dist_name_list}    create list
    @{p_name_list}    create list
    @{new_value_list}    create list
    ############ modify cell Corresponding RMOD ##############
    ${dist_name_list1}    ${p_name_list1}    ${new_value_list1}    Generate New cell Corresponding RMOD    rmod_id_list=${rmod_id_list}
    ...    add_cell_list=${add_cell_list}    CHANNEL_id_list=${CHANNEL_id_list}    p_name=antlDN
    Append to list    ${dist_name_list}    @{dist_name_list1}
    Append to list    ${p_name_list}    @{p_name_list1}
    Append to list    ${new_value_list}    @{new_value_list1}
    ############ modify  prioritizedRAT ##########################
    Append to list    ${dist_name_list}    ${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    Append to list    ${p_name_list}    prioritizedRAT
    Append to list    ${new_value_list}    NR
    ############ modify lcrid, pyhscellID,  freqBandIndicatorNR ##
    ${dist_name_list2}    ${p_name_list2}    ${new_value_list2}    Generate multiple Parameter With Same P_name
    ...    dist_name_list=${i_dist_name_list1}    p_name_list=${i_p_name_list1}    all_id_list=${id_list1}    new_value_list=${i_new_value_list1}
    Append to list    ${dist_name_list}    @{dist_name_list2}
    Append to list    ${p_name_list}    @{p_name_list2}
    Append to list    ${new_value_list}    @{new_value_list2}
    ############ modify lcrid, pyhscellID,  freqBandIndicatorNR ##
    ${dist_name_list3}    ${p_name_list3}    ${new_value_list3}    Generate multiple Parameter With Diff Father Mo
    ...    f_dist_name_list=${f_dist_name_list}    f_id_list_list=${f_id_list_list}    c_dist_name=${c_dist_name}
    ...    c_id_list_list=${c_id_list_list}    p_name_list=${i_p_name_list2}    new_value_list=${i_new_value_list2}
    Append to list    ${dist_name_list}    @{dist_name_list3}
    Append to list    ${p_name_list}    @{p_name_list3}
    Append to list    ${new_value_list}    @{new_value_list3}
    [Return]     ${dist_name_list}    ${p_name_list}    ${new_value_list}

Modify Parameter For Add NRcell
    [Arguments]    ${add_cell_list}=${NR_cell_list}
    ${dist_name_list}    ${p_name_list}    ${new_value_list}    Generate Common Parameter For Add NRcell
    Modify Ordinary Parameter Value    dist_name_list=${dist_name_list}    p_name_list=${p_name_list}    new_value_list=${new_value_list}
    Modify Parameter With Same list_name And Empty p_name    dist_name=${NRCELLGRP_ID}    list_name=nrCellList
    ...    id_list=${add_cell_list}    value_list=${add_cell_list}    index_id=0
    scf.add_elements_to_list    dist_name=${NRDU_ID}    list_name=refNrCellGroup    elements=${NR_cell_list}

Generate Common Parameter2
    [Arguments]    ${f_dist_name_list}=${f_dist_name_list1}    ${f_id_list_list}=${f_id_list_list2}    ${c_dist_name}=${c_dist_name1}
    ...    ${c_id_list_list}=${c_id_list_list1}    ${in_p_name_list1}=${i_pname_list3}    ${in_new_value_list1}=${i_new_value_list3}
    @{dist_name_list}    create list
    @{p_name_list}    create list
    @{new_value_list}    create list
    ############ modify  prioritizedRAT ##########################
    Append to list    ${dist_name_list}    ${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    Append to list    ${p_name_list}    prioritizedRAT
    Append to list    ${new_value_list}    NR
    ############ modify  chbwdl, chbwul ##########################
    ${dist_name_list1}    ${p_name_list1}    ${new_value_list1}    Generate multiple Parameter With Diff Father Mo
    ...    f_dist_name_list=${f_dist_name_list}    f_id_list_list=${f_id_list_list}    c_dist_name=${c_dist_name}
    ...    c_id_list_list=${c_id_list_list}    p_name_list=${in_p_name_list1}    new_value_list=${in_new_value_list1}
    Append to list    ${dist_name_list}    @{dist_name_list1}
    Append to list    ${p_name_list}    @{p_name_list1}
    Append to list    ${new_value_list}    @{new_value_list1}
    ############ modify legacyWideCarrierMode ####################
    ${dist_name_list2}    ${p_name_list2}    Generate Parameter With Same P_name On same Father Mo    dist_name=${RMOD_name}
        ...    id_list=${CHANNEL_id_list[1:4]}    p_name=legacyWideCarrierMode
    Append to list    ${dist_name_list}    @{dist_name_list2}
    Append to list    ${p_name_list}    @{p_name_list2}
    Append to list    ${new_value_list}    true    true    true
    [Return]     ${dist_name_list}    ${p_name_list}    ${new_value_list}

Demo A to C
    [Arguments]  ${new_scf_path}
    scf.load_scf       file_path=${default_scf}
    Remove Multiple Mo In Scf    dist_list=${LTE_dist_name_list1}    ID_list=${LTE_cell_list}
    Clone Multiple Mo In Scf    dist_list=${NR_dist_name_list1}    source_ID_list=${copy_NR_cell_list}    target_ID_list=${NR_cell_list}
    Modify Parameter For Add NRcell
    scf.save_scf        file_path=${new_scf_path}

Demo A to B
    [Arguments]  ${new_scf_path}
    scf.load_scf       file_path=${default_scf}
    Remove Multiple Mo In Scf    dist_list=${LTE_dist_name_list1}    ID_list=${LTE_cell_list}
    ${dist_name_list}    ${p_name_list}    ${new_value_list}   Generate Common Parameter2
    Modify Ordinary Parameter Value    dist_name_list=${dist_name_list}    p_name_list=${p_name_list}    new_value_list=${new_value_list}
    Modify bwpDN Value    dist_name=${NRCELL_ID}   id_list=${NR_cell_list1}   old_value=4    new_value=15    index=0
    Modify bwpDN Value    dist_name=${NRCELL_ID}   id_list=${NR_cell_list1}   old_value=33    new_value=39    index=1
    scf.save_scf        file_path=${new_scf_path}