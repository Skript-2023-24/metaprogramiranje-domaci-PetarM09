require './test'

# Demo
session = GoogleDrive::Session.from_config("config.json")
spreadsheet_key = "1_uropqd2z4e0_kEFgv7LRFzMkOvrbl4PH3ouahNNHxg"
worksheet_title = "Sheet1"

t = Table.new(session, spreadsheet_key, worksheet_title)

# t2 = Table.new(worksheet2)
p "Ispis tabele"
t.cela_tabela.each { |row| p row }

p "Red 0"
p t.row(0)


p "Red 1"
p t.row(1)

p "t['Prva Kolona']"
p t['Prva Kolona']

p "t['Prva Kolona'][1]"
p t['Prva Kolona'][1]

p "t['Prva Kolona'][2]= 2556"
p t['Prva Kolona'][2] = 2556

p "t['Prva Kolona']"
p t['Prva Kolona']

p "t.prvaKolona"
p t.prvaKolona

# Merging tables
#merged_table = t + t
#puts merged_table.cela_tabela.each { |row| p row }

# Subtracting tables
#subtracted_table = t - t
#puts subtracted_table.cela_tabela.each { |row| p row }

# Column operations
p "t.prvaKolona.sum"
p t.prvaKolona.sum
p "t['Prva Kolona'].sum"
puts t["Prva Kolona"].sum

p "t.prvaKolona.avg"
p t.prvaKolona.avg

# Map, select, reduce

p "t.prvaKolona.map{ |cell| cell + 1  }"
p t.prvaKolona.map { |cell| cell.to_i + 1 }

p "t.prvaKolona.select{ |cell| cell.to_i > 10  }"
p t.prvaKolona.select { |cell| cell.to_i > 0 }

p "t.prvaKolona.reduce(0){ |sum, cell| sum + cell.to_i  }"
p t.prvaKolona.reduce(0) { |sum, cell| sum + cell.to_i }


# Individual row access by unique identifier (e.g., indeks.rn4120)
puts t.by_index.rn4120.inspect

# Demonstrate other features as needed