*** Settings ***
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library    testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CNI-89997.resources.RuFactoryRfsw

*** Keywords ***
Load Factory RFSW on RU
    [Arguments]  ${factory_rfsw_credentials}  ${svne1_path_rfsw}  ${swman_cmd_params}  ${gnb_id}  ${du_id}  ${ru_id}
    ...  ${cu_id}  ${common_unit_id}  ${capacity_unit_id}
    ${factory_file_name}=  Get From Dictionary	${swman_cmd_params}	 file_name
    ${factory_build_name}=  Get From Dictionary	 ${swman_cmd_params}  build_name
    Set Test Variable   ${factory_rfsw_credentials}   ${factory_rfsw_credentials}
    download factory rfws from svne1  path_rfsw=${svne1_path_rfsw}  gnb_id=${gnb_id}  du_id=${du_id}
    Log To Console  \nLoading factory RFSW on 1st RU partition
    Load Factory RFSW on RU Partition  swman_cmd_params=${swman_cmd_params}  factory_file_name=${factory_file_name}
    ...  run_on_factory_rfsw=${False}  run_as_superuser=${True}  gnb_id=${gnb_id}  du_id=${du_id}  ru_id=${ru_id}
    ...  cu_id=${cu_id}  common_unit_id=${common_unit_id}  capacity_unit_id=${capacity_unit_id}
    verify if factory rfsw is active  factory_build_name=${factory_build_name}  run_as_superuser=${False}
    ...  gnb_id=${gnb_id}  du_id=${du_id}  ru_id=${ru_id}  common_unit_id=${common_unit_id}
    ...  capacity_unit_id=${capacity_unit_id}
    Log To Console  \nLoading factory RFSW on 2nd RU partition
    Load Factory RFSW on RU Partition  swman_cmd_params=${swman_cmd_params}  factory_file_name=${factory_file_name}
    ...  run_on_factory_rfsw=${True}  run_as_superuser=${False}  gnb_id=${gnb_id}  du_id=${du_id}  ru_id=${ru_id}
    ...  cu_id=${cu_id}  common_unit_id=${common_unit_id}  capacity_unit_id=${capacity_unit_id}
    verify if factory rfsw is active on both partitions  factory_file_name=${factory_file_name}
    ...  run_as_superuser=${False}  gnb_id=${gnb_id}  du_id=${du_id}  ru_id=${ru_id}  common_unit_id=${common_unit_id}
    ...  capacity_unit_id=${capacity_unit_id}
    perform gnb software update  gnb_id=${gnb_id}  du_id=${du_id}
    gnbru.wait_for_all_radio_units_to_be_online    bts_id=${gnb_id}    du_id=${du_id}   timeout=${600}   interval=${180}
    verify active rfsw after gnb sw update  run_as_superuser=${True}  gnb_id=${gnb_id}  du_id=${du_id}  ru_id=${ru_id}
    gnbcell.wait_for_all_cells_to_be_onair    bts_id=${gnb_id}    du_id=${du_id}    timeout=${600}
    verify sw incompatible alarm not exist  gnb_id=${gnb_id}  du_id=${du_id}

Load Factory RFSW on RU Partition
    [Arguments]  ${swman_cmd_params}  ${factory_file_name}  ${run_on_factory_rfsw}  ${run_as_superuser}
    ...  ${gnb_id}  ${du_id}  ${ru_id}  ${cu_id}  ${common_unit_id}  ${capacity_unit_id}
    remove ssh known hosts  gnb_id=${gnb_id}  du_id=${du_id}  cu_id=${cu_id}
    upload factory rfsw package to ru  factory_file_name=${factory_file_name}  gnb_id=${gnb_id}  du_id=${du_id}
    ...  ru_id=${ru_id}  run_on_factory_rfsw=${run_on_factory_rfsw}  common_unit_id=${common_unit_id}
    ...  capacity_unit_id=${capacity_unit_id}
    swman inventory request  gnb_id=${gnb_id}  du_id=${du_id}  ru_id=${ru_id}  common_unit_id=${common_unit_id}
    ...  capacity_unit_id=${capacity_unit_id}  run_on_factory_rfsw=${run_on_factory_rfsw}
    ...  run_as_superuser=${run_as_superuser}
    swman save sw  cmd_params=${swman_cmd_params}  gnb_id=${gnb_id}  du_id=${du_id}  ru_id=${ru_id}
    ...  run_on_factory_rfsw=${run_on_factory_rfsw}  run_as_superuser=${run_as_superuser}
    swman activate sw  cmd_params=${swman_cmd_params}  gnb_id=${gnb_id}  du_id=${du_id}  ru_id=${ru_id}
    ...  run_on_factory_rfsw=${run_on_factory_rfsw}  run_as_superuser=${run_as_superuser}
    reboot gnb and verify uptime  gnb_id=${gnb_id}  du_id=${du_id}
    wait for sw incompatible alarm  gnb_id=${gnb_id}  du_id=${du_id}
