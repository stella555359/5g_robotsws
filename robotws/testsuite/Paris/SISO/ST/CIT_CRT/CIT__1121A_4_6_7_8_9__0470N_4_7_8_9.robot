*** Settings ***
Documentation
...         Description : CIR for Testcases for Feature 5GC001121_AMOD and 5GC000470-N (1121)
...
...         5GC001121 aims to support of 5G classical gNB and cloud gNB-DU on ASIK A102/M02 and ABIL/ABIL2
...            on AMOD Sub-rack
...
...         5GC000470 aims to support of 5G classical gNB and cloud gNB-DU on ASIB A102/M02 and ABIL/ABIL2
...         with same feature set as with ASIK and ABIL/ABIL2 units, this feature requires testing:
...             - software management via OAM
...             - Multi-UE at I&V (e.g. with Qualcomm)
...             - other MCSs up to max cell capactiy
...             - ET PM counter validation
...             - Higher stability than -A (startup: >90%; Call setup and release > 90%;
...                                               throughput: 8-12h with 90% of MSC data rate)
...
...         AUTHOR (I&V):   Merwane CHEMSSI         merwane.chemssi@nokia.com
...                         Joseph SOQUES           joseph.soques@nokia.com
...                         Philippe GABORIEAU      philippe.gaborieau@nokia.com


Force Tags          CA_5G_IVPS   5G_RAN   RAN_5G   RAN_ST  5G_RAN_TDD   SISO
...                 SBTS00   STATE_SW_UPLOADED     CIT


Library     ute_reporting_portal
Resource    ../5GC001121/5GC001121_keyword.robot
Resource    ../5GC000470/5GC000470-N_5GC001121/5GC000470-N_5GC001121__keyword.robot
Library    ../../../resources/ST/python/kw_commissioning_swconfig.py

Suite Setup             Setup Suite


*** Variables ***

${PATH_Storage}                     ${OUTPUT DIR}
${MAX_LOOP}                         5

${GN_WEBUI_ASIx}                    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER}                    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${GN_WEBUI_PASSWORD}                ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_OAM_IP}                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_USER_NAME}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ASIK_USER_PWD}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}


*** Test Cases ***

# 5GC001121_A

[1]5GC001121_A_8_Check HW infos
    [Setup]    Setup Test Case
    kw_5GC001121_A_8_Check HW infos
    [Teardown]    Teardown Test Case


[1]5GC001121_A_4_5gBTS_Basic_Synchro
    [Setup]    Setup Test Case
    kw_5GC001121_A_4_5gBTS_Basic_Synchro
    [Teardown]    Teardown Test Case


[1]5GC001121_A_6_5gBTS_Site_Reset
    [Documentation]  Loop of 5 resets with check of status of all HW modules
    ...              a sleep of 15min is necessary between two resets to avoid fallback

    [Setup]    Setup Test Case With OAM
    kw_5GC001121_A_6_5gBTS_Site_Reset
    [Teardown]    Teardown Test Case With OAM


[1]5GC001121_A_7_5gBTS_Snapshot
    [Setup]    Setup Test Case
    kw_5GC001121_A_7_5gBTS_Snapshot
    [Teardown]    Teardown Test Case


[1]5GC001121_A_9_Cell_Setup
    [Setup]    Setup Test Case With OAM
    kw_5GC001121_A_9_Cell_Setup
    [Teardown]    Teardown Test Case With OAM


# 5GC000470-N

[1]5GC000470-N_004_5gBTS_Basic_Synchro
    [Setup]    Setup Test Case
    kw_5GC000470-N_004_5gBTS_Basic_Synchro
    [Teardown]    Teardown Test Case


[1]5GC000470-N_007_5gBTS_Snapshot
    [Setup]    Setup Test Case
    kw_5GC000470-N_007_5gBTS_Snapshot
    [Teardown]    Teardown Test Case


[1]5GC000470-N_008_Check_HW_infos
    [Setup]    Setup Test Case
    kw_5GC000470-N_008_Check_HW_infos
    [Teardown]    Teardown Test Case

[1]5GC000470-N_009_Cell_Setup
    [Setup]    Setup Test Case with OAM
    kw_5GC000470-N_009_Cell_Setup
    [Teardown]    Teardown Test Case with OAM


*** Keywords ***
Setup Suite
    Append To Environment Variable    no_proxy    ${GN_WEBUI_ASIx}    separator=,
    Commissioning Classical and Copy SWConfig file     with_on_air_test=True     with_alarm_23=True

Setup Test Case
    Create Sessions

Setup Test Case With OAM
    Create Sessions
    Connect To OAM

Teardown Test Case
    Teardown Sessions

Teardown Test Case With OAM
    Teardown Sessions
    disconnect from OAM
