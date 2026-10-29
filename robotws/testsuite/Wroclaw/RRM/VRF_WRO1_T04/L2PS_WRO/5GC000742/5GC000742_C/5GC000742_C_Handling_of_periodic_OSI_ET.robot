*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO   VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :author: Jakub Gabrys
...              :contact: jakub.gabrys@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_tshark
Library      ta5g_egate
Library      ta5g_commissioning
Variables    ta5g_global_var

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
${SIB2_PERIODICITY_RF16}=    ${F1AP_GNB_CONFIGURATION_UPDATE} && ((nr-rrc.si_Periodicity == 1) && (nr-rrc.type == 0))
${SIB3_PERIODICITY_RF32}=    ${F1AP_GNB_CONFIGURATION_UPDATE} && ((nr-rrc.si_Periodicity == 2) && (nr-rrc.type == 1))
${SIB4_PERIODICITY_RF64}=    ${F1AP_GNB_CONFIGURATION_UPDATE} && ((nr-rrc.si_Periodicity == 3) && (nr-rrc.type == 2))
${SIB5_PERIODICITY_RF128}=   ${F1AP_GNB_CONFIGURATION_UPDATE} && ((nr-rrc.si_Periodicity == 4) && (nr-rrc.type == 3))
${ALL_SIBPERIODICITY_VALUES}=    ${SIB2_PERIODICITY_RF16}  and  ${SIB3_PERIODICITY_RF32}  and
...    ${SIB4_PERIODICITY_RF64}  and  ${SIB5_PERIODICITY_RF128}
${SIBPERIODICITY_RF8}=    ${F1AP_GNB_CONFIGURATION_UPDATE} && (nr-rrc.si_Periodicity == 0) &&
...    (nr-rrc.type == 0) && (nr-rrc.type == 1) && (nr-rrc.type == 2) && (nr-rrc.type == 3)


*** Test Cases ***
5GC000742_C_1_Handling_Of_Different_Periodicity_ET
    Verify Sibperiodicity Before Values Are Changed
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_periodicity_sib2_sib3_sib4_sib5.json
    Verify Sibperiodicity After Values Are Changed

*** Keywords ***
Verify Sibperiodicity Before Values Are Changed
    Verify Tcpdump Log
    ...    packet_filter=${SIBPERIODICITY_RF8}
    ...    number_of_messages=1    relation_symbol=>=

Verify Sibperiodicity After Values Are Changed
    Verify Tcpdump Log
    ...    packet_filter=${ALL_SIBPERIODICITY_VALUES}
    ...    number_of_messages=1    relation_symbol=>=
