*** Settings ***
Documentation
...    Author: Izabela Muntean (izabela.muntean@nokia.com)
...    Maintainer: Izabela Muntean (izabela.muntean@nokia.com)
...    Group in charge: RAN_BOAM_VERIF
...    References: doors
...    Feature Description: CB007487
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/RP003279_CB007487/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          FALSE
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True


${SW_DESTINATION}     /home/ute

&{FAULT_4655}    fault_id=4655
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="Service account root access is enabled"
...              alarm_resource=MRBTS-10793/MNL-1/MNLENT-1/SECADM-1

&{FAULT_61649}    fault_id=61649
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="LMP access via port 443"
...              alarm_resource=MRBTS-10793/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4654}    fault_id=4654
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="Ethernet port security is disabled"
...              alarm_resource=MRBTS-10793/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4681}    fault_id=4681
...              alarm_id=7111
...              alarm_severity=Major
...              alarm_description="Sanity Check Error"
...              alarm_resource=MRBTS-10793/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_61524}    fault_id=61524
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="SSH enabled"
...              alarm_resource=MRBTS-10793/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_61652}    fault_id=61652
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="R&D Service Port enabled"
...              alarm_resource=MRBTS-10793/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_1837}    fault_id=1837
...              alarm_id=7113
...              alarm_severity=Major
...              alarm_description="VSWR major alarm"
...              alarm_resource=MRBTS-10793/EQM_R-1/APEQM_R-1/RMOD_R-1/ANTL_R-5

@{ALLOWED_ALARMS}    &{FAULT_4655}   &{FAULT_61649}   &{FAULT_61524}   &{FAULT_61652}   &{FAULT_4681}
...                  &{FAULT_1837}   &{FAULT_4654}


*** Keywords ***

CB007487_Capacity_unit_Hot_remove_CPRI
    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    Disconnect_Connect_BBMOD
    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}

Disconnect_Connect_BBMOD
    SYSTEM Execute Command On gNB
    ...    command=echo 1 >/dev/ddal/power/slot_id_01/board_pwr_shutdown
    Sleep  5s
    SYSTEM Execute Command On gNB
    ...    command=echo 0 >/dev/ddal/power/slot_id_01/board_pwr_shutdown
#   ${content}=  SYSTEM Execute Command On gNB
#    ...    command=df -h
#    ${status}   Run Keyword And Return Status  should contain   ${content}    100% /ffs/fs1
#    Run Keyword Unless   ${status}   should contain   ${content}
#    ...                     100% /ffs/fs2



