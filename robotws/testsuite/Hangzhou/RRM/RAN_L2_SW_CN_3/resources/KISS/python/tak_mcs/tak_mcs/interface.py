# -*- coding: utf-8 -*-
"""
:created on: 2018-10-12

:copyright: Nokia
:author: Yonna
:contact: yonna.yao@nokia.com
"""

from ute_common_store import Store
from .mcs import MCSControl2, MCSControl3


class tak_mcs(object):

    """

        Introduction
        ************

        These keywords are used for JieXi MCS control.


        Install Before Keyword Used
        ************

        MCS control PC should install:

        ::

            1. MCS Setup
            2. MCS server
            3. Cygwin (or enable ssh service in windows system)


        Config Before Keyword Used
        ************

        After install these application, these operation should be done before run keyword

        ::

            1. MCS server config(only for MCS 2.0).
                System setting -> Server IP:0.0.0.0 -> Server Port :18888 -> Apply
            2. create short link for MCSServ.exe(should do config in both MCS 2.0 and MCS 3.0)
                1). cd C:\\Program Files\\Topyoung\\MCS Server\\ (MCS sever installation path)
                2). Select 'MCSServ.exe' or 'MCS_Controller.exe',right click mouse,select 'Create shortcut'
                3). copy shortcut file to C:\\, and rename it as 'mcsserver.exe'
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.store = Store()
        self.ssh_client = None

    def mcs_setup(self, host_ip, device_ip, db_path=None, mcs_port=18888, timeout=180,
                  username='tdlte-tester', password='btstest', prompt='>', alias='default'):
        """MCS setup. It will start mcs server process, connect to mcs device, import db file.
        :param string host_ip:                    host ip running mcs server
        :param string device_ip:                  mcs ip
        :param string db_path:                    db file path
        :param integer mcs_port:                  mcs port, it is 18888 in mcs 2.0 and 28888 in mcs 3.0
        :param integer timeout:                   timeout of mcs execute command
        :param string username:                   user name of host ip
        :param string password:                   password of host ip
        :param string prompt:                     prompt used in ssh
        :param string alias:                      alias
        """
        if mcs_port == 18888:
            mcs = MCSControl2(server_ip=host_ip, dev_ip=device_ip, mcs_port=mcs_port, timeout=timeout,
                              server_uname=username, server_pwd=password, prompt=prompt)
        else:
            mcs = MCSControl3(server_ip=host_ip, dev_ip=device_ip, mcs_port=mcs_port, timeout=timeout,
                              server_uname=username, server_pwd=password, prompt=prompt)
        self.store.add(mcs, alias)
        mcs.mcs_prepare(db_path)

    def mcs_query_idn(self, alias='default'):
        """Query device idn.

        :param string alias:         alias

        :return:                     idn info.
        :rtype:                      string
        """
        return self.store.get(alias).query_idn()

    def mcs_query_hw_version(self, alias='default'):
        """Query device HW version.

        :param string alias:          alias

        :return:                      device HW version info.
        :rtype:                       string
        """
        return self.store.get(alias).query_hw_version()

    def mcs_query_calibrated_frequency(self, alias='default'):
        """List calibrated frequency data.

        :param string alias:         alias

        :return:                      calibrated data, eg. [2300, 2600, 3500] or NONE
         :rtype:                      list
        """
        return self.store.get(alias).query_calibrated_frequency()

    def mcs_set_frequency(self, frequency, alias='default'):
        """Set frequency.

        :param string frequency:          frequency data
        :param string alias:              alias
        """
        self.store.get(alias).set_frequency(frequency)

    def mcs_query_in_use_frequency(self, alias='default'):
        """Query frequency in using. Call "Mcs Set Frequency" is precondition.

        :param string alias:              alias

        :return:                          frequency data
        :rtype:                           string
        """
        return self.store.get(alias).query_current_frequency()

    def mcs_set_phase(self, phase, alias='default'):
        """Set channel's phase data.If set fail will try once again.Call "Mcs Set Frequency" is precondition.

        :param dictionary phase:          dictionary contain channel and phase
        :param string alias:              alias

        Example::

            ${phase}=     Create Dictionary     A1B1=5.625        A1B2=11.25
            MCS Set Phase     ${phase}
            MCS Set Phase        phase=/home/phase.csv

        **CSV FORMAT MUST AS:**

        ::

          phase   |    A1     |    A2     |    A3     |    A4     |    A5     |    A6     |    A7    |  ...
            B1    |  135.02   |  135.22   |  135.02   |  135.02   |  135.02   |  135.02   |  135.02  |  ...
            B2    |  45.07    |   90.14   |   180.27  |   315.1   |   180.27  |   180.27  |  180.27  |  ...

        """
        self.store.get(alias).set_phase(phase)

    def mcs_set_phase_by_port(self, port, angle_h, angle_v, alias='default'):
        """set channel's phase data using angle value. Call "Mcs Set Frequency" is precondition.

        :param string port:               port, it can set as 1 or 1,2,3,4
        :param float angle_h:             angle horizontal value
        :param float angle_v:             angle vertical value
        :param string alias:              alias

        Example::

            Mcs Set Phase By Port    port=1    angle_h=-20    angle_v=30
            Mcs Set Phase By Port    port=2,3,4    angle_h=-10    angle_v=40
        """
        self.store.get(alias).set_phase_by_port(port, angle_h, angle_v)

    def mcs_set_attenuation(self, att, alias='default'):
        """Set channel's attenuation data.If set fail will try once again.Call "Mcs Set Frequency" is precondition.

        :param dictionary att:             dictionary contain channel and attenuation
        :param string alias:               alias

        Example::

            ${att}=    Create Dictionary      A1B1=1            A1B2=10
            MCS Set Attenuation        ${att}
            MCS Set Attenuation        att=/home/att.csv

                **CSV FORMAT MUST AS:**

        ::

          phase   |    A1     |    A2     |    A3     |    A4     |    A5     |    A6     |    A7    |  ...
            B1    |    10     |    20     |    10     |    20     |    50     |    60     |    50    |  ...
            B2    |    10     |    10     |    10     |    30     |   50      |    70     |    70    |  ...

        """
        self.store.get(alias).set_attenuation(att)

    def mcs_set_attenuation_by_port(self, port, att_odd, att_even, alias='default'):
        """Set channel's attenuation data.Call "Mcs Set Frequency" is precondition.

        :param string port:               port, it can set as 1 or 1,2,3,4
        :param float att_odd:             attenuation odd value
        :param float att_even:            attenuation even value
        :param string alias:               alias

        Example::

            Mcs Set Attenuation By Port     port=1    att_odd=10    att_even=90
            Mcs Set Attenuation By Port     port=2,3,4    att_odd=20    att_even=80
        """
        self.store.get(alias).set_attenuation_by_port(port, att_odd, att_even)

    def mcs_set_channel_phase_and_attenuation(self, att_phase, alias='default'):
        """Set channel's phase and attenuation.If set fail will try once again.
        Call "Mcs Set Frequency" is precondition.

        :param dictionary att_phase:        dictionary contain channel, phase and attenuation
        :param string alias:                alias

        Example::
            # in dictionary phase_att, the value should be define as format 'attenuation,phase'
            ${phase_att}=    Create Dictionary       A1B1=1,5.6            A1B2=4,11.25
            MCS Set Channel Phase And Attenuation        att_phase=${phase_att}

        """
        self.store.get(alias).set_channel_phase_and_attenuation(att_phase)

    def mcs_query_channel_phase_and_attenuation(self, channel='ALL', alias='default'):
        """Query channel's phase and attenuation.Call "Mcs Set Frequency" is precondition.

        :param string channel:                channel info. default is 'ALL'
        :param string alias:                  alias

        :return:                              channel and its phase & attenuation
        :rtype:                               dictionary
        """
        return self.store.get(alias).query_channel_phase_and_attenuation(channel)

    def mcs_read_error_info(self, alias='default'):
        """Read error info.

        :param string alias:                  alias

        :return:                              error info
        :rtype:                               string
        """
        return self.store.get(alias).read_error_info()

    def mcs_apply_channel_for_resource(self, channel, alias='default'):
        self.store.get(alias).apply_channel_for_resource(channel)

    def mcs_get_calibration_file_name(self, alias='default'):
        return self.store.get(alias).get_calibration_file_name()

    def mcs_get_loading_scene_process(self, alias='default'):
        return self.store.get(alias).get_loading_scene_process()

    def mcs_get_playback_scene_process(self, alias='default'):
        return self.store.get(alias).get_playback_scene_process()

    def mcs_get_reference_channel(self, bport, alias='default'):
        return self.store.get(alias).get_reference_channel(bport)

    def mcs_get_resource_usage_info(self, alias='default'):
        return self.store.get(alias).get_resource_usage_info()

    def mcs_get_scene(self, alias='default'):
        return self.store.get(alias).get_scene()

    def mcs_get_ul_calibration_file_name(self, alias='default'):
        return self.store.get(alias).get_ul_calibration_file_name()

    def mcs_load_scene(self, csv_name, alias='default'):
        self.store.get(alias).load_scene(csv_name)

    def mcs_pause_playback_scene(self, alias='default'):
        self.store.get(alias).pause_playback_scene()

    def mcs_reboot(self, alias='default'):
        self.store.get(alias).reboot_mcs()

    def mcs_release_resource(self, alias='default'):
        self.store.get(alias).release_resource()

    def mcs_restart_playback_scene(self, alias='default'):
        self.store.get(alias).restart_playback_scene()

    def mcs_set_reference_channel(self, channel, alias='default'):
        self.store.get(alias).set_reference_channel(channel)

    def mcs_set_ul_frequency(self, csn_name, alias='default'):
        self.store.get(alias).set_ul_frequency(csn_name)

    def mcs_start_playback_scene(self, loop_time=10, alias='default'):
        self.store.get(alias).start_playback_scene(loop_time)

    def mcs_start_single_frame_playback_scene(self, frame_num, alias='default'):
        self.store.get(alias).start_single_frame_playback_scene(frame_num)

    def mcs_stop_playback_scene(self, alias='default'):
        self.store.get(alias).stop_playback_scene()

    def mcs_teardown(self, alias='default'):
        """Disconnect mcs device, and close socket connect.

        :param string alias:                   alias
        :return:
        """
        try:
            self.store.get(alias).mcs_disconnection()
        finally:
            self.store.remove(alias)
