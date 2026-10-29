*** Settings ***
Documentation       This Test script is dedicated for CB009409 TCP boost PUG Requirements. 
...                 5G_RAN_USR_RRM_18942, 5G_RAN_USR_RRM_18943, 5G_RAN_USR_RRM_18947, 5G_RAN_USR_RRM_18946
...                 Maintainer: MN RAN Pz BLR 2 SG 
...                 Author: arunkumar.a@nokia.com

Library         Collections 
Library         OperatingSystem
Library         DateTime
Library         testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    uc
Library         taf.sbts.oam.coam.admin    WITH NAME    admin
Library         taf.sw.dcap.rd    WITH NAME    rd
Library         taf.collectors.core   WITH NAME   core
Library         taf.collectors.btslog  WITH NAME   btslog
Library         testsuite/Bangalore/ORAN/resources/python/SysValidation.py     WITH NAME     vdn

Resource        taf/rfrl/common_resources/common_step/interface.robot

Force Tags        SBTS00  CRT        

Test Setup        Test_Setup_keywords
Test Teardown     Test_Teardown_Keywords

*** Variables ***
@{UE_alias}                        UE_3    # UE_1 = Skippable ue & UE_2= Non skippable
@{capabilities}                    Legacy_3
${timeout}                         300
${scf_commission_file_1}           ${SCF_PATH}/scf_for_CB009409_testing.xml
${scf_commission_file_VoNR}        ${SCF_PATH}/Vonr_scf_for_CB009409.xml
${SCF_PATH}                        ${TEST_PATH}/SCF
${BTS_ID}                          11008
@{Protocol_Type}                   FTP
@{DIRECTION}                       dl
${ABSTRACT_LIB_CONFIG}             ${TEST_PATH}/UE/ta_ue_config.yaml
&{BTS_Details}                     bts_host=192.168.255.129
...                                bts_port=443
...                                username=Nemuadmin
...                                password=nemuuser
...                                use_ssl=True
...                                update_interval=5000 
...                                admin_api_log_dir=${EXECDIR} 
...                                name=default
...                                bundle_path=None
...                                release=SBTS00
...                                timeout=30
&{Dcap_Server_Details}             host=10.41.209.120
...                                port=443    secure=True    Alias=GNB_1
...                                username=dcapuser    password=dcapadmin!
&{Dcap_User_Details}               host=10.58.239.183    port=443    
...                                username=Nemuadmin    password=nemuuser
@{Only_Gnb_custom_profile}         cp_5g    L2Ps_Component    L2Lo_Component    
...                                L2HiRlc_Component    L2HiPdcp_Component   
@{Bts_custom_profile}              immediateSnapshot    scf    pmFiles    ipCapture
${OUT_SUITE_LOGS_DIR_PATH}                  ${TEMPDIR}/dcaplog
${Dict_MOC_PATH}                            MRBTS-11008/NRBTS-11008/NRCELL-4  
${PARAMETER_KEY}                            actTcpBoostPug
${9409_Disable}                             disabled
${9409_allUes}                              allUes
${9409_onlyskippable}                       onlySkippableGrantCapableUes
${VoNR_TESTCASE_IN_ULTRACALLER}             VONR_Server_Call 
${BTSLOG}                                   btslog
${TCP_Boost_PUG_Activated}                  TCP Boost Data Burst detected. TCP Boost PUG state Activated
${TCP_Boost_PUG_VoNR}                       VoNr Proactive Grant elegibility check fail srPeriodity
${5QI5}                                     fiveQi: 5
${5QI1}                                     fiveQi: 1
${CS_Entry_validation}                      CS1 Entry for TCP PUG
@{Counters_list}                            M55308C00038  M55308C00039  M55308C00040  M55308C00042	
${BTSLOG_Path_for_validation}               ${TEST_PATH}/btslog
${TEST_PATH}                                testsuite/Bangalore/RRM/5GST_BLR/SG02/5G_CRT
*** Test Cases ***

[CB009409-A.01]Enable & Disable of TCP Boost PUG for all UEs 
    [Documentation]    This Testcase have Feature Disable, allUes and onlySkippableGrantCapableUes functionality.
    ...        Moreover, Loging part takecare from DCAP-LITE and Syslog legacy method used for validation purpose.  
    [Tags]    5G_RAN_USR_RRM_18943    5G_PM_953

    SCF_Commission     ${scf_commission_file_1}
    Sleep    200 s    BTS may need some time to update scf file.
    start Btslogs from Local machine    ${BTSLOG}     
    Get_Feature_Activation    ${Dict_MOC_PATH}    ${PARAMETER_KEY}    value=${9409_allUes}
    Sleep    120 s    BTS may need some time to update scf file.
    uc.Require UE    ${UE_alias}    ${capabilities} 
    ${Detached_output}    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE     ue_alias=${UE_alias}   
    ${attach_UE}    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    ue_alias=${UE_alias}
    Sleep    120 s
    FTP_dl_data_transfer    ${UE_alias}    ${Protocol_Type}    ${DIRECTION}
    Sleep    60 s    FTP File transfer should be complete.
    ${Detached_output}    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE     ue_alias=@{UE_alias}
    Stops Btslogs from Local machine    ${BTSLOG}
#    Verification_btslog    ${TCP_Boost_PUG_Activated}
#    Verification_btslog    ${CS_Entry_validation}

    start Btslogs from Local machine    ${BTSLOG}     
    ${attach_UE}    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    ue_alias=@{UE_alias}   
    Get_Feature_Activation    ${Dict_MOC_PATH}    ${PARAMETER_KEY}    value=${9409_onlyskippable}    
    Sleep    180 s    BTS may need some time to update scf file.    
    FTP_dl_data_transfer    ${UE_alias}    ${Protocol_Type}    ${DIRECTION} 
    PM_Counter_Check_Validation     
    ${Detached_output}    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE     ue_alias=@{UE_alias}
    Stops Btslogs from Local machine    ${BTSLOG}
#    Verification_btslog    ${TCP_Boost_PUG_Activated}
#    Verification_btslog    ${CS_Entry_validation}

[CB009409-B.02]Verification of UE with VoNR proactive grants do not get TCP Boost PUG
    [Documentation]    Test belong to VoNR functionality and 5QI Validation
    [Tags]    5G_RAN_USR_RRM_19080  5G_RAN_USR_RRM_18946
    SCF_Commission     ${scf_commission_file_VoNR}
    Sleep    200 s    BTS may need some time to update scf file.
    start Btslogs from Local machine    ${BTSLOG}    
    Get_Feature_Activation    ${Dict_MOC_PATH}    ${PARAMETER_KEY}    value=${9409_allUes}
    Sleep    120 s    BTS may need some time to update scf file.
    uc.Require UE    ${UE_alias}    ${capabilities} 
    ${Detached_output}    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE     ue_alias=${UE_alias}
    ${attach_UE}    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    ue_alias=${UE_alias}
    Voice_call_start    ${UE_alias}    ${VoNR_TESTCASE_IN_ULTRACALLER}
    FTP_dl_data_transfer    ${UE_alias}    ${Protocol_Type}    ${DIRECTION}
    Voice_call_stop     ${UE_alias}
    ${Detached_output}    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE     ue_alias=@{UE_alias}
    Stops Btslogs from Local machine    ${BTSLOG}
#    Verification_btslog    ${TCP_Boost_PUG_VoNR}
#    Verification_btslog    ${5QI1}
    
*** Keywords ***
Get_Pre_Active_alarms
    [Documentation]    Active Alarms
    ${Pre_Active_Alarm}    admin.get_active_alarms    
    Log    ${Pre_Active_Alarm}

Get_Post_Active_alarms
    [Documentation]    Keyword is feature purpose for alarm validation. 
    ${Post_Active_Alarm}    admin.get_active_alarms    
    Log    ${Post_Active_Alarm}

Get_Feature_Activation
    [Documentation]    Scope of the keyword to disable tcpboostpug.
    [Arguments]    ${Dict_Name}=${None}    
    ...            ${parameter}=${None} 
    ...            ${operation}=update    ${value}=${None} 
    ...            ${should_activate}=True    ${timeout}=350  
    admin.perform_parameter_recommissioning
    ...    dist_name=${Dict_Name}
    ...    parameter=${parameter}
    ...    operation=${operation}   
    ...    value=${value}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}

FTP_dl_data_transfer
    [Documentation]    Keyword does data transfer over FTP Server. As of not 4mp data is set in yaml file.
    [Arguments]    ${ue_alias}    ${protocol_type}    ${direction}
    uc.start_datatransfer    ue_alias=${ue_alias}    protocoltype=${protocol_type}   direction=${direction}
    uc.await_data_transfer_finish    ue_alias=${ue_alias}    direction=${direction}

SCF_Commission
    [Documentation]    Keyword can fetch user input as xml file and does full commission
    [Arguments]      ${Commission_file}=Commission_files
    Directory Should Exist    ${SCF_PATH}   
    admin.perform_commissioning    ${BTS_ID}    skip_parameter_relation_errors=true
    ...        scf_file=${Commission_file}   timeout=2000

Test_Setup_keywords
    [Documentation]    Test Pre condition
    admin.Connect to    bts_host=${BTS_Details.bts_host}     admin_api_log_dir=${BTS_Details.admin_api_log_dir}
    ...        release=${BTS_Details.release}
    Run Keyword And Ignore Error    Start_Dcap
    Get_Pre_Active_alarms
  
    
Test_Teardown_Keywords
    [Documentation]    Test post condition

    Run Keyword And Ignore Error    Stop_Dcap
    Get_Post_Active_alarms
    Run Keyword And Continue On Failure    interface.Common step trigger
    admin.teardown_admin

Start_Dcap
    [Documentation]   Keyword does Stat tracing in DCAP server. Directly used from taf.sw.dcap.rd libary. 
    ...    its dedicated for 5G CRT. Meanwhile we use it for other setup as well.     
       
    rd.connect_to      host=${Dcap_Server_Details.host}    port=${Dcap_Server_Details.port}
    ...             secure=${True}  
    ${out_put}    rd.start_trace     duration=-1     bts=&{Dcap_User_Details}
    ...        gnb_custom_profile=@{Only_Gnb_custom_profile}    bts_custom_profile=@{Bts_custom_profile}
    ...        wait_for_activation=True
    Log To Console    ${out_put}
    ${trace_id}     Get From Dictionary     ${out_put}    id
    Set Suite Variable    ${trace_id} 
    
Stop_Dcap
    [Documentation]     Keyword does Stop the dcap trace and save the output file into local directory. 
    ...        local dir: /tmp/dcaplog/
    [Arguments]        ${Dcap_Trace_ID}=${trace_id}
    Log To Console    ${Dcap_Trace_ID}
    rd.stop_trace    ${Dcap_Trace_ID}
    Sleep    3m    DCAP log stopping take more then expected.To avoid unwanted interfrence
    ${DCAP_results_path}    OperatingSystem.Join Path    ${OUT_SUITE_LOGS_DIR_PATH}    DCAP_Logs
    Create Directory  ${DCAP_results_path}
    rd.get_results     target_dir=${DCAP_results_path}    timeout=200

Voice_call_start
    [Arguments]       ${alias}    ${test_case_name}
    uc.start_voice_call    ${alias}    ${test_case_name}

Voice_call_stop
    [Arguments]       ${alias}
    uc.stop_voice_call    ${alias}

start Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: “/tmp/btslog2”
    ...    
    [Arguments]    ${log_alias}    
    btslog.create_btslog_collector    ${log_alias}    
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias} 
    core.Set Suite Alias    ${log_alias}

Stops Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: “/tmp/btslog2”
    [Arguments]    ${log_alias}   
    Run Keyword And Continue On Failure     core.stop_collectors      names=${log_alias}   
    Run Keyword And Continue On Failure     core.collect_collectors      names=${log_alias}   
    Run Keyword And Continue On Failure    core.teardown_collectors      names=${log_alias}   

#Verification_btslog
#    [Documentation]    Keyword does btslog verification. moreover, syslog_reader.py have complete function
#    ...    from taf.analyzer.syslog. It is common validation only user input requires.
#    [Arguments]    ${user_text}

#    Run Keyword And Ignore Error
#    ...     vdn.validate_syslog_file_contents    ${user_text}   # its for user string validation. 
#    ...     vdn.validate_syslog_file_contents


PM_Counter_Check_Validation
    [Documentation]    Requirement of 5G_PM_953 - PM counter validation
    ...    Keyword does collect the counter and check should not equal to 0 
    [Tags]    5G_PM_953
    ${counter_List}    admin.get_pm_counters_by_dist_name   timeout=${timeout} 
    log    ${counter_List}
    FOR   ${count1}	   IN    @{Counters_list}
    	Run Keyword and Continue On Failure    Dictionary Should Not Contain Value    ${counter_List}    0
        log    ${counter_List}
    END   

    
