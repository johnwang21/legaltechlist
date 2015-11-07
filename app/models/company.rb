class Company < ActiveRecord::Base
  has_many :taggings
  has_many :tags, through: :taggings
  
  #this should be has_one, but apparently there's a bug?
  belongs_to :category
  
  accepts_nested_attributes_for :category
  
  validates :name, presence: true, length: {minimum: 5}
  validates :location, presence: true, length: {minimum: 5}
  validates :founded_date, presence: true, format: {with: /\d\d\d\d/, message: "must be a 4-digit year."}
  validates :category, presence: true
  validates :description, presence: true, length: {minimum: 25}
  validates :employee_count, presence: true, format: {with: /[\d]+/, message: "must contain a number."}
  
	include PgSearch
	pg_search_scope :search,
                  	:against => :name,
                  	:using => {
                    	:tsearch => {:prefix => true}
                  }

	def self.text_search(query)
		if query.present?
			search(query)
		else
			all
		end
	end
  
  def self.tagged_with(name)
    Tag.find_by_name!(name).companies
  end
  
  def all_tags=(names)
    self.tags = names.split(",").map do |name|
      Tag.where(name: name.strip).first_or_create!
    end
  end
  
  def all_tags
    self.tags.map(&:name).join(", ")
  end

end
