*** Settings ***
Documentation   This is a keyword file for 5GC000710-A-2cell, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${measurement_period_in_min}          5
${class_NRCELL}                       class="com.nokia.srbts.nrbts:NRCELL"
${cell1_distName}                      NRCELL-1
${cell2_distName}                      NRCELL-2


*** Keywords ***

set sw release version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   split string    ${gnb_swVersion}    _
    set suite variable    ${release}   ${gnb_sw_version_parts}[0]


Update and activate SCF 2 cell config
    [Documentation]    [PRIVATE]    update SCF and activate on gNB
    ...       :Autor: Sylvia Schneider
    set sw release version
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_710A.xml
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    FOR   ${param}   IN
    ...   actRedirect
    ...   actNormVCFallback
    ...   actVoFallBackLteB1MeaBaRedir
       Log To Console    set parameter ${param} to false
       Set Element Text   ${scf_xml}    text=false      xpath=.//p[@name="${param}"]
    END

    Log To Console    update list actVoiceFallbackDuringHOPrep to disabled
    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  Catenate  SEPARATOR=\n
    ...   <list name="actVoiceFallbackDuringHOPrep">
    ...   <p>disabled</p>
    ...   </list>
    Add Element  ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}"]

    Log To Console    NRMOPR_SA-1 set voiceFBMode to disabled
    Set Element Text   ${scf_xml}    text=disabled      xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRMOPR_SA-1"]/p[@name="voiceFBMode"]

    update single parameter values
    add lists in NRCELL object
    add parameter values in NRCELL object
    create new objects
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_710A.xml
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/SCFC_710A.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/SCFC_710A.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_710A.xml finished
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


update single parameter values
    [Documentation]    [PRIVATE]    update single parameter values in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started
    FOR     ${param}   IN
    ...    actInterFreqInterGnbMobilityNSA
    ...    actInterFreqIntraGnbMobilityNSA
    ...    actIntraFreqInterGnbMobilityNSA3x
    ...    actIntraFreqIntraGnbMobilityNSA
    ...    actMobilityProfile
    ...    actSPID
       Set Element Text   ${scf_xml}    text=true      xpath=.//p[@name="${param}"]
    END

    FOR     ${xpath}   IN
    ...    managedObject[@distName\="${bts_distName}/${cell1_distName}"]
    ...    managedObject[@distName\="${bts_distName}/${cell2_distName}"]
       Set Element Text   ${scf_xml}    text=rsrp      xpath=.//${xpath}/p[@name="a1MeashoEnabled"]
       Set Element Text   ${scf_xml}    text=rsrp      xpath=.//${xpath}/p[@name="a2MeashoEnabled"]
       Set Element Text   ${scf_xml}    text=balancedChoice    xpath=.//${xpath}/p[@name="measGapSelection"]
    END

    FOR     ${xpath}   IN
    ...    managedObject[@distName\="${bts_distName}/${cell1_distName}"]
    ...    managedObject[@distName\="${bts_distName}/${cell2_distName}"]
        Set Element Text   ${scf_xml}    text=rsrp      xpath=.//${xpath}/p[@name="a3MeasEnabled"]
        Set Element Text   ${scf_xml}    text=rsrp      xpath=.//${xpath}/p[@name="a5MeasEnabled"]
    END

    FOR     ${param}            ${value}    ${cell}    IN
    ...    gscnOrSsPbchArfcn    7995        1
    ...    gscnOrSsPbchArfcn    7880        2
    ...    nrarfcn              647666      1
    ...    nrarfcn              636666      2
       Set Element Text   ${scf_xml}   text=${value}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell}"]/p[@name="${param}"]
    END

    Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="reportingIntervalPm"]
    Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="miNrNRMOP"]
    Log To Console    updating single parameter values - finished


add parameter values in NRCELL object
    [Documentation]    [PRIVATE]    add parameter values in NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    adding parameter values in NRCELL object - started
    ${measGapSelectionSA}      set variable    <p name="measGapSelectionSA">balancedChoice</p>
    ${mgta}                    set variable    <p name="mgta">ms0</p>
    ${sMeasConfigSsbRsrp}      set variable    <p name="sMeasConfigSsbRsrp">4</p>
    ${abs1}                    set variable  <p name="absThreshSsbRsrpConsolidation">1</p>
    ${abs2}                    set variable  <p name="absThreshSsbRsrqConsolidation">2</p>
    ${NRPLMNSET_NSA-1_plmn}    set variable    <p>${bts_distName}/NRPLMN-2</p>

    FOR     ${xpath}   IN
    ...    managedObject[@distName\="${bts_distName}/${cell1_distName}"]
    ...    managedObject[@distName\="${bts_distName}/${cell2_distName}"]
        Add Element     ${scf_xml}     ${measGapSelectionSA}      xpath=.//${xpath}
        Add Element     ${scf_xml}     ${mgta}                    xpath=.//${xpath}
        Add Element     ${scf_xml}     ${sMeasConfigSsbRsrp}      xpath=.//${xpath}
        Add Element     ${scf_xml}     ${abs1}                    xpath=.//${xpath}
        Add Element     ${scf_xml}     ${abs2}                    xpath=.//${xpath}
    END

    ${nrDefMoPrNsaDN}          set variable    <p name="nrDefMoPrNsaDN">${bts_distName}/NRMOPR_NSA-32</p>
    FOR     ${cell_id}   IN   1   2   3   4
       ${xpath}   set variable   managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]
       Add Element     ${scf_xml}     ${nrDefMoPrNsaDN}          xpath=.//${xpath}
    END

    FOR     ${xpath}   IN
    ...    managedObject[@distName\="${bts_distName}/${cell1_distName}/NRPLMNSET_NSA-1"]/list[@name\="nrPlmnDNList"]
    ...    managedObject[@distName\="${bts_distName}/${cell2_distName}/NRPLMNSET_NSA-1"]/list[@name\="nrPlmnDNList"]
       Add Element     ${scf_xml}     ${NRPLMNSET_NSA-1_plmn}   xpath=.//${xpath}
    END
    Log To Console    adding parameter values in NRCELL object - finished


add lists in NRCELL object
    [Documentation]    [PRIVATE]    add lists in NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    create lists in NRCELL object - started
    FOR     ${list}   IN
    ...    a5MeasSsbRsrp
    ...    a5MeasSsbRsrq
    ...    a3MeasSsbRsrp
    ...    a3MeasSsbRsrq
        run keyword    Create ${list}
    END
    Log To Console    create lists in NRCELL object - finished


Create a3MeasSsbRsrp
    [Documentation]    [PRIVATE]    create list a3MeasSsbRsrp and add it in NRCELL object
    ...       :Autor: Sylvia Schneider
    ${a3MeasSsbRsrp}    set variable    <list name="a3MeasSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">1</p>
    ...    <p name="a3OffsetSsbRsrp">10</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms0</p>
    ...    </item>
    ...    </list>
           ${a3MeasSsbRsrp}    Catenate     SEPARATOR=\n   ${a3MeasSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrp}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Add Element     ${scf_xml}     ${a3MeasSsbRsrp}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Create a3MeasSsbRsrq
    [Documentation]    [PRIVATE]    create list a3MeasSsbRsrq and add it in NRCELL object
    ...       :Autor: Sylvia Schneider
    ${a3MeasSsbRsrq}    set variable    <list name="a3MeasSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">2</p>
    ...    <p name="a3OffsetSsbRsrq">10</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms40</p>
    ...    </item>
    ...    </list>
           ${a3MeasSsbRsrq}    Catenate     SEPARATOR=\n   ${a3MeasSsbRsrq}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrq}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Add Element     ${scf_xml}     ${a3MeasSsbRsrq}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Create a5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create list a5MeasSsbRsrp and add it in NRCELL-1 object
    ...       :Autor: Sylvia Schneider
    ${a5MeasSsbRsrp}    set variable     <list name="a5MeasSsbRsrp">
    FOR    ${line}   IN
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">52</p>
    ...    <p name="a5Threshold2SsbRsrp">54</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms100</p>
    ...    </item>
    ...    </list>
           ${a5MeasSsbRsrp}    Catenate     SEPARATOR=\n   ${a5MeasSsbRsrp}   ${line}
    END
    FOR     ${xpath}   IN
    ...    managedObject[@distName\="${bts_distName}/${cell1_distName}"]
    ...    managedObject[@distName\="${bts_distName}/${cell2_distName}"]
           Add Element     ${scf_xml}     ${a5MeasSsbRsrp}   xpath=.//${xpath}
    END


Create a5MeasSsbRsrq
    [Documentation]    [PRIVATE]    create list a5MeasSsbRsrq and add it in NRCELL-1 object
    ...       :Autor: Sylvia Schneider
    ${a5MeasSsbRsrq}    set variable     <list name="a5MeasSsbRsrq">
    FOR    ${line}   IN
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">40</p>
    ...    <p name="a5Threshold2SsbRsrq">30</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
           ${a5MeasSsbRsrq}    Catenate     SEPARATOR=\n   ${a5MeasSsbRsrq}   ${line}
    END
    FOR     ${xpath}   IN
    ...    managedObject[@distName\="${bts_distName}/${cell1_distName}"]
    ...    managedObject[@distName\="${bts_distName}/${cell2_distName}"]
           Add Element     ${scf_xml}     ${a5MeasSsbRsrq}   xpath=.//${xpath}
    END


create new objects
    [Documentation]    [PRIVATE]    create objects in SCF
    ...       :Autor: Sylvia Schneider
    Create NRHOIF-1    cell_id=1
    Create NRHOIF-1    cell_id=2
    Create NRMEASCFG_IF-1
    Create NRMEASCFG_IF-2
    FOR    ${obj_id}   IN  1   2   3   4
       run keyword    Create NRMOPRMA_NSA-${obj_id}
    END
    FOR    ${obj_id}   IN  1   2   3   32   4
       run keyword    Create NRMOPR_NSA-${obj_id}
    END
    Create NRPLMN-2
    Create NRREL


Create NRREL
    FOR    ${NRCELL}    ${lcrId}   IN
    ...    1            2
    ...    2            1
       Log To Console    Building object ${bts_distName}/NRCELL-${NRCELL}/NRREL-1 with lcrId=${lcrId}
       Create single NRREL   ${NRCELL}    ${lcrId}
    END


Create single NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRCELL}    ${lcrId}
    ${NRREL}   set variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-${NRCELL}/NRREL-1"
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">0dB</p>
    ...    <p name="cellIndividualSsbRsrqOffset">0dB</p>
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


Create NRHOIF-1
    [Documentation]    [PRIVATE]    create NRHOIF-1 object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${cell_id}

    ${cell1_ssbFrequency}    Set Variable    636576
    ${cell2_ssbFrequency}    Set Variable    647616

    Log To Console    Building object ${bts_distName}/${cell${cell_id}_distName}/NRHOIF-1
    ${NRHOIF-1}   set variable   <managedObject class="NRHOIF" distName="${bts_distName}/${cell${cell_id}_distName}/NRHOIF-1"
    ${NRHOIF-1}   Catenate     SEPARATOR=${SPACE}   ${NRHOIF-1}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1BasedPCellSwitchEnabled">false</p>
    ...    <p name="a2BasedPCellSwitchEnabled">false</p>
    ...    <p name="a3MeasEnabled">rsrp</p>
    ...    <p name="a4MeasEnDcSteeringEnabled">none</p>
    ...    <p name="a4MeasHigherPrioFreqEnabled">none</p>
    ...    <p name="a4MeasNrDcEnabled">none</p>
    ...    <p name="a4MeasSCellAddEnabled">none</p>
    ...    <p name="a5MeasEnabled">rsrpCombined</p>
    ...    <p name="cellDepType">NSA</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="ifhoSsbScs">30 KHz</p>
    ...    <p name="ifhoSsbSmtcDuration">sf5</p>
    ...    <p name="ifhoSsbSmtcPeriodicity">sf20</p>
    ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
    ...    <p name="scs">30 KHz</p>
    ...    <p name="ssBurstSetPeriod">10</p>
    ...    <p name="ssbFrequency">${cell${cell_id}_ssbFrequency}</p>
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
           ${NRHOIF-1}   Catenate     SEPARATOR=\n         ${NRHOIF-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRHOIF-1}           xpath=.//cmData


Create NRMEASCFG_IF-1
    [Documentation]    [PRIVATE]    create NRMEASCFG_IF-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEASCFG_IF-1
    ${NRMEASCFG_IF-1}    set variable   <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-1"
    ${NRMEASCFG_IF-1}   Catenate     SEPARATOR=${SPACE}   ${NRMEASCFG_IF-1}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a3MeasEnabled">none</p>
    ...    <p name="a5MeasEnabled">rsrpCombined</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="ssbFrequency">647616</p>
    ...    </managedObject>
           ${NRMEASCFG_IF-1}   Catenate     SEPARATOR=\n         ${NRMEASCFG_IF-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMEASCFG_IF-1}           xpath=.//cmData


Create NRMEASCFG_IF-2
    [Documentation]    [PRIVATE]    create NRMEASCFG_IF-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEASCFG_IF-2
    ${NRMEASCFG_IF-2}    set variable   <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-2"
    ${NRMEASCFG_IF-2}   Catenate     SEPARATOR=${SPACE}   ${NRMEASCFG_IF-2}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a3MeasEnabled">rsrp</p>
    ...    <p name="a5MeasEnabled">none</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="ssbFrequency">636576</p>
    ...    </managedObject>
           ${NRMEASCFG_IF-2}   Catenate     SEPARATOR=\n         ${NRMEASCFG_IF-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMEASCFG_IF-2}           xpath=.//cmData


Create NRMOPRMA_NSA-1
    [Documentation]    [PRIVATE]    create NRMOPRMA_NSA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_NSA-1
    ${NRMOPRMA_NSA-1}   set variable   <managedObject class="NRMOPRMA_NSA" distName="${bts_distName}/NRMOPRMA_NSA-1"
    ${NRMOPRMA_NSA-1}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_NSA-1}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mobilityProfilePriority">1</p>
    ...    <p name="nrMoPrNsaDN">${bts_distName}/NRMOPR_NSA-1</p>
    ...    <p name="spid">1</p>
    ...    <p name="spidLast">100</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-2</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPRMA_NSA-1}   Catenate     SEPARATOR=\n         ${NRMOPRMA_NSA-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_NSA-1}           xpath=.//cmData


Create NRMOPRMA_NSA-2
    [Documentation]    [PRIVATE]    create NRMOPRMA_NSA-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_NSA-1
    ${NRMOPRMA_NSA-2}   set variable   <managedObject class="NRMOPRMA_NSA" distName="${bts_distName}/NRMOPRMA_NSA-2"
    ${NRMOPRMA_NSA-2}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_NSA-2}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mobilityProfilePriority">2</p>
    ...    <p name="nrMoPrNsaDN">${bts_distName}/NRMOPR_NSA-2</p>
    ...    <p name="spid">50</p>
    ...    <p name="spidLast">90</p>
    ...    </managedObject>
           ${NRMOPRMA_NSA-2}   Catenate     SEPARATOR=\n         ${NRMOPRMA_NSA-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_NSA-2}           xpath=.//cmData


Create NRMOPRMA_NSA-3
    [Documentation]    [PRIVATE]    create NRMOPRMA_NSA-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_NSA-1
    ${NRMOPRMA_NSA-3}   set variable   <managedObject class="NRMOPRMA_NSA" distName="${bts_distName}/NRMOPRMA_NSA-3"
    ${NRMOPRMA_NSA-3}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_NSA-3}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mobilityProfilePriority">3</p>
    ...    <p name="nrMoPrNsaDN">${bts_distName}/NRMOPR_NSA-3</p>
    ...    <p name="spid">99</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPRMA_NSA-3}   Catenate     SEPARATOR=\n         ${NRMOPRMA_NSA-3}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_NSA-3}           xpath=.//cmData


Create NRMOPRMA_NSA-4
    [Documentation]    [PRIVATE]    create NRMOPRMA_NSA-4 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_NSA-4
    ${NRMOPRMA_NSA-4}   set variable   <managedObject class="NRMOPRMA_NSA" distName="${bts_distName}/NRMOPRMA_NSA-4"
    ${NRMOPRMA_NSA-4}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_NSA-4}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mobilityProfilePriority">4</p>
    ...    <p name="nrMoPrNsaDN">${bts_distName}/NRMOPR_NSA-4</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-2</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPRMA_NSA-4}   Catenate     SEPARATOR=\n         ${NRMOPRMA_NSA-4}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_NSA-4}           xpath=.//cmData


Create NRMOPR_NSA-1
    [Documentation]    [PRIVATE]    create NRMOPR_NSA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-1
    ${NRMOPR_NSA-1}   set variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-1"
    ${NRMOPR_NSA-1}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_NSA-1}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1MeashoEnabled">rsrpCombined</p>
    ...    <p name="a2MeashoEnabled">rsrpCombined</p>
    ...    <list name="nrMeasCfgIfDNList">
    ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
    ...    <p>${bts_distName}/NRMEASCFG_IF-2</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPR_NSA-1}   Catenate     SEPARATOR=\n         ${NRMOPR_NSA-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_NSA-1}           xpath=.//cmData


Create NRMOPR_NSA-2
    [Documentation]    [PRIVATE]    create NRMOPR_NSA-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-2
    ${NRMOPR_NSA-2}   set variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-2"
    ${NRMOPR_NSA-2}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_NSA-2}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1MeashoEnabled">rsrp</p>
    ...    <p name="a2MeashoEnabled">rsrp</p>
    ...    <list name="nrMeasCfgIfDNList">
    ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
    ...    <p>${bts_distName}/NRMEASCFG_IF-2</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPR_NSA-2}   Catenate     SEPARATOR=\n         ${NRMOPR_NSA-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_NSA-2}           xpath=.//cmData


Create NRMOPR_NSA-3
    [Documentation]    [PRIVATE]    create NRMOPR_NSA-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-3
    ${NRMOPR_NSA-3}   set variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-3"
    ${NRMOPR_NSA-3}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_NSA-3}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1MeashoEnabled">rsrpCombined</p>
    ...    <p name="a2MeashoEnabled">rsrpCombined</p>
    ...    <list name="nrMeasCfgIfDNList">
    ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
    ...    <p>${bts_distName}/NRMEASCFG_IF-2</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPR_NSA-3}   Catenate     SEPARATOR=\n         ${NRMOPR_NSA-3}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_NSA-3}           xpath=.//cmData


Create NRMOPR_NSA-32
    [Documentation]    [PRIVATE]    create NRMOPR_NSA-32 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-32
    ${NRMOPR_NSA-32}   set variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-32"
    ${NRMOPR_NSA-32}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_NSA-32}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1MeashoEnabled">none</p>
    ...    <p name="a2MeashoEnabled">none</p>
    ...    </managedObject>
           ${NRMOPR_NSA-32}   Catenate     SEPARATOR=\n         ${NRMOPR_NSA-32}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_NSA-32}           xpath=.//cmData


Create NRMOPR_NSA-4
    [Documentation]    [PRIVATE]    create NRMOPR_NSA-4 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-4
    ${NRMOPR_NSA-4}   set variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-4"
    ${NRMOPR_NSA-4}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_NSA-4}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1MeashoEnabled">rsrpCombined</p>
    ...    <p name="a2MeashoEnabled">rsrpCombined</p>
    ...    <list name="nrMeasCfgIfDNList">
    ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
    ...    <p>${bts_distName}/NRMEASCFG_IF-2</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPR_NSA-4}   Catenate     SEPARATOR=\n         ${NRMOPR_NSA-4}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_NSA-4}           xpath=.//cmData


Create NRPLMN-2
    [Documentation]    [PRIVATE]    create NRPLMN-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRPLMN-2
    ${NRPLMN-2}   set variable   <managedObject class="NRPLMN" distName="${bts_distName}/NRPLMN-2"
    ${NRPLMN-2}   Catenate     SEPARATOR=${SPACE}   ${NRPLMN-2}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mcc">${mcc_SCF}</p>
    ...    <p name="mnc">388</p>
    ...    <p name="mncLength">${mnclenght_SCF}</p>
    ...    </managedObject>
           ${NRPLMN-2}   Catenate     SEPARATOR=\n         ${NRPLMN-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRPLMN-2}           xpath=.//cmData

