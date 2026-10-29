*** Settings ***
Documentation
...   Resources for testing CB009469 feature
...   author: Aleksander Gospodarczyk, Natalia Czech, Bartosz Odziomek
...   contact: aleksander.gospodarczyk@nokia.com, natalia.czech@nokia.com, bartosz.odziomek@nokia.com

Resource        taf/rfrl/procedures/SISO/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource        testsuite/Krakow/SISO/procedures/General_SiSo_BTS_reset_with_RF_power_reset/procedure.robot
Resource        taf/rfrl/bts/robot/common/gnb_cell.robot
Resource        taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource        taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource        testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Library         taf.rfrl.bts.commissioning
Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library         testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${scf}         main_gnb


*** Keywords ***
Test Suite Setup
    Perform Full Commissioning On Classical gnb     prefix_tag=${scf}    update_timeout=1200
    Common Suite Setup

Test Setup With Watching Alarms
    Run Keywords   Set Suite Variable    @{CUSTOM_ALLOWED_ALARMS}    No X2 link available
    ...           No X2 link available for a specific LTEENB
    ...           Diagnostic Files collected
    ...           BTS Reset Cause
    ...           Sanity Check Error
    ...           Radio Diagnostic Files collected
    ...           Unit power reset
    ...           AND
    ...           Common Preconditions With Watching Alarms

02_Re-Commissioning_via_WebEM
    General SiSo Comissioning BTS Template Comissioning
    ...  dist_name=MRBTS-{}/MNL-1/MNLENT-1/SYNC-1
    ...  incorrect_value=10000
    ...  correct_value=5
    ...  parameter=Manual frame timing adjustment
    Wait until keyword succeeds    900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    Wait Until Keyword Succeeds    600sec     15sec    Verify Alarm is not Active on gNB    fault_name=BTS Reset Cause
