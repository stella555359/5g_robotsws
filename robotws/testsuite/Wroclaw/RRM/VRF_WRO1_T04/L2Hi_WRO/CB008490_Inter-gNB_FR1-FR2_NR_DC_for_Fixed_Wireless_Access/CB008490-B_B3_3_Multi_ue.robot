*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_SEC_B3_3}=   2m
${TRAFFIC_DURATION_BEFORE_PSCELL_SEC}=   2m

*** Keywords ***
CB008490-B_B3_3_Multi_ue
    Register Multi Nrdc Ues With Default Pdu Session
    Start Udp Traffic In DL For 4 Ues
    Check Data Traffic For Mue After PSCell Addition

Check Data Traffic For Mue After PSCell Addition
    Sleep    ${TRAFFIC_DURATION_SEC_B3_3}
    Check Data Traffic On Mcg For Mue
    Check Data Traffic On Scg For Mue




