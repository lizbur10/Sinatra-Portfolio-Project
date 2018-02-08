class Report < ActiveRecord::Base
    belongs_to :bander

    def slug
        Helpers.slugify(self.date)
    end

end