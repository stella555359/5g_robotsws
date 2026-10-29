*** Settings ***
Documentation    Author: yonna.yao@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Resource    common_host_server.robot
Resource    common_logs_operate.robot
Resource    common_gnb.robot
Resource    common_airphone.robot
Resource    common_qualcomm.robot
Resource    common_common.robot
Resource    internal_setup_teardown.robot
Resource    alarm_checking.robot
Library     taf.sw.scout    WITH NAME    scout
Library     ../python/tak_airphone/
Library    random
#*** Variables ***

*** Keywords ***
Common Suite Setup
    [Arguments]    ${domain}=noklab\\
    [Documentation]    This keyword is common Suite Setup.
    ...    Examples:
    ...    | Common Suite Setup |
    #Set Tags     QCP_RAN_ET
    Set Tags     QCD_MN_RAN
    Clean Up Env
    Get Host IP
    Get Host Name
    Get GNB Software Version
    Get Control Board Type
    Get Base Band Board Type
    Get Test Line Type
    Run Keyword If     "${L1_TYPE}"=="${EMPTY}"    Get L1Bypass Type
    Download All Tools
    #${UE_TYPE}    _get_ue_type
    Set Suite Variable    ${UE_TYPE}    airphone
    Run Keyword If    '${UE_TYPE}'=='airphone'    _airphone_suite_setup
    Run Keyword If    '${UE_TYPE}'=='qualcomm'    _qualcomm_suite_setup    ${domain}
    Run Keyword If    '${UE_TYPE}'=='cpe'    _cpe_suite_setup
    Check Alarm and stop robot testing when unexpected alarm raised
	${ret}     run      pip list |grep -E "^ta|^ute"
    log    ${ret}
    #${ret}   OperatingSystem.Run and return rc and output  . /home/ute/test_repo/bin/activate;pip install ta_a2a -U

Common Suite Teardown
    [Documentation]    This keyword is common Suite Teardown.
    ...    Examples:
    ...    | Common Suite Teardown |
    Run Keyword If    '${UE_TYPE}'=='airphone'    Airphone Teardown
    Run Keyword If    '${UE_TYPE}'=='qualcomm'    Qualcomm Teardown
    Run Keyword If    '${UE_TYPE}'=='cpe'    _cpe_suite_teardown

Common Test Setup
    [Documentation]    This keyword is common Test Setup. will start common logs.
    ...    Examples:
    ...    | Common Test Setup |
    Run Keyword And Ignore Error    Set QC Tag In Case     ${TEST_NAME}     ${SOFTWARE_INFO}
    Run Keyword And Ignore Error    Start Collect Logs

Common Test Teardown
    [Documentation]    This keyword is common Test Teardown. will stop common logs and collect config files
    ...    Examples:
    ...    | Common Test Teardown |   |
    Run Keyword And Ignore Error    Stop Collect Logs
    OperatingSystem.create directory    ${test_log_directory()}/All/
    Run Keyword And Ignore Error    Backup Scf                 ${test_log_directory()}/All/
    Run Keyword And Ignore Error    Backup Swconfig            ${test_log_directory()}/All/
    Run Keyword If    '${UE_TYPE}'=='airphone'    _airphone_test_teardown
    kill_ute_syslog_process
    run keyword and ignore error    Check TL Type And Prepare Configuration
    run keyword and ignore error    common_setup_teardown.Ask scout to analyze scf

Ask scout to analyze scf
    # ask scout to analyze scf
    ${hostname}=    Run    cat /etc/hostname | sed 's/-/_/g'
    ${host_name}    Evaluate    re.sub("_1$", "", re.sub("_2$", "", "${host_name}"))    re
    scout.setup_scout    scout_testline_name=${hostname}
    scout.request_scf


Check TL Type And Prepare Configuration
    ${testline_type}=    Get Testline Type
    Log To Console    testline_type=${testline_type}
    Run Keyword IF   '${testline_type}'=='CLOUD_5G_I_LO_AP_LO'    Prepare Configuration For LO_AP_LO
    ...    ELSE IF   '${testline_type}'=='CLOUD_5G_I_BOO_AP_LOO'
    ...    Prepare Configuration For BOO_AP_LOO
    ...    ELSE IF   '${testline_type}' == 'CLOUD_5G_I_MP_AP_LOOO' or '${testline_type}' == 'CLOUD_5G_I_MP_AP_LO'
    ...    Prepare Configuration For MP_AP_LOOO

Prepare Configuration For LO_AP_LO
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    ${grandparent_dir}=    Join Path    ${parent_dir}    ..
    ${file_list}=    Create List    scfc_aplo.xml    scfc_aplo_01.xml    scfc_aplo_02.xml    scfc_aplo_03.xml    scfc_aplo_04.xml
    ...    scfc_tmo_local.xml
    ${scfc_file}  Evaluate  random.choice(${file_list})  random
    ${file_dict}=    Create Dictionary    scfc_aplo.xml=iphy_aplo.xml    scfc_aplo_01.xml=iphy_aplo_01.xml
    ...     scfc_aplo_02.xml=iphy_aplo_02.xml     scfc_aplo_03.xml=iphy_aplo_03.xml     scfc_aplo_04.xml=iphy_aplo_04.xml
    ...     scfc_tmo_local.xml=iphy_tmo_local.xml
    ${iphy_file}    Get From Dictionary    ${file_dict}    ${scfc_file}
    Change iphy rru version    ${grandparent_dir}/sg11/internal_resource/config/${SW_BRANCH}/${iphy_file}
    ${scfc_path}    Set variable    ${grandparent_dir}/sg11/internal_resource/config/${SW_BRANCH}/${scfc_file}
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
    Perform Full Commission    ${new_scfc}
    Sleep    60s    wait testline can reboot stable.
    Verify GNB Is Configured

Prepare Configuration For BOO_AP_LOO
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    ${grandparent_dir}=    Join Path    ${parent_dir}    ..
    ${file_list}=    Create List    scfc_boo_01.xml    scfc_boo_02.xml    scfc_boo_03.xml    scfc_boo_04.xml    scfc_boo_05.xml    scfc_boo_06.xml
    ${scfc_file}  Evaluate  random.choice(${file_list})  random
    ${file_dict}=    Create Dictionary    scfc_boo_01.xml=iphy_boo_01.xml    scfc_boo_02.xml=iphy_boo_02.xml
    ...     scfc_boo_03.xml=iphy_boo_03.xml     scfc_boo_04.xml=iphy_boo_04.xml     scfc_boo_05.xml=iphy_boo_05.xml
    ...     scfc_boo_06.xml=iphy_boo_06.xml
    ${iphy_file}    Get From Dictionary    ${file_dict}    ${scfc_file}
    Change iphy rru version    ${grandparent_dir}/sg11/internal_resource/config/${SW_BRANCH}/${iphy_file}
    ${scfc_path}    Set variable    ${grandparent_dir}/sg11/internal_resource/config/${SW_BRANCH}/${scfc_file}
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
    Perform Full Commission    ${new_scfc}
    Sleep    60s    wait testline can reboot stable.
    Verify GNB Is Configured

 Prepare Configuration For MP_AP_LOOO
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    ${grandparent_dir}=    Join Path    ${parent_dir}    ..
    ${file_list}=    Create List    scfc_mp_01.xml    scfc_mp_02.xml
    ${scfc_file}  Evaluate  random.choice(${file_list})  random
    ${file_dict}=    Create Dictionary    scfc_mp_01.xml=iphy_mp_01.xml    scfc_mp_02.xml=iphy_mp_02.xml
    ${iphy_file}    Get From Dictionary    ${file_dict}    ${scfc_file}
    Change iphy rru version    ${grandparent_dir}/sg11/internal_resource/config/${SW_BRANCH}/${iphy_file}
    ${scfc_path}    Set variable    ${grandparent_dir}/sg11/internal_resource/config/${SW_BRANCH}/${scfc_file}
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
    Perform Full Commission    ${new_scfc}
    Sleep    60s    wait testline can reboot stable.
    Verify GNB Is Configured
