import matplotlib.pyplot as plt
from datetime import datetime
import os
from vpython import *

from vpython_ui_black_white import create_scene
# from vpython_ui_green import create_scene
from fonctions_utils import update_subplot, connecting, enregistrement, enregistrement_mensuel


# fonctions_utils.py

# Vpython: affichage
positions, format_txt, dynamic_txt, led = create_scene()

# Monitoring: initialisation
index = 0
samples = []
temperature = []
humidity = []
moisture = []
water = []

now = datetime.now()
current_month = now.month
current_year = now.year

# ENREGISTREMENT
data_prototype = fr"d:\Programmation & simulation\Projets\système d'irrigation automatique\projet\projet6\data\data_prototype.csv"
fichier_prototype = open(data_prototype, "a", encoding="utf-8")
# Écrire l'en-tête s’il est vide
if os.stat(data_prototype).st_size == 0:
    fichier_prototype.write(
        "Samples,Temperature,Humidité,Humidité_sol,Consommation_eau\n")
# FIN ENREGISTREMENT

fig, ax1 = plt.subplots(2, 2, figsize=(10, 8))
fig.suptitle('Real-Time Monitoring', fontsize=16)

plt.subplot(2, 2, 1)
update_subplot(samples, temperature, 'Temperature (°C)', 'T(°C)', 'k', [0, 50])

plt.subplot(2, 2, 2)
update_subplot(samples, humidity, 'Humidity (%)', 'H(%)', 'b', [0, 100])

plt.subplot(2, 2, 3)
update_subplot(samples, moisture, 'Soil moisture (%)', 'M(%)', 'c', [0, 100])

plt.subplot(2, 2, 4)
update_subplot(samples, water, 'Consummed water(cl)', 'W(cl)', 'r', [0, 500])

plt.ion()
# ---Fin: initialisation---#

data_micro = connecting()

try:
    while True:
        while (data_micro.inWaiting() == 0):
            pass
        data_packet = data_micro.readline()
        data_packet = str(data_packet, "utf-8")
        data_packet = data_packet.strip('\r\n')
        data_packet = data_packet.split(',')

        if (len(data_packet) == 7):
            try:
                for i in range(4):
                    data_packet[i] = int(data_packet[i])

                data_pump = data_packet[5].split(':')
                waiting = int(data_packet[6])

                # affichage des données récues
                for data in data_packet:
                    print(data)
                print()

                # ---Affichage Vpython---#
                dynamic_txt["mode"].visible = False
                dynamic_txt["pump"].visible = False
                dynamic_txt["temp"].visible = False
                dynamic_txt["hum"].visible = False
                dynamic_txt["moisture"].visible = False
                dynamic_txt["water"].visible = False

                dynamic_txt["mode"] = text(text=f" {data_packet[4]}", pos=positions["mode"], align='left',
                                           height=1, depth=format_txt["depth_text"], color=format_txt["color_text"])
                dynamic_txt["pump"] = text(text=f" {data_pump[1]}", pos=positions["pump"], align='left',
                                           height=1, depth=format_txt["depth_text"], color=format_txt["color_text"])
                dynamic_txt["temp"] = text(text=f" {data_packet[0]}", pos=positions["temp"], align='center',
                                           height=1, depth=format_txt["depth_text"], color=format_txt["color_text"])
                dynamic_txt["hum"] = text(text=f" {data_packet[1]}", pos=positions["hum"], align='center',
                                          height=1, depth=format_txt["depth_text"], color=format_txt["color_text"])
                dynamic_txt["moisture"] = text(text=f" {data_packet[2]}", pos=positions["moisture"], align='center',
                                               height=1, depth=format_txt["depth_text"], color=format_txt["color_text"])
                dynamic_txt["water"] = text(text=f" {data_packet[3]}", pos=positions["water"], align='center',
                                            height=1, depth=format_txt["depth_text"], color=format_txt["color_text"])

                if waiting:
                    led.color = vector(1, 0, 0)
                else:
                    led.color = vector(0, 1, 0)
                # ---Fin Affichage Vpython---#

                # ---Affichage graphique---#
                samples.append(index)
                temperature.append(data_packet[0])
                humidity.append(data_packet[1])
                moisture.append(data_packet[2])
                water.append(data_packet[3])

                # ENREGISTREMENT
                enregistrement(fichier_prototype, samples[index], temperature[index],
                               humidity[index], moisture[index], water[index])

                plt.subplot(2, 2, 1)
                update_subplot(samples, temperature,
                               'Temperature (°C)', 'T(°C)', 'k', [0, 50])

                plt.subplot(2, 2, 2)
                update_subplot(samples, humidity, 'Humidity (%)',
                               'H(%)', 'b', [0, 100])

                plt.subplot(2, 2, 3)
                update_subplot(samples, moisture,
                               'Soil moisture (%)', 'M(%)', 'c', [0, 100])

                plt.subplot(2, 2, 4)
                update_subplot(
                    samples, water, 'Consummed water(cl)', 'W(cl)', 'r', [0, 500])

                plt.tight_layout()
                plt.pause(0.01)
                index += 1
                # ---Fin Affichage graphique---#

                now = datetime.now()
                if now.month != current_month:
                    try:
                        enregistrement_mensuel(current_month, current_year,
                                               samples, temperature, humidity, moisture, water)

                    except Exception as e:
                        print(f"Une erreur est survenue : {e}")
                    index = 0
                    samples = []
                    temperature = []
                    humidity = []
                    moisture = []
                    water = []
                    current_month = now.month

                    if now.year != current_year:
                        current_year = now.year

            except ValueError:
                continue

except KeyboardInterrupt:
    print('Exiting Program')
    os._exit()

except:
    print('Error Occurs, Exiting Program')
    os._exit()

finally:
    fichier_prototype.close()  # AJOUT : fermeture du fichier CSV
    plt.ioff()
    plt.show()
    data_micro.close()
