from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.utilities.tl_config import tl


class CBSD(GnbCommissioning):
    def __init__(self):
        super(CBSD, self).__init__()

    def update_supportedChBw_for_cbsd(self, new_channels_bw):
        nrcbrspr_dn = 'MRBTS-{}/NRBTS-{}/NRCBRSPR-1'.format(tl.gnbs[0].instance_id, tl.gnbs[0].global_bts_id)
        new_supportedChBw = "0b"
        new_channels_bw = [int(channel[:-3]) for channel in new_channels_bw.split(",")]
        channel_bw_available = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]
        for channel in reversed(channel_bw_available):
            if channel in new_channels_bw:
                new_supportedChBw += "1"
            else:
                new_supportedChBw += "0"
        new_supportedChBw = int(new_supportedChBw, 2)
        self.perform_configuration_parameter_recommissioning(operation='update', dist_name=nrcbrspr_dn,
                                                             parameter='supportedChBw', value=new_supportedChBw)
