*** Settings ***
Documentation    Suite description
...    Author:        weilong.zhang@nokia-sbell.com
...    Maintainer:    weilong.zhang@nokia-sbell.com

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/affa.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_model.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/variables.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${peak_rate}    "191":[26,14],"252":[70,31],"253":[0.016,0.013],
...             "192":[26,14],"212":[70,34],"263":[0.016,0.013],
...             "193":[26,14],"242":[70,34],"283":[0.016,0.013]
${peak_rate1}    "112":[135,60],"111":[135,60],
...             "211":[135,60],"212":[70,34]
#${peak_rate1}   "251":[35,14],"281":[35,14],"252":[54,14],"212":[54,14],"253":[0.016,0.013],"263":[0.016,0.013]
&{CLOUD_5G_CLASSICAL_SA_ASOE_AHCI_CB011110}=    HW_ID=CB011110    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate}}
&{AHEK_5cc}=    HW_ID=CTC    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate1}}
&{CLOUD_5G_AHCI_CTC}=    HW_ID=CTC    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate}}
#&{CLOUD_5G_AHCI_CNI113777_2NB}=    HW_ID=CNI113777    site_mode=5G_4G     ONAIR_TIME=15 min
#...									peak_rate_config={${peak_rate}}
#&{CLOUD_5G_AHCI_CNI113777_1NB_256QAM}=    HW_ID=CNI113777    site_mode=5G_4G     ONAIR_TIME=15 min
#...									peak_rate_config={${peak_rate}}
#&{CLOUD_5G_AHCI_CNI124006_DSS_NR10M_LTE10M_NB}=    HW_ID=CNI124006    site_mode=5G_4G     ONAIR_TIME=15 min
#...									peak_rate_config={${peak_rate1}}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${GLO_PERFORM_SAVE_LOG}    FAIL
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset    RRU power loss     EN DSS De-activated on partner side
${INIT_CONFIG_ID}    CLOUD_5G_CLASSICAL_SA_ASOE_AHCI_CB011110
${parameters}    [{"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-2/LNCEL_FDD-0","para_name":"Activation reduced frequency offset","para_value":"false",
...    "require_reset":"online"},{"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-5/LNCEL_FDD-0",
...    "para_name":"Activation reduced frequency offset","para_value":"false","require_reset":"online"},
...    {"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-3/NBIOT_FDD-0","para_name":"NB-IoT standalone EARFCN Downlink",
...    "para_value":"2401","require_reset":"online"},{"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-3/NBIOT_FDD-0",
...    "para_name":"NB-IoT standalone EARFCN Uplink","para_value":"20401",
...    "require_reset":"online"},{"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-4/NBIOT_FDD-0",
...    "para_name":"NB-IoT standalone EARFCN Downlink","para_value":"8787",
...    "require_reset":"online"},{"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-4/NBIOT_FDD-0",
...    "para_name":"NB-IoT standalone EARFCN Uplink","para_value":"26787",
...    "require_reset":"online"},{"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-6/NBIOT_FDD-0",
...    "para_name":"NB-IoT standalone EARFCN Downlink","para_value":"2401",
...    "require_reset":"online"},{"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-6/NBIOT_FDD-0",
...    "para_name":"NB-IoT standalone EARFCN Uplink","para_value":"20401",
...    "require_reset":"online"},{"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-7/NBIOT_FDD-0",
...    "para_name":"NB-IoT standalone EARFCN Downlink","para_value":"8787",
...    "require_reset":"online"},{"dist_name":"MRBTS-11620/LNBTS-11620/LNCEL-7/NBIOT_FDD-0",
...    "para_name":"NB-IoT standalone EARFCN Uplink","para_value":"26787","require_reset":"online"},]
#${band_class}    5
${total_rf_power_high_threshold}    60
${total_rf_power_low_threshold}    1
#${if_reporting_rep}      True
*** Test Cases ***
#[1][1.1] CB011110_General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    QC_33175    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Recommissioning     config_id=CLOUD_5G_AHCI_CTC
#    Delta plan Commissioning_enable iqc
#    Wait For All Cells OnAir
#    Verify HW State
#    Check Alarms
#    Delta plan Commissioning_disbale iqc
#    Wait For All Cells OnAir
#    Verify HW State
#    Check Alarms
#    [Teardown]    Testcase Basic Postcondition

[1] CB011110_Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_33174    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=AHEK_5cc
    test_fv.Data Transfer    required_cells=211:111
    [Teardown]    Testcase Basic Postcondition

#[5][1.0] Explore case
#    [Tags]    QC_33176    QCD_MN_RAN   QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Tput
#    Explore case1
#    [Teardown]    Testcase Basic Postcondition

#[1.0] Manual_SiSo_SM_LTE_RAT_reset_for_concurrent
#   [Tags]    QC_33180    QCD_MN_RAN    QCP_RAN_VRF
#   [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm      config_id=CLOUD_5G_AHCI_CTC
#   LTE_RAT_reset_for_concurrent    required_cells=252
#   [Teardown]    Testcase Basic Postcondition

[2] Manual_SiSo_SM_NR_RAT_reset_for_concurrent
    [Tags]    QC_33181    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm      config_id=CLOUD_5G_AHCI_CTC
    NR_RAT_reset_for_concurrent_CNI124006     required_cells=191
    [Teardown]    Testcase Basic Postcondition

[3] Ru Lock And Unlock then Cell block and unblock
    [Tags]    QC_33178    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RuLockunlock_Celllockunlock      config_id=AHEK_5cc
    Ru lock And Unlock All     required_cells=111
    [Teardown]    Testcase Basic Postcondition

[4] Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_33177 	QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lockunlock_And_Cell_lockunlock      config_id=AHEK_5cc
    Cell Block And Unblock All with rfreset     required_cells=211
    [Teardown]    Testcase Basic Postcondition

#[1][1.0] Common_SiSo_Testabililty_BS-RF__LTE_RTWP online monitoring
#    [Tags]    QC_33179    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=rfDiagnosticTest      config_id=CLOUD_5G_AHCI_CTC
#    RF Diagnostic Test
##    Change Testline Configuration    config_id=CLOUD_5G_AHCI_CTC
##    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
#    [Teardown]    Testcase Basic Postcondition


*** Keywords ***
RF Diagnostic Test
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
        Run Keyword And Continue On Failure    Admin Alarms Get And Check    allowed=${GLO_ADMIN_ALLOWED_ALARM}
        ...    alias=${connection_id}
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${lcrid}    Set Variable    ${cell_info["lcrId"]}
        ${cellType}   Set Variable If  "${cell_info["NetworkType"]}"=="SA"  NR
        ...    "${cell_info["NetworkType"]}"=="NSA"  NR
        ...    "${cell_info["NetworkType"]}"=="4G"  LTE
        ${cell_tech}     Set Variable    ${cell_info['cellTechnology']}
        ${band_class}    Set Variable    ${cell_info["band"]}
        Run Keyword If    "${cellType}"=="LTE"   coam.Start RF Diagnostic Test    True    ${lcrid}    ${cellType}
        ...    8    -8    3    -110    -30    band_class=${band_class}    total_rf_power_high_threshold=${total_rf_power_high_threshold}
        ...    total_rf_power_low_threshold=${total_rf_power_low_threshold}    alias=rfDiagnosticTest_${bts_id}
        ...    ELSE IF    "${cellType}"=="NR"    Run RF Diagnostic Test    ${lcrid}    ${cellType}    alias=rfDiagnosticTest_${bts_id}
        Run Keyword If    "${cellType}"=="NR"    Get And Check RF Diagnostic Test Result 5G    alias=rfDiagnosticTest_${bts_id}
        ...    ELSE IF    "${cellType}"=="LTE" and "${cell_tech}"=="FDD"    Get And Check RF Diagnostic Test Result 4G
        ...    alias=rfDiagnosticTest_${bts_id}
    END
    Verify All Cells OnAir
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

NR_RAT_reset_for_concurrent_CNI124006
    [Arguments]    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Get NR and LTE Cell List
    ${Due_mode_rru_list}    Create List
    ${Due_mode_rru_list}    Get Due Mode RRU List    ${NR_CELL_LIST}     ${LTE_CELL_LIST}
    FOR    ${fr_sn}    IN    @{Due_mode_rru_list}
        Remove Invalid Cell    ${fr_sn}
    END
    FOR    ${bts_id}    IN    @{BTS_LIST}
        coam.rat_reset    rat_type=NR    timeout=260    connection=${CASE_NAME}_${bts_id}
        Wait Until Keyword Succeeds    600sec    10sec    Verify All Cells OnAir
        Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    END
    sleep    180
    Verify All Cells OnAir
Explore case1
       BTS Operation    operation=rat_reset      product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=False
       ...    reset_type=Hard
               sleep    5min
        BTS Operation    operation=cell_lock              product_type=gnb    bts_index=0    distname_id=NRCELL-ALL           need_verify=False
        sleep    5min
        BTS Operation    operation=cell_unlock              product_type=gnb    bts_index=0    distname_id=NRCELL-ALL         need_verify=False
        sleep    5min
        BTS Operation    operation=cell_lock              product_type=gnb    bts_index=0    distname_id=LNCELL-ALL           need_verify=False
        sleep    5min
        BTS Operation    operation=cell_unlock              product_type=gnb    bts_index=0    distname_id=LNCELL-ALL          need_verify=False
        Wait For All Cells OnAir
        Verify HW State
        Check Alarms
        Make L3Call     required_cells=252:242:212
Delta plan Commissioning_enable iqc
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=enb
    ...                               delta_file_path=/home/ute/MN/UTE/robotws/commissionings/HGZ/1_5_UTE4G172/node1/SBTS00/enableIQC.json
    Log To Console    delta plan update result: ${out}
Delta plan Commissioning_disbale iqc
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=enb
    ...                               delta_file_path=/home/ute/MN/UTE/robotws/commissionings/HGZ/1_5_UTE4G172/node1/SBTS00/disableIQC.json
    Log To Console    delta plan update result: ${out}
