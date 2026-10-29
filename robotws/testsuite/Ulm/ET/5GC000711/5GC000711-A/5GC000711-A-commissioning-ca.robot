*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part commissioning ca
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${measurement_period_in_min}          5
${class_NRCELL}                       class="com.nokia.srbts.nrbts:NRCELL"
${cell_distName}                      NRCELL-1
${cell2_distName}                     NRCELL-2


*** Keywords ***

Update SCF CA common part
    [Documentation]    [PRIVATE]    Update SCF CA common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_711A_CA_common.xml

    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${scf_xml}

    Log To Console    remove in all cells object "NRPLMNSET_NSA-1"
    FOR   ${cell_id}   IN   1   2   3  4
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    Log To Console    \nset actSib1ForNsaCell to false in all cells
    Set Elements Text   ${scf_xml}    text=false      xpath=.//p[@name="actSib1ForNsaCell"]

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
    ...   actOverheatingAssistance          false
       Log To Console    set parameter ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
    END

    Log To Console    \nset actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actDynUlDataSplitMode"]

    update single parameter values ca
    Update NRCELL parameters ca
    create new objects ca
    Add Lists
    Add List allowUnsuppBcOrBcs
    Add List a1MeasSCellAddSsbRsrp and Rsrq
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_711A_CA_common.xml


Update SCF CA with tc specific parameters
    [Documentation]    [PRIVATE]    Update common SCF with tc specific parameters
    ...       :Autor: Sylvia Schneider
    Log To Console    nonContentRachAcFullConfigHo set to value ${nonContentRachAcFullConfigHo}
    Log To Console    actMeasBasedSCellAdditionSa set to value ${actMeasBasedSCellAdditionSa}
    Log To Console    sCellAdditionMethod set to value ${sCellAdditionMethod}
    Log To Console    a1MeasSCellAddEnabled set to value ${a1MeasSCellAddEnabled}
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_711A_CA_common.xml
    Set Suite Variable    ${scf_xml}
    Set Element Text   ${scf_xml}    text=${nonContentRachAcFullConfigHo}       xpath=.//p[@name="nonContentRachAcFullConfigHo"]
    Set Element Text   ${scf_xml}    text=${actMeasBasedSCellAdditionSa}          xpath=.//list[@name="actMeasBasedSCellAdditionSa"]/p
    ${xpath_NRCELL-1}   Set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    Set Element Text   ${scf_xml}    text=${a1MeasSCellAddEnabled}              xpath=.//${xpath_NRCELL-1}/p[@name="a1MeasSCellAddEnabled"]
    ${xpath_NRREL-1}   Set Variable    managedObject[@distName="${bts_distName}/NRCELL-1/NRREL-1"]
    Set Element Text   ${scf_xml}    text=${sCellAdditionMethod}                xpath=.//${xpath_NRREL-1}/p[@name="sCellAdditionMethod"]
    Save xml     ${scf_xml}    ${resultDir}/SCFC_711A_CA_tc_specific.xml
    Log To Console    SCF saved ${resultDir}/SCFC_711A_CA_tc_specific.xml


tc specific update and activate SCF CA and bring tl onAir
    [Documentation]    [PRIVATE]    tc specific update and activate SCF CA and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    Update SCF CA with tc specific parameters
    Load wts file    basic_wts_711A_ca
    start wireshark trace
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_711A_CA_tc_specific.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_711A_CA_tc_specific.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_711A_CA_tc_specific.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    stop wireshark trace for setup
    check wts in active state
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    get scf coam   ${resultDir}    SCF_final.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Add List allowUnsuppBcOrBcs
    Log To Console    Building list allowUnsuppBcOrBcs for object ${bts_distName}/NRCELL
    ${allowUnsuppBcOrBcs}    Set Variable    <list name="allowUnsuppBcOrBcs">
    FOR     ${line}   IN
    ...    <p>accept unknown band combinations</p>
    ...    </list>
           ${allowUnsuppBcOrBcs}   Catenate     SEPARATOR=\n         ${allowUnsuppBcOrBcs}   ${line}
    END
    FOR   ${cell_id}   IN   1   2   3   4
       Log To Console    Building list allowUnsuppBcOrBcs for object ${bts_distName}/NRCELL-${cell_id}
       Add Element     ${scf_xml}     ${allowUnsuppBcOrBcs}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]
    END


Add List a1MeasSCellAddSsbRsrp and Rsrq
    Log To Console    Building list a1MeasSCellAddSsbRsrp for object ${bts_distName}/NRCELL-1
    ${a1MeasSCellAddSsbRsrp}    Set Variable    <list name="a1MeasSCellAddSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresisSCellAddSsbRsrp">0</p>
    ...    <p name="a1ThresholdSCellAddSsbRsrpTDD">59</p>
    ...    <p name="a1TimeToTriggerSCellAddSsbRsrp">320ms</p>
    ...    </item>
    ...    </list>
           ${a1MeasSCellAddSsbRsrp}   Catenate     SEPARATOR=\n         ${a1MeasSCellAddSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeasSCellAddSsbRsrp}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]

    Log To Console    Building list a1MeasSCellAddSsbRsrq for object ${bts_distName}/NRCELL-1
    ${a1MeasSCellAddSsbRsrq}    Set Variable    <list name="a1MeasSCellAddSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresisSCellAddSsbRsrq">0</p>
    ...    <p name="a1ThresholdSCellAddSsbRsrq">56</p>
    ...    <p name="a1TimeToTriggerSCellAddSsbRsrq">320ms</p>
    ...    </item>
    ...    </list>
           ${a1MeasSCellAddSsbRsrq}   Catenate     SEPARATOR=\n         ${a1MeasSCellAddSsbRsrq}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeasSCellAddSsbRsrq}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


create new objects ca
    [Documentation]    [PRIVATE]    create objects in SCF ca
    ...       :Autor: Sylvia Schneider
    FOR    ${obj}    IN
    ...    NRADJECELL
    ...    NRADJGNB
    ...    NRREL ca
    ...    NRRELE
    ...    NRHOIR
    ...    XNLINK
       Run Keyword   Create ${obj}
    END


Create NRREL ca
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRREL-1 with lcrId=2
    Create single NRREL ca    NRCELL=1    lcrId=2
    Log To Console    Building object ${bts_distName}/NRCELL-2/NRREL-1 with lcrId=1
    Create single NRREL       NRCELL=2    lcrId=1


Create single NRREL ca
    [Documentation]    [PRIVATE]    create NRREL object in SCF ca
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRCELL}    ${lcrId}
    ${NRREL}   Set Variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-${NRCELL}/NRREL-1"
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
    ...    <p name="sCellAdditionMethod">blind</p>
    ...    <p name="sCellOperationalMode">dlOnly</p>
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


update single parameter values ca
    [Documentation]    [PRIVATE]    update single parameter values in SCF ca
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started
    FOR    ${value}       ${param}     IN
    ...    true           actInterRatHoFromEutraToSA
    ...    true           actInterRatHoSA
    ...    true           actIntraFreqHoSA
    ...    true           actMFBIEutra
    ...    true           actRanSharing
    ...    true           actCarrierAggregation
    ...    SA             gNbCuType
    ...    0              x2LinkSupervisionTmr
    ...    2CCDL_2CCUL    caConfigurationSupport
    ...    false          actPucchF3BasedTaGrantsRed
         Set Element Text   ${scf_xml}    text=${value}       xpath=.//p[@name="${param}"]
         Log To Console    ${param} for NRCELL-1 set to value ${value}
    END

    FOR    ${param}   IN
    ...   miNrRelReportCu
    ...   miNrMobilityReport
    ...   miNrNGCC
    ...   miNrRSACU
    ...   reportingIntervalPm
         Log To Console    ${param} set to value ${measurement_period_in_min}min
         Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="${param}"]
    END

    Set Element Text   ${scf_xml}    text=ca_Fr1Tdd_Sa
    ...      xpath=.//managedObject[@distName="${bts_distName}/NRDU-1"]/list[@name="carrierAggregationSupportList"]/p

    FOR   ${param}   IN
    ...   <p name\="maxNumScellsDl">1</p>
    ...   <p name\="maxNumScellsUl">1</p>
    ...   <p name\="sCellActivationMethod">blind</p>
    ...   <p name\="nonContentRachAcFullConfigHo">true</p>
    ...   <p name\="tNgRelocExecDeltL">5000</p>
    ...   <p name\="timerXnDataFwdGuard">250</p>
          Log To Console    add "${param}" to ${bts_distName}
          Add Element        ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}"]
    END
    Log To Console    updating single parameter values - finished


Update NRCELL parameters ca
    [Documentation]    [PRIVATE]    Update NRCELL parameters ca
    ...       :Autor: Sylvia Schneider
    Log To Console    updating parameters from NRCELL objects
    ${sMeasConfigSsbRsrp}    Set Variable    <p name="sMeasConfigSsbRsrp">4</p>
    FOR    ${NRCELL}       IN
    ...    managedObject[@distName\="${bts_distName}/NRCELL-1"]
    ...    managedObject[@distName\="${bts_distName}/NRCELL-2"]
       Add Element        ${scf_xml}    ${sMeasConfigSsbRsrp}   xpath=.//${NRCELL}
       Set Element Text   ${scf_xml}    text=intra-gNB     xpath=.//${NRCELL}/p[@name="actK1Opt"]
    END

    Set Elements Text   ${scf_xml}    text=SA            xpath=.//p[@name="cellDepType"]
    Set Elements Text   ${scf_xml}    text=infinity      xpath=.//p[@name="sCellDeactivationTimerGNB"]

    ${xpath_NRCELL-1}   Set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    FOR   ${param}   IN
    ...   <p name\="measGapSelectionSA">favourUeThroughput</p>
    ...   <p name\="a1MeasSCellAddEnabled">rsrp</p>
          Add Element       ${scf_xml}    ${param}   xpath=.//${xpath_NRCELL-1}
          Log To Console    add "${param}" to NRCELL-1
    END

    FOR    ${value}       ${param}     IN
    ...    rsrp           a1MeashoEnabled
    ...    rsrp           a1MeashoEnabledSA
    ...    rsrp           a2MeashoEnabled
    ...    rsrp           a2MeashoEnabledSA
    ...    n40            cbraPreamblesPerSsb
    ...    7880           gscnOrSsPbchArfcn
    ...    636666         nrarfcn
         Set Element Text   ${scf_xml}    text=${value}       xpath=.//${xpath_NRCELL-1}/p[@name="${param}"]
         Log To Console    ${param} for NRCELL-1 set to value ${value}
    END

    Set Element Text   ${scf_xml}    text=7995      xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="gscnOrSsPbchArfcn"]
    Set Element Text   ${scf_xml}    text=647666    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="nrarfcn"]

