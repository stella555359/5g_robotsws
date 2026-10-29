"""
KPI Calculation Utilities
=========================

This module defines the `KpiCalculation` class and supporting logic used by
`kpi.py` to evaluate KPI values against configuration targets.

Responsibilities
----------------
- Encapsulate all data and metadata related to a single KPI calculation.
- Store KPI name, target, formula, dimension filters, reduction method, and
  calculated values.
- Provides methods `report_verdict_failed` and `report_verdict` for logging
  calculated KPI results. Output is logged using robot.api logger.
- Provides method for exporting calculated KPI results to `kpi_calculation.jsonl`
  for data analysis and `kpi_calculation_readable.txt` in human readable form.

This file is part of the user-facing KPI evaluation pipeline but typically does
not require user modification. Users control KPI verification only through
`config.py`.
"""

import json
import pandas as pd
from dataclasses import dataclass
from pathlib import Path

from robot.api import logger

from kpi_definition import KPI_DEFINITION

__all__ = ["KpiCalculation"]


@dataclass
class CalculationResult:
    """Container for a single KPI calculation result."""

    dimension: list[str]
    calculated_kpi: pd.DataFrame
    is_kpi_on_target: bool


class KpiCalculation(object):

    JSONL_FILENAME = "kpi_calculation.jsonl"
    READABLE_FILENAME = "kpi_calculation_readable.txt"

    def __init__(self, kpi_definition: str, **kwargs) -> None:
        try:
            self.kpi_definition = KPI_DEFINITION[kpi_definition]
        except KeyError as e:
            raise KeyError(f"KPI definition '{kpi_definition}' not found") from e

        self.target = kwargs.get("target", self.kpi_definition.target)
        self.dimension_filters = kwargs.get(
            "dimension_filters", self.kpi_definition.dimension_filters
        )
        self.reduction_method = kwargs.get(
            "reduction_method", self.kpi_definition.reduction_method
        )
        self.is_mandatory: bool = kwargs.get("is_mandatory", True)

        self.calculation_formula_inputs = self.kpi_definition.calculation_formula_inputs
        self.calculation_formula = self.kpi_definition.calculation_formula
        self.comparison_operator = self.kpi_definition.comparison_operator
        self.max_kpi_value = self.kpi_definition.max_kpi_value

        self.calculation_results: list[CalculationResult] = []

    def create_empty_calculation_result(self, dimension_filter: list) -> None:
        self.calculation_results.append(
            CalculationResult(
                dimension=dimension_filter, calculated_kpi=pd.DataFrame(), is_kpi_on_target=False
            )
        )

    def update_calculation_result(
        self, dimension_filter: list, calculated_kpi: pd.DataFrame, is_kpi_on_target: bool
    ) -> None:
        matched = next(
            (cr for cr in self.calculation_results if cr.dimension == dimension_filter), None,
        )
        if matched:
            matched.calculated_kpi = calculated_kpi
            matched.is_kpi_on_target = is_kpi_on_target

    def _target_repr(self) -> str:
        """Return a compact string describing the target comparison operator."""
        op_name = getattr(self.comparison_operator, "__name__", str(self.comparison_operator))
        return f"{op_name} {self.target}"

    def report_verdict_failed(self) -> None:
        """Log only failed KPI calculation results as errors."""
        for result in self.calculation_results:
            if not result.is_kpi_on_target:
                message = (
                    f"KPI name: {self.kpi_definition.name}\n"
                    f"KPI id: {self.kpi_definition.id}\n"
                    f"KPI target: {self._target_repr()}\n"
                    f"Dimension: {result.dimension}\n"
                    f"KPI calculation:\n{result.calculated_kpi.to_string()}"
                )
                logger.error(message)

    def report_verdict(self) -> None:
        """Log all KPI calculation results (debug-level)."""
        for result in self.calculation_results:
            message = (
                f"KPI name: {self.kpi_definition.name}\n"
                f"KPI id: {self.kpi_definition.id}\n"
                f"KPI target: {self._target_repr()}\n"
                f"KPI mandatory: {self.is_mandatory}\n"
                f"Dimension: {result.dimension}\n"
                f"KPI calculation:\n{result.calculated_kpi.to_string()}"
            )
            logger.debug(message)

    def dump_calculation_to_file(self, logs_dir: str | Path) -> None:
        """Append calculation results to logs (JSONL + human-readable)."""
        logs_path = Path(logs_dir)
        logs_path.mkdir(parents=True, exist_ok=True)

        for calculation_result in self.calculation_results:
            self._dump_data(calculation_result, logs_path)
            self._dump_data_readable(calculation_result, logs_path)

    def _dump_data(self, result: CalculationResult, logs_path: Path) -> None:
        """Append a JSONL entry for the given calculation result to the file."""
        entry = {
            "kpi_name": self.kpi_definition.name,
            "kpi_id": self.kpi_definition.id,
            "kpi_target": self.target,
            "kpi_mandatory": self.is_mandatory,
            "dimension_filter": result.dimension,
            "calculation_result": result.calculated_kpi.to_dict(
                orient="records"
            ),
            "is_kpi_on_target": result.is_kpi_on_target,
        }

        jsonl_path = logs_path / self.JSONL_FILENAME
        try:
            with jsonl_path.open("a", encoding="utf-8") as fh:
                fh.write(json.dumps(entry, ensure_ascii=False, default=str) + "\n")
        except Exception as e:
            logger.error(f"Failed to write KPI calculation JSONL: {str(e)}")

    def _dump_data_readable(self, result: CalculationResult, logs_path: Path) -> None:
        """Append a human-readable text entry for the given calculation result to the file."""
        readable_path = logs_path / self.READABLE_FILENAME
        body = (
            f"KPI name: {self.kpi_definition.name}\n"
            f"KPI id: {self.kpi_definition.id}\n"
            f"KPI target: {self._target_repr()}\n"
            f"KPI mandatory: {self.is_mandatory}\n"
            f"Dimension: {result.dimension}\n"
            f"KPI calculation:\n{result.calculated_kpi.to_string()}\n"
            "### END ENTRY ###\n\n"
        )
        try:
            with readable_path.open("a", encoding="utf-8") as fh:
                fh.write(body)
        except Exception as e:
            logger.error(f"Failed to write KPI calculation readable file: {str(e)}")
