*** Settings ***
Documentation
     ...    [Procedure] "The test case is planned to validate Backupipsec with M-PlaneIPv4 Ipsec tunnel with expired SeGW certificate"
     ...    [Date] "30-09-2024"
     ...    [Author] "Ruchika"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "IPSEC with backup ipsec enable"
     ...    [Feature_ID] "CB009741"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "ASIL"
     ...    [Commissioning_comment] "This script requires 5G configuration with IPSEC Enabled."


Library         ./SR001664_functions.py
variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB009741_keywords.robot

Suite setup     Run Keywords    setup oamops
Suite Teardown      Run Keywords    Teardown oamops


***Test Cases***
[1]TRS_CB009741_Verify_IPv4_Pri_sec_pri_automatic_switchover_with_Mplane_established_certexpired
    Perform Commissioning       scf_file=${Base_SCF_9741}        verify_bts_status=False     alias=default       timeout=300
    Sleep   180
    Perform Recommissioning        type=delta      delta_file=${backupipsec_CB009741}     timeout=400
    ...     skip_parameter_relation_errors=${True}
    Copy configuration files
    Read parameter BTS
    Add remote tunnel routes
    Perform Recommissioning        type=delta      delta_file=${basic_CMP_MOC_9741}     timeout=500     skip_parameter_relation_errors=${True}
    Sleep   120
    Verify cmp certificate state
    Verify tunnel establishment with valid certificate
    Perform Recommissioning        type=delta      delta_file=${Featureflag_9741}     timeout=400     skip_parameter_relation_errors=${True}
    Sleep   60
    Run    sudo ipsec restart
    Sleep   60
    Get Ipsec Tunnels Status
    Sleep   10
    Verify Alarm    faultid=61030    should_exist=${False}
    Verify Alarm    faultid=61644   severity=major    should_exist=${False}
    Sleep   10
    Verify tunnel status with expired cert
    Verify alarm with Peer certificate lifetime is Expired
    Verify Alarm        faultid=61644       occurrences=1
###Backupi
    Run     sudo ip a d 10.0.1.7/24 dev eth3.1300
    Run     sudo ip a d 10.0.1.11/24 dev eth3.1301
    Own Add Vlan    vlan_id=${vlan_id}
    Add Primary Ip To Vlan    vlan_id=${vlan_id}
    Own Set Ip Link up    vlan_id=${vlan_id}
    Add Secondary Ip To Vlan    vlan_id=${vlan_id}
    Run    sudo ipsec restart
    Sleep   20
    Remove Primary Ip From Vlan    vlan_id=${vlan_id}
    Add Secondary Ip To Vlan    vlan_id=${vlan_id}
    Sleep   200
    Verify Alarm        faultid=61644       occurrences=1
    Verify Alarm        faultid=61030       occurrences=1
    Remove Secondary Ip From Vlan    vlan_id=${vlan_id}
    Add Ps Ip To Vlan    vlan_id=${vlan_id}
    Add Secondary Ip To Vlan    vlan_id=${vlan_id}
    Sleep   300
    Verify Alarm        faultid=61030       occurrences=1
    Verify Alarm        faultid=61644       occurrences=1
    Sleep   30
    Add Primary Ip To Vlan    vlan_id=${vlan_id}
    Sleep   20
    Verify Alarm        faultid=61012       occurrences=1
    Verify Alarm        faultid=61644       occurrences=1