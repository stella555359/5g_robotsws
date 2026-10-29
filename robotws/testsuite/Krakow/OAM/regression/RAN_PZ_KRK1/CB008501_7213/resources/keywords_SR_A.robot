*** Settings ***
Documentation
...   Resources for regression testing of features CB008501 and CB007213 CRT
...   author:   Marek Szlapa
...   contact:  marek.szlapa@nokia.com

Library    taf.rfrl.utilities.logger.custom_logger                      WITH NAME    custom_logger
Library    taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog    WITH NAME    collect_log
Library    taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations        WITH NAME    gnbru
Library    taf.rfrl.bts.devices.du.du_operations.GnbDuOperations        WITH NAME    gnbdu


*** Variables ***
${file_to_extraxt}          RMOD_L_1_linux_logs.tar
${Testpc_Interface_name}    eth3


*** Keywords ***
Reconfigure DHCP config
    [Documentation]    Configure FHNET inside gnb to reach RU interface IP
    custom_logger.Log info to console    Configuring DHCP and Resetting RU
    Set DHCP
    gnbru.Reset radio unit    radio_type=asirmod
    gnbdu.Wait for site to be onair

Snapshot download and extract
    [Arguments]    ${snapshot_name}
    [Documentation]    Collect and Extract gnb snapshot for packets verification
    custom_logger.Log info to console    Downloading ${snapshot_name}
    ${snapshot_path}     collect_log.Collect snapshot    snapshot_name=${snapshot_name}
    ${ectracted_path}    Extract snapshot    snapshot_path=${snapshot_path}    file_name_to_find=${file_to_extraxt}
    [Return]    ${ectracted_path}

Get packets
    [Arguments]    ${extracted_snapshot_dir}    ${chain}    ${search_info}
    [Documentation]    Get packets count from snapshot file
    custom_logger.Log info to console    Getting number of ${search_info} ${chain} packets
    ${result}    Get Packets Count    ${extracted_snapshot_dir}    ${chain}    ${search_info}
    custom_logger.Log info to console    msg=Result: ${result}    log_hierarchy=2
    [Return]    ${result}

Run scapy command
    [Arguments]    ${protocol}    ${packets_number}    ${pps}
    [Documentation]    Send packets to Shub using scapy command in test PC
    custom_logger.Log info to console    Sending ${protocol} packets to Shub using Scapy
    ${interface_details}    Get transfer devices IPs    test_pc_interface=${Testpc_Interface_name}
    ${current_python}    Get Current Python
    ${command}    Catenate
    ...           ${current_python}
    ...           ${CURDIR}/sendpackets.py
    ...           ${interface_details['PC_MAC']}
    ...           ${interface_details['RU_MAC']}
    ...           ${protocol}
    ...           ${packets_number}
    ...           ${pps}
    ...           ${interface_details['RU_IPV4']}
    ...           ${Testpc_Interface_name}
    ${ls_output_from_remote}    Run    sudo -s eval '${command}'
    Should Contain    ${ls_output_from_remote}    True
