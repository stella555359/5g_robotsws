*** Settings ***
Suite Setup       Run Keywords    Set CP Debug
...               AND    Import Testline Variables
...               AND    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
...               AND    Send Swconfig File To Airphone    path=${swconfig_ap_file}
...               AND    Send Swconfig File To GNB    path=${SCF_PATH}/${SW_BRANCH}/SWCONFIG/swconfig.txt
...               AND    Modify VlanId In SCF File    ${SCF_PATH}/${SW_BRANCH}/SCF/${SCF_FILE}
...               AND    Suite Setup Update GNB bj    scf_file=${SCF_FILE}    iphy_file=${iphy_file}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
...               AND    Start Gnb Cell Setup Log
#...               AND    Start To Capture Logs Via gnb logs    gnb_ip=10.0.1.2    command_suf=-E -cp
...               AND    Start X2 Pcap Log
...               AND    Suite Setup Start WTS And Check OnAir

Suite Teardown    Common Suite Teardown bj
Test Setup        Common Test Setup
Test Teardown     Run Keywords    Common Test Teardown bj

Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    FR1    Owner_yanhwei   SBTS00    SBTS22R3    CRT

#Resource          ${EXECDIR}/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/common_setup_teardown.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_setup_teardown_bj.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_test_env_setup_bj.robot
Resource          ./case_keyword.robot
#Library           ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/bip/bip_mirroring_asil.py
#Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_location_and_bandwidth
#Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_csi_rs_rb_start_and_nr
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_srs_configuration
#Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB008917/check_pdcch_coreset_and_initial_bwp


*** Variables ***
&{GNB_ASIK}         ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
${SCF_PATH}         ${CURDIR}/resources/config/
${DELTA_FILE}       Delta_Conf_CB007601-A_1-1_TC001.json
${SCF_FILE}         Configuration_scf8917_tc46_tdd40M100prb_cloud.xml
${iphy_file}        ${CURDIR}/resources/wts/iphy.xml
${swconfig_ap_file}        ${CURDIR}/resources/wts/swconfig.txt
${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
${WTS_CFG}          wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC-4SA_ARFCN.cfg
${UE1_ID}            1
${UE2_ID}            2
${UE3_ID}            3
${UE_ID}            1
${PROFILE_ID}       1
${GNB_ID}           2
${CELL_ID}          1
${BEARER_ID}        2
# gnbbip apbip log doesn't work
#@{LOG_NAME_LIST}    btslog    snapshot  tcpdump  x2pcap  ttitrace  sherpa  tshark  apl3l1
#@{LOG_NAME_LIST}    btslog   x2pcap
@{LOG_NAME_LIST}    x2pcap
@{LOG_NAME_SUITE_SETUP}            x2pcap
${COUNT}            0
${UE_NUMS}          10
${pass_procedure}   ${False}
#&{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443


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
#...    ${CURDIR}/5G_test_syslog.json
    Run Keyword If      ${tdra_chk} == False      Log To Console  Log Analysis Fail!
    Log To Console          =============================End tdra checker==============================

location_and_bandwidth_checker
    Log To Console                       starting verify_location_and_bandwidth
    verify_location_and_bandwidth        log_path=${TEST_LOG_DIRECTORY}
    ...    scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml    msg_file=${egate_log_path}
    ...    tti_dl_file=${tti_dl_file}    tti_ul_file=${tti_ul_file}
    Log To Console                       verify_location_and_bandwidth passed

csi_rs_starting_rb_and_nr_of_rbs_checker
    Log To Console                                starting verify_csirs_starting_rb_and_nr_of_rbs
    verify_csirs_starting_rb_and_nr_of_rbs        log_path=${TEST_LOG_DIRECTORY}
    ...    scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml    pcap_file=${bip_pcap_txt_file}
    ...    egate_file=${egate_log_path}
    Log To Console                                verify_csirs_starting_rb_and_nr_of_rbs  passed

srs_configuration_checker
    Log To Console                                starting verify_srs_configuration
    verify_srs_configuration        log_path=${TEST_LOG_DIRECTORY}    scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml
    ...    emil_file=${emil_output_file}    pcap_file=${TEST_LOG_DIRECTORY}/wireshark_gnb.txt
#    verify_srs_configuration        log_path=${TEST_LOG_DIRECTORY}    scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml
#...    emil_file=${emil_output_file}    pcap_file=${bip_pcap_txt_file}    egate_file=${egate_log_path}
    Log To Console                                verify_srs_configuration  passed

Pdcch_Coreset_And_Initial_Bwp_checker
    Log To Console                                starting verify_pdcch_coreset_and_initial_bwp
#    verify_pdcch_coreset_and_initial_bwp        log_path=${TEST_LOG_DIRECTORY}
#...    scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml    emil_file=${emil_output_file}
#...    pcap_file=${bip_pcap_txt_file}
    verify_pdcch_coreset_and_initial_bwp        log_path=${TEST_LOG_DIRECTORY}
    ...    scf_file=${TEST_LOG_DIRECTORY}/SCF_running.xml    emil_file=${emil_output_file}
    ...    pcap_file=${bip_pcap_txt_file}    egate_file=${egate_log_path}
    Log To Console                                verify_pdcch_coreset_and_initial_bwp  passed


Stop And Download Via gnb logs Case
    Log To Console    pass_procedure:${pass_procedure}
    Run Keyword If    ${pass_procedure} != ${true}     Stop And Download Via gnb logs on Gnb

*** Test Cases ***
CB008917-A-c_TC046
    [Documentation]    CB008917-A-c_TC046_N77_TDD_BWP100_40M__SA_multiue_config2_CRCNG
    [Tags]    CRT    QC_6527    QCD_MN_RAN    QCP_RAN_VAL

	Stop X2 Pcap Log               ${TEST_LOG_DIRECTORY}

	Log To Console    Stop Gnb Cell Setup Log
	Stop Gnb Cell Setup Log    log_dir=${TEST_LOG_DIRECTORY}

	Log To Console    Convert BIP To TXT By MCShark
	Convert BIP To TXT By MCShark BJ   ${TEST_LOG_DIRECTORY}/wireshark_gnb.pcap
	...    ${TEST_LOG_DIRECTORY}/wireshark_gnb.txt   itf_l2_ps_cell_cellsetupreq

    Log To Console    start_dcap_controller_py
    start_dcap_controller_py

#	Log To Console    DCM ET UTF Lab Controller Start
#	DCM ET UTF Lab Controller Start

	Log To Console    Start Emil Log by DCAP
	DCAP start collect log    cp_5g

	sleep     10
    Log To Console    attach 3 SA UE
    SA 5G Attach bj    ${UE1_ID}

    SA Set Traffic Type To Internal bj    ${UE1_ID}
    SA 5G PDU Session Setup bj    ${UE1_ID}

    Log To Console    make UL/DL 50M traffic


    SA Start DL Traffic Internal bj   ${UE1_ID}   ${UE1_ID}   1   2   1
#	SA Start UL Traffic Internal bj   ${UE1_ID}   ${UE1_ID}   1   2   50

    SA 5G Attach bj    ${UE2_ID}

    SA Set Traffic Type To Internal bj    ${UE2_ID}

    SA 5G PDU Session Setup bj    ${UE2_ID}

    Log To Console    make UL/DL 50M ue2 traffic
    SA Start DL Traffic Internal bj   ${UE2_ID}   ${UE2_ID}   1   2   8
#	SA Start UL Traffic Internal bj   ${UE2_ID}   ${UE2_ID}   1   2   50

    SA 5G Attach bj    ${UE3_ID}

    SA Set Traffic Type To Internal bj    ${UE3_ID}

    SA 5G PDU Session Setup bj    ${UE3_ID}

	Log To Console    make UL/DL 50M ue3 traffic
    SA Start DL Traffic Internal bj   ${UE3_ID}   ${UE3_ID}   1   2   10
#	SA Start UL Traffic Internal bj   ${UE3_ID}   ${UE3_ID}   1   2   50

    Start Ttitrace With Streaming Mode bj

    # NSA UE
    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
    Set Suite Variable    ${UE_ID}    ${UE_ID}
#    NSA NR And Eutra UE Param Set    ${UE_ID}    ${UE_NR_CAP_TDD}    ${UE_EUTRA_NR_CAP_TDD}
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
#   NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    ${dl_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
    Log    DL Troughput is ${dl_tp}    console=True
#    ${ul_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    ul
#    Log    UL Troughput is ${ul_tp}    console=True

#    NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    dl
#    NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    ul
#    Log To Console     NSA LTE Detach
#    NSA LTE Detach    ${UE_ID}
    SA Start DL Traffic Internal bj   ${UE3_ID}   ${UE3_ID}   1   2   80
    SA Start DL Traffic Internal bj   ${UE2_ID}   ${UE2_ID}   1   2   80
    SA Start DL Traffic Internal bj   ${UE1_ID}   ${UE1_ID}   1   2   10

	sleep   1


    Log To Console     Case scenario completed

    Log To Console     OUTPUT_DIR:${OUTPUT_DIR}
    Stop Ttitrace bj


#	Stop And Download Via Gnb Logs

	Log To Console    Stop And Collect Emil Log
	DCAP stop collect log

	Log To Console    DCAP_EMIL_DECODER
	${emil_output_file}     DCAP_EMIL_DECODER
	set Suite variable     ${emil_output_file}
	Log To Console    ${emil_output_file}

    Common Test Log Capture

    set Suite variable     ${pass_procedure}    ${True}
#    Stop X2 Pcap Log               ${TEST_LOG_DIRECTORY}
    Set Suite Variable    ${egate_log_path}    ${TEST_LOG_DIRECTORY}/egate_console.log
    Backup Scf    ${TEST_LOG_DIRECTORY}    running

#	Decode Ttitrace Log bj
#    Set Suite Variable    ${tti_dl_file}      ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_dl.csv
#    Set Suite Variable    ${tti_ul_file}      ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_ul.csv


#	[Teardown]    DCAP stop collect log    ${trace_id}    log_save_path=${LOG_PATH}/dcp1/


#    Connect To UTE
#	${emil_bip_path}    Unzip Emil File with Name    name=m
#    Log To Console     ${emil_bip_path}
#	${bip_pcap_txt_file}     Convert Pcap To Text UTE    source=${emil_bip_path}/CPlane_E1F1.pcap
#...    filter=itf_l2_ps_cell_cellsetupreq
#	Log To Console     bip Pcap txt:${bip_pcap_txt_file}
#	set Suite variable     ${bip_pcap_txt_file}

#    Connect To UTE
#	${emil_path}    Unzip Emil File with Name    name=Emil
#    Log To Console     ${emil_path}
#	Connect To Emil
#	Log To Console       Connected to Emil done
#	Log To Console       Converting Emil file
#	${emil_output_file}     Convert Emil To Text    source=${emil_path}/emil/mon.0.emil.5gm    emil_protocol=5G
#	${emil_output_file}     Convert Emil To Text    source=${emil_file}    emil_protocol=5G
#	set Suite variable     ${emil_output_file}

	srs_configuration_checker
