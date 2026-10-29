*** Settings ***
Resource        ../../common_resources/ca_FM_general.robot

*** Variables ***
${ASIK_IP_LMP}    192.168.255.129
${ASIK_username}  toor4nsn
${ASIK_password}  oZPS0POrRieRtu

*** Keywords ***
TC__FM__Check_RU_restart_indication_is_sent_to_OAM_4527_BTS_fault
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21403
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC will crash one RMOD randomly. Fault 4527 ID should appear.
    ...  Files BTS40_125D_startup.tgz, BTS40_125D_syslog.tgz, BTS40_125D_crash.tgz, BTS40_125D_others.tgz, BTS40_125D_trbl_logs.tgz
    ...  are verified to be collected in the snapshot.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-21403 - Initial TAT creation
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  *******************

    Set Tags    CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21  FEATURE-RP002187

    Step0: Select RMOD
    Step1: Crash RU
    Step2: Check Fault 4527
    Step3: Collect Snapshot


Step0: Select RMOD
    Log  Step0: Select RMOD  console=true
    ${RMOD_list}  query infomodel  get list //RMOD_R-*
    ${number_of_rdmos}  get length  ${RMOD_list}
    ${select_rmod_randomly}  Evaluate  random.randint(0, ${number_of_rdmos}-1)  modules=random
    Log  Reset site to clear the alarms.  console=true
    coam.Reset Site
    Wait Until Keyword Succeeds  600  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Get RMOD IP from Info Model  ${select_rmod_randomly}

Step1: Crash RU
    Log  Step1: Crash RU  console=true
    Crash RU
    ${status}  Run keyword and return status  Assert Alarm Active  faultId=10  timeout=300
    Run keyword if  ${status}
    ...  Log  Fault Id 10 appeared.[OK]  console=true
    ...  ELSE
    ...  Set test restriction  Fault Id 10 was not seen.[NOK]

Step2: Check Fault 4527
    Log  Step2: Check Fault 4527  console=true
    ${status}  Run keyword and return status  Assert Alarm Active  faultId=4527  timeout=300
    Run keyword if  ${status}
    ...  Log  Fault Id 4527 appeared.[OK]  console=true
    ...  ELSE
    ...  Set test failed  Fault Id 4527 was not seen.[NOK]
    ${cells_status}  Run keyword and return status  Wait Until Keyword Succeeds  300  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run keyword if  ${status}
    ...  Log  Cells OK after crash.  console=true
    ...  ELSE
    ...  Set Test Restriction  Cells NOT OK after crash.

Step3: Collect Snapshot
    Log  Step3: Collect Snapshot  console=true
    ${bts_id}  Fetch from right  ${TESTLINE_NAME}  _
    ${files}  create list  BTS${bts_id}_125D_syslog.tgz  BTS${bts_id}_125D_crash.tgz  BTS${bts_id}_125D_others.tgz  BTS${bts_id}_125D_trbl_logs.tgz
    collect snapshot  /home/ute/btsauto/snapshot.zip  timeout=300
    unzip  /home/ute/btsauto/snapshot.zip  /home/ute/btsauto/snapshot_dir/
    ${snapshot_file_list}  OperatingSystem.Get file  /home/ute/btsauto/snapshot_dir/snapshot_file_list.txt
    FOR  ${file}  IN  @{files}
    ${status}  Run keyword and return status  should contain  ${snapshot_file_list}  ${file}
    Run keyword if  ${status}  Log  ${file} is in snapshot  console=true
    ...  ELSE
    ...  Set Test Failed  ${file} is not in snapshot.
    END

Get RMOD IP from Info Model
    [Arguments]  ${random_rmod}
    ${get_rmod_l}   coam.get_managed_objects  RMOD_L  timeout=600s
    ${IP}  Set Variable  ${get_rmod_l[${random_rmod}]["parameters"]["ipAddress"]}
    Log  Selected RMOD: ${get_rmod_l[${random_rmod}]["parameters"]["serialNumber"]}  console=true
    should not be equal as strings    ${IP}    0.0.0.0
    Set Test Variable  ${IP}

Crash RU
    wait until keyword succeeds  5min  5s  ssh.Connect to     hostname=${ASIK_IP_LMP}  username=${ASIK_username}
    ...  password=${ASIK_password}	alias=ASIK
    ${NODEID_FHNET}  ssh.Execute  ls -al /tmp/node* | grep FHNET | head -1 | awk -F '_' '{print $2}' | awk -F ' ' '{print $1}'  connection=ASIK
    ...  timeout=10
    ssh.Execute  lxc-attach -n ${NODEID_FHNET.split("\r\n")[0]} -- /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes"  connection=ASIK
    ...  timeout=10
    sleep    1s
    Set Test Variable  ${FHNET_IP}  192.168.255.254
    ssh.Connect To  hostname=${FHNET_IP}  username=${ASIK_username}  password=${ASIK_password}  proxy=ASIK  alias=container
    Run Keyword And Ignore Error  ssh.Connect To  hostname=${IP}  username=root  password=w@=EIj7P6R0bVy85OjCVa^ho&8  proxy=container  alias=RU
    ${ps_edf_output}   ssh.Execute  ps  connection=RU  timeout=10
    ${ps_cmd_RU}  ssh.Execute  ps | grep CCSDaemonExe | awk '{print $1}' | xargs -n1  connection=RU
    ${ps_Killcmd_RU}  ssh.Execute  ps | grep CCSDaemonExe | awk '{print $1}' | xargs kill -11 $1  connection=RU
    ssh.Disconnect  connection=RU
    ssh.Disconnect  connection=container
    ssh.Disconnect  connection=ASIK


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
