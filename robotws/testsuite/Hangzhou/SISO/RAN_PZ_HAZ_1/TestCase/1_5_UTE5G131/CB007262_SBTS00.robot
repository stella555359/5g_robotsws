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
...                        peak_rate_config={"171":[200,10]}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    5G_CB007262_AEHC_3AHCA_MultiRat

${parameters}    [{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'PRACH configuration index',
...    'para_value':'89','require_reset':False},{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'Start RB',
...    'para_value':'4','require_reset':False},{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'Tilt Offset',
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

${GGMAP}    {"L1204101448":{"1": "3.1.1", "2": "3.1.2", "7": "3.1.7"}, "L1231609493":{"7":"3.1.8"},
...         "L1212814013": {"1": "3.1.5", "2": "3.1.6"}, "AS210918787":{"1":"3.1.3","2":"3.1.4"}}

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    No module fan detected    NgGnbInitPartialReset
...                                   Unstable eCPRI Link Detected

${link_dict}    {"L1212814013": {"break": "3.1.1:3.1.5;3.1.2:3.1.6", "connect": "3.3.3:3.1.2;3.3.4:3.1.6"}}

*** Test Cases ***
[1][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    QC_33126    QCD_MN_RAN    QCP_RAN_VRF
    [Timeout]    72h
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=5G_CB007262_AEHC_3AHCA_MultiRat
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    Testcase Basic Postcondition

[1][1.0] SISO_RF module power reset
    [Tags]    QC_33125    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_Power_Reset
    Askey Power Reset
    SISO_RF module power reset    required_cells=171:179:180:181
    [Teardown]    Testcase Basic Postcondition

[1] SISO_Recovery RF module reset
    [Tags]    QC_33127    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=rf_reset
    Askey Power Reset
    SISO_Recovery RF module reset    required_cells=171:179:180:181
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Cell Block Then resetBBmod Then Unblock
    [Tags]    QC_33119    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_resetBBmod_Unblock
    Askey Power Reset
    Common_SiSo_State Management_cell Lock_Then_resetBBMOD_Then_cell unlock    required_cells=171:179:180:181
    [Teardown]    Testcase Basic Postcondition

[1]Common_SiSo_Configuration Management_Delta plan Commissioning
    [Tags]    QC_33123    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Delta_commission
    Askey Power Reset
    ${parameters}    Evaluate    ${parameters}
    SiSo Multi Parameters Recommissioning    ${parameters}    required_cells=171:179:180:181
    [Teardown]    Testcase Basic Postcondition

#[2]Common_SiSo_Configuration Management_Delta plan Commissioning
#    [Tags]    QC_33124    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Delta_commission
#    ${objects_celltype_4DL4UL}    Evaluate    ${objects_celltype_4DL4UL}
#    ${parameters_celltype_4DL4UL}    Evaluate    ${parameters_celltype_4DL4UL}
#    ${objects_celltype_8DL4UL}    Evaluate    ${objects_celltype_8DL4UL}
#    ${parameters_celltype_8DL4UL}    Evaluate    ${parameters_celltype_8DL4UL}
#    FOR    ${i}    IN RANGE    25
#        Askey Power Reset
#        SiSo Multi Parameters Recommissioning    ${parameters_celltype_4DL4UL}    ${objects_celltype_4DL4UL}
#        ...    required_cells=171    ping=${False}
#        Askey Power Reset
#        SiSo Multi Parameters Recommissioning    ${parameters_celltype_8DL4UL}    ${objects_celltype_8DL4UL}
#        ...    required_cells=171    ping=${False}
#        Logging Multinode Restart
#    END
#    [Teardown]    Testcase Basic Postcondition

[2]Common_SiSo_Configuration Management_Delta plan Commissioning
    [Tags]    QC_33124    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Delta_commission
    Set Library Search Order    _Parameter_Operation
    FOR    ${i}    IN RANGE    25
        Set Test Variable    ${FLAG}    True
        Askey Power Reset
        Delta File Commission For Celltype    ${CURDIR}/4DL4UL.json    4DL4UL    required_cells=171
        Askey Power Reset
        Askey ADB Reset
        Delta File Commission For Celltype    ${CURDIR}/8DL4UL.json    8DL4UL    required_cells=171
        Logging Multinode Restart    test_status=${FLAG}
    END
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Testcase Basic Postcondition

[1][2.0] Exceptional_RF Fiber Insert&Removal Break_both_Primary&Secondary_Link
    [Tags]    QC_33122   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=fiber_insert_remove    config_id=5G_CB007262_AEHC_3AHCA_MultiRat
    SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'L1212814013': 'secondary'}
    SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'L1212814013': 'primary'}
    SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'L1212814013': ['primary', 'secondary']}
    SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'AS210918787': 'secondary'}
    SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'AS210918787': 'primary'}
    SiSo Recovery Hot Remove And Insert RF fibers    rflink={'AS210918787': ['primary', 'secondary']}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock & Unlock_Then_Cell Block & unblock
    [Tags]    QC_33128    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RU_Lock_Unlock_Then_Cell Block_unblock   config_id=5G_CB007262_AEHC_3AHCA_MultiRat
    Askey Power Reset
    Ru lock And Unlock All    required_cells=171:179:180:181
    Cell Block And Unblock All    required_cells=171:179:180:181
    [Teardown]    Testcase Basic Postcondition

[1][4.0] Manual_SiSo_SM_NR_RAT_reset
    [Tags]    QC_33130    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=5G_CB007262_AEHC_3AHCA_MultiRat
    Askey Power Reset
    RAT reset from WebEm For NR testline    required_cells=171
    [Teardown]    Testcase Basic Postcondition

[1][4.0] Manual_SiSo_SM_LTE_RAT_reset
    [Tags]    QC_33129    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=5G_CB007262_AEHC_3AHCA_MultiRat
    Askey Power Reset
    LTE_RAT_reset_for_concurrent    required_cells=181
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_power off then on secondary core
    [Tags]    QC_181285    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=5G_CB007262_AEHC_3AHCA_MultiRat
    Askey Power Reset
    Common_SiSo_Recovery_power off then on secondary core    required_cells=171:179:180:181
    [Teardown]    Testcase Basic Postcondition

#[1] General_SiSo_Recovery_Multiple changes_of_Long optical fiber
#    [Tags]    QC_33121   QCD_MN_RAN   QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=fiber_insert_remove    config_id=AEHC_one_fiber_3AHCA
#    FOR    ${i}    IN RANGE    ${1}
#        Askey Power Reset
#        General_SiSo_Recovery_Multiple changes_of_Long optical fiber    L1202005438    ${link_dict}
#        ...    required_cells=171
#    END
#    [Teardown]    Testcase Basic Postcondition

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

Common_SiSo_Recovery_power off then on secondary core
    [Arguments]    ${required_cells}=${EMPTY}
    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FSM']['L1182811441']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FSM']['L1182811441']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FSM']['L1182811441']['pdu']['port']}
    sleep    1 min
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FSM']['L1182811441']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FSM']['L1182811441']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FSM']['L1182811441']['pdu']['port']}
    Run Keyword And Continue On Failure    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    ${alarm1}    Set Variable    BTS secondary core autonomous reset as recovery action:Fault signature for crash or failure
    ${alarm2}    Set Variable    RAT autonomous reset as recovery action:No connection between primary and BTS extension system module
    Check Historical Alarms    additional_allowed_alarms=${alarm1}:${alarm2}
    Make L3call    required_cells=${required_cells}
