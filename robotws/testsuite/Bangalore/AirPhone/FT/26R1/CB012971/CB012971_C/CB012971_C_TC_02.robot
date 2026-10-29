*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This script is to validate CB012971
                 ...                               test cases
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,10.08.2025,vadivelan.manickavasagam@nokia.com

Resource          ../resources/Keywords/CB012971_Keywords.robot
Resource          ../../../resources/Variables/general_common_variables.robot
Resource          ../resources/Variables/CB012971_variables.robot
Suite Setup       CB012971 Suite Setup        ${TC_DIR_CB012971_C_02}
Suite Teardown    CB012971 Suite Teardown     ${TC_DIR_CB012971_C_02}

*** Test Cases ***
CB012971_C_TC02_4UE_MUPAIRING
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,15.08.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify 4 UE DLMU PAIRING in SBSRS  UEs
         ...    Make sure DLMU PAIRED using GNB TTI logs and DL Data rate almost double
     ${vendor_update}=    Set Variable    yes
#APS #0x58078F=1 #RZV 0x5901BD=0 #rdEnableSbBfDlMuMimoL2 #0x58013E=1  #rdDlMuInfFactor #0x580553=0 #rdDlEnableReTxUeMu #0x580540=0
     Add Rad Param Or Modify GNB swconfig     0x8000a6=0
     Add Rad Param Or Modify AP swconfig     0x10043=51011     0x10040=1
     Get cell On Air     iphy=${CFG_CB012971_A_TC_02_IPHY}     scf_delta=${CFG_CB012971_C_TC_00_GNB_SCF}
     ...     cfg=${CFG_CB012971_A_TC_02_WTS}
     ...     vendor_update=${vendor_update}
#     ...     bsr=${BSR_FILE_CB012971_AVQL}
     Start SOS with BIP     ${sos_script_path}
     Sleep      300
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Collect And Validate      log=${L_AP_SYS}      element=${VAL_UL_SB_SRS_ENABLED}
     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
     Collect And Validate      log=${L_AP_SYS}      element=${VAL_UL_SB_SRS_SIZE_2}
     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
     CB012971 SA Call UE1 to UE4
     CB012971 4UE PROFILE POS ACT
     Start Logs     ${L_GNB_TTI}
     Sleep      2
     Stop Logs     ${L_GNB_TTI}
#    verify DLMUMIO 4 UE DATA RATE
     DLMUPAIR
#    verify DLMUMIMO Pairing and SBSRS
     DLMUPAIRTTI
     CB012971 SA Deregister UE 1 to 4
#     Stop and collect SOS       ${sos_script_path}      ${TC_DIR_CB012971_C_02}
