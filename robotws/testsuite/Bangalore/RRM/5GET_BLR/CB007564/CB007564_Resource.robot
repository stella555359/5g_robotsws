
*** Settings ***
Documentation       copyright nokia
Library          ./resources/python/l1b_tag_gnb.py
Library          ./resources/python/lib.py
Library          ./resources/python/read_csv.py
Resource        ../resources/NPS/SWENG/robot/Tools.robot
Resource        ../resources/NPS/SWENG/robot/Connect.robot
Library         ../resources/NPS/SWENG/python/Container.py
Resource         ../resources/NPS/SWENG/robot/Container.robot
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library           luashark_tools.analyzer       WITH NAME       analyze
Resource          ../resources/NPS/SWENG/robot/CaptureFilter.robot
Library           ../resources/NPS/SWENG/python/StringTool.py
Variables         ../resources/NPS/SWENG/python/ReadConfig.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/PM_Counters.py

*** Variables ***
&{P_MEAS_PERIOD}        &{EMPTY}
&{P_START_TIME}         &{EMPTY}
${P_console}            ${False}
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
&{AP_ABIL}                 ip=192.168.253.85    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAbil
${CMD_OPEN_CP_DEBUG}       echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
${CMD_KILL_BIP_PROCESS}    pkill -9 tcpdump
${RD_PARAM_BRANCH}         SEPARATOR=${EMPTY}    # CP Debug;CCEsplit
${RD_PARAM}                SEPARATOR=${EMPTY}    # CP Debug;CCEsplit
${RD_PAR_ACSI}             SEPARATOR=${EMPTY}
${RD_PAR_ACSI_BRANCH}      SEPARATOR=${EMPTY}
${RD_PAR_AP_BRANCH}        SEPARATOR=${EMPTY}
${RD_dss_7859}             SEPARATOR=${EMPTY}
${RD_dss_7859_BRANCH}      SEPARATOR=${EMPTY}
${SCF_PATH}                ${CURDIR}/resources/config
${port}                    22
${PRB_LIST_20M_50_50}      1,50
${PRB_LIST_15M_50_50}      1,50
${ALLOC_SUBFRAME_20M}      0010101010-0100001000-0011101110-0000000110-0011100010-0111101110-0011101110-0000000010
${ALLOC_SUBFRAME_15M}      0010000000-0111101000-0011100000-0111100000-0010000000-0000001100-0000000000-0100000000
${ue_id}                    11
${LOG_PATH}                  /tmp/btslogs/CFRA
${Filter_cellsetupreq}      x2ap

&{SCRIPTDEF_MIRROR_AP_FS}           host=${AIRSCALE_AP.sys[0].M}
...                                 names=apMirroring.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh apMirroring.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}  host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring.sh,gnbMirroringConfig.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=/ffs/run/config/scripts/gnbMirroring.sh
...                                 commonMirrorScript=True

&{SCRIPTDEF_MIRROR_GNB_FS_BO_2slot}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring_ABIO_2slot_right_BIP_FS.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring_ABIO_2slot_right_BIP_FS.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_GNB_FS_CPRT_BO_2slot}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring_ABIO_2slot_right_CPRT_FS.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring_ABIO_2slot_right_CPRT_FS.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_GNB_L1B_BO}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring_ASIB_ABIO_L1Bypass.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring_ASIB_ABIO_L1Bypass.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_GNB_L1B_BL}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring.sh
...                                 commonMirrorScript=True

&{SCRIPTDEF_MIRROR_GNB_L1B_LO}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring_ASIL_ABIO_L1Bypass.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring_ASIL_ABIO_L1Bypass.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_AP_ASOE}         host=${AIRSCALE_AP.sys[0].M}
...                                 names=apMirroringASOE.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh apMirroringASOE.sh
...                                 commonMirrorScript=False

# CAPTURE                         : Dictionaries, that should contain:
#   isMirror  : toogle indicating if a mirroring should be previously done via script
#   scriptDef : reference to sxript def  structure
#   host      : reference to host on which capture should be launched
#   interface : interface on which capture will be launched (tcpdump -i <interface>)
#   prefix    : first part of pcap file name
#   name      : full name (without extension) if pcap file name. (Set during Init)
#   path      : full path of pcap once captured and uploaded on test VM. It is set at capture stop
#   withTN    : Indicate if test name should be embeded in pcap file name
#   filter    : filter for tcpdump
#
# Capture launched on CPIF during SgNB Addition PRACH : Kept for old Cloud code compatibility
&{CAPTURE_SCTP_CLOUD}               host=${HOST_GNB_CPIF}                   isNode=${False}
...                                 interface=any sctp
...                                 isMirror=False                          scriptDef=
...                                 prefix=SCTP_CLOUD                       name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

#==========================================================================================
# CAPTURE STRUCTURES
#==========================================================================================
#-----------------------------------
# CAPTURE for CORE
#-----------------------------------
# Add of interface FP0 to support ASIK
&{CAPTURE_CORE_GNB_SYS0_FP0}        host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=fp0
...                                 isMirror=False                          scriptDef=
...                                 prefix=CORE_GNB_SYS0_M_FP0              name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
# Add of interface eth1 on WTS to support Cloud configuration
&{CAPTURE_CORE_WTS_ETH3}            host=${HOST_EPCSIM}                     isNode=${False}
...                                 interface=eth3
...                                 isMirror=False                          scriptDef=
...                                 prefix=CORE_WTS_ETH3                    name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
# Add of interface BR1 to support ASIB
&{CAPTURE_CORE_GNB_SYS0_BR1}        host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=br1
...                                 isMirror=False                          scriptDef=
...                                 prefix=CORE_GNB_SYS0_M_BR1              name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

# Add of interface BR0 to support ASIL
&{CAPTURE_CORE_GNB_SYS0_BR0}        host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=br0
...                                 isMirror=False                          scriptDef=
...                                 prefix=CORE_GNB_SYS0_M_BR0              name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

##-----------------------------------
## CAPTURE for CPRT
##-----------------------------------
#&{CAPTURE_CPRT_AP_SYS0_ETHA01}      host=${AIRSCALE_AP.sys[0].S}            isNode=${False}
#...                                 interface=etha01
#...                                 isMirror=False                          scriptDef=
#...                                 prefix=CPRT_AP_SYS0_S_ETHA01            name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
#&{CAPTURE_CPRT_NODE}                host=None                               isNode=${True}
#...                                 interface=any                           node=CPRT
#...                                 isMirror=False                          scriptDef=
#...                                 prefix=NODECPRT_GNB                     name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
#
##-----------------------------------
## CAPTURE for BIP
##-----------------------------------
#&{CAPTURE_L1L2_GNB_FS_ASIK_ABIL}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
#...                                 interface=pepbp1
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}
#...                                 prefix=L1L2_GNB_FS_KL                   name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
#&{CAPTURE_L1L2_GNB_FS_ASIB_ABIL}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
#...                                 interface=eths2
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}
#...                                 prefix=L1L2_GNB_FS_BL                   name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
#&{CAPTURE_L1L2_GNB_FS_ASIL_ABIO}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
#...                                 interface=nac_eth2
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}
#...                                 prefix=L1L2_GNB_FS_LO                   name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
## FDD only
#&{CAPTURE_L1L2_GNB_FS_ASIB_ABIO}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
#...                                 interface=eths3
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}
#...                                 prefix=L1L2_GNB_FS_BO                   name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
#
#&{CAPTURE_L1L2_GNB_FS_ASIB_ABIO_2slot_BIP}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
#...                                 interface=eths3
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_BO_2slot}
#...                                 prefix=L1L2_GNB_FS_BO_2slots_BIP                   name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
#
#&{CAPTURE_L1L2_GNB_FS_ASIB_ABIO_2slot_CPRT}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
#...                                 interface=eths3
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_CPRT_BO_2slot}
#...                                 prefix=L1L2_GNB_FS_BO_2slots_CPRT                   name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
#
# TDD in l1 bypass due to restrictions
#&{CAPTURE_L1L2_GNB_L1BYPASS_ASIB_ABIO}
#...                                 host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
#...                                 interface=eths2
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_L1B_BO}
#...                                 prefix=L1L2_GNB_L1B_BO                  name=
#...                                 path=                                   withTN=False
#...                                 filter=\'${PREFIX_ETHER_BIP_MSG_TYPE_ASIB}<0xf000\'
#&{CAPTURE_L1L2_GNB_L1BYPASS_ASIB_ABIL}
#...                                 host=${AIRSCALE_GNB.sys[0].S}           isNode=${False}
#...                                 interface=etha01
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_L1B_BL}
#...                                 prefix=L1L2_GNB_L1B_BL                  name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
##&{CAPTURE_L1L2_GNB_L1BYPASS_ASIL_ABIO}
##...                                 host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
##...                                 interface=nac_eth2
##...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_L1B_LO}
##...                                 prefix=L1L2_GNB_L1B_LO                  name=
##...                                 path=                                   withTN=False
##...                                 filter=\'${PREFIX_ETHER_BIP_MSG_TYPE_ASIL}<0xf000\'
#
#&{CAPTURE_L1L2_L1BYPASS_AP}         host=${AIRSCALE_AP.sys[0].S}            isNode=${False}
#...                                 interface=etha01
#...                                 isMirror=False                          scriptDef=
#...                                 prefix=L1L2_AP_L1B_LO                   name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
#
## CAPTURE_L1L2_FS_AP_IPV6 => CAPTURE_L1L2_FS_AP since no more triggering upon IP kind (all are IPv6)
#&{CAPTURE_L1L2_FS_AP}               host=${AIRSCALE_AP.bb[0].S}             isNode=${False}
#...                                 interface=ethbp1
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_AP_FS}
#...                                 prefix=L1L2_FS_AP                       name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}
#
#&{CAPTURE_L1L2_AP_ASOE}             host=${AIRSCALE_AP.sys[0].S}             isNode=${False}
#...                                 interface=etha01
#...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_AP_ASOE}
#...                                 prefix=L1L2_AP_ASOE                       name=
#...                                 path=                                   withTN=False
#...                                 filter=${EMPTY}

*** Keywords ***
Convert TL Mode And Suite Setup
    Change Testline From Fullstack To L1bypass
    Change IPHY File Value
    Run Keywords    Set CP Debug
    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir
Convert TL Mode And Suite Setup Tdd
    Change IPHY File Value
    Run Keywords    Set CP Debug
    Get All Testline Information And Set Suite Variable
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup Tdd_2
    Send IPHY XML for AP        ap_iphy=${iphy}
  #  Change IPHY File Value
    Run Keywords    Set CP Debug
   # Suite Setup Update GNB with full and delta commissioning    swconfig_param=${RD_PARAM}    scf_file=${scf_file}    delta_file=${DELTA_FILE}
    #Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${scf_file}
    Get All Testline Information And Set Suite Variable
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${scf_file}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${scf_file}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
    Delta Commission With SCF File    ${DELTA_FILE}
    Reboot TL And Check Configured
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir
Convert TL Mode And Suite Setup Fdd
    Change Testline From Fullstack To L1bypass
    Change IPHY File Value
    add_l1bypass_sic_address_in_gnb     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
    Run Keywords    Set CP Debug
    Get All Testline Information And Set Suite Variable
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup fdd_acsi
    Change Testline From Fullstack To L1bypass
    Change IPHY File Value
    add_l1bypass_sic_address_in_gnb     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
    Run Keywords    Set CP Debug
    Get All Testline Information And Set Suite Variable
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PAR_ACSI}    scf_file=${DELTA_FILE}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PAR_ACSI_BRANCH}    scf_file=${DELTA_FILE}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PAR_ACSI_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PAR_ACSI}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup 30Mhz Fdd
    Send IPHY XML for AP        ap_iphy=${iphy}
    Change Testline From Fullstack To L1bypass
    Change IPHY File Value
    add_l1bypass_sic_address_in_gnb     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
    Run Keywords    Set CP Debug
    Get All Testline Information And Set Suite Variable
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir
Change IPHY File Value
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    Modify Text File    ${file_path}    ${OLD_PARAS_IPHY}    ${NEW_PARAS_IPHY}
    Send IPHY XML To Airphone    ${file_path}
  #${test_log_directory}/ttitrace_streaming/output_ul_formated.csv

Start And Stop Tti Trace Bin to CSV
    [Arguments]    ${logpath}    ${time_duration}
    Start GNB TTI Trace
    Sleep    ${time_duration}    reason=get *L2TtiTrace_EventsSnapshot
    Stop And Decode GNB TTI Trace    ${log_path}/

Check DL Per Slot Ue Numbers
    [Arguments]    ${tti_csv_dir}    ${number}
    ${filters}    Set Variable    dlFdSchedData
    ${out_file_name}    Set Variable    ${tti_csv_dir}/dlFdSchedData.csv
    ${result}    Set Variable    ${False}
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*dl.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    ${result}    Verify DL Per Slot Ue Numbers In Target File    ${out_file_name}    ${number}
    Exit For Loop If    ${result}==${True}
    END
    Should Be True    ${result}==${True}

Verify DL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}    ${number}
    [Documentation]    tti csv file contains only dlFdSchedData msg, please refer to tti_convert.py for more infos
    ${times}    Evaluate    ${number}-1
    ${full_patt}    Set Variable    dlFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:dlFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
    ${rnti_patt}    Set Variable    dlFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
    ${count}    Evaluate    len(set(${rnti_vals}))
    ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
    Exit For Loop If    ${check_result}==${True}
    END
    [Return]    ${check_result}

Check UL Per Slot Ue Numbers
    [Arguments]    ${tti_csv_dir}    ${number}
    ${filters}    Set Variable    ulFdSchedData
    ${out_file_name}    Set Variable    ${tti_csv_dir}/ulFdSchedData.csv
    ${result}    Set Variable    ${False}
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*ul.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    ${result}    Verify UL Per Slot Ue Numbers In Target File    ${out_file_name}    ${number}
    Exit For Loop If    ${result}==${True}
    END
    Should Be True    ${result}==${True}

Verify UL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}    ${number}
    [Documentation]    tti csv file contains only ulFdSchedData msg, please refer to tti_convert.py for more infos
    ${times}    Evaluate    ${number}-1
    ${full_patt}    Set Variable    ulFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:ulFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
    ${rnti_patt}    Set Variable    ulFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
    ${count}    Evaluate    len(set(${rnti_vals}))
    ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
    Exit For Loop If    ${check_result}==${True}
    END
    [Return]    ${check_result}

Start And Stop Tti Trace
    Start GNB TTI Trace
    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
    Stop And Decode GNB TTI Trace    ${TEST_LOG_DIRECTORY}

Test Ttitrace With Snapshot Mode Catch Continously
    [Arguments]    ${log_path}
    Catch Ttitrace Log    1s
    Decode TTI Trace And Send To Control PC One By One    ${log_path}/

Set CP Debug
    ${connection_gnb}    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Execute    ${CMD_OPEN_CP_DEBUG}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect
Get Counter Value With Admin
     [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the lastest value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value With Admin | M55323C14001 |
    ...
    COAM.Setup Admin
    ${counter}    COAM.Get Pm Counters    ${counter_id}
    ${counter_str}    Convert To String    ${counter}
    ${counter_list}    String.Get Regexp Matches    ${counter_str}
    ...    (?P<counter_time>\\d+)':\\s(?P<counter_num>\\d+)    counter_time    counter_num
    ${latest}    Evaluate    max(${counter_list})
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${latest[-1]}

Verify fdm max ul and dl Counters
     [Arguments]    ${ul_expected}      ${dl_expected}
     [Documentation]    This keyword is to verify the FDM dl&ul counter
     ${counter_dl}           Get Counter Value With Admin          M55308C17002
     ${counter_ul}           Get Counter Value With Admin          M55308C18002
     Should Be True      ${counter_dl}==${dl_expected}
     Should Be True      ${counter_ul}==${ul_expected}
Start And Stop Tti Trace Streaming
    [Arguments]         ${path}
    Start Ttitrace With Streaming Mode
    Sleep    3s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}

Start And Stop Tti Trace Streaming after pci change
    [Arguments]         ${path}
    sleep   1s
    Start Ttitrace With Streaming Mode_2
    Sleep    3s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}

Start And Stop Tti Trace A2A and stop bip
    [Arguments]         ${path}
    Start Ttitrace With Streaming Mode
    Sleep    2s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    sleep     5s
    BIP_Monitoring_Stop_AP_ASIK_ABIL        /home/ute/Downloads/
    Convert Ttitrace From Pcap To Excelcsv        ${path}

Convert Tti To Csv Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv

Check UL and DL rnti per slot
    [Arguments]    ${path}  ${expected_ul}   ${expected_dl}
    ${x}=    check_num_of_rnti_per_slot    ul    ${expected_ul}    ${path}/output_ul_formated.csv
    Should Contain    ${x}    Pass
    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
    Should Contain    ${y}    Pass

Check ACSI per on PUSCH slot
    [Arguments]    ${path}  ${min_acsi_on_pusch}    ${file_name}
    ${result} =    check_num_of_acsi_on_pusch_per_slot    ${min_acsi_on_pusch}    ${path}/${file_name}
    [return]    ${result}

Check ACSI per on PUSCH slot for longer duration
    [Arguments]    ${path}    ${expected_acsi}    ${file_name}
     FOR    ${i}    IN RANGE    50
        Start And Stop Tti Trace Streaming    ${path}/${i}
        Convert Tti To Csv Mode          ${path}/${i}
        ${x}    Check ACSI per on PUSCH slot    ${path}/${i}    ${expected_acsi}    ${file_name}
        Exit For Loop If    ${x[1]}==${expected_acsi}
     END
     Should Contain    ${x[0]}    Pass


Online Change MaximumPxschAllocationPerSlot Parameter
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    COAM.Setup Admin
    COAM.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}    parameter=${parameter}    operation=update    value=${value}    skip_parameter_relation_errors=True
    sleep       15s
     [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
SA MultiUE Attach And Do Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${dl_tput}      ${ul_tput}
    : FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    \   SA 5G Attach        ${ue_id}
    \    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    \    SA 5G PDU Session Setup multiue       ${ue_id}
    \    Start DL Traffic        ${ue_id}   ${dl_tput}
    \    Start UL Traffic        ${ue_id}   ${ul_tput}
    \    Display average DL and UL data        ${ue_id}
SA 5G PDU Session Setup multiue
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}
NSA MultiUE Attach And Do Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${ue_info}
    [Documentation]    This keyword is to do NSA multi UE attach and do DL/UL traffic
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${max_ue_num} | Yes | the number of multi UE |
    ...    | ${ue_info} | Yes | the directory for setting UE info. |
    ...
    ...    Examples:
    ...    1. both UL and DL --- kbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100M | ul_traffic=10m |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    2. both UL and DL --- mbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | \ Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100k | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    3. only UL or DL
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=0 | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...    or
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | \ profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=10m | ul_traffic=0 |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ${ul_traffic_type}    Run Keyword If    '${ue_info.ul_traffic}'!='0'    Evaluate    '${ue_info.ul_traffic}'[-1]
    ${dl_traffic_type}    Run Keyword If    '${ue_info.dl_traffic}'!='0'    Evaluate    '${ue_info.dl_traffic}'[-1]
    ${dl_type}    Run Keyword If    '${dl_traffic_type}'!='None'    String.Convert To Lowercase    ${dl_traffic_type}
    ${ul_type}    Run Keyword If    '${ul_traffic_type}'!='None'    String.Convert To Lowercase    ${ul_traffic_type}
    ${ul_traffic_value}    Run Keyword If    '${ul_type}'!='None'    Evaluate    '${ue_info.ul_traffic}'[0:-1]
    ${dl_traffic_value}    Run Keyword If    '${dl_type}'!='None'    Evaluate    '${ue_info.dl_traffic}'[0:-1]
#    : FOR    ${ue_id}    IN RANGE    11    ${max_ue_num}+11
#    \    NSA LTE Attach    ${ue_id}    ${ue_info.profile_id}
#    \    NSA 5G Attach    ${ue_id}    ${ue_info.gnb_id}    ${ue_info.cell_id}    ${ue_info.bearer_id}
#    \    NSA Verify If Attach Passed
#    \    Run Keyword If    '${ul_type}'=='m'    NSA Start UL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
#    ...    ELSE IF    '${ul_type}'=='k'    NSA Start UL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
#    \    Run Keyword If    '${dl_type}'=='m'    NSA Start DL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}
#    ...    ELSE IF    '${dl_type}'=='k'    NSA Start DL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}
    NSA LTE Attach    ${ue_id}
    NSA 5G Attach     ${ue_id}    2    1    2

Start DL Traffic
    [Arguments]    ${ue_id}     ${dl_tput}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=dl trf_id\=1 kbps\=${dl_tput}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
Start UL Traffic
    [Arguments]    ${ue_id}     ${ul_tput}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=ul trf_id\=1 kbps\=${ul_tput}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
Verify if average DL data is correct
    [Arguments]    ${ue_id}
    sleep   10s
    ${out}=    ute_wtssim.Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=dl
    Create File       ${OUTPUT_DIR}/dl_data1.txt    ${out}
    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG DL : ${average_dl}    WARN
   # Should Be True    ${average_dl} > 27000
    [Return]    ${average_dl}

Display average DL and UL data
    [Arguments]    ${ue_id}
    sleep   10s
    ${out_dl}=    ute_wtssim.Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=dl
    Create File       ${OUTPUT_DIR}/dl_data1.txt    ${out_dl}
    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG DL : ${average_dl}    WARN
    ${out_ul}=    ute_wtssim.Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=ul
    Create File       ${OUTPUT_DIR}/ul_data1.txt    ${out_ul}
    ${average_ul}=      Run    cat ${OUTPUT_DIR}/ul_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG UL : ${average_ul}    WARN
    [Return]    ${average_dl}    ${average_ul}
Detach multiple SA UEs
    [Arguments]    ${max_ue_num}
    : FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    \        SA 5G Detach       ${ue_id}

Detach multiple NSA UEs
    [Arguments]    ${max_ue_num}
    : FOR    ${ue_id}    IN RANGE    11    ${max_ue_num}+11
    \       NSA LTE Detach      ${ue_id}
wait for counter update ${sleep}s
    sleep       ${sleep}s

Detach multiple NSA UE
    [Arguments]    ${ue_id}
#    : FOR    ${ue_id}    IN RANGE    11    ${max_ue_num}+11
    NSA LTE Detach      ${ue_id}


wait for previous action to stabilise ${sleep}s
     sleep       ${sleep}s
Verify max ue per slot after online modification
    [Arguments]    ${pusch}     ${pdsch}    ${log_path}     ${pusch_exp}     ${pdsch_exp}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-1    maxNumPuschAllocationPerSlot    ${pusch}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-1    maxNumPdschAllocationPerSlot    ${pdsch}
    Start And Stop Tti Trace Streaming        ${test_log_directory}/ttitrace_streaming/${log_path}
	Convert Tti To Csv Mode             ${test_log_directory}/ttitrace_streaming/${log_path}
    Check UL and DL rnti per slot       ${test_log_directory}/ttitrace_streaming/${log_path}   ${pusch_exp}   ${pdsch_exp}
    wait for counter update ${600}s
    Verify fdm max ul and dl Counters   ${pusch_exp}   ${pdsch_exp}
Verify ue per slot after online modify A2A
    [Arguments]    ${pusch}     ${pdsch}    ${log_path}     ${pusch_exp}     ${pdsch_exp}    ${ini_file_ul}     ${ini_file_dl}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-1    maxNumPuschAllocationPerSlot    ${pusch}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-1    maxNumPdschAllocationPerSlot    ${pdsch}
    Start And Stop Tti Trace Streaming        ${test_log_directory}/ttitrace_streaming/${log_path}
	Convert Tti To Csv Mode             ${test_log_directory}/ttitrace_streaming/${log_path}
	Check Log With Au2anlysis    ${CURDIR}${/}A2A/test${/}${ini_file_dl}    i
    ...    save_log_directory=${test_log_directory}/ttitrace_streaming/${log_path}
    Check Log With Au2anlysis    ${CURDIR}${/}A2A/test${/}${ini_file_ul}    i
    ...    save_log_directory=${test_log_directory}/ttitrace_streaming/${log_path}
    wait for counter update ${600}s
    Verify fdm max ul and dl Counters   ${pusch_exp}   ${pdsch_exp}
Verify ue per slot ul and dl A2A
    [Arguments]    ${log_path}     ${ini_file_ul}     ${ini_file_dl}
    Check Log With Au2anlysis    ${CURDIR}${/}A2A/test${/}${ini_file_dl}    i
    ...    save_log_directory=${test_log_directory}/ttitrace_streaming/${log_path}
    Check Log With Au2anlysis    ${CURDIR}${/}A2A/test${/}${ini_file_ul}    i
    ...    save_log_directory=${test_log_directory}/ttitrace_streaming/${log_path}


UE Beamforming Profile And Association For 2 Beams SA
    [Arguments]    ${max_ue_num}
    : FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}/2 + 1
    \    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    \    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=1
    \    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    \    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=2
    \    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    \    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    \    Log To Console    ******The BC profiles are set******
    \    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    \    Log To Console    ******Beam Control Profile 1 Display: ******
    \    Log To Console    ${output}
    \    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    \    Log To Console    ******Beam Control Profile 2 Display: ******
    \    Log To Console    ${output}

    \    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach
    : FOR    ${ue_id}    IN RANGE    ${max_ue_num}/2 + 1    ${max_ue_num} + 1
    \    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    \    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=1
    \    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    \    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=2
    \    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    \    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    \    Log To Console    ******The BC profiles are set******
    \    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    \    Log To Console    ******Beam Control Profile 1 Display: ******
    \    Log To Console    ${output}
    \    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    \    Log To Console    ******Beam Control Profile 2 Display: ******
    \    Log To Console    ${output}
    \    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=2 beamaction=attach

UE Beamforming Profile And Association For 2 Beams NSA
    [Arguments]    ${max_ue_num}
    : FOR    ${ue_id}    IN RANGE    11    ${max_ue_num}/2 + 11
    \    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    \    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=1
    \    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    \    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=2
    \    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    \    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    \    Log To Console    ******The BC profiles are set******
    \    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    \    Log To Console    ******Beam Control Profile 1 Display: ******
    \    Log To Console    ${output}
    \    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    \    Log To Console    ******Beam Control Profile 2 Display: ******
    \    Log To Console    ${output}

    \    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach
    : FOR    ${ue_id}    IN RANGE    ${max_ue_num}/2 + 11    ${max_ue_num} + 11
    \    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    \    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=1
    \    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    \    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=2
    \    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    \    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    \    Log To Console    ******The BC profiles are set******
    \    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    \    Log To Console    ******Beam Control Profile 1 Display: ******
    \    Log To Console    ${output}
    \    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    \    Log To Console    ******Beam Control Profile 2 Display: ******
    \    Log To Console    ${output}
    \    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=2 beamaction=attach

Convert TL Mode And Suite Setup 7564
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_dss_7859_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_dss_7859}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir for DSS

Enable 7859 With DSS
    [Arguments]    ${prb_list}    ${ALLOC_SUBFRAME}    ${min_dss_ratio}    ${max_dss_ratio}    ${min_prb_ratio}    ${max_prb_ratio}
    Setup XP LINK
    Set LTE NR DSS Mode
    Setup DSS Link
    Set DL RESOURCE Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Coordination
    Set UL Resource Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Allocation    nor_subframe=${ALLOC_SUBFRAME}    prb_list=${prb_list}
    Builtin.Log     ${min_prb_ratio}
    Builtin.Log     ${max_prb_ratio}


Set UL Resource Cell Reservation
    [Arguments]    ${min_prb_ratio}    ${max_prb_ratio}
    [Documentation]    This keyword is for ul resource cell Reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | min_prb_ratio | Yes | The minimum value of PRB share ratio |
    ...    | max_prb_ratio | Yes | The maximum value of PRB share ratio |
    ...    Example:
    ...    | enb_dss_ul_cell_resource_reservation    | 2 | 1 | 30 | 70 |
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ${command}    Set Variable    enb_dss_cell_resource_coordination enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=UL
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_dss_ul_cell_resource_reservation enb=2 cell=1 minimum_prb_share=${min_prb_ratio} maximum_prb_share=${max_prb_ratio}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=${pattern}    timeout=3minutes
    ute_wtssim.Execute Egate Command    cmd=enb_crm_status enb=2 cell=1
    Builtin.Log     ${min_prb_ratio}
    Builtin.Log     ${max_prb_ratio}

Cell Resource Allocation
    [Arguments]    ${nor_subframe}    ${prb_list}
    [Documentation]    This keyword is used to allocate cell resource.
    ...    | Input Parameters | Man. | Description |
    ...    | nor_subframe | Yes | The dl allocated normal subframes |
    ...    | prb_list | Yes | It shows the info of startprb and amount of prbs. e.g. 1,30 1:startprb    30:amount of prbs.|
    ...    Example:
    ...    | Cell Resource Allocation | 0010000000-0000001000-0000000000-0000000000-0000000000-0000001000-0000000000-0000000000 | 1,30 |
    ${command}    Catenate    enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL
    ...    allocation_start_time=immediate dl_allocated_normal_subframes=${nor_subframe}
    ute_wtssim.Execute Egate Command    ${command}
    ${command}    Catenate    enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1
    ...    dir=UL allocation_start_time=immediate ul_allocated_prb_list=${prb_list}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber    timeout=2minutes
    ${output}    String.Get Lines Matching Regexp    ${output}
    ...    Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber    partial_match=${true}
    Log To Console    \n${output}

Suite Setup Start WTS And Check OnAir for DSS
    [Arguments]        ${log}=yes
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    NG Link Should Be UP
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    Address Distribution Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection for DSS
    Verify Cell Setup
    [Teardown]    Run Keyword If    "${log}"=="yes"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}

Setup X2 Connection for DSS
    [Documentation]    This keyword is to setup X2 connection and check x2 is ok
    Log To Console    setup X2 connection...
    ${pattern}    Set Variable    ENB-1: X2AP Link with GNB-2 .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=1 target\=2
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    x2_is_ok



Get Max PM Counter Value With Admin
    [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the max value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value From Coam | M55323C14001 |
    ...
    ${counter_value_list}    CB007564_Resource.Get All Counter Values List With Admin    ${counter_id}
    ${max_counter_value}    Evaluate    max(${counter_value_list})
    [Return]    ${max_counter_value}


Get All Counter Values List With Admin
    [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the couter value list from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get All Counter Values List With Admin | M55323C14001 |
    ...
    COAM.Setup Admin
    ${counter}    COAM.Get Pm Counters    ${counter_id}
    ${counter_str}    Convert To String    ${counter}
    ${counter_value_list}    String.Get Regexp Matches    ${counter_str}    '\\d+':\\s*(?P<${counter_id}>\\d+)    ${counter_id}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${counter_value_list}

Validate CBRA_INIT1 parameters in syslog
    [Arguments]     ${test_model}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "handleAckNackForContRes: UE attached: xsfn= "
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_params}
        should contain    ${status}    ${item}
    END

Validate CBRA_INIT2 parameters in syslog
    [Arguments]     ${test_model}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log |
    ...     grep -A4 "handleRaContResSuccessUe: rnti= raState=dl_awaitUlNsaContResAck subCellIndex=0"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_params}
        should contain    ${status}    ${item}
    END

Start Collecting Syslog
    [Arguments]    ${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}    ${NAME}=5g
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable  ${LOG_PATH}/Syslog
    set test variable      ${CURRENT_SYSLOG_PATH}
    Start Syslog  log_dir=${CURRENT_SYSLOG_PATH}  log_name=syslog_${NAME}.log  ip=192.168.255.126
    ...    host_ip=${VM_IP}   ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAME}

Stop Collecting Syslog
    [Arguments]    ${NAME}=5g
    ${file_path}    Collect Syslog Results    alias=${NAME}
    [Return]      ${file_path}



Check the syslog contain the rach cbra test and other parameters for rach cbra
    [Arguments]    ${logpath}    ${test_model}    ${prach}=False
    log to console     Verifying syslog
#    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A2 "handleAckNackForContRes:"
#    should contain    ${status}    handleAckNackForContRes
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "UE attached:"
    should contain    ${status}    UE attached
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "xsfn"
    should contain    ${status}    xsfn
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "rnti"
    should contain    ${status}    rnti
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A2 "handleRaContResSuccessUe:"
    should contain    ${status}    handleRaContResSuccessUe
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "rnti"
    should contain    ${status}    rnti
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "raState"
    should contain    ${status}    raState=dl_awaitUlNsaContResAck
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "subCellIndex"
    should contain    ${status}    subCellIndex=0
    Run Keyword if    '${prach}' == 'True'    Validate cbra rach parameters in syslog    ${test_model}

Validate cbra rach parameters in syslog
    [Arguments]     ${test_model}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "handleAckNackForContRes: UE attached:"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_params}
        should contain    ${status}    ${item}
    END

#Get information elements from SgNBAdditionRequestAcknowledge message
#    [Documentation]     Retrieves data values from SgNBAdditionRequestAcknowledge at CPRT level
#    Log to console             Checking SgNBAdditionRequestAcknowledge OAM-CPRT IE
#    Log Variables
#
#    ${start_conf_variables}     run keyword if     '${AirScale}' == 'ASIK'     Get IE from SgNBAdditionRequestAcknowledge
#    ...                 ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap    SgNBAdditionRequestAcknowledge
#    ...        ELSE      Get IE from SgNBAdditionRequestAcknowledge
#    ...                 ${CaptureCPRT.path}    SgNBAdditionRequestAcknowledge
#    set suite variable       ${start_conf_variables}     ${start_conf_variables}
#    Log Variables

Get Information Elements from SgNBAdditionRequestAcknowledge message and verify cbra rach parameters
    [Documentation]         Creates a dictionary containing IE from SgNBAdditionRequestAcknowledge message from OAM
    Log to console                 Checking SgNBAdditionRequestAcknowledge OAM-CPRT IE
    &{SgNBAdditionRequestAcknowledge_varibles_expected}     create dictionary      one=n64    rach-ConfigCommon=setup   prach-ConfigurationIndex=12
    ...       ssb-perRACH-OccasionAndCB-PreamblesPerSSB=one     ra-ContentionResolutionTimer=sf64    prach-RootSequenceIndex:l839
    &{SgNB_AdditionAck_variables}           Get IE from SgNBAdditionRequestAcknowledge     ${CaptureCPRT.path}      ${Filter_cellsetupreq}
    set suite variable       &{SgNB_AdditionAck_variables}      &{SgNB_AdditionAck_variables}
    Dictionaries Should Be Equal     ${SgNBAdditionRequestAcknowledge_varibles_expected}     ${SgNB_AdditionAck_variables}

Get IE from SgNBAdditionRequestAcknowledge
    [Arguments]         ${pcapFile}    ${filter_req}
    [Documentation]
    ...                 Constructs and return a dictionary with
    ...                 key-value data structure from OAM-CPRT
    ...
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}

    ${packet}        set variable                  x2ap

    ${rachConfigCommon}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*rach-ConfigCommon$
    ...                                                endPacket=${1}

    ${rachconfig}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*rach-ConfigGeneric$
    ...                                                endPacket=${1}

    ${ssbprach}     analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ssb-perRACH-OccasionAndCB-PreamblesPerSSB$
    ...                                                endPacket=1

    ${cbrassb}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*n64$
    ...                                                endPacket=1

    ${prachConfigurationIndex}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*prach-ConfigurationIndex$
    ...                                                endPacket=1

    &{start_conf_variables}     Create Dictionary         rachConfigCommon=${rachConfigCommon}
    ...                                                   rachconfig=${rachconfig}
    ...                                                   ssbprach=${ssbprach}
    ...                                                   cbrassb=${cbrassb}
    ...                                                   prachConfigurationIndex=${prachConfigurationIndex}

    [Return]            ${start_conf_variables}
    Log Variables


Set test log path
    ${fullTestName}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set test variable    ${LOG_PATH1}    ${LOG_PATH}
    set test variable    ${LOG_PATH}    ${LOG_PATH}/${fullTestName}
    Create Directory        ${LOG_PATH}



    #-----------------------------------
# CAPTURES for CPRT
#-----------------------------------
Capture CPRT Set Upon Config
    [Arguments]                     ${airscale}=${AIRSCALE_GNB}
    ...                             ${sysIndex}=0
    ${capture}                      Run Keyword if                          '${airscale.hw}'=='GNB'
    ...                             Dictionary Get                          ${CAPTURE_CPRT_NODE}
    ...     ELSE                    Dictionary Get                          ${CAPTURE_CPRT_AP_SYS0_ETHA01}
    [Return]                        ${capture}
    Builtin.Log    ${sysIndex}
    Builtin.Log     ${capture}


Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init        ${capture_var_cprt}
    Capture start       ${capture_var_cprt}

Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop        ${capture_var_cprt}



Capture Init
    [Documentation]                 Entry point for capture init : put in place expected mirroring if required
    ...                             input argument is a <capture>.
    ...                             A suffix may be added to prefix capture
    ...                             Also, if <withTN> is set to True, Test Name will be part of the pcap file
    ...                             Final name of pcap will be : <prefix>[<suffix>][<TestName>]
    [Arguments]                     ${capture}
    ...                             ${withTN}=False
    ...                             ${suffix}=${EMPTY}
    ${capture.prefix}               set Variable                            ${capture.prefix}${suffix}
    ${capture.withTN}               set Variable                            ${withTN}
    Run Keyword if                  ${capture.isMirror}
    ...                             Mirror Script Install                   ${capture.scriptDef}

Capture Stop
    [Documentation]                 Stop a capture previously launched
    ...                             1) retrieve pid of capture and kill it
    ...                             2) check capture is no more running
    ...                             3) download pcap in logs on VM
    [Arguments]                     ${capture}
    # Retrieve pid of corresponding capture and kill it
    ${tcpdumpCmd_path}              Set Variable                            ${capture.CaptureRootPathCmd}/${capture.name}.pcap
    ${sudoPrefix}                   Sudo Prefix                             ${capture.host}
    ${cmd}                          set variable
    ...            ${sudoPrefix}kill `ps -ef | grep tcpdump | grep ${tcpdumpCmd_path} | grep "${sudoPrefix}" | grep -v grep | awk '{print $2}'`
    Dated Log                       Stop Tcpdump on ${capture.host.alias} (${tcpdumpCmd_path}) prefix=(${sudoPrefix}) CMD=(${cmd})
    SSH Cmd                         ${cmd}
    ...                             alias=${capture.host.alias}
    # Check no more identical capture is running
    Check Tcpdump Is Running        ${tcpdumpCmd_path}                      alias=${capture.host.alias}
    ...                             isRunning=False
    # Set capture path on VM
    ${capture.path}                 Set variable                            ${LOG_PATH}/${capture.name}.pcap
    # Update path on remote to pcap file
    ${tcpdump_path}                 Set Variable                            ${capture.CaptureRootPath}/${capture.name}.pcap
    # Download from master to VM
    csn.download_file               remote_path=${tcpdump_path}
    ...                             local_path=${capture.path}
    ...                             connection=${capture.host.alias}        # instead AliasProxy
    [Return]                        ${capture.path}



Mirror Script Install
    [Documentation]                 Install mirroring script on target
    ...                             1) Extract list of scripts in <scriptDef.names> and download them on host
    ...                             2) Execute dedicated command on host
    [Arguments]                     ${scriptDef}
    # Split list of script file names into a table, and parse table to download each file
    Dated log                       Download scripts for mirroring:${scriptDef.names}
    @{scriptList}                   Split String                            ${scriptDef.names}      separator=,
    ${alias}                        SSH Wait For Connect                    ${scriptDef.host}
    FOR    ${script}        IN     @{scriptList}
        SSH Upload Script           alias=${alias}                          scriptFile=${script}
        ...                         remotePath=${scriptDef.remotePath}
    END
    # Hard coded for the moment ...
    Run Keyword if                 '${GNB_DU.sys[0].M.boardType}'=='ASOE'
    ...                            Mirror Script Launch AP         ${scriptDef}                            ${alias}
    ...  ELSE                      Mirror Script Launch GNB        ${scriptDef}                            ${alias}
    # Mirror Script Launch AP         ${scriptDef}                            ${alias}




Mirror Script Launch GNB
    [Arguments]                     ${scriptDef}                            ${alias}
    ${dom_ID}                       Get Domain Id                           ${AIRSCALE_GNB.sys[0].M}
    ${mirrorslot}                   Set Variable If                         '${dom_ID}'=='1'
    ...                             1                                       5
    Dated log                       Execute script:[${scriptDef.cmd} ${AIRSCALE_GNB.bb[0].M.boardType} ${mirrorslot}]

    ${mirror_cmd}                   Run Keyword If    '${scriptDef.commonMirrorScript}' == 'True'
    ...                                 Catenate
    ...                                     nohup ${scriptDef.cmd}
    ...                                     --bb_board_type=${AIRSCALE_GNB.bb[0].M.boardType}
    ...                                     --bb_slot_${mirrorslot}='true'
    ...                                     &
    ...                             ELSE
    ...                                 Set Variable    ${scriptDef.cmd}

    ${read_output}                  Run Keyword If    '${scriptDef.commonMirrorScript}' == 'True'
    ...                                 Set Variable    False
    ...                             ELSE
    ...                                 Set Variable    True

    ${output}                       SSH Cmd
    ...                             command=${mirror_cmd}
    ...                             readOuput=${read_output}
    ...                             alias=${alias}

    # Check no error was detected : inhibited for the moment, since some "failure" still exist in V17 script version
    # should not contain              ${output}                               failure

    Run Keyword If                  '${scriptDef.commonMirrorScript}' == 'True'
    ...                             sleep    10s

Mirror Script Launch AP
    [Arguments]                     ${scriptDef}                            ${alias}
    Dated log                       Execute script:[${scriptDef.cmd}
    ${output}                       SSH Cmd                                 command=${scriptDef.cmd}
    ...                             alias=${alias}



#===================================
Capture Start
    [Documentation]                 Start a capture.
    ...                             1) full name of capture is computed, upon <withTN> flag
    ...                             2) previous capture is removed if existing
    ...                             3) new capture is launched on host/interface defined in <capture> fields
    ...                             4) if required (<check> flag), check process is running
    [Arguments]                     ${capture}                              # Reference to capture to be launched
    ...                             ${check}=True                           # Should we check tcpdump is running once launched ?
    # Set capture name : either prefix or prefix.<test_name>
    ${TestName}                     getFormattedName
    ${capture.name}                 Set variable                            ${capture.prefix}
    ${capture.name}                 Set variable if                         ${capture.withTN}
    ...                             ${capture.name}.${TestName}             ${capture.name}
    # Set Capture Root Path upon host : if host has OAM as proxy, we should use  ${CAPTURE_ROOT_PATH_LOCAL}
    run keyword if                  ${capture.isNode}
    ...                             Capture Prepare from Node               ${capture}
    ...   ELSE                      Capture Root Path Set                   ${capture}
    Dated Log                       CaptureRootPath=(${capture.CaptureRootPath}) CaptureRootPathCmd=(${capture.CaptureRootPathCmd})
    # Remove eventual previous local cature file
    ${tcpdumpCmd_path}              Set Variable                            ${capture.CaptureRootPathCmd}/${capture.name}.pcap
    ${tcpdump_path}                 Set Variable                            ${capture.CaptureRootPath}/${capture.name}.pcap
    ${alias}                        SSH Connect                             host=${capture.host}
    csn.execute                     rm -rf ${tcpdump_path}                  connection=${alias}
    # Launch a new capture
    ${sudoPrefix}                   Sudo Prefix                             ${capture.host}
    ${cmd}                          set variable
    ...                             ${sudoPrefix}tcpdump -i ${capture.interface} -w ${tcpdumpCmd_path} ${capture.filter}
    ${cmd}                          set variable if                         ${capture.isNode}
    ...                             lxc-attach -n ${capture.node.nodeId} -- ${cmd}
    ...                             ${cmd}
    Dated Log                       Start tcpdump on ${alias} (${cmd})
    csn.send_command                ${cmd}                                  connection=${alias}
    # Check corresponding process was properly launched
    run keyword if                  '${check}'=='True'
    ...                             Check Tcpdump Is Running                ${tcpdumpCmd_path}
    ...                             alias=${alias}                          isRunning=True

SSH Download File
    [Documentation]                 Download a file from remote host
    ...                             if shouldBeRemoved is set to True, original file is removed from remote host
    [Arguments]                     ${host}
    ...                             ${remotePath}
    ...                             ${localPath}
    ...                             ${shouldBeRemoved}=${False}
    ${alias}                        SSH Connect                             host=${host}
    # Download from remote to VM
    Dated log                       Download file [${host.alias}]:${remotePath} to ${localPath}
    csn.download_file               remote_path=${remotePath}
    ...                             local_path=${localPath}
    ...                             connection=${host.alias}
    # Remove file from source if required
    run keyword if                  ${shouldBeRemoved}==${True}
    ...                             SSH Cmd                                 rm ${remotePath}
    ...                             alias=${host.alias}

#===================================
# Ping
#===================================
SSH Was OAM Rebooted
    [Documentation]                 Wait during max <timeout> to detect if the OAM of an <airscale> was rebooted
    ...                             or not (after a SCF modification for instance)
    [Arguments]                     ${airscale}
    ...                             ${timeout}=60s
    Dated log                       Pinging OAM : ${airscale.oam.sshConnection.addr}
    ${status}                       Run Keyword and Return status
    ...                             wait until keyword succeeds             ${timeout}              10s
    ...                                 SSH Check Ping Status               ${airscale.oam}         isPingable=False
    Dated log                       SSH Was OAM Rebooted : ${status}
    [Return]                        ${status}



Get Domain Id
    [Arguments]                     ${host}
    ${alias}                        SSH Connect                             ${host}
    ${cmd}                          Set variable                            ddal -s ddal_sysinfo_module_get_domain_id 0
    ${domainId}                     SSH Cmd                                 ${cmd} | grep dmid | cut -d= -f2
    ...                             alias=${alias}
    ${domainId}                     getStringFromCmdReturn                  ${domainId}
    Run Keyword If                  '${domainId}'=='${EMPTY}'               Fail    Cannot retrieve the domain ID form the testline
    # StringTool.printHeaderLine      name=${host.alias}:Domain ID            value=${domainId}
    [Return]                        ${domainId}

Capture Root Path Set
    [Documentation]                 Set path in which capture should be done
    [Arguments]                     ${capture}
    ${capture.CaptureRootPath}      set variable                            ${CAPTURE_ROOT_PATH_LOCAL}
    ${capture.CaptureRootPathCmd}   set variable                            ${capture.CaptureRootPath}


Capture Prepare from Node
    [Arguments]                     ${capture}
    ${capture.node}                 getNodeFromCaptureNode
    ...                             listNode=${LIST_NODE}
    ...                             captureNode=${capture.node}
    ${capture.host}                 set variable                            ${capture.node.host}
    ${capture.CaptureRootPathCmd}   set variable                            ${CAPTURE_ROOT_PATH_LOCAL}
    ${capture.CaptureRootPath}      set variable
    ...                             ${CAPTURE_ROOT_PATH_LOCAL}/node_${capture.node.id}/${capture.CaptureRootPathCmd}


Check the syslog contain the rach cfra test and other parameters for rach cfra
    [Arguments]    ${logpath}    ${test_model}    ${prach}=False
    log to console     Verifying syslog
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A2 "handleAckCRCOkForMsg3CFRA:"
    should contain    ${status}    handleAckCRCOkForMsg3CFRA
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "UE attached after CFRA:"
    should contain    ${status}    UE attached after CFRA
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "xsfn"
    should contain    ${status}    xsfn
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "rnti"
    should contain    ${status}    rnti
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A2 "handleSuccessfulCrcWithCfra:"
    should contain    ${status}    handleSuccessfulCrcWithCfra
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "rnti"
    should contain    ${status}    rnti
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "raState"
    should contain    ${status}    raState=dl_awaitMsg3
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "subCellId"
    should contain    ${status}    subCellId=0
    Run Keyword if    '${prach}' == 'True'    Validate cfra rach parameters in syslog    ${test_model}

Validate cfra rach parameters in syslog
    [Arguments]     ${test_model}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "handleAckCRCOkForMsg3CFRA: UE attached after CFRA:"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_params}
        should contain    ${status}    ${item}
    END

Check Tcpdump Is Running
    [Documentation]                 Basic service to check a capture is running, based on its path for pcap
    [Arguments]                     ${path}                                 # path of capture file to search
    ...                             ${alias}                                # alias of host on which search
    ...                             ${isRunning}=True                       # check to be done
    Sleep                           1                                       # To ensure process is properly down
    ${output}                       SSH Cmd
    ...                             ps -ef | grep tcpdump | grep ${path} | grep -v grep
    ...                             alias=${alias}
    run keyword if                  '${isRunning}'=='False'                 should be empty         ${output}
    run keyword if                  '${isRunning}'=='True'                  should not be empty     ${output}

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}



Capture CPRT Pcap
    [Documentation]          Attach a NSA UE via eNB by using keyword 'UE Attach Enb' (for more details see keyword 'UE Attach Enb').
    ...                      Then trig the SgNB Addition procedure by using keyword 'UE Attach Gnb' (for more details see keyword 'UE Attach Gnb').
    ...                      A SCTP capture is also started during the SgNB addition.
    ...                      Also, another capture (for instance, for BIP messages) may be performed on demand:
    ...                      meaning if a <captureCallback> and its asociated <capture> structure is provided through arguments.
    ...                      Return path of trace capture file.
    ...
    ...                      *Argument details:*
    ...                      - *ueSetting*:        Reference to UE Settings  (default value = UE_NO_PROFILE)
    ...                      - *captureCallback*:  Reference to a KW call back or None  (default value = None)
    ...                      - *capture*:          Associated <Capture> structure if Callback is provided  (default value = None)
    ...                      - *expected_gnb_log*: Msg to validate enb_ue_dc_start (default value = Successfully reconfigured dual connectivity)
    ...                      - *withTN*:           If set to True, Test Name will be part of the pcap file (default value = False)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${captureCallback}=None
    ...                             ${capture}=None
    ...                             ${expected_gnb_log}=Successfully reconfigured dual connectivity
    ...                             ${withTN}=${False}
#    Dated Log New Line              Starting GNB attach to ENB
    ${captureCORE}                  CB007564_Resource.Capture CORE Set Upon Config
    Capture Init                    ${captureCORE}
    ...                                 withTN=${WithTN}
    ...                                 suffix=_GNB_ADDITION_UE${ueSetting.ue}
    Capture Start                   ${captureCORE}
    Builtin.Log         ${capture}
#    UE Attach Enb                   ueSetting=${ueSetting}
    Traced Sleep                    duration=5s                    msg=Workaround for pb Attach Gnb
#    UE Attach Gnb                   ueSetting=${ueSetting}
#    ...                             captureCallback=${captureCallback}
#    ...                             capture=${capture}
#    ...                             expected_gnb_log=${expected_gnb_log}
    Capture Stop                    ${captureCORE}
    [Teardown]                      Run keyword if                          '${KEYWORD_STATUS}'!='PASS'
    ...                             Capture Stop                            ${captureCORE}
    [Return]                        ${captureCORE.path}
    Builtin.Log     ${captureCallback}
    Builtin.Log     ${expected_gnb_log}

Check rachconfigcommon in SgNBAdditionRequestAcknowledge
    [Arguments]                     ${pcapFile}
    ...                             ${expected_cbrassb_value}

    ${pcapFiltered}                 analyzer.filter_pcap
    ...                                 pcapInFile=${pcapFile}
    ...                                 filterName=x2ap
    ...                                 filterExp=x2ap
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
    ${msg}                          Set Variable                    SgNBAdditionRequestAcknowledge
    Dated Log                       In message ${msg}, check PrachConfigIndex=${expected_cbrassb_value}      first=True
    ${prachPath}                    set variable                    nr-rrc.prach_ConfigurationIndex

    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=${msg}
    ...                             path=${prachPath}
    ...                             value=${expected_cbrassb_value}

#-----------------------------------
# CAPTURES for F1X2
#-----------------------------------
Capture CORE Set Upon Config
    [Documentation]                 Return pertinent instance of capture upon context to get CORE messages
    ...                             It take into account kind of Airscale
    [Arguments]                     ${airscale}=${GNB_DU}
    ${capture}                      copyCaptureCORE                         entity=${airscale}
    [Return]                        ${capture}
    Builtin.Log     ${capture}


Wait until the next Measurement Period starts
    [Documentation]    :Author: Jing Liang
    ...    this keyword could be used as wait for current Measurement Period stops
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param additional_time: (default=30) additional seconds for waiting
    [Arguments]    ${gnb_id}=0    ${additional_time}=30
#    ${meas_period}=    300
    wait_next_meas_period    meas_period=${300}    add_time=${additional_time}    with_console_output=${P_console}
    ${start_time}=    DateTime.Get Current Date    result_format=%H:%M:%S
#    BuiltIn.Log    Start Time Of Measurement Period = ${start_time}    level=DEBUG
    ${start_time}=    DateTime.Convert Time    ${start_time}    result_format=timedelta
#    Set To Dictionary    ${P_START_TIME}    gnb_${gnb_id}    ${start_time}
#    Set Test Variable    ${P_START_TIME}
    Builtin.Log     ${gnb_id}

Get Measurement Period from GNB
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    :return: Measurement period in second
    [Arguments]    ${gnb_id}=0
    ${meas_period}=    Get Variable Value    ${P_MEAS_PERIOD.gnb_${gnb_id}}
    Run Keyword If    '${meas_period}'=='None'
    ...    Fetch Measurement Period from SCF    gnb_id=${gnb_id}
    [Return]    ${P_MEAS_PERIOD.gnb_${gnb_id}}
    Builtin.Log     ${gnb_id}

Get SCF from gNB
    [Documentation]    :Author: Nikolay Shkulepov
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param target_dir: (default None) save SCF to path
    ...     :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...
    ...     :return:   scf path for further usage
    ...
    [Arguments]    ${gnb_id}=${0}    ${target_dir}=None  ${component}=DU
    ${oamType}=    testline.Get OAM Type     gnb_id=${gnb_id}
    ${gnbScfName}=    Set variable    SCFC_gNB${gnb_id}_${component}.xml
    Set Suite Variable    ${private_gnbScfName${gnb_id}}    ${gnbScfName}
    ${resultConfigDir}=    Run Keyword If    '${target_dir}'=='None'    Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${target_dir}
    Run keyword if    '${oamType}'=='cloud_coam'    Get SCF from gNB with cloud cOAM  component=${component}
    ...                             gnbScfName=${gnbScfName}    resultConfigDir=${resultConfigDir}    gnb_id=${gnb_id}
    ...    ELSE IF    '${oamType}'=='coam'        Get SCF from gNB with cOAM
    ...                             gnbScfName=${gnbScfName}    resultConfigDir=${resultConfigDir}    gnb_id=${gnb_id}
    ...    ELSE    Fail    Unknown OAM Type ${oamType}
    [Return]    ${resultConfigDir}/${gnbScfName}
    Builtin.Log     ${gnb_id}

Fetch Measurement Period from SCF
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    Collect Measurement Period from SCF
    [Arguments]    ${gnb_id}=0
#    ${scf_path}=    Get SCF from gNB    gnb_id=${gnb_id}
    scf.Load SCF    file_path=${scf_path}
    ${meas_period}=    scf.Get Value from SCF    p_name=reportingIntervalPm
    scf.Save SCF    file_path=${scf_path}
    ${meas_period}=    Evaluate    int(${meas_period[:-3]}) * 60
    Set To Dictionary    ${P_MEAS_PERIOD}    gnb_${gnb_id}    ${meas_period}
    Set Suite Variable    ${P_MEAS_PERIOD}
    Builtin.Log     ${gnb_id}

Validate Rach PM Counters
    ${pi_list}=  Create List  M55306C09005  M55306C09006  M55306C09008
    ${index_list}=  Create List  0  1  2  3  4  5  #Extracts PM Counter values from last 6 PM Intervals
    ${actual_pm_values}=  Get Counter Value  pi_dir=${OUTPUT_DIR}/PMC/gnb_pm_counters  dist_name=CELLS/NRCELL-1/NRACH
    ...  pi_list=${pi_list}  index=${index_list}
    ${ues_in_pm_interval}=  Create Dictionary  0=${0}  1=${2}  2=${4}  3=${4}  4=${4}  5=${0}
    ${verdict}=  pm_analyzer.counter_verdict_generator_ul  actual_pm_values=${actual_pm_values}  ues_in_pm_interval=${ues_in_pm_interval}
    Should contain  True  ${verdict}


Attach and do CFRA_HO
    [Arguments]     ${ue_id}     #${count}={1}
    ${gnb2}     set Variable    enb_x2_link_up enb=1 target=2
    ${output}   ute_wtssim.Execute Egate Command    cmd=${gnb2}
#    Log To Console ${output}
    sleep   3s
    ${gnb3}     set Variable    enb_x2_link_up enb=1 target=3
    ${output}   ute_wtssim.Execute Egate Command    cmd=${gnb3}
#    Log To Console ${output}
    sleep   3s
    ${attach}   set Variable    ue_attach id=${ue_id}
    ${output}   ute_wtssim.Execute Egate Command    cmd=${attach}
#    Log To Console ${output}
    sleep   3s
    ${endc}     Set Variable     ue_dc_enb_start ue=${ue_id} target_gnb=3 target_cells=3 bearer=2 type=split_scg
    ${output}   ute_wtssim.Execute Egate Command    cmd=${endc}
#    Log To Console ${output}
    sleep   3s
    ${meas}     Set Variable    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${output}   ute_wtssim.Execute Egate Command      cmd=${meas}
#    Log To Console ${output}
    sleep   3s
    ${ho}   Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=${ue_id}
    ...     srsrq_nr=${ue_id} phycell_id=50 nrsrp_nr=30 nrsrq_nr=20
    ${output}   ute_wtssim.Execute Egate Command    cmd=${ho}
#    Log To Console ${output}
    sleep   3s
    ${detach}   set Variable    ue_detach id=${ue_id}
    ${output}   ute_wtssim.Execute Egate Command    cmd=${detach}
#    Log To Console ${output}


Attach and do CBRA_HO
    [Arguments]     ${ue_id}     #${count}={1}
    ${gnb2}     set Variable    enb_x2_link_up enb=1 target=2
    ${output}   ute_wtssim.Execute Egate Command    cmd=${gnb2}
#    Log To Console ${output}
    sleep   3s
    ${gnb3}     set Variable    enb_x2_link_up enb=1 target=3
    ${output}   ute_wtssim.Execute Egate Command    cmd=${gnb3}
#    Log To Console ${output}
    sleep   3s
    ${attach}   set Variable    ue_attach id=${ue_id}
    ${output}   ute_wtssim.Execute Egate Command    cmd=${attach}
#    Log To Console ${output}
    sleep   3s
    ${endc}     Set Variable     ue_dc_enb_start ue=${ue_id} target_gnb=3 target_cells=3 bearer=2 type=split_scg
    ${output}   ute_wtssim.Execute Egate Command    cmd=${endc}
#    Log To Console ${output}
    sleep   3s
    ${meas}     Set Variable    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${output}   ute_wtssim.Execute Egate Command      cmd=${meas}
#    Log To Console ${output}
    sleep   3s
    ${ho}   Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=${ue_id}
    ...     srsrq_nr=${ue_id} phycell_id=50 nrsrp_nr=30 nrsrq_nr=20
    ${output}   ute_wtssim.Execute Egate Command    cmd=${ho}
#    Log To Console ${output}
    sleep   3s
    ${detach}   set Variable    ue_detach id=${ue_id}
    ${output}   ute_wtssim.Execute Egate Command    cmd=${detach}
#    Log To Console ${output}
