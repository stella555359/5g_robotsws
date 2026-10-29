# *** Settings ***
# Documentation      author: Chen Xiaodong
# ...                contact: xiaodong.d.chen@nokia-sbell.com
# ...                Group: HGZ_SG2
# Suite Setup       679 Suite Setup
# Suite Teardown    679 Suite TearDown
# Force Tags        5G_RRM          CB007782
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          Resources/5GC000679_common_keyword_Dingli.robot
# Resource          ../5GC001655/Resources/1347_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Variables         Resources/7782_modify_para.py
# 
# *** Variables ***
# ${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
# ${scf_path_23R3}    /home/ute/Downloads/SCF/SBTS23R3
# ${scf_path_Trunk}    /home/ute/Downloads/SCF/Trunk
# 
# ${case3_scf}    ${tmp_swconfig_dir}/7782_case3_scf.xml
# ${apn1}    ${tl.core.pdns[0].apn}
# 
# #22R1 filter
# ${pusch_filter}    \"uldata_puschreceivereq\"
# ${luashark_path_22R2}    /home/ute/Downloads/Lua_SBTS22R2_7782/generated_luashark/luashark.lua
# ${luashark_path_22R3}    /home/ute/Downloads/Lua_SBTS22R3_7782/generated_luashark/luashark.lua
# ${command_template_ul_22R2}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_22R2} -Y ${pusch_filter} -T pdml
# ${command_template_ul_22R3}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_22R3} -Y ${pusch_filter} -T pdml
# ${pusch_mcs_filed_name}    UlData_PuschReceiveReq.grants_item_0.mcs
# ${xpath_pusch_mcs_filed_name}    .//UlData_PuschReceiveReq.grants_item_0.mcs
# ${uldmrsflag_filed_name}    UlData_PuschReceiveReq.grants_item_0.numOfDmrsCdmGroupWithoutData 
# 
# #7782 case check filter
# ${ulDmrsMappingType_filter}    UlData_PuschReceiveReq.grants_item_0.ulDmrsMappingType        
# ${ulDmrsTypeAPos_filter}    UlData_PuschReceiveReq.grants_item_0.ulDmrsTypeAPos  
# ${ulDmrsAddPos_filter}    UlData_PuschReceiveReq.grants_item_0.ulDmrsAddPos 
# ${ulPtrsFlag_filter}    UlData_PuschReceiveReq.grants_item_0.ulPtrsFlag
# ${ulPtrsTimeDensity_filter}    UlData_PuschReceiveReq.grants_item_0.ulPtrsTimeDensity
# ${ulPtrsFrequencyDensity_filter}    UlData_PuschReceiveReq.grants_item_0.ulPtrsFrequencyDensity
# ${numOfLayers_filter}    UlData_PuschReceiveReq.grants_item_0.numOfLayers
# 
# ${data_transfer_dl}     50Mbits/sec
# ${data_transfer_ul}     130Mbits/sec
# ${Expected_Throughput_DL}     40
# ${Expected_Throughput_UL}     80
# 
# @{pa_value}    40    50    80
# 
# *** Test Cases ***
# [1][1.0] CB007782-5G-B_04_Verify NSA-Basic support of PUSCH data and DMRS FDM for TDD FR1-Traffic UL DL-0 additional DMRS-PUSCH type B
#     [Tags]    CRT    NSA    CB007782    100M
#     [Setup]    Case Setup 7782
#     DMRS typeB ULDL tput test    default_scf=${scf_path}/7782_case1_typeB_scf.xml
#     log to console      "TpyeA test start"
#     Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_tpyeA}
#     ...                                  default_scf=${scf_path}/7782_case1_typeB_scf.xml
#     COAM Wait for gnb ready and cell setup    timeout=15 min
#     log to console      "get PA init value"
#     ${initial_att_values}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
#     Set Test Variable    ${initial_att_values}
#     log to console      "UE0_attach_startTput"
#     UE0 attach and check tput
#     log to console      "start_bip_capture"
#     Connect to Common Unit Master
#     Start Bip Log Capture on Loki
#     sleep      2s
#     Adjust PA value for topyoung    n=0
#     sleep      2s
#     Adjust PA value for topyoung    n=1
#     sleep      2s
#     Adjust PA value for topyoung    n=2
#     sleep      2s
#     log to console      "stop bip"
#     #${list_log_path_local}    Stop Bip Log Capture on Loki and download BIP Logs to testPC    log_path=${OUTPUT_DIR}
#     #set test variable    ${bip_log_path}    @{list_log_path_local}[0]
#     Csn.Disconnect    connection=ASIK Master
#     log to console      "Check UL DMRS enable"
#     #Run Keyword And Ignore Error    Check UL DMRS enable
#     #Check 7782 case keypoints    ulDmrsMappingType=0
#     #...                          ulDmrsTypeAPos=3
#     #...                          ulDmrsAddPos=0
#     #...                          ulPtrsFlag=0
#     #...                          ulPtrsTimeDensity=1
#     #...                          ulPtrsFrequencyDensity=4
#     #...                          numOfLayers=1   
#     All UEs Check Tput    num=1
#     [Teardown]    Run Keyword And Ignore Error    Recover 7782 test ENV    n=1    apn_address=${apn1}
# 
# [1][1.0] CB007782-5G-A_06_Verify NSA-Basic support of PUSCH mapping type A for TDD FR1-Traffic UL DL-DMRS Pos3-1 additional DMRS-long PUCCH
#     [Tags]    CRT    ABIO    NSA    CB007782    100M
#     [Setup]    Case Setup 7782
#     DMRS typeB ULDL tput test    default_scf=${scf_path}/7782_case2_typeB_scf.xml
#     Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_tpyeA}
#     ...                                  default_scf=${scf_path}/7782_case2_typeB_scf.xml
#     COAM Wait for gnb ready and cell setup    timeout=15 min
#     log to console      "get PA init value"
#     ${initial_att_values}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
#     Set Test Variable    ${initial_att_values}
#     log to console      "UE0_attach_startTput"
#     UE0 attach and check tput
#     log to console      "start_bip_capture"
#     Connect to Common Unit Master
#     Start Bip Log Capture on Loki
#     sleep      2s
#     Adjust PA value for topyoung    n=0
#     sleep      2s
#     Adjust PA value for topyoung    n=1
#     sleep      2s
#     Adjust PA value for topyoung    n=2
#     sleep      2s
#     log to console      "stop bip"
#     #${list_log_path_local}    Stop Bip Log Capture on Loki and download BIP Logs to testPC    log_path=${OUTPUT_DIR}
#     #set test variable    ${bip_log_path}    @{list_log_path_local}[0]
#     Csn.Disconnect    connection=ASIK Master
#     log to console      "Check UL DMRS enable"
#     #Run Keyword And Ignore Error    Check UL DMRS enable
#     #Check 7782 case keypoints    ulDmrsMappingType=0
#     #...                          ulDmrsTypeAPos=3
#     #...                          ulDmrsAddPos=1
#     #...                          ulPtrsFlag=0
#     #...                          ulPtrsTimeDensity=1
#     #...                          ulPtrsFrequencyDensity=4
#     #...                          numOfLayers=1   
#     All UEs Check Tput    num=1
#     [Teardown]    Run Keyword And Ignore Error    Recover 7782 test ENV    n=1    apn_address=${apn1}
# 
# [1]7782_AA_03_SA_Basic_support_of_PUSCH_mapping_typeA_for_TDD_FR1_Traffic_UL_DL_DMRS_Pos2_automatic_shortpucch
#     [Tags]    SA    CB007782    100M
#     [Setup]    Case Setup 7782
#     Load Case SCF and Commission    default_scf=${case3_scf}
#     log to console      "get PA init value"
#     ${initial_att_values}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
#     Set Test Variable    ${initial_att_values}
#     log to console      "UE0_attach_startTput"
#     UE0 attach and check tput
#     log to console      "start_bip_capture"
#     Connect to Common Unit Master
#     Precondition for bip capture with gnbMirroring scripts
#     Bip Capture with gnbMirroring scripts    file_size_mbytes=2000
#     sleep      2s
#     Adjust PA value for topyoung    n=0
#     sleep      2s
#     Adjust PA value for topyoung    n=1
#     sleep      2s
#     Adjust PA value for topyoung    n=2
#     sleep      2s
#     log to console      "stop bip"
#     ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
#     set test variable    ${bip_log_path}    @{list_log_path_local}[0]
#     Csn.Disconnect    connection=ASIK Master
#     log to console      "Check UL DMRS enable"
#     Check UL DMRS enable
#     Check 7782 case keypoints    ulDmrsMappingType=0
#     ...                          ulDmrsTypeAPos=2
#     ...                          ulDmrsAddPos=0
#     ...                          ulPtrsFlag=1
#     ...                          ulPtrsTimeDensity=1
#     ...                          ulPtrsFrequencyDensity=2
#     ...                          numOfLayers=2   
#     All UEs Check Tput    num=1
#     [Teardown]    Run Keyword And Ignore Error    Recover 7782 test ENV    n=1    ue_mode=SA    apn_address=ims
# 
# *** Keywords ***
# Case Setup 7782
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     ${build}    Coam Get Active SW Version
#     ${result}    String.split string    string=${build}    separator=_
#     Run keyword if    'SBTS23R3' in ${result}    set test variable    ${scf_path}    ${scf_path_23R3}
#     ...       ELSE     set test variable    ${scf_path}    ${scf_path_Trunk}
#     Run keyword if    'SBTS22R2' in ${result}    set test variable    ${command_template_UL}    ${command_template_UL_22R2}
#     ...       ELSE     set test variable    ${command_template_UL}    ${command_template_UL_22R3}
#     robot_common_operations.Common Case Setup  
# 
# Adjust PA value for topyoung
#     [Documentation]    set PA to planned value, @{pa_value}[0],@{pa_value}[1],@{pa_value}[2]
#     [Arguments]    ${n}    
#     log to console      "set PA value${n}"
#     &{channels_to_modify}    create dictionary    1=@{pa_value}[${n}]    2=@{pa_value}[${n}]    3=@{pa_value}[${n}]    4=@{pa_value}[${n}]
#     gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}
# 
# DMRS typeB ULDL tput test
#     [Documentation]    typeB test in order to compare with tpyeA
#     [Arguments]    ${default_scf}        
#     log to console      "DMRS typeB test"
#     Load Case SCF and Commission    default_scf=${default_scf}
#     UE0 attach and check tput
#     COAM Teardown gnb connections
#     Run keyword and ignore error    All UEs Stop traffic    ue_mode=NSA    apn_address=${apn1}    j=1
# 
# UE0 attach and check tput
#     [Documentation]    UE0 attach_start_DIUL_tput and check Tput
#     #[Arguments]
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     spark attach and start DLUL traffic     data_transfer_dl=${data_transfer_dl}
#     ...                                     data_transfer_ul=${data_transfer_ul}
#     ...                                     n=0
#     ...                                     ue_mode=NSA
#     ...                                     attach_mode=5G_NSA
#     ...                                     apn_address=${apn1}    
#     Check throughput on gNB    direction=dl    throughput=${Expected_Throughput_DL}
#     Check throughput on gNB    direction=ul    throughput=${Expected_Throughput_UL}
#     sleep      5s
#     All UEs Check Tput    num=1
# 
# Draw line for Tput
#     [Documentation]    draw tput line pictrue
#     #[Arguments]
#     ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
#     ${list_of_cell_ids}    Create list    15761409
#     power_ue.Check Tput     ue_type=${ue_type}     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
#     ...                     target_throughput=${Expected_Throughput_UL}
#     power_ue.Check Tput     ue_type=${ue_type}     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
#     ...                     target_throughput=${Expected_Throughput_DL}
# 
# Check UL DMRS enable
#     [Documentation]    when actUlDataDmrsFdm is true. In uldata_puschreceivereq, numOfDmrsCdmGroupWithoutData should be 1 when MCS >= Threshold,
#     ...                should be 2 when MCS < Threshold. When ul256Qam is true,NIDD ulDataDmrsFdmThres256QamMcs is Threshold MCS, else
#     ...                ulDataDmrsFdmThres64QamMcs is Threshold MCS.
#     #[Arguments]
#     ${actUl256Qam}    Get_parameter_value    abbr=actUl256Qam    filter_param=Activate 256QAM in UL
#     ${mcs_threshold}    Run Keyword If    '${actUl256Qam}'=='true'    Get_parameter_value    abbr=ulDataDmrsFdmThres256QamMcs
#     ...                                                                     filter_param=Uplink data and DMRS FDM threshold 256QAM MCS
#     ...       ELSE     Get_parameter_value    abbr=ulDataDmrsFdmThres64QamMcs    filter_param=Uplink data and DMRS FDM threshold 64QAM MCS
#     bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}    
#     ...                                                      command_template=${command_template_ul}  
#     pcap.filter_packets_by_expression    filter_expression=${uldmrsflag_filed_name} == 0x01
#     ${mcs_value}    Get value from Bip Log by xpath    xpath=${xpath_pusch_mcs_filed_name}
#     ${mcs_value}     Remove Duplicates    ${mcs_value}   
#     ${length}    Get Length    ${mcs_value}
#     Should Be True    ${length}>${0}
#     FOR    ${i}    IN RANGE    ${length}
#         Should Be True    @{mcs_value}[${i}]>=${mcs_threshold}
#     END
#     bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}    
#     ...                                                      command_template=${command_template_ul} 
#     pcap.filter_packets_by_expression    filter_expression=${uldmrsflag_filed_name} == 0x02
#     ${mcs_value}    Get value from Bip Log by xpath    xpath=${xpath_pusch_mcs_filed_name}
#     ${mcs_value}     Remove Duplicates    ${mcs_value}   
#     ${length}    Get Length    ${mcs_value}
#     Should Be True    ${length}>${0}
#     FOR    ${i}    IN RANGE    ${length}
#         Should Be True    @{mcs_value}[${i}]<${mcs_threshold}
#     END
# 
# Check 7782 case keypoints
#     [Documentation]    case1/2/3 value as follow
#     ...                ulDmrsMappingType=TypeA(0)/A/A
#     ...                ulDmrsTypeAPos=3/3/2
#     ...                ulDmrsAddPos=0/1/0
#     ...                ulPtrsFlag=0/0/1
#     ...                ulPtrsTimeDensity=1/1/1
#     ...                ulPtrsFrequencyDensity=4/4/2
#     ...                numOfLayers=1/1/2
#     [Arguments]    ${ulDmrsMappingType}    ${ulDmrsTypeAPos}    ${ulDmrsAddPos}    ${ulPtrsFlag}    ${ulPtrsTimeDensity}
#     ...            ${ulPtrsFrequencyDensity}    ${numOfLayers}
#     bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}    
#     ...                                                      command_template=${command_template_ul}
#     pcap.filter_packets_by_expression    filter_expression=${uldmrsflag_filed_name} == 0x01
#     Check the fix value from bip    type_filter=${ulDmrsMappingType_filter}    plan_value=${ulDmrsMappingType}
#     Check the fix value from bip    type_filter=${ulDmrsTypeAPos_filter}    plan_value=${ulDmrsTypeAPos}
#     Check the fix value from bip    type_filter=${ulDmrsAddPos_filter}    plan_value=${ulDmrsAddPos}
#     Check the fix value from bip    type_filter=${ulPtrsFlag_filter}    plan_value=${ulPtrsFlag}
#     Check the fix value from bip    type_filter=${ulPtrsTimeDensity_filter}    plan_value=${ulPtrsTimeDensity}
#     Check the fix value from bip    type_filter=${ulPtrsFrequencyDensity_filter}
#     ...                             plan_value=${ulPtrsFrequencyDensity}
#     Check the fix value from bip    type_filter=${numOfLayers_filter}    plan_value=${numOfLayers}
# 
# Check the fix value from bip
#     [Documentation]    get the value from bip and contrast with the planned value
#     [Arguments]    ${type_filter}    ${plan_value}
#     ${get_bip_value}    Get value from Bip Log    field_name=${type_filter}
#     ${get_bip_value}     Remove Duplicates    ${get_bip_value}   
#     ${length}    Get Length    ${get_bip_value}
#     Should Be True    ${length}>${0}
#     Should Be True    @{get_bip_value}[0]==${plan_value}
# 
# Recover 7782 test ENV
#     [Documentation]    good point: recover PA_value=34
#     [Arguments]    ${apn_address}    ${ue_mode}=NSA    ${n}=1
#     COAM Teardown gnb connections
#     Run keyword and ignore error    All UEs Stop traffic    ue_mode=${ue_mode}    apn_address=${apn_address}    j=${n}
#     Run keyword and ignore error    gnb_classical_hangzhou.Restore Attenuation Values For RU  initial_att_values=${initial_att_values}
#     Run keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# Spark UE attach
#     [Documentation]    Attach
#     ...          :param  n: The ue_index of Spark
#     ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
#     ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
#     [Arguments]    ${n}    ${attach_mode}    ${get_spark_license}=False
#     log to console      "Prepare_UE${n}"
#     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=${get_spark_license}
#     sleep      3s
#     log to console      "attach_UE${n}"
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}     attach_mode=${attach_mode}    ue_index=${n}
#     power_ue.Verify attach     ue_type=${ue_type}    4G_check=True    5Grach_ed=${5Grach_ed}     ue_index=${n}
# 
# spark attach and start DLUL traffic
#     [Documentation]    Attach_start_DL_UL_tput
#     ...          :param  n: The ue_index of Spark
#     ...          :param  ue_mode: start traffic for NSA or SA
#     ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
#     ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
#     [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}
#     ...             ${apn_address}    ${ue_mode}    ${attach_mode}
#     run keyword and ignore error    Spark UE attach    n=${n}    attach_mode=${attach_mode}    get_spark_license=False
#     sleep      2s
#     power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
#     ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
#     power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
#     ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
