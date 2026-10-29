*** Settings ***
Documentation   This is a keyword file for CB012121-A-B13, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB012121-A-B13-commissioning-objects.robot
Resource        CB012121-A-B13-commissioning-lists.robot


*** Variables ***

${measurement_period_in_min}          5
${class_NRCELL}                       class="com.nokia.srbts.nrbts:NRCELL"
${cell_distName}                      NRCELL-1


*** Keywords ***


Update SCF A-B13
    [Documentation]    [PRIVATE]    update SCF part A-B13
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB012121-A-B13.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${scf_xml}
    FOR   ${cell_id}   IN   1   2   3   4
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    Update Single Parameter Values
    Update NRCELL Parameters
    CB012121-A-B13-commissioning-objects.Create New Objects A-B13
    Update priorityWaitTimer To 10000 In All Cells
    Set actSib1ForNsaCell To False In All Cells
    Update NRCELL-2 Parameters A-B13
    CB012121-A-B13-commissioning-lists.Add And Update Lists A-B13
    Update FEATCADM Parameters
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB012121-A-B13.xml


Update Single Parameter Values
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

    ${nonContentRachAcFullConfigHo}    Set Variable    <p name="nonContentRachAcFullConfigHo">true</p>
    Add Element        ${scf_xml}     ${nonContentRachAcFullConfigHo}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${tNgRelocExecDeltL}    Set Variable    <p name="tNgRelocExecDeltL">5000</p>
    Add Element        ${scf_xml}     ${tNgRelocExecDeltL}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${timerXnDataFwdGuard}    Set Variable    <p name="timerXnDataFwdGuard">250</p>
    Add Element        ${scf_xml}     ${timerXnDataFwdGuard}   xpath=.//managedObject[@distName="${bts_distName}"]

    Log To Console    updating single parameter values - finished


Update NRCELL Parameters
    [Documentation]    [PRIVATE]    Update NRCELL parameters
    ...       :Autor: Sylvia Schneider
    Log To Console    updating parameters from NRCELL objects
    ${xpath_NRCELL-1}   Set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${xpath_NRCELL-2}   Set Variable    managedObject[@distName="${bts_distName}/NRCELL-2"]
    ${sMeasConfigSsbRsrp}    Set Variable    <p name="sMeasConfigSsbRsrp">4</p>
    ${absThreshSsbRsrpConsolidation}    Set Variable    <p name="absThreshSsbRsrpConsolidation">0</p>
    ${measGapSelectionSA}    Set Variable    <p name="measGapSelectionSA">favourUeThroughput</p>
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

    Log To Console    \nupdate actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false      xpath=.//p[@name="actDynUlDataSplitMode"]


Update NRCELL-2 Parameters A-B13
    [Documentation]    [PRIVATE]    update NRCELL parameters A-B13
    ...       :Autor: Sylvia Schneider
    ${xpath_NRCELL-2}   Set Variable    managedObject[@distName="${bts_distName}/NRCELL-2"]
    FOR   ${param}               ${value}     IN
    ...   gscnOrSsPbchArfcn      8008
    ...   nrarfcn                648000
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//${xpath_NRCELL-2}/p[@name="${param}"]
    END
    Set Element Text   ${scf_xml}    text=636576    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2/NRHOIF-1"]/p[@name="ssbFrequency"]


Activate SCF And Bring Tl onAir
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    wts_ue.Kill WTS services
    CB012121-keywords.Start Wireshark Trace
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/SCFC_CB012121-A-B13.xml
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/SCFC_CB012121-A-B13.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_CB012121-A-B13.xml finished
    Run Keyword And Ignore Error    connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}
    CB012121-keywords.Check All Radio Units Online
    Log To Console    start to bring tl on air without reboot
    ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
    CB012121-keywords.Stop Wireshark Trace For Setup
    CB012121-A-B13-wts.Check Wts In Active State
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    keywordbook-480.Get Scf Coam   ${resultDir}    SCF_final.xml
    [Teardown]    Run Keyword And Ignore Error    connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}


Set actMeasurementStrategy To Disabled
    [Documentation]    [PRIVATE]    delta commissioning to set actMeasurementStrategy to disabled
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set actMeasurementStrategy to disabled

    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/actMeasurementStrategy_disabled.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}


Open Http Session For Delta Commissioning
    [Documentation]    [PRIVATE]    open http session for delta commissioning
    ...       :Autor: Sylvia Schneider
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Set Test Variable   ${oam_alias}


Close Http Session For Delta Commissioning
    [Documentation]    [PRIVATE]    close http session for delta commissioning
    ...       :Autor: Sylvia Schneider
    connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}


Set a3a5Priority To 60 For NRCELL-1 NRFOIF-3
    [Documentation]    [PRIVATE]    delta commissioning to set a3a5Priority to 60 for NRCELL-1 NRFOIF-3
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set a3a5Priority to 60 for NRCELL-1 NRFOIF-3
    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/delta_NRHOIF3_a3a5Priority_60.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}

Update priorityWaitTimer To 10000 In All Cells
    [Documentation]    [PRIVATE]    update priorityWaitTimer to 10000 in all cells
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate priorityWaitTimer to 10000 in all cells
    Set Elements Text   ${scf_xml}    text=10000      xpath=.//p[@name="priorityWaitTimer"]


Set actSib1ForNsaCell To False In All Cells
    [Documentation]    [PRIVATE]    set actSib1ForNsaCell to false in all cells
    ...       :Autor: Sylvia Schneider
    Log To Console    \nset actSib1ForNsaCell to false in all cells
    Set Elements Text   ${scf_xml}    text=false      xpath=.//p[@name="actSib1ForNsaCell"]


Update FEATCADM Parameters
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
