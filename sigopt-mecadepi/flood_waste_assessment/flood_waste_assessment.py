# -*- coding: utf-8 -*-
#-----------------------------------------------------------
#
# FloodWasteAssessment
# Copyright Serge Lhomme
# EMAIL: serge.lhomme (at) u-pec.fr
# WEB  : https://github.com/IGNF/SIGOPT
# WEB  : http://serge.lhomme.pagesperso-orange.fr/deven.html
#
# Tools for assessing flood waste (based on Mecadepi method)
# This tool need to be completed
#
#-----------------------------------------------------------
#
# licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
#---------------------------------------------------------------------

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from PyQt4 import QtXml
from qgis.gui import *
import os
import sys
currentPath = os.path.dirname(__file__)
sys.path.append(os.path.abspath(os.path.dirname(__file__) + '/tools'))

from fwadialog import fwaDialog
from fwadialog2 import fwaDialog2
from fwadialog3 import fwaDialog3
from fwatooldialog import fwatoolDialog
from fwatoolbuilddialog import fwatoolbuildDialog
from fwatoolbuilddialog2 import fwatoolbuildDialog2
from fwatooltypecomdialog import fwatooltypecomDialog
from fwatooltypecomdialog2 import fwatooltypecomDialog2
from fwabardialog import fwabarDialog

class FloodWasteAssessment:

  def __init__(self, iface):
    self.iface = iface

  def initGui(self):
    self.action = QAction("Assessment", self.iface.mainWindow())
    QObject.connect(self.action, SIGNAL("activated()"), self.run)
    self.actionb = QAction("Tools", self.iface.mainWindow())
    QObject.connect(self.actionb, SIGNAL("activated()"), self.runtools)

    self.iface.addPluginToMenu("&FWA...", self.action)
    self.iface.addPluginToMenu("&FWA...", self.actionb)

  def unload(self):
    self.iface.removePluginMenu("&FWA...",self.action)
    self.iface.removePluginMenu("&FWA...",self.actionb)

#--------------------------------------------------------------------- La partie estimation ---------------------------------------------------------------------

  def run(self): 
        global canvas
        canvas = self.iface.mapCanvas()
        global allLayers
        allLayers = canvas.layers()
        global count
        count = canvas.layerCount()
        global lay
        lay = []
        for i in allLayers:
           lay = lay+[str(i.name())]
        self.dlg = fwaDialog(self.iface.mainWindow())
        self.dlg.ui.comboBox.addItems(["Sommaire", "Detaillee"])
        QObject.connect(self.dlg.ui.buttonBox, SIGNAL("accepted()"), self.couche)
        self.dlg.show()

  def couche(self):
        global method
        method = self.dlg.ui.comboBox.currentText()
        if method == "Sommaire":
            self.dlg2 = fwaDialog2(self.iface.mainWindow())
            self.dlg2.ui.comboBox.addItems(["IRIS","Bati"])
            self.dlg2.ui.comboBox2.addItems(lay)
            QObject.connect(self.dlg2.ui.buttonBox, SIGNAL("accepted()"), self.champ)
            self.dlg2.show()
        if method == "Detaillee":
            QMessageBox.information(None, " Message : ", "A faire")

  def champ(self):
        test = self.dlg2.ui.comboBox.currentText()
        layer = self.dlg2.ui.comboBox2.currentText()
        for j in range(count):
          if str(layer) == str(lay[j]) :
            ind = j
        global aLayer
        aLayer = allLayers[int(ind)]
        global provider
        provider = aLayer.dataProvider()
        field=provider.fields()
        global fields
        fields=[]
        for i in range(field.count()):
          fields=fields+[str(field[i].name())]
        self.dlg3 = fwaDialog3(self.iface.mainWindow())
        self.dlg3.ui.comboBox.addItems(fields)
        self.dlg3.ui.comboBox2.addItems(fields)
        self.dlg3.ui.comboBox3.addItems(fields)
        QObject.connect(self.dlg3.ui.buttonBox, SIGNAL("accepted()"), self.calculfin)
        self.dlg3.show()

  def calculfin(self):
        champ1 = self.dlg3.ui.comboBox.currentText()
        for j in range(len(fields)):
          if str(champ1) == str(fields[j]) :
            ind_champ1 = j
        champ2 = self.dlg3.ui.comboBox2.currentText()
        for j in range(len(fields)):
          if str(champ2) == str(fields[j]) :
            ind_champ2 = j
        champ3 = self.dlg3.ui.comboBox3.currentText()
        for j in range(len(fields)):
          if str(champ3) == str(fields[j]) :
            ind_champ3 = j
        fit3 = provider.getFeatures()
        feat3 = QgsFeature()
        nbcol=int(provider.fields().count())
        provider.addAttributes([QgsField("Meuble(kg)", QVariant.Double)])
        provider.addAttributes([QgsField("IEEE (kg)", QVariant.Double)])
        provider.addAttributes([QgsField("Danger(kg)", QVariant.Double)])
        provider.addAttributes([QgsField("Melange(m3)", QVariant.Double)])
        provider.addAttributes([QgsField("Vehicule(u)", QVariant.Double)])
        provider.addAttributes([QgsField("Soin(m3)", QVariant.Double)])
        c = provider.featureCount()
        self.dlg = fwabarDialog(self.iface.mainWindow())
        self.dlg.ui.progressBar.setProperty("value", 0)
        self.dlg.show()
        i = 0
        while (fit3.nextFeature(feat3)):
            nblog = feat3.attributes()[int(ind_champ1)] # champ identifiant du nombre de logements inondables par iris
            nblog2 = feat3.attributes()[int(ind_champ2)] # champ identifiant du nombre de menages dans la zone inondable par iris
            typecom = feat3.attributes()[int(ind_champ3)] # champ du type de la commune
            if typecom == "AggloParis" :
                sommeiee = 51.313 + 28.305 + 58.289 + 11.343 + 18.893 + 2.468 + 1.983 + 4.428 + 10.304 + 1.974 + 4.322 + 0.121 + 0.181 + 0.778 + 0.102 + 0.025 + 20.542 + 3.535
            if typecom == "Rurale" :
                sommeiee = 51.350 + 39.714 + 60.338 + 14.725 + 21.908 + 2.468 + 1.928 + 4.488 + 10.436 + 1.856 + 3.851 + 0.121 + 0.116 + 0.709 + 0.088 + 0.021 + 31.476 + 8.271
            if typecom == "PVille" :
                sommeiee = 51.702 + 33.812 + 60.659 + 14.003 + 21.025 + 2.496 + 2.043 + 4.514 + 10.510 + 2.046 + 4.236 + 0.122 + 0.122 + 0.727 + 0.101 + 0.023 + 26.492 + 4.308 
            if typecom == "MVille" :
                sommeiee = 51.160 +	27.131 + 57.969 + 10.648 + 17.291 + 2.458 + 2.019 +	4.403 + 10.250 + 2.042 + 4.316 + 0.108 + 0.136 + 0.728 + 0.091 + 0.022 + 17.569 + 2.321
            if typecom == "GVille" :
                sommeiee = 51.844 + 21.834 + 56.125 + 9.653 + 16.828 + 2.439 + 1.974 + 4.309 + 10.138 + 1.940 + 4.491 + 0.112 + 0.216 + 0.806 + 0.102 + 0.027 + 14.648 + 1.334 				
            meubles = int(nblog) * 1025
            aLayer.startEditing() #IrisLayer ou BatiLayer
            aLayer.changeAttributeValue(i, nbcol, meubles)
            iee = nblog * sommeiee
            aLayer.changeAttributeValue(i, nbcol + 1, iee)
            dangers = nblog * 15.1
            aLayer.changeAttributeValue(i, nbcol + 2, dangers)
            melange = nblog * 7.09
            aLayer.changeAttributeValue(i, nbcol + 3, melange)
            vehi = (nblog2 * 0.476) + (2 * nblog2 * 0.307) + (3 * nblog2 * 0.052)
            aLayer.changeAttributeValue(i, nbcol + 4, vehi)
            soin = nblog * 0.158 * 0.75
            aLayer.changeAttributeValue(i, nbcol + 5, soin)
            aLayer.commitChanges()
            i = i + 1
            valbar = int(i * 100 / float(c))
            self.dlg.ui.progressBar.setProperty("value", valbar)
        self.dlg.close()
        QMessageBox.information(None, " Message : ", "Calcul termine")

#--------------------------------------------------------------------- Les outils ---------------------------------------------------------------------

  def runtools(self): 
        global canvas
        canvas = self.iface.mapCanvas()
        global allLayers
        allLayers = canvas.layers()
        global count
        count = canvas.layerCount()
        global lay
        lay=[]
        for i in allLayers:
           lay=lay+[str(i.name())]
        self.dlg = fwatoolDialog(self.iface.mainWindow())
        self.dlg.ui.comboBox.addItems(["Estimation logements inondables", "Type de commune", "Estimation nombre de pieces", "Estimation hauteur eau"])
        QObject.connect(self.dlg.ui.buttonBox, SIGNAL("accepted()"), self.couchetools)
        self.dlg.show()

  def couchetools(self):
        global outil
        outil = self.dlg.ui.comboBox.currentText()
        if outil == "Estimation logements inondables":
            QMessageBox.information(None, " Message : ", "Attention cette estimation ne tient pas compte des hauteurs d eau")
            self.dlg2 = fwatoolbuildDialog(self.iface.mainWindow())
            self.dlg2.ui.comboBox.addItems(lay)
            self.dlg2.ui.comboBox2.addItems(lay)
            self.dlg2.ui.comboBox3.addItems(lay)
            self.dlg2.ui.comboBox4.addItems(lay)
            QObject.connect(self.dlg2.ui.buttonBox, SIGNAL("accepted()"), self.champtoolbuild)
            self.dlg2.show()
        if outil == "Type de commune":
            self.dlg2 = fwatooltypecomDialog(self.iface.mainWindow())
            self.dlg2.ui.comboBox.addItems(lay)
            self.dlg2.ui.comboBox2.addItems(lay)
            QObject.connect(self.dlg2.ui.buttonBox, SIGNAL("accepted()"), self.champtooltypecom)
            self.dlg2.show()
        if outil == "Estimation nombre de pieces":
            QMessageBox.information(None, " Message : ", "A faire")
        if outil == "Estimation hauteur eau":
            QMessageBox.information(None, " Message : ", "A faire")
            

  def champtoolbuild(self):
        global BatLayer, EauLayer, IrisLayer, LogLayer
        global provider, provider2, provider3, provider4
        global fields, fields2, fields3, fields4
        layerbat = self.dlg2.ui.comboBox2.currentText()
        for j in range(count):
          if str(layerbat) == str(lay[j]) :
            indbat = j
        BatLayer = allLayers[int(indbat)]
        layeriris = self.dlg2.ui.comboBox4.currentText()
        for j in range(count):
          if str(layeriris) == str(lay[j]) :
            indiris = j
        IrisLayer = allLayers[int(indiris)]
        layereau = self.dlg2.ui.comboBox3.currentText()
        for j in range(count):
          if str(layereau) == str(lay[j]) :
            indeau = j
        EauLayer = allLayers[int(indeau)]
        layerlog = self.dlg2.ui.comboBox.currentText()
        for j in range(count):
          if str(layerlog) == str(lay[j]) :
            indlog = j
        LogLayer = allLayers[int(indlog)]
        provider = BatLayer.dataProvider()
        provider2 = EauLayer.dataProvider()
        provider3 = IrisLayer.dataProvider()
        provider4 = LogLayer.dataProvider()
        field=provider.fields()
        fields=[]
        for i in range(field.count()):
          fields=fields+[str(field[i].name())]
        field=provider3.fields()
        fields3=[]
        for i in range(field.count()):
          fields3=fields3+[str(field[i].name())]
        field=provider4.fields()
        fields4=[]
        for i in range(field.count()):
          fields4=fields4+[str(field[i].name())]
        self.dlg3 = fwatoolbuildDialog2(self.iface.mainWindow())
        self.dlg3.ui.comboBox.addItems(fields)
        self.dlg3.ui.comboBox2.addItems(fields)
        self.dlg3.ui.comboBox3.addItems(fields3)
        self.dlg3.ui.comboBox4.addItems(fields4)
        self.dlg3.ui.comboBox5.addItems(fields4)
        self.dlg3.ui.comboBox6.addItems(fields4)
        QObject.connect(self.dlg3.ui.buttonBox, SIGNAL("accepted()"), self.calcultoolbuild)
        self.dlg3.show()

  def champtooltypecom(self):
        global Layer, comLayer
        global provider, provider2
        global fields, fields2
        laye = self.dlg2.ui.comboBox.currentText()
        for j in range(count):
          if str(laye) == str(lay[j]) :
            ind = j
        Layer = allLayers[int(ind)]
        layercom = self.dlg2.ui.comboBox2.currentText()
        for j in range(count):
          if str(layercom) == str(lay[j]) :
            indcom = j
        comLayer = allLayers[int(indcom)]
        provider = Layer.dataProvider()
        provider2 = comLayer.dataProvider()
        field=provider.fields()
        fields=[]
        for i in range(field.count()):
          fields=fields+[str(field[i].name())]
        field=provider2.fields()
        fields2=[]
        for i in range(field.count()):
          fields2=fields2+[str(field[i].name())]
        self.dlg3 = fwatooltypecomDialog2(self.iface.mainWindow())
        self.dlg3.ui.comboBox.addItems(fields)
        self.dlg3.ui.comboBox2.addItems(fields2)
        self.dlg3.ui.comboBox3.addItems(fields2)
        QObject.connect(self.dlg3.ui.buttonBox, SIGNAL("accepted()"), self.calcultooltypecom)
        self.dlg3.show()
		
  def calcultoolbuild(self):
        champbatind = self.dlg3.ui.comboBox.currentText()
        for j in range(len(fields)):
          if str(champbatind) == str(fields[j]) :
            indchampbatind = j
        champbathaut = self.dlg3.ui.comboBox2.currentText()
        for j in range(len(fields)):
          if str(champbathaut) == str(fields[j]) :
            indchampbathaut = j
        champirisind = self.dlg3.ui.comboBox3.currentText()
        for j in range(len(fields3)):
          if str(champirisind) == str(fields3[j]) :
            indchampirisind = j
        champlogiris = self.dlg3.ui.comboBox4.currentText()
        for j in range(len(fields4)):
          if str(champlogiris) == str(fields4[j]) :
            indchamplogiris = j
        champlognbr = self.dlg3.ui.comboBox5.currentText()
        for j in range(len(fields4)):
          if str(champlognbr) == str(fields4[j]) :
            indchamplognbr = j
        champmainbr = self.dlg3.ui.comboBox6.currentText()
        for j in range(len(fields4)):
          if str(champmainbr) == str(fields4[j]) :
            indchampmainbr = j
        #creation des listes
        resbati = [] #id, num ligne, surface sol, hauteur, niveau, surface hab, inondable, nb etage inondable, num IRIS, polygon, centroid, nb_log_ino
        resinon = [] #numero de ligne (vecteur des logements inondables)
        resIrisInon = [] #num Iris (vecteur des Iris inondables par le bati)
        surfhabiris = [] #surfhabiris (ne tient compte que des immeubles) les lignes sont les memes que resIrisInon
        ctmaisiris = [] #compte le nombre de maisons par IRIS
        resiris = [] #vecteur final pour les iris
        resiris2 = [] #vecteur final pour les iris
        resirisnum = [] #vecteur final pour les iris
        log = [] # vecteur logement correspondant au num iris
        log2 = [] # vecteur logement correspondant au nombre de logement (immeuble) dans un iris
        log3 = [] # vecteur logement correspondant au nombre de logement (maison) dans un iris
        #couche centroid qui sera utilisee pour associer les batis aux IRIS
        CenLay = QgsVectorLayer("Point?crs=epsg:2154", "Centroid", "memory")
        prcen = CenLay.dataProvider() 
        #Analyse du bati notamment vis-a-vis de linondation
        i=0
        CenLay.startEditing()
        prcen.addAttributes( [ QgsField("id", QVariant.Int) ] ) #couche centroid
        CenLay.commitChanges()
        provider = BatLayer.dataProvider()
        provider2 = EauLayer.dataProvider()
        fit1 = provider.getFeatures()
        feat = QgsFeature()
        c = provider.featureCount()
        self.dlg = fwabarDialog(self.iface.mainWindow())
        self.dlg.ui.progressBar.setProperty("value", 0)
        self.dlg.ui.label.setText("Progression du calcul (1/5)")
        self.dlg.show()
        while (fit1.nextFeature(feat)):  
            id = feat.attributes()[int(indchampbatind)] # champ identifiant de bati_ind
            numligne = i
            geom = feat.geometry()
            surfsol = geom.area()
            hauteur = float(feat.attributes()[int(indchampbathaut)]) # champ hauteur de bati_ind
            if hauteur <= 2.5 :
                niveau = 1
            if hauteur > 2.5 :
                niveau = int(hauteur/2.5)
            if surfsol > 180 :
                surfhab = niveau * surfsol
            if surfsol <= 180 : 
                surfhab = surfsol
            numiris = 0
            nb_log_ino = 0 
            nb_log_ino2 = 0 
            poly = geom.asPolygon()
            centroid = geom.centroid().asPoint()
	        #partie inondation 
            test=0
            fit2 = provider2.getFeatures()
            feat2 = QgsFeature()
            while (fit2.nextFeature(feat2)):
                geom2 = feat2.geometry()
                if geom.intersects(geom2):
                    test = 1
            if test == 1 :
                resinon = resinon + [i]
                inondable = 1
                nbetageinon = 1
            if test == 0 :
                inondable = 0 
                nbetageinon = 0 
            #couche centroid
            pt = QgsFeature() 
            pt.setGeometry( QgsGeometry.fromPoint(centroid) ) 
            pt.setAttributes([int(i)])
            CenLay.startEditing()
            CenLay.addFeatures( [ pt ] ) 
            CenLay.commitChanges()
            resbati = resbati + [[id, numligne, surfsol, hauteur, niveau, surfhab, inondable, nbetageinon, numiris, poly, centroid, nb_log_ino, nb_log_ino2]]
            i = i + 1
            valbar = int((i * 100) / float(c))
            self.dlg.ui.progressBar.setProperty("value", valbar)
        self.dlg.close()
        #Affection du bati (par les centroides) aux IRIS et exploitation du fichier csv logement
        fit3 = provider3.getFeatures()
        feat3 = QgsFeature()
        fit4 = provider4.getFeatures()
        feat4 = QgsFeature()
        i2=0
        c = provider3.featureCount()
        self.dlg = fwabarDialog(self.iface.mainWindow())
        self.dlg.ui.progressBar.setProperty("value", 0)
        self.dlg.ui.label.setText("Progression du calcul (2/5)")
        self.dlg.show()
        while (fit3.nextFeature(feat3)):
            geomiris = feat3.geometry() 
            numiris = feat3.attributes()[int(indchampirisind)] # champ identifiant de IRIS
            featsPnt = CenLay.getFeatures(QgsFeatureRequest().setFilterRect(geomiris.boundingBox()))
            testinon = 0
            surf = 0
            ctmais = 0
            for featPnt in featsPnt:
                if featPnt.geometry().within(geomiris):
                    numpnt = featPnt.attributes()[0] 
                    resbati[numpnt][8] = numiris
                    if resbati[numpnt][5] > 180 :
                        surf = surf + resbati[numpnt][5]
                    if resbati[numpnt][5] <= 180 :
                        ctmais = ctmais + 1
                    if resbati[numpnt][6] == 1:
                        testinon = 1
            if testinon == 1 :
                resIrisInon = resIrisInon + [int(numiris)]
                surfhabiris = surfhabiris + [surf]
                ctmaisiris = ctmaisiris + [ctmais]
            #exploitation du fichier logement
            resiris = resiris + [0]
            resiris2 = resiris2 + [0]
            resirisnum = resirisnum + [int(numiris)]
            fit4.nextFeature(feat4)
            numirislog = feat4.attributes()[int(indchamplogiris)] # champ iris de logement (immeuble)
            nblog = feat4.attributes()[int(indchamplognbr)] # champ nb logement (immeuble)
            nbmais = feat4.attributes()[int(indchampmainbr)] # champ nb logement (maison) a modifier
            log = log + [int(numirislog)]
            log2 = log2 + [nblog]
            log3 = log3 + [nbmais]
            i2 = i2 + 1
            valbar = int((i2 * 100) / float(c))
            self.dlg.ui.progressBar.setProperty("value", valbar)
        print(ctmaisiris)
        self.dlg.close()
        c = len(resinon)
        self.dlg = fwabarDialog(self.iface.mainWindow())
        self.dlg.ui.progressBar.setProperty("value", 0)
        self.dlg.ui.label.setText("Progression du calcul (3/5)")
        self.dlg.show()
        #Calcul du nombre de logements inondables par bati
        for i in range(len(resinon)):
            id = resinon[i]
            surfsoldubat = resbati[id][2]
            if surfsoldubat <= 180 :
                numirisdubat = resbati[id][8]
                if numirisdubat != 0 :
                    numligniris = resIrisInon.index(int(numirisdubat))
                    nbmaiiristheo = ctmaisiris[numligniris]
                    numlignirislogmai = log.index(int(numirisdubat))
                    nbmaiiris = log3[numlignirislogmai]                
                    resbati[id][11] = nbmaiiris / float(nbmaiiristheo)
                    resbati[id][12] = nbmaiiris / float(nbmaiiristheo)
                    numligneresiris = resirisnum.index(int(numirisdubat))
                    resiris[numligneresiris] = resiris[numligneresiris] + (nbmaiiris / float(nbmaiiristheo))
                    resiris2[numligneresiris] = resiris2[numligneresiris] + (nbmaiiris / float(nbmaiiristheo))
                if numirisdubat == 0 :
                    "Do nothing"
            if surfsoldubat > 180 :
                numirisdubat = resbati[id][8]
                if numirisdubat != 0 :
                    nbetageinondubat = resbati[id][7]
                    nbetagedubat = resbati[id][4]
                    numligniris = resIrisInon.index(int(numirisdubat))
                    surftothabiris = surfhabiris[numligniris]
                    numlignirislog = log.index(int(numirisdubat))
                    nblogiris = log2[numlignirislog]
                    if nblogiris != 0 :
                        surfmoyiris = surftothabiris / float(nblogiris)
                        resfin = (surfsoldubat * nbetageinondubat) / float(surfmoyiris)
                        resbati[id][11] = resfin
                        resbati[id][12] = (surfsoldubat * nbetagedubat) / float(surfmoyiris)
                        numligneresiris = resirisnum.index(int(numirisdubat))
                        resiris[numligneresiris] = resiris[numligneresiris] + resfin
                        resiris2[numligneresiris] = resiris2[numligneresiris] + ((surfsoldubat * nbetagedubat) / float(surfmoyiris))
                    if nblogiris == 0 :
                        resbati[id][11] = 0
                        resbati[id][12] = 0
                if numirisdubat == 0 :
                    "Do nothing"
            valbar = int((i * 100) / float(c))
            self.dlg.ui.progressBar.setProperty("value", valbar)
        self.dlg.close()
        #Sauvegarde des resultats
        nbcol=int(provider.fields().count())
        provider.addAttributes([QgsField("Log_inon", QVariant.Double)])
        provider.addAttributes([QgsField("Mena_inon", QVariant.Double)])
        provider.addAttributes([QgsField("IRIS", QVariant.Int)])
        c = provider.featureCount()
        self.dlg = fwabarDialog(self.iface.mainWindow())
        self.dlg.ui.progressBar.setProperty("value", 0)
        self.dlg.ui.label.setText("Progression du calcul (4/5)")
        self.dlg.show()
        for i in range(len(resbati)):
            BatLayer.startEditing()
            BatLayer.changeAttributeValue(resbati[i][1],nbcol,resbati[i][11])
            BatLayer.changeAttributeValue(resbati[i][1],nbcol + 1,resbati[i][12])
            BatLayer.changeAttributeValue(resbati[i][1],nbcol + 2, int(resbati[i][8]))
            BatLayer.commitChanges()
            valbar = int((i * 100) / float(c))
            self.dlg.ui.progressBar.setProperty("value", valbar)
        self.dlg.close()
        nbcol3=int(provider3.fields().count())
        provider3.addAttributes([QgsField("Log_inon", QVariant.Double)])
        provider3.addAttributes([QgsField("Mena_inon", QVariant.Double)])
        c = provider3.featureCount()
        self.dlg = fwabarDialog(self.iface.mainWindow())
        self.dlg.ui.progressBar.setProperty("value", 0)
        self.dlg.ui.label.setText("Progression du calcul (5/5)")
        self.dlg.show()
        for i in range(len(log)):
            IrisLayer.startEditing()
            IrisLayer.changeAttributeValue(i,nbcol3,resiris[i])
            IrisLayer.changeAttributeValue(i,nbcol3 + 1,resiris2[i])
            IrisLayer.commitChanges()
            valbar = int((i * 100) / float(c))
            self.dlg.ui.progressBar.setProperty("value", valbar)
        self.dlg.close()
        QMessageBox.information(None, " Message : ", "Calcul termine")

  def calcultooltypecom(self):
        champiris = self.dlg3.ui.comboBox.currentText()
        for j in range(len(fields)):
          if str(champiris) == str(fields[j]) :
            indchampiris = j
        champcom = self.dlg3.ui.comboBox2.currentText()
        for j in range(len(fields2)):
          if str(champcom) == str(fields2[j]) :
            indchampcom = j
        champpop = self.dlg3.ui.comboBox3.currentText()
        for j in range(len(fields2)):
          if str(champpop) == str(fields2[j]) :
            indchamppop = j
        c1 = provider.featureCount()
        c2 = provider2.featureCount()
        c = (2 * c1) + c2 
        ic = 0
        self.dlg = fwabarDialog(self.iface.mainWindow())
        self.dlg.ui.progressBar.setProperty("value", 0)
        self.dlg.show()
        fit2 = provider2.getFeatures()
        feat = QgsFeature()
        tabcodecom = []
        tabpopcom = []
        while (fit2.nextFeature(feat)):  
            id = feat.attributes()[int(indchampcom)] 
            pop = feat.attributes()[int(indchamppop)] 
            tabcodecom = tabcodecom + [id]
            tabpopcom = tabpopcom + [pop]
            ic = ic + 1
            valbar = int((ic * 100) / float(c))
            self.dlg.ui.progressBar.setProperty("value", valbar)
        fit = provider.getFeatures()
        feat = QgsFeature()
        res = []
        while (fit.nextFeature(feat)):  
            id = str(feat.attributes()[int(indchampiris)])
            com = id[0:5]
            dep = int(id[0:2])
            if dep == 75 or dep == 77 or dep == 78 or dep == 91 or dep == 92 or dep == 93 or dep == 94 or dep == 95 :
                res = res + ["AggloParis"]
            if dep != 75 and dep != 77 and dep != 78 and dep != 91 and dep != 92 and dep != 93 and dep != 94 and dep != 95 and dep != 0 :
                ligne = tabcodecom.index(com)
                pop = tabpopcom[ligne]
                if int(pop) >= 100000:
				    res = res + ["GVille"]
                if (int(pop) >= 2000) and (int(pop) < 20000):
				    res = res + ["PVille"]
                if (int(pop) >= 20000) and (int(pop) < 100000):
				    res = res + ["MVille"]
                if int(pop) < 2000:
				    res = res + ["Rurale"]
            if dep == 0 :
                l = len(res)
                type = res[l-1]
                res = res + [type]
            ic = ic + 1
            valbar = int((ic * 100) / float(c))
            self.dlg.ui.progressBar.setProperty("value", valbar)
        nbcol=int(provider.fields().count())
        provider.addAttributes([QgsField("Type_Com", QVariant.String)])
        for i in range(len(res)):
            Layer.startEditing()
            Layer.changeAttributeValue(i,nbcol,res[i])
            Layer.commitChanges()
            ic = ic + 1
            valbar = int((ic * 100) / float(c))
            self.dlg.ui.progressBar.setProperty("value", valbar)
        self.dlg.close()
        QMessageBox.information(None, " Message : ", "Calcul termine")
             
