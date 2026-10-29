*** Settings ***
Documentation   This is a keyword file for CB008146-E-2cell, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${measurement_period_in_min}          5


*** Keywords ***

set sw release version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   split string    ${gnb_swVersion}    _
    set suite variable    ${release}   ${gnb_sw_version_parts}[0]


Update and activate SCF
    [Documentation]    [PRIVATE]    update SCF and activate on gNB
    ...       :Autor: Sylvia Schneider
    set sw release version
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB008146E.xml
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    Log To Console    remove element "redirFreqEutra" from NRCELL-1 and NRCELL-2 NRREDRT-0
    FOR   ${cell_id}   IN   1    2
        Remove Element     ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRREDRT-0"]/p[@name="redirFreqEutra"]
    END
    Log To Console    remove element ${bts_distName}/TRACKINGAREA-200
    Remove Element     ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/TRACKINGAREA-200"]

    FOR   ${param}   IN
    ...    actSliceAwareScheduler
    ...    actSliceAwareSchedulerUlAndEnh
    ...    actNormVCFallback
        Log To Console    set ${param} to false
        Set Element Text   ${scf_xml}    text=false       xpath=.//p[@name="${param}"]
    END

    Log To Console    NRMOPR_SA-1 set voiceFBMode to disabled
    Set Element Text   ${scf_xml}    text=disabled      xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRMOPR_SA-1"]/p[@name="voiceFBMode"]

    Log To Console    update list actVoiceFallbackDuringHOPrep to disabled
    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  Catenate  SEPARATOR=\n
    ...   <list name="actVoiceFallbackDuringHOPrep">
    ...   <p>disabled</p>
    ...   </list>
    Add Element  ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}"]

    FOR   ${object}      ${param}                       IN
    ...   /NRCELL-1      actEnhDtxOptimizedScheduler
    ...   /NRCELL-2      actEnhDtxOptimizedScheduler
    ...   /NRCELL-3      actEnhDtxOptimizedScheduler
    ...   /NRCELL-4      actEnhDtxOptimizedScheduler
      Log To Console    set in NRBTS-1${object} param ${param} to value "false"
      Set Element Text   ${scf_xml}    text=false       xpath=.//managedObject[@distName="${bts_distName}${object}"]/p[@name="${param}"]
    END

    FOR   ${cell_id}   ${list}   ${param}   ${value}    IN
    ...   1            a2MeasRedirectSsbRsrq   a2ThresholdRedirectSsbRsrq     30
    ...   2            a2MeasRedirectSsbRsrq   a2ThresholdRedirectSsbRsrq     30
    ...   3            a2MeasRedirectSsbRsrq   a2ThresholdRedirectSsbRsrq     30
    ...   4            a2MeasRedirectSsbRsrq   a2ThresholdRedirectSsbRsrq     30
    ...   3            a2MeasRedirectSsbRsrp   a2ThresholdRedirectSsbRsrp     33
    ...   4            a2MeasRedirectSsbRsrp   a2ThresholdRedirectSsbRsrp     33
       Log To Console    update NRCELL-${cell_id}, list ${list}, param ${param} to value ${value}
       ${xpath_cell}  Set Variable  managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]
       Set Element Text   ${scf_xml}    text=${value}       xpath=.//${xpath_cell}/list[@name="${list}"]/item/p[@name="${param}"]
    END

    update single parameter values
    add parameter values in NRBTS object
    add parameter values in NRCELL object
    add lists in NRCELL object
    create new objects
    create and update SNSSAI object
    update object NRREDRT-0
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB008146E.xml
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/SCFC_CB008146E.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/SCFC_CB008146E.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_CB008146E.xml finished
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


update object NRREDRT-0
    [Documentation]    [PRIVATE]    update parameter values of object NRREDRT-0 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating object NRREDRT-0
    FOR   ${cell}   IN   1   2
        ${freq}   Set Variable If    ${cell}==1    636666     647666
        ${NRREDRT-0_redirFreqNr}     set variable    <p name="redirFreqNr">${freq}</p>
        ${NRREDRT-0_redirSsbScs}     set variable    <p name="redirSsbScs">30 KHz</p>
        Add Element     ${scf_xml}    ${NRREDRT-0_redirFreqNr}    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell}/NRREDRT-0"]
        Add Element     ${scf_xml}    ${NRREDRT-0_redirSsbScs}    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell}/NRREDRT-0"]
        Set Element Text   ${scf_xml}    text=nr    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell}/NRREDRT-0"]/p[@name="redirRat"]
   END


update single parameter values
    [Documentation]    [PRIVATE]    update single parameter values in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started

    Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="miNrNRMOP"]
    Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="miNrRelReportCu"]

    Set Element Text   ${scf_xml}    text=true      xpath=.//p[@name="actInterFreqHoSA"]
    Set Element Text   ${scf_xml}    text=true      xpath=.//p[@name="actIntraFreqHoSA"]
    Set Element Text   ${scf_xml}    text=true      xpath=.//p[@name="actMobilityProfile"]
    Set Element Text   ${scf_xml}    text=true      xpath=.//p[@name="actRedirect"]
    Set Element Text   ${scf_xml}    text=true      xpath=.//p[@name="actRfspIndex"]
    Set Element Text   ${scf_xml}    text=7200      xpath=.//p[@name="drbInactivityTimerSA"]
    Set Element Text   ${scf_xml}    text=1000      xpath=.//p[@name="nsaInactivityTimer"]
    Set Element Text   ${scf_xml}    text=false     xpath=.//p[@name="actPucchF3BasedTaGrantsRed"]

    ${xpath_a2ThresholdRedirectSsbRsrp}   set variable
    ...    list[@name="a2MeasRedirectSsbRsrp"]/item/p[@name="a2ThresholdRedirectSsbRsrp"]
    FOR    ${i}   IN   1   2
       Set Element Text   ${scf_xml}   text=rsrp   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/p[@name="a1MeashoEnabled"]
       Set Element Text   ${scf_xml}   text=rsrp   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/p[@name="a1MeashoEnabledSA"]
       Set Element Text   ${scf_xml}   text=rsrp   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/p[@name="a2MeasRedirectEnabled"]
       Set Element Text   ${scf_xml}   text=rsrp   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/p[@name="a2MeashoEnabled"]
       Set Element Text   ${scf_xml}   text=rsrp   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/p[@name="a2MeashoEnabledSA"]
       Set Element Text   ${scf_xml}   text=rsrp   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/p[@name="a3MeasEnabled"]
       Set Element Text   ${scf_xml}   text=rsrp   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/p[@name="a5MeasEnabled"]
       Set Element Text   ${scf_xml}   text=25
       ...   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/${xpath_a2ThresholdRedirectSsbRsrp}
    END
    Set Element Text   ${scf_xml}   text=647666   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="nrarfcn"]
    Set Element Text   ${scf_xml}   text=636666   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="nrarfcn"]
    Set Element Text   ${scf_xml}   text=7995     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="gscnOrSsPbchArfcn"]
    Set Element Text   ${scf_xml}   text=7880     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="gscnOrSsPbchArfcn"]

    FOR    ${i}   IN   1   2   3   4
       Set Element Text   ${scf_xml}   text=balancedChoice
       ...                 xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/p[@name="measGapSelection"]
       Set Element Text   ${scf_xml}   text=${bts_distName}/NRMOPR_SA-32
       ...   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]/p[@name="nrDefMoPrSaDN"]

    END


add parameter values in NRBTS object
    [Documentation]    [PRIVATE]    add parameter values in NRBTS object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    adding parameter values in NRBTS object - started
    ${timerXnDataFwdGuard}    set variable    <p name="timerXnDataFwdGuard">250</p>
    Add Element     ${scf_xml}     ${timerXnDataFwdGuard}   xpath=.//managedObject[@distName="${bts_distName}"]
    Log To Console    adding parameter values in NRBTS object - finished


add parameter values in NRCELL object
    [Documentation]    [PRIVATE]    add parameter values in NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    adding parameter values in NRCELL object - started
    ${absThreshSsbRsrpConsolidation}    set variable    <p name="absThreshSsbRsrpConsolidation">0</p>
    ${absThreshSsbRsrqConsolidation}    set variable    <p name="absThreshSsbRsrqConsolidation">2</p>
    ${mgta}                             set variable    <p name="mgta">ms0</p>
    ${sMeasConfigSsbRsrp}               set variable    <p name="sMeasConfigSsbRsrp">0</p>
    FOR    ${i}   IN   1   2
       Add Element   ${scf_xml}   ${absThreshSsbRsrpConsolidation}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
       Add Element   ${scf_xml}   ${absThreshSsbRsrqConsolidation}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
       Add Element   ${scf_xml}   ${mgta}                            xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
       Add Element   ${scf_xml}   ${sMeasConfigSsbRsrp}              xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
    END

    ${nrDefMoPrNsaDN}          set variable    <p name="nrDefMoPrNsaDN">${bts_distName}/NRMOPR_NSA-1</p>
    ${NRPLMNSET_SA-1_plmn}     set variable    <p>${bts_distName}/NRPLMN-2</p>
    ${measGapSelectionSA}               set variable    <p name="measGapSelectionSA">balancedChoice</p>
    FOR    ${i}   IN   1   2   3  4
       Add Element   ${scf_xml}   ${NRPLMNSET_SA-1_plmn}
       ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}/NRPLMNSET_SA-1"]/list[@name="nrPlmnDNList"]
       Log To Console    adding parameter "${NRPLMNSET_SA-1_plmn}" to NRCELL${i}/NRPLMNSET_SA-1 nrPlmnDNList
       Add Element   ${scf_xml}   ${nrDefMoPrNsaDN}                  xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
       Log To Console    adding parameter "${nrDefMoPrNsaDN}" to NRCELL${i}
       Add Element   ${scf_xml}   ${measGapSelectionSA}              xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
       Log To Console    adding parameter "${measGapSelectionSA}" to NRCELL${i}
    END
    Log To Console    adding parameter values in NRCELL object - finished


add lists in NRCELL object
    [Documentation]    [PRIVATE]    add lists in NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    create lists in NRCELL object - started
    Create a1MeashoSsbRsrpSA
    Create a1MeashoSsbRsrqSA
    Create a2MeashoSsbRsrpSA
    Create a2MeashoSsbRsrqSA
    Create a3MeasSsbRsrp
    Create a5MeasSsbRsrp


Create a1MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create list a1MeashoSsbRsrpSA and add it in NRCELL object
    ...       :Autor: Sylvia Schneider
    ${a1MeashoSsbRsrpSA}    set variable    <list name="a1MeashoSsbRsrpSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a1HysteresishoSsbRsrpSA">0</p>
           ...    <p name="a1HysteresisHoSsbRsrpVoNr">0</p>
           ...    <p name="a1ThresholdhoSsbRsrpSA">39</p>
           ...    <p name="a1ThresholdHoSsbRsrpVoNr">60</p>
           ...    <p name="a1TimeToTriggerhoSsbRsrpSA">ms480</p>
           ...    <p name="a1TimeToTriggerHoSsbRsrpVoNr">ms480</p>
           ...    </item>
           ...    </list>
           ${a1MeashoSsbRsrpSA}    Catenate     SEPARATOR=\n   ${a1MeashoSsbRsrpSA}   ${line}
    END
    FOR    ${i}   IN   1   2   3  4
       Add Element     ${scf_xml}     ${a1MeashoSsbRsrpSA}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
    END


Create a1MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create list a1MeashoSsbRsrqSA and add it in NRCELL object
    ...       :Autor: Sylvia Schneider
    ${a1MeashoSsbRsrqSA}    set variable    <list name="a1MeashoSsbRsrqSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a1HysteresishoSsbRsrqSA">0</p>
           ...    <p name="a1HysteresisHoSsbRsrqVoNr">0</p>
           ...    <p name="a1ThresholdhoSsbRsrqSA">36</p>
           ...    <p name="a1ThresholdHoSsbRsrqVoNr">63</p>
           ...    <p name="a1TimeToTriggerhoSsbRsrqSA">ms480</p>
           ...    <p name="a1TimeToTriggerHoSsbRsrqVoNr">ms480</p>
           ...    </item>
           ...    </list>
           ${a1MeashoSsbRsrqSA}    Catenate     SEPARATOR=\n   ${a1MeashoSsbRsrqSA}   ${line}
    END
    FOR    ${i}   IN   1   2   3  4
       Add Element     ${scf_xml}     ${a1MeashoSsbRsrqSA}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
    END


Create a2MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create list a2MeashoSsbRsrpSA and add it in NRCELL object
    ...       :Autor: Sylvia Schneider
    ${a2MeashoSsbRsrpSA}    set variable    <list name="a2MeashoSsbRsrpSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a2HysteresishoSsbRsrpSA">0</p>
           ...    <p name="a2HysteresisHoSsbRsrpVoNr">0</p>
           ...    <p name="a2ThresholdhoSsbRsrpSA">34</p>
           ...    <p name="a2ThresholdHoSsbRsrpVoNr">44</p>
           ...    <p name="a2TimeToTriggerhoSsbRsrpSA">ms480</p>
           ...    <p name="a2TimeToTriggerHoSsbRsrpVoNr">ms480</p>
           ...    </item>
           ...    </list>
           ${a2MeashoSsbRsrpSA}    Catenate     SEPARATOR=\n   ${a2MeashoSsbRsrpSA}   ${line}
    END
    FOR    ${i}   IN   1   2   3  4
       Add Element     ${scf_xml}     ${a2MeashoSsbRsrpSA}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
    END


Create a2MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create list a2MeashoSsbRsrqSA and add it in NRCELL object
    ...       :Autor: Sylvia Schneider
    ${a2MeashoSsbRsrqSA}    set variable    <list name="a2MeashoSsbRsrqSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a2HysteresishoSsbRsrqSA">0</p>
           ...    <p name="a2HysteresisHoSsbRsrqVoNr">0</p>
           ...    <p name="a2ThresholdhoSsbRsrqSA">31</p>
           ...    <p name="a2ThresholdHoSsbRsrqVoNr">49</p>
           ...    <p name="a2TimeToTriggerhoSsbRsrqSA">ms480</p>
           ...    <p name="a2TimeToTriggerHoSsbRsrqVoNr">ms480</p>
           ...    </item>
           ...    </list>
           ${a2MeashoSsbRsrqSA}    Catenate     SEPARATOR=\n   ${a2MeashoSsbRsrqSA}   ${line}
    END
    FOR    ${i}   IN   1   2   3  4
       Add Element     ${scf_xml}     ${a2MeashoSsbRsrqSA}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${i}"]
    END


Create a3MeasSsbRsrp
    [Documentation]    [PRIVATE]    create list a3MeasSsbRsrp and add it in NRCELL object
    ...       :Autor: Sylvia Schneider
    ${a3MeasSsbRsrp}    set variable    <list name="a3MeasSsbRsrp">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrp">0</p>
           ...    <p name="a3OffsetSsbRsrp">6</p>
           ...    <p name="a3TimeToTriggerSsbRsrp">ms320</p>
           ...    </item>
           ...    </list>
           ${a3MeasSsbRsrp}    Catenate     SEPARATOR=\n   ${a3MeasSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrp}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Add Element     ${scf_xml}     ${a3MeasSsbRsrp}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Create a5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create list a5MeasSsbRsrp and add it in NRCELL object
    ...       :Autor: Sylvia Schneider
    ${a5MeasSsbRsrp}    set variable    <list name="a5MeasSsbRsrp">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a5HysteresisSsbRsrp">0</p>
           ...    <p name="a5Threshold1SsbRsrp">52</p>
           ...    <p name="a5Threshold2SsbRsrp">54</p>
           ...    <p name="a5TimeToTriggerSsbRsrp">ms100</p>
           ...    </item>
           ...    </list>
           ${a5MeasSsbRsrp}    Catenate     SEPARATOR=\n   ${a5MeasSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a5MeasSsbRsrp}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Add Element     ${scf_xml}     ${a5MeasSsbRsrp}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


create new objects
    [Documentation]    [PRIVATE]    create objects in SCF
    ...       :Autor: Sylvia Schneider
    Create NRHOIF
    Create NRREL
    Create NRMEASCFG_IF
    Create NRMOPRMA_SA-1
    Create NRMOPRMA_SA-2
    Create NRMOPRMA_SA-3
    Create NRMOPRMA_SA-4
    Create NRMOPRMA_SA-5
    Create NRMOPR_NSA
    Update NRMOPR_SA-1
    Create NRMOPR_SA
    Create NRMOPR_SA-32
    Create NRMORED-1
    Create NRMORED-2
    Create NRPLMN-2


Create NRHOIF
    [Documentation]    [PRIVATE]    create NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${object_instance}   ${ssbFrequency}   IN
    ...    1                    636576
    ...    2                    647616
       Create single NRHOIF   ${object_instance}   ${ssbFrequency}
    END


Create single NRHOIF
    [Documentation]    [PRIVATE]    create single NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${Id}   ${ssbFrequency}
    Log To Console    Building object ${bts_distName}/NRCELL-${Id}/NRHOIF-1
    ${NRHOIF}    set variable   <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-${Id}/NRHOIF-1"
    ${NRHOIF}   Catenate     SEPARATOR=${SPACE}   ${NRHOIF}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1BasedPCellSwitchEnabled">false</p>
           ...    <p name="a2BasedPCellSwitchEnabled">false</p>
           ...    <p name="a3MeasEnabled">rsrp</p>
           ...    <p name="a4MeasEnDcSteeringEnabled">none</p>
           ...    <p name="a4MeasHigherPrioFreqEnabled">none</p>
           ...    <p name="a4MeasNrDcEnabled">none</p>
           ...    <p name="a4MeasSCellAddEnabled">none</p>
           ...    <p name="a5MeasEnabled">rsrpCombined</p>
           ...    <p name="cellDepType">SA</p>
           ...    <p name="freqBandIndicatorNR">78</p>
           ...    <p name="ifhoSsbScs">30 KHz</p>
           ...    <p name="ifhoSsbSmtcDuration">sf5</p>
           ...    <p name="ifhoSsbSmtcPeriodicity">sf20</p>
           ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
           ...    <p name="scs">30 KHz</p>
           ...    <p name="ssBurstSetPeriod">10</p>
           ...    <p name="ssbFrequency">${ssbFrequency}</p>
           ...    <list name="a3MeasSsbRsrp">
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrp">1</p>
           ...    <p name="a3OffsetSsbRsrp">10</p>
           ...    <p name="a3TimeToTriggerSsbRsrp">ms0</p>
           ...    </item>
           ...    </list>
           ...    <list name="a3MeasSsbRsrq">
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrq">2</p>
           ...    <p name="a3OffsetSsbRsrq">10</p>
           ...    <p name="a3TimeToTriggerSsbRsrq">ms40</p>
           ...    </item>
           ...    </list>
           ...    <list name="a5MeasSsbRsrp">
           ...    <item>
           ...    <p name="a5HysteresisSsbRsrp">0</p>
           ...    <p name="a5Threshold1SsbRsrp">102</p>
           ...    <p name="a5Threshold2SsbRsrp">92</p>
           ...    <p name="a5TimeToTriggerSsbRsrp">ms480</p>
           ...    </item>
           ...    </list>
           ...    <list name="a5MeasSsbRsrq">
           ...    <item>
           ...    <p name="a5HysteresisSsbRsrq">0</p>
           ...    <p name="a5Threshold1SsbRsrq">40</p>
           ...    <p name="a5Threshold2SsbRsrq">30</p>
           ...    <p name="a5TimeToTriggerSsbRsrq">ms480</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRHOIF}   Catenate     SEPARATOR=\n         ${NRHOIF}   ${line}
    END
    Add Element     ${scf_xml}     ${NRHOIF}           xpath=.//cmData


Create NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${object_instance}   ${lcrId}   IN
    ...    1                    2
    ...    2                    1
       Create single NRREL   ${object_instance}   ${lcrId}
    END


Create single NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${Id}   ${lcrId}
    Log To Console    \nBuilding object ${bts_distName}/NRCELL-${Id}/NRREL-1
    ${NRREL}   set variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-${Id}/NRREL-1"
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellIndividualSsbRsrpOffset">-2dB</p>
           ...    <p name="cellIndividualSsbRsrqOffset">-2dB</p>
           ...    <p name="gNbId">1</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="handoverAllowedSA">allowed</p>
           ...    <p name="handoverAllowedSARedCap">forbidden</p>
           ...    <p name="isRplCellForPSCell">false</p>
           ...    <p name="lcrId">${lcrId}</p>
           ...    <p name="nrDcAllowed">false</p>
           ...    <p name="removeNotAllowed">false</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">311</p>
           ...    <p name="mnc">489</p>
           ...    <p name="mncLength">3</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRREL}   Catenate     SEPARATOR=\n         ${NRREL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREL}           xpath=.//cmData


Create NRMEASCFG_IF
    [Documentation]    [PRIVATE]    create NRMEASCFG_IF object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRMEASCFG_IF-1
    ${NRMEASCFG_IF-1}   set variable   <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-1"
    ${NRMEASCFG_IF-1}   Catenate     SEPARATOR=${SPACE}   ${NRMEASCFG_IF-1}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a3MeasEnabled">none</p>
           ...    <p name="a5MeasEnabled">rsrpCombined</p>
           ...    <p name="freqBandIndicatorNR">78</p>
           ...    <p name="ssbFrequency">647616</p>
           ...    </managedObject>
           ${NRMEASCFG_IF-1}   Catenate     SEPARATOR=\n         ${NRMEASCFG_IF-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMEASCFG_IF-1}           xpath=.//cmData

    Log To Console    Building object ${bts_distName}/NRCELL-1/NRMEASCFG_IF-2
    ${NRMEASCFG_IF-2}   set variable   <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-2"
    ${NRMEASCFG_IF-2}   Catenate     SEPARATOR=${SPACE}   ${NRMEASCFG_IF-2}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a3MeasEnabled">rsrpCombined</p>
           ...    <p name="a5MeasEnabled">none</p>
           ...    <p name="freqBandIndicatorNR">78</p>
           ...    <p name="ssbFrequency">636576</p>
           ...    </managedObject>
           ${NRMEASCFG_IF-2}   Catenate     SEPARATOR=\n         ${NRMEASCFG_IF-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMEASCFG_IF-2}           xpath=.//cmData


Create NRMOPRMA_SA-1
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-1
    ${NRMOPRMA_SA-1}   set variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-1"
    ${NRMOPRMA_SA-1}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-1}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">1</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-1</p>
           ...    <p name="rfspIndex">1</p>
           ...    <p name="rfspIndexLast">100</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-2</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-1}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-1}           xpath=.//cmData


Create NRMOPRMA_SA-2
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-2
    ${NRMOPRMA_SA-2}   set variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-2"
    ${NRMOPRMA_SA-2}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-2}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">2</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-2</p>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-2</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-2}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-2}           xpath=.//cmData


Create NRMOPRMA_SA-3
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-3
    ${NRMOPRMA_SA-3}   set variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-3"
    ${NRMOPRMA_SA-3}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-3}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">3</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-3</p>
           ...    <p name="rfspIndex">51</p>
           ...    <p name="rfspIndexLast">98</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-1</p>
           ...    </list>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-3}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-3}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-3}           xpath=.//cmData


Create NRMOPRMA_SA-4
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-4 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-4
    ${NRMOPRMA_SA-4}   set variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-4"
    ${NRMOPRMA_SA-4}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-4}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">4</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-4</p>
           ...    <p name="rfspIndex">99</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-1</p>
           ...    </list>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-4}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-4}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-4}           xpath=.//cmData


Create NRMOPRMA_SA-5
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-5 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-5
    ${NRMOPRMA_SA-5}   set variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-5"
    ${NRMOPRMA_SA-5}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-5}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">5</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-5</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-2</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-5}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-5}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-5}           xpath=.//cmData


Create NRMOPR_NSA
    [Documentation]    [PRIVATE]    create NRMOPR_NSA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-1
    ${NRMOPR_NSA-1}   set variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-1"
    ${NRMOPR_NSA-1}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_NSA-1}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1MeashoEnabled">none</p>
           ...    <p name="a2MeashoEnabled">none</p>
           ...    </managedObject>
           ${NRMOPR_NSA-1}   Catenate     SEPARATOR=\n         ${NRMOPR_NSA-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_NSA-1}           xpath=.//cmData


Update NRMOPR_SA-1
    [Documentation]    [PRIVATE]    update NRMOPR_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Update object ${bts_distName}/NRMOPR_SA-1
    ${a1MeashoEnabledSA}    set Variable    <p name="a1MeashoEnabledSA">rsrp</p>
    ${a2MeashoEnabledSA}    set Variable    <p name="a2MeashoEnabledSA">rsrp</p>
    Add Element     ${scf_xml}     ${a1MeashoEnabledSA}         xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]
    Add Element     ${scf_xml}     ${a2MeashoEnabledSA}         xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]
    Set Element Text   ${scf_xml}    text=rsrp     xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]/p[@name="a2MeasRedirectEnabled"]
    ${nrMeasCfgIfDNList}    set variable     <list name="nrMeasCfgIfDNList">
    FOR    ${line}   IN
           ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
           ...    <p>${bts_distName}/NRMEASCFG_IF-2</p>
           ...    </list>
           ${nrMeasCfgIfDNList}    Catenate     SEPARATOR=\n   ${nrMeasCfgIfDNList}   ${line}
    END
    Add Element     ${scf_xml}     ${nrMeasCfgIfDNList}   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]
    ${nrMoRedDNList}    set variable     <list name="nrMoRedDNList">
    FOR    ${line}   IN
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    <p>${bts_distName}/NRMORED-2</p>
           ...    </list>
           ${nrMoRedDNList}    Catenate     SEPARATOR=\n   ${nrMoRedDNList}   ${line}
    END
    Add Element     ${scf_xml}     ${nrMoRedDNList}   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]


Create NRMOPR_SA
    [Documentation]    [PRIVATE]    create NRMOPR_SA object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${object_instance}  ${SAa1a2}   IN
    ...    2                   rsrpCombined
    ...    3                   rsrpCombined
    ...    4                   rsrpCombined
    ...    5                   rsrp
       Run Keyword     Create single NRMOPR_SA   ${object_instance}    ${SAa1a2}
    END


Create single NRMOPR_SA
    [Documentation]    [PRIVATE]    create single NRMOPR_SA object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${id}   ${SAa1a2}
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-${id}
    ${NRMOPR_SA}   set variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-${id}"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1MeashoEnabledSA">${SAa1a2}</p>
           ...    <p name="a2MeasRedirectEnabled">rsrp</p>
           ...    <p name="a2MeashoEnabledSA">${SAa1a2}</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMeasCfgIfDNList">
           ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
           ...    <p>${bts_distName}/NRMEASCFG_IF-2</p>
           ...    </list>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    <p>${bts_distName}/NRMORED-2</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-32
    [Documentation]    [PRIVATE]    create NRMOPR_SA-32 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-32
    ${NRMOPR_SA}   set variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-32"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1MeashoEnabledSA">none</p>
           ...    <p name="a2MeasRedirectEnabled">none</p>
           ...    <p name="a2MeashoEnabledSA">none</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMORED-1
    [Documentation]    [PRIVATE]    create NRMORED-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMORED-1
    ${NRMORED}   set variable   <managedObject class="NRMORED" distName="${bts_distName}/NRMORED-1"
    ${NRMORED}   Catenate     SEPARATOR=${SPACE}   ${NRMORED}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="redirFreqNr">647666</p>
           ...    <p name="redirPrio">1</p>
           ...    <p name="redirRat">nr</p>
           ...    </managedObject>
           ${NRMORED}   Catenate     SEPARATOR=\n         ${NRMORED}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMORED}           xpath=.//cmData


Create NRMORED-2
    [Documentation]    [PRIVATE]    create NRMORED-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMORED-2
    ${NRMORED}   set variable   <managedObject class="NRMORED" distName="${bts_distName}/NRMORED-2"
    ${NRMORED}   Catenate     SEPARATOR=${SPACE}   ${NRMORED}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="redirFreqNr">636666</p>
           ...    <p name="redirPrio">2</p>
           ...    <p name="redirRat">nr</p>
           ...    </managedObject>
           ${NRMORED}   Catenate     SEPARATOR=\n         ${NRMORED}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMORED}           xpath=.//cmData


Create NRPLMN-2
    [Documentation]    [PRIVATE]    create NRPLMN-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRPLMN-2
    ${NRPLMN-2}   set variable   <managedObject class="NRPLMN" distName="${bts_distName}/NRPLMN-2"
    ${NRPLMN-2}   Catenate     SEPARATOR=${SPACE}   ${NRPLMN-2}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mcc">311</p>
           ...    <p name="mnc">388</p>
           ...    <p name="mncLength">3</p>
           ...    </managedObject>
           ${NRPLMN-2}   Catenate     SEPARATOR=\n         ${NRPLMN-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRPLMN-2}           xpath=.//cmData


create and update SNSSAI object
    [Documentation]    [PRIVATE]    update SNSSAI-1 and create SNSSAI-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Add Element     ${scf_xml}     <p>${bts_distName}/NRPLMN-2</p>
    ...   xpath=.//managedObject[@distName="${bts_distName}/SNSSAI-1"]/list[@name="nrPlmnDNList"]

    ${TRACKINGAREA}   set variable   <managedObject class="TRACKINGAREA" distName="${bts_distName}/TRACKINGAREA-200"
    ${TRACKINGAREA}   Catenate     SEPARATOR=${SPACE}   ${TRACKINGAREA}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="fiveGsTac">200</p>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">MRBTS-1/NRBTS-1/SNSSAI-1</p>
           ...    </item>
           ...    <item>
           ...    <p name="snssaiDN">MRBTS-1/NRBTS-1/SNSSAI-2</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${TRACKINGAREA}   Catenate     SEPARATOR=\n         ${TRACKINGAREA}   ${line}
    END
    Add Element     ${scf_xml}     ${TRACKINGAREA}           xpath=.//cmData

    ${SNSSAI-2}   set variable   <managedObject class="SNSSAI" distName="${bts_distName}/SNSSAI-2"
    ${SNSSAI-2}   Catenate     SEPARATOR=${SPACE}   ${SNSSAI-2}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="administrativeState">Unlocked</p>
           ...    <p name="sd">13714342</p>
           ...    <p name="sst">1</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-1</p>
           ...    <p>${bts_distName}/NRPLMN-2</p>
           ...    </list>
           ...    </managedObject>
           ${SNSSAI-2}   Catenate     SEPARATOR=\n         ${SNSSAI-2}   ${line}
    END
    Add Element     ${scf_xml}     ${SNSSAI-2}           xpath=.//cmData
