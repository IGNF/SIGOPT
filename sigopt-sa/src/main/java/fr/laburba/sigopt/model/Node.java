package fr.laburba.sigopt.model;

public class Node {
	

	private double x,y;
	
	private int id;

	public Node(int id,int c, double x, double y) {
		super();
	
		this.x = x;
		this.y = y;
		this.id = id;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public double getX() {
		return x;
	}

	public void setX(double x) {
		this.x = x;
	}

	public double getY() {
		return y;
	}

	public void setY(double y) {
		this.y = y;
	}


}
