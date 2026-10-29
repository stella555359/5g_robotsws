import os
import logging
import time
from taf.internal.gnb.oam.rap.client.rap.v2.rest import ApiException
from taf.internal.gnb.oam.rap.client.rap.v2 import ApiClient, Configuration, AUTHApi, PNPApi


class DevNJ_ASIR_PnP_Rest_Keywords(object):
    """
    Used to manipulate WEBEM for ASIR Plug and Play.
    please ensure taf.internal.gnb.oam.rap.client version is equal or above version : 0.32.0
    Below four requested keywords will be implemented and delivered to feature team, while others for internal usage.
    get_asir_pnp_status
    get_asir_autoconnection_parameters
    set_asir_autoconnection_parameters
    get_asir_pnp_report
    """
    def __init__(self):
        self.configuration = Configuration()
        self.configuration.host = 'https://192.168.255.129:3601/api/v1'
        self.configuration.username = 'Nemuadmin'
        self.configuration.password = 'nemuuser'
        self.configuration.verify_ssl = False
        self.configuration.debug = True
        self.autologout_timer = 'restart'

        self.auth_api_instance = AUTHApi(ApiClient(self.configuration))
        self.pnp_api_instance = PNPApi(ApiClient(self.configuration))

    def request_token(self):
        try:
            auth_api_response = self.auth_api_instance.auth_token_post(grant_type='password',
                                                                       username=self.configuration.username,
                                                                       password=self.configuration.password,
                                                                       scope='write').to_dict()
            self.configuration.access_token = auth_api_response['access_token']
            logging.info("Access Token : {0}".format(self.configuration.access_token))
        except ApiException as ex:
            raise ApiException("Exception when calling AUTHApi->auth_token_post : {0}".format(ex))

    def revoke_access(self, token_type_hint="access_token"):
        try:
            self.auth_api_instance.auth_revoke_post(self.configuration.access_token, token_type_hint=token_type_hint)
        except ApiException as ex:
            raise ApiException("Exception when calling AUTHApi->auth_revoke_post : {0}".format(ex))

    def get_number_of_logged_users(self, count=0):
        api_response = self.auth_api_instance.auth_users_get(x_nokia_autologout_timer=self.autologout_timer,
                                                             count=count)
        return api_response['numberOfUsers']

    def get_asir_pnp_status(self, pnp_status_type='All'):
        """
        Used to get ASIR PnP Auto_connection and Auto_configuration status
        :param pnp_status_type: Conn for auto_connection status, Conf for auto_configuration, by default All for both
        :return Status for ASIR PnP
        """
        try:
            api_response = self.pnp_api_instance.pnp_state_get(x_nokia_autologout_timer=self.autologout_timer)
            if api_response and pnp_status_type == 'Conn':
                return api_response.to_dict()['autoconnection']
            elif api_response and pnp_status_type == 'Conf':
                return api_response.to_dict()['autoconfiguration']
            else:
                return api_response

        except ApiException as ex:
            print("Exception when calling PNPApi->pnp_state_get : {0}".format(ex))

    def get_asir_autoconnection_parameters(self):
        """
        Used to get ASIR PnP autoconnection parameters, normally service ip and site id are included.
        :return  configuration of autoconnection with list type
        """
        retrieve_list = []
        try:
            api_response = self.pnp_api_instance.pnp_config_get(x_nokia_autologout_timer=self.autologout_timer)
            if api_response:
                logging.info("try to get auto_connection parameters.")
                for item in api_response:
                    tmp_dict = {}
                    if item.to_dict()['name'] != 'autoConfBlocked':
                        tmp_dict[item.to_dict()['name']] = item.to_dict()['value']
                        retrieve_list.append(tmp_dict)
            else:
                logging.error("Error to get auto_connection parameters when calling PNPApi->pnp_config_get")

        except ApiException as ex:
            print("Exception when calling PNPApi->pnp_config_get : {0}".format(ex))

        return retrieve_list

    def _get_value_from_lst(self, search_str, input_list):
        """
        Search specific string within the input list
        :param search_str:  string you want to search
        :param input_list:  input list for search
        :return  value of the search string key
        """
        for item in input_list:
            for sub_item in item.keys():
                if sub_item == search_str:
                    return item.get(sub_item)
        return None

    def set_asir_autoconnection_parameters(self, pnp_service_ip=None, ac_site_id=None):
        """
        Used to set ASIR PnP autoconnection parameters such as pnp_service_ip or autoconnection_site_id
        Note : this keyword must be performed under ASIR PnP scenario, otherwise will fail
        :param pnp_service_ip: ASIR pnp service ip to be set
        :param ac_site_id: ASIR pnp autoconnection site id to be set
        :return
        """
        flag = ''
        t_list, parameters_to_be_set = [], []
        if pnp_service_ip and ac_site_id:
            flag = 'both'
            api_parameter_1 = {
                'operation': 'update',
                'name': 'ipAddress',
                'value': pnp_service_ip
            }
            api_parameter_2 = {
                'operation': 'update',
                'name': 'autoConfSiteId',
                'value': ac_site_id
            }
            for item in [api_parameter_1, api_parameter_2]:
                parameters_to_be_set.append(item)
        elif pnp_service_ip:
            flag = 'ip'
            api_parameter = {
                'operation': 'update',
                'name': 'ipAddress',
                'value': pnp_service_ip
            }
            parameters_to_be_set.append(api_parameter)
        else:
            flag = 'id'
            api_parameter = {
                'operation': 'update',
                'name': 'autoConfSiteId',
                'value': ac_site_id
            }
            parameters_to_be_set.append(api_parameter)

        if parameters_to_be_set:
            logging.info("The auto_connection parameters to be set are : {0}".format(parameters_to_be_set))
            try:
                self.pnp_api_instance.pnp_config_patch(x_nokia_autologout_timer=self.autologout_timer,
                                                       pnp_single_config=parameters_to_be_set)
            except ApiException as ex:
                print("Exception when calling PNPApi->pnp_config_patch : {0}".format(ex))

            time.sleep(2)
            t_list = self.get_asir_autoconnection_parameters()
            logging.info("After SET(auto_connection) operation : {0}".format(t_list))
            if flag == 'both':
                ip_addr = self._get_value_from_lst('ipAddress', t_list)
                autocon_site_id = self._get_value_from_lst('autoConfSiteId', t_list)
                return 'Success' if ip_addr == pnp_service_ip and autocon_site_id == ac_site_id else 'Failure'

            elif flag == 'ip':
                return 'Success' if self._get_value_from_lst('ipAddress', t_list) == pnp_service_ip else 'Failure'

            else:
                return 'Success' if self._get_value_from_lst('autoConfSiteId', t_list) == ac_site_id else 'Failure'

        else:
            logging.error("The autoc_onnection parameters to be set are empty.")
            return 'Failure'

    def get_asir_pnp_report(self, path_to_store_file):
        """
        Used to do ASIR PnP report content collection
        :param path_to_store_file: path to save ASIR PnP report file
        :return ASIR PnP report file path
        """
        report_file_location = ''
        try:
            api_response = self.pnp_api_instance.pnp_state_report_post(x_nokia_autologout_timer=self.autologout_timer)
            logging.info("pnp_state_report_post return result is : {0}".format(api_response))
            if api_response:
                jobid = api_response.to_dict()["job_id"]
                report_file_name = api_response.to_dict()["file_name"]

                try:
                    report_api_response = self.pnp_api_instance.pnp_state_report_job_id_get(
                                                      jobid,
                                                      x_nokia_autologout_timer=self.autologout_timer)
                    report_file_location = report_api_response.to_dict()["location"]
                    if not report_file_location:
                        time.sleep(5)
                        report_api_response = self.pnp_api_instance.pnp_state_report_job_id_get(
                                                                jobid,
                                                                x_nokia_autologout_timer=self.autologout_timer)
                        report_file_location = report_api_response.to_dict()["location"]

                    logging.info("pnp_state_report_job_id_get return result is : {0}".format(report_api_response))

                except ApiException as ex:
                    print("Exception when calling PNPApi->pnp_state_report_job_id_get : {0}".format(ex))

                try:
                    report_file_api_response = self.pnp_api_instance.pnp_state_report_job_id_result_get(
                                                                   jobid,
                                                                   report_file_name,
                                                                   x_nokia_autologout_timer=self.autologout_timer)
                    if report_file_api_response:
                        with open(os.path.join(path_to_store_file, report_file_name), 'w') as FH:
                            FH.write(report_file_api_response)
                except ApiException as ex:
                    print("Exception when calling PNPApi->pnp_state_report_job_id_result_get : {0}".format(ex))

                try:
                    self.pnp_api_instance.pnp_state_report_job_id_delete(
                                                                jobid,
                                                                x_nokia_autologout_timer=self.autologout_timer)
                except ApiException as ex:
                    print("Exception when calling PNPApi->pnp_state_report_job_id_delete : {0}".format(ex))

        except ApiException as ex:
            print("Exception when calling PNPApi->pnp_state_report_post : {0}".format(ex))

        return os.path.join(path_to_store_file, report_file_name)

    def set_asir_pnp_auto_config_blocked_status(self, auto_conf_blocked='false'):
        """
        Used to set ASIR PnP Auto_configuration status
        :param auto_conf_blocked: autoconf is blocked or unblock, by default unblock
        """
        tmp_list = []
        api_parameter = {
            'operation': 'update',
            'name': 'autoConfBlocked',
            'value': auto_conf_blocked
        }
        tmp_list.append(api_parameter)

        try:
            api_response = self.pnp_api_instance.pnp_config_patch(x_nokia_autologout_timer=self.autologout_timer,
                                                                  pnp_single_config=tmp_list)
            print(api_response)

        except ApiException as ex:
            print("Exception when calling PNPApi->pnp_config_patch : {0}".format(ex))

    def clear_and_restart_asir_pnp_autoconn(self):
        """
        Used to clear and restart auto connection of ASiR PnP process
        """
        api_parameter = {
            'operation': 'restart'
        }

        try:
            api_response = self.pnp_api_instance.pnp_state_post(x_nokia_autologout_timer=self.autologout_timer,
                                                                pnp_state_request_body=api_parameter)
            print(api_response)

        except ApiException as ex:
            print("Exception when calling PNPApi->pnp_state_post : {0}".format(ex))
