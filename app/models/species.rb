class Species < ActiveRecord::Base
    self.table_name = 'all_species'
    has_many :birds
    has_many :banders, through: :birds
    validates_presence_of :code, :name
    validates_uniqueness_of :code, :name

    def self.find_by_code(code)
        self.all.detect { |species| species.code == code.upcase }
    end
end