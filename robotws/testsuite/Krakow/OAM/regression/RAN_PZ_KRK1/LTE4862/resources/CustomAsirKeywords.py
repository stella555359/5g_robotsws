import logging
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations, login_logout
from taf.rfrl.bts.devices.asir.dist_name_patterns import AsirDistNamePatterns


class CustomAsirKeywords(GnbAsirHubOperations):

    @login_logout
    def verify_rfc_is_commissioned(self,  rfc_id=1, bts_id=0):
        rfc_details = self._get_rfc_details()
        commissioning_state = self._get_rfc_commissioning_state(uid=rfc_details['uid'])
        if commissioning_state == 'Yes':
            logging.info("RFC {} is Commissioned".format(rfc_id))
        else:
            raise ValueError("RFC {} is not Commissioned".format(rfc_id))

    def _get_rfc_details(self, rfc_id=1):
        return self._get_all_dist_names_and_uids(AsirDistNamePatterns.re_rfc_dist_name.format(rfc_id))[0]

    def _get_rfc_commissioning_state(self, uid, bts_id=0):
        info = self.get_unit_logical_info(uid)
        logging.debug("Details for UID {}: {}".format(uid, info))
        states = self._get_states_from_logical_info(info)
        for state in states:
            if state['title'] == 'Commissioned':
                return state['text']
