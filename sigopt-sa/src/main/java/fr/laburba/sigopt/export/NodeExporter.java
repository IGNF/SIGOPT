package fr.laburba.sigopt.export;

import fr.ign.cogit.geoxygene.api.feature.IFeature;
import fr.ign.cogit.geoxygene.api.feature.IFeatureCollection;
import fr.ign.cogit.geoxygene.feature.DefaultFeature;
import fr.ign.cogit.geoxygene.feature.FT_FeatureCollection;
import fr.ign.cogit.geoxygene.util.attribute.AttributeManager;
import fr.ign.cogit.geoxygene.util.conversion.ShapefileWriter;
import fr.laburba.sigopt.loader.input.CoordinateMatrix;
import fr.laburba.sigopt.model.DepotDeStockage;
import fr.laburba.sigopt.model.Node;
import fr.laburba.sigopt.model.PointDeCollecte;

public class NodeExporter {
	
	
	
	public static void export(CoordinateMatrix mat, String fileOut)
	{
		IFeatureCollection<IFeature> featCollOut = new FT_FeatureCollection<>();
		
		for(Node n : mat.getListNodes()){
			
			IFeature feat = new DefaultFeature();	
			feat.setGeom(n.toGeometry());
			
			if(n instanceof DepotDeStockage){
				AttributeManager.addAttribute(feat, "TYPE", "Depot", "String");
			}
			
			
			
			if(n instanceof PointDeCollecte){
				AttributeManager.addAttribute(feat, "TYPE", "PointCollecte", "String");
			}
			
			AttributeManager.addAttribute(feat, "ID", n.getId(), "Integer");
			
			featCollOut.add(feat);
			
			
		}
		
		ShapefileWriter.write(featCollOut, fileOut);
		
		
	}
}
