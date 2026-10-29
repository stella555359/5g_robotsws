*** Settings ***
Documentation
...  author: Kamil Kluz
...  contact: kamil.kluz@nokia.com
...  Description: This user scenario describes the successful addition of a new DRB in the ext-gNB for a UE context
...               already in IgNB-CA mode

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/kw_2640.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008533/resources/kw_8533.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001390/resources/kw_1390.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py
Library         testsuite/Wroclaw/RRM/resources/logs.py


*** Variables ***
${resource_path_8140-JA}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources


*** Keywords ***
[1]CB008140-AB#B3_Unsuccessful_XP_setup_procedure_for_the_inter-gNB_CA_BTS_startup_scenario
    #Load identical software build on external gNBs    uncomment when TC is launched manually
#    Load scf for second NR    ${resource_path_8140-JA}    SCFs    scf_8140-JA-gNB2.xml
#    Load scf for NR           ${resource_path_8140-JA}    SCFs    scf_8140-JA-gNB1.xml
    Start syslog collection
    watchdog.watch_alarms
    Sleep   60s
    Change ip relation for JE case
    Log to console   IP relation has been changed
    Sleep  60s
    watchdog.Wait for active alarm    fault_id=7331     timeout=5 min
    Stop syslog collection
    [Teardown]    Run keyword
    ...           Fix ip relation for JE case
