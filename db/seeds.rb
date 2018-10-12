# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def aname; rand(36**rand(5..10)).to_s(36); end

10.times { Student.create first_name: aname, last_name: aname, email: aname, country_id: rand(1..4) }

3.times { Country.create name: aname }
