*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007308-5G_5GC000167
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB007308-5G_5GC000167/general.robot

Library    SSHLibrary   WITH NAME   ssh
Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library     taf.sbts.oam.coam.admin
Library     taf.transport.ssh
Library     taf.sbts.oam.coam.admin.admin   WITH NAME   admin_cli

Resource    ./keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/AirPhone/resources/ute/ute_wts_runner.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${reasoning_path_1937_left}=       /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${reasoning_path_1937_right}=      /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-1/RU_L-1

${RNCELL_path_left}=		       /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${RNCELL_path_right}=		       /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1

${scf_2_11_UTESRAN201}        /home/ute/MN/UTE/robotws/custom-config/2_11_UTESRAN201/SCFC.xml
${TRUNK_VERSION}=                 SBTS23R2

&{FAULT_4655}    fault_id=4655
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="Service account root access is enabled"
...              alarm_resource=MRBTS-1/MNL-1/MNLENT-1/SECADM-1

&{FAULT_61649}    fault_id=61649
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="LMP access via port 443"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4654}    fault_id=4654
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="Ethernet port security is disabled"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4681}    fault_id=4681
...              alarm_id=7111
...              alarm_severity=Major
...              alarm_description="Sanity Check Error"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4687}    fault_id=4687
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_description="CPRI RU Migration to eCPRI Mode Required"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1

&{FAULT_4334}    fault_id=4334
...              alarm_id=7116
...              alarm_severity=Major
...              alarm_description="Serial console activated"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1

&{FAULT_4592}    fault_id=4592
...              alarm_id=7115
...              alarm_severity=Warning
...              alarm_description="BTS Reset Cause"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_61524}    fault_id=61524
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="SSH enabled"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_61652}    fault_id=61652
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="R&D Service Port enabled"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_7305}    fault_id=7305
...              alarm_id=7107
...              alarm_severity=Critical
...              alarm_description="NG SCTP setup fail"
...              alarm_resource=MRBTS-1/NRBTS-1/SERVEDAMF-1

&{FAULT_7300}    fault_id=7300
...              alarm_id=7107
...              alarm_severity=Major
...              alarm_description="No X2 link available"
...              alarm_resource=MRBTS-1/NRBTS-1

&{FAULT_7100}    fault_id=7100
...              alarm_id=7114
...              alarm_severity=Major
...              alarm_description="F1 Cell activation failed due to link unavailable"
...              alarm_resource=MRBTS-1/NRBTS-1/NRCELL-1

&{FAULT_7103}    fault_id=7103
...              alarm_id=7114
...              alarm_severity=Major
...              alarm_description="SA cell activation failed"
...              alarm_resource=MRBTS-1/NRBTS-1/NRCELL-1

&{FAULT_7523}    fault_id=7523
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_description="Cell Activation timeout at gNB-DU"
...              alarm_resource=MRBTS-1/NRBTS-1/NRCELL-1

&{FAULT_61050}    fault_id=61050
...              alarm_id=61050
...              alarm_severity=Critical
...              alarm_description="Missing SFP module on SMOD-1, EIF2"
...              alarm_resource=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-4

&{FAULT_61029}    fault_id=61029
...              alarm_id=61029
...              alarm_severity=Critical
...              alarm_description="LOS on SMOD-1, EIF3"
...              alarm_resource=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-3

&{FAULT_6450}    fault_id=6450
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_description="Diagnostic Files collected"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

@{ALLOWED_ALARMS}    &{FAULT_4654}   &{FAULT_4655}   &{FAULT_61649}   &{FAULT_61524}   &{FAULT_61652}   &{FAULT_61050}   &{FAULT_61029}
...    &{FAULT_7305}   &{FAULT_7300}   &{FAULT_7100}   &{FAULT_7103}   &{FAULT_7523}   &{FAULT_4681}   &{FAULT_4334}   &{FAULT_6450}   &{FAULT_4592}

*** Keywords ***
ASOE_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat
    log to console  Start test fault 1937
    Get reasoning path for 1937
    Wait Until Keyword Succeeds   600    60    ADMIN INFOMODEL Check If BTS Is OnAir
    Get Version Of Active SW
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    Perform activate service account synchronization to RU devices
    SYSTEM Check if fault is not in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    Check ReasoningStatus Empty for 1937
    ADMIN Check If Alarm Is Not Active  fault_id=1937

    log to console   trigger fault 1937 by change temperature
    Change temperature for trigger fault 1937

    Run Keyword and Continue on Failure   Check ReasoningStatus for 1937
    Sleep   10
    Run Keyword and Continue on Failure   SYSTEM Check if fault is in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    Run Keyword and Continue on Failure   ADMIN Check If Alarm Is Active  fault_id=1937
    Run Keyword and Continue on Failure   Check not uncommissioned state
    Sleep  10

    log to console   Cancel fault 1937
    Change temperature for cancel fault 1937
    Wait Until Keyword Succeeds    900    60    ADMIN Check If Alarm Is Not Active  fault_id=1937
    Check ReasoningStatus Empty for 1937
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
#    [Teardown]    Run Keyword And Ignore Error    Change temperature for cancel fault 1937

ASOE_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl
    log to console  Start test fault 4383
    Wait Until Keyword Succeeds    600    60    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383

#    Get Version Of Active SW
#    Run Keyword If  '${version}' == '${TRUNK_VERSION}'   Trigger Fault 4383 And Check Active Fault
#    Run Keyword If  '${version}' == 'SBTS22R2'   Trigger Fault 4383 And Should Have Been Raised
    Trigger Fault 4383 And Check Active Fault

    ${configured}   Run Keyword And Return Status   Wait Until Keyword Succeeds   600   10   ADMIN INFOMODEL Check If BTS Is Configured
    Run Keyword Unless   ${configured}    Wait Until Keyword Succeeds   30   10   ADMIN INFOMODEL Check If BTS Is Onair
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}

#---------------------------------------------------------------------
Test Preconditions
    Log
    ...    message=\n+ Stated Test PREconditions ${TEST_NAME}
    ...    console=yes
    LOGGING Start Logging
    ${out_mrbts_id}=    taf.sbts.oam.coam.admin.Get Bts Info
    Set Test Variable    ${OUT_MRBTS_ID}    ${out_mrbts_id['mrbtsID']}
    Log Variables
    Log
    ...    message=\n+ Finished Test PREconditions: ${TEST_NAME}
    ...    console=yes

Get Version Of Active SW
    ${split_build}=    Split string       ${OUT_ACTIVE_SW}    separator=\_
    ${version}=       Get from list    ${split_build}    0
    Set Suite Variable   ${version}

Get reasoning path for 1937
    ${RMOD_distname}    Get Object Distname From Class Name if List
    ...    class_name=RMOD_L
    ${RMOD_distname_1}=   get from list   ${RMOD_distname}   0
#    ${RMOD_distname_2}=   get from list   ${RMOD_distname}   1
    ${reasoning_path_1937_1}=   Set variable   ${RMOD_distname_1}/RU_L-1
#    ${reasoning_path_1937_2}=   Set variable   ${RMOD_distname_2}/RU_L-1
    Set test variable   ${reasoning_path_1937_1}
#    Set test variable   ${reasoning_path_1937_2}

Check ReasoningStatus Empty for 1937
    Wait Until Keyword Succeeds    900    60    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_1937_1}
#    Wait Until Keyword Succeeds    900    60    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
#    ...    dist_name=${reasoning_path_1937_2}

Check ReasoningStatus for 1937
#    ${is_present}    Run Keyword And Return Status
    Wait Until Keyword Succeeds
    ...    300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_1937_1}
    ...    value=DangerouslyOverheated
#    Run Keyword Unless    ${is_present}    Wait Until Keyword Succeeds
#    ...    300  60  ADMIN INFOMODEL Check ReasoningStatus Value
#    ...    dist_name=${reasoning_path_1937_2}
#    ...    value=DangerouslyOverheated

Check if fault is not in active raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   taf.sbts.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should not contain  ${RawAlamrsActive}  (${fault_id})
    Should not contain  ${RawAlamrsActive}  ${EFaultId}

Generate fault ${fault_id} on RMOD
    Telnet.Open Connection  192.168.200.1  port=8023  prompt=>  newline=LF
    Telnet.Execute Command  trigger_rf_fault 0 ${fault_id} module MAJ
    Sleep	5s
    Telnet.Close All Connections

Disable fault ${fault_id} on RMOD
    Telnet.Open Connection  192.168.200.1  port=8023  prompt=>  newline=LF
    Telnet.Execute Command  cancel_rf_fault 0 ${fault_id} module
    Sleep	5s
    Telnet.Close All Connections

Reset and on configured
    admin.ADMIN Reset Site
    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Configured

Get Object Distname From Class Name
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
        ${distName}    Get From Dictionary    ${element}    distName
    END
    [Return]    ${distName}

Get Object Distname From Class Name if List
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    @{distname_list}   create list
    FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
        ${distName}    Get From Dictionary    ${element}    distName
        append to list   ${distname_list}   ${distName}
    END
    [Return]    ${distName_list}

Trigger Fault 4383 And Check Active Fault
    Log To Console    Fault 4383 Trigger And Should Be Raised
    ssh.Open Connection    host=192.168.255.1    port=22    timeout=60
    ssh.Login    username=toor4nsn    password=oZPS0POrRieRtu    delay=1s
    ssh.Write    pkill -11 -f '/ffs/run/devicecfg/containers/FHNETNODE'
    ssh.Close Connection
    wait until keyword succeeds   60    10    ADMIN Check If Alarm Is Active  fault_id=4383
    Wait Until Keyword Succeeds
    ...               5 min
    ...               5 sec
    ...               keywords.Check not uncommissioned state
    Sleep  30

Check If BTS Configured
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Configured

Perform activate service account synchronization to RU devices
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            parameter=actSyncToRU
    ...                                            operation=update
    ...                                            value=true
    ...                                            skip_parameter_relation_errors=True

Change temperature for trigger fault 1937
    ssh.Open Connection    host=192.168.255.1    port=22    timeout=60
    ssh.Login    username=toor4nsn    password=oZPS0POrRieRtu    delay=1s
    ssh.Write    cat /ffs/run/config/FRIps.txt
    ${FRIps}=    ssh.Read Until    expected=>
    ${splitFRIps}=    Split string       ${FRIps}    separator=\;
    ${ip_rmod}=     Get from list       ${splitFRIps}     2
    ssh.Write    lxc-ls
    ${virtual_nodes}    ssh.Read Until    expected=>
    ${split_VN}=    Split string       ${virtual_nodes}    separator=\
    ${fhnet_container}=     Get from list       ${split_VN}     0
    ssh.Write    lxc-attach -n ${fhnet_container}
    ssh.Read Until    expected=>
    ssh.Write    ssh serviceuser@${ip_rmod}
    ssh.Read Until    expected=?
    ssh.Write    yes
    ssh.Read Until    expected=password:
    ssh.Write    Pl(FzaYj5~c5;q
    ssh.Read Until    expected=$

    ssh.Write    echo /ca action terminate |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write    echo /trx1 action terminate |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write    echo / action create ThermometerDevice /trx1 /temp/bmFpga1/tcxo |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write    echo / action create ConfigAccess /ca /module |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write    echo /ca action fetch DECODED \\"tempest_inst1.bin\\" \\"/var/tmp/tempest_inst1.json\\" |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write    echo /ca action fetch DECODED \\"tcs.bin\\" \\"/var/tmp/tcs_default.json\\" |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write     sudo cat /var/tmp/tempest_inst1.json|grep tempOffset
    ${tempOffset}=    ssh.Read Until     expected=$
    log to console   ${tempOffset}
    Run Keyword If  '${version}' == 'SBTS22R3'  ssh.Write   sudo sed -i 's/"tempOffset": 0,/"tempOffset": 85,/g' /var/tmp/tempest_inst1.json
    ...    ELSE    ssh.Write   sudo sed -i 's/"tempOffset": 0.0,/"tempOffset": 85.0,/g' /var/tmp/tempest_inst1.json
    ssh.Read Until     expected=$
    ssh.Write     sudo cat /var/tmp/tempest_inst1.json|grep tempOffset
    ${tempOffset}=    ssh.Read Until     expected=$
    log to console   ${tempOffset}
    ssh.Write    echo /ca action store TEMPORARY DECODED \\"tempest_inst1.bin\\" \\"/var/tmp/tempest_inst1.json\\" |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write    echo /ca action update |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write    echo /trx1 action override TEMPERATURE 85 |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Close Connection

Change temperature for cancel fault 1937
    ssh.Open Connection    host=192.168.255.1    port=22    timeout=60
    ssh.Login    username=toor4nsn    password=oZPS0POrRieRtu    delay=1s
    ssh.Write    cat /ffs/run/config/FRIps.txt
    ${FRIps}=    ssh.Read Until    expected=>
    ${splitFRIps}=    Split string       ${FRIps}    separator=\;
    ${ip_rmod}=     Get from list       ${splitFRIps}     2
    ssh.Write    lxc-ls
    ${virtual_nodes}    ssh.Read Until    expected=>
    ${split_VN}=    Split string       ${virtual_nodes}    separator=\
    ${fhnet_container}=     Get from list       ${split_VN}     0
    ssh.Write    lxc-attach -n ${fhnet_container}
    ssh.Read Until    expected=>
    ssh.Write    ssh serviceuser@${ip_rmod}
    ssh.Read Until    expected=password:
    ssh.Write    Pl(FzaYj5~c5;q
    ssh.Read Until    expected=$

    Run Keyword If  '${version}' == 'SBTS22R3'  ssh.Write   sudo sed -i 's/"tempOffset": 85/"tempOffset": 0/g' /var/tmp/tempest_inst1.json
    ...    ELSE    ssh.Write   sudo sed -i 's/"tempOffset": 85.0/"tempOffset": 0.0/g' /var/tmp/tempest_inst1.json
    ssh.Read Until     expected=$
    ssh.Write    sudo cat /var/tmp/tempest_inst1.json|grep tempOffset
    ${tempOffset}=    ssh.Read Until     expected=$
    log to console   ${tempOffset}
    ssh.Write    echo /ca action store TEMPORARY DECODED \\"tempest_inst1.bin\\" \\"/var/tmp/tempest_inst1.json\\" |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write    echo /ca action update |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write    echo /trx1 action override OFF |frmonShellClient 127.0.0.1 2000
    ssh.Read Until     expected=$
    ssh.Write   sudo reboot --reboot
    ssh.Read Until     expected=$
    ssh.Close Connection

2_11_UTESRAN201 TL Preparation
    PREPOST Setup Admin
    ADMIN Perform Commissioning
    ...     scf_file=${scf_2_11_UTESRAN201}   skip_parameter_relation_errors=${True}
    Wait Until Keyword Succeeds  600  10   ADMIN Check BTS Configured
    Sleep   30
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords   Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found. Wait for onAir State
    ADMIN Teardown Admin

UTE TL Preparation
    [Documentation]  Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  CB007308-5G_5GC000167.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    PREPOST Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...   scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ...   skip_parameter_relation_errors=${True}
    ${configured}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords
    ...    Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
