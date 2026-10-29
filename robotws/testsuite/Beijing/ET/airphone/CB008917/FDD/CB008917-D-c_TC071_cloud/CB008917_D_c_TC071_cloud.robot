*** Settings ***
Documentation    CB008917_D_c_TC071_cloud
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
Resource        ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_test_env_setup_bj.robot
Resource        ./case_keyword.robot
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_prbs_pdsch_pusch_prb_blanking
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_numalloccellprb_pooling
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_srs_configuration
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_location_and_bandwidth
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_csi_rs_rb_start_and_nr
*** Variables ***
&{GNB_ASIK}         ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
${SCF_PATH}         ${CURDIR}/resources/config/
${SCF_FILE}         Configuration_scf_MRBTS-1_20220908-1421_10M_45PRB_dedicateBWP_pooling.xml
${IPHY_FILE}        ${CURDIR}/iphy_1cell_SANSA_band1_AHEGF.xml
${UE_ID}            1
${PROFILE_ID}       1
${GNB_ID}           2
${CELL_ID}          1
${BEARER_ID}        2
@{LOG_NAME_LIST}    btslog   x2pcap
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


check_numalloccellprb_pooling
    Log To Console          ${EMPTY}
    Log To Console          =============================Start Pooling with PRB Blanking checker=======================
    verify_numalloccellprb_pooling    log_path=${TEST_LOG_DIRECTORY}
    ...     scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml     pcap_file=${TEST_LOG_DIRECTORY}/wireshark_gnb.txt
    ...     tti_dl_file=${tti_dl_file}    tti_ul_file=${tti_ul_file}
    Log To Console          =============================End Pooling with PRB Blanking checker=========================

srs_configuration_checker
    Log To Console                                starting verify_srs_configuration
    verify_srs_configuration        log_path=${TEST_LOG_DIRECTORY}    scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml
    ...     emil_file=${emil_output_file}    pcap_file=${TEST_LOG_DIRECTORY}/wireshark_gnb.txt
    Log To Console                                verify_srs_configuration  passed

location_and_bandwidth_checker
    Log To Console                       starting verify_location_and_bandwidth
    verify_location_and_bandwidth        log_path=${TEST_LOG_DIRECTORY}
    ...     scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml    msg_file=${egate_log_path}
    ...     tti_dl_file=${tti_dl_file}    tti_ul_file=${tti_ul_file}
    Log To Console                       verify_location_and_bandwidth passed

csirs_rb_start_and_nr_checker
    Log To Console                                starting verify_csirs_rb_start_and_nr
    verify_csirs_rb_start_and_nr        log_path=${TEST_LOG_DIRECTORY}
    ...     scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml    pcap_file=${TEST_LOG_DIRECTORY}/wireshark_gnb.txt
    ...     egate_file=${egate_log_path}
    Log To Console                                verify_csirs_rb_start_and_nr  passed

Stop And Download Via gnb logs Case
    Log To Console    pass_procedure:${pass_procedure}
    Run Keyword If    ${pass_procedure} != ${true}     Stop And Download Via gnb logs on Gnb

*** Test Cases ***
CB008917-D-c_TC071
    [Documentation]
    [Tags]    CRT    QC_6529    QCD_MN_RAN    QCP_RAN_VAL
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


    Log To Console    SA UE attach
    SA 5G Attach    ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}

    SA Start DL Traffic    5    20
    SA Start UL Traffic    1    20


    SA Stop DL Traffic
    SA Stop UL Traffic

    SA 5G Detach    ${UE_ID}
   Log To Console     OUTPUT_DIR:${OUTPUT_DIR}
    Stop Ttitrace bj

    Common Test Log Capture

    set Suite variable     ${pass_procedure}    ${True}
    Set Suite Variable    ${egate_log_path}    ${TEST_LOG_DIRECTORY}/egate_console.log
    Backup Scf    ${TEST_LOG_DIRECTORY}    running

	Decode Ttitrace Log bj
    Set Suite Variable    ${tti_dl_file}      ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_dl.csv
    Set Suite Variable    ${tti_ul_file}      ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_ul.csv

    location_and_bandwidth_checker
	csirs_rb_start_and_nr_checker
	check_numalloccellprb_pooling
