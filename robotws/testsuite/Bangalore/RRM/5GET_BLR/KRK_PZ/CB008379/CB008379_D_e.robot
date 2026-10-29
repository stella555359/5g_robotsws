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
...         CB008379-D_e
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [12.04.2022] - Create Test Suite
...         [30.04.2022] - Peer review closed 

Resource    ./resources/CB008379-common_keywords.robot
Library     ./resources/custom_ta_messaging.py

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run keywords
...      enable_uu_messaging_on_simulated_nodes    AND
...      Run Setup

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBsim_with_lte_cell.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim_with_lte_cell.lua
...                      CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBsim_with_lte_cell.lua
...     CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE=${CURDIR}/config/SA_TDD_2c_FDD_2c_1gNBsim_with_lte_cell.lua
...     CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ=${CURDIR}/config/SA_TDD_2c_FDD_2c_1gNBsim_with_lte_cell.lua
...     CLOUD_5G_O_E_AP_LOO:VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_4_CELLS=${CURDIR}/config/SA_TDD_2c_FDD_2c_1gNBsim_with_lte_cell.lua
${LUA_CFG}=              ${CURDIR}/config/SA_TDD_2c_FDD_2c_1gNBsim_with_lte_cell.lua
${SKIP_COUNTERS}=        ${FALSE}
${TA_MESSAGING_DISABLE_CSV_LOGGING}=        ${TRUE}

*** Test Cases ***
CB008379-D-e Successful inter-RAT A3 or A5 based handover from 5G to LTE to 5G without data forwarding with GBR bearer
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of this test is to perform successful inter-RAT B2 based handover from LTE to 5G
    ...     for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254
    ...
    ...  == Precondition: ==
    ...     - gNB2 up and running with one SA cell OnAir
    ...     - measurements A1, A2 and B2 are configured on gNB
    ...     - NRCELL-1.actNonVoNRGbrService = true
    ...     - NRCELL-1.actVoNR = true
    ...     - NRCELL-1.actCDrx = false
    ...     - NRBTS-1.actInterRatHoSA = true
    ...     - NRBTS-1.actInterRatHoFromEutraToSA = true
    ...
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...     - 5G_RAN_CP_12360506; 5G_RAN_USR_RRM_14770; 5G_CP_MM_2997; CB_FIM_4087
    ...
    ...  == REQUIRED LOGS ==
    ...     NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...     - CB008379-D1#B3 Successful Handover from LTE to 5G w/o data forwarding having GBR bearers
    ...
    ...  == HISTORY ==
    ...     [12.04.2022] - Create Test Suite
    ...     [30.04.2022] - Peer review closed 
    [Tags]    D_e
    [Setup]    Run keywords
    ...        Start egate collection    AND
    ...        Prepare test environment D-e

    [Teardown]  run keywords
    ...          restore_default_iphy_interfaces   AND
    ...          stop egate collection
    Omit when SKIP_COUNTERS present
    ...         start collecting counters
    Run Keyword And Continue On Failure  Repeat UE1: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI2
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    Teardown repeat keyword if failed
    Run Keyword And Continue On Failure  Repeat UE2: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI3
    Teardown repeat keyword if failed
    Run Keyword And Continue On Failure  Repeat UE3: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI4
    Teardown repeat keyword if failed

    Run Keyword And Continue On Failure  Repeat UE4: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI71
    Teardown repeat keyword if failed
    Run Keyword And Continue On Failure  Repeat UE5: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI72
    Teardown repeat keyword if failed
    Run Keyword And Continue On Failure  Repeat UE6: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI76
    Teardown repeat keyword if failed

    Run Keyword And Continue On Failure  Repeat UE7: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI128
    Teardown repeat keyword if failed
    Run Keyword And Continue On Failure  Repeat UE8: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI212
    Teardown repeat keyword if failed
    Run Keyword And Continue On Failure  Repeat UE9: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI254
    Teardown repeat keyword if failed

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...     Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 9
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
