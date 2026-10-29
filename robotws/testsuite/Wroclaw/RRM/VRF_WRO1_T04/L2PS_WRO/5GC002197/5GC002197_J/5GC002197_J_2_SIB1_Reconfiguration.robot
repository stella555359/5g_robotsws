*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO   VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Jakub Gabrys
...              :contact: jakub.gabrys@nokia.com

Variables    ta5g_global_var
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_egate
Library      ta5g_tshark
Library      ta5g_pm_counters
Resource     ../../resources/configuration_id.robot

Resource     ../../resources/5G_SW_WRO_Keywords.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_default_scf_ABIP.xml
    ...        AND             Check Radios Availability
    ...        AND             Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.112/24
    ...        AND             Start Default Logging And Reach Onair
    ...                        lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
    ...                        output_dirpath=${OUTPUT_DIR}

Suite Teardown      Run Keywords     Print Active Alarms
    ...             AND      Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${T300_400ms_packet_filter} =     nr-rrc.t300 == 3
${T300_600ms_packet_filter} =     nr-rrc.t300 == 4

*** Test Cases ***
5GC002197_J_2_SIB1_Reconfiguration
    [Documentation]   Correct handling of SIB1 Reconfiguration via online parameter.

    Verify Tcpdump Log       packet_filter=${T300_400ms_packet_filter}    number_of_messages=2
    Verify Tcpdump Log       packet_filter=${F1AP_GNB_CONFIGURATION_UPDATE}    number_of_messages=2
    Verify Tcpdump Log       packet_filter=${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE}    number_of_messages=2
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=t300    value=600ms
    Verify Tcpdump Log       packet_filter=${F1AP_GNB_CONFIGURATION_UPDATE}    number_of_messages=3
    Verify Tcpdump Log       packet_filter=${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE}    number_of_messages=3
    Verify Tcpdump Log       packet_filter=${T300_600ms_packet_filter}    number_of_messages=1
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55150C00040    >0    F1_CU_DU_CNF_UPD_RCVD
        ...    M55150C00053    >0    F1_CU_DU_CNF_UPD_RCNF
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${pm_counter_file}
    [Teardown]    Send Configuration ID To Scout
