# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       Qualcomm Common Suite Setup
# Test Setup        Qualcomm Common Test Setup
# Force Tags    qualcomm10317    owner_pennwang    SBTS22R2
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${4G_GNB_IP}    10.108.175.74
# ${SCFC_4G}    SCFC_7922_4G.xml
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# 
# *** Test Cases ***
# Prepare for nsa and pa
#     Qualcomm prepare gnb onair to another gnb    ${4G_GNB_IP}    ${SCFC_4G}
#     set attenuation by csv    FC:10.108.163.172:5000    ${CONFIG_DIR_PATH}/qualcomm_config/pa_fhfb_10db.csv
# 
# 
# 
# 
# 
