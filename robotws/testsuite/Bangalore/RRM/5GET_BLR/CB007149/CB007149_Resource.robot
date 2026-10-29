*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Samik Sarkar
...              :contact: samik.sarkar@nokia.com

Variables    ta5g_global_var

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library          taf.sbts.oam.coam.admin         WITH NAME   ute_adm
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
#Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          OperatingSystem
Library          String
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ./resources/python/l1b_tag_gnb.py



#Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
#Resource         ../../resources/robot/Airphone.robot
#Resource         ../../resources/robot/WTS_Runner_Keywords.robot
#Resource         ../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
#Resource         ../../resources/robot/PM_Counters.robot
#Library          taf.transport.ssh           WITH NAME    taf_ssh
#Library          taf.wts.runner              WITH NAME    wtsrunner
#Resource         taf/rfrl/common_resources/robot/coam.robot
#Resource         ../../resources/robot/Setup_Env.robot
#Library          ../../resources/python/BIP_Capture.py
#Library          ../../resources/python/CPRT_Capture.py
#Library          ../../resources/python/avg_dl_data.


*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22

${nsa_nr_cap_band3}       SEPARATOR=
...                       E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C200141F00B586368E9
...                       315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E026AA9C06AA9C000210600172687C03904000002904000
...                       00A90400001292500001A601F056F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB2928200009
...                       2CA4A480002A965250174172E9565D03C9A55934AB22BB902401E0068040200000020

${nsa_nr_mrdc_band3}       A10181102C0C03804000000888160641C460000024400401C0022002100008040401803080008020200C0180

${sa_nr_cap_band3}         SEPARATOR=
...                        E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600141F00B586368E93
...                        15047F2CA49940E0416C9824060C78C7FE618F28581C0E1E026AA9C06AA9C0010000000000210600172687C039040000
...                        0290400000A90400001292500001A601F056F2A6F032B7480282000012CA48080000CB29202000052CA48080001CB292
...                        82000092CA48480002A965240174162E9545D0389A55134AA22BB102401E0068040200000020

${nsa_nr_cap_band28}       SEPARATOR=
...                        E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C200141F06F586368E931
...                        5047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E026AA9C06AA9C000210600DF2687C0390400000290400000A90
...                        400001292500001A601F056F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480
...                        002A965250174172E9565D03C9A55934AB22BB902401E0068040200000020

${nsa_nr_mrdc_band28}      A10181102C0C03836000000888160641C460000024400401C01B2002100008040401803080008020200C0180

${sa_nr_cap_band28}        SEPARATOR=
...                        E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600141F06F586368E931504
...                        7F2CA49940E0416C9824060C78C7FE618F28581C0E1E026AA9C06AA9C0010000000000210600DF2687C03904000002904000
...                        00A90400001292500001A601F056F2A6F032B7480282000012CA48080000CB29202000052CA48080001CB29282000092CA48
...                        480002A965240174162E9545D0389A55134AA22BB102401E0068040200000020

${nsa_nr_cap_band66_1}     SEPARATOR=
...                        E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C200141F107586368
...                        E9315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E026AA9C06AA9C0002106020F2687C0390400000290
...                        400000A90400001292500001A601F056F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB2928
...                        2000092CA4A480002A965250174172E9565D03C9A55934AB22BB902401E0068040200000020

${nsa_nr_cap_band66}       SEPARATOR=
...                        E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F883AC31B474
...                        98A823F96526CA01105B260901831E31FF9863CA16070387809ABA701ABA700008418083C9A1F00E41000000A4100
...                        0002A41000004A494000069807C15BCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A080
...                        0024B292920000AA5949405D05CBA559740F269564D2AC8AEE40107801A010080000008


${nsa_nr_mrdc_band66}      A10181102C0C03882000000888160641C460000024400401C041200210000804040080108000802020040080

${sa_nr_cap_band66}        SEPARATOR=
...                        E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600141F107586368
...                        E9315047F2CA49940E0416C9824060C78C7FE618F28581C0E1E026AE9C06AE9C001007882001C4100000000420C04
...                        1F413003800241C140180F82400603E00482000001001C15A0002000012CA4800682C509007801A01008000000000
...                        0600400C0080108

${nsa_nr_cap_band25}       SEPARATOR=
...                        E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C200141F063586368
...                        E9315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E026AE9C06AE9C000210600C72687C0390400000290
...                        400000A90400001292500001A601F056F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB2928
...                        2000092CA4A480002A965250174172E9565D03C9A55934AB22BB902401E0068040200000020

${nsa_nr_mrdc_band25}      A10181102C0C03830000000888160641C180000024400401C0182002100008040401803080008020200C0180

${sa_nr_cap_band25}        SEPARATOR=
...                        E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600141F063586368
...                        E9315047F2CA49940E0416C9824060C78C7FE618F28581C0E1E026AE9C06AE9C001007830001C1800000000420C01
...                        9F413003800241C140180F82400603E00482000001001C15A0002000012CA4800682C509007801A01008000000000
...                        0600400C0080108

${nsa_nr_cap_band1}       SEPARATOR=
...                       E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F801AC31B47498A823F965
...                       26CA01105B260901831E31FF9863CA16070387809AAA701AAA700008418001C9A1F00E41000000A41000002A41000004A494000
...                       069807C15BCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000AA5949405D05CBA5
...                       59740F269564D2AC8AEE40107801A010080000008

${nsa_nr_mrdc_band1}      A10181102C0C03830000000888160641C1B0000024400401C0182002100008040401803080008020200C0180

${sa_nr_cap_band1}        SEPARATOR=
...                       E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F801AC31B47498A823F96524
...                       CA01105B260901831E31FF9863CA16070387809AAA701AAA7000400000000008418001C9A1F00E41000000A41000002A41000004A
...                       494000069807C15BCA9BC0CADD200A0800004B29202000032CA480800014B29202000072CA4A0800024B292120000AA5949005D05
...                       8BA551740E269544D2A88AEC40107801A010080000008

*** Keywords ***
## Delta Commissioning
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

Change IPHY File Value
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    Run    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  300s

Change CFG File Value
    [Arguments]    ${file_path}    ${ul_arfcn}   ${dl_arfcn}    ${sa_cap}   ${nsa_nr_cap}   ${nsa_mrdc_cap}
    ${x}    Set Variable    nr_arfcn
    ${y}    Set Variable    nr_arfcn=
    ${z}    Catenate    SEPARATOR=:   ${ul_arfcn}   ${dl_arfcn}
    ${nsa_pat}  Set Variable       ue_eutra_nr_capabilities
    ${sa_pat}   Set Variable       ue_nr_capabilities
    Run    cat ${file_path}|grep -m 1 "${x}"|awk -F'${y}' '{print $2 }'|awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${z}/g' ${file_path}
    #Below is for SA cap changes
    Run    cat ${file_path}|grep -m 1 "${sa_pat}"|awk -F'${sa_pat}=' '{print $2}'|xargs -I {} sed -i 's/{}/${sa_cap}/' ${file_path}
    #Below is for NSA cap changes
    #NSA_UE_NR cap changes
    ${cmd1}    Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${SPACE}${SPACE}dual_conn=eutra_nr' '{print $1}'
    ${cmd2}    Set Variable    |awk -F'${sa_pat}=' '{print $2}'|xargs -I {} sed -i 's/{}/${nsa_nr_cap}/g' ${file_path}
    ${cmd}     Set Variable    ${cmd1}${cmd2}
#   Run    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${SPACE}${SPACE}dual_conn=eutra_nr' '{print $1}'|
#   ...    awk -F'${sa_pat}=' '{print $2}'|xargs -I {} sed -i 's/{}/${nsa_nr_cap}/g' ${file_path}
    Run    ${cmd}
    #NSA DC cap changes
    Run    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${nsa_pat}=' '{print $2}'|xargs -I {} sed -i 's/{}/${nsa_mrdc_cap}/g' ${file_path}


Check Cell On Air
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                   file=${wts_cfg_file}
    wtsrunner.read_wtsemu_output_until_re    expected=Airphone: Cell Setup completed     timeout=240

NSA UE Attach  #NSA
    [Arguments]    ${UE_ID}    ${chk_fail}=${-1}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
#    ${fail_pt}    Set Variable    UE${UE_ID}: No band combinations in MR-DC capabilities*
    ${fail_pt}    Set Variable    value Cause : radioNetwork : tDCprep-expiry
    ${pattern}    Set Variable If    ${chk_fail}!=${-1}    ${fail_pt}    ${UE_attach_pattern}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${pattern}    ${Timeout_NSA}
    [Return]      ${output}

MultiUE Attach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${chk_fail}=${-1}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
#    UE Attach should be Successful    ${ue_id}
    NSA UE Attach    ${UE_ID}    chk_fail=${chk_fail}
    END

MultiUE DL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger DL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${dl_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE UL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${ul_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger UL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${ul_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE DL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    dl    ${trf_id}
    END

MultiUE UL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    ul    ${trf_id}
    END

MultiUE Detach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Detach should be Successful    ${ue_id}
    END

Unsupported UE Capabilty SA
    [Arguments]    ${ue_id}
    ${x}    Set Variable    UE${ue_id}: Will use unsupported native band
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${x}    ${60}

MultiUE Validate UL Traffic For NSA
    [Arguments]    ${st_ue_id}    ${en_ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
    Validate UL Traffic For NSA    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    END

MultiUE Validate DL Traffic For NSA
    [Arguments]    ${st_ue_id}    ${en_ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
    Validate DL Traffic For NSA    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    END

Start Collecting Syslog
    [Arguments]    ${NAME}      ${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable     ${LOG_PATH}/
    set suite variable      ${CURRENT_SYSLOG_PATH}
    set suite variable      ${logname}     syslog_${NAME}.log
    ta5g_syslog.Start Syslog  log_dir=${CURRENT_SYSLOG_PATH}  log_name=${logname}   ip=192.168.255.126
    ...       ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAME}

Stop Collecting Syslog
    [Arguments]    ${NAME}
    ${file_path}    ta5g_syslog.Collect Syslog Results    alias=${NAME}
    [Return]      ${file_path}

Start L2 BIP Trace Capturing
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set suite variable    ${CaptureL1L2}    ${capture_l1l2}
    Set L1L2 capture  ${CaptureL1L2}

Start CPRT Trace Capturing
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set suite variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}

Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init        ${capture_var_cprt}
    Capture start       ${capture_var_cprt}

Set L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture.Modify BIP Script File    ${BIP_SCRIPT_PATH}
    Capture init        ${capture_var_l1l2}
    Capture start       ${capture_var_l1l2}

Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop        ${capture_var_cprt}

Stop L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture stop        ${capture_var_l1l2}

