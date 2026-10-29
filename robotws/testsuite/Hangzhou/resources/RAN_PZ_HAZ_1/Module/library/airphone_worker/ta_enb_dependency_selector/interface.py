# -*- coding: utf-8 -*-

from . import enb_build_files


class ta_enb_dependency_selector(object):
    """
    Introduction
    ************

    Robot and Command Line Interface that enables the user to download necessary enb specific files
    to their test line.

    KWARGS parameters
    *****************

    This library uses the robot framework SSH library. You can customize the SSH connection using kwargs.

    :Supported SSH parameters are available via kwargs:
            * **ssh_host_ip***   (string)  - Machine that hosts the SSH connection. Default is '127.0.0.1'
            * **ssh_port**       (integer) - SSH service port available on specified machine. Default is 22.
            * **ssh_prompt**     (string)  - SH prompt available after log in. Default is '$ '.
            * **ssh_username**   (string)  - Username valid for SSH authentication. Default is 'ute'.
            * **ssh_password**   (string)  - Password valid for SSH authentication. Default is 'ute'.
            * **ssh_timeout**    (string/int) - SSH Timeout, int is measured in ms. Default is '900s'.
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def download_k3_files(self, enb_load=None, dest='/opt/k3/lib64', **kwargs):
        """
        Downloads k3 codecs and ttcn3 data types


        :param string enb_load:              eNB load that is being used by the user.
        Default is None which gets TargetBD to acquire enb_load
        :param string dest:                  Destination of the downloaded k3 files. Default is /opt/k3/lib64

        K3 codecs will be downloaded to the **dest** value while TTCN-3 data types will be downloaded to
        {dest}/k3/plugins/ttcn3.

        :KWARG values:
            * **trs_ip**    (string) - IP address of eNB

        NOTE
        ----
        Current implementation (FB16.09) will download latest files from K3 trunk repository. This will
        change on FB16.10 where it will be taken from LOM.


        Example
        -------

        ::

            Download K3 Files   enb_load=FL00_1234_99999_0000   dest='/home/ute'

            will have the files placed in:

            *K3 CODECS*         - /home/ute
            *TTCN-3 DATA TYPES* - /home/ute/k3/plugins/ttcn3

        """
        enb_build_files.download_k3_files(enb_load=enb_load, dest=dest, **kwargs)

    def download_ws_lte_files(self, enb_load=None, dest=None, **kwargs):
        """
        Downloads Wireshark LTE codec


        :param string enb_load:              eNB load that is being used by the user.
        Default is None which gets TargetBD to acquire enb_load
        :param string dest:                  Custom Wireshark LTE codec destination.

        Wireshark LTE codec will be downloaded to ~/.config/wireshark/plugins/ by default.

        :KWARG values:
            * **trs_ip**    (string) - IP address of eNB

        """
        enb_build_files.download_ws_lte_files(enb_load=enb_load, dest=dest, **kwargs)

    def get_nsetap_version(self, enb_load=None):
        """
        Get NSETAP version in enb specific metafile.ini from files.ute

        :param string enb_load:     eNB load that is being used by the user. Default is None
        which gets TargetBD to acquire enb_load
        :rtype:                     string
        :return:                    nsetap version (e.g. 0.7.1)
        """
        return enb_build_files.get_nsetap_version(enb_load=enb_load)
