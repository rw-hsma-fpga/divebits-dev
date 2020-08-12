import DiveBits_base

import importlib


def DiveBits_factory(component: dict): # return correct subclass

    db_type = component["DB_TYPE"] # add check/error
    if db_type not in DiveBits_base.db_types:
        raise SyntaxError('DiveBits ERROR: Unknown DB_TYPE')

    classname = DiveBits_base.db_types[db_type]
    classtype = getattr(importlib.import_module(classname), classname)
    inst = classtype()

    return inst
