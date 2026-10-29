*** Settings ***
Documentation
...     Keywords Purpose:
...         Keywords for Feature 5GC002093
Library      taf.transport.ssh                    WITH NAME    ssh
Library      ../../resources/swconfig_handler.py     WITH NAME    swconf
Library      ute_ue                               WITH NAME    ue
Library      ../../resources/pm_analyze.py           WITH NAME    pm_analyze
Library      taf.sbts.oam.coam.admin              WITH NAME    coam
Resource     ../../resources/pm_collection.robot


*** Keywords ***
SetFlagOnSwConfig
    [Arguments]       ${flag}      ${value}
    ${asik_cnx}       ssh.connect_to
	...               ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
	...               ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
	...               ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...               alias=asik_als

    swconf.set_flag
    ...     ${asik_cnx}
    ...     /ffs/run/swconfig.txt
    ...     ${flag}
    ...     ${value}

    ${contents}=    ssh.Execute      more /ffs/run/swconfig.txt | grep 580220   connection=${asik_cnx}
    ssh.disconnect  connection=${asik_cnx}
    Trigger coam Site Reset and Wait Startup Completed     timeout=500   gnb_id=0


DetachUe
    [Arguments]       ${alias}       ${capabilities}
    ue.require_ue      ue_alias=${alias}     capabilities=${capabilities}
    ue.detach_ue       ue_alias=${alias}

DetachUe_noRequireUE
    [Arguments]       ${alias}       #${capabilities}
    ue.detach_ue       ue_alias=${alias}
    Log To Console     \n in kw DetachUe_noRequireUE ${alias} detached


RebootUE
    [Arguments]       ${ue}
    Log To Console       ${ue.ssh_connection_details.addr}
    ssh.Connect To
	...              ${ue.ssh_connection_details.addr}
	...              ${ue.ssh_connection_details.username}
	...              ${ue.ssh_connection_details.password}
	...              alias=cnxUE
    ssh.Send Command         command=adb reboot        connection=cnxUE
    Sleep     50s
    ssh.Disconnect     connection=cnxUE

AttachUE
    [Arguments]       ${alias}       ${capabilities}
    #TODO move require_ue to precondition
    Run Keyword And Ignore Error   ue.require_ue      ue_alias=${alias}     capabilities=${capabilities}
    ue.attach_ue       ue_alias=${alias}
    Sleep     5s

AttachUE_With_Reboot
    [Arguments]       ${alias}       ${capabilities}
    Run Keyword And Ignore Error   ue.require_ue      ue_alias=${alias}     capabilities=${capabilities}
#	ue.reboot_ue       ${alias}
    ue.software_reset    ${alias}    timeout=90
    ue.attach_ue       ue_alias=${alias}
    Log To Console     \n in kw AttachUE_With_Reboot ${alias} rebooted and attached
    Sleep     5s


AttachUE_noRequireUE
    [Arguments]       ${alias}       #${capabilities}
#    ue.require_ue      ue_alias=${alias}     capabilities=${capabilities}
    ue.attach_ue       ue_alias=${alias}
    Sleep     5s


WaitForNextMeasPeriod
    [Arguments]       ${gNB}      ${meas_period}    ${additional_time_sec}
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${meas_period}
    ...        additional_waiting_time_sec=${additional_time_sec}
    ...        gnb=${gNB}

TrafficAskey
#TODO debit et ports
    ssh.Connect To
    ...   ${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...   ${tl.appserver.iperf_details.ssh_connection_details.username}
    ...   ${tl.appserver.iperf_details.ssh_connection_details.password}
    ...   alias=cnx

    ${cmd}=   Set Variable   iperf -c ${tl.ues[1].iperf_details.network_interface_address} -u -i 1 -p 3034 -l 1350 -t 240 -b 680M
    ssh.Send Command    command=${cmd}     connection=cnx
    ${cmd}=   Set Variable   iperf -c ${tl.ues[0].iperf_details.network_interface_address} -u -i 1 -p 3041 -l 1350 -t 240 -b 680M
    ssh.Send Command    command=${cmd}     connection=cnx
    Sleep     240s
    ssh.Disconnect     connection=cnx

TrafficAskey_450M
#TODO debit et ports
    ssh.Connect To
    ...   ${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...   ${tl.appserver.iperf_details.ssh_connection_details.username}
    ...   ${tl.appserver.iperf_details.ssh_connection_details.password}
    ...   alias=cnx

    ${cmd}=   Set Variable   iperf -c ${tl.ues[1].iperf_details.network_interface_address} -u -i 1 -p 3034 -l 1350 -t 240 -b 450M
    ssh.Send Command    command=${cmd}     connection=cnx
    ${cmd}=   Set Variable   iperf -c ${tl.ues[0].iperf_details.network_interface_address} -u -i 1 -p 3041 -l 1350 -t 240 -b 450M
    ssh.Send Command    command=${cmd}     connection=cnx
    Sleep     240s
    ssh.Disconnect     connection=cnx

TrafficAskey_720s
#TODO debit et ports
    ssh.Connect To
    ...   ${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...   ${tl.appserver.iperf_details.ssh_connection_details.username}
    ...   ${tl.appserver.iperf_details.ssh_connection_details.password}
    ...   alias=cnx

    # traffic duration is set to 2 x measurement period in s + additionnal time of 120s = 120 + 2*60*5min =  120+600

    ${cmd}=   Set Variable   iperf -c ${tl.ues[0].iperf_details.network_interface_address} -u -i 1 -p 3041 -l 1350 -t 720 -b 600M
    ssh.Send Command    command=${cmd}     connection=cnx
    ${cmd}=   Set Variable   iperf -c ${tl.ues[1].iperf_details.network_interface_address} -u -i 1 -p 3034 -l 1350 -t 720 -b 600M
    ssh.Send Command    command=${cmd}     connection=cnx
    Sleep     25s
    ssh.Disconnect     connection=cnx
