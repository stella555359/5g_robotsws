*** Settings ***
Documentation
...    Author: Zhao Lanhua
...    Contact: lanhua.zhao@nokia-sbell.com
...    This file is for CRT regression cases in TL37014.
...    Please do not modify the file without notification to author
...    Deprecated case removed by civen.chen
#
#Suite Setup    Common Suite Setup For AIC
#Suite Teardown     Custom Suite Teardown For AIC
#
#Force Tags
#...      CRT             #Tag Item
#...      RAN_PZ_HAZ_1             #Competence Area
#...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
#...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]
#
#Test Timeout    600 minutes
#
#Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
#Resource          ../../T02/Common_Case/common_resource_new.robot
#
#*** Variables ***
#${TESTLINE_NAME}             7_5_UTE5GAIC025T006
#
#*** Test Cases ***
#CB010414_CB012113_01_UE is redirected to LTE via RRC Connection Release with actNormVCFallbackEnh enabled
#    [Tags]    CRT    CB012113     VCFB
#    [Documentation]
#    ...    Author: lanhua.zhao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    23.04.2024, lanhua.zhao@nokia-sbell.com draft
#    [Setup]    Common Case Precondition
#    Online Set VCU Parameter To True
#    wait until keyword succeeds    10min    30s    Check All Cells On Air In vCU
#    Prepare PA Signal for NRCELL1
#    Start Counter For CB012113_VCFB
#    Prepare And Attach UE    ue_index=0    ui_version=S21
#    Start VONR Call For UE    ue_index=0    capabilities=REAL_ANDROID_UE    duration=60s
#    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    Log to Console    \nstart wireshark
#    Change PA for VONR Fallback To LTE
#    Sleep    10s     reason=Wait For vocie fallback
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    Log To Console    \nWireshark log of VCU: ${local_file_path}
#    Check Wireshark for ICS RESPONSE     wireshark_path=${local_file_path}
#    sleep    10min
#    Log to Console		\nwaiting for CU counters update
#    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
#    [Teardown]    Common Case Postcondition
#
#CB010414_CB012113_02_parameter config and PDL check
#    [Tags]    CRT    CB012113     PDL
#    [Documentation]
#    ...    Author: lanhua.zhao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    22.04.2024, lanhua.zhao@nokia-sbell.com draft
#    [Setup]    Common Case Precondition
#    Online Change VCU Parameter 5 Times
#    Online Change CUDU Parameter 5 Times
#    Prepare PA Signal for NRCELL1
#    Prepare And Attach UE    ue_index=0    ui_version=S21
#    Start VONR Call For UE    ue_index=0    capabilities=REAL_ANDROID_UE    duration=60s
#    Change PA for VONR Fallback To LTE
#    Sleep    5s     reason=Wait For vocie fallback
#    Run Keyword And Ignore Error    Stop VONR Call For UE
#    [Teardown]    Common Case Postcondition
#
#CB010413_02_CB008159_NR_Additional_PM_counters_Verify_on_FDD_NSA
#    [Tags]        CRT      CB008159
#    [Documentation]
#    ...    Author: juan.liu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    29.2.2024,juan.liu@nokia-sbell.com, draft
#    [Setup]        Common Case Precondition
#    Set Library Search Order    AIC_UE    real_ue
#    Start Check vDU Counter For CB008159
#    Start Check vCU Counter For CB008159
#	Prepare PA for LTE
#	Prepare And Attach UE    ue_index=1
#    Change PA Signal To Add NRCELL2 For NSA
#	Start Call For UE    ue_index=1    direction=dl
#    Sleep    10min
#    Log to Console		\nwaiting for counters update
#    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0
#    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
#    [Teardown]        Common Case Postcondition
#
#CB008281_01_Active_deactive_funtion_online_TDD
#    [Tags]    CRT    CB008281    Thor
#    [Documentation]
#    ...    Author: lanhua.zhao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    04.03.2024, lanhua.zhao@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    wait until keyword succeeds    20min    30s    Check All Cells On Air In vCU
#    Online change Parameter1 five times
#    Online change Parameter2 five times
#	Prepare PA Signal for NRCELL1
#    Prepare And Attach UE    ue_index=0    ui_version=S21
#    Start Call For UE      ue_index=0    direction=dl
#    [Teardown]    Common Case Postcondition
#
#CB011169_15_CNI_78446_A_1_SA_Inital_RRC_Setup_with_dedicated_config_in_initialDownlinkBWP_with_large_BWP
#    [Tags]    CRT    CB011169     BWP
#    [Documentation]
#    ...    Author: lanhua.zhao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    09.05.2024, lanhua.zhao@nokia-sbell.com draft
#    [Setup]    Common Case Precondition
#    Start 3 Counters in VDU For CNI78446
#    Online Change Parameters In vDU
#    wait until keyword succeeds    10min    30s    Check All Cells On Air In vCU
#    Prepare PA Signal for NRCELL2
#    Log to console     \nattachUE
#    Prepare And Attach UE    ue_index=0    ui_version=S21
#    Start Call For UE    ue_index=0    direction=dl
#    sleep    10min
#    Log to Console		\nwaiting for DU counters update
#    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0
#    [Teardown]    Common Case Postcondition
#
#CB011169_18_CNI-80045_01_gNB BC selection based on allowedBC-ListMRDC order from eNB during EN-DC setup - FR1 NSA multi NR band
#    [Tags]    CRT    CB011169     ENDC
#    [Documentation]
#    ...    Author: lanhua.zhao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    15.05.2024, lanhua.zhao@nokia-sbell.com draft
#    [Setup]    Common Case Precondition
#    Set Library Search Order    AIC_UE    real_ue
#    Online Change VCU Parameter To Enable Feature
#    wait until keyword succeeds    10min    30s    Check All Cells On Air In vCU
#    Prepare PA Signal for LTECELL
#    Prepare And Attach UE    ue_index=1
#    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    Log to Console    \nstart wireshark
#    Change PA Signal To Add NRCELL For NSA
#    Sleep    5s     reason=Wait For wireshark capture
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    Log To Console    \nWireshark log of VCU: ${local_file_path}
#    Run Keyword And Ignore Error     Detach M80
#    Check Wireshark for SGNB ADD ACK     wireshark_path=${local_file_path}
#    [Teardown]    Common Case Postcondition
#
#CB013032_32_Parameters_under_MNL-EQM-TNL-NRBTS_Related Functions_check_in_WebEM_testline config1
#    [Tags]    CRT    CB013032    METADATA
#    [Documentation]
#    ...    Author: lanhua.zhao@nokia-sbell.com
#    ...    history change: 06.03.2025,lanhua.zhao@nokia-sbell.com draft
#    [Setup]    Common Case Precondition
#    Get Parameter Details In vCU
#    Get Parameter Details In vDU
#    [Teardown]    Common Case Postcondition
#
#*** Keywords ***
#Common Case Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    ${NEW_PLAN_NAME}    Get Test Case Name
#    Set Test Variable    ${NEW_PLAN_NAME}
#
#Common Case Postcondition
#    log to console    Case Postcondition
#    Common Test Teardown For AIC
#    vDU Login By Rest
#    Run Keyword And Ignore Error    plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error    svdu.Delete Plan  plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error    vDU Logout By Rest
#    Run Keyword And Ignore Error    Detach UE0
#    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
#    ...                                                             conn=${conn}    timeout=${timeout}
#
#Prepare And Attach UE
#    [Arguments]    ${ue_index}=${0}    ${ui_version}=default
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
#    Log to Console    \n***Prepare UE***
#    Prepare UE    ${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
#    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
##    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
##    Sleep    60s    reason=wait attach UE Successfully
#    [Return]     ${ue_${ue_index}_type}
#
#Detach UE0
#    UE Detach    ${ue0_type}    ue_index=${0}
#
#Start Call For UE
#    [Arguments]    ${ue_index}=${0}        ${direction}=dl
#    Start traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
#	...              throughput=110M    duration=${300}
#	sleep    5s    reason=wait call sucessfully
#
#Custom Suite Teardown For AIC
#    Common Suite Teardown For AIC
#    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
#    ${result}    Run Process    ${cmd}    shell=True
#    log to console    ${result.stdout}
#    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
#    ${result}    Run Process    ${cmd_new}    shell=True
#    log to console    ${result.stdout}
#    log to console    ${result.stderr}
#    log to console    ${result.rc}
#
#Start VONR Call For UE
#    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_ANDROID_UE    ${duration}=60s
#    Log to Console    ***Prepare to start a VONR call.***
#    Start VONR Call    ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}    vc_alias=VC_1    call_number=004488    duration=${duration}
#    ...                capabilities=${capabilities}
#    Log to Console    \n***Started VONR call..***
#
#Stop VONR Call For UE
#    [Arguments]    ${ue_index}=${0}
#    Log to Console    ***Prepare to stop a ue VoNR call.***
#    Stop VONR Call    ue_type=${ue_${ue_index}_type}    vc_alias=VC_1
#    Log to Console    \n***Stoped VONR call..***
#
############################### CB012113 ##############################
#Online Set VCU Parameter To True
#    @{para_list}           Create List    actNormVCFallbackEnh
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}     Create List    true
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter update result: ${out}
#
#Online Set VCU Parameter To False
#    @{para_list}           Create List    actNormVCFallbackEnh
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}     Create List    false
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter update result: ${out}
#
#Online Change VCU Parameter 5 Times
#    Log To Console    \nChange vCU parameter 5 times
#    Online Set VCU Parameter To False
#    Online Set VCU Parameter To True
#    Online Set VCU Parameter To False
#    Online Set VCU Parameter To True
#    Online Set VCU Parameter To False
#    Online Set VCU Parameter To True
#    Online Set VCU Parameter To False
#    Online Set VCU Parameter To True
#    Online Set VCU Parameter To False
#    Online Set VCU Parameter To True
#
#Set VCU Parameter to True
#    @{para_list}           Create List    actVoNR
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#    @{value_list_true}     Create List    true
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter update result: ${out}
#
#Set VCU Parameter to False
#    @{para_list}           Create List    actVoNR
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#    @{value_list_true}     Create List    false
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter update result: ${out}
#
#Set VDU Parameter to True
#    @{para_list}           Create List    actVoNR
#    @{mo_list_vdu}         Create List    MRBTS-37470/NRBTS-37014/NRCELL-2
#    @{value_list_true}     Create List    true
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vdu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VDU parameter update result: ${out}
#
#Set VDU Parameter to False
#    @{para_list}           Create List    actVoNR
#    @{mo_list_vdu}         Create List    MRBTS-37470/NRBTS-37014/NRCELL-2
#    @{value_list_true}     Create List    false
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vdu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VDU parameter update result: ${out}
#
#Online Set VCU And VDU Parameter to True
#    Set VCU Parameter to True
#    Set VDU Parameter to True
#
#Online Set VCU And VDU Parameter to False
#    Set VCU Parameter to False
#    Set VDU Parameter to False
#
#Online Change CUDU Parameter 5 Times
#    Log To Console    \nChange vCUvDU parameter 5 times
#    Online Set VCU And VDU Parameter to True
#    Online Set VCU And VDU Parameter to False
#    Online Set VCU And VDU Parameter to True
#    Online Set VCU And VDU Parameter to False
#    Online Set VCU And VDU Parameter to True
#    Online Set VCU And VDU Parameter to False
#    Online Set VCU And VDU Parameter to True
#    Online Set VCU And VDU Parameter to False
#    Online Set VCU And VDU Parameter to True
#    Online Set VCU And VDU Parameter to False
#
#Prepare PA Signal for NRCELL1
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[12]}=15    ${attenuation_channels[13]}=15
#    ...                                             ${attenuation_channels[2]}=70    ${attenuation_channels[3]}=70
#    ...                                             ${attenuation_channels[14]}=70    ${attenuation_channels[15]}=70
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Change PA for VONR Fallback To LTE
#    Set PA For NRCELL2 And LTE To 0
#    Increase PA For NRCELL1 Step By Step
#
#Set PA For NRCELL2 And LTE To 0
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[14]}=0    ${attenuation_channels[15]}=0
#    ...                                             ${attenuation_channels[2]}=0    ${attenuation_channels[3]}=0
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    NRCELL2 and LTE PA Changed.
#
#Increase PA For NRCELL1 Step By Step
#    Log to Console     \n***Increase NRCELL1 PA
#    FOR    ${PA_Value}    IN RANGE    15    51    5
#        ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#        &{channels_to_modify}    create dictionary   ${attenuation_channels[12]}=${PA_Value}
#        ...                                          ${attenuation_channels[13]}=${PA_Value}
#        Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#        sleep    2s
#    END
#
#Start Counter For CB012113_VCFB
#    ${rule1}    Catenate
#		...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
#        ...         Counter: M55124C02501;
#        ...         Counter rule: max(M55124C02501)>=1;
#    ${rule2}    Catenate
#		...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
#        ...         Counter: M55124C01502;
#        ...         Counter rule: max(M55124C01502)>=1;
#    ${rule3}    Catenate
#		...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
#        ...         Counter: M55125C02501;
#        ...         Counter rule: max(M55125C02501)>=1;
#    ${rule4}    Catenate
#		...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
#        ...         Counter: M55125C02502;
#        ...         Counter rule: max(M55125C02502)>=1;
#    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
#    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0
#
#Check Wireshark for ICS RESPONSE
#   [Arguments]    ${wireshark_path}=${wireshark_local_file_path_vCU}
#    &{analysis_dict}       Create Dictionary    filter_conditions=ngap
#    ${expect_message}=    Set Variable    InitialContextSetupResponse
#    ${result}=    Log Analysis    operation=filter    log_type=wireshark    log_path=${wireshark_path}
#    ...                           analysis_dict=${analysis_dict}
#    Should Contain    ${result}    ${expect_message}
#
############################### CB008159 ##############################
#Start Check vDU Counter For CB008159
#    ${rule1}    Catenate
#		...         Distname: MRBTS-37470/NRBTS-37014/NRCELL-2;
#        ...         Counter: M55306C09006;
#        ...         Counter rule: max(M55306C09006)>=1 and has_no_0_value(M55306C09006);
#    ${rule2}    Catenate
#		...         Distname: MRBTS-37470/NRBTS-37014/NRCELL-2;
#        ...         Counter: M55306C09013;
#        ...         Counter rule: max(M55306C09013)>=0 and has_no_0_value(M55306C09013);
#     ${rule3}    Catenate
#		...         Distname: MRBTS-37470/NRBTS-37014/NRCELL-2;
#        ...         Counter: M55306C09015;
#        ...         Counter rule: max(M55306C09015)>=0 and has_no_0_value(M55306C09015);
#    ${rule_list}    Create List    ${rule1}    ${rule2}     ${rule3}
#    Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=0
#
#Start Check vCU Counter For CB008159
#    ${rule1}    Catenate
#		...         Distname: MRBTS-37014/NRBTS-37014/NRCELL-2/MCC-262/MNC-03/ECI-2660903/MCC-262/MNC-03;
#        ...         Counter: M55180C00007;
#        ...         Counter rule: max(M55180C00007)>=1 and has_no_0_value(M55180C00007);
#    ${rule_list}    Create List    ${rule1}
#    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0
#
#Prepare PA for LTE
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[0]}=127     ${attenuation_channels[1]}=127
#    ...                                             ${attenuation_channels[2]}=0     ${attenuation_channels[3]}=0
#    ...                                             ${attenuation_channels[4]}=127    ${attenuation_channels[5]}=127
#    ...                                             ${attenuation_channels[6]}=127     ${attenuation_channels[7]}=127
#    ...                                             ${attenuation_channels[8]}=127    ${attenuation_channels[9]}=127
#        ...                                         ${attenuation_channels[10]}=127    ${attenuation_channels[11]}=127
#    ...                                             ${attenuation_channels[12]}=127    ${attenuation_channels[13]}=127
#    ...                                             ${attenuation_channels[14]}=127    ${attenuation_channels[15]}=127
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Change PA Signal To Add NRCELL2 For NSA
#    Log to console    \nChange PA Attenuation for NRCELL1 And NRCELL2
#    FOR    ${PA_Value}    IN RANGE    50    16    -5
#        ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#        &{channels_to_modify}    create dictionary   ${attenuation_channels[14]}=${PA_Value}
#        ...                                          ${attenuation_channels[15]}=${PA_Value}
#        Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#        sleep    2s
#    END
#
############################### CB008281 ##############################
#Online change Parameter1 five times
#    Log To Console    \nParameter1 Change
#    @{para_list}           Create List    nrEcidMeasSupervisionTimer
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}     Create List    3000
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter1 update result: ${out}
#    Sleep   10s    reason=Wait For Next Set
#    @{para_list}           Create List    nrEcidMeasSupervisionTimer
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}     Create List    6500
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter1 update result: ${out}
#    Sleep   10s    reason=Wait For Next Set
#    @{para_list}           Create List    nrEcidMeasSupervisionTimer
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}     Create List    2900
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter1 update result: ${out}
#    Sleep   10s    reason=Wait For Next Set
#    @{para_list}           Create List    nrEcidMeasSupervisionTimer
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}     Create List    6000
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter1 update result: ${out}
#    Sleep   10s    reason=Wait For Next Set
#    @{para_list}           Create List    nrEcidMeasSupervisionTimer
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}     Create List    3000
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter1 update result: ${out}
#    Sleep   10s    reason=Wait For Next Set
#
#Online change Parameter2 five times
#    Log To Console    \nParameter2 Change
#    Change Parameter2 To True
#    Change Parameter2 To False
#    Sleep    5s
#    Change Parameter2 To True
#    Change Parameter2 To False
#    Sleep    5s
#    Change Parameter2 To True
#    Change Parameter2 To False
#    Sleep    5s
#    Change Parameter2 To True
#    Change Parameter2 To False
#    Sleep    5s
#    Change Parameter2 To True
#    Change Parameter2 To False
#    Sleep    5s
#
#Change Parameter2 To True
#    @{para_list}           Create List    actUlNrEcIdPosMethod
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    @{value_list_true}     Create List    true
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter2 update result: ${out}
#
#Change Parameter2 To False
#    @{para_list}           Create List    actUlNrEcIdPosMethod
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    @{value_list_true}     Create List    false
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter2 update result: ${out}
#
############################### CNI_78446 ##############################
#Prepare PA Signal for NRCELL2
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[12]}=127    ${attenuation_channels[13]}=127
#    ...                                             ${attenuation_channels[2]}=127    ${attenuation_channels[3]}=127
#    ...                                             ${attenuation_channels[14]}=0    ${attenuation_channels[15]}=0
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Online Change Parameters In vDU
#    @{para_list}           Create List    ueConnectionEstablishmentMode
#    @{mo_list_vdu}         Create List    MRBTS-37470/NRBTS-37014/NRCELL-2
#    @{value_list_true}     Create List    useInitialBwp
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vdu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VDU parameter update result: ${out}
#
#Start 3 Counters In VDU For CNI78446
#    ${rule1}    Catenate
#		...         Distname: MRBTS-37470/NRBTS-37014/NRCELL-2;
#        ...         Counter: M55166C00002;
#        ...         Counter rule: max(M55166C00002)>=1;
#    ${rule2}    Catenate
#		...         Distname: MRBTS-37470/NRBTS-37014/NRCELL-2;
#        ...         Counter: M55166C00004;
#        ...         Counter rule: max(M55166C00004)>=1;
#    ${rule3}    Catenate
#		...         Distname: MRBTS-37470/NRBTS-37014/NRCELL-2;
#        ...         Counter: M55139C02502;
#        ...         Counter rule: max(M55139C02502)>=1;
#    ${rule_list}    Create List    ${rule1}    ${rule2}     ${rule3}
#    Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=0
#
############################### CNI_80045 ##############################
#Prepare PA Signal for LTECELL
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[12]}=90    ${attenuation_channels[13]}=90
#    ...                                             ${attenuation_channels[2]}=0    ${attenuation_channels[3]}=0
#    ...                                             ${attenuation_channels[14]}=70   ${attenuation_channels[15]}=70
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Online Change VCU Parameter To Enable Feature
#    @{para_list}           Create List    actAllowedBcListMrdcPrioBcSel
#    @{mo_list_vcu}         Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}     Create List    true
#    ${out}                 Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}
#    Log To Console        VCU parameter update result: ${out}
#
#Change PA Signal To Add NRCELL For NSA
#    Log to console    \nChange PA Attenuation for NRCELL1 And NRCELL2
#    FOR    ${PA_Value}    IN RANGE    50    0    -5
#        ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#        &{channels_to_modify}    create dictionary   ${attenuation_channels[12]}=${PA_Value}
#        ...                                          ${attenuation_channels[13]}=${PA_Value}
#        ...                                          ${attenuation_channels[14]}=${PA_Value}
#        ...                                          ${attenuation_channels[15]}=${PA_Value}
#        Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#        sleep    2s
#    END
#
#Detach M80
#    UE Detach    ${ue_1_type}    ue_index=${1}
#
#Check Wireshark for SGNB ADD ACK
#   [Arguments]    ${wireshark_path}=${wireshark_local_file_path_vCU}
#    &{analysis_dict}       Create Dictionary    filter_conditions=x2ap
#    ${expect_message}=    Set Variable    SgNBAdditionRequestAcknowledge
#    ${result}=    Log Analysis    operation=filter    log_type=wireshark    log_path=${wireshark_path}
#    ...                           analysis_dict=${analysis_dict}
#    Should Contain    ${result}    ${expect_message}
#
########################################## CB013032 ########################################
#Get Managed Object By Adaptation Id
#    [Arguments]    ${managed_objects}    ${adaptation_id}
#    FOR    ${obj}    IN    @{managed_objects}
#        ${obj_adaptation_id}=    Get From Dictionary    ${obj}    adaptationId
#        Run Keyword If    '${obj_adaptation_id}' == '${adaptation_id}'    Return From Keyword    ${obj}
#    END
#    Fail    Managed object with adaptationId ${adaptation_id} not found
#
#Get Parameter Details In vCU
#    [Arguments]    ${para_config_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL37014/parameter_config_vcu.json
#    Login To vCU By Rest    gnb_index=${0}
#    ${all_nidd_info}    cu.get_nidd    raw=True
#    ${managed_objects}=    Get From Dictionary    ${all_nidd_info}    managedObjects
#    ${context}    OperatingSystem.Get File    ${para_config_path}
#    ${parameters_config_list}    json.Loads    ${context}
#    ${parameters_config_list_lenth}    Get Length    ${parameters_config_list}
#    FOR   ${index}    IN RANGE    ${parameters_config_list_lenth}
#        ${adaptationId}=    Get From Dictionary    ${parameters_config_list[${index}]}    adaptationId_name
#        ${obj}=    Get Managed Object By Adaptation Id    ${managed_objects}    ${adaptation_id}
#        ${parameters}=    Get From Dictionary    ${obj}    parameters
#        ${parameter_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    parameter_name
#        ${param}=    Get From Dictionary    ${parameters}    ${parameter_name}
#        ${simple_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    simple_name
#        ${number_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    number_name
#        ${check_list}=    Get From Dictionary    ${parameters_config_list[${index}]}    check_list
#        ${check_list_lenth}    Get Length    ${check_list}
#        FOR   ${i}    IN RANGE    ${check_list_lenth}
#            ${result}=    Get From Dictionary    ${param['${simple_name}']['${number_name}']}    ${check_list[${i}]}
#            Log    result: ${result}
#        END
#    END
#    [Teardown]    Logout To vCU By Rest
#
#Get Parameter Details In vDU
#    [Arguments]    ${para_config_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL37014/parameter_config_vdu.json
#    vDU Login By Rest    vdu_index=0
#    ${all_nidd_info}    vdu.get_nidd    raw=True
#    ${managed_objects}=    Get From Dictionary    ${all_nidd_info}    managedObjects
#    ${context}    OperatingSystem.Get File    ${para_config_path}
#    ${parameters_config_list}    json.Loads    ${context}
#    ${parameters_config_list_lenth}    Get Length    ${parameters_config_list}
#    FOR   ${index}    IN RANGE    ${parameters_config_list_lenth}
#        ${adaptationId}=    Get From Dictionary    ${parameters_config_list[${index}]}    adaptationId_name
#        ${obj}=    Get Managed Object By Adaptation Id    ${managed_objects}    ${adaptation_id}
#        ${parameters}=    Get From Dictionary    ${obj}    parameters
#        ${parameter_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    parameter_name
#        ${param}=    Get From Dictionary    ${parameters}    ${parameter_name}
#        ${simple_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    simple_name
#        ${number_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    number_name
#        ${check_list}=    Get From Dictionary    ${parameters_config_list[${index}]}    check_list
#        ${check_list_lenth}    Get Length    ${check_list}
#        FOR   ${i}    IN RANGE    ${check_list_lenth}
#            ${result}=    Get From Dictionary    ${param['${simple_name}']['${number_name}']}    ${check_list[${i}]}
#            Log    result: ${result}
#        END
#    END
#    [Teardown]    vDU Logout By Rest     vdu_index=0
