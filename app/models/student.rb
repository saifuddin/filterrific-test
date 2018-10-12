class Student < ApplicationRecord
	belongs_to :country

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :with_country_id,
      :with_created_at_gte
    ]
  )

  # Scope definitions. We implement all Filterrific filters through ActiveRecord
  # scopes. In this example we omit the implementation of the scopes for brevity.
  # Please see 'Scope patterns' for scope implementation details.
	scope :search_query, lambda { |query|
	  # Searches the students table on the 'first_name' and 'last_name' columns.
	  # Matches using LIKE, automatically appends '%' to each term.
	  # LIKE is case INsensitive with MySQL, however it is case
	  # sensitive with PostGreSQL. To make it work in both worlds,
	  # we downcase everything.
	  return nil  if query.blank?

	  # condition query, parse into individual keywords
	  terms = query.downcase.split(/\s+/)

	  # replace "*" with "%" for wildcard searches,
	  # append '%', remove duplicate '%'s
	  terms = terms.map { |e|
	    (e.gsub('*', '%') + '%').gsub(/%+/, '%')
	  }
	  # configure number of OR conditions for provision
	  # of interpolation arguments. Adjust this if you
	  # change the number of OR conditions.
	  num_or_conds = 2
	  where(
	    terms.map { |term|
	      "(LOWER(students.first_name) LIKE ? OR LOWER(students.last_name) LIKE ?)"
	    }.join(' AND '),
	    *terms.map { |e| [e] * num_or_conds }.flatten
	  )
	}

	scope :sorted_by, lambda { |sort_option|
	  # extract the sort direction from the param value.
	  direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
	  case sort_option.to_s
	  when /^created_at_/
	    # Simple sort on the created_at column.
	    # Make sure to include the table name to avoid ambiguous column names.
	    # Joining on other tables is quite common in Filterrific, and almost
	    # every ActiveRecord table has a 'created_at' column.
	    order("students.created_at #{ direction }")
	  when /^name_/
	    # Simple sort on the name colums
	    order("LOWER(students.last_name) #{ direction }, LOWER(students.first_name) #{ direction }")
	  when /^country_name_/
	    # This sorts by a student's country name, so we need to include
	    # the country. We can't use JOIN since not all students might have
	    # a country.
	    order("LOWER(countries.name) #{ direction }").includes(:country).references(:country)
	  else
	    raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
	  end
	}

	scope :with_country_id, lambda { |country_ids|
	  where(country_id: [*country_ids])
	}

	scope :with_created_at_gte, lambda { |reference_time|
	  where('students.created_at >= ?', reference_time)
	}

  def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Registration date (newest first)', 'created_at_desc'],
      ['Registration date (oldest first)', 'created_at_asc'],
      ['Country (a-z)', 'country_name_asc']
    ]
  end

  def full_name
  	"#{first_name} #{last_name}"
  end

  def country_name
  	country.name
  end

  def decorated_created_at
  	created_at
  end
end
