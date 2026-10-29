*** Settings ***
Documentation
...    author: CSV Team Ulm

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library     OperatingSystem
Library     XML

Library     taf.transport.ssh          WITH NAME    ssh

Resource    ../../../../Ulm/resources/Common/ute_workarounds.robot
Resource    ../../../../Ulm/resources/Common/wts_ue.robot
Resource    ../../../../Ulm/resources/Common/gnb.robot
Resource    ../../../../Ulm/resources/Common/testline.robot
Resource    ../../../../Ulm/resources/Common/util.robot
Resource    ../../../../Ulm/resources/Common/connect.robot

Resource    ../../../../Ulm/SyVe/CSV/resources/commonKeywords.robot

Library     ../../../../Ulm/SyVe/CSV/libraries/common_tools.py          WITH NAME    common_tools



*** Variables ***

${TARGET_SW_VERSION}     ${EMPTY}



*** Keywords ***

Bring Hybrid AP TL To onAir
    [Arguments]  ${basic_setup_cfg}=basic_setup_ANR_XN_MESH.cfg   ${force_reboot}=${True}
    Log To Console    ${\n}INFO: Bringing Hybrid AP TL to onAir State ... (may take some time)
    Log To Console    ${\n}INFO: basic_setup_cfg = ${basic_setup_cfg}
    Log To Console    ${\n}INFO: force_reboot = ${force_reboot}
    ${branch}    commonKeywords.Get CURRENT_SW_BRANCH And Set It As Suite Variable
    ${testline}    testline.Get Testline Name
    ${wts_cfg_path}    Set Variable    /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/${branch}/${testline}/GNB-0/
    ${cfg_file_path}    Set Variable    /opt/wts/latest/basic_setup.cfg
    ${cfg_file_info_before}    OperatingSystem.Run    ls -l ${cfg_file_path}
    OperatingSystem.Run    cp -f ${wts_cfg_path}/${basic_setup_cfg} ${cfg_file_path}
    ${cfg_file_into_after}    OperatingSystem.Run    ls -l ${cfg_file_path}
    ${is_bringup_needed}    Set Variable    ${True}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    ${force_reboot}
        Bring Hybrid AP TL To OnAir Status    with_reboot=${True}
        ${does_sa_work}    Try SA UE Registration
        ${does_nsa_work}    Try NSA UE Attach
        ${is_tl_up_and_running}    Evaluate    ${does_sa_work} or ${does_nsa_work}
        Log To Console    ${\n}INFO: Hybrid AP TL is onAir and is_tl_up_and_running = ${is_tl_up_and_running}
        RETURN
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    TRY
        wts_ue.Connect To Running EGATE
        wts_ue.Send Egate Command And Verify Output    cmd=re
        Run Keyword And Ignore Error
        ...    wts_ue.Config WTS For Airphone    pass_regexp=CHANGE STATE: ACTIVE - SimMode is ready now    cfg_file=${cfg_file_path}    timeout=900s
        wts_ue.Setup X2 Link
        Sleep   5s   reason=waiting for Airphone stabilized
        ${does_sa_work}    Try SA UE Registration
        ${does_nsa_work}    Try NSA UE Attach
        ${is_bringup_needed}    Evaluate    not(${does_sa_work} or ${does_nsa_work})
    EXCEPT
        ${is_bringup_needed}    Set Variable    ${True}
    END
    Log To Console    ${\n}INFO: is Bringing Hybrid AP TL To onAir State needed? --> ${is_bringup_needed}
    IF    ${is_bringup_needed}
        TRY
            Log To Console    ${\n}INFO: try WITHOUT reboot
            Bring Hybrid AP TL To OnAir Status    with_reboot=${False}
        EXCEPT
            Log To Console    ${\n}INFO: do WITH reboot
            Bring Hybrid AP TL To OnAir Status    with_reboot=${True}
        END
    END


Try SA UE Registration
    TRY
        wts_ue.Send Egate Command And Verify Output    cmd=ue_register id=1 nwslice=1
        ...                                            pass_regexp=UE performed Registration
        ...                                            timeout=3s
        wts_ue.Send Egate Command And Verify Output    cmd=ue_deregister id=1 ue_deregister_type=switch_off
        ...                                            timeout=1s
        RETURN    ${True}
    EXCEPT
        RETURN    ${False}
    END


Try NSA UE Attach
    TRY
        wts_ue.Send Egate Command And Verify Output    cmd=ue_attach id=101 emergency=off pdn_connectivity_type=auto
        ...                                            pass_regexp=UE performed Registration
        ...                                            timeout=3s
        wts_ue.Send Egate Command And Verify Output    cmd=ue_detach id=101 ue type=not_specified ue_detach_type=automatic
        ...                                            timeout=1s
        RETURN    ${True}
    EXCEPT
        RETURN    ${False}
    END


Bring Hybrid AP TL To OnAir Status
    [Arguments]   ${with_reboot}   ${cfg_file}=${tl.core.cfg_filename}   ${capture_cell_setup_trace}=${False}   ${cell_setup_trace_dir}=${EMPTY}
    [Timeout]     30min
    IF    ${with_reboot}
        ute_workarounds.Bring Airphone TL To F1 Up Status
    ELSE
        gnb.Wait For Minimum Required State For Cell Setup For All GNBs    timeout=30min
        ute_workarounds.Modify SCTP Settings On Test-VM And AP
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF   ${capture_cell_setup_trace}   ute_workarounds.Start Trace On L2 PS CP RT Interface
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.Start WTS For Airphone
    ${egate_output_after_cfg_file}    wts_ue.Send Egate Command And Verify Output    cmd=cfg file=${cfg_file}
    ...                                                                              pass_regexp=CHANGE STATE: ACTIVE - SimMode is ready now
    ...                                                                              return_output=${True}
    ...                                                                              timeout=900s
    ${amf_is_not_ap}    Run Keyword And Return Status    Should Not Contain Any    ${egate_output_after_cfg_file}    AMF - IP:10.0.1.2 NG link is Up
    wts_ue.Setup X2 Link
    IF    ${amf_is_not_ap}
        Run Keyword And Ignore Error    wts_ue.Send Egate Command And Verify Output    cmd=amf_disp
        ...                                                                            pass_regexp=AMF - IP:10.0.1.2 NG link is Up
        ...                                                                            timeout=900s
    END
    wts_ue.Setup X2 Link
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    gnb.Wait Until All GNBs To Be OnAir State    timeout=2min
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Teardown]      ute_workarounds.Stop Trace On L2_PS CP_RT Interface If Started      capture_cell_setup_trace=${capture_cell_setup_trace}
    ...                                                                                 cell_setup_trace_dir=${cell_setup_trace_dir}

Get RU Info from TargetBD
    [Arguments]    ${ru_type}=AEQE
    ${gnb_alias}    connect.Connect To Node Common Unit
    ${file_path}    util.Get File Path on Target    file_pattern=/ffs/run/TargetBD*ENB*.xml    connection=${gnb_alias}
    ssh.download file    remote_path=${file_path}    local_path=${configuration_directory}/TargetBD.xml    connection=${gnb_alias}
    ssh.disconnect    ${gnb_alias}
    ${ru_version}  ${frm_sw}    common_tools.Get_Values_From_TargetBD    ${configuration_directory}/TargetBD.xml    ${ru_type}
    RETURN    ${ru_version}    ${frm_sw}


Modify IPHY XML For NEW SW Build
    ${ap_alias}    connect.Connect to Airphone Common Unit
    ssh.Download File    /rom/simmode/iphy.xml    ${configuration_directory}/iphy_original.xml    connection=${ap_alias}
        ${xml}    XML.Parse XML    ${configuration_directory}/iphy_original.xml
        ${ru_type}    XML.Get Element Text    ${xml}    .//cardName
        ${ru_version}  ${frm_sw}    Get RU Info from TargetBD    ru_type=${ru_type}
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${contents}    OperatingSystem.Get File    ${configuration_directory}/iphy_original.xml
        ${contents}    Replace String Using Regexp    ${contents}    bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${contents}    Replace String Using Regexp    ${contents}    buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${contents}    Replace String Using Regexp    ${contents}    name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${contents}    Replace String Using Regexp    ${contents}    version>.*<\/version>   version>${ru_version}<\/version>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        OperatingSystem.Create File    ${configuration_directory}/iphy_updated.xml    ${contents}
    ssh.Upload File    ${configuration_directory}/iphy_updated.xml    /rom/simmode/iphy.xml    connection=${ap_alias}
