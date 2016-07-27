package fr.laburba.sigopt.loader.input;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;

import fr.laburba.sigopt.model.DepotDeStockage;
import fr.laburba.sigopt.model.Node;
import fr.laburba.sigopt.model.PointDeCollecte;

public class CoordinateMatrix {

	private static GeometryFactory geomFact = new GeometryFactory();

	private Map<Integer, Node> multiMap = new HashMap<>();


	public CoordinateMatrix(File f) throws IOException {
		fillMatrix(f);
	}

	public void fillMatrix(File f) throws IOException {

		// We create a BufferReader
		InputStream ips = new FileInputStream(f);
		InputStreamReader ipsr = new InputStreamReader(ips);
		BufferedReader br = new BufferedReader(ipsr);

		String Line = br.readLine();

		// On récupère le tableau des identifiants

		int id = 0;
		int cat= 1;// catégorie :point de collecte ou dépot de stockage.
		// On parcourt chaque ligne
		int indexX = 2;
		int indexY = 3;
		
		while ((Line = br.readLine()) != null) {

			// On parse la ligne courante
			String[] tabLineTemp = Line.split(";");

			System.out.println(Arrays.toString(tabLineTemp));
			
		
			//On fait un test => si c'est 0 alors on crée un Point de Collecte
			//Si c'est un on crée un centre de stockage
			//On ajoute à la hasmap
			
if(Integer.parseInt(tabLineTemp[cat])==0){
	
	DepotDeStockage d= new DepotDeStockage (Integer.parseInt(tabLineTemp[id]), 0, indexX, indexY);
	  for (int i =  0; i < tabLineTemp[cat].length(); i++) {
	System.out.println(d);
	
}}


		else if (Integer.parseInt(tabLineTemp[cat])==1){
		PointDeCollecte p= new 	PointDeCollecte  (Integer.parseInt(tabLineTemp[id]),1, indexX, indexY);
		for (int i =  0; i < tabLineTemp[cat].length(); i++) {
		System.out.println(p);
		}
		}


Node n = new Node(Integer.parseInt(tabLineTemp[id]),
		Integer.parseInt(tabLineTemp[cat]),
		   
		  Double.parseDouble(tabLineTemp[indexX]),
		  Double.parseDouble(tabLineTemp[indexY]));

		multiMap.put(Integer.parseInt(tabLineTemp[id]), n);

		
		}
			


		br.close();
	}

	public Set<Integer> getListId() {
		return multiMap.keySet();
	}



	public com.vividsolutions.jts.geom.Point getPoint(int id) {

			
		Node n = multiMap.get(id);
		
		if(n == null){
			return null;
		}
		

		return geomFact.createPoint(new Coordinate(n.getX(), n.getY()));

	}
	
	public Collection<Node> getListNodes(){
		return multiMap.values();
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
		  
		  
		
		  com.vividsolutions.jts.geom.Point p = cM.getPoint(92078);
		  
		  System.out.println("Les coordnnées du point qui a l'id 92078 sont : " + p);
		
		  

	}

}
