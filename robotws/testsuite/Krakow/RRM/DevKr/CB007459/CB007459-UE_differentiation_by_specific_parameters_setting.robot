*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == INTRODUCTION ==
...      Specific UEs to which specific setting applies are identified based on information received from MeNB over X2
...      during SgNB Addition/Modification procedure: PLMN ID,SPID
...      If the received couple (PLMN ID, SPID) matches with the configured R&D parameters
...      SKT_PLMN_ID and SKT_TEST_UE_SPID then the UE is identified as a specific UE.
...
...      == TEST SET NAME ==
...      CB007459-A
...      == TESTING SPLIT ==
...      CB007459-A
...      == AUTHORS ==
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...      == REFERENCES ==
...      CBB007459 CFAM
...      https://nokia.sharepoint.com/:f:/r/sites/ASCOP/AS%20Documents/FS1TAs-CFAMs/CB/CB007400%20-%20CB007599/CFAM
...
...      == HISTORY ==
...         [09.02.2021] - Created TC
...         [28.05.2021] - Review corrections

Library     ute_wtssim  # must be imported before ta5g_iphy to avoid error
Library     ute_fsmaccess
Library     ta_messaging
Library     ta_emss
Library     ta5g_iphy
Library     ta5g_testline_management

Resource    ./resources/CB007459.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB007459/NSA_2_CELLS.yaml

Suite Setup  Run Keywords
...  Setup emss    node_id=1
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  Connect using ssh to    gNB_CLASSICAL_OAM
...  AND  Connect using ssh to    AP
...  AND  Change RandD parameters
...  AND  Backup and modify swconfig file    parameters_list=@{SWCONFIG_FLAGS_LIST}
...  AND  Delete HashContainer files    gNB_CLASSICAL_OAM
...  AND  Trigger site reset
...  AND  Wait for testline ICMP Echo replies and SSH services
...  AND  Sleep  60
...  AND  Check radios availability
...  AND  Reach OnAir and wait for X2 link establishment
...  lua_cfg=${lua_cfg_file}
...  check_version=off
...  AND  Enable UE capture on simulated eNB  enable=${True}
...  AND  Sleep  2s

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_2c_NSA.lua

*** Test Cases ***
CB007459-5G-A-1_Successful_SgNB_Addition_with_specific_RD_parameters_matching_PLMN_and_different_SPID_settings
    [Tags]    B1
    ...    GQC_PLAN:FEATURE:CB007459-5G-A
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Check R&D parameters during SgNBAddition procedure for UEs having matching gNB R&D SKT PLMN and different SPID configuration
    ...  == Precondition ==
    ...  - Simulated MeNB up and running with LTE cell
    ...  - SgNB up and running with one NSA cell OnAir
    ...  - Established X2 connection MeNB-SgNB
    ...  - UE1 configured with SPID matching rdSktSpId, UE2 configured with SPID non-matching rdSktSpId
    ...  - gNB configured with Serving-PLMN (MCC:MNC) matching rdSktPlmnId
    ...  - NRBTS.actSPID = True
    ...  == Flow ==
    ...  - Start 20Mbps DL traffics on both UEs with bearers dedicated for EN-DC split
    ...  - Trigger SgNBAddition procedure separately for UE1, UE2
    ...  - Stop 20Mbps DL traffics on both UEs split bearers
    ...  == Postcondition ==
    ...  - UE1 flow with R&D parameters values
    ...  - UE2 flow with NIDD parameters values
    ...  - Successful data transmission over 5G
    ...  - Inactivity timer expiration based on rdNsaInactivityTimer value with UE1 context removal from SgNB side
    ...  - Inactivity timer expiration based on NIDD nsaInactivityTimer value with UE2 context removal from SgNB side
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in NSA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB007459-A#B1, CB007459-A#B6
    ...  == REQUIRED LOGS ==
    ...  X2AP, RRC
    ...  == AUTHOR ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB007459-13336

    [Setup]  Prepare test environment B1
    Start 20Mbps DL traffic on split bearer for UE1
    Start 20Mbps DL traffic on split bearer for UE2
    Trigger SgnbAddition procedure for UE1 with SPID=${CP_UE_rdSktSpId}
    Trigger SgnbAddition procedure for UE2 with SPID=${nonMatchingSpId}
    Verify RD params values in addResp message in ENDC_UE1 flow having matching SPID/PLMN config
    Verify NIDD params values in addResp message in ENDC_UE2 flow having non-matching SPID/PLMN config

    Stop and verify 20Mbps DL traffics on split bearers for UE1 UE2 and verify inactivity timers
    [Teardown]  Detach UE1 and UE2


CB007459-5G-A-3_Successful_Intra-Freq_Inter_gNB_for_NSAOpt3x_with_specific_RD_parameters_and_matching_PLMN_SPID
    [Tags]    B3
    ...    GQC_PLAN:FEATURE:CB007459-5G-A
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  == Info==
    ...  Verify if the configured R&D parameters match with parameters received in SgNB Addition Acknowledge during
    ...  Intra-Frequency inter en-gNB mobility procedure for UE1 having matching gNB R&D PLMN and SPID configuration.
    ...
    ...  Verify if the configured NRCELL1 parameters match with parameters received in SgNB Addition Acknowledge during
    ...  Intra-Frequency inter en-gNB mobility procedure for UE2 having non matching gNB R&D PLMN and SPID configuration.
    ...
    ...  == Precondition: ==
    ...  gNB - simulated gNB;
    ...     NRCELL simulated on AEQA radio module - NR_BAND: n78;
    ...  gNB_tgt classical - real gNB - ABIL + ASIK;
    ...  eNB - simulated MeNB by WTS;
    ...  UEs - Airphone simulator;
    ...
    ...  eNB up and running;
	...  gNB up and running with one NSA cell OnAir;
	...  UE1 configured with SPID matching rdSktSpId;
	...  UE1 attached to eNB with installed B1-NR meas object related to gNB nrcell;
	...  UE2 configured with with SPID non-matching rdSktSpId;
	...  UE2 attached to eNB with installed B1-NR meas object related to gNB nrcell;
    ...  gNB_tgt is configured with:
    ...     rdSktPlmnId, rdPMAxNROwnCell, rdPONominalPucch, rdPONominalPusch, rdPONominalSrs, rdAlpha and rdInitialPreambleReceivedtargetPower;
    ...
    ...  TESTING TOOLS:  AirPhone, EPCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:  gNB classic BTS in NSA mode
    ...         HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  REQUIREMENTS COVERAGE:  CB007459-A#B3, CB007459-A#B6
    ...
    ...  REQUIRED LOGS:  X2AP
    ...
    ...  AUTHOR:
    ...             Karolina Sroczyk (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
    ...
    ...  REFERENCES:
    ...             Related CFAM US:
    ...                 CB007459-A#B3: Intra-Frequency inter en-gNB mobility for NSA Opt 3x with specific parameters setting
    ...
    ...  HISTORY:
    ...         [15.02.2021]  - Created TC
    [Setup]  Prepare test environment B3
    Start 20Mbps DL traffic on split bearer for UE1
    Start 20Mbps DL traffic on split bearer for UE2

    Trigger SgnbAddition procedure for UE1 with SPID=${CP_UE_rdSktSpId}
    Trigger SgnbAddition procedure for UE2 with SPID=${nonMatchingSpId}
    UE1 triggers inter gNB HO from gNB_real to gNB_sim
    Verify that inter gNB HO from gNB_real to gNB_sim succeed for UE1
    UE2 triggers inter gNB HO from gNB_real to gNB_sim
    Verify that inter gNB HO from gNB_real to gNB_sim succeed for UE2

    UE1 with SPID=${CP_UE_rdSktSpId} triggers inter gNB HO from gNB_sim to gNB_real
    Verify that SCG establishment for UE1 with NRCELL_1 on gNB2 succeed
    UE2 with SPID=${nonMatchingSpId} triggers inter gNB HO from gNB_sim to gNB_real
    Verify that SCG establishment for UE2 with NRCELL_1 on gNB2 succeed

    Verify RD params values in addResp message in ENDC_UE1 flow having matching SPID/PLMN config
    Verify NIDD params values in addResp message in ENDC_UE2 flow having non-matching SPID/PLMN config

    Stop and verify 20Mbps DL traffics on split bearers for UE1 UE2 and verify inactivity timers
    [Teardown]  Detach UE1 and UE2

CB007459-5G-A-4_Intra_frequency_intra_DU_PSCell_change_based_on_A3_A5_with_SRB3_successful_with_specific_parameters
    [Tags]    B4
    ...    GQC_PLAN:FEATURE:CB007459-5G-A
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Check R&D parameters during PSCell change procedure for UEs having matching gNB R&D SKT PLMN and different SPID configuration
    ...  == Precondition ==
    ...  - Simulated MeNB up and running with LTE cell
    ...  - SgNB up and running with two NSA cell with same nr_arfcn
    ...  - Established X2 connection MeNB-SgNB
    ...  - UE1 configured with SPID non-matching rdSktSpId, UE2 configured with SPID non-matching rdSktSpId
    ...  - gNB configured with Serving-PLMN (MCC:MNC) matching rdSktPlmnId
    ...  - NRBTS.actSPID = True
    ...  - NRBTS.srb3SupportEnabled = True
    ...  - NRBTS.nsaActivityNotificationLevel = drb
    ...  - NRCELL-1.a5MeasEnabled = rsrp
    ...  - NRCELL-2.a5MeasEnabled = rsrp
    ...  == Flow ==
    ...  - Start 20Mbps DL traffics on both UEs with bearers dedicated for EN-DC split
    ...  - Trigger SgNBAddition procedure separately for UE1, UE2
    ...  - Trigger SgnbModification for UE1 changing its SPID which equals to rdSktSpId
    ...  - Trigger PSCell change procedure to CELL2.2 (PCI=51) for UE1, UE2 by sending A5 measurements
    ...  - gNB responds to UEs with RRCReconfiguration via SRB3
    ...  - Stop 20Mbps DL traffics on both UEs split bearers
    ...  == Postcondition ==
    ...  - RRCReconfiguration sent to UE1 via SRB3 with reconfigurationWithSync uses R&D parameters values
    ...  - RRCReconfiguration sent to UE2 via SRB3 with reconfigurationWithSync uses NIDD parameters values
    ...  - UEs did random access to the target cell
    ...  - Successful data transmission over 5G
    ...  - Inactivity timer expiration based on NIDD nsaInactivityTimer value with UE1 context removal from SgNB side
    ...  - Inactivity timer expiration based on NIDD nsaInactivityTimer value with UE2 context removal from SgNB side
    ...  == REQUIRED LOGS ==
    ...  X2AP, F1AP, RRC
    ...  == AUTHOR ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>

    [Setup]  Prepare test environment B4
    Start 20Mbps DL traffic on split bearer for UE1
    Start 20Mbps DL traffic on split bearer for UE2
    Trigger SgnbAddition for UE1 SPID=${nonMatchingSpId} and UE2 SPID=${nonMatchingSpId} with SRB3 enabled
    Trigger SgnbModification for UE1 changing SPID to ${CP_UE_rdSktSpId}
    UE1 sends measurement with eventA5 triggering PSCell change to gNB2 cell-2 PCI-51
    UE2 sends measurement with eventA5 triggering PSCell change to gNB2 cell-2 PCI-51
    Verify RD params values in ueCtxModifyResp message in PSCell_change_SRB3_UE1 flow having matching SPID/PLMN config
    Verify NIDD params values in ueCtxModifyResp message in PSCell_change_SRB3_UE2 flow having non-matching SPID/PLMN config

    # matching UE SPID sent only in SgnbModification does not trigger rdNsaInactivityTimer
    Stop and verify 20Mbps DL traffics on split bearers for UE1 UE2 and verify equal NIDD inactivity timers
    [Teardown]  Cleanup after test B4

CB007459-5G-A-1_Successful_SgNB_Addition_with_specific_RD_parameters_matching_PLMN_and_different_SPID_settings_with_pucchModeSelect_eq_longPucch
    [Tags]    B1_alternative
    ...    GQC_PLAN:FEATURE:CB007459-5G-A
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Check R&D parameters during SgNBAddition procedure for UEs having matching gNB R&D SKT PLMN and different SPID configuration
    ...  when pucchModeSelect equals to longPucch
    ...  == Precondition ==
    ...  - Simulated MeNB up and running with LTE cell
    ...  - SgNB up and running with one NSA cell OnAir
    ...  - Established X2 connection MeNB-SgNB
    ...  - UE9 configured with SPID matching rdSktSpId, UE10 configured with SPID non-matching rdSktSpId
    ...  - gNB configured with serving PLMN matching rdSktPlmnId, NRBTS.actSPID = True and NRCELL-1.pucchModeSelect = longPucch
    ...  == Flow ==
    ...  - Start 20Mbps DL traffics on both UEs with bearers dedicated for EN-DC split
    ...  - Trigger SgNBAddition procedure separately for UE9, UE10
    ...  - Stop 20Mbps DL traffics on both UEs split bearers
    ...  == Postcondition ==
    ...  - UE9 flow with R&D parameters values
    ...  - UE10 flow with NIDD parameters values
    ...  - Successful data transmission over 5G
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  gNB classical BTS in NSA mode
    ...       HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB007459-A#B1
    ...  == REQUIRED LOGS ==
    ...  X2AP
    ...  == AUTHOR ==
    ...  Karolina Sroczyk (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  CB007459-13336
    ...  == HISTORY ==
    ...         [18.03.2021]  - Created TC

    [Setup]  Prepare test environment B1_alternative
    Trigger SgnbAddition procedure for UE9 with SPID=${CP_UE_rdSktSpId}
    Trigger SgnbAddition procedure for UE10 with SPID=${nonMatchingSpId}
    Verify if p0-nominal equals to ${CP_UE_rdP0NominalPucchF1F3} in addResp:pucch-ConfigCommon for ENDC_UE9
    Verify if p0-nominal equals to ${NRCELL-1.p0NominalPucchF1F3} in addResp:pucch-ConfigCommon for ENDC_UE10
    [Teardown]  Cleanup after test B1 alternative

CB007459-5G-A-2_Intra_frequency_intra_DU_PSCell_change_based_on_A3_A5_without_SRB3_successful_with_specific_parameters
    [Tags]    B2
    ...    GQC_PLAN:FEATURE:CB007459-5G-A
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...     Check R&D parameters during PSCell change procedure for UEs having matching gNB R&D SKT SPID and
    ...     different PLMN configuration
    ...  == Precondition ==
    ...     - Simulated MeNB up and running with LTE cell
    ...     - SgNB up and running with two NSA cell with same nrarfcn
    ...     - Established X2 connection MeNB-SgNB
    ...     - both UEs have SPID matching rdSktSpId
    ...     - gNB configured with serving PLMN matching rdSktPlmnId and NRBTS.actSPID = True
    ...  == Flow ==
    ...     - Start 20Mbps DL traffic on split bearers for UE3
    ...     - Trigger SgNBAddition procedure for UE3
    ...     - Trigger PSCell change procedure for UE3 by sending A3 measurements
    ...     - for UE3: verify if parameters in RRCReconfiguration included in SgNBModificationRequired are set
    ...     -      accordingly to RD parameters
    ...     - Stop 20Mbps DL traffics on split bearers for UE3
    ...     - for UE3: verify if UE context is removed from SgNB after rdNsaInactivityTimer expires
    ...     - Detach UE3
    ...     - Change gNB PLMN to non matching rdSktPlmnId
    ...     - Start 20Mbps DL traffic on split bearers for UE4
    ...     - Trigger SgNBAddition procedure for UE4
    ...     - Trigger PSCell change procedure for UE4 by sending A3 measurements
    ...     - for UE4: verify if parameters in RRCReconfiguration included in SgNBModificationRequired are set
    ...     -      accordingly to NIDD parameters
    ...     - for UE4: verify if UE context is removed from SgNB after nsaInactivityTimer expires
    ...  == Postcondition ==
    ...     - UE3 receives R&D parameters values in RRCReconfiguration included in SgNBModificationRequired
    ...     - UE4 receives NIDD parameters values in RRCReconfiguration included in SgNBModificationRequired
    ...     - data transmission continues after PSCell change
    ...
    ...  == TESTING TOOLS ==
    ...     AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...      gNB classical BTS in NSA mode
    ...         HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...     5G_RAN_USR_18931, 5G_RAN_USR_18936
    ...  == REQUIRED LOGS ==
    ...     X2AP
    ...  == AUTHOR ==
    ...     Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  == REFERENCES ==
    ...     CB007459 CFAM
    ...  == HISTORY ==
    ...         [15.02.2021]  - Created TC

    [Setup]  Prepare test environment B2

    Start 20Mbps DL traffic on split bearer for UE3
    Trigger SgnbAddition procedure for UE3 with SPID=${CP_UE_rdSktSpId}
    UE3 sends measurement with eventA3 triggering PSCell change to gNB2 cell-2
    Verify successful PSCell change for UE3
    Verify RD params values in modReq message in PSCell_change_UE3 flow having matching SPID/PLMN config
    Stop and verify 20Mbps DL traffic on split bearer for UE3 and verify RD inactivity timer

    Run keyword and ignore error  Detach UE3 and UE4

    Send delta commissioning with non rdSktPlmn

    Attach UE4 with SPID=${CP_UE_rdSktSpId}

    Start 20Mbps DL traffic on split bearer for UE4

    Trigger SgnbAddition procedure for UE4 with SPID=${CP_UE_rdSktSpId}
    UE4 sends measurement with eventA3 triggering PSCell change to gNB2 cell-2
    Verify successful PSCell change for UE4
    Verify NIDD params values in modReq message in PSCell_change_UE4 flow having non-matching SPID/PLMN config
    Stop and verify 20Mbps DL traffic on split bearer for UE4 and verify NIDD inactivity timer

    [Teardown]  Cleanup after test B2
