*** Settings ***
Resource    CB013206_keywords.robot
Library     CB013206_keywords.py

Documentation
...    author: Łukasz Filipek
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   12s
@{B2_COUNTERS_ID}=    ${COUNTER_ID_NX2CC_RAB_REL_NORM_MENB_PMQAP}    ${COUNTER_ID_NX2CC_RAB_REL_NORM_MENB_NRREL}

*** Keywords ***
CB013206-B-B2_Norm_Menb_Inactivity_Cause_Release
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Add Nr Cappa    ue_id=12
    Attach Ue To Enb    ue_id=12
    Start Gnb Addition Procedure    ue=12    bearer=2    target_cells=1    dc_type=split_scg
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Wait For Normal Ue Release Initiated By MenB    ue_id=11
    Trigger Handover to second cell    ue_id=12
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=enb_ue_dc_release ue=12 by=enb cause=MISC_CauseMisc_unspecified
    Wait For Next Full Pm Interval
    Check If Cell And Pmqap Has Expected Value    counters_id_list=@{B2_COUNTERS_ID}    expected_value=1

