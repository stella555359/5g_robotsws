*** Settings ***
Documentation   CLONE SCF FILES FROM MASTER TL TO SLAVE TL
Library  OperatingSystem
Library  Process
Library  String
Library  BuiltIn

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Variables ***
${scf_adaptation_tool}  /mnt/etfiles/config/tools/scf_adaptation_tool/scf_adaptation_tool.py


*** Test Cases ***
Clone_Nodes
    FOR  ${element}  IN  @{tl.nodes}
        Clone_SCF_File  ${element}
    END


*** Keywords ***
Clone_SCF_File
    [Arguments]  ${node}=gnb0
    [Documentation]
    ...   clone master scf file to additional TL  using Alex scf_adaptation_tool
    ...   call with fitting var-file e.g. robot --variablefile TMOv3_TL351_clonevars.yaml clone_tl.robot
    ...   cloned scf files will have naming like:  TMOv3_TL351_gnb0_clonedscf.xml
    ...   list of nodes is defined also in variable file

    ${m_name}=  Change Node Name  ${node}
    ${mod}=     Set Variable  ${path_to_tempfiles}/mod_to_${tl.name}_${node}.yaml
    ${master}=  Set Variable  ${path_to_masterfiles}/${tl.branch}/7_15_UTE5G${tl.master}/${m_name}/scf.xml
    ${output}=  Set Variable  ${path_to_targetfiles}/${tl.branch}/7_15_UTE5G${tl.name}/${m_name}/${tl.variant}_${tl.name}_${node}_clonedscf.xml
    Log To Console  \nClone master-scf for variant ${tl.variant} from ${tl.master}-${node} to ${tl.name}-${node}\n
    Log To Console  MasterFile: ${master}
    Log To Console  TargetFile: ${output}
    ${template}=  OperatingSystem.Get File    ${path_to_modfiles}/${tl.variant}_${node}_modifications.yaml
    OperatingSystem.Remove File  ${mod}
    ${replaced}=  BuiltIn.Replace Variables  ${template}
    OperatingSystem.Append to file    ${mod}    ${replaced}
    ${result_scf_adapt}  Process.Run process  python ${scf_adaptation_tool} -m ${mod} -t ${master} -o ${output}  stdout=/tmp/a.log  shell=True
    IF  '${log_output} eq true'
        Log To Console  ${result_scf_adapt.stdout}
    END
    TRY
        BuiltIn.Should Be Equal As Integers  ${result_scf_adapt.rc}  0
    EXCEPT
        Log To Console  ${result_scf_adapt.stdout}
        Log To Console  ${result_scf_adapt.stderr}
        BuiltIn.Fail  scf_adaption failed, see stderr
    END

    ${result_sed}  Process.Run process  sed -i 's/\\([MNLR]\\)BTS-\\([0-9]\\+\\)/\\1BTS-${${node}.btsid}/g' ${output}  shell=True
    TRY
        BuiltIn.Should Be Equal As Integers  ${result_sed.rc}  0
    EXCEPT
        Log To Console  ${result_sed.stderr}
        BuiltIn.Fail  sed_replacement failed, see stderr
    END
    TRY
        Variable Should Exist  ${${node}.enbid}
    EXCEPT
        Log  no sbts, go on...
    ELSE
        ${result_sed}  Process.Run process  sed -i 's/LNBTS-\\([0-9]\\+\\)/LNBTS-${${node}.enbid}/g' ${output}  shell=True
    END
    IF  'ENB' in '${m_name}'
        Workaround For GTPU List  ${output}
    END


Change Node Name
    [Arguments]  ${node}=gnb0
    [Documentation]
    ...   internal helper KW to get the node from e.g. gnb0 to GNB-0
    ...   needed for building the filepath...

    ${node_id}=  String.Get Substring  ${node}  -1
    ${node_type}=  String.Get Substring  ${node}  0  3
    ${node_type}=  String.Convert To Upper Case  ${node_type}
    ${nodename}=  BuiltIn.Catenate  SEPARATOR=-  ${node_type}  ${node_id}
    RETURN  ${nodename}


Workaround For GTPU List
    [Arguments]  ${xml_file}
    [Documentation]
    ...   at the moment adaptation tool can replace entries in a list
    ...   so we replace the ip addresses in GTPU object via sed
    ...   only relevant for eNB scf files

    Log To Console  eNB node so we have to use workaround....
    Log To Console  replace IP master_gnb0_uplane ${wa.gnb0.up_ip}
    ${result_sed_wa_1}  Process.Run process  sed -i 's/${wa.gnb0.up_ip}/${gnb0.up_ip}/g' ${xml_file}  shell=True
    TRY
        BuiltIn.Should Be Equal As Integers  ${result_sed_wa_1.rc}  0
    EXCEPT
        Log To Console  ${result_sed_wa_1.stdout}
        Log To Console  ${result_sed_wa_1.stderr}
        BuiltIn.Fail  sed_workaround failed, see stderr
    END
    Log To Console  replace IP master_gnb1_uplane ${wa.gnb1.up_ip}
    ${result_sed_wa_2}  Process.Run process  sed -i 's/${wa.gnb1.up_ip}/${gnb1.up_ip}/g' ${xml_file}  shell=True
    TRY
        BuiltIn.Should Be Equal As Integers  ${result_sed_wa_2.rc}  0
    EXCEPT
        Log To Console  ${result_sed_wa_2.stdout}
        Log To Console  ${result_sed_wa_2.stderr}
        BuiltIn.Fail  sed_workaround failed, see stderr
    END
   Log To Console  replace IP master_SGW_IP ${wa.gnb0.gateway}
    ${result_sed_wa_3}  Process.Run process  sed -i 's/${wa.gnb0.gateway}/${gnb0.gateway}/g' ${xml_file}  shell=True
    TRY
        BuiltIn.Should Be Equal As Integers  ${result_sed_wa_3.rc}  0
    EXCEPT
        Log To Console  ${result_sed_wa_3.stdout}
        Log To Console  ${result_sed_wa_3.stderr}
        BuiltIn.Fail  sed_workaround failed, see stderr
    END

