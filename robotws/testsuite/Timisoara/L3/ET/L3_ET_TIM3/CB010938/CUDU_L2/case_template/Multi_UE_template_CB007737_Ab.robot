*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580497=1
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
Suite Teardown    Common Suite Teardown    debug
Test Setup        Run Keywords    Delta Commission With SCF File    delta_json=${DELTA_SCF}
...               AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
...               AND    Common Test Setup
Test Teardown     Common Test Teardown    debug
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_qiqluo
...               SBTS00    SBTS22R4    CN1_SQ6    CB007737
Resource          ../../Resources/CB007737/Resources/CB007737_Common.robot
Resource          ../../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${SCF_PATH}                 ${CURDIR}/../CB007737/Config
${FULL_SCF}                 CB007737_Ab_scfc.xml
${DELTA_SCF}                Delta_CB007737_Ab.json
${IPHY_FILE}                ${CURDIR}/../CB007737/Resources/wts/iphy_4F_2T.xml
${WTS_LOCAL}                ${CURDIR}/../CB007737/Resources/wts
${WTS_CFG}                  CB007737_Ab.cfg
${WTS_DIR}                  /opt/wts/latest
${DL_DATA}                  100
${UL_DATA}                  10
${PCELL_UL_TPUT}            5
${PCELL_DL_TPUT}            5
${SCELL1_DL_TPUT}           5
${SCELL2_DL_TPUT}           5
@{EXP_DL_TPUT_LIST}         5    5    5
@{CA_UE_LIST}               1    2    3
@{PCELL_ID_LIST}            50    53    54
@{SCELL_PHYSICALID_1}       51    54
@{SCELL_PHYSICALID_2}       50    51
@{SCELL_PHYSICALID_3}       50    53
@{SCELL_PHYSICALID_LIST}    ${SCELL_PHYSICALID_1}    ${SCELL_PHYSICALID_2}    ${SCELL_PHYSICALID_3}

*** Test Cases ***
CB007737_ET_AB14_ABIO_4F2T_MultiUE_Mixcore_3CC_Tput
    SA Multi UE Attach With Scell A1 Addition    ${CA_UE_LIST}    ${PCELL_ID_LIST}    ${SCELL_PHYSICALID_LIST}    105    3
    SA Multi UE Start DL And UL Traffic    ${CA_UE_LIST}    ${DL_DATA}    ${UL_DATA}
    Display Multi UE Throughput    ${CA_UE_LIST}
    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${CA_UE_LIST}    ${PCELL_UL_TPUT}    ${EXP_DL_TPUT_LIST}    3
    common_Log_capture.Start Ttitrace With Streaming Mode
    Sleep    2s    reason=capture ttitrace
    common_Log_capture.Stop Ttitrace
    common_Log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${output_dir}/ttitrace_streaming/
    Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_dl.csv    ${output_dir}/ttitrace_streaming/output_dl_formated.csv
    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}..${/}CB007737${/}A2A/CB007737_Ab${/}CB007737_Ab.ini
    ...    i    save_log_directory=${output_dir}/ttitrace_streaming

