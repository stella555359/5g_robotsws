*** Settings ***
Documentation
...  Author:        Tomasz Mozola
...  Contact:       tomasz.mozola@nokia.com
...  Description:   Suite Setup/Teardown and Test Setup/Teardown

Library     taf.ue
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.transport.ssh          WITH NAME    ssh
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pdu.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/TTIDecoderInstaller.py    WITH NAME    tti
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_SFE.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/tests_CB007090.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.robot


*** Variables ***
@{UE}                  UE_1
@{MULTI_UE}            UE_1   UE_2
${temp_WRO7_dir}       testsuite/Wroclaw/RRM/VRF_WRO2_T01
${SCF_8954}            ${temp_WRO7_dir}/CB008954/resources/SCFs/${MRBTS_5G_ID}/${MRBTS_5G_ID}_ute151_8954_SBTS25R2.xml
${SCF_8954_25R1}       ${temp_WRO7_dir}/CB008954/resources/SCFs/${MRBTS_5G_ID}/${MRBTS_5G_ID}_ute151_8954_SBTS25R1.xml
${SCF_8954_24R2}       ${temp_WRO7_dir}/CB008954/resources/SCFs/${MRBTS_5G_ID}/${MRBTS_5G_ID}_ute151_8954_SBTS24R2.xml
${SCF_8954_24R3}       ${temp_WRO7_dir}/CB008954/resources/SCFs/${MRBTS_5G_ID}/${MRBTS_5G_ID}_ute151_8954_SBTS24R3.xml
${SCF_8954H}           ${temp_WRO7_dir}/CB008954/resources/SCFs/${MRBTS_5G_ID}/${MRBTS_5G_ID}_ute151_8954_H.xml
${root_scf_path}       testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008954/resources/SCFs/${MRBTS_5G_ID}/${MRBTS_5G_ID}_ute151_8954

*** Keywords ***
#**************************************************CB008954************************************************************
Suite Setup For 8954
    common_kw.Connect to gNB and eNB
    Download SCF
    Upload SCF with proper release
    Require Ue    UE_1    capabilities=RFCX201F8VD
    common_kw.Setup attenuators
    common_kw.Turn off attenuation
    Log To Console    Suite Setup done

Suite Teardown For 8954
    common_kw.Verify if all cells are onair
    Log To Console    Suite Teardown done

Test Setup For 8954
    [Arguments]    ${if_samode}=${FALSE}    ${is_item_H}=${FALSE}
    Run Keyword If    ${is_item_H} == ${TRUE}    common_kw.Upload scf and perform commissioning  ${SCF_8954H}
    Run Keyword If    ${if_samode} == ${TRUE}    Lock all LTE cells
    Download SCF
    Start syslog capture
    taf.ue.reboot ue  UE_1  300
    taf.ue.detach ue  UE_1
    Log To Console    Test Setup done

Test Teardown For 8954
    [Arguments]    ${if_samode}=${FALSE}    ${recomm}=${FALSE}    ${is_item_H}=${FALSE}
    Run keyword if test failed   Collect counters
    run keyword and ignore error    Stop all datatransfers
    taf.ue.detach ue  UE_1
    Run Keyword If    ${is_item_H} == ${TRUE}    Get and upload default SCF
    Run Keyword If    ${if_samode} == ${TRUE}    Unlock all LTE locked cells
    Collect snapshot if test failed
    Run Keyword If    ${recomm} == ${TRUE}    Recommission to default
    Stop syslog capture
    common_kw.Turn off attenuation
    ssh.reset_cache
    Add Scout Data Info To Testcase
    Log To Console    Test Teardown done

Upload SCF with proper release
    coam.Connect to  name=get_sw_name
    ${release_name}  coam.Get Sw Release Name  connection=get_sw_name
    ${scf_path}  set variable  ${root_scf_path}_${release_name}.xml

    common_kw.Upload scf and perform commissioning  ${scf_path}
    Check and install incompatible sw
    common_kw.Verify if all cells are onair
    [Teardown]  coam.Teardown  connection=get_sw_name

#*********************************************TRUNK FDD CIT************************************************************

Suite Setup FDD CIT
    setup_teardown.Get BTS id and set as suite variable
    Remove tmp btslog dir
    Setup attenuators
    taf.ue.Require Ue  UE  capabilities=SamsungS22

Suite Teardown FDD CIT
    Suite cOAM Teradown

Test Setup FDD CIT
   Start syslog capture
   Verify if all cells are onair
#   taf.ue.reboot ue    UE    180
   Fast L3Call Check

Test Teardown FDD CIT
    Add Scout Data Info To Testcase
    Collect snapshot if test failed
    Stop syslog capture
    interface.Common step trigger
    Turn off attenuation
    ssh.reset_cache

#*********************************************TRUNK FDD ***************************************************************

Suite Setup FDD
    setup_teardown.Set BTS and cell ids as suite variables
    Setup attenuators
    Turn off attenuation
    taf.ue.Require Ue    AT_BASED_UE_1    capabilities=SamsungS22
    Remove tmp btslog dir

Suite Teardown FDD
    Suite cOAM Teradown

Test Setup FDD
    Download SCF
    Start syslog capture
    Verify if all cells are onair
    taf.ue.reboot ue    AT_BASED_UE_1    180
    taf.ue.Require Ue    AT_BASED_UE_1    capabilities=SamsungS22

Test Teardown FDD
    Add Scout Data Info To Testcase
    Collect snapshot if test failed
    Recommission to default
    Stop syslog capture
    interface.Common step trigger
    Turn off attenuation
    ssh.reset_cache

#*********************************************trunk-power-saving*******************************************************

Suite Setup power saving
    Connect to gNB and eNB
    Get UEs   ${UE}   REAL_UE
    Setup attenuators
    Turn off attenuation

Test Setup power saving
    run keyword and ignore error  Connect to gNB and eNB
    Download gNB and eNB SFCs
#    taf.ue.reboot ue  UE_1  180
    setup_teardown.Start syslog capture

Test Teardown power saving
    Run keyword if test failed   Collect counters
    setup_teardown.Collect snapshot if test failed
    setup_teardown.Stop syslog capture
    Turn off attenuation
    ssh.reset_cache
    Add Scout Data Info To Testcase
    Recommission gNB and eNB in background

#*********************************************trunk counters***********************************************************

Suite Setup counters
    Upload SCF with proper release
    Get UEs   ${UE}   REAL_UE_SA
    Setup attenuators
    Turn off attenuation
    Connect to gNB and eNB

Test Setup counters
    Start syslog capture
    Download SCF
    taf.ue.reboot ue    UE_1    180
    Detach UEs from cell    ${UE}

Test Teardown counters
    Add Scout Data Info To Testcase
    Run keyword if test failed   Collect counters
    Unlock Cells
    Collect snapshot if test failed
    Recommission to default
    Stop syslog capture
    Turn off attenuation
    ssh.reset_cache

#*********************************************TRUNK TPUT**************************************************************

Suite Setup Tput
    setup_teardown.Set BTS and cell ids as suite variables
    Setup attenuators
    Remove tmp btslog dir
    common_kw.Setup tcpdump collector
    Require Ue  UE  capabilities=SamsungS22

Suite Teardown Tput
    Suite cOAM Teradown

Test Setup Tput
    Start syslog capture
    Verify if all cells are onair
    Download SCF
    reboot ue    UE    180

Test Teardown Tput
    Add Scout Data Info To Testcase
    Collect snapshot if test failed
    Stop syslog capture
    interface.Common step trigger
    Turn off attenuation
    ssh.reset_cache

#*********************************************TRUNK WPT AVQL***********************************************************

Suite Setup WPT
#    log to console    Used UE library: ${ue_lib}
    Prepare testline WPT PS6
    Setup TTI Trace Collection
    common_kw.Setup tcpdump collector
    tti.download and install
    Get UEs  ${MULTI_UE}

Test Setup WPT
    Start syslog capture
    Download SCF

Test Teardown WPT
    taf.ue.Stop data transfers for all ues
    run keyword and ignore error    Disable TTI Trace
    Collect snapshot if test failed
    Stop syslog capture
    Add Scout Data Info To Testcase
    Recommission to default

#*********************************************5GC002139****************************************************************

Suite Setup 5GC002139
    setup_teardown.Get BTS id and set as suite variable
    taf.ue.Require Ue  AT_BASED_UE_1  capabilities=OPERATORO

Test Setup 5GC002139
    Start syslog capture
    Download SCF
    Verify if all cells are onair

Test Teardown 5GC002139
    Collect Snapshot
    Add Scout Data Info To Testcase
    Recommission to default
    Stop syslog capture


#*********************************************CB007090*****************************************************************

Suite Setup CB007090
    setup_teardown.Get BTS id and set as suite variable

Test Setup CB007090
    Get UEs  ${MULTI_UE}  ue_capabilities=7090_UE

Test Teardown CB007090
    Unlock all locked cells
    run keyword and ignore error  taf.ue.Stop data transfers for all ues
    Add Scout Data Info To Testcase
    Collect snapshot if test failed

#*********************************************CB013206*****************************************************************

Suite Setup CB013206
    power on testline
    sleep    3m
    Prepare testline before test
    Connect to gNB and eNB
    Download gNB and eNB SFCs
    Get UEs   ${UE}   REAL_UE
    Setup attenuators
    Turn off attenuation

Suite Teardown CB013206
    Recommission gNB and eNB in background
    power off testline
    Log To Console    Suite Teardown done

Test Setup CB013206
    Download SCF
    Start Syslog Capture

Test Teardown CB013206
    taf.ue.Stop data transfers for all ues
    Collect Snapshot if test failed
    Recommission to default
    Stop syslog capture
    Add Scout Data Info To Testcase
    Turn off attenuation

#*********************************************5GC002300****************************************************************

Suite Setup for 5GC002300
    setup_teardown.Set BTS and cell ids as suite variables
    Setup attenuators
    Turn off attenuation
    taf.ue.Require Ue    AT_BASED_UE_1    capabilities=SamsungS22
    Remove tmp btslog dir

Suite Teardown for 5GC002300
    Suite cOAM Teradown

Test Setup for 5GC002300
    Download SCF
    Start syslog capture
    Verify if all cells are onair
    taf.ue.reboot ue    AT_BASED_UE_1    180


Test Teardown for 5GC002300
    Add Scout Data Info To Testcase
    Collect snapshot if test failed
    Recommission to default
    Stop syslog capture
    interface.Common step trigger
    Turn off attenuation
    ssh.reset_cache

#*********************************************5GC001013****************************************************************

Suite Setup for 5GC001013
    setup_teardown.Set BTS and cell ids as suite variables
    Setup attenuators
    Turn off attenuation
    taf.ue.Require Ue    AT_BASED_UE_1    capabilities=SamsungS22
    Remove tmp btslog dir

Suite Teardown for 5GC001013
    Suite cOAM Teradown

Test Setup for 5GC001013
    Download SCF
    Start syslog capture
    Verify if all cells are onair
    taf.ue.reboot ue    AT_BASED_UE_1    180


Test Teardown for 5GC001013
    Add Scout Data Info To Testcase
    Collect snapshot if test failed
    Recommission to default
    Stop syslog capture
    interface.Common step trigger
    Turn off attenuation
    ssh.reset_cache

#*********************************************CB013553******************************************************************

Suite Setup for CB013553
    Remove tmp btslog dir

Suite Teardown for CB013553
    Suite cOAM Teradown

Test Setup for CB013553
   [Arguments]       ${if_Sub_D}=${FALSE}
   Run Keyword If    ${if_Sub_D} == ${TRUE}    Download SCF
   Start syslog capture

Test Teardown for CB013553
    [Arguments]    ${recomm}=${FALSE}
    Add Scout Data Info To Testcase
    Collect snapshot if test failed
    Run Keyword If    ${recomm} == ${TRUE}    Recommission to default
    Stop syslog capture
    interface.Common step trigger
    ssh.reset_cache

#*********************************************CB008204******************************************************************

Suite Setup for CB008204
    Upload SCF with proper release
    Get UEs   ${UE}   REAL_UE_SA
    Setup attenuators
    Turn off attenuation
    Connect to gNB and eNB

Test Setup for CB008204
   Start syslog capture
   Download SCF
   taf.ue.reboot ue    UE_1    180
   Detach UEs from cell    ${UE}

Test Teardown for CB008204
    Add Scout Data Info To Testcase
    Run keyword if test failed   Collect counters
    Unlock Cells
    Collect snapshot if test failed
    Recommission to default
    Stop syslog capture
    Turn off attenuation
    ssh.reset_cache

#*********************************************CB009543*******************************************************
Suite Setup for CB009543
    common_kw.Setup attenuators
    common_kw.Turn on attenuation

Test Setup for CB009543
    setup_teardown.Start syslog capture

Test Teardown for CB009543
    Run keyword if test failed   Collect counters
    setup_teardown.Collect snapshot if test failed
    setup_teardown.Stop syslog capture
    ssh.reset_cache
    common_kw.Turn on attenuation
    Add Scout Data Info To Testcase

Suite Teardown for CB009543
    Collect Snapshot
