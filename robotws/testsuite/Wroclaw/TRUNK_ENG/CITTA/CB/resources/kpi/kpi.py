import os
import base64
import zipfile
import gzip
import io
import math
import pandas as pd
import xml.etree.ElementTree as ET
from typing import Callable, Any
from datetime import datetime, timezone
import tzlocal
from robot.api import logger
from kpi_calculation import KpiCalculation


def get_counters_data(pm_files_path: str, logs_dir: str = "/tmp") -> pd.DataFrame:
    """
    Decode, extract, and parse performance counter files into a single DataFrame.

    This function is the entry point used by Robot Framework. It expects the
    `pm_files_path` to point to a base64-encoded ZIP archive (as
    produced by the `Get Pm Files` keyword from `taf.sbts.oam.coam.admin`).
    The ZIP contents are extracted into `logs_dir`, `.gz` files are decompressed
    to `.xml`, and all XML measurement files are parsed into a normalized
    pandas DataFrame where each row represents a single metric sample.

    The parsing preserves:
      - `startTime` and `interval` from `<PMSetup>`,
      - `measurementType` and `neTag` from `<NE-*>`,
      - `metric` (counter ID) and numeric `value`,
      - `dimensions` (list of MO/DN values).

    Returns a DataFrame with at least: `startTime`, `interval`, `measurementType`,
    `neTag`, `metric`, `value`, `dimensions`. All `startTime` values are timezone-aware
    UTC timestamps.

    Parameters
    ----------
    pm_files_path : str
        Path to the base64-encoded ZIP produced by the collection keyword.
    logs_dir : str, optional
        Directory used for temporary extraction and decompression. Defaults to `/tmp`.

    Returns
    -------
    pandas.DataFrame
        Parsed counter samples consolidated from all extracted XML files.

    See Also
    --------
    _decode_and_extract_counter_file, _extract_counters_files, _parse_counters_files.
    """
    packed_counters_files_paths = _decode_and_extract_counter_file(
        pm_files_path, logs_dir
    )
    counters_files_paths = _extract_counters_files(packed_counters_files_paths)
    counters_data = _parse_counters_files(counters_files_paths)
    return counters_data


def _decode_and_extract_counter_file(file_path: str, output_folder: str) -> list[str]:
    """
    Decode a base64-encoded ZIP file and extract its contents.

    Reads the entire file at `file_path` as base64-encoded bytes, decodes
    them in-memory, and extracts the ZIP members into `output_folder`.
    Returns absolute paths to all extracted files (preserving any relative
    paths inside the ZIP).

    Parameters
    ----------
    file_path : str
        Path to the base64-encoded ZIP file.
    output_folder : str
        Directory where the ZIP members are extracted.

    Returns
    -------
    list[str]
        Absolute paths to all extracted files.

    Raises
    ------
    FileNotFoundError
        If `file_path` does not exist.

    Notes
    -----
    This function does not filter for specific extensions; the next step
    will handle `.gz` → `.xml` conversion as needed.
    """
    extracted_paths = []
    if not os.path.isfile(file_path):
        raise FileNotFoundError(f"Input file does not exist: {file_path}")
    os.makedirs(output_folder, exist_ok=True)
    with open(file_path, "r") as f:
        base64_data = f.read()
    zip_bytes = base64.b64decode(base64_data)
    with zipfile.ZipFile(io.BytesIO(zip_bytes)) as z:
        for relative_file_path in z.namelist():
            z.extract(relative_file_path, output_folder)
            extracted_paths.append(
                os.path.join(output_folder, relative_file_path.lstrip("/"))
            )
    return extracted_paths


def _extract_counters_files(files_paths: list) -> list[str]:
    """
    Find and decompress GZIP-compressed XML counter files.

    Given a list of filesystem paths (as extracted from the ZIP), this function
    looks for `.gz` files, decompresses each to its `.xml` counterpart, and
    returns a list of the resulting XML file paths. The original `.gz` files
    are deleted after successful decompression.

    Parameters
    ----------
    files_paths : list
        Paths to files extracted from the ZIP.

    Returns
    -------
    list[str]
        Paths to decompressed XML files.

    Raises
    ------
    FileNotFoundError
        If any path in `files_paths` does not exist.

    Notes
    -----
    Only `.gz` files are processed. Existing `.xml` files (if any) will be
    included later by `_parse_counters_files`.
    """
    counters_xml_files_paths = []
    for file_path in files_paths:
        if not os.path.isfile(file_path):
            raise FileNotFoundError(f"Input file does not exist: {file_path}")
        if file_path.endswith(".gz"):
            xml_path = os.path.splitext(file_path)[0]
            with gzip.open(file_path, "rb") as gz_in, open(xml_path, "wb") as xml_out:
                xml_out.write(gz_in.read())
            if os.path.isfile(xml_path) and xml_path.endswith(".xml"):
                counters_xml_files_paths.append(xml_path)
                os.remove(file_path)
    return counters_xml_files_paths


def _parse_counters_files(files_paths: list) -> pd.DataFrame:
    """
    Parse all XML counter files into a single DataFrame.

    Iterates over `files_paths`, parses each `.xml` file using `_parse_counter_file`,
    and concatenates all rows into a single pandas DataFrame. Each row is a metric
    sample with timestamp, counter ID, and dimension information.

    Parameters
    ----------
    files_paths : list
        Paths to XML files containing counter data.

    Returns
    -------
    pandas.DataFrame
        Consolidated counter data from all parsed XML files.

    Raises
    ------
    FileNotFoundError
        If any XML path does not exist.

    Logging
    -------
    Emits debug logs with the number of rows parsed.
    """
    total_rows = []
    for file_path in files_paths:
        if not os.path.isfile(file_path):
            raise FileNotFoundError(f"Input file does not exist: {file_path}")
        if file_path.endswith(".xml"):
            total_rows.extend(_parse_counter_file(file_path))
    counters_data = pd.DataFrame(total_rows)
    logger.debug(
        f"Counters data has {len(counters_data)} rows after parsing counters files"
    )
    return counters_data


def _parse_counter_file(file_path: str) -> list[dict]:
    """
    Parse a single XML counter file into row dictionaries.

    Reads `<PMSetup>` blocks to extract the `startTime` and measurement
    `interval`. For each `<PMMOResult>`, it collects all `<MO>` blocks as
    dimensions (DNs). Under each `<NE-*>` section it iterates over metrics
    and yields rows with:
      - `startTime` (UTC, pandas Timestamp),
      - `interval` (string),
      - `measurementType`,
      - `neTag` (the `<NE-*>` tag name),
      - `metric` (counter ID),
      - `value` (float),
      - `dimensions` (list of DN strings).

    Parameters
    ----------
    file_path : str
        Path to the XML file.

    Returns
    -------
    list[dict]
        Parsed rows to be assembled by `_parse_counters_files`.

    Raises
    ------
    FileNotFoundError
        If `file_path` does not exist.
    """
    tree = ET.parse(file_path)
    root = tree.getroot()
    parsed = []
    for pmsetup in root.findall(".//PMSetup"):
        start_time_utc = pd.to_datetime(pmsetup.attrib.get("startTime")[:-3], utc=True)
        interval = pmsetup.attrib.get("interval")
        for pmmo in pmsetup.findall("PMMOResult"):
            # Collect dimensions (could be multiple <MO> blocks)
            dn_values = []
            for mo in pmmo.findall("MO"):
                dim = mo.attrib.get("dimension")
                if dim:
                    dn = mo.findtext("DN")
                    dn_values.append(dn)
            for meas in pmmo:
                tag = meas.tag
                if meas.tag.startswith("NE-"):
                    measurement_type = meas.attrib.get("measurementType")

                    for mea in list(meas):
                        parsed.append(
                            {
                                "startTime": start_time_utc,
                                "interval": interval,
                                "measurementType": measurement_type,
                                "neTag": tag,
                                "metric": mea.tag,
                                "value": float((mea.text or "").strip()),
                                "dimensions": dn_values,
                            }
                        )
    return parsed


def verify_kpis(
    calculation_period_start: datetime,
    calculation_period_end: datetime,
    kpis_config_data: dict,
    counters_data: pd.DataFrame,
    logs_dir: str = "/tmp",
) -> list[KpiCalculation]:
    """
    Calculate and verify configured KPIs against their targets over a time period.

    This routine orchestrates KPI verification as follows:
      1) Build a `KpiCalculation` object for each KPI name/settings found in
         `kpis_config_data`. These settings originate from the user's
         `config.py` and may override defaults from `kpi_definition.py` (target,
         dimension filters, reduction method).
      2) Improve performance by removing all counter rows whose `metric` is not
         referenced by any of the configured KPIs.
      3) For each KPI, iterate over each configured dimension-filter instance:
         - Create an empty calculation result record.
         - Compute the KPI time series via `_calculate_kpi`, which:
             • sums required counters per dimension and timestamp,
             • applies the KPI's calculation formula,
             • reduces across dimensions using either **sum** or **mean** as
               configured (per KPI or overridden in config). Use **mean** for
               ratio-based KPIs and **sum** for counts (e.g., number of UEs).
         - Compare each timestamped KPI value to the KPI target with the KPI's
           comparison operator, and mark data points **inside** the open interval
           (`calculation_period_start`, `calculation_period_end`) that are off-target.
         - Update the per-dimension calculation result with a textual summary and
           an on-target/off-target flag.
      4) If any per-dimension result is off-target and the KPI is marked mandatory,
         include that KPI in the returned list. Always log a verdict summary per KPI
         to external log file under `logs_dir`.

    Dimension Filters
    -----------------
    - Verification is performed for **every** configured KPI and for **each**
      dimension-filter group. Each outer list entry in `dimension_filters`
      represents one separate KPI calculation case.
      Each inner list (e.g., `["NRCELL-1", "NRSECTOR-1"]`) defines a set of
      dimension patterns that must all match at the same time (logical AND).
      Example:
          [["NRCELL-1", "NRSECTOR-1"], ["NRCELL-2", "NRSECTOR-2"]]
      → KPI will be calculated once for NRCELL-1/NRSECTOR-1 combination and
        once for NRCELL-2/NRSECTOR-2.

    - If a high-level filter such as `["NRCELL-"]` is used, one aggregated KPI
      is calculated across all matching dimensions. A reduction method
      (**sum** or **mean**) is then applied across the aggregated set.

    - If `reduction_method` is not explicitly defined, the default from
      `kpi_definition.py` is used.

    Time Handling
    -------------
    - `calculation_period_start` and `calculation_period_end` is converted to timezone-aware
      UTC datetimes; comparison includes timestamps strictly between these values.

    Parameters
    ----------
    calculation_period_start : datetime
        Start of the KPI verification window.
    calculation_period_end : datetime
        End of the KPI verification window.
    kpis_config_data : dict
        Mapping of KPI definition names to user-provided overrides (e.g., targets,
        dimension filters, reduction method, mandatory flag), typically loaded from
        `config.py`.
    counters_data : pandas.DataFrame
        Parsed counter samples as returned by `get_counters_data`.
    logs_dir : str, optional
        Directory used for KPI calculation results log. Defaults to `/tmp`.

    Returns
    -------
    list[KpiCalculation]
        KPIs that missed their targets (only those with any off-target results
        and marked as mandatory). The function itself does not fail a test.

    Follow-up
    ---------
    - To actively report off-target KPIs as errors in Robot logs, call
      `report_verdict_failed()` on each returned `KpiCalculation`.
    """
    kpis_verification_failed = []
    os.makedirs(logs_dir, exist_ok=True)
    calculation_period_start = _convert_time_to_utc_aware(calculation_period_start)
    calculation_period_end = _convert_time_to_utc_aware(calculation_period_end)
    kpis_to_verify = [
        KpiCalculation(kpi_definition_name, **kpi_custom_settings)
        for kpi_definition_name, kpi_custom_settings in kpis_config_data.items()
    ]
    if counters_data.empty:
        raise ValueError("Counters data is missing.")
    counters_data = _remove_unnecessary_counters(counters_data, kpis_to_verify)
    _dump_counters_to_file(counters_data, logs_dir)
    for kpi_to_verify in kpis_to_verify:
        for kpi_dimension_filter in kpi_to_verify.dimension_filters:
            kpi_to_verify.create_empty_calculation_result(kpi_dimension_filter)
            kpi_calculated_value = _calculate_kpi(
                kpi_to_verify.calculation_formula_inputs,
                kpi_to_verify.reduction_method,
                kpi_to_verify.calculation_formula,
                kpi_dimension_filter,
                counters_data,
            )
            if kpi_calculated_value.empty:
                continue
            kpi_calculated_value_adjusted = _adjust_kpi_value(
                kpi_to_verify,
                kpi_calculated_value,
                kpi_dimension_filter
            )
            kpi_values_off_target, comparision_result = (
                _compare_target_and_calculated_kpi_value(
                    kpi_to_verify.target,
                    kpi_calculated_value_adjusted,
                    kpi_to_verify.comparison_operator,
                    calculation_period_start,
                    calculation_period_end,
                )
            )
            kpi_to_verify.update_calculation_result(
                kpi_dimension_filter, comparision_result, kpi_values_off_target.empty
            )
        is_kpi_off_target = any(
            calculation_result.is_kpi_on_target is False
            for calculation_result in kpi_to_verify.calculation_results
        )
        if is_kpi_off_target and kpi_to_verify.is_mandatory:
            kpis_verification_failed.append(kpi_to_verify)
        kpi_to_verify.dump_calculation_to_file(logs_dir)
    return kpis_verification_failed


def _convert_time_to_utc_aware(timestamp: datetime) -> datetime:
    """
    Convert any datetime (naive or tz-aware) to a UTC-aware datetime.
    If naive, assume it's in the system's local timezone.
    """
    if timestamp.tzinfo is None:
        local_time_zone = tzlocal.get_localzone()
        timestamp = timestamp.replace(tzinfo=local_time_zone)
    return timestamp.astimezone(timezone.utc)


def _remove_unnecessary_counters(
    counters_data: pd.DataFrame, kpis: list[KpiCalculation]
) -> pd.DataFrame:
    """
    Prune counters to only those required by the configured KPIs.

    Builds the union of all counter IDs referenced by the KPIs' calculation
    formula inputs and filters `counters_data` to rows whose `metric` is in
    that set. This significantly reduces the volume of data processed in the
    subsequent KPI calculations.

    Parameters
    ----------
    counters_data : pandas.DataFrame
        Full counters dataset.
    kpis : list[KpiCalculation]
        KPI calculation objects whose inputs determine the required counters.

    Returns
    -------
    pandas.DataFrame
        A copy of `counters_data` filtered to required counter IDs.

    Logging
    -------
    Emits debug logs with row counts before and after pruning.
    """
    logger.debug(f"Input counters data has {len(counters_data)} rows")
    counters_ids = [
        counter
        for kpi in kpis
        for counters_list in kpi.calculation_formula_inputs.values()
        for counter in counters_list
    ]
    counters_data = counters_data[counters_data["metric"].isin(counters_ids)].copy()
    logger.debug(f"Output counters data has {len(counters_data)} rows after pruning")
    return counters_data


def _dump_counters_to_file(
    counters_data: pd.DataFrame,
    log_directory: str,
) -> None:
    """
    Dump counters DataFrame to a CSV file for future access by other scripts.

    Parameters
    ----------
    counters_data : pandas.DataFrame
        The counters DataFrame to dump to file.
    log_directory : str
        Directory path where the file should be saved.

    Raises
    ------
    OSError
        If the directory cannot be created or file cannot be written.
    ValueError
        If counters_data is empty or log_directory is invalid.
    """
    full_path = os.path.join(log_directory, "pruned_counters.csv")

    try:
        counters_data.to_csv(
            full_path,
            index=True,
            encoding='utf-8',
            float_format='%.6f'
        )
        logger.info(f"Successfully dumped rows to: {full_path}")
    except Exception as e:
        logger.error(f"Failed to dump counters data to {full_path}: {str(e)}")


def _calculate_kpi(
    calculation_formula_inputs: dict[str, list[str]],
    reduction_method: str,
    calculation_formula: Callable[..., Any],
    kpi_dimension_filter: list,
    counters_data: pd.DataFrame,
) -> pd.Series:
    """
    Calculate a KPI time series for a single dimension-filter specification.

    For each named input in `calculation_formula_inputs` (e.g., `num`, `denom`),
    this function:
      1) Calls `_sum_counters` to obtain a mapping of {dimension_path → Series}
         where each Series is the sum over the specified counter IDs per timestamp,
         after filtering rows to those matching `kpi_dimension_filter`.
      2) Aligns all inputs by dimension and applies the provided `calculation_formula`
         (from `kpi_definition.py`) per dimension to produce a KPI Series
         (e.g., ratios, throughput).
      3) Reduces across dimensions using:
         - `"sum"`: column-wise sum of per-dimension KPI Series,
         - `"mean"`: column-wise mean of per-dimension KPI Series.
         Choose `"mean"` for ratio KPIs and `"sum"` for counts, unless overridden
         in the user's configuration.

    Parameters
    ----------
    calculation_formula_inputs : dict[str, list[str]]
        Mapping of formula argument names to lists of counter IDs.
    reduction_method : str
        Either `"sum"` or `"mean"`, controlling how multiple matched dimensions
        are reduced into a single KPI series.
    calculation_formula : Callable[..., Any]
        Callable that computes the KPI from the named inputs (e.g., `num`, `denom`).
    kpi_dimension_filter : list[str]
        A single dimension-filter group, typically one inner list from the
        user's `dimension_filters` configuration (e.g.,
        ["NRCELL-1", "NRSECTOR-1"]). All listed patterns must match (AND logic).
    counters_data : pandas.DataFrame
        Dataset containing the raw counters.

    Returns
    -------
    pandas.Series
        A KPI time series indexed by timestamp. Empty if inputs are missing or
        filtering yields no data.
    """
    calculation = {}
    kpi_calculated_value = pd.Series(dtype=float)
    for formula_input_name, counters_ids in calculation_formula_inputs.items():
        counters_summed_per_dimension = _sum_counters(
            counters_data, counters_ids, kpi_dimension_filter
        )
        if not counters_summed_per_dimension:
            return kpi_calculated_value
        for dimension_path, counter_summed in counters_summed_per_dimension.items():
            if dimension_path not in calculation:
                calculation[dimension_path] = {}
            calculation[dimension_path][formula_input_name] = counter_summed
    if reduction_method == "sum":
        kpi_calculated_value = pd.concat(
            [
                calculation_formula(**calculation_inputs)
                for _, calculation_inputs in calculation.items()
            ],
            axis=1,
        ).sum(axis=1, skipna=False)
    elif reduction_method == "mean":
        kpi_calculated_value = pd.concat(
            [
                calculation_formula(**calculation_inputs)
                for _, calculation_inputs in calculation.items()
            ],
            axis=1,
        ).mean(axis=1, skipna=False)
    return kpi_calculated_value


def _sum_counters(
    counters_data: pd.DataFrame, counters_ids: list, kpi_dimension_filter: list
) -> dict[str, pd.DataFrame]:
    """
    Sum requested counters per timestamp for data matching a dimension filter.

    Processing is done in two phases:
      1) **Counter filtering:** keep only rows whose `metric` is in `counters_ids`.
         If any requested IDs are absent, an error is logged and an empty result
         is returned.
      2) **Dimension filtering:** pass the result to `_filter_data_by_dimension`
         to keep only rows whose `dimensions` match **all** patterns in the
         `kpi_dimension_filter` list. If no rows remain, an error is logged and
         an empty result is returned.

    The filtered rows are then grouped by their `dimensions` (treated as a tuple),
    pivoted into a time x metric matrix, and summed across the requested
    `counters_ids` to yield a per-timestamp Series for each distinct dimension
    path. The output is a dict mapping `dimension_path (tuple)` to Series.

    Parameters
    ----------
    counters_data : pandas.DataFrame
        Dataset containing parsed counters.
    counters_ids : list
        Counter IDs to sum.
    kpi_dimension_filter : list
        Dimension filter patterns used to select matching rows.

    Returns
    -------
    dict[str, pandas.Series]
        A mapping from dimension tuple to a Series of summed values per timestamp.
        Returns an empty dict if required counters are missing or filtering yields no rows.

    Logging
    -------
    - Logs an error if any `counters_ids` are missing in the data.
    - Logs an error if no rows match the dimension filter.

    Notes
    -----
    - This function assumes that `kpi_dimension_filter` corresponds to one
      *inner list* of the user-provided `dimension_filters`, meaning that all
      listed dimension patterns must match the same row.
    """
    output = {}
    counters_data_filtered_by_counters_ids = counters_data[
        counters_data["metric"].isin(counters_ids)
    ].copy()
    counters_ids_missing_in_counters_data = set(counters_ids) - set(
        counters_data_filtered_by_counters_ids["metric"]
    )
    if counters_ids_missing_in_counters_data:
        logger.error(
            f"Counters IDs {counters_ids_missing_in_counters_data} not found in counters data"
        )
        return output
    counters_data = _filter_data_by_dimension(
        counters_data_filtered_by_counters_ids, kpi_dimension_filter
    )
    if counters_data.empty:
        logger.error(f"No counters matches {kpi_dimension_filter} dimension filter")
        return output
    counters_data_grouped_by_dimensions = {
        key: grp.reset_index(drop=True)
        for key, grp in counters_data.groupby(
            counters_data["dimensions"].apply(tuple), sort=False
        )
    }
    for dimension, counters in counters_data_grouped_by_dimensions.items():
        pivoted_data = counters.pivot_table(
            index="startTime", columns="metric", values="value", aggfunc="sum"
        )
        output.update({dimension: pivoted_data[counters_ids].sum(axis=1)})
    return output


def _filter_data_by_dimension(
    counters_data: pd.DataFrame, kpi_dimension_filters: list
) -> pd.DataFrame:
    """
    Filter counters by matching all dimension patterns (logical AND across patterns).

    This function expands each row by exploding the `dimensions` list so that
    each DN appears on its own row. For each pattern in `kpi_dimension_filters`,
    it constructs a word-boundary regex and selects row indices whose exploded
    `dimensions` contain that pattern. The final set of matching indices is the
    intersection across all patterns (AND semantics). The original exploded rows
    corresponding to this intersection are then returned.

    Parameters
    ----------
    counters_data : pandas.DataFrame
        Input counters, expected to contain a `dimensions` list column.
    kpi_dimension_filters : list[str]
        List of dimension patterns that must all match simultaneously.
        For example, for filter group ["NRCELL-1", "NRSECTOR-1"], only rows
        whose `dimensions` contain **both** NRCELL-1 and NRSECTOR-1 will be kept.

    Returns
    -------
    pandas.DataFrame
        Subset of `counters_data` whose rows match **all** provided patterns.
        Returns an empty Series if any pattern produces zero matches.

    Notes
    -----
    - This function is used to apply the **inner list** of each
      `dimension_filters` configuration (logical AND across all items).
      `verify_kpis` iterates over the outer list, applying this filter once
      per group.
    """
    data_matching_patterns = []
    counters_data = counters_data.explode("dimensions")
    for kpi_dimension_filter in kpi_dimension_filters:
        pattern = rf"\b{kpi_dimension_filter}\b"
        data_matching_pattern = counters_data[
            counters_data["dimensions"].str.contains(pattern, na=False, regex=True)
        ].index.unique()
        data_matching_patterns.append(data_matching_pattern)
    if any(
        data_matching_pattern.empty for data_matching_pattern in data_matching_patterns
    ):
        return pd.DataFrame()
    data_matching_first_pattern = data_matching_patterns[0]
    for data_matching_next_pattern in data_matching_patterns[1:]:
        data_matching_first_pattern = data_matching_first_pattern.intersection(
            data_matching_next_pattern
        )
    return counters_data.loc[data_matching_first_pattern]


def _adjust_kpi_value(
    kpi_to_verify: KpiCalculation,
    kpi_calculated_value: pd.Series,
    kpi_dimension_filter: list
) -> pd.Series:
    """
    Adjusts KPI values before comparison with the target by applying normalization rules.
    Acts as a wrapper for adjustment functions.

    Parameters
    ------------
    kpi_to_verify : KpiCalculation
        KPI configuration object containing metadata, including the maximum allowed KPI value.
    kpi_calculated_value : pandas.Series
        Series of raw calculated KPI values to be adjusted.
    kpi_dimension_filter : list[str]
        A single dimension-filter group, typically one inner list from the
        user's `dimension_filters` configuration (e.g.,
        ["NRCELL-1", "NRSECTOR-1"]). All listed patterns must match (AND logic).

    Returns
    --------
    pandas.Series
        Adjusted (or not) KPI values depending on KPI definition.
    """
    dimension_filter = " ".join(kpi_dimension_filter)

    kpi_calculated_value = _adjust_kpi_over_max_value(
        kpi_to_verify,
        kpi_calculated_value,
        dimension_filter
    )
    return kpi_calculated_value


def _adjust_kpi_over_max_value(
    kpi: KpiCalculation,
    kpi_value: pd.Series,
    dimension_filter: str
) -> pd.Series:
    """
    Normalizes KPI values that exceed a configured maximum value by redistributing the
    excess to the previous period. Any amount over the maximum in the current period is
    shifted backwards, so the current value is capped and the excess appears in the
    previous time step.

    If max_kpi_value value in KPI definition is set to None, normalization is skipped.

    Parameters
    ------------
    kpi : KpiCalculation
        KPI configuration object providing the maximum allowed KPI value.
    kpi_value : pandas.Series
        Series of KPI values to be checked and adjusted.
    dimension_filter : A single dimension-filter group

    Returns
    --------
    pandas.Series
        KPI values after normalization
    """
    if kpi.max_kpi_value:
        if kpi_value.gt(kpi.max_kpi_value).any():
            logger.debug(
                f"{kpi.kpi_definition.id}, {dimension_filter}:\n{kpi_value}"
            )
            kpi_over_max_value = (kpi_value - kpi.max_kpi_value).clip(lower=0)
            kpi_over_max_value_shifted = kpi_over_max_value.shift(-1).fillna(0)
            kpi_value = kpi_value + kpi_over_max_value_shifted - kpi_over_max_value
            kpi_value = kpi_value.apply(lambda x: math.ceil(x) if pd.notna(x) else x).astype(float)
    return kpi_value


def _compare_target_and_calculated_kpi_value(
    target: float,
    kpi_calculated_value: pd.Series,
    comparison_operator: Callable[[float, float], bool],
    calculation_period_start: datetime,
    calculation_period_end: datetime,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """
    Compare a KPI time series to its target and flag off-target timestamps.

    Converts the KPI series to a DataFrame with columns `timestamp`, `value`,
    computes a boolean `comparison_result` by applying the KPI's operator
    (e.g., >=, <=, >, <) to compare `value` vs `target`, and selects the rows
    strictly within the open interval (`calculation_period_start`, `calculation_period_end`)
    that are off-target.

    Parameters
    ----------
    target : float
        The KPI target value (possibly overridden by user config).
    kpi_calculated_value : pandas.Series or pandas.DataFrame
        Time series of calculated KPI values indexed by timestamp.
    comparison_operator : operator
        Binary operator from the KPI definition (e.g., `operator.ge`).
    calculation_period_start : datetime
        Start of the evaluation window (UTC).
    calculation_period_end : datetime
        End of the evaluation window (UTC).

    Returns
    -------
    tuple[pandas.DataFrame, pandas.DataFrame]
        A tuple of:
          - `kpi_values_off_target`: rows within the evaluation window where
            `comparison_result` is False,
          - `comparision_result`: the full comparison table for logging/reporting.

    Notes
    -----
    - Timestamps are filtered with `inclusive="neither"`, so boundary values
      equal to start or end are excluded from evaluation.
    """
    comparision_result = kpi_calculated_value.reset_index()
    comparision_result.columns = ["timestamp", "value"]
    comparision_result["comparison_result"] = comparison_operator(
        comparision_result["value"], target
    )
    mask = comparision_result["timestamp"].between(
        calculation_period_start, calculation_period_end, inclusive="neither"
    )
    comparision_result["period_under_analyse"] = mask
    kpi_values_off_target = comparision_result[
        mask & comparision_result["comparison_result"].eq(False)
    ]
    return kpi_values_off_target, comparision_result
