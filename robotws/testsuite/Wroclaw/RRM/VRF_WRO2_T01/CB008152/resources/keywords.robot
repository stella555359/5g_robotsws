*** Settings ***
Documentation  Test Specific keywords

Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py
Library  taf.sbts.oam.coam.admin

*** Variables ***
${test_cell}  10
${nr_bts_id}        ${tl.gnbs[0].instance_id}

*** Keywords ***
Prepare TL for CB008152
    log to console  Preparing TL for CB008152 by uploading SCF file

    ${sw_ver}  get_sw_version_from_webem

    ${scf_path}  set variable  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008152/resources/scfs/${sw_ver[:8]}.xml

    activate_scf_commissioning  ${scf_path}

    Verify test cell status

    perform_rat_block  lte
    log to console  TL preparation done


Set 64QAM DL/UL
    log to console  Setting 64QAM for uplink and downling
    create delta

    append parameter update to delta
    ...  MRBTS-${nr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${test_cell}
    ...  actDl256Qam
    ...  false

    append parameter update to delta
    ...  MRBTS-${nr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${test_cell}
    ...  actDlLaDynBlerTarget
    ...  false

    append parameter update to delta
    ...  MRBTS-${nr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${test_cell}
    ...  actUl256Qam
    ...  false

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

    Verify test cell status


Verify test cell status
    Wait Until Keyword Succeeds
    ...  10m
    ...  5s
    ...  verify cell status  MRBTS-${nr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${test_cell}