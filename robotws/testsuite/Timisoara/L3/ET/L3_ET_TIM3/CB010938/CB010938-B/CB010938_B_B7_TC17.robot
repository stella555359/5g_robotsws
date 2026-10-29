*** Settings ***

Force Tags    CLOUD_5G_I_LO_AP_LO
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Alexandru Goman, Denisa Gogu
...              :contact: alexandru.goman@nokia.com, denisa.gogu@nokia.com

Resource     CB010938_B_Keywords_And_Variables.robot

Suite Setup      Run Keywords    Get Scfc File    output_filepath=/home/ute/initial_commissioning.xml
...            AND             Log to console    Start Vm Ethernet Interfaces
...            AND             Run    ${VM_ETH_IFACES}
...              AND             Setup Custom SCF    scf=${custom-scf-TC17}
...              AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...              AND             Reach OnAir    lua_cfg=${CURDIR}/config/basic_setup_TC17.lua   check_edaemon_port=True
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup       Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown   Send Full Commissioning    input_filepath=/home/ute/initial_commissioning.xml

*** Test Cases ***
TC17_CB010938_B_B7_UE_inter_vendor_inter_gNB_Xn_handover_Chipset_and_RAN_info_exchange_feature_functionality_is_enabled_in_both_source_and_target
    [Documentation]
    ...    This user scenario describes the target Nokia gNB behavior during Xn handover (Intra frequency) from
    ...    source non-Nokia gNB for UE with mac-ParametersCommon/dummy param set to supported

    Perform SA call without traffic      ue_id=1
    Send A5 MR to trigger interGNB intraFreqHo with blind Scell Addition      ue_id=1      target_pci=52      meas_id=1
    Execute Egate Command    cmd=ue_capability_enquiry id=1 band_eutra=200,201,202
    ...    ca_bandwidth_class_dl_eutra=5,0,0 ca_bandwidth_class_ul_eutra=5,5,5
    Send A5 MR to trigger interGNB intraFreqHo with blind Scell Addition      ue_id=1      target_pci=50      meas_id=2
    Verify Tcpdump Log    packet_filter=${infra_info_TC17}
    Verify Tcpdump Log    packet_filter=${chipset_info_TC17}
