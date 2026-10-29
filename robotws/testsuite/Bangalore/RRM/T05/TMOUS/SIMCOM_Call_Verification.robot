*** Settings ***
Documentation
...              	SIMCOM call verification

#Library    taf.ue
Library		ute_ue
Library		String
Library		DateTime
Library		Collections
Library		OperatingSystem
Library		taf.transport.ssh		WITH NAME	ssh
Library		taf.hw.rf_attenuator	WITH NAME  at

Test setup		Set attenuation values
Test Teardown	Revert attenuation values

*** Variables ***
@{at_channel}				${1}	${2}	${3}	${4}	${5}	${6}	${7}
...							${8}	${9}	${10}	${11}	${12}	${13}	${14}
...							${15}	${16}
${attenuator_host}          10.45.153.207
${attenuator_port}          ${3001}
${at_vendor}	 			TOPYOUNG
${at_model}	 				TAS_16T16_0_2G6_90_1S_DEJS
${UE_alias}					UE_1
${Data_protocol}			tcp
${deviation}				30%
${UE_PC_IP}					10.45.150.235
${Windows_user}				inbabtslabuser
${Windows_pass}				BT5l@bus3rl0g1n
${Proxy_path}				C://Users//inbabtslabuser//Documents
${Cell_attach_percentage}	50
${Verify_data_transfer}		False
${Verify_ping}				True
${RAT_to_test}				LTE			#supported LTE,NR,NSA
@{LTE_Pass}								# Leave empty
@{nr5g_Pass}                            # Leave empty
@{NRNSA_Pass}                           # Leave empty
@{LTE_tested}                           # Leave empty
@{nr5g_tested}                          # Leave empty
@{NRNSA_tested}                         # Leave empty

*** Test Cases ***
Call Verification on SIMCOM
    Verify call on SIMCOM

*** Keywords ***
Verify call on SIMCOM
	Start simcom Proxy
    Require Ue			ue_alias=${UE_alias}    capabilities=REAL_SIMCOM_UE
	${RAT}		Split string	${RAT_to_test}		,
    FOR	${i}	IN	@{RAT}
		Run keyword		Verify ${i} cells
	END
	Log and Verify results

Verify all cells
	Verify LTE cells
	Verify NR cells
	Verify NSA cells

Verify LTE cells
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=5035		scs=15    band=12		pci=330
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=68661	scs=15    band=71		pci=351
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=5035		scs=15    band=12		pci=56
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=68661	scs=15    band=71		pci=185
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=5035		scs=15    band=12		pci=118
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=68661	scs=15    band=71		pci=316
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=2300		scs=15    band=4		pci=444
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=975		scs=15    band=2		pci=318
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=2300		scs=15    band=4		pci=44
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=975		scs=15    band=2		pci=47
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=2300		scs=15    band=4		pci=463
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=975		scs=15    band=2		pci=103
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=40072	scs=30    band=41		pci=423
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=39874	scs=30    band=41		pci=423
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=40072	scs=30    band=41		pci=122
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=39874	scs=30    band=41		pci=122
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=40072	scs=30    band=41		pci=97
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=LTE		earfcn=39874	scs=30    band=41		pci=97

Verify NR cells
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=126270	scs=15    band=71		pci=636
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=126270	scs=15    band=71		pci=770
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=126270	scs=15    band=71		pci=829
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=396970	scs=15    band=25		pci=273
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=396970	scs=15    band=25		pci=146
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=396970	scs=15    band=25		pci=571
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=512190	scs=30    band=41		pci=534
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=514056	scs=30    band=41		pci=534
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=512190	scs=30    band=41		pci=485
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=514056	scs=30    band=41		pci=485
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=512190	scs=30    band=41		pci=628
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=nr5g	earfcn=514056	scs=30    band=41		pci=628

Verify NSA cells
	Run Keyword And ignore error		Verify cell		${UE_alias}    network_mode=NRNSA	earfcn=126270	scs=15    band=71		pci=636

Set attenuation values
    Setup Attenuator
	${set attenuation}	Create List		1,0	2,0	3,0	4,0	5,0	6,0	7,0	8,0	9,0	10,0
	...									11,0	12,0	13,0	14,0	15,0	16,0
	Change attenuation	${set attenuation}

Revert attenuation values
	${set attenuation}	Create List		1,90	2,90	3,0	4,90	5,90	6,90	7,90	8,90	9,90	10,90
	...									11,90	12,90	13,90	14,90	15,90	16,90
	Change attenuation	${set attenuation}

Setup Attenuator
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}

Change attenuation
    [Arguments]     ${port_val_list}
    [Documentation]     Set the attenuation of specified port
	Print statement in console      Changing attenuator values : ${port_val_list}
    FOR    ${val}    IN    @{port_val_list}
        ${channel_num}      ${value}    Split String    ${val}  ,   1
        Set Attenuator value    ${channel_num}      ${value}
    END

Set Attenuator value
    [Arguments]     ${channel_num}      ${value}
    [Documentation]     Set the attenuation of specified port
    ${channel_num}      Convert To Integer      ${channel_num}
    ${value}			Convert To Integer      ${value}
    ${set_value}  		at.read_attenuation  port=${${channel_num}}
    at.set_attenuation  port=${channel_num}     value=${value}      confirm=${True}
    #sleep   2s      	reason=Wait for change in state
    ${set_value}  		at.read_attenuation  port=${${channel_num}}
    Should Be Equal As Strings  ${set_value}  ${value}

Print statement in console
	[Arguments]		${Statement}
	${date}			Get Current Date	result_format=%H:%M:%S
	${date}			Convert to String	${date}
	Log         	\n[${date}] ${Statement}    console=True

Verify cell
	[Arguments]			${UE}	${network_mode}		${earfcn}		${scs}    ${band}		${pci}
	Print statement in console	Verifying the cell: network_mode=${network_mode}, earfcn=${earfcn}, scs=${scs}, band=${band}, pci=${pci}
	Append To List		${${network_mode}_tested}	${pci}
	Detach Ue			ue_alias=${UE_alias}
	${result}			set_earfcn_lock	${UE}	network_mode=${network_mode}
	...					earfcn=${earfcn}	scs=${scs}	band=${band}	pci=${pci}
	Run keyword if		'${result}'=='False'	Run keywords	Log		EARFCN lock failed		ERROR
	...		AND			FAIL
	...		ELSE		Print statement in console		EARFCN lock successfull
    ${result}			Run keyword and return status	Attach Ue	ue_alias=${UE_alias}
	Run keyword if		'${result}'=='False'			Detach Ue	ue_alias=${UE_alias}
	${result}			Run keyword and return status	Attach Ue	ue_alias=${UE_alias}
	Run keyword if		'${result}'=='False'	Run keywords	Log		Cell attach failed		ERROR
	...		AND			FAIL
	...		ELSE		Print statement in console		Cell attach successfull
	Log Ue Info			${UE_alias}		ALL
	${IP}				get_ue_info		${UE_alias}		IP
	${Cell_id}			get_ue_info		${UE_alias}		cell_id
	Run keyword if		'${Verify_ping}'=='True'	Verify SIMCOM Ping		${IP}		${network_mode}		${pci}		${Cell_id}
	Run keyword if		'${Verify_data_transfer}'=='True'	Start simcom data transfer		${UE}

Verify SIMCOM Ping
	[Arguments]			${IP}	${network_mode}		${pci}		${Cell_id}
	${output}			Run		ping -c 4 ${IP}
	${out}				Run keyword and return status		Should contain	${output}	4 received
	Run keyword if		'${out}'=='True'	Run keywords	Append To List	${${network_mode}_Pass}	${pci},${Cell_id}
	...												AND		Print statement in console		Ping test successfull
	...			ELSE	LOG		Ping test failed	WARN

Start simcom data transfer
	[Arguments]				${UE}
    Start Data Transfer     DT_1    ${UE}    DL    protocol=${Data_protocol}    packet=1024B    throughput=60Mbits/sec
	Start Data Transfer     DT_2    ${UE}    UL    protocol=${Data_protocol}    packet=1024B    throughput=60Mbits/sec
    Sleep    10
    Stop Data Transfer		DT_1
	Stop Data Transfer		DT_2
    ${Result_DL}			Run keyword and return status	Verify Average Throughput With Deviation    DT_1    19244Kbits/sec    ${deviation}
    ${Result_UL}			Run keyword and return status	Verify Average Throughput With Deviation    DT_2    10151Kbits/sec    ${deviation}
	Run keyword if			'${Result_DL}'=='False'		Log		DL throughput failed		WARN
	Run keyword if			'${Result_UL}'=='False'		Log		UL throughput failed		WARN

Start simcom Proxy
	[Documentation]				Start proxy
	Print statement in console	Starting simcom proxy using Batch file
	Stop simcom Proxy
	sleep						5
	Execute command in UE PC	cd ${Proxy_path} && ./Start_simcom_proxy.bat
	sleep						10
	${output}					Execute command in UE PC		ps -W | awk '/python.exe/,NF=1'
	${Result}					Run keyword and return status	Should Not Be Empty		${output}
	Run keyword if 				'${Result}'=='False'			Run keywords	Print statement in console	Unable to start Proxy in UE PC, Please check manually !!!
	...																	AND		Fail

Stop simcom Proxy
	Execute command in UE PC	ps -W | awk '/python.exe/,NF=1' | xargs kill -f

Execute command in UE PC
	[Documentation]		Execute command in UE PC
	[Arguments]			${command}
	Print statement in console		Executing command "${command}" in machine "${UE_PC_IP}"
	Wait Until Keyword Succeeds	   3 times	   5
	...		ssh.Connect_to		${UE_PC_IP}		${Windows_user}		${Windows_pass}    alias=UE_PC_CMD		timeout=60
    ${output}			ssh.Execute		${command}			connection=UE_PC_CMD
    Log					${output}
	[Teardown]			ssh.Disconnect		connection=UE_PC_CMD
	[Return]			${output}

Log and Verify results
	${LTE_cells}		Get Length	${LTE_Pass}
	${NR_cells}			Get Length	${nr5g_Pass}
	${NSA_cells}		Get Length	${NRNSA_Pass}
	${Total_LTE_cells}	Get Length	${LTE_tested}
	${Total_NR_cells}	Get Length	${nr5g_tested}
	${Total_NSA_cells}	Get Length	${NRNSA_tested}
	Log					LTE Tested cells: ${Total_LTE_cells}
	Log					NR Tested cells: ${Total_NR_cells}
	Log					NSA Tested cells: ${Total_NSA_cells}
	Print statement in console	LTE attached cells: ${LTE_cells} \n${LTE_Pass}
	Print statement in console	NR attached cells: ${NR_cells} \n${nr5g_Pass}
	Print statement in console	NSA attached cells: ${NSA_cells} \n${NRNSA_Pass}
	${LTE_pass_count}	Evaluate	(${Total_LTE_cells}*${Cell_attach_percentage})/100
	${NR_pass_count}	Evaluate	(${Total_NR_cells}*${Cell_attach_percentage})/100
	${NSA_pass_count}	Evaluate	(${Total_NSA_cells}*${Cell_attach_percentage})/100
	Run keyword and continue on failure		Should be true	${LTE_cells}>=${LTE_pass_count}
	Run keyword and continue on failure		Should be true	${NR_cells}>=${NR_pass_count}
	Run keyword and continue on failure		Should be true	${NSA_cells}>=${NSA_pass_count}
