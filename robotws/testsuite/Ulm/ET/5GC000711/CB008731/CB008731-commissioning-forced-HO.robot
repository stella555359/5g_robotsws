*** Settings ***
Documentation   This is a keyword file for CB008731_force_HO, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008731-commissioning_objects.robot
Resource        CB008731-commissioning_lists.robot
Resource        CB008731-commissioning_parameter.robot

*** Variables ***

${measurement_period_in_min}     5


*** Keywords ***



Update SCF file for TCCB008731 force HO
    [Documentation]    [PRIVATE]    Update SCF file for TCCB008731 force HO
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF force HO
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    Log To Console    remove parameter "nrDefMoPrSaDN" in all cells
    FOR   ${cell_id}   IN   1   2   3  4
       remove element   ${scf_xml}    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/p[@name="nrDefMoPrSaDN"]
       remove element   ${scf_xml}    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END
    FOR   ${object}   IN
    ...   NRMOPR_SA-1
    ...   TRACKINGAREA-200
    ...   NRCELL-1/NRREDRT-0
       Log To Console    remove element "${bts_distName}/${object}"
       remove element   ${scf_xml}    xpath=.//managedObject[@distName="${bts_distName}/${object}"]
    END

    FOR   ${param}   ${value}  IN
    ...    actRatResetEnhancement              true
    ...    actA1HoPrefNRLayer                  SA
    ...    actHigherPrioFreqHo                 SA
    ...    actInterFreqHoSA                    true
    ...    actInterRatHoFromEutraToSA          true
    ...    actInterRatHoSA                     true
    ...    actIntraFreqHoSA                    true
    ...    actIpThpt                           true
    ...    actMultiFrequencyBandIndicatorNRSupport    true
    ...    actNrpmqapProfiles                  true
    ...    actPucchF3BasedTaGrantsRed          false
    ...    actMeasurementProfile               SA
    ...    actRedirect                         true
    ...    thpTimeCalc                         enabled
    ...    actMultiDrbNSA                      false
        update single nrbts parameter   ${param}   ${value}
    END

    FOR   ${param}    IN
    ...   <p name\="nonContentRachAcFullConfigHo">false</p>
    ...   <p name\="tNgRelocExecDeltL">5000</p>
    ...   <p name="timerXnDataFwdGuard">250</p>
       Log To Console    add parameter "${param}" to "${bts_distName}"
       Add Element       ${scf_xml}     ${param}   xpath=.//managedObject[@distName="${bts_distName}"]
    END


    FOR    ${object}   IN
    ...    NRADJECELL
    ...    NRADJGNB force_HO
    ...    NRADJNRCELL force_HO
    ...    NRHOIF NRCELL-1 force_HO
    ...    NRHOIF NRCELL-2 force_HO
    ...    NRREDRT
    ...    NRREL force_HO
    ...    NRRELE
    ...    NRCONNECTMODE_PROFILE
    ...    NRHOIR force_HO
    ...    NRMEAS_PROFILE
    ...    NRMEASPR_IAF
    ...    NRMEASPR_IEF
    ...    NRMEASPR_IRF
    ...    NRMEASPR_MA_SA
    ...    NRPLMN
    ...    NRPMQAP
    ...    SNSSAI
    ...    TRACKINGAREA
    ...    XNLINK force_HO
        run keyword     Create ${object}
    END

    FOR   ${param}                  ${value}  IN
    ...    a1MeashoEnabled          rsrp
    ...    a1MeashoEnabledSA        rsrp
    ...    a2MeasRedirectEnabled    rsrpCombined
    ...    a2MeashoEnabled          rsrp
    ...    a2MeashoEnabledSA        rsrp
    ...    a3MeasEnabled            rsrp
    ...    a5MeasEnabled            rsrp
    ...    actEnhancedVoNR          true
    ...    actVoNR                  true
    ...    measGapSelection         balancedChoice
       Log To Console    set NRCELL-1 parameter "${param}" to value "${value}"
       Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]
       Log To Console    set NRCELL-2 parameter "${param}" to value "${value}"
       Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="${param}"]
    END

    FOR   ${NRCELL_ID}    ${value}   IN
    ...   1               n40
    ...   2               n64
       Log To Console    set NRCELL-${NRCELL_ID} parameter "${param}" to value "${value}"
       Set Element Text  ${scf_xml}  text=${value}
       ...  xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_ID}"]/p[@name="cbraPreamblesPerSsb"]
    END

    Add Element   ${scf_xml}   <p name="a2MeasReleaseEnabled">rsrp</p>   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]

    FOR    ${NRCELL_id}    ${param}                          ${value}   IN
    ...    1               a1MeashoPrefNRLayerEnabledSA      rsrp
    ...    2               chBw                              80MHz
    ...    2               freqBandIndicatorNR               41
    ...    2               gscnOrSsPbchArfcn                 6351
    ...    2               nrarfcn                           508020
       Set Element Text   ${scf_xml}    text=${value}    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]/p[@name="${param}"]
    END

    add a4MeasHigherPrioFreqMaxReactSA to NRCELL
    add absThreshSsbRsrpConsolidation absThreshSsbRsrqConsolidation to NRCELL
    add measGapSelectionSA mgta sMeasConfigSsbRsrp to NRCELL

    FOR    ${list}     IN
    ...    a2MeasReleaseSsbRsrp
    ...    a2MeasReleaseSsbRsrq
    ...    a3MeasSsbRsrp force_HO
    ...    a4PeriodicMeasControlSA
    ...    a5MeasSsbRsrp
    ...    a5MeasSsbRsrq
    ...    measPrMaSAList
    ...    nrhoirDNList
       run keyword   Create List ${list}
    END

   FOR    ${list}                        ${param}               ${value}   ${NRCELL_id}   IN
   ...    a1MeashoPrefNRLayerSsbRsrpSA   a1ThresholdhoSsbRsrp   108        1
   ...    a1MeashoPrefNRLayerSsbRsrpSA   a1ThresholdhoSsbRsrp   108        2
   ...    a1MeashoPrefNRLayerSsbRsrqSA   a1ThresholdhoSsbRsrq   108        1
   ...    a1MeashoPrefNRLayerSsbRsrqSA   a1ThresholdhoSsbRsrq   108        2
      run keyword   Create List ${list}   ${param}=${value}    NRCELL_id=${NRCELL_id}
   END

   FOR   ${list}             ${param1}                ${value1}   ${param2}                  ${value2}   ${NRCELL_id}   IN
   ...   a1MeashoSsbRsrpSA   a1ThresholdhoSsbRsrpSA   104         a1ThresholdHoSsbRsrpVoNr   100         1
   ...   a1MeashoSsbRsrpSA   a1ThresholdhoSsbRsrpSA   104         a1ThresholdHoSsbRsrpVoNr   100         2
   ...   a1MeashoSsbRsrpSA   a1ThresholdhoSsbRsrpSA   104         a1ThresholdHoSsbRsrpVoNr   100         3
   ...   a1MeashoSsbRsrpSA   a1ThresholdhoSsbRsrpSA   104         a1ThresholdHoSsbRsrpVoNr   100         4
   ...   a1MeashoSsbRsrqSA   a1ThresholdhoSsbRsrqSA   104         a1ThresholdHoSsbRsrqVoNr   100         1
   ...   a1MeashoSsbRsrqSA   a1ThresholdhoSsbRsrqSA   104         a1ThresholdHoSsbRsrqVoNr   100         2
   ...   a1MeashoSsbRsrqSA   a1ThresholdhoSsbRsrqSA   104         a1ThresholdHoSsbRsrqVoNr   100         3
   ...   a1MeashoSsbRsrqSA   a1ThresholdhoSsbRsrqSA   104         a1ThresholdHoSsbRsrqVoNr   100         4
   ...   a2MeashoSsbRsrpSA   a2ThresholdhoSsbRsrpSA   100         a2ThresholdHoSsbRsrpVoNr   96          1
   ...   a2MeashoSsbRsrpSA   a2ThresholdhoSsbRsrpSA   100         a2ThresholdHoSsbRsrpVoNr   96          2
   ...   a2MeashoSsbRsrpSA   a2ThresholdhoSsbRsrpSA   100         a2ThresholdHoSsbRsrpVoNr   96          3
   ...   a2MeashoSsbRsrpSA   a2ThresholdhoSsbRsrpSA   100         a2ThresholdHoSsbRsrpVoNr   96          4
   ...   a2MeashoSsbRsrqSA   a2ThresholdhoSsbRsrqSA   100         a2ThresholdHoSsbRsrqVoNr   96          1
   ...   a2MeashoSsbRsrqSA   a2ThresholdhoSsbRsrqSA   100         a2ThresholdHoSsbRsrqVoNr   96          2
   ...   a2MeashoSsbRsrqSA   a2ThresholdhoSsbRsrqSA   100         a2ThresholdHoSsbRsrqVoNr   96          3
   ...   a2MeashoSsbRsrqSA   a2ThresholdhoSsbRsrqSA   100         a2ThresholdHoSsbRsrqVoNr   96          4
   ...   a5MeasSsbRsrp       a5Threshold1SsbRsrp      52          a5Threshold2SsbRsrp        54          2
       run keyword    Create List ${list}   ${param1}=${value1}   ${param2}=${value2}    NRCELL_id=${NRCELL_id}
   END

    FOR   ${list}                 ${param}                     ${value}   IN
    ...   a1MeashoSsbRsrp         a1ThresholdhoSsbRsrp         104
    ...   a1MeashoSsbRsrq         a1ThresholdhoSsbRsrq         104
    ...   a2MeasRedirectSsbRsrp   a2ThresholdRedirectSsbRsrp   92
    ...   a2MeasRedirectSsbRsrq   a2ThresholdRedirectSsbRsrq   92
    ...   a2MeashoSsbRsrp         a2ThresholdhoSsbRsrp         100
    ...   a2MeashoSsbRsrq         a2ThresholdhoSsbRsrq         100
       ${list_path}  set variable   list[@name="${list}"]/item/p[@name="${param}"]
       Log To Console   ${bts_distName}/NRCELL-1"]/${list_path} set ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/${list_path}
    END

    ${list_path}  set variable   list[@name="a2MeasRedirectSsbRsrp"]/item/p[@name="a2ThresholdRedirectSsbRsrp"]
    Log To Console   ${bts_distName}/NRCELL-2"]/${list_path} set a2ThresholdRedirectSsbRsrp to 25
    Set Element Text   ${scf_xml}    text=25   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/${list_path}


    FOR   ${cell_id}   IN   1   2   3   4
       Set Element Text   ${scf_xml}    text=SA       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]/p[@name="cellDepType"]
       Log To Console    set NRCELL-${cell_id} parameter "cellDepType" to value "SA"
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


    FOR   ${param}                     ${value}  IN
    ...    miNrMeasProfileInterFreq    ${measurement_period_in_min}min
    ...    miNrMeasProfileInterRat     ${measurement_period_in_min}min
    ...    miNrMeasProfileIntraFreq    ${measurement_period_in_min}min
    ...    miNrMeasProfileMappingSA    ${measurement_period_in_min}min
    ...    miNrMobilityReport          ${measurement_period_in_min}min
    ...    miNrRelReportCu             ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB8731_force_HO.xml
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB8731_force_HO.xml


activate SCF and bring tl onAir force HO
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/SCFC_CB8731_force_HO.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/SCFC_CB8731_force_HO.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_CB8731_force_HO.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot, SA only
    Bring Airphone TL to on Air status without reboot    force_cu_type=SA
    Log To Console    save final scf ${resultDir}/SCF_final_force_HO.xml
    get scf coam   ${resultDir}    SCF_final_force_HO.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


set actForceHoInsuffUeCap to true
    [Documentation]    [PRIVATE]    set actForceHoInsuffUeCap to true delta commissioning
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning actForceHoInsuffUeCap is set to true
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    admin.perform delta recommissioning
    ...    ${CURDIR}/delta_actForceHoInsuffUeCap.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    Log To Console    delta commissioning finished


save last SCF
    [Documentation]    [PRIVATE]    save last SCF
    ...       :Autor: Sylvia Schneider
    get scf coam    ${resultDir}    SCFC_CB008731_actForceHoInsuffUeCap.xml
    Log To Console    last SCF saved ${resultDir}/SCFC_CB008731_actForceHoInsuffUeCap.xml
