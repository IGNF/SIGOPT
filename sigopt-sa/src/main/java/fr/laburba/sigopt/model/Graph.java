package fr.laburba.sigopt.model;

import java.util.ArrayList;
import java.util.List;

public class Graph {

	private List<DepotDeStockage> depots = new ArrayList<>();

	private List<PointDeCollecte> points = new ArrayList<>();

	private List<Node> nodes = new ArrayList<>();

	private List<Edge> arcs = new ArrayList<>();

	public Graph(List<Node> lNodes, List<Edge> lEdge) {
		nodes.addAll(lNodes);
		arcs.addAll(lEdge);

		for (Node n : lNodes) {
			if (n instanceof DepotDeStockage) {
				depots.add((DepotDeStockage) n);
			}

			if (n instanceof PointDeCollecte) {
				points.add((PointDeCollecte) n);
			}
		}

	}

	public List<DepotDeStockage> getDepots() {
		return depots;
	}

	public void setDepots(List<DepotDeStockage> depots) {
		this.depots = depots;
	}

	public List<PointDeCollecte> getPoints() {
		return points;
	}

	public void setPoints(List<PointDeCollecte> points) {
		this.points = points;
	}

	public List<Node> getNodes() {
		return nodes;
	}

	public void setNodes(List<Node> nodes) {
		this.nodes = nodes;
	}

	public List<Edge> getArcs() {
		return arcs;
	}

	public void setArcs(List<Edge> arcs) {
		this.arcs = arcs;
	}

}
