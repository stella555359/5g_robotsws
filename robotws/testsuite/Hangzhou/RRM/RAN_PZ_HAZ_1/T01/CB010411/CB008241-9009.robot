*** Settings ***
Documentation
...   Author: xiaowei.1.chen@nokia-sbell.com
...   Contact: xiaowei.1.chen@nokia-sbell.com
...   Description: The basic AIC&CLASSICAL ANR case

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC

Force Tags
...                CRT
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22

Test Timeout    60 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot

Library           taf.sbts.oam.coam.admin                                WITH NAME    soam


*** Variables ***
${local_path_of_scf_file}    ${tl.gnbs[0].dus[0].cloud_deployment.default_cfg_dir}/DEP_SCF_FILES/CU_0/
${serials}     RFCX10MEQBF
*** Test Cases ***
[1][1.0] CB010411_CB008239_A_inter_RAT_ANR_New_inter_RAT_Neighbour_object_addition_to_Network_Plan_File
    [Tags]    QC_32359       QCD_MN_RAN      QCP_RAN_VRF
    SOAM_Admin.Login
    SOAM_Admin.set parameter value    MRBTS-4813/LNBTS-4813/LNCEL-1/SIB-0    cellBarred    notBarred
    Run Keyword And Ignore Error    SOAM_Admin.Logout
    wait until keyword succeeds    600    10    BTS Operation for AIC   verify   vdu   NRCELL-ALL
    Parameter Operation for AIC    maxNumAnrNrrelePerCell    0
    Adjust The Signal Via PA    10760_cell1=0
    Attach UE
    Start Collect Mutli Counters For CB008239_A01
    Adjust The Signal Via PA    10760_cell1=20    4813_lte=35
    Stop Collect Mutli Counter On vCU
    Detach UE
    Parameter Operation for AIC    maxNumAnrNrrelePerCell    1
    Adjust The Signal Via PA    10760_cell1=0
    Attach UE
    Start Collect Counter    M55147C01501    1
    Adjust The Signal Via PA    10760_cell1=20    4813_lte=35
    Stop Collect Mutli Counter On vCU
    Detach UE
[1][1.0] CB010411_CB008239_A_inter_RAT_ANR_PCI_Resolution_and_inter_RAT_neighbour_relation_addition
    [Tags]    QC_32360        QCD_MN_RAN      QCP_RAN_VRF
    Adjust The Signal Via PA
[1][1.0] CB010411_CB008239_B_inter_RAT_ANR_Neighbour_relation_removal_due_to_consecutive_RE_CHECK_state_reporting
    [Tags]    QC_32361       QCD_MN_RAN      QCP_RAN_VRF
    SOAM_Admin.Login
    SOAM_Admin.set parameter value    MRBTS-4813/LNBTS-4813/LNCEL-1/SIB-0    cellBarred    barred
    Run Keyword And Ignore Error    SOAM_Admin.Logout
    sleep    30s
    Adjust The Signal Via PA    10760_cell1=0
    Attach UE
    Adjust The Signal Via PA    10760_cell1=20    4813_lte=35
    Wait Until Keyword Succeeds    10min    20s     CHECK NRRELE-256 NOT Exist
    Parameter Check for AIC
    Detach UE
    SOAM_Admin.Login
    SOAM_Admin.set parameter value    MRBTS-4813/LNBTS-4813/LNCEL-1/SIB-0    cellBarred    notBarred
    Adjust The Signal Via PA
    sleep    10s
[1][1.0] CB011169_CB012118_Successful Voice and Emergency Fallback via B1 Measurement redirection
    [Tags]    QC_32469       QCD_MN_RAN      QCP_RAN_VRF
    Adjust The Signal Via PA    10760_cell1=0
    Attach UE
    Start Collect Mutli Counters For VOICE
    Adjust The Signal Via PA    10760_cell1=0    4813_lte2=40
    Log To Console    Start voice call 006688
    Start voice call    006688
    Stop voice call
    Detach UE
    Stop Collect Mutli Counter On vCU
    Adjust The Signal Via PA
    Detach UE
*** Keywords ***
############################## CB008241 ##############################
BTS Operation for AIC
    [Arguments]     ${operation}    ${product_type}   ${distname_id}
    BTS Operation      operation=${operation}
    ...                product_type=${product_type}
    ...                bts_index=0
    ...                distname_id=${distname_id}
    ...                need_verify=yes
    ...                verify_status=CELL_ONAIR

Parameter Operation for AIC
    [Arguments]     ${para}     ${para_value}
    @{para_list}          Create List    ${para}
    @{value_list}         Create List    ${para_value}
    @{mo_list}            Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRANRPRE-1
    ${res}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=${para_list}    value_list=${value_list}    mo_list=${mo_list}
    Log To Console        VCU paramter update result: ${res}

Parameter Check for AIC
    @{para_list}      Create List    nrAdjECellId
    @{mo_list_vcu}    Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJECELL-5000
    ${out}            Parameter Operation    operation=parameter_value_check   product_type=vcu
    ...                                      para_list=@{para_list}    mo_list=@{mo_list_vcu}
    ${nrAdjECellId}    Set Variable    ${out['MRBTS-10760/NRBTS-10760/NRADJECELL-5000']['nrAdjECellId']}
    Run Keyword If    "${nrAdjECellId}"=="${None}"    FAIL    "VCU Parameter Check Result "${nrAdjECellId}""
    ...               ELSE    Log To Console    VCU Parameter Check Result: ${out}

Start Collect Counter
    [Arguments]     ${counter}     ${counter_value}
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname:MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: ${counter};
    ...         Counter rule:avg(${counter})==${counter_value};
    append to list  ${rule_list}    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

Stop Collect Mutli Counter On vCU
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0

Start Collect Mutli Counters For CB008239_A01
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C07001;
    ...         Counter rule:avg(M55124C07001)>=1;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C07002;
    ...         Counter rule:avg(M55124C07002)>=1;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55147C01502;
    ...         Counter rule:avg(M55147C01502)==1;
    append to list  ${rule_list}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Collect Mutli Counters For VOICE
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C01032;
    ...         Counter rule:avg(M55124C01032)==1;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C01033;
    ...         Counter rule:avg(M55124C01033)==1;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C02501;
    ...         Counter rule:avg(M55124C02501)==1;
    append to list  ${rule_list}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Collect Mutli Counters For EM VOICE
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C01032;
    ...         Counter rule:avg(M55124C01032)==1;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C01034;
    ...         Counter rule:avg(M55124C01034)==1;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C03501;
    ...         Counter rule:avg(M55124C03501)==1;
    append to list  ${rule_list}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
SOAM_Admin.Login
    [Arguments]    ${bts_host}=10.97.83.130    ${username}=Nemuadmin    ${password}=nemuuser
    ...            ${bts_port}=${443}    ${log_dir}=${TEST_LOG_DIRECTORY}    ${alias}=SOAM
    soam.connect_to
    ...    bts_host=${bts_host}
    ...    bts_port=${bts_port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    admin_api_log_dir=${log_dir}
    ...    name=${alias}

SOAM_Admin.Logout
    [Arguments]    ${connection}=SOAM
    soam.teardown    connection=${connection}

SOAM_Admin.set parameter value
    [Arguments]    ${dist_name}    ${parameter}    ${new_value}    ${operation}=update
    ...            ${sleep_time}=${30}    ${timeout}=${800}    ${connection}=SOAM
    ...            ${skip_parameter_relation_errors}=true    ${should_activate}=${true}
    soam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...                                       operation=${operation}    value=${new_value}
    ...                                       skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                       should_activate=${should_activate}    timeout=${timeout}
    ...                                       connection=${connection}
    Sleep    ${sleep_time}

CHECK NRRELE-256 NOT Exist
    Login To vCU By Rest
    ${mo_dn}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1/NRRELE-256
    ${para_result}   Run Keyword And Ignore Error    vCU Online Get All Parameters Of Distname    dist_name=${mo_dn}
    ${expect_mo}    Set Variable   FAIL
    should be equal    ${para_result}[0]   ${expect_mo}

Prepare UE0
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Test Variable    ${ue0_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue0_type}    ue_index=${0}     ui_version=MATE40PROUI2.0

Attach UE
    Commercial UE Operation    attach    serialno=${serials}   forced=${True}
    sleep   2s
Detach UE
    Commercial UE Operation    detach    serialno=${serials}
    sleep   5s
Start voice call
    [Arguments]     ${number}
    Commercial UE Operation    start call    serialno=${serials}  dial_number=${number}
    sleep    10s
Stop voice call
    Commercial UE Operation    stop call    serialno=${serials}
Adjust The Signal Via PA
    [Arguments]    ${10760_cell1}=120    ${10760_cell2}=120    ${4813_lte}=120    ${4813_NR}=120     ${4813_lte2}=120
    Log to console    Adjust The Signal Via PA
    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0   vendor=TOPYOUNG   du_id=0   max_attenuation=120
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=${10760_cell1}
    ...    ${attenuation_channels[1]}=${4813_NR}
    ...    ${attenuation_channels[2]}=${4813_lte2}
    ...    ${attenuation_channels[3]}=${10760_cell2}
    ...    ${attenuation_channels[4]}=${4813_lte}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    10s    reason=wait signal stable
    Log to console    attenuation change complete
    Log to console    attenuation change complete

Start Collect Wireshark Log In vCU
    Log to Console    \n***Start Wireshark Log In vCU***
    sleep     5s
    Start Wireshark Log In vCU   gnb_index=${0}
    ...                          container_name=nwmgmt
    ...                          pod_name=cpif
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    vDU Logout By Rest
    Run Keyword And Ignore Error    Detach UE0
    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
    ...                                                             conn=${conn}    timeout=${timeout}