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
${INIT_CONFIG_ID}    CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    PPS reference missing
...                                   GPS receiver alarm: position questionable
...                                   GPS receiver alarm: not tracking satellites
...                                   GNSS autonomous reset as recovery action
${online_commissioning1}    [{'distName':'MRBTS-37087/MNL-1/MNLENT-1/FMCADM-1','paraName':'actForceUnitAutoReset','paraValue':'false'}]
${GLO_PERFORM_SAVE_LOG}    FAIL
*** Test Cases ***
[1][1.0]CB013082_radio_module_recover_after_secondary_link_4685_actForceUnitAutoReset_true
    [Tags]    QC_847823   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    CB013082 radio module recovers after link break triggering 4685 actForceUnitAutoReset    fr_sn=AH232601217    link_type=secondary
    ...    extra_fiber=['23','34']      required_cells=334:335
    [Teardown]    Testcase Basic Postcondition

[1][1.0] CB013082_radio_module_recover_after_secondary_link_4685_actForceUnitAutoReset_false
    [Tags]    QC_847832   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair      config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    CB013082 radio module recovers after link break triggering 4685 actForceUnitAutoReset    fr_sn=AH232601217    link_type=secondary
        ...    extra_fiber=['23','34']     online_parameters=${online_commissioning1}      required_cells=334:335
    [Teardown]    Testcase Basic Postcondition

[2][1.0] CB013082_radio_module_recover_after_secondary_link_4685_actForceUnitAutoReset_true
    [Tags]    QC_847824   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair      config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    FOR    ${i}    IN RANGE    ${3}
        CB013082 radio module recovers after link break triggering 4685 actForceUnitAutoReset    fr_sn=AH232601217    link_type=secondary
        ...    extra_fiber=['23','34']      required_cells=334:335
    END
    [Teardown]    Testcase Basic Postcondition
