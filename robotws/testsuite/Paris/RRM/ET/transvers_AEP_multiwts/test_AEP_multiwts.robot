*** Settings ***
Documentation
...             :author/s:     francois.tourlonnias@nokia.com
...             :description:  Multiple wts management on AEP Tesline cell_setups and L3 calls
...             :status:       experimental
# ----------------------------------------------------------------------------------------------
# Libraries
# ----------------------------------------------------------------------------------------------
Library           BuiltIn
Library           OperatingSystem

# ----------------------------------------------------------------------------------------------
# Resources
# ----------------------------------------------------------------------------------------------
Resource          ./resources/robot/AEP_multiwts_Keywords.robot
Resource          ../resources/robot/KeyWordMarket.robot
Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/CallSetup.robot

Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
...               CLOUD_5G_I_MPPP_3xAP_LOOO+ECPRI_CMWV_TDD_AEQE

# Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}  #fromscratch realise un wtsclear
Suite Setup       Setup.suite setup    keepAllUeDataInCfgFile=${True}  # Keep UE data in the cfg file
...                                    edaemonPort=${22222}
...                                    egatePort=${30000}
Test Teardown     AEP_Test_Teardown
# Suite Teardown    Setup.Suite Teardown       #reset_ap=${True}

*** Variables ***
${TC_Name}                    AEP_Template
${CONFIGURED_ACTIVE_REGEX}    Active\\s+600
# ${CONFIGURED_ACTIVE_REGEX}    Active                   600
# ${CONFIGURED_ACTIVE_REGEX}    Active                   600        0         600
# ${CONFIGURED_ACTIVE_REGEX}    Active\\s+600\\s+0\\s+600
# ${CONFIGURED_ACTIVE_REGEX}    Active\\s{19}600\\s{8}0\\s{9}600

${howlong}                    3600   # configuration time for the AEP cell setup and callsetup (lua script execution)
${estimateTimeForL3call}      50     # minutes to wait for the L3 calls 100 UE by cell with traffic to be established
${l3callSerialized}           ${False}  # False in // I want to have all the L3 calls in parallel
${VMmonitoring}               ${False}
${NoSnap}                     ${True}    # basicaly snapshot are waited. this variable is also settale via external variable
${BtsLogStarted}              ${False}

*** Test Cases ***
AEP_multiwts_100UEperCell_6cells
    [Documentation]           AEP_multiwts 100UEperCell 6cells
    ...                       description:  AEP_multiwts 100UEperCell 6cells
    ...                       cells are filled with 100UE each and L3 calls are established with traffic for ${howlong} minutes
    ...                       cell filling order cell1, cell2, cell3, cell4, cell5, cell6
    ...                       The test is successful if all UE are in connected state after the L3 calls

    Dated Log New Line    ==================================
    Dated Log    ==....█████╗.███████.██████╗....==
    Dated Log    ==...██╔══██╗██╔════╝██╔══██╗...==
    Dated Log    ==...███████║█████╗..██████╔╝...==
    Dated Log    ==...██╔══██║██╔══╝..██╔═══╝....==
    Dated Log    ==...██║..██║███████╗██║........==
    Dated Log    ==...╚═╝..╚═╝╚══════╝╚═╝........==
    Dated Log    ==================================

    # Init Sequence          _                                  # step managment and Set Suite variables settings
    Set Debug Mode                  ${False}                    # Set debug mode to True
    kwmkt_Create_Test_Suite_Folder

    Dated Log New Line              ***** ${TC_Name} Starting *****
    # Suite setup discover itself how many wts emulators are available on the Test line
    Run Keyword If    ${SUITE_DEBUG_MODE}
    ...               AEP_multiwtsemu_Display_TL_Structure        nbVMwts=${nbVMwts}    alias_list=${alias_list}

    # following abandoned because of the new AEP_multiwtsemu_instance_creation
    # in fact impossible to find any TAF objects to record in multiwtsemu.create_instance object on resources/python/MultiWtsEmu.py
    # AEP_multiwtsemu_instance_creation                             nbVMwts=${nbVMwts}

    AEP_Start_Btslog                                              addr=${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...                                                           username=${tl.test_pcs[0].default_ssh_connection_details.username}
    ...                                                           password=${tl.test_pcs[0].default_ssh_connection_details.password}

    ${VM_luaPath}                                                 Set Variable          ${CURDIR}/resources/script/100uePerCell
    # AEP_multiwtsemu_TL_Restart
    AEP_multiwtsemu_TL_Restart

    kwmkt_Alarmslist                                              Start    ${logsDir}
    AEP_multiwtsemu_WTS_StartConfig                               VM_luaPath=${VM_luaPath}    nbVMwts=${nbVMwts}
    ...                                                           Connect.DicHOSTSwts=${Connect.DicHOSTSwts}
    AEP_multiwtsemu_Cell_Setup_Check                              nbVMwts=${nbVMwts}

    sleep                                                         60s
    AEP_multiwtsemu_L3Call                                        nbVMwts=${nbVMwts}
    ...                                                           l3callSerialized=${l3callSerialized}
    ...                                                           howlong=${howlong}
    ...                                                           estimateTimeForL3call=${estimateTimeForL3call}

# miseaupoint

#     # Init Sequence          _                                  # step managment and Set Suite variables settings
#     Set Debug Mode                  ${True}                    # Set debug mode to True
#     kwmkt_Create_Test_Suite_Folder

#     Dated Log New Line              ***** ${TC_Name} Starting *****
#     # Suite setup discover itself how many wts emulators are available on the Test line
#     AEP_multiwtsemu_Display_TL_Structure        nbVMwts=${nbVMwts}    alias_list=${alias_list}

