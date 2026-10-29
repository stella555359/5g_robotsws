*** Settings ***
Documentation
...               Authors:    artur.krolak@nokia.com, dawid.wojciechowski@nokia.com
...               Maintainers:    arunkumar.a@nokia.com, dharmendra.k.samal@nokia.com
...		  This Keywords file belongs to PZ BLR SG02 and its runing under NB-IoT Test Lines (BTS-832, 486,494,465) Execution.
...		  If you want to modify this script please infom to SG02 or Maintainers. please don't modify without pre-information 

Library           OperatingSystem
Library           SSHLibrary    60 seconds
Library           String
Library           Collections
Library           ute_fsmaccess

*** Variables ***
${INFO_MODEL_PORT}=            DISABLED    #Possible values: ENABLED or DISABLED, where:
                                           #ENABLED means use keywords from ute_infomodel library
                                           #DISABLED means use keywords from ute_admin_infomodel library
${LOGS_SNAPSHOT}=              ${TRUE}     #Possible values: True or False
${ENB_ACTIONS_TRIGGER}=        ADMIN       #Possible values: BTSSM or ADMIN
${ENB_IP}=                     192.168.255.1
${ENB_USER}=                   toor4nsn
${ENB_PASSWORD}=               oZPS0POrRieRtu
${ADMIN_PORT}=                 443
${ADMIN_PORT_FL}=              3600
${IM_ALIAS}=                   infomodel
${TRS_IP}=                     192.168.255.129
${TRS_LOGIN}=                  Nemuadmin
${TRS_PASS}=                   nemuuser
${SYSLOG_IP}=                  192.168.255.126
${SYSLOG_PORT}=                51000
${SYSLOG_FILENAME}             syslog_enb.log
${TRUNK_PREFIX}=               FL00
${BRANCH_PREFIX_1}=            SBTS19A
${BRANCH_PREFIX_2}=            SBTS19B
${TSHARK_CAPTURING}=           ENABLED      #Possible values: ENABLED, DISABLED
${SCFC_PATHS}
${OUT_SUITE_LOGS_DIR_PATH}
${OUT_TEST_LOGS_DIR_PATH}
${OUT_ADMIN_PORT}
${OUT_ENB_ACTIVE_SW}
${OUT_ENB_PASSIVE_SW}
${OUT_FEATURE_ID}
${OUT_ENB_ID}
${OUT_BTS_SIDE}
${OUT_HW_VERSION}
${OUT_DICT_OF_MME}
${OUT_SCFC_FILE}
${OUT_SCFC_FILE_PATH}
${OUT_SCFC_DEFAULT_CLOUD}
${OUT_SCFC_VARIABLE_NAME}
${OUT_SCFC_ACTIVATED_NBIOT}
${OUT_RMOD_SER_NUM_LIST}
${OUT_RMOD_TYPE_LIST}
${OUT_LEGACY_LCR_ID_LIST}
${OUT_INBAND_LCR_ID_LIST}
${OUT_STANDALONE_LCR_ID_LIST}
${OUT_GUARDBAND_LCR_ID_LIST}
${OUT_NBIOT_CELLS_DICTIONARIES_LIST}
${OUT_LEGACY_LTE_LNCELL_LIST}
@{OUT_LNCEL_LIST}

@{ALLOWED_ALARMS}=    Vendor BTS certificate
...                   Synchronization lost
...                   Diagnostic Files collected
...                   BTS booted at .*? due to trs management reset
...                   BTS reference clock missing
...                   ToP master service .*? unusable
...                   GPS receiver alarm: not tracking satellites
...                   R&D Service Port enabled
...                   SSH enabled
...                   LMP access .*?
...                   IP Traffic Capturing Ongoing port.*
...                   Failure in connection to Real-time PM Collection Entity
...                   Temp Fault1
...                   BTS Reset Cause
...                   Validation of signed file failed
...                   Ethernet port security is disabled
...                   Service account root access is enabled
...                   No connection to unit
...                   NTP Server .*?
@{ALARM_BLOCK_BTS}=                      {'alarmDetail': 'BTS blocked', 'faultId': '0*50\\D*', 'alarmsSeverity': 'a3'}
@{ALARM_POWER_RESET_OF_ALL_FR}=          {'alarmDetail': 'Failure in optical interface', 'faultId': '0*10\\D*', 'alarmsSeverity': 'a3'}
@{ALARM_CELL_BLOCK}=                     {'alarmDetail': 'Cell blocked', 'faultId': '0*49\\D*', 'alarmsSeverity': 'a3'}
@{ALARM_BLOCK_OF_ALL_FR}=                {'alarmDetail': 'RF Module blocked', 'faultId': '1931\\D*', 'alarmsSeverity': 'a3'}
@{ALARM_FAN_FAILURE}=                    {'alarmDetail': 'Fan failure', 'faultId': '1932\\D*', 'alarmsSeverity': 'a1'}
@{ALARM_SITE_RESET}=                     {'alarmDetail': 'BTS reset time increased', 'faultId': '4091\\D*', 'alarmsSeverity': 'a1'}
...                                      {'alarmDetail': 'Bts autonomous reset as recovery action', 'faultId': '4114\\D*'}
@{ALARM_S1_FAILURE}=                     {'alarmDetail': 'Transport layer connection failure in S1 interface', 'faultId': '6202\\D*'}
@{ALARM_TEMP_FAULT1}=                    {'alarmDetail': 'Temp Fault1', 'faultId': '9000\\D*'}
@{ALARM_BTS_RESET_CAUSE}=                {'alarmDetail': 'BTS Reset Cause', 'faultId': '4592\\D*'}

${TSHARK_IP}=                        10.53.164.122
${TSHARK_USER}=                      inbabstlabuser
${TSHARK_PASSWORD}=                  BT5l@bus3rl0g1n
${TSHARK_DIR}=                       /usr/bin/

${IPERF_WROC_SERVER}=                10.111.67.29
${IPERF_WROC_LOGIN}=                 inbabstlabuser
${IPERF_WROC_PASSWOR}=               BT5l@bus3rl0g1n
${IPERF_DEFAULT_PAYLOAD}=            1240

*** Keywords ***
#Check If Performing Initial NbIoT Commissioning Is Claimed
#    [Documentation]  Check if flag responsible for initial nbIoT is defined and prepare variable for next actions
#    ...              Author:    artur.krolak@nokia.com
#    ${with_initial_nbiot}=    Run Keyword And Return Status    Variable Should Exist    ${PERFORM_ACTIVATION_NBIOT_COMMISSIONING}
#    Run Keyword If    '${with_initial_nbiot}' == '${FALSE}'    Set Suite Variable    ${PERFORM_ACTIVATION_NBIOT_COMMISSIONING}    ${FALSE}
#    ...       ELSE    Set Suite Variable    ${PERFORM_ACTIVATION_NBIOT_COMMISSIONING}    ${PERFORM_ACTIVATION_NBIOT_COMMISSIONING}

Get BTS SW Active Release
    ${release}=    Fetch From Left    ${OUT_ENB_ACTIVE_SW}    _
    ${branch_check}=    Split string    ${OUT_ENB_ACTIVE_SW}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    FL00
    ...     ELSE    Set Variable    ${release}
    Set Suite Variable    ${sw_release}

Extract Short Cloud ID From System
    ${out_raw_id}=    Set Variable    %{UTE_CONFIGURATION}
    ${out_cloud_id}=    Fetch From Right    ${out_raw_id}    marker=.
    ${out_cloud_id}=    Fetch From Right    ${out_cloud_id}    marker=_
    [Return]  ${out_cloud_id}

InfoModel Setup and Start
    [Arguments]    ${alias}=${IM_ALIAS}
    [Documentation]    Author:    artur.krolak@nokia.com
    Infomodel Connect Im
    Run Keyword If    '${INFO_MODEL_PORT}' == 'ENABLED' and '${ENB_ACTIONS_TRIGGER}' == 'BTSSM'    Start Infomodel Logger    alias=${alias}

InfoModel Stop and Save
    [Arguments]    ${alias}=${IM_ALIAS}
    ...            ${filename}=${OUT_TEST_LOGS_DIR_PATH}infomodel.ims2
    [Documentation]    Author:    artur.krolak@nokia.com
    Save Infomodel Log    filename=${filename}    alias=${alias}
    Run Keyword If  '${INFO_MODEL_PORT}' == 'ENABLED' and '${ENB_ACTIONS_TRIGGER}' == 'BTSSM'    Stop Infomodel Logger    alias=${alias}
    Info Model Disconnect    alias=${alias}

Siteconf Collect File
    [Documentation]    Author:    artur.krolak@nokia.com
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Run Keyword
    ...     Upload Siteconf Bts File    filename=${OUT_TEST_LOGS_DIR_PATH}/siteconf.txt
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"    Run Keyword
    ...     Log  \nCannot download Siteconf file with Admin tool  WARN  console=true

Get Actual Timestamp
    [Documentation]    Author:    artur.krolak@nokia.com
    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}=    Get Time    year,month,day,hour,min,sec
    ${out_actual_timestamp}=    Set Variable    ${year}${month}${day}${hour}${min}${sec}
    [Return]   ${out_actual_timestamp}

Get Snapshot
    [Arguments]    ${path_to_snapshot}=${OUT_TEST_LOGS_DIR_PATH}snapshot.zip
    [Documentation]    Author:    artur.krolak@nokia.com
#TODO: Admin setup teardown required? Should Be Open before test and closed after all test actions
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Run Keyword    Save Snapshot    snapshotfilename=${path_to_snapshot}
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"    Run Keywords    taf.sbts.oam.coam.admin.Setup admin    alias=snapshot_collection    AND
    ...    taf.sbts.oam.coam.admin.Collect Snapshot    target_file_name=${path_to_snapshot}
    ...                                                                                                    timeout=900
    ...                                                                                                    alias=snapshot_collection    AND
    ...                                                                      taf.sbts.oam.coam.admin.Teardown Admin    alias=snapshot_collection

Suite Precondition
    [Documentation]    Author:    artur.krolak@nokia.com
    Log Variables
    Run    pip freeze > ${OUTPUTDIR}/libraries_versions.txt
#    interface.Common step trigger
    ${out_suite_logs_dir_path}=    Logging Create Suite Logs Directory    logs_dir_path=${OUTPUT_DIR}
    Set Suite Variable    ${OUT_SUITE_LOGS_DIR_PATH}    ${out_suite_logs_dir_path}${/}
    Set Library Search Order    OperatingSystem    ute_admin_infomodel
    Delete files and folder
#    UpdateSoftware
    FSM Access Open Connection
    FSM Access Get eNB HW Version And Set eNB Side
    FSM Access Get Active And Passive Enb Sw Versions
#    FSM Access Get Enb Sw Program
    FSM Access Close Connection
    Get BTS SW Active Release
    Set ENB_ACTIONS_TRIGGER Depending On SW Build
    ${out_admin_port}=         Set Variable If    "${ENB_ACTIONS_TRIGGER}"=="BTSSM"    ${ADMIN_PORT_FL}
    ...                                           "${ENB_ACTIONS_TRIGGER}"=="ADMIN"    ${ADMIN_PORT}
    Set Suite Variable    ${OUT_ADMIN_PORT}    ${out_admin_port}
    Logging Kill Process Local    BTSSiteManager
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Setup Btssm    log_path=${OUT_SUITE_LOGS_DIR_PATH}
    ...    ELSE IF    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"    taf.sbts.oam.coam.admin.Setup Admin    bts_host=${ENB_IP}
    ...                                                                     bts_port=${OUT_ADMIN_PORT}
    ...                                                                     use_ssl=True
    ...                                                                     admin_api_log_dir=${OUT_SUITE_LOGS_DIR_PATH}
    SCFC Get Commissioning File From BTS    scfc_name=SCFC_Suite_Backup.xml
    GetSnapshotAfterUpdateSw

#    Infomodel Unexpected Alarms Should Not Be Available    allowed_alarms=${ALLOWED_ALARMS}
#    Check If Performing Initial NbIoT Commissioning Is Claimed
#    SCFC Set Default SCFC And Special Variables Based On Testiline Configuration
#    Run Keyword If    ${PERFORM_ACTIVATION_NBIOT_COMMISSIONING}==${TRUE}    Run Keywords    InfoModel Setup and Start    AND
#    ...                                                                                     Perform Activation NBIoT Commissioning    AND
#    ...                                                                                     SCFC Get Cells And RMOD Lists From ENB
#    ...																				     postfix=Suite_Precondition
#    ...                                                                                     scope=SUITE    AND


GetSnapshotAfterUpdateSw
    [Arguments]    ${path_to_snapshot}=${OUT_SUITE_LOGS_DIR_PATH}snapshot_update_sw.zip
    [Documentation]    Author:    artur.krolak@nokia.com
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Run Keyword    Save Snapshot    snapshotfilename=${path_to_snapshot}
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"    Run Keywords    taf.sbts.oam.coam.admin.Setup admin    alias=snapshot_collection    AND
    ...    taf.sbts.oam.coam.admin.Collect Snapshot    target_file_name=${path_to_snapshot}    timeout=900    alias=snapshot_collection    AND
    ...    taf.sbts.oam.coam.admin.Teardown Admin    alias=snapshot_collection 

UpdateSoftware
    taf.sbts.oam.coam.admin.Setup Admin    bts_host=192.168.255.129
    ...                                                                     bts_port=443
    ...                                                                     use_ssl=True
    ...                                                                     admin_api_log_dir=${OUT_SUITE_LOGS_DIR_PATH}
    ${Build_p8}=    Set Variable    /home/ute/robotlte/testsuite/WMP/GVe/Bangalore/SG02/IoT/Builds/P8Build/
    ...    SBTS22R1_ENB_0000_001210_000022_release_BTSSM_downloadable_A54.zip   
    ${v}=    taf.sbts.oam.coam.admin.Get Parameters    /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1    timeout=30
    ${oldSoftwareSBTS}=    Set Variable    ${v['activeSoftwareVersion']}
    log    ********* Active SW Version is ${v['activeSoftwareVersion']}*********
    log    ********* Passive SW Version is ${v['passiveSoftwareVersion']}********
    Run Keyword If    "${v['passiveSoftwareVersion']}" == "SBTS22R1_ENB_0000_001210_000022"    
    ...    Run Keyword   taf.sbts.oam.coam.admin.Rollback Software    timeout=1000
    ...    ELSE IF    "${v['activeSoftwareVersion']}" != "SBTS22R1_ENB_0000_001210_000022"
    ...    Fail   **** "SBTS22R1_ENB_0000_001210_000022" not exit in Active/Passive partation ******
    sleep    10m
    #taf.sbts.oam.coam.admin.Reset Configuration    false    false    timeout=1500
    #sleep    15m
    #taf.sbts.oam.coam.admin.Update Software    ${Build_p8}    should_activate=True    timeout=2000
    #sleep    10m
    taf.sbts.oam.coam.admin.Teardown admin
    #sleep    10s
    #sbtsUsersJsonRemoveFromFFS
    #sleep    10m
    taf.sbts.oam.coam.admin.Setup Admin    bts_host=192.168.255.129
    ...                                                                     bts_port=443
    ...                                                                     use_ssl=True
    ...                                                                     admin_api_log_dir=${OUT_SUITE_LOGS_DIR_PATH}
    #taf.sbts.oam.coam.admin.Perform Commissioning    bts_id=494
    #...                                scf_file=/home/ute/robotlte/testsuite/WMP/GVe/Bangalore/SG02/IoT/Builds/P8Build/p8scf.xml
    #sleep    10m
    ${v}=    taf.sbts.oam.coam.admin.Get Parameters    /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1    timeout=30
    ${P8Software}=    Set Variable    ${v['activeSoftwareVersion']}
    log    ********* Active SW Version is ${v['activeSoftwareVersion']}*********
    Latest Sbts Build    SBTS23R1    2    SBTS22R4    SRAN_CIT    No
    ${BuildPath}=    Set Variable    /home/ute/robotlte/testsuite/WMP/GVe/Bangalore/SG02/IoT/Builds/Reg/
    @{build_Number}=    OperatingSystem.List Files In Directory    /home/ute/robotlte/testsuite/WMP/GVe/Bangalore/SG02/IoT/Builds/Reg/
    ${Build}=    Set Variable    /home/ute/robotlte/testsuite/WMP/GVe/Bangalore/SG02/IoT/Builds/Reg/@{build_Number}[0]
    log    ${Build}
    Set Global Variable    @{build_Number}
    Set Global Variable    ${Build}
    ${a}=    Split String    @{build_Number}[0]    _
    log    ${a[0]}
    ${release}=    Set Variable    ${a[0]}
    log    ${release}
    ${varCheck}=    Run Keyword And Ignore Error    Should Contain    ${oldSoftwareSBTS}    ${a[2]}_${a[3]}_${a[4]}
    taf.sbts.oam.coam.admin.Update Software    ${Build}    should_activate=True    timeout=2000  
    sleep    10m
    taf.sbts.oam.coam.admin.Teardown admin
    sleep    10s
    taf.sbts.oam.coam.admin.Setup Admin    bts_host=192.168.255.129
    ...                                                                     bts_port=443
    ...                                                                     use_ssl=True
    ...                                                                     admin_api_log_dir=${OUT_SUITE_LOGS_DIR_PATH}
    log    *********Software Download Completed **************
    log    ********* Active SW Version is ${v['activeSoftwareVersion']}*********
    ${v}=    taf.sbts.oam.coam.admin.Get Parameters    /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1    timeout=30
    ${activesoftware}=    Set Variable    ${v['activeSoftwareVersion']}
    #sleep    500s
    log    ********* Active SW Version is ${v['activeSoftwareVersion']}*********
    taf.sbts.oam.coam.admin.Teardown admin

Suite Postcondition
    [Documentation]    Author:    artur.krolak@nokia.com
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Run Keyword   Teardown btssm
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"    Run Keyword   taf.sbts.oam.coam.admin.Teardown admin
    Log    \nTest Suite Finished    console=True
    Run    ute_reporting_portal send -ro /home/ute/results/Run2/output.xml -tl 1_2_UTE4GCLOUD832 -ca UTE -p UTE -l CLOUD_SRAN_L_1ASIB_1ABIO_2AHEGA

#Logging Create Suite Logs Directory
#    [Arguments]    ${logs_dir_path}
#    [Documentation]    Author:    artur.krolak@nokia.com
#    ${out_suite_logs_dir_path}=    Normalize Path    ${logs_dir_path}/${OUT_ENB_ACTIVE_SW}
#    ${out_suite_logs_dir_path}=    Replace String    ${out_suite_logs_dir_path}    ${SPACE}    _
#    Create Directory    ${out_suite_logs_dir_path}
#    Set Suite Variable    ${OUT_SUITE_LOGS_DIR_PATH}    ${out_suite_logs_dir_path}${/}
#    [Return]            ${out_suite_logs_dir_path}${/}
#
#Logging Create Test Logs Directory
#    [Arguments]    ${logs_dir_path}
#    [Documentation]    Author:    artur.krolak@nokia.com
#    ${out_test_logs_dir_path}=    Normalize Path    ${logs_dir_path}/${TEST_NAME}
#    ${out_test_logs_dir_path}=    Replace String    ${out_test_logs_dir_path}    ${SPACE}    _
#    Create Directory    ${out_test_logs_dir_path}
#    Set Suite Variable    ${OUT_TEST_LOGS_DIR_PATH}    ${out_test_logs_dir_path}${/}
#    [Return]            ${out_test_logs_dir_path}${/}

Logging Syslog Start
    [Arguments]  ${alias}=syslog
    [Documentation]    Author:    artur.krolak@nokia.com
    Start syslog    log_dir=${OUT_TEST_LOGS_DIR_PATH}
    ...             log_name=${SYSLOG_FILENAME}
    ...             ip=${syslog_ip}
    ...             ports=${SYSLOG_PORT}
    ...             alias=${alias}

Logging Syslog Stop and Collect Logs
    [Arguments]    ${alias}=syslog
    [Documentation]    Author:    artur.krolak@nokia.com
    ute_syslog.Stop Syslog    alias=${alias}
    ute_syslog.Collect Syslog Results    destination=${OUT_TEST_LOGS_DIR_PATH}${SYSLOG_FILENAME}
    ...                                  alias=${alias}

Logging Test Start
    [Documentation]    Author:    artur.krolak@nokia.com
    Log Variables
    ${out_test_logs_dir_path}=    logging.Logging Create Test Logs Directory    logs_dir_path=${OUT_SUITE_LOGS_DIR_PATH}
    ${out_test_logs_dir_path_iot}=    Replace String    string=${out_test_logs_dir_path}
    ...                                                 search_for=[
    ...                                                 replace_with=_
    ${out_test_logs_dir_path_iot}=    Replace String    string=${out_test_logs_dir_path_iot}
    ...                                                 search_for=]
    ...                                                 replace_with=_
    Run    mkdir -p ${out_test_logs_dir_path_iot}
    Run    rm -rf ${out_test_logs_dir_path}
    Set Suite Variable    ${OUT_TEST_LOGS_DIR_PATH}    ${out_test_logs_dir_path_iot}${/}
    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=syslog
    Logging Syslog Start
#    InfoModel Setup and Start
    Run Keyword If    '${TSHARK_CAPTURING}' == 'ENABLED' and '${ENB_ACTIONS_TRIGGER}' == 'BTSSM'
    ...    TShark Start Capturing Packets And Set Port Mirroring On S1 Interface

#    Start EMIL trace with NB IoT profil

Test Preconditions
    [Arguments]    ${commissioning_path}=${EMPTY}
    ...            ${csv_parameter_file}=${EMPTY}
    Logging Test Start
    Run Keyword If  "${csv_parameter_file}" != "${EMPTY}"
    ...    add_random_parameters    input_file=${commissioning_path}_${sw_release}.xml
    ...                             output_file=${commissioning_path}_${sw_release}.xml
    ...                             csv_file=${csv_parameter_file}
    Run Keyword If  "${commissioning_path}" != "${EMPTY}"
    ...    Perform Full Commissioning And Check BTS OnAir    commissioning_path=${commissioning_path}_${sw_release}.xml
    ...                                                      csv_parameter_file=${csv_parameter_file}
    SCFC Get Commissioning File From BTS    scfc_name=SCFC_${TEST_NAME}.xml
    ...                                     scfc_path=${OUT_TEST_LOGS_DIR_PATH}
    SCFC Get LCRID List    ${OUT_SCFC_FILE_PATH}

Test Postconditions
    [Arguments]    ${commissioning_path}=${OUT_SUITE_LOGS_DIR_PATH}/SCFC_Suite_Backup.xml
    Perform Full Commissioning And Check BTS OnAir    commissioning_path=${commissioning_path}
    Logging Test Stop
    Logging Pack Test Dir
s
Logging Test Stop
    [Documentation]    Author:    artur.krolak@nokia.com
#TODO Temporary disabled due to "ssh banner" error
#    Get RawAlarmHistory
#    Stop EMIL trace and save emil log
#    Get All BTSSM Logs And Admin Api Logs
#    Run Keyword If    '${ENB_ACTIONS_TRIGGER}' == 'BTSSM'    Run Keywords    Upload siteconf bts file
#    ...    filename=${OUT_TEST_LOGS_DIR_PATH}/siteconf.txt  AND
#    ...                                                                      Collect Btssm Files    unzip=true
#    ...                                                                                             subdirectory=${OUT_TEST_LOGS_DIR_PATH}
    Run Keyword If    '${TSHARK_CAPTURING}' == 'ENABLED' and '${ENB_ACTIONS_TRIGGER}' == 'BTSSM'
    ...    TShark Stop Capturing Packets And Disable Port Mirroring On S1 Interface
    Run Keyword If    '${LOGS_SNAPSHOT}' == '${TRUE}'    run keyword if test failed    Get Snapshot
#    Save Infomodel Log    filename=${OUT_TEST_LOGS_DIR_PATH}infomodel.ims2    alias=${IM_ALIAS}
    Run Keyword If    '${INFO_MODEL_PORT}' == 'ENABLED' and '${ENB_ACTIONS_TRIGGER}' == 'BTSSM'    Stop Infomodel Logger    alias=${IM_ALIAS}
#    Info Model Disconnect    alias=${IM_ALIAS}
    Logging Syslog Stop and Collect Logs
#    Run Keyword And Ignore Error    getNBIoTSyslogSummary    ${OUT_TEST_LOGS_DIR_PATH}${SYSLOG_FILENAME}

Logging Pack Test Dir
    ${test_name_path}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    Run Keyword And Ignore Error    Run    tar -czvf ${OUT_SUITE_LOGS_DIR_PATH}${test_name_path}.tar.gz -C ${OUT_TEST_LOGS_DIR_PATH} .
    Run Keyword And Ignore Error    File Should Exist    ${OUT_SUITE_LOGS_DIR_PATH}${test_name_path}.tar.gz
    Run Keyword If    "${OUT_TEST_LOGS_DIR_PATH}"!=""
    ...    Run Keyword And Ignore Error    Remove Directory    ${OUT_TEST_LOGS_DIR_PATH}    recursive=True

#Get Feature ID
#    ${out_feature_id}=    Get Regexp Matches    string=${SUITE_NAME}
#    ...                                         pattern=^[a-zA-Z0-9]+
#    Set Suite Variable     ${OUT_FEATURE_ID}    @{out_feature_id}[0]

Set QC_Tag
    [Documentation]    Author:    kacper.halas@nokia.com
    ...                Maintainer:    kacper.halas@nokia.com, tomasz.blaszczyszyn@nokia.com, 
    FSM Access Open Connection
    FSM Access Get eNB HW Version And Set eNB Side
    FSM Access Get Active And Passive Enb Sw Versions
    FSM Access Close Connection
    Get BTS SW Active Release
    Get BTS SW Active Release
    ${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_${sw_release}]
    Set Tags    ${QC_ID}

Set QC_Tag depending on SW version and HW version
    [Documentation]    Author:    dawid.wojciechowski@nokia.com
    ...                Maintainer:    kacper.halas@nokia.com, tomasz.blaszczyszyn@nokia.com
    ${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_${sw_release}_${OUT_HW_VERSION}]
    Set Tags    ${QC_ID}

SCFC Get Legacy Cells LCRID List
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Maintainer:    artur.krolak@nokia.com
    [Arguments]    ${scfc_file}
    ${legacy_lcr_id_list}=    Evaluate Xpath    source=${scfc_file}
    ...                                         expression=//managedObject[@class='NOKLTE:LNCEL' and ./p/text()='FDD']/p[@name='lcrId']/text()
    [Return]    ${legacy_lcr_id_list}

SCFC Get Inband Cells LCRID List
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Maintainer:    artur.krolak@nokia.com
    [Arguments]    ${scfc_file}
    ${inband_lcr_id_list}=    Evaluate Xpath    source=${scfc_file}
    ...    expression=//managedObject[@class='NOKLTE:LNCEL' and ./p/text()='NB-IoT-FDD' and ./p/text()='inband']/p[@name='lcrId']/text()
    [Return]    ${inband_lcr_id_list}

SCFC Get Standalone Cells LCRID List
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Maintainer:    artur.krolak@nokia.com
    [Arguments]    ${scfc_file}
    ${standalone_lcr_id_list}=    Evaluate Xpath    source=${scfc_file}
    ...    expression=//managedObject[@class='NOKLTE:LNCEL' and ./p/text()='NB-IoT-FDD' and ./p/text()='standalone']/p[@name='lcrId']/text()
    [Return]    ${standalone_lcr_id_list}

SCFC Get Guardband Cells LCRID List
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Maintainer:    artur.krolak@nokia.com
    [Arguments]    ${scfc_file}
    ${guardband_lcr_id_list}=    Evaluate Xpath    source=${scfc_file}
    ...    expression=//managedObject[@class='NOKLTE:LNCEL' and ./p/text()='NB-IoT-FDD' and ./p/text()='guardband']/p[@name='lcrId']/text()
    [Return]    ${guardband_lcr_id_list}

SCFC Get LCRID List
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Maintainer:    artur.krolak@nokia.com
    [Arguments]    ${scfc_file}
    ${legacy_lcr_id_list}=    SCFC Get Legacy Cells LCRID List    scfc_file=${scfc_file}
    ${inband_lcr_id_list}=    SCFC Get Inband Cells LCRID List    scfc_file=${scfc_file}
    ${standalone_lcr_id_list}=    SCFC Get Standalone Cells LCRID List    scfc_file=${scfc_file}
    ${guardband_lcr_id_list}=    SCFC Get Guardband Cells LCRID List    scfc_file=${scfc_file}
    Set Test Variable    ${OUT_LEGACY_LCR_ID_LIST}    ${legacy_lcr_id_list}
    Set Test Variable    ${OUT_INBAND_LCR_ID_LIST}    ${inband_lcr_id_list}
    Set Test Variable    ${OUT_STANDALONE_LCR_ID_LIST}    ${standalone_lcr_id_list}
    Set##TODO: Get BTS SW Active Release should be outside below keyword??

SCFC Get Cell Parameter
    [Arguments]    ${lncel_id}
    ...            ${parameter}
    ...            ${scfc_file}=${OUT_SCFC_FILE_PATH}
    ${out_parameter_value}=    Get Element Text    source=${scfc_file}
    ...    xpath=//managedObject[@distName="MRBTS-${OUT_ENB_ID}/LNBTS-${OUT_ENB_ID}/LNCEL-${lncel_id}"]/p[@name="${parameter}"]
    [Return]            ${out_parameter_value}

SCFC Get cellTechnology
    [Arguments]    ${lncel_id}    ${scfc_file}=${OUT_SCFC_FILE_PATH}
    [Documentation]    Author:    artur.krolak@nokia.com
    ${out_cellTechnology}=    SCFC Get Cell Parameter    lncel_id=${lncel_id}
    ...                                                  parameter=cellTechnology
    [Return]            ${out_cellTechnology}

SCFC Get nbIoTMode
    [Arguments]    ${lncel_id}    ${scfc_file}=${OUT_SCFC_FILE_PATH}
    [Documentation]    Author:    artur.krolak@nokia.com
    ${out_nbIoTMode}=    SCFC Get Cell Parameter    lncel_id=${lncel_id}
    ...                                             parameter=nbIoTMode
    [Return]            ${out_nbIoTMode}

SCFC Get nbIoTLinkedCellId
    [Arguments]    ${lncel_id}    ${scfc_file}=${OUT_SCFC_FILE_PATH}
    [Documentation]    Author:    artur.krolak@nokia.com
    ${out_nbIotLinkedCellId}=    SCFC Get Cell Parameter    lncel_id=${lncel_id}
    ...                                                     parameter=nbIotLinkedCellId
    [Return]            ${out_nbIotLinkedCellId}

#SCFC Set Default Cloud SCFC


SCFC Load Default Configuration On Site
    [Documentation]  Author:    artur.krolak@nokia.com
    ...              This keywords perform commissioning for default TL state - no nbIoT feature activated (scfc file from "node 1" directory)
    Perform Full Commissioning And Check BTS OnAir    path_to_full_scf=${OUT_SCFC_DEFAULT_CLOUD}

SCFC Get Commissioning File From BTS
    [Arguments]    ${scfc_name}
    ...            ${scfc_path}=${OUT_SUITE_LOGS_DIR_PATH}
    [Documentation]   Allowed scopes are TEST or SUITE
    ...               Author:           artur.krolak@nokia.com
    ...               Maintainer:       Author
    ${out_scfc_file_path}=    Set Variable    ${scfc_path}/${scfc_name}
    Set Suite Variable    ${OUT_SCFC_FILE_PATH}    ${out_scfc_file_path}
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Site Manager Get Commissioning And Save As File    logs_dir_path=${scfc_path}
    ...                                                                                                         scfc_file_name=${scfc_name}
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"    taf.sbts.oam.coam.admin.Collect SCF    target_file_name=${OUT_SCFC_FILE_PATH}
    OperatingSystem.File Should Exist    ${OUT_SCFC_FILE_PATH}
    ${out_enb_id}=    SCFC Get BtsId    ${OUT_SCFC_FILE_PATH}
    Set Suite Variable    ${OUT_ENB_ID}    ${out_enb_id}

#SCFC Get Cells And RMOD Lists From ENB
#    [Arguments]    ${postfix}=${EMPTY}
#    ...            ${scope}=TEST
#    [Documentation]   Allowed scopes are TEST or SUITE
#    ...               Author:           artur.krolak@nokia.com
#    ...               Maintainer:       Author
#    ${out_scfc_file_path}=    Set Variable    ${OUT_${scope}_LOGS_DIR_PATH}SCFC_${postfix}.xml
#    Set Suite Variable    ${OUT_SCFC_FILE_PATH}    ${out_scfc_file_path}
#    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"
#    ...    Site Manager Get Commissioning And Save As File    logs_dir_path=${OUT_${scope}_LOGS_DIR_PATH}
#    ...        logs_dir_path=${OUT_${scope}_LOGS_DIR_PATH}    scfc_file_name=SCFC_${postfix}.xml
#    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"    taf.sbts.oam.coam.admin.Collect SCF    target_file_name=${OUT_SCFC_FILE_PATH}
#    OperatingSystem.File Should Exist    ${OUT_SCFC_FILE_PATH}
##    ${out_rmod_ser_num_list}=    SCFC Create FR Serial Number List    ${OUT_SCFC_FILE_PATH}
##    Set Suite Variable    ${OUT_RMOD_SER_NUM_LIST}    ${out_rmod_ser_num_list}
##    ${out_rmod_type_list}=    SCFC Get Product Name For FR Serial Number    ${OUT_SCFC_FILE_PATH}    ${OUT_RMOD_SER_NUM_LIST}
##    Set Suite Variable    ${OUT_RMOD_TYPE_LIST}    ${out_rmod_type_list}
#    ${out_enb_id}=    SCFC Get BtsId    ${OUT_SCFC_FILE_PATH}
#    Set Suite Variable    ${OUT_ENB_ID}    ${out_enb_id}
##    Run Keyword If    ${OUT_INBAND_LCR_ID_LIST} != @{EMPTY}    Get Info About NBIoT Cell

#Get NBIoT Info Of All Cells
#    [Arguments]  ${lcr_id_list}
#    [Documentation]    Author:    artur.krolak@nokia.com
#    ...    Return the list of dictionaries with info all cells. To get value of key form list of dict use "get from dictionary" keyword
#    ...                e.g. "${info}=  get from dictionary  @{data_of_all_cells}[5]  cellTechnology".
#    ...                There is an assumption, that items from lnc_id_list are corresponding to those from lcr_id_list, e.g
#    @{out_data_of_all_cells}=    Create List
#    :FOR    ${out_cell_id}    IN    @{lcr_id_list}
#    \  ${out_lcr_id}=    Set Variable  ${out_cell_id}
#    \  ${out_lncel_id}=    SCFC Get LncelId For LcrId    ${OUT_SCFC_FILE_PATH}    ${out_cell_id}
#    \  ${out_cellTechnology}=    SCFC Get cellTechnology    ${out_lncel_id}
#    \  ${out_nbIoTMode}=    SCFC Get nbIoTMode    ${out_lncel_id}
#    \  ${out_nbIotLinkedCellId}=    Run Keyword If    '${out_nbIoTMode}'!='disabled'    SCFC Get nbIoTLinkedCellId    ${out_cell_id}
#    \  ...                                    ELSE                                      Set Variable    ${EMPTY}
#    \  ${out_cell_data}=    Create Cells Parameters Dictionary    lncel_id=${out_lncel_id}
#    ...                                                           lcr_id=${out_lcr_id}
#    ...                                                           cellTechnology=${out_cellTechnology}
#    ...                                                           nbIoTMode=${out_nbIoTMode}
#    ...                                                           nbIotLinkedCellId=${out_nbIotLinkedCellId}
#    \  Append To List    ${out_data_of_all_cells}    ${out_cell_data}
#    [Return]    ${out_data_of_all_cells}

Create Cells Parameters Dictionary
    [Arguments]    ${lncel_id}
    ...            ${lcr_id}
    ...            ${cellTechnology}
    ...            ${nbIoTMode}
    ...            ${nbIotLinkedCellId}
    [Documentation]    Author:    artur.krolak@nokia.com
    &{out_cell_parameters_dictionary}=    Create Dictionary    lnc_id=${lncel_id}
    ...                                                        lcr_id=${lcr_id}
    ...                                                        cellTechnology=${cellTechnology}
    ...                                                        nbIoTMode=${nbIoTMode}
    ...                                                        nbIotLinkedCellId=${nbIotLinkedCellId}
    [Return]    ${out_cell_parameters_dictionary}

Get Info About NBIoT Cell
    [Arguments]    ${lcr_id_list}=${OUT_INBAND_LCR_ID_LIST}
    [Documentation]    Author:    artur.krolak@nokia.com
    ${out_nbIoT_cells_dictionaries_list}=    Get NBIoT Info Of All Cells    lcr_id_list=${lcr_id_list}
    Set Suite Variable    ${OUT_NBIOT_CELLS_DICTIONARIES_LIST}    ${out_nbIoT_cells_dictionaries_list}
    ${out_legacy_lte_lncell_list}=    Set List Of Legacy LNCELLs
    Set Suite Variable    ${OUT_LEGACY_LTE_LNCELL_LIST}    ${out_legacy_lte_lncell_list}

Set List Of Legacy LNCELLs
    [Arguments]     ${nbIoT_cells_dictionaries_list}=${OUT_NBIOT_CELLS_DICTIONARIES_LIST}
    [Documentation]   Returns list of LTE LNCELLS.
    ...               In current state of development only LTE-Legacy LNCELL do have parameter "operationalState" which can establish that
    ...               cell is in "onAir" state. Narrow band IoT cells are transparent for OAM about "onAir" state,
    ...               hence such workaround was introduced.
    ...               Keyword must be run only after commissioning to state without nbIoT enabled.
    ...               Author:    artur.krolak@nokia.com
    ${out_legacy_lte_lncell_list}=    Create List
    FOR    ${out_cell_dictionary}    IN    @{nbIoT_cells_dictionaries_list}
         ${out_cellTechnology}=    Get From Dictionary    ${out_cell_dictionary}    cellTechnology
         Run Keyword If    '${out_cellTechnology}'=='FDD'    Append To List    ${out_legacy_lte_lncell_list}    ${out_cell_dictionary.lnc_id}
    END
    [Return]    ${out_legacy_lte_lncell_list}

Check If eNB Is Pingable
    [Documentation]    Author:    artur.krolak@nokia.com
    Check If Host Is Pingable    host=${ENB_IP}

Check If TRS Is Pingable
    [Documentation]    Author:    artur.krolak@nokia.com
    Check If Host Is Pingable    host=${TRS_IP}

Check If Host Is Pingable
    [Arguments]    ${host}    ${times}=1
    ${output}=  Run    ping -c ${times} ${host}
    Should Contain    ${output}    ${times} packets transmitted, ${times} received

Check If eNB Is Not Pingable
    [Documentation]    Author:    artur.krolak@nokia.com
    Check If Host Is Pingable    host=${ENB_IP}

Check If TRS Is Not Pingable
    [Documentation]    Author:    artur.krolak@nokia.com
    Check If Host Is Pingable    host=${TRS_IP}

Check If Host Is Not Pingable
    [Arguments]    ${host}    ${times}=1
    ${output}=  Run    ping -c ${times} ${host}
    Should Contain    ${output}    ${times} packets transmitted, 0 received

Wait For Host To Be Pingable
    [Arguments]    ${host}    ${timeout}=600
    [Documentation]    Author:    artur.krolak@nokia.com
    Wait Until Keyword Succeeds    ${timeout}    5    Check If Host Is Pingable    host=${host}
    [Return]     PASS

Wait For eNB To Be Pingable
    [Documentation]    Author:    tomasz.blaszczyszyn@nokia.com
    ${out_result}=    Wait For Host To Be Pingable    host=${ENB_IP}
    [Return]    ${out_result}

Wait For TRS To Be Pingable
    [Documentation]    Author:    tomasz.blaszczyszyn@nokia.com
    ${out_result}=    Wait For Host To Be Pingable    host=${TRS_IP}
    [Return]    ${out_result}

Wait Until Host Is Unavailable
    [Arguments]    ${host}    ${timeout}=600
    [Documentation]    Author:    tomasz.blaszczyszyn@nokia.com
    Wait Until Keyword Succeeds    ${timeout}    5    Check If Host Is Not Pingable    host=${host}
    [Return]     PASS

Wait Until eNB Is Unavailable
    [Documentation]    Author:    tomasz.blaszczyszyn@nokia.com
    Wait Until Host Is Unavailable    host=${ENB_IP}

Wait Until TRS Is Unavailable
    [Documentation]    Author:    tomasz.blaszczyszyn@nokia.com
    Wait Until Host Is Unavailable    host=${TRS_IP}

FSM Access Open Connection
    [Arguments]    ${alias}=fsm_access
    Setup Enb Fsm Access    alias=${alias}

FSM Access Close Connection
    [Arguments]    ${alias}=fsm_access
    Teardown Enb Fsm Access    alias=${alias}

FSM Access Put Swconfig On Enb And Reboot
    [Arguments]    ${source}
    ...            ${alias}=fsm_access
    ...            ${enb_reboot}=True
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Put file to enb. If reboot after load is needed please set the arguments enb_reboot on True
    ute_fsmaccess.Put Enb Swconfig File    source=${source}
    ...                                    alias=${alias}
    Run Keyword If    '${enb_reboot}'=='True'    Execute Command On Enb    reboot    alias=${alias}
    Wait Until TRS Is Unavailable
    Wait For TRS To Be Pingable
    Wait For eNB To Be Pingable

FSM Access Get eNB HW Version And Set eNB Side
    [Arguments]    ${alias}=fsm_access
    [Documentation]    Author:    artur.krolak@nokia.com
    FSM Access Get eNB HW Version    alias=${alias}
    FSM Access Set eNB Side    alias=${alias}

FSM Access Get eNB HW Version
    [Arguments]    ${alias}=fsm_access
    ${out_hw_version}=    Get Enb Hw Version    alias=${alias}
    Set Suite Variable    ${OUT_HW_VERSION}    ${out_hw_version}
    [Return]    ${out_hw_version}

FSM Access Get Enb Sw Program
    ${out_sw_program}=    Get Regexp Matches    ${OUT_ENB_ACTIVE_SW}    ^[A-Z]{2,4}
    ${out_sw_program}=    Get From List    ${out_sw_program}    0
    Set Suite Variable    ${OUT_SW_PROGRAM}    ${out_sw_program}
    [Return]    ${out_sw_program}


FSM Access Set eNB Side
    [Arguments]    ${alias}=fsm_access
    ${out_bts_side}=    Execute Command On Enb    ddal -s ddal_sysinfo_module_get_domain_id 0| tail -c 2    alias=${alias}
    ${out_bts_side}=    Set Variable If    ('${out_bts_side}'=='1' or '${out_bts_side}'=='0')    1
    ...                                    ('${out_bts_side}'=='2')    4
    Set Suite Variable    ${OUT_BTS_SIDE}    ${out_bts_side}
    [Return]    ${out_bts_side}

FSM Get RawAlarmHistory
    [Arguments]   ${alarm_file}=${OUT_TEST_LOGS_DIR_PATH}/RawAlarmHistory.txt
    ...           ${alias}=fsm_access
    [Documentation]    Author:       artur.krolak@nokia.com
    Get Enb File    source=/ram/RawAlarmHistory.txt
    ...             destination=${alarm_file}
    ...             alias=${alias}

FSM Access Get Active And Passive Enb Sw Versions
    ${out_enb_active_sw}=    FSM Access Get Acive Enb Sw Version
    [Return]    ${out_enb_active_sw}
#    ${out_enb_passive_sw}=    FSM Access Get Passive Enb Sw Version
#    [Return]    ${out_enb_active_sw}    ${out_enb_passive_sw}

FSM Access Get Enb Sw Version
    [Arguments]    ${partition}=active
    ...            ${alias}=fsm_access
    ${out_enb_sw}=    Get Enb Sw Version    partition=${partition}
    ...                                     alias=${alias}
    [Return]    ${out_enb_sw}

FSM Access Get Acive Enb Sw Version
    ${out_enb_active_sw}=    FSM Access Get Enb Sw Version    partition=active
    Set Suite Variable    ${OUT_ENB_ACTIVE_SW}    ${out_enb_active_sw}
    [Return]    ${out_enb_active_sw}

FSM Access Get Passive Enb Sw Version
    ${out_enb_passive_sw}=    FSM Access Get Enb Sw Version    partition=passive
    Set Suite Variable    ${OUT_ENB_PASSIVE_SW}    ${out_enb_passive_sw}
    [Return]    ${out_enb_passive_sw}

FSM Access Ping Given Ip
    [Arguments]    ${ip}=127.0.0.1
    ...            ${counter}=1
    ...            ${alias}=fsm_access
    FSM Access Open Connection    alias=${alias}
    ${out_command}=    Execute Command On Enb    ping -c ${counter} ${ip}    alias=${alias}
    FSM Access Close Connection    alias=${alias}
#    ${out_result}=    Run    tail -n 2 ${out_command} | head -n 1 | awk -F, '{print$3}'
#    Should Be Equal As Strings    "${out_command}"    " 0% packet loss"


SCFC Get IP And Rat Support of MME
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Get from scfc file information of MME IP and Rat Support.
    [Arguments]    ${number_of_lnmme}
    ...            ${scfc_file_path}=${OUT_SCFC_FILE_PATH}
    ...            ${enb_id}=${OUT_ENB_ID}
    ${out_mme_ip}=    Evaluate Xpath    source=${OUT_SCFC_FILE_PATH}
    ...    expression=string(.//managedObject[@distName="MRBTS-${OUT_ENB_ID}/LNBTS-${OUT_ENB_ID}/LNMME-${number_of_lnmme}"]/p[@name="ipAddrPrim"])
    ${out_mme_rat_support}=    Evaluate Xpath    source=${OUT_SCFC_FILE_PATH}
    ...    expression=string(.//managedObject[@distName="MRBTS-${OUT_ENB_ID}/LNBTS-${OUT_ENB_ID}/LNMME-${number_of_lnmme}"]/p[@name="mmeRatSupport"])
    [Return]    ${out_mme_rat_support}    ${out_mme_ip}

SCFC Get IP's of MME
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Return dictionary of all MME's IP where key is MME RAT Support. Keyword return e.g. {'Wideband-LTE':'10.44.199.18'}.
    [Arguments]    ${scfc_file}=${OUT_SCFC_FILE_PATH}
    ${out_dict_of_mme}=    Create Dictionary
    ${out_count_mme}=    xml.Get Element Count    source=${OUT_SCFC_FILE_PATH}
    ...                                           xpath=//cmData/managedObject[@class="NOKLTE:LNMME"]
    FOR    ${out_index}    IN RANGE    0    ${out_count_mme}
        ${out_mme_rat_support}    ${mme_ip}=      SCFC Get IP And Rat Support of MME    number_of_lnmme=${out_index}
        Set To Dictionary    ${out_dict_of_mme}    ${out_mme_rat_support}=${mme_ip}
    END
    Set Suite Variable    ${OUT_DICT_OF_MME}    ${out_dict_of_mme}
    [Return]    ${out_dict_of_mme}

Set SCFC Variable
    [Arguments]    ${tc_id}
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Setting the scfc variable needed for commissioning according to provided test case id. Every test case id
    ...                might be linked to any variable that is defined in Test Line's init.py file.
    ...                feature_scfc_file variable is defined in testsuite/WMP/GVe/Banglore/IoT/config/feature_scfc_file.yaml
    ${out_cell_variant}=  Get From Dictionary    ${feature_scfc_file}    ${tc_id}
    ${out_scfc_file}=    Set Variable    ${SCFC_${out_cell_variant}}
    Run Keyword If    '${tc_id}'==''    FAIL    msg=Unspecified test case id provided. Please refer to keyword's documentation.
    Set Suite Variable    ${OUT_SCFC_FILE}    ${out_scfc_file}
    [Return]    ${out_scfc_file}

SCFC Perform Parameter Commissioning
    [Arguments]    ${parameter_string}
    [Documentation]    Author:    artur.krolak@nokia.com
    ${out_parameter}=    Convert To String    ${parameter_string}
    Perform Parameter Commissioning    parameter=${out_parameter}
#    Infomodel Unexpected Alarms Should Not Be Available    allowed_alarms=${ALLOWED_ALARMS}

SCFC Full Commissioning
    [Arguments]    ${path_to_full_scf}
    [Documentation]    Author:    filip.sokolowski@nokia.com
    ...  Maintainer:   Author
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}"=="BTSSM"    Perform Full Commissioning And Wait For Reset    fullfile=${path_to_full_scf}
    ...                                                                                                     timeout=1500
    ...    ELSE IF    "${ENB_ACTIONS_TRIGGER}"=="ADMIN"    taf.sbts.oam.coam.admin.Perform Commissioning    bts_id=${OUT_ENB_ID}
    ...                                                                             scf_file=${path_to_full_scf}
    ...                                                                             skip_parameter_relation_errors=True

SCFC Perform delta commissioning
    [Arguments]    ${delta_file}=None    ${delta_file_json}=None
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"
    ...    SCFC Migrate And Perform Delta Commissioning    delta_file_path=${delta_file}
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"
    ...    Perform Delta Recommissioning    delta_file=${delta_file_json}
    Infomodel BTS Should Reach OnAir
    Sleep  30

SCFC Migrate And Perform Delta Commissioning
    [Arguments]    ${delta_file_path}
    SCFC Migrate With SuTool to eNB Version    path_to_full_scf=${delta_file_path}
    ute_btssm.Perform Delta Commissioning      deltafile=${delta_file_path}

SCFC Migrate With SuTool And Perform Full Commissioning
    [Arguments]  ${path_to_full_scf}
    [Documentation]    Author:    artur.krolak@nokia.com
    SCFC Migrate with SuTool to eNB Version    path_to_full_scf=${path_to_full_scf}
    SCFC Full Commissioning    path_to_full_scf=${path_to_full_scf}

SCFC Migrate With SuTool to eNB Version
    [Arguments]    ${path_to_full_scf}
    ...            ${output_path}=${path_to_full_scf}
    ...            ${log_path}=${OUT_TEST_LOGS_DIR_PATH}
    [Documentation]    Author:    artur.krolak@nokia.com
    Setup Scfc
    ${result}=    ute_scfc.Migrate_Scfc_Using_Sutool    scfc_path=${path_to_full_scf}
    ...                                                 output_path=${output_path}
    ...                                                 log_path=${log_path}sutool.log
    [Teardown]    Teardown Scfc

SSH Open Connection To Server
    [Documentation]    Author:    tomasz.blaszczyszyn@nokia.com
    [Arguments]    ${ip_addr}
    ...            ${login}
    ...            ${password}
    ...            ${alias}
    SSHLibrary.Open Connection    host=${ip_addr}
    ...                           alias=${alias}
    SSHLibrary.Login    ${login}    ${password}

SSH Open Connection to SMod
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Open SSH connection to SM use default login and password.
    [Arguments]    ${enb_ip}=${ENB_IP}
    ...            ${login}=${ENB_USER}
    ...            ${password}=${ENB_PASSWORD}
    ...            ${alias}=ssh_smod
#    SSHLibrary.Open Connection    host=${enb_ip}
#    ...                           alias=${alias}
#    SSHLibrary.Login    ${login}    ${password}
    SSH Open Connection To Server    ip_addr=${enb_ip}
    ...                              login=${login}
    ...                              password=${password}
    ...                              alias=${alias}

SSH Open Connection To SMod TRS IP
    [Documentation]    Author:    tomasz.blaszczyszyn@nokia.com
    ...                Open SSH connection to SM TRS IP use default login and password.
    [Arguments]    ${enb_ip}=${TRS_IP}
    ...            ${login}=${ENB_USER}
    ...            ${password}=${ENB_PASSWORD}
    ...            ${alias}=ssh_smod_trs
#    SSHLibrary.Open Connection    host=${enb_ip}
#    ...                           alias=${alias}
#    SSHLibrary.Login    ${login}    ${password}
    SSH Open Connection To Server    ip_addr=${enb_ip}
    ...                              login=${login}
    ...                              password=${password}
    ...                              alias=${alias}


IPTABLES Open SSH To SMod And S1 Interface Block
    [Arguments]    ${mme_to_block}
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Block S1 interface by adding registry to SM's firewall.
    SSH Open Connection to SMod
    FOR    ${out_index}    IN    @{mme_to_block}
      ${out_mme_ip}=    Get From Dictionary    ${OUT_DICT_OF_MME}    ${out_index}
      IPTABLES Add Registry To SM Firewall    ${out_mme_ip}
      IPTABLES Check If IP Exist    ${out_mme_ip}
    END
    SSHLibrary.Close Connection

IPTABLES Open SSH To SMod And S1 Interface Unblock
    [Arguments]    ${mme_to_unblock}
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Unblock S1 interface by removing registry from SM's firewall.
    SSH Open Connection to SMod
    FOR    ${out_index}    IN    @{mme_to_unblock}
      ${out_mme_ip}=    Get From Dictionary     ${OUT_DICT_OF_MME}    ${out_index}
      IPTABLES Delete Registry From SM's Firewall    ${out_mme_ip}
      IPTABLES Check If IP Not Exist    ${out_mme_ip}
    END
    SSHLibrary.Close Connection

IPTABLES Add Registry To SM Firewall
    [Arguments]    ${ip_to_add}
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Add registry to table firewall of SM.
    ${out}=    SSHLibrary.Execute Command    iptables -A INPUT -s ${ip_to_add} -j DROP
    ${out}=    SSHLibrary.Execute Command    iptables -A OUTPUT -d ${ip_to_add} -j DROP

IPTABLES Delete Registry From SM's Firewall
    [Arguments]  ${ip_to_delete}
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Delete registry from table firewall of SM.
    ${out}=    SSHLibrary.Execute Command    iptables -D INPUT -s ${ip_to_delete} -j DROP
    ${out}=    SSHLibrary.Execute Command    iptables -D OUTPUT -d ${ip_to_delete} -j DROP

IPTABLES Check If IP Exist
    [Arguments]  ${ip_to_check}
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Check if IP was added to firewall's table of SM.
    ${out_message_to_check}=    Set Variable    DROP\\s*all\\s*--\\s*${ip_to_check}\\s*anywhere\\D*DROP\\s*all\\s*--\\s*anywhere\\s*${ip_to_check}
    ${out}=    SSHLibrary.Execute Command    iptables -L | grep -E "Chain|${ip_to_check}"
    Should Match Regexp    ${out}    ${out_message_to_check}

IPTABLES Check If IP Not Exist
    [Arguments]  ${ip_to_check}
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Check if IP was deleted from firewall's table of SM.
    ${out_message_to_check}=    Set Variable    DROP\\s*all\\s*--\\s*${ip_to_check}\\s*anywhere\\D*DROP\\s*all\\s*--\\s*anywhere\\s*${ip_to_check}
    ${out}=    SSHLibrary.Execute Command    iptables -L | grep -E "Chain|${ip_to_check}"
    Should Not Match Regexp  ${out}  ${out_message_to_check}

Perform Full Commissioning And Check BTS OnAir All Cells OnAir
    [Arguments]    ${path_to_full_scf}
    [Documentation]
    ...  Author:       filip.sokolowski@nokia.com
    ...  Maintainer:   Author
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Perform Full Commissioning And Wait For Reset    fullfile=${path_to_full_scf}
    ...    ELSE IF    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"    taf.sbts.oam.coam.admin.Perform Commissioning    bts_id=${OUT_ENB_ID}
    ...                                                                                         scf_file=${path_to_full_scf}
#    Infomodel BTS Should Reach OnAir

Perform Delta Commissioning And Check BTS OnAir All Cells OnAir
    [Arguments]    ${tc_id}
    [Documentation]
    ...  Author:       filip.sokolowski@nokia.com
    ...  Maintainer:   Author, dawid.wojciechowski@nokia.com
    ${out_path_to_delta_scf}=    Set SCFC Variable    tc_id=${tc_id}
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Run Keywords
    ...                      SCFC Migrate with SuTool to eNB Version    path_to_full_scf=${out_path_to_delta_scf}    AND
    ...                      Perform Delta Commissioning    deltafile=${out_path_to_delta_scf}
    ...    ELSE IF    "${ENB_ACTIONS_TRIGGER}" == "ADMIN"    taf.sbts.oam.coam.admin.Perform Commissioning    bts_id=${OUT_ENB_ID}
    ...                                                                                         scf_file=${out_path_to_delta_scf}
    Infomodel BTS Should Reach OnAir

Perform Delta Commissioning With Full Commissioning Fallback
    [Arguments]    ${scfc_file}
    ...            ${delta_file}
    [Documentation]    Author:    artur.krolak@nokia.com
    ${out_delta_result}=    Run Keyword And Return Status    Perform Delta Commissioning    deltafile=${delta_file}
    Run Keyword If    not ${out_delta_result}    SCFC Full commissioning    ${scfc_file}

System Make File Executable
    [Arguments]    ${bin_path}
    [Documentation]    Author:    artur.krolak@nokia.com
    ${rc}=    Run And Return Rc    chmod a+x '${bin_path}'
    Should Be Equal As Integers    ${rc}    ${0}    msg=Failed to add executable mode to file ${bin_path}. Maybe not exist?    values=False

TCPDump Start Capture Packets
    [Arguments]    ${enb_ip}=${ENB_IP}
    ...            ${login}=${ENB_USER}
    ...            ${password}=${ENB_PASSWORD}
    ...            ${file_name}=wireshark.pcap
    ...            ${file_size}=20
    ...            ${interface}=any
    ...            ${filters}=sctp
    [Documentation]    Author:    artur.krolak@nokia.com
    ...    Get packets from define interface with filters to file. If needed more than one filter please use expressions: && (and), || (or), ! (not)
    Wait For eNB To Be Pingable
    ${actual_time}=  Get Actual Timestamp
    SSH Open Connection to SMod
    Start Command    tcpdump -w ${actual_time}${file_name} -i ${interface} ${filters}
    ${out_pid_of_tcpdump_list}=    SSHLibrary.Execute Command    pidof tcpdump
    SSHLibrary.Close Connection

TCPDump Stop Capture Packets And Get Wireshark File
    [Arguments]  ${enb_ip}=${ENB_IP}
    ...          ${login}=${ENB_USER}
    ...          ${password}=${ENB_PASSWORD}
    ...          ${file_name}=wireshark.pcap
    [Documentation]    Author:    artur.krolak@nokia.com
    Wait For eNB To Be Pingable
    ${actual_time}=  Get Actual Timestamp
    SSH Open Connection to SMod
    ${out_pid_of_tcpdump_list}=    SSHLibrary.Execute Commandnd    pidof   tcpdump
    Start Command    kill ${out_pid_of_tcpdump_list}
    Wait Until Keyword Succeeds    5 min    2 s    sshlibrary.get file    *${file_name}    ${OUT_SUITE_LOGS_DIR_PATH}
    SSHLibrary.Execute Commandnd    rm *${file_name}
    ${out_pid_of_tcpdump_list}=    SSHLibrary.Execute Command    pidof tcpdump
    SSHLibrary.Close Connection

TShark Check Message In Captured Packets
    [Arguments]    ${message_to_check}
    ...            ${file}=${path_to_file}
    [Documentation]    Author:    artur.krolak@nokia.com
    ${out}=    Run Keyword    recover_and_check_if_element_attribute_exists    file=${file}
    ...                                                                        value=${message_to_check}
    Run Keyword If    ${out}==${FALSE}    FAIL    msg=No message "${message_to_check}" found.

TShark Wait On Message In Packets
    [Arguments]     ${message_to_check}
    ...             ${file}=${path_to_file}
    [Documentation]    Author:    artur.krolak@nokia.com
    Wait Until Keyword Succeeds    5min    10s    TShark Check Message In Captured Packets    message_to_check=${message_to_check}
    ...                                                                                       file=${file}

TShark Check Attach Message On S1 Intefrace
    [Arguments]    ${xml_file}=${path_to_file}
    [Documentation]    Author:    artur.krolak@nokia.com
    Run Keyword And Continue On Failure    Wait On Message In Packets    wait_on_message=Attach request
    ...                                                                  file=${xml_file}
    Run Keyword And Continue On Failure    Wait On Message In Packets    wait_on_message=Authentication request
    ...                                                                  file=${xml_file}
    Run Keyword And Continue On Failure    Wait On Message In Packets    wait_on_message=Authentication response
    ...                                                                  file=${xml_file}
    Run Keyword And Continue On Failure    Wait On Message In Packets    wait_on_message=Attach accept
    ...                                                                  file=${xml_file}
    Run Keyword And Continue On Failure    Wait On Message In Packets    wait_on_message=Attach complete
    ...                                                                  file=${xml_file}

TShark Start Capturing Packets and Set Port Mirroring on S1 interface
    [Arguments]    ${trs_ip}=${TRS_IP}
    ...            ${trs_login}=${TRS_LOGIN}
    ...            ${trs_pass}=${TRS_PASS}
    ...            ${filter}=sctp
    ...            ${log_dir}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${file_name}=tshark
    ...            ${alias}=port_mirroring
    [Documentation]    Author:    artur.krolak@nokia.com
    ${out_timestamp}=  Get Actual Timestamp
    ${rc}    ${out_interface_name}=    Run And Return Rc and output
    ...    netstat -ie | grep -B1 "192.168." | head -n1 | awk '{print $1}' | tr -d "[:punct:]"
    ${rc}    ${out_interface_mac}=    Run And Return Rc and output
    ...    netstat -ie | awk -v RS='' '/192.168/' | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
    Setup Tshark    interface=${out_interface_name}
    ...             log_dir=${log_dir}
    ...             log_name=${file_name}
    Setup Ta Enb Trs Traffic    ip_address=${TRS_IP}
    ...                         username=${TRS_LOGIN}
    ...                         password=${TRS_PASS}
    ...                         alias=${alias}
    Run Keyword If    "${OUT_HW_VERSION}" == "FSMr3"  Start Traffic Capturing    capture_option=streaming
    ...                                                                          streaming_option_port=LMP
    ...                                                                          streaming_option_mac=${out_interface_mac}
    ...                                                                          alias=${alias}
    ...    ELSE IF    "${OUT_HW_VERSION}" == "FSMr4"  Start Traffic Capturing    capture_option=streaming
    ...                                                                          streaming_option_port=AIRSCALE-LMP
    ...                                                                          streaming_option_mac=${out_interface_mac}
    ...                                                                          alias=${alias}
    ...       ELSE     Log   \nCan't get HW Version of eNB!    console=True
    Start Capturing    capture_filter=${filter}

TShark Stop Capturing Packets and Disable Port Mirroring on S1 interface
    [Arguments]    ${alias}=port_mirroring
    [Documentation]    Author:    artur.krolak@nokia.com
    Stop Capturing
    Stop Traffic Capturing    alias=${alias}
    Teardown Tshark
    Teardown Ta Enb Trs Traffic    alias=${alias}
    Teardown All Aliases For Ta Enb Trs Traffic

Setup And Start Capturing Tshark
    [Arguments]                   ${capture_filter}=host ${CPLANE_IP}
    ...                           ${interface}=any
    ...                           ${alias}=default
    ...                           ${log_dir}=/tmp/ENB_${OUT_ENB_ID}
    ...                           ${log_name}=None
    ...                           ${ssh_ip}=${TSHARK_IP}
    ...                           ${ssh_username}=${TSHARK_USER}
    ...                           ${ssh_password}=${TSHARK_PASSWORD}
    ...                           ${tshark_dir}=${TSHARK_DIR}
    ute_tshark.Setup Tshark       interface=${interface}
    ...                           alias=${alias}
    ...                           log_dir=${log_dir}
    ...                           log_name=${log_name}
    ...                           ssh_ip=${ssh_ip}
    ...                           ssh_username=${ssh_username}
    ...                           ssh_password=${ssh_password}
    ...                           tshark_dir=${tshark_dir}
    ute_tshark.Start Capturing    capture_filter=${capture_filter}
    ...                           alias=${alias}

Stop Tshark Capturing And Collect Logs
    [Arguments]                          ${stop_capturing}=True
    ...                                  ${alias}=default
    ...                                  ${logs_dir}=${OUT_TEST_LOGS_DIR_PATH}
    ...                                  ${log_name}=None
    ...                                  ${remote_log_dir}=/tmp/ENB_${OUT_ENB_ID}
    ...                                  ${host}=${TSHARK_IP}
    ...                                  ${login}=${TSHARK_USER}
    ...                                  ${password}=${TSHARK_PASSWORD}
    Run Keyword If                       ${stop_capturing}
    ...    ute_tshark.Stop Capturing     alias=${alias}
    SSHLibrary.Open Connection           host=${host}    alias=${alias}
    SSHLibrary.Login                     username=${login}     password=${password}
    ${output}=    SSHLibrary.Get File    source=${remote_log_dir}/${log_name}
    ...                                  destination=${logs_dir}
    SSHLibrary.Execute Command           command=rm -f ${remote_log_dir}/${log_name}
    SSHLibrary.Close Connection
    ute_tshark.Teardown Tshark           alias=${alias}
    Sleep  10s


Check Enb Is Pingable And OnAir And No Unexpected Alarms
    ${out_enb_status}=  Wait For TRS To Be Pingable
#    Infomodel BTS Should Reach OnAir
#    Infomodel Unexpected Alarms Should Not Be Available    ${ALLOWED_ALARMS}

Infomodel Connect Im
    [Arguments]    ${alias}=${IM_ALIAS}
    Run Keyword If   '${INFO_MODEL_PORT}' == 'ENABLED' and '${ENB_ACTIONS_TRIGGER}' == 'BTSSM'
    ...               ute_admin_infomodel.Setup Infomodel     im_library_log_dir=${OUT_TEST_LOGS_DIR_PATH}
    ...                                                      alias=${alias}
    ...    ELSE IF  '${INFO_MODEL_PORT}' == 'DISABLED' and '${ENB_ACTIONS_TRIGGER}' == 'BTSSM'
    ...               ute_admin_infomodel.Setup Infomodel    address=${ENB_IP}
    ...                                                      port=3600
    ...                                                      use_ssl=True
    ...                                                      admin_api_log_dir=${OUT_TEST_LOGS_DIR_PATH}
    ...                                                      alias=${alias}
    ...    ELSE IF  '${ENB_ACTIONS_TRIGGER}' == 'ADMIN'
    ...               ute_admin_infomodel.Setup Infomodel    address=${ENB_IP}
    ...                                                      port=443
    ...                                                      use_ssl=True
    ...                                                      admin_api_log_dir=${OUT_TEST_LOGS_DIR_PATH}
    ...                                                      alias=${alias}
    ute_admin_infomodel.Connect Infomodel    alias=${alias}

#Infomodel Unexpected Alarms Should Not Be Available
#    [Arguments]    ${allowed_alarms}=${EMPTY}
#    ...            ${mandatory_alarms}=${EMPTY}
#    ...            ${alias}=${IM_ALIAS}
#    [Documentation]    Author:    artur.krolak@nokia.com
#    Run Keyword And Continue On Failure    Info Model Alarms Get And Check    allowed=${allowed_alarms}
#    ...                                                                       mandatory=${mandatory_alarms}
#    ...                                                                       bts_l_id=${OUT_BTS_SIDE}
#    ...                                                                       alias=${alias}

Infomodel All Cells Should Be Disabled
    [Arguments]    ${lcr_id_list}=${OUT_LCR_ID_LIST}
    ...            ${alias}=${IM_ALIAS}
    [Documentation]    Author:    artur.krolak@nokia.com
    FOR    ${out_index}    IN    @{lcr_id_list}
      Infomodel LCELL Blocking State Should Be    lcr_id=${out_index}
      ...                                         state=disabled
      ...                                         alias=${alias}
      ...                                         timeout=30
    END
Infomodel Cell Should Be Enabled
    [Arguments]    ${lcr_id_list}=${OUT_LCR_ID_LIST}
    ...            ${alias}=${IM_ALIAS}
    [Documentation]    Author:       artur.krolak@nokia.com
    FOR    ${out_index}    IN    @{lcr_id_list}
      Infomodel LCELL Blocking State Should Be    lcr_id=${out_index}
      ...                                         state=enabled
      ...                                         alias=${alias}
      ...                                         timeout=30
    END
Infomodel LCELL Blocking State Should Be
    [Arguments]    ${lcr_id}
    ...            ${state}
    ...            ${alias}=${IM_ALIAS}
    ...            ${timeout}=30
    [Documentation]    Author:    artur.krolak@nokia.com
    Query Infomodel    query=//LNCEL_R-${lcr_id} is [operationalState=${state}]
    ...                alias=${alias}
    ...                timeout=${timeout}

Infomodel Alarm Should Be Raised
    [Arguments]    ${lcr_id}
    ...            ${fault_id}=49
    ...            ${alias}=${IM_ALIAS}
    [Documentation]    Author:    artur.krolak@nokia.com
    Query Infomodel    query=//LNCEL_L-${lcr_id}/ALARM_L-* is [alarmInformation.faultId=${fault_id}]
    ...                alias=${alias}
    ...                timeout=30

Infomodel Alarm Should Be Cleared
    [Arguments]    ${lcr_id}
    ...            ${fault_id}=49
    ...            ${alias}=${IM_ALIAS}
    [Documentation]    Author:    artur.krolak@nokia.com
    Query Infomodel    query=count //LNCEL_L-${lcr_id}/ALARM_L-* is [alarmInformation.faultId=${fault_id}] = 0
    ...                alias=${alias}
    ...                timeout=30

Infomodel Wait Until All Cells OnAir
    [Arguments]    ${lcr_id_list}
    ...            ${alias}=${IM_ALIAS}
    [Documentation]    Author:    artur.krolak@nokia.com
    FOR    ${out_lcr_id}    IN    @{lcr_id_list}
      Infomodel Wait Until Cell OnAir    lcr_id=${out_lcr_id}    alias=${alias}
    END
Infomodel Wait Until Cell OnAir
    [Arguments]    ${lcr_id}
    ...            ${alias}=${IM_ALIAS}
    [Documentation]    Author:    artur.krolak@nokia.com
    Wait Until Keyword Succeeds    15 min    10s    Infomodel Check Cell OnAir State    lcr_id=${lcr_id}    alias=${alias}

Infomodel Check Cell OnAir State
    [Arguments]    ${lcr_id}
    ...            ${alias}=${IM_ALIAS}
    [Documentation]    Author:    artur.krolak@nokia.com
    Query Infomodel    query=//LNBTS_M-1/CELL_M-${lcr_id} is [stateInfo.proceduralState=OnAirDone]    alias=${alias}

Infomodel BTS Should Reach OnAir
    [Arguments]    ${alias}=${IM_ALIAS}
    [Documentation]    Author:    tomasz.blaszczyszyn@nokia.com
    Run Keyword And Continue On Failure    ute_admin_infomodel.Query Infomodel
    ...                                    query=every //LNBTS_M-1/CELL_M-* is [stateInfo.proceduralState=regex"[oO]nAirDone"]
    ...                                    timeout=600
    ...                                    alias=${alias}
    Run Keyword And Continue On Failure    ute_admin_infomodel.Query Infomodel
    ...                                    query=//LNBTS_M-* is [stateInfo.proceduralState=regex"[oO]nAir"]
    ...                                    timeout=60
    ...                                    alias=${alias}
#    Run Keyword And Continue On Failure    ute_admin_infomodel.Query Infomodel
#    ...                                    query=every //LNBTS_M-1/CELL_M-* is [stateInfo.availabilityStatus=regex"[oO]nline"]
#    ...                                    timeout=60
#    ...                                    alias=${alias}
    Run Keyword And Continue On Failure    ute_admin_infomodel.Query Infomodel
    ...                                    query=every //LNBTS_M-1/CELL_M-* is [stateInfo.operationalState=regex"[eE]nabled"]
    ...                                    timeout=60
    ...                                    alias=${alias}

Infomodel Check Device Status
    [Arguments]    ${object}
    ...            ${status}
    ...            ${objects_ids}
    ...            ${alias}=${IM_ALIAS}
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                Checking status of given objects (given objects are in ${objects_ids}). Allow objects are "Cell" and "FR".
    ...                Allow state are:
    ...                for cell: "OnAirDone" or "Validated"
    ...                for FR: "Blocked" or "Unblocked"
    Run Keyword If    '${object}' == 'Cell'    Query Infomodel
    ...    query=check //LNBTS_M-1/CELL_M-${objects_ids} is [stateInfo.proceduralState='${status}']    alias=${alias}
    Run Keyword If    '${object}' == 'FR'    Query Infomodel
    ...    query=check //RMOD_L-1/RU_L-${objects_ids} is [stateInfo.blockingState='${status}']    alias=${alias}

Infomodel Check eNB Is In onAir State
    [Arguments]    ${expected_value}=OnAir
    ...            ${alias}=${IM_ALIAS}
    [Documentation]    Author:    artur.krolak@nokia.com
    ${infomodel_LNBTS_object}=    Get Infomodel Object    dist_name=//LNBTS_R-${OUT_ENB_ID}
    ...                                                   timeout=900
    ...                                                   alias=${alias}
    Should Be Equal    ${infomodel_LNBTS_object.stateInfo.operationalState}    ${expected_value}

Perform Full Commissioning And Check BTS OnAir
    [Arguments]    ${commissioning_path}
    ...            ${csv_parameter_file}=${EMPTY}
    [Documentation]    Author:    artur.krolak@nokia.com
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}"=="BTSSM"
    ...  SCFC Migrate with SuTool And Perform Full Commissioning    path_to_full_scf=${commissioning_path}
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}"=="ADMIN"
    ...  SCFC Migrate And Perform Full Commissioning Via Admin    path_to_full_scf=${commissioning_path}
    ...                                                           csv_parameter_file=${csv_parameter_file}
    Check Enb Is Pingable And OnAir And No Unexpected Alarms

SCFC Migrate And Perform Full Commissioning Via Admin
    [Arguments]    ${path_to_full_scf}
    ...            ${csv_parameter_file}=${EMPTY}
    SCFC Migrate with SuTool to eNB Version    path_to_full_scf=${path_to_full_scf}
    Copy File    ${path_to_full_scf}
    ...          ${OUT_TEST_LOGS_DIR_PATH}/SCFC_${TEST_NAME}_after_migration.xml
    Perform Full Commissioning Via Admin    path_to_full_scf=${path_to_full_scf}

Perform Full Commissioning Via Admin
    [Arguments]    ${path_to_full_scf}
    ...            ${bts_id}=${OUT_ENB_ID}
    ...            ${skip_parameter_relation_errors}=False
    ...            ${should_activate}=True
    ...            ${timeout}=500
    ...            ${alias}=default
    taf.sbts.oam.coam.admin.Perform Commissioning    bts_id=${bts_id}
    ...                                scf_file=${path_to_full_scf}
    ...                                skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                should_activate=${should_activate}
    ...                                timeout=${timeout}
    ...                                alias=${alias}

Perform Activation NBIoT Commissioning
    [Arguments]    ${path_to_full_scf}=${OUT_SCFC_ACTIVATED_NBIOT}
    [Documentation]    Author:    artur.krolak@nokia.com
    Perform Full Commissioning And Check BTS OnAir    path_to_full_scf=${OUT_SCFC_ACTIVATED_NBIOT}

Automated Site Commissioning
    [Arguments]    ${tc_id}
#    ...            ${path_to_full_scf}=${OUT_SCFC_FILE}
    [Documentation]    Author:    artur.krolak@nokia.com
    ...                In future it could be moved to separate file from keywords.robot.
    ${out_path_to_full_scf}=    Set SCFC Variable    tc_id=${tc_id}
    Perform Full Commissioning And Check BTS OnAir    path_to_full_scf=${out_path_to_full_scf}
    SCFC Get Cells and RMOD Lists From ENB   postfix=SCFC_${tc_id}

Perform Site Commissioning And Revert To Default Configuration
    [Arguments]    ${tc_id}
#    ...            ${path_to_full_scf}=${OUT_SCFC_FILE}
    Automated Site Commissioning    tc_id=${tc_id}
#    ...                             path_to_full_scf=${path_to_full_scf}
    Infomodel Wait Until All Cells OnAir  ${OUT_LEGACY_LTE_LNCELL_LIST}
    SCFC Load Default Configuration On Site
    Infomodel Wait Until All Cells OnAir  ${OUT_LEGACY_LTE_LNCELL_LIST}

Block Cell And Check If Blocked
    [Arguments]    ${lncel_id}
    Block    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${enb_id}/LNCEL_R-${lncel_id}
    Assert    LNCEL    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${enb_id}/LNCEL_R-${lncel_id}    blockingState=Blocked

Unblock Cell And Check If Unblocked
    [Arguments]    ${lncel_id}
    Unblock    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${enb_id}/LNCEL_R-${lncel_id}
    Assert    LNCEL    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${enb_id}/LNCEL_R-${lncel_id}    blockingState=Unblocked

Block All Cells And Check If Are Blocked
    [Documentation]    Author:       artur.krolak@nokia.com
    FOR    ${lncel_id}    IN     @{OUT_LEGACY_LTE_LNCELL_LIST}
        Block Cell And Check If Blocked    lncel_id=${lncel_id}
    END
Unblock All Cells And Check If Are Unblocked
    [Documentation]    Author:       artur.krolak@nokia.com
    FOR    ${lncel_id}    IN     @{OUT_LEGACY_LTE_LNCELL_LIST}
        Unblock Cell And Check If Unblocked    lncel_id=${lncel_id}
    END
Block RMod And Check If Blocked
    [Arguments]    ${rmod_id}
    Block    ${rmod_id}
    Assert    RMOD    ${rmod_id}    blockingState=Blocked

Unblock RMod And Check If Unblocked
    [Arguments]    ${rmod_id}
    Unblock    ${rmod_id}
    Assert    RMOD    ${rmod_id}    blockingState=Unblocked

Block All RMods And Chceck If Are Blocked
#TODO: Check If Setup Admin Required, Setups In Test Setup
    [Documentation]    Author:    artur.krolak@nokia.com
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    taf.sbts.oam.coam.admin.Setup Admin     bts_port=3600
    @{rmod_id_list}=    Get Ids For All    RMOD
    FOR    ${rmod_id}    IN    @{rmod_id_list}
        Block RMod And Check If Blocked    rmod_id=${rmod_id}
    END
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Run Keyword    taf.sbts.oam.coam.admin.Teardown Admin

Unblock All RMods And Check If Are Unblocked
#TODO: Check If Setup Admin Required, Setups In Test Setup
    [Documentation]    Author:    artur.krolak@nokia.com
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    taf.sbts.oam.coam.admin.Setup Admin     bts_port=3600
    @{rmod_id_list}=    Get Ids For All    RMOD
    FOR    ${rmod_id}    IN    @{rmod_id_list}
         Unblock RMod And Check If Unblocked    rmod_id=${rmod_id}
    END
    Run Keyword If    "${ENB_ACTIONS_TRIGGER}" == "BTSSM"    Run Keyword    taf.sbts.oam.coam.admin.Teardown Admin

Prepare Delta Commissioning File
    [Arguments]    ${input_delta_file_path}
    ...            ${output_delta_file_path}
    SCFC Get Cells And RMOD Lists From ENB
    Run Keyword If      "${OUT_INBAND_LCR_ID_LIST}" != "[]"        Set Test Variable    ${iot_cell_ids}    ${OUT_INBAND_LCR_ID_LIST}
    ...   ELSE IF       "${OUT_STANDALONE_LCR_ID_LIST}" != "[]"    Set Test Variable    ${iot_cell_ids}    ${OUT_STANDALONE_LCR_ID_LIST}
    ...   ELSE IF       "${OUT_GUARDBAND_LCR_ID_LIST}" != "[]"     Set Test Variable    ${iot_cell_ids}    ${OUT_GUARDBAND_LCR_ID_LIST}
    ${delta_file}=    OperatingSystem.Get File    path=${input_delta_file_path}
    ${delta_file}=    Replace String              string=${delta_file}
    ...                                           search_for={OUT_ENB_ID}
    ...                                           replace_with=${OUT_ENB_ID}
    FOR    ${LEGACY_LCR_ID}     IN    @{OUT_LEGACY_LCR_ID_LIST}
       ${delta_file}=       Replace String    string=${delta_file}
     	...                                        search_for={LEGACY_CELL_${LEGACY_LCR_ID}}
    	...                                        replace_with=${LEGACY_LCR_ID}
    END
    FOR    ${iot_cell_id}     IN    @{iot_cell_ids}
       ${lncell_index}     Evaluate          @{iot_cell_ids}.index(str(${iot_cell_id}))+1
       ${delta_file}=      Replace String    string=${delta_file}
    	...                                       search_for={IOT_CELL_${lncell_index}}
    	...                                       replace_with=${iot_cell_id}
    END
    Create File    path=${output_delta_file_path}
    ...            content=${delta_file}

Check Parameter In Scf File And Compare
    [Arguments]    ${scfc_file_path}
    ...            ${distname}
    ...            ${parameter}
    ...            ${value_to_compare}
    ${out_parameter_value}=  Evaluate Xpath  ${scfc_file_path}
    ...                      string(.//managedObject[contains(@distName,"${distname}")]//p[@name="${parameter}"])
    Should Be Equal    ${out_parameter_value}    ${value_to_compare}

Set Random Parameter Value In Range And Step In Delta File
    [Arguments]    ${delta_dir}
    ...            ${parameter}
    ...            ${max_value}
    ...            ${min_value}
    ...            ${step}
    ${parameter_value}=    Get Random Value In Range And Step   ${max_value}    ${min_value}    ${step}
    ${delta_file}=         OperatingSystem.Get File             path=${delta_dir}
    ${delta_file}=         Replace String                       string=${delta_file}
    ...                                                         search_for=${parameter}
    ...                                                         replace_with=${parameter_value}
    Create File                                                 path=${delta_dir}
    ...                                                         content=${delta_file}
    [Return]    ${parameter_value}

Parameters Should Match
    [Arguments]    ${parameter_1}    ${parameter_2}
    Should Be Equal As Strings    ${parameter_1}    ${parameter_2}

Admin Delta Change Administrative State Of MME
    [Arguments]    ${delta_file}    ${lnmme0_stat}    ${lnmme1_stat}
    Perform Delta Recommissioning    ${delta_file}

Set ENB_ACTIONS_TRIGGER Depending On SW Build
    [Documentation]            Author:    dawid.wojciechowski@nokia.com
    ${ENB_ACTIONS_TRIGGER}=    Evaluate    "BTSSM" if "${sw_release}".startswith("FL18A") else "ADMIN"
    Set Suite Variable     ${ENB_ACTIONS_TRIGGER}

Get Attenuation Value In Range Of Rsrp And Set Test Variable
    [Arguments]     ${current_att}    ${current_rsrp}    ${min_rsrp}    ${max_rsrp}
    ${requested_att}=    Get Attenuation Value In Range Of Rsrp      current_att=${current_att}
    ...                                                              current_rsrp=${current_rsrp}
    ...                                                              min_rsrp=${min_rsrp}
    ...                                                              max_rsrp=${max_rsrp}
    Set Test Variable    ${requested_att}    ${requested_att}

Check If First BTS is OnAir And Turn Off Second One
    Run  ute_tl power_off rf_2
    Run  ute_tl power_on rf_1
    Infomodel Connect Im                alias=suite_precondition
    Infomodel BTS Should Reach OnAir    alias=suite_precondition

Turn On Second BTS
    Run  ute_tl power_on rf_2
    ute_admin_infomodel.Teardown infomodel    alias=suite_precondition

Get All LNCELL List
    taf.sbts.oam.coam.admin.Setup admin             bts_host=${ENB_IP}             bts_port=${ADMIN_PORT}    use_ssl=True    alias=lncel
    @{cell_ids}=            Get Ids For All                LNCEL                     alias=lncel
    taf.sbts.oam.coam.admin.Teardown Admin          alias=lncel
    FOR    ${cell_id}   IN    @{cell_ids}
        ${lncel_id}=       Remove String Using Regexp     ${cell_id}   .*LNCEL_.-
       log                 ${lncel_id}                    console=True
       Append To List      ${OUT_LNCEL_LIST}          ${lncel_id}
       log                 list of lncels:@{OUT_LNCEL_LIST}              console=True
    END
    [Return]    @{OUT_LNCEL_LIST}

Ping Host From Server
    [Arguments]    ${host_ip}
    ...            ${counter}=1
    ...            ${payload}=${IPERF_DEFAULT_PAYLOAD}
    ...            ${timeout}=240
    ...            ${server_ip}=${IPERF_WROC_SERVER}
    ...            ${server_user}=${IPERF_WROC_LOGIN}
    ...            ${server_password}=${IPERF_WROC_PASSWOR}
    ${out_ping_result}=    Run
    ...    sshpass -p ${server_password} ssh ${server_user}@${server_ip} 'hostname; ping -c ${counter} -s ${payload} -w ${timeout} ${host_ip}'

Ping Host From Server In Background
    [Arguments]    ${host_ip}
    ...            ${counter}=1
    ...            ${payload}=${IPERF_DEFAULT_PAYLOAD}
    ...            ${timeout}=240
    ...            ${server_ip}=${IPERF_WROC_SERVER}
    ...            ${server_user}=${IPERF_WROC_LOGIN}
    ...            ${server_password}=${IPERF_WROC_PASSWOR}
    ...            ${alias}=proc1
    ${out_ping_process}=    Start Process
    ...    sshpass -p ${server_password} ssh ${server_user}@${server_ip} 'hostname; ping -w ${timeout} -c ${counter} -s ${payload} ${host_ip}'
    ...                     shell=True
    ...                     alias=${alias}
    [Return]    ${out_ping_process}

Wait For Background Process End
    [Arguments]    ${handle}
    ...            ${timeout}=60
    FOR    ${out_index}    IN RANGE    0    ${timeout}
        ${out_result}=    Is Process Running    handle=${handle}
        Exit For Loop If    '${out_result}'=='False'
        Sleep    1s
    END
Wait For Background Process End And Get Its Output
    [Arguments]    ${handle}
    ...            ${timeout}=60
    ...            ${stdout_path}=${OUT_TEST_LOGS_DIR_PATH}proc_stdout.txt
    ...            ${stderr_path}=${OUT_TEST_LOGS_DIR_PATH}proc_stderr.txt
    Wait For Background Process End    handle=${handle}
    ...                                timeout=${timeout}
    Terminate Process    handle=${handle}
    ${out_process_stdout}    ${out_process_stderr}    ${out_stdout_path}    ${out_stderr_path}=
    ...                      Get Process Result    handle=${handle}
    ...                                            stdout=${stdout_path}
    ...                                            stderr=${stderr_path}
    ...                                            stdout_path=${stdout_path}
    ...                                            stderr_path=${stderr_path}
    [Return]    ${out_process_stdout}

Wait For Background Process End And Verify Its Output
    [Arguments]    ${handle}
    ...            ${pattern}=0% packet loss
    ...            ${timeout}=60
    ...            ${stdout_path}=${OUT_TEST_LOGS_DIR_PATH}proc_stdout.txt
    ...            ${stderr_path}=${OUT_TEST_LOGS_DIR_PATH}proc_stderr.txt
    ${out_process_stdout}=    Wait For Background Process End And Get Its Output    handle=${handle}
    ...                                                                             timeout=${timeout}
    ...                                                                             stdout_path=${stdout_path}
    ...                                                                             stderr_path=${stderr_path}
    Should Contain    ${out_process_stdout}    ${pattern}
    ...               msg=Process output does not contain expected pattern: ${pattern}!

Wait For Background Ping End And Verify Packets Loss
    [Arguments]    ${handle}
    ...            ${packet_loss}=99
    ...            ${timeout}=60
    ...            ${stdout_path}=${OUT_TEST_LOGS_DIR_PATH}proc_stdout.txt
    ...            ${stderr_path}=${OUT_TEST_LOGS_DIR_PATH}proc_stderr.txt
    ${out_process_output}=    Wait For Background Process End And Get Its Output    handle=${handle}
    ...                                                                             timeout=${timeout}
    ...                                                                             stdout_path=${stdout_path}
    ...                                                                             stderr_path=${stderr_path}
    ${out_packet_loss}=    Run    echo "${out_process_output}" | grep "packet loss" | awk -F', ' '{print $3}' | sed 's/[^0-9]*//g'
    Should Be True    ${packet_loss}>=${out_packet_loss}    msg=${out_packet_loss}% is higher than expected ${packet_loss}%!

Syslog BLER Counting DL
    [Arguments]    ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ...            ${expected_BLER}=0.01
    ${out_ack_dl}=    Run
    ...    grep UeDlCR ${OUT_TEST_LOGS_DIR_PATH}${syslog_file}| grep "harqAckResult[:[:space:]]2 harqAckBits[:[:space:]]1," | wc -l
    ${out_nack_dl}=    Run
    ...    grep UeDlCR ${OUT_TEST_LOGS_DIR_PATH}${syslog_file}| grep "harqAckResult[:[:space:]]2 harqAckBits[:[:space:]]2," | wc -l
    ${out_ack_dl_17}=    Run
    ...    grep UeDlCR ${OUT_TEST_LOGS_DIR_PATH}${syslog_file}| grep "harqAckResult[:[:space:]]2 harqAckBits[:[:space:]]17," | wc -l
    ${out_nack_dl_16}=    Run
    ...    grep UeDlCR ${OUT_TEST_LOGS_DIR_PATH}${syslog_file}| grep "harqAckResult[:[:space:]]2 harqAckBits[:[:space:]]16," | wc -l
    ${out_dtx_dl}=    Run    grep UeDlCR ${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | grep "harqAckResult[:[:space:]]1" | wc -l
    ${out_all_nacks}=    Evaluate    ${out_nack_dl}+${out_nack_dl_16}+${out_dtx_dl}
    ${out_all_nacks_acks}=    Evaluate    ${out_all_nacks}+${out_ack_dl}+${out_ack_dl_17}
    ${out_bler_dl}=    Evaluate    float(${out_all_nacks})/float(${out_all_nacks_acks})
    Should Be True    ${out_bler_dl} <= ${expected_BLER}
    ...               msg=BLER is equal to ${out_bler_dl}. It is higher than expected BLER value ${expected_BLER}!

Syslog BLER Counting UL
    [Arguments]    ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ...            ${expected_BLER}=0.01
    ${out_ack_ul}=    Run    grep UeUlCR ${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | grep crcResult[:[:space:]]1 | wc -l
    ${out_nack_ul}=    Run    grep UeUlCR ${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | grep crcResult[:[:space:]]0 | wc -l
    ${out_nacks_acks}=    Evaluate    ${out_nack_ul}+${out_ack_ul}
    ${out_bler_ul}=    Evaluate    float(${out_nack_ul})/float(${out_nacks_acks})
    Should Be True    ${out_bler_ul} <= ${expected_BLER}
    ...               msg=BLER is equal to ${out_bler_ul}. It is higher than expected BLER value ${expected_BLER}!

Syslog Take Parameter Value From Message
    [Arguments]    ${message_pattern}=MACPS_DlCoreCell VIP/macps.nb.sch.NbPdschSender
    ...            ${parameter}=carrierIndex
    ...            ${expected_value}=0
    ...            ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ${out_preview}=    Run    egrep "${message_pattern}" ${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | grep "${parameter}"
    Log    ${out_preview}
#    ${out_result}=    Run    egrep "${message_pattern}" ${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | grep "${parameter} = ${expected_value}"
    ${out_result}=    Run    egrep "${message_pattern}"	${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | sed -e s'/\\,/\\n/g' | grep -o "${parameter}".* |
    ...	awk -F'[=,:]' '{print $2}' | sed -e s'/ //g' |uniq -c | sort -n -r | awk 'NR == 1 {print $2}'
    Should Be Equal As Integers    first=${expected_value}
    ...                            second=${out_result}
    ...                            msg= Expected parameter value ${expected_value} is not equal to found result which is equal to ${out_result}!

Syslog Check Parameter Value Exists In Message
    [Arguments]    ${message_pattern}=MACPS_DlCoreCell VIP/macps.nb.sch.NbPdschSender
    ...            ${parameter}=carrierIndex
    ...            ${expected_value}=0
    ...            ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ${out_preview}=    Run    egrep "${message_pattern}" ${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | grep "${parameter}"
    Log    ${out_preview}
    ${out_result}=    Run    egrep "${message_pattern}" ${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | sed -e s'/\,/\n/g' | grep -E
    ...	"${parameter}[=:]${expected_value}" | wc -l
    Should Be True    ${out_result} >= ${0}

Syslog Take Parameter Value From Message Containing Given Parameter
    [Arguments]    ${message_pattern}=MACPS_DlCoreCell VIP/macps.nb.sch.NbPdschSender
    ...            ${given_parameter}=crnti
    ...            ${given_parameter_value}=0
    ...            ${parameter}=carrierIndex
    ...            ${expected_value}=0
    ...            ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ${out_preview}=    Run    egrep "${message_pattern}" ${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | grep -e
    ...${given_parameter}*.*${given_parameter_value}, | grep "${parameter}"
    Log    ${out_preview}
    ${out_result}=    Run    egrep "${message_pattern}" ${OUT_TEST_LOGS_DIR_PATH}${syslog_file} | grep -e
    ...${given_parameter}*.*${given_parameter_value}, | sed -e s'/\\,/\\n/g' | grep -o
    ..."${parameter}".* | awk -F'[=,:]' '{print $2}' | sed -e s'/ //g' |uniq -c | sort -n -r | awk '{print $2}'
    @{out_result}=    Convert To List    ${out_result}
    Remove Values From List    ${out_result}    \n
    FOR    ${out_index}    IN    @{out_result}
        ${out_found_value}=    Run Keyword If    ${out_index}==${expected_value}    Set Variable    ${out_index}
        Run Keyword If    ${out_index}==${expected_value}    Exit For Loop
    END
    Should Be Equal    first=${expected_value}
    ...                second=${out_found_value}
    ...                msg= Expected parameter value ${expected_value} is not equal to found result which is equal to ${out_result}!
    [Return]    ${out_found_value}

Syslog Expect Parameter Value In Messages Containing Given Parameter With Values
    [Documentation]      ${given_parameter_values} must be a list
    [Arguments]    ${message_pattern}=MACPS_DlCoreCell VIP/macps.nb.sch.NbPdschSender
    ...            ${given_parameter}=crnti
    ...            ${given_parameter_values}=@{EMPTY}
    ...            ${parameter}=carrierIndex
    ...            ${expected_value}=0
    ...            ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    FOR    ${out_index}    IN    @{given_parameter_values}
        ${out_found_value}=    Run Keyword And Ignore Error
        ...    Syslog Take Parameter Value From Message Containing Given Parameter    message_pattern=${message_pattern}
        ...    parameter=${parameter}
        ...    expected_value=${expected_value}
        ...    given_parameter=${given_parameter}
        ...    given_parameter_value=${out_index}
        Run Keyword If    '${out_found_value[0]}'!='FAIL'    Exit For Loop
    END
    Should Be Equal    first=${expected_value}
    ...                second=${out_found_value[1]}
    ...                msg= Expected parameter value ${expected_value} is not equal to found result which is equal to ${out_found_value}!

Syslog Most Popular Crnti
    [Arguments]    ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ...            ${sw_version}=${TRUNK_PREFIX}
    ${out_crnti}=    Run Keyword If    '${sw_version}'=='${TRUNK_PREFIX}'    Run
    ...    grep "crcResult:1" ${syslog_path}/${syslog_file} | grep -o crnti.* | awk -F[:=,]
    ...	'{print $2}'| sort | uniq -c | sort -n -r | awk 'NR == 1 {print $2}'
    ...              ELSE IF    '${sw_version}'!='${TRUNK_PREFIX}'
    ...    Run    grep "crcResult:1" ${syslog_path}/${syslog_file} | grep -o crnti.* | awk -F[:=,]
    ...	'{print $2}'| sort | uniq -c | sort -n -r | awk 'NR == 1 {print $2}'
    Set Test Variable    ${OUT_TEST_CRNTI}    ${out_crnti}
    [Return]    ${out_crnti}

Syslog Create Crnti List
    [Arguments]    ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ...            ${sw_version}=${TRUNK_PREFIX}
    ${out_crntis}=    Run Keyword If    '${sw_version}'=='${TRUNK_PREFIX}'
    ...    Run    grep "crcResult:1" ${syslog_path}/${syslog_file} | grep -o crnti.* | awk -F[:=,] '{print $2}'| sort | uniq -c | sort -n -r | wc -l
    ...    ELSE IF    '${sw_version}'!='${TRUNK_PREFIX}'
    ...    Run    grep "crcResult:1" ${syslog_path}/${syslog_file} | grep -o crnti.* | awk -F[:=,] '{print $2}'| sort | uniq -c | sort -n -r | wc -l
    @{out_crntis_list}=    Create List
    ${out_crntis}=    Evaluate    ${out_crntis}+${1}
    FOR    ${out_index}    IN RANGE    1    ${out_crntis}
        ${out_crnti}=    Run Keyword If    '${sw_version}'=='${TRUNK_PREFIX}'
        ...    Run    grep "crcResult:1" ${syslog_path}/${syslog_file} | grep -o crnti.* | awk -F[:=,]
        ...	'{print $2}'| sort | uniq -c | sort -n -r | awk 'NR == ${out_index} {print $2}'
        ...    ELSE IF    '${sw_version}'!='${TRUNK_PREFIX}'
        ...    Run    grep "crcResult:1" ${syslog_path}/${syslog_file} | grep -o crnti.* | awk -F[:=,]
        ...	'{print $2}'| sort | uniq -c | sort -n -r | awk 'NR == ${out_index} {print $2}'
        Append To List    ${out_crntis_list}    ${out_crnti}
    END
    [Return]    ${out_crntis_list}

Syslog Count And Verify Max TBS
    [Documentation]  For DL msg use: macps.nb.sch.NbPuschSender|sendPusch():
    ...              For UL msg use: macps.nb.sch.NbPduMuxSender|sendPduMuxCombinedReq():
    ...              In case of empty output, check if the above messages are not changed
    [Arguments]    ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ...            ${direction}=DL
    ...            ${expected_max_tbs}=${SYSLOG_MAX_TBS_DL}
    ...            ${sw_version}=${TRUNK_PREFIX}
    ${out_uplink_msg}=    Set Variable    macps.nb.sch.NbPuschSender|sendPusch():
    ${out_downlink_msg}=    Set Variable    macps.nb.sch.NbPduMuxSender|sendPduMuxCombinedReq():
#    ${out_crnti}=    Syslog Most Popular Crnti    syslog_path=${syslog_path}
#    ...                                           syslog_file=${syslog_file}
#    ...                                           sw_version=${sw_version}
    ${out_crntis_list}=    Syslog Create Crnti List    syslog_path=${syslog_path}
    ...                                                syslog_file=${syslog_file}
    ...                                                sw_version=${sw_version}
    FOR    ${out_crnti}    IN    @{out_crntis_list}
        ${out_tbs_max_dl}=    Run Keyword If    '${direction}'=='DL' and '${sw_version}'=='${TRUNK_PREFIX}'    Run
        ...    egrep "${out_downlink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | grep -v "tbSize:0" | grep -o tbSize.* | awk -F[:=,]
        ...	'{print $2}' | sort | uniq -c | sort -n -r | awk '{print $2}' | tr '\n' ',' | sed 's/,$//g'
        ...                      ELSE IF   '${direction}'=='DL' and '${sw_version}'!='${TRUNK_PREFIX}'    Run
        ...    egrep "${out_downlink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | grep -v "tbSize:0" | grep -o tbSize.* | awk -F[:=,]
        ...	'{print $2}' | sort | uniq -c | sort -n -r | awk '{print $2}' | tr '\n' ',' | sed 's/,$//g'
        ${out_tbs_max_ul}=    Run Keyword If    '${direction}'=='UL' and '${sw_version}'=='${TRUNK_PREFIX}'    Run
        ...    egrep "${out_uplink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | grep -v "tbSize:0" | grep -o tbSize.* | awk -F[:=,]
        ...	'{print $2}' | sort | uniq -c | sort -n -r | awk '{print $2}' | tr '\n' ',' | sed 's/,$//g'
        ...                      ELSE IF   '${direction}'=='UL' and '${sw_version}'!='${TRUNK_PREFIX}'    Run
        ...    egrep "${out_uplink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | grep -v "tbSize:0" | grep -o tbSize.* | awk -F[:=,]
        ...	'{print $2}' | sort | uniq -c | sort -n -r | awk '{print $2}' | tr '\n' ',' | sed 's/,$//g'
        ${out_tbs_max}=    Set Variable If      '${direction}'=='DL'     ${out_tbs_max_dl}    ${out_tbs_max_ul}
        @{out_tbs_max_list}=    Split String    string=${out_tbs_max}
        ...                                     separator=,
        ${out_tbs}=    Syslog Check TBS Is Expected    tbses_list=${out_tbs_max_list}
        ...                                            expected_max_tbs=${expected_max_tbs}
        ...                                            direction=${direction}
        Run Keyword If    '${out_tbs}'=='${expected_max_tbs}'    Exit For Loop
    END
    Should Be True    ${out_tbs} == ${expected_max_tbs}
    ...               msg=None of tbses is equal to expected max tbs value ${expected_max_tbs}!

Syslog Check TBS Is Expected
    [Arguments]    ${tbses_list}
    ...            ${expected_max_tbs}
    ...            ${direction}=DL
    @{out_tbses_list}=    Create List
    FOR    ${out_index}    IN    @{tbses_list}
        ${out_tbs_dl_trunk}=    Run Keyword If  '${direction}'=='DL'    Evaluate    ${out_index}*8
        ${out_tbs}=    Set Variable If    '${direction}'=='DL'    ${out_tbs_dl_trunk}    ${out_index}
        Append To List    ${out_tbses_list}    ${out_tbs}
        Run Keyword If    '${out_tbs}'=='${expected_max_tbs}'    Exit For Loop
    END
    [Return]    ${out_tbs}

Syslog Count And Verify Average TBS
    [Documentation]  For DL msg use: macps.nb.sch.NbPuschSender|sendPusch():
    ...              For UL msg use: macps.nb.sch.NbPduMuxSender|sendPduMuxCombinedReq():
    ...              In case of empty output, check if the above messages are not changed
    [Arguments]    ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ...            ${direction}=DL
    ...            ${expected_avg_tbs}=${SYSLOG_AVG_TBS_DL}
    ...            ${sw_version}=${TRUNK_PREFIX}
    ${out_uplink_msg}=    Set Variable    macps.nb.sch.NbPuschSender|sendPusch():
    ${out_downlink_msg}=    Set Variable    macps.nb.sch.NbPduMuxSender|sendPduMuxCombinedReq():
    ${out_crnti}=    Syslog Most Popular Crnti    syslog_path=${syslog_path}
    ...                                           syslog_file=${syslog_file}
    ...                                           sw_version=${sw_version}
    ${out_tbs_sum}=    Run Keyword If    '${direction}'=='DL' and '${sw_version}'=='${TRUNK_PREFIX}'
    ...    Run    egrep "${out_downlink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | awk -F, '{sum+=$21} END {print sum}'
    ...                ELSE IF    '${direction}'=='UL' and '${sw_version}'=='${TRUNK_PREFIX}'
    ...    Run    egrep "${out_uplink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | awk -F, '{sum+=$21} END {print sum}'
    ...                ELSE IF    '${direction}'=='DL' and '${sw_version}'!='${TRUNK_PREFIX}'
    ...    Run
	...    egrep "${out_downlink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | grep -v "tbSize:0" | awk -F, '{sum+=$28} END {print sum}'
    ...                ELSE IF    '${direction}'=='UL' and '${sw_version}'!='${TRUNK_PREFIX}'
    ...    Run
    ...    egrep "${out_uplink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti}| grep -v "tbSize:0" | awk -F, '{sum+=$28} END {print sum}'
    ${out_tbs_count}=    Run Keyword If    '${direction}'=='DL' and '${sw_version}'=='${TRUNK_PREFIX}'
    ...    Run    egrep "${out_downlink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | wc -l
    ...                ELSE IF    '${direction}'=='UL' and '${sw_version}'=='${TRUNK_PREFIX}'
    ...    Run    egrep "${out_uplink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | wc -l
    ...                ELSE IF    '${direction}'=='DL' and '${sw_version}'!='${TRUNK_PREFIX}'
    ...    Run    egrep "${out_downlink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | wc -l
    ...                ELSE IF    '${direction}'=='UL' and '${sw_version}'!='${TRUNK_PREFIX}'
    ...    Run    egrep "${out_uplink_msg}" ${syslog_path}/${syslog_file} | grep ${out_crnti} | wc -l
    ${out_tbs_avg_bajts}=    Evaluate    ${out_tbs_sum}/${out_tbs_count}
    ${out_tbs_avg_bits}=    Evaluate    ${out_tbs_avg_bajts}*8
    Should Be True    ${out_tbs_avg_bits} >= ${expected_avg_tbs}
    ...               msg=Average TBS for ${direction} is equal to ${out_tbs_avg_bits}. It is lower than expected value ${expected_avg_tbs}!
    [Return]    ${out_tbs_avg_bits}


Syslog Check For Alarm Detection
    [Arguments]    ${fault_id}=6202
    ...            ${syslog_path}=${OUT_TEST_LOGS_DIR_PATH}
    ...            ${syslog_file}=${SYSLOG_FILENAME}
    ${out_result}=    Run    egrep "Detector ${fault_id}" ${OUT_TEST_LOGS_DIR_PATH}${syslog_file}
    Should Not Be Empty    ${out_result}    msg=Expected fault ${fault_id} has not been detected in syslog!


Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
    [Return]   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

 

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${tl_name}

 

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

 

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

counter_create
    [Documentation]    
    ...    Author: arunkumar.a@noika.com, MN_RAN_Pz_BLR_SG02
    ...    counter_Create and counter_analyser is for validating PM counters and 
    ...    Bench marking the values. for more details about PM counters refer this link.  
    ...    link: https://nokia.sharepoint.com/sites/ran-wow/WoW_Wiki/RRM%20Test%20Strategy.aspx#2.17______Counter_Testing_Scope_and_Strategy
    ...    CNI-89399 - Counter values Validation and Benchmarking for RRM Features

    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    PM.create PM collector
    ...  name=LTE_NB_IoT_pm_counters
    ...  webservice=${webservice}
    ...  for_last=2 hour    
    ...  intervals=15
    PM.setup_collectors           names=LTE_NB_IoT_pm_counters
    PM.collect_collectors         names=LTE_NB_IoT_pm_counters     target_dir=/home/ute/results/LTE_NB_IoT_pm_counters
    PM.teardown_collectors        names=LTE_NB_IoT_pm_counters

counter_analyser
    [Documentation]    
    ...    Author: arunkumar.a@noika.com, MN_RAN_Pz_BLR_SG02
    ...    counter_Create and counter_analyser is for validating PM counters and 
    ...    Bench marking the values. for more details about PM counters refer this link.  
    ...    link: https://nokia.sharepoint.com/sites/ran-wow/WoW_Wiki/RRM%20Test%20Strategy.aspx#2.17______Counter_Testing_Scope_and_Strategy
    ...    CNI-89399 - Counter values Validation and Benchmarking for RRM Features

  ${pi_list}=  Create List
  ...  M8201C19
  ...  M8066C63
  ...  M8201C20
  ...  M8066C29
  ...  M8066C30
  ...  M8066C25
  ...  M8204C0

  ${pi_dict}=  get_pi_value
  ...  pi_list=${pi_list}
  ...  pi_dir=/home/ute/results/LTE_NB_IoT_pm_counters
  ...  pi_file_pattern=PM*
  Log  ${pi_dict}
