*** Settings ***
Documentation   This is a keyword file for CB008731, part commissioning voice
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
    ...    scf_file=${resultDir}/SCFC_CB8731_${tc}.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_CB8731_${tc}.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Log To Console    save final scf ${resultDir}/SCF_final_${tc}.xml
    get scf coam   ${resultDir}    SCF_final_${tc}.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


update GMC parameter
    [Documentation]    [PRIVATE]    update GMC parameter
    ...       :Autor: Sylvia Schneider
    FOR   ${param}                          ${value}   IN
    ...   actNrAutSgnbAddCplSlCellDetRec    false
    ...   actNrAutUeCtxStpRtSlCellDetRec    false
    ...   actNrAutDegAdmCtrlSlCellDetRec    false
    ...   actNonGbrServiceDiff              false
    ...   actA2SgnbRelease                  false
    ...   actInterMeNBMobility              false
    ...   actIntraMeNBMobility              false
    ...   actMobilityRetryToSecondBestCell  false
    ...   actMultiDrbNSA                    false
    ...   periodicalDataUsageReportTimer    0
       Log To Console    set parameter ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
    END
    Log To Console    \nset actSib1ForNsaCell to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actSib1ForNsaCell"]
    Log To Console    \nset actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actDynUlDataSplitMode"]


Update SCF t1
    [Documentation]    [PRIVATE]    update SCF for rohc voice
    ...       :Autor: Sylvia Schneider
    set sw release version
    Log To Console    \nstart update SCF

    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    Log To Console    remove all NRPLMNSET_NSA-1
    FOR   ${cell_id}   IN   1   2   3  4
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    IF    '${release}'!='SBTS24R3'    update GMC parameter
    IF    '${release}'=='SBTS25R2' or '${release}'=='SBTS25R3'   Create NRPMQAP_25R   ELSE   Create NRPMQAP

    Create NRADJECELL
    Create NRADJGNB
    Create NRHOIR
    Create NRREL base
    Create NRRELE
    Create XNLINK
    Create List a1MeashoSsbRsrpSA
    Create List a1MeashoSsbRsrqSA
    Create List a2MeashoSsbRsrpSA
    Create List a2MeashoSsbRsrqSA
    Create List emergencyCallRestrictions
    Create List nrhoirDNList

    FOR   ${param}   ${value}  IN
    ...    actInterRatHoFromEutraToSA   true
    ...    actInterRatHoSA              true
    ...    actIntraFreqHoSA             true
    ...    actMFBIEutra                 true
    ...    actNrpmqapProfiles           true
    ...    actRohc                      true
    ...    gNbCuType                    SA
    ...    x2LinkSupervisionTmr         0
    ...    actPucchF3BasedTaGrantsRed   false
        update single nrbts parameter   ${param}   ${value}
    END

    FOR    ${param}                    ${value}  IN
    ...    a1MeashoEnabled             rsrp
    ...    a1MeashoEnabledSA           rsrp
    ...    a2MeashoEnabled             rsrp
    ...    a2MeashoEnabledSA           rsrp
    ...    actEnhancedVoNR             true
    ...    actVoNR                     true
    ...    actVoNrMobilityThresholds   VoNrMobilityThresholds
    ...    cbraPreamblesPerSsb         n40
       update single nrcell-1 parameter   ${param}   ${value}
    END

    update parameter for all nrcell objects    param=cellDepType   value=SA

    FOR   ${param}                  ${value}  IN
    ...    miNrMobilityReport       ${measurement_period_in_min}min
    ...    miNrNgInterfaceNrpmqap   ${measurement_period_in_min}min
    ...    miNrRelReportCu          ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END

    add sMeasConfigSsbRsrp to NRCELL-1
    add sMeasConfigSsbRsrp to NRCELL-2
    add nonContentRachAcFullConfigHo tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    add measGapSelectionSA to nrcell-1
    add maxCidAllowed parameter for NRDRB_PDCP objects

    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB8731_t1.xml


Update SCF t4
    [Documentation]    [PRIVATE]    update SCF for High Priority Access
    ...       :Autor: Sylvia Schneider
    set sw release version
    Log To Console    \nstart update SCF

    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    Log To Console    remove all NRPLMNSET_NSA-1
    FOR   ${cell_id}   IN   1   2   3  4
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    IF    '${release}'!='SBTS24R3'    update GMC parameter
    IF    '${release}'=='SBTS25R2' or '${release}'=='SBTS25R3'   Create NRPMQAP_25R   ELSE   Create NRPMQAP

    FOR   ${param}   ${value}  IN
    ...    actInterRatHoFromEutraToSA   true
    ...    actInterRatHoSA              true
    ...    actIntraFreqHoSA             true
    ...    actMFBIEutra                 true
    ...    actNrpmqapProfiles           true
    ...    drbInactivityTimerSA         7200
    ...    gNbCuType                    SA
    ...    x2LinkSupervisionTmr         0
    ...    actPucchF3BasedTaGrantsRed   false
        update single nrbts parameter   ${param}   ${value}
    END

    add nonContentRachAcFullConfigHo tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object

    Create NRADJECELL
    Create NRADJGNB
    Create NRREL base
    Create NRRELE
    Create NRHOIR
    Create NRPRIOACC_PROFILE-1
    Create XNLINK

    update single nrdu parameter

    FOR    ${param}                    ${value}  IN
    ...    a1MeashoEnabled             rsrp
    ...    a1MeashoEnabledSA           rsrp
    ...    a2MeashoEnabled             rsrp
    ...    a2MeashoEnabledSA           rsrp
    ...    actEnhancedVoNR             true
    ...    actEmergencyCall            true
    ...    emergencyCallFails          true
    ...    actPriorityAccess           true
    ...    actVoNR                     true
    ...    actVoNrMobilityThresholds   VoNrMobilityThresholds
    ...    cbraPreamblesPerSsb         n40
    ...    emergencyCallLimServ        true
    ...    maxNumOfCaUsersNRCell       0
    ...    maxNumOfNrDcSnUsers         1
    ...    maxNumOfRrcSA               1
    ...    maxNumOfSCellAlloc          1
    ...    maxNumOfUsersPerNRCell      1
    ...    maxNumOfNrDcSnUsers         1
    ...    maxNumOfUsersPerCell        0
    ...    numOfRadioResReservForEmergency        1
       update single nrcell-1 parameter   ${param}   ${value}
    END

    update parameter for all nrcell objects    param=cellDepType   value=SA

    add measGapSelectionSA to nrcell-1
    add high priority params to nrcell-1
    add sMeasConfigSsbRsrp to NRCELL-1
    add sMeasConfigSsbRsrp to NRCELL-2

    Create List a1MeashoSsbRsrpSA
    Create List a1MeashoSsbRsrqSA
    Create List a2MeashoSsbRsrpSA
    Create List a2MeashoSsbRsrqSA
    Create List emergencyCallRestrictions
    Create List nrhoirDNList


    FOR   ${param}                  ${value}  IN
    ...    miNrMobilityReport       ${measurement_period_in_min}min
    ...    miNrNgInterfaceNrpmqap   ${measurement_period_in_min}min
    ...    miNrRelReportCu          ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END

    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB8731_t4.xml


Update SCF t5
    [Documentation]    [PRIVATE]    update SCF for GBR services
    ...       :Autor: Sylvia Schneider
    set sw release version
    Log To Console    \nstart update SCF

    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    Log To Console    remove all NRPLMNSET_NSA-1
    FOR   ${cell_id}   IN   1   2   3  4
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    IF    '${release}'!='SBTS24R3'    update GMC parameter

    FOR   ${param}   ${value}  IN
    ...    actInterRatHoFromEutraToSA   true
    ...    actInterRatHoSA              true
    ...    actIntraFreqHoSA             true
    ...    actMFBIEutra                 true
    ...    gNbCuType                    SA
    ...    x2LinkSupervisionTmr         0
    ...    actPucchF3BasedTaGrantsRed   false
        update single nrbts parameter   ${param}   ${value}
    END

    add nonContentRachAcFullConfigHo tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object

    Create NRADJECELL
    Create NRADJGNB
    Create NRREL base
    Create NRRELE
    Create NRHOIR
    Create NRDRB_16_17
    Create NRDRB_5QI-7_8
    Create NRDRB_MAC-5_6
    Create XNLINK

    FOR    ${param}                    ${value}  IN
    ...    a1MeashoEnabled             rsrp
    ...    a1MeashoEnabledSA           rsrp
    ...    a2MeashoEnabled             rsrp
    ...    a2MeashoEnabledSA           rsrp
    ...    actEnhancedVoNR             true
    ...    actVoNR                     true
    ...    actEnhancedVoNR             true
    ...    actNonVoNRGbrService        true
    ...    actVoNrMobilityThresholds   VoNrMobilityThresholds
    ...    dlMcsDropLimitForVoNR       0
    ...    cbraPreamblesPerSsb         n40
       update single nrcell-1 parameter   ${param}   ${value}
    END

    update parameter for all nrcell objects    param=cellDepType   value=SA

    add measGapSelectionSA to nrcell-1
    add sMeasConfigSsbRsrp to NRCELL-1
    add sMeasConfigSsbRsrp to NRCELL-2

    Create List a1MeashoSsbRsrpSA
    Create List a1MeashoSsbRsrqSA
    Create List a2MeashoSsbRsrpSA
    Create List a2MeashoSsbRsrqSA
    Create List nrhoirDNList

    FOR   ${param}                  ${value}  IN
    ...    miNrMobilityReport       ${measurement_period_in_min}min
    ...    miNrRelReportCu          ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END

    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB8731_t5.xml
