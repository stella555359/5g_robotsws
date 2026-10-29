*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :author: Pawel Gniewek
...              :contact: pawel.gniewek@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_tshark
Library      ta5g_egate
Library      ta5g_commissioning

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_default_scf.xml
    ...        AND             Check Radios Availability
    ...        AND             Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.112/24
    ...        AND             Start Default Logging And Reach Onair
    ...                              lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
    ...                              output_dirpath=${OUTPUT_DIR}
    ...        AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_reconfiguration_sib2_sib3_sib4_sib5.json

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

Test Template    Verify Tcpdump Log


*** Variables ***
${QHYST}=    nr-rrc.q_Hyst == 1
${PCIBLACKLIST}=    nr-rrc.intraFreqExcludedCellList == 1
${THRESHXHIGHP}=    nr-rrc.threshX_HighP == 31
${PMAXEUTRA}=    nr-rrc.p_MaxEUTRA == 24

*** Test Cases ***                                       PACKET_FILTER
5GC000742_C_3_Reconfiguration_And_Encoding_Of_Sib2_ET    ${QHYST}           number_of_messages=1    relation_symbol=>=

5GC000742_C_4_Reconfiguration_And_Encoding_Of_Sib3_ET    ${PCIBLACKLIST}    number_of_messages=1    relation_symbol=>=

5GC000742_C_5_Reconfiguration_And_Encoding_Of_Sib4_ET    ${THRESHXHIGHP}    number_of_messages=1    relation_symbol=>=

5GC000742_C_6_Reconfiguration_And_Encoding_Of_Sib5_ET    ${PMAXEUTRA}       number_of_messages=1    relation_symbol=>=
