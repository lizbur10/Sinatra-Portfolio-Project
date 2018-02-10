class Species < ActiveRecord::Base
    self.table_name = 'all_species'
    has_many :birds
    has_many :banders, through: :birds

end