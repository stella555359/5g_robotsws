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

Resource          ../resources/Keywords/FT_LEGACY_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ../resources/Variables/FT_LEGACY_Variables.robot
Suite Setup       FT_LEGACY Suite Setup         ${TC_DIR_FT_LEGACY}
Suite Teardown    FT_LEGACY Suite Teardown      ${TC_DIR_FT_LEGACY}

*** Test Cases ***
FT Legacy SA Multiple UE
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,28.03.2026,vadivelan.manickavasagam@nokia.com
         ...    To verify 16 Multiple UEs
     ${vendor_update}=    Set Variable    yes
#APS #0x58078F=1 #RZV 0x5901BD=0 #rdEnableSbBfDlMuMimoL2 #0x58013E=1  #rdDlMuInfFactor #0x580553=0 #rdDlEnableReTxUeMu #0x580540=0
     Add Rad Param Or Modify GNB swconfig     0x8000a6=0
     Add Rad Param Or Modify AP swconfig     0x10043=51011     0x10040=1
     Set Pet Config      ${FT_LEGACY_PET_B_CFG_DIR}
     PET Get cell On Air     iphy=${CFG_FT_LEGACY_IPHY}     scf_delta=${CFG_FT_LEGACY_GNB_SCF}
     ...     cfg=${CFG_SANSA_LUA}
     ...     vendor_update=${vendor_update}
#     ...     bsr=${CFG_BSR_FILE_AVQL}
#     Start SOS with BIP     ${sos_script_path}
     Sleep      400
     PET FT LEGACY SA Call    ${CFG_FT_LEGACY_SCRIPT_SA_16UE}
#     Stop and collect SOS       ${sos_script_path}      ${TC_DIR_CB012971_C_02}
