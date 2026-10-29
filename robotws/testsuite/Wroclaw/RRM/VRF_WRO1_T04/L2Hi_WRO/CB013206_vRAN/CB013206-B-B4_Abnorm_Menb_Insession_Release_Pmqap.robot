*** Settings ***
Resource     keywords_CB013206_AiC.robot

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 25R2

*** Variables ***
${TRAFFIC_DURATION_SEC}=   12s

*** Keywords ***
CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap_Cloud
    Attach Ue And Perform SgNBAdditionRequest
    Start Data Traffic For Nsa Ue    ue_id=11    bearer=2    direction=dl    mbps=50
    Sleep    ${TRAFFIC_DURATION_SEC}
    Check Traffic On Mcg And Scg Leg    ue_id=11    dir=dl
    Wait For Abnormal Ue Release Initiated By MenB    ue_id=11
    Check Pm Counters For Abnormal Releases Initiated By Menb


Check Pm Counters For Abnormal Releases Initiated By Menb
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNRM_MENB_INSES}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1
    ...    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNRM_MENB_INSES_PMQAP}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNORM_MENB}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/MCC-311/MNC-489/ECI-19088897/MCC-311/MNC-489
    ...    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNOR_MENB_NRREL}
