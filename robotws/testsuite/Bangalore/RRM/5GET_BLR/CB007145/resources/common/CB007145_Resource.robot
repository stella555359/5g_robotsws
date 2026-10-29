*** Settings ***
Documentation    :copyright: Nokia
...              :authors: XXX
...              :contact: XXX

Variables    ta5g_global_var
#Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../resources/robot/TTI_Traces.robot
Resource         ../../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ../../../resources/ECEcommon/common_setup_teardown.robot
Resource         ../../../resources/robot/common_log_collection.robot

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library          ute_admin                         WITH NAME   ute_adm
Library          Collections
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          OperatingSystem
Library          String
Library          ../../../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../../../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
Library          ../python/utility.py
Library         ../../../resources/python/ssh_command.py

Library          DateTime
#Library          ./resources/python/l1b_tag_gnb.py

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22

${nsa_nr_cap_band66}       SEPARATOR=
...                        E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C200141F107586368E9
...                        315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E026AA9C06AA9C0002106020F2687C03904000002904000
...                        00A90400001292500001A601F066F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB2928200009
...                        2CA4A480002A9652501741B2E9565D03C9A55934AB22BB902401E0068040200000020

${nsa_nr_mrdc_band66}       A10181102C0C03882000000888160641C460000024400401C041200210000804040080108000802020040080

${sa_nr_cap_band66}         SEPARATOR=
...                         E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F883AC31
...                         B47498A823F96524CA01105B260901831E31FF9863CA16070387809BFF701BFF7000400E20800000001010793
...                         43E00482000001001C19A0002000012CA4800683450107801A010080000000000200400840


${nsa_nr_cap_band25}       SEPARATOR=
...                        E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F831AC31B47
...                        498A823F96526CA01105B260901831E31FF9863CA16070387809AAA701AAA700008418031C9A1F00E41000000A41
...                        000002A41000004A494000069807C19BCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A
...                        0800024B292920000AA5949405D06CBA559740F269564D2AC8AEE40107801A010080000008

${nsa_nr_mrdc_band25}      A10181102C0C03830000000888160641C180000024400401C018200210000804040080108000802020040080

${sa_nr_cap_band25}        SEPARATOR=
...                        E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F831AC31B47
...                        498A823F96524CA01105B260901831E31FF9863CA16070387809BFF701BFF7000400E0C00000000100639343E004
...                        82000001001C19A0002000012CA4800683450107801A010080000000000200400840

${nsa_nr_cap_band28}       SEPARATOR=
...                        E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F837AC31B474
...                        98A823F96526CA01105B260901831E31FF9863CA16070387809AAA701AAA700008418037C9A1F00E41000000A4100
...                        0002A41000004A494000069807C19BCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A080
...                        0024B292920000AA5949405D06CBA559740F269564D2AC8AEE40107801A010080000008

${nsa_nr_mrdc_band28}      A10181102C0C03836000000888160641C460000024400401C01B200210000804040080108000802020040080

${sa_nr_cap_band28}        SEPARATOR=
...                        E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F837AC31B474
...                        98A823F96524CA01105B260901831E31FF9863CA16070387809BFF701BFF7000400E0D800000001006F9343E00482
...                        000001001C19A0002000012CA4800683450107801A010080000000000200400840




*** Keywords ***
## Delta Commissioning
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size    ${AP_ASIK.ip}    ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

#Start Log Collection
#    Start Collecting Syslog     NAME=scell_add
#    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
#
#Stop Log Collection
#    Run Keyword and Ignore error   Stop Collecting Syslog      NAME=scell_add
#    Run Keyword and Ignore error   Stop L1L2 capture  ${CaptureL1L2}
#    Run Keyword and Ignore error   Stop CPRT capture   ${CaptureCPRT}
#    Run Keyword and Ignore error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
#    Run Keyword and Ignore error   Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_scell_add.pcap




Get And Update RU Details for CA
    [Arguments]    ${old_ru_type}   ${new_ru_type}  ${new_ru_code}      ${gscn}     ${positn}   ${skip}=${-1}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD.*xml$|awk '{ print $9 }'
	#${targetbd_fn}	Set variable	TargetBD_SBTS23R1_ENB_9999_220527_000008.xml
	${c1}      Set Variable     ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD.*xml$|awk '{ print $9 }'|
	${c2}      Set Variable     xargs -I {} scp toor4nsn@192.168.255.129:/ffs/run/{} .
	Run     ${c1}${c2}
    ${c1}      Set Variable     cat ${targetbd_fn}|grep ${new_ru_type}|grep resourceBuildKey|awk '{print $2}'|
    ${c2}      Set Variable     awk -F '=' '{print $2}'|sed s/\\"//g
	${resourceBuildKey}=    Run    ${c1}${c2}
    Log To console      ${resourceBuildKey}
    ${c1}    Set Variable    cat ${targetbd_fn}|grep ${new_ru_type}|grep resourceSWVersion|awk '{print $6}'|
    ${c2}    Set Variable    awk -F'=' '{print $2}'|sed 's/\\"//g;s/>//g'
    ${resourceSWVersion}=    Run    ${c1}${c2}
    Log To console      ${resourceSWVersion}
    ${c1}    Set Variable       cat ${targetbd_fn}|grep ${new_ru_type}|grep -m 1 swFileKey|awk -F '>' '{print $2}'|
    ${c2}    Set Variable       awk -F '<' '{print $1}'
    ${swFileKey}=   Run    ${c1}${c2}
    Log To console      ${swFileKey}
    #product code
    ${c1}    Set Variable     cat ${file_path} |grep -A 4 ${old_ru_type}|grep productCode|awk -F '>' '{print $2}'|
    ${c2}    Set Variable     Run  awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${new_ru_code}/g' ${file_path}

    ${c1}    Set Variable    cat ${file_path} |grep ${old_ru_type}|head -n3|tail -n1|awk -F '>' '{print $2}'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${swFileKey}/g' ${file_path}
    Run     ${c1}${c2}
    #resourceBuildKey
    ${c1}    Set Variable    cat ${file_path} |grep ${old_ru_type}|head -n2|tail -n1|awk -F '>' '{print $2}'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${resourceBuildKey}/g' ${file_path}
    Run     ${c1}${c2}
    #bldVersion
    ${c1}    Set Variable    cat ${file_path} |grep -A 4 ${old_ru_type}|head -n5|tail -n1|awk -F '>' '{print $2}'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${resourceSWVersion}/g' ${file_path}
    Run     ${c1}${c2}
    #Card Name AEHC
    ${c1}    Set Variable    cat ${file_path} |grep ${old_ru_type}|head -n1|tail -n1|awk -F '>' '{print $2}'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${new_ru_type}/g' ${file_path}
    Run    ${c1}${c2}
    ${c1}    Set Variable    cat ${file_path} |grep "GSCN"|head -n${positn}|tail -n1|awk -F'GSCN>' '{print $2 }'|
    ${c2}    Set Variable    awk -F'<' '{print $1 }'|xargs -I {} sed -i 's/{}/${gscn}/' ${file_path}
    Run    ${c1}${c2}

    Send IPHY XML To Airphone   ${file_path}
    Run Keyword If   ${skip}==${-1}   Run    ssh toor4nsn@192.168.200.1 reboot

Change IPHY File Value
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  120s

Change IPHY File Value AP ABIO
      [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}

    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD_SBTS.*xml$|awk '{ print $9 }'
    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}
    ${new_version}   Run    cat ${target_bd_path} | grep -m 1 ${RU_TYPE}|awk -F resourceSWVersion= '{print $2}'|sed 's/"//g;s/>//g'
    FOR     ${i}    IN RANGE   3    5
    ${linenum}   Run    cat ${file_path} | grep -i card -n | awk 'NR==${i}{ print; }'|awk -F ':' '{print$1}'
    Run      sed -i '${linenum}s/AHLOA/${RU_TYPE}/g' ${file_path}
    ${linenum}   Run    cat ${file_path} | grep -i resourceBuildKey -n | awk 'NR==${i}{ print; }'|awk -F ':' '{print$1}'
    Run     sed -i '${linenum}s/AHLOA/${RU_TYPE}/g' ${file_path}

    ${linenum}   Run     cat ${file_path} | grep -i GSCN -n | awk 'NR==${i}{ print; }' | awk -F ':' '{print$1}'
    Run    sed -i '${linenum}s/1582/${GSCN}/g' ${file_path}
    ${linenum}   Run     cat ${file_path} | grep -i bldVersion -n|awk 'NR==${i}{ print; }'|awk -F ':' '{print$1}'
    ${old_version}      Run     cat ${file_path}| grep -m ${i} -i bldVersion |tail -n 1 | awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'
    Run    sed -i '${linenum}s/${old_version}/${new_version}/g' ${file_path}

    ${linenum}   Run     cat ${file_path} | grep -i buildversion -n | awk 'NR==${i}{ print; }'|awk -F ':' '{print$1}'
    ${old_version}      Run     cat ${file_path}| grep -m ${i} -i buildversion | tail -n 1 |awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'
    Run    sed -i '${linenum}s/${old_version}/${new_version}/g' ${file_path}
    END

     ${x}   ${y}    ssh_command.get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
    ...    ssh_command.update_iphy_7145    ${file_path}
    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s

Change CFG File Value
    [Arguments]    ${file_path}    ${ul_arfcn}   ${dl_arfcn}    ${sa_cap}   ${nsa_nr_cap}   ${nsa_mrdc_cap}
    ${x}    Set Variable    nr_arfcn
    ${y}    Set Variable    nr_arfcn=
    ${z}    Catenate    SEPARATOR=:   ${ul_arfcn}   ${dl_arfcn}
    ${nsa_pat}  Set Variable       ue_eutra_nr_capabilities
    ${sa_pat}   Set Variable       ue_nr_capabilities


    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${x}"|awk -F'${y}' '{print $2 }'|
    ${c2}   Set Variable    awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${z}/g' ${file_path}
    Run    ${c1}${c2}

    #Below is for SA cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${sa_pat}"|awk -F'${sa_pat}=' '{print $2}'|
    ${c2}   Set Variable    xargs -I {} sed -i 's/{}/${sa_cap}/g' ${file_path}
    Run    ${c1}${c2}
    #Below is for NSA cap changes
    #NSA_UE_NR cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${SPACE}${SPACE}dual_conn=eutra_nr' '
    ${c2}   Set Variable    {print $1}'|awk -F'${sa_pat}=' '{print $2}'|
    ${c3}   Set Variable    xargs -I {} sed -i 's/{}/${nsa_nr_cap}/g' ${file_path}
    Run    ${c1}${c2}${c3}
    #NSA DC cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${nsa_pat}=' '{print $2}'|
    ${c2}   Set Variable    xargs -I {} sed -i 's/{}/${nsa_mrdc_cap}/g' ${file_path}
    Run     ${c1}${c2}


MultiUE Attach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
    UE Attach should be Successful    ${ue_id}    3
    END

MultiUE Attach for NSA 2_Cell
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
    UE Attach should be Successful    ${ue_id}    1
    END

MultiUE DL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}=${Bearer_ID}
    ...     ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger DL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${dl_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

    Log To console      ${id}

MultiUE UL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${ul_rate}    ${id}=${Bearer_ID}
    ...     ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger UL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${ul_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

    Log To console      ${id}

MultiUE DL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    dl    ${trf_id}
    END

MultiUE UL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}      ul    ${trf_id}
    END

MultiUE Validate DL Traffic For NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Validate DL Traffic For NSA    ${ue_id}    ${dl_rate}   id=${Bearer_ID}
    END

MultiUE Validate UL Traffic For NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Validate UL Traffic For NSA    ${ue_id}    ${ul_rate}   id=${Bearer_ID}
    END


MultiUE Detach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Detach should be Successful   ${ue_id}
    END
Start and Stop TTI TRACE
    [Arguments]    ${duration}=${3}
    Start Ttitrace With Streaming Mode_3
    sleep    ${duration}s
    Stop Ttitrace

Collect TTI Trace
    [Arguments]    ${ttitrace_path}
    Convert Ttitrace From Pcap To Excelcsv        ${LOG_PATH}/${ttitrace_path}/
    Convert Tti To Csv Mode          ${LOG_PATH}/${ttitrace_path}

Convert Tti To Csv Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv

Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}
    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_VERSION}     22R1
    Set Suite variable   ${Branch_22R1}



