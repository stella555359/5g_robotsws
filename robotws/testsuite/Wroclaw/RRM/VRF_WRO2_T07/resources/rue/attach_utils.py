import time
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue import adb_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl


def get_library_instance(library):
    instance = BuiltIn().get_library_instance(library)
    if not instance:
        raise ImportError('Unable to access %s instance, check if library is imported' % instance)
    return instance


taf_ue = get_library_instance('taf.ue')


@logged_keyword
def require_ues(num_of_ues, capabilities='REAL_UE'):
    for ue in range(1, int(num_of_ues) + 1):
        logged_keyword(taf_ue.require_ue)(ue_alias='UE_{}'.format(ue), capabilities=capabilities)


@logged_keyword
def attach_ues(num_of_ues):
    for ue in range(1, int(num_of_ues) + 1):
        logged_keyword(taf_ue.attach_ue)('UE_{}'.format(ue))


@logged_keyword
def attach_one_ue(ue_number):
    logged_keyword(taf_ue.attach_ue)('UE_{}'.format(ue_number))


@logged_keyword
def detach_ues(num_of_ues):
    for ue in range(1, int(num_of_ues) + 1):
        logged_keyword(taf_ue.detach_ue)('UE_{}'.format(ue))


@logged_keyword
def start_ul_data_transfer_on_ues(num_of_ues, duration='100s', throughput='100Mbits/sec', protocol='udp',
                                  parallel_streams='1', packet_size='1200', max_segment_size='1450', custom_dt_name=""):
    for ue in range(1, int(num_of_ues) + 1):
        if custom_dt_name == "":
            logged_keyword(taf_ue.start_data_transfer)(dt_name='DT_UL_{}'.format(ue), ue_alias='UE_{}'.format(ue),
                                                       direction='UL', duration=duration,
                                                       throughput=throughput, protocol=protocol,
                                                       packet_size=packet_size, parallel_streams=parallel_streams,
                                                       max_segment_size=max_segment_size)
        else:
            logged_keyword(taf_ue.start_data_transfer)(dt_name="DT_UL{}_{}".format(custom_dt_name, ue),
                                                       ue_alias='UE_{}'.format(ue),
                                                       direction='UL', duration=duration,
                                                       throughput=throughput, protocol=protocol,
                                                       packet_size=packet_size, parallel_streams=parallel_streams,
                                                       max_segment_size=max_segment_size)


@logged_keyword
def start_dl_data_transfer_on_ues(num_of_ues, duration='100s', throughput='100Mbits/sec', protocol='udp',
                                  parallel_streams='1', packet_size='1200', max_segment_size='1450', custom_dt_name="",
                                  buffer='50M'):
    for ue in range(1, int(num_of_ues) + 1):
        if custom_dt_name == "":
            logged_keyword(taf_ue.start_data_transfer)(dt_name='DT_DL_{}'.format(str(ue)), ue_alias='UE_{}'.format(ue),
                                                       direction='DL', duration=duration,
                                                       throughput=throughput, protocol=protocol,
                                                       packet_size=packet_size, parallel_streams=parallel_streams,
                                                       max_segment_size=max_segment_size,
                                                       buffer=buffer)
        else:
            logged_keyword(taf_ue.start_data_transfer)(dt_name="DT_DL{}_{}".format(custom_dt_name, ue),
                                                       ue_alias='UE_{}'.format(ue),
                                                       direction='DL', duration=duration,
                                                       throughput=throughput, protocol=protocol,
                                                       packet_size=packet_size, parallel_streams=parallel_streams,
                                                       max_segment_size=max_segment_size,
                                                       buffer=buffer)


@logged_keyword
def check_ul_transfer_is_alive(num_of_ues, custom_dt_name=""):
    for ue in range(1, int(num_of_ues) + 1):
        if custom_dt_name == "":
            logged_keyword(taf_ue.check_data_transfer_is_alive)('DT_UL_{}'.format(ue))
        else:
            logged_keyword(taf_ue.check_data_transfer_is_alive)("DT_UL{}_{}".format(custom_dt_name, ue))


@logged_keyword
def check_dl_transfer_is_alive(num_of_ues, custom_dt_name=""):
    for ue in range(1, int(num_of_ues) + 1):
        if custom_dt_name == "":
            logged_keyword(taf_ue.check_data_transfer_is_alive)('DT_DL_{}'.format(ue))
        else:
            logged_keyword(taf_ue.check_data_transfer_is_alive)("DT_DL{}_{}".format(custom_dt_name, ue))


@logged_keyword
def await_dl_data_transfer_finish(num_of_ues, custom_dt_name=""):
    for ue in range(1, int(num_of_ues) + 1):
        if custom_dt_name == "":
            logged_keyword(taf_ue.await_data_transfer_finish)('DT_DL_{}'.format(ue))
        else:
            logged_keyword(taf_ue.await_data_transfer_finish)("DT_DL{}_{}".format(custom_dt_name, ue))


@logged_keyword
def await_ul_data_transfer_finish(num_of_ues, custom_dt_name=""):
    for ue in range(1, int(num_of_ues) + 1):
        if custom_dt_name == "":
            logged_keyword(taf_ue.await_data_transfer_finish)('DT_UL_{}'.format(ue))
        else:
            logged_keyword(taf_ue.await_data_transfer_finish)("DT_UL{}_{}".format(custom_dt_name, ue))


@logged_keyword
def stop_ul_data_transfer_on_ues(num_of_ues):
    for ue in range(1, int(num_of_ues) + 1):
        logged_keyword(taf_ue.stop_data_transfer)('DT_UL_{}'.format(ue))


@logged_keyword
def stop_dl_data_transfer_on_ues(num_of_ues):
    for ue in range(1, int(num_of_ues) + 1):
        logged_keyword(taf_ue.stop_data_transfer)('DT_DL_{}'.format(ue))


@logged_keyword
def verify_average_ul_throughput(num_of_ues, tput_min='10Mbits/sec', omit=0, end=0, custom_dt_name=''):
    for ue in range(1, int(num_of_ues) + 1):
        if custom_dt_name == "":
            logged_keyword(taf_ue.verify_average_throughput)(dt_name='DT_UL_{}'
                                                             .format(ue), tput_min=tput_min, omit=omit, end=end)
        else:
            logged_keyword(taf_ue.verify_average_throughput)(dt_name="DT_UL{}_{}".format(custom_dt_name, ue),
                                                             tput_min=tput_min, omit=omit, end=end)


@logged_keyword
def verify_average_dl_throughput(num_of_ues, tput_min='10Mbits/sec', omit=0, end=0, custom_dt_name=''):
    for ue in range(1, int(num_of_ues) + 1):
        if custom_dt_name == "":
            logged_keyword(taf_ue.verify_average_throughput)(dt_name='DT_DL_{}'
                                                             .format(ue), tput_min=tput_min, omit=omit, end=end)
        else:
            logged_keyword(taf_ue.verify_average_throughput)(dt_name="DT_DL{}_{}".format(custom_dt_name, ue),
                                                             tput_min=tput_min, omit=omit, end=end)


@logged_keyword
def change_network_mode(ue_alias, network_mode):
    taf_ue.change_network_mode(ue_alias, network_mode)


@logged_keyword
def start_voice_call(vc_alias='VC_1', ue_alias='UE_1', to='UE_2'):
    taf_ue.start_voice_call(vc_alias=vc_alias, ue_alias=ue_alias, to=to)


@logged_keyword
def stop_voice_call(vc_alias='VC_1'):
    taf_ue.stop_voice_call(vc_alias=vc_alias)


@logged_keyword
def await_incoming_voice_call(vc_alias='VC_1', ue_alias='UE_2', action='answer', timeout='20'):
    taf_ue.await_incoming_voice_call(vc_alias=vc_alias, ue_alias=ue_alias, action=action, timeout=timeout)


@logged_keyword
def set_network_mode(ues_list, reboot_ues=True, remove_pyro_dir=True):
    net_mode_time = 15
    try:
        if reboot_ues:
            adb_utils.reboot_ues()
        if remove_pyro_dir:
            adb_utils.remove_pyro_server_dir()
        current_ue_alias = 1
        for ues in ues_list:
            for ue in range(int(ues['number_of_ues'])):
                logged_keyword(taf_ue.require_ue)(ue_alias='UE_{}'.format(current_ue_alias),
                                                  capabilities=ues['capabilities'])
                blog("Changing network mode to {0} on UE {1}".format(ues['network_mode'], current_ue_alias))
                try:
                    change_network_mode('UE_{0}'.format(current_ue_alias), ues['network_mode'])
                except BaseException as e:
                    blog("There was an error during changing network mode: {}".format(e), level='ERROR')
                current_ue_alias += 1
                time.sleep(net_mode_time)
    except BaseException as e:
        blog("Changing network mode failed!".format(e), level='ERROR')
        raise e
    return True


@logged_keyword
def check_ue_attach_and_tput(number_of_ues, min_ul_tput='15Mbits/sec', min_dl_tput='15Mbits/sec',
                             ul_tput='200Mbits/sec', dl_tput='200Mbits/sec'):
    require_ues(number_of_ues)
    try:
        blog("Attaching UEs...", level='INFO')
        attach_ues(number_of_ues)
        blog("Starting DL/UL data transfer on UEs...", level='INFO')
        start_ul_data_transfer_on_ues(num_of_ues=number_of_ues, duration='100s', throughput=ul_tput)
        start_dl_data_transfer_on_ues(num_of_ues=number_of_ues, duration='100s', throughput=dl_tput)
        blog("Waiting for data transfer to finish...", level='INFO')
        time.sleep(50)
        blog("Verifying DL/UL throughput...", level='INFO')
        verify_average_ul_throughput(num_of_ues=number_of_ues, tput_min=min_ul_tput)
        verify_average_dl_throughput(num_of_ues=number_of_ues, tput_min=min_dl_tput)
    except BaseException:
        assert False, "UE attach and throughput check failed!"
    finally:
        detach_ues(num_of_ues=number_of_ues)
    return True
