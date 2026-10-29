*** Settings ***
Documentation    ...
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_dss_command.robot
#Resource          ./resources/CB006112_common_keyword.robot
#Resource          ./../CUDU_L2/common_log_capture.robot
##Library           ./../CUDU_L2/scripts/python/egate_operator.py
#Library           taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
#Suite Setup       Common Suite Setup 2
##Run Keywords
##...               Check TL Type And Suite Setup
##...               Prepare Test Env
#Force Tags        Classical    IPV4    FR1    PRI-High    CB006112
#...               Owner_lading    CB006112    RAN_5G    SBTS00    SBTS23R1    CRT
#...               CN1_SQ  CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
#Suite Teardown    Common Suite Teardown 2
#
#*** Variables ***
#${ALLOC_SUBFRAME_10M_20M_50_50}    0010000010-0111001110-0011001110-0111000110-0011001010-0111001000-0010000000-0110000110
#${ALLOC_SUBFRAME_20M_50_50_PRB}    0010000000-0111101000-0011100000-0111101000-0011100000-0111101000-0011100000-0011001000
#${WTS_DIR}                         /opt/wts/latest
#${LOCAL_WTS_DIR_E01}               SCF/CB006112_ET_E01
#${LOCAL_WTS_DIR_E06}               SCF/CB006112_ET_E06
#${WTS_CFG_10M}                     basic_wts_2063_10M.cfg
#${WTS_CFG_20M}                     basic_wts_2063_20M.cfg
#${WTS_AP_XML}                      AirPhoneConfig_2063.xml
#${GSCN}                            1588
#${Case_index_E01}                  CaseE01
#${Case_index_E06}                  CaseE06
#${DELTA_PATH_10M}                  Delta_conf_5GC002063_ET_10M.json
#${6112_scf_E01}                    ${CURDIR}/config/SCF_5GC006112_ET_10M.xml
#${SWCONFIG_PARAM_gnb}              0x4B000F=1;0x4F011=1
#${LOLO_2CC}                        ${CURDIR}/config/iphy_LOLO2CC.xml
#${DELTA_PATH_20M_PRB}              Delta_conf_5GC002063_ET_20M_PRB.json
#${dist_name_E06}                   MRBTS-1/NRBTS-1/NRCELL-1
#${parameter_E06}                   addNumOfGBRBearers
#${value_E06}                       383
#${force_reboot}                    ${True}
#${UE1_ID}                          1
#${UE2_ID}                          2
#${UE3_ID}                          3
#
#*** Test Cases ***
#CB006112-ET-E-01Voice call on DSS with 10MHz chBw
#    [Tags]     Owner_lading    CB006112-ET-E-01
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_10M}
##    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_E01}
#    ...        AND    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM_gnb}    scf_file=${6112_scf_E01}
#                      ...    iphy_file=${LOLO_2CC}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${CURDIR}/config/
#    ...        AND    Common Test Setup 2
#
#    Hard Reboot Testline
#    Verify Coam Site Is Ready
#    Start UTE WTS FOR DSS
#    Log To Console    ${WTS_CFG}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    SA GBR Call For Multi UE    ${UE2_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    60M    180
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    60M    180
#    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7074    1400       2M   180
#    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7075    1400       2M    180
#    Setup a folder for subcase    ${Case_index_E01}
#    Collect GNB SnapShot Via AaShell    ${output_dir}/${Case_index_E01}
#    #Check ULDL GBRreport in local cprt log    ${output_dir}/${Case_index_E01}
#    [Teardown]    Recover TL
#
#CB006112-ET-E-06 GBR load report and GBR Radio admin control
#    Verify Coam Site Is Ready
#    Set Delta Jason Config Path
#    Configure Gnb    ${Delata_JSON_PATH}/${DELTA_PATH_20M_PRB}
#    Verify Coam Site Is Ready
#    Reboot gnb and ap via ssh
#    Verify Coam Site Is Ready
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_20M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${Delata_JSON_PATH}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_20M_50_50_PRB}    12,50    30    70
#    SA GBR Call For Multi UE    ${UE1_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    2M    1800
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    2M    1800
#    Online Change One Para With Admin    ${dist_name_E06}    ${parameter_E06}    ${value_E06}
#    SA GBR Call For Multi UE for E05   ${UE3_ID}
#    Setup a folder for subcase    ${Case_index_E06}
#    Collect GNB SnapShot Via AaShell    ${output_dir}/${Case_index_E06}
#    Check Voice Call Reject in E05E06    ${output_dir}/${Case_index_E06}
#    [Teardown]    Recover TL
#
#*** Keywords ***
#Check gbrLoadReport enabled from gNB side in pcap for caseE01
#    Download And Unzip Lua File    sw=${SW_VERSION_TOTAL}
#    ${gbrLoadReportEnabled_filter}    Catenate    itf_l2_ps_cell_DssCellCrmClientCfgReq.gbrLoadReport.gbrLoadReport_item_0 == 0x01
#    cap.Read Cap    cap_file=${OUTPUT_DIR}/${Case_index_E01}/x2.pcap    X=lua_script:${output_dir}/generated_luashark/xpshark.lua
#    ...    display_filter=${gbrLoadReportEnabled_filter}
#    ${status}    Run Keyword and Return Status     cap.Check Expression    ${gbrLoadReportEnabled_filter}    log=${True}
#    Log To Console    gbrLoadReport enabled from L2PS to CPRT......
#
#Check DL measuredGbrLoad in EnbXP.pcap for caseE01
#    ${filter_E01}    Catenate    xp_dss_XpDssMessage.dssDlQosLoadMeasurement.measuredGbrLoad == 0x06
#    Wait Until Keyword Succeeds    2 min    7 s    cap.Read Cap    cap_file=${OUTPUT_DIR}/${Case_index_E01}/XP.pcap
#    ...    X=lua_script:${output_dir}/generated_luashark/xpshark.lua   display_filter=${filter_E01}
#    ${status}    Run Keyword and Return Status    cap.Check Expression    ${filter_E01}   log=${True}
#    Log To Console    DL measuredGbrLoad reported right......
#
#Check UL measuredGbrLoad in EnbXP.pcap for caseE01
#    ${filter_E01}    Catenate    xp_dss_XpDssMessage.enDssUlQosLoadMeasurement.measuredGbrLoad == 0x0c
#    Wait Until Keyword Succeeds    2 min    7 s    cap.Read Cap    cap_file=${OUTPUT_DIR}/${Case_index_E01}/XP.pcap
#    ...    X=lua_script:${output_dir}/generated_luashark/xpshark.lua   display_filter=${filter_E01}
#    ${status}    Run Keyword and Return Status    cap.Check Expression    ${filter_E01}   log=${True}
#    Log To Console    UL measuredGbrLoad reported right......
#
#Check ULDL GBRreport in CPRT log
#    BuiltIn.Log To Console    Check ULDL GBRreport in CPRT log...
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=connection_gnb
#    ${cmd1}    Set Variable     cp /tmp/node_CPRT00/tmp/startup_cp_rt.log* /tmp/
#    SSH.Execute    command=${cmd1}    connection=connection_gnb
#    Sleep    2s
#    ${cmd2}    Set Variable    xz -d /tmp/startup_cp_rt.log.xz;cat /tmp/startup_cp_rt.log | grep -i dlGbrPrbLoadLargeBwp
#    ${E01_info}    SSH.Execute    command=${cmd2}    connection=connection_gnb
#    Should Contain Any    ${E01_info}    dlGbrPrbLoadLargeBwp:5
#    ...    dlGbrPrbLoadLargeBwp:6
#    ...    ulGbrPrbLoadLargeBwp:14
#    ...    ulGbrPrbLoadLargeBwp:13
#    ...    ulGbrPrbLoadLargeBwp:12
#    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect
#
#
