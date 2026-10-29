*** Settings ***
Documentation    Commissioning keywords for CB011006 B03



*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]
BWPs commissioning for IWK03
    ${scf_file}=    Load SCF

        ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
        sort list    ${distName_NRCELL}
        ${distName_1st_FDD_cell}=    set variable    ${distName_NRCELL[${fdd_cell_1}-1]}

        Activate multiple BWPs feature
        Change small BWP    ${distName_1st_FDD_cell}    n106
        Add BWP to cell    ${distName_1st_FDD_cell}    n106

    Save SCF, delta commissioning and wait for onair    ${scf_file}