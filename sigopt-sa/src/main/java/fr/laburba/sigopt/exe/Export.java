package fr.laburba.sigopt.exe;

import java.io.File;

import fr.laburba.sigopt.export.EdgeExporter;
import fr.laburba.sigopt.export.NodeExporter;
import fr.laburba.sigopt.export.PathExporter;
import fr.laburba.sigopt.loader.input.CoordinateMatrix;
import fr.laburba.sigopt.loader.input.DistanceMatrix;

public class Export {

	public static void main(String[] args) throws Exception {

		String folder =  CoordinateMatrix.class.getResource("/data/sa-uncertainty/test1/").getPath();
		String fileCoord = folder + "coordonnees.csv";
		String fileMatDistance = folder + "matrice_distance.csv";
		String trashQuant = folder + "trash_quant.csv";
		String pathFile = folder + "tournee.txt";
		String removeFile = folder + "deblais.txt";

		String folderOut = "/home/mickael/data/temp/";

		File fileCoordinate = new File(fileCoord);
		CoordinateMatrix cM = new CoordinateMatrix(fileCoordinate);

		File fileDistance = new File(fileMatDistance);
		DistanceMatrix dM = new DistanceMatrix(fileDistance);

		File fileTrash = new File(trashQuant);
		DistanceMatrix trashMatrix = new DistanceMatrix(fileTrash);

		NodeExporter.export(cM, folderOut + "node.shp");
		EdgeExporter.export(cM, dM, trashMatrix, folderOut + "edge.shp");
		
		if(((new File(pathFile)).exists()) &&  ( new File(removeFile).exists())){
			PathExporter.exportPath(cM, dM, new File(pathFile), new File(removeFile), folderOut + "tournee.shp");
		}
		
		


	}
}
