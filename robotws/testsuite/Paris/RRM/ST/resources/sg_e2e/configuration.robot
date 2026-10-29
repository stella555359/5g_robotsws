*** Settings ***
Documentation   description

Library     OperatingSystem
Library     String
Library     Collections
Library     taf.config.scf                           WITH NAME   scf
Library     taf.gnb.oam.commissioning                   WITH NAME   cm
Library     taf.transport.ssh                           WITH NAME   ssh
Library     taf.gnb.oam.coam.admin                      WITH NAME   coam
Library     taf.gnb.oam.coam.cu                         WITH NAME   coam_cu
Resource    ${CURDIR}/gnbStatus.robot
Resource    ${CURDIR}/logs.robot
Library     ${CURDIR}/myLib_maths.py

*** Keywords ***
Create Connections
    [Documentation]     Metascript to create session
    ...                 Author: Stephane Croquet - 20190401
    ...                 Update: F.Magueur - 20200812 - Update for CLOUD COAM
    ...                 gNB compatibility: CLOUD MZ / CLOUD COAM / CLASSICAL MZ / CLASSICAL COAM
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'MZOAM'
    ...                 configuration.Cloud Create Connections
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'COAM'
    ...                 configuration.Cloud Coam Create Connections
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 configuration.Classical Create Connections

Cloud Create Connections
    [Documentation]      Create session with WebUI and get VM ip addresses
    ...                  Author: Stephane Croquet - 20181217
    set suite variable        ${oam_alias}    OAM
    set suite variable        ${oam_vm_url}   https://${oam_vm}/
    mz.create session         ${oam_vm}       ${oam_vm_mz_login}   ${oam_vm_mz_password}    alias=MegaZ
    @{cu_vm_list}             mz.get all vms types   MegaZ
    set suite variable        @{cu_vm_list}
    &{vm_ip_addr}             mz.get vm ip addresses            MegaZ
    set suite variable        &{vm_ip_addr}

Cloud Coam Create Connections
    [Documentation]      Create session with WebUI and get VM ip addresses
    ...                  Author: F.Magueur - 2020812
    set suite variable        ${oam_alias}    OAM
    # Connect to CU OAM
    set suite variable        ${oam_cu_vm_url}   https://${oam_vm}/

    # Fix ssue: if the connection already exists with the same alias, taf creates a second instance with same alias, but only
    # one will be disconnected by coam_cu.disconnect. Delete the existing session before creating a new one.
    Run keyword and ignore error    coam_cu.disconnect

    coam_cu.connect to      host=${oam_vm}
    ...                     port=    username=${oamVMMzLogin}    password=${oamVMMzPassword}     cu_version=cuoam_19b    secure=${TRUE}

    # Connect to DU OAM
    set suite variable        ${oam_du_vm_url}   https://${oam_asik}/
    wait until keyword succeeds    5 min     30 sec    coam.connect to      bts_host=${oam_asik}    name=coamCnx

#####  !!!!!!!!!!
#####  A tester pour savoir ce qui est attendu reellement dans ces listes
#####  !!!!!!!!!!
    @{cu_vm_list}             coam_cu.get vms
    set suite variable        @{cu_vm_list}
    ${nb_vm}    Get length    ${cu_vm_list}
    &{vm_ip_addr}    Create Dictionary
    FOR    ${index}    IN RANGE    0  ${nb_vm}
        Set to dictionary    ${vm_ip_addr}    ${cu_vm_list[${index}]["name"]}    ${cu_vm_list[${index}]["ip_interfaces"][0].ip_address}
    END
    set suite variable        &{vm_ip_addr}

Classical Create Connections
    [Documentation]      Create session with WebUI
    ...                  Author: Stephane Croquet - 20190401
    ...                  Update: Stephane Croquet - 20190510 - Add COAM
    set suite variable        ${oam_alias}    OAM
    set suite variable        ${oam_vm_url}   https://${oam_vm}/
    run keyword if      '${oam_type}' == 'MZ'
    ...                 wait until keyword succeeds    5 min     30 sec
    ...                 mz.create session         ${oam_vm}       ${oam_vm_mz_login}   ${oam_vm_mz_password}    alias=MegaZ
    run keyword if      '${oam_type}' == 'COAM'
    ...                 wait until keyword succeeds    5 min     30 sec
    ...                 coam.connect to      bts_host=${oam_vm}    name=coamCnx

Create SSH
    [Documentation]     Metascript to create SSH connections
    ...                 gNB compatibility: CLOUD CLASSICAL
    ...                 Author: Stephane Croquet - 20180325
    ...                 20200814: F.Magueur: modification due to cloud cOAM: add criteria oam_type
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'MZOAM'
    ...                 configuration.Cloud Create SSH
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'COAM'
    ...                 configuration.Cloud cOAM Create SSH
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL' and '${system_module_type}'=='ASIK'
    ...                 configuration.Classical Create SSH
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL' and '${system_module_type}'=='ASOD'
    ...                 configuration.Classical Create SSH
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL' and '${system_module_type}'=='ASIB'
    ...                 configuration.Classical ASIx Create SSH

Cloud Create SSH
    [Documentation]     Create SSH connections with VM OAM, ASIK master, ASIK slave, ABIL Xeon A, ABIL Xeon B, ABIL LONER for Cloud
    ...                 Author: Stephane Croquet - 20181217
    ...                 Update: Stéphane Croquet - 20180325
    ...                         Change keyword to be specific for cloud gNB (name...)
    ...                         Remove the ssh connection for mirroring point
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${oam_vm}           ${oam_vm_login}         ${oam_vm_password}      alias=${oam_alias}
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${asik_fh}          ${asik_fh_login}	    ${asik_fh_password}	    proxy=${oam_alias}      alias=asikFhCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${asik_slave}       ${asik_fh_login}	    ${asik_fh_password}	    proxy=asikFhCnx         alias=asikSlaveCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilXeonA}        ${asik_fh_login}	    ${asik_fh_password}	    proxy=asikFhCnx         alias=abilXeonACnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilXeonB}        ${asik_fh_login}	    ${asik_fh_password}	    proxy=asikFhCnx         alias=abilXeonBCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilLoner}        ${asik_fh_login}	    ${asik_fh_password}	    proxy=asikFhCnx         alias=abilLonerCnx

Cloud cOAM Create SSH
    [Documentation]     Create SSH connections with VM OAM on CU, and
    ...                 ASIK master, ASIK slave, ABIL Xeon A, ABIL Xeon B, ABIL LONER in case of ASIK/ABIL boards
    ...                 ASOD Master, ASOD Slave, ASOD loner in case of ASOD
    ...                 Author: F.Magueur - 20200814
    ...                 Update: F.Magueur - 20201007: add differentiation ASIK ASOD
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${oam_vm}           ${oam_vm_login}         ${oam_vm_password}      alias=${oam_alias}
    Run keyword if    '${system_module_type}' == 'ASIK'
    ...               Cloud cOAM ASIK Create SSH
    Run keyword if    '${system_module_type}' == 'ASOD'
    ...               Cloud cOAM ASOD Create SSH

Cloud cOAM ASIK Create SSH
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${oam_asik}          ${asik_fh_login}	    ${asik_fh_password}	    alias=asikFhCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${asik_slave}       ${asik_fh_login}	    ${asik_fh_password}	    proxy=asikFhCnx         alias=asikSlaveCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilXeonA}        ${asik_fh_login}	    ${asik_fh_password}	    proxy=asikFhCnx         alias=abilXeonACnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilXeonB}        ${asik_fh_login}	    ${asik_fh_password}	    proxy=asikFhCnx         alias=abilXeonBCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilLoner}        ${asik_fh_login}	    ${asik_fh_password}	    proxy=asikFhCnx         alias=abilLonerCnx

Cloud cOAM ASOD Create SSH
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${oam_asod}          ${asod_fh_login}	    ${asod_fh_password}	    alias=asikFhCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${asod_slave}       ${asod_fh_login}	    ${asod_fh_password}	    proxy=asikFhCnx         alias=asodSlaveCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${asod_loner}        ${asod_fh_login}	    ${asod_fh_password}	    proxy=asikFhCnx         alias=asodLonerCnx

Cloud cOAM Create SSH to VM
    [Documentation]     Create SSH connections with VM on CU
    ...                 SSH connection to OAM VM must exists before this keyword is called
    ${cpif_hostname}    Set variable    cpif-0.local
    set test variable    ${cpif_hostname}     ${cpif_hostname}
    ssh.connect to    ${cpif_hostname}    ${oamVMLogin}    ${oamVMPassword}    proxy=${oam_alias}    alias=CPIF

Cloud cOAM Close SSH to VM
    [Documentation]     Close SSH connections with VM on CU
    run keyword and ignore error    ssh.disconnect            CPIF

Classical Create SSH
    [Documentation]     Create SSH connections with  ASIK master, ASIK slave, ABIL Xeon A, ABIL Xeon B, ABIL LONER for Classical
    ...                 Author: Stephane Croquet - 20190401
    set suite variable        ${oam_alias}    OAM
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${oam_vm}           ${oam_vm_login}         ${oam_vm_password}      alias=asikFhCnx
    wait until keyword succeeds    10 min     20 sec     ssh.connect to
    ...     ${asik_slave}       ${asik_fh_login}        ${asik_fh_password}     proxy=asikFhCnx         alias=asikSlaveCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilXeonA}        ${asik_fh_login}        ${asik_fh_password}     proxy=asikFhCnx         alias=abilXeonACnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilXeonB}        ${asik_fh_login}        ${asik_fh_password}     proxy=asikFhCnx         alias=abilXeonBCnx
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilLoner}        ${asik_fh_login}        ${asik_fh_password}     proxy=asikFhCnx         alias=abilLonerCnx


Classical ASIx Create SSH
    [Documentation]     Create SSH connections with  ASIB master, ABIO bsh 1:1, ABIO Loki A bsh 1:1, ABIO Loki B bsh 1:2
    ...                 Author: Abderrahmane NEZROUK - 20210325
    set suite variable        ${oam_alias}    OAM
    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${oam_vm}           ${oam_vm_login}         ${oam_vm_password}      alias=asikFhCnx


Classical Create Connection
    [Documentation]     Create SSH connections to interface identified by alias name for Classical
    ...                 Author: Abderrahmane Nezrouk - 20201001
    [Arguments]         ${alias}=asikFhCnx

    #bypass robocop
    ${alias}    set variable    ${alias}

    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${oam_vm}           ${oam_vm_login}         ${oam_vm_password}      alias=asikFhCnx
    Run Keyword if      'alias'='asikSlaveCnx'    wait until keyword succeeds    10 min     20 sec     ssh.connect to
    ...     ${asik_slave}       ${asik_fh_login}        ${asik_fh_password}     proxy=asikFhCnx         alias=asikSlaveCnx
    ...   ELSE IF       'alias'='abilXeonACnx'    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilXeonA}        ${asik_fh_login}        ${asik_fh_password}     proxy=asikFhCnx         alias=abilXeonACnx
    ...   ELSE IF       'alias'='abilXeonBCnx'    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilXeonB}        ${asik_fh_login}        ${asik_fh_password}     proxy=asikFhCnx         alias=abilXeonBCnx
    ...   ELSE IF       'alias'='abilLonerCnx'    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${abilLoner}        ${asik_fh_login}        ${asik_fh_password}     proxy=asikFhCnx         alias=abilLonerCnx

Force SSH
    [Documentation]     Metascprit to reconnect SSH connections
    ...                 Author: Stephane Croquet - 20180325
    run keyword if      '${GNB_Architecture}' == 'CLOUD'
    ...                 configuration.Cloud Force SSH
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 configuration.Classical Force SSH

Cloud Force SSH
    [Documentation]     Reconnect SSH connections with VM OAM, ASIK master, ASIK slave, ABIL Xeon A, ABIL Xeon B, ABIL LONER for Cloud
    ...                 Author: Stephane Croquet - 20181217
    ...                 Update: Stéphane Croquet - 20180325
    ...                         Change keyword to be specific for cloud gNB (name...)
    ...                         Remove the ssh connection for mirroring point
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          ${oam_alias}
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          asikFhCnx
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          asikSlaveCnx
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          abilXeonACnx
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          abilXeonBCnx
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          abilLonerCnx

Classical Force SSH
    [Documentation]     Reconnect SSH connections with VM OAM, ASIK master, ASIK slave, ABIL Xeon A, ABIL Xeon B, ABIL LONER for Classical
    ...                 Author: Stephane Croquet - 20190401
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          asikFhCnx
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          asikSlaveCnx
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          abilXeonACnx
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          abilXeonBCnx
    wait until keyword succeeds    15 min     30 sec     ssh.force reconnect          abilLonerCnx

Close Connections SSH
    [Documentation]     Metascprit to close SSH connections
    ...                 gNB compatibility: CLOUD MZ / CLASSICAL MZ / CLASSICAL COAM
    ...                 Author: Stephane Croquet - 20180325
    ...                 Update: F.Magueur - 20200812 - Update for CLOUD COAM
    ...                 Update: Abderrahmane NEZROUK - for ASIB/ABIO Classical
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'MZOAM'
    ...                 configuration.Cloud Close Connections SSH
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'COAM'
    ...                 configuration.Cloud cOAM Close Connections SSH
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL' and '${system_module_type}'=='ASIK'
    ...                 configuration.Classical Close Connections SSH
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL' and '${system_module_type}'=='ASOD'
    ...                 configuration.Classical Close Connections SSH
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL' and '${system_module_type}'=='ASIB'
    ...                 configuration.Classical Close Connection    alias=asikFhCnx

Cloud Close Connections SSH
    [Documentation]     Close SSH connection with VM OAM, ASIK master, ASIK slave, ABIL Xeon A, ABIL Xeon B, ABIL LONER for Cloud
    ...                 Author: Stephane Croquet - 20181217
    ...                 Update: Stéphane Croquet - 20180325
    ...                 Update: Stéphane Croquet - 20180325
    ...                         Change keyword to be specific for cloud gNB (name...)
    ...                         Remove the ssh connection for mirroring point
    run keyword and ignore error    ssh.disconnect            abilXeonACnx
    run keyword and ignore error    ssh.disconnect            abilXeonBCnx
    run keyword and ignore error    ssh.disconnect            abilLonerCnx
    run keyword and ignore error    ssh.disconnect            asikSlaveCnx
    run keyword and ignore error    ssh.disconnect            asikFhCnx
    run keyword and ignore error    ssh.disconnect            ${oam_alias}
    run keyword and ignore error    mz.teardown session       MegaZ

Cloud cOAM Close Connections SSH
    [Documentation]     Close SSH connection with VM OAM, ASIK master, ASIK slave, ABIL Xeon A, ABIL Xeon B, ABIL LONER for Classical
    ...                 Author: Stephane Croquet - 20200814
    ...                 Update: F.Magueur - 20190510 - Add COAM
    ...                 Update: F.Magueur - 20201007: add differentiation ASIK ASOD
    run keyword and ignore error    coam_cu.disconnect
    run keyword and ignore error    coam.teardown    coamCnx
    Run keyword if    '${system_module_type}' == 'ASIK'
    ...               Cloud cOAM ASIK Close SSH
    Run keyword if    '${system_module_type}' == 'ASOD'
    ...               Cloud cOAM ASOD Close SSH

Cloud cOAM ASIK Close SSH
    run keyword and ignore error    ssh.disconnect            abilXeonACnx
    run keyword and ignore error    ssh.disconnect            abilXeonBCnx
    run keyword and ignore error    ssh.disconnect            abilLonerCnx
    run keyword and ignore error    ssh.disconnect            asikSlaveCnx
    run keyword and ignore error    ssh.disconnect            asikFhCnx

Cloud cOAM ASOD Close SSH
    run keyword and ignore error    ssh.disconnect            asodLonerCnx
    run keyword and ignore error    ssh.disconnect            asodSlaveCnx
    run keyword and ignore error    ssh.disconnect            asikFhCnx

Classical Close Connections SSH
    [Documentation]     Close SSH connection with VM OAM, ASIK master, ASIK slave, ABIL Xeon A, ABIL Xeon B, ABIL LONER for Classical
    ...                 Author: Stephane Croquet - 20190401
    ...                 Update: Stephane Croquet - 20190510 - Add COAM
    run keyword and ignore error    ssh.disconnect            abilXeonACnx
    run keyword and ignore error    ssh.disconnect            abilXeonBCnx
    run keyword and ignore error    ssh.disconnect            abilLonerCnx
    run keyword and ignore error    ssh.disconnect            asikSlaveCnx
    run keyword and ignore error    run keyword if      '${oam_type}' == 'COAM'        coam.teardown    coamCnx

Classical Close Connection
    [Documentation]     Close SSH connection to interface identified by alias for Classical
    ...                 Author: Abderrahmane Nezrouk - 20201001
    [Arguments]         ${alias}
    run keyword and ignore error    ssh.disconnect            ${alias}
    run keyword and ignore error    run keyword if      '${oam_type}' == 'COAM'        coam.teardown    coamCnx

Mirroring Create SSH
    [Documentation]    Create SSH connections for mirroring points
    ...                gNB compatibility: CLOUD and CLASSICAL
    ...                Author: Stephane Croquet - 20190404
    ...                Update doc - F.Magueur - 20201007. ${mirroring} and ${mirroring2} are defined in var_test_suite.robot.
    ...                    ${mirroring} refers to controler board (cOAM Cloud configuration)
    ...                    ${mirroring2} refers to real eNB IP address
    run keyword if      '${mirroring}' is not 'None'
    ...     ssh.connect to  ${mirroring}        ${mirroring_login}    ${mirroring_password}    alias=mirroringCnx
    run keyword if      '${mirroring2}' is not 'None'
    ...     ssh.connect to  ${mirroring2}        ${mirroring2_login}    ${mirroring2_password}    alias=mirroringCnx2


Mirroring Close SSH
    [Documentation]    Close SSH connections for mirroring points
    ...                gNB compatibility: CLOUD and CLASSICAL
    ...                Author: Stephane Croquet - 20190404
     run keyword if      '${mirroring}' is not 'None'
    ...     ssh.disconnect  mirroringCnx
    run keyword if      '${mirroring2}' is not 'None'
    ...     ssh.disconnect  mirroringCnx2

Del SCF System Param
    [Documentation]     Removal of parameters settable only by the system
    ...                 ${parameters} is parameter string listed as follows   param1; param2; paramN
    ...                 Path to SCF file to modify is stored in suite variable ${output_scf}
    [Arguments]     ${parameters}

    ${output_scf_local}    join path    ${scf_path}    ${updated_scf_file_name}


    @{splitparam}           Split String    ${parameters}   ;
    FOR                    ${param}    IN    @{splitparam}
                          Run    sudo sed -i -e '/${param}/ d' ${output_scf_local}
                          Log         Parameter Removed : ${param}
    END

Set scf param
    [Documentation]     basic scf change occuring only once in SCF xml file.
    ...                 ${parameters} is parameter string listed as follows   param1 , value1 ; param2 , value2 ; paramN , valueN
    ...                 Author : Denis/Ziad
    [Arguments]     ${parameters}    ${output_scf}=${EMPTY}

    #Copy File       ${scf_path}/save_initial_scf.xml      ${scf_path}/scf_under_test.xml
    Run keyword if     '${output_scf}'=='${EMPTY}'
    ...     Run keywords
    ...       Set test variable     ${output_scf}       ${scf_path}/scf_under_test.xml
    ...       AND
    ...       Run keyword if    not os.path.exists($output_scf)    Copy File    ${scf_path}/save_initial_scf.xml    ${output_scf}
    #...       Run keyword unless    os.path.exists($output_scf)    Copy File    ${scf_path}/save_initial_scf.xml    ${output_scf}

    #${bit_without_quotes}     Strip String    ${bit}    characters="
    @{splitparam}           Split String    ${parameters}   ;
    FOR                    ${element}    IN    @{splitparam}
                           @{oneparam}     Split String    ${element}   ,
                           ${param}     Set Variable       @{oneparam}[0]
                           ${param}    Strip String    ${SPACE}${param}${SPACE}
                           ${value}     Set Variable     @{oneparam}[1]
                           ${value}    Strip String    ${SPACE}${value}${SPACE}
                           ${resp}              Run    grep -c -i "${param}" ${output_scf}
                           run keyword if   ${resp} > 0     Run    sed -i -e 's/${param}\">[[:print:]]*</${param}\">${value}</g' ${output_scf}
                           Log         Parameter set : ${param} = ${value}
    END

    #Check reboot needed
    ${resp}                   Run                 diff ${scf_path}/save_initial_scf.xml ${output_scf}
    @{ln}   split to lines  ${resp}
    Run keyword if  len($ln) > 2     set test variable    ${reboot}     1
    ...     ELSE IF     'cmData type' not in $ln     set test variable    ${reboot}     1

    Run     sed -i -e 's/<cmData type=\"actual\">/<cmData type=\"plan\" scope=\"all\">/g' ${output_scf}

    [Return]                ${output_scf}

Commissioning via SCF file
    [Documentation]     save the current scf and change the delivered SCF according modif provided through scf_
    ...                 modi_param variable within tlconfig.py and performed commissioning in case scf_modi_param not empty
    ...                 TAF used taf.gnb.oam.commissioning 2.1.6
    #curent SCF save
    gnbStatus.Check active Software Version number

	configuration.save scf		save_initial_scf.xml
    ${output_scf}   join path   ${scf_path}     scf_under_test.xml
    run keyword if  len($scf_modi_param) != 0
    ...             cm.modify_scf    input_scf=${scf_path}/save_initial_scf.xml   output_scf=${output_scf}    parameters_lists=${scf_modi_param}

Save sw config
  [Arguments]       ${swcfg_name}=backup_swconfig.txt       ${path}=${scf_path}
   ssh.download file         /ffs/run/swconfig.txt    ${path}/${swcfg_name}   connection=asikFhCnx

Upload sw config
  [Arguments]       ${swcfg_name}
   ssh.upload file           ${swcfg_name}    /ffs/run/swconfig.txt   connection=asikFhCnx

Modify bits in swconfig
  [Arguments]       ${bit}    ${file_path}    ${connection}
  [Documentation]   change the value of an hexadecimal field (or several fields) with the new value(s), both specified in ${bit} in
  ...               the swconfig file within the path specified ${file_path}. If the hexadecimal field does not exist in the file,
  ...               the hexadecimal field & its value are written into the file initial file is saved in a local directory.
  ...               it returns the local path of the file (for restore initial file purpose)
  ...               ${bit} format can be like "4600BA=2 0x100002=0"
  ...               TAF used: ssh version 3.3.1
  ...               Author: EricBP

  ssh.execute               rm ${file_path}.p7    connection=${connection}
  @{file_name}              split string     ${file_path}    /
  reverse list              ${file_name}
  ${save_file}              join path   ${save_path}    @{file_name}[0]_ini
  ssh.download file         ${file_path}    ${save_file}   connection=${connection}
  ${bit_without_quotes}     Strip String    ${bit}    characters="
  @{bit_splited}            Split String    ${bit_without_quotes}   ${EMPTY}
  FOR                      ${element}    IN    @{bit_splited}
                           @{bit_splited2}     Split String    ${element}   =
                           ${registerId}       fetch from right   @{bit_splited2}[0]   \#
                           ssh.send command     grep ${registerId} ${file_path}    connection=${connection}
                           ${output}            ssh.read output                    connection=${connection}
                           @{output_splited}     Split String    ${output}   =
                           ${resp}     Run         grep -i "@{bit_splited2}[0]" ${file_path}
                           ssh.execute         chmod 777 ${file_path}     connection=${connection}
                           run keyword if      len($output) == 0 and len($resp) == 0 and '#' in $element      log     No change
                           ...     ELSE IF     len($output) == 0    ssh.execute     echo "${element}" >> ${file_path}     connection=${connection}
                           ...     ELSE        Run keywords
                           ...                 set suite variable      @{cmd_sw}    grep ${registerId} ${file_path} > /dev/null && sed -i
                           ...     "s/@{output_splited}[0]=[0-9]*/${element}/" ${file_path} || echo "${element}" >> ${file_path}      AND
                           ...     set suite variable         ${cmd_sw}        @{cmd_sw}[0] @{cmd_sw}[1]       AND
                           ...     log         ${cmd_sw}
                           run keyword if      len($output) != 0    ssh.execute       ${cmd_sw}       connection=${connection}
  END

  #Check if reboot needed
  ${save_file_new}          join path   ${save_path}    @{file_name}[0]_new
  ssh.download file         ${file_path}    ${save_file_new}  connection=${connection}
  ${resp}                   Run                       diff ${save_file} ${save_file_new}
  ${len}                    get length      ${resp}
  Run keyword if             ${len}>0                  set test variable    ${reboot}     1

  [Return]                  ${save_file}

Configure real EPC routes
    [Documentation]   Activates Real EPC connection, permetting to raise the X2 link
    ...               TAF used: ssh version 3.3.1
    ssh.connect to              cpif-0.local     robot    rastre1    proxy=${oam_alias}    alias=CPIF
    ssh.execute                 sudo route add -net ${subnet_backhaul} gw ${GW_address}         connection=CPIF
    ssh.disconnect              connection=CPIFconfiguration
    ssh.connect to              upue-0.local     robot    rastre1    proxy=${oam_alias}    alias=UPUE
    ssh.execute                 sudo route add -net ${SGW_address} gw ${GW_address}        connection=UPUE
    ssh.disconnect              connection=UPUE

Create UnitOAM_SOAP_log file
    [Arguments]    ${CnxToRU}=CPRI      #CPRI or TestVMRU
    Run Keyword and Return Status      Run Keyword if     '${CnxToRU}' == 'TestVMRU'
    ...                                ssh.Connect To     ${testVM_ru}       localuser        10c@1user      alias=testVM_ru
    Run Keyword and Return Status      Run Keyword if     '${CnxToRU}' == 'TestVMRU'
    ...                                ssh.Connect To     ${ru_VM}           root             umniedziala     proxy=testVM_ru      alias=rucnx
    Run Keyword and Return Status      Run Keyword if     '${CnxToRU}' == 'CPRI'
    ...                                logs.Get ru_asik IP address
    #Run Keyword and Return Status      Run Keyword if    '${CnxToRU}' == 'CPRI'
    #...                                ssh.Connect To    ${ru_asik}         root             umniedziala     proxy=asikcnx        alias=rucnx
    ${return}                          ssh.execute        command= /usr/bin/ccsShell.sh rad -pw 0x2c 1            connection=rucnx
    sleep    5 sec
    ssh.disconnect                     connection=rucnx

BIP L1L2 message mirroring configuration
    [Documentation]    Load  config 5 (Latest Loner >5G19A_6.1051.326)
    ...                Argument:
    ...                     connecton: ASIK Master Connection alias (to handle cloud and classical gNB)
    ...                Author: Stephane Croquet - 20190404 - Jacob VELASCO 08102019
    [Arguments]     ${connection}=asikFhCnx    ${mirroring_mode}=local

    ${output}      ssh.execute        chmod +x /ffs/run/config/scripts/*.sh       connection=${connection}
    log            ${output}
    ${cmd}          set variable    /ffs/run/config/scripts/gnbMirroring.sh --mirroring_mode='${mirroring_mode}'
    ${output}      ssh.execute     ${cmd}   connection=${connection}
    log            ${output}

Scf Fallback Creation
    [Documentation]     Create a delta scf file with current value for a given parameter (To be used to fallback after an online modification)
    ...                 Parameters:
    ...                     -scf_current: current scf name (full path anf filename)
    ...                     -scf_delta_fallback: name of delta scf to be created (full path anf filename)
    ...                     -scf_delta_template: name of template delta scf to be used (full path anf filename)
    ...                     -dist_name: distinguish named
    ...                     -p_name: parameter named
    ...                 Autor: Stephane Croquet
    ...                 Creation: 23/01/2019
    [Arguments]     ${scf_current}     ${scf_delta_fallback}    ${scf_delta_template}    ${dist_name}  ${p_name}

    scf.load scf    ${scf_current}
    ${value}        run keyword     scf.get value from scf     p_name=${p_name}
    log             Previous value ${value}
    scf.load scf             ${scf_delta_template}
    scf.add element to scf   ${dist_name}   ${p_name}   ${value}
    scf.save scf             ${scf_delta_fallback}

Online Modification
    [Documentation]    Create a delta scf file with new value for a given parameter (To be used for online modification)
    ...                 Parameters:
    ...                     -scf_delta: name of delta scf to be created (full path anf filename)
    ...                     -scf_delta_template: name of template delta scf to be used (full path anf filename)
    ...                     -dist_name: distinguish named
    ...                     -p_name: parameter named
    ...                     -value: value to set
    ...                 Autor: Stephane Croquet
    ...                 Creation: 23/01/2019
    [Arguments]     ${scf_delta}  ${scf_delta_template}   ${dist_name}  ${p_name}   ${value}
    log             New value ${value}
    scf.load scf    ${scf_delta_template}
    scf.add element to scf  ${dist_name}  ${p_name}   ${value}
    scf.save scf    ${scf_delta}


Add External Clock
    [Documentation]    For VIAVI only, configure external GPS synchro from ASIK if required.
    ...                gNB compatibility: CLOUD.
    ...                Author: Stephane Croquet - 20190404
    ${output}   ssh.execute
    ...         ddal -s ddal_clk_io_configure_output_signal 1 DDAL_CLK_IO_SIGNAL_10M_INTERNAL DDAL_CLK_IO_PORT_SINGLE_ENDED_OUT_1
    ...         connection=asikFhCnx
    log            ${output}


Check CPRI Discovery
    [Documentation]    Wait for CPRI setup (RRH is detected).
    ...                It's a way, among many others, to detect ASIK is started.
    ...                gNB compatibility: CLASSICAL.
    ...                Author: Stephane Croquet - 20190404
    ${output}      ssh.execute
    ...            cat /tmp/startup_DEFAULT.log | grep 'CPRI_DISCOVERY_IND'
    ...            connection=${oam_alias}
    Should Contain
    ...            ${output}
    ...            CPRI_DISCOVERY_IND

Site Reset
    [Documentation]     Metascript to perform site reset
    ...                 gNB compatibility: MZ / COAM
    ...                 Author: Stephane Croquet - 20190519
    ...                 20202805: Update Fabienne Magueur: parameters for COAM
    ...                 20200812 In case of Cloud cOAM, only DU is reset. Reset of CU will be handled
    ...                          by another keyword.
    run keyword if      '${oam_type}' == 'MZ'
    ...                 mz.reset_site     MegaZ
    run keyword if      '${oam_type}' == 'COAM'
    ...                 coam.reset_site    300    coamCnx    True

Save SCF
    [Documentation]     Metascript to save current SCF
    ...                 gNB compatibility: MZ / COAM
    ...                 Author: Stephane Croquet - 20190519
    ...                 20200528 Update Fabienne Magueur: add timeout and connection name for COAM
    ...                 20200812 In case of Cloud cOAM, only SCF of DU is saved. SCF of CU will be handled
    ...                          by another keyword.
    [Arguments]         ${scf_name}=backup_scf.xml  ${path}=${scf_path}
    run keyword if      '${oam_type}' == 'MZ'
    ...                 mz.get_current_scf_file     ${path}    ${scf_name}  MegaZ
    run keyword if      '${oam_type}' == 'COAM'
    ...                 coam.get_current_scf_file   ${path}    ${scf_name}    20    coamCnx
    ${cu_scf_initial}    set variable    ${path}/InitialCuSCF.xml
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'COAM'
    ...                 coam_cu.get_current_plan_file     path=${cu_scf_initial}    timeout=300s

SCF Validate
    [Documentation]     Metascript to validate SCF
    ...                 gNB compatibility: MZ / COAM
    ...                 Author: Stephane Croquet - 20190519
    ...                 20202805: Update Fabienne Magueur: parameters for COAM
    [Arguments]         ${scf_file}
    run keyword if      '${oam_type}' == 'MZ'
    ...                 mz.validate_scf     ${scf_file}     20      MegaZ
    run keyword if      '${oam_type}' == 'COAM'
    ...                 coam.validate_scf   ${scf_file}    20    coamCnx

SCF Commission
    [Documentation]     Metascript to perform commissionning using SCF file
    ...                 gNB compatibility: MZ / COAM
    ...                 Author: Stephane Croquet - 20190523 - Modif : 20191024
    ...                 20202805: Update Fabienne Magueur: parameters for COAM
    ...                 20200812 In case of Cloud cOAM, only SCF of DU is saved. SCF of CU will be handled
    ...                          by another keyword.
    [Arguments]         ${scf_file}
    run keyword if      '${oam_type}' == 'MZ'       run keywords
    ...                 mz.perform commissioning       ${scf_file}       MegaZ      AND
    ...                 Run keyword and ignore error    configuration.Site Reset    AND
    ...                 Run keyword and ignore error    configuration.Close Connections SSH     AND
    ...                 sleep   240            #To avoid timeout on HTTP connection
    run keyword if      '${oam_type}' == 'COAM'     run keywords
    ...                 coam.perform commissioning     ${scf_file}      False    True    300    coamCnx        AND
    ...                 Run keyword and ignore error    configuration.Close Connections SSH     AND
    ...                 sleep   15

Luashark config
    [Arguments]         ${expand_field}=0         ${expand_struct}=1
    [Documentation]     expand_item_field = false,     -- Expand array item Field.
    ...                 expand_item_structure = true,  -- Expand array item Structure


    run keyword if   ${expand_field} == 1
    ...              Run    sed -i 's/expand_item_field = false,/expand_item_field = true,/g' /opt/luashark/config.lua
    run keyword if   ${expand_field} == 0
    ...              Run    sed -i 's/expand_item_field = true,/expand_item_field = false,/g' /opt/luashark/config.lua

    run keyword if   ${expand_struct} == 1
    ...              Run    sed -i 's/expand_item_structure = false,/expand_item_structure = true,/g' /opt/luashark/config.lua
    run keyword if   ${expand_struct} == 0
    ...             Run    sed -i 's/expand_item_structure = true,/expand_item_structure = false,/g' /opt/luashark/config.lua

Set scf param V2
    [Documentation]     basic scf change occuring only once in SCF xml file.
    ...                 ${parameters} is parameter string listed as follows   param1 , value1 ; param2 , value2 ; paramN , valueN
    ...                 Author : Denis Verdier
    [Arguments]     ${parameters}

    configuration.Save SCF  save_initial_scf.xml
    Copy File       ${scf_path}/save_initial_scf.xml      ${scf_path}/scf_under_test.xml
    ${output_scf}   join path   ${scf_path}     scf_under_test.xml
    Copy File       ${scf_path}/$save_initial_scf.xml      ${output_scf}
    #${bit_without_quotes}     Strip String    ${bit}    characters="
    @{splitparam}           Split String    ${parameters}   ;
    FOR                    ${element}    IN    @{splitparam}
                           @{oneparam}     Split String    ${element}   ,
                           ${param}     Set Variable       @{oneparam}[0]
                           ${param}    Strip String    ${SPACE}${param}${SPACE}
                           ${value}     Set Variable     @{oneparam}[1]
                           ${value}    Strip String    ${SPACE}${value}${SPACE}
                           ${resp}              Run    grep -c -i "${param}" ${output_scf}
                           run keyword if   ${resp} == 1     Run    sed -i -e 's/${param}\">[[:print:]]*</${param}\">${value}</g' ${output_scf}
                           Log         Parameter set : ${param} = ${value}
    END

    #Check reboot needed
    ${resp}                   Run                 diff ${scf_path}/save_initial_scf.xml ${output_scf}
    ${len}                    get length          ${resp}
    Run keyword if      ${len}>0                  set test variable    ${reboot}     1

    Run     sed -i -e 's/<cmData type=\"actual\">/<cmData type=\"plan\" scope=\"all\">/g' ${output_scf}
    #Run     sed -i -e 's/encoding=\"UTF-8\" standalone=\"no/encoding=\"UTF-8\" standalone=\"yes/g' ${output_scf}

    [Return]                ${output_scf}

Change NRCELL parameter in SCF
    [Documentation]     Replace/set the parameter of NRCELL object in the given parsed XML (SCF)
    ...   Arguments: source SCF   parameter_name    parameter_value
    ...   Author: Stephane Croquet - 20191118
    [Arguments]    ${xml_root}  ${param_name}  ${param_value}
    ${dist_name} =           set variable     MRBTS-${mr_bts}/NRBTS-${GNB_nr_bts}/NRCELL-1
    XML.Set Element Text  ${xml_root}  xpath=//managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]  text=${param_value}


Change NRCELL parameter in SCF V2
    [Documentation]     Replace/set the parameter of NRCELL object or of list under NRCELL object in the given parsed XML (SCF)
    ...   Arguments: source SCF   parameter_name    parameter_value  list(under NRCELL)
    ...   Author: Stephane Croquet - 20200119
    [Arguments]  ${xml_root}  ${param_name}  ${param_value}  ${list}=${EMPTY}
    ${dist_name}=    set variable     MRBTS-${mr_bts}/NRBTS-${GNB_nr_bts}/NRCELL-1
    ${xpath}=  set variable if
    ...  '${list}'=='${EMPTY}'  //managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    ...  '${list}'!='${EMPTY}'  //managedObject[@distName="${dist_name}"]/list[@name="${list}"]//p[@name="${param_name}"]
    XML.Set Element Text  ${xml_root}  xpath=${xpath}  text=${param_value}

Set Parameter Value
    [Documentation]     Metascript to change 1 parameter
    ...                 gNB compatibility: MZ / COAM
    ...                 Autor: Stephane Croquet
    ...                 Creation: 26/07/2019
    [Arguments]         ${dist_name}  ${p_name}   ${value}
    run keyword if      '${oam_type}' == 'MZ'
    ...                 set parameter value MzOAM     ${dist_name}  ${p_name}   ${value}
    run keyword if      '${oam_type}' == 'COAM'
    ...                 set parameter value cOAM      ${dist_name}  ${p_name}   ${value}


Set Parameter Value MzOAM
    [Documentation]    Parameter modification with MzOAM using delta SCF file.
    ...                Contrainte: SCF_Delta template must be filled with correct NIDD definition
    ...                Parameters:
    ...                     -dist_name: distinguish named
    ...                     -p_name: parameter named
    ...                     -value: value to set
    ...                 Autor: Stephane Croquet
    ...                 Creation: 26/07/2019
    [Arguments]     ${dist_name}  ${p_name}   ${value}
    scf.load scf                ${PATH_TL_Config}/SCFDelta_template.xml
    scf.add element to scf      ${dist_name}  ${p_name}   ${value}
    scf.save scf                ${scf_path}/scfDelta.xml
    configuration.scf validate  ${scf_path}/scfDelta.xml
    cm.commission               ${oam_vm}        ${scf_path}/scfDelta.xml
    configuration.create Connections
    configuration.create SSH


Set Parameter Value cOAM
    [Documentation]    Parameter modification with coam TAF
    ...                Parameters:
    ...                     -dist_name: distinguish named
    ...                     -p_name: parameter named
    ...                     -value: value to set
    ...                 Autor: Stephane Croquet
    ...                 Creation: 26/07/2019
    ...                 20202805: Update Fabienne Magueur: parameters for COAM
    [Arguments]     ${dist_name}  ${p_name}   ${value}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}  parameter=${p_name}  value=${value}
    ...    operation=update    skip_parameter_relation_errors=true    should_activate=True
    ...    timeout=300    connection=coamCnx


Restore Initial Configuration
    [Documentation]   restore either initial suite scf - if used in suite teardown, either initial TC scf
    ...   Author: Denis Verdier  - 20191205
    ...                 20200812 In case of Cloud cOAM, only SCF of DU is restored. SCF of CU will be handled
    ...                          by another keyword.

    ${res}  run keyword and return status  log  ${SUITE_STATUS}
    ${f}  run keyword if  $res  set variable  ${suite_dir}/initial_scf.xml
    ...  ELSE  set variable      ${scf_path}/save_initial_scf.xml

    ${swf}  run keyword if  $res  set variable  ${suite_dir}/initial_swconfig.txt
    ...  ELSE  set variable      ${scf_path}/save_initial_swconfig.txt

    configuration.Create Connections
    configuration.Create ssh
    configuration.Save SCF      path=${suite_dir}       scf_name=temp_scf.xml
    configuration.Save sw config    path=${suite_dir}       swcfg_name=temp_swconfig.txt

    #Check swconfig
    ${resp}  Run  diff ${suite_dir}/temp_swconfig.txt ${swf}
    @{ln}   split to lines  ${resp}
    ${length}   get length  ${ln}
    ${rebootforswcfg}       Run keyword if  len(${ln}) > 0   set variable  ${TRUE}
    Run     rm -f ${suite_dir}/temp_swconfig.txt
    configuration.Upload sw config    ${swf}

    #Check scf
    ${resp}  Run  diff ${suite_dir}/temp_scf.xml ${f}
    @{ln}   split to lines  ${resp}
    ${length}   get length  ${ln}
    ${rebootforscf}       Run keyword if  len(${ln}) > 10   set variable  ${TRUE}
    ...  ELSE   set variable  ${FALSE}
    Run     rm -f ${suite_dir}/temp_scf.xml

    run keyword if  $rebootforscf == True     Run keyword and ignore error    configuration.scf commission      ${f}
    ...  ELSE IF    $rebootforswcfg == True   Run keyword and ignore error    configuration.Site Reset
    ...  ELSE       return from keyword       No restore needed

    # Wait to get ip connectivity to boards (to configure traces)
    configuration.create SSH
    configuration.create Connections
    wait until keyword succeeds    20 min     30 sec    gnbStatus.Check Cell Availability Status V2

    configuration.Close Connections SSH


AEUD Trx only IQ swap after reset
    [Documentation]    20200528: Update Fabienne Magueur: parameter for coam.get detected hw info
    ${result}   coam.get detected hw info    coamCnx
    ${r}   Convert To String      ${result}
    log     ${r}
    return from keyword if      'AEUD' not in $r       RU is not AEUD

    ${ipRU}            Get RU IP On Loner
    ssh.Connect To	   ${ipRU}       root      umniedziala 	 proxy=abilLonerCnx   alias=rucnx
    ${return}                          ssh.execute                 command= /sbin/devmem 0xa0205030 32            connection=rucnx
    log         ${return}
    ${return}                          ssh.execute                 command= /sbin/devmem 0xa0205030 32 0x0        connection=rucnx
    ${return}                          ssh.execute                 command= /sbin/devmem 0xa0205030 32            connection=rucnx
    log         ${return}

    ssh.Connect To	   192.168.100.2      root      umniedziala 	 proxy=rucnx   alias=rucnx_slave
    ${return}                          ssh.execute                 command= /sbin/devmem 0xa0205030 32            connection=rucnx_slave
    log         ${return}
    ${return}                          ssh.execute                 command= /sbin/devmem 0xa0205030 32 0x0        connection=rucnx_slave
    ${return}                          ssh.execute                 command= /sbin/devmem 0xa0205030 32            connection=rucnx_slave
    log         ${return}

# Keyword fo C-Plane Trace configuration

Configure CPlane Trace level
  [Documentation]   Set CPlane trace level to "trace" on ASIK Master

    # starting from 19A, CPLane traces can be activated by creating file cp_runtime.ini in /ffs/run and rebooting the gNB

    ${TraceCplaneFileExist}    File Exists    /ffs/run/cp_runtime.ini    connection=asikFhCnx

    Run keyword if    '${TraceCplaneFileExist}' == 'False'    Run keywords
    ...     Upload File    local_path=${CURDIR}/../Resources/cp_runtime.ini    remote_path=/ffs/run/cp_runtime.ini    connection=asikFhCnx    AND
    ...     set test variable    ${reboot}    1


# Miscellaneous Keywords
########################
Get Reset Counter ASIK
    [Documentation]    Get the value of Reset Counter from ASIK board.

    ${active_partition_n}=    Execute    ls -l /ffs/run | awk -F "-> " '{print $2}'    connection=asikFhCnx
    ${active_partition}=    String.Get Substring   ${active_partition_n}    0    8
    Log     Partition Active:${active_partition}Fin
    ${blackbox_file}=      catenate    SEPARATOR=    ${active_partition}   /config/lifedata/blackbox
    ${reset_count_str}=    Execute    grep "RESET COUNTER" ${blackbox_file} | awk -F ": " '{print $2}'    connection=asikFhCnx

    ${reset_count}=    Convert To Integer   ${reset_count_str}

    [Return]    ${reset_count}

Get Reset Counter ABIL
    [Documentation]    Get the value of Reset Counter from ABIL board.

    ${blackbox_file}    set variable    /ram/lifedataFsp/blackbox
    ${reset_count_str}=    Execute    grep "RESET COUNTER" ${blackbox_file} | awk -F ": " '{print $2}'    connection=abilXeonACnx

    ${reset_count}=    Convert To Integer   ${reset_count_str}

    [Return]    ${reset_count}

Get RF IP Address From Dhcp Lease
    [Documentation]    Get RF IP Address from DHCP Lease
    ...                RF IP Address can be found startup_BTSOM.log

    ${startup_BTSOM_remote_path}=    Set Variable    /tmp/startup_BTSOM.log
    ${startup_BTSOM_local_path}=    join path       ${save_path}    startup_BTSOM.log
    ${startup_BTSOM_xz_0x1011_remote_path}=    Set Variable    /ffs/run/logs/0x1011_aasyslog/startup_BTSOM.log.xz
    ${startup_BTSOM_xz_fct_0a_remote_path}=    Set Variable    /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz
    ${startup_BTSOM_local_path_xz}=    join path       ${save_path}    startup_BTSOM.log.xz

    ${is_file_in_tmp}=    File exists    remote_path=${startup_BTSOM_remote_path}    connection=asikFhCnx
    ${is_file_in_0x1011_aasyslog}=    File exists    remote_path=${startup_BTSOM_xz_0x1011_remote_path}    connection=asikFhCnx
    ${is_file_in_0x1011_fct_0a_aasyslog}=    File exists    remote_path=${startup_BTSOM_xz_fct_0a_remote_path}    connection=asikFhCnx

    # Get startup_BTSOM.log file path
    Run keyword if    ${is_file_in_tmp} == True
    ...        ssh.download file     remote_path=${startup_BTSOM_remote_path}    local_path=${startup_BTSOM_local_path}    connection=asikFhCnx
    Run keyword if    ${is_file_in_0x1011_aasyslog} == True    Run keywords
    ...        log    remote_path=${startup_BTSOM_xz_0x1011_remote_path}, local_path=${startup_BTSOM_local_path_xz}    AND
    ...        ssh.download file     remote_path=${startup_BTSOM_xz_0x1011_remote_path}    local_path=${startup_BTSOM_local_path_xz}
    ...                              connection=asikFhCnx    AND
    ...        Run    /usr/bin/unxz ${startup_BTSOM_local_path_xz}
    Run keyword if    ${is_file_in_0x1011_fct_0a_aasyslog} == True    Run keywords
    ...        log    remote_path=${startup_BTSOM_xz_fct_0a_remote_path}, local_path=${startup_BTSOM_local_path_xz}    AND
    ...        ssh.download file     remote_path=${startup_BTSOM_xz_fct_0a_remote_path}    local_path=${startup_BTSOM_local_path_xz}
    ...                              connection=asikFhCnx    AND
    ...        Run    /usr/bin/unxz ${startup_BTSOM_local_path_xz}

    ${RF_INET_LEASE}=    Run    grep API_INET_DHCP_LEASE_IND_MSG ${startup_BTSOM_local_path}
    ${filter_ip}=   Get Regexp Matches   ${RF_INET_LEASE}    ip\\s\\[\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\]    0
    ${RF_dhcp_ip}=   Get Regexp Matches   ${filter_ip[0]}    \\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}
    ${RF_IP}=    set variable    ${RF_dhcp_ip[0]}

    Should Not Be Empty    ${RF_IP}

    [Return]    ${RF_IP}

Get RF IP Address From Dhcp Lease 21A
    [Documentation]    Get RF IP Address from DHCP Lease
    ...                RF IP Address can be found on ASIK master in /ram/radio-dhcpd/dhcp.leases (not available
    ...                anymore in startup_BTSOM.log starting from 21A)
    ...                Starting from 21A, RF can be joined only from FHNET

    configuration.Create ssh
    ${startup_dhcp_lease_remote_path}=    Set Variable    /ram/radio-dhcpd/dhcp.leases
    ${lease_address}    ssh.execute    grep -E '[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+' /ram/radio-dhcpd/dhcp.leases
    ...                 connection=asikFhCnx    timeout=10s

    Run keyword and ignore error    configuration.Close Connections SSH
    log    ${lease_address}
    log    ${lease_address[0]}
    ${RF_dhcp_ip}=   Get Regexp Matches   ${lease_address}    \\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}    0
    ${RF_IP}=    set variable    ${RF_dhcp_ip[0]}

    Should Not Be Empty    ${RF_IP}

    [Return]    ${RF_IP}


Get DU hw Type
    [Documentation]    Get system module board type
     Run Keyword If    '${oam_type}' == 'COAM'    Get DU hw Type Coam

Get DU hw Type Coam
    ${hw_dict}    coam.Get Detected Hw Info    timeout=20    connection=coamCnx
    Log    ${hw_dict}

    ${value}    Set Variable    ${hw_dict['systemModules'][0]['productName']}
    Log    ${value}

    ${board_type}    Get Substring    ${value}    0    4
    Set Suite Variable    ${system_module_type}    ${board_type}

Get Baseband Type
    [Documentation]    Get baseband board type
    Run Keyword If    '${oam_type}' == 'COAM'    Get Baseband Type Coam

Get Baseband Type Coam
    [Documentation]
    ${bb_list}    Get Fbb Info    timeout=20s    connection=coamCnx
    Log    ${bb_list}
    ${value}      Set Variable    ${bb_list[0]['productName']}
    Log    ${value}
    ${board_type}    Get Substring    ${value}    0    4
    Set Suite Variable     ${baseband_type}    ${board_type}

