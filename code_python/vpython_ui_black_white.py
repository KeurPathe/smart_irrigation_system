from vpython import *

# ---InitVpython---#


def create_scene():
    # cadre
    scene.height = 400
    scene.width = 600

    length_box = 20
    height_box = 8
    deep_box = 1.2
    box_thick = 0.2
    box_color = vector(150/255, 200/255, 255/255)
    front_color = vector(0/255, 0/255, 0/255)
    box_opacity = 1
    front_opacity = 0.4

    place_text = 0.5*deep_box/2
    format_txt = {"color_text": vector(1, 1, 1), "depth_text": 0.2}

    # bottom_box
    box(size=vector(length_box, box_thick, deep_box),
        pos=vector(0, -height_box/2, 0),
        color=box_color, opacity=box_opacity)
    # top_box
    box(size=vector(length_box, box_thick, deep_box),
        pos=vector(0, height_box/2, 0),
        color=box_color, opacity=box_opacity)
    # left_box
    box(size=vector(box_thick, height_box, deep_box),
        pos=vector(-length_box/2, 0, 0),
        color=box_color, opacity=box_opacity)
    # right_box
    box(size=vector(box_thick, height_box, deep_box),
        pos=vector(length_box/2, 0, 0),
        color=box_color, opacity=box_opacity)
    # back_box
    box(size=vector(length_box, height_box, box_thick),
        pos=vector(0, 0, -deep_box/2),
        color=box_color, opacity=box_opacity)
    # front_box
    box(size=vector(length_box, height_box, box_thick),
        pos=vector(0, 0, deep_box/2),
        color=front_color, opacity=front_opacity)
    # background_box
    box(size=vector(length_box, height_box, box_thick/2),
        pos=vector(0, 0, box_thick/3),
        color=vector(0, 0, 0), opacity=0.95)

    # Positions des textes
    positions = {
        "mode": vector(-length_box/2 + 5, height_box/2 - 2, place_text),
        "pump": vector(length_box/2 - 5, height_box/2 - 2, place_text),
        "temp": vector(-length_box/2 + 5, height_box/2 - height_box/3 - 2, place_text),
        "hum": vector(length_box/2 - 5, height_box/2 - height_box/3 - 2, place_text),
        "moisture": vector(-length_box/2 + 5, -height_box/2 + height_box/3 - 2, place_text),
        "water": vector(length_box/2 - 5, -height_box/2 + height_box/3 - 2, place_text)
    }

    text(text="MODE :              ", pos=positions["mode"], align='right', height=1,
         depth=format_txt["depth_text"], color=format_txt["color_text"])
    text(text="PUMP :             ", pos=positions["pump"], align='right', height=1,
         depth=format_txt["depth_text"], color=format_txt["color_text"])
    text(text="T :     °C", pos=positions["temp"], align='center', height=1,
         depth=format_txt["depth_text"], color=format_txt["color_text"])
    text(text="H :       %", pos=positions["hum"], align='center', height=1,
         depth=format_txt["depth_text"], color=format_txt["color_text"])
    text(text="M :       %", pos=positions["moisture"], align='center', height=1,
         depth=format_txt["depth_text"], color=format_txt["color_text"])
    text(text="W :          cl", pos=positions["water"], align='center', height=1,
         depth=format_txt["depth_text"], color=format_txt["color_text"])

    # Valeurs dynamiques
    dynamic_txt = {
        "mode": text(text=" ___", pos=positions["mode"], align='left', height=1, depth=format_txt["depth_text"], color=format_txt["color_text"]),
        "pump": text(text=" ___", pos=positions["pump"], align='left', height=1, depth=format_txt["depth_text"], color=format_txt["color_text"]),
        "temp": text(text=" __", pos=positions["temp"], align='center', height=1, depth=format_txt["depth_text"], color=format_txt["color_text"]),
        "hum": text(text=" __", pos=positions["hum"], align='center', height=1, depth=format_txt["depth_text"], color=format_txt["color_text"]),
        "moisture": text(text=" __", pos=positions["moisture"], align='center', height=1, depth=format_txt["depth_text"], color=format_txt["color_text"]),
        "water": text(text=" ___", pos=positions["water"], align='center', height=1, depth=format_txt["depth_text"], color=format_txt["color_text"])
    }

    # voyant indiquant l'autorisation d'irriger
    base_radius = 1
    base_height = 0.3
    base_pos = vector(0, height_box/2 + 1.5, -deep_box/4)
    base_color = vector(1, 1, 1)
    # base_cylinder
    cylinder(length=base_height, radius=base_radius,
             pos=base_pos, color=base_color, axis=vector(0, 0, 1), opacity=0.5)

    led_radius = 0.7
    led_height = 0.2
    led_pos = base_pos
    led_color = vector(1, 1, 1)
    led = cylinder(length=led_height, radius=led_radius,
                   pos=led_pos, color=led_color, axis=vector(0, 0, 1), opacity=1)

    # box voyant
    height_box_led = 2*base_radius + 0.8
    # bottom_box
    box(size=vector(length_box, box_thick, deep_box),
        pos=vector(0, height_box/2 + 0.1, 0),
        color=box_color, opacity=box_opacity)
    # top_box
    box(size=vector(length_box, box_thick, deep_box),
        pos=vector(0, height_box/2 + height_box_led, 0),
        color=box_color, opacity=box_opacity)
    # left_box
    box(size=vector(box_thick, height_box_led, deep_box),
        pos=vector(-length_box/2, height_box/2 + height_box_led/2, 0),
        color=box_color, opacity=box_opacity)
    # right_box
    box(size=vector(box_thick, height_box_led, deep_box),
        pos=vector(length_box/2, height_box/2 + height_box_led/2, 0),
        color=box_color, opacity=box_opacity)
    # back_box
    box(size=vector(length_box, height_box_led, box_thick),
        pos=vector(0, height_box/2 + height_box_led/2, -deep_box/2),
        color=box_color, opacity=box_opacity)
    # front_box
    box(size=vector(length_box, height_box_led, box_thick),
        pos=vector(0, height_box/2 + height_box_led/2, deep_box/2),
        color=front_color, opacity=0.1)

    return positions, format_txt, dynamic_txt, led
