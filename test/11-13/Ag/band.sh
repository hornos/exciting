#!/bin/bash

zcat bandstructure.xml.gz | xsltproc ../../../exc/xml/vt/xmlband2agr.xsl - > bandstructure.agr

