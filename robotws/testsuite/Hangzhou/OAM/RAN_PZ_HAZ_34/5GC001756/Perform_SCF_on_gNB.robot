# *** Settings ***
# Documentation
# ...  author: Jiang Shengyuan
# ...  contact: Jiang Shengyuan@nokia-sbell.com
# Library     String
# Library     DateTime
# Library     XML    True
# Library     Collections
# Library     OperatingSystem
# Library     taf.transport.ssh    WITH NAME   csn
# Library     taf.analyzer.pcap   WITH NAME   wireshark
# 
# Variables   ../libraries/global_vars.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
# 
# *** Variables ***
# *** Test Cases ***
# Perform_SCF_on_gNB
#     ${TL_total}   Get Length   ${tl.gnbs}
#     :FOR   ${gNB}   IN RANGE   0   ${TL_total}
#         log to console   ${gNB}
#         log to console   ${tl.gnbs[${gNB}].cu.oam_ssh_connection_details.addr}
#         CI_commssion.common commissioning   gnb_index=${gNB}
#         run keyword and continue on failure   Check Validation Error on gNB   gNB=${gNB}
#     END
# *** Keyword ***
# Check Validation Error on gNB
#     [Arguments]  ${gNB}
#     ${connection}   Set Variable If    ${gNB}==0   GNB_OAM   GNB_OAM_${gNB}
#     Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gNB}
#     ${Active_SW_version}   Get Active SW Version   connection=${connection}
#     Set Suite Variable   ${Active_SW_version}
#     ${Golden_SCF_Path}   Get Golden SCF Path    gnb_index=${gNB}
#     run keyword and ignore error   COAM Teardown gnb connections    connection=${connection}
#     COAM Login    alias=validate
#     ${error}   coam.Validate Scf Online   scf_file=${Golden_SCF_Path}
#     ...   validation_type=NIDD_AND_RELATIONS   skip_parameter_relation_errors=True    timeout=60   connection=validate
#     run keyword and ignore error   COAM Logout   connection=validate
#     should be equal   ${error['requestMessage']['niddValidationResult']['status']}   OK
#     should be equal   ${error['requestMessage']['pdlValidationResult']['status']}   OK