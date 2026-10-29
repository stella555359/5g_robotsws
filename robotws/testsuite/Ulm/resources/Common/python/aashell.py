from typing import Union


def extract_domain_from_rad(rad_id: Union[int, str]) -> str:
    """
    Extrahiert die ersten vier Zeichen (vermutlich den Domain-Teil) aus einer RAD-ID.

    Wenn die rad_id ein Integer ist, wird sie zuerst in eine Hexadezimaldarstellung umgewandelt.
    Anschließend werden die ersten vier Zeichen der resultierenden String-Darstellung zurückgegeben.

    Args:
        rad_id (Union[int, str]): Die RAD-ID, entweder als Integer oder als String.

    Returns:
        str: Die ersten vier Zeichen der (potenziell in Hex umgewandelten) RAD-ID.
             Beachten Sie, dass dies bei Integer-Eingaben wie 10 (hex '0xa') '0xa' zurückgeben würde.
             Wenn die Absicht ist, die ersten zwei *Hex-Ziffern* nach '0x' zu erhalten,
             müsste die Logik angepasst werden (z.B. `rad_id[2:4]` nach der Konvertierung).
             Die aktuelle Implementierung gibt `(str(rad_id))[0:4]` zurück.
    """
    if isinstance(rad_id, int):
        # Konvertiert den Integer in eine Hexadezimal-String-Darstellung (z.B. 10 -> '0xa')
        rad_id_str = hex(rad_id)
    else:
        # Wenn es bereits ein String ist, verwenden wir ihn direkt
        rad_id_str = rad_id

    # Gibt die ersten vier Zeichen des Strings zurück.
    # Beachten Sie den Kommentar in der Docstring bezüglich der Interpretation.
    return rad_id_str[0:4]
