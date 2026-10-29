*** Settings ***

Documentation    :copyright: Nokia
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
    [Documentation]    If need to update iphy.xml or Airphone.xml or wts files or complicated changes,
    ...    please do these job before this keyword.
    Create Test Directory
    Run Keyword If    '${swconfig_ap}'!='${EMPTY}'    Add RD Parameters To Airphone Swconfig File    ${swconfig_ap}
    Run Keyword If    '${swconfig_gnb}'!='${EMPTY}'    Add RD Parameters To GNB Swconfig File    ${swconfig_gnb}
    Run Keyword If    '${scfc}'!='${EMPTY}'    Update Gnb Scfc    ${scfc}
    Run Keyword If    '${swconfig_ap}'!='${EMPTY}' or '${swconfig_gnb}'!='${EMPTY}' or '${scfc}'!='${EMPTY}'
    ...    Reboot TL And Check Configured
    Run Keyword If    '${logs}'!='${EMPTY}'    Start Logs    ${logs}
    Start WTS And Check OnAir
    [Teardown]    Run Keyword And Ignore Error    Run Keyword If    '${logs}'!='${EMPTY}'    Stop Logs    ${logs}

Multi Cases Test Teardown
    Run Keyword And Ignore Error    Run Keyword If Test Failed    Log    Please collect sosreport...
    Run Keyword And Ignore Error    Show Relation Errors If Exist
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    cmd=reset    pass_regexp=CHANGE STATE: INIT
    Run Keyword And Ignore Error    ute_wtssim.Teardown All Aliases For Edaemon
    Run Keyword And Ignore Error    ute_wtssim.Teardown All Aliases For Egate
    Run Keyword And Ignore Error    Restore All Gnb And AP Configurations

Start WTS And Check OnAir
    Start UTE WTS    # This step already includes kill egate and edaemon
    Run Keyword If    '${GNBCUTYPE}'=='NSA'    Setup X2 Connection
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Verify Cell Setup

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
    Get Testline Name
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
    coam.Setup Admin    alias=backup
    coam.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${DEFAULT_SCFC}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    ...    alias=backup
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown    alias=backup

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
    Suite Setup Update GNB    log=none
    Suite Setup Copy WTS Config Files From QT
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

Common Test Setup 2
    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}

Common Test Teardown 2
    [Arguments]    ${mode}=none
    Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
    Save Egate Log    log_path=${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    cp -r ${OUTPUT_DIR}/bip_attach/ ${TEST_LOG_DIRECTORY}
    Get Current Testline Config Files    log_path=${TEST_LOG_DIRECTORY}
    Run Keyword If    "${mode}"=="none"    Collect GNB SnapShot Via AaShell    log_dir=${TEST_LOG_DIRECTORY}
    Run Keyword If    "${mode}"=="none"    Collect UTE SosReport    log_dir=${TEST_LOG_DIRECTORY}
    Clean Edaemon And Egate
    Set Suite Variable    ${CUDU_L2}    /home/ute/robotws5g/testsuite/migration/Bangalore/RRM/5GET_BLR/CB007859_ET/resources/common
    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${TEST_LOG_DIRECTORY}
    ...    ${CUDU_L2}/filter_msg.txt    ${OUTPUT_DIR}/output_log.txt

Common Suite Teardown 2
    Get Current Testline Config Files    log_path=${SUITE_LOG_DIRECTORY}
