package fr.laburba.sigopt.SA;

import java.io.File;

import fr.laburba.sigopt.loader.input.DistanceMatrix;

public class SimAnneal {

		// Calcul de la propability d'acceptence
	    public static double acceptanceProbability(int energy, int newEnergy, double temperature) {
	        // si la solution est meilleur on va l'accepter 
	        if (newEnergy < energy) {
	            return 1.0;
	        }
	        // si la nouvelle solution est eronnée, on va calculé la probabilité d' acceptance 
	        return Math.exp((energy - newEnergy) / temperature);
	    }

	    public static void main(String[] args) {
	    	File f = new File(DistanceMatrix.class.getResource("/data/idf/mat_dist.csv").getPath());
			DistanceMatrix dM = new DistanceMatrix(f);
	        
	        // température initiale
	        double temp = 10000;

	        // vitesse de refroidissement
	        double coolingRate = 0.003;

	        //  solution initiale
	        DistanceMatrix currentSolution = new DistanceMatrix(f);
	        currentSolution.getDistanceTab();
	        
	        System.out.println("Initial solution distance: " + currentSolution.getDistanceTab());

	        // Set as current best
	        DistanceMatrix best = new  DistanceMatrix(currentSolution.getDistanceTab());
	        
	     
	        while (temp > 1) {
	            
	        	  DistanceMatrix newSolution = new   DistanceMatrix(currentSolution.getDistance());


	            
	            // l'energy de la solution
	            int currentEnergy = (int) currentSolution.getDistance(currentEnergy, currentEnergy);
	            int neighbourEnergy = (int) newSolution.getDistance(neighbourEnergy, neighbourEnergy);

	            // décidé si on va accepter 
	            if (acceptanceProbability(currentEnergy, neighbourEnergy, temp) > Math.random()) {
	                currentSolution = new  DistanceMatrix(newSolution.getDistanceTab());
	            }

	            // Keep track of the best solution found
	            if (currentSolution.getDistance(neighbourEnergy, neighbourEnergy) < best.getDistance(neighbourEnergy, neighbourEnergy)) {
	                best = new   DistanceMatrix(currentSolution.getDisatnce());
	            }
	            
	            // System frais
	            temp *= 1-coolingRate;
	        }

	        System.out.println("Final solution distance: " + best.getDistanceTab());
	        System.out.println("Tour: " + best);
	    }
	}