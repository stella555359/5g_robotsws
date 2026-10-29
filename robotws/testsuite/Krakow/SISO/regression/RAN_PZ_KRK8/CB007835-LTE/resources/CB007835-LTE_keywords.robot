*** Settings ***
Documentation
...   Keywords for test suite for regression testing of feature CB007835-A LTE
...   author: Mateusz Iwankiewicz
...   contact: mateusz.iwankiewicz@nokia.com

Library      String
Library      Process
Library      DateTime
Library      OperatingSystem
Library      taf.rfrl.bts.commissioning     WITH NAME    commissioning
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      CB007835-LTE_keywords.py
Library      taf/rfrl/procedures/resources/python/setups_and_teardowns_keywords.py
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations
...          WITH NAME    gnbcell
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations
...          WITH NAME    gnbru
Library      taf.rfrl.bts.devices.ru.ru_serial_logs_collector.GnbRuSerialLogsCollector
...          WITH NAME    gnb_ru_lmi
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/common/gnb_log.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    variables.py

*** Variables ***
############### OAM and UUF #########################
@{CUSTOMERS_LIST}              TMO US
${QC_DOMAIN}                   MN_RAN
${QC_PROJECT}                  RAN_VRF
${TOPOLOGY}                    CLOUD_5G_CLASSICAL_ASIAR_ABIAB1B2B3_AHFIB_ENB
${runs_of_uuf_reset}           ${30}
${runs_of_activation_reset}    ${20}
${runs_of_uuf_upgrade}         ${5}
${runs_of_ru_reset}            ${20}
${runs_of_bb_reset}            ${10}
${test_iteration}              ${5}
${SOURCE_SW}                   ${None}
${TARGET_SW}                   ${None}
@{CUSTOM_ALARMS}               6331  6327  4125  7308  7319  4405  4153  4452  1898  4123  4298
@{IGNORED_PRINTS}              is not defined in SysinfoQuota.xml. Please contact the owner
${SHOULD_BE_REPORTED}          ${True}

&{NODE1}                       testline_object=${tl.gnbs[0]}
...                            source_sw=${SOURCE_SW}
...                            target_sw=${TARGET_SW}
...                            custom_allowed_alarms=${CUSTOM_ALARMS}
...                            syslog_ignored_prints=${IGNORED_PRINTS}

@{NODES}                       ${NODE1}

${RP_CA}                       VRF_RRM
${RP_ORGANIZATION}             VRF_KRK_T08
${RP_LOCATION}                 VRF_KRK

############### Test Setup ###############
${TARGET_DIR}                  /home/ute/Downloads
${SW_CONFIG_PATH}              commissionings/Krakow/7_7_UTE5GCLOUDT1SK043/swconfig.txt
${SCF_PREFIX}                  ${None}

*** Keywords ***
Test Suite Setup
    Set Global Variable    ${TARGET_SW}    ${ENB_BUILD}
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ***** Source Software Set to: ${SOURCE_SW} *****
    Log to console    ***** Target Software Set to: ${TARGET_SW} *****
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Preparing TestLine for testing ----
    Run    mkdir /home/ute/Downloads
    Pubs Mount
    Download Source Build
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Upgrading BTS to ${SOURCE_SW} ----\n
    Upgrade and Commission Gnb    builds_dir=${TARGET_DIR}  sw_build=${SOURCE_SW}  prefix_tag=${SCF_PREFIX}
    Wait until keyword succeeds    1200 sec    30 sec    gnbcell.Verify All Cells Are Onair
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Uploading SWconfig on gNB ----\n
    commissioning.Upload Swconfig On Classical Gnb
    ...    sw_config_path=${SW_CONFIG_PATH}
    ...    reboot_after_upload=${True}
    Wait until keyword succeeds    1200 sec    30 sec    gnbcell.Verify All Cells Are Onair
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- SWconfig has been uploaded ----\n
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Collecting snapshot to remove Diagnostic Files Collected alarm ----\n
    Collect Snapshot From gNB    log_dir=${OUTPUT_DIR}/${SUITE_NAME}
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Snapshot has been collected ----\n
    Run     rm ${TARGET_DIR}/${SOURCE_SW}_release_BTSSM_downloadable_A54.zip
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Source software has been deleted from ${TARGET_DIR} ----\n
    Common Suite Setup
    gnb_ru_lmi.Setup Hosts For All RU Console Collection
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- TestLine has been prepared for testing ----\n

Download Source Build
    [Arguments]    ${timeout}=600
    Log to console    ---- Downloading ${SOURCE_SW} ----
    ${first_part}=    Fetch From Left    ${SOURCE_SW}    _
    Set Suite Variable    ${SOURCE_BRANCH}    ${first_part}
    Start Process    cp    /home/ute/pubs/LOADS/${SOURCE_BRANCH}/${SOURCE_SW}_release_BTSSM_downloadable_A54.zip    ${TARGET_DIR}    alias=file_copy
    ${result}=    Wait For Process    file_copy    timeout=${timeout}
    Should Be Equal As Integers    ${result.rc}    0    Copy failed: ${result.stderr}
    File Should Exist    ${TARGET_DIR}/${SOURCE_SW}_release_BTSSM_downloadable_A54.zip
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Software downloaded ----

Pubs Mount
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Mounting PUBS ----
    Run    sudo su -c 'mkdir /mnt/pubs'
    ${terminator}=    Catenate    SEPARATOR=${SPACE}
    ...    sudo su -c 'echo "//10.83.200.250/project/pubs /mnt/pubs cifs
    ...    user,username=pubs,vers=3.0,password=pubs123,domain=KRK-NAS,uid=ute,gid=ute 0 0"  >> /etc/fstab'
    Run    ${terminator}
    Run    sudo su -c 'mount /mnt/pubs'
    Run    sudo su -c 'ln -s /mnt/pubs/ /home/ute/pubs'
    File Should Exist    /home/ute/pubs/pubs
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- PUBS mounted successfully ----

Wait For RMOD Offline On GNB
    [Arguments]    ${id}=${1}
    Wait Until Keyword Succeeds  10min  20s  gnbru.verify_radio_unit_statuses  ru_id=${id}  availability_status=offline

Test Suite Teardown
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    \n********************************************
    Log to console    \n---- Start Suite Teardown ----\n
    Common Suite Teardown
    Run Keyword and Ignore Error    gnb_ru_lmi.Teardown Hosts For All RU Console Collection
    Log to console    \n---- Suite Teardown DONE ----\n
    Log to console    \n********************************************

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    gnb_ru_lmi.Setup Serial Console Connection for All RUs
    ...    raise_exception=${True}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}ursive=${True}

Custom Test Teardown
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    gnb_ru_lmi.Collect Snapshot From all Setup RUs
    gnb_ru_lmi.Collect Console Log From all Setup RUs
    gnb_ru_lmi.Teardown Serial Console Connection for All Setup RUs
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
