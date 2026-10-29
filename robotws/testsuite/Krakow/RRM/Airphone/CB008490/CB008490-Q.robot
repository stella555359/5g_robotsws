*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces successful procedure of inter-gNB NR-DC UE bulk release.
...
...      == TEST SET NAME ==
...      CB008490-Q: Other Interactions
...
...      == TESTING SPLIT ==
...     	CB008490-Q#B1: Graceful shutdown of NR-DC-SN cell (OAM-triggered)
...     	CB008490-Q#B2: Energy saving: NR-DC-SN cell switch off (stepwise, first cell deactivation)
...     	CB008490-Q#B3: Energy saving: NR-DC-SN cells switch off (stepwise, with the last cell deactivation)
...     	CB008490-Q#B4: Energy saving: NR-DC-SN cells switch off (one-shot)
...     	CB008490-Q#B5: Energy saving: NR-DC-SN cell switch on (stepwise)
...     	CB008490-Q#B6: Energy saving: NR-DC-SN cells switch on (one-shot)
...     	CB008490-Q#B7: Forced NR-DC-SN cell switch off and on (based on time of day and voltage)
...     	CB008490-Q#B8: Extended NR-DC-SN cell range
...     	CB008490-Q#B9: Support refServCellIndicator IE in RRCReconfiguration message when configuring CB012118 B1 measurement to UE in NR-DC mode
...     	CB008490-Q#B10: SCGFailureInformation received from the UE due to unsuccessful Random Access during SNode Addition
...     	CB008490-Q#B11 Interworking with Active Queue Management with PI2 discarding
...     	CB008490-Q#B12: Co-existence of NR-DC with emergency / HPA sessions

...
...      == TESTING SCOPE ==
...      CB008490-Q: Other Interactions
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek 			<tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1038
...
...      == HISTORY ==
...      [21.03.2025] - Create Test Suite
...      [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)
...

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490_pm_counters.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[MP][MP]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/cfg_n77A_n257M_8CC.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/full_scf_gnb2_MN_8CC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/full_scf_gnb3_SN_8CC.xml
${AP_XML}=                Krakow/CB008490/iphy_1cell_n78_8cells_n257_1xAWEUB.xml

${BBMOD_GNB_DIST_NAME}=    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1

*** Test Cases ***
CB008490-SR-Q-B8 Extended NR-DC-SN cell range 2,3km
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario verifies the inter-gNB NR-DC-SN PSCell addition procedure with FR2 extended range configuration.
    ...
    ...  == PRECONDITION ==
    ...  MN and SN gNBs are configured for NR-DC
    ...  SN supports FR2 CA
    ...  All cells in cellGroup#1 are configured with:
    ...  NRCELL.prachConfigurationIndex is set to 135
    ...  NRCELL.zeroCorrelationZoneConfig is set to 0
    ...  NRCELL.rangeExtension enum is set to 5-11km
    ...
    ...  == POSTCONDITION ==
    ...  NR-DC-SN Cell-1 is locked
    ...  UUE1 and UE2 are released from SN and MN
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_29002
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-Q#B8: Extended NR-DC-SN cell range  ALT2
    ...
    ...  == HISTORY ==
    ...    [21.03.2025] - Create Test Suite
    ...    [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)

    [Setup]  Prepare test environment CB008490-Q-B8_1

    Set timing advance for SCG leg - UE1, distance to cell - 1500m

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    [Teardown]    Q-B8 cleanup


CB008490-SR-Q-B8 Extended NR-DC-SN cell range 6,9km
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario verifies the inter-gNB NR-DC-SN PSCell addition procedure with FR2 extended range configuration.
    ...
    ...  == PRECONDITION ==
    ...  MN and SN gNBs are configured for NR-DC
    ...  SN supports FR2 CA
    ...  All cells in cellGroup#1 are configured with:
    ...  NRCELL.prachConfigurationIndex is set to 135
    ...  NRCELL.zeroCorrelationZoneConfig is set to 0
    ...  NRCELL.rangeExtension enum is set to 5-11km
    ...
    ...  == POSTCONDITION ==
    ...  NR-DC-SN Cell-1 is locked
    ...  UUE1 and UE2 are released from SN and MN
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_29002
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-Q#B8: Extended NR-DC-SN cell range  ALT2
    ...
    ...  == HISTORY ==
    ...    [21.03.2025] - Create Test Suite
    ...    [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)

    [Setup]  Prepare test environment CB008490-Q-B8_2

    Set timing advance for SCG leg - UE1, distance to cell - 3000m

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    [Teardown]    Q-B8 cleanup


CB008490-SR-Q-B8 Extended NR-DC-SN cell range 11km
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario verifies the inter-gNB NR-DC-SN PSCell addition procedure with FR2 extended range configuration.
    ...
    ...  == PRECONDITION ==
    ...  MN and SN gNBs are configured for NR-DC
    ...  SN supports FR2 CA
    ...  All cells in cellGroup#1 are configured with:
    ...  NRCELL.prachConfigurationIndex is set to 135
    ...  NRCELL.zeroCorrelationZoneConfig is set to 0
    ...  NRCELL.rangeExtension enum is set to 5-11km
    ...
    ...  == POSTCONDITION ==
    ...  NR-DC-SN Cell-1 is locked
    ...  UUE1 and UE2 are released from SN and MN
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_29002
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-Q#B8: Extended NR-DC-SN cell range  ALT2
    ...
    ...  == HISTORY ==
    ...    [21.03.2025] - Create Test Suite
    ...    [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)

    [Setup]  Prepare test environment CB008490-Q-B8_3

    Set timing advance for SCG leg - UE1, distance to cell - 6000m

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    [Teardown]    Q-B8 cleanup


CB008490-Q-B1 OAM triggered graceful shutdown of NR-DC-SN cell
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This scenario verifies OAM-triggered graceful cell shutdown. Bearer takeback operation is performed for UE
    ...  using cell as PSCell, and UE bulk release is performed for UE using this cell as Scell
    ...
    ...  == PRECONDITION ==
    ...  MN and SN gNBs are configured for NR-DC
    ...  SN supports FR2 CA
    ...  Graceful cell shutdown is enabled
    ...  NR-DC-SN Cell-1 hosts two UEs:
    ...  UE1, using this cell as PSCell (operating or not in CA)
    ...  UE2, using this cell as SCell
    ...
    ...  == POSTCONDITION ==
    ...  NR-DC-SN Cell-1 is locked
    ...  UUE1 and UE2 are released from SN and MN
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23638
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-EB#B3 Partial Reset - Dropped Xn link
    ...
    ...  == HISTORY ==
    ...    [21.03.2025] - Create Test Suite
    ...    [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)

    [Setup]  Prepare test environment CB008490-Q-B101

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    Attach UE2 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE2, MN gNB2

    UE2 sends A4 measurement with id=2 and PCIs [53]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE2, MN gNB2

    Set expected messages flows for RLF due to cell shutdown for SN gNB3
    Set NRCELL-3.administrativeState to Shutting down on bts-2
    Verify expected messages flows for RLF due to cell shutdown for SN gNB3

    Verify that XNAP ResetRequest ResetRequestTypeInfo contains 'partialReset', gNB3
    Verify that XNAP ResetRequest contains cause:misc:o-and-M-intervention, gNB3
    Verify that E1AP Reset contains cause:misc:om-intervention, gNB3
    Verify that F1AP Reset contains cause:misc:om-intervention, gNB3

    [Teardown]    Q-B101 cleanup

CB008490-SR-Q-B2 Energy Saving - NR-DC-SN cell switch off - stepwise first cell deactivation
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This scenario verifies gNB behavior when cell is switched-off due to energy saving.
    ...  Bearer takeback operation or Reset is performed for UE using cell as PSCell, and UE bulk release is performed
    ...  for UE using this cell as Scell
    ...
    ...  == PRECONDITION ==
    ...  MN and SN gNBs are configured for NR-DC
    ...  SN supports FR2 CA
    ...  Graceful cell shutdown is enabled
    ...  NR-DC-SN Cell-1 hosts two UEs:
    ...  UE1, using this cell as PSCell (operating or not in CA)
    ...  UE2, using this cell as SCell
    ...
    ...  == POSTCONDITION ==
    ...  NR-DC-SN Cell-3 is in EnergySavingState
    ...  UE1 and UE2 are released from SN and MN
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...  - NRBTS.actNrLBPowerSaving is set to true
    ...  - Power saving group has been created on SN and configured as follows:
    ...  - NRPGRP.lbpsSOMethod is set to cell switch off
    ...  - NRPGRP.lbpsPeriodList is configured
    ...  - NRPGRP.lbpsPeriodList.lbpsSuspended is set to notSuspended
    ...  - NRPGRP.lbpsMinLoad and NRPGRP.lbpsMaxLoad are configured
    ...  - NRPGRP.lbpsLastCellMinLoad is configured
    ...  - NRPGRP.lbpsLastCellSOEnabled is set to true
    ...  - NRPGRP.lbpsCellList contains cell-1, cell-2, cell-3, cell-4
    ...  - NRPGRP.lbpsCellList.lbpsCellSOOrder is configured to keep following order: cell1 -> cell2 -> cell3 -> cell4
    ...  - NRBTS.actCoordinated4g5gPowerSaving is set to false
    ...  - NRBTS.shutdownNogNBCellTmr is set to 30min
    ...  - NRBTS.nrDcReevalTimer is set to 20min
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_28915, 5G_RAN_USR_RRM_28997
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-Q#B2: Energy saving: NR-DC-SN cell switch off (stepwise, first cell deactivation)
    ...  CB008490-Q#B3: Energy saving: NR-DC-SN cells switch off (stepwise, with the last cell deactivation)
    ...
    ...  == HISTORY ==
    ...    [21.03.2025] - Create Test Suite
    ...    [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)

    [Setup]  Prepare test environment CB008490-Q-B201

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    Attach UE2 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE2, MN gNB2

    UE2 sends A4 measurement with id=2 and PCIs [53]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE2, MN gNB2

    Wait 360s for cells [2,3] energySavingState change to [notEnergySaving, switchingOff]
    Set expected messages flows for RLF due to cell shutdown for SN gNB3
    Wait 300s for cells [2,3] energySavingState change to [notEnergySaving, energySaving]

    Verify expected messages flows for RLF due to cell shutdown for SN gNB3

    Verify that XNAP ResetRequest ResetRequestTypeInfo contains 'partialReset', gNB3
    Verify that XNAP ResetRequest contains cause:misc:o-and-M-intervention, gNB3
    Verify that E1AP Reset contains cause:misc:om-intervention, gNB3
    Verify that F1AP Reset contains cause:misc:om-intervention, gNB3

    sleep    120    # if cell goes to energy saving at the start of PM period, e.g. 12:40:01, then keyword
    # Wait until PM counters file is ready and saved for SN NRBTS-3 will gather PM counters file from 12:35-12:40
    # without relevant counter values. This sleep ensures that abovementioned keyword will wait for "true" nexd PM perios

    Omit when SKIP_COUNTERS present
    ...  Wait until PM counters file is ready and saved for SN NRBTS-3

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify counter value on MRBTS-3 NRBTS-3 NRCELL-3 for M55601C00505 - SAMPLES_NR_CELL_POWER_SAV_L_L is above 10
    ...  Verify counter value on MRBTS-3 NRBTS-3 NRCELL-3 for M55601C00501 - SAMPLES_NR_CELL_POWER_SAVING is above 10
    ...  Verify counter value on MRBTS-3 NRBTS-3 NRCELL-3 for M55601C01001 - NR_CELL_PLAN_UNAVAIL_SAMPLES is above 10
    ...  Verify counter value on MRBTS-3 NRBTS-3 NRCELL-3 for M55601C00502 - CHNG_TO_NR_CELL_POWER_SAVING equals 1
    ...  Verify counter value on MRBTS-3 NRBTS-3 NRCELL-3 for M55601C01002 - NR_CELL_PLAN_UNAVAIL_CHNG_TO equals 1

    [Teardown]    Q-B201 cleanup

CB008490-SR-Q-B2 Energy Saving - NR-DC-SN cell switch off - stepwise first cell deactivation with XNlink deactivation
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This scenario verifies gNB behavior when cell is switched-off due to energy saving.
    ...  Bearer takeback operation or Reset is performed for UE using cell as PSCell, and UE bulk release is performed
    ...  for UE using this cell as Scell. Due to shutdownNogNBCellTmr set to 0, XN link between MN and SN will be closed
    ...  after last cell switch off.
    ...
    ...  == PRECONDITION ==
    ...  MN and SN gNBs are configured for NR-DC
    ...  SN supports FR2 CA
    ...  Graceful cell shutdown is enabled
    ...  NR-DC-SN Cell-1 hosts two UEs:
    ...  UE1, using this cell as PSCell (operating or not in CA)
    ...  UE2, using this cell as SCell
    ...
    ...  == POSTCONDITION ==
    ...  NR-DC-SN Cell-3 is in EnergySavingState
    ...  UE1 and UE2 are released from SN and MN
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...  - NRBTS.actNrLBPowerSaving is set to true
    ...  - Power saving group has been created on SN and configured as follows:
    ...  - NRPGRP.lbpsSOMethod is set to cell switch off
    ...  - NRPGRP.lbpsPeriodList is configured
    ...  - NRPGRP.lbpsPeriodList.lbpsSuspended is set to notSuspended
    ...  - NRPGRP.lbpsMinLoad and NRPGRP.lbpsMaxLoad are configured
    ...  - NRPGRP.lbpsLastCellMinLoad is configured
    ...  - NRPGRP.lbpsLastCellSOEnabled is set to true
    ...  - NRPGRP.lbpsCellList contains cell-1, cell-2, cell-3, cell-4
    ...  - NRPGRP.lbpsCellList.lbpsCellSOOrder is configured to keep following order: cell1 -> cell2 -> cell3 -> cell4
    ...  - NRBTS.actCoordinated4g5gPowerSaving is set to false
    ...  - NRBTS.shutdownNogNBCellTmr is set to 30min
    ...  - NRBTS.nrDcReevalTimer is set to 20min
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_28915, 5G_RAN_USR_RRM_28997
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-Q#B2: Energy saving: NR-DC-SN cell switch off (stepwise, first cell deactivation)
    ...  CB008490-Q#B3: Energy saving: NR-DC-SN cells switch off (stepwise, with the last cell deactivation)
    ...
    ...  == HISTORY ==
    ...    [21.03.2025] - Create Test Suite
    ...    [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)

    [Setup]  Prepare test environment CB008490-Q-B201

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    Attach UE2 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE2, MN gNB2

    UE2 sends A4 measurement with id=2 and PCIs [53]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE2, MN gNB2

    Wait 360s for cells [2,3] energySavingState change to [notEnergySaving, switchingOff]
    Set expected messages flows for RLF due to cell shutdown for SN gNB3
    Wait 300s for cells [2,3] energySavingState change to [notEnergySaving, energySaving]

    Verify expected messages flows for RLF due to cell shutdown for SN gNB3

    Verify that XNAP ResetRequest ResetRequestTypeInfo contains 'partialReset', gNB3
    Verify that XNAP ResetRequest contains cause:misc:o-and-M-intervention, gNB3
    Verify that E1AP Reset contains cause:misc:om-intervention, gNB3
    Verify that F1AP Reset contains cause:misc:om-intervention, gNB3

    Wait 360s for cells [2] energySavingState change to [switchingOff]
    Wait 300s for cells [2] energySavingState change to [energySaving]

    Wait 360s for cells [4] energySavingState change to [switchingOff]
    Wait 300s for cells [4] energySavingState change to [energySaving]

    Wait 360s for cells [5] energySavingState change to [switchingOff]
    Wait 300s for cells [5] energySavingState change to [energySaving]

    Check that XNlink is down for 3s

    #cleanup for AP
    Detach and kill UE1
    Detach and kill UE2

    EXPECT FLOW[timeout=300]: gNB3 XNAP xnSetup
    Suspend power saving period
    PASS FLOW[timeout=300]: gNB3 XNAP xnSetup

    Wait 300s for cells [2,3,4,5] operationalState change to [enabled,enabled,enabled,enabled]

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    [Teardown]    Q-B201 cleanup

CB008490-SR-Q-B5 Energy Saving NR-DC-SN cell switch on - stepwise
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This scenario verifies gNB behavior during cell switch on triggered by increased load in the power group
    ...  After cellswitch on and nrDcReevalTimer bearer takeback is triggered.
    ...
    ...  == PRECONDITION ==
    ...  MN and SN gNBs are configured for NR-DC
    ...  SN supports FR2 CA
    ...  Graceful cell shutdown is enabled
    ...  NR-DC-SN Cell-1 hosts two UEs:
    ...  UE1, using this cell as PSCell (operating or not in CA)
    ...  UE2, using this cell as SCell
    ...
    ...  == POSTCONDITION ==
    ...  NR-DC-SN Cell-3 is in EnergySavingState
    ...  UE1 and UE2 are released from SN and MN
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...  - NRBTS.actNrLBPowerSaving is set to true
    ...  - Power saving group has been created on SN and configured as follows:
    ...  - NRPGRP.lbpsSOMethod is set to cell switch off
    ...  - NRPGRP.lbpsPeriodList is configured
    ...  - NRPGRP.lbpsPeriodList.lbpsSuspended is set to notSuspended
    ...  - NRPGRP.lbpsMinLoad and NRPGRP.lbpsMaxLoad are configured
    ...  - NRPGRP.lbpsLastCellMinLoad is configured
    ...  - NRPGRP.lbpsLastCellSOEnabled is set to true
    ...  - NRPGRP.lbpsCellList contains cell-1, cell-2, cell-3, cell-4
    ...  - NRPGRP.lbpsCellList.lbpsCellSOOrder is configured to keep following order: cell1 -> cell2 -> cell3 -> cell4
    ...  - NRBTS.actCoordinated4g5gPowerSaving is set to false
    ...  - NRBTS.shutdownNogNBCellTmr is set to 30min
    ...  - NRBTS.nrDcReevalTimer is set to 20min
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_28915, 5G_RAN_USR_RRM_28997
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-Q#B2: Energy saving: NR-DC-SN cell switch off (stepwise, first cell deactivation)
    ...  CB008490-Q#B3: Energy saving: NR-DC-SN cells switch off (stepwise, with the last cell deactivation)
    ...
    ...  == HISTORY ==
    ...    [21.03.2025] - Create Test Suite
    ...    [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)

    [Setup]  Prepare test environment CB008490-Q-B5
#
    Wait 300s for cells [9] energySavingState change to [energySaving]

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected flows for Scell setup for SN gNB3 for UE1

    UE1 sends A4 measurement with id=1 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected flows for Scell setup for SN gNB3 for UE1
    Verify in SNodeModificationRequired 6 cells were configured for gNB3 for UE1

    Suspend power saving period
    Wait 300s for cells [9] operationalState change to [enabled]

    Set expected messages flows for TakeBack after nrDcReevalTimer for MN gNB2 for UE1
    #Wait 10min for nrDcReevalTimer to expire
    Verify expected messages flows for TakeBack after nrDcReevalTimer for MN gNB2 for UE1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected flows for Scell setup for SN gNB3 for UE1

    UE1 sends A4 measurement with id=3 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected flows for Scell setup for SN gNB3 for UE1
    Verify in SNodeModificationRequired 7 cells were configured for gNB3 for UE1

    [Teardown]    Q-B5 cleanup

*** Keywords ***
Suspend power saving period
    get_ps_config    suspended=True
    Sleep    2
    Configure    ${CURDIR}/config/yaml/power_saving.yaml    bts_id=2
Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1

Set expected flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_id:\d+}, SN gNB${sn_id:\d+}
    Set expected messages flows for SNodeAddition for SN gNB${sn_id}
    Set expected messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Set expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Set expected not failed messages flows for SNodeAddition for SN gNB${sn_id}

Verify expected flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_id:\d+}, SN gNB${sn_id:\d+}
    Verify expected messages flows for SNodeAddition for SN gNB${sn_id}
    Verify expected messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Verify expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Verify expected not failed messages flows for SNodeAddition for SN gNB${sn_id}
