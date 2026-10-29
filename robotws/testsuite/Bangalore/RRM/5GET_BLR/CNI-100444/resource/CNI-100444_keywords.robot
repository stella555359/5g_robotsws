*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Sruthi
...              :contact:  sruthi.jacob@nokia.com

Variables    ta5g_global_var
#Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource          ../../resources/robot/TTI_Traces.robot
Resource        ../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../../resources/robot/Setup_Env.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
Resource        ../../CB008285/CB008285_Resource.robot
Resource        ../../CB008116_CLASSICAL/basic_resource.robot
Resource        ../../CB009827/resources/CB009827_Keywords.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
#Library          ute_admin                         WITH NAME   ute_adm
Library          taf.sbts.oam.coam.admin     WITH NAME   ute_adm
Library          Collections
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          OperatingSystem
Library          String
Library          ../../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
Library           luashark_tools.analyzer       WITH NAME       analyzer
Library          DateTime

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22
#   Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3	4	5 	6	7	8	9	10	11	12	13	14	15
&{profiles_mapping}     null=NIA0   snow3g=NIA1   aes=NIA2    zuc=NIA3

*** Keywords ***
 Trigger MAC-I corruption
   [Arguments]    ${ue_id}    ${integrityProt_macI_corruption_string}
   wtsrunner.ue_param  id=${ue_id}    integrityProt_macI_corruption=${integrityProt_macI_corruption_string}
   sleep    5s
   ${wts_output}   wtsrunner.read_wtsemu_output_until_re    expected=UE${ue_id}: IS IDLE   timeout=30
   ${wts_output}   Get Lines Matching Regexp    ${wts_output}
   ...            [NgLink::OnReceiveUeContextReleaseRequest]::Received UE CONTEXT RELEASE REQUEST from GNB-2 handled successfully

Verify CNI-100444 PM Counter
    [Arguments]    ${feature_id}   ${counter_id}      ${expected_value}=0
    Log To Console  ${feature_id}   ${counter_id}      ${expected_value}
    sleep    240s
    ${PM_dir_1}=    Fetch PM Counter
    Validate PM counter value is bigger than given value   PM_dir=${PM_dir_1}    PM_counter=${counter_id}    expected_value=0    moc=NRCELL-3
    Validate PM counter value is bigger than given value   PM_dir=${PM_dir_1}    PM_counter=${counter_id}    expected_value=0    moc=NRCELL-4
Fetch PM Counter
      ${PM_dir_1}=  PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
      [Return]    ${PM_dir_1}
Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage: Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}     ${IP}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
        SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection
