*** Settings ***
Documentation      common keyword

*** Keywords ***
Multi Cases Suite Setup
    [Arguments]    ${local_wts_dir}=${EMPTY}
    Clean Up Env
    Create Suite Directory
    Get All Gnb And AP Software Informations
    Get WTS Files From QT Or Local    ${local_wts_dir}
    Backup All Configuration Files
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

Multi Cases Suite Teardown
    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Log    Please collect sosreport...
    Run Keyword And Ignore Error    Teardown All Connections  # ssh connections
    Run Keyword And Ignore Error    Stop Edaemon Egate

Multi Cases Test Setup
    [Arguments]    ${swconfig_ap}=${EMPTY}    ${swconfig_gnb}=${EMPTY}    ${scfc}=${EMPTY}    ${logs}=${EMPTY}
    ...    ${gnb_num}=1    ${uec_num}=1
    [Documentation]    If need to update iphy.xml or Airphone.xml or wts files or complicated changes,
    ...    please do these job before this keyword.
    Create Test Directory
    Run Keyword If    '${swconfig_ap}'!='${EMPTY}'    Add RD Parameters To Airphone Swconfig File    ${swconfig_ap}
    Run Keyword If    '${swconfig_gnb}'!='${EMPTY}'    Add RD Parameters To GNB Swconfig File    ${swconfig_gnb}
    Run Keyword If    '${scfc}'!='${EMPTY}'    Update Gnb Scfc    ${scfc}
    Run Keyword If    '${swconfig_ap}'!='${EMPTY}' or '${swconfig_gnb}'!='${EMPTY}' or '${scfc}'!='${EMPTY}'
    ...    Reboot TL And Check Configured
    Run Keyword If    '${logs}'!='${EMPTY}'    Start Logs    ${logs}
    Start WTS And Check OnAir    ${gnb_num}    ${uec_num}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword If    '${logs}'!='${EMPTY}'    Stop Logs    ${logs}

Multi Cases Test Teardown
    Run Keyword And Ignore Error    Run Keyword If Test Failed    Log    Please collect sosreport...
    Run Keyword And Ignore Error    Show Relation Errors If Exist
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    cmd=reset    pass_regexp=CHANGE STATE: INIT
    Run Keyword And Ignore Error    ute_wtssim.Teardown All Aliases For Edaemon
    Run Keyword And Ignore Error    ute_wtssim.Teardown All Aliases For Egate
    Run Keyword And Ignore Error    Restore All Gnb And AP Configurations

Start WTS And Check OnAir
    [Arguments]    ${gnb_num}=1    ${uec_num}=1
    Start UTE WTS    # This step already includes kill egate and edaemon
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='SANSA' or '${GNBCUTYPE}'=='SA'    Check All Cells Received SIB2
    ...    ${gnb_num}    ${uec_num}
    Verify Cell Setup
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection

Get All Gnb And AP Software Informations
    Get Testline Type
    Get Software Version
    Get Airphone Software Version
    Get WTS Version
    # Setup Connections
    Set CP Debug Log
    Get Control Board Type
    Get Base Band Board Type
    Get RRU Type
    Get Host Name
    Get Default NRBTS DistName

Get WTS Files From QT Or Local
    [Arguments]    ${local_wts_dir}=${EMPTY}
    Backup Scf    ${SUITE_LOG_DIRECTORY}    before_suite
    Run Keyword If    '${local_wts_dir}'=='${EMPTY}'    Copy WTS Files From QT
    ...    ELSE    Copy WTS Files From Local    ${local_wts_dir}

Copy WTS Files From QT
    [Documentation]    If can rename below keyword or not
    Suite Setup Copy WTS Config Files From QT

Copy WTS Files From Local
    [Arguments]    ${local_wts_dir}
    [Documentation]    If can rename below keyword or not
    Suite Setup Copy WTS Config Files From Local    ${local_wts_dir}

Backup All Configuration Files
    Log    Start to backup all configuration files    level=WARN
    Create Backup Directory
    Backup Gnb Swconfig
    Backup Airphone Swconfig
    Backup Airphone IPHY XML
    Backup WTS Files
    Backup Scfc File
    Log    Done to backup all configuration files    level=WARN

Restore All Gnb And AP Configurations
    Log    Start to restore all configuration files    level=WARN
    Restore Gnb Swconfig
    Restore Airphone Swconfig
    Restore Airphone IPHY XML
    Restore WTS Files
    Restore Scfc File
    Reboot TL And Check Configured  # if not, send scfc in next case will fail due to CPlane is busy
    Log    Done to restore all configuration files    level=WARN

Create Backup Directory
    OperatingSystem.Run    mkdir ${OUTPUT_DIR}/backup
    Set Suite Variable    ${BACKUP_DIR}    ${OUTPUT_DIR}/backup

Backup Scfc File
    Backup Scf    ${BACKUP_DIR}    default
    Set Suite Variable    ${DEFAULT_SCFC}    ${BACKUP_DIR}/SCF_default.xml

Backup Gnb Swconfig
    Get Swconfig File From GNB    ${BACKUP_DIR}
    Set Suite Variable    ${DEFAULT_SWCONFIG_GNB}    ${BACKUP_DIR}/swconfig_gnb.txt

Backup Airphone Swconfig
    Get Swconfig File From Airphone    ${BACKUP_DIR}
    Set Suite Variable    ${DEFAULT_SWCONFIG_AP}    ${BACKUP_DIR}/swconfig_ap.txt

Backup Airphone IPHY XML
    Get IPHY XML From Airphone    ${BACKUP_DIR}
    Set Suite Variable    ${DEFAULT_IPHY_XML}    ${BACKUP_DIR}/iphy.xml

Backup WTS Files
    OperatingSystem.Run    cp ${WTS_DIR}/${WTS_CFG} ${BACKUP_DIR}
    OperatingSystem.Run    cp ${WTS_DIR}/${WTS_AP_XML} ${BACKUP_DIR}
    Set Suite Variable    ${DEFAULT_CFG}    ${BACKUP_DIR}/${WTS_CFG}
    Set Suite Variable    ${DEFAULT_AP_XML}    ${BACKUP_DIR}/${WTS_AP_XML}

Restore Scfc File
    ${bts_id}    Get BTS Id
    COAM.Setup Admin    alias=backup
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${DEFAULT_SCFC}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    ...    alias=backup
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown    alias=backup

Restore Gnb Swconfig
    Send Swconfig File To GNB    ${DEFAULT_SWCONFIG_GNB}

Restore Airphone Swconfig
    Send Swconfig File To Airphone    ${DEFAULT_SWCONFIG_AP}

Restore Airphone IPHY XML
    Send IPHY XML To Airphone    ${DEFAULT_IPHY_XML}

Restore WTS Files
    OperatingSystem.Run    cp ${DEFAULT_CFG} ${WTS_DIR}
    OperatingSystem.Run    cp ${DEFAULT_AP_XML} ${WTS_DIR}

Update Gnb Scfc
    [Arguments]    ${scf_file}
    ${scf_file_type}    Get File Type    ${scf_file}
    Run Keyword If    '${scf_file_type}'=='xml'    Full Commission With SCF File    ${scf_file}
    Run Keyword If    '${scf_file_type}'=='json'    Delta Commission With SCF File    ${scf_file}

Common Suite Setup 2
    Suite Setup Update GNB    log=${False}
    Suite Setup Copy WTS Config Files From QT
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

Common Test Setup 2
    Run Keyword If    "${SUITE_LOG_DIRECTORY}"==""    Create Suite Directory
    Run Keyword If    "${TEST_LOG_DIRECTORY}"==""    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}

Common Test Teardown 2
    [Arguments]    ${snapshot}=${False}    ${egate}=${True}    ${check_tl}=${True}
    Run Keyword If    "${SUITE_LOG_DIRECTORY}"==""    Create Suite Directory
    Run Keyword If    "${TEST_LOG_DIRECTORY}"==""    Create Test Directory
    Run Keyword And Ignore Error    Save Egate Log    log_path=${TEST_LOG_DIRECTORY}
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ram/node_CPRT00/tmp/startup_cp_rt.log* ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    cp -r ${OUTPUT_DIR}/bip_attach/ ${TEST_LOG_DIRECTORY}
    Get Current Testline Config Files    log_path=${TEST_LOG_DIRECTORY}/myconfigs/
    Run Keyword If Test Failed    Collect GNB SnapShot Via AaShell    log_dir=${TEST_LOG_DIRECTORY}
    Run Keyword If Test Failed    Collect UTE SosReport    log_dir=${TEST_LOG_DIRECTORY}
    Run Keyword If    "${egate}"=="${True}"    Clean Edaemon And Egate
    #Run    cp Gnb_syslog.tar.gz ${TEST_LOG_DIRECTORY}
    Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
    Log To Console    snapshot=${snapshot}
    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${TEST_LOG_DIRECTORY}
    ...    ${CURDIR}/filter_msg.txt    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt
    Auto_Analyze_Error    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt
    Run Keyword If    "${check_tl}"=="${True}"    Run Keyword And Ignore Error    Check TL Type And Prepare Configuration
    FOR    ${index}    IN RANGE    1    4
        Log To Console    ===============Excute 'Ask scout to analyze scf' Time: ${index}==============
        ${ret}    Run Keyword And Ignore Error    Ask scout to analyze scf    remove_postfix=${False}
        Run Keyword Unless    '${ret[0]}'=='PASS'    Run Keyword And Ignore Error    Ask scout to analyze scf    remove_postfix=${True}
        Exit For Loop If    '${ret[0]}'=='PASS'
        Sleep    10s     #avoid "admin_cli_status is not running!"
    END

Common Suite Teardown 2
    Run Keyword If    "${SUITE_LOG_DIRECTORY}"==""    Create Suite Directory
    Run Keyword And Ignore Error    Get Alarms
    Run Keyword And Ignore Error    Show Relation Errors If Exist
    Get Current Testline Config Files    log_path=${SUITE_LOG_DIRECTORY}/myconfigs/

Clean Edaemon And Egate
    ute_wtssim.Teardown Edaemon    alias=edaemon
    ute_wtssim.Teardown Egate



Check TL Type And Prepare Configuration
    ${testline_type}=    Get Testline Type
    Log To Console    testline_type=${testline_type}
    ${test_name}=    Set Variable    ${TEST NAME}
    Run Keyword IF   '${testline_type}'=='CLOUD_5G_I_BOO_AP_LOO'    Prepare Configuration For BOO_AP_LOO
    ...    ELSE IF   '${testline_type}'=='CLOUD_5G_I_LO_AP_LO'
    ...    Prepare Configuration For LO_AP_LO

Prepare Configuration For LO_AP_LO
    ${file_list}=    Create List    scfc_aplo.xml    scfc_aplo_01.xml    scfc_aplo_02.xml    scfc_aplo_03.xml    scfc_aplo_04.xml
    ...    scfc_tmo_local.xml
    ${scfc_file}  Evaluate  random.choice(${file_list})  random
    ${file_dict}=    Create Dictionary    scfc_aplo.xml=iphy_aplo.xml    scfc_aplo_01.xml=iphy_aplo_01.xml
    ...     scfc_aplo_02.xml=iphy_aplo_02.xml     scfc_aplo_03.xml=iphy_aplo_03.xml     scfc_aplo_04.xml=iphy_aplo_04.xml
    ...    scfc_tmo_local.xml=iphy_tmo_local.xml
    ${iphy_file}    Get From Dictionary    ${file_dict}    ${scfc_file}
    Modify IPHY File And Send to Airphone    ${CURDIR}/test/config/${iphy_file}
    Full Commission With SCF File    ${CURDIR}/test/config/${scfc_file}
    Sleep    120s    wait testline can reboot stable.
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'=='False'    Reboot TL And Check Configured


Prepare Configuration For BOO_AP_LOO
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    ${grandparent_dir}=    Join Path    ${parent_dir}    ..
    ${file_list}=    Create List    scfc_boo_01.xml    scfc_boo_02.xml    scfc_boo_03.xml    scfc_boo_04.xml    scfc_boo_05.xml    scfc_boo_06.xml
    ${scfc_file}  Evaluate  random.choice(${file_list})  random
    ${file_dict}=    Create Dictionary    scfc_boo_01.xml=iphy_boo_01.xml    scfc_boo_02.xml=iphy_boo_02.xml
    ...     scfc_boo_03.xml=iphy_boo_03.xml     scfc_boo_04.xml=iphy_boo_04.xml     scfc_boo_05.xml=iphy_boo_05.xml
    ...     scfc_boo_06.xml=iphy_boo_06.xml
    ${iphy_file}    Get From Dictionary    ${file_dict}    ${scfc_file}
    Modify IPHY File And Send to Airphone    ${CURDIR}/test/config/${iphy_file}
    Full Commission With SCF File    ${CURDIR}/test/config/${scfc_file}
    Sleep    120s    wait testline can reboot stable.
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'=='False'    Reboot TL And Check Configured
