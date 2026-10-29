*** Settings ***
Documentation
...            author:       Hubert Chrzan, hubert.chrzan@nokia.com
...            maintainer:   Hubert Chrzan, hubert.chrzan@nokia.com

Library     ute_wtssim
Library     taf.transport.ssh           WITH NAME    taf_ssh
Resource    wts_2vms.robot

*** Variables ***
${HOST_IP_AP1}=        ${tl.test_pcs[0].default_ssh_connection_details.addr}
${HOST_IP_AP2}=        ${tl.test_pcs[1].default_ssh_connection_details.addr}
${WTS1_ALIAS}=         wts1
${WTS2_ALIAS}=         wts2
${AP1_PDU_PORT}=       ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${AP2_PDU_PORT}=       ${tl.ues[1].l1.common_units[0].pdu_port.port_no}
@{WTS_REGEX_AP1}       Established connection with proxy to eNB 2 cell 1
...                    Established connection with proxy to eNB 2 cell 2
...                    Established connection with proxy to eNB 2 cell 3
...                    eNB 2 cell 1: SystemInformationBlockType1-NR updated
...                    eNB 2 cell 2: SystemInformationBlockType1-NR updated
...                    eNB 2 cell 3: SystemInformationBlockType1-NR updated
@{WTS_REGEX_AP2}       Established connection with proxy to eNB 2 cell 7
...                    Established connection with proxy to eNB 2 cell 8
...                    Established connection with proxy to eNB 2 cell 9
...                    eNB 2 cell 7: SystemInformationBlockType1-NR updated
...                    eNB 2 cell 8: SystemInformationBlockType1-NR updated
...                    eNB 2 cell 9: SystemInformationBlockType1-NR updated

*** Keywords ***
Generic Test Setup CNI-120690
    [Documentation]    Start WTS till it reach OnAir on two WTS
    Check And Kill admin API Process
    Connect to virtual machine    alias=${WTS1_ALIAS}    hostname=${HOST_IP_AP1}
    Connect to virtual machine    alias=${WTS2_ALIAS}    hostname=${HOST_IP_AP2}
    Configure UTE ETH3 interface    alias=${WTS1_ALIAS}
    Configure UTE ETH2 interface    alias=${WTS2_ALIAS}
    Check And Stop Egate And Edaemon Then Reboot If Necessary    PDU_PORT=${AP1_PDU_PORT}    alias=${WTS1_ALIAS}
    Check And Stop Egate And Edaemon Then Reboot If Necessary    PDU_PORT=${AP2_PDU_PORT}    alias=${WTS2_ALIAS}

    Wait for gNB To Be Ready

    Start and configure WTS    alias=${WTS1_ALIAS}    hostname=${HOST_IP_AP1}
    Sleep    10s    reason=Wait for all data to be available
    Validate WTS regexp        reg_list=${WTS_REGEX_AP1}    alias=${WTS1_ALIAS}
    Start and configure WTS    alias=${WTS2_ALIAS}    hostname=${HOST_IP_AP2}
    Sleep    10s    reason=Wait for all data to be available
    Validate WTS regexp        reg_list=${WTS_REGEX_AP2}    alias=${WTS2_ALIAS}
    Ensure NG Link is Up    amf_id=1    alias=${WTS1_ALIAS}
    Ensure NG Link is Up    amf_id=3    alias=${WTS2_ALIAS}

Generic Test Teardown CNI-120690
    Check And Stop Egate And Edaemon Then Reboot If Necessary    PDU_PORT=${AP1_PDU_PORT}    alias=${WTS1_ALIAS}
    Check And Stop Egate And Edaemon Then Reboot If Necessary    PDU_PORT=${AP2_PDU_PORT}    alias=${WTS2_ALIAS}
    teardown all aliases for egate
    teardown all aliases for edaemon
    Wait for gNB To Be Ready
    Check And Kill admin API Process
    taf_ssh.reset_cache
