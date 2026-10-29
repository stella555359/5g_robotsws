*** Settings ***
Documentation
...     Test Suite Purpose:

Library     OperatingSystem
Library     String
Library     Process
Library     Collections
Library     taf.config.scf                  WITH NAME       scf


*** Keywords ***
Prepare cells in scf
    [Documentation]     create the number of required cells in scf and adapt cells parameters to the RF declared in __init_py
    ...                 SCF must have been collected and stored in ${scf_full_path} (full filename with path) from gNB before
    ...                 this keyword is launched
    ...                 nrarfcn and gscn to use for each cell must be declared as lists imported by the test case. The list
    ...                 must have the following name and format:
    ...                 <RF Type>_arfcn_cells_<contiguous|noncontiguous>=    arfcn cell 1    arfcn cell 2    arfcn cell 3   .....
    ...                 <RF Type>_gscn_cells_<contiguous|noncontiguous>=     gscn cell 1   gscn cell 2    gscn cell 3    .....
    ...                 Ex: @{AEQA_arfcn_cells_contiguous}=    12345    23456    34567   45678    56789    67890    78901    89012
    ...                 RF Type is taken from __init__.py of the TL.
    ...                 ${contiguous} can take value contiguous or noncontiguous.
    [Arguments]         ${scf_full_path}    ${number_of_required_cells}    ${contiguous}    ${scf_target_path}    ${start_pci}=50


    # Find out number of cells on gNB
    ${fichier_scf}=    Get File    ${scf_full_path}
    ${list_cell_distnames}=    Get Regexp Matches    ${fichier_scf}    MRBTS-\\d+/NRBTS-\\d+/NRCELL-\\d+
    ${list_lcelnr_distnames}=    Get Regexp Matches    ${fichier_scf}    MRBTS-\\d+/MNL-\\d+/MNLENT-\\d+/CELLMAPPING-\\d+/LCELNR-\\d+"
    ${cell_distname_root}=    Get Regexp Matches    ${list_cell_distnames[0]}    MRBTS-\\d+/NRBTS-\\d+/NRCELL-
    ${lcelnr_distname_root}=    Get Regexp Matches    ${list_lcelnr_distnames[0]}    MRBTS-\\d+/MNL-\\d+/MNLENT-\\d+/CELLMAPPING-\\d+/LCELNR-

    ${numOfCells}=     Get length    ${list_cell_distnames}
    ${numOfLcelnr}=     Get length    ${list_lcelnr_distnames}

    # Delete all cells except first one
    scf.load scf    ${scf_full_path}
    ${start_pci}=   convert to integer    ${start_pci}
    ${start_pci}=    evaluate    ${start_pci} - 1
    ${index}=    convert to integer    1


    :FOR    ${index}    in range     1    ${numOfCells}
    \    scf.remove_mo_with_descendant_mos    ${list_cell_distnames[${index}]}

    :FOR    ${index}    in range     1    ${numOfLcelnr}
    \    ${lcelnr} =    Remove String     ${list_lcelnr_distnames[${index}]}    "
    \    scf.remove_mo_with_descendant_mos    ${list_lcelnr_distnames[${index}]}

    scf.save_scf    ${scf_path}/scf_temp.xml

    # Rename remaining cell as NRCELL-1 and LCELNR as LCELNR-1
    ${fichier_scf}=    Get File    ${scf_path}/scf_temp.xml
    ${current_cell_distname}=    Get Regexp Matches    ${fichier_scf}    MRBTS-\\d+/NRBTS-\\d+/NRCELL-\\d+
    ${new_cell_distname}=    Replace string using Regexp    ${current_cell_distname[0]}    NRCELL-\\d+    NRCELL-1
    ${fichier_scf}=    Replace string using Regexp     ${fichier_scf}   MRBTS-\\d+/NRBTS-\\d+/NRCELL-\\d+    ${new_cell_distname}

    ${current_lcelnr_distname}=    Get Regexp Matches    ${fichier_scf}    MRBTS-\\d+/MNL-\\d+/MNLENT-\\d+/CELLMAPPING-\\d+/LCELNR-\\d+
    ${new_lcelnr_distname}=    Replace string using Regexp    ${current_lcelnr_distname[0]}    LCELNR-\\d+    LCELNR-1
    ${fichier_scf}=    Replace string using Regexp     ${fichier_scf}   MRBTS-\\d+/MNL-\\d+/MNLENT-\\d+/CELLMAPPING-\\d+/LCELNR-\\d+
    ...                                                ${new_lcelnr_distname}
    Create file    ${scf_path}/scf_temp2.xml    ${fichier_scf}

    # create the number of cells and lcelnr requested
    scf.load scf    ${scf_path}/scf_temp2.xml
    ${index}=    convert to integer    1
    ${nb_cell_required}=    evaluate    ${number_of_required_cells}

    :FOR    ${index}    in range     1    ${nb_cell_required}
    \    ${cell_index}=    evaluate    ${index} + 1
    \    ${added_cell_distname}=    Replace string using Regexp    ${new_cell_distname}    NRCELL-\\d+    NRCELL-${cell_index }
    \    ${added_lcelnr_distname}=    Replace string using Regexp    ${new_lcelnr_distname}    LCELNR-\\d+    LCELNR-${cell_index }
    \    scf.clone mo with descendant mos    ${new_cell_distname}    ${added_cell_distname}
    \    scf.clone mo with descendant mos    ${new_lcelnr_distname}    ${added_lcelnr_distname}

    # Update nrCellList in NRCELLGRP with the right number of cells
    ${cell_group_distname_root}=    Get Regexp Matches    ${cell_distname_root[0]}    MRBTS-\\d+/NRBTS-\\d+
    ${cell_group_distname}=    Catenate    SEPARATOR=    ${cell_group_distname_root[0]}    /NRCELLGRP-0
    scf.remove list from scf    dist_name=${cell_group_distname}    list_name=nrCellList
    scf.add list to scf    dist_name=${cell_group_distname}    list_name=nrCellList

    ${nb_cell_required_top_range}=    evaluate    ${nb_cell_required} + 1
    @{elements}=    create list
    :FOR    ${index}    in range     1    ${nb_cell_required_top_range}
    \    Append to list    ${elements}    ${index}
    # add element prend un dictionnaire
    scf.add elements to list    dist_name=${cell_group_distname}    list_name=nrCellList    elements=@{elements}

    # Set NRCELL parameters independant of RF

    :FOR    ${index}    in range     1    ${nb_cell_required_top_range}
    \    ${cell_distname}=    Catenate    SEPARATOR=    ${cell_distname_root[0]}    ${index}
    \    log    value=${index} dist_name=${cell_distname} p_name=cellName
    \    ${phy_index}    Evaluate    ${start_pci} + ${index}
    \    scf.modify scf element    value=${index}    dist_name=${cell_distname}    p_name=lcrId
    \    scf.modify scf element    value=${phy_index}    dist_name=${cell_distname}    p_name=physCellId

    # Set NRCELL arfcn and gscn according to RF declared in __init__py
    ${RF_type}=    set variable    ${tl.gnbs[0].dus[0].rus[0].radio_type}
    ${arfcn_list}=    catenate    SEPARATOR=    ${RF_type}    _arfcn_cells_    ${contiguous}
    ${gscn_list}=    catenate    SEPARATOR=    ${RF_type}    _gscn_cells_    ${contiguous}
    log to console    ${${arfcn_list}}
    :FOR    ${index}    in range     1    ${nb_cell_required_top_range}
    \    ${cell_distname}=    Catenate    SEPARATOR=    ${cell_distname_root[0]}    ${index}
    \    ${index_list}=    evaluate    ${index} - 1
    \    scf.modify scf element    value=${${arfcn_list}[${index_list}]}    dist_name=${cell_distname}    p_name=nrarfcn
    \    scf.modify scf element    value=${${gscn_list}[${index_list}]}    dist_name=${cell_distname}    p_name=gscn

    scf.save_scf    ${scf_target_path}

