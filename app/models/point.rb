class Point < ActiveRecord::Base
  belongs_to :tracksegment
  #:description, :elevation, :latitude, :longitude, :name, :point_created_at
end
