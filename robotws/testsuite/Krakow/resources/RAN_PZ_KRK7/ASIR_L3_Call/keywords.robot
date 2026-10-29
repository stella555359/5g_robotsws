*** Settings ***
Documentation
...   Test suite for regression testing for feature CB008972
...   author: Jakub Bialon
...   contact: jakub.bialon@nokia.com
...   group: MN_RAN_RD_VRF_KRK_7

Library      BuiltIn
Library      taf.sbts.oam.coam.admin   WITH NAME   adminCli
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations
Library      taf.rfrl.bts.devices.asir.generic_asir.GenericAsirHub   WITH NAME   asirAdmin
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations   WITH NAME   gnb_asir
Resource     taf/rfrl/bts/robot/enb.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
# -----------------------------UE-----------------------------
${capabilities}                         REAL_UE
${alias}                                UE
${bts_type}                             GNB
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False
${deviation_ul}                         10%
${deviation_dl}                         10%
${duration}                             120s
${interval}                             1
${linux_congestion}                     reno
${parallel_streams_dl}                  4
${parallel_streams_ul}                  4
${reboot_ue}                            False
${size_packet_dl}                       1320B
${size_packet_ul}                       1380B
${timeout_reboot_ue}                    100
${tput_dl}                              830 Mbits/sec
${tput_ul}                              83 Mbits/sec
${qci}                                  None
${protocol}                             tcp
${buffer_client_dl}                     None
${buffer_server_dl}                     None
${buffer_client_ul}                     None
${buffer_server_ul}                     None
${GNB_SCF_NAME}                         SCF_main_gnb.xml


*** Keywords ***
Verify L3 Call Traffic
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}    qci_dl=${qci}    qci_ul=${qci}    linux_congestion_dl=${linux_congestion}
    ...    linux_congestion_ul=${linux_congestion}

Lock ASIR
    @{hub_ids}=    Get All Hub Ids
    adminCli.Connect to      name=coam
    FOR    ${i}    IN   @{hub_ids}
           adminCli.lock
           ...        dist_name=MRBTS-77143/EQM-1/APEQM-1/ASIRMOD-${i}
           ...        connection=coam
           ...        timeout=60
    END
    adminCli.teardown          connection=coam

Unlock ASIR
    @{hub_ids}=    Get All Hub Ids
    adminCli.Connect to      name=coam
    FOR    ${i}    IN   @{hub_ids}
           adminCli.unlock
           ...        dist_name=MRBTS-77143/EQM-1/APEQM-1/ASIRMOD-${i}
           ...        connection=coam
           ...        timeout=60
    END
    adminCli.teardown          connection=coam
