*** Settings ***
Documentation
...  author: Piotr Szlegel
...  contact: piotr.szlegel@nokia.com
#Resource        testsuite/SISO/Wroclaw/CommonKeywords/RobotKeywords/Alarms.robot
Resource        ./resources/keywords.robot

*** Keywords ***
[1]5GC000900-B_19_Successful_NSA_cell_setup_but_SA_cell_setup_fails_for_mixed_mode_cell
    # [Tags]   CRT
    wait until keyword succeeds  10min      1min    Check if X2 link Up
    wait until keyword succeeds  10min      1min   Check if NGlinkUp
    Break AMF connection
    watchdog.Wait for active alarm    fault_id=7103    timeout=10 min
    Bring Up AMF connection
    # Lock gNB NSA+SA cells
    # Set NRCELL fPdcchMonOccsnPo
    # Unlock gNB NSA+SA cells
    # Wait for fault 7101
    [Teardown]     Run keywords
    ...            Recover

[1]5GC000900-B_20_Successful_SA_cell_setup_but_NSA_cell_setup_fails_for_mixed_mode_cell
    # [Tags]   CRT   CDRT
    wait until keyword succeeds  10min      1min    Check if X2 link Up
    Run Keyword and Ignore Error  Set cell DepType for all cells   SA+NSA
    Run Keyword and Ignore Error  Set cell DepType for all cells   both
    Get X2 IP from LTE side
    Connect to LTE
    Break X2 connection
    watchdog.Wait for active alarm    fault_id=7100    timeout=10 min
    Bring Up X2 connection
    Restrict X2
    Lock gNB NSA+SA cells
    Unlock gNB NSA+SA cells
    sleep  3min
    watchdog.Wait for active alarm    fault_id=7101    timeout=10 min
    Get broadcast pcap
    Check pcap
    [Teardown]     Run keywords
    ...            Reset ASIA   AND
    ...            Reset and wait OnAir

[1]5GC000900-B_18_Successful_NSA+SA_cell_setup
    coam.Reset site    connection=cOAM
    Wait until keyword succeeds    20 min     1 min    Verify all cells are onair with admin
    Fail if critical alarms occurs and show other alarms
    Get broadcast pcap
    Check pcap

[1]5GC000900-B_22_Successful_NSA+SA_cell_reconfiguration_to_NSA_only_cell
    Find cell id with specific deptype    type=both
    Set cell DepType        type=NSA    cell_id=${specific_cell_id}
    Fail if critical alarms occurs and show other alarms

[1]5GC000900-B_23_Successful_NSA+SA_cell_reconfiguration_to_SA_only_cell
    Find cell id with specific deptype    type=both
    Set cell DepType        type=SA    cell_id=${specific_cell_id}
    Fail if critical alarms occurs and show other alarms

