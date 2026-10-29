*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONF}
#...               vendor_change_list=${vendor_change_list}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_MP_AP_LOOO    CRT    RAN_5G    RAN_5G_TDD    Owner_w13li
#...               CN1_SG6    CB012528    SBTS00
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCF_FILE}                 12528_E_302_SCF.xml
#${IPHY_FILE}                ${CURDIR}/Config/wts/iphy_E101.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
#${WTS_CFG}                  12cell40ueprecell_E101.lua
#${PDU_ID}                   1
#${SWCONF}                   0x58084A=40
#&{xml_params_dict1}     actDPAOverloadControl=true    actTwoCoresL2DeploymentFddFr1=true
#...                     maxNumOfCAUserL2SubPool=80    maxNumScheUePdschL2Sp=26    maxNumScheUePuschL2Sp=22
#&{vendor_change_dict1}     list_name=${EMPTY}    ref_value=${EMPTY}      params_dict=${xml_params_dict1}
#@{vendor_change_list}      ${vendor_change_dict1}
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#
#*** Test Cases ***
#CB012528_ET_E302_3F_2T_20Mhz_60Mhz_MultiUE_DPA_OLC_IWK_With_CB012716_ABIO
#    #5_NON_CA_UE_Attach
#    50_Ue_Attach
#    ${status}    Capture Ttitrace And Check DPA OLC    DAPOLC
#    Run Keyword If    "${status}"=="${False}"    Second_Check_DPA_OLC
#    50_Ue_Dettach
#    50_Ue_Attach
#    Start_DL_UL_Traffic
#    #Run Keyword And Ignore Error     Capture Ttitrace And Check Schedule
#    Check_All_Ue_Tput
#    50_Ue_Dettach
#
#
#*** Keywords ***
#
#Capture Ttitrace And Check DPA OLC
#    [Arguments]    ${dir_name}
#    ${tti_file_dir}    set Variable    ${test_log_directory}/ttitrace/${dir_name}
#    Capture Convert Format Ttitrace With Streaming Mode    10s    log_dir=${tti_file_dir}
#    ${dpa_olc_list}    Ttitrace Filter Source Column Return Self Column    ${tti_file_dir}/output_dl_formated.csv    sCellActStopResume
#    ...    ["RESUME", "STOP"]    include    yes
#    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${dpa_olc_list}
#	[Return]     ${status}
#
#Second_Check_DPA_OLC
#    50_Ue_Dettach
#    50_Ue_Attach
#    ${status}    Capture Ttitrace And Check DPA OLC    DAPOLC2
#	Run Keyword If    "${status}"=="${False}"    Fail
#
#Capture Ttitrace And Check Schedule
#    ${tti_file_dir}    set Variable    ${test_log_directory}/ttitrace/tput
#    Capture Convert Format Ttitrace With Streaming Mode    0.5s    log_dir=${tti_file_dir}
#    CUDU_L2 Check DTXNACK Rate    log_id=tput    expect_rate=0.05
#    CUDU_L2 Check UL DTXCRC Rate    log_id=tput    expect_rate=0.05
#
#5_NON_CA_UE_Attach
#    FOR    ${ue_id}    IN RANGE    61    66
#	\    SA 5G CA Attach    ${ue_id}
#
#50_Ue_Attach
#    FOR    ${ue_id}    IN RANGE    1    51
#	\    SA 5G CA Attach    ${ue_id}
#
#50_Ue_Dettach
#    FOR    ${ue_id}    IN RANGE    1    51
#	\    SA 5G Detach    ${ue_id}
#
#Start_DL_UL_Traffic
#    FOR    ${ue_id}    IN RANGE    1    51
#    \    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    40    trf_id=1
#    \    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    15    trf_id=1
#
#Check_All_Ue_Tput
#    FOR    ${ue_id}    IN RANGE    1    51
#    \    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${ue_id} type=pusch,pdsch scell=primary,secondary    pass_regexp=CellIndex
#    \    Sleep    1s
#
