require 'date'
require_relative 'NICalc.rb'
$MAGIC_DATE = '1970-01-01'

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
#is a hash of arrays containing structs.
#The hash key is the name of the element. Value is an array of struct ELementData
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
		mostRecent = nil
		x = @contents[id].each do |line|
			#only consider if less than target date and this line is not marked as deleted
			#then only if we have no found entry yet, or this one is later than the best found entry
			mostRecent = line if (line.effDate <= effDate && line.deleted == false) && (mostRecent.nil? || (line.effDate > mostRecent.effDate))
		end
		mostRecent
	end

	def valuesAtDate(effDate)
		@contents.keys.each_with_object({}) { |v, h| h[v] = valueAtDate(v, effDate).data}
	end
end

#------------------------------------------------------------------
bob = Employee.new
#TODO - holding DOB and DOBverified are not date effective. How should these be passed?
#TODO - contracted out and mariner flags come from job details, so will be a separate DateEffective?
#       As will apprentice flags next year
bob.dateOfBirth = '1980-01-01'
bob.employmentStartDate = '2010-01-01'
bob.legislation.add(:DateOfBirth, bob.dateOfBirth)
bob.legislation.add(:NiSpecialExemption, false)
bob.legislation.add(:NiMariner, false)
bob.legislation.add(:NiOverStatePensionAge, true)
bob.legislation.add(:NiContractedOut, true)
bob.legislation.add(:NiMarriedReduced, false)
bob.legislation.add(:NiUnder21, false)
bob.legislation.add(:NiDeferred, false)
bob.legislation.add(:DateOfBirthVerified, true)

niPay = NiPay.new(	value: 2000.00,
					payDate: '2015-05-31',
					payFrequency: :month,
					flags: bob.legislation
					)


puts UkNationalInsurance::Calc(niPay:niPay)
# puts niPay.inspect
# puts UkNationalInsurance::SUPPORTED_YEARS
# puts bob.legislation.inspect
# puts bob.legislation.valueAtDate(:NiMariner, '2015-08-26')