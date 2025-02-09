import { collection } from './db_helper';
import { Polygon, Point } from "geojson";
import * as  turf from '@turf/turf';

class RegionInformations {
    private regions;

    public constructor() {
        this.regions = [];
    }

    async setup() {
        const cursor = await collection.find({ 'type': 'region' }).toArray();
        cursor.forEach(doc => {
            this.regions.push({name: doc.fish, polygon: turf.multiPolygon(doc.points)})
        });
    }

    public find_points(lon, lat) {
        const position = turf.point([lon, lat]);
        return this.regions.find(region =>
            turf.booleanPointInPolygon(position, region.polygon)
          );
    }
}

const regionInformations = new RegionInformations();
regionInformations.setup().then();
export { regionInformations }