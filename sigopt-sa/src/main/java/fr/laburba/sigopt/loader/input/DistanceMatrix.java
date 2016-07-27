package fr.laburba.sigopt.loader.input;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class DistanceMatrix {

	private Map<Couple, Double> multiMap = new HashMap<>();
	private int[] ids;

	public class Couple {

		int id1, id2;

		public Couple(int id1, int id2) {
			this.id1 = id1;
			this.id2 = id2;
		}

		public int getId1() {
			return id1;
		}

		public int getId2() {
			return id2;
		}

		@Override
		public String toString() {
			return id1 + " : " + id2;
		}

		@Override
		public boolean equals(Object couple) {

			if (!(couple instanceof Couple)) {
				return false;
			}

			Couple couple2 = (Couple) couple;

			if ((this.getId1() == couple2.getId1()) && (this.getId2() == couple2.getId2())) {
				return true;
			}

			if ((this.getId1() == couple2.getId2()) && (this.getId2() == couple2.getId1())) {
				return true;
			}

			return false;

		}
		
		@Override
		public int hashCode(){
			return this.getId1() + 100000 * this.getId2();
		}

	}

	public DistanceMatrix(File f) throws IOException {
		fillMatrix(f);
	}

	public void fillMatrix(File f) throws IOException {
		// We create a BufferReader
		InputStream ips = new FileInputStream(f);
		InputStreamReader ipsr = new InputStreamReader(ips);
		BufferedReader br = new BufferedReader(ipsr);

		String ligne;
		// First line contains id
		ligne = br.readLine();

		// On récupère le tableau des identifiants
		String[] listId = ligne.split(";");

		ids = new int[listId.length - 1];

		for (int i = 1; i < listId.length; i++) {
			ids[i - 1] = Integer.parseInt(listId[i]);
		}

		// On stocke la taille de ce tableau (car on l'utilise beaucoup)
		int lengthIdLenght = ids.length;

		// Compteur qui indique à partir de quelle colonne on regarde
		int count = 1;

		// On parcourt chaque ligne
		while ((ligne = br.readLine()) != null) {
			count++;
			// On parse la ligne courante
			String[] tabLineTemp = ligne.split(";");
			
			
			

			// On récupère en int l'ID courant de la ligne
			String idCurrentRow = tabLineTemp[0];
			int i_idCurrentRow = Integer.parseInt(idCurrentRow);

			for (int i = count; i < lengthIdLenght + 1; i++) {
				// On récupère l'ID de chaque colonne en entier
				String idCurrentCol = listId[i];
				int i_idCurrentCol = Integer.parseInt(idCurrentCol);

				// Même id, la distance est nulle on ne stocke pas (je le laisse
				// quand même dans le code même si la matrice est diagonale)
				if (i_idCurrentRow == i_idCurrentCol) {
					continue;
				}

				// On récupère l'id min et l'id max
				int minId = Math.min(i_idCurrentRow, i_idCurrentCol);
				int maxId = Math.max(i_idCurrentRow, i_idCurrentCol);

				// On vérifie par principe que la distance n'est pas déjà entrée
				Couple c = new Couple(minId, maxId);
				Double d = multiMap.get(c);

				if (d != null) {
					System.out.println("Ce cas n'est pas supposé se produire");
					continue;
				}

				multiMap.put(c, Double.parseDouble(tabLineTemp[i]));

			}

		}
		br.close();
	}

	public Map<Couple, Double> getDistanceTab() {
		return this.multiMap;
	}

	public double getDistance(Couple c) {
		// Distance nulle pour les mêmes noeuds
		if (c.getId1() == c.getId2()) {
			return 0;
		}

		Double d = multiMap.get(c);
		// -1 si la distance n'est pas dans le tableau
		if (d == null) {
			return -1;
		}

		return d;
	}

	public double getDistance(int id1, int id2) {

		int minId = Math.min(id1, id2);
		int maxId = Math.max(id1, id2);

		return this.getDistance(new Couple(minId, maxId));

	}

	public int[] getListId() {
		return ids;
	}

	public static void main(String[] args) throws IOException {
		File f = new File(DistanceMatrix.class.getResource("/data/idf/mat_dist.csv").getPath());
		DistanceMatrix dM = new DistanceMatrix(f);

		/// Liste des identifiants
		int[] lIds = dM.getListId();
		System.out.println("---------------------------------");
		for (int i = 0; i < lIds.length; i++) {
			System.out.print(lIds[i] + ";");
		}
		System.out.println("");
		System.out.println("---------------------------------");
		// On peut afficher quelques distances
		Double d = dM.getDistance(78307, 77001);
		System.out.println("Distance : 78307 et 77001 : " + d);

		d = dM.getDistance(91538, 94065);
		System.out.println("Distance : 91538 et 94065 : " + d);

		Couple c = dM.new Couple(91538, 94065);
		d = dM.getDistanceTab().get(c);
		System.out.println("Distance : 91538 et 94065 : " + d);

		Set<Couple> keys = dM.getDistanceTab().keySet();

		for (Couple ctemp : keys) {

			if (ctemp.equals(c)) {
				System.out.println(c.toString() + "  :  " + dM.getDistance(ctemp));
				System.out.println(c.toString() + "  :  " + dM.getDistance(c));
			}

		}

	}

}
