*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    A22 Suite Setup Update GNB
#Suite Teardown    A22 Suite Teardown
#Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD    STATE_CONFIGURED    RAN_5G_FDD    FR1
#...               Owner_yalsun    CN1_SQ    CB007736    SBTS00    SBTS23R1    SBTS22R4    SBTS22R3    RAN_5G
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#
#*** Variables ***
#${WEBUI_HOST}         192.168.255.1
#${WEBUI_USER}         Nemuadmin
#${WEBUI_PWD}          nemuuser
#${SCF_PATH}           ${CURDIR}/config
#${LOCAL_WTS_DIR}      ${CURDIR}/config/CB007736_ET_A22
#${GNB_SCFC}           ${CURDIR}/config/CB007736_ET_A22/CB007736_A22.xml
#${WTS_DIR}            /opt/iphy/latest
#${WTS_CFG}            basic_fs_sa_call_fdd_cmwv_3CC.cfg
#${WTS_AP_XML}         AirPhoneConfig_fs_fdd_sa_cmw_3CC.xml
#${UE1_ID}             1
#${UE2_ID}             2
#${UE3_ID}             3
#${PROFILE_ID}         1
#${GNB_ID}             2
#${CELL_ID}            2
#${BEARER_ID}          2
#@{LOG_NAME_LIST}      btslog    snapshot
#${COUNT}              0
#${SWCONFIG_PARAM}     0x5800F3=1;0x590072=1;
#${ASP_BOARD_TYPE}     ABIO
#${NON_DTX}            NON_DTX
#${CELL2_SIB}          eNB 2 cell 2: SystemInformationBlockType2-NR updated
#${CELL3_SIB}          eNB 2 cell 3: SystemInformationBlockType2-NR updated
#
#*** Test Cases ***
#CB007736-ET-A-22 Multi UEs call on 3CC CA configuration cell
#    Attach SA CA Muti UE and Get Throughput    UE_ID=1    dl_tp_set=175
#    ...    ul_tp_set=175    dl_tp_threshold=50    ul_tp_threshold=10
#    Attach SA CA Muti UE and Get Throughput    UE_ID=2    dl_tp_set=175
#    ...    ul_tp_set=175    dl_tp_threshold=50    ul_tp_threshold=10
#    Attach SA CA Muti UE and Get Throughput    UE_ID=3    dl_tp_set=175
#    ...    ul_tp_set=175    dl_tp_threshold=50    ul_tp_threshold=10
#	SA Stop Data Traffic Internal    UE_ID=1    pdu_id=1
#    SA Stop Data Traffic Internal    UE_ID=2    pdu_id=1
#    SA Stop Data Traffic Internal    UE_ID=3    pdu_id=1
#
#*** Keywords ***
#A22 Suite Setup Update GNB
#    Suite Setup Update GNB    log=${False}
#    Run Keyword If    '${swconfig_param}'!='${empty}'    Add RD Parameters To GNB Swconfig File    ${swconfig_param}
#    Send SCFC for GNB    ${gnb_scfc}
#    sleep    10s
#    Hard Reboot Testline
#    Verify Coam Site Is Ready
#    A22 Start WTS And Check OnAir
#
#A22 Suite Teardown
#    Run Keyword And Ignore Error    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Collect GNB Snapshot Via Aashell    log_dir=${SUITE_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Collect AP Snapshot Via Aashell    log_dir=${SUITE_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Send SCFC for GNB    ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml
#
#Hard Reboot Testline
#    Hard Reboot Airphone
#    Hard Reboot GNB
#
#A22 Start WTS And Check OnAir
#    [Documentation]    This keyword is to modify vlan, start WTS, Wait for onAir
#    OperatingSystem.Run    cp ${local_wts_dir}/${WTS_CFG} ${WTS_DIR}
#    OperatingSystem.Run    cp ${local_wts_dir}/${WTS_AP_XML} ${WTS_DIR}
#    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_CFG}
#    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_AP_XML}
#    Configure A22 VM Interfaces
#    Run Keyword And Ignore Error    Stop Edaemon Egate
#    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
#    ute_wtssim.Start Edaemon Process    alias=edaemon
#    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
#    ute_wtssim.Start Egate Process
#    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}    pass_regexp=SCTP proxy link
#    Cell3 SIB Decoding
#    Verify Cell Setup
#
#Configure A22 VM Interfaces
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
#
#Cell3 SIB Decoding
#    ta5g_egate.Wait For Egate Console Output    expected_message=${CELL3_SIB}    timeout=300s
#    Log    sib_decoding_is_ok
#    Sleep    3s
#
#
#Attach SA CA Muti UE and Get Throughput
#    [Arguments]    ${UE_ID}=3    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell1_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${scell2_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2
#    log    Pcell Troughput is ${pcell_tp}    console=True
#    log    Scell1 Troughput is ${scell1_tp}    console=True
#    log    Scell2 Troughput is ${scell2_tp}    console=True
#    Should Be True    "${pcell_tp}">"0" and "${scell1_tp}">"0"and "${scell2_tp}">"0"
