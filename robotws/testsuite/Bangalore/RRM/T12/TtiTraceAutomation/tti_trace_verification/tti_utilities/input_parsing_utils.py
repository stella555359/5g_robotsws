import re


def is_ip_address(segment: str) -> bool:
    return re.match(r"^\d{1,3}(\.\d{1,3}){3}$", segment) is not None


def is_hostname(segment: str) -> bool:
    return re.match(r"^[a-zA-Z0-9.-]+$", segment) is not None


def classify_path(path: str) -> str:
    # Normalize slashes for consistent parsing
    normalized = path.replace("\\", "/").strip()

    # Check for network path: starts with // or \\ and followed by IP or hostname
    if normalized.startswith("//") or path.startswith("\\\\"):
        parts = normalized.lstrip("/").split("/")
        if parts and (is_ip_address(parts[0]) or is_hostname(parts[0])):
            return "network"

    # Check for system path: Windows (C:\...) or Linux (/...)
    if re.match(r"^[a-zA-Z]:[\\/]", path):  # Windows drive letter
        return "system"
    if normalized.startswith("/"):  # Linux absolute path
        return "system"

    # Fallback
    return "unknown"
