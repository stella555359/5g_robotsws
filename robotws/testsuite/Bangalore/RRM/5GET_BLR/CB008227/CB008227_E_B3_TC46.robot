*** Settings ***
Force Tags    CLOUD_5G_I_[LO][LO]_AP_[LOO]    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_TDD
...   PY36

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes the verification of NBR counters verfication IntergNB CA call with
...                                Pcell and Scell
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20682,CB_FIM_39326,CB_FIM_38153


Resource         CB008227_Resource.robot
Library      BuiltIn
Library      Collections
#Library      ute_admin_infomodel
Library      taf.ul.ue.sim.env_setup
Library      ./resource/get_host_addr.py
Library      ./resource/CB008227_keywords.py


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/IntergNB_T_F_iphy.xml
    ...        AND             Start Default Logging
    ...        AND             add gnb configuration  ${scfc_gnb1}   host_id=1
    ...        AND             add gnb configuration  ${scfc_gnb2}   host_id=2
    ...        AND             add 5gc     ${CURDIR}/config/IntergNB_wts.cfg     edaemon_ports=22222
    ...        AND             configure environment
    ...        AND             Setup Egate  egate_port=20000  alias=default

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup   Get gNB2 IP address

*** Variables ***
${LOCAL_MOID}=                    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${scfc_gnb1}=                     IntergNB_scf1.xml
${scfc_gnb2}=                     IntergNB_scf2.xml
${sa_ue_id1}      1
${sa_ue_id2}      2
${sa_ue_id3}      3
${sa_ue_id4}      4
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID2}    2
${QFI_ID3}    3
${QFI_ID4}    4
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4
${epc_log_path}    /tmp/
${TEST_NAME}        E_B3_TC46

*** Test Cases ***
CB008227-E#B3_TC46_NBR_interworking_with_IntergNB_DL_CA
    #Step1:Attach UE1 with NBR and UE2 with non-NBR
    Attach CA UE-${sa_ue_id1} with non-NBR bearer to TDD PCell
    Attach CA UE-${sa_ue_id2} with NBR bearer to TDD PCell
    #Step2:Trigger A1 measuremnt for Scell addtition
    UE Send A1 To Trigger 3CC CA setup   ${sa_ue_id1}
    UE Send A1 To Trigger 3CC CA setup   ${sa_ue_id2}
    #Step3:Start UL and DL traffic and verify Scell activation
    Start DL and UL Data Traffic SA And Expect Scell Activation   ${sa_ue_id1}   ${QFI_ID}
    Start DL and UL Data Traffic SA And Expect Scell Activation   ${sa_ue_id2}   ${QFI_ID2}
    #Step4:Verify DL & UL Tput on Pcell & Scell
    Verify DL and UL Tput SA    ${sa_ue_id1}   300   20   40   70
    Verify DL and UL Tput SA    ${sa_ue_id2}   300   35   40   120
    #Step5:Verify NBR counters pegging in Pcell and Scell
    Verify NBR counter update for pcell and scell
    [Teardown]    Run Keywords   Stop All Data Transfers And Detach UE SA    ${sa_ue_id1}   ${sa_ue_id2}
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Attach CA UE-${ue_id} with non-NBR bearer to TDD PCell
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${Pdu_session_ID} trf_type=internal
    Attach Ue    ue_id=${ue_id}
    sleep   2s
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${Pdu_session_ID}   gw_id=${gw_ID}
    sleep   2s

Attach CA UE-${ue_id} with NBR bearer to TDD PCell
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${Pdu_session_ID} trf_type=internal
    Attach Ue    ue_id=${ue_id}
    sleep   2s
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${Pdu_session_ID}   gw_id=${gw_ID}
    sleep   2s
    Modify Pdu Session   ue_id=${ue_id}    pdu_id=${Pdu_session_ID}   qos_to_add=${Q_O_ADD2}
    sleep   2s

UE Send A1 To Trigger 3CC CA setup
    [Arguments]    ${ue_id}=${sa_ue_id1}    ${scell1pci}=60    ${scell2pci}=61
    ${ret1}=    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=40
    ...    pass_regexp=activated successfully at airphone
    sleep   5s
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId${scell2pci}

Start DL and UL Data Traffic SA And Expect Scell Activation
    [Arguments]    ${ue_id}    ${qfid}
    FOR    ${trfid}    IN RANGE    1    5
          Execute Egate Command And Wait For Data
          ...    cmd=trf_data_start ue=${ue_id} pdu=${Pdu_session_ID} qfi=${qfid} dir=dl mbps=100 trf_id=${trfid}
          sleep   2s
          Execute Egate Command And Wait For Data
         ...    cmd=trf_data_start ue=${ue_id} pdu=${Pdu_session_ID} qfi=${qfid} dir=ul mbps=50 trf_id=${trfid}
    END
    Sleep    10s

Verify DL and UL Tput SA
    [Arguments]    ${ue_id}   ${pcell}   ${scell1}   ${scell2}   ${pcellul}
    ${pcell_tput_dl}=     Get Max Data Traffic For Given Cc    ue_id=${ue_id}    cc=0    direction=dl    unit=Mbps
    ${scell1_tput_dl}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}    cc=1    direction=dl    unit=Mbps
    ${scell2_tput_dl}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}    cc=2    direction=dl    unit=Mbps
    ${pcell_tput_ul}=     Get Max Data Traffic For Given Cc    ue_id=${ue_id}    cc=0    direction=ul    unit=Mbps
    Should Be True    ${pcell_tput_dl} > ${pcell}
    Should Be True    ${scell1_tput_dl} > ${scell1}
    Should Be True    ${scell2_tput_dl} > ${scell2}
    Should Be True    ${pcell_tput_ul} > ${pcellul}

Verify NBR counter update for pcell and scell
    ${pm_counter_file1}=   Get Next Unpacked Raw Pm Counters File    output_dirpath=${OUTPUT DIR}/nbr_counter_gnb1
    Verify Any Counters In File
    ...  M55139C03506  1  SA_DU_DRB_NBR_REQ
    ...  M55139C03507  1  SA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55139C03508  0  SA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_counter_file1}
    log to console   ${hostid2}
    ${pm_counter_file2}=   Get Latest Unpacked Raw Pm Counters File    output_dirpath=${OUTPUT DIR}/nbr_counter_gnb2   remote_host=${hostid2}
    Verify Any Counters In File
    ...  M55139C03506  1  SA_DU_DRB_NBR_REQ
    ...  M55139C03507  1  SA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55139C03508  0  SA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-11
    ...  file_path=${pm_counter_file2}
    Verify Any Counters In File
    ...  M55139C03506  1  SA_DU_DRB_NBR_REQ
    ...  M55139C03507  1  SA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55139C03508  0  SA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-12
    ...  file_path=${pm_counter_file2}

Stop All Data Transfers And Detach UE SA
    [Arguments]    ${first_ue_id}   ${last_ue_id}
    FOR    ${ID}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Execute Egate Command    cmd=trf_data_stop ue=${ID} pdu=1
         Sleep    1s
         Execute Egate Command    cmd=ue_deregister id=${ID} ue_deregister_type=switch_off
    END

Get gNB2 IP address
    ${hostid1}  ${hostid2}  Get Host Addr
    set suite variable   ${hostid1}
    set suite variable   ${hostid2}
