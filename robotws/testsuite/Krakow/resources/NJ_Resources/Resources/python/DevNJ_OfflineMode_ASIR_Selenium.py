from DevNJ_ASIR_Selenium import *
try:
    import numpy
except Exception as e:
    pass
import re


class DevNJ_OfflineMode_ASIR_Selenium(DevNJ_ASIR_Selenium):
    """
    Library to manipulate offline ASIR WebEM test with Selenium
    """
    def switch_to_tab(tab, wait_after_switch=True):
        """
        Decorator for keywords that need to switch to spefified tab
        """

        def switch_to_tab_decorator(func):
            @wraps(func)
            def wrapped_function(self, *args, **kwargs):
                self.switch_to_dedicated_tab(tab, wait_after_switch)
                return func(self, *args, **kwargs)

            return wrapped_function

        return switch_to_tab_decorator

    def catch_exception(func):
        """
        Decorator for keywords need to catch exception and save screenshot
        """

        @wraps(func)
        def interface_func(*args, **kwargs):
            try:
                outcome = func(*args, **kwargs)
            except Exception:
                instance = args[0]
                instance.save_screenshot('{}.png'.format(func.__name__))
                raise
            return outcome

        return interface_func

    @catch_exception
    def import_airscale_system_file(self, sub_type='host', location=None, host_file_name=None, second_file_name=None,
                                    initial_flag=False):
        """
        This method used to import airscale configuration file, which both host and secondary type are supported.
        but host system file is required to be imported in advance if you want to import secondary system file.
        :param sub_type: airscale system file type, host or secondary
        :param location: the airscale system file location
        :param host_file_name: the airscale host system file name
        :param second_file_name: the airscale secondary system file name, not mandatory if sub_type is host
        :param initial_flag: flag used to judge whether it is imported by offline tool initial login interface
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium import_airscale_system_file", also_console=True)
        _xpath_import_airscale_button = "//button[@id='importAirScaleStartButton']"
        _xpath_host_system_button = "//button[@id='load-host-system-file-button']"
        _xpath_secondary_system_button = "//button[@id='load-secondary-system-file']"
        _xpath_host_system_file_label = "//input[@id='load-host-system-file-input']"
        _xpath_secondary_system_file_label = "//input[@id='load-secondary-system-file-input']"

        airscale_host_file = os.path.join(location, host_file_name)
        assert (os.path.exists(airscale_host_file)
                ), "{0} system config file is not exist, please check!".format(airscale_host_file)

        time.sleep(3)
        if initial_flag:
            import_airscale_button = Wait(self.wd, self.ui_delay * 5).until(
                EC.element_to_be_clickable((By.XPATH, _xpath_import_airscale_button)))
            if import_airscale_button:
                self.wd.find_element(By.XPATH, _xpath_import_airscale_button).click()

        logger.info("import airscale host system file {0}.".format(airscale_host_file), also_console=True)
        load_system_button = Wait(self.wd, self.ui_delay * 5).until(
            EC.element_to_be_clickable((By.XPATH, _xpath_host_system_button)))
        if load_system_button:
            time.sleep(self.ui_delay * 3)
            self.wd.find_element(By.XPATH, _xpath_host_system_file_label).send_keys(airscale_host_file)

        if sub_type == 'secondary':
            assert (second_file_name is not None
                    ), "airscale secondary system file name is {0}, please check!".format(second_file_name)
            airscale_second_file = os.path.join(location, second_file_name)
            assert (os.path.exists(airscale_second_file)
                    ), "{0} system config file is not exist, please check!".format(airscale_second_file)
            logger.info("sub_type is {0},import secondary system file {1}.".format(sub_type, airscale_second_file),
                        also_console=True)

            load_second_button = Wait(self.wd, self.ui_delay * 5).until(
                EC.element_to_be_clickable((By.XPATH, _xpath_secondary_system_button)))
            if load_second_button:
                time.sleep(self.ui_delay * 3)
                self.wd.find_element(By.XPATH, _xpath_secondary_system_file_label).send_keys(airscale_second_file)

    @catch_exception
    def remove_airscale_secondary_system_file(self, remove_type, airscale_file_name=None):
        """
        This method used to remove airscale secondary system file, both single and all remove are supported.
        :param remove_type: remove single file or all if more than one, single or all
        :param airscale_file_name: airscale system file name which to be removed
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium remove_airscale_secondary_system_file", also_console=True)
        _xpath_remove_all_button = "//button[@id='remove-all-secondary-system-file']"
        _xpath_remove_single_button = \
            "//span[contains(text(),'{0}')]//..//button[contains(@id,'remove-secondary')]".format(airscale_file_name)
        _xpath_remove_all_confirm_btn = "//button[contains(text(),'Remove all')]"
        _xpath_rmv_single_confirm_btn = "//button[contains(text(),'Remove')]"
        _xpath_remove_button = _xpath_remove_all_button if remove_type == 'all' else _xpath_remove_single_button
        _xpath_confirm_btn = _xpath_remove_all_confirm_btn if remove_type == 'all' else _xpath_rmv_single_confirm_btn
        if remove_type == 'all':
            logger.info("You choose to remove all secondary system files.", also_console=True)
            self.wd.find_element(By.XPATH, _xpath_remove_button).click()
            time.sleep(self.ui_delay)
            confirm_button = self.wd.find_element(By.XPATH, _xpath_confirm_btn)
            if confirm_button:
                confirm_button.click()
        else:
            assert (airscale_file_name is not None
                    ), "airscale secondary system file name is {0}, please check!".format(airscale_file_name)
            logger.info("Choose to remove {0} secondary system file.".format(airscale_file_name), also_console=True)
            time.sleep(self.ui_delay)
            Wait(self.wd, self.ui_delay * 5).until(
                EC.element_to_be_clickable((By.XPATH, _xpath_remove_button)))
            self.wd.find_element(By.XPATH, _xpath_remove_button).click()
            time.sleep(self.ui_delay)
            confirm_button = self.wd.find_element(By.XPATH, _xpath_confirm_btn)
            if confirm_button:
                confirm_button.click()

    @catch_exception
    def _populate_asirmod_to_shub_mapping(self, asir_id, shub_id):
        """
        Internal method used to populate asirmod & hubmod mapping relation.
        :param asir_id: asir module identifier
        :param shub_id: smart hub identifier
        """
        xpath_asir_locator = "//tr[contains(@id,'ASIRMOD-{0}')]"
        xpath_shub_locator = "{0}//td//*[contains(@class, 'hubmodMoi')]"
        assert (asir_id and shub_id), "please input mandatory parameter asir_id and shub_id."
        try:
            self.wd.find_element(By.XPATH, xpath_asir_locator.format(asir_id))

        except Exception as Ex:
            if "no such element:" in Ex.msg:
                raise Exception("Unable to locate ASIRMOD-{0}, check its existence!".format(asir_id))

        shub_element = self.wd.find_element(By.XPATH, xpath_shub_locator.format(xpath_asir_locator.format(asir_id)))
        if shub_element and shub_element.tag_name == 'mat-select':
            logger.info("populate ASIRMOD-{0} to mat-select HUBMOD-{1}.".format(asir_id, shub_id), also_console=True)
            self._select_value_in_mat_select(shub_element,
                                             "HUBMOD-{0}".format(shub_id),
                                             lambda x, y: x.strip() == y.strip(),
                                             check_required=False)
        elif shub_element and shub_element.tag_name == 'input':
            logger.info("populate ASIRMOD-{0} to HUBMOD-{1}.".format(asir_id, shub_id), also_console=True)
            shub_element.clear()
            shub_element.send_keys("HUBMOD-{0}".format(shub_id))
        else:
            raise Exception("Unable to find element or its tag type is unsupported!")

    @catch_exception
    def map_secondary_asirmod_to_shub(self, asir_shub_dict, switch_to_next=False):
        """
        Main Function:
        This method used to map relation between ASIR and HUBMOD after import airscale host & secondary system file

        Arguments:
            :param asir_shub_dict: dictionary of asir & shub mapping
            format should be similar: asir_shub_dict = {'ASIRMOD-1' : 'HUBMOD-2',
                                                        'ASIRMOD-2' : 'HUBMOD-1'}
            :param switch_to_next: flag button for switch to other tab to do further operation

        Return Value:
            None

        Examples:
            ${map_dict}  create dictionary  ASIRMOD-1=HUBMOD-22  ASIRMOD-2=HUBMOD-23  ASIRMOD-3=HUBMOD-24
            Map Secondary Asirmod To Shub  asir_shub_dict=${map_dict}  switch_to_next=${True}

        Version:
            | Author | Version | Delivery Date | Comments |
            | Sun Jingang | 1.0.0 | 2021/10/09 | First approved version by VA |
            | Sun Jingang | 1.0.1 | 2022/01/25 | adaption for CNI-77365 |
            | Sun Jingang | 1.0.2 | 2022/03/08 | remove unnecessary verification |
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium map_airscale_asir_hubmod_relationship", also_console=True)
        xpath_asir_table_locator = "//div[@id='secondary-system-file-mapping-table']"
        xpath_asir_ele_locator = "//tr[contains(@id,'ASIRMOD-')]"
        asir_list = []

        assert asir_shub_dict, "empty dictionary of asir and shub mapping."
        Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located((By.XPATH, xpath_asir_table_locator)))
        asir_elements = self.wd.find_elements(By.XPATH, xpath_asir_ele_locator)
        for index in range(len(asir_elements)):
            asir_list.append(asir_elements[index].get_attribute('id'))

        for asir, hub in asir_shub_dict.items():
            time.sleep(1)
            if asir.strip() not in asir_list:
                raise Exception("{0} module you want to manipulate is not exist.".format(asir))

            self._populate_asirmod_to_shub_mapping(asir_id=asir.split('-')[-1],
                                                   shub_id=hub.split('-')[-1])

        time.sleep(2)
        if switch_to_next:
            self._stepper_to_next_tab()

    @catch_exception
    def _populate_shub_to_asirmod(self, asir_id, shub_id, user_label=None):
        """
        Internal method used to populate shub & asirmod mapping relation.
        :param asir_id: asir module identifier
        :param shub_id: smart hub identifier
        :param user_label: user label description
        """
        xpath_map_item_locator = "//div[@id='system-file-factory-table']//tbody//tr"
        map_item_found = None
        shub_asir_list = self.wd.find_elements(By.XPATH, xpath_map_item_locator)
        if shub_asir_list:
            for shub_asir_item in shub_asir_list:
                try:
                    map_item_found = shub_asir_item.find_element(By.XPATH, ".//td//div[contains(@class, \
                                            'hostAsirMod')]//span[contains(text(), 'ASIRMOD-{0}')]".format(asir_id))
                    if map_item_found:
                        map_item_found = shub_asir_item
                        break

                except Exception as Ex:
                    if "no such element:" in Ex.msg:
                        continue

            shub_found = map_item_found.find_element(By.XPATH, ".//*[contains(@class, 'sHUB')]")
            if shub_found and shub_found.tag_name == 'mat-select':
                # HUBMOD-12 (APHA)
                logger.info("map ASIRMOD-{0} to mat-select HUBMOD-{1}.".format(asir_id, shub_id), also_console=True)
                self._select_value_in_mat_select(shub_found,
                                                 "HUBMOD-{0}".format(shub_id),
                                                 lambda x, y: y.strip() == x.strip().replace(' ', '').split('(')[0],
                                                 check_required=False)
            time.sleep(1)
            if user_label is not None:
                label_found = map_item_found.find_element(By.XPATH, ".//*[contains(@class, 'userLabel')]")
                if label_found and label_found.tag_name == 'input':
                    logger.info("set HUBMOD-{0} user label {1}.".format(shub_id, user_label), also_console=True)
                    label_found.clear()
                    label_found.send_keys(user_label)

        else:
            raise Exception("Unable to find any shub & asirmod mapped item.")

    @catch_exception
    def map_shub_to_host_asirmod(self, shub_asir_dict):
        """
        Main Function:
        This method used to map relation between sHUB and host ASIR after import airscale host & second system file.

        Arguments:
           :param shub_asir_dict: dictionary of shub & asirmod mapping
           format should be like: shub_asir_dict = {'ASIRMOD-1' : {'hubmod_id' : 1, 'user_label' : 'test purpose'},
                                                    'ASIRMOD-2' : {'hubmod_id' : 2, 'user_label' : 'hello python'}}

        Return Value:
           None

        Examples:
           ${dict}  create dictionary  hubmod_id=24
           ${tmp_dict}  create dictionary  ASIRMOD-1=${dict}
           map shub to host asirmod  shub_asir_dict=${tmp_dict}

        Version:
           | Author | Version | Delivery Date | Comments |
           | Sun Jingang | 1.0.0 | 2022/1/25 | First approved version for CNI-77365 |
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium map_shub_to_host_asirmod", also_console=True)
        xpath_shub_table_locator = "//div[@id='system-file-factory-table']"
        xpath_asir_locator = \
            "//div[@id='system-file-factory-table']//tbody//tr//td//div[contains(@class, 'hostAsirMod')]//span"

        assert shub_asir_dict, "empty dictionary of shub and asirmod mapping."
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_shub_table_locator)))
        asirmod_elements = self.wd.find_elements(By.XPATH, xpath_asir_locator)
        actual_asirid_list = [asir_ele.text.strip().split('-')[-1] for asir_ele in asirmod_elements]
        logger.info("Availabel host ASIRMOD Id list : {0}".format(actual_asirid_list))

        for asirmod, shub in shub_asir_dict.items():
            if asirmod.split('-')[-1] in actual_asirid_list:
                self._populate_shub_to_asirmod(asirmod.split('-')[-1],
                                               shub.get('hubmod_id'),
                                               shub.get('user_label'))
            else:
                raise Exception("asirmod_id - {0} you manipulate is not exist.".format(asirmod.split('-')[-1]))

    @catch_exception
    def _stepper_to_next_tab(self):
        """
        Internal method for click next button to switch to next tab do further operation.
        """
        xpath_next_button = "//button[contains(@id, 'next')]"
        xpath_warning_modal = "//div[@class='modal-panel']"
        xpath_header_text = "{0}//div[contains(@class, 'header-text')]"
        xpath_finish_button = "//div[@class='modal-panel']//button[contains(@class, 'primary')]"

        next_button = self.wd.find_element(By.XPATH, xpath_next_button)
        if next_button and next_button.get_attribute('disabled') != 'true':
            next_button.click()
            try:
                self.wd.find_element(By.XPATH, xpath_warning_modal)
                header_text = self.wd.find_element(By.XPATH, xpath_header_text.format(xpath_warning_modal))
                finish_button = self.wd.find_element(By.XPATH, xpath_finish_button)
                time.sleep(2)
                if header_text and 'Finishing' in header_text.text:
                    finish_button.click()

            except Exception as ex:
                if "no such element:" in ex.msg:
                    logger.info("No warning modal appear!")

        else:
            raise Exception("Next button is in disabled status.")

    @catch_exception
    def import_asir_commission_file(self, location=None, asir_file_name=None):
        """
        This method used to import asir commission file.
        :param location: the ASIR commission file location
        :param asir_file_name: the ASIR commission file name
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium import_asir_commission_file", also_console=True)
        _xpath_import_asir_button = "//button[@id='configFromFileStartButton']"
        _xpath_file_select_button = "//button[@id='file-select-button']"
        _xpath_input_file_label = "//input[@id='file']"
        _xpath_warning_icon_label = "//mat-icon[@id='warning-message-icon']"
        _xpath_warning_message_label = "//p[contains(@id,'warning-message-title')]"
        _xpath_migrate_next_button = "//button[@id='stepper-next-button']"

        if not location:
            asir_config_file = asir_file_name
        else:
            asir_config_file = os.path.join(location, asir_file_name)

        assert (os.path.exists(asir_config_file)
                ), "{0} commission file is not exist, please check!".format(asir_file_name)

        select_button = Wait(self.wd, self.ui_delay * 2).until(
            EC.element_to_be_clickable((By.XPATH, _xpath_file_select_button)))
        if select_button:
            self.wd.find_element(By.XPATH, _xpath_input_file_label).send_keys(asir_config_file)

        # below enhancement is required for config migration scenario
        try:
            self.wd.find_element(By.XPATH, _xpath_warning_icon_label)
            self.wd.find_element(By.XPATH, _xpath_warning_message_label)

            logger.info("Attention ASIR commission migration is required!", also_console=True)
            time.sleep(self.ui_delay * 3)
            stepper_next_button = Wait(self.wd, self.ui_delay * 5).until(
                EC.element_to_be_clickable((By.XPATH, _xpath_migrate_next_button)))
            if stepper_next_button:
                stepper_next_button.click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("configuration migration is not required!", also_console=True)

    @catch_exception
    def import_rfc_configuration_file(self, asir_location=None, asir_file_name=None, rfc_location=None,
                                      rfc_file_name=None, initial_flag=False):
        """
        This method used to import rfc configuration file, asir commission file need to be imported in advance.
        :param asir_location: the configuration file location
        :param asir_file_name: the ASIR commission file name
        :param rfc_location: the rfc file location
        :param rfc_file_name: the RFC configuration file name
        :param initial_flag: flag used to judge whether it is imported by offline tool initial login interface
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium import_rfc_configuration_file", also_console=True)
        _xpath_import_asir_button = "//button[@id='configFromFileStartButton']"
        _xpath_file_select_button = "//button[@id='file-select-button']"
        _xpath_import_rfc_button = "//button[@id='import-rfc-file-button']"
        _xpath_input_file_label = "//input[@id='file']"
        _xpath_warning_icon_label = "//mat-icon[@id='warning-message-icon']"
        _xpath_warning_message_label = "//p[contains(@id,'warning-message-title')]"
        _xpath_migrate_next_button = "//button[@id='stepper-next-button']"

        asir_config_file = os.path.join(asir_location, asir_file_name)
        rfc_config_file = os.path.join(rfc_location, rfc_file_name)
        assert (os.path.exists(asir_config_file) and os.path.exists(rfc_config_file)
                ), "{0} or {1} configuration file is not exist, please check!".format(asir_file_name, rfc_file_name)

        if initial_flag:
            import_asir_button = Wait(self.wd, self.ui_delay * 3).until(
                EC.element_to_be_clickable((By.XPATH, _xpath_import_asir_button)))
            if import_asir_button:
                self.wd.find_element(By.XPATH, _xpath_import_asir_button).click()

        select_button = Wait(self.wd, self.ui_delay * 3).until(
            EC.element_to_be_clickable((By.XPATH, _xpath_file_select_button)))
        if select_button:
            self.wd.find_element(By.XPATH, _xpath_input_file_label).send_keys(asir_config_file)

        # below enhancement is required for RFC configuration migration scenario
        try:
            self.wd.find_element(By.XPATH, _xpath_warning_icon_label)
            self.wd.find_element(By.XPATH, _xpath_warning_message_label)

            logger.info("RFC configuration migration is required!", also_console=True)
            time.sleep(self.ui_delay * 3)
            stepper_next_button = Wait(self.wd, self.ui_delay * 3).until(
                EC.element_to_be_clickable((By.XPATH, _xpath_migrate_next_button)))
            if stepper_next_button:
                stepper_next_button.click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("configuration migration is not required!", also_console=True)

        # switch to RFC tab due to other tabs were introduced
        logger.info("Switch to RFC dedicated tab!", also_console=True)
        self.switch_to_dedicated_tab('RFCs')
        time.sleep(2)

        import_rfc_button = Wait(self.wd, self.ui_delay * 5).until(
            EC.element_to_be_clickable((By.XPATH, _xpath_import_rfc_button)))
        if import_rfc_button:
            self.wd.find_element(By.XPATH, _xpath_input_file_label).send_keys(rfc_config_file)

    @switch_to_tab('Parameter editor')
    @catch_exception
    def add_tree_view_object(self, object_name, object_para_list):
        """
        This method used to add tree-view level object.
        :param object_name: the object name which to be added
        :param object_para_list: the detailed object parameter
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium add_tree_view_object", also_console=True)
        _xpath_object_tree_header = "//div[@id='tree-header']"
        _xpath_top_node = "//span[contains(text(),'ASI')]"
        _xpath_top_node_icon = "{}//..//..//mat-icon[contains(@class,'expand-header-icon')]".format(_xpath_top_node)
        _xpath_add_object_btn = "//button[@id='add-child-button']"
        _xpath_modal_panel = "//div[@class='modal-panel']"
        _xpath_add_object_class = "//mat-select[contains(@class,'selectMOC')]"
        _xpath_add_object_option = "//mat-option//span[contains(text(),'{0}')]".format(object_name)
        _xpath_modal_add_obj_btn = "//button[contains(@class,'add-mo-modal')]"
        _xpath_object_generated = \
            "//span[contains(@class,'node-name created') and contains(text(),'{0}')]".format(object_name)
        _xpath_prevalidate_btn = "//button[@id='run-prevalidation-btn']"

        Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located((By.XPATH, _xpath_object_tree_header)))

        top_node_icon = self.wd.find_element(By.XPATH, _xpath_top_node_icon)
        if top_node_icon:
            icon_status = top_node_icon.get_attribute('svgicon')
            if icon_status == 'expand':
                logger.info("top node icon has already been in expand status.", also_console=True)
                self.wd.find_element(By.XPATH, _xpath_top_node).click()
            else:
                logger.info("top node icon is in {0} status, expand it now.".format(icon_status), also_console=True)
                top_node_icon.click()

        self.wd.find_element(By.XPATH, _xpath_add_object_btn).click()

        Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located((By.XPATH, _xpath_modal_panel)))
        self.wd.find_element(By.XPATH, _xpath_add_object_class).click()
        time.sleep(2)
        self.wd.find_element(By.XPATH, _xpath_add_object_option).click()
        time.sleep(2)
        self.wd.find_element(By.XPATH, _xpath_modal_add_obj_btn).click()

        Wait(self.wd, self.ui_delay * 3).until(EC.element_to_be_clickable((By.XPATH, _xpath_object_generated)))
        self.wd.find_element(By.XPATH, _xpath_object_generated).click()

        for internal_key in object_para_list[0].keys():
            self._set_tree_view_text_value(internal_key, object_para_list[0][internal_key])

        for internal_key in object_para_list[1].keys():
            self._set_tree_view_text_value(internal_key, object_para_list[1][internal_key])

        self.wd.find_element(By.XPATH, _xpath_prevalidate_btn).click()

    @switch_to_tab('Parameter editor')
    @catch_exception
    def expand_collapse_tree_view_obj(self, op_type, asi_id, obj_name, obj_id):
        """
        This method used to expand/collapse tree-view level object, return sub-object number with expand operation.
        :param op_type: tree view level object operate type, expand or collapse
        :param asi_id: ASI identifier
        :param obj_name: object name you want to expand/collapse
        :param obj_id: object identifier you want to expand/collapse
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium expand_collapse_tree_view_obj", also_console=True)
        object_str = "ASI-{0}/{1}-{2}".format(asi_id, obj_name, obj_id)
        logger.info("the object you want to {0} is {1}".format(op_type, object_str), also_console=True)
        _xpath_object_icon = "//div[@id='{0}']//mat-icon".format(object_str)
        _xpath_sub_obj_label = "//div[contains(@id,'{0}/')]".format(object_str)
        try:
            object_icon = self.wd.find_element(By.XPATH, _xpath_object_icon)
            if object_icon:
                icon_value = object_icon.get_attribute('data-mat-icon-name')
                logger.info("icon value is {0}, {1} it now.".format(icon_value, op_type), also_console=True)
                if icon_value == 'arrowRight' and op_type == 'expand':
                    object_icon.click()
                    time.sleep(self.ui_delay)
                    sub_object = self.wd.find_elements(By.XPATH, _xpath_sub_obj_label)
                    return len(sub_object) if sub_object else None
                elif icon_value == 'expand' and op_type == 'collapse':
                    object_icon.click()
                    time.sleep(self.ui_delay)
                else:
                    logger.error("incorrect icon value {0}, can't {1}!".format(icon_value, op_type), also_console=True)
                    return None
        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("object {0} has no sub-obj, can't {1}.".format(object_str, op_type), also_console=True)

    @switch_to_tab('Parameter editor')
    @catch_exception
    def modify_object_with_tooltip(self, para_dict=None):
        """
        This method used to modify specific object parameter and verify tooltip appear or not after modification.
        :param para_dict: object parameter dict, format should be similar {'obj_mo' : 'ASI-1/CMCADM-1',
                                                                           'obj_para' : 'cmSyncCheckPeriod',
                                                                           'obj_value' : 60}
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium modify_object_with_tooltip", also_console=True)
        hdr_str = "//div[@id='parameters-view-table']//tbody//"
        _xpath_object_locator = "//div[@id='{0}']".format(para_dict['obj_mo'])
        _xpath_object_modify = \
            "{0}tr[contains(@id,'{1}')]//*[contains(@class,'parameterValue')]".format(hdr_str, para_dict['obj_para'])
        # temporary solution for tooltip appear
        _xpath_tree_path_locator = "//div[@id='tree-path']"

        assert (para_dict is not None
                ), "object you want to modify is {0}, please check!".format(para_dict)
        self.wd.find_element(By.XPATH, _xpath_object_locator).click()
        object_tag_name = self.wd.find_element(By.XPATH, _xpath_object_modify).tag_name

        if self._check_obj_tooltip_exist(hdr_str, para_dict['obj_para']) == 'False':
            logger.info("modify object {0} value to {1}".format(para_dict['obj_para'], para_dict['obj_value']),
                        also_console=True)
            if object_tag_name == 'input':
                self.wd.find_element(By.XPATH, _xpath_object_modify).clear()
                self.wd.find_element(By.XPATH, _xpath_object_modify).send_keys(para_dict['obj_value'])

            elif object_tag_name == 'mat-select':
                _xpath_mat_option = "//mat-option//span[contains(text(),'{0}')]".format(para_dict['obj_value'])
                self.wd.find_element(By.XPATH, _xpath_object_modify).click()
                time.sleep(self.ui_delay)
                self.wd.find_element(By.XPATH, _xpath_mat_option).click()

            else:
                logger.error("wrong operation, can't modify object {0}".format(para_dict['obj_para']))
                return

            # simulate mouse move after modification to trigger tooltip appear [Enter can't work]
            self.wd.find_element(By.XPATH, _xpath_tree_path_locator).click()
            logger.info("modification done!", also_console=True)

            if self._check_obj_tooltip_exist(hdr_str, para_dict['obj_para']) == 'True':
                logger.info("object {0} modify tooltip appeared!".format(para_dict['obj_para']), also_console=True)

    @switch_to_tab('Parameter editor')
    @catch_exception
    def delete_tree_view_object(self, object_name):
        """
        This method used to delete tree-view level object.
        :param object_name: the object name which to be deleted
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium delete_tree_view_object", also_console=True)
        _xpath_object_selected = \
            "//span[contains(@class,'node-name created') and contains(text(),'{0}')]".format(object_name)
        _xpath_delete_selected_obj_btn = "//button[@id='delete-object-button']"
        _xpath_modal_panel = "//div[@class='modal-panel']"
        _xpath_modal_remove_btn = "//button[contains(text(),'Remove')]"
        logger.info("begin to delete object {0}".format(object_name), also_console=True)
        self.wd.find_element(By.XPATH, _xpath_object_selected).click()
        self.wd.find_element(By.XPATH, _xpath_delete_selected_obj_btn).click()
        Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located((By.XPATH, _xpath_modal_panel)))
        time.sleep(self.ui_delay * 2)
        self.wd.find_element(By.XPATH, _xpath_modal_remove_btn).click()

    @switch_to_tab('Parameter editor')
    @catch_exception
    def get_rw_ro_para_type(self, asi_id, mod_name, mod_id, obj_name):
        """
        This method used to get ASIR commission parameter rw/ro attribute.
        :param asi_id: asir identifier
        :param mod_name: module name under asi
        :param mod_id: module identifier under asi
        :param obj_name: object name under module
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium get_rw_ro_para_type", also_console=True)
        module_str = "ASI-{0}/{1}-{2}".format(asi_id, mod_name, mod_id) \
            if mod_name and mod_id else "ASI-{0}".format(asi_id)
        header_str = "//div[@id='parameters-view-table']//tbody"
        _xpath_mod_selector = "//div[@id='{0}']".format(module_str)
        _xpath_mod_locator = "//span[contains(text(),'{0}-{1}') and contains(@id,'selected')]".format(mod_name, mod_id)
        _xpath_obj_locator = \
            "{0}//tr[contains(@id,'{1}')]//*[contains(@class,'parameterValue')]".format(header_str, obj_name)

        try:
            self.wd.find_element(By.XPATH, _xpath_mod_selector).click()
            Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located((By.XPATH, _xpath_mod_locator)))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("can't locate element {0}-{1}".format(mod_name, mod_id), also_console=True)
                return None

        time.sleep(self.ui_delay * 2)
        obj_element = self.wd.find_element(By.XPATH, _xpath_obj_locator)
        if obj_element:
            obj_attribute = obj_element.get_attribute('disabled')
            return 'ro' if obj_attribute == 'true' else 'rw'

    @switch_to_tab('Parameter editor')
    @catch_exception
    def create_object_with_structure(self, asi_id, mod_name, mod_id, obj_name, para_list):
        """
        This method used to create/add parameter view level object with data structure.
        :param asi_id: asir identifier
        :param mod_name: module name under asi
        :param mod_id: module identifier under asi
        :param obj_name: object name under module
        :param para_list: the detailed object parameter
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium create_object_with_structure", also_console=True)
        module_str = "ASI-{0}/{1}-{2}".format(asi_id, mod_name, mod_id)
        header_str = "//div[@id='parameters-view-table']//tbody//tr"
        _xpath_mod_selector = "//div[@id='{0}']".format(module_str)
        _xpath_mod_locator = "//span[contains(text(),'{0}-{1}') and contains(@id,'selected')]".format(mod_name, mod_id)
        _xpath_obj_locator = "{0}[@id='{1}']//td//mat-icon[@data-mat-icon-name='addIcon']".format(header_str, obj_name)
        _xpath_obj_add_btn = "{0}//..//..//button".format(_xpath_obj_locator)
        _xpath_item_number = "//span[contains(text(),'Structure')]"
        _xpath_tree_path_locator = "//div[@id='tree-path']"

        try:
            self.wd.find_element(By.XPATH, _xpath_mod_selector).click()
            Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located((By.XPATH, _xpath_mod_locator)))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("can't locate element {0}-{1}".format(mod_name, mod_id), also_console=True)
                return

        time.sleep(3)
        obj_add_btn = self.wd.find_element(By.XPATH, _xpath_obj_add_btn)
        if obj_add_btn:
            btn_attribute = obj_add_btn.get_attribute('disabled')
            if not btn_attribute:
                logger.info("Add button is in enabled status, perform add operation now.", also_console=True)
                obj_add_btn.click()
                time.sleep(self.ui_delay * 3)
                obj_number = len(self.wd.find_elements(By.XPATH, _xpath_item_number))
                for internal_key in para_list[0].keys():
                    detailed_obj_str = '{0}-{1}-{2}'.format(obj_name, obj_number - 1, internal_key)
                    self._set_tree_view_text_value(detailed_obj_str, para_list[0][internal_key])
            else:
                logger.info("Add button is in disabled status, can't perform add operation.", also_console=True)
        # simulate mouse move to trigger update effect
        self.wd.find_element(By.XPATH, _xpath_tree_path_locator).click()

    @switch_to_tab('Parameter editor')
    @catch_exception
    def delete_object_with_structure(self, asi_id, mod_name, mod_id, obj_name, sub_obj_name):
        """
        This method used to delete parameter view level object with data structure.
        :param asi_id: asir identifier
        :param mod_name: module name under asi
        :param mod_id: module identifier under asi
        :param obj_name: object name under module
        :param sub_obj_name: sub object name under object
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium delete_object_with_structure", also_console=True)
        module_str = "ASI-{0}/{1}-{2}".format(asi_id, mod_name, mod_id)
        hdr_str = "//div[@id='parameters-view-table']//tbody//tr"
        _xpath_mod_selector = "//div[@id='{0}']".format(module_str)
        _xpath_mod_locator = "//span[contains(text(),'{0}-{1}') and contains(@id,'selected')]".format(mod_name, mod_id)
        _xpath_obj_locator = "{0}[@id='{1}']//td//mat-icon[contains(@class,'expand-icon')]".format(hdr_str, obj_name)
        _xpath_obj_del_btn = \
            "//span[contains(text(),'{0}')]//..//..//..//..//td//\
            mat-icon[@data-mat-icon-name='removeIcon']//..//..//button".format(sub_obj_name)

        try:
            self.wd.find_element(By.XPATH, _xpath_mod_selector).click()
            Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located((By.XPATH, _xpath_mod_locator)))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("can't locate element {0}-{1}".format(mod_name, mod_id), also_console=True)
                return

        time.sleep(self.ui_delay)
        exp_col_btn = self.wd.find_element(By.XPATH, _xpath_obj_locator)
        if exp_col_btn:
            btn_attribute = exp_col_btn.get_attribute('svgicon')
            if btn_attribute == 'collapse':
                logger.info("expand-icon button is in expand status.", also_console=True)

            else:
                logger.info("expand-icon button is in collapse status, expand it now.", also_console=True)
                exp_col_btn.click()

        Wait(self.wd, self.ui_delay).until(EC.element_to_be_clickable((By.XPATH, _xpath_obj_del_btn)))
        del_obj_btn = self.wd.find_element(By.XPATH, _xpath_obj_del_btn)
        if del_obj_btn:
            del_btn_attribute = del_obj_btn.get_attribute('disabled')
            if not del_btn_attribute:
                logger.info("begin to delete object {0}.".format(sub_obj_name), also_console=True)
                del_obj_btn.click()
                time.sleep(self.ui_delay)
            else:
                logger.info("Delete button is gray, can't perform delete operation.", also_console=True)
                return

    @switch_to_tab('Parameter editor')
    @catch_exception
    def set_revert_parameter_value(self, asi_id, mod_name, mod_id, obj_name, op_type='default'):
        """
        This method used to set parameter view level object value to default or revert set parameter operation.
        :param asi_id: asir identifier
        :param mod_name: module name under asi
        :param mod_id: module identifier under asi
        :param obj_name: object name under module
        :param op_type: operational type, default or revert
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium set_revert_parameter_value-{0}".format(op_type),
                    also_console=True)
        module_str = "ASI-{0}/{1}-{2}".format(asi_id, mod_name, mod_id) \
            if mod_name and mod_id else "ASI-{0}".format(asi_id)
        header_str = "//div[@id='parameters-view-table']//tbody//tr"
        _xpath_mod_selector = "//div[@id='{0}']".format(module_str)
        _xpath_obj_locator = \
            "{0}[contains(@id,'{1}')]//*[contains(@class,'parameterValue')]".format(header_str, obj_name)
        if mod_name and mod_id:
            _xpath_mod_locator = "//span[text()='{0}-{1}' and contains(@id,'selected')]".format(mod_name, mod_id)

        mat_icon_name = 'setToDefault' if op_type == 'default' else 'resetIcon'
        _xpath_set_revert_btn = \
            "{0}[contains(@id,'{1}')]//td//\
            mat-icon[@data-mat-icon-name='{2}']//..//..//button".format(header_str, obj_name, mat_icon_name)

        try:
            self.wd.find_element(By.XPATH, _xpath_mod_selector).click()
            if mod_name and mod_id:
                Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located((By.XPATH, _xpath_mod_locator)))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("can't locate module element {0}-{1}".format(mod_name, mod_id), also_console=True)
                return

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, _xpath_obj_locator)))
        time.sleep(3)
        ori_value = self._get_label_text_value(_xpath_obj_locator)
        set_revert_btn = self.wd.find_element(By.XPATH, _xpath_set_revert_btn)
        if set_revert_btn:
            btn_attribute = set_revert_btn.get_attribute('disabled')
            if not btn_attribute:
                if op_type == 'default':
                    logger.info("set para {0} value from {1} to default.".format(obj_name, ori_value),
                                also_console=True)
                else:
                    logger.info("revert set parameter {0} value operation.".format(obj_name), also_console=True)
                set_revert_btn.click()
                time.sleep(self.ui_delay)
                cur_value = self._get_label_text_value(_xpath_obj_locator)

            else:
                logger.info("set_revert_button is gray, can't perform any operation.", also_console=True)
                return
        return ori_value, cur_value

    @switch_to_tab('Parameter editor')
    @catch_exception
    def search_parameter(self, para_name, timeout=10):
        """
        This method used to search existed and not existed parameter, return item number if found, None otherwise.
        :param para_name: parameter name which you want to search
        :param timeout: waiting timeout seconds for searched result
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium search_parameter", also_console=True)
        _xpath_search_box = "//input[contains(@class,'search-input')]"
        _xpath_search_btn = "//mat-icon[contains(@class,'search-button')]"
        _xpath_search_result_table = "//div[@id='search-results-table']"
        _xpath_empty_list = "//div[@id='search-results-table']//div[contains(@class,'empty-table')]"
        _xpath_not_empty_list = "//div[@id='search-results-table']//tbody//tr"
        _xpath_element_num_locator = "//a[@id='tree-view-tab-search']//div[contains(@class,'elements-number')]"
        # add below enhancement as WA to resolve TimeoutError
        _xpath_error_header = \
            "//div[contains(@class,'error-message-container')]//div[contains(@class,'information-header')]"
        _xpath_error_retry_btn = "//div[contains(@class,'error-message-container')]//button"

        logger.info("begin to search parameter {0}".format(para_name), also_console=True)
        self.wd.find_element(By.XPATH, _xpath_search_box).clear()
        self.wd.find_element(By.XPATH, _xpath_search_box).send_keys(para_name + '\n')
        self.wd.find_element(By.XPATH, _xpath_search_btn).click()
        time.sleep(self.ui_delay * 3)  # wait a while to flush the result

        dt_start = time.time()
        while time.time() < dt_start + timeout:
            try:
                Wait(self.wd, 1).until(EC.visibility_of_element_located((By.XPATH, _xpath_search_result_table)))
                break
            except TimeoutException as ex:
                logger.info("Timeout to search parameter {0} with {1}".format(para_name, ex.msg), also_console=True)

        # WA for search TimeoutError
        try:
            error_message_window = self.wd.find_element(By.XPATH, _xpath_error_header)
            retry_button = self.wd.find_element(By.XPATH, _xpath_error_retry_btn)
            if error_message_window and retry_button:
                error_message = error_message_window.text
                retry_button_content = retry_button.text
                if error_message == 'TimeoutError' and retry_button_content == 'Retry':
                    logger.info("search TimeoutError appear, retry...", also_console=True)
                    time.sleep(self.ui_delay * 5)  # wait a sec otherwise retry button is not ready
                    retry_button.click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("No TimeoutError appear, continue...", also_console=True)

        exp_item_list = self.wd.find_elements(By.XPATH, _xpath_not_empty_list)
        search_result_cnt = int(self.wd.find_element(By.XPATH, _xpath_element_num_locator).text)
        if exp_item_list:
            if len(exp_item_list) == search_result_cnt:
                return search_result_cnt
            else:
                logger.error("mismatched search result for object {0}!".format(para_name))
                return None

        else:
            exp_empty = self.wd.find_element(By.XPATH, _xpath_empty_list)
            if exp_empty and search_result_cnt == 0:
                logger.info("parameter {0} is not exist.".format(para_name), also_console=True)
                return None

    """
    some xpath for specific cell attribute operation
    """
    _xpath_tr_cell_item = "//div[@id='cells-list-content']//tr[contains(@id,'BTS-{0}/CELL-{1}')]"
    _xpath_cell_dtl_head = "//div[@id='cell-details-header']"
    _xpath_tr_lte_cell_locator = _xpath_tr_cell_item + "//td//span[contains(text(),'LTE')]"
    _xpath_hub_checkbox_locator = "//div[@id='hub-antennas-form']//mat-checkbox[contains(@class,'checkbox')]"

    _xpath_hub_tr_locator = "//div[@id='hub-antennas-form']//mat-checkbox[contains(@class,'checkbox')]//..//tr"

    # _xpath_hubmod_locator = "//div[@id='hub-antennas-form']//tr[contains(@id,'HUBMOD-{0}')]//mat-checkbox"
    _xpath_hubmod_locator = "//div[@id='hub-antennas-form']//tr[contains(@id,'{0}')]//mat-checkbox"

    xpath_chbox_checked = "//mat-checkbox[@type='checkbox']//input[@type='checkbox' and @aria-checked='true']"

    @switch_to_tab('Cells')
    @catch_exception
    def enable_disable_lte_nbiot_mode(self, bts_id, cell_id, iot_mode):
        """
        This method used to enable/disable LTE cell NB IoT mode.
        :param bts_id: BTS identifier
        :param cell_id: BTS cell identifier
        :param iot_mode: NB IoT mode value, one of (none, inband, guardband)
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium enable_disable_lte_nbiot_mode", also_console=True)
        _xpath_nbiot_label = "//div[@id='cell-properties']//label[contains(text(),'NB')]//..//mat-select"
        _xpath_nbiot_mat_option = "//mat-option//span[contains(text(),'{0}')]".format(iot_mode)
        _xpath_secondarycell_label = "//div[contains(@class,'secondaryCell')]"

        self.wd.find_element(By.XPATH, self._xpath_tr_cell_item.format(bts_id, cell_id)).click()
        Wait(self.wd, self.ui_delay * 5).until(EC.visibility_of_element_located((By.XPATH, self._xpath_cell_dtl_head)))

        nbiot_label_attr = self.wd.find_element(By.XPATH, _xpath_nbiot_label).get_attribute('class')
        assert ('pulldown' not in nbiot_label_attr
                ), "NB IoT setting mode is in disable status, can't perform any operation."

        assert ("{0}".format(iot_mode) in ['none', 'inband', 'guardband']
                ), "NB IoT mode {0} is not supported!".format(iot_mode)

        cur_mode = self._get_label_text_value(_xpath_nbiot_label)
        assert (cur_mode != iot_mode
                ), "the mode {0} you want to set is equal to current mode!".format(iot_mode)

        self.wd.find_element(By.XPATH, _xpath_nbiot_label).click()
        time.sleep(self.ui_delay)
        self.wd.find_element(By.XPATH, _xpath_nbiot_mat_option).click()
        if iot_mode in ['inband', 'guardband']:
            Wait(self.wd, self.ui_delay * 5).until(
                EC.visibility_of_element_located((By.XPATH, _xpath_secondarycell_label)))
        logger.info("Successfully set NB IoT mode to {0}".format(iot_mode), also_console=True)

    @switch_to_tab('Cells')
    @catch_exception
    def enable_disable_lte_supercell_mode(self, bts_id, cell_id, sc_mode, hub_id):
        """
        This method used to enable/disable LTE super cell mode.
        :param bts_id: BTS identifier
        :param cell_id: BTS cell identifier
        :param hub_id: Hub module identifier, format should be eg. HUBMOD-1/HUBMOD-2
        :param sc_mode: LTE super cell mode, enable/disable
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium enable_disable_lte_supercell_mode", also_console=True)
        checked_hub_list, uncheck_hub_list = [], []
        _xpath_supercell_label = "//div[@id='cell-properties']//label[contains(text(),'Supercell')]//..//span"
        _xpath_enb_dis_locator = "//div[@id='hub-antennas-form']//tr[contains(@id,'{0}')]//mat-checkbox"

        try:
            lte_cell = self.wd.find_element(By.XPATH, self._xpath_tr_lte_cell_locator.format(bts_id, cell_id))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("Selected BTS-{0}/CELL-{1} isn't LTE cell.".format(bts_id, cell_id), also_console=True)
                return

        self.wd.find_element(By.XPATH, self._xpath_tr_cell_item.format(bts_id, cell_id)).click()
        Wait(self.wd, self.ui_delay * 5).until(EC.visibility_of_element_located((By.XPATH, self._xpath_cell_dtl_head)))

        time.sleep(6)
        hub_list = self.wd.find_elements(By.XPATH, self._xpath_hub_checkbox_locator)
        assert (len(hub_list) >= 2
                ), "There is only {0} Hubmod, can't perform enable/disable supercell operation!".format(len(hub_list))

        supercell_label = self._get_label_text_value(_xpath_supercell_label)

        hub = self.wd.find_element(By.XPATH, self._xpath_hubmod_locator.format(hub_id))
        hub_checked = 'checked' in hub.get_attribute('class')
        logger.info("hub_checked: {}".format(hub_checked), also_console=True)
        if supercell_label == 'No' and sc_mode == 'enable' and not hub_checked:

            updated_sc_label = self._get_cell_element_attribute_value(_xpath_enb_dis_locator.format(hub_id),
                                                                      'value',
                                                                      _xpath_supercell_label)
            if updated_sc_label == 'Yes':
                logger.info("Successfully enable BTS-{0}/CELL-{1} supercell."
                            .format(bts_id, cell_id), also_console=True)
            else:
                logger.info("Failed to enable BTS-{0}/CELL-{1} supercell.".format(bts_id, cell_id), also_console=True)

        elif supercell_label == 'Yes' and sc_mode == 'disable' and hub_checked:

            updated_sc_label = self._get_cell_element_attribute_value(_xpath_enb_dis_locator.format(hub_id),
                                                                      'value',
                                                                      _xpath_supercell_label)
            if updated_sc_label == 'No':
                logger.info("Successfully disable BTS-{0}/CELL-{1} supercell."
                            .format(bts_id, cell_id), also_console=True)
            else:
                logger.info("Failed to disable BTS-{0}/CELL-{1} supercell.".format(bts_id, cell_id), also_console=True)

        else:
            logger.info("wrong operation/hub number, current supercell label is {0}, while you choose {1} operation."
                        .format(supercell_label, sc_mode), also_console=True)
            return

    @switch_to_tab('Cells')
    @catch_exception
    def enable_disable_lte_distributed_mimo(self, bts_id, cell_id, dm_mode):
        """
        This method used to enable/disable LTE cell distributed mimo mode.
        :param bts_id: BTS identifier
        :param cell_id: BTS cell identifier
        :param dm_mode: LTE cell distributed mimo mode, enable/disable
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium enable_disable_lte_distributed_mimo", also_console=True)

        _xpath_distributed_mimo_label = \
            "//div[@id='cell-properties']//label[contains(text(),'MIMO')]//..//mat-checkbox"
        _xpath_ant_locator = \
            "//div[@id='hub-antennas-form']//tr[contains(@id,'{0}')]//td//mat-select[contains(@class,'ANTL-1')]"

        try:
            lte_cell = self.wd.find_element(By.XPATH, self._xpath_tr_lte_cell_locator.format(bts_id, cell_id))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("Selected BTS-{0}/CELL-{1} isn't LTE cell.".format(bts_id, cell_id), also_console=True)
                return

        self.wd.find_element(By.XPATH, self._xpath_tr_cell_item.format(bts_id, cell_id)).click()
        Wait(self.wd, self.ui_delay * 5).until(EC.visibility_of_element_located((By.XPATH, self._xpath_cell_dtl_head)))

        time.sleep(3)
        # hub_number = len(self.wd.find_elements(By.XPATH, self._xpath_hub_checkbox_locator))
        # for index in range(1, hub_number + 1):
        #     hub_elem = self.wd.find_element(By.XPATH, self._xpath_hubmod_locator.format(index)).get_attribute('class')
        #     if 'checked' in hub_elem:
        #         checked_hub_list.append("HUBMOD-{0}".format(index))

        hub_checkbox_list = self.wd.find_elements(By.XPATH, self._xpath_hub_checkbox_locator)
        hub_id = None
        for hub_checkbox in hub_checkbox_list:
            if 'checked' in hub_checkbox.get_attribute('class'):
                hub_tr = hub_checkbox.find_element(By.XPATH, "//..//tr")
                hub_id = hub_tr.get_attribute("id").split("/")[-1]
                break

        dis_mimo_label = self.wd.find_element(By.XPATH, _xpath_distributed_mimo_label).get_attribute('class')
        cur_dis_mimo = 'enable' if 'checked' in dis_mimo_label else 'disable'

        if cur_dis_mimo == 'disable' and dm_mode == 'enable' and hub_id is not None:
            hub_ant_label = self._get_cell_element_attribute_value(_xpath_distributed_mimo_label,
                                                                   'attribute',
                                                                   _xpath_ant_locator.format(hub_id))
            ant_mat_select_value = 'pulldown' if 'pulldown' in hub_ant_label else None
            if ant_mat_select_value == 'pulldown':
                logger.info("Successfully enable BTS-{0}/CELL-{1} distributed DL MIMO."
                            .format(bts_id, cell_id), also_console=True)
            else:
                logger.info("Failed to enable BTS-{0}/CELL-{1} distributed DL MIMO."
                            .format(bts_id, cell_id), also_console=True)

        elif cur_dis_mimo == 'enable' and dm_mode == 'disable' and hub_id is not None:
            hub_ant_label = self._get_cell_element_attribute_value(_xpath_distributed_mimo_label,
                                                                   'attribute',
                                                                   _xpath_ant_locator.format(hub_id))
            ant_mat_select_value = 'pulldown' if 'pulldown' in hub_ant_label else None
            if not ant_mat_select_value:
                logger.info("Successfully disable BTS-{0}/CELL-{1} distributed DL MIMO."
                            .format(bts_id, cell_id), also_console=True)
            else:
                logger.info("Failed to disable BTS-{0}/CELL-{1} distributed DL MIMO."
                            .format(bts_id, cell_id), also_console=True)

        else:
            logger.info("wrong operation, current distributed DL MIMO label is {0}, \
                while you choose {1} operation.".format(cur_dis_mimo, dm_mode), also_console=True)
            return

    @switch_to_tab('Cells')
    @catch_exception
    def enable_disable_5g_double_tx_power(self, bts_id, cell_id, tp_mode):
        """
        This method used to enable/disable 5G cell double tx power.
        :param bts_id: BTS identifier
        :param cell_id: BTS cell identifier
        :param tp_mode: double tx power mode, enable/disable
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium enable_disable_5g_double_tx_power", also_console=True)
        _xpath_tr_5g_cell_locator = self._xpath_tr_cell_item + "//td//span[contains(text(),'5G')]"
        _xpath_double_tx_power_label = \
            "//div[@id='cell-properties']//label[contains(text(),'power')]//..//mat-checkbox"
        _xpath_profile_hub_mapping = \
            "//div[@id='cell-details-mapping-content']//tr//td//mat-select[contains(@class,'Antl-1')]//span"

        try:
            nr_cell = self.wd.find_element(By.XPATH, _xpath_tr_5g_cell_locator.format(bts_id, cell_id))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("Selected BTS-{0}/CELL-{1} is not 5G cell.".format(bts_id, cell_id), also_console=True)
                return

        self.wd.find_element(By.XPATH, self._xpath_tr_cell_item.format(bts_id, cell_id)).click()
        Wait(self.wd, self.ui_delay * 5).until(EC.visibility_of_element_located((By.XPATH, self._xpath_cell_dtl_head)))

        time.sleep(5)
        tx_power_label = self.wd.find_element(By.XPATH, _xpath_double_tx_power_label).get_attribute('class')
        cur_tx_power = 'enable' if 'checked' in tx_power_label else 'disable'

        if cur_tx_power == 'disable' and tp_mode == 'enable':
            hub_ant_val = self._get_cell_element_attribute_value(_xpath_double_tx_power_label,
                                                                 'value',
                                                                 _xpath_profile_hub_mapping)
            hub_ant_val_update = 'Yes' if ',' in hub_ant_val else 'No'
            if hub_ant_val_update == 'Yes':
                logger.info("Successfully enable BTS-{0}/CELL-{1} double tx power."
                            .format(bts_id, cell_id), also_console=True)
            else:
                logger.info("Failed to enable BTS-{0}/CELL-{1} double tx power."
                            .format(bts_id, cell_id), also_console=True)

        elif cur_tx_power == 'enable' and tp_mode == 'disable':
            hub_ant_val = self._get_cell_element_attribute_value(_xpath_double_tx_power_label,
                                                                 'value',
                                                                 _xpath_profile_hub_mapping)
            hub_ant_val_update = 'Yes' if ',' in hub_ant_val else 'No'
            if hub_ant_val_update == 'No':
                logger.info("Successfully disable BTS-{0}/CELL-{1} double tx power."
                            .format(bts_id, cell_id), also_console=True)
            else:
                logger.info("Failed to disable BTS-{0}/CELL-{1} double tx power."
                            .format(bts_id, cell_id), also_console=True)

        else:
            logger.info("wrong operation, BTS-{0}/CELL-{1} double tx power is {2}, \
                while you choose {3} operation.".format(bts_id, cell_id, cur_tx_power, tp_mode), also_console=True)
            return

    @switch_to_tab('Cells')
    @catch_exception
    def configure_split_mode_5g_4g_cell(
            self, bts_id1, cell_id1, bts_id2, cell_id2, module_type, chan1, chan2, chan3=None, chan4=None):
        """
        This method used to configure split mode for 5G & 4G cell.
        :param bts_id1: BTS 1 identifier
        :param cell_id1: cell identifier for bts_id1
         :param bts_id2: BTS 2 identifier
        :param cell_id2: cell identifier for bts_id2
        :param chan1: Channel 1 parameter value
        :param chan2: Channel 2 parameter value
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium configure_split_mode_5g_4g_cell", also_console=True)
        xpath_shub_locator = "//mat-checkbox[@type='checkbox' and contains(@class,'{0}')]"

        self.modify_hub_antenna_mapping(bts_id1, cell_id1, chan1=chan1, chan2=chan2, chan3=chan3, chan4=chan4)
        checked_shub = self._get_cell_checked_shub(bts_id1, cell_id1, self.xpath_chbox_checked)
        cell_id1_map = self.get_profile_antenna_mapping_info(bts_id1, cell_id1)
        self.wd.find_element(By.XPATH, self._xpath_tr_cell_item.format(bts_id2, cell_id2)).click()
        time.sleep(self.ui_delay * 2)
        self.wd.find_element(By.XPATH, xpath_shub_locator.format(checked_shub)).click()
        self.modify_hub_antenna_mapping(bts_id2, cell_id2, chan1=chan1, chan2=chan2, chan3=chan3, chan4=chan4)
        self.populate_cell_mapping_info(bts_id2,
                                        cell_id2,
                                        cell_id1_map[0]['profile_id'],
                                        module_type,
                                        cell_id1_map[0]['shub_ant1'],
                                        cell_id1_map[0]['shub_ant2'],
                                        cell_id1_map[0]['shub_ant3'],
                                        cell_id1_map[0]['shub_ant4'])

    @switch_to_tab('Cells')
    @catch_exception
    def modify_hub_antenna_mapping(self, bts_id, cell_id, chan1=None, chan2=None, chan3=None, chan4=None):
        """
        This method used to modify HUB and antenna channel mapping info.
        :param bts_id: BTS identifier
        :param cell_id: cell identifier
        :param chan1: Channel 1 parameter value
        :param chan2: Channel 2 parameter value
        :param chan3: Channel 3 parameter value
        :param chan4: Channel 4 parameter value
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium modify_hub_antenna_mapping", also_console=True)
        _xpath_channel_selector = "{0}//..//..//..//..//..//..//..//..//mat-select[contains(@class,'ANTL-{1}')]"
        _xpath_channel_mat_option_value = "//mat-option//span[contains(text(),'{0}')]"

        self.wd.find_element(By.XPATH, self._xpath_tr_cell_item.format(bts_id, cell_id)).click()
        time.sleep(self.ui_delay * 2)

        for i, chan in enumerate([chan1, chan2, chan3, chan4], 1):
            self.wd.find_element(By.XPATH, _xpath_channel_selector.format(self.xpath_chbox_checked, i)).click()
            time.sleep(self.ui_delay)
            self.wd.find_element(By.XPATH, _xpath_channel_mat_option_value.format(chan)).click()
            time.sleep(self.ui_delay)

    @switch_to_tab('Cells')
    @catch_exception
    def get_profile_antenna_mapping_info(self, bts_id, cell_id):
        """
        This method used to get specific cell detailed profile-antenna mapping info.
        :param bts_id: BTS identifier
        :param cell_id: cell identifier
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium get_profile_antenna_mapping_info", also_console=True)
        xpath_div_cell_mapping = "//div[@id='cell-details-mapping-content']"
        xpath_profile_tr_in_mapping_table = "{0}//tbody//tr[contains(@id,'/ANTMODPR')]".format(xpath_div_cell_mapping)
        xpath_prrh_type_locator = ".//div[contains(@class,'asir-prrh')]//span"
        xpath_module_type_locator = ".//mat-select[contains(@class,'profileBandClass')]"
        xpath_hub_ant_chan = ".//mat-select[contains(@class,'profileHubAntl-{0}')]"

        pro_antenna_map_list = []

        self.wd.find_element(By.XPATH, self._xpath_tr_cell_item.format(bts_id, cell_id)).click()
        time.sleep(3)
        Wait(self.wd, self.ui_delay * 2).until(EC.visibility_of_element_located((By.XPATH, xpath_div_cell_mapping)))

        pro_lst = self.wd.find_elements(By.XPATH, xpath_profile_tr_in_mapping_table)
        for idx in range(len(pro_lst)):
            t_dict = {}
            t_dict['profile_id'] = pro_lst[idx].get_attribute('id').split('/')[1].split('-')[1]
            t_dict['asir_prrh'] = pro_lst[idx].find_element(By.XPATH, xpath_prrh_type_locator).text
            t_dict['module_type'] = pro_lst[idx].find_element(By.XPATH, xpath_module_type_locator).text
            for iter in [1, 2, 3, 4]:
                t_dict['shub_ant{0}'.format(iter)] = \
                    pro_lst[idx].find_element(By.XPATH, xpath_hub_ant_chan.format(iter)).text
            pro_antenna_map_list.append(t_dict)

        return pro_antenna_map_list

    @switch_to_tab('Cells')
    @catch_exception
    def rf_sub_module_preselection(self, bts_id, cell_id1, cell_id2):
        """
        This method used to modify two cells HUB mapping info.
        NOTE : currently only support one cell mapped one hub config.
        :param bts_id: BTS identifier
        :param cell_id1: cell 1 identifier
        :param cell_id2: cell 2 identifier
        """
        logger.info("DevNJ_OfflineMode_ASIR_Selenium rf_sub_module_preselection", also_console=True)
        xpath_cell_list_locator = "//div[@id='cells-list-content']//tr[contains(@id,'/BTS-{0}/CELL-')]".format(bts_id)

        cell_num = len(self.wd.find_elements(By.XPATH, xpath_cell_list_locator))
        assert (cell_num >= 2
                ), "{0} cell number is less than 2, can't perform swap operation".format(bts_id)

        # save necessary information for swap operation
        cell_id1_shub = self._get_cell_checked_shub(bts_id, cell_id1, self.xpath_chbox_checked)
        cell_id1_map = self.get_profile_antenna_mapping_info(bts_id, cell_id1)

        cell_id2_shub = self._get_cell_checked_shub(bts_id, cell_id2, self.xpath_chbox_checked)
        cell_id2_map = self.get_profile_antenna_mapping_info(bts_id, cell_id2)

        # cell_id1 swap operation
        self._swap_hub_antenna_profile_info(bts_id=bts_id,
                                            cell_id=cell_id1,
                                            chbox_xpath=self.xpath_chbox_checked,
                                            hub_id=cell_id2_shub,
                                            cell_map_info=cell_id2_map)

        # cell_id2 swap operation
        self._swap_hub_antenna_profile_info(bts_id=bts_id,
                                            cell_id=cell_id2,
                                            chbox_xpath=self.xpath_chbox_checked,
                                            hub_id=cell_id1_shub,
                                            cell_map_info=cell_id1_map)

    @catch_exception
    def load_snapshot(self, snapshot_path, sub_menu='Load AirScale Snapshot', timeout=60, return_time_cost={}):
        """
        This keyword used to load snapshot with offline mode asir webem
        :param snapshot_path: fullpath of snapshot file
        :param sub_menu: one of the button name, currently only have 'Load AirScale Snapshot'
        :param timeout: Maximum seconds for waiting for load snapshot
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None
        Examples:
        | load_snapshot |
        | ${time_cost}  | Create Dictionary |
        | load_snapshot | snapshot_path='/home/ute/pkgload/xxx.zip' | return_time_cost=time_cost |
        """

        logger.info("DevNJ_OfflineMode_ASIR_Selenium load_snapshot", also_console=True)
        timeout = int(timeout)
        dict_sub_menu_to_button_id = {
            'load airscale snapshot': 'load-airscale-snapshot-button'
        }

        start_button_id = dict_sub_menu_to_button_id.get(sub_menu.lower())
        assert (start_button_id is not None), "Failed to find button of {}".format(sub_menu)

        _xpath_man_snapshot = "//*[@href='#/snapshot']"
        _xpath_stepper_load_asirscale_snapshot = "//div[@class='ot-panel-header simple-header']//" \
                                                 "span[contains(text(), 'Load AirScale Snapshot')]"
        _xpath_man_snapshot_start_button = "//button[@id='{}']".format(start_button_id)
        _xpath_man_snapshot_reload = "//div[@class='modal-panel']//button[contains(text(), 'Reload')]"
        _xpath_man_snapshot_file_input = "//app-load-snapshot//input[@id='fileInputId']"
        _xpath_snapshot_successfully_loaded = "//div[@id='snapshot-status-content']//span[contains(text(), " \
                                              "'Snapshot has been')]"

        wait = Wait(self.wd, self.ui_delay * 5)
        try:
            wait.until(EC.element_to_be_clickable((By.XPATH, _xpath_man_snapshot))).click()
            time.sleep(self.ui_delay)
            wait.until(EC.visibility_of_element_located((By.XPATH, _xpath_stepper_load_asirscale_snapshot))).click()
        except Exception as e:
            logger.info("Snapshot button is unclickable in {} s, try again".format(self.ui_delay * 5))
            wait.until(EC.element_to_be_clickable((By.XPATH, _xpath_man_snapshot))).click()
            time.sleep(self.ui_delay)
            wait.until(EC.visibility_of_element_located((By.XPATH, _xpath_stepper_load_asirscale_snapshot))).click()

        wait.until(EC.element_to_be_clickable((By.XPATH, _xpath_man_snapshot_start_button)))
        time.sleep(self.ui_delay)

        js = "arguments[0].removeAttribute(\"hidden\");"
        input_file = self.wd.find_element(By.XPATH, _xpath_man_snapshot_file_input)
        self.wd.execute_script(js, input_file)
        input_file.send_keys(snapshot_path)

        dt_start = time.time()

        while time.time() < dt_start + timeout:
            try:
                load_status = self.wd.find_element(By.XPATH, _xpath_snapshot_successfully_loaded)
                logger.info("{}".format(load_status.get_attribute('textContent')), also_console=True)
                if 'successfully' in load_status.get_attribute('textContent'):
                    return_time_cost['time_cost'] = round(time.time() - dt_start, 3)
                    break
            except Exception as e:
                pass
        else:
            assert False, "Snapshot {} load failed after {}s".format(snapshot_path, timeout)

    @catch_exception
    def check_diagnostic_information(self):
        """
        This keyword used to check diagnostic information after load snapshot

        """

        current_elem_category = None
        dict_diagnostic_info = {}

        _xpath_diagnostic_infor_content = "//as-split-area//div[@id='diagnostic-information-content']/div"
        diagnostic_table_list = self.wd.find_elements(By.XPATH, _xpath_diagnostic_infor_content)

        time.sleep(self.ui_delay*5)

        if diagnostic_table_list:
            logger.info("Diagnostic information category: {}".format(len(diagnostic_table_list)), also_console=True)
            for diag_info in diagnostic_table_list:
                all_elems = diag_info.find_elements(By.XPATH, "./div")
                for elem in all_elems:
                    elem_class = elem.get_attribute('class')
                    if 'section-header' in elem_class:
                        current_elem_category = re.search(
                            r'((\w+\s?)+)', elem.get_attribute('textContent').lower(), re.I | re.M).group()
                        if current_elem_category and current_elem_category not in dict_diagnostic_info:
                            dict_diagnostic_info[current_elem_category] = {}
                    else:
                        _xpath_mat_icon = ".//mat-icon"
                        _xpath_des = ".//div[contains(@class, 'flex-description')]"

                        current_elem_des = elem.find_element(By.XPATH, _xpath_des).get_attribute('textContent').strip()
                        current_elem_icon = elem.find_element(By.XPATH, _xpath_mat_icon). \
                            get_attribute('data-mat-icon-name').strip()
                        current_elem_name = elem.find_element(By.XPATH, _xpath_mat_icon + '{}'.format('/../..')). \
                            get_attribute('textContent').strip()

                        dict_elem_status = {'icon': current_elem_icon, 'details': current_elem_des}

                        if current_elem_name and current_elem_name not in dict_diagnostic_info[current_elem_category]:
                            dict_diagnostic_info[current_elem_category][current_elem_name] = dict_elem_status

        logger.info("Diagnostic information: {}".format(dict_diagnostic_info), also_console=True)
        pprint(dict_diagnostic_info)

        dict_err = {}
        for elem_category_key, elem_category_value in dict_diagnostic_info.items():
            for elem_name_key, elem_name_value in elem_category_value.items():
                if 'cross' in elem_name_value['icon'].lower():
                    dict_err[elem_category_key] = {}
                    dict_err[elem_category_key][elem_name_key] = \
                        {'icon': elem_name_value['icon'], 'details': elem_name_value['details']}

        assert (not bool(dict_err)), "Some elements in snapshot load failed: {}".format(dict_err)

    @catch_exception
    def check_alarm_relations(self, fault_index_list=[]):
        """
        This keyword used to check alarm relateions between alarm in fault table and
        device properties/Fault details in topology view
        :param fault_index_list: alarm index in alarm table, range 0-x

        """

        _xpath_header_active_fault = "//as-split-area//a[@id='faults-tab-active']"
        _xpath_fault_rows = "//as-split-area//div[@id='faults-table']//table/tbody/tr"
        _xpath_fault_click = "{}[{}]"
        _xpath_device_propeities = "//as-split-area[@id='topologyDetailsArea']" \
                                   "//mat-expansion-panel[contains(@id, 'collapsible-group-0')]/div//div/div"
        _xpath_fault_details = "//as-split-area[@id='faultDetailsArea']//" \
                               "div[contains(@class, 'mat-expansion-panel-body')]/div"
        dict_click_fault = {}
        dict_click_device_properties = {}
        dict_click_fault_details = {}
        wait = Wait(self.wd, 10)
        self.wd.find_element(By.XPATH, _xpath_header_active_fault).click()
        fault_rows = self.wd.find_elements(By.XPATH, _xpath_fault_rows)
        if fault_index_list:
            click_fault_index = fault_index_list if isinstance(fault_index_list, list)\
                else str(fault_index_list).split()
        else:
            try:
                click_fault_index = numpy.random.randint(0, len(fault_rows), 5)
            except Exception as e:
                click_fault_index = ['0']

        for fault_index in set(click_fault_index):
            try:
                tr = self.wd.find_element(By.XPATH, _xpath_fault_click.format(_xpath_fault_rows, int(fault_index) + 1))
                tr.click()
            except Exception as ex:
                if "no such element:" in ex.msg:
                    logger.info("No Alarms", also_console=True)
                    break
            fault_details = [td.get_attribute('textContent').strip().lower() for td in
                             tr.find_elements(By.XPATH, './td')]
            dict_click_fault[int(fault_index)] = fault_details

            device_details_list = wait.until(
                EC.visibility_of_all_elements_located((By.XPATH, _xpath_device_propeities)))
            device_details_info_list = [device_details.get_attribute('textContent').replace(' ', '').lower()
                                        for device_details in device_details_list]
            dict_click_device_properties[int(fault_index)] = dict([device_details_info.
                                                                  lower().split(':')
                                                                  for device_details_info in device_details_info_list])

            fault_details_list = wait.until(EC.visibility_of_all_elements_located((By.XPATH, _xpath_fault_details)))
            fault_details_info_list = [fault_details.get_attribute('textContent').replace(' ', '').lower()
                                       for fault_details in fault_details_list]

            dict_click_fault_details[int(fault_index)] = dict([fault_details_info.lower().split(':', 1)
                                                               for fault_details_info in fault_details_info_list])

        logger.info("Display all faults in fault table: {}".format(dict_click_fault), also_console=True)
        logger.info("Diasplay all device properties: {}".format(dict_click_device_properties), also_console=True)
        logger.info("Display all fault details: {}".format(dict_click_fault_details), also_console=True)

        dict_fault_compare = {}
        for k_fault, v_fault in dict_click_fault.items():
            paired_no_flag = False
            if 'pairedmanagedobject' not in dict_click_device_properties[k_fault]:
                paired_no_flag = True
            if paired_no_flag:
                flag = dict_click_device_properties[k_fault]['runtimemanagedobject'] != v_fault[3]
            else:
                flag = dict_click_device_properties[k_fault]['runtimemanagedobject'] != v_fault[3] and \
                    dict_click_device_properties[k_fault]['pairedmanagedobject'] != v_fault[3]

            if flag or dict_click_fault_details[k_fault]['faultid'] not in v_fault[2]:
                dict_fault_compare[k_fault] = {}
                dict_fault_compare[k_fault]['fault table'] = v_fault
                dict_fault_compare[k_fault]['device properties'] = \
                    dict_click_device_properties[k_fault]['runtimemanagedobject']
                dict_fault_compare[k_fault]['fault details'] = dict_click_fault_details[k_fault]['faultid']

        assert not bool(dict_fault_compare), "Check alarm relations failed {}".format(dict_fault_compare)

    @catch_exception
    @switch_to_tab('Save')
    def save_scf_in_tab(self, download_dir='/home/ute/Downloads', timeout=30):
        """
        Main Function:
            Save scf in tab: switch to tab *Save*, click 'save' button on tab *Save*

        Arguments:
            :param download_dir: scf save directory
            :param timeout: timeout after click save button

        Return Value:
            :return list_scf_after_download[-1]: saved scf path

        Examples:
            Example 1:
            | Save Scf In Tab | download_dir=/home/ute/Downloads |
            | ...  timeout=30 |
            Example 2:
            | Save Scf In Tab |

        Version:
            | Author | Version | Delivery Date | Comments |
            | Li Huafeng| 1.0.0 | 2022/01/11 | First approved version by VA |
        """

        list_scf_before_download = []
        for f in os.listdir(download_dir):
            f_path = os.path.join(download_dir, f)
            if not os.path.isdir(f_path) and os.path.splitext(f)[-1].lower() == '.xml':
                list_scf_before_download.append(f_path)
        xpath_saveoffline_btn = "//button[@id='save-configuration-save-button']"
        time.sleep(2)
        self.wd.find_element(By.XPATH, xpath_saveoffline_btn).click()
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            time.sleep(1)
            list_scf_after_download = []
            for f in os.listdir(download_dir):
                f_path = os.path.join(download_dir, f)
                if not os.path.isdir(f_path) and f_path not in list_scf_before_download \
                        and os.path.splitext(f)[-1].lower() == '.xml':
                    list_scf_after_download.append(f_path)
            if list_scf_after_download:
                return list_scf_after_download[-1]
        assert False, 'Failed to save backup scf'

    @switch_to_tab('Save')
    @catch_exception
    def prevalidate_in_tab(self, timeout=10):
        """
        Main Function:
            Prevalidate in *Save* tab: switch to tab *Save*, click 'prevalidate' button on tab *Save*

        Arguments:
            :param timeout: timeout after click prevalidate button

        Return Value:
            :return None

        Examples:
            Example 1:
            | Prevalidate In Tab | timeout=30 |
            Example 2:
            | Prevalidate In Tab |

        Version:
            | Author | Version | Delivery Date | Comments |
            | Li Huafeng| 1.0.0 | 2022/01/11 | First approved version by VA |
        """

        timeout = int(timeout)
        dict_ret = {}
        xpath_with_errors = "//div[@id='toast-container']//div[contains(text(),'Configuration invalid')]"
        xpath_prevalidate_btn = "//button[@id='save-configuration-validate-button']"
        self.wd.find_element(By.XPATH, xpath_prevalidate_btn).click()
        wait = Wait(self.wd, timeout)
        xpath_toast_btn = "//div[@id='toast-container']//div[contains(text(),'Configuration valid')]"
        try:
            prevalidate_btn = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_toast_btn)))
        except TimeoutException:
            prevalidate_btn = None
        if prevalidate_btn:
            dict_ret['ret'] = True
            return dict_ret
        dict_ret['ret'] = False
        error_navs = self.wd.find_elements(By.XPATH, xpath_with_errors)
        if error_navs:
            logger.info("Configuration invalid", also_console=True)
            return dict_ret
        else:
            logger.info("Failed to pick errors", also_console=True)
            return dict_ret

    def get_software_version(self):
        """
        This keyword used to get software version in navigation bar

        """
        return self._get_site_information().get('SW')

    def get_site_status(self, online_mode=True):
        """
        This keyword used to get site onair status in navigation bar

        """
        if online_mode:
            return self._get_site_information(online_mode=True).get('Onlinestatus')
        else:
            return self._get_site_information(online_mode=False).get('Offlinemode')

    @catch_exception
    def _get_site_information(self, online_mode=False):
        _xpath_site_info = "//div[@id='header']//div[contains(@class, 'site-info-bar')]/div"

        wait = Wait(self.wd, 10)
        site_info_list = wait.until(EC.visibility_of_all_elements_located((By.XPATH, _xpath_site_info)))
        list_site_info_detail = [site_info.get_attribute('textContent').replace(' ', '').replace(',', ':')
                                 for site_info in site_info_list]
        logger.info("site info = {}".format(list_site_info_detail), also_console=True)

        if online_mode:
            list_online_info = [site_info
                                for site_info in filter(lambda x: '\n' not in x, list_site_info_detail)]
            list_online_info[0] = "Onlinestatus:" + list_online_info[0]
            dict_site_info_detail = dict([site_info.split(':')
                                          for site_info in list_online_info])
            return dict_site_info_detail
        else:
            dict_site_info_detail = dict([site_info.split(':', 1)
                                          for site_info in filter(lambda x: x, list_site_info_detail)])
            logger.info("site info = {}".format(dict_site_info_detail), also_console=True)
            return dict_site_info_detail

    def _set_shub_asir_relation(self, element, xpath_locator):
        """
        Internal usage
        """
        self.wd.find_element(By.XPATH, element).click()
        time.sleep(2)
        self.wd.find_element(By.XPATH, xpath_locator).click()
        time.sleep(2)

    def _get_cell_checked_shub(self, bts_id, cell_id, chbox_xpath):
        """
        Internal usage for getting one specific cell mapped HUB info
        """
        xpath_shub_locator = "{0}//..//..//..//..//mat-checkbox"

        self.wd.find_element(By.XPATH, self._xpath_tr_cell_item.format(bts_id, cell_id)).click()
        time.sleep(self.ui_delay)
        hub_info = self.wd.find_element(By.XPATH, xpath_shub_locator.format(chbox_xpath)).get_attribute('class')
        checked_shub = "HUBMOD-{0}".format(hub_info.split(' ')[2].split('/')[1].split('-')[1])
        return checked_shub

    def _set_tree_view_text_value(self, para, value):
        """
        Internal method for tree view text value setting operation, which both textarea and input tag are supported.
        """
        common_str = "//div[@id='parameters-view-table']"
        _xpath_obj_para_label = \
            "{0}//tbody//tr[@id='{1}']//td//*[contains(@class,'parameterValue')]".format(common_str, para)

        logger.info("begin to set parameter {0} value.".format(para), also_console=True)
        self.wd.find_element(By.XPATH, _xpath_obj_para_label).click()
        time.sleep(2)
        Wait(self.wd, self.ui_delay * 3).until(EC.element_to_be_clickable((By.XPATH, _xpath_obj_para_label)))
        self.wd.find_element(By.XPATH, _xpath_obj_para_label).send_keys(value)

    def _check_obj_tooltip_exist(self, com_part, obj_para):
        """
        Internal method used to check whether the object tooltip appear or not.
        """
        _xpath_object_modify_icon = \
            "{0}tr[contains(@id,'{1}')]//td//input[contains(@class,'para')]//..//mat-icon".format(com_part, obj_para)

        try:
            obj_tooltip_icon = self.wd.find_element(By.XPATH, _xpath_object_modify_icon)
            if obj_tooltip_icon:
                icon_value = obj_tooltip_icon.get_attribute('aria-hidden')
                return 'True' if icon_value == 'false' else 'False'

        except Exception as ex:
            if "no such element:" in ex.msg:
                return 'False'

    def _get_label_text_value(self, xpath_label):
        """
        Internal method to get some element text value.
        """
        combobox = self.wd.find_element(By.XPATH, xpath_label)
        if combobox:
            return combobox.text
        else:
            logger.info("Can't find {0} related object item.".format(xpath_label), aslo_console=True)
            return None

    def _get_cell_element_attribute_value(self, xpath_loctor1, op_flag, xpath_locator2):
        """
        Internal method used to get cell specific web element class attribute or text value for further check.
        :param op_flag: used to identify to get/check text value or class attribute, value or attribute
        """
        self.wd.find_element(By.XPATH, xpath_loctor1).click()
        time.sleep(self.ui_delay * 2)
        if op_flag == 'value':
            return self._get_label_text_value(xpath_locator2)
        else:
            return self.wd.find_element(By.XPATH, xpath_locator2).get_attribute('class')

    def _swap_hub_antenna_profile_info(self, bts_id, cell_id, chbox_xpath, hub_id, cell_map_info):
        """
        Internal usage for rf HUB module preselection
        """
        xpath_shub_locator = "{0}//..//..//..//..//mat-checkbox"
        xpath_swap_locator = "//mat-checkbox[@type='checkbox' and contains(@class,'{0}')]"

        time.sleep(self.ui_delay)
        self.wd.find_element(By.XPATH, self._xpath_tr_cell_item.format(bts_id, cell_id)).click()
        time.sleep(self.ui_delay * 3)
        self.wd.find_element(By.XPATH, xpath_shub_locator.format(chbox_xpath)).click()
        time.sleep(self.ui_delay)
        self.wd.find_element(By.XPATH, xpath_swap_locator.format(hub_id)).click()
        time.sleep(self.ui_delay)
        self.populate_cell_mapping_info(bts_id=bts_id,
                                        cell_id=cell_id,
                                        profile_id=cell_map_info[0]['profile_id'],
                                        band_class=cell_map_info[0]['module_type'],
                                        antl1=cell_map_info[0]['shub_ant1'],
                                        antl2=cell_map_info[0]['shub_ant2'],
                                        antl3=cell_map_info[0]['shub_ant3'],
                                        antl4=cell_map_info[0]['shub_ant4'])


if __name__ == '__main__':
    time_cost = {}

    off_line = DevNJ_OfflineMode_ASIR_Selenium(debug=True)
    off_line.clean_browser()
    off_line.login(url='file:///home/ute/pkgload/index.html', online_mode=False)
    off_line.load_snapshot(snapshot_path='/home/ute/pkgload/Snapshot_MRBTS-16_5GC001311'
                                         '-ASI16_SBTS22R1_ENB_9999_210819_000010_20210908-0442-2.zip',
                           return_time_cost=time_cost)
    pprint("time_cost={}".format(time_cost))
    off_line.check_diagnostic_information()
    off_line.enter_topology_view()
    off_line.check_alarm_relations()
    off_line.enter_topology_view()
    print(off_line.get_software_version())
    print(off_line.get_site_status())
    off_line.enter_config_man(sub_menu="view_offline")
    off_line.check_time_needed_to_expand_ASI_object_in_view_configuration(
        expected_node_names=['PM-1', 'SECPRM-1', 'PMCADM-1'])
    off_line.check_time_needed_to_expand_ANTMOD_object_in_view_configuration(ant_mod_id='1',
                                                                             expected_expanded_items=['ANTRFSM-1'])

    off_line.check_time_needed_to_expand_ASI_object_in_view_configuration(
        expected_node_names=['HUBMOD_R-1'], running=True)
    off_line.check_time_needed_to_expand_ANTMOD_object_in_view_configuration(ant_mod_id='1',
                                                                             expected_expanded_items=['ANTRFSM_R-1'],
                                                                             running=True)
    off_line.logout(online_mode=False)
