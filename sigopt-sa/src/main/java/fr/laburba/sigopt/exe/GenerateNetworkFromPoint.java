package fr.laburba.sigopt.exe;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import fr.ign.cogit.geoxygene.api.feature.IFeature;
import fr.ign.cogit.geoxygene.api.feature.IFeatureCollection;
import fr.ign.cogit.geoxygene.api.spatial.coordgeom.IDirectPosition;
import fr.ign.cogit.geoxygene.contrib.cartetopo.Arc;
import fr.ign.cogit.geoxygene.contrib.cartetopo.CarteTopo;
import fr.ign.cogit.geoxygene.contrib.cartetopo.Noeud;
import fr.ign.cogit.geoxygene.contrib.delaunay.TriangulationJTS;
import fr.ign.cogit.geoxygene.util.attribute.AttributeManager;
import fr.ign.cogit.geoxygene.util.conversion.ShapefileReader;
import fr.ign.cogit.geoxygene.util.conversion.ShapefileWriter;
import fr.ign.cogit.geoxygene.util.index.Tiling;

public class GenerateNetworkFromPoint {
	public static void main(String[] args) throws Exception {
		// Répertoire/entrée/sortie
		String pathFlder = GenerateNetworkFromPoint.class.getResource("/data/idf/").getPath();
		String outFolder = "/home/mickael/Bureau/temp/";
		// ID du centre
		String idCenter = "94028";
		// Rayon (distance des sommets pris en compte depuis le centre
		double radius = 10000;

		// On charge les données
		IFeatureCollection<IFeature> feat = ShapefileReader.read(pathFlder + "com_idf_pt_xy.shp");
		feat.initSpatialIndex(Tiling.class, false);


		// On retrouve le centre

		IDirectPosition center = null;

		for (IFeature featTemp : feat) {

			String insee = featTemp.getAttribute("INSEE_COM").toString();

			if (insee.equals(idCenter)) {


				center = featTemp.getGeom().coord().get(0);
				break;
			}

		}

		// generation de la carte Topo
		CarteTopo tri = generateCarteTopo(feat, center, radius);
		
		//On prépare la liste de noeuds 
		List<Noeud> lNoeud = new ArrayList<>();
		lNoeud.addAll(tri.getListeNoeuds());
		
		//On met le dépot en premier
		for(Noeud n : lNoeud){
			String insee = n.getAttribute("INSEE_COM").toString();

			if (insee.equals(idCenter)) {
				lNoeud.remove(n);
				lNoeud.add(0,n);
				break;
			}
			
		}

		
		
		exportCSVCoord(lNoeud, outFolder + "coordonnees.csv");
		exportMatDistance(lNoeud, outFolder + "matrice_distance.csv", true); //distance
		exportMatDistance(lNoeud, outFolder + "trash_quant.csv", false); //trash

		// On génère pour export dans le formalisme SIGOPT
		ShapefileWriter.write(tri.getPopNoeuds(), outFolder + "node.shp");
		ShapefileWriter.write(tri.getPopArcs(), outFolder + "arcs.shp");

	}

	private static void exportCSVCoord(List<Noeud>lNoeud, String fileOut) throws IOException {

		FileWriter fw = new FileWriter(fileOut);
		BufferedWriter bw = new BufferedWriter(fw);

		bw.write("id;cat;X;Y\n");

		for (Noeud n : lNoeud) {
	
			String insee = n.getAttribute("INSEE_COM").toString();

			IDirectPosition dp = n.getCoord();
			bw.write(insee + ";0;" + dp.getX() + ";" + dp.getY() + "\n");
		}

		bw.close();
		fw.close();
	}

	private static void exportMatDistance(List<Noeud> lNoeud,  String fileOut, boolean distanceOrTrash) throws IOException {

		FileWriter fw = new FileWriter(fileOut);
		BufferedWriter bw = new BufferedWriter(fw);

		StringBuffer bf = new StringBuffer("");


		for (Noeud n : lNoeud) {
			String insee = n.getAttribute("INSEE_COM").toString();


			bf.append(";" + insee);
		}

		bf.append("\n");
		
		for (Noeud n : lNoeud) {
			String insee = n.getAttribute("INSEE_COM").toString();


			bf.append(insee + ";");
			bf.append(treatNode(n, lNoeud,distanceOrTrash));
			bf.append("\n");
			
			
		}
		

		bw.write(bf.toString());

		bw.close();
		fw.close();
	}

	private static String treatNode(Noeud n, List<Noeud> lNoeud, boolean distanceOrTrash) {
		StringBuffer bf = new StringBuffer(""); 

		List<Arc> lA = n.arcs();

		Map<Integer, Double> map = new HashMap<>();

		for (Arc a : lA) {

			Noeud nDiff = null;

			if (a.getNoeudIni() == n) {
				nDiff = a.getNoeudFin();
			} else {
				nDiff = a.getNoeudIni();
			}

			int idDiffNoeud = indexOfFromID(lNoeud, nDiff.getAttribute("INSEE_COM").toString());
			
			
			if(distanceOrTrash){
				map.put(idDiffNoeud, a.getGeom().length());
			}else{
				double trash1 = Integer.parseInt(n.getAttribute("POP").toString());
				double trash2 = Integer.parseInt(nDiff.getAttribute("POP").toString());
				
				double nbArcsInDiff = nDiff.arcs().size();
				
				double trash = trash1 / lA.size() + trash2 / nbArcsInDiff ;
				map.put(idDiffNoeud, trash);
				
			}

		}

		int nbSize = lNoeud.size();

		for (int i = 0; i < nbSize; i++) {

			Double d = map.get(i);

			if (d == null) {
				bf.append("-1");
			} else {
				bf.append(d);
			}

			if (i != (nbSize - 1)) {
				bf.append(";");
			}
		}

		return bf.toString();

	}


	private static int indexOfFromID(List<Noeud> lNoeud, String id) {
		int count = 0;
		for (Noeud n : lNoeud) {
			String insee = n.getAttribute("INSEE_COM").toString();

			if (insee.equals(id)) {

				return count;
			}

			count++;
		}
		return -1;
	}

	private static CarteTopo generateCarteTopo(IFeatureCollection<IFeature> feat, IDirectPosition center, double radius)
			throws Exception {

		if (center == null) {
			System.out.println("Centre not found");
		}

		System.out.println("Center found");

		// Triangulation initialisation
		TriangulationJTS tri = new TriangulationJTS("-eXopLM6f");

		// Pour tous les sommets qui se trouvent à une distance radius
		for (IFeature featTemp : feat.select(center, radius)) {

			// On crée un noeud qui participera à la triangulation
			Noeud noeud = new Noeud(featTemp.getGeom().coord().get(0));
			int pop = Integer.parseInt(featTemp.getAttribute("POP").toString());
			String insee = featTemp.getAttribute("INSEE_COM").toString();
			AttributeManager.addAttribute(noeud, "POP", pop, "Integer");
			AttributeManager.addAttribute(noeud, "INSEE_COM", insee, "String");

			tri.addNoeud(noeud);

		}

		System.out.println("Il y a " + tri.getPopNoeuds().size() + "   noeuds");

		tri.triangule();

		System.out.println("Il y a " + tri.getPopArcs().size() + "   arcs");

		return tri;

	}

}
