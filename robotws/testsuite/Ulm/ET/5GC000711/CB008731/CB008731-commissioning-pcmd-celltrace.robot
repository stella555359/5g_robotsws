*** Settings ***
Documentation   This is a keyword file for CB008731, part commissioning pcmd, cell trace
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
    Log To Console    activate ${resultDir}/SCFC_CB8731_pcmd_celltrace.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_CB8731_pcmd_celltrace.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_CB8731_pcmd_celltrace.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Log To Console    save final scf ${resultDir}/SCF_final_${tc}.xml
    get scf coam   ${resultDir}    SCF_final_${tc}.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Update SCF pcmd celltrace
    [Documentation]    [PRIVATE]    update SCF for pcmd cell trace
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
    ...    NRCTRLTS
    ...    NRHOIR
    ...    NRMTRACECU
    ...    NRREL base
    ...    NRRELE
    ...    TCE
    ...    TCEADM
    ...    XNLINK
       Run Keyword    Create ${obj}
    END

    FOR    ${list}   IN
    ...    a1MeashoSsbRsrpSA
    ...    a1MeashoSsbRsrqSA
    ...    a2MeashoSsbRsrpSA
    ...    a2MeashoSsbRsrqSA
    ...    nrhoirDNList
       Run Keyword    Create List ${list}
    END

    FOR   ${param}   ${value}  IN
    ...    actInterRatHoFromEutraToSA      true
    ...    actMFBIEutra                    true
    ...    actCellTraceReport              true
    ...    actPCMDReport                   ${actPCMDReport}
    ...    actInterRatHoSADlDataForward    true
    ...    gNbCuType                       SA
        update single nrbts parameter   ${param}   ${value}
    END

    FOR    ${param}                        ${value}  IN
    ...    a1MeashoEnabled                 rsrp
    ...    a1MeashoEnabledSA               rsrp
    ...    a2MeashoEnabled                 rsrp
    ...    a2MeashoEnabledSA               rsrp
    ...    cbraPreamblesPerSsb             n40
       update single nrcell-1 parameter   ${param}   ${value}
    END

    update parameter for all nrcell objects    param=cellDepType   value=SA

    FOR   ${param}                         ${value}  IN
    ...    miNrMobilityReport              ${measurement_period_in_min}min
    ...    miNrRelReportCu                 ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END

    add sMeasConfigSsbRsrp to NRCELL-1
    add sMeasConfigSsbRsrp to NRCELL-2
    add nonContentRachAcFullConfigHo tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    add measGapSelectionSA to nrcell-1

    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB8731_pcmd_celltrace.xml


set actInterRatHoFromEutraToSA actCellTraceReport
    [Documentation]    [PRIVATE]    execute delta commissioning with parameter actInterRatHoFromEutraToSA actCellTraceReport
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning of parameter started
    Log To Console    actInterRatHoFromEutraToSA set to value true
    Log To Console    actCellTraceReport set to value false
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_cellTrace.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/scf_update_cellTrace.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/scf_update_cellTrace.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished
