*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes



Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Test Timeout    90 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${BBMOD_Runtime}   /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1
${nrcellDN_Runtime}   /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1
&{syslog_filter_conditions}      line_regex=FaultId: 8101   element_regex=.*
&{analysis_dict_syslog_1}        filter_conditions=${syslog_filter_conditions}
*** Test Cases ***
Case_Precondition
    Case Precondition For CommonET
#    Case Precondition For TMO
#    Case Precondition For RJIO
#   Airphone Operation  edaemon_egate_setup  gnb  tag=CommonET

CNI129090_SR_TC01_DL_IQ_Data_Capture_MSG2_Failure_single_UE
    [Tags]    QC_XXX      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario to test L1-IQ can be saved while msg2 not scheduled.
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...    3. Test Case Steps:
    ...       step1. update the RD parameters
    ...       step2. UE attached to SA with Rach Failure
    ...    4. Expert Result:
    ...       a. UE attaced failed
    ...       b. DL-IQ can be saved while msg2 not scheduled.
    ADMIN Set RAD debug parameters
    Configure Uplane L1 Iq Data For 5G
    Start DCAP logs   log_type=bip
    sleep  25s
    Get Required Logs    start   syslog   gnb
    Introduce msg3 rach failure
    UE Register with Rach Failure   ue_id=1
    [Teardown]    TC01 Teardown

CNI129090_SR_TC02_DL_IQ_Data_Capture_MSG2_Failure_multi_UEs
    [Tags]    QC_XXX       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario to test L1-IQ can be saved while msg2 not scheduled.
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...    3. Test Case Steps:
    ...       step1. update the RD parameters
    ...       step2. UE attached to SA with Rach Failure
    ...    4. Expert Result:
    ...       a. multi UE attaced failed
    ...       b. DL-IQ can be saved while msg2 not scheduled.
    ADMIN Set RAD debug parameters
    Configure Uplane L1 Iq Data For 5G
    Start DCAP logs   log_type=bip
    sleep  25s
    Get Required Logs    start   syslog   gnb
    Introduce msg3 rach failure   ue_id=1-3
    UE Register with Rach Failure   ue_id=1-3
    [Teardown]    TC02 Teardown

CNI129090_SR_TC03_DL_IQ_Data_Capture_Failure_wrong_scenario
    [Tags]    QC_XXX       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario to test L1-IQ can not be saved while msg2 not scheduled.
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...    3. Test Case Steps:
    ...       step1. update the RD parameters with wrong beamid
    ...       step2. UE attached to SA with Rach Failure
    ...    4. Expert Result:
    ...       a. multi UE attaced failed
    ...       b. DL-IQ can not be saved while msg2 not scheduled.
    Start DCAP logs   log_type=bip
    sleep  25s
    Introduce msg3 rach failure   ue_id=1   missed_ra_resp_num=10
    UE Register with Rach Failure without check   ue_id=1
    Introduce exit test mode
    UE Register   ue_id=2
    [Teardown]    TC03 Teardown

CNI129090_SR_TC04_DL_IQ_Data_Capture_Failure_not_consecutive_preambles
    [Tags]    QC_XXX       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario to test L1-IQ can not be saved while msg2 not scheduled.
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...    3. Test Case Steps:
    ...       step1. update the RD parameters with wrong beamid
    ...       step2. UE attached to SA with Rach Failure
    ...    4. Expert Result:
    ...       a. UE attaced failed with un consecutive preamble
    ...       b. DL-IQ can not be saved while msg2 not scheduled.
    ADMIN Set RAD debug parameters
    Configure Uplane L1 Iq Data For 5G
    Start DCAP logs   log_type=bip
    sleep  25s
    Get Required Logs    start   syslog   gnb
    Introduce skip msg1   ue_id=1   missed_ra_resp_num=100  min=120   max=360
    UE Register with Rach Failure without check   ue_id=1
    [Teardown]    TC04 Teardown

CNI129090_SR_TC05_DL_IQ_Data_Capture_single_UE
    [Tags]    QC_XXX      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario to test L1-IQ can be saved while msg2 not scheduled.
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...    3. Test Case Steps:
    ...       step1. update the RD parameters
    ...       step2. UE attached to SA with Rach Failure
    ...    4. Expert Result:
    ...       a. UE attaced failed
    ...       b. DL-IQ can be saved while msg2 not scheduled.
    Start DCAP logs   log_type=bip
    sleep  25s
    Get Required Logs    start   syslog   gnb
    UE Register   ue_id=1
    PDU Session Setup   ue_id=1
    Start data traffic in egate   ue_id=1   direction=dl  mbps=10
    Start data traffic in egate   ue_id=1   direction=ul  mbps=10
    Check Traffic Status   ue_id=1
    Introduce msg3 rach failure   ue_id=2
    UE Register with Rach Failure   ue_id=2
    [Teardown]    TC05 Teardown

*** Keywords ***
Case Precondition For CommonET
    log to console    Case Precondition
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Case Precondition   operation=env_setup_sansa  tag=CommonET
    start_dcap_controller_common
    OperatingSystem.Run     DCAP_Basic_controller start

Case Precondition For RJIO
    log to console    Case Precondition
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Case Precondition   operation=env_setup_sa  tag=RJIO   customer=RJIO
    start_dcap_controller_common
    OperatingSystem.Run     DCAP_Basic_controller start

Case Precondition For TMO
    log to console    Case Precondition
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Case Precondition   operation=env_setup_sansa  tag=TMO   customer=TMO
    start_dcap_controller_common
    OperatingSystem.Run     DCAP_Basic_controller start

Case Precondition
    [Arguments]   ${operation}=env_setup_sansa   ${tag}=CLOUD_5G_I_LO_AP_LO   ${customer}=${NONE}
    Airphone Operation  edaemon_egate_setup  gnb  tag=${tag}
    Airphone Operation  ${operation}  gnb  tag=${tag}  customer=${customer}

UE Register with Rach Failure
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1   ${pass_regexp}=T300 expiration
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=${pass_regexp}

UE Register with Rach Failure without check
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1   ${pass_regexp}=none
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=${pass_regexp}

UE Register
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1   ${pass_regexp}=UE now in NG RM Registered state
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=${pass_regexp}

PDU Session Setup
    [Arguments]    ${ue_id}=1  ${gw}=1  ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gw}    pass_regexp=${pass_regexp}

Start data traffic in egate
    [Arguments]   ${ue_id}=${EMPTY}   ${direction}=ul  ${protocol}=udp   ${ack_mode}=off   ${trf_id}=1  ${qfi}=1
    ...   ${cl_trf_stats}=on   ${mbps}=10   &{kwargs}
    ${command}   Catenate
    ...   trf_data_start ue=${ue_id} dir=${direction} trf_id=${trf_id}
    ...   protocol=${protocol} ack_mode=${ack_mode} cl_trf_stats=${cl_trf_stats}
    ...   pdu=1 qfi=${qfi} mbps=${mbps}
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${command}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Check traffic status
    [Arguments]    ${ue_id}=1   ${pdu}=1
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=1 dir=dl    pass_regexp=Parameter
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=1 dir=ul    pass_regexp=Parameter

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

Introduce msg3 rach failure
    [Arguments]    ${ue_id}=1   ${missed_ra_resp_num}=10
	${cont_testmode}	Set Variable    cont_res_testmode_nr profile_id=1 missed_ra_resp=${missed_ra_resp_num}
	${ue_testmode}		Set Variable	ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=activate profile_id=1
	ute_wtssim.Execute Egate Command    ${cont_testmode}    timeout=60s
	ute_wtssim.Execute Egate Command    ${ue_testmode}    timeout=60s

Introduce skip msg1
    [Arguments]    ${ue_id}=1   ${missed_ra_resp_num}=100  ${min}=20   ${max}=100
	${cont_testmode}		Set Variable
    ...  cont_res_testmode_nr profile_id=1 missed_ra_resp=${missed_ra_resp_num} min_slots_next_prach=${min} max_slots_next_prach=${max}
	${ue_testmode}		Set Variable	ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=activate profile_id=1
	ute_wtssim.Execute Egate Command    ${cont_testmode}    timeout=60s
	ute_wtssim.Execute Egate Command    ${ue_testmode}    timeout=60s

Introduce exit test mode
    [Arguments]    ${ue_id}=1
	${ue_testmode}		Set Variable	ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=deactivate profile_id=1
	${cont_testmode}    Set Variable    cont_res_testmode_nr profile_id=1 delete=true
	ute_wtssim.Execute Egate Command    ${ue_testmode}    timeout=60s
	ute_wtssim.Execute Egate Command    ${cont_testmode}    timeout=60s

Start DCAP logs
    [Arguments]     ${log_type}=tti    ${nrCells}=NRCELL_R-1
    ${dcap_argument}   Create Dictionary   nrCells=${nrCells}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start   log_type=${log_type}   product_type=gnb   bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

Stop DCAP logs
    [Arguments]     ${log_type}=tti
    ${local_file_path}    Log Collection    stop_and_download    log_type=${log_type}    product_type=gnb    bts_index=${0}    cudu_index=${0}

Create wts folder if not exists
     Run Keyword If    not os.path.exists("${wts_folder}")   Run  cd /opt;sudo mkdir wts
     ${wts_folder}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
     ${wts_folder_list}    Split String    ${wts_folder}    /
     ${wts_up_folder}    Generate wts path
     Run  cd ${wts_up_folder};tar -czvf latest.tar ${wts_folder_list[-1]}/
     ${exist_latest}   Run   cd ${wts_up_folder};ls latest.tar
     Run keyword if  "${exist_latest}"=="latest.tar"    Run  cd ${wts_up_folder};sudo cp latest.tar /opt/wts
     Run keyword if  "${exist_latest}"=="latest.tar"    Run  cd ${wts_up_folder};sudo rm latest.tar
     Run  cd /opt/iphy;rm -f latest
     ${exist_latest}   Run   cd /opt/wts;ls latest.tar
     Run keyword if  "${exist_latest}"=="latest.tar"   Run  cd /opt/wts;sudo tar -xzvf latest.tar
     Run keyword if  "${exist_latest}"=="latest.tar"   Run  cd /opt/wts;sudo rm latest.tar
     Run  cd /opt/wts;sudo mv ${wts_folder_list[-1]}/ latest/
     Run  cd /opt/iphy;ln -s /opt/wts/latest latest

Generate wts path
    ${wts_folder}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    ${wts_folder_list}    Split String    ${wts_folder}    /
    ${wts_folder}    Set Variable    /opt/iphy/${wts_folder_list[-2]}
    [Return]    ${wts_folder}

#ADMIN Set RAD debug parameters
#    wait until keyword succeeds   3x   1min    COAM_Admin.Login
#    &{rad_parameter_1}    create dictionary   name=rdAbnormalEventRachMsg2FailureEnable    value=1
#    &{rad_parameter_2}    create dictionary   name=rdAbnormalEventRachMsg2FailureInitialTa    value=0
#    &{rad_parameter_3}    create dictionary   name=rdAbnormalEventRachMsg2FailureMonitoringPeriodicity    value=120
#    &{rad_parameter_4}    create dictionary   name=rdAbnormalEventRachMsg2FailureMonitoringBeamId    value=0
#    &{rad_parameter_5}    create dictionary   name=rdAbnormalEventRachMsg2FailureMonitoringSubCellId    value=0
#    &{rad_parameter_6}    create dictionary   name=rdAbnormalEventRachMsg2FailureDetectionsThreshold    value=3
#    &{rad_parameter_5}    create dictionary   name=rdAbnormalEventTriggerOnlineEnable    value=2
#    &{rad_parameter_6}    create dictionary   name=rdAbnormalEventTriggerNumber    value=100
#    @{rad_parameters}   Create List    ${rad_parameter_1}   ${rad_parameter_2}  ${rad_parameter_3}
#    ...    ${rad_parameter_4}   ${rad_parameter_5}   ${rad_parameter_6}  ${rad_parameter_7}  ${rad_parameter_8}
#    coam.set_multiple_rad_debug_parameters
#    ...    domain=L2PS
#    ...    persistency=NotPersistent
#    ...    rad_parameters=${rad_parameters}
#    ...    connection=COAM
#    [Teardown]  Run Keyword And Ignore Error    COAM_Admin.Logout

ADMIN Set RAD debug parameters
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    &{rad_parameter_0}    create dictionary   name=rdAbnormalEventTriggerOnlineEnable    value=2
    &{rad_parameter_1}    create dictionary   name=rdAbnormalEventRachMsg2FailureMonitoringPeriodicity    value=120
    &{rad_parameter_2}    create dictionary   name=rdAbnormalEventRachMsg2FailureDetectionsThreshold    value=3
    &{rad_parameter_3}    create dictionary   name=rdAbnormalEventRachMsg2FailureEnable    value=true
    @{rad_parameters}   Create List   ${rad_parameter_0}  ${rad_parameter_1}   ${rad_parameter_2}  ${rad_parameter_3}
    coam.set_multiple_rad_debug_parameters
    ...    domain=L2PS
    ...    persistency=NotPersistent
    ...    rad_parameters=${rad_parameters}
    ...    connection=COAM
    [Teardown]  Run Keyword And Ignore Error    COAM_Admin.Logout

ADMIN Reset All Rad Debug Parameters
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.Reset All Rad Debug Parameters   connection=COAM
    [Teardown]  Run Keyword And Ignore Error    COAM_Admin.Logout

Get Required Logs
   [Arguments]    ${operation}=start  ${log_type}=syslog  ${product_type}=gnb  ${bts_index}=${0}
   ${local_file_path}   Log Collection    operation=${operation}   log_type=${log_type}
   ...   product_type=${product_type}    bts_index=${bts_index}    cudu_index=${0}
   [Return]      ${local_file_path}

Configure Uplane L1 Iq Data For 5G
    [Documentation]  Parameter module_dn must be a Runtime DN of BBMOD or SMOD DN that support embeded BBMOD
    ...              one of dlNrSubcellList|ulNrSubcellList| dlLteCellList|ulLteCellList must be configured, maxItems is 2
    ...    Example request:     "moduleDN":"/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1",
    ...                         "dlNrSubcellList": [{"nrcell_rDN": "/NRCELL_R-1","subcellId":1}],
    ...                         "ulNrSubcellList": [{"nrcell_rDN": "/NRCELL_R-2","subcellId":2}],
    ...                         "dlLteCellList": [1],
    ...                         "ulLteCellList": [1],
    ...                         "captureOnEvent": true
    [Arguments]  ${module_dn}=${BBMOD_Runtime}   ${nrcellDN}=${nrcellDN_Runtime}  ${subcellId}=${0}
    ...    ${captureOnEvent}=${true}  ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    &{dic_dlNrSubcellList}  create dictionary   nrcellDN=${nrcellDN}   subcellId=${subcellId}
    @{dlNrSubcellList}   Create List   ${dic_dlNrSubcellList}
    coam.configure_uplane_l1_iq_data    module_dn=${module_dn}
    ...                                      dl_nr_subcell_list=${dlNrSubcellList}
    ...                                      capture_on_event=${captureOnEvent}
    ...                                      connection=${connection}
    Log To Console      ${subcellId}
    [Teardown]     Run Keyword And Ignore Error    COAM_Admin.Logout

Parse syslog
    [Arguments]   ${syslog_path}=${None}
    ${result}    Log Analysis    filter    syslog    ${syslog_path}    ${analysis_dict_syslog_1}
    Log To Console    \nAnalyze log: ${result}
    should not be empty   ${result}

Parse iqdata Log
    [Arguments]   ${filter_pattern}=.*E529.*IqSnapshotBuffer.xz
    ...          ${zip_snapshot_path}=zip_snapshot   ${iq_file_name}=${NONE}
    [Documentation]  Parse snapshot
     ${save_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
      ...                 directory_name=gnb_snapshot
     ${snapshot_file}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
     OperatingSystem.Run  sudo apt update
     OperatingSystem.Run  sudo apt install unzip
     OperatingSystem.Run  unzip ${snapshot_file}/snapshot.zip -d ${save_path}/
     ${file_name}    basic.find_file_in_zip_archives_in_directory
     ...   dir_zip=${save_path}/   target_file_name_regex=${filter_pattern}
     OperatingSystem.Run  unzip ${save_path}/${file_name} -d ${save_path}/${zip_snapshot_path}/
     ${local_file_size}   basic.verify_local_file_size    local_path=${save_path}/${zip_snapshot_path}/${iq_file_name}
     should be true    ${local_file_size} > 32

TC01 Teardown
    sleep   10s
    Stop DCAP logs    log_type=bip
    ${local_file_path}  Get Required Logs   stop_and_download   syslog   gnb
    Introduce exit test mode
    UE Deregister From gNB    ue_id=1
    ADMIN Reset All Rad Debug Parameters
    Parse iqdata Log   filter_pattern=BTS1_224D_ContIqSnapshotBuffer.xz
     ...   iq_file_name=BTS1_224D_ContIqSnapshotBuffer.xz
    Parse syslog   ${local_file_path}
    Common Test Teardown For RRM

TC02 Teardown
    sleep   10s
    Stop DCAP logs    log_type=bip
    ${local_file_path}   Get Required Logs   stop_and_download   syslog   gnb
    Introduce exit test mode   ue_id=1-3
    UE Deregister From gNB    ue_id=1-3
    ADMIN Reset All Rad Debug Parameters
    Parse iqdata Log   filter_pattern=BTS1_224D_ContIqSnapshotBuffer.xz
     ...   iq_file_name=BTS1_224D_ContIqSnapshotBuffer.xz
    Parse syslog   ${local_file_path}
    Common Test Teardown For RRM

TC03 Teardown
    sleep   10s
    Stop DCAP logs    log_type=bip
    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    ADMIN Reset All Rad Debug Parameters
    Common Test Teardown For RRM

TC04 Teardown
    sleep   10s
    Stop DCAP logs    log_type=bip
    Get Required Logs   stop_and_download   syslog   gnb
    UE Deregister From gNB    ue_id=1
    ADMIN Reset All Rad Debug Parameters
    Common Test Teardown For RRM

TC05 Teardown
    sleep   10s
    Stop DCAP logs    log_type=bip
    ${local_file_path}   Get Required Logs   stop_and_download   syslog   gnb
    UE Deregister From gNB    ue_id=1
    ADMIN Reset All Rad Debug Parameters
    Parse syslog   ${local_file_path}
    Common Test Teardown For RRM