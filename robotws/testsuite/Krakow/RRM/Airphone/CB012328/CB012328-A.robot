*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This feature extends the inter-gNB NR-DC (CB008490) with limited mobility support.
...      The NR-DC allowed UEs can be configured with mobility related measurements when entering the cell. The UEs are also
...      configured with NR-DC FR2 A4 if not conflicting with other measurements.
...      If mobility is needed, before the NR-DC is set-up, it's performed in a regular way.
...      NR-DC measurements can not co-exist with inter-frequency and inter-RAT measurements for coverage-based mobility.
...      In case both measurement types are needed, NR-DC measurements are not activated or released.
...      When NR-DC is configured, no mobility is possible until SCG is released.
...      When A3/A5 intra frequency report is received, the gNB triggers SN takeback. Handover is again possible after SCG is
...      released.
...      In case of A2 report for inter-frequency/inter-RAT mobility activation. The gNB triggers SN takeback and configures
...      the inter-frequency/inter-RAT measurements as needed.
...      NR-DC can be added again, if HO doesn't happen, or FR1 inter-freq/inter-RAT measurements are released, after
...      another round of A4 FR2 measurements.
...      The feature also allows to disable the check for RFSP and configure NR-DC for all capable devices.
...      The feature allows to prevent NR-DC for UEs having another PDU session with 5QI1 and 5GI2 bearers.
...      PM counters are updated so that it's possible to measure the number of NR-DC take-backs due to measurement reception.
...      The feature is activated automatically if NR-DC is activated in the cell. With this feature, NR-DC can be additionally
...      enabled/disabled per UE profile.
...
...      == TEST SET NAME ==
...      CB012328-A NR-DC eligibility determination and measurements activation
...
...      == TESTING SPLIT ==
...      CB012328-A#B0601: Start A4 retry timer after successful RRC Re-establishment to the same serving cell
...      CB012328-A#B0602: Start A4 retry timer after successful RRC Re-establishment to the different serving cell
...      in the same DU of same gNB
...      CB012328-A#B0701: Activate inter-frequency A4 measurements for NR-DC PSCell Addition after successful
...      transition of suspended UE in RRC_INACTIVE state to RRC_CONNECTED
...      CB012328-A#IWK0101: Early DRX Setup (CB013233) for the NR-DC eligible UE with/without support of independent
...      measurement gaps
...
...      == CONTACTS ==
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         USCB012328-A#B06: Start A4 retry timer after successful RRC Re-establishment
...         12813625: USCB012328-A#B07: Activate inter-frequency A4 measurements for NR-DC PSCell Addition after
...         successful transition of suspended UE in RRC_INACTIVE state to RRC_CONNECTED
...         12827437: USCB012328-A#IWK01: Early DRX Setup ( CB013233) for the NR-DC eligible UE without support of
...         independent measurement gaps.
...
...      == HISTORY ==
...      [16.12.2025] - Create Test Suite
...      [xx.xx.xxxx] - Review closed ()
...
Resource    resources/CB012328-common_keywords.robot
Resource    resources/CB012328_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB012328/sfc_3cells_n78_n78_n257_simSN_GMC.xml
${AP_XML}=                Krakow/CB012328/iphy_3cells_n78_n78_n257_simSN.xml
${yaml_actDRX}=           ${CURDIR}/config/yaml/actDRX.yaml


*** Test Cases ***
CB012328-A CRT
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Merged testcases:
    ...  CB012328-A-IWK0101 Early DRX Setup (CB013233) for the NR-DC eligible UE with or without support of
    ...  independent measurement gaps
    ...  CB012328-A-B0601 Start A4 retry timer after successful RRC Re-establishment to the same serving cell
    ...  CB012328-A-B0602 Start A4 retry timer after successful RRC Re-establishment to the different serving cell
    ...  in the same DU of same gNB
    ...  CB012328-A-B0701 Activate inter-frequency A4 measurements for NR-DC PSCell Addition after successful
    ...  transition from RRC_INACTIVE to RRC_CONNECTED
    ...
    ...  See the description of corresponding test cases
    ...
    ...  == PRECONDITION ==
    ...  See preconditions of corresponding test cases
    ...
    ...  == TEST STEPS ==
    ...  See corresponding test cases
    ...
    ...  == POSTCONDITION ==
    ...  See corresponding test cases
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_SN
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB module MN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 12813623;12827124;12813625;12827437;12827449
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  12827437: USCB012328-A#IWK01: Early DRX Setup ( CB013233) for the NR-DC eligible UE without support of
    ...  independent measurement gaps.
    ...  12813623: USCB012328-A#B06: Start A4 retry timer after successful RRC Re-establishment
    ...  12813623: USCB012328-A#B06: Start A4 retry timer after successful RRC Re-establishment
    ...  12813625: USCB012328-A#B07: Activate inter-frequency A4 measurements for NR-DC PSCell Addition after
    ...  successful transition of suspended UE in RRC_INACTIVE state to RRC_CONNECTED
    ...  == HISTORY ==
    ...  [22.03.2026] - Create Test Case

    [Setup]  Prepare test environment CB012328-A

# CB012328-A-IWK0101 Early DRX Setup (CB013233) for the NR-DC eligible UE with or without support of independent measurement gaps
    Log To Console    Start CB012328-A-IWK0101

    Activate CB013233    #DRX setup
    #UE15 NOT supporting DRX
    Attach UE15 without ICS to MN gNB2 NRCELL-1
    Add to UE15 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE15 in RRCReconfiguration message
    Verify that DRX was not configured for UE15
    Verify that A4 measurement was activated in second RRCReconfiguration message for UE15

    #UE2 supportins DRX
    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Add to UE1 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE1 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
    Verify that DRX was configured for UE1

    Trigger UE1 to send deregister request
    Trigger UE15 to send deregister request
    Deactivate CB013233

# CB012328-A-B0601 Start A4 retry timer after successful RRC Re-establishment to the same serving cell
    Log To Console    Start CB012328-A-B0601

    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Add to UE1 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE1 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
    Trigger reestablishment for UE1 to gNB2 NRCELL-1
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
#    wait until a4RetryTimer expires ~10s
    Verify A4 meauserment activation for UE1 with timeout=12s

    Trigger UE1 to send deregister request

# CB012328-A-B0602 Start A4 retry timer after successful RRC Re-establishment to the different serving cell in the same DU of same gNB
    Log To Console    Start CB012328-A-B0602

    Attach UE1 without ICS to MN gNB2 NRCELL-2
    Add to UE1 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE1 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
    Trigger reestablishment for UE1 to gNB2 NRCELL-1
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
    #wait until a4RetryTimer expires ~10s
    Verify A4 meauserment activation for UE1 with timeout=12s

    Trigger UE1 to send deregister request

# CB012328-A-B0701 Activate inter-frequency A4 measurements for NR-DC PSCell Addition after successful transition from RRC_INACTIVE to RRC_CONNECTED
    Log To Console    Start CB012328-A-B0701

    Attach UE16 without ICS to MN gNB2 NRCELL-1
    Add to UE16 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE16 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE16 in RRCReconfiguration message
    Trigger UE16 to send UAI with RRC preferred state of inactive
    sleep    2
    Trigger UE16 to enter ACTIVE state with A4 configuration
    Verify that A3, A5, A2 meauserments were configured for UE16 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE16 in RRCReconfiguration message
    Verify that A4 measurement was activated in second RRCReconfiguration message for UE16

    Trigger UE16 to send deregister request

    [Teardown]  CB012328-SR-A cleanup


CB012328-A-IWK0101 Early DRX Setup (CB013233) for the NR-DC eligible UE with or without support of independent measurement gaps
    [Tags]    A1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario verifies the behavior of the gNB which configures DRX for the UE during ICS, without
    ...  checking its NR-DC eligibility. In case the UE does not support independent gaps, then DRX has to be released
    ...  when NR-DC A4 measurements are being configured with measurement gaps.
    ...  Alternate Scenario presents that for the UE supporting independent gaps, the DRX configuration is kept while
    ...  A4 for NR-DC is being configured for the UE.
    ...
    ...  == PRECONDITION ==
    ...  - 12750563: CB012328 Common preconditions
    ...  UE supports bandFR1#1 and bandFR2#1, as well as NR-DC band combination (bandFR1#1-bandFR2#1,
    ...  e.g. DC_n77A-n257M), that can accommodate saCell#1 and nrDcCell#1.
    ...  NRCELL-1.actEarlyDrxSetup = true
    ...  UE1 does not support independent gaps
    ...  UE2 does supports independent gaps
    ...
    ...  == TEST STEPS ==
    ...  UE1 performs ICS with pdu session setup
    ...  Verify measurements activation and DRX setup for UE1
    ...  UE2 performs ICS with pdu session setup
    ...  Verify measurements activation and DRX setup for UE2
    ...
    ...  == POSTCONDITION ==
    ...  UE1 has established PDU session, A2, A3, A4, A5 measurements are activated, DRX is not configured for UE1
    ...  UE2 has established PDU session, A2, A3, A4, A5 measurements are activated, DRX is configured for UE2
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_SN
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB module MN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 12827437, 12827449
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  12827437: USCB012328-A#IWK01: Early DRX Setup ( CB013233) for the NR-DC eligible UE without support of
    ...  independent measurement gaps.
    ...
    ...  == HISTORY ==
    ...  [28.11.2024] - Create Test Suite
    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)

    [Setup]  Prepare test environment CB012328-A

    Activate CB013233    #DRX setup
    #UE15 NOT supporting DRX
    Attach UE15 without ICS to MN gNB2 NRCELL-1
    Add to UE15 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE15 in RRCReconfiguration message
    Verify that DRX was not configured for UE15
    Verify that A4 measurement was activated in second RRCReconfiguration message for UE15

    #UE2 supportins DRX
    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Add to UE1 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE1 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
    Verify that DRX was configured for UE1

    [Teardown]  CB012328-SR-A cleanup

CB012328-A-B0601 Start A4 retry timer after successful RRC Re-establishment to the same serving cell
    [Tags]    A2
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario verifies the behavior of the gNB which starts a4retryTimer after UE re-establishes
    ...  successfully to the same serving cell in same DU in same gNB (main scenario) and A2/A3/A5 measurements
    ...  configuration for mobility purpose are not blocked to UE during the Reestablishment procedure.
    ...
    ...  == PRECONDITION ==
    ...  - 12750563: CB012328 Common preconditions
    ...  UE supports bandFR1#1 and bandFR2#1, as well as NR-DC band combination (bandFR1#1-bandFR2#1,
    ...  e.g. DC_n77A-n257M), that can accommodate saCell#1 and nrDcCell#1.
    ...  UE1 is in the RRC connected state in saCell#1 and not in NR-DC mode
    ...
    ...  == TEST STEPS ==
    ...  UE1 expirience RLF and performs reestablishment to the same cell
    ...
    ...  == POSTCONDITION ==
    ...  UE1 has established PDU session, A2, A3, A5 measurements are activated, A4 retry timer is running
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_SN
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB module MN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 12827124
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  12813623: USCB012328-A#B06: Start A4 retry timer after successful RRC Re-establishment
    ...
    ...  == HISTORY ==
    ...  [28.11.2024] - Create Test Suite
    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)

    [Setup]  Prepare test environment CB012328-A

    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Add to UE1 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE1 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
    Trigger reestablishment for UE1 to gNB2 NRCELL-1
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
#    wait until a4RetryTimer expires ~10s
    Verify A4 meauserment activation for UE1 with timeout=12s

    [Teardown]  CB012328-SR-A cleanup

CB012328-A-B0602 Start A4 retry timer after successful RRC Re-establishment to the different serving cell in the same DU of same gNB
    [Tags]    A3
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario verifies the behavior of the gNB which starts a4retryTimer after UE re-establishes
    ...  successfully to the different cell in same DU in same gNB and A2/A3/A5 measurements
    ...  configuration for mobility purpose are not blocked to UE during the Reestablishment procedure.
    ...
    ...  == PRECONDITION ==
    ...  - 12750563: CB012328 Common preconditions
    ...  UE supports bandFR1#1 and bandFR2#1, as well as NR-DC band combination (bandFR1#1-bandFR2#1,
    ...  e.g. DC_n77A-n257M), that can accommodate saCell#1 and nrDcCell#1.
    ...  UE1 is in the RRC connected state in saCell#1 and not in NR-DC mode
    ...
    ...  == TEST STEPS ==
    ...  UE1 expirience RLF and performs reestablishment to the different cell in the same gNB
    ...
    ...  == POSTCONDITION ==
    ...  UE1 has established PDU session, A2, A3, A5 measurements are activated, A4 retry timer is running
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_SN
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB module MN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 12813623
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  12813623: USCB012328-A#B06: Start A4 retry timer after successful RRC Re-establishment
    ...
    ...  == HISTORY ==
    ...  [28.11.2024] - Create Test Suite
    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)

    [Setup]  Prepare test environment CB012328-A

    Attach UE1 without ICS to MN gNB2 NRCELL-2
    Add to UE1 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE1 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
    Trigger reestablishment for UE1 to gNB2 NRCELL-1
    Verify that A4 was NOT configured for UE1 in RRCReconfiguration message
    #wait until a4RetryTimer expires ~10s
    Verify A4 meauserment activation for UE1 with timeout=12s

    [Teardown]  CB012328-SR-A cleanup

CB012328-A-B0701 Activate inter-frequency A4 measurements for NR-DC PSCell Addition after successful transition from RRC_INACTIVE to RRC_CONNECTED
    [Tags]    A4
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario verifies the behavior of the gNB which starts a4retryTimer after UE re-establishes
    ...  successfully to the different cell in same DU in same gNB and A2/A3/A5 measurements
    ...  configuration for mobility purpose are not blocked to UE during the Reestablishment procedure.
    ...
    ...  == PRECONDITION ==
    ...  - 12750563: CB012328 Common preconditions
    ...  UE supports bandFR1#1 and bandFR2#1, as well as NR-DC band combination (bandFR1#1-bandFR2#1,
    ...  e.g. DC_n77A-n257M), that can accommodate saCell#1 and nrDcCell#1.
    ...  UE1 is in the RRC connected state in saCell#1 and not in NR-DC mode
    ...
    ...  == TEST STEPS ==
    ...  UE1 changes state from Connted to Inactive
    ...  RRC Connection Resume was received from UE1
    ...  UE1 transitions to Connected
    ...
    ...  == POSTCONDITION ==
    ...  UE1 has established PDU session, A2, A3, A4, A5 measurements are activated
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_SN
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB module MN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 12813625
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  12813625: USCB012328-A#B07: Activate inter-frequency A4 measurements for NR-DC PSCell Addition after
    ...  successful transition of suspended UE in RRC_INACTIVE state to RRC_CONNECTED
    ...
    ...  == HISTORY ==
    ...  [28.11.2024] - Create Test Suite
    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)

    [Setup]  Prepare test environment CB012328-A

    Attach UE16 without ICS to MN gNB2 NRCELL-1
    Add to UE16 initial PDU session
    Verify that A3, A5, A2 meauserments were configured for UE16 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE16 in RRCReconfiguration message
    Trigger UE16 to send UAI with RRC preferred state of inactive
    sleep    2
    Trigger UE16 to enter ACTIVE state with A4 configuration
    Verify that A3, A5, A2 meauserments were configured for UE16 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE16 in RRCReconfiguration message
    Verify that A4 measurement was activated in second RRCReconfiguration message for UE16

    [Teardown]  CB012328-SR-A cleanup

#CB012328-A Exploratory
#    [Tags]    Exploratory
#    [Documentation]
#    ...  == DESCRIPTION ==
#    ...  Perform scenario from items A-B0601 and A-B0602 for large number of UEs
#    ...
#    ...  == PRECONDITION ==
#    ...  - 12750563: CB012328 Common preconditions
#    ...  UE supports bandFR1#1 and bandFR2#1, as well as NR-DC band combination (bandFR1#1-bandFR2#1,
#    ...  e.g. DC_n77A-n257M), that can accommodate saCell#1 and nrDcCell#1.
#    ...  UE1-500 is in the RRC connected state in saCell#1 and not in NR-DC mode
#    ...
#    ...  == TEST STEPS ==
#    ...  UE1-500 expirience RLF and performs reestablishment to the different cell in the same gNB
#    ...  UE1-500 expirience RLF and performs reestablishment to the same cell
#    ...
#    ...  == POSTCONDITION ==
#    ...  UE1-500 has established PDU session, A2, A3, A5 measurements are activated, A4 retry timer is running
#    ...
#    ...  == TESTING TOOLS ==
#    ...    AirPhone, 5GCSim, UTE
#    ...
#    ...  == TEST ENVIRONMENT ==
#    ...  - gNB simulated BTS sim_SN
#    ...  - gNB classical BTS in SA mode as MN - gNB_MN
#    ...  - gNB module MN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
#    ...  - UE configured in SA, TDD
#    ...
#    ...  == REQUIREMENTS COVERAGE ==
#    ...  REQUIREMENTS IN SCOPE: 12813625
#    ...
#    ...  == REQUIRED LOGS ==
#    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
#    ...
#    ...  == CONTACTS ==
#    ...     - Maciej Madej          <maciej.madej@nokia.com>
#    ...
#    ...  == MAINTAINER ==
#    ...     - Maciej Madej          <maciej.madej@nokia.com>
#    ...
#    ...  == REFERENCES ==
#    ...  12813625: USCB012328-A#B07: Activate inter-frequency A4 measurements for NR-DC PSCell Addition after
#    ...  successful transition of suspended UE in RRC_INACTIVE state to RRC_CONNECTED
#    ...
#    ...  == HISTORY ==
#    ...  [28.11.2024] - Create Test Suite
#    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)
#
#    [Setup]  Prepare test environment CB012328-A
#
#    Attach UE1-500 without ICS to MN gNB2 NRCELL-1
#    Add to UE1-500 initial PDU session with ICS
#    Trigger reestablishment for UE1-500 to gNB2 NRCELL-1
#    Verify that A3, A5, A2 was configured for UE1-500
#    Verify that A4 was NOT configured for UE1-500
#    #wait until a4RetryTimer expires ~10s
#    Verify A4 meauserment activation for UE1-500 with timeout=12s
#    Detach UE1-500
#
#    Attach UE1-500 without ICS to MN gNB2 NRCELL-1
#    Add to UE1-500 initial PDU session with ICS
#    Trigger reestablishment for UE1-500 to gNB2 NRCELL-2
#    Verify that A3, A5, A2 was configured for UE1-500
#    Verify that A4 was NOT configured for UE1-500
#    #wait until a4RetryTimer expires ~10s
#    Verify A4 meauserment activation for UE1-500 with timeout=12s
#    Detach UE1-500
#
#    [Teardown]  CB012328-SR-A cleanup
