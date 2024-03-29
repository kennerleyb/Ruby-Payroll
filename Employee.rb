

#------------------------------------------------------------------
class Employee
	attr_accessor :legislation, :flags, :dateOfBirth, :employmentStartDate
	def initialize
		@legislation = DateEffective.new
		@dateOfBirth = nil
		@employmentStartDate = nil
	end
end

#------------------------------------------------------------------
ElementData = Struct.new(:id, :data, :effDate, :deleted)

class DateEffective
#basic class for holding date effective elements
#is a hash of arrays containing ElementData structs.
#The hash key is the name of the element.
#Value is an array of struct ELementData

	def initialize()
		@contents = {}
	end

	def add (id, data, effDate:$MAGIC_DATE, deleted: false)
		#if there is no entry for this data name yet, create an entry
		@contents[id] ||= []
		#TODO - mark any existing entries on this date as deleted
		@contents[id] << ElementData.new(id, data, effDate, deleted)
	end

	def valueAtDate(id, effDate)
		#returns value for this id at the specified date
		mostRecent = nil
		x = @contents[id].each do |line|
			#only consider if less than target date and
			#this line is not marked as deleted
			#then only if we have no found entry yet,
			#or this one is later than the best found entry
			mostRecent = line if
				(line.effDate <= effDate && line.deleted == false) &&
			 	(mostRecent.nil? || (line.effDate > mostRecent.effDate))
		end
		mostRecent
	end

	def valuesAtDate(effDate)
		#returns all values at the specified date
		@contents.keys.each_with_object({}) {|v, h|
			h[v] = valueAtDate(v, effDate).data}
	end
end

