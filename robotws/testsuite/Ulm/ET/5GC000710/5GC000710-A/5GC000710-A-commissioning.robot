*** Settings ***
Documentation   This is a keyword file for 5GC000710-A, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource  ../../../resources/Common/coam_ulm.robot
*** Variables ***

${measurement_period_in_min}          5
${cell_distName}                      NRCELL-3


*** Keywords ***

set sw release version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   split string    ${gnb_swVersion}    _
    set suite variable    ${release}   ${gnb_sw_version_parts}[0]


Update SCF with tc specific parameter actSPID
    [Documentation]    [PRIVATE]    Update common SCF with tc specific parameters
    ...       :Autor: Sylvia Schneider
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_710A_common.xml
    set suite variable    ${scf_xml}
    Log To Console    set in NRBTS param actSPID to value "${actSPID}"
    Set Element Text   ${scf_xml}    text=${actSPID}       xpath=.//p[@name="actSPID"]
    Save xml     ${scf_xml}    ${resultDir}/SCFC_710A_tc_specific.xml
    Log To Console    SCF saved ${resultDir}/SCFC_710A_tc_specific.xml


tc specific update and activate SCF and bring tl onAir with ${wtsfile}
    [Documentation]    [PRIVATE]    tc specific update and activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    Update SCF with tc specific parameter actSPID
    Load wts file ${wtsfile}
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_710A_tc_specific.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_710A_tc_specific.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_710A_tc_specific.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    Wait until all DUs up
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Setup 2nd X2link
    check wts in active state
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    get scf coam   ${resultDir}    SCF_final.xml


Update SCF common part
    [Documentation]    [PRIVATE]    update SCF common part
    ...       :Autor: Sylvia Schneider
    set sw release version
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}
    update single parameter values
    add lists in NRCELL object
    add parameter values in NRCELL object
    create new objects

    FOR   ${param}   IN
    ...   actRedirect
    ...   actNormVCFallback
    ...   actA2SgnbRelease
    ...   actIntraFreqIntraGnbMobilityNSA
       Log To Console    set NRBTS param ${param} to false
       Set Element Text   ${scf_xml}    text=false    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="${param}"]
    END
    Log To Console    set NRMOPR_SA-1 param voiceFBMode to disabled
    Set Element Text   ${scf_xml}    text=disabled    xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]/p[@name="voiceFBMode"]
    FOR   ${id}   IN   1   2  3  4
       Log To Console    remove param a2MeasReleaseEnabled from NRCELL-${id}
       Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${id}"]/p[@name="a2MeasReleaseEnabled"]
    END
    Log To Console    update list actVoiceFallbackDuringHOPrep to disabled
    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  Catenate  SEPARATOR=\n
    ...   <list name="actVoiceFallbackDuringHOPrep">
    ...   <p>disabled</p>
    ...   </list>
    Add Element  ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}"]

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_710A_common.xml
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_710A_common.xml


update single parameter values
    [Documentation]    [PRIVATE]    update single parameter values in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started
    FOR       ${param}                           ${value}     IN
       ...    actInterFreqInterGnbMobilityNSA    true
       ...    actInterFreqIntraGnbMobilityNSA    true
       ...    actInterFreqInterGnbMobilityNSA    true
       ...    actMobilityProfile                 true
       ...    nsaInactivityTimer                 7200
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
    END

    Set Element Text   ${scf_xml}    text=balancedChoice    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]/p[@name="measGapSelection"]

    FOR       ${param}    IN
       ...    reportingIntervalPm
       ...    miNrNRMOP
       ...    miNrRacCu
       ...    miNrRacDu
       ...    miNrX2CC
       Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="${param}"]
    END
    Log To Console    updating single parameter values - finished


add parameter values in NRCELL object
    [Documentation]    [PRIVATE]    add parameter values in NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    adding parameter values in NRCELL object - started
    ${absThreshSsbRsrqConsolidation}    set variable    <p name="absThreshSsbRsrqConsolidation">0</p>
    ${measGapSelectionSA}               set variable    <p name="measGapSelectionSA">balancedChoice</p>
    ${mgta}                             set variable    <p name="mgta">ms0</p>
    FOR       ${param}    IN
       ...    ${absThreshSsbRsrqConsolidation}
       ...    ${measGapSelectionSA}
       ...    ${mgta}
       Log To Console    adding parameter "${param}" in object ${bts_distName}/NRCELL-3
       Add Element     ${scf_xml}     ${param}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]
    END

    ${NRPLMNSET_NSA-1_plmn}     set variable    <p>${bts_distName}/NRPLMN-2</p>
    Log To Console    adding parameter "${NRPLMNSET_NSA-1_plmn}" in list nrPlmnDNList, object ${bts_distName}/NRCELL-3/NRPLMNSET_NSA-1
    Add Element     ${scf_xml}     ${NRPLMNSET_NSA-1_plmn}
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3/NRPLMNSET_NSA-1"]/list[@name="nrPlmnDNList"]

    ${nrDefMoPrNsaDN}          set variable    <p name="nrDefMoPrNsaDN">${bts_distName}/NRMOPR_NSA-32</p>
    FOR   ${cell_id}   IN   1   2   3   4
       Log To Console    adding parameter "${nrDefMoPrNsaDN}" in object ${bts_distName}/NRCELL-${cell_id}
       Add Element     ${scf_xml}     ${nrDefMoPrNsaDN}                  xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]
    END

    Log To Console    adding parameter values in NRCELL object - finished


add lists in NRCELL object
    [Documentation]    [PRIVATE]    add lists in NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    create lists in NRCELL object - started
    Create a3MeasSsbRsrq
    Create a5MeasSsbRsrq
    Log To Console    create lists in NRCELL object - finished


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
    Add Element     ${scf_xml}     ${a3MeasSsbRsrq}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]

Create a5MeasSsbRsrq
    [Documentation]    [PRIVATE]    create list a5MeasSsbRsrq and add it in NRCELL object
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
    Add Element     ${scf_xml}     ${a5MeasSsbRsrq}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]


create new objects
    [Documentation]    [PRIVATE]    create objects in SCF
    ...       :Autor: Sylvia Schneider
    Create NRADJNRCELL-1
    Create NRADJNRCELL-2
    Create NRADJNRCELL-3
    Create NRHOIF
    Create NRREL   instance=1
    Create NRREL   instance=2
    Create NRREL   instance=3
    Create NRMEASCFG_IF-1
    Create NRMEASCFG_IF-2
    Create NRMEASCFG_IF-3
    Create NRMOPRMA_NSA-1
    Create NRMOPRMA_NSA-2
    Create NRMOPRMA_NSA-3
    Create NRMOPRMA_NSA-4
    Create NRMOPR_NSA-1
    Create NRMOPR_NSA-2
    Create NRMOPR_NSA-3
    Create NRMOPR_NSA-32
    Create NRMOPR_NSA-4
    Create NRPLMN-2


Create NRHOIF
    [Documentation]    [PRIVATE]    create NRHOIF-1 and 2 objects in SCF
    ...       :Autor: Sylvia Schneider
    FOR     ${inst}   ${a5MeasE}   ${freqBandIndNR}   ${ssbFreq}   ${a3HysSsbRsrp}   ${a3OffSsbRsrp}   ${a3TimeToTriggerSsbRsrp}   IN
           ...    1   rsrpCombined   71               127970       1                 10                ms0
           ...    2   none           5                176410       0                 3                 ms480
           Create single NRHOIF
           ...    instance=${inst}   a5MeasEnabled=${a5MeasE}   freqBandIndicatorNR=${freqBandIndNR}   ssbFrequency=${ssbFreq}
           ...    a3HysteresisSsbRsrp=${a3HysSsbRsrp}   a3OffsetSsbRsrp=${a3OffSsbRsrp}   a3TimeToTriggerSsbRsrp=${a3TimeToTriggerSsbRsrp}
    END


Create single NRHOIF
    [Documentation]    [PRIVATE]    create NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${instance}   ${a5MeasEnabled}   ${freqBandIndicatorNR}   ${ssbFrequency}
    ...            ${a3HysteresisSsbRsrp}   ${a3OffsetSsbRsrp}   ${a3TimeToTriggerSsbRsrp}

    Log To Console    Building object ${bts_distName}/NRCELL-3/NRHOIF-${instance}
    ${NRHOIF}   set variable   <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-3/NRHOIF-${instance}"
    ${NRHOIF}   Catenate     SEPARATOR=${SPACE}   ${NRHOIF}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1BasedPCellSwitchEnabled">false</p>
           ...    <p name="a2BasedPCellSwitchEnabled">false</p>
           ...    <p name="a3MeasEnabled">rsrp</p>
           ...    <p name="a4MeasEnDcSteeringEnabled">none</p>
           ...    <p name="a4MeasHigherPrioFreqEnabled">none</p>
           ...    <p name="a4MeasNrDcEnabled">none</p>
           ...    <p name="a4MeasSCellAddEnabled">none</p>
           ...    <p name="a5MeasEnabled">${a5MeasEnabled}</p>
           ...    <p name="cellDepType">NSA</p>
           ...    <p name="freqBandIndicatorNR">${freqBandIndicatorNR}</p>
           ...    <p name="ifhoSsbScs">15KHz</p>
           ...    <p name="ifhoSsbSmtcDuration">sf5</p>
           ...    <p name="ifhoSsbSmtcPeriodicity">sf20</p>
           ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
           ...    <p name="scs">15 KHz</p>
           ...    <p name="ssBurstSetPeriod">10</p>
           ...    <p name="ssbFrequency">${ssbFrequency}</p>
           ...    <list name="a3MeasSsbRsrp">
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrp">${a3HysteresisSsbRsrp}</p>
           ...    <p name="a3OffsetSsbRsrp">${a3OffsetSsbRsrp}</p>
           ...    <p name="a3TimeToTriggerSsbRsrp">${a3TimeToTriggerSsbRsrp}</p>
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
    [Arguments]    ${instance}
    Log To Console    Building object ${bts_distName}/NRCELL-3/NRREL-${instance}
    ${NRREL}   set variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-3/NRREL-${instance}"
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellIndividualSsbRsrpOffset">-2dB</p>
           ...    <p name="cellIndividualSsbRsrqOffset">-2dB</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="handoverAllowedSA">allowed</p>
           ...    <p name="handoverAllowedSARedCap">forbidden</p>
           ...    <p name="isRplCellForPSCell">false</p>
           ...    <p name="lcrId">${instance}</p>
           ...    <p name="nrDcAllowed">false</p>
           ...    <p name="removeNotAllowed">false</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${mcc_SCF}</p>
           ...    <p name="mnc">${mnc_SCF}</p>
           ...    <p name="mncLength">3</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRREL}   Catenate     SEPARATOR=\n         ${NRREL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREL}           xpath=.//cmData


Create NRMEASCFG_IF-1
    [Documentation]    [PRIVATE]    create NRMEASCFG_IF-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEASCFG_IF-1
    ${NRMEASCFG_IF-1}    set variable   <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-1"
    ${NRMEASCFG_IF-1}   Catenate     SEPARATOR=${SPACE}   ${NRMEASCFG_IF-1}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a3MeasEnabled">none</p>
           ...    <p name="a5MeasEnabled">rsrpCombined</p>
           ...    <p name="freqBandIndicatorNR">71</p>
           ...    <p name="ssbFrequency">127970</p>
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
           ...    <p name="freqBandIndicatorNR">71</p>
           ...    <p name="ssbFrequency">127970</p>
           ...    </managedObject>
           ${NRMEASCFG_IF-2}   Catenate     SEPARATOR=\n         ${NRMEASCFG_IF-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMEASCFG_IF-2}           xpath=.//cmData


Create NRMEASCFG_IF-3
    [Documentation]    [PRIVATE]    create NRMEASCFG_IF-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEASCFG_IF-3
    ${NRMEASCFG_IF-3}    set variable   <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-3"
    ${NRMEASCFG_IF-3}   Catenate     SEPARATOR=${SPACE}   ${NRMEASCFG_IF-3}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a3MeasEnabled">rsrq</p>
           ...    <p name="a5MeasEnabled">rsrq</p>
           ...    <p name="freqBandIndicatorNR">5</p>
           ...    <p name="ssbFrequency">176410</p>
           ...    </managedObject>
           ${NRMEASCFG_IF-3}   Catenate     SEPARATOR=\n         ${NRMEASCFG_IF-3}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMEASCFG_IF-3}           xpath=.//cmData


Create NRADJNRCELL-1
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-1
    ${NRADJNRCELL-1}    set variable   <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-1"
    ${NRADJNRCELL-1}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL-1}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellDepType">NSA</p>
           ...    <p name="cellReservedForOperatorUse">notReserved</p>
           ...    <p name="fiveGsTac">${fiveGsTac_SCF}</p>
           ...    <p name="freqBandIndicatorNR">71</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="lcrId">1</p>
           ...    <p name="nrarfcn">126380</p>
           ...    <p name="physCellId">48</p>
           ...    <p name="ssbFrequency">126530</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${mcc_SCF}</p>
           ...    <p name="mnc">${mnc_SCF}</p>
           ...    <p name="mncLength">${mnclenght_SCF}</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRADJNRCELL-1}   Catenate     SEPARATOR=\n         ${NRADJNRCELL-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJNRCELL-1}           xpath=.//cmData


Create NRADJNRCELL-2
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-2
    ${NRADJNRCELL-2}    set variable   <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-2"
    ${NRADJNRCELL-2}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL-2}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellDepType">NSA</p>
           ...    <p name="cellReservedForOperatorUse">notReserved</p>
           ...    <p name="fiveGsTac">${fiveGsTac_SCF}</p>
           ...    <p name="freqBandIndicatorNR">71</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="lcrId">2</p>
           ...    <p name="nrarfcn">128000</p>
           ...    <p name="physCellId">49</p>
           ...    <p name="ssbFrequency">127970</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${mcc_SCF}</p>
           ...    <p name="mnc">${mnc_SCF}</p>
           ...    <p name="mncLength">${mnclenght_SCF}</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRADJNRCELL-2}   Catenate     SEPARATOR=\n         ${NRADJNRCELL-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJNRCELL-2}           xpath=.//cmData


Create NRADJNRCELL-3
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-3
    ${NRADJNRCELL-3}    set variable   <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-3"
    ${NRADJNRCELL-3}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL-3}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellDepType">NSA</p>
           ...    <p name="cellReservedForOperatorUse">notReserved</p>
           ...    <p name="fiveGsTac">${fiveGsTac_SCF}</p>
           ...    <p name="freqBandIndicatorNR">5</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="lcrId">3</p>
           ...    <p name="nrarfcn">176500</p>
           ...    <p name="physCellId">46</p>
           ...    <p name="ssbFrequency">176410</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${mcc_SCF}</p>
           ...    <p name="mnc">${mnc_SCF}</p>
           ...    <p name="mncLength">${mnclenght_SCF}</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRADJNRCELL-3}   Catenate     SEPARATOR=\n         ${NRADJNRCELL-3}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJNRCELL-3}           xpath=.//cmData


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
           ...    <p name="a1MeashoEnabled">rsrp</p>
           ...    <p name="a2MeashoEnabled">rsrp</p>
           ...    <list name="nrMeasCfgIfDNList">
           ...    <p>${bts_distName}/NRMEASCFG_IF-3</p>
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
