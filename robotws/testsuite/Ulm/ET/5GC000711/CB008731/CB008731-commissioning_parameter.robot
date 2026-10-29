*** Settings ***
Documentation   This is a keyword file for CB008731, part commissioning, update and add parameters
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

update single nrbts parameter
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrbts parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//p[@name="${param}"]


update single nrcell-1 parameter
    [Arguments]   ${param}   ${value}
    Log To Console    set in NRCELL-1 single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]


update single nrcell-2 parameter
    [Arguments]   ${param}   ${value}
    Log To Console    set in NRCELL-2 single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="${param}"]


update parameter for all nrcell objects
    [Arguments]   ${param}   ${value}
    Log To Console    set in all cells parameter "${param}" to value "${value}"
    Set Elements Text   ${scf_xml}    text=${value}       xpath=.//p[@name="${param}"]


update single nrpmnrl parameter
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrplmrnl parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRPMRNL-1"]/p[@name="${param}"]


update single nrdu parameter
    Log To Console    set single nrdu parameter numOfDrbsReservForEmergency to value 1
    Set Element Text   ${scf_xml}    text=1       xpath=.//managedObject[@distName="${bts_distName}/NRDU-1"]/p[@name="numOfDrbsReservForEmergency"]


add maxCidAllowed parameter for NRDRB_PDCP objects
    [Documentation]    [PRIVATE]    add maxCidAllowed parameter for NRDRB_PDCP objects
    ...       :Autor: Sylvia Schneider
    ${maxCidAllowed}    set variable    <p name="maxCidAllowed">4</p>
    FOR    ${id}       IN   1   2   3
       Log To Console    add <p name="maxCidAllowed">4</p> to ${bts_distName}/NRDRB_PDCP-${id}
       Add Element       ${scf_xml}     ${maxCidAllowed}   xpath=.//managedObject[@distName="${bts_distName}/NRDRB_PDCP-${id}"]
    END


add a4MeasHigherPrioFreqMaxReactSA to NRCELL
    [Documentation]    [PRIVATE]    add parameter a4MeasHigherPrioFreqMaxReactSA to nrcell
    ...       :Autor: Sylvia Schneider
    FOR    ${nrcell}   ${value}   IN
    ...    NRCELL-1    1
    ...    NRCELL-2    0
       Log To Console    add msMeasConfigSsbRsrp parameter value ${value} to ${nrcell}
       ${a4MeasHigherPrioFreqMaxReactSA}    set variable    <p name="a4MeasHigherPrioFreqMaxReactSA">${value}</p>
       Add Element        ${scf_xml}     ${a4MeasHigherPrioFreqMaxReactSA}   xpath=.//managedObject[@distName="${bts_distName}/${nrcell}"]
    END


add absThreshSsbRsrpConsolidation absThreshSsbRsrqConsolidation to NRCELL
    [Documentation]    [PRIVATE]    add parameters absThreshSsbRsrpConsolidation absThreshSsbRsrqConsolidation to nrcell
    ...       :Autor: Sylvia Schneider
    ${absThreshSsbRsrpConsolidation}  set variable  <p name="absThreshSsbRsrpConsolidation">10</p>
    ${absThreshSsbRsrqConsolidation}  set variable  <p name="absThreshSsbRsrqConsolidation">10</p>
    FOR    ${NRCELL_id}    IN  1   2
       Add Element        ${scf_xml}     ${absThreshSsbRsrpConsolidation}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]
       Add Element        ${scf_xml}     ${absThreshSsbRsrqConsolidation}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]
    END


add sMeasConfigSsbRsrp to ${nrcell}
    [Documentation]    [PRIVATE]    add parameter sMeasConfigSsbRsrp to nrcell
    ...       :Autor: Sylvia Schneider
    Log To Console    add msMeasConfigSsbRsrp parameter to ${nrcell}
    ${sMeasConfigSsbRsrp}    set variable    <p name="sMeasConfigSsbRsrp">4</p>
    Add Element        ${scf_xml}     ${sMeasConfigSsbRsrp}   xpath=.//managedObject[@distName="${bts_distName}/${nrcell}"]


add measGapSelectionSA to nrcell-1
    ${xpath_NRCELL-1}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${measGapSelectionSA}    set variable    <p name="measGapSelectionSA">favourUeThroughput</p>
    Add Element        ${scf_xml}    ${measGapSelectionSA}   xpath=.//${xpath_NRCELL-1}


add measGapSelectionSA mgta sMeasConfigSsbRsrp to NRCELL
    ${xpath_NRCELL-1}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${xpath_NRCELL-2}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-2"]
    Add Element        ${scf_xml}    <p name="measGapSelectionSA">balancedChoice</p>                                  xpath=.//${xpath_NRCELL-1}
    Add Element        ${scf_xml}    <p name="measGapSelectionSA">balancedChoice</p>                                  xpath=.//${xpath_NRCELL-2}
    Add Element        ${scf_xml}    <p name="mgta">ms0</p>                                                           xpath=.//${xpath_NRCELL-1}
    Add Element        ${scf_xml}    <p name="mgta">ms0</p>                                                           xpath=.//${xpath_NRCELL-2}
    Add Element        ${scf_xml}    <p name="nrConnectModeProfileDN">${bts_distName}/NRCONNECTMODE_PROFILE-1</p>     xpath=.//${xpath_NRCELL-1}
    Add Element        ${scf_xml}    <p name="nrConnectModeProfileDN">${bts_distName}/NRCONNECTMODE_PROFILE-2</p>     xpath=.//${xpath_NRCELL-2}
    Add Element        ${scf_xml}    <p name="sMeasConfigSsbRsrp">0</p>                                               xpath=.//${xpath_NRCELL-1}
    Add Element        ${scf_xml}    <p name="sMeasConfigSsbRsrp">0</p>                                               xpath=.//${xpath_NRCELL-2}


add nonContentRachAcFullConfigHo tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    ${nonContentRachAcFullConfigHo}    set variable    <p name="nonContentRachAcFullConfigHo">true</p>
    Add Element        ${scf_xml}     ${nonContentRachAcFullConfigHo}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${tNgRelocExecDeltL}    set variable    <p name="tNgRelocExecDeltL">5000</p>
    Add Element        ${scf_xml}     ${tNgRelocExecDeltL}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${timerXnDataFwdGuard}    set variable    <p name="timerXnDataFwdGuard">250</p>
    Add Element        ${scf_xml}     ${timerXnDataFwdGuard}   xpath=.//managedObject[@distName="${bts_distName}"]


add high priority params to nrcell-1
    FOR    ${param}       IN
    ...    <p name\="numOfRadioResReservForPa">1</p>
    ...    <p name\="pagingPrioLevelPaMax">1</p>
    ...    <p name\="pagingPrioLevelPaMin">1</p>
    ...    <p name\="powerRampingStepHighPriorityCbra">dB4</p>
    ...    <p name\="raPrioritizationForAI">MPS</p>
    ...    <p name\="tPageCorrInt">3000</p>
       Log To Console    add ${param} to ${bts_distName}/NRCELL-1
       Add Element        ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    END
    ${applyPriorityAccess}    set variable    <p name="applyPriorityAccess">HPA</p>
    Add Element        ${scf_xml}     ${applyPriorityAccess}   xpath=.//managedObject[@distName="${bts_distName}"]


add preemption params to nrbts and nrcells
    ${maxNumOfPreemptions}    set variable    <p name="maxNumOfPreemptions">20</p>
    Add Element        ${scf_xml}     ${maxNumOfPreemptions}   xpath=.//managedObject[@distName="${bts_distName}"]

    FOR    ${param}       IN
       ...    <p name\="preferNsaPreemption">false</p>
       ...    <p name\="allowEmergencyReservForTempUse">false</p>
       ...    <p name\="numOfRadioResReservForTempUse">30</p>
       Log To Console    add ${param} to all NRCELL
       Add Element        ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
       Add Element        ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]
       Add Element        ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]
       Add Element        ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-4"]
    END


