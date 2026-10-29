*** Settings ***
Documentation
...         Description : CRT for Testcases for Feature 5GC000470
...
...         5GC000470 aims to support of 5G classical gNB and cloud gNB-DU on ASIB A102/M02 and ABIL/ABIL2
...         with same feature set as with ASIK and ABIL/ABIL2 units, this feature requires testing:
...         - software management via OAM
...         - Multi-UE at I&V (e.g. with Qualcomm)
...         - other MCSs up to max cell capactiy
...         - ET PM counter validation
...         - Higher stability than -A (startup: >90%; Call setup and release > 90%;
...                                         throughput: 8-12h with 90% of MSC data rate)
...
...         AUTHOR (I&V):   Merwane CHEMSSI         merwane.chemssi@nokia.com
...                         Joseph SOQUES           joseph.soques@nokia.com
...                         Philippe GABORIEAU      philippe.gaborieau@nokia.com


Force Tags          CA_5G_IVPS   5G_RAN   RAN_5G   RAN_ST  5G_RAN_TDD   SISO
...                 SBTS00   STATE_SW_UPLOADED     CRT


Library     ute_reporting_portal
Resource    ../5GC000470/5GC000470-BA/5GC000470_BA_keyword.robot
Library    ../../../resources/ST/python/kw_commissioning_swconfig.py

Suite Setup             Setup Suite


*** Variables ***

${GN_WEBUI_ASIx}                    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER}                    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${GN_WEBUI_PASSWORD}                ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_OAM_IP}                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_USER_NAME}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ASIK_USER_PWD}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

${MAX_LOOP}                         5
${PATH_Storage}                     ${OUTPUT DIR}
# ${PATH_eCLATPMParser}               ${custom['PATH_eCLATPMParser']}

${test_duration}                    5min
${throughput_dl}                    178Mbits/sec
${throughput_ul}                    80Mbits/sec
${average_throughput_deviation}     10%

${timeout_for_switch_on}            15   s
${BOARD_NO}                         01


*** Test Cases ***
[1]5GC000470_BA_25_Classical_NSA_TDD_cmWave_5gNB_RU_reset
    [Documentation]  Loop of 5 resets of Radio Module with check of status of all HW modules until Cell on Air

    [Setup]    Setup Test Case With OAM
    kw_5GC000470_BA_25_Classical_NSA_TDD_cmWave_5gNB_RU_reset
    [Teardown]    Teardown Test Case With OAM


[1]5GC000470_BA_27_Classical_NSA_TDD_cmWave_5gNB_Cell_setup_stability
    [Documentation]  Loop of 5 resets with check of status of all HW modules
    ...              a sleep of 15min is necessary between two resets to avoid fallback

    [Setup]    Setup Test Case With OAM
    kw_5GC000470_BA_27_Classical_NSA_TDD_cmWave_5gNB_Cell_setup_stability
    [Teardown]    Teardown Test Case With OAM


*** Keywords ***
Setup Suite
    Append To Environment Variable    no_proxy   ${GN_WEBUI_ASIx}
    Commissioning Classical and Copy SWConfig file     with_on_air_test=True     with_alarm_23=True

Setup Test Case With OAM
    Create Sessions
    Connect To OAM

Teardown Test Case With OAM
    Teardown Sessions
    disconnect from OAM
