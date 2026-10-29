# *** Settings ***
# Documentation
# ...   author: Hu Jiao
# ...   contact: jiao.hu@nokia-sbell.com
# ...   squad group: SG_05
# ...   feature : CB007608_CB006555_CB007200 in 5G22R1
# 
# Force Tags    SBTS00    SBTS22R3    RAN_5G
# ...    PY36
# ...           RAN_5G_TDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_ENB
# Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND     CI_interface.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# Test Setup           robot_common_operations.Common Case Setup 
# Test Teardown        robot_common_operations.Common Case Teardown
# 
# Library     XML    use_lxml=True
# Library     taf.sbts.oam.coam.admin        WITH NAME    coam_admin
# Library    OperatingSystem
# Library    String
# Resource      ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    ../CB007608_A_B/Resources/CB007608_coam_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${dl_port}    ${tl.ues[0].iperf_details.port}
# ${dl_time}    180
# ${dl_throughput}    5M
# ${dl_length}    1024B
# ${ul_time}    60
# ${ul_port}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
# ${ul_throughput}     4M
# ${ul_length}    1024B
# ${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${local_path}    ${OUTPUT DIR}
# ${command_template_with_Y}       {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
# ${tshark_path}      /usr/bin/tshark
# ${SPpath}     .//nr-rrc.commonSearchSpaceList//nr-rrc.SearchSpace_element
# ${SP3path}    .//nr-rrc.searchSpacesToAddModList/*[@show="Item 0"]/nr-rrc.SearchSpace_element
# ${SPUEpath}    .//nr-rrc.searchSpacesToAddModList/*[@show="Item 1"]/nr-rrc.SearchSpace_element
# ${filter_1}       _5g_l1_dl_l2_ps_dldata_pdschsendreq_t
# ${filter_2}       _5g_l1_dl_l2_ps_dldata_pdcchsendreq_t
# 
# ##CB007608_A_CB006555_Migration_rules_for_22R1_verification_config_2_mmW_ASIL_eCPRI
# # check initial BWP locationAndBandwidth
# ${rrc_initial_DL_BWP_RIV}    .//nr-rrc.initialDownlinkBWP_element/nr-rrc.genericParameters_element/nr-rrc.locationAndBandwidth
# 
# 
# ${rrc_initial_UL_BWP_RIV}    .//nr-rrc.initialUplinkBWP_element/nr-rrc.genericParameters_element/nr-rrc.locationAndBandwidth
# 
# # check dedicated BWP locationAndBandwidth
# ${rrc_dedicated_DL_BWP_RIV}   .//nr-rrc.BWP_Downlink_element/nr-rrc.bwp_Common_element/nr-rrc.genericParameters_element/nr-rrc.locationAndBandwidth
# ${rrc_dedicated_UL_BWP_RIV}   .//nr-rrc.BWP_Uplink_element/nr-rrc.bwp_Common_element/nr-rrc.genericParameters_element/nr-rrc.locationAndBandwidth
# 
# #check common search space
# ${rrc_PDCCH_common_searchSpace_type1_1}    ${SPpath}/nr-rrc.controlResourceSetId
# ${rrc_PDCCH_common_searchSpace_type1_2}    ${SPpath}/nr-rrc.searchSpaceType/nr-rrc.common_element/nr-rrc.dci_Format0_0_AndFormat1_0_element
# ${rrc_PDCCH_common_searchSpace_type1_3&4}   ${SPpath}/nr-rrc.monitoringSymbolsWithinSlot
# ${rrc_PDCCH_common_searchSpace_type1_5}   ${SPpath}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel2
# ${rrc_PDCCH_common_searchSpace_type1_6}   ${SPpath}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel4
# ${rrc_PDCCH_common_searchSpace_type1_7}   ${SPpath}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel8
# ${rrc_PDCCH_common_searchSpace_type1_8}   ${SPpath}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel16
# ${rrc_PDCCH_common_searchSpace_type1_9&12}   ${SPpath}/nr-rrc.monitoringSlotPeriodicityAndOffset/nr-rrc.sl1_element
# ${rrc_PDCCH_common_searchSpace_type1_10}    ${SPpath}/nr-rrc.searchSpaceId
# ${rrc_PDCCH_common_searchSpace_type1_11}    .//nr-rrc.pdcch_ConfigCommon/nr-rrc.setup_element/nr-rrc.ra_SearchSpace
# 
# 
# #check dedicated coreset
# ${rrc_PDCCH_Dedicated_coresetDedicated_1}   .//nr-rrc.controlResourceSetToAddModList//nr-rrc.ControlResourceSet_element/nr-rrc.cce_REG_MappingType
# ${rrc_PDCCH_Dedicated_coresetDedicated_2}  .//nr-rrc.controlResourceSetToAddModList//nr-rrc.ControlResourceSet_element/nr-rrc.controlResourceSetId
# ${rrc_PDCCH_Dedicated_coresetDedicated_4}   .//nr-rrc.controlResourceSetToAddModList//nr-rrc.ControlResourceSet_element/nr-rrc.duration
# ${coresetDedicated_7}   .//nr-rrc.controlResourceSetToAddModList//nr-rrc.ControlResourceSet_element/nr-rrc.frequencyDomainResources
# 
# #check dedicated search space type3
# ${rrc_PDCCH_Dedicated_searchSpace_type3_1}    ${SP3path}/nr-rrc.controlResourceSetId
# ${rrc_PDCCH_Dedicated_searchSpace_type3_2}   ${SP3path}/nr-rrc.searchSpaceType/nr-rrc.common_element/nr-rrc.dci_Format0_0_AndFormat1_0_element
# ${rrc_PDCCH_Dedicated_searchSpace_type3_3&4}   ${SP3path}/nr-rrc.monitoringSymbolsWithinSlot
# ${rrc_PDCCH_Dedicated_searchSpace_type3_5}   ${SP3path}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel1
# ${rrc_PDCCH_Dedicated_searchSpace_type3_6}   ${SP3path}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel2
# ${rrc_PDCCH_Dedicated_searchSpace_type3_7}   ${SP3path}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel4
# ${rrc_PDCCH_Dedicated_searchSpace_type3_8}   ${SP3path}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel8
# ${rrc_PDCCH_Dedicated_searchSpace_type3_9}   ${SP3path}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel16
# ${rrc_PDCCH_Dedicated_searchSpace_type3_10&13}   ${SP3path}/nr-rrc.monitoringSlotPeriodicityAndOffset/nr-rrc.sl1_element
# ${rrc_PDCCH_Dedicated_searchSpace_type3_11}    ${SP3path}/nr-rrc.searchSpaceId
# 
# 
# #check dedicated search space UE-specific
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_1}    ${SPUEpath}/nr-rrc.controlResourceSetId
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_2}   ${SPUEpath}/nr-rrc.searchSpaceType/nr-rrc.ue_Specific_element/nr-rrc.dci_Formats
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_3&4}   ${SPUEpath}/nr-rrc.monitoringSymbolsWithinSlot
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_5}   ${SPUEpath}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel1
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_6}   ${SPUEpath}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel2
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_7}   ${SPUEpath}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel4
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_8}   ${SPUEpath}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel8
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_9}   ${SPUEpath}/nr-rrc.nrofCandidates_element/nr-rrc.aggregationLevel16
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_10&13}   ${SPUEpath}/nr-rrc.monitoringSlotPeriodicityAndOffset/nr-rrc.sl1_element
# ${rrc_PDCCH_Dedicated_searchSpace_UE_specific_11}    ${SPUEpath}/nr-rrc.searchSpaceId
# 
# 
# #check dmrsTypeAPosition
# ${dmrsTypeAPosition}    .//nr-rrc.dmrs_TypeA_Position
# 
# #CB007608_CB007200_02_DL_Test_Model_Verification_TM1-1
# ${bip_remote_log_path}    /tmp
# ${bip_remote_log_name}    tcpdump_L2L1_bip_filtering_off.pcap
# 
# 
# &{DICTONARY_PDCCHSENDREQ_IE}                   DlData_PdcchSendReq_t.beamId=0
# ...                                            Offset=8
# ...                                            Length=1
# ...                                            3gpp.rnti=0
# ...                                            DlData_DciInfo.startSymbolNumber=0
# ...                                            DlData_DciInfo.numOfSymbols=2
# ...                                            DlData_DciInfo.startCce=0
# ...                                            DlData_DciInfo.aggregationLevel=1
# ...                                            DlData_DciInfo.dmrsReferencePoint=0
# ...                                            DlData_DciInfo.pdcchPrecodingOption4x4=0
# ...                                            DlData_DciInfo.coresetFreqDomain=9223372036854775808
# ...                                            DlData_DciInfo.cceRegMappingType=1
# ...                                            DlData_DciInfo.nShiftModNumOfRegBundles=0
# ...                                            DlData_DciInfo.interleaverRows=2
# ...                                            DlData_DciInfo.regBundleSize=6
# ...                                            DlData_DciInfo.precoderGranularity=0
# ...                                            DlData_DciInfo.coresetFreqDomainRbShift=0
# ...                                            DlData_DciInfo.dciSize=48
# ...                                            DlData_DciInfo.numCeAxCIndex=2
# ...                                            DlData_DciInfo.polarizationSelection=0
# ...                                            3gpp.dmrsScramblingSequenceInt=93
# ...                                            DlData_DciInfo.patternId_item=200,200
# 
# &{DICTONARY_PDSCHSENDREQ_IE_rnti0}             DlData_PdschGrant.dlDmrsConfigType=1
# ...                                            DlData_PdschGrant.dlDmrsLen=1
# ...                                            DlData_PdschGrant.dlDmrsMappingType=0
# ...                                            DlData_PdschGrant.dlDmrsAddPos=0
# ...                                            DlData_PdschGrant.dlDmrsTypeAPos=2
# ...                                            DlData_PdschGrant.numOfDmrsCdmGroupWithoutData=1
# ...                                            DlData_PdschGrant.nscId=0
# ...                                            DlData_PdschGrant.offsetRbDmrs=0
# ...                                            DlData_PdschGrant.startSymbol=0
# ...                                            DlData_PdschGrant.antPort=32768
# ...                                            DlData_PdschGrant.spatialMode=2
# ...                                            DlData_PdschGrant.codebookIndex=0
# ...                                            DlData_PdschGrant.dlPtrsFlag=1
# ...                                            DlData_PdschGrant.dlPtrsTimeDensity=4
# ...                                            DlData_PdschGrant.dlPtrsFrequencyDensity=2
# ...                                            DlData_PdschGrant.dlPtrsNumOfPorts=1
# ...                                            DlData_PdschGrant.dlPtrsResElemOffset=0
# ...                                            DlData_PdschGrant.rvIndex=0
# ...                                            DlData_PdschGrant.k0divZ=0
# ...                                            DlData_PdschGrant.numOfLayers=1
# ...                                            DlData_PdschGrant.pdschPrecodingOption4x4=0
# #...                                            DlData_PdschGrant.numCeAxCIndex=2
# ...                                            3gpp.dmrsScramblingSequenceInt=93
# ...                                            DlData_PdschGrant.startPrb=3
# ...                                            DlData_PdschGrant.numOfPrb=63
# ...                                            DlData_PdschGrant.modulationOrder=2
# ...                                            3gpp.rnti=0
# 
# &{DICTONARY_PDSCHSENDREQ_IE_rnti2}             DlData_PdschGrant.dlDmrsConfigType=1
# ...                                            DlData_PdschGrant.dlDmrsLen=1
# ...                                            DlData_PdschGrant.dlDmrsMappingType=0
# ...                                            DlData_PdschGrant.dlDmrsAddPos=0
# ...                                            DlData_PdschGrant.dlDmrsTypeAPos=2
# ...                                            DlData_PdschGrant.numOfDmrsCdmGroupWithoutData=1
# ...                                            DlData_PdschGrant.nscId=0
# ...                                            DlData_PdschGrant.offsetRbDmrs=0
# ...                                            DlData_PdschGrant.startSymbol=2
# ...                                            DlData_PdschGrant.antPort=32768
# ...                                            DlData_PdschGrant.spatialMode=2
# ...                                            DlData_PdschGrant.codebookIndex=0
# ...                                            DlData_PdschGrant.dlPtrsFlag=1
# ...                                            DlData_PdschGrant.dlPtrsTimeDensity=4
# ...                                            DlData_PdschGrant.dlPtrsFrequencyDensity=2
# ...                                            DlData_PdschGrant.dlPtrsNumOfPorts=1
# ...                                            DlData_PdschGrant.dlPtrsResElemOffset=0
# ...                                            DlData_PdschGrant.rvIndex=0
# ...                                            DlData_PdschGrant.k0divZ=0
# ...                                            DlData_PdschGrant.numOfLayers=1
# ...                                            DlData_PdschGrant.pdschPrecodingOption4x4=0
# #...                                            DlData_PdschGrant.numCeAxCIndex=2
# ...                                            3gpp.dmrsScramblingSequenceInt=93
# ...                                            DlData_PdschGrant.startPrb=0
# ...                                            DlData_PdschGrant.numOfPrb=3
# ...                                            DlData_PdschGrant.modulationOrder=2
# ...                                            3gpp.rnti=2
# 
# *** Test Cases ***
# 
# [1]CB007608_A_CB006555_Migration_rules_for_22R1_verification_config_2_mmW_ASIL_eCPRI
#     [Documentation]
#     ...    The purpose of this user scenario is to validate dynamic pdcch properly configured in 22R1
#     ...    ******************
#     ...    *******************
# 
#     [Setup]   Precondition: check gNB can be on air
#     [Teardown]    Run Keywords    Tests_Recover_6555
# 
#     Step 1: Collect CPIF log
#     Step 2: Attach UE and Send DL traffic    MCI_value=32374815
#     Step 3: Stop pcap on CPIF and download to testPc
#     Step 4: Stop DL traffic and detach UE
#     Step 5: Verify parameters of dynamic pdcch configured correctly
# 
# [1]CB007403_CB007200_02_DL_Test_Model_Verification_TM1-1
#    [Documentation]
#    ...  This user scenario validates the signal from NR is aligned with the parameters defined for NR-FR2-TM1.1
#    ...  Step1:Selects the RU mode 'NR only RU' and test model=TM1_1 into DL TestModels state
#    ...  Step2:Capture BIP log
#    ...  Step3:Verify the PDCCH and PDSCH characteristics in BIP log are consistent with the parameters defined for NR-FR2-TM1.1
#    ...  Step4:Stop Test Transmitter test model
#    [Setup]   Run Keywords     Precondition: check gNB can be on air   AND   Download MCShark To UTE
#    [Teardown]    Run Keywords    Tests_Recover_7200
# #-----------------------------------------------------------------------
# # Step1:Selects the RU mode 'NR only RU' and test model=TM1_1 into DL TestModels state
# #-----------------------------------------------------------------------
#     log to console     \nStep1:Selects the RU mode 'NR only RU' and test model=TM1_1 into DL TestModels state
#     Activate Test dedicated Mode
#     Check gNB can be on test mode
#     ${beampattern}=  Create List     ${200}    ${200}
#     Start DL Test Transmitter    test_model=TM1_1
#     ...                          ru_mode=NR_Only
#     ...                          pci=93
#     ...                          polarization=P_plus45_or_0
#     ...                          beamPatternId=${beampattern}
#     ...                          power_backoff=0
#     ...                          mimo_rank=1
#     ...                          p_max=20
#     sleep    20s    reason=Wait for successful response from admin
# ##-----------------------------------------------------------------------
# ## Step2-Step3:Capture BIP log
# ## AND
# ## Verify the PDCCH and PDSCH characteristics in BIP log are consistent with the parameters defined for NR-FR2-TM1.1
# ##-----------------------------------------------------------------------
#     Create Directory    /home/ute/BIPlog
#     Start to collect bip log new    nr_phy_cell_ids=74
#     sleep  5s
#     Stop to collect bip log new     target_dir=/home/ute/BIPlog
#     ${bip_files}     Get BIP File List      log_path=/home/ute/BIPlog/l1l2bip    bip_prefix=BTS1976_1011_mirroring_L2L1
#     ${csv_file}    Replace String    ${bip_files}    .pcap    _pdsch.csv
# 
#     @{csv_title_list_1}    Create List    DlData_PdschGrant.dlDmrsConfigType    DlData_PdschGrant.dlDmrsLen
#     ...    DlData_PdschGrant.dlDmrsMappingType   DlData_PdschGrant.dlDmrsAddPos      DlData_PdschGrant.dlDmrsTypeAPos
#     ...    DlData_PdschGrant.numOfDmrsCdmGroupWithoutData    DlData_PdschGrant.nscId
#     ...    DlData_PdschGrant.offsetRbDmrs    DlData_PdschGrant.startSymbol    DlData_PdschGrant.antPort
#     ...    DlData_PdschGrant.spatialMode    DlData_PdschGrant.codebookIndex    DlData_PdschGrant.dlPtrsFlag
#     ...    DlData_PdschGrant.dlPtrsTimeDensity    DlData_PdschGrant.dlPtrsFrequencyDensity
#     ...    DlData_PdschGrant.dlPtrsNumOfPorts    DlData_PdschGrant.dlPtrsResElemOffset    DlData_PdschGrant.rvIndex
#     ...    DlData_PdschGrant.k0divZ    DlData_PdschGrant.numOfLayers    DlData_PdschGrant.pdschPrecodingOption4x4
#     ...    3gpp.dmrsScramblingSequenceInt    DlData_PdschGrant.startPrb
#     ...    DlData_PdschGrant.numOfPrb    DlData_PdschGrant.modulationOrder    3gpp.rnti
# 
#     Convert BIP To CSV By MCShark    bip_file=${bip_files}
#     ...    output_file=${csv_file}    filter=${filter_1}    csv_title_list=${csv_title_list_1}
# 
#     Check_Bip_Sub_Info_By_Special_Item
#     ...    file_path=${csv_file}
#     ...    item=3gpp.rnti
#     ...    item_value=0
#     ...    father_dict=${DICTONARY_PDSCHSENDREQ_IE_rnti0}
# 
#     Check_Bip_Sub_Info_By_Special_Item
#     ...    file_path=${csv_file}
#     ...    item=3gpp.rnti
#     ...    item_value=2
#     ...    father_dict=${DICTONARY_PDSCHSENDREQ_IE_rnti2}
# 
#     @{csv_title_list_2}    Create List    DlData_PdcchSendReq_t.beamId    Offset    Length    3gpp.rnti
#     ...    DlData_DciInfo.startSymbolNumber    DlData_DciInfo.numOfSymbols    DlData_DciInfo.startCce
#     ...    DlData_DciInfo.aggregationLevel    DlData_DciInfo.dmrsReferencePoint
#     ...    DlData_DciInfo.pdcchPrecodingOption4x4    DlData_DciInfo.coresetFreqDomain
#     ...    DlData_DciInfo.cceRegMappingType    DlData_DciInfo.nShiftModNumOfRegBundles
#     ...    DlData_DciInfo.interleaverRows    DlData_DciInfo.regBundleSize
#     ...    DlData_DciInfo.precoderGranularity    DlData_DciInfo.coresetFreqDomainRbShift
#     ...    DlData_DciInfo.dciSize    DlData_DciInfo.numCeAxCIndex
#     ...    DlData_DciInfo.polarizationSelection    3gpp.dmrsScramblingSequenceInt
#     ...    DlData_DciInfo.patternId_item
# 
#     ${csv_file2}    Replace String    ${bip_files}    .pcap    _pdcch.csv
# 
#     Convert BIP To CSV By MCShark    bip_file=${bip_files}
#     ...    output_file=${csv_file2}    filter=${filter_2}    csv_title_list=${csv_title_list_2}
# 
#     Check_Bip_Sub_Info_By_Special_Item
#     ...    file_path=${csv_file2}
#     ...    item=3gpp.rnti
#     ...    item_value=0
#     ...    father_dict=${DICTONARY_PDCCHSENDREQ_IE}
# 
# #-----------------------------------------------------------------------
# # Step4:Stop Test Transmitter test model
# #-----------------------------------------------------------------------
#      log to console     \nStep4:Stop Test Transmitter test model
#      Stop Test Transmitter test model
# 
# 
# 
# 
# 
# 
# 
# 
