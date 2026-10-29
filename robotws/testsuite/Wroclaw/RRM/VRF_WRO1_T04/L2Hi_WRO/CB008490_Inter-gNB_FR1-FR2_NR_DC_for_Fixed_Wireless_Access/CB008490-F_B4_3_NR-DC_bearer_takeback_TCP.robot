*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R3

*** Keywords ***
CB008490-F_B4_1_NR-DC_bearer_takeback_TCP
    Register Nrdc Ue With Default Pdu Session
    Start Dl Tcp Traffic
    Check Data Traffic Before PSCell Addition
    Send A4 Measurement And Trigger Pscell Addition
    Check Data Traffic After PSCell Addition
    Trigger Max Rlc Retx
    Check Data Traffic Before PSCell Addition
    Send A4 Measurement And Trigger Pscell Addition
    Check Data Traffic After PSCell Addition
