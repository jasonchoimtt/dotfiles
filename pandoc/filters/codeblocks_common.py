from collections import OrderedDict


def parse_codeblock_args(elem):
    syntax = elem.classes[0] if elem.classes else ''
    args = OrderedDict(elem.attributes)

    for k, v in args.items():
        if v.lower() in ('false', 'no'):
            args[k] = False

    return syntax, args
