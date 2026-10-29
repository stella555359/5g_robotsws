*** Settings ***
Documentation    Commissioning keywords for CB011006 B19


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]
Initial commissioning for IWK19
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    Set Element     dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=type0CoresetConfigurationIndex    value=8
    Set Element     dist_name=${distName_NRCELL[${fdd_cell_2}-1]}    p_name=type0CoresetConfigurationIndex    value=8

    # activates collection of RRC PM counters
    ${distName_NRPMRNL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    Set Element     dist_name=${distName_NRPMRNL[0]}    p_name=miNrCCD    value=5min


BWPs commissioning for IWK19
    ${scf_file}=    Load SCF

        ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
        sort list    ${distName_NRCELL}
        ${distName_1st_FDD_cell}=    set variable    ${distName_NRCELL[${fdd_cell_1}-1]}

        Activate multiple BWPs feature
        Change small BWP    ${distName_1st_FDD_cell}    n52
        Add BWP to cell    ${distName_1st_FDD_cell}    n52
        Add BWP to cell    ${distName_1st_FDD_cell}    n106
        Add power saving BWP to cell    ${distName_1st_FDD_cell}    n52

    Save SCF, delta commissioning and wait for onair    ${scf_file}