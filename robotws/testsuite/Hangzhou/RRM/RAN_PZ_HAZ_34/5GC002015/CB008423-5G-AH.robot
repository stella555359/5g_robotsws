# *** Settings ***
# Documentation      author: Ji Jian
# ...                contact: jian.ji@nokia-sbell.com
# ...                Group: HGZ_SG2
# Force Tags         5G_RRM
# ...    PY36
# 
# Suite Setup        Common Suite Setup for COAM
# Suite Teardown     Common Suite Teardown for COAM
# 
# Resource           Resources/5GC001655_common_keyword.robot
# 
# *** Variables ***
# ${scf_file}                     CB008072.xml
# ${data_transfer_ul}             200Mbits/sec
# ${Expected_Throughput_UL}       100
# ${pusch_mcs}                    UlData_puschReceiveReqGrant_t.mcs
# ${Ul_numOfDmrs}                 UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
# ${tmp_swconfig_dir}             /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
# ${ue_index}                     0
# &{CB008423_5G_AH_05}            SBTS22R2=QC_169989    SBTS22R3=QC_282962    SBTS22R4=QC_361889    SBTS23R1=QC_226311
# 
# *** Test Cases ***
# [1][1.0]_CB008423-5G-AH_05_Verify_SA_-_PUSCH_mapping_type_B_for_TDD_FR1_CPRI_-_DMRS_Pos3_-_1_additional_DMRS-Long_Pucch_DMRS_FDM_OFF_vs_ON
#     [Tags]     CIT_22R3    ${CB008423_5G_AH_05['${program}']}
#     [Setup]     Case Setup
#     "Step1" Settings of actUlDataDmrsFdm to true
#     "Step2" Start and check UL traffic for actUlDataDmrsFdm at true for SA
#     "Step3" Check uldata_puschreceivereq for actUlDataDmrsFdm at true
#     "Step4" Settings of actUlDataDmrsFdm to false
#     "Step5" Start and check UL traffic for actUlDataDmrsFdm at false for SA
#     "Step6" Check uldata_puschreceivereq for actUlDataDmrsFdm at false
#     "Step7" Compare ul_tput of actUlDataDmrsFdm set to true or false
#     [Teardown]     Case Teardown
# 
# *** Keywords ***
# Case Setup
#     COAM Create log directory
#     Run Keyword And Continue On Failure    Connect to gnb coam via ssl
#     Run Keyword And Continue On Failure    Aasyslog precondition    aa_sys_mode=5    aa_sys_addr=0xC0A8FF7E    aa_sys_udp_port=0xC738
#     Run Keyword And Continue On Failure    Btslog Setup Collector
#     ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
#     Check Alarm and stop robot testing when unexpected alarm raised
#     Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
#     COAM Wait for gnb ready and cell setup    gnb_type='SA'
#     ${license_status}    Run Keyword And Return Status    get_spark_license_for_team      
# 	...    host=${tl.ues[0].ssh_connection_details.addr}     
# 	...    user=${tl.ues[0].licensekeeper.username}    password=${tl.ues[0].licensekeeper.password}
#     Set Test Variable    ${license_status} 
#     Run Keyword And Ignore Error     COAM Teardown gnb connections
# 
# Case Teardown
#     Run Keyword And Continue On Failure    Connect to gnb coam via ssl
#     Run Keyword And Continue On Failure    Run Keyword If Test Failed
#     ...    COAM Save snapshot via rest api    connection=GNB_OAM    log_path=${LOG_PATH}    timeout=${600}
#     Run Keyword And Continue On Failure    Btslog Teardown Collector
#     Run Keyword And Continue On Failure    CI_interface.Common Case Teardown
#     Check Alarm and stop robot testing when unexpected alarm raised
#     Run keyword And Ignore Error    release_spark_license_for_team    host=${tl.ues[0].ssh_connection_details.addr}
#     Run Keyword And Ignore Error    COAM Teardown gnb connections
# #------------------------------------------------Update CB008423 parameter------------------------------------------------#	
# "${Step}" Settings of actUlDataDmrsFdm to true
#     Log to console    \n"${Step}" Settings of actUlDataDmrsFdm to true and actUl256Qam to true\n
#     Wait until keyword succeeds    10 min    5 s    Update CB008423 parameter
#     ...    actUl256Qam=true
#     ...    actUlDataDmrsFdm=true
# 
# "${Step}" Settings of actUlDataDmrsFdm to false
#     Log to console    \n"${Step}" Settings of actUlDataDmrsFdm to false and actUl256Qam to true\n
#     Wait until keyword succeeds    10 min    5 s    Update CB008423 parameter
#     ...    actUl256Qam=true
#     ...    actUlDataDmrsFdm=false
# 
# Update CB008423 parameter
#     [Arguments]    ${actUlDataDmrsFdm}    ${actUl256Qam}=true    ${actUlDftSOfdm}=true
#     Wait until keyword succeeds    3 min    5 s    COAM Navigate to login page via webUI
#     selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
#     ...    filter_param=Activate 256QAM in UL
#     ...    new_value=${actUl256Qam}
#     selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
#     ...    filter_param=Activate uplink data and DMRS FDM
#     ...    new_value=${actUlDataDmrsFdm}
#     selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
#     ...    filter_param=Activate use of UL DFT-S-OFDM
#     ...    new_value=${actUlDftSOfdm}
#     run keywords    Connect to gnb coam via ssl
#     ...     AND     selenium_coam.validate_plan
#     ...     AND     COAM check validation errors from webui     is_need_to_check_validation_errors=${True}
#     ...     AND     Wait until keyword succeeds    5 min    5 s    selenium_coam.activate_plan     activate_plan_despite_errors=${True}
#     ...     AND     Run Keyword And Continue On Failure    Wait until keyword succeeds    5 min    5 s    COAM Check GNB cell on air
#     ...     AND     Run Keyword And Continue On Failure    COAM Download scf from cluster    scf_dir_path=${TS_CASE_LOG_PATH}
#     ...     AND     Run Keyword And Ignore Error    COAM Teardown gnb connections
#     [Teardown]     Run keyword and ignore error     COAM selenium logout
# 
# #------------------------------------------------Start and check UL traffic------------------------------------------------#
# Start UL traffic and Capture BIP
#     [Arguments]     ${data_transfer_ul}     ${Expected_Throughput_UL}    ${bip_log}    ${ue_mode}=NSA    ${attach_mode}=5G_NSA
#     ...    ${buffer_size}=1400B    ${ul_port}=52228    ${apn1}=wap1.nokia.com    ${ue_index}=${0}    ${power_reset}=False
#     #------------------------------------------------------UE attach------------------------------------------------------#
#     Get UE Type for Power UE from File
#     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}    get_spark_license=${license_status}
#     Sleep    3s
#     ${5Grach_ed}    Wait until keyword succeeds    10 min    5 s    power_ue.UE Attach
#     ...    ue_type=${ue_type}     ue_index=${ue_index}    attach_mode=${attach_mode}    power_reset=${power_reset}
#     Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}    4G_check=True    5Grach_ed=${5Grach
# ..._ed}    ue_index=${ue_index}
#     #---------------------------------------------------start traffic---------------------------------------------------#
#     Wait until keyword succeeds    3 min    5 s    power_ue.Start traffic
#     ...    ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}    ue_mode=${ue_mode}   apn_address=${apn1} 
#     ...    duration=900     iperf_port=${ul_port}     buffer_size=${buffer_size}    ue_index=${ue_index}
#     Sleep    5s
#     #---------------------------------------Get Initial Attenuation Values -------------------------------------------#
#     ${initial_att_values_info}    Run Keyword And Ignore Error    Get Initial Attenuation Values
#     @{default_att_values}    create list    0    0    0    0
#     ${initial_att_values}    set variable if    '${initial_att_values_info[0]}'=='PASS'    ${initial_att_values_info[1]}    ${default_att_values}
#     Set Test Variable    ${initial_att_values}
#     #---------------------------------------Adjust PA AND Capturing Aasyslog Throughput---------------------------------------#	
#     Start Capture Aasyslog
#     Run keyword and ignore error    Wait until keyword succeeds    2 min    5 s
#     ...    Adjust PA Value One By One    start=0    end=60    step=1
#     Stop Capture Aasyslog
#     #------------------------------------------------Check UL Tput------------------------------------------------#
#     ${cells}    Create list    ${nrCellIdentity}
#     ${real_ul_tput}    Run keyword and ignore error    power_ue_throughput.__Standard Check Aasyslog Throughput    
#     ...    direction=ul    cells=${cells}    log=${local_path}    target_throughput=${Expected_Throughput_UL}
#     ...    target_avg_percent=0.1    min_percent=0
#     Log To Console    \nreal_ul_tput= ${real_ul_tput}
#     ${average_ul_tput}    Set Variable If    '${real_ul_tput[0]}'=='PASS'    ${real_ul_tput[1][0]['average']}    ${real_ul_tput[0]['average']}
#     set test variable    ${average_ul_tput}
#     Log To Console    \naverage_ul_tput= ${average_ul_tput} Mbits/sec\n
#     #------------------------------------------------Capture BIP------------------------------------------------#
#     Run Keyword And Continue On Failure    Wait until keyword succeeds    1 min    3 s    Common Capture BIP log and download to testPC
#     #--------------------------------------- Restore Attenuation -------------------------------------------#
#     [Teardown]    Run keyword and ignore error    run keyword if    '${initial_att_values_info[0]}'=='PASS'    Run keywords
#     ...    Restore Attenuation Values    initial_att_values=@{initial_att_values}
#     ...    AND     power_ue.Stop traffic     ue_type=${ue_type}     direction=ul     iperf_port=${ul_port}
#     ...    AND     power_ue.UE Detach     ue_type=${ue_type}
#     ...    ELSE    Run keywords    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul     iperf_port=${ul_port}
#     ...    AND     power_ue.UE Detach     ue_type=${ue_type}
#     [Return]     ${average_ul_tput}
# 
# "${Step}" Start and check UL traffic for actUlDataDmrsFdm at true for NSA
#     Log to console    \n"${Step}" Start and check UL traffic for actUlDataDmrsFdm to true\n
#     ${ul_tput_actUlDataDmrsFdm_true}    Start UL traffic and Capture BIP
#     ...    data_transfer_ul=${data_transfer_ul}
#     ...    Expected_Throughput_UL=${Expected_Throughput_UL}
#     ...     bip_log=${bip_log}
#     ...     attach_mode=5G_NSA
#     set test variable    ${ul_tput_actUlDataDmrsFdm_true}
# 
# "${Step}" Start and check UL traffic for actUlDataDmrsFdm at false for NSA
#     Log to console    \n"${Step}" Start and check UL traffic for actUlDataDmrsFdm to false\n
#     ${ul_tput_actUlDataDmrsFdm_false}    Start UL traffic and Capture BIP
#     ...    data_transfer_ul=${data_transfer_ul}
#     ...    Expected_Throughput_UL=${Expected_Throughput_UL}
#     ...     bip_log=${bip_log}
#     ...     attach_mode=5G_NSA
#     set test variable    ${ul_tput_actUlDataDmrsFdm_false}
# 
# "${Step}" Start and check UL traffic for actUlDataDmrsFdm at true for SA
#     Log to console    \n"${Step}" Start and check UL traffic for actUlDataDmrsFdm to true\n
#     ${ul_tput_actUlDataDmrsFdm_true}    Start UL traffic and Capture BIP
#     ...    data_transfer_ul=${data_transfer_ul}
#     ...    Expected_Throughput_UL=${Expected_Throughput_UL}
#     ...     bip_log=${bip_log}
#     ...     attach_mode=5G_SA
#     set test variable    ${ul_tput_actUlDataDmrsFdm_true}
# 
# "${Step}" Start and check UL traffic for actUlDataDmrsFdm at false for SA
#     Log to console    \n"${Step}" Start and check UL traffic for actUlDataDmrsFdm to false\n
#     ${ul_tput_actUlDataDmrsFdm_false}    Start UL traffic and Capture BIP
#     ...    data_transfer_ul=${data_transfer_ul}
#     ...    Expected_Throughput_UL=${Expected_Throughput_UL}
#     ...     bip_log=${bip_log}
#     ...     attach_mode=5G_SA
#     set test variable    ${ul_tput_actUlDataDmrsFdm_false}
# 
# "${Step}" Compare ul_tput of actUlDataDmrsFdm set to true or false
#     ${ul_tput_ratio}     Evaluate    round(${ul_tput_actUlDataDmrsFdm_true}/${ul_tput_actUlDataDmrsFdm_false},2)
#     Log to console    \nul_tput_actUlDataDmrsFdm_true=${ul_tput_actUlDataDmrsFdm_true}
#     Log to console    \nul_tput_actUlDataDmrsFdm_false=${ul_tput_actUlDataDmrsFdm_false}
#     Log to console    \nul_tput_ratio=${ul_tput_ratio}
#     Run keyword and ignore error    should be true    ${ul_tput_ratio}>=1.06
# 
# #------------------------------------------------Check result in BIP ------------------------------------------------#	
# "${Step}" Check uldata_puschreceivereq for actUlDataDmrsFdm at true
#     Log to console    \n"${Step}" Check uldata_puschreceivereq for actUlDataDmrsFdm at true\n
#     Check Ul_numOfDmrs in BIP for actUlDataDmrsFdm at true
# 	Check ulDmrsMappingType ulDmrsAddPos ulDmrsTypeApos in BIP for actUlDataDmrsFdm at true
# 	
# "${Step}" Check uldata_puschreceivereq for actUlDataDmrsFdm at false
#     Log to console    \n"${Step}" Check uldata_puschreceivereq for actUlDataDmrsFdm at false\n
#     Check Ul_numOfDmrs in BIP for actUlDataDmrsFdm at false
# 
# Check Ul_numOfDmrs in BIP for actUlDataDmrsFdm at true
#     [Arguments]    ${field_name}=uldata_puschreceivereq
#     #------------------------------------------------filter_expression_msc_less_5 ------------------------------------------------#
#     ${m}    set variable    UlData_puschReceiveReqGrant_t.mcs
#     ${filter_expression_msc_less_5}=     Catenate     ((${m}==0x00) || (${m}==0x01) || (${m}==0x02) || (${m}==0x03) || (${m}==0x04))
#     Load pcap file with filter    pcap_file=${bip_log_path}    field_name=${field_name}
#     ...    filter_expression=${filter_expression_msc_less_5}
#     ${Ul_numOfDmrs_msc_less_5}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
#     ...    pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
#     ${Ul_numOfDmrs_msc_less_5}    Remove Duplicates    ${Ul_numOfDmrs_msc_less_5}
#     Run Keyword And Continue On Failure     log to console    Ul_numOfDmrs_msc_less_5=${Ul_numOfDmrs_msc_less_5}
#     ${Ul_mcs_less_5}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
#     ...    pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.mcs
#     ${Ul_mcs_less_5}    Remove Duplicates    ${Ul_mcs_less_5}
#     Run Keyword And Continue On Failure     log to console    Ul_mcs_less_5=${Ul_mcs_less_5}
#     Run Keyword And Continue On Failure     Run keyword if     ${Ul_mcs_less_5} != []
#     ...    should be true    '${Ul_numOfDmrs_msc_less_5[0]}'=='2'    ELSE    should be true    ${Ul_numOfDmrs_msc_less_5}==[]
#     #------------------------------------------------filter_expression_msc_more_5 ------------------------------------------------#	
#     ${m}    set variable    UlData_puschReceiveReqGrant_t.mcs
#     ${filter_expression_msc_more_5}=     Catenate     ((${m}!=0x00) && (${m}!=0x01) && (${m}!=0x02) && (${m}!=0x03) && (${m}!=0x04))
#     Load pcap file with filter    pcap_file=${bip_log_path}    field_name=${field_name}
#     ...    filter_expression=${filter_expression_msc_more_5}
#     ${Ul_numOfDmrs_msc_more_5}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
#     ...    pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
#     ${Ul_numOfDmrs_msc_more_5}    Remove Duplicates    ${Ul_numOfDmrs_msc_more_5}
#     Run Keyword And Continue On Failure     log to console    Ul_numOfDmrs_msc_more_5=${Ul_numOfDmrs_msc_more_5}
#     ${Ul_mcs_more_5}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
#     ...    pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.mcs
#     ${Ul_mcs_more_5}    Remove Duplicates    ${Ul_mcs_more_5}
#     Run Keyword And Continue On Failure     log to console    Ul_mcs_more_5=${Ul_mcs_more_5}
#     Run Keyword And Continue On Failure     Run keyword if     ${Ul_mcs_more_5} != []
#     ...    should be true    '${Ul_numOfDmrs_msc_more_5[0]}'=='2'    ELSE    should be true    ${Ul_numOfDmrs_msc_more_5}==[]
# 
# Check ulDmrsMappingType ulDmrsAddPos ulDmrsTypeApos in BIP for actUlDataDmrsFdm at true
#     [Arguments]    ${field_name}=uldata_puschreceivereq
#     Load pcap file    pcap_file=${bip_log_path}    field_name=${field_name}
#     #------------------------------------------------check_ulDmrsMappingType------------------------------------------------#		
#     ${ulDmrsMappingType}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
#     ...    pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.ulDmrsMappingType
#     ${ulDmrsMappingType}    Remove Duplicates    ${ulDmrsMappingType}
#     Run Keyword And Continue On Failure     log to console    ulDmrsMappingType=${ulDmrsMappingType}    	
#     Run Keyword And Continue On Failure     should be true    '${ulDmrsMappingType[0]}'=='0'
#     #------------------------------------------------check_ulDmrsAddPos------------------------------------------------#		
#     ${ulDmrsAddPos}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
#     ...    pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.ulDmrsAddPos
#     ${ulDmrsAddPos}    Remove Duplicates    ${ulDmrsAddPos}
#     Run Keyword And Continue On Failure     log to console    ulDmrsAddPos=${ulDmrsAddPos}    	
#     Run Keyword And Continue On Failure     should be true    '${ulDmrsAddPos[0]}'=='1'
#     #------------------------------------------------check_ulDmrsTypeApos------------------------------------------------#		
#     ${ulDmrsTypeApos}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
#     ...    pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.ulDmrsTypeAPos
#     ${ulDmrsTypeApos}    Remove Duplicates    ${ulDmrsTypeApos}
#     Run Keyword And Continue On Failure     log to console    ulDmrsTypeApos=${ulDmrsTypeApos}    	
#     Run Keyword And Continue On Failure     should be true    '${ulDmrsTypeApos[0]}'=='3'
# 
# Check Ul_numOfDmrs in BIP for actUlDataDmrsFdm at false
#     [Arguments]    ${field_name}=uldata_puschreceivereq
#     Load pcap file    pcap_file=${bip_log_path}    field_name=${field_name}
#     ${Ul_numOfDmrs}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
#     ...    pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
#     ${Ul_numOfDmrs}    Remove Duplicates    ${Ul_numOfDmrs}
#     Run Keyword And Continue On Failure     log to console    Ul_numOfDmrs=${Ul_numOfDmrs}
#     Run Keyword And Continue On Failure     should be true    '${Ul_numOfDmrs[0]}'=='2' 