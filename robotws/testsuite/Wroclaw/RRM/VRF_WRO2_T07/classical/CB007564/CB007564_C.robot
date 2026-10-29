*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the TESTSUITE file for feature CB007564

#Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   5G_RAN   5G_RAN_FDD
#...           RAN_5G    RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP   PY36
#...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB
#...           SBTS22R4__WITH__CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB
#...           SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/keywords_7564_C.robot

Suite Setup      Run Keywords
...              Prepare Testline                                                       AND
...              Initialise Attenuator

Test Setup       Run Keywords
...              BTSLOG Start btslog on local machine                                   AND
...              Nullify attenuation on all ports

Test Teardown    Run Keywords
...              Make snapshot in case of error                                         AND
...              BTSLOG Collect btslog                                                  AND
...              Nullify attenuation on all ports


*** Test Cases ***
CB007564-C_5_RA_CB_INIT_RESOLVED_incrementation_due_to_successful_initial_RA_setup_with_CRC_OK_and_contention_resolved
    [Documentation]   This test case verifies incrementation of counter provided to measure number of time when
     ...              RA setup is successful and the contention is resolved by UL grant addressed to its CRNTI.
     ...              Contention is considered resolved when an UL transmission with CRC OK is received.
    CB007564-C_5_RA_CB_INIT_RESOLVED_incrementation_due_to_successful_initial_RA_setup_with_CRC_OK_and_contention_resolved

CB007564-C_6_RA_MSG3_RECEP_INIT_incrementation_due_to_successful_initial_RA_setup
    [Documentation]   This test case verifies incrementation of counter provided to measure number of time when
     ...              RA setup is successful and msg3 is received successfully from UE.
    CB007564-C_6_RA_MSG3_RECEP_INIT_incrementation_due_to_successful_initial_RA_setup

CB007564-C_8_Incrementation_of_counters_due_to_initial_access_based_on_contention_free_procedure
    [Documentation]   This test case verifies incrementation of counter provided to measure number of times when
     ...              dedicated preamble is sent to the UE from gNB for initial access: DED_PREAMBL_SENT_CFRA_INIT,
     ...              number of time when dedicated preamble assigned to UE by the gNB is used by UE during Msg1:
     ...              INIT_RA_ATT_CFRA_and_DED_PREAMBL_USED_CFRA_INIT_and_INIT_MSG1_ACK_CFRA and number of time when
     ...              CFRA setup is successful and the UE responds in first UL transmission
     ...              that CRC is OK: INIT_MSG2_ACK_CFRA.
    CB007564-C_8_Incrementation_of_counters_due_to_initial_access_based_on_contention_free_procedure
