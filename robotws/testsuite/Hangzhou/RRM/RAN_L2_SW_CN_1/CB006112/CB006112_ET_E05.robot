*** Settings ***
Documentation    ...
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_dss_command.robot
#Resource          ./resources/CB006112_common_keyword.robot
##Library           ./../CUDU_L2/scripts/python/egate_operator.py
#Library           taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
#Suite Setup       Run Keywords
#...               Suite Setup Update GNB
#...               Prepare Test Env
#Force Tags        Classical    IPV4    FR1    PRI-High    CB006112
#...               Owner_lading    CRT    RAN_5G    SBTS00    SBTS23R1
#...               CN1_SQ  CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#Suite Teardown    Teardown All Connections
#
#*** Variables ***
#${ALLOC_SUBFRAME_10M_20M_50_50}    0010000010-0111001110-0011001110-0111000110-0011001010-0111001000-0010000000-0110000110
#${WTS_DIR}                         /opt/wts/latest
#${LOCAL_WTS_DIR_E05}               SCF/CB006112_ET_E05
#${WTS_CFG_20M}                     basic_wts_2063_20M.cfg
#${WTS_AP_XML}                      AirPhoneConfig_2063.xml
#${GSCN}                            1588
#${Case_index_E05}                  CaseE05
#${DELTA_PATH_20M}                  Delta_conf_5GC002063_ET_20M.json
#${dist_name_E05}                   MRBTS-1/NRBTS-1/NRCELL-1
#${parameter_E05}                   maxGBRTrafficLimit
#${value_E05}                       1
#${UE1_ID}                          1
#${UE2_ID}                          2
#${UE3_ID}                          3
#${force_reboot}                    ${True}
#
#*** Test Cases ***
#CB006112-ET-E-05 DSS GBR Load Reporting to trigger TD load
#    Set Delta Jason Config Path
#    Configure Gnb    ${Delata_JSON_PATH}/${DELTA_PATH_20M}
#    Verify Coam Site Is Ready
#    Reboot gnb and ap via ssh
#    Verify Coam Site Is Ready
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_20M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${Delata_JSON_PATH}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70
#    SA GBR Call For Multi UE    ${UE1_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    2M    180
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    2M    180
#    Online Change One Para With Admin    ${dist_name_E05}    ${parameter_E05}    ${value_E05}
#    SA GBR Call For Multi UE for E05   ${UE3_ID}
#    Setup a folder for subcase    ${Case_index_E05}
#    Collect GNB SnapShot Via AaShell    ${output_dir}/${Case_index_E05}
#    Check Voice Call Reject in E05E06    ${output_dir}/${Case_index_E05}
#    [Teardown]    Recover TL
#
#*** Keywords ***
#Check DL measuredGbrLoad should be 0x64 reported by L2PS
#    Download And Unzip Lua File    sw=${SW_VERSION_TOTAL}
#    ${gbrLoadReportEnabled_filter}    Catenate    xp_dss_XpDssMessage.dssDlQosLoadMeasurement.measuredGbrLoad == 0x64
#    Wait Until Keyword Succeeds    2 min    7 s    cap.Read Cap    cap_file=${OUTPUT_DIR}/${Case_index_E05}/XP.pcap
#    ...    X=lua_script:${output_dir}/generated_luashark/xpshark.lua    display_filter=${gbrLoadReportEnabled_filter}
#    ${status}    Run Keyword and Return Status     cap.Check Expression    ${gbrLoadReportEnabled_filter}    log=${True}
#    Log To Console    DL measuredGbrLoad checked successfully
#
#
#
#
