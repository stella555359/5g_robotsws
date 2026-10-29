*** Settings ***
Documentation
...   author: Karolina Pawlik and Michal Pekala
...   contact: karolina.pawlik.ext@nokia.com
...   This is the ROBOT for feature 5GC002534-A_16, 5GC002534-A_18, 5GC002534-A_04, 5GC002534-A_06

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.robot
#Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/parameters.py
Library     ute_ue
Library     taf.ul.messaging.mtk      WITH NAME    mtk
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/variables.py
Resource    testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot


# Suite Setup     Run keywords
#         ...     BTSLOG Start btslog on local machine    AND
#         ...     Connecting To Coam    AND
#         ...     Get SCF Before Test     AND
#         ...     Reserve UEs MTK For tests


# Suite Teardown  Run keywords
#         ...     Load SCF After Test   AND
#         ...     BTSLOG Collect btslog     AND
#         ...     Disconnecting from Coam


*** Keywords ***

[1]5GC002534-A_04_PDSCH traffic at SSB slot. NSA. chBW=15MHz
    [Documentation]  #The purpose of this test is to...
    Load scf for NR    ${resource_path_2534}    2534-A_SCFs    scf_15MHZ.xml
    Check If Truput Is Higher With Pdsch On NSA TCP
    Verify PM Counters
    Detach UE NSA


[1]5GC002534-A_06_PDSCH traffic at SSB slot with PRB blanking. NSA. chBW=20MHz
    [Documentation]  #The purpose of this test is to...
    Load scf for NR    ${resource_path_2534}    2534-A_SCFs    scf_20MHZ.xml
    Check If Truput Is Higher With Pdsch On NSA UDP
    Verify PM Counters
    Detach UE NSA


[1]5GC002534-A_16_PDSCH traffic at SSB slot. SA. chBW=15MHz
    [Documentation]  #The purpose of this test is to...
    Load scf for NR    ${resource_path_2534}    2534-A_SCFs    scf_15MHZ.xml
    Check If Truput Is Higher With Pdsch On SA TCP
    Verify PM Counters
    Detach UE SA

[1]5GC002534-A_18_PDSCH traffic at SSB slot with PRB blanking. SA. chBW=20MHz
    [Documentation]  #The purpose of this test is to...
#    Load SCF_20_MHZ_No_PRBBlanking  #    If semi auto, scf loading kw below must be uncommented.
    Check If Truput Is Higher With Pdsch On SA UDP
    Verify PM Counters
    Detach UE SA
