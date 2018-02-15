# Specifications for the Sinatra Assessment

Specs:
- [x] Use Sinatra to build the app - all models inherit from ActiveRecord
- [x] Use ActiveRecord for storing information in a database - all models inherit from active record; has_many and belongs_to relationships are defined
- [x] Include more than one model class (list of model class names e.g. User, Post, Category) - I have 4 models defined 
- [x] Include at least one has_many relationship (x has_many y e.g. User has_many Posts) - banders have many birds, reports and species through birds; species have many birds and many banders through birds
- [x] Include user accounts - banders must register and log in to create reports 
- [x] Ensure that users can't modify content created by other users - only info belonging to a bander is exposed; if access directly via url, error messages or redirects for: bander account info; reports/edit
- [x] Ensure that the belongs_to resource has routes for Creating, Reading, Updating and Destroying - there are methods for creating, updating, and destroying birds; methods for creating, reading, and updating reports; and methods for creating and reading species.
- [x] Include user input validations - there are validations for: registration info (name, email, password); login info (name/password correct); edit account info (email valid); species alpha code; and number banded (>=0) **NEED TO CHECK THOROUGHLY
- [x] Display validation failures to user with error message (example form URL e.g. /posts/new) - there are flash messages but for some reason they are not working consistently **NEED TO FIX FLASH MESSAGES
- [ ] Your README.md includes a short description, install instructions, a contributors guide and a link to the license for your code

Confirm
- [x] You have a large number of small Git commits (mostly - I forgot occasionally)
- [x] Your commit messages are meaningful (mostly - sometimes I couldn't remember exactly what I'd done)
- [x] You made the changes in a commit that relate to the commit message (mostly - some minor things snuck through from time to time)
- [x] You don't include changes in a commit that aren't related to the commit message (mostly)
