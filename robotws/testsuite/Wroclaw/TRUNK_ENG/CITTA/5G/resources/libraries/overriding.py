import logging
from collections.abc import Mapping
from robot.libraries.BuiltIn import BuiltIn


def override_variables(*variable_names):
    """Replaces provided variable values using their *override* counterpart

    Example:

    having in variables section

        ${DUPLEX}    TDD
        &{DUPLEX_OVERRIDE}    SBTS25R1=FDD

    ``override_variables("DUPLEX")`` will set ``DUPLEX`` to ``FDD` if executed on BTS
    software with SBTS25R1 prefix, and leave it as it is in any other case.

    Note that variable will change scope to *suite* even if value remains the same.
    """
    _bi = BuiltIn()
    all_variables = _bi.get_variables(no_decoration=True)
    # FIXME: do not require to provide enb build via `-v` command arg
    build_prefix = all_variables.get("ENB_BUILD", "").partition("_")[0]
    if not build_prefix:
        logging.warning("Variable '${ENB_BUILD}' not set. Refusing to do overrides.")
        return

    logging.debug(f"Using key {repr(build_prefix)} for overriding variables.")
    for variable in variable_names:
        value = all_variables.get(variable)
        value_map = all_variables.get(f"{variable}_OVERRIDE")

        if not value:
            raise ValueError(f"Variable '${{{variable}}}' not found.")
        if not value_map:
            raise ValueError(f"Variable '${{{variable}_OVERRIDE}}' not found.")
        if not isinstance(value_map, Mapping):
            raise ValueError(
                f"Variable '${{{variable}_OVERRIDE}}' is not a dictionary like."
            )

        logging.debug(f"Current value of ${{{variable}}} is {repr(value)}.")
        _bi.set_suite_variable(f"${variable}", value_map.get(build_prefix, value))
