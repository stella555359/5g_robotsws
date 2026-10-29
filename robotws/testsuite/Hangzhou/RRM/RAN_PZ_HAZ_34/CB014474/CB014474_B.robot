*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB014474_B

Resource         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014474/Resources/CB014474_case_step.robot



Suite Setup         BuiltIn.Run Keywords     CB014474_suite_setup
...                 AND                      CB014474 Common Case TestLine Setup with gnb1 and gnb2

Suite Teardown      CB014474_suite_teardown



*** Variables ***
${BB1002_attach_vonr_wireshark_disable}      BB1002_attach_vonr_wireshark_disable.pcap
${BB1002_attach_vonr_wireshark_enable}       BB1002_attach_vonr_wireshark_enable.pcap
${BB1002_TTI_disable}                        BB1002_TTIlog_14474_disable
${BB1002_TTI_enable}                         BB1002_TTIlog_14474_enable

*** Test Cases ***
[1]CB014474_B#B1_002_VoNR_call_quality_MOS_target_based_on_VoNR_Robustness_Algorithm_with_PRBusage_optimization_FDD_20M
    [Documentation]
    ...    FCA_VRF_RRM-30596;12700632;COVER B#B001,B002,B003
    [Tags]    BB1002
    [Setup]
    CB014474_case_setup    online_ModifySCF_GNB1=True
    ...                    Modify_Para_Online_GNB1=${Online_Modify_BB1002}
    ${nr_phy_cell_gnb1cell2}    get physicalCellId from coam_gnb_classical    lcrid=${2}    gnb_index=${0}
    Adjust Attenuation value for GNB1_CELL2    gnb1_cell2_value=${0}
    power_ue.Prepare UE    ue_type=${ue_type_samsung}    ui_version=S20UI2.5    ue_index=${12}
    ${BB1002_wiresharklog_01}    samsung UE attach and make a VONR call    tcpdump_collector_name=${BB1002_attach_vonr_wireshark_disable}
    Andriod UE adb disable data services    ue_index=${12}
    Start Ttitrace With Admin Mode    names=${BB1002_TTI_disable}    nr_phy_cell_ids=${nr_phy_cell_gnb1cell2}    gNB_index=${0}
    Set the attenuation value step by step for GNB1_CELL2
    sleep    2s
    Stop TTI and detach UE    tti_names=${BB1002_TTI_disable}
    Convert Ttitrace From Pcap To Excelcsv    names=${BB1002_TTI_disable}    target_dir=${epc_log_path}
    Common Case TestLine Setup        ModifySCF_Aftercommission=True
    ...                               Modify_Para_Online=${Online_Modify_enable_14474}
    Adjust Attenuation value for GNB1_CELL2    gnb1_cell2_value=${0}
    ${BB1002_wiresharklog_02}    samsung UE attach and make a VONR call    tcpdump_collector_name=${BB1002_attach_vonr_wireshark_enable}
    Andriod UE adb disable data services    ue_index=${12}
    Start Ttitrace With Admin Mode    names=${BB1002_TTI_enable}    nr_phy_cell_ids=${nr_phy_cell_gnb1cell2}    gNB_index=${0}
    Set the attenuation value step by step for GNB1_CELL2
    sleep    2s
    Stop TTI and detach UE    tti_names=${BB1002_TTI_enable}
    Convert Ttitrace From Pcap To Excelcsv    names=${BB1002_TTI_enable}      target_dir=${epc_log_path}
    BB1002_TTI_analyze
    [Teardown]    CB014474_case_teardown


