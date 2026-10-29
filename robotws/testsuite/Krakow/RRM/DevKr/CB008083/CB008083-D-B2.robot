*** Settings ***
Documentation
...   == COPYRIGHT ==
...      Nokia Networks
...
...   == INTRODUCTION ==
...   The feature CB008083 will implement the following gNB enhancements on NG-C interface:
...   - Support of GUAMI Type IE in NG Setup Response and AMF Configuration Update messages
...   - Maximum number of NG Setup Retries increased to 1000 (from 100)
...   - Controlled shutdown of the NG-C link , i.e. SCTP association is gracefully shutdown when
...  	- NG-C link is locked, and NG Flex feature is not activated (currently supported when NG Flex feature is activated)
...  	- last SA cell is removed/deactivated
...   - Support of optional RAN Node Name IE in the NG Setup Request and RAN Configuration Update messages
...
...   == TEST SET NAME ==
...      CB008083_NG_enhancements_for_multi-vendor_AMF_support
...
...   == TESTING SPLIT==
...      CB008083-A Support of GUAMI Type IE in NG Setup Response and AMF Configuration Update messages
...      CB008083-B Maximum number of NG Setup Retries increased to 1000 (from 100)
...      CB008083-C Controlled shutdown of the NG-C link
...      CB008083-D Support of optional RAN Node Name IE in the NG Setup Request and RAN Configuration Update messages
...
...   == AUTHORS ==
...    - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...    - Marek Kieltyka <marek.kieltyka@nokia.com>
...    - Michal Szymakowski <michal.szymakowski@nokia.com>
...    - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...   == MAINTAINER ==
...    - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...   == REFERENCES ==
...    - CB008083 CFAM
...    - https://collab.ext.net.nokia.com/ui#review:id=874511
...
...   == HISTORY ==
...      [07.12.2022] - Create Test Suite

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run Setup
...    number_of_amfs=3
...    gnbcuname='gNB_D_B2'
...    f1ap=True
...    setup_aliases=True

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_TC6.lua
#${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim_1amf_TC7.lua

*** Test Cases ***
CB008083-D-B2 gNBCuName configured during startup NGC setup gNBCuName deleted triggers update without name
    [Tags]    D_B2_1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Test verifies that flows: E1AP gNB-CU-CP-ConfigurationUpdate and NGAP rANConfigurationUpdate,
    ...  are sent 1 time when gNbCuName is deleted and later configured with the same value.
    ...  == Precondition ==
    ...  - Real gNB2 is up and running
    ...  - AMF1 is up and running
    ...  - NRBTS.actEnhancedNgRanSupport = True
    ...  - NRBTS.gNbCuName = gNB_D_B2
    ...  - NRBTS.miNrE1InterfaceBts = 5min
    ...  - NRBTS.miNrNgInterface = 5min
    ...  - NG-C link between AMF and gNB is established.
	...
    ...  == Postcondition ==
    ...  - Verify that flow E1AP gNB-CU-CP-ConfigurationUpdate was sent 1 time
    ...  - Verify that RAN Configuration Update to AMF1 contains RANNodeName set to gNB-D-B2
    ...  - Counters:
    ...  - E1_GNB_CUCP_CONFIG_UPD_SENT = 1
    ...  - E1_GNB_CUCP_CONFIG_ACK_RCV = 1
    ...  - NG_CU_RAN_CONFIG_UPD_SENT = 1
    ...  - NG_CU_RAN_CONFIG_ACK_RCV = 1
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with two simulated AEQE radio modules - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_OP_2492, 5G_RAN_USR_RRM_17573
    ...
    ...  == REQUIRED LOGS ==
    ...    NGAP, E1AP
    ...
    ...  == CONTACTS ==
    ...     - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - CB008083-D#B2: MSC 5G_CP_CONF_669 NG RAN Configuration Update
    ...     - CB008083-D#B2-PMO#1: Counter for NG RAN Configuration Update with RAN Node Name IE - Success case
    ...
    ...  == HISTORY ==
    ...     [07.12.2022]  - Created TC

    [Setup]  Run keywords
    ...  Configure actEnhancedNgRanSupport flag to True value   AND
    ...  Configure gNbCuName to gNB_D_B2

    Wait until PM counters file is ready and saved

    EXPECT FLOW: AMF1 NGAP nGSetup
    Reset NG link to AMF1
    PASS FLOW: AMF1 NGAP nGSetup

    Verify that NG Setup Request to AMF1 contains RANNodeName set to gNB-D-B2

    EXPECT FLOW[timeout=120]: gNB2 E1AP gNB-CU-CP-ConfigurationUpdate
    EXPECT FLOW[timeout=120]: AMF1 NGAP rANConfigurationUpdate
    Delete gNbCuName
    Configure gNbCuName to gNB_D_B2
    PASS FLOW[timeout=120]: AMF1 NGAP rANConfigurationUpdate
    PASS FLOW[timeout=120]: gNB2 E1AP gNB-CU-CP-ConfigurationUpdate

    Verify that RAN Configuration Update to AMF1 contains RANNodeName set to gNB-D-B2

    Wait until PM counters file is ready and saved
    Verify PM counters for RANNodeName update: E1_SENT:1, E1_ACK:1, NG_SENT:1, NG_ACK:1

CB008083-D-B2 gNBCuName configured during startup NGC setup gNBCuName reconfigured triggers update
    [Tags]    D_B2_2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Test verifies that flow E1AP gNB-CU-CP-ConfigurationUpdate is sent 1 time
    ...  and NGAP rANConfigurationUpdate is sent 3 times when actNgcFlexSaMode=True, when 3 AMFs are connected with gNB
    ...  and gNbCuName is changed.
    ...  == Precondition ==
    ...  - Real gNB2 is up and running
    ...  - 3 AMFs are up and running
    ...  - 3 NG-C links between AMFs and gNB are established
    ...  - NRBTS.actEnhancedNgRanSupport = True
    ...  - NRBTS.actNgcFlexSaMode = True
    ...  - NRBTS.gNbCuName = gNB_D_B2
	...
    ...  == Postcondition ==
    ...  - Verify that flow E1AP gNB-CU-CP-ConfigurationUpdate was sent 1 time
    ...  - Verify that RAN Configuration Update to AMF1, AMF2, AMF3 contains RANNodeName set to gNB-D-B2-reconfigured
    ...  - Counters:
    ...  - E1_GNB_CUCP_CONFIG_UPD_SENT = 1
    ...  - E1_GNB_CUCP_CONFIG_ACK_RCV = 1
    ...  - NG_CU_RAN_CONFIG_UPD_SENT = 3
    ...  - NG_CU_RAN_CONFIG_ACK_RCV = 3
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with two simulated AEQE radio modules - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_OP_2492, 5G_RAN_USR_RRM_17573
    ...
    ...  == REQUIRED LOGS ==
    ...    NGAP, E1AP
    ...
    ...  == CONTACTS ==
    ...     - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - CB008083-D#B2: MSC 5G_CP_CONF_669 NG RAN Configuration Update
    ...     - CB008083-D#B2-PMO#1: Counter for NG RAN Configuration Update with RAN Node Name IE - Success case
    ...
    ...  == HISTORY ==
    ...     [07.12.2022]  - Created TC

    [Setup]  Run keywords
    ...  Configure actEnhancedNgRanSupport flag to True value   AND
    ...  Configure actNgcFlexSaMode flag to True value

    Wait until PM counters file is ready and saved

    EXPECT FLOW: gNB2 E1AP gNB-CU-CP-ConfigurationUpdate
    EXPECT FLOW: AMF1 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF2 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF3 NGAP rANConfigurationUpdate
    Configure gNbCuName to gNB_D_B2_reconfigured
    PASS FLOW: AMF1 NGAP rANConfigurationUpdate
    PASS FLOW: AMF2 NGAP rANConfigurationUpdate
    PASS FLOW: AMF3 NGAP rANConfigurationUpdate
    PASS FLOW: gNB2 E1AP gNB-CU-CP-ConfigurationUpdate

    Verify that RAN Configuration Update to AMF1 contains RANNodeName set to gNB-D-B2-reconfigured
    Verify that RAN Configuration Update to AMF2 contains RANNodeName set to gNB-D-B2-reconfigured
    Verify that RAN Configuration Update to AMF3 contains RANNodeName set to gNB-D-B2-reconfigured

    Wait until PM counters file is ready and saved
    Verify PM counters for RANNodeName update: E1_SENT:1, E1_ACK:1, NG_SENT:3, NG_ACK:3

    [Teardown]   Configure gNbCuName to gNB_D_B2

CB008083-D-B2 gNBCuName not configured during startup NGC setup gNBCuName reconfigured together with FF enabling triggers update
    [Tags]    D_B2_3
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Test verifies that flow E1AP gNB-CU-CP-ConfigurationUpdate is sent 1 time
    ...  and NGAP rANConfigurationUpdate is sent 3 times when actNgcFlexSaMode=True, when 3 AMFs are connected with gNB
    ...  and gNbCuName is changed in single delta, together with activation of FAF actEnhancedNgRanSupport.
    ...  == Precondition ==
    ...  - Real gNB2 is up and running
    ...  - 3 AMFs are up and running
    ...  - 3 NG-C links between AMFs and gNB are established
    ...  - NRBTS.actEnhancedNgRanSupport = False
    ...  - NRBTS.actNgcFlexSaMode = True
    ...  - NRBTS.gNbCuName is not set
	...
    ...  == Postcondition ==
    ...  - Verify that flow E1AP gNB-CU-CP-ConfigurationUpdate was sent 1 time
    ...  - Verify that RAN Configuration Update to AMF1, AMF2, AMF3 contains RANNodeName set to gNB-D-B2-reconfigured
    ...  - Counters:
    ...  - E1_GNB_CUCP_CONFIG_UPD_SENT = 1
    ...  - E1_GNB_CUCP_CONFIG_ACK_RCV = 1
    ...  - NG_CU_RAN_CONFIG_UPD_SENT = 3
    ...  - NG_CU_RAN_CONFIG_ACK_RCV = 3
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with two simulated AEQE radio modules - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_OP_2492, 5G_RAN_USR_RRM_17573
    ...
    ...  == REQUIRED LOGS ==
    ...    NGAP, E1AP
    ...
    ...  == CONTACTS ==
    ...     - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - CB008083-D#B2: MSC 5G_CP_CONF_669 NG RAN Configuration Update
    ...     - CB008083-D#B2-PMO#1: Counter for NG RAN Configuration Update with RAN Node Name IE - Success case
    ...
    ...  == HISTORY ==
    ...     [07.12.2022]  - Created TC

    [Setup]  Run keywords
    ...  Configure actEnhancedNgRanSupport flag to False value   AND
    ...  Delete gNbCuName

    Wait until PM counters file is ready and saved

    EXPECT FLOW: AMF1 NGAP nGSetup
    EXPECT FLOW: AMF2 NGAP nGSetup
    EXPECT FLOW: AMF3 NGAP nGSetup
    Reset NG link to AMF1
    Reset NG link to AMF2
    Reset NG link to AMF3
    PASS FLOW: AMF1 NGAP nGSetup
    PASS FLOW: AMF2 NGAP nGSetup
    PASS FLOW: AMF3 NGAP nGSetup

    Verify that NG Setup Request to AMF1 does not contain RANNodeName
    Verify that NG Setup Request to AMF2 does not contain RANNodeName
    Verify that NG Setup Request to AMF3 does not contain RANNodeName

    EXPECT FLOW: gNB2 E1AP gNB-CU-CP-ConfigurationUpdate
    EXPECT FLOW: AMF1 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF2 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF3 NGAP rANConfigurationUpdate
    Configure actEnhancedNgRanSupport flag to True value and gNbCuName to gNB_D_B2
    PASS FLOW: AMF1 NGAP rANConfigurationUpdate
    PASS FLOW: AMF2 NGAP rANConfigurationUpdate
    PASS FLOW: AMF3 NGAP rANConfigurationUpdate
    PASS FLOW: gNB2 E1AP gNB-CU-CP-ConfigurationUpdate

    Verify that RAN Configuration Update to AMF1 contains RANNodeName set to gNB-D-B2
    Verify that RAN Configuration Update to AMF2 contains RANNodeName set to gNB-D-B2
    Verify that RAN Configuration Update to AMF3 contains RANNodeName set to gNB-D-B2

    Wait until PM counters file is ready and saved
    Verify PM counters for RANNodeName update: E1_SENT:1, E1_ACK:1, NG_SENT:3, NG_ACK:3

CB008083-D-B2 gNBCuName not configured during startup NGC setup gNBCuName reconfigured triggers update
    [Tags]    D_B2_4
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Test verifies that flows E1AP gNB-CU-CP-ConfigurationUpdate and NGAP rANConfigurationUpdate:
    ...  - is sent after gNbCuName change, while actEnhancedNgRanSupport=True
    ...  - is not sent after deletion of gNbCuName, while actEnhancedNgRanSupport=False
    ...  == Precondition ==
    ...  - Real gNB2 is up and running
    ...  - 3 AMFs are up and running
    ...  - 3 NG-C links between AMFs and gNB are established
    ...  - NRBTS.actEnhancedNgRanSupport = True
    ...  - NRBTS.actNgcFlexSaMode = True
    ...  - NRBTS.gNbCuName is not set
	...
    ...  == Postcondition ==
    ...  - Verify that flow E1AP gNB-CU-CP-ConfigurationUpdate was sent 2 times
    ...  - Verify that 1st RAN Configuration Update to AMF1, AMF2, AMF3 contains RANNodeName set to gNB-D-B2
    ...  - Verify that 2nd RAN Configuration Update to AMF1, AMF2, AMF3 contains RANNodeName set to gNB-D-B2-after-enable-FAF
    ...  - Counters:
    ...  - E1_GNB_CUCP_CONFIG_UPD_SENT = 2
    ...  - E1_GNB_CUCP_CONFIG_ACK_RCV = 2
    ...  - NG_CU_RAN_CONFIG_UPD_SENT = 6
    ...  - NG_CU_RAN_CONFIG_ACK_RCV = 6
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with two simulated AEQE radio modules - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_OP_2492, 5G_RAN_USR_RRM_17573
    ...
    ...  == REQUIRED LOGS ==
    ...    NGAP, E1AP
    ...
    ...  == CONTACTS ==
    ...     - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - CB008083-D#B2: MSC 5G_CP_CONF_669 NG RAN Configuration Update
    ...     - CB008083-D#B2-PMO#1: Counter for NG RAN Configuration Update with RAN Node Name IE - Success case
    ...
    ...  == HISTORY ==
    ...     [07.12.2022]  - Created TC

    [Setup]  Run keywords
    ...  Configure actEnhancedNgRanSupport flag to True value   AND
    ...  Configure actNgcFlexSaMode flag to True value   AND
    ...  Delete gNbCuName

    Reset NG links to 3 AMFs

    Verify that NG Setup Request to AMF1 does not contain RANNodeName
    Verify that NG Setup Request to AMF2 does not contain RANNodeName
    Verify that NG Setup Request to AMF3 does not contain RANNodeName

    Wait until PM counters file is ready and saved

    Set expect E1AP and NGAP flows for gNbCuName update
    Configure gNbCuName to gNB_D_B2
    Verify that E1AP and NGAP flows occur for gNbCuName update to gNB-D-B2 value when actEnhancedNgRanSupport is set to True

    Configure actEnhancedNgRanSupport flag to False value

    Set expect E1AP and NGAP flows for gNbCuName update
    Delete gNbCuName
    Verify that E1AP and NGAP flows not occur for gNbCuName update when actEnhancedNgRanSupport is set to False

    Configure actEnhancedNgRanSupport flag to True value

    Set expect E1AP and NGAP flows for gNbCuName update
    Configure gNbCuName to gNB_D_B2_after_enable_FAF
    Verify that E1AP and NGAP flows occur for gNbCuName update to gNB-D-B2-after-enable-FAF value when actEnhancedNgRanSupport is set to True

    Wait until PM counters file is ready and saved
    Verify PM counters for RANNodeName update: E1_SENT:2, E1_ACK:2, NG_SENT:6, NG_ACK:6

*** Keywords ***
Reset NG links to 3 AMFs
    EXPECT FLOW: AMF1 NGAP nGSetup
    EXPECT FLOW: AMF2 NGAP nGSetup
    EXPECT FLOW: AMF3 NGAP nGSetup
    Reset NG link to AMF1
    Reset NG link to AMF2
    Reset NG link to AMF3
    PASS FLOW: AMF1 NGAP nGSetup
    PASS FLOW: AMF2 NGAP nGSetup
    PASS FLOW: AMF3 NGAP nGSetup

Set expect E1AP and NGAP flows for gNbCuName update
    EXPECT FLOW: gNB2 E1AP gNB-CU-CP-ConfigurationUpdate
    EXPECT FLOW: AMF1 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF2 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF3 NGAP rANConfigurationUpdate

Verify that E1AP and NGAP flows occur for gNbCuName update to ${gNbCuNameIEString} value when actEnhancedNgRanSupport is set to True
    PASS FLOW: gNB2 E1AP gNB-CU-CP-ConfigurationUpdate
    PASS FLOW: AMF1 NGAP rANConfigurationUpdate
    PASS FLOW: AMF2 NGAP rANConfigurationUpdate
    PASS FLOW: AMF3 NGAP rANConfigurationUpdate

    Verify that RAN Configuration Update to AMF1 contains RANNodeName set to ${gNbCuNameIEString}
    Verify that RAN Configuration Update to AMF2 contains RANNodeName set to ${gNbCuNameIEString}
    Verify that RAN Configuration Update to AMF3 contains RANNodeName set to ${gNbCuNameIEString}

Verify that E1AP and NGAP flows not occur for gNbCuName update when actEnhancedNgRanSupport is set to False
    FAIL FLOW: gNB2 E1AP gNB-CU-CP-ConfigurationUpdate
    FAIL FLOW: AMF1 NGAP rANConfigurationUpdate
    FAIL FLOW: AMF2 NGAP rANConfigurationUpdate
    FAIL FLOW: AMF3 NGAP rANConfigurationUpdate
