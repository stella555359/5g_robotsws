from moler.util.moler_test import MolerTest

from taf.rfrl.bts.devices.ru.ru_operations import GenericRuOperations
from taf.rfrl.bts.devices.generic_bts import login_logout
from time import time as tm


class BBSubUnit(GenericRuOperations):

    def __init__(self, bts_type=0):
        """
        Constructor of GenericBbbu class.
        :param bts_type: GNB|ENB
        :return: None
        """
        super(BBSubUnit, self).__init__(bts_type=bts_type)

    @MolerTest.raise_background_exceptions()
    @login_logout
    def verify_asik_status(self, bts_id=0, du_id=0):
        """
        Check if there are any unwanted events on ASIK(Common Unit)

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        system_module_info = self.admin.get_fsm_info(connection=self.rest_alias.format(bts_id, du_id),
                                                     timeout=30)
        for system in system_module_info:
            if system['status']['operationalState'].lower() != "enabled" \
                    or system['status']['availabilityStatus'].lower() != "online" \
                    or system['status']['administrativeState'].lower() != "unlocked":
                MolerTest.error(
                    "Operational state: {}, should be Enabled\nAvailability status: {} should be Online\n"
                    "Administrative state: {} should be Unlocked".format(system['status']['operationalState'],
                                                                         system['status']['availabilityStatus'],
                                                                         system['status']['administrativeState']))

    def verify_ru_status(self):
        """
        Verify radio unit status

        :return: None
        """
        self.admin.connect_to()
        bts_info = self.admin.get_bts_info()
        operational_state = (bts_info["radioModules"]["rmod"][0]["status"]["operationalState"])
        availability_status = (bts_info["radioModules"]["rmod"][0]["status"]["availabilityStatus"])
        administrative_state = (bts_info["radioModules"]["rmod"][0]["status"]["administrativeState"])
        self.admin.teardown()
        return operational_state, availability_status, administrative_state

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def wait_for_ru(self, timeout=600):
        """
        Wait for expected radio unit status

        :return: None
        """
        status = True
        start_time = tm()
        elapsed_time = 0
        while status and elapsed_time < timeout:
            operational_state, availability_status, administrative_state = self.verify_ru_status()
            if availability_status == "Online" and operational_state == "Enabled" and \
                    administrative_state == "Unlocked":
                status = False
            else:
                MolerTest.sleep(30)
                elapsed_time = int(tm() - start_time)
        if status:
            MolerTest.error("Not expected RU status: availability_status={}, operational_state={},"
                            " administrative_state={}".format(availability_status, operational_state,
                                                              administrative_state))
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_ru_status_after_restart(self):
        """
        Verify radio unit status after restart

        :return: None
        """
        operational_state, availability_status, administrative_state = self.verify_ru_status()
        if availability_status != "NotInstalled" or operational_state != "Disabled" or \
                administrative_state != "Unlocked":
            MolerTest.error("Not expected RU status: availability_status={}, operational_state={},"
                            " administrative_state={}".format(availability_status, operational_state,
                                                              administrative_state))
        MolerTest.steps_end()
