*** Settings ***
Documentation
...   author: Michal Pekala and Karolina Pawlik
...   contact: karolina.pawlik.ext@nokia.com
...   This is the ROBOT for feature 5GC002534-B_31

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_askey.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.py
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/variables.py
Resource        testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_for_logs.robot
Library         ute_ue


# Suite Setup     Run keywords
#         ...     Setup attenuators   AND
#         ...     Set initial attenuation   AND
#         ...     Reserve UEs Askey For tests

# Test Setup      Run keywords
#         ...     BTSLOG Start btslog on local machine    AND
#         ...     Connecting To Coam     AND
#         ...     Get SCF Before Test

# Test Teardown   Run keywords
#         ...     Load SCF After Test     AND
#         ...     BTSLOG Collect btslog   AND
#         ...     Disconnecting from Coam


*** Variables ***
${truput_pdsch_off}
${truput_pdsch_on}

*** Keywords ***


[1]5GC002534-B_31_PDSCH traffic at SSB slot in DSS case. NSA. chBW=10MHz
    [Documentation]  PDSCH_traffic_at_SSB_slot_in_DSS_case_NSA_chBW=10MHz
    [Tags]   #CRT
    keywords_2534.Load scf for LTE       2534-B_SCFs   B31_LTE_Configuration_scf.xml
    Load scf for NR    ${resource_path_2534}    2534-B_SCFs    B31_NR_Configuration_scf.xml
    Check X2 Status
    Check If Truput Is Higher With Pdsch On Askey NSA UDP
    Verify PM Counters
    Detach UE Askey NSA


[1]5GC002534-B_33_PDSCH traffic at SSB slot in DSS case with PRB blanking. NSA. chBW=15MHz
     [Documentation]  PDSCH_traffic_at_SSB_slot_in_DSS_case_with_PRB_blanking_NSA_chBW=15MHz
     [Tags]   #CRT
     keywords_2534.Load scf for LTE       2534-B_SCFs   B33_LTE_Configuration_scf.xml
     Load scf for NR    ${resource_path_2534}    2534-B_SCFs    B33_NR_Configuration_scf.xml
     Check X2 Status
     Check If Truput Is Higher With Pdsch On Askey NSA UDP
     Verify PM Counters
     Detach UE Askey NSA


[1]5GC002534-B_36_PDSCH traffic at SSB slot in DSS case. SA. chBW=15MHz
     [Documentation]  PDSCH_traffic_at_SSB_slot_in_DSS_case_SA_chBW=10MHz
     [Tags]   #CRT
     keywords_2534.Load scf for LTE       2534-B_SCFs   B36_LTE_Configuration_scf.xml
     Load scf for NR    ${resource_path_2534}    2534-B_SCFs    B36_NR_Configuration_scf.xml
     Check X2 Status
     Check If Truput Is Higher With Pdsch On Askey SA TCP
     Verify PM Counters
     Detach UE Askey SA


[1]5GC002534-B_38_PDSCH traffic at SSB slot in DSS case with PRB blanking. SA. chBW=20MHz
     [Documentation]  PDSCH_traffic_at_SSB_slot_in_DSS_case_with_PRB_blanking_SA_chBW=20MHz
     [Tags]   #CRT
     keywords_2534.Load scf for LTE       2534-B_SCFs   B38_LTE_Configuration_scf.xml
     Load scf for NR    ${resource_path_2534}    2534-B_SCFs    B38_NR_Configuration_scf.xml
     Check X2 Status
     Check If Truput Is Higher With Pdsch On Askey SA UDP
     Verify PM Counters
     Detach UE Askey NSA


[1]5GC002534-B_43_PDSCH traffic at SSB slot in DSS for multiple users with PRB blanking NSA+SA chBW=15MHz
    [Documentation]     Test case from 5GC002534-E PDSCH_scheduling_at_SBB_slots_with_FDM (notation from QC)
    ...                 The purpose of this test is to verify that gNB can support PDSCH scheduling at SSB slot
    ...                 without Ct, for multiple users in DSS case with PRB blanking.
    [Tags]   #CRT
    keywords_2534.Load scf for LTE        2534-B_SCFs      B43_LTE_Configuration_scf.xml
    Load scf for NR    ${resource_path_2534}    2534-B_SCFs    B43_NR_Configuration_scf.xml
    Check If Truput Is Higher With Pdsch On Askey NSA SA UDP
    Verify PM Counters
    Detach UE Askey NSA
    Detach UE Askey SA
