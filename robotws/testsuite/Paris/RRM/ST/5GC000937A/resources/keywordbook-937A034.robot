*** Settings ***
Documentation
...      todo:clean


*** Keywords ***
Update swconfig txt file parameters values
    [Arguments]    ${gnb_id}=0
    SetFlagOnSwConfig ext01      flag=0x58012b      value=${rad_0x58012b_src[1]}    gnb_id=${gnb_id}


Update gnb parameter values with full commissioning coam source gnb for 937A034
    [Arguments]    ${gnb_id}=0
    set test variable   ${nrbts_dn}        ${gnb_${gnb_id}_bts_distName}
    set test variable   ${nrcell_dn}     ${gnb_${gnb_id}_bts_distName}/${source_distName}

    ${param_list}     Create List
#          general parameters
    ...    modify:${nrbts_dn}:srb3SupportEnabled=${srb3SupportEnabled_src[1]}
    ...    modify:${nrbts_dn}:actCarrierAggregation=${actCarrierAggregation_src[1]}
    ...    modify:${nrcell_dn}:cbraPreamblesPerSsb=${cbraPreamblesPerSsb_src[1]}
    ...    modify:${nrcell_dn}:actCDrx=${actCDrx_src[1]}
    ...    modify:${nrcell_dn}:actPowerSavingBWP=${actPowerSavingBWP_src[1]}
#    ...    modify:${nrcell_dn}:actCaWimaxInterferenceAvoidance=${actCaWimaxInterferenceAvoidance_src[1]}
#          modify parameter actCaWimaxInterferenceAvoidance on the 2 NRCELL :
    ...    modify:${nrbts_dn}:actCaWimaxInterferenceAvoidance=${actCaWimaxInterferenceAvoidance_src[1]}
#          modify tddFrameStructure to 1116 3ms on the 2 NRCELL :
    ...    modify:${nrbts_dn}:frameStructureType=${frameStructureType_src[1]}
    ...    modify:${nrbts_dn}:tddFrameStructure:guardPeriodLength=${guardPeriodLength_src[1]}
#    ...    add:${nrbts_dn}:tddFrameStructure:lteToNrFrameShift=${lteToNrFrameShift_src[1]}  # ne fonctionne pas
    ...    add:${nrbts_dn}/NRCELL-1:tddFrameStructure:lteToNrFrameShift=${lteToNrFrameShift_src[1]}
    ...    add:${nrbts_dn}/NRCELL-1:tddFrameStructure:tdLteUlDlConfig=${tdLteUlDlConfig_src[1]}
    ...    add:${nrbts_dn}/NRCELL-2:tddFrameStructure:lteToNrFrameShift=${lteToNrFrameShift_src[1]}
    ...    add:${nrbts_dn}/NRCELL-2:tddFrameStructure:tdLteUlDlConfig=${tdLteUlDlConfig_src[1]}
    ...    modify:${nrbts_dn}:ulDlDataSlotRatio=${ulDlDataSlotRatio_src[1]}
#          modify parameter fPdcchMonOccsnPo on the 2 NRCELL :
#    ...    modify:${nrbts_dn}/NRCELL-1:fPdcchMonOccsnPo:4   ne fonctionne pas
#    ...    modify:${nrbts_dn}/NRCELL-2:fPdcchMonOccsnPo=4
#    ...    modify:${nrcell_dn}:fPdcchMonOccsnPo=4   ne fonctionne pas
#    ...    modify:${nrcell_dn}:fPdcchMonOccsnPoList=4   ne fonctionne pas
    ...    delete:${nrbts_dn}/NRCELL-1:fPdcchMonOccsnPo
    ...    add:${nrbts_dn}/NRCELL-1:fPdcchMonOccsnPo
    ...    add:${nrbts_dn}/NRCELL-1:fPdcchMonOccsnPo::4
    ...    delete:${nrbts_dn}/NRCELL-2:fPdcchMonOccsnPo
    ...    add:${nrbts_dn}/NRCELL-2:fPdcchMonOccsnPo
    ...    add:${nrbts_dn}/NRCELL-2:fPdcchMonOccsnPo::4
#          modify duration and periodicity of item0 with Type0A and item2 with type2 in seachSpacecommon of the 3 BWP
    ...    modify:BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=6|searchSpaceType=Type0A
    ...    modify:BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=6|searchSpaceType=Type2
    ...    modify:BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=6|searchSpaceType=Type0A
    ...    modify:BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=6|searchSpaceType=Type2
    ...    modify:BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=6|searchSpaceType=Type0A
    ...    modify:BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=6|searchSpaceType=Type2
    ...    modify:BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
    ...    modify:BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
    ...    modify:BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
    ...    modify:BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
    ...    modify:BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
    ...    modify:BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
#          modify measurement interval parameters
    ...    modify:${gnb_${gnb_id}_pmcadm_distName}:reportingIntervalPm=${measurement_period_in_min}min
#    ...    modify:${nrbts_dn}/NRPMRNL-1:miNrRRCC=${measurement_period_in_min}min
#    ...    modify:${nrbts_dn}/NRPMRNL-1:miNrPdcch=${measurement_period_in_min}min

    load_scf   ${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml
    perform_scf_modification   ${param_list}
    save_scf   ${resultBaseDir}/SCFC_updated_gnb_${gnb_id}.xml
    keywordbook-937A034.restore SCF coam ext02    gnb_id=${gnb_id}    scf=SCFC_updated_gnb_${gnb_id}.xml



restore SCF coam ext02
    [Documentation]    [PRIVATE] restore SCF on classical gnb
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${scf}: scf file name
    [Arguments]     ${gnb_id}=0   ${scf}=SCFC_start_gnb_0.xml
    builtIn.Log To Console    \nfull commissioning on coam gnb-${gnb_id} started
    admin.connect_to
    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    name=gnb
    admin.perform_commissioning
  # ...   scf_file=${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml
    ...   scf_file=${resultBaseDir}/${scf}
    ...   skip_parameter_relation_errors=True
    ...   should_activate=${TRUE}
    ...   timeout=660
    ...   connection=gnb
    admin.teardown    connection=gnb
    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0
    builtIn.Log To Console    full commissioning on coam gnb-${gnb_id} finished

