*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    release: 25R1

*** Keywords ***
CB008490-B_B3_2_Large_data_transfer_in_downlink_TCP
    Register Nrdc Ue With Default Pdu Session
    Start Dl Tcp Traffic
    Check Data Traffic Before PSCell Addition
    Send A4 Measurement And Trigger Pscell Addition
    Check Data Traffic After PSCell Addition
