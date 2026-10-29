*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part commissioning 2gnb
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${measurement_period_in_min}          5
${class_NRCELL}                       class="com.nokia.srbts.nrbts:NRCELL"
${cell_distName}                      NRCELL-1


*** Keywords ***

activate rfsp and mobilityProfile
    [Documentation]    [PRIVATE]    delta commissioning to activate rfsp and mobilityProfile for t8
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning of parameter started
    Log To Console    actRfspIndex set to value true
    Log To Console    actMobilityProfile set to value true
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_t8.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/scf_update_t8.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/scf_update_t8.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished
    get scf coam    ${resultDir}    SCFC_t8_rfsp_mobProf_true.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_t8_rfsp_mobProf_true.xml


Update SCF 2gnb
    [Documentation]    [PRIVATE]    update SCF and activate on gNB for 2gnb
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_711A_2gnb.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${scf_xml}

    Log To Console    remove in all cells object "NRPLMNSET_NSA-1"
    FOR   ${cell_id}   IN   1   2   3  4
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    Log To Console    \nset actSib1ForNsaCell to false in all cells
    Set Elements Text   ${scf_xml}    text=false      xpath=.//p[@name="actSib1ForNsaCell"]

    Log To Console    remove NRCELL-1 param a2MeasReleaseEnabled
    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="a2MeasReleaseEnabled"]

    Log To Console    remove NRCELL-1 list a2MeasReleaseSsbRsrp
    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a2MeasReleaseSsbRsrp"]

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
    ...   actRedirect                       false
    ...   actNormVCFallback                 false
    ...   actVoFallBackLteB1MeaBaRedir      false
       Log To Console    set parameter ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
    END

    Log To Console    \nset actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actDynUlDataSplitMode"]

    Log To Console    set actVoiceFallbackDuringHOPrep to disabled
    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  Set Variable  <list name="actVoiceFallbackDuringHOPrep">\n<p>disabled</p>\n</list>
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}"]

    FOR   ${object}    IN
    ...   NRCELL-1
    ...   NRMOPR_SA-1
       Log To Console    ${object} set voiceFBMode to disabled
       ${xpath}   Set Variable   managedObject[@distName="${bts_distName}/${object}"]
       Set Element Text   ${scf_xml}    text=disabled      xpath=.//${xpath}/p[@name="voiceFBMode"]
    END

    update single parameter values
    update single parameter values 2gnb
    Update NRCELL parameters
    create new objects
    create new objects 2gnb
    Add Lists
    Add List a3MeasSsbRsrp 2gnb

    FOR    ${list}                 ${param}                     ${value}           IN
    ...    a2MeashoSsbRsrp         a2ThresholdhoSsbRsrp         34
    ...    a2MeasRedirectSsbRsrp   a2ThresholdRedirectSsbRsrp   24
    ...    a2MeasRedirectSsbRsrq   a2ThresholdRedirectSsbRsrq   24
       Log To Console    NRCELL-1 list ${list} set ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}
       ...   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="${list}"]/item/p[@name="${param}"]
    END

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_711A_2gnb.xml


activate 2gnb SCF and bring tl onAir
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    Load wts file    basic_wts_711A_2gnb
    start wireshark trace
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/SCFC_711A_2gnb.xml
    admin.perform commissioning
    ...    scf_file=${resultBaseDir}/SCFC_711A_2gnb.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_711A_2gnb.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    stop wireshark trace for setup
    check wts in active state
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


update single parameter values 2gnb
    [Documentation]    [PRIVATE]    update single parameter values in SCF for 2gnb
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values for 2gnb - started
    Set Element Text   ${scf_xml}    text=rsrp       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="a3MeasEnabled"]
    ${absThreshSsbRsrpConsolidation}    Set Variable    <p name="absThreshSsbRsrpConsolidation">0</p>
    Add Element        ${scf_xml}     ${absThreshSsbRsrpConsolidation}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="miNrNRMOP"]
    Log To Console    updating single parameter values for 2gnb - finished


create new objects 2gnb
    [Documentation]    [PRIVATE]    create objects in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${obj}   IN
    ...    NRREL
    ...    NRMOPRMA_SA-1
    ...    NRMOPR_SA-2
    ...    NRADJNRCELL
    ...    NRADJGNB
    ...    XNLINK
       run keyword   Create ${obj} 2gnb
    END


Create NRREL 2gnb
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR     ${instance}   ${lcrId}   IN
    ...        2       1
    ...        3       2
           Create single NRREL 2gnb    ${instance}   ${lcrId}
    END



Create single NRREL 2gnb
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${instance}    ${lcrId}
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRREL-${instance}
    ${NRREL}   Set Variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-1/NRREL-${instance}"
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">-2dB</p>
    ...    <p name="cellIndividualSsbRsrqOffset">-2dB</p>
    ...    <p name="gNbId">38</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="handoverAllowedSA">allowed</p>
    ...    <p name="handoverAllowedSARedCap">forbidden</p>
    ...    <p name="isRplCellForPSCell">false</p>
    ...    <p name="lcrId">${lcrId}</p>
    ...    <p name="nrDcAllowed">false</p>
    ...    <p name="removeNotAllowed">false</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRREL}   Catenate     SEPARATOR=\n         ${NRREL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREL}           xpath=.//cmData


Create NRMOPRMA_SA-1 2gnb
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-1
    ${NRMOPRMA_SA}    Set Variable  <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-1"
    ${NRMOPRMA_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mobilityProfilePriority">1</p>
    ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-2</p>
    ...    <p name="rfspIndex">12</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPRMA_SA}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA}           xpath=.//cmData


Create NRMOPR_SA-2 2gnb
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-2
    ${NRMOPR_SA}    Set Variable  <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-2"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a2MeasRedirectEnabled">none</p>
    ...    <p name="emergencyCallFails">disabled</p>
    ...    <p name="emergencyFBMode">disabled</p>
    ...    <p name="voiceFBMode">disabled</p>
    ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRADJNRCELL 2gnb
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR     ${instance}   ${fiveGsTac}    ${lcrId}    ${physCellId}   IN
    ...        1            100          1           48
    ...        2            788          2           49
           Create single NRADJNRCELL 2gnb    ${instance}   ${fiveGsTac}    ${lcrId}    ${physCellId}
    END


Create single NRADJNRCELL 2gnb
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${instance}    ${fiveGsTac}    ${lcrId}    ${physCellId}
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-${instance}
    ${NRADJNRCELL}    Set Variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-${instance}"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellDepType">SA</p>
    ...    <p name="cellReservedForOperatorUse">notReserved</p>
    ...    <p name="fiveGsTac">${fiveGsTac}</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="gNbId">38</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="lcrId">${lcrId}</p>
    ...    <p name="nrarfcn">636666</p>
    ...    <p name="physCellId">${physCellId}</p>
    ...    <p name="ssbFrequency">636576</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRADJNRCELL}   Catenate     SEPARATOR=\n         ${NRADJNRCELL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJNRCELL}           xpath=.//cmData


Create NRADJGNB 2gnb
    [Documentation]    [PRIVATE]    create NRADJGNB object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJGNB-2
    ${NRADJGNB}    Set Variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-2"
    ${NRADJGNB}   Catenate     SEPARATOR=${SPACE}   ${NRADJGNB}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="gNodeBId">38</p>
    ...    <p name="gNodeBIdCtrl">oamControlled</p>
    ...    <p name="xnLinkRef">2</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRADJGNB}   Catenate     SEPARATOR=\n         ${NRADJGNB}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJGNB}           xpath=.//cmData


Create XNLINK 2gnb
    [Documentation]    [PRIVATE]    create XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/XNLINK-2
    ${XNLINK}   Set Variable   <managedObject class="com.nokia.srbts.nrbts:XNLINK" distName="${bts_distName}/XNLINK-2"
    ${XNLINK}   Catenate       SEPARATOR=${SPACE}   ${XNLINK}   version="${SCF.version}" operation="create">
    ${XNLINK}   Catenate       SEPARATOR=\n         ${XNLINK}    <p name="cPlaneIpAddr">10.0.1.6</p>
    ${XNLINK}   Catenate       SEPARATOR=\n         ${XNLINK}    <p name="cPlaneIpAddrCtrl">oamControlled</p>
    ${XNLINK}   Catenate       SEPARATOR=\n         ${XNLINK}    </managedObject>
    Add Element     ${scf_xml}     ${XNLINK}           xpath=.//cmData


Add List a3MeasSsbRsrp 2gnb
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL-1
    ${a3MeasSsbRsrp}    Set Variable    <list name="a3MeasSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">6</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
           ${a3MeasSsbRsrp}   Catenate     SEPARATOR=\n         ${a3MeasSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrp}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
