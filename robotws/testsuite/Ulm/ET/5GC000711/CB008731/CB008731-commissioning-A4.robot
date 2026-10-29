*** Settings ***
Documentation   This is a keyword file for CB008731, part commissioning A4
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008731-commissioning_lists.robot
Resource        CB008731-commissioning_objects.robot
Resource        CB008731-commissioning_parameter.robot

*** Variables ***
${measurement_period_in_min}     5

*** Keywords ***

activate SCF and bring tl onAir ${tc}
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_CB8731_${tc}.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_CB8731_A4_${tc}.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_CB8731_A4_${tc}.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Log To Console    save final scf ${resultDir}/SCF_final_${tc}.xml
    get scf coam   ${resultDir}    SCF_final_${tc}.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}

Update SCF common part
    [Documentation]    [PRIVATE]    update SCF common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${scf_xml}

    Log To Console    remove in all cells object "NRPLMNSET_NSA-1"
    FOR   ${cell_id}   IN   1   2   3  4
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    FOR   ${param}                          ${value}   IN
    ...   actNrAutSgnbAddCplSlCellDetRec    false
    ...   actNrAutUeCtxStpRtSlCellDetRec    false
    ...   actNrAutDegAdmCtrlSlCellDetRec    false
    ...   actA2SgnbRelease                  false
    ...   actInterMeNBMobility              false
    ...   actIntraMeNBMobility              false
    ...   actMobilityRetryToSecondBestCell  false
    ...   actMultiDrbNSA                    false
    ...   periodicalDataUsageReportTimer    0
       Log To Console    set parameter ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
    END

    Log To Console    \nset actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actDynUlDataSplitMode"]

    Log To Console    \nset actSib1ForNsaCell to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actSib1ForNsaCell"]

    FOR    ${obj}   IN
    ...    NRADJECELL
    ...    NRADJGNB
    ...    NRHOIR
    ...    NRHOIF
    ...    NRREL base
    ...    NRRELE
    ...    NRPMQAP
    ...    XNLINK
        Run Keyword   Create ${obj}
    END

    FOR    ${list}   IN
    ...    a1MeashoSsbRsrpSA
    ...    a1MeashoSsbRsrqSA
    ...    a1MeashoPrefNRLayerSsbRsrpSA
    ...    a1MeashoPrefNRLayerSsbRsrqSA
    ...    a2MeashoSsbRsrpSA
    ...    a2MeashoSsbRsrqSA
    ...    a4PeriodicMeasControlSA
    ...    nrhoirDNList
        Run Keyword   Create List ${list}
    END

    FOR   ${param}   ${value}  IN
    ...    actHigherPrioFreqHo          SA
    ...    actInterFreqHoSA             true
    ...    actInterRatHoFromEutraToSA   true
    ...    actInterRatHoSA              true
    ...    actIntraFreqHoSA             true
    ...    actMFBIEutra                 true
    ...    actNrpmqapProfiles           true
    ...    gNbCuType                    SA
    ...    x2LinkSupervisionTmr         0
    ...    actPucchF3BasedTaGrantsRed   false
        update single nrbts parameter   ${param}   ${value}
    END

    FOR    ${param}                        ${value}  IN
    ...    a1MeashoEnabled                 rsrp
    ...    a1MeashoEnabledSA               rsrp
    ...    a1MeashoPrefNRLayerEnabledSA    rsrp
    ...    a2MeashoEnabled                 rsrp
    ...    a2MeashoEnabledSA               rsrp
    ...    cbraPreamblesPerSsb             n40
       update single nrcell-1 parameter   ${param}   ${value}
    END

    FOR    ${param}                        ${value}  IN
    ...    gscnOrSsPbchArfcn               7995
    ...    nrarfcn                         647666
       update single nrcell-2 parameter   ${param}   ${value}
    END

    FOR   ${param}               ${value}  IN
    ...    cellDepType           SA
       update parameter for all nrcell objects       ${param}   ${value}
    END

    FOR   ${param}                         ${value}  IN
    ...    miNrMobilityReport              ${measurement_period_in_min}min
    ...    miNrNgInterfaceNrpmqap          ${measurement_period_in_min}min
    ...    miNrRelReportCu                 ${measurement_period_in_min}min
    ...    miNrIntraGnbMobilitySaPmqap     ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END

    add a4MeasHigherPrioFreqMaxReactSA to NRCELL
    add sMeasConfigSsbRsrp to NRCELL-1
    add sMeasConfigSsbRsrp to NRCELL-2
    add nonContentRachAcFullConfigHo tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    add measGapSelectionSA to nrcell-1
    add maxCidAllowed parameter for NRDRB_PDCP objects

    Save Xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB8731_A4_common.xml
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB8731_A4_common.xml


Update SCF t6
    [Documentation]    [PRIVATE]    update SCF for A1_based_traffic_steering
    ...       :Autor: Sylvia Schneider

    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB8731_A4_common.xml
    Set Suite Variable    ${scf_xml}
    update single nrbts parameter   actA1HoPrefNRLayer   SA
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB8731_A4_t6.xml
    Log To Console    SCF saved ${resultDir}/SCFC_CB8731_A4_t6.xml


Update SCF t7
    [Documentation]    [PRIVATE]    update SCF for Periodic_A4_based_mobility_after_interRAT_HO_from_LTE
    ...       :Autor: Sylvia Schneider

    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB8731_A4_common.xml
    Set Suite Variable    ${scf_xml}
    update single nrbts parameter   actA1HoPrefNRLayer   none
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB8731_A4_t7.xml
    Log To Console    SCF saved ${resultDir}/SCFC_CB8731_A4_t7.xml
