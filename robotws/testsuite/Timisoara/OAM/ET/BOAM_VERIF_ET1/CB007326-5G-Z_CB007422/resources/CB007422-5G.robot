*** Settings ***
Documentation
...    Author: George Medesan (george.medesan@nokia.com)
...    Maintainer: Izabela Muntean (izabela.muntean@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET4
...    References: doors
...    Feature Description:CB007422-5G
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB007422-5G/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library      taf.transport.ssh   WITH NAME   csn

Resource    ../../../BOAM_VERIF_ET2/resources/admin.robot
Resource    ../../../BOAM_VERIF_ET2/resources/pretest_posttest.robot
Resource    ../../../BOAM_VERIF_ET2/resources/system.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${asik_addr}                     192.168.255.1
${asik_username}                 toor4nsn
${asik_password}                 oZPS0POrRieRtu

${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1

${scf_path}             /tmp/
${scf_name}             scf_file.xml

*** Keywords ***

CB007326-5G-Z_CB007422-1_Fault_4592_triggering_with_actFaultSignature
    Log to console   Perform Reset Site
    ADMIN Reset Site
    Check BTS Status is in Configured state after reset
    Check FaulID 4592

Check BTS Status is in Configured state after reset
    Sleep  30
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    wait until keyword succeeds  900s  100s   Check If BTS Configured

Check FaulID 4592
    wait until keyword succeeds  1300s  30s    ADMIN Check If Alarm Is Active  fault_id=4592
    Log to console   Fault 4592 is visible

Check FaulID 4383 is not present
    ADMIN Check If Alarm Is Not Active  fault_id=4383
    Log to console   Fault 4383 is not visible

Check FaulID 4383 is present
    wait until keyword succeeds  60     0.001    ADMIN Check If Alarm Is Active  fault_id=4383
    Log to console   Fault 4383 is visible

Stop container to trigger fault 4383
    SYSTEM Execute Command On gNB
    ...    command=pkill -11 -f '/opt/CCS/CCSDaemonExe --startup=nid=0x2511'

Check If BTS Configured
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Configured

Test Preconditions for CB007422
    Test Preconditions
    Log to console  actFaultSignature=True
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...                                  dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  parameter=actFaultSignature
    ...                                  value=true
    ...                                  operation=update
    ...                                  skip_parameter_relation_errors=True

Test Postconditions for CB007422
    Test Postconditions
    Log to console  actFaultSignature=False
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...                                  dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  parameter=actFaultSignature
    ...                                  value=false
    ...                                  operation=update
    ...                                  skip_parameter_relation_errors=True
