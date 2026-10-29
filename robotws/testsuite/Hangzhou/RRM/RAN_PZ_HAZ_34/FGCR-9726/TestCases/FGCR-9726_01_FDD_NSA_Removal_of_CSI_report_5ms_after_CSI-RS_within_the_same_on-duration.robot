# # 
# #     [Documentation]
# #     ...   author: Liu Ning
# #     ...   contact: ning.4.liu@nokia-sbell.com
# #     ...   squad group: MMW_SG3
# #     ...   Feature FGCR-9726 in 5G21A program
# # 
# # *** Settings ***
# # 
# # Suite Setup
# # Suite Teardown
# # Test Timeout       60 min
# # 
# # Force Tags    CRT_TRUNK    CRT_21B    CRT_22R1
# # ...    PY36
# # 
# # 
# # Resource		./FGCR-9726_PM_Counter.robot   
# # Resource		../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
# # Resource        taf/rfrl/common_resources/robot/TTI_Trace.robot
# # Resource    	testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
# # Resource    	testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# # Resource        taf/rfrl/common_resources/robot/connection_alias_store.robot
# # Resource    	testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# # Resource    	testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
# # 
# # Library	    	taf.sbts.oam.coam.admin   WITH NAME   DU
# # Library 		taf.ue  WITH NAME   ute_ue
# # Library    		OperatingSystem
# # 
# # *** Variables ***
# # ####${Given_cell_index}    ${1} 
# # ${Given_cell_index}    ${empty}
# # ${UE_TYPE}    askey
# # #${UE_TYPE}    ${tl.ues[0].capabilities[0]}
# # ###${UE_TYPE}    samsung
# # ${DL_traffic}    300M
# # ${UL_traffic}    100M
# # 
# # ${TS_CASE_LOG_PATH}    /home/ute/casetest/TS_CASE_LOG_PATH/
# # 
# # ${DU_OAM_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# # #${CU_WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# # ${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # ${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # ${DU_OAM_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# # ${DU_Connection}     GNB_OAM
# # ${mrbts_ID_enb}    ${tl.enbs[0].instance_id}
# # 
# # 
# # *** Test Cases ***
# # [1]FGCR-9726_01_FDD_NSA_Removal_of_CSI_report_5ms_after_CSI-RS_within_the_same_on-duration
# #     [Documentation]    *****************
# #     ...    Check FGCR-9726 function.
# #     ...    ******************
# #     ...    *******************
# #     [Tags]    CRT_TRUNK    ning.4.liu@nokia-sbell.com
# #     [Setup]
# #     [Teardown]    Case teardown	
# # 	Step1:Check cell status and information
# # 	Step4:UE start traffic when DRX is activated
# # 	Step2:Check PM counter M55308C11001 and M55308C11002 and M55116C00014 when UE attach
# #     
# # 
# # 
# # 
# # *** Keywords ***
# # 
# # Step1:Check cell status and information
# #     log to console         Step1:Check cell on air
# #     Connect to gnb coam via ssl
# # 	Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air    connection=${DU_Connection}
# # 	Verify all cells should be onair    connection=${DU_Connection}
# # 	&{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
# # 	${cell_index_list}    Get Dictionary Keys    ${NR_CELL_ID_MAPPING}
# # 	${cell_index_length}    get length    ${cell_index_list}
# #     Set Suite Variable    ${cell_index_list} 
# #     ${cell_index_list_all}    Copy List    ${cell_index_list}
# #     Set Suite Variable    ${cell_index_list_all}    	
# # 	log to console     cell list is ${cell_index_list_all}
# #     #####${cell_group_list0}    Get Dictionary Values     ${NR_CELL_ID_MAPPING}    cell_group_id
# # 	#####${cell_index_length}    get length     ${cell_group_list0}
# # 	#####${cell_group_list}    Create List
# # 	#####:For    ${index}    IN RANGE    ${cell_index_length}
# # 	#####\    Keep In Dictionary    ${cell_group_list0[${index}]}     cell_group_id
# # 	#####:For    ${index}    IN RANGE    ${cell_index_length}
# #     #####\    ${cell_group_index}    Get Dictionary Values    ${cell_group_list0[${index}]}    cell_group_id
# #     #####\    Append to list   ${cell_group_list}    ${cell_group_index[${0}]}	
# # 	#####Set Suite Variable    ${cell_group_list}
# # 	#####log to console    cell group index is ${cell_group_list}
# #     Run keyword if    '${Given_cell_index}'=='${empty}'    Randomly select cell index    cell_index_list=${cell_index_list}
# # 	
# #     ${cell_group_list0}    Get From Dictionary     ${NR_CELL_ID_MAPPING}    ${Given_cell_index}
# # 	${cell_group_index}    Get From Dictionary     ${cell_group_list0}    cell_group_id
# # 	@{cell_group_index_list}        create list    ${cell_group_index}
# #     Set Suite Variable    ${cell_group_index}    
# # 	Set Suite Variable    ${cell_group_index_list}  
# # 	log to console    cell group index list is ${cell_group_index_list}
# #     Remove Values From List     ${cell_index_list}   ${Given_cell_index}
# # 	${locked_cell_list}    Copy List    ${cell_index_list}
# # 	Set Suite Variable    ${locked_cell_list}    
# #     log to console    locked cell is ${locked_cell_list}	
# # 	${cell_locked_length}    get length    ${locked_cell_list}
# #     Set Suite Variable    ${cell_locked_length}   
# #     
# # 	log to console     start to modify the parameters       	
# # 	Modify the parameters related with PM counter
# # 	Wait until Keyword Succeeds   5 min   5s    Modify the parameters related with DRX    
# # 	...    cell_group_list=${cell_group_index_list}   Given_cell_index=${Given_cell_index} 	
# # 	
# # 	Run Keyword And Ignore Error    DU.teardown      connection=${DU_Connection} 
# # 
# #    	Modify values in hbte for cell    
# # 	...    cell_index_list=${cell_index_list_all}    Given_cell_index=${Given_cell_index}    locked_cell_list=${locked_cell_list}
# # 
# #     ${defaultLnRelGnbCellId_value}=    Set Variable If
# #     ...    ${Given_cell_index}==1    1
# #     ...    ${Given_cell_index}==2    2
# #     ...    ${Given_cell_index}==3    5
# # 
# #     Connect and Modify the parameter on enblte    dist_name=MRBTS-${mrbts_ID_enb}/LNBTS-${mrbts_ID_enb}/LNCEL-1
# #     ...    parameter=defaultLnRelGnbCellId    value=${defaultLnRelGnbCellId_value}
# # 
# # 	####DU.connect_to    bts_host=${DU_OAM_IP}    bts_port=${443}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
# #     ####...   name=${DU_Connection}
# # 	####Run keyword if    ${cell_locked_length}!=0    Run Keyword And Continue On Failure    Lock cell in classical GNB    
# # 	####...    locked_cell_list=${locked_cell_list}    cell_locked_length=${cell_locked_length}    connection=${DU_Connection}    
# # 	
# #    [Teardown]    Run Keyword And Ignore Error    DU.teardown      connection=${DU_Connection} 
# # 
# # Step2:Check PM counter M55308C11001 and M55308C11002 and M55116C00014 when UE attach
# #     log to console         Step2:Check PM counter M55308C11001 and M55308C11002 and M55116C00014 when UE attach
# #     log to console     start to make UE attach
# #     Run Keyword And Ignore Error     start to capture BIP log
# # 
# # 	Make UE attach    UE_TYPE=${UE_TYPE}
# # 	Run Keyword And Ignore Error    Check CSI measurement is reported in DRX on duration when UE attach
# # 
# #     Run Keyword And Ignore Error    stop to capture BIP log
# # 
# #     log to console     start to get the counter
# # 	Wait until Keyword Succeeds   5 min   5s    Connect to DU with OAM IP
# # 	Run Keyword And Continue On Failure     Get PM counter from GNB
# #   
# # 	[Teardown]    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
# # 
# # Check CSI measurement is reported in DRX on duration when UE attach
# #     log to console      Check CSI measurement is reported in DRX on duration when UE attach
# # 	####Make UE attach    UE_TYPE=${UE_TYPE}
# # 	Sleep    1s
# #     Start TTI trace log capturing
# #     Sleep    2s
# #     Stop TTI trace log capturing
# # 	log     ${TS_CASE_LOG_PATH}
# #     ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
# # 
# #     #####check tti trace csiSrReportData    UL_DL_csv_file_path_dict=${UL_DL_csv_file_path_dict}
# # 	
# #     #####[Teardown]   Run Keyword And Continue On Failure    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
# # 
# # Step4:UE start traffic when DRX is activated
# #     log to console      Step4:UE start traffic when DRX is activated    
# # 
# #     Run Keyword And Ignore Error     start to capture BIP log
# #     Log To Console    \n ### Prepare UE ###
# #     power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}    reset_sol=ue_reboot
# #     Run Keyword And Continue On Failure    Make UE attach    UE_TYPE=${UE_TYPE}
# # 	Sleep    1s
# #     Run Keyword And Continue On Failure    UE Start traffic    UE_TYPE=${UE_TYPE}
# #     Run Keyword And Ignore Error    Check CSI measurement is reported in DRX on duration when UE attach
# # 	Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
# # 	Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
# # 	Run Keyword And Ignore Error    stop to capture BIP log
# #     [Teardown]   run keyword and ignore error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
# # 	
# # Make UE attach
# #     [Arguments]     ${UE_TYPE}
# # 
# #     Log To Console    \n ### UE Attach ###
# #     ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
# #     ###${status}    run keyword and return status    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
# # 	${status}    run keyword and return status    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed_0}    4G_check=False
# # 
# # 
# # UE Start traffic
# #     [Arguments]     ${UE_TYPE}
# #     Log To Console    \n ###UE Start traffic and check TP ###
# #     power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${DL_traffic}    duration=60s
# #     power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=${UL_traffic}    duration=60s
# #     sleep  1s
# # 	power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=${5}
# #     power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=${2}
# # 
# # start to capture BIP log
# #     Connect to Common Unit Master
# #     Precondition for bip capture with gnbMirroring scripts
# #     Bip Capture with gnbMirroring scripts
# #     [Teardown]   run keyword and ignore error    Csn.Disconnect    connection=ASIK Master
# # 
# # stop to capture BIP log
# # 	Connect to Common Unit Master
# # 	${list_log_path_local}    run keyword and ignore error    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
# #     set test variable    ${bip_log_path}    @{list_log_path_local}[0]
# #     [Teardown]   run keyword and ignore error    Csn.Disconnect    connection=ASIK Master
# # 
# # Lock cell in classical GNB
# #     [Arguments]     ${locked_cell_list}    ${cell_locked_length}    ${connection}
# #     Log To Console    \n ### start to lock cells ###  
# # 	FOR    ${index}    IN RANGE    ${cell_locked_length}
# #         run keyword and continue on failure    Perform cell lock via rest api    cell_idx=${locked_cell_list}[${index}]
# #        ...                                                                       connection=${DU_Connection}
# # 	END
# # Randomly select cell index
# #     [Arguments]     ${cell_index_list}        
# #     ${Given_cell_index}      BuiltIn.Evaluate    random.choice(${cell_index_list})    random
# #     Set Suite Variable    ${Given_cell_index} 
# # 
# # Unlock cell in classical GNB
# #     [Arguments]     ${locked_cell_list}    ${cell_locked_length}    ${connection}
# #     Log To Console    \n ### start to unlock cells ###  
# # 	FOR    ${index}    IN RANGE    ${cell_locked_length}
# #         run keyword and continue on failure    Perform cell unlock via rest api    cell_idx=${locked_cell_list}[${index}]       
# # 	   ...                                                                       connection=${DU_Connection}
# # 	END
# # check tti trace csiSrReportData
# #     [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}=DL
# #     ${path}    get from dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
# #     ${ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
# #     ${rnti_list}    ${ue_rnti_number}   get_multi_rntis_from_tti_trace_19b    path=${ul_path}
# #     ${sfn_list}    ${sfn_diff_list}    get_csisrreportdata_sfn_by_rnti_19b    file_path=${path}    rnti=${rnti_list[-1]}
# #     check csi report periodically    sfn_diff_list=${sfn_diff_list}
# # 
# # 
# # 
# # check csi report periodically
# #     [Arguments]    ${sfn_diff_list}
# #     ${sfn_diff_4_num}    evaluate  ${sfn_diff_list}.count(4)
# #     log    ${sfn_diff_4_num}
# #     ${sfn_diff_length}    get length    ${sfn_diff_list}
# #     ${ratio}    evaluate    float(${sfn_diff_4_num})/float(${sfn_diff_length})
# #     should be true    ${ratio}>=0.95
# # 
# # Case teardown
# #    ###Run Keyword And Continue On Failure    DU.connect_to    
# # 	###...   bts_host=${DU_OAM_IP}    bts_port=${443}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
# #     ###...   name=${DU_Connection}
# #    ###Run Keyword And Continue On Failure    Unlock cell in classical GNB    
# # 	###...    locked_cell_list=${locked_cell_list}    cell_locked_length=${cell_locked_length}    connection=${DU_Connection}
# #    Run Keyword And Ignore Error    DU.teardown      connection=${DU_Connection}
# #    Run Keyword And Ignore Error    Run    ps -ef|grep admin | awk '{print $2}' |xargs kill -9
# # 
# # Modify HBTE Channel Vaules
# #     [Arguments]    ${value}=63    ${ru_id}=0    ${gnb_id}=0
# #     ${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
# #     attenuator.setup_attenuator
# #     ...    ip_addr=${ATTENUATOR_ADDR}
# #     ...    port=${attenuation_port}
# #     ...    attenuation_port_numbers=${channels}
# #     ...    vendor=HBTE
# #     ${channels_to_modify}    Create Dictionary
# #     FOR    ${channel}    IN    @{channels}
# #         ${channel}    Convert To String    ${channel}
# #         Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
# #     END
# #     Log To Console    ${channels_to_modify}
# #     gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}
# # 
# # 
# # 
# # Modify values in hbte for cell
# #     [Arguments]    ${cell_index_list}    ${Given_cell_index}    ${locked_cell_list}
# # 	#####${Given_cell_list_index} is consistent with index in RU list,so please make sure RU index in init.py match the sequence in GNB
# #     ${Given_cell_list_index}    Get Index From List    ${cell_index_list}    ${Given_cell_index}
# #     
# # 	#####gnb_id is item index of BTS in init.py 	
# #     Modify HBTE Channel Vaules    value=0    ru_id=${Given_cell_list_index}    gnb_id=0
# # 	log to console    start to add the value attenuation 
# # 	${cell_locked_length}    get length    ${locked_cell_list}
# #     Set Suite Variable    ${cell_locked_length}    	
# #    	Run keyword if    ${cell_locked_length}!=0    Run Keyword And Continue On Failure    Loop modify values in hbte   
# # 	...    cell_index_list=${cell_index_list}    locked_cell_list=${locked_cell_list}    
# # 
# # Loop modify values in hbte 
# #     [Arguments]    ${cell_index_list}    ${locked_cell_list}    
# # 	FOR    ${list_item}    IN    @{locked_cell_list}
# #         ${cell_index_in_list}    Get Index From List    ${cell_index_list}    ${list_item}
# #         Modify HBTE Channel Vaules    value=60    ru_id=${cell_index_in_list}     gnb_id=0
# # 	END
# # 
