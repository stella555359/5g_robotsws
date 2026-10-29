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
[1][1.0] Template commission
    [Tags]    QC_50394    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=commission    config_id=CB009542_ASOF_2AWHHF_9cell_NR50M_40M_LTE20M_10M
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Call_Throughput Measurements (UDP)
    [Tags]    QC_33168    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3Call
    Make Tput      required_cells=331
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Configuration Management_Delta plan Commissioning
    [Tags]    QC_33165    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Commissioning     config_id=CB009542_ASOF_2AWHHF_6cell_NR100M_LTE20M
    ${cell_info}   Get Cell Info With PCI    ${ALL_CELL_LIST}    341
    SuperCell Reconfiguration With Half Subcell Expansion2    ${cell_info}
    [Teardown]    Testcase Basic Postcondition

[1][2.0] Manual_SiSo_SM_NR_RAT_reset
    [Tags]    QC_33164    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=NR_RAT_reset
    RAT reset from WebEm For NR testline    required_cells=341
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_SuperCell_Subcell_failure_statemangement
    [Tags]    QC_33163    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=NR_RAT_reset
    Append To List      ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}      Not able to synchronize baseband bus
    Append To List      ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}      Unit power reset
    Common_SiSo_State Management_Sub-cell failure in super cell configuration    required_cells=341
    Remove From List     ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}     -1
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_hot remove and insert RF fibers
    [Tags]    QC_33169    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RemovePrimFiber
    SiSo Recovery Hot Remove And Insert RF Fibers     rflink={'AH232601217': ['primary', 'seccondary']}
    [Teardown]    Testcase Basic Postcondition

[2][1.0] Common_SiSo_Recovery_hot remove and insert RF fibers
    [Tags]    QC_33170    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RemovePrimFiber    config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    SiSo Recovery Hot Remove And Insert RF Fibers     rflink={'AH232601217': ['primary', 'seccondary']}
    [Teardown]    Testcase Basic Postcondition


#[1][1.0] Automated__Startup_Site_Reset_Without HWF repetition
#    [Tags]    QC_33167    QCD_MN_RAN   QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Site_Reset
#    Stability Site Reset    repetition=1
#    [Teardown]    Testcase Basic Postcondition

[1][1.0]CB013082_radio_module_recover_after_secondary_link_4685_actForceUnitAutoReset_true
    [Tags]    QC_33171   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    CB013082 radio module recovers after link break triggering 4685 actForceUnitAutoReset    fr_sn=AH232601217    link_type=secondary
    ...    extra_fiber=['23','34']      required_cells=334:335
    [Teardown]    Testcase Basic Postcondition

[1][1.0] CB013082_radio_module_recover_after_secondary_link_4685_actForceUnitAutoReset_false
    [Tags]    QC_33172   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair      config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    CB013082 radio module recovers after link break triggering 4685 actForceUnitAutoReset    fr_sn=AH232601217    link_type=secondary
        ...    extra_fiber=['23','34']     online_parameters=${online_commissioning1}      required_cells=334:335
    [Teardown]    Testcase Basic Postcondition

[2][1.0] CB013082_radio_module_recover_after_secondary_link_4685_actForceUnitAutoReset_true
    [Tags]    QC_33173   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair      config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    FOR    ${i}    IN RANGE    ${3}
        CB013082 radio module recovers after link break triggering 4685 actForceUnitAutoReset    fr_sn=AH232601217    link_type=secondary
        ...    extra_fiber=['23','34']      required_cells=334:335
    END
    [Teardown]    Testcase Basic Postcondition


*** Keywords ***
SuperCell Reconfiguration With Half Subcell Expansion2
    [Arguments]    ${cell_info}
#    Get And Check Reset Counter For All BTS Node
    ${bts_id}    Set Variable    ${cell_info["btsId"]}
    ${alias}    Set Variable    ${CASE_NAME}_${bts_id}_ui
    ${scf_file}    Set Variable    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ${localIpAddr}    Get Scfc localIpAddr    ${scf_file}
    ${channelgroup_id_list}    Get Dictionary Keys    ${cell_info["channelgroup"]}
    ${subcell_count}    Get Length    ${channelgroup_id_list}
    ${count}    Evaluate    int(${subcell_count}/2)
    ${left_subcell}    Evaluate    ${subcell_count}-${count}
    ${change_channelgroup_id}    Set Variable    ${channelgroup_id_list}[-${count}:]

    Selenium Login    url=https://${localIpAddr}
    ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${alias}

    Delete SubCells In One Cell    ${cell_info["cellId"]}    ${change_channelgroup_id}    ${bts_id}    alias=${alias}
    selenium_coam.remove_element
    ...    dist_name=${cell_info["distName"]}
    ...    abbr=eirpControlPowerReductionFactorList    filter_param=List of EIRP control power reduction factor per cell segment
    ...    node_index=2     sbts=${alias}
    Selenium Active Plan    alias=${alias}
#    ${current_scfc}    Get Current Scfc    ${bts_id}
#    ${bbu_list}    ${rmod_list}    ${cell_list}    ${rmod_chain}    btsInfo    ${current_scfc}
    ${new_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${cell_info["phyCellId"]}
    ${actual_subcell}    Evaluate    len(${new_cell_info["channelgroup"]}.keys())
    Should Be Equal As Integers    ${left_subcell}    ${actual_subcell}
    Run Keyword And Continue On Failure    Make Tput For One Super Cell    cell_info=${new_cell_info}
    ...    extra_peak_rate_config=${PEAK_RATE_CONFIG}
    Selenium Refresh Page     alias=${alias}
    Add SubCells In One Cell    ${cell_info["cellId"]}    ${change_channelgroup_id}    ${bts_id}    ${scf_file}    alias=${alias}
    selenium_coam.Add Element    dist_name=${cell_info["distName"]}     abbr=eirpControlPowerReductionFactorList
    ...    filter_param=List of EIRP control power reduction factor per cell segment    sbts=${alias}
    Selenium Active Plan    alias=${alias}
    Run Keyword And Continue On Failure    Make Tput For One Super Cell    cell_info=${cell_info}
    ...    extra_peak_rate_config=${PEAK_RATE_CONFIG}
#    ${supercell_count}    Get Supercell Count With BtsId    ${bts_id}
#    ${reset_count}    Set Variable If    "${supercell_count}"=="1"    2    0
#    Get And Check Reset Counter For All BTS Node     correct_reset_counter=${reset_count}
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout    alias=${alias}
#    ...    AND   Run Keyword If    "${KEYWORD_STATUS}"=="FAIL"    Recover Scfc    ${bts_id}    ${scf_file}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout    alias=${alias}