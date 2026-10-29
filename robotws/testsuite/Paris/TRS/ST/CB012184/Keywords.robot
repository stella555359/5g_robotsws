*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB012184: Deep Sleep Mode Support for RF6.1 TDD RRH

Resource            CommonKeywords.robot


*** Variables ***
${tshark_filter_srn_1}=       (oran_fh_cus.ru_port_id >=64 && oran_fh_cus.ru_port_id <=95)
${tshark_filter_srn_2}=       (oran_fh_cus.ru_port_id >=192 && oran_fh_cus.ru_port_id <=223)


*** Keywords ***
CB012184 Setup
    Log To Console    CB012184 setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

Test Setup
    Log To Console    Test setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # Start the logs
    # Start All Logs

Test Teardown
    Log To Console    Test teardown
    # Save the logs and get Snapshot
    # Get All Logs

    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

# [1]CB012184_E_TC_25_2x50G-SRS-4DL4UL-ABIQ

SRS 4DL4UL
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_12184}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # 2 SSH sessions for the 2 DPDK processes
    ${TESTPMD}=    Connect to DPDK    ${mirror_dpdk_addr}    ${mirror_dpdk_username}    ${mirror_dpdk_password}
    ${PDUMP}=    Connect to DPDK    ${mirror_dpdk_addr}    ${mirror_dpdk_username}    ${mirror_dpdk_password}

    Start Remote Testpmd    ${TESTPMD}    ${mirror_dpdk_password}
    Start Remote Pdump    ${PDUMP}    ${mirror_dpdk_password}

    Sleep    10s

    Close Remote Pdump    ${PDUMP}
    Stop Remote Testpmd    ${TESTPMD}

    Switch Connection    ${TESTPMD}

    ${command}=    Set Variable    sudo chmod 666 /tmp/robot_mirror.pcap
    SSHLibrary.Write    text=${command}
    Sleep    2s
    ${output}=    SSHLibrary.Read
    Log To Console    ${output}
    ${command}=    Set Variable    ${mirror_dpdk_password}
    SSHLibrary.Write    text=${command}
    Sleep    2s
    ${output}=    SSHLibrary.Read

    ${tshark_filter_srn}=    Set Variable    ${tshark_filter_srn_1} || ${tshark_filter_srn_2}
    ${output}=    SSHLibrary.Execute Command
    ...    command=tshark -r /tmp/robot_mirror.pcap -Y '${tshark_filter_srn}' -w /tmp/robot_mirror_srn.pcap

    ${command}=    Set Variable
    ...    tshark -r /tmp/robot_mirror_srn.pcap -Y 'vlan.id == 200' -T fields -e eth.dst > /tmp/200.txt
    SSHLibrary.Execute Command    command=${command}

    ${command}=    Set Variable
    ...    tshark -r /tmp/robot_mirror_srn.pcap -Y 'vlan.id == 201' -T fields -e eth.dst > /tmp/201.txt
    ${output}=    SSHLibrary.Execute Command    command=${command}

    ${command}=    Set Variable
    ...    tshark -r /tmp/robot_mirror_srn.pcap -Y 'vlan.id == 202' -T fields -e eth.dst > /tmp/202.txt
    ${output}=    SSHLibrary.Execute Command    command=${command}

    ${command}=    Set Variable    uniq /tmp/200.txt | wc -l
    ${srn_used_ports}=    SSHLibrary.Execute Command    command=${command}
    Should Be Equal    ${srn_used_ports}    1
    Log To Console    ${srn_used_ports} ABIQ ports are used for cell 1

    ${command}=    Set Variable    uniq /tmp/201.txt | wc -l
    ${srn_used_ports}=    SSHLibrary.Execute Command    command=${command}
    Should Be Equal    ${srn_used_ports}    1
    Log To Console    ${srn_used_ports} ABIQ ports are used for cell 2

    ${command}=    Set Variable    uniq /tmp/202.txt | wc -l
    ${srn_used_ports}=    SSHLibrary.Execute Command    command=${command}
    Should Be Equal    ${srn_used_ports}    1
    Log To Console    ${srn_used_ports} ABIQ ports are used for cell 3

    ${command}=    Set Variable    uniq /tmp/200.txt > /tmp/srn.txt
    ${output}=    SSHLibrary.Execute Command    command=${command}
    ${command}=    Set Variable    uniq /tmp/201.txt >> /tmp/srn.txt
    ${output}=    SSHLibrary.Execute Command    command=${command}
    ${command}=    Set Variable    uniq /tmp/202.txt >> /tmp/srn.txt
    ${output}=    SSHLibrary.Execute Command    command=${command}
    ${command}=    Set Variable    uniq /tmp/srn.txt | wc -l
    ${srn_used_ports}=    SSHLibrary.Execute Command    command=${command}
    Should Be Equal    ${srn_used_ports}    2
    Log To Console    ${srn_used_ports} ABIQ ports are used for the 3 cells
