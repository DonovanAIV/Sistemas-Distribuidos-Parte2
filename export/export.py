from pymongo import MongoClient
import csv

# Conexión mongdb
uri = "mongodb://admin:admin123@localhost:27017/"
client = MongoClient(uri)
db = client["info"]
coleccion = db["eventos"]

with open("./data/data.csv", "w", newline='', encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["uuid", "type", "city", "pubMillis", "street", "x", "y"])

    for alerta in coleccion.find():
        city = alerta.get("city", "")
        if isinstance(city, dict):
            city_name = city.get("name", "")
        else:
            city_name = city

        writer.writerow([
            alerta.get("uuid", ""),
            alerta.get("type", ""),
            city_name,
            alerta.get("pubMillis", ""),
            alerta.get("street", ""),
            alerta.get("location", {}).get("x", ""),
            alerta.get("location", {}).get("y", "")
        ])