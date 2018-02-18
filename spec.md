# Specifications for the Sinatra Assessment

Specs:
- [x] Use Sinatra to build the app - the app uses the sinatra gem and includes controllers with routes 
- [x] Use ActiveRecord for storing information in a database - all models inherit from ActiveRecord; belongs_to, has_many, and has_many through relationships are defined
- [x] Include more than one model class (list of model class names e.g. User, Post, Category) - I have 4 model classes defined: Bander, Bird, Species, and Report
- [x] Include at least one has_many relationship (x has_many y e.g. User has_many Posts) - I included three has_many relationships (banders have many birds and many reports; species have many birds) I also have four has_many through relationships (banders have many species through birds; species have many banders through birds; reports have many birds through banders and have many species through birds). Note that not all of these relationships are used in any meaningful way in the code.
- [x] Include user accounts - banders must register and log in to view, create, edit and post reports 
- [x] Ensure that users can't modify content created by other users - only info belonging to a bander is exposed when they navigate through the app; if anyone tries to access content directly via the url, there are error messages or redirects for: bander account info; reports/:date; reports/:date/edit; reports/:date/preview. Also, banders are not allowed to add birds to a report that doesn't belong to them (based on the date).
- [x] Ensure that the belongs_to resource has routes for Creating, Reading, Updating and Destroying - I have 2 belongs_to resources: birds and reports. There are methods for creating, updating, and destroying birds and methods for creating, reading, and updating reports (so I have all the CRUD routes between the two)
- [x] Include user input validations - there are validations for: registration info (all fields entered, valid email, name & email unique); login info (name/password combo valid); edit account info (all fields populated, email valid); new birds (alpha code formatted correctly, alpha code/name combo matches a record in the database, and number banded >=0); edit birds (number banded >= 0)
- [x] Display validation failures to user with error message (example form URL e.g. /posts/new) - validation failure error messages are created for: /banders/new, banders/:slug/edit, /login, /birds/new, /reports/:date/edit. Note: error messages are created and saved into a Flash hash, but for some reason they are not being written out consistently - some work, some don't 
- [x] Your README.md includes a short description, install instructions, a contributors guide and a link to the license for your code - Yes

Confirm
- [x] You have a large number of small Git commits (I have a very large number of commits and most of them are small - I forgot occasionally)
- [x] Your commit messages are meaningful (mostly)
- [x] You made the changes in a commit that relate to the commit message (mostly)
- [x] You don't include changes in a commit that aren't related to the commit message (mostly)
