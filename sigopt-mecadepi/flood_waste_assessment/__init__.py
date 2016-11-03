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

def classFactory(iface):
  from flood_waste_assessment import FloodWasteAssessment
  return FloodWasteAssessment(iface)
