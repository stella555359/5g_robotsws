*** Settings ***
Documentation
...     [Procedure]             "The testcase verify's port scan to check removal port 80 and config 3600 when actcli
...                              enabled "
...     [Date]                  "13-01-2022"
...     [Author]                "Sharavathi Achar"
...     [Maintenance]           "TRS ET Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "Security"
...     [Domain_Hash_Tags]      "NMAP port scan"
...     [Feature_ID]            "CB007672-5G-J"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-7672"
...     [Config_Comments]       "NA"
...     [RunTime Parameters]    "bts_id used is 7672"


Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB007672_5G_J_Removal_of_port_80_Config_3600_443_scan_ActcliParametercheck

    [Documentation]     This test case verifies the port 80 removal and port 3600 status according to actcli parameter

    Perform Commissioning       scf_file=${comm_file}   verify_bts_status=False     timeout=400     alias=default

    Sleep    900

    Perform Recommissioning     type=param      param_path=${soe_flag}     value=${True}        operation=update
    ...     timeout=120

    Get IPs To Ping

    Perform NMAP Port scan for Mplane

    Perform NMAP Port scan for LMP

    Perform Recommissioning     type=param      param_path=${actcli}    value=${True}       operation=update
    ...     timeout=120

    Perform NMAP Port scan for Mplane after enabling actcli

    Perform NMAP Port scan for LMP after enabling actcli

*** Keywords ***

Get IPs To Ping
    [Documentation]     This keyword reads a common IPv4 IP for all RAT config perspective.

    ${mplane_IP} =            Get Parameter       rat=common      param_path=${mplane1_ip_moc_path}

    Set Suite Variable      ${mplane_IP}

    ${mplane_IPV6} =            Get Parameter       rat=common      param_path=${mplanev6_ip_moc_path}

    Set Suite Variable      ${mplane_IPV6}


Perform NMAP Port scan for Mplane

    ${rc}  ${output}=    Run and Return Rc And Output   ${nmap_command} ${mplane_IP}

    Sleep       30

    Should Match Regexp   '${output}'   ${port443}
    Should Match Regexp   '${output}'   ${port3600_closed}
    Should Match Regexp   '${output}'   ${port80}

    ${rc}  ${output}=    Run and Return Rc And Output   ${nmapv6_command} ${mplane_IPV6}

    Sleep       30

    Should Match Regexp   '${output}'   ${port443}
    Should Match Regexp   '${output}'   ${port3600_closed}
    Should Match Regexp   '${output}'   ${port80}


Perform NMAP Port scan for LMP

    ${rc}  ${output}=    Run and Return Rc And Output   ${nmap_command} ${LMP_ip}

    Sleep       30

    Should Match Regexp   '${output}'   ${port443}
    Should Match Regexp   '${output}'   ${port3600_closed}
    Should Match Regexp   '${output}'   ${port80}

Perform NMAP Port scan for Mplane after enabling actcli

    ${rc}  ${output}=    Run and Return Rc And Output   ${nmap_command} ${mplane_IP}

    Sleep       30

    Should Match Regexp   '${output}'   ${port443}
    Should Match Regexp   '${output}'   ${port3600_opened}
    Should Match Regexp   '${output}'   ${port80}

    ${rc}  ${output}=    Run and Return Rc And Output   ${nmapv6_command} ${mplane_IPV6}

    Sleep       30

    Should Match Regexp   '${output}'   ${port443}
    Should Match Regexp   '${output}'   ${port3600_opened}
    Should Match Regexp   '${output}'   ${port80}



Perform NMAP Port scan for LMP after enabling actcli

    ${rc}  ${output}=    Run and Return Rc And Output   ${nmap_command} ${LMP_ip}

    Sleep       30

    Should Match Regexp   '${output}'   ${port443}
    Should Match Regexp   '${output}'   ${port3600_opened}
    Should Match Regexp   '${output}'   ${port80}
