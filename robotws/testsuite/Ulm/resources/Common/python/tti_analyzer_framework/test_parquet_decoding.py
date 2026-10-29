import argparse
import logging
import pathlib
import shutil
import sys
import time

import numpy as np
import pandas as pd

import testsuite.Ulm.resources.Common.python.tti_analyzer_framework.tti_dataframe as tti_dataframe

logging.basicConfig(level=logging.INFO, format="%(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

DL_EVENTS: list[str] = [
    "dlHarqRxDataArray",
    "dlLaDeltaCqiArray",
    "dlFdSchedData",
    "dlSCellActivationData",
    "dlFdSchedAdditionalData",
    "dlRemoteSCellOHDeactivationData",
]
UL_EVENTS: list[str] = [
    "ulHarqRxData",
    "ulFdSchedData",
    "ulLaDeltaSinr",
    "ulSCellActivationData",
    "ulFdSchedAdditionalData",
]
COMMON_COLUMNS: list[str] = [
    "timeStamp",
    "hfnTickCount",
    "hfn_sfn_slot",
    "sfn",
    "slot",
    "rnti",
    "lcrId",
    "physCellId",
    "emCoreId",
]


def cleanup_decoder_outputs(trace_file: pathlib.Path) -> None:
    patterns = (
        f"{trace_file.stem}_*_parqCsv_*.csv",
        f"{trace_file.stem}_parqCsv_*.csv",
        f"parq_{trace_file.stem}_*.db",
    )
    for pattern in patterns:
        for file_path in trace_file.parent.glob(pattern):
            try:
                file_path.unlink()
            except OSError as exc:
                logger.debug("Could not remove %s: %s", file_path, exc)
    shutil.rmtree(trace_file.parent / "parq", ignore_errors=True)


def decode_trace(trace_file: pathlib.Path) -> pd.DataFrame:
    start = time.perf_counter()
    cleanup_decoder_outputs(trace_file)
    df = tti_dataframe.convert_tti_trace_to_df(tti_pcap_file=str(trace_file), events_list=DL_EVENTS + UL_EVENTS)
    df.to_pickle(trace_file.with_name(f"{trace_file.stem}_decoded.pkl"))
    logger.info("Decode finished in %.3fs (shape=%s)", time.perf_counter() - start, df.shape)
    return df


def filter_by_event_group(df: pd.DataFrame, event_names: list[str]) -> pd.DataFrame:
    event_cols = [c for c in df.columns if any(e in c for e in event_names)]
    if not event_cols:
        return df.iloc[:0]
    cols = list(dict.fromkeys([c for c in COMMON_COLUMNS if c in df.columns] + event_cols))
    return df.loc[:, cols]


def compare_frames(df_new: pd.DataFrame, backup_path: pathlib.Path,
                   label: str,
                   rtol: float = 1e-5,
                   atol: float = 1e-8,
                   ) -> bool:
    if not backup_path.exists():
        raise FileNotFoundError(f"Backup pickle not found: {backup_path}")
    df_ref = pd.read_pickle(backup_path)
    lines = [f"[{label}] new={df_new.shape} backup={df_ref.shape}"]
    report_path = backup_path.parent / f"comparison_report_{backup_path.stem}.txt"

    if len(df_new) < len(df_ref):
        lines.append(f"FAIL rows: new has fewer rows ({len(df_new)} < {len(df_ref)})")
        report_path.write_text("\n".join(lines) + "\n")
        logger.info("%s comparison report: %s", label, report_path)
        return False

    missing = sorted(set(df_ref.columns) - set(df_new.columns))
    if missing:
        lines.append(f"FAIL columns: missing {len(missing)} backup columns")
        lines.extend(f"  - {c}" for c in missing[:30])
        report_path.write_text("\n".join(lines) + "\n")
        logger.info("%s comparison report: %s", label, report_path)
        return False

    left = df_new[df_ref.columns].iloc[: len(df_ref)].reset_index(drop=True)
    right = df_ref.reset_index(drop=True)
    dtype_mismatch = [c for c in right.columns if left[c].dtype != right[c].dtype]
    if dtype_mismatch:
        lines.append(f"FAIL dtypes: {len(dtype_mismatch)} mismatches")
        lines.extend(f"  - {c}: {left[c].dtype} != {right[c].dtype}" for c in dtype_mismatch[:30])

    value_mismatch = []
    for col in right.columns:
        a, b = left[col], right[col]
        if pd.api.types.is_numeric_dtype(a) and pd.api.types.is_numeric_dtype(b):
            if not np.isclose(np.asarray(a), np.asarray(b), rtol=rtol, atol=atol, equal_nan=True).all():
                value_mismatch.append(col)
        elif not a.equals(b):
            value_mismatch.append(col)
    if value_mismatch:
        lines.append(f"FAIL values: {len(value_mismatch)} differing columns")
        lines.extend(f"  - {c}" for c in value_mismatch[:30])

    passed = not dtype_mismatch and not value_mismatch
    lines.append("PASS" if passed else "FAIL")
    report_path.write_text("\n".join(lines) + "\n")
    logger.info("%s comparison report: %s", label, report_path)
    logger.info("%s comparison %s", label, "PASSED" if passed else "FAILED")
    return passed


def first_non_indexed_pcap(trace_dir: pathlib.Path) -> pathlib.Path:
    match = next((f for f in trace_dir.glob("*.pcap") if not f.stem or not f.stem[-1].isdigit()), None)
    if match is None:
        raise FileNotFoundError(f"No base pcap found in {trace_dir}")
    return match


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--trace-dir", default="/home/ute/personal/hirzel/test_data")
    args = parser.parse_args()

    trace_dir = pathlib.Path(args.trace_dir)
    trace_file = first_non_indexed_pcap(trace_dir)
    df = decode_trace(trace_file)
    dl_ok = compare_frames(
        filter_by_event_group(df, event_names=DL_EVENTS),
        backup_path=trace_dir / "ttitrace_streaming_dl_backup.pkl",
        label="DL",
    )
    ul_ok = compare_frames(
        filter_by_event_group(df, event_names=UL_EVENTS),
        backup_path=trace_dir / "ttitrace_streaming_ul_backup.pkl",
        label="UL",
    )
    if dl_ok and ul_ok:
        logger.info("All validations PASSED.")
    else:
        logger.error("Some validations FAILED. See comparison reports.")
        sys.exit(1)
