*** Settings ***
Documentation    Common variables for 1113 feature

*** Variables ***
${SCF_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_step3.xml
@{GNB_PS_CELL_INDEX_LIST}        1    2
${UL_EXPECT}        20
${DL_EXPECT}        527
${UL_EXPECT_BEAMSET_6}        22
${DL_EXPECT_BEAMSET_6}        487
${UL_EXPECT_BEAMSET_2}        20
${DL_EXPECT_BEAMSET_2}        527
${EXP_TPUT_PERCENTAGE}    0.95

