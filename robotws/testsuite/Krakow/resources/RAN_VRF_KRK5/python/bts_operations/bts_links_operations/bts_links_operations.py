from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.scf_parsers import get_all_params_under_class_name
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console


def verify_xn_link_status(ip_addr, status='available', bts_id=0, scf_dir='/tmp', ):
    gnb_du = GnbDuOperations()
    scf_path = gnb_du.get_bts_configuration_file(bts_id=bts_id, config_type='configurationAndRuntimeObjects',
                                                 local_dir=scf_dir)
    with open(scf_path, 'r') as scf_file:
        class_name = 'com.nokia.srbts.nrbts:XNLINK'
        scf_content = scf_file.read()
        found_objects = get_all_params_under_class_name(scf_file_content=scf_content, class_name=class_name)
        if found_objects:
            for found_object in found_objects:
                if ip_addr == found_object['params']['cPlaneIpAddr']:
                    if found_object['params']['xnLinkStatus'] == status:
                        log_info_to_console('Correct status of xnLink with ip address={}'.format(ip_addr),
                                            log_hierarchy=3)
                        return 0
                    else:
                        raise Exception('Incorrect status of xnLink with ip address={}'.format(ip_addr))
        raise Exception('No xnLink found with ip address={}'.format(ip_addr))
