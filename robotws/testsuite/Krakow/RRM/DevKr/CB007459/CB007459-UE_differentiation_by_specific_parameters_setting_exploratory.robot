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
...      == AUTHOR ==
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

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS21B    SBTS23R4
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB007459/NSA_2_CELLS.yaml

Suite Setup  Run Keywords
...  Connect using ssh to    gNB_CLASSICAL_OAM
...  AND  Connect using ssh to    AP
...  AND  Backup and modify swconfig file    parameters_list=@{SWCONFIG_FLAGS_INVALID_LIST}
...  AND  Delete HashContainer files    gNB_CLASSICAL_OAM
...  AND  Trigger site reset
...  AND  Check radios availability
...  AND  Reach OnAir and wait for X2 link establishment
...  lua_cfg=${lua_cfg_file}
...  check_version=off
...  AND  Enable UE capture on simulated eNB  enable=${True}
...  AND  Sleep  2s

*** Variables ***
${lua_cfg_file}=  ${CURDIR}/config/egate_2c_NSA.lua

*** Test Cases ***
CB007459-5G-A-1_SgNB_Addition_with_RD_parameters_set_to_invalid_values_while_matching_PLMN_and_SPID
    [Tags]    B1_exploratory    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Verify if F1AP_UEContextSetupFailure message occures during SgNB Addition procedure for UE1 having matching
    ...  gNB R&D PLMN and SPID configuration.
    ...
    ...  Verify if the configured NRCELL1 parameters match with parameters received in SgNB Addition Acknowledge during
    ...  SgNB Addition procedure for UE2 having non matching gNB R&D PLMN and SPID configuration.
    ...
    ...  == Precondition ==
    ...  - Simulated MeNB up and running with LTE cell
    ...  - SgNB up and running with one NSA cell OnAir
    ...  - Established X2 connection MeNB-SgNB
    ...  - UE1 configured with SPID matching rdSktSpId, UE2 configured with SPID non-matching rdSktSpId
    ...  - gNB configured with serving PLMN matching rdSktPlmnId and NRBTS.actSPID = True
    ...  - out of range value of R&D parameter (alpha) is set
    ...  == Flow ==
    ...  Trigger SgNBAddition procedure for UE1:
    ...    - Expect F1AP_UEContextSetupFailure
    ...  - Trigger SgNBAddition procedure for UE2:
    ...    - Expect X2AP_SgNBAdditionRequestAcknowledge
    ...  == Postcondition ==
    ...  - UE1 interrupted flow with out of range R&D parameter value
    ...  - UE2 flow with NIDD parameters values
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
    ...  CB007459-13330
    ...  == HISTORY ==
    ...         [26.04.2021]  - Created TC

    [Setup]  Prepare test environment B1_exploratory
    Trigger SgnbAddition procedure when UE1 with SPID=${CP_UE_rdSktSpId} and RD params are set to invalid values
    Verify that F1AP_UEContextSetupFailure and X2AP_SgNBAdditionRequestReject occured for UE1 at gNB2
    Trigger SgnbAddition procedure for UE2 with SPID=${nonMatchingSpId}
    Verify NIDD params values in addResp message in ENDC_UE2 flow having non-matching SPID/PLMN config
    [Teardown]  Detach UE1 and UE2
