class Helpers

    def self.slugify(input)
        slug = input.downcase.gsub(/['.]/, "")
        slug = slug.gsub(/[^a-z0-9]+/, '-')
        slug = slug.gsub(/-$/, "")
    end

    def self.count_by_species(date_string)
        Bird.group("species").where("banding_date = ?", date_string).count
    end

    def self.delete_species(code)
        species_to_delete = Species.find_by_code(code)
        bird_to_delete = Bird.find_by(:banding_date => date_string, :species_id => species_to_delete.id) 
        bird_to_delete.delete
    end

    def self.set_date(date_string)
        year = Time.now.year
        month_string = parse_month(date_string).capitalize
        month = Date::MONTHNAMES.index(month_string) || Date::ABBR_MONTHNAMES.index(month_string)
        day = parse_day(date_string)
        Time.new(year, month, day)
    end

    def self.parse_month(date_string)
        month_string = date_string.gsub(/[^a-zA-Z]/, "")
    end

    def self.parse_day(date_string)
        str=date_string.gsub(/\s?[a-zA-Z]\s?/, "")
        str.gsub(/[-]/, "")
    end

    # def self.date_string
    #     session[:date].strftime("%b %d")
    # end

    def self.slugify_date_string(date_string)
        slugify(date_string)
    end

    def self.slugify_date(date)
        date.strftime("%b-%d").downcase
    end    

end