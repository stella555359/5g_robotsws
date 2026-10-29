*** Settings ***
Documentation
...    Keywords needing a connect to real eNB to collect data from real eNB, or to modify parameters on real eNB

Library         taf.gnb.oam.coam.admin                      WITH NAME   coam
Library         taf.gnb.oam.coam.admin                      WITH NAME   enblte

Resource        ${CURDIR}/scf_num_of_cells.robot

*** Keywords ***
Connect to eNB via ssl oam addr
    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte
    enblte.connect_to    bts_host=${tl.enbs[0].oam_ip}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}


Enblte close ssl
    [Arguments]    ${connection}=enblte
    enblte.teardown    connection=${connection}


Get pcell lnrelgnbcell nrcellid
    [Documentation]    Find the LNRELGNBCELL and related nrCellId of the gNB on the real eNB it is connected to
    ...                eNB can be connected to several gNB
    ...                gNB can have several cells
    ...                Return a dictionary containing gNB Pcell NRCELL name, associated LNRELGNBCELL distName and nrCellId value.
    [Arguments]    ${alias}=enblte    ${oam_vm}=10.14.48.220

    # Get the list of gNB cells and their nrCellIdentity
    coam.connect to      bts_host=${oam_vm}    name=coamCnx
    coam.get_cells_info    connection=coamCnx
    &{subcell_info}=    coam.get_subcells_info    connection=coamCnx
    coam.teardown     coamCnx

    ${list_gnb_cell_names}    Get dictionary keys    ${subcell_info["NRCELLGRP-0"]}
    ${numOfCells}=     Get length    ${list_gnb_cell_names}
    @{list_gNB_nrCellId}    Create list
    :FOR    ${index}    in range    0  ${numOfCells}
    \    Append to list    ${list_gNB_nrCellId}
    ...                    ${subcell_info["NRCELLGRP-0"]["${list_gnb_cell_names[${index}]}"]["NRCELL_L"]["parameters"]["nrCellIdentity"]}

    # Get the list of lnrelgnbcell declared on eNB
    Connect to eNB via ssl oam addr    connection=${alias}
    @{MOs}    enblte.get_managed_objects    class_name=LNRELGNBCELL_A    connection=${alias}

    ${nb_lnrel}    Get length    ${MOs}
    ${index}       Evaluate    0
    @{list_lnrel_nrCellId}    Create List
    :FOR    ${index}    in range    0  ${nb_lnrel}
    \    ${lnrelgnbcell_parameters}    Set variable    ${MOs[${index}]['parameters']}
    \    Append to list    ${list_lnrel_nrCellId}    ${lnrelgnbcell_parameters['nrCellId']}


    # Find out the lnrelgnbcell related to the gNB
    :FOR    ${index}    in range    0  ${numOfCells}
    \    ${index_gnb_nrcell}    Get index from list    ${list_lnrel_nrCellId}    ${list_gNB_nrCellId[${index}]}
    \    ${gnb_lnrelgnbcell_distname}    Set Variable    ${MOs[${index_gnb_nrcell}]['distName']}
    \    run keyword if    ${index_gnb_nrcell} != -1    Exit for loop

    Run keyword if     ${index_gnb_nrcell} == -1    Fail    gNB nrCrllId not found on eNB

    # Rework gnb_lnrelgnbcell_distname from
    # MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-22262/LNBTS_A-22262/LNCEL_A-75/LNRELGNBCELL_A-0
    # to:
    # MRBTS-22262/LNBTS-22262/LNCEL-75/LNRELGNBCELL-0
    ${chaine}    Get Regexp Matches    ${gnb_lnrelgnbcell_distname}    MRBTS_A-\\d+/LNBTS_A-\\d+/LNCEL_A-\\d+/LNRELGNBCELL_A-\\d+
    ${chaine2}    Replace String    ${chaine[0]}    _A    ${EMPTY}
    ${gnb_lnrelgnbcell_distname}    Set variable    ${chaine2}

    &{gnb_dict}    Create Dictionary    pcell=${list_gnb_cell_names[${index}]}
    ...                                 gnb_lnrelgnbcell_distname=${gnb_lnrelgnbcell_distname}
    ...                                 nrCellId=${list_lnrel_nrCellId[${index_gnb_nrcell}]}

    [Teardown]    Enblte close ssl    connection=${alias}
    [return]    ${gnb_dict}


Configure eNB for 5GC001668 with several cells
    [Arguments]    ${connection}   ${oam_vm}    ${gnb_lnrelgnbcell_nrCellId}

    wait until keyword succeeds    10 min     10 sec     coam.connect to      bts_host=${oam_vm}    name=coamCnx
    &{subcell_info}=    coam.get_subcells_info    connection=coamCnx
    coam.teardown     coamCnx
    set test variable    ${nrCellIdentity}    ${subcell_info["NRCELLGRP-0"]["NRCELL-1"]["NRCELL_L"]["parameters"]["nrCellIdentity"]}

    Run keyword if    '${nrCellIdentity}' != '${gnb_lnrelgnbcell_nrCellId.nrCellId}'
    ...                Modify nrCellId on enblte    enblte    ${gnb_lnrelgnbcell_nrCellId}    ${nrCellIdentity}


Modify nrCellId on enblte
    [arguments]    ${connection}   ${gnb_lnrelgnbcell_nrCellId}    ${nrCellId}
    [teardown]     enblte.teardown    connection=enblte
    ${enb_scf_initial}    Catenate    SEPARATOR=    ${scf_path}    /    save_initial_scf_enb.xml
    ${enb_scf_final}    Catenate    SEPARATOR=    ${scf_path}    /    final_scf_enb.xml
    Connect to eNB via ssl oam addr    connection=${connection}
    enblte.Get current scf file    ${scf_path}    save_initial_scf_enb.xml    60    ${connection}
    scf.load scf    ${enb_scf_initial}
    log    value=${nrCellId}
    log    dist_name=${gnb_lnrelgnbcell_nrCellId.gnb_lnrelgnbcell_distname}
    scf.modify scf element    value=${nrCellId}    dist_name=${gnb_lnrelgnbcell_nrCellId.gnb_lnrelgnbcell_distname}    p_name=nrCellId
    scf.save scf    ${enb_scf_final}
    enblte.perform commissioning    ${enb_scf_final}      False    True    300    ${connection}
    set test variable    ${is_enb_scf_changed}    True

Wait eNB cell is on air
    [Arguments]    ${enb_cell}
    wait until keyword succeeds    10 min    60 sec    Check enb cell is on air    ${enb_cell}


Restore gNB nrCellId on eNB
    [arguments]    ${connection}=enblte
    [teardown]     enblte.teardown    connection=enblte
    ${enb_scf_initial}    Catenate    SEPARATOR=    ${scf_path}    /    save_initial_scf_enb.xml
    ${status}    File should exist    ${enb_scf_initial}
    Connect to eNB via ssl oam addr    connection=${connection}
    Run keyword if    '${is_enb_scf_changed}' == 'True'
    ...               enblte.perform commissioning    ${enb_scf_initial}      False    True    300    ${connection}


Check enb cell is on air
    [Arguments]    ${enb_cell}
    Connect to eNB via ssl oam addr
    ${enbcell_status}=    Get enb cell status from btsinfo    ${enb_cell}
    should be equal    ${enbcell_status}    Online


Get enb cell status from btsinfo
    [Arguments]    ${enb_cell_name}
    ${output} =    enblte.get_bts_info    connection=enblte
    enblte.teardown    connection=enblte
    log    ${output["status"]}
    log    ${output["cells"]}
    # liste des cellules lte
    log    ${output["cells"]["lte"]}
    ${nb_cell_enb}    Get length    ${output["cells"]["lte"]}
    # 1ere cellule de la liste, c est un dictionnaire
    log    ${output["cells"]["lte"][0]}

    ${enbcell_status}    Set variable    offline
    :FOR    ${index}   in range   0  ${nb_cell_enb}
    \    ${cell_name}    Set variable    ${output["cells"]["lte"][${index}]["cellName"]}
    \    ${enbcell_status}    Set variable if    '${cell_name}' == '${enb_cell_name}'
    ...                                          ${output["cells"]["lte"][${index}]["status"]["availabilityStatus"]}
    \    Exit for loop if    '${enbcell_status}' == 'Online'

    [Return]    ${enbcell_status}

