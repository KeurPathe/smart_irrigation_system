import matplotlib.pyplot as plt
import serial
import time
from datetime import datetime
import csv


def update_subplot(x, y, title, ylabel, color, ylim):
    plt.cla()
    plt.grid(True)
    plt.ylim(ylim)
    plt.title(title)
    plt.ylabel(ylabel)
    plt.plot(x, y, color)


def connecting():
    # Open Serial Port
    data_micro = serial.Serial('COM1', baudrate=9600, timeout=10, parity=serial.PARITY_NONE,
                               stopbits=serial.STOPBITS_ONE,
                               bytesize=serial.EIGHTBITS
                               )

    time.sleep(1)
    return data_micro


def enregistrement(fichier, data1, data2, data3, data4, data5):
    # ENREGISTREMENT
    donnee = f"{data1},{data2},{data3},{data4},{data5}\n"
    fichier.write(donnee)
    fichier.flush()
    # print("Enregistré :", fichier_prototype.strip())
    # FIN ENREGISTREMENT


def enregistrement_mensuel(current_month, current_year, data1, data2, data3, data4, data5):
    files_name = f"{current_year}_{current_month:02d}.csv"
    files_path = fr"d:\Programmation & simulation\Projets\système d'irrigation automatique\projet\projet6\data\{files_name}"
    with open(files_path, mode="w", newline="", encoding="utf-8") as fichier:
        writer = csv.writer(fichier)
        writer.writerow(
            ["samples", "Temperature", "Humidity", "Moisture", "Water_consummed"])
        for i in range(len(data1)):
            writer.writerow(
                [data1[i], data2[i], data3[i], data4[i], data5[i]])
    print(f"Data successfull saved in {files_path}")
