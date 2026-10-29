*** Settings ***
Documentation   This is a keyword file for 480-L, part commissioning, update and add parameters
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Update RMOD Parameter For All LCELNR-2 Objects
    [Documentation]    [PRIVATE]    update RMOD parameter for all LCELNR-2 objects
    ...       :Autor: Sylvia Schneider
    Log To Console    set in LCELNR-2 parameter "resourceDN" to value "RMOD-1"
    ${xpath}   Set Variable   managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1"]
    Set Element Text   ${scf_xml}    text=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1       xpath=.//${xpath}/p[@name="resourceDN"]


Update Single Nrbts Parameter
    [Documentation]    [PRIVATE]    update single nrbts parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrbts parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//p[@name="${param}"]


Add Single Nrbts Parameter
    [Documentation]    [PRIVATE]    add single nrbts parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}
    Log To Console    add single nrbts parameter "${param}"
    Add Element        ${scf_xml}     ${param}           xpath=.//managedObject[@distName="${bts_distName}"]


Update Nrcellgrp-1 nrCellList
    [Documentation]    [PRIVATE]    update nrcellgrp-1 nrCellList
    ...       :Autor: Sylvia Schneider
    Log To Console    update nrcellgrp-1 nrCellList
    FOR   ${nrcell}   IN  2   3   4
       Add Element     ${scf_xml}     <p>${nrcell}</p>      xpath=.//managedObject[@distName="${bts_distName}/NRCELLGRP-0"]/list[@name="nrCellList"]
    END

Update Single Nrcell Parameter
    [Documentation]    [PRIVATE]    update single nrcell parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${nrcell}   ${param}   ${value}
    Log To Console    set in NRCELL-${nrcell} single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell}"]/p[@name="${param}"]


Update Parameter For All Nrcell Objects
    [Documentation]    [PRIVATE]    update parameter for all nrcell objects
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set in all cells parameter "${param}" to value "${value}"
    Set Elements Text   ${scf_xml}    text=${value}       xpath=.//p[@name="${param}"]
