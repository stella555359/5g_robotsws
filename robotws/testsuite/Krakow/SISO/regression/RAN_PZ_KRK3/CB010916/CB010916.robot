*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010916 (Antenna port re-mapping)
...   author: Marek Bodziony, Piotr Suski
...   contact: marek.bodziony@nokia.com, piotr.suski@nokia.com

Resource    ./resources/CB010916_keywords.robot

Force Tags    STATE_SW_UPLOADED    CRT    PY36

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
Suite Teardown      Common Suite Teardown

*** Test Cases ***
[1][1.0] CB010916-03_Modifying_antenna_port_re-mapping_for_4TX_cell_while_feature_is_active
    [Setup]    TC03 test setup
    Modify antenna port re-mapping [3,2,1,0] on Cell-0 and verify cell lock/unlock
    Verify correct port mapping [3,2,1,0] on CPRI cell in SYSLOG
    Perform L3 call on Cell-0
    Modify antenna port re-mapping [2,0,3,1] on Cell-0 and verify cell lock/unlock
    Verify correct port mapping [2,0,3,1] on CPRI cell in SYSLOG
    Perform L3 call on Cell-0
    Modify antenna port re-mapping [1,2,3,0] on Cell-1 and verify cell lock/unlock
    Verify correct port mapping [1,2,3,0] on eCPRI cell in SYSLOG
    Perform L3 call on Cell-1
    Modify antenna port re-mapping [2,0,1,3] on Cell-1 and verify cell lock/unlock
    Verify correct port mapping [2,0,1,3] on eCPRI cell in SYSLOG
    Perform L3 call on Cell-1
    Modify antenna port re-mapping [0,1,3,2] on Cell-1 and verify cell lock/unlock
    Verify correct port mapping [0,1,3,2] on eCPRI cell in SYSLOG
    Perform L3 call on Cell-1
    [Teardown]   TC03 test teardown

[1][1.0] CB010916-06_Modifying_antenna_port_re-mapping_for_4TX_cell_while_feature_is_active_supercell
    [Setup]    TC06 test setup
    Modify antenna port re-mapping [1,0,2,3] on Supercell and verify Supercell lock/unlock
    Verify correct port mapping [1,0,2,3] on eCPRI cell in SYSLOG
    Perform L3 call on Cell-1 (supercell)
    Modify antenna port re-mapping [3,2,0,1] on Supercell and verify Supercell lock/unlock
    Verify correct port mapping [3,2,0,1] on eCPRI cell in SYSLOG
    Perform L3 call on Cell-1 (supercell)
    Modify antenna port re-mapping [1,3,2,0] on Supercell and verify Supercell lock/unlock
    Verify correct port mapping [1,3,2,0] on eCPRI cell in SYSLOG
    Perform L3 call on Cell-1 (supercell)
    Modify antenna port re-mapping [0,1,3,2] on Supercell and verify Supercell lock/unlock
    Verify correct port mapping [0,1,3,2] on eCPRI cell in SYSLOG
    Perform L3 call on Cell-1 (supercell)
    [Teardown]   TC06 test teardown

[1][1.0] CB010916-07_Antenna_port_re-mapping_for_2x_2TX_pRRHs_D-MIMO
    [Setup]    TC07 test setup
    Enable antenna port re-mapping [3,2,1,0] on Cell-0 and verify cell lock/unlock
    Verify correct port mapping [3,2,1,0] on CPRI cell in SYSLOG
    Perform L3 call on Cell-0 (D-MIMO)
    Modify antenna port re-mapping [1,3,0,2] on Cell-0 and verify cell lock/unlock
    Verify correct port mapping [1,3,0,2] on CPRI cell in SYSLOG
    Perform L3 call on Cell-0 (D-MIMO)
    Modify antenna port re-mapping [2,0,3,1] on Cell-0 and verify cell lock/unlock
    Verify correct port mapping [2,0,3,1] on CPRI cell in SYSLOG
    Perform L3 call on Cell-0 (D-MIMO)
    Modify antenna port re-mapping [0,2,1,3] on Cell-0 and verify cell lock/unlock
    Verify correct port mapping [0,2,1,3] on CPRI cell in SYSLOG
    Perform L3 call on Cell-0 (D-MIMO)
    Modify antenna port re-mapping [2,1,3,0] on Cell-0 and verify cell lock/unlock
    Verify correct port mapping [2,1,3,0] on CPRI cell in SYSLOG
    Perform L3 call on Cell-0 (D-MIMO)
    Disable antenna port re-mapping on Cell-0 and verify cell lock/unlock
    Verify correct port mapping [0,1,2,3] on CPRI cell in SYSLOG
    Perform L3 call on Cell-0 (D-MIMO)
    [Teardown]  TC07 test teardown
