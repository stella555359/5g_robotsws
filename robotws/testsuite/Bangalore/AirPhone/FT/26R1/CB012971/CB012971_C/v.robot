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
     Start SOS with BIP     ${sos_script_path}
     Stop and collect SOS       ${sos_script_path}      ${TC_DIR_CB012971_C_02}
