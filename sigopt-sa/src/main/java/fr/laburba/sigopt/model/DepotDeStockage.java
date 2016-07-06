package fr.laburba.sigopt.model;

public class DepotDeStockage extends Node{

	public int id;

	public int capacity;

	public DepotDeStockage(int id, int capacity, double x, double y) {
		super(x,y);
		this.id = id;
		this.capacity = capacity;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getCapacity() {
		return capacity;
	}

	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}

	@Override
	public String toString() {
		return "DepotDeStockage [id=" + id + ", capacity=" + capacity + ", getId()=" + getId() + ", getCapacity()="
				+ getCapacity() + "]";
	}

}