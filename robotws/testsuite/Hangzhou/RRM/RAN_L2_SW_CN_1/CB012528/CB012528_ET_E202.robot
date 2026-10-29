*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${SCF_FILE}
#...               iphy_file=${IPHY_FILE}    vendor_change_list=${VENDOR_CHANGE_LIST}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOOO    CRT    RAN_5G    RAN_5G_TDD    Owner_nilei
#...               CN1_SG6    CB012528    SBTS00
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Config
#${SCF_FILE}              Configuration_scf_20M_2D2L12716off.xml
#${IPHY_FILE}             ${CURDIR}/Config/wts/iphy_12F_2T2D2L.xml
#${LOCAL_WTS_DIR}         ${CURDIR}/Config/wts/
#${WTS_CFG}               12cell40caue5noncaue.lua
#${RD_PARAM}              0x580849=40;0x58083A=1
#${PDU_ID}                1
#&{XML_PARAMS_DICT}       actDPAOverloadControl=true    actTwoCoresL2DeploymentFddFr1=false
#&{VENDOR_CHANGE_DICT}    list_name=${EMPTY}
#...                      ref_value=${EMPTY}    params_dict=${XML_PARAMS_DICT}
#@{VENDOR_CHANGE_LIST}    ${VENDOR_CHANGE_DICT}
#
#*** Test Cases ***
#CB012528_ET_E202_3F_2T_20Mhz_60Mhz_MultiUE_DPA_OLC_ABIO_12528_ON
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    NonCA Ue Attach
#    CA Ue Attach
#    #Capture Convert Format Ttitrace With Streaming Mode    10s    log_dir=${test_log_directory}/ttitrace/1
#    #Verify DL SCellActStopResume As Expected    log_id=1
#    #Capture Ttitrace And Check DPA OLC    DAPOLC
#    NonCA Ue Start DL UL Traffic
#    CA Ue Start DL UL Traffic
#    Check_All_Ue_Tput
#    Capture Convert Format Ttitrace With Streaming Mode    1s    log_dir=${test_log_directory}/ttitrace/2
#    Capture Ttitrace And Check DPA OLC    2
#    CUDU L2 Check DTXNACK Rate    log_id=2    expect_rate=0.05
#    [Teardown]    Run Keywords    Common Test Teardown
#    ...    AND    Stop Edaemon Egate
#
#*** Keywords ***
#NonCA Ue Attach
#    FOR    ${ue_id}    IN RANGE    481    486
#    \    Single Ue Attach    ${ue_id}
#
#CA Ue Attach
#    FOR    ${ue_id}    IN RANGE    81    121
#    \    Single Ue Attach    ${ue_id}
#
#Single Ue Attach
#    [Arguments]    ${ue_id}    ${pdu_id}=1
#    Log To Console    UE${ue_id} Start Attach...
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
#    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1
#    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes
#
#NonCA Ue Start DL UL Traffic
#    FOR    ${ue_id}    IN RANGE    481    486
#    \    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    25    trf_id=1
#    \    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    10    trf_id=1
#    Sleep    5s
#
#CA Ue Start DL UL Traffic
#    FOR    ${ue_id}    IN RANGE    81    121
#    \    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    25    trf_id=1
#    \    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    10    trf_id=1
#    Sleep    5s
#
#Verify DL SCellActStopResume As Expected
#    [Arguments]    ${log_id}=1
#    ${stop_number}    Get SCellActStopResume Total Number    dpaOverloadCtrl.sCellActStopResume    ["STOP"]    ${log_id}
#    ${resume_number}    Get SCellActStopResume Total Number    dpaOverloadCtrl.sCellActStopResume    ["RESUME"]    ${log_id}
#    Log To Console    stopnumber is ${stop_number}\n
#    Should Be True    ${stop_number}>0
#    Log To Console    resumenumber is ${resume_number}\n
#    Should Be True    ${resume_number}>0
#
#Get SCellActStopResume Total Number
#    [Arguments]    ${name}=dpaOverloadCtrl.sCellActStopResume    ${check}=["STOP"]    ${log_id}=1
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_dl.csv    ${name}    ${check}    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Capture Ttitrace And Check DPA OLC
#    [Arguments]    ${dir_name}
#    ${tti_file_dir}    set Variable    ${test_log_directory}/ttitrace/${dir_name}
#    #Capture Convert Format Ttitrace With Streaming Mode    10s    log_dir=${tti_file_dir}
#    ${dpa_olc_list}    Ttitrace Filter Source Column Return Self Column    ${tti_file_dir}/output_dl_formated.csv    sCellActStopResume
#    ...    ["RESUME", "STOP"]    include    yes
#    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${dpa_olc_list}
#	[Return]     ${status}
#
#Check_All_Ue_Tput
#    FOR    ${ue_id}    IN RANGE    81    121
#    \    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${ue_id} type=pusch,pdsch scell=primary,secondary    pass_regexp=CellIndex
#    \    Sleep    1s
