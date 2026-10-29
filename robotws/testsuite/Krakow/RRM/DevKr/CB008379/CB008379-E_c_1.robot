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
...         CB008379-E_c
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [04.04.2022] - Create Test Suite
...         [10.08.2022] - Switch to AP_LO TL

Resource    ./resources/CB008379-common_keywords.robot
Resource    ../../resources/Robot/common_keywords/bwp.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup      admission_control=${True}
...                         fdm_scheduling_for_load_reporting=${True}
...                         multiple_BWP=${True}
...                         change_GSCN=${True}
...                         reset_tl=${True}

*** Variables ***
${SKIP_COUNTERS}=       ${FALSE}
${LUA_CFG}=             ${CURDIR}/config/SA_TDD_2c_UEs_BWP_capable.lua
${gscn}=                7853

&{NRCELL_1_BWP}=    ID=1    SMALL_BW=50    LARGE_BW=100

${maxGBRTrafficLimit}               17
${gfbr}                             30
${mfbr}                             30
@{mgfbr_2}                          30  27  24
#${mfbr_2}                           23
${gfbr_3}                           29
${mfbr_3}                           29
${bg_trf_small_bwp}                 40
${bg_trf_small_bwp_2}               25
${bg_trf_large_bwp}                 3
${wait_until_kw_succ_rep}           1x
${wait_until_kw_succ_time}          3s
${wait_until_resources_allocated}   10
${wait_until_resources_released}    10

*** Test Cases ***
CB008379-E-c_1 Admission control with multiple BWP-CB7552
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Test verifies admission control on small and large BWP profiles
    ...     Background UEs on small and large BWP with GBR DL traffic, small BWP UE2 fails adding PDU session with GBR bearer
    ...     due to no resources available on small BWP, large BWP UE41 successfully adds PDU session with GBR bearer.
    ...     Detach small BWP UE1 to release some resources on small BWP, then try again with small BWP UE2 and adding PDU session
    ...     with GBR bearer ends with success.
    ...     Large BWP UE42 fails adding PDU session with GBR bearer due to no resources available on large BWP, decrease DL traffic
    ...     on small BWP UE2, then try again with large BWP UE42 and adding PDU session with GBR bearer ends with success.
    ...
    ...  == Precondition: ==
    ...     - gNB2 up and running with one SA cell OnAir
    ...     - feature CB007552 (multiple BWP)is configured and activated
    ...         BWP_PROFILE-5 - initial BWP
    ...         BWP_PROFILE-57 - Large Dedicated BWP - 100MHz
    ...         BWP_PROFILE-55 - Small Dedicated BWP - 50MHz
    ...     - UEs 1-40 not supporting 100MHz bandwith (small BWP capable)
    ...     - UEs 41-80 supporting 100MHz bandwith (large BWP capable)
    ...
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ABIO + ASIB) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...     5G_CP_IF_NTW_4978; 5G_RAN_USR_RRM_14842; CB_FIM_4093
    ...
    ...  == REQUIRED LOGS ==
    ...     NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...     - USCB008379-E#AC2: GBR Load reporting for GBR Radio Admission Control per BWP
    ...
    ...  HISTORY:
    ...     [04.04.2022] - Create Test Suite
    ...     [04.04.2022] - Review closed
    ...     [10.08.2022] - Switch to AP_LO TL
    ...     [10.05.2023} - limit 5QI checks to 1 from each group

    [Setup]  Prepare test environment E_c-1

    Omit when SKIP_COUNTERS present     start collecting counters

    Run keyword with options
    ...     Repeat Admission control for small BWP UE 1,2 and large BWP UE 41,42,43 and 5QI2

    Run keyword with options
    ...     Repeat Admission control for small BWP UE 7,8 and large BWP UE 51,52,53 and 5QI71

    Run keyword with options
    ...     Repeat Admission control for small BWP UE 13,14 and large BWP UE 61,62,63 and 5QI128

    Omit when SKIP_COUNTERS present         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_DU_ADM_SUCC_GBR_BWP2 >=9, SA_DU_ADM_SUCC_GBR_BWP1 >=6, SA_DU_ADM_ATT_GBR_BWP2 >=12, SA_DU_ADM_ATT_GBR_BWP1 >=9
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT >=7, QFI_SETUP_SUCC >=5, QFI_REL >=5, QFI_REL_NORMAL >=5
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT >=7, QFI_SETUP_SUCC >=5, QFI_REL >=5, QFI_REL_NORMAL >=5
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT >=7, QFI_SETUP_SUCC >=5, QFI_REL >=5, QFI_REL_NORMAL >=5
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT >=21, QFI_SETUP_SUCC >=15, QFI_REL >=15, QFI_REL_NORMAL >=15
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


*** Keywords ***
Run keyword with options
    [Arguments]  ${keyword}
    @{mfgbr_list}=   Create List  @{mgfbr_2}
    Set Suite Variable   @{mfgbr_list}
    Wait until keyword succeeds   3x   3sec   ${keyword}
