*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    A07 Suite Setup Update GNB
#Suite Teardown    A07 Suite Teardown
#Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD    master_classicalbts_all    STATE_CONFIGURED    RAN_5G_FDD    FR1
#...               Owner_qianwu    CN1_SQ    CB007736    SBTS00    SBTS23R1    SBTS22R4    SBTS22R3    RAN_5G
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#
#*** Variables ***
#${WEBUI_HOST}         192.168.255.1
#${WEBUI_USER}         Nemuadmin
#${WEBUI_PWD}          nemuuser
#${SCF_PATH}           ${CURDIR}/config
#${LOCAL_WTS_DIR}      ${CURDIR}/config/CB007736_ET_A07
#${gnb_scfc}           ${CURDIR}/config/CB007736_ET_A07/CB007736_A07.xml
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
#CB007736-ET-A-07 3CC CA cells mapping on different cores of half ABIO
#    Delete PM BTS Counter File
#    SA 5G Attach    ${UE1_ID}
#    SA 5G PDU Session Setup    ${UE1_ID}
#    Traffic And Check CA
#    SA 5G Detach    ${UE1_ID}
#    Wait Until Keyword Succeeds    30min    1min    Get PM BTS Counter File
#    Check A07 BTS Counter
#
#*** Keywords ***
#A07 Suite Setup Update GNB
#    Create Suite Directory
#    Backup Scf    ${SUITE_LOG_DIRECTORY}    before_suite
#    Run Keyword If    '${swconfig_param}'!='${empty}'    Add RD Parameters To GNB Swconfig File    ${swconfig_param}
#    Send SCFC for GNB    ${gnb_scfc}
#    Hard Reboot Testline
#    Verify Coam Site Is Ready
#    A07 Start WTS And Check OnAir
#
#A07 Suite Teardown
#    Run Keyword And Ignore Error    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Collect GNB Snapshot Via Aashell    log_dir=${SUITE_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Collect AP Snapshot Via Aashell    log_dir=${SUITE_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Send SCFC for GNB    ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml
#
#Hard Reboot Testline
#    Hard Reboot Airphone
#    Hard Reboot GNB
#
#A07 Start WTS And Check OnAir
#    [Documentation]    This keyword is to modify vlan, start WTS, Wait for onAir
#    OperatingSystem.Run    cp ${local_wts_dir}/${WTS_CFG} ${WTS_DIR}
#    OperatingSystem.Run    cp ${local_wts_dir}/${WTS_AP_XML} ${WTS_DIR}
#    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_CFG}
#    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_AP_XML}
#    Configure A07 VM Interfaces
#    Run Keyword And Ignore Error    Stop Edaemon Egate
#    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
#    ute_wtssim.Start Edaemon Process    alias=edaemon
#    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
#    ute_wtssim.Start Egate Process
#    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}    pass_regexp=SCTP proxy link
#    Cell3 SIB Decoding
#    Verify Cell Setup
#
#Configure A07 VM Interfaces
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
#Traffic And Check CA
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    100M    60
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    100M    60
#    Start GNB TTI Trace
#    Sleep    1s
#    Stop And Decode GNB TTI Trace    ${OUTPUT_DIR}/tti
#    Check SCell Addition
#    Verify Pcell and Scell DL Traffic Transfered As Expected
#
#Check SCell Addition
#    BuiltIn.Log To Console    Check SCell Addition...
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
#    ${SCell_Addition_info}    SSH.Execute    cat /tmp/node_CPCL00/tmp/startup_cp_cl.log | grep -i ConcreteCaSCellCandidateSelectionProcedure
#    Should Contain    ${SCell_Addition_info}
#    ...    Finished with status Status:ok and selected SCells: [NRCellIdentity: 16386, NRCellIdentity: 16387]
#    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect
#
#Verify Pcell and Scell DL Traffic Transfered As Expected
#    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/tti/1730_L2TtiTrace_EventsSnapshot.bin.0.dl.csv    ${OUTPUT_DIR}/dl/
#    Log To Console    Check tbSize from TTI trace
#    @{tbSize_dl}=    get_specified_column_from_csv_file    ${OUTPUT_DIR}/dl/dlFdSchedData_sfn.csv    tbSize
#    FOR    ${i}    IN    @{tbSize_dl}
#         Should Be True    ${i}>0
#    END
#    Log To Console    Check ulPucchReceiveRespPs from TTI trace
#    @{dtx}=    get_specified_column_from_csv_file    ${OUTPUT_DIR}/dl/ulPucchReceiveRespPsData_sfn.csv    dtx
#    FOR    ${i}    IN    @{dtx}
#         Should Be True    '${i}'=='${NON_DTX}'
#    END
#
#Delete PM BTS Counter File
#    BuiltIn.Log To Console    Delete PM BTS counter file on SA
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
#    SSH.Execute    rm /tmp/PM.BTS*
#    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect
#
#Get PM BTS Counter File
#    BuiltIn.Log To Console    Get PM BTS Counter File...
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
#    SSH.Execute    gunzip /tmp/PM.BTS*.gz
#    SSH.Execute    rm /tmp/PM.BTS*.xml
#	${contents}    SSH.Execute    ls -1 /tmp/PM.BTS*
#    @{lines}    Split To Lines    ${contents}
#    : FOR    ${line}    IN    @{lines}
#     \    ${counter_info1}    SSH.Execute    cat ${line} | grep M55139C01001
#     \    ${M55139C01001_list}    Get Regexp Matches    ${counter_info1}    <M55139C01001>(\\d+)</M55139C01001>    1
#     \    ${lenth}    Evaluate    len(${M55139C01001_list})
#     \    Run keyword if    '${lenth}'!='0'      Exit For Loop
#    Should Be True    ${lenth}>0
#    ${M55139C01001_Scell1}    Get From List    ${M55139C01001_list}    1
#    Run Keyword If    ${M55139C01001_Scell1}==0    SSH.Execute    rm ${line}
#    Should Contain        ${M55139C01001_Scell1}    1
#    Set Suite Variable    ${line}
#    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect
#
#Check A07 BTS Counter
#    Check PM Counter Value    M55139C01001    0,1,1
#    Check PM Counter Value    M55139C01002    0,1,1
#    Check PM Counter Value    M55139C01003    0,0,0
#    Check PM Counter Value    M55139C01004    0,0,0
#    Check PM Counter Value    M55139C01501    1,0,0
#    Check PM Counter Value    M55139C01502    1,0,0
#    Check PM Counter Value    M55316C03003    0,0,0
#    Check PM Counter Value    M55316C04003    0,0,0
#
#Check PM Counter Value
#    [Arguments]    ${counter_name}    ${check_point}
#    BuiltIn.Log To Console    check ${counter_name}...
#	${value_list}=    Split String    ${check_point}    ,
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
#    ${counter_info1}    SSH.Execute    cat ${line} | grep ${counter_name}
#    ${counter_list}    Get Regexp Matches    ${counter_info1}    <${counter_name}>(\\d+)</${counter_name}>    1
#    BuiltIn.Log    ${counter_list}
#    ${counter_Pcell}    Get From List    ${counter_list}    0
#    ${counter_Scell1}    Get From List    ${counter_list}    1
#    ${counter_Scell2}    Get From List    ${counter_list}    2
#    Should Contain        ${counter_Pcell}    ${value_list}[0]
#    Should Contain        ${counter_Scell1}    ${value_list}[1]
#    Should Contain        ${counter_Scell2}    ${value_list}[2]
#    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect
