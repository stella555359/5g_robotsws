*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        bibo.lei@nokia-sbell.com
...    Maintainer:    blei

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/affa.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_model.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/variables.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${ASOF_3AWHHF_9cell_NR50M_LTE20M}=    {"331":[160,25],"332":[105,7],"333":[105,9],"334":[400,30],"335":[105,9],
...    "336":[105,9],"337":[400,30],"338":[105,9],"339":[105,9]}
&{CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M}    HW_ID=AWHHF   site_mode=5G    ONAIR_TIME=15 min
...    GG=89:90;100:101;111:112;122:123;133:134;144:145
...	   peak_rate_config=${ASOF_3AWHHF_9cell_NR50M_LTE20M}

${ASOF_2AWHHF_6cell_NR100M_LTE20M}=    {"341":[90,25],"342":[105,9]}
&{CB009542_ASOF_2AWHHF_6cell_NR100M_LTE20M}    HW_ID=AWHHF   site_mode=5G    ONAIR_TIME=15 min
...    GG=100:101;111:112;122:124;133:134;144:145
...	   peak_rate_config=${ASOF_2AWHHF_6cell_NR100M_LTE20M}

${ASOF_2AWHHF_9cell_NR50M_40M_LTE20M_10M}=    {"331":[70,25],"332":[105,9],"333":[105,9],"334":[400,30],"335":[105,9],
...    "336":[105,9],"337":[300,30],"338":[105,9],"339":[51,4.5]}
&{CB009542_ASOF_2AWHHF_9cell_NR50M_40M_LTE20M_10M}    HW_ID=AWHHF   site_mode=5G    ONAIR_TIME=15 min
...    GG=89:90;100:101;122:123;133:134
...	   peak_rate_config=${ASOF_2AWHHF_9cell_NR50M_40M_LTE20M_10M}

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${parameters}    [{'dist_name':'MRBTS-37087/MNL-1/MNLENT-1/SYNC-1','para_name':'Manual frame timing adjustment',
...    'para_value':'1 (microseconds)','require_reset':True,'required_reset_bts_id': '37087'},
...    {'dist_name':'MRBTS-37087/NRBTS-37087','para_name':'Activate Paging','para_value':'false',
...    'require_reset':'rat_reset'}]
#${ru_password_user}=    KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
${GGMAP}    {"AH232601217":{"2": "100:101","3": "133:134"},"EB194060094":{"1": "111:112","2": "144:145"}}
#${INIT_CONFIG_ID}    CB009542_ASOF_2AWHHF_6cell_NR100M_LTE20M
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    PPS reference missing
...                                   GPS receiver alarm: position questionable
...                                   GPS receiver alarm: not tracking satellites

*** Test Cases ***
[1][1.0] Template commission
    [Tags]    QC_693788    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=commission    config_id=CB009542_ASOF_2AWHHF_9cell_NR50M_40M_LTE20M_10M
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Configuration Management_Delta plan Commissioning
    [Tags]    QC_693789    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Commissioning     config_id=CB009542_ASOF_2AWHHF_6cell_NR100M_LTE20M
    ${cell_info}   Get Cell Info With PCI    ${ALL_CELL_LIST}    341
    SuperCell Reconfiguration With Half Subcell Expansion    ${cell_info}
    [Teardown]    Testcase Basic Postcondition

[1][2.0] Manual_SiSo_SM_NR_RAT_reset
    [Tags]    QC_693790    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=NR_RAT_reset
    RAT reset from WebEm For NR testline    required_cells=341
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_SuperCell_Subcell_failure_statemangement
    [Tags]    QC_740631    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=NR_RAT_reset
    Append To List      ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}      Not able to synchronize baseband bus
    Append To List      ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}      Unit power reset
    Common_SiSo_State Management_Sub-cell failure in super cell configuration    required_cells=341
    Remove From List     ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}     -1
    [Teardown]    Testcase Basic Postcondition

[2][1.0] Common_SiSo_Recovery_hot remove and insert RF fibers
    [Tags]    QC_693785    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=RemovePrimFiber
    SiSo Recovery Hot Remove And Insert RF Fibers     rflink={'AH232601217': ['primary', 'seccondary']}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_hot remove and insert RF fibers
    [Tags]    QC_693784    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=RemovePrimFiber    config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    SiSo Recovery Hot Remove And Insert RF Fibers     rflink={'AH232601217': ['primary', 'seccondary']}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Call_Throughput Measurements (UDP)
    [Tags]    QC_693786    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=L3Call
    Make Tput      required_cells=331:332
    [Teardown]    Testcase Basic Postcondition


[1][1.0] Automated__Startup_Site_Reset_Without HWF repetition
    [Tags]    QC_693787    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Site_Reset
    Stability Site Reset    repetition=1
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Call_Throughput Measurements (UDP)_MP
    [Tags]    QC_764070    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=L3Call    config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    Make Tput      required_cells=331:332
    [Teardown]    Testcase Basic Postcondition

[1][2.0] Manual_SiSo_SM_NR_RAT_reset_MP
    [Tags]    QC_764066    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=NR_RAT_reset    config_id=CB009542_ASOF_2AWHHF_6cell_NR100M_LTE20M
    RAT reset from WebEm For NR testline    required_cells=341
    [Teardown]    Testcase Basic Postcondition
