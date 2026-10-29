*** Settings ***
Documentation   CIT regression TCs for 5GC002481_AGBL shall be added here for fully automated regression testing.

Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py    WITH NAME    testline_preparation
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/A/resources/keywords_774_A.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/B/resources/keywords_774_B.robot

Suite Setup      Run Keywords
...              testline_preparation.Prepare Testline    custom_swconfig_flags=${swconfig_flags_rohc}        AND
...              Initialise Attenuator

Test Setup       Nullify attenuation on all ports

Test Teardown    Run Keywords
...              Detach UE    UE_1                                AND
...              Detach UE    UE_2                                AND
...              774_A_btslog.teardown_btslog                     AND
...              Nullify attenuation on all ports


*** Test Cases ***
5GC000774_A_01_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD
    [Documentation]   The TC verifies whether VoNR with ROHC works correctly. FDD
    5GC000774_A_01_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD


5GC000774_A_03_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD_with_maxCidAllowed=1
    [Documentation]   The TC verifies whether VoNR with ROHC works correctly, when maxCidAllowed=1. FDD
    5GC000774_A_03_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD_with_maxCidAllowed=1


5GC000774_B_03_Verification_of_PM_counters_M55320C19001_M55320C19002_M55320C19003_and_M55320C19004
    [Documentation]   Check PM counters M55320C19001, M55320C19003, which are related to no. ROHC (de)compressions
    5GC000774_B_03_Verification_of_PM_counters_M55320C19001_M55320C19002_M55320C19003_and_M55320C19004


5GC000774_B_04_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002
    [Documentation]   Check PM counters M55135C01001, M55135C01002, M55124C06001 and M55124C06002
    5GC000774_B_04_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002
