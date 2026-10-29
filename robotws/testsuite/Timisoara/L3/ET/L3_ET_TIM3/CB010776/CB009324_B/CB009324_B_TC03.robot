*** Settings ***
Force Tags    CCLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD    PY36    CONFIGURED    RAN_5G_FDD    CRT    RAN_5G    SBTS00
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: George Medesan
...              :contact: george.medesan@nokia.com

Resource     ../CB009324_keywords.robot
Library      ute_reporting_portal

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND             Get Scfc File    output_filepath=/home/ute/initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=Delta_Configuration_scf_CB009324_FDD_final.json
...            AND             With Swconfig Flags                       flags=@{FLAGS_LIST}
...            AND             Trigger Site Reset
...            AND             sleep  300
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/egate_2c_fdd_sansa.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND             Set udp buffer size


Test Setup       Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Processes And Gather Logs And Compress Logs

Suite Teardown    Send Full Commissioning    input_filepath=/home/ute/initial_commissioning.xml

*** Variables ***

${rdTestPurposeBurstSizeDivider}=  0x5A00AF=64
@{FLAGS_LIST}=  ${rdTestPurposeBurstSizeDivider}

*** Test Cases ***

TC03_Traffic_Shaping_for_DL_Forwarded_Data_over_X2-U_for_Single_UE_FDD
    [Documentation]    This test case verifies that counters related to packets drop are not inceremented:
    ...                PDCP PDU packet lost on X2-U interface: NUM_DL_PDU_LOST_X2_QoS_GRP
    ...                Transport First Level Scheduler (FSTSCH): M51351C
    ...                5G_RAN_USR_RRM_19651
    Wait For Next Full Pm Interval
    Perform NSA call    ue_id=11   target_cell=1   target_gnb=2
    sleep  10

    Dual Connectivity Release    ue_id=11   bearer=2   by=enb   cause=off

    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55323C01009    >0    DL_VOL_SNT_F1_QoS_GRP_09
        ...    M55313C08009    >0    DL_PDCP_VOL_SNT_X2_QOS_GRP_09
#        ...    M55313C04009    0     NUM_DL_PDU_LOST_X2_QOS_GRP_09
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${pm_counter_file}
    
    ${pm_M55323C01009}=    Get Pm Counter Value As Integer    M55323C01009    ${pm_counter_file}
    ${pm_M55313C08009}=    Get Pm Counter Value As Integer    M55313C08009    ${pm_counter_file}
    
    Verify Any Counters In File
        ...    M51351C3    0    ifTxDropPackets_rate_EF1
        ...    M51351C9    0    ifTxDropPackets_rate_EF2
        ...    M51351C15    0    ifTxDropPackets_rate_EF3
        ...    M51351C21    0    ifTxDropPackets_rate_AF1
        ...    M51351C27    0    ifTxDropPackets_rate_AF2
        ...    M51351C33    0    ifTxDropPackets_rate_AF3
        ...    M51351C39    0    ifTxDropPackets_rate_AF4
        ...    M51351C45    0    ifTxDropPackets_rate_BE
        ...    local_moid=PLMN-PLMN/MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/QOS-1/FSTSCH-1
        ...    file_path=${pm_counter_file}
    Perform Detach UEs    ue_id=11

    Report pm counter    id=M55323C01009    value=${pm_M55323C01009}    result=Passed
    Report pm counter    id=M55313C08009    value=${pm_M55313C08009}    result=Passed

    Report pm counter    id=M51351C3    value=0    result=Passed
    Report pm counter    id=M51351C9    value=0    result=Passed
    Report pm counter    id=M51351C15    value=0    result=Passed
    Report pm counter    id=M51351C21    value=0    result=Passed
    Report pm counter    id=M51351C27    value=0    result=Passed
    Report pm counter    id=M51351C33    value=0    result=Passed
    Report pm counter    id=M51351C39    value=0    result=Passed
    Report pm counter    id=M51351C45    value=0    result=Passed
