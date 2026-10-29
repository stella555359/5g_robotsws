*** Settings ***
Documentation    Suite description
...    Author:        amy.wu@nokia-sbell.com
...    Maintainer:    Wu Amy

Library     Telnet
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot

Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

Force Tags    STATE_GNB_NOT_COMMISSIONED   CLOUD_5G_CLASSICAL_SA_ASIBLR_ABIOB1B4_AEHC_3xAHCA_FULLRACK

Test Timeout     72h

*** Variables ***
&{5G_CB007262_AEHC_3AHCA_MultiRat}=    HW_ID=CB007262    site_mode=MultiRat    ONAIR_TIME=15 min
...    GG=3.1.1:3.1.5;3.1.2:3.1.6;3.1.7:3.1.3;3.1.8:3.1.4
...                                    peak_rate_config={"171":[200,10]}
&{AEHC_one_fiber_3AHCA}    HW_ID=CB007262    site_mode=MultiRat    ONAIR_TIME=15 min
...                        peak_rate_config={"171":[200,10],"172":[200,10]}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    5G_CB007262_AEHC_3AHCA_MultiRat

${parameters}    [{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'PRACH configuration index',
...    'para_value':'89','require_reset':False},{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'Start RB',
...    'para_value':'4','require_reset':False},{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'Tilt Offset',
...    'para_value':'2','require_reset':False},{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-2','para_name':'Tilt Offset',
...    'para_value':'2','require_reset':False}]

${LCELNR1_DIST_NAME}    MRBTS-10628/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1

${objects_celltype_4DL4UL}    [{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2","operate":"delete"}]
${parameters_celltype_4DL4UL}    [{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'NR Cell type',
...    'para_value':'4DL4UL','require_reset':"rat_reset"}]

${objects_celltype_8DL4UL}    [{"object_name":"${LCELNR1_DIST_NAME}","object_class_name":"CHANNELGROUP",
...    "plan_to_copy_from":${None},"copy_from":${None},"include_subobject":${False},"id_value":"2",
...    "is_load_default_values":False,"operate":"add"},{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2",
...    "object_class_name":"CHANNEL", "plan_to_copy_from":${None},"copy_from":${None}, "include_subobject":${False},
...    "id_value":"1","is_load_default_values":False,"operate":"add"},{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2",
...    "object_class_name":"CHANNEL", "plan_to_copy_from":${None},"copy_from":${None}, "include_subobject":${False},
...    "id_value":"2","is_load_default_values":False,"operate":"add"},{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2",
...    "object_class_name":"CHANNEL", "plan_to_copy_from":${None},"copy_from":${None}, "include_subobject":${False},
...    "id_value":"3","is_load_default_values":False,"operate":"add"},{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2",
...    "object_class_name":"CHANNEL", "plan_to_copy_from":${None},"copy_from":${None}, "include_subobject":${False},
...    "id_value":"4","is_load_default_values":False,"operate":"add"}]
${parameters_celltype_8DL4UL}    [{"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-1",
...    "para_name":"Direction of the channel", "para_value":"TX","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-1",
...    "para_name":"Distinguished Name of resource","para_value":"MRBTS-10628/EQM-1/APEQM-1/RMOD-1/PHYANT-1",
...    "require_reset":"False"},{"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-2",
...    "para_name":"Direction of the channel","para_value":"TX","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-2","para_name":"Distinguished Name of resource",
...    "para_value":"MRBTS-10628/EQM-1/APEQM-1/RMOD-1/PHYANT-1","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-3",
...    "para_name":"Direction of the channel", "para_value":"TX","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-3",
...    "para_name":"Distinguished Name of resource","para_value":"MRBTS-10628/EQM-1/APEQM-1/RMOD-1/PHYANT-1",
...    "require_reset":"False"},{"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-4",
...    "para_name":"Direction of the channel","para_value":"TX","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-4","para_name":"Distinguished Name of resource",
...    "para_value":"MRBTS-10628/EQM-1/APEQM-1/RMOD-1/PHYANT-1","require_reset":"False"},
...    {"dist_name":"MRBTS-10628/NRBTS-10628/NRCELL-1","para_name":"NR Cell type","para_value":"8DL4UL",
...    "require_reset":"False"}]

${GLO_SCOUT_TESTLINE_NAME}    1_5_UTE5G131_1

${GGMAP}    {"L1231609493":{"1": "3.1.1", "2": "3.1.2", "7": "3.1.7"}, "L1204101448":{"7":"3.1.8"},
...         "L1212814013": {"1": "3.1.5", "2": "3.1.6"}, "AS210918787":{"1":"3.1.3","2":"3.1.4"}}

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    No module fan detected    NgGnbInitPartialReset
...                                   Unstable eCPRI Link Detected    Baseband Module Hardware Failure

${link_dict}    {"L1212814013": {"break": "3.1.1:3.1.5;3.1.2:3.1.6", "connect": "3.3.3:3.1.2;3.3.4:3.1.6"}}

*** Test Cases ***

[1][1.0] Cell Block Then resetBBmod Then Unblock
    [Tags]    QC_188647    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_resetBBmod_Unblock    config_id=5G_CB007262_AEHC_3AHCA_MultiRat
    Askey Power Reset
    Common_SiSo_State Management_cell Lock_Then_resetBBMOD_Then_cell unlock    required_cells=171:179:180:181
    [Teardown]    Testcase Basic Postcondition

[1][4.0] Manual_SiSo_SM_NR_RAT_reset
    [Tags]    QC_188646    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=5G_CB007262_AEHC_3AHCA_MultiRat
    Askey Power Reset
    RAT reset from WebEm For NR testline    required_cells=171
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***
Verify Askey Exist
    ${ue_config}   others.Get Ue Common Config   ue_info=${tl.ues[0]}    index=0
    csn.connect to    ${ue_config['cpc_ip']}    ${ue_config['cpc_username']}    ${ue_config['cpc_password']}    timeout=120    alias=cpc_0
    ${ret}    csn.execute    command=adb devices    connection=cpc_0
    sleep    30 sec
    should contain    ${ret}    ${ue_config['serial_number']}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=cpc_0

Power Reset With Telnet
    [Arguments]    ${host}    ${username}    ${password}    ${port}
    Telnet.open_connection    host=${host}    timeout=30    prompt=>    prompt_is_regexp=True
    Telnet.login    ${username}    ${password}    login_prompt=User Name :    password_prompt=Password${SPACE}${SPACE}:
    Telnet.execute_command    olOff ${port}
    Sleep    60s
    Telnet.execute_command    olOn ${port}
    [Teardown]    Run Keyword And Ignore Error    Telnet.close_connection

Askey Power Reset
    Power Reset With Telnet    10.106.198.41    apc    apc    8
    Wait Until Keyword Succeeds    3 min    10 sec    Verify Askey Exist

Askey ADB Reset
    csn.connect_to    hostname=10.106.198.28    username=siso1-tester    password=Nokia123!    port=22    alias=adb
    csn.execute    adb reboot    connection=adb
    FOR    ${i}    IN RANGE    ${10}
        sleep    30 sec
        ${ret}    csn.execute    adb devices    connection=adb
        ${ret}    Convert to string     ${ret}
        Return From Keyword If    "985a045e" in '''${ret}'''
    END
    Fail    msg="askey not detect!"

Delta File Commission For Celltype
    [Arguments]    ${delta_file}    ${cell_type}    ${required_cells}=${EMPTY}
    ...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    ${para_list}    Create List    nrCellType
    ${mo_list}    Create List    MRBTS-10628/NRBTS-10628/NRCELL-1
    Parameter Operation    operation=delta_plan_update    product_type=gnb    delta_file_path=${delta_file}
    wait for all cells onair
    ${value}    Parameter Operation    operation=parameter_value_check    product_type=gnb    para_list=${para_list}
    ...    mo_list=${mo_list}
    should be equal as strings    ${value["MRBTS-10628/NRBTS-10628/NRCELL-1"]["nrCellType"]}    ${cell_type}
    Make L3call    required_cells=${required_cells}    extra_peak_rate_config=${extra_peak_rate_config}
    Check Alarms
    Check Historical Alarms
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="FAIL"    Set Test Variable    ${FLAG}    False
