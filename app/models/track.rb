class Track < ActiveRecord::Base
    has_many :tracksegments, :dependent => :destroy
    has_many :points, :through => :tracksegments
    has_attached_file :gpx
    
    do_not_validate_attachment_file_type :gpx
    before_save :parse_file
   
    def parse_file
        # get the uploaded file from paperclip
        #Paperclip.io_adapters.for(gpx.file).read
        tempfile = gpx.queued_for_write[:original]
        print tempfile.inspect.to_s
        doc = Nokogiri::XML(tempfile)
        parse_xml(doc)
    end
    
    def parse_xml(doc)
        doc.root.elements.each do |node|
            parse_tracks(node)
        end
        
    end
    
    def parse_tracks(node)
        Rails.logger.debug("Node name: #{node.node_name}")
       if node.node_name.eql? 'trk' 
            node.elements.each do |node|
               parse_track_segments(node)
            end
        end
    end
    
    def parse_track_segments(node)
        if node.node_name.eql? 'trkseg'
            tmp_segment = Tracksegment.new
            node.elements.each do |node|
                parse_points(node,tmp_segment)
            end
            self.tracksegments << tmp_segment
        end
    end
    
    def parse_points(node,tmp_segment)
        if node.node_name.eql? 'trkpt'
          tmp_point = Point.new
          tmp_point.latitude = node.attr("lat")
          tmp_point.longitude = node.attr("lon")
          node.elements.each do |node|
            tmp_point.name = node.text.to_s if node.name.eql? 'name'
            tmp_point.elevation = node.text.to_s if node.name.eql? 'ele'
            tmp_point.description = node.text.to_s if node.name.eql? 'desc'
            tmp_point.point_created_at = node.text.to_s if node.name.eql? 'time'
          end
          tmp_segment.points << tmp_point
        end
    end
        
end
