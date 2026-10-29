*** Settings ***
Documentation
...     Keywords Purpose:
...         Keywords for SSH checks with connection to controller

Library             taf.transport.ssh              WITH NAME    ssh

Library             OperatingSystem
Library             DateTime
Library             String


*** Keywords ***

Connect To HW Unit
        [Arguments]           ${HOSTNAME}                   ${USER}       ${PASSWORD}             ${ALIAS}
        ...                   ${PROXY}=${None}              ${TIMEOUT}=2000
        ${SSH_CONN}           ssh.connect_to                hostname=${HOSTNAME}         username=${USER}
        ...                   password=${PASSWORD}          proxy=${PROXY}               timeout=${TIMEOUT}
        ...                   alias=${ALIAS}
        [Return]              ${SSH_CONN}

disconnect from hw unit
        [Arguments]           ${HW_CONNECTION}
        ssh.disconnect        connection=${HW_CONNECTION}

Connect To LMP
        [Arguments]             ${IP}=${LMP_IP}
        ...                     ${USERNAME}=${LMP_USER_NAME}
        ...                     ${PASSWORD}=${LMP_PWD}
        Connect To HW Unit      ${IP}          ${USERNAME}         ${PASSWORD}          LMP

disconnect from LMP
        disconnect from hw unit    LMP

Connect To DCAP
        [Arguments]            ${IP}=${DCAP_IP}
        ...                    ${USERNAME}=${DCAP_USER_NAME}
        ...                    ${PASSWORD}=${DCAP_PWD}
        Connect To HW Unit     ${IP}          ${USERNAME}         ${PASSWORD}          DCAP

disconnect from DCAP
        disconnect from hw unit    DCAP

Connect To OAM
        [Arguments]            ${IP}=${ASIK_OAM_IP}
        ...                    ${USERNAME}=${ASIK_USER_NAME}
        ...                    ${PASSWORD}=${ASIK_USER_PWD}
        Connect To HW Unit     ${IP}          ${USERNAME}         ${PASSWORD}          OAM

disconnect from OAM
        disconnect from hw unit    OAM

Check FCT Status From Asik AdetS Classical
    [Documentation]         Perform Adet command on ASIK and check status of FSM1_FCT
    ssh.execute             command=export PATH=/usr/local/bin:/usr/sbin:/usr/bin
    ...                     connection=OAM
    ${output}               ssh.execute
    ...                     command=export PYTHONPATH=/opt/hwmt/python; python /opt/hwmt/python/hwapi/AdetS.py -s
    ...                     connection=OAM
    should not start with   ${output}           timeout while waiting for message            msg=No board detected
    should contain          ${output}           0x10\tFSM1_FCT\tready[0]

Check FBBs Status From Asik AdetS Classical
    [Documentation]         Perform Adet command on ASIK and check status of all FBB boards
    ssh.execute         command=export PATH=/usr/local/bin:/usr/sbin:/usr/bin
    ...                 connection=OAM
    ${output}           ssh.execute
    ...                 command=export PYTHONPATH=/opt/hwmt/python; python /opt/hwmt/python/hwapi/AdetS.py -s | grep FSM1_FSP
    ...                 connection=OAM
    should not start with   ${output}           timeout while waiting for message           msg=No board detected
    ${nb_lines}         get line count         ${output}
    log                 ${nb_lines} ABIL detected
    @{output}           Split to Lines         ${output}

    FOR                ${index}               IN RANGE                ${nb_lines}
                        ${nb_abil}             evaluate                ${nb_lines}+1
                        should contain         @{output}[${index}]     ready[0]             msg=ABIL ${nb_abil} failed
    END

Uncommissioned Check with Adet command
    [Documentation]     Check KPI after poweroff/on or reset
    ...                 KPI is compared with a reference duration and store Failed/Success tests
    [Arguments]         ${RESET_MAX_TIME}
    ${Time_Now}=        Get current date
    sleep               120s
    Wait Until Keyword Succeeds         300s         10s      Connect To LMP
    Wait Until Keyword Succeeds         300s         10s      Check boards with Adet command
    ${Time_Now}=        Get current date                result_format=%Y-%m-%d_%H:%M:%S
    ${DiffTime}=        Subtract Date from Date         ${Time_Now}     ${RESET_START_DATE}     result_format=number
    ${out}              Convert Time                    ${DiffTime}     verbose
    Run Keyword IF      ${DiffTime} > ${RESET_MAX_TIME}
    ...     Run Keyword and continue on failure     Result_Failure
    ...     ${RESET_START_DATE}      ${Time_Now}       ${out}        Fail       ${TEST_LOOP}
    ...     ELSE
    ...     Run Keyword and continue on failure     Result_success
    ...     ${RESET_START_DATE}      ${Time_Now}       ${out}        Success    ${TEST_LOOP}

Check boards with Adet command
    [Documentation]         Perform Adet command on ASIx board and check status of FSM1_FCT and FSM1_FSP1
    ...                     It works for one FSM1_FSP1
    Connect To LMP
    ${output}               ssh.execute        command=chk adet      connection=LMP
    should contain          ${output}          _FCT ready[0]
    should contain          ${output}          _FSP1 ready[0]
    [Teardown]              disconnect from LMP

Collect PM files
    [Documentation]         Based on SSH connection on the Classical Controller, Download all generated PM files located on /tmp folder
    [Arguments]                 ${folder}
    OperatingSystem.Create Directory         ${custom['PATH_Storage']}/PM/${folder}
    ${pm_files}=                ssh.execute             command=ls /tmp/PM.BTS*.xml*        connection=OAM
    @{pm_files_list}            split string      string=${pm_files}
    FOR    ${file}     IN      @{pm_files_list}
            ${file}             Fetch from right        ${file}         /
            ssh.Download File       /tmp/${file}    ${custom['PATH_Storage']}/PM/${folder}/${file}     connection=OAM
    END

Check the container status id=${node_id}
    [Documentation]         Check all containers status of the board given in argument (ASIK-Master / ASIK-Slave / ABIL)
    ${out}           ssh.execute
    ...         command=export PYTHONPATH=/opt/hwmt/python;python /opt/hwmt/python/hwapi/SupervisorS.py -n ${node_id} -o list_cbts
    ...         connection=OAM
#
    ${output}           get lines containing string         ${out}       localNodeId
    @{output}           split to lines                      ${output}
#
    FOR                ${line}          IN      @{output}
                should contain         ${line}     nodeState:3
    END

Check gNB ASIB ABIO containers are running
    [Documentation]     List containers on ASIB and ABIO and check they are in running state
    Connect To LMP
    ${cont_asix}        ssh.execute           command=lxc-ls --line -f -F NAME,STATE
    ...                 connection=LMP
    ${nb_lines}         get line count         ${cont_asix}
    @{output}           Split to Lines         ${cont_asix}
    FOR                ${i}                   IN RANGE                1          ${nb_lines}
                        should contain         @{output}[${i}]         RUNNING
    ...                 msg=@{output}[${i}] container not RUNNING
    END
    ${cont_abio}        ssh.execute           command=bsh 1:0 lxc-ls --line -f -F NAME,STATE
    ...                 connection=LMP
    ${nb_lines}         get line count         ${cont_abio}
    @{output}           Split to Lines         ${cont_abio}
    FOR                ${i}                   IN RANGE                1          ${nb_lines}
                        should contain         @{output}[${i}]         RUNNING
    ...                 msg=@{output}[${i}] container not RUNNING
    END
    [Teardown]          disconnect from LMP

Deactivation Link Adaptation on swconfig
    [Documentation]         workaround on swconfig.txt to disable Link adaptation
    ssh.execute         command=sed '/0x580011/d' swconfig.txt
    ...                 connection=OAM
    ssh.execute         command=sed '/0x580012/d' swconfig.txt
    ...                 connection=OAM
    ssh.execute         command=sed '/0x580013/d' swconfig.txt
    ...                 connection=OAM
    ssh.execute         command=sed '/0x580014/d' swconfig.txt
    ...                 connection=OAM

    ssh.execute         command=echo 0x580011=0 >> /ffs/run/swconfig.txt
    ...                 connection=OAM
    ssh.execute         command=echo 0x580012=0 >> /ffs/run/swconfig.txt
    ...                 connection=OAM
    ssh.execute         command=echo 0x580013=0 >> /ffs/run/swconfig.txt
    ...                 connection=OAM
    ssh.execute         command=echo 0x580014=0 >> /ffs/run/swconfig.txt
    ...                 connection=OAM

    ssh.execute         command=crasign /ffs/run/swconfig.txt
    ...                 connection=OAM

Reset Board
    [Documentation]         Perform a power off/on of the FBB board given in argument
    [Arguments]         ${abil_id}=${BOARD_ID}

    ssh.execute         command=export PATH=/usr/local/bin:/usr/sbin:/usr/bin
    ...                 connection=OAM

    Log                                  board_pwr_shutdown slot_id_${abil_id} 1
    ${output}           ssh.execute
    ...                 command=echo 1 > /dev/ddal/power/slot_id_${abil_id}/board_pwr_shutdown
    ...                 connection=OAM

    Sleep               2s

    Log                                  board_pwr_shutdown slot_id_${abil_id} 0
    ${output}           ssh.execute
    ...                 command=echo 0 > /dev/ddal/power/slot_id_${abil_id}/board_pwr_shutdown
    ...                 connection=OAM

Get Mem Usage
    [Documentation]         Based of FBB board id given in argument, check of the Total / Free / Available memory
    ...                     depending on the period given in agument : before, during or after launching trafic
    [Arguments]         ${board_id}     ${period}
#
    ${CURRENT_DATE}=    Get current date    result_format=%Y-%m%d_%H:%M:%S
#
	${MemTotal}			ssh.execute			command=bsh ${board_id}:0 cat /proc/meminfo | grep -i MemTotal		connection=OAM
	...                 timeout=10s
	${MemFree}			ssh.execute			command=bsh ${board_id}:0 cat /proc/meminfo | grep -i MemFree		connection=OAM
	...                 timeout=10s
	${MemAvailable}		ssh.execute			command=bsh ${board_id}:0 cat /proc/meminfo | grep -i MemAvailable	connection=OAM
	...                 timeout=10s
#
    ${RESET_RESULT_FILE}=   Catenate    SEPARATOR=_     /tmp/Mem_Usage          ${CURRENT_DATE}_${period}.txt
#
    ssh.execute     command=bsh ${board_id}:0 grep -R "" /sys/kernel/mm/hugepages/ /proc/sys/vm/*huge* > ${RESET_RESULT_FILE}
    ...             connection=OAM
	ssh.execute	    command=bsh ${board_id}:0 cat /proc/cmdline >> ${RESET_RESULT_FILE}     connection=OAM
	ssh.execute	    command=bsh ${board_id}:0 cat /proc/meminfo >> ${RESET_RESULT_FILE}     connection=OAM
	ssh.execute	    command=bsh ${board_id}:0 cat /proc/iomem >> ${RESET_RESULT_FILE}       connection=OAM
	ssh.execute	    command=bsh ${board_id}:0 cat /proc/mtd >> ${RESET_RESULT_FILE}         connection=OAM
	ssh.execute	    command=bsh ${board_id}:0 cat /var/log/xstart.msg >> ${RESET_RESULT_FILE}   connection=OAM
	ssh.Download File    ${RESET_RESULT_FILE}    ${RESET_RESULT_FILE}   connection=OAM
	ssh.execute	    command=rm -f ${RESET_RESULT_FILE}                  connection=OAM

Set gnb in uncommissioned mode
    ${output}               ssh.execute        command=cd /ffs/run/config ; rm -rf *     connection=LMP
    ${output}               ssh.execute        command=cd /ffs/run/logs ; rm -rf *       connection=LMP
    ${output}               ssh.execute        command=systemctl reboot                  connection=LMP
    [Teardown]              disconnect from LMP
