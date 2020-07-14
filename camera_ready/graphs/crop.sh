#!/bin/bash

pdfcrop $1.pdf
mv $1-crop.pdf $1.pdf
