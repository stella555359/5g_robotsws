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
...         [23.08.2021] - Created TC
...         [26.05.2022] - Airphone APoABIO switch

Library     ute_wtssim  # must be imported before ta5g_iphy to avoid error
Library     ute_fsmaccess
Library     ta_messaging
Library     ta_emss
Library     ta5g_iphy
Library     ta5g_testline_management

Resource    ./resources/CB007459.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Connect using ssh to    gNB_CLASSICAL_OAM
...  AND  Connect using ssh to    AP
...  AND  Change RandD parameters common keyword
...  AND  Backup and modify swconfig file    parameters_list=@{SWCONFIG_FLAGS_LIST}
...  AND  Delete HashContainer files    gNB_CLASSICAL_OAM
...  AND  Send base commissioning and configure non-SKT NIDD parameter values
...  AND  Run Keyword and ignore error    Trigger site reset
...  AND  Wait for testline ICMP Echo replies and SSH services
...  AND  Sleep  60
...  AND  Check radios availability
...  AND  Prepare TL with config files
...  AND  Enable UE capture on simulated eNB  enable=${True}
...  AND  Sleep  2s

*** Variables ***
&{TOPOLOGY_TO_LUA}=     CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/NSA/egate_2c_NSA_ASOE.lua
...        CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE=${CURDIR}/config/egate_TDD_2c_FDD_2c_NSA_ASOE.lua
...        CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ=${CURDIR}/config/egate_TDD_2c_FDD_2c_NSA_ASOE.lua
...        CLOUD_5G_O_E_AP_LOO:VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_4_CELLS=${CURDIR}/config/egate_TDD_2c_FDD_2c_NSA_ASOE.lua
${LUA_CFG}=   ${CURDIR}/config/egate_2c_NSA_ASOE.lua
${GNB_PLATFORM_TYPE}=       ASOE
${long_pucch}=           ${False}

*** Test Cases ***
CB007326-5G-A-1_Successful_SgNB_Addition_with_specific_RD_parameters_matching_PLMN_and_different_SPID_settings
    [Tags]    B1
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
    ...  - HARDWARE ID: gNB(ASOE) with 2 simulated AEQE radio modules - NR_BAND: n78
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
