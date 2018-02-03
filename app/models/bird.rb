class Bird < ActiveRecord::Base
    belongs_to :species
    belongs_to :bander
    validates_presence_of :banding_date
    
end