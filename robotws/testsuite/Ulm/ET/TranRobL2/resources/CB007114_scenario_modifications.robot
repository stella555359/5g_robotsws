*** Settings ***
Documentation    Scenario specific keywords for 7114
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    OperatingSystem

Library    taf.config.wts                              WITH NAME    wts
Library    taf.config.scf                              WITH NAME    scf
Library    taf.transport.ssh                           WITH NAME    ssh
Library    taf.sbts.oam.coam.admin                     WITH NAME    admin
Library    ../libraries/vendor_file_modifier.py        WITH NAME    vendor_file_modifier
Library    ../../L2/libraries/template_functions.py    WITH NAME    template
Resource   ../../../resources/Common/gnb.robot
Resource   ../../../resources/Common/testline.robot
Resource   ../../../resources/Common/wts_ue.robot
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***

Update Basic Configuration File
    IF    'CB007114-G-MAX' in '${SUITE_NAME}'    Update UE Capability String in Basic Cfg file ASOH
    ...   ELSE    Update UE Capability String in Basic Cfg file
    IF    'TranRob Endurance Pooling Fdd' in '${SUITE_NAME}'    Insert New Sim Parameter


Run Feature Specific Keywords Before Attach
    [Documentation]
    ...    configure low pathloss and activate ul sinr testmode for all UEs to get AP OLPC workigng like real UE

    wts_ue.Send Egate Command And Verify Output    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=60
    # Print configuration in egate log
    wts_ue.Send Egate Command And Verify Output    cmd=ul_sinr_testmode_nr profile_id=1

    @{ue_ids}=    template.get_ue_ids_configured_for_scenario    ${scenario_name}

    FOR    ${ue_id}   IN    @{ue_ids}
			wts_ue.Send Egate Command and verify output  ue_testmode_set_nr id=${ue_id} scell=5 testmode=ul_sinr profile_id=1 action=activate
			Log To Console  ue_testmode_set_nr id=${ue_id} scell=5 testmode=ul_sinr profile_id=1 action=activate
    END

Run Feature Specific Keywords After Attach Before Traffic Is Started
    RETURN


Run Feature Specific Keywords During Traffic Before Detach
    [Arguments]  ${traffic_duration}
    ${starttime_traffic}=  DateTime.Get Current Date  UTC
    Log To Console  Traffic started at ${starttime_traffic} UTC
    Log To Console  Traffic duration: ${traffic_duration}


Run Feature Specific Keywords After Traffic Before detach
    ${attached_ue_list}=    template.Get_Ue_Ids_Configured_For_Scenario    scenario_name=${scenario_name}
    Sort List  ${attached_ue_list}
    Set Test Variable    ${attached_ue_list}
    ${string_attached_ue_list}=    Catenate    SEPARATOR=,    @{attached_ue_list}
    Set Test Variable    ${string_attached_ue_list}
    Log To Console    Attached UE's: ${string_attached_ue_list}
    wts_ue.Send Egate Command And Verify Output    ue_stats_nr id=${string_attached_ue_list} type=pdsch,pusch scell=0-5 delay=60000
    Log To Console    ue_stats_nr id=${string_attached_ue_list} type=pdsch,pusch scell=0-5 delay=60000

    TRY
        Display Traffic Data Rate
    EXCEPT    AS    ${error}
        LOG  Error in "Display Traffic Data Rate": ${error}  level=ERROR  console=yes
    END


 Display Traffic Data Rate
     ${bearer_stats_attribs_nsa}  ${_} =  template.Get_Bearer_Stat_Params  scenario_name=${scenario_name}
     ${tp}=  wts_ue.Get Bearer Stats From Egate
     ...  ue_id=${bearer_stats_attribs_nsa["ues"]}  trf_id=${bearer_stats_attribs_nsa["trf_ids"]}
     ...  id=${bearer_stats_attribs_nsa["bearers"]}
     Log To Console    Current DL throughput for all NSA UEs is ${tp} bps
     ${_}  ${bearer_stats_attribs_sa}=  template.Get_Bearer_Stat_Params  scenario_name=${scenario_name}
     ${tp}=  wts_ue.Get Bearer Stats From Egate
     ...  ue_id=${bearer_stats_attribs_sa["ues"]}  trf_id=${bearer_stats_attribs_sa["trf_ids"]}  pdu=${bearer_stats_attribs_sa["pdus"]}
     ...  qfi=${bearer_stats_attribs_sa["qfis"]}
     Log To Console    Current DL throughput for all SA UEs is ${tp} bps


Override UE CSI Report For All UEs
    [Arguments]    @{}  ${nr_cqi}=10  ${rank}=0
    wts_ue.Update UE Channel State Information  profile_id=1  cqi=${nr_cqi}  cqi_mode=fixed  ri_mode=fixed  ri=${rank}


Run Scenario Specific Keywords Before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}
    Log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords after detach
    RETURN
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Make Necessary Changes To SCF
    [Documentation]
    scf.load_scf    ${original_gnb_scf}
    Enable Scheduled UE Pooling
    Change Reporting Interval  interval_duration=${pm_reporting_interval}
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    IF  'CB007114-G-MAX' not in '${SUITE_NAME}'  Modify Vendor File and Perform Commissioning
    ...   ELSE   commissioning.Execute Full Commissioning  scf_path=${configuration_directory}/SCF_updated.xml


Enable Scheduled UE Pooling
    #  Create objects and Elements:
    Log  Enabling Scheduled UE Pooling  console=yes
    ${distName_NRBTS}=    gnb.Get DistNames From gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    scf.Modify Scf Element    dist_name=${distName_NRBTS[0]}      p_name=actScheUePooling    value=true
    scf.Modify Scf Element    dist_name=${distName_NRBTS[0]}      p_name=actConnRrcPooling    value=true
    ${distName_NRCELL}=    gnb.Get DistNames From gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        scf.Modify Scf Element    dist_name=${dist_name}      p_name=maxNumPdschAllocationPerSlot    value=4
        scf.Modify Scf Element    dist_name=${dist_name}      p_name=maxNumPuschAllocationPerSlot    value=4
        scf.Modify Scf Element    dist_name=${dist_name}      p_name=actLongPucchPhase2              value=true
    END
    ${distName_PDCCH}=    gnb.Get DistNames From gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]+/PDCCH-[0-9]+
    FOR  ${dist_name}  IN  @{distName_PDCCH}
        scf.Modify Scf Element    dist_name=${dist_name}      p_name=dciDedicatedAggregationLevel    value=AL4
    END
    ${distName_dedic_PDCCH}=    gnb.Get DistNames From gNB SCF
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]+/PDCCH-[0-9]+/PDCCH_CONFIG_DEDICATED-[0-9]+
    FOR  ${dist_name}  IN  @{distName_dedic_PDCCH}
        scf.Modify Scf Element    dist_name=${dist_name}      p_name=numOfPdcchCandidatesInAL1    value=n0    index=0
        scf.Modify Scf Element    dist_name=${dist_name}      p_name=numOfPdcchCandidatesInAL1    value=n2    index=1
    END
    Log  Parameters for Scheduled UE Pooling changed successfully  console=yes


Modify Vendor File And Perform Commissioning
    [Documentation]   This  keyword should be used to modify vendor file.
    ...    Due to AirPhone over ABIL FS limitations, the default values of the vendor file parameters are modified to lower values in order\
    ...    to be able to observe UE pooling even with lower number of UEs. Values used should be mentioned in the test plan.
    ${oam_alias}=    connect.Setup OAM http session
    ${vendor_path}=    Set Variable    ${configuration_directory}/vendor_lte.xml
    admin.download_vendor_file    target_file_name=${vendor_path}    connection=${oam_alias}
    Backup Vendor File    file_path=${vendor_path}
    Modify L1 BbPool Capacity In Vendor File
    IF    'CB007114-E' in '${SUITE_NAME}'
        Modify BbPoolMode in Vendor File to round-robin
    ELSE IF    'CB007114-G-MIN' in '${SUITE_NAME}'
        Modify BbPoolMinResource
    ELSE IF    'CB007114-G-EQU' in '${SUITE_NAME}'
        Modify L2 BbPool Capacity In Vendor File
    END
    admin.set_vendor_file    vendor_file=${vendor_path}    connection=${oam_alias}
    admin.perform_commissioning    scf_file=${configuration_directory}/SCF_updated.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=False  timeout=300
    connect.Teardown OAM http session


Backup Vendor File
    [Arguments]  ${file_path}
    Copy File	${file_path}  ${file_path}.bkp


Modify L1 BbPool Capacity In Vendor File
    ${common_unit_type}=    testline.Get Common Unit Type
    ${capacity_unit_type}=    testline.Get Capacity Unit Type
    ${hw_variant}=    Set Variable If  '${common_unit_type}'=='ASOH'     ${common_unit_type}     ${capacity_unit_type}
    ${filter_criteria}=    Create Dictionary
    ...  bbHwVariant=${hw_variant}
    ...  confDuplexMode=FDD
    ${data_to_be_modified}=    Create Dictionary
    ...  maxNumScheUePdschL1Pool=16
    ...  maxNumScheUePdschL1Sp=8
    ...  maxNumScheUePuschL1Pool=16
    ...  maxNumScheUePuschL1Sp=8
    ${path_to_xml}=  vendor_file_modifier.Get_Xml_Path_For_List  listname=BbPoolCapacity
    vendor_file_modifier.Modify_Vendor_File
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  xml_path=${path_to_xml}


Modify L2 BbPool Capacity In Vendor File
    ${common_unit_type}=    testline.Get Common Unit Type
    ${capacity_unit_type}=    testline.Get Capacity Unit Type
    ${hw_variant}=    Set Variable If  '${common_unit_type}'=='ASOH'     ${common_unit_type}     ${capacity_unit_type}
    ${filter_criteria}=    Create Dictionary
    ...  bbHwVariant=${hw_variant}
    ...  confDuplexMode=FDD
    IF    'CB007114-G-MAX' in '${SUITE_NAME}'
        ${data_to_be_modified}=    Create Dictionary
                                   ...  maxNumScheUePdschL2Sp=5
                                   ...  maxNumScheUePuschL2Sp=5
    ELSE
        ${data_to_be_modified}=    Create Dictionary
                                   ...  maxNumScheUePdschL2Sp=3
                                   ...  maxNumScheUePuschL2Sp=3
    END
    ${path_to_xml}=  vendor_file_modifier.Get_Xml_Path_For_List  listname=BbPoolCapacity
    vendor_file_modifier.Modify_Vendor_File
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  xml_path=${path_to_xml}


Modify BbPoolMode in Vendor File To Round-robin
    ${filter_criteria}=    Create Dictionary
    ...  BbPoolMode=load-metric
    ${data_to_be_modified}=    Create Dictionary
    ...  BbPoolMode=round-robin
    ${path_to_xml}=  vendor_file_modifier.Get_Xml_Path_For_BbPoolMode
    vendor_file_modifier.Modify_Vendor_File
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  xml_path=${path_to_xml}


Modify BbPoolMinResource
    [Arguments]    ${BbPoolMinResource}=50
    ${filter_criteria}=    Create Dictionary
    ...  BbPoolMinResource=10
    ${data_to_be_modified}=    Create Dictionary
    ...  BbPoolMinResource=${BbPoolMinResource}
    ${path_to_xml}=  vendor_file_modifier.Get_Xml_Path_For_BbPoolMinResource
    vendor_file_modifier.Modify_Vendor_File
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  xml_path=${path_to_xml}
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Change Reporting Interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=  gnb.Get DistNames From gNB SCF  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrCellAvailability
    scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrCellUtilization
    scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrTimingAdvance
    scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrUlSignalQuality
    scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=miNrUlHarq
    ${distName_PMCADM}=  gnb.Get DistNames From gNB SCF  regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm


Update UE Capability String In Basic Cfg file
    ${ue_capability_sa}=  Catenate  SEPARATOR=${EMPTY}  E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600141F11B5863
    ...    68E9315047F2CA49940E0416C9824060C78C7FE618F28581C0E1E026761D86761D802001800000000388C00000000841808DC9A1F00E41000000A41000002A41000004A4
    ...    94000069805C0CBC8CADD200A0800004B29202000032CA480800014B29202000072CA4A0800024B292120000AA5949004D038BA471742A269544576204803C00D0080400
    ...    00000000100200420

    ${ue_capability_nsa}=  Catenate  SEPARATOR=${EMPTY}  E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C200141F11B586
    ...    368E9315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E0227009C000210602372687C0390400000290400000A90400001292500001A601F032F2A2F032B7480
    ...    282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501740F2E9565D03C9A55934AB22BB902401E00680402000000200
    wts.Load Wts Cfg        /opt/iphy/latest/basic_setup.cfg
    wts.Modify              ue_param id=1
    ...  ue_nr_capabilities=${ue_capability_sa}
    wts.Modify              ue_param id=11
    ...  ue_nr_capabilities=${ue_capability_nsa}
    wts.Save Wts Cfg        /opt/iphy/latest/basic_setup.cfg


Update UE Capability String In Basic Cfg File ASOH
    ${ue_capability_sa}=  Catenate  SEPARATOR=${EMPTY}  E1A01000014F5E0302C00203401208367130F8505026C020FFCC31E50B03826010188A0300A63000A0F805AC31B
    ...    47498A823F96524CA03082D930480C18F18FFCC31E50B0381C3C04CEC3B0CEC3B004003000000000700800000001083000B9343E01C82000001482000005482000009492
    ...    80000D300B81B791B5BA40141000009652504000065949410000296525040000E594941000049652524000154B292809A075748EAE8554D2AA8AED40501E006804020000
    ...    000000080100210

    ${ue_capability_nsa}=  Catenate  SEPARATOR=${EMPTY}  E1201000014F5E0302C00203401208367130F8505026C020FFCC31E50B03826010188A0300A61000A0F805AC31
    ...   B47498A823F96526CA03082D930480C18F18FFCC31E50B0381C3C044E0138000420C002E4D0F80720800000520800001520800002524A000034C03E06DE54DE06D6EB0050
    ...   4000025949410000196525040000A594941000039652504000125949490000552CA4A02E81E5D2ACBA07574AB26956457720280F00340201000000100
    wts.Load Wts Cfg        /opt/iphy/latest/basic_setup.cfg
    wts.Modify              ue_param id=1
    ...  ue_nr_capabilities=${ue_capability_sa}
    wts.Modify              ue_param id=11
    ...  ue_nr_capabilities=${ue_capability_nsa}
    wts.Save Wts Cfg        /opt/iphy/latest/basic_setup.cfg


Insert New Sim Parameter
    ${command}=     Set Variable     sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled
    ${location}=    Set Variable     sim_param_set NR_PDCP_CIPHERING=distributed
    wts.Load Wts Cfg        /opt/iphy/latest/basic_setup.cfg
    wts.insert    ${command}    after    ${location}
    wts.Save Wts Cfg        /opt/iphy/latest/basic_setup.cfg
