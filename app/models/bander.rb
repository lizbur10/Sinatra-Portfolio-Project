class Bander < ActiveRecord::Base
    validates_presence_of :name, :password
    has_many :birds
    has_many :species, through: :birds

    def slug
        slug = self.name.downcase.gsub(/[\+]/, " plus ")
        slug = slug.gsub(/['.]/, "")
        slug = slug.gsub(/[^a-z0-9]+/, '-')
        slug = slug.gsub(/-$/, "")
    end

    def self.find_by_slug(slug)
        self.all.detect { |bander| bander.slug == slug }
    end
    
end