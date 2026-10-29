*** Settings ***
Documentation    :copyright: Nokia
Force Tags    CLOUD_R4MAPN_CUS    CRT   SBTS00

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
${coco}=        ${CURDIR}/config/CNI133565_TC5_coco.yaml
${scfc}=        CNI133565_TC5_scf.xml
${ADDRESS}     192.168.255.1
${PORT}        3600
${USE_SSL}     True

*** Test Cases ***

CNI-133565_TC5_Successful_addition_of_firewall_rules_for_CP_UP_IP_addresses_obtained_during_SgNBModification_Procedure_intraMeNBHO
    [Setup]    Setup testline_B        ${coco}    ${scfc}
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
    [teardown]    Detach all UEs
