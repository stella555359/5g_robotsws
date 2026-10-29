*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py

Force Tags    CLOUD_5G_CLASSICAL_NSA_ASIB_3xAHGD    CA_RAN_PZ_HAZ_1    SBTS00    RAN_5G    RAN_5G_FDD    STATE_SW_UPLOADED

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{5G_CB008434_S1}=        HW_ID=5G_CB008434        ONAIR_TIME=20 min     site_mode=SA
...    peak_rate_config={"333":[750,65]}    iperf_type=via_command
&{5G_CB008434_S1_without_sleep}=        HW_ID=5G_CB008434        ONAIR_TIME=20 min     site_mode=SA
...    peak_rate_config={"333":[750,65]}    iperf_type=via_command
&{5G_CB008434_S2}=        HW_ID=5G_CB008434        ONAIR_TIME=20 min     site_mode=SA
...    peak_rate_config={"188":[750,65],"189":[750,65]}    iperf_type=via_command
&{5G_CB008434_S2_without_sleep}=        HW_ID=5G_CB008434        ONAIR_TIME=20 min     site_mode=SA
...    peak_rate_config={"188":[750,65],"189":[750,65]}    iperf_type=via_command

#
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset    Unit power reset
#${INIT_CONFIG_ID}


*** Test Cases ***
#[3]CB008434_04_supercell_Super cell Setup
#    [Timeout]    2h
#    [Tags]    QC_33268    QCD_MN_RAN  QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Cellsetup    config_id=5G_CB008434_S1
#    Supercell_Super_Cell_Setup
#    [Teardown]    Testcase Basic Postcondition

[1][2.0] CB008434_02_Common_SiSo_State Management_Sub-cell failure in super cell configuration
    [Timeout]    4h
    [Tags]    QC_33266    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cellfailure    config_id=5G_CB008434_S1_without_sleep
    Common_SiSo_State Management_Sub-cell failure in super cell configuration
    [Teardown]    Testcase Basic Postcondition

[1]CB008434_03_Super_Cell_Reconfiguration
    [Timeout]    5h
    [Tags]    QC_33267    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cellreconfig    config_id=5G_CB008434_S1
    SuperCell Reconfiguration
    [Teardown]    Testcase Basic Postcondition

#[2]CB008434_05_supercell_delete
#    [Timeout]    5h
#    [Tags]    QC_33269    QCD_MN_RAN  QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Celldelete    config_id=5G_CB008434_S1
#    SuperCell Reconfiguration To Norall
#    [Teardown]    Testcase Basic Postcondition

#[1]CB008434_04_supercell_Super cell Setup
#    [Timeout]    2h
#    [Tags]    QC_33270    QCD_MN_RAN  QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Cellsetup    config_id=5G_CB008434_S2
#    Supercell_Super_Cell_Setup
#    [Teardown]    Testcase Basic Postcondition

[1]CB008434_05_supercell_delete
    [Timeout]    4h
    [Tags]    QC_33271    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Celldelete    config_id=5G_CB008434_S2
    SuperCell Reconfiguration To Norall
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_RF module reset_Then_RAT_reset
    [Timeout]    2h
    [Tags]    QC_33272    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_RAT_Reset    config_id=5G_CB008434_S2_without_sleep
    Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell block_Then_resetBBMOD_Then_Cell unblock
    [Timeout]    2h
    [Tags]    QC_33273    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=BB_CELL_LOCK    config_id=5G_CB008434_S2_without_sleep
    Common_SiSo_State Management_cell Lock_Then_resetBBMOD_Then_cell unlock
    [Teardown]    Testcase Basic Postcondition

#[1][1.0] Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
#    [Timeout]    2h
#    [Tags]    QC_33275    QCD_MN_RAN  QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=RF_LOCK_RESET    config_id=5G_CB008434_S2_without_sleep
#    Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
#    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Timeout]    2h
    [Tags]    QC_33274    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_LOCK_RESET_BB    config_id=5G_CB008434_S2_without_sleep
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Teardown]    Testcase Basic Postcondition
