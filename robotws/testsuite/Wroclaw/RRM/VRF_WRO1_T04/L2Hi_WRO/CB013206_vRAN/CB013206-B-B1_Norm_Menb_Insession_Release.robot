*** Settings ***
Resource     keywords_CB013206_AiC.robot

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 25R2


*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s
${a3_params}=    event=A3 srsrp_nr=11 srsrq_nr=11 ssinr_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30

*** Keywords ***
CB013206-B-B1_Norm_Menb_Insession_Release_Cloud
    Attach Ue And Perform SgNBAdditionRequest
    Start Data Traffic For Nsa Ue    ue_id=11    bearer=2    direction=ul    mbps=20
    Sleep    ${TRAFFIC_DURATION_SEC}
    Check Traffic On Mcg And Scg Leg    ue_id=11    dir=ul
    Attach Ue And Perform SgNBAdditionRequest    ue_id=12
    Start Data Traffic For Nsa Ue    ue_id=12    bearer=2    direction=dl    mbps=20
    Sleep    ${TRAFFIC_DURATION_SEC}
    Trigger Handover To Second Cell    ue_id=12
    Check Traffic On Mcg And Scg Leg    ue_id=12    dir=dl
    Check Ue Location
    Wait For Normal Ue Release Initiated By MenB    ue_id=11
    Wait For Normal Ue Release Initiated By MenB    ue_id=12
    Check Pm Counters For Normal Releases Initiated By Menb


Trigger Handover to second cell
    [Arguments]   ${ue_id}
    Execute Egate Command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 ${a3_params}
    Sleep    2s

Check Ue Location
    Execute Egate Command   cmd=ue_disp id=11 type=cell
    Execute Egate Command   cmd=ue_disp id=12 type=cell

Check Pm Counters For Normal Releases Initiated By Menb
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...    counter_id=${COUNTER_ID_NX2CC_RAB_REL_NRM_MENB_INSES}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1
    ...    counter_id=${COUNTER_ID_RAB_REL_NRM_MENB_INSES_PMQAP}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1
    ...    counter_id=${COUNTER_ID_NX2CC_RAB_REL_NORM_MENB_PMQAP}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/MCC-311/MNC-489/ECI-19088897/MCC-311/MNC-489
    ...    counter_id=${COUNTER_ID_NX2CC_RAB_REL_NORM_MENB_NRREL}
