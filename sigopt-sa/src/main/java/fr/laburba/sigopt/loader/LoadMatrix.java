package fr.laburba.sigopt.loader;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;

import com.vividsolutions.jts.geom.Point;

import fr.laburba.sigopt.loader.input.CoordinateMatrix;
import fr.laburba.sigopt.loader.input.DistanceMatrix;
import fr.laburba.sigopt.model.DepotDeStockage;
import fr.laburba.sigopt.model.Edge;
import fr.laburba.sigopt.model.Graph;
import fr.laburba.sigopt.model.Node;
import fr.laburba.sigopt.model.PointDeCollecte;

public class LoadMatrix {

	private DistanceMatrix dM;
	private CoordinateMatrix cM;
	private static boolean add;
	
	
	public LoadMatrix(File fileMatrixDistance, File fileCoordinates) throws IOException {

		//On charge les matrices
 dM = new DistanceMatrix(fileMatrixDistance);
		 cM = new CoordinateMatrix(fileCoordinates);

	}

	
	public Graph loadGraph(){		
		
	//Maintenant on prépare la liste d'arcs et la les listes de noeudds
	
		//On créer une liste de noeuds
		ArrayList<Node> Noeuds = new ArrayList<Node>();
		Noeuds.addAll(cM.getListNodes());
		
		//On instnancie les dépots et les centres de stockage et on les ajoute à la liste de noeuds
		List<DepotDeStockage> depots = new ArrayList<>();
		depots.add((DepotDeStockage) cM.getListId());
		  

	List<PointDeCollecte> points = new ArrayList<>();
		
points.add((PointDeCollecte) cM.getListId());
		  
		//On créer la liste d'arcs
		
	ArrayList<Edge> arcs = new ArrayList<Edge>();
		//On ajoute les arcs à partir des identifiants en utilisant les instances de dépôts et centre de stockage
         arcs.add ((Edge) dM.getDistanceTab());
		
		
		System.out.println(arcs);
		
		
		
		
		
	    return new Graph(new ArrayList<Node>(), new ArrayList<Edge>());
	
		
		
	    		
	}
	
	public static void main(String[] args) throws IOException {
		
		
		
		
		File f = new File(CoordinateMatrix.class.getResource("/data/idf/com_idf_pt_xy.csv").getPath());
		CoordinateMatrix cM = new CoordinateMatrix(f);
		
		
		
       Set<Integer> Lid = cM.getListId();
		  System.out.println("---------------------------------");
		for (int i =  0; i < Lid.size(); i++) {
		  
		 System.out.print(Lid.toArray()[i] + ";");
		  
		  } System.out.println("");
	 System.out.println("---------------------------------");
		  
		  

			
		
	
	
	
     }
	}	

	


