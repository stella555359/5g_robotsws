*** Settings ***
Resource    CB013206_keywords.robot
Library     CB013206_keywords.py

Documentation
...    author: Łukasz Filipek
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   12s

*** Keywords ***
CB013206-B-B3_Abnorm_Menb_Insession_Release_Non_Pmqap
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start Data Traffic For Nsa Ue    ue_id=11    bearer=2    direction=dl    mbps=10
    Check Traffic On Mcg And Scg Leg    ue_id=11    dir=dl
    Add Nr Cappa    ue_id=12
    Attach Ue To Enb    ue_id=12
    Start Gnb Addition Procedure    ue=12    bearer=2    target_cells=1    dc_type=split_scg
    Start Data Traffic For Nsa Ue    ue_id=12    bearer=2    direction=dl    mbps=10
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Trigger Handover to second cell    ue_id=12
    Check Traffic On Mcg And Scg Leg    ue_id=12    dir=dl
    Detach Ue    ue_id=11
    Check In Session Status    status=True
    Wait For Abnormal Ue Release Initiated By MenB    ue_id=12
    Verify Normal In-Session Release Counter Was Incremented By MeNB For UE11
    Verify Abnormal In-Session Release Counter Was Incremented By MeNB For UE12
    Verify Abnormal Release Counter Was Incremented By MeNB For PMQAP For UE12

Verify Normal In-Session Release Counter Was Incremented By MeNB For UE11
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NX2CC_RAB_REL_NRM_MENB_INSES}
    ...    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}

Verify Abnormal In-Session Release Counter Was Incremented By MeNB For UE12
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNRM_MENB_INSES}
    ...    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2    filepath=${PM_COUNTERS}

Verify Abnormal Release Counter Was Incremented By MeNB For PMQAP For UE12
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNORM_MENB}
    ...    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2    filepath=${PM_COUNTERS}