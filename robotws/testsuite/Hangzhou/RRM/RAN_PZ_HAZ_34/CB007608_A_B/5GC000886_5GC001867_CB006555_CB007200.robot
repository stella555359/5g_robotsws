# *** Settings ***
# Documentation
# ...   author: Hu Jiao
# ...   contact: jiao.hu@nokia-sbell.com
# ...   squad group: SG_05
# ...   feature : CB007608_5GC000886 in 5G22R1
# 
# Force Tags    CRT_22R4    CRT_TRUNK   CRT_22R2
# ...    PY36
# 
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup     Run Keywords    Suite setup for 5GC000886
# ...   AND      robot_common_operations.Common Suite Setup
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# 
# 
# 
# 
# Library      taf.converters.pcaptopdml    WITH NAME    pcaptopdml
# Library     XML    use_lxml=True
# Library     taf.sbts.oam.coam.admin        WITH NAME    coam_admin
# Resource      ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    ./Resources/CB007608_coam_common_keywords.robot
# Resource       ./Resources/pmcounters.robot
# Library           OperatingSystem
# 
# 
# *** Variables ***
# ${MME_IP}    10.108.225.167
# ${enb_IP}    10.68.253.5
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
# #${local_path}    /opt/workspace/CIT/Master/Case_Logs/
# #${local_path}    ${OUTPUT DIR}/Logs
# #${local_path}     ../test_results
# ${command_template_with_Y}       {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
# ${tshark_path}      /usr/bin/tshark
# ${SPpath}     .//nr-rrc.commonSearchSpaceList//nr-rrc.SearchSpace_element
# ${SP3path}    .//nr-rrc.searchSpacesToAddModList/*[@show="Item 0"]/nr-rrc.SearchSpace_element
# ${SPUEpath}    .//nr-rrc.searchSpacesToAddModList/*[@show="Item 1"]/nr-rrc.SearchSpace_element
# ##5GC000886_B_04_Secondary_RAT_Data_Usage_Report_Periodical_Enb_actSecRatRep_off_and_on
# ${enb_dist_B04}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
# ${enb_para_B04}    actSecRatRep
# ${s1log_B04_1}    886_B_04_S1_1.pcap
# ${s1log_B04_2}    886_B_04_S1_2.pcap
# ${new_value_B_04}    10
# 
# 
# ##5GC000886_D_04_Verify_PMCounter_Secondary_RAT_Data_Usage_Report_by_MN_initiate_SGNB_Release
# ${dist_name_A02}    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
# ${parameter_name_A02}     periodicalDataUsageReportTimer
# ${new_value_A02_Back}    10
# ${new_value_A02}    0
# #${parameter_name_A01}      actSecDataUsageRep
# #${new_value_A01_01}    true
# #${new_value_A01_Back}    false
# ${E1log_D04}    886_D_04_E1.pcap
# ${PM_counter_D04}    M55110C02001
# ${PMfile_name_D04}    PMFile_D04.xml
# ${periodicalDataUsageReportTimer}    10
# 
# ##5GC000886_D_12_Secondary_RAT_Data_Usage_Report_Modify_Periodical_Value
# ${dist_name_D12}    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
# ${parameter_name_D12}     periodicalDataUsageReportTimer
# ${new_value_D12_1}    20
# ${new_value_D12_2}    0
# ${E1log_D12_1}    886_D_12_E1_1.pcap
# ${E1log_D12_2}    886_D_12_E1_2.pcap
# 
# 
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
# ${rrc_PDCCH_common_searchSpace_type1_2}   ${SPpath}/nr-rrc.searchSpaceType/nr-rrc.common_element/nr-rrc.dci_Format0_0_AndFormat1_0_element
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
# 
# 
# 
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
# 
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
# #${luashark_path}      /home/ute/luashark/generated_luashark/luashark.lua
# ${bip_remote_log_path}    /tmp
# #${bip_remote_log_name}    tcpdump_L2L1_bip_filtering_off.pcap
# &{DICTONARY_PDCCHSENDREQ_IE}                   DlData_PdcchSendReq_t.beamId=0
# #...                                            Offset=8
# #...                                            Length=1
# #...                                            3gpp.rnti=0
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
# #...                                            3gpp.dmrsScramblingSequenceInt=93
# ...                                            DlData_DciInfo.patternId_item=200
# 
# 
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
# #...                                            3gpp.dmrsScramblingSequenceInt=93
# ...                                            DlData_PdschGrant.startPrb=3
# ...                                            DlData_PdschGrant.numOfPrb=63
# ...                                            DlData_PdschGrant.modulationOrder=2
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
# #...                                            3gpp.dmrsScramblingSequenceInt=93
# ...                                            DlData_PdschGrant.startPrb=0
# ...                                            DlData_PdschGrant.numOfPrb=3
# ...                                            DlData_PdschGrant.modulationOrder=2
# 
# 
# 
# *** Test Cases ***
# [1]CB007608_B_5GC000886_B_04_Secondary_RAT_Data_Usage_Report_Periodical_Enb_actSecRatRep_off_and_on
#     [Documentation]
#     ...    This case is to verify Secondary RAT Data Usage Report generation and delivery periodical,
#     ...    and it is not affected by wether Enb actSecRatRep is on or off.It need gnb periodicalDataUsageReportTimer and actSecDataUsageRep enable
#     [Tags]     CRT_22R1    CRT_TRUNK   CRT_22R2
#     [Timeout]    1 hour
# 
#     [Teardown]
#     log to console    \nStep1:Precondition for power UE
#     Precondition for power UE    ue_type=samsung     ue_index=${0}
# 	  log to console    \nStep2:Connect and Modify the parameter on enblte
#     Connect and Modify the parameter on enblte    dist_name=${enb_dist_B04}
#     ...    parameter=${enb_para_B04}     value=false
# 	log to console    \nStep3.1:reboot UE
# 	Andriod UE adb reboot    ue_index=${0}
#   	log to console    \nStep3:Attach and check power UE
#     Attach and check power UE    ue_type=samsung     MCI_value=2579969    ue_index=${0}
# 	  log to console    \nStep4:Start To Capture ENB Logs
#     Start To Capture ENB Logs    filename=${s1log_B04_1}   connection=ENB
#     sleep    20s
# 	  log to console    \nStep5:Stop and download ENB Logs
#     Stop and download ENB Logs    filename=${s1log_B04_1}    connection=ENB
# 	  log to console    \nStep6:Start To Capture ENB Logs
#     Start To Capture ENB Logs    filename=${s1log_B04_2}   connection=ENB
# 	  log to console    \nStep7:Connect and Modify the parameter on enblte
#     Connect and Modify the parameter on enblte    dist_name=${enb_dist_B04}
#     ...    parameter=${enb_para_B04}     value=true
#     sleep    10s
#   	log to console    \nStep8:Stop and download ENB Logs
#     Stop and download ENB Logs    filename=${s1log_B04_2}    connection=ENB
# 	  log to console    \nStep9:Detach for power UE
#     Detach for power UE    ue_type=samsung     ue_index=${0}
# 	  log to console    \nStep10:Analysis ENB_B04 S1 log_1
#     Analysis ENB_B04 S1 log_1
#   	log to console    \nStep11:Analysis ENB_B04 S1 log_2
#     Analysis ENB_B04 S1 log_2
# 	log to console    \nStep12:Connect and Modify the parameter on enblte_recover
#      Connect and Modify the parameter on enblte    dist_name=${enb_dist_B04}
#     ...    parameter=${enb_para_B04}     value=false
# 
# [1]CB007608_B_5GC000886_D_04_Verify_PMCounter_Secondary_RAT_Data_Usage_Report_by_MN_initiate_SGNB_Release
#     [Documentation]
#     ...    This case is to verify the PMcunter of Secondary RAT Data Usage Report generation and delivery triggered by
#     ...    SgNB Release initiated by MN，PM counter name ENDC_X2_SEC_RAT_DATA_USAGE_REP,PI-ID is M55110C02001.
# 	...    It need enable event trigger but disable period trigger
#     [Tags]     CRT_22R1    CRT_TRUNK    CRT_22R2
#     [Timeout]    1 hour
#     [Teardown]   Run Keywords    Tests_Recover
#     Precondition: check gNB can be on air
# 	  log to console    \nStep1.2:Change the COAM parameter online
#     Change the COAM parameter online    dist_name=${dist_name_A02}    parameter_name=${parameter_name_A02}    new_value=${new_value_A02}
#   	log to console    \nStep2:precondition for power UE
#     Precondition for power UE    ue_type=samsung     ue_index=${0}
#    	log to console    \nStep1.1:check aireplane state and wait the PM period expire
# 	  check aireplane state and wait the PM period expire    ue_index=${0}
# 	  log to console    \nStep3:Start To Capture Wireshark Logs
#     Start To Capture Wireshark Logs    filename=${E1log_D04}    connection=gnb    interface=any
# 	  log to console    \nStep4:Attach and check power UE
#     Attach and check power UE    ue_type=samsung     MCI_value=2579969    ue_index=${0}
#     log to console     \nstep5:Start the DL data throughput
#     Start the DL data throughput        ue_index=${0}    ue_addr=${UE_IP}
#     log to console    \nstep6:start Ul data throughput
#     Start the UL data throughput
#     sleep    5s
#   	log to console    \nstep7:Detach for power UE
#     Detach for power UE    ue_type=samsung     ue_index=${0}
#     sleep    10s
#     Stop and download Logs    logname=${E1log_D04}   connection=gnb
#     Set Suite Variable    ${pm_utc_left}    1
#   	log to console     \nstep7 stop and download logs
#     Wait Until Keyword Succeeds    15min    1min    Check SRB0_SRB1_Counters
#     log to console   \n PM counter
# 
# 
# [1]CB007608_B_5GC000886_D_12_Secondary_RAT_Data_Usage_Report_Modify_Periodical_Value
#    [Documentation]
#     ...    This case is to verify Secondary RAT Data Usage Report generation and delivery periodical???
#     ...    and verfy different predical value,including 0
# 	[Tags]     CRT_22R1    CRT_TRUNK    CRT_22R2
#     [Timeout]    1 hour
#     [Teardown]   Run Keywords    Tests_Recover
#     Precondition: check gNB can be on air
#     log to console     \nstep1 Change the COAM parameter online
#     Change the COAM parameter online    dist_name=${dist_name_D12}    parameter_name=${parameter_name_D12}    new_value=${new_value_D12_1}
#     Precondition for power UE    ue_type=samsung     ue_index=${0}
#     log to console     \nstep2 S1_Start To Capture x2 Wireshark Logs
#     Start To Capture x2 Wireshark Logs    filename=${E1log_D12_1}    connection=gnb    interface=any
#     #Start To Capture Wireshark Logs    filename=${E1log_D12_1}    connection=gnb    interface=any
# 	  log to console     \nstep3 Attach and check power UE
#     Attach and check power UE    ue_type=samsung    MCI_value=2579969     ue_index=${0}
#     log to console     \nstep4 Start the DL data throughput
#     Start the DL data throughput        ue_index=${0}    ue_addr=${UE_IP}
#     log to console    \nstep5 Start the UL data throughput
#     Start the UL data throughput
#     sleep    15s
#     sleep    15s
#     Stop and download Logs    logname=${E1log_D12_1}   connection=gnb
#     log to console    \nstep6 Change the COAM parameter online s2
#     Change the COAM parameter online    dist_name=${dist_name_D12}    parameter_name=${parameter_name_D12}    new_value=${new_value_D12_2}
#     log to console    \n step7 s2 start to capture wireshark logs
#     Start To Capture Wireshark Logs    filename=${E1log_D12_2}    connection=gnb    interface=any
#     sleep    20s
#     Stop and download Logs    logname=${E1log_D12_2}   connection=gnb
#     log to console    \n step8 Analysis E1_D12 log_1
#     Analysis E1_D12 log_1
#     log to console    \n step9 Analysis E1_D12 log_1
#     Analysis E1_D12 log_2
# 
# [1]CB007608_A_CB006555_Migration_rules_for_22R1_verification_config_2_mmW_ASIL_eCPRI
#     [Documentation]
#     ...    The purpose of this user scenario is to validate dynamic pdcch properly configured in 22R1
#     ...    ******************
#     ...    *******************
#     [Tags]     CRT_22R1    CRT_TRUNK   CRT_22R2
# 
#     [Teardown]    Run Keywords    Tests_Recover_6555
#     Precondition: check gNB can be on air
#     Step 1: Collect CPIF log
#     Step 2: Attach UE and Send DL traffic    MCI_value=2579969
#     Step 3: Stop pcap on CPIF and download to testPc
#     Step 4: Stop DL traffic and detach UE
#     Step 5: Verify parameters of dynamic pdcch configured correctly
# 
# [1]CB007608_CB007200_02_DL_Test_Model_Verification_TM1-1
#    [Documentation]
#    ...  This user scenario validates the signal from NR is aligned with the parameters defined for NR-FR2-TM1.1
#    ...  Step1:Selects the RU mode 'NR only RU' and test model=TM1_1 into DL TestModels state
#    ...  Step2:Capture BIP log
#    ...  Step3:Verify the PDCCH and PDSCH characteristics in BIP log are consistent with the parameters defined for NR-FR2-TM1.1
#    ...  Step4:Stop Test Transmitter test model
#    [Tags]     CRT_22R1    CRT_TRUNK    CRT_22R2    test
# 
#    #AND   Download luashark
#    [Teardown]    Run Keywords    Tests_Recover_7200    AND    CI_interface.Common Suite Setup
# #-----------------------------------------------------------------------
# # Step1:Selects the RU mode 'NR only RU' and test model=TM1_1 into DL TestModels state
# #-----------------------------------------------------------------------
#     Run Keywords     Precondition: check gNB can be on air    AND    Download MCShark To UTE
#     log to console     \nStep1:Selects the RU mode 'NR only RU' and test model=TM1_1 into DL TestModels state
#     Activate Test dedicated Mode
# 
#     Check gNB can be on test mode
# 
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
# 
# #-----------------------------------------------------------------------
# # Step2:Capture BIP log
# #-----------------------------------------------------------------------
#     log to console     \nStep2:Capture BIP log
#     Capture BIP log
#     ${list_log_path_local}=  set variable    ${local_path}/${bip_remote_log_name}
# 
# #-----------------------------------------------------------------------
# # Step3:Verify the PDCCH and PDSCH characteristics in BIP log are consistent with the parameters defined for NR-FR2-TM1.1
# #-----------------------------------------------------------------------
#     log to console     \nStep3:Verify the PDCCH and PDSCH characteristics in BIP log are consistent with the parameters defined for NR-FR2-TM1.1
# 
#     set suite variable     ${rnti0_pdml_file}      ${local_path}/rnti0.pdml
#     set suite variable     ${command_template1}    ${tshark_path} -Y "3gpp.rnti==0" -r ${list_log_path_local} -T pdml > ${local_path}/rnti0.pdml
#     pcaptopdml.create_pcap_to_pdml_converter
#     ...      name=converter
#     ...      file_path_pattern=${list_log_path_local}
#     ...      tshark_path=${tshark_path}
#     ...      command_template=${command_template1}
#     pcaptopdml.convert    converter
#     #${pdml_file} =    Replace String    ${list_log_path_local}    .pcap    .pdml
# 
#     set suite variable     ${rnti2_pdml_file}      ${local_path}/rnti2.pdml
#     set suite variable     ${command_template2}    ${tshark_path} -Y "3gpp.rnti==2" -r ${list_log_path_local} -T pdml > ${local_path}/rnti2.pdml
#     pcaptopdml.create_pcap_to_pdml_converter
#     ...      name=converter
#     ...      file_path_pattern=${list_log_path_local}
#     ...      tshark_path=${tshark_path}
#     ...      command_template=${command_template2}
#     pcaptopdml.convert    converter
# 
#     pcaptopdml.create_pcap_to_pdml_converter
#     ...    tshark_path=${tshark_path}
#     ...      name=converter
#     ...      file_path_pattern=${list_log_path_local}
#     pcaptopdml.convert    converter
#     ${pdml_file} =    Replace String    ${list_log_path_local}    .pcap    .pdml
# 
# 
#     Verify that message DlData_PdcchSendReq      ${pdml_file}
#     Verify message DlData_PdschSendReq for UE1_rnti0    ${rnti0_pdml_file}
#     Verify message DlData_PdschSendReq for UE1_rnti1    ${rnti2_pdml_file}
# 	
# #-----------------------------------------------------------------------
# # Step4:Stop Test Transmitter test model
# #-----------------------------------------------------------------------
#      log to console     \nStep4:Stop Test Transmitter test model
#      Stop Test Transmitter test model
# 
# 
# *** Keywords ***
# Download MCShark To UTE
#     ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
#     set suite variable     ${wireshark_version}
# 
#     ${sw_version}    Get MCShark Version
#     ${cmd}    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
#     ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
#     ${MCShark}    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-${wireshark_version}*buster.so
#     set suite variable     ${MCShark}
# 
#     ${is_MCShark_exist}    Run keyword and return status    Should not contain    ${MCShark}    No such file or directory
# 
#     Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
#     ...  ELSE         log to console    This version mcshark donot exit and use last version mcshark
# 
# 
# Download MCShark If Have
#     Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*buster.so
#     Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/
# 
#     log to console    download mcshark successfully to UTE
# 
# Get MCShark Version
#     [Documentation]    jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl
#     ${sw_version}    coam.get_sw_version    connection=GNB_OAM
#     ${list_version}    Split String    ${sw_version}    _
#     ${first}    ${rest}    Split String    ${sw_version}    _    1
#     ${new_version}    Set Variable If    "${list_version}[2]"=="9999"
#     ...    SBTS00_${rest}      ${sw_version}
#     ${list_version}    Split String    ${new_version}    _
#     ${rest}    ${last}    Split String From Right    ${new_version}    _    1
#     ${latest_version}    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
#     ...    ${rest}_000000      ${new_version}
#     [Return]    ${latest_version}
#     [Teardown]    COAM Teardown gnb connections
# 
# 
# Suite setup for 5GC000886
#     CI_interface.Common Suite Setup
#     Create Directory    /home/ute/5GC000886_log
#     Set Suite Variable   ${local_path}   /home/ute/5GC000886_log
# 
# 
# 
# Analysis ENB_B04 S1 log_1
#     pcap.Read Cap    ${local_path}${s1log_B04_1}    alias=enbb0411
#     ${result}    Run keyword and ignore error    pcap.Check Expression    condition_expression=ip.dst == ${MME_IP} and s1ap.procedureCode == 62    
# 	...    pcap_parser=enbb0411
#     should contain    ${result}    FAIL
#     pcap.Read Cap    ${local_path}${s1log_B04_1}    alias=enbb0412
#     pcap.Check Expression    condition_expression=ip.dst == ${enb_IP} and x2ap.procedureCode==38    pcap_parser=enbb0412
# 
# Analysis ENB_B04 S1 log_2
#     pcap.Read Cap    ${local_path}${s1log_B04_2}    alias=enbb0421
#     pcap.Check Expression    condition_expression=ip.dst == ${MME_IP} and s1ap.procedureCode == 62    pcap_parser=enbb0421
#     pcap.Read Cap    ${local_path}${s1log_B04_2}    alias=enbb0422
#     pcap.Check Expression    condition_expression=ip.dst == ${enb_IP} and x2ap.procedureCode == 38    pcap_parser=enbb0422
# 
# Analysis E1_D12 log_1
#     pcap.setup    ${local_path}${E1log_D12_1}    alias=e1d12l1
#     pcap.get_packets    filter=x2ap.e_RABUsageReportList == 1    pcap_parser=e1d12l1
#     @{Secondary_startTimeStamp}=    pcap.get_field_value    field_name=x2ap.startTimeStamp
#     ...    filter=x2ap.e_RABUsageReportList == 1    pcap_parser=e1d12l1
#     @{Secondary_endTimeStamp}=    pcap.get_field_value    field_name=x2ap.endTimeStamp
#     ...    filter=x2ap.e_RABUsageReportList == 1    pcap_parser=e1d12l1
#     @{startTimeStamp1List}    Set Variable    @{Secondary_startTimeStamp}[0]
#     ${startTimeStamp1Str} =    Remove String    @{startTimeStamp1List}[0]    :
#     ${startTimeStamp1} =    Convert To Integer    ${startTimeStamp1Str}    16
#     @{endTimeStamp1List}    Set Variable    @{Secondary_endTimeStamp}[0]
#     ${endTimeStamp1Str} =    Remove String    @{endTimeStamp1List}[0]    :
#     ${endTimeStamp1} =    Convert To Integer    ${endTimeStamp1Str}    16
#     ${time_dif} =    evaluate  ${endTimeStamp1}-${startTimeStamp1}
#     should be true    ${time_dif}==20
# 
# Analysis E1_D12 log_2
#     pcap.Read Cap    ${local_path}${E1log_D12_2}    alias=e1d12l2
#     ${result}    Run keyword and ignore error    pcap.Check Expression    ip.dst == ${enb_IP} and x2ap.procedureCode==38    pcap_parser=e1d12l2
#     should contain    ${result}    FAIL
# 
# COAM_Admin.CheckBTSConterWithTraget
#     [Arguments]    ${counter_id}    ${target_value}=0
#     ${date}   Get Current Date   exclude_millis=True
#      log to console    \ntest4
#     ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter_id}
#      log to console    \ntest5
#     ${values}    get dictionary values   ${res}
#      log to console    \ntest6
#     should be true    ${values[-1]}==${target_value}
# 
# Check SRB0_SRB1_Counters
#     log to console    \ntest1
#     wait until keyword succeeds    3x    1min    COAM_WebEM.Login
#      log to console    \ntest2
#     COAM_Admin.CheckBTSConterWithTraget     counter_id=M55110C02001    target_value=1
#      log to console    \ntest3
#     COAM_WebEM.Logout
# 
# COAM_WebEM.Login
#     [Documentation]   parameter should be ${True} or ${False}
#     [Arguments]      ${virtual_enable}=${TRUE}    ${url}=${WEBUI_URL}
#     run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
#     run keyword and ignore error    selenium_coam.logout
#     selenium_coam.login    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
#     selenium_coam.disable_message_box
#     selenium_coam.disable_screen_lock
#     sleep    15s
#     ${res}    selenium_coam.start_up_view_window_exists
#     run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window
# 
# COAM_WebEM.Logout
#     [Arguments]     ${virtual_disable}=${TRUE}
#     ${res}    selenium_coam.start_up_view_window_exists
#     run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window
#     selenium_coam.logout
#     run keyword if      ${virtual_disable}    selenium_coam.disable_virtual_display
# 
# 
