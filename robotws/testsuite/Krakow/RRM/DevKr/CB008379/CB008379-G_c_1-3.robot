*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008379: GBR Services for SA
...
...      == TEST SET NAME ==
...         CB008379
...
...      == TESTING SPLIT==
...            CB008379-G_c
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Tomasz Pyrek <michal.szymakowski@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [04.04.2022] - Create Test Suite
...         [18.01.2023] - Switch to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Setup    drx=True

*** Variables ***
${LUA_CFG}=                            ${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008379-G-c_1 DRX-GBR interaction - non-GBR and GBR added - DRX reconfigured after non-VoNR GBR released
    [Tags]    G_c-1    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS without PDU session. PDU Session with single nonGBR QoS Flow and DRX profile is configured.
    ...  Second QoSFlow 5QI 2,3,4,71,72,76 or 5QI128..254 is setup. Drx profile is released when GBR is established.
    ...  Release GBR QoSFlow via Pdu Session modification procedure. Drx profile is restored to previous value.
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = true
    ...  - NRCELL-1.actCDrxVoNR = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxGBRTrafficLimit = 90% (default)
    ...  - NRDRB.maxDataRateGbrDl = 30 Mb/s
    ...  - NRDRB.maxDataRateGbrUl = 30 Mb/s
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_CP_MM_3021
    ...  == REQUIRED LOGS ==
    ...  - NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  - USCB008379-G#B3: GBR services interaction with DRX - disable DRX when GBR DRB is added
    ...  HISTORY:
    ...  [2022-04-15] initial testcase creation

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI2 for UE1 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI3 for UE2 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI4 for UE3 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI71 for UE4 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI72 for UE5 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI76 for UE6 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI128 for UE7 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI212 for UE8 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI254 for UE9 and DRX active


    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...     Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

CB008379-G-c_2 DRX-GBR interaction - non-GBR VoNR GBR added - DRX restored after non-VoNR and VoNR GBR released
    [Tags]    G_c-2    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS without PDU session. PDU Session with single nonGBR QoS Flow and DRX profile is configured.
    ...  Second QoSFlow 5QI 1 is setup. Drx profile is released and VoNR Drx profile is applied.
    ...  Third QoSFlow 5QI 2,3,4,71,72,76 or 5QI128..254 is setup. VoNR Drx profile is released when GBR is established.
    ...  Release GBR QoSFlow via Pdu Session modification procedure. VoNR Drx profile is restored to prevoius value.
    ...  Release VoNR GBR. Drx profile is restored to prevoius value.
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = true
    ...  - NRCELL-1.actCDrxVoNR = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxGBRTrafficLimit = 90% (default)
    ...  - NRDRB.maxDataRateGbrDl = 30 Mb/s
    ...  - NRDRB.maxDataRateGbrUl = 30 Mb/s
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_CP_MM_3021
    ...  == REQUIRED LOGS ==
    ...  - NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  - USCB008379-G#B3: GBR services interaction with DRX - disable DRX when GBR DRB is added
    ...  HISTORY:
    ...  [2022-04-15] initial testcase creation

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI2 for UE10 and DRX active
        Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI3 for UE11 and DRX active
        Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI4 for UE12 and DRX active
        Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI71 for UE13 and DRX active
        Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI72 for UE14 and DRX active
        Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI76 for UE15 and DRX active
        Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI128 for UE16 and DRX active
        Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI212 for UE17 and DRX active
        Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI254 for UE18 and DRX active

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...     Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

CB008379-G-c_3 DRX-GBR interaction - VoNR non-GBR GBR added - DRX reconfigured after non-VoNR GBR released
    [Tags]    G_c-3
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS without PDU session. PDU Session with single nonGBR + single 5QI1 GBR QoS Flow and Drx profile is configured.
    ...  Second QoSFlow 5QI 1 is setup. Drx profile is released and VoNR Drx profile is applied.
    ...  Third QoSFlow 5QI 2,3,4,71,72,76 or 5QI128..254 is setup. VoNR Drx profile is released when GBR is established.
    ...  Release VoNR GBR. No DRX reocnfiguration happens.
    ...  Release GBR QoSFlow via Pdu Session modification procedure. Drx profile is restored to prevoius value.
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = true
    ...  - NRCELL-1.actCDrxVoNR = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxGBRTrafficLimit = 90% (default)
    ...  - NRDRB.maxDataRateGbrDl = 30 Mb/s
    ...  - NRDRB.maxDataRateGbrUl = 30 Mb/s
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_CP_MM_3021
    ...  == REQUIRED LOGS ==
    ...  - NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  - USCB008379-G#B3: GBR services interaction with DRX - disable DRX when GBR DRB is added
    ...  HISTORY:
    ...  [2022-04-15] initial testcase creation

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Run Keyword And Continue On Failure
    ...   Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI2, release VoNR before 5QI for UE19 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI3, release VoNR before 5QI for UE20 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI4, release VoNR before 5QI for UE21 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI71, release VoNR before 5QI for UE22 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI72, release VoNR before 5QI for UE23 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI76, release VoNR before 5QI for UE24 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI128, release VoNR before 5QI for UE25 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI212, release VoNR before 5QI for UE26 and DRX active
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI254, release VoNR before 5QI for UE27 and DRX active

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...     Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
