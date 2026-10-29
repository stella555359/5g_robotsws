*** Settings ***
Documentation
...   feature keywords

Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2

Library    OperatingSystem
Library    String
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    keywords_7797.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/mcs/mcs_parsing.py
Library    ute_ue
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000747/resources/keywords_747.py

*** Keywords ***
256 QAM for PUSCH Dynamic Switching between 64QAM and 256 QAM
    [Arguments]  ${ue}=${UE_SA}   ${mcs_table_only}=${TRUE}
    Tcpdump.Start Tcpdump On Smod    smod_slave=${FALSE}
    Attach UE  ${UE_SA}
    Start Data Transfer and Check if Alive After a While    ${ue}

    L1L2.Start GnbMirroring    capturing_time_seconds=2    filename=l1l2_256.pcap
    BuiltIn.Sleep  2s  reason=Wait for bip logs
    ${bip_256}=    L1L2.stop_gnbmirroring_and_download_logs

    keywords_7797.Set 256qam Activation State For All Cells  ul  false
    Stop Data Transfers For All UEs

    Wait For Ue Idle State    inactivity_timer=60

    Start Data Transfer and Check if Alive After a While    ${ue}

    L1L2.Start GnbMirroring    capturing_time_seconds=2    filename=l1l2_64.pcap
    BuiltIn.Sleep  2s  reason=Wait for bip logs
    ${bip_64}=    L1L2.stop_gnbmirroring_and_download_logs

    keywords_7797.Set 256qam Activation State For All Cells  ul   true
    Stop Data Transfers For All UEs

    Wait For Ue Idle State    inactivity_timer=60
    Start Data Transfer and Check if Alive After a While    ${ue}
    L1L2.Start GnbMirroring    capturing_time_seconds=2    filename=l1l2_256_2.pcap
    BuiltIn.Sleep  2s  reason=Wait for bip logs
    ${bip_256_2}=    L1L2.stop_gnbmirroring_and_download_logs
    Tcpdump.Stop Tcpdump and download logs from SMOD

    Verify Mcs In Bip Logs  ${bip_256}  256  mcs_table_only=${mcs_table_only}
    Verify Mcs In Bip Logs  ${bip_64}  64  mcs_table_only=${mcs_table_only}
    Verify Mcs In Bip Logs  ${bip_256_2}  256  mcs_table_only=${mcs_table_only}

    [Teardown]    Run Keywords    Tcpdump.teardown_tcpdump_on_smod    AND
    ...    Stop Data Transfers For All UEs    AND
    ...    Detach Ue  ${UE_SA}

Start Data Transfer and Check if Alive After a While
    [Arguments]    ${ue}=${UE_SA}
    ${port}=  Generate random string  4  56789
    Log    Port for data transfer: ${port}    console=${True}
    Start Data Transfer  DT_UL_1  ${ue}  ul
    ...                  buffer=1000M   packet_size=1300   throughput=15 Mbits/sec  protocol=udp  port=${port}
    BuiltIn.Sleep  10s  reason=Wait for tput stabilization
    Check Data Transfer Is Alive  DT_UL_1

Set Attenuation 1 cell
    [Arguments]    ${cell_id}
    keywords.Attenuate All Cells
    Set Attenuation  ${ATTENUATOR['NRCELL_${cell_id}']['attenuation']}  ${ATTENUATOR['NRCELL_${cell_id}']['ports']}  confirm=${TRUE}
