# Script to convert and combine TIFs/PDFs
require 'mini_magick'
require 'combine_pdf'
require 'csv'

# Put this script into the base directory of a relativity production
# Then run it

######################
#   open data file   #
######################

data_file_path = File.join(File.dirname(__FILE__), "DATA/*.dat")
docs = []
Dir.glob(data_file_path).each do |filename|
  index = 0
  begDocCol, endDocCol = nil, nil
  CSV.foreach(filename) do |row|
    if index == 0
      row.to_s.split("þ").each_with_index do |cell, index|
        #puts "#{index}: #{cell}"
        begDocCol = index if cell.to_s == "ProdBegBates"
        endDocCol = index if cell.to_s == "ProdEndBates"
      end
    else
      begDoc, endDoc = nil, nil
      row.to_s.split("þ").each_with_index do |cell, index|
        #puts "#{index}: #{cell}"
        begDoc = cell if index == begDocCol
        endDoc = cell if index == endDocCol
      end
      docs << [begDoc, endDoc, ]
    end
    index += 1
  end
end

######################
# combine blueprints #
######################

# basefile = '/Users/erikgibbons/Downloads/Strain PLLC/888700-0103/FA_'
# datFile =
# blueprints = ['001.TXT', '002.TXT', '003.TXT', '004.TXT']
# pdf_basefile = '/Users/erikgibbons/code/scripts/888700-0103/FA_'
# output_basefile = '/Users/erikgibbons/code/scripts/888700-0103/output_files/FA_'

# header = []
# rows = []

# puts "blueprint consolidation...."
# blueprints.each_with_index do |bp,i|
#   puts "adding #{bp} to blueprint...."
#   temp_rows = []
#   file = File.open(basefile + bp)
#   text = file.read
#   text_array = text.split("\r\n")
#   # set header if first run ### probably not necessary, but deal with it
#   if i == 0
#     header = text_array[0].split(",")
#     # remove escapes from headers
#     header.each_with_index { |h,j| header[j] = eval(h) }
#   end
#   # put each row into an array
#   text_array[1..-1].each { |r| temp_rows << r.split(",") }
#   # remove escapes from rows
#   temp_rows.each { |r| r.each_with_index { |e,j| r[j] = eval(e) } }
#   temp_rows.each { |r| rows << r }
#   file.close
# end

##################
# use blueprints #
##################
begin
  Dir.mkdir File.join(File.dirname(__FILE__), "PDF")
  Dir.mkdir File.join(File.dirname(__FILE__), "PDF/COMBINED")
  Dir.mkdir File.join(File.dirname(__FILE__), "PDF/INDIVIDUALS")
rescue
end
docs.each do |doc|
  endfilename = File.join(File.dirname(__FILE__), "PDF/COMBINED/#{doc[0]}.pdf")
  start_page = doc[0].match(/\d+$/).to_s.to_i
  end_page = doc[1].match(/\d+$/).to_s.to_i
  prefix = doc[0].match(/^[^\d]+/).to_s

  page = start_page
  output_files = []
  (end_page - start_page + 1).times do
    filename = "#{doc[0][0..-(page.to_s.length + 1)]}#{page}"
    puts filename
    infilename = File.join(File.dirname(__FILE__), "IMAGES/IMAGES001/#{filename}.tif")
    outfilename = File.join(File.dirname(__FILE__), "PDF/INDIVIDUALS/#{filename}.pdf")
    image = MiniMagick::Image.open(infilename)
    image.format 'pdf'
    image.write outfilename
    output_files << outfilename
    page += 1
  end

  pdf = CombinePDF.new
  output_files.each { |outfile| pdf << CombinePDF.load(outfile) }
  pdf.save endfilename
end

# set number of times to loop
# last_file = rows.last[1][3..-1].to_i

# create each PDF
# last_file.times do |i|
  # puts "converting FA_#{(i + 1).to_s.rjust(5, '0')} to PDF...."
  # open TIFF file
#   image = MiniMagick::Image.open(basefile + (i + 1).to_s.rjust(5, '0') + ".TIF")
  # convert to PDF
#   image.format 'pdf'
  # write PDF
#   image.write pdf_basefile + (i + 1).to_s.rjust(5, '0') + ".pdf"
# end

# rows.each do |row|
  # set range of files
#   range = (row[0][3..-1].to_i..row[1][3..-1].to_i)
#   puts "combining PDFs FA_#{range.first.to_s.rjust(5, '0')} through FA_#{range.last.to_s.rjust(5,'0')}..."
  # create empty pdf
#   pdf = CombinePDF.new
  # push pdfs in range into template pdf
#   range.each { |i| pdf << CombinePDF.load(pdf_basefile + i.to_s.rjust(5, '0') + ".pdf") }
  # save output file
#   pdf.save output_basefile + range.first.to_s.rjust(5, '0') + ".pdf"
# end
