*** Settings ***
Documentation
...    Test suite for regression testing for feature CB013432
...    authors: Jakub Bialon
...    maintainer: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com


Library    taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations   WITH NAME   gnbasir
Library    ./resources/tools.py
Library    ./../../../../../../testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py


*** Test Cases ***
CB013432_01_Feature_Enable_for_ASiR_WebEM
    gnbasir.Wait For Asir To Be Onair
    gnbasir.Verify Status Of All Asir Cells Is Operational


CB013432_02_CM_Recommissioning_for_ASiR_WEM
    gnbasir.Perform Asir Commissioning    scf_path=../testline_configuration/7_7_TSPY019/SBTS00/CB013432_GNB0_ASIR_SCF.xml
    gnbasir.Wait For Asir To Be Onair
    tools.Update Aisr Parmeter Maxparallelusersessions    value=6
    gnbasir.Wait For Asir To Be Onair
    ${error_msg}=    Run Keyword And Expect Error    *    tools.Update Aisr Parmeter Maxparallelusersessions    value=11
    Should Contain    ${error_msg}    Validation failed: invalid parameters.
    gnbasir.Wait For Asir To Be Onair


CB013432_04_Block_Unblock_pRRHs_via_ASiR_WebEM
    gnbasir.Block Antenna    ant_id=1
    gnbasir.Block Antenna    ant_id=2
    @{ant_ids}    Create List    1  2
    gnbasir.Verify Antennas Are Blocked    ant_ids=@{ant_ids}
    @{allowed_alarms}    Create List    ${4348}
    gnbasir.Verify Only Allowed Alarms Are Active    allowed_alarms=@{allowed_alarms}
    gnbasir.unblock_antenna    ant_id=1
    gnbasir.unblock_antenna    ant_id=2
    gnbasir.Verify Alarm Is Not Active    fault_id=4348
    gnbasir.Verify All Antennas Are Enabled


CB013432_05_Reset_ASiR_HUB_via_ASiR_WebEM
    gnbasir.Reset Hub    timeout=${300}
    gnbasir.Wait For Asir To Be Onair
    tools.Wait For All Hubmods Is Operational


CB013432_07_Reset_pRRH_via_ASiR_WebEM
    gnbasir.Reset Antenna    ant_id=1   timeout=${300}
    @{allowed_alarms}    Create List    ${4480}
    gnbasir.Verify Only Allowed Alarms Are Active    allowed_alarms=@{allowed_alarms}
    gnbasir.Wait For Asir To Be Onair
    gnbasir.Verify All Antennas Are Enabled
    gnbasir.Verify Alarm Is Not Active    fault_id=4480
    Sleep    60s    Waiting for wlan connection
    gnbasir.Reset Antenna    ant_id=2    timeout=${300}
    gnbasir.Verify Only Allowed Alarms Are Active    allowed_alarms=@{allowed_alarms}
    gnbasir.Wait For Asir To Be Onair
    gnbasir.Verify All Antennas Are Enabled
    gnbasir.Verify Alarm Is Not Active    fault_id=4480
