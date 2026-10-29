*** Settings ***
Documentation   This is a keyword file for CB008699, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008699-commissioning_objects_lists.robot
Resource        CB008699-commissioning_parameter.robot

*** Variables ***
${measurement_period_in_min}     5

*** Keywords ***

Set Sw Release Version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   Split String    ${gnb_swVersion}    _
    Set Suite Variable    ${RELEASE}   ${gnb_sw_version_parts}[0]



Activate SCF And Bring TL onAir ${tc}
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_CB8699_${tc}.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_CB8699_${tc}.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_CB8699_${tc}.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Log To Console    save final scf ${resultDir}/SCF_final_${tc}.xml
    get scf coam   ${resultDir}    SCF_final_${tc}.xml


Update SCF file for TC CB008699 common part
    [Documentation]    [PRIVATE]    update SCF for common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF common part
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    FOR   ${param}   ${value}  IN
    ...    actInterFreqHoSA                    true
    ...    actInterRatHoFromEutraToSA          true
    ...    actIntraFreqHoSA                    true
    ...    actIpThpt                           true
    ...    actNrpmqapProfiles                  true
    ...    thpTimeCalc                         enabled
    ...    actPucchF3BasedTaGrantsRed          false
        update single nrbts parameter   ${param}   ${value}
    END

    Set Sw Release Version
    IF    '${RELEASE}'=='SBTS25R2' or '${RELEASE}'=='SBTS25R3'   Create NRPMQAP_25R   ELSE   Create NRPMQAP

    Create NRADJGNB
    Create NRADJNRCELL
    Create NRHOIF

    Create XNLINK
    Add List a3MeasSsbRsrp

    FOR    ${param}                    ${value}  IN
    ...    a3MeasEnabled               rsrp
    ...    cbraPreamblesPerSsb         n40
       update single nrcell-1 parameter   ${param}   ${value}
    END

    FOR   ${param}                  ${value}  IN
    ...    miNrPDCPCell             ${measurement_period_in_min}min
    ...    miNrPdcpCellNrpmqap      ${measurement_period_in_min}min
    ...    miNrRelReportCu          ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END

    add nonContentRachAcFullConfigHo tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    add measGapSelectionSA absThreshSsbRsrpConsolidation sMeasConfigSsbRsrp to nrcell-1

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB8699_common.xml
    Log To Console    \nsave updated SCF common part ${resultBaseDir}/SCFC_CB8699_common.xml


Update SCF t1_t5
    [Documentation]    [PRIVATE]    update SCF for Source_DRB_to_QoS_flow_mapping_missing_at_target_gNB_during_Xn_handove
    ...                             update SCF for CNI_96896_Data_Forwarding_Info_is_missing_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nsave updated SCF common part, parameters actFullRRCConfigurationSaHo, nonContentRachAcFullConfigHo
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB8699_common.xml
    set suite variable    ${scf_xml}
    update single nrbts parameter   actFullRRCConfigurationSaHo           disabled
    update single nrbts parameter   nonContentRachAcFullConfigHo          true
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB8699_t1_t5.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB8699_t1_t5.xml


Update SCF t2_t3
    [Documentation]    [PRIVATE]    update SCF for Unknown_RRC_extension_detected_by_target_gNB_during_Xn_handover
    ...                             update SCF for Unknown_critical_RRC_extension_detected_by_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_CB8699_common.xml
    set suite variable    ${scf_xml}
    update single nrbts parameter   actFullRRCConfigurationSaHo           enabled
    update single nrbts parameter   nonContentRachAcFullConfigHo          false
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB8699_t2_t3.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB8699_t2_t3.xml


Update SCF t4
    [Documentation]    [PRIVATE]    update SCF for Source_DRB_to_QoS_flow_mapping_not_supported_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    remove nrbts parameter nonContentRachAcFullConfigHo

    ${scf_xml}    parse xml    ${resultDir}/SCFC_CB8699_after_remove.xml
    set suite variable    ${scf_xml}
    update single nrbts parameter   actFullRRCConfigurationSaHo           DrbToQosMappingOnly
    update single nrbts parameter   actInterRatHoFromEutraToSA            false
    Create NRADJNRCELL-2
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB8699_t4.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB8699_t4.xml


Update SCF t6
    [Documentation]    [PRIVATE]    update SCF for CB008699_Force_full_RRC_configuration_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    remove nrbts parameter nonContentRachAcFullConfigHo

    ${scf_xml}    parse xml    ${resultDir}/SCFC_CB8699_after_remove.xml
    set suite variable    ${scf_xml}
    update single nrbts parameter   actFullRRCConfigurationSaHo           enabled
    update single nrbts parameter   actForceFullRRCConfigurationSaHo      disabled
    update single nrbts parameter   actInterRatHoFromEutraToSA            false
    Create NRADJNRCELL-2
    Save xml     ${scf_xml}    ${resultDir}/SCFC_CB8699_t6.xml
    Log To Console    \nsave SCF in ${resultDir}/SCFC_CB8699_t6.xml
