package fr.laburba.sigopt.model;

public class PointDeCollecte extends Node{

	public int id;
	public int demande;

	public PointDeCollecte(int id, int demande, double x, double y) {
		super(x,y);
		this.id = id;
		this.demande = demande;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getDemande() {
		return demande;
	}

	public void setDemande(int demande) {
		this.demande = demande;
	}

	@Override
	public String toString() {
		return "PointDeCollecte [id=" + id + ", demande=" + demande + ", getId()=" + getId() + ", getDemande()="
				+ getDemande() + "]";
	}
}
