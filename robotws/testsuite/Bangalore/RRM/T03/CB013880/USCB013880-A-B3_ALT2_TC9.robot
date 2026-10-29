*** Settings ***
Force Tags    CONFIGURED       PY310    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Documentation   :copyright: Nokia
...             :authors: Priya Bakshi
...             :contact: Priya.Bakshi@nokia.com

...             INTRODUCTION: The User scenario covers new fault update with slice addition in TAC after activation of the NR-DC-SN
...             cell handling a slice which is not supported by any connected MN gNB.

...             TEST SET NAME:    CB013880
...             TESTING SPLIT:    Refer CB013880 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013880_CFAM
...             Requirement ID:   12795118

Resource       ../../../../Bangalore/resources/robot/WTS_Runner_Keywords.robot
Resource       ../../../../Bangalore/resources/robot/common_log_collection.robot
Resource       ../../../../Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/robot/Setup.robot
Resource       resources/CB013880_keyword.robot



Variables      ta5g_global_var
Library        taf.sbts.oam.coam.admin     WITH NAME    CoamAdmin
Library        taf.sw.wtssim
Library        taf.transport.ssh           WITH NAME    taf_ssh
Library        taf.ul.ue.sim.env_setup
Library        taf.wts.runner              WITH NAME    wtsrunner
Library        OperatingSystem
Library        Collections
Library        resources/multignb_variables.py
Library        String

*** Variables ***
${SCFC_GNB_MN}=             scfc_13880_D_MN_real.xml
${SCFC_GNB_SN}=             Configuration_SN.xml
${IPHY}=                    ${CURDIR}/config/CB013880_iphy.xml
${wts_cfg_file_TC1}=        ${CURDIR}/config/CB013880_nrdc.cfg
${MN_CELL_1}=               1
${MN_CELL_2}=               2
${MN_CELL_3}=               3
${MN_CELL_4}=               4
${NRDC_SN_CELL}=            5
@{MN_CELLS}=                1    2    3    4
@{SN_CELLS}=                5    6    7    8
@{SN_CELLS_after_test}=     6    7    8
@{FAULT_IDS_LIST}=          6450    4383
&{WTS}                      Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}                  /opt/iphy/latest
${BTS_ADDRESS}              10.0.1.3
${BTS_PORT}                  443
${USE_SSL}                   True
${Log_Path}                  ${OUTPUT_DIR}
${delta_add_slice3}=          ${CURDIR}/config/SBTS26R3/Delta_Configuration_addslice3.json
${delta_delete_slice3}=       ${CURDIR}/config/SBTS26R3/Delta_Configuration_deleteslice3.json

*** Test Cases ***
USCB013880-A#B3_ALT2_TC9_Fault_update_with_additional_new_slice_by_adding_in TAC_in_NRDC

    [Setup]    Run keywords
    ...                Log to console    "Setting up Testline"
    ...    AND        Run Keyword and Ignore Error      Suite setup from scratch
    ...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${SCFC_GNB_SN}
    ...                remote_host=${REMOTE_HOST_1_IP}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${SCFC_GNB_MN}
    ...    AND          sleep     180s
    ...    AND         Run cfg file      ${wts_cfg_file_TC1}


    Check SIB messagges for all cells
    Start Log    cprt
    Register UE and start data traffic
    Initiate sgnb addition
    ${path1}    Stop Log    cprt   test_scenario=NRDC
    Check If Alarm Appeared for NRCELL5_tc9   8301    MRBTS-3/NRBTS-3/NRCELL-5
    Check If Alarm Appeared for NRCELL6_tc9   8301    MRBTS-3/NRBTS-3/NRCELL-6
    perform delta and add 3rd slice
    Check If Alarm Appeared for NRCELL5_tc9    8301    MRBTS-3/NRBTS-3/NRCELL-5
    Check If Alarm Appeared for NRCELL6_tc9    8301    MRBTS-3/NRBTS-3/NRCELL-6


    [Teardown]      Run keywords
	...       Log to console    " Reverting Testline"
	...       AND    detach_ue_with_power_off    ue_id=1
	...       AND    perform delta and delete 3rd slice
	...       AND    Run Keyword and Ignore Error    CB013880_keyword.Kill WTS processes Using WTS_Runner
