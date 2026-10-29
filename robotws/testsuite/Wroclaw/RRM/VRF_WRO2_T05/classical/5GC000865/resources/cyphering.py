import pyshark


def get_nea(path, display_filter):
    cap = pyshark.FileCapture(path, display_filter=display_filter)
    return cap[0]
