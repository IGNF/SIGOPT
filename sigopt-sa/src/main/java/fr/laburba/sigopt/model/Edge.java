package fr.laburba.sigopt.model;

public class Edge{

	Node nodeIni, nodeEnd;
	double distance;

	public Edge( Node nodeIni, Node nodeEnd, double distance) {
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