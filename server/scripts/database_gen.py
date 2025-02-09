import geopandas as gpd
from pymongo import MongoClient
from pyproj import Transformer

myclient = MongoClient("localhost", 27017)
transformer = Transformer.from_crs("EPSG:32198", "EPSG:4326", always_xy=True)

data = myclient.dev
storage = data.create_collection("my_collection")

# storage.insert_one({"test": "wtf"})
# huh = storage.find_one({"test": "wtf"})


def process_geo(geometry, fish):
    geo = list(geometry.geoms)
    for region in geo:
        points = []
        for x, y in list(region.exterior.coords):
            lon, lat = transformer.transform(x, y)
            points.append([lon, lat])
        database_entry = {"type": "region", "fish": fish, "points": points}

        storage.insert_one(database_entry)
        print("New database entry")

        print("- - - - - - - - - - - - - - - - - -")
    print("***************************************")


def process_row(row):
    entry_databases = {"type": "fish"}

    for key, value in row.items():
        if key != "geometry":
            entry_databases[key] = value

    storage.insert_one(entry_databases)
    process_geo(row["geometry"], row["NOM_SCIENT"])


if __name__ == "__main__":
    # gdf = gpd.read_file("./data/Aires_repartition_poisson_eau_douce.geojson")
    # gdf.apply(lambda row: process_row(row), axis=1)
    print(storage.count_documents(filter={"type": "fish"}))
    print(storage.count_documents(filter={"type": "region"}))
    print(storage.count_documents(filter={}))
