*** Settings ***
Documentation   This is a keyword file for CB008127, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008127-commissioning-objects.robot
Resource        CB008127-commissioning-lists.robot
Resource        CB008127-commissioning-parameter.robot

*** Variables ***

${measurement_period_in_min}     5


*** Keywords ***

Activate SCF And Bring Tl OnAir ${tc}
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS Services
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_CB008127_${tc}.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_CB008127_${tc}.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_CB008127_${tc}.xml finished
    Run Keyword And Ignore Error    connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}
    Check All Radio Units Online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL To On Air Status Without Reboot
    Log To Console    save final scf ${resultDir}/SCF_final_${tc}.xml
    Get Scf Coam   ${resultDir}    SCF_final_${tc}.xml


Update SCF File For TC CB008127 Common Part
    [Documentation]    [PRIVATE]    update SCF for common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF common part
    Remove Nrcell Parameters And Objects NRMOPR SA-1 TRACKINGAREA-200
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start_after_remove.xml
    Set Suite Variable    ${scf_xml}

    FOR   ${param}   ${value}  IN
    ...    actInterFreqHoSA                    true
    ...    actIntraFreqHoSA                    true
    ...    actIpThpt                           true
    ...    actMeasurementProfile               SA
    ...    actNrpmqapProfiles                  true
    ...    drbInactivityTimerSA                7200
    ...    thpTimeCalc                         enabled
    ...    actPucchF3BasedTaGrantsRed          false
    ...    actNormVCFallback                   false
    ...    actSliceAwareScheduler              false
    ...    actSliceAwareSchedulerUlAndEnh      false
        Update Single Nrbts Parameter   ${param}   ${value}
    END

    Log To Console    update list actVoiceFallbackDuringHOPrep to disabled
    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  Catenate  SEPARATOR=\n
    ...   <list name="actVoiceFallbackDuringHOPrep">
    ...   <p>disabled</p>
    ...   </list>
    Add Element  ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}"]

    FOR   ${object}      ${param}                       IN
    ...   /NRCELL-1      actEnhDtxOptimizedScheduler
    ...   /NRCELL-2      actEnhDtxOptimizedScheduler
    ...   /NRCELL-3      actEnhDtxOptimizedScheduler
    ...   /NRCELL-4      actEnhDtxOptimizedScheduler
      Log To Console    set in NRBTS-1${object} param ${param} to value "false"
      Set Element Text   ${scf_xml}    text=false       xpath=.//managedObject[@distName="${bts_distName}${object}"]/p[@name="${param}"]
    END

    Update Single Nrcell-1 Parameter   param=cbraPreamblesPerSsb   value=n40

    Add TNgRelocExecDeltL TimerXnDataFwdGuard To Mrbts Object
    Add Parameters To All Nrcell Objects
    Add Parameter A2MeasReleaseEnabled To Nrcell-1

    FOR    ${object}   IN
    ...    NRADJGNB
    ...    NRADJNRCELL
    ...    NRHOIF
    ...    NRREL
    ...    NRMEAS_PROFILE
    ...    NRMEASPR_IAF
    ...    NRMEASPR_MA_SA
    ...    NRPLMN
    ...    SNSSAI
    ...    XNLINK
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

    FOR    ${list}    IN
    ...    a1MeashoSsbRsrpSA
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
       Update Single Nrcell-1 Parameter   ${param}    ${value}
       Update Single Nrcell-2 Parameter   ${param}    ${value}
    END

    FOR   ${nrcell_id}   ${list}                   ${param}                     ${value}    IN
    ...   1              a1MeashoSsbRsrp           a1ThresholdhoSsbRsrp         104
    ...   1              a1MeashoSsbRsrq           a1ThresholdhoSsbRsrq         104
    ...   1              a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp   92
    ...   2              a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp   25
    ...   1              a2MeasRedirectSsbRsrq     a2ThresholdRedirectSsbRsrq   92
    ...   1              a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp         100
    ...   1              a2MeashoSsbRsrq           a2ThresholdhoSsbRsrq         100
    ...   1              a2MeasReleaseSsbRsrp      a2ThresholdReleaseSsbRsrp    88
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

    Save Xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB008127_common.xml
    Log To Console    \nsave updated SCF common part ${resultBaseDir}/SCFC_CB008127_common.xml


Update SCF T1
    [Documentation]    [PRIVATE]    update SCF for t1
    ...        AB_Configuration_of_A2_A3_A5_intraFreq_measurements_with_measurement_profiles_during_context_setup
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for measurement profile test
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB008127_common.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect           false
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t1.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t1.xml


Update SCF T2
    [Documentation]    [PRIVATE]    update SCF for t2
    ...        AB_Redirection_based_on_A2_measurements_upon_selected_measurement_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for redirect test
    Remove NRREDRT-0    scf_file_in=${resultBaseDir}/SCFC_CB008127_common.xml      scf_file_out=${resultDir}/SCFC_CB008127_t2.xml
    ${scf_xml}    Parse Xml    ${resultDir}/SCFC_CB008127_t2.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect           true
    Recreate NRREDRT
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t2.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t2.xml


Update SCF T3
    [Documentation]    [PRIVATE]    update SCF for t3
    ...        AB_Interworking_with_mobility_profiles_during_context_setup
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for mobility profiles test
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB008127_common.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect                  false
    Update Single Nrbts Parameter   actMobilityProfile           true
    Add Parameters To All Nrcell Objects T3
    Update Add Parameters Nrcell-3 And Nrcell-4
    Create NRMEASCFG IF
    Create NRMOPRMA NSA
    Create NRMOPRMA SA
    Create NRMOPR NSA
    Create NRMOPR SA
    Create Single NRHOIF    nrcell_id=3
    Create Single NRHOIF    nrcell_id=4
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t3.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t3.xml


Update SCF T4
    [Documentation]    [PRIVATE]    update SCF for t4
    ...        AB_Configuration_of_intraFreq_measurements_A2_A3_A5_using_selected_measurement_profile_during_RRC_Resume
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for RRC resume test
    Remove NRREDRT-0    scf_file_in=${resultBaseDir}/SCFC_CB008127_common.xml      scf_file_out=${resultDir}/SCFC_CB008127_t4.xml
    ${scf_xml}    Parse Xml    ${resultDir}/SCFC_CB008127_t4.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   srbInactivityTimerSA         60
    Update Single Nrbts Parameter   actRedirect                  true
    Recreate NRREDRT
    Add Parameters To Nrbts Object T4
    Add Parameters To NRPLMNSET SA-1 T4
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t4.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t4.xml


Update SCF T7
    [Documentation]    [PRIVATE]    update SCF for t7
    ...        AB_Configuration_of_A2_A3_A5_intraFreq_measurements_during_Xn_HO_using_measurement_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for XN HO measurement profile test
    Remove NRREDRT-0    scf_file_in=${resultBaseDir}/SCFC_CB008127_common.xml      scf_file_out=${resultDir}/SCFC_CB008127_t7.xml
    ${scf_xml}    Parse Xml    ${resultDir}/SCFC_CB008127_t7.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect           true
    Recreate NRREDRT
    Update NRCELL-1 Parameters T7
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t7.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t7.xml


Update SCF T8
    [Documentation]    [PRIVATE]    update SCF for t8
    ...        AB_Configuration_of_A2_A3_A5_intraFreq_measurements_during_NG_HO_using_measurement_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for NG HO measurement profile test
    Remove NRREDRT-0    scf_file_in=${resultBaseDir}/SCFC_CB008127_common.xml      scf_file_out=${resultDir}/SCFC_CB008127_t8.xml
    ${scf_xml}    Parse Xml    ${resultDir}/SCFC_CB008127_t8.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect           true
    Recreate NRREDRT
    Update NRCELL-1 Parameters T8
    Update Add MRBTS Parameter T8 T9
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t8.xml
    Remove Parameter T8 T9    scf_file=${resultDir}/SCFC_CB008127_t8.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t8.xml


Update SCF T10
    [Documentation]    [PRIVATE]    update SCF for t3
    ...        AB_Interworking_with_mobility_profiles_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for mobility profiles XN handover test
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB008127_common.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect                  false
    Update Single Nrbts Parameter   actMobilityProfile           true
    Add Parameters To All Nrcell Objects T3
    Update Add Parameters Nrcell-3 And Nrcell-4
    Create NRMEASCFG IF
    Create NRMOPRMA NSA
    Create NRMOPRMA SA
    Create NRMOPR NSA
    Create NRMOPR SA
    Create Single NRHOIF    nrcell_id=3
    Create Single NRHOIF    nrcell_id=4
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t10.xml
    scf.Load Scf    ${resultDir}/SCFC_CB008127_t10.xml
    Log To Console    remove list "a1MeashoSsbRsrq" from object "${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-8"
    scf.Remove List From Scf       dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-8        list_name=a1MeashoSsbRsrq
    Log To Console    remove list "a2MeashoSsbRsrq" from object "${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-8"
    scf.Remove List From Scf       dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-8        list_name=a2MeashoSsbRsrq
    scf.Save Scf    ${resultDir}/SCFC_CB008127_t10.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t10.xml


Update SCF T15
    [Documentation]    [PRIVATE]    update SCF for t15
    ...        AB_RRC_Re_Establishment_during_Xn_HO_with_measurement_profiles
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for XN HO measurement profile test
    Remove NRREDRT-0    scf_file_in=${resultBaseDir}/SCFC_CB008127_common.xml      scf_file_out=${resultDir}/SCFC_CB008127_t15.xml
    ${scf_xml}    Parse Xml    ${resultDir}/SCFC_CB008127_t15.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect                       true
    Update Single Nrbts Parameter   actInterGnbRREPreparedCell        true
    Update Single Nrbts Parameter   rrcReestabTypeSA                  sameGNB
    Recreate NRREDRT
    Update NRCELL-1 Parameters T7
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t15.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t15.xml


Update SCF T20
    [Documentation]    [PRIVATE]    update SCF for t20
    ...        AB_Measurement_profile_selection_without_freqBandIndicatorNR
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for measurement profile test
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_CB008127_common.xml
    Set Suite Variable    ${scf_xml}
    Update Single Nrbts Parameter   actRedirect           false
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t20.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t20.xml


Update SCF T21
    [Documentation]    [PRIVATE]    update SCF for t21
    ...        AB_Interworking_with_MFBI_during_ICS_and_after_RRC_Reestablishment
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdated SCF common part for interworking with MFBI test
    Remove NRREDRT-0    scf_file_in=${resultBaseDir}/SCFC_CB008127_common.xml      scf_file_out=${resultDir}/SCFC_CB008127_t21.xml
    ${scf_xml}    Parse Xml    ${resultDir}/SCFC_CB008127_t21.xml
    Set Suite Variable    ${scf_xml}
    Update Nrbts Params ActRedirect ActMultiFrequencyBandIndicatorNRSupport RrcReestabTypeSA
    Add NrConnectModeProfileDN To Nrcell-1 Nrcell-2 Nrhoif-1
    Create NRCONNECTMODE PROFILE
    Add List MeasPrMaSAList To NRCELL-2
    Update NRMEASPR MA SA-2
    Update Single Nrcell-2 Parameter    param=a2MeasRedirectEnabled   value=rsrp
    Recreate NRREDRT
    Save Xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_t21.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_t21.xml


Delta Commissioning To Remove FreqBandIndicatorNR From NRMEASPR MA SA-2
    [Documentation]    [PRIVATE]    delta commissioning to remove freqBandIndicatorNR from NRMEASPR_MA_SA-2
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning NRMEASPR_MA_SA-2
    Log To Console    remove freqBandIndicatorNR
    Log To Console    change uePowerClass to ue-PowerClass1
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/delta_remove_freqBandIndicator_78.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}
    Log To Console    delta commissioning finished
    Get Scf Coam    ${resultDir}    SCFC_CB008127_t20_1_remove_freqBandInd.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_CB008127_t20_1_remove_freqBandInd.xml

Delta Commissioning Switching Priorities In NRCELL-1 MeasPrMaSAList
    [Documentation]    [PRIVATE]    delta commissioning switching priorities in NRCELL-1 measPrMaSAList
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning switching priorities in NRCELL-1 measPrMaSAList started
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_t20_2.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/CB008127-scf_update_t20_2.xml    ${delta_SCF_update}
    Execute Delta Commissioning    delta_scf_template=${resultDir}/CB008127-scf_update_t20_2.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning switching priorities in NRCELL-1 measPrMaSAList finished
    Get Scf Coam    ${resultDir}    SCFC_CB008127_t20_2.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_CB008127_t20_2.xml
