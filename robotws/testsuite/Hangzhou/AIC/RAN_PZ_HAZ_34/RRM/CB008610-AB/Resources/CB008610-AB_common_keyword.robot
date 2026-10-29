*** Settings ***

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB007199 in 5G22R3 program

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/log_cap.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/common_trans.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/PA.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/AIC_Counter_KPI.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

Library             taf.analyzer.pcap                     WITH NAME    pcap
Library             taf.sw.dcap.rd		                  WITH NAME	   DCAP
Library             CB008610-AB_variables.py
Variables           CB008610-AB_variables.py
*** Variables ***
${alias}        vDU
${UE_TYPE}      askey_vran20
${ttitrace_server_ip}    10.57.167.107
${TTI_username}    ute
${TTI_password}    iW_K#8.ute%A10h0m0ra
####### DCAP server part #######
#${DCAP_IP}   10.107.169.16
${DCAP_IP}   10.57.150.41
${DCAP_PORT}     443
#${DCAP_USER}    dcapuser
#${DCAP_PASSWORD}     Dcap@nokia
${DCAP_USER}    lab5g
${DCAP_PASSWORD}     Noki@pdz123!
#${prompt}    \\[dcapuser@dcap20\\s\\S+\\]\\$
#${DCAP_LOG_DIR}     /sharedvolume/ntracer/_data/
${DCAP_LOG_DIR}     /sharedvolume/uptracer/_data/
${DCAP_CP_LOG_DIR}     /sharedvolume/flowtracer5g/tmp/5G
${DCAP_UP_LOG_DIR}     /sharedvolume/udptracer/_data/
&{bts_vdu}      host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}    username=Nemuadmin    password=nemuuser    port=443
${TS_CASE_LOG_PATH}     /home/ute/casetest/8610_logs/TS_CASE_LOG/
*** Keywords ***
Make UE Attach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}
    #power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    reset_sol=reboot_ue
    ${attached}=    Run Keyword And Return Status    power_ue.Verify attach    ue_index=${ue_index}    ue_type=${ue_type}
    Run Keyword If    ${attached}==False    Run Keywords
    ...    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    AND
    ...    power_ue.Verify attach    ue_index=${ue_index}    ue_type=${ue_type}

Make UE Detach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

Start Device traffic
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${dltp_expected}=1000  ${data_send_dl}=1.5G    ${data_send_ul}=100M
	...             ${ultp_expected}=50    ${tp_direction}=ul    ${sleep_time}=1m
    Start traffic according to direction and protocol    tp_direction=${tp_direction}    data_send_ul=${data_send_ul}
    #${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    #Set test variable    ${handle}
    #${container_prefix}    vDU Get Container Name Prefix
	#sleep    60s
	#${local_l2rt_file}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    #...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
	#Set Suite Variable    ${local_l2rt_file}
    #${all_tput}=    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    #...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}
    #[Return]  ${all_tput[0]['average']}

Start traffic according to direction and protocol
    [Arguments]  ${data_send_dl}=1000M    ${data_send_ul}=60M     ${tp_direction}=both    ${protocol}=udp
    log to console      Start traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${data_send_ul}    duration=30    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${data_send_dl}    duration=30    ue_type=${ue_type}    protocol=${protocol}
	...    window=32M

Stop traffic according to direction and protocol
    [Arguments]  ${tp_direction}=both
    log to console      Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp

Modify HBTE Channel Vaules
    [Arguments]    ${value}=63    ${ru_id}=0    ${du_id}=0
    ${attenuation_channels}    Get Attenuation port    RU_id=${ru_id}    du_id=${du_id}
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{attenuation_channels}
        #${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
    END
    Log To Console    ${channels_to_modify}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
Adjust PA Value
    [Arguments]  ${Value}=25
     ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
    run keyword if    ${Value} == 25    Modify HBTE Channel Vaules    value=${Value}    ru_id=0    du_id=0
    ...    ELSE    Add 5 Per Adjustment    value=${Value}
Add 5 Per Adjustment
    [Arguments]  ${value}=0
    FOR    ${var}    IN RANGE    25    ${value}    5
        Modify HBTE Channel Vaules    value=${var}    ru_id=0    du_id=0
        sleep    2s
    END
Check DMRS time domain And FDM
    [Arguments]    ${pcap_filter}=/usr/bin/tshark -r {pcap_file} -Y "uldata_puschreceivereq" -T pdml
    ...    ${dmrstype}=0    ${Fdm_flag}=1    ${typeA_position}=2
    log to console    Get In BIP log
    pcap.load_pcap_file    command_template=${pcap_filter}    pcap_file=${local_file_path}
    ${PuschMappingType}=    pcap.get_field_value_by_xpath    xpath=.//UlData_puschReceiveReqGrant_t.ulDmrsMappingType
    ${typeA_pos}=    pcap.get_field_value_by_xpath    xpath=.//UlData_puschReceiveReqGrant_t.ulDmrsTypeAPos
    #${Dmrs_FDM}=    pcap.get_field_value_by_xpath    xpath=.//UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
    should be true    ${PuschMappingType[0]} == ${dmrstype}
    run keyword if    ${dmrstype}==0    should be true    ${typeA_pos[0]} == ${typeA_position}

Check 545 Related message
    [Arguments]    ${pcap_filter}=/usr/bin/tshark -r {pcap_file} -Y "uldata_puschreceivereq" -T pdml
    ...    ${dmrstype}=0    ${Fdm_flag}=1    ${typeA_position}=2
    log to console    Get In BIP log
    pcap.load_pcap_file    command_template=${pcap_filter}    pcap_file=${local_file_path}
    ${PuschMappingType}=    pcap.get_field_value_by_xpath    xpath=.//UlData_puschReceiveReqGrant_t.ulDmrsMappingType
    ${typeA_pos}=    pcap.get_field_value_by_xpath    xpath=.//UlData_puschReceiveReqGrant_t.ulDmrsTypeAPos
    #${Dmrs_FDM}=    pcap.get_field_value_by_xpath    xpath=.//UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
    should be true    ${PuschMappingType[0]} == ${dmrstype}
    run keyword if    ${dmrstype}==0    should be true    ${typeA_pos[0]} == ${typeA_position}
Check Related Counters
    ${du_counter_id_list}    Create List    M55302C06027    M55302C08027
    ${du_counter_values_final_list}    Create List
    FOR    ${du_counter_id}    IN    @{du_counter_id_list}
        ${du_counter_values_final_list}    Check Counter For vDU   counter_id=${du_counter_id}
        ...                                            dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
        ...                                            expected_value=0
        ...                                            get_number=3
    END

Start L1 Bip Log Capture
    log to console    \n start capture BIP log
    #Connect To vDU Node Interactively    pod_abbr=up   alias=${alias}
    ${biplogfullpath}    Begin BIP Log Capture    alias=${alias}    container=l2rt    port_name=l1biprt
    set test variable    ${biplogfullpath}
    #[Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}

Stop L1 Bip Log Capture
    log to console    \n Stop capture BIP log
    #Connect To vDU Node Interactively    pod_abbr=up   alias=${alias}
    ${local_file_path}=    Stop BIP Capture And Download
    ...    initial_log_path=${biplogfullpath}   alias=${alias}    container=l2rt
    set test variable    ${local_file_path}
    #[Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}

Create Bts On DCAP
    [Arguments]    ${bts_mr_id}=10572
    ${bts_info}    DCAP.get_all_bts_info
    #log to console    ${bts_info}
    ${bts_info_length}    get length    ${bts_info}
    FOR    ${index}    IN RANGE    ${bts_info_length}
        ${is_bts_exist}    set variable if    ${bts_info[${index}]['mr_bts_id']} == ${bts_mr_id}    true    false
        Exit For Loop If    '${is_bts_exist}'=='true'
    END
    run keyword if    '${is_bts_exist}' != 'true'    DCAP.create_bts    host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...    ELSE    log to console    message=the specific bts is exist
Start TTI Trace Capture Via DCAP Basic
    DCAP.connect_to     host=${DCAP_IP}    port=${DCAP_port}     username=dcapuser
    ...     password=dcapadmin!     secure=True
    ${vdu_custom_profile}=     Create List     L2Ps_Component
    ${gnb_custom_profile}=     Create List     cp_5g
    Create Bts On DCAP
    ${output}    DCAP.start_trace     bts=${bts_vdu}     wait_for_activation=${True}
    ...     control_plane_interface=${True}     vdu_custom_profile=${vdu_custom_profile}
#    ...    gnb_custom_profile=${gnb_custom_profile}
    Log    ${output}[id]
    set suite variable    &{output}
Stop TTI Trace Capture Via DCAP Basic
    DCAP.stop_trace    trace_id=${output}[id]
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${output}[id]    target_dir=${TS_CASE_LOG_PATH}
    csn.Connect to    hostname=${ttitrace_server_ip}    username=${TTI_username}    password=${TTI_password}    alias=ute
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    csn.Execute   command=unzip ${downloaded_emil_file_path} -d ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    csn.Execute   command=rm ${downloaded_emil_file_path}    connection=ute
    ${downloaded_emil_file}=    csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp | grep .pcap    connection=ute
    ${downloaded_emil_file}   Strip String   ${downloaded_emil_file}    characters=\r\n
    ${downloaded_emil_file_path}=    csn.Execute   command=find ${TS_CASE_LOG_PATH}dcap_tmp -name ${downloaded_emil_file}    connection=ute
    ${downloaded_emil_file_path}   Strip String   ${downloaded_emil_file_path}    characters=\r\n
    ${downloaded_emil_file_path}  create list  ${downloaded_emil_file_path}
    set suite variable    ${downloaded_emil_file_path}
Start Capture Wireshark F1 On CU
    log to console    Start tcpdump on F1 interface
    ${handle} =    Begin Wireshark F1 Log On CU
    [Return]  ${handle}
Stop Capture Wireshark F1 On CU
    [Arguments]  ${handle}
    log to console    Stop tcpdump on F1 interface
    ${local_f1_file} =    End Wireshark F1 Log On CU    handle=${handle}   local_pcap_file_name=f1pcapfile.pcap
    Set Test Variable    ${local_f1_file}
Validate And ActivateDelta Plan
    [Arguments]  ${plan_id}    ${uni_id}    ${delta_plan_name}
    Validate Delta Plan By REST   ${plan_id}
    ${scf_path}  Get A Directory  SCF
    ${delta_filename}  Set Variable   add_route_${uni_id}.xml
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_plan_name}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=True
Add NRULCLPC_PROFILE
    [Arguments]  ${plan_id}    ${Parent_MO_Dn}    ${MO_Name}
    ${uni_id}   Get Unique Id
    ${scf_path}  Get A Directory  SCF
    ${scf_full_path}=  vdu.Get Current Plan File  ${scf_path}  full_scf_${uni_id}.xml  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${MO_Exist}    scf.Is Object In Scf    ${Parent_MO_Dn}/NRULCLPC_PROFILE-0
    Run Keyword If    "${MO_Exist}" == "False"    Add Delta Plan MO
    ...    plan_id=${plan_id}    parent_mo_dn=${Parent_MO_Dn}    mo_name=${MO_Name}
    ${clpcPucch_list}    Create Dictionary   /clpcPucch=${EMPTY}
    ${clpcPusch_list}    Create Dictionary   /clpcPusch=${EMPTY}
    ${NRULCLPC_PROFILE_para}=   create dictionary
    ...    clpcPucch/0/sinrAveMeasSamples=10
    ...    clpcPucch/0/sinrThresholdIndex=triplet 1 (-2, 0, +1)
    ...    clpcPucch/0/tIntervalSinrUpd=100ms
    ...    clpcPucch/0/tTpcPenalty=50
    ...    clpcPucch/0/targetSinr=4
    ...    clpcPusch/0/interferAveMeasPeriod=0dot1s
    ...    clpcPusch/0/maxTargSinr=10
    ...    clpcPusch/0/minTargSinr=-10
    ...    clpcPusch/0/refPathloss=134
    ...    clpcPusch/0/sinrAveMeasSamples=10
    ...    clpcPusch/0/sinrThresholdIndex=triplet 1 (-2, 0, +1)
    ...    clpcPusch/0/tIntervalSinrUpd=100ms
    ...    clpcPusch/0/tTpcPenalty=50
    ...    clpcPusch/0/targetSinrOffset=0
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${Parent_MO_Dn}/NRULCLPC_PROFILE-0
    ...  updated_paras_dict=${clpcPucch_list}   operation=add
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${Parent_MO_Dn}/NRULCLPC_PROFILE-0
    ...  updated_paras_dict=${clpcPusch_list}   operation=add
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${Parent_MO_Dn}/NRULCLPC_PROFILE-0
    ...    updated_paras_dict=${NRULCLPC_PROFILE_para}   operation=add
Check TTI logs
    [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}=UL
    ${csv_path}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
    #${ul_csv_path}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    UL
    ${tpc_list}    TTI_Trace.get_ulTpc_Or_dlTpc_Tpc    file_path=${csv_path}    direction=${direction}
    #${Pathloss_list}    TTI_Trace.get_ulLaPhr_Pathloss    file_path=${ul_csv_path}
    #${LaPhr_list}    TTI_Trace.get_ulLaPhr_sfn    file_path=${ul_csv_path}
    #${Pathloss_Status}    Check_Pathloss_Status    input_list=${Pathloss_list}    expect_diff=2    flag=${flag}
    ${TPC_Status}    Check_TPCcommand_Trend    TPC_value_list=${tpc_list}    tolerance=0.4
    #${LaPhr_result}    Check_LaPhr_Sfn_cycle    LaPhr_list=${LaPhr_list}    tolerance=0.6
    #Run Keyword And Continue On Failure    Should Be Equal    ${Pathloss_Status}     ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${TPC_Status}    ${True}
    #Run Keyword And Continue On Failure    Should Be Equal    ${LaPhr_result}    ${True}
Decode TTI trace
    ${vdu_version}=    Get Running Build Number
    set test variable    ${vdu_version}
    ${local_dl_csv}  ${local_ul_csv}=    Decoder TTITrace With Linux Server     ${ttitrace_server_ip}
    ...    ${TTI_username}  ${TTI_password}  ${vdu_version}  ${downloaded_emil_file_path}
    set test variable    ${local_dl_csv}
    set test variable    ${local_ul_csv}

Precondition
    [Arguments]
    Connect To vDU Node Interactively    pod_abbr=up   alias=${alias}
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    vDU Login
    Get Max Plan Number And Delete One If Reach Max Number
    &{modify_dict}    Create Dictionary
    ${uni_id}   Get Unique Id
	${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
	${plan_id}    ${action_id}    Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
    FOR    ${para}    IN    @{Para_CB008072_Common}
        ${value}=    Online Get VDU Parameter Value    mo_dn=${para['dist_name']}    para_name=${para['p_name']}
        run keyword if    "${value}" != "${para['new_value']}"    run keywords
        ...    clear_dictionary    dict=${modify_dict}    AND
        ...    Set To Dictionary    ${modify_dict}    ${para['p_name']}    ${para['new_value']}    AND
        ...    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${para['dist_name']}   updated_paras_dict=${modify_dict}   operation=replace
    END
    run keyword if    &{modify_dict}!= &{Empty}    Validate And ActivateDelta Plan
	...    plan_id=${plan_id}    uni_id=${uni_id}    delta_plan_name=${delta_plan_name}
    Adjust PA Value
    [Teardown]    Run Keyword And Ignore Error    vDU Logout
