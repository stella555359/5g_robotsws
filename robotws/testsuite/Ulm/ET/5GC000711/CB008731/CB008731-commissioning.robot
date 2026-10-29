*** Settings ***
Documentation   This is a keyword file for CB008731, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008731-commissioning_lists.robot
Resource        CB008731-commissioning_objects.robot
Resource        CB008731-commissioning_parameter.robot

*** Variables ***
${measurement_period_in_min}     5

*** Keywords ***

Update SCF t2
    [Documentation]    [PRIVATE]    update SCF for voice partial admission
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

    Log To Console    \nset actARPBasedAC to off in all cells
    Set Elements Text   ${scf_xml}    text=off           xpath=.//p[@name="actARPBasedAC"]

    FOR   ${param}   ${value}  IN
    ...    actInterRatHoFromEutraToSA   true
    ...    actMFBIEutra                 true
    ...    gNbCuType                    SA
        update single nrbts parameter   ${param}   ${value}
    END

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
    Create List nrhoirDNList

    FOR    ${param}                    ${value}  IN
    ...    a1MeashoEnabled             rsrp
    ...    a1MeashoEnabledSA           rsrp
    ...    a2MeashoEnabled             rsrp
    ...    a2MeashoEnabledSA           rsrp
    ...    cbraPreamblesPerSsb         n40
    ...    maxNumOfNonGBRBearersSA         4
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

    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB8731_t2.xml


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


Update SCF t3
    [Documentation]    [PRIVATE]    update SCF for arp based preemption
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

    Log To Console    \nset actARPBasedAC to off in all cells
    Set Elements Text   ${scf_xml}    text=off           xpath=.//p[@name="actARPBasedAC"]

    FOR   ${param}                        ${value}  IN
    ...    actInterRatHoFromEutraToSA      true
    ...    actMFBIEutra                    true
    ...    actUserPreemption               true
    ...    gNbCuType                       SA
    ...    actRedirect                     false
    ...    actVoFallBackLteB1MeaBaRedir    false
    ...    actNormVCFallback               false
        update single nrbts parameter   ${param}   ${value}
    END

    Log To Console    update list actVoiceFallbackDuringHOPrep to disabled
    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  Catenate  SEPARATOR=\n
    ...   <list name="actVoiceFallbackDuringHOPrep">
    ...   <p>disabled</p>
    ...   </list>
    Add Element  ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}"]

    add nonContentRachAcFullConfigHo tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    add preemption params to nrbts and nrcells

    Create NRADJECELL
    Create NRADJGNB
    Create NRREL base
    Create NRRELE
    Create NRHOIR
    Create XNLINK

    FOR    ${param}                    ${value}  IN
    ...    a1MeashoEnabled             rsrp
    ...    a1MeashoEnabledSA           rsrp
    ...    a2MeashoEnabled             rsrp
    ...    a2MeashoEnabledSA           rsrp
    ...    cbraPreamblesPerSsb         n40
    ...    maxNumOfCaUsersNRCell       2
    ...    maxNumOfNrDcSnUsers         5
    ...    maxNumOfRrcSA               2
    ...    maxNumOfSCellAlloc          2
    ...    maxNumOfUsersPerNRCell      5
    ...    maxNumOfNrDcSnUsers         5
    ...    maxNumOfUsersPerCell        2
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

    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB8731_t3.xml


set actARPBasedAC to handovers
    [Documentation]    [PRIVATE]    execute delta commissioning with parameter actARPBasedAC
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning of parameter started
    Log To Console    actARPBasedAC set to value handovers
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_t2.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/scf_update_t2.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/scf_update_t2.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished
