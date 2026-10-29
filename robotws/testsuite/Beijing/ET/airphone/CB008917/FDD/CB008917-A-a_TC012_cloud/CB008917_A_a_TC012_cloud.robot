*** Settings ***
Suite Setup       Run Keywords    Set CP Debug
...               AND    Import Testline Variables
...               AND    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
...               AND    Send Swconfig File To GNB    path=${CURDIR}/swconfig_gnb/swconfig.txt
...               AND    Modify VlanId In SCF File    ${SCF_PATH}/${SW_BRANCH}/SCF/${SCF_FILE}
...               AND    Suite Setup Update GNB bj    scf_file=${SCF_FILE}    iphy_file=${iphy_file}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
...               AND    Modify GSCN On Airphone    50    5342
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown bj
Test Setup        Common Test Setup
Test Teardown     Run Keywords    Common Test Teardown bj


Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD
...               RAN_5G_FDD    FR1    Owner_YaqinWang   SBTS00    SBTS23R1    CRT



#Resource          ${EXECDIR}/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/common_setup_teardown.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_setup_teardown_bj.robot
Resource          ./case_keyword.robot
#Library           ${EXECDIR}/testsuite/Beijing/et/airphone/resources/bip/bip_mirroring_asil.py
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_location_and_bandwidth
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/gscn_check.py


*** Variables ***
&{GNB_ASIK}         ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
${SCF_PATH}         ${CURDIR}/resources/config/
${DELTA_FILE}       Delta_Conf_CB007601-A_1-1_TC001.json
${SWCONFIG_GNB}      ${CURDIR}/swconfig_gnb/swconfig.txt
${SCF_FILE}         SCF_FDD_20220803_50PRBSA.xml
${iphy_file}        ${CURDIR}/resources/wts/iphy.xml
${UE_ID}            3
${PROFILE_ID}       1
${GNB_ID}           2
${CELL_ID}          1
@{LOG_NAME_LIST}    btslog
${COUNT}            0
${UE_NUMS}          10
${pass_procedure}   ${False}
${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
${WTS_CFG}          basic_setup_1cell_SANSA_band1_nr1_eutra5.cfg
${swconfig_param}   0x420028=0

@{LOG_NAME_SUITE_TEARDOWN}    utefiles



*** Keywords ***
egate checker
    Log To Console          ${EMPTY}
    Log To Console          =============================Start egate checker==============================
    ${egate_log_chk}    Common Analysis For Egate     ${SUITE_LOG_DIRECTORY}    ${egate_log_path}
    ...     ${CURDIR}/resources/5G_test_egate.json
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

location_and_bandwidth_checker
    Log To Console                       starting verify_location_and_bandwidth
    verify_location_and_bandwidth        log_path=${TEST_LOG_DIRECTORY}
    ...     scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml    msg_file=${egate_log_path}    tti_dl_file=${tti_dl_file}
    ...     tti_ul_file=${tti_ul_file}
    Log To Console                       verify_location_and_bandwidth passed

gscn checker
    Log To Console          ${EMPTY}
    Log To Console          =============================Start gscn checker==============================
    ${gscn_log_chk}    gscn_check_py     log_path=${TEST_LOG_DIRECTORY}
    ...     scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml     egate_file=${egate_log_path}
    Run Keyword If      ${gscn_log_chk} == ${false}      Log To Console    GSCN Log Analysis Fail!
    Log To Console          =============================End gscn checker==============================

Stop And Download
    gnb logs Case
    Log To Console    pass_procedure:${pass_procedure}
    Run Keyword If    ${pass_procedure} != ${true}     Stop And Download Via gnb logs on Gnb

*** Test Cases ***
CB008917-A-a_TC012
    [Documentation]
    [Tags]    CRT    QC_6533    QCD_MN_RAN    QCP_RAN_VAL
     Log To Console    Install Ttitrace And MCshark
     Install Ttitrace And MCshark BJ

#     Start Ttitrace With Streaming Mode
     Log To Console    Start X2,AP/Gnb BIP Log and Emil log on ABIO+ASIL
     Start Ttitrace With Streaming Mode bj

     sleep    2

    # SA UE
    SA 5G Attach bj                       ${UE_ID}
    SA Set Traffic Type To Internal bj    ${UE_ID}
    SA 5G PDU Session Setup bj            ${UE_ID}
    SA Start DL Traffic Internal bj       ${UE_ID}    ${UE_ID}    1    1    50
    SA Start UL Traffic Internal bj       ${UE_ID}    ${UE_ID}    1    1    20
    sleep                                 2s

    SA UE Check Throughput bj      ${UE_ID}    ${UE_ID}    5    1    1

    SA Stop DL Traffic Internal bj    ${UE_ID}    ${UE_ID}    1
    sleep                             2s
    SA Stop UL Traffic Internal bj    ${UE_ID}    ${UE_ID}    1
    sleep                             2s
    SA 5G Detach                      ${UE_ID}

    Stop Ttitrace bj
    Common Test Log Capture

    set Suite variable     ${pass_procedure}    ${True}
    Set Suite Variable    ${egate_log_path}    ${TEST_LOG_DIRECTORY}/egate_console.log
    Backup Scf    ${TEST_LOG_DIRECTORY}    running

	Decode Ttitrace Log bj
    Set Suite Variable    ${tti_dl_file}      ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_dl.csv
    Set Suite Variable    ${tti_ul_file}      ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_ul.csv

    location_and_bandwidth_checker
    gscn checker



