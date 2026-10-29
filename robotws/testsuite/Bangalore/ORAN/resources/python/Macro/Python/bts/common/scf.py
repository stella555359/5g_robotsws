# -*- coding: utf-8 -*-
"""
Generic keywords for BTS.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
import logging
from taf.sbts.oam.coam.admin.exceptions import DataNotAvailable
from taf.internal.sbts.admin.exceptions import \
    AdminApiProcedureFailureException
from taf.internal.robot_typecasts import time_to_seconds, to_boolean
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.generic_bts import GenericBts, login_logout, login_logout_GUI
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    exceptions import ValidationErrorNotActive, ValidationError
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    utilities import get_builtin_value

tl = get_builtin_value(param_name="tl")


class GenericScf(GenericBts):
    """SCF keywords for eNB and gNB"""

    @login_logout
    def verify_validation_error_active(self, bts_id=0, du_id=0):
        """
        Verify validation error is active on current SCF
        :param bts_id: ID of gNB/eNB
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return: None
        """
        try:
            validation_result = self._validate_scf(bts_id=bts_id, du_id=du_id)
            logging.error("Validation result: {}".format(validation_result))
            raise ValidationErrorNotActive("Validation error is not active")
        except AdminApiProcedureFailureException:
            logging.info("Validation error is active")

    @login_logout
    def perform_bts_full_commissioning(
            self, scf_file, bts_id=0, skip_parameter_relation_errors=False,
            should_activate=True, validate_scf=True, timeout=300, du_id=0):
        """
        Perform Full BTS commissioning.

        :param scf_file: Path to the scf file
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param skip_parameter_relation_errors: Skip parameter
        relation errors
        :param should_activate: Should automatically activate plan
        :param validate_scf:    Should automatically validate plan
        :param timeout: Timeout for the operation. It is based on observed
         test times
        :return: None.
        """

        timeout = time_to_seconds(time=timeout)
        skip_parameter_relation_errors = to_boolean(
            item=skip_parameter_relation_errors)
        should_activate = to_boolean(item=should_activate)
        validate_scf = to_boolean(item=validate_scf)
        connection = self.rest_alias.format(bts_id, du_id)

        try:
            if validate_scf:
                validation_result = self._validate_scf(
                    bts_id=bts_id, du_id=du_id)
                logging.info("Validation result: {}".format(validation_result))
            self.admin.perform_commissioning(
                scf_file=scf_file,
                skip_parameter_relation_errors=skip_parameter_relation_errors,
                should_activate=should_activate,
                timeout=timeout, connection=connection)
        except AdminApiProcedureFailureException:
            raise ValidationError("Validation error occurred and "
                                  "configuration should be rejected")
        else:
            logging.info("Validation passed")

    @login_logout
    def perform_bts_delta_commissioning(
            self, delta, bts_id=0, skip_parameter_relation_errors=False,
            should_activate=True, timeout=300, du_id=0):
        """
        Perform parameter recommissioning, update and delete operation
         can be used.

        :param list delta: list of parameters to update. Sample delta:
                delta = [{
                            'distName': dist_name,
                            'operation': 'update',
                            'parameters': [{
                                            'operation': operation,
                                            'parameterName': parameter,
                                            'value': value}]}]
                where:
                    dist_name: Object dist name ie. "MRBTS-{}/LNBTS-{}/LNMME-0"
                    parameter: Parameter name ie. "ipAddrPrim"
                    operation: Parameter operation (update or delete)
                    value: Parameter value ie. "10.0.1.99" or
                    [{"eea1":0, "eea0":1, "eea3":8, "eea2":0}]
        :param bts_id: ID of gNB/eNB
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param boolean skip_parameter_relation_errors: Skip parameter
        relation errors
        :param bool should_activate: Should automatically activate plan
        :param Union[int,str] timeout: Time to wait for positive
        procedure result
        :raises taf.gnb.oam.coam.admin.legacy.exceptions.
        AdminApiProcedureFailureException: Will be raised if
            recommissioning fails
        :return dict: Recommissioning status
        """
        timeout = time_to_seconds(time=timeout)
        skip_parameter_relation_errors = to_boolean(
            item=skip_parameter_relation_errors)
        should_activate = to_boolean(item=should_activate)

        for param_dict in delta:
            param_dict['distName'] = self.adjust_dist_name(
                dist_name=param_dict['distName'],
                bts_id=bts_id, du_id=du_id)

        parameters = {"planObjects": delta,
                      "shouldBeActivated": should_activate}

        connection = self.admin.store.get(
            self.rest_alias.format(bts_id, du_id))

        if skip_parameter_relation_errors:
            parameters["skipParameterRelationErrors"] = True
        status = connection._api_client.execute_procedure(
            "recommission", parameters, timeout)
        if status is None:
            raise DataNotAvailable("Recommissioning status "
                                   "has not been provided by M-Plane.")
        return status

    @login_logout
    def perform_object_recommissioning(self, dist_name, parameter, operation,
                                       bts_id=0,
                                       skip_parameter_relation_errors=False,
                                       should_activate=True,
                                       timeout=180, du_id=0):
        """
        Perform recommissioning of specified configuration parameter on bts.

        :param dist_name:object dist name ie. "MRBTS-{}/NRBTS-{}/NRPGRP-0"
        :type  dist_name: str
        :param parameter: list of dicts ie.
        [
            parameterName=lbpsPeriodList
            operation=update
            value=[
                      {
                          lbpsDayOfWeek=Mon
                          lbpsDuration=10
                          lbpsStartTimeHour=12
                          lbpsStartTimeMinute=10
                          lbpsSuspended=notSuspended
                      }
                  ]
        ]
        :type  parameter: list
        :param operation: parameter operation (create, update or delete)
        :type  operation: str
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration,
        default 0
        :type  bts_id: int
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :type  du_id: int
        :param skip_parameter_relation_errors: If True then skip parameter
        relation errors, default False
        :type  skip_parameter_relation_errors: bool
        :param should_activate: If True activate plan automatically, default
        True
        :type  should_activate: bool
        :param timeout: Time to wait for positive procedure result, default 180
        :type  timeout: int
        :return: dict
        :return: ie.
        {
            "commissioningResult":
                {"isGoingToTriggerReset": false,
                    "activationResult":
                        {"resultNode":
                            {"distName":
                             "/MRBTS-1/RAT-1/URI-1/SESSION-67/
                             PLAN_ACTIVATE_IND-1/PLAN_ACTIVATE_RESULT-1",
                             "parameters":
                                {"result": "Success",
                                 "feedback": "",
                                 "resetCoverage": ["None"],
                             "rejectedObjects": []}},
            "indicationDistName":
            "/MRBTS-1/RAT-1/URI-1/SESSION-67/PLAN_ACTIVATE_IND-1"}},
            "validationResult": {"niddValidationResult":
                                {"status": "OK",
                                "logs": {"skippedElements": null,
                                         "missingObjectsErrors": null,
                                         "definitionErrors": null,
                                         "maxOccurrencesErrors": null}},
                                         "pdlValidationResult":
                                         {"status": "OK
                                          "logs":
                                            {"hardwareErrors": [],
                                             "relationErrors": []}}},
            "modifiedObjectsDistNames":
                {"deleted": [],
                "modified": ["MRBTS-51102/NRBTS-51102/NRPGRP-0"]}}
        """
        dist_name = self.adjust_dist_name(dist_name=dist_name,
                                          bts_id=bts_id, du_id=du_id)
        self.admin.perform_object_recommissioning(
            dist_name, parameter, operation, skip_parameter_relation_errors,
            should_activate, timeout,
            connection=self.rest_alias.format(bts_id, du_id))

    @login_logout
    def verify_configuration_rejection(
            self, scf_file, bts_id=0, skip_parameter_relation_errors=False,
            should_activate=False, timeout=60, du_id=0):
        """
        Verify if configuration was rejected

        :param scf_file: Path to the scf file
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param skip_parameter_relation_errors: Skip parameter relation errors
        :param should_activate: Should automatically activate plan
        :param timeout: Timeout for the operation. It is based on
        observed test times
        :return: None.
        """

        timeout = time_to_seconds(time=timeout)
        skip_parameter_relation_errors = to_boolean(
            item=skip_parameter_relation_errors)
        should_activate = to_boolean(item=should_activate)

        try:
            self.admin.perform_commissioning(
                scf_file=scf_file,
                skip_parameter_relation_errors=skip_parameter_relation_errors,
                should_activate=should_activate,
                timeout=timeout,
                connection=self.rest_alias.format(bts_id, du_id))

        except AdminApiProcedureFailureException:
            logging.info("Configuration has been rejected successfully")

        else:
            raise ValidationError("This configuration should be rejected")

    def _validate_scf(self, bts_id=0, scf_file=None,
                      local_dir_path="/tmp/", file_name="scf.xml", timeout=180,
                      du_id=0):
        """
        Validate SCF file and return validation result
        :param bts_id: ID of gNB/eNB
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param str file_name: File name of final SCF
        :param str local_dir_path: Path to directory to store final SCF
        :param str scf_file: Path to the SCF file
        :param Union[int,str] timeout: Timeout for the operation
        :raises taf.gnb.oam.coam.admin.legacy.exceptions.AdminApiProcedure
        FailureException: Will be raised if
        validation failed
        :return: str: SCF validation result.
            validation_result = {
                                    "niddValidationResult": {
                                    "status": "OK",
                                    "logs": {"skippedElements": null,
                                    "missingObjectsErrors": null,
                                    "definitionErrors": null,
                                      "maxOccurrencesErrors": null}},
                                    "pdlValidationResult": {
                                    "status": "OK",
                                    "logs": {"hardwareErrors": [],
                                     "relationErrors": []}}
                                }
        """
        connection = self.rest_alias.format(bts_id, du_id)
        scf = scf_file if scf_file else self.admin.get_current_scf_file(
            local_dir_path, file_name, timeout, connection)
        return self.admin.validate_scf(scf_file=scf, timeout=timeout,
                                       connection=connection)

    def perform_parameter_recommissioning(
            self, dist_name, parameter, operation, value, bts_id=0,
            skip_parameter_relation_errors=False, should_activate=True,
            timeout=60,
            du_id=0):
        """
        Perform specified parameter recommissioning on bts.

        :param dist_name:object dist name ie. "MRBTS-{}/LNBTS-{}/LNMME-0"
        :type  dist_name: str
        :param parameter: parameter name ie. "ipAddrPrim"
        :type  parameter: str
        :param operation: parameter operation (update or delete)
        :type  operation: str
        :param value: parameter value ie. "locked" or "unlocked"
        :type  value: str
        :param bts_id: BTS(eNB/gNB) id - related to Test Line
         configuration, default 0
        :type  bts_id: int
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :type  du_id: int
        :param skip_parameter_relation_errors: If True then skip parameter
        relation errors, default False
        :type  skip_parameter_relation_errors: bool
        :param should_activate: If True activate plan automatically, default
        True
        :type  should_activate: bool
        :param timeout: Time to wait for positive procedure result, default 60
        :type  timeout: int
        :return: Example:
                {
                   "commissioningResult": {
                      "activationResult": {
                         "indicationDistName":
                         "/MRBTS-1/RAT-1/URI-4/SESSION-40/
                         PLAN_ACTIVATE_IND-1",
                         "resultNode": {
                            "distName": "/MRBTS-1/RAT-1/URI-4
                            /SESSION-40/PLAN_ACTIVATE_
                            IND-1/PLAN_ACTIVATE_RESULT-1",
                            "parameters": {
                               "feedback": "",
                               "rejectedObjects": [],
                               "resetCoverage": [
                                  "None"
                               ],
                               "result": "Success"
                            }
                         }
                      },
                      "isGoingToTriggerReset": false
                   },
                   "modifiedObjectsDistNames": {
                      "deleted": [],
                      "modified": [
                         "MRBTS-100325/LNBTS-100325/LNADJGNB-1"
                      ]
                   },
                   "validationResult": {
                      "niddValidationResult": {
                         "logs": {
                            "definitionErrors": "None",
                            "maxOccurrencesErrors": "None",
                            "missingObjectsErrors": "None",
                            "skippedElements": "None"
                         },
                         "status": "OK"
                      },
                      "pdlValidationResult": {
                         "logs": {
                            "hardwareErrors": [],
                            "relationErrors": []
                         },
                         "status": "OK"
                      }
                   }
                }
        :rtype : dict
        """
        dist_name = self.adjust_dist_name(
            dist_name=dist_name, bts_id=bts_id, du_id=du_id)
        return self.admin.perform_parameter_recommissioning(
            dist_name, parameter, operation, value,
            skip_parameter_relation_errors,
            should_activate, timeout,
            connection=self.rest_alias.format(bts_id, du_id))

    @login_logout
    def perform_configuration_parameter_recommissioning(
            self, dist_name, parameter, operation, value,
            bts_id=0, skip_parameter_relation_errors=False,
            should_activate=True, timeout=60, du_id=0):
        """
        Perform recommissioning of specified configuration parameter on bts.

        :param dist_name:object dist name ie. "MRBTS-{}/LNBTS-{}/LNMME-0"
         or "MRBTS-{}/NRBTS-{}/NRCELL-1"
        :type  dist_name: str
        :param parameter: parameter name ie. "ipAddrPrim"
        :type  parameter: str
        :param operation: parameter operation (update or delete)
        :type  operation: str
        :param value: parameter value ie. "locked" or "unlocked"
        :type  value: str
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration,
         default 0
        :type  bts_id: int
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :type  du_id: int
        :param skip_parameter_relation_errors: If True then skip parameter
        relation
        errors, default False
        :type  skip_parameter_relation_errors: bool
        :param should_activate: If True activate plan automatically,
        default True
        :type  should_activate: bool
        :param timeout: Time to wait for positive procedure result, default 60
        :type  timeout: int
        :return: None
        """
        self.perform_parameter_recommissioning(
            dist_name=dist_name, parameter=parameter, operation=operation,
            value=value, bts_id=bts_id, should_activate=should_activate,
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            timeout=timeout, du_id=du_id)

    @login_logout
    def reset_configuration(self, bts_id=0, du_id=0):
        """
        Reset configuration

        :param bts_id: BTS(eNB/gNB) id - related to Test Line
         configuration, default 0
        :type  bts_id: int
        :param du_id: DU id - related to Test Line configuration, default 0
        :type  du_id: int
        :return: None
        """

        self.admin.reset_configuration(
            connection=self.rest_alias.format(bts_id, du_id))

    @login_logout_GUI
    def perform_bts_full_commissioning_via_gui(self, bts_id=0, du_id=0,
                                               scf_path=None):
        """
        Upload and activate new scf file closing necessary windows
        :param bts_id: BTS(eNB/gNB) id - related to Test Line
        configuration, default 0
        :type  bts_id: int
        :param du_id: DU id - related to Test Line configuration, default 0
        :type  du_id: int
        :parm scf_path: path to scf
        :type scf_path: str
        :return: None
        """
        self.gui_coam.continue_after_plug_and_play_modal_appear()
        self.gui_coam.load_commissioning_file_and_check_load_status(scf_path)
        self.gui_coam.activate_plan(activate_plan_despite_errors=True)

    @login_logout
    def disable_enable_all_pm_counters(self, bts_id=0, du_id=0,
                                       value="disabled"):
        """
        Disable or enable all pm counters on gnb
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration,
         default 0
        :type  bts_id: int
        :param du_id: DU id - related to Test Line configuration, default 0
        :type  du_id: int
        :param value: New value of counter parameters
        :type value: str  - value/5min/15min/30min/60min/360min/720min/14400min
        :return: None
        """

        PMTNL_counters = ["ethernetLinkInterval",
                          "bridgePortStatisticsInterval",
                          "ethernetInterfaceStatisticsInterval",
                          "firstLevelSchedulerStatisticsInterval",
                          "ipInterfaceStatisticsInterval",
                          "ipNodeStatisticsInterval",
                          "ipPerHopBehaviourStatisticsInterval",
                          "ipSecSaStatisticsInterval",
                          "ipSecStatisticsInterval",
                          "ipV4AddressStatisticsInterval",
                          "ipV4RxPerHopBehaviourStatisticsInterval",
                          "ipV4TxPerHopBehaviourStatisticsInterval",
                          "ipV6AddressStatisticsInterval",
                          "ipV6RxPerHopBehaviourStatisticsInterval",
                          "ipV6TxPerHopBehaviourStatisticsInterval",
                          "sctpStatisticsInterval",
                          "secondLevelSchedulerStatisticsInterval",
                          "tcpUdpStatisticsInterval",
                          "vlanStatisticsInterval",
                          "ipFilteringInterval",
                          ]

        NRPMRNL_counters = ["miNrBeamforming",
                            # "miNrBeamforming2",
                            "miNrCaCu",
                            "miNrCaDu",
                            "miNrCellAvailability",
                            "miNrCellUtilization",
                            "miNrDlHarq",
                            "miNrDlSignalQuality",
                            "miNrE1InterfaceBts",
                            "miNrE1InterfaceCuCpNsa",
                            "miNrE1InterfaceCuCpSa",
                            "miNrE1InterfaceCuUp",
                            "miNrE1InterfaceCuUpNsa",
                            "miNrE1InterfaceCuUpSa",
                            "miNrEcpriUpFCp",
                            "miNrEirp",
                            "miNrEnDssPerCell",
                            "miNrF1CC",
                            "miNrF1CD",
                            "miNrF1UCInterface",
                            "miNrF1UDInterface",
                            "miNrF1UU",
                            "miNrGnss",
                            "miNrHighRlcReport",
                            "miNrIfPsCellChange",
                            "miNrLowRlcReport",
                            "miNrLteMgPerCell",
                            "miNrLteMobilityReport",
                            "miNrMacPduTput",
                            "miNrMacSduReport",
                            "miNrMgPerCell",
                            "miNrMobilityReportCu",
                            "miNrMobilityReportDu",
                            "miNrNAECL",
                            "miNrNGCC",
                            "miNrNREMO",
                            "miNrNTRAF",
                            "miNrNgInterface",
                            "miNrNgUReport",
                            # "miNrNgcFlexInterface",
                            "miNrPDCP1Report",
                            # "miNrPDCP2Report",
                            # "miNrPaging",
                            "miNrPdcpC",
                            "miNrPsCellChange",
                            "miNrRANS",
                            "miNrRRCC",
                            "miNrRRCD",
                            "miNrRSACU",
                            "miNrRSADU",
                            "miNrRSANB",
                            "miNrRSUP",
                            "miNrRacCu",
                            "miNrRacDu",
                            "miNrRachUsage",
                            "miNrRadBearer",
                            # "miNrRelReportCu",
                            "miNrRlfPerCell",
                            "miNrS1UInterface",
                            "miNrSfpBbmod",
                            "miNrSfpRmod",
                            "miNrSfpSmod",
                            "miNrSlicingCuCp",
                            "miNrSlicingCuUp",
                            "miNrSrb3C",
                            "miNrSrb3D",
                            "miNrSrvcAvaStats",
                            "miNrTimingAdvance",
                            "miNrUeState",
                            "miNrUlHarq",
                            "miNrUlSignalQuality",
                            "miNrX2CB",
                            "miNrX2CC",
                            "miNrX2UInterface",
                            "miNrXnCCInterface",
                            "miNrXnInterface",
                            "miNrXnUCInterface"
                            ]

        template = {
            "operation": "update",
            "value": value
        }

        list_of_PMTNL_counters = []
        for name in PMTNL_counters:
            template["parameterName"] = name
            list_of_PMTNL_counters.append(template.copy())

        list_of_NRPMRNL_counters = []
        for name in NRPMRNL_counters:
            template["parameterName"] = name
            list_of_NRPMRNL_counters.append(template.copy())

        dist_name_PMTNL = self.adjust_dist_name(
            "MRBTS-{}/TNLSVC-1/TNL-1/PMTNL-1", bts_id=bts_id, du_id=du_id)
        dist_name_NRPMRNL = self.adjust_dist_name(
            "MRBTS-{}/NRBTS-{}/NRPMRNL-1", bts_id=bts_id, du_id=du_id)

        delta = [
            {
                "distName": dist_name_PMTNL,
                "operation": "update",
                "parameters": list_of_PMTNL_counters
            },
            {
                "distName": dist_name_NRPMRNL,
                "operation": "update",
                "parameters": list_of_NRPMRNL_counters
            }]
        self.perform_bts_delta_commissioning(delta=delta)


class EnbScf(GenericScf):
    """Class contains SCF keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.

        """

        super(EnbScf, self).__init__(bts_type=EnbScf.bts_type)


class GnbScf(GenericScf):
    """Class contains SCF keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.

        """
        super(GnbScf, self).__init__(bts_type=GnbScf.bts_type)
