*** Settings ***
Documentation
...              Suite for all CB009484-B testcases
...              test automation author: Robert Rozanski
...              contact: robert.rozanski@nokia.com

Resource        ../Resources/CB009484-Keywords.robot
Resource        ../../../common_resources/alarms/alarm.robot
Resource        ../../../common_resources/admin/bts_operations.robot
Resource        ../../../common_resources/admin/admin.robot
Resource        ../../../common_resources/commissioning/commissioning.robot

Library    taf.transport.ssh        WITH NAME   ssh
Library    taf.fdsw.rc    WITH NAME    fdsw
Library    ../Resources/utils.py
Library    Process

*** Variables ***
${BTS_ID}=                              ${tl.gnbs[0].global_bts_id}
${SW_path}=                             /home/ute/Downloads
${SW_PACKAGE_25R2}=                     SBTS25R2_ENB_0000_000539_000000
${SW_PACKAGE_25R3}=                     SBTS00_ENB_9999_250624_000011
${SW_DOWNLOAD_LINK}=                    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
@{mplane}=                              localIpAddrAllocated
@{System_Module_parameter_on_Webem}=    productName

*** Keywords ***

Enable actPtiAndSpectreV2KernelFlag and check flags
    [Documentation]    Keyword enable parameter actPtiAndSpectreV2KernelFlag on Webem and checks flags
    ...                spectreV2KernelState and ptiKernelState - should be enable
    coam_admin.Setup Admin                          bts_host=192.168.255.129    name=Connection_Webem
    Check parameter actPtiAndSpectreV2KernelFlag    False
    coam_admin.Perform Parameter Recommissioning
    ...    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    actPtiAndSpectreV2KernelFlag    update     true    connection=Connection_Webem
    coam_admin.reset_site    connection=Connection_Webem
        Check parameter actPtiAndSpectreV2KernelFlag    True
    ${has_bbmod} =    Check if TL have BB    connection=Connection_Webem
    IF      ${has_bbmod}
       Check flags spectreV2KernelState and ptiKernelState from Webem with enable actPtiAndSpectreV2KernelFlag
       ...    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1    SM
       Log      This SM doesn't have BB       console=True
    ELSE
        Check flags spectreV2KernelState and ptiKernelState from Webem with enable actPtiAndSpectreV2KernelFlag
    ...    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1    SM
    Wait Until Keyword Succeeds  2 min    30 sec
    ...    Check flags spectreV2KernelState and ptiKernelState from Webem with enable actPtiAndSpectreV2KernelFlag
    ...    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1    BB
    END
    Wait Until Keyword Succeeds     2 min    30 sec
    ...                             Check If BTS Status Is Configured Or OnAir    connection=Connection_Webem
    [Teardown]                      coam_admin.Teardown    Connection_Webem

Checking by SSH spectre and pti
    [Documentation]                     Keyword checks vulnerabilities spectre v2 and pti on Linux kernel on BTS
    ${ssh_conn}                         Connect to BTS
    ${vulnerabilities}                  Set Variable                    cat /sys/devices/system/cpu/vulnerabilities/spectre_v2
    ${output_vulnerabilities}           ssh.execute                     ${vulnerabilities}      connection=${ssh_conn}
    Log                                 ${output_vulnerabilities}       console=True
    Should Contain                      ${output_vulnerabilities}       Mitigation
    ${check_spectre_pti}                Set Variable                    cat /proc/cmdline
    ${output_spectre_pti}               ssh.execute                     ${check_spectre_pti}    connection=${ssh_conn}
    Log                                 ${output_spectre_pti}           console=True
    Should Contain                      ${output_spectre_pti}           pti=on spectre_v2=on
    [Teardown]                          Disconnect from BTS             ${ssh_conn}

Disable actPtiAndSpectreV2KernelFlag and check flags
    [Documentation]    Keyword disable parameter actPtiAndSpectreV2KernelFlag on Webem and checks flags
    ...                spectreV2KernelState and ptiKernelState - should be disable
    coam_admin.Setup Admin                          bts_host=192.168.255.129    name=Connection_Webem
    Check parameter actPtiAndSpectreV2KernelFlag    True
    coam_admin.Perform Parameter Recommissioning
    ...    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    actPtiAndSpectreV2KernelFlag    update     false    connection=Connection_Webem
    coam_admin.reset_site    connection=Connection_Webem
    Check parameter actPtiAndSpectreV2KernelFlag    False
    ${has_bbmod} =    Check if TL have BB    connection=Connection_Webem
    IF      ${has_bbmod}
       Check flags spectreV2KernelState and ptiKernelState from Webem with disable actPtiAndSpectreV2KernelFlag
       ...    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1    SM
       Log      This SM doesn't have BB       console=True
    ELSE
        Check flags spectreV2KernelState and ptiKernelState from Webem with disable actPtiAndSpectreV2KernelFlag
        ...    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1    SM
        Check flags spectreV2KernelState and ptiKernelState from Webem with disable actPtiAndSpectreV2KernelFlag
        ...    MRBTS-${BTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1    BB
    END
    Wait Until Keyword Succeeds  2 min    30 sec
    ...                         Check If BTS Status Is Configured Or OnAir    connection=Connection_Webem
    [Teardown]    coam_admin.Teardown    Connection_Webem

Prepare_TL_for_rollback
    [Documentation]    Keyword prepare TL to test with rollback - Update_from_N-1_to_N_release_and_rollback
    ...                 after this there is 25R2 on passive partition and 25R3
    coam_admin.Setup Admin  bts_host=192.168.255.129    name=Connection_Webem
    Perform Configuration Reset
    coam_admin.Teardown    Connection_Webem
    ${download_SW_25R2}  Set Variable
    ...    wget -P ${SW_path} "${SW_DOWNLOAD_LINK}/SBTS25R2/${SW_PACKAGE_25R2}/${SW_PACKAGE_25R2}_release_BTSSM_downloadable_A54.zip"
    ${output}    Run  ${download_SW_25R2}
    Wait Until Keyword Succeeds     20 min    30 sec
    ...                             fdsw.connect_to  ip_address=192.168.255.129
    ...                             port=443  username=Nemuadmin  password=nemuuser
    fdsw.software_update    ${SW_path}/${SW_PACKAGE_25R2}_release_BTSSM_downloadable_A54.zip    activate=True
    Wait Until Keyword Succeeds    20 min    30 sec
    ...                             coam_admin.Setup Admin  bts_host=192.168.255.129    name=Connection_Webem
    ${new_scf_path}   Set Variable    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T02/features/CB009484/Resources/scf.xml
    Commission SCF    scf_file=${new_scf_path}    skip_parameter_relation_errors=False    connection=Connection_Webem
    Wait Until Keyword Succeeds  20 min    30 sec
    ...                         Check If BTS Status Is Configured Or OnAir    connection=Connection_Webem
    Install Software On BTS    ${SW_path}/${SW_PACKAGE_25R2}_release_BTSSM_downloadable_A54.zip    connection=Connection_Webem
    Wait Until Keyword Succeeds  20 min    30 sec
    ...                         Check If BTS Status Is Configured Or OnAir    connection=Connection_Webem
    ${download_SW_25R3}  Set Variable
    ...    wget -P ${SW_path} "${SW_DOWNLOAD_LINK}/SBTS00/${SW_PACKAGE_25R3}/${SW_PACKAGE_25R3}_release_BTSSM_downloadable_A54.zip"
    ${output}    Run  ${download_SW_25R3}
    Install Software On BTS    ${SW_path}/${SW_PACKAGE_25R3}_release_BTSSM_downloadable_A54.zip    connection=Connection_Webem
    Wait Until Keyword Succeeds  20 min    30 sec
    ...                         Check If BTS Status Is Configured Or OnAir    connection=Connection_Webem
    [Teardown]    Run Keywords
                  ...    Run    rm -rf /home/ute/Downloads/*downloadable_A54.zip
                  ...    AND    coam_admin.Teardown    Connection_Webem

Update_from_N-1_to_N_release_and_rollback_next_check_pti_and_spectre_v2_kernel_flag_from_WebEM
    [Documentation]    Keyword checks parameter actPtiAndSpectreV2KernelFlag on Webem and checks flags
    ...                spectreV2KernelState and ptiKernelState on 25R2
    coam_admin.Setup Admin  bts_host=192.168.255.129    name=Connection_Webem
    Check parameter actPtiAndSpectreV2KernelFlag    False
    coam_admin.Perform Parameter Recommissioning
    ...                         MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                         actPtiAndSpectreV2KernelFlag    update     true    connection=Connection_Webem
    coam_admin.reset_site    connection=Connection_Webem
    Wait Until Keyword Succeeds  20 min    30 sec
    ...                         Check If BTS Status Is Configured Or OnAir    connection=Connection_Webem
    coam_admin.wait_sw_update_possible  readiness_timeout=1000    timeout=1200  connection=Connection_Webem
    Check parameter actPtiAndSpectreV2KernelFlag    True
    ${Type_of_SM1}    coam_admin.get_parameter_by_distname          MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...                                                             ${System_Module_parameter_on_Webem}    connection=Connection_Webem
    ${Type_of_SM2}    Get From Dictionary    ${Type_of_SM1}[0]      parameters
    ${Type_ofSM3}     Get From Dictionary    ${Type_of_SM2}         productName
    IF      '${Type_of_SM3}' == 'ASOF AirScale Core' or '${Type_of_SM3}' == 'ASOE AirScale Core' or '${Type_of_SM3}' == 'ASOH AirScale Core'
       Check flags spectreV2KernelState and ptiKernelState from Webem with enable actPtiAndSpectreV2KernelFlag
       ...    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1    SM
       Log      This SM doesn't have BB       console=True
    ELSE
        Check flags spectreV2KernelState and ptiKernelState from Webem with enable actPtiAndSpectreV2KernelFlag
    ...    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1    SM
    Check flags spectreV2KernelState and ptiKernelState from Webem with enable actPtiAndSpectreV2KernelFlag
    ...    MRBTS-${BTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1    BB
    END
    coam_admin.Perform Parameter Recommissioning
    ...                                             MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                             actPtiAndSpectreV2KernelFlag    update     false    connection=Connection_Webem
    coam_admin.reset_site                           connection=Connection_Webem
    Wait Until Keyword Succeeds                     20 min    30 sec
    ...                                             Check If BTS Status Is Configured Or OnAir    connection=Connection_Webem
    coam_admin.wait_sw_update_possible              readiness_timeout=1000    timeout=1200  connection=Connection_Webem#
    coam_admin.rollback_software                    timeout=2400  connection=Connection_Webem
    coam_admin.Teardown                             Connection_Webem
    Wait Until Keyword Succeeds                     20 min    30 sec
    ...                                             coam_admin.Setup Admin  bts_host=192.168.255.129    name=Connection_Webem
    Wait Until Keyword Succeeds                     20 min    30 sec
    ...                                             Check If BTS Status Is Configured Or OnAir    connection=Connection_Webem
    coam_admin.wait_sw_update_possible              readiness_timeout=1000    timeout=1200  connection=Connection_Webem
    Check parameter actPtiAndSpectreV2KernelFlag    False
    Run Keyword And Expect Error                    *ErrorCode: 23*
    ...    coam_admin.Perform Parameter Recommissioning
    ...    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    actPtiAndSpectreV2KernelFlag    update     true    connection=Connection_Webem
    IF      '${Type_of_SM3}' == 'ASOF AirScale Core' or '${Type_of_SM3}' == 'ASOE AirScale Core' or '${Type_of_SM3}' == 'ASOH AirScale Core'
       Check flags spectreV2KernelState and ptiKernelState from Webem actPtiAndSpectreV2KernelFlag Negative
       ...    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1    SM
       Log      This SM doesn't have BB       console=True
    ELSE
        Check flags spectreV2KernelState and ptiKernelState from Webem actPtiAndSpectreV2KernelFlag Negative
    ...    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1    SM
    Check flags spectreV2KernelState and ptiKernelState from Webem actPtiAndSpectreV2KernelFlag Negative
    ...    MRBTS-${BTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1    BB
    END
    [Teardown]    coam_admin.Teardown    Connection_Webem

Negative_scenario_pti_and_spectre_v2_kernel_flag_from_WebEM
    [Documentation]    Keyword enable parameter actPtiAndSpectreV2KernelFlag on Webem and checks flags
    ...                spectreV2KernelState and ptiKernelState on unsupported hardware
    coam_admin.Setup Admin                          bts_host=192.168.255.129    name=Connection_Webem
    Check parameter actPtiAndSpectreV2KernelFlag    False
    coam_admin.Perform Parameter Recommissioning
    ...    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    actPtiAndSpectreV2KernelFlag    update     true    connection=Connection_Webem
    coam_admin.reset_site                           connection=Connection_Webem
    Wait Until Keyword Succeeds                     20 min    30 sec
    ...                         Check If BTS Status Is Configured Or OnAir    connection=Connection_Webem
    Check parameter actPtiAndSpectreV2KernelFlag    False
    Check flags spectreV2KernelState and ptiKernelState from Webem actPtiAndSpectreV2KernelFlag ASIM
    ...    MRBTS-${BTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1    SM
    Check flags spectreV2KernelState and ptiKernelState from Webem actPtiAndSpectreV2KernelFlag ASIM
    ...    MRBTS-${BTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1    BB
    [Teardown]    coam_admin.Teardown    Connection_Webem

Run Hping3
    [Documentation]     Keyword runs Hping3 on mplane on UDP, TCP, ICMP
    ...                 --interval u300   -   bedzie wysylac pakiet co 0.3 milisekundy.
    ...                 3300 pakiet na sekunde wytrzymuje
    [Arguments]    ${command}
    coam_admin.Setup Admin  bts_host=192.168.255.129    name=Connection_Webem
    ${List_with_mplane}    coam_admin.get_parameter_by_distname
    ...    MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1/IPADDRESSV4_R-1     ${mplane}    connection=Connection_Webem
    log    ${List_with_mplane}    console=True
    ${Get_mplane_parameter}    Get From Dictionary    ${List_with_mplane}[0]    parameters
    log    ${Get_mplane_parameter}    console=True
    ${local_ip}    Get From Dictionary    ${Get_mplane_parameter}    localIpAddrAllocated
    ${output}    Run Process    ${command} ${local_ip}     timeout=2sec
    ...    on_timeout=terminate    shell=True
    Check That The BTS Is Fully Operational    connection=Connection_Webem
    No Faults Except Allowed Should Be Present On BTS

    match string     ${output.stderr}
    [Return]         ${output.stdout}
    [Teardown]       coam_admin.Teardown    Connection_Webem
