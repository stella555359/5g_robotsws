*** Settings ***
Documentation
...          Just an exemple on setting some OAM parameters

Resource                            ../Tools.robot
Resource                            ../Setup.robot
Resource                            ../Topology.robot
Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py
Library                             ../../python/Setup.py
Library                             taf.gnb.oam.coam.vdu.interface.Vdu     WITH NAME    vdu
Library                             taf.gnb.oam.coam.cu                    WITH NAME    vcu

Suite Setup                         Suite Setup From scratch                    listBackupFiles=${FD_ALL}

*** Variables ***

&{gNbCuName}     operation_type=replace    parameter_path=/btsName    value=TL037-VCU
${MODN}          MRBTS-10684
@{PARAM_LIST}    &{gNbCuName}

*** Test Cases ***

Toto
    OAM Set Params     modify_param=${PARAM_LIST}    oam=${GNB_CU.oam}    modn=${MODN}

ModifParamVDU
    ## PARAM with no reboot
    ${modn}                    set variable         MRBTS-10684
    &{dico}                    Create Dictionary    btsName=TL037_AF
    Dated Log                  VDU param to be modified: ${dico}
    OAM Set Params             modify_param=${dico}    operation=replace    modn=${modn}

SetScfVdu
    log to console    START
    ${f}    set variable    /home/ute/AF/robotws/testsuite/Paris/resources/SWENG/robot/examples/SCF_DU_fortest.xml
    #OAM Perform Full Commissioning    scf_file=${f}

Restart
    Restart TL
    WA Airscale Wait for Ready    airscale=${AP_DU}

Start
    Dated log                       Start
    ${output}                       call method
    ...                             ${GNB_DU.pods[0].containers[0]}
    ...                             cmd
    ...                                 cmd=ls -al
    ...                                 debug=True
    Dated log                       END
    log to console                  GNB_DU: ${GNB_DU.name} -- ${GNB_DU.mainNode.ip}
