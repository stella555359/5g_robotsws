*** Settings ***
Documentation
...    Author:Chen Xiaodong
...    contact:xiaodong.d.chen@nokia-sbell.com
...    squad group:5G_PZ_HZ_2_SG

Force Tags       5G_RAN_TDD    PY39
Suite Setup          Common Suite Setup for COAM
Suite Teardown       robot_common_operations.Common Suite Teardown
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A/Resources/5GC002029_A_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000679_AA/Resources/5GC000679_common_keyword_Dingli.robot
Library           taf.selenium.sbts   WITH NAME   selenium_sbts

*** Variables ***
${scf_path}                /home/ute/Downloads/SCF
${default_scf}            ${scf_path}/SBTS25R3/siso_default_scf.xml
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_4681}              faultId=${4681}    #Sanity Check Error
&{fault_61649}              faultId=${61649}    #LMP access via port 443
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}    &{fault_4681}
              ...    &{fault_61649}
${btslog_path}    /opt/btslog/btslog
${btslog_launcher_path}    /opt/btslog/btslog_launcher
${btslog_folder}    /tmp/btslog2

*** Test Cases ***
[1]General_SiSo_Commissioning_BTS_Template_Commissioning
    [Setup]    Test Case Setup
    FOR    ${i}    IN RANGE    100
         COAM Commission with scf file    scf_file_path=${default_scf}    timeout=600
         COAM Wait for gnb ready and cell setup    timeout=15min
    END
    [Teardown]    Run Keyword And Ignore Error    Test Case Teardown

[1]General_SiSo_Cell_lock_and_unlock
    [Setup]    Test Case Setup
    FOR    ${i}    IN RANGE    100
         COAM Wait for gnb ready and cell setup
         @{use_cell_list}    Create List    0    1
         Lock Cell and Check Status 11    cell_list=${use_cell_list}      gnb_type=SA
         Unlock Cell and Check Status 11    allowed_faults=${allowed_faults}    cell_list=${use_cell_list}
    END
    [Teardown]    Run Keyword And Ignore Error    Test Case Teardown

[1][1.0] General_SiSo_RU_lock_unlock
    [Setup]    Test Case Setup
    FOR    ${i}    IN RANGE    100
         @{use_ru_list}    Create List    3    4    5
         Lock RU and Check Status    ru_list=${use_ru_list}      gnb_type=SA
         Unlock RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    END
    [Teardown]    Run Keyword And Ignore Error    Test Case Teardown

[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    [Setup]    Test Case Setup
    FOR    ${i}    IN RANGE    100
         ${active_fault}    COAM Get active alarms
         Perform BTS Site Reset
         COAM Wait for gnb ready and cell setup    timeout=20min
         Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
         sleep    50s
    END
    [Teardown]    Run Keyword And Ignore Error    Test Case Teardown

[1][1.0] General_SiSo_Auto_RF_module_reset_from_WebUI
    [Setup]    Test Case Setup
    FOR    ${i}    IN RANGE    100
         @{use_ru_list}    Create List    1     3     4     5
         Reset RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    END
    [Teardown]    Run Keyword And Ignore Error    Test Case Teardown

*** Keywords ***
Common Suite Setup for COAM
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Suite Variable     ${version}     ${result}[0]
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/siso_default_scf.xml

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='NSA'

Lock Cell and Check Status 11
    [Arguments]    ${cell_list}    ${all_cell}=${true}    ${gnb_type}=NSA
    FOR    ${c_list}    IN    @{cell_list}
         Perform cell lock via rest api    cell_idx=${c_list}
    END
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=7300
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=7319

Unlock Cell and Check Status 11
    [Arguments]    ${allowed_faults}    ${cell_list}
    FOR    ${c_list}    IN    @{cell_list}
         Perform cell unlock via rest api    cell_idx=${c_list}
    END
    sleep    60s
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}