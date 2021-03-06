class Bander < ActiveRecord::Base
    has_secure_password
    has_many :birds
    has_many :reports
    has_many :species, through: :birds

    def slug
        Helpers.slugify(self.name)
    end

    def self.find_by_slug(slug)
        self.all.detect { |bander| bander.slug == slug }
    end
    
end