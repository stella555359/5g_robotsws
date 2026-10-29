*** Settings ***
Documentation
...                  == Purpose ==
...                  Module to manage main actions required to setup a call on simulator WTS module set (Airphone, ePCSim, LTESim).
...
...                  == Description ==
...                  This library support NSA and SA calls by using the simulator WTS module set (Airphone, ePCSim, LTESim).
...
...                  This library does not contain keyword to manage UE traffic.
...
...                  Main services are :
...                          - WTS Setup              : Start, configure and establish X2 link on WTS.
...                          - Check cell setup       : Checking cell setup messages on eGate console and/or Airphone log file.
...                          - SgNB Addition to ENB   : Trig secondary gNB addition of a NSA UE after attach procedure.
...                          - UE attach/detach       : Attach and detach precedures for NSA UE.
...                          - UE register/deregister : Register and deregister precedures for SA UE.
...                          - DSS                    : DSS configuration and establishment.
...                          - Get and Set UE CRNTI   : Get C_RNTI from egate_console.log, store it in the c_rnti param of the UeSetting dictionary.
...
...                 The CallSetup library is part of the SWENG environment. So to use this library in a robot test,
...                 it is important to import the SWENG Setup.robot library to define the 'Setup Suite' and the 'Teardown Suite' keywords.
...                 Without the use of the 'Setup Suite' of the SWENG environment, the CallSetup library could malfunction because
...                 variables linked to the environment would not be initialized.
...
...                 A certain number of keywords is based on a dictionary (mainly corresponding to the ueSetting argument) to describe the UE profile
...                 and which allows the expected good processing. This dictionary is also used by traffic keywords in the traffic.robot library
...                 (see traffic.robot).
...
...                 Overview of dictionary structure:
...                  - ue            : Ue id from config.cfg of Airphone.
...                  - profile       : Profile id or None (used in UE Attach NSA).
...                  - bearer        : One or more bearer id. In case of several bearer id, the format is a string containing a list of bearer id \
...                                    with each bearer id separated by a comma (2,8,...).
...                  - testMode      : Should test mode be used (True or False) for NSA mode.
...                  - trf_id        : Id for the traffic.
...                  - pdu           : Used for SA mode.
...                  - qfi           : Used for SA mode.
...                  - target_gnb    : Used by UE Attach in NSA mode.
...                  - target_cells  : Camped cell of UE.
...                  - type          : Used by bearer stat for traffic checking.
...                  - burst         : Specific usage when start traffic.
...                  - throughput    : Throughput requested to be generated on the bearer.
...                  - testModeValue : Used in UE Attach gNB in NSA mode during RACH procedure.
...                  - size          : Layer 3 packet size range (size includes all headers beginning from IP). \
...                                    Maximum of 1358 for NB-IoT UEs. Maximum of 9000 for UEs configured with NR PDCP. \
...                                    Otherwise, maximum is 8188 (default value: None).
...                  - period_ms     : Time interval between each emission of a burst.
...                  - c_rnti        : Used to store the c_rnti value after ue registration. Filled after call to "Get UE RNTI" KW.
...
...          4 variables based on the dictionary structure to define UE profile in CallSetup library.
...
...          _3 variables for NSA call_:
...
...          *&{UE_NO_PROFILE}*
...            | ue            | 1                    |
...            | profile       | None                 |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | qfi           | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...            | period_ms     | ${None}              |
...            | size          | ${None}              |
...            | c_rnti        | ${None}              |
...
...          *&{UE_SIMPLE}*
...            | ue            | 1                    |
...            | profile       | 1                    |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | qfi           | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...            | period_ms     | ${None}              |
...            | size          | ${None}              |
...            | c_rnti        | ${None}              |
...
...          *&{UE_SIMPLE_TEST_MODE}*
...            | ue            | 1                    |
...            | profile       | 1                    |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | qfi           | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | True                 |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...            | period_ms     | ${None}              |
...            | size          | ${None}              |
...            | c_rnti        | ${None}              |
...
...          _1 variable for SA call_:
...
...          *&{BASIC_UE_SA}*
...            | ue            | 1                    |
...            | profile       | None                 |
...            | type          | ${None}              |
...            | pdu           | 1                    |
...            | qfi           | 1                    |
...            | bearer        | ${None}              |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | ${None}              |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...            | period_ms     | ${None}              |
...            | size          | ${None}              |
...            | c_rnti        | ${None}              |
...
...          _Variables for TDD or FDD NSA call WITH NEW BASIC.CFG DESIGN_:
...
...          *&{NSA_UE_NO_PROFILE}*
...            | ue            | ${FIRST_NSA_UE_ID}   |
...            | profile       | None                 |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | qfi           | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...            | period_ms     | ${None}              |
...            | size          | ${None}              |
...            | c_rnti        | ${None}              |
...
...          *&{BASIC_UE_NSA_TDD}*
...            | ue            | ${FIRST_NSA_UE_ID_TDD}   |
...            | profile       | 1                        |
...            | type          | l3                       |
...            | pdu           | ${None}                  |
...            | qfi           | ${None}                  |
...            | bearer        | 2                        |
...            | testMode      | False                    |
...            | trf_id        | 1                        |
...            | burst         | ${None}                  |
...            | target_gnb    | 2                        |
...            | target_cells  | ${FIRST_TDD_NSA_CELL_ID} |
...            | throughput    | ${DEFAUT_THROUGHPUT}     |
...            | testModeValue | csi_report_override      |
...            | period_ms     | ${None}                  |
...            | size          | ${None}                  |
...            | c_rnti        | ${None}                  |
...
...          *&{BASIC_UE_NSA_FDD}*
...            | ue            | ${FIRST_NSA_UE_ID_FDD}   |
...            | profile       | 1                        |
...            | type          | l3                       |
...            | pdu           | ${None}                  |
...            | qfi           | ${None}                  |
...            | bearer        | 2                        |
...            | testMode      | False                    |
...            | trf_id        | 1                        |
...            | burst         | ${None}                  |
...            | target_gnb    | 2                        |
...            | target_cells  | ${FIRST_FDD_NSA_CELL_ID} |
...            | throughput    | ${DEFAUT_THROUGHPUT}     |
...            | testModeValue | csi_report_override      |
...            | period_ms     | ${None}                  |
...            | size          | ${None}                  |
...            | c_rnti        | ${None}                  |
...
...          _Variables for TDD or FDD SA call WITH NEW BASIC.CFG DESIGN_:
...
...          *&{BASIC_UE_SA_TDD}*
...            | ue            | ${FIRST_SA_UE_ID_TDD}   |
...            | profile       | None                    |
...            | type          | ${None}                 |
...            | pdu           | 1                       |
...            | qfi           | 1                       |
...            | bearer        | ${None}                 |
...            | testMode      | False                   |
...            | trf_id        | 1                       |
...            | burst         | ${None}                 |
...            | target_gnb    | ${None}                 |
...            | target_cells  | ${FIRST_TDD_SA_CELL_ID} |
...            | throughput    | ${DEFAUT_THROUGHPUT}    |
...            | testModeValue | csi_report_override     |
...            | period_ms     | ${None}                 |
...            | size          | ${None}                 |
...            | c_rnti        | ${None}                 |
...
...          *&{BASIC_UE_SA_FDD}*
...            | ue            | ${FIRST_SA_UE_ID_FDD}   |
...            | profile       | None                    |
...            | type          | 13                      |
...            | pdu           | 1                       |
...            | qfi           | 1                       |
...            | bearer        | ${None}                 |
...            | testMode      | False                   |
...            | trf_id        | 1                       |
...            | burst         | ${None}                 |
...            | target_gnb    | ${None}                 |
...            | target_cells  | ${FIRST_FDD_SA_CELL_ID} |
...            | throughput    | ${DEFAUT_THROUGHPUT}    |
...            | testModeValue | csi_report_override     |
...            | period_ms     | ${None}                 |
...            | size          | ${None}                 |
...            | c_rnti        | ${None}                 |
...
...        _Other variables are defined in library CallSetup.robot_:
...        | ${DEFAUT_THROUGHPUT} | 2 | Default throughtput is 2 mega |
...        | ${NO_THROUGHPUT}     | 0 | Define no throughput          |
...        | ${ENB_ID}            | 1 | Id for eNB (4G) as set in config file on WTS Changes these values ONLY accordingly deployed WTS confi file |
...        | ${GNB_ID}            | 2 | Id for gNB (5G) as set in config file on WTS Changes these values ONLY accordingly deployed WTS confi file |
...        | ${TARGET_CELLS}      | 1 |                               |
...
...          _Example_:
...
...          Do an 5G call setup and do traffic:
...          - Setup WTS with 2 cells
...          - Register a UE in SA mode on 5G core network
...          - Open a PDU session
...          - Modify the QoSFlow of a PDU session 2 times
...          - Do a traffic (see Traffic.robot library)
...          - Deregister the UE from 5G core network
...          | *** Settings ***
...          | Resource \ \ \ \ \ \ \ \ \ \ \ \ \ \ ../../../resources/SWENG/robot/Setup.robot
...          | Resource \ \ \ \ \ \ \ \ \ \ \ \ \ \ ../../../resources/SWENG/robot/CallSetup.robot
...          | Resource \ \ \ \ \ \ \ \ \ \ \ \ \ \ ../../../resources/SWENG/robot/Traffic.robot
...          |
...          | Suite Setup \ \ \ \ \ \ \ \ \ \ \ Suite Setup
...          | Suite Teardown \ \ \ \ \ \ \ \ Suite Teardown
...          |
...          | *** Test Cases ***
...          | Do a call with traffic
...          | \ \ \ Setup Wtsemu SA \ \ \ \ \ \ \ \ nbCell=2
...          | \ \ \ UE Register \ \ \ \ \ \ \ \ \ \ \ \ ue=3
...          | \ \ \ Launch PDU Session \ \ \ \ \ ue=3 \ \ \ \ \ \ \ \ \ pdu=3 \ \ \ gw=3
...          | \ \ \ UE PDU Session Modify \ \ ue=3 \ \ \ \ \ \ \ \ \ pdu=3 \ \ \ qfta=2 \ \ \ by=amf
...          | \ \ \ UE PDU Session Modify \ \ ue=3 \ \ \ \ \ \ \ \ \ pdu=3 \ \ \ qfta=3 \ \ \ by=amf
...          | \ \ \ #
...          | \ \ \ # Do traffic during n secondes by using Traffic.robot library
...          | \ \ \ #
...          | \ \ \ UE Deregister \ \ \ \ \ \ \ \ \ id=3
...

Library                             taf.wts.runner                         WITH NAME    wtsemu
Library                             taf.wts.runner                         WITH NAME    wtsemu_1    # temporary multwts purpose
Library                             taf.wts.runner                         WITH NAME    wtsemu_2    # tempotary multwts purpose
Library                             taf.wts.runner                         WITH NAME    wtsemu_3    # temporary multwts purpose
Library                             ../python/ReadConfig.py
Library                             ute_wtssim
Resource                            SetConfig.robot
Resource                            Capture.robot
Resource                            Topology.robot
Resource                            Tools.robot
Resource                            UteTools.robot
Resource                            Oam.robot
Resource                            WtsCfgConfig.robot
Library                             ../../../RRM/ET/resources/python/robot_extension.py   WITH NAME       robot_extension

*** Variables ***

# file to store GNB alarms when SIB check is failed
${SIB_ALARMS_FILE}                    alarms_when_sib_check_ko.txt

# Default throughtput is 2 mega.
${DEFAUT_THROUGHPUT}                2
${NO_THROUGHPUT}                    0

# Ids for eNB (4G) and gNB (5G) as set in configuration file on WTS
# Changes these values ONLY accordingly deployed WTS config file
${ENB_ID}                           1
${GNB_ID}                           2
${TARGET_CELLS}                     1

# List of common useful profiles for traffic
&{UE_NO_PROFILE}                    ue=1                                    profile=None        type=l3
...                                 pdu=${None}                             qfi=${None}         c_rnti=${None}
...                                 bearer=2                                testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=${GNB_ID}                    target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
...                                 period_ms=${None}                       size=${None}

&{UE_SIMPLE}                        ue=1                                    profile=1           type=l3
...                                 pdu=${None}                             qfi=${None}         c_rnti=${None}
...                                 bearer=2                                testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=${GNB_ID}                    target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
...                                 period_ms=${None}                       size=${None}

&{UE_SIMPLE_TEST_MODE}              ue=1                                    profile=1           type=l3
...                                 pdu=${None}                             qfi=${None}         c_rnti=${None}
...                                 bearer=2                                testMode=True
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=${GNB_ID}                    target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
...                                 period_ms=${None}                       size=${None}

&{BASIC_UE_SA}                      ue=1                                    profile=None        type=${None}
...                                 pdu=1                                   qfi=1               c_rnti=${None}
...                                 bearer=${None}                          testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=${None}                      target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
...                                 period_ms=${None}                       size=${None}

&{NSA_UE_NO_PROFILE}                ue=11                                   profile=None        type=l3
...                                 pdu=${None}                             qfi=${None}         c_rnti=${None}
...                                 bearer=2                                testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=${GNB_ID}                    target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
...                                 period_ms=${None}                       size=${None}

*** Keywords ***
CallSetup Init Variables
    [Arguments]                     ${shouldUseLua}
    ...                             ${nbUe}
    ...                             ${nbSaUe}
    ${newValue}                     evaluate                ${nbUe} - ${nbSaUe} + 1
    ${LUA_FIRST_SA_UE_ID}           Run Keyword If          ${shouldUseLua}==${True}    set variable    ${newValue}
    ${LUA_FIRST_NSA_UE_ID}          Run Keyword If          ${shouldUseLua}==${True}    set variable    1
    Run Keyword If                  ${shouldUseLua}==${True}    Set Suite Variable      ${FIRST_SA_UE_ID}       ${LUA_FIRST_SA_UE_ID}
    Run Keyword If                  ${shouldUseLua}==${True}    Set Suite Variable      ${FIRST_NSA_UE_ID}      ${LUA_FIRST_NSA_UE_ID}
    Dated Log New Line              FIRST_SA_UE_ID=${FIRST_SA_UE_ID}
    Dated Log New Line              FIRST_NSA_UE_ID=${FIRST_NSA_UE_ID}

    &{UE_NO_PROFILE}                create dictionary
    ...                             ue=${FIRST_NSA_UE_ID}                   profile=None        type=l3
    ...                             pdu=${None}                             qfi=${None}         c_rnti=${None}
    ...                             bearer=2                                testMode=False
    ...                             trf_id=1                                burst=${None}
    ...                             target_gnb=${GNB_ID}                    target_cells=${TARGET_CELLS}
    ...                             throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    ...                             period_ms=${None}                       size=${None}
    Set Suite Variable              &{UE_NO_PROFILE}

    &{UE_SIMPLE}                    create dictionary
    ...                             ue=${FIRST_NSA_UE_ID}                   profile=1           type=l3
    ...                             pdu=${None}                             qfi=${None}         c_rnti=${None}
    ...                             bearer=2                                testMode=False
    ...                             trf_id=1                                burst=${None}
    ...                             target_gnb=${GNB_ID}                    target_cells=${TARGET_CELLS}
    ...                             throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    ...                             period_ms=${None}                       size=${None}
    Set Suite Variable              &{UE_SIMPLE}

    &{UE_SIMPLE_TEST_MODE}          create dictionary
    ...                             ue=${FIRST_NSA_UE_ID}                   profile=1           type=l3
    ...                             pdu=${None}                             qfi=${None}         c_rnti=${None}
    ...                             bearer=2                                testMode=True
    ...                             trf_id=1                                burst=${None}
    ...                             target_gnb=${GNB_ID}                    target_cells=${TARGET_CELLS}
    ...                             throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    ...                             period_ms=${None}                       size=${None}
    Set Suite Variable              &{UE_SIMPLE_TEST_MODE}

    &{BASIC_UE_SA}                  create dictionary
    ...                             ue=${FIRST_SA_UE_ID}                    profile=None        type=l3
    ...                             pdu=1                                   qfi=1               c_rnti=${None}
    ...                             bearer=${None}                          testMode=False
    ...                             trf_id=1                                burst=${None}
    ...                             target_gnb=${None}                      target_cells=${TARGET_CELLS}
    ...                             throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    ...                             period_ms=${None}                       size=${None}
    Set Suite Variable              &{BASIC_UE_SA}

    &{NSA_UE_NO_PROFILE}            create dictionary
    ...                             ue=${FIRST_NSA_UE_ID}                   profile=None        type=l3
    ...                             pdu=${None}                             qfi=${None}         c_rnti=${None}
    ...                             bearer=2                                testMode=False
    ...                             trf_id=1                                burst=${None}
    ...                             target_gnb=${GNB_ID}                    target_cells=${TARGET_CELLS}
    ...                             throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    ...                             period_ms=${None}                       size=${None}
    Set Suite Variable              &{NSA_UE_NO_PROFILE}

    # Init variables for cells: UE id is set to None if no CELL of the type and technology is defined in the testline
    OAM Get Info From SCF

    # By default, all first SA or NSA UE Id are set to None
    ${FIRST_SA_UE_ID_TDD}           Set Variable            None
    ${FIRST_SA_UE_ID_FDD}           Set Variable            None
    ${FIRST_NSA_UE_ID_TDD}          Set Variable            None
    ${FIRST_NSA_UE_ID_FDD}          Set Variable            None

    ${FIRST_SA_UE_ID_TDD}           Run keyword If          '${TDD_SA_Cell_nb}'!='0' and '${TDD_Cell_nb}'!='0'
    ...                                                     Get First SA UE Id          cell=NRCELL-${TDD_Cell_list[0].nrCellId}
    ${FIRST_SA_UE_ID_FDD}           Run keyword If          '${FDD_SA_Cell_nb}'!='0' and '${FDD_Cell_nb}'!='0'
    ...                                                     Get First SA UE Id          cell=NRCELL-${FDD_Cell_list[0].nrCellId}
    ${FIRST_NSA_UE_ID_TDD}          Run keyword If          '${TDD_NSA_Cell_nb}'!='0' and '${TDD_Cell_nb}'!='0'
    ...                                                     Get First NSA UE Id         techno=TDD      cell_rank=${TDD_Cell_list[0].nrCellId}
    ${FIRST_NSA_UE_ID_FDD}          Run keyword If          '${FDD_NSA_Cell_nb}'!='0' and '${FDD_Cell_nb}'!='0'
    ...                                                     Get First NSA UE Id         techno=FDD      cell_rank=${FDD_Cell_list[0].nrCellId}

#    ${FIRST_TDD_CELL_ID}            Set Variable If         '${TDD_Cell_nb}'=='0'       None            ${TDD_Cell_list[0].nrCellId}
#    ${FIRST_FDD_CELL_ID}            Set Variable If         '${FDD_Cell_nb}'=='0'       None            ${FDD_Cell_list[0].nrCellId}

    ${FIRST_TDD_SA_CELL_ID}         Set Variable If         '${TDD_Cell_nb}'=='0' or '${TDD_SA_Cell_nb}'=='0'       None    ${TDD_SA_Cell_list[0]}
    ${FIRST_TDD_NSA_CELL_ID}        Set Variable If         '${TDD_Cell_nb}'=='0' or '${TDD_NSA_Cell_nb}'=='0'      None    ${TDD_NSA_Cell_list[0]}
    ${FIRST_FDD_SA_CELL_ID}         Set Variable If         '${FDD_Cell_nb}'=='0' or '${FDD_SA_Cell_nb}'=='0'       None    ${FDD_SA_Cell_list[0]}
    ${FIRST_FDD_NSA_CELL_ID}        Set Variable If         '${FDD_Cell_nb}'=='0' or '${FDD_NSA_Cell_nb}'=='0'      None    ${FDD_NSA_Cell_list[0]}

    &{BASIC_UE_SA_TDD}              create dictionary
    ...                             ue=${FIRST_SA_UE_ID_TDD}                profile=None        type=${None}
    ...                             pdu=1                                   qfi=1               c_rnti=${None}
    ...                             bearer=${None}                          testMode=False
    ...                             trf_id=1                                burst=${None}
    ...                             target_gnb=${None}                      target_cells=${FIRST_TDD_SA_CELL_ID}
    ...                             throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    ...                             period_ms=${None}                       size=${None}
    Set Suite Variable              &{BASIC_UE_SA_TDD}

    &{BASIC_UE_SA_FDD}              create dictionary
    ...                             ue=${FIRST_SA_UE_ID_FDD}                profile=None        type=l3
    ...                             pdu=1                                   qfi=1               c_rnti=${None}
    ...                             bearer=${None}                          testMode=False
    ...                             trf_id=1                                burst=${None}
    ...                             target_gnb=${None}                      target_cells=${FIRST_FDD_SA_CELL_ID}
    ...                             throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    ...                             period_ms=${None}                       size=${None}
    Set Suite Variable              &{BASIC_UE_SA_FDD}

    &{BASIC_UE_NSA_TDD}             create dictionary
    ...                             ue=${FIRST_NSA_UE_ID_TDD}               profile=1           type=l3
    ...                             pdu=${None}                             qfi=${None}         c_rnti=${None}
    ...                             bearer=2                                testMode=False
    ...                             trf_id=1                                burst=${None}
    ...                             target_gnb=${GNB_ID}                    target_cells=${FIRST_TDD_NSA_CELL_ID}
    ...                             throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    ...                             period_ms=${None}                       size=${None}
    Set Suite Variable              &{BASIC_UE_NSA_TDD}

    &{BASIC_UE_NSA_FDD}             create dictionary
    ...                             ue=${FIRST_NSA_UE_ID_FDD}               profile=1           type=l3
    ...                             pdu=${None}                             qfi=${None}         c_rnti=${None}
    ...                             bearer=2                                testMode=False
    ...                             trf_id=1                                burst=${None}
    ...                             target_gnb=${GNB_ID}                    target_cells=${FIRST_FDD_NSA_CELL_ID}
    ...                             throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    ...                             period_ms=${None}                       size=${None}
    Set Suite Variable              &{BASIC_UE_NSA_FDD}


#===================================
# WTS Setup
#===================================
WTS Setup
    [Documentation]                 Clean WTSEmu (processes, logs), restart ePC simulator (ePCSim)
    ...                             and configure it to establish a X2 link between eNB and gNB if gNB is configured in NSA mode.
    ...                             Wait for SIB-NR if not NSA and check cell setup.
    ...
    ...                             *Argument details:*
    ...                             - *telnet_egate_addr*: eGate VM IP address (default: dynamically retrieved)
    ...                             - *nbUe*: nb total of UE(s) to set in basic-setup LUA file (default value = 1)
    ...                             - *nbSaUe*: nb of SA UE(s) to set in basic-setup LUA file (default value = 0)
    ...                             - *shouldUseLua*: flag to choose between cfg or LUA basic-setup file (default value = True)
    ...                             - *bypassX2Setup*: flag to bypass the X2 setup - usually for SA (default value = False)
    ...                             - *nbCell*: number of cell to check for SystemInformationBlock-NR (default value = 0)
    ...                                         If nbCell=0 then checks are done for the total number of cells defined on the testline
    ...                             - *cellList*: list of cells ID to be used for checking (this parameter and "nbCell" parameters are
    ...                                           mutually excluded and this one has higher priority in case both arameters are provided)
    ...                             - *list_of_UE_tobe_created*: list of UEs structure to be created when using lua (default value = None)
    ...                                 mandatory params: ue & target_cells &{my_UE_SA}     ue=1    target_cells=2
    ...                             - *time_to_wait*: time to wait the SIB (default value = 5min)
    ...
    ...                             Exemple:
    ...                             | If nbUe = 10 and nbSaUe = 0, \ \ \ \ \ 10 NSA UE from 1 to 10, 0 SA UE
    ...                             | If nbUe = 10 and nbSaUe = 5, \ \ \ \ \ \ 5 NSA UE from 1 to 5, 5 SA UE from 6 to 10
    ...                             | If nbUe = 10 and nbSaUe = 10, \ \ \ \ \ 0 NSA UE, 10 SA UE from 1 to 10
    [Arguments]                     ${telnet_egate_addr}=${tl.core.default_ssh_connection_details.addr}
    ...                             ${nbUe}=1
    ...                             ${nbSaUe}=0
    ...                             ${shouldUseLua}=${True}
    ...                             ${bypassX2Setup}=${False}
    ...                             ${bypassSIB}=${False}
    ...                             ${nbCell}=0
    ...                             ${cellList}=${None}
    ...                             ${list_of_UE_tobe_created}=${None}
    ...                             ${shouldSaveBasicCfg}=${False}
    ...                             ${time_to_wait}=5min

    # New global variables setup
    CallSetup Init Variables        shouldUseLua=${shouldUseLua}
    ...                             nbUe=${nbUe}
    ...                             nbSaUe=${nbSaUe}

    # For SIB check, we have to use the number of unblocked SA cells
    ${NbrSACellUnblocked}   ${NbOfUnblockedCells}=      Run Keyword if   ${isAic}       OAM Number of Blocked Unblocked Cells VRAN
    ...                                                             ELSE                OAM Number of Blocked Unblocked Cells
    ${cell_len}                     Set Variable        ${NbOfUnblockedCells}
    ${cell_len}                     Convert to string   ${cell_len}
    ${cell_nr}                      set variable if     ${nbCell}==0    ${NbrSACellUnblocked}    ${nbCell}
    set suite variable              ${cell_nr}
    set suite variable              ${NbrSACellUnblocked}
    set suite variable              ${NbOfUnblockedCells}

    # Clean WTS from process and logs point of view
    ${isSANSA}                      set variable if     '${NWtype}' == 'SA+NSA'     ${True}    ${False}
    set suite variable              ${isSANSA}
    ${isNSA}                        set variable if    '${NWtype}' == 'NSA'         ${True}    ${False}
    set suite variable              ${isNSA}
    ${alias}                        SSH Wait For Connect                    host=${HOST_EPCSIM}
    Dated Log New Line              Starting WTS setup (WTS:IP=${HOST_EPCSIM.sshConnection.addr})
    WTS Clear
    # Cloud only
    Run Keyword If                  ${TLConfig.isGnbCloud} and not ${isAic}
    ...                             WTS Set Backhaul IP                     ${alias}
    # If lua file is requested, then init lua config file with nb of UEs:
    Run Keyword If                  ${shouldUseLua}
    ...                                 Run Keywords    Dated Log           Before Lua creation, FIRST_SA_UE_ID = ${FIRST_SA_UE_ID}
    ...                                          AND    Dated Log           Before Lua creation, FIRST_NSA_UE_ID= ${FIRST_NSA_UE_ID}
    ${LuaFileName}                  Run Keyword If      ${shouldUseLua}
    ...                                                 TxtConfig Init      nbUe=${nbUe}
    ...                                                                     nbSaUe=${nbSaUe}
    ...                                                                     list_of_UE_tobe_created=${list_of_UE_tobe_created}
    ...                                         ELSE    set variable        ${EMPTY}
    Run Keyword If                  ${shouldUseLua}     UpdateUEsId         nbUe=${nbUe}
    ...                                                                     nbSaUe=${nbSaUe}
    Run Keyword If                  ${shouldUseLua}
    ...                                 Run Keywords    Dated Log           After Lua creation, FIRST_SA_UE_ID = ${FIRST_SA_UE_ID}
    ...                                         AND     Dated Log           After Lua creation, FIRST_NSA_UE_ID= ${FIRST_NSA_UE_ID}
    ...                                         AND     Dated Log           Lua Filename is: ${LuaFileName}
    IF              not ${shouldUseLua}
                    Check For SaNsa
    END
    # Configure eDaemon and eGate
    WTS Start processes             telnet_egate_addr=${telnet_egate_addr}
    # Launching configuration
    WTS Configure upon format       shouldUseLua=${shouldUseLua}            luaFile=${LuaFileName}
    # Check SIBs if required
    run keyword if                  not ${isNSA} and not ${bypassSIB}
    ...                                 Run Keywords    Dated Log                       Delay for SIBs is set to ${time_to_wait}
    ...                                         AND     wait until keyword succeeds     ${time_to_wait}     10s
    ...                                                     Check SIB MultiCell         nbCell=${cell_nr}   cellList=${cellList}
    # launch cell setup check except for NSA topo, will be done after X2 setup
    run keyword if                  not ${isNSA} and ${bypassX2Setup}
    ...                             UE Cell Setup Check                     nbCell=${cell_nr}   cellList=${cellList}
    # This backup command was previously launched at the end of the KW. Then it was not systematically estimated.
    Run Keyword If                  "${shouldSaveBasicCfg}"=="${True}"      UteTools.Save Used Basic File
    # Save the file pointed by the following link: egate_console.log
    OsTool.saveFileWithDateFilePattern
    ...                             pathname=${tl.core.dir_path}
    ...                             fileName=egate_console.log
    ...                             logpath=${LOG_PATH}
    ...                             pattern=AfterWtsSetup

    return from keyword if          ${bypassX2Setup}
    # Establish X2 Link, reset reconfigure and retry in case of failure
    ${status}                       Run keyword and return status
    ...                             WTS Set X2 Link                         nbCell=${cell_nr}     cellList=${cellList}
    Run keyword if                  ${status}==${False}
    ...                             Run keywords
    ...                                 wtsemu.Reset_Wtsemu_Cfg
    ...     AND                         WTS Configure upon format
    ...                                     shouldUseLua=${shouldUseLua}
    ...                                     luaFile=${LuaFileName}
    ...     AND                         WTS Set X2 Link                     nbCell=${cell_nr}     cellList=${cellList}
    # Save the file pointed by the following link: egate_console.log
    OsTool.saveFileWithDateFilePattern
    ...                             pathname=${tl.core.dir_path}
    ...                             fileName=egate_console.log
    ...                             logpath=${LOG_PATH}
    ...                             pattern=AfterWtsSetupAndX2LinkSetup

Setup Wtsemu SA
    [Documentation]                WTSEmu Setup for SA call. This is a call to keyword 'WTS Setup':
    ...                            | WTS Setup
    ...                            | ...   telnet_egate_addr=${tl.core.default_ssh_connection_details.addr}
    ...                            | ...   nbUe=1
    ...                            | ...   nbSaUe=${nbSaUe}
    ...                            | ...   shouldUseLua=${shouldUseLua}
    ...                            | ...   bypassX2Setup=${True}
    ...                            | ...   bypassSIB=${False}
    ...                            | ...   nbCell=${nbCell}
    ...                            See keyword 'WTS Setup' for more details.
    ...
    ...                            *Argument details:*
    ...                            - *nbSaUe*: number of SA UE to use (default value = 1, should be >= 1)
    ...                            - *nbCell*: number of cell to check for SystemInformationBlock-NR (default value= 0 dynamically retrieved)
    ...                            - *shouldUseLua*: flag to choose between cfg or lua basic-setup file (default value = False)
    ...                            - *list_of_UE_tobe_created*: list of UEs structure to be created when using lua (default value = None)
    ...                                 mandatory params: ue & target_cells &{my_UE_SA}     ue=1    target_cells=2
    ...                            - *time_to_wait*: time to wait the SIB (default value = 5min)

    [Arguments]        ${nbUe}=1    ${nbCell}=0    ${cellList}=${None}    ${nbSaUe}=1
    ...                ${shouldUseLua}=${False}    ${list_of_UE_tobe_created}=${None}
    ...                ${shouldSaveBasicCfg}=${False}       ${time_to_wait}=5min
    CallSetup.WTS Setup         nbUe=${nbUe}    nbSaUe=${nbSaUe}    nbCell=${nbCell}   cellList=${cellList}    bypassX2Setup=${True}
    ...                         shouldUseLua=${shouldUseLua}    list_of_UE_tobe_created=${list_of_UE_tobe_created}   time_to_wait=${time_to_wait}
    Run Keyword If              "${shouldSaveBasicCfg}"=="${True}"
    ...                         UteTools.Save Used Basic File

Empty Buffer For Egate
    [Documentation]                 TOTALLY NOT RECOMMENDED BECAUSE DEPRECATED - PLEASE USE "Flush Egate Console Buffer" keyword
    ...                             to flush egate buffer (need to send 4096 bytes until "sim_log set flush" command implemented in taf)
    [Arguments]         ${max_loop}=5
    FOR    ${i}    IN RANGE    0    ${max_loop}
        wtsemu.sim_state_disp
    END


Flush Egate Console Buffer
    [Documentation]                 Allow to flush egate buffer into egate_console.log file:
    ...                             | Flush Egate Console Buffer
    ...                             | ... time_to_wait=1s
    ...
    ...                            *Argument details:*
    ...                            - *time_to_wait*: (optional)(default value=1s) sleep duration to be sure egate_console.log file is well updated
    [Arguments]                     ${time_to_wait}=1s
    ute_wtssim.setup_egate          egate_port=${tl.core.egate_port}
    ...                             host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                             tool_dir=${tl.core.dir_path}
    ...                             ssh_user=ute
    ...                             ssh_pass=ute
    ...                             alias=egate
    ute_wtssim.execute_egate_command
    ...                             cmd=sim_log_set flush
    ...                             timeout=5s
    ...                             alias=egate
    ute_wtssim.teardown_egate       alias=egate
    sleep                           ${time_to_wait}

Get Current Gnb Alarms
    [Documentation]                 INTERNAL USAGE
    ...                             Get current GNB alarms and save them in the file provided as parameter
    [Arguments]                     ${output_file}=${None}
    @{alarms}                       OAM Get Active Alarms                   oam=${GNB_DU.oam}
    ${i}                            Set variable                            ${0}
    FOR  ${alarm}       IN          @{alarms}
        ${i}                        evaluate                                ${i}+${1}
        Dated log                   \tGNB_DU_OAM_ALARM[${i}]=${alarm}
        # Store in log file
        Run Keyword If              "${output_file}"!="${None}"
        ...                         Append To File                          ${LOG_PATH}/${output_file}
        ...                                                                 GNB_DU_OAM_ALARM[${i}]=${alarm}\n
    END


Display Cells Status
    [Documentation]      INTERNAL USAGE
    ...                  Display cells status for classical test lines
    [Arguments]        ${cellsInfo}
    FOR    ${c}    IN    @{cellsInfo}
         Dated Log       Cell ${c['physicalCellId']} status = ${c['status']}
    END


Display Aic Cells Status
   [Documentation]      INTERNAL USAGE
   ...                  Display cells status for AIC test lines
    [Arguments]        ${cellsInfo}
    FOR    ${c}    IN    @{cellsInfo}
        ${status}      Catenate        SEPARATOR=
        ...                             {administrative_state: ${c['administrative_state']}, operational_state: ${c['operational_state']},
        ...                             availability_status: ${c['availability_status']}, procedural_status: ${c['procedural_status']}}
        Dated Log      Cell ${c['id']} status = ${status}
    END


# ADT - replace "get_cells_info" by "OAM Get Cells Nr"
Get Cells Status
    [Documentation]                 INTERNAL USAGE
    ...                             Display the test line cells status
    Dated Log                       Displaying cells status
    ${cellsNr}                      OAM Get Cells Nr    ${GNB_DU.oam}
    IF                      ${isAic}
                                    Display Aic Cells Status    ${cellsNr}
    ELSE
                                    Display Cells Status    ${cellsNr}
    END

Check SIB MultiCell
    [Documentation]                 Check SIB-NR messages on egate console according to number of cells.
    ...                             *Argument details:*
    ...                             - *nbCell*: number of cells to check for SystemInformationBlock-NR (default value = 1)
    ...                             - *cellList*: list of cells ID to be used for checking (this parameter and "nbCell" parameters are
    ...                                           mutually excluded and this one has higher priority in case both parameters are provided)
    [Arguments]                     ${nbCell}=1
    ...                             ${cellList}=${None}
    Dated log                       Wait for SIBs - nbCell=${nbCell} - cellList=${cellList}
    Run Keyword If                  ${cellList} != ${None}
    ...                             Check SIB Using Cell List            cellList=${cellList}
    ...       ELSE                  Check SIB Using Cell Number          nbCell=${nbCell}

Check SIB Using Cell List
    [Documentation]                 Check SIB-NR messages on egate console according to the list of cells.
    ...                             *Argument details:*
    ...                             - *cellList*: list of cells ID to be used for checking
    [Arguments]                     ${cellList}=${None}
    # get the list of cells OK from egate_console.log
    Flush Egate Console Buffer
    ${command}    Catenate
    ...           grep 'SystemInformationBlockType1-NR updated' ${tl.core.dir_path}/egate_console.log | sort -u | paste -sd, -
    ${cellListOk}                   run                             ${command}
    Dated Log                       cellListOk=[${cellListOk}]
    # check if the cells provided in cellList are all OK
    ${cellKo}                       Set Variable      ${False}
    ${uniqueCellListOk}    Evaluate    re.findall(r'cell (\\d+):', '''${cellListOk}''')    modules=re
    Dated Log                       uniqueCellListOk=[${uniqueCellListOk}]
    ${uniqueCellListOk}    Evaluate    list(set(${uniqueCellListOk}))
    Dated Log                       uniqueCellListOk=[${uniqueCellListOk}]
    FOR    ${cell}    IN   @{cellList}
        ${found}    Evaluate    str(${cell}) in ${uniqueCellListOk}
        ${cellKo}    Set Variable If    not ${found}    ${True}    ${cellKo}
        Run Keyword if    not ${found}    Dated Log     ERROR: cell number ${cell} was not up
    END
    should be true    ${cellKo} == ${False}
    # get the alarm list in case of error
    Run Keyword If                  ${cellKo} == ${True}    Run Keywords
    ...                             Get Current Gnb Alarms          output_file=${SIB_ALARMS_FILE}
    ...   AND                       Get Cells Status
    should be true                  ${cellKo} == ${False}

Check SIB Using Cell Number
    [Documentation]                 Check SIB-NR messages on egate console according to number of cells.
    ...                             *Argument details:*
    ...                             - *nbCell*: number of cell to check for SystemInformationBlock-NR (default value = 1)
    [Arguments]                     ${nbCell}=1
    Flush Egate Console Buffer
    ${check_sibs}                   SSH Wait For Connect and Cmd
    ...                             command=grep 'SystemInformationBlockType1-NR updated' ${tl.core.dir_path}/egate_console.log|sort -u|wc -l
    ...                             host=${HOST_EPCSIM}
    ${check_sibs}                   Set variable                    ${check_sibs.replace("\n","").replace("\r","")}
    Dated Log New Line              Number of detected SIB: ${check_sibs}
    # get the alarm list in case of error
    Run Keyword If                  ${check_sibs.strip()} < ${nbcell}    Run Keywords
    ...                             Get Current Gnb Alarms          output_file=${SIB_ALARMS_FILE}
    ...   AND                       Get Cells Status
    # display the Cell Ids where SIB is successful
    ${command}                      Catenate
    ...                             grep -i 'SystemInformationBlockType1-NR updated' ${tl.core.dir_path}/egate_console.log |
    ...                             awk -F " " '{print echo "SIB " $7 $8 echo " well done"}'
    ${sib_result}                   run                             ${command}
    ${sib_result}                   Set variable                    ${sib_result.replace("\n"," ; ").replace("\r"," ; ")}
    Dated Log                       sib status: ${sib_result}
    # the number of cells activated must be equal or bigger than the number of expected cells
    should be true                  ${check_sibs.strip()} >= ${nbcell}

WTS Clear
    [Documentation]                 Stop WTSEmu, kill eDaemon and eGate processes, and purge WTS logs.
    ...
    ...                             *Argument details:*
    ...                             - host: vm ip address (default value = ${HOST_EPCSIM})
    [Arguments]                     ${host}=${HOST_EPCSIM}
    SSH Wait For Connect            ${host}
    wtsemu.kill_wtsemu_edaemon      edaemon_port=${tl.core.edaemon_port}
    ...                             connection=${host.alias}
    wtsemu.kill_wtsemu_egate        egate_port=${tl.core.egate_port}
    ...                             connection=${host.alias}
    Sleep                           1s
    SSH Cmd                         cd ${tl.core.dir_path}; rm -f *log*     alias=${host.alias}

WTS Kill All eGate
    [Documentation]                 List then Kill all eGate processes.
    OperatingSystem.Run             ps -edf | grep egate
    OperatingSystem.Run             ps -edf | grep edaemon
    Sleep                           1s
    OperatingSystem.Run             sudo pkill -9 egate
    OperatingSystem.Run             sudo pkill -9 edaemon
    Sleep                           1s

WTS Start processes
    [Documentation]                 Start eDaemon and eGate, Establish an eGate connexion
    ...                             and remove configure of WTSEmu eGate controller.
    ...
    ...                             *Argument details:*
    ...                             - alias: VM connection alias (default value = dynamically retrieved)
    ...                             - telnet_egate_addr: VM eGate address (default value = dynamically retrieved)
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    ...                             ${telnet_egate_addr}=${tl.core.default_ssh_connection_details.addr}
    # The following code is added to take into account that sometimes, the eGate is still running.
    # In these cases, when eGate is still running, this blocks the new session.
    # A solution is: connect to the eGate and launch the "reset" then "exit" commands.
    Dated log                       Starting WTS clean-Up
    wtsemu.Configure Wtsemu Edaemon  edaemon_ssh_alias=${alias}             directory_path=${tl.core.dir_path}    port=${tl.core.edaemon_port}
    wtsemu.Configure Wtsemu Egate    egate_ssh_alias=${alias}               directory_path=${tl.core.dir_path}    port=${tl.core.egate_port}
    # Launch telnet command
    Dated Log                       \tConnecting to: ${telnet_egate_addr}, Port: ${tl.core.egate_port}
    sleep                           3s
    wtsemu.Start Wtsemu             egate_console_ip=${telnet_egate_addr}
    ...                             egate_port=${tl.core.egate_port}
    sleep                           5s
    Dated Log                       \tResetting WTS configuration - Done via "script" KW
    robot_extension.Run Keyword And Warn On Failure                         wtsemu.script       file=${CURDIR}/WtsEmuReset.sce
    robot_extension.Run Keyword And Warn On Failure                         wtsemu.script_status
    robot_extension.Run Keyword And Warn On Failure                         wtsemu.script_stop
    sleep                           3s

    # Start eDaemon and eGate
    Dated log                       Starting WTS processes
    wtsemu.Configure Wtsemu Edaemon  edaemon_ssh_alias=${alias}             directory_path=${tl.core.dir_path}    port=${tl.core.edaemon_port}
    wtsemu.Configure Wtsemu Egate    egate_ssh_alias=${alias}               directory_path=${tl.core.dir_path}    port=${tl.core.egate_port}
    # Launch telnet command
    Dated Log                       \tConnecting to: ${telnet_egate_addr}, Port: ${tl.core.egate_port}
    sleep                           3s
    wtsemu.Start Wtsemu             egate_console_ip=${telnet_egate_addr}
    ...                             egate_port=${tl.core.egate_port}
    sleep                           5s
    Dated Log                       \tResetting WTS configuration - Done via "reset_wtsemu_cfg" KW
    wtsemu.Reset_Wtsemu_Cfg

#===================================
# AEP Airphone Early Pet corner
#===================================
# Flush Egate Console Buffer mwts
#     [Documentation]                 Allow to flush egate buffer into egate_console.log file:
#     ...                             | Flush Egate Console Buffer
#     ...                             | ... time_to_wait=1s
#     ...
#     ...                            *Argument details:*
#     ...                            - *time_to_wait*: (optional)(default value=1s) sleep duration to be sure egate_console.log file is well updated
#     [Arguments]                     ${time_to_wait}=1s
#     ...                             ${tlcoreX}=${tl.core.default_ssh_connection_details.addr}
#     ${dir_path}=                    ReadConfig.get_test_pctmp_attribute    ${tlcoreX}    dir_path
#     # ${telnet_egate_addr}=           ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}    default_ssh_connection_details.addr
#     ${telnet_egate_addr}=           Set Variable                           ${tlcoreX.default_ssh_connection_details.addr}
#     Dated Log                       >>>>Flush Egate Console Buffer mwts - telnet_egate_addr=${telnet_egate_addr}
#     ${edaemon_port}=                ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}    edaemon_port
#     ${egate_port}=                  ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}    egate_port
#     ute_wtssim.setup_egate          egate_port=${egate_port}
#     ...                             host_ip=${telnet_egate_addr}
#     ...                             tool_dir=${dir_path}
#     ...                             ssh_user=ute
#     ...                             ssh_pass=ute
#     ...                             alias=egate
#     ute_wtssim.execute_egate_command
#     ...                             cmd=sim_log_set flush
#     ...                             timeout=5s
#     ...                             alias=egate
#     ute_wtssim.teardown_egate       alias=egate
#     sleep                           ${time_to_wait}

WTS Clear mwts
    [Documentation]                 Stop WTSEmu, kill eDaemon and eGate processes, and purge WTS logs.
    ...                             This is a specific version for MWTS (Multi WTS -Wireless Test System-) entities.
    ...
    ...                             *Argument details:*
    ...                             - host: vm ip address (default value = ${HOST_EPCSIM})
    [Arguments]                     ${idx}=1    ${host}=${HOST_EPCSIM}

    SSH Wait For Connect            ${host}
    ${wtsemuinstance}               Set Variable    wtsemu_${idx + 1}
    Run Keyword    ${wtsemuinstance}.kill_wtsemu_edaemon      edaemon_port=${tl.core[${idx}].edaemon_port}
    ...                                        connection=${host.alias}
    Run Keyword    ${wtsemuinstance}.kill_wtsemu_egate        egate_port=${tl.core[${idx}].egate_port}
    ...                                        connection=${host.alias}
    Sleep                           1s
    SSH Cmd                         cd ${tl.core[${idx}].dir_path}; rm -f *log*     alias=${host.alias}

WTS Start processes mwts
    [Documentation]                 Start eDaemon and eGate, Establish an eGate connexion
    ...                             and remove configure of WTSEmu eGate controller.
    ...
    ...                             *Argument details:*
    ...                             - alias: VM connection alias (default value = dynamically retrieved)
    ...                             - telnet_egate_addr: VM eGate address (default value = dynamically retrieved)
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    ...                             ${tlcoreX}=${tl.core.default_ssh_connection_details.addr}
    ...                             ${wtsemuinstance}=wtsemu
    Dated Log                       WTS Start processes mwts arg alias:${alias} tlcoreX=>${tlcoreX} wtsemuinstance=${wtsemuinstance}

    # Retrieve the attributes from the tlcoreX
    ${dir_path}=                    ReadConfig.get_test_pctmp_attribute    ${tlcoreX}        dir_path
    ${telnet_egate_addr}=           Set Variable    ${tlcoreX.default_ssh_connection_details.addr}
    ${edaemon_port}=                ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}        edaemon_port
    ${egate_port}=                  ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}        egate_port

    Debug Dated Log                 Starting WTS clean-Up
    Debug Dated Log                 telnet_egate_addr=${telnet_egate_addr}
    Debug Dated Log                 dir_path=${dir_path}
    Debug Dated Log                 edaemon_port=${edaemon_port}
    Debug Dated Log                 egate_port=${egate_port}

    # The following code is added to take into account that sometimes, the eGate is still running.
    # In these cases, when eGate is still running, this blocks the new session.
    # A solution is: connect to the eGate and launch the "reset" then "exit" commands.

    Run Keyword    ${wtsemuinstance}.Configure Wtsemu Edaemon  edaemon_ssh_alias=${alias}    directory_path=${dir_path}    port=${edaemon_port}
    Run Keyword    ${wtsemuinstance}.Configure Wtsemu Egate    egate_ssh_alias=${alias}      directory_path=${dir_path}    port=${egate_port}
    # Launch telnet command
    Dated Log                       \tConnecting to: ${telnet_egate_addr}, Port: ${egate_port}
    sleep                           10s
    Run Keyword    ${wtsemuinstance}.Start Wtsemu             egate_console_ip=${telnet_egate_addr}
    ...                             egate_port=${egate_port}
    ...                             egate_timeout=10
    sleep                           10s
    Dated Log                       \tResetting WTS configuration - Done via "script" KW
    robot_extension.Run Keyword And Warn On Failure                         Run Keyword    ${wtsemuinstance}.script
    ...                                                                                                      file=${dir_path}/WtsEmuReset.sce
    robot_extension.Run Keyword And Warn On Failure                         Run Keyword    ${wtsemuinstance}.script_status
    robot_extension.Run Keyword And Warn On Failure                         Run Keyword    ${wtsemuinstance}.script_stop
    sleep                           10s

    # Start eDaemon and eGate
    Dated log                        Starting WTS processes on VM ${telnet_egate_addr}
    Run Keyword    ${wtsemuinstance}.Configure Wtsemu Edaemon  edaemon_ssh_alias=${alias}    directory_path=${tlcoreX.dir_path}
    ...                                                        port=${tlcoreX.edaemon_port}
    Run Keyword    ${wtsemuinstance}.Configure Wtsemu Egate    egate_ssh_alias=${alias}      directory_path=${tlcoreX.dir_path}
    ...                                                        port=${tlcoreX.egate_port}
    # Launch telnet command
    Dated Log                       \tConnecting to: ${telnet_egate_addr}, Port: ${tlcoreX.egate_port}
    sleep                           10s
    Run Keyword    ${wtsemuinstance}.Start Wtsemu             egate_console_ip=${telnet_egate_addr}
    ...                                                       egate_port=${tlcoreX.egate_port}
    ...                                                       egate_timeout=10
    sleep                           10s
    Dated Log                       \tResetting WTS configuration - Done via "reset_wtsemu_cfg" KW
    Run Keyword    ${wtsemuinstance}.Reset_Wtsemu_Cfg



#======== end AEP corner ===========
WTS Configure upon format
    [Documentation]                 Configure WTSEmu by using a configuration file .cfg or .lua basic-setup file by using a command in eGate console
    ...                             and wait for the simulator to be ready.
    ...
    ...                             *Argument details:*
    ...                             - *shouldUseLua*: To use .lua file (default value = True)
    ...                             - *luaFile*: basic-setup lua file to use (value generated during execution of keyword 'WTS Setup')
    [Arguments]                     ${shouldUseLua}=${True}
    ...                             ${luaFile}=${EMPTY}
    Run Keyword if                  ${shouldUseLua}
    ...                             WTS Configure                           ConfigFileName=${luaFile}
    ...   ELSE                      WTS Configure                           ConfigFileName=${tl.core.cfg_filename}

WTS Configure
    [Documentation]                 INTERNAL USAGE
    ...                             Set configuration for WTS from file as pointed in __init__.py.
    [Arguments]                     ${ConfigFileName}=${tl.core.cfg_filename}
    ...                             ${pass_regexp}=CHANGE STATE: ACTIVE - SimMode is ready now
    Dated Log                       \tConfiguring WtsEmu with ${tl.core.dir_path}/${ConfigFileName}
    wtsemu.Configure                file=${tl.core.dir_path}/${ConfigFileName}
    # Flush the buffer to be sure to have all egate console log
    Flush Egate Console Buffer
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=${pass_regexp}
    ...                             timeout=300
    sleep                           30s

WTS Set Backhaul IP
    [Documentation]                 INTERNAL USAGE
    ...                             Retrieve "dynamic" IP@ of UPUE backhaul, then update configuration file on WTS consequently.
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    ${vmUPUE}                       call method                             ${GNB_CU.oam}
    ...                             getVM                                   UPUE
    ${output}                       SSH Wait For Connect and Cmd
    ...                             command=sudo ip addr show backhaul | grep -Po 'inet \\K[\\d.]+'
    ...                             host=${vmUPUE}
    ${ip}                           Strip String                            ${output}
    Should Not Be Empty             ${ip}
    Dated log                       \tgNB UPUE backhaul IP: ${ip}
    ${file}                         set variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    SSH Cmd                         command= sudo sed -i 's/set ENB2_S1_ADDR=.*/set ENB2_S1_ADDR="${ip}"/g' ${file}
    ...                             alias=${alias}
    SSH Cmd                         sudo fuser -k 2152/udp                  alias=${alias}

WTS Set X2 Link
    [Documentation]                 Establish on WTSEmu the X2 link between eNB and gNB.
    ...
    ...                             Wait for cell cetup for each cell by using keyword 'UE Cell Setup Check'.
    ...
    ...                             See keyword 'UE Cell Setup Check' for more details.
    ...
    ...                             *Argument details:*
    ...                             - alias: vm connection alias (default value = dynamically retrieved)
    [Arguments]                     ${nbCell}=0
    ...                             ${cellList}=${None}
    wtsemu.Enb X2 Link Up           enb=${ENB_ID}                               target=${GNB_ID}
    sleep                           3s
    IF              not ${isAic}
                    wtsemu.Read Wtsemu Output Until Re
                    ...     expected=ENB-${ENB_ID}: X2AP Link with [EG]NB-${GNB_ID} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
                    ...     timeout=500
    END
    UE Cell Setup Check             nbCell=${nbCell}                         cellList=${cellList}

#===================================
# GNB Attach to ENB
#===================================
SgNB Addition to ENB
    [Documentation]          Attach a NSA UE via eNB by using keyword 'UE Attach Enb' (for more details see keyword 'UE Attach Enb').
    ...
    ...                      Then trig the SgNB Addition procedure by using keyword 'UE Attach Gnb' (for more details see keyword 'UE Attach Gnb').
    ...
    ...                      A SCTP capture is also started during the SgNB addition.
    ...
    ...                      Also, another capture (for instance, for BIP messages) may be performed on demand:
    ...                      meaning if a <captureCallback> and its asociated <capture> structure is provided through arguments.
    ...
    ...                      Return path of trace capture file.
    ...
    ...                      *Argument details:*
    ...                      - *ueSetting*:        Reference to UE Settings  (default value = UE_NO_PROFILE)
    ...                      - *captureCallback*:  Reference to a KW call back or None  (default value = None)
    ...                      - *capture*:          Associated <Capture> structure if Callback is provided  (default value = None)
    ...                      - *expected_gnb_log*: Msg to validate enb_ue_dc_start (default value = reported successful RA)
    ...                      - *withTN*:           If set to True, Test Name will be part of the pcap file (default value = False)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${captureCallback}=None
    ...                             ${capture}=None
    ...                             ${expected_gnb_log}=reported successful RA
    ...                             ${withTN}=${False}
    Dated Log New Line              Starting GNB attach to ENB
    ${captureCORE}                  Capture CORE Set Upon Config
    Capture Init                    ${captureCORE}
    ...                                 withTN=${WithTN}
    ...                                 suffix=_GNB_ADDITION_UE${ueSetting.ue}
    Capture Start                   ${captureCORE}
    UE Attach Enb                   ueSetting=${ueSetting}
    Traced Sleep                    duration=5s                    msg=Workaround for pb Attach Gnb
    UE Attach Gnb                   ueSetting=${ueSetting}
    ...                             captureCallback=${captureCallback}
    ...                             capture=${capture}
    ...                             expected_gnb_log=${expected_gnb_log}
    Capture Stop                    ${captureCORE}
    [Teardown]                      Run keyword if                          '${KEYWORD_STATUS}'!='PASS'
    ...                             Capture Stop                            ${captureCORE}
    [Return]                        ${captureCORE.path}

UE Attach Enb
    [Documentation]                 Attach specified NSA UE (signaling on eNB).
    ...
    ...                             Wait for '4G Attach is successful' message to appear on eGate console.
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:       Reference to UE Settings structure  (default value = UE_NO_PROFILE)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    wtsemu.Ue Attach                id=${ueSetting.ue}
    wtsemu.Read Wtsemu Output Until Re  expected=UE IS ACTIVE               timeout=10
    Dated Log                       4G Attach is successful (UE=${ueSetting.ue} Profile=${ueSetting.profile})

UE Attach Gnb
    [Documentation]           Launch enb_ue_dc_start commande in eGate console to trig SgNB Addition procedure for NSA UE.
    ...
    ...                       Wait for message "sgNb Addition procedure is completed successfully" to appear on eGate console.
    ...
    ...                       The capture of BIP traces in gNB are started before the procedure triggering and stopped 2.2 seconds later.
    ...
    ...                       Get the CRNTI info from egate console log then set the CRNTI info into ueSetting dictionary.
    ...
    ...                       *Argument details:*
    ...                       - *ueSetting*:        Reference to UE Settings structure  (default value = UE_NO_PROFILE)
    ...                       - *captureCallback*:  Reference to a KW call back or None (default value = None)
    ...                       - *capture*:          Associated <Capture> structure if Callback is provided (default value = None)
    ...                       - *expected_gnb_log*: Msg to validate enb_ue_dc_start (default value = reported successful RA)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${expected_gnb_log}=reported successful RA
    # Start tcpdump on BIP if required
    Callback Start Capture          callback=${captureCallback}             capture=${capture}
    sleep                           400 ms
    # Launch Enb Start
    wtsemu.enb_ue_dc_start          ue=${ueSetting.ue}
    ...                             target_gnb=${ueSetting.target_gnb}
    ...                             target_cells=${ueSetting.target_cells}
    ...                             bearer=${ueSetting.bearer}
    ...                             type=split_scg
    # Force testModeValue to csi_report_override if not already defined
    ${IsKeyExist}                   Is Key Exist
    ...                             ${ueSetting}                            testModeValue
    ${ueSetting.testModeValue}      set variable if                         ${IsKeyExist}
    ...                             ${ueSetting.testModeValue}              csi_report_override
    run keyword if                  ${ueSetting.testMode}                   wtsemu.ue testmode set
    ...                             id=${ueSetting.ue}
    ...                             profile_index=${ueSetting.profile}
    ...                             action=activate
    ...                             test_mode=${ueSetting.testModeValue}
    sleep                           1800 ms
    # Stop BIP capture (if required)
    Callback Stop Capture           callback=${captureCallback}              capture=${capture}
    # Check console result
    Dated Log                       Checking sgNb Addition procedure...${expected_gnb_log}
    # Flush the buffer to be sure to have all egate console log
    Flush Egate Console Buffer
    wtsemu.Read Wtsemu Output Until  expected=${expected_gnb_log}            timeout=30
    # Get the CRNTI info from egate console log:
    ${value}                        Read NSA CRNTI From Egate log
    # Set the CRNTI info into ueSetting dictionary:
    set to dictionary               ${ueSetting}                             c_rnti=${value}
    Dated Log                       sgNb Addition procedure is completed successfully and CRNTI is: ${ueSetting.c_rnti}
    Sleep                           5

UE Detach Enb
    [Documentation]                 Detach specified NSA UE (signaling on eNB).
    ...
    ...                             Wait for detach message to appear on eGate console.
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:        Reference to UE Settings structure (default value = UE_NO_PROFILE)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    Dated log                       UE detach: UE ${ueSetting.ue}
    wtsemu.Ue Detach                id=${ueSetting.ue}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=UE${ueSetting.ue}: detached
    ...                             timeout=10

UE Attach Detach
    # Keyword deprecated            TO BE REMOVED
    [Documentation]                 INTERNAL USAGE. Attempt a re-attach then a detach on GNB.
    ...                             *Argument details:*
    ...                             - *ueSetting*:        Reference to UE Settings structure  (default: UE_NO_PROFILE)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    UE Attach Enb                   ueSetting=${ueSetting}
    sleep                           30s
    UE Attach Gnb                   ueSetting=${ueSetting}
    sleep                           20s
    UE Detach Enb                   ueSetting=${ueSetting}

UE Attach Check
    [Documentation]                 This KW is now deprecated.
    ...
    ...                             Check in Ue attach successful. This keyword is only supported in mono UE.
    #...                             previously : Verify AP Classical UE attach
    Dated Log                       Checking Ue attach is now part of attach procedure.This KW is now deprecated

UE Cell Setup Check
    [Documentation]                 Check in Airphone that cell setup is OK for each cell by the presence of
    ...                             message 'Cell Setup completed for' in egate log file (/opt/iphy/latest/egate_console.log).
    [Arguments]                     ${nbCell}=0
    ...                             ${cellList}=${None}
    Dated Log                       Checking Ue Cell Setup
    # cellList, if provided, has higher priority than nbCell
    Run Keyword If                  ${cellList}!=${None}
    ...                             Run Keywords
    ...                                     Dated Log   ===> List of Cells configured = ${cellList}
    ...                             AND     Wait until keyword succeeds     6min   10s
    ...                                         Check Cell Setup Using Cell List    cellList=${cellList}
    ...       ELSE                  Run Keywords
    ...                                     Dated Log   \t===> Number of expected cell setup completed= ${nbCell}
    ...                             AND     Wait until keyword succeeds     6min   10s
    ...                                         Grep and check is equal to cell number
    ...                                             host=${HOST_EPCSIM}
    ...                                             file=${tl.core.dir_path}/egate_console.log
    ...                                             pattern='Cell Setup completed for \\[CELL_ID:'
    ...                                             nbCell=${nbCell}
    ...                                             cell_nr_global=${cell_nr}

Check Cell Setup Using Cell List
    [Documentation]                 Check "Cell Setup Completed" messages in egate console log according to the cell list.
    ...                             *Argument details:*
    ...                             - *cellList*: list of cells ID to be used for checking
    [Arguments]                     ${cellList}=${None}
    # Flush the buffer to be sure to have all egate console log
    Flush Egate Console Buffer
    # get the list of cells OK from egate_console.log
    ${command}                      Catenate
    ...                             grep 'Cell Setup completed for \\[CELL_ID:' ${tl.core.dir_path}/egate_console.log | sort -u |
    ...                             sed -E 's/.*Cell Setup.*\\[CELL_ID:(.*)\\]/\\1/'
    ${cellListOk}                   run                             ${command}
    Dated Log                       cellListOk=[${cellListOk}]
    # check if the cells provided in cellList are all OK
    ${cellKo}                       Set Variable      ${False}
    FOR    ${cell}    IN   @{cellList}
        ${cellOk}                   run     echo "${cellListOk}" | grep -w ${cell}
        ${cellKo}                   Set Variable If                 '${cellOk}' == ''    ${True}    ${cellKo}
        Run Keyword if              '${cellOk}' == ''               Dated Log     ERROR: cell number ${cell} was not up
    END
    should be true                  ${cellKo} == ${False}

Grep and check in file
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${host}                                 ${file}
    ...                             ${grep}                                 ${pattern}
    Dated log                       Check on ${host.alias}:file ${file} contain pattern [${pattern}]
    ${alias}                        SSH Connect                             ${host}
    ${output}                       SSH Cmd
    ...                                 grep ${grep} ${file}
    ...                                 alias=${alias}
    should contain                  ${output}                               ${pattern}

Grep and check is equal to cell number
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${host}                                 ${file}
    ...                             ${pattern}
    ...                             ${nbCell}=0
    ...                             ${cell_nr}=${None}
    ...                             ${cell_nr_global}=${None}
    # Flush the buffer to be sure to have all egate console log
    Flush Egate Console Buffer
    Dated log                       Check on ${host.alias}:file ${file} contain pattern [${pattern}]
    ${alias}                        SSH Connect                             ${host}

    # on AIC FDD conf, lines are duplicated --> need to keep only 1 line per cell --> add "sort -u"
    ${output}                       SSH Cmd
    ...                                 grep ${pattern} ${file} | sort -u | wc -l
    ...                                 alias=${alias}

    # if nbCell is not provided (0) then use the passed cell_nr parameter as fallback, otherwise use nbCell
    IF    ${nbCell}==0
        # Prioritize explicit cell_nr parameter, then global suite variable, then cell_nr_global
        IF    ${cell_nr}!=${None}
            ${nb_of_cell}           Set Variable    ${cell_nr}
        ELSE IF    ${cell_nr_global}!=${None}
            ${nb_of_cell}           Set Variable    ${cell_nr_global}
        ELSE
            # Last resort: 0 (will cause assertion if cells found)
            ${nb_of_cell}           Set Variable    0
        END
    ELSE
        ${nb_of_cell}               Set Variable    ${nbCell}
    END
    Dated Log                       Expected number of cells: ${nb_of_cell}, Found: ${output.strip()}

    Should Be Equal As Numbers      ${output.strip()}                       ${nb_of_cell}

Check For SaNsa
    [Documentation]                 INTERNAL USAGE
    ${UE_SIMPLE.ue}                 set variable if    ${isSANSA}    ${FIRST_NSA_UE_ID}    1
    ${UE_SIMPLE_TEST_MODE.ue}       set variable if    ${isSANSA}    ${FIRST_NSA_UE_ID}    1
    ${UE_NO_PROFILE.ue}             set variable if    ${isSANSA}    ${FIRST_NSA_UE_ID}    1

WTS Set XpAP and X2 Link
    [Documentation]                 DSS Establishment on WTSEmu by up the XpAP and X2AP interface between eNB and gNB.
    ...
    ...                             The checking of XpAP up interface is done by the presence of the message 'XpAP Link with ... is up'
    ...                             on the eGate console.
    ...
    ...                             The checking of X2AP up interface is done by the presence of the message 'X2AP Link with ... is up'
    ...                             on the eGate console.
    ...
    ...                             *Argument details:*
    ...                             - *id*:        id to use (default value = 1)
    ...                             - *targetGnb*: targetGnb to use (default value = 2)
    [Arguments]                     ${id}=1    ${targetGnb}=2
    Dated log                       Establishing XP link between eNB and gNB
    wtsemu.enb_xp_param             id=${id}    ignore_xp=off    xp_listening_socket=on
    wtsemu.enb_xp_param             id=${id}    xp_peers=${targetGnb}
    sleep                           3s
    wtsemu.enb_xp_link_up           enb=${id}       target=${targetGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=ENB-${ENB_ID}: XpAP Link with [EG]NB-${targetGnb} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
    ...                             timeout=120
    wtsemu.enb_x2_link_up           enb=${id}       target=${targetGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=ENB-${ENB_ID}: X2AP Link with [EG]NB-${targetGnb} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
    ...                             timeout=60

DSS Partnership Creation
    [Documentation]                 Configure the DSS partnership between eNB/gNB on terget cell.
    ...
    ...                             *Argument details:*
    ...                             - *cellIdGnb*: Cell Id gNB (default value = 2)
    [Arguments]                     ${cellIdGnb}=2
    Dated log                       CRM Partnership Creation
    wtsemu.enb_dss_param            id=1     feature_flag=on     message_sets=V1,DMS2
    wtsemu.enb_cell_param           enb=1    id=1    lte_nr_dss_mode=DL_CRS_TDM_UL_FDM
    wtsemu.enb_dss_configure_partnership     enb=1   cell=1      dss_peer=2:${cellIdGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=CRM Partnership Creation
    ...                             timeout=60

DSS Establish Partnership
    [Documentation]                 Establish the DSS partnership by configure CRM resource reservation and resource allocation in UL and DL.
    ...
    ...                             *Argument details:*
    ...                             - *cellIdGnb*: Cell Id Gnb (default value = 2)
    ...                             - *targetGnb*: targetGnb to use (default value = 2)
    [Arguments]                     ${cellIdGnb}=2    ${targetGnb}=2
    ${dans}    set variable         0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
    Dated log                       DSS Establishing Partnership
    wtsemu.enb_crm_cell_resource_reservation     enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          assigned_dl_minimum_share_to_nr=15     assigned_dl_maximum_share_to_nr=70
    ...                                          assigned_dl_minimum_share_to_lte=15    assigned_dl_maximum_share_to_lte=70
    ...                                          assigned_ul_minimum_share_to_nr=20     assigned_ul_maximum_share_to_nr=70
    wtsemu.enb_dss_establish_partnership         enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Cell .*: EN DSS UL Cell Subcarrier Resource Coordination.*\n*.*success on remote NE
    ...                             timeout=60
    wtsemu.enb_crm_param                         id=1          ul_qos_load_meas_timer=200              dl_qos_load_meas_timer=200
    wtsemu.enb_dss_resource_allocation           enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          dir=DL   allocation_start_time=immediate   dl_allocated_normal_subframes=${dans}
    wtsemu.enb_dss_resource_allocation           enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          dir=UL        allocation_start_time=immediate         ul_allocated_prb_list=9,30
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Received EN DSS UL Qos Load Indication Sequence\nNumber=0
    ...                             timeout=60
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Received DSS DL Qos Load Indication SequenceNum\nber=0
    ...                             timeout=60

UE Register
    [Documentation]           Register SA UE (signaling on gNB) and checking by apparition of message 'crnti' on eGate console.
    ...
    ...                       Get and return the SA UE CRNTI info from eGate console log
    ...
    ...                       *Argument details:*
    ...                         - *ue*:         Specified UE ID (default value = 1)
    ...                         - *timeout*:    (default: 30)
    [Arguments]             ${ue}=1             ${timeout}=30
    ...                     ${expected_log}=UE now in NG RM Registered state
    # Flush the buffer to be sure to have all egate console log
    Flush Egate Console Buffer
    wtsemu.ue_register      id=${ue}
    Dated Log               Checking: ${expected_log}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=${expected_log}
    ...                             timeout=${timeout}
    # Now get and return the SA UE CRNTI info from eGate console log:
    ${crnti}                Read SA CRNTI From Egate log        ueId=${ue}
    Dated Log               The CRNTI of UE Id ${ue} is: ${crnti}
    [Return]                ${crnti}

UE Deregister
    [Documentation]                 Deregister a SA UE (signaling on gNB) and checking by apparition of message 'UE Context Release Complete'
    ...                             on eGate console.
    ...
    ...                             *Argument details:*
    ...     - *id*:                 UE ID (default value = 1)
    ...     - *ue_deregister_type*: UE deregister type (default value = switch_off)
    ...     - *by*:                 device initiating the deregister procedure (default value = ue)
    [Arguments]    ${id}=1    ${ue_deregister_type}=switch_off    ${by}=ue
    Dated log                       UE detach: UE ${id}
    wtsemu.ue_deregister            id=${id}    ue_deregister_type=${ue_deregister_type}    by=${by}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=UE Context Release Complete
    ...                             timeout=10

Launch PDU Session
    [Documentation]        Open a PDU session:
    ...                    - Set parameters of session.
    ...                    - Open the PDU session by using the keyword 'UE PDU Session Setup' (for more details see keyword 'UE PDU Session Setup').
    ...
    ...                    *Argument details:*
    ...    - *ue*:      the UE identifier (default value = 1)
    ...    - *pdu*:     the PDU identifier (default value = 1)
    ...    - *gw*:      the gateway identifier (default value = 1)
    ...    - *nwslice*: the network slice identifier (default value = 1)
    [Arguments]             ${ue}=1                  ${pdu}=1
    ...                     ${gw}=1                  ${nwslice}=1
    wtsemu.set_pdu_param    ue=${ue}                 pdu=${pdu}
    ...                     trf_type=internal
    UE PDU Session Setup    ue=${ue}
    ...                     pdu=${pdu}               gw=${gw}
    ...                     nwslice=${nwslice}
    Dated Log               PDU Session setup OK (ue=${ue})

UE PDU Session Setup
    [Documentation]           Open a PDU session.
    ...
    ...                       Check the message 'Initial Context Setup Successful' on eGate console.
    ...
    ...                       Return the IP address assigned to UE.
    ...
    ...                       *Argument details:*
    ...    - *pdu*:        PDU Session ID  (default = 1)
    ...    - *ue*:         Specified UE ID (default = 1)
    ...    - *nwslice*:    Requested Network Slice for the PDU Session  (default = 1)
    ...    - *gw*:         PDU Gateway ID. Specifies gateway to use for this PDU session OPTIONAl --> TBRM  (default = 1)
    ...    - *timeout*:    Timeout for message "Initial Context Setup Successful" (default = 30)
    [Arguments]    ${ue}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${timeout}=30
    wtsemu.ue_pdu_session_setup
    ...               pdu=${pdu}                ue=${ue}
    ...               nwslice=${nwslice}        gw=${gw}
    ${output}         wtsemu.Read Wtsemu Output Until Re
    ...               expected=Initial Context Setup Successful
    ...               timeout=${timeout}
    ${output}         StringTool.getStringFromCmdReturn    ${output}
    ${pattern}=       Catenate                  Allocated PduSessionFsm with PDU session ID:${pdu} .*
    ...               UE IP address:([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})
    ${ue_ip}=         Get Regexp Matches        ${output}
    ...               ${pattern}                1
    [Return]      ${ue_ip[0]}

UE PDU Session Modify
    [Documentation]       Modify the QoSFlow of a PDU session.
    ...
    ...                   *Argument details:*
    ...    - *pdu*:        PDU Session ID  (default = 3)
    ...    - *ue*:         Specified UE ID (default = 3)
    ...    - *qfta*:       value for qosflows_to_add or qosflows_to_del (default = 2)
    ...    - *by*:         by              (default = amf)
    ...    - *toDel*:      if ${False} by default qosflows_to_add is used else qosflows_to_del
    [Arguments]    ${ue}=3    ${pdu}=3    ${qfta}=2    ${by}=amf        ${toDel}=${False}
    Dated Log     Start "UE PDU Session Modify"
    Run Keyword If     '${toDel}'=='${False}'
    ...                             wtsemu.ue_pdu_session_modify    ue=${ue}    pdu=${pdu}    qosflows_to_add=${qfta}    by=${by}
    ...         ELSE                wtsemu.ue_pdu_session_modify    ue=${ue}    pdu=${pdu}    qosflows_to_del=${qfta}    by=${by}
    ${output}                       Run Keyword if               '${toDel}'=='${False}'
    ...                             wtsemu.Read Wtsemu Output Until Re
    ...                             expected=UPF-1: Added QosFlow with QFI:
    ...                             timeout=120
    ...     ELSE                    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Ue ${ue} PduId ${pdu} Removed FiveQi:Qfi
    ...                             timeout=120
    Sleep    1s    reason=Waiting command to be executed

Get UEid upon Topology
    [Documentation]                 INTERNAL USAGE.
    ...                             Return the UE_id values usable in some KW according to used topology.
    ...                             At the moment the value is 11 for SANSA, 1 for others.
    ${UE_id}                        Set Variable If                         ${isSANSA}
    ...                             ${FIRST_NSA_UE_ID}                      1
    [Return]                        ${UE_id}

UpdateUEsId
    [Documentation]                 INTERNAL USAGE.
    [Arguments]                     ${nbUe}=0
    ...                             ${nbSaUe}=0
    ${FIRST_SA_UE_ID}               Run Keyword If              '${nbSaUe}'=='0'
    ...                                                         set variable    0
    ...                                         ELSE            evaluate        ${nbUe}-${nbSaUe}
    ${FIRST_NSA_UE_ID}              evaluate                    ${nbUe}-${nbSaUe}
    Set Suite Variable              ${FIRST_SA_UE_ID}
    Set Suite Variable              ${FIRST_NSA_UE_ID}

Get and Set SA UE CRNTI
    [Documentation]                 To be used only for SA UEs.
    ...
    ...                             Get then add the c_rnti parameter in the ueSetting dictionary passed as an input parameter.
    ...
    ...                             Return the C_RNTI value.
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*: (mandatory) UE Setting dictionary (UE_NO_PROFILE, UE_SIMPLE, UE_BASIC_SA, ...).
    [Arguments]                     ${ueSetting}
    ${crnti}                        Read SA CRNTI From Egate log        ueId=${ueSetting.ue}
    set to dictionary               ${ueSetting}                        c_rnti=${crnti}
    [Return]                        ${crnti}

Read NSA CRNTI From Egate log
    [Documentation]                 INTERNAL USAGE.
    ...                             Grep egate_console.log file to get newUE-Identity info.
    # Create the commands to extract the CRNTI info:
    ${command}                      Catenate
    ...                                 grep 'newUE-Identity ' ${tl.core.dir_path}/egate_console.log |
    ...                                 tail -1 |
    ...                                 sed -nr 's/\\s*newUE-Identity\\s+([0-9]+).*/\\1/p'
    ${crnti}                        run                         ${command}
    [Return]                        ${crnti}

Read SA CRNTI From Egate log
    [Documentation]                 INTERNAL USAGE.
    ...                             Launch the ue_disp command then flush egate buffer and then grep egate_console.log file to get C_RNTI info.
    [Arguments]                     ${ueId}=1
    ute_wtssim.setup_egate          egate_port=${tl.core.egate_port}
    ...                             host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                             tool_dir=${tl.core.dir_path}
    ...                             ssh_user=ute
    ...                             ssh_pass=ute
    ...                             alias=egate
    # Prepare and execute the command to display the crnti:
    ${cmd}                          set variable                ue_disp id=${ueId} type=general_info
    ute_wtssim.execute_egate_command
    ...                             cmd=${cmd}
    ...                             timeout=5s
    ...                             alias=egate
    # Flush egate buffer into egate_console.log file:
    ute_wtssim.execute_egate_command
    ...                             cmd=sim_log_set flush
    ...                             timeout=5s
    ...                             alias=egate
    # Teardown egate console:
    ute_wtssim.teardown_egate       alias=egate
    sleep                           1s
    # Prepare and execute the command to extract the CRNTI info:
    ${command}                      Catenate
    ...                                 grep 'C-RNTI ' ${tl.core.dir_path}/egate_console.log |
    ...                                 tail -1 |
    ...                                 sed -nr 's/C-RNTI\\s+([0-9]+).*/\\1/p'
    ${crnti}                        run                         ${command}
    # Return the CRNTI value
    [Return]                        ${crnti}
