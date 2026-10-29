from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.du_operations import login_logout


class Bbmod_operations(GnbDuOperations):

    def __init__(self,):
        """
        Constructor of Bbmod_operations class.
        :return: None
        """
        super(Bbmod_operations, self).__init__()
        self.uptime = {}

    @login_logout
    def reset_bbmod_with_timeout(self, bts_id=0, du_id=0, bbmod_id=1, timeout=1200):
        """
        Reset BBMOD
        :param bts_id:      ID of gNB/eNB, default 0
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param bbmod_id:    RUNTIME BBMOD ID
        :param timeout:     timeout
        :return:    None
        """
        # eg: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-2
        dist_name = self._get_runtime_bbmod_dist_name(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id)

        self.admin.reset_unit(connection=self.rest_alias.format(bts_id, du_id),
                              dist_name=dist_name, reset_type='Warm', timeout=timeout)
