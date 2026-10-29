from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.resources.log.log import blog

attenuator = Attenuator(with_initialisation=False)


@logged_keyword
def initialise_attenuator():
    attenuator.initialise_attenuator()


@logged_keyword
def set_attenuation(value_string, port=None, confirm=True, attenuator_id=None):
    try:
        attenuator.set_attenuation(value_string, port, confirm, attenuator_id)
    except ValueError as e:
        blog(e, level='ERROR')


@logged_keyword
def gradually_increase_attenuation(init_value=0, max_value=90, step=1, interval=0.2, port=None, attenuator_id=None):
    attenuator.gradually_increase_attenuation(init_value, max_value, step, interval, port, attenuator_id)


@logged_keyword
def gradually_decrease_attenuation(init_value=35, min_value=0, step=1, interval=0.2, port=None, attenuator_id=None):
    attenuator.gradually_decrease_attenuation(init_value, min_value, step, interval, port, attenuator_id)


@logged_keyword
def nullify_attenuation_on_all_ports():
    attenuator.nullify_attenuation_on_all_ports()


@logged_keyword
def attenuate_all_ports():
    attenuator.attenuate_all_ports()


@logged_keyword
def release_attenuator():
    attenuator.release_attenuator()
