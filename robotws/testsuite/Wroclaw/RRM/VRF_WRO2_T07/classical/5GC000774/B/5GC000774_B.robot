*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the TESTSUITE file for ROHC-B

Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/B/resources/keywords_774_B.robot

Suite Setup      Initialise Attenuator

Test Setup       Nullify attenuation on all ports

Test Teardown    Run Keywords
...              Detach UE    UE_1                                AND
...              Detach UE    UE_2                                AND
...              Nullify attenuation on all ports


*** Test Cases ***
5GC000774_B_03_Verification_of_PM_counters_M55320C19001_M55320C19002_M55320C19003_and_M55320C19004
    [Documentation]   Check PM counters M55320C19001, M55320C19003, which are related to no. ROHC (de)compressions
    5GC000774_B_03_Verification_of_PM_counters_M55320C19001_M55320C19002_M55320C19003_and_M55320C19004


5GC000774_B_04_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002
    [Documentation]   Check PM counters ...
    5GC000774_B_04_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002


5GC000774_B_05_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002_Emergency_Call
    [Documentation]   Check PM counters ...
    5GC000774_B_05_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002_Emergency_Call


5GC000774_B_06_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_M55124C06002_Voice_Call_Eme_Call_IntragNBintraFreq_HO
    [Documentation]   Check PM counters ...
    5GC000774_B_06_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_M55124C06002_Voice_Call_Eme_Call_IntragNBintraFreq_HO


5GC000774_B_07_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_M55124C06002_Voice_Call_IntergNBintraFreq_HO
    [Documentation]   Check PM counters ...
    5GC000774_B_07_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_M55124C06002_Voice_Call_IntergNBintraFreq_HO
