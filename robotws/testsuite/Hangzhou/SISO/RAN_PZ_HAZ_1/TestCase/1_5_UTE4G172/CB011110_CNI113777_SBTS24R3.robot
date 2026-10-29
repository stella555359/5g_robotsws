*** Settings ***
Documentation    Suite description
...    Author:        sue.nie@nokia-sbell.com
...    Maintainer:    Nie Sue

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/affa.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_model.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/variables.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${peak_rate}    "251":[19,4],"252":[70,34],"253":[0.016,0.013],"273":[0.016,0.013],"281":[19,4],"212":[70,34],"263":[0.016,0.013],"274":[0.016,0.013]
&{CLOUD_5G_CLASSICAL_SA_ASOE_AHCI_CB011110}=    HW_ID=CB011110    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate}}
&{CLOUD_5G_AHCI_CNI113777_1NB}=    HW_ID=CNI113777    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate}}
&{CLOUD_5G_AHCI_CNI113777_2NB}=    HW_ID=CNI113777    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate}}
&{CLOUD_5G_AHCI_CNI113777_1NB_256QAM}=    HW_ID=CNI113777    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate}}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${GLO_PERFORM_SAVE_LOG}    NONE
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset    RRU power loss
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

*** Test Cases ***
#[1.0] Manual_SiSo_SM_NR_RAT_reset_for_concurrent
 #   [Tags]    QC_847834    QCD_MN_RAN    QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=CLOUD_5G_AHCI_CNI113777_2NB
   # NR_RAT_reset_for_concurrent    required_cells=253
    #[Teardown]    Testcase Basic Postcondition

#[1.0] Manual_SiSo_SM_LTE_RAT_reset_for_concurrent
 #  [Tags]    QC_847835    QCD_MN_RAN    QCP_RAN_ST
  # [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=CLOUD_5G_AHCI_CNI113777_1NB
   #LTE_RAT_reset_for_concurrent    required_cells=253
   #LTE_RAT_reset_for_concurrent    required_cells=212
   #[Teardown]    Testcase Basic Postcondition

#[4][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_847836    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_AHCI_CNI113777_1NB_256QAM
   # test_fv.Data Transfer    required_cells=251:263
    #[Teardown]    Testcase Basic Postcondition

#[1][1.1] CB011110_General_SiSo_Commissioning_BTS_Template_Commissioning
 #   [Tags]    QC_847837    QCD_MN_RAN    QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Recommissioning      config_id=CLOUD_5G_AHCI_CNI113777_1NB
   # General_SiSo_Commissioning_BTS_Template_Commissioning
    #[Teardown]    Testcase Basic Postcondition

#[1][1.0] Common_SiSo_Testabililty_BS-RF__LTE_RTWP online monitoring
 #   [Tags]    QC_847838    QCD_MN_RAN    QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=rfDiagnosticTest    config_id=CLOUD_5G_AHCI_CNI113777_1NB
   # RF Diagnostic Test
   # Change Testline Configuration    config_id=CLOUD_5G_AHCI_CNI113777_2NB
   # Wait For All Cells OnAir        timeout=${ONAIR_TIME}
   # [Teardown]    Testcase Basic Postcondition

#RF Lock and unlock Then Cell block and unblock
 #   [Tags]    QC_848839 	QCD_MN_RAN    QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Ru_Lockunlock_And_Cell_lockunlock    config_id=CLOUD_5G_AHCI_CNI113777_1NB_256QAM
   # Ru lock And Unlock All    required_cells=251
    #Cell Block And Unblock All    required_cells=263
    #[Teardown]    Testcase Basic Postcondition

Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_847840 	QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=cell_block_RF_reset_Cell_unblock    config_id=CLOUD_5G_CLASSICAL_SA_ASOE_AHCI_CB011110
    Cell Block And Unblock All with rfreset	required_cells=252
    [Teardown]    Testcase Basic Postcondition

#[4][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_847841    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_AHCI_CNI113777_1NB
   # test_fv.Data Transfer    required_cells=251:263
    #[Teardown]    Testcase Basic Postcondition

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
        ${m_band}    Set Variable    ${cell_info["band"]}
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

