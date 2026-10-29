*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LOOO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD
#...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_FDD   5G_RAN_FDD   CRT

Documentation    :copyright: Nokia
...              :authors: Sagarika S V
...              :contact: sagarika.s_v@nokia.com
...              This user scenario verifies the GBR / Non-GBR load estimation and reporting.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/Common_Keywords.robot
Resource         ./resources/CB009215_keyword.robot
Resource         ../../../resources/robot/TTI.robot

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_FDD_H1_3CELL.lua
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${BTS_ADDRESS}    192.168.255.1
${configuration_directory}    /home/ute/vendor/
${SCF_Path}    SCF_DU_Setup.xml
${maxNumLayerPrbL1Sp_DL}    636
${maxNumStreamPrbL1Sp_DL}    636
${maxNumLayerPrbL1Sp_UL}    318
${maxNumStreamPrbL1Sp_UL}    636
${maxNumWbStreamPrbL1Sp}     424
${SCFC}=        ${CURDIR}/config/SCF/CB009215_H_3Cell_A4_20Mhz_SCF_GMC.xml
${AP_XML}=     ${CURDIR}/config/SCF/CB009215_H_3Cell_A4_20Mhz_GMC_iphy.xml
${r&d_parameter}     0x58012d=3;0x580758=1;0x580690=1;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=1

*** Keywords ***
Run CB009215-H1_Verify_GBR_and_Non-GBR_load_estimation_and_reporting_with_PRB_Pooling
    [Documentation]   This user scenario verifies the GBR / Non-GBR load estimation and reporting.
    log to console   Suite setup successful ...
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log   btslog
    Register UEs and Trigger GBR UL Traffic in Cell    Start_UE=1    End_UE=1    UL_Rate=10
    Register UEs and Trigger GBR UL Traffic in Cell    Start_UE=11    End_UE=14     UL_Rate=20
    Register UEs and Trigger GBR UL Traffic in Cell    Start_UE=21    End_UE=21    UL_Rate=10
    ${Step1_logs}    Collect and Decode TTI Logs1    gbr_demand_log_dir1    cellId=51
    log to console   ${Step1_logs}
    Stop Log    btslog    test_scenario=Step1
    Start Log   btslog
    Register UEs and Trigger NonGBR UL Traffic in Cell   Start_UE=15    End_UE=15    UL_Rate=66
    sleep    20s
    Validate GBR ULTraffic    Start_UE=1    End_UE=1    UL_Rate=10
    Validate GBR UL Traffic    Start_UE=11    End_UE=14    UL_Rate=20
    Validate GBR UL Traffic    Start_UE=21    End_UE=21    UL_Rate=10
    Validate NGBR UL Traffic    Start_UE=15    End_UE=15    UL_Rate=66
    ${Step2_logs}       Collect and Decode TTI Logs1    gbr_demand_log_dir2    cellId=51
    log to console   ${Step2_logs}
    Stop Log    btslog    test_scenario=Step2
    Run Keyword and continue on failure    Validate UL gbr demand and allocation1    ${Step1_logs}[ttitrace]/output_ul_formated.csv
    ...            ${Step2_logs}[ttitrace]/output_ul_formated.csv     cellId=51

Collect and Decode TTI Logs1
    [Arguments]    ${dir_name}    ${cellId}
	Start Log      ttitrace
	Sleep    1s
    ${gbr_demand_logpath}    Stop Log       ttitrace   test_scenario=${dir_name}
    log to console   ${dir_name}   ${cellId}
    log to console   ${gbr_demand_logpath}
	Decode TTI Trace    ${dir_name}
	[Return]    ${gbr_demand_logpath}

Validate UL gbr demand and allocation1
    [Arguments]   ${csv_file_path1}    ${csv_file_path2}    ${cellId}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_gbr_allocation.check_gbr_demand_allocation    ${csv_file_path1}
    ...                      ${csv_file_path2}    ${cellId}
    [Return]   ${Result}