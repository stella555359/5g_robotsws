*** Settings ***

Documentation     [SUITE PURPOSE] 
...               This small Robot was a personal script I put here to let community use it .
...               Collect FD_ALL (scf/basic/iphy/ap &5gnb swconfig) file on Classical machine 
...               to be able to refresh custom_config files I monitor. contact: francois.tourlonnias@nokia.com
...               
...               usage:  on jenkins, fill your form as usual with correct TOPOLOGY
...                       CRT_ROBOT_TEST_SUITE: testsuite/Paris/RRM/ET/resources/robot/ConfigCollector.robot
...                       CRT_TEST_CASE:        40MhzFdd or AB or F or F_TC3 or 8533AB5
...
...               WOW:    on each Trunk branch off, the actual trunk (SBTS00) became a branch.
...                       * on trunk (SBTS00) the scf is modified at each design delivery to include or remove feature 
...                         or new param for a feature. SCF on trunk is living
...                       * on branch the SCF have normaly no special modifications and stay as last branch off state
...                       for cusctom_config aspects, we need to maintain 2 repositories (One for Trunk, One for the branch -old trunk-)
...                       normaly at branch off time, the 2 repository will contain same scf
... 
...               Please be free to add your own Test cases if you want 
...


Resource           ./ConfigCollector_Keywords.robot

Suite Setup        Suite Setup From Scratch               #listBackupFiles=${FD_ALL}

Force Tags                          CA_5G_SW_FR-Villarceaux   RRM
...                                 master_classicalbts_all
...                                 SBTS00    SBTS22R3    SBTS23R1    SBTS22R4    CONFIGURED    5G_RAN    RAN_5G
...                                 PY36

*** Variables ***

*** Test Cases ***

40MhzFdd
    [Tags]    CONFIGS_BW/40Mhz_FDD/custom_config_40MhzFDD.yaml
    ...       CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    Collect    40MhzFdd

AB
    [Tags]    IBCA/5GC002640/custom_config_2640-AB.yaml
    ...       CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
    Collect    AB

F
    [Tags]    IBCA/5GC002640/custom_config_2640-F.yaml.yaml
    ...       CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
    Collect    F

F_TC3
    [Tags]    IBCA/5GC002640/custom_config_2640-F_TC3.yaml
    ...       CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
    Collect    F_TC3

8533AB5
    [Tags]    IBCA/5GC002640/custom_config_8533AB5.yaml
    ...       CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
    Collect    8533AB5

