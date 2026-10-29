*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT
Documentation    :copyright: Nokia
...              :authors: Sowrabha.S.M
...              :contact: sowrabha.s_m@nokia.com
...              Feature Overview:
...    "CB007112: Baseband resource pooling of up to 16 DL MIMO layers" increases the DL MIMO layers to 16DL
...    for 3 cells TDD FR1 deployment on top of baseband pooling feature CB008940 implementation.

...    Both CB007112 and CB008940 provide pooling of L1 DL PRB processing resources in DL between NR TDD FR1 cells.
...    The main differences are: CB007112 is applicable on full ABIO/ASOE board deployment,
...    CB008940 is applicable on half ABIO/ASOE board deployment, it means CB007112 manages 2 L1 pool processing resources per
...    L2-RT instance, CB008940 manage 1 L1 pool resource per L2-RT instance. CB007112 controls L1 DL PRB processing resources
...    on subcell level granularity, CB008940 controls L1 DL PRB processing resources on stream-PRB level granularity.


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ./resources/CB007112_keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../CB009215/resources/CB009215_keyword.robot
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND    Add routes
...                 AND    Update GNB R&D Parameter
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib

#Suite Teardown       Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword And Ignore Error     Stop Default Processes And Gather Logs And Compress Logs


Test Teardown   Run Keywords  Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1   12
...     AND   Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_7112enable_csirs.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${filepath}         "https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/srjacob/CB007112/"
${en_ue_id}         ${13}
@{cell_id}          50    51    52
${UE_RRC_Reject}    RRC Reject was received
${Timeout_SA}    15
${r&d_parameter}      0x580265=2;0x580117=1
&{minprb}    50=${48}  51=${48}   52=${48}
${SCFC}=                   Bangalore/RRM/ET/CB007112/SCF_CB007112_csirs.xml
${AP_XML}=                 Bangalore/RRM/ET/CB007112/iphy_CB007112_csirs.xml

*** Test Cases ***
[1]CB007112_F_1_Admission_control_for_UE_specific_CSI-RS_in_L1_pool_level
    log to console   Suite setup successful ...
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Attach four SA UEs in cell and trigger traffic    start_ue_id=1    end_ue_id=12   DL_rate=10    UL_rate=10
    Run Keyword And Continue On Failure    Collect and Valiadate TTI Sherpa Logs
    Register UE and check RRC Rejection    ue_id=13
    Register UE and check RRC Rejection    ue_id=15

*** Keywords ***
Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Register UE and check RRC Rejection
    [Arguments]   ${ue_id}
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_RRC_Reject}    ${Timeout_SA}
    Log to Console    ---> ${UE_RRC_Reject}
    Print Matching Lines from Output File    ${output}    ${UE_RRC_Reject}
    BuiltIn.Log                ue_rejected
    [Return]      ${output}

Collect and Valiadate TTI Sherpa Logs
	Start Log      ttitrace
	Sleep    2s
    ${sherp_tti}    Stop Log       ttitrace   test_scenario=Dl_tti
	Decode TTI Trace    Dl_tti
    ${alloacated_subcell}    Create List     1     1    1
    ${alloacated_ulsubcell}    Create List     1     1    1
    ${ch_bw}    Create list   100  100  100
    Validate cell dlprballocation from TTI traces    ${sherp_tti}[ttitrace]    ${cell_id}   ${alloacated_subcell}
    ...    ${ch_bw}   subcell=${3}
    #Run Keyword And Continue On Failure   Validate cell ulprballocation from TTI traces    ${sherp_tti}[ttitrace]
    #...    ${cell_id}   ${alloacated_ulsubcell}   ${ch_bw}
    ${ZAB_cells}  ${NOZAB_cells}   Validate ZAB privilege granted    ${sherp_tti}[ttitrace]
    FOR  ${cell}  IN  @{cell_id}
        List Should Contain Value   ${ZAB_cells}    ${cell}
    END
    check_prballocation.Check_minprballocation   ${sherp_tti}[ttitrace]/output_dl_formated.csv    ${minprb}

