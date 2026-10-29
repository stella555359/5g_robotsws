*** Settings ***
Documentation   This is a keyword file for CB008127-CD, part commissioning, update and add parameters
...             Team: 'MN RAN RD VRF ULM6'
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


add parameters to nrcell-1 and nrcell-2 objects
    [Documentation]    [PRIVATE]    add parameters to nrcell-1 and nrcell-2 objects
    ...       :Autor: Sylvia Schneider
    FOR   ${param}    IN
    ...   <p name\="absThreshSsbRsrpConsolidation">1</p>
    ...   <p name\="absThreshSsbRsrqConsolidation">1</p>
    ...   <p name\="measGapSelectionSA">favourUeThroughput</p>
    ...   <p name\="sMeasConfigSsbRsrp">1</p>
       Log To Console    add parameter "${param}" to cell ${bts_distName}/NRCELL-1
       Add Element        ${scf_xml}    ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
       Log To Console    add parameter "${param}" to cell ${bts_distName}/NRCELL-2
       Add Element        ${scf_xml}    ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]
    END

    update parameter a2MeasReleaseEnabled nrcell-3 and nrcell-4


update parameter a2MeasReleaseEnabled nrcell-3 and nrcell-4
    [Documentation]    [PRIVATE]    update parameter a2MeasReleaseEnabled nrcell-3 and nrcell-4
    ...       :Autor: Sylvia Schneider
    Log To Console    update parameter a2MeasReleaseEnabled to none for NRCELL-3 and NRCELL-4
    Set Element Text   ${scf_xml}    text=none       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]/p[@name="a2MeasReleaseEnabled"]
    Set Element Text   ${scf_xml}    text=none       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-4"]/p[@name="a2MeasReleaseEnabled"]


update single nrpmnrl parameter
    [Documentation]    [PRIVATE]    update single nrpmnrl parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrplmrnl parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRPMRNL-1"]/p[@name="${param}"]


Add ssbFrequency to NRADJNRCELL-1
    [Documentation]    [PRIVATE]    Add ssbFrequency to NRADJNRCELL-1
    ...       :Autor: Sylvia Schneider
    ${ssbFrequency}    set variable   <p name="ssbFrequency">636576</p>
    Log To Console    add parameter "${ssbFrequency}" to ${bts_distName}/NRADJNRCELL-1
    Add Element        ${scf_xml}    ${ssbFrequency}   xpath=.//managedObject[@distName="${bts_distName}/NRADJNRCELL-1"]


add parameters to NRCELL t2
    [Documentation]    [PRIVATE]    add parameters to NRCELL t2
    ...       :Autor: Sylvia Schneider
    ${a2MeasReleaseEnabled}    set variable    <p name="a2MeasReleaseEnabled">none</p>
    Log To Console    add parameter "${a2MeasReleaseEnabled}" to cell ${bts_distName}/NRCELL-3
    Add Element        ${scf_xml}    ${a2MeasReleaseEnabled}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]


update parameters NRCELL t2
    [Documentation]    [PRIVATE]    update parameters NRCELL t2
    ...       :Autor: Sylvia Schneider
    FOR     ${param}             IN
    ...     a1MeashoEnabled
    ...     a2MeasReleaseEnabled
    ...     a2MeashoEnabled
    ...     a3MeasEnabled
    ...     a5MeasEnabled
       update single nrcell-2 parameter   param=${param}   value=rsrq
    END


add nrConnectModeProfileDN
    [Documentation]    [PRIVATE]    add nrConnectModeProfileDN
    ...       :Autor: Sylvia Schneider
    ${nrConnectModeProfileDN}    set variable    <p name="nrConnectModeProfileDN">${bts_distName}/NRCONNECTMODE_PROFILE-1</p>

    FOR   ${object}    IN
    ...   NRADJNRCELL-1
    ...   NRCELL-1
    ...   NRCELL-2
    ...   NRCELL-1/NRHOIF-1
    ...   NRCELL-2/NRHOIF-1
       Log To Console    add parameter "${nrConnectModeProfileDN}" to ${object}
       Add Element       ${scf_xml}    ${nrConnectModeProfileDN}   xpath=.//managedObject[@distName="${bts_distName}/${object}"]
    END


add nrDefMoPrNsaDN
    [Documentation]    [PRIVATE]    add nrDefMoPrNsaDN
    ...       :Autor: Sylvia Schneider
    FOR   ${index}    IN    1  2  3   4
       ${nrDefMoPrNsaDN}            set variable    <p name="nrDefMoPrNsaDN">MRBTS-1/NRBTS-1/NRMOPR_NSA-32</p>
       Log To Console    add parameter "${nrDefMoPrNsaDN}" to NRCELL-${index}
       Add Element       ${scf_xml}    ${nrDefMoPrNsaDN}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${index}"]
    END


update parameters NRCELL t6
    [Documentation]    [PRIVATE]    update parameters NRCELL t6
    ...       :Autor: Sylvia Schneider
    FOR     ${param}                       ${value}     IN
    ...     a1MeashoEnabled                rsrpAndRsrq
    ...     a2MeashoEnabled                rsrpAndRsrq
    ...     a3MeasEnabled                  rsrpAndRsrq
    ...     a5MeasEnabled                  rsrpAndRsrq
       update single nrcell-1 parameter   param=${param}   value=${value}
       update single nrcell-2 parameter   param=${param}   value=${value}
    END
    update single nrcell-1 parameter   param=a1MeashoPrefNRLayerEnabled   value=rsrpAndRsrq
    update single nrcell-1 parameter   param=a2MeasReleaseEnabled         value=rsrq
    update single nrcell-2 parameter   param=a2MeasReleaseEnabled         value=rsrpAndRsrq

    ${a2MeasReleaseEnabled}    set variable    <p name="a2MeasReleaseEnabled">none</p>
    Log To Console    add parameter "${a2MeasReleaseEnabled}" to cell ${bts_distName}/NRCELL-3 and NRCELL-4
    Add Element        ${scf_xml}    ${a2MeasReleaseEnabled}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]
    Add Element        ${scf_xml}    ${a2MeasReleaseEnabled}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-4"]


update NRHOIF parameters
    [Documentation]    [PRIVATE]    update NRHOIF parameters
    ...       :Autor: Sylvia Schneider
    Log To Console    set NRHOIF-1 parameter "a4MeasHigherPrioFreqEnabled" to value "rsrpAndRsrq"
    Set Element Text   ${scf_xml}
    ...    text=rsrpAndRsrq      xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/p[@name="a4MeasHigherPrioFreqEnabled"]
    ${a4PriorityForHigherPrioFreqHo}  set variable  <p name="a4PriorityForHigherPrioFreqHo">10</p>
    Add Element    ${scf_xml}    ${a4PriorityForHigherPrioFreqHo}     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]


update thresholds NRMEASPR_IEF-2
    [Documentation]    [PRIVATE]    update thresholds NRMEASPR_IEF-2
    ...       :Autor: Sylvia Schneider
    ${xpath_ief2}  set variable   ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-2
    Log To Console    set parameter values in ${xpath_ief2}
    FOR   ${list}                        ${param}               ${value}    IN
    ...   a3MeasSsbRsrp                  a3OffsetSsbRsrp        3
    ...   a3MeasSsbRsrq                  a3OffsetSsbRsrq        4
    ...   a4MeasHigherPrioFreqSsbRsrp    a4ThresholdSsbRsrp     50
    ...   a4MeasHigherPrioFreqSsbRsrq    a4ThresholdSsbRsrq     51
    ...   a5MeasSsbRsrp                  a5Threshold1SsbRsrp    65
    ...   a5MeasSsbRsrq                  a5Threshold1SsbRsrq    66
      Log To Console    in list "${list}" set parameter "${param}" to value "${value}"
      Set Element Text  ${scf_xml}   text=${value}   xpath=.//managedObject[@distName="${xpath_ief2}"]/list[@name="${list}"]/item/p[@name="${param}"]
    END
