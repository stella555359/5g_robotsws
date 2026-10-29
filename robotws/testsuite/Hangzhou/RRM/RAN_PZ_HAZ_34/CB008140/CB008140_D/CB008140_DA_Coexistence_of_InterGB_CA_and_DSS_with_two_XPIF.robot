#*** Settings ***
#Documentation     author: qingqing zhang
#...                 contact: qingqing.zhang@nokia-sbell.com
#...                 squad group: SG_03
#...                 feature : CB008140-DA
#
#Resource    ./../Resources/CB008140_common_keywords.robot
#
#
#
#Suite Setup     Run Keywords
#...               robot_common_operations.Common Suite Setup    AND
#...               Run Keyword And Ignore Error    Common Suite Setup for COAM
#
#Suite Teardown    Run Keywords
#...               robot_common_operations.Common Suite Teardown    AND
#...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${gnb_path}    /tmp/
#${tl_scf_filename_gnb1}    Configuration_scf_GNB1_CB008140_DA.xml
#${tl_scf_filename_gnb2}    Configuration_scf_GNB2_CB008140_380.xml
#${tl_scf_filename_enb}    Configuration_scf_ENB_CB008140_DSS.xml
#${logname_gnb1}       XP_setup_gnb1.pcap
#${logname_gnb2}       XP_setup_gnb2.pcap
#${interface1}    any
#@{ALLOWED_FAULT}    61652    61524    61649    9000    4592    4527    1932    4334    61074    61618    4687    4655    4654    6450
#*** Test Cases ***
#[1]CB008140-5G-DA_006_Coexistence_of_InterGB_CA_and_DSS_with_two_XPIF
#    [Documentation]
#    ...    This case is the successful XP setup procedure for the inter-gNB CA between gNB-DUs which can act as
#    ...    both prime gNB-DU and external gNB-DU
#    [Tags]    classical    CRT_TRUNK    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Commission SCF with two gnb
#    COAM gNB Reset site via api    is_need_check_cell_onair=False    wait_for_reconnection=False
#    COAM gNB Reset site via api    gnb_index=${4}    is_need_check_cell_onair=False    wait_for_reconnection=False
#    Wait until keyword succeeds    5min    1s    Connect to gnb    gnb_index=${0}
#    Wait until keyword succeeds    5min    2s    Start capture gNB log on master    filename=${logname_gnb1}    gNB_index=${0}
#    Wait until keyword succeeds    5min    2s    Start capture gNB log on master    filename=${logname_gnb2}    gNB_index=${4}
#    Wait until keyword succeeds    10 min    20s    Check the cells status on air    bts_host=${bts_host0}
#    Wait until keyword succeeds    10 min    20s    Check the cells status on air    bts_host=${bts_host4}
#    Stop and download the Logs    filename=${logname_gnb1}    gNB_index=${0}
#    Stop and download the Logs    filename=${logname_gnb2}    gNB_index=${4}
#    Check wireshark log for 001    logname_gnb1=${logname_gnb1}    logname_gnb2=${logname_gnb2}
#    Check only default Fault Present    ${gnb_index}=${0}
#    Check only default Fault Present    ${gnb_index}=${4}
#    [Teardown]    Run Keyword And Ignore Error    Case Teardown
#
#
#*** Keywords ***
#Check wireshark log for 001
#    [Arguments]    ${logname_gnb1}    ${logname_gnb2}
#    ${gNb1Id_DEC}    Gnb id conversion    WEBUI_COAM=${WEBUI_host0}
#    set suite variable    ${gNb1Id_DEC}
#    ${gNb2Id_DEC}    Gnb id conversion    WEBUI_COAM=${WEBUI_host4}
#    set suite variable    ${gNb2Id_DEC}
#    Check XP setup procedure    logname=${logname_gnb1}   prime_gnb_index=${xnap_gnb1}    gnb_ID=${gNb2Id_DEC}
#    ...    XP_Status=${1}
#    Check XP setup procedure    logname=${logname_gnb2}    prime_gnb_index=${xnap_gnb5}    gnb_ID=${gNb1Id_DEC}
#    ...    XP_Status=${1}
#
#Check XP setup procedure
#    [Arguments]    ${logname}    ${prime_gnb_index}    ${gnb_ID}    ${XP_Status}
#    Check IgNBCAXpSetupRequest message    logname=${logname}    gnb_ID=${gnb_ID}
#    Check IgNBCAXpSetupResponse message    logname=${logname}    gnb_ID=${gnb_ID}    XP_Status=${XP_Status}
#    Check IgNBCAconfigurationUpdateIndication message    logname=${logname}    soure_ip=${prime_gnb_index}
#
#Commission SCF with two gnb
#     Common Case TestLine Setup with singe BTS
#     ...    gnb_index=${0}    is_commission=True    golden_scf_name=${tl_scf_filename_gnb1}
#     ...    Enb_commission=False    enb_scf=${tl_scf_filename_enb}
#     Common Case TestLine Setup with singe BTS
#     ...    gnb_index=${4}    is_commission=True    golden_scf_name=${tl_scf_filename_gnb2}
