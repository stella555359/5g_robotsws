*** Settings ***
Suite Setup
Suite Teardown

Documentation
...         author: n5liu
...         contact: ning.4.liu@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         CNI-103148 test

Force Tags            RAN_5G     SBTS00      CRT_UTE


Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CNI-103148/Resources/CNI-103148_KW.robot

*** Variables ***
${WarningConfiguration}    ignore:SomeDeprecatedKeyword:DeprecationWarning
#${Test_PC_IP}             ${tl.test_pc[0].default_ssh_connection_details.addr}
#${Test_PC_username}       ${tl.test_pc[0].default_ssh_connection_details.username}
${snapshot_zip_path}       /home/ute/SBTS00_ENB_9999_250822_000001_release_BTSSM_downloadable_A54.zip
${remote_dir}              /data/ERR_WRN_analysis/7_5_UTE5G402T919
*** Test Cases ***
[1]CNI-103148_reset_RAT_snapshot_RF_LOG_debug
    [Setup]
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    sleep    20s
    Run Keyword And Ignore error   Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Ignore Error   ERR_WRN_Check.Check ERR Or WRN From Syslog
    ...   sys_logs_path=${sys_logs_path}[1]    testline=${testline_name}
    [Teardown]         Run Keyword If    "${execute_flag}[1]" == "${True}"
    ...      Run Keyword and Ignore Error       Restore remoteSyslog config in BTS
    ...       actRemoteSyslogTransmission=${parameter_log}[0]       syslog_config=${parameter_log}[1]
    ...        reconfig_flag=${parameter_log}[2]

*** Keywords ***
Debug_Debug
    ${UTE_zip_logs_path}      Set Variable       ${None}
    ${UTE_syslogs_path}      Set Variable       ${None}
    Set Suite Variable    ${UTE_syslogs_path}
    &{syslog_config1}     Create Dictionary
	   ...      remoteSyslogServerHost=${EMPTY}}
	 ${syslog_config_list}  Create List  ${syslog_config1}
    ${status}     ${execute_flag}      Run Keyword and Ignore Error       Check all conditions for ERR WRN
    IF   '${execute_flag}[1]' == '${False}'
         Log    Some condition is not met
         RETURN      ${UTE_zip_logs_path}      ${UTE_syslogs_path}
    END
    ${parameter_log_0}                  Run Keyword and Ignore Error       Get parameter value for MO
    ...      dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ${parameter_log}      set variable      ${parameter_log_0}[1]
    Run Keyword and Ignore Error       BuiltIn.Set Suite Variable    ${parameter_log}
    Run Keyword and Ignore Error       Log To Console       remote syslog config is ${parameter_log}
    Log To Console      Make remoteSyslog work for ERR WRN analysis
    Run Keyword and Ignore Error       Make remoteSyslog work for ERR WRN analysis
    ...       reconfig_flag=${parameter_log}[2]
