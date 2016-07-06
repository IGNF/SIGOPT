package fr.laburba.sigopt.model;

public class Edge extends Node {

	Node nodeIni, nodeEnd;
	double distance;

	public Edge(double x, double y, Node nodeIni, Node nodeEnd, double distance) {
		super(x, y);
		this.nodeIni = nodeIni;
		this.nodeEnd = nodeEnd;
		this.distance = distance;
	}

	public Node getNodeIni() {
		return nodeIni;
	}

	public void setNodeIni(Node nodeIni) {
		this.nodeIni = nodeIni;
	}

	public Node getNodeEnd() {
		return nodeEnd;
	}

	public void setNodeEnd(Node nodeEnd) {
		this.nodeEnd = nodeEnd;
	}

	public double getDistance() {
		return distance;
	}

	public void setDistance(double distance) {
		this.distance = distance;
	}

}