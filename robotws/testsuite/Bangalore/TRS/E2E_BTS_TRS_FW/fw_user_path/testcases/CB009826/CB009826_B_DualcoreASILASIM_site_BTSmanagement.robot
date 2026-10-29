*** Settings ***

Documentation

...        [Procedure]     "Checking SEC-ADM parameters in Primary and Secondary core"
...        [Date]          "12-06-2024"
...        [Author]        "Nagadeep"
...        [Feature_ID]    "CB009826"
...        [Maintenance]   "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "onair,checking SSH , SOE and R&D ports functionality,IPSEC"
...        [DELTA_FILE_DEPENDENCY]  "ssh_key_root.json,ssh_key_service.json"
...        [Validated_TestLine]     "TL001 & TL002"
...        [Precondition]             "Primary and secondary core's should be in sync"

variables       ta_e2e_bts_trs_fw

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/resources/CB009826_common_keywords.robot

Suite setup    Run Keywords    Suite Setup Preconditions
...            AND    Setup Oamops     alias=source
...            AND    Setup Oamops     dut=chained_bts     alias=secondary
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...            AND    Teardown Oamops     alias=source
...            AND    Teardown Oamops    dut=chained_bts    alias=secondary

***Test Cases***

[1][1.0] CB009826_B_DualcoreASILASIM site_BTSmanagement
     Perform Commissioning       scf_file=${Basic_scf}   verify_bts_status=False     timeout=400    alias=source
     Sleep      20
     Get parameter values
     Sleep   30
     Verify IP connectivity
     ${snapshot_primary}=  Collect Snapshot    timeout=600     alias=source
     ${snapshot_secondary}=  Collect Snapshot    timeout=600    alias=secondary
     Sleep    120
     Perform Recommissioning    type=delta    delta_file=${ipsec_delta}    timeout=800   skip_parameter_relation_errors=${True}
     ...    verify_bts_status=False     alias=source
     Enable Ipsec on SecureGW
     Enable Ipsec on Admin
     Ipsec Psk Update    key=Testing@123        timeout=120     alias=source
     Sleep    60
     Get Ipsec Tunnels Status
#checking ssh on both cores
    Check SSH Login       Primarybts
    Check SSH Login      Secondarybts

     Verify Alarm    expected_alarms=${expected_alarms}     alias=source
     Verify Alarm    unexpected_alarms=${unexpected_alarms}     alias=source
#LMP
    Sleep    60
    Verify Alarm   faultid=61649     rat=5g      should_exist=${True}      occurrences=1     alias=source
    Verify Alarm   faultid=61649     rat=5g      should_exist=${True}      occurrences=1     alias=secondary
#Disable SSH
    Change Ssh Access    enable=${False}       alias=source
    Sleep    60
    Verify Alarm   faultid=61524     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...     alias=source
    Verify Alarm   faultid=61524     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...    alias=secondary
#Enable SSH
    Change Ssh Access    enable=${True}     alias=source
    Sleep    60
    Verify Alarm   faultid=61524     rat=5g      should_exist=${True}      occurrences=1     alias=source
    Verify Alarm   faultid=61524     rat=5g      should_exist=${True}      occurrences=1     alias=secondary
#Enable SOE
    Change Ethernet Port Security    enable=${True}   alias=source
    Sleep    60
    Verify Alarm   faultid=4654     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...    alias=source
    Verify Alarm   faultid=4654     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...    alias=secondary
#Disable SOE
	Change Ethernet Port Security    enable=${False}   alias=source
    Sleep    60
    Verify Alarm   faultid=4654     rat=5g      should_exist=${True}      occurrences=1     alias=source
    Verify Alarm   faultid=4654     rat=5g      should_exist=${True}      occurrences=1     alias=secondary
#Disable R&D port
    Change Rnd Port Security   enable=${False}  alias=source
    Sleep    60
    Verify Alarm   faultid=61652     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...     alias=source
    Verify Alarm   faultid=61652     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...     alias=secondary
#Enable R&D port
    Change Rnd Port Security   enable=${True}  alias=source
    Sleep    60
    Verify Alarm   faultid=61652     rat=5g      should_exist=${True}      occurrences=1     alias=source
    Verify Alarm   faultid=61652    rat=5g      should_exist=${True}      occurrences=1    dut=chained_bts     alias=secondary
#Loginbanner
#primary
    ${stdout}=    Get Parameter   param_path=${secadm_moc_Log_banner}      str_format=${True}     alias=source
    Setup Remote Access  remote_device=Primarybts
   ${output}=         Remote Command Execute      command=cat /etc/ssh/banner
    Should Be Equal    ${stdout}     ${output}
#secondary
    Setup Remote Access  remote_device=Secondarybts
    ${output}=         Remote Command Execute      command=cat /etc/ssh/banner
    Should Be Equal    ${stdout}     ${output}
#############
     FOR    ${num}      IN RANGE    10
     Reset Bts    should_be_onair=false    timeout=500     alias=source
     Sleep    300
     END
     Sleep    150
     ${snapshot_primary}=  Collect Snapshot    timeout=600     alias=source
     ${snapshot_secondary}=  Collect Snapshot    timeout=600    alias=secondary
#checking ssh on both cores
    Check SSH Login       Primarybts
    Check SSH Login      Secondarybts
    Get Ipsec Tunnels Status
    Disable Ipsec on SecureGW
    Disable Ipsec on Admin
    Verify IP connectivity
    Verify Alarm    expected_alarms=${expected_alarms}    alias=source
    Verify Alarm    unexpected_alarms=${unexpected_alarms}     alias=source
#LMP
    Sleep    60
    Verify Alarm   faultid=61649     rat=5g      should_exist=${True}      occurrences=1     alias=source
    Verify Alarm   faultid=61649     rat=5g      should_exist=${True}      occurrences=1     alias=secondary
#Disable SSH
   Change Ssh Access    enable=${False}       alias=source
    Sleep    120
    Verify Alarm   faultid=61524     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...     alias=source
    Verify Alarm   faultid=61524     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...      alias=secondary
#Enable SSH
    Change Ssh Access    enable=${True}     alias=source
    Sleep    120
    Verify Alarm   faultid=61524     rat=5g      should_exist=${True}      occurrences=1     alias=source
    Verify Alarm   faultid=61524     rat=5g      should_exist=${True}      occurrences=1     alias=secondary
#Enable SOE
    Change Ethernet Port Security    enable=${True}   alias=source
    Sleep    120
    Verify Alarm   faultid=4654     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...     alias=source
    Verify Alarm   faultid=4654     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...     alias=secondary
#Disable SOE
    Change Ethernet Port Security    enable=${False}   alias=source
    Sleep    120
    Verify Alarm   faultid=4654     rat=5g      should_exist=${True}      occurrences=1     alias=source
    Verify Alarm   faultid=4654     rat=5g      should_exist=${True}      occurrences=1     alias=secondary
#Disable R&D port
    Change Rnd Port Security   enable=${False}  alias=source
    Sleep    120
    Verify Alarm   faultid=61652     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...     alias=source
    Verify Alarm   faultid=61652     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
    ...     alias=secondary
#Enable R&D port
    Change Rnd Port Security   enable=${True}  alias=source
    Sleep    120
    Verify Alarm   faultid=61652     rat=5g      should_exist=${True}      occurrences=1     alias=source
    Verify Alarm   faultid=61652    rat=5g      should_exist=${True}      occurrences=1    dut=chained_bts     alias=secondary
#Loginbanner
#primary
    ${stdout}=    Get Parameter   param_path=${secadm_moc_Log_banner}      str_format=${True}     alias=source
    Setup Remote Access  remote_device=Primarybts
   ${output}=         Remote Command Execute      command=cat /etc/ssh/banner
    Should Be Equal    ${stdout}     ${output}
#secondary
    Setup Remote Access  remote_device=Secondarybts
    ${output}=         Remote Command Execute      command=cat /etc/ssh/banner
    Should Be Equal    ${stdout}     ${output}
#    Teardown Oamops    alias=secondary