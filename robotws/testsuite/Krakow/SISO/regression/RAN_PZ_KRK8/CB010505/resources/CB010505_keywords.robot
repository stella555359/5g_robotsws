*** Settings ***
Documentation
...   Keywords for CB010505
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource        taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Library         taf.rfrl.utilities.cloud_manager.artifacts
Library         testsuite/Krakow/resources/random_oam_procedure_runner.py
Library         taf.rfrl.bts.devices.du.du_operations.GnbDuOperations     WITH NAME    Du
Library         OperatingSystem
Library         String
Library         Collections
Library         testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py


*** Variables ***
${downloads_dir}        /home/ute/Downloads
${BTS_config}           CB010505_main_gnb
@{allowed_alarms}       Service account root access is enabled
...                     SSH enabled
...                     Diagnostic Check Error
...                     LMP access via port 443
...                     No X2 link available for a specific LTEENB
...                     No X2 link available
...                     BTS Reset Cause
...                     Ethernet port security is disabled
...                     R&D Service Port enabled
${impermissible_x2_fault_1}          No X2 link available for a specific LTEENB
${impermissible_x2_fault_2}          No X2 link available
${duration}             120s
${tput_dl}              300 Mbits/sec
${tput_ul}              160 Mbits/sec
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${SOURCE_SW}                                    ${None}
${TARGET_SW}                                    ${None}

${OPERATIONS} =
...    ['bts_power_on', 'cell_block_unblock', 'cell_lock_unlock',
...     'power_reset_rmod', 'rat_reset', 'reset_bbmod',
...     'reset_rmod', 'site_reset']
${TOTAL_TIMEOUT}                                ${10800}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${False}
${OPERATION_KWARGS}                             ${None}
${RANDOM_SEED}                                  ${None}
${L3_CALL}                                      ${False}
${L3_CALL_KEYWORDS}                             ${None}

*** Keywords ***
Suite Setup
    BuiltIn.Log to console      \n-- Commission gNB --\n
    Perform Full Commissioning On Classical gnb     prefix_tag=${BTS_config}    update_timeout=1200
    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    BuiltIn.Log to console      \n-- Preparing Testline --\n
    Common Suite Setup
    ${SOURCE_SW} =
    ...    IF    '${SOURCE_SW}' == '${None}'
    ...    Get CM Source Build
    ...    ELSE    Set Variable    ${SOURCE_SW}
    ${TARGET_SW} =
    ...    IF    '${TARGET_SW}'=='${None}'
    ...    Get Cm Target Build
    ...    ELSE    Set Variable  ${TARGET_SW}
    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Wait Until Keyword Succeeds    60s    30s    ute_ue.Require Ue    UE      capabilities=REAL_ANDROID_UE


Cell_Block_and_Unblock
    General SiSo Cell block and unblock
    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair

RU_module_reset_from_GUI
    General SiSo Auto gNB Site Reset From WebUI

Commissioning_BTS_Template_Commissioning
    Wait until keyword succeeds      600 sec    15 sec     Perform Full Commissioning and Wait for onAir
    ...    prefix_tag=${BTS_config}

SWM_Software_download_and_activation
    Set Suite Variable      ${sw_version}    ${TARGET_SW}
    ${sw_package_dir}  Download SW package     ${sw_version}   ${downloads_dir}
    gnbswupdate.update Software
    ...    sw_package_dir=${sw_package_dir}
    ...    timeout=1200
    Wait Until Keyword Succeeds     1200 sec     30 sec   Verify gNB is onAir

Perform L3 Call on single UE
    [Arguments]    ${95_percent_tput_required}=False
    ${status}=    Run Keyword And Return Status     L3 call DL UL    95_percent_tput_required=${95_percent_tput_required}
    ute_ue.Detach Ue    UE
    Run Keyword If    '${status}'=='False'    L3 call DL UL    95_percent_tput_required=${95_percent_tput_required}
    ...    ELSE    BuiltIn.Log to console    \n...TPUT Passed...\n

L3 call DL UL
    [Arguments]    ${95_percent_tput_required}=False
    X2 Alarms Verification
    BuiltIn.Log to console      \n--Attach UE--\n
    Wait until keyword succeeds      600 sec    120 sec    ute_ue.Attach Ue      UE
    BuiltIn.Log to console    \n--Starting TPUT test--\n
    IF    ${95_percent_tput_required}
        Start Data Transfer DL&UL and Verify Troughput    ${duration}     ${tput_dl}    ${tput_ul}    deviation_dl=5%    deviation_ul=5%
    ELSE
        Start Data Transfer DL&UL and Verify Troughput    ${duration}     ${tput_dl}    ${tput_ul}    deviation_dl=80%    deviation_ul=80%
    END
    BuiltIn.Log to console      \n--Checking if X2 alarms are visible--\n
    X2 Alarms Verification
    BuiltIn.Log to console    \n--Detaching UE after tput--\n
    ute_ue.Detach Ue    UE

X2 alarms verification
    Set Test Variable       ${fault_name}       ${impermissible_x2_fault_1}
    Wait Until Keyword Succeeds    600s    15s    Verify Alarm is not Active on gNB    ${fault_name}
    Set Test Variable       ${fault_name}       ${impermissible_x2_fault_2}
    Wait Until Keyword Succeeds    600s    15s    Verify Alarm is not Active on gNB    ${fault_name}

