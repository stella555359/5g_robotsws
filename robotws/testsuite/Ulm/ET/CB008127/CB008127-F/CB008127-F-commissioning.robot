*** Settings ***
Documentation   This is a keyword file for CB008127, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008127-F-commissioning-objects.robot
Resource        CB008127-F-commissioning-lists.robot
Resource        CB008127-F-commissioning-parameter.robot

*** Variables ***

${measurement_period_in_min}     5


*** Keywords ***

set sw release version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   split string    ${gnb_swVersion}    _
    set suite variable    ${release}   ${gnb_sw_version_parts}[0]


Update SCF common
    [Documentation]    [PRIVATE]    update SCF for CB008127-F common
    ...       :Autor: Sylvia Schneider
    set sw release version
    Log To Console    \nstart update SCF CB008127-F common part

    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}
    IF    '${release}'!='SBTS24R3'    update GMC parameter

    Log To Console    remove in all cells parameter "nrDefMoPrSaDN" and object "NRPLMNSET_NSA-1" in all cells
    FOR   ${cell_id}   IN   1   2   3  4
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/p[@name="nrDefMoPrSaDN"]
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END
    FOR   ${path}   IN
    ...   ${bts_distName}/NRMOPR_SA-1
    ...   ${bts_distName}/TRACKINGAREA-200
    ...   ${bts_distName}/NRCELL-1/NRREDRT-0
       Log To Console    remove element "${path}"
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${path}"]
    END

    FOR    ${param}                            ${value}  IN
    ...    actInterFreqHoSA                    true
    ...    actInterRatHoFromEutraToSA          true
    ...    actInterRatHoSA                     true
    ...    actIntraFreqHoSA                    true
    ...    actIpThpt                           true
    ...    actMeasurementProfile               SA
    ...    actNrpmqapProfiles                  true
    ...    actRedirect                         true
    ...    drbInactivityTimerSA                7200
    ...    thpTimeCalc                         enabled
    ...    actPucchF3BasedTaGrantsRed          false
    ...    actMultiDrbNSA                      false
    ...    actMobilityRetryToSecondBestCell    false
        update single nrbts parameter   ${param}   ${value}
    END


    FOR   ${param}   IN
    ...   <p name\="nonContentRachAcFullConfigHo">false</p>
    ...   <p name\="tNgRelocExecDeltL">5000</p>
    ...   <p name\="timerXnDataFwdGuard">250</p>
       Log To Console    "${bts_distName}" add parameter "${param}"
       Add Element        ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}"]
    END

    FOR   ${param}    IN
    ...   <p name\="absThreshSsbRsrpConsolidation">10</p>
    ...   <p name\="absThreshSsbRsrqConsolidation">10</p>
    ...   <p name\="measGapSelectionSA">balancedChoice</p>
    ...   <p name\="mgta">ms0</p>
    ...   <p name\="sMeasConfigSsbRsrp">0</p>
       Log To Console    add parameter "${param}" to cell ${bts_distName}/NRCELL-1
       Add Element        ${scf_xml}    ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
       Log To Console    add parameter "${param}" to cell ${bts_distName}/NRCELL-2
       Add Element        ${scf_xml}    ${param}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]
    END


    add parameter a2MeasReleaseEnabled to nrcell-1

    FOR    ${object}   IN
    ...    NRADJECELL
    ...    NRADJGNB
    ...    NRADJGNB-2
    ...    NRADJNRCELL
    ...    NRCELL-1 NRHOIF-1
    ...    NRCELL-2 NRHOIF-1
    ...    NRHOIR
    ...    NRREL
    ...    NRRELE
    ...    NRMEAS_PROFILE
    ...    NRMEASPR_IAF
    ...    NRMEASPR_IEF
    ...    NRMEASPR_IRF
    ...    NRMEASPR_MA_SA-1
    ...    NRMEASPR_MA_SA-2
    ...    NRPLMN
    ...    SNSSAI
    ...    XNLINK
    ...    XNLINK-2
        run keyword     Create ${object}
    END

    IF    '${release}'=='SBTS25R2' or '${release}'=='SBTS25R3'   Create NRPMQAP_25R   ELSE   Create NRPMQAP

    Recreate NRREDRT

    FOR   ${param}                  ${value}  IN
    ...    a1MeashoEnabled          rsrp
    ...    a1MeashoEnabledSA        rsrp
    ...    a2MeasRedirectEnabled    rsrpCombined
    ...    a2MeashoEnabled          rsrp
    ...    a2MeashoEnabledSA        rsrp
    ...    a3MeasEnabled            rsrp
    ...    a5MeasEnabled            rsrp
    ...    measGapSelection         balancedChoice
       Log To Console    set NRCELL-1 and NRCELL-2 parameter "${param}" to value "${value}"
       Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]
       Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="${param}"]
    END

    FOR   ${NRCELL_id}    ${param}                      ${value}    IN
    ...   1               actEnhancedVoNR               true
    ...   2               actEnhancedVoNR               false
    ...   1               actVoNR                       true
    ...   2               actVoNR                       false
    ...   1               actVoNrMobilityThresholds     VoNrMobilityThresholds
    ...   2               actVoNrMobilityThresholds     off
    ...   1               cbraPreamblesPerSsb           n40
    ...   2               cbraPreamblesPerSsb           n64
       Set Element Text   ${scf_xml}    text=${value}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]/p[@name="${param}"]
    END

    FOR   ${NRCELL_id}    ${list}            ${param}                 ${value}    IN
    ...   1               a1MeashoSsbRsrp          a1ThresholdhoSsbRsrp          104
    ...   1               a1MeashoSsbRsrq          a1ThresholdhoSsbRsrq          104
    ...   1               a2MeasRedirectSsbRsrp    a2ThresholdRedirectSsbRsrp    92
    ...   1               a2MeasRedirectSsbRsrq    a2ThresholdRedirectSsbRsrq    92
    ...   2               a2MeasRedirectSsbRsrp    a2ThresholdRedirectSsbRsrp    25
    ...   1               a2MeashoSsbRsrp          a2ThresholdhoSsbRsrp          100
    ...   1               a2MeashoSsbRsrq          a2ThresholdhoSsbRsrq          100
       ${xpath}   set variable   managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]/list[@name="${list}"]/item/p[@name="${param}"]
       Set Element Text   ${scf_xml}    text=${value}    xpath=.//${xpath}
    END

    FOR    ${list}    IN
    ...    a1MeashoPrefNRLayerSsbRsrpSA
    ...    a1MeashoPrefNRLayerSsbRsrqSA
    ...    a2MeasReleaseSsbRsrq
    ...    a3MeasSsbRsrq
    ...    a5MeasSsbRsrq
    ...    measPrMaSAList
    ...    nrhoirDNList
        run keyword     Add List ${list} to NRCELL-1
    END

    IF    '${release}'=='SBTS24R3'    Add List a2MeasReleaseSsbRsrp to NRCELL-1
    ...   ELSE   Update List a2MeasReleaseSsbRsrp for NRCELL-1

    FOR    ${list}    IN
    ...    a1MeashoSsbRsrpSA
    ...    a1MeashoSsbRsrqSA
    ...    a2MeashoSsbRsrpSA
    ...    a2MeashoSsbRsrqSA
    ...    a3MeasSsbRsrp
    ...    a5MeasSsbRsrp
        run keyword     Add List ${list}
    END

    FOR   ${param}                     ${value}  IN
    ...    miNrMeasProfileInterFreq    ${measurement_period_in_min}min
    ...    miNrMeasProfileInterRat     ${measurement_period_in_min}min
    ...    miNrMeasProfileIntraFreq    ${measurement_period_in_min}min
    ...    miNrMeasProfileMappingSA    ${measurement_period_in_min}min
    ...    miNrRelReportCu             ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END


    FOR   ${param}                  ${value}  IN
    ...    a1MeashoEnabled          rsrp
    ...    a1MeashoEnabledSA        rsrp
    ...    a2MeasRedirectEnabled    rsrpCombined
    ...    a2MeashoEnabled          rsrp
    ...    a2MeashoEnabledSA        rsrp
    ...    a3MeasEnabled            rsrp
    ...    a5MeasEnabled            rsrp
    ...    measGapSelection         balancedChoice
       Log To Console    set NRCELL-2 parameter "${param}" to value "${value}"
       Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="${param}"]
    END

    FOR   ${nrcell_id}   IN   1   2   3   4
       Log To Console    set NRCELL-${nrcell_id} parameter "cellDepType" to value "SA"
       Set Element Text   ${scf_xml}    text=SA       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]/p[@name="cellDepType"]
    END


    FOR     ${new_param}                         ${object}                  ${list}    IN
    ...     <p>${bts_distName}/NRPLMN-2</p>      NRCELL-1/NRPLMNSET_SA-1    nrPlmnDNList
    ...     <p>${bts_distName}/NRPLMN-2</p>      NRCELL-2/NRPLMNSET_SA-1    nrPlmnDNList
    ...     <p>${bts_distName}/NRPLMN-2</p>      NRCELL-3/NRPLMNSET_SA-1    nrPlmnDNList
    ...     <p>${bts_distName}/NRPLMN-2</p>      NRCELL-4/NRPLMNSET_SA-1    nrPlmnDNList
    ...     <p>${bts_distName}/NRPLMN-2</p>      SNSSAI-1                   nrPlmnDNList
       Log To Console    add "${new_param}" to list "${bts_distName}/${object}"]/list[@name="${list}"]
       Add Element   ${scf_xml}   ${new_param}   xpath=.//managedObject[@distName="${bts_distName}/${object}"]/list[@name="${list}"]
    END


    ${TRACKINGAREA}   set variable   <managedObject class="TRACKINGAREA" distName="${bts_distName}/TRACKINGAREA-200"
    ${TRACKINGAREA}   Catenate     SEPARATOR=${SPACE}   ${TRACKINGAREA}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="fiveGsTac">200</p>
    ...    <list name="snssaiList">
    ...    <item>
    ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
    ...    </item>
    ...    <item>
    ...    <p name="snssaiDN">${bts_distName}/SNSSAI-2</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${TRACKINGAREA}   Catenate     SEPARATOR=\n         ${TRACKINGAREA}   ${line}
    END
    Add Element     ${scf_xml}     ${TRACKINGAREA}           xpath=.//cmData

    FOR    ${param}   IN
    ...   miNrMeasProfileInterFreq
    ...   miNrMeasProfileInterRat
    ...   miNrMeasProfileIntraFreq
    ...   miNrMeasProfileMappingSA
    ...   reportingIntervalPm
         Log To Console    ${param} set to value 5min
         Set Element Text   ${scf_xml}    text=5min      xpath=.//p[@name="${param}"]
    END

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB008127_common.xml
    Log To Console    \nsave updated SCF common part ${resultBaseDir}/SCFC_CB008127_common.xml


update GMC parameter
    [Documentation]    [PRIVATE]    update GMC parameter
    ...       :Autor: Sylvia Schneider
    FOR   ${param}   IN
    ...   actNrAutSgnbAddCplSlCellDetRec
    ...   actNrAutUeCtxStpRtSlCellDetRec
    ...   actNrAutDegAdmCtrlSlCellDetRec
       Log To Console    set parameter ${param} to false
       Set Element Text   ${scf_xml}    text=false      xpath=.//p[@name="${param}"]
    END

    Log To Console    \nset actSib1ForNsaCell to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actSib1ForNsaCell"]
    Set Elements Text   ${scf_xml}    text=deactivated     xpath=.//p[@name="actDataForwardingForVoNr"]
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actMaxInitDeltaCqiClampVoNR"]
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actTargetBlerVoNR"]
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actVoNRIncCodingGain"]

    FOR   ${object}      ${param}                      ${value}   IN
    ...   /NRMOPR_SA-1   voiceFBMode                   disabled
    ...   ${EMPTY}       actSliceAwareAdmissionCtrl    false
    ...   ${EMPTY}       actSliceAwareScheduler        false
    ...   ${EMPTY}       actSliceAwareSchedulerUlAndEnh    false
    ...   ${EMPTY}       actA2SgnbRelease              false
    ...   ${EMPTY}       actNormVCFallback             false
    ...   ${EMPTY}       rrcReestabTypeSA              deactivated
    ...   ${EMPTY}       actInterGnbRREPreparedCell    false
    ...   ${EMPTY}       actInterMeNBMobility          false
    ...   ${EMPTY}       actIntraMeNBMobility          false
    ...   /NRCELL-1      actEnhDtxOptimizedScheduler   false
    ...   /NRCELL-1      actDynUlDataSplitMode         false
    ...   /NRCELL-2      actDtxOptimizedScheduler      false
    ...   /NRCELL-2      actEnhDtxOptimizedScheduler   false
    ...   /NRCELL-2      actDynUlDataSplitMode         false
    ...   /NRCELL-3      actDtxOptimizedScheduler      false
    ...   /NRCELL-3      actEnhDtxOptimizedScheduler   false
    ...   /NRCELL-3      actDynUlDataSplitMode         false
    ...   /NRCELL-4      actDtxOptimizedScheduler      false
    ...   /NRCELL-4      actEnhDtxOptimizedScheduler   false
    ...   /NRCELL-4      actDynUlDataSplitMode         false
      Log To Console    set in NRBTS-1${object} param ${param} to value "${value}"
      Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}${object}"]/p[@name="${param}"]
    END

    Log To Console    remove a2MeasReleaseSsbRsrp from NRCELL-2, 3, 4
    FOR   ${cell_id}   IN   2   3  4
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/list[@name="a2MeasReleaseSsbRsrp"]
    END

    Log To Console    update list actVoiceFallbackDuringHOPrep to disabled
    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  Catenate  SEPARATOR=\n
    ...   <list name="actVoiceFallbackDuringHOPrep">
    ...   <p>disabled</p>
    ...   </list>
    Add Element  ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}"]

    FOR   ${NRCELL_id}    ${param}                      ${value}    IN
    ...   1               voiceFBMode                   disabled
    ...   2               voiceFBMode                   disabled
       Set Element Text   ${scf_xml}    text=${value}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]/p[@name="${param}"]
    END




activate SCF and bring tl onAir ${tc}
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_CB008127_F_${tc}.xml started
    admin.perform commissioning
    ...    scf_file=${resultDir}/SCFC_CB008127_F_${tc}.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_CB008127_F_${tc}.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot, only SA
    Bring Airphone TL to on Air status without reboot   force_cu_type=SA
    Log To Console    save final scf ${resultDir}/SCF_final_${tc}.xml
    get scf coam   ${resultDir}    SCF_final_${tc}.xml


remove IRF from profile MA_SA-2
    [Documentation]    [PRIVATE]    delta commissioning to remove IRF from profile MA_SA-2
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning to remove IRF from profile MA_SA-2
    Log To Console     set actVoNrFallbackFromMeasProfile to true

    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    admin.perform delta recommissioning
    ...    ${CURDIR}/remove_IRF_from_MA_SA-2.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}

    Log To Console    delta commissioning finished
    get scf coam    ${resultDir}    SCFC_delta_remove_IRF_from_MA_SA-2.xml
    Log To Console    SCF after delta commissioning saved ${resultDir}/SCFC_delta_remove_IRF_from_MA_SA-2.xml


modify IAF-3 value a2ThresholdRedirectSsbRsrp
    [Documentation]    [PRIVATE]    delta commissioning to modify IAF-3 value a2ThresholdRedirectSsbRsrp
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning to modify IAF-3 value a2ThresholdRedirectSsbRsrp

    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    admin.perform delta recommissioning
    ...    ${CURDIR}/modify_IAF-3_values.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}

    Log To Console    delta commissioning finished
    get scf coam    ${resultDir}    SCFC_delta_modify_IAF-3_values.xml
    Log To Console    SCF after delta commissioning saved ${resultDir}/SCFC_delta_modify_IAF-3_values.xml


Update SCF t1
    [Documentation]    [PRIVATE]    update SCF for t1
    ...        F_InterRAT_handover_for_VoNR_call_with_5QI_criterion_in_measurement_profiles
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for t1
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_common.xml
    set suite variable    ${scf_xml}
    Log To Console    set NRCELL-1 parameter "actVoNrFallbackFromMeasProfile" to value "false"
    Set Element Text   ${scf_xml}    text=false
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="actVoNrFallbackFromMeasProfile"]
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_F_t1.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_F_t1.xml


Update SCF t2
    [Documentation]    [PRIVATE]    update SCF for t2
    ...        F_Reselection_of_measurement_profile_based_on_5QI_and_CA_capability_criterions
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for t2
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_common.xml
    set suite variable    ${scf_xml}

    update single nrbts parameter   param=actMeasProfileCa   value=SA
    FOR    ${object}   IN
    ...    NRMEASPR_IAF-3
    ...    NRMEASPR_IEF-3
    ...    NRMEASPR_IRF-3
    ...    NRMEASPR_MA_SA-3
    ...    NRCACLASS-24
        run keyword     Create ${object}
    END
    update measPrMaSAList from NRCELL-1    measPrPriority=5       NRMEASPR_MA_SA_id=3

    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_F_t2.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_F_t2.xml


Update SCF t3
    [Documentation]    [PRIVATE]    update SCF for t3
    ...        F_Selection_of_measurement_profile_based_on_5QI_and_RedCap_criterions
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for t2
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_common.xml
    set suite variable    ${scf_xml}

    update single nrbts parameter   param=actMeasProfileCa   value=SA
    update single nrbts parameter   param=rrcReestabTypeSA   value=sameGNB
    FOR    ${object}   IN
    ...    NRMEASPR_IAF-3
    ...    NRMEASPR_IAF-4
    ...    NRMEASPR_IEF-3
    ...    NRMEASPR_IRF-3
    ...    NRMEASPR_MA_SA-3
    ...    NRMEASPR_MA_SA-4
    ...    NRCACLASS-24
        run keyword     Create ${object}
    END

    FOR   ${measPrPriority}    ${NRMEASPR_MA_SA_id}    IN
    ...   5                    3
    ...   8                    4
       update measPrMaSAList from NRCELL-1    measPrPriority=${measPrPriority}       NRMEASPR_MA_SA_id=${NRMEASPR_MA_SA_id}
    END

    FOR   ${cell_id}   IN   1   2
       ${xpath}  set variable   managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/p[@name="actRedCapUeSupport"]
       Set Element Text   ${scf_xml}    text=true       xpath=.//${xpath}
    END

    FOR   ${cell_id}   IN   1   2
       ${xpath}  set variable   list[@name="dlDataDmrsFdm"]/item/p[@name="redCap1RxUesEnabled"]
       Set Element Text   ${scf_xml}    text=true       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/${xpath}
    END

    FOR   ${nrcell_id}     ${element}     IN
    ...   1                <p name\="cellBarredRedCap">no barring</p>
    ...   2                <p name\="cellBarredRedCap">no barring</p>
    ...   1                <p name\="maxNumOfRrcSARedCap">9</p>
    ...   2                <p name\="maxNumOfRrcSARedCap">9</p>
       Add element  ${scf_xml}    ${element}  xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]
    END

    Set Element Text   ${scf_xml}    text=allowed
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRREL-3"]/p[@name="handoverAllowedSARedCap"]

    FOR   ${param}              ${value}     IN
    ...   a3OffsetSsbRsrp       10
    ...   a3OffsetSsbRsrpVoNr   15
       ${xpath}   set variable   managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/list[@name="a3MeasSsbRsrp"]/item/p[@name="${param}"]
       Set Element Text   ${scf_xml}    text=${value}       xpath=.//${xpath}
    END

    Set Element Text   ${scf_xml}    text=rsrpCombined    xpath=.//managedObject[@distName="${bts_distName}/NRHOIR-1"]/p[@name="b2MeashoEnabled"]

    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_F_t3.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_F_t3.xml
