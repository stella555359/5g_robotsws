from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout_GUI, login_logout
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


class PMQAPDU(GenericBts):

    @login_logout_GUI
    def create_plmn_profile(self, instance_id, activate_plan_despite_errors=False, bts_id=0, du_id=0):
        """
        Create PLMN profile in PMQAP instance on DU

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param instance_id: instance id
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)
        dist_name = "{}/NRPMQAP-{}".format(dist_name, str(instance_id))
        self.gui_coam.add_element(dist_name=dist_name,
                                  filter_param='PLMN ID configuration',
                                  abbr='cfgPlmnId',
                                  sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=dist_name,
                                          filter_param='MCC of PLMN ID',
                                          new_value=1,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=dist_name,
                                          filter_param='MNC of PLMN ID',
                                          new_value=1,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=dist_name,
                                          filter_param='MNC length of PLMN ID',
                                          new_value=2,
                                          sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    @login_logout_GUI
    def set_parameter(self, new_parameter, new_value, bts_id=0, du_id=0):
        """
        Create PMQAP instance on DU

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param new_parameter: parameter to change
        :new_value: new parameter value
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/LTEENB-0", bts_id=bts_id, du_id=du_id)
        self.gui_coam.set_parameter_value(dist_name=dist_name,
                                          filter_param=new_parameter,
                                          new_value=new_value,
                                          sbts=gui_alias)

        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(sbts=gui_alias)

    @login_logout_GUI
    def handle_UE_inactivity(self, activate, timer, bts_id=0, du_id=0):
        """
        Activate ue inactivity timer
        :param activate: activate ue inactivity
        :param timer:   inactivity timer
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        self.gui_coam.set_parameter_value(dist_name, filter_param='Activate inactivity detection for NSA UE',
                                          new_value=activate, sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name, filter_param='Non Stand Alone inactivity timer', new_value=timer,
                                          sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(sbts=gui_alias)

    @login_logout_GUI
    def create_pmqap_instance(self, instance_id, activate_plan_despite_errors=False,
                              bts_id=0, du_id=0):
        """
        Create PMQAP instance on DU

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param instance_id: instance id
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        sw_version = GnbDuOperations().get_bts_sw_version(bts_id=bts_id, du_id=du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='NRPMQAP',
                                 id_value=instance_id,
                                 is_load_default_values=True,
                                 sbts=gui_alias)

        if SbtsSwVersion(sw_version) >= SbtsSwVersion('SBTS23R2_ENB_0000_000000_000000'):
            dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMQAP-1", bts_id=bts_id, du_id=du_id)
            self.gui_coam.delete_parameter(dist_name=dist_name,
                                           filter_param="Throughput histogram scale type for both UL and DL "
                                                        "throughput distribution counters",
                                           sbts=gui_alias
                                           )
        if SbtsSwVersion(sw_version) >= SbtsSwVersion('SBTS23R4_ENB_0000_000000_000000'):
            dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMQAP-1", bts_id=bts_id, du_id=du_id)
            self.gui_coam.delete_parameter(dist_name=dist_name,
                                           filter_param="AM RLC DL delay threshold",
                                           sbts=gui_alias
                                           )
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    @login_logout_GUI
    def delete_pmqap_instance(self, instance_id, activate_plan_despite_errors=False,
                              bts_id=0, du_id=0):
        """
        Delete PMQAP instance from DU

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param instance_id: instance id
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)
        dist_name = "{}/NRPMQAP-{}".format(dist_name, str(instance_id))

        self.gui_coam.remove_object(object_name=dist_name, sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    @login_logout_GUI
    def get_pm_counter_info_via_gui(self, counter_id, full_path, bts_id=0, du_id=0):
        """
        Function to fetch a counter value from BTS Counters section in WebEM via Selenium

        :param counter_id: counter name to fetch from GUI
        :type  counter_id: str

        """
        return next(iter(self.gui_coam.get_bts_counters_info(counter_id=counter_id, full_path=full_path,
                                                             sbts=self.gui_alias.format(bts_id, du_id)).values()))


class EnbPMQAPDU(PMQAPDU):

    bts_type = 'ENB'

    def __init__(self):
        super(EnbPMQAPDU, self).__init__(bts_type=EnbPMQAPDU.bts_type)


class GnbPMQAPDU(PMQAPDU):

    bts_type = 'GNB'

    def __init__(self):
        super(GnbPMQAPDU, self).__init__(bts_type=GnbPMQAPDU.bts_type)
