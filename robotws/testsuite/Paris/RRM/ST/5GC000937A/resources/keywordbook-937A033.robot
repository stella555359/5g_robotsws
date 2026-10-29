*** Settings ***
Documentation
...      todo:clean


*** Keywords ***
Update gnb parameter values with full commissioning coam source gnb for 937A033
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
#          modify the 4 following parameters dciXXX in the entire SCF so for the 3 BWP_PROFILE-X :
    ...    modify:${nrbts_dn}:dciDedicatedAggregationLevel=AL8
    ...    modify:${nrbts_dn}:dciRaCompletionAggregationLevel=AL8
    ...    modify:${nrbts_dn}:dciRaMsg2AggregationLevel=AL8
    ...    modify:${nrbts_dn}:dciSiAggregationLevel=AL8
#          modify parameter numOfPdcchCandidatesInAL8=n2 in the entire SCF so for the 3 BWP_PROFILE-X
#          in PDCCH_CONFIG_COMMON-1 and and in PDCCH_CONFIG_DEDICATED-1 :
    ...    modify:${nrbts_dn}:numOfPdcchCandidatesInAL8=n2
#          modify tddFrameStructure :
    ...    modify:${nrcell_dn}:frameStructureType=${frameStructureType_src[1]}
    ...    modify:${nrcell_dn}:guardPeriodLength=${guardPeriodLength_src[1]}
    ...    add:${nrcell_dn}:tddFrameStructure:lteToNrFrameShift=${lteToNrFrameShift_src[1]}
    ...    add:${nrcell_dn}:tddFrameStructure:tdLteUlDlConfig=${tdLteUlDlConfig_src[1]}
    ...    modify:${nrcell_dn}:ulDlDataSlotRatio=${ulDlDataSlotRatio_src[1]}
    ...    modify:${nrcell_dn}:prachConfigurationIndex=${prachConfigurationIndex_src[1]}
#          modify measurement interval parameters
    ...    modify:${gnb_${gnb_id}_pmcadm_distName}:reportingIntervalPm=${measurement_period_in_min}min
    ...    modify:${nrbts_dn}/NRPMRNL-1:miNrRRCC=${measurement_period_in_min}min
    ...    modify:${nrbts_dn}/NRPMRNL-1:miNrPdcch=${measurement_period_in_min}min

    load_scf   ${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml
    perform_scf_modification   ${param_list}
    save_scf   ${resultBaseDir}/SCFC_updated_gnb_${gnb_id}.xml
    restore SCF coam ext02    gnb_id=${gnb_id}    scf=SCFC_updated_gnb_${gnb_id}.xml


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

