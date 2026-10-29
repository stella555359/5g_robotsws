*** Settings ***
Documentation     author: Chen Yin
...               contact: Yin.1.chen@nokia-sbell.com
...               squad group: SG_02
Force Tags        5G_SISO
...    PY36
Suite Setup       Setup enviornment with relevant configuration      scf_path=9487_C_06.xml
Resource          Resources/CB009487_common_resource.robot
Resource          ../5GC002029-A/Resources/5GC002029_A_common_keywords.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py
Library    taf.ue    WITH NAME    ute_ue

*** Variables ***
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_61649}             faultId=${61649}    #LMP access via port 443
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}      &{fault_61649}
${btslog_path}    /opt/btslog/btslog
${btslog_launcher_path}    /opt/btslog/btslog_launcher
${btslog_folder}    /tmp/btslog2
@{nrCellIdentity}    3702785
${UL_THROUGHPUT}    200
${DL_THROUGHPUT}    1500
${ue_index}      0


*** Test Cases ***
[1][1.0] General_SiSo_Pre_Cabling_configuration
    [Setup]    Test Case Setup
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${current_scf}=    Get Current SCF file    dir=${log_path}
    ${DL_EXPECT_peak}    ${UL_EXPECT_peak}    get_theoretical_throughput
    ...     scf_path=${current_scf}
    ...     cell_id=1
    Reboot CPE before testing      ue_index=${ue_index}      ue_SN_num=${tl.ues[${ue_index}].serial_number}
    Sleep    5min
    Wait Until Keyword Succeeds       5min      30s      Connect to gnb coam via ssl      connection=GNB_OAM
    ${cell_mapping}=      Get Relation Mapping Between Cell Index And NrCellIdentity      connection_alias=GNB_OAM
    ${cell_id} =      convert to string    ${cell_mapping[${1}]['nrCellIdentity']}
    ${cell_id}=       Create List       ${cell_id}
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${ue_index}
    Set Test Variable      ${ue_type}
    UE Attach
    Start L3 call and check peak TPUT
    ...      expected_DL_TPUT=${DL_EXPECT_peak}      expect_UL_TPUT=${UL_EXPECT_peak}      nrCellIdentity=${cell_id}
    ...      data_transfer_dl=${DL_THROUGHPUT}      data_transfer_ul=${UL_THROUGHPUT}
    ...      process_num=5
    [Teardown]    Test Case Teardown


*** Keywords ***
Reboot CPE before testing
    [Arguments]   ${ue_index}      ${ue_SN_num}
    Run Keyword And Ignore Error     csn.disconnect    connection=cygwin
    Connect to control pc via cygwin    ue_index=1
    Sleep    2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${ue_SN_num} shell reboot    connection=cygwin
    sleep   3s

UE Attach
    [Arguments]    ${attach_mode}=5G_SA      ${ue_index}=0      ${cap_index}=0      ${check_4G}=False
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    cap_index=${cap_index}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=${check_4G}     5Grach_ed=${5Grach_ed}

Start L3 call and check peak TPUT
    [Arguments]    ${expected_DL_TPUT}      ${expect_UL_TPUT}      ${nrCellIdentity}
    ...      ${data_transfer_dl}=300    ${data_transfer_ul}=20    ${duration}=500      ${attach_mode}=5G_SA
    ...      ${ue_index}=0      ${cap_index}=0      ${process_num}=1      ${check_resource}=aasyslog
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    cap_index=${cap_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=${duration}
    ...                       ue_index=${ue_index}    cap_index=${cap_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${UL_THROUGHPUT}
    ...                       duration=${duration}    ue_index=${cap_index}      process_num=${process_num}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}     duration=120      check_source=${check_resource}
    ${target_UL_TPut}      Evaluate      ${expect_UL_TPUT}*0.95
    ${target_DL_TPut}      Evaluate      ${expected_DL_TPUT}*0.95
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    cells=${nrCellIdentity}
    ...                                    log=${tput_log}    target_throughput=${expected_DL_TPUT}      check_source=${check_resource}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    cells=${nrCellIdentity}
    ...                                    log=${tput_log}    target_throughput=${target_UL_TPut}      check_source=${check_resource}
    [Teardown]        Stop traffic and UE detach      ue_type=${ue_type}

Stop traffic and UE detach
    [arguments]    ${ue_type}      ${ue_index}=${0}
    Run Keyword And Ignore Error      power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    Run Keyword And Ignore Error     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    Run Keyword And Ignore Error      power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
