# Script to convert and combine TIFs/PDFs
require 'mini_magick'
require 'combine_pdf'
require 'csv'
require 'find'

# updated on 29-JAN-2018
# image file can be anywhere in /IMAGE folder or subfolder, script will now find the image there
# data file can be anywhere in directory, script will not find the data file

# Put this script into the base directory of a relativity production
# Then run it

######################
#   open data file   #
#   sort documents   #
######################

data_file_paths = []
Find.find(File.dirname(__FILE__)) do |path|
  data_file_paths << path if ( path[".dat"] || path[".DAT"] )
end

docs = []
Dir.glob(data_file_paths).each do |filename|
  index = 0
  begDocCol, endDocCol = nil, nil
  CSV.foreach(filename) do |row|
    if index == 0
      row.to_s.split("þ").each_with_index do |cell, index|
        #puts "#{index}: #{cell}"
        begDocCol = index if cell.match(/beg/i)
        endDocCol = index if cell.match(/end/i)
      end
    else
      begDoc, endDoc = nil, nil
      row.to_s.split("þ").each_with_index do |cell, index|
        #puts "#{index}: #{cell}"
        begDoc = cell if index == begDocCol
        endDoc = cell if index == endDocCol
      end
      docs << [begDoc, endDoc]
    end
    index += 1
  end
end

###################
# use sorted docs #
###################
begin
  Dir.mkdir File.join(File.dirname(__FILE__), "PDF")
  Dir.mkdir File.join(File.dirname(__FILE__), "PDF/COMBINED")
  Dir.mkdir File.join(File.dirname(__FILE__), "PDF/INDIVIDUALS")
rescue
end
docs.each do |doc|
  # output filename corresponds to first bates number in range
  endfilename = File.join(File.dirname(__FILE__), "PDF/COMBINED/#{doc[0]}.pdf")

  # pull the start and end numbers out of the filename
  start_page = doc[0].match(/\d+$/).to_s.to_i
  end_page = doc[1].match(/\d+$/).to_s.to_i

  # get the prefix of the bates number
  prefix = doc[0].match(/^[^\d]+/).to_s

  # set variables
  page = start_page
  output_files = []

  # create individual pdf files for each image
  (end_page - start_page + 1).times do
    filename = "#{doc[0][0..-(page.to_s.length + 1)]}#{page}"
    puts filename

    infilename = nil

    # find the image that corresponds to the production data file
    Find.find(File.join(File.dirname(__FILE__), "IMAGES")) do |path|
      infilename = path if path["#{filename}"]
      break if infilename
    end

    # create output filename
    outfilename = File.join(File.dirname(__FILE__), "PDF/INDIVIDUALS/#{filename}.pdf")

    # save time by only writing output PDF (single image) file if it doesn't already exist
    unless File.file?(outfilename)
      image = MiniMagick::Image.open(infilename)
      image.format 'pdf'
      image.write outfilename
    end

    # store all output filenames into array and iterate
    output_files << outfilename
    page += 1
  end

  # combine all of the output single page PDF files into a single output file
  pdf = CombinePDF.new
  output_files.each { |outfile| pdf << CombinePDF.load(outfile) }
  pdf.save endfilename
end
