*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Deepthi A
                 ...              :contact      : deepthi.a@nokia.com
                 ...              :Description  : This script is to validate 1st Successful
                 ...  RI pilot processing during RIM DL mitigation triggered by RI detection only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,03.01.2025

Resource          ./resources/Keywords/CB014157_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB014157_variables.robot

Suite Setup       CB012564 Suite Setup
Suite Teardown    CB012564 Suite Teardown

*** Test Cases ***
CB012564_A_TC_01
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,29.04.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify CB012564 RIM RS1 RS2 in 72e
     Add Rad Param Or Modify GNB swconfig      0x580581=48       0x58057a = 4
     ${vendor_update}=    Set Variable    yes
     Get cell On Air     iphy=${CB014157_TC_01_IPHY}     scf_delta=${CB014157_TC_01_GNB_SCF}
     ...     cfg=${CB014157_TC_01_WTS}
     ...     vendor_update=${vendor_update}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Start SOS with BIP     ${sos_script_path}
     Sleep     30
     CB014157 SA Call UE1
     Sleep      1
     Activate RI
     Sleep     600
     Wait For Fault To Be Up     fault_id=7525   timeout=1900
     Activate RI enable RI pilot window
     Sleep     300
     Collect And Validate      log=${L_AP_GNB_SYS}       element=${VAL_RI_PILOT_WINDOW_detected}
     ...     value=none      logfile_with_path=${ONLINE_GNB_SYS_LOG}
     Collect And Validate      log=${L_AP_GNB_SYS}       element=${VAL_RI_PILOT_DL_MUTE_STATE_ACTIVE}
     ...     value=none      logfile_with_path=${ONLINE_GNB_SYS_LOG}
     Collect And Validate      log=${L_AP_GNB_SYS}       element=${VAL_RI_PILOT_WINDOW}
     ...     value=none      logfile_with_path=${ONLINE_GNB_SYS_LOG}
     Activate RIMRS FW1 9823-E
     Sleep     12
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Wait For Fault To Be Up     fault_id=7527   timeout=1900
     ${alarm_text}    Get 7527 alarm setid
     Log to console     ${alarm_text}
     Sleep    120
     ${alarm_text}=    Get 7527 alarm setid
     Log to console     ${alarm_text}
     ${retMatchResult}      Check RsSetId in Alarm Text       ${alarm_text}
     Should Be True     ${retMatchResult}
     Deactivate RIMRS FW1
     Sleep   100s
     Log to console     Waiting for 7527 RIMRS alarm to be down
     Wait For Fault To Be Down     fault_id=7527   timeout=600
     Deactivate RI
     Sleep   100s
     Log to console     Waiting for 7525 Remote Interference alarm to be down
     Wait For Fault To Be Down     fault_id=7525   timeout=700
     CB014157 SA Deregister UE1
