*** Settings ***
Documentation    CB008917_C_c_TC056_cloud
Suite Setup       Run Keywords    Set CP Debug
...               AND    Import Testline Variables
...               AND    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
...               AND    Modify VlanId In SCF File    ${SCF_PATH}/${SW_BRANCH}/SCF/${SCF_FILE}
...               AND    Suite Setup Update GNB bj    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
...               AND    Start Gnb Cell Setup Log
...               AND    Start X2 Pcap Log
...               AND    Suite Setup Start WTS And Check OnAir

Suite Teardown    Common Suite Teardown bj
Test Setup        Common Test Setup
Test Teardown     Run Keywords    Common Test Teardown bj


Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD
...               RAN_5G_FDD    FR1    Owner_YaqinWang   SBTS00    SBTS23R1    CRT

Resource        ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_setup_teardown_bj.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_test_env_setup_bj.robot
Resource        ./case_keyword.robot
Library         ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_prbs_pdsch_pusch_prb_blanking
Library         ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_csi_rs_rb_start_and_nr_for_blanking
Library         ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_numalloccellprb_pooling



*** Variables ***
&{GNB_ASIK}         ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
${SCF_PATH}         ${CURDIR}/resources/config/
${SCF_FILE}         SCF_FDD_Band8SA_0_21_pooling.xml
${IPHY_FILE}        ${CURDIR}/iphy_1cell_SANSA_band8_AHPDA.xml
${UE_ID}            1
${PROFILE_ID}       1
${GNB_ID}           2
${CELL_ID}          1
@{LOG_NAME_LIST}    btslog   x2pcap
${COUNT}            0
${UE_NUMS}          10
${pass_procedure}   ${False}
${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
${WTS_CFG}          basic_setup_1cell_SANSA_nr8_eutra5.cfg
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
    ...     ${CURDIR}/resources/5G_test_syslog.json
    Run Keyword If      ${syslog_chk} == False      Log To Console  Log Analysis Fail!
    Log To Console          =============================End syslog checker==============================

PRB Blanking PUSCH PDSCH checer
    Log To Console          ${EMPTY}
    Log To Console          =============================Start PRB Blanking checker============================
    verify_prbs_pdsch_pusch_prb_blanking    log_path=${TEST_LOG_DIRECTORY}
    ...     scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml     pcap_file=${TEST_LOG_DIRECTORY}/wireshark_gnb.txt
    ...     tti_dl_file=${tti_dl_file}    tti_ul_file=${tti_ul_file}
    Log To Console          =============================End PRB Blanking checker==============================

check_csi_rs_rb_start_and_nr_for_blanking
    Log To Console                                starting verify_starting_rb_and_nr_of_rbs
    verify_csirs_rb_start_and_nr_for_blanking       log_path=${TEST_LOG_DIRECTORY}
    ...     scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml    egate_file=${egate_log_path}
    Log To Console                                verify_starting_rb_and_nr_of_rbs  passed

check_numalloccellprb_pooling
    Log To Console          ${EMPTY}
    Log To Console          =============================Start Pooling with PRB Blanking checker=======================
    verify_numalloccellprb_pooling    log_path=${TEST_LOG_DIRECTORY}
    ...     scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml     pcap_file=${TEST_LOG_DIRECTORY}/wireshark_gnb.txt
    ...     tti_dl_file=${tti_dl_file}    tti_ul_file=${tti_ul_file}
    Log To Console          =============================End Pooling with PRB Blanking checker=========================

Stop And Download Via gnb logs Case
    Log To Console    pass_procedure:${pass_procedure}
    Run Keyword If    ${pass_procedure} != ${true}     Stop And Download Via gnb logs

*** Test Cases ***
CB008917-C-c_TC056
    [Documentation]
    [Tags]    CRT    QC_6532    QCD_MN_RAN    QCP_RAN_VAL
	Stop X2 Pcap Log               ${TEST_LOG_DIRECTORY}

	Log To Console    Stop Gnb Cell Setup Log
	Stop Gnb Cell Setup Log    log_dir=${TEST_LOG_DIRECTORY}

	Log To Console    Convert BIP To TXT By MCShark
	Convert BIP To TXT By MCShark BJ   ${TEST_LOG_DIRECTORY}/wireshark_gnb.pcap
	...    ${TEST_LOG_DIRECTORY}/wireshark_gnb.txt   itf_l2_ps_cell_cellsetupreq

	sleep     10
    Log To Console    Install Ttitrace And MCshark
    Install Ttitrace And MCshark BJ
    sleep     2
	#     Start Ttitrace With Streaming Mode
    Log To Console    Start TTItrace
    Start Ttitrace With Streaming Mode bj
	sleep     2
    # SA UE attach
    SA 5G Attach bj                       ${UE_ID}
    SA Set Traffic Type To Internal bj    ${UE_ID}
    SA 5G PDU Session Setup bj            ${UE_ID}
    SA Start DL Traffic Internal bj       ${UE_ID}    ${UE_ID}    1    1    50
    SA Start UL Traffic Internal bj       ${UE_ID}    ${UE_ID}    1    1    20
    sleep                                 2s

    SA Stop DL Traffic Internal bj    ${UE_ID}    ${UE_ID}    1
    sleep                             2s
    SA Stop UL Traffic Internal bj    ${UE_ID}    ${UE_ID}    1
    sleep                             2s
    SA 5G Detach                      ${UE_ID}


    Log To Console     OUTPUT_DIR:${OUTPUT_DIR}
    Stop Ttitrace bj

    Common Test Log Capture

    set Suite variable     ${pass_procedure}    ${True}
    Set Suite Variable    ${egate_log_path}    ${TEST_LOG_DIRECTORY}/egate_console.log
    Backup Scf    ${TEST_LOG_DIRECTORY}    running

	Decode Ttitrace Log bj
    Set Suite Variable    ${tti_dl_file}      ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_dl.csv
    Set Suite Variable    ${tti_ul_file}      ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_ul.csv



    PRB Blanking PUSCH PDSCH checer
    check_csi_rs_rb_start_and_nr_for_blanking
    check_numalloccellprb_pooling


