import json
import os
from esp32 import NVS


def save(key, value, namespace='Eeprom'):
    nvs = NVS(namespace)
    json_str = json.dumps(value)
    nvs.set_blob(key, json_str)

    # don't forget to commit
    nvs.commit()


def load(key, default=None, namespace='Eeprom'):
    nvs = NVS(namespace)
    buf = bytearray(1000)

    try:
        nvs.get_blob(key, buf)
        value = json.loads(buf)
        return value
    except Exception as _:
        if default is None:
            raise ValueError()
        return default
