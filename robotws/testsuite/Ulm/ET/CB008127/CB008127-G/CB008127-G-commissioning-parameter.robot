*** Settings ***
Documentation   This is a keyword file for CB008127-G, part commissioning, update and add parameters
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

update single nrbts parameter
    [Documentation]    [PRIVATE]    update single nrbts parameter
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrbts parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//p[@name="${param}"]


update single nrcell-1 parameter
    [Documentation]    [PRIVATE]    update single nrcell-1 parameter
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]   ${param}   ${value}
    Log To Console    set in NRCELL-1 single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]


update single nrcell-2 parameter
    [Documentation]    [PRIVATE]    update single nrcell-1 parameter
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]   ${param}   ${value}
    Log To Console    set in NRCELL-2 single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="${param}"]


add parameters to nrcell-1 and nrcell-2 objects
    [Documentation]    [PRIVATE]    add parameters to nrcell-1 and nrcell-2 objects
    ...       :Autor: Shruthi Shivaprasad
    ${a2MeasReleaseEnabled}             set variable    <p name="a2MeasReleaseEnabled">rsrp</p>
    ${absThreshSsbRsrpConsolidation}    set variable    <p name="absThreshSsbRsrpConsolidation">1</p>
    ${absThreshSsbRsrqConsolidation}    set variable    <p name="absThreshSsbRsrqConsolidation">1</p>
    ${measGapSelectionSA}    set variable    <p name="measGapSelectionSA">favourUeThroughput</p>
    ${sMeasConfigSsbRsrp}    set variable    <p name="sMeasConfigSsbRsrp">1</p>
    FOR   ${param}    IN
    ...   a2MeasReleaseEnabled
    ...   absThreshSsbRsrpConsolidation
    ...   absThreshSsbRsrqConsolidation
    ...   measGapSelectionSA
    ...   sMeasConfigSsbRsrp
       Log To Console    add parameter "${${param}}" to cell ${bts_distName}/NRCELL-1
       Add Element        ${scf_xml}    ${${param}}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
       Log To Console    add parameter "${${param}}" to cell ${bts_distName}/NRCELL-2
       Add Element        ${scf_xml}    ${${param}}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]
    END


add parameter a2MeasReleaseEnabled to nrcell-3 and nrcell-4
    [Documentation]    [PRIVATE]    add parameter a2MeasReleaseEnabled to nrcell-3 and nrcell-4
    ...       :Autor: Shruthi Shivaprasad
    ${a2MeasReleaseEnabled}    set variable    <p name="a2MeasReleaseEnabled">none</p>
    Log To Console    add parameter "${a2MeasReleaseEnabled}" to cell ${bts_distName}/NRCELL-3
    Add Element        ${scf_xml}    ${a2MeasReleaseEnabled}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]
    Log To Console    add parameter "${a2MeasReleaseEnabled}" to cell ${bts_distName}/NRCELL-4
    Add Element        ${scf_xml}    ${a2MeasReleaseEnabled}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-4"]


update single nrpmnrl parameter
    [Documentation]    [PRIVATE]    update single nrpmnrl parameter
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrplmrnl parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRPMRNL-1"]/p[@name="${param}"]


Add ssbFrequency to NRADJNRCELL-1
    [Documentation]    [PRIVATE]    Add ssbFrequency to NRADJNRCELL-1
    ...       :Autor: Shruthi Shivaprasad
    ${ssbFrequency}    set variable   <p name="ssbFrequency">636576</p>
    Log To Console    add parameter "${ssbFrequency}" to ${bts_distName}/NRADJNRCELL-1
    Add Element        ${scf_xml}    ${ssbFrequency}   xpath=.//managedObject[@distName="${bts_distName}/NRADJNRCELL-1"]


add parameters to NRCELL t2
    [Documentation]    [PRIVATE]    add parameters to NRCELL t2
    ...       :Autor: Shruthi Shivaprasad
    ${a2MeasReleaseEnabled}    set variable    <p name="a2MeasReleaseEnabled">none</p>
    Log To Console    add parameter "${a2MeasReleaseEnabled}" to cell ${bts_distName}/NRCELL-3
    Add Element        ${scf_xml}    ${a2MeasReleaseEnabled}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]


update parameters NRCELL t2
    [Documentation]    [PRIVATE]    update parameters NRCELL t2
    ...       :Autor: Shruthi Shivaprasad
    FOR     ${param}             IN
    ...     a1MeashoEnabled
    ...     a2MeasReleaseEnabled
    ...     a2MeashoEnabled
    ...     a3MeasEnabled
    ...     a5MeasEnabled
       update single nrcell-2 parameter   param=${param}   value=rsrq
    END


add nrDefMoPrNsaDN
    [Documentation]    [PRIVATE]    add nrDefMoPrNsaDN
    ...       :Autor: Shruthi Shivaprasad
    FOR   ${index}    IN    1  2  3   4
       ${nrDefMoPrNsaDN}            set variable    <p name="nrDefMoPrNsaDN">MRBTS-1/NRBTS-1/NRMOPR_NSA-32</p>
       Log To Console    add parameter "${nrDefMoPrNsaDN}" to NRCELL-${index}
       Add Element       ${scf_xml}    ${nrDefMoPrNsaDN}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${index}"]
    END


update NRHOIF parameters
    [Documentation]    [PRIVATE]    update NRHOIF parameters
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    set NRHOIF-1 parameter "a4MeasHigherPrioFreqEnabled" to value "rsrpAndRsrq"
    Set Element Text   ${scf_xml}
    ...    text=rsrpAndRsrq      xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/p[@name="a4MeasHigherPrioFreqEnabled"]
    ${a4PriorityForHigherPrioFreqHo}  set variable  <p name="a4PriorityForHigherPrioFreqHo">10</p>
    Add Element    ${scf_xml}    ${a4PriorityForHigherPrioFreqHo}     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]
