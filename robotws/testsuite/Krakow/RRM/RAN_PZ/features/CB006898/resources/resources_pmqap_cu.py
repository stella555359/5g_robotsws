from taf.rfrl.bts.devices.cu.generic_cu import GenericCu, login_logout_GUI


class PMQAPCU(GenericCu):
    """Class contains keywords for gNB"""

    def __init__(self):
        """
        Constructor
        """
        super(PMQAPCU, self).__init__(bts_type='GNB')

    @login_logout_GUI
    def create_cu_plmn_profile(self, instance_id, bts_id=0, du_id=0):
        """
        Create PLMN profile in PMQAP instance on CU

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param instance_id: instance id
        :return: None
        """

        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)
        dist_name = "{}/NRPMQAP-{}".format(dist_name, str(instance_id))
        items = {'mcc': 1, 'mnc': 1, 'mncLength': 2}
        try:
            self.gui_coam_cu.create_delta_plan("NEW_PLAN")
            self.gui_coam_cu.add_element(object_name=dist_name, filter_param='PLMN ID configuration',
                                         abbreviation='cfgPlmnId', structure_items=items)
            self.gui_coam_cu.validate_plan()
            self.gui_coam_cu.activate_plan(activate_plan_despite_reset=True, activate_plan_despite_cell_locking=True)
        except Exception as error:
            raise error
        finally:
            self.gui_coam_cu.choose_plan(plan_name="NEW_PLAN")
            self.gui_coam_cu.delete_plan(timeout=60)

    @login_logout_GUI
    def create_cu_pmqap_instance(self, instance_id, bts_id=0, du_id=0):
        """
        Create PMQAP instance on CU

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param instance_id: instance id
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)
        try:
            self.gui_coam_cu.create_delta_plan("NEW_PLAN")
            self.gui_coam_cu.choose_plan("NEW_PLAN")
            self.gui_coam_cu.add_object(dist_name=dist_name, object_class_name='NRPMQAP', is_load_default_values=True,
                                        id_value=instance_id)
            self.gui_coam_cu.validate_plan()
            self.gui_coam_cu.activate_plan(activate_plan_despite_reset=True, activate_plan_despite_cell_locking=True)
        except Exception as error:
            raise error
        finally:
            self.gui_coam_cu.choose_plan(plan_name="NEW_PLAN")
            self.gui_coam_cu.delete_plan(timeout=60)

    @login_logout_GUI
    def delete_cu_pmqap_instance(self, instance_id, bts_id=0, du_id=0):
        """
        Delete PMQAP instance from CU

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param instance_id: instance id
        :return: None
        """

        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)
        dist_name = "{}/NRPMQAP-{}".format(dist_name, str(instance_id))
        try:
            self.gui_coam_cu.create_delta_plan("NEW_PLAN")
            self.gui_coam_cu.choose_plan("NEW_PLAN")
            self.gui_coam_cu.remove_object(object_name=dist_name, timeout=60)
            self.gui_coam_cu.validate_plan()
            self.gui_coam_cu.activate_plan(activate_plan_despite_reset=True, activate_plan_despite_cell_locking=True)
        except Exception as error:
            raise error
        finally:
            self.gui_coam_cu.choose_plan(plan_name="NEW_PLAN")
            self.gui_coam_cu.delete_plan(timeout=60)

    @login_logout_GUI
    def set_measurement(self, name, measurement_id, value, bts_id=0, du_id=0):
        """
        Set measurement

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param name: parameter
        :param measurement_id: abbreviation of the parameter
        :param value: parameter value
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)
        self.set_parameter(dist_name, name, measurement_id, value)

    @login_logout_GUI
    def set_profile(self, name, abbr, value, instance_id, bts_id=0, du_id=0):
        """
        Set PMQAP profile

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param name: parameter
        :param abbr: abbreviation of the parameter
        :param value: parameter value
        :param instance_id: instance id
        :return: None
        """

        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)
        dist_name = "{}/NRPMQAP-{}".format(dist_name, str(instance_id))
        self.set_parameter(dist_name, name, abbr, value)

    @login_logout_GUI
    def activate_feature_CB006898(self, value, bts_id=0, du_id=0):
        """
        Set feature flag
        :param value: parameter value
        :return: None
        """

        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        self.set_parameter(dist_name, 'Activate QOS NRPMQAP profiles', 'actNrpmqapProfiles', value)

    def handle_UE_inactivity(self, activate, timer, bts_id=0, du_id=0):
        """
        Activate ue inactivity timer
        :param activate: activate ue inactivity
        :param timer:   inactivity timer
        :return: None
        """

        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        self.set_parameter(dist_name, 'Activate inactivity detection for NSA UE', 'actInactDetNSAUe', activate)
        self.set_parameter(dist_name, 'Non Stand Alone inactivity timer', 'nsaInactivityTimer', timer)

    @login_logout_GUI
    def set_parameter(self, dist_name, name, abbr, value, bts_id=0, du_id=0):
        """
        Set parameter on CU via GUI
        :param dist_name: dist name of the parameter
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param name: parameter
        :param abbr: abbreviation of the parameter
        :param value: parameter value
        :return: None
        """

        try:
            self.gui_coam_cu.create_delta_plan("NEW_PLAN")
            self.gui_coam_cu.choose_plan("NEW_PLAN")
            current_parameter = self.gui_coam_cu.get_parameter_value(object_name=dist_name,
                                                                     filter_param=name,
                                                                     abbreviation=abbr)
            if current_parameter != value:
                self.gui_coam_cu.set_parameter_value(object_name=dist_name,
                                                     filter_param=name,
                                                     new_value=value,
                                                     abbr=abbr,
                                                     timeout=60)
                self.gui_coam_cu.activate_plan(timeout=60)
        except Exception as error:
            raise error
        finally:
            self.gui_coam_cu.choose_plan(plan_name="NEW_PLAN")
            self.gui_coam_cu.delete_plan()
