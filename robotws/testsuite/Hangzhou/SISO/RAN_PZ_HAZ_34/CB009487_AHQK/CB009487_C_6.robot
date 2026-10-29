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

*** Variables ***
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}
${btslog_path}    /opt/btslog/btslog
${btslog_launcher_path}    /opt/btslog/btslog_launcher
${btslog_folder}    /tmp/btslog2

*** Test Cases ***
[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    [Setup]    Test Case Setup
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20min
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_Auto_RF_module_reset_from_WebUI
    [Setup]    Test Case Setup
    @{ru_list}=       Get Current RU Number
    FOR    ${ru_index}    IN    @{ru_list}
        Perform RU Reset    ru_index=${ru_index}
        Wait Until Keyword Succeeds    240 sec    15 sec    RU Should Be Offline    ru_index=${ru_index}    connection=GNB_OAM
    END
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}    connection=GNB_OAM
    COAM Wait for gnb ready and cell setup    timeout=15 min    connection=GNB_OAM
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_Auto_RF_lock_unlock
    [Setup]    Test Case Setup
    @{use_ru_list}=        Get Current RU Number
    Lock RU and Check Status    ru_list=${use_ru_list}      gnb_type=SA
    Unlock RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    Test Case Setup
    @{use_ru_list}=        Get Current RU Number
    Connect to Common Unit Master
    FOR       ${ru_index}      IN      @{use_ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}     ru_alias=RU_${ru_index}
        Verify RFSW Log Include In Snapshot    ru_index=${ru_index}     ru_alias=RU_${ru_index}
    END
    [Teardown]    Test Case Teardown
