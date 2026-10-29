from robot.api import logger
import xml.etree.ElementTree as ET


def checking_tls_pcap_messages(xml_file, tls_version):
    """
    Sprawdza, czy plik PDML (np. tls.xml) zawiera wszystkie
    kluczowe komunikaty handshake TLS1.2.
    """
    if tls_version == "1_2":
        required_messages = [
            "Client Hello",
            "Server Hello",
            "Certificate",
            "Server Key Exchange",
            "Server Hello Done",
            "Application Data"
        ]

    elif tls_version == "1_3":
        required_messages = [
            "Client Hello",
            "Server Hello",
            "Change Cipher Spec",
            "Application Data"
        ]

    found_messages = set()
    sequence = []

    tree = ET.parse(xml_file)
    root = tree.getroot()

    # przeszukujemy wszystkie elementy <field ... showname="...">
    for field in root.iter("field"):
        showname = field.get("showname", "")
        for msg in required_messages:
            if msg in showname:
                sequence.append(msg)
                found_messages.add(msg)

    missing = [m for m in required_messages if m not in found_messages]
    if missing:
        raise AssertionError(
            f"Brakuj?ce komunikaty TLS 1.2 w PCAP: {', '.join(missing)}"
        )

    idx = 0
    for msg in sequence:
        if idx < len(required_messages) and msg == required_messages[idx]:
            idx += 1
    if idx < len(required_messages):
        raise AssertionError(f"Komunikaty TLS1.2 wystepuja ale w zlej kolejnosc. "
                             f"Oczekiwano: {required_messages}, znaleziono: {sequence}")
