*** Settings ***
Documentation   This is a keyword file for CB008127, part commissioning 2bands
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008127-commissioning-objects.robot
Resource        CB008127-commissioning-lists.robot
Resource        CB008127-commissioning-parameter.robot

*** Variables ***

${measurement_period_in_min}     5


*** Keywords ***



Update SCF File For TC CB008127 Common 2bands
    [Documentation]    [PRIVATE]    update SCF for 2bands common
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF 2bands common
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${scf_xml}

    Log To Console    remove parameter "nrDefMoPrSaDN" in all cells
    FOR   ${cell_id}   IN   1   2   3  4
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/p[@name="nrDefMoPrSaDN"]
    END
    Log To Console    remove element "${bts_distName}/NRMOPR_SA-1"
    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]
    Log To Console    remove element "${bts_distName}/TRACKINGAREA-200"
    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/TRACKINGAREA-200"]
    Log To Console    remove element "${bts_distName}/NRCELL-1/NRREDRT-0"
    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRREDRT-0"]

    FOR   ${param}   ${value}  IN
    ...    actInterFreqHoSA                    true
    ...    actIntraFreqHoSA                    true
    ...    actIpThpt                           true
    ...    actHigherPrioFreqHo                 SA
    ...    actMeasurementProfile               SA
    ...    actNrpmqapProfiles                  true
    ...    drbInactivityTimerSA                7200
    ...    thpTimeCalc                         enabled
    ...    actPucchF3BasedTaGrantsRed          false
    ...    actNormVCFallback                   false
    ...    actRedirect                         false
    ...    actSliceAwareScheduler              false
    ...    actSliceAwareAdmissionCtrl          false
	...    actSliceAwareSchedulerUlAndEnh      false
	...    actVoFallBackLteB1MeaBaRedir        false
        Update Single Nrbts Parameter   ${param}   ${value}
    END

    FOR   ${object}      ${param}                       IN
    ...   /NRCELL-1      actDtxOptimizedScheduler
    ...   /NRCELL-1      actEnhDtxOptimizedScheduler
    ...   /NRCELL-2      actDtxOptimizedScheduler
    ...   /NRCELL-2      actEnhDtxOptimizedScheduler
    ...   /NRCELL-2      actDlSrsBm
    ...   /NRCELL-2      actDlRankProbing
    ...   /NRCELL-2      actInterRankSwitchBlock
    ...   /NRCELL-2      actDlSrsForCA
    ...   /NRCELL-2      actCsirsBeamPowerBalance
    ...   /NRCELL-2      actDlMuMimoEnh
    ...   /NRCELL-2      actPdschBeamPowerBalance
    ...   /NRCELL-2      actSrsBeamFallbackByRetrx
    ...   /NRCELL-2      actUlSrsBm
    ...   /NRCELL-2      actSrsUlBeamFallbackByRetrx
    ...   /NRCELL-2      actUlMuMimo
    ...   /NRCELL-2      actAdaptiveReTxResMcsEnh
    ...   /NRCELL-3      actDtxOptimizedScheduler
    ...   /NRCELL-3      actEnhDtxOptimizedScheduler
    ...   /NRCELL-4      actDtxOptimizedScheduler
    ...   /NRCELL-4      actEnhDtxOptimizedScheduler
      Log To Console    set in NRBTS-1${object} param ${param} to value "false"
      Set Element Text   ${scf_xml}    text=false       xpath=.//managedObject[@distName="${bts_distName}${object}"]/p[@name="${param}"]
    END

    Log To Console    update list actVoiceFallbackDuringHOPrep to disabled
    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  Catenate  SEPARATOR=\n
    ...   <list name="actVoiceFallbackDuringHOPrep">
    ...   <p>disabled</p>
    ...   </list>
    Add Element  ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}"]

    Log To Console    remove element NRCELL-2/NRDLMUMIMO-1
    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2/NRDLMUMIMO-1"]

    Update Single Nrcell-1 Parameter   param=cbraPreamblesPerSsb   value=n40

    FOR    ${param}                ${value}   IN
    ...    chBw                    80MHz
    ...    freqBandIndicatorNR     41
    ...    gscnOrSsPbchArfcn       6351
    ...    nrarfcn                 508020
        Update Single Nrcell-2 Parameter   param=${param}   value=${value}
    END

    Add TNgRelocExecDeltL TimerXnDataFwdGuard To Mrbts Object
    Add Parameters To All Nrcell Objects

    FOR    ${object}   IN
    ...    NRADJGNB
    ...    NRADJNRCELL
    ...    NRHOIF 2bands
    ...    NRREL
    ...    NRMEAS_PROFILE
    ...    NRMEASPR_IAF
    ...    NRMEASPR_MA_SA
    ...    NRPLMN
    ...    SNSSAI
        Run Keyword     Create ${object}
    END

    Set Sw Release Version
    IF    '${RELEASE}'=='SBTS25R2' or '${RELEASE}'=='SBTS25R3'   Create NRPMQAP_25R   ELSE   Create NRPMQAP

    FOR    ${list}    IN
    ...    a1MeashoPrefNRLayerSsbRsrpSA
    ...    a1MeashoPrefNRLayerSsbRsrqSA
    ...    a2MeasReleaseSsbRsrq
    ...    a3MeasSsbRsrq
    ...    a5MeasSsbRsrq
    ...    measPrMaSAList
        Run Keyword     Add List ${list} To NRCELL-1
    END

    Update List A2MeasReleaseSsbRsrp NRCELL-1 A2ThresholdReleaseSsbRsrp Value 88
    Update List A1MeashoSsbRsrpSA VoNr


    FOR    ${list}    IN
    ...    a1MeashoSsbRsrqSA
    ...    a2MeashoSsbRsrpSA
    ...    a2MeashoSsbRsrqSA
    ...    a3MeasSsbRsrp
    ...    a5MeasSsbRsrp
        Run Keyword     Add List ${list}
    END

    FOR   ${param}                     ${value}  IN
    ...    miNrMeasProfileInterFreq    ${measurement_period_in_min}min
    ...    miNrMeasProfileInterRat     ${measurement_period_in_min}min
    ...    miNrMeasProfileIntraFreq    ${measurement_period_in_min}min
    ...    miNrMeasProfileMappingSA    ${measurement_period_in_min}min
    ...    miNrRelReportCu             ${measurement_period_in_min}min
       Update Single Nrpmnrl Parameter       ${param}   ${value}
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
       Log To Console    set NRCELL-1 parameter "${param}" to value "${value}"
       Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]
       Log To Console    set NRCELL-2 parameter "${param}" to value "${value}"
       Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="${param}"]
    END

    FOR   ${nrcell_id}   ${list}                   ${param}                     ${value}    IN
    ...   1              a1MeashoSsbRsrp           a1ThresholdhoSsbRsrp         104
    ...   1              a1MeashoSsbRsrq           a1ThresholdhoSsbRsrq         104
    ...   1              a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp   92
    ...   2              a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp   25
    ...   1              a2MeasRedirectSsbRsrq     a2ThresholdRedirectSsbRsrq   92
    ...   1              a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp         100
    ...   1              a2MeashoSsbRsrq           a2ThresholdhoSsbRsrq         100
       Update Single List Parameter Nrcell   nrcell_id=${nrcell_id}   list=${list}    param=${param}   value=${value}
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

    ${TRACKINGAREA}   Set Variable   <managedObject class="TRACKINGAREA" distName="${bts_distName}/TRACKINGAREA-200"
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

    ${nonContentRachAcFullConfigHo}    Set Variable    <p name="nonContentRachAcFullConfigHo">true</p>
    Log To Console    add parameter "${nonContentRachAcFullConfigHo}" to "${bts_distName}"
    Add Element        ${scf_xml}     ${nonContentRachAcFullConfigHo}   xpath=.//managedObject[@distName="${bts_distName}"]

    Add List A4PeriodicMeasControlSA To NRCELL
    ${xpath_nrcell-1}   Set Variable   managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${xpath_nrcell-2}   Set Variable   managedObject[@distName="${bts_distName}/NRCELL-2"]
    ${a4MeasHigherPrioFreqMaxReactSA}    Set Variable    <p name="a4MeasHigherPrioFreqMaxReactSA">1</p>
    Log To Console    add parameter "${a4MeasHigherPrioFreqMaxReactSA}" to "${bts_distName}/NRCELL-1"
    Add Element        ${scf_xml}     ${a4MeasHigherPrioFreqMaxReactSA}   xpath=.//${xpath_nrcell-1}
    ${a4MeasHigherPrioFreqMaxReactSA}    Set Variable    <p name="a4MeasHigherPrioFreqMaxReactSA">0</p>
    Add Element        ${scf_xml}     ${a4MeasHigherPrioFreqMaxReactSA}   xpath=.//${xpath_nrcell-2}

    Log To Console    NRCELL_1 and 2, set parameter "a1ThresholdhoSsbRsrp" in list a1MeashoPrefNRLayerSsbRsrpSA to value "108"
    Set Element Text   ${scf_xml}    text=108
    ...   xpath=.//${xpath_nrcell-1}/list[@name="a1MeashoPrefNRLayerSsbRsrpSA"]/item/p[@name="a1ThresholdhoSsbRsrp"]
    Set Element Text   ${scf_xml}    text=108
    ...   xpath=.//${xpath_nrcell-2}/list[@name="a1MeashoPrefNRLayerSsbRsrpSA"]/item/p[@name="a1ThresholdhoSsbRsrp"]
    Log To Console    set parameter "a1ThresholdhoSsbRsrq" in list a1MeashoPrefNRLayerSsbRsrqSA to value "108"
    Set Element Text   ${scf_xml}    text=108
    ...   xpath=.//${xpath_nrcell-1}/list[@name="a1MeashoPrefNRLayerSsbRsrqSA"]/item/p[@name="a1ThresholdhoSsbRsrq"]

    Set A1MeashoPrefNRLayerEnabledSA In NRCELL-1 To rsrpCombined

    Log To Console    set RMOD parameter "prodCodePlanned" to value "475124A"
    Set Element Text   ${scf_xml}    text=475124A       xpath=.//managedObject[@distName="MRBTS-1/EQM-1/APEQM-1/RMOD-2"]/p[@name="prodCodePlanned"]

    Log To Console    Building object ${bts_distName}/XNLINK-1
    ${new_MO}   Set Variable   <managedObject class="com.nokia.srbts.nrbts:XNLINK" distName="${bts_distName}/XNLINK-1"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cPlaneIpAddr">10.0.1.3</p>
           ...    <p name="cPlaneIpAddrCtrl">oamControlled</p>
           ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData

    Save Xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB008127_2bands_common.xml
    Log To Console    \nsave SCF in ${resultBaseDir}/SCFC_CB008127_2bands_common.xml


Activate SCF 2bands And Bring Tl OnAir ${tc}
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    ${scf}      IF   '${tc}'=='t17'    Set Variable    ${resultDir}/SCFC_CB008127_t17.xml
    ...    ELSE IF   '${tc}'=='t18'    Set Variable    ${resultDir}/SCFC_CB008127_t18.xml
    ...    ELSE IF   '${tc}'=='t19'    Set Variable    ${resultDir}/SCFC_CB008127_t19.xml
    ...    ELSE IF   '${tc}'=='t22'    Set Variable    ${resultDir}/SCFC_CB008127_t22.xml
    ...    ELSE IF   '${tc}'=='t23'    Set Variable    ${resultDir}/SCFC_CB008127_t23.xml
    ...    ELSE                        Set Variable    ${resultBaseDir}/SCFC_CB008127_2bands_common.xml
    Kill WTS Services
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Log To Console    activate ${scf} started
    admin.Perform Commissioning
    ...    scf_file=${scf}
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${scf} finished
    Run Keyword And Ignore Error    connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}
    Check All Radio Units Online
    Log To Console    start to bring tl on air without reboot

    IF   '${tc}'=='t19' or '${tc}'=='t23'   Bring Airphone TL To On Air Status Without Reboot    force_cu_type=SA
    ...   ELSE     Bring Airphone TL To On Air Status Without Reboot
    IF   '${tc}'=='t16'   Delta Commissioning ActA1HoPrefNRLayer   none   ${tc}
    ...         ELSE      Delta Commissioning ActA1HoPrefNRLayer   SA     ${tc}
    Log To Console    save final scf ${resultDir}/SCF_final_${tc}.xml
    Get Scf Coam   ${resultDir}    SCF_final_${tc}.xml


Delta Commissioning ActA1HoPrefNRLayer
    [Documentation]    [PRIVATE]    delta commissioning actA1HoPrefNRLayer
    ...        AB_Second_RRC_Reconfiguration_for_InterFreq_A2_after_Xn_handover_using_measurement_profile
    ...        AB_Second_RRC_Reconfiguration_for_A1_based_traffic_steering_after_Xn_handover
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${actA1HoPrefNRLayer}   ${tc}
    Log To Console    \ndelta commissioning of parameter actA1HoPrefNRLayer to value "${actA1HoPrefNRLayer}" started
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_actA1HoPrefNRLayer.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/scf_update_actA1HoPrefNRLayer.xml    ${delta_SCF_update}
    Execute Delta Commissioning    delta_scf_template=${resultDir}/scf_update_actA1HoPrefNRLayer.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter actA1HoPrefNRLayer finished
    Get Scf Coam    ${resultDir}    SCFC_CB008127_${tc}.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_CB008127_${tc}.xml


Update SCF 2bands T17
    [Documentation]    [PRIVATE]    update SCF 2bands for t17
    ...        AB_Second_RRC_Reconfiguration_for_A1_based_traffic_steering_after_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for A1_based_traffic_steering_after_Xn_handover test
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB008127_2bands_common.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect   true
    Recreate 2bands NRREDRT

    Set Element Text   ${scf_xml}    text=rsrpCombined
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/p[@name="a4MeasHigherPrioFreqEnabled"]
    Create NRMEASPR IEF T19
    Recreate NRMEASPR MA SA-5 And NRMEASPR MA SA-6
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t17.xml
    scf.Load Scf    ${resultDir}/SCFC_CB008127_t17.xml


Update SCF 2bands T18
    [Documentation]    [PRIVATE]    update SCF 2bands for t18
    ...        AB_Second_RRC_Reconfiguration_using_measurment_profile_after_NG_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for mobility profiles test
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB008127_2bands_common.xml
    Set Suite Variable    ${scf_xml}

    FOR   ${param}   ${value}  IN
    ...    actIntraNrNgHo               sourceAndTarget
    ...    actRedirect                  true
    ...    tNgRelocOverall              3000
        Update Single Nrbts Parameter   ${param}   ${value}
    END

    FOR   ${param}   IN
    ...   <p name\="suppCnPartialAdNgHo">false</p>
    ...   <p name\="tNgRelocCancelN">2000</p>
    ...   <p name\="tNgRelocExecDeltN">3000</p>
    ...   <p name\="tNgRelocOverallN">3000</p>
    ...   <p name\="tNgRelocPrepN">2000</p>
        Add Element        ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}"]
    END


    FOR   ${param}       IN
    ...    a1MeashoPrefNRLayerEnabledSA
    ...    a2MeasRedirectEnabled
    ...    a2MeashoEnabledSA
    ...    a3MeasEnabled
    ...    a5MeasEnabled
       Log To Console    set NRCELL-1 parameter "${param}" to value "rsrq"
       Set Element Text   ${scf_xml}    text=rsrq       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]
    END

    Recreate 2bands NRREDRT

    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t18.xml
    scf.Load Scf    ${resultDir}/SCFC_CB008127_t18.xml
    Log To Console    remove element "${bts_distName}/XNLINK-1"
    scf.Remove Mo With Descendant Mos        dist_name=${bts_distName}/XNLINK-1
    Log To Console    remove parameter "xnLinkRef" from objct "${bts_distName}/NRADJGNB-1"
    scf.Remove Element From Scf    dist_name=${bts_distName}/NRADJGNB-1       p_name=xnLinkRef
    scf.Save Scf    ${resultDir}/SCFC_CB008127_t18.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t18.xml


Update SCF 2bands T19
    [Documentation]    [PRIVATE]    update SCF 2bands for t19
    ...        AB_Second_RRC_Reconfiguration_after_interRAT_HO_from_LTE_using_measurement_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for interRAT mobility profiles test
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB008127_2bands_common.xml
    Set Suite Variable    ${scf_xml}

    FOR   ${param}   IN
    ...   actNrAutSgnbAddCplSlCellDetRec
    ...   actNrAutUeCtxStpRtSlCellDetRec
    ...   actNrAutDegAdmCtrlSlCellDetRec
    ...   actInterMeNBMobility
    ...   actIntraMeNBMobility
    ...   actMobilityRetryToSecondBestCell
    ...   actMultiDrbNSA
       Log To Console    set parameter ${param} to false
       Set Element Text   ${scf_xml}    text=false      xpath=.//p[@name="${param}"]
    END
    Log To Console    \nset actSib1ForNsaCell and actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actSib1ForNsaCell"]
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actDynUlDataSplitMode"]

    FOR   ${param}                             ${value}  IN
    ...    actInterRatHoFromEutraToSA          true
    ...    actInterRatHoSA                     true
    ...    actInterFreqHoSA                    true
    ...    actRedirect                         true
    ...    nonContentRachAcFullConfigHo        false
        Update Single Nrbts Parameter   ${param}   ${value}
    END

    FOR   ${obj}   IN
    ...   NRADJECELL
    ...   NRADJGNB-2
    ...   NRRELE
    ...   NRHOIR
    ...   NRMEASPR_IRF
    ...   XNLINK-2
       Run Keyword   Create ${obj}
    END

    Recreate 2bands NRREDRT

    Add List NrhoirDNList To NRCELL-1
    Update 2bands A1MeashoPrefNRLayerSsb A1ThresholdhoSsb In NRMEASPR IAF

    FOR   ${NRMEASPR_MA_SA_id}  IN  1   2   3   4   5   6   7  8
       ${add_IRF}  Set Variable   <p name="nrMeasPrIrfDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-${NRMEASPR_MA_SA_id}</p>
       ${xpath}    Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${NRMEASPR_MA_SA_id}"]
       Add Element    ${scf_xml}    ${add_IRF}   xpath=.//${xpath}
    END

    Log To Console    set NRCELL-1 parameter "a1MeashoPrefNRLayerEnabledSA" to value "rsrp"
    Set Element Text   ${scf_xml}    text=rsrp
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="a1MeashoPrefNRLayerEnabledSA"]

    FOR   ${cell_id}   IN   1   2   3   4
       Set Element Text   ${scf_xml}    text=SA       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/p[@name="cellDepType"]
       Log To Console    set NRCELL-${cell_id} parameter "cellDepType" to value "SA"
    END

    FOR   ${cell_id}   IN   3   4
       ${xpath}  Set Variable   list[@name="a4PeriodicMeasControlSA"]/item/p[@name="a4Fr1SupervisionTimer"]
       Set Element Text   ${scf_xml}    text=10000    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/${xpath}
       Log To Console    set NRCELL-${cell_id}, list a4PeriodicMeasControlSA, parameter "a4Fr1SupervisionTimer" to value "10000"
    END

    Log To Console    remove in all cells object "NRPLMNSET_NSA-1"
    FOR   ${cell_id}   IN   1   2   3  4
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    Set Element Text   ${scf_xml}    text=rsrpCombined
    ...       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/p[@name="a3MeasEnabled"]
    Set Element Text   ${scf_xml}    text=rsrp       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/p[@name="a5MeasEnabled"]

    Add List A5MeasSsbRsrp A5MeasSsbRsrq To NRCELL-1 NRHOIF-1
    Create NRMEASPR IEF T19
    Recreate NRMEASPR MA SA-5 And NRMEASPR MA SA-6
    FOR  ${id}  IN  5  6
       ${nrMeasPrIrfDN}  Set Variable  <p name="nrMeasPrIrfDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IRF-${id}</p>
       Add Element   ${scf_xml}  ${nrMeasPrIrfDN}   xpath=.//managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}"]
    END
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t19.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t19.xml


Update 2bands A1MeashoPrefNRLayerSsb A1ThresholdhoSsb In NRMEASPR IAF
    [Documentation]    [PRIVATE]    update 2bands a1MeashoPrefNRLayerSsb_a1ThresholdhoSsb in NRMEASPR_IAF
    ...       :Autor: Sylvia Schneider

    ${xpath_rsrp}   Set Variable   list[@name="a1MeashoPrefNRLayerSsbRsrp"]/item/p[@name="a1ThresholdhoSsbRsrp"]
    ${xpath_rsrq}   Set Variable   list[@name="a1MeashoPrefNRLayerSsbRsrq"]/item/p[@name="a1ThresholdhoSsbRsrq"]
    FOR   ${index}  IN   1   2   3   4   5   7   8
        ${xpath1}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${index}"]
        Log To Console   set parameter "${xpath1}/${xpath_rsrp}" to value "${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[${index}]"
        Set Element Text   ${scf_xml}    text=${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[${index}]   xpath=.//${xpath1}/${xpath_rsrp}
        Log To Console   set parameter "${xpath1}/${xpath_rsrq}" to value "${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[${index}]"
        Set Element Text   ${scf_xml}    text=${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[${index}]   xpath=.//${xpath1}/${xpath_rsrq}
    END

    ${xpath1}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-6"]
    Log To Console   set parameter "${xpath1}/${xpath_rsrp}" to value "84"
    Set Element Text   ${scf_xml}    text=84   xpath=.//${xpath1}/${xpath_rsrp}
    Log To Console   set parameter "${xpath1}/${xpath_rsrq}" to value "84"
    Set Element Text   ${scf_xml}    text=84   xpath=.//${xpath1}/${xpath_rsrq}


Update SCF 2bands T22
    [Documentation]    [PRIVATE]    update SCF 2bands for t22
    ...        AB_Interworking_with_MFBI_during_incoming_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for AB_Interworking_with_MFBI_during_incoming_Xn_handover test
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB008127_2bands_common.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect                               true
    Update Single Nrbts Parameter   actMultiFrequencyBandIndicatorNRSupport   true
    Add NrConnectModeProfileDN To 2bands Nrcell Nrhoif
    Recreate 2bands NRREDRT
    FOR   ${profile_id}    ${FreqBandIndicator}      IN
    ...   1                77
    ...   2                90
       Create NRCONNECTMODE PROFILE     profile_id=${profile_id}    FreqBandIndicator=${FreqBandIndicator}
    END
    Add List MeasPrMaSAList To NRCELL-2
    Update 2bands NRMEASPR MA SA-5 And NRMEASPR MA SA-7
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t22.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t22.xml


Update SCF 2bands T23
    [Documentation]    [PRIVATE]    update SCF 2bands for t23
    ...        PX_SA_Distribution_of_mapping_selection_and_measurement_profile_usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part t23

    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB008127_2bands_common.xml
    Set Suite Variable    ${scf_xml}

    Log To Console    remove in all cells object "NRPLMNSET_NSA-1"
    FOR   ${cell_id}   IN   1   2   3  4
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    FOR   ${param}   IN
    ...   actNrAutSgnbAddCplSlCellDetRec
    ...   actNrAutUeCtxStpRtSlCellDetRec
    ...   actNrAutDegAdmCtrlSlCellDetRec
       Log To Console    set parameter ${param} to false
       Set Element Text   ${scf_xml}    text=false      xpath=.//p[@name="${param}"]
    END
    Log To Console    \nset actSib1ForNsaCell and actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actSib1ForNsaCell"]
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actDynUlDataSplitMode"]

    FOR   ${param}                             ${value}  IN
    ...    actInterRatHoFromEutraToSA          true
    ...    actInterRatHoSA                     true
    ...    actInterFreqHoSA                    true
    ...    actRedirect                         true
    ...    nonContentRachAcFullConfigHo        false
    ...    actInterMeNBMobility                false
    ...    actIntraMeNBMobility                false
    ...    actMobilityRetryToSecondBestCell    false
    ...    actMultiDrbNSA                      false
        Update Single Nrbts Parameter   ${param}   ${value}
    END

    FOR   ${obj}   IN
    ...   NRADJECELL
    ...   NRADJGNB-2
    ...   NRRELE
    ...   NRHOIR
    ...   NRMEASPR_IRF
    ...   XNLINK-2
       Run Keyword   Create ${obj}
    END

    Recreate 2bands NRREDRT

    Add List NrhoirDNList To NRCELL-1
    Update 2bands A1MeashoPrefNRLayerSsb A1ThresholdhoSsb In NRMEASPR IAF

    FOR   ${NRMEASPR_MA_SA_id}  IN  1   2   3   4   5   6   7  8
       ${add_IRF}  Set Variable   <p name="nrMeasPrIrfDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-${NRMEASPR_MA_SA_id}</p>
       ${xpath}    Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${NRMEASPR_MA_SA_id}"]
       Add Element    ${scf_xml}    ${add_IRF}   xpath=.//${xpath}
    END

    Log To Console    set NRCELL-1 parameter "a1MeashoPrefNRLayerEnabledSA" to value "rsrp"
    Set Element Text   ${scf_xml}    text=rsrp
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="a1MeashoPrefNRLayerEnabledSA"]

    FOR   ${cell_id}   IN   1   2   3   4
       Set Element Text   ${scf_xml}    text=SA       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/p[@name="cellDepType"]
       Log To Console    set NRCELL-${cell_id} parameter "cellDepType" to value "SA"
    END

    FOR   ${cell_id}   IN   3   4
       ${xpath}  Set Variable   list[@name="a4PeriodicMeasControlSA"]/item/p[@name="a4Fr1SupervisionTimer"]
       Set Element Text   ${scf_xml}    text=10000    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/${xpath}
       Log To Console    set NRCELL-${cell_id}, list a4PeriodicMeasControlSA, parameter "a4Fr1SupervisionTimer" to value "10000"
    END

    FOR   ${NRMEASPR_MA_SA_id}   IN   3   4
       Log To Console    remove element ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${NRMEASPR_MA_SA_id}
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${NRMEASPR_MA_SA_id}"]
    END
    Recreate NRMEASPR MA SA-3 And NRMEASPR MA SA-4
    Create NRMEASPR IEF

    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t23.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t23.xml
