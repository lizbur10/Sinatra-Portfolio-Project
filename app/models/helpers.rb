class Helpers

    def self.slugify(input)
        slug = input.downcase.gsub(/['.]/, "")
        slug = slug.gsub(/[^a-z0-9]+/, '-')
        slug = slug.gsub(/-$/, "")
    end

end