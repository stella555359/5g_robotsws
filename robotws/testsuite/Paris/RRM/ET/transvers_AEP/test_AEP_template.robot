*** Settings ***
Documentation
...             :author/s:     francois.tourlonnias@nokia.com
...             :description:  First attempt to start AEP lua scripts
...                            THIS IS USED ON MONO WTS AEP TEST LINES ONLY

# ----------------------------------------------------------------------------------------------
# Libraries
# ----------------------------------------------------------------------------------------------
Library           BuiltIn
Library           OperatingSystem
Library           taf.wts.runner                         WITH NAME    wtsemu

# ----------------------------------------------------------------------------------------------
# Resources
# ----------------------------------------------------------------------------------------------
Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/CallSetup.robot
Resource          ./resources/robot/AEP_Keywords.robot

Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

# Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}  #fromscratch realise un wtsclear
Suite Setup       Setup.suite setup    keepAllUeDataInCfgFile=${True}  # Keep UE data in the cfg file
...                                    edaemonPort=${22222}
...                                    egatePort=${30000}
# ...                                    debug=${True}                   # not play another Get TL Info and a lot of things
#...                                    automaticTeardown=${True}

# Suite Teardown    Setup.Suite Teardown       reset_ap=${True}

*** Variables ***
${TC_Name}                    AEP_Template
${CONFIGURED_ACTIVE_REGEX}    Active\\s+600
# ${CONFIGURED_ACTIVE_REGEX}    Active                   600
# ${CONFIGURED_ACTIVE_REGEX}    Active                   600        0         600
# ${CONFIGURED_ACTIVE_REGEX}    Active\\s+600\\s+0\\s+600
# ${CONFIGURED_ACTIVE_REGEX}    Active\\s{19}600\\s{8}0\\s{9}600


*** Test Cases ***
AEP_Template
    [Documentation]        AEP_Template

    # Init Sequence          _                                  # step managment and Set Suite variables settings
    Dated Log New Line     * * * * * ${TC_Name} Starting * * * * * * * * * * * * * * * * * * * *
    AEP_TL_Restart

    AEP_LaunchWTS          luafile=${CURDIR}/resources/script/WTS1_config_TDD_6CC.lua

    Dated Log              AEP Waiting MIB-SIB
    wtsemu.script          file=${CURDIR}/resources/script/multi_ue_sa_script_new.lua
    ...                    entry=check_CellSetup(1,6)
    Dated Log              AEP Checking SIBs
    Flush Egate Console Buffer    # Flush the buffer to be sure to have all egate console log
    wtsemu.Read Wtsemu Output Until Re
	...                    expected= Cell Setup Check Script Complet
	...                    timeout=300

    sleep                  30s
    Dated Log              AEP L3 Call ongoing
    wtsemu.script          file=${CURDIR}/resources/script/sansa_WTS1_FTS_2502.lua
    ...                    entry=launch_multi_l3_calls(mbps,10,10,both,3600)


    ${timeout}=            Set Variable    1200    # Total maximum time in seconds (20 minutes)
    ${interval}=           Set Variable    30      # Interval between each check in seconds
    ${elapsed}=            Set Variable    0       # Elapsed time initialized to 0

    Dated Log New Line     AEP Checking 100 L3 Calls + traffic on 6 cells <= ${timeout} seconds using re:${CONFIGURED_ACTIVE_REGEX}
    # wtsemu.Read Wtsemu Output Until Re
    # ...                    expected=${CONFIGURED_ACTIVE_REGEX}
    # ...                    timeout=${timeout}
    WHILE    ${elapsed} < ${timeout}
        Dated Log New Line          Verification of Configured and Active values (attempt after ${elapsed} seconds)
        Sleep              ${interval}    # Wait 30 seconds before the next attempt
        wtsemu.ue_summary
        Flush Egate Console Buffer   # Flush the buffer to be sure to have all egate console log

        # ${status}    Run Keyword And Return Status    wtsemu.Read Wtsemu Output Until Re
        # ...                                            expected=${CONFIGURED_ACTIVE_REGEX}
        # ...                                            timeout=10
        ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.Read Wtsemu Output Until Re
        ...                                            expected=${CONFIGURED_ACTIVE_REGEX}
        ...                                            timeout=10
        Dated Log     D E B U G expected...:>${CONFIGURED_ACTIVE_REGEX}<
        Dated Log     D E B U G status.....:${status}
        Dated Log     D E B U G output.....:${output}
        Run Keyword If    '${status}' == 'PASS'    Exit For Loop
        Dated Log    all ue are not yet Active on traffic, continuing the loop

        ${elapsed}=        Evaluate       ${elapsed} + ${interval}
    END

    # Final verification if the condition has not been satisfied
    Run Keyword If    '${elapsed}' >= '${timeout}'    Fail    all Configured UE are not yet Active after 30 minutes.
