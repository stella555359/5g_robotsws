*** Settings ***
Documentation
...   author: Samraj Easterraj
...   contact: samraj.easterraj@nokia.com
...   5GC001423_SA End to End Verizon Test cases

Library     ${CURDIR}/../../../RRM/ST/resources/sg_e2e/pcap_helper.py

Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    ${CURDIR}/keywords.robot
Resource    ${CURDIR}/useful_keyword.robot

Resource    ${CURDIR}/../../../RRM/ST/resources/sg_e2e/mirroringScripts/gnbMirroring.robot


Force Tags    QCD_MN_5G    QCP_5G    SKIP_AGENT     CLOUD_5G_QC_ASIKL_ABILB1_AEUB_ENB_IPv6

Suite Setup      Common Suite Setup
#Suite Teardown   Teardown Logs Collectors
#Test Setup       Collect logs during test
#Test Teardown    Run Keyword And Ignore Error     Collect logs after test finished

*** Variables ***
${capabilities_ue}   REAL_UE
${branch_tag}        None
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  Radio Diagnostic Files collected
...                  Diagnostic Files collected
...                  Service account root access is enabled
...                  ToP reference missing
...                  Previously downloaded plan session#MRBTS-7361#13 was overwritten by a new plan session#MRBTS-7361#17
${size_packet}         1400B
${buffer_client_dl}    8M
${buffer_server_dl}    8M
${buffer_client_ul}    4M
${buffer_server_ul}    4M
${interval}            1
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${LOG_PATH}            ${OUTPUTDIR}
${PM_STORAGE}          ${LOG_PATH}

*** Test Cases ***
[1]5GI000144_F_2_CU and DU commissioning
    Perform Cloud Full Commissioning on CU and all DUs     prefix_tag=8CC

[1]5GC001423_SA_9_Cell Setup 8CC
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    Perform Cloud CU Commissioning     prefix_tag=8CC
    Perform All DUs commissioning    prefix_tag=8CC
    Check Cloud Setup OnAir

[1]5GC001423_SA_40_SSB transmission
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    [Teardown]     run keyword and ignore error    ssh.disconnect    asikFhCnx

    Test Suite Preparation
    Prepare Ue for L3 Call    capabilities=${capabilities_ue}    reboot_ue=True    timeout_reboot_ue=100
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${du-host}          ${du-user}	    ${du-password}	    alias=asikFhCnx
    # Start Log Collection
    gnbMirroring.Start Mirroring Traces      number_of_files=3    file_size_mbytes=55    connection=asikFhCnx
    Perform Attach and Verify UE Properly Attached
    ${L1L2_trace_pcap}    gnbMirroring.Stop and Collect Mirroring Traces     connection=asikFhCnx
    # Analysis Part:
    SA_40_SSB transmission Analysis     ${res_path}    ${L1L2_trace_pcap}



[1]5GC001423_SA_28_Link-Adaptation
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    [Teardown]     run keyword and ignore error    ssh.disconnect    asikFhCnx

    Test Suite Preparation
    Prepare Ue for L3 Call    capabilities=${capabilities_ue}    reboot_ue=True    timeout_reboot_ue=100
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${du-host}          ${du-user}	    ${du-password}	    alias=asikFhCnx
    ${tcpdump_filter}=         catenate    SEPARATOR=${SPACE}\\x26\\x26${SPACE}    ether[0x18:2]!=0xe101    ether[0x18:2]!=0x0122
    ...                              ether[0x18:2]!=0x0133     ether[0x18:2]!=0x0108    ether[0x18:2]!=0x0131
    #Init DL Directory:
    ${dl_pcap_path}  JoinPath       ${res_path}     DL
    Set Suite Variable          ${res_path}     ${dl_pcap_path}
    create directory    ${res_path}
    #Start BIP Log collection
    gnbMirroring.Start Mirroring Traces     number_of_files=10    file_size_mbytes=95    filtering=on
    ...            filter=${tcpdump_filter}    connection=asikFhCnx
    DL_Throughput_UDP_1-DRB_OTA_eLoner_4CC_contiguous    30s    #300s
    #Init DL Directory:
    ${DL_Traffic_L1L2_trace_pcap}    gnbMirroring.Stop and Collect Mirroring Traces    filtering=on    clean_scripts=No
    ...                                                                                 connection=asikFhCnx
    ${ul_pcap_path}  JoinPath       ${res_path}     ../UL
    Set Suite Variable          ${res_path}     ${ul_pcap_path}
    create directory    ${res_path}
    gnbMirroring.Start Mirroring Traces     number_of_files=10    file_size_mbytes=95    filtering=on
    ...            filter=${tcpdump_filter}    connection=asikFhCnx
    #UL_Throughput_UDP_1-DRB_OTA_eLoner_1CC_contiguous    30s     #300s
    BuiltIn.Sleep    30s
    ${UL_Traffic_L1L2_trace_pcap}    gnbMirroring.Stop and Collect Mirroring Traces     filtering=on
    ...                                                                                 connection=asikFhCnx
    SA_28_Link-Adaptation DL Analysis    ${dl_pcap_path}    ${DL_Traffic_L1L2_trace_pcap}
    SA_28_Link-Adaptation UL Analysis    ${ul_pcap_path}    ${UL_Traffic_L1L2_trace_pcap}

    #Validate MCS value > 26

[1]5GC001423_SA_15_5G attach
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    #...      Perform_4CCnon_contiguous_commissioning
    Prepare Ue for L3 Call    capabilities=${capabilities_ue}    reboot_ue=True    timeout_reboot_ue=100     alias=UE_1
    FOR    ${counter}    IN RANGE    1    5
        Attach UE and Detach      UE_1
    END

[1]5GC001423_SA_5_Cell Setup 4CC
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    Perform Cloud CU Commissioning     prefix_tag=4CC
    Perform All DUs commissioning    prefix_tag=4CC
    Check Cloud Setup OnAir

[1]5GC001423_SA_18_PDSCH+PUSCH max Tput 4CCDL_1CCUL
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    Prepare Ue for L3 Call    capabilities=${capabilities_ue}    reboot_ue=True    timeout_reboot_ue=100
    Bi-Directional_Throughput_UDP_1-DRB_OTA_eLoner_4CC_1CC_contiguous    30s
    DL_Throughput_UDP_1-DRB_OTA_eLoner_4CC_contiguous    30s
    UL_Throughput_UDP_1-DRB_OTA_eLoner_1CC_contiguous    30s
    # Any Logs to be collected ?

[1]5GC001423_SA_27_4CC_DL_1CC_UL_CA_contigous_carriers
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    #...      Perform_4CC_1CC_contiguous_commissioning
    Prepare Ue for L3 Call    capabilities=${capabilities_ue}    reboot_ue=True    timeout_reboot_ue=100
    DL_Throughput_UDP_1-DRB_OTA_eLoner_4CC_contiguous    300s
    UL_Throughput_UDP_1-DRB_OTA_eLoner_1CC_contiguous    300s

[1]5GC001423_SA_19_4CC Max tput long duration
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    Prepare Ue for L3 Call    capabilities=${capabilities_ue}    reboot_ue=True    timeout_reboot_ue=100
    DL_Throughput_UDP_1-DRB_OTA_eLoner_4CC_contiguous    1800s

[1]5GC001423_SA_20_5G SUE Peak Throughput_4CCDL_2CCUL ENDC activated
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    ...      Perform_4CC_2CC_non_contiguous_commissioning
    Prepare Ue for L3 Call    capabilities=${capabilities_ue}    reboot_ue=True    timeout_reboot_ue=100
    DL_Throughput_UDP_1-DRB_OTA_eLoner_4CC_contiguous    300s
    UL_Throughput_UDP_1-DRB_OTA_eLoner_1CC_contiguous    300s

[1]5GC001423_SA_32_Configuration_PCMD_NETACT
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    Perform_commissioning_activate_PCMD
    Check Cloud Setup OnAir
    #Any server status to be checked ?
    #Any logs to be verified ?

[1]5GC001423_SA_34_Activation_PCMD_NETACT
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    Perform_commissioning_activate_PCMD
    Check Cloud Setup OnAir
    #Should validate any PCMD log prints in gNB?

[1]5GC001423_SA_33_Deactivation_PCMD_NETACT
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    Perform_commissioning_deactivate_PCMD
    Check Cloud Setup OnAir
    #Perform Configuration Parameter Recommissioning On gNB
    #            ...     dist_name=MRBTS-{}/NRBTS-{}
    #            ...     param_name=actPCMDReport
    #            ...     param_value=false

[1]5GC001423_SA_37_RAP reset Slave, check synchro on Master
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    Prepare Ue for L3 Call    capabilities=${capabilities_ue}    reboot_ue=True    timeout_reboot_ue=100
    Data Transfer Start on Real UE And Wait    direction=DL    duration=400s    tput=2242 Mbits/sec   protocol=udp    deviation=65%
    gnb_bbu.Reset gNB         du_id=1
    Sleep   360s
    Check Cloud Setup OnAir
    Check Data Transfer on Real UE      direction=DL     tput=2242 Mbits/sec    deviation=55%

[1]5GI000144_F_12_Snapshot generation on CU and DU
    Download snapshot from CU
    ${snapshot_log_path}=     Collect Snapshot From gNB via GUI
    Run And Return Rc And Output        unzip ${snapshot_log_path}

[1]5GI000144_F_7_cell group lock-unlock from CU and DU webuis
    FOR    ${counter}    IN RANGE    0    5
         Lock Unlock Cell Group from CU And DU
    END

[1]5GI000144_F_10_Resets RU from NSP ; Webui
    FOR    ${du_id}    IN RANGE    1    2
        Log To Console    Rebooting all RUs of DU : ${du_id}
        Reboot All RUs in Cloud BTS DU    du_id=${du_id}     Counter=5
    END

[1]5GI000144_F_9_Resets DU from WebUI
    FOR    ${DU-RESET}    IN RANGE    0    2
        Log To Console    Reset Counter : ${DU-RESET}
        Reboot All DUs in Cloud BTS    ${DU-RESET}    5
    END

[1]5GI000144_F_8_Resets CU from WebUI
    [Setup]  Run keywords
    ...      Verify CU state is operational
    FOR    ${iterator}    IN RANGE    1   6
        Cloud Site Reset
        Sleep    700s
        Verify CU state is operational
    END

[1]5GC001423_SA_46_Nrcelltype parameter change on Webui
    [Setup]  Run keywords
    ...      Check Cloud Setup OnAir
    Perform_commissioning_NRCELLTYPE_parameters
    Check Cloud Setup OnAir

[1]5GC001423_SA_11_Stability_enBreset
    [Setup]  Run keywords
    ...      Verify CU state is operational
    ...      enb_bbu.Verify eNB is onAir
    FOR    ${iterator}    IN RANGE    1    2
        enb_bbu.Reset eNB
        Sleep    400s
        enb_bbu.Verify eNB is onAir
        Verify CU state is operational
    END
