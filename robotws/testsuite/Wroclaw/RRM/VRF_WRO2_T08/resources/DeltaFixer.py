"""
:copyright: Nokia
:author: dariusz.maciocha@nokia.com
:maintainer: dariusz.maciocha@nokia.com
"""

import ast
import json
import re
from pathlib import Path

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException
from taf.sbts.oam.coam.admin import admin


class DeltaFixer:
    def __init__(self) -> None:
        self._api = admin()
        self._built_in = BuiltIn()
        self._errors_msg = None
        self._delta = None
        self._scf = None
        self._remote_host = None
        self._skip_errors = None
        self._loop_protection = False
        self._output_dir: str = f'{self._built_in.get_variable_value("${OUTPUT_DIR}")}/' \
                                f'{self._built_in.get_variable_value("${TEST_NAME}")}'

    def send_delta_commissioning_with_fixer(self, input_filepath: str | Path, remote_host: str | None = None,
                                            skip_parameter_relation_errors: bool = False) -> None:
        """
            Send delta commissioning with fixing errors that occur.
            This method sends delta commissioning from the provided input file. If the admin API procedure fails,
            it attempts to fix the errors and resend the data.

            :param input_filepath: Path to the input file containing data for recommissioning.
            :type input_filepath: str | Path
            :param remote_host: Remote VM IP to which delta should be applied.
            :type remote_host: str | None
            :param skip_parameter_relation_errors: Should be changed only in exceptional conditions
            :type skip_parameter_relation_errors: bool
            :raises AdminApiProcedureFailureException: Exception raised when the admin API procedure fails.
            :return: None

            Example usage:
            .. code-block:: python
                delta_fixer = DeltaFixer()
                delta_fixer.send_delta_commissioning_with_fixer('path/to/input/file.json')
        """
        self._remote_host = remote_host
        self._skip_errors = skip_parameter_relation_errors
        try:
            self._send_delta_recommissioning(input_filepath, self._skip_errors)
        except AdminApiProcedureFailureException as e:
            self._errors_msg = self._get_errors_dict_from_exception(e.args)
            self._fixer(self._get_scf(), input_filepath)

    @staticmethod
    def _get_errors_dict_from_exception(msg: tuple) -> dict:
        error_msg = msg[0].split("\n")[1]
        error_msg = '{' + error_msg.partition('{')[2].rpartition('}')[0] + '}'
        return ast.literal_eval(error_msg)

    def _send_delta_recommissioning(self, input_filepath: str | Path,
                                    skip_parameter_relation_errors: bool = False) -> None:
        try:
            self._api.setup_admin(remote_host=self._remote_host)
            self._api.perform_delta_recommissioning(input_filepath, skip_parameter_relation_errors)
        finally:
            self._api.teardown_admin()

    def _get_scf(self) -> str:
        try:
            self._api.setup_admin(remote_host=self._remote_host)
            return self._api.get_current_scf_file(self._output_dir, 'basic_scf.xml', 30)
        finally:
            self._api.teardown_admin()

    def _fixer(self, scf_path: str | Path, delta_path: str | Path) -> None:
        with Path(delta_path).open() as delta_f, Path(scf_path).open() as scf_f:
            self._delta = json.load(delta_f)
            self._scf = scf_f.read()
        try:
            if isinstance(self._errors_msg, dict):
                assert self._errors_msg["error"] == ['missing NIDD definition for parameter']
            else:
                assert self._errors_msg[0]["error"] == ['missing NIDD definition for parameter']
        except (KeyError, AssertionError):
            pass
        else:
            self._handle_missing_nidd_definition()
            self._send_fixed_delta(with_fixer=True)
            return
        try:
            assert self._errors_msg['niddValidationResult']['logs']['definitionErrors'][0] is not None
        except Exception:
            try:
                if len(self._errors_msg['pdlValidationResult']['logs']['relationErrors']) == 1 and \
                        "gNbCuType out of range 'NR-DC-SN+NSA'|'NR-DC-SN+SA'|'NR-DC-SN+SA+NSA'" in \
                        self._errors_msg['pdlValidationResult']['logs']['relationErrors'][0]['pdl']:
                    return
            except Exception:
                pass
            raise AdminApiProcedureFailureException(f"Error could not be handled by fixer.\n {self._errors_msg}")
        else:
            self._handle_missing_definition_errors()
            if self._loop_protection:
                self._send_fixed_delta(with_fixer=False)
                return
            self._loop_protection = True
            self._send_fixed_delta(with_fixer=True)

    def _handle_missing_nidd_definition(self) -> None:
        logger.console("Delta failed with missing NIDD params. Fixer will try to repair it.")
        if isinstance(self._errors_msg, dict):
            self._fix_missing_nidd_definition(self._errors_msg)
        else:
            for error in self._errors_msg:
                self._fix_missing_nidd_definition(error)

    def _fix_missing_nidd_definition(self, error: dict) -> None:
        fixed = False
        for i in range(len(self._delta)):
            if self._delta[i]['distName'] == error['distName']:
                for param_id in range(len(self._delta[i]['parameters'])):
                    if self._delta[i]['parameters'][param_id]['parameterName'] == error['parameter']:
                        self._delta[i]['parameters'].pop(param_id)
                        fixed = True
                        break
                break
        if not fixed:
            raise AdminApiProcedureFailureException(f"Error could not be handled by fixer.\n {self._errors_msg}")

    def _handle_missing_definition_errors(self) -> None:
        logger.console("Delta failed with definition errors. Fixer will try to repair it.")
        output_missing = []
        for error in self._errors_msg['niddValidationResult']['logs']['definitionErrors']:
            if (error['error']) == [{'key': 'PARAMETER_IS_REQUIRED'}]:
                self._fix_required_parameter_error(error, output_missing)
            elif len(error['error']) == 2 and error['error'][1] == {'key': 'MISSING_REQUIRED_VALUE_IN_LIST'}:
                self._fix_missing_value_in_list_error(error, output_missing)
            else:
                output_missing.append(error["parameter"])
        if output_missing:
            raise Exception(f"Missing fix for {output_missing}")

    def _fix_required_parameter_error(self, error: dict, output_missing: list) -> None:
        for i in range(len(self._delta)):
            if self._delta[i]['distName'] == error['distName']:
                param_pattern = f'<p name="{error["parameter"]}">(.*)</p>'
                match = re.search(param_pattern, self._scf)
                if not match:
                    param_pattern = f'<list name="{error["parameter"]}">(.*?)</list>'
                    match = re.search(param_pattern, self._scf, flags=re.DOTALL)
                    if not match:
                        output_missing.append(error["parameter"])
                        break
                    self._delta[i]['parameters'].append(
                        {"parameterName": f"{error['parameter']}",
                         "value": [val[3:-4] for val in match.group(1).split()], "operation": "update"})
                    break
                self._delta[i]['parameters'].append({"parameterName": f"{error['parameter']}",
                                                     "value": f"{match.group(1)}", "operation": "update"})
                break

    def _fix_missing_value_in_list_error(self, error: dict, output_missing: list) -> None:
        for i in range(len(self._delta)):
            if self._delta[i]['distName'] == error['distName']:
                param_pattern = f'<p name="{error["error"][0].strip()}">(.*)</p>'
                match = re.search(param_pattern, self._scf)
                if not match:
                    output_missing.append(f'{error["parameter"]}.{error["error"][0]}')
                    break
                for param_id in range(len(self._delta[i]['parameters'])):
                    if self._delta[i]['parameters'][param_id]['parameterName'] == error['parameter']:
                        self._delta[i]['parameters'][param_id]['value'][0][error['error'][0].strip()] = \
                            match.group(1)
                        break
                break

    def _send_fixed_delta(self, with_fixer: bool) -> None:
        fixed_delta_path = Path(self._output_dir, 'fixed_delta.json')
        with fixed_delta_path.open(mode='w') as file:
            json.dump(self._delta, file, indent=4)
        if with_fixer:
            self.send_delta_commissioning_with_fixer(fixed_delta_path, self._remote_host, self._skip_errors)
            return
        self._send_delta_recommissioning(fixed_delta_path, self._skip_errors)
