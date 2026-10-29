*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature describes scenarios with sk-Counter incrementation and reset, unsuccesful PSCell Addition resulting in takeback.
...
...      == TEST SET NAME ==
...      CB008490-DB PSCell Addition (functionality requiring takeback)
...
...      == TESTING SPLIT ==
...      CB008490-DB#B101: sk-Counter incrementation and reset
...      CB008490-DB#B201: Unsuccessful inter-gNB NR-DC PSCell Addition in MN
...      CB008490-DB#B301: Unsuccessful inter-gNB NR-DC PSCell Addition in SN
...      CB008490-DB#B401: Concurrency handling in SN
...
...      == TESTING SCOPE ==
...      CB008490-DB#B101: sk-Counter incrementation and reset
...      1. CB008490-SR-DB-B101_1 - SN Counter reset after successful RRC Reestablishment to the same serving cell
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM
...
...      == HISTORY ==
...      [21.11.2024] - Create Test Suite
...      [26.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922695)

Resource    ../resources/CB008490-common_keywords.robot
Resource    ../resources/CB008490_setup_and_teardowns.robot
Resource    ../resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIO_UPIP_activated.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257_simSN.xml


*** Test Cases ***
CB008490-SR-DB-B101_1 - SN Counter reset after successful RRC Reestablishment to the same serving cell
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test scenario verifies that MN gNB resets SN Counter (sk-Counter) value to 0 after successful
    ...  RRC Reestablishment of UE to the same serving cell.
    ...
    ...  == PRECONDITION ==
    ...    - NRBTS.actUplaneIntegrityProtection is set to "SA" in the gNB acting as MN
    ...    - NRBTS.rrcReestabTypeSA is set to sameGNB in the gNB acting as MN
    ...    - Sim SN gNB supports Integrity Protection, but due to limitations only NIA-0 algorithm is allowed
    ...    - InitialContextSetupRequest -> PDUSessionResourceSetupListCxtReq -> PDUSessionResourceSetupRequestTransfer -> SecurityIndication ->
    ...      integrityProtectionIndication = required
    ...    - UPIP is activated on the MN for PDU
    ...    - UE1 is connected to MN gNB after takeback procedure (internal sk-Counter value = 1) with A4 measurement installed
    ...
    ...  == POSTCONDITION ==
    ...    - sk-Counter used in PSCell Addition procedure after RRC Reestablishment is set to 0
    ...    - UE1 with established NR-DC connection
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - simulated gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26233
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DB#B1: [MN] Security key generation in Inter-gNB NR-DC Subsequent PSCell Addition (Access Stratum Security related aspect
     ...    - sk-Counter incrementation) - main scenario
    ...
    ...  == HISTORY ==
    ...  [21.11.2024] - Create Test Suite
    ...  [26.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922695)

    [Setup]  Prepare test environment CB008490-DB-B101_1

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    Set expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE1, MN gNB2
    UE1 sends RRC:SCGFailureInformation to MN gNB2
    Verify expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE1, MN gNB2

    sleep    2
    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    Verify in RRCReconfiguration that sk-Counter is set to 1 for UE1

    Set expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE1, MN gNB2
    UE1 sends RRC:SCGFailureInformation to MN gNB2
    Verify expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE1, MN gNB2

    Execute egate command    cmd=amf_ue_ics_param id=1 ue=1 indexToRFSP=1
    Trigger reestablishment for UE1 to gNB2 NRCELL-1
    sleep    4
    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=3 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    Verify in RRCReconfiguration that sk-Counter is set to 0 for UE1

    [Teardown]  CB008490-DB-B101_1 cleanup
