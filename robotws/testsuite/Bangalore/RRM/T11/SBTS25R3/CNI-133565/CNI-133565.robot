*** Settings ***
Documentation    :copyright: Nokia
Force Tags    CLOUD_R4MANO_CUS    CRT   SBTS00


Library     OperatingSystem
Library     ta_uexgate
Library     taf.ul.ue.sim.env_setup
Library     BuiltIn
Library     String
Library     SSHLibrary
Library     Collections
Library     ta_messaging
Library		taf.sw.syslog
Library     taf.sw.wtssim
Library		taf.sbts.oam.coam.admin
Resource    ${CURDIR}/resources/CNI-133565_keywords.robot
Resource     ../../../../resources/robot/configuration_id.robot



*** Variables ***
${coco_TC1}=        ${CURDIR}/config/coco.yaml
${scfc_TC1}=        oam_controlled_SCF.xml
#@{swconfig_flags}=      ${REDUCE_S1_RECONNECTION_TIME}     @{ENABLE_CPLANE_DEBUG_LOGS}
#${REDUCE_S1_RECONNECTION_TIME}=    0x0015001B=15
${ADDRESS}     192.168.255.129
${PORT}        3600
${USE_SSL}     True
${delta_configuration}     ${CURDIR}/config/SBTS00/Delta_Add_LNADJGNB-1.json
${delta_Remove}      ${CURDIR}/config/SBTS00/Delta_Remove_LNADJGNB-1.json
${coco_m}=        ${CURDIR}/config/coco_cplane_mod.yaml
${scfc_m}=        oam_controlled_SCF.xml
${delta_cplane_modification}     ${CURDIR}/config/SBTS00/Delta_CPlane_modification.json
${coco_TC2}=        ${CURDIR}/config/coco.yaml
${scfc_TC2}=        CNI133565_TC5_scf.xml

*** Test Cases ***

CNI-133565_TC1_verify_addition_modification_removal_of_firewall_rules_for_IP_addresses_of_X2_to_en-gNB_links_oam_controlled
    Setup testline_A        ${coco_TC1}    ${scfc_TC1}
    Unlock LNADJGNB-0 Object
    Verify that LNADJGNB x2ToGnbLinkStatus is available on BTS1
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting
    Start syslog_unlock_uplane
    Attach UE1 to CELL1 and check SgNBAdditionRequest
    Verify if bearer-type change from MCG to SCG-split is successfull
    Verify if firewall_open is seen for LNADJGNB-0 in syslog_unlock_uplane
    Create LNADJGNB-1 MOC
    Verify that LNADJGNB x2ToGnbLinkStatus is available on BTS1
    Start syslog_addition_uplane
    Attach UE2 to CELL2 and check SgNBAdditionRequest
    Verify if bearer-type change from MCG to SCG-split is successfull
    Verify if firewall_open is seen for LNADJGNB-1 in syslog_addition_uplane
    Start syslog_deletion_uplane
    Delete LNADJGNB-1 MOC from BTS
    Verify if firewall_close is seen in syslog_deletion_uplane
    Run UEx command    ue_detach    all
####    CPLANE modification
    Setup testline_Cplane_modification      ${coco_m}
    Execute Egate command     cmd=link_lock link=x2 at=enb:3 to=enb:1    alias=TC1
    Start syslog_cplane_modification_uplane
    Change CPlane IP for LNADJGNB-0 Object
    Run UEx command    ue_prefered_nr_cell id=1 nr_pci=385 gnb_id=4 cell_id=41
    Attach UE1 to CELL1 and check SgNBAdditionRequest
    Verify if bearer-type change from MCG to SCG-split is successfull
    Verify if firewall_open is seen for new IP and firewall_close is seen for old IP in syslog_cplane_modification_uplane

CNI-133565_TC5_Successful_addition_of_firewall_rules_for_CP_UP_IP_addresses_obtained_during_SgNBModification_Procedure_intraMeNBHO
    [Setup]    Setup testline_B        ${coco_TC2}    ${scfc_TC2}
    Start syslog_cplane_addition
    Trigger sim_eNB to inform MME-1 about connected gNB    2    TC2
    Trigger sim_eNB to inform MME-1 about connected gNB    3    TC2
    Unlock LNADJGNB-2 Object
    Unlock LNADJGNB-3 Object
    Verify that LNADJGNB x2ToGnbLinkStatus is available on BTS1
    Verify if firewall_open is seen for LNADJGNB-2 and LNADJGNB-3 in syslog_cplane_addition
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting
    Start syslog_sgnb_addition
    Attach UE_1 to the Cell_1 and check for SgNBadditionRequest
    Verify if bearer-type change from MCG to SCG-split is successfull
    Verify if firewall_open is seen for LNADJGNB-3 in syslog_sgnb_addition
#   Handover to Cell2 to trigger SgnbModification
    Start syslog_sgnb_modification
    Handover UE1 to CELL2 and check SgnbModificationRequest
    Verify if bearer-type change from MCG to SCG-split and SGNB modification is successfull
    Verify if firewall is already opened for LNADJGNB-3 in syslog_sgnb_modification
    [teardown]    run keywords    Detach all UEs
                           ...    AND
                           ...    teardown_all_aliases_for_syslog
