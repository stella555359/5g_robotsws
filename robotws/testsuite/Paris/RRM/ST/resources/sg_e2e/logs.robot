*** Settings ***
Documentation   description

Library      DateTime
Library      Collections
Library      OperatingSystem
Library      String
Library      taf.transport.ssh              WITH NAME   ssh
Library      taf.gnb.oam.megazone_client    WITH NAME   mz
Library      taf.gnb.oam.coam.admin         WITH NAME   coam
Resource     ${CURDIR}/basics.robot


*** Keywords ***
Cloud All CU journal collection
    [Documentation]   journal logfile collection. Each journal retrieved with -b option (logs from last reboot) gzipped downloaded in local path
    ...               result_Y_M_D_H_M/logs/CU/<VMname>
    ...               Taf used: ssh 3.3.1
    [Arguments]         &{vm_dict}

    ${vm_name_list}             get dictionary keys         ${vm_dict}
    build vm alias              &{vm_ip_addr}
    :FOR        ${vm_name}  IN   @{vm_name_list}
    \           ssh.connect to              ${vm_alias_dict.${vm_name}}-0.local     robot    rastre1    proxy=${oam_alias}   alias=${vm_name}
    \           ssh.execute                 sudo journalctl -b > //tmp//${vm_name}Journal.txt    connection=${vm_name}
    \           ${path_tmp}                 joinpath            ${logs_path}    CU/${vm_name}
    \           create directory            ${path_tmp}
    \           directory should exist      ${path_tmp}         ${path_tmp} directory should be created
    \           ${path_tmp}                 joinpath            ${path_tmp}     ${vm_name}Journal.txt.gz
    \           ssh.execute                 sudo gzip /tmp/${vm_name}Journal.txt  connection=${vm_name}
    \           ssh.download file           /tmp/${vm_name}Journal.txt.gz      ${path_tmp}   connection=${vm_name}
    \           file should not be empty    ${path_tmp}    ${path_tmp} abnormaly empty
    \           ssh.execute                 rm /tmp/${vm_name}Journal.txt*  connection=${vm_name}
    \           ssh.disconnect              connection=${vm_name}

Cloud Get Cu Oam logs
    [Documentation]   log file of OAM VM startup_RACOAM.log is retrieved, gzipped and downloaded in same local repository as OAM VM journal logs
    ...               Taf used: ssh 3.3.1
    ${vm_name_list}             get dictionary keys          ${vm_ip_addr}
    ${index}                    get index from list          ${vm_name_list}    oamVM
    ${path_tmp}                 joinpath                     ${logs_path}       CU/@{vm_name_list}[${index}]/OamVM_startup_RACOAM.log.gz
    # TO DO: peut etre amélioré pour autoriser que la string oam et non oamVM (si nom de la VM pas connu)
    create file                 ${path_tmp}
    ${oam_vm_logs_path}         set variable    /opt/nokia/SS_MzOam/cloud-racoam/logs/startup_RACOAM.log
    ${status}                   ssh.execute     ls -lrt ${oam_vm_logs_path}    connection=${oam_alias}
    ${info}                     Set Variable    No such file or directory
    ${match}     ${value} =     Run Keyword And Ignore Error    Should Contain     ${status}     ${info}
    Run Keyword If              '${match}'=='PASS'    Get Cu Oam logs in startup RACOAM gz      ${path_tmp}
    ...                         ELSE                  Get Cu Oam logs in startup RACOAM log     ${path_tmp}

Get Cu Oam logs in startup RACOAM gz
    [Arguments]         ${path_tmp}
    ${oam_vm_logs_path}         set variable    /opt/nokia/SS_MzOam/cloud-racoam/logs/startup_RACOAM.log
    ${oam_vm_logs_path}         catenate   SEPARATOR=   ${oam_vm_logs_path}   .gz
    ssh.download file           ${oam_vm_logs_path}          ${path_tmp}        connection=${oam_alias}
    file should not be empty    ${path_tmp}                  ${path_tmp} abnormaly empty

Get Cu Oam logs in startup RACOAM log
    [Arguments]         ${path_tmp}
    ${oam_vm_logs_path}         set variable    /opt/nokia/SS_MzOam/cloud-racoam/logs/startup_RACOAM.log
    ssh.execute                 cp ${oam_vm_logs_path} /tmp/OamVM_startup_RACOAM.log     connection=${oam_alias}
    ssh.execute                 gzip /tmp/OamVM_startup_RACOAM.log     connection=${oam_alias}
    ssh.download file           /tmp/OamVM_startup_RACOAM.log.gz          ${path_tmp}        connection=${oam_alias}
    file should not be empty    ${path_tmp}                  ${path_tmp} abnormaly empty
    ssh.send command            sudo rm /tmp/OamVM_startup_RACOAM.log.gz     connection=${oam_alias}

Get Oam snapshot
    [Documentation]
    ...                 TAF used: gnb.oam.megazone
    ...                 gNB compatibility: MZ COAM
    ...                 Update: Stephane Croquet - 20190510 - Add COAM
    ${date}                     get current date
    ${date_format}              convert date        ${date}       %Y.%m.%d_%H.%M
    ${path_tmp}                 joinpath        ${res_path}      Snapshot
    create directory            ${path_tmp}
    ${snapshot_path}            joinpath        ${path_tmp}      Snapshot_${date_format}.7z
    run keyword if      '${oam_type}' == 'MZ'
    ...                 mz.make snapshot      snapshot_path=${snapshot_path}        timeout=900    session=MegaZ
    run keyword if      '${oam_type}' == 'COAM'
    ...                 coam.get_snapshot     target_file_name=${snapshot_path}     timeout=900    connection=coamCnx
    file should not be empty    ${snapshot_path}                  ${snapshot_path} abnormally empty

Get Asik logs
    [Documentation]     collection of 3 startup files of Asik: startup_DEFAULT.log.xz, startup_NODEOAM.log, startup_OAMAGENT.log;
    ...                 + journalctl after last reboot
    ...                 TAF used: transport.ssh
    ...                 Update 20181120: S. Croquet - Add alias as argument
    ...                 Update 20200528 FM: Change alias default value. Logs are not at the same place in the different releases
    [Arguments]         ${alias}=asikFhCnx


    # journalctl
    ${path_tmp}                     joinpath       ${logs_path}    DU/Asik
    create directory                ${path_tmp}
    ${file_path_tmp}                joinpath        ${path_tmp}      ASIK_Journal.gz
    ssh.execute                     journalctl -b > //tmp//ASIK_Journal.txt               connection=${alias}
    ssh.execute                     gzip /tmp/ASIK_Journal.txt   connection=${alias}
    ssh.download file               /tmp/ASIK_Journal.txt.gz            ${file_path_tmp}      connection=${alias}
    ssh.execute                     rm /tmp/ASIK_Journal.txt.gz   connection=${alias}

    # startup_DEFAULT.log Asik Master
    # Location of startup_DEFAULT.log.xz file has changed since 19B.
    ${status1}                       ssh.File Exists    /tmp/startup_DEFAULT.log    connection=${alias}
    ${status2_19A}                       ssh.File Exists    /ffs/run/logs/0x1011_aasyslog/startup_DEFAULT.log.xz    connection=${alias}
    ${status2_19B}                       ssh.File Exists    /ffs/run/logs/fct-0a_aasyslog/startup_DEFAULT.log.xz    connection=${alias}
    ${startup_DEFAULT}              Run Keyword If  '${status2_19A}'=='True' or '${status2_19B}'=='True'    Set variable    startup_DEFAULT.log.xz
    ...                             ELSE                                  Set variable    startup_DEFAULT.log

    ${file_path_tmp}                joinpath       ${path_tmp}      ASIK_${startup_DEFAULT}

    Run Keyword If    '${status2_19B}'=='True'    ssh.download file      /ffs/run/logs/fct-0a_aasyslog/${startup_DEFAULT}    ${file_path_tmp}
    ...                                                              connection=${alias}
    Run Keyword If    '${status2_19A}'=='True'    ssh.download file      /ffs/run/logs/0x1011_aasyslog/${startup_DEFAULT}    ${file_path_tmp}
    ...                                                              connection=${alias}
    Run Keyword If    '${status1}'=='True'    ssh.download file      /tmp/${startup_DEFAULT}    ${file_path_tmp}    connection=${alias}

    file should not be empty        ${file_path_tmp}                ${file_path_tmp} abnormaly empty

    # startup_BTSOM.log Asik Master: this file can be removed before the cell is activated. Its absence shall not be considered as an error.
    ${file_path_tmp}                joinpath       ${path_tmp}      ASIK_startup_BTSOM.log
    ${status1}                      ssh.File Exists    /tmp/startup_DEFAULT.log    connection=${alias}
    Run keyword and ignore error    ssh.download file               /tmp/startup_BTSOM.log    ${file_path_tmp}          connection=${alias}


    # startup_DEFAULT.log Asik Slave
    ${status}                       ssh.File Exists    /tmp/startup_DEFAULT.log    connection=asikSlaveCnx
    ${startup_DEFAULT}              Run Keyword If  '${status}'=='True'    Set variable    startup_DEFAULT.log
    ...                             ELSE                                  Set variable    startup_DEFAULT.log.xz
    ${file_path_tmp}                joinpath       ${path_tmp}      ASIK-slave_${startup_DEFAULT}
    ssh.download file               /tmp/${startup_DEFAULT}      ${file_path_tmp}           connection=asikSlaveCnx
    file should not be empty        ${file_path_tmp}                ${file_path_tmp} abnormaly empty

Get L1 logs on Abil Loner
    [Documentation]     collection of loner and L1 control log file from Abil
    ...                 TAF used: transport.ssh
	${path_tmp}                     joinpath       ${logs_path}    DU/Abil/L1
    create directory                ${path_tmp}

    ${file_path_tmp}                joinpath        ${path_tmp}      Loner_L1_Journal.gz
    ssh.execute                     journalctl -b > //tmp//Loner_L1_Journal.txt               connection=abilLonerCnx
    ssh.execute                     gzip /tmp/Loner_L1_Journal.txt   connection=abilLonerCnx
    ssh.download file               /tmp/Loner_L1_Journal.txt.gz            ${file_path_tmp}     connection=abilLonerCnx
    ssh.execute                     rm /tmp/Loner_L1_Journal.txt.gz   connection=abilLonerCnx
	${status}                       ssh.execute     ls -lrt /var/log/l1sw-startup.log    connection=abilLonerCnx
    ${info}                         Set Variable    No such file or directory
    ${match}     ${value} =         Run Keyword And Ignore Error    Should Contain     ${status}     ${info}
    ${status2}                      ssh.execute     ls -lrt /var/log/l1sw-startup.tgz    connection=abilLonerCnx
    ${info2}                        Set Variable    No such file or directory
    ${match2}     ${value2} =       Run Keyword And Ignore Error    Should Contain     ${status2}     ${info2}
    ${L1sw_startup}                 Run Keyword If  '${match}'=='FAIL'    Set variable    l1sw-startup.log
    ...                             ELSE IF         '${match2}'=='FAIL'   Set variable    l1sw-startup.tgz
    ...                             ELSE            Log             "Not l1sw-startup.tgz neither l1sw-startup.log file exists"
	${file_path_tmp}                joinpath       ${path_tmp}      Loner_${L1sw_startup}
	Run keyword and ignore error    ssh.download file	   /var/log/${L1sw_startup}	     ${file_path_tmp}    connection=abilLonerCnx
	Run keyword and ignore error    file should not be empty        ${file_path_tmp}     ${file_path_tmp} abnormaly empty

Get ru_asik IP address
    [Documentation]           Look for RU ip address on dhcpd.conf and dhcpd_eoc.conf asik files.
    ...                       Then, return RU ip address that provides a succesfull ssh connection
    ...                       TAF used: ssh version 4.1.0
    ...                       Author: Jacob
    ...                       Update 20181120: S. Croquet - Add proxy as argument
    ...                       Update 20190118: EricBP - new file reading: dhcpd.lease. Just this read should be sufficient(if tbc,to be simplified)
    [Arguments]               ${proxy}=asikFhCnx
    ${result_ligne}           ssh.execute
    ...   command=cat /var/lib/radio-dhcpd/dhcpd.conf | grep -E -o "range *([0-9]+.[0-9]+.[0-9]+.[0-9]+) [0-9]+.[0-9]+.[0-9]+.[0-9]+"
    ...   connection=${proxy}
    @{result}                 Split String    ${result_ligne}   ${EMPTY}
    ${ru_address_1}           set variable  ${result[2]}
    ${ru_address_1_W}         Run Keyword and Return Status    ssh.Connect To   ${ru_address_1}  root   umniedziala   proxy=${proxy}   alias=rucnx
    ${result_ligne}           ssh.execute
    ...   command=cat /var/lib/radio-dhcpd/dhcpd_eoc.conf | grep -E -o "range *([0-9]+.[0-9]+.[0-9]+.[0-9]+) [0-9]+.[0-9]+.[0-9]+.[0-9]+"
    ...   connection=${proxy}
    @{result}                 Split String    ${result_ligne}   ${EMPTY}
    ${ru_address_2}           set variable  ${result[10]}
    ${ru_address_2_W}         Run Keyword and Return Status    ssh.Connect To   ${ru_address_2}  root   umniedziala   proxy=${proxy}   alias=rucnx
    ${result_ligne}           ssh.execute     command=cat /var/lib/radio-dhcpd/dhcpd.leases | grep -E -o "lease *([0-9]+.[0-9]+.[0-9]+.[0-9]+)"
    ...                       connection=${proxy}

    log                       ${ru_address_1_W}
    log                       ${ru_address_2_W}
    ${ru_asik}                Run keyword if    ${ru_address_1_W} == True        Set variable  ${ru_address_1}
    ...                       ELSE IF           ${ru_address_2_W} == True        Set variable  ${ru_address_2}
    Set suite variable         ${ru_asik}


Get RU IP On Loner
    [Documentation]    Get RU IP address from ARP entry table.
    ...                It is assumed interface rlan0 is used for RU connection.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Author: Stephane Croquet - 20190404
    ...                Modified: Jacob Velasco - 17072019 to be attapted to eCPRI: arb0p3.295 or rlan0
    ${ip_tmp}         ssh.execute     ip n | grep rlan0     connection=abilLonerCnx
    ${status}         Run Keyword and Return Status       Should contain     ${ip_tmp}    rlan0
    Run Keyword If    '${status}'=='False'      set suite variable       ${RU_intf}      arb0p3.295
    ...                             ELSE       set suite variable       ${RU_intf}      rlan0
    ${ip}          ssh.execute     ip n | grep ${RU_intf} | grep -E -o '^[0-9]+.[0-9]+.[0-9]+.[0-9]+'     connection=abilLonerCnx
    log                       ${ip}

    ${ip}            fetch from left     ${ip}   \r\n

    [Return]           ${ip}


Get RU Logs From CPRI
    [Documentation]    Get log from RU using CPRI connection.
    ...                New version of the preivous keyword using a new method to get RU IP
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Argument:
    ...                     asikCnx: alias for ASIK Xeon Master
    ...                Author: Stephane Croquet - 20190404
    [Arguments]     ${asikCnx}

    #bypass robocop
    ${asikCnx}    set variable    ${asikCnx}
    ${ipRU}            Get RU IP On Loner
    ssh.Connect To	   ${ipRU}       root      umniedziala 	 proxy=abilLonerCnx   alias=rucnx
    ${path_tmp}                        joinpath                    ${logs_path}     RU
    create directory                   ${path_tmp}
    ${file_path_tmp}                   joinpath                     ${path_tmp}                         logFpgaFull
    ${return}                          ssh.execute                 command= /usr/bin/ccsShell.sh log -c full            connection=rucnx
	append to file                     ${path_tmp}/logFpgaFull.txt                       ${return}
    Run Keyword and continue on failure      ssh.download file	   /ram/1011_startup.zip		  ${path_tmp}   connection=rucnx
    Run Keyword and continue on failure      ssh.download file	   /ram/1011_runtime.zip	      ${path_tmp}   connection=rucnx
    Run Keyword and continue on failure      ssh.download file	   /ram/startup_DEFAULT.log.xz	  ${path_tmp}   connection=rucnx
    Run Keyword and continue on failure      ssh.download file	   /ram/UnitOAM_SOAP_Log.xml	  ${path_tmp}   connection=rucnx
    ssh.disconnect     connection=rucnx


Get RU logs
    [Documentation]
    ...                       Update 20181120: S. Croquet - Add proxy as argument
    [Arguments]    ${CnxToRU}=CPRI    ${proxy}=asikFhCnx     #CPRI or TestVMRU
    Run Keyword and Return Status      Run Keyword if              '${CnxToRU}' == 'TestVMRU'
    ...                                ssh.Connect To	            ${testVM_ru}       localuser        10c@1user	alias=testVM_ru
    Run Keyword and Return Status      Run Keyword if              '${CnxToRU}' == 'TestVMRU'
    ...                                ssh.Connect To	            ${ru_VM}       root      umniedziala 	 proxy=testVM_ru  alias=rucnx
    Run Keyword and Return Status      Run Keyword if              '${CnxToRU}' == 'CPRI'
    ...                                logs.Get ru_asik IP address  proxy=${proxy}
    ${path_tmp}                        joinpath                    ${logs_path}     RU
    create directory                   ${path_tmp}
    ${file_path_tmp}                   joinpath                     ${path_tmp}                         logFpgaFull
    ${return}                          ssh.execute                 command= /usr/bin/ccsShell.sh log -c full            connection=rucnx
	append to file                     ${path_tmp}/logFpgaFull.txt                       ${return}
    Run Keyword and continue on failure      ssh.download file				   /ram/1011_startup.zip		  ${path_tmp}   connection=rucnx
    Run Keyword and continue on failure      ssh.download file				   /ram/1011_runtime.zip	      ${path_tmp}   connection=rucnx
    Run Keyword and continue on failure      ssh.download file				   /ram/startup_DEFAULT.log.xz	  ${path_tmp}   connection=rucnx
    Run Keyword and continue on failure      ssh.download file				   /ram/UnitOAM_SOAP_Log.xml	  ${path_tmp}   connection=rucnx
    ssh.disconnect                     connection=rucnx
    Run Keyword and Return Status      Run Keyword if   '${CnxToRU}' == 'TestVMRU'       ssh.disconnect        connection=testVM_ru


Get L2RT logs on Abil Xeon
    [Arguments]                 ${connection}       ${abil_xeon}

    #bypass robocop
    ${abil_xeon}    set variable    ${abil_xeon}

    ${path_tmp}                 joinpath        ${logs_path}    DU/Abil/L2
    create directory            ${path_tmp}
    ${xeon}                     Run Keyword If  '${connection}'=='abilXeonACnx'    Set variable    ABIL-XeonA
    ...                         ELSE                                               Set variable    ABIL-XeonB
    ${file_path_tmp}            joinpath        ${path_tmp}      ${xeon}_L2_Journal.gz
    ssh.execute                 journalctl -b > //tmp//${xeon}_L2_Journal.txt               connection=${connection}
    ssh.execute                 gzip /tmp/${xeon}_L2_Journal.txt   connection=${connection}
    ssh.download file           /tmp/${xeon}_L2_Journal.txt.gz            ${file_path_tmp}     connection=${connection}
    ssh.execute                 rm /tmp/${xeon}_L2_Journal.txt.gz   connection=${connection}

    ${status}                   ssh.execute     ls -lrt /tmp/startup_DEFAULT.log    connection=${connection}
    ${info}                     Set Variable    No such file or directory
    ${match}     ${value} =     Run Keyword And Ignore Error    Should Contain     ${status}     ${info}
    ${startup_DEFAULT}          Run Keyword If  '${match}'=='PASS'    Set variable    startup_DEFAULT.log.xz
    ...                         ELSE                                  Set variable    startup_DEFAULT.log
    ${file_path_tmp}            joinpath        ${path_tmp}     ${xeon}_${startup_DEFAULT}
    ssh.download file			/tmp/${startup_DEFAULT}	        ${file_path_tmp}		    connection=${connection}
	file should not be empty    ${file_path_tmp}                ${file_path_tmp} abnormaly empty

Read Abil Loner registers
    [Arguments]                 @{registers_list}
    [Documentation]             argument is a list of registers to be read (with or without the bytes number).
    ...                         it returns a list of lists of the registers values
    ...                         ${abil_loner}:   loner IP @ inerited from tlconfig.py
    ...                         asikcnx:    alias of the asik connection inherited from setup part of main script
    ...                         Taf used:   taf.transport.ssh (3.3.1)
    ...                         Author:     EricBP
    @{registers_values}         create list
    :FOR                        ${registerId}  IN     @{registers_list}
    \                           ${cmd}              set variable       fpga_rw ra ${registerId}
    \                           ${output}           ssh.execute        command=${cmd}     connection=abilLonerCnx
    \                           ${output}           remove string   ${output}   \r
    \                           should not contain  ${output}  error
    \                           should contain      ${output}  0x
    \                           @{list}             split string        ${output}   \n
    \                           remove from list    ${list}     -1
    \                           append to list      ${registers_values}    @{list}
    log many                    @{registers_values}
    [Return]                    @{registers_values}

Write Abil Loner registers
    [Arguments]                 @{registers_list}
    [Documentation]             argument is a list of lists of 2 values: 1st value is the registerId and second one is the value to be written.
    ...                         ${abil_loner}:   loner IP @ inerited from tlconfig.py
    ...                         asikcnx:    alias of the asik connection inherited from setup part of main script
    ...                         Taf used:   taf.transport.ssh (3.3.1)
    ...                         Author:     EricBP
    :FOR                        ${registers_data}    IN     @{registers_list}
    \                           ${cmd}              set variable       fpga_rw wa @{registers_data}[0] @{registers_data}[1]
    \                           log                 ${cmd}
    \                           ${output}           ssh.execute        command=${cmd}     connection=abilLonerCnx
    \                           should not contain  ${output}  error    ignore_case=True
    \                           ${cmd}              set variable       fpga_rw ra @{registers_data}[0]
    \                           ${output}           ssh.execute        command=${cmd}     connection=abilLonerCnx
    \                           ${test}             replace string     @{registers_data}[1]     0x  ${EMPTY}
    \                           should contain      ${output}   ${test}     ignore_case=True
    ##                          should be equal does not work in above line...

Get RU DDR4
	[Arguments]					${interface}  ${file_name}  ${duration}=1228800     ${proxy}=asikFhCnx
	[Documentation]				allows to retrieve in local results directory (result_XXX/logs/RU) the RU DDR4 dump for the interface specified
	...                         ${interface} captured specified by user can be either CPRI_DL0, CPRI_DL1, CPRI_UL0, CPRI_UL1, JESD_DL_ANT0,
	...                         JESD_DL_ANT1, JESD_UL_ANT0, JESD_UL_ANT1
	...							${file_path} will be concatenate with /RAM & file will be stored under /RAM
	...                         Author: EricBP
	...                         Update 20181109: for RU ssh connection open, keyword Get ru asik IP adress included
	...                         Update 20181120: S. Croquet - Add proxy as argument
	${interfaces_list}			create list  CPRI_DL0  CPRI_DL1  CPRI_UL0  CPRI_UL1  JESD_DL_ANT0  JESD_DL_ANT1  JESD_UL_ANT0  JESD_UL_ANT1
	#CPRI
	list should contain value	${interfaces_list}  ${interface}  interface specified is not part of the interfaces available
	${file_path}                joinpath   /ram     ${file_name}
	Get ru_asik IP address      proxy=${proxy}

	ssh.Connect To              ${ru_asik}      root    umniedziala     proxy=${proxy}    alias=rucnx
	${return}		ssh.execute  fpgaddr4access -b 0 -c cr -p 0 -i -s ${interface} -n ${duration} -t 3 -f hex2 ${file_path}  connection=rucnx

	log							${return}
	${local_path}               joinpath                    ${logs_path}     RU
    create directory            ${local_path}
    ${local_path}               joinpath                    ${local_path}     ${file_name}
	Run Keyword and continue on failure      ssh.download file     ${file_path}  ${local_path}  connection=rucnx
    ssh.disconnect              connection=rucnx

Get RU DDR4 eCPRI
	[Arguments]					${interface}  ${file_name}  ${duration}=1228800     ${proxy}=asikFhCnx
	[Documentation]				allows to retrieve in local results directory (result_XXX/logs/RU) the RU DDR4 dump for the interface specified
	...                         ${interface} captured specified by user can be either CPRI_DL0, CPRI_DL1, CPRI_UL0, CPRI_UL1, JESD_DL_ANT0,
	...                         JESD_DL_ANT1, JESD_UL_ANT0, JESD_UL_ANT1
	...							${file_path} will be concatenate with /RAM & file will be stored under /RAM
	...                         Author: EricBP
	...                         Update 20181109: for RU ssh connection open, keyword Get ru asik IP adress included
	...                         Update 20181120: S. Croquet - Add proxy as argument

    #bypass robocop
    ${proxy}    set variable    ${proxy}
    ${interfaces_list}			create list  FH_DL_INSERTALL  FH_UL_INSERTALL  RF_DL_INSERTALL  RF_UL_INSERTALL
	#eCPRI
	list should contain value	${interfaces_list}  ${interface}  interface specified is not part of the interfaces available
	${file_path}                joinpath   /ram     ${file_name}

	${ipRU}            Get RU IP On Loner
    ssh.Connect To	   ${ipRU}       root      umniedziala 	 proxy=abilLonerCnx   alias=rucnx

	${return}		ssh.execute  fpgaddr4access -b 1 -c cr -p 0 -s ${interface} -n ${duration} -t 2 -f hex2 -i -q 16 ${file_path}  connection=rucnx

	log							${return}
	${local_path}               joinpath                    ${logs_path}     RU
    create directory            ${local_path}
    ${local_path}               joinpath                    ${local_path}     ${file_name}
	Run Keyword and continue on failure      ssh.download file     ${file_path}  ${local_path}  connection=rucnx
    ssh.disconnect              connection=rucnx

Tcpdump Start
    [Arguments]         ${interface}    ${session}    ${outputName}    ${cmdPrefix}=${EMPTY}     ${fileNumber}=50
    ...                 ${filter}=${EMPTY}  ${timer}=0   ${X2C_filter}=${EMPTY}  ${fileSize}=90    ${delay}=0   ${sshSendCmd}=False
    ...                 ${board_socid}=0
    [Documentation]     Starts a tcpdump command over an user specified interface for a defined session.
    ...                 Can be used in 2 modes:
    ...                     -manual, dump has to be manually stopped. Timeout also added in update
    ...                     -automatic, dump is stopped automatically after specified timer expiry
    ...                 Parameters:
    ...                     -interface: Interface name on the system
    ...                     -session: Alias of the session
    ...                     -outputName: output file name to be used
    ...                     -cmdPrefix: Privileges are required on some system. This option allows to run in an autonomous way
    ...                                 the command on the different systems. The command sent is modified, a prefix is added.
    ...                                 For example on BB3, sudo and password to specify, prefix shoudl be "echo password | sudo -S"
    ...                     -fileNUmber: Number of pcap files
    ...                     -filter: Capture filter
    ...                     -X2C_filter: to filter on @ip. Syntax must be "host @ip"
    ...                     -timer: timer used by the automatic mode. By default 0 (Manual mode)
    ...                     -fileSize: pcap file size . Optional, 90 by default
    ...                     -delay: timer to delay the tcpdump start, 0 by default
    ...                     -sshSendCmd: Allow to send the tcpdump with "ssh.send command" (ie manual mode) and a timeout
    ...                 Tips:
    ...                     -to run in automatic, timer has to be set
    ...                     -to run in manual without timeout, sshSendCmd has to be set to True
    ...                     -to run in manual with timeout, sshSendCmd has to be set to True and timer has to set
    ...                     -if sshSendCmd is set to true and no timer is specified, the test will fail
    ...                 Taf used: taf.transport.ssh version 4.1.0
    ...                 Autor: Stephane Croquet
    ...                 Update: Zak (28/01/2019): Add X2C_filter option
    ...                 Updtate: S. Croquet (29/01/2019): Add timer,fileSize, delay, sshSendCmd options
    ...                 Updtate: S. Croquet (07/05/2019): Add -U option (avoid to have empty pcap files)
    ...                 Update: A. NEZROUK  (31/03/2021): Add bsh script usage.
    ${date}    get current date    result_format=%Y%m%d_%H%M
    ${fileName}    set variable    ${outputName}_${date}.pcap
    ${tcpDumpCmd}=    Set Variable If    '${delay}'!='0'    sleep ${delay} &&    ${EMPTY}
    ${tcpDumpCmd}    Run Keyword If    '${cmdPrefix}'!='${EMPTY}' and '${tcpDumpCmd}'!='${EMPTY}'
    ...        catenate    SEPARATOR=${SPACE}    ${tcpDumpCmd}    ${cmdPrefix}
    ...              ELSE IF    '${tcpDumpCmd}'=='${EMPTY}' and '${cmdPrefix}'!='${EMPTY}'
    ...        catenate    SEPARATOR=    ${cmdPrefix}
    ...             ELSE
    ...        catenate    SEPARATOR=    ${tcpDumpCmd}
    ${tcpDumpCmd}    Run Keyword If    '${timer}'!='0' and '${tcpDumpCmd}'!='${EMPTY}'
    ...        catenate    SEPARATOR=${SPACE}    ${tcpDumpCmd}    timeout ${timer}
    ...             ELSE IF    '${timer}'!='0'
    ...        catenate    SEPARATOR=    timeout ${timer}
    ...             ELSE
    ...        catenate    SEPARATOR=    ${tcpDumpCmd}
    ${tcpDumpCmd}=    Run Keyword If    '${board_socid}'!='0'
    ...        catenate    SEPARATOR=${SPACE}    bsh ${board_socid}    ${tcpDumpCmd}
    ...        tcpdump "${filter}" -i ${interface} ${X2C_filter} -C ${filesize} -B 9000 -U -w /tmp/${fileName} -W ${fileNumber}
    ...               ELSE
    ...         catenate    SEPARATOR=${SPACE}    ${tcpDumpCmd}
    ...         tcpdump "${filter}" -i ${interface} ${X2C_filter} -C ${filesize} -B 9000 -U -w /tmp/${fileName} -W ${fileNumber}
    log    ${tcpDumpCmd}
    run keyword if    ${sshSendCmd} or '${board_socid}'!='0' or '${timer}'=='0'
    ...         ssh.send command      command=${tcpDumpCmd}    connection=${session}
    ...               ELSE IF     ${timer} != 0
    ...         ssh.execute           command=${tcpDumpCmd}    connection=${session}
    ...               ELSE
    ...         fail    Not Supported TCP Dump Options
    [Return]                    ${fileName}



Tcpdump Stop And Collect
    [Arguments]                 ${interface}    ${session}  ${outputName}  ${outputPath}     ${cmdPrefix}=${EMPTY}
    ...                         ${board_socid}=0
    [Documentation]             Kill the tcpdump process related to the specified interface/session
    ...                         Parameters:
    ...                             -interface: Interface name on the system
    ...                             -session: Alias of the session
    ...                             -outputName: output file name to be used
    ...                             -outputPath: target directory to collect the files
    ...                             -cmdPrefix: Privileges are required on some system. This option allows to run in an autonomous way
    ...                                         the command on the different systems. The command sent is modified, a prefix is added.
    ...                                         For example on BB3, sudo and password to specify, prefix shoudl be "echo password | sudo -S"
    ...                         Taf used: taf.transport.ssh version 4.1.0
    ...                         Autor: Stephane Croquet
    ...                         Update 20202805 Fabienne Magueur: remove files on target once downloaded on test VM
    ...                         Update 20210321 Abderrahmane NEZROUK usage of bsr/bget commands
    Kill Tcpdump Process        ${interface}    ${session}    ${board_socid}
    log                         ${interface}
    log                         ${session}
    log                         ${outputName}
    log                         ${outputPath}
    log                         ${cmdPrefix}
    ${path_tmp}  joinpath       ${res_path}     ${outputPath}
    create directory            ${path_tmp}
    set suite variable          ${path_tcpdump}     ${path_tmp}
    directory should exist      ${path_tmp}         ${path_tmp} directory should be created
    ${file_names_tcpdump}       Function search filenames       /tmp    ${outputName}   ${session}    board_socid=${board_socid}
    :FOR                        ${i}    IN  @{file_names_tcpdump}
    \                           Exit For Loop IF    '${board_socid}'=='0'
    \                           ${cmd}    set variable    bget ${board_socid} /tmp/${i} /tmp
    \                           ssh.execute                 command=${cmd}    connection=${session}
    \                           Run keyword and ignore error    ssh.execute    bsh ${board_socid} rm /tmp/${i}    connection=${session}
    \                           ${xpath_tmp}                 joinpath            ${path_tmp}     ${i}
    \                           ssh.download file           /tmp/${i}           ${xpath_tmp}   connection=${session}
    \                           ${cmd}    set variable    ${cmdPrefix} rm /tmp/${i}
    \                           ${rm_status}    ${rm_error}    Run keyword and ignore error    ssh.execute    ${cmd}    connection=${session}

    :FOR                        ${i}    IN  @{file_names_tcpdump}
    \                           Exit For Loop IF    '${board_socid}'!='0'
    \                           ${xpath_tmp}                 joinpath            ${path_tmp}     ${i}
    \                           ssh.download file           /tmp/${i}           ${xpath_tmp}   connection=${session}
    \                           ${cmd}    set variable    ${cmdPrefix} rm /tmp/${i}
    \                           ${rm_status}    ${rm_error}    Run keyword and ignore error    ssh.execute    ${cmd}    connection=${session}

    [Return]                    @{file_names_tcpdump}[0]


Kill Tcpdump Process
    [Arguments]                 ${interface}    ${session}    ${board_socid}=0
    [Documentation]             Kill the tcpdump process related to the specified interface/session
    ...                         Parameters:
    ...                             -interface: Interface name on the system
    ...                             -session: Alias of the session

    ${cmd}                      Run Keyword If    '${board_socid}'=='0'
    ...          set variable   kill -9 `ps -ef | grep -E '^[tcpdump|root]' | grep ${interface} | awk '{print $2}'`
    ...                         ELSE
    ...          set variable   bsh ${board_socid} pkill -2 tcpdump
    ssh.execute                 command=${cmd}    connection=${session}


Get L2Counter
    [Documentation]             Collect L2 Counters on Abil XeonA
    ...                         Arguments:
    ...                             -${cmd}: L2CounterClient command with required options
    ...                             -${counterFile}: file name to log the counters
    ...                         Counter file is stored in the logs directory (hardcoded) with given name.
    ...                         Temporary file on ABIL is automatically deleted
    ...                         Author: Stephane Croquet - 20181206
    [Arguments]     ${cmd}     ${counterFile}
    ssh.execute         ${cmd} > /tmp/L2Counter_Before.txt     connection=abilXeonACnx
    ${file_path_tmp}    joinpath        ${logs_path}      ${counterFile}
    ssh.download file   /tmp/L2Counter_Before.txt      ${file_path_tmp}     connection=abilXeonACnx
    ssh.execute         rm /tmp/L2Counter_Before.txt   connection=abilXeonACnx


Get Counter Value
    [Documentation]             Extract 1 counter from counter file. Return an integer.
    ...                         Arguments:
    ...                             -${counterName}: Name of counter to be extracted
    ...                             -${counterFile}: counter file name
    ...                         Author: Stephane Croquet - 20181206
    [Arguments]     ${counterName}      ${counterFile}
    ${line}=    OperatingSystem.Grep File   ${counterFile}    ${counterName}
    ${stringValue}=     Get Regexp Matches      ${line}     :\\s+(\\d+)     1
    ${intValue}=      Convert To Number      ${stringValue[0]}
    [return]    ${intValue}


Get Full Logs
    [Documentation]
    ...     Author: Stephane Croquet - 20181206
    ...     Update: EricBP - 20190215
    ...     Update: Stephane Croquet - 20190320
    ...     Update: Stephane Croquet - 20191002 - Add collect snapshot for cOAM
    ...     Update: Stephane Croquet - 20191030 - Updates due to init.py alignment
    log     ******* COLLECT CU/DU/RU *******
    Run keyword if    '${oam_type}' == 'COAM'                logs.COAM Get Snapshot
    ...     ELSE       logs.Cloud Get Full Logs

COAM Get Snapshot
    [Documentation]     Get snapshot
    ...     Author: Stephane Croquet - 20191002
    ...     20202805 Fabienne Magueur: update coam.get_snapshot parameters
    coam.get_snapshot       ${logs_path}/snapshot    Full    True    360    coamCnx

Cloud Get Full Logs
    logs.Cloud all CU journal collection     &{vm_ip_addr}
    logs.Cloud Get Cu oam logs
    logs.get asik logs  alias=asikFhCnx
    logs.Get L2RT logs on Abil Xeon     abilXeonACnx        ${abil_xeonA}
    logs.Get L2RT logs on Abil Xeon     abilXeonBCnx        ${abil_xeonB}
    logs.get L1 logs on Abil Loner


Classical Get Full Logs
    logs.Classical Get all containers logs
    logs.get asik logs  alias=asikFhCnx
    logs.get L1 logs on Abil Loner
    logs.Get L2RT logs on Abil Xeon     abilXeonACnx        ${abil_xeonA}
    logs.Get L2RT logs on Abil Xeon     abilXeonBCnx        ${abil_xeonB}


Classical Get all containers logs
    [Arguments]         ${asik_alias}=asikcnx  ${asik_slave_alias}=asikSlaveCnx
    [Documentation]     collection of logs of all containers of each asik process, master & slave. containers are specified through
    ...                 2 lists specified in config file. the keyword calls other keyword Classical Get containers logs
    ...                 Author: Nesar Hewad - 20190215

    #bypass robocop
    ${asik_alias}    set variable    ${asik_alias}
    ${asik_slave_alias}    set variable    ${asik_slave_alias}
    logs.Classical Get containers logs   asikFhCnx   @{asik_master_containers}
    logs.Classical Get containers logs   asikSlaveCnx   @{asik_slave_containers}


Classical Get containers logs
    [Arguments]         ${connection}       @{containers_list}
    [Documentation]     collection of all the logs of all containers (specified in @{containers_list}) on the specified asik,
    ...                 master or slave (${connection})
    ...                 Author: Nesar Hewad - 20190215
    :FOR                    ${containers}   IN          @{containers_list}
    \                       ssh.send command            cd /tmp/node_${containers}/tmp               connection=${connection}
    \                       ssh.send command            mkdir /tmp/${containers}                     connection=${connection}
    \                       ssh.send command            cp /tmp/node_${containers}/tmp/startup_* /tmp/${containers}   connection=${connection}
    \                       ssh.execute                 tar -cvf /tmp/${containers}.tar /tmp/${containers}  connection=${connection}
    \                       ${path_tmp}                 joinpath            ${logs_path}    DU/Asik/Node_${containers}
    \                       create directory            ${path_tmp}
    \                       directory should exist      ${path_tmp}         ${path_tmp} directory should be created
    \                       ssh.download file           /tmp/${containers}.tar      ${path_tmp}/${containers}.tar    connection=${connection}
    \                       file should not be empty    ${path_tmp}/${containers}.tar    ${path_tmp}/${containers}.tar abnormaly empty
    \                       ssh.execute                 rm -r /tmp/${containers}  connection=${connection}
    \                       ssh.execute                 rm -r /tmp/${containers}.tar  connection=${connection}


Start L1L2 Traces
    [Documentation]    Start L1L2 Traces.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                It is assumed that X2 traces gNB are captured on mirroring point 1 with sudo specific commands.
    ...                Only one syscom trace capture can be started. It has to be stopped before starting a new one.
    ...                Configure BIP L1L2 message mirroring.
    ...                Argument:
    ...                     procedure: prefix for trace naming
    ...                Author: Stephane Croquet - 20190404
    ...                Updtate: S. Croquet (07/05/2019): Add ${filter} argument. Correct typo mistake in trace name.
    [Arguments]        ${procedure}     ${filter}
    log     ******* START L1L2 TRACES *******
    run keyword if      '${GNB_Architecture}' == 'CLOUD'
    ...                 configuration.BIP L1L2 message mirroring configuration        asikFhCnx
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 configuration.BIP L1L2 message mirroring configuration        ${oam_alias}
    ${traceNameL1L2}=    run keyword     logs.Tcpdump Start
    ...     ${L1L2_itf}
    ...     mirroringCnx
    ...     ${procedure}_L1L2_${GNB_Friendly_TL_Name}
    ...     cmdPrefix=${sudoCommand1}
    ...     filter=${filter}
    set test variable   ${traceNameL1L2}    ${traceNameL1L2}

Stop L1L2 Traces
    [Documentation]    Stop L1L2 Traces.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Author: Stephane Croquet - 20190404
    log     ******* STOP L1L2 TRACES *******
    logs.Tcpdump Stop And Collect
    ...     ${L1L2_itf}
    ...     mirroringCnx
    ...     ${traceNameL1L2}
    ...     logs/tcpdump/
    ...     cmdPrefix=${sudoCommand1}

Start Syscom Traces
    [Documentation]    Start syscom Traces.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Only one syscom trace capture can be started. It has to be stopped before starting a new one.
    ...                Argument:
    ...                     procedure: prefix for trace naming
    ...                Author: Stephane Croquet - 20190404
    [Arguments]       ${procedure}    ${board_socid}=0
    run keyword if      '${GNB_Architecture}' == 'CLOUD'
    ...                 logs.Start Syscom Traces Cloud        ${procedure}    ${board_socid}
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 logs.Start Syscom Traces Classical    ${procedure}    ${board_socid}

Start Syscom Traces Cloud
    [Documentation]    Start syscom traces on cloud gNB.
    ...                It is assumed that syscom traces on cloud gNB are captured on ASIK Master.
    ...                Argument:
    ...                     procedure: prefix for trace naming
    ...                Author: Stephane Croquet - 20190404
    [Arguments]          ${procedure}    ${board_socid}
    log     ******* START SYSCOM TRACES - CLOUD *******
    ${traceNameSyscom}=      run keyword     logs.Tcpdump Start
    ...     ${syscom_itf}
    ...     asikFhCnx
    ...     ${procedure}_syscomAsik_${GNB_Friendly_TL_Name}
    ...     board_socid=${board_socid}


    set test variable   ${traceNameSyscom}     ${traceNameSyscom}

Start Syscom Traces Classical
    [Documentation]    Start syscom traces on classical gNB.
    ...                It is assumed that syscom traces on classical gNB are captured on ASIK Slave.
    ...                Argument:
    ...                     procedure: prefix for trace naming
    ...                Author: Stephane Croquet - 20190404
    [Arguments]          ${procedure}    ${board_socid}=0
    log     ******* START SYSCOM TRACES - CLASSICAL *******
    ${connection}    Set Variable If    '${board_socid}'!='0'    asikFhCnx    asikSlaveCnx
    Run Keyword If    '${connection}'=='asikFhCnx'
    ...    wait until keyword succeeds    5 min     30 sec     ssh.force reconnect     asikFhCnx

    ${traceNameSyscom}=      run keyword     logs.Tcpdump Start
    ...     ${syscom_itf}
    ...     ${connection}
    ...     ${procedure}_syscomAsik_${GNB_Friendly_TL_Name}
    ...     board_socid=${board_socid}
    set test variable   ${traceNameSyscom}     ${traceNameSyscom}

Stop Syscom Traces
    [Documentation]    Stop Syscom Traces.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Author: Stephane Croquet - 20190404
    ...                Update
    [Arguments]        ${board_socid}=0
    run keyword if      '${GNB_Architecture}' == 'CLOUD'
    ...                 logs.Stop Syscom Traces Cloud
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 logs.Stop Syscom Traces Classical    ${board_socid}

Stop Syscom Traces Cloud
    [Documentation]    Stop syscom traces on cloud gNB.
    ...                Author: Stephane Croquet - 20190404
    log     ******* STOP SYSCOM TRACES - CLOUD *******
    logs.Tcpdump Stop And Collect
    ...     ${syscom_itf}
    ...     asikFhCnx
    ...     ${traceNameSyscom}
    ...     logs/tcpdump/

Stop Syscom Traces Classical
    [Documentation]    Stop syscom traces on classical gNB.
    ...                Author: Stephane Croquet - 20190404
    ...                Update
    [Arguments]        ${board_socid}=0
    log     ******* STOP SYSCOM TRACES - CLASSICAL *******
    ${connection}    Set Variable If    '${board_socid}'!='0'    asikFhCnx    asikSlaveCnx
    logs.Tcpdump Stop And Collect
    ...     ${syscom_itf}
    ...     ${connection}
    ...     ${traceNameSyscom}
    ...     logs/tcpdump/
    ...     board_socid=${board_socid}

Start X2 Traces
    [Documentation]    Start X2 Traces.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Only one syscom trace capture can be started. It has to be stopped before starting a new one.
    ...                Argument:
    ...                     procedure: prefix for trace naming
    ...                Author: Stephane Croquet - 20190404
    [Arguments]          ${procedure}    ${timer}=60
    run keyword if      '${GNB_Architecture}' == 'CLOUD'
    ...                 logs.Start X2 Traces Cloud        ${procedure}
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 logs.Start X2 Traces Classical    ${procedure}    ${timer}

Start X2 Traces Cloud
    [Documentation]    Start X2 traces on cloud gNB.
    ...                It is assumed that X2 traces on cloud gNB are captured on mirroring point 2 with sudo specific commands.
    ...                Argument:
    ...                     procedure: prefix for trace naming
    ...                Author: Stephane Croquet - 20190404
    ...                Update: Stephane Croquet - 20190502 Add parameter X2C_filter (too much traffic captured on CLOUD gNBs)
    [Arguments]          ${procedure}
    log     ******* START X2 TRACES - CLOUD *******
    ${traceNameX2Backhaul}=    run keyword     logs.Tcpdump Start
    ...     ${S1X2_itf}
    ...     mirroringCnx2
    ...     ${procedure}_X2_${GNB_Friendly_TL_Name}
    ...     cmdPrefix=${sudoCommand2}
    ...     X2C_filter=${S1X2_FILTER_HOST}
    set test variable   ${traceNameX2Backhaul}    ${traceNameX2Backhaul}

Start X2 Traces Classical
    [Documentation]    Start X2 traces on classical gNB.
    ...                It is assumed that X2 traces on classical gNB are captured on backhaul interface of ASIK Master.
    ...                Argument:
    ...                     procedure: prefix for trace naming
    ...                Author: Stephane Croquet - 20190404
    ...                Update 20200528 Fabienne Magueur: get interface name from __init__.py
    [Arguments]          ${procedure}     ${timer}=60
    ${x2c_vlan}=    Convert to string    ${tl.gnbs[0].cu.x2c.vlan_id}
    ${backhaul_itf}=    Catenate    SEPARATOR=.    fp0    ${x2c_vlan}
    #${GNB_Friendly_TL_Name}=    Set variable    ${tl_name}
    log                ******* START X2 TRACES - CLASSICAL *******
    ${traceNameX2Backhaul}=    run keyword     logs.Tcpdump Start
    ...     interface=${backhaul_itf}
    ...     session=asikFhCnx
    ...     outputName=${procedure}_X2_${GNB_Friendly_TL_Name}
    ...     cmdPrefix=
    ...     fileNumber=1
    ...     filter=
    ...     timer=${timer}
    ...     X2C_filter=
    ...     fileSize=90
    ...     delay=0
    ...     sshSendCmd=True
    set test variable   ${traceNameX2Backhaul}    ${traceNameX2Backhaul}

Stop X2 Traces
    [Documentation]    Stop X2 Traces.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Author: Stephane Croquet - 20190404
    run keyword if      '${GNB_Architecture}' == 'CLOUD'
    ...                 logs.Stop X2 Traces Cloud
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 logs.Stop X2 Traces Classical

Stop X2 Traces Cloud
    [Documentation]    Stop X2 traces on cloud gNB.
    ...                Author: Stephane Croquet - 20190404
    log     ******* STOP X2 TRACES - CLOUD *******
    logs.Tcpdump Stop And Collect
    ...     ${S1X2_itf}
    ...     mirroringCnx2
    ...     ${traceNameX2Backhaul}
    ...     logs/tcpdump/
    ...     cmdPrefix=${sudoCommand2}

Stop X2 Traces Classical
    [Documentation]    Stop X2 traces on classical gNB.
    ...                Author: Stephane Croquet - 20190404
    ...                Update 20200528 Fabienne Magueur: get interface name from __init__.py

    ${x2c_vlan}=    Convert to string    ${tl.gnbs[0].cu.x2c.vlan_id}
    ${backhaul_itf}=    Catenate    SEPARATOR=.    fp0    ${x2c_vlan}
    log                ******* STOP X2 TRACES - CLASSICAL *******
    logs.Tcpdump Stop And Collect
    ...     ${backhaul_itf}
    ...     asikFhCnx
    ...     ${traceNameX2Backhaul}
    ...     logs/tcpdump/

Clean L1L2 Mirroring
    [Documentation]    Kill tcpdump sessions and remove pcap files started for L1L2 traces.
    ...                It is assumed that X2 traces on cloud gNB are captured on mirroring point 2 with sudo specific commands.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Author: Stephane Croquet - 20190404
    run keyword and continue on failure   logs.Tcpdump kill
    ...     ${L1L2_itf}
    ...     mirroringCnx
    ...     cmdPrefix=${sudoCommand1}
    run keyword and continue on failure   ssh.execute
    ...     command=${sudoCommand1} rm /tmp/*pcap*
    ...     connection=mirroringCnx

Clean Syscom Mirroring
    [Documentation]    Kill tcpdump sessions and remove pcap files started for syscom traces.
    ...                To be run in Teardown session. All pcap are removed.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Author: Stephane Croquet - 20190404
    run keyword if     '${GNB_Architecture}' == 'CLOUD'
    ...                logs.Clean Syscom Mirroring Cloud
    run keyword if     '${GNB_Architecture}' == 'CLASSICAL'
    ...                logs.Clean Syscom Mirroring Classical

Clean Syscom Mirroring Cloud
    [Documentation]    Kill tcpdump sessions and remove pcap files started for syscom traces on cloud gNB.
    ...                It is assumed that syscom traces on cloud gNB are captured on ASIK Master.
    ...                Author: Stephane Croquet - 20190404
    run keyword and continue on failure   logs.Tcpdump kill
    ...     ${syscom_itf}
    ...     asikFhCnx
    run keyword and continue on failure   ssh.execute
    ...     command=rm /tmp/*pcap*
    ...     connection=asikFhCnx

Clean Syscom Mirroring Classical
    [Documentation]    Kill tcpdump sessions and remove pcap files started for syscom traces on classical gNB.
    ...                It is assumed that syscom traces on cloud gNB are captured on ASIK Slave.
    ...                Author: Stephane Croquet - 20190404
    run keyword and continue on failure   logs.Tcpdump kill
    ...     ${syscom_itf}
    ...     asikSlaveCnx
    run keyword and continue on failure   ssh.execute
    ...     command=rm /tmp/*pcap*
    ...     connection=asikSlaveCnx

Clean X2 Mirroring
    [Documentation]    Kill tcpdump sessions and remove pcap files started for X2 traces.
    ...                To be run in Teardown session. All pcap are removed.
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Author: Stephane Croquet - 20190404
    run keyword if     '${GNB_Architecture}' == 'CLOUD'
    ...                logs.Clean X2 Mirroring Cloud
    run keyword if     '${GNB_Architecture}' == 'CLASSICAL'
    ...                logs.Clean X2 Mirroring Classical

Clean X2 Mirroring Cloud
    [Documentation]    Kill tcpdump sessions and remove pcap files started for X2 traces on cloud gNB.
    ...                It is assumed that X2 traces on cloud gNB are captured on mirroring point 2 with sudo specific commands.
    ...                Author: Stephane Croquet - 20190404
    run keyword and continue on failure   logs.Tcpdump kill
    ...     ${S1X2_itf}
    ...     mirroringCnx2
    ...     cmdPrefix=${sudoCommand2}
    run keyword and continue on failure   ssh.execute
    ...     command=${sudoCommand2} rm /tmp/*pcap*
    ...     connection=mirroringCnx2

Clean X2 Mirroring Classical
    [Documentation]    Kill tcpdump sessions and remove pcap files started for X2 traces on classical gNB.
    ...                It is assumed that X2 traces on cloud gNB are captured on backhaul interface of ASIK Master.
    ...                Author: Stephane Croquet - 20190404
    run keyword and continue on failure   logs.Tcpdump kill
    ...     ${backhaul_itf}
    ...     ${oam_alias}
    run keyword and continue on failure   ssh.execute
    ...     command=rm /tmp/*pcap*
    ...     connection=${oam_alias}

Tcpdump Kill
    [Documentation]      Kill the tcpdump process related to the specified interface/session.
    ...                  Arguments:
    ...                      -interface: Interface name on the system
    ...                      -session: Alias of the session
    ...                      -cmdPrefix: Privileges are required on some system. This option allows to run in an autonomous way
    ...                                  the command on the different systems. The command sent is modified, a prefix is added.
    ...                                  For example on BB3, sudo and password has to be specified, the prefix has to be
    ...                                  used "echo password | sudo -S".
    ...                  Author: Stephane Croquet - 20190404
    [Arguments]          ${interface}    ${session}   ${cmdPrefix}=${EMPTY}

    ${output}            ssh.execute          command=ps -ef | grep -i tcpdump    connection=${session}
    log                  ${output}

    log                  ${cmdPrefix}
    ${cmd}               set variable    ${cmdPrefix} kill -9 `ps -ef | grep -E '^[tcpdump|root]' | grep ${interface} | awk '{print $2}'`
    log                  ${cmd}
    ${output}            ssh.execute          command=${cmd}    connection=${session}
    log                  ${output}

    ${output}            ssh.execute          command=ps -ef | grep -i tcpdump    connection=${session}
    log                  ${output}

Journal timing error
    logs.Get L2RT logs on Abil Xeon
    logs.Get L2RT logs on Abil Xeon    abilXeonBCnx
    logs.Get L1 logs on Abil Loner
    Run     echo 'XeonA\n' > ${logs_path}/journal_errors.txt
    Run     zgrep 'broken\\|tti too' ${logs_path}/DU/Abil/L2/*XeonA*.gz >> ${logs_path}/journal_errors.txt
    Run     echo '\nXeonB\n' >> ${logs_path}/journal_errors.txt
    Run     zgrep 'broken\\|tti too' ${logs_path}/DU/Abil/L2/*XeonB*.gz >> ${logs_path}/journal_errors.txt
    Run     echo '\nLoner\n' >> ${logs_path}/journal_errors.txt
    Run     zgrep 'Late m\\|gap\\|skip' ${logs_path}/DU/Abil/L1/*.gz >> ${logs_path}/journal_errors.txt

Check For Contention In ABIL - Step 1
    [Documentation]     Check that the contention is successfully done in L2PS traces. Current implemention: find
    ...                 flow control start message.
    ...                 Step 1: save current journal in temporary file
    ...                 Step 2: look for flow control msg  in temporary file
    ...                 gNB compatibility: Classical COAM (testing restriction)
    ...                 Autor: Stephane Croquet
    ...                 Creation: 02/10/2019
    ...                 22 09 2020: F.Magueur: add connection as argument
    [Arguments]          ${connection}=abilXeonACnx

    #ssh.send command    journalctl -f > /tmp/logForContention.log    connection=${connection}
    Run keyword and ignore error    ssh.file exists     /tmp/node_UPUE20/tmp/ASP-173A_startup.log     connection=${connection}
    Run keyword and ignore error    ssh.file exists     /tmp/node_UPUE00/tmp/ASC-1515_startup.log     connection=${connection}
    Run keyword if    '${system_module_type}' == 'ASIK'
    ...    ssh.send command    tail -f /tmp/node_UPUE20/tmp/ASP-173A_startup.log > /tmp/logForContention.log   connection=${connection}
    Run keyword if    '${system_module_type}' == 'ASOD'
    ...    ssh.send command    tail -f /tmp/node_UPUE00/tmp/ASC-1515_startup.log > /tmp/logForContention.log   connection=${connection}


Check For Contention In ABIL - Step 2
    [Documentation]     Check that the contention is successfully done in L2PS traces. Current implemention: find
    ...                 flow control start message.
    ...                 Step 1: save current journal in temporary file
    ...                 Step 2: look for flow control msg  in temporary file
    ...                 gNB compatibility: Classical COAM (testing restriction)
    ...                 Autor: Stephane Croquet
    ...                 Creation: 02/10/2019
    ...                 22 09 2020: F.Magueur: add connection as argument
    [Arguments]          ${connection}=abilXeonACnx

    ssh.execute  kill -9 `ps -ef | grep 'journalctl -f' | awk '{print $2}'`         connection=${connection}
    ${response}  ssh.execute    grep -ia "flow control started" /tmp/logForContention.log    connection=${connection}
    ${value}=  Evaluate    "flow control started" in """${response}"""
    #run keyword unless  ${value}  run keywords
    run keyword if  ${value} == ${False}  run keywords
    ...  Append To File  ${suite_dir}/result.txt  \n\tContention Check FAILED: Flow Control Start Not Found\n  AND
    ...  fail  Contention Check FAILED: Flow Control Start Not Found
    run keyword if  ${value}   Append To File  ${suite_dir}/result.txt  \n\tContention Check SUCCEEDED: Flow Control Start Found\n
    ssh.download file           /tmp/logForContention.log            ${logs_path}/logForContention.log     connection=${connection}


###############################################################################################################################
# Keyword Domain: Mirroring L1L2
###############################################################################################################################
Start Mirroring Traces on Asik New
    [Documentation]    If mirroring scripts are not already present on ASIK, downloads mirroring scripts on ASIK and execute them
    ...                To stay compatible with UTE Cloud, mirro is performed on ASIK ABIL shared directory instead of EIF2
    ...                Mirroring scripts: automaticL2L1Tcpdump_L1R51.sh and loner_mirroring_L1R51.sh
    ...                Starts L1L2 tracesSSB auto mapping
    ...                Author: Fabienne Magueur
    ...                Updated :Abderrahmane NEZROUK
    [Arguments]        ${connection}

    Run keywords      ssh.Upload file    local_path=${CURDIR}/mirroringScripts/5G19B/activate_mirroring_ethloner0.sh
    ...                                  remote_path=/ffs/run/config/scripts/activate_mirroring_ethloner0.sh
    ...                                  connection=${connection}                                            AND
    ...               ssh.Upload file    local_path=${CURDIR}/mirroringScripts/5G19B/deactivate_mirroring_ethloner0.sh
    ...                                  remote_path=/ffs/run/config/scripts/deactivate_mirroring_ethloner0.sh
    ...                                  connection=${connection}                                            AND
    ...               ssh.Execute        chmod 777 /ffs/run/config/scripts/activate_mirroring_ethloner0.sh
    ...                                  connection=${connection}                                            AND
    ...               ssh.Execute        chmod 777 /ffs/run/config/scripts/deactivate_mirroring_ethloner0.sh
    ...                                  connection=${connection}


    Log               ************** Start L1L2 Traces ************
    # launch tcpdump
    #ssh.Send Command    sh /ffs/run/config/scripts/automaticL2L1Tcpdump_L1R51.sh   connection=${connection}
    ssh.Send Command    sh /ffs/run/config/scripts/activate_mirroring_ethloner0.sh   connection=${connection}

Stop and Collect Mirroring Traces on Asik New
    [Documentation]    Stops L1L2 traces on ABIL if not already stopped
    ...                Collect pcap file on VM
    ...                Clean Asik board
    ...                Author: Fabienne Magueur
    ...                Updated :Abderrahmane NEZROUK
    [Arguments]                 ${connection}

    # stop tcpdump
    Log               ************** Stop L1L2 Traces ************
    ssh.Execute        chmod 777 /ffs/run/config/scripts/deactivate_mirroring_ethloner0.sh
    ...                                  connection=${connection}

    # Collect file
    ${path_tmp}  joinpath       ${res_path}     logs/tcpdump
    create directory            ${path_tmp}
    set suite variable          ${path_tcpdump}     ${path_tmp}
    directory should exist      ${path_tmp}         ${path_tmp} directory should be created
    ${file_tmp}    joinpath     ${path_tmp}    tcpdumpL2L1.pcap

    ssh.download file           remote_path=/ffs/run/config/scripts/tcpdumpL2L1.pcap
    ...                         local_path=${file_tmp}
    ...                         connection=${connection}

    # Delete mirroring scripts on ASIK
    ssh.Execute    rm /ffs/run/config/scripts/automaticL2L1Tcpdump_L1R51.sh    connection=${connection}
    ssh.Execute    rm /ffs/run/config/scripts/activate_mirroring_ethloner0.sh    connection=${connection}
    ssh.Execute    rm /ffs/run/config/scripts/deactivate_mirroring_ethloner0.sh    connection=${connection}
    ssh.Execute    rm /ffs/run/config/scripts/tcpdumpL2L1.pcap    connection=${connection}
    # Delete trace file on ASIK
    ssh.Execute    rm /ffs/run/config/scripts/tcpdumpL2L1.pcap    connection=${connection}

    set test variable    ${L1L2_trace_pcap}    ${file_tmp}
    [Return]    ${file_tmp}


Start Mirroring Traces on Asik
    [Documentation]    Prepare and launch tcpdump. This keyword shall be used if mirroring configuration used
    ...                is: Number of packets limited to 100000, capture during 20s, 1 file of 20 Mb
    [Arguments]   ${connection}   ${capturing_time}=infinite    ${number_of_files}=1
    ...   ${file_size_mbytes}=120    ${filtering}=off    ${filter}=${EMPTY}

    ${remote_path1}    Prepare Mirroring script on Asik    ${connection}

    Update gnbMirroringConfig    connection=${connection}    capturing_time=${capturing_time}   number_of_files=${number_of_files}
    ...                 file_size_mbytes=${file_size_mbytes}     filtering=${filtering}    filter=${filter}

    Log               ************** Start gnbMirroring.sh ************

    # launch tcpdump
    ssh.Send Command    command=sh ${remote_path1}      get_pty=True      connection=${connection}
    # ensure that tcpdump started before to continue
    Sleep    5s
    # wait until keyword succeeds    10 sec     0 sec     Check tcpdump Process is Running     ${connection}

Prepare Mirroring script on Asik
    [Documentation]    Downloads mirroring scripts on ASIK
    ...                To stay compatible with UTE Cloud, mirroring is performed on ASIK ABIL shared directory instead of EIF2
    ...                Mirroring scripts 5G19B: gnbMirroring.sh and gnbMirroringConfig.sh
    ...                Author: Fabienne Magueur
    ...                Update: Abderrahmane NEZROUK on 02/09/2020 usage of script V39
    [Arguments]        ${connection}

    wait until keyword succeeds    5 min     30 sec     ssh.force reconnect     asikFhCnx

    # Check SW release
    set test variable    ${sw_release}    ${5GRelease}

    ${remote_dir}    Set variable    /ffs/run/config/scripts

    ${remote_dir_exists}    ssh.File exists    remote_path=${remote_dir}    connection=${connection}
    ${cmd}           Set variable    mkdir ${remote_dir}
    Run keyword if    '${remote_dir_exists}' == 'False'
    ...        ssh.Execute    ${cmd}    connection=${connection}

    ${local_path1}          Set variable    ${CURDIR}/mirroringScripts/gnbMirroring.sh
    ${local_path2}          Set variable    ${CURDIR}/mirroringScripts/gnbMirroringConfig.sh

    ${remote_path1}=    catenate    SEPARATOR=    /ffs/run/config/scripts/gnbMirroring.sh
    ${remote_path2}=    catenate    SEPARATOR=    /ffs/run/config/scripts/gnbMirroringConfig.sh

    ssh.Upload file    local_path=${local_path1}    remote_path=${remote_path1}    connection=${connection}
    ssh.Upload file    local_path=${local_path2}    remote_path=${remote_path2}    connection=${connection}
    ssh.Execute        chmod 777 ${remote_path1}    connection=${connection}
    ssh.Execute        chmod 777 ${remote_path2}   connection=${connection}

    # by default the number of pcap files expected is one
    set test variable     ${num_tcp_file_expected}    1

    # return path of the mirroring script on ASIK
    [return]    ${remote_path1}

Update gnbMirroringConfig
    [Documentation]  This keyword update gnbMirroringConfig.sh according to parameters provided in argument
    [Arguments]     ${connection}=asikFhCnx    ${capturing_time}=infinite    ${number_of_files}=1    ${file_size_mbytes}=50
    ...             ${filtering}=off    ${filter}=${EMPTY}    ${mirroring_mode}=local    ${l2_l1_bip}=true    ${syscom_mirroring}=false
    ...             ${BB_BOARD_TYPE}=ABIL

    ${mirroring_script}    set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh
    ${mirroring_script_sav}    set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh.sav

    ssh.execute     cp ${mirroring_script} ${mirroring_script_sav}    connection=${connection}

    ssh.execute     sed -i -e 's/CAPTURING_TIME_SECONDS\=[0-9]*/CAPTURING_TIME_SECONDS\=${capturing_time}/g' ${mirroring_script}
    ...             connection=${connection}

    ssh.execute     sed -i -e 's/NUMBER_OF_FILES\=[0-9]*/NUMBER_OF_FILES\=${number_of_files}/g' ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e 's/FILE_SIZE_MBYTES\=[0-9]*/FILE_SIZE_MBYTES\=${file_size_mbytes}/g' ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/FILTERING\='.*'/FILTERING\='${filtering}'/g" ${mirroring_script}    connection=${connection}

    #for V30
    ssh.execute     sed -i -e "s/MIRRORING_MODE\='.*'/MIRRORING_MODE\='${mirroring_mode}'/g" ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/FILTER\='.*'/FILTER\='${filter}'/g" ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/L2_L1_BIP\='.*'/L2_L1_BIP\='${l2_l1_bip}'/g" ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/SYSCOM_MIRRORING\='.*'/SYSCOM_MIRRORING\='${syscom_mirroring}'/g" ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/BB_BOARD_TYPE\='.*'/BB_BOARD_TYPE\='${BB_BOARD_TYPE}'/g" ${mirroring_script}    connection=${connection}

    set test variable     ${num_tcp_file_expected}    ${number_of_files}

Update gnbMirroring script
    [Documentation]  This keyword update gnbMirroring.sh to limit the number of packets captured to the
    ...              value given in argument

    [Arguments]     ${connection}=asikFhCnx    ${nb_packet_to_capture}=100000

    ${mirroring_script}    set variable    /ffs/run/config/scripts/gnbMirroring.sh
    ${mirroring_script_sav}    set variable    /ffs/run/config/scripts/gnbMirroring.sh.sav

    ssh.execute     cp ${mirroring_script} ${mirroring_script_sav}    connection=${connection}

    ${mirroring_script}    set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh
    ${mirroring_script_sav}    set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh.sav

    ssh.execute     cp ${mirroring_script} ${mirroring_script_sav}    connection=${connection}

    # for V26
    # ssh.execute     sed -i -e "s/filtered_messages_when_filtering_on\='.*'/filtered_messages_when_filtering_on\='${filter}'/g" ${mirroring_script}
    # ...            connection=${connection}

    ssh.execute     sed -i -e 's/tcpdump -i ethbp1.*\\(-c \\)*[0-9]* -C/tcpdump -i ethbp1 -c ${nb_packet_to_capture} -C/g' ${mirroring_script}
    ...             connection=${connection}

Restore gnbMirroring script
    [Documentation]  This keyword restore original gnbMirroring.sh in case it has been updated by Update gnbMirroring script
    [Arguments]     ${connection}=asikFhCnx

    ${mirroring_script}    set variable    /ffs/run/config/scripts/gnbMirroring.sh
    ${mirroring_script_sav}    set variable    /ffs/run/config/scripts/gnbMirroring.sh.sav

    ssh.execute     mv ${mirroring_script_sav} ${mirroring_script}    connection=${connection}


Restore gnbMirroringConfig
    [Documentation]  This keyword restore original gnbMirroring.sh in case it has been updated by Update gnbMirroring script
    [Arguments]     ${connection}=asikFhCnx

    ${mirroring_script}    set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh
    ${mirroring_script_sav}    set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh.sav

    ssh.execute     mv ${mirroring_script_sav} ${mirroring_script}    connection=${connection}

Start Customized Mirroring Traces on Asik
    [Documentation]    Launch mirroring command. Mirroring scripts must have been downloaded and configured before this keyword is used.
    [Arguments]   ${connection}    ${remote_path1}

    Log               ************** Start gnbMirroring.sh ************

    # launch tcpdump
    ssh.Send Command    echo $(sh ${remote_path1}) \\\\n   connection=${connection}

Start Mirroring manual or remote on Asik
    [Documentation]    Launch mirroring command. This keyword is used only when MIRRORING_MODE is manual or remote.
    [Arguments]   ${connection}    ${remote_path1}

    Log               ************** Start gnbMirroring.sh ************
    ssh.Send Command    sh ${remote_path1}    timeout=10    connection=${connection}
    Read output    connection=${connection}

Stop and Collect Mirroring Traces on Asik
    [Documentation]    Stops L1L2 traces on ABIL if not already stopped
    ...                Collect pcap file on VM
    ...                in 19A tcpdump file is located on ASIK in /ffs/run/config/scripts
    ...                From 19B, tcpdump file is located on ASIK in /tmp
    ...                Clean Asik board
    ...                Author: Fabienne Magueur
    ...                Updated: Abderrahmane NEZROUK usgae of script V39

    [Arguments]        ${connection}   ${filtering}=off    ${clean_scripts}=on

    run keyword if    '5G19B' == '${5GRelease}'     Stop Mirroring Traces on Asik    connection=abilXeonBCnx
    ...                ELSE                        Stop Mirroring Traces            connection=${connection}

    BuiltIn.sleep         5s
    # ${connection}
    ${L1L2_trace_pcap}    Collect and clean mirroring traces on ASIK    connection=${connection}    filtering=${filtering}
    Run Keyword If    '${clean_scripts}'=='on'
    ...    Clean mirroring script on ASIK    connection=${connection}
    set test variable    ${L1L2_trace_pcap}    ${L1L2_trace_pcap}
    [Return]    ${L1L2_trace_pcap}

Stop and Collect Mirroring Traces
    [Documentation]    Stops traces on ABIL/ABIO if not already stopped
    ...                Collect pcap file on VM
    ...                Clean Asik/ASIB board
    ...                Author: Abderrahmane NEZROUK

    [Arguments]        ${connection}   ${board_socid}=0    ${filtering}=off

    Stop Mirroring Traces    ${connection}    ${board_socid}

    BuiltIn.sleep         5s
    # ${connection}
    ${L1L2_trace_pcap}    Collect and clean mirroring traces on ASIK    connection=${connection}    filtering=${filtering}
    Clean mirroring script on ASIK    connection=${connection}
    set test variable    ${L1L2_trace_pcap}    ${L1L2_trace_pcap}
    [Return]    ${L1L2_trace_pcap}

Stop Mirroring Traces on Asik
    [Documentation]    Stops L1L2 traces on ABIL if not already stopped
    ...                Author: Fabienne Magueur
    [Arguments]        ${connection}
    # Force reconnect
    wait until keyword succeeds    5 min     30 sec     ssh.force reconnect     asikFhCnx
    Run keyword if    "asikFhCnx" != "${connection}"
    ...      wait until keyword succeeds    5 min     30 sec     ssh.force reconnect     ${connection}
    # Stop tcpdump on ABIL and ASIK if still running
    # nb: process should be already stopped in 19A as the capture is limited to 100000 captured packets
    # nb2: From 19B: process should be already stopped in 19B as tcpdump is killed after execution by mirroring script
    Log               ************** Stop L1L2 Traces ************
    ${cmd}         set variable   kill -9 `ps -ef | grep -E '^[tcpdump|root]' | grep ethbp1 | awk '{print $2}'`
    ssh.execute                 command=${cmd}    connection=${connection}

Stop Mirroring Traces
    [Documentation]    Stops L1L2 traces if not already stopped
    ...                Author: Abderrahmane NEZROUK
    [Arguments]        ${connection}    ${board_socid}=0
    # Force reconnect
    # wait until keyword succeeds    5 min     30 sec     ssh.force reconnect     asikFhCnx
    # Stop tcpdump on ABIL/ABIO and ASIK/ASIB if still running
    # nb: Keyword compatible with ASIB/ASIK conf
    Log               ************** Stop Traces ************
    ${cmd}         set variable if   '${board_socid}'!='0'
    ...     bsh ${board_socid} pkill -2 tcpdump
    ...     pkill -2 tcpdump
    ${run}=        ssh.execute                 command=${cmd}    connection=${connection}


Collect and clean mirroring traces on ASIK
    [Documentation]    Collect pcap file on VM
    ...                Author: Fabienne Magueur
    [Arguments]        ${connection}   ${filtering}=off

    # Collect file on ASIK
    ${path_tmp}  joinpath       ${res_path}     logs/tcpdump
    create directory            ${path_tmp}
    set suite variable          ${path_tcpdump}     ${path_tmp}
    directory should exist      ${path_tmp}         ${path_tmp} directory should be created

    # Depending on mirroring configuration several files may be generated
    @{download_list_remote}    Create list
    @{download_list_local}    Create list
    ${file_tmp}  joinpath       ${path_tmp}     tcpdumpL2L1.pcap

    ${num_of_files}    evaluate    ${num_tcp_file_expected}
    ${max_index}       evaluate    ${num_of_files} -1
    : FOR    ${index}     IN RANGE    ${num_of_files}
    \        ${index_string}    Convert to string    ${index}
    \        ${valuelocal}    catenate    SEPARATOR=    ${path_tmp}    /tcpdumpL2L1_filtering_${filtering}.pcap    ${index_string}
    \        ${valueremote}    catenate    SEPARATOR=    /tmp/tcpdumpL2L1_filtering_${filtering}.pcap    ${index_string}
    \        ${index_num}      Convert to integer    ${index}
    \        insert into list    ${download_list_local}     ${index_num}    ${valuelocal}
    \        insert into list    ${download_list_remote}    ${index_num}    ${valueremote}


    # - In local mode, capture is stored to /tmp/tcpdumpL2L1[_gulp]_filtering_[off|on].pcap000
    ${remote_path}    set variable      /tmp/tcpdumpL2L1_filtering_${filtering}.pcap

    Run keyword if     ${num_of_files} == 1    Run keywords
    ...                ssh.download file    remote_path=${remote_path}
    ...                         local_path=${file_tmp}
    ...                         connection=${connection}                       AND
    ...                ssh.execute    rm ${remote_path}    connection=${connection}

    : FOR    ${index}     IN RANGE    ${num_of_files}
    \        Run keyword if     ${num_of_files} == 1    Continue for loop
    \        ${index_num}      Convert to integer    ${index}
    \        Run keyword and ignore error    ssh.download file    remote_path=${download_list_remote[${index_num}]}
    ...                         local_path=${download_list_local[${index_num}]}    connection=${connection}
    \        Run keyword and ignore error    ssh.Execute    rm ${download_list_remote[${index_num}]}    connection=${connection}

    set test variable    ${L1L2_trace_pcap}    ${file_tmp}

    Return from keyword if    ${num_of_files} == 1    ${file_tmp}
    Return from keyword if    ${num_of_files} > 1     ${download_list_local}

Clean mirroring script on ASIK
    [Documentation]    Delete mirroring scripts on ASIK
    ...                Author: Fabienne Magueur
    ...                Update: Abderrahmane NEZROUK on 02/09/2020
    [Arguments]        ${connection}

    # Delete mirroring scripts on ASIK

    ${remote_path1}    Set variable    /ffs/run/config/scripts/gnbMirroring.sh
    ${remote_path2}    Set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh


    ssh.Execute    rm ${remote_path1}    connection=${connection}
    ssh.Execute    rm ${remote_path2}    connection=${connection}

Prepare Mirroring script on Asod
    [Documentation]    Downloads mirroring script on ASOD
    ...                Mirroring scripts 5G20B: mirror.sh
    ...                Author: Fabienne Magueur
    ...                Update: Abderrahmane NEZROUK on 02/09/2020
    [Arguments]        ${connection}

    # Check SW release
    set test variable    ${sw_release}    ${5GRelease}

    ${remote_dir}    Set variable    /ffs/run/config/scripts

    ${remote_dir_exists}    ssh.File exists    remote_path=${remote_dir}    connection=${connection}
    ${cmd}           Set variable    mkdir ${remote_dir}
    Run keyword if    '${remote_dir_exists}' == 'False'
    ...        ssh.Execute    ${cmd}    connection=${connection}

    ${local_path}          Set variable    ${CURDIR}/mirroringScripts/${sw_release}/mirror.sh
    ${remote_path}=    catenate    SEPARATOR=    /ffs/run/config/scripts/mirror.sh

    ssh.Upload file    local_path=${local_path}    remote_path=${remote_path}    connection=${connection}
    ssh.Execute        chmod 777 ${remote_path}    connection=${connection}

    # by default the number of pcap files expected is one
    set test variable     ${num_tcp_file_expected}    1

    # return path of the mirroring script on ASIK
    [return]    ${remote_path}

Start Mirroring on Asod
    [Documentation]    Launch mirroring command. Mirroring script must have been downloaded before this keyword is used.
    ...                Unlike ASIK case, this doesn't start tcpdump, it has to be launched after with
    ...                keyword Start capture L1L2 on ASOD
    [Arguments]   ${connection}    ${remote_path1}

    Log               ************** Start gnbMirroring.sh ************

    ${cmd}    catenate   bash    ${remote_path1}    6 11
    ssh.Send Command    ${cmd}    timeout=10    connection=${connection}
    Read output    connection=${connection}

Start Mirroring Traces on ASOD
    [Documentation]    This keyword starts tcpdump for L1L2 traces on ASOD
    [Arguments]        ${procedure}   ${filter}

    ${interface}          Set variable    pepbp1
    ${connnection_tcp}    Set variable    asikFhCnx

    ${traceNameL1L2}=    run keyword     logs.Tcpdump Start
    ...     ${interface}
    ...     ${connnection_tcp}
    ...     ${procedure}_L1L2_${GNB_Friendly_TL_Name}
    ...     filter=${filter}
    set test variable   ${traceNameL1L2}    ${traceNameL1L2}

Stop and Collect Mirroring Traces on ASOD
    [Documentation]    This keyword stops tcpdump for L1L2 traces on ASOD

    ${interface}          Set variable    pepbp1
    ${connnection_tcp}    Set variable    asikFhCnx

    logs.Tcpdump Stop And Collect
    ...     ${interface}
    ...     ${connnection_tcp}
    ...     ${traceNameL1L2}
    ...     logs/tcpdump/

Merge pcap files
    [Documentation]  This keyword merge the given pcap file list and return the absolute path of the merged file.
    ...    Packets from the input files are merged in chronological order based on each frame’s timestamp
    ...    Author: Abderrahmane NEZROUK
    [Arguments]     ${pcap_files_list}      ${output_pcpa_file}

    @{pcap_files_lst}    Set variable    ${pcap_files_list}
    ${cmd}    catenate    SEPARATOR=    mergecap    ${SPACE}    -w    ${SPACE}    ${output_pcpa_file}
    : FOR    ${pcap_file}     IN    @{pcap_files_lst}
    \       ${cmd}    catenate    SEPARATOR=    ${cmd}    ${SPACE}      ${pcap_file}
    ${res}    Run    ${cmd}
    [Return]    ${output_pcpa_file}


Start F1AP Traces
    [Documentation]    This keyword starts F1AP traces
    ...                Compatibility: cloud cOAM
    [arguments]       ${procedure}    ${itf}=fronthaul    ${connection}=abilXeonACnx
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'COAM'
    ...                 logs.Start F1AP Traces Cloud cOAM    ${procedure}    ${itf}
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 Start F1AP Traces Classical    ${procedure}    ${itf}    ${connection}

Start F1AP Traces Cloud cOAM
    [Documentation]    This keyword connects to CPIF VM and launches tcpdump on interface ${itf}
    ...                Compatibility: cloud cOAM
    [arguments]       ${procedure}    ${itf}=fronthaul

    ${traceNameF1ap}=    run keyword     logs.Tcpdump Start
    ...     interface=${itf}
    ...     session=CPIF
    ...     outputName=${procedure}_F1AP
    ...     cmdPrefix=sudo
    set test variable   ${traceNameF1ap}    ${traceNameF1ap}


Start F1AP Traces Classical
    [Documentation]    This keyword connects to ${connection} and launches tcpdump on interface ${itf}
    ...                Compatibility: classical cOAM
    [arguments]       ${procedure}    ${itf}=etha01    ${connection}=abilXeonACnx
    ${traceNameF1ap}=      run keyword     logs.Tcpdump Start
    ...     ${itf}
    ...     ${connection}
    ...     ${procedure}_f1ap
    set test variable   ${traceNameF1ap}     ${traceNameF1ap}


Stop and collect F1AP traces
    [Documentation]    This keyword stops and collect F1AP pcap file
    [arguments]       ${procedure}    ${itf}=etha01    ${connection}=abilXeonACnx

    #bypass robocop
    ${procedure}    set variable    ${procedure}

    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'COAM'
    ...                 logs.Stop and collect F1AP traces Cloud cOAM   ${itf}    ${connection}
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 logs.Stop and collect F1AP traces classical    ${itf}    ${connection}

Stop and collect F1AP traces cloud cOAM
    [Documentation]    This command connects to CPIF VM, stops tcpdump and collect pcap file
    [arguments]       ${itf}=fronthaul    ${connection}=CPIF
    log     ******* STOP F1AP TRACES ON ${connection} - CLOUD *******
    logs.Tcpdump Stop And Collect
    ...     ${itf}
    ...     ${connection}
    ...     ${traceNameF1ap}
    ...     logs/tcpdump/
    ...     cmdPrefix=sudo

Stop and collect F1AP traces classical
    [Documentation]    This command connects to  ${connection} and stops tcpdump on interface ${itf}
    [arguments]       ${itf}=etha01    ${connection}=abilXeonACnx
    log     ******* STOP F1AP TRACES ON ${connection} - CLASSICAL *******
    logs.Tcpdump Stop And Collect
    ...     ${itf}
    ...     ${connection}
    ...     ${traceNameF1ap}
    ...     logs/tcpdump/

Start F1AP XeonB Traces Classical
    [Documentation]    This keyword connects to ${connection} and launches tcpdump on interface ${itf}
    ...                Compatibility: classical cOAM
    [arguments]       ${procedure}    ${itf}=etha01    ${connection}=abilXeonBCnx
    ${traceNameF1apb}=      run keyword     logs.Tcpdump Start
    ...     ${itf}
    ...     ${connection}
    ...     ${procedure}_f1ap
    set test variable   ${traceNameF1apb}     ${traceNameF1apb}

Stop and collect F1AP XeonB traces classical
    [Documentation]    This command connects to  ${connection} and stops tcpdump on interface ${itf}
    [arguments]       ${itf}=etha01    ${connection}=abilXeonBCnx
    log     ******* STOP F1AP TRACES ON ${connection} - CLASSICAL *******
    logs.Tcpdump Stop And Collect
    ...     ${itf}
    ...     ${connection}
    ...     ${traceNameF1apb}
    ...     logs/tcpdump/

Configure tti traces
    [Documentation]    This keywords configures tti traces according to gnb architecture
     [arguments]       ${num_of_files}=300
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'COAM' and '${system_module_type}' == 'ASIK'
    ...                 logs.Configure tti traces ASIK    num_of_files=${num_of_files}
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'COAM' and '${system_module_type}' == 'ASOD'
    ...                 logs.Configure tti traces ASOD    num_of_files=${num_of_files}
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 logs.Configure tti traces ASIK    num_of_files=${num_of_files}

Configure tti traces ASIK
    [Documentation]    This keywords:
    ...                - downloads tti traces script on ${connection}
    ...                - configures /opt/tools/ttiTrace/eventsCollect.sh with ${num_of_files}
    [arguments]       ${connection}=asikFhCnx    ${connection_tti_tools}=abilXeonBCnx    ${num_of_files}=300

    ${tti_traces_script}    Set variable    ${CURDIR}/ttitraces/gnb_tti_traces_v3e_modif.sh
    ${remote_path}          Set variable    /ffs/run/logs/gnb_tti_traces_v3e.sh

    ssh.upload File    ${tti_traces_script}   ${remote_path}   ${connection}

    ${cmd}    Set variable    chmod 777 ${remote_path}
    ssh.execute    ${cmd}    ${connection}

    ${event_collect}    Set variable    /opt/tools/ttiTrace/eventsCollect.sh
    ${cmd}              Set variable    sed -i -e 's/DELETE_AFTER=120/DELETE_AFTER=${num_of_files}/g' ${event_collect}
    ssh.execute    ${cmd}    ${connection_tti_tools}

Configure tti traces ASOD
    [Documentation]    This keywords:
    ...                - downloads tti traces script on ${connection}
    ...                - configures /opt/tools/ttiTrace/eventsCollect.sh with ${num_of_files}
    [arguments]       ${connection}=asikFhCnx    ${connection_tti_tools}=asodSlaveCnx    ${num_of_files}=300

    #bypass robocop
    ${num_of_files}    set variable    ${num_of_files}

    ${tti_traces_script}    Set variable    ${CURDIR}/ttitraces/gnb_tti_traces_v3e.sh
    ${remote_path}          Set variable    /ffs/run/logs/gnb_tti_traces_v3e.sh

    ssh.upload File    ${tti_traces_script}   ${remote_path}   ${connection}

    ${cmd}    Set variable    chmod 777 ${remote_path}
    ssh.execute    ${cmd}    ${connection}

    ${event_collect}    Set variable    /opt/tools/ttiTrace/eventsCollect.sh
    ${cmd}              Set variable    sed -i -e 's/DELETE_AFTER=120/DELETE_AFTER=300/g' ${event_collect}
    ssh.execute    ${cmd}    ${connection_tti_tools}

Start tti traces
    [Documentation]    This keywords start tti traces on gNB with a delay of ${delay_tti} seconds
    [arguments]       ${connection}=asikFhCnx    ${delay}=10

    #bypass robocop
    ${delay}    set variable    ${delay}

    ${cmd}    Set variable    /ffs/run/logs/gnb_tti_traces_v3e.sh start
    ssh.execute   command=${cmd}    connection=${connection}

Stop and collect tti traces
    [Documentation]    This keywords stops and collect tti traces according to gnb architecture
    [arguments]        ${procedure}    ${connection}=asikFhCnx

    #bypass robocop
    ${procedure}    set variable    ${procedure}

    ${cmd}                  Set variable    /ffs/run/logs/gnb_tti_traces_v3e.sh stop
    ssh.execute   ${cmd}    ${connection}

    ${cmd}                  Set variable    /ffs/run/logs/gnb_tti_traces_v3e.sh collect
    ssh.execute   ${cmd}    ${connection}

    ${remote_path}          Set variable if
    ...       '${system_module_type}' == 'ASIK'    /tmp/tti_traces_asp-1b.tar
    ...       '${system_module_type}' == 'ASOD'    /tmp/tti_traces_asc-0b.tar

    ${path_tmp}  joinpath       ${res_path}     logs/tcpdump
    create directory            ${path_tmp}
    set suite variable          ${path_tcpdump}     ${path_tmp}
    ${local_path}     Set variable if
    ...           '${system_module_type}' == 'ASIK'    ${path_tcpdump}/tti_traces_asp-1b.tar
    ...           '${system_module_type}' == 'ASOD'    ${path_tcpdump}/tti_traces_asc-0b.tar

    ssh.download file   remote_path=${remote_path}    local_path=${local_path}    connection=${connection}
    set test variable    ${tti_trace_file}    ${local_path}

    ${cmd}                  Set variable    rm /tmp/tti_traces_asp-1b.tar
    Run keyword and ignore error    ssh.execute   ${cmd}    ${connection}
