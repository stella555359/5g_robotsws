import logging
import requests
import uuid

from taf.nms.nom import nom
from robot.api import logger
from time import sleep, time
from nokia_nom_open_api_client.exceptions import ApiException
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)


class DevNJ_NOM(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        """
        Init function
        """
        self.ROBOT_LIBRARY_LISTENER = self

        self.nom = nom()
        self._nom_device_name = 'NOM'
        self._client_id = str(self._generate_unique_client_id())
        self._already_connected = False

    def get_self(self):
        """
        keyword get_self
        This is a helper for robotframework to get the instance, then can pass into other keywords as a parameter
        :return: self

        Examples:
        | ${nom_sel} | get_self |
        | nom_operation | ${nom_sel} |
        """
        return self

    def connect(self, rest_credentials, mgmt_credentials):
        """
        Connect to the NOM before login.

        :param rest_credentials: dict, including api gw host, username, password, port
        :param mgmt_credentials: dict, including user mgmt host, username, password, port

        This has to be run before login or trying to disconnect.
        """
        if self._already_connected:
            return

        nom_rf_secret = self.nom.register_the_client(client_id=self._client_id,
                                                     username=rest_credentials['username'],
                                                     password=rest_credentials['password'],
                                                     apigw_uri=rest_credentials['host'])

        logging.debug("Connection is register with ID: {}".format(self._client_id))

        self.nom.connect_to(user_mgmt_uri=mgmt_credentials['host'],
                            apigw_uri=rest_credentials['host'],
                            client_id=self._client_id,
                            client_secret=nom_rf_secret,
                            port=rest_credentials['port'],
                            username=rest_credentials['username'],
                            password=rest_credentials['password'],
                            nom_version='nom_v1',
                            secure=True)

        self._already_connected = True

    def disconnect(self, rest_credentials):
        """
        Close connection to the NOM.

        :param rest_credentials: dict, including api gw host, username, password, port
        """
        if not self._already_connected:
            return
        logging.debug("Delete connection to NOM for ID: {}".format(self._client_id))
        status = self.nom.delete_the_client(client_id=self._client_id,
                                            username=rest_credentials['username'],
                                            password=rest_credentials['password'],
                                            apigw_uri=rest_credentials['host'])
        assert (status == "Deleted Successfully"), "Disconnect failed: {}".format(status)
        self._already_connected = False

    @staticmethod
    def _generate_unique_client_id():
        """
         Get the unique _client_id which is identification of the API client to be registered.
        """
        return uuid.uuid1()

    def nom_login(self, rest_credentials, mgmt_credentials):
        """
         Check id of NOM connection and connect to NOM

         Examples:
             NOM Login  ${nom_rest_credentials}  ${nom_mgmt_credentials}
        """
        self.connect(rest_credentials, mgmt_credentials)

    def nom_logout(self, rest_credentials):
        """
         Function index for disconnect from NOM

         Examples:
             NOM Logout    ${nom_rest_credentials}
        """
        self.disconnect(rest_credentials)

    def nom_delete_plan(self, conf_id):
        """
         Function index for deletion plan

         Examples:
             NOM Delete Plan  ${conf_id}
        """
        self.nom.delete_plan(conf_id)

    def nom_integrate_ne(self, ne, ip, username, password, em_url, rest_credentials, mgmt_credentials, tls_ca=None,
                         connection=False):
        """
         Integrate BTS to NOM
         :param ne: str, MRBTS or ASiR to be integrated
         :param ip: str, ip of MRBTS or ASiR to be integrated
         :param username: str, username of NOM's plan
         :param password: str, password of NOM's plan
         :param em_url: str, url for NE's WebEM
         :param rest_credentials: dict, NOM rest credentials info
         :param mgmt_credentials: dict, NOM mgmt credentials info
         :param tls_ca: str, CA string
         :param connection: if True, The connection will be established

         Examples:
             NOM Integrate NE    ne=MRBTS-51150  ip=10.66.30.68  username=wsuser  password=A0zY~rP#8Mx@
             ...    em_url=https://10.66.30.68  rest_credentials=${nom_rest_credentials}
             ...    mgmt_credentials=${nom_mgmt_credentials}  tls_ca=${tlsCA}
        """
        try:
            if connection:
                self.nom_login(rest_credentials, mgmt_credentials)

            if tls_ca:
                name = "{}_tls_integration".format(ne)
            else:
                name = "{}_non_tls_integration".format(ne)

            plan_name, conf_id = self._create_plan(name, "PLAN")
            if ne.lower().startswith('mrbts'):
                add_ob = {'mo_class': {'id': 'com.nokia.nms.integration:MRBTSINT', 'version': '1.0'},
                          'mo_id': '{}/MRBTSINT-AUTO'.format(ne),
                          'operation': 'CREATE',
                          'parameters': {"host": ip, "username": username, "password": password,
                                         "elementManagerURL": em_url, "port": '8080',
                                         "sbiNetConnectedTo": "sbi-default-ipv4"}}
            elif ne.lower().startswith('asi'):
                add_ob = {'mo_class': {'id': 'com.nokia.nms.integration:NE3SINT', 'version': '1.0'},
                          'mo_id': '{}/NE3SINT-AUTO'.format(ne),
                          'operation': 'CREATE',
                          'parameters': {"host": ip, "username": username, "password": password,
                                         "elementManagerURL": em_url, "port": '6080',
                                         "sbiNetConnectedTo": "sbi-default-ipv4"}}
            else:
                logger.error("This type of NE is not supported!")

            if tls_ca is not None:
                if ne.lower().startswith('mrbts'):
                    tls_dict = {'port': '8443', 'tlsHostNameCheck': 'false', 'tlsCA': tls_ca}
                if ne.lower().startswith('asi'):
                    tls_dict = {'port': '6443', 'tlsHostNameCheck': 'false', 'tlsCA': tls_ca}
                add_ob['parameters'].update(tls_dict)
            self.nom.add_managed_objects(conf_id, [add_ob])
            result = self.nom.integrate_ne(plan_name, timeout=300, reintegrate=True)
            assert (result[2].get('status') == 'finished'), "Integration failed: {}".format(result)
        finally:
            self.nom.delete_plan(conf_id)
            if connection:
                self.nom_logout(rest_credentials)

    def nom_deintegrate_ne(self, ne, rest_credentials, mgmt_credentials, connection=False):
        """
         De-integrate BTS from NOM
         :param ne: str, MRBTS or ASiR to be integrated
         :param rest_credentials: dict, NOM rest credentials info
         :param mgmt_credentials: dict, NOM mgmt credentials info
         :param connection: if True, The connection will be established

         Examples:
             NOM Deintegrate NE   ne=MRBTS-51150  rest_credentials=${nom_rest_credentials}
             ...    mgmt_credentials=${nom_mgmt_credentials}  tls_ca=${tlsCA}
        """
        try:
            if connection:
                self.nom_login(rest_credentials, mgmt_credentials)
            name = "{}_de-integration".format(ne)
            plan_name, conf_id = self._create_plan(name, "PLAN")
            if ne.lower().startswith('mrbts'):
                add_ob = {'mo_class': {'id': 'com.nokia.nms.integration:MRBTSINT', 'version': '1.0'},
                          'mo_id': '{}/MRBTSINT-AUTO'.format(ne),
                          'operation': 'DELETE'}
            elif ne.lower().startswith('asi'):
                add_ob = {'mo_class': {'id': 'com.nokia.nms.integration:NE3SINT', 'version': '1.0'},
                          'mo_id': '{}/NE3SINT-AUTO'.format(ne),
                          'operation': 'DELETE'}
            self.nom.add_managed_objects(conf_id, [add_ob])
            result = self.nom.deintegrate_ne(plan_name, timeout=300, purge_data=True)
            assert (result[2].get('status') == 'finished'), "De-integration failed: {}".format(result)

        finally:
            self.nom.delete_plan(conf_id)
            if connection:
                self.nom_logout(rest_credentials)

    def nom_export_plan(self, path, scope=None):
        """
         Function index for get NE plan in NOM
         :param list scope: List of managed object DNs of which subtrees should be included in export.
                       If not specified, i.e. array is empty, entire actual configuration will be exported
                       If provided, the value has to be managed object's distinguish name in URL encoded format.
                       For example, "MRBTS-1234" or "PLMN-PLMN/MRBTS-1234".
         :param str path: Path to save file.

         :return RAML2 file

         Examples:
             NOM Export Plan    ${nom_mrbts_scf_path}    MRBTS-1234
        """
        nom_scf = self.nom.export_plan(path, scope)
        return nom_scf

    def nom_add_managed_objects(self, conf_id, managed_objects):
        """
         Function index for add managed object to plan
         :param int conf_id: PLAN type configuration id.
         :param list[dict] managed_objects: every dict must contain the following keys:
             ``moId/mo_id``, ``moClass/mo_class``, ``planOperation/operation``, ``parameters``.

         Examples:
             NOM Add Managed Objects    ${conf_id}    ${new_mos}
        """
        self.nom.add_managed_objects(conf_id, managed_objects)

    def nom_edit_managed_objects(self, conf_id, managed_objects):
        """
         Function index for edit managed object to plan
         :param int conf_id: PLAN type configuration id.
         :param list[dict] managed_objects: every dict must contain the following keys:
             ``moId/mo_id``, ``moClass/mo_class``, ``planOperation/operation``, ``parameters``.

         Examples:
             NOM Edit Managed Objects    ${conf_id}    ${new_mos}
        """
        self.nom.edit_managed_objects(conf_id, managed_objects)

    def nom_get_managed_objects_parameters(self, mo_ids):
        """
         Function index for get managed object parameters
         :param list[str] mo_ids: A list of managed object ids

         :return dict: Managed object parameters e.g. :
         {
           "result": [
             {
               "mo_id": "MRBTS-1234",
               "mo_class": {
                 "id": "com.nokia.srbts:MRBTS",
                 "version": "SBTS20C_2006_001"
               },
               "operation": None,
               "parameters": {
                 "btsName": "some value"
               }
             }
           ]
         }

         Examples:
              ${mos}    Create List    ASI-${ASI_ID}/SECPRM-1
              ${origin_mos}    NOM Get Managed Objects Parameters    ${mos}
        """
        new_mos = self.nom.get_managed_objects_parameters(1, mo_ids)
        return new_mos

    def nom_create_empty_plan(self, plan_name, description="", plan_type="PLAN"):
        """
         Function index for create plan on NOM
         :param str plan_name: Configuration name
         :param str description: Plan description
         :param str plan_type: Type of the configuration: ACTUAL, REFERENCE, PLAN

         :return dict: plan header information

         Examples:
              ${conf_id}    NOM Create Empty Plan    modify_ASI-1234_localPasswdExpiryPeriod
        """
        plan = self.nom.create_empty_plan(plan_name, description, plan_type)
        return plan['info']['conf_id']

    def nom_upload_parameter(self, integrated_ids, timeout=30):
        """
         Function index for CM upload
         :param list[str] integrated_ids: List of integrated element ids
         :param Union[int,str] timeout: Time to wait for the response of the current operation

         :return list[dict]: every dict contains operation_id, status and timestamp keys.

         Examples:
              ${asi_list}    Create List    ASI-1234
              Nom Upload Parameter    ${asi_list}
        """
        result = self.nom.upload_parameter(integrated_ids, timeout)
        assert (result[2].get('status') == 'finished'), "NOM upload parameter failed: {}".format(result)
        return result

    def nom_provision_plan(self, plan_name, rollback_plan_generation=False, timeout=60):
        """
         Function Initiate plan provisioning for given plan content.
         :param str plan_name: Name of the plan whose managed objects are to be integrated by this execution.
         :param bool rollback_plan_generation: If set to true a backup plan will be auto-generated, which will be
            reverting changes done by the plan to their present actual values.
         :param Union[int,str] timeout: Time to wait for the response of the current operation.

         :return list[dict]: Every ``dict`` contains ``operation_id``, ``status`` and ``timestamp`` attributes.

         Examples:
              NOM Provision Plan    plan_name=modify_ASI-1234_localPasswdExpiryPeriod
        """
        result = self.nom.provision_plan(plan_name, rollback_plan_generation, timeout)
        assert (result[2].get('status') == 'finished'), "NOM provision plan failed: {}".format(result)
        return result

    def nom_import_sw_package(self, file_path, ne_type, ne_sw_version=None, file_name=None, timeout=None):
        """
         Function index for import network element software package.
         :param str file_path: Path to network element software package file.
         :param str ne_type: Network element type. Allowed value: MRBTS, SMM, FHGW
         :param str file_name: Network element software package filename, e.g.: 5G20A_GNB_0009_001800_001514.zip
         :param str ne_sw_version: Network element software version, e.g.: 5G20A_GNB_0009_001800_001514
         :param Union[int,str] timeout: Timeout for importing SW package.

         Examples:
              NOM Import SW Package    ${load_path}    MRBTS
        """
        try:
            self.nom.import_sw_package(file_path, ne_type, ne_sw_version, file_name, timeout)
            sleep(3)
        except ApiException as e:
            self._stop_test_execution_if_exception_doesnt_match(e, ["Internal Server Error"])
            logger.info("Error info: {}".format(e), also_console=True)
            sleep(3)

    def nom_delete_sw_package(self, ne_sw_version, timeout=60):
        """
         Function index for delete network element software package.
         :param str ne_sw_version: Network element software version, e.g.: 5G20A_GNB_0009_001800_001514
         :param Union[int,str] timeout: Timeout for deleting SW package.

         :return list[dict]: every dict contains operation_id, status and timestamp keys.

         Examples:
              NOM Delete SW Package    SBTS00_ENB_9999_220705_000001
        """
        result = self.nom.delete_sw_package(ne_sw_version, timeout)
        assert (result[2].get('status') == 'finished'), "NOM delete SW package failed: {}".format(result)
        return result

    def nom_get_sw_package_list(self, ne_type='MRBTS'):
        """
         Function index for get list of available network element software packages.
         :param str ne_type: Network element type. Allowed value: MRBTS, SMM, FHGW

         :return list(dict): every dict contains ne_sw_version and ne_type keys, e.g.:
         [
           {
             "ne_sw_version": "SBTS00_ENB_9999_210511_000006",
             "ne_type": "MRBTS"
           }
         ]

         Examples:
              ${package_list}    NOM Get SW Package List
        """
        package_list = self.nom.get_sw_package_list(ne_type)
        return package_list

    def nom_provision_sw(self, integrated_ids, ne_sw_version, download=True, activate=True, timeout=1800,
                         run_async=False, provision=None, precheck=None, postcheck=None):
        """
         Function index for SW Provision
         :param list[str] integrated_ids: List of integrated network elements, e.g. ['MRBTS-1234']
         :param str ne_sw_version: Network element software version, e.g.: 5G20A_GNB_0009_001800_001514
         :param bool download: Specify whether download of given sw version has to be performed.
         :param bool activate: Specify whether activation of given sw version has to be performed.
         :param Union[int,str] timeout: Timeout for SW provision, download or activation operation.
         :param bool run_async: If set to True keyword won't wait for operation result and return operation_id instead.
         :param bool provision: Specify whether atomic provision of given sw version has to be performed.
             If set to True, other flags are ignored.
         :param str precheck: Specifies software pre-check type before download, activate, or provision.
             Allowed values: ``fullCheck``, ``upgradeCheck`` or ``rebootCheck``.
         :param bool postcheck: Specifies whether software post-check is required after download,activate or provision.

         :return list[dict]: every dict contains operation_id, status and timestamp keys.
                       dict: containing operation_id
         {
              "operation_id": "f0d454ed-7fed-4838-ab5e-647af65b127f"
         }

         Examples:
              ${mrbts_list}    Create List    MRBTS-1234
              NOM Provision SW    ${mrbts_list}    SBTS00_ENB_9999_220705_000001
        """
        result = self.nom.provision_sw(integrated_ids, ne_sw_version, download, activate, timeout,
                                       run_async, provision, precheck, postcheck)
        assert (result[2].get('status') == 'finished'), "NOM provision SW failed: {}".format(result)
        return result

    def nom_upload_alarms(self, integrated_ids):
        """
         Starts alarm upload for each of the integrated element ids.
         :param list[str] integrated_ids: list of integrated element ids
         :param Union[int,str] timeout: Time to wait for the response of the current operation

         :return list[dict]: every dict contains operation_id, status and timestamp keys.

         Examples:
              ${asi_list}    Create List    ASI-1234
              ${result}    NOM Upload Alarms    ${asi_list}
        """
        result = self.nom.upload_alarms(integrated_ids)
        assert (result[2].get('status') == 'finished'), "NOM provision SW failed: {}".format(result)
        return result

    def nom_get_alarms_from_integrated_ne(self, integrated_id, filters=None, only_active=True):
        """
         Function fetch alarms based on provided integrated_id
         :param str integrated_id: Distname for an integrated element
         :param list[dict] filters: Optional, dictionaries containing AlarmSearchCriteria parameters:
                                    str attribute_name: alarm json key which needs to be searched
                                    str operator: enum [ EQ, NE, LT, GT, LTE, GTE, CONTAINS ]
                                    str attribute_value: value/content to be searched, multiple condition criteria in
                                    filter criteria are evaluated with an "AND" condition, and multiple filter criteria
                                    are evaluated with an "OR" condition.
                                    e.g.
                                         [{
                                         "attribute_name": "integratedId",
                                         "operator": "EQ",
                                         "attribute_value": "FHGW-6666"
                                         },{
                                         "attribute_name": "integratedId",
                                         "operator": "EQ",
                                         "attribute_value": "HQZ-FHGW/FHGW-5379"
                                          }]
         :param bool only_active: If set to True only only_active alarms will be fetched

         :return dict: AlarmSearchPageResponse dict containing: description, alarms (list of Alarms objects),
                       next (AlarmSearchQueryRequest dict) and count.

         Examples:
              ${alarms_info}=  NOM Get Alarms From Integrated NE    ASI-1234
        """
        ne_alarms = self.nom.get_alarms_from_integrated_ne(integrated_id, filters, only_active)
        return ne_alarms

    def nom_rollback_sw(self, integrated_ids):
        """
         Function fetch alarms based on provided integrated_id
         :param list[str] integrated_ids: List of integrated network elements, e.g. ['MRBTS-1234']
         :param Union[int,str] timeout: Timeout for SW rollback operation.

         :return list[dict]: every dict contains operation_id, status and timestamp keys.

         Examples:
              ${mrbts_list}    Create List    MRBTS-1234
              ${result}    NOM Rollback SW    ${mrbts_list}
        """
        result = self.nom.rollback_sw(integrated_ids)
        assert (result[2].get('status') == 'finished'), "NOM rollback SW failed: {}".format(result)
        return result

    def _create_plan(self, name, plan_type="PLAN"):
        """
         Create a NOMs plan and prevent from error
         :param name: str, name of plan name to be created
         :param type: str, type of plan name to be created
         :return: str, plan name, conf id of plan

         Examples:
              plan_name, conf_id = self._create_plan(name, "PLAN")
        """
        try:
            plan = self.nom.create_empty_plan(name, "", plan_type)
        except ApiException as e:
            self._stop_test_execution_if_exception_doesnt_match(e, ["Internal Server Error", "plan already exists"])
            while time() <= time() + 10:
                plan = self.nom.create_empty_plan(name, str(time()).split(".")[0], plan_type)
                break
        return plan['info']['name'], plan['info']['conf_id']

    @staticmethod
    def _stop_test_execution_if_exception_doesnt_match(exception, message_wanted):
        """
         Try to perform operation on plan via NOM
         :param exception: some Exception
         :param message_wanted: list, list with acceptable messages
        """
        if not any(message in str(exception) for message in message_wanted):
            logging.info("Exception type: " + str(type(exception)))
            raise exception
