*** Settings ***
Documentation    This is a Robot keyword File, for 5GC001514
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        ../5GC000480/keywordbook-480.robot
Resource        ../../resources/Common/commissioning.robot
Resource        ../../resources/Common/reporting.robot


*** Keywords ***

Prepare TL
    [Documentation]    [PRIVATE]    prepare tl
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create Test Suite Folders
    keywordbook-480.Get Test Variables And Upload Start SCF
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos
    gnb.Get SCF From GNB With COAM    gnbScfName=SCFC_start.xml    resultConfigDir=${resultBaseDir}
    gnb.Store Current Swconfig From GNB
    wts_ue.Store Current Swconfig From Airphone
    wts_ue.Store Current WTS Config


Perform Test Setup
    [Documentation]    [PRIVATE]    perform test setup
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create a Test Scenario Folder
    ute_workarounds.Bring Airphone TL To On Air Status
    5GC001514-keywords.Get Ip From Hosts


Perform Test Teardown
    [Documentation]    [PRIVATE]    perform test teardown with saving logs
    ...       :Autor: Sylvia Schneider
    reporting.Set SCOUT TC ID for Reporting
    5GC001514-keywords.Stop Tcpdump Recording
    wts_ue.Teardown Egate Connection for Airphone
    wts_ue.Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    keywordbook-480.Collect Snapshot And Sos Report Data     ${resultDir}


Perform suite teardown
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    keywordbook-480.Collect snapshot and sos report data   ${resultBaseDir}


Get Ip From Hosts
    [Documentation]    [PRIVATE]   find ip for unit in /etc/hosts
    ...     :Autor: Sylvia Schneider
    ${gNBCommUnit_alias}    Wait Until Keyword Succeeds
    ...    ${SSH_AUTHENTICATION_TIMEOUT}   ${SSH_AUTHENTICATION_RETRY_INTERVAL}
    ...     connect.Connect To Node Common Unit
    Sleep    2s
    ssh.Send Command    grep -i ${unit1} /etc/hosts    timeout=60s     get_pty=True   connection=${gNBCommUnit_alias}
    ${unit_hosts}   ssh.Read Output       connection=${gNBCommUnit_alias}
    @{unit_parts}   Split String    ${unit_hosts}   ${SPACE}
    Set Test Variable    ${unit_addr1}    ${unit_parts}[0]
    Log To Console    \n${unit1} address taken from /etc/hosts is "${unit_addr1}"

    ssh.Send Command    grep -i ${unit2} /etc/hosts    timeout=60s     get_pty=True   connection=${gNBCommUnit_alias}
    ${unit_hosts}   ssh.Read Output       connection=${gNBCommUnit_alias}
    @{unit_parts}   Split String    ${unit_hosts}   ${SPACE}
    Set Test Variable    ${unit_addr2}     ${unit_parts}[0]
    Log To Console    \n${unit2} address taken from /etc/hosts is "${unit_addr2}"
    [Teardown]    ssh.Disconnect   connection=${gNBCommUnit_alias}


Set actForceUnitAutoReset To false
    [Documentation]    [PRIVATE]   delta commissioning for parameter actForceUnitAutoReset
    ...     :Autor: Sylvia Schneider
    Log To Console    set parameter actForceUnitAutoReset to false with delta commissioning
    ${parsed_SCF}    Parse Xml     ${resultBaseDir}/SCFC_start.xml
    ${fmcadm_dist}     Get Element Attribute    ${parsed_SCF}    distName    xpath=.//managedObject[@class="com.nokia.srbts.mnl:FMCADM"]
    ${fmcadm_vers}     Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@class="com.nokia.srbts.mnl:FMCADM"]
    ${BBMOD_vers}      Get Element Attribute    ${parsed_SCF}    version
    ...     xpath=.//managedObject[@distName="MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-2"]
    Set Test Variable   ${BBMOD_vers}

    ${delta_SCF_template}    Get File       ${CURDIR}/autoforce_delta.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/autoforce_delta.xml    ${delta_SCF_update}
    commissioning.Execute Delta Commissioning    delta_scf_template=${resultDir}/autoforce_delta.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished
    keywordbook-480.get Scf Coam    ${resultDir}    SCFC_autoforce_delta.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_autoforce_delta.xml


Set CPCL actForceUnitAutoReset To False
    [Documentation]    [PRIVATE]   delta commissioning for parameter actForceUnitAutoReset
    ...     :Autor: Sylvia Schneider
    Log To Console    set parameter actForceUnitAutoReset to false with delta commissioning
    ${parsed_SCF}    Parse Xml     ${resultBaseDir}/SCFC_start.xml
    ${fmcadm_dist}     Get Element Attribute    ${parsed_SCF}    distName    xpath=.//managedObject[@class="com.nokia.srbts.mnl:FMCADM"]
    ${fmcadm_vers}     Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@class="com.nokia.srbts.mnl:FMCADM"]

    ${delta_SCF_template}    Get File       ${CURDIR}/autoforce_delta_CPCL.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/autoforce_delta_CPCL.xml    ${delta_SCF_update}
    commissioning.Execute Delta Commissioning    delta_scf_template=${resultDir}/autoforce_delta_CPCL.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished
    keywordbook-480.Get SCF Coam    ${resultDir}    SCFC_autoforce_delta_CPCL.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_autoforce_delta_CPCL.xml


Lock BBMOD-2
    [Documentation]    [PRIVATE]   Lock BBMOD-2
    ...     :Autor: Sylvia Schneider
    Log To Console    set parameter Lock BBMOD-2 with delta commissioning
    ${delta_SCF_template}    Get File       ${CURDIR}/lock_BBMOD2_delta.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/lock_BBMOD2_delta.xml    ${delta_SCF_update}
    commissioning.Execute Delta Commissioning    delta_scf_template=${resultDir}/lock_BBMOD2_delta.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished
    Sleep    2s
    keywordbook-480.get Scf Coam    ${resultDir}    SCFC_lock_BBMOD2_delta.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_lock_BBMOD2_delta.xml


Unlock BBMOD-2
    [Documentation]    [PRIVATE]   unlock BBMOD-2
    ...     :Autor: Sylvia Schneider
    Log To Console    set parameter Unlock BBMOD-2 with delta commissioning
    ${delta_SCF_template}    Get File       ${CURDIR}/unlock_BBMOD2_delta.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/unlock_BBMOD2_delta.xml    ${delta_SCF_update}
    commissioning.Execute Delta Commissioning    delta_scf_template=${resultDir}/unlock_BBMOD2_delta.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished
    Sleep    2s
    keywordbook-480.get Scf Coam    ${resultDir}    SCFC_unlock_BBMOD2_delta.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_unlock_BBMOD2_delta.xml


Lock BBMOD2 And Attach UE And Unlock BBMOD2 And Run Traffic
    [Documentation]    [PRIVATE]   attach UE, start traffic, get statistic, stop traffic, reset statistics
    ...     :Autor: Sylvia Schneider
    wts_ue.Attach UE To LTE    ue_id=${ue_id}
    Sleep    2s
    Lock BBMOD-2
    wts_ue.Trigger LTE-NR Dual Connectivity For Bearers    ue_id=${ue_id}    target_cells=${cell_id}    bearer_id=2
    Unlock BBMOD-2
    5GC001514-keywords-traffic.Start Downlink And Uplink Traffic
    5GC001514-keywords-traffic.Get Bearer Statistics   before_crash
    5GC001514-keywords-traffic.Stop Traffic


Attach UE And Run Traffic
    wts_ue.Attach UE To LTE    ue_id=${ue_id}
    Sleep    2s
    wts_ue.Trigger LTE-NR Dual Connectivity For Bearers    ue_id=${ue_id}    target_cells=${cell_id}    bearer_id=2
    5GC001514-keywords-traffic.Start Downlink And Uplink Traffic
    5GC001514-keywords-traffic.Get Bearer Statistics   before_crash
    5GC001514-keywords-traffic.Stop Traffic


Trigger sgNBaddition And Run Traffic
    [Documentation]    [PRIVATE]   trigger sgNBaddition, start traffic, record traffic, get statistic, stop traffic
    ...     :Autor: Sylvia Schneider
    wts_ue.Trigger LTE-NR dual connectivity for bearers    ue_id=${ue_id}    target_cells=${cell_id}   bearer_id=2
    5GC001514-keywords-traffic.Start Downlink And Uplink Traffic
    5GC001514-keywords-traffic.Record Traffic With Tcpdump
    5GC001514-keywords-traffic.Reset Bearer Statistics
    5GC001514-keywords-traffic.Get Bearer Statistics   after_crash
    5GC001514-keywords-traffic.Stop Traffic


Detach Single UE
    Log to Console    \nDetach UE ${ue_id}
    wts_ue.Detach UE from LTE     ue_id=${ue_id}
    Sleep    3s


Check gNB onAir
    [Documentation]    [PRIVATE]   check that gNB is onAir
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until gNB with all cells is onAir
    Wait Until Keyword Succeeds
    ...    3min   20sec
    ...    gnb.Wait Until Node To Be Onair State


Close Connection
    [Documentation]    [PRIVATE]   close connection to gNBCommonUnit
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${gNBCommUnit_alias}
    ssh.Write Input    exit${\n}     connection=${gNBCommUnit_alias}
    ssh.Read Output Until   ${SPACE}>    timeout=10   connection=${gNBCommUnit_alias}


Attach To Container
    [Documentation]    [PRIVATE]   attach to a container
    ...     :Autor: Sylvia Schneider
    [Arguments]     ${gNBCommUnit_alias}    ${cont}
    ssh.Write Input    lxc-attach -n ${cont}${\n}     connection=${gNBCommUnit_alias}
    ssh.Read Output Until   ~${SPACE}>    timeout=10   connection=${gNBCommUnit_alias}


Start Tcpdump Recording
    [Documentation]    [PRIVATE]    start wireshark trace, simulated eNB, classical testline
    ...       :Autor: Sylvia Schneider
    tcpdump.Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     5s
    Set Suite Variable      ${tcpdump_running}    true


Stop Tcpdump Recording
    [Documentation]    [PRIVATE]    stop wireshark trace, simulated eNB, classical testline
    ...       :Autor: Sylvia Schneider
    IF    '${tcpdump_running}'=='false'   RETURN
    Sleep     5s
    tcpdump.Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Sleep     2s
    Move File    ${resultDir}/dump_testpc/dump_testpc.pcap    ${resultDir}/wireshark.pcap
    Sleep     5s
    Set Suite Variable      ${tcpdump_running}    false
