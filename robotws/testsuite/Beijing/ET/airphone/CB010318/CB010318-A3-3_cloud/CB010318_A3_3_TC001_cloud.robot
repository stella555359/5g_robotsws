*** Settings ***
Documentation    CB010318-A_3_3 FCA_5G_L2L3-138191

Suite Setup       Run Keywords    Set CP Debug
#...               AND    Start To Capture Logs Via gnb logs on Gnb    gnb_ip=10.0.1.2    command_suf=-E
...               AND    Import Testline Variables
...               AND    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
...               AND    Send Swconfig File To Airphone    path=${swconfig_ap_file}
...               AND    Send Swconfig File To GNB    path=${SCF_PATH}/${SW_BRANCH}/SWCONFIG/swconfig.txt
...               AND    Modify VlanId In SCF File    ${SCF_PATH}/${SW_BRANCH}/SCF/${SCF_FILE}
...               AND    Suite Setup Update GNB bj    scf_file=${SCF_FILE}    iphy_file=${iphy_file}
#...               AND    Suite Setup Update GNB
#...               AND    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM}    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Add Multi UE NSA    ${UE_NUMS}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Start To Capture Logs Via gnb logs    gnb_ip=10.0.1.2    command_suf=-t -b -cp -c -E
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown bj
Test Setup        Common Test Setup
Test Teardown     Run Keywords    Common Test Teardown bj
#...               AND    Stop And Download Via gnb logs Case
#...               AND    egate_checker
#...               AND    syslog_checker


Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    FR1    Owner_yanhwei   SBTS00    SBTS22R3    CRT

#Resource          ${EXECDIR}/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/common_setup_teardown.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_setup_teardown_bj.robot
Resource          ./case_keyword.robot
Resource          ./TC01.robot
#Library           ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/bip/bip_mirroring_asil.py
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB007601/tdra_check.py
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008593/check_cb8593_adaptive_sr
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008534/check_cell_csi_rs_allocation
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/info_checker

*** Variables ***
&{GNB_ASIK}         ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
${SCF_PATH}         ${CURDIR}/resources/config/
${DELTA_FILE}       Delta_Conf_CB007601-A_1-1_TC001.json
#${SCF_FILE}         Configuration_scf_MRBTS-1_O-RAN_TL-BM69_BF_20230406-0653.xml
${SCF_FILE}         Configuration_scf_MRBTS-1_O-RAN_TL-BM69_BF_20231019-1729_enable10513.xml
${iphy_file}        ${CURDIR}/resources/wts/iphy_8458_from_8141.xml
${swconfig_ap_file}        ${CURDIR}/resources/wts/swconfig.txt
#${swconfig_gnb_file}       ${SCF_PATH}/${SW_BRANCH}/SWCONFIG/swconfig.txt
#${swconfig_gnb_file}       ${SCF_PATH}/swconfig.txt
${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
#${WTS_CFG}          wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
${WTS_CFG}          basiccfg_vonr_uecap_uma_TC01.lua

${UE_ID}            1
${PROFILE_ID}       1
${GNB_ID}           2
${CELL_ID}          1
${BEARER_ID}        2
# gnbbip apbip log doesn't work
#@{LOG_NAME_LIST}    btslog    snapshot  tcpdump  x2pcap  ttitrace  sherpa  tshark  apl3l1
@{LOG_NAME_LIST}    btslog   x2pcap
${COUNT}            0
${UE_NUMS}          10
${pass_procedure}   ${False}

@{LOG_NAME_SUITE_TEARDOWN}    utefiles


${UE_NR_CAP_TDD}        E1A00000074E5A131E0003832001E09306400043C24026C030E7CC31E50B03826010180E01951B0A35820286809659
...                     44C2C01EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261600F5B0404041C3
...                     BC70E418700040C9E3EAE0009E00380027800546C4DD6080A5A02596513000005803D6C10101073EF1CF9863DF3E4F
...                     278FAB80027800E0009E00151B13B582028680965944C2C01EB608080838778E1C830E0008193C7D54000014000000
...                     420E26800000001013444000E010113D84C00C000A070500703009801C001A0F800000000000039534000400002596
...                     5400D2AAA12007000B000000040080118B130001020304050607080B101112131921252627284A

${UE_EUTRA_NR_CAP_TDD}    211C04C160801C4D00000005F800000000020120268A8000C80C03639F0C06000200020100801002
*** Keywords ***
egate checker
    Log To Console          ${EMPTY}
    Log To Console          =============================Start egate checker==============================
    ${egate_log_chk}    Common Analysis For Egate     ${SUITE_LOG_DIRECTORY}    ${egate_log_path}
    ...    ${CURDIR}/resources/5G_test_egate.json
    Run Keyword If      ${egate_log_chk} == ${false}      Log To Console    Log Analysis Fail!
    Log To Console          =============================End egate checker==============================
syslog checker
    Tar Gnb syslog by log path    ${SUITE_LOG_DIRECTORY}
    Log To Console          ${EMPTY}
    Log To Console          =============================Start syslog checker==============================
    ${syslog_chk}       Common Analysis For Syslog     ${SUITE_LOG_DIRECTORY}    ${SYSLOG_LIST}
    ...    ${CURDIR}/resources/5G_test_syslog.json
    Run Keyword If      ${syslog_chk} == False      Log To Console  Log Analysis Fail!
    Log To Console          =============================End syslog checker==============================

tdra checker
    [Documentation]    test keywords
    Log To Console          ${EMPTY}
    Log To Console          =============================Start tdra checker==============================
    ${tdra_chk}    tdra_check_py    log_path=${TEST_LOG_DIRECTORY}     scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml
    ...    egate_file=${egate_log_path}
#    ${syslog_chk}    Common Analysis For Syslog     ${TEST_LOG_DIRECTORY}    ${SYSLOG_LIST}
#   ...    ${CURDIR}/5G_test_syslog.json
    Run Keyword If      ${tdra_chk} == False      Log To Console  Log Analysis Fail!
    Log To Console          =============================End tdra checker==============================

cell_csi_rs_allocation_checker
    Log To Console                       starting verify_cell_csi_rs_allocation
    verify_cell_csirs_allocation            log_path=${TEST_LOG_DIRECTORY}
    ...    scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml                      msg_file=${egate_log_path}
    Log To Console                       verify_cell_csi_rs_allocation passed
Stop And Download Via gnb logs Case
    Log To Console    pass_procedure:${pass_procedure}
    Run Keyword If    ${pass_procedure} != ${true}     Stop And Download Via gnb logs on Gnb

*** Test Cases ***
CB010318_A3_3_TC001
    [Documentation]    CB010318-A_3_3 FCA_5G_L2L3-138191
    [Tags]    CRT    QC_6534    QCD_MN_RAN    QCP_RAN_VAL    CRT_lv
#    Start GNB BIP Log By gnbMirroring BJ
#    Start X2 Pcap Log
#    Start Ttitrace With Streaming Mode

    sleep     10
    Start X2 Pcap Log

    # SA UE
    Log To Console    start TC01 execution
    10318_TC01

    Common Test Log Capture

#    Run Keyword And Continue On Failure    Stop BIP Log On GNB FCT BJ

    set Suite variable     ${pass_procedure}    ${True}
    Stop X2 Pcap Log               ${TEST_LOG_DIRECTORY}
    Set Suite Variable    ${egate_log_path}    ${TEST_LOG_DIRECTORY}/egate_console.log
    Backup Scf    ${TEST_LOG_DIRECTORY}    running
