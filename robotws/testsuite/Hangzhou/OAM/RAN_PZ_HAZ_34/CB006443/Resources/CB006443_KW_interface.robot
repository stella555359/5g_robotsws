*** Settings ***
Documentation      author: Lixia Wang
...                contact: ning.4.liu@nokia-sbell.com
...                History: Do some adaption for CB006443 by LiuNing
...                This robot file is for CB006443 C&P.

Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource          ../../None_Feature_SG1/OAM_Interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
###CI_interface.robot is defined ,${commissionings_path} and ${testline_name} can be used#####
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource            taf/rfrl/bts/robot/common/gnb_log.robot
Resource            taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource          ./CB006443_KW1_5GR22.robot
Resource          ./CB006443_KW2_5GR22.robot
Resource          ./OAM_KPI_KW1.robot

Library    ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py
Library    ../../None_Feature_SG1/OAM_Interface.py
Library    taf.collectors.core   WITH NAME   core
Library    taf.sbts.oam.coam.admin  WITH NAME   admin
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.selenium.sbts   WITH NAME   selenium_sbts
Library    timing.py
Library    ../../../../resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/PM_Counter.py     WITH NAME   PM_Counter
Library    PM_Counter.PMCounter    WITH NAME    counter
Library    ../../5GC002479/Resources/5GC002479_A.py
Variables    ./TLDelta.py
Library      taf.ul.oam_kpi_calculations    WITH NAME   oam_kpi_calculations
Library         ./ims_keywords.py
Library      ute_reporting_portal
Library      taf.rfrl.common_resources.oam_kpi.report_oam_kpi


Variables    targets.py

*** Variables ***
#Configure the TL specific variable
${USER_LOG_DIR}        /opt/ute/Logs
${UPDATE_FILE_PATH}       /home/ute/Download_gNB_Package
${YAFT_PATH}              /opt/ute/YAFT
${WTS_FILE_PATH}       ${tl.core.dir_path}
${UTE_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
#${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
#${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${WEBUI_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${distname}                 ${MRBTS_ID}/${NRBTS_ID}
${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${model}    ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
${LOGIN_BOX}=    xpath=//*[@id="login-view"]/div/div[1]/div[1]/ng-view/div/form/div[2]/input
${PASS_BOX}=    xpath=//*[@id="login-view"]/div/div[1]/div[1]/ng-view/div/form/div[3]/input
${URL_LMP}       192.168.255.129
${LEGAL}=     xpath=//html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
${LOGIN_BUTTON}=    xpath=//*[@id="login-view"]/div/div[1]/div[1]/ng-view/div/form/div[4]/div[1]/div/ui-button[1]/button

#${PdcchMonOccsnPo}    First PDCCH monitoring occasion of paging occasion
#${pdcch_wrong}     200
#${gscn}    Synchronization channel number
#${gscn_wrong}     26639
#${PMINTERVAL}       5
${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_LMP_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_LMP_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
&{condition_PS_same}     PS=same
&{condition_PS_diff}     PS=diff
${ALIAS_SSH_DU}    SSH_DU
${NIDD_Parameters_path}     /home/ute/NIDD_Parameters
@{PMMNL_exception_list}    mtSBTSSIMon    mtSfpmtSfp    cteStatisticsInterval    loosePhaseAndTimeStatisticsInterval
...    mtSfp    mtEthernetSidehaul    dteStatisticsInterval   s1X2TacStatisticsInterval
...    miTrRxWindowStats    miRxWindowStats
@{NRPMRNL_exception_list}    ulUeThptMethod    miNrNgcFlexInterface    miNrPaging    miNrRelReportCu
@{PMTNLINT_exception_list}    s1X2TacStatisticsInterval    s1X2TacStatisticsInterval
${NETACT_LOGSERVER_IP}              ${netact_info['cmwas_ip']}
${NETACT_LOGSERVER_USERNAME}        ${netact_info['user']}
${NETACT_LOGSERVER_PASSWORD}        ${netact_info['password']}
##################define these variable for convenient############################
#${ALIAS_ASIK}     asik    ##
#${ALIAS_ASIK_SLAVE}    asik_slave    ##
#${ALIAS_UTE}      ute    ##
########################END of alias Define#######################################
${BTSSWServerPath}          https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
##########################SCF##########################
@{SCF_IWK}                      SCF_Trunk.xml
${SCF_IWK_Trunk}        ${commissionings_path}/HGZ/${testline_name}/

*** Keywords ***
TC.CB006443_AA_01_CM_Full_Plan_Download_Validation_Activation_Operations
    [Documentation]
    ...  Purpose:Aim to test the KPI of load, validate and active the SCF on WebUI
    ...  Precondition:No error when do validation
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: Create a full configuration plan with error and load the scf on WebUI
    ...           eg:modify ABIL ID to generate error
    ...    Step2: Check the validation duration should no more than requirement in WebEM,
    ...           and validate the scf and check error exist.
    ...    Step3: Create a full configuration plan without error and load the scf in WebUI
    ...    Step4: Do validation operation in WebEM,
    ...           and Check the validation duration should no more than requirement
    ...    Step5: Check both the load scf duration should no more than requirement
    ...    Step6: Active the scf without error and check the active duration should no more than requirement
#    [Arguments]   ${SCF_WithError}=${CASE_INPUT_CB006443['CB006443_AA_01']['SCF_WithError']}
#    ...           ${SCF_NoError}=${CASE_INPUT_CB006443['CB006443_AA_01']['SCF_NoError']}
    [Arguments]   ${Duration_SCFLoad}=${CASE_INPUT_CB006443['CB006443_AA_01']['Duration_SCFLoad']}
    ...           ${Duration_ValidationError}=${CASE_INPUT_CB006443['CB006443_AA_01']['Duration_ValidationError']}
    ...           ${Duration_Validation}=${CASE_INPUT_CB006443['CB006443_AA_01']['Duration_Validation']}
    ...           ${Duration_Activation}=${CASE_INPUT_CB006443['CB006443_AA_01']['Duration_Activation']}
    run   cp ${BACKUP_SCF} ${LOG_PATH}/ErrorSCF.xml
    Basic.SedReplaceLine    <p name=\\"secondEndpointDN\\">${MRBTS_ID}\\/EQM-1\\/APEQM-1\\/CABINET-1\\/BBMOD-1<\\/p>
    ...    \\<p name=\\"secondEndpointDN\\"\\>${MRBTS_ID}\\/EQM-1\\/APEQM-1\\/CABINET-1\\/BBMOD-9999\\<\\/p\\>
    ...    ${LOG_PATH}/ErrorSCF.xml
    COAM_WebEM.Login
    Log To Console    Step1: Create a full configuration plan with error and load the scf on WebUI
    ${status}=    selenium_coam.load_commissioning_file_and_check_load_status
    ...           file_path=${LOG_PATH}/ErrorSCF.xml
    Should be True    ${status}
    Log To Console   Step2: Check the validation duration should no more than requirement in WebEM,
    ...           and validate the scf and check error exist.
    selenium_coam.validate_plan     timeout=${Duration_ValidationError}
    ${error}    selenium_coam.get_relation_errors
    Should Not Be Empty    ${error}
    log to console    Step3: Create a full configuration plan without error and load the scf in WebUI
    ${status}=    selenium_coam.load_commissioning_file_and_check_load_status
     ...           file_path=${BACKUP_SCF}
    Should be True    ${status}
    Log To Console    Step4: Do validation operation in WebEM,
    ...           and Check the validation duration should no more than requirement
    selenium_coam.validate_plan     timeout=${Duration_Validation}
#    ${error}    selenium_coam.get_relation_errors
##    Should Be Empty     ${error}
    #first error load commission file
    log To Console    Step5: Check both the load scf duration should no more than defined by requirement
    ${timestart}    run    cat ${OUTPUT DIR}/debug.log |grep "//load-action-button//input"|awk '{print $1,$2}'|head -n 1|tail -1
    ${timestart}      convert date    ${timestart}    epoch
    ${timeend}    run    cat ${OUTPUT DIR}/debug.log |grep "END KW: selenium_coam.Load Commissioning"|awk '{print $1,$2}'|head -n 1|tail -1
    ${timeend}      convert date    ${timeend}    epoch
    ${duration1}    Evaluate    ${timeend}-${timestart}
    log to console    ${duration1}
    should be true     ${duration1}<${Duration_SCFLoad}
    #second success load commission file
    ${timestart}    run    cat ${OUTPUT DIR}/debug.log |grep "//load-action-button//input"|awk '{print $1,$2}'|head -n 3|tail -1
    ${timestart}      convert date    ${timestart}    epoch
    ${timeend}    run    cat ${OUTPUT DIR}/debug.log |grep "END KW: selenium_coam.Load Commissioning"|awk '{print $1,$2}'|head -n 2|tail -1
    ${timeend}      convert date    ${timeend}    epoch
    ${duration2}    Evaluate    ${timeend}-${timestart}
    log to console    ${duration2}
    should be true     ${duration2}<${Duration_SCFLoad}
    Log To Console    Step6: Active the scf without error and check the active duration should no more than requirement
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=${Duration_Activation}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend


TC.CB006443_AA_02_CM_Delta_Plan_Validation_Activation_Operations_No_Service_Outage
    [Documentation]
    ...   Purpose:Test case is to check configuration file_delta plan(No service outage) can be validation/activation
    ...            successful and duration meet requirement.
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Modify parameter which will not cause site reset but will cause error when do validation.
    ...            eg:modify 'shutdownNogNBCellTmr' to wrong value in webem.
    ...     Step2: Caculate validate duration(duration is captured from system) and check validation duration no more than
    ...            requirement.
    ...     Step3: Validate and check error exist on WebEM.
    ...     Step4: Restore environment,which means modify parmeter back,do validation and activation.
    [Arguments]   ${InActSA_ErrValue}=80000
    ...           ${Duration_DeltaValidation}=${CASE_INPUT_CB006443['CB006443_AA_02']['Duration_DeltaValidation_error']}
    COAM_WebEM.Login
    Log To Console    Step1: Modify parameter which will not cause site reset but will cause error when do validation.
    ...            eg:modify 'shutdownNogNBCellTmr' to wrong value in webem.
    ${timestartTmp}   Get Current Date
    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ...    new_value=${InActSA_ErrValue}
    ${validate_message_STEP1}   selenium_coam.get_error_info_after_set_parameter
    Log To Console    Step2: Caculate validate duration(duration is captured from system) and check validation duration no more than
    ...            requirement
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp_CB006443AA02}    Evaluate    ${timeend}-${timestart}
    Should Be True     ${0}<${duration_time_tmp_CB006443AA02}<=${Duration_DeltaValidation}
    Log To Console    Step3: Validate and check error exist on WebEM.
    Should Not Be Empty       ${validate_message_STEP1}
    selenium_coam.undo_changes
    Log To Console    Step4: Restore environment,which means modify parmeter back,do validation and activation.
    ${InActSA_Value}    selenium_coam.get_parameter_value
    ...    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ${InActSA_Value}    get regexp matches    ${InActSA_Value}     [0-9]+
    ${InActSA_Value}    Evaluate    ${InActSA_Value[0]}+1
    ${InActSA_CorrectValue}=  set variable if    ${InActSA_Value} >= ${5}   3   8
    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ...    new_value=${InActSA_CorrectValue}
    selenium_coam.validate_plan
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty     ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    COAM_WebEM.Logout

TC.CB006443_AA_03_CM_Configuration_File_Backup
    [Documentation]
    ...   Purpose:Test case is to check configuration file can be saved successful and duration meet requirement.
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Backup SCF and check whether time meet requirement
	...   Note:OM_GEN_SFS_PERF_CAP.6819 in 21A.Target is 30s
    [Arguments]    ${SCF_backup_duration}=${CASE_INPUT_CB006443['CB006443_AA_03']['SCF_backup_duration']}
    COAM_WebEM.Login
    Log To Console    Step1: Backup SCF and check whether time meet requirement.
    ${timestartTmp}    KW.TimerStart
	${bkp_scf_file}    selenium_coam.Save Bts Configuration
    set suite variable    ${bkp_scf_file}
    ${duration_time_tmp}     KW.TimerStop    timestart=${timestartTmp}
    LOG    ${duration_time_tmp}
    COAM_WebEM.Logout
    Should Be True     ${0}<${duration_time_tmp}<=${SCF_backup_duration}      Configuration File Backup time is more than 30s

TC.CB006443_AA_04_CM_Delta_Plan_Validation_Activation_Operations_Site_Level_Service_Outage
    [Documentation]
    ...   Purpose:test case is to check configuration file_delta plan(Site level service outage need)
    ...            can be validation/activation can be successful and duration meet requirement.
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Modify parameter which will cause site reset has error when do validation.
    ...            eg:modify 'drxDefaultPaging' to a different value.
    ...     Step2: Validate and check error not exist on WebEM.
    ...     Step3: Do activation,caculate activation duration(duration is captured from system) and check validation
    ...            duration no more than requirement.
    [Arguments]   ${Duration_DeltaActivation}=${CASE_INPUT_CB006443['CB006443_AA_04']['Duration_DeltaActivation']}
    COAM_WebEM.Login
    Log To Console    Step1:Modify parameter which will cause site reset has error when do validation.
    ${drxDefaultPaging_Value}    selenium_coam.get_parameter_value
    ...    dist_name=${distname}    filter_param=Default DRX paging cycle value for the gNB    abbr=drxDefaultPaging
    run keyword if    "${drxDefaultPaging_Value}"=="v256"
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${distname}              filter_param=Default DRX paging cycle value for the gNB
    ...    new_value=v128   abbr=drxDefaultPaging
    ...    ELSE
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${distname}              filter_param=Default DRX paging cycle value for the gNB
    ...    new_value=v256   abbr=drxDefaultPaging
    Log To Console    Step2: Validate and check error not exist on WebEM.
    selenium_coam.validate_plan
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty     ${error}
    Log To Console    Step3: Do activation,caculate activation duration and check validation duration no more than requirement
    ${timestartTmp}   Get Current Date
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    ...    timeout=120
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp_STEP2}    Evaluate    ${timeend}-${timestart}
    Should Be True     ${0}<${duration_time_tmp_STEP2}<=${Duration_DeltaActivation}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend

TC.CB006443_AA_05_CM_Delta_Plan_Provision_Operation_No_Service_Outage
    [Documentation]
    ...   Purpose:Check configuration file_delta plan(no service outage) provision can be successful and duration meet requirement
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TTA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import delta scf which will not cause reset in netact,and check provision duration no more than
    ...     requirement
    [Arguments]   ${Delta_Plan_Provision_Durtion}=${CASE_INPUT_CB006443['CB006443_AA_05']['Delta_Plan_Provision_Durtion']}
    ...    ${filter_method}=Other
    Log To Console    Step1: Import delta scf which will not cause reset in netact,and check provision duration no more than
    ...     requirement
    NetAct.Login   url=${netact_info['url']}
            ...    username=${netact_info['url_user']}
            ...    password=${netact_info['url_password']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan
    ...    FileName=${commissionings_path}/HGZ/${testline_name}/TA_Delta_NoReset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
    ...    filter_method=${filter_method}
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_Provision_Durtion}

TC.CB006443_AA_06_CM_Full_Config_Plan_Provision
    [Documentation]
    ...   Purpose:Check configuration file_delta plan(no service outage) provision can be successful and duration meet requirement
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Full_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import full scf in netact,and check provision duration no more than requirement
    [Arguments]   ${Full_Plan_Provision_Durtion}=${CASE_INPUT_CB006443['CB006443_AA_06']['Full_Plan_Provision_Durtion']}
    Log To Console    Step1: Import full scf in netact,and check provision duration no more than requirement
    NetAct.Login   url=${netact_info['url']}
            ...    username=${netact_info['url_user']}
            ...    password=${netact_info['url_password']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan
    ...    FileName=${commissionings_path}/HGZ/${testline_name}/TA_Full_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
     ...    filter_method=Other
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${Full_Plan_Provision_Durtion}

TC.CB006443_AA_07_CM_Delta_Plan_Pre-Activate_Successful
    [Documentation]
    ...   Purpose:Check delta plan pre-activate duration meet requirement.
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import delta no reset scf in netact,do pre_procision and check  duration no more than
    ...     requirement
    [Arguments]   ${Delta_Plan_PreProvision_Durtion}=${CASE_INPUT_CB006443['CB006443_AA_07']['Delta_Plan_PreProvision_Durtion']}
    Log To Console    Step1: Import delta no reset scf in netact,do pre_procision and check  duration no more than
    ...     requirement
    NetAct.Login   url=${netact_info['url']}
            ...    username=${netact_info['url_user']}
            ...    password=${netact_info['url_password']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan
    ...    FileName=${commissionings_path}/HGZ/${testline_name}/TA_Delta_NoReset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=true
    ...    filter_method=Other
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_PreProvision_Durtion}

TC.CB006443_AA_08_CM_Delta_Plan_Download
    [Documentation]
    ...   Purpose:Check delta plan download duration meet requirement.
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import delta with no reset scf in netact,check download duration no more than requirement
    [Arguments]   ${Import_Delta_Plan_Durtion}=${CASE_INPUT_CB006443['CB006443_AA_08']['Import_Delta_Plan_Durtion']}
    log to console    Step1: Import delta with no reset scf in netact,check download duration no more than requirement
    BtsLog.StartBTSlogCollection
    NetAct.Login   url=${netact_info['url']}
            ...    username=${netact_info['url_user']}
            ...    password=${netact_info['url_password']}
    NetAct.StartApp  app_name=CM Operations Manager
    ${duration}    NetAct.CMOperationManager.ImportPlan
    ...    FileName=${commissionings_path}/HGZ/${testline_name}/TA_Delta_NoReset_Plan.xml
    log to console    ${duration}
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    should be true    ${duration}>${0} and ${duration}<${Import_Delta_Plan_Durtion}

TC.CB006443_AA_09_CM_Delta_Plan_Provision_Operation_Site_Service_Outage
    [Documentation]
    ...   Purpose: Check configuration file_delta plan(site service outage) provision can be successful and duration meet requirement.
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   TestC Steps:
    ...     Step1: Import delta with no reset scf in netact,check download duration no more than requirement
    [Arguments]   ${Delta_Plan_Provision_Durtion_Reboot}=${CASE_INPUT_CB006443['CB006443_AA_09']['Delta_Plan_Provision_Durtion_Reboot']}
    log to console    Step1: Import delta with no reset scf in netact,check download duration no more than requirement
    NetAct.Login   url=${netact_info['url']}
            ...    username=${netact_info['url_user']}
            ...    password=${netact_info['url_password']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan
    ...    FileName=${commissionings_path}/HGZ/${testline_name}/TA_Delta_Reset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
    ...    filter_method=Other
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_Provision_Durtion_Reboot}

TC.CB006443_AA_10_CM_Upload_CM_Configuration
    [Documentation]
    ...   Purpose:Check CM configuration upload can be successful and duration meet requirement.
    ...   Precondition: Netact has been integrated
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1:Upload configuration in netact,check upload status and duration no more than requirement
    [Arguments]   ${CMUplod_Durtion}=${CASE_INPUT_CB006443['CB006443_AA_10']['CMUplod_Durtion']}
    log to console    Step1:Upload configuration in netact,check upload status and duration no more than requirement
    NetAct.Login   url=${netact_info['url']}
            ...    username=${netact_info['url_user']}
            ...    password=${netact_info['url_password']}
    NetAct.StartApp  app_name=CM Operations Manager
    ${duration}    NetAct.CMOperationManager.Upload
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${CMUplod_Durtion}

TC.CB006443_AA_11_CM_Duration_of_CM_Change_Notification
    [Documentation]
    ...   Purpose:The BTS/DU/CU/vDU shall complete the CM change notification generation and transmission
    ...   within the times defined in 10+7s.
    ...   Precondition: NetAct ENV shall be integrated.
    ...   Test tools:WebUI, btslog
    ...   Test Steps:
    ...     Step1: Modify parameter which will not cause site reset and will not cause error when do validation.
    ...            eg:modify 'shutdownNogNBCellTmr' to a different value
    ...     Step2: Validate and check error not exist on WebEM.
    ...     Step3: Capture btslog and do activation.
    ...     Step4: Caculate duration between message "finishActivation" and "Transfer ccn succeedand"
    ...     in btslog and check duration no more than requirement
    [Arguments]    ${Duration_ChangeNoti}=${CASE_INPUT_CB006443['CB006443_AA_11']['Duration_ChangeNoti']}
    COAM_WebEM.Login
    Log To Console    Step1: Modify parameter which will not cause site reset and will not cause error when do validation.
    ${InActSA_Value}    selenium_coam.get_parameter_value
    ...    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ${InActSA_Value}    get regexp matches    ${InActSA_Value}     [0-9]+
    ${InActSA_Value}    Evaluate    ${InActSA_Value[0]}+1
    ${InActSA_Value_New}=  set variable if    ${InActSA_Value} >= ${5}   3   8
    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ...    new_value=${InActSA_Value_New}
    selenium_coam.validate_plan
    Log To Console    Step2: Validate and check error not exist on WebEM.
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty     ${error}
    Log To Console    Step3: Capture btslog and do activation.
    ${CheckString}    set variable     "finishActivation|Transfer ccn succeed"
    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    run keyword and ignore error    run    command=cd /tmp/;rm -rf BTSLOG_AA_11.txt
    BtsLog.StartBTSlogCollection
    #run    command=tail -f /tmp/btslog2/SYSLOG_*.LOG |grep -E ${CheckString} >> /tmp/BTSLOG_AA_11.txt&
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    Sleep    5s
    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    Sleep    2s
    COAM_WebEM.Logout
    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step4: Caculate duration between message "finishActivation" and "Transfer ccn succeedand"
    ...     in btslog and check duration no more than requirement.
    run    command=cat /tmp/btslog2/SYSLOG_*.LOG |grep -E ${CheckString} >> /tmp/BTSLOG_AA_11.txt&
    Sleep    2s
    ${Noti_Time0}     run    command=cat /tmp/BTSLOG_AA_11.txt|grep finishActivation|awk '{print $6}'|head -n 1|tail -1
    Should Not Be Empty     ${Noti_Time0}
    ${Noti_Time0}        convert date    ${Noti_Time0.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${Noti_Time2}    run    command=cat /tmp/BTSLOG_AA_11.txt | grep "Transfer ccn succeed"|awk '{print $6}'|head -n 3|tail -1
    Should Not Be Empty     ${Noti_Time2}
    ${Noti_Time2}        convert date    ${Noti_Time2.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${Noti_Duration1}    Evaluate    ${Noti_Time2}-${Noti_Time0}
    Should Be True     ${Noti_Duration1}<=${Duration_ChangeNoti} and ${Noti_Duration1}>${0}

TC.CB006443_BA_01_PM_Collection
    [Documentation]
    ...   Purpose:Check the PM result file creation successful and duration meet requirement.
    ...   Precondition: NA
    ...   Test tools:ssh to gnb
    ...   Test Steps:
    ...     Step1:Get pm file created interval from webem
    ...     Step2:Check pm file will create successfully within pm file created interval.
    [Arguments]   ${PM_File_Creation_Time}=${CASE_INPUT_CB006443['CB006443_BA_01']['PM_File_Creation_Time']}
	              ...    ${PM_File_Path}=/tmp     ${PM_File_filter}=PM.BTS*.xml.gz
                  ...    ${PMINTERVAL}=60min    ${Max_loop}=2
    ${connection}    Connect to DU by ADMIN API
    ${Original_reportingIntervalPm}    Run Keyword And Continue On Failure    Update or Create parameter by Admin API
       ...    class_name=PMCADM_A    parameter_Abbreviation=reportingIntervalPm
	   ...    Expected_Value=${PMINTERVAL}    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    set test variable    ${Original_reportingIntervalPm}
    ${PMINTERVAL_num}=    Remove String    ${PMINTERVAL}    min
    Run Keyword And Continue On Failure    Update or Create parameter based on NIDD
    ...    class_name=PMMNL_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_PMMNL.xlsm
    ...    Expected_Value=15min    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1    MOCName=MNL/MNLENT/PMMNL
    ...    exception_list=@{PMMNL_exception_list}

    Run Keyword And Continue On Failure    Update or Create parameter based on NIDD
    ...    class_name=PMTNLINT_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_PMTNLINT.xlsm
    ...    Expected_Value=5min    Dist_name=${MRBTS_ID}/TNLSVC-1/PMTNLINT-1    MOCName=TNLSVC/PMTNLINT
    ...    exception_list=@{PMTNLINT_exception_list}

    Run Keyword And Continue On Failure    Update or Create parameter based on NIDD
    ...    class_name=NRPMRNL_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_NRPMRNL.xlsm
    ...    Expected_Value=5min    Dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPMRNL-1    MOCName=NRBTS/NRPMRNL
    ...    exception_list=@{NRPMRNL_exception_list}

	 FOR    ${i}    IN RANGE    ${Max_loop}
	     ssh.Connect to    hostname=${ASIK_LMP_IP}
     ...               username=${ASIK_LMP_USERNAME}
     ...               password=${ASIK_LMP_PASSWORD}
     ...               alias=${ALIAS_SSH_DU}
         Check PM collect OAM KPI    reporting_interval=${PMINTERVAL_num}   PM_File_Path=${PM_File_Path}
     ...    PM_File_filter=${PM_File_filter}    PM_File_Creation_Time=${PM_File_Creation_Time}
         Run Keyword And Ignore error    ssh.disconnect    connection=${ALIAS_SSH_DU}
     END

     [Teardown]    Run Keywords   Run Keyword And Ignore error      gNB.Disconnect
	        ...    AND   Run Keyword And Ignore error    Update or Create parameter by Admin API
            ...    class_name=PMCADM_A    parameter_Abbreviation=reportingIntervalPm
	        ...    Expected_Value=${Original_reportingIntervalPm}    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
			...    AND    Run Keyword And Ignore error    DisConnect to DU by ADMIN API

Check PM collect OAM KPI
     [Arguments]      ${reporting_interval}   ${PM_File_Path}    ${PM_File_filter}
	           ...    ${PM_File_Creation_Time}
     &{pre_case_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation
	 ...    reporting_interval=${reporting_interval}    asik_alias=${ALIAS_SSH_DU}
     Sleep    ${pre_case_time_info['wait_time_sec']}
     ${timeendTmp1}     Get Current Date
     ${timestart}        convert date    ${timeendTmp1}     epoch
	 FOR    ${i}    IN RANGE    1000
        ${new_PM_File_output}=    ssh.execute
	   ...    command=find ${PM_File_Path} -name '${PM_File_filter}' -newermt '${pre_case_time_info['log_generator_timestamp']}'
       ...    connection=${ALIAS_SSH_DU}
        ${new_PM_File}    run keyword and ignore error    Remove String    ${new_PM_File_output}    \r\n
	    Run Keyword if    "${new_PM_File[1]}"=="${EMPTY}"    sleep    5ms
        exit for loop if  "${new_PM_File[1]}"!="${EMPTY}"
     END
	 ${timeendTmp}     Get Current Date
     ${timeend}        convert date    ${timeendTmp}     epoch
     #${timestart}      convert date    ${pre_case_time_info['log_generator_timestamp']}    epoch
	 ${duration1}    Evaluate    ${timeend}-${timestart}
     log to console    PM_Collection KPI for is ${duration1}
     should be true     ${0}<${duration1}<${PM_File_Creation_Time}


TC.CB006443_BA_02_PM_Retention
    [Documentation]
    ...   Precondition: NA
    ...   Purpose:Check PM result files shall be kept for 24h in the BTS
    ...   Test tools:ssh to gnb
    ...   Test Steps:
    ...     Step1: Check pm file kept duration(from created to current time)
    ...     Step2: Wait "target duration - kept duration",check pm file exist.
    ...     Note:target duration-kept duration is set to 180s rather than 24h,we could modify to 24h in weekend to run this case
    [Arguments]   ${Duration_PM_Kept}=${CASE_INPUT_CB006443['CB006443_BA_02']['Duration_PM_Kept']}
    Log To Console    Step1: Check pm file kept duration(from created to current time)

    gNB.Connect
    Wait Until Keyword Succeeds    20x    5s      KW.PM_exist
    ${PM_Create_Time}=       ssh.execute
     ...      command=cd /tmp;ls -al PM*.ANY.xml.gz --time-style '+%Y/%m/%d %H:%M:%S' |awk '{print $6,$7}'|head -n 1
     ...      connection=${ALIAS_ASIK}
    ${PM_File_Before}=       ssh.execute
     ...      command=cd /tmp;ls -al PM*.ANY.xml.gz |awk '{print $9}'|head -n 1           connection=${ALIAS_ASIK}
    ${GNB_Currenct_Time}=    ssh.execute     command=date +%Y%m%d%H%M%S     connection=${ALIAS_ASIK}
    ${PM_Create_Time}        Fetch From Left    ${PM_Create_Time}          \r\n
    ${GNB_Currenct_Time}     Fetch From Left    ${GNB_Currenct_Time}       \r\n
    ${PM_Create_Time}        convert date    ${PM_Create_Time}       epoch
    ${GNB_Currenct_Time}     convert date    ${GNB_Currenct_Time}    epoch
    ${PM_Generation_Time}    Evaluate    ${GNB_Currenct_Time}-${PM_Create_Time}
    ${PM_Left_Time}          Evaluate    ${Duration_PM_Kept}-${PM_Generation_Time}
    Log To Console      ${PM_Left_Time}
    Log To Console    Step2: Wait "target duration - kept duration",check pm file exist.
    Run Keyword If      ${PM_Left_Time} > 0         Sleep     ${PM_Left_Time}s
    ...    ELSE     run keywords
    ...             gNB.Disconnect
    ...    AND      Pass Execution     PM file already be kept for ${PM_Generation_Time} seconds in BTS
    ${PM_File_After}=       ssh.execute
    ...      command=cd /tmp;ls -al PM*|awk '{print $9}'|head -n 1           connection=${ALIAS_ASIK}
    Should Be Equal    ${PM_File_Before}    ${PM_File_After}
    gNB.Disconnect

TC.CB006443_BA_03_PM_Data_File_Size
    [Documentation]
    ...   Purpose: heck PM result files size is meet requirement
    ...   Precondition: NA
    ...   Test tools:WebUI,ssh to gnb
    ...   Test Steps:
    ...     Step1: Modify ModifyPMPeriod in webem
    ...     Step2: Ssh to gnb and check pm files exist by executing command
    ...     Step3: Caculate files' size and check it no more than requirement
    [Arguments]   ${PM_MAX_Size}=${CASE_INPUT_CB006443['CB006443_BA_03']['PM_MAX_Size']}    ${PMINTERVAL}=15
    Log To Console    Step1: Modify ModifyPMPeriod in webem
    #KW.ModifyPMPeriod    FileINTERVAL=15min     PMINTERVAL=15min
############# comment fowlling to reduce testing time
    ${connection}    Connect to DU by ADMIN API
    ${Original_reportingIntervalPm}    Run Keyword And Continue On Failure    Update or Create parameter by Admin API
       ...    class_name=PMCADM_A    parameter_Abbreviation=reportingIntervalPm
	   ...    Expected_Value=${PMINTERVAL}min    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    set test variable    ${Original_reportingIntervalPm}
    Run Keyword And Continue On Failure    Update or Create parameter based on NIDD
    ...    class_name=PMMNL_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_PMMNL.xlsm
    ...    Expected_Value=${PMINTERVAL}min    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1    MOCName=MNL/MNLENT/PMMNL
    ...    exception_list=@{PMMNL_exception_list}

    Run Keyword And Continue On Failure    Update or Create parameter based on NIDD
    ...    class_name=PMTNLINT_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_PMTNLINT.xlsm
    ...    Expected_Value=${PMINTERVAL}min    Dist_name=${MRBTS_ID}/TNLSVC-1/PMTNLINT-1    MOCName=TNLSVC/PMTNLINT
    ...    exception_list=@{PMTNLINT_exception_list}

    Run Keyword And Continue On Failure    Update or Create parameter based on NIDD
    ...    class_name=NRPMRNL_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_NRPMRNL.xlsm
    ...    Expected_Value=${PMINTERVAL}min    Dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPMRNL-1    MOCName=NRBTS/NRPMRNL
    ...    exception_list=@{NRPMRNL_exception_list}
    Wait Until Keyword Succeeds   1min   3s     DU_WebEM.LogIn and Check all NR Cell On Air
    Log To Console    Step2: Ssh to gnb and check pm files exist by executing command
    ssh.Connect to    hostname=${ASIK_LMP_IP}
     ...               username=${ASIK_LMP_USERNAME}
     ...               password=${ASIK_LMP_PASSWORD}
     ...               alias=${ALIAS_SSH_DU}
    &{pre_case_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation
	 ...    reporting_interval=${PMINTERVAL}    asik_alias=${ALIAS_SSH_DU}
	Log To Console    sleep time is ${pre_case_time_info['wait_time_sec']}
	${Timestap1}    robot.libraries.DateTime.Add Time To Date
	...    date=${pre_case_time_info['log_generator_timestamp']}
	...    time=${PMINTERVAL} minutes    result_format=%Y-%m-%d %H:%M
    ${sleeptime}    Evaluate    ${pre_case_time_info['wait_time_sec']}+60*${PMINTERVAL}
    Sleep    ${sleeptime}
    Log To Console    Step3: Caculate files' size and check it no more than "PM_MAX_Size"
    FOR    ${i}    IN RANGE    1200
       ${PM_File_exist}=       RUN KEYWORD AND CONTINUE ON FAILURE     ssh.execute
       ...    command=find /tmp -name 'PM.BTS*.ANY.xml.gz' -newermt '${Timestap1}'
       ...    connection=${ALIAS_SSH_DU}
       ${PM_Status}    RUN KEYWORD AND RETURN STATUS      Should Contain    ${PM_File_exist}    PM.BTS
       ...    ignore_case=True
       Exit For Loop If    '${PM_Status}'=='${True}'
    END
    ${PM_File_name}    Run Keyword And Ignore Error    Remove String    ${PM_File_exist}    \r\n
    ${PM_File_Size_Output}=       RUN KEYWORD AND CONTINUE ON FAILURE     ssh.execute
    ...    command=cd /tmp;ls -ll ${PM_File_name[1]} | awk '{print $5}'
     ...    connection=${ALIAS_SSH_DU}
    ${PM_File_Size_B}    Run Keyword And Ignore Error    Remove String    ${PM_File_Size_Output}    \r\n
    ${PM_File_Size}    RUN KEYWORD AND CONTINUE ON FAILURE     Evaluate    ${PM_File_Size_B[1]}/1024
    Should Be True     ${0}<${PM_File_Size}<${PM_MAX_Size}
    [Teardown]    Run Keywords    Run Keyword And Ignore error    ssh.disconnect    connection=${ALIAS_SSH_DU}
	        ...    AND   Run Keyword And Ignore error    Update or Create parameter by Admin API
       ...    class_name=PMCADM_A    parameter_Abbreviation=reportingIntervalPm
	   ...    Expected_Value=${Original_reportingIntervalPm}    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
	   ...    AND    Run Keyword And Ignore error    DisConnect to DU by ADMIN API

TC.CB006443_BA_04_PM_CPU_Impact
    [Documentation]
    ...   Purpose:CPU load impact between disable all PM counters and enable all PM counters
    ...   Precondition: NA
    ...   Test tools:WebUI,ssh to gnb
    ...   Test Steps:
    ...     Step1: Disale all pm counters and check CPU load
    ...     Step2: Enable pm counters and check CPU load
    ...     Step3: Check CPU load's increase meet target
    [Arguments]   ${CPU_Jitter}=${CASE_INPUT_CB006443['CB006443_BA_04']['CPU_Jitter']}    ${PMINTERVAL}=5min

    Log To Console    Step1: Disale all pm counters and check CPU load
    #KW.ModifyPMPeriod    FileINTERVAL=5min     PMINTERVAL=disabled
    ${connection}    Connect to DU by ADMIN API
    ${Original_reportingIntervalPm}    Run Keyword And Continue On Failure    Update or Create parameter by Admin API
       ...    class_name=PMCADM_A    parameter_Abbreviation=reportingIntervalPm
	   ...    Expected_Value=${PMINTERVAL}     Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    set test variable    ${Original_reportingIntervalPm}
    ${PMINTERVAL_num}=    Remove String    ${PMINTERVAL}    min
    Run Keyword And Ignore Error     Update or Create parameter based on NIDD
    ...    class_name=PMMNL_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_PMMNL.xlsm
    ...    Expected_Value=disabled    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1    MOCName=MNL/MNLENT/PMMNL
    ...    exception_list=@{PMMNL_exception_list}

   Run Keyword And Ignore Error     Update or Create parameter based on NIDD
    ...    class_name=PMTNLINT_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_PMTNLINT.xlsm
    ...    Expected_Value=disabled    Dist_name=${MRBTS_ID}/TNLSVC-1/PMTNLINT-1    MOCName=TNLSVC/PMTNLINT
    ...    exception_list=@{PMTNLINT_exception_list}

    Run Keyword And Ignore Error     Update or Create parameter based on NIDD
    ...    class_name=NRPMRNL_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_NRPMRNL.xlsm
    ...    Expected_Value=disabled    Dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPMRNL-1    MOCName=NRBTS/NRPMRNL
    ...    exception_list=@{NRPMRNL_exception_list}
    gNB.Connect
    ${sum_1}    set variable    ${0}
    FOR  ${i}    IN RANGE    ${100}
        ${result}  Conn.Execute    cmd=grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'    alias=${ALIAS_ASIK}
        ${result}    Fetch From Left     ${result}   \r\n
        ${sum_1}     Evaluate    ${result}+${sum_1}
        Sleep    3s
    END
    Log To Console    Step2: Enable pm counters and check CPU load
    #KW.ModifyPMPeriod    FileINTERVAL=5min     PMINTERVAL=5min
    Run Keyword And Ignore Error     Update or Create parameter based on NIDD
     ...    class_name=PMMNL_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_PMMNL.xlsm
     ...    Expected_Value=15min
     ...    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1    MOCName=MNL/MNLENT/PMMNL
     ...    exception_list=@{PMMNL_exception_list}
     Run Keyword And Ignore Error     Update or Create parameter based on NIDD
     ...    class_name=PMTNLINT_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_PMTNLINT.xlsm
     ...    Expected_Value=15min
     ...    Dist_name=${MRBTS_ID}/TNLSVC-1/PMTNLINT-1    MOCName=TNLSVC/PMTNLINT
     ...    exception_list=@{PMTNLINT_exception_list}
     Run Keyword And Ignore Error     Update or Create parameter based on NIDD
     ...    class_name=NRPMRNL_A    filelocation=${NIDD_Parameters_path}/NIDD_Parameter_Report_NRPMRNL.xlsm
     ...    Expected_Value=15min
     ...    Dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPMRNL-1    MOCName=NRBTS/NRPMRNL
     ...    exception_list=@{NRPMRNL_exception_list}
    ${sum_2}    set variable    ${0}
    FOR  ${i}    IN RANGE    ${100}
        ${result}  Conn.Execute    cmd=grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'    alias=${ALIAS_ASIK}
        ${result}    Fetch From Left     ${result}   \r\n
        ${sum_2}     Evaluate    ${result}+${sum_2}
        Sleep    3s
    END
    Log To Console    Step3: Check CPU load's increase meet target
    ${sum_1}     Evaluate    ${sum_1}/${100}
    ${sum_2}     Evaluate    ${sum_2}/${100}
    ${jitter}    Evaluate    abs(${sum_2}-${sum_1})
    should be true    ${0}<${jitter}<${CPU_Jitter}

TC.CB006443_CA_01_FM_Duration_of_Alarm_Event_Reporting
    [Documentation]
    ...   Purpose:Check the duration of alarm event reporting in BTS and system
    ...   Precondition: cell on air
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Trigger alarm
    ...     Step2: Cancel alarm
    ...     Step3: Check alarm not exsit
    [Arguments]   ${alarm_report_time}=${CASE_INPUT_CB006443['CB006443_CA_01']['alarm_report_time']}
    [Teardown]    KW.WebEMRestore
    log to console    Step1: Trigger alarm
    ${Smods}    COAM_Admin.GetBTSTopology
    ${gscn_list}=  create list
    set test variable    ${gscn_list}
    FOR    ${smod}    IN    @{Smods}
        #Note:Modify ${gscn} in nrcell1 per smod to trgger fault
        ${CellID}    set variable    ${smod['BBMODs'][0]['RUs'][0]['Cells'][0]['id']}
        set test variable    ${CellID}
        Set test variable    ${version}    ${AF_PATH}
        #Note:${gscn} is different in SBTS21B stream
        run keyword if    ${version.count('SBTS21B')}>${0}
        ...    set suite variable    ${gscn}    Global synchronization channel number
        COAM_WebEM.Login
        ${gscn_org}    CM_WebEM.GetListParameter     dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CellID}    filter_param=${gscn}
        Append To List   ${gscn_list}   ${gscn_org}
        set test variable    ${gscn_org}
        set suite variable    ${restored}    false
        Process.ChangeCellParameterToTestFault    filter_param=${gscn}   newvalue=${gscn_wrong}    cellid=${CellID}
        ${FM_startTime}    KW.TimerStart
        wait until keyword succeeds   1min   2s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7114
        ...    target_fault_id=7516    target_fault_name=Incorrect cell parameter configuration    target_severity=critical
        ${FM_duration}     KW.TimerStop    timestart=${FM_startTime}
        log to console    Step2: Cancel alarm
        KW.FM.CancelCriticalFault7516
        log to console    Step3: Check alarm not exsit
        Alarm.check alarm is not in active alarms    alarm_filter=7114
        set suite variable    ${restored}    true
        Should Be True     ${0}<${FM_duration}<=${alarm_report_time}       Fault reporting time is more than 60s
    END

TC.CB006443_CA_02_FM_Alarm_Upload
    [Documentation]
    ...   Purpose:The purpose of this test case is to check Alarm Load Operation is completed succesfully with requirement
    ...   Precondition: Netact has integrated,there are active alarms in webui(aleady has alarm normally,no need to trigger)
    ...   Test tools:Netact,webui
    ...   Test Steps:
    ...     Step1: Logon NetAct do Alarm Upload
    [Arguments]   ${Alarm_Upload_Durtion}=${CASE_INPUT_CB006443['CB006443_CA_02']['Alarm_Upload_Durtion']}
    log to console    Step1: Logon NetAct do Alarm Upload
    NetAct.Login   url=${netact_info['url']}
            ...    username=${netact_info['url_user']}
            ...    password=${netact_info['url_password']}
    KW.NetActGetBTSAlias
    NetAct.StartApp  app_name=Monitor
    ${duration}    NetAct.Monitor.AlarmUpload    name=${BTSALIAS}
    should be true     ${duration}>${0} and ${duration}<${Alarm_Upload_Durtion}

TC.CB006443_DA_01_LOG_Manual_Trigger_Snapshot
    [Documentation]
    ...   Purpose:Check manually triggered on-demand snapshot can be success and duration meeting requirement
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Save snapshot by choosing all log files,and check duration meet target
    [Arguments]   ${snapshot_save_time}=${CASE_INPUT_CB006443['CB006443_DA_01']['snapshot_save_time']}
    log to console    Step1:Save snapshot by choosing all log files,and check duration meet target
    COAM_WebEM.Login
    ${timestartTmp}   Get Current Date
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}
    log     ${duration_time_tmp}
    Should Be True     ${0}<${duration_time_tmp}<=${snapshot_save_time}     Snapshot collect time is more than 15 minute

TC.CB006443_DA_02_LOG_Automatically_Triggered_Snapshot
    [Documentation]
    ...   Purpose:Check snapshot is triggered by fault can be success and duration meeting requirement
    ...   Precondition:Netact is integrated.
    ...   Test tools:webui,netact
    ...   Test Steps:
    ...     Step1:Set fault number and trigger type in WebUI
    ...     Step2:Trigger fault which set in step1
    ...     Step3:Check snapshot exist in Netact logserver,and duration meet requirement.
    [Arguments]   ${FilePresentTime}=${CASE_INPUT_CB006443['CB006443_DA_02']['FilePresentTime']}
    [Teardown]    KW.WebEMRestore
    log to console    Step1:Set fault number and trigger type in WebUI
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    run keyword and ignore error     COAM_WebEM.DeleteParameter    distName=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    abbr=Fault snapshot triggers
    sleep    2s
    run keyword and ignore error     selenium_coam.add_element    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
     ...    filter_param=Fault snapshot triggers      timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number     parameter_status=Show only modified parameters    new_value=${7516}    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type      new_value=onFaultDetection    node_index=${0}    timeout=${100}
    sleep    2s
    COAM_WebEM.ValidateAndActiveParameters
    log to console    trigger fault

     log to console    Step2:Trigger fault which set in step1
     ${Smods}    COAM_Admin.GetBTSTopology
     FOR    ${smod}    IN    @{Smods}
         run keyword and ignore error    KW.CheckFilePresent
         wait until keyword succeeds   15min    10s    COAM_WebEM.Login
         ${CellID}    set variable    ${smod['BBMODs'][0]['RUs'][0]['Cells'][0]['id']}
         set test variable    ${CellID}
         ${gscn_org}    CM_WebEM.GetListParameter     dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CellID}    filter_param=${gscn}
         set test variable    ${gscn_org}
         set suite variable    ${restored}    false
         Process.ChangeCellParameterToTestFault    filter_param=${gscn}   newvalue=${gscn_wrong}    cellid=${CellID}
         wait until keyword succeeds   1min   2s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7114
         ...    target_fault_id=7516    target_fault_name=Incorrect cell parameter configuration    target_severity=critical
         log to console    Step3:Check snapshot exist in Netact logserver,and duration meet requirement.
         Timer.Start
         wait until keyword succeeds   30min   20s    KW.CheckFilePresent
         ${duration}    Timer.Stop
         log to console    ${duration}
         KW.FM.CancelCriticalFault7516
         Alarm.check alarm is not in active alarms    alarm_filter=7114
         set suite variable    ${restored}    true
         Should be true    ${0}<${duration}<=${FilePresentTime}*${60}
    END

TC.CB006443_DA_03_Remote_Syslog_Session_Start_and_Stop_Latency
    [Documentation]
    ...   Purpose:Check the BTS is enable/disable the transmission of syslog messages within required time
    ...   Precondition:
    ...   Test tools:webui,btslog
    ...   Test Steps:
    ...     Step1:Enable/disale the transmission and other releated pameters about syslog in WebEM
    ...           Note:If "Activate remote syslog transmission" is "true",modify it to "false",if it is "false",modify it to "true".
    ...     Step2:Check the BTS shall enable/disable the transmission of syslog messages within target duration
    [Arguments]   ${StartAndStopLtency}=${CASE_INPUT_CB006443['CB006443_DA_03']['StartAndStopLtency']}
    wait until keyword succeeds     10x   1s     COAM_Admin.Login
    COAM_Admin.ResetSite     timeout=1800s
    Wait Until Keyword Succeeds    6x     3min     Check all cells Should Be On Air
    log to console    Step1:enable the transmission of syslog in WebEM
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    ${res}    run keyword and ignore error    selenium_coam.delete_parameter    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog configuration
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    filter_param=Activate remote syslog transmission    new_value=false    node_index=${0}
    Run Keyword If     '${res[0]}'=='PASS'   COAM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error     selenium_coam.add_element    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
     ...    filter_param=Remote syslog configuration
    sleep    2s
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog DSCP     new_value=${1}    node_index=${0}
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog format
    ...    new_value=RFC5424     node_index=${0}
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog server IP address
    ...    new_value=${UTE_IP}    node_index=${0}
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog server IP port number
    ...    new_value=10000    node_index=${0}
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog transmit duration
    ...    new_value=2    node_index=${0}
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog transport protocol
    ...    new_value=UDP    node_index=${0}
    COAM_WebEM.ValidateAndActiveParameters
    log to console    Step2:Check the BTS shall enable/disable the transmission of syslog messages within target duration
    ${value}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1    abbr=Activate remote syslog transmission
    ${value}    set variable if    '${value}'=='true'    false     true
    ${CheckString}    set variable if    '${value}'=='true'
    ...    "update usageState to 2|finishActivation"    "update usageState to 0|finishActivation"
    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    run keyword and ignore error    run    command=cd /tmp/;rm -rf BTSLOG_DA_03_0.txt
    BtsLog.StartBTSlogCollection
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Activate remote syslog transmission    new_value=${value}    node_index=${0}
    COAM_WebEM.ValidateAndActiveParameters
    Sleep    7s
    BtsLog.StopBTSlogCollectionandGetlog
    log to console    Step2:Check the BTS shall enable/disable the transmission of syslog messages within target duration
    run    command=cat /tmp/btslog2/SYSLOG_*.LOG |grep -E ${CheckString} >> /tmp/BTSLOG_DA_03_0.txt
    ${timeEnd}    run    command=cat /tmp/BTSLOG_DA_03_0.txt|grep finishActivation|awk '{print $6}'|head -n 1|tail -1
    Should Not Be Empty     ${timeEnd}
    ${timeEnd}    convert date    ${timeEnd.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}    epoch
    ${timeStart}    run    command=cat /tmp/BTSLOG_DA_03_0.txt|grep "update usageState"|awk '{print $6}'|head -n 3|tail -1
    Should Not Be Empty     ${timeStart}
    ${timeStart}      convert date    ${timeStart.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}    epoch
    ${duration}    Evaluate    ${timeEnd}-${timeStart}
    Should be true    ${duration}>${0} and ${duration}<${StartAndStopLtency}


TC.CB006443_FA_01_WebEM_Memory_Consumption
    [Documentation]
    ...   Purpose:Check Memory consumed when WebEM application launch
    ...   Precondition:NA
    ...   Test tools:webui,ute server
    ...   Test Steps:
    ...     Step1:Login WebEM and do some operations in WebEM. Observe the memory
    [Arguments]   ${MaxFileSize}=${CASE_INPUT_CB006443['CB006443_FA_01']['MaxFileSize']}
    log to console    Step1:Login WebEM and do some operations in WebEM,and bserve the memory
    COAM_WebEM.Login
    #run in ute server
    ${result}    run    ps -e -o 'rsz,pid,comm,args,pcpu,rsz,vsz,stime,user,uid'|grep firefox|awk '{sum += $1} END {print sum}'
    ${result}    Evaluate    ${MaxFileSize}-${result}
    COAM_WebEM.Logout
    should be true     ${result}>${0}

TC.CB006443_FA_02_WebEM_Number_of_Concurrent_WebEM_User_Sessions
    [Documentation]
    ...   Purpose:Check Memory consumed when WebEM application launch
    ...   Precondition:Ute's memory is enough,since 1 session takes about 1G
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Login WebEM and set max sessions num
    ...     Step2:Check create max sessions successfully,and fail to create max sessions num+1
    [Arguments]   ${MaxSession}=${CASE_INPUT_CB006443['CB006443_FA_02']['MaxSession']}
	...    ${webEMSessionLogoutTimer}=${CASE_INPUT_CB006443['CB006443_FA_02']['webEMSessionLogoutTimer']}
    log to console    Step1:Login WebEM and set max sessions num
    ${connection}    Connect to DU by ADMIN API
	${Original_MaxSession}    Run Keyword And Continue On Failure    Update or Create parameter by Admin API
       ...    class_name=LUAC_A     parameter_Abbreviation=btsEMMaxSimulSession
	   ...    Expected_Value=${MaxSession}    Dist_name=${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1
	${Original_LogoutTimer}    Run Keyword And Continue On Failure    Update or Create parameter by Admin API
       ...    class_name=LUAC_A     parameter_Abbreviation=webEMSessionLogoutTimer
	   ...    Expected_Value=${webEMSessionLogoutTimer}    Dist_name=${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1
    set test variable    ${Original_MaxSession}
	set test variable    ${Original_LogoutTimer}

	run keyword and ignore error     KW.CleanFirefox

    log to console    Step2:Check create max sessions successfully,and fail to create max sessions num+1
    ${stream}   Set Variable if  ${AF_PATH.count('SBTS')}>${0}    sbts   gnb
    ####The package selenium from python can't be called directly.
    #${driver}    ${pagePart}    CreateWebDriver
    #input_usr_and_pwd_then_click_login_button
    #    ...    driver=${driver}  pagePart=${pagePart}  url=${WEBUI_URL}  usr=${WEBUI_USERNAME}  pwd=${WEBUI_PASSWORD}  stream=${stream}
    #Sleep    5s
    ####The package selenium from python can't be called directly.
    ${connection}    run keyword and ignore error    Connect to DU by ADMIN API
	${session_number}    Check exist session

    ${PortMax}     Evaluate    ${MaxSession}-${session_number}+1
    FOR    ${i}    IN RANGE    ${PortMax}
	    log to console   this is ${i}
        Run Keyword And Continue On Failure    Connect to DU by ADMIN API    connection_AdminApi=DU${i}
        sleep    2s
    END
    ${session_number}    Check exist session
    selenium_sbts.enable_virtual_display
    ${return_message}    Run Keyword And Continue On Failure    selenium_sbts.login
    ...    url=${WEBUI_URL}    username=${WEBUI_USERNAME}  password=${WEBUI_PASSWORD}
    ...    version=${stream}    alias=sbts1
    selenium_sbts.disable_virtual_display
    FOR    ${i}    IN RANGE    ${PortMax}
	    log to console   this is ${i}
        Run Keyword And Continue On Failure    DisConnect to DU by ADMIN API    connection_AdminApi=DU${i}
        sleep    2s
    END
    run keyword and ignore error     selenium_sbts.logout
    Should Contain    ${return_message}      Sessions number limit reached
	[Teardown]   Run Keywords    run keyword and ignore error    Update or Create parameter by Admin API
       ...    class_name=LUAC_A     parameter_Abbreviation=btsEMMaxSimulSession
	   ...    Expected_Value=${Original_MaxSession}    Dist_name=${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1
	...    AND    run keyword and ignore error    Update or Create parameter by Admin API
       ...    class_name=LUAC_A     parameter_Abbreviation=webEMSessionLogoutTimer
	   ...    Expected_Value=${Original_LogoutTimer}    Dist_name=${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1
	...    AND    run keyword and ignore error  DisConnect to DU by ADMIN API

TC.CB006443_FA_03_WebEM_Duration_of_Loading_WebEM_Application
    [Documentation]
    ...   Purpose:Check the duration of loading WebEM application
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Launch browser to enter WebEM URL
    ...     Step2:Check durantion from "the operator navigates to the WebEM URL" to "login window visible" meet target
    [Arguments]   ${Duration_Loading_WebEM}=${CASE_INPUT_CB006443['CB006443_FA_03']['Duration_Loading_WebEM']}
    log to console    Step1:Launch browser to enter WebEM URL
    ${display}    ${driver}   ${pagePart}    SG1_coam_driver_open
    log to console    Step2:Check durantion from "the operator navigates to the WebEM URL" to "login window visible" meet target
    ${startTime}    KW.TimerStart
    inputurl_and_wait_element    driver=${driver}   pagePart=${pagePart}   url=${WEBUI_URL}
    ${duration}   KW.TimerStop    timestart=${startTime}
    SG1_coam_driver_close    driver=${driver}    display=${display}
    should be true    ${0}<${duration}<${Duration_Loading_WebEM}

TC.CB006443_FA_04_WebEM_Duration_of_Login_WebEM_Application
    [Documentation]
    ...   Purpose:Check the duration of login WebEM
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Open WebEM URL input username and password then click "Login"
    ...     Step2:Check duration from click "Login" to full webem application visiable.
    [Arguments]   ${Login_duration_time}=${CASE_INPUT_CB006443['CB006443_FA_04']['Login_duration_time']}
    log to console    Step1:Open WebEM URL input username and password then click "Login"
    ${display}  createDiplay
    enableDisplay  ${display}
    ${driver}  createDriver
    ${pagePart}  createPagePart  ${driver}
    set test variable     ${driver}
    set test variable     ${pagePart}
    set test variable     ${display}
     ${stream}   Set Variable if  ${AF_PATH.count('SBTS')}>${0}    sbts   gnb
    input_usr_and_pwd_then_click_login_button
    ...    driver=${driver}  pagePart=${pagePart}  url=${WEBUI_URL}  usr=${WEBUI_USERNAME}  pwd=${WEBUI_PASSWORD}  stream=${stream}
    log to console    Step2:Check duration from click "Login" to full webem application visiable.
    ${timestartTmp}   Get Current Date
    ${timestart}  convert date  ${timestartTmp}  epoch
    waitLegalStatementApper  ${pagePart}
    ${timeendTmp}  Get Current Date
    confirmLegalStatement  ${pagePart}
    ${timeend}  convert date  ${timeendTmp}  epoch
    ${duration_time_tmp}  Evaluate  ${timeend}-${timestart}
    log  ${duration_time_tmp}
    Should Be True     ${0}<${duration_time_tmp}<=${Login_duration_time}      WebEM login time is too long
    CB006443_FA.logout

TC.CB006443_FA_05_WebEM_Duration_of_Loading_WebEM_Runtime_View
    [Documentation]
    ...   Purpose:Check the duration of be able to present the runtime view to the operator
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Login in webem,check duration from click "legal notice" visible " to "runtime view" visible.
    [Arguments]   ${StartupView_Login_duration_time}=${CASE_INPUT_CB006443['CB006443_FA_05']['StartupView_Login_duration_time']}
    log to console    Step1:Login in webem,check duration from click "legal notice" visible " to "runtime view" visible.
    #Power.ResetgNB    model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    ${display}    ${driver}   ${pagePart}    SG1_coam_driver_open
    ${stream}   Set Variable if  ${AF_PATH.count('SBTS')}>${0}    sbts   gnb
    wait until keyword succeeds  15x   1min   input_usr_and_pwd_then_click_login_button
    ...    driver=${driver}  pagePart=${pagePart}  url=${WEBUI_URL}  usr=${WEBUI_USERNAME}  pwd=${WEBUI_PASSWORD}  stream=${stream}
    waitLegalStatementApper  pagePart=${pagePart}    timeout=240
    ${startTime}    KW.TimerStart
    confirmLegalStatement  pagePart=${pagePart}
    waitForRunTimeView    pagePart=${pagePart}    timeout=30
    ${duration}     KW.TimerStop    timestart=${startTime}
#    CLoseStartupPage    pagePart=${pagePart}
    SG1_coam_driver_close    driver=${driver}    display=${display}
    should be true    ${0}<${duration}<${StartupView_Login_duration_time}

TC.CB006443_FA_06_WebEM_WebEM_Remote_Tool_User_Session_Capacity
    [Documentation]
    ...   Purpose:check WebEM remote tool user session capacity
    ...   Precondition:NA
    ...   Test tools:webui,admincli
    ...   Test Steps:
    ...     Step1:Prepare admincli
    ...     Step2:Repeat to setup connection to gnb using WebEM remote tool and excute CLI command to open user session
    ...     Step3:Check connect successfully within maximum remote user sessions,and fail when sessions out of range
    [Arguments]   ${RMToolSessionCount}=${CASE_INPUT_CB006443['CB006443_FA_06']['RMToolSessionCount']}
    ...    ${Stream_Version}=${CASE_INPUT_CB006443['StreamPrefix']}
    log to console    Step1:Prepare admincli
    KW.PrepareAdminCli    Stream_Version=${Stream_Version}
    log to console    Step2:Repeat to setup connection to gnb using WebEM remote tool and excute CLI command to open user session
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    ${cmd}   set variable   --bts-host=${ASIK_IP} --bts-port=443 --insecure=false --bts-username=${WEBUI_USERNAME} --bts-password=${WEBUI_PASSWORD}
    ${PortMaxR}    Evaluate    ${9001}+${RMToolSessionCount}
    ${PortMax}    Evaluate     ${9000}+${RMToolSessionCount}
    FOR    ${i}    IN RANGE    ${9000}   ${PortMaxR}
        run    command=cd ${CLI_PATH}&&./admin-cli.sh --cli-port=${i} ${cmd} >log${i}.txt&
        Sleep    5s
        ${result}    run    command=cd ${CLI_PATH}&&cat log${i}.txt
        log to console    Step3:Check connect successfully within maximum remote user sessions,and fail when sessions out of range
        run keyword if   ${i}!=${PortMax}    should be true    ${result.count('BTS connected')}>0
        ...    ELSE    should be true    ${result.count('session establishment failure')}>0
    END
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9

TC.CB006443_FA_07_WebEM_WebEM_Remote_Tool_Connection_Request_Latency_Standalone_mode
    [Documentation]
    ...   Purpose:Check WebEM Remote Tool in standalone mode shall provide the request feedback to the user within target duration
    ...   Precondition:NA
    ...   Test tools:webui,admincli
    ...   Test Steps:
    ...     Step1:Prepare admincli
    ...     Step2:Execute an ADMIN CLI command in stanadalone mode and check the output time
    ...           Note1:Only need to care steps,could refer other material if you want to konw more about remote tool,
    ...                eg:standalone mode's concept.
    ...           Note2: Target duration is starting from the time of the initialization of the application in
    ...                 standalone mode,until the time the user receives the request response (i.e. process response).
    ...                 but only check duration for executing command in TA case since duration is much smaller than target.
    [Arguments]   ${RMToolRequestLatency}=${CASE_INPUT_CB006443['CB006443_FA_07']['RMToolRequestLatency']}
    ...    ${Stream_Version}=${CASE_INPUT_CB006443['StreamPrefix']}
    log to console    Step1:Prepare admincli
    KW.PrepareAdminCli    Stream_Version=${Stream_Version}
    log to console    Step2:Execute an ADMIN CLI command in stanadalone mode and check the output time
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    ${cmd}   set variable    ./admin-cli.sh --bts-username=${WEBUI_USERNAME} --bts-password=${WEBUI_PASSWORD} --bts-host=${ASIK_IP}
    ${cmd}   set variable    ${cmd} --bts-port="443" --secure="true" --data="{\"requestId\":1,\"parameters\":{\"name\":\"getActiveAlarms\"}}"
    Timer.Start
    ${result}    run    command=cd ${CLI_PATH}&&${cmd}
    ${duration}    Timer.Stop
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    should be true    ${duration}<${RMToolRequestLatency} and ${duration}>${0}

TC.CB006443_FA_08_WebEM_WebEM_Remote_Tool_Connection_Latency_Server_mode
    [Documentation]
    ...   Purpose:Check The WebEM Remote Tool in server mode shall enable the connection to the BTS/DU within target duration
    ...   Precondition:NA
    ...   Test tools:webui,admincli
    ...   Test Steps:
    ...     Step1:Prepare admincli
    ...     Step2:Execute ADMIN CLI command in server mode and check the output time when BTS connected.
    ...           Note:Only need to care steps,could refer other material if you want to konw more about remote tool.
    ...                eg:server mode's concept.
    [Arguments]   ${RMToolConnectionLatency}=${CASE_INPUT_CB006443['CB006443_FA_08']['RMToolConnectionLatency']}
    ...    ${Stream_Version}=${CASE_INPUT_CB006443['StreamPrefix']}
    log to console    Step1:Prepare admincli
    KW.PrepareAdminCli    Stream_Version=${Stream_Version}
    log to console    Step2:Execute ADMIN CLI command in server mode and check the output time when BTS connected.
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    ${cmd}   set variable    ./admin-cli.sh --cli-port=9000 --bts-host=${ASIK_IP} --bts-port=443 --insecure=false
    ${cmd}   set variable    ${cmd} --bts-username=${WEBUI_USERNAME} --bts-password=${WEBUI_PASSWORD}
    Timer.Start
    ${result}    run    command=cd ${CLI_PATH}&&${cmd}>log_FA_08.txt&
    FOR  ${i}   IN RANGE    ${30}
        ${result}    run    command=cd ${CLI_PATH}&&cat log_FA_08.txt
        Run Keyword If    ${result.count('BTS connected')}>0    Exit For Loop
        Sleep    1s
    END
    ${duration}    Timer.Stop
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    should be true    ${duration}<${RMToolConnectionLatency} and ${duration}>${0}

TC.CB006443_FA_09_WebEM_WebEM_Remote_Tool_Request_Latency_Server_mode
    [Documentation]
    ...   Purpose:Check the WebEM Remote Tool in server mode shall provide the request feedback to the user within target duration
    ...   Precondition:NA
    ...   Test tools:webui,admincli
    ...   Test Steps:
    ...     Step1:Prepare admincli
    ...     Step2:Execute an ADMIN CLI command in stanadalone mode and check the output time
    ...           Note1:Only need to care steps,could refer other material if you want to konw more about remote tool,
    ...                eg:standalone mode's concept.
    ...           Note2: Target duration is starting from the time of the initialization of the application in
    ...                 standalone mode,until the time the user receives the request response (i.e. process response).
    ...                 but only check duration for executing command in TA case since duration is much smaller than target.
    [Arguments]   ${RMToolRequestLatencyServerMode}=${CASE_INPUT_CB006443['CB006443_FA_09']['RMToolRequestLatencyServerMode']}
    ...    ${Stream_Version}=${CASE_INPUT_CB006443['StreamPrefix']}
    log to console    Step1:Prepare admincli
    KW.PrepareAdminCli    Stream_Version=${Stream_Version}
    log to console    Step2:Execute an ADMIN CLI command in stanadalone mode and check the output time
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    ${cmd}   set variable    ./admin-cli.sh --cli-port=9002 --bts-host=${ASIK_IP} --bts-port=443 --insecure=false
    ${cmd}   set variable    ${cmd} --bts-username=${WEBUI_USERNAME} --bts-password=${WEBUI_PASSWORD}
    ${result}    run    command=cd ${CLI_PATH}&&${cmd}>log_FA_09.txt&
    ${cmd}   set variable    ./agent-cli.sh --cli-port=9002 --data="{\\\"requestId\\\":1,\\\"parameters\\\":{\\\"name\\\":\\\"getActiveAlarms\\\"}}"
    Timer.Start
    ${result}    run    command=cd ${CLI_PATH}/agent-cli&&${cmd}
    ${duration}    Timer.Stop
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    should be true    ${duration}<${RMToolRequestLatencyServerMode} and ${duration}>${0}

TC.CB006443_SWM_Software_Upgrade
    [Arguments]   ${max_num}=800   ${stream}=${TargetStream}    ${status}=[released ,released_with_restrictions]
    ...           ${conditions}=${condition_PS_same}
    set suite variable     ${SWM}     ${1}
    run    command=rm -rf ${UPDATE_FILE_PATH}
    sleep   10s
    run    command=mkdir ${UPDATE_FILE_PATH}
    ${TargetBuildVersion}=         Set Variable         ${TARGETSW}
    ${OriginalBuildVersion}=       KW.SWM.FilterGetGNBSWVersion      Target_build=${TargetBuildVersion}   max_num=${max_num}
    ...               stream=${stream}    status=${status}       conditions=${conditions}
    log to console    original=${OriginalBuildVersion}
    log to console    target=${TargetBuildVersion}
    #RUN KEYWORD AND CONTINUE ON FAILURE    KW.SWM.PrepareOriginalENVbyYAFT    build_version=${OriginalBuildVersion}
   # RUN KEYWORD IF   '${CheckOnAir_flag}'=='${True}'    RUN KEYWORD AND CONTINUE ON FAILURE
    #...    wait until keyword succeeds    30min    60s    DU_WebEM.LogIn and Check all NR Cell On Air
    #...    login_flag=${True}    connection=${connection}    wait_time=${wait_time}    reset_flag=${True}

    KW.KPI2_Prepare_SW_Update    SW1_name=${OriginalBuildVersion}
    log to console    package prepared
    ${Target_package_path}        SoftwareUpdate.Download_gNB_Package    build_version=${TargetBuildVersion}
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    log to console    Download SW build with activate
    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    log to console   start to  load software
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${Target_package_path}
    log to console    ${load_result}
    ${download_startTime}    KW.TimerStart
    log to console   start to software update with active
    selenium_coam.software_update     is_activate=${True}
    log to console   finish KW selenium_coam.software_update
    ${finish}    wait until keyword succeeds    20min    10s    check SW download progress finished
    ${SW_download_duration}     KW.TimerStop    timestart=${download_startTime}
    log to console   download duration is ${SW_download_duration}
    set suite variable     ${SW_download_duration}
    set suite variable     ${SWM}     ${2}
    Log To Console   Software Update Finished, Waiting For Resetting...
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    Wait until keyword succeeds    10min    10s    CB006443_Resouce.gNB.CheckgNBReset
    ${active_startTime}    KW.TimerStart
    log to console    waitAllCellsOnair
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	${reset_time_ref}      convert date    ${timestamp_log}    epoch
	set suite variable    ${reset_time_ref}
    wait until keyword succeeds    30min    10s    Check all cells Should Be On Air
    ${SW_active_duration}     KW.TimerStop    timestart=${active_startTime}
    ${SW_upgrade_duration}     KW.TimerStop    timestart=${download_startTime}
    log to console    active duration is ${SW_active_duration}
    log to console    KPI4 duration is ${SW_upgrade_duration}
    set suite variable     ${SW_active_duration}
    set suite variable     ${SW_upgrade_duration}
    set suite variable     ${SWM}     ${3}
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}



TC.CB006443_IA_01_SWM_Max_Duration_of_SW_Download
    [Documentation]  This case is to verify max duration of Software download.For 21A,target is 15min.For 22R1,see OM_GEN_SFS_PERF_CAP.10589
    ...  Test Steps:
    ...    Step1: check if SWM case was run, if not then do SWM software upgrade
    ...    Step2: ${SWM}=${2} means software download is finished.If ${SWM}<${2} that means sw download is not execute and failed
    ...    Step3: check sw loadload duration should be not over target.
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different release.
    ...    {CASE_INPUT_CB006443['CB006443_IA_01']['SW_Download_MAX']}: SW download max duration
    [Arguments]   ${SW_Download_MAX}=${CASE_INPUT_CB006443['CB006443_IA_01']['SW_Download_MAX']}
    Set Test Variable  ${target_kpis}
     Run keyword if    ${SWM}==${0}    TC.CB006443_SWM_Software_Upgrade
     Run keyword if    ${SWM}<${2}     Fail    Step not execute
     log    ${SW_download_duration}
     Should Be True     ${0}<${SW_download_duration}<=${SW_Download_MAX}


TC.CB006443_IA_02_OAM_KPI_2a_SWM_Outage_Duration_of_SW_Activation_Inter_Release_without_SM_Firmware_Upgrade
     [Documentation]  KPI#2a - Inter-release SW activation downtime without firmware update.
     ...  Precondition:This case needs preparing SCF for originail Stream in gnb_configuration,
     ...               because after YAFT to original stream, SCF may be lost.
     ...  Test Steps:
     ...    Step1: YAFT SW to original stream build which the firmware is same with target build, Run Software upgrade case
     ...    Step2: check KPI#2a result should be not over target.
     ...  Configurtion Parameters:
     ...    TL configuration: N/A
     ...    TC configuraiton: N/A
     ...    Checkpoint configuration:The target depends on different configuration.
     ...    {CASE_INPUT_CB006443['CB006443_IA_KPI2a']['KPI2a_AVG']}: KPI2a average target
     [Arguments]   ${KPI2a_MAX}=${CASE_INPUT_CB006443['CB006443_IA_KPI2a']['KPI2a_MAX']}
     ...    ${Rollback}=${False}
    ${KPI3_MAX}    Evaluate    ${KPI2a_MAX}+${30}
    &{kpi_results}=    Create Dictionary    kpi2a=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_2a
    ims_keywords.check_instance_connection    gnbbbu
    oam_kpi_calculations.clear_results

     set suite variable     ${SWM_KPI2A}     ${1}
     set suite variable     ${SWM}     ${0}
     Run Keyword and Continue on Failure     KW.SWM.CheckIfSWActiveRun    stream=${OriginalStream}
     set suite variable     ${SWM_KPI2A}     ${2}
     log        ${SW_active_duration}
     Run Keyword And Ignore error    log to console    SW_active is ${SW_active_duration}

    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	#${referrence_time}      convert date    ${timestamp_log}    epoch
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${timestamp_log}
    ...    referrence_time=${reset_time_ref}
    Run Keyword And Ignore error     Collect IMS File  ${LOG_PATH}/loop${timestamp_log}_ims2/
    ${status}  Run Keyword And Ignore error      Analyse IMS File   kpi_list=${kpi_list}    loop=${timestamp_log}

    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${TC_status}	   Set Variable If
    ...    "${alarm_status}"=="False" and ${30}<${duration_time_tmp}<${KPI2a_MAX}
    ...     pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${TC_status}    pass
    ${snapshot_file}    Run Keyword If    '${TC_status}'=='fail'     Run Keywords
    ...     sleep    45s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
    Run Keyword If    '${TC_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run keywords     Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${timestamp_log}_ims2/
    Should Be True     ${SW_active_duration}<=${KPI2b_MAX}
    Run Keyword And Ignore Error     Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error     Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error     Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error     Run    sudo rm -rf /tmp/*.zip
    Run Keyword And Ignore error     log to console    this loop is ${TC_status} and KPI is ${duration_time_tmp}
    Run Keyword and Continue on Failure      Should Be True     ${0}<${SW_active_duration}<=${KPI2a_MAX}

    Run Keyword If    '${Rollback}'=='${True}'    KW.KPI13_rollback    KPI13_Target=${KPI3_MAX}
   [Teardown]      Run Keyword And Ignore error    ims_keywords.instance_disconnect      gnbbbu


TC.CB006443_IA_03_OAM_KPI_2b_SWM_Outage_Duration_of_SW_activation_Inter_Release_with_SM_Firmware_Upgrade
     [Documentation]  KPI#2b - Inter-release SW activation downtime with firmware update.
     ...  Precondition:This case needs preparing SCF for originail Stream in gnb_configuration,
     ...               because after YAFT to original stream, SCF may be lost.
     ...  Test Steps:
     ...    Step1: YAFT SW to original stream build which the firmware is differnt with target build, Run Software upgrade case
     ...    Step2: check KPI#2b result should be not over target.
     ...  Configurtion Parameters:
     ...    TL configuration: N/A
     ...    TC configuraiton: N/A
     ...    Checkpoint configuration:The target depends on different configuration.
     ...    {CASE_INPUT_CB006443['CB006443_IA_KPI2b']['KPI2b_AVG']}: KPI2a average target
     [Arguments]   ${KPI2b_MAX}=${CASE_INPUT_CB006443['CB006443_IA_KPI2b']['KPI2b_MAX']}
     ...    ${Rollback}=${False}
    ${KPI3_MAX}    Evaluate    ${KPI2b_MAX}+${30}
     set suite variable     ${SWM_KPI2B}     ${1}
     set suite variable     ${SWM}     ${0}
    &{kpi_results}=    Create Dictionary    kpi2b=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_2b
    ims_keywords.check_instance_connection    gnbbbu
    oam_kpi_calculations.clear_results
    Set Test Variable  ${target_kpis}

    Run Keyword and Continue on Failure     KW.SWM.CheckIfSWActiveRun
    ...    stream=${OriginalStream}    conditions=&{condition_PS_diff}
     set suite variable     ${SWM_KPI2B}     ${2}
     Run Keyword And Ignore error    log        ${SW_active_duration}
     Run Keyword And Ignore error     log to console    SW_active is ${SW_active_duration}

    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	#${referrence_time}      convert date    ${timestamp_log}    epoch
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${timestamp_log}
    ...    referrence_time=${reset_time_ref}
    Run Keyword And Ignore error     Collect IMS File  ${LOG_PATH}/loop${timestamp_log}_ims2/
    ${status}  Run Keyword And Ignore error      Analyse IMS File   kpi_list=${kpi_list}    loop=${timestamp_log}

    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${TC_status}	   Set Variable If
    ...    "${alarm_status}"=="False" and ${30}<${duration_time_tmp}<${KPI2b_MAX}
    ...     pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${TC_status}    pass
    ${snapshot_file}    Run Keyword If    '${TC_status}'=='fail'     Run Keywords
    ...     sleep    45s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
    Run Keyword If    '${TC_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run keywords     Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${timestamp_log}_ims2/
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    Run Keyword And Ignore error     log to console    this loop is ${TC_status} and KPI is ${duration_time_tmp}
    run keyword and ignore error     ims_keywords.instance_disconnect  gnbbbu
    RUN KEYWORD AND CONTINUE ON FAILURE    Should Be True     ${SW_active_duration}<=${KPI2b_MAX}
    Run Keyword If    '${Rollback}'=='${True}'    KW.KPI13_rollback    KPI13_Target=${KPI3_MAX}
    [Teardown]     run keyword and ignore error     ims_keywords.instance_disconnect  gnbbbu


TC.CB006443_IA_04_OAM_KPI_2c_SWM_Outage_Duration_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade
     [Documentation]  KPI#2c - Intra-release SW activation downtime without firmware update.
     ...  Test Steps:
     ...    Step1: YAFT SW to same stream build which the firmware is same with target build, Run Software upgrade case
     ...    Step2: check KPI#2c result should be not over target.
     ...  Configurtion Parameters:
     ...    TL configuration: N/A
     ...    TC configuraiton: N/A
     ...    Checkpoint configuration:The target depends on different configuration.
     ...    {CASE_INPUT_CB006443['CB006443_IA_KPI2c']['KPI2c_AVG']}: KPI2c average target
     [Arguments]   ${KPI2c_MAX}=${CASE_INPUT_CB006443['CB006443_IA_KPI2c']['KPI2c_MAX']}
     ...    ${Rollback}=${False}

     set suite variable     ${SWM_KPI2C}     ${1}
     set suite variable     ${SWM}     ${0}

    ${KPI3_MAX}    Evaluate    ${KPI2c_MAX}+${30}
    &{kpi_results}=    Create Dictionary    kpi2c=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_2c
    ims_keywords.check_instance_connection    gnbbbu
    oam_kpi_calculations.clear_results
    Set Test Variable  ${target_kpis}

    Run Keyword and Continue on Failure     KW.SWM.CheckIfSWActiveRun
    ...    stream=${TargetStream}   conditions=&{condition_PS_same}
    set suite variable     ${SWM_KPI2C}     ${2}
    Run Keyword And Ignore error    log        ${SW_active_duration}
    Run Keyword And Ignore error    log to console    SW_active is ${SW_active_duration}
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	#${referrence_time}      convert date    ${timestamp_log}    epoch
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${timestamp_log}
    ...    referrence_time=${reset_time_ref}
    Run Keyword And Ignore error     Collect IMS File  ${LOG_PATH}/loop${timestamp_log}_ims2/
    ${status}  Run Keyword And Ignore error      Analyse IMS File   kpi_list=${kpi_list}    loop=${timestamp_log}

    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${TC_status}	   Set Variable If
    ...    "${alarm_status}"=="False" and ${30}<${duration_time_tmp}<${KPI2c_MAX}
    ...     pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${TC_status}    pass
    ${snapshot_file}    Run Keyword If    '${TC_status}'=='fail'     Run Keywords
    ...     sleep    45s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
    Run Keyword If    '${TC_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run keywords     Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${timestamp_log}_ims2/
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    Run Keyword And Ignore error     log to console    this loop is ${TC_status} and KPI is ${duration_time_tmp}
    run keyword and ignore error     ims_keywords.instance_disconnect  gnbbbu
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be True     ${0}<${SW_active_duration}<=${KPI2c_MAX}
    Run Keyword If    '${Rollback}'=='${True}'    KW.KPI13_rollback    KPI13_Target=${KPI3_MAX}
    [Teardown]     run keyword and ignore error     ims_keywords.instance_disconnect  gnbbbu

TC.CB006443_IA_05_OAM_KPI_2d_SWM_Outage_Duration_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade
    [Documentation]  KPI#2d - Intra-release SW activation downtime with firmware update.
    ...  Test Steps:
    ...    Step1: YAFT SW to same stream build which the firmware is different with target build, Run Software upgrade case
    ...    Step2: check KPI#2c result should be not over target.
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different configuration.
    ...    {CASE_INPUT_CB006443['CB006443_IA_KPI2c']['KPI2c_AVG']}: KPI2c average target
    [Arguments]   ${KPI2d_MAX}=${CASE_INPUT_CB006443['CB006443_IA_KPI2d']['KPI2d_MAX']}
    ...    ${Rollback}=${False}
     set suite variable     ${SWM_KPI2D}     ${1}
     set suite variable     ${SWM}     ${0}

    ${KPI3_MAX}    Evaluate    ${KPI2d_MAX}+${30}
    &{kpi_results}=    Create Dictionary    kpi2d=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_2d
    ims_keywords.check_instance_connection    gnbbbu
    oam_kpi_calculations.clear_results
    Set Test Variable  ${target_kpis}

    Run Keyword and Continue on Failure     KW.SWM.CheckIfSWActiveRun
    ...    stream=${TargetStream}   conditions=&{condition_PS_diff}
    set suite variable     ${SWM_KPI2D}     ${2}
    Run Keyword And Ignore error     log        ${SW_active_duration}
    Run Keyword And Ignore error    log to console    SW_active is ${SW_active_duration}

    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	#${referrence_time}      convert date    ${timestamp_log}    epoch
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${timestamp_log}
    ...    referrence_time=${reset_time_ref}
    Run Keyword And Ignore error     Collect IMS File  ${LOG_PATH}/loop${timestamp_log}_ims2/
    ${status}  Run Keyword And Ignore error      Analyse IMS File   kpi_list=${kpi_list}    loop=${timestamp_log}

    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${TC_status}	   Set Variable If
    ...    "${alarm_status}"=="False" and ${30}<${duration_time_tmp}<${KPI2d_MAX}
    ...     pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${TC_status}    pass
    ${snapshot_file}    Run Keyword If    '${TC_status}'=='fail'     Run Keywords
    ...     sleep    45s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
    Run Keyword If    '${TC_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run keywords     Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${timestamp_log}_ims2/
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    Run Keyword And Ignore error     log to console    this loop is ${TC_status} and KPI is ${duration_time_tmp}
    run keyword and ignore error     ims_keywords.instance_disconnect  gnbbbu

    RUN KEYWORD AND CONTINUE ON FAILURE    Should Be True     ${0}<${SW_active_duration}<=${KPI2d_MAX}
    Run Keyword If    '${Rollback}'=='${True}'    KW.KPI13_rollback    KPI13_Target=${KPI3_MAX}
    [Teardown]     run keyword and ignore error     ims_keywords.instance_disconnect  gnbbbu


TC.CB006443_IA_15_OAM_KPI_4_SWM_SW_Upgrade_Time_Intra_Release
    [Documentation]  KPI#4 - Complete BTS SW upgrade. This KPI is applicable for any supported SW inter-release upgrade path
    ...      towards the target SW release and also for any SW intra-release upgrade path since 22R1.
    ...  Test Steps:
    ...    Step1: check if software upgrade case is not executed then then Run Software upgrade case with default condition.
    ...    Step2: check KPI#4 result should be not over KPI4 average target
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different configuration.
    ...    {CASE_INPUT_CB006443['CB006443_IA_KPI2d']['KPI4_AVG']}: KPI4 average target
    [Arguments]   ${KPI4_MAX}=${CASE_INPUT_CB006443['CB006443_IA_KPI4']['KPI4_MAX']}
    run keyword if   ${SWM_KPI2A}<${1} and ${SWM_KPI2B}<${1} and ${SWM_KPI2C}<${1} and ${SWM_KPI2D}<${1}
         ...    KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}
     Run keyword if    ${SWM}<${3}    Fail    Step not execute
     log        ${SW_upgrade_duration}
     Should Be True     ${0}<${SW_upgrade_duration}<=${KPI4_MAX}

TC.CB006443_IA_17_OAM_KPI_4a_SWM_SW_Upgrade_Time_Inter_Release
    [Documentation]  KPI#4a is removed after 22R1.No need to test KPI4a since 22R1. KPI#4 is including both intra and inter release.
    [Arguments]   ${KPI4a_MAX}=${CASE_INPUT_CB006443['CB006443_IA_KPI4a']['KPI4a_MAX']}
     run keyword if   ${SWM_KPI2A}<${1} and ${SWM_KPI2B}<${1}    KW.SWM.CheckIfSWActiveRun    stream=${OriginalStream}
     Run keyword if    ${SWM_KPI2A}<${2} and ${SWM_KPI2B}<${2}      Fail    Step not execute
     log        ${SW_upgrade_duration}
     Should Be True     ${SW_upgrade_duration}<=${KPI4a_MAX}


KW.WebEMRestore
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    run keyword and ignore error     selenium_coam.remove_element    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    filter_param=Fault snapshot triggers      timeout=${100}
#    run keyword and ignore error    Process.ChangeCellParameterToTestFault    filter_param=${gscn}
#    ...    newvalue=${gscn_org}    cellid=${CellID}
    Run Keyword If     '${restored}'=='true'     return from keyword
    run keyword and ignore error    KW.FM.CancelCriticalFault7516
    run keyword and ignore error    Alarm.check alarm is not in active alarms    alarm_filter=7114

KW.CheckFilePresent
    NetAct.LogServer.Connect
    ${result}    Basic.CheckFilePresentAndRemove    path=/d/oss/global/diagsnap/ne3sws    keyword=${MRBTS_ID}    alias=ANETACT_LOGSERVER
    NetAct.LogServer.Disconnect
    run keyword if    '${result}'=='NotPresent'    Fail    File Not Present

KW.PrepareAdminCli
    [Arguments]   ${Stream_Version}=${CASE_INPUT_CB006443['StreamPrefix']}
    return from keyword if    '${CLI_PATH}'!='NotSet'
    COAM_WebEM.Login
    run keyword and ignore error    COAM_WebEM.SetParameterValue  distName=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    abbr=Activate CLI    value=true
    run keyword and ignore error    COAM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error    COAM_WebEM.Logout
    run  command=cd ${LOG_PATH}&&rm -rf CLI &&mkdir CLI
    Set Suite Variable    ${CLI_PATH}    ${LOG_PATH}/CLI/
    ${StreamPrefix}    Basic.GetSBTSStreamPrefix    vstring=${TARGETSW}
    ${StreamFolder}    Set Variable if    ${TARGETSW.count('SBTS')}>0    ${StreamPrefix}/    ${EMPTY}
    ${wft_url}    Set Variable if    ${TARGETSW.count('SBTS')}>0    ${link_to_Artifact_SBTS_WFT}${StreamFolder}    ${link_to_Artifact}
    ${filename_prefix}   Set Variable if    ${TARGETSW.count('SBTS')}>0    ${EMPTY}    ${Stream_Version}

    WFT.DownloadPackage   link_to_Artifact=${wft_url}
    ...    filename=${filename_prefix}${TARGETSW}_ADMIN_CLI.zip
    ...    UPDATE_FILE_PATH=${CLI_PATH}
    run    command=cd ${CLI_PATH}&& unzip ${filename_prefix}${TARGETSW}_ADMIN_CLI.zip

KW.NetAct.Init
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['StreamPrefix']
    ...    default_value=5G21A_
    Set Suite Variable    ${CLI_PATH}    NotSet

KW.NetActGetBTSAlias
    [Timeout]    30 minutes
    NetAct.StartApp   app_name=CM Editor
    swing.Switch to Application    CM Editor
    ${path}    NetAct.CM.SelectgNB  bts_name=${MRBTS_ID}
    ${INODE}   ${BTSNode}   Split String From Right    string=${path}   separator=|     max_split=1
    set global variable    ${BTSPATH}    ${path}
    set global variable    ${INODE}    ${INODE}
    ${BTSAlias}    NetAct.CM.GetBTSAliasName
    set global variable    ${BTSALIAS}   ${BTSAlias}
    Log to Console    debug:SelectgNB Finished \ successfully.
    run keyword and ignore error    NetAct.CloseApp  app_name=CM Editor

KW.LoginWithAlias
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]       ${url}=${WEBUI_URL}    ${alias}=None
    #run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    wait until keyword succeeds  15x   1min  selenium_coam.login
    ...    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}    alias=${alias}

KW.TimerStart
    ${timeTmp}   Get Current Date
    ${timestart}      convert date    ${timeTmp}    epoch
    [Return]     ${timestart}

KW.TimerStop
    [Arguments]   ${timestart}
    ${timeTmp}    Get Current Date
    ${timeend}    convert date    ${timeTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    [Return]     ${duration_time_tmp}

KW.CleanFirefox
    Log to Console    CleanFirefox
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver

TestteardownforWebEM
    [Documentation]    History: add step collect snapshot
    Set test Variable    ${CLI_PATH}    NotSet
    Run Keyword If Test Failed   run keyword and ignore error    WEBUI.Collect snapshot
    Run Keyword And Ignore Error    run    command=ps xafu |grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    Run Keyword And Ignore Error         KW.CleanFirefox
    TestCase.Stop

TestteardownforWebEM_tmp
    ${res}     run keyword and ignore error     COAM_Admin.CheckAllCellsOnair
    run keyword if   '${res[0]}'=='FAIL'    Power.ResetgNB     model=${model}
    wait until keyword succeeds    10min    20s    COAM_Admin.CheckAllCellsOnair
    TestteardownforWebEM

Start BTSlogs Collection
    [Documentation]    collect syslogs from ute VM.
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz ${LOG_PATH}


KW.CP Suite setup for 6443
    [Documentation]
    [Arguments]
    gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache

KW.CP Teardown Suite
    TestSuite.Stop

AA_Teardown case
    TestteardownforWebEM
    gNB.Commission   scf_file=${BACKUP_SCF}
    Wait Until Keyword Succeeds    15min    2min    DU_WebEM.LogIn and Check all NR Cell On Air

####################################### CB006443-BA PM #######################################
Change PM ReportingInterval
    [Arguments]    ${pm_time}
    Wait Until Keyword Succeeds    2 times    30s
    ...    COAM_WebEM.SetParameterValue    ${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1    Performance measurement data reporting interval
    ...    value=${pm_time}
     CM_WebEM.ValidateAndActiveParameters

BA_01_Teardown case
    TestteardownforWebEM

KW.PM_exist
    [Arguments]    ${pm_order}=1
    ${PM_exist}=         ssh.execute
    ...      command=cd /tmp;ls -lh PM*.ANY.xml.gz | awk '{if(NR==${pm_order})print}'     connection=${ALIAS_ASIK}
    Should Not Be Empty    ${PM_exist}
    Should Not Contain Any     ${PM_exist}       No such file or directory     cannot

KW.ModifyPMPeriod
    [Arguments]    ${FileINTERVAL}=15min     ${PMINTERVAL}=15min
    COAM_WebEM.Login
    run keyword and ignore error    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ...      abbr=Performance measurement data reporting interval                            value=${FileINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement Interval for NR Beamforming                                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Carrier Aggregation Central Unit (CU)          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Carrier Aggregation Distributed Unit (DU)      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Cell Availability                              value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Cell Utilization per PLMN                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Cell Utilization                               value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR DL HARQ                                        value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement Interval for NR DL Signal Quality Level                        value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR DL signal quality level 2                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR E1AP Interface Report per BTS                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR E1AP Interface Report per CU-CP for NSA        value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR E1AP Interface Report per CU-CP for SA         value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR E1AP Interface Report per CU-UP E1 Interface   value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR E1AP Interface Report per CU-UP for NSA        value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR E1AP Interface Report per CU-UP for SA         value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR eCPRI U-Plane & Fast-C-Plane                   value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR equivalent isotropic radiated power            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR EN DSS per New Radio cell                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR F1AP Interface Report per CELL                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR F1AP Interface Report per DU                   value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR F1-U Interface Report BTS                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR F1-U Interface Report DU                       value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR F1AP Interface Report for CU per DU            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement Interval for NR GNSS synchronization measurements              value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR High RLC Report                                value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Inter Frequency PS-Cell Change                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Low RLC Report                                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for Enforced LTE measurement gap reports per Cell     value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement Interval for NR LTE Mobility Report                            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR MAC PDU throughput                             value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR MAC SDU Report                                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Measurement Gaps                               value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement Interval for NR Mobility CU                                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement Interval for NR Mobility DU                                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR adjacent E-UTRAN Cell                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR mobility between gNB cell and E-UTRAN cell     value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for New Radio NR mobility profiles                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR PDU Session DL Forwarding                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for Central unit (CU) traffic measurement             value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR NGC Interface per BTS                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR NG-U Interface Report                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR PDCP Report 1                                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR PDCP Report 2                                  value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR Paging                                         value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR PDCCH                                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR PDCP-C Report                                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Intra Frequency PS-Cell Change                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR RAN Sharing                                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR RRC Interface Report per CELL                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR RRC Interface Report per DU                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for Standalone (SA) Central unit (CU) Radio admission control measurement
    ...      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for Standalone (SA) Distributed unit (DU) Radio admission control
    ...      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for Standalone (SA) gNB traffic measurement            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR RAN Sharing UP                                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for Central unit (CU) Radio admission control measurement
    ...      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for Distributed unit (DU) Radio admission control measurement
    ...      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR RACH Usage                                       value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Radio Bearer                                     value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR RLF Report per CELL                              value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR S1-U Interface                                   value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for SFP BBMOD                                           value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for SFP RMOD                                            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for SFP SMOD                                            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Slice per CU-CP                                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR PDCP Slice per CU-UP.                            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR NSA Signaling Radio Bearer in the gNB-CU         value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR NSA Signaling Radio Bearer in gNB-DU             value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR service availability statistics                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR Timing Advance                                   value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR NSA UE State New RadioCELL level                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR UL HARQ                                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR UL Signal Quality Level                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR X2-C Interface signaling New RadioBTS level      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR X2-C Interface signaling New RadioCELL level     value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR X2-U Interface Report                            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR XN-C Interface signaling New RadioCELL level     value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR XN Interface                                     value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Measurement interval for NR XN-U Interface Report BTS                        value=${PMINTERVAL}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    COAM_WebEM.Logout

####################################### CB006443-CA  FM #######################################
Process.ChangeCellParameterToTestFault
     [Arguments]    ${filter_param}   ${newvalue}    ${cellid}=1
    CM_WebEM.ModifyAndActiveListParameters    ${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cellid}
    ...   ${filter_param}   ${0}    ${newvalue}

CM_WebEM.ModifyAndActiveListParameters
    [Arguments]    ${dist_name}    ${filter_param}    ${node_index}     ${new_value}
    ${string}    Convert To String    ${new_value}
    Wait Until Keyword Succeeds    2 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${dist_name}    filter_param=${filter_param}    node_index=${node_index}    new_value=${string}
    CM_WebEM.ValidateAndActiveParameters

CM_WebEM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

CM_WebEM.GetListParameter
    [Arguments]    ${dist_name}=MRBTS-1908/NRBTS-1050/NRCELL-1    ${filter_param}=First PDCCH monitoring occasion of paging occasion
    ...   ${node_index}=${0}
    ${value}   Wait Until Keyword Succeeds    2 times    30s
    ...    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}    filter_param=${filter_param}    node_index=${node_index}
    [Return]       ${value}

Process.Check fault 7516 is raised with expected severity
     [Arguments]   ${target_severity}=major
    wait until keyword succeeds   1min   10s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7114
    ...    target_fault_id=7516    target_fault_name=Incorrect cell parameter configuration    target_severity=${target_severity}


Alarm.Check Certain Alarm with Severity form Active Alarms
    [Arguments]     ${target_alarm_id}    ${target_fault_id}    ${target_fault_name}    ${target_severity}
    ${alarm_info}    selenium_coam.get_active_alarm_info
    Set test variable    ${alarm_info}
    ${length}    Get length     ${alarm_info}
    FOR    ${i}    IN RANGE    ${length}
        ${res}    run keyword and return status    Alarm.Check Certain Alarm  alarm_id=${alarm_info[${i}]['Alarm ID']}
        ...    fault_id=${alarm_info[${i}]['Fault ID']}    fault_name=${alarm_info[${i}]['Fault name']}   target_alarm_id=${target_alarm_id}
        ...    target_fault_id=${target_fault_id}    target_fault_name=${target_fault_name}    severity=${alarm_info[${i}]['Severity']}
        ...    target_severity=${target_severity}
        Run Keyword If    ${res}    Exit For Loop
    END
    run keyword if  not ${res}   Fail    Alarm ${target_alarm_id} not found!

Alarm.Check Certain Alarm
    [Arguments]   ${alarm_id}    ${fault_id}    ${fault_name}   ${target_alarm_id}    ${target_fault_id}    ${target_fault_name}
    ...   ${severity}   ${target_severity}
    run keyword and ignore error    should contain   container=${alarm_id}   item=${target_alarm_id}
    Run Keyword And Continue On Failure    should contain   container=${fault_id}   item=${target_fault_id}
    Run Keyword And Continue On Failure    should contain   container=${fault_name}   item=${target_fault_name}
    Run Keyword And Continue On Failure    should contain   container=${severity}   item=${target_severity}

Alarm.check alarm is not in active alarms
    [Arguments]      ${alarm_id}
    @{alarms}    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_id}
    should be empty    ${alarms}

KW.FM.CancelCriticalFault7516
    COAM_WEBEM.LockUnlcokCell    cell_idx=${CellID}    action=lock
    Process.ChangeCellParameterToTestFault    filter_param=${gscn}   newvalue=${gscn_org}    cellid=${CellID}
    COAM_WEBEM.LockUnlcokCell    cell_idx=${CellID}    action=unlock

#######################################  CB006443-FA   WebEM  #######################################

CB006443_FA.logout
     KW.CleanFirefox


KW.Reset.RUPowerOff
    [Arguments]    ${ru_index}=1
    ${i}    Evaluate    ${ru_index}-${1}
     Power.OnOff     pdu_ip=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
     ...                 Port_Number=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
     ...                 Action=power_off
     ...                 model=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}

KW.Reset.RUPowerOn
    [Arguments]    ${ru_index}=1
    ${i}    Evaluate    ${ru_index}-${1}
     Power.OnOff     pdu_ip=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
     ...                 Port_Number=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
     ...                 Action=power_on
     ...                 model=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}

KW.CaseStatusCaluateWithoutPassRate
    [Arguments]       ${duration}=${0}    ${max}=${0}
    ${CaseSUM}        run keyword if    ${duration}<=${max}    Evaluate    ${CaseSUM}+${duration}
    ...    ELSE    Set Variable    ${CaseSUM}
    ${CaseAVGLoop}    run keyword if    ${duration}<=${max}    Evaluate    ${CaseAVGLoop}+${1}
     ...    ELSE    Set Variable    ${CaseAVGLoop}
    Set Suite Variable    ${CaseSUM}     ${CaseSUM}
    Set Suite Variable    ${CaseAVGLoop}         ${CaseAVGLoop}
#    run keyword if    '${CasePassRateStatus}'=='NotExecute'    Set Suite Variable    ${CasePassRateStatus}    PASS
#    run keyword if    ${duration}>${max}    Set Suite Variable    ${CasePassRateStatus}    FAIL

KW.CB006939_HA_05_OAM_KPI_17_Cell_Block_Unblock
    [Arguments]      ${CellBlockDurtion}    ${CellUnblockDurtion}    ${cell_idx}=1
    log to console    Step1: Trigger cell block and start BTSLog
    BtsLog.StartBTSlogCollection
#    ${CheckString_Block}    set variable     "Write auditlog for BLOCK_IND|has been changed from Online to Offline"
#    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
#    run    command=tail -f /tmp/btslog2/SYSLOG_*.LOG | grep -E ${CheckString_Block} > /tmp/BTSLOG_blockcell.txt&
    COAM_WebEM.Login
    selenium_sbts.block_cell     cell_idx=${cell_idx}
    Sleep    20s

    COAM_WebEM.Logout
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step2: Check blockcell_duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Write auditlog for BLOCK_IND"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${blockcell_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${blockcell_startTime}
    ${blockcell_startTime}     convert date
    ...    ${blockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Online to Offline"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${blockcell_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${blockcell_endTime}
    ${blockcell_endTime}        convert date
    ...     ${blockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${blockcell_duration}    Evaluate    ${blockcell_endTime}-${blockcell_startTime}
    Should Be True     ${blockcell_duration}<=${CellBlockDurtion} and ${blockcell_duration}>${0}
    log to console   blockcell duration is ${blockcell_duration}
    log to console    Step3: Trigger cell unblock and start BTSLog
    BtsLog.StartBTSlogCollection
    COAM_WebEM.Login
    selenium_sbts.unblock_cell     cell_idx=${cell_idx}
    Sleep    20s
    COAM_WebEM.Logout
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step4: Check unblockcell_duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Write auditlog for UNBLOCK_IND"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${unblockcell_startTime}     run    command=${cmd}
    Should Not Be Empty     ${unblockcell_startTime}
    ${unblockcell_startTime}     convert date
    ...     ${unblockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Offline to Online"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${unblockcell_endTime}     run    command=${cmd}
    Should Not Be Empty     ${unblockcell_endTime}
    ${unblockcell_endTime}        convert date
    ...      ${unblockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${unblockcell_duration}    Evaluate    ${unblockcell_endTime}-${unblockcell_startTime}
    Should Be True     ${unblockcell_duration}<=${CellUnblockDurtion} and ${unblockcell_duration}>${0}
    log to console   unblockcell duration is ${unblockcell_duration}

HA_KPI17_Teardown case
    [Arguments]      ${cell_idx}=${CASE_INPUT_CB006443['CB006939_HA_KPI17']['CELL'][0]['index']}
    COAM_WebEM.Login
    ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    run keyword if    '${cell_info['Status']['Blocking state']}'=="Blocked"
    ...    selenium_sbts.unblock_cell    cell_idx=${cell_idx}
    sleep   10s
    COAM_WebEM.Logout
    TestteardownforWebEM

KW.CB006443_HA_07_OAM_KPI_16_Cell_Lock_Unclock
    [Arguments]      ${CellLockUnLockDurtion}    ${cell_idx}=1
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    Timer.Start
    wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=lock    checkstatus=false
    log to console    lock start
    FOR    ${i}    IN RANGE    ${60}
        ${res}    run keyword and ignore error    COAM_WEBEM.CheckLockUnlcokCellStatus     cell_idx=${cell_idx}    status=Locked
        Exit For Loop If    '${res[0]}'=='PASS'
        Sleep    1s
    END
    ${duration_1}     Timer.Stop
    Timer.Start
    wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}     action=unlock    checkstatus=false
    log to console    unlock start
    FOR    ${i}    IN RANGE    ${60}
        ${res}    run keyword and ignore error    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}    status=Unlocked
        Exit For Loop If    '${res[0]}'=='PASS'
        Sleep    1s
    END
    ${duration_2}     Timer.Stop
    Should be true    ${duration_1}<${CellLockUnLockDurtion} and ${duration_2}<${CellLockUnLockDurtion}
#######################################  CB006443-IA   SWM  #######################################
KW.SWM.PrepareOriginalENVbyYAFT
    [Arguments]    ${build_version}
    ${Smods}    COAM_Admin.GetBTSTopology
    ${length}=   Get Length   ${Smods}
    Run Keyword And Ignore Error    log to console    Smods length is ${Smods}
    run keyword if    ${build_version.count('${TargetStream}')}>0    Set Suite Variable    ${gSCF}    ${CurrentStreamSCF}
    ...    ELSE       Set Suite Variable    ${gSCF}    ${OriginalStreamSCF}
    Run Keyword And Ignore Error    log to console      SCF is ${gSCF}
    run keyword if  '${length}'=='1'      KW.SWM.PrepareOriginalBuildEnv    build_version=${build_version}    scf=${gSCF}
    #...    ELSE    KW.SWM.PrepareENVDualCore    build_version=${build_version}

#This KW is not used in CB006443 and CB008181

KW.SWM.PrepareOriginalBuildEnv
    [Arguments]    ${build_version}    ${scf}=None
    ${upgrade_package_path}     SoftwareUpdate.Download_gNB_Package    ${build_version}
    KW.SWM.CP.PrepareEnvByYAFT    filename=${upgrade_package_path}    scf=${scf}

KW.SWM.CP.PrepareEnvByYAFT
    [Arguments]    ${filename}    ${scf}=None
    log to console    YAFT Started
    RUN KEYWORD AND CONTINUE ON FAILURE     KW.TryEnableSSH
    KW.SWM.YAFT    filename=${filename}
    log to console    Second YAFT
    KW.SWM.YAFT    filename=${filename}
    log to console    Second YAFT END and wait onair
	###official build,This KW should be run
    wait until keyword succeeds   8min   30s    KW.TryEnableSSH
    log to console    start to get streamversion
    #${StreamVersion}    Get SW release by ADMIN API    StreamVersion=${StreamVersion}
    ${connection_AdminApi}    Connect to DU by ADMIN API

    ${gnb_status}   KW.SWM.GetGNBStatus   connection=${connection_AdminApi}
    ###official build,This KW should be run
    Run Keyword If   '${gnb_status}'=='NotCommissioned'    wait until keyword succeeds    5min    10s
    ...    gNB.Commission   scf_file=${SCF}
    #RUN KEYWORD AND CONTINUE ON FAILURE     wait until keyword succeeds    5min    10s
    #...    gNB.Commission   scf_file=${SCF}
    Run Keyword And Ignore Error    log to console      Check Fault 23 is raised in RF
    ${res}    RUN KEYWORD AND CONTINUE ON FAILURE      wait until keyword succeeds    16min    10s    KW.CheckRUAlarmOrOnair
    Run Keyword And Ignore Error    log to console      Upgrade RF
    run keyword if     '${res[0]}'=='PASS'        RUN KEYWORD AND CONTINUE ON FAILURE
    ...    KW.UpGradeForRU    filename=${filename}
    [Teardown]     Run Keyword And Ignore Error    DisConnect to DU by ADMIN API
        ...    connection_AdminApi=${connection_AdminApi}

KW.SWM.FilterGetGNBSWVersion
    [Arguments]   ${Target_build}=${TARGETSW}   ${max_num}=500   ${stream}=${TargetStream}
    ...           ${status}=[released ,released_with_restrictions]
    ...           ${conditions}=${condition_PS_same}
    ...           ${Target_Build_in_File}=${CASE_INPUT_CB006443['StreamPrefix']}${Target_build}
    ${Target_build}   Set Variable if    ${TARGETSW.count('SBTS')}>0    ${Target_build}
    ...   ${Target_Build_in_File}
    Log to Console           ${Target_build}
    Log to Console           ${conditions}
    ${candidate_builds}       get_loadbuild_candidates    max_num=${max_num}   stream=${stream}   status=${status}
    ${sw_version_filtered}    filter_target_loadbuild_from_candidates
    ...           original_build=${Target_build}    candidates=${candidate_builds}     conditions=${conditions}
    Run Keyword If      '${sw_version_filtered}' == 'None'       Run Keywords
    ...           Log To Console      no condition matched build is found
    ...           AND    FAIL
    Log to Console      Latest match condition build: ${sw_version_filtered}
#    ${sw_version_filtered}     Get Regexp Matches     ${sw_version_filtered}     [0-9]+.[0-9]+.[0-9]+
#    ${sw_version_filtered}=    Set Variable      ${sw_version_filtered[0]}
    ${split_build}=    run keyword and return if     ${sw_version_filtered.count('SBTS')}==0    KW.SWM.splitBuildName    ${sw_version_filtered}
    run keyword if     ${split_build}==None    set test variable    ${filter_build}    ${sw_version_filtered}
    ...    ELSE    set test variable    ${filter_build}    ${split_build}
    Log to Console      swbuild=${sw_version_filtered}
    Log to Console      filterbuild=${filter_build}
#    [Return]   ${sw_version_filtered}
    [Return]   ${filter_build}

KW.SWM.splitBuildName
    [Arguments]    ${build}
    ${build}     Get Regexp Matches     ${build}     [0-9]+.[0-9]+.[0-9]+
    [Return]   ${build[0]}

KW.SWM.YAFT
    [Arguments]    ${filename}=AS__*.zip
    log   ${filename}
    ${case_status}    RUN KEYWORD AND RETURN STATUS    RUN KEYWORD AND CONTINUE ON FAILURE    gNB.Connect
    Run Keyword If    '${case_status}'=='False'    Run Keywords
    ...    PB.PowerOnOff     pdu_ip=${PB_DU_IP}    Port_Number=${PB_DU_PORT}    Action=both    model=${PB_DU_Vendor}
    ...    AND    gNB.Connect
    ${BOARD}    gNB.GetSystemModuleName
    gNB.Disconnect
    ssh.Connect to    hostname=${ASIK_LMP_IP}    username=${ASIK_LMP_USERNAME}
    ...    password=${ASIK_LMP_PASSWORD}     alias=${ALIAS_ASIK}
    ${newvalue}=  Catenate    SEPARATOR=   KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,
    ...     ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,
    ...     diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1
    Basic.SedReplaceLine  matchValue=MACs  newValue=${SPACE}  file=/etc/ssh/sshd_config  alias=${ALIAS_ASIK}
    Basic.SedReplaceLine  matchValue=KexAlgorithms  newValue=${newvalue}  file=/etc/ssh/sshd_config  alias=${ALIAS_ASIK}  force=true
    Conn.Execute    cmd=cat /etc/ssh/sshd_config    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=systemctl restart sshd      alias=${ALIAS_ASIK}
    sleep  10s
    ${yaft_command}    Set Variable If   '${BOARD}'=='ASIL'
    ...    cd ${YAFT_PATH} &&echo oZPS0POrRieRtu | python ./yaft.py -i ${ASIK_LMP_IP} -z ${filename} -K --ignore_FSPs --ask_for_password
    ...    cd ${YAFT_PATH} &&echo oZPS0POrRieRtu | python ./yaft.py -i ${ASIK_LMP_IP} -z ${filename} --ask_for_password
    log  ${yaft_command}
    run  sudo rm -rf ${YAFT_PATH}/YAFT_IMAGE
    ${result}  run  ${yaft_command}
    Should Contain Any   ${result}   Flashing done    Cannot establish SSH session with FCT    Waiting for FC* after reboot

KW.SWM.UpGradeForRU
    [Arguments]    ${filename}
    COAM_WebEM.Login    url=${ASIK_LMP_IP_URL}
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${filename}
    log to console    ${load_result}
    log to console   start to upgrade RU
    selenium_coam.software_update     is_activate=${True}
    ${finish}    wait until keyword succeeds    30min    10s    check SW download progress finished

KW.SWM.Init
    [Arguments]    ${Original_Stream}    ${Original_Branch}
    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion
    set suite variable    ${TARGETSW}    ${version_Target}
    set suite variable    ${TargetStream}     ${StreamTarget}
    set suite variable       ${OriginalStream}         ${Original_Stream}

    set suite variable     ${SWM}     ${0}
    set suite variable     ${SWM_KPI2A}     ${0}
    set suite variable     ${SWM_KPI2B}     ${0}
    set suite variable     ${SWM_KPI2C}     ${0}
    set suite variable     ${SWM_KPI2D}     ${0}
    ${CurrentStreamSCF}   Backup SCF from SBTS by admin
    Set Suite Variable    ${CurrentStreamSCF}     ${CurrentStreamSCF}
    Set Suite Variable    ${OriginalStreamSCF}    ${commissionings_path}/HGZ/${testline_name}/SCF_${Original_Branch}.xml
    #Set Suite Variable    ${OriginalStreamSCF}    /home/ute/SCF_${OriginalStream}.xml

KW.SWM.CheckIfSWActiveRun
    [Arguments]      ${stream}=${TargetStream}   ${conditions}=&{condition_PS_same}
     Run keyword if    ${SWM}==${0}    Run Keyword and Continue on Failure
     ...    TC.CB006443_SWM_Software_Upgrade    stream=${stream}   conditions=${conditions}
     Run keyword if    ${SWM}<${3}     Fail    Step SW active not execute

KW.SWM.GetGNBStatus
    [Arguments]   ${connection}=COAM
    ${general_status}   admin.get_bts_statuses   connection=${connection}   timeout=60
    [Return]   ${general_status['proceduralState']}
#######################################     #######################################
########prepare TL---added in CB009395 at 2023.08.03######
Prepare testline to cell onair
    [Arguments]      ${localFilePath}=${SCF_IWK_Trunk}     ${tl_scf_filename}=${SCF_IWK[0]}
    log to console    do commission with full SCF in gitlab
	Connect to gnb coam via ssl   bts_host=${DU_OAM}    username=${WEBUI_USER}    password=${WEBUI_PWD}
	COAM Commission with scf file    scf_file_path=${localFilePath}${tl_scf_filename}    timeout=500    is_pdl_checking_needed=${False}
	log to console    check all cell status start
    Wait until keyword succeeds    10min    30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

KW.TestSuilt.Start
    [Arguments]    ${Stream_Master}=${CASE_INPUT_CB006443['Stream_Version']}
    ...    ${Original_Stream_list}=${CASE_INPUT_CB006443['CB006443_IA']['OriginalStream']}
    ...    ${do_commission}=${False}
    TestSuilt.Start
    set suite variable    ${OAM_TYPE}    COAM
    set suite variable    ${TLDelta_PATH_ON_GIT}        ${CFGFILE_PATH}
    gNB.FormatBTSID       MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    ${version_Target}    Basic.GetStreamAndVersion
    set suite variable    ${TargetBTSVersion}    ${version_Target}
    KW.NetAct.Init
    ${BACKUP_SCF}   Backup SCF from SBTS by admin
    set suite variable    ${BACKUP_SCF}
    ${StreamVersion}    Get stream version     Stream_Master=${Stream_Master}
    set suite variable    ${StreamVersion}
    set suite variable    ${Original_Stream}    ${Original_Stream_list['${StreamVersion}']}
    ${Original_Branch}    Fetch from left    ${Original_Stream}    _
    set suite variable    ${Original_Branch}
    run keyword and Ignore error    KW.SWM.Init
    ...    Original_Stream=${Original_Stream}    Original_Branch=${Original_Branch}
    log to console    original stream is ${Original_Stream}
    ########prepare TL---added in CB009395 at 2023.08.03######
    Run Keyword If     '${do_commission}'=='${True}'
    ...    run keyword and Ignore error    Prepare testline to cell onair
    Wait Until Keyword Succeeds    10min    30s    DU_WebEM.LogIn and Check all NR Cell On Air
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/'*.tgz'
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*download*
    Run Keyword And Ignore Error    Run    sudo rm -rf /home/ute/Downloads/*
    Run Keyword And Ignore Error    Run    sudo rm -f /home/ute/*.zip
    Run Keyword And Ignore Error    Run    sudo rm -rf /home/coam/*




KW.TestSuilt.Stop
    Run Keyword And Ignore Error    run  sudo rm -rf ${YAFT_PATH}/YAFT_IMAGE
    Run Keyword And Ignore Error    run  sudo rm -rf ${UPDATE_FILE_PATH}
    Run Keyword And Ignore Error    robot_common_operations.Common Suite teardown


TestCase.Start_CB006443
    TestCase.Start
    KW.CleanFirefox


######################Keyword For New Report Solution######################
Get ims2 File From BTS
    [Documentation]  Gather ims2 logs to file. Connection must be created in Suite (Test) Setup.
    Connect To Admin    alias=ims2_log
    taf_admin.collect_infomodel_log_from_current_session
    ...    target_file_name=${entity_logs_path}/current_ims.ims2
    ...    timeout=300
    ...    connection=ims2_log
    [Teardown]    Disconnect From Admin    alias=ims2_log

Collect Active Alarms
    [Arguments]    ${loop}=0    ${ALLOWED_ALARMS}=${ALLOWED_ALARMS}
    ${active_alarms_list}=   ims_keywords.Get Active Alarms  allowed_alarms=${ALLOWED_ALARMS}
    Set Test Variable  ${active_alarms_list}
    ims_keywords.Save Alarms  ${active_alarms_list}  ${LOG_PATH}/loop${loop}
    Return From Keyword If  ${active_alarms_list} != @{EMPTY}   ${True}
    Return From Keyword    ${False}

###add in CB009395######
Collect new history Alarms
    [Arguments]    ${referrence_time}    ${loop}=0     ${ALLOWED_ALARMS}=${ALLOWED_ALARMS}
    ${new_history_alarms_list}=   ims_keywords.Get New History Alarms
    ...    allowed_alarms=${ALLOWED_ALARMS}    referrence_time=${referrence_time}
    Set Test Variable  ${new_history_alarms_list}
    ims_keywords.Save Alarms  ${new_history_alarms_list}  ${LOG_PATH}/loop${loop}
    Return From Keyword If  ${new_history_alarms_list} != @{EMPTY}   ${True}
    Return From Keyword    ${False}
###add in CB009395######

Collect IMS File
   [Arguments]   ${log_dir}
   ${ims_file_path}  gnb_log.Collect IMS Log From gNB  log_dir=${log_dir}  timeout=${600}
   @{ims_files}=  List Files In Directory  ${log_dir}  pattern=IMS_Log*.ims2
   #@{ims_files}=  List Files In Directory  ${log_dir}  pattern=*.bin
   Set Suite Variable  ${ims_file}  ${log_dir}${ims_files[-1]}
   #OperatingSystem.run  find ${log_dir} -name \"*.ims2\" -exec rm {} \\;

Analyse IMS File
    [Arguments]  ${kpi_list}   ${kpi_params}=${None}    ${loop}=0
    oam_kpi_calculations.Calculate Kpis  kpi_names=${kpi_list}   ims_file_path=${ims_file}    kpi_params=${kpi_params}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${LOG_PATH}/loop${loop}_ims2/results_${ext_json_name}.json
    ${result}  oam_kpi_calculations.get_results
##    [Return]    ${results}
    ims_keywords.save_kpi_to_csv_results  ${loop}  ${LOG_PATH}/loop${loop}_ims2  ${result}  ${active_alarms_list}
    FOR  ${kpi}  IN  @{kpi_list}
        ${x} = 	Combine Lists 	${kpi_results['${kpi}']} 	${result['${kpi}']}
        Set To Dictionary  ${kpi_results}  ${kpi}  ${x}
    END
    FOR  ${kpi_name}  IN  @{target_kpis}
        ${kpi}=  Set Variable  ${kpi_name.replace('KPI_', 'kpi')}
        ${kpi_avg}  oam_kpi_calculations.get_average_results  kpi_name=${kpi}
        #Return From Keyword If  ${kpi_avg} > ${CASE_INPUT_CB006443['CB006443_HA_KPI1a']['KPI1a_AVG']}  ${True}
        ${duration_time_tmp}    Set test Variable   ${kpi_avg}
    END
    Return From Keyword    ${False}

Connect to admin
    [Arguments]  ${ip_address}=${LMP_IP}        ${alias}=cOAM_admin
    ...          ${username}=${WEBEM_USERNAME}  ${password}=${WEBEM_PASSWORD}
    ${date}=	DateTime.Get Current Date
    Create directory  /home/ute/test_results/admin
    Create directory  /home/ute/test_results/admin/${date}
    ${connection}=  admin.connect_to  bts_host=${ip_address}
    ...                                                    name=${alias}
    ...                                                    username=${username}
    ...                                                    password=${password}
    ...                                                    update_interval=500
    ...                                                    admin_api_log_dir=/home/ute/test_results/admin/${date}
    [Return]  ${connection}

Disconnect From Admin
    [Arguments]  ${alias}=cOAM_admin
    admin.teardown  ${alias}

Backup SCF from SBTS by admin
   Connect to DU by ADMIN API      connection_AdminApi=backup_scf
   admin.Get Current Scf File       local_dir_path=${OUTPUT_DIR}
   ...      file_name=BackUp_scf.xml    timeout=60    connection=backup_scf
   ${CurrentStreamSCF} =    Join Path    ${OUTPUT_DIR}    ${file_name}
   set suite variable       ${CurrentStreamSCF}
   [Return]  ${CurrentStreamSCF}
   [Teardown]       run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=backup_scf

Report KPI
    [Arguments]      ${kpi_name}=kpi3    ${target_dir}=${USER_LOG_DIR}
    log to console      parameter kpi_name: "${kpi_name}" and target_dir:"${target_dir}" is not used
    ute_reporting_portal.Set reference configuration ID  ref_configuration_id=${REFERENCE_CONFIGURATION_ID}
    Report OAM KPI  oam_kpi_results=${kpi_results}  oam_kpi_targets=${OAM_KPI_TARGETS}
