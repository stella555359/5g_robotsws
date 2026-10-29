from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout_GUI


class PMQAPDU(GenericBts):
    """Class contains keywords for gNB"""

    def __init__(self):
        """
        Constructor
        """
        super(PMQAPDU, self).__init__(bts_type='GNB')

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
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors,
                                    sbts=gui_alias)

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
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='NRPMQAP',
                                 id_value=instance_id,
                                 is_load_default_values=True,
                                 sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors,
                                    sbts=gui_alias)

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
