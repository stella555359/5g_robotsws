*** Settings ***
Documentation    This is for CB006502 AENB CPRI keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_commssion.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Library    ../TestData/variables_CB007833.py
Library    ../TestData/variables_6502_40M.py
Library    ../TestData/variables_6502_60M.py
Library    taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    String
Library    DateTime
Library    OperatingSystem
Library    Process
Library    SeleniumLibrary

Variables    ../TestData/variables_6502_60M.py
Variables    ../TestData/variables_6502_40M.py

*** Variables ***
# Detailed Connector info
${First_Port}          First endpoint port label
${First_port_ID}       First endpoint port identifier
${Second_Port}         Second endpoint label
${Second_port_ID}      Second endpoint port identifier
${First_R_Port}        First endpoint port label in runtime
${First_R_Port_ID}     First endpoint port identifier in runtime
${Sencond_R_Port}      Second endpoint label in runtime
${Second_R_Port_ID}    Second endpoint port identifier in runtime

@{cell_1}    ${1}
${ui_version_xiaomi}    Mi12UI13.0.12
*** Keywords ***

AENB CPRI Suite Setup
    [Arguments]    ${gnb_index}=0
    log to console    \n*** AENB CPRI Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
#    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    run keyword if     ${if_commissioning}    AENB CPRI Common Suite Setup    gnb_index=${gnb_index}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Origin_Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    ${Golden_SCF_Path}    Replace String    ${Origin_Golden_SCF_Path}    .xml    _CPRI_40M.xml
    set suite variable      ${Golden_SCF_Path}
    sleep    3min
    COAM Commission with scf file  scf_file_path=${Golden_SCF_Path}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait until keyword succeeds    30min    30s    verify all cells should be onair
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if     '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    get eNB active version
    set suite variable    ${suite_setup_fail_flag}    ${False}

AENB CPRI Common Suite Setup
    [Documentation]    This keyword will contain both WA operation for CIT/UTEC in suite setup.
    [Arguments]  ${gnb_index}=${0}    ${du_index}=${0}    ${common_unit_index}=${0}
#    CI_commssion.common commissioning    gnb_index=${gnb_index}   du_index=${du_index}
    AENB CPRI common commissioning    gnb_index=${gnb_index}   du_index=${du_index}
    ...    common_unit_index=${common_unit_index}

AENB CPRI common commissioning
    [Timeout]    90min
    [Documentation]  common commisioning for hz test line.
    ...   Keyword depends on variables from command line, keyword will return directly without them.
    ...   Keyword supports both classical and cloud gnb.
    ...   Keyword supports both hz ci and ute cloud test line.
    ...   For test line on ute cloud, keyword will install package again if fault 23 raises.
    ...   Keyword do normal commissioning for classical bts.
    ...   Keyword do cu and du commissioning for cloud bts.
    ...   Tester needs to put SCF to scf_base_path with particular name.
    [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
    run keyword if    '${var_status}'=='FAIL'    run keywords
    ...    Builtin.log    Not ute or ci command, will not do common commission.    level=WARN    AND
    ...    return from keyword
    run keyword if      '${ci_var_dict}[gnb_type]'=='CloudBts'
    ...    CI_commssion.Do CU Commission    &{ci_var_dict}
#    CI_commssion.Do DU Commission    &{ci_var_dict}
    AENB CPRI Do DU Commission    &{ci_var_dict}

AENB CPRI Do DU Commission
    [Arguments]          ${connection}=du_coam    &{var_dict}
    CI_commssion.Connect To Du With F1 Or LMP    connection=${connection}    du_host=${var_dict}[du_host]
    ...        username=${var_dict}[username]    password=${var_dict}[password]
    CI_commssion.Commisioning Custom DU Scf    connection=${connection}   testline=${var_dict}[testline]
    ...    stream=${var_dict}[stream]    gnb_type=${var_dict}[gnb_type]   ute_env=${var_dict}[ute_env]
    ...    gnb_index=${var_dict}[gnb_index]
    Wait For Expect Fault Present    faultId=10    timeout=1800
#    WAIT UNTIL KEYWORD SUCCEEDS    80x    15s    CI_commssion.All Hw Should Be Detected
#    ...    testline=&{var_dict}[testline]    build=&{var_dict}[build]    stream=&{var_dict}[stream]
#    ...    ute_env=&{var_dict}[ute_env]   connection=${connection}
#    WAIT UNTIL KEYWORD SUCCEEDS    15min    15s    CI_commssion.gNB Is OnAir   build=&{var_dict}[build]
#    ...    stream=&{var_dict}[stream]    ute_env=&{var_dict}[ute_env]   connection=${connection}
#    WAIT UNTIL KEYWORD SUCCEEDS    15min    15s    CI_commssion.Verify all cells should be Online   connection=${connection}
    [Teardown]  taf.sbts.oam.coam.admin.teardown   connection=${connection}

Customer_Pronto_PMAX
    [Arguments]
    Selenium Login And Disable Screen Lock
    Commision scf with specific
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    ${modify_params}    create list
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=Maximum output power    p_name=pMax
    ...    value=18.8
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    verify all cells should be onair
    sleep    720s
    Log to console    \n******* check if RU reset and BTS should not be reseted *******
    Wait until keyword succeeds    10min    1min    Check HW modules detection
#    Close Start Up View    timeout=60
    Selenium Logout And Close Browser

Commision scf with specific
    [Arguments]    ${PMAX}=PMAX
    ${scf_path}     Replace String    ${Golden_SCF_Path}    .xml    ${PMAX}.xml
    COAM Commission with scf file    scf_file_path=${scf_path}   timeout=15min

General_SiSo_BTS_(Q)SFP+SFP28_provisioning_enhancements
    [Arguments]    ${WEBUI_USER}=Nemuadmin    ${WEBUI_PASSWORD}=nemuuser    ${SFP_1}=S_RF1    ${QSFP_1}=Q_RF1
    ...    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ...    ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    Verify all cells should be onair
    ${release}    Get BTS Release
    Selenium Login And Disable Screen Lock
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${url}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}     version=${release}
    Log to console    \n********** start check cablink2/cablink2-R info **********
    Get Values for Cablink2/Cablink2_R point
    Selenium Logout And Close Browser
    Get linkspeed for cablink2    SFP_1=${SFP_1}    QSFP_1=${QSFP_1}
    Log to console    \n********** start check ABIL SFP_1 info ***********
    ${Cab2_Link_speed}     ${Cab2_Avilability_Status}    ${Cab2_Operational_state}    Check ABIL SFP_1 info
    ...    SFP_1=${SFP_1}    QSFP_1=${QSFP_1}
    Run Keyword If    '${release}'=='23R3' or '${release}'=='22R4' or '${release}'=='23R1' or '${release}'=='23R2' or '${release}'=='23R4'
    ...    should be equal    ${Cab2_Avilability_Status}    -
    ...    ELSE    should be equal    ${Cab2_Avilability_Status}    Online
    Run Keyword If    '${release}'=='23R3' or '${release}'=='22R4' or '${release}'=='23R1' or '${release}'=='23R2' or '${release}'=='23R4'
    ...    should be equal    ${Cab2_Operational_state}    enabled
    ...    ELSE    should be equal    ${Cab2_Operational_state}    Enabled
#    Run Keyword If    '${release}'!='23R3' and '${release}'!='22R4' and '${release}'!='23R1' and '${release}'!='23R2'
#    ...    Run Keywords
#    ...    should be equal    ${Cab2_Avilability_Status}    Online
#    ...    AND
#    ...    should be equal    ${Cab2_Operational_state}    Enabled
    Log to console    \n********* start check cablink3/cablink3-R and QSFP info *********
    Check Cablink3 and QSFP info    SFP_1=${SFP_1}    QSFP_1=${QSFP_1}
    Sleep    10s
#    selenium_coam.logout
#    [Teardown]    selenium_coam.disable_virtual_display
    [Teardown]    Selenium Logout And Close Browser

Check ABIL SFP_1 info
    [Arguments]    ${HW_BBMOD}=BBMOD-1 / BBMOD_R-1    ${SFP_1}=S_RF1    ${QSFP_1}=Q_RF2    ${RU_OPT1}=OPT_IF1
     ...    ${RU_OPT2}=OPT_IF2    ${ru_index}=${1}    ${BB_index}=${1}
    ${RU_Runtime_Object}    Get RU info Runtime Object
    Selenium Login And Disable Screen Lock
    ${SFP1_info}    selenium_coam.get_hw_info    hw_name=${HW_BBMOD}    connector=${SFP_1}
    ${Cab2_Link_speed}    Get Variable Value    ${SFP1_info['Link speed']}
    should be equal    ${SFP1_info['Physical port']}    ${SFP_1}
    should be equal    ${SFP1_info['First endpoint']}    BBMOD_R-${BB_index}/${SFP_1}
    should be equal    ${SFP1_info['Second endpoint']}    ${RU_Runtime_Object}/${RU_OPT1}
    should be equal    ${SFP1_info['Status']['Administrative state']}    Unlocked
    ${Cab2_Avilability_Status}    Get Variable Value    ${SFP1_info['Status']['Availability status']}
    ${Cab2_Operational_state}    Get Variable Value    ${SFP1_info['Status']['Operational state']}
    should be equal    ${SFP1_info['Status']['Usage state']}    Active
    ${Thresholds_length}    Get Length    ${SFP1_info['Thresholds']}
    should be equal    ${Thresholds_length}    ${10}
    [Return]    ${Cab2_Link_speed}    ${Cab2_Avilability_Status}    ${Cab2_Operational_state}
    [Teardown]    Selenium Logout And Close Browser

Check ABIL Q_RF1 info
    [Arguments]    ${HW_BBMOD}=BBMOD-1 / BBMOD_R-1    ${SFP_1}=S_RF1    ${QSFP_1}=Q_RF2    ${RU_OPT1}=OPT_IF1
     ...    ${RU_OPT2}=OPT_IF2    ${ru_index}=${1}    ${BB_index}=${1}    ${cell_id}=1    ${separator}=M
    ${QSFP1_info}    selenium_coam.get_hw_info    hw_name=${HW_BBMOD}    connector=${QSFP_1}
    ${Cab3_Link_speed}    Get Variable Value    ${QSFP1_info['Link speed']}
    ${Bandwidth}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...    filter_param=Channel bandwidth
    ${BW}    Split String    string=${Bandwidth}    separator=${separator}    max_split=-1
    ${chBw}    Convert To Integer    ${BW[0]}
    should be equal    ${QSFP1_info['Physical port']}    ${QSFP_1}
    should be equal    ${QSFP1_info['First endpoint']}    BBMOD_R-${BB_index}/${QSFP_1}
    should be equal    ${QSFP1_info['Second endpoint']}    RMOD_R-${ru_index}/${RU_OPT2}
    should be equal    ${QSFP1_info['Status']['Administrative state']}    Unlocked
    ${Cab3_Avilability_Status}    Get Variable Value    ${QSFP1_info['Status']['Availability status']}
    ${Cab3_Operational_state}    Get Variable Value    ${QSFP1_info['Status']['Operational state']}
    Run Keyword If    ${chBw} <= 50
    ...    should be equal    ${QSFP1_info['Status']['Usage state']}    Idle
    Run Keyword If     ${chBw} > 50
    ...    should be equal    ${QSFP1_info['Status']['Usage state']}    Active
    ${Thresholds_length}    Get Length    ${QSFP1_info['Thresholds']}
    should be equal    ${Thresholds_length}    ${10}
    [Return]    ${Cab3_Link_speed}    ${Cab3_Avilability_Status}    ${Cab3_Operational_state}

Get Values for Cablink2/Cablink2_R point
    [Arguments]    ${EQM_cab_2}=MRBTS-${mrbtsId}/EQM-1/HWTOP-1/CABLINK-2
    ...    ${EQM_R_cab_2}=MRBTS-${mrbtsId}/EQM_R-1/HWTOP_R-1/CABLINK_R-1001
    ${EQM_Cab2_FirstPort}    selenium_coam.get_parameter_value    dist_name=${EQM_cab_2}    filter_param=${First_Port}
    ${EQM_Cab2_FirstPortID}    selenium_coam.get_parameter_value    dist_name=${EQM_cab_2}    filter_param=${First_port_ID}
    ${EQM_Cab2_SecondPort}    selenium_coam.get_parameter_value    dist_name=${EQM_cab_2}    filter_param=${Second_Port}
    ${EQM_Cab2_SecondPortID}    selenium_coam.get_parameter_value    dist_name=${EQM_cab_2}    filter_param=${Second_port_ID}
    ${EQM-R_Cab2_FirstPort}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_2}    filter_param=${First_R_Port}
    ${EQM-R_Cab2_FirstPortID}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_2}    filter_param=${First_R_Port_ID}
    ${EQM-R_Cab2_SecondPort}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_2}    filter_param=${Sencond_R_Port}
    ${EQM-R_Cab2_SecondPortID}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_2}    filter_param=${Second_R_Port_ID}
    should be equal    ${EQM_Cab2_FirstPort}    ${EQM-R_Cab2_FirstPort}
    should be equal    ${EQM_Cab2_FirstPortID}    ${EQM-R_Cab2_FirstPortID}
    should be equal    ${EQM_Cab2_SecondPort}    ${EQM-R_Cab2_SecondPort}
    should be equal    ${EQM_Cab2_SecondPortID}    ${EQM-R_Cab2_SecondPortID}

Get Values for Cablink3/Cablink3-R point
    [Arguments]    ${EQM_cab_3}=MRBTS-${mrbtsId}/EQM-1/HWTOP-1/CABLINK-3
    ...    ${EQM_R_cab_3}=MRBTS-${mrbtsId}/EQM_R-1/HWTOP_R-1/CABLINK_R-1002
    Selenium Login And Disable Screen Lock
    ${EQM_Cab3_FirstPort}    selenium_coam.get_parameter_value    dist_name=${EQM_cab_3}    filter_param=${First_Port}
    ${EQM_Cab3_FirstPortID}    selenium_coam.get_parameter_value    dist_name=${EQM_cab_3}    filter_param=${First_port_ID}
    ${EQM_Cab3_SecondPort}    selenium_coam.get_parameter_value    dist_name=${EQM_cab_3}    filter_param=${Second_Port}
    ${EQM_Cab3_SecondPortID}    selenium_coam.get_parameter_value    dist_name=${EQM_cab_3}    filter_param=${Second_port_ID}
    ${EQM-R_Cab3_FirstPort}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_3}    filter_param=${First_R_Port}
    ${EQM-R_Cab3_FirstPortID}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_3}    filter_param=${First_R_Port_ID}
    ${EQM-R_Cab3_SecondPort}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_3}    filter_param=${Sencond_R_Port}
    ${EQM-R_Cab3_SecondPortID}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_3}    filter_param=${Second_R_Port_ID}
    should be equal    ${EQM_Cab3_FirstPort}    ${EQM-R_Cab3_FirstPort}
    should be equal    ${EQM_Cab3_FirstPortID}    ${EQM-R_Cab3_FirstPortID}
    should be equal    ${EQM_Cab3_SecondPort}    ${EQM-R_Cab3_SecondPort}
    should be equal    ${EQM_Cab3_SecondPortID}    ${EQM-R_Cab3_SecondPortID}
    [Teardown]    Selenium Logout And Close Browser

Get linkspeed for cablink2
    [Arguments]    ${EQM_cab_2}=MRBTS-${mrbtsId}/EQM-1/HWTOP-1/CABLINK-2    ${SFP_1}=S_RF1    ${QSFP_1}=Q_RF2
    ...    ${EQM_R_cab_2}=MRBTS-${mrbtsId}/EQM_R-1/HWTOP_R-1/CABLINK_R-1001    ${Linkspeed}=Link speed
    Selenium Login And Disable Screen Lock
    ${EQM_Cab2_linkspeed}    selenium_coam.get_parameter_value    dist_name=${EQM_cab_2}    filter_param=${Linkspeed}
    ${EQM-R_Cab2_linkspeed}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_2}    filter_param=${Linkspeed}
    Selenium Logout And Close Browser
    ${Cab2_Link_speed}    ${Cab2_Avilability_Status}    ${Cab2_Operational_state}    Check ABIL SFP_1 info
    ...    SFP_1=${SFP_1}    QSFP_1=${QSFP_1}
    should be equal    ${EQM_Cab2_linkspeed}    ${EQM-R_Cab2_linkspeed}
    should be equal    ${EQM-R_Cab2_linkspeed}    ${Cab2_Link_speed}
    [Return]    ${EQM_Cab2_linkspeed}    ${EQM-R_Cab2_linkspeed}
    [Teardown]    Selenium Logout And Close Browser

Get linkspeed for cablink3
    [Arguments]     ${EQM_cab_3}=MRBTS-${mrbtsId}/EQM-1/HWTOP-1/CABLINK-3    ${Linkspeed}=Link speed
    ...    ${EQM_R_cab_3}=MRBTS-${mrbtsId}/EQM_R-1/HWTOP_R-1/CABLINK_R-1002    ${SFP_1}=S_RF1    ${QSFP_1}=Q_RF2
    Selenium Login And Disable Screen Lock
    ${EQM_Cab3_linkspeed}        selenium_coam.get_parameter_value    dist_name=${EQM_cab_3}    filter_param=${Linkspeed}
    ${EQM-R_Cab3_linkspeed}    selenium_coam.get_parameter_value    dist_name=${EQM_R_cab_3}    filter_param=${Linkspeed}
    Selenium Logout And Close Browser
    ${release}    Get BTS Release
    ${Cab3_Link_speed}    ${Cab3_Avilability_Status}    ${Cab3_Operational_state}    Check ABIL Q_RF1 info
    ...    SFP_1=${SFP_1}    QSFP_1=${QSFP_1}
    should be equal    ${EQM_Cab3_linkspeed}    ${EQM-R_Cab3_linkspeed}
    should be equal    ${Cab3_Link_speed}    ${EQM-R_Cab3_linkspeed}
    Run Keyword If    '${release}'=='22R3' or '${release}'=='22R4'
    ...    should be equal    ${Cab3_Operational_state}    enabled
    Run Keyword If    '${release}'=='22R3' or '${release}'=='22R4'
    ...    should be equal    ${Cab3_Avilability_Status}    -
    Run Keyword If    '${release}'!='22R3' and '${release}'!='22R4'
    ...    Run Keywords
    ...    should be equal    ${Cab3_Avilability_Status}    Online
    ...    AND
    ...    should be equal    ${Cab3_Operational_state}    Enabled
    [Return]    ${EQM_Cab3_linkspeed}    ${EQM-R_Cab3_linkspeed}
    [Teardown]    Selenium Logout And Close Browser

Check Cablink3 and QSFP info
    [Arguments]    ${SFP_1}=S_RF1    ${QSFP_1}=Q_RF1
    ${cablink_times}   Count Cablink Number
    Run Keyword If    ${cablink_times}>2    Get Values for Cablink3/Cablink3-R point
    Run Keyword If    ${cablink_times}>2    Get linkspeed for cablink3    SFP_1=${SFP_1}    QSFP_1=${QSFP_1}

Get BTS Release
    [Arguments]    ${connection}=GNB_OAM
    ${sw_Version}     coam.get_sw_version    connection=${connection}
    ${BTS_release}    coam_siso_common.Coam Get program version based on gNB active version    version_active_sw=${sw_Version}
    ${release}    Convert To String    ${BTS_release}
    [Return]    ${release}

Count Cablink Number
    [Arguments]    ${connection}=GNB_OAM    ${str}=com.nokia.srbts.eqm:CABLINK
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${scf_path}    Join Path    ${SAVE LOG DIRECTORY}    ${timestamp}
    ${scf_file}    download scf download via rest api    scf_dir_path=${scf_path}    connection=${connection}
    ${cablink_times}    get_str_appeared_times_in_file     str=${str}    filepath=${scf_file}
    [Return]    ${cablink_times}

Get RU info Runtime Object
    Selenium Login And Disable Screen Lock
    ${cablink-R_info}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/EQM_R-1/HWTOP_R-1/CABLINK_R-1001    filter_param=Second endpoint distinguished name in runtime
    ...    abbr=secondEndpointDN
    ${cablink-R_info_list}    Split String From Right   ${cablink-R_info}     /
    ${RU_Runtime_Object}    Set Variable    ${cablink-R_info_list}[3]
    [Return]    ${RU_Runtime_Object}
    [Teardown]    Selenium Logout And Close Browser

CB006502_AENB_General_SiSo_E2E_system_setup_with_data_transfer_conducted_MCS27_30km_60MHz
    log to console    start commission 60M SCF...
    Selenium Login And Disable Screen Lock
    ${SCF_60M}    Replace String    ${Golden_SCF_Path}    .xml    _CPRI_60M.xml
    COAM Commission with scf file    scf_file_path=${SCF_60M}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Selenium Logout And Close Browser
    data_transfer_common    tput_self_define=${tput_define_60M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.95}    min_percent=${0.85}

CB006502_AENB_General_SiSo_E2E_system_setup_with_data_transfer_conducted_MCS27_30km_40MHz
    log to console    start commission 40M SCF...
    Selenium Login And Disable Screen Lock
    ${SCF_40M}    Replace String    ${Golden_SCF_Path}    .xml    _CPRI_40M.xml
    COAM Commission with scf file    scf_file_path=${SCF_40M}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Selenium Logout And Close Browser
    data_transfer_common    tput_self_define=${tput_define_40M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.95}    min_percent=${0.85}

RU_lock_unlock_excute
#    comission specific scf    replace_scf_name=_9359_8DL8UL    check_lte_cell_status=${True}
#    data_transfer_common    tput_self_define=${tput_define_8DL8UL_100M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
#    ...    target_avg_percent=${0.3}    min_percent=${0.3}    tput_from=self_define
    log to console    ++++ start lock all RUs ++++
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    ${ru_index_list}    Get All RU Index
    FOR    ${RU_idx}    IN    @{ru_index_list}
        selenium_coam.lock_ru    ru_index=${RU_idx}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
    END
    log to console    ++++ start unlock all RUs ++++
    FOR    ${RU_idx}    IN    @{ru_index_list}
        selenium_coam.unlock_ru    ru_index=${RU_idx}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
    END
    Selenium Logout And Close Browser
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_define_60M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.3}    min_percent=${0.3}    ui_version=${ui_version_xiaomi}
    [Teardown]    Selenium Logout And Close Browser

Reset bts and check on air
    Perform BTS Site Reset
    Sleep    30s
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
