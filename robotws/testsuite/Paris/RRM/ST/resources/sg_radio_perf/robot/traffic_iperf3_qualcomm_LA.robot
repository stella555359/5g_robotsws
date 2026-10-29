
*** Keywords ***


Start DLUL Traffic LA
    [Documentation]  Launch DL traffic with iperf command (UDP). Server info are valued in __init__.py (custom part)
    ...              This keyword take as argument:
    ...                    . ${distantip}
    ...                    . ${tputDL} by default 1000M    DL Tput
	...                    . ${tputUL} by default 200M     UL Tput
    ...                    . ${duration} by default 60000   duration of DLUL traffic
    ...                    . ${ueid} by default 0        number to compute used port, discriminating each mobile of the test on same server.
    ...              Author: Denis
    ...                      Update 2019.08.22  Annie Wong
    [Arguments]         ${distantip}   ${tputDL}=1000M  ${tputUL}=200M   ${duration}=60000     ${ueid}=0

    log to console                Start DLUL Traffic LA

    ${portDL}                     Get Traffic port    DL      ${ueid}
    ${portUL}                     Get Traffic port    UL      ${ueid}
	
    log to console                portDL=${portDL}
    log to console                portUL=${portUL}


	# UE Side
	# -------
    ssh.Connect To              ${IPERF_VM_UL_IPADDRESS}         ${IPERF_VM_UL_LOGIN}       ${IPERF_VM_UL_PASSWD}
    ...                         alias=iPerfUE
	
	# DL : stop on going DL iperf3
    #ssh.execute    command=adb shell -n "ps -ef|grep iperf3|grep -v 'grep'|grep ${portDL}|awk '{print $2}'|xargs kill -9"   connection=iPerfUE
    ssh.Send Command            command=adb shell "pkill iperf3"
    ...                         connection=iPerfUE
    ssh.Send Command            command=adb shell -n "rm /data/iPerfUEdl.log"
    ...                         connection=iPerfUE
	
	# UL : stop on going UL iperf3
    #ssh.execute    command=adb shell -n "ps -ef|grep iperf3|grep -v 'grep'|grep ${portUL}|awk '{print $2}'|xargs kill -9"   connection=iPerfUE
    ssh.Send Command            command=adb shell "pkill iperf3"
    ...                         connection=iPerfUE
    ssh.Send Command            command=adb shell -n "rm /data/iPerfUEul.log"
    ...                         connection=iPerfUE


	# DL : start DL iperf3
	log to console              -------Start DL Traffic UE Side	
	log                         adb shell "/data/iperf3 -4 -s -i 1 -p ${portDL} -V --logfile /data/iPerfUEdl.log" &
    ssh.Send Command            command=adb shell "/data/iperf3 -4 -s -i 1 -p ${portDL} -V --logfile /data/iPerfUEdl.log" &
    ...                         connection=iPerfUE
 	# check if the command has well started
    sleep                       5s
    ${result}                   ssh.Execute     command= adb shell -n "cat /data/iPerfUEdl.log"
    ...                         connection=iPerfUE
    should not contain          ${result}       iperf3: exiting

	
	# UL : start UL iperf3
	log to console              -------Start UL Traffic UE Side	
	log                         adb shell -n "/data/iperf3 -4 -s -i 1 -p ${portUL} -V --logfile /data/iPerfUEul.log" &
    ssh.Send Command            command=adb shell -n "/data/iperf3 -4 -s -i 1 -p ${portUL} -V --logfile /data/iPerfUEul.log" &
    ...                         connection=iPerfUE
 	# check if the command has well started
    sleep                       5s
    ${result}                   ssh.Execute     command= adb shell -n "cat /data/iPerfUEul.log"
    ...                         connection=iPerfUE
    should not contain          ${result}       iperf3: exiting

    ssh.disconnect              connection=iPerfUE


	# TS Side
	# -------
    ssh.Connect To              ${IPERF_VM_DL_IPADDRESS}         ${IPERF_VM_DL_LOGIN}          ${IPERF_VM_DL_PASSWD}
    ...                         alias=iPerfCN
	
	# DL : stop on going DL iperf3
	ssh.execute         		ps -ef|grep iperf3|grep -v "grep"|grep ${portDL}|awk '{print $2}'|xargs kill -9      connection=iPerfCN
	#ssh.Send Command            command=pkill -e iperf
    #...                         connection=iPerfCN
	ssh.Send Command            command=rm iperfDL.log
    ...                         connection=iPerfCN
	
	# UL : stop on going UL iperf3
	ssh.execute         		ps -ef|grep iperf3|grep -v "grep"|grep ${portUL}|awk '{print $2}'|xargs kill -9      connection=iPerfCN
    #ssh.Send Command            command=pkill -e iperf
    #...                         connection=iPerfCN
	ssh.Send Command            command=rm iperfUL.log
    ...                         connection=iPerfCN
	
	
	# DL : start DL iperf3
	log to console              -------Start DL Traffic TS Side		
    log                         iperf3 -c ${distantip} -u -i 1 -b ${tputDL} -t ${duration} -p ${portDL} -l 1300 --logfile iperfDL.log &
    ssh.Send Command            command=iperf3 -c ${distantip} -u -i 1 -b ${tputDL} -t ${duration} -p ${portDL} -l 1300 --logfile iperfDL.log &
    ...                         connection=iPerfCN
	# check if the command has well started
    sleep                       5s
    ${result}                   ssh.Execute     command=cat iperfDL.log
    ...                         connection=iPerfCN
    should contain              ${result}       local ${COREIPTRAFFICSERVER} port
    should contain              ${result}       connected to ${distantip} port ${portDL}
	

	# UL : start UL iperf3
	log to console              -------Start UL Traffic TS Side		
    log                         iperf3 -R -c ${distantip} -u -i 1 -b ${tputUL} -t ${duration} -p ${portUL} -l 1300 --logfile iperfUL.log &
    ssh.Send Command            command=iperf3 -R -c ${distantip} -u -i 1 -b ${tputUL} -t ${duration} -p ${portUL} -l 1300 --logfile iperfUL.log &
    ...                         connection=iPerfCN
 	# check if the command has well started
    sleep                       5s
    ${result}                   ssh.Execute     command=cat iperfUL.log
    ...                         connection=iPerfCN
	#log to console              result=${result}
	#log to console              COREIPTRAFFICSERVER=${COREIPTRAFFICSERVER}
    #should contain              ${result}       local ${COREIPTRAFFICSERVER} port
    #should contain              ${result}       connected to ${distantip} port ${portUL}


    ssh.disconnect              connection=iPerfCN	




Start DL Traffic LA
    [Documentation]  Launch DL traffic with iperf command (UDP). Server info are valued in __init__.py (custom part)
    ...              This keyword take as argument:
    ...                    . ${distantip}
    ...                    . ${tput} by default 1000M     DL Tput
    ...                    . ${duration} by default 60000   duration of DL traffic
    ...                    . ${ueid} by default 0        number to compute used port, discriminating each mobile of the test on same server.
    ...              Author: Denis
    ...                      Update 2019.08.22  Annie Wong
    [Arguments]         ${distantip}   ${tput}=1800M     ${duration}=60000     ${ueid}=0


    ${port}                     Get Traffic port    DL      ${ueid}

	# UE Side
	# -------
    ssh.Connect To              ${IPERF_VM_UL_IPADDRESS}         ${IPERF_VM_UL_LOGIN}       ${IPERF_VM_UL_PASSWD}
    ...                         alias=iPerfUE


	# DL : stop on going DL iperf3
    #ssh.execute    command=adb shell -n "ps -ef|grep iperf3|grep -v 'grep'|grep ${port}|awk '{print $2}'|xargs kill -9"   connection=iPerfUE
    ssh.Send Command            command=adb shell "pkill iperf3"
    ...                         connection=iPerfUE
    ssh.Send Command            command=adb shell -n "rm /data/iPerfUEdl.log"
    ...                         connection=iPerfUE


	# DL : start DL iperf3
	log to console              -------Start DL Traffic UE Side	
	log                         adb shell "iperf3 -4 -s -i 1 -p ${port} -V --logfile /data/iPerfUEdl.log" &
    ssh.Send Command            command=adb shell "iperf3 -4 -s -i 1 -p ${port} -V --logfile /data/iPerfUEdl.log" &
    ...                         connection=iPerfUE
 	# check if the command has well started
    sleep                       5s
    ${result}                   ssh.Execute     command= adb shell -n "cat /data/iPerfUEdl.log"
    ...                         connection=iPerfUE
    should not contain          ${result}       iperf3: exiting
    
	ssh.disconnect              connection=iPerfUE



	# TS Side
	# -------
    ssh.Connect To              ${IPERF_VM_DL_IPADDRESS}         ${IPERF_VM_DL_LOGIN}          ${IPERF_VM_DL_PASSWD}
    ...                         alias=iPerfCN

	# DL : stop on going DL iperf3
	ssh.execute         		ps -ef|grep iperf3|grep -v "grep"|grep ${port}|awk '{print $2}'|xargs kill -9      connection=iPerfCN
	#ssh.Send Command            command=pkill -e iperf
    #...                         connection=iPerfCN
	ssh.Send Command            command=rm iperfDL.log
    ...                         connection=iPerfCN


	# DL : start DL iperf3
	log to console              -------Start DL Traffic TS Side		
    log                         iperf3 -c ${distantip} -u -i 1 -b ${tput} -t ${duration} -p ${port} -l 1300 --logfile iperfDL.log &
    ssh.Send Command            command=iperf3 -c ${distantip} -u -i 1 -b ${tput} -t ${duration} -p ${port} -l 1300 --logfile iperfDL.log &
    ...                         connection=iPerfCN
	# check if the command has well started
    sleep                       5s
    ${result}                   ssh.Execute     command=cat iperfDL.log
    ...                         connection=iPerfCN
    #should contain              ${result}       local ${COREIPTRAFFICSERVER} port
    #should contain              ${result}       connected to ${distantip} port ${port}



    ssh.disconnect              connection=iPerfCN




Start UL Traffic LA
    [Documentation]  Launch UL traffic with iperf command (UDP). Server info are valued in tlconfig.py (config file)
    ...              This keyword take as argument:
    ...                    . ${distantip}
    ...                    . ${tput} by default 200M     DL Tput
    ...                    . ${duration} by default 60000   duration of DL traffic
    ...                    . ${ueid} by default 0        number to compute used port, discriminating each mobile of the test on same server.
    ...              Author: Denis
    ...             05.11.2019 : Modification to launch iperf receiver
    [Arguments]         ${distantip}   ${tput}=200M     ${duration}=60000     ${ueid}=0


    ${port}             		Get Traffic port    UL      ${ueid}

	
	# TS Side
	# -------
    ssh.Connect To              ${IPERF_VM_DL_IPADDRESS}         ${IPERF_VM_DL_LOGIN}          ${IPERF_VM_DL_PASSWD}
    ...                         alias=iPerfCN
		
	# UL : stop on going UL iperf3
	ssh.execute         		ps -ef|grep iperf|grep -v "grep"|grep ${port}|awk '{print $2}'|xargs kill -9      connection=iPerfCN
    #ssh.Send Command            command=pkill -e iperf
    #...                         connection=iPerfCN
	#ssh.Send Command            command=rm iperfUL.log
    #...                         connection=iPerfCN
		

	# UL : start UL iperf3
	log to console              -------Start UL Traffic TS Side		
    log                         iperf3 -s -i 1 -p ${port} -4 -D --logfile iperfUL.log &
    ssh.Send Command            command=iperf3 -s -i 1 -p ${port} -4 -J &
    ...                         connection=iPerfCN
 	# check if the command has well started
    log to console				CHECK_TS_SIDE_!!!!!!
    sleep                       30s    
    ${result}                   ssh.Execute     command=cat iperfUL.log
    ...                         connection=iPerfCN
    #should contain              ${result}       local ${COREIPTRAFFICSERVER} port
    #should contain              ${result}       connected to ${distantip} port ${port}

    ssh.disconnect              connection=iPerfCN


	# UE Side
	# -------
    ssh.Connect To              ${IPERF_VM_UL_IPADDRESS}         ${IPERF_VM_UL_LOGIN}       ${IPERF_VM_UL_PASSWD}
    ...                         alias=iPerfUE
	
	# UL : stop on going UL iperf
    #ssh.execute    command=adb shell -n "ps -ef|grep iperf|grep -v 'grep'|grep ${port}|awk '{print $2}'|xargs kill -9"   connection=iPerfUE
    ssh.Send Command            command=adb shell "pkill iperf" &
    ...                         connection=iPerfUE
    #ssh.Send Command            command=adb shell -n "rm /data/iPerfUEul.log"
    #...                         connection=iPerfUE

    sleep                       1s

	# UL : start UL iperf3
	log to console              -------Start UL Traffic UE Side	
	log to console              adb shell -n "/data/iperf-android -c ${COREIPTRAFFICSERVER} -u -i 1 -p ${port} -b ${tput} -t ${duration}"
    sleep                       1s
    #ssh.Send Command            command=adb shell -n "iperf3 -s -4 -i1 -p34500" connection=iPerfUE
    ssh.Send Command
    ...   command=adb shell -n "iperf3 -c ${COREIPTRAFFICSERVER} -u -i1 -b200M -p ${port} --udp-counters-64bit -t60000 -Z -A3 --forceflush" &
    ...	  connection=iPerfUE
	log to console              CHECK_UE_SIDE_!!!!!!!
    sleep                       30s
 	# check if the command has well started
    sleep                       1s
    #${result}                   ssh.Execute     command= adb shell -n "cat /data/iPerfUEul.log"
    #...                         connection=iPerfUE
    #should not contain          ${result}       iperf: exiting

    ssh.disconnect              connection=iPerfUE


Get Traffic port
    [Documentation]  Retrieve iperf port from UEid.
    ...              and values that should contain.
    [Arguments]      ${direction}    ${ueid}=0
    #${port}       	Evaluate         34000 + ${ueid}
    #log to console           port=${port}	
	

    ${port}=         Run Keyword if   '${direction}' == 'DL'    Evaluate         34100 + ${ueid}
	...              ELSE                  		                Evaluate         34500 + ${ueid}


    Return from Keyword           ${port}




Stop Traffic LA
    [Documentation]  Stop DL/ UL traffic by killing Iperf process on port numbered based on ueid. Server info are valued in tlconfig.py (config file)
    ...              This keyword take as argument:
    ...                    . ${ueid} by default 0       number to compute port, discriminating each mobile of the test on same server.
    ...              Author: Denis
    [Arguments]         ${direction}  ${ueid}=0


	log to console              Stop Traffic LA-----------------direction=${direction}

    ${port}             		Get Traffic port        ${direction}       ${ueid}

	# TS Side
	# -------
    ssh.Connect To              ${IPERF_VM_DL_IPADDRESS}         ${IPERF_VM_DL_LOGIN}          ${IPERF_VM_DL_PASSWD}
    ...                         alias=iPerfCN

    # Kill all iperf processes
    ${result}                   ssh.execute         command=pkill -e iperf         connection=iPerfCN
    ${result}                   ssh.execute    ps -ef|grep iperf|grep -v "grep"|grep ${port}|awk '{print $2}'|xargs kill -9      connection=iPerfCN
    #log to console              *************************************resultTS=${result}

    # Check that at least one process has been killed.
    #should contain              ${result}       iperf3 killed
	
    sleep                    	2s
    ssh.disconnect              connection=iPerfCN


    # UE Side
    # -------		
    ssh.Connect To              ${IPERF_VM_UL_IPADDRESS}         ${IPERF_VM_UL_LOGIN}       ${IPERF_VM_UL_PASSWD}
    ...                         alias=iPerfUE

    ssh.Send Command            command=adb shell "pkill iperf"
    ...                         connection=iPerfUE
 
    #${result}    ssh.execute    command=adb shell "ps -ef|grep iperf3|grep -v "grep"|grep '${port}'|awk '{print $2}'|xargs"   connection=iPerfUE
    #log to console              *************************************resultUE=${result}
    #${result}   ssh.execute
    #...    command=adb shell "ps -ef|grep iperf3|grep -v "grep"|grep '${port}'|awk '{print $2}'|xargs kill -9"
    #...    connection=iPerfUE

    ##########
    #OK  ${result}   ssh.execute  adb shell -n "kill -9 11914"  connection=iPerfUE
    #    log to console              ==================================================result0=${result}
    #${result}    ssh.execute
    #...    command=adb shell -n "ps -ef|grep iperf3|grep -v 'grep'|grep ${port}|awk '{print $2}'|xargs kill -9"
    #...    connection=iPerfUE
    ##########
	
    sleep                    2s
    ssh.disconnect           connection=iPerfUE

