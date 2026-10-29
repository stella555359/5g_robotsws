*** Settings ***
Resource    CB013206_keywords.robot
Library     CB013206_keywords.py

Documentation
...    author: Łukasz Filipek
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
@{B1_COUNTERS_ID}=    ${COUNTER_ID_RAB_REL_NRM_MENB_INSES_PMQAP}
...                ${COUNTER_ID_NX2CC_RAB_REL_NRM_MENB_INSES}
...                ${COUNTER_ID_NX2CC_RAB_REL_NORM_MENB_PMQAP}

*** Keywords ***
CB013206-B-B1_Norm_Menb_Insession_Release
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start Data Traffic For Nsa Ue    ue_id=11    bearer=2    direction=ul    mbps=40
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Check Traffic On Mcg And Scg Leg    ue_id=11    dir=ul
    Add Nr Cappa    ue_id=12
    Attach Ue To Enb    ue_id=12
    Start Gnb Addition Procedure    ue=12    bearer=2    target_cells=1    dc_type=split_scg
    Start Data Traffic For Nsa Ue    ue_id=12    bearer=2    direction=dl    mbps=40
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Trigger Handover To Second Cell    ue_id=12
    Check Traffic On Mcg And Scg Leg    ue_id=12    dir=dl
    Wait For Normal Ue Release Initiated By MenB    ue_id=11
    Check In Session Status    status=True
    Wait For Normal Ue Release Initiated By MenB    ue_id=12
    Wait For Next Full Pm Interval
    Check If Cell And Pmqap Has Expected Value    counters_id_list=@{B1_COUNTERS_ID}    expected_value=1
