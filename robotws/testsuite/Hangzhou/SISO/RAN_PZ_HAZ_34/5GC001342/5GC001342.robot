*** Settings ***
Documentation     author: Chen Yin
...               contact: Yin.1.chen@nokia-sbell.com
...               squad group: SG_02
...               configuration: 1S_1CC_4DL2UL
Force Tags        5G_SISO    CIT_TRUNK    COAM    CIT_22R4     CIT_22R3
...    PY36
Suite Setup       Setup enviornment with relevant configuration    scf_path=1S_1CC_4DL2UL.xml     ru_list=1
Suite Teardown    Run keyword and ignore error    Recover enviornment     scf_path=2S_1CC_4DL4UL_peak.xml
Resource          Resources/5GC001342_common_keywords.robot
Resource          ../5GC002029-A/Resources/5GC002029_A_common_keywords.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot

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
@{nrCellIdentity}    9093121
${UL_THROUGHPUT}    200M
${DL_THROUGHPUT}    1000M
${DURATION}    1200
${DL_TDD_EXPECT_100M}    300
${UL_TDD_EXPECT_100M}    15
${update_parameters_list}      [{'dist_name': 'MRBTS-555/EQM-1/HWTOP-1/CABLINK-2', 'parameter': 'linkSpeed',
    ...    'value': 'eCpri10'}, {'dist_name': 'MRBTS-555/EQM-1/HWTOP-1/CABLINK-3', 'parameter': 'linkSpeed', 'value': 'eCpri10'}]



*** Test Cases ***
[1]General_SiSo_RU_module_reset_from_GUI
    [Tags]    5GC001342
    [Setup]    Test Case Setup
    @{use_ru_list}    Create List    1
    Reset RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    [Teardown]    Test Case Teardown

[1]General_SiSo_RF_module_power_reset
    [Tags]    5GC001342
    [Setup]    Test Case Setup
    @{ignore_list}      Create List      10      4589
    @{use_ru_list}    Create List    1
    AlarmWatchdog.add_allow_alarms    fault_id=@{ignore_list}
    Power Off RU and Check Status    ru_list=${use_ru_list}
    Power On RU and Check Status    ru_list=${use_ru_list}    allowed_faults=${allowed_faults}
    AlarmWatchdog.remove_allow_alarms    fault_id=@{ignore_list}
    [Teardown]    Test Case Teardown

[1]General_SiSo_Commissioning_BTS_Recommissioning
    [Tags]    5GC001342
    [Setup]    Test Case Setup
    ${current_scf}=    Get Current SCF file    dir=${log_path}
    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${current_scf}    timeout=600
    COAM Wait for gnb ready and cell setup    timeout=15min
    [Teardown]    Test Case Teardown

[1]General_SiSo_BTS_startup_with_RF_delayed_startup
    [Tags]    5GC001342
    [Setup]    Test Case Setup
    General SiSo BTS Startup With RF Delayed Startup
    [Teardown]    Test Case Teardown

[1]General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    [Tags]    5GC001342
    [Setup]    Test Case Setup
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20min
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    [Teardown]    Test Case Teardown

[1]General_SiSo_Auto_RF_lock_unlock
    [Tags]    5GC001342
    [Setup]    Test Case Setup
    @{use_ru_list}    Create List    1
    Lock RU and Check Status    ru_list=${use_ru_list}
    Unlock RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    [Teardown]    Test Case Teardown

[1]General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    5GC001342
    [Setup]    Test Case Setup
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20min
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=RU_1    ru_index=1
    Verify RFSW Log Include In Snapshot    ru_alias=RU_1    ru_index=1
    [Teardown]    Test Case Teardown

[1]General_SiSo_KPI_Cell_lock_unlock_success_rate
    [Tags]    5GC001342
    [Setup]    Test Case Setup
    @{use_cell_list}    Create List    1
    Lock Cell and Check Status    cell_list=${use_cell_list}
    Unlock Cell and Check Status    allowed_faults=${allowed_faults}    cell_list=${use_cell_list}
    @{use_cell_group_list}    Create List    0
    Lock Cell Group and Check Status    cell_group_list=${use_cell_group_list}
    Unlock Cell Group and Check Status    allowed_faults=${allowed_faults}    cell_group_list=${use_cell_group_list}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Setup]    Test Case Setup
    Connect to Common Unit Master
    Connect to RU With Allocated IP      ru_index=1
    COAM verify ru sw version    ru_resource_build_key=LTX_AHQK_E1
    [Teardown]    Test Case teardown


[1]5GC001342_05_AHQK_eCPRI_with_1S-1CC-2DL-2UL_non-BF_80MHz_with 4 subsectors_L3_call
    [Setup]    Test Case Setup
    Recover enviornment        scf_path=2S_1CC_4DL4UL_peak.xml
    COAM Wait for gnb ready and cell setup    timeout=15min
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    Set test variable    ${ue_type}
    log    "link speed eCPRI25"
    UE Attach and Start Traffic    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
    ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
    ...                            nrCellIdentity=${nrCellIdentity}[0]    apn_address=dxdata2    ui_version=S24UI5.1
    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${stream}    Split String    ${current_version['Active']}    _
    Run keyword if      '${stream}[2]'=='9999'
    ...      Change CABLINK Link Speed to eCPRI10      version=${stream}[0]
    log    "link speed eCPRI25"
    UE Attach and Start Traffic    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
    ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
    ...                            nrCellIdentity=${nrCellIdentity}[0]    apn_address=dxdata2    ui_version=S24UI5.1
    [Teardown]    Test Case Teardown
