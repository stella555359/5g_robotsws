*** Settings ***
Documentation
...             :author/s:     francois.tourlonnias@nokia.com
...             :description:  First attempt to start AEP lua scripts

Library                   taf.wts.runner                          WITH NAME    wtsemu

Resource                  ../../../../../resources/SWENG/robot/Oam.robot
Resource                  ../../../../../resources/SWENG/robot/Restart.robot
*** Variables ***
# Define variables here.
${somelua}                 sansa.lua

*** Keywords ***
# Define custom keywords here.

AEP_Restart_OAM
    OAM Reset SIte         ${GNB_DU.oam}
    OAM Wait Available     ${GNB_DU.oam}     400

AEP_TL_Restart
    Set Suite Variable     ${Verdict_TL_Restart}    FAILED
    Dated Log              TL_Restart
    Restart.Restart TL     #isOAMRebooted=TruAEP_Restart_OAM
    Set Suite Variable     ${Verdict_TL_Restart}    PASS

AEP_LaunchWTS
    [Arguments]            ${luafile}=${CURDIR}/resources/script/WTS1_config_TDD_6CC.lua

    Dated Log              Starting AEP_LaunchWTS
    ${alias}               SSH Wait For Connect                    host=${HOST_EPCSIM}
    # WTS Clear              #Stop WTSEmu, kill eDaemon and eGate processes, and purge WTS logs  toomuch already done on Restart.Restart TL
    WTS Start processes    telnet_egate_addr=${tl.core.default_ssh_connection_details.addr}

    Dated Log              AEP cfg file= ${luafile}
    wtsemu.sim_cfg         file=${luafile}
    ...                    entry=run_configuration(3600)
    Dated Log              AEP Waiting CHANGE STATE: ACTIVE - SimMode is ready now
    Flush Egate Console Buffer    # Flush the buffer to be sure to have all egate console log
    wtsemu.Read Wtsemu Output Until Re
	...                    expected=CHANGE STATE: ACTIVE - SimMode is ready now
	...                    timeout=300
	sleep                  30s
