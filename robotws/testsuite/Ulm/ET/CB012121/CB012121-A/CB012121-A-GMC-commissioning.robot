*** Settings ***
Documentation   This is a keyword file for CB012121-A, part commissioning GMC
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB012121-A-commissioning-objects.robot
Resource        CB012121-A-commissioning-lists.robot


*** Variables ***

${measurement_period_in_min}          5
${class_NRCELL}                       class="com.nokia.srbts.nrbts:NRCELL"
${cell_distName}                      NRCELL-1


*** Keywords ***

Update SCF common
    [Documentation]    [PRIVATE]    update SCF common
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121_common.xml
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}
    FOR   ${cell_id}   IN   1   2   3   4
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    update single parameter values
    Update NRCELL parameters
    create new objects GMC
    update priorityWaitTimer to 10000 in all cells
    set actSib1ForNsaCell to false in all cells
    update NRCELL-2 parameters
    Add and Update Lists GMC
    Log To Console    \nupdate actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false      xpath=.//p[@name="actDynUlDataSplitMode"]
    update FEATCADM parameters
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121_common.xml


Update SCF B6
    [Documentation]    [PRIVATE]    update SCF common part A-B6
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121_B6.xml
    Update SCF common
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB012121_common.xml
    Log To Console    NRHOIR-1 set param b2MeashoEnabled to rsrp
    Set Element Text   ${scf_xml}    text=rsrp    xpath=.//managedObject[@distName="${bts_distName}/NRHOIR-1"]/p[@name="b2MeashoEnabled"]
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121_B6.xml


Update SCF B9
    [Documentation]    [PRIVATE]    update SCF common part A-B9
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121_B9.xml
    Update SCF common
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB012121_common.xml
    Log To Console    NRHOIR-1 set param b2MeashoEnabled to rsrp
    Set Element Text   ${scf_xml}    text=rsrp    xpath=.//managedObject[@distName="${bts_distName}/NRHOIR-1"]/p[@name="b2MeashoEnabled"]
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121_B9.xml


Update SCF B2-Alt4
    [Documentation]    [PRIVATE]    update SCF common part A-B2-Alt4
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121_B2-Alt4.xml
    Update SCF common
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB012121_common.xml
    Log To Console    NRHOIR-1 set param b2MeashoEnabled to rsrp
    Set Element Text   ${scf_xml}    text=rsrp    xpath=.//managedObject[@distName="${bts_distName}/NRHOIR-1"]/p[@name="b2MeashoEnabled"]
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121_B2-Alt4.xml


Update SCF B2-Alt5
    [Documentation]    [PRIVATE]    update SCF common part A-B2-Alt5
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121_B2-Alt5.xml
    Update SCF common
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB012121_common.xml
    FOR   ${object}           ${param}                ${value}    IN
    ...   NRCELL-2            gscnOrSsPbchArfcn       7880
    ...   NRCELL-2            nrarfcn                 636666
    ...   NRCELL-2/NRHOIF-1   ssbFrequency            648864
    ...   NRHOIR-1            b2MeashoEnabled         rsrp
       Log To Console    ${object} set param ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}   xpath=.//managedObject[@distName="${bts_distName}/${object}"]/p[@name="${param}"]
    END
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121_B2-Alt5.xml


Update SCF B3
    [Documentation]    [PRIVATE]    update SCF common part A-B3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121_B3.xml
    Update SCF common
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB012121_common.xml
    set suite variable    ${scf_xml}
    FOR   ${value}        ${object}   ${param}    IN
    ...   rsrq            NRCELL-1    a3MeasEnabled
    ...   rsrq            NRCELL-1/NRHOIF-1    a3MeasEnabled
    ...   rsrq            NRCELL-1/NRHOIF-2    a3MeasEnabled
    ...   rsrq            NRCELL-1/NRHOIF-3    a3MeasEnabled
    ...   rsrpCombined    NRCELL-2/NRHOIF-1    a3MeasEnabled
    ...   rsrpCombined    NRCELL-2/NRHOIF-2    a3MeasEnabled
    ...   rsrpCombined    NRCELL-2/NRHOIF-3    a3MeasEnabled
    ...   3               NRCELL-1/NRHOIF-1    a3a5Priority
    ...   2               NRCELL-1/NRHOIF-2    a3a5Priority
    ...   1               NRCELL-1/NRHOIF-3    a3a5Priority
    ...   rsrq            NRCELL-1/NRHOIF-1    a5MeasEnabled
    ...   rsrq            NRCELL-1/NRHOIF-2    a5MeasEnabled
    ...   rsrq            NRCELL-1/NRHOIF-3    a5MeasEnabled
        Log To Console    ${object} set ${param} to value ${value}
        Set Element Text   ${scf_xml}    text=${value}    xpath=.//managedObject[@distName="${bts_distName}/${object}"]/p[@name="${param}"]
    END

    ${absThreshSsbRsrqConsolidation}    set variable    <p name="absThreshSsbRsrqConsolidation">0</p>
    Add Element        ${scf_xml}     ${absThreshSsbRsrqConsolidation}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Log To Console    add ${absThreshSsbRsrqConsolidation} to NRCELL-1

    Create List a3MeasSsbRsrq

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121_B3.xml


Update SCF B4
    [Documentation]    [PRIVATE]    update SCF common part A-B4
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121_B4.xml
    Update SCF common
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB012121_common.xml
    FOR   ${value}        ${object}   ${param}    IN
    ...   rsrpCombined    NRCELL-1/NRHOIF-1    a3MeasEnabled
    ...   rsrpCombined    NRCELL-1/NRHOIF-2    a3MeasEnabled
    ...   rsrpCombined    NRCELL-1/NRHOIF-3    a3MeasEnabled
    ...   rsrpCombined    NRCELL-2/NRHOIF-1    a3MeasEnabled
    ...   rsrpCombined    NRCELL-2/NRHOIF-2    a3MeasEnabled
    ...   rsrpCombined    NRCELL-2/NRHOIF-3    a3MeasEnabled
    ...   3               NRCELL-1/NRHOIF-1    a3a5Priority
    ...   2               NRCELL-1/NRHOIF-2    a3a5Priority
    ...   1               NRCELL-1/NRHOIF-3    a3a5Priority
    ...   forbidden       NRCELL-1/NRREL-4     handoverAllowedSA
    ...   forbidden       NRCELL-1/NRREL-5     handoverAllowedSA
        Log To Console    ${object} set ${param} to value ${value}
       Set Element Text   ${scf_xml}    text=${value}    xpath=.//managedObject[@distName="${bts_distName}/${object}"]/p[@name="${param}"]
    END

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121_B4.xml


Update SCF B1_ALT1
    [Documentation]    [PRIVATE]    Update SCF common part B1_ALT1
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121_B1_ALT1.xml
    Update SCF common
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB012121_common.xml
    set suite variable    ${scf_xml}
    Log To Console    actRfspIndex and actMobilityProfile set to value true
    Set Element Text   ${scf_xml}    text=true      xpath=.//p[@name="actRfspIndex"]
    Set Element Text   ${scf_xml}    text=true      xpath=.//p[@name="actMobilityProfile"]

    FOR   ${value}        ${object}   ${param}    IN
    ...   5000            NRCELL-1             bestCellWaitTimer
    ...   1               NRCELL-1/NRHOIF-1    a3a5Priority
    ...   rsrpCombined    NRCELL-1/NRHOIF-1    a3MeasEnabled
    ...   2               NRCELL-1/NRHOIF-2    a3a5Priority
    ...   rsrpCombined    NRCELL-1/NRHOIF-2    a3MeasEnabled
    ...   3               NRCELL-1/NRHOIF-3    a3a5Priority
    ...   rsrpCombined    NRCELL-1/NRHOIF-3    a3MeasEnabled
    ...   5               NRCELL-2/NRHOIF-1    a3a5Priority
    ...   rsrpCombined    NRCELL-2/NRHOIF-1    a3MeasEnabled
    ...   6               NRCELL-2/NRHOIF-2    a3a5Priority
    ...   rsrpCombined    NRCELL-2/NRHOIF-2    a3MeasEnabled
    ...   7               NRCELL-2/NRHOIF-3    a3a5Priority
    ...   rsrpCombined    NRCELL-2/NRHOIF-3    a3MeasEnabled
    ...   4               NRHOIR-1             b2Priority
       Log To Console    ${object} set ${param} to value ${value}
       Set Element Text   ${scf_xml}    text=${value}    xpath=.//managedObject[@distName="${bts_distName}/${object}"]/p[@name="${param}"]
    END
    Add Lists
    create new objects A-B1_ALT1
    Log To Console    NRMOPR_SA-2 set priorityWaitTimer to value 0
    Set Element Text   ${scf_xml}    text=0   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-2"]/p[@name="priorityWaitTimer"]
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121_B1_ALT1.xml


update single parameter values
    [Documentation]    [PRIVATE]    update single parameter values in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started
    FOR    ${value}          ${param}   IN
    ...    true              actInterFreqHoSA
    ...    true              actInterRatHoFromEutraToSA
    ...    true              actInterRatHoSA
    ...    true              actIntraFreqHoSA
    ...    cellQuality       actMeasurementStrategy
    ...    true              actMFBIEutra
    ...    true              actRanSharing
    ...    SA                gNbCuType
    ...    0                 x2LinkSupervisionTmr
    ...    false             actPucchF3BasedTaGrantsRed
    ...    false             actMobilityRetryToSecondBestCell
    ...    false             actMultiFrequencyBandIndicatorNRSupport
    ...    false             sgnbRelForNoHandoverEnabled
    ...    false             actA2SgnbRelease
    ...    false             actInterMeNBMobility
    ...    false             actIntraMeNBMobility
    ...    false             actMultiDrbNSA
    ...    0                 periodicalDataUsageReportTimer
         Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
         Log To Console    ${param} set to value ${value}
    END

    FOR    ${param}   IN
    ...   miNrInterRATMobilitySaPmqap
    ...   miNrInterGnbMobilityCellCuSa
    ...   miNrIntraGnbMobilityCellCuSa
    ...   miNrMobilityReport
    ...   miNrSaAcDuNrpmqap
    ...   miNrSaAdjGnb
    ...   miNrSaCuNrpmqap
    ...   miNrUeQuan
    ...   miNrNRMOP
    ...   miNrRelReportCu
    ...   reportingIntervalPm
         Log To Console    ${param} set to value ${measurement_period_in_min}min
         Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="${param}"]
    END

    ${nonContentRachAcFullConfigHo}    set variable    <p name="nonContentRachAcFullConfigHo">true</p>
    Add Element        ${scf_xml}     ${nonContentRachAcFullConfigHo}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${tNgRelocExecDeltL}    set variable    <p name="tNgRelocExecDeltL">5000</p>
    Add Element        ${scf_xml}     ${tNgRelocExecDeltL}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${timerXnDataFwdGuard}    set variable    <p name="timerXnDataFwdGuard">250</p>
    Add Element        ${scf_xml}     ${timerXnDataFwdGuard}   xpath=.//managedObject[@distName="${bts_distName}"]

    Log To Console    updating single parameter values - finished


Update NRCELL parameters
    [Documentation]    [PRIVATE]    Update NRCELL parameters
    ...       :Autor: Sylvia Schneider
    Log To Console    updating parameters from NRCELL objects
    ${xpath_NRCELL-1}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${xpath_NRCELL-2}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-2"]
    ${sMeasConfigSsbRsrp}    set variable    <p name="sMeasConfigSsbRsrp">4</p>
    ${absThreshSsbRsrpConsolidation}    set variable    <p name="absThreshSsbRsrpConsolidation">0</p>
    ${measGapSelectionSA}    set variable    <p name="measGapSelectionSA">favourUeThroughput</p>
    FOR    ${NRCELL_id}       IN
    ...    1
    ...    2
       Add Element        ${scf_xml}    ${sMeasConfigSsbRsrp}              xpath=.//${xpath_NRCELL-${NRCELL_id}}
       Add Element        ${scf_xml}    ${absThreshSsbRsrpConsolidation}   xpath=.//${xpath_NRCELL-${NRCELL_id}}
       Add Element        ${scf_xml}    ${measGapSelectionSA}              xpath=.//${xpath_NRCELL-${NRCELL_id}}
       Set Element Text   ${scf_xml}    text=SA        xpath=.//${xpath_NRCELL-${NRCELL_id}}/p[@name="cellDepType"]
       Set Element Text   ${scf_xml}    text=7880      xpath=.//${xpath_NRCELL-${NRCELL_id}}/p[@name="gscnOrSsPbchArfcn"]
       Set Element Text   ${scf_xml}    text=636666    xpath=.//${xpath_NRCELL-${NRCELL_id}}/p[@name="nrarfcn"]

    END

    FOR    ${NRCELL}       IN
    ...    managedObject[@distName\="${bts_distName}/NRCELL-3"]
    ...    managedObject[@distName\="${bts_distName}/NRCELL-4"]
       Set Element Text   ${scf_xml}    text=SA         xpath=.//${NRCELL}/p[@name="cellDepType"]
       Set Element Text   ${scf_xml}    text=10000      xpath=.//${NRCELL}/p[@name="bestCellWaitTimer"]
    END

    FOR    ${value}    ${param}   IN
    ...    rsrp        a1MeashoEnabled
    ...    rsrp        a1MeashoEnabledSA
    ...    rsrp        a2MeashoEnabled
    ...    rsrp        a2MeashoEnabledSA
    ...    rsrp        a3MeasEnabled
    ...    rsrp        a5MeasEnabled
    ...    10000       bestCellWaitTimer
         Set Element Text   ${scf_xml}    text=${value}      xpath=.//${xpath_NRCELL-1}/p[@name="${param}"]
         Set Element Text   ${scf_xml}    text=${value}      xpath=.//${xpath_NRCELL-2}/p[@name="${param}"]
         Log To Console    ${param} set to value ${value} for NRCELL-1 and NRCELL-2
    END
    Log To Console    cbraPreamblesPerSsb set to value n40 for NRCELL-1
    Set Element Text   ${scf_xml}    text=n40      xpath=.//${xpath_NRCELL-1}/p[@name="cbraPreamblesPerSsb"]


update NRCELL-2 parameters
    [Documentation]    [PRIVATE]    update NRCELL parameters
    ...       :Autor: Sylvia Schneider
    ${xpath_NRCELL-2}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-2"]
    FOR   ${param}               ${value}     IN
    ...   gscnOrSsPbchArfcn      8008
    ...   nrarfcn                648000
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//${xpath_NRCELL-2}/p[@name="${param}"]
    END
    Set Element Text   ${scf_xml}    text=636576    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2/NRHOIF-1"]/p[@name="ssbFrequency"]


activate SCF and bring tl onAir
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${scf_file}
    Kill WTS services
    start wireshark trace
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/${scf_file}.xml
    admin.perform commissioning
    ...    scf_file=${resultBaseDir}/${scf_file}.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/${scf_file}.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    stop wireshark trace for setup
    check wts in active state
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    get scf coam   ${resultDir}    SCF_final.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


set actMeasurementStrategy to disabled
    [Documentation]    [PRIVATE]    delta commissioning to set actMeasurementStrategy to disabled
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set actMeasurementStrategy to disabled

    admin.perform delta recommissioning
    ...    ${CURDIR}/../CB012121-common/actMeasurementStrategy_disabled.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}


open http session for delta commissioning
    [Documentation]    [PRIVATE]    open http session for delta commissioning
    ...       :Autor: Sylvia Schneider
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    set test variable   ${oam_alias}


close http session for delta commissioning
    [Documentation]    [PRIVATE]    close http session for delta commissioning
    ...       :Autor: Sylvia Schneider
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


set actMeasurementStrategy to cellQuality
    [Documentation]    [PRIVATE]    delta commissioning to set actMeasurementStrategy to cellQuality
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set actMeasurementStrategy to cellQuality

    admin.perform delta recommissioning
    ...    ${CURDIR}/../CB012121-common/actMeasurementStrategy_cellQuality.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}


set actMeasurementStrategy to priority
    [Documentation]    [PRIVATE]    delta commissioning to set actMeasurementStrategy to priority
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set actMeasurementStrategy to priority

    admin.perform delta recommissioning
    ...    ${CURDIR}/../CB012121-common/actMeasurementStrategy_priority.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}


update priorityWaitTimer to 10000 in all cells
    [Documentation]    [PRIVATE]    update priorityWaitTimer to 10000 in all cells
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate priorityWaitTimer to 10000 in all cells
    Set Elements Text   ${scf_xml}    text=10000      xpath=.//p[@name="priorityWaitTimer"]


set actSib1ForNsaCell to false in all cells
    [Documentation]    [PRIVATE]    set actSib1ForNsaCell to false in all cells
    ...       :Autor: Sylvia Schneider
    Log To Console    \nset actSib1ForNsaCell to false in all cells
    Set Elements Text   ${scf_xml}    text=false      xpath=.//p[@name="actSib1ForNsaCell"]


update FEATCADM parameters
    [Documentation]    [PRIVATE]    update FEATCADM parameters
    ...       :Autor: Sylvia Schneider
    FOR   ${param}   IN
    ...   actNrRrcSuccRateSlCellDuDetRec
    ...   actNrAutSgnbAddCplSlCellDetRec
    ...   actNrAutUeCtxStpRtSlCellDetRec
    ...   actNrAutDegAdmCtrlSlCellDetRec
       Log To Console    set FEATCADM parameter ${param} to false
       Set Element Text   ${scf_xml}    text=false      xpath=.//p[@name="${param}"]
    END


set NRREL4 and NRREL5 to handoverAllowedSA forbidden
    [Documentation]    [PRIVATE]    set NRREL4 and NRREL5 to handoverAllowedSA forbidden
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta set NRREL4 and NRREL5 to handoverAllowedSA forbidden
    admin.perform delta recommissioning
    ...    ${CURDIR}/delta_handoverAllowedSA_forbidden.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    Log To Console    delta commissioning finished
