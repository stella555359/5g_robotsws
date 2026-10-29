*** Settings ***
Documentation   This is a keyword file for 480-L, part commissioning, delete
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Delete Element
    [Documentation]    [PRIVATE]    Delete element
    ...       :Autor: Sylvia Schneider
    FOR   ${object}   IN
    ...   MRBTS-1/EQM-1/APEQM-1/RMOD-2
    ...   MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
    ...   MRBTS-1/EQM-1/HWTOP-1/CABLINK-3
    ...   ${bts_distName}/NRCELLGRP-1
       Log To Console    remove object ${object}
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${object}"]
    END

    FOR    ${object}   ${list}    IN
    ...    MRBTS-1/MNL-1/MNLENT-1/SYNC-2        targetDNList
    ...    ${bts_distName}/NRDU-1               refNrCellGroup
       Log To Console    remove list "${list}" from object "${object}"
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${object}"]/list[@name="${list}"]
    END
