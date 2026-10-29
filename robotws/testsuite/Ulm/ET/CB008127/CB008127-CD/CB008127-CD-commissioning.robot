*** Settings ***
Documentation   This is a keyword file for CB008127-CD, part commissioning
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008127-CD-commissioning-objects.robot
Resource        CB008127-CD-commissioning-lists.robot
Resource        CB008127-CD-commissioning-parameter.robot

*** Variables ***

${measurement_period_in_min}     5


*** Keywords ***

set sw release version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   split string    ${gnb_swVersion}    _
    set suite variable    ${release}   ${gnb_sw_version_parts}[0]


activate SCF and bring tl onAir ${tc}
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_CB008127_CD_${tc}.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_CB008127_CD_${tc}.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_CB008127_CD_${tc}.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Log To Console    save final scf ${resultDir}/SCF_final_CD_${tc}.xml
    get scf coam   ${resultDir}    SCF_final_CD_${tc}.xml


Update SCF file for TC CB008127-CD common part
    [Documentation]    [PRIVATE]    update SCF for common part
    ...       :Autor: Sylvia Schneider
    set sw release version
    Log To Console    \nstart update SCF common part
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    FOR   ${param}   ${value}  IN
    ...    actA2SgnbRelease                        true
    ...    actInterFreqInterGnbMobilityNSA         true
    ...    actInterFreqIntraGnbMobilityNSA         true
    ...    actIntraFreqIntraGnbMobilityNSA         true
    ...    actIntraMeNBMobility                    true
    ...    actMeasurementProfile                   SA+NSA
    ...    actRedirect                             false
    ...    actNormVCFallback                       false
    ...    actVoFallBackLteB1MeaBaRedir            false
        update single nrbts parameter   ${param}   ${value}
    END

    Log To Console    update list actVoiceFallbackDuringHOPrep to disabled
    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  Catenate  SEPARATOR=\n
    ...   <list name="actVoiceFallbackDuringHOPrep">
    ...   <p>disabled</p>
    ...   </list>
    Add Element  ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}"]

    Log To Console    NRMOPR_SA-1 set voiceFBMode to disabled
    Set Element Text   ${scf_xml}    text=disabled      xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRMOPR_SA-1"]/p[@name="voiceFBMode"]

    FOR   ${param}                  ${value}  IN
    ...    a1MeashoEnabled          rsrp
    ...    a2MeashoEnabled          rsrp
    ...    a3MeasEnabled            rsrp
    ...    a5MeasEnabled            rsrp
       update single nrcell-1 parameter     param=${param}   value=${value}
       update single nrcell-2 parameter     param=${param}   value=${value}
    END

    update single nrcell-2 parameter   param=gscnOrSsPbchArfcn   value=7995
    update single nrcell-2 parameter   param=nrarfcn             value=647666
    add parameters to nrcell-1 and nrcell-2 objects

    update parameter a2MeasReleaseEnabled nrcell-3 and nrcell-4

    FOR    ${list}    IN
    ...    a2MeasReleaseSsbRsrq
    ...    a3MeasSsbRsrp
    ...    a3MeasSsbRsrq
    ...    a5MeasSsbRsrp
    ...    a5MeasSsbRsrq
        run keyword     Add List ${list}
    END

    update list a2MeasReleaseSsbRsrp

    Add List measPrMaNSAList to NRCELL-1

    FOR    ${object}   IN
    ...    NRADJNRCELL
    ...    NRHOIF_NRCELL-1
    ...    NRREL-1 for NRCELL-1
    ...    NRREL-2
    ...    NRMEAS_PROFILE
    ...    NRMEASPR_IAF
    ...    NRMEASPR_IEF
    ...    NRMEASPR_MA_NSA
        run keyword     Create ${object}
    END

    FOR   ${param}                     ${value}  IN
    ...    miNrMeasProfileInterFreq    ${measurement_period_in_min}min
    ...    miNrMeasProfileIntraFreq    ${measurement_period_in_min}min
    ...    miNrMeasProfileMappingNSA   ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    Log To Console    \nsave updated SCF common part ${resultBaseDir}/SCFC_CB008127_CD_common.xml


Update SCF t1
    [Documentation]    [PRIVATE]    update SCF for t1
    ...        CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_SgNB_addition_using_selected_meas_profile_for_NSA
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for measurement profile test
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    set suite variable    ${scf_xml}
    Add ssbFrequency to NRADJNRCELL-1
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_CD_t1.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_CD_t1.xml


Update SCF t2
    [Documentation]    [PRIVATE]    update SCF for t2
    ...        CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_MeNB_initiated_SgNB_Modification_using_meas_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for MeNB_initiated_SgNB_Modification_using_meas_profile test
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    set suite variable    ${scf_xml}
    update parameters NRCELL t2
    Add ssbFrequency to NRADJNRCELL-1
    add parameters to NRCELL t2
    Add List measPrMaNSAList to NRCELL-2
    Create NRHOIF_NRCELL-2
    Create NRREL-1 for NRCELL-2
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_CD_t2.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_CD_t2.xml


Update SCF t3
    [Documentation]    [PRIVATE]    update SCF for t3
    ...        CD_Configuration_of_A2_measurement_using_measurement_profile_upon_A1_measurement_report
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for A2_measurement_using_measurement_profile_upon_A1_measurement_report test
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    set suite variable    ${scf_xml}
    update parameters NRCELL t2
    Add ssbFrequency to NRADJNRCELL-1
    add parameters to NRCELL t2
    Add List measPrMaNSAList to NRCELL-2
    Create NRHOIF_NRCELL-2
    Create NRREL-1 for NRCELL-2

    FOR   ${param}                  ${value}          IN
    ...    a1MeashoEnabled          rsrpCombined
    ...    a2MeashoEnabled          rsrpCombined
       update single nrcell-1 parameter     param=${param}   value=${value}
    END

    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_CD_t3.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_CD_t3.xml


Update SCF t4
    [Documentation]    [PRIVATE]    update SCF for t4
    ...        CD_Configuration_of_intraFreq_measurements_during_interMeNB_handover_with_PSCell_change_using_meas_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for intraFreq_measurements_during_interMeNB_handover_with_PSCell_change test
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    set suite variable    ${scf_xml}
    update parameters NRCELL t2
    Add ssbFrequency to NRADJNRCELL-1
    add parameters to NRCELL t2
    Add List measPrMaNSAList to NRCELL-2
    Create NRHOIF_NRCELL-2
    Create NRREL-1 for NRCELL-2
    update single nrbts parameter   param=actInterMeNBMobility   value=true
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_CD_t4.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_CD_t4.xml


Update SCF t5
    [Documentation]    [PRIVATE]    update SCF for t5
    ...        CD_Interaction_with_mobility_profiles_and_MFBI_during_PS_cell_change_using_measurement_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for Interaction_with_mobility_profiles_and_MFBI_during_PS_cell_change test
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    set suite variable    ${scf_xml}
    update single nrbts parameter   param=actMobilityProfile                         value=true
    update single nrbts parameter   param=actMultiFrequencyBandIndicatorNRSupport    value=true
    Add ssbFrequency to NRADJNRCELL-1
    add parameters to NRCELL t2
    update measPrMaNSAList for NRCELL      NRCELL-id=1    measPrPriority=6
    Add List measPrMaNSAList to NRCELL-2
    FOR   ${object}   IN
    ...   NRHOIF_NRCELL-2
    ...   NRREL-1 for NRCELL-2
    ...   NRCONNECTMODE_PROFILE
    ...   NRMEASCFG_IF
    ...   NRMOPRMA_NSA
    ...   NRMOPR_NSA-1 and NRMOPR_NSA-32
    ...   NRMOPRMA_SA
    ...   NRMEASPR_MA_NSA-3 with IAF-1
       run keyword   Create ${object}
    END
    add nrConnectModeProfileDN
    add nrDefMoPrNsaDN
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_CD_t5.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_CD_t5.xml


Update SCF t6
    [Documentation]    [PRIVATE]    update SCF for t6
    ...        CD_Interaction_with_MFBI_and_A1_based_traffic_steering_to_preferred_NR_layer_after_SgNB_addition
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for Interaction_with_MFBI_and_A1_based_traffic_steering_to_preferred_NR_layer test
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    set suite variable    ${scf_xml}
    FOR    ${param}                                   ${value}     IN
    ...    actMultiFrequencyBandIndicatorNRSupport    true
    ...    actA1HoPrefNRLayer                         NSA
    ...    actHigherPrioFreqHo                        NSA
       update single nrbts parameter   param=${param}    value=${value}
    END

    FOR   ${object}   IN
    ...   NRHOIF_NRCELL-2
    ...   NRREL-1 for NRCELL-2
    ...   NRCONNECTMODE_PROFILE
    ...   NRMEASPR_IAF-3 t6
    ...   NRMEASPR_MA_NSA-3 with IAF-3
       run keyword   Create ${object}
    END
    update NRHOIF parameters

    update parameters NRCELL t6
    Add ssbFrequency to NRADJNRCELL-1
    add nrConnectModeProfileDN

    ${a4MeasHigherPrioFreqMaxReact}             set variable    <p name="a4MeasHigherPrioFreqMaxReact">1</p>
    Log To Console    add parameter "a4MeasHigherPrioFreqMaxReact" to cell ${bts_distName}/NRCELL-1
    Add Element        ${scf_xml}    ${a4MeasHigherPrioFreqMaxReact}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]

    FOR    ${list}    IN
    ...    a1MeashoPrefNRLayerSsbRsrp
    ...    a1MeashoPrefNRLayerSsbRsrq
    ...    a4PeriodicMeasControlNSA
    ...    a4MeasSsbRsrp
    ...    a4MeasSsbRsrq
    ...    measPrMaNSAList to NRCELL-2
       run keyword      Add List ${list}
    END
    update measPrMaNSAList for NRCELL      NRCELL-id=1    measPrPriority=6
    update measPrMaNSAList for NRCELL      NRCELL-id=2    measPrPriority=6

    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_CD_t6.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_CD_t6.xml


Update SCF t7
    [Documentation]    [PRIVATE]    update SCF for t7
    ...        PX_NSA_Distribution_of_mapping_selection_and_measurement_profile_usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for PX_NSA_Distribution_of_mapping_selection_and_measurement_profile_usage test
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    set suite variable    ${scf_xml}
    update parameters NRCELL t2
    Add ssbFrequency to NRADJNRCELL-1
    add parameters to NRCELL t2
    Add List measPrMaNSAList to NRCELL-2
    Create NRHOIF_NRCELL-2
    Create NRREL-1 for NRCELL-2
    Add List nrMeasPrIefList
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_CD_t7.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_CD_t7.xml


Update SCF t8
    [Documentation]    [PRIVATE]    update SCF for t8
    ...        PX_Measurement_profile_selection_without_freqBandIndicatorNR_for_NSA
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for PX_Measurement_profile_selection_without_freqBandIndicatorNR_for_NSA
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    set suite variable    ${scf_xml}
    Add ssbFrequency to NRADJNRCELL-1
    add parameters to NRCELL t2
    Add List measPrMaNSAList to NRCELL-2
    Create NRHOIF_NRCELL-2
    Create NRREL-1 for NRCELL-2
    Add List nrMeasPrIefList

    update single nrbts parameter   param=actMultiFrequencyBandIndicatorNRSupport    value=true
    add nrConnectModeProfileDN
    FOR   ${object}   IN
    ...   NRCONNECTMODE_PROFILE
    ...   NRMEASPR_IAF-3 t8
    ...   NRMEASPR_IEF-3
       run keyword   Create ${object}
    END
    recreate NRMEASPR_MA_NSA t8
    update measPrMaNSAList for NRCELL      NRCELL-id=1    measPrPriority=9
    update measPrMaNSAList for NRCELL      NRCELL-id=2    measPrPriority=9
    update thresholds NRMEASPR_IEF-2

    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_CD_t8.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_CD_t8.xml


Update SCF t9
    [Documentation]    [PRIVATE]    update SCF for t9
    ...        MN_Measurement_profile_reselection_due_to_frequenz_band_change_during_MeNB_mobility_scenario
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for MN_Measurement_profile_reselection_due_to_frequenz_band_change_during_MeNB_mobility_scenario
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_CD_common.xml
    set suite variable    ${scf_xml}
    Add ssbFrequency to NRADJNRCELL-1
    add parameters to NRCELL t2
    Add List measPrMaNSAList to NRCELL-2
    Create NRHOIF_NRCELL-2
    Create NRREL-1 for NRCELL-2
    Add List nrMeasPrIefList

    FOR    ${param}    IN
    ...    actMultiFrequencyBandIndicatorNRSupport
    ...    actAllowedBcListMrdcPrioBcSel
        update single nrbts parameter   param=${param}    value=true
    END
    add nrConnectModeProfileDN
    FOR   ${object}   IN
    ...   NRCONNECTMODE_PROFILE
    ...   NRMEASPR_IAF-3 t8
    ...   NRMEASPR_IEF-3
       run keyword   Create ${object}
    END
    recreate NRMEASPR_MA_NSA t9
    update measPrMaNSAList for NRCELL      NRCELL-id=1    measPrPriority=9
    update measPrMaNSAList for NRCELL      NRCELL-id=2    measPrPriority=9
    update thresholds NRMEASPR_IEF-2

    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_CD_t9.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_CD_t9.xml


remove freqBandIndicatorNR 78 from pcCapabilityList
    [Documentation]    [PRIVATE]    delta commissioning to remove freqBandIndicatorNR 78 from pcCapabilityList
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning remove freqBandIndicatorNR 78 from NRMEASPR_MA_NSA-1 pcCapabilityList

    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    admin.perform delta recommissioning
    ...    ${CURDIR}/delta_remove_freqBandIndicator_78.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}

    Log To Console    delta commissioning finished
    get scf coam    ${resultDir}    SCFC_CB008127_t8_delta_freqBandIndicatorNR.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_CB008127_t8_delta_freqBandIndicatorNR.xml
