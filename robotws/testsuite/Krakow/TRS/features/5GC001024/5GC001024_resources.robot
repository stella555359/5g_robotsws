*** Settings ***
Library    testsuite/Krakow/TRS/resources/Firewall.py
Library    taf.rfrl.bts.commissioning
Library    testsuite.Krakow.TRS.resources.cu_webem.cu_webem_keywords.CuWebem    WITH NAME  webem
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${param_name} =  icmpResponseEnabled
${bts_id} =  0
${local_scf_dir_path} =  /home/ute/Downloads/
${scf_file_name}  scf_for_icmpResponseEnabled.xml
${original_icmpResponseEnabled}

*** Keywords ***
Check Current Flag State On Cu
    ${state}   Firewall.Get IcmpResponseEnabled Flag State
    [Return]  ${state}

Change all icmpResponseEnabled value
    [Arguments]    ${param_value}
    create_scf_to_edit  ${local_scf_dir_path}  ${scf_file_name}
    change_icmpResponseEnabled_value_in_scf  ${local_scf_dir_path}${scf_file_name}   MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1  ${param_value}
    change_icmpResponseEnabled_value_in_scf  ${local_scf_dir_path}${scf_file_name}   MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1  ${param_value}
    change_icmpResponseEnabled_value_in_scf  ${local_scf_dir_path}${scf_file_name}   MRBTS-{}/TNLSVC-1/TNL-3/IPNO-1  ${param_value}
    change_icmpResponseEnabled_value_in_scf  ${local_scf_dir_path}${scf_file_name}   MRBTS-{}/TNLSVC-1/TNL-4/IPNO-1  ${param_value}
    change_icmpResponseEnabled_value_in_scf  ${local_scf_dir_path}${scf_file_name}   MRBTS-{}/TNLSVC-1/TNL-5/IPNO-1  ${param_value}
    change_icmpResponseEnabled_value_in_scf  ${local_scf_dir_path}${scf_file_name}   MRBTS-{}/TNLSVC-1/TNL-6/IPNO-1  ${param_value}
    webem.Perform cu commissioning  ${local_scf_dir_path}${scf_file_name}

Change icmpResponseEnabled value
    Change icmpResponseEnabled value
    [Arguments]    ${param_value}  ${dist_name}
    change_icmpResponseEnabled_value_in_scf  ${local_scf_dir_path}${scf_file_name}  ${dist_name}  ${param_value}
    webem.Perform cu commissioning  ${local_scf_dir_path}${scf_file_name}

Save original icmpResponseEnabled value
    ${flag}  Check Current Flag State On Cu
    Set Global Variable  ${original_icmpResponseEnabled}  ${flag}
    Log  ${original_icmpResponseEnabled}

Set original icmpResponseEnabled value
    ${flag}  Check Current Flag State On Cu
    Run Keyword If 	"${original_icmpResponseEnabled}" != "${flag}"  Change all icmpResponseEnabled value  ${original_icmpResponseEnabled}

1024 Suite Setup
    Common Suite Setup With Commissioning
    Save original icmpResponseEnabled value
    Save Current gNB Configuration

1024 Suite Teardown
    Common Suite Teardown
    Set original icmpResponseEnabled value

1024 Test Setup
    Common Preconditions

1024 Test Teardown
    Common Postconditions
