#!/bin/env ruby

require 'csv'

csv_file=File.open('prova.csv', 'w')

CSV::Writer.generate(csv_file).add_row(['1','prova', 'commento'])
CSV::Writer.generate(csv_file).add_row(['2','prova2', 'commento2'])

csv_file.close


