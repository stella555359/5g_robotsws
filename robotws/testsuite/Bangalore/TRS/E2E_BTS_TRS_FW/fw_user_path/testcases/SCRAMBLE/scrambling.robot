*** Settings ***
Documentation
...		[Author]     		        "Megha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

***Test Cases ***
[1][1.0] CNI-93267-B-B5_Scramble coredump, regdump and other dump files in SRAN PDD_ABL
    Perform Commissioning     scf_file=${base_scfc}    verify_bts_status=False     timeout=1200     alias=default
    Sleep   30
  ${store_snapshot}         Collect Snapshot        timeout=900     alias=default
    Collect Im Snapshot     timeout=120     alias=default

#Upload Snapshot
    ${attach_id}    Upload To Caps    file=${store_snapshot}   config_file=caps_qa_config
    Set Suite Variable    ${attach_id}
    Is Scramble Ready    attach_id=${attach_id}    config_file=caps_qa_config
    List Attachments    attach_id=${attach_id}    config_file=caps_qa_config

#Downlaod Snapshot
    ${downloaded_path}      ${filename}     ${passwd}    Download scrambled file from caps    attach_id=${attach_id}    config_file=caps_qa_config
    log     ${downloaded_path}
    Is Scramble Ready    attach_id=${attach_id}    config_file=caps_qa_config
    List Attachments    attach_id=${attach_id}    config_file=caps_qa_config

        Verify Scrambling       actual_zip=${store_snapshot}        scrambled_zip=${filename}     folder_path=${downloaded_path}      pwd=${passwd}