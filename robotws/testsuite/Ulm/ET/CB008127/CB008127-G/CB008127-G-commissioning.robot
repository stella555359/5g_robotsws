*** Settings ***
Documentation   This is a keyword file for CB008127-G, part commissioning
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

Resource        CB008127-G-commissioning-objects.robot
Resource        CB008127-G-commissioning-lists.robot
Resource        CB008127-G-commissioning-parameter.robot
Library         taf.config.scf                  WITH NAME    scf

*** Variables ***

${measurement_period_in_min}     5


*** Keywords ***

activate SCF and bring tl onAir ${tc}
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Shruthi Shivaprasad
    Kill WTS services
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_CB008127_G_${tc}.xml started
    admin.perform commissioning
    ...    scf_file=${resultDir}/SCFC_CB008127_G_${tc}.xml
    ...    skip_parameter_relation_errors=True
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_CB008127_G_${tc}.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Log To Console    save final scf ${resultDir}/SCF_final_G_${tc}.xml
    get scf coam   ${resultDir}    SCF_final_G_${tc}.xml


Update SCF file for TC CB008127-G common part
    [Documentation]    [PRIVATE]    update SCF for common part
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \nstart update SCF common part
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    FOR   ${param}   ${value}  IN
    ...    actA2SgnbRelease                    true
    ...    actInterFreqInterGnbMobilityNSA                    true
    ...    actInterFreqIntraGnbMobilityNSA                    true
    ...    actIntraFreqIntraGnbMobilityNSA                    true
    ...    actIntraMeNBMobility                    true
    ...    actMeasurementProfile               SA+NSA
        update single nrbts parameter   ${param}   ${value}
    END

    FOR   ${param}                  ${value}  IN
    ...    a1MeashoEnabled          rsrp
    ...    a2MeashoEnabled          rsrp
    ...    a3MeasEnabled            rsrp
    ...    a5MeasEnabled            rsrp
       update single nrcell-1 parameter     param=${param}   value=${value}
       update single nrcell-2 parameter     param=${param}   value=${value}
    END

    update single nrcell-1 parameter   param=gscnOrSsPbchArfcn   value=7845
    update single nrcell-1 parameter   param=nrarfcn             value=633364
    add parameters to nrcell-1 and nrcell-2 objects
    add parameter a2MeasReleaseEnabled to nrcell-3 and nrcell-4

    FOR    ${list}    IN
    #...    a2MeasReleaseSsbRsrp
    ...    a2MeasReleaseSsbRsrq
    ...    a3MeasSsbRsrp
    ...    a3MeasSsbRsrq
    ...    a5MeasSsbRsrp
    ...    a5MeasSsbRsrq
        run keyword     Add List ${list}
    END

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

    Create NRPLMN-2
    add parameter values in NRCELL object

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB008127_G_common.xml
    Log To Console    \nsave updated SCF common part ${resultBaseDir}/SCFC_CB008127_G_common.xml


Update SCF t1
    [Documentation]    [PRIVATE]    update SCF for t1
    ...        G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_PLMN
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \nupdated SCF for measurement profile test t1
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB008127_G_common.xml
    set suite variable    ${scf_xml}
    Add List nrMeasPrIefList
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_G_t1.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_G_t1.xml

delta commissioning to modify PLMN-2 in NRMEASPR_MA_NSA-1 t1
    [Documentation]    [PRIVATE]    delta commissioning to add PLMN-2 in NRMEASPR_MA_NSA-1
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \ndelta commissioning NRMEASPR_MA_NSA-1
    Log To Console    modify NRMEASPR_MA_NSA-1
    Log To Console    change plmnlist to PLMN-2
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_t1.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/CB008127-scf_update_t1.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/CB008127-scf_update_t1.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter actMeasurementProfile finished
    get scf coam    ${resultDir}    SCFC_CB008127_t1.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_CB008127_t1.xml

delta commissioning to set to rsrpCombined t4
    [Documentation]    [PRIVATE]    delta commissioning to set to rsrpcombined
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \ndelta commissioning t4
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_t4.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/CB008127-scf_update_t4.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/CB008127-scf_update_t4.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter to set to rsrpCombined
    get scf coam    ${resultDir}    SCFC_CB008127_t4.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_CB008127_t4.xml


delta commissioning to set to srb3 t4
    [Documentation]    [PRIVATE]    delta commissioning to set srb3 support
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \ndelta commissioning t4
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_srb3_t4.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/CB008127-scf_update_srb3_t4.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/CB008127-scf_update_srb3_t4.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter to srb3 support
    get scf coam    ${resultDir}    SCFC_CB008127_srb3_t4.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_CB008127_t4.xml

Update SCF t2
    [Documentation]    [PRIVATE]    update SCF for t2
    ...        G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_PLMN_SPID
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \nupdated SCF common part for PLMN_SPID testcase
    set suite variable    ${scf_xml}
    scf.load_scf    ${resultBaseDir}/SCFC_CB008127_G_common.xml
    scf.remove_mo_with_descendant_mos        dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1
    scf.remove_mo_with_descendant_mos        dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3
    scf.save_scf    ${resultDir}/SCFC_CB008127_G_plmn_t2.xml
    Log To Console    \n PLMN object removed from NRMEAS profile
    ${scf_xml}    parse xml    ${resultDir}/SCFC_CB008127_G_plmn_t2.xml
    set suite variable    ${scf_xml}
    update single nrbts parameter   param=actSPID                         value=true
    Add spid in NRMEASPR_MA_NSA-1
    Add spid in NRMEASPR_MA_NSA-3
    Add List nrMeasPrIefList
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_G_t2.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_G_t2.xml


Update SCF t3
    [Documentation]    [PRIVATE]    update SCF for t3
    ...        G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_SPID
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \nupdated SCF common part for SPID testcase
    set suite variable    ${scf_xml}
    scf.load_scf    ${resultBaseDir}/SCFC_CB008127_G_common.xml
    scf.remove_mo_with_descendant_mos        dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1
    scf.remove_mo_with_descendant_mos        dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3
    scf.save_scf    ${resultDir}/SCFC_CB008127_G_spid_t3.xml
    Log To Console    \n PLMN object removed from NRMEAS profile
    ${scf_xml}    parse xml    ${resultDir}/SCFC_CB008127_G_spid_t3.xml
    set suite variable    ${scf_xml}
    update single nrbts parameter   param=actSPID                         value=true
    Remove plmn in NRMEASPR_MA_NSA-1
    Remove plmn in NRMEASPR_MA_NSA-3
    Add List nrMeasPrIefList
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_G_t3.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_G_t3.xml


Update SCF t4
    [Documentation]    [PRIVATE]    update SCF for t4
    ...        G_Reselection_of measurement_profile_based_upon_mutiple_creiterions_during_measurement_reconfiguration
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \nupdated SCF common part for US 4 testcase
    set suite variable    ${scf_xml}
    scf.load_scf    ${resultBaseDir}/SCFC_CB008127_G_common.xml
    scf.remove_mo_with_descendant_mos        dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3
    scf.save_scf    ${resultDir}/SCFC_CB008127_G_spid_t4.xml
    Log To Console    \n PLMN object removed from NRMEAS profile
    ${scf_xml}    parse xml    ${resultDir}/SCFC_CB008127_G_spid_t4.xml
    set suite variable    ${scf_xml}
    update single nrbts parameter   param=actSPID                         value=true
    Add all 3 parameters in NRMEASPR_MA_NSA-3
    Add List nrMeasPrIefList t4
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_G_t4.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_G_t4.xml


Update SCF t5
    [Documentation]    [PRIVATE]    update SCF for t5
    ...        G_Reselection_of measurement_profile_based_upon_mutiple_creiterions_during_measurement_reconfiguration_mobility_profile
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \nupdated SCF common part for US 4 alternate testcase
    set suite variable    ${scf_xml}
    scf.load_scf    ${resultBaseDir}/SCFC_CB008127_G_common.xml
    scf.remove_mo_with_descendant_mos        dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3
    scf.save_scf    ${resultDir}/SCFC_CB008127_G_spid_t5.xml
    Log To Console    \n PLMN object removed from NRMEAS profile
    ${scf_xml}    parse xml    ${resultDir}/SCFC_CB008127_G_spid_t5.xml
    set suite variable    ${scf_xml}
    update single nrbts parameter   param=actSPID                         value=true
    update single nrbts parameter   param=actMobilityProfile                         value=true
    update single nrcell-1 parameter   param=a1MeashoEnabled   value=rsrq
    update single nrcell-1 parameter   param=a2MeashoEnabled   value=rsrq
    update single nrcell-1 parameter   param=a3MeasEnabled   value=rsrq
    update single nrcell-1 parameter   param=a5MeasEnabled   value=rsrq
    Add all 3 parameters in NRMEASPR_MA_NSA-3
    Add List nrMeasPrIefList t4
    FOR   ${object}   IN
    ...   NRMEASCFG_IF
    ...   NRMOPRMA_NSA
    ...   NRMOPR_NSA-1 and NRMOPR_NSA-32
    ...   NRMOPRMA_SA
       run keyword   Create ${object}
    END
    add nrDefMoPrNsaDN
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB008127_G_t5.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB008127_G_t5.xml
