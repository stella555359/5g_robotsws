from GenericHub.GenericHub import GenericHub
from functools import wraps
from taf.ul.sc.tl_config import TestLineConfiguration
from moler.util.moler_test import MolerTest
import re
import datetime
import os

tl_config = TestLineConfiguration()
ant_port_list = ['0xa110001c', '0xa110101c', '0xa110201c', '0xa110301c', '0xa110401c', '0xa110501c',
                 '0xa110601c', '0xa110701c', '0xa110801c', '0xa110901c', '0xa110a01c', '0xa110b01c']
hub10_optical_interfaces = {
    'opt_if_0': '0xa010c024',    # CPRI Port
    'opt_if_1': '0xa010d024',    # CPRI Port
    'opt_if_2': '0xa010e024',    # CPRI Port
    'opt_if_3': '0xa010f024'     # CPRI Port
}
hub20_optical_interfaces = {
    'opt_if_0': '0xa1110024',    # CPRI Port
    'opt_if_1': '0xa1111024',    # CPRI Port
    'opt_if_2': '0xa1112024',    # CPRI Port
    'opt_if_3': '0xa1113024',    # CPRI Port
    'opt_if_4': '0xa1411094',    # eCPRI Port
    'opt_if_5': '0xa1411194'     # eCPRI Port
}

# Below info come from gemini.qin@nokia-sbell.com, if have issue, need check with her
hub10_optical_interfaces_rfs_spec = {
    'opt_if_0': {
        '0xa010c010': '0x0',
        '0xa010c000': '0x3',
        '0xa0003004': '0x2'
    }
}

hub20_optical_interfaces_rfs_spec = {
    'opt_if_0': {
        '0xa1110010': '0x0',
        '0xa1110000': '0x3',
        '0xa1003004': '0x2'
    }
}

hub_instance = None


def connect_to_hub(hub_fun):
    @wraps(hub_fun)
    def wrapper(*args, **kwargs):
        if args:
            device_name = args[0]
        elif 'device_name' in kwargs:
            device_name = kwargs['device_name']
        elif hub_fun.__defaults__:
            device_name = hub_fun.__defaults__[0]
            kwargs['device_name'] = device_name

        global hub_instance
        hub_instance = GenericHub(device_name=device_name, autoconnect=True)

        result = hub_fun(*args, **kwargs)
        return result

    return wrapper


@connect_to_hub
def get_cpri_link_address(device_name, port_number):
    """
    This keywork is to get cpri link address according to port number and hub version
    Private function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param port_number: Port Number Of Cpri Link range [0-5]: CPRI->0~3, eCPRI->4~5
        For Example: Primary Cpri Link Is 0, Second Cpri Link Is 1
    :return hub_address: address of cpri link

    """

    result_hub_version = hub_instance.get_hostname_for_hub()

    if result_hub_version == 'fzhub20':
        hub_address = hub20_optical_interfaces['opt_if_'+port_number]
    else:
        hub_address = hub10_optical_interfaces['opt_if_'+port_number]

    return hub_address


@connect_to_hub
def plug_in_hub_cpri_link(device_name='GNB0_HUB0', port_number=None):
    """
    This keywork is to simulate plug in or out cpri link by change register value
    Public function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param port_number: Port Number Of Cpri Link range [0-3], or [0-5] if hub 2.0
    """

    if port_number is None:
        MolerTest.error("Please afford necessary arguments port_number={}".
                        format(port_number), raise_exception=True)

    hub_instance.change_tx_dis_content(
        text="0", output_file="/sys/class/sfp/sfp{}/tx_dis".format(port_number))


@connect_to_hub
def plug_out_hub_cpri_link(device_name='GNB0_HUB0', port_number=None, rfs_spec=False):
    """
    This keywork is to simulate plug in or out cpri link by change register value
    Public function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param port_number: Port Number Of Cpri Link range [0-3], or [0-5] if hub 2.0
    :param rfs_spec: Default is False, this flag only used for RFS HUB port 0
    """
    if port_number is None:
        MolerTest.error("Please afford necessary arguments port_number={}".
                        format(port_number), raise_exception=True)

    if not rfs_spec:
        hub_instance.change_tx_dis_content(
            text="1", output_file="/sys/class/sfp/sfp{}/tx_dis".format(port_number))
    else:
        if str(port_number) != '0':
            MolerTest.error("Currently RFS special port_number only support port 0, other port please use "
                            "rfs_spec=False", raise_exception=True)

        result_hub_version = hub_instance.get_hostname_for_hub()
        if result_hub_version == 'fzhub20':
            hub_register_info_dict = hub20_optical_interfaces_rfs_spec['opt_if_{}'.format(port_number)]
        else:
            hub_register_info_dict = hub10_optical_interfaces_rfs_spec['opt_if_{}'.format(port_number)]

        for k, v in hub_register_info_dict.items():
            hub_instance.change_cpri_link_value(address=k, size='32', value=v)


@connect_to_hub
def get_cpri_link_status(device_name='GNB0_HUB0', port_number=None):
    """
    This keywork is to get cpri link address according to port number and hub version
    Public function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param port_number: Port Number Of Cpri Link range [0-5],CPRI->0~3, eCPRI->4~5
        For Example: Primary Cpri Link Is 0, Second Cpri Link Is 1
    :return value: value get from cpri link address

    """
    if port_number is None:
        MolerTest.error("Please afford necessary arguments port_number={}".
                        format(port_number), raise_exception=True)

    hub_address = get_cpri_link_address(
        device_name=device_name, port_number=port_number)
    value = hub_instance.get_cpri_link_value(address=hub_address)
    if port_number == '4' or port_number == '5':
        return 'Synced' if re.search(r'0x[\dABCDEF]*C$', value) else 'Not synced'
    else:
        return 'Synced' if re.search(r'0x[\dABCDEF]*F$', value) else 'Not synced'


@connect_to_hub
def get_primary_cpri_link_status(device_name='GNB0_HUB0'):
    """
    This keywork is to check primary link is syncd or not
    Public function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :return A list with status and value, for example:['Not synced', u'0x00000A0B']

    """

    result_hub_version = hub_instance.get_hostname_for_hub()

    if result_hub_version == 'fzhub20':
        primary_address = '0xa1110024'
    else:
        primary_address = '0xa010c024'

    value = hub_instance.get_cpri_link_value(address=primary_address)

    if re.search(r'0x[\dABCDEF]*F$', value):
        return 'Synced', value
    else:
        return 'Not synced', value


@connect_to_hub
def get_ant_port_rate(device_name='GNB0_HUB0', port_number=None):
    """
    This keyword is to get ant port rate
    Public function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param port_number: The port num of ant, index is from 0 to 11.
    :return result: Ant port rate

    """

    if port_number is None:
        MolerTest.error("Please afford necessary arguments port_number={}".
                        format(port_number), raise_exception=True)

    ant_port_address = ant_port_list[int(port_number)]

    result_hub_version = hub_instance.get_hostname_for_hub()

    if result_hub_version == 'fzhub20':
        result = hub_instance.get_cpri_link_value(address=ant_port_address)
        ret = re.search(r'0x[\dABCDEF]*(?P<rate>[\dABCDEF])', result)
        if ret.group(1) == '6':
            return 'Rate6'
        elif ret.group(1) == '8':
            return 'Rate8'
        elif ret.group(1) == 'A':
            return 'Rate10'
        else:
            raise Exception(
                'The Ant port rate {} is not match with 5G or 4G ant'.format(result))
    else:
        result = hub_instance.get_ant_port_rate(
            cmd='quadphy', options='-c -p', port_num=port_number)
        return result


@connect_to_hub
def get_hub_build_version(device_name='GNB0_HUB0'):
    """
    This keyword is to get hub build version
    Public function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :return

    """
    result = hub_instance.get_hub_build_version()
    return result


@connect_to_hub
def get_active_hub_build_version(device_name='GNB0_HUB0'):
    """
    This keyword is to get active hub build version
    Public function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :return active_hub_build_version: hub build version in active partition

    """
    active_hub_build_version = hub_instance.get_active_hub_build_version()
    return active_hub_build_version


@connect_to_hub
def code_load(device_name='GNB0_HUB0', build_version=None, filename=None, directory=None):
    """
    This keyword is to get active hub build version
    Public function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param build_version: loaded version of the build
    :param filename: name of file with build to load
    :param directory: path to file with build to load
    :return None

    """
    if build_version is None or filename is None or directory is None:
        MolerTest.error("Please afford necessary arguments build_version={} filename={} directory={}".
                        format(build_version, filename, directory), raise_exception=True)

    hub_instance.code_load(build_version=build_version,
                           filename=filename, directory=directory)


def get_hub_build_version_from_url(url):
    """
    The keyword gets a Hub's build version from the given URL.
    Public Function

    :param url: URL to Hub's configuration
    :return: Hub's build version
    """

    hub_build_version = GenericHub.get_hub_build_version_from_url(url)
    return hub_build_version


@connect_to_hub
def get_ant_status(device_name='GNB0_HUB0', port=0, device=0, address=0, timeout=120, step=10):
    """
    Check if there is a record in the register corresponding to the given antenna parameters.
    Public Function
    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param port: port where antenna is connected
    :param device: antenna number
    :param address: antenna address
    :param timeout: timeout for vrha_mem command checking ant status
    :param step: step between checks
    :return: 'Detected' or 'Not detected'
    """

    ant_status = hub_instance.get_ant_status(
        port=port, device=device, address=address, timeout=timeout, step=step)
    return ant_status


def check_if_antennas_detected(device_name='GNB0_HUB0', number_of_antennas=1, device=0, address=0):
    """
    Check if there is a record in the register corresponding to the given antenna parameters.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param number_of_antennas: number of antennas available
    :param device: device number
    :param address: antenna address
    :return: nothing
    """

    MolerTest.info(
        "Checking if {} antennas are detected...".format(number_of_antennas))

    for i in range(int(number_of_antennas)):
        detected_status = get_ant_status(
            device_name=device_name, port=i, device=device, address=address)

        if detected_status == 'Detected':
            MolerTest.info('Ant {} is detected'.format(i))
        else:
            MolerTest.error('Ant {} is not detected'.format(i))


@connect_to_hub
def collect_snapshot_from_hub(device_name='GNB0_HUB0'):
    """
    Collect snapshot from Hub.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :return: result of snapshot log catch command
    """
    now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = "Hub_Snapshot_{}_{}.zip".format(device_name, now)

    snapshot_result = hub_instance.collect_snapshot(filename=filename)

    if snapshot_result["SUCCESS"]:
        MolerTest.info("Logs from the Hub have been collected successfully")
    else:
        MolerTest.error(
            "There was an error while collecting logs from the Hub", raise_exception=True)

    return filename


@connect_to_hub
def download_snapshot_from_hub(device_name='GNB0_HUB0', output_dir=None, filename=None):
    """
    Download snapshot file from Hub to local directory.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param output_dir: local directory to save snapshot
    :param filename: name of file to download
    :return: None
    """

    if output_dir is None or filename is None:
        MolerTest.error('Please afford necessary parameter output_dir={}, filename={}'.format(output_dir, filename),
                        raise_exception=True)

    hub_instance.download_snapshot_from_hub(
        output_dir=output_dir, filename=filename)

    snapshot_path = os.path.join(output_dir, filename)
    MolerTest.info('snapshot_path={}'.format(snapshot_path))
    if os.path.exists(snapshot_path):
        return snapshot_path
    else:
        MolerTest.error('Snapshot file {} download failed'.format(
            filename), raise_exception=True)


@connect_to_hub
def download_vrha_log_from_hub(device_name='GNB0_HUB0', output_dir=None):
    """
    Download rfsw vrha log of all ANTs from Hub.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param output_dir: local directory to save snapshot
    :return: None
    """

    if output_dir is None:
        MolerTest.error('Please afford necessary parameter output_dir={}'.format(
            output_dir), raise_exception=True)

    hub_instance.collect_vrha_log(output_dir=output_dir)


@connect_to_hub
def download_lola_log_from_hub(device_name='GNB0_HUB0', output_dir=None):
    """
    Download rfsw lola log from Hub.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param output_dir: local directory to save snapshot
    :return: None
    """

    if output_dir is None:
        MolerTest.error('Please afford necessary parameter output_dir={}'.format(
            output_dir), raise_exception=True)

    hub_instance.collect_lola_log(output_dir=output_dir)


@connect_to_hub
def unplug_ant_from_hub(device_name='GNB0_HUB0', ant_port=None):
    """
    Unplug ant.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param ant_port: ant port
    :return: status of unplug ant
    """

    if ant_port is None:
        MolerTest.error('Please afford necessary parameter ant_port={}'.format(
            ant_port), raise_exception=True)

    result = hub_instance.unplug_ant(ant_port=ant_port)
    if result == 'success':
        MolerTest.info('Unplug ant port {} successfully'.format(ant_port))
    else:
        MolerTest.error('Unplug ant port {} fail'.format(
            ant_port), raise_exception=True)


@connect_to_hub
def plug_ant_from_hub(device_name='GNB0_HUB0', ant_port=None):
    """
    Plug ant.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param ant_port: ant port
    :return: status of plug ant
    """

    if ant_port is None:
        MolerTest.error('Please afford necessary parameter ant_port={}'.format(
            ant_port), raise_exception=True)

    result = hub_instance.plug_ant(ant_port=ant_port)
    if result == 'success':
        MolerTest.info('Plug ant port {} successfully'.format(ant_port))
    else:
        MolerTest.error('Plug ant port {} fail'.format(
            ant_port), raise_exception=True)


@connect_to_hub
def get_fpga_version_from_hub(device_name='GNB0_HUB0', ant_port=0, device=0, address=0x00000000):
    """
    Gets the fpga version on hub.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param ant_port: port where antenna is connected
    :param device: antenna number
    :param address: antenna address
    :return: the fpga version as string.
    """

    ant_version = get_fpga_version_of_specific_ant_from_hub(device_name=device_name, ant_port=ant_port, device=device,
                                                            address=address)

    ant_verison_filter = re.search(r'0x[A-Fa-f]\d\d\d', ant_version, re.I)
    if ant_verison_filter.group() == '0xa514' or ant_verison_filter.group() == '0xA514':
        cmd_path = '/lib/firmware/ant/squatch1/metainfo |head -1'
    elif ant_verison_filter.group() == '0xa515' or ant_verison_filter.group() == '0xA515':
        cmd_path = '/lib/firmware/ant/squatch2/metainfo |head -1'
    elif ant_verison_filter.group() == '0xa516' or ant_verison_filter.group() == '0xA516':
        cmd_path = '/lib/firmware/ant/squatch3/metainfo |head -1'

    fpga_version = hub_instance.get_fpga_version_on_hub(path=cmd_path)
    return fpga_version


@connect_to_hub
def get_fpga_version_of_specific_ant_from_hub(device_name='GNB0_HUB0', ant_port=0, device=0, address=0x00000000):
    """
    Get the fpga version of specific ant.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param ant_port: port where antenna is connected
    :param device: antenna number
    :param address: antenna address
    :return: fpga version of specific ant
    """

    result = hub_instance.get_fpga_version_of_specific_ant(
        ant_port=ant_port, device=device, address=address)
    return result


@connect_to_hub
def disable_hub_reboot(device_name='GNB0_HUB0'):
    """
    The keyword stop hub reboot for some log collection.
    Public Function

    :type device_name: name of the device, e.g 'GNB0_HUB0'
    :return: None
    """

    hub_instance.disable_hub_reboot()


@connect_to_hub
def enable_hub_reboot(device_name='GNB0_HUB0'):
    """
    The keyword remove the file appInhibitReboot to recover hub reboot mechanism.
    Public Function

    :type device_name: name of the device, e.g 'GNB0_HUB0'
    :return: None
    """

    hub_instance.enable_hub_reboot()


@connect_to_hub
def collect_arm_dump_log(device_name='GNB0_HUB0', output_dir=None, port_num=None):
    """
    The keyword collects ArmMemDump logs from HUB and download it to local.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param output_dir: directory on local device
    :param port_num: The port num of ant, index is from 0 to 11
    :return: None
    """

    if output_dir is None or port_num is None:
        MolerTest.error('Please afford necessary parameter output_dir={}, port_num={}'.format(output_dir, port_num),
                        raise_exception=True)
    arm_log_path = os.path.join(output_dir, 'arm{}.bin'.format(port_num))
    if os.path.exists(arm_log_path):
        os.system('rm -rf {}'.format(arm_log_path))

    tokelau_version = hub_instance.get_newest_tokelau_version()
    hub_instance.collect_arm_dump_log(output_dir=output_dir, port_num=port_num,
                                      tokelau_version=tokelau_version)

    if os.path.exists(arm_log_path):
        return arm_log_path
    else:
        MolerTest.error('Collect arm dump log failed', raise_exception=True)


@connect_to_hub
def collect_hub_power_management_log(device_name='GNB0_HUB0', output_dir=None):
    """
    Collect powerstats info of all hub components from HUB and download it to local.
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param output_dir: directory on local device
    :return: None
    """
    if output_dir is None:
        MolerTest.error('Please afford necessary parameter output_dir={}'.format(
            output_dir), raise_exception=True)

    hub_powerm_log_path = os.path.join(output_dir, 'hub_powerstats.log')
    if os.path.exists(hub_powerm_log_path):
        os.system('rm -rf {}'.format(hub_powerm_log_path))

    hub_instance.collect_hub_power_management_log(output_dir=output_dir)

    if os.path.exists(hub_powerm_log_path):
        return hub_powerm_log_path
    else:
        MolerTest.error(
            'Collect hub power management log failed', raise_exception=True)


@connect_to_hub
def get_ant_relevant_info(device_name='GNB0_HUB0', ant_port=None):
    """
    get_ant_relevant_info: Collect Ant relevant infomation as an OrderedDictionary,
        by specify hub's name and the ant's port
    Public Function

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :param ant_port: ant port
    :return: Ordered Dictionary of Ant relevant infomation
    """

    if ant_port is None:
        MolerTest.error('Please afford necessary parameter ant_port={}'.format(
            ant_port), raise_exception=True)
    return hub_instance.get_ant_relevant_info(ant_port=ant_port)


@connect_to_hub
def change_hub_password(device_name='GNB0_HUB0', new_password="", user=None):
    """
    Main Function:
        This keyword is used to change user hubadmin/hubapp password with password CLI.
    Arguments:
        :param device_name: name of the device, e.g 'GNB0_HUB0'
        :new_password: new password
        :user: hubadmin or hubapp, default is hubadmin user
    Return Value:
        :return: Dictionary of PASSWORD_CHANGED status
    Examples:
    Example 1: Change user hubadmin password
        | Change Hub Password | device_name='GNB0_HUB0' | new_password='Nokia57@ute!' |
    Example 2: Change user hubapp password
        | Change Hub Password | device_name='GNB0_HUB0' | new_password='Nokia57@ute!' | user='hubapp' |
    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei | 1.0.0 | 2022/11/21 | First approved version by VA |
    """
    ret = hub_instance.change_password(new_password=new_password, user=user)
    if ret.get('PASSWORD_CHANGED'):
        MolerTest.info("Change password successfully")
    else:
        MolerTest.error('Failed to change password', raise_exception=True)
    return ret


@connect_to_hub
def reset_to_default_hub_password(device_name='GNB0_HUB0', user=None, reset_to_default=False):
    """
    Main Function:
        This keyword is used to reset user hubadmin/hubapp password with password CLI.
    Arguments:
        :param device_name: name of the device, e.g 'GNB0_HUB0'
        :reset_to_default: True means to reset password
        :user: hubadmin or hubapp, default is hubadmin user
    Return Value:
        :return: Dictionary of PASSWORD_RESET status
    Examples:
    Example 1: Reset user hubadmin password
        | Reset To Default Hub Password | device_name='GNB0_HUB0' | reset_to_default=True |
    Example 2: Reset user hubapp password
        | Reset To Default Hub Password | device_name='GNB0_HUB0' | reset_to_default=True | user='hubapp' |
    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei | 1.0.0 | 2022/11/21 | First approved version by VA |
    """
    ret = hub_instance.change_password(user=user, reset_to_default=reset_to_default)
    if ret.get('PASSWORD_RESET'):
        MolerTest.info("Reset password successfully with hub password cli")
    else:
        MolerTest.error('Failed to reset password with hub password cli', raise_exception=True)
    return ret


@connect_to_hub
def hub_config_reset(device_name='GNB0_HUB0'):
    """
    Main Function:
        This keyword is used to reset user hubadmin/hubapp password with config_reset CLI.
    Arguments:
        :param device_name: name of the device, e.g 'GNB0_HUB0'
    Return Value:
        :return: Dictionary of PASSWORD_RESET status
    Examples:
        | Hub Config Reset | device_name='GNB0_HUB0' |
    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei | 1.0.0 | 2022/11/21 | First approved version by VA |
    """
    ret = hub_instance.config_reset()
    if ret.get('PASSWORD_RESET'):
        MolerTest.info("Reset password successfully with hub config_reset cli")
    else:
        MolerTest.error('Failed to reset password with hub config_reset cli', raise_exception=True)
    return ret


def connect_to_hubadmin_device(device_name='GNB0_HUB0'):
    """
    Main Function:
        This keyword is used to connect hub device.
    Arguments:
        :param device_name: name of the device, e.g 'GNB0_HUB0'
    Return Value:
        None
    Examples:
        | Connect To Hubadmin Device | device_name='GNB0_HUB0' |
    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei | 1.0.0 | 2022/11/21 | First approved version by VA |
    """
    hub_instance.device.goto_state("PROXY_PC")
    hub_instance.connect_to_hub()


def connect_to_hubapp_with_ssh_command(device_name='GNB0_HUB0', login='hubapp', host='192.168.255.129', password=None):
    """
    Main Function:
        This keyword is used to connect to hubapp with ssh command.
    Arguments:
        :param device_name: name of the hub device
        :param login: user
        :host: host ip
        :password: login password
    Return Value:
        None
    Examples:
        | Connect To Hubapp With Ssh Command | login='hubapp' | host='192.168.255.129' | password='Nokia57@ute!' |
    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei | 1.0.0 | 2022/11/21 | First approved version by VA |
    """
    MolerTest.info("SSH login and connect to hub....")
    hub_instance.device.goto_state("PROXY_PC")
    hub_instance.connect_to_hubapp(login=login, host=host, password=password)


def change_hubadmin_default_login_password(device_name='GNB0_HUB0', password="oZPS0POrRieRtu"):
    """
    Main Function:
        This keyword is used to change hubadmin login default password.
    Arguments:
        :param device_name: name of the device, e.g 'GNB0_HUB0'
        :param password: default password is oZPS0POrRieRtu
    Return Value:
        None
    Examples:
        | Change Hubadmin Default Login Password | device_name='GNB0_HUB0' | password='Nokia57@ute!' |
    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei | 1.0.0 | 2022/11/21 | First approved version by VA |
    """
    MolerTest.info("Change hubamdin default password")
    hub_instance.change_user_hubadmin_default_login_password(password=password)


@connect_to_hub
def check_hub_account_status(device_name='GNB0_HUB0', user="hubapp", options="-S", check_user_status="L"):
    """
    Main Function:
        This keyword is used to check hub account status.
    Arguments:
        :param device_name: name of the device, e.g 'GNB0_HUB0'
        :param user: hub user
        :options: additional command parameters
    Return Value:
        None
    Examples:
        | Check Hub Account Status | device_name='GNB0_HUB0' | user='hubapp' | options='-S' |
    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei | 1.0.0 | 2022/11/21 | First approved version by VA |
    """
    ret = hub_instance.check_hub_account_status(user=user, options=options, check_user_status=check_user_status)
    return ret


@connect_to_hub
def connect_to_hub_with_default_password(device_name='GNB0_HUB0'):
    """
    Main Function:
        This keyword is used to connect hub device.
    Arguments:
        :param device_name: name of the device, e.g 'GNB0_HUB0'
    Return Value:
        None
    Examples:
        | Connect To Hub Device | device_name='GNB0_HUB0' |
    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei | 1.0.0 | 2022/12/13 | First approved version by VA |
    """
    MolerTest.info("Connect To Hub ....")


@connect_to_hub
def check_hub_predefined_login_available_accounts(device_name='GNB0_HUB0'):
    """
    Main Function:
        This keyword is used to get users who can login to Hub.
        The predefined password file is as below:
          toor4nsn@fzhub10:~# cat /etc/passwd
                toor4nsn:x:0:0::/user/toor4nsn:/bin/bash
                root:x:0:0:root:/user/toor4nsn:/sbin/nologin
                daemon:x:1:1:daemon:/usr/sbin:/bin/false
                bin:x:2:2:bin:/bin:/bin/false
                ... ...
        If '/sbin/nologin', '/bin/false' and others found in the line, it means the user can not login to Hub
        Else, e.g. '/bin/bash' found in the line, it means the user can login to Hub
        The available login user should be in 'hubapp','toor4nsn','ftp' ('sync')

    Return Value:
        :return: List of users who can login

    Examples:
        check_hub_predefined_login_available_accounts()
    """
    ret = hub_instance.get_hub_password_info()
    users_can_login = []
    for line in ret:
        user_name = line.split(':')[0]
        user_authority = line.split(':')[-1]
        if '/sbin/nologin' in user_authority or '/bin/false' in user_authority:
            continue
        elif user_name in ['hubapp', 'toor4nsn', 'ftp', 'sync']:
            users_can_login.append(user_name)
        else:
            MolerTest.error("User {} should not have login access!".format(user_name), raise_exception=True)

    return users_can_login


@connect_to_hub
def check_hub_account_uid_is_unique(device_name='GNB0_HUB0'):
    """
    Main Function:
        This keyword is used to check account UIDs in Hub are different.
        The predefined account file is as below:
          toor4nsn@fzhub10:~# cat /etc/passwd
                toor4nsn:x:0:0::/user/toor4nsn:/bin/bash
                root:x:0:0:root:/user/toor4nsn:/sbin/nologin
                daemon:x:1:1:daemon:/usr/sbin:/bin/false
                bin:x:2:2:bin:/bin:/bin/false
                ... ...
        For toor4nsn and root user, they have the same UID:0, however because root user has no login permission,
        when 'root:x:0:0:root:/user/toor4nsn:/sbin/nologin' detected, it can be ignored.

    Return Value:
        None

    Examples:
        check_hub_account_uid_is_unique()
    """
    ret = hub_instance.get_hub_password_info()
    uid_list = [line.split(':')[2] for line in ret]
    MolerTest.info("uid_list: {}".format(uid_list))
    if len(set(uid_list)) == len(uid_list):
        MolerTest.info("UID is unique in RFC passwd file")
    else:
        uid_list.remove('0')
        MolerTest.info("uid_list_new: {}".format(uid_list))
        if "root:x:0:0:root:/user/toor4nsn:/sbin/nologin" in ret and len(set(uid_list)) == len(uid_list):
            MolerTest.info("root user has nologin authority")
            MolerTest.info("UID is unique in RFC passwd file")
        else:
            MolerTest.error("UID is not unique in RFC passwd file!", raise_exception=True)
