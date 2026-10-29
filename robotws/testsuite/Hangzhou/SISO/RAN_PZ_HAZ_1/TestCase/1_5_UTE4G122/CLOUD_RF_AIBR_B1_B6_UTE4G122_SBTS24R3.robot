*** Settings ***
Documentation    Suite description
...    Author:        nick.1.wu@nokia-sbell.com
...    Maintainer:    Wu Nick

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py

Force Tags        CLOUD_RF_AILR_B1_B6_AAHD_AZQF_FRPA    CA_GVe    RAN_5G_TDD    RAN_5G    SBTS24R3
...    STATE_SW_UPLOADED

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${para1}    1.1.1:1.3.1;1.1.2:1.3.2;1.1.3:1.3.3;1.1.4:1.3.4;1.1.5:1.3.5;1.1.6:1.3.6;1.1.7:1.3.7;1.1.8:1.3.8;
${para2}    1.2.5:1.4.1;1.2.6:1.4.2;1.2.7:1.4.3;1.2.8:1.4.4;1.2.1:1.4.5;1.2.2:1.4.6;1.2.3:1.4.7;1.2.4:1.4.8
&{2AAHF_T3_AZQF_AZNB_T4_FXED_T6}    SM=L1182811442|L1190601917
...                      RF=1M194603257|1M194603256|6Q181710305|6Q181710303|1M173634014|L1162105358
...                      GG=${para1}${para2}
...                      HW_ID=2AAHF_T3_AZQF_AZNB_T4_FXED_T6    ONAIR_TIME=20 min     site_mode=4G
&{2AEHB_T3_AZQF_AZNB_T4_FXED_T6}    SM=L1182811442|L1190601917
...                      RF=L1211113059|L1213414030|6Q181710305|6Q181710303|1M173634014|L1162105358
...                      GG=2.1.1:2.7.1;2.1.2:2.7.2
...                      HW_ID=2AEHB_T3_AZQF_AZNB_T4_FXED_T6    ONAIR_TIME=20 min     site_mode=4G
&{ET_AZQF_ABIC_ABIA}    SM=L1182811442|L1190601917
...                      RF=6Q181710303
#...                      GG=3.6.1:3.6.5;3.6.2:3.6.6
...                      HW_ID=ET_AZQF_ABIC_ABIA    ONAIR_TIME=20 min     site_mode=4G

${KEY_PERFORM_HW_SETUP}    True
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    2AEHB_T3_AZQF_AZNB_T4_FXED_T6

#${attachs_aehb}    133:135:138:140:1:4:5:142:145:130:131:132:141:146:147
${attachs_aehb}    140
#${attachs_aahf}    133:134:135:137:138:140:142:143:144:130:132:141
${target_ru_info_abic_abia}    [{'serialNo':'6Q181710303',
...    'breaklink':'3.6.6:3.6.2',  'linksec':'3.6.6:1.1.3'}]
${btsids}    [2396]
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    RX Power too low    Unstable eCPRI Link Detected
...    Auto-negotiation mismatch on SMOD-1, EIF3    LOS on SMOD-1, EIF3
${GLO_PERFORM_SAVE_LOG}    FAIL

*** Test Cases ***
[2][1.0] Onair SiSo_Exploratory
    [Tags]    QC_847897    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    Site Reset
    [Teardown]    Testcase Basic Postcondition

[2][1.0] 1UE ULDL Peak rate
    [Tags]    QC_847893    QCD_MN_RAN    QCP_RAN_ST
    [Setup]   Testcase Basic Precondition    case_name=L3call    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    Make Tput   required_cells=${attachs_aehb}
    [Teardown]    Testcase Basic Postcondition

[2] SISO SFP transceiver temperrature too high on RRU
    [Tags]    QC_847877    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Fault_4698    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    RF Fault 4698 SFP transceiver temperrature too high    rf_sn=6Q181710305
    [Teardown]    Testcase Basic Postcondition

[1][1.0] ABIC_ABIA_Fault_4525_EFaultId_UnsupportedRadioConnectionConfigurationAl
    [Tags]    QC_847898   QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=UnsupportedRadioConnectionConfigurationAl
    ...    config_id=ET_AZQF_ABIC_ABIA
#    ${target_ru_info_abic_abia}    Evaluate    ${target_ru_info_abic_abia}
#    ${btsids}    Evaluate    ${btsids}
#    Unsupported Radio Connection Between ABIA And ABIC Configuration With Fault 4525
#    ...    target_ru_info=${target_ru_info_abic_abia}    btsids=${btsids}
    Site Reset
    [Teardown]    Testcase Basic Postcondition

[a] Common_SiSo_RAT reset
    [Timeout]    2h
    [Tags]    QC_415746   QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    RAT reset from WebEm For LTE testline
    [Teardown]    Testcase Basic Postcondition

[b][1.0] RF module reset_Then_BBMOD_reset
    [Tags]    QC_79481   QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
    [Teardown]    Testcase Basic Postcondition

[c][1.0] Block & Unblock cell_Then_ RF lock & unlock
    [Tags]    QC_79481   QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    Common_SiSo_State Management_Block & Unblock cell_Then_ RF lock & unlock
    [Teardown]    Testcase Basic Postcondition


*** Keywords ***
RAT reset from WebEm For LTE testline
    Get NR and LTE Cell List
    RAT reset and make L3call    LTE
    sleep    180
    Verify All Cells OnAir
    Check Alarms
    Check Historical Alarms

RAT reset and make L3call
    [Arguments]    ${rat_type}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        coam.rat_reset    rat_type=${rat_type}    timeout=260    connection=${CASE_NAME}_${bts_id}
        Wait Until Keyword Succeeds    600sec    10sec    Verify All Cells OnAir
    END

Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Arguments]    ${bbmod_id_list}=${EMPTY}
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Lock RU   ${btsId}
    END
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Reset BB Module   require_bbmod=${bbmod_id_list}    btsid=${btsId}
    END
    FOR    ${bts_id}    IN   @{ALL_BTS_ID_LIST}
        Admin HW Check    BBMOD   ${NODE_CFG['${bts_id}'].bbmod_sn_list}    parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
        Admin HW Check    RMOD   ${NODE_CFG['${bts_id}'].fr_sn_list}     parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
    END
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Unlock RU   ${btsId}
    END
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
    [Arguments]    ${bbmod_id_list}=${EMPTY}     ${required_power_rfs}=${EMPTY}
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Radio Reset without onair    ${fr_serial_number}
    END

    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Reset BB Module   require_bbmod=${bbmod_id_list}    btsid=${btsId}
    END
    FOR    ${bts_id}    IN   @{ALL_BTS_ID_LIST}
        Admin HW Check    BBMOD   ${NODE_CFG['${bts_id}'].bbmod_sn_list}    parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
        Admin HW Check    RMOD   ${NODE_CFG['${bts_id}'].fr_sn_list}     parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
    END

    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Common_SiSo_State Management_cell Lock_Then_resetBBMOD_Then_cell unlock
    [Arguments]    ${bbmod_id_list}=${EMPTY}    ${required_cells}=${EMPTY}
    ${cell_list}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${ALL_CELL_LIST}    ${required_cells}
    ...    ELSE    Choose Cells    ${ALL_CELL_LIST}
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
    END
#    sleep  3min
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Reset BB Module   require_bbmod=${bbmod_id_list}    btsid=${btsId}
    END
    sleep  3min
    FOR    ${bts_id}    IN   @{ALL_BTS_ID_LIST}
        Admin HW Check    BBMOD   ${NODE_CFG['${bts_id}'].bbmod_sn_list}    parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
        Admin HW Check    RMOD   ${NODE_CFG['${bts_id}'].fr_sn_list}     parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
    END
#    sleep  5min
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Alarms
    Check Historical Alarms     additional_allowed_alarms=Cell blocked
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Common_SiSo_State Management_Block & Unblock cell_Then_ RF lock & unlock
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
    END
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
         ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
         Lock RU   ${btsId}
         Wait Until Keyword Succeeds    5min    10 sec    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled"
         ...    timeout=600s    alias=${CASE_NAME}_${bts_id}
         Unlock RU   ${btsId}
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
    END
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms    additional_allowed_alarms=Cell blocked
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
    [Documentation]   Auther:qing.2.he@nokia-sbell.com
    [Arguments]    ${timeout}=10 min    ${required_power_rfs}=${EMPTY}
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
    Lock RU   ${btsId}
    END
    sleep    2min
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    ${cell_cross_rru}    Check Is Cell Cross RRU
    FOR    ${fr_serial_number}    IN    @{rf_list}
         Radio Reset without onair    ${fr_serial_number}
    END
    sleep   2min
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
    Unlock RU   ${btsId}
    END
    Wait For All Cells OnAir    timeout=${timeout}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
    [Arguments]    ${required_power_rfs}=${EMPTY}
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"
    ...    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    ${rat_type_list}    Create List
    FOR    ${btsId}    IN    @{BTS_LIST}
        ${cell_type}    Set Variable    ${NODE_CFG['${btsId}'].cells_class_name}
        Run Keyword IF    ${cell_type}==['NRCEL', 'LNCEL']    Evaluate    $rat_type_list.append(["NR","LTE"])
        ...    ELSE IF    ${cell_type}==['WNCEL', 'LNCEL']    Evaluate    $rat_type_list.append(["WCDMA","LTE"])
        ...    ELSE IF    ${cell_type}==['NRCEL']    Append To List    ${rat_type_list}    NR
        ...    ELSE IF    ${cell_type}==['LNCEL']    Append To List    ${rat_type_list}    LTE
        ...    ELSE IF    ${cell_type}==['WNCEL']    Append To List    ${rat_type_list}    WCDMA
        ...    ELSE IF    ${cell_type}==['GNCEL']    Append To List    ${rat_type_list}    GSM
    END
    FOR    ${rat_type_sub}    IN    @{rat_type_list}
        ${is_list}    Evaluate    isinstance($rat_type_sub,list)
        ${rat_type_concurrent}    Set Variable If    ${is_list}    ${rat_type_sub}    ${rat_type_list}
    END
    ${rat_type}    Evaluate    random.choice(${rat_type_concurrent})   modules=random
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Radio Reset without onair    ${fr_serial_number}
    END
    FOR    ${btsId}    IN    @{BTS_LIST}
        coam.reset_rat    rat_type=${rat_type}    timeout=260    connection=${CASE_NAME}_${bts_id}
    END
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Admin HW Check    RMOD    ${NODE_CFG['${bts_id}'].fr_sn_list}
        ...    parameters=operationalState=regex"(?i)Enabled"    timeout=600s    connection=${CASE_NAME}_${bts_id}
    END
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

