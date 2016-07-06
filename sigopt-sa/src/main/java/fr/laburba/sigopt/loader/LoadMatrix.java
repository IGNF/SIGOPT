package fr.laburba.sigopt.loader;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import fr.laburba.sigopt.loader.input.CoordinateMatrix;
import fr.laburba.sigopt.loader.input.DistanceMatrix;
import fr.laburba.sigopt.model.Edge;
import fr.laburba.sigopt.model.Graph;
import fr.laburba.sigopt.model.Node;

public class LoadMatrix {

	private DistanceMatrix dM;
	private CoordinateMatrix cM;
	
	
	public LoadMatrix(File fileMatrixDistance, File fileCoordinates) throws IOException {

		//On charge les matrices
		 dM = new DistanceMatrix(fileMatrixDistance);
		 cM = new CoordinateMatrix(fileCoordinates);

	}

	
	public Graph loadGraph(){		
		//Maintenant on prépare la liste d'arcs et la les listes de noeudds
		
		//On récupère la liste des identifiants
		
		//On créer une liste de noeuds
		//On instnancie les dépots et les centres de stockage et on les ajoute à la liste de noeud
		
		
		//On créer la liste d'arcs
		//On ajoute les arcs à partir des identifiants en utilisant les instances de dépôts et centre de stockage
		
		
		return new Graph(new ArrayList<Node>(), new ArrayList<Edge>());
	}
	
	
}
