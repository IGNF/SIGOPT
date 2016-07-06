package fr.laburba.sigopt.loader.input;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;

import fr.laburba.sigopt.loader.input.DistanceMatrix.Couple;

public class CoordinateMatrix {

	private static GeometryFactory geomFact = new GeometryFactory();
	
	
	
	private Map<Double,Couple> multiMap = new HashMap<>();
	private int[]id ;

	public class Couple {

		int x, y;

		public int getX() {
			return x;
		}

		public int getY() {
			return y;
		}

	
		public Couple(int x, int y) {
			this.x = x;
			this.y = y;
		}

		@Override
		public String toString() {
			return x + " : " + y;
		}

	}
	
	
	public CoordinateMatrix(File f) throws IOException {
		fillMatrix(f);
	}

	
	
	public void fillMatrix(File f) throws IOException {
		// We create a BufferReader
		InputStream ips = new FileInputStream(f);
		InputStreamReader ipsr = new InputStreamReader(ips);
		BufferedReader br = new BufferedReader(ipsr);

	// First Row contains id
	String Line = br.readLine();
	// On récupère le tableau des identifiants
	
	String[] listId =Line.split(";");

	id = new int[listId.length - 1];

	for (int i =0; i < listId.length; i++) {
		id[i ] = Integer.parseInt(listId[i]);
		
		
	}
	
				
//On stocke la taille de ce tableau (car on l'utilise beaucoup)
			int lengthIdLenght = id.length;

			// Compteur qui indique à partir de quelle colonne on regarde
		int count = 1;

			// On parcourt chaque ligne
			while ((Line = br.readLine()) != null) {
				count++;
				// On parse la ligne courante
			String[] tabLineTemp = Line.split(";");

				// On récupère en int l'ID courant de la ligne
				String idCurrentRow = tabLineTemp[0];
				int i_idCurrentRow = Integer.parseInt(idCurrentRow);

			for (int i = count; i < lengthIdLenght + 1; i++) {
					// On récupère l'ID de chaque colonne en entier
				String idCurrentCol = listId[i];
					int i_idCurrentCol = Integer.parseInt(idCurrentCol);
		
					
			}}
		
				


br.close();
}	

			public int[] getListId() {
				return id;
			}
				
				
				
				
				
				
				
				
				
				
				
				
		//@TODO : compléter la hashmap avec l'identifiant et les coordonnées
	
	
	
	
	
	


	public Point getPoint(int id) {

		// @TODO : compléter pour trouver les bonnes coordonnées

		return geomFact.createPoint(new Coordinate(0, 0));

	}

	
	
	public static void main(String[] args) throws IOException {
		File f = new File(CoordinateMatrix.class.getResource("/data/idf/com_idf_pt_xy.csv").getPath());
		CoordinateMatrix cM = new CoordinateMatrix(f);
	
		/// Liste des identifiants
		int[] lId = cM.getListId();
		System.out.println("---------------------------------");
		for (int i = 0; i < lId.length; i++) {
			System.out.print(lId[i] + ";");
	
	
	}
	System.out.println("");
	System.out.println("---------------------------------");
	
	
	
	
	}
	
	
}



	