*** Settings ***
Documentation    Scenario specific keywords for CB008847
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.scf                                 WITH NAME    scf
Library    taf.transport.ssh                              WITH NAME    ssh
Library    taf.sbts.oam.coam.admin                        WITH NAME    admin
Library    taf.config.wts                                 WITH NAME    wts
Library    ../../L2/libraries/template_functions.py       WITH NAME    template
Library    ../libraries/vendor_file_modifier.py           WITH NAME    vendor_file_modifier
Resource   ../../../resources/Common/wts_ue.robot
Resource   ../../../resources/Common/commissioning.robot

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***

Update Basic Configuration File
    wts.Load Wts Cfg    /opt/iphy/latest/basic_setup.cfg
    wts.insert      cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-69,-34,14,48    after    uec_param id=1
    wts.insert      cell_testmode_set_nr cell_id=all gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts.Save Wts Cfg    /opt/iphy/latest/basic_setup.cfg


Run Feature specific keywords before attach
    ${ue_ids_configured}=    Get UE Ids configured for scenario    ${scenario_name}
    Log to Console  Activating UE based SRS testmode
    wts_ue.Send Egate Command And Verify Output    cmd=ue_srs_beam_pos_nr profile_id=1 init_pos=0 srsMode=fixed
    # Print configuration in egate log
    wts_ue.Send Egate Command And Verify Output    cmd=ue_srs_beam_pos_nr profile_id=1
    FOR  ${ue_id}  IN  ${ue_ids_configured}
        Send Egate Command and verify output    cmd=ue_testmode_set_nr id=${ue_id} testmode=ue_srs_beam_pos action=activate profile_id=1
    END


Run Feature specific keywords after attach before traffic is started
    RETURN


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    IF  'LOCK' in '${SUITE_NAME}'  Lock a Cell and Collect TTI Trace
    ${starttime_traffic}=  DateTime.Get Current Date  UTC
    Log To Console  Traffic started at ${starttime_traffic} UTC
    Log To Console  Traffic duration: ${traffic_duration} seconds


Run Feature specific keywords after traffic before detach
    IF  'LOCK' in '${SUITE_NAME}'  Unlock a Cell

    ${attached_ue_list}=    template.Get_Ue_Ids_Configured_For_Scenario    scenario_name=${scenario_name}
    Sort List  ${attached_ue_list}
    Set Test Variable    ${attached_ue_list}
    ${string_attached_ue_list}=    Catenate    SEPARATOR=,    @{attached_ue_list}
    Set Test Variable    ${string_attached_ue_list}
    Log To Console    Attached UE's: ${string_attached_ue_list}
    wts_ue.Send Egate Command And Verify Output    ue_stats_nr id=${string_attached_ue_list} type=pdsch,pusch scell=0-5 delay=60000
    Log To Console    ue_stats_nr id=${string_attached_ue_list} type=pdsch,pusch scell=0-5 delay=60000

    TRY
        Display Traffic Data Rate
    EXCEPT    AS    ${error}
        LOG  Error in "Display Traffic Data Rate": ${error}  level=ERROR  console=yes
    END


 Display Traffic Data Rate
     ${bearer_stats_attribs_nsa}  ${_} =  template.Get_Bearer_Stat_Params  scenario_name=${scenario_name}
     ${tp}=  wts_ue.Get Bearer Stats From Egate
     ...  ue_id=${bearer_stats_attribs_nsa["ues"]}  trf_id=${bearer_stats_attribs_nsa["trf_ids"]}
     ...  id=${bearer_stats_attribs_nsa["bearers"]}
     Log To Console    Current DL throughput for all NSA UEs is ${tp} bps
     ${_}  ${bearer_stats_attribs_sa}=  template.Get_Bearer_Stat_Params  scenario_name=${scenario_name}
     ${tp}=  wts_ue.Get Bearer Stats From Egate
     ...  ue_id=${bearer_stats_attribs_sa["ues"]}  trf_id=${bearer_stats_attribs_sa["trf_ids"]}  pdu=${bearer_stats_attribs_sa["pdus"]}
     ...  qfi=${bearer_stats_attribs_sa["qfis"]}
     Log To Console    Current DL throughput for all SA UEs is ${tp} bps


Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}
    Log    The following Keywords were Run: ${scenario_specific_keywords}

Run Feature specific keywords after detach
    RETURN
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Make necessary changes to SCF
    scf.load_scf    ${original_gnb_scf}
    Enable Scheduled UE Pooling for TDD
    Enable Dynamic PDCCH Configuration
    Enable VoNR
    Enable Periodic SRS
    Change reporting interval  interval_duration=${pm_reporting_interval}
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    @{8847_rd_params}=  create list  0x420068=2
    Update SW Config file on System Module  param_list=${8847_rd_params}
    commissioning.Execute Full Commissioning  scf_path=${configuration_directory}/SCF_updated.xml  skip_relation_errors=False


Enable Scheduled UE Pooling for TDD
    #  Create objects and Elements:
    Log  Enabling Scheduled UE Pooling  console=yes
    ${distName_NRBTS}=        Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=        Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    #enable TDD ue pooling activation flag
    Set Element    dist_name=${distName_NRBTS[0]}       p_name=actBbPoolTddFr1                 value=true
    Set Element    dist_name=${distName_NRBTS[0]}       p_name=actBbPoolTddFr1AlgEnh           value=true
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        Set Element    dist_name=${dist_name}      p_name=actIncreasedFdmUsersPerSlot     value=true
        Set Element    dist_name=${dist_name}      p_name=maxNumPdschAllocationPerSlot    value=16
        Set Element    dist_name=${dist_name}      p_name=maxNumPuschAllocationPerSlot    value=16
        Set Element    dist_name=${dist_name}      p_name=actShortBsrLimitAdaptation      value=true
    END
    Log  Parameters for Scheduled UE Pooling changed successfully  console=yes

Enable VoNR
    Log  Enabling VoNR  console=yes
    ${distName_NRCELL}=    Get distNames from gNB DU    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        scf.modify scf element    dist_name=${dist_name}    p_name=actVoNR    value=true
    END

Enable Periodic SRS
    Log  Enabling Periodic SRS  console=yes
    ${distName_NRBTS}=             Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=            Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_NRCELLGRP}=         Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELLGRP-[0-9]+
    ${distName_NRSYSINFO_PROF}=    Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRSYSINFO_PROFILE-[0-9]+
    Set Element    dist_name=${distName_NRBTS[0]}             p_name=actBeamControlImprovement1     value=true
    Set Element    dist_name=${distName_NRBTS[0]}             p_name=actBeamControlImprovement2     value=true
    Set Element    dist_name=${distName_NRBTS[0]}             p_name=actFdmEnhancedScheduling       value=true
    Set Element    dist_name=${distName_NRSYSINFO_PROF[0]}    p_name=systemInformationTargetRate    value=0
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        Set Element    dist_name=${dist_name}      p_name=actBeamforming                  value=true
        Set Element    dist_name=${dist_name}      p_name=actIncreasedFdmUsersPerSlot     value=true
        Set Element    dist_name=${dist_name}      p_name=actUlSrsBm                      value=true
        Set Element    dist_name=${dist_name}      p_name=mMimoAntArrayMode               value=Bottom 32TRX Array (2x8x2)
        Set Element    dist_name=${dist_name}      p_name=numberOfRxBeamforming           value=4Rx
        scf.modify_scf_element    dist_name=${dist_name}    list_name=fPdcchMonOccsnPo    value=2

        ${list_name}=    Set Variable    beamSet
        ${beamSet_elements}=    Create dictionary
        ...                     basicBeamSet             beamSet_4
        ...                     leftEdgeAngle            60
        ...                     lowerEdgeAngle           135
        ...                     nrBtsBeamRefinementP2    false
        ...                     rightEdgeAngle           60
        ...                     upperEdgeAngle           80
        ${list_exist}=          scf.is_list_in_object    dist_name=${dist_name}    list_name=${list_name}
        IF     ${list_exist}    scf.remove_list_from_scf    dist_name=${dist_name}    list_name=${list_name}
        scf.add_list_to_scf     dist_name=${dist_name}    list_name=${list_name}
        scf.add_item_to_list    dist_name=${dist_name}    list_name=${list_name}    elements=${beamSet_elements}

        ${list_name}=    Set Variable    srsForBeamMgmt
        ${srsForBeamMgt_elements}=    Create dictionary
        ...                           bSRS                          2
        ...                           comb                          comb2
        ...                           cSRS                          63
        ...                           srsTypeAllocForDlBm           antenna switching or codebook
        ...                           srsUePeriodicity              slots20
        ...                           srsPowerThresholdForUlBm      -1320           #Default value in 25R3
        ...                           srsDlBeamFallbackOption       fallback once   #Default value in 25R3
        ...                           srsUlBeamFallbackOption       fallback once   #Default value in 25R3
        ${list_exist}=          scf.is_list_in_object    dist_name=${dist_name}    list_name=${list_name}
        IF     ${list_exist}    scf.remove_list_from_scf    dist_name=${dist_name}    list_name=${list_name}
        scf.add_list_to_scf     dist_name=${dist_name}    list_name=${list_name}
        scf.add_item_to_list    dist_name=${dist_name}    list_name=${list_name}    elements=${srsForBeamMgt_elements}
    END
    FOR  ${dist_name}  IN  @{distName_NRCELLGRP}
        Set Element    dist_name=${dist_name}      p_name=numberOfTransmittedSsBlocks     value=4 beams
    END

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Enable Dynamic PDCCH Configuration
    Log  Enabling Dynamic PDCCH Configuration  console=yes
    ${distName_PDCCH}=    Set Variable    MRBTS-1/NRBTS-1/BWP_PROFILE-44/PDCCH-1
    Set Element    dist_name=${distName_PDCCH}    p_name=alSelection    value=dynamic
    ${list_name}=    Set Variable    dynamicAggregationLevelSet
    ${dynamicAggregationLevelSet_elements}=    Create dictionary
    ...                                        aggregationLevelList    AL2_AL4
    ...                                        cqiCorrectionUp         8
    ...                                        cqiDciCssAl1            101
    ...                                        cqiDciCssAl16           0
    ...                                        cqiDciCssAl2            69
    ...                                        cqiDciCssAl4            33
    ...                                        cqiDciCssAl8            10
    ...                                        highOlcCqiOffset        100
    ...                                        lowOlcCqiOffset         100
    ...                                        pCqiErasureActTimer     160
    ...                                        pCqiErasureReduction    1
    ${list_exist}=          scf.is_list_in_object    dist_name=${distName_PDCCH}    list_name=${list_name}
    IF     ${list_exist}    scf.remove_list_from_scf    dist_name=${distName_PDCCH}    list_name=${list_name}
    scf.add_list_to_scf     dist_name=${distName_PDCCH}    list_name=${list_name}
    scf.add_item_to_list    dist_name=${distName_PDCCH}    list_name=${list_name}    elements=${dynamicAggregationLevelSet_elements}

    ${distName_PDCCH_dedicated}=    Set Variable    MRBTS-1/NRBTS-1/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ${list_name}=    Set Variable    coresetDedicated
    ${coresetDedicated_elements}=    Create dictionary
    ...                              cceToRegMapping    nonInterleaved
    ...                              coresetId          1
    ...                              cRbStart           0
    ...                              duration           1
    ...                              interleaverSize    none
    ...                              regBundleSize      n6
    ...                              size               192
    ${list_exist}=          scf.is_list_in_object    dist_name=${distName_PDCCH_dedicated}    list_name=${list_name}
    IF     ${list_exist}    scf.remove_list_from_scf    dist_name=${distName_PDCCH_dedicated}    list_name=${list_name}
    scf.add_list_to_scf     dist_name=${distName_PDCCH_dedicated}    list_name=${list_name}
    scf.add_item_to_list    dist_name=${distName_PDCCH_dedicated}    list_name=${list_name}    elements=${coresetDedicated_elements}

    ${list_name}=    Set Variable    searchSpaceDedicated
    ${searchSpaceDedicated_elements_item1}=    Create dictionary
    ...                                        coresetId                     0
    ...                                        dciFormat                     formats0-0-And-1-0
    ...                                        duration                      1
    ...                                        monitoringSymbolWithinSlot    symbol_0_1
    ...                                        numOfPdcchCandidatesInAL1     n0
    ...                                        numOfPdcchCandidatesInAL16    n0
    ...                                        numOfPdcchCandidatesInAL2     n0
    ...                                        numOfPdcchCandidatesInAL4     n2
    ...                                        numOfPdcchCandidatesInAL8     n0
    ...                                        periodicity                   sl1
    ...                                        searchSpaceId                 7
    ...                                        searchSpaceType               Type3
    ...                                        slotOffset                    0
    ${searchSpaceDedicated_elements_item2}=    Create dictionary
    ...                                        coresetId                     1
    ...                                        dciFormat                     formats0-1-And-1-1
    ...                                        duration                      1
    ...                                        monitoringSymbolWithinSlot    symbol_0_1
    ...                                        numOfPdcchCandidatesInAL1     n0
    ...                                        numOfPdcchCandidatesInAL16    n0
    ...                                        numOfPdcchCandidatesInAL2     n4
    ...                                        numOfPdcchCandidatesInAL4     n3
    ...                                        numOfPdcchCandidatesInAL8     n0
    ...                                        periodicity                   sl1
    ...                                        searchSpaceId                 8
    ...                                        searchSpaceType               UE-Specific
    ...                                        slotOffset                    0

    ${list_exist}=          scf.is_list_in_object     dist_name=${distName_PDCCH_dedicated}    list_name=${list_name}
    IF     ${list_exist}    scf.remove_list_from_scf    dist_name=${distName_PDCCH_dedicated}    list_name=${list_name}
    scf.add_list_to_scf     dist_name=${distName_PDCCH_dedicated}    list_name=${list_name}
    scf.add_item_to_list    dist_name=${distName_PDCCH_dedicated}    list_name=${list_name}    elements=${searchSpaceDedicated_elements_item1}
    scf.add_item_to_list    dist_name=${distName_PDCCH_dedicated}    list_name=${list_name}    elements=${searchSpaceDedicated_elements_item2}

    Log  Parameters for Dynamic PDCCH Configuration added successfully  console=yes

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Download and Modify Vendor File and perform commissioning
    ${oam_alias}=    connect.Setup OAM http session
    #configuration_directory is a suite variable defined in common_keywords.robot
    ${vendor_path}=    Set Variable    ${configuration_directory}/vendor_lte.xml
    admin.download_vendor_file    target_file_name=${vendor_path}    connection=${oam_alias}
    Backup Vendor File  file_path=${vendor_path}
    Modify bbPoolMode in Vendor File to round-robin
    admin.set_vendor_file  vendor_file=${vendor_path}  connection=${oam_alias}
    admin.perform_commissioning  scf_file=${configuration_directory}/SCF_updated.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=True  timeout=600
    connect.Teardown OAM http session

Download and Modify Vendor File and perform commissioning for Minimum Test Case
    ${oam_alias}=    connect.Setup OAM http session
    #configuration_directory is a suite variable defined in common_keywords.robot
    ${vendor_path}=    Set Variable    ${configuration_directory}/vendor_lte.xml
    admin.download_vendor_file    target_file_name=${vendor_path}    connection=${oam_alias}
    Backup Vendor File  file_path=${vendor_path}
    IF    '-D' in '${SUITE_NAME}'
        Modify bbPoolMode in Vendor File to round-robin
        Modify bbPoolMinResource    50
        Modify Vendor File for Minimum Test Case    round-robin
    ELSE
        Modify bbPoolMinResource    60
        Modify Vendor File for Minimum Test Case    load-metric
    END
    admin.set_vendor_file  vendor_file=${vendor_path}  connection=${oam_alias}
    admin.perform_commissioning  scf_file=${configuration_directory}/SCF_updated.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=True  timeout=600
    connect.Teardown OAM http session

Backup Vendor File
    [Arguments]  ${file_path}
    Copy File	${file_path}  ${file_path}.bkp

Modify bbPoolMode in Vendor File to round-robin
    ${filter_criteria}=    Create Dictionary
    ...  bbPoolMode=load-metric
    ${data_to_be_modified}=    Create Dictionary
    ...  bbPoolMode=round-robin
    ${path_to_xml}=  vendor_file_modifier.get_xml_path_for_bbPoolMode
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  xml_path=${path_to_xml}

Modify Vendor File for Minimum Test Case
    [Arguments]   ${algorithm}=round-robin
    ${common_unit_type}=    Get Common Unit Type
    ${capacity_unit_type}=    Get Capacity Unit Type
    ${hw_variant}=    set variable if  '${common_unit_type}'=='ASOE'     ${common_unit_type}     ${capacity_unit_type}
    ${filter_criteria}=    Create Dictionary
    ...  bbHwVariant=${hw_variant}
    ...  confDuplexMode=TDD
    IF    '${algorithm}'=='load-metric'
        ${data_to_be_modified}=   Create Dictionary
                                  ...  maxNumScheUePdschL1Pool=12
                                  ...  maxNumScheUePdschL1Sp=7
                                  ...  maxNumScheUePuschL1Pool=12
                                  ...  maxNumScheUePuschL1Sp=7
    ELSE
        ${data_to_be_modified}=   Create Dictionary
                                  ...  maxNumScheUePdschL1Pool=9
                                  ...  maxNumScheUePdschL1Sp=5
                                  ...  maxNumScheUePuschL1Pool=9
                                  ...  maxNumScheUePuschL1Sp=5
    END
    ${path_to_xml}=  vendor_file_modifier.get_xml_path_for_list  listname=bbPoolCapacity
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  xml_path=${path_to_xml}

Modify bbPoolMinResource
    [Arguments]    ${bbPoolMinResource}=50
    ${filter_criteria}=    Create Dictionary
    ...  bbPoolMinResource=10
    ${data_to_be_modified}=    Create Dictionary
    ...  bbPoolMinResource=${bbPoolMinResource}
    ${path_to_xml}=  vendor_file_modifier.get_xml_path_for_bbPoolMinResource
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  xml_path=${path_to_xml}

Get Average Date Rate
    FOR  ${ue_id}  IN RANGE  101   ${total_number_of_ues_nsa}+${101}
       ${data_rate_dl}=    wts_ue.Get Average Data Rate via Egate    ue_id=${ue_id}    id=2    dir=dl    trf_id=1
       log to console  UE${ue_id} dl traffic data rate is ${data_rate_dl}
       ${data_rate_ul}=    wts_ue.Get Average Data Rate via Egate    ue_id=${ue_id}    id=2    dir=ul    trf_id=1
       log to console  UE${ue_id} ul traffic data rate is ${data_rate_ul}
    END
    FOR  ${ue_id}  IN RANGE  1   ${total_number_of_ues_sa}+${1}
       ${data_rate_dl}=    wts_ue.Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=1    qfi=1
       log to console  UE${ue_id} dl traffic data rate is ${data_rate_dl}
       ${data_rate_ul}=    wts_ue.Get Average Data Rate via Egate    ue_id=${ue_id}    dir=ul    trf_id=1    pdu=1    qfi=1
       log to console  UE${ue_id} ul traffic data rate is ${data_rate_ul}
    END

Lock a Cell and Collect TTI Trace
    [Arguments]    ${gnb_id}=0    ${port}=3600    ${alias}=cOAM
    [Documentation]  Unlocks RMOD 3 which is mapped to cell 3 in the SCF configuration.
    ...    Also collects tti traces after Locking the cell.
    ${distName_RMOD}=    Get distNames from gNB DU  regex=MRBTS-[0-9]+/EQM-[0-9]+/APEQM-[0-9]+/RMOD-[3]
    admin.connect to    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  bts_port=${port}  name=${alias}
    admin.lock    dist_name=${distName_RMOD}  timeout=60  connection=${alias}
    admin.teardown    connection=${alias}
    Sleep  15s  reason=wait lock cell procedure to finish
    ${tti_trace_collector}=    ttitrace.Create collectors and Start Generation of TTI Trace
    ...  tti_trace_filename=ttitrace_streaming_cell_lock  bts_type=classical  nr_phy_cell_ids=50,51  dest_ip=10.0.1.1
    Sleep  2s  reason=collect enough tti trace data for analysis
    ttitrace.Stop TTI Trace generation    ${tti_trace_collector}
    ttitrace.Collect TTI Trace and teardown collectors  desired_file_name=ttitrace_streaming_cell_lock
    ...  desired_storage_directory=${ts_log_dir}/tti_trace_cell_lock

Unlock a Cell
    [Arguments]    ${gnb_id}=0    ${port}=3600    ${alias}=cOAM
    [Documentation]  Unlocks RMOD 3 which is mapped to cell 3 in the SCF configuration.
    ${distName_RMOD}=    Get distNames from gNB DU  regex=MRBTS-[0-9]+/EQM-[0-9]+/APEQM-[0-9]+/RMOD-[3]
    admin.connect to    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  bts_port=${port}  name=${alias}
    admin.unlock    dist_name=${distName_RMOD}  timeout=60  connection=${alias}
    admin.teardown    connection=${alias}
    Sleep  10s  reason=wait unlock cell procedure to finish
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Change reporting interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=  Get distNames from gNB SCF  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrCellAvailability
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrCellUtilization
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrTimingAdvance
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrUlSignalQuality
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrUlHarq
    ${distName_PMCADM}=  Get distNames from gNB SCF  regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm
