*** Settings ***
Resource   Common.robot


*** Variables ***
${local_prepare_firmware}   ${CURDIR}/../Scripts/prepare-firmware.sh
${remote_prepare_firmware}   /ffs/run/prepare-firmware.sh
@{UBOOT_MODULE_LIST}   ASIA   ASIB   ABIA   ABIC
# ...   ASIAA   ASIBA   ASIAL   FSMF   FSIH   FBBC   FBIH   ABIAL
&{BIOS_MODULE_FILE}   ABIO=ASP-SNFB1-MC-BW   ABIN=ASP-SNFB1-MC-BW   ABIL=ASPA-MC-BW   ASIL=FCT-SNFB1-MC-BW   ASIK=FCT-MC-BW   ASOE=ASC-SNFB1-MC-BW
&{FPGA_MODULE_FILE}   ASIK=FCT-PC   ASOE=ASC-PCO8-BW


*** Keywords ***
UUF Downgrade Firmware
    [Arguments]   ${downgrade_sequence}=${UPGRADE_SEQUENCE}
    Log To Console   //TODO: UUF Downgrade Firmware
    &{needResetDict}   Create Dictionary
    FOR   ${testline}   IN   @{downgrade_sequence}
        ${needReset}   Single Testline Downgrade Firmware   testline=${testline}
        Set To Dictionary   ${needResetDict}   ${testline}=${needReset}
    END

    FOR   ${testline}   IN   @{downgrade_sequence}
        Continue For Loop If   not ${needResetDict["${testline}"]}
        ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
        ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
        ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
        COAM Login
        ...   bts_host=${webem_addr}
        ...   username=${webem_username}
        ...   password=${webem_password}
        ...   alias=${testline}
        Log To Console   Reset Site: ${testline}
        COAM Reset Site   wait_for_reconnection=${False}   connection=${testline}
    END

    Sleep   30s
    FOR   ${testline}   IN   @{downgrade_sequence}
        Continue For Loop If   not ${needResetDict["${testline}"]}
        # Wait Until Keyword Succeeds   20m   1m   UUF Wait Cell Onair   testline=${testline}
        # Wait Until Keyword Succeeds   5m   1m   UUF Wait X2 Link Status   testline=${testline}
        UUF Wait Times For Cell OnAir   testline=${testline}
    END
    [Teardown]   Run Keyword And Ignore Error   COAM Logout ALL Testline   testline_list=${downgrade_sequence}


Single Testline Downgrade Firmware
    [Arguments]   ${testline}
    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

    ${isDualCore}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['isDualCore']}
    ${primary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['primary_host']}
    ${secondary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['secondary_host']}


    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    ${PrimarySmodReset}   SMOD Update Firmware   connection=${testline}
    ${PrimaryBBmodReset}   BBMOD Update Firmware   connection=${testline}
    ${PrimaryReset}   Evaluate   ${PrimarySmodReset} or ${PrimaryBBmodReset}

    Return From Keyword If   not ${isDualCore}   ${PrimaryReset}

    # Secondary Core
    Run Keyword If   ${isDualCore}
    ...   csn.Connect to  hostname=${secondary_host}  username=${ssh_username}  password=${ssh_password}  proxy=${testline}  alias=${testline}_dual
    ${SecondarySmodReset}   SMOD Update Firmware   connection=${testline}_dual
    ${SecondaryBBmodReset}   BBMOD Update Firmware   connection=${testline}_dual
    ${SecondaryReset}   Evaluate   ${SecondarySmodReset} or ${SecondaryBBmodReset}

    ${needReset}   Evaluate   ${PrimaryReset} or ${SecondaryReset}
    [Return]   ${needReset}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${isDualCore}   csn.Disconnect   connection=${testline}_dual   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
SMOD Update Firmware
    [Arguments]   ${connection}
    csn.Upload File
    ...   local_path=${local_prepare_firmware}
    ...   remote_path=${remote_prepare_firmware}
    ...   connection=${connection}
    csn.Execute   command=chmod +x ${remote_prepare_firmware}   connection=${connection}

    Log To Console   ==============================================================================
    Log To Console   Update UBOOT And BIOS on System Board: [${connection}]
    ${needResetUBOOT}   Update UBOOT   connection=${connection}
    ${needResetBIOS}   Update BIOS   connection=${connection}
    ${needResetFPGA}   Update FPGA   connection=${connection}
    ${needReset}   Evaluate   ${needResetUBOOT} or ${needResetBIOS} or ${needResetFPGA}
    Log To Console   ==============================================================================
    [Return]   ${needReset}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
BBMOD Update Firmware
    [Arguments]   ${connection}
    ${needReset}   Set Variable   ${False}
    ${bbmod_ip_list}   Get BBMOD IPs   connection=${connection}
    FOR   ${bbmod_ip}   IN   @{bbmod_ip_list}
        Log To Console   ==============================================================================
        Log To Console   Update UBOOT And BIOS on Baseband Board: [${bbmod_ip}]
        ${needResetSingleBBMOD}   Single BBMOD Update Firmware   bbmod_ip=${bbmod_ip}   connection=${connection}
        ${needReset}   Set Variable If   ${needResetSingleBBMOD}   ${True}   ${needReset}
        Log To Console   ==============================================================================
    END
    [Return]   ${needReset}


Single BBMOD Update Firmware
    [Arguments]   ${bbmod_ip}   ${connection}
    csn.Connect to   hostname=${bbmod_ip}   username=${ssh_username}   password=${ssh_password}   alias=${bbmod_ip}   proxy=${connection}
    ${needResetUBOOT}   Update UBOOT   connection=${bbmod_ip}
    ${needResetBIOS}   Update BIOS   connection=${bbmod_ip}
    ${needResetSingleBBMOD}   Evaluate   ${needResetUBOOT} or ${needResetBIOS}
    [Return]   ${needResetSingleBBMOD}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${bbmod_ip}


Get BBMOD IPs
    [Arguments]   ${connection}
    ${ip_list}   Create List
    ${bbmod_ip_string}   csn.Execute   command=cat /etc/hosts | grep -iE 'asp-.a|fsp-.a'| awk '{print $1}'   connection=${connection}
    ${bbmod_ip_list}   Split To Lines   ${bbmod_ip_string}
    FOR   ${bbmod_ip}   IN   @{bbmod_ip_list}
        ${status}   csn.Execute   command=timeout 1s ping -c 1 ${bbmod_ip} > /dev/null 2>&1; echo $?   connection=${connection}
        ${status}   Strip String   ${status}
        Run Keyword If   "${status}"=="0"   Append To List   ${ip_list}   ${bbmod_ip}
    END
    Reverse List   ${ip_list}
    Log To Console   ${ip_list}
    [Return]   ${ip_list}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
Update UBOOT
    [Arguments]   ${connection}
    Log To Console   ------------------------------------------------------------------------------
    Log To Console   //TODO: Update UBOOT

    ${module_type}   csn.Execute
    ...   command=sysinfo 2>&1 | head -n10 | grep "ID_00_MODULE_ID_\\[0\\]" | awk -F "'" '{print $2}'   connection=${connection}
    ${module_type}   Strip String   ${module_type}
    Log To Console   module_type: ${module_type}
    Return From Keyword If   "${module_type}" not in ${UBOOT_MODULE_LIST}   ${False}

    ${check_version}   csn.Execute   command=${remote_prepare_firmware} -v   connection=${connection}
    Log To Console   Check Uboot Version: ${check_version}
    Return From Keyword If   "versions are different" not in '''${check_version}'''   ${False}

    Log To Console   Uboot Version Not Match. Performing Uboot Downgrade: [${module_type}]
    ${output}   csn.Execute   command=${remote_prepare_firmware}   connection=${connection}   timeout=${600}
    # Log To Console   ${output}

    ${check_version}   csn.Execute   command=${remote_prepare_firmware} -v   connection=${connection}
    Log To Console   ReCheck Uboot Version: ${check_version}
    Run Keyword If   "u-boot versions are the same" not in '''${check_version}'''   Log To Console   [Error] Uboot Downgrade Unsuccessfull.
    Return From Keyword If   "u-boot versions are the same" not in '''${check_version}'''   ${False}

    [Return]   ${True}


Update BIOS
    [Arguments]   ${connection}
    Log To Console   ------------------------------------------------------------------------------
    Log To Console   //TODO: Update BIOS

    ${module_type}   csn.Execute
    ...   command=sysinfo 2>&1 | head -n10 | grep "ID_00_MODULE_ID_\\[0\\]" | awk -F "'" '{print $2}'   connection=${connection}
    ${module_type}   Strip String   ${module_type}
    Log To Console   module_type: ${module_type}
    Return From Keyword If   "${module_type}" not in ${BIOS_MODULE_FILE}   ${False}


    ${hwapilog_compress}   csn.File Exists   remote_path=/tmp/startup_HWAPI.log.xz   connection=${connection}
    ${cat_cmd}   Set Variable If   ${hwapilog_compress}   xzcat /tmp/startup_HWAPI.log.xz   cat /tmp/startup_HWAPI.log

    ${bios_version}   csn.Execute   command=${cat_cmd} | grep 'running bios version'   connection=${connection}
    ${match}   ${running_bios_version}   ${binary_bios_version}   Should Match Regexp   ${bios_version}
    ...   running bios version (0x[0-9a-fA-F]+), binary version (0x[0-9a-fA-F]+)

    Log To Console   ${bios_version}
    Log To Console   running_bios_version: ${running_bios_version}
    Log To Console   binary_bios_version: ${binary_bios_version}

    ${cpu_type}   csn.Execute   command=cat /proc/cpuinfo | grep ste | head -n 1 | awk -F ' ' '{print $3}'   connection=${connection}
    ${cpu_type}   Strip String   ${cpu_type}
    ${downgrade_supported}   Set Variable If   "${cpu_type}" in ["3", "5", "7"]   ${True}   ${False}
    ${downgrade_needed}   Set Variable If   "${running_bios_version}" not in "${binary_bios_version}"   ${True}   ${False}
    Return From Keyword If   not (${downgrade_supported} and ${downgrade_needed})   ${False}

    ${bios_file_prefix}   Get Variable Value   ${BIOS_MODULE_FILE["${module_type}"]}   ${EMPTY}
    Return From Keyword If   "${bios_file_prefix}"==""   ${False}

    ${bios_file_name_path}   csn.Execute   command=find /ffs/run/swpool/LFS -iname ${bios_file_prefix}*.bin   connection=${connection}
    ${bios_file_name_path}   Strip String   ${bios_file_name_path}
    Log To Console   Update BIOS Command: update_bios.sh -F -D ${bios_file_name_path}

    ${bios_output}   csn.Execute   command=update_bios.sh -F -D ${bios_file_name_path}   connection=${connection}   timeout=${600}
    # Log To Console   ${bios_output}
    Run Keyword If   "Successfully updated bios on bootflash" not in '''${bios_output}'''   Log To Console   [Error] BIOS Downgrade Unsuccessfull.
    Return From Keyword If   "Successfully updated bios on bootflash" not in '''${bios_output}'''   ${False}

    [Return]   ${True}


Update FPGA
    [Arguments]   ${connection}
    Log To Console   ------------------------------------------------------------------------------
    Log To Console   //TODO: Update FPGA

    ${module_type}   csn.Execute
    ...   command=sysinfo 2>&1 | head -n10 | grep "ID_00_MODULE_ID_\\[0\\]" | awk -F "'" '{print $2}'   connection=${connection}
    ${module_type}   Strip String   ${module_type}
    Log To Console   module_type: ${module_type}
    Return From Keyword If   "${module_type}" not in ${FPGA_MODULE_FILE}   ${False}

    ${fpga_file_prefix}   Get Variable Value   ${FPGA_MODULE_FILE["${module_type}"]}   ${EMPTY}
    Return From Keyword If   "${fpga_file_prefix}"==""   ${False}

    ${fpga_file_name_path}   csn.Execute   command=find /ffs/run/swpool/LFS -iname ${fpga_file_prefix}*.bin   connection=${connection}
    ${fpga_file_name_path}   Strip String   ${fpga_file_name_path}

    ${check_fpga_upgrade}   csn.Execute   command=fsm_fpga_upgrade -c ${fpga_file_name_path}   connection=${connection}
    ${check_fpga_upgrade}   Strip String   ${check_fpga_upgrade}
    Return From Keyword If   "upgrade needed" not in '''${check_fpga_upgrade}'''   ${False}

    ${fpga_output}   csn.Execute   command=fsm_fpga_upgrade -f ${fpga_file_name_path}   connection=${connection}   timeout=${600}
    Run Keyword If   "upgrade was successful" not in '''${fpga_output}'''   Log To Console   [Error] FGPA Downgrade Unsuccessfull.
    Return From Keyword If   "upgrade was successful" not in '''${fpga_output}'''   ${False}

    # Run Keyword If   "upgrade was successful" in '''${fpga_output}'''
    # ...   csn.Send Command   command=fsm_fpga_upgrade -reconfig   connection=${connection}

    [Return]   ${True}
