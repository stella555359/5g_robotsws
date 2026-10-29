*** Settings ***
Documentation
...   Keywords for CB008734 feature testsuite
...   author: Aleksander Gospodarczyk, Natalia Czech, Bartosz Odziomek
...   contact: aleksander.gospodarczyk@nokia.com, natalia.czech@nokia.com, bartosz.odziomek@nokia.com

Resource        testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Cell_Lock_Unlock.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Auto_Cell_Block_Unblock.robot
Resource        taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource        taf/rfrl/bts/robot/common/gnb_cell.robot
Resource        taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library         taf.rfrl.utilities.logger.custom_logger    WITH NAME    logger
Library         taf.rfrl.bts.commissioning
Library         testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py



*** Variables ***
${ue_pc_address}=               PLKR-SC5G-UE4.intra.noklab.net
${ue_pc_login}=                 PLKR-SC5G-UE4+user-lab0
${ue_pc_password}=              NokiaBts2003
${BTS_config}                   CB008734_main_gnb
${ue_alias}                     UE
${duration}                     120s
${tput_dl}                      1000 Mbits/sec
${tput_ul}                      1000 Mbits/sec
${alias}                        ${ue_alias}
${error}                        DataTransferVerificationFailure
${fault_name1}                  No X2 link available for a specific LTEENB
${fault_name2}                  No X2 link available
@{CUSTOM_ALLOWED_ALARMS}        No X2 link available
...                             No X2 link available for a specific LTEENB



*** Keywords ***
Test Suite Setup
    BuiltIn.Log to console      \n-- Commission gNB --\n
    Perform Full Commissioning On Classical gnb     prefix_tag=${BTS_config}    update_timeout=1200
    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    BuiltIn.Log to console      \n-- Preparing Testline --\n
    Restart Ue Proxy On Ue PC
    Common Suite Setup
    BuiltIn.Log To Console   \n--Preparing UE--\n
    Wait Until Keyword Succeeds    600s    30s     ue.Require Ue    UE      capabilities=REAL_ANDROID_UE
    ue.Detach Ue     UE
    BuiltIn.Log To Console   \n--Suite Setup DONE--\n

Custom Test Setup
    BuiltIn.Log To Console   \n--Start Test Setup--\n
    Wait Until Keyword Succeeds    600s    30s    Common Preconditions With Watching Alarms
    BuiltIn.Log To Console   \n--Test Setup DONE--\n

Custom Test Teardown
    BuiltIn.Log To Console    \n--Start Test Teardown--\n
    ue.Detach Ue    UE
    BuiltIn.Log To Console      \n--Checking if X2 alarms are visible--\n
    X2 Alarms Verification
    Wait Until Keyword Succeeds    600s    30s    Common Postconditions With Watching Alarms

Perform L3 Call on single UE
    ${status}=    Run Keyword And Return Status     L3 call DL UL
    ue.Detach Ue    UE
#    Run Keyword if    '${status}'=='False'      L3 call DL UL    ELSE    log to console      \n...TPUT Passed...\n

L3 call DL UL
    BuiltIn.Log To Console      \n--Attach UE--\n
#    Wait until keyword succeeds      60 sec    60 sec    ue.Attach Ue      UE
    ue.Attach Ue      UE
    BuiltIn.Log To Console    \n--Starting TPUT test--\n
    run keyword and expect error    STARTS:${error}    Start Data Transfer DL&UL and Verify Troughput
    ...                             ${duration}     ${tput_dl}    ${tput_ul}
    BuiltIn.Log To Console      \n--Checking if X2 alarms are visible--\n
    X2 Alarms Verification
    BuiltIn.log to console    \n--Detaching UE after tput--\n
    ue.Detach Ue    UE

07_Cell_Block_Unblock
    General SiSo Cell block and unblock
    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    Perform L3 Call on single UE

08_Cell_Lock_Unlock
    gnbbbu.connect       bts_id=${0}  du_id=${0}   force=${True}
    Lock Unlock All gNB Cells via Gui       administrative_state=${True}
    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    Perform L3 Call on single UE

10_RF_lock_unlock
    General SiSo Auto RF Lock Unlock
    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    Perform L3 Call on single UE

11_RF_head_Reset_from_WebEM
    General SiSo Auto RF module reset from WebUI        runs=1
    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    Perform L3 Call on single UE

12_Site_Reset_from_WebEM
   General SiSo Auto gNB Site Reset From WebUI
   BuiltIn.Log To Console      \n--Checking if X2 alarms are visible--\n
   X2 alarms verification
   Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair
   Perform L3 Call on single UE
   Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair

X2 alarms verification
    Set Test Variable       ${fault_name}       ${fault_name1}
    Wait Until Keyword Succeeds    600s    15s    Verify Alarm is not Active on gNB    ${fault_name}
    Set Test Variable       ${fault_name}       ${fault_name2}
    Wait Until Keyword Succeeds    600s    15s    Verify Alarm is not Active on gNB    ${fault_name}
