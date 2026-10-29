*** Settings ***
Documentation   This is a keyword file for CB008127, part commissioning, update and add parameters
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Update Single Nrbts Parameter
    [Documentation]    [PRIVATE]    update single nrbts parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrbts parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//p[@name="${param}"]


Update Single Nrcell-1 Parameter
    [Documentation]    [PRIVATE]    update single nrcell-1 parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set in NRCELL-1 single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]

Update Single Nrcell-2 Parameter
    [Documentation]    [PRIVATE]    update single nrcell-1 parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set in NRCELL-2 single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="${param}"]


Add TNgRelocExecDeltL TimerXnDataFwdGuard To Mrbts Object
    [Documentation]    [PRIVATE]    add tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    ...       :Autor: Sylvia Schneider
    ${tNgRelocExecDeltL}    Set Variable    <p name="tNgRelocExecDeltL">5000</p>
    Add Element        ${scf_xml}     ${tNgRelocExecDeltL}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${timerXnDataFwdGuard}    Set Variable    <p name="timerXnDataFwdGuard">250</p>
    Add Element        ${scf_xml}     ${timerXnDataFwdGuard}   xpath=.//managedObject[@distName="${bts_distName}"]


Add Parameters To All Nrcell Objects
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


Add Parameters To All Nrcell Objects T3
    [Documentation]    [PRIVATE]    add parameters to all nrcell objects t3
    ...       :Autor: Sylvia Schneider
    ${nrDefMoPrNsaDN}    Set Variable    <p name="nrDefMoPrNsaDN">${bts_distName}/NRMOPR_NSA-1</p>
    ${nrDefMoPrSaDN}     Set Variable    <p name="nrDefMoPrSaDN">${bts_distName}/NRMOPR_SA-1</p>
    FOR  ${NRCELL_id}    IN   1   2  3   4
       Log To Console    add parameter "${nrDefMoPrNsaDN}" to cell ${bts_distName}/NRCELL-${NRCELL_id}
       Add Element        ${scf_xml}    ${nrDefMoPrNsaDN}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]
       Log To Console    add parameter "${nrDefMoPrSaDN}" to cell ${bts_distName}/NRCELL-${NRCELL_id}
       Add Element        ${scf_xml}    ${nrDefMoPrSaDN}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]
    END


Update Add Parameters Nrcell-3 And Nrcell-4
    [Documentation]    [PRIVATE]    update parameters nrcell-3 and nrcell-4
    ...       :Autor: Sylvia Schneider
    ${measGapSelectionSA}    Set Variable    <p name="measGapSelectionSA">balancedChoice</p>
    FOR   ${nrcell_id}   IN   3   4
       ${xpath_NRCELL}    Set Variable  managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]
       Log To Console     set in NRCELL-${nrcell_id} parameter "measGapSelection" to value "balancedChoice"
       Set Element Text   ${scf_xml}    text=balancedChoice    xpath=.//${xpath_NRCELL}/p[@name="measGapSelection"]
       Log To Console     add parameter "${measGapSelectionSA}" to cell ${bts_distName}/NRCELL-${nrcell_id}
       Add Element        ${scf_xml}    ${measGapSelectionSA}   xpath=.//${xpath_NRCELL}
    END


Add Parameter A2MeasReleaseEnabled To Nrcell-1
    [Documentation]    [PRIVATE]    add parameter a2MeasReleaseEnabled to nrcell-1
    ...       :Autor: Sylvia Schneider
    Log To Console    add "<p name="a2MeasReleaseEnabled">rsrp</p>" to "${bts_distName}/NRCELL-1"
    Add Element        ${scf_xml}    <p name="a2MeasReleaseEnabled">rsrp</p>   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Remove Nrcell Parameters And Objects NRMOPR SA-1 TRACKINGAREA-200
    [Documentation]    [PRIVATE]    remove nrcell parameters and objects NRMOPR_SA-1 TRACKINGAREA-200
    ...       :Autor: Sylvia Schneider
    scf.Load Scf      ${resultBaseDir}/SCFC_start.xml
    Log To Console    remove parameter "nrDefMoPrSaDN" in all cells
    FOR   ${cell_id}   IN   1   2   3  4
       scf.Remove Element From Scf    dist_name=${bts_distName}/NRCELL-${cell_id}       p_name=nrDefMoPrSaDN
    END

    Log To Console    remove element "${bts_distName}/NRMOPR_SA-1"
    scf.Remove Mo With Descendant Mos        dist_name=${bts_distName}/NRMOPR_SA-1
    Log To Console    remove element "${bts_distName}/TRACKINGAREA-200"
    scf.Remove Mo With Descendant Mos        dist_name=${bts_distName}/TRACKINGAREA-200
    scf.Save Scf      ${resultBaseDir}/SCFC_start_after_remove.xml


Update Single List Parameter Nrcell
    [Documentation]    [PRIVATE]    update single list parameter nrcell
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${nrcell_id}   ${list}    ${param}   ${value}
    ${mo_nrcell}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]
    Log To Console    set NRCELL-${nrcell_id}, list "${list}", parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}  text=${value}    xpath=.//${mo_nrcell}/list[@name="${list}"]/item/p[@name="${param}"]


Update Single Nrpmnrl Parameter
    [Documentation]    [PRIVATE]    update single nrpmnrl parameter
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrplmrnl parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRPMRNL-1"]/p[@name="${param}"]


Add Parameters To Nrbts Object T4
    [Documentation]    [PRIVATE]    add parameters to nrbts object t4
    ...       :Autor: Sylvia Schneider
    Update Single Nrbts Parameter   actRrcInactState   intra-gNB
    FOR   ${param}   IN
    ...   <p name\="drbRrcInactInactivityTimerSA">5</p>
    ...   <p name\="maxUeRrcInactTime">60</p>
    ...   <p name\="rrcInactIMMSteeringEnabled">false</p>
    ...   <p name\="rrcInactLocationReportEnabled">false</p>
    ...   <p name\="rrcInactPreferredStateEnabled">false</p>
    ...   <p name\="tRanPagingGuard">4</p>
       Log To Console    add parameter "${param}" to ${bts_distName}
       Add Element        ${scf_xml}    ${param}   xpath=.//managedObject[@distName="${bts_distName}"]
    END


Add Parameters To NRPLMNSET SA-1 T4
    [Documentation]    [PRIVATE]    add parameters to NRPLMNSET_SA-1 t4
    ...       :Autor: Sylvia Schneider
    Log To Console    add parameter "<p name="ranAC">100</p>" to "${bts_distName}/NRCELL-1/NRPLMNSET_SA-1"
    Add Element        ${scf_xml}    <p name="ranAC">100</p>   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRPLMNSET_SA-1"]


Update Nrarfcn And Gscn For Cell2 T5 T6
    [Documentation]    [PRIVATE]    update nrarfcn and gsnc for cell2 t5_t6
    ...       :Autor: Sylvia Schneider
    Log To Console    set parameter "nrarfcn" in NRCELL-2 to value "647666"
    Set Element Text   ${scf_xml}    text=647666   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="nrarfcn"]
    Log To Console    set parameter "gscnOrSsPbchArfcn" in NRCELL-2 to value "7995"
    Set Element Text   ${scf_xml}    text=7995   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="gscnOrSsPbchArfcn"]


Update Add NRCELL-1 Parameters And Lists T5 T6
    [Documentation]    [PRIVATE]    update add NRCELL-1 parameters and lists t5_t6
    ...       :Autor: Sylvia Schneider
    ${xpath_nrcell-1}   Set Variable   managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${xpath_nrcell-2}   Set Variable   managedObject[@distName="${bts_distName}/NRCELL-2"]

    ${a4MeasHigherPrioFreqMaxReactSA}    Set Variable    <p name="a4MeasHigherPrioFreqMaxReactSA">1</p>
    Log To Console    add parameter "${a4MeasHigherPrioFreqMaxReactSA}" to "${bts_distName}/NRCELL-1"
    Add Element        ${scf_xml}     ${a4MeasHigherPrioFreqMaxReactSA}   xpath=.//${xpath_nrcell-1}
    ${a4MeasHigherPrioFreqMaxReactSA}    Set Variable    <p name="a4MeasHigherPrioFreqMaxReactSA">0</p>
    Add Element        ${scf_xml}     ${a4MeasHigherPrioFreqMaxReactSA}   xpath=.//${xpath_nrcell-2}

    Log To Console    set parameter "a1ThresholdhoSsbRsrp" in list a1MeashoPrefNRLayerSsbRsrpSA to value "108"
    Set Element Text   ${scf_xml}    text=108
    ...   xpath=.//${xpath_nrcell-1}/list[@name="a1MeashoPrefNRLayerSsbRsrpSA"]/item/p[@name="a1ThresholdhoSsbRsrp"]
    Log To Console    set parameter "a1ThresholdhoSsbRsrq" in list a1MeashoPrefNRLayerSsbRsrqSA to value "108"
    Set Element Text   ${scf_xml}    text=108
    ...   xpath=.//${xpath_nrcell-1}/list[@name="a1MeashoPrefNRLayerSsbRsrqSA"]/item/p[@name="a1ThresholdhoSsbRsrq"]


Set A1MeashoPrefNRLayerEnabledSA In NRCELL-1 To ${value}
    [Documentation]    [PRIVATE]    set a1MeashoPrefNRLayerEnabledSA in NRCELL-1
    ...       :Autor: Sylvia Schneider
    ${xpath_nrcell-1}   Set Variable   managedObject[@distName="${bts_distName}/NRCELL-1"]
    Log To Console    set parameter "a1MeashoPrefNRLayerEnabledSA" in NRCELL-1 to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}   xpath=.//${xpath_nrcell-1}/p[@name="a1MeashoPrefNRLayerEnabledSA"]


Update NRCELL-1 Parameters T7
    [Documentation]    [PRIVATE]    update NRCELL-1 parameters t7
    ...       :Autor: Sylvia Schneider
    FOR   ${param}                  ${value}    IN
    ...   a2MeasRedirectEnabled     rsrqCombined
    ...   a2MeashoEnabledSA         rsrq
    ...   a3MeasEnabled             rsrq
    ...   a5MeasEnabled             rsrq
       Update Single Nrcell-1 Parameter    param=${param}           value=${value}
    END


Update NRCELL-1 Parameters T8
    [Documentation]    [PRIVATE]    update NRCELL-1 parameters t8
    ...       :Autor: Sylvia Schneider
    FOR   ${param}                  ${value}    IN
    ...   a2MeasRedirectEnabled     rsrpAndRsrq
    ...   a2MeashoEnabledSA         rsrpAndRsrq
    ...   a3MeasEnabled             rsrpAndRsrq
    ...   a5MeasEnabled             rsrpAndRsrq
       Update Single Nrcell-1 Parameter    param=${param}           value=${value}
    END


Update Add MRBTS Parameter T8 T9
    [Documentation]    [PRIVATE]    update NRCELL-1 parameters t8_t9
    ...       :Autor: Sylvia Schneider
    FOR   ${param}               ${value}    IN
    ...   actIntraNrNgHo     sourceAndTarget
    ...   tNgRelocOverall    3000
    ...   tNgRelocPrep       2000
       Update Single Nrbts Parameter       param=${param}          value=${value}
    END

    FOR  ${param}   IN
    ...   <p name\="suppCnPartialAdNgHo">false</p>
    ...   <p name\="tNgRelocCancelN">2000</p>
    ...   <p name\="tNgRelocExecDeltL">5000</p>
    ...   <p name\="tNgRelocExecDeltN">3000</p>
    ...   <p name\="tNgRelocOverallN">3000</p>
    ...   <p name\="tNgRelocPrepN">2000</p>
       Log To Console    add parameter "${param}" to "${bts_distName}"
       Add Element        ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}"]
    END


Remove Parameter T8 T9
    [Documentation]    [PRIVATE]    remove parameter t8_t9
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${scf_file}
    scf.Load Scf     ${scf_file}
    Log To Console    remove parameter "xnLinkRef" in ${bts_distName}/NRADJGNB-1
    scf.Remove Element From Scf    dist_name=${bts_distName}/NRADJGNB-1       p_name=xnLinkRef
    Log To Console    remove element "${bts_distName}/XNLINK-1"
    scf.Remove Mo With Descendant Mos        dist_name=${bts_distName}/XNLINK-1
    scf.Save Scf     ${scf_file}


Update Nrbts Params ActRedirect ActMultiFrequencyBandIndicatorNRSupport RrcReestabTypeSA
    [Documentation]    [PRIVATE]    update nrbts params
    ...       :Autor: Sylvia Schneider
    FOR   ${param}                                   ${value}    IN
    ...   actRedirect                                true
    ...   actMultiFrequencyBandIndicatorNRSupport    true
    ...   rrcReestabTypeSA                           sameGNB
       Update Single Nrbts Parameter   ${param}      ${value}
    END


Add NrConnectModeProfileDN To Nrcell-1 Nrcell-2 Nrhoif-1
    [Documentation]    [PRIVATE]    add nrConnectModeProfileDN to nrcell-1 nrcell-2 nrhoif-1
    ...       :Autor: Sylvia Schneider
    ${nrConnectModeProfileDN}    Set Variable    <p name="nrConnectModeProfileDN">${bts_distName}/NRCONNECTMODE_PROFILE-1</p>
    FOR   ${object}   IN
    ...    NRCELL-1
    ...    NRCELL-1/NRHOIF-1
    ...    NRCELL-2
       Log To Console    add parameter "${nrConnectModeProfileDN}}" to ${object}
       Add Element       ${scf_xml}    ${nrConnectModeProfileDN}   xpath=.//managedObject[@distName="${bts_distName}/${object}"]
    END


Add NrConnectModeProfileDN To 2bands Nrcell Nrhoif
    [Documentation]    [PRIVATE]    add nrConnectModeProfileDN to 2bands nrcell nrhoif
    ...       :Autor: Sylvia Schneider

    FOR   ${object}             ${profile}     IN
    ...    NRCELL-1             NRCONNECTMODE_PROFILE-1
    ...    NRCELL-2/NRHOIF-1    NRCONNECTMODE_PROFILE-1
    ...    NRCELL-2             NRCONNECTMODE_PROFILE-2
    ...    NRCELL-1/NRHOIF-1    NRCONNECTMODE_PROFILE-2
       ${nrConnectModeProfileDN}    Set Variable    <p name="nrConnectModeProfileDN">${bts_distName}/${profile}</p>
       Log To Console    add parameter "${nrConnectModeProfileDN}" to ${object}
       Add Element       ${scf_xml}    ${nrConnectModeProfileDN}   xpath=.//managedObject[@distName="${bts_distName}/${object}"]
    END
