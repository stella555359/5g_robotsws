*** Settings ***
Documentation    Suite description
...    Author:        weilong.zhang@nokia-sbell.com
...    Maintainer:    Zhang weilong

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${peak_rate1}    "530":[250,100],"532":[250,100],"534":[300,130],
...             "431":[17,8], "434":[0.17,8],"436":[17,8],"432":[107,15]
${peak_rate2}    "530":[410,170],"531":[150,60],
...             "438":[17,8], "436":[17,8],"434":[29,14],"439":[29,14],"435":[29,14],"437":[29,14],"431":[29,14],
...              "432":[29,14],"433":[17,8]
${peak_rate3}    "530":[510,50],"532":[510,50],"534":[510,50],
...             "431":[17,8], "432":[17,8],"435":[17,8]
&{TMOUS_A}=    HW_ID=CB013395    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate1}}
&{slim_AVHA}=    HW_ID=CB013395    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate2}}

&{TMOUS_3AHLOA_3AHFIB_2AVHA}=    HW_ID=CB013395    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate3}}

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${GLO_PERFORM_SAVE_LOG}    NONE
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    #Diagnostic files collected
${INIT_CONFIG_ID}    TMOUS_A
#${CALL_STRATEGY}    New Feature
${GLO_PERFORM_SAVE_LOG}    FAIL
${REP_COMMENT}      NFTA
${if_reporting_rep}      False
#${ONAIR_TIME}    10min

*** Test Cases ***
[1][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    QC_251672  QCD_MN_RAN    QCP_RAN_VRF
    [Timeout]    72h
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=TMOUS_A
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    Testcase Basic Postcondition
Common_SiSo_Configuration Management_Delta plan Commissioning
    [Tags]    QC_251671  QCD_MN_RAN    QCP_RAN_VRF
    [Timeout]    72h
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=slim_AVHA
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    Testcase Basic Postcondition

Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
    [Tags]    QC_251673  QCD_MN_RAN    QCP_RAN_VRF
    [Timeout]    72h
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=TMOUS_A
    BTS Operation    operation=ru_reset           product_type=gnb    bts_index=0    distname_id=RMOD-ALL
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    BTS Operation    operation=bbmod_reset        product_type=gnb    bts_index=0    distname_id=BBMOD-1 BBMOD-3 BBMOD-4
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Verify HW State
    Check Alarms
    Check Historical Alarms    #additional_allowed_alarms=BTS blocke
    [Teardown]    Testcase Basic Postcondition
Common_SiSo_Recovery_RAT_Reset_Then_Power_Off_Power_On_Secondary_Core_on_Full_Rack
    [Tags]    QC_251674  QCD_MN_RAN    QCP_RAN_VRF
    [Timeout]    72h
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=TMOUS_A
    BTS Operation    operation=rat_reset    product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=True
    BTS Operation    operation=rat_reset    product_type=gnb    bts_index=0    distname_id=LNCEL-ALL    need_verify=True
    Common_SiSo_Recovery_power off then on secondary core
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***

Delta plan Commissioning_disable ssb
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=enb
    ...                               delta_file_path=/home/ute/MN/UTE/robotws/commissionings/HGZ/1_5_UTE5G214/node1/SBTS00/disable_SSB.json
    Log To Console    delta plan update result: ${out}
Delta plan Commissioning_enable ssb
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=enb
    ...                               delta_file_path=/home/ute/MN/UTE/robotws/commissionings/HGZ/1_5_UTE5G214/node1/SBTS00/enable_SSB.json
    Log To Console    delta plan update result: ${out}
Explore case1
       BTS Operation    operation=rat_reset      product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=False
       ...    reset_type=Hard
               sleep    5min
        BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0    distname_id=NRCELL-ALL   need_verify=False
        sleep    5min
        BTS Operation    operation=cell_unlock   product_type=gnb    bts_index=0    distname_id=NRCELL-ALL  need_verify=False
        sleep    5min
        BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0    distname_id=LNCELL-ALL    need_verify=False
        sleep    5min
        BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0    distname_id=LNCELL-ALL  need_verify=False
        Wait For All Cells OnAir
        Verify HW State
        Check Alarms
#        Make L3Call     required_cells=530:531:438:436
Power state verify
    [Arguments]    ${serial_num}
    ${bts_id}    Get Master BTS Id With RF serial Number    ${serial_num}
    ${object_info}    Get R_RRU Object Info With Serialnum    class_name=RMOD_R    serial_num=${serial_num}
    ...     connection=${CASE_NAME}_${bts_id}
    Should Be Equal As Strings    ${object_info["parameters"]["powerState"]}   SLEEP_EXTREME
    [Return]   ${object_info}



Common_SiSo_Recovery_power off then on secondary core
    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FSM']['DH244039926']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FSM']['DH244039926']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FSM']['DH244039926']['pdu']['port']}
    sleep    1 min
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FSM']['DH244039926']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FSM']['DH244039926']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FSM']['DH244039926']['pdu']['port']}
    Run Keyword And Continue On Failure    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    ${alarm1}    Set Variable    BTS secondary core autonomous reset as recovery action:Fault signature for crash or failure
    ${alarm2}    Set Variable    RAT autonomous reset as recovery action:No connection between primary and BTS extension system module
    Check Historical Alarms    additional_allowed_alarms=${alarm1}:${alarm2}

Delta plan Commissioning_remove cell5
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=enb
    ...                               delta_file_path=/home/ute/MN/UTE/robotws/commissionings/HGZ/1_5_UTE5G214/node1/SBTS00/remove_cell5.json
    Log To Console    delta plan update result: ${out}

Delta plan Commissioning_add cell5
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=enb
    ...                               delta_file_path=/home/ute/MN/UTE/robotws/commissionings/HGZ/1_5_UTE5G214/node1/SBTS00/add_cell5.json
    Log To Console    delta plan update result: ${out}

    Check Historical Alarms
    ...    additional_allowed_alarms=BTS secondary core autonomous reset as recovery action:Fault signature for
    ...    crash or failure:RAT autonomous reset as recovery action:No connection between primary and BTS extension system module

