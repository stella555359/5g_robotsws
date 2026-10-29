*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008133
...         When using 64T64R massive MIMO radio units, half of DL TXs can be dynamically muted/unmuted to save energy in low load conditions.
...			CB008133 is applicable only for beam forming configurations in NR TDD FR1 where the cell is served by a 64T64R massive MIMO radio unit.
...			It provides energy savings by muting half of the TXs (32 TXs) in low load conditions. All 64 RXs are still used for uplink.
...			Muting is done when the load as measured by gNB goes below a configurable threshold. When the load increases above a configurable
...			threshold the muted TXs are switched on again. Muting and un-muting is done dynamically and automatically without cell down time.
...			The feature is the mMIMO counterpart of the feature CB008392. It also uses similar configuration as the feature CB008392
...			based on "power saving groups" (group of cells with overlapping coverage which share the load).
...
...         This feature can be enabled/disabled by new O&M parameter.
...         This feature is only applied to TDD FR1.
...
...      == TEST SET NAME ==
...         CB008133 - Massive MIMO muting (FR1) for energy efficiency
...
...      == TESTING SPLIT ==
...         Subfeature-A Basic mMIMO muting/unmuting algorithms
...         Subfeature-B Feature interaction
...
...      == CONTACTS ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...
...      == MAINTAINER ==
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008133 CFAM
...
...      == HISTORY ==
...         [07.11.2022] - TC Create
...         [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

Resource    ../CB008392/resources/CB008392-common_keywords.robot
Resource    resources/CB008133_setup_and_teardowns.robot

Force Tags    SKIPRUN

*** Variables ***

*** Test Cases ***
CB008133-Robusness_1 Interaction with cell level alarm
    [Tags]    A_2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test verifies bahaviour of gNB when feature is activated and cell level alarm is present
    ...     Test steps:
    ...       1. Reach on air state
    ...       2. Activate CB008133 feature
    ...       3. Verify that all cells are in notEnergySaving state
    ...       4. Wait 200s
    ...       5. Verify that all cells are in reducedEnergySaving state
    ...       6. Reset X2 link
    ...       7. Verify that all cells are in notEnergySaving state
    ...       8. Setup X2 link
    ...       9. Wait 200s
    ...       10. Verify that all cells are in reducedEnergySaving state
    ...       11. Repeat steps 6-10 few times
    ...
    ...     During testing CB008392 in above scenario bug was found that cells swtched off to offline state
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = False
    ...
    ...  == Postconditions ==
    ...   - All cells should be online
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...
    ...  == HISTORY ==
    ...     [12.01.2023] - TC Create

    No operation

CB008133-Robusness_2 Cell addition to gNB
    [Tags]    A_2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test verifies bahaviour of gNB when feature is activated and new cell is configured on gNB
    ...     Test steps:
    ...       1. Reach on air state
    ...       2. Activate CB008133 feature
    ...       3. Verify that all cells are in notEnergySaving state
    ...       4. Wait 200s
    ...       5. Verify that all cells (1, 3, 4) are in reducedEnergySaving state
    ...       6. Configure new NRCEL-2 on gNB
    ...       7. Verify that NRCEL-2 is operational
    ...       8. Verify that all cells are in notEnergySaving state
    ...       9. Wait 200s
    ...       10. Verify that all cells (1, 2, 3, 4) are in reducedEnergySaving state
    ...       11. Remove NRCEL-2 from gNB
    ...       12. Verify that all cells are in notEnergySaving state
    ...       13. Wait 200s
    ...       14. Verify that all cells (1, 3, 4) are in reducedEnergySaving state
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = False
    ...
    ...  == Postconditions ==
    ...   - All cells should be in reducedEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...
    ...  == HISTORY ==
    ...     [12.01.2023] - TC Create

    No operation

CB008133-Robusness_3 gNB reset
    [Tags]    A_2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test verifies bahaviour of gNB when feature is activated gNB reset is performed
    ...     Test steps:
    ...       1. Reach on air state
    ...       2. Activate CB008133 feature
    ...       3. Verify that all cells are in notEnergySaving state
    ...       4. Wait 200s
    ...       5. Verify that all cells are in reducedEnergySaving state
    ...       6. Perform gNB reset
    ...       7. Reach on air state
    ...       8. Verify that all cells are in notEnergySaving state
    ...       9. Wait 200s
    ...       10. Verify that all cells are in reducedEnergySaving state
    ...       11. Repeat steps 6-10 few times
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = False
    ...
    ...  == Postconditions ==
    ...   - after gNB restart all cells should be in reducedEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...
    ...  == HISTORY ==
    ...     [12.01.2023] - TC Create

    No operation