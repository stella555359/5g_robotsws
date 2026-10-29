*** Settings ***

Force Tags    CLOUD_5G_I_MP_AP_LO
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: George Medesan
...              :contact: george.medesan@nokia.com

Resource     CB010938_C_Keywords_And_Variables.robot

Suite Setup      Run Keywords    Get Scfc File    output_filepath=/home/ute/initial_commissioning.xml
...              AND             Setup Custom IPHY   iphy=${custom-iphy-TC02}
...              AND             Setup Custom SCF    scf=${custom-scf-TC02}
...              AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...              AND             Reach OnAir    lua_cfg=${CURDIR}/config/basic_setup_TC02.cfg   check_edaemon_port=True
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup       Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown   Send Full Commissioning    input_filepath=/home/ute/initial_commissioning.xml

*** Test Cases ***
TC02_CB010938_C_B1_Successful_exchange_of_Chipset_and_RAN_identification_info_from_supporting_UEs_during_UE_Capability_retrieval_ERR_ROBUSTNESS
    [Documentation]
    ...    This user scenario describes the gNB UE Radio Capability retrieval procedure to successfully exchange Chipset
    ...    and RAN Identification information between UE and Network for supporting UEs. The UE indicates extended chipset
    ...    version in first dummy4 and didn't include second dummy4 structure at all, gNB-CU-CP considers UE is sending
    ...    invalid data and continue without any failure.

    Wait For Next Full Pm Interval
    Perform SA call      ue_id=1
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C00027   +1    UE_CHIPSET_VENDOR_RECV_ERR
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    Verify Tcpdump Log    packet_filter=${ueCapabilityEnquiryFilter}
    Verify Tcpdump Log    packet_filter=${ueCapabilityInformationFilter}
