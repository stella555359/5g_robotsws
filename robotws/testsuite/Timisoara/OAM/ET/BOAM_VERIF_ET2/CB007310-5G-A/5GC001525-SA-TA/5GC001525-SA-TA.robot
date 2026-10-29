*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana
...    Maintainer: Zaharia Andreea-Oana
...    Test Description:

Library    SSHLibrary
##Library    ute_fault
Library    string
Library    ute_async
Library    collections
Library    Selenium2Library
Library    XML  lxml=True
Library    Process
Library     taf.sbts.oam.coam.admin
Library     taf.transport.ssh

Resource 	./OAM_Common.robot
Resource    ../../resources/system.robot
Resource   ../../resources/admin.robot
Resource   ../../resources/admin_infomodel.robot
#Resource    ../../resources/fault_trigger.robot

*** Variables ***
${fault_id_4383}=           4383
${EFaultId_4383}=           EFaultId_VirtualNodeNotRespondingAl
${source_fault4383}=         /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1/SOC_L-1/SW_NODE_L-1001
${reasoningStatus_4383}=     [stateInfo.reasoningStatus[?]="NodeStoppedUnexpectedly"]
${reasoning_path_4383}=      /MRBTS-1/RAT-1/BTS_L_1/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1/SOC_L-1/SW_NODE_L-*
${RNCELL_path}=			     /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${fault_id_28}=           28
${EFaultId_28}=           EFaultId_SwPackageAl
${CORRUPT_SW_PATH}       /home/ute/Documents/fault28/
${CORRUPT_SW_VERSION}    Airscale_corrupted.zip  #AirScale-0.816.318.zip    # AirScale-6.8351.764.zip
#${VALIDATED_SW_PACKAGE_PATH}       /home/ute/Downloads/
#${VALIDATED_SW_PACKAGE_VERSION}    AirScale-0.890.209.zip
${reasoning_path_28}=            /MRBTS-1/RAT-1/SWM-1
${source_fault28}=               /MRBTS-1/RAT-1/SWM-1
#${reasoningStatus_28}=     [stateInfo.reasoningStatus[?]="StorageFileCRC_Failure"]
${reasoningStatus_28}=     StorageFileCRC_Failure
${result_failed}=            [swDownloadInfo.result[?]="Failed"]
${state_finished}=           [swDownloadInfo.state[?]="Finished"]
${SYSTEM_ENB_TRANSPORT_IP}      192.168.255.129
${SW_DESTINATION}     /home/ute

${fault_id_1850}=           1850
${EFaultId_1850}=           EFaultId_SwCorruptedAl
${reasoning_path_1850}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1/STORAGE_L-1/FILE_SYSTEM_L-1/BUILD_DATA_L-1
${source_fault1850}=               /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1/STORAGE_L-1/FILE_SYSTEM_L-1/BUILD_DATA_L-1
${reasoningStatus_1850}=     SwCorrupted
${cell_status_path}=           /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/NRBTS_M-1/CELL_M-0
${rmod_status_path}=           /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
${frmon}=                   frmonShellClient 127.0.0.1 2000
${core_dump}=               /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-*/SMOD_L-1/CCU_L-1/STORAGE_L-*/FILE_SYSTEM_L-*/CORE_DUMP_L-*

&{F1850}         fault_id=1850
...              alarm_id=7111
...              alarm_severity=Critical
...              fault_name="SW corrupted"
...              notifier=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

${alarm_resource}=      /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

#${pma_process} =             pmagentproxy
${alarm_severity_Warning}=   Warning
${alarm_number_7101}=        7101

${fault_id_1937}=           1937
${EFaultId_1937}=           EFaultId_FrDangerouslyOverheat
${alarm_path}=               /MRBTS-1/RAT-1/FRI-1/ALARM-*
${recovery_reset_ind_path}=  /MRBTS-1/RAT-1/FRI-1/RECOVERY_RESET_IND-1
${cpath}=                    /MRBTS-1/RAT-1//LNBTS-1/CPLANE-1
${source_fault1937}=         /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${reasoningStatus_1937}=     [stateInfo.reasoningStatus[1]="DangerouslyOverheated"]
${reasoning_path_1937}=      /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${reasoningStatus_empty}=    [stateInfo.reasoningStatus=empty]

${alarm_severity_Critical}=  Critical
${alarm_number_7116}=        7116
${rf_user}                  serviceuser
${rf_password}              Pl(FzaYj5~c5;q
${rf_ip}                    172.22.0.2

*** Keywords ***
5GC001525-SA-TA-Fault_generation_1937

    Get reasoning path for 1937
    Wait Until Keyword Succeeds   600    60    ADMIN INFOMODEL Check If BTS Is OnAir
    log to console   trigger fault 1937 by change temperaturel
    SYSTEM Check if fault is not in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    Check ReasoningStatus Empty for 1937
    ADMIN Check If Alarm Is Not Active  fault_id=1937
    Run Keyword and Ignore Error    Prepare RMOD for SSH connection
    Change temperature for trigger fault 1937

    Check ReasoningStatus for 1937
    Sleep   10
    SYSTEM Check if fault is in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    ADMIN Check If Alarm Is Active  fault_id=1937
    Sleep   100
    log to console   Cancel fault 1937
    Change temperature for cancel fault 1937

    Wait Until Keyword Succeeds   420   60    ADMIN Check If Alarm Is Not Active  fault_id=1937
    ADMIN Check If Alarm Is In Historical Alarms  fault_id=1937
    Check ReasoningStatus Empty for 1937
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is OnAir



5GC001525-SA-TA-Fault_generation_4383
    ADMIN INFOMODEL Check If BTS Is OnAir
    #run_keyword_and_continue_on_failure   Verify if Alarm Managed Object for '${fault_id_4383}' is not in Info Model
    ADMIN Check If Alarm Is Not Active  fault_id=4383
    Start collecting BTS ping logs
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    log to console   trigger fault 4383
    Stop container to trigger fault 4383
    #Wait Until Keyword Succeeds  30  5  ADMIN INFOMODEL Check Parameter Value In Dictionary  ${recovery_reset_ind_path}  recoveryFaultID   type
#    Wait Until Keyword Succeeds  30  5      ADMIN INFOMODEL Check Parameter Value In Dictionary
#        ...    dist_name=${recovery_reset_ind_path}
#        ...    dict_name=recoveryFaultID
#        ...    dict_param=type
#        ...    value=soft
    Wait Until Keyword Succeeds   300   30    ADMIN Check If Alarm Is Active  fault_id=4383
   # run_keyword_and_continue_on_failure   ute_admin_infomodel.Query infomodel
    #...                                   query=${recovery_reset_ind_path} is [recoveryFaultID=${fault_id_4383},type=Site]   timeout=30
    Wait Until Keyword Succeeds   1200   60   ADMIN INFOMODEL Check If BTS Is OnAir
    Wait Until Keyword Succeeds   300   60    ADMIN Check If Alarm Is Not Active  fault_id=4383
    #run_keyword_and_continue_on_failure   is not in faults group  active  ${fault_id_4383}  ${source_fault4383}  ${EFaultId_4383}  timeout=30
#    5GC001525-SA-TA.Check if state of all cells is onAir

5GC001525-SA-TA-Fault_generation_28
    ADMIN INFOMODEL Check If BTS Is OnAir
    Download Corrupt SW from LSS
    run_keyword_and_continue_on_failure   Verify if Alarm Managed Object for '${fault_id_28}' is not in Info Model
    #run_keyword_and_continue_on_failure   is not in faults group  active  ${fault_id_28}  ${source_fault28}  ${EFaultId_28}  timeout=30
    OperatingSystem.File Should Exist     ${CORRUPT_SW_PATH}${CORRUPT_SW_VERSION}
    File Should Not Be Empty              ${CORRUPT_SW_PATH}${CORRUPT_SW_VERSION}
    log to console   trigger fault 28
    Trigger fault 28
    admin.ADMIN Reset Site
    #Wait for Site is pingable
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is OnAir
    run_keyword_and_continue_on_failure   Verify if Alarm Managed Object for '${fault_id_28}' is not in Info Model
    #run_keyword_and_continue_on_failure   is not in faults group  active  ${fault_id_28}  ${source_fault28}  ${EFaultId_28}  timeout=30
   # Check if every RF module is on swCheckDone status
    #5GC001525-SA-TA.Check if state of all cells is onAir


5GC001525-SA-TA-Fault_generation_1850
    ADMIN INFOMODEL Check If BTS Is OnAir
    run_keyword_and_continue_on_failure   Verify if Alarm Managed Object for '${fault_id_1850}' is not in Info Model
    Run Keyword and Ignore Error    Prepare RMOD for SSH connection
    log to console   trigger fault 1850
    Trigger fault 1850
    Wait Until Keyword Succeeds
    ...    500  30  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_1850}
    ...    value=${reasoningStatus_1850}
    Wait Until Keyword Succeeds  90  5  ADMIN Check If Alarm Is Active  fault_id=1850
    log to console   cancel fault 1850
    Cancel fault 1850
    Sleep  100
    run_keyword_and_continue_on_failure   Verify if Alarm Managed Object for '${fault_id_1850}' is not in Info Model

    Wait Until Keyword Succeeds   100   10    ADMIN Check If Alarm Is Not Active  fault_id=1850
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is OnAir
    #Check if every RF module is on swCheckDone status
#    Check if every RF module is on Online status
#    5GC001525-SA-TA.Check if state of all cells is onAir

Trigger fault 28
    Run Keyword And Expect Error      *  ADMIN Update Software  ${CORRUPT_SW_PATH}${CORRUPT_SW_VERSION}   should_activate=False
   # ute_admin_infomodel.Query infomodel   query=${reasoning_path_28} is ${result_failed}  timeout=30
#    Wait Until Keyword Succeeds
#    ...    45  5  ADMIN INFOMODEL Check ReasoningStatus Value
#    ...    dist_name=${reasoning_path_28}
#    ...    value=${result_failed}
   # run_keyword_and_continue_on_failure   ute_admin_infomodel.Query infomodel  query=${reasoning_path_28} is ${reasoningStatus_28}  timeout=30
    Wait Until Keyword Succeeds
    ...    45  5  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_28}
    ...    value=${reasoningStatus_28}
    #run_keyword_and_continue_on_failure   is in faults group  active  ${fault_id_28}  ${source_fault28}  ${EFaultId_28}  timeout=30

Trigger fault 1850
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    ssh ${rf_user}@${rf_ip}
    SSHLibrary.Read Until    expected=password:
    SSHLibrary.Write    ${rf_password}
    SSHLibrary.Read Until     expected=$
    SSHLibrary.Write    sudo -i
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write  cp /mnt/runtime/swman/slot_1 /mnt/runtime/swman/slot_1.orig
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write  truncate -s 0 /mnt/runtime/swman/slot_1
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write  cp /mnt/runtime/swman/slot_0 /mnt/runtime/swman/slot_0.orig
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write  truncate -s 0 /mnt/runtime/swman/slot_0
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write  reboot
    SSHLibrary.Close Connection

Cancel fault 1850
    SYSTEM Open SSH Connection To Enb
     #SSHLibrary.Write    cat /ffs/run/config/FRIps.txt
    #${FRIps}=    SSHLibrary.Read Until    expected=>
    #${splitFRIps}=    Split string       ${FRIps}    separator=\;
    #${ip_rmod}=     Get from list       ${splitFRIps}     2
    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until    expected=>
     SSHLibrary.Write    rm /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    ssh ${rf_user}@${rf_ip}
    SSHLibrary.Read Until    expected=?
    SSHLibrary.Write    yes
    SSHLibrary.Read Until    expected=password:
    SSHLibrary.Write    ${rf_password}
    SSHLibrary.Read Until     expected=$
    SSHLibrary.Write    sudo -i
    #SSHLibrary.Write    w@=EIj7P6R0bVy85OjCVa^ho&8
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write  cp /mnt/runtime/swman/slot_1.orig /mnt/runtime/swman/slot_1
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write  cp /mnt/runtime/swman/slot_0.orig /mnt/runtime/swman/slot_0
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write  reboot
    SSHLibrary.Close Connection


Verify if Alarm Managed Object for '${fault_id}' is not in Info Model
   # ute_admin_infomodel.Query infomodel  query=count ${alarm_path} is [faultId=${fault_id}] = 0  timeout=300
     Wait Until Keyword Succeeds  300  30  ADMIN Check If Alarm Is Not Active  fault_id=${fault_id}
Check if state of all cells is onAir
    ute_admin_infomodel.Query infomodel  query=every ${cell_status_path} is [stateInfo.proceduralState=OnAirDone]  timeout=500
   # ute_admin_infomodel.Query infomodel
   #... query=every /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/NRBTS_M-1/CELL_M-2 is [stateInfo.proceduralState=OnAirDone]  timeout=500

Check if every RF module is on Online status
    ute_admin_infomodel.Query infomodel  query=every ${rmod_status_path} is [stateInfo.operationalState=enabled]  timeout=30
#    ute_admin_infomodel.Query infomodel
#...  query=every /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2 is [stateInfo.availabilityStatus=Online]

Change temperature for trigger fault 1937
    SYSTEM Open SSH Connection To Enb
   # SSHLibrary.Write    cat /ffs/run/config/FRIps.txt
   # ${FRIps}=    SSHLibrary.Read Until    expected=>
   # ${splitFRIps}=    Split string       ${FRIps}    separator=\;
   # ${ip_rmod}=     Get from list       ${splitFRIps}     2
    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    ssh ${rf_user}@${rf_ip}
    SSHLibrary.Read Until    expected=password:
    SSHLibrary.Write    ${rf_password}
    SSHLibrary.Read Until     expected=$
    SSHLibrary.Write    sudo -i
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo /ca action terminate |${frmon}
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo /trx1 action terminate |${frmon}
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo / action create ThermometerDevice /trx1 /module/ASC0_internal_BMR |${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   / action create ConfigAccess /ca /module
    SSHLibrary.Write    echo / action create ConfigAccess /ca /module |${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /ca action fetch DECODED "type/tempest_inst1.bin" "/var/tmp/tempest_inst1.json"
    SSHLibrary.Write    echo /ca action fetch DECODED \\"tempest_inst1.bin\\" \\"/var/tmp/tempest_inst1_default.json\\" |${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /ca action fetch DECODED "type/tcs.bin" "/var/tmp/tcs.json"
    SSHLibrary.Write    echo /ca action fetch DECODED \\"tcs.bin\\" \\"/var/tmp/tcs_default.json\\" |${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write    cp /var/tmp/tempest_inst1.json /var/tmp/tempest_inst1_default.json
## ${list_tempOffset_default}=   SSHLibrary.Write   cat /var/tmp/tempest_inst1.json | grep tempOffset
    SSHLibrary.Write     cat /var/tmp/tempest_inst1_default.json|grep tempOffset
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   sed -i 's/"tempOffset": 0,/"tempOffset": 65,/g' /var/tmp/tempest_inst1.json
     SSHLibrary.Write   sed -i 's/"tempOffset": 0.0,/"tempOffset": 65,/g' /var/tmp/tempest_inst1_default.json
     SSHLibrary.Read Until     expected=#
      SSHLibrary.Write   sed -i 's/"tempOffset": 0,/"tempOffset": 65,/g' /var/tmp/tempest_inst1_default.json
     SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   sed -i 's/"tempOffset": 5.0,/"tempOffset": 65,/g' /var/tmp/tempest_inst1.json
## SSHLibrary.Write   sed -i 's/"tempOffset": 23.0,/"tempOffset": 65,/g' /var/tmp/tempest_inst1.json
## ${list_tempOffset_65}=   SSHLibrary.Write   cat /var/tmp/tempest_inst1.json | grep tempOffset
    SSHLibrary.Write     cat /var/tmp/tempest_inst1_default.json|grep tempOffset
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /ca action store TEMPORARY DECODED "type/tempest_inst1.bin" "/var/tmp/tempest_inst1.json"
    SSHLibrary.Write    echo /ca action store TEMPORARY DECODED \\"tempest_inst1.bin\\" \\"/var/tmp/tempest_inst1_default.json\\" |${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /ca action update
    SSHLibrary.Write    echo /ca action update |${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   / action create ThermometerDevice /trx1 /module/ASC0_internal_BMR
#    SSHLibrary.Write    echo / action create ThermometerDevice /trx1 /module/ASC0_internal_BMR |frmonShellClient 127.0.0.1 2000
#    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /trx1 action override TEMPERATURE 65
    SSHLibrary.Write    echo /trx1 action override TEMPERATURE 65 |${frmon}
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Close Connection
#    Sleep         400s

Change temperature for cancel fault 1937
    SYSTEM Open SSH Connection To Enb
    # SSHLibrary.Write    cat /ffs/run/config/FRIps.txt
   # ${FRIps}=    SSHLibrary.Read Until    expected=>
    #${splitFRIps}=    Split string       ${FRIps}    separator=\;
    #${ip_rmod}=     Get from list       ${splitFRIps}     2
    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    ssh ${rf_user}@${rf_ip}
    SSHLibrary.Read Until    expected=password:
     SSHLibrary.Write    ${rf_password}

     SSHLibrary.Read Until     expected=$
     SSHLibrary.Write    sudo -i

    SSHLibrary.Read Until     expected=#
# SSHLibrary.Write   /ca action store TEMPORARY DECODED "type/tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"
    SSHLibrary.Write   sed -i 's/"tempOffset": 65,/"tempOffset": 0.0,/g' /var/tmp/tempest_inst1_default.json
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write     cat /var/tmp/tempest_inst1_default.json|grep tempOffset
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo /ca action store TEMPORARY DECODED \\"tempest_inst1.bin\\" \\"/var/tmp/tempest_inst1_default.json\\" |${frmon}
    SSHLibrary.Read Until     expected=#
# SSHLibrary.Write   /ca action update
    SSHLibrary.Write    echo /ca action update |${frmon}
    SSHLibrary.Read Until     expected=#
# SSHLibrary.Write   /trx1 action override TEMPERATURE 51
    SSHLibrary.Write    echo /trx1 action override OFF |${frmon}
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo /ca action terminate |${frmon}
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo /trx1 action terminate |${frmon}
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Close Connection
#    Sleep         400s
# SSHLibrary.Write   /ca action terminate
# SSHLibrary.Write   /trx1 action terminate

Start collecting BTS ping logs
    Run    ping 192.168.255.1 >> /tmp/ping_BTS.txt &

Check condition before stop container
    ute_admin_infomodel.Query infomodel  query=count ${core_dump} is = 0  timeout=120
    #is not in faults group  active  ${fault_id_4383}  /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-*/SMOD_L-1
  #  ...  EFaultId_VirtualNodeNotRespondingAl  timeout=60

Stop container to trigger fault 4383
    #SYSTEM Execute Command On gNB   systemctl stop hwr-container@TRACECM00.service
    SYSTEM Execute Command On gNB   pkill -11 -f '/opt/CCS/CCSDaemonExe --startup=nid=0x1510'


Download Corrupt SW from LSS
    OperatingSystem.Run     sshpass -p 'zO&n1W*ktp7' scp -r coam@10.5.25.105:/opt/coam/NU_STERGE/fault28/ /home/ute/Documents/

Check ReasoningStatus Empty for 1937
    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_1937}


Get reasoning path for 1937
    ${RMOD_distname}    Get Object Distname From Class Name if List
    ...    class_name=RMOD_L
    ${RMOD_distname_1}=   get from list   ${RMOD_distname}   0
    ${reasoning_path_1937}=   Set variable   ${RMOD_distname_1}/RU_L-1

    Set test variable   ${reasoning_path_1937}


Check ReasoningStatus for 1937
    ${is_present}    Run Keyword And Return Status    Wait Until Keyword Succeeds
    ...    300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_1937}
    ...    value=DangerouslyOverheated

Get Object Distname From Class Name
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    :FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
    \    ${distName}    Get From Dictionary    ${element}    distName
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
    :FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
    \    ${distName}    Get From Dictionary    ${element}    distName
    \    append to list   ${distname_list}   ${distName}
    [Return]    ${distName_list}

Prepare RMOD for SSH connection
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    rm /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    ssh ${rf_user}@${rf_ip}
    SSHLibrary.Read Until    expected=?
    SSHLibrary.Write    yes
    SSHLibrary.Read Until    expected=password:
    SSHLibrary.Close Connection
