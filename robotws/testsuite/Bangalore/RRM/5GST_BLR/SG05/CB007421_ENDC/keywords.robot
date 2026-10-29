*** Settings ***
Documentation
...               Authors:    artur.krolak@nokia.com, dawid.wojciechowski@nokia.com
...               Maintainers:    artur.krolak@nokia.com, dawid.wojciechowski@nokia.com

Library           OperatingSystem
Library           SSHLibrary    60 seconds
Library           String
Library           Collections
Library           Process
#Library           ute_admin_infomodel
#Library           ute_admin
Library           taf.sbts.oam.coam.admin
#Library           ute_syslog
#Library           ute_scfc
#Library           ute_tshark
Library           ute_fsmaccess
#Library           ta_emil_cli_aatrace_parser
#Library           ta_enb_trs_traffic
#Library           custom_keywords.py
#Library           log_analayzer.py
#Library           custom_keywords.py
#Library           random_parameters.py
Library           /home/ute/robotlte/testsuite/Athulya/TDD_bundling/Resources/downloadSbtsBuild.py
Library           /home/ute/robotlte/testsuite/Athulya/TDD_bundling/Resources/sbtsUsersJsonRemove.py

#Resource          ../../../../../resources/WMP/GVe/Wroclaw/admin.robot
#Resource          ../../../../../resources/WMP/GVe/Wroclaw/bts_sw.robot
#Resource          ../../../../../resources/WMP/GVe/Wroclaw/logging.robot
#Resource          ../../../../../resources/WMP/GVe/Wroclaw/info_model_actions.robot
#Resource          ../../../../../resources/WMP/GVe/Wroclaw/bts_scfc.robot

#Variables         config/default_nbiot_scfc_map.yaml
#Variables         config/feature_scfc_file.yaml

*** Variables ***
${INFO_MODEL_PORT}=            DISABLED    #Possible values: ENABLED or DISABLED, where:
                                           #ENABLED means use keywords from ute_infomodel library
                                           #DISABLED means use keywords from ute_admin_infomodel library
${LOGS_SNAPSHOT}=              ${TRUE}     #Possible values: True or False
${ENB_ACTIONS_TRIGGER}=        ADMIN       #Possible values: BTSSM or ADMIN
${ENB_IP}=                     192.168.255.129
${ENB_USER}=                   toor4nsn
${ENB_PASSWORD}=               oZPS0POrRieRtu
${ADMIN_PORT}=                 443
${ADMIN_PORT_FL}=              3600
${IM_ALIAS}=                   infomodel
${TRS_IP}=                     192.168.255.129
${TRS_LOGIN}=                  Nemuadmin
${TRS_PASS}=                   nemuuser
${SYSLOG_IP}=                  192.168.255.126
${SYSLOG_PORT}=                51000
${SYSLOG_FILENAME}             syslog_enb.log
${TRUNK_PREFIX}=               FL00
${BRANCH_PREFIX_1}=            SBTS19A
${BRANCH_PREFIX_2}=            SBTS19B
${TSHARK_CAPTURING}=           ENABLED      #Possible values: ENABLED, DISABLED
${MPLANE_IP}=                  10.41.211.207
${CPLANE_IP}=                  10.41.211.207
${SCFC_DIR_PATH}=              /home/ute/robotlte/testsuite/Athulya/TDD_bundling/SCF/04082021/DL_4CA_2x2_MIMO_TC3_101.xml
#${SCFC_RAW_NAME}=              ${config_module.SCFC_REFERENCE_NAME}
${SCFC_PATHS}
${OUT_SUITE_LOGS_DIR_PATH}
${OUT_TEST_LOGS_DIR_PATH}
${OUT_ADMIN_PORT}
${OUT_ENB_ACTIVE_SW}
${OUT_ENB_PASSIVE_SW}
${OUT_FEATURE_ID}
${OUT_ENB_ID}
${OUT_BTS_SIDE}
${OUT_HW_VERSION}
${OUT_DICT_OF_MME}
${OUT_SCFC_FILE}
${OUT_SCFC_FILE_PATH}
${OUT_SCFC_DEFAULT_CLOUD}
${OUT_SCFC_VARIABLE_NAME}
${OUT_SCFC_ACTIVATED_NBIOT}
${OUT_RMOD_SER_NUM_LIST}
${OUT_RMOD_TYPE_LIST}
${OUT_LEGACY_LCR_ID_LIST}
${OUT_INBAND_LCR_ID_LIST}
${OUT_STANDALONE_LCR_ID_LIST}
${OUT_GUARDBAND_LCR_ID_LIST}
${OUT_NBIOT_CELLS_DICTIONARIES_LIST}
${OUT_LEGACY_LTE_LNCELL_LIST}
@{OUT_LNCEL_LIST}

@{ALLOWED_ALARMS}=    Vendor BTS certificate
...                   Synchronization lost
...                   Diagnostic Files collected
...                   BTS booted at .*? due to trs management re qc
...                   BTS reference clock missing
...                   ToP master service .*? unusable
...                   GPS receiver alarm: not tracking satellites
...                   R&D Service Port enabled
...                   SSH enabled
...                   LMP access .*?
...                   IP Traffic Capturing Ongoing port.*
...                   Failure in connection to Real-time PM Collection Entity
...                   Temp Fault1
...                   BTS Reset Cause
...                   Validation of signed file failed
...                   Reference clock missing in startup
@{ALARM_BLOCK_BTS}=                      {'alarmDetail': 'BTS blocked', 'faultId': '0*50\\D*', 'alarmsSeverity': 'a3'}
@{ALARM_POWER_RESET_OF_ALL_FR}=          {'alarmDetail': 'Failure in optical interface', 'faultId': '0*10\\D*', 'alarmsSeverity': 'a3'}
@{ALARM_CELL_BLOCK}=                     {'alarmDetail': 'Cell blocked', 'faultId': '0*49\\D*', 'alarmsSeverity': 'a3'}
@{ALARM_BLOCK_OF_ALL_FR}=                {'alarmDetail': 'RF Module blocked', 'faultId': '1931\\D*', 'alarmsSeverity': 'a3'}
@{ALARM_FAN_FAILURE}=                    {'alarmDetail': 'Fan failure', 'faultId': '1932\\D*', 'alarmsSeverity': 'a1'}
@{ALARM_SITE_RESET}=                     {'alarmDetail': 'BTS reset time increased', 'faultId': '4091\\D*', 'alarmsSeverity': 'a1'}
...                                      {'alarmDetail': 'Bts autonomous reset as recovery action', 'faultId': '4114\\D*'}
@{ALARM_S1_FAILURE}=                     {'alarmDetail': 'Transport layer connection failure in S1 interface', 'faultId': '6202\\D*'}
@{ALARM_TEMP_FAULT1}=                    {'alarmDetail': 'Temp Fault1', 'faultId': '9000\\D*'}
@{ALARM_BTS_RESET_CAUSE}=                {'alarmDetail': 'BTS Reset Cause', 'faultId': '4592\\D*'}

${TSHARK_IP}=                        10.42.80.41
${TSHARK_USER}=                      feve
${TSHARK_PASSWORD}=                  feve
${TSHARK_DIR}=                       /usr/local/bin/
${P8_build}=    /testsuite/Athulya/TDD_bundling/Resources/Builds/P8Build/*.zip


*** Keywords ***
Set QC_Tag
    ${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_FL00]
    Set Tags    ${QC_ID}

UpdateSoftware
    taf.sbts.oam.coam.admin.Setup admin    bts_host=192.168.255.129
    ...                                                                     bts_port=443
    ...                                                                     use_ssl=True
    ...                                                                     admin_api_log_dir=${OUT_SUITE_LOGS_DIR_PATH}
    ${Build_p8}=    Set Variable    ${P8_build}    
    ${v}=    taf.sbts.oam.coam.admin.Get Parameters    /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1    timeout=30
    ${oldSoftwareSBTS}=    Set Variable    ${v['activeSoftwareVersion']}
    log    ********* Active SW Version is ${v['activeSoftwareVersion']}*********
    taf.sbts.oam.coam.admin.Reset Configuration    false    false    timeout=1500
    sleep    10m
    Log to console  Config ResetDone
    taf.sbts.oam.coam.admin.Update Software    ${Build_p8}    should_activate=True    timeout=3000
    sleep    10m
    taf.sbts.oam.coam.admin.Teardown admin
    sleep    10s
    sbtsUsersJsonRemoveFromFFS
    sleep    10m
    taf.sbts.oam.coam.admin.Setup Admin    bts_host=192.168.255.129
    ...                                                                     bts_port=443
    ...                                                                     use_ssl=True
    ...                                                                     admin_api_log_dir="/home/ute"
    taf.sbts.oam.coam.admin.Perform Commissioning    bts_id=1061
    ...                                scf_file=/home/ute/robotlte/testsuite/Athulya/TDD_bundling/SCF/04082021/DL_4CA_2x2_MIMO_TC3_101.xml
    sleep   10m
    Log to console  P8 site is up
    ${v}=    taf.sbts.oam.coam.admin.Get Parameters    /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1    timeout=30
    ${P8Software}=    Set Variable    ${v['activeSoftwareVersion']}
    log    ********* Active SW Version is ${v['activeSoftwareVersion']}*********
    Latest Sbts Build    SBTS22R1   1   SBTS00   SRAN_CRT   No
    Log to console  Build Download Completed
    ${BuildPath}=    Set Variable    /home/ute/robotlte/testsuite/Athulya/TDD_bundling/Resources/Builds/Reg
    @{build_Number}=    OperatingSystem.List Files In Directory    /home/ute/robotlte/testsuite/Athulya/TDD_bundling/Resources/Builds/Reg/
    ${Build}=    Set Variable    /home/ute/robotlte/testsuite/Athulya/TDD_bundling/Resources/Builds/Reg/@{build_Number}[0]
    log to console    ${Build}
    Set Global Variable    @{build_Number}
    Set Global Variable    ${Build}
    ${a}=    Split String    @{build_Number}[0]    _
    log    ${a[0]}
    ${release}=    Set Variable    ${a[0]}
    log    ${release}
    ${varCheck}=    Run Keyword And Ignore Error    Should Contain    ${oldSoftwareSBTS}    ${a[2]}_${a[3]}_${a[4]}
    taf.sbts.oam.coam.admin.Update Software    ${Build}    should_activate=True    timeout=2000
    sleep    10m
    Log to console  SW update Ongoing...
    taf.sbts.oam.coam.admin.Teardown admin
    sleep    10s
    taf.sbts.oam.coam.admin.Setup Admin    bts_host=192.168.255.129
    ...                                                                     bts_port=443
    ...                                                                     use_ssl=True
    ...                                                                     admin_api_log_dir="/home/ute"
    log    *********Software Download Completed **************
    log    ********* Active SW Version is ${v['activeSoftwareVersion']}*********
    ${v}=    taf.sbts.oam.coam.admin.Get Parameters    /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1    timeout=30
    ${activesoftware}=    Set Variable    ${v['activeSoftwareVersion']}
    log to console    ********* Active SW Version is ${v['activeSoftwareVersion']}*********
    taf.sbts.oam.coam.admin.Teardown admin
    sleep   7m



