# Script to convert and combine TIFs/PDFs
require 'mini_magick'
require 'combine_pdf'

######################
# combine blueprints #
######################

basefile = '/Users/erikgibbons/Downloads/Strain PLLC/888700-0103/FA_'
blueprints = ['001.TXT', '002.TXT', '003.TXT', '004.TXT']
pdf_basefile = '/Users/erikgibbons/code/scripts/888700-0103/FA_'
output_basefile = '/Users/erikgibbons/code/scripts/888700-0103/output_files/FA_'

header = []
rows = []

puts "blueprint consolidation...."
blueprints.each_with_index do |bp,i|
  puts "adding #{bp} to blueprint...."
  temp_rows = []
  file = File.open(basefile + bp)
  text = file.read
  text_array = text.split("\r\n")
  # set header if first run ### probably not necessary, but deal with it
  if i == 0
    header = text_array[0].split(",")
    # remove escapes from headers
    header.each_with_index { |h,j| header[j] = eval(h) }
  end
  # put each row into an array
  text_array[1..-1].each { |r| temp_rows << r.split(",") }
  # remove escapes from rows
  temp_rows.each { |r| r.each_with_index { |e,j| r[j] = eval(e) } }
  temp_rows.each { |r| rows << r }
  file.close
end

##################
# use blueprints #
##################

# set number of times to loop
last_file = rows.last[1][3..-1].to_i

# create each PDF
last_file.times do |i|
  puts "converting FA_#{(i + 1).to_s.rjust(5, '0')} to PDF...."
  # open TIFF file
  image = MiniMagick::Image.open(basefile + (i + 1).to_s.rjust(5, '0') + ".TIF")
  # convert to PDF
  image.format 'pdf'
  # write PDF
  image.write pdf_basefile + (i + 1).to_s.rjust(5, '0') + ".pdf"
end

rows.each do |row|
  # set range of files
  range = (row[0][3..-1].to_i..row[1][3..-1].to_i)
  puts "combining PDFs FA_#{range.first.to_s.rjust(5, '0')} through FA_#{range.last.to_s.rjust(5,'0')}..."
  # create empty pdf
  pdf = CombinePDF.new
  # push pdfs in range into template pdf
  range.each { |i| pdf << CombinePDF.load(pdf_basefile + i.to_s.rjust(5, '0') + ".pdf") }
  # save output file
  pdf.save output_basefile + range.first.to_s.rjust(5, '0') + ".pdf"
end
