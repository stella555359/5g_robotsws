*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

Documentation   :copyright: Nokia
...             :authors: Magdalena Mlynarska
...             :contact: magdalena.mlynarska@nokia.com

Resource       ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Resource       feature_keywords.robot
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ute_fsmaccess
Library        ta5g_file_system
Library        ta5g_cell_operations
Library        ../../resources/scout_report.py
Library        ta5g_egate


Suite Setup        Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Set VM Ethernet Interfaces for Simulated Core Network
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC}
...    AND         Reach Onair Without Confirmation    lua_cfg=${basic_setup}
...    AND         Enable Tshark Verification

Suite Teardown    Compress Test Logs

Test Teardown      Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Find Errors
...    AND         Add Scout Scf Id To Test Data
...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND         Collect Selected Debug Files
...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...                omit_collectors=sos_report

*** Variables ***
${IPHY}=                              ${CURDIR}/config/iphy.xml
${basic_setup}=                       ${CURDIR}/config/basic_setup.cfg
${SCFC}=                              scfc_A_B4.xml
${Delta_A_B4}=                        Delta_A_B4.json
${Delta_A_B4_2}=                      Delta_A_B4_2.json
@{FAULT_IDS}=                         6450    4383    2087    7101
@{CELLS_LIST}=                        2    3    4    5    6    7    8    9    10    11    12
@{COUNTERS_NOT_TO_INCREMENT}=    M55306C00001    M55306C00002    M55306C00003    M55306C00004    M55306C00005    M55306C00006
...    M55306C00007    M55306C00008    M55306C00009    M55306C00010    M55306C00011    M55306C00012    M55306C00013    M55306C00014    M55306C00015
...    M55306C00016    M55306C00017    M55306C00018    M55306C00019    M55306C00020    M55306C00021    M55306C00022    M55306C00023    M55306C00024
...    M55306C00025    M55306C00026    M55306C00027    M55306C00028    M55306C00029    M55306C00030    M55306C00031    M55306C00032    M55306C00033
...    M55306C00034    M55306C00035    M55306C00036    M55306C00037    M55306C00038    M55306C00039    M55306C00040    M55306C00041    M55306C00042
...    M55306C00043    M55306C00044    M55306C00045    M55306C00046    M55306C00047    M55306C00048    M55306C00049    M55306C00050    M55306C00051
...    M55306C00052    M55306C00053    M55306C00054    M55306C00055    M55306C00056    M55306C00057    M55306C00058    M55306C00059    M55306C00060
...    M55306C00061    M55306C00062    M55306C00063

*** Test Cases ***
CB014330_TC14_A_B4_RACH_false_alarm_monitor_for_pfaTargetPRACH_online_modification_Classical_FR1_TDD_cell

    Verify Pm Counters Values Before Test Starts
    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Send Data Traffic In UL
    Verify Counters For All Cells On The gNB With Parameter pfaTargetPRACH Set To 0.1
                                #Changing value of the parameter pfaTargetPRACH to 0.0001
    Find Scfc and Send Delta Commissioning   scfc_filename=${Delta_A_B4}
    Wait For All Cells To Be Enabled
    Verify Counters For All Cells On The gNB With Parameter pfaTargetPRACH Set To 0.0001
                               #Changing value of the parameter pfaTargetPRACH to 0.1
    Find Scfc and Send Delta Commissioning   scfc_filename=${Delta_A_B4_2}
    Wait For All Cells To Be Enabled
    Verify Counters For All Cells On The gNB With Parameter pfaTargetPRACH Set To 0.1

*** Keywords ***
Verify Pm Counters Values Before Test Starts
    Wait For Next Full Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
       ...   M55306C00001      >5000     RA_ATT_CONT_A_PRMBL_SSB_00
       ...   M55306C00002      >5000     RA_ATT_CONT_A_PRMBL_SSB_01
       ...   M55306C00003      >5000     RA_ATT_CONT_A_PRMBL_SSB_02
       ...   M55306C00004      >5000     RA_ATT_CONT_A_PRMBL_SSB_03
       ...   M55306C00005      >5000     RA_ATT_CONT_A_PRMBL_SSB_04
       ...   M55306C00006      >5000     RA_ATT_CONT_A_PRMBL_SSB_05
       ...   M55306C00007      0      RA_ATT_CONT_A_PRMBL_SSB_06
       ...   M55306C00008      0      RA_ATT_CONT_A_PRMBL_SSB_07
       ...   M55306C00009      0      RA_ATT_CONT_A_PRMBL_SSB_08
       ...   M55306C00010      0      RA_ATT_CONT_A_PRMBL_SSB_09
       ...   M55306C00011      0      RA_ATT_CONT_A_PRMBL_SSB_10
       ...   M55306C00012      0      RA_ATT_CONT_A_PRMBL_SSB_11
       ...   M55306C00013      0      RA_ATT_CONT_A_PRMBL_SSB_12
       ...   M55306C00014      0      RA_ATT_CONT_A_PRMBL_SSB_13
       ...   M55306C00015      0      RA_ATT_CONT_A_PRMBL_SSB_14
       ...   M55306C00016      0      RA_ATT_CONT_A_PRMBL_SSB_15
       ...   M55306C00017      0      RA_ATT_CONT_A_PRMBL_SSB_16
       ...   M55306C00018      0      RA_ATT_CONT_A_PRMBL_SSB_17
       ...   M55306C00019      0      RA_ATT_CONT_A_PRMBL_SSB_18
       ...   M55306C00020      0      RA_ATT_CONT_A_PRMBL_SSB_19
       ...   M55306C00021      0      RA_ATT_CONT_A_PRMBL_SSB_20
       ...   M55306C00022      0      RA_ATT_CONT_A_PRMBL_SSB_21
       ...   M55306C00023      0      RA_ATT_CONT_A_PRMBL_SSB_22
       ...   M55306C00024      0      RA_ATT_CONT_A_PRMBL_SSB_23
       ...   M55306C00025      0      RA_ATT_CONT_A_PRMBL_SSB_24
       ...   M55306C00026      0      RA_ATT_CONT_A_PRMBL_SSB_25
       ...   M55306C00027      0      RA_ATT_CONT_A_PRMBL_SSB_26
       ...   M55306C00028      0      RA_ATT_CONT_A_PRMBL_SSB_27
       ...   M55306C00029      0      RA_ATT_CONT_A_PRMBL_SSB_28
       ...   M55306C00030      0      RA_ATT_CONT_A_PRMBL_SSB_29
       ...   M55306C00031      0      RA_ATT_CONT_A_PRMBL_SSB_30
       ...   M55306C00032      0      RA_ATT_CONT_A_PRMBL_SSB_31
       ...   M55306C00033      0      RA_ATT_CONT_A_PRMBL_SSB_32
       ...   M55306C00034      0      RA_ATT_CONT_A_PRMBL_SSB_33
       ...   M55306C00035      0      RA_ATT_CONT_A_PRMBL_SSB_34
       ...   M55306C00036      0      RA_ATT_CONT_A_PRMBL_SSB_35
       ...   M55306C00037      0      RA_ATT_CONT_A_PRMBL_SSB_36
       ...   M55306C00038      0      RA_ATT_CONT_A_PRMBL_SSB_37
       ...   M55306C00039      0      RA_ATT_CONT_A_PRMBL_SSB_38
       ...   M55306C00040      0      RA_ATT_CONT_A_PRMBL_SSB_39
       ...   M55306C00041      0      RA_ATT_CONT_A_PRMBL_SSB_40
       ...   M55306C00042      0      RA_ATT_CONT_A_PRMBL_SSB_41
       ...   M55306C00043      0      RA_ATT_CONT_A_PRMBL_SSB_42
       ...   M55306C00044      0      RA_ATT_CONT_A_PRMBL_SSB_43
       ...   M55306C00045      0      RA_ATT_CONT_A_PRMBL_SSB_44
       ...   M55306C00046      0      RA_ATT_CONT_A_PRMBL_SSB_45
       ...   M55306C00047      0      RA_ATT_CONT_A_PRMBL_SSB_46
       ...   M55306C00048      0      RA_ATT_CONT_A_PRMBL_SSB_47
       ...   M55306C00049      0      RA_ATT_CONT_A_PRMBL_SSB_48
       ...   M55306C00050      0      RA_ATT_CONT_A_PRMBL_SSB_49
       ...   M55306C00051      0      RA_ATT_CONT_A_PRMBL_SSB_50
       ...   M55306C00052      0      RA_ATT_CONT_A_PRMBL_SSB_51
       ...   M55306C00053      0      RA_ATT_CONT_A_PRMBL_SSB_52
       ...   M55306C00054      0      RA_ATT_CONT_A_PRMBL_SSB_53
       ...   M55306C00055      0      RA_ATT_CONT_A_PRMBL_SSB_54
       ...   M55306C00056      0      RA_ATT_CONT_A_PRMBL_SSB_55
       ...   M55306C00057      0      RA_ATT_CONT_A_PRMBL_SSB_56
       ...   M55306C00058      0      RA_ATT_CONT_A_PRMBL_SSB_57
       ...   M55306C00059      0      RA_ATT_CONT_A_PRMBL_SSB_58
       ...   M55306C00060      0      RA_ATT_CONT_A_PRMBL_SSB_59
       ...   M55306C00061      0      RA_ATT_CONT_A_PRMBL_SSB_60
       ...   M55306C00062      0      RA_ATT_CONT_A_PRMBL_SSB_61
       ...   M55306C00063      0      RA_ATT_CONT_A_PRMBL_SSB_62
       ...   M55306C00064      0      RA_ATT_CONT_A_PRMBL_SSB_63

       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
       ...    filepath=${pm_counter_file}

    FOR    ${cell_index}    IN    @{CELLS_LIST}
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
           ...    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT}
           ...    value=0
           ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_index}
           ...    filepath=${pm_counter_file}
    END


Verify Counters For All Cells On The gNB With Parameter pfaTargetPRACH Set To 0.0001
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
       ...   M55306C00001      <100      RA_ATT_CONT_A_PRMBL_SSB_00
       ...   M55306C00002      <100      RA_ATT_CONT_A_PRMBL_SSB_01
       ...   M55306C00003      <100      RA_ATT_CONT_A_PRMBL_SSB_02
       ...   M55306C00004      <100      RA_ATT_CONT_A_PRMBL_SSB_03
       ...   M55306C00005      <100      RA_ATT_CONT_A_PRMBL_SSB_04
       ...   M55306C00006      <100      RA_ATT_CONT_A_PRMBL_SSB_05
       ...   M55306C00007      0      RA_ATT_CONT_A_PRMBL_SSB_06
       ...   M55306C00008      0      RA_ATT_CONT_A_PRMBL_SSB_07
       ...   M55306C00009      0      RA_ATT_CONT_A_PRMBL_SSB_08
       ...   M55306C00010      0      RA_ATT_CONT_A_PRMBL_SSB_09
       ...   M55306C00011      0      RA_ATT_CONT_A_PRMBL_SSB_10
       ...   M55306C00012      0      RA_ATT_CONT_A_PRMBL_SSB_11
       ...   M55306C00013      0      RA_ATT_CONT_A_PRMBL_SSB_12
       ...   M55306C00014      0      RA_ATT_CONT_A_PRMBL_SSB_13
       ...   M55306C00015      0      RA_ATT_CONT_A_PRMBL_SSB_14
       ...   M55306C00016      0      RA_ATT_CONT_A_PRMBL_SSB_15
       ...   M55306C00017      0      RA_ATT_CONT_A_PRMBL_SSB_16
       ...   M55306C00018      0      RA_ATT_CONT_A_PRMBL_SSB_17
       ...   M55306C00019      0      RA_ATT_CONT_A_PRMBL_SSB_18
       ...   M55306C00020      0      RA_ATT_CONT_A_PRMBL_SSB_19
       ...   M55306C00021      0      RA_ATT_CONT_A_PRMBL_SSB_20
       ...   M55306C00022      0      RA_ATT_CONT_A_PRMBL_SSB_21
       ...   M55306C00023      0      RA_ATT_CONT_A_PRMBL_SSB_22
       ...   M55306C00024      0      RA_ATT_CONT_A_PRMBL_SSB_23
       ...   M55306C00025      0      RA_ATT_CONT_A_PRMBL_SSB_24
       ...   M55306C00026      0      RA_ATT_CONT_A_PRMBL_SSB_25
       ...   M55306C00027      0      RA_ATT_CONT_A_PRMBL_SSB_26
       ...   M55306C00028      0      RA_ATT_CONT_A_PRMBL_SSB_27
       ...   M55306C00029      0      RA_ATT_CONT_A_PRMBL_SSB_28
       ...   M55306C00030      0      RA_ATT_CONT_A_PRMBL_SSB_29
       ...   M55306C00031      0      RA_ATT_CONT_A_PRMBL_SSB_30
       ...   M55306C00032      0      RA_ATT_CONT_A_PRMBL_SSB_31
       ...   M55306C00033      0      RA_ATT_CONT_A_PRMBL_SSB_32
       ...   M55306C00034      0      RA_ATT_CONT_A_PRMBL_SSB_33
       ...   M55306C00035      0      RA_ATT_CONT_A_PRMBL_SSB_34
       ...   M55306C00036      0      RA_ATT_CONT_A_PRMBL_SSB_35
       ...   M55306C00037      0      RA_ATT_CONT_A_PRMBL_SSB_36
       ...   M55306C00038      0      RA_ATT_CONT_A_PRMBL_SSB_37
       ...   M55306C00039      0      RA_ATT_CONT_A_PRMBL_SSB_38
       ...   M55306C00040      0      RA_ATT_CONT_A_PRMBL_SSB_39
       ...   M55306C00041      0      RA_ATT_CONT_A_PRMBL_SSB_40
       ...   M55306C00042      0      RA_ATT_CONT_A_PRMBL_SSB_41
       ...   M55306C00043      0      RA_ATT_CONT_A_PRMBL_SSB_42
       ...   M55306C00044      0      RA_ATT_CONT_A_PRMBL_SSB_43
       ...   M55306C00045      0      RA_ATT_CONT_A_PRMBL_SSB_44
       ...   M55306C00046      0      RA_ATT_CONT_A_PRMBL_SSB_45
       ...   M55306C00047      0      RA_ATT_CONT_A_PRMBL_SSB_46
       ...   M55306C00048      0      RA_ATT_CONT_A_PRMBL_SSB_47
       ...   M55306C00049      0      RA_ATT_CONT_A_PRMBL_SSB_48
       ...   M55306C00050      0      RA_ATT_CONT_A_PRMBL_SSB_49
       ...   M55306C00051      0      RA_ATT_CONT_A_PRMBL_SSB_50
       ...   M55306C00052      0      RA_ATT_CONT_A_PRMBL_SSB_51
       ...   M55306C00053      0      RA_ATT_CONT_A_PRMBL_SSB_52
       ...   M55306C00054      0      RA_ATT_CONT_A_PRMBL_SSB_53
       ...   M55306C00055      0      RA_ATT_CONT_A_PRMBL_SSB_54
       ...   M55306C00056      0      RA_ATT_CONT_A_PRMBL_SSB_55
       ...   M55306C00057      0      RA_ATT_CONT_A_PRMBL_SSB_56
       ...   M55306C00058      0      RA_ATT_CONT_A_PRMBL_SSB_57
       ...   M55306C00059      0      RA_ATT_CONT_A_PRMBL_SSB_58
       ...   M55306C00060      0      RA_ATT_CONT_A_PRMBL_SSB_59
       ...   M55306C00061      0      RA_ATT_CONT_A_PRMBL_SSB_60
       ...   M55306C00062      0      RA_ATT_CONT_A_PRMBL_SSB_61
       ...   M55306C00063      0      RA_ATT_CONT_A_PRMBL_SSB_62
       ...   M55306C00064      0      RA_ATT_CONT_A_PRMBL_SSB_63

       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
       ...    filepath=${pm_counter_file}

    FOR    ${cell_index}    IN    @{CELLS_LIST}
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
           ...    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT}
           ...    value=0
           ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_index}
           ...    filepath=${pm_counter_file}
    END

Verify Counters For All Cells On The gNB With Parameter pfaTargetPRACH Set To 0.1
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
       ...   M55306C00001      >5000     RA_ATT_CONT_A_PRMBL_SSB_00
       ...   M55306C00002      >5000     RA_ATT_CONT_A_PRMBL_SSB_01
       ...   M55306C00003      >5000     RA_ATT_CONT_A_PRMBL_SSB_02
       ...   M55306C00004      >5000     RA_ATT_CONT_A_PRMBL_SSB_03
       ...   M55306C00005      >5000     RA_ATT_CONT_A_PRMBL_SSB_04
       ...   M55306C00006      >5000     RA_ATT_CONT_A_PRMBL_SSB_05
       ...   M55306C00007      0      RA_ATT_CONT_A_PRMBL_SSB_06
       ...   M55306C00008      0      RA_ATT_CONT_A_PRMBL_SSB_07
       ...   M55306C00009      0      RA_ATT_CONT_A_PRMBL_SSB_08
       ...   M55306C00010      0      RA_ATT_CONT_A_PRMBL_SSB_09
       ...   M55306C00011      0      RA_ATT_CONT_A_PRMBL_SSB_10
       ...   M55306C00012      0      RA_ATT_CONT_A_PRMBL_SSB_11
       ...   M55306C00013      0      RA_ATT_CONT_A_PRMBL_SSB_12
       ...   M55306C00014      0      RA_ATT_CONT_A_PRMBL_SSB_13
       ...   M55306C00015      0      RA_ATT_CONT_A_PRMBL_SSB_14
       ...   M55306C00016      0      RA_ATT_CONT_A_PRMBL_SSB_15
       ...   M55306C00017      0      RA_ATT_CONT_A_PRMBL_SSB_16
       ...   M55306C00018      0      RA_ATT_CONT_A_PRMBL_SSB_17
       ...   M55306C00019      0      RA_ATT_CONT_A_PRMBL_SSB_18
       ...   M55306C00020      0      RA_ATT_CONT_A_PRMBL_SSB_19
       ...   M55306C00021      0      RA_ATT_CONT_A_PRMBL_SSB_20
       ...   M55306C00022      0      RA_ATT_CONT_A_PRMBL_SSB_21
       ...   M55306C00023      0      RA_ATT_CONT_A_PRMBL_SSB_22
       ...   M55306C00024      0      RA_ATT_CONT_A_PRMBL_SSB_23
       ...   M55306C00025      0      RA_ATT_CONT_A_PRMBL_SSB_24
       ...   M55306C00026      0      RA_ATT_CONT_A_PRMBL_SSB_25
       ...   M55306C00027      0      RA_ATT_CONT_A_PRMBL_SSB_26
       ...   M55306C00028      0      RA_ATT_CONT_A_PRMBL_SSB_27
       ...   M55306C00029      0      RA_ATT_CONT_A_PRMBL_SSB_28
       ...   M55306C00030      0      RA_ATT_CONT_A_PRMBL_SSB_29
       ...   M55306C00031      0      RA_ATT_CONT_A_PRMBL_SSB_30
       ...   M55306C00032      0      RA_ATT_CONT_A_PRMBL_SSB_31
       ...   M55306C00033      0      RA_ATT_CONT_A_PRMBL_SSB_32
       ...   M55306C00034      0      RA_ATT_CONT_A_PRMBL_SSB_33
       ...   M55306C00035      0      RA_ATT_CONT_A_PRMBL_SSB_34
       ...   M55306C00036      0      RA_ATT_CONT_A_PRMBL_SSB_35
       ...   M55306C00037      0      RA_ATT_CONT_A_PRMBL_SSB_36
       ...   M55306C00038      0      RA_ATT_CONT_A_PRMBL_SSB_37
       ...   M55306C00039      0      RA_ATT_CONT_A_PRMBL_SSB_38
       ...   M55306C00040      0      RA_ATT_CONT_A_PRMBL_SSB_39
       ...   M55306C00041      0      RA_ATT_CONT_A_PRMBL_SSB_40
       ...   M55306C00042      0      RA_ATT_CONT_A_PRMBL_SSB_41
       ...   M55306C00043      0      RA_ATT_CONT_A_PRMBL_SSB_42
       ...   M55306C00044      0      RA_ATT_CONT_A_PRMBL_SSB_43
       ...   M55306C00045      0      RA_ATT_CONT_A_PRMBL_SSB_44
       ...   M55306C00046      0      RA_ATT_CONT_A_PRMBL_SSB_45
       ...   M55306C00047      0      RA_ATT_CONT_A_PRMBL_SSB_46
       ...   M55306C00048      0      RA_ATT_CONT_A_PRMBL_SSB_47
       ...   M55306C00049      0      RA_ATT_CONT_A_PRMBL_SSB_48
       ...   M55306C00050      0      RA_ATT_CONT_A_PRMBL_SSB_49
       ...   M55306C00051      0      RA_ATT_CONT_A_PRMBL_SSB_50
       ...   M55306C00052      0      RA_ATT_CONT_A_PRMBL_SSB_51
       ...   M55306C00053      0      RA_ATT_CONT_A_PRMBL_SSB_52
       ...   M55306C00054      0      RA_ATT_CONT_A_PRMBL_SSB_53
       ...   M55306C00055      0      RA_ATT_CONT_A_PRMBL_SSB_54
       ...   M55306C00056      0      RA_ATT_CONT_A_PRMBL_SSB_55
       ...   M55306C00057      0      RA_ATT_CONT_A_PRMBL_SSB_56
       ...   M55306C00058      0      RA_ATT_CONT_A_PRMBL_SSB_57
       ...   M55306C00059      0      RA_ATT_CONT_A_PRMBL_SSB_58
       ...   M55306C00060      0      RA_ATT_CONT_A_PRMBL_SSB_59
       ...   M55306C00061      0      RA_ATT_CONT_A_PRMBL_SSB_60
       ...   M55306C00062      0      RA_ATT_CONT_A_PRMBL_SSB_61
       ...   M55306C00063      0      RA_ATT_CONT_A_PRMBL_SSB_62
       ...   M55306C00064      0      RA_ATT_CONT_A_PRMBL_SSB_63

       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
       ...    filepath=${pm_counter_file}

    FOR    ${cell_index}    IN    @{CELLS_LIST}
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
           ...    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT}
           ...    value=0
           ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_index}
           ...    filepath=${pm_counter_file}
    END


