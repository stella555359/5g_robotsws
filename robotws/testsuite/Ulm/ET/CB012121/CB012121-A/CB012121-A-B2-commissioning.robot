*** Settings ***
Documentation   This is a keyword file for CB012121-A-B2, part commissioning
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
    [Documentation]    [PRIVATE]    update SCF common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121_common.xml
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}
    FOR   ${cell_id}   IN   1   2   3   4
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    update single parameter values
    Update NRCELL parameters
    create new objects A-B2_Alt5
    Add Lists A-B2_Alt5
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121_common.xml


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


update NRCELL-2 parameters A-B2_Alt4
    [Documentation]    [PRIVATE]    update NRCELL parameters A-B2_Alt4
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
    Kill WTS services
    start wireshark trace
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/SCFC_CB012121_common.xml
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/SCFC_CB012121_common.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_CB012121_common.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    stop wireshark trace for setup
    check wts in active state
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    get scf coam   ${resultDir}    SCF_final.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


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
       Log To Console    \nset FEATCADM parameter ${param} to false
       Set Element Text   ${scf_xml}    text=false      xpath=.//p[@name="${param}"]
    END
