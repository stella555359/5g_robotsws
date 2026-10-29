*** Settings ***
Documentation      author: Lixia Wang
...                 contact: lixia.wang@nokia-sbell.com
...                This robot file is for 5GC002479 C&P.

Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource          ../../None_Feature_SG1/OAM_Interface.robot
Resource          5GC002479_Resouce.robot
Library          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py
Library           ../../None_Feature_SG1/OAM_Interface.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.sbts.oam.coam.admin  WITH NAME   admin
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
Library           taf.ul.selenium.netact     WITH NAME     selenium_netact
#Library           ../../../../RRM/RAN_PZ_HAZ_34/5GC000638/Resources/coam_close.py
Library           timing.py
Library           5GC002479_A.py
Variables         CaseConfiguration.py
#Variables         ${CFGFILE_PATH}TLDelta.py

*** Variables ***
#Configure the TL specific variable
${USER_LOG_DIR}        /opt/ute/Logs
#${CFGFILE_PATH}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${TLDelta_PATH_ON_GIT}        ${CFGFILE_PATH}
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
${UPDATE_FILE_PATH}       /home/ute/Download_gNB_Package
${YAFT_PATH}              /opt/ute/YAFT
${WTS_FILE_PATH}       ${tl.core.dir_path}

${UTE_IP}              ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}        ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}        ${tl.test_pc.default_ssh_connection_details.password}

${ASIK_LMP_IP_Secondary}    ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}

${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_LMP_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_LMP_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

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

${PdcchMonOccsnPo}    First PDCCH monitoring occasion of paging occasion
${pdcch_wrong}     200
${gscn}    Synchronization channel number
${gscn_wrong}     26639
${PMINTERVAL}       5

&{condition_PS_same}     PS=same
&{condition_PS_diff}     PS=diff
${webEMSessionLogoutTimer}    7200 (Seconds)

${MO_Type_xpath}         //*[@id="ccMOTypecomboboxField"]
${View_xpath}            //*[@id="TreeViewcomboboxField"]
${Parent_xpath}          //input[@id="mot:::c"]
${MO_DN_xpath}           //table[@class='table table-bordered table-header']//input[@class='filter-input']
${Radio_Select_box}      //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[1]/input
${Upload_xpath}          //*[@id="belowTableActions:uploadButton"]
${Upload_status_xpath}   //*[@id="swmTable_networkView_body"]//td[@class='columnLastSoftwareTaskNS']//img[contains(@src, 'webuif/icons')]
${Operation_details_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[10]/div/span/a/span
${New_task_xpath}        //span[contains(@id, 'opActionButtons')]/input[contains(@value, 'New Task')]
${PreCheck_xpath}        //*[@id="include:createWizardForm:opTree:0:2::opNodeName"]
${PostCheck_xpath}       //*[@id="include:createWizardForm:opTree:0:5::opNodeName"]
${SW_download_xpath}       //*[@id="include:createWizardForm:opTree:0:1::opTreeNodeId:text"]
${finish_xpath}          //*[@id="include:createWizardForm:btnFinish"]
${target_software}         //*[@id="frmTaskDetails:SoftwarePackageLink"]
${Network_Operations_view_xpath}     //*[@id="beautifulForm:j_id__v_201"]
${Cancel_button_xpath}     //*[@id="TView:TTable:0:0:btnCancel"]/img
${Cancel_confirm_OK_xpath}    //*[@id="TView:cancelTaskConfirmationPanelmsgBtnOk"]
${Operation_status_xpath}    /html/body/div[2]/form[3]/span/span/div/table/tbody/tr/td[10]/div/div/div/span/a/span
##################define these variable for convenient############################
${ALIAS_ASIK}     asik    ##
${ALIAS_ASIK_SLAVE}    asik_slave    ##
${ALIAS_UTE}      ute    ##
########################END of alias Define#######################################
${BTSSWServerPath}          https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
*** Keywords ***
TC.5GC002479_AA_01_CM_Full_Plan_Download_Validation_Activation_Operations
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
    ...    Checkpoint configuration:
    ...    {AA_01['Duration_SCFLoad']}: max load scf duration
    ...    {AA_01['Duration_ValidationError']}: max validation duration of scf with error
    ...    {AA_01['Duration_Validation']}: max validation duration of scf without error
    ...    {AA_01['Duration_Activation']}: max active duration of scf without error
#    [Arguments]   ${SCF_WithError}=${CASE_INPUT_5GC002479['5GC002479_AA_01']['SCF_WithError']}
#    ...           ${SCF_NoError}=${CASE_INPUT_5GC002479['5GC002479_AA_01']['SCF_NoError']}
    [Arguments]   ${Duration_SCFLoad}=${AA_01['Duration_SCFLoad']}
    ...           ${Duration_ValidationError}=${AA_01['Duration_ValidationError']}
    ...           ${Duration_Validation}=${AA_01['Duration_Validation']}
    ...           ${Duration_Activation}=${AA_01['Duration_Activation']}
    set test variable    ${execution_result}    fail
    run   cp ${BACKUP_SCF} ${LOG_PATH}/ErrorSCF.xml
    Basic.SedReplaceLine    <p name=\\"firstEndpointDN\\">${MRBTS_ID}\\/EQM-1\\/APEQM-1\\/CABINET-1\\/SMOD-1<\\/p>
    ...    \\<p name=\\"firstEndpointDN\\"\\>${MRBTS_ID}\\/EQM-1\\/APEQM-1\\/CABINET-1\\/SMOD-10\\<\\/p\\>
    ...    ${LOG_PATH}/ErrorSCF.xml
    COAM_WebEM.Login
    BtsLog.StartBTSlogCollection
    Log To Console    Step1: Create a full configuration plan with error and load the scf on WebUI
    ${status}=    selenium_coam.load_commissioning_file_and_check_load_status
    ...           file_path=${LOG_PATH}/ErrorSCF.xml
    Should be True    ${status}
    Log To Console   Step2: Check the validation duration should no more than requirement in WebEM,
    ...           and validate the scf and check error exist.
    selenium_coam.activate_plan    download_plan_without_activation=${True}    activate_plan_despite_errors=${True}
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    ${error}    selenium_coam.get_relation_errors
    Should Not Be Empty    ${error}
    Log To Console    Step3: Check activate duration from syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PlanValidateIndScenario"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${error_validation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${error_validation_startTime}
    ${error_validation_startTime}     convert date
    ...    ${error_validation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_VALIDATE_RESULT-1 with result=Success"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${error_validation_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${error_validation_endTime}
    ${error_validation_endTime}        convert date
    ...     ${error_validation_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${error_validation_duration_tmp_AA01}    Evaluate    ${error_validation_endTime}-${error_validation_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${error_validation_duration_tmp_AA01}<=${Duration_ValidationError} and ${error_validation_duration_tmp_AA01}>${0}
    log to console    duration of full plan valdation with error is ${error_validation_duration_tmp_AA01}
    log to console    Step4: Create a full configuration plan without error and load the scf in WebUI
    ${status}=    selenium_coam.load_commissioning_file_and_check_load_status
     ...           file_path=${BACKUP_SCF}
    Should be True    ${status}
    BtsLog.StartBTSlogCollection
    Log To Console    Step5: Do validation operation in WebEM,
    ...           and Check the validation duration should no more than requirement
    selenium_coam.activate_plan    download_plan_without_activation=${True}    activate_plan_despite_errors=${True}
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step6: Check activate duration from syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PlanValidateIndScenario"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${succ_validation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${succ_validation_startTime}
    ${succ_validation_startTime}     convert date
    ...    ${succ_validation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_VALIDATE_RESULT-1 with result=Success"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${succ_validation_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${succ_validation_endTime}
    ${succ_validation_endTime}        convert date
    ...     ${succ_validation_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${succ_validation_duration_tmp_AA01}    Evaluate    ${succ_validation_endTime}-${succ_validation_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${succ_validation_duration_tmp_AA01}<=${Duration_Validation} and ${succ_validation_duration_tmp_AA01}>${0}
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty    ${error}
    log to console    duration of full plan validation without error is ${succ_validation_duration_tmp_AA01}
#    ${error}    selenium_coam.get_relation_errors
##    Should Be Empty     ${error}
    #first error load commission file
    log To Console    Step7: Check both the load scf duration should no more than defined by requirement
    ${timestart}    run    cat ${OUTPUT DIR}/debug.log |grep "load-action-button input"|awk '{print $1,$2}'|head -n 1|tail -1
    ${timestart}      convert date    ${timestart}    epoch
    ${timeend}    run    cat ${OUTPUT DIR}/debug.log |grep "END KW: selenium_coam.Load Commissioning File"|awk '{print $1,$2}'|head -n 1|tail -1
    ${timeend}      convert date    ${timeend}    epoch
    ${duration1}    Evaluate    ${timeend}-${timestart}
    log to console    ${duration1}
    should be true     ${duration1}<${Duration_SCFLoad}
    #second success load commission file
    ${timestart}    run    cat ${OUTPUT DIR}/debug.log |grep "load-action-button input"|awk '{print $1,$2}'|head -n 3|tail -1
    ${timestart}      convert date    ${timestart}    epoch
    ${timeend}    run    cat ${OUTPUT DIR}/debug.log |grep "END KW: selenium_coam.Load Commissioning File"|awk '{print $1,$2}'|head -n 2|tail -1
    ${timeend}      convert date    ${timeend}    epoch
    ${duration2}    Evaluate    ${timeend}-${timestart}
    log to console    ${duration2}
    should be true     ${duration2}<${Duration_SCFLoad}
    Log To Console    Step6: Active the scf without error and check the active duration should no more than requirement
    BtsLog.StartBTSlogCollection
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=${Duration_Activation}
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step7: Check activate duration from syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PlanActivateIndScenario"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${full_activation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${full_activation_startTime}
    ${full_activation_startTime}     convert date
    ...    ${full_activation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_ACTIVATE_RESULT-1 with result=Success"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${full_activation_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${full_activation_endTime}
    ${full_activation_endTime}        convert date
    ...     ${full_activation_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${full_activation_duration_tmp_AA01}    Evaluate    ${full_activation_endTime}-${full_activation_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${full_activation_duration_tmp_AA01}<=${Duration_Activation} and ${full_activation_duration_tmp_AA01}>${0}
    log to console    duration of full plan activation is ${full_activation_duration_tmp_AA01}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][0]}
    ...    target_value=${Duration_SCFLoad}    result_value=${duration2}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][1]}
    ...    target_value=${Duration_ValidationError}    result_value=${error_validation_duration_tmp_AA01}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][2]}
    ...    target_value=${Duration_Validation}    result_value=${succ_validation_duration_tmp_AA01}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][3]}
    ...    target_value=${Duration_Activation}    result_value=${full_activation_duration_tmp_AA01}
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_02_CM_Delta_Plan_Validation_Activation_Operations_No_Service_Outage
#    [Documentation]
#    ...   Purpose:Test case is to check configuration file_delta plan(No service outage) can be validation/activation
#    ...            successful and duration meet requirement.
#    ...   Precondition: No error after do validation.
#    ...   Test tools:WebUI
#    ...   Test Steps:
#    ...     Step1: Modify parameter which will not cause site reset but will cause error when do validation.
#    ...            eg:modify 'shutdownNogNBCellTmr' to wrong value in webem.
#    ...     Step2: Caculate validate duration(duration is captured from system) and check validation duration no more than
#    ...            requirement.
#    ...     Step3: Validate and check error exist on WebEM.
#    ...     Step4: Restore environment,which means modify parmeter back,do validation and activation.
#    [Arguments]   ${InActSA_ErrValue}=80000
#    ...           ${Duration_DeltaValidation}=${AA_02['Duration_DeltaValidation']}
#    COAM_WebEM.Login
#    Log To Console    Step1: Modify parameter which will not cause site reset but will cause error when do validation.
#    ...            eg:modify 'shutdownNogNBCellTmr' to wrong value in webem.
#    ${timestartTmp}   Get Current Date
#    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
#    ...    new_value=${InActSA_ErrValue}
#    ${validate_message_STEP1}   selenium_coam.get_error_info_after_set_parameter
#    Log To Console    Step2: Caculate validate duration(duration is captured from system) and check validation duration no more than
#    ...            requirement
#    ${timestart}      convert date    ${timestartTmp}    epoch
#    ${timeendTmp}     Get Current Date
#    ${timeend}        convert date    ${timeendTmp}     epoch
#    ${duration_time_tmp_2479AA02}    Evaluate    ${timeend}-${timestart}
#    Should Be True     ${duration_time_tmp_2479AA02}<=${Duration_DeltaValidation}
#    Log To Console    Step3: Validate and check error exist on WebEM.
#    Should Not Be Empty       ${validate_message_STEP1}
#    selenium_coam.undo_changes
#    Log To Console    Step4: Restore environment,which means modify parmeter back,do validation and activation.
#    ${InActSA_Value}    selenium_coam.get_parameter_value
#    ...    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
#    ${InActSA_Value}    get regexp matches    ${InActSA_Value}     [0-9]+
#    ${InActSA_Value}    Evaluate    ${InActSA_Value[0]}+1
#    ${InActSA_CorrectValue}=  set variable if    ${InActSA_Value} >= ${5}   3   8
#    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
#    ...    new_value=${InActSA_CorrectValue}
#    selenium_coam.validate_plan
#    ${error}    selenium_coam.get_relation_errors
#    Should Be Empty     ${error}
#    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
#    COAM_WebEM.Logout
    [Documentation]
    ...   Purpose:Test case is to check download and activation duraton of delta plan(No service outage)
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Modify parameter which will not cause site reset
    ...            eg:modify 't304' to ms500.
    ...     Step2: Validate plan,activate plan(download without activation)Caculate delta plan downlaod duration(duration is captured from system)
    ...            and check validation duration no more than requirement
    ...     Step3: Validate and check error exist on WebEM.
    ...     Step4: Restore environment,which means modify parmeter back,do validation and activation.
    [Arguments]   ${InActSA_ErrValue}=80000
    ...           ${Duration_DeltaValidation}=${AA_02['Duration_DeltaValidation']}
    ...           ${Duration_Delta_Activation}=${AA_02['Duration_Delta_Activation']}
    set test variable    ${execution_result}    fail
    COAM_WebEM.Login
    Log To Console    Step1: Modify parameter which will not cause site reset
    ...            eg:modify 't304' to ms200
    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=Timer t304
    ...    new_value=ms200
    BtsLog.StartBTSlogCollection
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    COAM_WebEM.Logout
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step2: Check duration from syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PlanActivateIndScenario"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${delta_activation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${delta_activation_startTime}
    ${delta_activation_startTime}     convert date
    ...    ${delta_activation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_ACTIVATE_RESULT-1 with result=Success"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${delta_activation_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${delta_activation_endTime}
    ${delta_activation_endTime}        convert date
    ...     ${delta_activation_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${duration_time_tmp_AA02}    Evaluate    ${delta_activation_endTime}-${delta_activation_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${duration_time_tmp_AA02}<=${Duration_Delta_Activation} and ${duration_time_tmp_AA02}>${0}
    log to console   duration of delta plan activation without site reset is ${duration_time_tmp_AA02}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Duration_Delta_Activation}    result_value=${duration_time_tmp_AA02}
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_03_CM_Configuration_File_Backup
    [Documentation]
    ...   Purpose:Test case is to check configuration file can be saved successful and duration meet requirement.
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Backup SCF and check whether time meet requirement
	...   Note:OM_GEN_SFS_PERF_CAP.6819 in 21A.Target is 30s
    [Arguments]    ${SCF_backup_duration}=${AA_03['SCF_backup_duration']}
    set test variable    ${execution_result}    fail
    COAM_WebEM.Login
    Log To Console    Step1: Backup SCF and check whether time meet requirement.
    ${timestartTmp}    KW.TimerStart
	${bkp_scf_file}    selenium_coam.Save Bts Configuration
    set suite variable    ${bkp_scf_file}
    ${duration_time_tmp}     KW.TimerStop    timestart=${timestartTmp}
    LOG    ${duration_time_tmp}
    COAM_WebEM.Logout
    Should Be True     ${duration_time_tmp}<=${SCF_backup_duration}      Configuration File Backup time is more than 30s
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${SCF_backup_duration}    result_value=${duration_time_tmp}
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_04_CM_Delta_Plan_Validation_Activation_Operations_Site_Level_Service_Outage
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
    [Arguments]   ${Duration_DeltaActivation}=${AA_04['Duration_DeltaActivation']}
    set test variable    ${execution_result}    fail
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
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp_STEP2}    Evaluate    ${timeend}-${timestart}
    Should Be True     ${duration_time_tmp_STEP2}<=${Duration_DeltaActivation}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Duration_DeltaActivation}    result_value=${duration_time_tmp_STEP2}
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_05_CM_Delta_Plan_Provision_Operation_No_Service_Outage
    [Documentation]
    ...   Purpose:Check configuration file_delta plan(no service outage) provision can be successful and duration meet requirement
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TTA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import delta scf which will not cause reset in netact,and check provision duration no more than
    ...     requirement
    [Arguments]   ${Delta_Plan_Provision_Durtion}=${AA_05['Delta_Plan_Provision_Durtion']}
    set test variable    ${execution_result}    fail
    Log To Console    Step1: Import delta scf which will not cause reset in netact,and check provision duration no more than
    ...     requirement
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_NoReset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_Provision_Durtion}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Delta_Plan_Provision_Durtion}    result_value=${duration}
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_06_CM_Full_Config_Plan_Provision
    [Documentation]
    ...   Purpose:Check configuration file_delta plan(no service outage) provision can be successful and duration meet requirement
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Full_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import full scf in netact,and check provision duration no more than requirement
    [Arguments]   ${Full_Plan_Provision_Duration}=${AA_06['Full_Plan_Provision_Durtion']}
    set test variable    ${execution_result}    fail
    Log To Console    Step1: Import full scf in netact,and check provision duration no more than requirement
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Full_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${Full_Plan_Provision_Duration}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Full_Plan_Provision_Duration}    result_value=${duration}
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_07_CM_Delta_Plan_Pre-Activate_Successful
    [Documentation]
    ...   Purpose:Check delta plan pre-activate duration meet requirement.
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import delta no reset scf in netact,do pre_procision and check  duration no more than
    ...     requirement
    [Arguments]   ${Delta_Plan_PreProvision_Duration}=${AA_07['Delta_Plan_PreProvision_Durtion']}
    set test variable    ${execution_result}    fail
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    Log To Console    Step1: Import delta no reset scf in netact,do pre_procision and check  duration no more than
    ...     requirement
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_NoReset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=true
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_PreProvision_Duration}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Delta_Plan_PreProvision_Duration}    result_value=${duration}
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_08_CM_Delta_Plan_Download
    [Documentation]
    ...   Purpose:Check delta plan download duration meet requirement.
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import delta with no reset scf in netact,check download duration no more than requirement
    [Arguments]   ${Import_Delta_Plan_Durtion}=${AA_08['Import_Delta_Plan_Durtion']}
    log to console    Step1: Import delta with no reset scf in netact,check download duration no more than requirement
    BtsLog.StartBTSlogCollection
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    ${duration}    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_NoReset_Plan.xml
    log to console    ${duration}
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    should be true    ${duration}>${0} and ${duration}<${Import_Delta_Plan_Durtion}

TC.5GC002479_AA_09_CM_Delta_Plan_Provision_Operation_Site_Service_Outage
    [Documentation]
    ...   Purpose: Check configuration file_delta plan(site service outage) provision can be successful and duration meet requirement.
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   TestC Steps:
    ...     Step1: Import delta with no reset scf in netact,check download duration no more than requirement
    [Arguments]   ${Delta_Plan_Provision_Duration_Reboot}=${AA_09['Delta_Plan_Provision_Durtion_Reboot']}
    set test variable    ${execution_result}    fail
    log to console    Step1: Import delta with no reset scf in netact,check download duration no more than requirement
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_Reset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_Provision_Duration_Reboot}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Delta_Plan_Provision_Duration_Reboot}    result_value=${duration}
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_10_CM_Upload_CM_Configuration
    [Documentation]
    ...   Purpose:Check CM configuration upload can be successful and duration meet requirement.
    ...   Precondition: Netact has been integrated
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1:Upload configuration in netact,check upload status and duration no more than requirement
    [Arguments]   ${CMUplod_Duration}=${AA_10['CMUplod_Durtion']}
    set test variable    ${execution_result}    fail
    log to console    Step1:Upload configuration in netact,check upload status and duration no more than requirement
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    ${duration}    NetAct.CMOperationManager.Upload
    log to console    ${duration}
    should be true    ${duration}>${0} and ${duration}<${CMUplod_Duration}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${CMUplod_Duration}    result_value=${duration}
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_11_CM_Duration_of_CM_Change_Notification
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
    [Arguments]    ${Duration_ChangeNoti}=${AA_11['Duration_ChangeNoti']}
    set test variable    ${execution_result}    fail
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
#    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    run keyword and ignore error    run    command=cd /tmp/;rm -rf BTSLOG_AA_11.txt
    BtsLog.StartBTSlogCollection
#    run    command=tail -f /tmp/btslog2/SYSLOG_*.LOG |grep -E ${CheckString} >> /tmp/BTSLOG_AA_11.txt&
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    Sleep    5s
#    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
#    Sleep    2s
    COAM_WebEM.Logout
    BtsLog.StopBTSlogCollectionandGetlog
    run    command=cat /tmp/btslog2/SYSLOG_*.LOG |grep -E ${CheckString} >> /tmp/BTSLOG_AA_11.txt&
    Sleep    5s
    Log To Console    Step4: Caculate duration between message "finishActivation" and "Transfer ccn succeedand"
    ...     in btslog and check duration no more than requirement.
    ${Noti_Time0}     run    command=cat /tmp/BTSLOG_AA_11.txt|grep finishActivation|awk '{print $7}'|head -n 1|tail -1
    Should Not Be Empty     ${Noti_Time0}
    ${Noti_Time0}        convert date    ${Noti_Time0.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${Noti_Time2}    run    command=cat /tmp/BTSLOG_AA_11.txt | grep "Transfer ccn succeed"|awk '{print $7}'|head -n 3|tail -1
    Should Not Be Empty     ${Noti_Time2}
    ${Noti_Time2}        convert date    ${Noti_Time2.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${Noti_Duration1}    Evaluate    ${Noti_Time2}-${Noti_Time0}
    Should Be True     ${Noti_Duration1}<=${Duration_ChangeNoti} and ${Noti_Duration1}>${0}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Duration_ChangeNoti}    result_value=${Noti_Duration1}
    set test variable    ${execution_result}    pass

TC.CB008181_AA_12_CM_Duration_of_Delta_Plan_Validation
    [Documentation]
    ...   Purpose:Check delta plan pre-activate duration meet requirement.
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import delta no reset scf in netact,do pre_procision and check  duration no more than
    ...     requirement
    [Arguments]   ${Delta_Plan_PreProvision_Durtion}=${AA_07['Delta_Plan_PreProvision_Durtion']}
    ...           ${Delta_Plan_validation_err_Duration}=${AA_07['Delta_Plan_validation_err_Durtion']}
    ...           ${Delta_Plan_validation_suc_Duration}=${AA_07['Delta_Plan_validation_suc_Durtion']}
    ...           ${Delta_Plan_download_Duration}=${AA_07['Delta_Plan_download_Duration']}
    set test variable    ${execution_result}    fail
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    Log To Console    Step1: Import delta no reset scf in netact,do pre_procision and check  duration no more than
    ...     requirement
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_NoReset_Plan.xml
    ${download_duration}    NetAct.CMOperationManager.deltaPlanDownload    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=true
    Run Keyword And Ignore Error    should be true    ${download_duration}<${Delta_Plan_download_Duration} and
    ...     ${download_duration}>=${0}
    Log To Console    Duration of delta paln download is ${download_duration}
    ${validation_duration_succ}    NetAct.CMOperationManager.Validation    name=TA_PLAN_TL_${MRBTS_ID}
    ...   pre_provision=true
#    log to console    ${duration}
#    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_PreProvision_Durtion}
    should be true    ${validation_duration_succ}<${Delta_Plan_validation_suc_Duration} and ${validation_duration_succ}>${0}
    Log To Console    validated duration of delta paln without error is ${validation_duration_succ}
    Log To Console    Step2: Import delta plan with error and check the validation duration
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_Plan_error.xml
    ${validation_duration_err}    NetAct.CMOperationManager.Validation    name=TA_PLAN_TL_${MRBTS_ID}
    ...   pre_provision=true
#    log to console    ${duration}
#    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_PreProvision_Durtion}
    should be true    ${validation_duration_err}<${Delta_Plan_validation_err_Duration} and ${validation_duration_err}>${0}
    Log To Console    validated duration of delta paln with error is ${validation_duration_err}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][0]}
    ...    target_value=${Delta_Plan_download_Duration}    result_value=${download_duration}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][1]}
    ...    target_value=${Delta_Plan_validation_suc_Duration}    result_value=${validation_duration_succ}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][2]}
    ...    target_value=${Delta_Plan_validation_err_Duration}    result_value=${validation_duration_err}
    set test variable    ${execution_result}    pass

TC.5GC002479_BA_01_PM_Collection
    [Documentation]
    ...   Purpose:Check the PM result file creation successful and duration meet requirement.
    ...   Precondition: NA
    ...   Test tools:ssh to gnb
    ...   Test Steps:
    ...     Step1:Get pm file created interval from webem
    ...     Step2:Check pm file will create successfully within pm file created interval.
    [Arguments]   ${PM_File_Creation_Time}=${BA_01['PM_File_Creation_Time']}
     Log To Console    Step1:Get pm file created interval in webem
     COAM_WebEM.Login
     ${pm_interval_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    Performance measurement data reporting interval
     set test variable      ${pm_interval_org}
     run keyword if         '${pm_interval_org}'!='${PMINTERVAL}min'    Change PM ReportingInterval   ${PMINTERVAL}min
     ${inter}    Convert To Integer    ${PMINTERVAL}
     ${wait_time}    calculate_wait_time    interval=${inter}
     log     ${wait_time}
     Log To Console    Step2:Check pm file will create successfully within pm file created interval.
     gNB.Connect
     ${output_before}=    ssh.execute    command=cd /tmp;ls -lrt PM.BTS-*.xml.gz | wc -l     connection=${ALIAS_ASIK}
     log     ${output_before}
     set test variable     ${pm_before}    ${output_before.replace("\r\n","")}
     run keyword if    ${output_before.count('No such file or directory')}>0    set test variable     ${pm_before}     ${0}
     ${pm_generate_time}    Evaluate    ${wait_time}+${PM_File_Creation_Time}
     sleep      ${pm_generate_time}s
     ${output_after}=    ssh.execute    command=cd /tmp;ls -lrt PM.BTS-*.xml.gz | wc -l     connection=${ALIAS_ASIK}
     log    ${output_after}
     ${pm_after}    convert to integer    ${output_after}
     Should Be True    ${pm_after} > ${pm_before}
     gNB.Disconnect

TC.5GC002479_BA_02_PM_Retention
    [Documentation]
    ...   Precondition: NA
    ...   Purpose:Check PM result files shall be kept for 24h in the BTS
    ...   Test tools:ssh to gnb
    ...   Test Steps:
    ...     Step1: Check pm file kept duration(from created to current time)
    ...     Step2: Wait "target duration - kept duration",check pm file exist.
    ...     Note:target duration-kept duration is set to 180s rather than 24h,we could modify to 24h in weekend to run this case
    [Arguments]   ${Duration_PM_Kept}=${BA_02['Duration_PM_Kept']}
    Log To Console    Step1: Check pm file kept duration(from created to current time)
    gNB.Connect
    Wait Until Keyword Succeeds    20x    60s      KW.PM_exist
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

TC.5GC002479_BA_03_PM_Data_File_Size
    [Documentation]
    ...   Purpose: heck PM result files size is meet requirement
    ...   Precondition: NA
    ...   Test tools:WebUI,ssh to gnb
    ...   Test Steps:
    ...     Step1: Modify ModifyPMPeriod in webem
    ...     Step2: Ssh to gnb and check pm files exist by executing command
    ...     Step3: Caculate files' size and check it no more than requirement
    [Arguments]   ${PM_MAX_Size}=${BA_03['PM_MAX_Size']}
    Log To Console    Step1: Modify ModifyPMPeriod in webem
    KW.ModifyPMPeriod
############# comment fowlling to reduce testing time
#    ${SCF_File}   COAM_Admin.BackupSCF
#    run   cp ${SCF_File} ${LOG_PATH}/5GC002479_BA_03.xml
#    gNB.Commission   scf_file=${LOG_PATH}/5GC002479_BA_03.xml
#    COAM_Admin.ResetSite     timeout=1800
    Wait Until Keyword Succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    Log To Console    Step2: Ssh to gnb and check pm files exist by executing command
    gNB.Connect
    sleep    30min
#    Wait Until Keyword Succeeds    35x    60s     KW.PM_exist    pm_order=2
    Log To Console    Step3: Caculate files' size and check it no more than "PM_MAX_Size"
    FOR    ${i}    IN RANGE    2
        ${PM_File_Order}    Evaluate    ${i}+1
        #eg:If "${PM_File_Order}" is 2,get the earliest 2 pm files from command output list
        ${PM_File_Size_Output}=       ssh.execute
        ...      command=cd /tmp;ls -lh PM*.ANY.xml.gz | awk '{if(NR==${PM_File_Order})print $5}'    connection=${ALIAS_ASIK}
        ${PM_File_Size}    Fetch From Left    ${PM_File_Size_Output}       K
        ${PM_File_Size}    Remove String    ${PM_File_Size}    \r\n
        ${PM_File_Size}    Evaluate    ${PM_File_Size}+0
        Should Be True     ${PM_File_Size} < ${PM_MAX_Size}
    END
    gNB.Disconnect

TC.5GC002479_BA_04_PM_CPU_Impact
    [Documentation]
    ...   Purpose:CPU load impact between disable all PM counters and enable all PM counters
    ...   Precondition: NA
    ...   Test tools:WebUI,ssh to gnb
    ...   Test Steps:
    ...     Step1: Disale all pm counters and check CPU load
    ...     Step2: Enable pm counters and check CPU load
    ...     Step3: Check CPU load's increase meet target
    [Arguments]   ${CPU_Jitter}=${BA_04['CPU_Jitter']}
#    COAM_WebEM.Login
#    ${Value}    COAM_WebEM.GetParameterValue  distName=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
#    ...    abbr=Performance measurement data reporting interval
#    run keyword if    '${Value}'!='15min'   COAM_WebEM.SetParameterValue  distName=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
#    ...    abbr=Performance measurement data reporting interval    value=15min
#    run keyword if    '${Value}'!='15min'   COAM_WebEM.ValidateAndActiveParameters
    Log To Console    Step1: Disale all pm counters and check CPU load
    KW.ModifyPMPeriod    FileINTERVAL=5min     PMINTERVAL=disabled
    gNB.Connect
    ${sum_1}    set variable    ${0}
    FOR  ${i}    IN RANGE    ${100}
        ${result}  Conn.Execute    cmd=grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'    alias=${ALIAS_ASIK}
        ${result}    Fetch From Left     ${result}   \r\n
        ${sum_1}     Evaluate    ${result}+${sum_1}
        Sleep    3s
    END
#    COAM_WebEM.SetParameterValue  distName=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
#    ...    abbr=Performance measurement data reporting interval    value=5min
#    COAM_WebEM.ValidateAndActiveParameters
    Log To Console    Step2: Enable pm counters and check CPU load
    KW.ModifyPMPeriod    FileINTERVAL=5min     PMINTERVAL=5min
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
    should be true    ${jitter}<${CPU_Jitter}

TC.5GC002479_CA_01_FM_Duration_of_Alarm_Event_Reporting
    [Documentation]
    ...   Purpose:Check the duration of alarm event reporting in BTS and system
    ...   Precondition: cell on air
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Trigger alarm
    ...     Step2: Cancel alarm
    ...     Step3: Check alarm not exsit
    [Arguments]   ${alarm_report_time}=${CA_01['alarm_report_time']}
    [Teardown]    KW.WebEMRestore
    log to console    Step1: Trigger alarm
    ${Smods}    COAM_Admin.GetBTSTopology
#    FOR    ${smod}    IN    @{Smods}
#        ${CellID}    set variable    ${smod['BBMODs'][0]['RUs'][0]['Cells'][0]['id']}
#        set test variable    ${CellID}
#        COAM_WebEM.Login
#        ${pdcch_org}    CM_WebEM.GetListParameter     dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CellID}    filter_param=${PdcchMonOccsnPo}
#         ...     node_index=${0}
#        set test variable      ${pdcch_org}
#        Process.ChangeCellParameterToTestFault    filter_param=${PdcchMonOccsnPo}   newvalue=${pdcch_wrong}    cellid=${CellID}
#        ${timestartTmp}   Get Current Date
#        ${timestart}      convert date    ${timestartTmp}    epoch
#        ${timeendTmp}     Get Current Date
#        wait until keyword succeeds   1min   2s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7114
#        ...    target_fault_id=7516    target_fault_name=Incorrect cell parameter configuration    target_severity=major
#        ${timeendTmp}     Get Current Date
#        ${timeend}        convert date    ${timeendTmp}     epoch
#        ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
#        Should Be True     ${duration_time_tmp}<=${alarm_report_time}       Fault reporting time is more than 60s
#    END
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
        Should Be True     ${FM_duration}<=${alarm_report_time}       Fault reporting time is more than 60s
    END

TC.5GC002479_CA_02_FM_Alarm_Upload
    [Documentation]
    ...   Purpose:The purpose of this test case is to check Alarm Load Operation is completed succesfully with requirement
    ...   Precondition: Netact has integrated,there are active alarms in webui(aleady has alarm normally,no need to trigger)
    ...   Test tools:Netact,webui
    ...   Test Steps:
    ...     Step1: Logon NetAct do Alarm Upload
    [Arguments]   ${Alarm_Upload_Durtion}=${CA_02['Alarm_Upload_Durtion']}
    log to console    Step1: Logon NetAct do Alarm Upload
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    KW.NetActGetBTSAlias
    NetAct.StartApp  app_name=Monitor
    ${duration}    NetAct.Monitor.AlarmUpload    name=${BTSALIAS}
    should be true     ${duration}>${0} and ${duration}<${Alarm_Upload_Durtion}

TC.5GC002479_DA_01_LOG_Manual_Trigger_Snapshot
    [Documentation]
    ...   Purpose:Check manually triggered on-demand snapshot can be success and duration meeting requirement
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Save snapshot by choosing all log files,and check duration meet target
    [Arguments]   ${snapshot_save_time}=${DA_01['snapshot_save_time']}
    set test variable    ${execution_result}    fail
    log to console    Step1:Save snapshot by choosing all log files,and check duration meet target
    BtsLog.StartBTSlogCollection
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
    Should Be True     ${duration_time_tmp}<=${snapshot_save_time}     Snapshot collect time is more than 15 minute
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${snapshot_save_time}    result_value=${duration_time_tmp}
    set test variable    ${execution_result}    pass

TC.5GC002479_DA_02_LOG_Automatically_Triggered_Snapshot
    [Documentation]
    ...   Purpose:Check snapshot is triggered by fault can be success and duration meeting requirement
    ...   Precondition:Netact is integrated.
    ...   Test tools:webui,netact
    ...   Test Steps:
    ...     Step1:Set fault number and trigger type in WebUI
    ...     Step2:Trigger fault which set in step1
    ...     Step3:Check snapshot exist in Netact logserver,and duration meet requirement.
    [Arguments]   ${FilePresentTime}=${DA_02['FilePresentTime']}
    [Teardown]    KW.WebEMRestore
    set test variable    ${execution_result}    fail
    log to console    Step1:Set fault number and trigger type in WebUI
    BtsLog.StartBTSlogCollection
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    run keyword and ignore error     COAM_WebEM.DeleteParameter    distName=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    abbr=Fault snapshot triggers
    sleep    2s
    COAM_WebEM.ValidateAndActiveParameters
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

#    ${Smods}    COAM_Admin.GetBTSTopology
#    FOR    ${smod}    IN    @{Smods}
#        wait until keyword succeeds   15min    10s    COAM_WebEM.Login
#        ${CellID}    set variable    ${smod['BBMODs'][0]['RUs'][0]['Cells'][0]['id']}
#        set test variable    ${CellID}
#        ${pdcch_org}    CM_WebEM.GetListParameter     dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CellID}    filter_param=${PdcchMonOccsnPo}
#        ...     node_index=${0}
#        set test variable      ${pdcch_org}
#        Process.ChangeCellParameterToTestFault    filter_param=${PdcchMonOccsnPo}   newvalue=${pdcch_wrong}    cellid=${CellID}
#
#        wait until keyword succeeds   1min    2s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7114
#        ...    target_fault_id=7516    target_fault_name=Incorrect cell parameter configuration    target_severity=major
#
#        Timer.Start
#        wait until keyword succeeds   ${FilePresentTime}min   20s    KW.CheckFilePresent
#        ${duration}    Timer.Stop
#        log to console    ${duration}
#    END
     log to console    Step2:Trigger fault which set in step1
     ${Smods}    COAM_Admin.GetBTSTopology
     FOR    ${smod}    IN    @{Smods}
         #Note:Modify ${gscn} in nrcell1 per smod to trgger fault
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
         Should be true    ${duration}<=${FilePresentTime}
    END
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][0]}
    ...    target_value=${FilePresentTime}    result_value=${duration}
    set test variable    ${execution_result}    pass

TC.5GC002479_DA_03_Remote_Syslog_Session_Start_and_Stop_Latency
    [Documentation]    OM_GEN_SFS_PERF_CAP.6847  == CB008181_SR_A_32_Troubleshooting_Remote_Syslog_Session_Start_and_Stop_Latency
    ...   Purpose:Check the BTS is enable/disable the transmission of syslog messages within required time
    ...   Precondition:
    ...   Test tools:webui,btslog.UTE is setting to remote BTSLOG server, BTSLOG tool must set Ports and UDP Ports to 10000.
    ...   Test Steps:
    ...     Step1:Enable/disale the transmission and other releated pameters about syslog in WebEM
    ...           Note:If "Activate remote syslog transmission" is "true",modify it to "false",if it is "false",modify it to "true".
    ...     Step2:Check the BTS shall enable/disable the transmission of syslog messages within target duration
    [Arguments]   ${StartAndStopLtency}=${DA_03['StartAndStopLtency']}
    set test variable    ${execution_result}    fail
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
    ...    new_value=5    node_index=${0}
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog transport protocol
    ...    new_value=UDP    node_index=${0}
    COAM_WebEM.ValidateAndActiveParameters
    FOR    ${i}    IN RANGE    ${2}
        ${value}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1    abbr=Activate remote syslog transmission
        ${value}    set variable if    '${value}'=='true'    false     true
        ${CheckString}    set variable if    '${value}'=='true'
        ...    "update usageState to 2|finishActivation"    "update usageState to 0|finishActivation"
        run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    filter_param=Activate remote syslog transmission    new_value=${value}    node_index=${0}
#        run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
        run keyword and ignore error    run    command=cd /tmp/;rm -rf BTSLOG_DA_03_${i}.txt
        BtsLog.StartBTSlogCollection
#        run    command=tail -f /tmp/btslog2/SYSLOG_*.LOG |grep -E ${CheckString} >> /tmp/BTSLOG_DA_03_${i}.txt&
        COAM_WebEM.ValidateAndActiveParameters
        Sleep    5s
#        run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
#        Sleep    2s
        BtsLog.StopBTSlogCollectionandGetlog
        run    command=cat /tmp/btslog2/SYSLOG_*.LOG |grep -E ${CheckString} >> /tmp/BTSLOG_DA_03_${i}.txt&
        Sleep    5s
        log to console    Step2:Check the BTS shall enable/disable the transmission of syslog messages within target duration
        ${timeStart}    run    command=cat /tmp/BTSLOG_DA_03_${i}.txt|grep finishActivation|grep 192.168.255.129|awk '{print $7}'|head -n 1|tail -1
        Should Not Be Empty     ${timeStart}
        ${timeStart}    convert date    ${timeStart.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}    epoch
        ${timeEnd}    run    command=cat /tmp/BTSLOG_DA_03_${i}.txt|grep 192.168.255.129|grep "update usageState"|awk '{print $7}'|head -n 3|tail -1
        Should Not Be Empty     ${timeEnd}
        ${timeEnd}      convert date    ${timeEnd.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}    epoch
        ${duration}    Evaluate    ${timeEnd}-${timeStart}
        Should be true    ${duration}>${0} and ${duration}<${StartAndStopLtency}
        AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
        ...    target_value=${StartAndStopLtency}    result_value=${duration}
    END
    set test variable    ${execution_result}    pass


TC.5GC002479_FA_01_WebEM_Memory_Consumption
    [Documentation]
    ...   Purpose:Check Memory consumed when WebEM application launch
    ...   Precondition:NA
    ...   Test tools:webui,ute server
    ...   Test Steps:
    ...     Step1:Login WebEM and do some operations in WebEM. Observe the memory
    [Arguments]   ${MaxFileSize}=${FA_01['MaxFileSize']}
    log to console    Step1:Login WebEM and do some operations in WebEM,and bserve the memory
    COAM_WebEM.Login
    #run in ute server
    ${result}    run    ps -e -o 'rsz,pid,comm,args,pcpu,rsz,vsz,stime,user,uid'|grep firefox|awk '{sum += $1} END {print sum}'
    ${result}    Evaluate    ${MaxFileSize}-${result}
    COAM_WebEM.Logout
    should be true     ${result}>${0}

TC.5GC002479_FA_02_WebEM_Number_of_Concurrent_WebEM_User_Sessions
    [Documentation]
    ...   Purpose:Check Memory consumed when WebEM application launch
    ...   Precondition:Ute's memory is enough,since 1 session takes about 1G
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Login WebEM and set max sessions num
    ...     Step2:Check create max sessions successfully,and fail to create max sessions num+1
    [Arguments]   ${MaxSession}=${FA_02['MaxSession']}
    log to console    Step1:Login WebEM and set max sessions num
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    ${value}     selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...    filter_param=WebEM session logout timer
    run keyword if   '${value}'!='${webEMSessionLogoutTimer}'     selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1    filter_param=WebEM session logout timer    new_value=${webEMSessionLogoutTimer}
    run keyword and ignore error     COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    run keyword and ignore error     KW.CleanFirefox
    log to console    Step2:Check create max sessions successfully,and fail to create max sessions num+1
    ${driver}    ${pagePart}    CreateWebDriver
    ${stream}   Set Variable if  ${AF_PATH.count('SBTS')}>${0}    sbts   gnb
    input_usr_and_pwd_then_click_login_button
        ...    driver=${driver}  pagePart=${pagePart}  url=${WEBUI_URL}  usr=${WEBUI_USERNAME}  pwd=${WEBUI_PASSWORD}  stream=${stream}
    Sleep    60s
    ${PortMax}     Evaluate    ${MaxSession}-${1}
    FOR    ${i}    IN RANGE    ${PortMax}
        run keyword and ignore error    NewTabAndLogin    driver=${driver}    PagePart=${pagePart}    index=${i+1}
        ...    url=${WEBUI_URL}   usr=${WEBUI_USERNAME}   pwd=${WEBUI_PASSWORD}    stream=${stream}
        sleep    30s
    END
    ${result}    run keyword and ignore error    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
    log to console    ${result}
    should contain    ${result[1]}    Sessions number limit reached

TC.5GC002479_FA_03_WebEM_Duration_of_Loading_WebEM_Application
    [Documentation]
    ...   Purpose:Check the duration of loading WebEM application
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Launch browser to enter WebEM URL
    ...     Step2:Check durantion from "the operator navigates to the WebEM URL" to "login window visible" meet target
    [Arguments]   ${Duration_Loading_WebEM}=${FA_03['Duration_Loading_WebEM']}
    log to console    Step1:Launch browser to enter WebEM URL
    ${display}    ${driver}   ${pagePart}    SG1_coam_driver_open
    log to console    Step2:Check durantion from "the operator navigates to the WebEM URL" to "login window visible" meet target
    ${startTime}    KW.TimerStart
    inputurl_and_wait_element    driver=${driver}   pagePart=${pagePart}   url=${WEBUI_URL}
    ${duration}   KW.TimerStop    timestart=${startTime}
    SG1_coam_driver_close    driver=${driver}    display=${display}
    should be true    ${duration} < ${Duration_Loading_WebEM}

TC.5GC002479_FA_04_WebEM_Duration_of_Login_WebEM_Application
    [Documentation]
    ...   Purpose:Check the duration of login WebEM
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Open WebEM URL input username and password then click "Login"
    ...     Step2:Check duration from click "Login" to full webem application visiable.
    [Arguments]   ${Login_duration_time}=${FA_04['Login_duration_time']}
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
    Should Be True     ${duration_time_tmp}<=${Login_duration_time}      WebEM login time is too long
    5GC002479_FA.logout

TC.5GC002479_FA_05_WebEM_Duration_of_Loading_WebEM_Runtime_View
    [Documentation]
    ...   Purpose:Check the duration of be able to present the runtime view to the operator
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Login in webem,check duration from click "legal notice" visible " to "runtime view" visible.
    [Arguments]   ${StartupView_Login_duration_time}=${FA_05['StartupView_Login_duration_time']}
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
    should be true    ${duration} < ${StartupView_Login_duration_time}

TC.5GC002479_FA_06_WebEM_WebEM_Remote_Tool_User_Session_Capacity
    [Documentation]
    ...   Purpose:check WebEM remote tool user session capacity
    ...   Precondition:NA
    ...   Test tools:webui,admincli
    ...   Test Steps:
    ...     Step1:Prepare admincli
    ...     Step2:Repeat to setup connection to gnb using WebEM remote tool and excute CLI command to open user session
    ...     Step3:Check connect successfully within maximum remote user sessions,and fail when sessions out of range
    [Arguments]   ${RMToolSessionCount}=${FA_06['RMToolSessionCount']}
    log to console    Step1:Prepare admincli
    KW.PrepareAdminCli
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

TC.5GC002479_FA_07_WebEM_WebEM_Remote_Tool_Connection_Request_Latency_Standalone_mode
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
    [Arguments]   ${RMToolRequestLatency}=${FA_07['RMToolRequestLatency']}
    log to console    Step1:Prepare admincli
    KW.PrepareAdminCli
    log to console    Step2:Execute an ADMIN CLI command in stanadalone mode and check the output time
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    ${cmd}   set variable    ./admin-cli.sh --bts-username=${WEBUI_USERNAME} --bts-password=${WEBUI_PASSWORD} --bts-host=${ASIK_IP}
    ${cmd}   set variable    ${cmd} --bts-port="443" --secure="true" --data="{\"requestId\":1,\"parameters\":{\"name\":\"getActiveAlarms\"}}"
    Timer.Start
    ${result}    run    command=cd ${CLI_PATH}&&${cmd}
    ${duration}    Timer.Stop
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    should be true    ${duration}<${RMToolRequestLatency} and ${duration}>${0}

TC.5GC002479_FA_08_WebEM_WebEM_Remote_Tool_Connection_Latency_Server_mode
    [Documentation]
    ...   Purpose:Check The WebEM Remote Tool in server mode shall enable the connection to the BTS/DU within target duration
    ...   Precondition:NA
    ...   Test tools:webui,admincli
    ...   Test Steps:
    ...     Step1:Prepare admincli
    ...     Step2:Execute ADMIN CLI command in server mode and check the output time when BTS connected.
    ...           Note:Only need to care steps,could refer other material if you want to konw more about remote tool.
    ...                eg:server mode's concept.
    [Arguments]   ${RMToolConnectionLatency}=${FA_08['RMToolConnectionLatency']}
    log to console    Step1:Prepare admincli
    KW.PrepareAdminCli
    log to console    Step2:Execute ADMIN CLI command in server mode and check the output time when BTS connected.
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    ${cmd}   set variable    ./admin-cli.sh --cli-port=9000 --bts-host=${ASIK_IP} --bts-port=443 --insecure=false
    ${cmd}   set variable    ${cmd} --bts-username=${WEBUI_USERNAME} --bts-password=${WEBUI_PASSWORD}
    Timer.Start
    ${result}    run    command=cd ${CLI_PATH}&&${cmd}>log_FA_08.txt&
    FOR  ${i}    IN RANGE    ${30}
        ${result}    run    command=cd ${CLI_PATH}&&cat log_FA_08.txt
        Run Keyword If    ${result.count('BTS connected')}>0    Exit For Loop
        Sleep    1s
    END
    ${duration}    Timer.Stop
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    should be true    ${duration}<${RMToolConnectionLatency} and ${duration}>${0}

TC.5GC002479_FA_09_WebEM_WebEM_Remote_Tool_Request_Latency_Server_mode
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
    [Arguments]   ${RMToolRequestLatencyServerMode}=${FA_09['RMToolRequestLatencyServerMode']}
    log to console    Step1:Prepare admincli
    KW.PrepareAdminCli
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

TC.CP_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    [Arguments]   ${WebUI_reset_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']}
    set test variable    ${execution_result}    fail
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${RMODsList}       KW.CP_GetRMODsList
    ${AdjRMOD}    Set Variable     AEHC
    ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
    ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
    ...    AdjRMOD=${AdjRMOD}
    KW.CaseStatusInit    retry_times=${WebUI_reset_times}
    FOR    ${i}    IN RANGE    ${WebUI_reset_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error    KW.LoopForResetViaWEBUI    loop=${i+1}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        log to console     Case loop ${i+1} END
        Get common info     case_result=${reset_status}    case_name=site_reset   loop_number=${i+1}  duration_time=${duration_time_tmp}
        should be true    ${duration_time_tmp}<${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        Run Keyword And Ignore error    WEBUI.Collect snapshot
        AppendCaseResultToFile    index=${i}
        ...    target_value=${KPIAdjValue['KPI1a']['KPI1a_AVG']}    result_value=${duration_time_tmp}
    END
    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI1a']['KPI1a_AVG']}    max_loop=${WebUI_reset_times}
    set test variable    ${execution_result}    pass

# power_reset
TC.CP_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    [Arguments]   ${Power_reset_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['Power_reset_times']}
    set test variable    ${execution_result}    fail
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${RMODsList}       KW.CP_GetRMODsList
    ${AdjRMOD}    Set Variable     AEHC
    ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
    ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
    ...    AdjRMOD=${AdjRMOD}
    KW.CaseStatusInit    retry_times=${Power_reset_times}
    FOR    ${i}    IN RANGE    ${Power_reset_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error    KW.LoopForPowerReset    loop=${i+1}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPIAdjValue['KPI3']['KPI3_MAX']}
        log to console     Case loop ${i+1} END
        Get common info     case_result=${reset_status}    case_name=power_reset   loop_number=${i+1}  duration_time=${duration_time_tmp}
        should be true    ${duration_time_tmp}<${KPIAdjValue['KPI3']['KPI3_MAX']}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        Run Keyword And Ignore error    WEBUI.Collect snapshot
        AppendCaseResultToFile    index=${i}
        ...    target_value=${KPIAdjValue['KPI3']['KPI3_AVG']}    result_value=${duration_time_tmp}
    END
    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI3']['KPI3_AVG']}    max_loop=${Power_reset_times}
    set test variable    ${execution_result}    pass

TC.5GC002536_HA_03_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
    [Documentation]
    ...   Purpose: check OAM KPI5,Capacity module reset performance (service downtime) shall be kept within 180s
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Reset basebands one by one,and check every baseband's duration meet target
    set test variable    ${execution_result}    fail
    log to console    Step1:Reset basebands one by one,and check every baseband's duration meet target
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${AdjRMOD}    Set Variable     AEHC
    FOR    ${BBMOD}   IN    @{BTSInfo['basebandModules']}
        ${BBMOD_config}=    Split String From Right    ${BBMOD['id']['configuration']}     /
        ${BBMOD_ID}    Set Variable     ${BBMOD_config[-1]}
        ${tmp}=    Split String From Right   ${BBMOD_config[-1]}      -
        ${BBMOD_INDEX}    Set Variable   ${tmp[-1]}
        ${RMODs_Name}    KW.GetRMODsNameByBBMODID    BBMOD_ID=${BBMOD_ID}
        ${SFPCooledInfo}    KW.GetSFPCooledInfoOnBBMOD    BBMOD_INDEX=${BBMOD_INDEX}
        ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODs_Name}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
        ...    AdjRMOD=${AdjRMOD}
        Run Keyword And Ignore error      BtsLog.StartBTSlogCollection
        wait until keyword succeeds    10min    10s    COAM_WebEM.Login
        ${timestartTmp}    KW.TimerStart
        selenium_coam.reset_abil    abil_index=${BBMOD_INDEX}
        sleep    20s
        COAM_WebEM.Logout
        wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
        ${duration_time}     KW.TimerStop    timestart=${timestartTmp}
        Should Be True     ${duration_time}<=${KPIAdjValue['KPI5']}    Timeout
        Run Keyword And Ignore error       Stop BTSlogs Collection and get logs for every loop     loop=${BBMOD_INDEX}
#        Run Keyword And Ignore error       WEBUI.Collect snapshot
        AppendCaseResultToFile    index=${BBMOD_INDEX}
        ...    target_value=${KPIAdjValue['KPI5']}    result_value=${duration_time}
    END
    set test variable    ${execution_result}    pass

TC.CB006939_HA_04_OAM_KPI_54a_RU_Cold_Reset_Time
    [Documentation]
    ...  Purpose: Check RU reset with maximum configuration duration meet requirement.
    ...  Precondition: RU PB information must configured in testline_configuration/_init_.py.The RU order must be aligned with RU index
    ...   Testing tools:power stations
    ...  Test Steps:
    ...    Step1: Power off then power on RU
    ...    Step2: Calculate time starts
    ...    Step3: Wait until Cells are onair
    ...    Step4: Calculate time ends
    ...    Step5: Check the RU down time should meet target
    [Arguments]   ${RU_Reset_Times}=${CASE_INPUT_5GC002479['CB006939_HA_KPI54a']['RU_Reset_Times']}
    set test variable    ${execution_result}    fail
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${AdjRMOD}    Set Variable     AEHC
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        @{RMODsList}=  Create List
        ${RMOD}=  Set Variable    ${RU['productName']}
        Append To List    ${RMODsList}    ${RMOD}
        ${config}=    Split String From Right    ${RU['id']['configuration']}     /
        ${tmp}=    Split String From Right    ${config[-1]}    -
        ${RU_INDEX}    Set Variable   ${tmp[-1]}
        ${SFPCooledInfo}    KW.GetSFPCooledInfoOnRU   RU_INDEX=${RU_INDEX}
        ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
        ...    AdjRMOD=${AdjRMOD}
        KW.CB006939_HA_04_OAM_KPI_54a_RU_Cold_Reset_Time    retry_times=${RU_Reset_Times}    ru_index=${RU_INDEX}
        ...     KPI54A_MAX=${KPIAdjValue['KPI54a']['KPI54a_MAX']}    KPI54A_AVG=${KPIAdjValue['KPI54a']['KPI54a_AVG']}
    END
    set test variable    ${execution_result}    pass

TC.CB006939_HA_05_OAM_KPI_17_Cell_Block_Unblock_Outage_Duration
    [Documentation]
    ...  Purpose:Check OAM KPI17,The BTS shall complete the block/unblock Cell operations within target duration
    ...  Precondition: cell on air
    ...  Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:Block/Unblock one by one,and check every cell's duration meet target
    set test variable    ${execution_result}    fail
    log to console    Step1:Block/Unblock one by one,and check every cell's duration meet target
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    FOR    ${CELL}   IN    @{BTSInfo['cells']['nr']}
        @{RMODsList}=  Create List
        ${cell_config}=    Split String From Right    ${CELL['id']['configuration']}     /
        ${nrcell}   Set Variable     ${cell_config[-1]}
        ${tmp_cell}=    Split String From Right    ${nrcell}     -
        ${CELL_INDEX}   Set Variable     ${tmp_cell[-1]}
        ${rmod_config}=    Split String From Right    ${CELL['carrierList'][0]['antennaLineId']['configuration']}     /
        ${RMOD_ID}   Set Variable     ${rmod_config[-2]}
        ${RMODName}    KW.GetRMODNameByID     RMOD_ID=${RMOD_ID}
        Append To List    ${RMODsList}    ${RMODName}
        ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}    SFPCooled=False    AdjRMOD=${AdjRMOD}
        KW.CB006939_HA_05_OAM_KPI_17_Cell_Block_Unblock    CellBlockDurtion=${KPIAdjValue['KPI17a']}
        ...    CellUnblockDurtion=${KPIAdjValue['KPI17b']}      cell_idx=${CELL_INDEX}
#        Run Keyword And Ignore error    WEBUI.Collect snapshot
    END
    set test variable    ${execution_result}    pass

TC.5GC002479_HA_07_OAM_KPI_16_Cell_Lock_Unclock
    [Documentation]
    ...  Purpose:Check OAM KPI17,The BTS shall complete the block/unblock Cell operations within target duration
    ...  Precondition: cell on air
    ...   Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:Lock/Unlock one by one,and check every cell's duration meet target
    ...    Note:This case no need in feature 2536
    [Arguments]   ${CellLockUnLockDurtion}=${CASE_INPUT_5GC002479['5GC002479_HA_07']['CellLockUnLockDurtion']}
    set test variable    ${execution_result}    fail
    ${Smods}    COAM_Admin.GetBTSTopology
    FOR    ${smod}    IN    @{Smods}
        ${CellID}    set variable    ${smod['BBMODs'][0]['RUs'][0]['Cells'][0]['id']}
        KW.5GC002479_HA_07_OAM_KPI_16_Cell_Lock_Unclock   CellLockUnLockDurtion=${CellLockUnLockDurtion}     cell_idx=${CellID}
    END
    set test variable    ${execution_result}    pass

TC.CB006939_HA_10_OAM_KPI_51a_RU_Reset_Time
    [Documentation]
    ...  Purpose:Check OAM KPI17,The BTS shall complete the block/unblock Cell operations within target duration
    ...  Precondition: Cell on air
    ...  Testing tools:WebUI or Netact
    ...  Test Steps:
    ...    Step1:Reset one by one,and check every RU's duration meet target
    [Arguments]   ${RF_Reset_Times}=${CASE_INPUT_5GC002479['CB006939_HA_KPI51a']['RF_Reset_Times']}
    set test variable    ${execution_result}    fail
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${AdjRMOD}    Set Variable     AEHC
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        @{RMODsList}=  Create List
        ${RMOD}=  Set Variable    ${RU['productName']}
        Append To List    ${RMODsList}    ${RMOD}
        ${config}=    Split String From Right    ${RU['id']['configuration']}     /
        ${tmp}=    Split String From Right    ${config[-1]}    -
        ${RU_Reset_INDEX}    Set Variable   ${tmp[-1]}
        ${SFPCooledInfo}    KW.GetSFPCooledInfoOnRU   RU_INDEX=${RU_Reset_INDEX}
        ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}    SFPCooled=${SFPCooledInfo}
        ...    AdjRMOD=${AdjRMOD}
        KW.Reset.WEbUIResetWithRetry   case_name=rf_reset    retry_times=${RF_Reset_Times}    ru_reset_index=${RU_Reset_INDEX}
        ...    KPI51a_MAX=${KPIAdjValue['KPI51a']['KPI51a_MAX']}   KPI51a_AVG=${KPIAdjValue['KPI51a']['KPI51a_AVG']}
    END
    set test variable    ${execution_result}    pass

TC.5GC002479_SWM_Software_Upgrade
    [Arguments]   ${max_num}=500   ${stream}=${TargetStream}    ${status}=[released ,released_with_restrictions]
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
    KW.SWM.PrepareOriginalENVbyYAFT    build_version=${OriginalBuildVersion}
    ${Target_package_path}        SoftwareUpdate.Download_gNB_Package    build_version=${TargetBuildVersion}
    log to console    package prepared
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
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    ${SW_download_duration}     KW.TimerStop    timestart=${download_startTime}
    log to console   download duration is ${SW_download_duration}
    set suite variable     ${SW_download_duration}
    set suite variable     ${SWM}     ${2}
    ${active_startTime}    KW.TimerStart
    log to console    ckeck bts reset
    Wait until keyword succeeds    10min    10s    5GC002479_Resouce.gNB.CheckgNBReset
    log to console    waitAllCellsOnair
    wait until keyword succeeds    30min    10s    COAM_Admin.CheckAllCellsOnair
    ${SW_active_duration}     KW.TimerStop    timestart=${active_startTime}
    ${SW_upgrade_duration}     KW.TimerStop    timestart=${download_startTime}
    log to console    active duration is ${SW_active_duration}
    log to console    KPI4 duration is ${SW_upgrade_duration}
    set suite variable     ${SW_active_duration}
    set suite variable     ${SW_upgrade_duration}
    set suite variable     ${SWM}     ${3}

TC.5GC002479_IA_01_SWM_Max_Duration_of_SW_Download
    [Documentation]  This case is to verify max duration of Software download.For 21A,target is 15min.For 22R1,see OM_GEN_SFS_PERF_CAP.10589
    ...  Test Steps:
    ...    Step1: check if SWM case was run, if not then do SWM software upgrade
    ...    Step2: ${SWM}=${2} means software download is finished.If ${SWM}<${2} that means sw download is not execute and failed
    ...    Step3: check sw loadload duration should be not over target.
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different release.
    ...    {CASE_INPUT_5GC002479['5GC002479_IA_01']['SW_Download_MAX']}: SW download max duration
     set test variable    ${execution_result}    fail
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...   AdjRMOD=${AdjRMOD}
     Run keyword if    ${SWM}==${0}    TC.5GC002479_SWM_Software_Upgrade
     Run keyword if    ${SWM}<${2}     Fail    Step not execute
     log    ${SW_download_duration}
     Should Be True     ${SW_download_duration}<=${KPIAdjValue['SW_Download_MAX']}
     AppendCaseResultToFile    target_value=${KPIAdjValue['SW_Download_MAX']}    result_value=${SW_download_duration}
     set test variable    ${execution_result}    pass

TC.5GC002479_IA_02_OAM_KPI_2a_SWM_Outage_Duration_of_SW_Activation_Inter_Release_without_SM_Firmware_Upgrade
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
     ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2a']['KPI2a_AVG']}: KPI2a average target
     [Arguments]   ${KPI2a_AVG}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2a']['KPI2a_AVG']}
     set suite variable     ${SWM_KPI2A}     ${1}
     set suite variable     ${SWM}     ${0}
     KW.SWM.CheckIfSWActiveRun    stream=${OriginalStream}
     set suite variable     ${SWM_KPI2A}     ${2}
     log        ${SW_active_duration}
     Should Be True     ${SW_active_duration}<=${KPI2a_AVG}

TC.5GC002479_IA_03_OAM_KPI_2b_SWM_Outage_Duration_of_SW_activation_Inter_Release_with_SM_Firmware_Upgrade
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
     ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2b']['KPI2b_AVG']}: KPI2a average target
     [Arguments]   ${OriginalStream}=${CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStream']}
     set test variable    ${execution_result}    fail
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...   AdjRMOD=${AdjRMOD}
     set suite variable     ${SWM_KPI2B}     ${1}
     set suite variable     ${SWM}     ${0}
     KW.SWM.CheckIfSWActiveRun    stream=${OriginalStream}    conditions=&{condition_PS_diff}
     set suite variable     ${SWM_KPI2B}     ${2}
     log        ${SW_active_duration}
     Should Be True     ${SW_active_duration}<=${KPIAdjValue['KPI2b']['KPI2b_AVG']}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2b']['KPI2b_AVG']}    result_value=${SW_active_duration}
     set test variable    ${execution_result}    pass

TC.5GC002479_IA_04_OAM_KPI_2c_SWM_Outage_Duration_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade
     [Documentation]  KPI#2c - Intra-release SW activation downtime without firmware update.
     ...  Test Steps:
     ...    Step1: YAFT SW to same stream build which the firmware is same with target build, Run Software upgrade case
     ...    Step2: check KPI#2c result should be not over target.
     ...  Configurtion Parameters:
     ...    TL configuration: N/A
     ...    TC configuraiton: N/A
     ...    Checkpoint configuration:The target depends on different configuration.
     ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2c']['KPI2c_AVG']}: KPI2c average target
     set test variable    ${execution_result}    fail
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...    AdjRMOD=${AdjRMOD}
     set suite variable     ${SWM_KPI2C}     ${1}
     set suite variable     ${SWM}     ${0}
     KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}   conditions=&{condition_PS_same}
     set suite variable     ${SWM_KPI2C}     ${2}
     log        ${SW_active_duration}
     Should Be True     ${SW_active_duration}<=${KPIAdjValue['KPI2c']['KPI2c_AVG']}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2c']['KPI2c_AVG']}    result_value=${SW_active_duration}
     set test variable    ${execution_result}    pass

TC.5GC002479_IA_06_OAM_KPI_2d_SWM_Outage_Duration_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade
    [Documentation]  KPI#2d - Intra-release SW activation downtime with firmware update.
    ...  Test Steps:
    ...    Step1: YAFT SW to same stream build which the firmware is different with target build, Run Software upgrade case
    ...    Step2: check KPI#2c result should be not over target.
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different configuration.
    ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2c']['KPI2c_AVG']}: KPI2c average target
     set test variable    ${execution_result}    fail
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...    AdjRMOD=${AdjRMOD}
     set suite variable     ${SWM_KPI2D}     ${1}
     set suite variable     ${SWM}     ${0}
     KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}   conditions=&{condition_PS_diff}
     set suite variable     ${SWM_KPI2D}     ${2}
     log        ${SW_active_duration}
     Should Be True     ${SW_active_duration}<=${KPIAdjValue['KPI2d']['KPI2d_AVG']}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2d']['KPI2d_AVG']}    result_value=${SW_active_duration}
     set test variable    ${execution_result}    pass

TC.5GC002479_IA_10_OAM_KPI_62a_SWM_Success_Rate_of_SW_Activation_Inter_Release_without_SM_Firmware_Upgrade
    [Documentation]  KPI#2a - Inter-release SW activation downtime without firmware update.This case is to test duration is not over max target.
    ...  Precondition:This case needs preparing SCF for originail Stream in gnb_configuration,
    ...               because after YAFT to original stream, SCF may be lost.
    ...  Test Steps:
    ...    Step1: check if KPI YAFT SW to original stream build which the firmware is same with target build, Run Software upgrade case
    ...    Step2: check KPI#2a result should be not over max duration target.
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different configuration.
    ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2a']['KPI2a_MAX']}: KPI2a max duration target
    [Arguments]   ${KPI2a_MAX}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2a']['KPI2a_MAX']}
     run keyword if   ${SWM_KPI2A}<${1}     KW.SWM.CheckIfSWActiveRun    stream=${OriginalStream}   conditions=&{condition_PS_same}
     Run keyword if    ${SWM_KPI2A}<${2}     Fail    Step not execute
     log        ${SW_active_duration}
     Should Be True     ${SW_active_duration}<=${KPI2a_MAX}

TC.5GC002479_IA_11_OAM_KPI_62b_SWM_Success_Rate_of_SW_Activation_Inter_Release_with_SM_Firmware_Upgrade
     [Documentation]  KPI#2b - Inter-release SW activation downtime with firmware update.This case is to test duration is not over max target.
    ...  Precondition:This case needs preparing SCF for originail Stream in gnb_configuration,
    ...               because after YAFT to original stream, SCF may be lost.
    ...  Test Steps:
    ...    Step1: check if TC.5GC002479_IA_02_OAM_KPI_2a_SWM_Outage_Duration_of_SW_Activation_Inter_Release_without_SM_Firmware_Upgrade
    ...           is not run then run Software upgrade case with KPI2b condition.
    ...    Step2: check KPI#2b result should be not over max duration target.
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different configuration.
    ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2b']['KPI2b_MAX']}: KPI2b max duration target
    [Arguments]   ${KPI2b_MAX}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2b']['KPI2b_MAX']}
     run keyword if   ${SWM_KPI2B}<${1}     KW.SWM.CheckIfSWActiveRun    stream=${OriginalStream}    conditions=&{condition_PS_diff}
     Run keyword if    ${SWM_KPI2B}<${2}     Fail    Step not execute
     log        ${SW_active_duration}
     Should Be True     ${SW_active_duration}<=${KPI2b_MAX}

TC.5GC002479_IA_12_OAM_KPI_62c_SWM_Success_Rate_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade
   [Documentation]  KPI#2c - Intra-release update - without SM Firmware upgrade during software upgrade.
    ...      This case is to test duration is not over max target.
    ...  Test Steps:
    ...    Step1: check if TC.5GC002479_IA_12_OAM_KPI_62c_SWM_Success_Rate_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade
    ...           is not run then Run Software upgrade case with KPI2c condition.
    ...    Step2: check KPI#2c result should be not over KPI2c_MAX duration target.
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different configuration.
    ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2c']['KPI2c_MAX']}: KPI2c max duration target
    [Arguments]   ${KPI2c_MAX}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2c']['KPI2c_MAX']}
     run keyword if   ${SWM_KPI2C}<${1}     KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}   conditions=&{condition_PS_same}
     Run keyword if    ${SWM_KPI2C}<${2}     Fail    Step not execute
     log        ${SW_active_duration}
     Should Be True     ${SW_active_duration}<=${KPI2c_MAX}

TC.5GC002479_IA_13_OAM_KPI_62d_SWM_Success_Rate_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade
    [Documentation]  KPI#2d - Intra-release SW activation downtime with firmware update.This case is to test duration is not over max target.
    ...  Test Steps:
    ...    Step1: check if TC.5GC002479_IA_06_OAM_KPI_2d_SWM_Outage_Duration_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade
    ...           is not run then Run Software upgrade case with KPI2d condition.
    ...    Step2: check KPI#2d result should be not over KPI2d MAX target
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different configuration.
    ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_MAX']}: KPI2d MAX target
    [Arguments]   ${KPI2d_MAX}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_MAX']}
     run keyword if   ${SWM_KPI2D}<${1}    KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}   conditions=&{condition_PS_diff}
     Run keyword if    ${SWM_KPI2D}<${2}     Fail    Step not execute
     log        ${SW_active_duration}
     Should Be True     ${SW_active_duration}<=${KPI2d_MAX}

TC.5GC002479_IA_15_OAM_KPI_4_SWM_SW_Upgrade_Time_Intra_Release
    [Documentation]  KPI#4 - Complete BTS SW upgrade. This KPI is applicable for any supported SW inter-release upgrade path
    ...      towards the target SW release and also for any SW intra-release upgrade path since 22R1.
    ...  Test Steps:
    ...    Step1: check if software upgrade case is not executed then then Run Software upgrade case with default condition.
    ...    Step2: check KPI#4 result should be not over KPI4 average target
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different configuration.
    ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI4_AVG']}: KPI4 average target
     set test variable    ${execution_result}    fail
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...    AdjRMOD=${AdjRMOD}
     run keyword if   ${SWM_KPI2A}<${1} and ${SWM_KPI2B}<${1} and ${SWM_KPI2C}<${1} and ${SWM_KPI2D}<${1}
         ...    KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}
     Run keyword if    ${SWM}<${3}    Fail    Step not execute
     log        ${SW_upgrade_duration}
     Should Be True     ${SW_upgrade_duration}<=${KPIAdjValue['KPI4']['KPI4_AVG']}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI4']['KPI4_AVG']}    result_value=${SW_upgrade_duration}
     set test variable    ${execution_result}    pass

TC.5GC002479_IA_17_OAM_KPI_4a_SWM_SW_Upgrade_Time_Inter_Release
    [Documentation]  KPI#4a is removed after 22R1.No need to test KPI4a since 22R1. KPI#4 is including both intra and inter release.
    [Arguments]   ${KPI4a_AVG}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI4a']['KPI4a_AVG']}
     run keyword if   ${SWM_KPI2A}<${1} and ${SWM_KPI2B}<${1}    KW.SWM.CheckIfSWActiveRun    stream=${OriginalStream}
     Run keyword if    ${SWM_KPI2A}<${2} and ${SWM_KPI2B}<${2}      Fail    Step not execute
     log        ${SW_upgrade_duration}
     Should Be True     ${SW_upgrade_duration}<=${KPI4a_AVG}

TC.5GC002479_IA_18_OAM_KPI_64_SWM_SW_Upgrade_Success_Rate_without_SM_Firmware_Upgrade_Intra_Release
    [Documentation]  KPI#4 - Complete BTS SW upgrade. This KPI is applicable for any supported SW inter-release upgrade path
    ...      towards the target SW release and also for any SW intra-release upgrade path since 22R1.This TC is check KPI4 max time
    ...  Test Steps:
    ...    Step1: check if software upgrade case is not executed then then Run Software upgrade case with default condition.
    ...    Step2: check KPI#4 result should be not over KPI4 MAX target
    ...  Configurtion Parameters:
    ...    TL configuration: N/A
    ...    TC configuraiton: N/A
    ...    Checkpoint configuration:The target depends on different configuration.
    ...    {CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI4_MAX']}: KPI4 MAX target
    [Arguments]   ${KPI4_MAX}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI4']['KPI4_MAX']}
     run keyword if   ${SWM_KPI2A}<${1} and ${SWM_KPI2B}<${1} and ${SWM_KPI2C}<${1} and ${SWM_KPI2D}<${1}
        ...    KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}
     run keyword if   ${SWM_KPI2A}<${2} and ${SWM_KPI2B}<${2} and ${SWM_KPI2C}<${2} and ${SWM_KPI2D}<${2}    Fail    Step not execute
     log     ${SW_upgrade_duration}
     Should Be True     ${SW_upgrade_duration}<=${KPI4_MAX}

TC.5GC002479_IA_19_OAM_KPI_64a_SWM_SW_Upgrade_Success_Rate_Inter_Release
    [Documentation]  SKPI#4a is removed after 22R1.No need to test tiis TC since 22R1. KPI#4 is including both intra and inter release.
    [Arguments]   ${KPI4a_MAX}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI4a']['KPI4a_MAX']}
     run keyword if   ${SWM_KPI2A}<${1} and ${SWM_KPI2B}<${1}   KW.SWM.CheckIfSWActiveRun    stream=${OriginalStream}
     run keyword if   ${SWM_KPI2A}<${2} and ${SWM_KPI2B}<${2}      Fail    Step not execute
     log        ${SW_upgrade_duration}
     Should Be True     ${SW_upgrade_duration}<=${KPI4a_MAX}

TC.CB008181_SR_A_12_SWM_Duration_of_Fully_PreCheck
    [Documentation]
    ...   Purpose:Check duration of fully PreCheck via NetAct.
    ...   Precondition: Netact has been integrated,and gNB configurated.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: login NetAct and opern app "Software Manager"
    ...     Step2: select the target gNB & SW load to do "fully PreCheck"
    ...     Step3: checkt the duration after operation succeed
    ...     requirement
    [Arguments]   ${DurationOfSwPrecheck}=${SWM_12['DurationOfSwPrecheck']}
    set test variable    ${execution_result}    fail
    Log To Console    Step1: login NetAct and opern app "Software Manager"
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
            ...    showall=false
    selenium_netact.open_configuration_software_manager
    sleep    5s
    Log To Console    Step2: select the target gNB & SW load to do "fully PreCheck"
    KW.Select Target gNB in NetAct    BTS_ID=${MRBTS_ID}
    btslog.startbtslogcollection
    ${target_sw_load}    KW.Select SW package and finish fully PreCheck    sw_version=${CASE_INPUT_5GC002479['StreamPrefix']}
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step3: checkt the duration after operation succeed
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "SWM PrecheckRequestTask created"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${SWPreCheck_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWPreCheck_startTime}
    ${SWPreCheck_startTime}     convert date
    ...    ${SWPreCheck_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Precheck result succeeded"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${SWPreCheck_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWPreCheck_endTime}
    ${SWPreCheck_endTime}        convert date
    ...     ${SWPreCheck_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${DurationOfSwPreCheck_tmp_SWM12}    Evaluate    ${SWPreCheck_endTime}-${SWPreCheck_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSwPreCheck_tmp_SWM12}<=${DurationOfSwPrecheck} and ${DurationOfSwPreCheck_tmp_SWM12}>${0}
    Log To Console    PreCheck Duration of SW:${target_sw_load} is ${DurationOfSwPreCheck_tmp_SWM12}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwPrecheck}    result_value=${DurationOfSwPreCheck_tmp_SWM12}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_A_13_SWM_Duration_of_PostCheck
    [Documentation]
    ...   Purpose:Check duration of PostCheck via NetAct.
    ...   Precondition: Netact has been integrated,and gNB configurated.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: login NetAct and opern app "Software Manager"
    ...     Step2: select the target gNB & SW load to do "PostCheck"
    ...     Step3: checkt the duration after operation succeed
    ...     requirement
    [Arguments]   ${DurationOfSwPostCheck}=${SWM_13['DurationOfSwPostcheck']}
    set test variable    ${execution_result}    fail
    Log To Console    Step1: login NetAct and opern app "Software Manager"
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
            ...    showall=false
    selenium_netact.open_configuration_software_manager
    sleep    5s
    Log To Console    Step2: select the target gNB & SW load to do "PostCheck"
    KW.Select Target gNB in NetAct    BTS_ID=${MRBTS_ID}
    btslog.startbtslogcollection
    ${target_sw_load}    KW.Select SW package and finish PostCheck    sw_version=${CASE_INPUT_5GC002479['StreamPrefix']}
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step3: checkt the duration after operation succeed
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "SWM PostcheckRequestTask created"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${SWPostCheck_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWPostCheck_startTime}
    ${SWPostCheck_startTime}     convert date
    ...    ${SWPostCheck_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Postcheck result succeeded"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${SWPostCheck_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWPostCheck_endTime}
    ${SWPostCheck_endTime}        convert date
    ...     ${SWPostCheck_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${DurationOfSwPostCheck_tmp_SWM13}    Evaluate    ${SWPostCheck_endTime}-${SWPostCheck_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSwPostChecktmp_SWM13}<=${DurationOfSwPostcheck} and ${DurationOfSwPostCheck_tmp_SWM13}>${0}
    Log To Console    PostCheck Duration of SW:${target_sw_load} is ${DurationOfSwPostChecktmp_SWM13}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwPostCheck}    result_value=${DurationOfSwPostChecktmp_SWM13}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_A_15_SWM_Duration_of_SW_Rollback
    [Documentation]  Check the duration of SW rollback
    [Arguments]   ${DurationOfSwrollback}=${SWM_15['DurationOfSwrollback']}
    set test variable    ${execution_result}    fail
    Log To Console    Step1: Trigger 1st SW rollback via WebEM
    btslog.startbtslogcollection
    rollback site
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step2: Check 1st SW rollback duration1 from syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "SW_ROLLBACK_IND"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${SWRollback_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWRollback_startTime}
    ${SWRollback_startTime}     convert date
    ...    ${SWRollback_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "SW_ROLLBACK_RESULT"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${SWRollback_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWRollback_endTime}
    ${SWRollback_endTime}        convert date
    ...     ${SWRollback_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${SWRollback_duration_tmp_SWM15}    Evaluate    ${SWRollback_endTime}-${SWRollback_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${SWRollback_duration_tmp_SWM15}<=${DurationOfSwrollback} and ${SWRollback_duration_tmp_SWM15}>${0}
    log to console    duration1 of SW Rollback activation is ${SWRollback_duration_tmp_SWM15}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    Log To Console    Step1: Trigger 2nd SW rollback via WebEM
    btslog.startbtslogcollection
    rollback site
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step2: Check 2nd SW rollback duration2 from syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "SW_ROLLBACK_IND"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${SWRollback_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWRollback_startTime}
    ${SWRollback_startTime}     convert date
    ...    ${SWRollback_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "SW_ROLLBACK_RESULT"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${SWRollback_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWRollback_endTime}
    ${SWRollback_endTime}        convert date
    ...     ${SWRollback_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${SWRollback_duration_tmp_SWM15}    Evaluate    ${SWRollback_endTime}-${SWRollback_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${SWRollback_duration_tmp_SWM15}<=${DurationOfSwrollback} and ${SWRollback_duration_tmp_SWM15}>${0}
    log to console    duration2 of SW Rollback activation is ${SWRollback_duration_tmp_SWM15}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwrollback}    result_value=${SWRollback_duration_tmp_SWM15}
    set test variable    ${execution_result}    pass


TC.CB008181_SR_A_16_SWM_Duration_of_ Upload_SW_Configuration
    [Documentation]
    ...   Purpose:Check duration of upload sw configuration via NetAct.
    ...   Precondition: Netact has been integrated,and gNB configurated.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: login NetAct and opern app "Software Manager"
    ...     Step2: select the target gNB and do operation "upload"
    ...     Step3: checkt the duration after operation succeed
    ...     requirement
    [Arguments]   ${DurationOfSwConfigUpload}=${SWM_16['DurationOfSwConfigUpload']}
    set test variable    ${execution_result}    fail
    Log To Console    Step1: login NetAct and opern app "Software Manager"
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
            ...    showall=false
    selenium_netact.open_configuration_software_manager
    sleep    5s
    Log To Console    Step2: select the target gNB and do operation "Upload"
    KW.Select Target gNB in NetAct    BTS_ID=${MRBTS_ID}
    btslog.startbtslogcollection
    KW.Upload Target gNB SW Configuration
    NetAct.Logout
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step3: checkt the duration after operation succeed
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "COMA_UPLOAD"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${SWupload_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWupload_startTime}
    ${SWupload_startTime}     convert date
    ...    ${SWupload_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "OPERATION_PASSED"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${SWupload_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWupload_endTime}
    ${SWupload_endTime}        convert date
    ...     ${SWupload_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${DurationOfSwConfigUpload_tmp_SWM16}    Evaluate    ${SWupload_endTime}-${SWupload_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSwConfigUpload_tmp_SWM16}<=${DurationOfSwConfigUpload} and ${DurationOfSwConfigUpload_tmp_SWM16}>${0}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwConfigUpload}    result_value=${DurationOfSwConfigUpload_tmp_SWM16}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_A_17_SWM_Duration_of_ Cancel_SW_Management
    [Documentation]
    ...   Purpose:Check duration of Cancel SW Management.
    ...   Precondition: Netact has been integrated,and gNB configurated.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: login NetAct and opern app "Software Manager"
    ...     Step2: Step2: select the target gNB and download or Provision then cancel it
    ...     Step3: check the duration meet the requirement or not
    [Arguments]   ${DurationOfSwCancel}=${SWM_17['DurationOfSwCancel']}
    set test variable    ${execution_result}    fail
    Log To Console    Step1: login NetAct and opern app "Software Manager"
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
            ...    showall=false
    selenium_netact.open_configuration_software_manager
    sleep    5s
    Log To Console    Step2: select the target gNB and download or Provision then cancel it
    KW.Select Target gNB in NetAct    BTS_ID=${MRBTS_ID}
    btslog.startbtslogcollection
    ${target_sw_load}    KW.Select SW package and download then Cancel it    sw_version=${CASE_INPUT_5GC002479['StreamPrefix']}
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step3: check the duration meet the requirement or not
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "SW_UPDATE_ABORT_IND"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${SWCancel_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWCancel_startTime}
    ${SWCancel_startTime}     convert date
    ...    ${SWCancel_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Trying to create RESULT under"|grep "SW_UPDATE_ABORT_IND"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${SWCancel_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${SWCancel_endTime}
    ${SWCancel_endTime}        convert date
    ...     ${SWCancel_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${DurationOfSWCancel_tmp_SWM17}    Evaluate    ${SWCancel_endTime}-${SWCancel_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSWCanceltmp_SWM17}<=${DurationOfSwCancel} and ${DurationOfSWCancel_tmp_SWM17}>${0}
    Log To Console   Duration of SW Cancel is ${DurationOfSWCanceltmp_SWM17}s
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwCancel}    result_value=${DurationOfSWCanceltmp_SWM17}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_A_18_SWM_Duration_of_Copy_SW_from_Active_to_Passive_Partition_Manually_Triggered
   [Documentation]
    ...   Purpose:Check duration of Copy SW from active to Passive with health check
    ...   Precondition: SWs in active partition and passive partition are diff
    ...   Test tools:WebEM，btslog
    ...   Test Steps:
    ...     Step1: login WebEM and set the relate parameters
    ...     Step2: wait SW copy succeed
    ...     Step3: check the duration from syslogs
    [Arguments]   ${DurationOfSwCopyManual}=${SWM_18['DurationOfSwCopyManual']}
    set test variable    ${execution_result}    fail
    Log To Console    Step1: login WebEM and set the relate parameters
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${active_version}    string.split string    string=${version}[Active]
    ${passive_version}    string.split string    string=${version}[Passive]
    run keyword if    ${active_version}==${passive_version}    Fail    precondition not meet.
    run keyword and ignore error    selenium_sbts.remove_object    object_name=${MRBTS_ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    run keyword and ignore error    CM_WebEM.ValidateAndActiveParameters
    btslog.startbtslogcollection
    run keyword and ignore error   selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1
    ...    object_class_name=CMD  id_value=1    timeout=60
    Wait Until Keyword Succeeds    2min    5s   selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/CMD-1
    ...    object_class_name=COPYSWTOPASSIVEREQ   timeout=60
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    ...      abbr=COPYSWTOPASSIVEREQ instance id    value=${1}
    Wait Until Keyword Succeeds    2min    5s   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    ...      abbr=Copy SW and config to passive partition command    value=SW and config with health check
    CM_WebEM.ValidateAndActiveParameters
    Log To Console    Step2: wait SW copy succeed
    sleep   8min
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step3: check the duration from syslogs
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "COPYSWTOPASSIVEREQ"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${SwCopy_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${SwCopy_startTime}
    ${SwCopy_startTime}     convert date
    ...    ${SwCopy_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "CopySwToPassive"|grep -E
    ...     "Result succesfull|Copy Sw to passive was successfull"|awk '{print $7}'|head -n 1|tail -1
    ${SwCopy_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${SwCopy_endTime}
    ${SwCopy_endTime}        convert date
    ...     ${SwCopy_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${DurationOfSwCopy_tmp_SWM18}    Evaluate    ${SwCopy_endTime}-${SwCopy_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSwCopy_tmp_SWM18}<=${DurationOfSwCopyManual} and ${DurationOfSwCopy_tmp_SWM18}>${0}
    Log To Console   Duration of Copy SW from active to passive is ${DurationOfSwCopy_tmp_SWM18}s
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][0]}
    ...    target_value=${DurationOfSwCopyManual}    result_value=${DurationOfSwCopy_tmp_SWM18}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_A_31_Troubleshooting_Maximum_number_of_simultaneous_DCC_user_sessions_in_the_BTS
       [Documentation]   OM_GEN_SFS_PERF_CAP.4890
    ...  Purpose:Aim to DCC user session max counter is 1
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI, CLI
    ...  Test Steps:
    ...    Step1: prepare ADMNICLI
    ...    Step2:enable DCC support in WebEM
    ...    Step3:Check DCC count session is not more than 1
    ...    Checkpoint configuration:
    [Arguments]   ${DCCSessionCount}=1
    log to console    Step1:Prepare admincli
    KW.PrepareAdminCli
    log to console    Step2:enable DCC support in WebEM
    COAM_WebEM.Login
    run keyword and ignore error    COAM_WebEM.SetParameterValue  distName=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    abbr=Activate DCC support    value=true
    run keyword and ignore error    COAM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error    COAM_WebEM.Logout
    log to console    Step3: open dcc count session
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9
    ${cmd}   set variable   --bts-host=${ASIK_LMP_IP} --bts-port=9020 --insecure=false --bts-username=dcuser --bts-password="nE&e3Q*ptK8"
    ${SessionMax}    Evaluate     ${1}+${DCCSessionCount}
    FOR    ${i}    IN RANGE    ${SessionMax}
        run    command=cd ${CLI_PATH}&&./admin-cli.sh --cli-port=9020 ${cmd} >log${i}.txt&
        Sleep    5s
        ${result}    run    command=cd ${CLI_PATH}&&cat log${i}.txt
        log to console    Step4:Check connect successfully within maximum remote user sessions,and fail when sessions out of range
        run keyword if   ${i}!=${DCCSessionCount}    should be true    ${result.count('BTS connected')}>0
        ...    ELSE    should be true    ${result.count('listen EADDRINUSE: address already in use')}>0
    END
    run    command=ps -ef|grep admin-cli.sh|grep -v grep|awk '{print $2}' | xargs kill -9

TC.CB008181_SR_A_33_Troubleshooting_IP_connectivity_test
    [Documentation]   OM_GEN_SFS_PERF_CAP.6964
    ...  Purpose:Aim to test IP connectivity test duration
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: login WebEM to perform  IP connectivity test then start point
    ...    Step2: Wait until next IP connectivity test successful  -- end point
    ...    Step3: Check the duatation is not more than target
    ...    Checkpoint configuration:
    [Arguments]   ${IP_connectivity}=20
    set test variable    ${execution_result}    fail
    log to console    Step1: login WebEM to perform IP connectivity test
    wait until keyword succeeds   15min    10s    COAM_Admin.Login
    Timer.Start
    admin.test_ip_connectivity    remote_address=${UTE_IP}    dscp=10    payload_size=34    source_address=User-defined address    connection=COAM
    ${duration}    Timer.Stop
    Should Be True     ${duration}<=${IP_connectivity}
    COAM_Admin.Logout
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${IP_connectivity}    result_value=${duration}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_A_34_Troubleshooting_System_Module_Sanity_Checker
    [Documentation]   OM_GEN_SFS_PERF_CAP.10677
    ...  Purpose:Aim to test run sanity checker duration
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: login WebEM to perform run sanity checker --start point
    ...    Step2: sanity checker successful  -- end point
    ...    Step3: Check the duatation is not more than target
    ...    Checkpoint configuration:
    [Arguments]   ${Sanity_Checker}=60
    set test variable    ${execution_result}    fail
    log to console    Step1: System Module Sanity Checker
    wait until keyword succeeds   15min    10s    COAM_Admin.Login
    Timer.Start
    admin.run_sanity_check    connection=COAM
    ${duration}    Timer.Stop
    Should Be True     ${duration}<=${Sanity_Checker}
    COAM_Admin.Logout
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Sanity_Checker}    result_value=${duration}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_A_41_Duration_of_Configuration_Reset
    [Documentation]   OM_GEN_SFS_PERF_CAP.13130
    ...  Purpose:Aim to test configuration reset duration
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: login WebEM to perform configuration reset   --start point
    ...    Step2: Wait until gnb is in uncommission state  -- end point
    ...    Step3: Check the duatation is not more than target
    ...    Step4: commission to recovery gnb
    ...    Checkpoint configuration:
    [Arguments]   ${Configuration_Reset}=600
    set test variable    ${execution_result}    fail
    log to console    Step0: get gnb mode is dual core or single core
    ${gNBMode}    gNB.CheckgNBCoreMode
    set test variable      ${gNBMode}
    log to console    Step1: login WebEM to perform configuration reset
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    Timer.Start
    KW.gNB.ConfigurationReset
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run    command=killall firefox
    log to console    Wait until gnb is in uncommission state  -- end point
    wait until keyword succeeds   10min    10s     KW.gnb.LoginWithCoreMode    mode=${gNBMode}
    wait until keyword succeeds   10min    10s     KW.gnb.CheckBTSStatus
    ${duration}    Timer.Stop
    Should Be True     ${duration}<=${Configuration_Reset}
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    gNB.Commission   scf_file=${BACKUP_SCF}
    wait until keyword succeeds    30min    20s    COAM_Admin.CheckAllCellsOnair
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Configuration_Reset}    result_value=${duration}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_C_09_Cell_lock_unlock_duration_KPI16a_KPI16b
    [Documentation]
    ...  Purpose:Check OAM KPI17,The BTS shall complete the block/unblock Cell operations within target duration
    ...  Precondition: cell on air
    ...  Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:Block/Unblock one by one,and check every cell's duration meet target
    set test variable    ${execution_result}    fail
    log to console    Step1:Block/Unblock one by one,and check every cell's duration meet target
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    FOR    ${CELL}   IN    @{BTSInfo['cells']['nr']}
        @{RMODsList}=  Create List
        ${cell_config}=    Split String From Right    ${CELL['id']['configuration']}     /
        ${nrcell}   Set Variable     ${cell_config[-1]}
        ${tmp_cell}=    Split String From Right    ${nrcell}     -
        ${CELL_INDEX}   Set Variable     ${tmp_cell[-1]}
        ${rmod_config}=    Split String From Right    ${CELL['carrierList'][0]['antennaLineId']['configuration']}     /
        ${RMOD_ID}   Set Variable     ${rmod_config[-2]}
        ${RMODName}    KW.GetRMODNameByID     RMOD_ID=${RMOD_ID}
        Append To List    ${RMODsList}    ${RMODName}
        ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}    SFPCooled=False    AdjRMOD=${AdjRMOD}
        KW.CB008181_SR_C_09_Cell_lock_unlock_duration_KPI16a_KPI16b    CellLockDuration=${KPIAdjValue['KPI16a']}
        ...    CellUnlockDuration=${KPIAdjValue['KPI16b']}      cell_idx=${CELL_INDEX}
     END
    set test variable    ${execution_result}    pass

TC.CB008181_SR_C_15_OAM_KPI_10_5G_RAT_reset
    [Documentation]   OM_GEN_SFS_PERF_CAP.12897
    ...  Purpose:Aim to test KPI10 5G RAT reset duration
    ...  Precondition:BTS is commissioned with 5G RAT
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: login WebEM to check gnb is single core or dual core - target is extended 60 seconds if dual core
    ...    Step2: Check gnb type, get sctpWaitTimeInitSeqRetryX2 value if it is NSA - target is extended sctpWaitTimeInitSeqRetryX2 if NSA
    ...    Step3: Perform NR RAT reset   --start point
    ...    Step4: Wait until all cells are up  -- end point
    ...    Step5: Check the duatation is not more than target
    ...    Checkpoint configuration:
    [Arguments]   ${KPI10}=${CASE_INPUT_CB008181['CB008181_C_KPI10']['KPI10']}
    ...           ${DualCoreExtend}=${CASE_INPUT_CB008181['CB008181_C_KPI10']['DualCoreExtend']}
    ...           ${NSAExtend}=${CASE_INPUT_CB008181['CB008181_C_KPI10']['NSAExtend']}
     log to console    Step1: login WebEM to check gnb is single core or dual core - target is extended 60 seconds if dual core
     set test variable    ${execution_result}    fail
     BtsLog.StartBTSlogCollection
     ${gNBMode}    gNB.CheckgNBCoreMode
     ${gNBType}    KW.CP_GetgNBType
     ${ModeExtendValue}=    Set Variable if   "${gNBMode}"=="Dualcore"   ${DualCoreExtend}    ${0}
     log to console     Step2. target is extended sctpWaitTimeInitSeqRetryX2 if NSA
     ${NSAExtendValue}=    Set Variable if   "${gNBType}"=="NSA"   ${NSAExtend}    ${0}
     ${ExtendValue}=    Catenate    ${KPI10}+${ModeExtendValue}+${NSAExtendValue}
     ${KPI10}    Evaluate    ${ExtendValue}
     wait until keyword succeeds   10min    10s    COAM_WebEM.Login    version=SBTS22R4
     Timer.Start
     selenium_coam.reset_nr
     sleep  30s
     Wait Until Keyword Succeeds    20 min    10 sec    COAM_WebEM.VerifyAllCellsAreOnline
     ${duration}    Timer.Stop
     Should Be True     ${duration}<=${KPI10}
     AppendCaseResultToFile    target_value=${KPI10}    result_value=${duration}
     set test variable    ${execution_result}    pass

KW.CB008181_SR_C_09_Cell_lock_unlock_duration_KPI16a_KPI16b
    [Arguments]      ${CellLockDuration}    ${CellUnlockDuration}    ${cell_idx}=1
    log to console    Step1: Trigger cell lock and start BTSLog
    BtsLog.StartBTSlogCollection
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=lock    checkstatus=false
    sleep    40s
    COAM_WebEM.Logout
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step2: Check lock cell_duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "handleNewActivateRequest: activation started"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${lockcell_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${lockcell_startTime}
    ${lockcell_startTime}     convert date
    ...    ${lockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${lockcell_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${lockcell_endTime}
    ${lockcell_endTime}        convert date
    ...     ${lockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${lockcell_duration}    Evaluate    ${lockcell_endTime}-${lockcell_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${lockcell_duration}<=${CellLockDuration} and ${lockcell_duration}>${0}
    log to console   lock cell duration is ${lockcell_duration}
    log to console    Step3: Trigger cell unlock and start BTSLog
    BtsLog.StartBTSlogCollection
    COAM_WebEM.Login
    wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=unlock    checkstatus=false
    sleep    40s
    COAM_WebEM.Logout
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step4: Check unlock cell_duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "handleNewActivateRequest: activation started"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${unlockcell_startTime}     run    command=${cmd}
    Should Not Be Empty     ${unlockcell_startTime}
    ${unlockcell_startTime}     convert date
    ...     ${unlockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${unlockcell_endTime}     run    command=${cmd}
    Should Not Be Empty     ${unlockcell_endTime}
    ${unlockcell_endTime}        convert date
    ...      ${unlockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${unlockcell_duration}    Evaluate    ${unlockcell_endTime}-${unlockcell_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${unlockcell_duration}<=${CellUnlockDuration} and ${unlockcell_duration}>${0}
    log to console   unlock cell duration is ${unlockcell_duration}
    AppendCaseResultToFile    index=NRCELL_${cell_idx}_lock
    ...    target_value=${CellLockDuration}    result_value=${lockcell_duration}
    AppendCaseResultToFile    index=NRCELL_${cell_idx}_unlock
    ...    target_value=${CellUnlockDuration}    result_value=${unlockcell_duration}

KW.Select SW package and download then Cancel it
    [Arguments]    ${sw_version}
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[Active]    separator=_
    ${result3}     convert to string    ${result}[-3]
    ${result4}     convert to string    ${result}[-5]
    ${Sw_build_version}=
    ...   Run Keyword If   "${result4}"=="SBTS22R1" or "${result4}"=="SBTS22R2" or "${result4}"=="SBTS22R3" and "${result3}"=="0000"
    ...   set variable       ${sw_version}
    ...   ELSE IF      "${result4}"=="SBTS22R4" and "${result3}"=="9999"
    ...   string.Replace String     ${sw_version}    SBTS00    SBTS22R4
    ...   ELSE     Set Variable     ${sw_version}
    ${Selected_SW_xpath}=
    ...   Set Variable
    ...   //div[contains(text(), '${Sw_build_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${New_task_xpath}
    sleep    5s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${SW_download_xpath}
    sleep    5s
    ${select_button}    run keyword and ignore error    selenium_netact.click_button     ${Selected_SW_xpath}
    Run Keyword If   "${select_button[0]}"=="FAIL"    selenium_netact.click_button
    ...     //div[contains(text(), '${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${finish_xpath}
    sleep    5s
    wait until keyword succeeds    3min    10s    selenium_netact.click_button    ${Network_Operations_view_xpath}
    sleep    60s
    wait until keyword succeeds    3min    10s    selenium_netact.click_button     ${Cancel_button_xpath}
    sleep    5s
    run keyword and ignore error    selenium_netact.click_button     ${Cancel_confirm_OK_xpath}
    sleep    60s
    ${SW_Task_status}    wait until keyword succeeds    1min    10s
    ...      selenium_netact.get_elem_text   ${Operation_status_xpath}
    should be equal    Canceled    ${SW_Task_status}
    sleep    5s

KW.Select SW package and finish fully PreCheck
    [Arguments]    ${sw_version}
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[Active]    separator=_
    ${result3}     convert to string    ${result}[-3]
    ${result4}     convert to string    ${result}[-5]
    ${Sw_build_version}=
    ...   Run Keyword If   "${result4}"=="SBTS22R1" or "${result4}"=="SBTS22R2" or "${result4}"=="SBTS22R3" and "${result3}"=="0000"
    ...   set variable       ${sw_version}
    ...   ELSE IF      "${result4}"=="SBTS22R4" and "${result3}"=="9999"
    ...   string.Replace String     ${sw_version}    SBTS00    SBTS22R4
    ...   ELSE     Set Variable     ${sw_version}
    ${Selected_SW_xpath}=
    ...   Set Variable
    ...   (//div[contains(text(), '${Sw_build_version}')])[last()]/parent::td/preceding-sibling::td[1]//input[@type='radio']

    sleep    5s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${New_task_xpath}
    sleep    5s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${PreCheck_xpath}
    sleep    5s
    ${select_button}    run keyword and ignore error    selenium_netact.click_button     ${Selected_SW_xpath}
    Run Keyword If   "${select_button[0]}"=="FAIL"    selenium_netact.click_button
    ...     (//div[contains(text(), '${sw_version}')])[last()]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${finish_xpath}
    sleep    120s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${Operation_details_xpath}
    ${target_sw_load}    selenium_netact.get_elem_text    ${target_software}
    [Return]  ${target_sw_load}

KW.Select SW package and finish PostCheck
    [Arguments]    ${sw_version}
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[Active]    separator=_
    ${result3}     convert to string    ${result}[-3]
    ${result4}     convert to string    ${result}[-5]
    ${Sw_build_version}=
    ...   Run Keyword If   "${result4}"=="SBTS22R1" or "${result4}"=="SBTS22R2" or "${result4}"=="SBTS22R3" and "${result3}"=="0000"
    ...   set variable       ${sw_version}
    ...   ELSE IF      "${result4}"=="SBTS22R4" and "${result3}"=="9999"
    ...   string.Replace String     ${sw_version}    SBTS00    SBTS22R4
    ...   ELSE     Set Variable     ${sw_version}
    ${Selected_SW_xpath}=
    ...   Set Variable
    ...   //div[contains(text(), '${Sw_build_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${New_task_xpath}
    sleep    5s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${PostCheck_xpath}
    sleep    5s
    ${select_button}    run keyword and ignore error    selenium_netact.click_button     ${Selected_SW_xpath}
    Run Keyword If   "${select_button[0]}"=="FAIL"    selenium_netact.click_button
    ...     //div[contains(text(), '${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${finish_xpath}
    sleep    120s
    wait until keyword succeeds    2min    5s    selenium_netact.click_button     ${Operation_details_xpath}
    ${target_sw_load}    selenium_netact.get_elem_text    ${target_software}
    [Return]  ${target_sw_load}

KW.Upload Target gNB SW Configuration
    [Documentation]   upload target gNB SW version to NetAct
    selenium_netact.wait_for_enable        ${Upload_xpath}
    sleep    10s
    selenium_netact.Click Button    ${Upload_xpath}
    sleep    2min
    wait until keyword succeeds    3min    10s    selenium_netact.click_button    ${Network_Operations_view_xpath}
    sleep    60s
    ${SW_Task_status}    wait until keyword succeeds    1min    10s
    ...      selenium_netact.get_elem_text   ${Operation_status_xpath}
    should be equal    Successful    ${SW_Task_status}

KW.Select Target gNB in NetAct
    [Documentation]   Select tagaet gNB in software management/Network status
    [Arguments]  ${BTS_ID}   ${MO_Type_value}=MRBTS   ${View_value}=Parent
    wait until keyword succeeds    2min    5s    selenium_netact.write_value_and_enter      ${MO_Type_xpath}      ${MO_Type_value}
    sleep    10s
    wait until keyword succeeds    2min    5s    selenium_netact.write_value_and_enter      ${View_xpath}      ${View_value}
    sleep    10s
    wait until keyword succeeds    2min    5s    selenium_netact.select_checkbox      ${Parent_xpath}
    sleep    20s
    run keyword and ignore error    selenium_netact.select_checkbox      //*[@id="swmTable_networkView_clearFilters"]/a/div/span
    sleep    20s
    wait until keyword succeeds    2min    5s    selenium_netact.select_checkbox      //*[@id="swmTable_networkView_refreshTable"]/div/a/div/span
    sleep    20s
    wait until keyword succeeds    2min    5s    selenium_netact.select_checkbox      //*[@id="refresh"]
    sleep    20s
    wait until keyword succeeds    2min    5s    selenium_netact.write_value_and_enter     ${MO_DN_xpath}     ${BTS_ID}
    sleep    30s
    wait until keyword succeeds    2min    5s    selenium_netact.select_checkbox     ${Radio_Select_box}
    sleep    20s

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
    return from keyword if    '${CLI_PATH}'!='NotSet'
    KW.WebEM.EnableActcli
    run  command=cd ${LOG_PATH}&&rm -rf CLI &&mkdir CLI
    Set Suite Variable    ${CLI_PATH}    ${LOG_PATH}/CLI/
    ${StreamPrefix}    Basic.GetSBTSStreamPrefix    vstring=${TARGETSW}
    ${StreamFolder}    Set Variable if    ${TARGETSW.count('SBTS')}>0    ${StreamPrefix}/    ${EMPTY}
    ${wft_url}    Set Variable if    ${TARGETSW.count('SBTS')}>0    ${link_to_Artifact_SBTS_WFT}${StreamFolder}    ${link_to_Artifact}
    ${filename_prefix}   Set Variable if    ${TARGETSW.count('SBTS')}>0    ${EMPTY}    ${CASE_INPUT_5GC002479['StreamPrefix']}

    WFT.DownloadPackage   link_to_Artifact=${wft_url}
    ...    filename=${filename_prefix}${TARGETSW}_ADMIN_CLI.zip
    ...    UPDATE_FILE_PATH=${CLI_PATH}
    run    command=cd ${CLI_PATH}&& unzip ${filename_prefix}${TARGETSW}_ADMIN_CLI.zip

KW.WebEM.EnableActcli
    COAM_WebEM.Login
    run keyword and ignore error    COAM_WebEM.SetParameterValue  distName=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    abbr=Activate CLI    value=true
    run keyword and ignore error    COAM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error    COAM_WebEM.Logout

KW.NetAct.Init
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['StreamPrefix']
    ...    default_value=SBTS00_ENB_9999
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['NETACT_URL']
    ...    default_value=https://na20lbwas.qin1.srnhz.nsn-rdnet.net
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['NETACT_USER']
    ...    default_value=omc
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['NETACT_PASSWORD']
    ...    default_value=Nokia123!
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['NETACT_LOGSERVER_IP']
    ...    default_value=10.107.178.201
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['NETACT_LOGSERVER_USERNAME']
    ...    default_value=root
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['NETACT_LOGSERVER_PASSWORD']
    ...    default_value=arthur
    Basic.CheckVariableValid    var=TC5GC002479['KPI5']
    ...                         default_value=270
    Set Suite Variable    ${NETACT_LOGSERVER_IP}          ${CASE_INPUT_5GC002479['NETACT_LOGSERVER_IP']}
    Set Suite Variable    ${NETACT_LOGSERVER_USERNAME}    ${CASE_INPUT_5GC002479['NETACT_LOGSERVER_USERNAME']}
    Set Suite Variable    ${NETACT_LOGSERVER_PASSWORD}    ${CASE_INPUT_5GC002479['NETACT_LOGSERVER_PASSWORD']}
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
    [Arguments]      ${virtual_enable}=${TRUE}    ${url}=${WEBUI_URL}    ${alias}=None
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

RU_Reset_Teardown case
    Run Keyword And Ignore error       WEBUI.Collect snapshot
    TestteardownforWebEM

TestteardownforWebEM
    [Arguments]   ${connection}=COAM
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    WEBUI.Collect snapshot
    ...    ELSE    run keyword if    '${TEST STATUS}' == 'PASS'    log to console    Not collect snapshot logs
    Set test Variable    ${CLI_PATH}    NotSet
    Run Keyword And Ignore Error    run    command=ps xafu |grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    Run Keyword And Ignore Error         KW.CleanFirefox
    Run Keyword And Ignore Error    run    command=rm -rf /opt/ute/YAFT/YAFT_IMAGE/*
    Run Keyword And Ignore Error    run    command=rm -rf ${UPDATE_FILE_PATH}/*
    TestCase.Stop

TestteardownforWebEM_tmp
    ${res}     run keyword and ignore error     COAM_Admin.CheckAllCellsOnair
    run keyword if   '${res[0]}'=='FAIL'    run keywords
    ...      Run Keyword And Ignore error       WEBUI.Collect snapshot
    ...      AND   Power.ResetgNB     model=${model}
    wait until keyword succeeds    10min    20s    COAM_Admin.CheckAllCellsOnair
    TestteardownforWebEM

AppendCaseResultToFile
    [Arguments]   ${requirement_id}=NA    ${index}=NA    ${ru_type}=NA    ${ru_index}=NA
    ...           ${target_value}=NA   ${result_value}=NA    ${case_result}=NA
    ${check_kpi_value}    run keyword if
    ...    '${result_value}'!='NA' and '${target_value}'!='NA' and ${result_value}<=${target_value} and ${result_value}>${0}
    ...    set variable    pass
    ...    ELSE    set variable    fail

    ${data}    run keyword if    '${case_result}'!='NA'
    ...   Catenate    SEPARATOR=,    ${TEST NAME}    ${requirement_id}    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${case_result}\n
    ...   ELSE    Catenate    SEPARATOR=,    ${TEST NAME}    ${requirement_id}    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${check_kpi_value}\n

    Append To File    ${case_result_save_path}    ${data}

KW.TestSetup.SanityCheck
     coam_webem.login
     ${sanity_Error_exist}    run keyword and ignore error    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7115
        ...    target_fault_id=4681    target_fault_name=Sanity Check Error    target_severity=minor
     Run Keyword If    '${sanity_Error_exist[0]}'=='PASS'    Fail    case not run due to sanity check error

KW.TeardownForUncomssioncase
    ${res}     run keyword and ignore error     KW.gnb.CheckBTSStatus     BTS_status=Not commissioned
    run keyword if   '${res[0]}'=='PASS'    gNB.Commission   scf_file=${BACKUP_SCF}
    wait until keyword succeeds    20min    20s    COAM_Admin.CheckAllCellsOnair
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


KW.CP Suite setup for 2479
    [Documentation]
    [Arguments]
    gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    Import Variables         /home/ute/TAF/cfgfile/2479_Loop_times.py
    TestCase.Set_Case_Variable

KW.CP Teardown Suite
    TestSuite.Stop

AA_Teardown case
    TestteardownforWebEM
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    gNB.Commission   scf_file=${BACKUP_SCF}
    ...    ELSE    run keyword if    '${TEST STATUS}' == 'PASS'    log to console    Not collect snapshot logs
    wait until keyword succeeds    20min    20s    COAM_Admin.CheckAllCellsOnair

####################################### 5GC002479-BA PM #######################################
Change PM ReportingInterval
    [Arguments]    ${pm_time}
    Wait Until Keyword Succeeds    2 times    30s
    ...    COAM_WebEM.SetParameterValue    ${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1    Performance measurement data reporting interval
    ...    value=${pm_time}
     CM_WebEM.ValidateAndActiveParameters

BA_01_Teardown case
    run keyword if         '${pm_interval_org}'!='${PMINTERVAL}min'    Change PM ReportingInterval   ${pm_interval_org}
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
    ...      abbr=NR Beamforming                                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Carrier Aggregation Central Unit (CU)          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Carrier Aggregation Distributed Unit (gNB-DU)      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Cell Availability                              value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Cell Utilization per PLMN                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Cell Utilization                               value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR DL HARQ                                        value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR DL Signal Quality Level                        value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR DL Signal Quality Level 2                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR E1AP Interface Report per BTS                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR E1AP Interface Report per CU-CP for NSA        value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR E1AP Interface Report per CU-CP for SA         value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR E1AP Interface Report per CU-UP   value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR E1AP Interface Report per CU-UP for NSA        value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR E1AP Interface Report per CU-UP for SA         value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR eCPRI U-Plane & Fast-C-Plane                   value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Equivalent Isotropic Radiated Power            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR EN DSS per NR cell                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR F1AP Interface Report per CELL                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR F1AP Interface Report per DU                   value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR F1-U Interface Report BTS                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR F1-U Interface Report DU                       value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR F1AP Interface Report for CU per DU            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR GNSS              value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR High RLC Report                                value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Inter Frequency PSCell Change                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Low RLC Report                                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Enforced LTE measurement gap reports per Cell     value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR LTE Mobility                            value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR MAC PDU throughput                             value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR MAC SDU Report                                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Measurement Gaps                               value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Mobility CU                                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Mobility DU                                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR adjacent E-UTRAN Cell                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR NGAP Interface Report per CELL     value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Mobility Profiles                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR PDU Session DL Forwarding                      value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=Central unit (CU) traffic measurement             value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR NGC Interface per BTS                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR NG-U Interface Report                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR PDCP Report 1                                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR PDCP Report 2                                 value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR Paging                                         value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR PDCCH usage                                          value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR PDCP-C Report                                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Intra Frequency PSCell Change                 value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR RAN Sharing                                    value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR Resource Utilization per CELL                  value=${PMINTERVAL}
    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
    ...      abbr=NR RRC Interface Report per DU                    value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for Standalone (SA) Central unit (CU) Radio admission control measurement
#    ...      value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for Standalone (SA) Distributed unit (DU) Radio admission control
#    ...      value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for Standalone (SA) gNB traffic measurement            value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR RAN Sharing UP                                  value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for Central unit (CU) Radio admission control measurement
#    ...      value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for Distributed unit (DU) Radio admission control measurement
#    ...      value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR RACH Usage                                       value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR Radio Bearer                                     value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR RLF Report per CELL                              value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR S1-U Interface                                   value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for SFP BBMOD                                           value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for SFP RMOD                                            value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for SFP SMOD                                            value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR Slice per CU-CP                                  value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR PDCP Slice per CU-UP.                            value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR NSA Signaling Radio Bearer in the gNB-CU         value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR NSA Signaling Radio Bearer in gNB-DU             value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR service availability statistics                  value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR Timing Advance                                   value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR NSA UE State New RadioCELL level                 value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR UL HARQ                                          value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR UL Signal Quality Level                          value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR X2-C Interface signaling New RadioBTS level      value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR X2-C Interface signaling New RadioCELL level     value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR X2-U Interface Report                            value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR XN-C Interface signaling New RadioCELL level     value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR XN Interface                                     value=${PMINTERVAL}
#    COAM_WebEM.SetParameterValue    distName=${distname}/NRPMRNL-1
#    ...      abbr=Measurement interval for NR XN-U Interface Report BTS                        value=${PMINTERVAL}
    selenium_coam.validate_plan
#    ${error}    selenium_coam.get_relation_errors
#    Should Be Empty     ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    COAM_WebEM.Logout

####################################### 5GC002479-CA  FM #######################################
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

#######################################  5GC002479-FA   WebEM  #######################################

#Fill and Click login box
#    Input Text    locator=${LOGIN_BOX}    text=Nemuadmin
#    Input Text    locator=${PASS_BOX}    text=nemuuser
#    Click Button    locator=${LOGIN_BUTTON}

5GC002479_FA.logout
    #5GC002479_A.Logout  ${driver}  ${pagePart}
    #disableDisplay  ${display}
     KW.CleanFirefox
####################################### CB006939-HA  Reset  #######################################
KW.Reset.WEbUIResetWithRetry
    [Arguments]      ${case_name}     ${KPI51a_MAX}     ${KPI51a_AVG}     ${retry_times}    ${ru_reset_index}=1
    KW.CaseStatusInit    retry_times=${retry_times}
    FOR    ${i}    IN RANGE    ${retry_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error    KW.Reset.LoopForWebUIReset    loop=${i+1}    ru_reset_index=${ru_reset_index}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI51a_MAX}
        log to console     Case loop ${i+1} END
        Get common info     case_result=${reset_status}    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        should be true    ${duration_time_tmp}<${KPI51a_MAX}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        AppendCaseResultToFile    index=${i}    ru_index=${ru_reset_index}
        ...    target_value=${KPI51a_AVG}    result_value=${duration_time_tmp}
#        Run Keyword And Ignore error    WEBUI.Collect snapshot
    END
    #${avg}   Evaluate    ${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_AVG']}+${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_AVG_ADJ']}
    KW.CaseStatusFinnal    case_avg=${KPI51a_AVG}    max_loop=${retry_times}

KW.Reset.LoopForWebUIReset
    [Arguments]    ${loop}    ${ru_reset_index}
    #[Timeout]      ${CASE_INPUT_5GC002479['5GC002479']['LoopTimeout']} minutes
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login
    ${timestartTmp}   Get Current Date
    WEBUI.ResetRU    ru_index=${ru_reset_index}
    sleep    5s
    COAM_WebEM.Logout
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800   pass      fail
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}

KW.Reset.LoopForRUPowerReset
    [Arguments]    ${loop}     ${ru_index}
    KW.Reset.RUPowerOff    ru_index=${ru_index}
    KW.TimerStart
    KW.Reset.RUPowerOn     ru_index=${ru_index}
    wait until keyword succeeds     Check all cells Should Be On Air
    ${duration}    Timer.Stop
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}

KW.CB006939_HA_04_OAM_KPI_54a_RU_Cold_Reset_Time
    [Arguments]   ${retry_times}    ${KPI54A_MAX}     ${KPI54A_AVG}     ${ru_index}=1
    KW.CaseStatusInit    retry_times=${retry_times}
    FOR    ${i}    IN RANGE    ${retry_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        KW.Reset.RUPowerOff    ru_index=${ru_index}
        sleep    15s
        ${startTime}    KW.TimerStart
        KW.Reset.RUPowerOn     ru_index=${ru_index}
        wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair
        ${duration_time_tmp}    KW.TimerStop    timestart=${startTime}
#        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
#        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        KW.CaseStatusCaluateWithoutPassRate    duration=${duration_time_tmp}    max=${KPI54A_MAX}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        should be true    ${duration_time_tmp}<${KPI54A_MAX}
#        Run Keyword And Ignore error    WEBUI.Collect snapshot
        AppendCaseResultToFile    index=${i}    ru_index=${ru_index}
        ...    target_value=${KPI54A_AVG}    result_value=${duration_time_tmp}
    END
    KW.CaseStatusFinnal    case_avg=${KPI54A_AVG}    max_loop=${retry_times}

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

KW.GetRMODNameByID
    [Arguments]    ${RMOD_ID}
    ${BTSInfo}     COAM_Admin.GetBTSInfo
#    @{RMODsName}=  Create List
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        ${tmp}=    Split String From Right    ${RU['id']['configuration']}     /
        ${RU_ID}=    Set Variable    ${tmp[-1]}
        Continue For Loop If    '${RMOD_ID}'!='${RU_ID}'
        ${RMODName}=    Set Variable If    '${RMOD_ID}'=='${RU_ID}'    ${RU['productName']}
#        Append To List    ${RMODsName}    ${RMODName}
    END
    [Return]   ${RMODName}

KW.GetRMODsNameByBBMODID
    [Arguments]    ${BBMOD_ID}
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    @{RMODs_ID}=  Create List
    @{RMODs_Name}=  Create List
    FOR    ${CABLE}   IN    @{BTSInfo['cables']}
        ${cable_BBMOD}=    Split String From Right    ${CABLE['firstEndPointId']['configuration']}     /
        ${firstEndPointId_BBMOD}   Set Variable     ${cable_BBMOD[-2]}
        ${cable_RMOD}   Split String From Right    ${CABLE['secondEndPointId']['configuration']}     /
        ${secondEndPointId_RMOD}   Set Variable     ${cable_RMOD[-2]}
        Continue For Loop If     '${firstEndPointId_BBMOD}'!='${BBMOD_ID}'
        ${RMOD_ID}=    Set Variable If    '${firstEndPointId_BBMOD}'=='${BBMOD_ID}'      ${secondEndPointId_RMOD}
        Append To List    ${RMODs_ID}    ${RMOD_ID}
    END
    ${RMODs_length}    Get length      ${RMODs_ID}
    FOR    ${i}    IN RANGE    0     ${RMODs_length}
         ${RMOD_Name}    KW.GetRMODNameByID     RMOD_ID=${RMODs_ID[${i}]}
         Append To List    ${RMODs_Name}    ${RMOD_Name}
    END
    [Return]   ${RMODs_Name}

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
#    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
#    Sleep    2s
    COAM_WebEM.Logout
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step2: Check blockcell_duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "BLOCK_IND-1 trying to commit"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${blockcell_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${blockcell_startTime}
    ${blockcell_startTime}     convert date
    ...    ${blockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${blockcell_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${blockcell_endTime}
    ${blockcell_endTime}        convert date
    ...     ${blockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${blockcell_duration}    Evaluate    ${blockcell_endTime}-${blockcell_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${blockcell_duration}<=${CellBlockDurtion} and ${blockcell_duration}>${0}
    log to console   blockcell duration is ${blockcell_duration}
    log to console    Step3: Trigger cell unblock and start BTSLog
    BtsLog.StartBTSlogCollection
#    ${CheckString_UnBlock}    set variable     "Write auditlog for UNBLOCK_IND|has been changed from Offline to Online"
#    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
#    run    command=tail -f /tmp/btslog2/SYSLOG_*.LOG | grep -E ${CheckString_UnBlock} > /tmp/BTSLOG_unblockcell.txt&
    COAM_WebEM.Login
    selenium_sbts.unblock_cell     cell_idx=${cell_idx}
    Sleep    20s
#    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
#    Sleep    2s
    COAM_WebEM.Logout
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step4: Check unblockcell_duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Write auditlog for UNBLOCK_IND"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${unblockcell_startTime}     run    command=${cmd}
    Should Not Be Empty     ${unblockcell_startTime}
    ${unblockcell_startTime}     convert date
    ...     ${unblockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${unblockcell_endTime}     run    command=${cmd}
    Should Not Be Empty     ${unblockcell_endTime}
    ${unblockcell_endTime}        convert date
    ...      ${unblockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${unblockcell_duration}    Evaluate    ${unblockcell_endTime}-${unblockcell_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${unblockcell_duration}<=${CellUnblockDurtion} and ${unblockcell_duration}>${0}
    log to console   unblockcell duration is ${unblockcell_duration}
    AppendCaseResultToFile    index=NRCELL_${cell_idx}_block
    ...    target_value=${CellBlockDurtion}    result_value=${blockcell_duration}
    AppendCaseResultToFile    index=NRCELL_${cell_idx}_unblock
    ...    target_value=${CellUnblockDurtion}    result_value=${unblockcell_duration}

HA_KPI17_Teardown case
    [Timeout]    600s
#    [Arguments]      ${cell_idx}=${CASE_INPUT_5GC002479['CB006939_HA_KPI17']['CELL'][0]['index']}
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    KW.Reset.UnblockAllCells
    ...    ELSE    run keyword if    '${TEST STATUS}' == 'PASS'    log to console    Case is PASS
    Teardown Case

KW.Reset.UnblockAllCells
    ${BTSInfo}=     COAM_Admin.GetBTSInfo
    COAM_WebEM.Login
    FOR    ${CELL}   IN    @{BTSInfo['cells']['nr']}
        @{RMODsName}=  Create List
        ${cell_config}=    Split String From Right    ${CELL['id']['configuration']}     /
        ${nrcell}   Set Variable     ${cell_config[-1]}
        ${tmp_cell}=    Split String From Right    ${nrcell}     -
        ${CELL_INDEX}   Set Variable     ${tmp_cell[-1]}
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${CELL_INDEX}
        run keyword if    '${cell_info['Status']['Blocking state']}'=="Blocked"
        ...    selenium_sbts.unblock_cell    cell_idx=${CELL_INDEX}
        sleep   10s
    END
    COAM_WebEM.Logout

KW.5GC002479_HA_07_OAM_KPI_16_Cell_Lock_Unclock
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
#######################################  5GC002479-IA   SWM  #######################################
KW.SWM.PrepareOriginalENVbyYAFT
    [Arguments]    ${build_version}
    ${Smods}    COAM_Admin.GetBTSTopology
    ${length}=   Get Length   ${Smods}
    run keyword if    ${build_version.count('${TargetStream}')}>0    Set Suite Variable    ${gSCF}    ${OldCommissionSCF}
    ...    ELSE       Set Suite Variable    ${gSCF}    ${OriginalStreamSCF}
    run keyword if  '${length}'=='1'      KW.SWM.PrepareOriginalBuildEnv    build_version=${build_version}    scf=${gSCF}
    ...    ELSE    KW.SWM.PrepareENVDualCore    build_version=${build_version}

KW.SWM.PrepareENVDualCore
    [Arguments]    ${build_version}
    ${SecondaryUTEVMIP}       set variable    ${CASE_INPUT_5GC002479['5GC002479_IA']['SecondaryUTEVMIP']}
	log to console    !!!!!!!!!!!!ConfigurationReset!!!!!!!!!!!!!!!!
	KW.SWM.ConfigurationClear
	COAM_Admin.Login
	coam.reset_configuration    connection=COAM
	run keyword and ignore error    COAM_Admin.Logout
	Run Keyword And Ignore Error    GNB.kill admin process
	sleep    60s
    ssh.Connect to    hostname=${SecondaryUTEVMIP}    username=ute     password=iW_K#8.ute%A10h0m0ra     alias=SecondaryUTEVMIP
    ${cmd}=  Catenate     SEPARATOR=${SPACE}
    ...                   source ~/CIENV/${CASE_INPUT_5GC002479['5GC002479_IA']['SecondaryTLName']}/bin/activate &&
    ...                   robot -t TC.PrepareENVOnSecondary -L TRACE -b debug.log -d /home/ute/TAF/debug_log/123456/
    ...                  -l "$(date +"%Y%m%d%H%M")".html -v ip:${PrimaryDefaultIP} -v version:${build_version}
    ...                  /home/ute/TAF/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG1/common_case.robot
    ...                  && deactivate
    ${out}    Conn.Execute    cmd=${cmd}    alias=SecondaryUTEVMIP
    should contain    ${out}    1 test total, 1 passed, 0 failed
    should contain    ${out}    PrepareENVOnSecondary Success
    run    command=rm -rf ${UPDATE_FILE_PATH}/*
    Conn.Disconnect     alias=SecondaryUTEVMIP
    run keyword if    ${build_version.count('${TargetStream}')}>0    Set Suite Variable    ${gSCF}    ${OldCommissionSCF}
    ...    ELSE       Set Suite Variable    ${gSCF}    ${OriginalStreamSCF}
    KW.SWM.PrepareOriginalBuildEnv    build_version=${build_version}    scf=${gSCF}

KW.SWM.COAM_WebEM.LoginWithSync
     [Arguments]      ${button}    ${url}    ${virtual_enable}=${TRUE}
     ${action}   Create Dictionary  modal_name=Additional hardware detected   button=${button}    timeout=${60}
     ${action_list}   Create List  ${action}
     run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
     run keyword and ignore error    selenium_coam.logout
     selenium_coam.login    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
     ...    modal_action_configurations=${action_list}
     selenium_coam.disable_message_box
     selenium_coam.disable_screen_lock
     sleep    15s
     ${res}    selenium_coam.start_up_view_window_exists
     run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

KW.SWM.ConfigurationClear
    [Arguments]    ${dualcore}=true
    Conn.Connect    alias=${ALIAS_ASIK}
    ${isPrimaryCoreInLeftSubrack}    set variable    ${True}
    ${isPrimaryCoreInLeftSubrack}    Run Keyword If    '${dualcore}'=='true'        gNB.IsPrimaryCoreInLeftSubrack
    run keyword if    '${dualcore}'=='false'
    ...    KW.SWM.ConfigurationClearCommand    alias=${ALIAS_ASIK}
    ...    ELSE IF    '${isPrimaryCoreInLeftSubrack}'=='${True}'    run keywords
    ...    KW.SWM.ConfigurationClearCommand    alias=${ALIAS_ASIK}
    ...    AND    ssh.Connect to    fct4s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...    alias=asik_secondary  proxy=${ALIAS_ASIK}
    ...    AND    KW.SWM.ConfigurationClearCommand    alias=asik_secondary
    ...    AND    Conn.Disconnect    alias=asik_secondary
    ...    ELSE IF    '${isPrimaryCoreInLeftSubrack}'=='${False}'    run keywords
    ...    KW.SWM.ConfigurationClearCommand    alias=${ALIAS_ASIK}
    ...    AND    ssh.Connect to    fct0s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...    alias=asik_secondary  proxy=${ALIAS_ASIK}
    ...    AND    KW.SWM.ConfigurationClearCommand    alias=asik_secondary
    ...    AND    Conn.Disconnect    alias=asik_secondary
    Conn.Disconnect    alias=${ALIAS_ASIK}

KW.SWM.ConfigurationClearCommand
    [Arguments]    ${alias}
    Conn.Execute  cmd=mount -o rw,remount /ffs/fs2    alias=${alias}
    Conn.Execute  cmd=mount -o rw,remount /ffs/fs1    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs1/config/NCF.xml    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs2/config/NCF.xml    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs1/config/tmp_NCF.xml    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs2/config/tmp_NCF.xml    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs1/config/oamPnpReport.log    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs2/config/oamPnpReport.log    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs1/config/trsAutoconnReport.log    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs2/config/trsAutoconnReport.log    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs1/config/ne3sadapt/configs/ne3sadaptdata.db    alias=${alias}
    Conn.Execute  cmd=rm -rf /ffs/fs1/config/ne3sadapt/managers    alias=${alias}
    Conn.Execute  cmd=rm -rf /ffs/fs1/config/ne3sadapt    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs2/config/ne3sadapt/configs/ne3sadaptdata.db    alias=${alias}
    Conn.Execute  cmd=rm -rf /ffs/fs2/config/ne3sadapt/managers    alias=${alias}
    Conn.Execute  cmd=rm -rf /ffs/fs2/config/ne3sadapt    alias=${alias}
    Conn.Execute  cmd=rm -rf /ram/tmp/certificates/*    alias=${alias}
    Conn.Execute  cmd=rm -rf /ffs/fs1/trs_data/active/keystorage/certs/*    alias=${alias}
    Conn.Execute  cmd=rm -rf /ffs/fs2/trs_data/active/keystorage/certs/*    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs1/config/envdata -rf    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs2/config/envdata -rf    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs1/config/*.*    alias=${alias}
    Conn.Execute  cmd=rm /ffs/fs2/config/*.*    alias=${alias}
    Conn.Execute  cmd=rm /ffs/stb/config/* -rf    alias=${alias}

KW.SWM.PrepareOriginalBuildEnv
    [Arguments]    ${build_version}    ${scf}=None
    ${upgrade_package_path}     SoftwareUpdate.Download_gNB_Package    ${build_version}
    KW.SWM.CP.PrepareEnvByYAFT    filename=${upgrade_package_path}    scf=${scf}

KW.SWM.EnableSSH
    wait until keyword succeeds    15min    30s   COAM_Admin.Login
	log to console    SSH enable
	coam.enable_ssh_access    connection=COAM
	COAM_Admin.Logout

KW.SWM.CP.PrepareEnvByYAFT
    [Arguments]    ${filename}    ${scf}=None
    log to console    YAFT Started
    KW.SWM.EnableSSH
    wait until keyword succeeds    3x    60s    SoftwareUpdate.YAFT    filepath=${filename}
    log to console    Second YAFT
    wait until keyword succeeds   2x   5min    KW.SWM.EnableSSH
    wait until keyword succeeds    3x    60s    SoftwareUpdate.YAFT    filepath=${filename}
    log to console    Second YAFT END and wait onair
    wait until keyword succeeds   2x   5min    KW.SWM.EnableSSH
#    run keyword and ignore error    gNB.CheckHWStatusUntilReadyWithPowerReset
    run keyword and ignore error   Power.ResetgNB     model=${model}
    wait until keyword succeeds   10x   1min    KW.SWM.COAM_WebEM.LoginWithSync    button=Start sync  url=${ASIK_LMP_IP_URL}
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    ${gnb_status}   KW.SWM.GetGNBStatus
    run keyword and ignore error    COAM_Admin.Logout
    Run Keyword If   '${gnb_status}'=='NotCommissioned'    wait until keyword succeeds    30min    60s
    ...    gNB.Commission   scf_file=${gSCF}
    FOR    ${i}    IN RANGE    ${20}
        ${res}    wait until keyword succeeds    30min    60s    KW.CheckRUAlarmOrOnair
        run keyword if     '${res}'=='YES'        KW.UpGradeForRU    filename=${filename}
        ...    ELSE    Exit For Loop
    END

KW.SWM.FilterGetGNBSWVersion
    [Arguments]   ${Target_build}=${TARGETSW}   ${max_num}=500   ${stream}=${TargetStream}
    ...           ${status}=[released ,released_with_restrictions]
    ...           ${conditions}=${condition_PS_same}
    ${Target_build}   Set Variable if    ${TARGETSW.count('SBTS')}>0    ${Target_build}
    ...   ${CASE_INPUT_5GC002479['StreamPrefix']}${Target_build}
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
    gNB.Connect
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
    ...    cd ${YAFT_PATH} &&python ./yaft.py -i ${ASIK_LMP_IP} -z ${filename} -K --ignore_FSPs
    ...    cd ${YAFT_PATH} &&python ./yaft.py -i ${ASIK_LMP_IP} -z ${filename} -K
    log  ${yaft_command}
    run  sudo rm -rf ${YAFT_PATH}/YAFT_IMAGE
    ${result}  run  ${yaft_command}
    Should Contain Any   ${result}   Flashing done    Cannot establish SSH session with FCT    Waiting for FC* after reboot

KW.SWM.UpGradeForRU
    [Arguments]    ${filename}
#    FOR    ${i}    IN RANGE    ${5}
#        COAM_WebEM.Login    url=${ASIK_LMP_IP_URL}
#        ${finish}    Download and update package of site
#        ...    if_active=${True}     upgrade_package_path=${filename}    checkReset=false
#        run keyword and ignore error  COAM_WebEM.Logout
#        exit for loop if    '${finish}'=='true'
#        Sleep    60
#    END
    COAM_WebEM.Login    url=${ASIK_LMP_IP_URL}
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${filename}
    log to console    ${load_result}
    log to console   start to upgrade RU
    selenium_coam.software_update     is_activate=${True}
    ${finish}    wait until keyword succeeds    30min    10s    check SW download progress finished

KW.SWM.Init
#    ${version_Target}          get regexp matches    ${AF_PATH}     [0-9]+.[0-9]+.[0-9]+
#    set suite variable    ${TARGETSW}    ${version_Target[0]}
#    ${StreamTarget}         Get Regexp Matches     ${TARGETSW}     [0-9]+.[0-9]+
    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion
    set suite variable    ${TARGETSW}    ${version_Target}
    set suite variable    ${TargetStream}     ${StreamTarget}
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStream']
#    ...                         default_value=5G21A_11.800
#    ${OriginalStream}             Fetch From Right    ${CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStream']}     _
#    ${OriginalStreamPrefix}       Fetch From Left     ${CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStream']}
    set suite variable       ${OriginalStream}         ${CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStream']}
#    set suite variable       ${OriginalStream}         ${OriginalStream}
#    set suite variable       ${OriginalStreamPrefix}   ${OriginalStreamPrefix}
    set suite variable     ${SWM}     ${0}
    set suite variable     ${SWM_KPI2A}     ${0}
    set suite variable     ${SWM_KPI2B}     ${0}
    set suite variable     ${SWM_KPI2C}     ${0}
    set suite variable     ${SWM_KPI2D}     ${0}
    ${CurrentStreamSCF}   COAM_Admin.BackupSCF
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStreamSCF']
#    ...                         default_value=${SCF_File}
    Set Suite Variable    ${CurrentStreamSCF}     ${CurrentStreamSCF}
    Set Suite Variable    ${OriginalStreamSCF}    ${CFGFILE_PATH}/${CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStreamSCF']}
    Set Suite Variable    ${OldCommissionSCF}     ${CFGFILE_PATH}/OldCommissionSCF.xml

KW.SWM.CheckIfSWActiveRun
    [Arguments]      ${stream}=${TargetStream}   ${conditions}=&{condition_PS_same}
     Run keyword if    ${SWM}==${0}    TC.5GC002479_SWM_Software_Upgrade    stream=${stream}   conditions=${conditions}
     Run keyword if    ${SWM}<${3}     Fail    Step SW active not execute

KW.SWM.GetGNBStatus
    [Arguments]   ${connection}=COAM
    ${general_status}   admin.get_bts_statuses   connection=${connection}   timeout=60
    [Return]   ${general_status['proceduralState']}

KW.gNB.ConfigurationReset
    [Documentation]  Author: WangLixia
    ...              Description: perform configuration reset from WebEM
    log to console    gNB configuration reset
    selenium_sbts.configuration_reset
    sleep   20s

KW.gnb.CheckBTSStatus
    [Documentation]  Author: WangLixia
    ...              Description: Check BTS status should be equal to the input value
    [Arguments]    ${BTS_status}=Not commissioned
    ${status}=    selenium_coam.get_bts_status
    Should Be Equal    ${status}    ${BTS_status}

KW.gnb.LoginWithCoreMode
    [Documentation]  Author: WangLixia
    ...              Description: input is Dualcore or Singlecore
    [Arguments]    ${mode}=Singlecore
    Run keyword if     '${mode}'=='Dualcore'       KW.SWM.COAM_WebEM.LoginWithSync    button=Start sync  url=${ASIK_LMP_IP_URL}
    ...      ELSE IF   '${mode}'=='Singlecore'    COAM_WebEM.Login

#######################################CalculateKPI START#######################################
KW.CP_GetgNBType
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
    [Return]   ${gNBType}

KW.CP_GetCellNums
    ${BTSInfo}=     COAM_Admin.GetBTSInfo
    @{CELLs}=  Create List
    FOR    ${CELL}   IN    @{BTSInfo['cells']['nr']}
        ${tmp}=    Split String From Right    ${CELL['id']['configuration']}     /
        Append To List    ${CELLs}    ${tmp[-1]}
    END
    log to console    ${CELLs}
    ${CellNums}       Get length      ${CELLs}
    [Return]   ${CellNums}

KW.CP_GetRMODsList
    ${BTSInfo}=     COAM_Admin.GetBTSInfo
    @{RMODsList}=  Create List
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        ${RMOD}=  Set Variable    ${RU['productName']}
        Append To List    ${RMODsList}    ${RMOD}
    END
    log to console   ${RMODsList}
    [Return]   ${RMODsList}

KW.GetBaseKPIVaule
    [Arguments]      ${TLConfiguration}=${CASE_INPUT_5GC002479['TLConfiguration']}
    ${CFG}=   Set Variable    ${Configurations['${TLConfiguration}']}
    [Return]  ${CFG}

KW.GetRUKPI
    [Arguments]   ${RMODsList}
#    log to console    ${RMODs}
#    @{RMODsList}=  Create List
#    Append To List    ${RMODsList}   ${RMODs}
    ${length}       Get length     ${RMODsList}
    ${ConfiguredRUList}    Get Dictionary Keys    ${RUs}
    log to console   ${ConfiguredRUList}
    ${RUadjVlaue}=    Create Dictionary   AdjValues=0    AdjValueResetBBMOD=0    AdjValueCellBlockUnblock=0
    ${maxRUadjVlaue}    set variable     ${RUadjVlaue}
    FOR    ${i}    IN RANGE    0    ${length}
         ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${ConfiguredRUList}    ${RMODsList[${i}]}
         Continue For Loop If    "${status}"=="False"
         ${RUAdjValues}=   Set Variable if  "${status}"=="True"   ${RUs['${RMODsList[${i}]}']}
         ${maxRUadjVlaue}=    set variable if    ${RUAdjValues['AdjValues']}>=${maxRUadjVlaue['AdjValues']}    ${RUAdjValues}    ${maxRUadjVlaue}
    END
    [Return]    ${maxRUadjVlaue}

KW.GetCellNumKPI
    [Arguments]   ${CellNums}
    ${CellNumAdjVlaue}=    Create Dictionary   AdjValues=0
    ${adjVlaue}=   Run Keyword If   ${CellNums}>=${1} and ${CellNums}<=${3}     Evaluate   ${CellNumAdjVlaue['AdjValues']}+0
    ...     ELSE IF     ${CellNums}>=${4} and ${CellNums}<=${12}     Evaluate   ${CellNumAdjVlaue['AdjValues']}+60
    ...     ELSE IF    ${CellNums}>=${13} and ${CellNums}<=${21}    Evaluate   ${CellNumAdjVlaue['AdjValues']}+120
    ...     ELSE IF    ${CellNums}>=${22} and ${CellNums}<=${30}    Evaluate   ${CellNumAdjVlaue['AdjValues']}+180
    log to console   ${adjVlaue}
    Set To Dictionary    ${CellNumAdjVlaue}   AdjValues  ${adjVlaue}
    [Return]   ${CellNumAdjVlaue}

KW.GetgNBTypeKPI
    [Arguments]   ${gNBType}
    ${Type}    Get Dictionary Keys    ${gNBCuType}
    log to console   ${Type}
    ${gNBTypeAdjVlaue}=    Create Dictionary   AdjValues=0
    ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${Type}    ${gNBType}
    ${gNBTypeAdjVlaue}=    Set Variable if   "${status}"=="True"   ${gNBCuType['${gNBType}']}    ${gNBTypeAdjVlaue}
    [Return]   ${gNBTypeAdjVlaue}

KW.GetSFPKPI
    [Arguments]   ${SFPCooled}
    ${Value}    Get Dictionary Keys    ${SFPCooledTransceiver}
    log to console   ${Value}
    ${SFPAdjVlaue}=    Create Dictionary   AdjValues=0    AdjValueResetBBMOD=0
    ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${Value}    ${SFPCooled}
    ${SFPAdjVlaue}=    Set Variable if   "${status}"=="True"   ${SFPCooledTransceiver['${SFPCooled}']}    ${SFPAdjVlaue}
    [Return]   ${SFPAdjVlaue}

#KW.GetRUAdjByCellNums
#    [Arguments]   ${RMODs}    ${AdjRMOD}
#    Set Test Variable   ${CellsNum}    0
#    FOR  ${item}  IN   @{RMODs}
#        ${CellsNum}    run keyword if   '${item}'=='${AdjRMOD}'   Evaluate    ${CellsNum}+1
#        ...    ELSE    Set Variable    ${CellsNum}
#    END
#    ${ValueRUAdjByCellNums}    Evaluate   ${CellsNum}*30
#    [Return]    ${ValueRUAdjByCellNums}

KW.GetRUAdjByRMODCellNums
    [Arguments]   ${RMODs}    ${AdjRMOD}
    Set Test Variable   ${CellNumsInRMOD}    0
    FOR  ${item}  IN   @{RMODs}
        ${CellNumsInRMOD}    run keyword if   '${item}'=='${AdjRMOD}'   Evaluate    ${CellNumsInRMOD}+1
        ...    ELSE    Set Variable    ${CellNumsInRMOD}
    END
    ${ValueRUAdjByRMODCellNums}    Evaluate   ${CellNumsInRMOD}*30
    [Return]    ${ValueRUAdjByRMODCellNums}

KW.GetRUAdjByBBMODCellNums
    [Arguments]   ${RMODs}    ${AdjRMOD}
    Set Test Variable   ${CellNumsInBBMOD}    0
    FOR  ${item}  IN   @{RMODs}
        ${CellNumsInBBMOD}    run keyword if   '${item}'=='${AdjRMOD}'   Evaluate    ${CellNumsInBBMOD}+1
        ...    ELSE    Set Variable    ${CellNumsInBBMOD}
    END
    ${ValueRUAdjByBBMODCellNums}    Evaluate   ${CellNumsInBBMOD}*30
    [Return]    ${ValueRUAdjByBBMODCellNums}

KW.GetRUAdjBySiteCellNums
    [Arguments]   ${AdjRMOD}
    scf.Load_Scf  file_path=${BACKUP_SCF}
    ${BTSInfo}=     COAM_Admin.GetBTSInfo
    Set Test Variable   ${CellNumsInSite}    0
    FOR  ${item}  IN  @{BTSInfo['cells']['nr']}
        ${rmodlist}  scf.get_value_from_scf    dist_name=${item['id']['configuration']}    list_name=rModDNList
        ${config}=    Split String From Right    ${rmodlist}     /
        ${RMOD_ID}    Set Variable   ${config[-1]}
        ${RMODName}    KW.GetRMODNameByID     RMOD_ID=${RMOD_ID}
        ${CellNumsInSite}    run keyword if   '${RMODName}'=='${AdjRMOD}'   Evaluate    ${CellNumsInSite}+1
        ...    ELSE    Set Variable    ${CellNumsInSite}
    END
    ${ValueRUAdjBySiteCellNums}    Evaluate   ${CellNumsInSite}*30
    [Return]    ${ValueRUAdjBySiteCellNums}

KW.GetSFPCooledInfoOnRU
    [Arguments]   ${RU_INDEX}
    ${BTSInfo}=     COAM_Admin.GetBTSInfo
    FOR    ${CABLE}   IN    @{BTSInfo['cables']}
        ${cable_config}=    Split String From Right    ${CABLE['secondEndPointId']['configuration']}     /
        ${secondEndPoint}   Set Variable     ${cable_config[-1]}
        ${cable_ru}   Set Variable     ${cable_config[-2]}
        ${cable_internal}=    Split String From Right    ${CABLE['secondEndPointId']['internal']}     /
        ${cable_ru_internal}   Set Variable     ${cable_internal[-2]}
        ${tmp_ru}=    Split String From Right    ${cable_ru}     -
        ${CABLE_RU_INDEX}   Set Variable     ${tmp_ru[-1]}
        Continue For Loop If    '${CABLE_RU_INDEX}'!='${RU_INDEX}'
        ${hw_name}=    Set Variable    ${cable_ru} / ${cable_ru_internal}
        ${connector}=    Set Variable    ${secondEndPoint}
    END
    coam_webem.login
         ${SFPInfo}=    selenium_sbts.get_hw_info    hw_name=${hw_name}    connector=${connector}
         ${SFPCooledInfo}=    Set Variable    ${SFPInfo['Cooled Transceiver Declaration']}
    coam_webem.logout
    [Return]    ${SFPCooledInfo}

KW.GetSFPCooledInfoOnBBMOD
    [Arguments]   ${BBMOD_INDEX}
    ${BTSInfo}=     COAM_Admin.GetBTSInfo
    FOR    ${CABLE}   IN    @{BTSInfo['cables']}
        ${cable_firstEndPoint_config}=    Split String From Right    ${CABLE['firstEndPointId']['configuration']}     /
        ${firstEndPoint}   Set Variable     ${cable_firstEndPoint_config[-1]}
        ${cable_bbmod}   Set Variable     ${cable_firstEndPoint_config[-2]}
        ${cable_firstEndPoint_internal}=    Split String From Right    ${CABLE['firstEndPointId']['internal']}     /
        ${cable_bbmod_internal}   Set Variable     ${cable_firstEndPoint_internal[-2]}
        ${tmp_bbmod}=    Split String From Right    ${cable_bbmod}     -
        ${CABLE_BBMOD_INDEX}   Set Variable     ${tmp_bbmod[-1]}
        Continue For Loop If    '${CABLE_BBMOD_INDEX}'!='${BBMOD_INDEX}'
        ${firstEndPoint_hw_name}=    Set Variable    ${cable_bbmod} / ${cable_bbmod_internal}
        ${firstEndPoint_connector}=    Set Variable    ${firstEndPoint}
    END
    coam_webem.login
         ${SFPInfo}=    selenium_sbts.get_hw_info    hw_name=${firstEndPoint_hw_name}    connector=${firstEndPoint_connector}
         ${SFPCooledInfo}=    Set Variable    ${SFPInfo['Cooled Transceiver Declaration']}
    coam_webem.logout
    [Return]    ${SFPCooledInfo}

KW.GetSFPCooledInfoOnSite
    [Arguments]
    coam_webem.login
    ${BTSInfo}=     COAM_Admin.GetBTSInfo
    FOR    ${CABLE}   IN    @{BTSInfo['cables']}
        ${cable_secondEndPoint_config}=    Split String From Right    ${CABLE['secondEndPointId']['configuration']}     /
        ${secondEndPoint}   Set Variable     ${cable_secondEndPoint_config[-1]}
        ${cable_ru}   Set Variable     ${cable_secondEndPoint_config[-2]}
        ${cable_secondEndPoint_internal}=    Split String From Right    ${CABLE['secondEndPointId']['internal']}     /
        ${cable_ru_internal}   Set Variable     ${cable_secondEndPoint_internal[-2]}
        ${secondEndPoint_hw_name}=    Set Variable    ${cable_ru} / ${cable_ru_internal}
        ${secondEndPoint_connector}=    Set Variable    ${secondEndPoint}

        ${cable_firstEndPoint_config}=    Split String From Right    ${CABLE['firstEndPointId']['configuration']}     /
        ${firstEndPoint}   Set Variable     ${cable_firstEndPoint_config[-1]}
        ${cable_bbmod}   Set Variable     ${cable_firstEndPoint_config[-2]}
        ${cable_firstEndPoint_internal}=    Split String From Right    ${CABLE['firstEndPointId']['internal']}     /
        ${cable_bbmod_internal}   Set Variable     ${cable_firstEndPoint_internal[-2]}
        ${firstEndPoint_hw_name}=    Set Variable    ${cable_bbmod} / ${cable_bbmod_internal}
        ${firstEndPoint_connector}=    Set Variable    ${firstEndPoint}

        ${SFPInfo_firstEndPoint}=    selenium_sbts.get_hw_info    hw_name=${firstEndPoint_hw_name}    connector=${firstEndPoint_connector}
        ${SFPInfo_secondEndPoint}=    selenium_sbts.get_hw_info    hw_name=${secondEndPoint_hw_name}    connector=${secondEndPoint_connector}
        ${SFPCooledInfo_firstEndPoint}=    Set Variable    ${SFPInfo_firstEndPoint['Cooled Transceiver Declaration']}
        ${SFPCooledInfo_secondEndPoint}=    Set Variable    ${SFPInfo_secondEndPoint['Cooled Transceiver Declaration']}

        ${status}=   Evaluate   "${SFPCooledInfo_firstEndPoint}"=="true" or "${SFPCooledInfo_secondEndPoint}"=="true"
        ${SFPCooledInfo}=    Set Variable if    "${status}"=="True"     true    false
        Exit For Loop If    "${SFPCooledInfo}"=="true"
    END
    coam_webem.logout
    [Return]    ${SFPCooledInfo}

KW.GetAdjValue
    [Arguments]   ${RMODsList}   ${CellNums}   ${gNBType}   ${SFPCooled}    ${AdjRMOD}
        ${ValueBase}    KW.GetBaseKPIVaule   TLConfiguration=${CASE_INPUT_5GC002479['TLConfiguration']}
        ${ValueRUAdj}     KW.GetRUKPI    ${RMODsList}
        ${ValuegNBTypeAdj}    KW.GetgNBTypeKPI    gNBType=${gNBType}
        ${ValueSFPAdj}    KW.GetSFPKPI    SFPCooled=${SFPCooled}
        ${ValueCellNumAdj}    KW.GetCellNumKPI    CellNums=${CellNums}
        ${ValueRUAdjBySiteCellNums}      KW.GetRUAdjBySiteCellNums    AdjRMOD=${AdjRMOD}
        ${ValueRUAdjByBBMODCellNums}     KW.GetRUAdjByBBMODCellNums    RMODs=${RMODsList}    AdjRMOD=${AdjRMOD}
        ${ValueRUAdjByRMODCellNums}     KW.GetRUAdjByRMODCellNums    RMODs=${RMODsList}    AdjRMOD=${AdjRMOD}
#        ${ValueRUAdjByCellNums}     KW.GetRUAdjByCellNums    RMODs=${RMODsList}    AdjRMOD=${AdjRMOD}
        ${KPIAdjValue}    Copy Dictionary     dictionary=${ValueBase}   deepcopy=True
        ${Global_KPI1a_AVG_Formula}=    Run Keyword If    '${ValueBase['Customer']}'=='True'
        ...    Catenate    ${ValueBase['KPI1a']['KPI1a_AVG']}+${ValueRUAdj['AdjValues']}+${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}+
        ...    ${ValueRUAdjBySiteCellNums}
        ...    ELSE
        ...    Catenate    ${ValueBase['KPI1a']['KPI1a_AVG']}+${ValueRUAdj['AdjValues']}+${ValuegNBTypeAdj['AdjValues']}+
        ...    ${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}+${ValueRUAdjBySiteCellNums}
        ${Global_KPI1a_AVG}=   Evaluate    ${Global_KPI1a_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI1a']}    KPI1a_AVG    ${Global_KPI1a_AVG}
        ${Global_KPI1a_MAX}      Evaluate      int(${Global_KPI1a_AVG}*1.2)
        Set To Dictionary    ${KPIAdjValue['KPI1a']}   KPI1a_MAX    ${Global_KPI1a_MAX}
        ${Global_KPI3_AVG_Formula}=    Run Keyword If    '${ValueBase['Customer']}'=='True'
        ...    Catenate    ${ValueBase['KPI3']['KPI3_AVG']}+${ValueRUAdj['AdjValues']}+${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}+
        ...    ${ValueRUAdjBySiteCellNums}
        ...    ELSE
        ...    Catenate    ${ValueBase['KPI3']['KPI3_AVG']}+${ValueRUAdj['AdjValues']}+${ValuegNBTypeAdj['AdjValues']}+
        ...    ${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}+${ValueRUAdjBySiteCellNums}
        ${Global_KPI3_AVG}=    Evaluate   ${Global_KPI3_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI3']}   KPI3_AVG    ${Global_KPI3_AVG}
        ${Global_KPI3_MAX}        Evaluate      int(${Global_KPI3_AVG}*1.2)
        Set To Dictionary    ${KPIAdjValue['KPI3']}   KPI3_MAX    ${Global_KPI3_MAX}
        ${Global_KPI51a_AVG_Formula}=     Catenate    ${ValueBase['KPI51a']['KPI51a_AVG']}+${ValueRUAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}+
        ...    ${ValueRUAdjByRMODCellNums}
        ${Global_KPI51a_AVG}=    Evaluate    ${Global_KPI51a_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI51a']}   KPI51a_AVG    ${Global_KPI51a_AVG}
        ${Global_KPI51a_MAX}    Evaluate      int(${Global_KPI51a_AVG}*1.2)
        Set To Dictionary    ${KPIAdjValue['KPI51a']}   KPI51a_MAX    ${Global_KPI51a_MAX}
        ${Global_KPI54a_AVG_Formula}=     Catenate    ${ValueBase['KPI54a']['KPI54a_AVG']}+${ValueRUAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}+
        ...    ${ValueRUAdjByRMODCellNums}
        ${Global_KPI54a_AVG}=    Evaluate    ${Global_KPI54a_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI54a']}   KPI54a_AVG    ${Global_KPI54a_AVG}
        ${Global_KPI54a_MAX}    Evaluate      int(${Global_KPI54a_AVG}*1.2)
        Set To Dictionary    ${KPIAdjValue['KPI54a']}   KPI54a_MAX    ${Global_KPI54a_MAX}
        ${Global_KPI4_AVG_Formula}=     Run Keyword If    '${ValueBase['Customer']}'=='True'
        ...    Catenate    ${ValueBase['KPI4']['KPI4_AVG']}+${ValueRUAdj['AdjValues']}+${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ...    ELSE
        ...    Catenate    ${ValueBase['KPI4']['KPI4_AVG']}+${ValueRUAdj['AdjValues']}+${ValuegNBTypeAdj['AdjValues']}+
        ...    ${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI4_AVG}=    Evaluate    ${Global_KPI4_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI4']}   KPI4_AVG    ${Global_KPI4_AVG}
        ${Global_KPI4_MAX}        Evaluate      int(${Global_KPI4_AVG}*1.2)
        Set To Dictionary    ${KPIAdjValue['KPI4']}   KPI4_MAX    ${Global_KPI4_MAX}
        ${Global_KPI2a_AVG_Formula}=     Run Keyword If    '${ValueBase['Customer']}'=='True'
        ...    Catenate    ${ValueBase['KPI2a']['KPI2a_AVG']}+${ValueRUAdj['AdjValues']}+${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ...    ELSE
        ...    Catenate    ${ValueBase['KPI2a']['KPI2a_AVG']}+${ValueRUAdj['AdjValues']}+${ValuegNBTypeAdj['AdjValues']}+
        ...    ${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2a_AVG}=    Evaluate    ${Global_KPI2a_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2a']}   KPI2a_AVG    ${Global_KPI2a_AVG}
        ${Global_KPI2a_MAX}      Evaluate      int(${Global_KPI2a_AVG}*1.2)
        Set To Dictionary    ${KPIAdjValue['KPI2a']}   KPI2a_MAX    ${Global_KPI2a_MAX}
        ${Global_KPI2b_AVG_Formula}=     Run Keyword If    '${ValueBase['Customer']}'=='True'
        ...    Catenate    ${ValueBase['KPI2b']['KPI2b_AVG']}+${ValueRUAdj['AdjValues']}+${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ...    ELSE
        ...    Catenate    ${ValueBase['KPI2b']['KPI2b_AVG']}+${ValueRUAdj['AdjValues']}+${ValuegNBTypeAdj['AdjValues']}+
        ...    ${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2b_AVG}=    Evaluate    ${Global_KPI2b_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2b']}   KPI2b_AVG    ${Global_KPI2b_AVG}
        ${Global_KPI2b_MAX}      Evaluate      int(${Global_KPI2b_AVG}*1.2)
        Set To Dictionary    ${KPIAdjValue['KPI2b']}   KPI2b_MAX    ${Global_KPI2b_MAX}
        ${Global_KPI2c_AVG_Formula}=     Run Keyword If    '${ValueBase['Customer']}'=='True'
        ...    Catenate    ${ValueBase['KPI2c']['KPI2c_AVG']}+${ValueRUAdj['AdjValues']}+${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ...    ELSE
        ...    Catenate    ${ValueBase['KPI2c']['KPI2c_AVG']}+${ValueRUAdj['AdjValues']}+${ValuegNBTypeAdj['AdjValues']}+
        ...    ${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2c_AVG}=    Evaluate    ${Global_KPI2c_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2c']}   KPI2c_AVG    ${Global_KPI2c_AVG}
        ${Global_KPI2c_MAX}      Evaluate      int(${Global_KPI2c_AVG}*1.2)
        Set To Dictionary    ${KPIAdjValue['KPI2c']}   KPI2c_MAX    ${Global_KPI2c_MAX}
        ${Global_KPI2d_AVG_Formula}=     Run Keyword If    '${ValueBase['Customer']}'=='True'
        ...    Catenate    ${ValueBase['KPI2d']['KPI2d_AVG']}+${ValueRUAdj['AdjValues']}+${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ...    ELSE
        ...    Catenate    ${ValueBase['KPI2d']['KPI2d_AVG']}+${ValueRUAdj['AdjValues']}+${ValuegNBTypeAdj['AdjValues']}+
        ...    ${ValueCellNumAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2d_AVG}=    Evaluate    ${Global_KPI2d_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2d']}   KPI2d_AVG    ${Global_KPI2d_AVG}
        ${Global_KPI2d_MAX}      Evaluate      int(${Global_KPI2d_AVG}*1.2)
        Set To Dictionary    ${KPIAdjValue['KPI2d']}   KPI2d_MAX    ${Global_KPI2d_MAX}
        ${Global_KPI5_Formula}=   Catenate   ${ValueBase['KPI5']}+${ValueRUAdj['AdjValueResetBBMOD']}+${ValueSFPAdj['AdjValues']}+
        ...    ${ValueRUAdjByBBMODCellNums}
        ${Global_KPI5}=     Evaluate     ${Global_KPI5_Formula}
        Set To Dictionary    ${KPIAdjValue}   KPI5    ${Global_KPI5}
        ${Global_KPI17a}         Evaluate      ${ValueBase['KPI17a']}+${ValueRUAdj['AdjValueCellBlockUnblock']}
        Set To Dictionary    ${KPIAdjValue}   KPI17a    ${Global_KPI17a}
        ${Global_KPI17b}         Evaluate      ${ValueBase['KPI17b']}+${ValueRUAdj['AdjValueCellBlockUnblock']}
        Set To Dictionary    ${KPIAdjValue}   KPI17b    ${Global_KPI17b}
        ${Global_SW_Download_MAX}         Evaluate      ${ValueBase['SW_Download_MAX']}+0
        Set To Dictionary    ${KPIAdjValue}   SW_Download_MAX    ${Global_SW_Download_MAX}
   [Return]    ${KPIAdjValue}
#######################################CalculateKPI END#######################################

#######################################     #######################################

KW.TestSuilt.Start
    TestSuilt.Start
#    Import Variables     ${CFGFILE_PATH}/TLConfiguration.py
    run keyword and Ignore error    KW.SWM.Init
    set suite variable    ${OAM_TYPE}    COAM
    set suite variable    ${TLDelta_PATH_ON_GIT}        ${CFGFILE_PATH}
    gNB.FormatBTSID       MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    set suite variable    ${AdjRMOD}   None
    ${res}    Run Keyword And Ignore error    gNB.Generate TL SCF
	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${TLDelta_PATH_ON_GIT}
	...                  TestLineSCF_cell_num=${2}    cell_type=Both
	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    run keyword if    '${res[0]}'=='PASS'    gNB.Commission   scf_file=${LOG_PATH}/TestLineSCF2Cell_Both.xml
#    wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady
#    run keyword if    '${OAM_TYPE}'!='None'    wait until keyword succeeds    2min    60s   gNB.FormatBTSID
#    run keyword if    '${res[0]}'=='PASS'    gNB.Commission   scf_file=${LOG_PATH}/TestLineSCF2Cell_Both.xml
    ${onair_check}    run keyword and return status     COAM_WebEM.VerifyAllCellsAreOnlineFor2479
    Run keyword if    '${onair_check}'=='False'     Do site reset to recovery gnb
    ...    ELSE IF    '${onair_check}'=='True'      log     gnb is onair
    TestCase.Set_Case_Variable
    KW.NetAct.Init
    KW.WebEM.EnableActcli
    Run Keyword And Ignore error     Import Variables         /home/ute/TAF/cfgfile/2479_Loop_times.py
    ${BACKUP_SCF}   COAM_Admin.BackupSCF
    set suite variable    ${BACKUP_SCF}

    ${version}    Basic.GetStreamAndVersion
    log    ${version}
    @{suite_name}    Split String    ${SUITE SOURCE}    /
    @{suite_name}    Split String    ${suite_name[-1]}    .

    set suite variable    ${case_result_save_path}    ${CASE_RESULT_FLIE_PATH}${testline_name}_${suite_name[0]}_${version[1]}.csv
    Create File    ${case_result_save_path}

    ${file_head}    Catenate    SEPARATOR=,    case name    requirement id    index    Ru type    Ru index
    ...    target value    result value    case result\n
    Append To File    ${case_result_save_path}    ${file_head}



KW.TestSuilt.Stop
    TestSuilt.Stop

TestCase.Start_2479
    TestCase.Start
    Run Keyword And Ignore error      COAM_WebEM.Login
    ${onair_check}    run keyword and return status     COAM_WebEM.VerifyAllCellsAreOnlineFor2479
    Run keyword if    '${onair_check}'=='False'     Do site reset to recovery gnb
    ...    ELSE IF    '${onair_check}'=='True'      log     gnb is onair
    Run Keyword And Ignore error      COAM_WebEM.Logout
    KW.CleanFirefox

TestCase.Set_Case_Variable
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA']['SecondaryUTEVMIP']
#    ...                         default_value=1.1.1.1
    ${version_Target}    Basic.GetStreamAndVersion
    set suite variable    ${TargetBTSVersion}    ${version_Target}
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA']['SecondaryTLName']
    ...                         default_value=7_5_CLOUD402T011
    Basic.CheckVariableValid    var=AA_01['Duration_SCFLoad']
    ...                         default_value=20    is_digit=True
    Basic.CheckVariableValid    var=AA_01['Duration_ValidationError']
    ...                         default_value=270    is_digit=True
    Basic.CheckVariableValid    var=AA_01['Duration_Validation']
    ...                         default_value=140    is_digit=True
    Basic.CheckVariableValid    var=AA_01['Duration_Activation']
    ...                         default_value=600    is_digit=True
    Basic.CheckVariableValid    var=AA_02['Duration_DeltaValidation']
    ...                         default_value=60    is_digit=True
    Basic.CheckVariableValid    var=AA_03['SCF_backup_duration']
    ...                         default_value=30    is_digit=True
    Basic.CheckVariableValid    var=AA_04['Duration_DeltaActivation']
    ...                         default_value=600     is_digit=True
    Basic.CheckVariableValid    var=AA_05['Delta_Plan_Provision_Durtion']
    ...                         default_value=110     is_digit=True
    Basic.CheckVariableValid    var=AA_06['Full_Plan_Provision_Durtion']
    ...                         default_value=660     is_digit=True
    Basic.CheckVariableValid    var=AA_07['Delta_Plan_PreProvision_Durtion']
    ...                         default_value=60     is_digit=True
    Basic.CheckVariableValid    var=AA_08['Import_Delta_Plan_Durtion']
    ...                         default_value=20     is_digit=True
    Basic.CheckVariableValid    var=AA_09['Delta_Plan_Provision_Durtion_Reboot']
    ...                         default_value=660     is_digit=True
    Basic.CheckVariableValid    var=AA_10['CMUplod_Durtion']
    ...                         default_value=30     is_digit=True
    Basic.CheckVariableValid    var=AA_11['Duration_ChangeNoti']
    ...                         default_value=17     is_digit=True
    Basic.CheckVariableValid    var=BA_01['PM_File_Creation_Time']
    ...                         default_value=60    is_digit=True
    Basic.CheckVariableValid    var=BA_02['Duration_PM_Kept']
    ...                         default_value=180    is_digit=True
    Basic.CheckVariableValid    var=BA_03['PM_MAX_Size']
    ...                         default_value=272.7    is_digit=True
    Basic.CheckVariableValid    var=BA_04['CPU_Jitter']
    ...                         default_value=4    is_digit=True
    Basic.CheckVariableValid    var=CA_01['alarm_report_time']
    ...                         default_value=60    is_digit=True
    Basic.CheckVariableValid    var=CA_02['Alarm_Upload_Durtion']
    ...                         default_value=120    is_digit=True
    Basic.CheckVariableValid    var=DA_01['snapshot_save_time']
    ...                         default_value=900    is_digit=True
    Basic.CheckVariableValid    var=DA_02['FilePresentTime'
    ...                         default_value=15    is_digit=True
    Basic.CheckVariableValid    var=DA_03['StartAndStopLtency']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=FA_01['MaxFileSize']
    ...                         default_value=2147483648    is_digit=True
    Basic.CheckVariableValid    var=FA_02['MaxSession']
    ...                         default_value=10    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_FA_03']['Duration_Loading_WebEM']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=FA_03['Duration_Loading_WebEM']
    ...                         default_value=25    is_digit=True
    Basic.CheckVariableValid    var=FA_04['Login_duration_time']
    ...                         default_value=30    is_digit=True
    Basic.CheckVariableValid    var=FA_05['StartupView_Login_duration_time']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=FA_06['RMToolSessionCount']
    ...                         default_value=30    is_digit=True
    Basic.CheckVariableValid    var=FA_07['RMToolRequestLatency']
    ...                         default_value=30    is_digit=True
    Basic.CheckVariableValid    var=FA_08['RMToolConnectionLatency']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=FA_09['RMToolRequestLatencyServerMode']
    ...                         default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_KPI54A']['RMOD'][0]['KPI54A_AVG']
    ...                         default_value=480    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_KPI54A']['RMOD'][0]['KPI54A_MAX']
    ...                         default_value=576    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_HA_KPI54a']['RU_Reset_Times']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['Power_reset_times']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_HA_KPI51a']['RF_Reset_Times']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_HA_KPI51a']['RMOD'][0]['index']
    ...                         default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_HA_KPI51a']['RMOD'][0]['KPI51a_AVG']
    ...                         default_value=480    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_HA_KPI51a']['RMOD'][0]['KPI51a_MAX']
    ...                         default_value=576    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_HA_KPI17']['CELL'][0]['index']
    ...                         default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_HA_KPI17']['CELL'][0]['KPI17a']
    ...                         default_value=20    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['CB006939_HA_KPI17']['CELL'][0]['KPI17b']
    ...                         default_value=20    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002536_HA_KPI5']['BBMOD'][0]['index']
    ...                         default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002536_HA_KPI5']['BBMOD'][0]['KPI5']
    ...                         default_value=510    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_01']['SW_Download_MAX']
    ...                         default_value=900    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI4']['KPI4_AVG']
    ...                         default_value=1320    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI4']['KPI4_MAX']
    ...                         default_value=1584    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI4a']['KPI4a_AVG']
    ...                         default_value=1560    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI4a']['KPI4a_MAX']
    ...                         default_value=1872    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2a']['KPI2a_AVG']
    ...                         default_value=660    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2a']['KPI2a_MAX']
    ...                         default_value=792    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2b']['KPI2b_AVG']
    ...                         default_value=900    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2b']['KPI2b_MAX']
    ...                         default_value=1080    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2c']['KPI2c_AVG']
    ...                         default_value=480    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2c']['KPI2c_MAX']
    ...                         default_value=576    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_AVG']
    ...                         default_value=720    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_MAX']
    ...                         default_value=864    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB008181['CB008181_C_KPI10']['KPI10']
    ...                         default_value=120    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB008181['CB008181_C_KPI10']['DualCoreExtend']
    ...                         default_value=60    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB008181['CB008181_C_KPI10']['NSAExtend']
    ...                         default_value=240    is_digit=True
