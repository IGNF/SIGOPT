package fr.laburba.sigopt.export;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;

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

/**
 * Transformation of path file into GIS File
 * 
 * @author mickael brasebin
 *
 */
public class PathExporter {

	public final static String NAME_ATT_COST = "Distance";
	public final static String NAME_PATH_SECT_ID = "Sect_id";
	public final static String NAME_TRASH_REM = "Trash_rem";

	/**
	 * 
	 * @param cM
	 *            : CoordinateMatrix
	 * @param dm
	 *            : distanceMatrix
	 * @param pathFile
	 *            : file that contains the different paths
	 * @param removeFile
	 *            : optionnal file that indicates when trash are removed or not
	 * @param fileOut
	 *            : written shapefile
	 */
	public static void exportPath(CoordinateMatrix cM, DistanceMatrix dm, File pathFile, File removeFile,
			String fileOut) throws Exception {

		IFeatureCollection<IFeature> featC = new FT_FeatureCollection<>();
		// We get information about path and removed edges
		String[] tabPath = generatePath(pathFile);
		String[] tabRemove = null;
		// It is optionnal
		if (removeFile != null) {
			tabRemove = generatePath(removeFile);
		}

		// We detect if we are at a desposit place if it does not move so we
		// keep previous id
		int previousId = Integer.parseInt(tabPath[0]);
		Point preivousCoord = cM.getPoint(previousId);

		// id for a path section between two desposits
		int idPathSection = 0;

		// For each id of the point
		for (int i = 1; i < tabPath.length; i++) {
			int currentId = Integer.parseInt(tabPath[i]);

			// We are not moving we are at a deposit
			if (currentId == previousId) {
				idPathSection++;
				previousId = currentId;
				continue;
			}

			// We get the current coordinates
			Point currentCoord = cM.getPoint(currentId);

			IDirectPositionList dpl = new DirectPositionList();
			dpl.add(new DirectPosition(preivousCoord.getX(), preivousCoord.getY()));
			dpl.add(new DirectPosition(currentCoord.getX(), currentCoord.getY()));

			IFeature feat = new DefaultFeature(new GM_LineString(dpl));

			// We store the distance
			Double d = dm.getDistance(currentId, previousId);
			AttributeManager.addAttribute(feat, NAME_ATT_COST, d, "Double");
			// PathSectionID
			AttributeManager.addAttribute(feat, NAME_PATH_SECT_ID, idPathSection, "Integer");
			// We indicate if we remove the trashes
			if (tabRemove != null) {
				AttributeManager.addAttribute(feat, NAME_TRASH_REM, Integer.parseInt(tabRemove[i - 1]), "Integer");
			}

			featC.add(feat);
			previousId = currentId;
		}

		ShapefileWriter.write(featC, fileOut);
	}
	/**
	 * Just split the filename into a String array
	 * @param fileName
	 * @return
	 * @throws Exception
	 */
	private static String[] generatePath(File fileName) throws Exception {

		InputStream ips = new FileInputStream(fileName);
		InputStreamReader ipsr = new InputStreamReader(ips);
		BufferedReader br = new BufferedReader(ipsr);

		String ligne;
		// First line contains id
		ligne = br.readLine();

		String[] strPath = ligne.split(";");

		br.close();

		return strPath;
	}

	public static void exportPath(CoordinateMatrix cM, DistanceMatrix dm, File pathFile, String fileOut)
			throws Exception {
		exportPath(cM, dm, pathFile, null, fileOut);
	}

}
