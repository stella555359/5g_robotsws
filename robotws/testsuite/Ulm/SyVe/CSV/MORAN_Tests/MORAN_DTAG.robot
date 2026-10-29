*** Settings ***
Documentation
...    This resource file implements automated tests that are executed in the context of the lab pre-validation of MORAN solution planned to be
...    rolled-out in DTAG (Deutsche Telekom AG) field network with DTAG as host-MNO and partnering operator TEF (Telefonica O2 Germany) as guest-MNO.
...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
...    | Team:        | MN RAN RD VRF ULM 1 (CSV ULM)                     |
...    | Team Email:  | <I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com>        |

#-------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.ue
Library    ute_tshark
Library    String
Library    Collections

Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../../resources/Common/git_handling.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/snapshot.robot
Resource    ../../../resources/Common/tcpdump.robot
Resource    ../../../resources/Common/gnb.robot

Resource    ../../resources/syve_testline.robot
Resource    ../../resources/attenuator.robot
Resource    ../../resources/UEs_handler.robot
Resource    ../../resources/scf_info.robot

Resource    ../resources/commonKeywords.robot
Resource    ./resources/moran_tc_kw_lib.robot
Resource    ../resources/BTS_Cells_Handler.robot
Variables   qc_mapping.yaml


Suite Setup     moran_tc_kw_lib.MORAN Test Suite Setup Keyword
Suite Teardown  moran_tc_kw_lib.MORAN Test Suite Teardown Keyword


*** Variables ***
${RP_CA}                  VRF_RRM
${RP_ORGANIZATION}        VRF_ULM_T01
${QC_DOMAIN}              MN_RAN
${RP_LOCATION}            VRF_ULM
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL
&{RTT_KPI}                name=rtt
...                       visible_to_db=Yes
...                       category=Customer


*** Test Cases ***
MORAN_DTAG_5G_ping_RTT_FDD
    [Documentation]      This testcase implements the "TC20 - Ping test on MOCN-as-MORAN cell" variant for the host-MNO (DTAG) cell with NR RAT
    [Tags]    MORAN_DTAG_5G_ping_RTT_FDD
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic UL ping with DL background traffic test case for MORAN sites   target_rat=NR   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG-incomplete_5G_ping_RTT_FDD
    [Documentation]      This testcase implements the "TC20 - Ping test on MOCN-as-MORAN cell" variant for the host-MNO (DTAG-incomp) cell with NR RAT
    [Tags]    MORAN_DTAG-incomplete_5G_ping_RTT_FDD
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic UL ping with DL background traffic test case for MORAN sites   target_rat=NR   target_mno=DTAG-incomplete
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG_LTE_ping_RTT_FDD
    [Documentation]      This testcase implements the "TC20 - Ping test on MOCN-as-MORAN cell" variant for the host-MNO (DTAG) cell with LTE RAT
    [Tags]    MORAN_DTAG_LTE_ping_RTT_FDD
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic UL ping with DL background traffic test case for MORAN sites   target_rat=LTE   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_5G_ping_RTT_FDD
    [Documentation]      This testcase implements the "TC20 - Ping test on MOCN-as-MORAN cell" variant for the guest-MNO (TEF) cell with NR RAT
    [Tags]    MORAN_TEF_5G_ping_RTT_FDD
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic UL ping with DL background traffic test case for MORAN sites   target_rat=NR   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_LTE_ping_RTT_FDD
    [Documentation]      This testcase implements the "TC20 - Ping test on MOCN-as-MORAN cell" variant for the host-MNO (TEF) cell with LTE RAT
    [Tags]    MORAN_TEF_LTE_ping_RTT_FDD
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic UL ping with DL background traffic test case for MORAN sites   target_rat=LTE   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG_5G_SA_FDD_SingleUe_Throughput
    [Documentation]   This keyword implements a combination of "TC24 - Single UE DL Throughput" and "TC25 - Single UE UL Throughput" test case variant
    ...   for the host-MNO (DTAG) cell and for cells with NR SA FDD (RAT).
    [Tags]    MORAN_DTAG_5G_SA_FDD_TCP_TP
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic Single UE Throughput test case for MORAN sites   target_rat=NR   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG_LTE_FDD_SingleUe_Throughput
    [Documentation]   This keyword implements a combination of "TC24 - Single UE DL Throughput" and "TC25 - Single UE UL Throughput" test case variant
    ...   for the host-MNO (DTAG) cell and for cells with LTE FDD (RAT).
    [Tags]    MORAN_DTAG_LTE_FDD_TCP_TP
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic Single UE Throughput test case for MORAN sites   target_rat=LTE   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_5G_SA_FDD_SingleUe_Throughput
    [Documentation]   This keyword implements a combination of "TC24 - Single UE DL Throughput" and "TC25 - Single UE UL Throughput" test case variant
    ...   for the guest-MNO (TEF) cell and for cells with NR SA FDD (RAT).
    [Tags]    MORAN_TEF_5G_SA_FDD_TCP_TP
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic Single UE Throughput test case for MORAN sites   target_rat=NR   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_LTE_FDD_SingleUe_Throughput
    [Documentation]   This keyword implements a combination of "TC24 - Single UE DL Throughput" and "TC25 - Single UE UL Throughput" test case variant
    ...   for the guest-MNO (TEF) cell and for cells with LTE FDD (RAT).
    [Tags]    MORAN_TEF_LTE_FDD_TCP_TP
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic Single UE Throughput test case for MORAN sites   target_rat=LTE   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG_VoLTE_MO_Call
    [Documentation]   This keyword implements the "TC22 - VoLTE MO call" test case variant for the host-MNO (DTAG) UE
    [Tags]    MORAN_DTAG_VoLTE_MO_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=MO   target_rat=LTE   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG_VoLTE_MT_Call
    [Documentation]   This keyword implements the "TC23 - VoLTE MT call" test case variant for the host-MNO (DTAG) UE
    [Tags]    MORAN_DTAG_VoLTE_MT_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=MT   target_rat=LTE   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_VoLTE_MO_Call
    [Documentation]   This keyword implements the "TC22 - VoLTE MO call" test case variant for the guest-MNO (TEF) cell and UE
    [Tags]    MORAN_TEF_VoLTE_MO_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=MO   target_rat=LTE   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_VoLTE_MT_Call
    [Documentation]   This keyword implements the "TC23 - VoLTE MT call" test case variant for the guest-MNO (TEF) cell and UE
    [Tags]    MORAN_TEF_VoLTE_MT_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=MT   target_rat=LTE   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG_VoNR_MO_Call
    [Documentation]   This keyword implements the "TC22 - VoLTE MO call" test case variant for the host-MNO (DTAG) UE
    [Tags]    MORAN_DTAG_VoNR_MO_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=MO   target_rat=NR   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG_VoNR_MT_Call
    [Documentation]   This keyword implements the "TC23 - VoLTE MT call" test case variant for the host-MNO (DTAG) UE
    [Tags]    MORAN_DTAG_VoNR_MT_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=MT   target_rat=NR   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_VoNR_MO_Call
    [Documentation]   This keyword implements the "TC22 - VoLTE MO call" test case variant for the guest-MNO (TEF) cell and UE
    [Tags]    MORAN_TEF_VoNR_MO_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=MO   target_rat=NR   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_VoNR_MT_Call
    [Documentation]   This keyword implements the "TC23 - VoLTE MT call" test case variant for the guest-MNO (TEF) cell and UE
    [Tags]    MORAN_TEF_VoNR_MT_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=MT   target_rat=NR   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG_VoLTE_EC_Call
    [Documentation]   This keyword implements the "TC28 - VoLTE EC call" test case variant for the host-MNO (DTAG) cell and UE
    [Tags]    MORAN_DTAG_VoLTE_EC_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=EC   target_rat=LTE   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_VoLTE_EC_Call
    [Documentation]   This keyword implements the "TC28 - VoLTE EC call" test case variant for the guest-MNO (TEF) cell and UE
    [Tags]    MORAN_TEF_VoLTE_EC_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=EC   target_rat=LTE   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_DTAG_VoNR_EC_Call
    [Documentation]   This keyword implements the "TC28 - VoNR EC call" test case variant for the host-MNO (DTAG) cell and UE
    [Tags]    MORAN_DTAG_VoNR_EC_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=EC   target_rat=NR   target_mno=DTAG
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


MORAN_TEF_VoNR_EC_Call
    [Documentation]   This keyword implements a combination of "TC28 - VoNR EC call" test case variant for the guest-MNO (TEF) cell and UE
    [Tags]    MORAN_TEF_VoNR_EC_Call
    [Setup]    moran_tc_kw_lib.MORAN Test Case Setup Keyword
    Generic VoIP call test case for MORAN sites   call_type=EC   target_rat=NR   target_mno=TEF
    [Teardown]    moran_tc_kw_lib.MORAN Test Case Teardown Keyword


*** Keywords ***
Generic VoIP call test case for MORAN sites
    [Documentation]   This keyword implements a combination of "TC22 VoLTE/VoNR test - mobile-originating call on MORAN cell" and
    ...   "TC23 VoLTE/VoNR test - mobile-originating call on MORAN cell" test case variants for both,
    ...   the host-MNO (DTAG) cell or guest-MNO (TEF) cell and for cells with NR or LTE radio access technology (RAT).
    [Arguments]       ${call_type}=MO   ${target_rat}=LTE   ${target_mno}=DTAG

    builtin.Log To Console  ${EMPTY}
    builtin.Log To Console  ${EMPTY}   format=+<${{int(int($consolewidth)*1)-6}}
    ${long_log_string}=   builtin.Catenate   Executing "TC22/TC23/TC28 VoLTE/VoNR ${call_type} call test" test case variant
    ...   in a *${target_rat}* cell of *${target_mno}* MNO with MORAN site config
    builtin.Log To Console    ${long_log_string}
    builtin.Log To Console  ${EMPTY}   format=+<${{int(int($consolewidth*1))-6}}

    #---------- preferred_net_mode -----------------
    # 5G preferred  = NR/LTE/GSM/WCDMA    = NR/LTE
    # LTE preferred = GSM/WCDMA/LTE (PRL)
    # 3G preferred  = GSM/WCDMA preferred
    # 5G only       = NR only
    # LTE only      = LTE only
    #-----------------------------------------------
    ${preferred_net_mode}=   builtin.Set Variable If   '${target_rat}' == 'LTE'    LTE only        NR only           # secretcode

    IF         'DTAG' in '${target_mno}' and '${call_type}' in ['MO', 'EC']
       ${MO_UE_id}=   builtin.Set Variable   ${1}    # originate call at DTAG UE
       ${MT_UE_id}=   builtin.Set Variable   ${2}    # other UE is TEF UE, but actually not in use in this test variant
    ELSE IF    'TEF' in '${target_mno}' and '${call_type}' in ['MO', 'EC']
       ${MO_UE_id}=   builtin.Set Variable   ${2}    # originate call at TEF UE
       ${MT_UE_id}=   builtin.Set Variable   ${1}    # other UE is DTAG UE, but actually not in use in this test variant
    ELSE IF    'DTAG' in '${target_mno}' and '${call_type}' == 'MT'
       ${MO_UE_id}=   builtin.Set Variable   ${2}    # originate call at TEF UE
       ${MT_UE_id}=   builtin.Set Variable   ${1}    # terminate call at DTAG UE
    ELSE IF    'TEF' in '${target_mno}' and '${call_type}' == 'MT'
       ${MO_UE_id}=   builtin.Set Variable   ${1}    # originate call at DTAG UE
       ${MT_UE_id}=   builtin.Set Variable   ${2}    # terminate call at TEF UE
    END

    # performing steps needed for test result reporting to QC and RP
    ${_}  ${__}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=     Get From List    ${bts_distNames}    ${0}
    builtin.Log To Console      Running on TL node with btsId: ${bts_distName}

    ## NOTE: the cell blocking command below will fail with ADMIN_API Error Code 69, in case some of the cells are already in blocked state
    builtin.Log To console   Identifying all cells of the MORAN site configuration which are not be blocked during the follwing Voice Call test ...
    Select for Voice Call Test Scenarios the MORAN site cells to be blocked and set them as test variable
    ...   target_rat=${target_rat}   target_mno=${target_mno}   call_type=${call_type}

    # running actual TC keyword which is common for LTE and NR RAT cell variants
    moran_tc_kw_lib.MORAN VoIP call   target_mno=${target_mno}   target_rat=${target_rat}   call_type=${call_type}
    ...   MO_UE_id=${MO_UE_id}   MT_UE_id=${MT_UE_id}   preferred_net_mode=${preferred_net_mode}   technology_in_use=FDD


Generic Single UE Throughput test case for MORAN sites
    [Documentation]   This keyword implements a combination of "TC24 - Single UE DL Throughput" and "TC25 - Single UE UL Throughput" test case variant
    ...   for the host-MNO (DTAG) cell or guest-MNO (TEF) cell and for cells with NR or LTE radio access technology (RAT).
    [Arguments]       ${target_rat}=LTE   ${target_mno}=DTAG

    builtin.Log To Console  ${EMPTY}
    builtin.Log To Console  ${EMPTY}   format=+<${{int(int($consolewidth)*1)-6}}
    ${long_log_string}=   builtin.Catenate   Executing "TC24 - Single UE DL Throughput" and "TC25 - Single UE UL Throughput" test case coombination
    ...   in a *${target_rat}* cell of *${target_mno}* MNO with MORAN site config
    builtin.Log To Console    ${long_log_string}
    builtin.Log To Console  ${EMPTY}   format=+<${{int(int($consolewidth*1))-6}}

    #---------- preferred_net_mode -----------------
    # 5G preferred  = NR/LTE/GSM/WCDMA    = NR/LTE
    # LTE preferred = GSM/WCDMA/LTE (PRL)
    # 3G preferred  = GSM/WCDMA preferred
    # 5G only       = NR only
    # LTE only      = LTE only
    #-----------------------------------------------
    #${preferred_net_mode}=   builtin.Set Variable If   '${target_rat}' == 'LTE'    LTE preferred   NR preferred      # keyevents
    ${preferred_net_mode}=   builtin.Set Variable If   '${target_rat}' == 'LTE'    LTE only        NR only           # secretcode
    ${UE_id}=                builtin.Set Variable If   'DTAG' in '${target_mno}'   ${1}            ${2}          # NOTE: UE_id needs to be an integer!
    ${UNUSED_UE_id}=         builtin.Set Variable If   'DTAG' in '${target_mno}'   ${2}            ${1}          # NOTE: UE_id needs to be an integer!

    # performing steps needed for test result reporting to QC and RP
    ${_}  ${__}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=     Get From List    ${bts_distNames}    ${0}
    builtin.Log To Console      Running on TL node with btsId: ${bts_distName}

    # NOTE: the cell blocking command below will fail with ADMIN_API Error Code 69, in case some of the cells are already in blocked state
    builtin.Log To console   Identifying all cells of the MORAN site configuration which are to be blocked during the following Data Call test ...
    Select MORAN site cells to be blocked and set them as test variable   target_rat=${target_rat}   target_mno=${target_mno}

    # running actual TC keyword which is common for LTE and NR RAT cell variants
    moran_tc_kw_lib.MORAN L3 call with TCP Data Transfer    UE_id=${UE_id}   UNUSED_UE_id=${UNUSED_UE_id}
    ...   preferred_net_mode=${preferred_net_mode}   technology_in_use=FDD

    builtin.Log To Console   ${EMPTY}   format=+<${{int(int($consolewidth)*1)-6}}


Generic UL ping with DL background traffic test case for MORAN sites
    [Documentation]   This keyword implements the "TC20 - Ping test on MOCN-as-MORAN cell" variant for the host-MNO (DTAG) cell or guest-MNO (TEF)
    ...   cell and for cells with NR or LTE radio access technology (RAT).
    [Arguments]       ${target_rat}=LTE   ${target_mno}=DTAG

    builtin.Log To Console  ${EMPTY}
    builtin.Log To Console  ${EMPTY}   format=+<${{int(int($consolewidth)*1)-6}}
    builtin.Log To Console  Executing "TC20 - Ping test on MOCN-as-MORAN cell" in a *${target_rat}* cell of *${target_mno}* MNO with MORAN site config
    builtin.Log To Console  ${EMPTY}   format=+<${{int(int($consolewidth*1))-6}}

    #---------- preferred_net_mode -----------------
    # 5G preferred  = NR/LTE/GSM/WCDMA    = NR/LTE
    # LTE preferred = GSM/WCDMA/LTE (PRL)
    # 3G preferred  = GSM/WCDMA preferred
    # 5G only       = NR only
    # LTE only      = LTE only
    #-----------------------------------------------
    #${preferred_net_mode}=   builtin.Set Variable If   '${target_rat}' == 'LTE'    LTE preferred   NR preferred      # keyevents
    ${preferred_net_mode}=   builtin.Set Variable If   '${target_rat}' == 'LTE'    LTE only        NR only           # secretcode
    ${UE_id}=                builtin.Set Variable If   'DTAG' in '${target_mno}'   ${1}            ${2}          # NOTE: UE_id needs to be an integer!
    ${UNUSED_UE_id}=         builtin.Set Variable If   'DTAG' in '${target_mno}'   ${2}            ${1}          # NOTE: UE_id needs to be an integer!


    # performing steps needed for test result reporting to QC and RP
    ${_}  ${__}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=     Get From List    ${bts_distNames}    ${0}
    builtin.Log To Console      Running on TL node with btsId: ${bts_distName}

    # NOTE: the cell blocking command below will fail with ADMIN_API Error Code 69, in case some of the cells are already in blocked state
    builtin.Log To console   Identifying all cells of the MORAN site configuration which are to be blocked during the following Data Call test ...
    Select MORAN site cells to be blocked and set them as test variable   target_rat=${target_rat}   target_mno=${target_mno}

    # running actual TC keyword which is common for LTE and NR RAT cell variants
    MORAN Ping RTT    UE_id=${UE_id}   UNUSED_UE_id=${UNUSED_UE_id}
    ...   preferred_net_mode=${preferred_net_mode}   technology_in_use=FDD

    builtin.Log To Console   ${EMPTY}   format=+<${{int(int($consolewidth)*1)-6}}


MORAN Ping RTT
    [Documentation]   This keyword implements the execution of a PING data transfer, including monitoring / verification of related counters and KPIs.
    [Arguments]       ${UE_id}=${1}   ${UNUSED_UE_id}=${2}   ${preferred_net_mode}=5G preferred   ${technology_in_use}=FDD

    #Log To Console    ${\n}PING Testing...
    #Log To Console    Technology to use is: ${technology_in_use}

    ${oam_alias}=   connect.Setup OAM http session    node_type=enb    node_id=${0}
    Set Test Variable  ${oam_alias}
    FOR   ${LNCEL_to_block}    IN    @{CELLS_TO_BLOCK_LIST}
      admin.block_cell    dist_name=${LNCEL_to_block}    connection=${oam_alias}   timeout=120
    END

    # ToDo: Select it automatically! Used Also in E2E_5G_SA_Data_Transfer
    ${NRRU}=    BTS_Cells_Handler.Set Active NRRU As Variable Based On Technology In Use    technology_in_use=${technology_in_use}
    Log To Console    ${\n}Open attenuation for serving cell...
    attenuator.Set gNB all ports attenuation    value_in_db=${0}    ru_id=${NRRU}

    ${reservedUE}    moran_tc_kw_lib.Initialize UE and optionally start background user data transfer   UE_id=${UE_id}   UNUSED_UE_id=${UNUSED_UE_id}
    ...   preferred_net_mode=${preferred_net_mode}   with_bg_user_data=${True}
    Set Test Variable    ${reservedUE}

    Log To Console    ${\n}PING From UE to the Application Server.
    taf.ue.Stop Data Transfer    DL_Background_${reservedUE}
    moran_tc_kw_lib.Start PING    ue_alias=${reservedUE}   allowed_packet_loss=10   # temporary only / allowed_packet_loss=10=10%

    Await data transfer finish    ul_PING_${reservedUE}
    ${PING_Statistics}    Get Data Transfer Statistics    ul_PING_${reservedUE}
    Log To Console    ${\n}PING Statistics: ${\n}${PING_Statistics}

    ${device_model}    Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['device_model']}    ${EMPTY}
    ${imei}    Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['imei']}    ${EMPTY}
    ${description}    Set Variable IF    '${device_model}'!='${EMPTY}'    \[${device_model},${imei}\]    ${EMPTY}

    ${packet_loss}    Copy Dictionary    ${RTT_KPI}
    Set To Dictionary    ${packet_loss}    target=${PING_Statistics['packet_loss']}
    ...                                    value=${PING_Statistics['packet_loss']}
    ...                                    type=int
    ...                                    description=${description}
    ...                                    name=rtt_Packet_Loss
    ...                                    unit=packets

    ${rtt_min}    Copy Dictionary    ${RTT_KPI}
    Set To Dictionary    ${rtt_min}    target=${PING_Statistics['rtt_min']}
    ...                                value=${PING_Statistics['rtt_min']}
    ...                                type=float
    ...                                description=${description}
    ...                                name=rtt_Min
    ...                                unit=milliseconds

    ${rtt_max}    Copy Dictionary    ${RTT_KPI}
    Set To Dictionary    ${rtt_max}    target=${PING_Statistics['rtt_max']}
    ...                                value=${PING_Statistics['rtt_max']}
    ...                                type=float
    ...                                description=${description}
    ...                                name=rtt_Max
    ...                                unit=milliseconds

    ${rtt_avg}    Copy Dictionary    ${RTT_KPI}
    Set To Dictionary    ${rtt_avg}    target=${PING_Statistics['rtt_avg']}
    ...                                value=${PING_Statistics['rtt_avg']}
    ...                                type=float
    ...                                description=${description}
    ...                                name=rtt_Avg
    ...                                unit=milliseconds

    ${KPI_RESULTS}    Create List    ${packet_loss}
    ...                              ${rtt_min}
    ...                              ${rtt_max}
    ...                              ${rtt_avg}
    Set Suite Variable    ${KPI_RESULTS}

    taf.ue.Stop Data Transfer    DL_Background_${reservedUE}


Select MORAN site cells to be blocked and set them as test variable
    [Documentation]   This keyword returns the list DNs of cell MOCs to be blocked in a MORAN site for a specific target_rat / target_mno combination.
    ...    :param target_rat:    One of {LTE, NR}
    ...    :param target_mno:    One of {DTAG, TEF, DTAG-incomplete, TEF-incomplete}
    [Arguments]       ${target_rat}=LTE   ${target_mno}=DTAG

    ${bts_distNames}=   gnb.Get DistNames From GNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}

    IF   '${bts_distName}' == 'MRBTS-402321'                                                # TL232 - DTAG-TEF-MORAN-site ____________________________
       IF   '${target_rat}' == 'LTE' and '${target_mno}' == 'DTAG'                          # target_cell: LNCEL-0 (pci=32)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-3
          ...                                     ${bts_distName}/NRBTS-402321/NRCELL-13
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...               LNCEL_TO_BLOCK_LIST                      ${bts_distName}/LNBTS-452321/LNCEL-30
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'NR' and '${target_mno}' == 'DTAG'                      # target_cell: NRCELL-3 (pci=323)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-13
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-0
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-30
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'LTE' and '${target_mno}' == 'TEF'                      # target_cell: LNCEL-30 (pci=52)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-3
          ...                                     ${bts_distName}/NRBTS-402321/NRCELL-13
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-0
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'NR' and '${target_mno}' == 'TEF'                      # target_cell: NRCELL-13 (pci=110)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-0
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-30
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'NR' and '${target_mno}' == 'DTAG-incomplete'           # target_cell: NRCELL-3 (pci=323)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF  '${target_rat}' == 'NR' and '${target_mno}' == 'TEF-incomplete'             # target_cell: NRCELL-13 (pci=110)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-13
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-30
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${EMPTY}
          builtin.Log   Unsupported target_rat (${target_rat}) and target_mno (${target_mno}) combination! Returning empty list.
          ...           level=WARN   console=${True}
       END
    ELSE
       @{CELLS_TO_BLOCK_LIST}=   Create List   ${EMPTY}
       builtin.Log   Running KW 'Select MORAN site cells to be blocked' on a unsupported TL (${bts_distName}). Returning empty list.
       ...           level=WARN   console=${True}
    END

    Set Test Variable     @{CELLS_TO_BLOCK_LIST}
    ${CELLS_TO_BLOCK_LIST_pretty_str}=    builtin.Evaluate   pprint.pformat(@{CELLS_TO_BLOCK_LIST})   modules=pprint
    builtin.Log To Console    \ The list of cells that will be blocked during the following test is:\n${CELLS_TO_BLOCK_LIST_pretty_str}

    RETURN    @{CELLS_TO_BLOCK_LIST}


Select for Voice Call Test Scenarios the MORAN site cells to be blocked and set them as test variable
    [Documentation]   This keyword is designed for usage with mobile originated (MO) or mobile terminated (MT) Voice Call test scenarios and
    ...    returns the list DNs of cell MOCs to be blocked in a MORAN site for a specific target_rat / target_mno / call_type combination
    ...    :param target_rat:    One of {LTE, NR}
    ...    :param target_mno:    One of {DTAG, TEF}
    ...    :param call_type:     One of {MO, MT}
    [Arguments]       ${target_rat}=LTE   ${target_mno}=DTAG   ${call_type}=MO

    ${bts_distNames}=   gnb.Get DistNames From GNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}

    IF   '${bts_distName}' == 'MRBTS-402321'                                                # TL232 - DTAG-TEF-MORAN-site ____________________________
       IF   '${target_rat}' == 'LTE' and '${target_mno}' == 'DTAG' and '${call_type}' in ['MO', 'EC']          # MO_UE_cell: LNCEL-0 (pci=32)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-3
          ...                                     ${bts_distName}/NRBTS-402321/NRCELL-13
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-30
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'NR' and '${target_mno}' == 'DTAG' and '${call_type}' in ['MO', 'EC']      # MO_UE_cell: NRCELL-3 (pci=323)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-13
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-0
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-30
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'LTE' and '${target_mno}' == 'TEF' and '${call_type}' in ['MO', 'EC']      # MO_UE_cell: LNCEL-30 (pci=52)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-3
          ...                                     ${bts_distName}/NRBTS-402321/NRCELL-13
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-0
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'NR' and '${target_mno}' == 'TEF' and '${call_type}' in ['MO', 'EC']       # MO_UE_cell: NRCELL-13 (pci=110)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-0
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-30
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'LTE' and '${target_mno}' == 'DTAG' and '${call_type}' == 'MT'             # MT_UE_cell: LNCEL-0 (pci=32)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-3                        # MO_UE_cell: LNCEL-30 (pci=52)
          ...                                     ${bts_distName}/NRBTS-402321/NRCELL-13
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'NR' and '${target_mno}' == 'DTAG' and '${call_type}' == 'MT'              # MT_UE_cell: NRCELL-3 (pci=323)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/LNBTS-452321/LNCEL-0                         # MO_UE_cell: NRCELL-13 (pci=110)
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-30
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'LTE' and '${target_mno}' == 'TEF' and '${call_type}' == 'MT'              # MT_UE_cell: LNCEL-30 (pci=52)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/NRBTS-402321/NRCELL-3                        # MO_UE_cell: LNCEL-0 (pci=32)
          ...                                     ${bts_distName}/NRBTS-402321/NRCELL-13
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE IF   '${target_rat}' == 'NR' and '${target_mno}' == 'TEF' and '${call_type}' == 'MT'               # MT_UE_cell: NRCELL-13 (pci=110)
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${bts_distName}/LNBTS-452321/LNCEL-0                         # MO_UE_cell: NRCELL-3 (pci=323)
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-3
          ...                                     ${bts_distName}/LNBTS-452321/LNCEL-30
          ...                                     ${bts_distName}/GNBTS-1/GNBCF-1/GNCEL-1
       ELSE
          @{CELLS_TO_BLOCK_LIST}=   Create List   ${EMPTY}
          builtin.Log   Unsupported target_rat (${target_rat}) and target_mno (${target_mno}) combination! Returning empty list.
          ...           level=WARN   console=${True}
       END
    ELSE
       @{CELLS_TO_BLOCK_LIST}=   Create List   ${EMPTY}
       builtin.Log   Running KW 'Select MORAN site cells to be blocked (for Voice Calls)' on a unsupported TL (${bts_distName}). Returning empty list.
       ...           level=WARN   console=${True}
    END

    Set Test Variable     @{CELLS_TO_BLOCK_LIST}
    ${CELLS_TO_BLOCK_LIST_pretty_str}=    builtin.Evaluate   pprint.pformat(@{CELLS_TO_BLOCK_LIST})   modules=pprint
    builtin.Log To Console    \ The list of cells that will be blocked during the following test is:\n${CELLS_TO_BLOCK_LIST_pretty_str}

    RETURN    @{CELLS_TO_BLOCK_LIST}
