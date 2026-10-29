*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This script is to validate CB008235-A
                 ...                               03 test cases
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource          ./resources/Keywords/CB012564_Keywords.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB012564_variables.robot

Suite Setup       CB012564 Suite Setup
Suite Teardown    CB012564 Suite Teardown

*** Test Cases ***
CB012564_A_TC_01
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,29.04.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify CB012564 RIM RS1 RS2 in 72e
     ${vendor_update}=    Set Variable    yes
     Get cell On Air     iphy=${CFG_CB012564_TC_01_IPHY}     scf_delta=${CFG_CB012564_TC_01_GNB_SCF}
     ...     cfg=${CFG_CB012564_TC_01_WTS}
     ...     vendor_update=${vendor_update}
      Start Logs     ${L_AP_GNB_SYS}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Start SOS with BIP     ${sos_script_path}
     Sleep     30
     CB012564 SA Call UE1
     Sleep      1
     Activate RI
     Wait For Fault To Be Up     fault_id=7525   timeout=1900
     Activate RIMRS FW1 9823-E
     Sleep     12
#     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
#     Log to console      Please collect the bip logs for rimrs check also egen logs now
#     Collect And Check gnbBIP     /home/ute/logs/gNBbip/set1/
#     Collect and check apBIP     /home/ute/logs/APbip/set1/
#     Sleep     7
#     Collect And Check gnbBIP     /home/ute/logs/gNBbip/set2/
#     Collect and check apBIP     /home/ute/logs/APbip/set2/
#     Sleep     10
#     Collect And Check gnbBIP     /home/ute/logs/gNBbip/set3/
#     Collect and check apBIP     /home/ute/logs/APbip/set3/

     Wait For Fault To Be Up     fault_id=7527   timeout=1900
     ${alarm_text}    Get 7527 alarm setid
     Log to console     ${alarm_text}
     Sleep    120
     ${alarm_text}=    Get 7527 alarm setid
     Log to console     ${alarm_text}
     ${retMatchResult}      Check RsSetId in Alarm Text       ${alarm_text}
     Should Be True 	${retMatchResult}

     Sleep     300
