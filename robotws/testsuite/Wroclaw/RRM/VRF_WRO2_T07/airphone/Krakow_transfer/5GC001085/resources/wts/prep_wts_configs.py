from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from taf.config.wts import wts as wts_config
import os


def prepare_wts_config_file(wts_config_filename):
    epcsim_dir_path = BuiltIn().get_variable_value("${EPCSIM_DIR_PATH}")
    wts_cfgs_dir = BuiltIn().get_variable_value("${RESOURCES_WTS_CFGS_DIR}")
    unit_name = BuiltIn().get_variable_value("${UNIT_NAME}")
    wts_config_full_path = os.path.join(wts_cfgs_dir, wts_config_filename)

    wts_conf_instance = wts_config()
    wts_conf_instance.load_wts_cfg(wts_config_full_path)

    if unit_name == "ASIM":
        wts_conf_instance.delete(command="set_cell id=3 gnb=2")
        wts_conf_instance.delete(command="set_cell id=4 gnb=2")
    elif unit_name == "ASOE":
        wts_conf_instance.modify(command="set_cell id=3 gnb=2",
                                 modification="nr_arfcn=636666:636666 gscn=7880")

        wts_conf_instance.modify(command="set_cell id=4 gnb=2",
                                 modification="nr_arfcn=636666:636666 gscn=7880")

        wts_conf_instance.clone_and_modify(command="set_cell id=1 gnb=2",
                                           modification="id=5 nr_arfcn=135760:126380 gscn=1582 "
                                                        "pci=18:0 tac=200 nrci=0x05 tdd_cell=off")
        wts_conf_instance.clone_and_modify(command="set_cell id=1 gnb=2",
                                           modification="id=6 nr_arfcn=135760:126380 gscn=1582 "
                                                        "pci=18:1 tac=200 nrci=0x06 tdd_cell=off")
        wts_conf_instance.clone_and_modify(command="set_cell id=1 gnb=2",
                                           modification="id=7 nr_arfcn=135760:126380 gscn=1582 "
                                                        "pci=18:2 tac=200 nrci=0x07 tdd_cell=off")
        wts_conf_instance.clone_and_modify(command="set_cell id=1 gnb=2",
                                           modification="id=8 nr_arfcn=135760:126380 gscn=1582 "
                                                        "pci=19:0 tac=200 nrci=0x08 tdd_cell=off")
        if wts_conf_instance.get(command="set_ue simulated id=20"):
            wts_conf_instance.modify(command="set_ue simulated id=20", modification="cell=5")

    new_config_path = os.path.join(epcsim_dir_path, wts_config_filename)
    wts_conf_instance.save_wts_cfg(new_config_path)
    return new_config_path
