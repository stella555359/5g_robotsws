*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         This subfeature introduces successful establishment of MN terminated split bearer - additional content.
...         One NR-DC-SN cell, that can act as PSCell in NR-DC, is successfully activated. After Initial Context Setup,
...         NR DC establishment is attempted for NR DC eligible UEs, MN terminated Split Bearer Addition procedure is
...         successfully completed and bearer type is successfully changed from MCG to MN terminated split bearer.
...
...      == TEST SET NAME ==
...         CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...
...      == TESTING SPLIT==
...         CB008717-A NR-DC Cell Activation for a Secondary Node
...         CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...         CB008717-C UE Release due to AMF Context Release
...         CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...         CB008717-E UE Release without bearer takeback
...         CB008717-G Cell Management for Secondary Node
...         CB008717-H Configuration and Reception of A4 measurements
...         CB008717-I Successful Measurement based PSCell Addition
...         CB008717-J Interaction with event A4
...         CB008717-M Mobilty on PCell
...
...      == AUTHORS ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...       - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...       - CB008717 CFAM
...
...      == HISTORY ==
...         [25.01.2023] - Create Test Suite

Resource    ./resources/CB008717-common_keywords.robot

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

${nrcell2_pci}=  52

*** Test Cases ***
CB008717-D-B6a_handling_a4SupervisionTimer_expiration_after_unsuccessfull_PSCell_Addition_attempts
    [Documentation]
    ...  DESCRIPTION: This user scenario describes that gNB PSCell addition procedure fails due to maxNumOfNrDcSnUsers=0 limit
    ...  exceeded. a4SupervisionTimer expires, gNB performs the a4SupervisionTimer expiry event so RRC: RRCReconfiguration
    ...  message with NR-DC A4 measurements deactivation is sent.
    ...
    ...  PRECONDITION:
    ...     Configuration same as in CB008717-D-B1c scenario with difference in:
    ...          -NRBTS/timerRRCGuard is set to 2500
    ...         -NRBTS/NRCELL-2/a4PeriodicMeasControlSA/a4Fr2SupervisionTimer is set to 6000
    ...         -NRBTS/NRCELL-1/maxNumOfNrDcSnUsers is set to 0
    ...         -NRBTS/NRCELL-3/maxNumOfNrDcSnUsers is set to 0
    ...         -UE-NR-Capability same as in CB008717-D-B1c
    ...
    ...  POSTCONDITION:
    ...     - UE1 is in RRC: CONNECTED
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17361
    ...       *BACKLOG ID: FCA_5G_L2L3-104953
    ...
    ...  REQUIRED LOGS: NGAP, F1AP, E1AP, RRC
    ...
    ...  CONTACTS:
    ...  Test owner         : Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:              https://gates.nsn-net.net/view/00025f8e#o=1052
    ...  Sub-feature refinement: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...        [25.01.2023] - Created TC
    ...        [26.05.2023] - Test Case added to CRT after review

    [Tags]   D_B6a

    [Setup]  Prepare test environment D-B6a

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE1

    Expect that NR-DC procedure fails due to maxNumOfNrDcSnUsers exceeded on PSCell for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify that NR-DC procedure fails due to maxNumOfNrDcSnUsers exceeded on PSCell for UE1, gNB2 and AMF1

    Expect that a4Fr2SupervisionTimer expiry event is performed for UE1, gNB2 and AMF1
    Sleep   3s   Wait until a4Fr2SupervisionTimer expiration
    Verify that a4Fr2SupervisionTimer expiry event is performed for UE1, gNB2 and AMF1

    [Teardown]  Cleanup after test D-B6a
