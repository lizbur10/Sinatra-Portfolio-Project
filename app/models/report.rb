class Report < ActiveRecord::Base
    belongs_to :bander
    has_many :birds
    has_many :species, through: :birds
end