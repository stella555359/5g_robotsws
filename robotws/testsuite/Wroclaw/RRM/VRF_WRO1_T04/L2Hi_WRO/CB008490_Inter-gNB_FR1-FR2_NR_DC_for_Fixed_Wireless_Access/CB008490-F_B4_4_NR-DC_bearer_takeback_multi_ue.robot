*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R3

*** Variables ***
${TRAFFIC_DURATION_SEC_F_B4}=   2m
${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_F_B4}=   2m

*** Keywords ***
CB008490-F_B4_4_NR-DC_bearer_takeback_multi_ue
    Register Multi Nrdc Ues With Default Pdu Session
    Start Udp Traffic In DL For 4 Ues
    Check Data Traffic After PSCell Addition For Mue
    Trigger Max Rlc Retx For Multi Ue
    Check Data Traffic On Mcg For Mue

Check Data Traffic After PSCell Addition For Mue
    Sleep    ${TRAFFIC_DURATION_SEC_F_B4}
    Check Data Traffic On Mcg For Mue
    Check Data Traffic On Scg For Mue

Trigger Max Rlc Retx For Multi Ue
     FOR    ${index}    IN RANGE    1    5
             Trigger Max Rlc Retx    ue_id=${index}
             Log    ${index}
     END
