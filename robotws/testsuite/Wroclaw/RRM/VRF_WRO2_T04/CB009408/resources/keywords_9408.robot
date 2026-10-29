*** Settings ***
Documentation
...   feature keywords

Library    ute_ue
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009408/resources/keywords_9408.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Library    testsuite/Wroclaw/RRM/resources/cell_utility/cell_utility_backend.py

*** Keywords ***
Start L3 Call And Verify NSA
    [Arguments]    ${ue}
    Tcpdump.Start Tcpdump On Smod    filename=attach.pcap
    Require Ue If Not Reserved    ${UE_1}
    ute_ue.Attach UE    ${ue}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds  3x  5s  ute_ue.Log UE Info  ${ue}  IP
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
    Check Cell And Signal Strength For Ue    ${ue}
    ${nsa_success}    Run Keyword and return status    Verify NSA Attach    pcap_file=${pcap_file}
    Run Keyword If    ${nsa_success} == False   Detach Ue    ${ue}
    Should Be True    ${nsa_success}   NSA attach failed
    Start DL Traffic For Ue   ${ue}   20Mbits/sec    protocol=udp
    Verify DL Tput For Ue    ${ue}
    [Return]    ${pcap_file}
    [Teardown]    Run Keywords    Tcpdump.teardown_tcpdump_on_smod    AND
    ...    Detach Ue    ${ue}    AND
    ...    Set Test Variable    ${${ue}_reserved}    ${True}

Verify NSA Attach
    [Arguments]    ${pcap_file}
    Get NR PCI From Pcap File   ${pcap_file}
    Should Be True   ${nr_pci}
    [Return]   ${nr_pci}

Save Current Scf Modify Gnb ID And Reload Scf
    [Arguments]    ${new_gnb_id}=0
    ${current_scf}=    delta_keywords.Get Scf From Nr    ${OUTPUT_DIR}    scf_after_l3call.xml
    ${modified_scf}=    Modify Gnb Id In Scf   scf_file=${current_scf}    ln_adj_id=${new_gnb_id}
    Load Scf    ${modified_scf}    skip_relation_errors=${FALSE}
    Wait For Onair    lte
