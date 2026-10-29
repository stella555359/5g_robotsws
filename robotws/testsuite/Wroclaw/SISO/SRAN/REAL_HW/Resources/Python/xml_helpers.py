import xml.etree.ElementTree as ET
from robot.api.deco import keyword


class DNNotFoundError(Exception):
    pass


class RangeNotFoundError(Exception):
    pass


@keyword(name='Find Temperature Range By RMOD Distname')
def find_temperature_range_by_rmod_distname(file_path, dn_partial_value):
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()

        result = {}
        dn_found = False
        range_found = False

        for pmmoresult in root.findall('.//PMMOResult'):
            mo = pmmoresult.find('.//MO')
            if mo is not None:
                dn = mo.find('.//DN')
                if dn is not None:
                    dn_text = dn.text

                    if dn_partial_value in dn_text:
                        dn_found = True
                        ne_wbts = pmmoresult.find('.//NE-WBTS_1.0')
                        if ne_wbts is not None:
                            measurement_type = ne_wbts.get('measurementType')

                            if measurement_type == "SBTS_RMOD_TEMPERATURE":
                                for i in range(7):
                                    tag = f'SBTS_RMOD_TEMP_RANGE{i}_SAMPLES'
                                    element = ne_wbts.find(tag)
                                    if element is not None:
                                        result[f'RANGE{i}'] = int(element.text)
                                        range_found = True
                                    else:
                                        result[f'RANGE{i}'] = 0

        if not dn_found:
            raise DNNotFoundError(f"DN containing '{dn_partial_value}' not found in the XML file.")

        if not range_found:
            raise RangeNotFoundError("No RANGE fields found in the XML file.")

        return result
    except ET.ParseError as e:
        raise DNNotFoundError(f"Error parsing XML: {e}")
    except DNNotFoundError as e:
        raise e
    except RangeNotFoundError as e:
        raise e
