*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    SBTS23R1    RAN_5G    RAN_5G_TDD


Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    ta5g_egate
Library    ta5g_ue_mobility
Library    ta5g_setups_and_teardowns
Library    taf.collectors.tcpdump    WITH NAME    tcpdump

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AZQI_LokiB_8985_2.xml
#    ...                        swconfig_flags_list=@{CB008985}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB008985_A3_1SC_2SB_1070_100M_2x2_LokiB.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_SA.cfg


Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
#@{CB008985}=    0x59008A = 1 # rdTRSSlotAligned
#    ...			0x420062 = 1 # rdNewTddCellSlotModel

${EGATE_CONSOLE_LOG}       /opt/iphy/latest/egate_console.log

*** Test Cases ***
CB008985-A_A3_FR1_TDD_SA_SIB_broadcast_in_all_subcells
    Create multi beam profiles and associate the UEs to the profiles created
    Attach SA UEs
    Wait For Egate Console Output    expected_message=UE1: IS IDLE   timeout=60s
    Wait For Egate Console Output    expected_message=UE2: IS IDLE   timeout=60s
    UEs Idle Mode exit

*** Keywords ***
Create multi beam profiles and associate the UEs to the profiles created
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 sbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=2 testmode=beam_control action=activate profile_id=2 beamaction=attach
    Sleep    10s

Attach SA UEs
    Attach Ue    ue_id=1
    sleep    10s
    Attach Ue    ue_id=2
    Sleep    10s

UEs Idle Mode exit
    Execute egate command   cmd=ue_im_exit id=1    pass_regexp=AMF-1: Reauthentication procedure is complete.
    Execute egate command   cmd=ue_im_exit id=2    pass_regexp=AMF-1: Reauthentication procedure is complete.


