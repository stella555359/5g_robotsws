*** Settings ***
Documentation
...     [Procedure]             "The testcase verify's admin cli  login via  3600 port when actcli
...                              enabled from Netact"
...     [Date]                  "13-01-2022"
...     [Author]                "Sharavathi Achar"
...     [Maintenance]           "TRS ET Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "Security"
...     [Domain_Hash_Tags]      "Security"
...     [Feature_ID]            "CB007672-5G-J"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-7672"
...     [Config_Comments]       "NA"
...     [RunTime Parameters]    "bts_id used is 9015"


Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB007672_5G_J_Webem_login_via_3600_to_bts

    Perform Commissioning       scf_file=${comm_file_actcli}   verify_bts_status=False     timeout=400
    ...     alias=default

    Sleep    900

    Read IP Parameters

    Enable EthernetSecurity

    Login via LMP and Mplane with 3600 port

    Enable icmp flag

    Disable actcli flag from Netact

    Check cli login via port 3600 for LMP and Mplane

    Check cli login via port 443

    Post conditions

*** Keywords ***
Post conditions

    Enable actcli flag from Netact

    [Teardown]     Teardown Oamops

Read IP Parameters

    ${mplane_IP} =            Get Parameter       rat=common      param_path=${mplane1_ip_moc_path}

    Set Suite Variable      ${mplane_IP}

    ${mplane_IPV6} =            Get Parameter       rat=common      param_path=${mplanev6_ip_moc_path}

    Set Suite Variable      ${mplane_IPV6}


Login via LMP and Mplane with 3600 port

    Setup Oamops     bts_port=${3600_port}    timeout=120   alias=conn2

    Setup Oamops     bts_host=${mplane_IP}   bts_port=${3600_port}    timeout=120   alias=mplaneconn1

    Setup Oamops     bts_host=${mplane_IPV6}   bts_port=${3600_port}    timeout=120   alias=mplaneconn2

Enable Ethernetsecurity

    Perform Recommissioning     type=param      param_path=${soe_flag}    value=${True}      operation=update
    ...     timeout=120


Enable icmp flag

    Perform Recommissioning     type=param      param_path=${icmpres}    value=${True}        operation=update
    ...     timeout=120      alias=conn2


Disable actcli flag from Netact

    Setup Ems  config_device=netact1   alias=lab1023

    Cm Upload   config_device=netact1   alias=lab1023

    Configuration Manage  config_device=netact1    config=${disable_actcli}     plan_name=iv_fw_plan
    ...     delete_plan=${True}    alias=lab1023


Check cli login via port 3600 for LMP and Mplane

    Run Keyword and expect error   ${cmd1}   Setup Oamops     bts_port=${3600_port}    timeout=120
    ...     alias=conn3

    Run Keyword and expect error   ${cmd1}   Setup Oamops     bts_host=${mplane_IP}   bts_port=${3600_port}
    ...     timeout=120   alias=mplaneconn3

    Run Keyword and expect error   ${cmd1}   Setup Oamops     bts_host=${mplane_IPV6}   bts_port=${3600_port}
    ...     timeout=120   alias=mplaneconn4

Enable actcli flag from Netact

    Configuration Manage  config_device=netact1    config=${enable_actcli}     plan_name=iv_fw_plan
    ...     delete_plan=${True}    alias=lab1023

Check cli login via port 443

    Setup Oamops  timeout=120     alias=conn1
