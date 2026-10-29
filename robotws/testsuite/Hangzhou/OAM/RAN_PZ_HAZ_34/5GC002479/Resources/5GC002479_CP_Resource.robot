*** Settings ***
Documentation      author: Lixia Wang
...                 contact: lixia.wang@nokia-sbell.com
...                This robot file is for 5GC002479 C&P.

Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource          ../../None_Feature_SG1/OAM_Interface.robot
#Resource          5GC002479_Resouce.robot
Resource         ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_Resouce.robot
Library          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py
Library           ../../None_Feature_SG1/OAM_Interface.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.sbts.oam.coam.admin  WITH NAME   admin
Library           taf.collectors.btslog   WITH NAME   btslog
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
${PMINTERVAL}       15
${PMTIME}           15

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
${Operation_details_xpath}    //span[contains(@title,'Show task details')]
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
    Set Test Variable    ${GnbReset}    True
#    run   cp ${BACKUP_SCF} ${LOG_PATH}/ErrorSCF.xml
    run   cp ${CFGFILE_PATH}/ErrorSCF.xml ${LOG_PATH}/ErrorSCF.xml
#    Basic.SedReplaceLine    <p name=\\"firstEndpointDN\\">${MRBTS_ID}\\/EQM-1\\/APEQM-1\\/CABINET-1\\/SMOD-1<\\/p>
#    ...    \\<p name=\\"firstEndpointDN\\"\\>${MRBTS_ID}\\/EQM-1\\/APEQM-1\\/CABINET-1\\/SMOD-10\\<\\/p\\>
#    ...    ${LOG_PATH}/ErrorSCF.xml
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
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_VALIDATE_IND"| awk '{print $7}'|head -n 1|tail -1
#    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "markPlanActivation"|awk '{print $7}'|head -n 1|tail -1
    ${error_validation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${error_validation_startTime}
    ${error_validation_startTime}     convert date
    ...    ${error_validation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_VALIDATE_RESULT-1, result:Success"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${error_validation_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${error_validation_endTime}
    ${error_validation_endTime}        convert date
    ...     ${error_validation_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${error_validation_duration_tmp_AA01}    Evaluate    ${error_validation_endTime}-${error_validation_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${error_validation_duration_tmp_AA01}<=${Duration_ValidationError} and ${error_validation_duration_tmp_AA01}>${0}
    log to console    duration of full plan valdation with error is ${error_validation_duration_tmp_AA01}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][1]}
    ...    target_value=${Duration_ValidationError}    result_value=${error_validation_duration_tmp_AA01}
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
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_VALIDATE_IND"|awk '{print $7}'|head -n 1|tail -1
#    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "markPlanActivation"|awk '{print $7}'|head -n 1|tail -1
    ${succ_validation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${succ_validation_startTime}
    ${succ_validation_startTime}     convert date
    ...    ${succ_validation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_VALIDATE_RESULT-1, result:Success"|
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][2]}
    ...    target_value=${Duration_Validation}    result_value=${succ_validation_duration_tmp_AA01}
#    ${error}    selenium_coam.get_relation_errors
##    Should Be Empty     ${error}
    #first error load commission file
    log To Console    Step7: Check both the load scf duration should no more than defined by requirement
    ${timestart}    run    cat ${OUTPUT DIR}/debug.log |grep "load-action-button//input"|awk '{print $1,$2}'|head -n 1|tail -1
    ${timestart}      convert date    ${timestart}    epoch
    ${timeend}    run    cat ${OUTPUT DIR}/debug.log |grep "END KW: selenium_coam.Load Commissioning File"|awk '{print $1,$2}'|head -n 1|tail -1
    ${timeend}      convert date    ${timeend}    epoch
    ${duration1}    Evaluate    ${timeend}-${timestart}
    log to console    ${duration1}
    should be true     ${duration1}<${Duration_SCFLoad}
    #second success load commission file
    ${timestart}    run    cat ${OUTPUT DIR}/debug.log |grep "load-action-button//input"|awk '{print $1,$2}'|head -n 3|tail -1
    ${timestart}      convert date    ${timestart}    epoch
    ${timeend}    run    cat ${OUTPUT DIR}/debug.log |grep "END KW: selenium_coam.Load Commissioning File"|awk '{print $1,$2}'|head -n 2|tail -1
    ${timeend}      convert date    ${timeend}    epoch
    ${duration2}    Evaluate    ${timeend}-${timestart}
    log to console    ${duration2}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][0]}
    ...    target_value=${Duration_SCFLoad}    result_value=${duration2}
    should be true     ${duration2}<${Duration_SCFLoad}
    Log To Console    Step6: Active the scf without error and check the active duration should no more than requirement
    BtsLog.StartBTSlogCollection
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=${Duration_Activation}
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step7: Check activate duration from syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_ACTIVATE_IND"|
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][3]}
    ...    target_value=${Duration_Activation}    result_value=${full_activation_duration_tmp_AA01}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
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
    [Arguments]   ${Duration_Delta_Activation}=${AA_02['Duration_Delta_Activation']}
#    ...           ${InActSA_ErrValue}=80000
#    ...            ${Duration_DeltaValidation}=${AA_02['Duration_DeltaValidation']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
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
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_ACTIVATE_IND"| awk '{print $7}'|head -n 1|tail -1
#    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "markPlanActivation"|awk '{print $7}'|head -n 1|tail -1
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Duration_Delta_Activation}    result_value=${duration_time_tmp_AA02}
    run keyword and continue on failure    Should Be True
    ...    ${duration_time_tmp_AA02}<=${Duration_Delta_Activation} and ${duration_time_tmp_AA02}>${0}
    log to console   duration of delta plan activation without site reset is ${duration_time_tmp_AA02}
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
    Set Test Variable    ${GnbReset}    False
    COAM_WebEM.Login
    Log To Console    Step1: Backup SCF and check whether time meet requirement.
    ${timestartTmp}    KW.TimerStart
	${bkp_scf_file}    selenium_coam.Save Bts Configuration
    set suite variable    ${bkp_scf_file}
    ${duration_time_tmp}     KW.TimerStop    timestart=${timestartTmp}
    LOG    ${duration_time_tmp}
    COAM_WebEM.Logout
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${SCF_backup_duration}    result_value=${duration_time_tmp}
    Should Be True     ${duration_time_tmp}<=${SCF_backup_duration}      Configuration File Backup time is more than 30s
    set test variable    ${execution_result}    pass

TC.5GC002479_AA_04_CM_Delta_Plan_Validation_Activation_Operations_Site_Level_Service_Outage
    [Documentation]
    ...   Purpose:test case is to check configuration file_delta plan(Site level service outage need)
    ...            can be validation/activation can be successful and duration meet requirement.
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Modify parameter which will cause site reset has error when do validation.
    ...            eg:modify 'actNcYgMPlane' to a different value.
    ...     Step2: Validate and check error not exist on WebEM.
    ...     Step3: Do activation,caculate activation duration(duration is captured from system) and check validation
    ...            duration no more than requirement.
    [Arguments]   ${Duration_DeltaActivation}=${AA_04['Duration_DeltaActivation']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    True
    COAM_WebEM.Login
    BtsLog.StartBTSlogCollection
    Log To Console    Step1:Modify parameter which will cause site reset has error when do validation.
    ${actEcpriMplaneIPV6_Value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate eCPRI Transport with M plane over IPv6   abbr=actEcpriMplaneIPV6
    run keyword if    "${actEcpriMplaneIPV6_Value}"=="false"
    ...   selenium_coam.set_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate eCPRI Transport with M plane over IPv6
    ...   new_value=true   abbr=actEcpriMplaneIPV6
    ...   ELSE
    ...   selenium_coam.set_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate eCPRI Transport with M plane over IPv6
    ...   new_value=false   abbr=actEcpriMplaneIPV6
    Log To Console    Step2: Validate and check error not exist on WebEM.
    selenium_coam.validate_plan
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty     ${error}
    Log To Console    Step3: Do activation,caculate activation duration and check validation duration no more than requirement
#    ${timestartTmp}   Get Current Date
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
#    ${timestart}      convert date    ${timestartTmp}    epoch
#    ${timeendTmp}     Get Current Date
#    ${timeend}        convert date    ${timeendTmp}     epoch
#    ${duration_time_tmp_STEP2}    Evaluate    ${timeend}-${timestart}
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    COAM_WebEM.Logout
     Log To Console    Step3: Check activate duration from syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_VALIDATE_IND"| awk '{print $7}'|head -n 1|tail -1
#    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "markPlanActivation"|awk '{print $7}'|head -n 1|tail -1
    ${startTime}=     run    command=${cmd}
    Should Not Be Empty     ${startTime}
    ${startTime}     convert date
    ...    ${startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_ACTIVATE_RESULT-1 with result:Success"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${endTime}=     run    command=${cmd}
    Should Not Be Empty     ${endTime}
    ${endTime}        convert date
    ...     ${endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${duration}    Evaluate    ${endTime}-${startTime}

    Log To Console    Step4:recovery parameter which will cause site reset
    COAM_WebEM.Login
    ${actEcpriMplaneIPV6_Value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate eCPRI Transport with M plane over IPv6   abbr=actEcpriMplaneIPV6
    run keyword if    "${actEcpriMplaneIPV6_Value}"=="false"
    ...   selenium_coam.set_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate eCPRI Transport with M plane over IPv6
    ...   new_value=true   abbr=actEcpriMplaneIPV6
    ...   ELSE
    ...   selenium_coam.set_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate eCPRI Transport with M plane over IPv6
    ...   new_value=false   abbr=actEcpriMplaneIPV6
    COAM_WebEM.Logout
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Duration_DeltaActivation}    result_value=${duration}
    Should Be True     ${duration}<=${Duration_DeltaActivation} and ${duration}>${0}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    set test variable    ${execution_result}    pass

TC.CB008962_SR_A_43_CM_Duration_of_CM_Activation_Operation_RAT_Level_Service_Outage
     [Documentation]
    ...   Purpose:Test case is to check configuration file_delta plan(RAT level service outage)
    ...            can be validation/activation successful and duration meet requirement.
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Modify parameter which will cause RAT reset .
    ...            eg:modify 'actNonBfAndBfCa' to a different value which cause 5G RAT reset.
    ...     Step2: Validate and check error not exist on WebEM.
    ...     Step3: Do activation,caculate activation duration(duration is captured from system) and check validation
    ...            duration no more than requirement.
    ...     Step4: Restore environment,which means modify parmeter back,do validation and activation.
    [Arguments]   ${Duration_DeltaActivation_With_RAT_Reset}=${AA_12['Duration_DeltaActivationWithRATReset']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    COAM_WebEM.Login
    Log To Console    Step1:Modify parameter which will cause 5G RAT reset.
    ${actNonBfAndBfCa_Value}    selenium_coam.get_parameter_value
    ...    dist_name=${distname}/NRDU-1    filter_param=Activate non beamforming and beamforming TDD FR1 CA    abbr=actNonBfAndBfCa
    run keyword if    "${actNonBfAndBfCa_Value}"=="false"
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${distname}/NRDU-1              filter_param=Activate non beamforming and beamforming TDD FR1 CA
    ...    new_value=true   abbr=actNonBfAndBfCa
    ...    ELSE
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${distname}/NRDU-1              filter_param=Activate non beamforming and beamforming TDD FR1 CA
    ...    new_value=false   abbr=actNonBfAndBfCa
    BtsLog.StartBTSlogCollection
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    COAM_WebEM.Logout
#    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step2: Check duration from syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_VALIDATE_IND"| awk '{print $7}'|head -n 1|tail -1
#    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "markPlanActivation"|awk '{print $7}'|head -n 1|tail -1
    ${tmp_activation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${tmp_activation_startTime}
    ${tmp_activation_startTime}     convert date
    ...    ${tmp_activation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "PLAN_ACTIVATE_RESULT-1 with result=Success"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${tmp_activation_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${tmp_activation_endTime}
    ${tmp_activation_endTime}        convert date
    ...     ${tmp_activation_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${duration_time_tmp_AA12}    Evaluate    ${tmp_activation_endTime}-${tmp_activation_startTime}
    sleep    90s
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Starting resetting procedure"
    ${site_reset}=     run    command=${cmd}
    Should Be Empty     ${site_reset}
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Duration_DeltaActivation_With_RAT_Reset}    result_value=${duration_time_tmp_AA12}
    run keyword and continue on failure    Should Be True
    ...    ${duration_time_tmp_AA12}<=${Duration_DeltaActivation_With_RAT_Reset} and ${duration_time_tmp_AA12}>${0}
    log to console   duration of delta plan activation with RAT reset is ${duration_time_tmp_AA12}
    set test variable    ${execution_result}    pass

TC.CB008962_SR_A_44_CM_Delta_Plan_Provision_Operation_RAT_Level_Service_Outage
    [Documentation]
    ...   Purpose:Check configuration file_delta plan(RAT level service outage) provision can be successful and duration meet requirement
    ...   Precondition: Netact has been integrated,and delta with RAT reset scf(eg:TA_Delta_RATReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import delta scf which will cause RAT reset in netact,and check provision duration no more than requirement
    [Arguments]   ${Durtion_Delta_Plan_Provision_With_RAT_Reset}=${AA_13['Durtion_Delta_Plan_Provision_With_RAT_Reset']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    Log To Console    Step1: Import delta scf which will cause RAT reset in netact,and check provision duration no more than requirement
    run keyword and ignore error     BtsLog.StartBTSlogCollection
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_RATReset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
    log to console    ${duration}
    sleep    90s
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Starting resetting procedure"
    ${site_reset}=     run    command=${cmd}
    Should Be Empty     ${site_reset}
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Durtion_Delta_Plan_Provision_With_RAT_Reset}    result_value=${duration}
    should be true    ${duration}>${0} and ${duration}<${Durtion_Delta_Plan_Provision_With_RAT_Reset}
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
    Set Test Variable    ${GnbReset}    False
    Log To Console    Step1: Import delta scf which will not cause reset in netact,and check provision duration no more than
    ...     requirement
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_NoReset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
    log to console    ${duration}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Delta_Plan_Provision_Durtion}    result_value=${duration}
    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_Provision_Durtion}
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
    Set Test Variable    ${GnbReset}    True
    Log To Console    Step1: Import full scf in netact,and check provision duration no more than requirement
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Full_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
    log to console    ${duration}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Full_Plan_Provision_Duration}    result_value=${duration}
    should be true    ${duration}>${0} and ${duration}<${Full_Plan_Provision_Duration}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
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
    Set Test Variable    ${GnbReset}    False
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    Log To Console    Step1: Import delta no reset scf in netact,do pre_procision and check  duration no more than
    ...     requirement
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_NoReset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=true
    log to console    ${duration}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Delta_Plan_PreProvision_Duration}    result_value=${duration}
    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_PreProvision_Duration}
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
    Set Test Variable    ${GnbReset}    False
    log to console    Step1: Import delta with no reset scf in netact,check download duration no more than requirement
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_Reset_Plan.xml
    ${duration}    NetAct.CMOperationManager.ActiveNewPlan    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=false
    log to console    ${duration}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Delta_Plan_Provision_Duration_Reboot}    result_value=${duration}
    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_Provision_Duration_Reboot}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
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
    Set Test Variable    ${GnbReset}    False
    log to console    Step1:Upload configuration in netact,check upload status and duration no more than requirement
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    ${duration}    NetAct.CMOperationManager.Upload
    log to console    ${duration}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${CMUplod_Duration}    result_value=${duration}
    should be true    ${duration}>${0} and ${duration}<${CMUplod_Duration}
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
    Set Test Variable    ${GnbReset}    True
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
#    ${CheckString}    set variable     "finishActivation|Transfer ccn succeed"
    ${CheckString}    set variable     "finishActivation|ChangeNotificationTask"
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
    Log To Console    Step4: Caculate duration between message "finishActivation" and "ChangeNotificationTask"
    ...     in btslog and check duration no more than requirement.
    ${Noti_Time0}     run    command=cat /tmp/BTSLOG_AA_11.txt|grep finishActivation|awk '{print $7}'|head -n 1|tail -1
    Should Not Be Empty     ${Noti_Time0}
    ${Noti_Time0}        convert date    ${Noti_Time0.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
#    ${Noti_Time2}    run    command=cat /tmp/BTSLOG_AA_11.txt | grep "Transfer ccn succeed"|awk '{print $7}'|head -n 3|tail -1
    ${Noti_Time2}    run    command=cat /tmp/BTSLOG_AA_11.txt | grep "ChangeNotificationTask"|awk '{print $7}'|tail -n 1
    Should Not Be Empty     ${Noti_Time2}
    ${Noti_Time2}        convert date    ${Noti_Time2.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${Noti_Duration1}    Evaluate    ${Noti_Time2}-${Noti_Time0}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Duration_ChangeNoti}    result_value=${Noti_Duration1}
    Should Be True     ${Noti_Duration1}<=${Duration_ChangeNoti} and ${Noti_Duration1}>${0}
    set test variable    ${execution_result}    pass

TC.CB008181_AA_12_CM_Duration_of_Delta_Plan_Validation
    [Documentation]
    ...   Purpose:Check delta plan pre-activate duration meet requirement.
    ...   Precondition: Netact has been integrated,and delta with no reset scf(eg:TA_Delta_NoReset_Plan.xml) is prepared.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: Import delta no reset scf in netact,do pre_procision and check  duration no more than
    ...     requirement
    [Arguments]   ${Delta_Plan_validation_err_Duration}=${AA_07['Delta_Plan_validation_err_Durtion']}
    ...           ${Delta_Plan_validation_suc_Duration}=${AA_07['Delta_Plan_validation_suc_Durtion']}
    ...           ${Delta_Plan_download_Duration}=${AA_07['Delta_Plan_download_Duration']}
#    ...           ${Delta_Plan_PreProvision_Durtion}=${AA_07['Delta_Plan_PreProvision_Durtion']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    Log To Console    Step1: Import delta no reset scf in netact,do pre_procision and check  duration no more than
    ...     requirement
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_NoReset_Plan.xml
    ${download_duration}    NetAct.CMOperationManager.deltaPlanDownload    name=TA_PLAN_TL_${MRBTS_ID}    pre_provision=true
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][0]}
    ...    target_value=${Delta_Plan_download_Duration}    result_value=${download_duration}
    Run Keyword And Ignore Error    should be true    ${download_duration}<${Delta_Plan_download_Duration} and
    ...     ${download_duration}>=${0}
    Log To Console    Duration of delta paln download is ${download_duration}
    ${validation_duration_succ}    NetAct.CMOperationManager.Validation    name=TA_PLAN_TL_${MRBTS_ID}
    ...   pre_provision=true
#    log to console    ${duration}
#    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_PreProvision_Durtion}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][1]}
    ...    target_value=${Delta_Plan_validation_suc_Duration}    result_value=${validation_duration_succ}
    should be true    ${validation_duration_succ}<${Delta_Plan_validation_suc_Duration} and ${validation_duration_succ}>${0}
    Log To Console    validated duration of delta paln without error is ${validation_duration_succ}
    Log To Console    Step2: Import delta plan with error and check the validation duration
    NetAct.CMOperationManager.ImportPlan    FileName=${CFGFILE_PATH}/TA_Delta_Plan_error.xml
    ${validation_duration_err}    NetAct.CMOperationManager.Validation    name=TA_PLAN_TL_${MRBTS_ID}
    ...   pre_provision=true
#    log to console    ${duration}
#    should be true    ${duration}>${0} and ${duration}<${Delta_Plan_PreProvision_Durtion}
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][2]}
    ...    target_value=${Delta_Plan_validation_err_Duration}    result_value=${validation_duration_err}
    should be true    ${validation_duration_err}<${Delta_Plan_validation_err_Duration} and ${validation_duration_err}>${0}
    Log To Console    validated duration of delta paln with error is ${validation_duration_err}
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
    Set Test Variable    ${GnbReset}    False
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${snapshot_save_time}    result_value=${duration_time_tmp}
    Should Be True     ${duration_time_tmp}<=${snapshot_save_time}     Snapshot collect time is more than 15 minute
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
    Set Test Variable    ${GnbReset}    False
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
         AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][0]}
         ...    target_value=${FilePresentTime}    result_value=${duration}
         Should be true    ${duration}<=${FilePresentTime}
    END
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
    Set Test Variable    ${GnbReset}    False
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
        ...    "update usageState to |finishActivation"    "update usageState to|finishActivation"
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
        AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
        ...    target_value=${StartAndStopLtency}    result_value=${duration}
        Should be true    ${duration}>${0} and ${duration}<${StartAndStopLtency}
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
    #waitLegalStatementApper  ${pagePart}
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
    ...           ${Max_Duration_of_Site_Reset}=${SM_06['Max_Duration_of_Site_Reset']}
    set test variable    ${execution_result}    fail
    set test variable    ${GnbReset}    True
    @{MAXdurationList}=  Create List
    set test variable    ${CaseAVGLoop_KPI1a}     ${0}
    set test variable    ${CaseSUM_KPI1a}         ${0}
    set test variable    ${CaseAVGLoop_KPI1b}     ${0}
    set test variable    ${CaseSUM_KPI1b}        ${0}
    set test variable    ${CaseSUM_MAXduration}     ${0}
    set test variable    ${CaseAVGLoop_MAXduration}    ${0}
    set test variable    ${MAXduration_min}    5000
    set test variable    ${MAXduration_max}    0
    @{kpiList}  Create List  KPI1a   KPI1b
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${WebUI_reset_times}
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${RMODsList}       KW.CP_GetRMODsList
    ${AdjRMOD}    Set Variable     AEHC
    ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
    ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
    ...    AdjRMOD=${AdjRMOD}
    &{KPI_TARGET}    Create Dictionary
    Set To Dictionary    ${KPI_TARGET}    kpi1a=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
    Set To Dictionary    ${KPI_TARGET}    kpi1b=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
#    KW.CaseStatusInit    retry_times=${WebUI_reset_times}
    @{durationListForKPI1a}=  Create List
    set test variable    ${KPI1a_duration_min}    5000
    set test variable    ${KPI1a_duration_max}    0
    set test variable    ${KPI1b_duration_min}    5000
    set test variable    ${KPI1b_duration_max}    0
    @{durationListForKPI1b}=  Create List
    FOR    ${i}    IN RANGE    ${WebUI_reset_times}
        KW.CPKPILoopStart
        ${res}    run keyword and ignore error    KW.CPLoopForResetViaWEBUI    loop=${i+1}    graceful_cell_shutdown=${graceful_cell_shutdown}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp_KPI1a}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        Append To List    ${durationListForKPI1a}    ${duration_time_tmp_KPI1a}
        ${duration_time_tmp_KPI1b}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][2]}
        Append To List    ${durationListForKPI1b}    ${duration_time_tmp_KPI1b}
        ${MAXduration_duration}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][3]}
        Append To List    ${MAXdurationList}    ${MAXduration_duration}

        log to console    MAX duration ${MAXdurationList}
        log to console    KPI1a list ${durationListForKPI1a}
        log to console    KPI1b list ${durationListForKPI1b}

        Run Keyword And Ignore error     KW.CPKPILoopEnd    loop=${i}
        KW.CaseStatusCaluate    duration=${duration_time_tmp_KPI1a}    max=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        log to console     Case loop ${i+1} END
#        Get common info     case_result=${reset_status}    case_name=site_reset   loop_number=${i+1}  duration_time=${duration_time_tmp}

        ${CaseSUM_KPI1a}      run keyword if    ${duration_time_tmp_KPI1a}<=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        ...    Evaluate    ${CaseSUM_KPI1a}+${duration_time_tmp_KPI1a}
        ...    ELSE    Set Variable    ${CaseSUM_KPI1a}
        ${CaseAVGLoop_KPI1a}    run keyword if    ${duration_time_tmp_KPI1a}<=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        ...    Evaluate    ${CaseAVGLoop_KPI1a}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_KPI1a}
        Set test Variable    ${CaseSUM_KPI1a}    ${CaseSUM_KPI1a}
        Set test Variable    ${CaseAVGLoop_KPI1a}    ${CaseAVGLoop_KPI1a}

        ${CaseSUM_KPI1b}      run keyword if    ${duration_time_tmp_KPI1b}<=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        ...    Evaluate    ${CaseSUM_KPI1b}+${duration_time_tmp_KPI1b}
        ...    ELSE    Set Variable    ${CaseSUM_KPI1b}
        ${CaseAVGLoop_KPI1b}    run keyword if    ${duration_time_tmp_KPI1b}<=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        ...    Evaluate    ${CaseAVGLoop_KPI1b}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_KPI1b}
        Set test Variable    ${CaseSUM_KPI1b}    ${CaseSUM_KPI1b}
        Set test Variable    ${CaseAVGLoop_KPI1b}    ${CaseAVGLoop_KPI1b}

        ${CaseSUM_MAXduration}      run keyword if    ${MAXduration_duration}<=${Max_Duration_of_Site_Reset}
        ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
        ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
        ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_Site_Reset}
        ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
        Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
        Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}

        AppendCaseResultToFile    index=${i}    requirement_id=KPI1a
        ...    target_value=${KPIAdjValue['KPI1a']['KPI1a_AVG']}    result_value=${duration_time_tmp_KPI1a}
        AppendCaseResultToFile    index=${i}    requirement_id=KPI1b
        ...    target_value=${KPIAdjValue['KPI1a']['KPI1a_AVG']}    result_value=${duration_time_tmp_KPI1b}
        AppendCaseResultToFile   index=${i}   requirement_id=MAXDuration
        ...    target_value=${Max_Duration_of_Site_Reset}    result_value=${MAXduration_duration}

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${duration_time_tmp_KPI1a}>${KPIAdjValue['KPI1a']['KPI1a_MAX']}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#1a value is above target
    END
#    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI1a']['KPI1a_AVG']}    max_loop=${WebUI_reset_times}
#    set test variable    ${execution_result}    pass
    Run Keyword And Ignore error     KW.CPKPICaseEnd    times=${WebUI_reset_times}    OAM_KPI_TARGETS=${KPI_TARGET}
#    log to console    ${durationList}
    log to console    KPI1a list ${durationListForKPI1a}
    log to console    KPI1b list ${durationListForKPI1b}
    ${durationLength}=    Get length      ${durationListForKPI1a}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${KPI1a_duration_max}=   set variable if   ${durationListForKPI1a[${i}]}>=${KPI1a_duration_max}
         ...    ${durationListForKPI1a[${i}]}    ${KPI1a_duration_max}
         ${KPI1a_duration_min}=    set variable if   ${durationListForKPI1a[${i}]}<=${KPI1a_duration_min}
         ...    ${durationListForKPI1a[${i}]}    ${KPI1a_duration_min}
         ${KPI1b_duration_max}=   set variable if   ${durationListForKPI1b[${i}]}>=${KPI1b_duration_max}
         ...    ${durationListForKPI1b[${i}]}    ${KPI1b_duration_max}
         ${KPI1b_duration_min}=    set variable if   ${durationListForKPI1b[${i}]}<=${KPI1b_duration_min}
         ...    ${durationListForKPI1b[${i}]}    ${KPI1b_duration_min}
         ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
         ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
    END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${kpi1a_max}    evaluate    round(${KPI1a_duration_max},2)
    ${kpi1a_min}    evaluate    round(${KPI1a_duration_min},2)
    ${kpi1b_max}    evaluate    round(${KPI1b_duration_max},2)
    ${kpi1b_min}    evaluate    round(${KPI1b_duration_min},2)
    ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
    ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
#    ${kpi1a_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI1a']['KPI1a_AVG']}    max_loop=${WebUI_reset_times}
    ${kpi1a_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI1a}>0   Evaluate    ${CaseSUM_KPI1a}/${CaseAVGLoop_KPI1a}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${kpi1a_aver_tmp}<=${KPIAdjValue['KPI1a']['KPI1a_AVG']}
    ${kpi1a_aver}    evaluate    round(${kpi1a_aver_tmp},2)

    ${kpi1b_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI1b}>0   Evaluate    ${CaseSUM_KPI1b}/${CaseAVGLoop_KPI1b}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${kpi1b_aver_tmp}<=${KPIAdjValue['KPI1a']['KPI1a_AVG']}
    ${kpi1b_aver}    evaluate    round(${kpi1b_aver_tmp},2)

    ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_Site_Reset}
    ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)

    Get common infos    kpi=KPI1a_${GracefulCellShutdown}   kpi_max=${kpi1a_max}    kpi_min=${kpi1a_min}    kpi_aver=${kpi1a_aver}
    Get common infos    kpi=KPI1b_${GracefulCellShutdown}   kpi_max=${kpi1b_max}    kpi_min=${kpi1b_min}    kpi_aver=${kpi1b_aver}
    Get common infos    kpi=MAX_duration_of_Site_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}
    set test variable    ${execution_result}    pass

TC.CP_HA_01_OAM_KPI_1f_Site_Reset_WithOut_RuReset_Outage_Duration_Single_Core
    [Arguments]   ${WebUI_reset_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1f']['WebUI_reset_times']}
    set test variable    ${execution_result}    fail
    set test variable    ${GnbReset}    True
    @{MAXdurationList}=  Create List
    set test variable    ${CaseAVGLoop_KPI1f}     ${0}
    set test variable    ${CaseSUM_KPI1f}         ${0}
    set test variable    ${CaseSUM_MAXduration}     ${0}
    set test variable    ${CaseAVGLoop_MAXduration}    ${0}
    set test variable    ${MAXduration_min}    5000
    set test variable    ${MAXduration_max}    0
    @{kpiList}  Create List  KPI1f
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${WebUI_reset_times}
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${RMODsList}       KW.CP_GetRMODsList
    ${AdjRMOD}    Set Variable     AEHC
    ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
    ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
    ...    AdjRMOD=${AdjRMOD}
    &{KPI_TARGET}    Create Dictionary
    Set To Dictionary    ${KPI_TARGET}    kpi1f=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
#    KW.CaseStatusInit    retry_times=${WebUI_reset_times}
    @{durationListForKPI1f}=  Create List
    set test variable    ${KPI1f_duration_min}    5000
    set test variable    ${KPI1f_duration_max}    0
    FOR    ${i}    IN RANGE    ${WebUI_reset_times}
        KW.CPKPILoopStart
        ${res}    run keyword and ignore error    KW.CPLoopForResetViaWEBUIWithoutRUreset    loop=${i+1}
        ...    graceful_cell_shutdown=${graceful_cell_shutdown}    reset_without_ru=true
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp_KPI1f}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        Append To List    ${durationListForKPI1f}    ${duration_time_tmp_KPI1f}

        log to console    KPI1f list ${durationListForKPI1f}

        Run Keyword And Ignore error     KW.CPKPILoopEnd    loop=${i}
        KW.CaseStatusCaluate    duration=${duration_time_tmp_KPI1f}    max=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        log to console     Case loop ${i+1} END
#        Get common info     case_result=${reset_status}    case_name=site_reset   loop_number=${i+1}  duration_time=${duration_time_tmp}

        ${CaseSUM_KPI1f}      run keyword if    ${duration_time_tmp_KPI1f}<=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        ...    Evaluate    ${CaseSUM_KPI1f}+${duration_time_tmp_KPI1f}
        ...    ELSE    Set Variable    ${CaseSUM_KPI1f}
        ${CaseAVGLoop_KPI1f}    run keyword if    ${duration_time_tmp_KPI1f}<=${KPIAdjValue['KPI1a']['KPI1a_MAX']}
        ...    Evaluate    ${CaseAVGLoop_KPI1f}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_KPI1f}
        Set test Variable    ${CaseSUM_KPI1f}    ${CaseSUM_KPI1f}
        Set test Variable    ${CaseAVGLoop_KPI1f}    ${CaseAVGLoop_KPI1f}

        AppendCaseResultToFile    index=${i}    requirement_id=KPI1f
        ...    target_value=${KPIAdjValue['KPI1a']['KPI1a_AVG']}    result_value=${duration_time_tmp_KPI1f}

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${duration_time_tmp_KPI1f}>${KPIAdjValue['KPI1a']['KPI1a_MAX']}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#1f value is above target
    END
    Run Keyword And Ignore error     KW.CPKPICaseEnd    times=${WebUI_reset_times}    OAM_KPI_TARGETS=${KPI_TARGET}
#    log to console    ${durationList}
    log to console    KPI1f list ${durationListForKPI1f}
    ${durationLength}=    Get length      ${durationListForKPI1f}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${KPI1f_duration_max}=   set variable if   ${durationListForKPI1f[${i}]}>=${KPI1f_duration_max}
         ...    ${durationListForKPI1f[${i}]}    ${KPI1f_duration_max}
         ${KPI1f_duration_min}=    set variable if   ${durationListForKPI1f[${i}]}<=${KPI1f_duration_min}
         ...    ${durationListForKPI1f[${i}]}    ${KPI1f_duration_min}
    END
    ${kpi1f_max}    evaluate    round(${KPI1f_duration_max},2)
    ${kpi1f_min}    evaluate    round(${KPI1f_duration_min},2)
#    ${kpi1a_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI1a']['KPI1a_AVG']}    max_loop=${WebUI_reset_times}
    ${kpi1f_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI1f}>0   Evaluate    ${CaseSUM_KPI1f}/${CaseAVGLoop_KPI1f}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${kpi1f_aver_tmp}<=${KPIAdjValue['KPI1a']['KPI1a_AVG']}
    ${kpi1f_aver}    evaluate    round(${kpi1f_aver_tmp},2)

    Get common infos    kpi=KPI1f_${GracefulCellShutdown}   kpi_max=${kpi1f_max}    kpi_min=${kpi1f_min}    kpi_aver=${kpi1f_aver}
    set test variable    ${execution_result}    pass


# power_reset
TC.CP_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    [Arguments]   ${Power_reset_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['Power_reset_times']}
    set test variable    ${execution_result}    fail
    set test variable    ${GnbReset}    True
    @{kpiList}  Create List  KPI3
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Power_reset_times}
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${RMODsList}       KW.CP_GetRMODsList
    ${AdjRMOD}    Set Variable     AEHC
    ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
    ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
    ...    AdjRMOD=${AdjRMOD}
    &{KPI_TARGET}    Create Dictionary
    Set To Dictionary    ${KPI_TARGET}    kpi3=${KPIAdjValue['KPI3']['KPI3_MAX']}
#    KW.CaseStatusInit    retry_times=${Power_reset_times}
    @{durationList}=  Create List
    set test variable    ${duration_min}    5000
    set test variable    ${duration_max}    0
    FOR    ${i}    IN RANGE    ${Power_reset_times}
        KW.CPKPILoopStart
        AlarmWatchdog.add_allow_alarms    fault_id=4590
        AlarmWatchdog.add_allow_alarms    fault_id=4589
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error    KW.CPLoopForPowerReset    loop=${i+1}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        Append To List    ${durationList}    ${duration_time_tmp}
        log to console    ${durationList}
        ${startTime}   set variable    ${res[1][2]}
        Run Keyword And Ignore error     KW.CPKPILoopEnd    loop=${i}    startTime=${startTime}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPIAdjValue['KPI3']['KPI3_MAX']}
        log to console     Case loop ${i+1} END
#        Get common info     case_result=${reset_status}    case_name=power_reset   loop_number=${i+1}  duration_time=${duration_time_tmp}
        AppendCaseResultToFile    index=${i}
        ...    target_value=${KPIAdjValue['KPI3']['KPI3_AVG']}    result_value=${duration_time_tmp}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${duration_time_tmp}>${KPIAdjValue['KPI3']['KPI3_MAX']}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#3 value is above target
        AlarmWatchdog.remove_allow_alarms    fault_id=4590
        AlarmWatchdog.remove_allow_alarms    fault_id=4589
    END
#    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI3']['KPI3_AVG']}    max_loop=${Power_reset_times}
#    set test variable    ${execution_result}    pass
    Run Keyword And Ignore error     KW.CPKPICaseEnd    times=${Power_reset_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${durationList}
    ${durationLength}=    Get length      ${durationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
    END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${kpi_max}    evaluate    round(${duration_max},2)
    ${kpi_min}    evaluate    round(${duration_min},2)
    ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI3']['KPI3_AVG']}    max_loop=${Power_reset_times}
    ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
    Get common infos    kpi=KPI3   kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
    set test variable    ${execution_result}    pass

TC.5GC002536_HA_03_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
    [Documentation]
    ...   Purpose: check OAM KPI5,Capacity module reset performance (service downtime) shall be kept within 180s
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Reset basebands one by one,and check every baseband's duration meet target
    [Arguments]   ${BBMOD_Reset_Times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI5']['BBMOD_Reset_Times']}
    ...           ${Max_Duration_of_BBMOD_Reset}=${SM_03['Max_Duration_of_BBMOD_Reset']}
    set test variable    ${execution_result}    fail
    @{kpiList}  Create List  KPI5
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${BBMOD_Reset_Times}
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${AdjRMOD}    Set Variable     AEHC
    FOR    ${BBMOD}   IN    @{BTSInfo['basebandModules']}
        ${BBMOD_config}=    Split String From Right    ${BBMOD['id']['configuration']}     /
        ${BBMOD_ID}    Set Variable     ${BBMOD_config[-1]}
        ${tmp}=    Split String From Right   ${BBMOD_config[-1]}      -
        ${BBMOD_INDEX}    Set Variable   ${tmp[-1]}
        ${RMODs_infoList}    KW.GetRMODsInfoByBBMODID    BBMOD_ID=${BBMOD_ID}
        ${SFPCooledInfo_BBMOD}    KW.GetSFPCooledInfoOnBBMOD    BBMOD_INDEX=${BBMOD_INDEX}
        #RU_index just for 1BBMOD--1RMOD, not for 1BBMOD--nRMOD
        ${RU_Index}=  set variable  ${RMODs_infoList[1][0]}
        ${SFPCooledInfo_RU}    KW.GetSFPCooledInfoOnRU       RU_INDEX=${RU_Index}
        ${tmp_status}=   Evaluate   "${SFPCooledInfo_BBMOD}"=="true" or "${SFPCooledInfo_RU}"=="true"
        ${SFPCooledInfo}=    Set Variable if    "${tmp_status}"=="True"     true    false
        ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODs_infoList[0]}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
        ...    AdjRMOD=${AdjRMOD}
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi5=${KPIAdjValue['KPI5']}
        set test variable   ${KPI_TARGET}
        log to console    Reset basebands one by one,and check every baseband's duration meet target
        KW.CapacityModuleReset    retry_times=${BBMOD_Reset_Times}    KPI5=${KPIAdjValue['KPI5']}    bbmod_reset_index=${BBMOD_INDEX}
        ...    Max_Duration_of_BBMOD_Reset=${Max_Duration_of_BBMOD_Reset}
#        ...    KPI_TARGET=${KPI_TARGET}
    END
    Run Keyword And Ignore error     KW.CPKPICaseEnd    times=${BBMOD_Reset_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.CB010445_SR_C_19_Capacity_Module_Power_Reset_downtime_Manually_Triggered_KPI14
    [Documentation]
    ...   Purpose: check OAM KPI14,Capacity module power reset performance (service downtime) shall be kept within target.
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Power reset basebands one by one,and check every baseband's duration meet target
    [Arguments]   ${BBMOD_Power_Reset_Times}=${CASE_INPUT_5GC002479['CB010445_HA_KPI14']['BBMOD_Power_Reset_Times']}
    ...           ${Max_Duration_of_BBMOD_Power_Reset}=${SM_08['Max_Duration_of_BBMOD_Power_Reset']}
    set test variable    ${execution_result}    fail
    @{kpiList}  Create List  KPI14
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${BBMOD_Power_Reset_Times}
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${AdjRMOD}    Set Variable     AEHC
    FOR    ${BBMOD}   IN    @{BTSInfo['basebandModules']}
        ${BBMOD_config}=    Split String From Right    ${BBMOD['id']['configuration']}     /
        ${BBMOD_ID}    Set Variable     ${BBMOD_config[-1]}
        ${tmp}=    Split String From Right   ${BBMOD_config[-1]}      -
        ${BBMOD_INDEX}    Set Variable   ${tmp[-1]}
        ${PowerResetBBMOD_Unit}    KW.GetPowerResetBBMODUnitWithBBMODIndex    BBMOD_INDEX=${BBMOD_INDEX}
        ${RMODs_infoList}    KW.GetRMODsInfoByBBMODID    BBMOD_ID=${BBMOD_ID}
        ${SFPCooledInfo_BBMOD}    KW.GetSFPCooledInfoOnBBMOD    BBMOD_INDEX=${BBMOD_INDEX}
        #RU_index just for 1BBMOD--1RMOD, not for 1BBMOD--nRMOD
        ${RU_Index}=  set variable  ${RMODs_infoList[1][0]}
        ${SFPCooledInfo_RU}    KW.GetSFPCooledInfoOnRU       RU_INDEX=${RU_Index}
        ${tmp_status}=   Evaluate   "${SFPCooledInfo_BBMOD}"=="true" or "${SFPCooledInfo_RU}"=="true"
        ${SFPCooledInfo}=    Set Variable if    "${tmp_status}"=="True"     true    false
        ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODs_infoList[0]}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
        ...    AdjRMOD=${AdjRMOD}
        ${KPI14_Formula}=    set variable    ${KPIAdjValue['KPI5']}+200
        ${KPI14}=     Evaluate     ${KPI14_Formula}
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi14=${KPI14}
        set test variable   ${KPI_TARGET}
        log to console    Power reset basebands one by one,and check every baseband's duration meet target
        KW.CapacityModulePowerReset    retry_times=${BBMOD_Power_Reset_Times}    KPI14=${KPI14}    PowerResetBBMOD_Unit=${PowerResetBBMOD_Unit}
        ...    Max_Duration_of_BBMOD_Power_Reset=${Max_Duration_of_BBMOD_Power_Reset}
#        ...    KPI_TARGET=${KPI_TARGET}
    END
    Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${BBMOD_Power_Reset_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
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
    @{kpiList}  Create List  KPI54a
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${RU_Reset_Times}
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi54a=${KPIAdjValue['KPI54a']}
        set test variable   ${KPI_TARGET}
#        KW.CB006939_HA_04_OAM_KPI_54a_RU_Cold_Reset_Time    retry_times=${RU_Reset_Times}    ru_index=${RU_INDEX}
#        ...     KPI54A_MAX=${KPIAdjValue['KPI54a']['KPI54a_MAX']}    KPI54A_AVG=${KPIAdjValue['KPI54a']['KPI54a_AVG']}
        KW.CB006939_HA_04_OAM_KPI_54a_RU_Cold_Reset_Time    retry_times=${RU_Reset_Times}    ru_index=${RU_INDEX}
        ...    KPI_TARGET=${KPI_TARGET}    KPI54a=${KPIAdjValue['KPI54a']}
    END
    Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${RU_Reset_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.CB006939_HA_05_OAM_KPI_17_Cell_Block_Unblock_Outage_Duration
    [Documentation]
    ...  Purpose:Check OAM KPI17,The BTS shall complete the block/unblock Cell operations within target duration
    ...  Precondition: cell on air
    ...  Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:Block/Unblock one by one,and check every cell's duration meet target
    [Arguments]   ${Cell_BlockUnblock_Times}=${CASE_INPUT_5GC002479['CB010445_HA_KPI17']['Cell_BlockUnblock_Times']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    @{kpiList}  Create List  KPI17a  KPI17b
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Cell_BlockUnblock_Times}
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi17a=${KPIAdjValue['KPI17a']}
        Set To Dictionary    ${KPI_TARGET}    kpi17b=${KPIAdjValue['KPI17b']}
        set test variable   ${KPI_TARGET}
        KW.CB006939_HA_05_OAM_KPI_17_Cell_Block_Unblock    CellBlockDuration=${KPIAdjValue['KPI17a']}
        ...    CellUnblockDurtion=${KPIAdjValue['KPI17b']}   retry_times=${Cell_BlockUnblock_Times}    cell_idx=${CELL_INDEX}
#        ...    KPI_TARGET=${KPI_TARGET}
#        Run Keyword And Ignore error    WEBUI.Collect snapshot
    END
    KW.CPKPICaseEnd    times=${Cell_BlockUnblock_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.CB006939_HA_05_OAM_KPI_17a_Cell_Block_Outage_Duration
    [Documentation]
    ...  Purpose:Check OAM KPI17,The BTS shall complete the block/unblock Cell operations within target duration
    ...  Precondition: cell on air
    ...  Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:Block/Unblock one by one,and check every cell's duration meet target
    [Arguments]   ${Cell_BlockUnblock_Times}=${CASE_INPUT_5GC002479['CB010445_HA_KPI17']['Cell_BlockUnblock_Times']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    @{kpiList}  Create List  KPI17a
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Cell_BlockUnblock_Times}
    log to console    Step1:Block one by one,and check every cell's duration meet target
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi17a=${KPIAdjValue['KPI17a']}
        set test variable   ${KPI_TARGET}
        KW.CB006939_HA_05_OAM_KPI_17a_Cell_Block    CellBlockDuration=${KPIAdjValue['KPI17a']}
        ...    retry_times=${Cell_BlockUnblock_Times}    cell_idx=${CELL_INDEX}
#        ...    KPI_TARGET=${KPI_TARGET}
    END
    Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${Cell_BlockUnblock_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.CB006939_HA_06_OAM_KPI_17b_Cell_Unblock_Outage_Duration
    [Documentation]
    ...  Purpose:Check OAM KPI17,The BTS shall complete the block/unblock Cell operations within target duration
    ...  Precondition: cell on air
    ...  Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:Block/Unblock one by one,and check every cell's duration meet target
    [Arguments]   ${Cell_BlockUnblock_Times}=${CASE_INPUT_5GC002479['CB010445_HA_KPI17']['Cell_BlockUnblock_Times']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    @{kpiList}  Create List   KPI17b
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Cell_BlockUnblock_Times}
    log to console    Step1:Unblock one by one,and check every cell's duration meet target
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi17b=${KPIAdjValue['KPI17b']}
        set test variable   ${KPI_TARGET}
        KW.CB006939_HA_06_OAM_KPI_17b_Cell_Unblock    CellUnblockDurtion=${KPIAdjValue['KPI17b']}
        ...    retry_times=${Cell_BlockUnblock_Times}    cell_idx=${CELL_INDEX}
#        ...    KPI_TARGET=${KPI_TARGET}
    END
    Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${Cell_BlockUnblock_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.CB009402_SR_C_20_Cell_reset_downtime_Manually_Triggered_KPI19
    [Documentation]
    ...  Purpose:Check OAM KPI19,The BTS shall complete the Cell reset operations within target duration
    ...  Precondition: cell on air
    ...  Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:Cell reset one by one,and check every cell's duration meet target
    [Arguments]   ${Cell_Reset_Times}=${CASE_INPUT_5GC002479['CB009402_HA_KPI19']['Cell_Reset_Times']}
    ...           ${Max_Duration_of_Cell_Reset}=${SM_07['Max_Duration_of_Cell_Reset']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    @{kpiList}  Create List  KPI19
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Cell_Reset_Times}
    log to console    Step1:Cell reset one by one,and check every cell's duration meet target
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi19=${KPIAdjValue['KPI19']}
        set test variable   ${KPI_TARGET}
        KW.CB009402_SR_C_20_Cell_reset_downtime_Manually_Triggered_KPI19    ResetCellDuration=${KPIAdjValue['KPI19']}    cell_idx=${CELL_INDEX}
        ...    retry_times=${Cell_Reset_Times}    Max_Duration_of_Cell_Reset=${Max_Duration_of_Cell_Reset}
#        ...    KPI_TARGET=${KPI_TARGET}
    END
    Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${Cell_Reset_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
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
    ...           ${Max_Duration_of_RU_Reset}=${SM_02['Max_Duration_of_RU_Reset']}
    set test variable    ${execution_result}    fail
    set test variable    ${with_graceful}    ${False}
    @{kpiList}  Create List  KPI51a
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${RF_Reset_Times}
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi51a=${KPIAdjValue['KPI51a']}
        set test variable   ${KPI_TARGET}
#        KW.Reset.WEbUIResetWithRetry   case_name=rf_reset    retry_times=${RF_Reset_Times}    ru_reset_index=${RU_Reset_INDEX}
#        ...     KPI51a=${KPIAdjValue['KPI51a']['KPI51a_MAX']}    KPI51a_AVG=${KPIAdjValue['KPI51a']['KPI51a_AVG']}
        KW.Reset.WEbUIResetWithRetry    retry_times=${RF_Reset_Times}    ru_reset_index=${RU_Reset_INDEX}
        ...     KPI51a=${KPIAdjValue['KPI51a']}    KPI_TARGET=${KPI_TARGET}   Max_Duration_of_RU_Reset=${Max_Duration_of_RU_Reset}
        ...     with_graceful=${with_graceful}
    END
    Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${RF_Reset_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.General_SiSo_Auto_RF_module_reset_from_WebUI_with_L3call
    [Documentation]
    ...  Purpose:check l3call after RF reset
    ...  Precondition: Cell on air
    ...  Testing tools:WebUI or Netact
    ...  Test Steps:
    ...    Step1:Reset radio
    ...    Step2:l3call after cell up
    [Arguments]
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login
    WEBUI.ResetRU    ru_index=${1}    with_graceful=${False}
    sleep    60s
    COAM_WebEM.Logout
    wait until keyword succeeds    10min    30s    Check BTS Onair
    MultiUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG1']}
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog

TC.5GC002479_SWM_Software_Upgrade
    [Arguments]   ${max_num}=500   ${stream}=${TargetStream}    ${status}=[released ,released_with_restrictions]
    ...           ${conditions}=${condition_PS_same}
    set suite variable     ${SWM}     ${1}
    run    command=rm -rf ${UPDATE_FILE_PATH}
    sleep   10s
    run    command=mkdir ${UPDATE_FILE_PATH}
    Set Test Variable    ${GnbReset}    True
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

    log to console    check SW download duration
    ${sw_active_type}    Set Variable     All
    ${download_startTime}    KW.TimerStart
    log to console   start to software update with active
    selenium_sbts.software_update     is_activate=${True}    sw_active_type=${sw_active_type}

    log to console   finish KW selenium_coam.software_update
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    ${SW_download_duration}     KW.TimerStop    timestart=${download_startTime}
    log to console   download duration is ${SW_download_duration}

    set suite variable     ${SW_download_duration}
    set suite variable     ${SWM}     ${2}
#    ${active_startTime}    KW.TimerStart
    log to console    ckeck bts reset
    Run Keyword And Ignore error   Wait until keyword succeeds    10min    10s    5GC002479_Resouce.gNB.CheckgNBReset
    log to console    waitAllCellsOnair
    wait until keyword succeeds    30min    10s    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog

    log to console    check SW active duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
    ...       awk '{print $7}'|head -n 1
    ${active_startTime}=     run    command=${cmd}
    Should Not Be Empty    ${active_startTime}
    ${active_startTime}     convert date
    ...    ${active_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...      awk '{print $7}'|tail -n 1
    ${active_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${active_endTime}
    ${active_endTime}        convert date
    ...     ${active_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${SW_active_duration}    Evaluate    ${active_endTime}-${active_startTime}
    log to console    active duration is ${SW_active_duration}

    log to console    check SW upgrade duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "SwDownloadStatusUpdater"|
    ...      awk '{print $7}'|head -n 1
    ${upgrade_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${upgrade_startTime}
    ${upgrade_startTime}        convert date
    ...     ${upgrade_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...      awk '{print $7}'|head -n 1
    ${upgrade_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${upgrade_endTime}
    ${upgrade_endTime}        convert date
    ...     ${upgrade_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${SW_upgrade_duration}    Evaluate    ${upgrade_endTime}-${upgrade_startTime}
    log to console    KPI4 duration is ${SW_upgrade_duration}

#    ${SW_active_duration}     KW.TimerStop    timestart=${active_startTime}
#    ${SW_upgrade_duration}     KW.TimerStop    timestart=${download_startTime}
    set suite variable     ${SW_active_duration}
    set suite variable     ${SW_upgrade_duration}
    set suite variable     ${SWM}     ${3}

    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
    Run Keyword if   '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${1}

TC.CB012803_RU_Software_Upgrade
    [Arguments]   ${max_num}=500   ${stream}=${TargetStream}    ${status}=[released ,released_with_restrictions]
    ...           ${conditions}=${condition_ru_diff}    ${cell}=${cell}
#    set suite variable     ${SWM}     ${1}
    run    command=rm -rf ${UPDATE_FILE_PATH}
    sleep   10s
    run    command=mkdir ${UPDATE_FILE_PATH}
    Set Test Variable    ${GnbReset}    True
    ${TargetBuildVersion}=         Set Variable         ${TARGETSW}
    ${OriginalBuildVersion}=       KW.SWM.FilterGetGNBSWVersion      Target_build=${TargetBuildVersion}   max_num=${max_num}
    ...               stream=${stream}    status=${status}       conditions=${conditions}
    log to console    original=${OriginalBuildVersion}
    log to console    target=${TargetBuildVersion}
    KW.SWM.PrepareOriginalENVbyYAFT    build_version=${OriginalBuildVersion}
    ${Target_package_path}        SoftwareUpdate.Download_gNB_Package    build_version=${TargetBuildVersion}
    log to console    package prepared
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
#    log to console    Download SW build with activate
    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    log to console   start to load software for RU only SW upgrade
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${Target_package_path}
    log to console    ${load_result}

    log to console    check RU SW download duration
    ${sw_active_type}    Set Variable     RU SW only
    ${RUSWDownload_startTime}    KW.TimerStart
    log to console   start to RU software only
    selenium_sbts.software_update     is_activate=${True}    sw_active_type=${sw_active_type}
    log to console   finish KW selenium_coam.software_update
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    ${RUSWDownload_duration}     KW.TimerStop    timestart=${RUSWDownload_startTime}
    log to console   RU SW download duration is ${RUSWDownload_duration}
#    sleep  60s
    Run Keyword And Ignore error    COAM_WebEM.Logout
    sleep  120s
    log to console    waitAllCellsOnair after RU SW Upgrade
    wait until keyword succeeds    30min    10s    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog
    sleep   10s
    log to console    check KPI55a for RU Only SW upgrade duration
    ${cmd}   Catenate  cat /tmp/btslog2/SYSLOG_*.LOG|grep "CELL_M-${cell} status change to operational state: Disabled, availability status: Offline"|
    ...       awk '{print $7}'|head -n 1
    ${RUSWUpgrade_startTime}=     run    command=${cmd}
    Should Not Be Empty    ${RUSWUpgrade_startTime}
    ${RUSWUpgrade_startTime}     convert date
    ...    ${RUSWUpgrade_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "NR-${cell} has been changed from Validated to OnAirDone"|
    ...      awk '{print $7}'|tail -n 1
    ${RUSWUpgrade_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${RUSWUpgrade_endTime}
    ${RUSWUpgrade_endTime}        convert date
    ...     ${RUSWUpgrade_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${RUSWUpgrade_duration}    Evaluate    ${RUSWUpgrade_endTime}-${RUSWUpgrade_startTime}
    set test variable     ${RUSWUpgrade_duration}
    log to console    KPI55a RU Only SW upgrade duration is ${RUSWUpgrade_duration}

    log to console   Next recovery env by DU SW upgrade
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
#    log to console    Download SW build with activate
    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    log to console   start to load software for DU SW upgrade
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${Target_package_path}
    log to console    ${load_result}

    log to console    check SW download duration
    ${sw_active_type}    Set Variable     All
    ${DUSWDownload_startTime}    KW.TimerStart
    log to console   start to DU software update with active
    selenium_sbts.software_update     is_activate=${True}    sw_active_type=${sw_active_type}
    log to console   finish KW selenium_coam.software_update
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    ${DUSWDownload_duration}     KW.TimerStop    timestart=${DUSWDownload_startTime}
    log to console   DU SW download duration is ${DUSWDownload_duration}
    Run Keyword And Ignore error    COAM_WebEM.Logout
    set test variable     ${DUSWDownload_duration}
#    set suite variable     ${SWM}     ${2}
#    ${active_startTime}    KW.TimerStart
    log to console    ckeck bts reset
    Run Keyword And Ignore error   Wait until keyword succeeds    10min    10s    5GC002479_Resouce.gNB.CheckgNBReset
    log to console    waitAllCellsOnair
    wait until keyword succeeds    30min    10s    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog

    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
    Run Keyword if   '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${1}

TC.CB012803_DU_Software_Upgrade
    [Arguments]   ${max_num}=500   ${stream}=${TargetStream}    ${status}=[released ,released_with_restrictions]
    ...           ${conditions}=${condition_PS_same}
    set suite variable     ${SWM}     ${1}
    run    command=rm -rf ${UPDATE_FILE_PATH}
    sleep   10s
    run    command=mkdir ${UPDATE_FILE_PATH}
    Set Test Variable    ${GnbReset}    True
    ${TargetBuildVersion}=         Set Variable         ${TARGETSW}
    ${OriginalBuildVersion}=       KW.SWM.FilterGetGNBSWVersion      Target_build=${TargetBuildVersion}   max_num=${max_num}
    ...               stream=${stream}    status=${status}       conditions=${conditions}
    log to console    original=${OriginalBuildVersion}
    log to console    target=${TargetBuildVersion}
    KW.SWM.PrepareOriginalENVbyYAFT    build_version=${OriginalBuildVersion}
    ${Target_package_path}        SoftwareUpdate.Download_gNB_Package    build_version=${TargetBuildVersion}
    log to console    package prepared
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
#    log to console    Download SW build with activate
    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    log to console   start to load software for RU only SW upgrade
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${Target_package_path}
    log to console    ${load_result}

    log to console    check RU download duration
    ${sw_active_type}    Set Variable     RU SW only
    ${downloadRU_startTime}    KW.TimerStart
    log to console   start to RU software only
    selenium_sbts.software_update     is_activate=${True}    sw_active_type=${sw_active_type}
    log to console   finish KW selenium_coam.software_update
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    ${RU_download_duration}     KW.TimerStop    timestart=${download_RUstartTime}
    log to console   RU download duration is ${RU_download_duration}
#    sleep  60s
    Run Keyword And Ignore error    COAM_WebEM.Logout
    log to console    waitAllCellsOnair after RU SW Upgrade
    wait until keyword succeeds    30min    10s    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog
    sleep   60s
#    log to console    check KPI55a for RU Only SW upgrade duration
#    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
#    ...       awk '{print $7}'|head -n 1
#    ${upgradeRU_startTime}=     run    command=${cmd}
#    Should Not Be Empty    ${upgradeRU_startTime}
#    ${upgradeRU_startTime}     convert date
#    ...    ${upgradeRU_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
#    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
#    ...      awk '{print $7}'|tail -n 1
#    ${upgradeRU_endTime}=     run    command=${cmd}
#    Should Not Be Empty     ${upgradeRU_endTime}
#    ${upgradeRU_endTime}        convert date
#    ...     ${upgradeRU_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
#    ${upgradeRU_duration}    Evaluate    ${upgradeRU_endTime}-${upgradeRU_startTime}
#    log to console    KPI55a RU Only SW upgrade duration is ${upgradeRU_duration}

    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
#    log to console    Download SW build with activate
    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    log to console   start to load software for DU SW upgrade
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${Target_package_path}
    log to console    ${load_result}

    log to console    check SW download duration
    ${sw_active_type}    Set Variable     All
    ${downloadDU_startTime}    KW.TimerStart
    log to console   start to DU software update with active
    selenium_sbts.software_update     is_activate=${True}    sw_active_type=${sw_active_type}
    log to console   finish KW selenium_coam.software_update
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    ${DU_download_duration}     KW.TimerStop    timestart=${downloadDU_startTime}
    log to console   download duration is ${DU_download_duration}
    Run Keyword And Ignore error    COAM_WebEM.Logout

    set suite variable     ${DU_download_duration}
    set suite variable     ${SWM}     ${2}
#    ${active_startTime}    KW.TimerStart
    log to console    ckeck bts reset
    Run Keyword And Ignore error   Wait until keyword succeeds    10min    10s    5GC002479_Resouce.gNB.CheckgNBReset
    log to console    waitAllCellsOnair
    wait until keyword succeeds    30min    10s    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog

    log to console    check DU SW active duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
    ...       awk '{print $7}'|head -n 1
    ${DUSW_active_startTime}=     run    command=${cmd}
    Should Not Be Empty    ${DUSW_active_startTime}
    ${DUSW_active_startTime}     convert date
    ...    ${DUSW_active_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...      awk '{print $7}'|tail -n 1
    ${DUSW_active_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${DUSW_active_endTime}
    ${DUSW_active_endTime}        convert date
    ...     ${DUSW_active_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${DUSW_active_duration}    Evaluate    ${DUSW_active_endTime}-${DUSW_active_startTime}
    log to console    KPI57 DU SW active duration is ${DUSW_active_duration}

    log to console    check DU SW upgrade duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "SwDownloadStatusUpdater"|
    ...      awk '{print $7}'|head -n 1
    ${DUSW_upgrade_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${DUSW_upgrade_startTime}
    ${DUSW_upgrade_startTime}        convert date
    ...     ${DUSW_upgrade_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...      awk '{print $7}'|head -n 1
    ${DUSW_upgrade_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${DUSW_upgrade_endTime}
    ${DUSW_upgrade_endTime}        convert date
    ...     ${DUSW_upgrade_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${DUSW_upgrade_duration}    Evaluate    ${DUSW_upgrade_endTime}-${DUSW_upgrade_startTime}
    log to console    KPI58 DU SW upgrade duration is ${DUSW_upgrade_duration}

#    ${SW_active_duration}     KW.TimerStop    timestart=${active_startTime}
#    ${SW_upgrade_duration}     KW.TimerStop    timestart=${download_startTime}
    set suite variable     ${DUSW_active_duration}
    set suite variable     ${DUSW_upgrade_duration}
    set suite variable     ${SWM}     ${3}

    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
    Run Keyword if   '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${1}

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
     KW.CaseStatusInit    retry_times=1
     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
     Run keyword if    ${SWM}==${0}    TC.5GC002479_SWM_Software_Upgrade
     Run keyword if    ${SWM}<${2}     Fail    Step not execute
     log    ${SW_download_duration}
     Append To List    ${durationList}    ${SW_download_duration}
     log to console    ${durationList}
     AppendCaseResultToFile    target_value=${KPIAdjValue['SW_Download_MAX']}    result_value=${SW_download_duration}
     KW.CaseStatusCaluate    duration=${SW_download_duration}    max=${KPIAdjValue['SW_Download_MAX']}
     run keyword and continue on failure    Should Be True     ${SW_download_duration}<=${KPIAdjValue['SW_Download_MAX']}

#     set test variable    ${execution_result}    pass
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['SW_Download_MAX']}    max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=SW_Download_MAX  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
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
     run keyword and continue on failure    Should Be True     ${SW_active_duration}<=${KPI2a_AVG}

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
     @{kpiList}  Create List  KPI2b
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=1
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...   AdjRMOD=${AdjRMOD}
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi2b=${KPIAdjValue['KPI2b']['KPI2b_AVG']}
#     KW.CaseStatusInit    retry_times=1
     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
     set suite variable     ${SWM_KPI2B}     ${1}
     set suite variable     ${SWM}     ${0}
     KW.CPKPILoopStart
     AlarmWatchdog.add_allow_alarms    fault_id=4681
     AlarmWatchdog.add_allow_alarms    fault_id=4589
     AlarmWatchdog.add_allow_alarms    fault_id=10
     AlarmWatchdog.add_allow_alarms    fault_id=6450
     AlarmWatchdog.add_allow_alarms    fault_id=23
     KW.SWM.CheckIfSWActiveRun    stream=${OriginalStream}    conditions=&{condition_PS_diff}
     Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=1
     AlarmWatchdog.remove_allow_alarms    fault_id=4681
     AlarmWatchdog.remove_allow_alarms    fault_id=4589
     AlarmWatchdog.remove_allow_alarms    fault_id=10
     AlarmWatchdog.remove_allow_alarms    fault_id=6450
     AlarmWatchdog.remove_allow_alarms    fault_id=23
     set suite variable     ${SWM_KPI2B}     ${2}
     log        ${SW_active_duration}
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=1    OAM_KPI_TARGETS=${KPI_TARGET}
     Append To List    ${durationList}    ${SW_active_duration}
     log to console    ${durationList}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2b']['KPI2b_AVG']}    result_value=${SW_active_duration}
     KW.CaseStatusCaluate    duration=${SW_active_duration}    max=${KPIAdjValue['KPI2b']['KPI2b_AVG']}
     run keyword and continue on failure    Should Be True     ${SW_active_duration}<=${KPIAdjValue['KPI2b']['KPI2b_AVG']}
#     set test variable    ${execution_result}    pass
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI2b']['KPI2b_AVG']}   max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=KPI2b_${GracefulCellShutdown}  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
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
     @{kpiList}  Create List  KPI2c
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=1
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...    AdjRMOD=${AdjRMOD}
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi2c=${KPIAdjValue['KPI2c']['KPI2c_AVG']}
     set suite variable     ${SWM_KPI2C}     ${1}
     set suite variable     ${SWM}     ${0}
#     KW.CaseStatusInit    retry_times=1
     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
     KW.CPKPILoopStart
     AlarmWatchdog.add_allow_alarms    fault_id=4681
     AlarmWatchdog.add_allow_alarms    fault_id=4589
     AlarmWatchdog.add_allow_alarms    fault_id=10
     AlarmWatchdog.add_allow_alarms    fault_id=6450
     AlarmWatchdog.add_allow_alarms    fault_id=4590
     AlarmWatchdog.add_allow_alarms    fault_id=23
     KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}   conditions=&{condition_PS_same}
     Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=1
     AlarmWatchdog.remove_allow_alarms    fault_id=4681
     AlarmWatchdog.remove_allow_alarms    fault_id=4589
     AlarmWatchdog.remove_allow_alarms    fault_id=10
     AlarmWatchdog.remove_allow_alarms    fault_id=6450
     AlarmWatchdog.remove_allow_alarms    fault_id=4590
     AlarmWatchdog.remove_allow_alarms    fault_id=23
     set suite variable     ${SWM_KPI2C}     ${2}
     log        ${SW_active_duration}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2c']['KPI2c_AVG']}    result_value=${SW_active_duration}
     KW.CaseStatusCaluate    duration=${SW_active_duration}    max=${KPIAdjValue['KPI2c']['KPI2c_AVG']}
     run keyword and continue on failure    Should Be True     ${SW_active_duration}<=${KPIAdjValue['KPI2c']['KPI2c_AVG']}
#     set test variable    ${execution_result}    pass
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=1    OAM_KPI_TARGETS=${KPI_TARGET}
     Append To List    ${durationList}    ${SW_active_duration}
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI2c']['KPI2c_AVG']}    max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=KPI2c_${GracefulCellShutdown}  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
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
     @{kpiList}  Create List  KPI2d
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=1
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...    AdjRMOD=${AdjRMOD}
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi2d=${KPIAdjValue['KPI2d']['KPI2d_AVG']}
     set suite variable     ${SWM_KPI2D}     ${1}
     set suite variable     ${SWM}     ${0}
#     KW.CaseStatusInit    retry_times=1
     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
     KW.CPKPILoopStart
     AlarmWatchdog.add_allow_alarms    fault_id=4681
     AlarmWatchdog.add_allow_alarms    fault_id=4589
     AlarmWatchdog.add_allow_alarms    fault_id=10
     AlarmWatchdog.add_allow_alarms    fault_id=6450
     AlarmWatchdog.add_allow_alarms    fault_id=4590
     AlarmWatchdog.add_allow_alarms    fault_id=23
     KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}   conditions=&{condition_PS_diff}
     Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=1
     AlarmWatchdog.remove_allow_alarms    fault_id=4681
     AlarmWatchdog.remove_allow_alarms    fault_id=4589
     AlarmWatchdog.remove_allow_alarms    fault_id=10
     AlarmWatchdog.remove_allow_alarms    fault_id=6450
     AlarmWatchdog.remove_allow_alarms    fault_id=4590
     AlarmWatchdog.remove_allow_alarms    fault_id=23
     set suite variable     ${SWM_KPI2D}     ${2}
     log        ${SW_active_duration}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2d']['KPI2d_AVG']}    result_value=${SW_active_duration}
     KW.CaseStatusCaluate    duration=${SW_active_duration}    max=${KPIAdjValue['KPI2d']['KPI2d_AVG']}
     run keyword and continue on failure    Should Be True     ${SW_active_duration}<=${KPIAdjValue['KPI2d']['KPI2d_AVG']}
#     set test variable    ${execution_result}    pass
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=1    OAM_KPI_TARGETS=${KPI_TARGET}
     Append To List    ${durationList}    ${SW_active_duration}
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI2d']['KPI2d_AVG']}     max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=KPI2d_${GracefulCellShutdown}  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
     set test variable    ${execution_result}    pass

TC.CB013276_SR_C_26_Manual_RU_SW_upgrade_downtime_KPI55a
    [Documentation]  KPI#55a - Manual independent RU SW upgrade downtime.
     ...  Precondition:This case needs preparing SCF for originail Stream in gnb_configuration,
     ...               because after YAFT to original stream, SCF may be lost.
     ...  Test Steps:
     ...    Step1: YAFT SW to original stream build which the RF build is differnt with target build
     ...    Step2: Choose RU Software only to upgrade
     ...    Step4: Check KPI#55a result should be not over target.
     ...    Step5: recovery env by Choose All to SW Software upgrade
     [Arguments]   ${RMODName}=${CASE_INPUT_5GC002479['5GC002479_KPI55']['RU']}
     ...           ${RMODIndex}=${CASE_INPUT_5GC002479['5GC002479_KPI55']['RU_Index']}
     ...           ${CellIndex}=${CASE_INPUT_5GC002479['5GC002479_KPI55']['Cell_Index']}
     ...           ${condition_ru_diff}=${CASE_INPUT_5GC002479['5GC002479_KPI55']['condition_ru_diff']}
     set test variable    ${execution_result}    fail
     @{kpiList}  Create List  KPI55a
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=1
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     @{RMODsList}=  Create List
     ${RMOD}=  Set Variable    ${RMODName}
     Append To List    ${RMODsList}    ${RMOD}
     ${SFPCooledInfo}    KW.GetSFPCooledInfoOnRU   RU_INDEX=${RMODIndex}
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}    SFPCooled=${SFPCooledInfo}
        ...    AdjRMOD=${AdjRMOD}
     ${KPI55a}=    Evaluate    ${KPIAdjValue['KPI51a']}+120
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi55a=${KPI55a}
     set test variable   ${KPI_TARGET}

     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
#     set suite variable     ${SWM_KPI57b}     ${1}
#     set suite variable     ${SWM}     ${0}
     KW.CPKPILoopStart
     AlarmWatchdog.add_allow_alarms    fault_id=4681
     AlarmWatchdog.add_allow_alarms    fault_id=4589
     AlarmWatchdog.add_allow_alarms    fault_id=10
     AlarmWatchdog.add_allow_alarms    fault_id=6450
     AlarmWatchdog.add_allow_alarms    fault_id=4590
     AlarmWatchdog.add_allow_alarms    fault_id=23
     KW.SWM.CheckIfRUSWActiveRun    stream=${TargetStream}    conditions=&{condition_ru_diff}    cell=${CellIndex}
     Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=1
     AlarmWatchdog.remove_allow_alarms    fault_id=4681
     AlarmWatchdog.remove_allow_alarms    fault_id=4589
     AlarmWatchdog.remove_allow_alarms    fault_id=10
     AlarmWatchdog.remove_allow_alarms    fault_id=6450
     AlarmWatchdog.remove_allow_alarms    fault_id=4590
     AlarmWatchdog.remove_allow_alarms    fault_id=23
#     set suite variable     ${SWM_KPI57b}     ${2}
#     log        ${RUSW_active_duration}
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=1    OAM_KPI_TARGETS=${KPI_TARGET}
     Append To List    ${durationList}    ${RUSWUpgrade_duration}
     log to console    ${durationList}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2b']['KPI2b_AVG']}    result_value=${RUSWUpgrade_duration}
     KW.CaseStatusCaluate    duration=${RUSWUpgrade_duration}    max=${KPIAdjValue['KPI2b']['KPI2b_AVG']}
     run keyword and continue on failure    Should Be True     ${RUSWUpgrade_duration}<=${KPIAdjValue['KPI2b']['KPI2b_AVG']}
#     set test variable    ${execution_result}    pass
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI2b']['KPI2b_AVG']}   max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=KPI55a_${GracefulCellShutdown}  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
     set test variable    ${execution_result}    pass


TC.CB012803_SR_C_22_DU_SW_Activation_downtime_KPI57b_Inter_Release_with_SM_Firmware_Upgrade
    [Documentation]  KPI#57b - Manual DU Inter-release SW activation downtime with firmware update downtime .
     ...  Precondition:This case needs preparing SCF for originail Stream in gnb_configuration,
     ...               because after YAFT to original stream, SCF may be lost.
     ...  Test Steps:
     ...    Step1: YAFT SW to original stream build which the firmware is differnt with target build
     ...    Step2: Choose RU Software only to upgrade first
     ...    Step3: Choose All to SW Software upgrade
     ...    Step4: Check KPI#57b result should be not over target.
     [Arguments]   ${OriginalStream}=${CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStream']}
     set test variable    ${execution_result}    fail
     @{kpiList}  Create List  KPI57b
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=1
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...   AdjRMOD=${AdjRMOD}
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi57b=${KPIAdjValue['KPI2b']['KPI2b_AVG']}
#     KW.CaseStatusInit    retry_times=1
     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
     set suite variable     ${SWM_KPI57b}     ${1}
     set suite variable     ${SWM}     ${0}
     KW.CPKPILoopStart
     AlarmWatchdog.add_allow_alarms    fault_id=4681
     AlarmWatchdog.add_allow_alarms    fault_id=4589
     AlarmWatchdog.add_allow_alarms    fault_id=10
     AlarmWatchdog.add_allow_alarms    fault_id=6450
     AlarmWatchdog.add_allow_alarms    fault_id=4590
     AlarmWatchdog.add_allow_alarms    fault_id=23
     AlarmWatchdog.add_allow_alarms    fault_id=4420
     KW.SWM.CheckIfDUSWActiveRun    stream=${OriginalStream}    conditions=&{condition_PS_diff}
     Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=1
     AlarmWatchdog.remove_allow_alarms    fault_id=4681
     AlarmWatchdog.remove_allow_alarms    fault_id=4589
     AlarmWatchdog.remove_allow_alarms    fault_id=10
     AlarmWatchdog.remove_allow_alarms    fault_id=6450
     AlarmWatchdog.remove_allow_alarms    fault_id=4590
     AlarmWatchdog.remove_allow_alarms    fault_id=23
     AlarmWatchdog.remove_allow_alarms    fault_id=4420
     set suite variable     ${SWM_KPI57b}     ${2}
     log        ${DUSW_active_duration}
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=1    OAM_KPI_TARGETS=${KPI_TARGET}
     Append To List    ${durationList}    ${DUSW_active_duration}
     log to console    ${durationList}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2b']['KPI2b_AVG']}    result_value=${DUSW_active_duration}
     KW.CaseStatusCaluate    duration=${DUSW_active_duration}    max=${KPIAdjValue['KPI2b']['KPI2b_AVG']}
     run keyword and continue on failure    Should Be True     ${DUSW_active_duration}<=${KPIAdjValue['KPI2b']['KPI2b_AVG']}
#     set test variable    ${execution_result}    pass
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI2b']['KPI2b_AVG']}   max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=KPI57b_${GracefulCellShutdown}  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
     set test variable    ${execution_result}    pass

TC.CB012803_SR_C_23_DU_SW_Activation_downtime_KPI57c_Intra_Release_without_SM_Firmware_Upgrade
    [Documentation]  KPI#57c - Manual DU Intra-release SW activation downtime without firmware update downtime .
     ...  Precondition:This case needs preparing SCF for originail Stream in gnb_configuration,
     ...               because after YAFT to original stream, SCF may be lost.
     ...  Test Steps:
     ...    Step1: YAFT SW to original stream build which the firmware is same with target build
     ...    Step2: Choose RU Software only to upgrade first
     ...    Step3: Choose All to SW Software upgrade
     ...    Step4: Check KPI#57c result should be not over target.
#     [Arguments]   ${OriginalStream}=${CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStream']}
     set test variable    ${execution_result}    fail
     @{kpiList}  Create List  KPI57c
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=1
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...   AdjRMOD=${AdjRMOD}
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi57c=${KPIAdjValue['KPI2c']['KPI2c_AVG']}
#     KW.CaseStatusInit    retry_times=1
     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
     set suite variable     ${SWM_KPI57c}     ${1}
     set suite variable     ${SWM}     ${0}
     KW.CPKPILoopStart
     AlarmWatchdog.add_allow_alarms    fault_id=4681
     AlarmWatchdog.add_allow_alarms    fault_id=4589
     AlarmWatchdog.add_allow_alarms    fault_id=10
     AlarmWatchdog.add_allow_alarms    fault_id=6450
     AlarmWatchdog.add_allow_alarms    fault_id=4590
     AlarmWatchdog.add_allow_alarms    fault_id=23
     KW.SWM.CheckIfDUSWActiveRun    stream=${TargetStream}    conditions=&{condition_PS_same}
     Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=1
     AlarmWatchdog.remove_allow_alarms    fault_id=4681
     AlarmWatchdog.remove_allow_alarms    fault_id=4589
     AlarmWatchdog.remove_allow_alarms    fault_id=10
     AlarmWatchdog.remove_allow_alarms    fault_id=6450
     AlarmWatchdog.remove_allow_alarms    fault_id=4590
     AlarmWatchdog.remove_allow_alarms    fault_id=23
     set suite variable     ${SWM_KPI57c}     ${2}
     log        ${DUSW_active_duration}
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=1    OAM_KPI_TARGETS=${KPI_TARGET}
     Append To List    ${durationList}    ${DUSW_active_duration}
     log to console    ${durationList}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2c']['KPI2c_AVG']}    result_value=${DUSW_active_duration}
     KW.CaseStatusCaluate    duration=${DUSW_active_duration}    max=${KPIAdjValue['KPI2c']['KPI2c_AVG']}
     run keyword and continue on failure    Should Be True     ${DUSW_active_duration}<=${KPIAdjValue['KPI2c']['KPI2c_AVG']}
#     set test variable    ${execution_result}    pass
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI2c']['KPI2c_AVG']}   max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=KPI57c_${GracefulCellShutdown}  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
     set test variable    ${execution_result}    pass

TC.CB012803_SR_C_24_DU_SW_Activation_downtime_KPI57d_Intra_Release_with_SM_Firmware_Upgrade
    [Documentation]  KPI#57d - Manual DU Intra-release SW activation downtime with firmware update downtime .
     ...  Precondition:This case needs preparing SCF for originail Stream in gnb_configuration,
     ...               because after YAFT to original stream, SCF may be lost.
     ...  Test Steps:
     ...    Step1: YAFT SW to original stream build which the firmware is differnt with target build
     ...    Step2: Choose RU Software only to upgrade first
     ...    Step3: Choose All to SW Software upgrade
     ...    Step4: Check KPI#57d result should be not over target.
#     [Arguments]   ${OriginalStream}=${CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStream']}
     set test variable    ${execution_result}    fail
     @{kpiList}  Create List  KPI57d
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=1
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...   AdjRMOD=${AdjRMOD}
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi57b=${KPIAdjValue['KPI2d']['KPI2d_AVG']}
#     KW.CaseStatusInit    retry_times=1
     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
     set suite variable     ${SWM_KPI57d}     ${1}
     set suite variable     ${SWM}     ${0}
     KW.CPKPILoopStart
     AlarmWatchdog.add_allow_alarms    fault_id=4681
     AlarmWatchdog.add_allow_alarms    fault_id=4589
     AlarmWatchdog.add_allow_alarms    fault_id=10
     AlarmWatchdog.add_allow_alarms    fault_id=6450
     AlarmWatchdog.add_allow_alarms    fault_id=4590
     AlarmWatchdog.add_allow_alarms    fault_id=23
     KW.SWM.CheckIfDUSWActiveRun    stream=${TargetStream}    conditions=&{condition_PS_diff}
     Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=1
     AlarmWatchdog.remove_allow_alarms    fault_id=4681
     AlarmWatchdog.remove_allow_alarms    fault_id=4589
     AlarmWatchdog.remove_allow_alarms    fault_id=10
     AlarmWatchdog.remove_allow_alarms   fault_id=6450
     AlarmWatchdog.remove_allow_alarms    fault_id=4590
     AlarmWatchdog.remove_allow_alarms    fault_id=23
     set suite variable     ${SWM_KPI57d}     ${2}
     log        ${DUSW_active_duration}
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=1    OAM_KPI_TARGETS=${KPI_TARGET}
     Append To List    ${durationList}    ${DUSW_active_duration}
     log to console    ${durationList}
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI2d']['KPI2d_AVG']}    result_value=${DUSW_active_duration}
     KW.CaseStatusCaluate    duration=${DUSW_active_duration}    max=${KPIAdjValue['KPI2d']['KPI2d_AVG']}
     run keyword and continue on failure    Should Be True     ${DUSW_active_duration}<=${KPIAdjValue['KPI2d']['KPI2d_AVG']}
#     set test variable    ${execution_result}    pass
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI2d']['KPI2d_AVG']}   max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=KPI57d_${GracefulCellShutdown}  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
     set test variable    ${execution_result}    pass

TC.CB012803_SR_C_25_DU_SW_Upgrade_duration_KPI58
    [Documentation]  KPI#58 - Complete BTS SW upgrade. This KPI is applicable for any supported SW inter-release upgrade path
    ...      towards the target SW release and also for any SW intra-release upgrade path since 22R1.
    ...  Test Steps:
    ...    Step1: check if software upgrade case is not executed then then Run Software upgrade case with default condition.
    ...    Step2: check KPI#58 result should be not over KPI58 average target
     set test variable    ${execution_result}    fail
     @{kpiList}  Create List  KPI58
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=1
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...    AdjRMOD=${AdjRMOD}
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi58=${KPIAdjValue['KPI4']}
#     KW.CaseStatusInit    retry_times=1
     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
     KW.CPKPILoopStart
     AlarmWatchdog.add_allow_alarms    fault_id=4681
     AlarmWatchdog.add_allow_alarms    fault_id=4589
     AlarmWatchdog.add_allow_alarms    fault_id=10
     AlarmWatchdog.add_allow_alarms    fault_id=6450
     AlarmWatchdog.add_allow_alarms    fault_id=4590
     AlarmWatchdog.add_allow_alarms    fault_id=23
     run keyword if   ${SWM_KPI57b}<${1} and ${SWM_KPI57c}<${1} and ${SWM_KPI57d}<${1}
         ...    KW.SWM.CheckIfDUSWActiveRun    stream=${OriginalStream}
     Run keyword if    ${SWM}<${3}    Fail    Step not execute
     log        ${DUSW_upgrade_duration}
     Append To List    ${durationList}    ${DUSW_upgrade_duration}
     log to console    ${durationList}
     Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=1
     AlarmWatchdog.remove_allow_alarms    fault_id=4681
     AlarmWatchdog.remove_allow_alarms    fault_id=4589
     AlarmWatchdog.remove_allow_alarms    fault_id=10
     AlarmWatchdog.remove_allow_alarms    fault_id=6450
     AlarmWatchdog.remove_allow_alarms    fault_id=4590
     AlarmWatchdog.remove_allow_alarms    fault_id=23
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI4']}    result_value=${DUSW_upgrade_duration}
     KW.CaseStatusCaluate    duration=${DUSW_upgrade_duration}    max=${KPIAdjValue['KPI4']}
     run keyword and continue on failure    Should Be True     ${DUSW_upgrade_duration}<=${KPIAdjValue['KPI4']}
#     set test variable    ${execution_result}    pass
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=1    OAM_KPI_TARGETS=${KPI_TARGET}
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI4']}   max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=KPI58  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
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
     @{kpiList}  Create List  KPI4
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=1
     ${BTSInfo}     COAM_Admin.GetBTSInfo
     ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
     ${CellNums}    KW.CP_GetCellNums
     ${RMODsList}       KW.CP_GetRMODsList
     ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
     ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
     ...    AdjRMOD=${AdjRMOD}
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi4=${KPIAdjValue['KPI4']}
#     KW.CaseStatusInit    retry_times=1
     @{durationList}=  Create List
     set test variable    ${duration_min}    5000
     set test variable    ${duration_max}    0
     KW.CPKPILoopStart
     AlarmWatchdog.add_allow_alarms    fault_id=4681
     AlarmWatchdog.add_allow_alarms    fault_id=4589
     AlarmWatchdog.add_allow_alarms    fault_id=10
     AlarmWatchdog.add_allow_alarms    fault_id=6450
     AlarmWatchdog.add_allow_alarms    fault_id=4590
     AlarmWatchdog.add_allow_alarms    fault_id=23
     run keyword if   ${SWM_KPI2A}<${1} and ${SWM_KPI2B}<${1} and ${SWM_KPI2C}<${1} and ${SWM_KPI2D}<${1}
         ...    KW.SWM.CheckIfSWActiveRun    stream=${TargetStream}
     Run keyword if    ${SWM}<${3}    Fail    Step not execute
     log        ${SW_upgrade_duration}
     Append To List    ${durationList}    ${SW_upgrade_duration}
     log to console    ${durationList}
     AlarmWatchdog.remove_allow_alarms    fault_id=4681
     AlarmWatchdog.remove_allow_alarms    fault_id=4589
     AlarmWatchdog.remove_allow_alarms    fault_id=10
     AlarmWatchdog.remove_allow_alarms    fault_id=6450
     AlarmWatchdog.remove_allow_alarms    fault_id=4590
     AlarmWatchdog.remove_allow_alarms    fault_id=23
     Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=1
     AppendCaseResultToFile    target_value=${KPIAdjValue['KPI4']}    result_value=${SW_upgrade_duration}
     KW.CaseStatusCaluate    duration=${SW_upgrade_duration}    max=${KPIAdjValue['KPI4']}
     run keyword and continue on failure    Should Be True     ${SW_upgrade_duration}<=${KPIAdjValue['KPI4']}
#     set test variable    ${execution_result}    pass
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=1    OAM_KPI_TARGETS=${KPI_TARGET}
     log to console    ${durationList}
     ${durationLength}=    Get length      ${durationList}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi_max}    evaluate    round(${duration_max},2)
     ${kpi_min}    evaluate    round(${duration_min},2)
     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI4']}   max_loop=1
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     Get common infos    kpi=KPI4  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
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
    Set Test Variable    ${GnbReset}    False
    Log To Console    Step1: Start SW PreCheck
    btslog.startbtslogcollection
    ${target_sw_load}    KW.Select SW package and finish fully PreCheck    sw_version=${CASE_INPUT_5GC002479['StreamPrefix']}
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step2: checkt the duration after operation succeed
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwPrecheck}    result_value=${DurationOfSwPreCheck_tmp_SWM12}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSwPreCheck_tmp_SWM12}<=${DurationOfSwPrecheck} and ${DurationOfSwPreCheck_tmp_SWM12}>${0}
    Log To Console    PreCheck Duration of SW:${target_sw_load} is ${DurationOfSwPreCheck_tmp_SWM12}
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
    Set Test Variable    ${GnbReset}    False
    Log To Console    Start to do SW PostCheck
    btslog.startbtslogcollection
    ${target_sw_load}    KW.Select SW package and finish PostCheck    sw_version=${CASE_INPUT_5GC002479['StreamPrefix']}
    btslog.stopbtslogcollectionandgetlog
    Log To Console    checkt the duration after operation succeed
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwPostCheck}    result_value=${DurationOfSwPostChecktmp_SWM13}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSwPostChecktmp_SWM13}<=${DurationOfSwPostcheck} and ${DurationOfSwPostCheck_tmp_SWM13}>${0}
    Log To Console    PostCheck Duration of SW:${target_sw_load} is ${DurationOfSwPostChecktmp_SWM13}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_A_15_SWM_Duration_of_SW_Rollback
    [Documentation]  Check the duration of SW rollback
    [Arguments]   ${DurationOfSwrollback}=${SWM_15['DurationOfSwrollback']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwrollback}    result_value=${SWRollback_duration_tmp_SWM15}
    run keyword and continue on failure    Should Be True
    ...    ${SWRollback_duration_tmp_SWM15}<=${DurationOfSwrollback} and ${SWRollback_duration_tmp_SWM15}>${0}
    log to console    duration2 of SW Rollback activation is ${SWRollback_duration_tmp_SWM15}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    set test variable    ${execution_result}    pass


TC.CB008181_SR_A_16_SWM_Duration_of_ Upload_SW_Configuration
    [Documentation]
    ...   Purpose:Check duration of upload sw configuration via NetAct.
    ...   Precondition: Netact has been integrated,and gNB configurated.
    ...   Test tools:Netact
    ...   Test Steps:
    ...     Step1: login NetAct and opern app "Software Manager"
    ...     Step2: select the target gNB and do operation "upload"
    ...     Step3: check the duration after operation succeed
    ...     requirement
    [Arguments]   ${DurationOfSwConfigUpload}=${SWM_16['DurationOfSwConfigUpload']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
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
    Log To Console    Step3: check the duration after operation succeed
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwConfigUpload}    result_value=${DurationOfSwConfigUpload_tmp_SWM16}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSwConfigUpload_tmp_SWM16}<=${DurationOfSwConfigUpload} and ${DurationOfSwConfigUpload_tmp_SWM16}>${0}
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
    Set Test Variable    ${GnbReset}    False
    Log To Console    Step1: Start to do SW Cancel
    btslog.startbtslogcollection
    ${target_sw_load}    KW.Select SW package and download then Cancel it    sw_version=${CASE_INPUT_5GC002479['StreamPrefix']}
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step2: check the duration meet the requirement or not
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${DurationOfSwCancel}    result_value=${DurationOfSWCanceltmp_SWM17}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSWCanceltmp_SWM17}<=${DurationOfSwCancel} and ${DurationOfSWCancel_tmp_SWM17}>${0}
    Log To Console   Duration of SW Cancel is ${DurationOfSWCanceltmp_SWM17}s
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
    Set Test Variable    ${GnbReset}    True
    Log To Console    Step1: login WebEM and set the relate parameters
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${active_version}    string.split string    string=${version}[Active]
    ${passive_version}    string.split string    string=${version}[Passive]
    run keyword if    ${active_version}==${passive_version}    Fail    precondition not meet.
    run keyword and ignore error    selenium_sbts.remove_object    object_name=${MRBTS_ID}/MNL-1/CMD-1
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
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Software backup requested"|
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}'][0]}
    ...    target_value=${DurationOfSwCopyManual}    result_value=${DurationOfSwCopy_tmp_SWM18}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSwCopy_tmp_SWM18}<=${DurationOfSwCopyManual} and ${DurationOfSwCopy_tmp_SWM18}>${0}
    Log To Console   Duration of Copy SW from active to passive is ${DurationOfSwCopy_tmp_SWM18}s
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
    Set Test Variable    ${GnbReset}    False
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
    Set Test Variable    ${GnbReset}    False
    log to console    Step1: login WebEM to perform IP connectivity test
    wait until keyword succeeds   15min    10s    COAM_Admin.Login
    Timer.Start
    admin.test_ip_connectivity    remote_address=${UTE_IP}    dscp=10    payload_size=34    source_address=User-defined address    connection=COAM
    ${duration}    Timer.Stop
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${IP_connectivity}    result_value=${duration}
    Should Be True     ${duration}<=${IP_connectivity}
    COAM_Admin.Logout
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
    Set Test Variable    ${GnbReset}    False
    log to console    Step1: System Module Sanity Checker
    wait until keyword succeeds   15min    10s    COAM_Admin.Login
    Timer.Start
    admin.run_sanity_check    connection=COAM
    ${duration}    Timer.Stop
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Sanity_Checker}    result_value=${duration}
    Should Be True     ${duration}<=${Sanity_Checker}
    COAM_Admin.Logout
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
    AppendCaseResultToFile    requirement_id=${REQUIREMENT_ID['${TEST NAME}']}
    ...    target_value=${Configuration_Reset}    result_value=${duration}
    Should Be True     ${duration}<=${Configuration_Reset}
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    gNB.Commission   scf_file=${BACKUP_SCF}
    wait until keyword succeeds    30min    20s    COAM_Admin.CheckAllCellsOnair
    set test variable    ${execution_result}    pass

TC.CB008181_SR_C_09_Cell_lock_unlock_duration_KPI16a_KPI16b
    [Documentation]
    ...  Purpose:Check OAM KPI17,The BTS shall complete the block/unblock Cell operations within target duration
    ...  Precondition: cell on air
    ...  Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:Block/Unblock one by one,and check every cell's duration meet target
    [Arguments]   ${Cell_LockUnlock_Times}=${CASE_INPUT_5GC002479['CB010445_HA_KPI16']['Cell_LockUnlock_Times']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    @{kpiList}  Create List  KPI16a  KPI16b
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Cell_LockUnlock_Times}
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi16a=${KPIAdjValue['KPI16a']}
        Set To Dictionary    ${KPI_TARGET}    kpi16b=${KPIAdjValue['KPI16b']}
        set test variable   ${KPI_TARGET}
        KW.CB008181_SR_C_09_Cell_lock_unlock_duration_KPI16a_KPI16b    retry_times=${Cell_LockUnlock_Times}
        ...    CellLockDuration=${KPIAdjValue['KPI16a']}    CellUnlockDuration=${KPIAdjValue['KPI16b']}    cell_idx=${CELL_INDEX}
#        ...    KPI_TARGET=${KPI_TARGET}
    END
    KW.CPKPICaseEnd    times=${Cell_LockUnlock_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_C_09_Cell_lock_duration_KPI16a
    [Documentation]
    ...  Purpose:Check OAM KPI16a,The BTS shall complete the lock Cell operations within target duration
    ...  Precondition: cell on air
    ...  Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:lock/Unlock one by one,and check every cell's duration meet target
    [Arguments]   ${Cell_LockUnlock_Times}=${CASE_INPUT_5GC002479['CB010445_HA_KPI16']['Cell_LockUnlock_Times']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    @{kpiList}  Create List  KPI16a
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Cell_LockUnlock_Times}
    log to console    Step1:lock one by one,and check every cell's duration meet target
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi16a=${KPIAdjValue['KPI16a']}
        set test variable   ${KPI_TARGET}
        KW.CB008181_SR_C_09_Cell_lock_duration_KPI16a    retry_times=${Cell_LockUnlock_Times}
        ...    CellLockDuration=${KPIAdjValue['KPI16a']}    cell_idx=${CELL_INDEX}
#        ...    KPI_TARGET=${KPI_TARGET}
    END
    Run Keyword And Ignore error     KW.CPKPICaseEnd    times=${Cell_LockUnlock_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_C_10_Cell_unlock_duration_KPI16b
    [Documentation]
    ...  Purpose:Check OAM KPI17,The BTS shall complete the block/unblock Cell operations within target duration
    ...  Precondition: cell on air
    ...  Testing tools:WebUI
    ...  Test Steps:
    ...    Step1:Block/Unblock one by one,and check every cell's duration meet target
    [Arguments]   ${Cell_LockUnlock_Times}=${CASE_INPUT_5GC002479['CB010445_HA_KPI16']['Cell_LockUnlock_Times']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    @{kpiList}  Create List   KPI16b
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Cell_LockUnlock_Times}
    log to console    Step1:Unlock one by one,and check every cell's duration meet target
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi16b=${KPIAdjValue['KPI16b']}
        set test variable   ${KPI_TARGET}
        KW.CB008181_SR_C_10_Cell_unlock_duration_KPI16b    retry_times=${Cell_LockUnlock_Times}
        ...    CellUnlockDuration=${KPIAdjValue['KPI16b']}    cell_idx=${CELL_INDEX}
#        ...    KPI_TARGET=${KPI_TARGET}
    END
    Run Keyword And Ignore error     KW.CPKPICaseEnd    times=${Cell_LockUnlock_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.CB008181_SR_C_15_OAM_KPI_10_5G_RAT_reset
    [Documentation]  test NR RAT reset duration, case has been updated as KPI10a and KPI10b
    log to console   case has been updated as KPI10a and KPI10b

TC.CB008181_SR_C_15_1_OAM_KPI10a_5G_RAT_reset
    [Documentation]   OM_GEN_SFS_PERF_CAP.29071
    ...  Purpose:Aim to test KPI10a 5G RAT reset duration
    ...  Precondition:BTS is commissioned with 5G RAT
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: login WebEM disable Graceful shut down
    ...    Step2: Modify parameter 'actRatResetEnhancement==true' to enable CB008880
    ...    Step3: Perform NR RAT reset   --start point
    ...    Step4: Wait until all cells are up  -- end point
    ...    Step5: Check the duatation is not more than target
    ...    Checkpoint configuration:
    [Arguments]   ${RAT_Reset_Times}=${CASE_INPUT_5GC002479['CB008962_HA_KPI10']['RAT_Reset_Times']}
    ...           ${Max_Duration_of_RAT_Reset}=${SM_01['Max_Duration_of_RAT_Reset']}
    ...           ${SMOD}=${CASE_INPUT_5GC002479['SMOD']}
     Set Test Variable    ${GnbReset}    False
     @{kpiList}  Create List  KPI10a
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${RAT_Reset_Times}
     set test variable    ${execution_result}    fail

     ${KPI10b_Tmp}    run keyword if    "${SMOD}"=="ASOF" or "${SMOD}"=="ASOE"      Set Variable    ${270}
     ...      ELSE      KW.GetMaxBBMODResetVaule
     ${RMODsName}    KW.GetRMODName
     ${RMODs}=    Get length      ${RMODsName}
     FOR    ${rmod}   IN    @{RMODsName}
        ${KPI10b}=
        ...    Run Keyword If    '${rmod}'=='AWHQN'    Evaluate    ${KPI10b_Tmp}+70
        ...    ELSE IF    '${rmod}'=='AQQJ'    Evaluate    ${KPI10b_Tmp}+120
        ...    ELSE    Set Variable    ${KPI10b_Tmp}
        Exit For Loop If    '${rmod}'=='AWHQN' or '${rmod}'=='AQQJ'
     END
     log to console    ${KPI10b}

     ${ValueBase}    KW.GetBaseKPIVaule   TLConfiguration=${CASE_INPUT_5GC002479['TLConfiguration']}
#     set test variable    ${KPI10a}    ${ValueBase['KPI10a']}
     ${KPI10a}    set variable   ${ValueBase['KPI10a']}
     ${BBMODsName}    KW.GetBBMODName
     ${BBMODs}=    Get length      ${BBMODsName}
#     ${KPI10a}    set variable if    ${BBMODs}==0    ${120}
     FOR    ${bbmod}   IN    @{BBMODsName}
#        ${KPI10a}    set variable   ${ValueBase['KPI10a']}
        Continue For Loop If    "${bbmod}"!="ABIL"
        ${KPI10a}    set variable    ${KPI10b}
        Exit For Loop If    "${bbmod}"=="ABIL"
     END
     log to console    ${KPI10a}
     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi10a=${KPI10a}
     set test variable   ${KPI_TARGET}
     @{durationList_KPI10a}=  Create List
     @{MAXdurationList}=  Create List
#     set test variable    ${duration_min}    5000
#     set test variable    ${duration_max}    0
     set test variable    ${RATResetDuration_min}    5000
     set test variable    ${RATResetDuration_max}    0

     set test variable    ${MAXduration_min}    5000
     set test variable    ${MAXduration_max}    0
     Set test Variable    ${CaseSUM_KPI10a}     ${0}
     Set test Variable    ${CaseAVGLoop_KPI10a}     ${0}
     Set test Variable    ${CaseSUM_MAXduration}     ${0}
     Set test Variable    ${CaseAVGLoop_MAXduration}    ${0}
     log to console     Modify parameter 'actRatResetEnhancement==true' to enable CB008880
     wait until keyword succeeds   15min    10s    COAM_WebEM.Login
     ${value}     selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
     ...    filter_param=Activate RAT reset enhancement
     run keyword if   '${value}'=='false'     selenium_coam.set_parameter_value
     ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate RAT reset enhancement   new_value=true
     run keyword and ignore error     COAM_WebEM.ValidateAndActiveParameters
     COAM_WebEM.Logout
     FOR    ${i}    IN RANGE    ${RAT_Reset_Times}
         KW.CPKPILoopStart
         Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
         log to console      Case loop ${i+1}:Step1: Perform NR RAT reset(KPI#10a)
         wait until keyword succeeds   10min    10s    COAM_WebEM.Login    version=SBTS24R2
#         Timer.Start
         selenium_sbts.reset_nr   with_hard=${False}    with_graceful=${False}
         sleep  30s
         run keyword and ignore error    COAM_WebEM.Logout
         wait until keyword succeeds    20min    20s     COAM_Admin.CheckAllCellsOnair
         Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
         Log To Console    Case loop ${i+1}:Step2: Check duration of NR RAT rest
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
         ...       awk '{print $7}'|head -n 1
         ${RATReset_startTime}=     run    command=${cmd}
         Should Not Be Empty    ${RATReset_startTime}
         ${RATReset_startTime}     convert date
         ...    ${RATReset_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
         ...      awk '{print $7}'|tail -n 1
         ${RATReset_endTime}=     run    command=${cmd}
         Should Not Be Empty     ${RATReset_endTime}
         ${RATReset_endTime}        convert date
         ...     ${RATReset_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${RATReset_duration}    Evaluate    ${RATReset_endTime}-${RATReset_startTime}
         Append To List    ${durationList_KPI10a}    ${RATReset_duration}
         log to console    ${durationList_KPI10a}
         AppendCaseResultToFile    index=${i}    target_value=${KPI10a}    result_value=${RATReset_duration}
         run keyword and continue on failure    Should Be True
         ...    ${RATReset_duration}<=${KPI10a} and ${RATReset_duration}>${0}
         log to console   NR RAT reset duration is ${RATReset_duration}
         ${CaseSUM_KPI10a}      run keyword if    ${RATReset_duration}<=${KPI10a}    Evaluate    ${CaseSUM_KPI10a}+${RATReset_duration}
         ...    ELSE    Set Variable    ${CaseSUM_KPI10a}
         ${CaseAVGLoop_KPI10a}    run keyword if    ${RATReset_duration}<=${KPI10a}    Evaluate    ${CaseAVGLoop_KPI10a}+${1}
          ...    ELSE    Set Variable    ${CaseAVGLoop_KPI10a}
         Set test Variable    ${CaseSUM_KPI10a}    ${CaseSUM_KPI10a}
         Set test Variable    ${CaseAVGLoop_KPI10a}    ${CaseAVGLoop_KPI10a}

         Log To Console    Check MAXduration
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. trying to commit"|
          ...       awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_startTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_startTime}
         ${MAXduration_startTime}     convert date
         ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. finished with result: Succeeded"|
         ...      awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_endTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_endTime}
         ${MAXduration_endTime}        convert date
         ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}
         Append To List    ${MAXdurationList}    ${MAXduration_duration}
         log to console    ${MAXdurationList}
#         KW.CaseStatusCaluate    duration=${MAXduration_duration}    max=${Max_Duration_of_RAT_Reset}
         run keyword and continue on failure    Should Be True
         ...    ${MAXduration_duration}<=${Max_Duration_of_RAT_Reset} and ${MAXduration_duration}>${0}
         AppendCaseResultToFile   index=${i}    requirement_id=MAXDuration
         ...    target_value=${Max_Duration_of_RAT_Reset}    result_value=${MAXduration_duration}
         Log To Console   MAX duration of RAT reset  is ${MAXduration_duration}
         ${CaseSUM_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_RAT_Reset}
         ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
         ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
         ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_RAT_Reset}
         ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
         Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
         Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}
         Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}

         ${alarm_result}=    KW.GetAndCheckAlarm
         Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
         ...    Please check unexpect Alarm
         ${result1}  set variable if    ${RATReset_duration}>${KPI10a}   failed    pass
         ${result2}  set variable if    ${MAXduration_duration}>${Max_Duration_of_RAT_Reset}   failed    pass
         Run Keyword if   '${result1}'!='pass' or '${result2}'!='pass' or '${alarm_result}'=='False'
         ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
         Run Keyword And Continue On Failure    Run keyword if    '${result1}'!='pass' or '${result2}'!='pass'   Fail
         ...    KPI#10a value is above target
         log to console     Case loop ${i+1} END
     END
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${RAT_Reset_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
     log to console    ${durationList_KPI10a}
     ${durationLength}=    Get length      ${durationList_KPI10a}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${RATResetDuration_max}=    set variable if   ${durationList_KPI10a[${i}]}>=${RATResetDuration_max}
         ...    ${durationList_KPI10a[${i}]}    ${RATResetDuration_max}
         ${RATResetDuration_min}=    set variable if   ${durationList_KPI10a[${i}]}<=${RATResetDuration_min}
         ...    ${durationList_KPI10a[${i}]}    ${RATResetDuration_min}
         ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
         ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi10a_max}    evaluate    round(${RATResetDuration_max},2)
     ${kpi10a_min}    evaluate    round(${RATResetDuration_min},2)
     ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
     ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
#     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPI10}    max_loop=${RAT_Reset_Times}
#     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     ${kpi10a_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI10a}>0   Evaluate    ${CaseSUM_KPI10a}/${CaseAVGLoop_KPI10a}
     ...      ELSE     set variable    ${3600}
     run keyword and continue on failure    should be true    ${kpi10a_aver_tmp}<=${KPI10a}
     ${kpi10a_aver}    evaluate    round(${kpi10a_aver_tmp},2)

     ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
     ...      ELSE     set variable    ${3600}
     run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_RAT_Reset}
     ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)

     Get common infos    kpi=KPI10a   kpi_max=${kpi10a_max}    kpi_min=${kpi10a_min}    kpi_aver=${kpi10a_aver}
     Get common infos    kpi=MAX_duration_of_RAT_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}
     set test variable    ${execution_result}    pass

TC.CB008181_SR_C_15_2_OAM_KPI10b_5G_RAT_Hard_reset
    [Documentation]   OM_GEN_SFS_PERF_CAP.29071
    ...  Purpose:Aim to test KPI10b 5G RAT Hard reset duration
    ...  Precondition:BTS is commissioned with 5G RAT
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: login WebEM disable Graceful shut down
    ...    Step2: Modify parameter 'actRatResetEnhancement==true' to enable CB008880
    ...    Step3: Perform NR RAT Hard reset   --start point
    ...    Step4: Wait until all cells are up  -- end point
    ...    Step5: Check the duatation is not more than target
    ...    Checkpoint configuration:
    [Arguments]   ${RAT_Reset_Times}=${CASE_INPUT_5GC002479['CB008962_HA_KPI10']['RAT_Reset_Times']}
    ...           ${Max_Duration_of_RAT_Reset}=${SM_01['Max_Duration_of_RAT_Reset']}
    ...           ${SMOD}=${CASE_INPUT_5GC002479['SMOD']}
     Set Test Variable    ${GnbReset}    False
     @{kpiList}  Create List   KPI10b
     set test variable  ${kpiList}
     KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${RAT_Reset_Times}
     set test variable    ${execution_result}    fail

     ${KPI10b_Tmp}    run keyword if    "${SMOD}"=="ASOF" or "${SMOD}"=="ASOE"      Set Variable    ${270}
     ...      ELSE      KW.GetMaxBBMODResetVaule
     ${RMODsName}    KW.GetRMODName
     ${RMODs}=    Get length      ${RMODsName}
     FOR    ${rmod}   IN    @{RMODsName}
        ${KPI10b}=
        ...    Run Keyword If    '${rmod}'=='AWHQN'    Evaluate    ${KPI10b_Tmp}+70
        ...    ELSE IF    '${rmod}'=='AQQJ'    Evaluate    ${KPI10b_Tmp}+120
        ...    ELSE    Set Variable    ${KPI10b_Tmp}
        Exit For Loop If    '${rmod}'=='AWHQN' or '${rmod}'=='AQQJ'
     END
     log to console    ${KPI10b}

     &{KPI_TARGET}    Create Dictionary
     Set To Dictionary    ${KPI_TARGET}    kpi10b=${KPI10b}
     set test variable   ${KPI_TARGET}
     @{durationList_KPI10b}=  Create List
     @{MAXdurationList}=  Create List
#     set test variable    ${duration_min}    5000
#     set test variable    ${duration_max}    0
     set test variable    ${RATHardResetDuration_min}    5000
     set test variable    ${RATHardResetDuration_max}    0

     set test variable    ${MAXduration_min}    5000
     set test variable    ${MAXduration_max}    0
     Set test Variable    ${CaseSUM_KPI10b}     ${0}
     Set test Variable    ${CaseAVGLoop_KPI10b}     ${0}
     Set test Variable    ${CaseSUM_MAXduration}     ${0}
     Set test Variable    ${CaseAVGLoop_MAXduration}    ${0}
     log to console     Modify parameter 'actRatResetEnhancement==true' to enable CB008880
     wait until keyword succeeds   15min    10s    COAM_WebEM.Login
     ${value}     selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
     ...    filter_param=Activate RAT reset enhancement
     run keyword if   '${value}'=='false'     selenium_coam.set_parameter_value
     ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate RAT reset enhancement   new_value=true
     run keyword and ignore error     COAM_WebEM.ValidateAndActiveParameters
     COAM_WebEM.Logout
     FOR    ${i}    IN RANGE    ${RAT_Reset_Times}
         KW.CPKPILoopStart
         Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
         log to console      Case loop ${i+1}:Step3: Perform NR RAT Hard reset(KPI#10b)
         wait until keyword succeeds   10min    10s    COAM_WebEM.Login    version=SBTS24R2
#         Timer.Start
         selenium_sbts.reset_nr   with_hard=${True}    with_graceful=${False}
         sleep  30s
         run keyword and ignore error    COAM_WebEM.Logout
         wait until keyword succeeds    20min    20s     COAM_Admin.CheckAllCellsOnair
         Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
         Log To Console    Case loop ${i+1}:Step4: Check duration of NR RAT Hard rest
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
         ...       awk '{print $7}'|head -n 1
         ${RATHardReset_startTime}=     run    command=${cmd}
         Should Not Be Empty    ${RATHardReset_startTime}
         ${RATHardReset_startTime}     convert date
         ...    ${RATHardReset_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
         ...      awk '{print $7}'|tail -n 1
         ${RATHardReset_endTime}=     run    command=${cmd}
         Should Not Be Empty     ${RATHardReset_endTime}
         ${RATHardReset_endTime}        convert date
         ...     ${RATHardReset_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${RATHardReset_duration}    Evaluate    ${RATHardReset_endTime}-${RATHardReset_startTime}
         Append To List    ${durationList_KPI10b}    ${RATHardReset_duration}
         log to console    ${durationList_KPI10b}
         run keyword and continue on failure    Should Be True
         ...    ${RATHardReset_duration}<=${KPI10b} and ${RATHardReset_duration}>${0}
         AppendCaseResultToFile    index=${i}    target_value=${KPI10b}    result_value=${RATHardReset_duration}
         log to console   NR RAT Hard reset duration is ${RATHardReset_duration}
         ${CaseSUM_KPI10b}      run keyword if    ${RATHardReset_duration}<=${KPI10b}    Evaluate    ${CaseSUM_KPI10b}+${RATHardReset_duration}
         ...    ELSE    Set Variable    ${CaseSUM_KPI10b}
         ${CaseAVGLoop_KPI10b}    run keyword if    ${RATHardReset_duration}<=${KPI10b}    Evaluate    ${CaseAVGLoop_KPI10b}+${1}
          ...    ELSE    Set Variable    ${CaseAVGLoop_KPI10b}
         Set test Variable    ${CaseSUM_KPI10b}    ${CaseSUM_KPI10b}
         Set test Variable    ${CaseAVGLoop_KPI10b}    ${CaseAVGLoop_KPI10b}

         Log To Console    Check MAXduration
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. trying to commit"|
          ...       awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_startTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_startTime}
         ${MAXduration_startTime}     convert date
         ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. finished with result: Succeeded"|
         ...      awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_endTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_endTime}
         ${MAXduration_endTime}        convert date
         ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}
         Append To List    ${MAXdurationList}    ${MAXduration_duration}
         log to console    ${MAXdurationList}
#         KW.CaseStatusCaluate    duration=${MAXduration_duration}    max=${Max_Duration_of_RAT_Reset}
         run keyword and continue on failure    Should Be True
         ...    ${MAXduration_duration}<=${Max_Duration_of_RAT_Reset} and ${MAXduration_duration}>${0}
         AppendCaseResultToFile   index=${i}   requirement_id=MAXDuration
         ...    target_value=${Max_Duration_of_RAT_Reset}    result_value=${MAXduration_duration}
         Log To Console   MAX duration of RAT reset  is ${MAXduration_duration}
         ${CaseSUM_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_RAT_Reset}
         ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
         ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
         ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_RAT_Reset}
         ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
         Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
         Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}
         Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}

         ${alarm_result}=    KW.GetAndCheckAlarm
         Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
         ...    Please check unexpect Alarm
         ${result1}  set variable if    ${RATHardReset_duration}>${KPI10b}   failed    pass
         ${result2}  set variable if    ${MAXduration_duration}>${Max_Duration_of_RAT_Reset}   failed    pass
         Run Keyword if   '${result1}'!='pass' or '${result2}'!='pass' or '${alarm_result}'=='False'
         ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
         Run Keyword And Continue On Failure    Run keyword if    '${result1}'!='pass' or '${result2}'!='pass'   Fail
         ...    KPI#10b value is above target
         log to console     Case loop ${i+1} END
     END
     Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${RAT_Reset_Times}    OAM_KPI_TARGETS=${KPI_TARGET}
     log to console    ${durationList_KPI10b}
     ${durationLength}=    Get length      ${durationList_KPI10b}
     FOR    ${i}    IN RANGE    0     ${durationLength}
         ${RATHardResetDuration_max}=    set variable if   ${durationList_KPI10b[${i}]}>=${RATHardResetDuration_max}
         ...    ${durationList_KPI10b[${i}]}    ${RATHardResetDuration_max}
         ${RATHardResetDuration_min}=    set variable if   ${durationList_KPI10b[${i}]}<=${RATHardResetDuration_min}
         ...    ${durationList_KPI10b[${i}]}    ${RATHardResetDuration_min}
         ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
         ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
     ${kpi10b_max}    evaluate    round(${RATHardResetDuration_max},2)
     ${kpi10b_min}    evaluate    round(${RATHardResetDuration_min},2)
     ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
     ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
#     ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPI10}    max_loop=${RAT_Reset_Times}
#     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)

     ${kpi10b_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI10b}>0   Evaluate    ${CaseSUM_KPI10b}/${CaseAVGLoop_KPI10b}
     ...      ELSE     set variable    ${3600}
     run keyword and continue on failure    should be true    ${kpi10b_aver_tmp}<=${KPI10b}
     ${kpi10b_aver}    evaluate    round(${kpi10b_aver_tmp},2)

     ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
     ...      ELSE     set variable    ${3600}
     run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_RAT_Reset}
     ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)

     Get common infos    kpi=KPI10b   kpi_max=${kpi10b_max}    kpi_min=${kpi10b_min}    kpi_aver=${kpi10b_aver}
     Get common infos    kpi=MAX_duration_of_RAT_Hard_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}
     set test variable    ${execution_result}    pass

TC.CB008962_SR_C_16_CM_Duration_of_BTS_autonomous_reset_after_plan_activation_KPI12
    [Arguments]   ${ActivePlan_times}=${CASE_INPUT_5GC002479['CB008962_KPI12']['ActivePlan_times']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    True
#    log to console    Disable Graceful Shutdown
#    KW.DisableGracefulCellShutdown
    @{kpiList}  Create List  KPI12
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${ActivePlan_times}
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${RMODsList}       KW.CP_GetRMODsList
    ${AdjRMOD}    Set Variable     AEHC
    ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
    ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
    ...    AdjRMOD=${AdjRMOD}
    ${KPI12_Formula}=    set variable    ${KPIAdjValue['KPI1a']['KPI1a_MAX']}+35
    ${KPI12}=     Evaluate     ${KPI12_Formula}
    &{KPI_TARGET}    Create Dictionary
    Set To Dictionary    ${KPI_TARGET}    kpi12=${KPI12}
#    KW.CaseStatusInit    retry_times=${ActivePlan_times}
    @{durationList}=  Create List
    set test variable    ${duration_min}    5000
    set test variable    ${duration_max}    0
    Set test Variable    ${CaseSUM_KPI12}     ${0}
    Set test Variable    ${CaseAVGLoop_KPI12}     ${0}
    FOR    ${i}    IN RANGE    ${ActivePlan_times}
        KW.CPKPILoopStart
        Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
        Log To Console    Case loop ${i+1}:Step1:Modify parameter which will cause site reset has error when do validation.
        wait until keyword succeeds   15min    10s    COAM_WebEM.Login
        ${actEcpriMplaneIPV6_Value}    selenium_coam.get_parameter_value
        ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate eCPRI Transport with M plane over IPv6   abbr=actEcpriMplaneIPV6
        run keyword if    "${actEcpriMplaneIPV6_Value}"=="false"
        ...   selenium_coam.set_parameter_value
        ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate eCPRI Transport with M plane over IPv6    node_index=${0}
        ...   new_value=true   abbr=actEcpriMplaneIPV6
        ...   ELSE
        ...   selenium_coam.set_parameter_value
        ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate eCPRI Transport with M plane over IPv6    node_index=${0}
        ...   new_value=false   abbr=actEcpriMplaneIPV6
        Log To Console    Case loop ${i+1}:Step2: Validate and check error not exist on WebEM.
        selenium_coam.validate_plan
        ${error}    selenium_coam.get_relation_errors
        Should Be Empty     ${error}
        Log To Console    Case loop ${i+1}:Step3: Do activation
        selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
        ...    timeout=600
        sleep    20s
        run keyword and ignore error    COAM_WebEM.Logout
        wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
        run keyword and ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        Log To Console    Case loop ${i+1}:Step4: Check duration of bts reset after plan_activation
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
        ...       awk '{print $7}'|head -n 1
        ${siteReset_startTime}=     run    command=${cmd}
        Should Not Be Empty    ${siteReset_startTime}
        ${siteReset_startTime}     convert date
        ...    ${siteReset_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
        ...      awk '{print $7}'|tail -n 1
        ${siteReset_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${siteReset_endTime}
        ${siteReset_endTime}        convert date
        ...     ${siteReset_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${siteReset_duration}    Evaluate    ${siteReset_endTime}-${siteReset_startTime}
        Append To List    ${durationList}    ${siteReset_duration}
        log to console    ${durationList}
        Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}
#        KW.CaseStatusCaluate    duration=${siteReset_duration}    max=${KPI12}
        AppendCaseResultToFile    index=${i}    target_value=${KPI12}    result_value=${siteReset_duration}
        ${CaseSUM_KPI12}        run keyword if    ${siteReset_duration}<=${KPI12}    Evaluate    ${CaseSUM_KPI12}+${siteReset_duration}
        ...    ELSE    Set Variable    ${CaseSUM}
        ${CaseAVGLoop_KPI12}    run keyword if    ${siteReset_duration}<=${KPI12}    Evaluate    ${CaseAVGLoop_KPI12}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop}
        Set test Variable    ${CaseSUM_KPI12}    ${CaseSUM_KPI12}
        Set test Variable    ${CaseAVGLoop_KPI12}    ${CaseAVGLoop_KPI12}

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${siteReset_duration}>${KPI12}  failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#12 value is above target
        log to console     Case loop ${i+1} END
    END
#    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI12']['KPI12_AVG']}    max_loop=${ActivePlan_times}
#    set test variable    ${execution_result}    pass
    Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${ActivePlan_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${durationList}
    ${durationLength}=    Get length      ${durationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
    END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${kpi_max}    evaluate    round(${duration_max},2)
    ${kpi_min}    evaluate    round(${duration_min},2)
#    ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI12']['KPI12_AVG']}    max_loop=${ActivePlan_times}
#    ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)

    ${kpi_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI12}>0   Evaluate    ${CaseSUM_KPI12}/${CaseAVGLoop_KPI12}
     ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${kpi_aver_tmp}<=${KPI12}
    ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
    Get common infos    kpi=KPI12_${GracefulCellShutdown}   kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
    set test variable    ${execution_result}    pass

TC.CB010445_SR_C_21_Configuration_plan_activation_With_cell_locking_downtime_KPI15
    [Arguments]   ${Activation_Times_With_Cell_Locking}=${CASE_INPUT_5GC002479['CB010445_HA_KPI15']['Activation_Times_With_Cell_Locking']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    False
    @{kpiList}  Create List  KPI15
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Activation_Times_With_Cell_Locking}
    log to console    Step1:Modify parameter one by one,and check every cell's duration meet target
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
        &{KPI_TARGET}    Create Dictionary
        Set To Dictionary    ${KPI_TARGET}    kpi15=${KPIAdjValue['KPI15']}
        set test variable   ${KPI_TARGET}
        KW.CB010445_SR_C_21_Configuration_plan_activation_With_cell_locking_downtime_KPI15    retry_times=${Activation_Times_With_Cell_Locking}
        ...    KPI15=${KPIAdjValue['KPI15']}    cell_idx=${CELL_INDEX}
#        ...  KPI_TARGET=${KPI_TARGET}
     END
    Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${Activation_Times_With_Cell_Locking}    OAM_KPI_TARGETS=${KPI_TARGET}
    set test variable    ${execution_result}    pass

TC.CB008962_SR_C_17_Site_romote_power_reset_downtime_KPI11
    [Arguments]   ${Remote_Power_reset_times}=${CASE_INPUT_5GC002479['CB008962_HA_KPI11']['Remote_Power_reset_times']}
    ...           ${Max_Duration_of_Remote_Power_Reset}=${SM_04['Max_Duration_of_Remote_Power_Reset']}
    set test variable    ${execution_result}    fail
    Set Test Variable    ${GnbReset}    True
    @{kpiList}  Create List  KPI11
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${Remote_Power_reset_times}
#    ${ValueBase}    KW.GetBaseKPIVaule   TLConfiguration=${CASE_INPUT_5GC002479['TLConfiguration']}
#    set test variable    ${KPI11}    ${ValueBase['KPI11']}
#    log    ${KPI11}
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${RMODsList}       KW.CP_GetRMODsList
    ${AdjRMOD}    Set Variable     AEHC
    ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
    ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
    ...    AdjRMOD=${AdjRMOD}
    ${KPI11_Formula}=    set variable    ${KPIAdjValue['KPI1a']['KPI1a_MAX']}+200
    ${KPI11}=     Evaluate     ${KPI11_Formula}
    &{KPI_TARGET}    Create Dictionary
    Set To Dictionary    ${KPI_TARGET}    kpi11=${KPI11}
#    KW.CaseStatusInit    retry_times=${Remote_Power_reset_times}
    @{durationList}=  Create List
    @{MAXdurationList}=  Create List
    set test variable    ${duration_min}    5000
    set test variable    ${duration_max}    0
    set test variable    ${MAXduration_min}    5000
    set test variable    ${MAXduration_max}    0
    Set test Variable    ${CaseSUM_KPI11}     ${0}
    Set test Variable    ${CaseAVGLoop_KPI11}     ${0}
    Set test Variable    ${CaseSUM_MAXduration}     ${0}
    Set test Variable    ${CaseAVGLoop_MAXduration}    ${0}
    FOR    ${i}    IN RANGE    ${Remote_Power_reset_times}
        KW.CPKPILoopStart
        BtsLog.StartBTSlogCollection
        wait until keyword succeeds   10x   1min    COAM_WebEM.Login    version=${sbts_stream}
        log to console      Step1: Perform remote power reset   --start point
#        Timer.Start
#        ${timestartUTC}   Get Current Date   UTC
        selenium_sbts.power_reset    with_graceful=${False}
        sleep  30s
        run keyword and ignore error    COAM_WebEM.Logout
        log to console      Step2: Wait until all cells are up  -- end point
        wait until keyword succeeds   10x   1min    COAM_Admin.Login
        ${onair_status_Tmp}    Run Keyword And Return Status    Check all cells Should Be On Air
#        ${duration}    Timer.Stop
        run keyword and ignore error    COAM_Admin.Logout
        run keyword and ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}

        Log To Console    Case loop ${i+1}:Step3: Check duration of KPI#11
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
        ...       awk '{print $7}'|head -n 1
        ${timestart}=     run    command=${cmd}
        Should Not Be Empty    ${timestart}
        ${timestart}    convert date
        ...    ${timestart.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
        ...      awk '{print $7}'|tail -n 1
        ${timeend}=     run    command=${cmd}
        Should Not Be Empty     ${timeend}
        ${timeend}        convert date
        ...     ${timeend.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${duration}    Evaluate    ${timeend}-${timestart}
        Append To List    ${durationList}    ${duration}
        log to console    ${durationList}
        Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}
#        KW.CaseStatusCaluate    duration=${duration}    max=${KPI11}
        run keyword and continue on failure    Should Be True
        ...    ${duration}<=${KPI11} and ${duration}>${0}
        AppendCaseResultToFile    target_value=${KPI11}    result_value=${duration}
        Log To Console    Remote power reset duration is ${duration}
        ${CaseSUM_KPI11}        run keyword if    ${duration}<=${KPI11}    Evaluate    ${CaseSUM_KPI11}+${duration}
        ...    ELSE    Set Variable    ${CaseSUM}
        ${CaseAVGLoop_KPI11}    run keyword if    ${duration}<=${KPI11}    Evaluate    ${CaseAVGLoop_KPI11}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop}
        Set test Variable    ${CaseSUM_KPI11}    ${CaseSUM_KPI11}
        Set test Variable    ${CaseAVGLoop_KPI11}    ${CaseAVGLoop_KPI11}

        Log To Console    Check MAXduration of remote power reset
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.* trying to commit"|
          ...       awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_startTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_startTime}
         ${MAXduration_startTime}     convert date
         ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.*"| grep "trying to remove"|
         ...      awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_endTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_endTime}
         ${MAXduration_endTime}        convert date
         ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}
         Append To List    ${MAXdurationList}    ${MAXduration_duration}
         log to console    ${MAXdurationList}
         run keyword and continue on failure    Should Be True
         ...    ${MAXduration_duration}<=${Max_Duration_of_Remote_Power_Reset} and ${MAXduration_duration}>${0}
         AppendCaseResultToFile    requirement_id=MAXDuration
         ...    target_value=${Max_Duration_of_Remote_Power_Reset}    result_value=${MAXduration_duration}
         Log To Console   MAX duration of remote power reset is ${MAXduration_duration}
         ${CaseSUM_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_Remote_Power_Reset}
         ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
         ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
         ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_Remote_Power_Reset}
         ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
         Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
         Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}
        log to console     Case loop ${i+1} END

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result1}	  Set Variable If	  "${onair_status_Tmp}"=="True" and ${duration}<=${KPI11} 	    pass      fail
        ${result2}    set variable if   ${MAXduration_duration}<=${Max_Duration_of_Remote_Power_Reset}   pass      fail
        Run Keyword if   '${result1}'!='pass' or '${result2}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${result1}'!='pass' or '${result2}'!='pass'    Fail
        ...    KPI#11 value is above target
    END
#    set test variable    ${execution_result}    pass
    Run Keyword And Ignore error    KW.CPKPICaseEnd    times=${Remote_Power_reset_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${durationList}
    log to console    ${MAXdurationList}
    ${durationLength}=    Get length      ${durationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
         ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
         ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
    END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${kpi_max}    evaluate    round(${duration_max},2)
    ${kpi_min}    evaluate    round(${duration_min},2)
    ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
    ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
#    ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPI11}    max_loop=${Remote_Power_reset_times}
    ${kpi_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI11}>0   Evaluate    ${CaseSUM_KPI11}/${CaseAVGLoop_KPI11}
     ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${kpi_aver_tmp}<=${KPI11}
    ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
    ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
     ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_Remote_Power_Reset}
    ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)
    Get common infos    kpi=KPI11_${GracefulCellShutdown}   kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
    Get common infos    kpi=Max_Duration_of_Remote_Power_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}
    set test variable    ${execution_result}    pass

TC.CB009402_SR_A_45_Max_Duration_of_ALD_Reset
    [Arguments]   ${ALD_reset_times}=${CASE_INPUT_5GC002479['CB009402_HA_Max_Duration_of_ALD_Reset']['ALD_Reset_Times']}
    ...           ${Max_Duration_of_ALD_Reset}=${SM_05['Max_Duration_of_ALD_Reset']}
    set test variable    ${execution_result}    fail
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    KW.CaseStatusInit    retry_times=${ALD_reset_times}
    Set Test Variable    ${GnbReset}    False
    @{MAXdurationList}=  Create List
    set test variable    ${MAXduration_min}    5000
    set test variable    ${MAXduration_max}    0
    Set test Variable    ${CaseSUM_MAXduration}     ${0}
    Set test Variable    ${CaseAVGLoop_MAXduration}    ${0}
    FOR    ${i}    IN RANGE    ${ALD_reset_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        Log To Console    Case loop ${i+1}:Step1: Reset ALD
        wait until keyword succeeds   10x   1min    COAM_WebEM.Login
        selenium_coam.reset_ald    reset_type=software
        sleep    130s
        COAM_WebEM.Logout
        Run Keyword And Ignore error       Stop BTSlogs Collection and get logs for every loop     loop=${ALD_reset_times}
        Log To Console    Case loop ${i+1}:Step2: Check duration of ALD reset
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.* trying to commit"|
        ...       awk '{print $7}'|head -n 1|tail -1
        ${MAXduration_startTime}=     run    command=${cmd}
        Should Not Be Empty     ${MAXduration_startTime}
        ${MAXduration_startTime}     convert date
        ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.* finished with result: Succeeded"|
        ...      awk '{print $7}'|head -n 1|tail -1
        ${MAXduration_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${MAXduration_endTime}
        ${MAXduration_endTime}        convert date
        ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}
        Append To List    ${MAXdurationList}    ${MAXduration_duration}
        log to console    ${MAXdurationList}
        run keyword and continue on failure    Should Be True
         ...    ${MAXduration_duration}<=${Max_Duration_of_ALD_Reset} and ${MAXduration_duration}>${0}
        AppendCaseResultToFile    index=1   target_value=${Max_Duration_of_ALD_Reset}    result_value=${MAXduration_duration}
        Log To Console   MAX duration of ALD reset  is ${MAXduration_duration}
        ${CaseSUM_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_ALD_Reset}
        ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
        ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
        ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_ALD_Reset}
        ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
        Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
        Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}
        log to console     Case loop ${i+1} END
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${MAXduration_duration}>${Max_Duration_of_ALD_Reset}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI value is above target
        log to console     Case loop ${i+1} END
    END
    ${durationLength}=    Get length      ${MAXdurationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
         ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
    END
    ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
    ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
    ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_ALD_Reset}
    ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)
    Get common infos    kpi=MAX_duration_of_ALD_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}
    set test variable    ${execution_result}    pass

TC.CB013276_SR_A_53_Max_Duration_of_GNSSE_Reset
    [Arguments]   ${GNSSE_reset_times}=${CASE_INPUT_5GC002479['CB013276_HA_Max_Duration_of_GNSSE_Reset']['GNSSE_Reset_Times']}
    ...           ${Max_Duration_of_GNSSE_Reset}=${SM_09['Max_Duration_of_GNSSE_Reset']}
    set test variable    ${execution_result}    fail
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    KW.CaseStatusInit    retry_times=${GNSSE_reset_times}
    Set Test Variable    ${GnbReset}    False
    @{MAXdurationList}=  Create List
    set test variable    ${MAXduration_min}    5000
    set test variable    ${MAXduration_max}    0
    Set test Variable    ${CaseSUM_MAXduration}     ${0}
    Set test Variable    ${CaseAVGLoop_MAXduration}    ${0}
    FOR    ${i}    IN RANGE    ${GNSSE_reset_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        Log To Console    Case loop ${i+1}:Step1: Reset GNSSE
        wait until keyword succeeds   10x   1min    COAM_WebEM.Login
        selenium_sbts.reset_gnss
        sleep    130s
        COAM_WebEM.Logout
        Run Keyword And Ignore error       Stop BTSlogs Collection and get logs for every loop     loop=${GNSSE_reset_times}
        Log To Console    Case loop ${i+1}:Step2: Check duration of GNSSE reset
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.* trying to commit"|
        ...       awk '{print $7}'|head -n 1|tail -1
        ${MAXduration_startTime}=     run    command=${cmd}
        Should Not Be Empty     ${MAXduration_startTime}
        ${MAXduration_startTime}     convert date
        ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.* finished with result: Succeeded"|
        ...      awk '{print $7}'|head -n 1|tail -1
        ${MAXduration_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${MAXduration_endTime}
        ${MAXduration_endTime}        convert date
        ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}
        Append To List    ${MAXdurationList}    ${MAXduration_duration}
        log to console    ${MAXdurationList}
        run keyword and continue on failure    Should Be True
         ...    ${MAXduration_duration}<=${Max_Duration_of_GNSSE_Reset} and ${MAXduration_duration}>${0}
        AppendCaseResultToFile    index=1   target_value=${Max_Duration_of_GNSSE_Reset}    result_value=${MAXduration_duration}
        Log To Console   MAX duration of GNSSE reset  is ${MAXduration_duration}
        ${CaseSUM_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_GNSSE_Reset}
        ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
        ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
        ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_GNSSE_Reset}
        ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
        Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
        Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}
        log to console     Case loop ${i+1} END
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${MAXduration_duration}>${Max_Duration_of_GNSSE_Reset}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI value is above target
        log to console     Case loop ${i+1} END
    END
    ${durationLength}=    Get length      ${MAXdurationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
         ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
    END
    ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
    ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
    ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_GNSSE_Reset}
    ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)
    Get common infos    kpi=MAX_duration_of_GNSSE_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}
    set test variable    ${execution_result}    pass

TC.CB009199_SR_C_18_SW_rollback_downtime_Manually_Triggered_KPI13
     [Arguments]   ${SW_rollback_times}=${CASE_INPUT_5GC002479['CB009199_HA_KPI13']['SW_rollback_times']}
    set test variable    ${execution_result}    fail
    set test variable    ${GnbReset}    True
    @{kpiList}  Create List  KPI13
    set test variable  ${kpiList}
    KW.CPKPICaseStart    KPIsList=${kpiList}    retry_times=${SW_rollback_times}
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${RMODsList}       KW.CP_GetRMODsList
    ${AdjRMOD}    Set Variable     AEHC
    ${SFPCooledInfo}      KW.GetSFPCooledInfoOnSite
    ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODsList}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
    ...    AdjRMOD=${AdjRMOD}
    ${KPI13_Formula}=    set variable    ${KPIAdjValue['KPI2c']['KPI2c_AVG']}+30
    ${KPI13}=     Evaluate     ${KPI13_Formula}
    &{KPI_TARGET}    Create Dictionary
    Set To Dictionary    ${KPI_TARGET}    kpi13=${KPI13}
#    KW.CaseStatusInit    retry_times=${SW_rollback_times}
    @{durationList}=  Create List
    set test variable    ${duration_min}    5000
    set test variable    ${duration_max}    0
    Set test Variable    ${CaseSUM_KPI13}     ${0}
    Set test Variable    ${CaseAVGLoop_KPI13}     ${0}
    FOR    ${i}    IN RANGE    ${SW_rollback_times}
        KW.CPKPILoopStart
        Log To Console    Case loop ${i+1}:Step1: Trigger SW rollback via WebEM
        BtsLog.StartBTSlogCollection
        rollback site
        wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
        run keyword and ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        Log To Console    Case loop ${i+1}:Step2: Check SW rollback duration from syslog
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
        ...       awk '{print $7}'|head -n 1
        ${SWRollback_startTime}=     run    command=${cmd}
        Should Not Be Empty     ${SWRollback_startTime}
        ${SWRollback_startTime}     convert date
        ...    ${SWRollback_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
        ...      awk '{print $7}'|tail -n 1
        ${SWRollback_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${SWRollback_endTime}
        ${SWRollback_endTime}        convert date
        ...     ${SWRollback_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${SWRollback_duration_KPI13}    Evaluate    ${SWRollback_endTime}-${SWRollback_startTime}
        Append To List    ${durationList}    ${SWRollback_duration_KPI13}
        log to console    ${durationList}
#        KW.CPKPILoopEnd    loop=${i}   needprevIMS=true

#        KW.CaseStatusCaluate    duration=${SWRollback_duration_KPI13}    max=${KPIAdjValue['KPI13']['KPI13_MAX']}
        AppendCaseResultToFile    index=${i}    target_value=${KPI13}    result_value=${SWRollback_duration_KPI13}
#        Log To Console    Case loop ${i+1}:Step3: SW rollback duration is  ${SWRollback_duration_KPI13}

        ${CaseSUM_KPI13}        run keyword if    ${SWRollback_duration_KPI13}<=${KPI13}    Evaluate    ${CaseSUM_KPI13}+${SWRollback_duration_KPI13}
        ...    ELSE    Set Variable    ${CaseSUM}
        ${CaseAVGLoop_KPI13}    run keyword if    ${SWRollback_duration_KPI13}<=${KPI13}    Evaluate    ${CaseAVGLoop_KPI13}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop}
        Set test Variable    ${CaseSUM_KPI13}    ${CaseSUM_KPI13}
        Set test Variable    ${CaseAVGLoop_KPI13}    ${CaseAVGLoop_KPI13}

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${SWRollback_duration_KPI13}>${KPI13}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#13 value is above target
#        log to console    Case loop ${i+1}:duration of SW Rollback is ${SWRollback_duration_KPI13}
        wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
        log to console    Case loop ${i+1} END
    END
#    KW.CPKPICaseEnd    times=${SW_rollback_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${durationList}
    ${durationLength}=    Get length      ${durationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
    END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${kpi_max}    evaluate    round(${duration_max},2)
    ${kpi_min}    evaluate    round(${duration_min},2)
#    ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPIAdjValue['KPI13']['KPI13_AVG']}    max_loop=${SW_rollback_times}
#    ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
    ${kpi_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI13}>0    Evaluate    ${CaseSUM_KPI13}/${CaseAVGLoop_KPI13}
     ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${kpi_aver_tmp}<=${KPI13}
    ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)

    Get common infos    kpi=KPI13  kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
    set test variable    ${execution_result}    pass

TC.CB008681_SR_C_01_Energy_Consumption_Measurements
    [Documentation]   OM_GEN_SFS_PERF_CAP.24465
    ...  Purpose:Aim to test Energy measurement after site reset
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: Login WebEM online modify parameters to enable energy consumption counters for M40002, M40003 and M40004
    ...    Step2: Do site reset and waiting for one reporting interval
    ...    Step3: Check counter for Energy measurement M40002, M40003 and M40004
    ...    Checkpoint configuration:
    log to console    Step1: Login WebEM online modify parameters to enable energy consumption counters
    set test variable    ${execution_result}    fail
    BtsLog.StartBTSlogCollection
    KW.EnableEnergyConsumptionMeasurement
    log to console    Step2: waiting for one reporting interval
    sleep    ${PMTIME}min
    log to console    Step3: Check counter for Energy measurement M40002, M40003 and M40004
    @{BTS_COUNTER}    Create List    M40002C0  M40002C1  M40002C2
    @{BTSRFM_COUNTER}    Create List    M40003C0  M40003C1  M40003C2  M40003C3  M40003C4  M40003C5
    @{BTSSM_COUNTER}    Create List    M40004C0  M40004C1  M40004C2  M40004C3  M40004C4  M40004C5
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    KW.FetchCounter    @{BTS_COUNTER}
    KW.FetchCounter    @{BTSSM_COUNTER}
    KW.FetchCounter    @{BTSRFM_COUNTER}
    run keyword and ignore error    COAM_WebEM.Logout
    set test variable    ${execution_result}    pass

KW.CB010445_SR_C_21_Configuration_plan_activation_With_cell_locking_downtime_KPI15
    [Arguments]      ${KPI15}  ${retry_times}  ${cell_idx}=1
#    KW.CaseStatusInit    retry_times=${retry_times}
    set test variable    ${CasePassRateStatus}     NotExecute
    set test variable    ${CaseAVGLoop_celllocking}     ${0}
    set test variable    ${CaseSUM_celllocking}         ${0}
    @{CellLockinglList}=  Create List
    set test variable    ${CellLockingDuration_Min}    5000
    set test variable    ${CellLockingDuration_Max}    0
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        Log To Console    Case loop ${i+1}:Step1:Modify parameter with the Modification attribute 'Requires object locking'
        Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
        wait until keyword succeeds   15min    10s    COAM_WebEM.Login
        ${pMax_Value_tmp}    selenium_sbts.get_parameter_value
        ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_idx}     filter_param=Maximum output power    abbr=pMax
        log to console    ${pMax_Value_tmp}
        ${pMax_Value}=   Get Substring    ${pMax_Value_tmp}    0    2
        ${pMax_Value_new}    Evaluate      ${pMax_Value}-1
        log to console    ${pMax_Value_new}
        selenium_sbts.set_parameter_value
        ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_idx}    filter_param=Maximum output power    node_index=${0}
        ...    new_value=${pMax_Value_new}   abbr=pMax
        Log To Console    Case loop ${i+1}:Step2: Validate and check error not exist on WebEM.
        selenium_sbts.validate_plan
        ${error}    selenium_sbts.get_relation_errors
        Should Be Empty     ${error}
        Log To Console    Case loop ${i+1}:Step3: Do activation
        selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
        sleep    20s
        run keyword and ignore error    COAM_WebEM.Logout
        wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
        run keyword and ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}

        Log To Console    Case loop ${i+1}:Step4: Check the configuration plan activation with cell locking downtime
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
        ...       awk '{print $7}'|head -n 1
        ${startTime}=     run    command=${cmd}
        Should Not Be Empty    ${startTime}
        ${startTime}     convert date
        ...    ${startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
        ...      awk '{print $7}'|tail -n 1
        ${endTime}=     run    command=${cmd}
        Should Not Be Empty     ${endTime}
        ${endTime}        convert date
        ...     ${endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${duration}    Evaluate    ${endTime}-${startTime}
        Append To List    ${CellLockinglList}    ${duration}
        log to console    ${CellLockinglList}
        Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}
        run keyword and continue on failure    Should Be True
        ...    ${duration}<=${KPI15} and ${duration}>${0}

        ${CaseSUM_celllocking}        run keyword if    ${duration}<=${KPI15}    Evaluate    ${CaseSUM_celllocking}+${duration}
        ...    ELSE    Set Variable    ${CaseSUM_celllocking}
        ${CaseAVGLoop_celllocking}    run keyword if    ${duration}<=${KPI15}    Evaluate    ${CaseAVGLoop_celllocking}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_celllocking}
        Set test Variable    ${CaseSUM_celllocking}    ${CaseSUM_celllocking}
        Set test Variable    ${CaseAVGLoop_celllocking}    ${CaseAVGLoop_celllocking}

        AppendCaseResultToFile    index=NRCELL_${cell_idx}
        ...    target_value=${KPI15}   result_value=${duration}
        log to console    ${CellLockinglList}
        log to console     Case loop ${i+1} END
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${duration}>${KPI15}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#15 value is above target

        Log To Console    Case loop ${i+1}:Step5: recovery pMax value
        KW.RecoverypMaxValue  cell_idx=${cell_idx}    pMaxValue=${pMax_Value}
    END
#    KW.CPKPICaseEnd    times=${retry_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    ${durationLength}=    Get length      ${CellLockinglList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
        ${CellLockingDuration_Max}=    set variable if   ${CellLockinglList[${i}]}>=${CellLockingDuration_Max}
        ...    ${CellLockinglList[${i}]}    ${CellLockingDuration_Max}
        ${CellLockingDuration_Min}=    set variable if   ${CellLockinglList[${i}]}<=${CellLockingDuration_Min}
        ...    ${CellLockinglList[${i}]}    ${CellLockingDuration_Min}
    END
    ${CellLockingKpi_Max}    evaluate    round(${CellLockingDuration_Max},2)
    ${CellLockingKpi_Min}    evaluate    round(${CellLockingDuration_Min},2)
    ${CellLockingKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_celllocking}>0   Evaluate    ${CaseSUM_celllocking}/${CaseAVGLoop_celllocking}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${CellLockingKpi_aver_tmp}<=${KPI15}
    ${CellLockingKpi_aver}    evaluate    round(${CellLockingKpi_aver_tmp},2)
    Get common infos    kpi=KPI15_Cell_${cell_idx}   kpi_max=${CellLockingKpi_Max}    kpi_min=${CellLockingKpi_Min}
    ...    kpi_aver=${CellLockingKpi_aver}
    set test variable    ${execution_result}    pass

KW.RecoverypMaxValue
    [Arguments]     ${cell_idx}    ${pMaxValue}
    Log To Console    Set recovery pMax vaule
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_idx}    filter_param=Maximum output power    node_index=${0}
    ...    new_value=${pMaxValue}   abbr=pMax
    Log To Console    Validate and check error not exist on WebEM.
    selenium_coam.validate_plan
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty     ${error}
    Log To Console    Do activation
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    sleep    20s
    run keyword and ignore error    COAM_WebEM.Logout
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair

KW.CB008181_SR_C_09_Cell_lock_unlock_duration_KPI16a_KPI16b
    [Arguments]     ${retry_times}  ${CellLockDuration}    ${CellUnlockDuration}   ${cell_idx}=1
#    KW.CaseStatusInit    retry_times=${retry_times}
    set test variable    ${CasePassRateStatus}     NotExecute
    set test variable    ${CaseAVGLoop_lockcell}     ${0}
    set test variable    ${CaseSUM_lockcell}         ${0}
    set test variable    ${CaseAVGLoop_unlockcell}     ${0}
    set test variable    ${CaseSUM_unlockcell}        ${0}
    @{LockCellDurationList}=  Create List
    @{UnlockCellDurationList}=  Create List
    set test variable    ${LockCellDuration_Min}    5000
    set test variable    ${LockCellDuration_Max}    0
    set test variable    ${UnlockCellDuration_Min}    5000
    set test variable    ${UnlockCellDuration_Max}    0
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        log to console    Case loop ${i+1}:Step1: Trigger cell lock and start BTSLog
        BtsLog.StartBTSlogCollection
        wait until keyword succeeds   15min    10s    COAM_WebEM.Login
        wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=lock    checkstatus=false
        sleep    40s
        COAM_WebEM.Logout
        run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
        Log To Console    Case loop ${i+1}:Step2: Check lock cell_duration
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "processNewActivationRequest: activation started"|
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
        Append To List    ${LockCellDurationList}    ${lockcell_duration}
        log to console    ${LockCellDurationList}
        run keyword and continue on failure    Should Be True
        ...    ${lockcell_duration}<=${CellLockDuration} and ${lockcell_duration}>${0}
        log to console   lock cell duration is ${lockcell_duration}
    #    KW.CaseStatusCaluate    duration=${lockcell_duration}    max=${CellLockDuration}
        ${CaseSUM_lockcell}      run keyword if    ${lockcell_duration}<=${CellLockDuration}    Evaluate    ${CaseSUM_lockcell}+${lockcell_duration}
        ...    ELSE    Set Variable    ${CaseSUM_lockcell}
        ${CaseAVGLoop_lockcell}    run keyword if    ${lockcell_duration}<=${CellLockDuration}    Evaluate    ${CaseAVGLoop_lockcell}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_lockcell}
        Set test Variable    ${CaseSUM_lockcell}    ${CaseSUM_lockcell}
        Set test Variable    ${CaseAVGLoop_lockcell}    ${CaseAVGLoop_lockcell}

        log to console    Case loop ${i+1}:Step3: Trigger cell unlock and start BTSLog
        BtsLog.StartBTSlogCollection
        COAM_WebEM.Login
        wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=unlock    checkstatus=false
#        sleep    40s
        COAM_WebEM.Logout
        wait until keyword succeeds    5min    10s     COAM_Admin.CheckAllCellsOnair
        run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
        Log To Console    Case loop ${i+1}:Step4: Check unlock cell_duration
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "processNewActivationRequest: activation started"|
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
        Append To List    ${UnlockCellDurationList}    ${unlockcell_duration}
        log to console    ${UnlockCellDurationList}
        run keyword and continue on failure    Should Be True
        ...    ${unlockcell_duration}<=${CellUnlockDuration} and ${unlockcell_duration}>${0}
        log to console   unlock cell duration is ${unlockcell_duration}
        KW.CPKPILoopEnd    loop=${i}
    #    KW.CaseStatusCaluate    duration=${unlockcell_duration}    max=${CellUnlockDuration}
        ${CaseSUM_unlockcell}        run keyword if    ${unlockcell_duration}<=${CellUnlockDuration}
        ...    Evaluate    ${CaseSUM_unlockcell}+${unlockcell_duration}
        ...    ELSE    Set Variable    ${CaseSUM_unlockcell}
        ${CaseAVGLoop_unlockcell}    run keyword if    ${unlockcell_duration}<=${CellUnlockDuration}
        ...    Evaluate    ${CaseAVGLoop_unlockcell}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_unlockcell}
        Set test Variable    ${CaseSUM_unlockcell}    ${CaseSUM_unlockcell}
        Set test Variable    ${CaseAVGLoop_unlockcell}    ${CaseAVGLoop_unlockcell}

        AppendCaseResultToFile    index=NRCELL_${cell_idx}_lock
        ...    target_value=${CellLockDuration}    result_value=${lockcell_duration}
        AppendCaseResultToFile    index=NRCELL_${cell_idx}_unlock
        ...    target_value=${CellUnlockDuration}    result_value=${unlockcell_duration}
        log to console     Case loop ${i+1} END

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result1}  set variable if    ${unlockcell_duration}>${CellUnlockDuration}   failed    pass
        ${result2}  set variable if    ${lockcell_duration}>${CellLockDuration}   failed    pass
         Run Keyword if   '${result1}'!='pass' or '${result2}'!='pass' or '${alarm_result}'=='False'
         ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for cell    loop=${i+1}    index=${cell_idx}
         Run Keyword And Continue On Failure    Run keyword if    '${result1}'!='pass' or '${result2}'!='pass'   Fail
        ...    KPI#16 value is above target
    END
#    KW.CPKPICaseEnd    times=${retry_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${LockCellDurationList}
    log to console    ${UnlockCellDurationList}
    ${durationLength}=    Get length      ${LockCellDurationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
        ${LockCellDuration_Max}=    set variable if   ${LockCellDurationList[${i}]}>=${LockCellDuration_Max}
        ...    ${LockCellDurationList[${i}]}    ${LockCellDuration_Max}
        ${LockCellDuration_Min}=    set variable if   ${LockCellDurationList[${i}]}<=${LockCellDuration_Min}
        ...    ${LockCellDurationList[${i}]}    ${LockCellDuration_Min}
        ${UnlockCellDuration_Max}=    set variable if   ${UnlockCellDurationList[${i}]}>=${UnlockCellDuration_Max}
        ...    ${UnlockCellDurationList[${i}]}    ${UnlockCellDuration_Max}
        ${UnlockCellDuration_Min}=    set variable if   ${UnlockCellDurationList[${i}]}<=${UnlockCellDuration_Min}
        ...    ${UnlockCellDurationList[${i}]}    ${UnlockCellDuration_Min}
    END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${LockCellKpi_Max}    evaluate    round(${LockCellDuration_Max},2)
    ${LockCellKpi_Min}    evaluate    round(${LockCellDuration_Min},2)
    ${UnlockCellKpi_Max}    evaluate    round(${UnlockCellDuration_Max},2)
    ${UnlockCellKpi_Min}    evaluate    round(${UnlockCellDuration_Min},2)
#    ${LockCellKpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${CellLockDuration}   max_loop=1
    ${LockCellKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_lockcell}>0   Evaluate    ${CaseSUM_lockcell}/${CaseAVGLoop_lockcell}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${LockCellKpi_aver_tmp}<=${CellLockDuration}
    ${LockCellKpi_aver}    evaluate    round(${LockCellKpi_aver_tmp},2)
#    ${UnlockCellKpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${CellUnlockDuration}   max_loop=1
    ${UnlockCellKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_unlockcell}>0   Evaluate    ${CaseSUM_unlockcell}/${CaseAVGLoop_unlockcell}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${UnlockCellKpi_aver_tmp}<=${CellUnlockDuration}
    ${UnlockCellKpi_aver}    evaluate    round(${UnlockCellKpi_aver_tmp},2)
    Get common infos    kpi=KPI16a_Cell_${cell_idx}   kpi_max=${LockCellKpi_Max}    kpi_min=${LockCellKpi_Min}    kpi_aver=${LockCellKpi_aver}
    Get common infos    kpi=KPI16b_Cell_${cell_idx}   kpi_max=${UnlockCellKpi_Max}    kpi_min=${UnlockCellKpi_Min}    kpi_aver=${UnlockCellKpi_aver}

KW.CB008181_SR_C_09_Cell_lock_duration_KPI16a
    [Arguments]     ${retry_times}   ${CellLockDuration}  ${cell_idx}=1
#    KW.CaseStatusInit    retry_times=${retry_times}
    set test variable    ${CasePassRateStatus}     NotExecute
    set test variable    ${CaseAVGLoop_lockcell}     ${0}
    set test variable    ${CaseSUM_lockcell}         ${0}
    @{LockCellDurationList}=  Create List
    set test variable    ${LockCellDuration_Min}    5000
    set test variable    ${LockCellDuration_Max}    0
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        log to console    Case loop ${i+1}:Step1: Trigger cell lock and start BTSLog
        BtsLog.StartBTSlogCollection
        wait until keyword succeeds   15min    10s    COAM_WebEM.Login
        wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=lock    checkstatus=false
        sleep    40s
        run keyword and ignore error    COAM_WebEM.Logout
        run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog

        Log To Console    Case loop ${i+1}:Step2: Recovery cell to unlock
        COAM_WebEM.Login
        wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=unlock    checkstatus=false
        sleep    10s
        run keyword and ignore error    COAM_WebEM.Logout
        wait until keyword succeeds    5min    10s     COAM_Admin.CheckAllCellsOnair

        Log To Console    Case loop ${i+1}:Step3: Check lock cell_duration
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "processNewActivationRequest: activation started"|
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
        Append To List    ${LockCellDurationList}    ${lockcell_duration}
        log to console    ${LockCellDurationList}
        run keyword and continue on failure    Should Be True
        ...    ${lockcell_duration}<=${CellLockDuration} and ${lockcell_duration}>${0}
        log to console   lock cell duration is ${lockcell_duration}
    #    KW.CaseStatusCaluate    duration=${lockcell_duration}    max=${CellLockDuration}
        Run Keyword And Ignore error     KW.CPKPILoopEnd    loop=${i}

        ${CaseSUM_lockcell}      run keyword if    ${lockcell_duration}<=${CellLockDuration}    Evaluate    ${CaseSUM_lockcell}+${lockcell_duration}
        ...    ELSE    Set Variable    ${CaseSUM_lockcell}
        ${CaseAVGLoop_lockcell}    run keyword if    ${lockcell_duration}<=${CellLockDuration}    Evaluate    ${CaseAVGLoop_lockcell}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_lockcell}
        Set test Variable    ${CaseSUM_lockcell}    ${CaseSUM_lockcell}
        Set test Variable    ${CaseAVGLoop_lockcell}    ${CaseAVGLoop_lockcell}

        AppendCaseResultToFile    index=NRCELL_${cell_idx}_lock
        ...    target_value=${CellLockDuration}    result_value=${lockcell_duration}
        log to console     Case loop ${i+1} END

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${lockcell_duration}>${CellLockDuration}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for cell    loop=${i+1}    index=${cell_idx}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#16a value is above target
    END
#    KW.CPKPICaseEnd    times=${retry_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${LockCellDurationList}
    ${durationLength}=    Get length      ${LockCellDurationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
        ${LockCellDuration_Max}=    set variable if   ${LockCellDurationList[${i}]}>=${LockCellDuration_Max}
        ...    ${LockCellDurationList[${i}]}    ${LockCellDuration_Max}
        ${LockCellDuration_Min}=    set variable if   ${LockCellDurationList[${i}]}<=${LockCellDuration_Min}
        ...    ${LockCellDurationList[${i}]}    ${LockCellDuration_Min}
    END
    ${LockCellKpi_Max}    evaluate    round(${LockCellDuration_Max},2)
    ${LockCellKpi_Min}    evaluate    round(${LockCellDuration_Min},2)
    ${LockCellKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_lockcell}>0   Evaluate    ${CaseSUM_lockcell}/${CaseAVGLoop_lockcell}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${LockCellKpi_aver_tmp}<=${CellLockDuration}
    ${LockCellKpi_aver}    evaluate    round(${LockCellKpi_aver_tmp},2)
    Get common infos    kpi=KPI16a_Cell_${cell_idx}   kpi_max=${LockCellKpi_Max}    kpi_min=${LockCellKpi_Min}    kpi_aver=${LockCellKpi_aver}

KW.CB008181_SR_C_10_Cell_unlock_duration_KPI16b
    [Arguments]     ${retry_times}   ${CellUnlockDuration}  ${cell_idx}=1
#    KW.CaseStatusInit    retry_times=${retry_times}
    set test variable    ${CasePassRateStatus}     NotExecute
    set test variable    ${CaseAVGLoop_unlockcell}     ${0}
    set test variable    ${CaseSUM_unlockcell}        ${0}
    @{UnlockCellDurationList}=  Create List
    set test variable    ${UnlockCellDuration_Min}    5000
    set test variable    ${UnlockCellDuration_Max}    0
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        log to console    Case loop ${i+1}:Step1: Trigger cell lock
        wait until keyword succeeds   15min    10s    COAM_WebEM.Login
        wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=lock    checkstatus=false
        sleep    20s
        COAM_WebEM.Logout

        log to console    Case loop ${i+1}:Step2: Trigger cell unlock and start BTSLog
        BtsLog.StartBTSlogCollection
        COAM_WebEM.Login
        wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=unlock    checkstatus=false
#        sleep    40s
        COAM_WebEM.Logout
        wait until keyword succeeds    5min    10s     COAM_Admin.CheckAllCellsOnair
        run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
        Log To Console    Case loop ${i+1}:Step3: Check unlock cell_duration
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "processNewActivationRequest: activation started"|
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
        Append To List    ${UnlockCellDurationList}    ${unlockcell_duration}
        log to console    ${UnlockCellDurationList}
        run keyword and continue on failure    Should Be True
        ...    ${unlockcell_duration}<=${CellUnlockDuration} and ${unlockcell_duration}>${0}
        log to console   unlock cell duration is ${unlockcell_duration}
        Run Keyword And Ignore error     KW.CPKPILoopEnd    loop=${i}

    #    KW.CaseStatusCaluate    duration=${unlockcell_duration}    max=${CellUnlockDuration}
        ${CaseSUM_unlockcell}        run keyword if    ${unlockcell_duration}<=${CellUnlockDuration}
        ...    Evaluate    ${CaseSUM_unlockcell}+${unlockcell_duration}
        ...    ELSE    Set Variable    ${CaseSUM_unlockcell}
        ${CaseAVGLoop_unlockcell}    run keyword if    ${unlockcell_duration}<=${CellUnlockDuration}
        ...    Evaluate    ${CaseAVGLoop_unlockcell}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_unlockcell}
        Set test Variable    ${CaseSUM_unlockcell}    ${CaseSUM_unlockcell}
        Set test Variable    ${CaseAVGLoop_unlockcell}    ${CaseAVGLoop_unlockcell}

        AppendCaseResultToFile    index=NRCELL_${cell_idx}_unlock
        ...    target_value=${CellUnlockDuration}    result_value=${unlockcell_duration}
        log to console     Case loop ${i+1} END

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${unlockcell_duration}>${CellUnlockDuration}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for cell    loop=${i+1}    index=${cell_idx}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#16b value is above target
    END
    log to console    ${UnlockCellDurationList}
    ${durationLength}=    Get length      ${UnlockCellDurationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
        ${UnlockCellDuration_Max}=    set variable if   ${UnlockCellDurationList[${i}]}>=${UnlockCellDuration_Max}
        ...    ${UnlockCellDurationList[${i}]}    ${UnlockCellDuration_Max}
        ${UnlockCellDuration_Min}=    set variable if   ${UnlockCellDurationList[${i}]}<=${UnlockCellDuration_Min}
        ...    ${UnlockCellDurationList[${i}]}    ${UnlockCellDuration_Min}
    END
    ${UnlockCellKpi_Max}    evaluate    round(${UnlockCellDuration_Max},2)
    ${UnlockCellKpi_Min}    evaluate    round(${UnlockCellDuration_Min},2)
    ${UnlockCellKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_unlockcell}>0   Evaluate    ${CaseSUM_unlockcell}/${CaseAVGLoop_unlockcell}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${UnlockCellKpi_aver_tmp}<=${CellUnlockDuration}
    ${UnlockCellKpi_aver}    evaluate    round(${UnlockCellKpi_aver_tmp},2)
    Get common infos    kpi=KPI16b_Cell_${cell_idx}   kpi_max=${UnlockCellKpi_Max}    kpi_min=${UnlockCellKpi_Min}    kpi_aver=${UnlockCellKpi_aver}

KW.CB009402_SR_C_20_Cell_reset_downtime_Manually_Triggered_KPI19
    [Arguments]      ${retry_times}   ${ResetCellDuration}   ${Max_Duration_of_Cell_Reset}   ${cell_idx}=1
#    KW.CaseStatusInit    retry_times=${retry_times}
    set test variable    ${CasePassRateStatus}     NotExecute
    set test variable    ${CaseAVGLoop_resetcell}     ${0}
    set test variable    ${CaseSUM_resetcell}         ${0}
    set test variable    ${MAXduration_min}    5000
    set test variable    ${MAXduration_max}    0
    set test variable    ${CaseSUM_MAXduration}     ${0}
    set test variable    ${CaseAVGLoop_MAXduration}    ${0}
    @{CellResetDurationList}=  Create List
    @{MAXdurationList}=  Create List
    set test variable    ${CellResetDuration_Min}    5000
    set test variable    ${CellResetDuration_Max}    0
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        log to console    Case loop ${i+1}:Step1: Trigger cell reset and start BTSLog
        BtsLog.StartBTSlogCollection
        COAM_WebEM.Login    version=${sbts_stream}
        selenium_sbts.reset_cell     cell_idx=${cell_idx}    with_graceful=${False}
#        Sleep    40s
        run keyword and ignore error    COAM_WebEM.Logout
        wait until keyword succeeds    5min    10s     COAM_Admin.CheckAllCellsOnair
        run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog

        Log To Console    Case loop ${i+1}:Step2: Check cell reset duration
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
            ...       awk '{print $7}'|head -n 1
        ${cellreset_startTime}=     run    command=${cmd}
        Should Not Be Empty     ${cellreset_startTime}
        ${cellreset_startTime}     convert date
        ...    ${cellreset_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
            ...      awk '{print $7}'|tail -n 1
        ${cellreset_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${cellreset_endTime}
        ${cellreset_endTime}        convert date
        ...     ${cellreset_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cellreset_duration}    Evaluate    ${cellreset_endTime}-${cellreset_startTime}
        Append To List    ${CellResetDurationList}    ${cellreset_duration}
        log to console    ${CellResetDurationList}
        Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}
        run keyword and continue on failure    Should Be True
        ...    ${cellreset_duration}<=${ResetCellDuration} and ${cellreset_duration}>${0}
        log to console   reset cell duration is ${cellreset_duration}

        ${CaseSUM_resetcell}        run keyword if    ${cellreset_duration}<=${ResetCellDuration}
        ...    Evaluate    ${CaseSUM_resetcell}+${cellreset_duration}
        ...    ELSE    Set Variable    ${CaseSUM_resetcell}
        ${CaseAVGLoop_resetcell}    run keyword if    ${cellreset_duration}<=${ResetCellDuration}
        ...    Evaluate    ${CaseAVGLoop_resetcell}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_resetcell}
        Set test Variable    ${CaseSUM_resetcell}    ${CaseSUM_resetcell}
        Set test Variable    ${CaseAVGLoop_resetcell}    ${CaseAVGLoop_resetcell}

        AppendCaseResultToFile    index=NRCELL_${cell_idx}
        ...    target_value=${ResetCellDuration}    result_value=${cellreset_duration}
        log to console    ${CellResetDurationList}

        Log To Console    Check MAXduration
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. trying to commit"|
         ...       awk '{print $7}'|head -n 1|tail -1
        ${MAXduration_startTime}=     run    command=${cmd}
        Should Not Be Empty     ${MAXduration_startTime}
        ${MAXduration_startTime}     convert date
        ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. finished with result: Succeeded"|
        ...      awk '{print $7}'|head -n 1|tail -1
        ${MAXduration_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${MAXduration_endTime}
        ${MAXduration_endTime}        convert date
        ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}
        Append To List    ${MAXdurationList}    ${MAXduration_duration}
        log to console    ${MAXdurationList}
        run keyword and continue on failure    Should Be True
        ...    ${MAXduration_duration}<=${Max_Duration_of_Cell_Reset} and ${MAXduration_duration}>${0}
        AppendCaseResultToFile   index=NRCELL_${cell_idx}   requirement_id=MAXDuration
        ...    target_value=${Max_Duration_of_Cell_Reset}    result_value=${MAXduration_duration}
        Log To Console   MAX duration of Cell reset  is ${MAXduration_duration}
        ${CaseSUM_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_Cell_Reset}
        ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
        ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
        ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_Cell_Reset}
        ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
        Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
        Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}

        log to console     Case loop ${i+1} END

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${cellreset_duration}>${ResetCellDuration}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for cell    loop=${i+1}    index=${cell_idx}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#19 value is above target
    END
#    KW.CPKPICaseEnd    times=${retry_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    ${durationLength}=    Get length      ${CellResetDurationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
        ${CellResetDuration_Max}=    set variable if   ${CellResetDurationList[${i}]}>=${CellResetDuration_Max}
        ...    ${CellResetDurationList[${i}]}    ${CellResetDuration_Max}
        ${CellResetDuration_Min}=    set variable if   ${CellResetDurationList[${i}]}<=${CellResetDuration_Min}
        ...    ${CellResetDurationList[${i}]}    ${CellResetDuration_Min}
        ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
        ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
    END
    ${ResetCellKpi_Max}    evaluate    round(${CellResetDuration_Max},2)
    ${ResetCellKpi_Min}    evaluate    round(${CellResetDuration_Min},2)
    ${ResetCellKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_resetcell}>0   Evaluate    ${CaseSUM_resetcell}/${CaseAVGLoop_resetcell}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${ResetCellKpi_aver_tmp}<=${ResetCellDuration}
    ${ResetCellKpi_aver}    evaluate    round(${ResetCellKpi_aver_tmp},2)

    ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
    ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
    ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_Cell_Reset}
    ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)

    Get common infos    kpi=KPI19_Cell_${cell_idx}   kpi_max=${ResetCellKpi_Max}    kpi_min=${ResetCellKpi_Min}    kpi_aver=${ResetCellKpi_aver}
    Get common infos    kpi=MAX_duration_of_Cell_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}

WEBUI.Collect snapshot for cell
    [Arguments]    ${loop}=0    ${index}=1
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${LOG_PATH}/snapshot_${filename}_cell_${index}_loop_${loop}.zip

WEBUI.Collect snapshot for BBMOD
    [Arguments]    ${loop}=0    ${index}=1
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${LOG_PATH}/snapshot_${filename}_bbmod_${index}_loop_${loop}.zip

WEBUI.Collect snapshot for RMOD
    [Arguments]    ${loop}=0    ${index}=1
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${LOG_PATH}/snapshot_${filename}_ru_${index}_loop_${loop}.zip

KW.Select SW package and download then Cancel it
    [Arguments]    ${sw_version}
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[Active]    separator=_
    ${result3}     convert to string    ${result}[-3]
    ${result4}     convert to string    ${result}[-5]
    ${Sw_build_version}=
    ...   Run Keyword If   "${result4}"=="SBTS25R3" or "${result4}"=="SBTS26R1" or "${result4}"=="SBTS26R2" and "${result3}"=="0000"
    ...   set variable       ${sw_version}
    ...   ELSE IF      "${result4}"=="SBTS26R3" and "${result3}"=="9999"
    ...   string.Replace String     ${sw_version}    SBTS00    SBTS26R3
    ...   ELSE     Set Variable     ${sw_version}
    ${Selected_SW_xpath}=
    ...   Set Variable
    ...   (//div[contains(text(), '${Sw_build_version}')])[last()]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    Log to Console    login NetAct and open Software Manager
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
            ...    showall=false
    selenium_netact.open_configuration_software_manager
    sleep    5s
    Log to Console    Select the target BTS
    KW.Select Target gNB in NetAct    BTS_ID=${MRBTS_ID}
    Log to Console    Start to do SW Cancel
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
    sleep    200s
    ${SW_Task_status}    wait until keyword succeeds    2min    30s
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
    ...   Run Keyword If   "${result4}"=="SBTS25R3" or "${result4}"=="SBTS26R1" or "${result4}"=="SBTS26R2" and "${result3}"=="0000"
    ...   set variable       ${sw_version}
    ...   ELSE IF      "${result4}"=="SBTS26R3" and "${result3}"=="9999"
    ...   string.Replace String     ${sw_version}    SBTS00    SBTS26R3
    ...   ELSE     Set Variable     ${sw_version}
    ${Selected_SW_xpath}=
    ...   Set Variable
    ...   (//div[contains(text(), '${Sw_build_version}')])[last()]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    Log to Console    login NetAct and open Software Manager
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
            ...    showall=false
    selenium_netact.open_configuration_software_manager
    sleep    5s
    Log to Console    Select the target BTS
    KW.Select Target gNB in NetAct    BTS_ID=${MRBTS_ID}
    Log to Console    Start to do SW PreCheck
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
    ...   Run Keyword If   "${result4}"=="SBTS25R3" or "${result4}"=="SBTS26R1" or "${result4}"=="SBTS26R2" and "${result3}"=="0000"
    ...   set variable       ${sw_version}
    ...   ELSE IF      "${result4}"=="SBTS26R3" and "${result3}"=="9999"
    ...   string.Replace String     ${sw_version}    SBTS00    SBTS26R3
    ...   ELSE     Set Variable     ${sw_version}
    ${Selected_SW_xpath}=
    ...   Set Variable
    ...   (//div[contains(text(), '${Sw_build_version}')])[last()]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    Log to Console    login NetAct and open Software Manager
    NetAct.Login   url=${CASE_INPUT_5GC002479['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['NETACT_PASSWORD']}
            ...    showall=false
    selenium_netact.open_configuration_software_manager
    sleep    5s
    Log to Console    Select the target BTS
    KW.Select Target gNB in NetAct    BTS_ID=${MRBTS_ID}
    Log to Console    Start to do SW PostCheck
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
    ${wft_url}    Set Variable if    ${TARGETSW.count('SBTS')}>0    ${link_to_Artifact_SBTS_WFT}${StreamFolder}${TARGETSW}/    ${link_to_Artifact}
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
    [Arguments]    ${url}=${WEBUI_URL}    ${alias}=None
#    [Arguments]      ${virtual_enable}=${TRUE}    ${url}=${WEBUI_URL}    ${alias}=None
    #run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    wait until keyword succeeds  15x   1min  selenium_coam.login
    ...    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}    alias=${alias}

KW.CPKPICaseStart
    [Arguments]    ${KPIsList}    ${retry_times}=1
    &{kpi_results}  Create Dictionary
    FOR    ${key}   IN    @{KPIsList}
        ${key}=  Set Variable  ${key.replace('KPI', 'kpi')}
        Set To Dictionary    ${kpi_results}    ${key}=@{EMPTY}
    END
    Set suite Variable  ${kpi_results}
    ${kpi_list}  Get Dictionary Keys  ${kpi_results}
    Set Test Variable  ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    Set Test Variable  ${target_kpis}    ${kpi_list}
    KW.CaseStatusInit    retry_times=${retry_times}

KW.CPKPILoopStart
    ims_keywords.check_instance_connection   gnbbbu
    oam_kpi_calculations.clear_results

KW.CPKPILoopEnd
    [Arguments]    ${startTime}=None   ${loop}=1   ${needprevIMS}=false
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_ims2/  ${needprevIMS}
    ${kpiValue}  KW.CP Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}    startTime=${startTime}
    ims_keywords.instance_disconnect    gnbbbu

KW.CPKPICaseEnd
    [Arguments]    ${times}    ${OAM_KPI_TARGETS}
    Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    Run Keyword and Ignore Error   ute_reporting_portal.Set reference configuration ID  ref_configuration_id=${REFERENCE_CONFIGURATION_ID}
    Run Keyword and Ignore Error   report_oam_kpi.Report Oam Kpi   oam_kpi_results=${kpi_results}    oam_kpi_targets=${OAM_KPI_TARGETS}
    log to console    ${times}
#    FOR  ${kpi}  IN  @{kpi_list}
##        Run Keyword and Ignore Error   report_oam_kpi.Report OAM KPI Success Rate    kpi_name=${kpi}
##        ...    passed_iterations=${CaseAVGLoop}    executed_iterations=${CaseMaxTime}
#        ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['${kpi}']}
#    END

KW.CP Analyse IMS File
    [Arguments]  ${kpi_list}   ${startTime}=None   ${kpi_params}=${None}    ${loop}=0
    ${kpi_params}    run keyword if   '${startTime}'!='None'    KW.TimeEvaluate   startTime=${startTime}
    ...    ELSE    Set Variable    None
    oam_kpi_calculations.Calculate Kpis  kpi_names=${kpi_list}   ims_file_path=${ims_file}    kpi_params=${kpi_params}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${LOG_PATH}/loop${loop}_ims2/results_${ext_json_name}.json
    ${result}  oam_kpi_calculations.get_results
    ims_keywords.save_kpi_to_csv_results  ${loop}  ${LOG_PATH}/loop${loop}_ims2  ${result}  ${active_alarms_list}
    FOR  ${kpi}  IN  @{kpi_list}
        ${kpi}=  Set Variable  ${kpi.replace('KPI', 'kpi')}
        ${x} = 	Combine Lists 	${kpi_results['${kpi}']} 	${result['${kpi}']}
        Set To Dictionary  ${kpi_results}  ${kpi}  ${x}
    END

    FOR  ${kpi}  IN  @{target_kpis}
        ${kpivalue}  oam_kpi_calculations.get_average_results  kpi_name=${kpi}
    END
    [Return]    ${kpivalue}

KW.TimeEvaluate
    [Arguments]    ${startTime}
    ${args}   Catenate   SEPARATOR=${SPACE}   {"${ext_json_name}":{"start_point_timestamp":"${startTime}"}}
    ${kpiargs}   Evaluate     json.loads('''${args}''')   json
    [Return]    ${kpiargs}

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

KW.GetPowerResetBBMODUnitWithBBMODIndex
    [Arguments]   ${BBMOD_INDEX}
    COAM_WebEM.Login    version=SBTS24R1
    ${UnitsList}    selenium_sbts.get_units_to_be_reset
    COAM_WebEM.Logout
    ${length}       Get length     ${UnitsList}
    FOR    ${i}    IN RANGE    0    ${length}
        ${Units_Split}=    Split String    ${UnitsList[${i}]}    /
        ${Unit}   Set Variable     ${Units_Split[0]}
        ${tmp}=    Split String   ${Units_Split[0]}     -
        ${Unit_Index}=    Set Variable   ${tmp[-1]}
        ${Unit_Index}=    Replace String    ${Unit_Index}    ${SPACE}    ${EMPTY}
        Continue For Loop If    "${Unit_Index}"!="${BBMOD_INDEX}"
        ${PowerResetBBMOD_Unit}=    set variable     ${UnitsList[${i}]}
    END
    [Return]   ${PowerResetBBMOD_Unit}

KW.CapacityModulePowerReset
    [Arguments]    ${retry_times}    ${KPI14}   ${PowerResetBBMOD_Unit}    ${Max_Duration_of_BBMOD_Power_Reset}
    KW.CaseStatusInit    retry_times=${retry_times}
    Set Test Variable    ${GnbReset}    False
    @{durationList}=  Create List
    @{MAXdurationList}=  Create List
    set test variable    ${duration_min}    5000
    set test variable    ${duration_max}    0
    Set test Variable    ${CaseSUM_KPI14}     ${0}
    Set test Variable    ${CaseAVGLoop_KPI14}     ${0}
    set test variable    ${MAXduration_min}    5000
    set test variable    ${MAXduration_max}    0
    set test variable    ${CaseSUM_MAXduration}     ${0}
    set test variable    ${CaseAVGLoop_MAXduration}    ${0}
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        BtsLog.StartBTSlogCollection
        Log To Console    Case loop ${i+1}:Step1: Power reset baseband ${PowerResetBBMOD_Unit}
        wait until keyword succeeds    10min    10s    COAM_WebEM.Login    version=SBTS24R1
#        ${timestartTmp}    KW.TimerStart
#        ${timestartUTC}   Get Current Date   UTC
        selenium_sbts.baseband_power_reset    baseband_unit=${PowerResetBBMOD_Unit}    with_graceful=${False}
        sleep    20s
        COAM_WebEM.Logout
        wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
#        ${duration_time}     KW.TimerStop    timestart=${timestartTmp}
        Run Keyword And Ignore error       Stop BTSlogs Collection and get logs for every loop     loop=${i+1}
        Log To Console    Case loop ${i+1}:Step2: Check duration of bbmod ${PowerResetBBMOD_Unit} power reset
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
        ...       awk '{print $7}'|head -n 1
        ${BBMODReset_startTime}=     run    command=${cmd}
        Should Not Be Empty    ${BBMODReset_startTime}
        ${BBMODReset_startTime}     convert date
        ...    ${BBMODReset_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
        ...      awk '{print $7}'|tail -n 1
        ${BBMODReset_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${BBMODReset_endTime}
        ${BBMODReset_endTime}        convert date
        ...     ${BBMODReset_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${BBMODPowerReset_duration}    Evaluate    ${BBMODReset_endTime}-${BBMODReset_startTime}
        Append To List    ${durationList}    ${BBMODPowerReset_duration}
        log to console    ${durationList}

        Log To Console    Check MAXduration
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. trying to commit"|
          ...       awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_startTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_startTime}
         ${MAXduration_startTime}     convert date
         ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. finished with result: Succeeded"|
         ...      awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_endTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_endTime}
         ${MAXduration_endTime}        convert date
         ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}
         Append To List    ${MAXdurationList}    ${MAXduration_duration}
         log to console    ${MAXdurationList}
         run keyword and continue on failure    Should Be True
         ...    ${MAXduration_duration}<=${Max_Duration_of_BBMOD_Power_Reset} and ${MAXduration_duration}>${0}
         AppendCaseResultToFile   index=BBMOD_${i+1}   requirement_id=MAXDuration
         ...    target_value=${Max_Duration_of_BBMOD_Power_Reset}    result_value=${MAXduration_duration}
         Log To Console   MAX duration of BBMOD Power reset  is ${MAXduration_duration}
         ${CaseSUM_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_BBMOD_Power_Reset}
         ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
         ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
         ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_BBMOD_Power_Reset}
         ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
         Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
         Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}

        Run Keyword And Ignore error   KW.CPKPILoopEnd    loop=${i}
#        KW.CaseStatusCaluate    duration=${BBMODReset_duration}    max=${KPI5}
        run keyword and continue on failure    Should Be True
        ...    ${BBMODPowerReset_duration}<=${KPI14} and ${BBMODPowerReset_duration}>${0}
        AppendCaseResultToFile    index=BBMOD_${i+1}    target_value=${KPI14}    result_value=${BBMODPowerReset_duration}
        Log To Console    BBMOD_${i+1} power reset duration is ${BBMODPowerReset_duration}
        ${CaseSUM_KPI14}        run keyword if    ${BBMODPowerReset_duration}<=${KPI14}    Evaluate    ${CaseSUM_KPI14}+${BBMODPowerReset_duration}
        ...    ELSE    Set Variable    ${CaseSUM}
        ${CaseAVGLoop_KPI14}    run keyword if    ${BBMODPowerReset_duration}<=${KPI14}    Evaluate    ${CaseAVGLoop_KPI14}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop}
        Set test Variable    ${CaseSUM_KPI14}    ${CaseSUM_KPI14}
        Set test Variable    ${CaseAVGLoop_KPI14}    ${CaseAVGLoop_KPI14}
        log to console     Case loop ${i+1} END

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${BBMODPowerReset_duration}>${KPI14}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for BBMOD    loop=${i+1}   index=${PowerResetBBMOD_Unit}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#14 value is above target
        log to console     Case loop ${i+1} END
    END
#    KW.CPKPICaseEnd    times=${retry_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    ${durationLength}=    Get length      ${durationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
        ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}
        ...    ${durationList[${i}]}    ${duration_max}
        ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}
        ...    ${durationList[${i}]}    ${duration_min}
        ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
        ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
    END
    ${BBPowerReset_Max}    evaluate    round(${duration_max},2)
    ${BBPowerReset_Min}    evaluate    round(${duration_min},2)
    ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
    ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
    ${BBPowerReset_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI14}>0   Evaluate    ${CaseSUM_KPI14}/${CaseAVGLoop_KPI14}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${BBPowerReset_aver_tmp}<=${KPI14}
    ${BBPowerReset_aver}    evaluate    round(${BBPowerReset_aver_tmp},2)

    ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_BBMOD_Power_Reset}
    ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)

    Get common infos    kpi=KPI14_${PowerResetBBMOD_Unit}   kpi_max=${BBPowerReset_Max}    kpi_min=${BBPowerReset_Min}
    ...    kpi_aver=${BBPowerReset_aver}
    Get common infos    kpi=Max_Duration_of_BBMOD_Power_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}
    set test variable    ${execution_result}    pass

KW.CapacityModuleReset
    [Arguments]    ${retry_times}    ${KPI5}    ${Max_Duration_of_BBMOD_Reset}  ${bbmod_reset_index}=1
    KW.CaseStatusInit    retry_times=${retry_times}
    Set Test Variable    ${GnbReset}    False
    @{durationList}=  Create List
    @{MAXdurationList}=  Create List
    set test variable    ${duration_min}    5000
    set test variable    ${duration_max}    0
    set test variable    ${MAXduration_min}    5000
    set test variable    ${MAXduration_max}    0
    Set test Variable    ${CaseSUM_KPI5}     ${0}
    Set test Variable    ${CaseAVGLoop_KPI5}     ${0}
    Set test Variable    ${CaseSUM_MAXduration}     ${0}
    Set test Variable    ${CaseAVGLoop_MAXduration}    ${0}
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        BtsLog.StartBTSlogCollection
        Log To Console    Case loop ${i+1}:Step1: Reset baseband ${bbmod_reset_index}
        wait until keyword succeeds    10min    10s    COAM_WebEM.Login
#        ${timestartTmp}    KW.TimerStart
#        ${startTime}   Get Current Date   UTC
        selenium_sbts.reset_abil    abil_index=${bbmod_reset_index}    with_graceful=${False}
        sleep    20s
        COAM_WebEM.Logout
        wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
#        ${duration_time}     KW.TimerStop    timestart=${timestartTmp}
        Run Keyword And Ignore error       Stop BTSlogs Collection and get logs for every loop     loop=${bbmod_reset_index}
        Log To Console    Case loop ${i+1}:Step2: Check duration of bbmod ${bbmod_reset_index} reset
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
        ...       awk '{print $7}'|head -n 1
        ${BBMODReset_startTime}=     run    command=${cmd}
        Should Not Be Empty    ${BBMODReset_startTime}
        ${BBMODReset_startTime}     convert date
        ...    ${BBMODReset_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
        ...      awk '{print $7}'|tail -n 1
        ${BBMODReset_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${BBMODReset_endTime}
        ${BBMODReset_endTime}        convert date
        ...     ${BBMODReset_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${BBMODReset_duration}    Evaluate    ${BBMODReset_endTime}-${BBMODReset_startTime}
        Append To List    ${durationList}    ${BBMODReset_duration}
        log to console    ${durationList}
        Run Keyword And Ignore error     KW.CPKPILoopEnd    loop=${i}
#        KW.CaseStatusCaluate    duration=${BBMODReset_duration}    max=${KPI5}
        run keyword and continue on failure    Should Be True
        ...    ${BBMODReset_duration}<=${KPI5} and ${BBMODReset_duration}>${0}
        AppendCaseResultToFile    index=${bbmod_reset_index}    target_value=${KPI5}    result_value=${BBMODReset_duration}
        Log To Console    BBMOD_${bbmod_reset_index}_loop_${i} reset duration is ${BBMODReset_duration}
        ${CaseSUM_KPI5}        run keyword if    ${BBMODReset_duration}<=${KPI5}    Evaluate    ${CaseSUM_KPI5}+${BBMODReset_duration}
        ...    ELSE    Set Variable    ${CaseSUM}
        ${CaseAVGLoop_KPI5}    run keyword if    ${BBMODReset_duration}<=${KPI5}    Evaluate    ${CaseAVGLoop_KPI5}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop}
        Set test Variable    ${CaseSUM_KPI5}    ${CaseSUM_KPI5}
        Set test Variable    ${CaseAVGLoop_KPI5}    ${CaseAVGLoop_KPI5}
        Log To Console    Check MAXduration of BBMOD Reset
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.* trying to commit"|
        ...       awk '{print $7}'|head -n 1|tail -1
        ${MAXduration_startTime}=     run    command=${cmd}
        Should Not Be Empty     ${MAXduration_startTime}
        ${MAXduration_startTime}     convert date
        ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.* finished with result: Succeeded"|
        ...      awk '{print $7}'|head -n 1|tail -1
        ${MAXduration_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${MAXduration_endTime}
        ${MAXduration_endTime}        convert date
        ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}
        Append To List    ${MAXdurationList}    ${MAXduration_duration}
        log to console    ${MAXdurationList}
        run keyword and continue on failure    Should Be True
         ...    ${MAXduration_duration}<=${Max_Duration_of_BBMOD_Reset} and ${MAXduration_duration}>${0}
        AppendCaseResultToFile    index=${bbmod_reset_index}    target_value=${Max_Duration_of_BBMOD_Reset}
        ...    result_value=${MAXduration_duration}    requirement_id=MAXDuration
        Log To Console   MAX duration of BBMOD reset is ${MAXduration_duration}
        ${CaseSUM_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_BBMOD_Reset}
        ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
        ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
        ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_BBMOD_Reset}
        ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
        Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
        Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}
        log to console     Case loop ${i+1} END

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result1}  set variable if    ${BBMODReset_duration}>${KPI5}   failed    pass
        ${result2}  set variable if    ${MAXduration_duration}>${Max_Duration_of_BBMOD_Reset}   failed    pass
        Run Keyword if   '${result1}'!='pass' or '${result2}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for BBMOD    loop=${i+1}   index=${bbmod_reset_index}
        Run Keyword And Continue On Failure    Run keyword if    '${result1}'!='pass' or '${result2}'!='pass'    Fail
        ...    KPI#5 value is above target
        log to console     Case loop ${i+1} END
    END
#    KW.CaseStatusFinnal    case_avg=${KPI5}    max_loop=${retry_times}
#    KW.CPKPICaseEnd    times=${retry_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${durationList}
    log to console    ${MAXdurationList}
    ${durationLength}=    Get length      ${durationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
         ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
         ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
    END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${kpi_max}    evaluate    round(${duration_max},2)
    ${kpi_min}    evaluate    round(${duration_min},2)
    ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
    ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
#    ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPI5}    max_loop=${retry_times}
    ${kpi_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI5}>0   Evaluate    ${CaseSUM_KPI5}/${CaseAVGLoop_KPI5}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${kpi_aver_tmp}<=${KPI5}
    ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
    ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_BBMOD_Reset}
    ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)
    Get common infos    kpi=KPI5_BBMOD_${bbmod_reset_index}   kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
    Get common infos    kpi=MAX_duration_of_BBMOD_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}
    set test variable    ${execution_result}    pass

KW.CleanFirefox
    Log to Console    CleanFirefox
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver

RU_Reset_Teardown case
    Run Keyword And Ignore error       WEBUI.Collect snapshot
    TestteardownforWebEM

TestteardownforWebEM
#    [Arguments]   ${connection}=COAM
    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
    ...    Please check unexpect Alarm
    Run Keyword If  '${TEST STATUS}' == 'FAIL' or'${alarm_result}'=='False'   WEBUI.Collect snapshot
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
    COAM_WebEM.Login     version=${sbts_stream}
    run keyword and ignore error    selenium_sbts.synchronize
    COAM_WebEM.Logout
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

AA_Recovery_Teardown case
    TestteardownforWebEM
    run keyword and ignore error   gNB.Commission   scf_file=${BACKUP_SCF}
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
Get common infos
    [Arguments]    ${TL}=${testline_name}    ${stream}=${sbts_stream}   ${version}=${version_number}    ${kpi}=kpi1a
    ...    ${kpi_max}=0   ${kpi_min}=0   ${kpi_aver}=0
    ...    ${URL}=http://toolscenter.eecloud.dynamic.nsn-net.net/api/oamkpi/get_oam_kpi_his/?version=
    ${sw_time}    get_version_time_from_wft    version=${sbts_version}
    ${URL_tmp}      set variable
    ...   ${URL}${version}&testline=${TL}&release=${stream}&time=${sw_time}&kpi_name=${kpi}&kpi_aver=${kpi_aver}&kpi_min=${kpi_min}&kpi_max=${kpi_max}
    log to console     ${URL_tmp}
    ${res}    requests.get    url=${URL_tmp}

KW.Reset.WEbUIResetWithRetry
    [Arguments]   ${KPI51a}   ${Max_Duration_of_RU_Reset}   ${KPI_TARGET}    ${retry_times}   ${with_graceful}    ${ru_reset_index}=1
    KW.CaseStatusInit    retry_times=${retry_times}
    @{durationList}=  Create List
    @{MAXdurationList}=  Create List
    set test variable    ${duration_min}    5000
    set test variable    ${duration_max}    0
    set test variable    ${MAXduration_min}    5000
    set test variable    ${MAXduration_max}    0
    Set Test Variable    ${GnbReset}    True
    Set test Variable    ${CaseSUM_KPI51a}     ${0}
    Set test Variable    ${CaseAVGLoop_KPI51a}     ${0}
    Set test Variable    ${CaseSUM_MAXduration}     ${0}
    Set test Variable    ${CaseAVGLoop_MAXduration}    ${0}
    FOR    ${i}    IN RANGE    ${retry_times}
#        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        KW.CPKPILoopStart
        ${res}    run keyword and ignore error    KW.Reset.LoopForWebUIReset
        ...    loop=${i+1}    ru_reset_index=${ru_reset_index}    with_graceful=${with_graceful}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
#        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        Append To List    ${durationList}    ${duration}
        log to console    ${durationList}
#        ${startTime}   set variable    ${res[1][2]}
        Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}
#        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI51a}
        run keyword and continue on failure    Should Be True
        ...    ${duration}<=${KPI51a} and ${duration}>${0}
        AppendCaseResultToFile    index=${i}    ru_index=${ru_reset_index}
        ...    target_value=${KPI51a}    result_value=${duration}
        Log To Console    RU_${i} reset duration is ${duration}

        ${CaseSUM_KPI51a}        run keyword if    ${duration}<=${KPI51a}    Evaluate    ${CaseSUM_KPI51a}+${duration}
        ...    ELSE    Set Variable    ${CaseSUM}
        ${CaseAVGLoop_KPI51a}    run keyword if    ${duration}<=${KPI51a}    Evaluate    ${CaseAVGLoop_KPI51a}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop}
        Set test Variable    ${CaseSUM_KPI51a}    ${CaseSUM_KPI51a}
        Set test Variable    ${CaseAVGLoop_KPI51a}    ${CaseAVGLoop_KPI51a}

        Log To Console    Check MAXduration of RU Reset
        ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.* trying to commit"|
          ...       awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_startTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_startTime}
         ${MAXduration_startTime}     convert date
         ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-.*"| grep "SessionIndicationsController"|
         ...      awk '{print $7}'|head -n 1|tail -1
         ${MAXduration_endTime}=     run    command=${cmd}
         Should Not Be Empty     ${MAXduration_endTime}
         ${MAXduration_endTime}        convert date
         ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
         ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}
         Append To List    ${MAXdurationList}    ${MAXduration_duration}
         log to console    ${MAXdurationList}
#         KW.CaseStatusCaluate    duration=${MAXduration_duration}    max=${Max_Duration_of_RAT_Reset}
         run keyword and continue on failure    Should Be True
         ...    ${MAXduration_duration}<=${Max_Duration_of_RU_Reset} and ${MAXduration_duration}>${0}
         AppendCaseResultToFile    index=${i}    ru_index=${ru_reset_index}    requirement_id=MAXDuration
        ...    target_value=${Max_Duration_of_RU_Reset}    result_value=${MAXduration_duration}
         Log To Console   MAX duration of RU reset  is ${MAXduration_duration}
         ${CaseSUM_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_RU_Reset}
         ...    Evaluate    ${CaseSUM_MAXduration}+${MAXduration_duration}
         ...    ELSE    Set Variable    ${CaseSUM_MAXduration}
         ${CaseAVGLoop_MAXduration}    run keyword if    ${MAXduration_duration}<=${Max_Duration_of_RU_Reset}
         ...    Evaluate    ${CaseAVGLoop_MAXduration}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_MAXduration}
         Set test Variable    ${CaseSUM_MAXduration}    ${CaseSUM_MAXduration}
         Set test Variable    ${CaseAVGLoop_MAXduration}    ${CaseAVGLoop_MAXduration}
         log to console     Case loop ${i+1} END
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result1}  set variable if    ${duration}>${KPI51a}   failed    pass
        ${result2}  set variable if    ${MAXduration_duration}>${Max_Duration_of_RU_Reset}   failed    pass
        Run Keyword if   '${result1}'!='pass' or '${result2}'!='pass' or '${alarm_result}'=='False'
         ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for RMOD    loop=${i+1}   index=${ru_reset_index}
        Run Keyword And Continue On Failure    Run keyword if    '${result1}'!='pass' or '${result2}'!='pass'   Fail
        ...    KPI#51a value is above target
    END
    KW.CPKPICaseEnd    times=${retry_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${durationList}
    log to console    ${MAXdurationList}
    ${durationLength}=    Get length      ${durationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
         ${MAXduration_max}=    set variable if   ${MAXdurationList[${i}]}>=${MAXduration_max}    ${MAXdurationList[${i}]}    ${MAXduration_max}
         ${MAXduration_min}=    set variable if   ${MAXdurationList[${i}]}<=${MAXduration_min}    ${MAXdurationList[${i}]}    ${MAXduration_min}
     END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${kpi_max}    evaluate    round(${duration_max},2)
    ${kpi_min}    evaluate    round(${duration_min},2)
    ${MAXkpi_max}    evaluate    round(${MAXduration_max},2)
    ${MAXkpi_min}    evaluate    round(${MAXduration_min},2)
#    ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPI51a}    max_loop=${retry_times}
#    ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
    ${kpi_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI51a}>0   Evaluate    ${CaseSUM_KPI51a}/${CaseAVGLoop_KPI51a}
     ...      ELSE     set variable    ${3600}
     run keyword and continue on failure    should be true    ${kpi_aver_tmp}<=${KPI51a}
     ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
     ${MAXkpi_aver_tmp}    run keyword if     ${CaseAVGLoop_MAXduration}>0   Evaluate    ${CaseSUM_MAXduration}/${CaseAVGLoop_MAXduration}
     ...      ELSE     set variable    ${3600}
     run keyword and continue on failure    should be true    ${MAXkpi_aver_tmp}<=${Max_Duration_of_RU_Reset}
     ${MAXkpi_aver}    evaluate    round(${MAXkpi_aver_tmp},2)
     Get common infos    kpi=KPI51a_RU${ru_reset_index}_${GracefulCellShutdown}   kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}
     Get common infos    kpi=MAX_duration_of_RU_Reset   kpi_max=${MAXkpi_max}    kpi_min=${MAXkpi_min}    kpi_aver=${MAXkpi_aver}
     set test variable    ${execution_result}    pass

KW.CPLoopForResetViaWEBUI
    [Arguments]    ${loop}    ${graceful_cell_shutdown}
    BtsLog.StartBTSlogCollection
    Log To Console    Site reset loop ${loop}
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
#    ${timestartTmp}   Get Current Date
#    ${timestart}      convert date    ${timestartTmp}    epoch
    COAM_Admin.ResetSite     timeout=1800    graceful_cell_shutdown=${graceful_cell_shutdown}
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
#    ${timeendTmp}     Get Current Date
#    ${timeend}        convert date    ${timeendTmp}     epoch
#    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    Run Keyword And Ignore error       Stop BTSlogs Collection and get logs for every loop     loop=${loop}

    Log To Console    Check the duration of KPI#1a
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
        ...       awk '{print $7}'|head -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}
    ${timestart}    convert date
    ...    ${timestart.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...      awk '{print $7}'|tail -n 1
    ${timeend}=     run    command=${cmd}
    Should Not Be Empty     ${timeend}
    ${timeend}        convert date
    ...     ${timeend.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${duration_time_tmp_KPI1a}    Evaluate    ${timeend}-${timestart}

    Log To Console    Check the duration of KPI#1b
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from OnAirDone to Validated"|
        ...       awk '{print $7}'|tail -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}
    ${timestart}    convert date
    ...    ${timestart.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...      awk '{print $7}'|head -n 1
    ${timeend}=     run    command=${cmd}
    Should Not Be Empty     ${timeend}
    ${timeend}        convert date
    ...     ${timeend.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${duration_time_tmp_KPI1b}    Evaluate    ${timeend}-${timestart}

    Log To Console    Check MAXduration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. trying to commit"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${MAXduration_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${MAXduration_startTime}
    ${MAXduration_startTime}     convert date
    ...    ${MAXduration_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "RESET_IND-. finished with result: Succeeded"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${MAXduration_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${MAXduration_endTime}
    ${MAXduration_endTime}        convert date
    ...     ${MAXduration_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${MAXduration_duration}    Evaluate    ${MAXduration_endTime}-${MAXduration_startTime}

    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp_KPI1a}<1800 	    pass      fail
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${reset_status}   ${duration_time_tmp_KPI1a}    ${duration_time_tmp_KPI1b}    ${MAXduration_duration}

KW.CPLoopForResetViaWEBUIWithoutRUreset
    [Arguments]    ${loop}    ${graceful_cell_shutdown}    ${reset_without_ru}
    BtsLog.StartBTSlogCollection
    Log To Console    Site reset loop ${loop}
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
#    ${timestartTmp}   Get Current Date
#    ${timestart}      convert date    ${timestartTmp}    epoch
    KW.ResetSite    timeout=1800    graceful_cell_shutdown=${graceful_cell_shutdown}   reset_without_ru=${reset_without_ru}
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
#    ${timeendTmp}     Get Current Date
#    ${timeend}        convert date    ${timeendTmp}     epoch
#    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    Run Keyword And Ignore error       Stop BTSlogs Collection and get logs for every loop     loop=${loop}

    Log To Console    Check the duration of KPI#1f
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
        ...       awk '{print $7}'|head -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}
    ${timestart}    convert date
    ...    ${timestart.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...      awk '{print $7}'|tail -n 1
    ${timeend}=     run    command=${cmd}
    Should Not Be Empty     ${timeend}
    ${timeend}        convert date
    ...     ${timeend.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${duration_time_tmp_KPI1f}    Evaluate    ${timeend}-${timestart}

    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp_KPI1f}<1800     pass      fail
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${reset_status}   ${duration_time_tmp_KPI1f}

KW.ResetSite
    [Arguments]  ${timeout}    ${connection}=COAM    ${graceful_cell_shutdown}=False    ${reset_without_ru}=True
    log to console    Start reseting gNB!
    coam.reset_site   timeout=${timeout}    connection=${connection}    graceful_cell_shutdown=${graceful_cell_shutdown}
    ...    reset_without_ru=${reset_without_ru}
    log to console    Finish reseting gNB!


KW.CPLoopForPowerReset
    [Arguments]    ${loop}
    #[Timeout]    ${CASE_INPUT_5GC002479['5GC002479']['LoopTimeout']} minutes
    Log To Console    Power reset loop ${loop}
#    Power.ResetgNB     model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    KW.PowerResetgNB    model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}    Action=power_off
    KW.PowerResetgNB    model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}    Action=power_on
#    KW.PowerOff5GRUs
    ${timestartTmp}   Get Current Date
    ${timestartUTC}   Get Current Date   UTC
    #PowerReset5GRUs
#    KW.PowerOn5GRUs

    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800 	    pass      fail
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}    ${timestartUTC}

KW.PowerResetgNB
    [Arguments]  ${pdu_ip}=${PB_ASIK_IP}    ${Port_Number}=${PB_ASIK_PORT}    ${model}=FACOM    ${Action}=${Action}
    facom.PowerOnOff    pdu_ip=${pdu_ip}    Port_Number=${Port_Number}     Action=${Action}    model=${model}

KW.Reset.LoopForWebUIReset
    [Arguments]    ${loop}    ${ru_reset_index}    ${with_graceful}
    #[Timeout]      ${CASE_INPUT_5GC002479['5GC002479']['LoopTimeout']} minutes
    BtsLog.StartBTSlogCollection
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login
#    ${timestartTmp}   Get Current Date
    ${timestartUTC}   Get Current Date   UTC
    WEBUI.ResetRU    ru_index=${ru_reset_index}    with_graceful=${with_graceful}
    sleep    60s
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
#    ${timestart}      convert date    ${timestartTmp}    epoch
#    ${timeendTmp}     Get Current Date
#    ${timeend}        convert date    ${timeendTmp}     epoch
    Run Keyword And Ignore error       Stop BTSlogs Collection and get logs for every loop     loop=${loop}
#    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "status change to operational state: Disabled, availability status: Offline"|
        ...       awk '{print $7}'|head -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}
    ${timestart}    convert date
    ...    ${timestart.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...      awk '{print $7}'|tail -n 1
    ${timeend}=     run    command=${cmd}
    Should Not Be Empty     ${timeend}
    ${timeend}        convert date
    ...     ${timeend.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800   pass      fail
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}    ${timestartUTC}

KW.Reset.LoopForRUPowerReset
    [Arguments]    ${loop}     ${ru_index}
    Log To Console    RU Power reset loop ${loop}
    KW.Reset.RUPowerOff    ru_index=${ru_index}
    KW.TimerStart
    KW.Reset.RUPowerOn     ru_index=${ru_index}
    wait until keyword succeeds     Check all cells Should Be On Air
    ${duration}    Timer.Stop
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}

KW.CB006939_HA_04_OAM_KPI_54a_RU_Cold_Reset_Time
    [Arguments]   ${retry_times}    ${KPI54a}   ${KPI_TARGET}   ${ru_index}=1
#    KW.CaseStatusInit    retry_times=${retry_times}
    Set Test Variable    ${GnbReset}    False
    @{durationList}=  Create List
    set test variable    ${duration_min}    5000
    set test variable    ${duration_max}    0
    Set test Variable    ${CaseSUM_KPI54a}     ${0}
    Set test Variable    ${CaseAVGLoop_KPI54a}     ${0}
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        AlarmWatchdog.add_allow_alarms    fault_id=10
        AlarmWatchdog.add_allow_alarms    fault_id=4589
        AlarmWatchdog.add_allow_alarms    fault_id=1815
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        KW.Reset.RUPowerOff    ru_index=${ru_index}
        sleep    100s
        ${startTime}    KW.TimerStart
        ${timestartUTC}   Get Current Date   UTC
        KW.Reset.RUPowerOn     ru_index=${ru_index}
        wait until keyword succeeds    20min    5s    COAM_Admin.CheckAllCellsOnair
        ${duration_time_tmp}    KW.TimerStop    timestart=${startTime}
        Append To List    ${durationList}    ${duration_time_tmp}
        log to console    ${durationList}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        AlarmWatchdog.remove_allow_alarms    fault_id=10
        AlarmWatchdog.remove_allow_alarms    fault_id=1815
#        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
#        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
#        KW.CaseStatusCaluateWithoutPassRate    duration=${duration_time_tmp}    max=${KPI54a}
        Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}   startTime=${timestartUTC}
        ${CaseSUM_KPI54a}        run keyword if    ${duration_time_tmp}<=${KPI54a}    Evaluate    ${CaseSUM_KPI54a}+${duration_time_tmp}
        ...    ELSE    Set Variable    ${CaseSUM_KPI54a}
        ${CaseAVGLoop_KPI54a}    run keyword if    ${duration_time_tmp}<=${KPI54a}    Evaluate    ${CaseAVGLoop_KPI54a}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_KPI54a}
        Set test Variable    ${CaseSUM_KPI54a}    ${CaseSUM_KPI54a}
        Set test Variable    ${CaseAVGLoop_KPI54a}    ${CaseAVGLoop_KPI54a}
        log to console     Case loop ${i+1} END
        AppendCaseResultToFile    index=${i}    ru_index=${ru_index}
        ...    target_value=${KPI54a}    result_value=${duration_time_tmp}
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        AlarmWatchdog.remove_allow_alarms    fault_id=4589
        ${result}  set variable if    ${duration_time_tmp}>${KPI54a}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for RMOD    loop=${i+1}   index=${ru_index}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#54a value is above target
    END
#    KW.CaseStatusFinnal    case_avg=${KPI54a}    max_loop=${retry_times}
    KW.CPKPICaseEnd    times=${retry_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${durationList}
    ${durationLength}=    Get length      ${durationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
         ${duration_max}=    set variable if   ${durationList[${i}]}>=${duration_max}    ${durationList[${i}]}    ${duration_max}
         ${duration_min}=    set variable if   ${durationList[${i}]}<=${duration_min}    ${durationList[${i}]}    ${duration_min}
    END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${kpi_max}    evaluate    round(${duration_max},2)
    ${kpi_min}    evaluate    round(${duration_min},2)
#    ${kpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${KPI54a}    max_loop=${retry_times}
    ${kpi_aver_tmp}    run keyword if     ${CaseAVGLoop_KPI54a}>0   Evaluate    ${CaseSUM_KPI54a}/${CaseAVGLoop_KPI54a}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${kpi_aver_tmp}<=${KPI54a}
    ${kpi_aver}    evaluate    round(${kpi_aver_tmp},2)
    Get common infos    kpi=KPI54a_RU${ru_index}   kpi_max=${kpi_max}    kpi_min=${kpi_min}    kpi_aver=${kpi_aver}

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

KW.GetRMODName
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    @{RMODsName}=  Create List
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        Append To List    ${RMODsName}    ${RU['productName']}
    END
    [Return]   ${RMODsName}

KW.GetBBMODName
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    @{BBMODsName}=  Create List
    FOR    ${bbmod}   IN    @{BTSInfo['basebandModules']}
        ${tmp}=    Split String    ${bbmod['productName']}   ${SPACE}
        ${BBMODName}=    Set Variable    ${tmp[0]}
        Append To List    ${BBMODsName}    ${BBMODName}
    END
    [Return]   ${BBMODsName}

KW.GetRMODsInfoByBBMODID
    [Arguments]    ${BBMOD_ID}
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    @{RMODs_ID}=  Create List
    @{RMODs_Index}=  Create List
    @{RMODs_Name}=  Create List
    FOR    ${CABLE}   IN    @{BTSInfo['cables']}
        ${cable_BBMOD}=    Split String From Right    ${CABLE['firstEndPointId']['configuration']}     /
        ${firstEndPointId_BBMOD}   Set Variable     ${cable_BBMOD[-2]}
        ${cable_RMOD}   Split String From Right    ${CABLE['secondEndPointId']['configuration']}     /
        ${secondEndPointId_RMOD}   Set Variable     ${cable_RMOD[-2]}
        Continue For Loop If     '${firstEndPointId_BBMOD}'!='${BBMOD_ID}'
        ${RMOD_ID}=    Set Variable If    '${firstEndPointId_BBMOD}'=='${BBMOD_ID}'      ${secondEndPointId_RMOD}
        Append To List    ${RMODs_ID}    ${RMOD_ID}
        ${RMOD_tmp}   Split String From Right    ${RMOD_ID}     -
        ${RMOD_Index}     Set Variable     ${RMOD_tmp[-1]}
        Append To List    ${RMODs_Index}    ${RMOD_Index}
    END
    ${RMODs_length}    Get length      ${RMODs_ID}
    FOR    ${i}    IN RANGE    0     ${RMODs_length}
         ${RMOD_Name}    KW.GetRMODNameByID     RMOD_ID=${RMODs_ID[${i}]}
         Append To List    ${RMODs_Name}    ${RMOD_Name}
    END
    [Return]   ${RMODs_Name}    ${RMODs_Index}

KW.GetMaxBBMODResetVaule
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    KW.CP_GetgNBType
    ${CellNums}    KW.CP_GetCellNums
    ${AdjRMOD}    Set Variable     AEHC
    set test variable    ${MaxBBMODResetVaule}   ${0}
    FOR    ${BBMOD}   IN    @{BTSInfo['basebandModules']}
        ${BBMOD_config}=    Split String From Right    ${BBMOD['id']['configuration']}     /
        ${BBMOD_ID}    Set Variable     ${BBMOD_config[-1]}
        ${tmp}=    Split String From Right   ${BBMOD_config[-1]}      -
        ${BBMOD_INDEX}    Set Variable   ${tmp[-1]}
        ${RMODs_infoList}    KW.GetRMODsInfoByBBMODID    BBMOD_ID=${BBMOD_ID}
        ${SFPCooledInfo_BBMOD}    KW.GetSFPCooledInfoOnBBMOD    BBMOD_INDEX=${BBMOD_INDEX}
        #RU_index just for 1BBMOD--1RMOD, not for 1BBMOD--nRMOD
        ${RU_Index}=  set variable  ${RMODs_infoList[1][0]}
        ${SFPCooledInfo_RU}    KW.GetSFPCooledInfoOnRU       RU_INDEX=${RU_Index}
        ${tmp_status}=   Evaluate   "${SFPCooledInfo_BBMOD}"=="true" or "${SFPCooledInfo_RU}"=="true"
        ${SFPCooledInfo}=    Set Variable if    "${tmp_status}"=="True"     true    false
        ${KPIAdjValue}   KW.GetAdjValue   RMODsList=${RMODs_infoList[0]}   CellNums=${CellNums}   gNBType=${gNBType}   SFPCooled=${SFPCooledInfo}
        ...    AdjRMOD=${AdjRMOD}
        ${MaxBBMODResetVaule}    Set Variable If    ${KPIAdjValue['KPI5']}>${MaxBBMODResetVaule}    ${KPIAdjValue['KPI5']}   ${MaxBBMODResetVaule}
    END
    [Return]    ${MaxBBMODResetVaule}

KW.CB006939_HA_05_OAM_KPI_17_Cell_Block_Unblock
    [Arguments]   ${retry_times}  ${CellBlockDuration}   ${CellUnblockDurtion}  ${cell_idx}=1
#    KW.CaseStatusInit    retry_times=${retry_times}
    set test variable    ${CasePassRateStatus}     NotExecute
    set test variable    ${CaseAVGLoop_blockcell}     ${0}
    set test variable    ${CaseSUM_blockcell}         ${0}
    set test variable    ${CaseAVGLoop_unblockcell}     ${0}
    set test variable    ${CaseSUM_unblockcell}        ${0}
    @{BlockCellDurationList}=  Create List
    @{UnblockCellDurationList}=  Create List
    set test variable    ${BlockCellDuration_Min}    5000
    set test variable    ${BlockCellDuration_Max}    0
    set test variable    ${UnblockCellDuration_Min}    5000
    set test variable    ${UnblockCellDuration_Max}    0
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        log to console    Case loop ${i+1}:Step1: Trigger cell block and start BTSLog
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
        Log To Console    Case loop ${i+1}:Step2: Check blockcell_duration
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
        Append To List    ${BlockCellDurationList}    ${blockcell_duration}
        log to console    ${BlockCellDurationList}
        AppendCaseResultToFile    index=NRCELL_${cell_idx}_block
        ...    target_value=${CellBlockDuration}    result_value=${blockcell_duration}
        run keyword and continue on failure    Should Be True
        ...    ${blockcell_duration}<=${CellBlockDuration} and ${blockcell_duration}>${0}
        log to console   blockcell duration is ${blockcell_duration}

        #    KW.CaseStatusCaluate    duration=${blockcell_duration}    max=${CellBlockDurtion}
        ${CaseSUM_blockcell}        run keyword if    ${blockcell_duration}<=${CellBlockDuration}
        ...    Evaluate    ${CaseSUM_blockcell}+${blockcell_duration}
        ...    ELSE    Set Variable    ${CaseSUM_blockcell}
        ${CaseAVGLoop_blockcell}    run keyword if    ${blockcell_duration}<=${CellBlockDuration}
        ...    Evaluate    ${CaseAVGLoop_blockcell}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_blockcell}
        Set test Variable    ${CaseSUM_blockcell}    ${CaseSUM_blockcell}
        Set test Variable    ${CaseAVGLoop_blockcell}    ${CaseAVGLoop_blockcell}

        log to console    Case loop ${i+1}:Step3: Trigger cell unblock and start BTSLog
        BtsLog.StartBTSlogCollection
    #    ${CheckString_UnBlock}    set variable     "Write auditlog for UNBLOCK_IND|has been changed from Offline to Online"
    #    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    #    run    command=tail -f /tmp/btslog2/SYSLOG_*.LOG | grep -E ${CheckString_UnBlock} > /tmp/BTSLOG_unblockcell.txt&
        COAM_WebEM.Login
        selenium_sbts.unblock_cell     cell_idx=${cell_idx}
#        Sleep    20s
        COAM_WebEM.Logout
        wait until keyword succeeds    5min    10s     COAM_Admin.CheckAllCellsOnair
        run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
        Log To Console    Case loop ${i+1}:Step4: Check unblockcell_duration
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
        Append To List    ${UnblockCellDurationList}    ${unblockcell_duration}
        log to console    ${UnblockCellDurationList}
        AppendCaseResultToFile    index=NRCELL_${cell_idx}_unblock
        ...    target_value=${CellUnblockDurtion}    result_value=${unblockcell_duration}
        run keyword and continue on failure    Should Be True
        ...    ${unblockcell_duration}<=${CellUnblockDurtion} and ${unblockcell_duration}>${0}
        log to console   unblockcell duration is ${unblockcell_duration}
        KW.CPKPILoopEnd    loop=${i}
    #    KW.CaseStatusCaluate    duration=${unblockcell_duration}    max=${CellUnblockDurtion}
        ${CaseSUM_unblockcell}        run keyword if    ${unblockcell_duration}<=${CellUnblockDurtion}
        ...    Evaluate   ${CaseSUM_unblockcell}+${unblockcell_duration}
        ...    ELSE    Set Variable    ${CaseSUM_unblockcell}
        ${CaseAVGLoop_unblockcell}    run keyword if    ${unblockcell_duration}<=${CellUnblockDurtion}
        ...    Evaluate    ${CaseAVGLoop_unblockcell}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_unblockcell}
        Set test Variable    ${CaseSUM_unblockcell}    ${CaseSUM_unblockcell}
        Set test Variable    ${CaseAVGLoop_unblockcell}    ${CaseAVGLoop_unblockcell}

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result1}  set variable if    ${unblockcell_duration}>${CellUnblockDurtion}   failed    pass
        ${result2}  set variable if    ${blockcell_duration}>${CellBlockDuration}   failed    pass
        Run Keyword if   '${result1}'!='pass' or '${result2}'!='pass' or '${alarm_result}'=='False'
         ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for cell    loop=${i+1}    index=${cell_idx}
        Run Keyword And Continue On Failure    Run keyword if    '${result1}'!='pass' or '${result2}'!='pass'   Fail
        ...    KPI#17 value is above target
    END
#    KW.CPKPICaseEnd    times=${retry_times}    OAM_KPI_TARGETS=${KPI_TARGET}
    log to console    ${BlockCellDurationList}
    log to console    ${UnblockCellDurationList}
    ${durationLength}=    Get length      ${BlockCellDurationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
        ${BlockCellDuration_Max}=    set variable if   ${BlockCellDurationList[${i}]}>=${BlockCellDuration_Max}
        ...    ${BlockCellDurationList[${i}]}    ${BlockCellDuration_Max}
        ${BlockCellDuration_Min}=    set variable if   ${BlockCellDurationList[${i}]}<=${BlockCellDuration_Min}
        ...    ${BlockCellDurationList[${i}]}    ${BlockCellDuration_Min}
        ${UnblockCellDuration_Max}=    set variable if   ${UnblockCellDurationList[${i}]}>=${UnblockCellDuration_Max}
        ...    ${UnblockCellDurationList[${i}]}    ${UnblockCellDuration_Max}
        ${UnblockCellDuration_Min}=    set variable if   ${UnblockCellDurationList[${i}]}<=${UnblockCellDuration_Min}
        ...    ${UnblockCellDurationList[${i}]}    ${UnblockCellDuration_Min}
    END
#    set test variable     ${kpi_max}     ${duration_max}
#    set test variable     ${kpi_min}     ${duration_min}
    ${BlockCellKpi_Max}    evaluate    round(${BlockCellDuration_Max},2)
    ${BlockCellKpi_Min}    evaluate    round(${BlockCellDuration_Min},2)
    ${UnblockCellKpi_Max}    evaluate    round(${UnblockCellDuration_Max},2)
    ${UnblockCellKpi_Min}    evaluate    round(${UnblockCellDuration_Min},2)
#    ${BlockCellKpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${CellBlockDurtion}   max_loop=1
    ${BlockCellKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_blockcell}>0   Evaluate    ${CaseSUM_blockcell}/${CaseAVGLoop_blockcell}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${BlockCellKpi_aver_tmp}<=${CellBlockDuration}
    ${BlockCellKpi_aver}    evaluate    round(${BlockCellKpi_aver_tmp},2)
#    ${UnblockCellKpi_aver_tmp}    KW.CaseStatusFinnal    case_avg=${CellUnblockDurtion}   max_loop=1
    ${UnblockCellKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_unblockcell}>0   Evaluate    ${CaseSUM_unblockcell}/${CaseAVGLoop_unblockcell}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${UnblockCellKpi_aver_tmp}<=${CellUnblockDurtion}
    ${UnblockCellKpi_aver}    evaluate    round(${UnblockCellKpi_aver_tmp},2)
    Get common infos    kpi=KPI17a_Cell_${cell_idx}   kpi_max=${BlockCellKpi_Max}    kpi_min=${BlockCellKpi_Min}    kpi_aver=${BlockCellKpi_aver}
    Get common infos    kpi=KPI17b_Cell_${cell_idx}   kpi_max=${UnblockCellKpi_Max}   kpi_min=${UnblockCellKpi_Min}    kpi_aver=${UnblockCellKpi_aver}

KW.CB006939_HA_05_OAM_KPI_17a_Cell_Block
    [Arguments]   ${retry_times}    ${CellBlockDuration}   ${cell_idx}=1
    set test variable    ${CasePassRateStatus}     NotExecute
    set test variable    ${CaseAVGLoop_blockcell}     ${0}
    set test variable    ${CaseSUM_blockcell}         ${0}
    @{BlockCellDurationList}=  Create List
    set test variable    ${BlockCellDuration_Min}    5000
    set test variable    ${BlockCellDuration_Max}    0
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        AlarmWatchdog.add_allow_alarms    fault_id=49
        log to console    Case loop ${i+1}:Step1: Trigger cell block and start BTSLog
        BtsLog.StartBTSlogCollection
        COAM_WebEM.Login
        selenium_sbts.block_cell     cell_idx=${cell_idx}
        Sleep    20s
        run keyword and ignore error    COAM_WebEM.Logout
        run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog

        log to console    Case loop ${i+1}:Step2: Recovery cell to unblock
        COAM_WebEM.Login
        selenium_sbts.unblock_cell     cell_idx=${cell_idx}
        Sleep    10s
        run keyword and ignore error    COAM_WebEM.Logout
        wait until keyword succeeds    5min    10s     COAM_Admin.CheckAllCellsOnair
        AlarmWatchdog.remove_allow_alarms    fault_id=49

        Log To Console    Case loop ${i+1}:Step3: Check blockcell_duration
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
        Append To List    ${BlockCellDurationList}    ${blockcell_duration}
        log to console    ${BlockCellDurationList}
        AppendCaseResultToFile    index=NRCELL_${cell_idx}_block
        ...    target_value=${CellBlockDuration}    result_value=${blockcell_duration}
        run keyword and continue on failure    Should Be True
        ...    ${blockcell_duration}<=${CellBlockDuration} and ${blockcell_duration}>${0}
        log to console   blockcell duration is ${blockcell_duration}
        Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}
        #    KW.CaseStatusCaluate    duration=${blockcell_duration}    max=${CellBlockDurtion}
        ${CaseSUM_blockcell}        run keyword if    ${blockcell_duration}<=${CellBlockDuration}
        ...    Evaluate    ${CaseSUM_blockcell}+${blockcell_duration}
        ...    ELSE    Set Variable    ${CaseSUM_blockcell}
        ${CaseAVGLoop_blockcell}    run keyword if    ${blockcell_duration}<=${CellBlockDuration}
        ...    Evaluate    ${CaseAVGLoop_blockcell}+${1}
         ...    ELSE    Set Variable    ${CaseAVGLoop_blockcell}
        Set test Variable    ${CaseSUM_blockcell}    ${CaseSUM_blockcell}
        Set test Variable    ${CaseAVGLoop_blockcell}    ${CaseAVGLoop_blockcell}

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${blockcell_duration}>${CellBlockDuration}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
         ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for cell    loop=${i+1}    index=${cell_idx}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#17a value is above target
    END
    log to console    ${BlockCellDurationList}
    ${durationLength}=    Get length      ${BlockCellDurationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
        ${BlockCellDuration_Max}=    set variable if   ${BlockCellDurationList[${i}]}>=${BlockCellDuration_Max}
        ...    ${BlockCellDurationList[${i}]}    ${BlockCellDuration_Max}
        ${BlockCellDuration_Min}=    set variable if   ${BlockCellDurationList[${i}]}<=${BlockCellDuration_Min}
        ...    ${BlockCellDurationList[${i}]}    ${BlockCellDuration_Min}
    END
    ${BlockCellKpi_Max}    evaluate    round(${BlockCellDuration_Max},2)
    ${BlockCellKpi_Min}    evaluate    round(${BlockCellDuration_Min},2)
    ${BlockCellKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_blockcell}>0   Evaluate    ${CaseSUM_blockcell}/${CaseAVGLoop_blockcell}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${BlockCellKpi_aver_tmp}<=${CellBlockDuration}
    ${BlockCellKpi_aver}    evaluate    round(${BlockCellKpi_aver_tmp},2)
    Get common infos    kpi=KPI17a_Cell_${cell_idx}   kpi_max=${BlockCellKpi_Max}    kpi_min=${BlockCellKpi_Min}    kpi_aver=${BlockCellKpi_aver}

KW.CB006939_HA_06_OAM_KPI_17b_Cell_Unblock
    [Arguments]   ${retry_times}   ${CellUnblockDurtion}   ${cell_idx}=1
#    KW.CaseStatusInit    retry_times=${retry_times}
    set test variable    ${CasePassRateStatus}     NotExecute
    set test variable    ${CaseAVGLoop_unblockcell}     ${0}
    set test variable    ${CaseSUM_unblockcell}        ${0}
    @{UnblockCellDurationList}=  Create List
    set test variable    ${UnblockCellDuration_Min}    5000
    set test variable    ${UnblockCellDuration_Max}    0
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.CPKPILoopStart
        AlarmWatchdog.add_allow_alarms    fault_id=49
        log to console    Case loop ${i+1}:Step1: Trigger cell block
        COAM_WebEM.Login
        selenium_sbts.block_cell     cell_idx=${cell_idx}
        Sleep    20s
        run keyword and ignore error    COAM_WebEM.Logout
        log to console    Case loop ${i+1}:Step2: Trigger cell unblock and start BTSLog
        BtsLog.StartBTSlogCollection
        COAM_WebEM.Login
        selenium_sbts.unblock_cell     cell_idx=${cell_idx}
        Sleep    10s
        run keyword and ignore error     COAM_WebEM.Logout
        wait until keyword succeeds    5min    10s     COAM_Admin.CheckAllCellsOnair
        run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
        AlarmWatchdog.remove_allow_alarms    fault_id=49
        Log To Console    Case loop ${i+1}:Step3: Check unblockcell_duration
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
        Append To List    ${UnblockCellDurationList}    ${unblockcell_duration}
        log to console    ${UnblockCellDurationList}
        AppendCaseResultToFile    index=NRCELL_${cell_idx}_unblock
        ...    target_value=${CellUnblockDurtion}    result_value=${unblockcell_duration}
        run keyword and continue on failure    Should Be True
        ...    ${unblockcell_duration}<=${CellUnblockDurtion} and ${unblockcell_duration}>${0}
        log to console   unblockcell duration is ${unblockcell_duration}
        Run Keyword And Ignore error    KW.CPKPILoopEnd    loop=${i}

        ${CaseSUM_unblockcell}        run keyword if    ${unblockcell_duration}<=${CellUnblockDurtion}
        ...    Evaluate   ${CaseSUM_unblockcell}+${unblockcell_duration}
        ...    ELSE    Set Variable    ${CaseSUM_unblockcell}
        ${CaseAVGLoop_unblockcell}    run keyword if    ${unblockcell_duration}<=${CellUnblockDurtion}
        ...    Evaluate    ${CaseAVGLoop_unblockcell}+${1}
        ...    ELSE    Set Variable    ${CaseAVGLoop_unblockcell}
        Set test Variable    ${CaseSUM_unblockcell}    ${CaseSUM_unblockcell}
        Set test Variable    ${CaseAVGLoop_unblockcell}    ${CaseAVGLoop_unblockcell}

        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ${result}  set variable if    ${unblockcell_duration}>${CellUnblockDurtion}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
         ...    Run Keyword And Ignore error    WEBUI.Collect snapshot for cell    loop=${i+1}    index=${cell_idx}
        Run Keyword And Continue On Failure    Run keyword if    '${result}'!='pass'    Fail
        ...    KPI#17b value is above target
    END
    log to console    ${UnblockCellDurationList}
    ${durationLength}=    Get length      ${UnblockCellDurationList}
    FOR    ${i}    IN RANGE    0     ${durationLength}
        ${UnblockCellDuration_Max}=    set variable if   ${UnblockCellDurationList[${i}]}>=${UnblockCellDuration_Max}
        ...    ${UnblockCellDurationList[${i}]}    ${UnblockCellDuration_Max}
        ${UnblockCellDuration_Min}=    set variable if   ${UnblockCellDurationList[${i}]}<=${UnblockCellDuration_Min}
        ...    ${UnblockCellDurationList[${i}]}    ${UnblockCellDuration_Min}
    END
    ${UnblockCellKpi_Max}    evaluate    round(${UnblockCellDuration_Max},2)
    ${UnblockCellKpi_Min}    evaluate    round(${UnblockCellDuration_Min},2)
    ${UnblockCellKpi_aver_tmp}    run keyword if     ${CaseAVGLoop_unblockcell}>0   Evaluate    ${CaseSUM_unblockcell}/${CaseAVGLoop_unblockcell}
    ...      ELSE     set variable    ${3600}
    run keyword and continue on failure    should be true    ${UnblockCellKpi_aver_tmp}<=${CellUnblockDurtion}
    ${UnblockCellKpi_aver}    evaluate    round(${UnblockCellKpi_aver_tmp},2)
    Get common infos    kpi=KPI17b_Cell_${cell_idx}   kpi_max=${UnblockCellKpi_Max}   kpi_min=${UnblockCellKpi_Min}    kpi_aver=${UnblockCellKpi_aver}

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
    run keyword and continue on failure    Should be true    ${duration_1}<${CellLockUnLockDurtion} and ${duration_2}<${CellLockUnLockDurtion}
#######################################  5GC002479-IA   SWM  #######################################
KW.SWM.PrepareOriginalENVbyYAFT
    [Arguments]    ${build_version}
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    ${Smods}    COAM_Admin.GetBTSTopology
    ${length}=   Get Length   ${Smods}
    run keyword if    ${build_version.count('${TargetStream}')}>0    Set Suite Variable    ${gSCF}    ${OldCommissionSCF}
    ...    ELSE       Set Suite Variable    ${gSCF}    ${OriginalStreamSCF}
#    run keyword if  '${length}'=='1'      KW.SWM.PrepareOriginalBuildEnv    build_version=${build_version}    scf=${gSCF}
#    ...    ELSE    KW.SWM.PrepareENVDualCore    build_version=${build_version}
    KW.SWM.PrepareOriginalBuildEnv    build_version=${build_version}    scf=${gSCF}
    run keyword and ignore error    run    command=rm -rf ${UPDATE_FILE_PATH}/*
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog

KW.SWM.PrepareENVDualCore
    [Arguments]    ${build_version}
    ${SecondaryUTEVMIP}       set variable    ${CASE_INPUT_5GC002479['5GC002479_IA']['SecondaryUTEVMIP']}
	log to console    !!!!!!!!!!!!ConfigurationReset!!!!!!!!!!!!!!!!
	KW.SWM.ConfigurationClear
#	COAM_Admin.Login
#	coam.reset_configuration    connection=COAM
#	run keyword and ignore error    COAM_Admin.Logout
#    COAM_WebEM.Login    version=${sbts_stream}
#    selenium_coam.configuration_reset
#    Run Keyword And Return Status    COAM_WebEM.Logout
    ssh.Connect to    hostname=${ASIK_IP}   username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}   alias=${ALIAS_ASIK}
    ssh.send command    command=cd /rom/config&&rm -rf *&&reboot  connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error    Conn.Disconnect    alias=${ALIAS_ASIK}
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
    run keyword and ignore error   KW.SWM.COAM_WebEM.LoginWithSync    button=Start sync  url=${ASIK_LMP_IP_URL}
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    ${gnb_status}   KW.SWM.GetGNBStatus
    run keyword and ignore error    COAM_Admin.Logout
    Run Keyword If   '${gnb_status}'=='NotCommissioned'    wait until keyword succeeds    30min    60s
    ...    gNB.Commission   scf_file=${scf}
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
    [Arguments]    ${vstring}=${AF_PATH}
#    ${version_Target}          get regexp matches    ${AF_PATH}     [0-9]+.[0-9]+.[0-9]+
#    set suite variable    ${TARGETSW}    ${version_Target[0]}
#    ${StreamTarget}         Get Regexp Matches     ${TARGETSW}     [0-9]+.[0-9]+
    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion     vstring=${vstring}
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
    set suite variable     ${SWM_KPI57b}     ${0}
    set suite variable     ${SWM_KPI57c}     ${0}
    set suite variable     ${SWM_KPI57d}     ${0}
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

KW.SWM.CheckIfDUSWActiveRun
    [Arguments]      ${stream}=${TargetStream}   ${conditions}=&{condition_PS_same}
     Run keyword if    ${SWM}==${0}    TC.CB012803_DU_Software_Upgrade    stream=${stream}   conditions=${conditions}
     Run keyword if    ${SWM}<${3}     Fail    Step SW active not execute

KW.SWM.CheckIfRUSWActiveRun
    [Arguments]      ${stream}=${TargetStream}   ${conditions}=&{condition_ru_diff}    ${cell}=${CellIndex}
    TC.CB012803_RU_Software_Upgrade    stream=${stream}   conditions=${conditions}   cell=${cell}

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
    ${RUadjVlaue}=    Create Dictionary   AdjValues=0  AdjValueResetSite=0  AdjValueResetBBMOD=0  AdjValueCellBlockUnblock=0
    ...    AdjValueCellLockUnlock=0  AdjValueCellReset=0  AdjValueCellLocking=0   AdjValueSWActivation=0
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
    ${SFPAdjVlaue}=    Create Dictionary   AdjValues=0
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

#KW.GetRUAdjBySiteCellNums
#    [Arguments]   ${AdjRMOD}
#    scf.Load_Scf  file_path=${BACKUP_SCF}
#    ${BTSInfo}=     COAM_Admin.GetBTSInfo
#    Set Test Variable   ${CellNumsInSite}    0
#    FOR  ${item}  IN  @{BTSInfo['cells']['nr']}
#        ${rmodlist}  scf.get_value_from_scf    dist_name=${item['id']['configuration']}    list_name=rModDNList
#        ${config}=    Split String From Right    ${rmodlist}     /
#        ${RMOD_ID}    Set Variable   ${config[-1]}
#        ${RMODName}    KW.GetRMODNameByID     RMOD_ID=${RMOD_ID}
#        ${CellNumsInSite}    run keyword if   '${RMODName}'=='${AdjRMOD}'   Evaluate    ${CellNumsInSite}+1
#        ...    ELSE    Set Variable    ${CellNumsInSite}
#    END
#    ${ValueRUAdjBySiteCellNums}    Evaluate   ${CellNumsInSite}*30
#    [Return]    ${ValueRUAdjBySiteCellNums}

KW.GetSFPCooledInfoOnRU
    [Arguments]   ${RU_INDEX}
    coam_webem.login
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
        ${SFPInfo}=    selenium_sbts.get_hw_info    hw_name=${hw_name}    connector=${connector}
        ${SFPCooledInfo}=    Set Variable    ${SFPInfo['Cooled Transceiver Declaration']}
        Exit For Loop If    "${SFPCooledInfo}"=="true"
    END
#    coam_webem.login
#         ${SFPInfo}=    selenium_sbts.get_hw_info    hw_name=${hw_name}    connector=${connector}
#         ${SFPCooledInfo}=    Set Variable    ${SFPInfo['Cooled Transceiver Declaration']}
    coam_webem.logout
    [Return]    ${SFPCooledInfo}

KW.GetSFPCooledInfoOnBBMOD
    [Arguments]   ${BBMOD_INDEX}
    coam_webem.login
    ${BTSInfo}=     COAM_Admin.GetBTSInfo
    FOR    ${CABLE}   IN    @{BTSInfo['cables']}
        ${cable_firstEndPoint_config}=    Split String From Right    ${CABLE['firstEndPointId']['configuration']}     /
        ${firstEndPoint}   Set Variable     ${cable_firstEndPoint_config[-1]}
        Continue For Loop If    '${firstEndPoint}'=='RF_EXT'
        ${cable_bbmod}   Set Variable     ${cable_firstEndPoint_config[-2]}
        ${cable_firstEndPoint_internal}=    Split String From Right    ${CABLE['firstEndPointId']['internal']}     /
        ${cable_bbmod_internal}   Set Variable     ${cable_firstEndPoint_internal[-2]}
        ${tmp_bbmod}=    Split String From Right    ${cable_bbmod}     -
        ${CABLE_BBMOD_INDEX}   Set Variable     ${tmp_bbmod[-1]}
        Continue For Loop If    '${CABLE_BBMOD_INDEX}'!='${BBMOD_INDEX}'
        ${firstEndPoint_hw_name}=    Set Variable    ${cable_bbmod} / ${cable_bbmod_internal}
        ${firstEndPoint_connector}=    Set Variable    ${firstEndPoint}
        ${SFPInfo}=    selenium_sbts.get_hw_info    hw_name=${firstEndPoint_hw_name}    connector=${firstEndPoint_connector}
        ${SFPCooledInfo}=    Set Variable    ${SFPInfo['Cooled Transceiver Declaration']}
        Exit For Loop If    "${SFPCooledInfo}"=="true"
    END
#    coam_webem.login
#         ${SFPInfo}=    selenium_sbts.get_hw_info    hw_name=${firstEndPoint_hw_name}    connector=${firstEndPoint_connector}
#         ${SFPCooledInfo}=    Set Variable    ${SFPInfo['Cooled Transceiver Declaration']}
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
        ${SFPCooledInfo_firstEndPoint}=    Set Variable if    "${firstEndPoint_connector}"=="RF_EXT"    false
        ...    ${SFPInfo_firstEndPoint['Cooled Transceiver Declaration']}
        ${SFPCooledInfo_secondEndPoint}=    Set Variable if    "${secondEndPoint_connector}"=="RF_EXT"    false
        ...    ${SFPInfo_secondEndPoint['Cooled Transceiver Declaration']}

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
#        ${ValueRUAdjBySiteCellNums}      KW.GetRUAdjBySiteCellNums    AdjRMOD=${AdjRMOD}
        ${ValueRUAdjByBBMODCellNums}     KW.GetRUAdjByBBMODCellNums    RMODs=${RMODsList}    AdjRMOD=${AdjRMOD}
        ${ValueRUAdjByRMODCellNums}     KW.GetRUAdjByRMODCellNums    RMODs=${RMODsList}    AdjRMOD=${AdjRMOD}
#        ${ValueRUAdjByCellNums}     KW.GetRUAdjByCellNums    RMODs=${RMODsList}    AdjRMOD=${AdjRMOD}
        ${KPIAdjValue}    Copy Dictionary     dictionary=${ValueBase}   deepcopy=True
        ${Global_KPI1a_AVG_Formula}=   Catenate   ${ValueBase['KPI1a']['KPI1a_AVG']}+${ValueRUAdj['AdjValueResetSite']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI1a_AVG}=     Evaluate     ${Global_KPI1a_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI1a']}    KPI1a_AVG    ${Global_KPI1a_AVG}
        ${Global_KPI1a_MAX_Formula}=   Catenate   ${ValueBase['KPI1a']['KPI1a_MAX']}+${ValueRUAdj['AdjValueResetSite']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI1a_MAX}=     Evaluate     ${Global_KPI1a_MAX_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI1a']}   KPI1a_MAX    ${Global_KPI1a_MAX}
        ${Global_KPI3_AVG_Formula}=   Catenate   ${ValueBase['KPI3']['KPI3_AVG']}+${ValueRUAdj['AdjValueResetSite']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI3_AVG}=     Evaluate     ${Global_KPI3_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI3']}   KPI3_AVG    ${Global_KPI3_AVG}
        ${Global_KPI3_MAX_Formula}=   Catenate   ${ValueBase['KPI3']['KPI3_MAX']}+${ValueRUAdj['AdjValueResetSite']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI3_MAX}=     Evaluate     ${Global_KPI3_MAX_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI3']}   KPI3_MAX    ${Global_KPI3_MAX}
#        ${Global_KPI51a_AVG_Formula}=     Catenate    ${ValueBase['KPI51a']['KPI51a_AVG']}+${ValueRUAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}+
#        ...    ${ValueRUAdjByRMODCellNums}
#        ${Global_KPI51a_AVG}=    Evaluate    ${Global_KPI51a_AVG_Formula}
#        Set To Dictionary    ${KPIAdjValue['KPI51a']}   KPI51a_AVG    ${Global_KPI51a_AVG}
#        ${Global_KPI51a_MAX}    Evaluate      int(${Global_KPI51a_AVG}*1.2)
#        Set To Dictionary    ${KPIAdjValue['KPI51a']}   KPI51a_MAX    ${Global_KPI51a_MAX}
        ${Global_KPI51a_Formula}=   Catenate   ${ValueBase['KPI51a']}+${ValueRUAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI51a}=     Evaluate     ${Global_KPI51a_Formula}
        Set To Dictionary    ${KPIAdjValue}   KPI51a    ${Global_KPI51a}
#        ${Global_KPI54a_AVG_Formula}=     Catenate    ${ValueBase['KPI54a']['KPI54a_AVG']}+${ValueRUAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}+
#        ...    ${ValueRUAdjByRMODCellNums}
#        ${Global_KPI54a_AVG}=    Evaluate    ${Global_KPI54a_AVG_Formula}
#        Set To Dictionary    ${KPIAdjValue['KPI54a']}   KPI54a_AVG    ${Global_KPI54a_AVG}
#        ${Global_KPI54a_MAX}    Evaluate      int(${Global_KPI54a_AVG}*1.2)
#        Set To Dictionary    ${KPIAdjValue['KPI54a']}   KPI54a_MAX    ${Global_KPI54a_MAX}
        ${Global_KPI54a_Formula}=   Catenate   ${ValueBase['KPI54a']}+${ValueRUAdj['AdjValues']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI54a}=     Evaluate     ${Global_KPI54a_Formula}
        Set To Dictionary    ${KPIAdjValue}   KPI54a    ${Global_KPI54a}
        ${Global_KPI4_Formula}=   Catenate   ${ValueBase['KPI4']}
        ${Global_KPI4}=     Evaluate     ${Global_KPI4_Formula}
        Set To Dictionary    ${KPIAdjValue}   KPI4    ${Global_KPI4}
        ${Global_KPI2a_AVG_Formula}=   Catenate   ${ValueBase['KPI2a']['KPI2a_AVG']}+${ValueRUAdj['AdjValueSWActivation']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2a_AVG}=     Evaluate     ${Global_KPI2a_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2a']}    KPI2a_AVG    ${Global_KPI2a_AVG}
        ${Global_KPI2a_MAX_Formula}=   Catenate   ${ValueBase['KPI2a']['KPI2a_MAX']}+${ValueRUAdj['AdjValueSWActivation']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2a_MAX}=     Evaluate     ${Global_KPI2a_MAX_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2a']}    KPI2a_MAX    ${Global_KPI2a_MAX}
        ${Global_KPI2b_AVG_Formula}=   Catenate   ${ValueBase['KPI2b']['KPI2b_AVG']}+${ValueRUAdj['AdjValueSWActivation']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2b_AVG}=     Evaluate     ${Global_KPI2b_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2b']}    KPI2b_AVG    ${Global_KPI2b_AVG}
        ${Global_KPI2b_MAX_Formula}=   Catenate   ${ValueBase['KPI2b']['KPI2b_MAX']}+${ValueRUAdj['AdjValueSWActivation']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2b_MAX}=     Evaluate     ${Global_KPI2b_MAX_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2b']}    KPI2b_MAX    ${Global_KPI2b_MAX}
        ${Global_KPI2c_AVG_Formula}=   Catenate   ${ValueBase['KPI2c']['KPI2c_AVG']}+${ValueRUAdj['AdjValueSWActivation']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2c_AVG}=     Evaluate     ${Global_KPI2c_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2c']}    KPI2c_AVG    ${Global_KPI2c_AVG}
        ${Global_KPI2c_MAX_Formula}=   Catenate   ${ValueBase['KPI2c']['KPI2c_MAX']}+${ValueRUAdj['AdjValueSWActivation']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2c_MAX}=     Evaluate     ${Global_KPI2c_MAX_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2c']}    KPI2c_MAX    ${Global_KPI2c_MAX}
        ${Global_KPI2d_AVG_Formula}=   Catenate   ${ValueBase['KPI2d']['KPI2d_AVG']}+${ValueRUAdj['AdjValueSWActivation']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2d_AVG}=     Evaluate     ${Global_KPI2d_AVG_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2d']}    KPI2d_AVG    ${Global_KPI2d_AVG}
        ${Global_KPI2d_MAX_Formula}=   Catenate   ${ValueBase['KPI2d']['KPI2d_MAX']}+${ValueRUAdj['AdjValueSWActivation']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI2d_MAX}=     Evaluate     ${Global_KPI2d_MAX_Formula}
        Set To Dictionary    ${KPIAdjValue['KPI2d']}    KPI2d_MAX    ${Global_KPI2d_MAX}

#        ${Global_KPI2a_AVG}=    Evaluate    ${ValueBase['KPI2a']['KPI2a_AVG']}
#        Set To Dictionary    ${KPIAdjValue['KPI2a']}    KPI2a_AVG    ${Global_KPI2a_AVG}
#        ${Global_KPI2a_MAX}=    Evaluate    ${ValueBase['KPI2a']['KPI2a_MAX']}
#        Set To Dictionary    ${KPIAdjValue['KPI2a']}   KPI2a_MAX    ${Global_KPI2a_MAX}
#        ${Global_KPI2b_AVG}=    Evaluate    ${ValueBase['KPI2b']['KPI2b_AVG']}
#        Set To Dictionary    ${KPIAdjValue['KPI2b']}    KPI2b_AVG    ${Global_KPI2b_AVG}
#        ${Global_KPI2b_MAX}=    Evaluate    ${ValueBase['KPI2b']['KPI2b_MAX']}
#        Set To Dictionary    ${KPIAdjValue['KPI2b']}   KPI2b_MAX    ${Global_KPI2b_MAX}
#        ${Global_KPI2c_AVG}=    Evaluate    ${ValueBase['KPI2c']['KPI2c_AVG']}
#        Set To Dictionary    ${KPIAdjValue['KPI2c']}    KPI2c_AVG    ${Global_KPI2c_AVG}
#        ${Global_KPI2c_MAX}=    Evaluate    ${ValueBase['KPI2c']['KPI2c_MAX']}
#        Set To Dictionary    ${KPIAdjValue['KPI2c']}   KPI2c_MAX    ${Global_KPI2c_MAX}
#        ${Global_KPI2d_AVG}=    Evaluate    ${ValueBase['KPI2d']['KPI2d_AVG']}
#        Set To Dictionary    ${KPIAdjValue['KPI2d']}    KPI2d_AVG    ${Global_KPI2d_AVG}
#        ${Global_KPI2d_MAX}=    Evaluate    ${ValueBase['KPI2d']['KPI2d_MAX']}
#        Set To Dictionary    ${KPIAdjValue['KPI2d']}   KPI2d_MAX    ${Global_KPI2d_MAX}
#        ${Global_KPI5_Formula}=   Catenate   ${ValueBase['KPI5']}+${ValueRUAdj['AdjValueResetBBMOD']}+${ValueSFPAdj['AdjValues']}+
#        ...    ${ValueRUAdjByBBMODCellNums}
        ${Global_KPI5_Formula}=   Catenate   ${ValueBase['KPI5']}+${ValueRUAdj['AdjValueResetBBMOD']}+${ValueSFPAdj['AdjValues']}
        ${Global_KPI5}=     Evaluate     ${Global_KPI5_Formula}
        Set To Dictionary    ${KPIAdjValue}   KPI5    ${Global_KPI5}
        ${Global_KPI15}         Evaluate      ${ValueBase['KPI15']}+${ValueRUAdj['AdjValueCellLocking']}
        Set To Dictionary    ${KPIAdjValue}   KPI15    ${Global_KPI15}
        ${Global_KPI16a}         Evaluate      ${ValueBase['KPI16a']}+${ValueRUAdj['AdjValueCellLockUnlock']}
        Set To Dictionary    ${KPIAdjValue}   KPI16a    ${Global_KPI16a}
        ${Global_KPI16b}         Evaluate      ${ValueBase['KPI16b']}+${ValueRUAdj['AdjValueCellLockUnlock']}
        Set To Dictionary    ${KPIAdjValue}   KPI16b    ${Global_KPI16b}
        ${Global_KPI17a}         Evaluate      ${ValueBase['KPI17a']}+${ValueRUAdj['AdjValueCellBlockUnblock']}
        Set To Dictionary    ${KPIAdjValue}   KPI17a    ${Global_KPI17a}
        ${Global_KPI17b}         Evaluate      ${ValueBase['KPI17b']}+${ValueRUAdj['AdjValueCellBlockUnblock']}
        Set To Dictionary    ${KPIAdjValue}   KPI17b    ${Global_KPI17b}
        ${Global_KPI19}         Evaluate      ${ValueBase['KPI19']}+${ValueRUAdj['AdjValueCellReset']}
        Set To Dictionary    ${KPIAdjValue}   KPI19    ${Global_KPI19}
        ${Global_SW_Download_MAX}         Evaluate      ${ValueBase['SW_Download_MAX']}+0
        Set To Dictionary    ${KPIAdjValue}   SW_Download_MAX    ${Global_SW_Download_MAX}
   [Return]    ${KPIAdjValue}
#######################################CalculateKPI END#######################################
KW.DisableGracefulCellShutdown
     Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
     ${actGrflShdn_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/${NRBTS_ID}
     ...    Activate graceful cell shutdown
     run keyword if    '${actGrflShdn_org}'!='false'    selenium_coam.set_parameter_value     dist_name=${MRBTS_ID}/${NRBTS_ID}
     ...    filter_param=Activate graceful cell shutdown     new_value=false
     run keyword and ignore error   CM_WebEM.ValidateAndActiveParameters
     run keyword and ignore error    COAM_WebEM.Logout

KW.EnableGracefulCellShutdown
     Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
     ${actGrflShdn_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/${NRBTS_ID}
     ...    Activate graceful cell shutdown
     run keyword if    '${actGrflShdn_org}'!='true'    selenium_coam.set_parameter_value     dist_name=${MRBTS_ID}/${NRBTS_ID}
     ...    filter_param=Activate graceful cell shutdown     new_value=true
     run keyword and ignore error   CM_WebEM.ValidateAndActiveParameters
     run keyword and ignore error    COAM_WebEM.Logout

KW.EnableEnergyConsumptionMeasurement
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    run keyword and ignore error    selenium_sbts.remove_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    run keyword and ignore error    CM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1
    ...    object_class_name=PMMNL  id_value=1    timeout=60    is_load_default_values=true
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1   filter_param=SBTS Energy Consumption
    ...    new_value=${PMTIME}min
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1   filter_param=SBTS SM Energy Monitoring
    ...    new_value=${PMTIME}min
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1   filter_param=SBTS RFM energy monitoring
    ...    new_value=${PMTIME}min
    CM_WebEM.ValidateAndActiveParameters
     ${pm_interval_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    Performance measurement data reporting interval
     ${actPowerMeter_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    Power meter enabled
     run keyword if    '${pm_interval_org}'!='${PMTIME}min'    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    filter_param=Performance measurement data reporting interval     new_value=${PMTIME}min
     run keyword if    '${actPowerMeter_org}'!='true'    selenium_coam.set_parameter_value     dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
     ...    filter_param=Power meter enabled     new_value=true
     run keyword and ignore error   CM_WebEM.ValidateAndActiveParameters
     run keyword and ignore error    COAM_WebEM.Logout

KW.FetchCounter
    [Arguments]    @{counter_list}
    FOR  ${counter_id}  IN  @{counter_list}
        ${res}   selenium_coam.get_bts_counters_info   ${counter_id}
        log    ${res}
        ${values}    get dictionary values   ${res}
        log    ${values}
        log  The latest one is: ${values[-1]}
        ${status}    run keyword and continue on failure    should be true    ${values[-1]}>0
        ${case_status}    run keyword if    '${status}'=="None"
        ...    set variable    pass
        ...    ELSE    set variable    fail
        AppendCaseResultToFile    requirement_id=${counter_id}    target_value=NA    result_value=${values[-1]}    case_result=${case_status}
        Get common infos    kpi=${counter_id}   kpi_max=${values[-1]}    kpi_min=${values[-1]}    kpi_aver=${values[-1]}
        should be true    ${values[-1]}>0
    END


#######################################     #######################################

KW.TestSuilt.Start
    run keyword and ignore error    run    command=rm -rf /tmp/
    run keyword and ignore error    run    command=rm -rf /opt/ute/YAFT/YAFT_IMAGE/
    run keyword and ignore error    run    command=rm -rf /home/ute/Download_gNB_Package/
#    run keyword and ignore error    run    command=cd /opt/transformers.dynamic.nsn-net.net/ ; rm -rf *
    TestSuilt.Start
    Import Variables     ${CFGFILE_PATH}/TLConfiguration.py
    run keyword and Ignore error    KW.SWM.Init
    set suite variable    ${OAM_TYPE}    COAM
    set suite variable    ${TLDelta_PATH_ON_GIT}        ${CFGFILE_PATH}
    run keyword and ignore error    set suite variable    ${REFERENCE_CONFIGURATION_ID}
    ...    ${CASE_INPUT_5GC002479['REFERENCE_CONFIGURATION_ID']}
    gNB.FormatBTSID       MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    set suite variable    ${AdjRMOD}   None
    set suite variable    ${GracefulCellShutdown}   WithOut_GracefulCellShutdown
#    ${res}    Run Keyword And Ignore error    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${TLDelta_PATH_ON_GIT}
#	...                  TestLineSCF_cell_num=${2}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
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
    KW.DisableGracefulCellShutdown
    ${BACKUP_SCF}   COAM_Admin.BackupSCF
    set suite variable    ${BACKUP_SCF}

    ${version}    Basic.GetStreamAndVersion
    log    ${version}
    set suite variable    ${sbts_version}   ${version[1]}

    @{suite_name}    Split String    ${SUITE SOURCE}    /
    @{suite_name}    Split String    ${suite_name[-1]}    .

    ${stream}   ${subversion}    Split String   string=${version[1]}   separator=_     max_split=1
#    ${stream}    set variable if   '${stream}'>='SBTS22R2'    SBTS22R2    SBTS21B
    set suite variable    ${sbts_stream}    ${stream}

    @{version_total}    Split String   string=${version[1]}   separator=_     max_split=3
    set suite variable    ${version_number}    ${version_total[3]}
    log    ${version_number}

    set suite variable    ${case_result_save_path}    ${CASE_RESULT_FLIE_PATH}${testline_name}_${suite_name[0]}_${version[1]}.csv
    Create File    ${case_result_save_path}

    ${file_head}    Catenate    SEPARATOR=,    case name    requirement id    index    Ru type    Ru index
    ...    target value    result value    case result\n
    Append To File    ${case_result_save_path}    ${file_head}



KW.TestSuilt.Stop
    TestSuilt.Stop

TestCase.Start_2479
    TestCase.Start
#    KW.DisableGracefulCellShutdown
    Run Keyword And Ignore error      COAM_WebEM.Login
    ${onair_check}    run keyword and return status     COAM_WebEM.VerifyAllCellsAreOnlineFor2479
    Run keyword if    '${onair_check}'=='False'     Do site reset to recovery gnb and Check cells onair
    ...    ELSE IF    '${onair_check}'=='True'      log     gnb is onair
    Run Keyword And Ignore error      COAM_WebEM.Logout
    KW.CleanFirefox

TestCase.Start_WithOut_GracefulCellShutdown
    TestCase.Start
    KW.DisableGracefulCellShutdown
    set test variable    ${graceful_cell_shutdown}    False
    Run Keyword And Ignore error      COAM_WebEM.Login
    ${onair_check}    run keyword and return status     COAM_WebEM.VerifyAllCellsAreOnlineFor2479
    Run keyword if    '${onair_check}'=='False'     Do site reset to recovery gnb and Check cells onair
    ...    ELSE IF    '${onair_check}'=='True'      log     gnb is onair
    Run Keyword And Ignore error      COAM_WebEM.Logout
    KW.CleanFirefox

TestCase.Start_With_GracefulCellShutdown
    TestCase.Start
    KW.EnableGracefulCellShutdown
    set test variable    ${graceful_cell_shutdown}    True
    Run Keyword And Ignore error      COAM_WebEM.Login
    ${onair_check}    run keyword and return status     COAM_WebEM.VerifyAllCellsAreOnlineFor2479
    Run keyword if    '${onair_check}'=='False'     Do site reset to recovery gnb and Check cells onair
    ...    ELSE IF    '${onair_check}'=='True'      log     gnb is onair
    Run Keyword And Ignore error      COAM_WebEM.Logout
    KW.CleanFirefox

Do site reset to recovery gnb and Check cells onair
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    COAM_Admin.ResetSite     timeout=1800
    Check all cells Should Be On Air
    Run Keyword And Ignore Error    COAM_WebEM.Logout

TestCase.Set_Case_Variable
    [Arguments]    ${vstring}=${AF_PATH}
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA']['SecondaryUTEVMIP']
#    ...                         default_value=1.1.1.1
    ${version_Target}    Basic.GetStreamAndVersion     vstring=${vstring}
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
