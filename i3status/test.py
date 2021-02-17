import json


class Block(object):

    full_text = ""
    separator = False
    separator_block_width = 0
    border = "#000000"
    border_left = 0
    border_right = 0
    border_top = 2
    border_bottom = 2
    color = "#FFD180"
    background = "#000000"

    def json_render(self):
        return json.dumps({
            member[0]: member[1]
            for member in inspect.getmembers(self)
            if not member[0].startswith('__') and \
               member[1] and \
               not callable(member[1])
        })


class Separator(Block):

    full_text = ''
