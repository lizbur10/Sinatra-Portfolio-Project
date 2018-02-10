class Helpers

    def self.validate_email(email)
        /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/.match?(email.downcase)
    end

    def self.validate_alpha_code(code)
        /[A-Z]{4}/.match?(code.upcase)
    end

    def self.validate_species

    end

    def self.create_species

    end
    
    def self.slugify(input)
        slug = input.downcase.gsub(/['.]/, "")
        slug = slug.gsub(/[^a-z0-9]+/, '-')
        slug = slug.gsub(/-$/, "")
    end

    def self.count_by_species(date_string)
        Bird.group("species").where("banding_date = ?", date_string).count
    end

    def self.update_banding_numbers(passed_params, date_string)
        if passed_params[:delete]
            passed_params[:delete].each do | code, value |
                self.count_by_species(date_string).each do |species, count_from_db|
                    if species.code == code
                        count_from_db.times { self.delete_bird(code, date_string) }
                    end
                end
            end
        end
        self.count_by_species(date_string).each do |species, count_from_db|
            number_change = passed_params[:species][species.code].to_i - count_from_db
            if number_change > 0
                number_change.times {self.add_bird(species.code,date_string)}
            elsif number_change < 0
                number_change.abs.times {self.delete_bird(species.code,date_string)}
            end
        end
    end

    def self.add_bird(code, date_string)
        add_bird = Bird.create(:banding_date => date_string)
        add_bird.species = Species.find_by_code(code)
        add_bird.save
    end

    def self.delete_bird(code, date_string)
        find_species = Species.find_by_code(code)
        bird_to_delete = Bird.find_by(:banding_date => date_string, :species_id => find_species.id) 
        bird_to_delete.delete
    end

    def self.check_date(passed_params, session)
        if !session[:date]
            session[:date] = self.set_date(passed_params[:date])
        elsif self.slugify_date(session[:date]) != passed_params[:date]
            ## throw warning - want to switch dates?
            session[:date] = self.set_date(passed_params[:date])
        end
    end

    def self.set_date(date_string)
        year = Time.now.year
        month_string = self.parse_month(date_string).capitalize
        month = Date::MONTHNAMES.index(month_string) || Date::ABBR_MONTHNAMES.index(month_string)
        day = self.parse_day(date_string)
        Time.new(year, month, day)
    end

    def self.parse_month(date_string)
        month_string = date_string.gsub(/[^a-zA-Z]/, "")
    end

    def self.parse_day(date_string)
        str=date_string.gsub(/\s?[a-zA-Z]\s?/, "")
        str.gsub(/[-]/, "")
    end

    def self.date_string(date)
        date.strftime("%b %d")
    end

    def self.slugify_date_string(date_string)
        slugify(date_string)
    end

    def self.slugify_date(date)
        date.strftime("%b-%d").downcase
    end    

end