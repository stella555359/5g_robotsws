*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC


Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: rzeczkowski.damian@gmail.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../CB012192/collectors.robot
Resource     ../CB012192/multiUE_keywords.robot
Library      ../CB012192/resources.py
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      ta5g_ue_mobility

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_lpq_AVQL.xml
...            AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=scf_multi_ue_4_ssb_lpq.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/multi_UE_lpq.lua
...            AND             Get Next Unpacked Full Pm Counters File

Suite Teardown    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
&{ASSIGNMENTS}=    1=1    2=1    3=5    4=5    5=6    6=6

*** Test Cases ***
CB012192_A_Multi_UE_4_SSB_mapped_1_RO
    [Documentation]   This case will verify support of 2SSBs map to one RO configuration with multi UE.
    ...    Assign 6 UEs, 2 UEs under Beam ID 0, 2 UEs under Beam ID 4 and 2UEs under Beam ID 5.
    ...    Perform RACH attempt at single RO for all UEs.

    Start collecting BIP logs
    Assign UEs To Beams    ${UES_LIST}    ${BEAMS_LIST}    ${ASSIGNMENTS}
    MUE Prach Control Testmode    profile_id_index=1    first_ue_id_index=1    last_ue_id_index=6
    Register 6 UEs
    Verify If All 6 UEs Are Active
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}/BIP_LOGS    delay=10s
    Convert BIP logs pcap to csv
    ...       pcap_path=${OUTPUT_DIR}/BIP_LOGS/L1L2_BIP_Logs/tcpdump.pcap
    ...       filter=uldata_prachreceiveind
    ...       dir_path=${OUTPUT_DIR}/BIP_LOGS/
    ...       csv_log_name=BIP_logs.csv
    ...       columns=@{BIP_columns}
    gNB Detect All 6 Preambles In Single RO Dedicated
    [Teardown]    Run Keywords    Get PM Counter File For Analysis
    ...    AND    Deregister 6 UEs
    ...    AND    Add Scout Data Info To Testcase

*** Keywords ***
Get PM Counter File For Analysis
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55306C00001    2      RA_ATT_CONT_A_PRMBL_SSB_00
        ...    M55306C00005    2      RA_ATT_CONT_A_PRMBL_SSB_04
        ...    M55306C00006    2      RA_ATT_CONT_A_PRMBL_SSB_05
        ...    M55306C03001    6      RA_COMP_CONT_A_PRMBL
        ...    M55306C06001    6      RA_MSG3_RECEP
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
        ...    file_path=${pm_counter_file}
