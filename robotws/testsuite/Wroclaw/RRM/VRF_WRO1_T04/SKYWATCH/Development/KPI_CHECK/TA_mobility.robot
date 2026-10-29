*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00

Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Variables    ta5g_global_var
Resource    resources/5G_SW_WRO_Keywords.robot
#Resource    ../CB009086/resources/9086_keywords.robot
Resource    resources/Skywatch_keywords.robot
#Resource    ../CB007813/connect.robot
Resource    resources/KPI_related_keywords.robot
#Resource     resources/9086_keywords.robot
#Library    resources/9086_keywords.py
#Resource    resources/BIP_logs.robot
#Resource    ../../../../Ulm/resources/Common/bip_trace.robot
#Resource    ../../../../Ulm/resources/Common/bip_trace_ap.robot
Library    resources/KPI_related_keywords.py
Library    resources/tput_scen.py
Library    resources/Python/webem_alarms.py
Library    resources/TA_mobility.py

#Library    CB008367.py
#Library    ../CB007813/CB007813-B_keywords.py
#Library    ../CB007813/vendor_file_modifier.py
#Resource     resources/configuration_id.robot


#Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
#    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_1AEQE_GSCN_7853.xml
#    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
#    ...        AND             Find Scfc And Fix And Send Full Commissioning
#    ...                        scfc_filename=full_CB008367_A_B8_alt.xml
#    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
Suite Setup    Run Keywords    Check Radios Availability
#    ...        AND             Check Radios Availability
...        AND             Reach Onair    lua_cfg=${LUA_CFG_59}
#    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND            Sleep    1s
#    ...        AND             Start BIP Traces
#    ...        AND             Start Airphone BIP Traces

Test Teardown    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#Test Teardown    Run Keywords    Deregister 1 UEs
#    ...        AND               Stop BIP Traces
#    ...        AND               Stop Airphone BIP Traces
#    ...        AND               Deregister 1 UEs
#    ...        AND               Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#...    AND    Send Configuration ID To Scout

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x5808FF=2
#@{mplane_cells}=    ${5}    ${6}    ${9}    ${12}
${ue_cell}=    201
${LUA_CFG_59}    /home/ute/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/Main/config_59/cfg_skywatch_tmo_59.lua

*** Test Cases ***
NR_5101b_CHECK
#    Find Scfc and Send Delta Commissioning    scfc_filename=TAcounters.xml

    ute_wtssim.execute_egate_command    cmd=ue_change_location id=1 cell=${ue_cell}
#    Wait For Next Raw Pm Interval
#    Start BIP Traces
#    Start Airphone BIP Traces
    Activate TA Testmode
    FOR  ${i}  IN RANGE  20
        Attach For Ues
        ...    ues=${1}
        Pdu Session For Ues
        ...    ues=${1}
        ...    pass_regex=Established PDU session
        Start 1 Mbps Uplink Traffic For UEs 1-1
        Start Downlink Traffic 1 Mbps For UEs 1-1
        Sleep    2s
        Display Actual Traffic For UEs 1-1
        Deregister 1 UEs
#    ${list_of_counters}=    Prepare Counter List
#                            ...  counter=M55307C02001
#    Wait For Next Raw Pm Interval
#    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
#
#    FOR    ${counter}     IN      @{list_of_counters}
#    ${counter_value}=    Get Latest Pm Counter Value
#    ...    counter_id=${counter}
#    ...    local_moid=PLMN-PLMN/MRBTS-55203/NRBTS-55203/NRCELL-${ue_cell}
#    ...    filepath=${PM_COUNTERS}
#    Log to console    ${counter} = ${counter_value}
    END
#
#    Deactivate TA Testmode
#    BuiltIn.Fail    msg=Expected failure

*** Keywords ***
Activate TA Testmode
    [Arguments]    ${ue_id}=1
    Log to Console      Activating TA Testmode
    ${cmd}    Set Variable
    ...    ue_ta_nr profile_id=1 ue_p_delay_initial=864 ue_p_delay_min=704 ue_p_delay_max=1000 ue_speed=5 nb_reps_ta_sim=1
    ute_wtssim.execute_egate_command    cmd=${cmd}
    ${cmd}    Set Variable
    ...    ue_ta_nr profile_id=2 ue_p_delay_initial=100 ue_p_delay_min=100 ue_p_delay_max=200 ue_speed=5 nb_reps_ta_sim=1
    ute_wtssim.execute_egate_command    cmd=${cmd}
    ${cmd}    Set Variable
    ...    ue_ta_nr profile_id=3 ue_p_delay_initial=300 ue_p_delay_min=300 ue_p_delay_max=400 ue_speed=5 nb_reps_ta_sim=1
    ute_wtssim.execute_egate_command    cmd=${cmd}
    ${cmd}    Set Variable
    ...    ue_testmode_set_nr id\=${ue_id} scell\=0,1,2,3 testmode\=ta profile_id\=1 action\=activate
    ute_wtssim.execute_egate_command    cmd=${cmd}

Deactivate TA Testmode
    [Arguments]    ${ue_id}=1
    Log to Console      Deactivating TA Testmode
    ${cmd}    Set Variable
    ...    ue_testmode_set_nr id\=${ue_id} scell\=0,1,2,3 testmode\=ta profile_id\=1 action\=deactivate
    ute_wtssim.execute_egate_command    cmd=${cmd}
