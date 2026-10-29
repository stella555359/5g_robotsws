import pandas as pd
import logging

vlogger = logging.getLogger("vlogger")

# Core Error Handler


def handle_error(message, on_error="exit", logger=None, also_print=True):
    error_msg = f"[RETRIEVAL ERROR] {message}"

    if logger:
        logger.error(error_msg)
    if also_print or not logger:
        print(error_msg)

    if on_error == "exit":
        import sys

        sys.exit(1)
    elif callable(on_error):
        on_error(message)
    elif on_error == "continue":
        notice = "[RETRIEVAL NOTICE] Continuing execution despite error"
        if logger:
            logger.warning(notice)
        if also_print or not logger:
            print(notice)


# Safe .iloc Access
def safe_iloc(
    df,
    row_idx=0,
    col=None,
    default=None,
    on_error="exit",
    logger=vlogger,
    also_print=True,
    error_message=None,
):
    try:
        row = df.iloc[row_idx]
        if col and col not in row:
            raise KeyError(f"Column '{col}' not found in row at index {row_idx}")
        return row[col] if col else row
    except Exception as e:
        msg = error_message or f"safe_iloc failed: {e}"
        handle_error(msg, on_error, logger, also_print)
        return default


# Safe Dictionary Access
def safe_dict_get(
    d,
    key,
    default=None,
    on_error="exit",
    logger=vlogger,
    also_print=True,
    error_message=None,
):
    try:
        if not isinstance(d, dict):
            raise TypeError(f"Expected dict, got {type(d).__name__}")
        if key not in d:
            raise KeyError(f"Key '{key}' not found in dictionary")
        return d[key]
    except Exception as e:
        msg = error_message or f"safe_dict_get failed: {e}"
        handle_error(msg, on_error, logger, also_print)
        return default


# Safe DataFrame Creation
def safe_dataframe(
    data,
    columns=None,
    on_error="exit",
    logger=vlogger,
    also_print=True,
    error_message=None,
):
    try:
        df = pd.DataFrame(data)
        if columns:
            missing = [col for col in columns if col not in df.columns]
            for col in missing:
                df[col] = None
            df = df[columns]
        return df
    except Exception as e:
        msg = error_message or f"safe_dataframe failed: {e}"
        handle_error(msg, on_error, logger, also_print)
        return pd.DataFrame(columns=columns or [])


# Safe Column Retrieval from Row
def safe_row_get(
    row,
    col,
    default=None,
    strip=False,
    on_error="exit",
    logger=vlogger,
    also_print=True,
    error_message=None,
):
    try:
        if col not in row:
            raise KeyError(f"Column '{col}' not found in row")
        val = row[col]
        return val.strip() if strip and isinstance(val, str) else val
    except Exception as e:
        msg = error_message or f"safe_row_get failed: {e}"
        handle_error(msg, on_error, logger, also_print)
        return default


# Safe Filtering
def safe_filter(
    df,
    condition_fn,
    default=None,
    on_error="exit",
    logger=vlogger,
    also_print=True,
    error_message=None,
):
    try:
        filtered = df[condition_fn(df)]
        if filtered.empty:
            raise ValueError("Filter returned empty DataFrame")
        return filtered
    except Exception as e:
        msg = error_message or f"safe_filter failed: {e}"
        handle_error(msg, on_error, logger, also_print)
        return default


# Safe First Row Column Access
def safe_first_row_col(
    df,
    col,
    default=None,
    strip=False,
    on_error="exit",
    logger=vlogger,
    also_print=True,
    error_message=None,
):
    row = safe_iloc(
        df,
        0,
        default={},
        on_error=on_error,
        logger=logger,
        also_print=also_print,
        error_message=error_message,
    )
    return safe_row_get(
        row,
        col,
        default=default,
        strip=strip,
        on_error=on_error,
        logger=logger,
        also_print=also_print,
        error_message=error_message,
    )


# Safe Match Retrieval
def safe_match(
    df,
    condition_fn,
    col=None,
    default=None,
    strip=False,
    on_error="exit",
    logger=vlogger,
    also_print=True,
    error_message=None,
):
    try:
        match = df[condition_fn(df)]
        if match.empty:
            raise ValueError("No matching rows found")
        if col:
            row = match.iloc[0]
            if col not in row:
                raise KeyError(f"Column '{col}' not found in matched row")
            val = row[col]
            return val.strip() if strip and isinstance(val, str) else val
        return match
    except Exception as e:
        msg = error_message or f"safe_match failed: {e}"
        handle_error(msg, on_error, logger, also_print)
        return default
