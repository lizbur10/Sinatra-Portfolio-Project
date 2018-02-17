class Report < ActiveRecord::Base
    belongs_to :bander
    has_many :birds, through: :bander
    has_many :species, through: :birds
end