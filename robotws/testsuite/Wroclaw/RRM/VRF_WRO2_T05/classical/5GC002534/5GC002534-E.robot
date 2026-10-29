*** Settings ***
Documentation
...   author: Karolina Pawlik
...   contact: karolina.pawlik.ext@nokia.com
...   This is the ROBOT for feature 5GC002534-A-11, A-22, A-44

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.robot
#Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/parameters.py
Library     ute_ue
Resource    testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Library     taf.ul.messaging.mtk      WITH NAME    mtk
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/variables.py


*** Variables ***

@{lines_gNB_157_AHCA_1}        5   6   7   8
@{lines_gNB_157_AHCA_2}        1   2   3   4
@{lines_gNB_157_AHCA_3}        9   10   11   12
@{lines_LTE_157}               13    14
#@{lines_gNB_159_AHCA_1}        13   14   15   16
#@{lines_gNB_159_AHCA_2}        17   18
#@{lines_gNB_159_AHCA_3}        19   20
@{lines_LTE_159}               15   16

*** Keywords ***

[1]5GC002534-A_11_PDSCH traffic at SSB slot for two users. NSA. chBW=10MHz
    [Documentation]     Test case from 5GC002534-E PDSCH_scheduling_at_SBB_slots_with_FDM (notation from QC)
    ...                 The purpose of this test is to verify that gNB can support PDSCH scheduling
    ...                 at SSB slot without Ct, for multiple users (2 UEs)
    [Tags]   #CRT
    Load scf for NR    ${resource_path_2534}    2534-A_SCFs    A11_NR_Configuration_scf.xml
    Set initial attenuation
    Set attenuation and check   lines=${lines_LTE_157}   value=0
    log to console      Attenuation modify
    Check If Truput Is Higher With Pdsch On NSA NSA TCP
    Verify PM Counters
    Detach UE NSA SA
    Detach UE NSA


[1]5GC002534-A_22_PDSCH traffic at SSB for two users chBW=15MHZ
    [Documentation]     Test case from 5GC002534-E PDSCH_scheduling_at_SBB_slots_with_FDM (notation from QC)
    ...                 The purpose of this test is to verify that gNB can support PDSCH
    ...                 scheduling at SSB slot without Ct, for multiple users (2 UEs)
    [Tags]   #CRT
    Load scf for NR    ${resource_path_2534}    2534-A_SCFs    A22_NR_Configuration_scf.xml
    Set initial attenuation
    Set attenuation and check   lines=${lines_LTE_157}   value=0
    log to console      Attenuation modify
    Check If Truput Is Higher With Pdsch On SA SA UDP
    Verify PM Counters
    Detach UE NSA SA
    Detach UE SA


[1]5GC002534-A_44_PDSCH traffic at SSB slot for multiple users with PRB blanking chBW=20MHZ
    [Documentation]     Test case from 5GC002534-E PDSCH_scheduling_at_SBB_slots_with_FDM (notation from QC)
    ...                 The purpose of this test is to verify that gNB can support PDSCH
    ...                 scheduling at SSB slot without Ct, for multiple users with PRB blanking.
    [Tags]   #CRT
    Load scf for NR    ${resource_path_2534}    2534-A_SCFs    A44_NR_Configuration_scf.xml
    Set initial attenuation
    Set attenuation and check   lines=${lines_LTE_157}   value=0
    log to console      Attenuation modify
    Check If Truput Is Higher With Pdsch On NSA SA UDP
    sleep  150s
    Verify PM Counters
    Run Keyword and Ignore Error   Detach UE NSA
    Run Keyword and Ignore Error   Detach UE SA
