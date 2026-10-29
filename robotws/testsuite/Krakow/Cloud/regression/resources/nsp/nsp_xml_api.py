"""
NSP XML-API communication

:copyright: Nokia Networks
:author: Lukasz Skoczylas, Grzegorz Hajto
:contact: lukasz.skoczylas@nokia.com, grzegorz.hajto@nokia.com
"""

import xml.etree.ElementTree as ET
from requests import Session


class NspXmlApiException(Exception):
    """Exception class for problems during Nsp operations"""


class NspXmlApi(object):
    """NSP XML-API communication"""
    _SECURED = 'https'
    _PATH = '/xmlapi/invoke'
    _DEFAULT_HEADER = {'Content-Type': 'text/xml_api; charset=ISO-8859-1'}
    _URL = '{protocol}://{ip}:{port}{path}'
    ns = {'soap': 'http://schemas.xmlsoap.org/soap/envelope/',
          'api': 'xmlapi_1.0'}

    def __init__(self, ip, username, password, port=8443):
        """
        NSP XML-API constructor
        :param ip: (str) NSP server ip address
        :param username: (str) username with XML-Api rights
        :param password: (str) password
        :param port: (int) XML-Api port, default 8443
        """
        self._ip = ip
        self._username = username
        self._password = password
        self._port = port
        self._url = self._URL.format(protocol=self._SECURED,
                                     ip=self._ip,
                                     port=str(port),
                                     path=self._PATH)
        self._request_prepare()

    def send_request(self, msg):
        """
        Send XML-Api request
        :param msg: (str) xml-api request
        :return: (str) SOAP response
        """
        response = self._session.post(
            self._url,
            data=self._envelope(msg),
            headers=self._DEFAULT_HEADER)
        return response.text

    def find_all_in_response(self, response, element):
        """
        Finds all matching subelements, by tag name or path.
        :param response: (str) xml-api response
        :param element: (str) tag name or path
        :return: An iterator or sequence containing all matching elements
        """
        root = ET.fromstring(response)
        return root.findall('.//api:{}'.format(element), self.ns)

    def find_in_response(self, response, element):
        """
        Find first matching subelement, by tag name or path
        :param response: (str) xml-api response
        :param element: (str) tag name or path
        :return: (ET.Element) Matching element
        """
        root = ET.fromstring(response)
        return root.find('.//api:{}'.format(element), self.ns)

    def bts_sw_reset(self, mrbts_fdn):
        """
        Perform BTS Software Reset
        :param mrbts_fdn: (str) MRBTS full name (eg. network:MRBTS-465:MRBTS-465)
        """
        response = self.send_request(self.BTS_SW_RESET_MSG.format(mrbts_fdn))
        self._check_exception(response, 'flexi.AbstractMRBTS.btsSwResetException')

    def configure_instance(self, instance_fdn, object_class, parameter, value, action='modify'):
        """
        Configuration/modification of a single object instance.
        :param instance_fdn: (str) Distinguished Name of object being configured.
                             (eg. MRBTS-2464:MRBTS-2464:NRBTS-464:NRCELL-1)
        :param object_class: (str) Class of object to modify (eg. racgnb.NRCELL)
        :param parameter: (str) parameter name
        :param value: (str) value to set
        :param action: (str) action, default: modify
        """
        response = self.send_request(self.CONFIGURE_INSTANCE_MSG.format(instance=instance_fdn,
                                                                        object_class=object_class,
                                                                        parameter=parameter,
                                                                        value=value,
                                                                        action=action))
        self._check_exception(response, 'generic.GenericObject.configureInstanceException')

    def create_activation_session(self, name='TestAuto'):
        """
        Create activation session
        :param name: (str) Session name
        :return: (str) session fdn (eg. actv-mgr:session-110)
        """
        response = self.send_request(self.CREATE_SESSION_MSG.format(name=name))
        result = self.find_all_in_response(response, 'childDistinguishedName')
        if result:
            return result[0].text

    def close_activation_session(self, session_fdn):
        """
        Close and delete activation session
        :param session_fdn: (str) session full domain name (eg. actv-mgr:session-110)
        """
        self.send_request(self.CLOSE_SESSION_MSG.format(session=session_fdn))

    def scan_workorder_repo(self):
        """
        Request to scan workorder repository
        """
        self.send_request(self.SCAN_WO_REPO_MSG)

    def add_wo_to_session(self, wo_id, session_fdn):
        """
        Add workorder to session
        :param wo_id: (int) workorder id
        :param session_fdn: (str) session fdn (eg. actv-mgr:session-110)
        """
        response = self.send_request(self.ADD_WO_TO_SESSION_MSG.format(session=session_fdn,
                                                                       wo_id=wo_id))
        self._check_exception(response, "activation.Session.addWorkOrderException")

    def start_activation_session(self, session_fdn):
        """
        Start session
        :param session_fdn: (str) session fdn (eg. actv-mgr:session-110)
        """
        response = self.send_request(self.START_ACTIVATION_SESSION_MSG.format(session=session_fdn))
        self._check_exception(response, "activation.Session.startSessionException")

    def validate_session(self, session_fdn):
        """
        Validate session
        :param session_fdn: (str) session fdn (eg. actv-mgr:session-110)
        """
        response = self.send_request(self.VALIDATE_SESSION_MSG.format(session=session_fdn))
        self._check_exception(response, "activation.Session.validateSessionException")

    def session_activate_all_wo(self, session_fdn):
        """
        Activate session
        :param session_fdn: (str) session fdn (eg. actv-mgr:session-110)
        """
        response = self.send_request(self.ACTIVATE_ALL_WO_MSG.format(session=session_fdn))
        self._check_exception(response, "activation.Session.activateAllException")

    def get_instance(self, instance_fdn):
        """
        Get object instance
        :param instance_fdn: (str) (eg. actv-mgr:session-110, network:MRBTS-2464:MRBTS-2464:NRBTS-464)
        :return: (str) SOAP response
        """
        return self.send_request(self.FIND_INSTANCE_MSG.format(instance_fdn))

    def get_faults_on_object(self, object_fdn):
        """
        This method retrieves alarms on the specified affected object.
        :param object_fdn: (str) Full name of the affected object (eg. network:MRBTS-2464)
        :return: (list) List with AlarmInfo dict
        """
        response = self.send_request(self.FIND_FAULTS_ON_OBJECT_MSG.format(object=object_fdn))
        self._check_exception(response, "fm.FaultManager.findFaultsOnObjectException")
        faults = self.find_all_in_response(response, 'fm.AlarmInfo')
        return [{self._remove_ns_prefix(item.tag): item.text for item in alarm} for alarm in faults]

    def get_all_alarms_for_object(self, object_fdn):
        """
        This method returns a dict that contains every alarm in the self, affecting, aggregated
        and related categories for the specified object.
        :param object_fdn: (str) Full name of the affected object (eg. network:MRBTS-2464)
        :return: (dict) Dictionary with AlarmInfo list of each category: 'alarms', 'affectingAlarms',
                 'aggregatedAlarms', 'relatedAlarms'
        """
        response = self.send_request(self.FIND_ALARMS_FOR_OBJECT_MSG.format(object=object_fdn))
        self._check_exception(response, "fm.FaultManager.findAlarmsForOfnException")
        alarms_dict = {}
        for category in ('alarms', 'affectingAlarms', 'aggregatedAlarms', 'relatedAlarms'):
            alarms = self.find_in_response(response, category)
            alarms_list = []
            for alarm_item in alarms:
                for alarm in alarm_item[1]:
                    alarm_info = {self._remove_ns_prefix(item.tag): item.text for item in alarm}
                    alarms_list.append(alarm_info)
            alarms_dict[category] = alarms_list
        return alarms_dict

    def get_workorders(self):
        """
        Get workorders
        :return: (list of dict) Workorders attributes
        """
        response = self.send_request(self.FIND_WO_MSG)
        results = self.find_all_in_response(response, 'activation.WorkOrder')
        return [{'id': wo[0].text,
                 'filename': wo[1].text,
                 'woName': wo[2].text,
                 'fdn': wo[8].text,
                 'name': wo[9].text} for wo in results]

    def get_validation_result(self, session_fdn):
        """
        Get ValidationResult
        :param session_fdn: (str) session fdn (eg. actv-mgr:session-110)
        :return: (list of dict) List of ValidationResults
        """
        session_id = session_fdn.split('-')[-1]
        response = self.send_request(self.FIND_VALIDATION_RESULT_MSG.format(session_id=session_id))
        results = self.find_all_in_response(response, 'activation.ValidationResult')
        return [{'id': val_result[0].text,
                 'neWorkOrderId': val_result[2].text,
                 'severity': val_result[5].text,
                 'errorCode': val_result[6].text,
                 'checkDomain': val_result[8].text,
                 'cmDn': val_result[9].text,
                 'message': val_result[12].text} for val_result in results]

    def get_session_status(self, session_fdn):
        """
        Get session status
        :param session_fdn: (str) session fdn (eg. actv-mgr:session-110)
        :return: (list of dict) List of NeWorkOrderStatus
        """
        response = self.get_instance(session_fdn)
        results = self.find_all_in_response(response, "activation.NeWorkOrderStatus")
        return [{'neWorkOrderId': ne_wo_status[0].text,
                 'stage': ne_wo_status[9].text,
                 'stageAction': ne_wo_status[10].text,
                 'stageProgress': ne_wo_status[11].text,
                 'stageDetail': ne_wo_status[12].text,
                 'validity': ne_wo_status[15].text} for ne_wo_status in results]

    def get_find_instance_exception(self, response):
        """
        Find first matching subelement, by tag name or path
        :param response: (str) xml-api response
        :return: (ET.Element) Matching element
        """
        return self.find_in_response(response, "generic.GenericObject.findInstanceException")

    def _request_prepare(self):
        """
        Private method preparing request session
        """
        self._session = Session()
        self._auth = (self._username, self._password)
        self._session.verify = False

    def _envelope(self, msg):
        """
        Private method to encapsulate message into SOAP envelope
        :param msg: (str) XML-API message
        :return: (str) SOAP envelop with body
        """
        return self.ENVELOPE.format(
            user=self._username,
            passwd=self._password,
            body=msg)

    def _check_exception(self, response, api_exception):
        """
        Private method to check is API exception in response and raise NspXmlApiException
        :param response: (str) SOAP response
        :param api_exception: (str) API exception obj (eg. generic.GenericObject.configureInstanceException)
        """
        exception = self.find_in_response(response, api_exception)
        if exception is not None:
            raise NspXmlApiException(
                "{0}\nException description: {1}".format(api_exception, exception[0].text))

    def _remove_ns_prefix(self, text):
        """
        Private method to remove name-space prefix from XML element name
        :param text: (str) text
        :return: (str) text without prefix
        """
        prefix = '{' + self.ns['api'] + '}'
        if text.startswith(prefix):
            return text[len(prefix):]
        return text

    ENVELOPE = """
                  <SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">
                  <SOAP:Header>
                      <header xmlns="xmlapi_1.0">
                      <security>
                          <user>{user}</user>
                          <password hashed="false">{passwd}</password>
                      </security>
                      </header>
                  </SOAP:Header>
                  <SOAP:Body>
                      {body}
                  </SOAP:Body>
                  </SOAP:Envelope>"""

    FIND_INSTANCE_MSG = """
            <generic.GenericObject.findInstance xmlns="xmlapi_1.0">
                <instanceFullName>{}</instanceFullName>
            </generic.GenericObject.findInstance>"""

    CREATE_SESSION_MSG = """<generic.GenericObject.configureChildInstance   xmlns="xmlapi_1.0">
                            <deployer>immediate</deployer>
                            <distinguishedName>actv-mgr</distinguishedName>
                            <childConfigInfo>
                             <activation.Session>
                               <actionMask>
                                 <bit>create</bit>
                                </actionMask>
                               <sessionPriority>normal</sessionPriority>
                               <sessionName>{name}</sessionName>
                               <description></description>
                               <id>0</id>
                             </activation.Session>
                             </childConfigInfo>
                          </generic.GenericObject.configureChildInstance>"""

    CLOSE_SESSION_MSG = """<activation.Session.closeSession xmlns="xmlapi_1.0">
                               <sessionFdn>{session}</sessionFdn>
                               <continueOnFailure>false</continueOnFailure>
                               <shouldDelete>true</shouldDelete>
                             </activation.Session.closeSession>"""

    SCAN_WO_REPO_MSG = """
            <activation.ActivationManager.scanWorkOrderRepository xmlns="xmlapi_1.0">
                <continueOnFailure>false</continueOnFailure>
            </activation.ActivationManager.scanWorkOrderRepository>"""

    FIND_WO_MSG = """
            <find xmlns="xmlapi_1.0">
                <fullClassName>activation.WorkOrder</fullClassName>
            </find>"""

    ADD_WO_TO_SESSION_MSG = """
            <activation.Session.addWorkOrder xmlns="xmlapi_1.0">
                <deployer>immediate</deployer>
                <sessionFdn>{session}</sessionFdn>
                <workOrderFdn>actv-mgr:wo-{wo_id}</workOrderFdn>
                <failAllOnError>true</failAllOnError>
                <autoLoad>true</autoLoad>
            </activation.Session.addWorkOrder>"""

    START_ACTIVATION_SESSION_MSG = """
            <activation.Session.startSession xmlns="xmlapi_1.0">
                <sessionFdn>{session}</sessionFdn>
            </activation.Session.startSession>"""

    VALIDATE_SESSION_MSG = """
            <activation.Session.validateSession xmlns="xmlapi_1.0">
                <sessionFdn>{session}</sessionFdn>
                <areEngineeringChecksToBeExecuted>true</areEngineeringChecksToBeExecuted>
            </activation.Session.validateSession>"""

    FIND_VALIDATION_RESULT_MSG = """
            <find xmlns="xmlapi_1.0">
                <fullClassName>activation.ValidationResult</fullClassName>
                    <filter>
                        <equal name="sessionId" value="{session_id}"/>
                    </filter>
                    <resultFilter>
                        <children/>
                    </resultFilter>
            </find>"""

    ACTIVATE_ALL_WO_MSG = """
            <activation.Session.activateAll xmlns="xmlapi_1.0">
                <sessionFdn>{session}</sessionFdn>
            </activation.Session.activateAll>"""

    FIND_FAULTS_ON_OBJECT_MSG = """
            <fm.FaultManager.findFaultsOnObject xmlns="xmlapi_1.0">
                <baseInstanceFullName>{object}</baseInstanceFullName>
            </fm.FaultManager.findFaultsOnObject>"""

    FIND_ALARMS_FOR_OBJECT_MSG = """
                <fm.FaultManager.findAlarmsForOfn xmlns="xmlapi_1.0">
                    <alarmedObjectOfn>{object}</alarmedObjectOfn>
                </fm.FaultManager.findAlarmsForOfn>"""

    BTS_SW_RESET_MSG = """
                <flexi.AbstractMRBTS.btsSwReset  xmlns="xmlapi_1.0">
                    <deployer>immediate</deployer>
                    <synchronousDeploy>true</synchronousDeploy>
                    <instanceFullName>{}</instanceFullName>
                </flexi.AbstractMRBTS.btsSwReset>"""

    CONFIGURE_INSTANCE_MSG = """
                <generic.GenericObject.configureInstance    xmlns="xmlapi_1.0">
                    <deployer>immediate</deployer>
                    <synchronousDeploy>true</synchronousDeploy>
                    <distinguishedName>{instance}</distinguishedName>
                    <configInfo>
                        <{object_class}>
                            <actionMask>
                                <bit>{action}</bit>
                            </actionMask>
                            <{parameter}>{value}</{parameter}>
                        </{object_class}>
                    </configInfo>
             </generic.GenericObject.configureInstance>"""
