*** Settings ***
Documentation    ...
#Documentation     R&D flags description:
#...               0x580591=0(ulcaEnablerPhase) and 0x58056B=1(DPA algo) for CB006137
#...               0x420062=1(Enable_8847-K_NewTddCellSlotModel before 8940-A,2cells in the same L1SP)
#...               0x420068=6 (rdTddPoolingFeaturesEnable,3bits LSB: bit 0 -> CB008940, bit 1->CB008847, bit 2->CB007113)
#...               0x450027=1(enabledeveloperaccount for web UI) and 0x590072=1(CPRT debug logs)
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${FULL_SCF}
#...               iphy_file=${IPHY_FILE}
#...               AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    RAN_5G_TDD    RAN_5G    Owner_j8shen    CN1_SG06    CB006137    CRT    SBTS00
#Resource          ./resources/CB006137_BC_resource.robot
#
#*** Variables ***
#${RD_PARAM}                   0x58056B=1;0x420062=1;0x450027=1;0x590072=1;0x420068=6
#${SCF_PATH}                   ${CURDIR}/config
#${FULL_SCF}                   ${CURDIR}/config/6137_SCF_BC014_3T_3F.xml
#${IPHY_FILE}                  ${CURDIR}/config/WTS/iphy_BC014_3T_BBP.xml
#${WTS_LOCAL}                  ${CURDIR}/config/WTS
#${WTS_CFG}                    CB006137_3F_3T_BC014_BC022.cfg
#${MAX_WAITTIME_CONFIGURED}    20min
#${MAX_REBOOT_TIME}            1
##BC014
#${NONCA_UE3}                  3
#${UE1}                        1
#${UE2}                        2
#${SCELL_ID}                   52
#${DL_TPUT}                    10
#${UL_TPUT}                    20
#${DL_TARGET}                  5
#${UL_TARGET}                  15
#&{XML_PARAMS_DICT1}           maxNumOfDRBL2Pool=38    maxNumOfGBRL2Pool=19    maxNumOfUserL2Pool=19
#&{VENDOR_CHANGE_DICT1}        list_name=bbPoolCapacity
#...                           ref_value=ABIO\\d+TDD    params_dict=${XML_PARAMS_DICT1}
#&{XML_PARAMS_DICT2}           maxNumOfDRBL2Pool=9000    maxNumOfGBRL2Pool=1000    maxNumOfUserL2Pool=4500
#&{VENDOR_CHANGE_DICT2}        list_name=bbPoolCapacity
#...                           ref_value=ABIO\\d+TDD    params_dict=${XML_PARAMS_DICT2}
#&{XML_PARAMS_DICT3}           guaranteedResourceRatioPerCell=10
#&{VENDOR_CHANGE_DICT3}        list_name=${EMPTY}
#...                           ref_value=${EMPTY}    params_dict=${XML_PARAMS_DICT3}
#@{VENDOR_LIST_BC14}           ${VENDOR_CHANGE_DICT1}    ${VENDOR_CHANGE_DICT3}
##BC022
#&{VENDOR_PARAMS_DICT}         maxNumLayerPrbDlL1Sp=660    maxNumStreamPrbDlL1Sp=660    maxNumLayerPrbUlL1Sp=330
#...                           maxNumStreamPrbUlL1Sp=660
#${LIST_NAME}                  bbL1SpPrbCapacity
#${REF_VALUE}                  ABIO\\d+TDD48
#&{VENDOR_CHANGE_DICT4}        params_dict=&{VENDOR_PARAMS_DICT}    list_name=${LIST_NAME}    ref_value=${REF_VALUE}
#@{VENDOR_LIST_BC22}           ${VENDOR_CHANGE_DICT2}    ${VENDOR_CHANGE_DICT4}
#@{LOG_NAME_LIST}              snapshot    btsLog
#
#*** Test Cases ***
#CB006137-ET-BC014_Multi_UE__UL_CA__Call_with_Baseband_pooling_of_RRC_connected_user_with_L2_NR_User_number_limitation
#    [Tags]    Owner_j8shen
#    [Setup]    Run Keywords    Test Setup Update GNB    vendor_change_list=${VENDOR_LIST_BC14}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    Start GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}
#    NonCA UE Attach To TDD Cell And Check Througput
#    Two CA UEs Attached And Check 2nd UE SgnbAddition Failed Due To NR User Limitation
#    ${syslog}    Stop And Collect GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}
#    ${nr_usr_limit_tag}    Grep File    ${syslog}    Admit NR user failed on all sCells
#    Should Not Be Empty    ${nr_usr_limit_tag}
#    [Teardown]    Test Teardown Recover Env
#
#CB006137-ET-BC022_Single_UE__UL_CA__Call_with_baseband_pooling_of_UL_PRBs_for_TDD_FR1_with_frameStructureType_=_semiStatic_ulDlDataSlotRatio_=1_4
#    [Tags]    Owner_j8shen
#    [Setup]    Run Keywords    Test Setup Update GNB    vendor_change_list=${VENDOR_LIST_BC22}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    One CA UE Attach And DO UL DL Traffic    1    52    160    300
#    Two Non CA UE Attach To Same L1subpool TDD Cells
#    Check Multiple CA UEs Scell Throughput    1    1    0    1    10
#    Check Multiple NonCA UEs Throughput    5    6    ul    10
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=capture ttitrace
#    Stop Ttitrace
#    Convert Ttitrace And Formated
#    Save Egate Log    ${output_dir}/egate/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}ttitrace_5GC007113.ini
#    ...    i    save_log_directory=${output_dir}/ttitrace_streaming
#    [Teardown]    Test Teardown Recover Env    scf_file=${scf_suite_bak_file}
#    ...    iphy_file=${iphy_suite_bak_file}    GNB_swconfig_file=${gnb_swconfig_suite_bak_file}
#
#*** Keywords ***
#NonCA UE Attach To TDD Cell And Check Througput
#    SA UE Attach    ${NONCA_UE3}
#    Start ULDL Small Traffic And Check The Tput    ${NONCA_UE3}    ${DL_TPUT}    ${UL_TPUT}    ${DL_TARGET}    ${UL_TARGET}
#
#Two CA UEs Attached And Check 2nd UE SgnbAddition Failed Due To NR User Limitation
#    SA UE Attach    ${UE1}
#    Trigger Scell Addition With CoverbaseA1 Rsrp Rsrq    ${UE1}
#    Check Scell Addition Successful    ${UE1}    ${SCELL_ID}
#    Start ULDL Small Traffic And Check The Tput    ${UE1}    ${DL_TPUT}    ${UL_TPUT}    ${DL_TARGET}    ${UL_TARGET}
#    SA UE Attach    ${UE2}
#    Trigger Scell Addition With CoverbaseA1 But Failed    ${UE2}
#
#One CA UE Attach And DO UL DL Traffic
#    [Arguments]    ${UE1}    ${SCELL_ID}    ${UL_TPUT}    ${DL_TPUT}
#    SA UE Attach    ${UE1}
#    Trigger Scell Addition With CoverbaseA1 Rsrp Rsrq    ${UE1}
#    Check Scell Addition Successful    ${UE1}    ${SCELL_ID}
#    Start SA UL Big Traffic Internal    ${UE1}    ${UL_TPUT}
#    Start SA DL Big Traffic Internal    ${UE1}    ${DL_TPUT}
#
#Two Non CA UE Attach To Same L1subpool TDD Cells
#    Multi UE Attach And Do UL DL Traffic    5    6    20    50
#    Sleep    20s    reason=Wait for traffic stable
#
#Convert Ttitrace And Formated
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${output_dir}/ttitrace_streaming/
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_dl.csv
#    ...    ${output_dir}/ttitrace_streaming/output_dl_formated.csv
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_ul.csv
#    ...    ${output_dir}/ttitrace_streaming/output_ul_formated.csv
