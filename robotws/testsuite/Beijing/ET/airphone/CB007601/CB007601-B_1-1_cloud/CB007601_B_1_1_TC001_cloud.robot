*** Settings ***
Suite Setup       Run Keywords    Set CP Debug
#...               AND      Start To Capture Logs Via gnb logs    gnb_ip=10.0.1.2    command_suf=-E -b -T
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
#...               AND    Start To Capture Logs Via gnb logs on Gnb    path=/user/toor4nsn/gnb_logs_2.31
#...               gnb_ip=10.0.1.2    command_suf=-E -b -T
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown bj
Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
Test Teardown     Run Keywords    Common Test Teardown bj
#...               AND    Stop And Download Via gnb logs Case
#...               AND    5G_keywords_egate_checker
#...               AND    5G_keywords_syslog
#...               AND    Unzip Emil File
#...               AND    PCAP PARSER TEST
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    FR1    Owner_tracy   SBTS00    SBTS22R4    CRT

#Resource          ${EXECDIR}/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/common_setup_teardown.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_setup_teardown_bj.robot
Resource          ./case_keyword.robot
#Library           ${EXECDIR}/testsuite/Beijing/ET/resources/bip/bip_mirroring_asil.py
Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/CB007601/tdra_check.py

#pybot --pythonpath /home/ute/MN/UTE/robotws -v testline_name:5_3_UTE5GFT04019 -L
#...               trace -V /home/ute/testline_configuration/5_3_UTE5GFT04019 -d /
#...               home/ute/results /home/ute/MN/UTE/robotws/testsuite/Beijing/et/airphone/CB007601/CB007601-B_1-1
#...               /CB007601-B_1-1_TC001.robot
#cli_dcm_pybot_rp_et.py -a "-t 'CB007601-B_1-1_TC001_Aperiodic CSI with cell specific CSI-RS for TDD non beamforming
#...               cells' --pythonpath /home/ute/MN/UTE/robotws -v testline_name:5_3_UTE5GFT04019 -L trace -V
#...               /home/ute/testline_configuration/5_3_UTE5GFT04019 -d /home/ute/results /home/ute/MN/UTE/robotws
#...               /testsuite/Beijing/et/airphone/CB007601/CB007601-B_1-1/CB007601-B_1-1_TC001.robot"


*** Variables ***
&{GNB_ASIK}         ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
${SCF_PATH}         ${CURDIR}/resources/config
${DELTA_FILE}       Delta_Conf_CB007601-A_2-1_TC001.json
${SCF_FILE}         SCF_running.xml
${iphy_file}        ${CURDIR}/resources/wts/iphy.xml
${swconfig_ap_file}        ${CURDIR}/resources/wts/swconfig.txt
${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
${WTS_CFG}          wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg

${UE_ID}            1
${PROFILE_ID}       1
${GNB_ID}           2
${CELL_ID}          1
${BEARER_ID}        2
# gnbbip apbip log doesn't work
#@{LOG_NAME_LIST}    btslog    snapshot  tcpdump  x2pcap  ttitrace  sherpa  tshark  apl3l1
@{LOG_NAME_LIST}    btslog    x2pcap
${COUNT}            0
${UE_NUMS}          10
${pass_procedure}   ${false}

#${UE_NR_CAP_TDD}        05000000010800040004D90000800000085802C68020E1DE39F30C7942C0E8000000000240268000000000000000
#...                     01E0000000000000454000080000000008008554
${UE_NR_CAP_TDD}        E1A00000074E5A131E0003832001E09306400043C24026C030E7CC31E50B03826010180E01951B0A35820286809659
...                     44C2C01EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261600F5B0404041C3
...                     BC70E418700040C9E3EAE0009E00380027800546C4DD6080A5A02596513000005803D6C10101073EF1CF9863DF3E4F
...                     278FAB80027800E0009E00151B13B582028680965944C2C01EB608080838778E1C830E0008193C7D54000014000000
...                     420E26800000001013444000E010113D84C00C000A070500703009801C001A0F800000000000039534000400002596
...                     5400D2AAA12007000B000000040080118B130001020304050607080B101112131921252627284A

${UE_EUTRA_NR_CAP_TDD}    211C04C160801C4D00000005F800000000020120268A8000C80C03639F0C06000200020100801002
#${UE_EUTRA_NR_CAP_TDD}    011C040100904D00000402404D13000320300D9E3
#${pcap_file}             ${SUITE_LOG_DIRECTORY}/x2.pcap
${pcap_filter}           x2ap
${pcap_filter_bip}       dldata_csirssendreq

@{LOG_NAME_SUITE_TEARDOWN}    utefiles

*** Keywords ***
egate checker
    Log To Console          ${EMPTY}
    Log To Console          =============================Start egate checker==============================
    ${egate_log_chk}    Common Analysis For Egate     ${SUITE_LOG_DIRECTORY}    ${egate_log_path}
    ...    ${CURDIR}/resources/5G_test_egate.json
    Run Keyword If      ${egate_log_chk} == ${false}      Log To Console    Log Analysis Fail!
    Log To Console          =============================End syslog checker==============================

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

Stop And Download Via gnb logs Case
    Log To Console    pass_procedure:${pass_procedure}
    Run Keyword If    ${pass_procedure} != ${true}     Stop And Download Via gnb logs on Gnb
    ...    path=/user/toor4nsn/gnb_logs_2.31

PCAP PARSER TEST
    Connect To UTE
    Log To Console       Connected to UTE done
    Set Suite Variable    ${pcap_file_x2_1}         ${SUITE_LOG_DIRECTORY}/x2.pcap
    Set Suite Variable    ${pcap_file_x2_2}         ${TEST_LOG_DIRECTORY}/x2.pcap
    Set Suite Variable    ${pcap_file_pattern_bip}      ${TEST_LOG_DIRECTORY}/gNB_*/*.pcap*
    ${pcap_txt_file}     Convert Pcap To Text UTE    source=${pcap_file_x2_1}   filter=${pcap_filter}
    ${pcap_txt_file_1}     Convert Pcap To Text UTE    source=${pcap_file_x2_2}   filter=${pcap_filter}
    Log To Console       Convert pcap file: ${pcap_file_x2_1} to txt file: ${pcap_txt_file} done
    Log To Console       Convert pcap file: ${pcap_file_x2_2} to txt file: ${pcap_txt_file_1} done

    Batch Convert Pcap To Text UTE    source=${pcap_file_pattern_bip}   filter=${pcap_filter_bip}
    Log To Console       Convert pcap file: ${pcap_file_pattern_bip} to txt file done

EMIL CONVERT TEST
    Connect To Emil
    Log To Console       Connected to Emil done

    Log To Console       Converting Emil file
    Set Suite Variable    ${emil_file}     ${TEST_LOG_DIRECTORY}/gNB_*/emil/*.emil
#    ${emil_output_file}     Convert Emil To Text    source=${emil_file}    emil_protocol=5G
    Batch Convert Emil To Text    source=${emil_file}    emil_protocol=5G

*** Test Cases ***
CB007601-B_1-1_TC001_Aperiodic CSI with cell specific CSI-RS for TDD non beamforming cells
    [Documentation]    CB007601-A_2-1_TC001_Verify manual adjustment of cell specific CSI-RS location for 4x4 TDD
    ...    nonbeamforming cell when dlMimoMode=40 and numOfSubSectors=0_FR1_SANSA_100MHz
    [Tags]    CRT    QC_6516    QCD_MN_RAN    QCP_RAN_VAL
#    Start Gnb BIP Log
#    Start X2 Pcap Log
#    Start Ttitrace With Streaming Mode

#    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
#    Set Suite Variable    ${UE_ID}    ${UE_ID}

    ${UE_NR_CAP_TDD}         String.Replace String    ${UE_NR_CAP_TDD}          ${SPACE}    ${EMPTY}
    ${UE_EUTRA_NR_CAP_TDD}   String.Replace String    ${UE_EUTRA_NR_CAP_TDD}    ${SPACE}    ${EMPTY}

#    Log To Console          UE_NR_CAP_TDD2:${UE_NR_CAP_TDD}
#    Log To Console          UE_EUTRA_NR_CAP_TDD2:${UE_EUTRA_NR_CAP_TDD}
#    Log To Console          UE_ID2:${UE_ID}
#    NSA NR And Eutra UE Param Set    ${UE_ID}    ${UE_NR_CAP_TDD}    ${UE_EUTRA_NR_CAP_TDD}
#    Run Keyword If    "${SW_VERSION}"=="SBTS00"     NSA NR And Eutra UE Param Set    ${UE_ID}    ${UE_NR_CAP_TDD}    ${UE_EUTRA_NR_CAP_TDD}
#    ...    ELSE IF    "${SW_VERSION}"=="SBTS22R1"     NSA NR And Eutra UE Param Set    ${UE_ID}    ${NR_CAP_TDD_22R1}    ${EUTRA_NR_CAP_TDD_22R1}


     Log To Console    Start X2,AP/Gnb BIP Log and Emil log on ABIO+ASIL

#     Start Airphone BIP Log By gnbMirroring BJ
#     Start GNB BIP Log By gnbMirroring BJ
#     Start To Capture Logs Via gnb logs    gnb_ip=10.0.1.2    command_suf=-e -cp -t
#     sleep     10
     Start X2 Pcap Log bj


    # SA UE
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#
#    SA Start DL Traffic    5    20
#    SA Start UL Traffic    1    20
#
#    SA Check Average Traffic Bigger Than Target    dl    3
#    SA Check Average Traffic Bigger Than Target    ul    1
#
#    SA Stop DL Traffic
#    SA Stop UL Traffic
#
#    SA 5G Detach    ${UE_ID}

#    Stop And Dowonload gnb_Logs
#    SA Stop DL Traffic EGate   ${UE_ID}
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    SA Check Average Traffic Bigger Than Target    dl    5
#    SA Check Average Traffic Bigger Than Target    ul    1

    # NSA UE
    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
    Set Suite Variable    ${UE_ID}    ${UE_ID}
    NSA NR And Eutra UE Param Set    ${UE_ID}    ${UE_NR_CAP_TDD}    ${UE_EUTRA_NR_CAP_TDD}
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    ${dl_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
    Log    DL Troughput is ${dl_tp}    console=True
    ${ul_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    ul
    Log    UL Troughput is ${ul_tp}    console=True

    NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    dl
    NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    ul
    Log To Console     NSA LTE Detach
    NSA LTE Detach    ${UE_ID}

    Common Test Log Capture

#    Run Keyword And Continue On Failure    Stop Airphone BIP Log BJ
#    Run Keyword And Continue On Failure    Stop BIP Log On GNB FCT BJ
#    Stop And Download Via gnb logs
#    Stop And Download Via gnb logs on Gnb    path=/user/toor4nsn/gnb_logs_2.31
    Set Suite Variable    ${pass_procedure}    ${True}
    Log To Console       case_pass_procedure: ${pass_procedure}
    Stop X2 Pcap Log               ${TEST_LOG_DIRECTORY}

    Set Suite Variable    ${egate_log_path}    ${TEST_LOG_DIRECTORY}/egate_console.log
    Backup Scf    ${TEST_LOG_DIRECTORY}    running

#    syslog_checker
#    egate_checker
#    Unzip Emil File
#    PCAP PARSER TEST
#    EMIL CONVERT TEST
    tdra checker
