*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This script is to validate CB008235-A
                 ...                               03 test cases
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,21.04.2025,vadivelan.manickavasagam@nokia.com

Resource          ../resources/Keywords/CB008235_Keywords.robot
Resource          ../resources/Keywords/CB012564_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ../resources/Variables/CB008235_variables.robot

Suite Setup       CB008235 Suite Setup
Suite Teardown    CB008235 Suite Teardown

*** Test Cases ***
CB008235_D_TC_03_Interworking with CB012564 7-2e FH - RIM RS processing
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,21.04.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify four RANK 2 UE pairing IWK RIMRS
         ...    To Verify UL MU-MIMO stopped when Remote Interference detected
         ...    and recovered when  Remote Interference disappears.
     ${vendor_update}=    Set Variable    yes
     Get cell On Air     iphy=${CFG_CB008235_A_TC_01_IPHY}     scf_delta=${CFG_CB008235_D_TC_03_GNB_SCF}
     ...     cfg=${CFG_CB008235_A_TC_03_WTS}
     ...     vendor_update=${vendor_update}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Collect And Validate      log=${L_GNB_SYS}      element=${VAL_UL_SUBCELLTYPE_C16_8}
     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
     Start SOS with BIP     ${sos_script_path}
     CB008235 Ul Sinr Profile Act
     CB008235 SA Call UE1 to UE4
     Sleep      1
     Start Logs     ${L_GNB_TTI}
     Sleep      1
     Stop Logs     ${L_GNB_TTI}
     Validate 4UE RANK2 Paired in TTI logs
     Validate 4 RANK2 Paired UE Data Rate     45
     Activate RI
     Wait For Fault To Be Up     fault_id=7525   timeout=1900
     Activate RIMRS FW1 9823-E
     Wait For Fault To Be Up     fault_id=7527   timeout=1900
     ${alarm_text}    Get 7527 alarm setid
     Log to console     ${alarm_text}
     Sleep    120
     ${alarm_text}=    Get 7527 alarm setid
     Log to console     ${alarm_text}
     Check RsSetId in Alarm Text       ${alarm_text}
     Start Logs     ${L_GNB_TTI}
     Sleep      1
     Stop Logs     ${L_GNB_TTI}
     Collect And Check gnbBIP     /home/ute/logs/gNBbip/set1/
     Collect and check apBIP     /home/ute/logs/APbip/set1/
     Sleep     7
     Collect And Check gnbBIP     /home/ute/logs/gNBbip/set2/
     Collect and check apBIP     /home/ute/logs/APbip/set2/
     Sleep     10
     Collect And Check gnbBIP     /home/ute/logs/gNBbip/set3/
     Collect and check apBIP     /home/ute/logs/APbip/set3/
     Validate 4UE RANK2 NOT Paired in TTI logs
     Deactivate RIMRS FW1
     Sleep   100s
     Log to console     Waiting for 7527 RIMRS alarm to be down
     Wait For Fault To Be Down     fault_id=7527   timeout=600
#    Till alarm check for down specific to cellid supported in taf5g below commented
     Deactivate RI
     Sleep   100s
     Log to console     Waiting for 7525 Remote Interference alarm to be down
     Wait For Fault To Be Down     fault_id=7525   timeout=700
     Start Logs     ${L_GNB_TTI}
     Sleep      1
     Stop Logs     ${L_GNB_TTI}
     Validate 4UE RANK2 Paired in TTI logs
     Validate 4 RANK2 Paired UE Data Rate     45
     CB008235 SA Deregister UE 1 to 4
