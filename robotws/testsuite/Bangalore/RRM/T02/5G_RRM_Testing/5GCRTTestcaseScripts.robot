*** Settings ***
Documentation
...  author:  Ruchika Gupta
...  contact: ruchika.gupta@nokia.com

Library    Collections
Library    DateTime
Library    BuiltIn
Library    OperatingSystem     WITH NAME    os
Library    taf.sw.dcap.rd    WITH NAME    rd
Library    taf.sw.scout    WITH NAME    scout
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog    WITH NAME    btslog
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    uc
Library    taf.hw.rf_attenuator.attenuator    WITH NAME    attenuator
Library    ../resources/python/Test_Verification_Handler.py    WITH NAME    Validation
Resource   ../resources/robot/Common_keywords.resource
Resource   ../resources/robot/Rjio_Operation_keywords.resource
Library    taf.sw.reporting_portal    WITH NAME    rp
Resource   taf/rfrl/common_resources/common_step/interface.robot
Resource   ../../5GST_BLR/SG02/CB010638/CB010638_Test_Suite.robot
Force Tags   SBTS00    CA_VRF_BLR1  CRT  5G_FDD_CRT
...  CLOUD_5G_CLASSICAL_1ASIB_1ABIO_1ABIN_1AZHA  STATE_CONFIGURED  QCP_RAN_VRF  QCD_MN_RAN

Test Setup        Test_Setup_keywords
Test Teardown     Test_Teardown_Keywords

*** Variables ***

${tl_name}		7_2_UTE5GCLOUD1008

${testline_name}	7_2_UTE5GCLOUD1008

&{_CB008441_A_B1_03_PI2_Discard_TCP_Low_Latency_SA}    QC_ID_SBTS00=31002

&{_CB008441_A_B2_07_PI2_Discard_intergNB_Mobility}    QC_ID_SBTS00=31003

&{_CB008441_A_B1_19_PI2_Discard_UDP_SA}    QC_ID_SBTS00=31004

${logsdir}                                 /tmp/btslog2/SYSLOG_1.LOG
@{throughput_dl}                           1000
@{deviation_dl}                            100
@{timeout}                                 200
${scfconf}=                                 /home/ute/testline_configuration/7_2_UTE5GCLOUD1008/ta_ue_config.yaml
@{UE_alias}                                 UE4    # UE_1 = Skippable ue & UE_2= Non skippable
@{capabilities}                             Legacy_4
${SCF_PATH}                                 ${TEST_PATH}/SCF
${BTS_ID}                                   11008
@{Protocol_Type}                            FTP
@{Protocol_Type_UDP}                        UDP
@{Protocol_Type_TCP}                        TCP
@{DIRECTION}                                dl
&{BTS_Details}                              bts_host=192.168.255.129
...                                         bts_port=443
...                                         username=Nemuadmin
...                                         password=nemuuser
...                                         use_ssl=True
...                                         update_interval=5000
...                                         admin_api_log_dir=${EXECDIR}
...                                         name=default
...                                         bundle_path=None
...                                         release=SBTS00
...                                         timeout=30
&{Dcap_User_Details}                        host=10.58.239.183    port=443
...                                         username=Nemuadmin    password=nemuuser
${BTS_path}=                                /home/ute/Logs
${Dict_MOC_PATH}                            MRBTS-11008/NRBTS-11008/NRCELL-4
${Dict_MOC_PATH_NRDRB_NONGBR}               MRBTS-11008/NRBTS-11008/NRDRB-13
${PARAMETER_KEY}                            actTcpBoostPug
${PARAMETER_KEY_PDCPD_DISCARD}              queuingDelayDiscarding
${PI2_TARGET_DELAY}                         pi2TargetDelay
${PI2_TARGET_SIZE}                          pi2TargetSize
${PI2_TARGET_DELAY_VALUE}                   300
${PI2_TARGET_SIZE_VALUE}                    10
${PDCP_PI2_discarding_Activated}            canDiscard 1
${PI2_Packet_Discard_Disabled}              PI2_Packet_Discard_Disabled    # Text from L2HI will be enhanced
${CB008441_Feature_Enabled}                 PI2
${CB008441_Feature_Disabled}                Disabled
${Attenuator_ip_addr}                       10.45.153.211
${Attenuator_com_port}  		    3001
@{attenuation_ports}                        11    12
${Attenuator_vendor}                        TOPYOUNG
${Attenuator_model}                         TAS16T16-51-120-1N-DEJS
${5QI1}                                     fiveQi: 1
${CS_Entry_validation}                      CS1 Entry for TCP PUG
${prach_validation}                         prachNotNull
${TEST_PATH}                                testsuite/Bangalore/RRM/5GST_BLR/SG02/5G_CRT
@{counters_CB010544} =                      M55351C00001  M55351C00002  M55351C01001
${VALUE1}			            0db
${VALUE2}				    90db
${VALUE3}			            15db
@{Serving_port}                             11
@{Target_port}                              12
${RP_CA}=                                   VRF_RRM
${RP_QC_DOMAIN}=                            MN_RAN
${QC_Project}=                              RAN_VRF
${RP_QC_PROJECT}                            RAN_VRF
${RP_LOCATION}                              VRF_BLR1
${RP_Customer}                              Reliance India
${RP_organization}                          VRF_BLR1_T02
${connection}                               None

*** Test Cases ***

_CB008441_A_B1_03_PI2_Discard_TCP_Low_Latency_SA
    [Tags]    5G_RAN_USR_RRM_23142
    Log To Console  ${_CB008441_A_B1_03_PI2_Discard_TCP_Low_Latency_SA}
    PI2QueuingDelayAlgorithm_configuration_Enabled
    Validate_BTS_State_ONAIR
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE    ue_alias=${UE_alias}
    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    ue_alias=${UE_alias}
    Dl_data_transfer    ${UE_alias}    ${Protocol_Type_TCP}    ${DIRECTION}
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE    ue_alias=${UE_alias}
    Verification_btslog    ${PDCP_PI2_discarding_Activated}
    PI2QueuingDelayAlgorithm_configuration_Disabled
    Validate_BTS_State_ONAIR
    PM_Counter_Check_Validation_PI2
    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    ue_alias=${UE_alias}
    Dl_data_transfer    ${UE_alias}    ${Protocol_Type_TCP}    ${DIRECTION}
    Verification_btslog    ${PI2_Packet_Discard_Disabled}
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE    ue_alias=${UE_alias}

_CB008441_A_B2_07_PI2_Discard_intergNB_Mobility
    [Tags]    5G_RAN_USR_RRM_24142,CB_FIM43685
    Log To Console  ${_CB008441_A_B2_07_PI2_Discard_intergNB_Mobility}
    PI2QueuingDelayAlgorithm_configuration_Enabled
    Validate_BTS_State_ONAIR
    ${Attenuator_device_config}  attenuator.setup_attenuator   ip_addr=${Attenuator_ip_addr}  port=${Attenuator_com_port}
    ...    attenuation_port_numbers=${attenuation_ports}  vendor=${Attenuator_vendor}   model=${Attenuator_model}
    Log To Console  ${Attenuator_device_config}
    log to console    \n*****Serving Cell transmission*****
    Read_And_Set_Attenuation    attenuation_ports=${Serving_port}    set_value=${VALUE1}
    Read_And_Set_Attenuation    attenuation_ports=${Target_port}    set_value=${VALUE2}
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE    ue_alias=${UE_alias}
    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    ue_alias=${UE_alias}
    Dl_data_transfer    ${UE_alias}    ${Protocol_Type_UDP}    ${DIRECTION}
    log to console    \n*****Attenuating Serving and Target Cell for HO*****
    Read_And_Set_Attenuation    attenuation_ports=${Serving_port}    set_value=${VALUE3}
    Read_And_Set_Attenuation    attenuation_ports=${Target_port}    set_value=${VALUE1}
    PM_Counter_Check_Validation_PI2
    log to console    \n*****intragnb handover attenuation_ports******
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE    ue_alias=${UE_alias}
    Verification_btslog    ${PDCP_PI2_discarding_Activated}
    PI2QueuingDelayAlgorithm_configuration_Disabled

_CB008441_A_B1_19_PI2_Discard_UDP_SA
    [Tags]    5G_RAN_USR_RRM_23143
    Log To Console  ${_CB008441_A_B1_19_PI2_Discard_UDP_SA}
    PI2QueuingDelayAlgorithm_configuration_Enabled
    Validate_BTS_State_ONAIR
    ${Attenuator_device_config}  attenuator.setup_attenuator   ip_addr=${Attenuator_ip_addr}  port=${Attenuator_com_port}
    ...    attenuation_port_numbers=${attenuation_ports}  vendor=${Attenuator_vendor}   model=${Attenuator_model}
    Log To Console  ${Attenuator_device_config}
    log to console    \n*****Serving Cell transmission*****
    Read_And_Set_Attenuation    attenuation_ports=${Serving_port}    set_value=${VALUE1}
    Read_And_Set_Attenuation    attenuation_ports=${Target_port}    set_value=${VALUE2}
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE    ue_alias=${UE_alias}
    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    ue_alias=${UE_alias}
    Dl_data_transfer    ${UE_alias}    ${Protocol_Type_UDP}    ${DIRECTION}
    log to console    \n*****Attenuating Serving and Target Cell for HO*****
    Read_And_Set_Attenuation    attenuation_ports=${Serving_port}    set_value=${VALUE3}
    Read_And_Set_Attenuation    attenuation_ports=${Target_port}    set_value=${VALUE1}
    PM_Counter_Check_Validation_PI2
    log to console    \n*****intragnb handover attenuation_ports******
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE    ue_alias=${UE_alias}
    Verification_btslog    ${PDCP_PI2_discarding_Activated}
    PI2QueuingDelayAlgorithm_configuration_Disabled

*** Keywords ***

Set QC_Tag
    [Arguments]    ${Active_SW}
    ${QC_ID}=    Set Variable    ${${TEST_NAME}}[QC_ID_${Active_SW}]
    Set Tags    ${QC_ID}

Get_Pre_Active_alarms
    [Documentation]    Active Alarms
    ${Pre_Active_Alarm}    admin.get_active_alarms
    Log    ${Pre_Active_Alarm}

Get_Post_Active_alarms
    ${Post_Active_Alarm}    admin.get_active_alarms
    Log    ${Post_Active_Alarm}

Get_Feature_Activation
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
    Validate_BTS_State_ONAIR

taf_attenuator_objects
	[Documentation]  Author: Arunkumar A
    ...    Integrated along with https://taf-hw-rf-attenuator.docs.taf.ute.nsn-rdnet.net/
    [Arguments]   ${attenuation_ports}   ${set_value}
    ${Attenuator_device_config}  attenuator.setup_attenuator   ip_addr=${Attenuator_ip_addr}  port=${Attenuator_com_port}
    ...    attenuation_port_numbers=${attenuation_ports}  vendor=${Attenuator_vendor}   model=${Attenuator_model}
    Log To Console  ${Attenuator_device_config}
    FOR  ${port}  IN  @{attenuation_ports}
        ${port_value}  attenuator.read_attenuation    ${port}
        Run keyword    Run Keyword If   "${port_value}db"!="${set_value}"  attenuator.set_attenuation    port=${port}  value=${set_value}
        ...    confirm=${True}
        ...    confirmation_delay=5
        ...    ELSE    BuiltIn.Log To console    [ INFO ]: Port Number: ${port} and value: ${port_value}
    END


Read_And_Set_Attenuation
    [Arguments]   ${attenuation_ports}   ${set_value}
    FOR  ${port}  IN  @{attenuation_ports}
        ${port_value}  attenuator.read_attenuation    ${port}
        Run keyword    Run Keyword If   "${port_value}db"!="${set_value}"  attenuator.set_attenuation    port=${port}  value=${set_value}
        ...    confirm=${True}
        ...    confirmation_delay=5
        ...    ELSE    BuiltIn.Log To console    [ INFO ]: Port Number: ${port} and value: ${port_value}
    END


Parameter_Modification
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
    Validate_BTS_State_ONAIR

PI2QueuingDelayAlgorithm_configuration_Enabled
     Parameter_Modification     ${Dict_MOC_PATH_NRDRB_NONGBR}    ${PI2_TARGET_DELAY}    value=${PI2_TARGET_DELAY_VALUE}
     Parameter_Modification     ${Dict_MOC_PATH_NRDRB_NONGBR}     ${PI2_TARGET_SIZE}    value=${PI2_TARGET_SIZE_VALUE}
     Parameter_Modification     ${Dict_MOC_PATH_NRDRB_NONGBR}    ${PARAMETER_KEY_PDCPD_DISCARD}    value=${CB008441_Feature_Enabled}

PI2QueuingDelayAlgorithm_configuration_Disabled
     Parameter_Modification     ${Dict_MOC_PATH_NRDRB_NONGBR}    ${PARAMETER_KEY_PDCPD_DISCARD}    value=${CB008441_Feature_Disabled}
     Validate_BTS_State_ONAIR

Dl_data_transfer
    [Arguments]    ${ue_alias}    ${protocol_type}    ${direction}
    uc.start_datatransfer    ue_alias=${ue_alias}    protocoltype=${protocol_type}   direction=${direction}
    uc.await_data_transfer_finish    ue_alias=${ue_alias}    direction=${direction}
    ${Dowlink_Throughput}=    Run keyword and Continue on Failure     uc.calculate_thrughtput
		...    ue_alias=${ue_alias}    direction=${direction}
    	...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
    Log To Console  ${Dowlink_Throughput}

SCF_Commission
    [Arguments]      ${Commission_file}=Commission_files
    os.Directory Should Exist    ${SCF_PATH}
    admin.perform_commissioning    ${BTS_ID}    skip_parameter_relation_errors=true
    ...        scf_file=${Commission_file}   timeout=200

Test_Setup_keywords
    os.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${scfconf}
    ${date}    Get Current Date    result_format=%Y%m%d
    Create testcase folder
    ${SUITE NAME}    Set Variable    ${SUITE NAME}
    ${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
    os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    admin.Connect to    bts_host=${BTS_Details.bts_host}   bts_port= ${BTS_Details.bts_port}
    ...    username=${BTS_Details.username}    password=${BTS_Details.password}   admin_api_log_dir=${BTS_Details.admin_api_log_dir}
    Geting_BTS_IDs_for_cb010638
    ${tc_config_id}    Rjio_Operation_keywords.Link SCOUT SCF to Configuration ID for Reporting
    ...    tl_name_only=${tl_name}
    Set Test Variable   ${TC_EXE_ID}    ${tc_config_id}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    ${QC_ID}   Common_keywords.Get Qc Id According To Sw Release    active_sw=${Active_Sw_version}
    BuiltIn.Set Tags     QC_${QC_ID}
    Run Keyword And Continue On Failure    Start Btslogs from Local machine
    Run Keyword And Continue On Failure    Start_Dcap
    uc.Require UE    ${UE_alias}    ${capabilities}
    Get_Pre_Active_alarms

Create testcase folder
		${SUITE NAME}    Set Variable    ${SUITE NAME}
        ${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
        ${date}    Get Current Date    result_format=%Y%m%d
    	Run Keyword And Return Status    LOG    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    	os.create directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    	${out}    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    	set test variable    ${out}


Report To Reporting Portal Internal Keyword
    [Documentation]    Report to reporting portal by using with taf.sw.reproting_portal
    ...    Using for All Testcase veridict to update in RP.
    [Arguments]    ${verdict}  ${QC_ID}  ${target_build}  ${RP_QC_PROJECT}
    BuiltIn.Set Test Variable    ${tool}    WebEM
    ${Tool_name}    Convert To String    ${tool}
    ${build}    Convert To String    ${target_build}
    ${link_to_reporting_portal}  rp.report to rp
    ...  name=${TEST_NAME}
    ...  result=${verdict}
    ...  ca=${RP_CA}
    ...  build=${build}
    ...  testline=${testline_name}
    ...  qc_domain=${RP_QC_DOMAIN}
    ...  qc_project=${RP_QC_PROJECT}
    ...  qc_id=${QC_ID}
    ...  tool=${Tool_name}
    ...  tc_execution_id=${TC_EXE_ID}
    ...  location=${RP_LOCATION}
    ...  customer=${RP_Customer}
    ...  organization=${RP_organization}
    BuiltIn.Log To Console  Reporting Portal link: ${link_to_reporting_portal}
    BuiltIn.Log Many    ${link_to_reporting_portal}

Test_Teardown_Keywords
    Run Keyword And Continue On Failure    stop Btslogs from Local machine
    Run Keyword And Ignore Error    Stop_Dcap
    admin.collect_snapshot    target_file_name=/home/ute/Downloads/SNAPSHOT.zip    force=True
    ...    timeout=360    detailed_output=False    connection=${connection}
    Get_Post_Active_alarms
    Run Keyword And Continue On Failure    interface.Common step trigger
    ${tc_config_id}    Rjio_Operation_keywords.Link SCOUT SCF to Configuration ID for Reporting
    ...    tl_name_only=${tl_name}
    Set Test Variable   ${TC_EXE_ID}    ${tc_config_id}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    ${instance_id}   Common_keywords.Get Qc Id According To Sw Release    active_sw=${Active_Sw_version}
    Set Test Variable    ${TEST_QC_ID}    ${instance_id}
    Run Keyword If  '${TEST_STATUS}' == 'PASS'  Report To Reporting Portal Internal Keyword
    ...    verdict=passed  QC_ID=${TEST_QC_ID}  target_build=${Active_Sw_version}  RP_QC_PROJECT=${QC_Project}
    ...    ELSE  Report To Reporting Portal Internal Keyword    verdict=failed  QC_ID=${TEST_QC_ID}
    ...    target_build=${Active_Sw_version}  RP_QC_PROJECT=${QC_Project}
    admin.teardown_admin

Start_Dcap
    [Documentation]     Start DCAP logs with custom filter
    rd.connect_to  host=10.41.209.120   port=443    username=utfuser   password=utfadmin!
    ...              rd_version=dcapv3  secure=True
    &{Dcap_User_Details}   create dictionary  host=10.58.239.183    port=443    username=Nemuadmin    password=nemuuser
    @{gnb_trace_custom_profile}    Create List    controlPlane5g    condor5gSyslog
    ${output}    rd.start_trace     duration=-1    bts=&{Dcap_User_Details}
    ...    gnb_custom_profile=${gnb_trace_custom_profile}
    ...    bts_trace_profile=dcap-lite-default     wait_for_activation=True    timeout=1800
    ${Dcap_Trace_ID}      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${Dcap_Trace_ID}
    LOG      DCAP log collection has been started in the gNB

Stop_DCAP
    rd.stop_trace    trace_id=${Dcap_Trace_ID}
    log    "DCAP logging stopped"
    BuiltIn.Log To Console     ${Dcap_Trace_ID}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${dcap_log_file}    os.Normalize Path    ${TS_CASE_LOG_PATH}/DCAP_logs
    Create Directory    ${dcap_log_file}
    # Set Suite Variable    ${dcap_log_file}    ${common_log_file_path}/${current_file_name}/${time_stamp}/${TEST_NAME}/
    Set Suite Variable    ${dcap_log_file}
    rd.get_results    result_id=${Dcap_Trace_ID}    target_dir=${dcap_log_file}    timeout=300

Voice_call_start
    [Arguments]       ${alias}    ${test_case_name}
    uc.start_voice_call    ${alias}    ${test_case_name}
    Validate_BTS_State_ONAIR

Voice_call_stop
    [Arguments]       ${alias}
    uc.stop_voice_call    ${alias}
    Validate_BTS_State_ONAIR

Start Btslogs from Local machine
    	[Documentation]    path from where to get btslog files default value
    	#os.Run     killall btslog
    	Run Keyword And Continue On Failure    BTSLOG.create_btslog_collector    name=btslog    log_dir=${logsdir}
    	Run Keyword And Continue On Failure    core.setup_collectors    names=btslog
    	Run Keyword And Continue On Failure    core.set_suite_alias    btslog
    	Run Keyword And Continue On Failure    core.start_collectors    names=btslog

Verification_btslog
    [Arguments]    ${user_text}
    BuiltIn.Log To Console  ${user_text}
    Validation.validate_syslog_file_contents    dir_path=${out}    search_string=${user_text}
    Validate_BTS_State_ONAIR

PM_Counter_Check_Validation
    @{counter_list}=    create List    M55308C00038  M55308C00039  M55308C00040  M55308C00042
    ${log_entry} =    admin.get_pm_counters    counter_ids=M55308C00038,M55308C00039,M55308C00040,M55308C00042    timeout=100
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry ['BTS']['MRBTS-11008']['NRBTS-11008']['NRCELL-4']['NCELA']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}!=0
	Run Keyword IF    '${value}' != '0'    Log    ${counter_List}    ELSE    Log    '${value}' is equal to 0
    END

PM_Counter_Check_Validation_PI2
    @{counter_list}=    create List    M55350C00035
    ${log_entry} =    admin.get_pm_counters    counter_ids=M55350C00035    timeout=100
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry ['BTS']['MRBTS-11008']['NRBTS-11008']['NRCELL-4']['PDCPC']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
	Run Keyword IF    '${pi_value}' != '0'    Log    ${counter_List}    ELSE    fail
    END

Validate_BTS_State_ONAIR
    ${bts_status}   admin.get_bts_statuses
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \nBTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail


stop Btslogs from Local machine
    [Documentation]     Stops BTS log and check for crash
    	Run Keyword And Continue On Failure    core.stop_collectors    names=btslog
    	os.Copy Files    ${logsdir}    ${out}
    	Run Keyword And Continue On Failure    core.teardown_collectors    names=btslog

