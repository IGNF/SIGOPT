package fr.laburba.sigopt.export;

import java.util.Set;

import com.vividsolutions.jts.geom.Point;

import fr.ign.cogit.geoxygene.api.feature.IFeature;
import fr.ign.cogit.geoxygene.api.feature.IFeatureCollection;
import fr.ign.cogit.geoxygene.api.spatial.coordgeom.IDirectPositionList;
import fr.ign.cogit.geoxygene.feature.DefaultFeature;
import fr.ign.cogit.geoxygene.feature.FT_FeatureCollection;
import fr.ign.cogit.geoxygene.spatial.coordgeom.DirectPosition;
import fr.ign.cogit.geoxygene.spatial.coordgeom.DirectPositionList;
import fr.ign.cogit.geoxygene.spatial.coordgeom.GM_LineString;
import fr.ign.cogit.geoxygene.util.attribute.AttributeManager;
import fr.ign.cogit.geoxygene.util.conversion.ShapefileWriter;
import fr.laburba.sigopt.loader.input.CoordinateMatrix;
import fr.laburba.sigopt.loader.input.DistanceMatrix;
import fr.laburba.sigopt.loader.input.DistanceMatrix.Couple;

/**
 * Class that enables the export of the graph from a Distance Matrix. It may
 * includes trash information located on the edges of the graph
 * 
 * 
 * 
 * @author mickael brasebin
 *
 */
public class EdgeExporter {

	public final static String NAME_ATT_COST = "Distance";
	public final static String NAME_ATT_TRASHQUANT = "Trash";

	/**
	 * Export with the only DistanceMatrix
	 * 
	 * @param dm
	 */
	public static void export(CoordinateMatrix cM, DistanceMatrix dm, String fileName) {

		export(cM, dm, null, fileName);
	}

	/**
	 * Export with both DistanceMatrix and TrahashMatrix
	 * 
	 * @param dm
	 * @param trashMatrix
	 */
	public static void export(CoordinateMatrix cM, DistanceMatrix dm, DistanceMatrix trashMatrix, String fileName) {

		Set<Couple> c = dm.getDistanceTab().keySet();
		IFeatureCollection<IFeature> featColl = new FT_FeatureCollection<>();

		for (Couple cTemp : c) {
			Double d = dm.getDistanceTab().get(cTemp);

			if (d <= 0) {
				continue;
			}

			Double q = -1.0;

			if (trashMatrix != null) {
				q = trashMatrix.getDistance(cTemp);
			}

			Point pt1 = cM.getPoint(cTemp.getId1());
			Point pt2 = cM.getPoint(cTemp.getId2());

			IDirectPositionList dpl = new DirectPositionList();
			dpl.add(new DirectPosition(pt1.getX(), pt1.getY()));
			dpl.add(new DirectPosition(pt2.getX(), pt2.getY()));

			IFeature feat = new DefaultFeature(new GM_LineString(dpl));
			AttributeManager.addAttribute(feat, NAME_ATT_COST, d, "Double");

			if (q >= 0) {
				AttributeManager.addAttribute(feat, NAME_ATT_TRASHQUANT, q, "Double");
			}

			featColl.add(feat);
		}

		ShapefileWriter.write(featColl, fileName);

	}
}
