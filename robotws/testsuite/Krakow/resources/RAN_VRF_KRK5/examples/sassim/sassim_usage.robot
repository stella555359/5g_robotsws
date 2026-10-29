*** Settings ***
Documentation
...   Example of using SASsim module

Library    taf.rfrl.utilities.logger.custom_logger                                 WITH NAME  logger
Library    taf.rfrl.utilities.test_config                                          WITH NAME  test_config
Library    testsuite.Krakow.resources.RAN_VRF_KRK5.python.sassim.sassim.SASSim     WITH NAME  sassim

*** Test Cases ***
SASSim_Example
    ${repo_path}=    test_config.get_repository_path
    sassim.set_sas_sim_config
    ...    sas_sim_config=${repo_path}/testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010969_B2/local_resources/configs/SAS_Sim_test.conf
    sassim.prepare_and_start_sas_sim
    logger.log_info_to_console     SASsim is running
    sassim.stop_sas_sim
    logger.log_info_to_console     SASsim is stopped
