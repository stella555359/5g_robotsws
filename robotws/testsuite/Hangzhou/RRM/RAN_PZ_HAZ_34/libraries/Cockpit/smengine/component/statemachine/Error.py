class StateMachineError:
    (NO_ERROR,
     NOT_INIT,
     EVENT_ALREADY_EXIST,
     SM_FILE_ERROR,
     SM_NOT_VALID,
     SM_ALREADY_EXIST,
     INIT_ALREADY_DONE,
     CHECK_PYTHON_ERROR,
     END_OF_ENUM) = range(9)
