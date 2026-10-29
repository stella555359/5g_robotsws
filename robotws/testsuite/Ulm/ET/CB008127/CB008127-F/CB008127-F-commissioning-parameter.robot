*** Settings ***
Documentation   This is a keyword file for CB008127-F, part commissioning, update and add parameters
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

update single nrbts parameter
    [Documentation]    [PRIVATE]    update single nrbts parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrbts parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//p[@name="${param}"]


update single nrcell-1 parameter
    [Documentation]    [PRIVATE]    update single nrcell-1 parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set in NRCELL-1 single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]

update single nrcell-2 parameter
    [Documentation]    [PRIVATE]    update single nrcell-1 parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set in NRCELL-2 single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="${param}"]


update single nrpmnrl parameter
    [Documentation]    [PRIVATE]    update single nrpmnrl parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrplmrnl parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRPMRNL-1"]/p[@name="${param}"]


add parameter a2MeasReleaseEnabled to nrcell-1
    [Documentation]    [PRIVATE]    add parameter a2MeasReleaseEnabled to nrcell-1
    ...       :Autor: Sylvia Schneider
    Log To Console    add "<p name="a2MeasReleaseEnabled">rsrp</p>" to "${bts_distName}/NRCELL-1"
    Add Element        ${scf_xml}    <p name="a2MeasReleaseEnabled">rsrp</p>   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


add tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    [Documentation]    [PRIVATE]    add tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    ...       :Autor: Sylvia Schneider
    ${tNgRelocExecDeltL}    set variable    <p name="tNgRelocExecDeltL">5000</p>
    Add Element        ${scf_xml}     ${tNgRelocExecDeltL}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${timerXnDataFwdGuard}    set variable    <p name="timerXnDataFwdGuard">250</p>
    Add Element        ${scf_xml}     ${timerXnDataFwdGuard}   xpath=.//managedObject[@distName="${bts_distName}"]


add parameters to all nrcell objects
    [Documentation]    [PRIVATE]    add parameters to all nrcell objects
    ...       :Autor: Sylvia Schneider
    FOR   ${param}    IN
    ...   <p name\="absThreshSsbRsrpConsolidation">10</p>
    ...   <p name\="absThreshSsbRsrqConsolidation">10</p>
    ...   <p name\="measGapSelectionSA">balancedChoice</p>
    ...   <p name\="mgta">ms0</p>
    ...   <p name\="sMeasConfigSsbRsrp">0</p>
       Log To Console    add parameter "${param}" to cell ${bts_distName}/NRCELL-1
       Add Element        ${scf_xml}    ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
       Log To Console    add parameter "${param}" to cell ${bts_distName}/NRCELL-2
       Add Element        ${scf_xml}    ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]
    END
