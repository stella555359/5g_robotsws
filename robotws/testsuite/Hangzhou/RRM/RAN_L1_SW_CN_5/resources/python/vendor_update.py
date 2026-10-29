from taf.selenium.sbts import sbts
import os
import subprocess
from robot.api import logger

current_directory = os.getcwd()
scf_file = os.path.join(current_directory, 'scf_1.xml')
scf_file_recovery = os.path.join(current_directory, 'scf_recovery.xml')
url = 'https://10.108.241.139'
# param_dict = {'actEcpri72e': 'Ecpri72eUL'}
param_dict = {'actEcpri72e': 'disabled'}


def vendor_update(download_dir, param_dict, scf_file, btsid='10386', url='https://192.168.255.129'):
    logger.console(f"Start to execute vendor update with {scf_file}")
    coam_handler = sbts()
    try:
        coam_handler.enable_virtual_display()
        coam_handler.login(url=url,
                           username='Nemuadmin',
                           password='nemuuser',
                           download_dir=download_dir,
                           alias='cb007595')
        logger.console(f"current path is: {os.getcwd()}")
        old_vendor_file = os.path.join(os.getcwd(), 'vendor_lte.xml')
        if os.path.exists(old_vendor_file):
            os.remove(old_vendor_file)
        vendor_file = coam_handler.download_default_file(sbts='cb007595')
        logger.console('download vendor file: ' + vendor_file)
        change_param_in_vendor(param_dict, vendor_file)
        logger.console('change vendor file')
        valid_status = coam_handler.load_vendor_file_and_validate(file_path=vendor_file, sbts='cb007595')
        logger.console('load modify vendor' + vendor_file + '\n' + 'valide status ' + valid_status)
        commission_status = coam_handler.load_commissioning_file_and_check_load_status(file_path=scf_file,
                                                                                       sbts='cb007595')
        if commission_status:
            logger.console('commssion status is ok')
        else:
            logger.console('commssion status is fail')
        logger.debug(f'vendor_update: actEcpri72e set to {param_dict.get("actEcpri72e")}')
        coam_handler.validate_plan(sbts='cb007595')
        logger.console("validate done")
        coam_handler.activate_plan(activate_plan_despite_errors=True, timeout=300, sbts='cb007595')
        logger.console("active done")
        if vendor_file is not None and os.path.exists(vendor_file):
            os.remove(vendor_file)
    except Exception as exp:
        logger.error(f'No start up view and {exp}')
        raise Exception
    finally:
        coam_handler.disable_virtual_display()


def change_param_in_vendor(param_dict, vendor_file):
    for param_name, value in param_dict.items():
        command = f"sudo sed -i 's/<p name=\"{param_name}\">.*</<p name=\"{param_name}\">{value}</g' " \
                  f"{vendor_file}"
        logger.console(f"execute command: {command}")
        subprocess.run(command, shell=True, capture_output=True, text=True)
        query_cmd = f"cat {vendor_file}|grep {param_name}"
        result = subprocess.run(query_cmd, shell=True, capture_output=True, text=True)
        logger.console(f'{query_cmd} output:' + result.stdout)
