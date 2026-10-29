*** Settings ***
Documentation    Keywords for activating flags in swconfig file
Library      ../resources/common_functions.py
Library      ta5g_testline_management
Library      ta5g_enb

*** Variables ***
${ENABLE_CP_NRT_DEBUG_LOGS}=     0x66001b=1 # CP-NRT debug log level
${ENABLE_CP_RT_DEBUG_LOGS}=      0x590072=1 # CP-RT debug log level
${SET_ERAD_CCS_AASYSLOG_OUTPUT_MODE_TO_ALL}=        0x10041=1  # ERadCcs_AaSysLogOutputMode enabled for all
${ENABLE_SYSLOG_OUTPUT_SEVERITY_PRINTS_DEBUG_LEVEL}=    0x10040=1  # SYSLOG output severity prints debug level
${ENABLE_SYSLOG_INPUT_SEVERITY_PRINTS_DEBUG_LEVEL}=     0x1003F=1  # SYSLOG input severity prints debug level
${ENABLE_CP_NB_DEBUG_LOGS}=      0x890001=1 # CP-NB debug log level
${ENABLE_CP_SB_DEBUG_LOGS}=      0x890002=1 # CP-SB debug log level
${ENABLE_CP_UE_DEBUG_LOGS}=      0x890003=1 # CP-UE debug log level
${ENABLE_CP_CL_DEBUG_LOGS}=      0x890004=1 # CP-CL debug log level
${ENABLE_CP_IF_DEBUG_LOGS}=      0x890005=1 # CP-IF debug log level
${ENABLE_CP_SCTP_DEBUG_LOGS}=    0x890006=1 # CP-SCTP debug log level

@{SWCONFIG_FLAGS_LIST}=          ${ENABLE_CP_NRT_DEBUG_LOGS}
...                              ${ENABLE_CP_RT_DEBUG_LOGS}
...                              ${SET_ERAD_CCS_AASYSLOG_OUTPUT_MODE_TO_ALL}
...                              ${ENABLE_SYSLOG_OUTPUT_SEVERITY_PRINTS_DEBUG_LEVEL}
...                              ${ENABLE_SYSLOG_INPUT_SEVERITY_PRINTS_DEBUG_LEVEL}
...                              ${ENABLE_CP_NB_DEBUG_LOGS}
...                              ${ENABLE_CP_SB_DEBUG_LOGS}
...                              ${ENABLE_CP_UE_DEBUG_LOGS}
...                              ${ENABLE_CP_CL_DEBUG_LOGS}
...                              ${ENABLE_CP_IF_DEBUG_LOGS}
...                              ${ENABLE_CP_SCTP_DEBUG_LOGS}

*** Keywords ***
Reboot Modules And Wait For SSH Services
    Reboot Gnb and Airphone
    Wait For Testline Icmp Echo Replies And Ssh Services

Crasign Swconfig File On Bts
    Crasign File On Bts    file_path=/ffs/run/swconfig.txt

Enable C-Plane Debug Logs
    # Will activate C-Plane debug logs and reboot gNB and AP if ${with_reboot}==True
    [Arguments]    ${with_reboot}=${TRUE}
    Backup And Modify Swconfig File   parameters_list=@{SWCONFIG_FLAGS_LIST}
    Crasign Swconfig File On Bts
    Create Cp Runtime File    alias=cp_runtime
    Run Keyword If    ${with_reboot}==True    Reboot Modules And Wait For SSH Services

