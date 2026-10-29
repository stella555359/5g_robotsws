*** Settings ***
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
...    release:

*** Keywords ***
CB008717-B_B4_B7_DL_and_UL_Ping
    Register Nrdc Ue With Default Pdu Session With A4
    Register Legacy Ue With Default Pdu Session
    Dl Ping Delay Should Be Similar For Nrdc And Legacy Ue
    Ul Ping Delay Should Be Similar For Nrdc And Legacy Ue

Register Legacy Ue With Default Pdu Session
    Register Ue With Default Pdu Session    ue_id=41     pdu_id=15    gw=41

Dl Ping Delay Should Be Similar For Nrdc And Legacy Ue
    Ping Delay Should Be Similar For Nrdc And Legacy Ue    nrdc_ip=1.2.4.2
    ...                                                    legacy_ip=1.2.4.3

Ul Ping Delay Should Be Similar For Nrdc And Legacy Ue
    Ping Delay Should Be Similar For Nrdc And Legacy Ue    nrdc_ip=72.23.0.1
    ...                                                    legacy_ip=72.23.41.1
