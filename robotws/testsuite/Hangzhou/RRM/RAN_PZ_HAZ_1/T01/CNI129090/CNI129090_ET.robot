*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes to test CNI129090



Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Test Timeout    90 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T01/Resources/RRM2_RRM_Resource.robot

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${BBMOD_Runtime}   /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1
${nrcellDN_Runtime}   /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1
&{syslog_filter_conditions}      line_regex=FaultId: 8101   element_regex=.*
&{analysis_dict_syslog_1}        filter_conditions=${syslog_filter_conditions}
*** Test Cases ***
CNI129090_SR_TC01_DL_IQ_Data_Capture_MSG2_Failure_single_UE
    [Tags]    QC_137474      QCD_MN_RAN      QCP_RAN_VRF
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
    Run Keyword And Ignore Error   Scout_cli start
    Case Precondition  operation=env_setup_sansa   tag=${NONE}  customer=TMO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
#    Airphone Operation  edaemon_egate_setup  gnb  tag=${NONE}
#    Case Precondition  operation=env_setup_sansa   tag=CommonET
    Activate or Deactivate Emil
    ADMIN Set RAD debug parameters
    Configure Uplane L1 Iq Data For 5G
    Run Keyword And Ignore Error  Start DCAP logs   log_type=bip+emil
    sleep  25s
    Get Required Logs    start   syslog   gnb
    Introduce msg3 rach failure
    UE Register with Rach Failure   ue_id=1
    [Teardown]    TC01 Teardown

CNI129090_SR_TC01_DL_IQ_Data_Capture_MSG2_Failure_single_UE_25R2
    [Tags]    QC_145672      QCD_MN_RAN      QCP_RAN_VRF
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
    Case Precondition  operation=env_setup_sansa   tag=${NONE}  customer=TMO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
#    Airphone Operation  edaemon_egate_setup  gnb  tag=${NONE}
#    Case Precondition  operation=env_setup_sansa   tag=CommonET
    Activate or Deactivate Emil
    ADMIN Set RAD debug parameters
    Configure Uplane L1 Iq Data For 5G
    Run Keyword And Ignore Error  Start DCAP logs   log_type=bip+emil
    sleep  25s
    Get Required Logs    start   syslog   gnb
    Introduce msg3 rach failure
    UE Register with Rach Failure   ue_id=1
    [Teardown]    TC01 Teardown

*** Keywords ***
Case Precondition
    [Arguments]   ${operation}=env_setup_sansa   ${tag}=${NONE}   ${customer}=${NONE}
    Airphone Operation  edaemon_egate_setup  gnb  tag=${tag}
    Airphone Operation  ${operation}  gnb  tag=${tag}  customer=${customer}
    OperatingSystem.Run     DCAP_Basic_controller start

UE Register with Rach Failure
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1   ${pass_regexp}=T300 expiration
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=${pass_regexp}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

Introduce msg3 rach failure
    [Arguments]    ${ue_id}=1   ${missed_ra_resp_num}=100
	${cont_testmode}	Set Variable    cont_res_testmode_nr profile_id=1 missed_ra_resp=${missed_ra_resp_num}
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

ADMIN Set RAD debug parameters
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    &{rad_parameter_0}    create dictionary   name=rdAbnormalEventTriggerOnlineEnable    value=2
    &{rad_parameter_1}    create dictionary   name=rdAbnormalEventRachMsg2FailureMonitoringPeriodicity    value=160
    &{rad_parameter_2}    create dictionary   name=rdAbnormalEventRachMsg2FailureDetectionsThreshold    value=2
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

Activate or Deactivate Emil
    [Arguments]       ${actInternalTrace}=true   ${product_type}=gnb
     @{para_list}   Create List   actInternalTrace
     @{value_list}   Create List   ${actInternalTrace}
     @{mo_list}   Create List   MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1
     ${res}   Parameter Operation    operation=parameter_update   product_type=${product_type}   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

TC01 Teardown
    sleep   10s
    Run Keyword And Ignore Error  Stop DCAP logs    log_type=bip+emil
    ${local_file_path}  Get Required Logs   stop_and_download   syslog   gnb
    Introduce exit test mode
    UE Deregister From gNB    ue_id=1
    ADMIN Reset All Rad Debug Parameters
    Parse syslog   ${local_file_path}
    Parse iqdata Log   filter_pattern=BTS1_224D_l1a_contIqSnapshotBuffer.bin.xz
     ...   iq_file_name=BTS1_224D_l1a_contIqSnapshotBuffer.bin.xz
    Common Test Teardown For RRM