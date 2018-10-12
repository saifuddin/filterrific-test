class Country < ApplicationRecord
	has_many :students

	def self.options_for_select
	  order('LOWER(name)').map { |e| [e.name, e.id] }
	end
end
