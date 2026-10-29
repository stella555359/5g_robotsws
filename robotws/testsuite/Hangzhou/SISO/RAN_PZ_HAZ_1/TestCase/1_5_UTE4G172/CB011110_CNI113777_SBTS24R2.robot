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
${GLO_PERFORM_SAVE_LOG}    FAIL
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
#[1][1.0] CB011110_Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_775231    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_CLASSICAL_SA_ASOE_AHCI_CB011110
   # test_fv.Data Transfer    required_cells=252
    #[Teardown]    Testcase Basic Postcondition

#[1][1.0] CB011110_Common_SiSo_Recovery_RF_Module_Reset
 #   [Tags]    QC_775228    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=RF_Reset      config_id=CLOUD_5G_AHCI_CNI113777_2NB
   # SISO_Recovery RF module reset       required_cells=212
    #[Teardown]    Testcase Basic Postcondition

#[1][1.0] CB011110_Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_775231    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_CLASSICAL_SA_ASOE_AHCI_CB011110
   # test_fv.Data Transfer    required_cells=253
    #[Teardown]    Testcase Basic Postcondition

[1][1.0] CB011110_Common_SiSo_State Management_Cell_Block_Unblock
    [Tags]    QC_832261    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block      config_id=CLOUD_5G_AHCI_CNI113777_1NB_256QAM
    Cell Block And Unblock All      required_cells=253
    [Teardown]    Testcase Basic Postcondition

#[2][1.0] CB011110_Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_775231    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_CLASSICAL_SA_ASOE_AHCI_CB011110
   # test_fv.Data Transfer    required_cells=263
    #[Teardown]    Testcase Basic Postcondition

#[1][1.1] CB011110_General_SiSo_Commissioning_BTS_Template_Commissioning
 #   [Tags]    QC_775230    QCD_MN_RAN    QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Recommissioning      config_id=CLOUD_5G_AHCI_CNI113777_1NB
   # General_SiSo_Commissioning_BTS_Template_Commissioning
    #[Teardown]    Testcase Basic Postcondition

#[3][1.0] CB011110_Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_775231    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_CLASSICAL_SA_ASOE_AHCI_CB011110
   # test_fv.Data Transfer    required_cells=251
    #[Teardown]    Testcase Basic Postcondition

[4][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_832260    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_AHCI_CNI113777_1NB
    test_fv.Data Transfer    required_cells=263
    [Teardown]    Testcase Basic Postcondition

#[5][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_775232    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_AHCI_CNI113777_1NB
   # test_fv.Data Transfer    required_cells=252
    #[Teardown]    Testcase Basic Postcondition

#[5][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_775232    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_AHCI_CNI113777_1NB
   # test_fv.Data Transfer    required_cells=253
    #[Teardown]    Testcase Basic Postcondition

#[6][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_775232    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=CLOUD_5G_AHCI_CNI113777_1NB
   ## test_fv.Data Transfer    required_cells=212
    #[Teardown]    Testcase Basic Postcondition
