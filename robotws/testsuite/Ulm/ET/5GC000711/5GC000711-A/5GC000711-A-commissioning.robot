*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${measurement_period_in_min}          5
${class_NRCELL}                       class="com.nokia.srbts.nrbts:NRCELL"
${cell_distName}                      NRCELL-1


*** Keywords ***

set parameters to enable handover
    [Documentation]    [PRIVATE]    execute delta commissioning with parameter
    ...   actInterRatHoFromEutraToSA, nonContentRachAcFullConfigHo, tNgRelocExecDeltL and save final SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning of parameter started
    Log To Console    nonContentRachAcFullConfigHo set to value true
    Log To Console    tNgRelocExecDeltL set to value 5000
    Log To Console    actInterRatHoFromEutraToSA set to value true
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_t5.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/5GC000711-A-scf_update_t5.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/5GC000711-A-scf_update_t5.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished
    get scf coam    ${resultDir}    SCFC_711A_t5_ho_enabled.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_711A_t5_ho_enabled.xml


set actLocationReportingSA to false
    [Documentation]    [PRIVATE]    execute delta commissioning with parameter actLocationReportingSA
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning of parameter started
    Log To Console    actLocationReportingSA set to value false
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_t14.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/5GC000711-A-scf_update_t14.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/5GC000711-A-scf_update_t14.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished


Update SCF common part
    [Documentation]    [PRIVATE]    update SCF common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_711A_common.xml
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}
    Log To Console    remove in all cells object "NRPLMNSET_NSA-1"
    FOR   ${cell_id}   IN   1   2   3  4
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    update single parameter values
    Update NRCELL parameters
    create new objects
    Add Lists
    Update GMC parameters
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_711A_common.xml


Update GMC parameters
    [Documentation]    [PRIVATE]    Update GMC parameters which are needed to use AZQJ_GMC variant
    ...       :Autor: Sylvia Schneider
    set sw release version
    IF    '${release}'=='SBTS24R3'    RETURN

    Log To Console    \nset actSib1ForNsaCell to false in all cells
    Set Elements Text   ${scf_xml}    text=false      xpath=.//p[@name="actSib1ForNsaCell"]

    Log To Console    \nset actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actDynUlDataSplitMode"]

    FOR   ${param}                          ${value}   IN
    ...   actNrAutSgnbAddCplSlCellDetRec    false
    ...   actNrAutUeCtxStpRtSlCellDetRec    false
    ...   actNrAutDegAdmCtrlSlCellDetRec    false
    ...   actInterGnbRREPreparedCell        false
    ...   actA2SgnbRelease                  false
    ...   actInterMeNBMobility              false
    ...   actIntraMeNBMobility              false
    ...   actMobilityRetryToSecondBestCell  false
    ...   actMultiDrbNSA                    false
    ...   periodicalDataUsageReportTimer    0
       Log To Console    set parameter ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
    END


Update SCF with tc specific parameters
    [Documentation]    [PRIVATE]    Update common SCF with tc specific parameters
    ...       :Autor: Sylvia Schneider
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_711A_common.xml
    set suite variable    ${scf_xml}

    FOR    ${param}    IN
    ...    nonContentRachAcFullConfigHo
    ...    tNgRelocExecDeltL
    ...    actInterRatHoFromEutraToSA
    ...    rrcReestabTypeSA
    ...    actLocationReportingSA
        Log To Console    ${param} set to value ${${param}}
        Set Element Text   ${scf_xml}    text=${${param}}    xpath=.//p[@name="${param}"]
    END

    ${xpath_NRCELL-1}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    FOR    ${param}    IN
    ...    maxNumOfCaUsersNRCell
    ...    maxNumOfRrcSA
    ...    maxNumOfSCellAlloc
    ...    maxNumOfUsersPerNRCell
    ...    maxNumOfNrDcSnUsers
    ...    maxNumOfUsersPerCell
        Log To Console    ${param} set to value ${${param}}
        Set Element Text   ${scf_xml}    text=${${param}}    xpath=.//${xpath_NRCELL-1}/p[@name="${param}"]
    END

    ${tag_t4_exists}   count values in list   ${TEST TAGS}   t4
    IF     '${tag_t4_exists}'=='1'     update t4 timer t304
    Save xml     ${scf_xml}    ${resultDir}/SCFC_711A_tc_specific.xml
    Log To Console    SCF saved ${resultDir}/SCFC_711A_tc_specific.xml


update t4 timer t304
    [Documentation]    [PRIVATE]    update t4 timer t304
    ...       :Autor: Sylvia Schneider
    Set Element Text   ${scf_xml}    text=ms200    xpath=.//p[@name="t304"]


tc specific update and activate SCF and bring tl onAir
    [Documentation]    [PRIVATE]    tc specific update and activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    Update SCF with tc specific parameters
    Load wts file    basic_wts_711A
    start wireshark trace
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_711A_tc_specific.xml started
    admin.perform commissioning
    ...    scf_file=${resultDir}/SCFC_711A_tc_specific.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_711A_tc_specific.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    stop wireshark trace for setup
    check wts in active state
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    get scf coam   ${resultDir}    SCF_final.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


create new objects
    [Documentation]    [PRIVATE]    create objects in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${obj}    IN
    ...    NRADJECELL
    ...    NRADJGNB
    ...    NRREL
    ...    NRRELE
    ...    NRHOIR
    ...    XNLINK
       run keyword   Create ${obj}
    END


Create NRADJECELL
    [Documentation]    [PRIVATE]    create NRADJECELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJECELL-1
    ${NRADJECELL}   set variable   <managedObject class="NRADJECELL" distName="${bts_distName}/NRADJECELL-1"
    ${NRADJECELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJECELL}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="eNodeBId">18</p>
    ...    <p name="ePSTrackingAreaCode">222</p>
    ...    <p name="earfcnValue">1</p>
    ...    <p name="iRatDataForwardingMethod">indirectDataFwd</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="physCellId">11</p>
    ...    <list name="ecgiPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    <list name="enbPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRADJECELL}   Catenate     SEPARATOR=\n         ${NRADJECELL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJECELL}           xpath=.//cmData


Create NRADJGNB
    [Documentation]    [PRIVATE]    create NRADJGNB object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJGNB-1
    ${NRADJGNB}    set variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-1"
    ${NRADJGNB}   Catenate     SEPARATOR=${SPACE}   ${NRADJGNB}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="gNodeBId">18</p>
    ...    <p name="gNodeBIdCtrl">oamControlled</p>
    ...    <p name="xnLinkRef">1</p>
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
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${SCF.version}" operation="create">
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
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRREL}   Catenate     SEPARATOR=\n         ${NRREL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREL}           xpath=.//cmData


Create NRRELE
    [Documentation]    [PRIVATE]    create NRRELE object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRRELE-1
    ${NRRELE}   set variable   <managedObject class="NRRELE" distName="${bts_distName}/NRCELL-1/NRRELE-1"
    ${NRRELE}   Catenate     SEPARATOR=${SPACE}   ${NRRELE}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualOffset">0dB</p>
    ...    <p name="eNodeBId">18</p>
    ...    <p name="removeNotAllowed">false</p>
    ...    <p name="eutranCellExcluded">false</p>
    ...    <p name="lcrId">1</p>
    ...    <list name="ecgiPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRRELE}   Catenate     SEPARATOR=\n         ${NRRELE}   ${line}
    END
    Add Element     ${scf_xml}     ${NRRELE}           xpath=.//cmData


Create NRHOIR
    [Documentation]    [PRIVATE]    create NRHOIR object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRHOIR-1
    ${NRHOIR}   set variable   <managedObject class="NRHOIR" distName="${bts_distName}/NRHOIR-1"
    ${NRHOIR}   Catenate     SEPARATOR=${SPACE}   ${NRHOIR}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="allowedMeasBandwidth">mbw50</p>
    ...    <p name="b1MeasRedirectEnabled">none</p>
    ...    <p name="b2MeashoEnabled">rsrq</p>
    ...    <p name="b2Threshold1hoRsrp">35</p>
    ...    <p name="b2Threshold1hoRsrpVoNr">45</p>
    ...    <p name="b2Threshold1hoRsrq">50</p>
    ...    <p name="b2Threshold1hoRsrqVoNr">60</p>
    ...    <p name="earfcnValue">1</p>
    ...    <p name="eutraFreqQOffsetRange">0dB</p>
    ...    <p name="presenceAntennaPort1">false</p>
    ...    <p name="reportAmount">r8</p>
    ...    <p name="reportInterval">ms240</p>
    ...    <p name="widebandRsrqMeas">true</p>
    ...    <list name="eutraB2MeashoRsrp">
    ...    <item>
    ...    <p name="b2HysteresishoRsrp">0</p>
    ...    <p name="b2HysteresishoRsrpVoNr">0</p>
    ...    <p name="b2Threshold2hoRsrp">18</p>
    ...    <p name="b2Threshold2hoRsrpVoNr">28</p>
    ...    <p name="b2TimeToTriggerhoRsrp">ms480</p>
    ...    <p name="b2TimeToTriggerhoRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="eutraB2MeashoRsrq">
    ...    <item>
    ...    <p name="b2HysteresishoRsrq">0</p>
    ...    <p name="b2HysteresishoRsrqVoNr">0</p>
    ...    <p name="b2Threshold2hoRsrq">2</p>
    ...    <p name="b2Threshold2hoRsrqVoNr">12</p>
    ...    <p name="b2TimeToTriggerhoRsrq">ms480</p>
    ...    <p name="b2TimeToTriggerhoRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRHOIR}   Catenate     SEPARATOR=\n         ${NRHOIR}   ${line}
    END
    Add Element     ${scf_xml}     ${NRHOIR}           xpath=.//cmData


Create NRPLMNSET_SA
    Create single NRPLMNSET_SA    NRCELL=1
    Create single NRPLMNSET_SA    NRCELL=2


Create single NRPLMNSET_SA
    [Documentation]    [PRIVATE]    create NRPLMNSET_SA object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${NRCELL}
    Log To Console    Building object ${bts_distName}/NRCELL-${NRCELL}/NRPLMNSET_SA-1
    ${NRPLMNSET_SA}
    ...    set variable  <managedObject class="com.nokia.srbts.nrbts:NRPLMNSET_SA" distName="${bts_distName}/NRCELL-${NRCELL}/NRPLMNSET_SA-1"
    ${NRPLMNSET_SA}   Catenate     SEPARATOR=${SPACE}   ${NRPLMNSET_SA}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    <p name="trackingAreaDN">${bts_distName}/TRACKINGAREA-200</p>
    ...    </managedObject>
           ${NRPLMNSET_SA}   Catenate     SEPARATOR=\n         ${NRPLMNSET_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRPLMNSET_SA}           xpath=.//cmData


Create XNLINK
    [Documentation]    [PRIVATE]    create XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/XNLINK-1
    ${XNLINK}   set variable   <managedObject class="com.nokia.srbts.nrbts:XNLINK" distName="${bts_distName}/XNLINK-1"
    ${XNLINK}   catenate       SEPARATOR=${SPACE}   ${XNLINK}   version="${SCF.version}" operation="create">
    ${XNLINK}   catenate       SEPARATOR=\n         ${XNLINK}    <p name="cPlaneIpAddr">10.0.1.5</p>
    ${XNLINK}   catenate       SEPARATOR=\n         ${XNLINK}    <p name="cPlaneIpAddrCtrl">oamControlled</p>
    ${XNLINK}   catenate       SEPARATOR=\n         ${XNLINK}    </managedObject>
    Add Element     ${scf_xml}     ${XNLINK}           xpath=.//cmData


update single parameter values
    [Documentation]    [PRIVATE]    update single parameter values in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started
    FOR    ${value}    ${param}   IN
    ...    true        actInterRatHoFromEutraToSA
    ...    true        actInterRatHoSA
    ...    true        actIntraFreqHoSA
    ...    true        actMFBIEutra
    ...    true        actRanSharing
    ...    SA          gNbCuType
    ...    0           x2LinkSupervisionTmr
    ...    false       actPucchF3BasedTaGrantsRed
         Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
         Log To Console    ${param} set to value ${value}
    END

    FOR    ${param}   IN
    ...   miNrRelReportCu
    ...   miNrMobilityReport
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
    FOR    ${NRCELL}       IN
    ...    managedObject[@distName\="${bts_distName}/NRCELL-1"]
    ...    managedObject[@distName\="${bts_distName}/NRCELL-2"]
       ${sMeasConfigSsbRsrp}    set variable    <p name="sMeasConfigSsbRsrp">4</p>
       Add Element        ${scf_xml}     ${sMeasConfigSsbRsrp}   xpath=.//${NRCELL}
       Set Element Text   ${scf_xml}    text=SA        xpath=.//${NRCELL}/p[@name="cellDepType"]
    END

    FOR    ${NRCELL}       IN
    ...    managedObject[@distName\="${bts_distName}/NRCELL-3"]
    ...    managedObject[@distName\="${bts_distName}/NRCELL-4"]
       Set Element Text   ${scf_xml}    text=SA        xpath=.//${NRCELL}/p[@name="cellDepType"]
    END

    ${xpath_NRCELL-1}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${measGapSelectionSA}    set variable    <p name="measGapSelectionSA">favourUeThroughput</p>
    Add Element        ${scf_xml}    ${measGapSelectionSA}   xpath=.//${xpath_NRCELL-1}
    FOR    ${value}    ${param}   IN
    ...    rsrp        a1MeashoEnabled
    ...    rsrp        a1MeashoEnabledSA
    ...    rsrp        a2MeashoEnabled
    ...    rsrp        a2MeashoEnabledSA
    ...    n40        cbraPreamblesPerSsb
         Set Element Text   ${scf_xml}    text=${value}      xpath=.//${xpath_NRCELL-1}/p[@name="${param}"]
         Log To Console    ${param} set to value ${value} for NRCELL-1
    END


Add Lists
    Create List a1MeashoSsbRsrpSA
    Create List a1MeashoSsbRsrqSA
    Create List a2MeashoSsbRsrpSA
    Create List a2MeashoSsbRsrqSA
    Create List nrhoirDNList


Create List a1MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrpSA in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a1MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-1
    ${a1MeashoSsbRsrpSA}    set variable    <list name="a1MeashoSsbRsrpSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrpSA">0</p>
    ...    <p name="a1HysteresisHoSsbRsrpVoNr">0</p>
    ...    <p name="a1ThresholdhoSsbRsrpSA">39</p>
    ...    <p name="a1ThresholdHoSsbRsrpVoNr">49</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrpSA">ms480</p>
    ...    <p name="a1TimeToTriggerHoSsbRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${a1MeashoSsbRsrpSA}   Catenate     SEPARATOR=\n         ${a1MeashoSsbRsrpSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeashoSsbRsrpSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List a1MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrqSA in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a1MeashoSsbRsrqSA for object ${bts_distName}/NRCELL-1
    ${a1MeashoSsbRsrqSA}    set variable    <list name="a1MeashoSsbRsrqSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrqSA">0</p>
    ...    <p name="a1HysteresisHoSsbRsrqVoNr">0</p>
    ...    <p name="a1ThresholdhoSsbRsrqSA">36</p>
    ...    <p name="a1ThresholdHoSsbRsrqVoNr">46</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrqSA">ms480</p>
    ...    <p name="a1TimeToTriggerHoSsbRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${a1MeashoSsbRsrqSA}   Catenate     SEPARATOR=\n         ${a1MeashoSsbRsrqSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeashoSsbRsrqSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List a2MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrpSA in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-1
    ${a2MeashoSsbRsrpSA}    set variable    <list name="a2MeashoSsbRsrpSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrpSA">0</p>
    ...    <p name="a2HysteresisHoSsbRsrpVoNr">0</p>
    ...    <p name="a2ThresholdhoSsbRsrpSA">35</p>
    ...    <p name="a2ThresholdHoSsbRsrpVoNr">44</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrpSA">ms480</p>
    ...    <p name="a2TimeToTriggerHoSsbRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${a2MeashoSsbRsrpSA}   Catenate     SEPARATOR=\n         ${a2MeashoSsbRsrpSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a2MeashoSsbRsrpSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List a2MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrqSA in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeashoSsbRsrqSA for object ${bts_distName}/NRCELL-1
    ${a2MeashoSsbRsrqSA}    set variable    <list name="a2MeashoSsbRsrqSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrqSA">0</p>
    ...    <p name="a2HysteresisHoSsbRsrqVoNr">0</p>
    ...    <p name="a2ThresholdhoSsbRsrqSA">32</p>
    ...    <p name="a2ThresholdHoSsbRsrqVoNr">41</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrqSA">ms480</p>
    ...    <p name="a2TimeToTriggerHoSsbRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${a2MeashoSsbRsrqSA}   Catenate     SEPARATOR=\n         ${a2MeashoSsbRsrqSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a2MeashoSsbRsrqSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List nrhoirDNList
    [Documentation]    [PRIVATE]    create List nrhoirDNList in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list nrhoirDNList for object ${bts_distName}/NRCELL-1
    ${nrhoirDNList}    set variable    <list name="nrhoirDNList">
    FOR     ${line}   IN
    ...    <p>${bts_distName}/NRHOIR-1</p>
    ...    </list>
           ${nrhoirDNList}   Catenate     SEPARATOR=\n         ${nrhoirDNList}   ${line}
    END
    Add Element     ${scf_xml}     ${nrhoirDNList}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
