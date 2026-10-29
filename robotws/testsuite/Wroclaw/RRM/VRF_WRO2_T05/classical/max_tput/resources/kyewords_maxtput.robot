*** Settings ***
Documentation    Suite description
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot

*** Keywords ***
Set attenuator AEHC S1
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}   value=0   # CellID 104

Set attenuator AEHC S2
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}   value=0   # CellID 105

Set attenuator AEHC S3
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation_2 and check  lines=${lines_gNB_410_AEHC_6_TDD}   value=0   # CellID 106

Set attenuator AHLOA AEHC S1
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check  lines=${lines_gNB_410_AEHC_4_TDD}   value=0
    Set attenuation_2 and check  lines=${lines_gNB_410_AHLOA_3_FDD}  value=0   #AHLOA PCI:103 Att1

Set attenuator AHLOA AEHC S2
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check  lines=${lines_gNB_410_AEHC_5_TDD}   value=0
    Set attenuation_2 and check  lines=${lines_gNB_410_AHLOA_3_FDD}  value=0   #AHLOA PCI:103 Att1

Set attenuator AHLOA AEHC S3
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation_2 and check  lines=${lines_gNB_410_AEHC_6_TDD}   value=0
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_3_FDD}  value=0   #AHLOA PCI:103 Att1

Set attenuator AHLOA AEHC 5G S1
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check  lines=${lines_gNB_410_AEHC_4_TDD}   value=0
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_1_FDD}  value=0

Set attenuator AHLOA AEHC 5G S2
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check  lines=${lines_gNB_410_AEHC_5_TDD}   value=0
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_2_FDD}  value=0

Set attenuator AHLOA AEHC 5G S3
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation_2 and check  lines=${lines_gNB_410_AEHC_6_TDD}   value=0
    Set attenuation_2 and check  lines=${lines_gNB_410_AHLOA_3_FDD}  value=0

Check BTS Counter M51301C1
    Collect Counters   n_last=20
    @{counter_ids}      Create list  M51301C0  M51301C1
    ${counters_count}=  Get Length  ${counter_ids}
    ${pi_dict}=  get_pi_value
    ...  pi_list=@{counter_ids}
    ...  pi_dir=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/collector
    ...  pi_file_pattern=*PM*
    ${result}=  check counters values  ${pi_dict}
    should be true  ${result}

Check BTS Counter M51301C5
    Collect Counters   n_last=20
    @{counter_ids}      Create list  M51301C5
    ${counters_count}=  Get Length  ${counter_ids}
    ${pi_dict}=  get_pi_value
    ...  pi_list=@{counter_ids}
    ...  pi_dir=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/collector
    ...  pi_file_pattern=*PM*
    ${result}=  check_M51301C5  ${pi_dict}
    should be true  ${result}

