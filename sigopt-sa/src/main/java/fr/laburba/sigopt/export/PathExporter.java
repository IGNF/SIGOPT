package fr.laburba.sigopt.export;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

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
		List<String[]> tabPath = generatePath(pathFile);
		List<String[]> tabRemove = null;
		// It is optionnal
		if (removeFile != null) {
			tabRemove = generatePath(removeFile);
			
			
			if(tabPath.size() != tabRemove.size()){
				System.out.println(PathExporter.class.getCanonicalName() + " ERROR NUMBER OF LINE IS DIFFERENT");
				return;
			}
			
		}
		

		int nbLine = tabPath.size();
		
		int count = 0;
		for(int i=0;i<nbLine;i++){
			
			if(tabRemove == null){
				featC.addAll(generateTour(tabPath.get(i), null, cM, dm, (count++)));
			}else{
				featC.addAll(generateTour(tabPath.get(i), tabRemove.get(i), cM, dm, (count++)));
			}
		
		}
		
		
	
		ShapefileWriter.write(featC, fileOut);
	}
	
	public static IFeatureCollection<IFeature> generateTour(String[] tabPath, String[] tabRemove, CoordinateMatrix cM, DistanceMatrix dm, int count ){
		

		IFeatureCollection<IFeature> featColl = new FT_FeatureCollection<>();
		
		
		int previousId = Integer.parseInt(tabPath[0]);
		Point preivousCoord = cM.getPoint(previousId);

		// For each id of the point
		for (int i = 1; i < tabPath.length; i++) {
			int currentId = Integer.parseInt(tabPath[i]);


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
			AttributeManager.addAttribute(feat, NAME_PATH_SECT_ID, count, "Integer");
			// We indicate if we remove the trashes
			if (tabRemove != null) {
				AttributeManager.addAttribute(feat, NAME_TRASH_REM, Integer.parseInt(tabRemove[i - 1]), "Integer");
			}

			featColl.add(feat);
			previousId = currentId;
			preivousCoord = currentCoord;
		}

		
		return featColl;
		
	}

	/**
	 * Just split the filename into a String array
	 * 
	 * @param fileName
	 * @return
	 * @throws Exception
	 */
	private static List<String[]> generatePath(File fileName) throws Exception {

		List<String[]> list = new ArrayList<>();

		InputStream ips = new FileInputStream(fileName);
		InputStreamReader ipsr = new InputStreamReader(ips);
		BufferedReader br = new BufferedReader(ipsr);

		String ligne = br.readLine();

		while (ligne != null) {

			String[] strPath = ligne.split(" ");

			list.add(strPath);
			
			ligne = br.readLine();
		}

		br.close();

		return list;
	}

	public static void exportPath(CoordinateMatrix cM, DistanceMatrix dm, File pathFile, String fileOut)
			throws Exception {
		exportPath(cM, dm, pathFile, null, fileOut);
	}

}
