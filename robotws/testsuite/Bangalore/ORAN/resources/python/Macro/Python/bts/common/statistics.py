"""
Keywords for gNB.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""

from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    utilities import load_moler_configuration_from_tl
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    cpu_count import CpuCount

from moler.device import DeviceFactory


@load_moler_configuration_from_tl()
def start_cpu_monitoring(interval=10):
    """
    Start monitoring of CPU on gnb and local unix.

    :param interval: time in seconds between measurements.
    :return: None.
    """
    interval = int(interval)
    cpu_count = CpuCount.get_instance()
    gnb = DeviceFactory.get_device(name='GNB0')
    cpu_count.add_device(name=gnb.name, state='FCT', clone=True)
    unix_local = DeviceFactory.get_device(name='GNB0_WS')
    cpu_count.add_device(name=unix_local.name, state='UNIX_LOCAL', clone=True)
    cpu_count.set_interval(interval=interval)
    cpu_count.start_observer()


@load_moler_configuration_from_tl()
def stop_cpu_monitoring():
    """
    Stop monitoring of CPU.

    :return: None.
    """
    cpu_count = CpuCount.get_instance()
    cpu_count.stop_observer()
